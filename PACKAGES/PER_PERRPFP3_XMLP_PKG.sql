--------------------------------------------------------
--  DDL for Package PER_PERRPFP3_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPFP3_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPFP3S.pls 120.3 2008/05/15 09:12:57 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1 varchar2(240);
	P_CONC_REQUEST_ID	number;
	P_person_id	number;
	P_SPECIAL_INFO_SEGS	varchar2(240) := 'lpad('' '',240)';
	P_ass_scl_segs	varchar2(2000) := 'lpad('' '',2000)';
	P_ass_cost_segs	varchar2(240) := 'lpad('' '',240)';
	P_EXT_ACT_SEGS	varchar2(2000) := 'lpad('' '',2000)';
	C_ext_acct_id	number;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	--C_details	varchar2(900) := := 'ADD1.ADDRESS_LINE1' ;
	  C_details	varchar2(900) :=  'ADD1.ADDRESS_LINE1' ;
	--C_cont_details	varchar2(240) := := 'ADD1.ADDRESS_LINE1' ;
	  C_cont_details	varchar2(240) :=  'ADD1.ADDRESS_LINE1' ;
	C_requirement_desc	varchar2(240);
	C_requirement_value	varchar2(240);
	C_header_name	varchar2(350);
	C_pay_meth_count	number;
	--C_emp_df_details	varchar2(2000) := := 'peo.ATTRIBUTE1' ;
	  C_emp_df_details	varchar2(2000) :=  'peo.ATTRIBUTE1' ;
	--C_emp_leg_df_details	varchar2(2000) := := 'pp.per_information1' ;
	  C_emp_leg_df_details	varchar2(2000) :=  'pp.per_information1' ;
	--C_add_df_details	varchar2(600) := := 'addr.ADDR_ATTRIBUTE1' ;
	  C_add_df_details	varchar2(600) :=  'addr.ADDR_ATTRIBUTE1' ;
	--C_cont_df_details	varchar2(2000) := := 'con.cont_attribute1' ;
	  C_cont_df_details	varchar2(2000) :=  'con.cont_attribute1' ;
	--C_app_df_details	varchar2(2000) := := 'app.APPL_ATTRIBUTE1' ;
	  C_app_df_details	varchar2(2000) :=  'app.APPL_ATTRIBUTE1' ;
	  c_app_ass_df_details	varchar2(400) :=  'as'||'g.ass_attribute1' ;
	--C_sec_ass_df_details	varchar2(32000) := := 'rpad(sst.attribute1,32000,' ')' ;
	  C_sec_ass_df_details	varchar2(32000) :=  'rpad(sst.attribute1,32000,'' '')' ;
	--C_per_serv_df_details	varchar2(32000) := := 'rpad(A.ATTRIBUTE1,32000,' ')' ;
	  C_per_serv_df_details	varchar2(32000) :=  'rpad(A.ATTRIBUTE1,32000,'' '')' ;
	--C_temp	varchar2(240) := := 'got nothing mate' ;
	  C_temp	varchar2(240) :=  'got nothing mate' ;
	C_add_df_label	varchar2(600);
	C_emp_df_label	varchar2(600);
	C_emp_leg_df_label	varchar2(600);
	C_cont_df_label	varchar2(600);
	C_app_df_label	varchar2(600);
	C_app_ass_df_label	varchar2(600);
	--C_app_sec_status_details	varchar2(600) := := 'sst.attribute1' ;
	  C_app_sec_status_details	varchar2(600) :=  'sst.attribute1' ;
	C_app_sec_status_label	varchar2(600);
	--C_inter_df_details	varchar2(32000) := := 'rpad(a.attribute1,32000,' ')' ;
	  C_inter_df_details	varchar2(32000) :=  'rpad(a.attribute1,32000,'' '')' ;
	--C_inter_df_label	varchar2(32000) := := '''' ;
	  C_inter_df_label	varchar2(32000) :=  '''''' ;
	--C_sec_ass_df_label	varchar2(32000) := := '''' ;
	  C_sec_ass_df_label	varchar2(32000) :=  '''''' ;
	--C_ass_df_details	varchar2(32000) := := 'rpad(asg.ass_attribute1,32000,' ')' ;
	  C_ass_df_details	varchar2(32000) :=  'rpad(as'||'g.ass_attribute1,32000,'' '')' ;
	--C_ass_df_label	varchar2(32000) := := 'rpad(asg.ass_attribute1,32000,' ')' ;
	  C_ass_df_label	varchar2(32000) :=  'rpad(as'||'g.ass_attribute1,32000,'' '')' ;
	--C_fur_info_df_details	varchar2(32000) := := 'rpad(f.aei_attribute1,32000,' ')' ;
	  C_fur_info_df_details	varchar2(32000) :=  'rpad(f.aei_attribute1,32000,'' '')' ;
	--C_fur_info_df_label	varchar2(32000) := := '''' ;
	  C_fur_info_df_label	varchar2(32000) :=  '''''' ;
	--C_fur_info_ddf_details	varchar2(32000) := := 'rpad(paei.aei_information1,32000,' ')' ;
	  C_fur_info_ddf_details	varchar2(32000) :=  'rpad(paei.aei_information1,32000,'' '')' ;
	--C_fur_info_ddf_label	varchar2(32000) := := '''' ;
	  C_fur_info_ddf_label	varchar2(32000) :=  '''''' ;
	C_cost_id_flex_num	number;
	C_scl_id_flex_num	number;
	C_scl_desc	varchar2(3600);
	C_scl_value	varchar2(2000);
	C_cost_desc	varchar2(240);
	C_cost_values	varchar2(240);
	--C_ppm_df_details	varchar2(32000) := := 'rpad(ppm.attribute1,32000,' ')' ;
	  C_ppm_df_details	varchar2(32000) :=  'rpad(ppm.attribute1,32000,'' '')' ;
	--C_ppm_df_label	varchar2(32000) := := '''' ;
	  C_ppm_df_label	varchar2(32000) :=  '''''' ;
	C_ext_act_desc	varchar2(600);
	C_ext_act_values	varchar2(2000);
	--C_ele_df_details	varchar2(32000) := := 'rpad(ee.attribute1,32000,' ')' ;
	  C_ele_df_details	varchar2(32000) :=  'rpad(ee.attribute1,32000,'' '')' ;
	--C_ele_df_label	varchar2(32000) := := '''' ;
	  C_ele_df_label	varchar2(32000) :=  '''''' ;
	C_ele_cost_desc	varchar2(240);
	C_ele_cost_values	varchar2(240);
	--C_event_df_details	varchar2(600) := := 'a.attribute1' ;
	  C_event_df_details	varchar2(600) :=  'a.attribute1' ;
	C_event_df_label	varchar2(600);
	--C_book_df_details	varchar2(600) := := 'b.attribute1' ;
	  C_book_df_details	varchar2(600) :=  'b.attribute1' ;
	C_book_df_label	varchar2(600);
	--C_special_df_details	varchar2(600) := := 'jr.attribute1' ;
	  C_special_df_details	varchar2(600) :=  'jr.attribute1' ;
	C_special_df_label	varchar2(600);
	--C_per_serv_df_label	varchar2(32000) := := '''' ;
	  C_per_serv_df_label	varchar2(32000) :=  '''''' ;
	--C_absence_df_details	varchar2(600) := := 'a.attribute1' ;
	  C_absence_df_details	varchar2(600) :=  'a.attribute1' ;
	C_absence_df_label	varchar2(600);
	--C_subtitle	varchar2(100) := := 'Full Assignment Details' ;
	  C_subtitle	varchar2(100) :=  'Full Assignment Details' ;
	C_END_OF_TIME	date;
	C_currency_code	varchar2(20);
	function BeforeReport return boolean  ;
	function c_get_fur_info_flexformula(information_type in varchar2) return number  ;
	function C_scl_segsFormula return Number  ;
	function c_get_ext_acctformula(category in varchar2, territory_code in varchar2) return character  ;
	function AfterReport return boolean  ;
	Function C_ext_acct_id_p return number;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_details_p return varchar2;
	Function C_cont_details_p return varchar2;
	Function C_requirement_desc_p return varchar2;
	Function C_requirement_value_p return varchar2;
	Function C_header_name_p return varchar2;
	Function C_pay_meth_count_p return number;
	Function C_emp_df_details_p return varchar2;
	Function C_emp_leg_df_details_p return varchar2;
	Function C_add_df_details_p return varchar2;
	Function C_cont_df_details_p return varchar2;
	Function C_app_df_details_p return varchar2;
	Function c_app_ass_df_details_p return varchar2;
	Function C_sec_ass_df_details_p return varchar2;
	Function C_per_serv_df_details_p return varchar2;
	Function C_temp_p return varchar2;
	Function C_add_df_label_p return varchar2;
	Function C_emp_df_label_p return varchar2;
	Function C_emp_leg_df_label_p return varchar2;
	Function C_cont_df_label_p return varchar2;
	Function C_app_df_label_p return varchar2;
	Function C_app_ass_df_label_p return varchar2;
	Function C_app_sec_status_details_p return varchar2;
	Function C_app_sec_status_label_p return varchar2;
	Function C_inter_df_details_p return varchar2;
	Function C_inter_df_label_p return varchar2;
	Function C_sec_ass_df_label_p return varchar2;
	Function C_ass_df_details_p return varchar2;
	Function C_ass_df_label_p return varchar2;
	Function C_fur_info_df_details_p return varchar2;
	Function C_fur_info_df_label_p return varchar2;
	Function C_fur_info_ddf_details_p return varchar2;
	Function C_fur_info_ddf_label_p return varchar2;
	Function C_cost_id_flex_num_p return number;
	Function C_scl_id_flex_num_p return number;
	Function C_scl_desc_p return varchar2;
	Function C_scl_value_p return varchar2;
	Function C_cost_desc_p return varchar2;
	Function C_cost_values_p return varchar2;
	Function C_ppm_df_details_p return varchar2;
	Function C_ppm_df_label_p return varchar2;
	Function C_ext_act_desc_p return varchar2;
	Function C_ext_act_values_p return varchar2;
	Function C_ele_df_details_p return varchar2;
	Function C_ele_df_label_p return varchar2;
	Function C_ele_cost_desc_p return varchar2;
	Function C_ele_cost_values_p return varchar2;
	Function C_event_df_details_p return varchar2;
	Function C_event_df_label_p return varchar2;
	Function C_book_df_details_p return varchar2;
	Function C_book_df_label_p return varchar2;
	Function C_special_df_details_p return varchar2;
	Function C_special_df_label_p return varchar2;
	Function C_per_serv_df_label_p return varchar2;
	Function C_absence_df_details_p return varchar2;
	Function C_absence_df_label_p return varchar2;
	Function C_subtitle_p return varchar2;
	Function C_END_OF_TIME_p return date;
	Function C_currency_code_p return varchar2;
	function M_1FormatTrigger return number;
	function M_5FormatTrigger return number;
	function M_6FormatTrigger return number;
	function M_8FormatTrigger return number;
END PER_PERRPFP3_XMLP_PKG;

/
