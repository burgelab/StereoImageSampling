========
Overview
========
This repository provides a MATLAB implementation of a procedure to precisely sample 
binocular corresponding points from stereo images with co-registered ground-truth 
distance measurements.

This repository also includes example stereo-images with co-registered distance 
measurements (see below)

Code is provided for the binocular corresponding-point sampling and interpolation 
procedure described in the paper:
	Arvind Iyer & Johannes Burge (submitted)
	"The Effect of Depth Variation on Disparity Tasks in Natural Scenes"
	Journal of Vision

==================  
= Using the code =
==================  

Step 1: Save the code repository and add it to your Matlab path.

Step 2: Open the script LRSIstereoImageSamplingDemo.m and evaluate labeled sections. 
	LRSIstereoImageSamplingDemo.m is a tutorial script with examples of all principal 	functions.

=======================  
= Principal functions = 
=======================

	1) LRSIcorrespondingPoint.m: 	          Finds corresponding points
	2) LRSIcorrespondingPointVet.m: 	  Screens for bad points 
	3) LRSIcropLocalPatch.m: 		  Crops stereo-image and range patches
	4) vergenceFromRangeXYZ.m: 	          Computes groundtruth vergence demand
	5) LRSIcorrespondingPointAddDisparity.m:  Adds fixation disparity 
	6) plotLRSIimageANDdisparity.m:		  Plots cropped patches

==================== 
= Helper Functions =  
==================== 
Functions from the open-source "geom3D" library authored by David Legland are 
utilized by the functions in this repository. The library can be accessed at:

	https://www.mathworks.com/matlabcentral/fileexchange/24484-geom3d  

=========================  
= Function Descriptions =  
=========================  
All Matlab functions in this repository contain detailed descriptions of the input 
and output parameters.

======== 
= Data =  
========
This code depends on Luminance Range Stereo-Images (LRSI)- luminance images with 
co-registered distance measurements- from the database described in:	 
	Johannes Burge, Brian McCann & Wilson Geisler (2016)
        "Estimating 3D Tilt from Local Image Cues in Natural Scenes"
        Journal of vision 16.13 (2016): 2-2. 

If you use this data for your research project, please cite the above paper. 
  
The full source dataset of the example images can be accessed at 
http://natural-scenes.cps.utexas.edu/db.shtml under the section heading   
"Stereo Image and Range Data Collection”. 
    

1)	LRSItestImg*.mat: Example Luminance Range Stereo Images(2)
		+ Limg: left-eye  (LE) luminance image
		+ Rimg: right-eye (RE) luminance image		
		+ Lrng: LE range (m) of each imaged surface points in scene 
		+ Rrng: RE range (m) of each imaged surface points in scene 
		+ Lxyz: LE cartesian coordinates of surface points in scene
		+ Rxyz: RE cartesian coordinates of surface points in scene
 	(All distances are in meters)


2)      LRSIprojPlaneAnchorEye.m Function that provides…
		+ IPDm : Interpupillary distance 
		+ LppXm: projection plane x-coords in LE coordinate system
		+ LppYm: projection plane y-coords in LE coordinate system
		+ RppXm: projection plane x-coords in RE coordinate system
		+ RppYm: projection plane y-coords in RE coordinate system
		+ CppXm: projection plane x-coords in CE coordinate system
		+ CppYm: projection plane y-coords in CE coordinate system
		+ CppZm: projection plane z-coords
		(All distances are in meters) 


