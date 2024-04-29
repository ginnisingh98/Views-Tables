--------------------------------------------------------
--  DDL for Package PAY_ADVANCE_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ADVANCE_PAY_PKG" AUTHID CURRENT_USER as
/* $Header: paywsahp.pkh 120.0 2005/05/29 02:44:37 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
        PAY_ADVANCE_PAY_PKG
Purpose
	Server agent for PAYWSAHP form.
History
	18 Feb 97   40.0	M. Lisiecki	Created
		    40.1        M. Lisiecki     Pre release changes.
        17 Jun 97   40.2        M. Lisiecki     Added pragma to
	                                        advanced_periods
        25 Jun 97   40.3        M.Lisiecki      Changed get_balance and
						advance_amount to return char
						values.
        25 Jun 97   40.4        M.Lisiecki      Changed get_balance return
	                                        statement back to number
						value.
        10 Feb 98   110.2       T.Battoo        Added parameter to
                                                advance_amount and
                                                get_processed_flag function

        21 Jul 04   115.1       SuSivasu        Fixes for GSCC errors.
        17 Aug 04   115.2       SuSivasu        Added get_advance_period_start_date
                                                and get_advance_period_end_date.

									*/
--------------------------------------------------------------------------------
function advance_amount
(
p_advance_pay_start_date   date,
p_target_entry_id          number,
p_assignment_id            number
)
return varchar2;
pragma restrict_references (advance_amount,WNPS,WNDS);
--------------------------------------------------------------------------------
function get_balance
(
p_legislation_code         varchar2,
p_balance_lookup_name      varchar2,
p_assignment_id            number,
p_session_date           date
)
return number;
--------------------------------------------------------------------------------
function get_processed_flag
(
p_advance_pay_start_date      date,
p_target_entry_id            number,
p_assignment_id            number
)
return varchar2;
pragma restrict_references (get_processed_flag,WNPS,WNDS);
--------------------------------------------------------------------------------
function advanced_periods
(
p_assignment_id             number,
p_advance_pay_start_date    date,
p_advance_pay_end_date      date
)
return number;
pragma restrict_references (advanced_periods,WNPS,WNDS);
--------------------------------------------------------------------------------
function get_period_start_date
(
p_assignment_id number,
p_session_date  date
)
return date;
--------------------------------------------------------------------------------
function get_period_end_date
(
p_assignment_id number,
p_session_date  date
)
return date;
--------------------------------------------------------------------------------
function get_advance_period_start_date
(
p_assignment_id number,
p_session_date  date,
p_flag          varchar2
)
return date;
--------------------------------------------------------------------------------
function get_advance_period_end_date
(
p_assignment_id number,
p_session_date  date,
p_flag          varchar2
)
return date;
--------------------------------------------------------------------------------
procedure insert_indicator_entries
(
p_defer_flag in varchar2,
p_assignment_id in number,
p_session_date in out nocopy date,
p_pai_element_entry_id in out nocopy number,
p_pai_element_type_id  in number,
p_pai_sd_input_value_id in number,
p_pai_ed_input_value_id in number,
p_pai_start_date in date,
p_pai_end_date in date,
p_advance_pay_start_date in date,
p_advance_pay_end_date in date,
p_arrears_flag in varchar2,
p_periods_advanced in number,
p_ai_element_type_id in number,
p_ai_af_input_value_id in number,
p_ai_dpf_input_value_id in number
);
--------------------------------------------------------------------------------
procedure delete_indicator_entries
(
p_assignment_id in number,
p_legislation_code in varchar2,
p_session_date  in date,
p_pai_element_entry_id in number,
p_arrears_flag in varchar2
);
--------------------------------------------------------------------------------
end PAY_ADVANCE_PAY_PKG;

 

/
