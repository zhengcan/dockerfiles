#[allow(unused)]

extern crate ffmpeg_next as ffmpeg;

use std::path::*;

use ffmpeg::format::{input, Pixel};
use ffmpeg::media::Type;
use ffmpeg::software::scaling::{context::Context, flag::Flags};
use ffmpeg::util::frame::video::Video;
use magick_rust::{MagickWand, magick_wand_genesis};
use opencv::imgcodecs::*;

fn main() {
  // FFMpeg
  ffmpeg::init().unwrap();
  let path = PathBuf::from("flower.png");
  if let Ok(mut ictx) = input(&path) {
    let input = ictx
        .streams()
        .best(Type::Video)
        .ok_or(ffmpeg::Error::StreamNotFound).unwrap();
    let video_stream_index = input.index();

    let context_decoder = ffmpeg::codec::context::Context::from_parameters(input.parameters()).unwrap();
    let mut decoder = context_decoder.decoder().video().unwrap();

    let mut scaler = Context::get(
      decoder.format(),
      decoder.width(),
      decoder.height(),
      Pixel::RGB24,
      decoder.width(),
      decoder.height(),
      Flags::BILINEAR,
    ).unwrap();

    let mut frame_index = 0;

    let mut receive_and_process_decoded_frames =
      |decoder: &mut ffmpeg::decoder::Video| -> Result<(), ffmpeg::Error> {
        let mut decoded = Video::empty();
        while decoder.receive_frame(&mut decoded).is_ok() {
          let mut rgb_frame = Video::empty();
          scaler.run(&decoded, &mut rgb_frame).unwrap();
          frame_index += 1;
        }
        Ok(())
      };

    for (stream, packet) in ictx.packets() {
      if stream.index() == video_stream_index {
        decoder.send_packet(&packet).unwrap();
        receive_and_process_decoded_frames(&mut decoder).unwrap();
      }
    }
    decoder.send_eof().unwrap();
    receive_and_process_decoded_frames(&mut decoder).unwrap();
  }

  // OpenCV
  let mat = imread("flower.png", IMREAD_COLOR).unwrap();
  let params = opencv::types::VectorOfi32::new();
  imwrite("target/opencv.jpeg", &mat, &params).unwrap();

  // ImageMagick
  magick_wand_genesis();
  let wand = MagickWand::new();
  wand.read_image("flower.png").unwrap();
  wand.fit(240, 240);
  wand.write_image("target/imagemagick.jpeg").unwrap();

  println!("Done");
}
