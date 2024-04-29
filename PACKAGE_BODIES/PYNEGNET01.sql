--------------------------------------------------------
--  DDL for Package Body PYNEGNET01
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYNEGNET01" AS
/*$Header: pyusngn1.pkb 115.4 99/07/17 06:45:06 porting ship  $*/
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1996 Oracle Corporation US                      *
 *                                                                *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation US       *
 *                                                                *
 *                                                                *
 *                                                                *
 ****************************************************************** */
/*
 Name        : pynegnet01  (BODY)

 Description : This package declares procedures required to
               create all objects for processing negative net
               values in payroll processing.


 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 110.0   03/03/98 M.Lisiecki            Bug 563295.
                                        Based on original pyusngnt.pkb and
                                        modified to accomodate City_HT_WK,
                                        Workers Compensation EE and
                                        Workers Compensation2 EE.
                                        Additions:
                                        Bug 585429. Changed formula's CURR_ARR to be a negative value
                                        and  changed all arrears element's balance feeds from add to
                                        substr and vice versa.
                                        Update all formula results for arrears elements to the
                                        negative ammount.
 110.1  14/04/98  M.Lisiecki            Removed changes introduced to fix bug 585429 as it proved not
                                        to be a bug.
 115.1  21/04/99  S.Grant               Multi-radix changes.
 115.4  16-jun-1999 achauhan            replaced dbms_output with hr_utility.trace
 ================================================================= */
--
-- ====================== declare tables ============================
--
  TYPE char_tabtype IS TABLE OF VARCHAR2(50)
    INDEX BY BINARY_INTEGER;
  TYPE num_tabtype  IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
-- ==================================================================
  arrear_bal_name_list 		char_tabtype;
  proto_bal_name_list 		char_tabtype;
  Whld_bal_feed_name_list 	char_tabtype;
--
  Element_name_list 		char_tabtype;
  Element_priority_list 	num_tabtype;
--
  post_inp_value_list 		char_tabtype;
  post_res1_out_name_list 	char_tabtype;
  post_res1_inp_name_list 	char_tabtype;
  post_res1_out_unit_list 	char_tabtype;
  post_res4_out_name_list 	char_tabtype;
--
  arr_inp_value_list 		char_tabtype;
  arr_unit_list 		char_tabtype;
  arr_bal_feed_name_list 	char_tabtype;
  arr_bal_feed_rule_list 	char_tabtype;
--
  ff_repl1 			char_tabtype;
  ff_repl2 			char_tabtype;
  ff_repl3 			char_tabtype;
--
  jd_list 			char_tabtype;
--
  vertex_res_out_name_list 	char_tabtype;
--
-- =================================================================
--
  arrear_bal_id_list num_tabtype;
  whld_bal_feed_id_list num_tabtype;
--
  arr_element_id_list num_tabtype;
  arr_inp_id_list num_tabtype;
  arr_bal_feed_id_list num_tabtype;
  arr_assign_list num_tabtype;
--
  post_element_id_list num_tabtype;
  post_inp_id_list num_tabtype;
--
  ff_id_list num_tabtype;
--
-- ===================== end tables ================================
--
-- ===================== variables =================================
--
  v_ff_post_text 		VARCHAR2(3000);
  v_effective_start_date 	DATE 	:= TO_DATE('01/01/0001','DD/MM/YYYY');
  v_effective_end_date   	DATE 	:= TO_DATE('31/12/4712','DD/MM/YYYY');
  v_sysdate 			DATE 	:= SYSDATE;
  --
  v_legislation_code 		VARCHAR2(30) 	:= 'US';
  v_user 			VARCHAR2(20) 	:= USER;
  v_uid 			NUMBER 		:= UID;
  --
  v_formula_type_id 		NUMBER;
  v_uom 			VARCHAR2(10) 	:= 'Money';
  v_currency_code 		VARCHAR2(10) 	:= 'USD';
  --
  -- The business group name or id is needed in some cases.
  --
  v_business_group_name 	VARCHAR2(80)	;
  v_business_group_id 		NUMBER 	;
  --
  v_arr_inp_cnt 		BINARY_INTEGER 	:= 1;
  v_post_inp_cnt 		BINARY_INTEGER 	:= 1;
  --
  v_total_elements		BINARY_INTEGER := 18;
  v_total_balances		BINARY_INTEGER := 13;
  --
  v_run_results_exist		VARCHAR2(1)	:= 'N';
  --
  -- Bug 563295. mlisieck.
  v_tax_arrears_id              NUMBER := 0;

--
-- ===================== end variables =============================
--
-- ===================== initialize variables ======================
--
  PROCEDURE init_ff_post_text
  IS
  BEGIN
  --
  v_ff_post_text := '
    /* $Header: pyusngn1.pkb 115.4 99/07/17 06:45:06 porting ship  $ */
    Inputs are
	jurisdiction(text),
    	jd_su(text),
    	jd_wk(text),
    	jd_sc(text),
    	jd_rs(text)

    default for jd_sc is ''00-00000''

    CUR_ARR 		= 0
    CUR_NET 		= NET_ASG_GRE_RUN
    CUR_TAX 		= {REPL1}WITHHELD_ASG{REPL2}GRE_RUN
    CUR_ARR_TAKEN 	= {REPL1}ARREARS_ASG{REPL2}GRE_RUN

    CUR_STEP = 0
    ARR_RET_MSG = ''{REPL3} Arrears created''


     IF CUR_NET >= 0 then

	RETURN

     ELSE
	(
	 if CUR_TAX <> 0  and CUR_ARR_TAKEN = 0  THEN
       		(
		  CUR_STEP = CUR_TAX + CUR_NET

		  IF  CUR_STEP <= 0  THEN

		         CUR_ARR = CUR_TAX
	          ELSE
         		 CUR_ARR = -1 * CUR_NET
		)
     	else

		CUR_ARR = 0
		ARR_RET_MSG = '' ''
	)

     RETURN
      jurisdiction,
      jd_su,
      jd_wk,
      jd_sc,
      jd_rs,
      CUR_ARR,
     ARR_RET_MSG'
;
  --
  select formula_type_id
  into   v_formula_type_id
  from	 ff_formula_types
  where  formula_type_name = 'Oracle Payroll'
  ;

  END init_ff_post_text;

-- ===================== end initialize variables ==================
--
-- =================== initialize tables ===========================
--
--
-- ===================== initialize replacements for ff text =======
--
  PROCEDURE init_ff_repl
  IS
  BEGIN

  ff_repl1 (1) := 'SUI_EE_';
  ff_repl2 (1) := '_JD_';
  ff_repl3 (1) := 'SUI_EE ';

  ff_repl1 (2) := 'CITY_';
  ff_repl2 (2) := '_JD_';
  ff_repl3 (2) := 'CITY_WK ';

  -- Bug 563295. mlisieck.
  ff_repl1 (3) := 'HEAD_TAX_';
  ff_repl2 (3) := '_JD_';
  ff_repl3 (3) := 'HEAD_TAX';

  ff_repl1 (4) := 'COUNTY_';
  ff_repl2 (4) := '_JD_';
  ff_repl3 (4) := 'COUNTY_WK ';

  ff_repl1 (5) := 'SDI_EE_';
  ff_repl2 (5) := '_JD_';
  ff_repl3 (5) := 'SDI_EE ';

  ff_repl1 (6) := 'SIT_';
  ff_repl2 (6) := '_JD_';
  ff_repl3 (6) := 'SIT_WK ';

  ff_repl1 (7) := 'SCHOOL_';
  ff_repl2 (7) := '_JD_';
  ff_repl3 (7) := 'CITY_SC_WK ';

  ff_repl1 (8) := 'SCHOOL_';
  ff_repl2 (8) := '_JD_';
  ff_repl3 (8) := 'COUNTY_SC_WK ';

  ff_repl1 (9) := 'WORKERS_COMP_';
  ff_repl2 (9) := '_JD_';
  ff_repl3 (9) := 'WORKERS_COMP';

  ff_repl1 (10)  := 'WORKERS_COMP2_';
  ff_repl2 (10) := '_JD_';
  ff_repl3 (10) := 'WORKERS_COMPE2';

  ff_repl1 (11) := 'SCHOOL_';
  ff_repl2 (11) := '_JD_';
  ff_repl3 (11) := 'CITY_SC_RS ';

  ff_repl1 (12) := 'SCHOOL_';
  ff_repl2 (12) := '_JD_';
  ff_repl3 (12) := 'COUNTY_SC_RS ';

  ff_repl1 (13) := 'CITY_';
  ff_repl2 (13) := '_JD_';
  ff_repl3 (13) := 'CITY_RS ';

  ff_repl1 (14) := 'COUNTY_';
  ff_repl2 (14) := '_JD_';
  ff_repl3 (14) := 'COUNTY_RS ';

  ff_repl1 (15) := 'SIT_';
  ff_repl2 (15) := '_JD_';
  ff_repl3 (15) := 'SIT_RS ';

  ff_repl1 (16) := 'FIT_';
  ff_repl2 (16) := '_';
  ff_repl3 (16) := 'FIT ';

  ff_repl1 (17) := 'MEDICARE_EE_';
  ff_repl2 (17) := '_';
  ff_repl3 (17) := 'MEDICARE_EE ';

  ff_repl1 (18) := 'SS_EE_';
  ff_repl2 (18) := '_';
  ff_repl3 (18) := 'SS_EE ';

  END init_ff_repl;
