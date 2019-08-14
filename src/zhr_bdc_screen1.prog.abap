*&---------------------------------------------------------------------*
*& 包含               ZHR_BDC_SCREEN
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.
  PERFORM frm_init_screen.
*--------------------------------------------------------------------*
*AT SELECTION-SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM frm_modify_screen.
*--------------------------------------------------------------------*
*AT SELECTION-SCREEN
*--------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM frm_check_input.
*--------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM frm_path_f4help USING p_path.
*--------------------------------------------------------------------*
*START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  IF p_down = 'X'.
    PERFORM frm_download_template."下载相应数据模版
  ENDIF.
  IF p_up = 'X'.
    PERFORM frm_upload_data. "上传数据
    PERFORM frm_process_data. "处理数据
    PERFORM frm_alv_display. "ALV显示
  ENDIF.
