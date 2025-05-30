#!/usr/bin/env python3
import os
import shutil
import datetime
import sys
from pathlib import Path

# 设置根目录
ROOT_DIR = Path('/Users/marvi/CursorWorks/nativekeyai/wechat')
BACKUP_DIR = ROOT_DIR / 'assets_backup'

# 未使用资源列表（从asset_scanner.py的输出提取）
UNUSED_ASSETS = [
    'assets/icons/README.md',
    'assets/icons/ai-cover.png',
    'assets/icons/audio-active.png',
    'assets/icons/audio-cover.png',
    'assets/icons/default-avatar.png',
    'assets/icons/game-cover.png',
    'assets/icons/home-active.png',
    'assets/icons/home.png',
    'assets/icons/microphone.png',
    'assets/icons/profile-active.png',
    'assets/icons/profile.png',
    'assets/icons/svgs/audio-active.svg',
    'assets/icons/svgs/audio.svg',
    'assets/icons/svgs/home-active.svg',
    'assets/icons/svgs/home.svg',
    'assets/icons/svgs/profile-active.svg',
    'assets/icons/svgs/profile.svg',
    'assets/icons/svgs/video-active.svg',
    'assets/icons/svgs/video.svg',
    'assets/icons/video-active.png',
    'assets/icons/video-cover.png',
    'assets/images/README.md',
    'assets/images/ai-image-bg.png',
    'assets/images/ai-voice-bg.png',
    'assets/images/ai-word-bg.png',
    'assets/images/audio-cover-1.png',
    'assets/images/game/README.md',
    'assets/images/svgs/ai-cover.svg',
    'assets/images/svgs/ai-image-bg.svg',
    'assets/images/svgs/ai-voice-bg.svg',
    'assets/images/svgs/ai-word-bg.svg',
    'assets/images/svgs/app-logo.svg',
    'assets/images/svgs/audio-cover.svg',
    'assets/images/svgs/default-avatar.svg',
    'assets/images/svgs/game-cover.svg',
    'assets/images/svgs/video-cover.svg'
]

def create_backup_dir():
    """创建备份目录，使用日期时间作为子目录名"""
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = BACKUP_DIR / timestamp
    backup_path.mkdir(parents=True, exist_ok=True)
    return backup_path

def backup_and_remove_assets(backup_path, log_file_path):
    """备份并移除未使用的资源文件"""
    success_count = 0
    error_count = 0
    
    with open(log_file_path, 'w') as log_file:
        log_file.write(f"清理日志 - {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_file.write("=" * 60 + "\n\n")
        
        for asset in UNUSED_ASSETS:
            src_path = ROOT_DIR / asset
            if not src_path.exists():
                log_file.write(f"跳过 (文件不存在): {asset}\n")
                error_count += 1
                continue
            
            # 创建目标目录结构
            dest_dir = backup_path / asset
            dest_dir.parent.mkdir(parents=True, exist_ok=True)
            
            try:
                # 移动文件到备份目录
                shutil.move(src_path, dest_dir.parent)
                log_file.write(f"已移动: {asset}\n")
                success_count += 1
            except Exception as e:
                log_file.write(f"错误 (移动失败): {asset} - {str(e)}\n")
                error_count += 1
        
        # 写入汇总信息
        log_file.write("\n" + "=" * 60 + "\n")
        log_file.write(f"总计: {len(UNUSED_ASSETS)} 个文件\n")
        log_file.write(f"成功: {success_count} 个文件\n")
        log_file.write(f"失败: {error_count} 个文件\n")
        log_file.write("备份目录: " + str(backup_path) + "\n")
    
    return success_count, error_count

def main():
    print("开始清理未使用的资源文件...")
    
    # 创建备份目录
    backup_path = create_backup_dir()
    log_file_path = backup_path / "cleanup_log.txt"
    
    print(f"备份目录: {backup_path}")
    print(f"日志文件: {log_file_path}")
    
    # 备份并清理文件
    success_count, error_count = backup_and_remove_assets(backup_path, log_file_path)
    
    print("\n清理完成!")
    print(f"总计: {len(UNUSED_ASSETS)} 个文件")
    print(f"成功: {success_count} 个文件")
    print(f"失败: {error_count} 个文件")
    print(f"查看日志获取详细信息: {log_file_path}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n操作已取消")
        sys.exit(1)
    except Exception as e:
        print(f"\n执行过程中出现错误: {str(e)}")
        sys.exit(1) 