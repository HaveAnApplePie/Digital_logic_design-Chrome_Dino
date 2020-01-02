#define _CRT_SECURE_NO_DEPRECATE 
#include <windows.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>

FILE* outfp;
int carry2;

int BMPtoCOE(char *BMPfilename, int isfinished)
{
  FILE *fp;
  if ((fp = fopen(BMPfilename, "rb")) == NULL)
  {
	printf("在该路径下找不到该图片\n");
	return 1;
  }
  char bm[2];
  fseek(fp, sizeof(BITMAPFILEHEADER), 0);
  BITMAPINFOHEADER head;
  fread(&head, sizeof(BITMAPINFOHEADER), 1, fp);
  int picwidth = head.biWidth, picheight = head.biHeight;
  short ind;
  fseek(fp, 0L, 0);
  fread(bm, 2, 1, fp);
  fseek(fp, 0x1CL, 0);
  fread(&ind, 2, 1, fp);
  if (bm[0] != 'B' || bm[1] != 'M' || ind != 32)
  {
	printf("该图片不是32位的位图\n");
	return 1;
  }
  if (picheight < 0) picheight = -picheight;
  fseek(fp, 0x36L, 0);
  printf("图片尺寸%d*%d\n", picwidth, picheight);
  int buf = (picwidth * 3 % 4) ? 4 - (picwidth * 3) % 4 : 0;
  char *tmp = (char*)malloc(sizeof(char)*buf);
  int i, j;
  unsigned char r, g, b, t;
  for (i = 0; i < picheight; i++)
	for (j = 0; j < picwidth; j++)
	{
	  fread(&b, 1, 1, fp);
	  fread(&g, 1, 1, fp);
	  fread(&r, 1, 1, fp);
	  fprintf(outfp, "%3x%x%x", (int)(b / 256.0 * 16), (int)(g / 256.0 * 16), (int)(r / 256.0 * 16));
	  if (i == picheight - 1 && j == picwidth - 1 && isfinished)
		fprintf(outfp, ";");
	  else
		fprintf(outfp, ",");
	  carry2++;
	  if (carry2 == 16)
		fprintf(outfp, "\n"), carry2 = 0;
	  fread(&t, 1, 1, fp);
	}
  free(tmp);
  fclose(fp);
  return 0;
}

int main()
{
  outfp = fopen("C:/Users/Dell/Desktop/LeftUp.coe", "w");
  int i;
  char s[40] = "C:/Users/Dell/Desktop/LeftUp.bmp";
  fprintf(outfp, "memory_initialization_radix=16;\nmemory_initialization_vector =\n");
  BMPtoCOE(s, 1);
  system("pause");
  return 0; 
}