--
-- ===================== init_arrear_bal_name  =====================
--
  PROCEDURE init_arrear_bal_name
  IS
  BEGIN

  arrear_bal_name_list (1) := 'FIT Arrears';
  arrear_bal_name_list (2) := 'Medicare EE Arrears';
  arrear_bal_name_list (3) := 'Head Tax Arrears';
  arrear_bal_name_list (4) := 'SS EE Arrears';
  arrear_bal_name_list (5) := 'SUI EE Arrears';
  arrear_bal_name_list (6) := 'SDI EE Arrears';
  arrear_bal_name_list (7) := 'SIT Arrears';
  arrear_bal_name_list (8) := 'County Arrears';
  arrear_bal_name_list (9) := 'Workers Comp Arrears';
  arrear_bal_name_list (10) := 'Workers Comp2 Arrears';
  arrear_bal_name_list (11) := 'City Arrears';
  arrear_bal_name_list (12) := 'School Arrears';
  arrear_bal_name_list (13) := 'Tax Arrears';
  END init_arrear_bal_name;
--
-- ===================== init_proto_bal_name  =====================
--
  PROCEDURE init_proto_bal_name
  IS
  BEGIN
  proto_bal_name_list (1) := 'FIT Withheld';
  proto_bal_name_list (2) := 'Medicare EE Withheld';
  proto_bal_name_list (3) := 'Head Tax Withheld';
  proto_bal_name_list (4) := 'SS EE Withheld';
  proto_bal_name_list (5) := 'SUI EE Withheld';
  proto_bal_name_list (6) := 'SDI EE Withheld';
  proto_bal_name_list (9) := 'SIT Withheld';
  proto_bal_name_list (8) := 'County Withheld';
  proto_bal_name_list (9) := 'Workers Comp Withheld';
  proto_bal_name_list (10) := 'Workers Comp2 Withheld';
  proto_bal_name_list (11) := 'City Withheld';
  proto_bal_name_list (12) := 'School Withheld';
  proto_bal_name_list (13) := 'Tax Deductions';
  END init_proto_bal_name;
--
-- ===================== init_element_name  =====================
--
  PROCEDURE init_element_name
  IS
  BEGIN
  element_name_list (1) := 'SUI_EE_';
  element_name_list (2) := 'CITY_WK_';
  element_name_list (3) := 'CITY_HT_WK_';
  element_name_list (4) := 'COUNTY_WK_';
  element_name_list (5) := 'SDI_EE_';
  element_name_list (6) := 'SIT_WK_';
  element_name_list (7) := 'CITY_SC_WK_';
  element_name_list (8) := 'COUNTY_SC_WK_';
  element_name_list (9) := 'WORKERS_COMP_EE_';
  element_name_list (10) := 'WORKERS_COMP2_EE_';
  element_name_list (11) := 'CITY_SC_RS_';
  element_name_list (12) := 'COUNTY_SC_RS_';
  element_name_list (13) := 'CITY_RS_';
  element_name_list (14) := 'COUNTY_RS_';
  element_name_list (15) := 'SIT_RS_';
  element_name_list (16) := 'FIT_';
  element_name_list (17) := 'MEDICARE_EE_';
  element_name_list (18) := 'SS_EE_';
  --
  element_priority_list (1)	:= 4250;
  element_priority_list (2)	:= 4250;
  element_priority_list (3)     := 4250;
  element_priority_list (4)	:= 4250;
  element_priority_list (5)	:= 4250;
  element_priority_list (6) 	:= 4250;

  element_priority_list (7)	:= 4260;
  element_priority_list (8)	:= 4260;
  element_priority_list (9)     := 4260;
  element_priority_list (10)    := 4260;
  element_priority_list (11)	:= 4260;
  element_priority_list (12)	:= 4260;
  element_priority_list (13)	:= 4260;
  element_priority_list (14)	:= 4260;
  element_priority_list (15)	:= 4260;

  element_priority_list (16)	:= 4270;
  element_priority_list (17)	:= 4270;
  element_priority_list (18)	:= 4270;

  END init_element_name;
--
-- ===================== init_arr_assign_list  =====================
--
  PROCEDURE init_arr_assign_list
  IS
  BEGIN
  arr_assign_list (1) := 5;
  arr_assign_list (2) := 11;
  arr_assign_list (3) := 3;
  arr_assign_list (4) := 8;
  arr_assign_list (5) := 6;
  arr_assign_list (6) := 12;
  arr_assign_list (7) := 12;
  arr_assign_list (8) := 12;
  arr_assign_list (9) := 9;
  arr_assign_list (10) := 10;
  arr_assign_list (11) := 12;
  arr_assign_list (12) := 12;
  arr_assign_list (13) := 11;
  arr_assign_list (14) := 8;
  arr_assign_list (15) := 7;
  arr_assign_list (16) := 1;
  arr_assign_list (17) := 2;
  arr_assign_list (18) := 4;
  END init_arr_assign_list;
--
-- ===================== init_other_variables =====================
  PROCEDURE init_other_variables
  IS
  el_cnt              binary_integer := 1;
  total_el            binary_integer;
  inp_cnt             BINARY_INTEGER  := 1;
  bal_cnt             BINARY_INTEGER  := 1;
  total_post_inp      BINARY_INTEGER  := 5;
  total_arr_inp       BINARY_INTEGER  := 2;

  cursor crs_post_element_type_id (el_cnt number) is
    select element_type_id from pay_element_types_f
      where element_name = element_name_list (el_cnt) || 'POST_VERTEX';

  cursor crs_post_input_value_id (p_element_type_id number, p_inp_cnt number) is
    select input_value_id from pay_input_values_f
      where element_type_id = p_element_type_id and
        name = post_inp_value_list(p_inp_cnt);

  cursor crs_arr_element_type_id (el_count number) is
    select element_type_id from pay_element_types_f
      where element_name = element_name_list (el_count) || 'ARR';

  cursor crs_arr_input_value_id (p_element_type_id number, p_inp_cnt number) is
    select input_value_id from pay_input_values_f
      where element_type_id = p_element_type_id and
         name = arr_inp_value_list(p_inp_cnt);

  cursor crs_arr_bal_id (p_bal_cnt number) is
    select balance_type_id from pay_balance_types
      where balance_name = arrear_bal_name_list (p_bal_cnt);


  BEGIN

   total_el := 18;

   -- need to populate ids of elements that will not be created.
   --
   while (el_cnt <= total_el) loop

     if el_cnt not in (3,9,10) then

       -- post_vertex element
       open crs_post_element_type_id(el_cnt);
       fetch crs_post_element_type_id into post_element_id_list (el_cnt);

       -- post_vertex element's inputs
       inp_cnt := 1;
       while inp_cnt <= total_post_inp loop
         open crs_post_input_value_id (post_element_id_list (el_cnt), inp_cnt);
         fetch crs_post_input_value_id into post_inp_id_list ((el_cnt-1)*5+inp_cnt);
         close crs_post_input_value_id;
         inp_cnt := inp_cnt + 1;
       end loop;

       close crs_post_element_type_id;

       -- arrears element
       open crs_arr_element_type_id(el_cnt);
       fetch crs_arr_element_type_id into arr_element_id_list (el_cnt);

       inp_cnt := 1;
       -- arrears element's inputs
       while inp_cnt <= total_arr_inp loop
        open crs_arr_input_value_id (arr_element_id_list (el_cnt), inp_cnt);
        fetch crs_arr_input_value_id into arr_inp_id_list((el_cnt-1)*2+inp_cnt);
        close crs_arr_input_value_id;
        inp_cnt := inp_cnt + 1;
       end loop;

       close crs_arr_element_type_id;

    end if;

    el_cnt := el_cnt + 1;

  end loop;
  --
  while bal_cnt <=  v_total_balances loop
    open crs_arr_bal_id (bal_cnt);
    fetch crs_arr_bal_id into arrear_bal_id_list(bal_cnt);
    close crs_arr_bal_id;
    bal_cnt := bal_cnt + 1;
  end loop;

END init_other_variables;
--
-- ===================== init_jd_list  =====================
--
PROCEDURE init_jd_list
IS
BEGIN
  jd_list (1) := 'JD_WK';
  jd_list (2) := 'JD_WK';
  jd_list (3) := 'JD_RS';
  jd_list (4) := 'JD_WK';
  jd_list (5) := 'JD_WK';
  jd_list (6) := 'JD_SC';
  jd_list (7) := 'JD_SC';
  jd_list (8) := 'JD_SC';
  jd_list (9) := 'JD_WK';
  jd_list (10) := 'JD_WK';
  jd_list (11) := 'JD_SC';
  jd_list (12) := 'JD_RS';
  jd_list (13) := 'JD_RS';
  jd_list (14) := 'JD_RS';
  jd_list (15) := 'JD_RS';
  jd_list (16) := 'JD_RS';
  jd_list (17) := 'JD_RS';
  jd_list (18) := 'JD_XX';
  END init_jd_list;
--
-- ===================== init_post_inp_value  =====================
--
  PROCEDURE init_post_inp_value
  IS
  BEGIN
  post_inp_value_list (1) := 'Jurisdiction';
  post_inp_value_list (2) := 'jd_su';
  post_inp_value_list (3) := 'jd_wk';
  post_inp_value_list (4) := 'jd_sc';
  post_inp_value_list (5) := 'jd_rs';
  END init_post_inp_value;
--
-- ===================== init_post_res1_out  =====================
--
  PROCEDURE init_post_res1_out
  IS
  BEGIN
  post_res1_out_name_list (1) := 'CUR_ARR';
  post_res1_out_name_list (2) := 'JURISDICTION';
  END init_post_res1_out;
--
-- ===================== init_post_res1_inp  =====================
--
  PROCEDURE init_post_res1_inp
  IS
  BEGIN
  post_res1_inp_name_list (1) := 'Pay Value';
  post_res1_inp_name_list (2) := 'Jurisdiction';
  END init_post_res1_inp;
--
-- ===================== init_post_res1_unit  =====================
--
  PROCEDURE init_post_res1_unit
  IS
  BEGIN
  post_res1_out_unit_list (1) := 'Money';
  post_res1_out_unit_list (2) := 'Character';
  END init_post_res1_unit;
