*&---------------------------------------------------------------------*
*& 包含               ZHR_BDC_TOP
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*定义数据
*--------------------------------------------------------------------*

TYPE-POOLS: truxs.
TYPE-POOLS: slis.
TABLES: sscrfields.

DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
TABLES: t100.

DATA: BEGIN OF stat,
        selno LIKE sy-index,              "Selected records
        succs LIKE sy-index,              "Success records
        error LIKE sy-index,              "Error records
      END OF stat.

DATA: rawdata TYPE truxs_t_text_data.
DATA: progress_text(100) TYPE c.
DATA: info_name(40) TYPE c.
CONSTANTS: method_get  type string value 'GET',
method_post  type string value 'POST'.

FIELD-SYMBOLS: <itab>  TYPE STANDARD TABLE,
               <otype> TYPE otype,
               <objid> TYPE hrobjid,
               <check> TYPE char1,
               <text>  TYPE char100,
               <flag>  TYPE char1.

DATA: BEGIN OF gs_upload,  " 上传数据最大45列
        col01 TYPE string,
        col02 TYPE string,
        col03 TYPE string,
        col04 TYPE string,
        col05 TYPE string,
        col06 TYPE string,
        col07 TYPE string,
        col08 TYPE string,
        col09 TYPE string,
        col10 TYPE string,
        col11 TYPE string,
        col12 TYPE string,
        col13 TYPE string,
        col14 TYPE string,
        col15 TYPE string,
        col16 TYPE string,
        col17 TYPE string,
        col18 TYPE string,
        col19 TYPE string,
        col20 TYPE string,
        col21 TYPE string,
        col22 TYPE string,
        col23 TYPE string,
        col24 TYPE string,
        col25 TYPE string,
        col26 TYPE string,
        col27 TYPE string,
        col28 TYPE string,
        col29 TYPE string,
        col30 TYPE string,
        col31 TYPE string,
        col32 TYPE string,
        col33 TYPE string,
        col34 TYPE string,
        col35 TYPE string,
        col36 TYPE string,
        col37 TYPE string,
        col38 TYPE string,
        col39 TYPE string,
        col40 TYPE string,
        col41 TYPE string,
        col42 TYPE string,
        col43 TYPE string,
        col44 TYPE string,
        col45 TYPE string,
      END OF gs_upload.
DATA: gt_upload LIKE TABLE OF gs_upload.


CONSTANTS: high_date TYPE d VALUE '99991231'.

DATA: gv_ok(1) TYPE c.


DATA: p_front(1) TYPE c VALUE 'X',
      p_back(1)  TYPE c.

*--------------------------------------------------------------------*
*定义选择屏幕
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text00.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS: p_up RADIOBUTTON GROUP pa  USER-COMMAND z1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 2(8) text01 FOR FIELD p_up.      "上传
SELECTION-SCREEN POSITION 40.
PARAMETERS: p_down RADIOBUTTON GROUP pa.
SELECTION-SCREEN COMMENT 41(8) text02 FOR FIELD p_down.     "下载
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(16) text03 FOR FIELD p_path.
PARAMETERS: p_path LIKE ibipparms-path.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.

*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN POSITION 1.
*PARAMETERS: p_front RADIOBUTTON GROUP pb DEFAULT 'X'.
*SELECTION-SCREEN COMMENT 2(8) text04 FOR FIELD p_front.      "前台
*SELECTION-SCREEN POSITION 40.
*PARAMETERS: p_back RADIOBUTTON GROUP pb.
*SELECTION-SCREEN COMMENT 41(8) text05 FOR FIELD p_back.     "后台
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b1.
