*&---------------------------------------------------------------------*
*& 包含               ZHR_BDC_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  frm_init_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_init_screen .


ENDFORM.                    "frm_init_screen

*&---------------------------------------------------------------------*
*&      Form  frm_modify_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_modify_screen .

  text00 = '参数'.
  text01 = '上传数据'.
  text02 = '下载模板'.
  text03 = '选择要导入的文件'.
*  text04 = '前台导入'.
*  text05 = '后台作业'.

  IF p_down = 'X'.
    CLEAR p_path.
    LOOP AT SCREEN.
      IF screen-name = 'P_PATH' OR screen-name = 'P_FRONT' OR screen-name = 'P_BACK'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "frm_modify_screen

*&---------------------------------------------------------------------*
*&      Form  frm_check_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_check_input .


ENDFORM.                    "frm_check_input

*&---------------------------------------------------------------------*
*&      Form  frm_path_f4help
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_path_f4help USING p_file.

  DATA: lt_file TYPE  filetable,
        ls_file LIKE LINE OF lt_file,
        l_rc    TYPE  i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = '选择文件'
      default_extension       = 'TXT'
*     default_filename        =
      file_filter             = 'Microsoft Excel 文件 (*.XLS;*.XLSX)|*.XLS;*.XLSX|'
*     with_encoding           =
*     initial_directory       =
*     multiselection          =
    CHANGING
      file_table              = lt_file
      rc                      = l_rc
*     user_action             =
*     file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE e000(su) WITH '选择文件出错'.
  ENDIF.

  READ TABLE lt_file INTO ls_file INDEX 1.
  CHECK sy-subrc = 0.
  p_file = ls_file-filename.

ENDFORM.                    "frm_path_f4help

*&---------------------------------------------------------------------*
*&      Form  frm_download_template
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_download_template  .

  DATA: l_key   LIKE wwwdatatab,
        l_value TYPE w3_qvalue,
        l_mime  TYPE STANDARD TABLE OF w3mime,
        l_fname TYPE string,
        l_path  TYPE string,
        l_fpath TYPE string.

  l_key-relid = 'MI'.
  l_key-objid = 'ZAPI_MODEL'.
  l_fname = '审批节点维护'.
  CONCATENATE l_fname '_' sy-datum sy-uzeit INTO l_fname.

  CALL FUNCTION 'WWWPARAMS_READ'
    EXPORTING
      relid            = l_key-relid
      objid            = l_key-objid
      name             = 'fileextension'
    IMPORTING
      value            = l_value
    EXCEPTIONS
      entry_not_exists = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    MESSAGE s000(su) DISPLAY LIKE 'E' WITH '没有找到模板，请用SMW0上传相应模板'.
    STOP.
  ENDIF.

  CALL FUNCTION 'WWWDATA_IMPORT'
    EXPORTING
      key               = l_key
    TABLES
      mime              = l_mime
    EXCEPTIONS
      wrong_object_type = 1
      import_error      = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
    MESSAGE s000(su) DISPLAY LIKE 'E' WITH '没有找到模板，请用SMW0上传相应模板'.
    STOP.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = '请选择保存路径'
      initial_folder       = 'D:\'
    CHANGING
      selected_folder      = l_fpath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  IF sy-subrc <> 0.
    MESSAGE s000(su) DISPLAY LIKE 'E' WITH '请选择有效路径'.
    STOP.
  ELSEIF l_fpath = ''.
    MESSAGE s000(su) DISPLAY LIKE 'E' WITH '取消下载'.
    STOP.
  ENDIF.

  CONCATENATE l_fpath '\' l_fname l_value INTO l_path.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = l_path
      filetype                = 'BIN'
    TABLES
      data_tab                = l_mime
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc EQ 0.
    MESSAGE s000(su) WITH '模版下载成功'.
  ENDIF.

ENDFORM.                    "frm_download_template

*&---------------------------------------------------------------------*
*&      Form  frm_upload_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_upload_data.

  DATA: lv_len    TYPE i,
        lv_xls(3) TYPE c.

