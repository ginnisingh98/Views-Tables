--------------------------------------------------------
--  DDL for Package Body QPR_LOAD_MEAS_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_LOAD_MEAS_DATA" AS
/* $Header: QPRUFMDB.pls 120.17 2008/05/29 06:01:26 vinnaray ship $ */

 type char_type is table of varchar2(30) index by varchar2(30);
  type qpr_src_qtn_line_type is table of QPR_PN_INT_LINES%rowtype;
  type qpr_src_qtn_adj_type is table of qpr_pn_int_pr_adjs%rowtype;

  g_request_id number;
  g_instance_id number;
  g_meas_type varchar2(30);
  g_sys_date date;
  g_user_id number;
  g_login_id number;
  g_prg_appl_id number;
  g_prg_id number;

  r_srcrecs QPR_MEAS_DATA_TYPE;
  r_insrecs QPR_MEAS_DATA_TYPE;
  r_updrecs QPR_MEAS_DATA_TYPE1;
  r_meas_data QPR_DIM_DATA_TYPE;

  l_upd_ctr pls_integer := 1;
  l_ins_ctr pls_integer := 1;
  g_src_cols char240_type;
  g_trg_cols char240_type;

  g_t_src_lines QPR_SRC_QTN_LINE_TYPE;
  g_r_ins_deal QPR_DEAL_LINE_TYPE;
  g_r_upd_deal QPR_DEAL_LINE_TYPE;
  g_quote_hdr_sd QPR_PN_INT_HEADERS.SOURCE_REF_HEADER_SHORT_DESC%TYPE;
  g_source_id number;

  num_meas_cname CONSTANT varchar2(30)  := 'MEASURE#_NUMBER';
  char_meas_cname CONSTANT varchar2(30) := 'MEASURE#_CHAR';
  max_num_meas CONSTANT pls_integer  := 30;
  max_char_meas CONSTANT pls_integer := 10;
  MEAS_TYPE_SALES CONSTANT varchar2(30) := 'SALESDATA';
  MEAS_TYPE_ADJ CONSTANT varchar2(30) := 'ADJUSTMENT';
  MEAS_TYPE_OFFADJ CONSTANT varchar2(30) := 'OFFADJDATA';
  OM_MEAS_TYPE_DEALINT CONSTANT varchar2(30) := 'OM_DEALINT';
  ASO_MEAS_TYPE_DEALINT CONSTANT varchar2(30) := 'ASO_DEALINT';
  DEAL_HEADER_TBL CONSTANT varchar2(30) := 'QPR_PN_INT_HEADERS';
  DEAL_LINE_TBL CONSTANT varchar2(30) := 'QPR_PN_INT_LINES';
  SEEDED_INSTANCE_ID CONSTANT number := 1;

  NO_TBL_DEF exception;

  s_dim_select CONSTANT varchar2(1000) := 'select SR_ORDER_LINE_PK, SR_ADJ_ID_PK,
BOOKED_DATE, SR_CUSTOMER_PK, SR_SHIP_TO_LOC_PK, SR_ITEM_PK, SR_SALES_REP_PK,
SR_SALES_CHANNEL_PK, OU_ID, SR_USER_DEFINED1_PK, SR_USER_DEFINED2_PK,
SR_USER_DEFINED3_PK, SR_USER_DEFINED4_PK, SR_USER_DEFINED5_PK, ';

  s_where_clause CONSTANT varchar2(1000) := ' where booked_date between :d1 and
:d2 order by SR_ORDER_LINE_PK, SR_ADJ_ID_PK, BOOKED_DATE, SR_CUSTOMER_PK,
SR_SHIP_TO_LOC_PK, SR_ITEM_PK, SR_SALES_REP_PK, SR_SALES_CHANNEL_PK,
OU_ID, SR_USER_DEFINED1_PK, SR_USER_DEFINED2_PK, SR_USER_DEFINED3_PK,
SR_USER_DEFINED4_PK, SR_USER_DEFINED5_PK' ;

  s_where_clause1 CONSTANT varchar2(1000) := ' where trx_date between :d1 and
:d2 order by SR_ORDER_LINE_PK, SR_ADJ_ID_PK, BOOKED_DATE, SR_CUSTOMER_PK,
SR_SHIP_TO_LOC_PK, SR_ITEM_PK, SR_SALES_REP_PK, SR_SALES_CHANNEL_PK,
OU_ID, SR_USER_DEFINED1_PK, SR_USER_DEFINED2_PK, SR_USER_DEFINED3_PK,
SR_USER_DEFINED4_PK, SR_USER_DEFINED5_PK' ;

procedure log_debug(p_text in varchar2) is
begin
  fnd_file.put_line(fnd_file.log, p_text);
  --pp_debug(p_text);
   if (g_origin = 660 or g_origin = 697) then
	qpr_deal_pvt.debug_ext_log(p_text, g_origin);
   end if;
end;

function get_select_meas_sql(p_src_tbl_name varchar2, p_meas_type varchar2)
							return varchar2 is
    b_first boolean := true;
    s_sql varchar2(30000) := '';
    s_meas_sql varchar2(10000) := '';
    meas_name varchar2(30) := '';
    t_src_trg_cols char_type;
begin
    for i in g_src_cols.first..g_src_cols.last loop
     t_src_trg_cols(g_trg_cols(i)) := g_src_cols(i);
    end loop;
 -- loop to include measures of number type in select
    for i in 1..max_num_meas loop
      meas_name := replace(num_meas_cname, '#', i);
      if t_src_trg_cols.exists(meas_name) then
        s_meas_sql := s_meas_sql || t_src_trg_cols(meas_name);
      else
        s_meas_sql := s_meas_sql || 'null ';
      end if;
--      if i < max_num_meas then
        s_meas_sql := s_meas_sql || ', ';
--      end if;
    end loop;

--    loop to include measures of char type in select
    for i in 1..max_char_meas loop
      meas_name := replace(char_meas_cname, '#', i);
      if t_src_trg_cols.exists(meas_name) then
        s_meas_sql := s_meas_sql || t_src_trg_cols(meas_name);
      else
        s_meas_sql := s_meas_sql || 'null ';
      end if;
--      if i < max_char_meas then
        s_meas_sql := s_meas_sql || ', ';
--      end if;
    end loop;

    if t_src_trg_cols.exists('MEASURE_UOM') then
      s_meas_sql := s_meas_sql || t_src_trg_cols('MEASURE_UOM');
    else
      s_meas_sql := s_meas_sql || 'null';
    end if;

    s_sql := s_dim_select || s_meas_sql || ' from ' || p_src_tbl_name;
    if p_meas_type = MEAS_TYPE_OFFADJ then
      s_sql := s_sql || s_where_clause1;
    else
      s_sql := s_sql || s_where_clause;
    end if;
    log_debug('Complete SQL:' || s_sql);
    t_src_trg_cols.delete;
    return(s_sql);
exception
    when OTHERS then
        log_debug('ERROR FORMING MEASURE SELECT...');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end get_select_meas_sql;

procedure assign_val_to_ins(src_ctr in PLS_INTEGER) is
begin
  r_insrecs.ORD_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.ORD_LEVEL_VALUE(src_ctr);
  r_insrecs.ADJ_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.ADJ_LEVEL_VALUE(src_ctr);
  r_insrecs.TIME_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.TIME_LEVEL_VALUE(src_ctr);
  r_insrecs.CUS_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.CUS_LEVEL_VALUE(src_ctr);
  r_insrecs.GEO_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.GEO_LEVEL_VALUE(src_ctr);
  r_insrecs.PRD_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.PRD_LEVEL_VALUE(src_ctr);
  r_insrecs.REP_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.REP_LEVEL_VALUE(src_ctr);
  r_insrecs.CHN_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.CHN_LEVEL_VALUE(src_ctr);
  r_insrecs.ORG_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.ORG_LEVEL_VALUE(src_ctr);
  r_insrecs.USR1_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.USR1_LEVEL_VALUE(src_ctr);
  r_insrecs.USR2_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.USR2_LEVEL_VALUE(src_ctr);
  r_insrecs.USR3_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.USR3_LEVEL_VALUE(src_ctr);
  r_insrecs.USR4_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.USR4_LEVEL_VALUE(src_ctr);
  r_insrecs.USR5_LEVEL_VALUE(l_ins_ctr) := r_srcrecs.USR5_LEVEL_VALUE(src_ctr);
  r_insrecs.MEASURE1_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE1_NUMBER(src_ctr);
  r_insrecs.MEASURE2_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE2_NUMBER(src_ctr);
  r_insrecs.MEASURE3_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE3_NUMBER(src_ctr);
  r_insrecs.MEASURE4_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE4_NUMBER(src_ctr);
  r_insrecs.MEASURE5_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE5_NUMBER(src_ctr);
  r_insrecs.MEASURE6_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE6_NUMBER(src_ctr);
  r_insrecs.MEASURE7_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE7_NUMBER(src_ctr);
  r_insrecs.MEASURE8_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE8_NUMBER(src_ctr);
  r_insrecs.MEASURE9_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE9_NUMBER(src_ctr);
  r_insrecs.MEASURE10_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE10_NUMBER(src_ctr);
  r_insrecs.MEASURE11_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE11_NUMBER(src_ctr);
  r_insrecs.MEASURE12_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE12_NUMBER(src_ctr);
  r_insrecs.MEASURE13_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE13_NUMBER(src_ctr);
  r_insrecs.MEASURE14_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE14_NUMBER(src_ctr);
  r_insrecs.MEASURE15_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE15_NUMBER(src_ctr);
  r_insrecs.MEASURE16_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE16_NUMBER(src_ctr);
  r_insrecs.MEASURE17_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE17_NUMBER(src_ctr);
  r_insrecs.MEASURE18_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE18_NUMBER(src_ctr);
  r_insrecs.MEASURE19_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE19_NUMBER(src_ctr);
  r_insrecs.MEASURE20_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE20_NUMBER(src_ctr);
  r_insrecs.MEASURE21_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE21_NUMBER(src_ctr);
  r_insrecs.MEASURE22_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE22_NUMBER(src_ctr);
  r_insrecs.MEASURE23_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE23_NUMBER(src_ctr);
  r_insrecs.MEASURE24_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE24_NUMBER(src_ctr);
  r_insrecs.MEASURE25_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE25_NUMBER(src_ctr);
  r_insrecs.MEASURE26_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE26_NUMBER(src_ctr);
  r_insrecs.MEASURE27_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE27_NUMBER(src_ctr);
  r_insrecs.MEASURE28_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE28_NUMBER(src_ctr);
  r_insrecs.MEASURE29_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE29_NUMBER(src_ctr);
  r_insrecs.MEASURE30_NUMBER(l_ins_ctr) := r_srcrecs.MEASURE30_NUMBER(src_ctr);
  r_insrecs.MEASURE1_CHAR(l_ins_ctr) := r_srcrecs.MEASURE1_CHAR(src_ctr);
  r_insrecs.MEASURE2_CHAR(l_ins_ctr) := r_srcrecs.MEASURE2_CHAR(src_ctr);
  r_insrecs.MEASURE3_CHAR(l_ins_ctr) := r_srcrecs.MEASURE3_CHAR(src_ctr);
  r_insrecs.MEASURE4_CHAR(l_ins_ctr) := r_srcrecs.MEASURE4_CHAR(src_ctr);
  r_insrecs.MEASURE5_CHAR(l_ins_ctr) := r_srcrecs.MEASURE5_CHAR(src_ctr);
  r_insrecs.MEASURE6_CHAR(l_ins_ctr) := r_srcrecs.MEASURE6_CHAR(src_ctr);
  r_insrecs.MEASURE7_CHAR(l_ins_ctr) := r_srcrecs.MEASURE7_CHAR(src_ctr);
  r_insrecs.MEASURE8_CHAR(l_ins_ctr) := r_srcrecs.MEASURE8_CHAR(src_ctr);
  r_insrecs.MEASURE9_CHAR(l_ins_ctr) := r_srcrecs.MEASURE9_CHAR(src_ctr);
  r_insrecs.MEASURE10_CHAR(l_ins_ctr) := r_srcrecs.MEASURE10_CHAR(src_ctr);
  r_insrecs.MEASURE_UOM(l_ins_ctr) := r_srcrecs.MEASURE_UOM(src_ctr);
exception
    when OTHERS then
        log_debug('ERROR ASSIGNING VALUES TO INSERT...');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end assign_val_to_ins;

procedure assign_upd_measure_values(src_ctr in PLS_INTEGER) is
begin
  r_updrecs.MEASURE1_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE1_NUMBER(src_ctr);
  r_updrecs.MEASURE2_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE2_NUMBER(src_ctr);
  r_updrecs.MEASURE3_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE3_NUMBER(src_ctr);
  r_updrecs.MEASURE4_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE4_NUMBER(src_ctr);
  r_updrecs.MEASURE5_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE5_NUMBER(src_ctr);
  r_updrecs.MEASURE6_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE6_NUMBER(src_ctr);
  r_updrecs.MEASURE7_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE7_NUMBER(src_ctr);
  r_updrecs.MEASURE8_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE8_NUMBER(src_ctr);
  r_updrecs.MEASURE9_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE9_NUMBER(src_ctr);
  r_updrecs.MEASURE10_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE10_NUMBER(src_ctr);
  r_updrecs.MEASURE11_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE11_NUMBER(src_ctr);
  r_updrecs.MEASURE12_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE12_NUMBER(src_ctr);
  r_updrecs.MEASURE13_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE13_NUMBER(src_ctr);
  r_updrecs.MEASURE14_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE14_NUMBER(src_ctr);
  r_updrecs.MEASURE15_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE15_NUMBER(src_ctr);
  r_updrecs.MEASURE16_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE16_NUMBER(src_ctr);
  r_updrecs.MEASURE17_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE17_NUMBER(src_ctr);
  r_updrecs.MEASURE18_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE18_NUMBER(src_ctr);
  r_updrecs.MEASURE19_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE19_NUMBER(src_ctr);
  r_updrecs.MEASURE20_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE20_NUMBER(src_ctr);
  r_updrecs.MEASURE21_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE21_NUMBER(src_ctr);
  r_updrecs.MEASURE22_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE22_NUMBER(src_ctr);
  r_updrecs.MEASURE23_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE23_NUMBER(src_ctr);
  r_updrecs.MEASURE24_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE24_NUMBER(src_ctr);
  r_updrecs.MEASURE25_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE25_NUMBER(src_ctr);
  r_updrecs.MEASURE26_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE26_NUMBER(src_ctr);
  r_updrecs.MEASURE27_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE27_NUMBER(src_ctr);
  r_updrecs.MEASURE28_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE28_NUMBER(src_ctr);
  r_updrecs.MEASURE29_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE29_NUMBER(src_ctr);
  r_updrecs.MEASURE30_NUMBER(l_upd_ctr) := r_srcrecs.MEASURE30_NUMBER(src_ctr);
  r_updrecs.MEASURE1_CHAR(l_upd_ctr) := r_srcrecs.MEASURE1_CHAR(src_ctr);
  r_updrecs.MEASURE2_CHAR(l_upd_ctr) := r_srcrecs.MEASURE2_CHAR(src_ctr);
  r_updrecs.MEASURE3_CHAR(l_upd_ctr) := r_srcrecs.MEASURE3_CHAR(src_ctr);
  r_updrecs.MEASURE4_CHAR(l_upd_ctr) := r_srcrecs.MEASURE4_CHAR(src_ctr);
  r_updrecs.MEASURE5_CHAR(l_upd_ctr) := r_srcrecs.MEASURE5_CHAR(src_ctr);
  r_updrecs.MEASURE6_CHAR(l_upd_ctr) := r_srcrecs.MEASURE6_CHAR(src_ctr);
  r_updrecs.MEASURE7_CHAR(l_upd_ctr) := r_srcrecs.MEASURE7_CHAR(src_ctr);
  r_updrecs.MEASURE8_CHAR(l_upd_ctr) := r_srcrecs.MEASURE8_CHAR(src_ctr);
  r_updrecs.MEASURE9_CHAR(l_upd_ctr) := r_srcrecs.MEASURE9_CHAR(src_ctr);
  r_updrecs.MEASURE10_CHAR(l_upd_ctr) := r_srcrecs.MEASURE10_CHAR(src_ctr);
  r_updrecs.MEASURE_UOM(l_upd_ctr) := r_srcrecs.MEASURE_UOM(src_ctr);