--
-- ===================== init_post_res4_out  =====================
--
  PROCEDURE init_post_res4_out
  IS
  BEGIN
  post_res4_out_name_list (1) := 'JD_WK';
  post_res4_out_name_list (2) := 'JD_SU';
  post_res4_out_name_list (3) := 'JD_WK';
  post_res4_out_name_list (4) := 'JD_SC';
  post_res4_out_name_list (5) := 'JD_RS';
  END init_post_res4_out;
--
-- ===================== init_arr_inp_value  =====================
--
  PROCEDURE init_arr_inp_value
  IS
  BEGIN
  arr_inp_value_list (1) := 'Pay Value';
  arr_inp_value_list (2) := 'Jurisdiction';
  END init_arr_inp_value;
--
-- ===================== init_arr_unit  =====================
--
  PROCEDURE init_arr_unit
  IS
  BEGIN
  arr_unit_list (1) := 'Money';
  arr_unit_list (2) := 'Character';
  END init_arr_unit;
--
-- ===================== init_arr_bal_feed_name  =====================
--
  PROCEDURE init_arr_bal_feed_name
  IS
  BEGIN
  arr_bal_feed_name_list (1) := 'Tax Deductions';
  arr_bal_feed_name_list (2) := 'Net';
  arr_bal_feed_name_list (3) := 'Payments';
  END init_arr_bal_feed_name;
--
-- ===================== init_arr_bal_feed_id  =====================
--
  PROCEDURE init_arr_bal_feed_id
  IS
  lc_name VARCHAR2(80);
  feed_cnt NUMBER := 1;
  total_feed NUMBER := 3;
  ln_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.init_arr_bal_feed_id',1);
  --
  	WHILE feed_cnt <= total_feed
  	LOOP
  		lc_name := arr_bal_feed_name_list (feed_cnt);
  		SELECT balance_type_id
  		INTO ln_id
  		FROM pay_balance_types
  		WHERE balance_name = lc_name;
  		arr_bal_feed_id_list (feed_cnt) := ln_id;
  		feed_cnt := feed_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.init_arr_bal_feed_id',2);
  --
  END init_arr_bal_feed_id;
--
-- ===================== init_vertex_results  =====================
--
  PROCEDURE init_vertex_results is
  BEGIN
  vertex_res_out_name_list (1) := 'SUI_GEO';
  vertex_res_out_name_list (2) := 'SUI_GEO';
  vertex_res_out_name_list (3) := 'WCITY_GEO';
  vertex_res_out_name_list (4) := 'SCHOOL_GEO';
  vertex_res_out_name_list (5) := 'RCITY_GEO';
  END init_vertex_results;
--
-- ===================== init_whld_bal_feed_name  =====================
--
  PROCEDURE init_whld_bal_feed_name
  IS
  BEGIN
  whld_bal_feed_name_list (1) := 'SUI EE Withheld';
  whld_bal_feed_name_list (2) := 'City Withheld';
  whld_bal_feed_name_list (3) := 'Head Tax Withheld';
  whld_bal_feed_name_list (4) := 'County Withheld';
  whld_bal_feed_name_list (5) := 'SDI EE Withheld';
  whld_bal_feed_name_list (6) := 'SIT Withheld';
  whld_bal_feed_name_list (7) := 'School Withheld';
  whld_bal_feed_name_list (8) := 'School Withheld';
  whld_bal_feed_name_list (9) := 'Workers Comp Withheld';
  whld_bal_feed_name_list (10) := 'Workers Comp2 Withheld';
  whld_bal_feed_name_list (11) := 'School Withheld';
  whld_bal_feed_name_list (12) := 'School Withheld';
  whld_bal_feed_name_list (13) := 'City Withheld';
  whld_bal_feed_name_list (14) := 'County Withheld';
  whld_bal_feed_name_list (15) := 'SIT Withheld';
  whld_bal_feed_name_list (16) := 'FIT Withheld';
  whld_bal_feed_name_list (17) := 'Medicare EE Withheld';
  whld_bal_feed_name_list (18) := 'SS EE Withheld';
  END init_whld_bal_feed_name;
--
-- ===================== init_whld_bal_feed_id  =====================
--
  PROCEDURE init_whld_bal_feed_id
  IS
  lc_name VARCHAR2(80);
  feed_cnt NUMBER := 1;
  total_feed NUMBER := v_total_elements;
  ln_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.init_whld_bal_feed_id',1);
  --
  	WHILE feed_cnt <= total_feed
  	LOOP
  		lc_name := whld_bal_feed_name_list (feed_cnt);
  		SELECT balance_type_id
  		INTO ln_id
  		FROM pay_balance_types
  		WHERE balance_name = lc_name;
  		whld_bal_feed_id_list (feed_cnt) := ln_id;
  		feed_cnt := feed_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.init_whld_bal_feed_id',2);
  --
  END init_whld_bal_feed_id;
--
-- ===================== init_arr_bal_feed_rule  =====================
--
  PROCEDURE init_arr_bal_feed_rule
  IS
  BEGIN
  arr_bal_feed_rule_list (1) := '+1';
  arr_bal_feed_rule_list (2) := '-1';
  arr_bal_feed_rule_list (3) := '-1';
  END init_arr_bal_feed_rule;
--
-- ===================== init_all_tables =============================
--
  PROCEDURE init_all_tables
  IS
  BEGIN
  --
    hr_utility.set_location('pynegnet01.init_all_tables',1);
  --
  init_jd_list;
  init_arrear_bal_name;
  init_proto_bal_name;
  init_element_name;
  init_arr_assign_list;
  init_post_inp_value;
  init_post_res1_out;
  init_post_res1_inp;
  init_post_res1_unit;
  init_post_res4_out;
  init_arr_inp_value;
  init_arr_unit;
  init_arr_bal_feed_name;
  init_arr_bal_feed_id;
  init_arr_bal_feed_rule;
  init_whld_bal_feed_name;
  init_whld_bal_feed_id;

  init_other_variables;
  init_vertex_results;
  --
    hr_utility.set_location('pynegnet01.init_all_tables',2);
  --
  END init_all_tables;
-- ====================== check_run_results =======================
FUNCTION check_run_results return varchar2
IS
--
l_results_exist	varchar2(1)	:= 'N';
total_el	BINARY_INTEGER	:= v_total_elements;
el_cnt		BINARY_INTEGER  := 1;
--
cursor csr_chk_run_results (p_element_string varchar2)is
 select	'Y' 	results_exist
 from 	dual
 where
	exists ( select 'x'
	from 	pay_run_results 	rr,
		pay_element_types_f	ele
	where
		ele.element_type_id	= rr.element_type_id
	and	ele.element_name in ( p_element_string||'POST_VERTEX', p_element_string||'ARR')
		) ;
BEGIN

	total_el := v_total_elements;
	WHILE	( el_cnt <= total_el and l_results_exist = 'N') LOOP

        if el_cnt in (3,9,10) then

		open csr_chk_run_results ( element_name_list(el_cnt));
		fetch csr_chk_run_results into l_results_exist;
		close csr_chk_run_results;
		--
        end if;
		el_cnt	:= el_cnt + 1;
		--
	END LOOP;

return l_results_exist;
END check_run_results;
-- ====================== delete_bal_dim ===========================
--
  PROCEDURE delete_bal_dim
  IS
    CURSOR bal_dim (p_bal_name VARCHAR2)
    IS
      SELECT db.defined_balance_id
         FROM pay_balance_types bt,
           pay_defined_balances db
         WHERE bt.balance_name = p_bal_name AND
           bt.balance_type_id = db.balance_type_id;
    /* balances counter */
    total_bal BINARY_INTEGER := v_total_balances;
    bal_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
    ln_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_bal_dim',1);
  --
  	total_bal := v_total_balances;

  	WHILE bal_cnt <= total_bal
  	LOOP
               if bal_cnt in (3,9,10) then
  		lc_name := arrear_bal_name_list (bal_cnt);
  		FOR dim_rec IN bal_dim(lc_name)
  		LOOP
  		  ln_id :=dim_rec.defined_balance_id;
		  --
                  begin
  		  DELETE FROM pay_defined_balances
  		    WHERE defined_balance_id = ln_id;
                  EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                  end;
  		END LOOP;
            end if;
  		bal_cnt := bal_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_bal_dim',2);
  --
  END delete_bal_dim;
--
-- ====================== delete_bal_feed ===========================
--
  PROCEDURE delete_bal_feed
  IS
    CURSOR bal_dim (p_bal_name VARCHAR2)
    IS
      SELECT 	bf.balance_feed_id
      FROM 	pay_balance_types 	bt,
           	pay_balance_feeds_f 	bf
      WHERE
		bt.balance_name 	= p_bal_name 		AND
           	bt.balance_type_id 	= bf.balance_type_id;
    /* balances counter */

    total_bal 	BINARY_INTEGER 	:= v_total_balances;
    bal_cnt 	BINARY_INTEGER 	:= 1;
    lc_name 	VARCHAR2(80);
    ln_id 	NUMBER 		:= 0;

  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_bal_feed',1);
  --
  	total_bal := v_total_balances;
  	WHILE bal_cnt <= total_bal
  	LOOP
              if bal_cnt in (3,9,10) then
  		lc_name := arrear_bal_name_list (bal_cnt);
  		FOR dim_rec IN bal_dim(lc_name)
  		LOOP
  		  ln_id :=dim_rec.balance_feed_id;
                  begin
  		  DELETE FROM pay_balance_feeds_f
  		    WHERE balance_feed_id = ln_id;
                  EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                  end;
  		END LOOP;
               end if;
  		bal_cnt := bal_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_bal_feed',2);
  --
  END delete_bal_feed;