*  DATA: lt_return TYPE TABLE OF zhr_alsmex_tabline WITH HEADER LINE.



DATA: BEGIN OF lt_return OCCURS 0.
        INCLUDE STRUCTURE ALSMEX_TABLINE.
DATA: END OF lt_return.

  IF p_path = ''.
    MESSAGE s000(su) DISPLAY LIKE 'E' WITH '请指定导入文件'.
    STOP.
  ENDIF.

  REFRESH gt_upload.

  progress_text =  '正在上传数据，请等待......'.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = progress_text.

*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      i_tab_raw_data       = rawdata
*      i_filename           = p_path
*    TABLES
*      i_tab_converted_data = gt_upload
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.

  lv_len = strlen( p_path ).
  lv_len = lv_len - 3.
  lv_xls = p_path+lv_len(3).
  TRANSLATE lv_xls TO UPPER CASE.
  IF lv_xls = 'XLS'.
    gv_row2 =  60003.
  ELSE.
    gv_row2 = 100003.
  ENDIF.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
  EXPORTING
    FILENAME                      = p_path
    I_BEGIN_COL                   = gv_col1
    I_BEGIN_ROW                   = gv_row1
    I_END_COL                     = gv_col2 " 读取多少列
    I_END_ROW                     = gv_row2 "读取多少行
  TABLES
    INTERN                        = lt_return
  EXCEPTIONS
    INCONSISTENT_PARAMETERS       = 1
    UPLOAD_OLE                    = 2
  OTHERS                          = 3.

*  call function 'Z_ALSM_EXCEL_TO_INTERNAL_TABLE'
*    EXPORTING
*      filename                = p_path
*      i_begin_col             = gv_col1
*      i_begin_row             = gv_row1
*      i_end_col               = gv_col2
*      i_end_row               = gv_row2
*    TABLES
*      intern                  = lt_return
*    EXCEPTIONS
*      inconsistent_parameters = 1
*      upload_ole              = 2
*      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE e000(su) WITH '文件上传错误'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  LOOP AT lt_return.

    CASE lt_return-col.
      WHEN '0001'.
        gs_upload-col01 = lt_return-value.
      WHEN '0002'.
        gs_upload-col02 = lt_return-value.
      WHEN '0003'.
        gs_upload-col03 = lt_return-value.
      WHEN '0004'.
        gs_upload-col04 = lt_return-value.
      WHEN '0005'.
        gs_upload-col05 = lt_return-value.
      WHEN '0006'.
        gs_upload-col06 = lt_return-value.
      WHEN '0007'.
        gs_upload-col07 = lt_return-value.
      WHEN '0008'.
        gs_upload-col08 = lt_return-value.
      WHEN '0009'.
        gs_upload-col09 = lt_return-value.
      WHEN '0010'.
        gs_upload-col10 = lt_return-value.
      WHEN '0011'.
        gs_upload-col11 = lt_return-value.
      WHEN '0012'.
        gs_upload-col12 = lt_return-value.
      WHEN '0013'.
        gs_upload-col13 = lt_return-value.
      WHEN '0014'.
        gs_upload-col14 = lt_return-value.
      WHEN '0015'.
        gs_upload-col15 = lt_return-value.
      WHEN '0016'.
        gs_upload-col16 = lt_return-value.
      WHEN '0017'.
        gs_upload-col17 = lt_return-value.
      WHEN '0018'.
        gs_upload-col18 = lt_return-value.
      WHEN '0019'.
        gs_upload-col19 = lt_return-value.
      WHEN '0020'.
        gs_upload-col20 = lt_return-value.
      WHEN '0021'.
        gs_upload-col21 = lt_return-value.
      WHEN '0022'.
        gs_upload-col22 = lt_return-value.
      WHEN '0023'.
        gs_upload-col23 = lt_return-value.
      WHEN '0024'.
        gs_upload-col24 = lt_return-value.
      WHEN '0025'.
        gs_upload-col25 = lt_return-value.
      WHEN '0026'.
        gs_upload-col26 = lt_return-value.
      WHEN '0027'.
        gs_upload-col27 = lt_return-value.
      WHEN '0028'.
        gs_upload-col28 = lt_return-value.
      WHEN '0029'.
        gs_upload-col29 = lt_return-value.
      WHEN '0030'.
        gs_upload-col30 = lt_return-value.
      WHEN '0031'.
        gs_upload-col31 = lt_return-value.
      WHEN '0032'.
        gs_upload-col32 = lt_return-value.
      WHEN '0033'.
        gs_upload-col33 = lt_return-value.
      WHEN '0034'.
        gs_upload-col34 = lt_return-value.
      WHEN '0035'.
        gs_upload-col35 = lt_return-value.
      WHEN '0036'.
        gs_upload-col36 = lt_return-value.
      WHEN '0037'.
        gs_upload-col37 = lt_return-value.
      WHEN '0038'.
        gs_upload-col38 = lt_return-value.
      WHEN '0039'.
        gs_upload-col39 = lt_return-value.
      WHEN '0040'.
        gs_upload-col40 = lt_return-value.
      WHEN '0041'.
        gs_upload-col41 = lt_return-value.
      WHEN '0042'.
        gs_upload-col42 = lt_return-value.
      WHEN '0043'.
        gs_upload-col43 = lt_return-value.
      WHEN '0044'.
        gs_upload-col44 = lt_return-value.
      WHEN '0045'.
        gs_upload-col45 = lt_return-value.
    ENDCASE.

    AT END OF row.
      APPEND gs_upload TO gt_upload.
      CLEAR: gs_upload.
    ENDAT.

  ENDLOOP.

  IF lines( gt_upload ) = 0.
    MESSAGE i000(su) WITH '无数据'.
    STOP.
  ELSE.
    MESSAGE s000(su) WITH '文件上传成功'.
  ENDIF.