exception
    when OTHERS then
        log_debug('ERROR ASSIGNING VALUES TO UPDATE...');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end assign_upd_measure_values;

procedure delete_ins_rec_data is
begin
    r_insrecs.ORD_LEVEL_VALUE.delete;
    r_insrecs.ADJ_LEVEL_VALUE.delete;
    r_insrecs.TIME_LEVEL_VALUE.delete;
    r_insrecs.CUS_LEVEL_VALUE.delete;
    r_insrecs.GEO_LEVEL_VALUE.delete;
    r_insrecs.PRD_LEVEL_VALUE.delete;
    r_insrecs.REP_LEVEL_VALUE.delete;
    r_insrecs.CHN_LEVEL_VALUE.delete;
    r_insrecs.ORG_LEVEL_VALUE.delete;
    r_insrecs.USR1_LEVEL_VALUE.delete;
    r_insrecs.USR2_LEVEL_VALUE.delete;
    r_insrecs.USR3_LEVEL_VALUE.delete;
    r_insrecs.USR4_LEVEL_VALUE.delete;
    r_insrecs.USR5_LEVEL_VALUE.delete;
    r_insrecs.MEASURE1_NUMBER.delete;
    r_insrecs.MEASURE2_NUMBER.delete;
    r_insrecs.MEASURE3_NUMBER.delete;
    r_insrecs.MEASURE4_NUMBER.delete;
    r_insrecs.MEASURE5_NUMBER.delete;
    r_insrecs.MEASURE6_NUMBER.delete;
    r_insrecs.MEASURE7_NUMBER.delete;
    r_insrecs.MEASURE8_NUMBER.delete;
    r_insrecs.MEASURE9_NUMBER.delete;
    r_insrecs.MEASURE10_NUMBER.delete;
    r_insrecs.MEASURE11_NUMBER.delete;
    r_insrecs.MEASURE12_NUMBER.delete;
    r_insrecs.MEASURE13_NUMBER.delete;
    r_insrecs.MEASURE14_NUMBER.delete;
    r_insrecs.MEASURE15_NUMBER.delete;
    r_insrecs.MEASURE16_NUMBER.delete;
    r_insrecs.MEASURE17_NUMBER.delete;
    r_insrecs.MEASURE18_NUMBER.delete;
    r_insrecs.MEASURE19_NUMBER.delete;
    r_insrecs.MEASURE20_NUMBER.delete;
    r_insrecs.MEASURE21_NUMBER.delete;
    r_insrecs.MEASURE22_NUMBER.delete;
    r_insrecs.MEASURE23_NUMBER.delete;
    r_insrecs.MEASURE24_NUMBER.delete;
    r_insrecs.MEASURE25_NUMBER.delete;
    r_insrecs.MEASURE26_NUMBER.delete;
    r_insrecs.MEASURE27_NUMBER.delete;
    r_insrecs.MEASURE28_NUMBER.delete;
    r_insrecs.MEASURE29_NUMBER.delete;
    r_insrecs.MEASURE30_NUMBER.delete;
    r_insrecs.MEASURE1_CHAR.delete;
    r_insrecs.MEASURE2_CHAR.delete;
    r_insrecs.MEASURE3_CHAR.delete;
    r_insrecs.MEASURE4_CHAR.delete;
    r_insrecs.MEASURE5_CHAR.delete;
    r_insrecs.MEASURE6_CHAR.delete;
    r_insrecs.MEASURE7_CHAR.delete;
    r_insrecs.MEASURE8_CHAR.delete;
    r_insrecs.MEASURE9_CHAR.delete;
    r_insrecs.MEASURE10_CHAR.delete;
    r_insrecs.MEASURE_UOM.delete;
exception
    when OTHERS then
        log_debug('ERROR CLEARING INSERT REC BUFFER...');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end delete_ins_rec_data;

procedure delete_upd_rec_data is
begin
    r_updrecs.MEASURE_VALUE_ID.delete;
    r_updrecs.MEASURE1_NUMBER.delete;
    r_updrecs.MEASURE2_NUMBER.delete;
    r_updrecs.MEASURE3_NUMBER.delete;
    r_updrecs.MEASURE4_NUMBER.delete;
    r_updrecs.MEASURE5_NUMBER.delete;
    r_updrecs.MEASURE6_NUMBER.delete;
    r_updrecs.MEASURE7_NUMBER.delete;
    r_updrecs.MEASURE8_NUMBER.delete;
    r_updrecs.MEASURE9_NUMBER.delete;
    r_updrecs.MEASURE10_NUMBER.delete;
    r_updrecs.MEASURE11_NUMBER.delete;
    r_updrecs.MEASURE12_NUMBER.delete;
    r_updrecs.MEASURE13_NUMBER.delete;
    r_updrecs.MEASURE14_NUMBER.delete;
    r_updrecs.MEASURE15_NUMBER.delete;
    r_updrecs.MEASURE16_NUMBER.delete;
    r_updrecs.MEASURE17_NUMBER.delete;
    r_updrecs.MEASURE18_NUMBER.delete;
    r_updrecs.MEASURE19_NUMBER.delete;
    r_updrecs.MEASURE20_NUMBER.delete;
    r_updrecs.MEASURE21_NUMBER.delete;
    r_updrecs.MEASURE22_NUMBER.delete;
    r_updrecs.MEASURE23_NUMBER.delete;
    r_updrecs.MEASURE24_NUMBER.delete;
    r_updrecs.MEASURE25_NUMBER.delete;
    r_updrecs.MEASURE26_NUMBER.delete;
    r_updrecs.MEASURE27_NUMBER.delete;
    r_updrecs.MEASURE28_NUMBER.delete;
    r_updrecs.MEASURE29_NUMBER.delete;
    r_updrecs.MEASURE30_NUMBER.delete;
    r_updrecs.MEASURE1_CHAR.delete;
    r_updrecs.MEASURE2_CHAR.delete;
    r_updrecs.MEASURE3_CHAR.delete;
    r_updrecs.MEASURE4_CHAR.delete;
    r_updrecs.MEASURE5_CHAR.delete;
    r_updrecs.MEASURE6_CHAR.delete;
    r_updrecs.MEASURE7_CHAR.delete;
    r_updrecs.MEASURE8_CHAR.delete;
    r_updrecs.MEASURE9_CHAR.delete;
    r_updrecs.MEASURE10_CHAR.delete;
    r_updrecs.MEASURE_UOM.delete;
exception
    when OTHERS then
        log_debug('ERROR CLEARING UPDATE REC BUFFER...');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end delete_upd_rec_data;

procedure insert_measdata is
begin
    forall i in r_insrecs.ORD_LEVEL_VALUE.FIRST..r_insrecs.ORD_LEVEL_VALUE.LAST
      insert into QPR_MEASURE_DATA(MEASURE_VALUE_ID,
                                  INSTANCE_ID,
                                  MEASURE_TYPE_CODE,
                                  ORD_LEVEL_VALUE,
                                  ADJ_LEVEL_VALUE,
                                  TIME_LEVEL_VALUE,
                                  CUS_LEVEL_VALUE,
                                  GEO_LEVEL_VALUE,
                                  PRD_LEVEL_VALUE,
                                  REP_LEVEL_VALUE,
                                  CHN_LEVEL_VALUE,
                                  ORG_LEVEL_VALUE,
                                  USR1_LEVEL_VALUE,
                                  USR2_LEVEL_VALUE,
                                  USR3_LEVEL_VALUE,
                                  USR4_LEVEL_VALUE,
                                  USR5_LEVEL_VALUE,
                                  MEASURE1_NUMBER ,
                                  MEASURE2_NUMBER ,
                                  MEASURE3_NUMBER ,
                                  MEASURE4_NUMBER ,
                                  MEASURE5_NUMBER ,
                                  MEASURE6_NUMBER ,
                                  MEASURE7_NUMBER ,
                                  MEASURE8_NUMBER ,
                                  MEASURE9_NUMBER ,
                                  MEASURE10_NUMBER ,
                                  MEASURE11_NUMBER ,
                                  MEASURE12_NUMBER ,
                                  MEASURE13_NUMBER ,
                                  MEASURE14_NUMBER ,
                                  MEASURE15_NUMBER ,
                                  MEASURE16_NUMBER ,
                                  MEASURE17_NUMBER ,
                                  MEASURE18_NUMBER ,
                                  MEASURE19_NUMBER ,
                                  MEASURE20_NUMBER ,
                                  MEASURE21_NUMBER ,
                                  MEASURE22_NUMBER ,
                                  MEASURE23_NUMBER ,
                                  MEASURE24_NUMBER ,
                                  MEASURE25_NUMBER ,
                                  MEASURE26_NUMBER ,
                                  MEASURE27_NUMBER ,
                                  MEASURE28_NUMBER ,
                                  MEASURE29_NUMBER ,
                                  MEASURE30_NUMBER ,
                                  MEASURE1_CHAR ,
                                  MEASURE2_CHAR ,
                                  MEASURE3_CHAR ,
                                  MEASURE4_CHAR ,
                                  MEASURE5_CHAR ,
                                  MEASURE6_CHAR ,
                                  MEASURE7_CHAR ,
                                  MEASURE8_CHAR ,
                                  MEASURE9_CHAR ,
                                  MEASURE10_CHAR ,
                                  MEASURE_UOM,
                                  CREATION_DATE ,
                                  CREATED_BY ,
                                  LAST_UPDATE_DATE ,
                                  LAST_UPDATED_BY ,
                                  LAST_UPDATE_LOGIN ,
                                  PROGRAM_APPLICATION_ID,
                                  PROGRAM_ID,
                                  REQUEST_ID)
                    values(QPR_MEASURE_DATA_S.nextval,
                            g_instance_id,
                            g_meas_type,
                            r_insrecs.ORD_LEVEL_VALUE(i),
                            r_insrecs.ADJ_LEVEL_VALUE(i),
                            r_insrecs.TIME_LEVEL_VALUE(i),
                            r_insrecs.CUS_LEVEL_VALUE(i),
                            r_insrecs.GEO_LEVEL_VALUE(i),
                            r_insrecs.PRD_LEVEL_VALUE(i),
                            r_insrecs.REP_LEVEL_VALUE(i),
                            r_insrecs.CHN_LEVEL_VALUE(i),
                            r_insrecs.ORG_LEVEL_VALUE(i),
                            r_insrecs.USR1_LEVEL_VALUE(i),
                            r_insrecs.USR2_LEVEL_VALUE(i),
                            r_insrecs.USR3_LEVEL_VALUE(i),
                            r_insrecs.USR4_LEVEL_VALUE(i),
                            r_insrecs.USR5_LEVEL_VALUE(i),
                            r_insrecs.MEASURE1_NUMBER(i),
                            r_insrecs.MEASURE2_NUMBER(i),
                            r_insrecs.MEASURE3_NUMBER(i),
                            r_insrecs.MEASURE4_NUMBER(i),
                            r_insrecs.MEASURE5_NUMBER(i),
                            r_insrecs.MEASURE6_NUMBER(i),
                            r_insrecs.MEASURE7_NUMBER(i),
                            r_insrecs.MEASURE8_NUMBER(i),
                            r_insrecs.MEASURE9_NUMBER(i),
                            r_insrecs.MEASURE10_NUMBER(i),
                            r_insrecs.MEASURE11_NUMBER(i),
                            r_insrecs.MEASURE12_NUMBER(i),
                            r_insrecs.MEASURE13_NUMBER(i),
                            r_insrecs.MEASURE14_NUMBER(i),
                            r_insrecs.MEASURE15_NUMBER(i),
                            r_insrecs.MEASURE16_NUMBER(i),
                            r_insrecs.MEASURE17_NUMBER(i),
                            r_insrecs.MEASURE18_NUMBER(i),
                            r_insrecs.MEASURE19_NUMBER(i),
                            r_insrecs.MEASURE20_NUMBER(i),
                            r_insrecs.MEASURE21_NUMBER(i),
                            r_insrecs.MEASURE22_NUMBER(i),
                            r_insrecs.MEASURE23_NUMBER(i),
                            r_insrecs.MEASURE24_NUMBER(i),
                            r_insrecs.MEASURE25_NUMBER(i),
                            r_insrecs.MEASURE26_NUMBER(i),
                            r_insrecs.MEASURE27_NUMBER(i),
                            r_insrecs.MEASURE28_NUMBER(i),
                            r_insrecs.MEASURE29_NUMBER(i),
                            r_insrecs.MEASURE30_NUMBER(i),
                            r_insrecs.MEASURE1_CHAR(i),
                            r_insrecs.MEASURE2_CHAR(i),
                            r_insrecs.MEASURE3_CHAR(i),
                            r_insrecs.MEASURE4_CHAR(i),
                            r_insrecs.MEASURE5_CHAR(i),
                            r_insrecs.MEASURE6_CHAR(i),
                            r_insrecs.MEASURE7_CHAR(i),
                            r_insrecs.MEASURE8_CHAR(i),
                            r_insrecs.MEASURE9_CHAR(i),
                            r_insrecs.MEASURE10_CHAR(i),
                            r_insrecs.MEASURE_UOM(i),
                            g_sys_date,
                            g_user_id,
                            g_sys_date,
                            g_user_id,
                            g_login_id,
                            g_prg_appl_id,
                            g_prg_id,
                            g_request_id);
exception
    when OTHERS then
      log_debug('ERROR INSERTING FACT DATA...');
      log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_measdata;

