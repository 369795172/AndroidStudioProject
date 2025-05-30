#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
调整图片尺寸

用法:
python resize_image.py --input <输入图片> --output <输出目录> --sizes 28,108
"""

import argparse
import os
from pathlib import Path
from PIL import Image

def resize_image(input_path, output_dir, sizes):
    """将图片调整为多个指定尺寸"""
    
    # 创建输出目录
    os.makedirs(output_dir, exist_ok=True)
    
    # 打开源图片
    try:
        img = Image.open(input_path)
        print(f"读取图片: {input_path}")
        print(f"原始尺寸: {img.size}")
    except Exception as e:
        print(f"错误: 无法打开图片 {input_path}")
        print(f"  {e}")
        return []
    
    # 获取文件名（不含扩展名）
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    
    output_paths = []
    
    # 调整每个尺寸
    for size in sizes:
        # 确保尺寸是方形
        new_size = (size, size)
        
        # 创建调整后的图片
        resized_img = img.resize(new_size, Image.Resampling.LANCZOS)
        
        # 保存调整后的图片
        output_path = os.path.join(output_dir, f"{base_name}_{size}x{size}.png")
        resized_img.save(output_path, "PNG", optimize=True)
        
        output_paths.append(output_path)
        print(f"已生成图片: {output_path}")
    
    return output_paths

def main():
    parser = argparse.ArgumentParser(description='调整图片尺寸')
    parser.add_argument('--input', '-i', required=True, help='输入图片路径')
    parser.add_argument('--output', '-o', required=True, help='输出图片目录')
    parser.add_argument('--sizes', '-s', default='28,108', help='目标尺寸列表，用逗号分隔（默认：28,108）')
    
    args = parser.parse_args()
    
    input_path = args.input
    output_dir = args.output
    
    # 解析尺寸
    try:
        sizes = [int(s.strip()) for s in args.sizes.split(',')]
    except ValueError:
        print("错误: 尺寸必须是整数")
        return
    
    if not os.path.isfile(input_path):
        print(f"错误: 文件 {input_path} 不存在")
        return
    
    # 调整图片尺寸
    output_paths = resize_image(input_path, output_dir, sizes)
    
    # 打印结果
    if output_paths:
        print("\n转换完成:")
        print(f"- 输入文件: {input_path}")
        print(f"- 输出目录: {output_dir}")
        print(f"- 生成图片数量: {len(output_paths)}")
        
        for path in output_paths:
            print(f"  - {path}")

if __name__ == "__main__":
    main() 