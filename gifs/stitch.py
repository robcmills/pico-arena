#!/usr/bin/env python3
"""
Stitch multiple GIF files into a single mosaic GIF.
Handles GIFs with different frame counts by looping shorter ones.
"""

import os
import math
from pathlib import Path
from PIL import Image
import argparse


def get_gif_info(gif_path):
    """Extract frame count and duration from a GIF."""
    with Image.open(gif_path) as img:
        frame_count = 0
        durations = []
        try:
            while True:
                durations.append(img.info.get('duration', 100))
                frame_count += 1
                img.seek(frame_count)
        except EOFError:
            pass
        return frame_count, durations


def load_gif_frames(gif_path):
    """Load all frames from a GIF as a list of images."""
    frames = []
    with Image.open(gif_path) as img:
        try:
            while True:
                # Convert to RGBA to handle transparency properly
                frame = img.convert('RGBA')
                frames.append(frame.copy())
                img.seek(len(frames))
        except EOFError:
            pass
    return frames


def load_palette(palette_path):
    """Load palette from an image file."""
    with Image.open(palette_path) as img:
        # Convert to P mode if not already
        if img.mode != 'P':
            img = img.convert('P', palette=Image.ADAPTIVE, colors=256)
        return img.getpalette()


def create_mosaic_gif(input_dir, output_path, palette_path, columns=None):
    """Create a mosaic GIF from all GIFs in input directory."""
    
    # Find all GIF files
    gif_files = sorted(Path(input_dir).glob('arena_*_128.gif'))
    if not gif_files:
        print("No GIF files found in directory!")
        return
    
    print(f"Found {len(gif_files)} GIF files")
    
    # Analyze all GIFs to find max frame count and common duration
    max_frames = 0
    common_duration = None
    gif_data = []
    
    for gif_path in gif_files:
        frame_count, durations = get_gif_info(gif_path)
        max_frames = max(max_frames, frame_count)
        if common_duration is None and durations:
            common_duration = durations[0]
        gif_data.append({
            'path': gif_path,
            'frame_count': frame_count,
        })
        print(f"  {gif_path.name}: {frame_count} frames")
    
    print(f"\nMax frames: {max_frames}")
    print(f"Frame duration: {common_duration}ms")
    
    # Calculate grid dimensions
    num_gifs = len(gif_files)
    if columns is None:
        columns = math.ceil(math.sqrt(num_gifs))
    rows = math.ceil(num_gifs / columns)
    
    print(f"Grid: {columns}x{rows}")
    
    # Tile size (assuming all are 128x128)
    tile_width, tile_height = 128, 128
    mosaic_width = columns * tile_width
    mosaic_height = rows * tile_height
    
    print(f"Output size: {mosaic_width}x{mosaic_height}")
    
    # Load palette
    palette = load_palette(palette_path)
    
    # Load all GIF frames into memory
    print("\nLoading all GIF frames...")
    all_gif_frames = []
    for i, data in enumerate(gif_data):
        frames = load_gif_frames(data['path'])
        all_gif_frames.append(frames)
        if (i + 1) % 50 == 0:
            print(f"  Loaded {i + 1}/{num_gifs}")
    
    print(f"\nGenerating {max_frames} mosaic frames...")
    
    # Generate mosaic frames
    mosaic_frames = []
    for frame_idx in range(max_frames):
        # Create mosaic frame
        mosaic = Image.new('RGBA', (mosaic_width, mosaic_height), (0, 0, 0, 255))
        
        for gif_idx, frames in enumerate(all_gif_frames):
            # Calculate position in grid
            col = gif_idx % columns
            row = gif_idx // columns
            x = col * tile_width
            y = row * tile_height
            
            # Get frame (loop if necessary)
            source_frame = frames[frame_idx % len(frames)]
            mosaic.paste(source_frame, (x, y))
        
        # Convert to palette mode
        mosaic_p = mosaic.convert('RGB').quantize(palette=Image.open(palette_path).convert('P'))
        mosaic_frames.append(mosaic_p)
        
        if (frame_idx + 1) % 10 == 0:
            print(f"  Generated frame {frame_idx + 1}/{max_frames}")
    
    # Save mosaic GIF
    print(f"\nSaving to {output_path}...")
    mosaic_frames[0].save(
        output_path,
        save_all=True,
        append_images=mosaic_frames[1:],
        duration=common_duration,
        loop=0,
        optimize=False
    )
    
    print("Done!")


def main():
    parser = argparse.ArgumentParser(description='Create mosaic GIF from multiple GIFs')
    parser.add_argument('input_dir', help='Directory containing input GIF files')
    parser.add_argument('output', help='Output GIF path')
    parser.add_argument('--palette', default='pico8-palette.png', 
                        help='Palette image file (default: pico8-palette.png)')
    parser.add_argument('--columns', type=int, default=None,
                        help='Number of columns (default: auto)')
    
    args = parser.parse_args()
    
    create_mosaic_gif(args.input_dir, args.output, args.palette, args.columns)


if __name__ == '__main__':
    main()