ENDFORM.                    "frm_upload_data


*&---------------------------------------------------------------------*
*&      Form  frm_alv_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_alv_display .

  DATA: lt_fieldcat TYPE  slis_t_fieldcat_alv,
        lt_events   TYPE  slis_t_event,
        ls_event    TYPE LINE OF slis_t_event,
        ls_layout   TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-f2code = '&ETA'.
  ls_layout-detail_popup = 'X'.
  ls_layout-no_subtotals = ''.
  ls_layout-detail_initial_lines = 'X'.
  ls_layout-lights_fieldname = 'FLAG'.
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-countfname = '%ALVCOUNT'.
  ls_layout-box_fieldname = 'SEL'.

  ls_event-name  = slis_ev_top_of_page.
  ls_event-form  = slis_ev_top_of_page.
  APPEND ls_event TO lt_events.

  PERFORM frm_build_fieldcat USING lt_fieldcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'FRM_SET_PF_STATUS'
      i_callback_user_command  = 'FRM_USER_COMMAND'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
      i_save                   = 'A'
      it_events                = lt_events
    TABLES
      t_outtab                 = <itab>
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "frm_alv_display

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.

  DATA: ls_comment TYPE slis_listheader,
        lt_comment TYPE slis_t_listheader,
        num(8).

  ls_comment-typ  = 'H'.
  ls_comment-info = info_name.
  APPEND ls_comment TO lt_comment.

  ls_comment-typ  = 'S'.
  num = stat-selno.
  CONCATENATE '记录数：' num INTO ls_comment-info.
  APPEND ls_comment TO lt_comment.
  num = stat-succs.
  CONCATENATE '成功：' num INTO ls_comment-info.
  APPEND ls_comment TO lt_comment.
  num = stat-error.
  CONCATENATE '失败：' num INTO ls_comment-info.
  APPEND ls_comment TO lt_comment.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_comment.

ENDFORM.                    "TOP_OF_PAGE



*&---------------------------------------------------------------------*
*&      Form  frm_set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM frm_set_pf_status USING rt_extab TYPE slis_t_extab.

