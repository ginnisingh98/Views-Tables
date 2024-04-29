--------------------------------------------------------
--  DDL for Package Body PAY_CA_ISETUP_EARN_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_ISETUP_EARN_DEDN" as
/* $Header: paycaisetuped.pkb 120.0 2005/05/29 11:09 appldev noship $ */
/*
*/
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_ca_isetup_earn_dedn
    Filename	: paycaisetuped.pkb
    Change List
    -----------
    Date        Name          	Vers	Bug No  Description
    ----        ----          	----	------  -----------
    13-JUL-04   P.Ganguly  	115.0          	First Created.
*/

--
PROCEDURE compile_formula (p_element_type_id IN NUMBER) IS

   CURSOR csr_formula_name IS
   SELECT
     ff.formula_name,
     ft.formula_type_name
   FROM
     pay_status_processing_rules_f spr,
     ff_formulas_f ff,
     ff_formula_types ft
   WHERE
     spr.element_type_id = p_element_type_id AND
     spr.formula_id = ff.formula_id AND
     ff.formula_type_id = ft.formula_type_id;
--
   l_req_id NUMBER(10);

  BEGIN

  FOR csr_formula_name_rec IN csr_formula_name LOOP

    l_req_id :=
         fnd_request.submit_request(
                     application    => 'FF',
                     program        => 'SINGLECOMPILE',
                     argument1      => csr_formula_name_rec.formula_type_name,
                     argument2      => csr_formula_name_rec.formula_name);
  END LOOP;

END compile_formula;
--
FUNCTION create_isetup_earnings (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ele_category 		in varchar2	default NULL,
                p_ele_calc_method       in varchar2,
                p_ele_eoy_type          in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
		p_ele_ot_earnings	in varchar2 	default 'N',
		p_ele_ot_hours 		in varchar2 	default 'N',
		p_ele_ei_hours 		in varchar2 	default 'N',
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
		p_ele_calc_rule 	in varchar2,
		p_ele_calc_rule_code 	in varchar2	default NULL,
		p_sep_check_option	in varchar2	default 'N',
		p_reduce_regular	in varchar2	default 'N',
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date 	default NULL,
		p_bg_id			in number,
                p_termination_rule      in varchar2     default 'F')
                RETURN NUMBER IS
BEGIN

DECLARE

  l_element_type_id  pay_element_types_f.element_type_id%TYPE;

BEGIN
          l_element_type_id :=
                pay_ca_user_init_earn.create_user_init_earning(
                p_ele_name              =>  p_ele_name,
                p_ele_reporting_name    =>  p_ele_reporting_name,
                p_ele_description       =>  p_ele_description,
                p_ele_classification    =>  p_ele_classification,
                p_ele_category          =>  p_ele_category,
                p_ele_calc_method       =>  p_ele_calc_method,
                p_ele_eoy_type          =>  p_ele_eoy_type,
                p_ele_t4a_footnote      =>  p_ele_t4a_footnote,
                p_ele_rl1_footnote      =>  p_ele_rl1_footnote,
                p_ele_registration_number =>  p_ele_registration_number,
                p_ele_ot_earnings       =>  p_ele_ot_earnings,
                p_ele_ot_hours          =>  p_ele_ot_hours,
                p_ele_ei_hours          =>  p_ele_ei_hours,
                p_ele_processing_type   =>  p_ele_processing_type,
                p_ele_priority          =>  p_ele_priority,
                p_ele_standard_link     =>  p_ele_standard_link,
                p_ele_calc_rule         =>  p_ele_calc_rule,
                p_ele_calc_rule_code    =>  p_ele_calc_rule_code,
                p_sep_check_option      =>  p_sep_check_option,
                p_reduce_regular        =>  p_reduce_regular,
                p_ele_eff_start_date    =>  p_ele_eff_start_date,
                p_ele_eff_end_date      =>  p_ele_eff_end_date,
                p_bg_id                 =>  p_bg_id,
                p_termination_rule      =>  p_termination_rule) ;

  compile_formula(l_element_type_id);
  RETURN l_element_type_id;

