# Harvesting Multiple Views for Marker-less 3D Human Pose Annotations
## Georgios Pavlakos, Xiaowei Zhou, Konstantinos G. Derpanis, Kostas Daniilidis

This is the demo code for the paper **Harvesting Multiple Views for Marker-less 3D Human Pose Annotations**. Please follow the links to read the [paper](https://arxiv.org/abs/1704.04793) and visit the corresponding [project page](https://www.seas.upenn.edu/~pavlakos/projects/harvesting).

We provide code to test the multi-view optimization part of our approach on [Human3.6M](http://vision.imar.ro/human3.6m/description.php). Please follow the instructions below to setup and use our code. The typical procedure is 1) apply the ConvNet model using a torch script through command line and then 2) run a MATLAB script for the multiview optimization.

### 0) Compiling the multiview optimization code

We provide a precompiled version of the code for the multiview optimization for Linux and Windows machines. If you want to compile it yourself, you can use something like the next line:

```
cd code
mex CFLAGS='$CFLAGS -fopenmp' LDFLAGS='$LDFLAGS -fopenmp' COPTIMFLAGS='$COPTIMFLAGS -fopenmp -O2' LDOPTIMFLAGS='$LDOPTIMFLAGS -fopenmp -O2' DEFINES='$DEFINES -fopenmp' -v msgpass_sumprod.c
```

### 1) Downloading model and data

We use the [Stacked Hourglass](http://www-personal.umich.edu/~alnewell/pose/) model pretrained on MPII as the generic ConvNet for initial 2D pose predictions. You can download the model, along with a sample of Human3.6M data using the following bash script:

```bash init.sh```

In case you want to reproduce our results on the whole Human3.6M dataset, you need to download all the relevant images. We provide a script so that you can download the images corresponding to the most typical evaluation protocol. These images are extracted from the videos of the [original dataset](http://vision.imar.ro/human3.6m/description.php). Please run the script below to get the required images  (**be careful, since the zip files size is over 26GB**)

```bash data.sh```

### 2) Evaluation on Human3.6M (demo)

We have provided a sample of Human3.6M images. You can apply our model on this sample by running the command:

```
cd pose-hg-demo
th main.lua demo
```

Then, for the multi-view optimization, you can run the following function on MATLAB, which will do the evaluation for the whole sequence:

```
main_multiview('demo')
```

### 3) Evaluation on Human3.6M (full)

If you have downloaded the full set of Human3.6M images (step 1), you can run our code on the whole dataset. Again, first you need to apply the generic ConvNet on the single-view images:

```
cd pose-hg-demo
th main.lua valid
```

And then, for the multi-view optimization, you need to run the following function on MATLAB:

```
main_multiview('valid')
```

The results are for all the sequences of subjects 9 and 11. For the training subjects (1,5,6,7 and 8), you can replace 'valid' with 'train' in the two commands above.

### Citing

If you find this code useful for your research, please consider citing the following paper:

	@Inproceedings{pavlakos17harvesting,
	  Title          = {Harvesting Multiple Views for Marker-less 3{D} Human Pose Annotations},
	  Author         = {Pavlakos, Georgios and Zhou, Xiaowei and Derpanis, Konstantinos G and Daniilidis, Kostas},
	  Booktitle      = {Computer Vision and Pattern Recognition (CVPR)},
	  Year           = {2017}
	}

### Acknowledgements

This code includes the [released code](https://github.com/anewell/pose-hg-demo) and [model](http://www-personal.umich.edu/~alnewell/pose/umich-stacked-hourglass.zip) for the Stacked Hourglass networks by Alejandro Newell. If you use this code/model, please consider citing the [respective paper](http://arxiv.org/abs/1603.06937).