*  DATA: lt_exclud TYPE slis_t_extab,
*        ls_exclud TYPE slis_extab.
*
*  IF gv_ok = 'X'. " 已完成导入
*    ls_exclud-fcode = 'ZBDC'.
*    APPEND ls_exclud TO lt_exclud.
*    SET PF-STATUS 'BDC_ALV' EXCLUDING lt_exclud.
*  ELSE.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
*  ENDIF.

ENDFORM.                    "frm_set_pf_status
*&---------------------------------------------------------------------*
*&      Form  frm_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM frm_user_command  USING r_ucomm LIKE sy-ucomm
                             rs_selfield TYPE slis_selfield.

  DATA: lv_group LIKE apqi-groupid,
        lv_json1 type string,
        lv_json2 type string,
        lv_json type string,
        lv_url type string,
        lv_price type string,
        lv_time type T,
        LV_ValidStart(13) TYPE N,
        LV_ValidEnd(13) TYPE N,
        lv_tzon TYPE STRING,
        lv_msg type string,
        lv_msgty type c,
        lv_flag type c.
  DATA LV_DAYS TYPE VTBBEWE-ATAGE.

  IF r_ucomm = '&CALL'.

    LOOP AT <itab> ASSIGNING <wa> .
      CHECK <wa>-sel = 'X'.
      CHECK <wa>-check <> 'S'.
      clear:lv_json1,lv_json2,lv_json,lv_url,lv_msgty,lv_msg,lv_price.
      lv_price = <wa>-Price.
      CONDENSE lv_price.
*      PERFORM date_time_to_p6(rstr0400) USING <wa>-ValidStart       "/using
*                                        lv_time       "/using
*                                        LV_ValidStart           "/changing
*                                        lv_tzon.
*      PERFORM date_time_to_p6(rstr0400) USING <wa>-ValidEnd       "/using
*                                        lv_time       "/using
*                                        LV_ValidEnd          "/changing
*                                        lv_tzon.
*      CONCATENATE LV_ValidStart '000' INTO LV_ValidStart.
*      CONCATENATE LV_ValidEnd '000' INTO LV_ValidEnd.
*      CONDENSE LV_ValidStart.
*      CONDENSE LV_ValidEnd.
      CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
       EXPORTING
         i_date_from          = '19700101'
*        I_KEY_DAY_FROM       =
         i_date_to            = <wa>-ValidStart
*        I_KEY_DAY_TO         =
*        I_FLG_SEPARATE       = ' '
       IMPORTING
         E_DAYS               = LV_DAYS
*        E_MONTHS             =
*        E_YEARS              =
               .
      LV_ValidStart = LV_DAYS * 24 * 60 * 60 * 1000 + 8 * 60 * 60 * 1000.
      CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
       EXPORTING
         i_date_from          = '19700101'
*        I_KEY_DAY_FROM       =
         i_date_to            = <wa>-ValidEnd
*        I_KEY_DAY_TO         =
*        I_FLG_SEPARATE       = ' '
       IMPORTING
         E_DAYS               = LV_DAYS