procedure update_measdata is
begin
     forall i in r_updrecs.MEASURE_VALUE_ID.FIRST..r_updrecs.MEASURE_VALUE_ID.LAST
      update QPR_MEASURE_DATA set
                              MEASURE1_NUMBER = r_updrecs.MEASURE1_NUMBER(i),
                              MEASURE2_NUMBER = r_updrecs.MEASURE2_NUMBER(i),
                              MEASURE3_NUMBER = r_updrecs.MEASURE3_NUMBER(i),
                              MEASURE4_NUMBER = r_updrecs.MEASURE4_NUMBER(i),
                              MEASURE5_NUMBER = r_updrecs.MEASURE5_NUMBER(i),
                              MEASURE6_NUMBER = r_updrecs.MEASURE6_NUMBER(i),
                              MEASURE7_NUMBER = r_updrecs.MEASURE7_NUMBER(i),
                              MEASURE8_NUMBER = r_updrecs.MEASURE8_NUMBER(i),
                              MEASURE9_NUMBER = r_updrecs.MEASURE9_NUMBER(i),
                              MEASURE10_NUMBER = r_updrecs.MEASURE10_NUMBER(i),
                              MEASURE11_NUMBER = r_updrecs.MEASURE11_NUMBER(i),
                              MEASURE12_NUMBER = r_updrecs.MEASURE12_NUMBER(i),
                              MEASURE13_NUMBER = r_updrecs.MEASURE13_NUMBER(i),
                              MEASURE14_NUMBER = r_updrecs.MEASURE14_NUMBER(i),
                              MEASURE15_NUMBER = r_updrecs.MEASURE15_NUMBER(i),
                              MEASURE16_NUMBER = r_updrecs.MEASURE16_NUMBER(i),
                              MEASURE17_NUMBER = r_updrecs.MEASURE17_NUMBER(i),
                              MEASURE18_NUMBER = r_updrecs.MEASURE18_NUMBER(i),
                              MEASURE19_NUMBER = r_updrecs.MEASURE19_NUMBER(i),
                              MEASURE20_NUMBER = r_updrecs.MEASURE20_NUMBER(i),
                              MEASURE21_NUMBER = r_updrecs.MEASURE21_NUMBER(i),
                              MEASURE22_NUMBER = r_updrecs.MEASURE22_NUMBER(i),
                              MEASURE23_NUMBER = r_updrecs.MEASURE23_NUMBER(i),
                              MEASURE24_NUMBER = r_updrecs.MEASURE24_NUMBER(i),
                              MEASURE25_NUMBER = r_updrecs.MEASURE25_NUMBER(i),
                              MEASURE26_NUMBER = r_updrecs.MEASURE26_NUMBER(i),
                              MEASURE27_NUMBER = r_updrecs.MEASURE27_NUMBER(i),
                              MEASURE28_NUMBER = r_updrecs.MEASURE28_NUMBER(i),
                              MEASURE29_NUMBER = r_updrecs.MEASURE29_NUMBER(i),
                              MEASURE30_NUMBER = r_updrecs.MEASURE30_NUMBER(i),
                              MEASURE1_CHAR = r_updrecs.MEASURE1_CHAR(i),
                              MEASURE2_CHAR = r_updrecs.MEASURE2_CHAR(i),
                              MEASURE3_CHAR = r_updrecs.MEASURE3_CHAR(i),
                              MEASURE4_CHAR = r_updrecs.MEASURE4_CHAR(i),
                              MEASURE5_CHAR = r_updrecs.MEASURE5_CHAR(i),
                              MEASURE6_CHAR = r_updrecs.MEASURE6_CHAR(i),
                              MEASURE7_CHAR = r_updrecs.MEASURE7_CHAR(i),
                              MEASURE8_CHAR = r_updrecs.MEASURE8_CHAR(i),
                              MEASURE9_CHAR = r_updrecs.MEASURE9_CHAR(i),
                              MEASURE10_CHAR = r_updrecs.MEASURE10_CHAR(i),
                              MEASURE_UOM = r_updrecs.MEASURE_UOM(i),
                              LAST_UPDATE_DATE = g_sys_date,
                              LAST_UPDATED_BY = g_user_id,
                              LAST_UPDATE_LOGIN = g_login_id,
                              PROGRAM_APPLICATION_ID = g_prg_appl_id,
                              PROGRAM_ID = g_prg_id,
                              REQUEST_ID = g_request_id
        where MEASURE_VALUE_ID = r_updrecs.MEASURE_VALUE_ID(i);
exception
    when OTHERS then
      log_debug( 'ERROR UPDATING FACT DATA... ');
      log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end update_measdata;

procedure insert_update_meas_data(p_date_from in varchar2,
                                  p_date_to in varchar2,
                                  p_sql in varchar2) is

    bfound boolean := false;
    bupdate boolean := false;
    nrows number := 1000;
    c_srcdata SYS_REFCURSOR;
    date_from date;
    date_to date;

--    order of fields in the order by clause is important and must match
--    the order of fields that is being selected from the source. This is done
--    to reduce the number of iterations while cheking for the records to be
--    updated.
    cursor c_meas_data(d1 date, d2 date, ins_id number, meas_tname varchar2) is
                                      select ORD_LEVEL_VALUE,
                                            TIME_LEVEL_VALUE, CUS_LEVEL_VALUE,
                                            GEO_LEVEL_VALUE, ORG_LEVEL_VALUE,
                                            REP_LEVEL_VALUE, CHN_LEVEL_VALUE,
                                            PRD_LEVEL_VALUE, ADJ_LEVEL_VALUE,
                                            USR1_LEVEL_VALUE, USR2_LEVEL_VALUE,
                                            USR3_LEVEL_VALUE, USR4_LEVEL_VALUE,
                                            USR5_LEVEL_VALUE, MEASURE_VALUE_ID
                                      from QPR_MEASURE_DATA
                                      where TIME_LEVEL_VALUE between d1 and d2
                                      and INSTANCE_ID = ins_id
                                      and MEASURE_TYPE_CODE = meas_tname
                                      order by ORD_LEVEL_VALUE, ADJ_LEVEL_VALUE,
                                      TIME_LEVEL_VALUE,CUS_LEVEL_VALUE,
                                      GEO_LEVEL_VALUE,
                                      PRD_LEVEL_VALUE, REP_LEVEL_VALUE,
                                      CHN_LEVEL_VALUE, ORG_LEVEL_VALUE,
                                      USR1_LEVEL_VALUE,USR2_LEVEL_VALUE,
                                      USR3_LEVEL_VALUE, USR4_LEVEL_VALUE,
                                      USR5_LEVEL_VALUE;
begin

   date_from := fnd_date.canonical_to_date(p_date_from);
   date_to := fnd_date.canonical_to_date(p_date_to);

   open c_meas_data(date_from,date_to,g_instance_id, g_meas_type);
    loop
        fetch c_meas_data bulk collect into r_meas_data;
        exit when c_meas_data%notfound;
    end loop;
    close c_meas_data;

    open c_srcdata for p_sql using date_from, date_to;
    loop
      fetch c_srcdata bulk collect into r_srcrecs limit nrows;
      exit when r_srcrecs.ORD_LEVEL_VALUE.count = 0;

      delete_ins_rec_data();
      delete_upd_rec_data();

      l_ins_ctr := 1;
      l_upd_ctr := 1;
      for i in r_srcrecs.ORD_LEVEL_VALUE.first..r_srcrecs.ORD_LEVEL_VALUE.last
      loop
        bfound := false;
        bupdate := false;
        if r_meas_data.ORD_LEVEL_VALUE.count = 0 then
            assign_val_to_ins(i);
            l_ins_ctr := l_ins_ctr + 1;
        else
            for j in r_meas_data.ORD_LEVEL_VALUE.first..
                                        r_meas_data.ORD_LEVEL_VALUE.last loop
              if (r_meas_data.ORD_LEVEL_VALUE.exists(j)) then
                case g_meas_type
                when MEAS_TYPE_SALES then
                  if (to_char(r_srcrecs.ORD_LEVEL_VALUE(i)) =
                                                r_meas_data.ORD_LEVEL_VALUE(j))
                  and (r_srcrecs.TIME_LEVEL_VALUE(i) =
                                                r_meas_data.TIME_LEVEL_VALUE(j))
                  then
                      bupdate := true;
                  end if;
                when MEAS_TYPE_ADJ then
                   if (to_char(r_srcrecs.ORD_LEVEL_VALUE(i)) =
                                                r_meas_data.ORD_LEVEL_VALUE(j))
                  and (to_char(r_srcrecs.ADJ_LEVEL_VALUE(i)) =
                                                r_meas_data.ADJ_LEVEL_VALUE(j))
                  and (r_srcrecs.TIME_LEVEL_VALUE(i) =
                                                r_meas_data.TIME_LEVEL_VALUE(j))
                  then
                      bupdate := true;
                  end if;
                when MEAS_TYPE_OFFADJ then
                   if (to_char(r_srcrecs.ORD_LEVEL_VALUE(i)) =
                                                r_meas_data.ORD_LEVEL_VALUE(j))
                  and (to_char(r_srcrecs.ADJ_LEVEL_VALUE(i)) =
                                                r_meas_data.ADJ_LEVEL_VALUE(j))
                  and (r_srcrecs.TIME_LEVEL_VALUE(i) =
                                                r_meas_data.TIME_LEVEL_VALUE(j))
                  then
                      bupdate := true;
                  end if;
                else
                  if (to_char(r_srcrecs.ORD_LEVEL_VALUE(i)) =
                                                r_meas_data.ORD_LEVEL_VALUE(j))
                  and (to_char(r_srcrecs.ADJ_LEVEL_VALUE(i)) =
                                                r_meas_data.ADJ_LEVEL_VALUE(j))
                  and (r_srcrecs.TIME_LEVEL_VALUE(i) =
                                                r_meas_data.TIME_LEVEL_VALUE(j))
                  and (to_char(r_srcrecs.CUS_LEVEL_VALUE(i)) =
                                                r_meas_data.CUS_LEVEL_VALUE(j))
                  and (to_char(r_srcrecs.GEO_LEVEL_VALUE(i)) =
                                                r_meas_data.GEO_LEVEL_VALUE(j))
                  and ( to_char(r_srcrecs.PRD_LEVEL_VALUE(i)) =
                                                r_meas_data.PRD_LEVEL_VALUE(j))
                  and ( to_char(r_srcrecs.REP_LEVEL_VALUE(i)) =
                                                r_meas_data.REP_LEVEL_VALUE(j))
                  and ( to_char(r_srcrecs.CHN_LEVEL_VALUE(i)) =
                                                r_meas_data.CHN_LEVEL_VALUE(j))
                  and ( to_char(r_srcrecs.ORG_LEVEL_VALUE(i)) =
                                                r_meas_data.ORG_LEVEL_VALUE(j))
                  and (r_srcrecs.USR1_LEVEL_VALUE(i) =
                                                r_meas_data.USR1_LEVEL_VALUE(j))
                  and (r_srcrecs.USR2_LEVEL_VALUE(i) =
                                                r_meas_data.USR2_LEVEL_VALUE(j))
                  and (r_srcrecs.USR3_LEVEL_VALUE(i) =
                                                r_meas_data.USR3_LEVEL_VALUE(j))
                  and (r_srcrecs.USR4_LEVEL_VALUE(i) =
                                                r_meas_data.USR4_LEVEL_VALUE(j))
                  and (r_srcrecs.USR5_LEVEL_VALUE(i) =
                                                r_meas_data.USR5_LEVEL_VALUE(j))
                  then
                    bupdate := true;
                  end if;
                end case;

                if bupdate=true then
                  r_updrecs.MEASURE_VALUE_ID(l_upd_ctr) :=
                                              r_meas_data.MEASURE_VALUE_ID(j);
                  assign_upd_measure_values(i);
                  l_upd_ctr := l_upd_ctr + 1;
                  bfound := true;
--                Deleting the matched measure data so during the next iteration
--                those values can be skipped.
                  r_meas_data.ORD_LEVEL_VALUE.delete(j);
                  r_meas_data.ADJ_LEVEL_VALUE.delete(j);
                  r_meas_data.TIME_LEVEL_VALUE.delete(j);
                  r_meas_data.CUS_LEVEL_VALUE.delete(j);
                  r_meas_data.GEO_LEVEL_VALUE.delete(j);
                  r_meas_data.PRD_LEVEL_VALUE.delete(j);
                  r_meas_data.REP_LEVEL_VALUE.delete(j);
                  r_meas_data.CHN_LEVEL_VALUE.delete(j);
                  r_meas_data.ORG_LEVEL_VALUE.delete(j);
                  r_meas_data.USR1_LEVEL_VALUE.delete(j);
                  r_meas_data.USR2_LEVEL_VALUE.delete(j);
                  r_meas_data.USR3_LEVEL_VALUE.delete(j);
                  r_meas_data.USR4_LEVEL_VALUE.delete(j);
                  r_meas_data.USR5_LEVEL_VALUE.delete(j);
                  r_meas_data.MEASURE_VALUE_ID.delete(j);
                  exit;
                end if;
              end if;
            end loop;
            if bfound = false then
              assign_val_to_ins(i);
              l_ins_ctr := l_ins_ctr + 1;
            end if;
        end if;
      end loop;

      if r_insrecs.ORD_LEVEL_VALUE.count > 0 then
        log_debug('Inserted record count: ' || r_insrecs.ORD_LEVEL_VALUE.count);
        insert_measdata;
      end if;

      if r_updrecs.MEASURE_VALUE_ID.count >0 then
        log_debug('Updated record count: ' || r_updrecs.MEASURE_VALUE_ID.count);
        update_measdata;
      end if;
    end loop;
    close c_srcdata;
exception
    when OTHERS then
      log_debug('ERROR INSERTING/UPDATING FACT DATA... ');
      log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_update_meas_data;

function get_deal_sql(p_src_tbl_name in varchar2, p_tgt_tbl_name in varchar2)
                                              return varchar2 is
  s_sql varchar2(20000):= '';
  b_ret boolean;
  s_status varchar2(100);
  s_industry varchar2(100);
  s_table_owner varchar2(100);
  t_src_trg_cols char_type;
  t_deal_tbl_def char240_type;
begin
  b_ret := FND_INSTALLATION.GET_APP_INFO('QPR', s_status, s_industry,
                                         s_table_owner);

  select column_name bulk collect into t_deal_tbl_def
  from all_tab_columns
  where table_name = p_tgt_tbl_name
  and owner = s_table_owner order by column_id;

  if t_deal_tbl_def.count = 0 then
   raise NO_TBL_DEF;
  end if;

  for i in g_src_cols.first..g_src_cols.last loop
    t_src_trg_cols(g_trg_cols(i)) := g_src_cols(i);
  end loop;
  s_sql := 'select ';
  for i in t_deal_tbl_def.first..t_deal_tbl_def.last loop
    if t_src_trg_cols.exists(t_deal_tbl_def(i)) then
      s_sql := s_sql || t_src_trg_cols(t_deal_tbl_def(i));
    else
      s_sql := s_sql || ' null ';
    end if;
    if i < t_deal_tbl_def.count then
      s_sql := s_sql || ',';
    end if;
  end loop;
  if s_sql is not null then
    s_sql := s_sql || ' from ' || p_src_tbl_name;
  end if;
  s_sql := s_sql || ' where quote_header_id = :1';
  log_debug(s_sql);
  return s_sql;