--
-- ====================== delete_bal ===========================
--
  PROCEDURE delete_bal
  IS
    /* balances counter */
    total_bal BINARY_INTEGER := v_total_balances;
    bal_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
    ln_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_bal',1);
  --
  	total_bal := v_total_balances;
  	WHILE bal_cnt <= total_bal
  	LOOP
              if  bal_cnt in (3,9,10) then
  		lc_name := arrear_bal_name_list (bal_cnt);
                begin
  		DELETE FROM pay_balance_types
  		  WHERE balance_name = lc_name;
                EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                end;
           end if;
  		bal_cnt := bal_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_bal',2);
  --
  END delete_bal;
--
-- ====================== create_balances ===========================
--
  PROCEDURE create_balances
  IS
    CURSOR bal_dim (p_proto_bal_name VARCHAR2)
    IS
      SELECT bd.dimension_name
         FROM pay_balance_types bt,
           pay_balance_dimensions bd,
           pay_defined_balances db
         WHERE bt.balance_name = p_proto_bal_name AND
           bt.balance_type_id = db.balance_type_id AND
           db.balance_dimension_id = bd.balance_dimension_id;
    /* balances counter */
    total_bal BINARY_INTEGER := v_total_balances;
    bal_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
    lc_proto VARCHAR2(80);
    ln_id NUMBER := 0;
    lc_cur_dim VARCHAR2(80);
  BEGIN
  --
    hr_utility.set_location('pynegnet01.create_balances',1);
  --
  	total_bal := v_total_balances;
  	WHILE bal_cnt <= total_bal
  	LOOP
              if  bal_cnt in (3,9,10) then
  		lc_name := arrear_bal_name_list (bal_cnt);

  		-- call function pay_db_pay_setup.create_balance_type
  		-- to build new arrear balance
  --
  		ln_id := pay_db_pay_setup.create_balance_type(
  			p_balance_name 		=> lc_name,
  			p_uom 			=> v_uom,
  			p_currency_code 	=> v_currency_code,
  			p_reporting_name 	=> lc_name,
  			p_legislation_code 	=> v_legislation_code);
		--
  		arrear_bal_id_list (bal_cnt) 	:= ln_id;
		--
		--
		-- Use the prototype balance to determine the dimensions
		-- and jurisdiction level.
		--
  		lc_proto := proto_bal_name_list (bal_cnt);
		--
		-- update jurisdiction level for the arrears balance.
		--
		--
		   update pay_balance_types
		   set    jurisdiction_level =
				( select jurisdiction_level
				  from	 pay_balance_types
				  where  balance_name 		= lc_proto
				  and	 business_group_id is null
				  and	 legislation_code 	= 'US')
		  where	  balance_type_id = ln_id;
		--
		--
		    hr_utility.set_location('pynegnet01.create_balances',2);
		--
		--
  		-- build all dimensions from prototype
		--
  		FOR dim_rec IN bal_dim(lc_proto)
  		LOOP
  		  lc_cur_dim :=dim_rec.dimension_name;
		  --
  		  --call procedure pay_db_pay_setup.create_defined_balance
  		  pay_db_pay_setup.create_defined_balance(
  		  	p_balance_name 		=> lc_name,
  		  	p_balance_dimension 	=> lc_cur_dim,
  		  	p_legislation_code 	=> v_legislation_code);
  		END LOOP;
		  --
		    hr_utility.set_location('pynegnet01.create_balances',3);
		  --
              end if;
           bal_cnt := bal_cnt + 1;

  	END LOOP;
  END create_balances;
--
-- ====================== delete_ff_el ===========================
--
  PROCEDURE delete_ff_el
  IS
    -- elements counter
    total_el 		BINARY_INTEGER 	:= v_total_elements;
    el_cnt 		BINARY_INTEGER 	:= 1;
    ln_id 		NUMBER 		:= 0;
    lc_ff_name 		VARCHAR2(80);
    ln_formula_id 	NUMBER 		:=1;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_ff_el',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
              if el_cnt in (3,9,10) then
  		lc_ff_name := element_name_list (el_cnt) || 'POST_VERTEX';
                begin
		DELETE FROM ff_formulas_f
		WHERE formula_name = lc_ff_name;
                EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                end;
              end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_ff_el',2);
  --
  END delete_ff_el;
--
-- ====================== create_ff_el ===========================
--
  PROCEDURE create_ff_el
  IS
    -- elements counter
    total_el 		BINARY_INTEGER 	:= v_total_elements;
    el_cnt 		BINARY_INTEGER 	:= 1;
    ln_id 		NUMBER 		:= 0;
    lc_text 		VARCHAR2(2000);
    lc_repl1 		VARCHAR2(50);
    lc_repl2 		VARCHAR2(50);
    lc_repl3 		VARCHAR2(50);
    lc_ff_name 		VARCHAR2(80);
    lc_ff_desc 		VARCHAR2(80);
    lc_sticky_flag 	VARCHAR2(1) 	:= ' ';
    ln_formula_id 	NUMBER 		:=1;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.create_ff_el',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
             if  el_cnt in (3,9,10) then
  		lc_repl1 := ff_repl1 (el_cnt);
  		lc_repl2 := ff_repl2 (el_cnt);
  		lc_repl3 := ff_repl3 (el_cnt);
  		lc_text := v_ff_post_text;
  		lc_text := REPLACE(lc_text,'{REPL1}',lc_repl1);
  		lc_text := REPLACE(lc_text,'{REPL2}',lc_repl2);
  		lc_text := REPLACE(lc_text,'{REPL3}',lc_repl3);
  		lc_ff_name := element_name_list (el_cnt) || 'POST_VERTEX';
  		lc_ff_desc := lc_ff_name || ' arrear calculation';
		--
		--
  		SELECT ff_formulas_s.NEXTVAL
  		INTO ln_formula_id
  		FROM sys.dual;
		--
  		INSERT INTO ff_formulas_f
  		(FORMULA_ID,
  		EFFECTIVE_START_DATE,
  		EFFECTIVE_END_DATE,
  		BUSINESS_GROUP_ID,
  		LEGISLATION_CODE,
  		FORMULA_TYPE_ID,
  		FORMULA_NAME,
  		DESCRIPTION,
  		FORMULA_TEXT,
  		STICKY_FLAG,
  		LAST_UPDATE_DATE,
  		LAST_UPDATED_BY,
  		LAST_UPDATE_LOGIN,
  		CREATED_BY,
  		CREATION_DATE)
  		VALUES
  		(ln_formula_id,
  		v_effective_start_date,
  		v_effective_end_date,
  		v_business_group_id,
  		v_legislation_code,
  		v_formula_type_id,
  		lc_ff_name,
  		lc_ff_desc,
  		lc_text,
  		lc_sticky_flag,
  		v_sysdate,
  		v_uid,
  		v_uid,
  		v_uid,
  		v_sysdate);
		--
		--
  		ff_id_list (el_cnt) := ln_formula_id;
              end if;
  		el_cnt := el_cnt + 1;
		--
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.create_ff_el',2);
  --
  END create_ff_el;
--
-- ====================== delete_arr_inp ===========================
--
  PROCEDURE delete_arr_inp
  IS
    CURSOR arr_inp (p_arr_name VARCHAR2)
    IS
      SELECT iv.input_value_id
         FROM pay_input_values_f iv,
           pay_element_types_f et
         WHERE et.element_name = p_arr_name AND
           et.element_type_id = iv.element_type_id;
    /* balances counter */
    total_el BINARY_INTEGER := v_total_elements;
    el_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
    ln_id NUMBER := 0;
    spec_cnt BINARY_INTEGER := 1;
    total_spec BINARY_INTEGER := 3;
    ln_spec_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_arr_inp',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
             if el_cnt in (3,9,10) then
  		lc_name := element_name_list (el_cnt) || 'ARR';
  		FOR arr_rec IN arr_inp(lc_name)
  		LOOP
  		  ln_id := arr_rec.input_value_id;
  		  spec_cnt := 1;
  		  total_spec := 3;
  		  WHILE spec_cnt <= total_spec
  		  LOOP
  		  	ln_spec_id := arr_bal_feed_id_list (spec_cnt);
                        begin
  		  	DELETE FROM pay_balance_feeds_f
  		  	WHERE input_value_id = ln_id AND
  		  		balance_type_id = ln_spec_id;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                        end;
  		  	spec_cnt := spec_cnt + 1;
  		  END LOOP;
                  begin
  		  DELETE FROM pay_input_values_f
  		    WHERE input_value_id = ln_id and
                          business_group_id is null;
                  EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                  end;
  	 	END LOOP;
              end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_arr_inp',2);
  --
  END delete_arr_inp;
--
-- ====================== delete_arr_el ===========================
--
  PROCEDURE delete_arr_el
  IS
    /* elements counter */
    total_el BINARY_INTEGER := 0;
    el_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_arr_el',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
             if el_cnt in (3,9,10) then
  		lc_name := element_name_list (el_cnt) || 'ARR';
                begin
  		DELETE FROM pay_element_types_f
  		  WHERE element_name = lc_name and
                        business_group_id is null;
                EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                end;
               end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  	el_cnt := 1;
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
              if el_cnt in (3,9,10) then

  		lc_name := element_name_list (el_cnt) || 'ARR_%';
                begin
  		DELETE FROM ff_user_entities
  		  WHERE user_entity_name LIKE lc_name;
                EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                end;
            end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_arr_el',2);
  --
  END delete_arr_el;