*        E_MONTHS             =
*        E_YEARS              =
               .
      LV_ValidEnd = LV_DAYS * 24 * 60 * 60 * 1000 + 8 * 60 * 60 * 1000.
      CONCATENATE '{"SalesOrg":"' <wa>-SalesOrg '","Distribution":"' <wa>-Distribution
       '","Transport":"' <wa>-Transport '","IncotermsVersion":"' <wa>-IncotermsVersion
      '","to_MATERIAL_CHILDREN":[{"Material":"' <wa>-Material '","Price_V":"' lv_price
      '","Unit":"' <wa>-Unit '","ValidStart":"/Date(' LV_ValidStart ')/","ValidEnd":"/Date(' LV_ValidEnd
      ')/"}]}' into lv_json1.
      CONCATENATE '{"Material":"'<wa>-Material '","Price_V":"' lv_price
      '","Unit":"' <wa>-Unit '","ValidStart":"/Date(' LV_ValidStart
      ')/","ValidEnd":"/Date(' LV_ValidEnd
      ')/"}' into lv_json2.
      CONCATENATE 'https://my300048-api.saps4hanacloud.cn/sap/opu/odata/sap/YY1_MATERIAL_LOWESTPR_CDS/YY1_MATERIAL_LOWESTPR?$filter=SalesOrg eq '''
       <wa>-SalesOrg ''' and  Distribution eq '''  <wa>-Distribution ''' and  Transport eq '''  <wa>-Transport  ''' and  IncotermsVersion eq '''  <wa>-IncotermsVersion '''' into lv_url.
      PERFORM FRM_CALL_API using lv_json1 lv_json2 lv_url lv_msgty lv_msg.
      if lv_msgty = 'S'.
        <wa>-FLAG = 3.
        stat-succs = stat-succs + 1.
      ELSEIF lv_msgty = 'E'.
        <wa>-FLAG = 1.
        <wa>-TEXT = lv_msg.
        stat-error = stat-error + 1.
      endif.
    ENDLOOP.


    gv_ok = 'X'.  " 已完成导入

    rs_selfield-refresh = 'X'.

  ENDIF.

ENDFORM.                    "frm_user_command
*&---------------------------------------------------------------------*
*& Form FRM_CALL_API
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_JSON
*&---------------------------------------------------------------------*
FORM FRM_CALL_API  USING    P_LV_JSON1 P_LV_JSON2 P_URL p_msgty p_msg.
  data lv_token type string.
  data lv_cookie type string.
  data lv_cookie1 type string.
  data lv_url type string.
  data lv_url1 type string.
  data lv_url2 type string.
  data lv_1 type string.
  data lv_2 type string.
  data ref_http_client TYPE REF TO IF_HTTP_CLIENT.
  data lo_http_client TYPE REF TO IF_HTTP_CLIENT.
  data e_subrc type sy-subrc.
  data: e_msg_text type string,
        lt_fields      TYPE tihttpnvp,
  lv_rt_code TYPE i,
    lv_rt_str  TYPE string.
*&---创建链接实例REF_HTTP_CLIENT
  cl_http_client=>create_by_url(
          EXPORTING url    = P_URL
          IMPORTING client = ref_http_client ).

*&---发送Header属性
  ref_http_client->propertytype_accept_cookie = if_http_client=>co_enabled.
  " HTTP的协议版本
  ref_http_client->request->set_header_field(
          EXPORTING
               name  = '~server_protocol'
               value = 'HTTP/1.1' ).
  " 内容类型为json
  ref_http_client->request->set_header_field(
          EXPORTING
               name  = 'Content-Type'
               value = 'application/json;charset=utf-8' ).

  ref_http_client->request->set_header_field(
          EXPORTING
               name  = 'Accept'
               value = 'application/json' ).

  ref_http_client->request->set_header_field(
          EXPORTING
               name  = 'X-CSRF-Token'
               value = 'Fetch' ).

  ref_http_client->request->set_header_field(
          EXPORTING
               name  = 'sap-language'
               value = 'ZH' ).
  " 设置用户名密码 要求用户和密码要 basic 64位


   ref_http_client->request->set_header_field(
        EXPORTING
             name  = 'Authorization'
             value = 'Basic T0FfVVNFUjoxUUFaQHdzeDNlZGM0cmZ2NXRnYg==' ).


*----调用的方法

  ref_http_client->request->set_method( method_get ).

*---http数据发送

  ref_http_client->send(
     EXCEPTIONS
       http_communication_failure = 1
       http_invalid_state         = 2 ).

  IF sy-subrc <> 0.

*---得send方法错误信息

    ref_http_client->get_last_error(
            IMPORTING
              code    = e_subrc
              message = e_msg_text ).

  ELSE.

*&---接收返回信息

    ref_http_client->receive(
     EXCEPTIONS
       http_communication_failure = 1
       http_invalid_state         = 2
       http_processing_failed     = 3 ).

    IF sy-subrc <> 0.

* &---得到上面receive方法错误信息

      ref_http_client->get_last_error(
       IMPORTING
         code    = e_subrc
         message = e_msg_text ).

    ELSE.

*---获取返回状态码200为http协议正确返回

      ref_http_client->response->get_status( IMPORTING code = lv_rt_code ).
      " 返回状态码
      e_subrc = lv_rt_code.
*---获取返回的字符串数据
      lv_rt_str = ref_http_client->response->get_cdata( ).
*      判断此抬头数据是否已创建，切换不同的URL进行POST
      SPLIT lv_rt_str at '"to_MATERIAL_CHILDREN":{"__deferred":{"uri":"' into lv_1 lv_2.
      if lv_2 is initial.
        lv_url1 = 'https://my300048-api.saps4hanacloud.cn/sap/opu/odata/sap/YY1_MATERIAL_LOWESTPR_CDS/YY1_MATERIAL_LOWESTPR'.
*        需要通过相同的URL获取token
*&---创建链接实例REF_HTTP_CLIENT
          cl_http_client=>create_by_url(
                  EXPORTING url    = lv_url1
                  IMPORTING client = lo_http_client ).
          lo_http_client->propertytype_accept_cookie = if_http_client=>co_enabled.
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = '~server_protocol'
                       value = 'HTTP/1.1' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Content-Type'
                       value = 'application/json;charset=utf-8' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Accept'
                       value = 'application/json' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'X-CSRF-Token'
                       value = 'Fetch' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'sap-language'
                       value = 'ZH' ).
           lo_http_client->request->set_header_field(
                EXPORTING
                     name  = 'Authorization'
                     value = 'Basic T0FfVVNFUjoxUUFaQHdzeDNlZGM0cmZ2NXRnYg==' ).
           lo_http_client->request->set_method( method_get ).
           lo_http_client->send(
             EXCEPTIONS
               http_communication_failure = 1
               http_invalid_state         = 2 ).
           if sy-subrc = 0.
             lo_http_client->receive(
               EXCEPTIONS
                 http_communication_failure = 1
                 http_invalid_state         = 2
                 http_processing_failed     = 3 ).
             if sy-subrc = 0.
               lo_http_client->response->get_header_fields( CHANGING fields = lt_fields ).
               READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<field>) WITH KEY name = 'x-csrf-token'.
               lv_token = <field>-value.
             endif.
           endif.
*          READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<field2>) with key name = 'set-cookie'.
*          lv_cookie1 = <field2>-value.
*          CONCATENATE lv_cookie lv_cookie1 into lv_cookie.
*        &---发送Header属性
          lo_http_client->propertytype_accept_cookie = if_http_client=>co_enabled.
          " HTTP的协议版本
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = '~server_protocol'
                       value = 'HTTP/1.1' ).
          " 内容类型为json
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Cookie'
                       value = lv_cookie ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Content-Type'
                       value = 'application/json;charset=utf-8' ).

          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Accept'
                       value = 'application/json' ).

          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'X-CSRF-Token'
                       value = lv_token ).
*          ref_http_client->request->set_header_field(
*                  EXPORTING
*                       name  = 'X-Requested-With'
*                       value = 'X' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'sap-language'
                       value = 'ZH' ).
           lo_http_client->request->set_header_field(
                EXPORTING
                     name  = 'Authorization'
                     value = 'Basic T0FfVVNFUjoxUUFaQHdzeDNlZGM0cmZ2NXRnYg==' ).
           lo_http_client->request->set_method( method_post ).

          IF P_LV_JSON1 IS NOT INITIAL.

            lo_http_client->request->set_cdata(
                EXPORTING
                  data  = P_LV_JSON1 ).
          ENDIF.
*---http数据发送

          lo_http_client->send(
             EXCEPTIONS
               http_communication_failure = 1
               http_invalid_state         = 2 ).

          IF sy-subrc = 0.
*        &---接收返回信息

            lo_http_client->receive(
             EXCEPTIONS
               http_communication_failure = 1
               http_invalid_state         = 2
               http_processing_failed     = 3 ).

            IF sy-subrc = 0.
*        ---获取返回状态码201为创建成功
              lo_http_client->response->get_status( IMPORTING code = lv_rt_code ).
              lv_rt_str = lo_http_client->response->get_cdata( ).
              " 返回状态码
              e_subrc = lv_rt_code.
              if e_subrc = 201.
                P_MSGTY = 'S'.
              endif.
              lo_http_client->close( ).
            ENDIF.
        ENDIF.
      else.
*        创建子节点
        SPLIT lv_2 at '"' into lv_url2 lv_1.
        cl_http_client=>create_by_url(
                  EXPORTING url    = lv_url2
                  IMPORTING client = lo_http_client ).
          lo_http_client->propertytype_accept_cookie = if_http_client=>co_enabled.
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = '~server_protocol'
                       value = 'HTTP/1.1' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Content-Type'
                       value = 'application/json;charset=utf-8' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Accept'
                       value = 'application/json' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'X-CSRF-Token'
                       value = 'Fetch' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'sap-language'
                       value = 'ZH' ).
           lo_http_client->request->set_header_field(
                EXPORTING
                     name  = 'Authorization'
                     value = 'Basic T0FfVVNFUjoxUUFaQHdzeDNlZGM0cmZ2NXRnYg==' ).
           lo_http_client->request->set_method( method_get ).
           lo_http_client->send(
             EXCEPTIONS
               http_communication_failure = 1
               http_invalid_state         = 2 ).
           if sy-subrc = 0.
             lo_http_client->receive(
               EXCEPTIONS
                 http_communication_failure = 1
                 http_invalid_state         = 2
                 http_processing_failed     = 3 ).
             if sy-subrc = 0.
               lo_http_client->response->get_header_fields( CHANGING fields = lt_fields ).
               READ TABLE lt_fields ASSIGNING <field> WITH KEY name = 'x-csrf-token'.
               lv_token = <field>-value.
             endif.
           endif.

           lo_http_client->propertytype_accept_cookie = if_http_client=>co_enabled.
          " HTTP的协议版本
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = '~server_protocol'
                       value = 'HTTP/1.1' ).
          " 内容类型为json
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Cookie'
                       value = lv_cookie ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Content-Type'
                       value = 'application/json;charset=utf-8' ).

          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'Accept'
                       value = 'application/json' ).

          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'X-CSRF-Token'
                       value = lv_token ).
*          ref_http_client->request->set_header_field(
*                  EXPORTING
*                       name  = 'X-Requested-With'
*                       value = 'X' ).
          lo_http_client->request->set_header_field(
                  EXPORTING
                       name  = 'sap-language'
                       value = 'ZH' ).
           lo_http_client->request->set_header_field(
                EXPORTING
                     name  = 'Authorization'
                     value = 'Basic T0FfVVNFUjoxUUFaQHdzeDNlZGM0cmZ2NXRnYg==' ).
           lo_http_client->request->set_method( method_post ).

          IF P_LV_JSON2 IS NOT INITIAL.

            lo_http_client->request->set_cdata(
                EXPORTING
                  data  = P_LV_JSON2 ).
          ENDIF.
*---http数据发送

          lo_http_client->send(
             EXCEPTIONS
               http_communication_failure = 1
               http_invalid_state         = 2 ).

          IF sy-subrc = 0.
*        &---接收返回信息

            lo_http_client->receive(
             EXCEPTIONS
               http_communication_failure = 1
               http_invalid_state         = 2
               http_processing_failed     = 3 ).

            IF sy-subrc = 0.
*        ---获取返回状态码201为创建成功
              lo_http_client->response->get_status( IMPORTING code = lv_rt_code ).
              lv_rt_str = lo_http_client->response->get_cdata( ).
              " 返回状态码
              e_subrc = lv_rt_code.
              if e_subrc = 201.
                P_MSGTY = 'S'.
              endif.
              lo_http_client->close( ).
            ENDIF.
        ENDIF.
      endif.
   endif.
endif.
IF P_MSGTY NE 'S'.
   P_MSGTY = 'E'.
   SPLIT lv_rt_str at '"value":"' into lv_1 lv_2.
   SPLIT lv_2 at '"' into P_MSG lv_1.
ENDIF.
ENDFORM.