exception
    when NO_TBL_DEF then
        log_debug(p_tgt_tbl_name || ' definition not found');
        raise;
    when OTHERS then
        log_debug('ERROR IN FORMING DEAL SQL');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end get_deal_sql;

function insert_update_deal_hdr(
                                 p_header_id in number,
                                 p_sql in varchar2) return number is
b_insert boolean := false;
l_req_int_hdr_id number;
s_status varchar2(1);
c_get_hdr SYS_REFCURSOR;
r_hdr QPR_PN_INT_HEADERS%rowtype;
begin
  log_debug('In deal header method...');
  open c_get_hdr for p_sql using p_header_id;
  fetch c_get_hdr into r_hdr;
  close c_get_hdr;

  if r_hdr.SOURCE_REF_HEADER_ID is null then
     log_debug('Quote Header not found.');
     return(0);
  end if;

  begin
    select PN_INT_HEADER_ID, PN_REQ_HEADER_STATUS_FLAG
    into l_req_int_hdr_id, s_status
    from qpr_pn_int_headers
    where source_ref_header_id = p_header_id
    and instance_id = g_instance_id
    and source_id = g_source_id
    and source_ref_header_short_desc = g_quote_hdr_sd;
  exception
    when NO_DATA_FOUND then
      b_insert := true;
  end;

  if b_insert= true then
    log_debug('Inserting deal interface header...');
    insert into qpr_pn_int_headers(
                  PN_INT_HEADER_ID,
                  INSTANCE_ID,
                  SOURCE_REF_HEADER_ID,
                  SOURCE_REF_HEADER_SHORT_DESC,
                  SOURCE_REF_HEADER_LONG_DESC,
		  SOURCE_ID, SOURCE_SHORT_DESC, SOURCE_LONG_DESC,
                  CUSTOMER_ID, CUSTOMER_SHORT_DESC,CUSTOMER_LONG_DESC,
		  INVOICE_TO_PARTY_SITE_ID,
                  INVOICE_TO_PARTY_SITE_ADDRESS,
                  SALES_REP_ID, SALES_REP_SHORT_DESC,SALES_REP_LONG_DESC,
                  SALES_REP_EMAIL_ADDRESS,
                  SALES_CHANNEL_CODE,SALES_CHANNEL_SHORT_DESC,
                  SALES_CHANNEL_LONG_DESC,
                  FREIGHT_TERMS_CODE,FREIGHT_TERMS_SHORT_DESC,
                  FREIGHT_TERMS_LONG_DESC,
                  CURRENCY_CODE, CURRENCY_SHORT_DESC,CURRENCY_LONG_DESC,
                  PN_REQ_EXPIRY_DATE, PN_REQ_HEADER_STATUS_FLAG,
                  COMMENTS, ADDITIONAL_INFORMATION, PN_REQ_HEADER_CREATION_DATE,
                  MEASURE1_NUMBER, MEASURE2_NUMBER,MEASURE3_NUMBER,
                  MEASURE4_NUMBER, MEASURE5_NUMBER,MEASURE6_NUMBER,
                  MEASURE7_NUMBER, MEASURE8_NUMBER,MEASURE9_NUMBER,
                  MEASURE10_NUMBER,
                  MEASURE1_CHAR, MEASURE2_CHAR,MEASURE3_CHAR,
                  MEASURE4_CHAR, MEASURE5_CHAR,MEASURE6_CHAR,
                  MEASURE7_CHAR, MEASURE8_CHAR,MEASURE9_CHAR,
                  MEASURE10_CHAR,
                  REQUEST_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                  LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                  PROGRAM_APPLICATION_ID,PROGRAM_ID)
    values(qpr_pn_int_headers_s.nextval,
             g_instance_id,
             r_hdr.SOURCE_REF_HEADER_ID,
             r_hdr.SOURCE_REF_HEADER_SHORT_DESC,
             r_hdr.SOURCE_REF_HEADER_LONG_DESC,
             r_hdr.SOURCE_ID,
             r_hdr.SOURCE_SHORT_DESC,
             r_hdr.SOURCE_LONG_DESC,
             r_hdr.CUSTOMER_ID, r_hdr.CUSTOMER_SHORT_DESC,
             r_hdr.CUSTOMER_LONG_DESC,
	     r_hdr.INVOICE_TO_PARTY_SITE_ID,
             r_hdr.INVOICE_TO_PARTY_SITE_ADDRESS,
             r_hdr.SALES_REP_ID, r_hdr.SALES_REP_SHORT_DESC,
             r_hdr.SALES_REP_LONG_DESC,
             r_hdr.SALES_REP_EMAIL_ADDRESS,
             r_hdr.SALES_CHANNEL_CODE,r_hdr.SALES_CHANNEL_SHORT_DESC,
             r_hdr.SALES_CHANNEL_LONG_DESC,
             r_hdr.FREIGHT_TERMS_CODE,r_hdr.FREIGHT_TERMS_SHORT_DESC,
             r_hdr.FREIGHT_TERMS_LONG_DESC,
             r_hdr.CURRENCY_CODE, r_hdr.CURRENCY_SHORT_DESC,
             r_hdr.CURRENCY_LONG_DESC,
             r_hdr.PN_REQ_EXPIRY_DATE, 'I', r_hdr.COMMENTS,
             r_hdr.ADDITIONAL_INFORMATION,
             /*g_sys_date*/ r_hdr.PN_REQ_HEADER_CREATION_DATE,
                  r_hdr.MEASURE1_NUMBER, r_hdr.MEASURE2_NUMBER,
                  r_hdr.MEASURE3_NUMBER,
                  r_hdr.MEASURE4_NUMBER, r_hdr.MEASURE5_NUMBER,
                  r_hdr.MEASURE6_NUMBER,
                  r_hdr.MEASURE7_NUMBER, r_hdr.MEASURE8_NUMBER,
                  r_hdr.MEASURE9_NUMBER,
                  r_hdr.MEASURE10_NUMBER,
                  r_hdr.MEASURE1_CHAR, r_hdr.MEASURE2_CHAR,r_hdr.MEASURE3_CHAR,
                  r_hdr.MEASURE4_CHAR, r_hdr.MEASURE5_CHAR,r_hdr.MEASURE6_CHAR,
                  r_hdr.MEASURE7_CHAR, r_hdr.MEASURE8_CHAR,r_hdr.MEASURE9_CHAR,
                  r_hdr.MEASURE10_CHAR,
	     g_request_id, g_sys_date, g_user_id, g_sys_date,
             g_user_id, g_login_id, g_prg_appl_id, g_prg_id)
    returning PN_INT_HEADER_ID into l_req_int_hdr_id;
    log_debug('PN_INT_HEADER_ID:' || l_req_int_hdr_id);
  else
    if s_status <> 'P' then
      log_debug('Updating deal interface header...');
      update qpr_pn_int_headers set
           INSTANCE_ID = g_instance_id,
           SOURCE_REF_HEADER_SHORT_DESC = r_hdr.SOURCE_REF_HEADER_SHORT_DESC,
           SOURCE_REF_HEADER_LONG_DESC = r_hdr.SOURCE_REF_HEADER_LONG_DESC,
           CUSTOMER_ID = r_hdr.CUSTOMER_ID,
           CUSTOMER_SHORT_DESC= r_hdr.CUSTOMER_SHORT_DESC,
           CUSTOMER_LONG_DESC = r_hdr.CUSTOMER_LONG_DESC,
           INVOICE_TO_PARTY_SITE_ID = r_hdr.INVOICE_TO_PARTY_SITE_ID,
           INVOICE_TO_PARTY_SITE_ADDRESS = r_hdr.INVOICE_TO_PARTY_SITE_ADDRESS,
           SALES_REP_ID = r_hdr.SALES_REP_ID,
           SALES_REP_SHORT_DESC = r_hdr.SALES_REP_SHORT_DESC,
           SALES_REP_LONG_DESC = r_hdr.SALES_REP_LONG_DESC,
           SALES_REP_EMAIL_ADDRESS = r_hdr.SALES_REP_EMAIL_ADDRESS,
           SALES_CHANNEL_CODE = r_hdr.SALES_CHANNEL_CODE,
           SALES_CHANNEL_SHORT_DESC = r_hdr.SALES_CHANNEL_SHORT_DESC,
           SALES_CHANNEL_LONG_DESC = r_hdr.SALES_CHANNEL_LONG_DESC,
           FREIGHT_TERMS_CODE = r_hdr.FREIGHT_TERMS_CODE,
           FREIGHT_TERMS_SHORT_DESC = r_hdr.FREIGHT_TERMS_SHORT_DESC,
           FREIGHT_TERMS_LONG_DESC = r_hdr.FREIGHT_TERMS_LONG_DESC,
           CURRENCY_CODE = r_hdr.CURRENCY_CODE,
           CURRENCY_SHORT_DESC = r_hdr.CURRENCY_SHORT_DESC,
           CURRENCY_LONG_DESC = r_hdr.CURRENCY_LONG_DESC,
           PN_REQ_EXPIRY_DATE = r_hdr.PN_REQ_EXPIRY_DATE,
           COMMENTS = r_hdr.COMMENTS,
           ADDITIONAL_INFORMATION = r_hdr.ADDITIONAL_INFORMATION,
            MEASURE1_NUMBER = r_hdr.MEASURE1_NUMBER,
            MEASURE2_NUMBER = r_hdr.MEASURE2_NUMBER,
            MEASURE3_NUMBER = r_hdr.MEASURE3_NUMBER,
            MEASURE4_NUMBER = r_hdr.MEASURE4_NUMBER,
            MEASURE5_NUMBER = r_hdr.MEASURE5_NUMBER,
            MEASURE6_NUMBER = r_hdr.MEASURE6_NUMBER,
            MEASURE7_NUMBER = r_hdr.MEASURE7_NUMBER,
            MEASURE8_NUMBER = r_hdr.MEASURE8_NUMBER,
            MEASURE9_NUMBER = r_hdr.MEASURE9_NUMBER,
            MEASURE10_NUMBER = r_hdr.MEASURE10_NUMBER,
            MEASURE1_CHAR = r_hdr.MEASURE1_CHAR,
            MEASURE2_CHAR = r_hdr.MEASURE2_CHAR,
            MEASURE3_CHAR = r_hdr.MEASURE3_CHAR,
            MEASURE4_CHAR = r_hdr.MEASURE4_CHAR,
            MEASURE5_CHAR = r_hdr.MEASURE5_CHAR,
            MEASURE6_CHAR = r_hdr.MEASURE6_CHAR,
            MEASURE7_CHAR = r_hdr.MEASURE7_CHAR,
            MEASURE8_CHAR = r_hdr.MEASURE8_CHAR,
            MEASURE9_CHAR = r_hdr.MEASURE9_CHAR,
            MEASURE10_CHAR = r_hdr.MEASURE10_CHAR,
           LAST_UPDATE_DATE = g_sys_date,
           LAST_UPDATED_BY = g_user_id,
           LAST_UPDATE_LOGIN = g_login_id,
           PROGRAM_APPLICATION_ID = g_prg_appl_id,
           PROGRAM_ID = g_prg_id,
           REQUEST_ID = g_request_id
      where PN_INT_HEADER_ID = l_req_int_hdr_id;
    else
      log_debug('Status of the header does not permit update');
    end if;
  end if;
  return(l_req_int_hdr_id);
exception
    when OTHERS then
        log_debug('ERROR IN INSERTING/UPDATING DEAL INTERFACE HEADER');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end insert_update_deal_hdr;

