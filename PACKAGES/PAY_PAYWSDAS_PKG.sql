--------------------------------------------------------
--  DDL for Package PAY_PAYWSDAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYWSDAS_PKG" AUTHID CURRENT_USER as
/* $Header: pywsdas1.pkh 120.1 2005/12/23 02:43:54 arashid noship $ */
--
--
function get_formula_type return number;
--
--
function get_formula_id(p_assignment_set_id in number) return number;
--
--
function get_assignment_sets_s return number;
--
--
procedure get_min_max_line(p_assignment_set_id in     number,
                           p_min_line_no       in out nocopy number,
                           p_max_line_no       in out nocopy number);
--
--
function no_criteria_exists(p_assignment_set_id in number) return boolean;
--
--
procedure check_amendment_exists(p_assignment_set_id in number);
--
--
procedure check_unq_amendment(p_assignment_set_id in number,
                              p_assignment_id     in number,
                              p_rowid             in varchar2);
--
--
procedure check_amd_inc_exc(p_assignment_set_id in number);
--
--
procedure check_include_exclude(p_assignment_set_id in number,
                                p_include_exclude   in varchar2,
                                p_rowid             in varchar2);
--
--
procedure check_criteria_exists(p_assignment_set_id in number,
                                p_line_no           in number default 0);
--
--
procedure check_operand(p_business_group_id  in number,
                        p_legislation_code   in varchar2,
                        p_formula_type_id    in number,
                        p_data_type          in out nocopy varchar2,
                        p_operand            in varchar2);
--
--
procedure check_unique_name(p_assignment_set_name in varchar2,
                            p_business_group_id   in number,
                            p_rowid               in varchar2,
                            p_formula_type_id     in number,
                            p_legislation_code    in varchar2);
--
--
procedure check_line_no(p_assignment_set_id  in number,
                        p_line_no            in number,
                        p_rowid              in varchar2);
--
--
procedure delete_formula(p_formula_id      in number,
                         p_formula_type_id in number);
--
--
/*
 * NAME
 *   fetch_dbi_info
 *
 * DESCRIPTION
 *   Fetches database item information given the ASSIGNMENT_SET_ID,
 *   FORMULA_TYPE_ID, and OPERAND_VALUE (database item name). This
 *   will replace FF_DATABASE_ITEMS query in the ASSIGNMENT_SET
 *   user-exit C code.
 */
procedure fetch_dbi_info
(p_assignment_set_id in number
,p_formula_type_id in number
,p_date_format in varchar2
,p_operand_value in varchar2
,p_data_type out nocopy varchar2
,p_null_allowed out nocopy varchar2
,p_notfound_allowed out nocopy varchar2
,p_start_of_time out nocopy varchar2
);
--
--

end PAY_PAYWSDAS_PKG;

 

/
