import { readdirSync, readFileSync, writeFileSync } from "fs";
import { decompressFrames, parseGIF } from "gifuct-js";
import GIFEncoder from "gif-encoder";

const PALETTE = [
  0, 0, 0, 255,
  29, 43, 83, 255,
  41, 173, 255, 255,
  95, 87, 79, 255,
  255, 0, 77, 255,
  255, 236, 39, 255,
  255, 241, 232, 255,
  0, 255, 0, 255,
];

const INPUT_DIR = ".";
// const PALETTE_FILE = "./pico8-palette.png";
const OUTPUT = "./mosaic.gif";

async function main() {
  const gifs = readdirSync(INPUT_DIR)
    .filter(f => f.endsWith("_0_128.gif"))
    .map(f => {
      const parsed = parseGIF(readFileSync(`${INPUT_DIR}/${f}`).buffer);
      const frames = decompressFrames(parsed, true);
      return {
        name: f,
        frames,
      };
    });

  const maxFrames = Math.max(...gifs.map(g => g.frames.length));
  const w = 128, h = 128;
  const gifCount = gifs.length;

  const cols = Math.ceil(Math.sqrt(gifCount));
  const rows = Math.ceil(gifCount / cols);
  const mosaicWidth = cols * w;
  const mosaicHeight = rows * h;

  const encoder = new GIFEncoder(
    mosaicWidth,
    mosaicHeight,
    { highWaterMark: mosaicWidth * mosaicHeight * 1024 }
  );
  encoder.writeHeader();
  // encoder.setDelay(frameDelay);
  encoder.setRepeat(0);
  // encoder.setImagePalette(PALETTE);

  for (let f = 0; f < maxFrames; f++) {
    const composite = Buffer.alloc(mosaicWidth * mosaicHeight);

    for (let i = 0; i < gifCount; i++) {
      const gif = gifs[i];
      if (!gif) {
        throw new Error(`GIF ${i} not found`);
      }
      const frames = gif.frames;
      const loopedFrame = frames[f % frames.length];
      if (!loopedFrame) {
        throw new Error(`loopedFrame ${f % frames.length} not found`);
      }
      const x = (i % cols) * w;
      const y = Math.floor(i / cols) * h;

      const src = loopedFrame.pixels;
      for (let py = 0; py < h; py++) {
        for (let px = 0; px < w; px++) {
          const si = py * w + px;
          const di = (y + py) * mosaicWidth + (x + px);
          if (typeof src[si] === "number") {
            composite[di] = src[si];
          }
        }
      }
    }

    encoder.addFrame(composite, { indexedPixels: true, palette: PALETTE });
  }

  encoder.finish();
  writeFileSync(OUTPUT, encoder.read());
}

main();