--
-- ====================== delete_arr_spec ===========================
--
  PROCEDURE delete_arr_spec
  IS
    CURSOR arr_inp (p_arr_name VARCHAR2)
    IS
      SELECT iv.input_value_id
         FROM pay_input_values_f iv,
           pay_element_types_f et
         WHERE et.element_name = p_arr_name AND
           et.element_type_id = iv.element_type_id;
    /* balances counter */
    total_el BINARY_INTEGER := v_total_elements;
    el_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
    ln_id NUMBER := 0;
    spec_cnt BINARY_INTEGER := 1;
    total_spec BINARY_INTEGER := 3;
    ln_spec_id NUMBER := 0;
    ln_whld_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_arr_spec',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
              if el_cnt in (3,9,10) then

  		lc_name := element_name_list (el_cnt) || 'ARR';
  		ln_whld_id := whld_bal_feed_id_list (el_cnt);
  		FOR arr_rec IN arr_inp(lc_name)
  		LOOP
  		  ln_id := arr_rec.input_value_id;
  		  spec_cnt := 1;
  		  total_spec := 3;
  		  WHILE spec_cnt <= total_spec
  		  LOOP
  		  	ln_spec_id := arr_bal_feed_id_list (spec_cnt);
                        begin
  		  	DELETE FROM pay_balance_feeds_f
  		  	WHERE input_value_id = ln_id AND
  		  		( balance_type_id = ln_spec_id
  		  		  OR balance_type_id = ln_whld_id);
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                        end;
  		  	spec_cnt := spec_cnt + 1;
  		  END LOOP;
  		END LOOP;
               end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_arr_spec',2);
  --
  END delete_arr_spec;
--
-- ====================== create_arr_el ===========================
--
  PROCEDURE create_arr_el
  IS
    /* elements counter */
    total_el 		BINARY_INTEGER 		:= 0;
    el_cnt 		BINARY_INTEGER 		:= 1;
    lc_name 		VARCHAR2(80);
    lc_class 		VARCHAR2(20) 		:= 'Information';
    ln_priority 	NUMBER ; --			:= 4250;
    lc_rule 		VARCHAR2(20) 		:= 'Final Close';
    lc_type 		VARCHAR2(1) 		:= 'N';
    ln_id 		NUMBER 			:= 0;
    ln_inp_id 		NUMBER 			:= 0;
    lc_inp_name 	VARCHAR2(20);
    lc_uom 		VARCHAR2(20);
    lc_ind_flag 	VARCHAR2(1) 		:= 'Y';
    lc_mult_entries_allowed 	VARCHAR2(1) 	:= 'Y';
    inp_cnt 		BINARY_INTEGER 		:= 1;
    total_inp 		BINARY_INTEGER 		:= 2;
    --
    /* balance feed variables */
    lc_option		VARCHAR2(80);
    ln_input_value_id	NUMBER;
    ln_element_type_id 	NUMBER;
    ln_prim_class_id 	NUMBER;
    ln_sub_class_id 	NUMBER;
    ln_sub_class_rule_id NUMBER;
    ln_balance_type_id 	NUMBER;
    lc_scale 		VARCHAR2(80);
    ld_session_date 	DATE;
    lc_business_group 	VARCHAR2(80);
    lc_legislation_code VARCHAR2(80);
    lc_mode 		VARCHAR2(80);
    ln_find 		BINARY_INTEGER 		:= 0;
    spec_cnt 		BINARY_INTEGER 		:= 1;
    total_spec 		BINARY_INTEGER 		:= 3;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.create_arr_el',1);
  --
  	SELECT classification_id
  	INTO ln_prim_class_id
  	FROM pay_element_classifications
  	WHERE classification_name = 'Information'
	AND   legislation_code	  = 'US'
	AND   business_group_id is null
	;
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
              if el_cnt in (3,9,10) then

  		lc_name 	:= element_name_list (el_cnt) || 'ARR';
		ln_priority 	:= element_priority_list (el_cnt);
  		/* call function pay_db_pay_setup.create_element
  		to build new arr element */
  		ln_id :=
		   pay_db_pay_setup.create_element(
  			p_element_name 		=> lc_name,
  			p_description 		=> lc_name,
  			p_reporting_name 	=> lc_name,
  			p_classification_name 	=> lc_class,
  			p_input_currency_code 	=> v_currency_code,
  			p_output_currency_code 	=> v_currency_code,
  			p_processing_type 	=> lc_type,
  			p_mult_entries_allowed 	=> lc_mult_entries_allowed,
  			p_processing_priority 	=> ln_priority,
  			p_post_termination_rule => lc_rule,
  			p_indirect_only_flag 	=> lc_ind_flag,
  			p_effective_start_date 	=> v_effective_start_date,
  			p_effective_end_date 	=> v_effective_end_date,
  			p_legislation_code 	=> v_legislation_code);
		  --
		    hr_utility.set_location('pynegnet01.create_arr_el',2);
		  --
  		inp_cnt := 1;

  		/* input values loop */
  		WHILE inp_cnt <= total_inp
  		LOOP
  			lc_inp_name := arr_inp_value_list (inp_cnt);
  			lc_uom := arr_unit_list (inp_cnt);
  			ln_inp_id :=
			pay_db_pay_setup.create_input_value(
  				p_element_name => lc_name,
  				p_name => lc_inp_name,
  				p_uom => lc_uom,
  				p_display_sequence 	=> inp_cnt,
  				p_business_group_name 	=> v_business_group_name,
  				p_effective_start_date 	=> v_effective_start_date,
  				p_effective_end_date 	=> v_effective_end_date,
                                -- Bug 563295. mlisieck, added p_legislation_code.
                                p_legislation_code      => v_legislation_code);
  			arr_inp_id_list ((el_cnt-1)*2+inp_cnt) := ln_inp_id; -- v_arr_inp_cnt)
  --			v_arr_inp_cnt := v_arr_inp_cnt + 1;
  			inp_cnt := inp_cnt + 1;
  		END LOOP;
  		arr_element_id_list (el_cnt) := ln_id;
               end if;
  		el_cnt := el_cnt + 1;
  --
    hr_utility.set_location('pynegnet01.create_arr_el',3);
  --
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.create_arr_el',4);
  --
  END create_arr_el;
