#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
简化版：只替换src属性中的images/
"""

import os
import re
import sys
from pathlib import Path

def replace_src_images():
    if len(sys.argv) > 1:
        root_dir = sys.argv[1]
    else:
        root_dir = "."
    
    root_path = Path(root_dir).resolve()
    pattern = r'(src=["\'])(?<!\/)images/'
    
    print(f"处理目录: {root_path}")
    print(f"替换模式: {pattern}")
    print()
    
    for file_path in root_path.rglob('*'):
        if file_path.is_file() and file_path.suffix.lower() in {'.html', '.htm', '.php', '.vue', '.jsx', '.tsx'}:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = re.sub(pattern, r'\1/images/', content)
                
                if new_content != content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    
                    # 统计替换次数
                    replacements = len(re.findall(pattern, content))
                    print(f"✓ {file_path.relative_to(root_path)}: 替换了 {replacements} 处")
                    
            except UnicodeDecodeError:
                try:
                    with open(file_path, 'r', encoding='gbk') as f:
                        content = f.read()
                    
                    new_content = re.sub(pattern, r'\1/images/', content)
                    
                    if new_content != content:
                        with open(file_path, 'w', encoding='gbk') as f:
                            f.write(new_content)
                        
                        replacements = len(re.findall(pattern, content))
                        print(f"✓ {file_path.relative_to(root_path)}: 替换了 {replacements} 处")
                        
                except:
                    print(f"✗ {file_path.relative_to(root_path)}: 编码错误")
            except Exception as e:
                print(f"✗ {file_path.relative_to(root_path)}: {e}")
    
    print("\n处理完成！")

if __name__ == "__main__":
    replace_src_images()