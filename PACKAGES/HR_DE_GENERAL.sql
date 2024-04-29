--------------------------------------------------------
--  DDL for Package HR_DE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_GENERAL" AUTHID CURRENT_USER AS
/* $Header: pedegenr.pkh 115.14 2003/02/24 16:01:48 rmakhija noship $ */
--
FUNCTION get_three_digit_code(p_legislation_code in varchar2)
RETURN VARCHAR2;
--
--
PROCEDURE get_social_insurance_globals(
					p_business_group_id              in number
				       ,p_effective_date                in date
				       ,o_hlth_ins_contrib_insig_pct    out nocopy number
				       ,o_pens_ins_contrib_insig_pct    out nocopy number
				       ,o_spcl_care_ins_pct             out nocopy number
                                       ,o_pens_ins_pect                 out nocopy number
                                       ,o_unemp_ins_pect                out nocopy number
                                       ,o_hlth_ins_mon_gross_contrib    out nocopy number
                                       ,o_pens_ins_mon_gross_contrib_w  out nocopy number
                                       ,o_pens_ins_mon_gross_contrib_e  out nocopy number
                                       ,o_minr_ins_mon_gross_contrib_w  out nocopy number
                                       ,o_minr_ins_mon_gross_contrib_e  out nocopy number
                                       ,o_hlth_ins_contrib_insigph_pct  out nocopy number
                                       ,o_pens_ins_contrib_insigph_pct  out nocopy number
                                       ,o_tax_contrib_insig_pct         out nocopy number
                                       ,o_tax_contrib_insigph_pct       out nocopy number
                                       ,o_pvt_hlth_ins_min_mon_gross    out nocopy number
										);
--
function business_group_currency
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type;

function get_tax_office_details (p_organization_id in integer) return varchar2;
 --
 --
 -- Function to return a value from a user table i.e. a user column instance.
 --
 FUNCTION get_uci
 (p_effective_date   DATE
 ,p_user_table_id    NUMBER
 ,p_user_row_id      NUMBER
 ,p_user_column_name VARCHAR2) RETURN VARCHAR2;


-- Retrieve Provider names
function get_org_name (p_org_id in number)  return varchar2;

-- Get the max effective_start_date for a given element entry id. This date is shown
-- on the tax Information screen.
function max_tax_info_date (p_element_entry_id in varchar2) return date;

--Retrieve end reason no for DE PS
function get_end_reason_no(p_end_reason_id in number) return number;
--
--retrieve the end reason text for DE PS
function get_end_reason_desc(p_end_reason_id in number) return varchar2;

END hr_de_general;

 

/