--
-- ====================== create_arr_feed ===========================
--
  PROCEDURE create_arr_feed
  IS
    /* elements counter */
    total_el 		BINARY_INTEGER := 0;
    el_cnt 		BINARY_INTEGER := 1;
    lc_name 		VARCHAR2(80);
    lc_class 		VARCHAR2(20) 	:= 'Information';
    ln_priority 	NUMBER 		:= 4250;
    lc_rule 		VARCHAR2(20) 	:= 'Final Close';
    lc_type 		VARCHAR2(1) 	:= 'N';
    ln_id 		NUMBER 		:= 0;
    ln_inp_id 		NUMBER 		:= 0;
    lc_inp_name 	VARCHAR2(20);
    lc_uom 		VARCHAR2(20);
    lc_ind_flag 	VARCHAR2(1) 	:= 'Y';
    lc_mult_entries_allowed VARCHAR2(1) := 'Y';
    inp_cnt 		BINARY_INTEGER := 1;
    total_inp 		BINARY_INTEGER := 2;
    --
    /* balance feed variables */
    lc_option 		VARCHAR2(80);
    ln_input_value_id 	NUMBER;
    ln_element_type_id 	NUMBER;
    ln_prim_class_id 	NUMBER;
    ln_sub_class_id 	NUMBER;
    ln_sub_class_rule_id NUMBER;
    ln_balance_type_id 	NUMBER;
    lc_scale 		VARCHAR2(80);
    ld_session_date 	DATE;
    lc_business_group 	VARCHAR2(80);
    lc_legislation_code VARCHAR2(80);
    lc_mode 		VARCHAR2(80);
    ln_find 		BINARY_INTEGER := 0;
    spec_cnt 		BINARY_INTEGER :=1;
    total_spec 		BINARY_INTEGER :=3;
    ln_inp 		NUMBER :=0;
    --
    --
  BEGIN
  --
    hr_utility.set_location('pynegnet01.create_arr_feed',1);
  --
  	SELECT classification_id
  	INTO ln_prim_class_id
  	FROM pay_element_classifications
  	WHERE classification_name = 'Information'
	and   legislation_code	  = 'US'
	and   business_group_id is null ;

  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
               if el_cnt in (3,9,10) then

  		/* balance feeds loop */
  		/* arrear balance feed */
		    ln_find 		:= arr_assign_list (el_cnt);
		    ln_inp 		:= (el_cnt-1)*2+1;
		    lc_option 		:= 'INS_MANUAL_FEED';
		    ln_input_value_id 	:= arr_inp_id_list (ln_inp);
		    ln_element_type_id 	:= arr_element_id_list (el_cnt);
		    ln_sub_class_id 	:= NULL;
		    ln_sub_class_rule_id := NULL;
		    ln_balance_type_id 	:= arrear_bal_id_list (ln_find);
		    lc_scale 		:= '-1';
		    ld_session_date 	:= TRUNC(SYSDATE);
		    lc_business_group 	:= v_business_group_name;
		    lc_legislation_code := v_legislation_code;
		    lc_mode 		:= 'USER';

		    hr_balances.ins_balance_feed(
		    	p_option 		=> lc_option,
		    	p_input_value_id 	=> ln_input_value_id,
		    	p_element_type_id 	=> ln_element_type_id,
		    	p_primary_classification_id => ln_prim_class_id,
		    	p_sub_classification_id => ln_sub_class_id,
		    	p_sub_classification_rule_id => ln_sub_class_rule_id,
		    	p_balance_type_id 	=> ln_balance_type_id,
		    	p_scale 		=> lc_scale,
		    	p_session_date 		=> ld_session_date,
		    	p_business_group 	=> lc_business_group,
		    	p_legislation_code 	=> lc_legislation_code,
		    	p_mode 			=> lc_mode);
		  --
		    hr_utility.set_location('pynegnet01.create_arr_feed',2);
		  --
  		/* withheld balance feed */
		    ln_inp 		:= (el_cnt-1)*2+1;
		    lc_option 		:= 'INS_MANUAL_FEED';
		    ln_input_value_id 	:= arr_inp_id_list (ln_inp);
		    ln_element_type_id 	:= arr_element_id_list (el_cnt);
		    ln_sub_class_id 	:= NULL;
		    ln_sub_class_rule_id := NULL;
		    ln_balance_type_id 	:= whld_bal_feed_id_list (el_cnt);
		    lc_scale 		:= '+1';
		    ld_session_date 	:= TRUNC(SYSDATE);
		    lc_business_group 	:= v_business_group_name;
		    lc_legislation_code := v_legislation_code;
		    lc_mode 		:= 'USER';

		    hr_balances.ins_balance_feed(
		    	p_option 		=> lc_option,
		    	p_input_value_id 	=> ln_input_value_id,
		    	p_element_type_id 	=> ln_element_type_id,
		    	p_primary_classification_id => ln_prim_class_id,
		    	p_sub_classification_id => ln_sub_class_id,
		    	p_sub_classification_rule_id => ln_sub_class_rule_id,
		    	p_balance_type_id 	=> ln_balance_type_id,
		    	p_scale 		=> lc_scale,
		    	p_session_date 		=> ld_session_date,
		    	p_business_group 	=> lc_business_group,
		    	p_legislation_code 	=> lc_legislation_code,
		    	p_mode 			=> lc_mode);
		  --
		    hr_utility.set_location('pynegnet01.create_arr_feed',3);
		  --
		 /* special balances feed Tax Deductions, Net, Payments */
		 spec_cnt 	:= 1;
		 total_spec 	:= 3;
		 WHILE spec_cnt <= total_spec
		 LOOP
		    ln_inp 		:= (el_cnt-1)*2+1;
		    lc_option 		:= 'INS_MANUAL_FEED';
		    ln_input_value_id 	:= arr_inp_id_list (ln_inp);
		    ln_element_type_id 	:= arr_element_id_list (el_cnt);
		    ln_sub_class_id 	:= NULL;
		    ln_sub_class_rule_id := NULL;
		    ln_balance_type_id 	:= arr_bal_feed_id_list (spec_cnt);
		    lc_scale 		:= arr_bal_feed_rule_list (spec_cnt);
		    ld_session_date 	:= TRUNC(SYSDATE);
		    lc_business_group 	:= v_business_group_name;
		    lc_legislation_code := v_legislation_code;
		    lc_mode 		:= 'USER';
		    --


		    hr_balances.ins_balance_feed(
		    	p_option 		=> lc_option,
		    	p_input_value_id 	=> ln_input_value_id,
		    	p_element_type_id 	=> ln_element_type_id,
		    	p_primary_classification_id => ln_prim_class_id,
		    	p_sub_classification_id => ln_sub_class_id,
		    	p_sub_classification_rule_id => ln_sub_class_rule_id,
		    	p_balance_type_id 	=> ln_balance_type_id,
		    	p_scale 		=> lc_scale,
		    	p_session_date 		=> ld_session_date,
		    	p_business_group 	=> lc_business_group,
		    	p_legislation_code 	=> lc_legislation_code,
		    	p_mode 			=> lc_mode)
			;
		    spec_cnt := spec_cnt + 1;
		 END LOOP;

		    /* Total Tax Arrears balance feed */

		    ln_inp 		:= (el_cnt-1)*2+1;
		    lc_option 		:= 'INS_MANUAL_FEED';
		    ln_input_value_id 	:= arr_inp_id_list (ln_inp);
		    ln_element_type_id 	:= arr_element_id_list (el_cnt);
		    ln_sub_class_id 	:= NULL;
		    ln_sub_class_rule_id := NULL;
		    ln_balance_type_id 	:= arrear_bal_id_list (13); /* arrears_bal_id_list(v_total_balances) = 'Tax Arrears' */
		    lc_scale 		:= '-1';
		    ld_session_date 	:= TRUNC(SYSDATE);
		    lc_business_group 	:= v_business_group_name;
		    lc_legislation_code := v_legislation_code;
		    lc_mode 		:= 'USER';


		    hr_balances.ins_balance_feed(
		    	p_option 		=> lc_option,
		    	p_input_value_id 	=> ln_input_value_id,
		    	p_element_type_id 	=> ln_element_type_id,
		    	p_primary_classification_id => ln_prim_class_id,
		    	p_sub_classification_id => ln_sub_class_id,
		    	p_sub_classification_rule_id => ln_sub_class_rule_id,
		    	p_balance_type_id 	=> ln_balance_type_id,
		    	p_scale 		=> lc_scale,
		    	p_session_date 		=> ld_session_date,
		    	p_business_group 	=> lc_business_group,
		    	p_legislation_code 	=> lc_legislation_code,
		    	p_mode 			=> lc_mode);

                  end if;
  		el_cnt := el_cnt + 1;
		  --
		hr_utility.set_location('pynegnet01.create_arr_feed',4);
		--
		-- package above does not support effective_start_date
		--
		update 	pay_balance_feeds_f
		set	business_group_id	= null,
			effective_start_date	= v_effective_start_date
		where	balance_type_id 	= ln_balance_type_id
		;
		--
  	END LOOP;
	--
	hr_utility.set_location('pynegnet01.create_arr_feed',5);
	--
	--


  END create_arr_feed;
--
-- ====================== delete_post_inp ===========================
--
  PROCEDURE delete_post_inp
  IS
    CURSOR post_inp (p_post_name VARCHAR2)
    IS
      SELECT iv.input_value_id
         FROM pay_input_values_f iv,
           pay_element_types_f et
         WHERE et.element_name = p_post_name AND
           et.element_type_id = iv.element_type_id;
    /* balances counter */
    total_el BINARY_INTEGER := v_total_elements;
    el_cnt BINARY_INTEGER := 1;
    lc_name VARCHAR2(80);
    ln_id NUMBER := 0;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_post_input',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
           if el_cnt in (3,9,10) then

  		lc_name := element_name_list (el_cnt) || 'POST_VERTEX';
  		FOR post_rec IN post_inp(lc_name)
  		LOOP
  		  ln_id := post_rec.input_value_id;
                  begin
  		  DELETE FROM pay_input_values_f
  		    WHERE input_value_id = ln_id and
                          business_group_id is null;
                  EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                  end;
  		END LOOP;
                end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_post_input',2);
  --
  END delete_post_inp;
--
-- ====================== delete_post_el ===========================
--
  PROCEDURE delete_post_el
  IS
    /* elements counter */
    total_el 		BINARY_INTEGER 	:= 0;
    el_cnt 		BINARY_INTEGER 	:= 1;
    lc_name 		VARCHAR2(80);
    ln_id 		NUMBER 		:= 0;
    l_rule_id           NUMBER          := 0;

    cursor csr_all_processing_rules (p_lc_name varchar2) is
        SELECT psprf.status_processing_rule_id
          FROM pay_status_processing_rules_f psprf,
               pay_element_types_f petf
          WHERE petf.element_type_id = psprf.element_type_id and
                petf.element_name = p_lc_name and
                petf.business_group_id is null;
  BEGIN
  --
    hr_utility.set_location('pynegnet01.delete_post_el',1);
  --
  	total_el := v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
             if el_cnt in (3,9,10) then

  		lc_name := element_name_list (el_cnt) || 'POST_VERTEX';
                begin
  		DELETE FROM pay_element_types_f
  		  WHERE element_name = lc_name and
                        business_group_id is null;
                EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                end;
                 end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_post_el',2);
  --
  	el_cnt 		:= 1;
  	total_el 	:= v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
            if el_cnt in (3,9,10) then

  		lc_name := element_name_list (el_cnt) || 'POST_VERTEX_%';
  		DELETE FROM ff_user_entities
  		  WHERE user_entity_name LIKE lc_name and
                        business_group_id is null;
                end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_post_el',3);
  --
  	el_cnt 		:= 1;
  	total_el	:= v_total_elements;
  	WHILE el_cnt <= total_el
  	LOOP
              ln_id := 0;

  		lc_name := element_name_list (el_cnt) || 'POST_VERTEX';

              open csr_all_processing_rules (lc_name);
              fetch csr_all_processing_rules into l_rule_id;
              close csr_all_processing_rules;

                BEGIN
                        SELECT element_type_id
                        INTO ln_id
                        FROM pay_element_types_f
                        WHERE element_name = lc_name;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN NULL;
                END;

            if el_cnt in (3,9,10) then

  		IF ln_id > 0 THEN

  			DELETE FROM pay_status_processing_rules_f
  		  	WHERE element_type_id = ln_id;
                        DELETE FROM pay_formula_result_rules_f
                        WHERE status_processing_rule_id = l_rule_id;
  		END IF;
          else
               if ln_id > 0 THEN
               DELETE FROM pay_formula_result_rules_f
               WHERE status_processing_rule_id = l_rule_id;
               end if;
          end if;
  		el_cnt := el_cnt + 1;
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.delete_post_el',4);
  --
  END delete_post_el;
