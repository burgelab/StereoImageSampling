============
= Overview =
============
This repository provides a MATLAB implementation of a procedure to precisely sample 
binocular corresponding points from stereo images with co-registered ground-truth 
distance measurements.

Code is provided for the binocular corresponding-point sampling and interpolation 
procedure described in the paper:
	Arvind Iyer & Johannes Burge (2018)
	"Depth variation and stereo processing tasks in natural scenes".
	Journal of Vision. 18(6):4, 1-22.


This repository also includes two example stereo-images with co-registered distance 
measurements (see below)

==================  
= Using the code =
==================  

Step 1: Save the code to a folder and add it with subfolders to your Matlab path

Step 2: Open the tutorial script LRSIstereoImageSamplingDemo.m and evaluate each section. 
	
=======================  
= Principal functions = 
=======================

	1) LRSIcorrespondingPoint.m: 	          Finds corresponding points
	2) LRSIcorrespondingPointVet.m: 	  Screens for bad points 
	3) LRSIcropStereoPatch.m: 		  Interpolates and crops stereo-patches
	4) LRSIcorrespondingPointAddDisparity.m:  Adds fixation disparity
	5) vergenceFromRangeXYZ.m: 	          Vergence demand from range data
	6) vergenceFromCorrespondingPoints.m:     Vergence demand from corresponding points
	
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
co-registered distance measurements- from the dataset described in:	 
	Johannes Burge, Brian McCann, & Wilson Geisler (2016)
        "Estimating 3D Tilt from Local Image Cues in Natural Scenes"
        Journal of Vision, 16(2), doi:10.1167/16.13.2

If you use this data for your research project, please cite the above paper. 
  
The full dataset of all 99 luminance-range-stereo-images can be downloaded at 
http://natural-scenes.cps.utexas.edu/db.shtml under the section heading   
"Stereo Image and Range Data Collection”. 

1)	LRSItestImg*.mat: Example Luminance Range Stereo Images (2)
		+ Limg: left-eye  (LE) luminance image
		+ Rimg: right-eye (RE) luminance image		
		+ Lrng: LE range (m) of each imaged surface points in scene 
		+ Rrng: RE range (m) of each imaged surface points in scene 
		+ Lxyz: LE cartesian coordinates of surface points in scene
		+ Rxyz: RE cartesian coordinates of surface points in scene
 		(All distances are in meters)

2)      LRSIprojPlaneAnchorEye.m Function that provides…
		+ LppXm: projection plane x-coords in LE coordinate system
		+ LppYm: projection plane y-coords in LE coordinate system
		+ RppXm: projection plane x-coords in RE coordinate system
		+ RppYm: projection plane y-coords in RE coordinate system
		+ CppXm: projection plane x-coords in CE coordinate system
		+ CppYm: projection plane y-coords in CE coordinate system
		+ CppZm: projection plane z-coords
		+ IPDm : Inter-camera distance during data acquisition
		(All distances are in meters) 


