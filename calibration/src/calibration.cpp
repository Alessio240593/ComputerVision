/****************************************************************************
 * Copyright (C) 2022 by Alessio Zattoni                                    *
 *                                                                          *
 * This file is part of calibration.                                        *
 *                                                                          *
 *   calibration is free software: you can redistribute it and/or           *
 *   modify it under the terms of the GNU Lesser General Public License as  *
 *   published by the Free Software Foundation, either version 3 of the     * 
 *   License, or (at your option) any later version.                        * 
 *                                                                          *
 *   CrossCorrelation is distributed in the hope that it will be            *
 *   useful, but WITHOUT ANY WARRANTY; without even the implied warranty of *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *   GNU Lesser General Public License for more details.                    *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with Box.  If not, see <http://www.gnu.org/licenses/>.   *
 ****************************************************************************/



/**
 * @file calibration.hpp
 * @author Alessio Zattoni
 * @date 
 * @brief Questo file contiene l'implementazione di funzioni per la calibrazione della camera
 *
 * ...
 */



#include "calibration.hpp"


void createStereoCameraSetup(cv::Mat mtx,
                             cv::Mat dist,
                             cv::Mat R,
                             cv::Mat T)
{
  std::string path = "../calibration_setup/intrinsicExtrinsicParameters.yml";

  cv::FileStorage fs = cv::FileStorage(path, cv::FileStorage::WRITE);

  if (! fs.isOpened()) { 
    std::cerr << "Error:File did not open, at line " << __LINE__ - 3 << " in file " << __FILE__ << std::endl;
    exit(1); 
  }
  
  //camera intrinsic and Extrinsic parameters
  fs << "CAMERA_MATRIX_LEFT" << mtx;
  fs << "DISTCOEFFS_RIGHT" << dist;
  fs << "ROTATION_MATRIX" << R;
  fs << "TRASLATION_VECTOR" << T;

  //Close file streams
  fs.release();

  std::cout << "Write Done in file → " << path.substr(path.find_last_of("/") + 1) <<  std::endl;
}


void calibrateSingleCamera(std::string images_path,
                           int         checkerboard_rows, 
                           int         checkerboard_cols)
{
  std::cout << "Running stereo calibration ..." << std::endl;

  // Defining the dimensions of checkerboard
  int CHECKERBOARD[2]{checkerboard_rows, checkerboard_cols}; 

  // Creating vector to store vectors of 3D points for each checkerboard image
  std::vector<std::vector<cv::Point3f>> objpoints;

  // Creating vector to store vectors of 2D points for each checkerboard image
  std::vector<std::vector<cv::Point2f>> imgpoints;

  // Defining the world coordinates for 3D points
  std::vector<cv::Point3f> objp;
  for(int i{0}; i<CHECKERBOARD[1]; i++) {
    for(int j{0}; j<CHECKERBOARD[0]; j++)
      objp.push_back(cv::Point3f(j,i,0));
  }

  // Extracting path of individual image stored in a given directory
  std::vector<cv::String> images;
  // Path of the folder containing checkerboard images
  std::string path = images_path;

  cv::glob(path, images);

  cv::Mat frame, gray;
  // vector to store the pixel coordinates of detected checker board corners 
  std::vector<cv::Point2f> corner_pts;
  bool success;

  // Looping over all the images in the directory
  for(int i{0}; i<images.size(); i++) {
    frame = cv::imread(images[i]);
    cv::cvtColor(frame,gray,cv::COLOR_BGR2GRAY);

    // Finding checker board corners
    // If desired number of corners are found in the image then success = true  
    success = cv::findChessboardCorners(
      gray,
      cv::Size(CHECKERBOARD[0],CHECKERBOARD[1]),
      corner_pts, cv::CALIB_CB_ADAPTIVE_THRESH | cv::CALIB_CB_FAST_CHECK | cv::CALIB_CB_NORMALIZE_IMAGE);

    if(success) {
      cv::TermCriteria criteria(cv::TermCriteria::EPS | cv::TermCriteria::MAX_ITER, 30, 0.001);

      // refining pixel coordinates for given 2d points.
      cv::cornerSubPix(gray,corner_pts,cv::Size(11,11), cv::Size(-1,-1),criteria);

      // Displaying the detected corner points on the checker board
      cv::drawChessboardCorners(frame, cv::Size(CHECKERBOARD[0],CHECKERBOARD[1]), corner_pts,success);

      objpoints.push_back(objp);
      imgpoints.push_back(corner_pts);
    }

    cv::imshow("Image",frame);
    cv::moveWindow("Image", 0, 0);

    while (cv::waitKey(1) != 13);
  }

  cv::destroyAllWindows();

  cv::Mat mtx,dist,R,T;
  cv::Mat new_mtx;

  // Calibrating left camera
  double error = cv::calibrateCamera(objpoints,
                      imgpoints,
                      gray.size(),
                      mtx,
                      dist,
                      R,
                      T);

  std::cout << "Reprojection error camera= " << error << "\n";

  new_mtx = cv::getOptimalNewCameraMatrix(mtx,
                                dist,
                                gray.size(),
                                1,
                                gray.size(),
                                0);

  int flag = 0;
  flag |= cv::CALIB_FIX_ASPECT_RATIO +
          cv::CALIB_USE_INTRINSIC_GUESS +
          cv::CALIB_ZERO_TANGENT_DIST +
          cv::CALIB_SAME_FOCAL_LENGTH,
          cv::TermCriteria(cv::TermCriteria::COUNT + cv::TermCriteria::EPS, 100, 1e-5);
  
  cv::Mat rect, proj_mat, Q;
               
  createStereoCameraSetup(new_mtx, dist, R, T);   

  cv::Mat nice_img;

  std::cout << "Running images distortion retification..." << std::endl;

  for (int file{0}; file < images.size(); file++) {
    frame = cv::imread(images[file]);

    cv::imshow("Image before rectification",frame);
    cv::moveWindow("Image before rectification", 0, 0);

    cv::waitKey(0);

    cv::undistort(frame, nice_img, mtx, dist, new_mtx);

    cv::imshow("Image after rectification",frame);
    cv::moveWindow("Image after rectification", 900, 0);

    cv::waitKey(0);

    cv::destroyAllWindows();
  }

  std::cout << "End of calibratin phase, setup paramaters are in calibration_setup directory." << std::endl;
}