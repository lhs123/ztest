*&---------------------------------------------------------------------*
*& Report Z11185_FILE_IMPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z11185_MATLOWEST_IMPORT.
*----------------------------------------------
* 公用数据定义
*----------------------------------------------
INCLUDE ZHR_BDC_TOP1.
*include zhr_bdc_top.  " 公用数据定义
INCLUDE OLE2INCL. "定义OLE变量

*----------------------------------------------
* ZHRB0001数据定义      " modify 3
*----------------------------------------------
TYPES:BEGIN OF TY_IMPORT,
        SalesOrg(4) type c,                 "销售组织
        Distribution(2) type c,             "分销渠道
        Transport(3)  type c,               "运输方式
        IncotermsVersion(2) type c,         "国际贸易条款
        Material(10)  type c,               "物料
        Price(5) type p DECIMALS 2,         "价格
        Unit(10)  type c,                   "单位
        ValidStart  type d,                 "有效开始时间
        ValidEnd  type d,                   "有效结束时间
        check(1)  TYPE c, " E-error, S-Sucess
        text(100) TYPE c, " error message
        flag(1)   TYPE c, " 1-red，3-green
      END OF TY_IMPORT.
DATA:GS_IMPORT  TYPE TY_IMPORT,
      GT_IMPORT TYPE STANDARD TABLE OF TY_IMPORT.
DATA: BEGIN OF gs_1000,

        SalesOrg(4) type c,
        Distribution(2) type c,
        Transport(3)  type c,
        IncotermsVersion(2) type c,
        Material(10)  type c,
        Price(5) type p DECIMALS 2,
        Unit(10)  type c,
        ValidStart  type d,
        ValidEnd  type d.





DATA: sel(1)    TYPE c,
      check(1)  TYPE c, " E-error, S-Sucess
      text(100) TYPE c, " error message
      flag(1)   TYPE c, " 1-red，3-green
      %alvcount TYPE i, " count
      END OF gs_1000.

DATA: gt_1000 LIKE TABLE OF gs_1000.

FIELD-SYMBOLS <wa> LIKE gs_1000.

DATA: gv_col1 TYPE i VALUE 1,
      gv_col2 TYPE i VALUE 9,  " modify 5
      gv_row1 TYPE i VALUE 2,
      gv_row2 TYPE i VALUE 100003. " 最多允许10万条记录


*----------------------------------------------
* 公用屏幕处理
*----------------------------------------------
INCLUDE ZHR_BDC_SCREEN1.
*include zhr_bdc_screen. " 公用屏幕处理


*----------------------------------------------
* 公用form
*----------------------------------------------
INCLUDE ZHR_BDC_FORM1.
*include zhr_bdc_form. " 组织公用功能



*----------------------------------------------
* ZHRB0001 特定form   " modify 6
*----------------------------------------------


*&---------------------------------------------------------------------*
*&      Form  frm_process_data.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_process_data.

  DATA: lv_date TYPE d.

  REFRESH gt_1000.

  LOOP AT gt_upload INTO gs_upload.
    " 7列     " modify 7
    IF gs_upload-col01 IS INITIAL
      AND gs_upload-col02 IS INITIAL
      AND gs_upload-col03 IS INITIAL
      AND gs_upload-col04 IS INITIAL.
*      AND gs_upload-col05 IS INITIAL
*      AND gs_upload-col06 IS INITIAL.
*      AND gs_upload-col11 IS INITIAL.


      CONTINUE.
    ENDIF.

    stat-selno = stat-selno + 1.

    CLEAR gs_1000.
    gs_1000-SalesOrg = gs_upload-col01.
    gs_1000-Distribution = gs_upload-col02.
    gs_1000-Transport = gs_upload-col03.
    gs_1000-IncotermsVersion = gs_upload-col04.
    gs_1000-Material = gs_upload-col05.
    gs_1000-Price = gs_upload-col06.
    gs_1000-Unit = gs_upload-col07.
    gs_1000-ValidStart = gs_upload-col08.
    gs_1000-ValidEnd = gs_upload-col09.





*    gs_1000-flag = 2.
    APPEND gs_1000 TO gt_1000.
  ENDLOOP.

  ASSIGN gt_1000 TO <itab>.
  info_name = '物料最低限价维护'.   " modify 8

ENDFORM.                    "frm_process_data

*&---------------------------------------------------------------------*
*&      Form  frm_build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_build_fieldcat USING pt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  DEFINE alv_add_column.
    CLEAR: ls_fieldcat.
    ls_fieldcat-fieldname     =  &1.
    ls_fieldcat-seltext_l     =  &2.
    ls_fieldcat-outputlen     =  &3.
    ls_fieldcat-fix_column    =  &4.
    APPEND ls_fieldcat TO pt_fieldcat.
  END-OF-DEFINITION.


  " modify 9
  alv_add_column  'SalesOrg' '销售组织' '' 'X'.
  alv_add_column  'Distribution' '分销渠道' '' ''.
  alv_add_column  'Transport' '运输方式' '' ''.
  alv_add_column  'IncotermsVersion' '国际贸易条款' '' ''.
  alv_add_column  'Material' '物料' '' ''.
  alv_add_column  'Price'  '价格' '' ''.
  alv_add_column  'Unit'  '单位' '' ''.
  alv_add_column  'ValidStart'  '有效开始时间' '' ''.
  alv_add_column  'ValidEnd'  '有效结束时间' '' ''.
*  alv_add_column  'ANSVH'  '成本类型' '' ''.
*  alv_add_column  'NAME2'  '英文名' '' ''.




  alv_add_column  'CHECK'  '结果' '6' ''.
  alv_add_column  'TEXT'  '消息' '40' ''.

ENDFORM.                    "frm_build_fieldcat
                   "frm_bdc_data
