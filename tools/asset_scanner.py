#!/usr/bin/env python3
import os
import re
import sys
from pathlib import Path

# 设置根目录
ROOT_DIR = Path('/Users/marvi/CursorWorks/nativekeyai/wechat')
PAGES_DIR = ROOT_DIR / 'pages'
ASSETS_DIR = ROOT_DIR / 'assets'
COMPONENTS_DIR = ROOT_DIR / 'components'
APP_FILES = [ROOT_DIR / 'app.js', ROOT_DIR / 'app.json', ROOT_DIR / 'app.wxss']

def get_file_size_mb(file_path):
    """返回文件大小（MB）"""
    size_bytes = os.path.getsize(file_path)
    return size_bytes / (1024 * 1024)

def extract_resource_paths(file_path):
    """从文件中提取资源路径引用"""
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # 查找所有可能的资源路径模式
    patterns = [
        r'[\'"]/assets/[^\'"]+[\'"]',  # "/assets/path/file.ext"
        r'[\'"]\.\.?/assets/[^\'"]+[\'"]',  # "../assets/path/file.ext" or "./assets/path/file.ext"
        r'[\'"](?:\.\.?/)+[^\'"]+\.(png|jpg|jpeg|gif|svg|mp3|mp4|webp)[\'"]',  # 相对路径资源
        r'src=[\'"]/assets/[^\'"]+[\'"]',  # src="/assets/path/file.ext"
        r'src=[\'"]\.\.?/assets/[^\'"]+[\'"]',  # src="../assets/path/file.ext"
        r'url\([\'"]?(?:/|\.\.?/)?assets/[^\'"]+[\'"]?\)',  # CSS中的url()引用
    ]
    
    resources = []
    for pattern in patterns:
        matches = re.findall(pattern, content)
        for match in matches:
            if isinstance(match, tuple):
                match = match[0]
            # 清理引号和url()
            clean_path = match.replace('"', '').replace("'", '').replace('url(', '').replace(')', '')
            # 清理src=
            if clean_path.startswith('src='):
                clean_path = clean_path[4:]
            resources.append(clean_path)
    
    return resources

def scan_all_files():
    """扫描所有页面和组件文件，提取资源引用"""
    all_references = []
    
    # 扫描页面文件
    for root, _, files in os.walk(PAGES_DIR):
        for file in files:
            if file.endswith(('.wxml', '.wxss', '.js')):
                file_path = os.path.join(root, file)
                refs = extract_resource_paths(file_path)
                all_references.extend(refs)
    
    # 扫描组件文件
    for root, _, files in os.walk(COMPONENTS_DIR):
        for file in files:
            if file.endswith(('.wxml', '.wxss', '.js')):
                file_path = os.path.join(root, file)
                refs = extract_resource_paths(file_path)
                all_references.extend(refs)
    
    # 扫描app文件
    for app_file in APP_FILES:
        if app_file.exists():
            refs = extract_resource_paths(app_file)
            all_references.extend(refs)
    
    return all_references

def get_all_assets():
    """获取所有资源文件列表"""
    all_assets = []
    
    for root, _, files in os.walk(ASSETS_DIR):
        for file in files:
            # 排除.DS_Store和其他非资源文件
            if not file.startswith('.'):
                rel_path = os.path.relpath(os.path.join(root, file), ROOT_DIR)
                all_assets.append(rel_path)
    
    return all_assets

def find_large_files(threshold_kb=200):
    """查找大于阈值的资源文件"""
    large_files = []
    
    for root, _, files in os.walk(ASSETS_DIR):
        for file in files:
            file_path = os.path.join(root, file)
            size_kb = os.path.getsize(file_path) / 1024
            if size_kb > threshold_kb:
                rel_path = os.path.relpath(file_path, ROOT_DIR)
                large_files.append((rel_path, round(size_kb, 2)))
    
    return large_files

def normalize_path(path):
    """标准化路径以便比较"""
    # 移除开头的斜杠和./或../
    path = re.sub(r'^[/\.]+', '', path)
    # 确保assets/在开头
    if not path.startswith('assets/'):
        path = 'assets/' + path.split('assets/')[-1]
    return path

def main():
    print("正在扫描项目文件...")
    
    # 获取页面中引用的所有资源
    referenced_assets = scan_all_files()
    normalized_refs = [normalize_path(ref) for ref in referenced_assets]
    
    # 获取资源目录中的所有文件
    all_assets = get_all_assets()
    
    # 查找未使用的资源
    unused_assets = []
    for asset in all_assets:
        normalized_asset = normalize_path(asset)
        if normalized_asset not in normalized_refs:
            unused_assets.append(asset)
    
    # 查找大文件
    large_files = find_large_files()
    
    # 打印结果
    print("\n===== 未使用的资源文件 =====")
    for asset in sorted(unused_assets):
        print(f"- {asset}")
    
    print(f"\n总计: {len(unused_assets)} 个未使用的资源文件")
    
    print("\n===== 大于200KB的资源文件 =====")
    for file, size in sorted(large_files, key=lambda x: x[1], reverse=True):
        print(f"- {file} ({size:.2f} KB)")
    
    print(f"\n总计: {len(large_files)} 个大于200KB的资源文件")

if __name__ == "__main__":
    main()
