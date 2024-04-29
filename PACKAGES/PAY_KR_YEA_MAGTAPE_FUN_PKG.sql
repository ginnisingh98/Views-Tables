--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_MAGTAPE_FUN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_MAGTAPE_FUN_PKG" AUTHID CURRENT_USER as
/* $Header: pykryean.pkh 120.2.12010000.2 2010/01/27 14:24:37 vaisriva ship $ */
--
level_cnt               number;
--
type t_b_record is record(
        tax_unit_id     number,
        c_records       number,
        taxable         number,
        annual_itax     number,
        annual_rtax     number,
        annual_stax     number,
        d_records       number);
g_b_record              t_b_record;
--
type t_c_record is record(
        assignment_id   number,
        d_records_per_c number);
g_c_record              t_c_record;
------------------------------------------------------------------------
function b_data(
        p_bp_number           in varchar2,
        p_tax_office_code     in varchar2,
        p_item_name           in varchar2) return varchar2;
------------------------------------------------------------------------
function c_data(
        p_assignment_id in number,
        p_item_name     in varchar2) return varchar2;
------------------------------------------------------------------------
function latest_yea_action(
	p_asg_action_id  in  pay_assignment_actions.assignment_action_id%type,
        p_pact           in  number,
        p_target_year    in  number
)  return varchar2;
------------------------------------------------------------------------
function e_record_count(
        p_ass_id      in varchar2,
        p_eff_date    in date
) return number;
------------------------------------------------------------------------
-- Bug 9213683: Created a new function to fetch the non-taxable earnings
--              values for the Previous employer.
------------------------------------------------------------------------
function prev_non_tax_values(
                             p_assignment_id 	in varchar2,
                             p_bp_number	in varchar2,
                             p_code		in varchar2,
                             p_effective_date   in date) return number;
------------------------------------------------------------------------
end pay_kr_yea_magtape_fun_pkg;

/
