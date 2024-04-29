--------------------------------------------------------
--  DDL for Package PAY_CA_T4_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_T4_XML" AUTHID CURRENT_USER as
/* $Header: pycat4xml.pkh 120.4.12010000.2 2009/12/23 10:12:21 sneelapa ship $ */
/*

rem +======================================================================+
rem |                Copyright (c) 1993 Oracle Corporation                 |
rem |                   Redwood Shores, California, USA                    |
rem |                        All rights reserved.                          |
rem +======================================================================+
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   05-APR-2005  ssouresr    115.0  Created.
   30-NOV-2005  ssouresr    115.4  Changed fetch_t4_xml to be a procedure
   22-DEC-2009  sneelapa    115.6  Bug 7835218. Added get_ei_earnings_display_flag
*/

type other_info_rec is record (code   varchar2(3),
                               amount varchar2(50));

type other_info_tab is table of other_info_rec index by binary_integer;

g_other_info_list  other_info_tab;

procedure store_other_information(p_aa_id in number,
                                  p_prov  in varchar2);

procedure get_other_information(p_index  in     number,
                                p_code   in out nocopy varchar2,
                                p_amount in out nocopy varchar2);

function get_ei_earnings_display_flag(p_aa_id in number)
							return number;

procedure get_asg_xml;
procedure get_header_xml;
procedure get_trailer_xml;

procedure fetch_t4_xml(p_aa_id  in number,
                      p_pa_id  in number,
                      p_type   in varchar2,
                      p_print  in varchar2,
                      p_prov   in varchar2);

function create_xml_string (p_employer_name       varchar2,
                            p_employer_bn         varchar2,
                            p_employer_addr       varchar2,
                            p_employee_name       varchar2,
                            p_employee_last_name  varchar2,
                            p_employee_init       varchar2,
                            p_employee_addr       varchar2,
                            p_sin                 varchar2,
                            p_cpp_qpp_exempt      varchar2,
                            p_ei_exempt           varchar2,
                            p_employment_prov     varchar2,
                            p_employment_code     varchar2,
                            p_registration_number varchar2,
                            p_employment_income   varchar2,
                            p_cpp_contributions   varchar2,
                            p_qpp_contributions   varchar2,
                            p_ei_contributions    varchar2,
                            p_rpp_contributions   varchar2,
                            p_pension_adjustment  varchar2,
                            p_tax_deducted        varchar2,
                            p_ei_earnings         varchar2,
                            p_cpp_qpp_earnings    varchar2,
                            p_union_dues          varchar2,
                            p_charitable_donations varchar2,
                            p_other_code1         varchar2,
                            p_other_amount1       varchar2,
                            p_other_code2         varchar2,
                            p_other_amount2       varchar2,
                            p_other_code3         varchar2,
                            p_other_amount3       varchar2,
                            p_other_code4         varchar2,
                            p_other_amount4       varchar2,
                            p_other_code5         varchar2,
                            p_other_amount5       varchar2,
                            p_other_code6         varchar2,
                            p_other_amount6       varchar2,
                            p_year                varchar2,
                            p_ppip_exempt         varchar2,
                            p_ppip_contributions  varchar2,
                            p_ppip_earnings       varchar2,
                            p_gre_name            varchar2)
return varchar2;

function get_outfile return varchar2;

function get_IANA_charset return varchar2;

cursor main_block is
select 'Version_Number=X' ,'Version 1.1'
from   sys.dual;

cursor transfer_block is
select 'TRANSFER_ACT_ID=P', assignment_action_id
from pay_assignment_actions
where payroll_action_id =
      pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

cursor assignment_block is
select 'TRANSFER_ACT_ID=P',pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
from sys.dual;

level_cnt   NUMBER :=0;
g_temp_dir  VARCHAR2(512);

end pay_ca_t4_xml;

/
