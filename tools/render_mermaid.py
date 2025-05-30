#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
将Markdown文件中的Mermaid流程图转换为图片

用法:
python render_mermaid.py --input <markdown文件> --output <输出目录>
"""

import argparse
import asyncio
import os
import re
import sys
from pathlib import Path

from playwright.async_api import async_playwright

# Mermaid在线渲染器HTML模板
MERMAID_HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mermaid Diagram</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10.3.0/dist/mermaid.min.js"></script>
    <style>
        body {
            margin: 0;
            padding: 0;
            background: white;
        }
        #container {
            padding: 20px;
        }
    </style>
</head>
<body>
    <div id="container">
        <div class="mermaid">
            __MERMAID_CODE__
        </div>
    </div>
    <script>
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            fontFamily: 'Arial'
        });
    </script>
</body>
</html>
"""

async def render_mermaid_to_images(markdown_path, output_dir):
    """将Markdown文件中的Mermaid代码渲染为图片"""
    
    print(f"处理文件: {markdown_path}")
    
    # 创建输出目录
    os.makedirs(output_dir, exist_ok=True)
    
    # 读取Markdown文件
    with open(markdown_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 提取所有Mermaid代码块
    mermaid_blocks = re.findall(r'```mermaid\n(.*?)```', content, re.DOTALL)
    
    if not mermaid_blocks:
        print("未找到Mermaid代码块")
        return []
    
    image_paths = []
    
    # 启动Playwright
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={"width": 1200, "height": 800})
        
        for i, mermaid_code in enumerate(mermaid_blocks):
            # 准备HTML
            html_content = MERMAID_HTML_TEMPLATE.replace('__MERMAID_CODE__', mermaid_code)
            
            # 写入临时HTML文件
            temp_html = os.path.join(output_dir, f"temp_mermaid_{i}.html")
            with open(temp_html, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            # 渲染页面
            await page.goto(f"file://{os.path.abspath(temp_html)}")
            
            # 等待Mermaid渲染完成
            await page.wait_for_function('document.querySelector(".mermaid svg") !== null')
            
            # 获取渲染后的SVG元素
            svg_elem = await page.query_selector('.mermaid svg')
            
            # 生成不同格式的图片
            output_base = os.path.join(output_dir, f"flowchart_{i+1}")
            
            # 截图保存为PNG
            png_path = f"{output_base}.png"
            await svg_elem.screenshot(path=png_path)
            image_paths.append(png_path)
            
            # 删除临时HTML文件
            os.unlink(temp_html)
            
            print(f"已生成图片: {png_path}")
        
        await browser.close()
    
    return image_paths

def extract_diagram_titles(markdown_path):
    """从Markdown文件中提取流程图标题"""
    with open(markdown_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 查找每个Mermaid代码块之前的标题
    sections = re.split(r'```mermaid', content)
    titles = []
    
    for i, section in enumerate(sections):
        if i == 0:  # 第一部分是文件开头到第一个mermaid块之前的内容
            continue
        
        # 从前面的文本中找最近的标题
        lines = sections[i-1].strip().split('\n')
        title = None
        
        # 从下往上查找最近的标题行
        for line in reversed(lines):
            if line.startswith('#'):
                title = line.lstrip('#').strip()
                break
        
        if title:
            titles.append(title)
        else:
            titles.append(f"Diagram {i}")
    
    return titles

async def main():
    parser = argparse.ArgumentParser(description='将Markdown中的Mermaid图表转换为图片')
    parser.add_argument('--input', '-i', required=True, help='输入的Markdown文件路径')
    parser.add_argument('--output', '-o', required=True, help='输出图片的目录')
    
    args = parser.parse_args()
    
    markdown_path = args.input
    output_dir = args.output
    
    if not os.path.isfile(markdown_path):
        print(f"错误: 文件 {markdown_path} 不存在")
        sys.exit(1)
    
    # 提取图表标题
    diagram_titles = extract_diagram_titles(markdown_path)
    
    # 渲染图片
    image_paths = await render_mermaid_to_images(markdown_path, output_dir)
    
    # 打印结果摘要
    print("\n转换完成:")
    print(f"- 输入文件: {markdown_path}")
    print(f"- 输出目录: {output_dir}")
    print(f"- 生成图片数量: {len(image_paths)}")
    
    for i, path in enumerate(image_paths):
        title = diagram_titles[i] if i < len(diagram_titles) else f"Diagram {i+1}"
        print(f"  {i+1}. {title}: {path}")

if __name__ == "__main__":
    asyncio.run(main()) 