--
-- ====================== create_post_el ===========================
--
  PROCEDURE create_post_el
  IS
    /* elements counter */
    total_el 		BINARY_INTEGER := 0;
    el_cnt 		BINARY_INTEGER := 1;
    lc_name 		VARCHAR2(80);
    lc_class 		VARCHAR2(20) 	:= 'Information';
    ln_priority 	NUMBER; 	-- 			:= 4250;
    lc_rule 		VARCHAR2(20) 	:= 'Final Close';
    lc_type 		VARCHAR2(1) 	:= 'N';
    ln_id 		NUMBER 		:= 0;
    ln_inp_id 		NUMBER 		:= 0;
    lc_inp_name 	VARCHAR2(20);
    lc_uom 		VARCHAR2(20);
    lc_ind_flag 	VARCHAR2(1) 	:= 'Y';
    lc_mult_entries_allowed VARCHAR2(1) := 'Y';
    inp_cnt 		BINARY_INTEGER 	:= 1;
    total_inp 		BINARY_INTEGER 	:= 5;
    /* status variables */
    ln_stat_id 		NUMBER 		:= 0;
    lc_processing_rule 	VARCHAR2(1) 	:= 'P';
    ln_formula_id 	NUMBER 		:=0;
    /* rules variables */
    ln_rule_id 		NUMBER 		:= 0;
    ln_input_value_id 	NUMBER 		:= 0;
    ln_element_type_id 	NUMBER 		:= 0;
    lc_result_name 	VARCHAR2(30);
    lc_result_rule_type VARCHAR2(20);
    ln_find 		BINARY_INTEGER 	:= 0;
    rule_cnt 		BINARY_INTEGER 	:=0;
    total_rule 		BINARY_INTEGER 	:=2;
    lc_severity_level 	VARCHAR2(1) 	:= 'W';
  BEGIN
  --
    hr_utility.set_location('pynegnet01.create_post_el',1);
  --
  	total_el := v_total_elements;  /* element_name_list.COUNT; */
  	el_cnt := v_total_elements;
  	WHILE el_cnt > 0 LOOP

             if el_cnt in (3,9,10) then

  		lc_name 	:= element_name_list (el_cnt) || 'POST_VERTEX';
		ln_priority 	:= element_priority_list (el_cnt);
  		/* call function pay_db_pay_setup.create_element
  		to build new post element */

  		ln_id := pay_db_pay_setup.create_element(
  			p_element_name 		=> lc_name,
  			p_description 		=> lc_name,
  			p_reporting_name 	=> lc_name,
  			p_classification_name 	=> lc_class,
  			p_input_currency_code 	=> v_currency_code,
  			p_output_currency_code 	=> v_currency_code,
  			p_processing_type 	=> lc_type,
  			p_mult_entries_allowed 	=> lc_mult_entries_allowed,
  			p_processing_priority 	=> ln_priority,
  			p_post_termination_rule => lc_rule,
  			p_indirect_only_flag 	=> lc_ind_flag,
  			p_effective_start_date 	=> v_effective_start_date,
  			p_effective_end_date 	=> v_effective_end_date,
  			p_legislation_code 	=> v_legislation_code);
  		inp_cnt := 1;
		  --
		    hr_utility.set_location('pynegnet01.create_post_el',2);
		  --
  		WHILE inp_cnt <= total_inp
  		LOOP
  			lc_inp_name := post_inp_value_list (inp_cnt);
  			lc_uom := 'Character';
  			ln_inp_id :=
				pay_db_pay_setup.create_input_value(
  				p_element_name 		=> lc_name,
  				p_name 			=> lc_inp_name,
  				p_uom 			=> lc_uom,
  				p_display_sequence 	=> inp_cnt,
				p_business_group_name 	=> v_business_group_name,
  				p_effective_start_date 	=> v_effective_start_date,
  				p_effective_end_date 	=> v_effective_end_date,
                                -- Bug 563295. mlisieck, added p_legislation_code.
                                p_legislation_code      => v_legislation_code);
  			v_post_inp_cnt 		:= (el_cnt-1)*5+inp_cnt;
  			post_inp_id_list (v_post_inp_cnt) := ln_inp_id;
  			inp_cnt 		:= inp_cnt + 1;
  		END LOOP;
		  --
		    hr_utility.set_location('pynegnet01.create_post_el',3);
		  --
  		/* insert status processing rule */
  		ln_formula_id := ff_id_list (el_cnt);
  		ln_stat_id := pay_formula_results.ins_stat_proc_rule(
  			p_business_group_id 	=> v_business_group_id,
  			p_legislation_code 	=> v_legislation_code,
  			p_effective_start_date 	=> v_effective_start_date,
  			p_effective_end_date 	=> v_effective_end_date,
  			p_element_type_id 	=> ln_id,
  			p_formula_id 		=> ln_formula_id,
  			p_processing_rule 	=> lc_processing_rule);
		  --
		    hr_utility.set_location('pynegnet01.create_post_el',4);
		  --
                 post_element_id_list (el_cnt) := ln_id;
                 --
           else
               select status_processing_rule_id into ln_stat_id
                  from pay_status_processing_rules_f
                  where element_type_id = post_element_id_list (el_cnt);
           end if;

  		/* insert_formula result rules */
  		/* part 1 */
  		rule_cnt 	:= 1;
  		total_rule 	:= 2;
  		WHILE rule_cnt <= total_rule
  		LOOP
  		lc_result_name 		:= post_res1_out_name_list (rule_cnt);
  		lc_result_rule_type 	:= 'I';
  		ln_element_type_id 	:= arr_element_id_list (el_cnt);
  		ln_find 		:= (el_cnt-1)*2+rule_cnt;
  		ln_input_value_id 	:= arr_inp_id_list (ln_find);
  		ln_rule_id 		:= pay_formula_results.ins_form_res_rule(
  			p_business_group_id 	=> v_business_group_id,
  			p_legislation_code 	=> v_legislation_code,
  			p_effective_start_date 	=> v_effective_start_date,
  			p_effective_end_date 	=> v_effective_end_date,
  			p_status_processing_rule_id => ln_stat_id,
  			p_input_value_id 	=> ln_input_value_id,
  			p_result_name 		=> lc_result_name,
  			p_result_rule_type 	=> lc_result_rule_type,
  			p_element_type_id 	=> ln_element_type_id);
  		rule_cnt := rule_cnt + 1;
		  --
		    hr_utility.set_location('pynegnet01.create_post_el',5);
		  --
  		END LOOP;
  		/* part 2 */
  		lc_result_name 		:= 'ARR_RET_MSG';
  		lc_result_rule_type 	:= 'M';
  		-- ln_element_type_id 	:= arr_element_id_list (el_cnt);
  		ln_rule_id 		:= pay_formula_results.ins_form_res_rule(
  			p_business_group_id 	=> v_business_group_id,
  			p_legislation_code 	=> v_legislation_code,
  			p_effective_start_date 	=> v_effective_start_date,
  			p_effective_end_date 	=> v_effective_end_date,
  			p_status_processing_rule_id => ln_stat_id,
  			p_result_name 		=> lc_result_name,
  			p_result_rule_type 	=> lc_result_rule_type,
  			p_severity_level 	=> lc_severity_level);
			  --
			    hr_utility.set_location('pynegnet01.create_post_el',6);
			  --
  		/* part 3 */
  		IF el_cnt < v_total_elements THEN
  		rule_cnt 	:= 1;
  		total_rule 	:= 5;
  		post_res4_out_name_list (1) := jd_list (el_cnt);
  		WHILE rule_cnt <= total_rule
  		LOOP
  		lc_result_name := post_res4_out_name_list (rule_cnt);
  		lc_result_rule_type 	:= 'I';
  		ln_element_type_id 	:= post_element_id_list (el_cnt+1);
  		ln_find 		:= (el_cnt*5)+rule_cnt;
  		ln_input_value_id 	:= post_inp_id_list (ln_find);
  		ln_rule_id 	:= pay_formula_results.ins_form_res_rule(
  			p_business_group_id 	=> v_business_group_id,
  			p_legislation_code 	=> v_legislation_code,
  			p_effective_start_date 	=> v_effective_start_date,
  			p_effective_end_date 	=> v_effective_end_date,
  			p_status_processing_rule_id => ln_stat_id,
  			p_input_value_id 	=> ln_input_value_id,
  			p_result_name 		=> lc_result_name,
  			p_result_rule_type 	=> lc_result_rule_type,
  			p_element_type_id 	=> ln_element_type_id);
  		rule_cnt := rule_cnt + 1;
		  --
		    hr_utility.set_location('pynegnet01.create_post_el',7);
		  --
  		END LOOP;
  		END IF;
                --
  		el_cnt := el_cnt - 1;
                --
  	END LOOP;
  --
    hr_utility.set_location('pynegnet01.create_post_el',8);
  --
  END create_post_el;
--
-- ====================== delete_vertex_results ===========================
--
  PROCEDURE delete_vertex_results
  IS
    CURSOR first_inp (p_post_name VARCHAR2)
    IS
      SELECT 	iv.input_value_id
        FROM 	pay_input_values_f 	iv,
          	pay_element_types_f 	et
       WHERE 	et.element_name 	= p_post_name AND
           	et.element_type_id 	= iv.element_type_id
	;

    lc_name VARCHAR2(80) := 'VERTEX_RESULTS';
    ln_vertex_id NUMBER := 0;
    ln_id NUMBER := 0;


    BEGIN
  --
    hr_utility.set_location('pynegnet.delete_vertex_results',1);
  --
    	BEGIN
  		SELECT element_type_id
  		INTO ln_vertex_id
  		FROM pay_element_types_f
  		WHERE element_name = lc_name;
  		EXCEPTION
  			WHEN NO_DATA_FOUND THEN NULL;
  	END;
  	IF ln_vertex_id > 0 THEN
  		FOR first_rec IN first_inp('SUI_EE_POST_VERTEX')
  		LOOP
  		  ln_id := first_rec.input_value_id;
  		  DELETE FROM pay_formula_result_rules_f
  		    WHERE
			input_value_id  = ln_id
		    ;
-- sd1			element_type_id = ln_vertex_id
-- sd1  		      AND input_value_id = ln_id;
  		END LOOP;
  	END IF;
  --
    hr_utility.set_location('pynegnet.delete_vertex_results',2);
  --
  END delete_vertex_results;
