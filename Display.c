#include "Display.h"

u8g_t u8g;

void Display_Init(void)
{
  u8g_InitHWSPI(
      &u8g,
      &u8g_dev_sh1106_128x64_hw_spi,
      PN(1, 0), // CS
      PN(1, 4), // A0
      PN(0, 7) // RESET
  );
}

uint8_t row;
uint8_t column;

void key_read_callback(uint8_t _row, uint8_t _column)
{
  row = _row;
  column = _column;
}

void Display_Write_Centered(int8_t x_offset, int8_t y_offset, ...){
  va_list ap, apl;
  uint8_t lines;
  u8g_pgm_uint8_t *str;
  va_start(ap, y_offset);
  // count lines
  va_copy(apl, ap);
  lines=0;
  while(va_arg(apl, u8g_pgm_uint8_t *)!=NULL)
    lines++;
  va_end(apl);
  // print lines
  int l=0;
  while((str=va_arg(ap, u8g_pgm_uint8_t *))!=NULL){
    int8_t x=u8g_GetWidth(&u8g)/2-u8g_GetStrWidth(&u8g, str)/2+x_offset;
    u8g_SetFontRefHeightText(&u8g);
    int8_t y=u8g_GetHeight(&u8g)/2+u8g_GetFontAscent(&u8g)/2+y_offset;
    u8g_SetFontRefHeightAll(&u8g);
    int8_t font_height=(u8g_GetFontLineSpacing(&u8g));
    int8_t line_y_offset=-font_height/2*(lines-1);
    u8g_DrawStr(&u8g, x, y+line_y_offset+font_height*l+2*l, str);
    l++;
  }
  va_end(ap);
}

void Display_Update(void)
{
  char *str_row[11];
  char *str_column[11];

  row = 0;
  column = 0;

  ScanKeys_Read(&key_read_callback);

  u8g_FirstPage(&u8g);
  do {
    u8g_DrawFrame(&u8g, 0, 0, 128, 64);
    u8g_SetFont(&u8g, u8g_font_helvB12);
    Display_Write_Centered(
      0, 0,
      utoa(row, str_row, 10),
      utoa(column, str_column, 10),
      NULL
    );
  } while(u8g_NextPage(&u8g));
}
