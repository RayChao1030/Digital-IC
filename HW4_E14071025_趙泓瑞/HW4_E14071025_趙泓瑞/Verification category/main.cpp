#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <fstream> 
#include <cstdlib>
#include <iomanip>
#include <cstdio>

int down_width = 32;
int down_height = 31;
int downing_height;
int downing_width ;
//int x[31][32] ;
//int y[16][32] ;
int a =0;
int b =0;
int c =0;

int* array2;


using namespace std;
using namespace cv;

int main(int argc, char** argv)
{
	
		Mat image = imread("./image.jpg", CV_LOAD_IMAGE_GRAYSCALE);
		Mat resized_image;
		Mat resized_cutingcol_image;

		if (image.data == nullptr)
		{
			cerr << "No Image" << endl;

			system("pause");
			return 0;
		}
		else {
			//cout << image << endl;
			//imshow("Original Image", image);
			//waitKey();
			resize(image, resized_image, Size(down_width, down_height), INTER_LINEAR);
			resize(resized_image, resized_cutingcol_image, Size(down_width, 16), INTER_LINEAR);
			//imshow("Resized Down by defining height and width", resized_image);
			//waitKey();
			
			for (downing_height = 0; downing_height <= (down_height / 2); downing_height++) {
				for( downing_width = 0; downing_width < down_width; downing_width++) {
				resized_cutingcol_image.at<uchar>(downing_height, downing_width) = resized_image.at<uchar>(downing_height*2, downing_width);
				}
			}
			ofstream outfile1("img.dat" , ofstream::app);
			if (outfile1.is_open())
			{
				for (downing_height = 0; downing_height <= (down_height / 2); downing_height++) {
					for (downing_width = 0; downing_width < down_width; downing_width++) {
						outfile1 << hex << (int)resized_cutingcol_image.at<uchar>(downing_height, downing_width) << endl;
					}
				}
				outfile1.close();
			}
			else
			{
				cout << "can not open the resized_cutingcol_image.dat \n" << endl;
				return -1;
			}

			for (downing_height = 0; downing_height < (down_height / 2); downing_height++) {
				for (downing_width = 0; downing_width < down_width; downing_width++) {
					if((downing_width==0)|| (downing_width == 31))
						resized_image.at<uchar>(downing_height * 2 + 1, downing_width) = (resized_cutingcol_image.at<uchar>(downing_height, downing_width) + resized_cutingcol_image.at<uchar>(downing_height+1, downing_width))/2;
					else {
						a = abs(resized_cutingcol_image.at<uchar>(downing_height, downing_width - 1) - resized_cutingcol_image.at<uchar>(downing_height + 1, downing_width + 1));
						b = abs(resized_cutingcol_image.at<uchar>(downing_height, downing_width) - resized_cutingcol_image.at<uchar>(downing_height + 1, downing_width ));
						c = abs(resized_cutingcol_image.at<uchar>(downing_height, downing_width + 1) - resized_cutingcol_image.at<uchar>(downing_height + 1, downing_width - 1));
						if((b <= a)&& (b <= c))
							resized_image.at<uchar>(downing_height * 2 + 1, downing_width) = (resized_cutingcol_image.at<uchar>(downing_height, downing_width) + resized_cutingcol_image.at<uchar>(downing_height + 1, downing_width)) / 2;
						else if ((a <= b) && (a <= c))
							resized_image.at<uchar>(downing_height * 2 + 1, downing_width) = (resized_cutingcol_image.at<uchar>(downing_height, downing_width-1) + resized_cutingcol_image.at<uchar>(downing_height + 1, downing_width+1)) / 2;
						else if ((c <= b) && (c <= a))
							resized_image.at<uchar>(downing_height * 2 + 1, downing_width) = (resized_cutingcol_image.at<uchar>(downing_height, downing_width+1) + resized_cutingcol_image.at<uchar>(downing_height + 1, downing_width-1)) / 2;
					}

				}
			}

			ofstream outfile("golden.dat", ofstream::app);
			if (outfile.is_open())
			{
				for (downing_height = 0; downing_height < down_height; downing_height++) {
					for (downing_width = 0; downing_width < down_width; downing_width++) {
						outfile << hex << (int)resized_image.at<uchar>(downing_height, downing_width) << endl;
					}
				}
				outfile.close();
				cout << "finish \n" << endl;
			}
			else
			{
				cout << "can not open the resized_image.dat \n" << endl;
				return -1;
			}
			/*FILE * out = fopen("golden.dat", "w");
			for (int k = 0; k < 991; k++) {
				for (int j = 0; j < 16; ++j) {
					fprintf(outfile, "%02x", wo[j + k * 16] & 0xff);
				}
				fprintf(outfile, "\n");
			}
			fclose(outfile);*/
		}

	system("pause");

	return 0;
}