--
-- ====================== create_vertex_results ===========================
--
  PROCEDURE create_vertex_results
  IS
  /* insert_formula result rules */
  rule_cnt BINARY_INTEGER := 1;
  total_rule BINARY_INTEGER := 5;
  ln_stat_id NUMBER := 0;
  ln_rule_id NUMBER := 0;
  ln_input_value_id NUMBER := 0;
  ln_element_type_id NUMBER := 0;
  lc_result_name VARCHAR2(30);
  lc_result_rule_type VARCHAR2(20);
  lc_severity_level VARCHAR2(1) := 'W';
  BEGIN
  --
    hr_utility.set_location('pynegnet.create_vertex_results',1);
  --
  	BEGIN
  		SELECT status_processing_rule_id
  		INTO ln_stat_id
  		FROM pay_status_processing_rules_f sp,
  		  pay_element_types_f et
  		WHERE et.element_name = 'VERTEX_RESULTS'
  		  AND et.element_type_id = sp.element_type_id;
  		EXCEPTION
  		  WHEN NO_DATA_FOUND THEN NULL;
  	END;
  	IF ln_stat_id > 0 THEN
  		WHILE rule_cnt <= total_rule
  			LOOP
  			lc_result_name := vertex_res_out_name_list (rule_cnt);
  			lc_result_rule_type := 'I';
  			ln_element_type_id := post_element_id_list (1);
  			ln_input_value_id := post_inp_id_list (rule_cnt);
  			ln_rule_id := pay_formula_results.ins_form_res_rule(
  				p_business_group_id => v_business_group_id,
  				p_legislation_code => v_legislation_code,
  				p_effective_start_date => v_effective_start_date,
  				p_effective_end_date => v_effective_end_date,
  				p_status_processing_rule_id => ln_stat_id,
  				p_input_value_id => ln_input_value_id,
  				p_result_name => lc_result_name,
  				p_result_rule_type => lc_result_rule_type,
  				p_element_type_id => ln_element_type_id);
  			rule_cnt := rule_cnt + 1;
			  --
			    hr_utility.set_location('pynegnet.create_vertex_results',2);
			  --
  		END LOOP;
  	END IF;
  --
    hr_utility.set_location('pynegnet.create_vertex_results',3);
  --
  END create_vertex_results;
--
-----------------------cleanup-------------------------------------------
--
procedure cleanup is
cursor sel_input (p_element varchar2) is
select
	element_type_id
from    pay_element_types_f
where
	element_name = p_element
and	legislation_code = 'US'
;

total_el 		binary_integer := v_total_elements;
el_count 		binary_integer := 1;
lc_element_type_id	number;

begin
   while (el_count <= total_el)  loop
	--
      if  el_count in (3,9,10) then
	open sel_input (element_name_list(el_count)||'ARR');
	fetch sel_input into lc_element_type_id;
	close sel_input;
	--
	update 	pay_input_values_f
	set	business_group_id = null
	where	element_type_id   = lc_element_type_id
	and	business_group_id is not null
	;
	--
	update  pay_balance_feeds_f
	set	business_group_id = null,
		effective_start_date = v_effective_start_date
	where	input_value_id in
			(select input_value_id
			 from   pay_input_values_f
			 where  element_type_id = lc_element_type_id)
	and	(business_group_id is not null
		or effective_start_date <> v_effective_start_date)
	;
	--
       end if;
        el_count := el_count + 1;
	end loop;
	--
	el_count := 1;
	--
	--
  while (el_count <= total_el) loop
	--
      if  el_count in (3,9,10) then
	open sel_input (element_name_list(el_count)||'POST_VERTEX');
	fetch sel_input into lc_element_type_id;
	close sel_input;
	--
	--
	update 	pay_input_values_f
	set	business_group_id = null
	where	element_type_id   = lc_element_type_id
	and	business_group_id is not null
	;
	--
     end if;

     el_count := el_count + 1;

  end loop;
	--
end;
--
-- ====================== change_balance_feeds =========================
--
  PROCEDURE change_balance_feeds
  IS

  el_cnt             BINARY_INTEGER  := 1;
  feed_cnt           BINARY_INTEGER  := 1;
  l_scale            BINARY_INTEGER;
  l_balance_feed_id  BINARY_INTEGER;
  l_element_type_id  BINARY_INTEGER;
  l_balance_name     varchar2(30);
  l_assign_list      BINARY_INTEGER;

  cursor crs_arr_element_type_id (el_count number) is
    select element_type_id from pay_element_types_f
      where element_name = element_name_list (el_count) || 'ARR';

  CURSOR csr_bal_feeds (p_arr_element_type_id number)
  IS
    SELECT pbf.balance_feed_id, pbt.balance_name
       FROM pay_balance_feeds_f pbf, pay_input_values_f pivf,
            pay_element_types_f petf, pay_balance_types pbt
       WHERE pbf.input_value_id = pivf.input_value_id  and
             petf.element_type_id = pivf.element_type_id and
             petf.element_type_id = p_arr_element_type_id and
             pbf.balance_type_id = pbt.balance_type_id;

BEGIN

WHILE  el_cnt <= v_total_elements loop

if el_cnt not in (3,9,10) then

open crs_arr_element_type_id (el_cnt);
fetch crs_arr_element_type_id into l_element_type_id;
                --
                feed_cnt := 1;

                open csr_bal_feeds ( l_element_type_id);
                WHILE  feed_cnt <=  6 loop
                   fetch csr_bal_feeds into l_balance_feed_id, l_balance_name;
-- csr_bal_feeds%found LOOP
                     l_assign_list := arr_assign_list(el_cnt);
                     update pay_balance_feeds_f
                       set scale = decode
       (upper(l_balance_name),
       upper(arrear_bal_name_list(l_assign_list)),-1,
       upper(arr_bal_feed_name_list (2)),-1,
       upper(arr_bal_feed_name_list (3)),-1,
       upper(arrear_bal_name_list (13)),-1, +1)
                       where balance_feed_id = l_balance_feed_id and
                             business_group_id is null;
                     --
                  feed_cnt := feed_cnt + 1;
                END LOOP;
                close csr_bal_feeds;
                --
       close  crs_arr_element_type_id;

 end if;
                el_cnt := el_cnt + 1;
                --

END LOOP;

END change_balance_feeds;

--
-- ====================== change_post_formulas =========================
--
  PROCEDURE change_post_formulas
  IS

    total_el            BINARY_INTEGER  := v_total_elements;
    el_cnt              BINARY_INTEGER  := 1;
    lc_text             VARCHAR2(2000);
    lc_repl1            VARCHAR2(50);
    lc_repl2            VARCHAR2(50);
    lc_repl3            VARCHAR2(50);
    lc_ff_name          VARCHAR2(80);

  BEGIN
  --
    WHILE el_cnt <= total_el LOOP
         if  el_cnt not in (3,9,10) then
             lc_repl1 := ff_repl1 (el_cnt);
             lc_repl2 := ff_repl2 (el_cnt);
             lc_repl3 := ff_repl3 (el_cnt);
             lc_text := v_ff_post_text;
             lc_text := REPLACE(lc_text,'{REPL1}',lc_repl1);
             lc_text := REPLACE(lc_text,'{REPL2}',lc_repl2);
             lc_text := REPLACE(lc_text,'{REPL3}',lc_repl3);
             lc_ff_name := element_name_list (el_cnt) || 'POST_VERTEX';
                --
             update ff_formulas_f
             set formula_text = lc_text
             where formula_name = lc_ff_name and business_group_id is null;
          end if;

         el_cnt := el_cnt + 1;

     end loop;

end change_post_formulas;
--
-- ====================== change_run_results  =========================
--
--
  PROCEDURE change_run_results
  IS

  l_run_result_id       BINARY_INTEGER;
  l_input_value_id      BINARY_INTEGER;
  l_result_value        varchar2(60);

  cursor csr_run_results is
    select prrv.run_result_id, prrv.input_value_id, prrv.result_value
      from pay_run_result_values prrv,
           pay_input_values_f pivf,
           pay_element_types_f petf
           where prrv.input_value_id = pivf.input_value_id and
             upper(pivf.name) = 'PAY VALUE' and
             pivf.element_type_id = petf.element_type_id and
             petf.element_name like '%_ARR' and
             petf.business_group_id is null;

begin

  open csr_run_results;
  fetch csr_run_results into l_run_result_id, l_input_value_id, l_result_value;

  WHILE csr_run_results%found LOOP

    if fnd_number.canonical_to_number(l_result_value) > 0 then
      update pay_run_result_values
        set result_value = fnd_number.number_to_canonical(fnd_number.canonical_to_number(result_value) * (-1))
        where run_result_id = l_run_result_id and
              input_value_id = l_input_value_id;
    end if;
     fetch csr_run_results into l_run_result_id, l_input_value_id, l_result_value;
  end loop;

  close csr_run_results;

end change_run_results;
--
-- ====================== build_new_objects =========================
--
  PROCEDURE build_new_objects
  IS
  BEGIN

  -- initialize

  init_ff_post_text;
  init_ff_repl;
  init_all_tables;

  v_run_results_exist := check_run_results;

  select name into v_business_group_name
  from   hr_organization_units
  where  organization_id = 0 ;

if v_run_results_exist = 'N' then

  -- delete old objects

	  delete_ff_el;
	  delete_bal_dim;
	  delete_bal_feed;
	  delete_arr_spec;
	  delete_bal;
	  delete_arr_inp;
	  delete_arr_el;

         delete_vertex_results;
	  delete_post_inp;
	  delete_post_el;

  -- create new objects

	  create_ff_el;
	  create_balances;
	  create_arr_el;
	  create_arr_feed;
	  create_post_el;
create_vertex_results;
  --
change_balance_feeds;

change_post_formulas;

--
-- this has now be removed together with changed formula result value (* -1) and balance feed sign, following
-- reversing bug 585429 changes as this bug turned not to be a bug. mlisieck 14/04/98
-- change_run_results;

	  cleanup;

else
	-- run results exist so be careful about what gets updated.

hr_utility.trace('Error. Run results exist, this script has already been applied.  Contact your Oracle representative');

	  cleanup;

end if;

  END build_new_objects;
--

END pynegnet01;

/
