# PlantVision

## Introduction
Joint Multi-Leaf Segmentation, Alignment, and Tracking from Fluorescence Plant Videos

More details about the project can be found at: http://cvlab.cse.msu.edu/project-plant-vision.html

## Usage
Main entrance file: `MultiLeafTracking.m`.

You need to prepare your data into the required format. Check `dara_readInputTextFile.m` to see how the txt file is parsed. 
Specifically, the `inputPath` is a txt file that stores the image paths and plant location informations. It looks like this:
```bash
2
1 1 100 200 80 80 
1 2 100 400 90 90
3
image_frame_1.jpg
image_frame_2.jpg
image_frame_3.jpg
```
The first row is the total number of N plants in the image/video frames. 
Then the next N rows are the plant IDs and locations. 
Each row is in the format: `plant_row, plant_column, location_row, location_column, height, width`.
The next row is the total number of M frames in a video.
We assume the camera is fixed so the locations apply to all frames. 
The next M rows are the paths to the image frames in order. 
After you have prepared your data into this format, you can use `MultiLeafTracking.m` to process your data. 
Please pay attention to the leaf sizes in your data and change the `smallSize` and `largeSize` accordingly. 
You may also need to generate your own leaf templates if needed. 

## Citation
If you found this code useful, please consider to cite:
```
@article{yin2018joint,
  title={Joint Multi-Leaf Segmentation, Alignment, and Tracking for Fluorescence Plant Videos},
  author={Yin, Xi and Liu, Xiaoming and Chen, Jin and Kramer, David M},
  journal={IEEE Transactions on Pattern Analysis and Machine Intelligence},
  volume={40},
  number={6},
  pages={1411--1423},
  year={2018},
  publisher={IEEE}
}
```


