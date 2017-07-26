
# MobileNet on iOS

This application processes video frames from the camera with the pre-trained MobileNet
using Vision/CoreML framework in real time.

I copied the model file from [hollance/MobileNet-CoreML](https://github.com/hollance/MobileNet-CoreML), which is originated from [shicai/MobileNet-Caffe](https://github.com/shicai/MobileNet-Caffe).

MobileNet-Caffer is a Caffe implementation of Google's [MobileNets](https://arxiv.org/abs/1704.04861v1).

## Required Environment

- Xcode 9.0 beta 4
- iOS device running iOS11 beta 1 or later

## Notes

- The drop rate is about 50% on my iPhone 7, which means we are getting about 15fps.
- If I perform the vision request from the main thread, it won't update the UILabel (iOS bug?).
This is why I am using a background thread.
- VSCaptureSession is a helper class for video capture sessions,
which is copied from [VideoShader for Metal](https://github.com/snakajima/vs-metal).
- I am specifing CGImagePropertyOrientation.up as the orientation to VNImageRequestHandler,
but I am not sure if this is the right parameter (Apple's documentation is quite ambiguous).