END;

END create_isetup_earnings;
--

FUNCTION create_isetup_deductions (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
                p_ben_class_id          in number,
		p_ele_category 		in varchar2	default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
                p_ele_proc_runtype      in varchar2,
                p_ele_start_rule        in varchar2,
                p_ele_stop_rule         in varchar2,
		p_ele_calc_rule 	in varchar2,
		p_ele_calc_rule_code 	in varchar2,
                p_ele_insuff_funds      in varchar2,
		p_ele_insuff_funds_code	in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date 	default NULL,
		p_bg_id			in number) RETURN NUMBER IS
BEGIN

DECLARE

  l_element_type_id pay_element_types_f.element_type_id%TYPE;

BEGIN

  IF UPPER(p_ele_classification) = 'INVOLUNTARY DEDUCTIONS' THEN

  l_element_type_id :=
    pay_ca_user_init_dedn.create_user_init_garnishment(
                p_ele_name             => p_ele_name,
                p_ele_reporting_name   => p_ele_reporting_name,
                p_ele_description      => p_ele_description,
                p_ele_classification   => p_ele_classification,
                p_ben_class_id         => p_ben_class_id,
                p_ele_category         => p_ele_category,
                p_ele_processing_type  => p_ele_processing_type,
                p_ele_priority         => p_ele_priority,
                p_ele_standard_link    => p_ele_standard_link,
                p_ele_proc_runtype     => p_ele_proc_runtype,
                p_ele_start_rule       => p_ele_start_rule,
                p_ele_stop_rule        => p_ele_stop_rule,
                p_ele_calc_rule        => p_ele_calc_rule,
                p_ele_calc_rule_code   => p_ele_calc_rule_code,
                p_ele_insuff_funds     => p_ele_insuff_funds,
                p_ele_insuff_funds_code => p_ele_insuff_funds_code,
                p_ele_t4a_footnote     => p_ele_t4a_footnote,
                p_ele_rl1_footnote     => p_ele_rl1_footnote,
                p_ele_registration_number => p_ele_registration_number,
                p_ele_eff_start_date   => p_ele_eff_start_date,
                p_ele_eff_end_date     => p_ele_eff_end_date,
		p_bg_id	               => p_bg_id);

  ELSE

  l_element_type_id :=
    pay_ca_user_init_dedn.create_user_init_deduction(
                p_ele_name             => p_ele_name,
                p_ele_reporting_name   => p_ele_reporting_name,
                p_ele_description      => p_ele_description,
                p_ele_classification   => p_ele_classification,
                p_ben_class_id         => p_ben_class_id,
                p_ele_category         => p_ele_category,
                p_ele_processing_type  => p_ele_processing_type,
                p_ele_priority         => p_ele_priority,
                p_ele_standard_link    => p_ele_standard_link,
                p_ele_proc_runtype     => p_ele_proc_runtype,
                p_ele_start_rule       => p_ele_start_rule,
                p_ele_stop_rule        => p_ele_stop_rule,
                p_ele_calc_rule        => p_ele_calc_rule,
                p_ele_calc_rule_code   => p_ele_calc_rule_code,
                p_ele_insuff_funds     => p_ele_insuff_funds,
                p_ele_insuff_funds_code => p_ele_insuff_funds_code,
                p_ele_t4a_footnote     => p_ele_t4a_footnote,
                p_ele_rl1_footnote     => p_ele_rl1_footnote,
                p_ele_registration_number => p_ele_registration_number,
                p_ele_eff_start_date   => p_ele_eff_start_date,
                p_ele_eff_end_date     => p_ele_eff_end_date,
		p_bg_id	               => p_bg_id);
  END IF;

  compile_formula(l_element_type_id);
  RETURN l_element_type_id;

END;

END create_isetup_deductions;

END pay_ca_isetup_earn_dedn;

/