procedure assign_ins_deal_lines(p_qtn_ictr in number, p_src_ctr in number) is
l_line_no varchar2(240);
l_sql varchar2(2000);
begin
  g_r_ins_deal.SOURCE_REF_HDR_ID(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).SOURCE_REF_HDR_ID;
  g_r_ins_deal.SOURCE_REF_LINE_ID(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).SOURCE_REF_LINE_ID;
  if g_meas_type = ASO_MEAS_TYPE_DEALINT then
    begin
      l_sql := 'select QUOTE_LINE_NUMBER from qpr_sr_quote_line_num_v';
      l_sql := l_sql || qpr_sr_util.get_dblink(g_instance_id);
      l_sql := l_sql || ' where quote_header_id = :1 ';
      l_sql := l_sql || ' and quote_line_id = :2 and source_id = :3';
      execute immediate l_sql into l_line_no using
                g_t_src_lines(p_src_ctr).SOURCE_REF_HDR_ID,
                g_t_src_lines(p_src_ctr).SOURCE_REF_LINE_ID,
                g_source_id;
    exception
      when no_data_found then
        l_line_no := g_t_src_lines(p_src_ctr).SOURCE_REQUEST_LINE_NUMBER;
    end;
  g_r_ins_deal.SOURCE_REQ_LINE_NO(p_qtn_ictr) := l_line_no;
  else
  g_r_ins_deal.SOURCE_REQ_LINE_NO(p_qtn_ictr) :=
                          g_t_src_lines(p_src_ctr).SOURCE_REQUEST_LINE_NUMBER;
  end if;
  g_r_ins_deal.SOURCE_ID(p_qtn_ictr) := g_t_src_lines(p_src_ctr).SOURCE_ID;
  g_r_ins_deal.ORG_ID(p_qtn_ictr) := g_t_src_lines(p_src_ctr).ORG_ID;
  g_r_ins_deal.ORG_SHORT_DESC(p_qtn_ictr) :=
                                g_t_src_lines(p_src_ctr).ORG_SHORT_DESC;
  g_r_ins_deal.ORG_LONG_DESC(p_qtn_ictr) :=
                                g_t_src_lines(p_src_ctr).ORG_LONG_DESC;
  g_r_ins_deal.INVENTORY_ITEM_ID(p_qtn_ictr) :=
                                g_t_src_lines(p_src_ctr).INVENTORY_ITEM_ID;
  g_r_ins_deal.INVENTORY_ITEM_SHORT_DESC(p_qtn_ictr) :=
                             g_t_src_lines(p_src_ctr).INVENTORY_ITEM_SHORT_DESC;
  g_r_ins_deal.INVENTORY_ITEM_LONG_DESC(p_qtn_ictr) :=
                             g_t_src_lines(p_src_ctr).INVENTORY_ITEM_LONG_DESC;
  g_r_ins_deal.ITEM_TYPE_CODE(p_qtn_ictr) :=
                                    g_t_src_lines(p_src_ctr).ITEM_TYPE_CODE;
  g_r_ins_deal.TOP_MDL_SRC_LINE_ID(p_qtn_ictr) :=
                                   g_t_src_lines(p_src_ctr).TOP_MDL_SRC_LINE_ID;
  g_r_ins_deal.PAYMENT_TERM_ID(p_qtn_ictr) :=
                                    g_t_src_lines(p_src_ctr).PAYMENT_TERM_ID;
  g_r_ins_deal.PAYMENT_TERM_SHORT_DESC(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).PAYMENT_TERM_SHORT_DESC;
  g_r_ins_deal.PAYMENT_TERM_LONG_DESC(p_qtn_ictr) :=
                                g_t_src_lines(p_src_ctr).PAYMENT_TERM_LONG_DESC;
  g_r_ins_deal.UOM_CODE(p_qtn_ictr) := g_t_src_lines(p_src_ctr).UOM_CODE;
  g_r_ins_deal.UOM_SHORT_DESC(p_qtn_ictr) :=
                                  g_t_src_lines(p_src_ctr).UOM_SHORT_DESC;
  g_r_ins_deal.CURRENCY_CODE(p_qtn_ictr) :=
                                  g_t_src_lines(p_src_ctr).CURRENCY_CODE;
  g_r_ins_deal.CURRENCY_SHORT_DESC(p_qtn_ictr) :=
                                  g_t_src_lines(p_src_ctr).CURRENCY_SHORT_DESC;
  g_r_ins_deal.ORDERED_QTY(p_qtn_ictr) := g_t_src_lines(p_src_ctr).ORDERED_QTY;
  g_r_ins_deal.LIST_PRICE(p_qtn_ictr) := g_t_src_lines(p_src_ctr).LIST_PRICE;
  g_r_ins_deal.PROPOSED_PRICE(p_qtn_ictr) :=
                                        g_t_src_lines(p_src_ctr).PROPOSED_PRICE;
  g_r_ins_deal.REVISED_OQ(p_qtn_ictr) :=
                                        g_t_src_lines(p_src_ctr).REVISED_OQ;
  g_r_ins_deal.COMPETITOR_NAME(p_qtn_ictr) :=
                                       g_t_src_lines(p_src_ctr).COMPETITOR_NAME;
  g_r_ins_deal.COMPETITOR_PRICE(p_qtn_ictr) :=
                                      g_t_src_lines(p_src_ctr).COMPETITOR_PRICE;
  g_r_ins_deal.COMMENTS(p_qtn_ictr) := g_t_src_lines(p_src_ctr).COMMENTS;
  g_r_ins_deal.ADDITIONAL_INFO(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).ADDITIONAL_INFORMATION;
  g_r_ins_deal.SHIP_METHOD_CODE(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).SHIP_METHOD_CODE;
  g_r_ins_deal.SHIP_METHOD_SHORT_DESC(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).SHIP_METHOD_SHORT_DESC;
  g_r_ins_deal.SHIP_METHOD_LONG_DESC(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).SHIP_METHOD_LONG_DESC;
  g_r_ins_deal.FREIGHT_CHARGES(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).FREIGHT_CHARGES;
  g_r_ins_deal.GEOGRAPHY_ID(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).GEOGRAPHY_ID;
  g_r_ins_deal.GEOGRAPHY_SHORT_DESC(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).GEOGRAPHY_SHORT_DESC;
  g_r_ins_deal.GEOGRAPHY_LONG_DESC(p_qtn_ictr) :=
                               g_t_src_lines(p_src_ctr).GEOGRAPHY_LONG_DESC;
  g_r_ins_deal.MEASURE1_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE1_NUMBER;
  g_r_ins_deal.MEASURE2_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE2_NUMBER;
  g_r_ins_deal.MEASURE3_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE3_NUMBER;
  g_r_ins_deal.MEASURE4_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE4_NUMBER;
  g_r_ins_deal.MEASURE5_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE5_NUMBER;
  g_r_ins_deal.MEASURE6_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE6_NUMBER;
  g_r_ins_deal.MEASURE7_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE7_NUMBER;
  g_r_ins_deal.MEASURE8_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE8_NUMBER;
  g_r_ins_deal.MEASURE9_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE9_NUMBER;
  g_r_ins_deal.MEASURE10_NUMBER(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE10_NUMBER;
  g_r_ins_deal.MEASURE1_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE1_CHAR;
  g_r_ins_deal.MEASURE2_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE2_CHAR;
  g_r_ins_deal.MEASURE3_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE3_CHAR;
  g_r_ins_deal.MEASURE4_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE4_CHAR;
  g_r_ins_deal.MEASURE5_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE5_CHAR;
  g_r_ins_deal.MEASURE6_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE6_CHAR;
  g_r_ins_deal.MEASURE7_CHAR(p_qtn_ictr) :=
                            g_t_src_lines(p_src_ctr).MEASURE7_CHAR;
  g_r_ins_deal.MEASURE8_CHAR(p_qtn_ictr) :=
                              g_t_src_lines(p_src_ctr).MEASURE8_CHAR;
  g_r_ins_deal.MEASURE9_CHAR(p_qtn_ictr) :=
                          g_t_src_lines(p_src_ctr).MEASURE9_CHAR;
  g_r_ins_deal.MEASURE10_CHAR(p_qtn_ictr) :=
                          g_t_src_lines(p_src_ctr).MEASURE10_CHAR;

exception
    when OTHERS then
        log_debug('ERROR ASSIGNING VALUES TO INSERT IN INTERFACE LINE RECORD');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end assign_ins_deal_lines;

procedure assign_upd_deal_lines(p_qtn_uctr in number, p_src_ctr in number,
                                p_int_line_id in number) is
l_line_no varchar2(240);
begin
  g_r_upd_deal.PN_REQ_INTERFACE_LINE_ID(p_qtn_uctr) := p_int_line_id;
  g_r_upd_deal.SOURCE_REF_HDR_ID(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).SOURCE_REF_HDR_ID;
  g_r_upd_deal.SOURCE_REF_LINE_ID(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).SOURCE_REF_LINE_ID;
  if g_meas_type = ASO_MEAS_TYPE_DEALINT then
    begin
    select QUOTE_LINE_NUMBER into l_line_no
    from qpr_sr_quote_line_num_v
    where quote_header_id = g_t_src_lines(p_src_ctr).SOURCE_REF_HDR_ID
    and quote_line_id = g_t_src_lines(p_src_ctr).SOURCE_REF_LINE_ID
    and source_id = g_source_id;
    exception
      when no_data_found then
        l_line_no := g_t_src_lines(p_src_ctr).SOURCE_REQUEST_LINE_NUMBER;
    end;
  g_r_upd_deal.SOURCE_REQ_LINE_NO(p_qtn_uctr) := l_line_no;
  else
  g_r_upd_deal.SOURCE_REQ_LINE_NO(p_qtn_uctr) :=
                          g_t_src_lines(p_src_ctr).SOURCE_REQUEST_LINE_NUMBER;
  end if;
  g_r_upd_deal.SOURCE_ID(p_qtn_uctr) := g_t_src_lines(p_src_ctr).SOURCE_ID;
  g_r_upd_deal.ORG_ID(p_qtn_uctr) := g_t_src_lines(p_src_ctr).ORG_ID;
  g_r_upd_deal.ORG_SHORT_DESC(p_qtn_uctr) :=
                                g_t_src_lines(p_src_ctr).ORG_SHORT_DESC;
  g_r_upd_deal.ORG_LONG_DESC(p_qtn_uctr) :=
                                g_t_src_lines(p_src_ctr).ORG_LONG_DESC;
  g_r_upd_deal.INVENTORY_ITEM_ID(p_qtn_uctr) :=
                                g_t_src_lines(p_src_ctr).INVENTORY_ITEM_ID;
  g_r_upd_deal.INVENTORY_ITEM_SHORT_DESC(p_qtn_uctr) :=
                             g_t_src_lines(p_src_ctr).INVENTORY_ITEM_SHORT_DESC;
  g_r_upd_deal.INVENTORY_ITEM_LONG_DESC(p_qtn_uctr) :=
                             g_t_src_lines(p_src_ctr).INVENTORY_ITEM_LONG_DESC;
  g_r_upd_deal.ITEM_TYPE_CODE(p_qtn_uctr) :=
                                    g_t_src_lines(p_src_ctr).ITEM_TYPE_CODE;
  g_r_upd_deal.TOP_MDL_SRC_LINE_ID(p_qtn_uctr) :=
                                   g_t_src_lines(p_src_ctr).TOP_MDL_SRC_LINE_ID;
  g_r_upd_deal.PAYMENT_TERM_ID(p_qtn_uctr) :=
                                    g_t_src_lines(p_src_ctr).PAYMENT_TERM_ID;
  g_r_upd_deal.PAYMENT_TERM_SHORT_DESC(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).PAYMENT_TERM_SHORT_DESC;
  g_r_upd_deal.PAYMENT_TERM_LONG_DESC(p_qtn_uctr) :=
                                g_t_src_lines(p_src_ctr).PAYMENT_TERM_LONG_DESC;
  g_r_upd_deal.UOM_CODE(p_qtn_uctr) := g_t_src_lines(p_src_ctr).UOM_CODE;
  g_r_upd_deal.UOM_SHORT_DESC(p_qtn_uctr) :=
                                  g_t_src_lines(p_src_ctr).UOM_SHORT_DESC;
  g_r_upd_deal.CURRENCY_CODE(p_qtn_uctr) :=
                                  g_t_src_lines(p_src_ctr).CURRENCY_CODE;
  g_r_upd_deal.CURRENCY_SHORT_DESC(p_qtn_uctr) :=
                                  g_t_src_lines(p_src_ctr).CURRENCY_SHORT_DESC;
  g_r_upd_deal.ORDERED_QTY(p_qtn_uctr) := g_t_src_lines(p_src_ctr).ORDERED_QTY;
  g_r_upd_deal.LIST_PRICE(p_qtn_uctr) := g_t_src_lines(p_src_ctr).LIST_PRICE;
  g_r_upd_deal.PROPOSED_PRICE(p_qtn_uctr) :=
                                        g_t_src_lines(p_src_ctr).PROPOSED_PRICE;
  g_r_upd_deal.REVISED_OQ(p_qtn_uctr) :=
                                        g_t_src_lines(p_src_ctr).REVISED_OQ;
  g_r_upd_deal.COMPETITOR_NAME(p_qtn_uctr) :=
                                       g_t_src_lines(p_src_ctr).COMPETITOR_NAME;
  g_r_upd_deal.COMPETITOR_PRICE(p_qtn_uctr) :=
                                      g_t_src_lines(p_src_ctr).COMPETITOR_PRICE;
  g_r_upd_deal.COMMENTS(p_qtn_uctr) := g_t_src_lines(p_src_ctr).COMMENTS;
  g_r_upd_deal.ADDITIONAL_INFO(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).ADDITIONAL_INFORMATION;
  g_r_upd_deal.SHIP_METHOD_CODE(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).SHIP_METHOD_CODE;
  g_r_upd_deal.SHIP_METHOD_SHORT_DESC(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).SHIP_METHOD_SHORT_DESC;
  g_r_upd_deal.SHIP_METHOD_LONG_DESC(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).SHIP_METHOD_LONG_DESC;
  g_r_upd_deal.FREIGHT_CHARGES(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).FREIGHT_CHARGES;
  g_r_upd_deal.GEOGRAPHY_ID(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).GEOGRAPHY_ID;
  g_r_upd_deal.GEOGRAPHY_SHORT_DESC(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).GEOGRAPHY_SHORT_DESC;
  g_r_upd_deal.GEOGRAPHY_LONG_DESC(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).GEOGRAPHY_LONG_DESC;
  g_r_upd_deal.MEASURE1_NUMBER(p_qtn_uctr) :=
                               g_t_src_lines(p_src_ctr).MEASURE1_NUMBER;
  g_r_upd_deal.MEASURE2_NUMBER(p_qtn_uctr) :=
                                g_t_src_lines(p_src_ctr).MEASURE2_NUMBER;
  g_r_upd_deal.MEASURE3_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE3_NUMBER;
  g_r_upd_deal.MEASURE4_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE4_NUMBER;
  g_r_upd_deal.MEASURE5_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE5_NUMBER;
  g_r_upd_deal.MEASURE6_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE6_NUMBER;
  g_r_upd_deal.MEASURE7_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE7_NUMBER;
  g_r_upd_deal.MEASURE8_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE8_NUMBER;
  g_r_upd_deal.MEASURE9_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE9_NUMBER;
  g_r_upd_deal.MEASURE10_NUMBER(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE10_NUMBER;
  g_r_upd_deal.MEASURE1_CHAR(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE1_CHAR;
  g_r_upd_deal.MEASURE2_CHAR(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE2_CHAR;
  g_r_upd_deal.MEASURE3_CHAR(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE3_CHAR;
  g_r_upd_deal.MEASURE4_CHAR(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE4_CHAR;
  g_r_upd_deal.MEASURE5_CHAR(p_qtn_uctr) :=
                            g_t_src_lines(p_src_ctr).MEASURE5_CHAR;
  g_r_upd_deal.MEASURE6_CHAR(p_qtn_uctr) :=
                              g_t_src_lines(p_src_ctr).MEASURE6_CHAR;
  g_r_upd_deal.MEASURE7_CHAR(p_qtn_uctr) :=
                            g_t_src_lines(p_src_ctr).MEASURE7_CHAR;
  g_r_upd_deal.MEASURE8_CHAR(p_qtn_uctr) :=
                            g_t_src_lines(p_src_ctr).MEASURE8_CHAR;
  g_r_upd_deal.MEASURE9_CHAR(p_qtn_uctr) :=
                            g_t_src_lines(p_src_ctr).MEASURE9_CHAR;
  g_r_upd_deal.MEASURE10_CHAR(p_qtn_uctr) :=
                    g_t_src_lines(p_src_ctr).MEASURE10_CHAR;

exception
    when OTHERS then
        log_debug('ERROR ASSIGNING VALUES TO UPDATE INTERFACE LINE RECORD');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end assign_upd_deal_lines;

procedure del_ins_deal_lines is
begin
  g_r_ins_deal.SOURCE_REF_HDR_ID.delete;
  g_r_ins_deal.SOURCE_REF_LINE_ID.delete;
  g_r_ins_deal.SOURCE_REQ_LINE_NO.delete;
  g_r_ins_deal.SOURCE_ID.delete;
  g_r_ins_deal.ORG_ID.delete;
  g_r_ins_deal.ORG_SHORT_DESC.delete;
  g_r_ins_deal.ORG_LONG_DESC.delete;
  g_r_ins_deal.INVENTORY_ITEM_ID.delete;
  g_r_ins_deal.INVENTORY_ITEM_SHORT_DESC.delete;
  g_r_ins_deal.INVENTORY_ITEM_LONG_DESC.delete;
  g_r_ins_deal.ITEM_TYPE_CODE.delete;
  g_r_ins_deal.TOP_MDL_SRC_LINE_ID.delete;
  g_r_ins_deal.PAYMENT_TERM_ID.delete;
  g_r_ins_deal.PAYMENT_TERM_SHORT_DESC.delete;
  g_r_ins_deal.PAYMENT_TERM_LONG_DESC.delete;
  g_r_ins_deal.UOM_CODE.delete;
  g_r_ins_deal.UOM_SHORT_DESC.delete;
  g_r_ins_deal.CURRENCY_CODE.delete;
  g_r_ins_deal.CURRENCY_SHORT_DESC.delete;
  g_r_ins_deal.ORDERED_QTY.delete;
  g_r_ins_deal.LIST_PRICE.delete;
  g_r_ins_deal.PROPOSED_PRICE.delete;
  g_r_ins_deal.REVISED_OQ.delete;
  g_r_ins_deal.COMPETITOR_NAME.delete;
  g_r_ins_deal.COMPETITOR_PRICE.delete;
  g_r_ins_deal.COMMENTS.delete;
  g_r_ins_deal.ADDITIONAL_INFO.delete;
  g_r_ins_deal.SHIP_METHOD_CODE.delete;
  g_r_ins_deal.SHIP_METHOD_SHORT_DESC.delete;
  g_r_ins_deal.SHIP_METHOD_LONG_DESC.delete;
  g_r_ins_deal.FREIGHT_CHARGES.delete;
  g_r_ins_deal.GEOGRAPHY_ID.delete;
  g_r_ins_deal.GEOGRAPHY_SHORT_DESC.delete;
  g_r_ins_deal.GEOGRAPHY_LONG_DESC.delete;
  g_r_ins_deal.MEASURE1_NUMBER.delete;
  g_r_ins_deal.MEASURE2_NUMBER.delete;
  g_r_ins_deal.MEASURE3_NUMBER.delete;
  g_r_ins_deal.MEASURE4_NUMBER.delete;
  g_r_ins_deal.MEASURE5_NUMBER.delete;
  g_r_ins_deal.MEASURE6_NUMBER.delete;
  g_r_ins_deal.MEASURE7_NUMBER.delete;
  g_r_ins_deal.MEASURE8_NUMBER.delete;
  g_r_ins_deal.MEASURE9_NUMBER.delete;
  g_r_ins_deal.MEASURE10_NUMBER.delete;
  g_r_ins_deal.MEASURE1_CHAR.delete;
  g_r_ins_deal.MEASURE2_CHAR.delete;
  g_r_ins_deal.MEASURE3_CHAR.delete;
  g_r_ins_deal.MEASURE4_CHAR.delete;
  g_r_ins_deal.MEASURE5_CHAR.delete;
  g_r_ins_deal.MEASURE6_CHAR.delete;
  g_r_ins_deal.MEASURE7_CHAR.delete;
  g_r_ins_deal.MEASURE8_CHAR.delete;
  g_r_ins_deal.MEASURE9_CHAR.delete;
  g_r_ins_deal.MEASURE10_CHAR.delete;

exception
    when OTHERS then
        log_debug('ERROR IN CLEARING INTERFACE LINE RECORD');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end del_ins_deal_lines;

procedure del_upd_deal_lines is
begin
  g_r_upd_deal.PN_REQ_INTERFACE_LINE_ID.delete;
  g_r_upd_deal.SOURCE_REF_HDR_ID.delete;
  g_r_upd_deal.SOURCE_REF_LINE_ID.delete;
  g_r_upd_deal.SOURCE_REQ_LINE_NO.delete;
  g_r_upd_deal.SOURCE_ID.delete;
  g_r_upd_deal.ORG_ID.delete;
  g_r_upd_deal.ORG_SHORT_DESC.delete;
  g_r_upd_deal.ORG_LONG_DESC.delete;
  g_r_upd_deal.INVENTORY_ITEM_ID.delete;
  g_r_upd_deal.INVENTORY_ITEM_SHORT_DESC.delete;
  g_r_upd_deal.INVENTORY_ITEM_LONG_DESC.delete;
  g_r_upd_deal.ITEM_TYPE_CODE.delete;
  g_r_upd_deal.TOP_MDL_SRC_LINE_ID.delete;
  g_r_upd_deal.PAYMENT_TERM_ID.delete;
  g_r_upd_deal.PAYMENT_TERM_SHORT_DESC.delete;
  g_r_upd_deal.PAYMENT_TERM_LONG_DESC.delete;
  g_r_upd_deal.UOM_CODE.delete;
  g_r_upd_deal.UOM_SHORT_DESC.delete;
  g_r_upd_deal.CURRENCY_CODE.delete;
  g_r_upd_deal.CURRENCY_SHORT_DESC.delete;
  g_r_upd_deal.ORDERED_QTY.delete;
  g_r_upd_deal.LIST_PRICE.delete;
  g_r_upd_deal.PROPOSED_PRICE.delete;
  g_r_upd_deal.REVISED_OQ.delete;
  g_r_upd_deal.COMPETITOR_NAME.delete;
  g_r_upd_deal.COMPETITOR_PRICE.delete;
  g_r_upd_deal.COMMENTS.delete;
  g_r_upd_deal.ADDITIONAL_INFO.delete;
  g_r_upd_deal.SHIP_METHOD_CODE.delete;
  g_r_upd_deal.SHIP_METHOD_SHORT_DESC.delete;
  g_r_upd_deal.SHIP_METHOD_LONG_DESC.delete;
  g_r_upd_deal.FREIGHT_CHARGES.delete;
  g_r_upd_deal.GEOGRAPHY_ID.delete;
  g_r_upd_deal.GEOGRAPHY_SHORT_DESC.delete;
  g_r_upd_deal.GEOGRAPHY_LONG_DESC.delete;
  g_r_upd_deal.MEASURE1_NUMBER.delete;
  g_r_upd_deal.MEASURE2_NUMBER.delete;
  g_r_upd_deal.MEASURE3_NUMBER.delete;
  g_r_upd_deal.MEASURE4_NUMBER.delete;
  g_r_upd_deal.MEASURE5_NUMBER.delete;
  g_r_upd_deal.MEASURE6_NUMBER.delete;
  g_r_upd_deal.MEASURE7_NUMBER.delete;
  g_r_upd_deal.MEASURE8_NUMBER.delete;
  g_r_upd_deal.MEASURE9_NUMBER.delete;
  g_r_upd_deal.MEASURE10_NUMBER.delete;
  g_r_upd_deal.MEASURE1_CHAR.delete;
  g_r_upd_deal.MEASURE2_CHAR.delete;
  g_r_upd_deal.MEASURE3_CHAR.delete;
  g_r_upd_deal.MEASURE4_CHAR.delete;
  g_r_upd_deal.MEASURE5_CHAR.delete;
  g_r_upd_deal.MEASURE6_CHAR.delete;
  g_r_upd_deal.MEASURE7_CHAR.delete;
  g_r_upd_deal.MEASURE8_CHAR.delete;
  g_r_upd_deal.MEASURE9_CHAR.delete;
  g_r_upd_deal.MEASURE10_CHAR.delete;

exception
    when OTHERS then
        log_debug('ERROR IN CLEARING INTERFACE LINE RECORD');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end del_upd_deal_lines;

procedure insert_deal_lines(
                            p_header_id in number
                            ) is
begin
  log_debug('Inserting deal interface lines ....');
  forall i in g_r_ins_deal.SOURCE_REF_HDR_ID.first..
                                g_r_ins_deal.SOURCE_REF_HDR_ID.last
    insert into qpr_pn_int_lines(PN_INT_LINE_ID,
                              --          PN_INT_HEADER_ID,
                                        SOURCE_REF_HDR_ID,
                                        SOURCE_REF_LINE_ID,
                                        SOURCE_REQUEST_LINE_NUMBER,
                                        SOURCE_ID,
                                        ORG_ID,
                                        ORG_SHORT_DESC,
                                        ORG_LONG_DESC,
                                        INVENTORY_ITEM_ID,
                                        INVENTORY_ITEM_SHORT_DESC,
                                        INVENTORY_ITEM_LONG_DESC,
                                        ITEM_TYPE_CODE,
                                        TOP_MDL_SRC_LINE_ID,
                                        PAYMENT_TERM_ID,
                                        PAYMENT_TERM_SHORT_DESC,
                                        PAYMENT_TERM_LONG_DESC,
                                        UOM_CODE,
                                        UOM_SHORT_DESC,
                                        CURRENCY_CODE,
                                        CURRENCY_SHORT_DESC,
                                        ORDERED_QTY,
                                        LIST_PRICE,
                                        PROPOSED_PRICE,
                                        REVISED_OQ,
                                        PN_REQ_LINE_STATUS_FLAG,
                                        COMPETITOR_NAME,
                                        COMPETITOR_PRICE,
                                        COMMENTS,
                                        ADDITIONAL_INFORMATION,
                                        SHIP_METHOD_CODE,
                                        SHIP_METHOD_SHORT_DESC,
                                        SHIP_METHOD_LONG_DESC,
                                        FREIGHT_CHARGES,
                                        GEOGRAPHY_ID,
                                        GEOGRAPHY_SHORT_DESC,
                                        GEOGRAPHY_LONG_DESC,
                                        MEASURE1_NUMBER,
                                        MEASURE2_NUMBER,
                                        MEASURE3_NUMBER,
                                        MEASURE4_NUMBER,
                                        MEASURE5_NUMBER,
                                        MEASURE6_NUMBER,
                                        MEASURE7_NUMBER,
                                        MEASURE8_NUMBER,
                                        MEASURE9_NUMBER,
                                        MEASURE10_NUMBER,
                                        MEASURE1_CHAR,
                                        MEASURE2_CHAR,
                                        MEASURE3_CHAR,
                                        MEASURE4_CHAR,
                                        MEASURE5_CHAR,
                                        MEASURE6_CHAR,
                                        MEASURE7_CHAR,
                                        MEASURE8_CHAR,
                                        MEASURE9_CHAR,
                                        MEASURE10_CHAR,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN,
                                        PROGRAM_APPLICATION_ID,
                                        PROGRAM_ID ,
                                        REQUEST_ID)
    values(qpr_pn_int_lines_s.nextval,
--           p_int_hdr_id,
           g_r_ins_deal.SOURCE_REF_HDR_ID(i) ,
           g_r_ins_deal.SOURCE_REF_LINE_ID(i) ,
           g_r_ins_deal.SOURCE_REQ_LINE_NO(i),
           g_r_ins_deal.SOURCE_ID(i) ,
           g_r_ins_deal.ORG_ID(i) ,
           g_r_ins_deal.ORG_SHORT_DESC(i) ,
           g_r_ins_deal.ORG_LONG_DESC(i) ,
           g_r_ins_deal.INVENTORY_ITEM_ID(i) ,
           g_r_ins_deal.INVENTORY_ITEM_SHORT_DESC(i) ,
           g_r_ins_deal.INVENTORY_ITEM_LONG_DESC(i) ,
           g_r_ins_deal.ITEM_TYPE_CODE(i) ,
           g_r_ins_deal.TOP_MDL_SRC_LINE_ID(i) ,
           g_r_ins_deal.PAYMENT_TERM_ID(i) ,
           g_r_ins_deal.PAYMENT_TERM_SHORT_DESC(i) ,
           g_r_ins_deal.PAYMENT_TERM_LONG_DESC(i) ,
           g_r_ins_deal.UOM_CODE(i) ,
           g_r_ins_deal.UOM_SHORT_DESC(i) ,
           g_r_ins_deal.CURRENCY_CODE(i) ,
           g_r_ins_deal.CURRENCY_SHORT_DESC(i) ,
           g_r_ins_deal.ORDERED_QTY(i) ,
           g_r_ins_deal.LIST_PRICE(i) ,
           g_r_ins_deal.PROPOSED_PRICE(i) ,
           g_r_ins_deal.REVISED_OQ(i) , 'I',
           g_r_ins_deal.COMPETITOR_NAME(i) ,
           g_r_ins_deal.COMPETITOR_PRICE(i) ,
           g_r_ins_deal.COMMENTS(i),
           g_r_ins_deal.ADDITIONAL_INFO(i),
           g_r_ins_deal.SHIP_METHOD_CODE(i),
           g_r_ins_deal.SHIP_METHOD_SHORT_DESC(i),
           g_r_ins_deal.SHIP_METHOD_LONG_DESC(i),
           g_r_ins_deal.FREIGHT_CHARGES(i),
           g_r_ins_deal.GEOGRAPHY_ID(i),
           g_r_ins_deal.GEOGRAPHY_SHORT_DESC(i),
           g_r_ins_deal.GEOGRAPHY_LONG_DESC(i),
          g_r_ins_deal.MEASURE1_NUMBER(i),
          g_r_ins_deal.MEASURE2_NUMBER(i),
          g_r_ins_deal.MEASURE3_NUMBER(i),
          g_r_ins_deal.MEASURE4_NUMBER(i),
          g_r_ins_deal.MEASURE5_NUMBER(i),
          g_r_ins_deal.MEASURE6_NUMBER(i),
          g_r_ins_deal.MEASURE7_NUMBER(i),
          g_r_ins_deal.MEASURE8_NUMBER(i),
          g_r_ins_deal.MEASURE9_NUMBER(i),
          g_r_ins_deal.MEASURE10_NUMBER(i),
          g_r_ins_deal.MEASURE1_CHAR(i),
          g_r_ins_deal.MEASURE2_CHAR(i),
          g_r_ins_deal.MEASURE3_CHAR(i),
          g_r_ins_deal.MEASURE4_CHAR(i),
          g_r_ins_deal.MEASURE5_CHAR(i),
          g_r_ins_deal.MEASURE6_CHAR(i),
          g_r_ins_deal.MEASURE7_CHAR(i),
          g_r_ins_deal.MEASURE8_CHAR(i),
          g_r_ins_deal.MEASURE9_CHAR(i),
          g_r_ins_deal.MEASURE10_CHAR(i),
           g_sys_date,
           g_user_id,
           g_sys_date,
           g_user_id,
           g_login_id, g_prg_appl_id , g_prg_id, g_request_id);
  del_ins_deal_lines;
exception
    when OTHERS then
        log_debug('ERROR INSERTING VALUES TO DEAL INTERFACE LINE');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end insert_deal_lines;

procedure update_deal_lines is
begin
  log_debug('Updating deal interface lines ....');
  forall i in g_r_upd_deal.SOURCE_REF_HDR_ID.first..
                                  g_r_upd_deal.SOURCE_REF_HDR_ID.last
    update qpr_pn_int_lines set
           SOURCE_REQUEST_LINE_NUMBER = g_r_upd_deal.SOURCE_REQ_LINE_NO(i),
           SOURCE_ID = g_r_upd_deal.SOURCE_ID(i),
           ORG_ID = g_r_upd_deal.ORG_ID(i),
           ORG_SHORT_DESC = g_r_upd_deal.ORG_SHORT_DESC(i) ,
           ORG_LONG_DESC = g_r_upd_deal.ORG_LONG_DESC(i) ,
           INVENTORY_ITEM_ID = g_r_upd_deal.INVENTORY_ITEM_ID(i) ,
           INVENTORY_ITEM_SHORT_DESC= g_r_upd_deal.INVENTORY_ITEM_SHORT_DESC(i),
           INVENTORY_ITEM_LONG_DESC = g_r_upd_deal.INVENTORY_ITEM_LONG_DESC(i),
           ITEM_TYPE_CODE = g_r_upd_deal.ITEM_TYPE_CODE(i) ,
           TOP_MDL_SRC_LINE_ID = g_r_upd_deal.TOP_MDL_SRC_LINE_ID(i) ,
           PAYMENT_TERM_ID = g_r_upd_deal.PAYMENT_TERM_ID(i) ,
           PAYMENT_TERM_SHORT_DESC = g_r_upd_deal.PAYMENT_TERM_SHORT_DESC(i),
           PAYMENT_TERM_LONG_DESC = g_r_upd_deal.PAYMENT_TERM_LONG_DESC(i),
           UOM_CODE = g_r_upd_deal.UOM_CODE(i) ,
           UOM_SHORT_DESC = g_r_upd_deal.UOM_SHORT_DESC(i) ,
           CURRENCY_CODE = g_r_upd_deal.CURRENCY_CODE(i) ,
           CURRENCY_SHORT_DESC = g_r_upd_deal.CURRENCY_SHORT_DESC(i) ,
           ORDERED_QTY = g_r_upd_deal.ORDERED_QTY(i) ,
           LIST_PRICE = g_r_upd_deal.LIST_PRICE(i) ,
           PROPOSED_PRICE = g_r_upd_deal.PROPOSED_PRICE(i) ,
           REVISED_OQ = g_r_upd_deal.REVISED_OQ(i) ,
           COMPETITOR_NAME = g_r_upd_deal.COMPETITOR_NAME(i),
           COMPETITOR_PRICE = g_r_upd_deal.COMPETITOR_PRICE(i) ,
           COMMENTS = g_r_upd_deal.COMMENTS(i) ,
           ADDITIONAL_INFORMATION = g_r_upd_deal.ADDITIONAL_INFO(i),
           SHIP_METHOD_CODE = g_r_upd_deal.SHIP_METHOD_CODE(i),
           SHIP_METHOD_SHORT_DESC = g_r_upd_deal.SHIP_METHOD_SHORT_DESC(i),
           SHIP_METHOD_LONG_DESC = g_r_upd_deal.SHIP_METHOD_LONG_DESC(i),
           FREIGHT_CHARGES = g_r_upd_deal.FREIGHT_CHARGES(i),
           GEOGRAPHY_ID = g_r_upd_deal.GEOGRAPHY_ID(i),
           GEOGRAPHY_SHORT_DESC = g_r_upd_deal.GEOGRAPHY_SHORT_DESC(i),
           GEOGRAPHY_LONG_DESC = g_r_upd_deal.GEOGRAPHY_LONG_DESC(i),
            MEASURE1_NUMBER = g_r_upd_deal.MEASURE1_NUMBER(i),
            MEASURE2_NUMBER = g_r_upd_deal.MEASURE2_NUMBER(i),
            MEASURE3_NUMBER = g_r_upd_deal.MEASURE3_NUMBER(i),
            MEASURE4_NUMBER = g_r_upd_deal.MEASURE4_NUMBER(i),
            MEASURE5_NUMBER = g_r_upd_deal.MEASURE5_NUMBER(i),
            MEASURE6_NUMBER = g_r_upd_deal.MEASURE6_NUMBER(i),
            MEASURE7_NUMBER = g_r_upd_deal.MEASURE7_NUMBER(i),
            MEASURE8_NUMBER = g_r_upd_deal.MEASURE8_NUMBER(i),
            MEASURE9_NUMBER = g_r_upd_deal.MEASURE9_NUMBER(i),
            MEASURE10_NUMBER = g_r_upd_deal.MEASURE10_NUMBER(i),
            MEASURE1_CHAR = g_r_upd_deal.MEASURE1_CHAR(i),
            MEASURE2_CHAR = g_r_upd_deal.MEASURE2_CHAR(i),
            MEASURE3_CHAR = g_r_upd_deal.MEASURE3_CHAR(i),
            MEASURE4_CHAR = g_r_upd_deal.MEASURE4_CHAR(i),
            MEASURE5_CHAR = g_r_upd_deal.MEASURE5_CHAR(i),
            MEASURE6_CHAR = g_r_upd_deal.MEASURE6_CHAR(i),
            MEASURE7_CHAR = g_r_upd_deal.MEASURE7_CHAR(i),
            MEASURE8_CHAR = g_r_upd_deal.MEASURE8_CHAR(i),
            MEASURE9_CHAR = g_r_upd_deal.MEASURE9_CHAR(i),
            MEASURE10_CHAR = g_r_upd_deal.MEASURE10_CHAR(i),
           LAST_UPDATE_DATE = g_sys_date,
           LAST_UPDATED_BY = g_user_id,
           LAST_UPDATE_LOGIN = g_login_id,
           PROGRAM_APPLICATION_ID = g_prg_appl_id,
           PROGRAM_ID = g_prg_id,
           REQUEST_ID = g_request_id
  where  PN_INT_LINE_ID = g_r_upd_deal.PN_REQ_INTERFACE_LINE_ID(i);

  del_upd_deal_lines;
exception
    when OTHERS then
        log_debug('ERROR IN UPDATING DEAL INTERFACE LINES');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end update_deal_lines;

procedure insert_update_deal_lines(
                                   p_header_id in number,
                                   p_sql in varchar2) is
b_update  boolean := false;
l_req_int_hdr_id number;
l_req_int_line_id number;
l_rows number := 1000;
l_qt_ictr number := 0;
l_qt_uctr number := 0;
s_status varchar2(1);
s_sql varchar2(20000) := '';
s_src_tbl varchar2(30);
t_src_line_id num_type;
t_int_line_id num_type;
t_status char240_type;
c_deal_line SYS_REFCURSOR;
begin
  log_debug('In Deal Line method..');

    select l.SOURCE_REF_LINE_ID, l.PN_INT_LINE_ID, l.PN_REQ_LINE_STATUS_FLAG
    bulk collect into t_src_line_id, t_int_line_id, t_status
    from qpr_pn_int_lines l, qpr_pn_int_headers h
    where h.source_ref_header_id = p_header_id
    and h.instance_id = g_instance_id
    and h.source_id = g_source_id
    and h.source_ref_header_short_desc = g_quote_hdr_sd
		and h.source_id = l.source_id
		and h.source_ref_header_id = l.source_ref_hdr_id
    order by l.source_ref_line_id;

    open c_deal_line for p_sql using p_header_id;
    loop
      fetch c_deal_line bulk collect into g_t_src_lines limit l_rows;
      exit when g_t_src_lines.count = 0;
      for i in g_t_src_lines.first..g_t_src_lines.last loop
        b_update := false;
        if t_src_line_id.count=  0 then
          l_qt_ictr := l_qt_ictr + 1;
          assign_ins_deal_lines(l_qt_ictr, i);
        else
          for j in t_src_line_id.first..t_src_line_id.last loop
            if t_src_line_id.exists(j) then
              if t_src_line_id(j) = g_t_src_lines(i).source_ref_line_id then
                s_status := t_status(j);
                b_update := true;
                l_req_int_line_id := t_int_line_id(j);
                t_src_line_id.delete(j);
                t_int_line_id.delete(j);
                t_status.delete(j);
                exit;
              end if;
            end if;
          end loop;
          if b_update = true then
            if s_status <> 'P' then
              l_qt_uctr := l_qt_uctr + 1;
              assign_upd_deal_lines(l_qt_uctr, i, l_req_int_line_id);
            else
              log_debug('Status of line ' ||g_t_src_lines(i).source_ref_line_id                           || ' does not permit update.');
            end if;
          else
            l_qt_ictr := l_qt_ictr + 1;
            assign_ins_deal_lines(l_qt_ictr, i);
          end if;
        end if;
      end loop;   -- all src lines loop
      if g_r_ins_deal.SOURCE_REF_LINE_ID.count > 0 then
        insert_deal_lines( p_header_id);
      end if;
      if g_r_upd_deal.SOURCE_REF_LINE_ID.count > 0 then
        update_deal_lines;
      end if;
      g_t_src_lines.delete;
    end loop;
--  end if;
exception
    when OTHERS then
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end insert_update_deal_lines;

procedure insert_deal_adjs(p_header_id in number, p_sql in varchar2) is

l_ctr number:= 0;
l_rows number := 1000;
l_status varchar2(1);
b_first boolean := true;
t_pr_adj_val qpr_deal_adj_type;
t_adj_rec qpr_src_qtn_adj_type;
c_adj SYS_REFCURSOR;

begin
  log_debug('In price adjustments...');

  begin
    select 1 into l_status
    from qpr_pn_int_headers h
    where h.source_ref_header_id = p_header_id
    and h.instance_id = g_instance_id
    and h.source_id = g_source_id
    and h.pn_req_header_status_flag <> 'P';
  exception
    when no_data_found then
      log_debug('Quote status does not permit modifications');
      return;
  end;


    open c_adj for p_sql using p_header_id;
    loop
      fetch c_adj bulk collect into t_adj_rec limit l_rows;
      exit when t_adj_rec.count = 0;

      if b_first then
        b_first := false;

        delete qpr_pn_int_pr_adjs where source_ref_hdr_id = p_header_id
				and source_id = g_source_id
        and erosion_type = t_adj_rec(1).EROSION_TYPE;
      end if;

      for k in t_adj_rec.first..t_adj_rec.last loop
        t_pr_adj_val.SOURCE_ID(l_ctr) := t_adj_rec(k).SOURCE_ID;
        t_pr_adj_val.EROSION_TYPE(l_ctr) := t_adj_rec(k).EROSION_TYPE;
        t_pr_adj_val.EROSION_NAME(l_ctr) := t_adj_rec(k).EROSION_NAME;
        t_pr_adj_val.EROSION_DESC(l_ctr) := t_adj_rec(k).EROSION_DESC;
        t_pr_adj_val.EROSION_PER_UNIT(l_ctr) :=
                                          t_adj_rec(k).EROSION_PER_UNIT;
        t_pr_adj_val.EROSION_AMOUNT(l_ctr) := t_adj_rec(k).EROSION_AMOUNT;
        t_pr_adj_val.SRC_REF_HDR_ID(l_ctr) := t_adj_rec(k).SOURCE_REF_HDR_ID;
        t_pr_adj_val.SRC_REF_LINE_ID(l_ctr) := t_adj_rec(k).SOURCE_REF_LINE_ID;
        l_ctr := l_ctr + 1;
      end loop;


      forall i in t_pr_adj_val.src_ref_line_id.first..
					t_pr_adj_val.src_ref_line_id.last
        insert into qpr_pn_int_pr_adjs(pn_int_pr_adj_id,
                                       source_ref_hdr_id,
                                       source_ref_line_id,
                                       source_id,
                                       erosion_type,
                                       erosion_name,
                                       erosion_desc,
                                       erosion_per_unit,
                                       erosion_amount,
                                       creation_date,
                                       created_by,
                                       last_update_date,
                                       last_updated_by,
                                       last_update_login,
                                       program_application_id,
                                       program_id,
                                       request_id)
          values(qpr_pn_int_pr_adjs_s.nextval,
                 t_pr_adj_val.SRC_REF_HDR_ID(i),
                 t_pr_adj_val.src_ref_line_id(i),
                 t_pr_adj_val.source_id(i),
                 t_pr_adj_val.erosion_type(i),
                 t_pr_adj_val.erosion_name(i),
                 t_pr_adj_val.erosion_desc(i),
                 t_pr_adj_val.erosion_per_unit(i),
                 t_pr_adj_val.erosion_amount(i),
                  g_sys_date,
                 g_user_id,
                 g_sys_date,
                 g_user_id,
                 g_login_id, g_prg_appl_id , g_prg_id, g_request_id);

          t_pr_adj_val.source_id.delete;
          t_pr_adj_val.EROSION_TYPE.delete;
          t_pr_adj_val.EROSION_NAME.delete;
          t_pr_adj_val.EROSION_DESC.delete;
          t_pr_adj_val.EROSION_PER_UNIT.delete;
          t_pr_adj_val.EROSION_AMOUNT.delete;
          t_pr_adj_val.src_ref_hdr_id.delete;
          t_pr_adj_val.src_ref_line_id.delete;

      t_adj_rec.delete;
    end loop;
exception
  when OTHERS then
    log_debug(dbms_utility.format_error_backtrace);
    raise;
end insert_deal_adjs;

procedure fill_measure_data(errbuf out nocopy varchar2,
                          retcode out nocopy varchar2,
                          p_instance_id in number,
                          p_date_from in varchar2,
                          p_date_to in varchar2,
                          p_meas_type in varchar2,
                          p_header_id in number default 0) is

    db_link varchar2(150) := '';
    src_table varchar2(200);

    s_sql varchar2(30000) := '';

    l_rec_count number :=0;
    l_start_time number;
    l_end_time number;
    l_ret_code number;
    l_src_count number;
    l_inst_id number;
    l_req_int_hdr_id number;
    l_inst_type varchar2(30);

    cursor c_src_cols(m_type varchar2,m_ins_id number,m_src_tname varchar2, l_inst_type varchar2) is
            select distinct nvl(USER_SRC_COL_NAME,SRC_COL_NAME) SRC_COL_NAME,
            nvl(USER_TGT_COL_NAME, TGT_COL_NAME) TGT_COL_NAME
            from QPR_MEASURE_SOURCES
            where MEASURE_TYPE_CODE = m_type
            and INSTANCE_ID = m_ins_id
            and INSTANCE_TYPE = l_inst_type
            and nvl(user_src_tbl_name, src_tbl_name ) = m_src_tname
            order by TGT_COL_NAME;

    cursor c_srcs(m_type varchar2, m_ins_id number, l_inst_type varchar2)is
            select distinct nvl(USER_SRC_TBL_NAME, SRC_TBL_NAME) SRC_TBL_NAME,
                   TGT_TBL_NAME
            from QPR_MEASURE_SOURCES
            where MEASURE_TYPE_CODE = m_type
            and INSTANCE_ID = m_ins_id
            and INSTANCE_TYPE = l_inst_type
            order by TGT_TBL_NAME;
begin
    log_debug('Starting...');
    select hsecs into l_start_time from v$timer;
    log_debug('Start time :'||
                                      to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
    db_link := qpr_sr_util.get_dblink(p_instance_id);

    g_instance_id := p_instance_id;
    g_meas_type := p_meas_type;

    fnd_profile.get('CONC_REQUEST_ID', g_request_id);
    g_sys_date := sysdate;
    g_user_id := fnd_global.user_id;
    g_login_id := fnd_global.conc_login_id;
    g_prg_appl_id := fnd_global.prog_appl_id;
    g_prg_id := fnd_global.conc_program_id;

    if not qpr_sr_util.dm_parameters_ok then
      retcode:= 2;
      FND_MESSAGE.Set_Name ('QPR','QPR_NULL_PARAMETERS');
      FND_MSG_PUB.Add;
      log_debug('One or more mandatory parameters are not filled');
      return;
    end if;

    select instance_type into l_inst_type
    from qpr_instances
    where instance_id = p_instance_id;

    select count(*) into l_src_count
    from QPR_MEASURE_SOURCES
    where INSTANCE_ID = p_instance_id
    and MEASURE_TYPE_CODE = p_meas_type;

    if l_src_count > 0 then
      l_inst_id := p_instance_id;
    else
      l_inst_id := SEEDED_INSTANCE_ID;
    end if;

    for r_usr_src in c_srcs(p_meas_type, l_inst_id, l_inst_type) loop
	    log_debug('Fetching source columns ...');
        open c_src_cols(p_meas_type, l_inst_id,
  	                  r_usr_src.SRC_TBL_NAME, l_inst_type);
        fetch c_src_cols bulk collect into g_src_cols, g_trg_cols;
        close c_src_cols;

        src_table := r_usr_src.SRC_TBL_NAME || db_link ;

        if p_meas_type = OM_MEAS_TYPE_DEALINT or
           p_meas_type = ASO_MEAS_TYPE_DEALINT then
            s_sql := get_deal_sql(src_table, r_usr_src.TGT_TBL_NAME);
            if r_usr_src.TGT_TBL_NAME = DEAL_HEADER_TBL then
              s_sql := s_sql || ' and rownum < 2' ;
              l_req_int_hdr_id := insert_update_deal_hdr(
                                                         p_header_id,
                                                         s_sql);
            elsif r_usr_src.TGT_TBL_NAME = DEAL_LINE_TBL then
              -- since the sources are sorted by target tbl name the lines will
              -- come after header only
                insert_update_deal_lines(p_header_id,s_sql);
            else
                insert_deal_adjs(p_header_id, s_sql);
            end if;
        else
          s_sql := get_select_meas_sql(src_table, p_meas_type);
          insert_update_meas_data(p_date_from, p_date_to, s_sql);
        end if;
    end loop;
    select hsecs into l_end_time from v$timer;
    log_debug('End time :'|| to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
    log_debug('Time taken for loading(sec):' ||(l_end_time - l_start_time)/100);
exception
    when OTHERS then
      retcode := 2;
      errbuf  := 'ERROR: ' || substr(sqlerrm, 1, 1000);
      log_debug(substr(sqlerrm, 1, 1000));
      log_debug('CANNOT POPULATE FACT DATA');
end fill_measure_data;

procedure load_quote_data(errbuf out nocopy varchar2,
                           retcode out nocopy varchar2,
                           p_instance_id in number,
                           p_src_choice in number default 1,
                           p_quote_number in number default 0,
                           p_quote_version in number default 0,
                           p_order_type in varchar2 default null) is
l_dummy number;
begin
	begin
		select request_header_id into l_dummy
		from qpr_pn_request_hdrs_b
		where instance_id = p_instance_id
		and source_id = decode(p_src_choice,1, 660, 2, 697, p_src_choice)
		and source_ref_hdr_short_desc = (p_quote_number || ' - Ver '|| p_quote_version)
		and nvl(request_status, 'ACTIVE') = 'ACTIVE'
		and nvl(simulation_flag, 'Y') = 'N'
		and rownum < 2;

		retcode := 1;
		errbuf := 'Active Request ' || l_dummy || ' exist for this quote.';
		return;
	exception
		-- when no active requests are present then load quote --
		when NO_DATA_FOUND then
			load_quote_data_api(errbuf ,
											retcode ,
											p_instance_id ,
											p_src_choice ,
											null,
											p_quote_number ,
											p_quote_version ,
											p_order_type );

	end;
exception
    when OTHERS then
        retcode := 2;
        errbuf := 'ERROR: ' || substr(sqlerrm, 1, 1000);
        log_debug('ERROR IN LOADING QUOTE DATA');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end;

procedure load_quote_data_api(errbuf out nocopy varchar2,
                           retcode out nocopy varchar2,
                           p_instance_id in number,
                           p_src_choice in number default 1,
                           p_quote_header_id in number default null,
                           p_quote_number in number default 0,
                           p_quote_version in number default 0,
                           p_order_type in varchar2 default null) is
p_header_id number;
l_sql varchar2(1000);
src_tbl_name varchar2(200);
s_deal_type varchar2(30);
l_inst_type varchar2(30);
begin

  g_origin := p_src_choice;

  if p_instance_id is null then
    retcode := 2;
    FND_MESSAGE.Set_Name ('QPR','QPR_NULL_INSTANCE');
    FND_MSG_PUB.Add;
    errbuf := 'Instance Id cannot be null';
    return;
  end if;

  if (p_src_choice = 1 or p_src_choice = 660 )then
    s_deal_type := OM_MEAS_TYPE_DEALINT;
  elsif (p_src_choice = 2 or p_src_choice = 697) then
    s_deal_type := ASO_MEAS_TYPE_DEALINT;
  else
    s_deal_type := p_src_choice;
  end if;

  select distinct src_tbl_name into src_tbl_name
  from qpr_measure_sources
  where measure_type_code = s_deal_type
  and tgt_tbl_name = DEAL_HEADER_TBL
  and INSTANCE_TYPE = (select instance_type
			from qpr_instances
			where instance_id = p_instance_id);
  if p_quote_header_id is null then
	  l_sql := 'select quote_header_id, quote_header_sd, source_id from '
		  || src_tbl_name||qpr_sr_util.get_dblink(p_instance_id)
		  || ' where quote_number = ' || p_quote_number
		  || ' and quote_version =  ' || p_quote_version ;
	  if p_src_choice = 1 or p_src_choice = 660 then
	    l_sql := l_sql || ' and order_type_name = ''' || p_order_type || '''';
	  end if;
	  l_sql := l_sql || ' and rownum < 2';
  else
	  l_sql := 'select quote_header_id, quote_header_sd, source_id from '
		  || src_tbl_name||qpr_sr_util.get_dblink(p_instance_id)
		  || ' where quote_header_id = ' || p_quote_header_id;
	  l_sql := l_sql || ' and rownum < 2';
  end if;
  log_debug('SQL: '||l_sql);
  execute immediate l_sql into p_header_id, g_quote_hdr_sd, g_source_id;
  if nvl(p_header_id, 0) = 0 then
      retcode := 2;
      FND_MESSAGE.Set_Name ('QPR','QPR_NO_QUOTE');
      FND_MSG_PUB.Add;
      log_debug('Quote does not exist. ');
  else
     log_debug('Header_id: ' || p_header_id);
     fill_measure_data(errbuf,retcode, p_instance_id , null, null,
           s_deal_type,p_header_id);
  end if;

exception
    WHEN NO_DATA_FOUND then
       retcode := 2;
       log_debug('Quote does not exist.');
    when OTHERS then
        retcode := 2;
        errbuf := 'ERROR: ' || substr(sqlerrm, 1, 1000);
        log_debug('ERROR IN LOADING QUOTE DATA');
        log_debug(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        raise;
end load_quote_data_api;

function is_source_quote_changed(errbuf out nocopy varchar2,
                                  retcode out nocopy varchar2,
                                  p_instance_id in number,
                                  p_source_id in number,
                                  p_src_quote_header_id in number)
                                return varchar2 is
l_resp_cust qpr_pn_request_hdrs_b.customer_id%type;
l_resp_sales_rep qpr_pn_request_hdrs_b.sales_rep_id%type;
l_resp_sc qpr_pn_request_hdrs_b.sales_channel_code%type;
l_request_hdr_id qpr_pn_request_hdrs_b.request_header_id%type;
r_hdr qpr_pn_int_headers%rowtype;
r_lines qpr_pn_int_lines%rowtype;
l_hdr_matching boolean := false;
l_line_matching boolean := false;
l_org_id qpr_pn_lines.ORG_ID%type;
l_item_id qpr_pn_lines.inventory_item_id%type;
l_pt_id qpr_pn_lines.payment_term_id%type;
l_shm_code qpr_pn_lines.ship_method_code%type;
l_geo_id qpr_pn_lines.geography_id%type;
l_uom_code qpr_pn_lines.uom_code%type;
l_ord_qty qpr_pn_lines.ordered_qty%type;
l_price qpr_pn_lines.proposed_price%type;
l_curr_code qpr_pn_lines.currency_code%type;
l_quote_changed varchar2(1);
l_sql varchar2(10000);
l_line_cnt number;

c_ref SYS_REFCURSOR;

function fetch_sql(p_tgt_tbl_name varchar2) return varchar2 is
l_src_tbl varchar2(250);
l_sql varchar2(10000);

cursor c_src_cols(m_src_tname varchar2) is
  select distinct nvl(USER_SRC_COL_NAME,SRC_COL_NAME) SRC_COL_NAME,
        nvl(USER_TGT_COL_NAME,TGT_COL_NAME) TGT_COL_NAME
        from QPR_MEASURE_SOURCES src, qpr_instances inst
        where src.instance_type = inst.instance_type
        and inst.instance_id = p_instance_id
        and src.measure_type_code = decode(p_source_id, 660, 'OM_DEALINT',
                                            697, 'ASO_DEALINT')
        and nvl(src.user_src_tbl_name, src.src_tbl_name ) = m_src_tname
        order by TGT_COL_NAME;

begin
  select distinct src_tbl_name into l_src_tbl
  from qpr_measure_sources src, qpr_instances inst
  where src.instance_type = inst.instance_type
  and inst.instance_id = p_instance_id
  and src.measure_type_code = decode(p_source_id, 660, 'OM_DEALINT',
                                    697, 'ASO_DEALINT')
  and tgt_tbl_name = p_tgt_tbl_name;

  open c_src_cols(l_src_tbl);
  fetch c_src_cols bulk collect into g_src_cols, g_trg_cols;
  close c_src_cols;

  l_src_tbl := l_src_tbl || qpr_sr_util.get_dblink(p_instance_id);

  l_sql := get_deal_sql(l_src_tbl, p_tgt_tbl_name);

  return l_sql;
end fetch_sql;


begin
  l_quote_changed := 'N';
  -- read request_header details
  begin
    select req.CUSTOMER_ID, req.SALES_REP_ID, req.SALES_CHANNEL_CODE,
            req.request_header_id
    into l_resp_cust, l_resp_sales_rep, l_resp_sc, l_request_hdr_id
    from qpr_pn_request_hdrs_b req
    where instance_id = p_instance_id
    and source_id = p_source_id
    and source_ref_hdr_id = p_src_quote_header_id
    and request_status = 'ACTIVE'
    and rownum < 2;

    --get details from source ---
    l_sql := fetch_sql(DEAL_HEADER_TBL) ;
    l_sql := l_sql || ' and rownum < 2 ';

    open c_ref for l_sql using p_src_quote_header_id;
    fetch c_ref into r_hdr;
    close c_ref;

    if nvl(l_resp_cust,0) = nvl(r_hdr.CUSTOMER_ID,0) and
       nvl(l_resp_sales_rep,0) = nvl(r_hdr.SALES_REP_ID,0) and
       nvl(l_resp_sc, '*') = nvl(r_hdr.SALES_CHANNEL_CODE, '*') then
       l_hdr_matching := true;
    end if;
  exception
    when no_data_found then
      l_hdr_matching := false;
  end;

  if not l_hdr_matching then
    -- if hdr values are modified then quote is changed
    l_quote_changed := 'Y';
  else
  -- fetch line values from source -----

    l_sql := fetch_sql(DEAL_LINE_TBL);

    open c_ref for l_sql using p_src_quote_header_id;
    loop
      fetch c_ref into r_lines;
      exit when c_ref%notfound;

      l_line_matching := false;

      --read line details from pn_lines ----
      begin
        select ORG_ID,INVENTORY_ITEM_ID,ORIG_PAYMENT_TERM_ID,
              ORIG_SHIP_METHOD_CODE,
              GEOGRAPHY_ID,UOM_CODE,ORDERED_QTY,PROPOSED_PRICE,CURRENCY_CODE
        into l_org_id, l_item_id, l_pt_id, l_shm_code,
            l_geo_id, l_uom_code, l_ord_qty, l_price, l_curr_code
        from qpr_pn_lines
        where request_header_id = l_request_hdr_id
        and source_ref_line_id = r_lines.SOURCE_REF_LINE_ID
        and source_ref_hdr_id = r_lines.SOURCE_REF_HDR_ID
        and source_id = r_lines.SOURCE_ID
        and item_type_code <> 'DUMMY_PARENT'
        and rownum < 2;

        if nvl(l_org_id, 0) = nvl(r_lines.org_id,0) and
        nvl(l_item_id,0) = nvl(r_lines.inventory_item_id,0) and
        nvl(l_pt_id,0) = nvl(r_lines.payment_term_id,0) and
        nvl(l_shm_code,'*') = nvl(r_lines.ship_method_code, '*') and
        nvl(l_geo_id,0) = nvl(r_lines.geography_id, 0) and
        nvl(l_uom_code, '*') = nvl(r_lines.uom_code, '*') and
        nvl(l_ord_qty,0) = nvl(r_lines.ordered_qty,0) and
        nvl(l_price,0) = nvl(r_lines.proposed_price,0) and
        nvl(l_curr_code, '*') = nvl(r_lines.Currency_code, '*') then
          l_line_matching := true;
        end if;
      exception
        when NO_DATA_FOUND then
          l_line_matching := false;
      end;

      -- even if one line is not matching then quote does not match
      if not l_line_matching then
        l_quote_changed := 'Y';
        exit;
      end if;

    end loop;
    close c_ref;

    -- handle the case: header is matching- few lines have been deleted in
    -- source and the existing lines match.
    if l_quote_changed = 'N' then
      select count(*) into l_line_cnt
      from qpr_pn_lines
      where request_header_id = l_request_hdr_id
      and item_type_code <> 'DUMMY_PARENT';

      open c_ref for l_sql using p_src_quote_header_id;
      loop
        fetch c_ref into r_lines;
        exit when c_ref%notfound;
      end loop;

      if c_ref%rowcount <> l_line_cnt then
        l_quote_changed := 'Y';
      end if;
      close c_ref;
    end if;
  end if;

  return(l_quote_changed);
exception
  when others then
    retcode := 2;
    errbuf := sqlerrm;
    return(null);
end is_source_quote_changed;

END;


/
