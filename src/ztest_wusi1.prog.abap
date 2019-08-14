*&---------------------------------------------------------------------*
*& Report ZTEST_WUSI1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_WUSI1.
DATA lv_current_time           TYPE timestamp.
DATA lv_time_zone              TYPE string value 'UTC+8'.
DATA lv_current_date           TYPE c LENGTH 8.
data lv_price(8)   type p decimals 2.
data ls_header type if_slsprcg_cndnrecd_api_types=>ty_cndnrecd_criteria_header_s.
data lt_item    type if_slsprcg_cndnrecd_api_types=>ty_cndnrecd_criteria_item_t.
data ls_item    type if_slsprcg_cndnrecd_api_types=>ty_cndnrecd_criteria_item_s.
*data ls_option  type if_slsprcg_cndnrecd_api_types=>ty_cndnrecd_query_option_s.
data lt_conditiontype like ls_item-conditiontype.
data ls_conditiontype like line of lt_conditiontype.
data lt_conditionoption like ls_item-conditionfieldselectionoption.
data ls_conditionoption like line of lt_conditionoption.
data lt_conditionrecord like ls_item-conditionrecord.
data ls_conditionrecord like line of lt_conditionrecord.
data lt_conditiontable like ls_item-conditiontable.
data ls_conditiontable like line of lt_conditiontable.

data lt_validity type if_slsprcg_cndnrecd_api_types=>ty_condition_validity_t.
data lt_record type if_slsprcg_cndnrecd_api_types=>ty_condition_record_t.
data lt_scale type if_slsprcg_cndnrecd_api_types=>ty_condition_scale_t.
data lt_supplement type if_slsprcg_cndnrecd_api_types=>ty_condition_supplement_t.
*data ls_option_r type if_slsprcg_cndnrecd_api_types=>ty_query_option_response_s.
GET TIME STAMP FIELD lv_current_time.
CONVERT TIME STAMP lv_current_time TIME ZONE lv_time_zone INTO DATE lv_current_date.

data lv_price_str type string.
data lv_lowest_str type string.

    data(lo_instance) = CL_PRCG_CNDNRECORD_API_FACTORY=>get_instance( ).
    data(lo_sales_instance) = lo_instance->get_sales_api_instance( ).

**    单价不能小于最低限价

*   从价格主数据中获取物料返利
    ls_conditionoption-prcgconditionfieldrangename = 'SALESORGANIZATION'.
    ls_conditionoption-prcgconditionfieldrangelow = '1310'.
    ls_conditionoption-prcgconditionfieldrangeoption = 'EQ'.
    ls_conditionoption-prcgconditionfieldrangesign = 'I'.
    append ls_conditionoption to lt_conditionoption.

    ls_conditionoption-prcgconditionfieldrangename = 'DISTRIBUTIONCHANNEL'.
    ls_conditionoption-prcgconditionfieldrangelow = '10'.
    ls_conditionoption-prcgconditionfieldrangeoption = 'EQ'.
    ls_conditionoption-prcgconditionfieldrangesign = 'I'.
    append ls_conditionoption to lt_conditionoption.

*    ls_conditionoption-prcgconditionfieldrangename = 'CUSTOMER'.
**    ls_conditionoption-prcgconditionfieldrangelow = salesdocument-soldtoparty.
*    ls_conditionoption-prcgconditionfieldrangelow = '  1002129'.
*    ls_conditionoption-prcgconditionfieldrangeoption = 'EQ'.
*    ls_conditionoption-prcgconditionfieldrangesign = 'I'.
*    append ls_conditionoption to lt_conditionoption.

    ls_conditionoption-prcgconditionfieldrangename = 'MATERIAL'.
    ls_conditionoption-prcgconditionfieldrangelow = '5'.
    ls_conditionoption-prcgconditionfieldrangeoption = 'EQ'.
    ls_conditionoption-prcgconditionfieldrangesign = 'I'.
    append ls_conditionoption to lt_conditionoption.

    ls_conditiontype-sign = 'I'.
    ls_conditiontype-option = 'EQ'.
    ls_conditiontype-low = 'PPR0'.
    append ls_conditiontype to lt_conditiontype.

    ls_item-conditiontype = lt_conditiontype.
    ls_item-conditionfieldselectionoption = lt_conditionoption.
    append ls_item to lt_item.
    ls_header-conditionvaliditystartdate = '20181205'.
    ls_header-conditionvalidityenddate = '20181205'.

    try.
    lo_sales_instance->get_prcg_validities(
      EXPORTING
        is_cndnrecord_criteria_header = ls_header
        it_cndnrecord_criteria_item   = lt_item
*    is_cndnrecord_query_option    =
      IMPORTING
        et_condition_validity         = lt_validity
        et_condition_record           = lt_record
        et_condition_scale            = lt_scale
        et_condition_supplement       = lt_supplement
*        es_cndn_query_option_response = ls_option_r
    ).
    CATCH cx_prcg_cndnrecord_exception.
    endtry.
*    WRITE:/ lv_price_str.
    loop at lt_record into data(ls_record).
        if ls_record-conditiontype = 'PPR0'.
            data(lv_lowest) = ls_record-conditionratevalue.
            WRITE:/ lv_lowest.
        endif.
    endloop.
