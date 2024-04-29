--------------------------------------------------------
--  DDL for Package HR_US_W2_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_W2_REP" AUTHID CURRENT_USER AS
/* $Header: pyusw2pg.pkh 120.1.12010000.3 2009/09/14 12:58:57 kagangul ship $ */



/*
Name        : hr_us_w2_rep (Header)
File        : pyusw2pg.pkh
Description : This package declares functions and procedures which are
              used to return values for the W2 US Payroll reports.

Change List
-----------

Version Date      Author      Bug No.   Description of Change
-------+---------+-----------+---------+----------------------------------
40.0    13-MAY-98 ssarma                Date Created
40.1    22-JUL-99 ssarma                Added the following functions :
                                        get_w2_tax_item, get_tax_unit_addr_line,
                                        get_tax_unit_bg, get_per_item,
                                        get_state_item.
115.6   10-AUG-01 kthirmiy              Added a new function get_leav_reason
                                        to get the termination reason meaning
                                        to fix the bug 1482168.
115.8   16-SEP-01 ssarma                Overloaded function get_w2_box_15
115.9   17-SEP-01 ssarma                Removed default for effective date from
                                        function get_w2_box_15.
115.10  30-NOV-01 meshah                add dbdrv.
115.11  17-May-02 fusman                add checkfile dbdrv.
115.11  24-JUN-02 rsirigir              As per bug 2429333 from
                                        FUNCTION  get_w2_arch_bal
                                        (w2_tax_unit_id in number,
                                        to
                                        FUNCTION  get_w2_arch_bal
                                        (w2_tax_unit_id in number DEFAULT NULL,
115.12  24-JUN-02 rsirigir              As per bug 2429333 from
                                        FUNCTION  get_w2_arch_bal
                                        (w2_jurisdiction_code in varchar2,
                                        to
                                        FUNCTION  get_w2_arch_bal
                                        (w2_jurisdiction_code
                                         varchar2 DEFAULT NULL,
115.15  06-AUG-02 ppanda                For fixing Bug #2145804 and 2207317
                                        a procedure get_county_tax_info added
115.16  10-SEP-02 kthirmiy              Added a procedure get_agent_tax_unit_id
                                        for the Agent reporting Enhancement
115.17 13-Nov-2002 fusman      2625264  Added Pl/sql table to check the optional
                                        reporting parameter of fed wages in state wages
                                        for NY
115.18 13-Nov-2002 fusman               Moved the PL/SQL declaration to package header.
                                        Removed WNPS from RESTRICT_REFERENCES for
                                        get_w2_arch_bal function.
115.20 02-DEC-2002 asasthan             nocopy chnages for gscc compliance
115.23 12-AUG-2003 rsethupa    2631650  Rolled back the changes intoduced in version
                                        115.22
115.24 26-AUG-2003 meshah               Added in a new function
                                        get_w2_box17_label. This function is
                                        called from the pay_us_locality_w2_v.
115.25 27-SEP-2007 sausingh   5517938   Added a new function get_last_deffer_year
                                         to display first year of designated roth
                                         contribution
115.27 14-Sep-2009 kagangul   8353425   Added a new function get_w2_employee_name.
=============================================================================

*/
TYPE tax_info_record IS RECORD (
     tax_unit_id       number(15),
     tax_value         varchar2(1));

TYPE newyork_tax_tabrec IS TABLE OF tax_info_record
INDEX BY BINARY_INTEGER;
ltr_newyork_tax_table newyork_tax_tabrec;

  TYPE box17_rec IS RECORD
       ( tax_unit_id    number
       , state_abbrev   varchar2(2)
       , value          varchar2(10)
       );

  TYPE box17_table IS TABLE OF
       box17_rec
  INDEX BY BINARY_INTEGER;

  ltr_box17     box17_table;


FUNCTION  get_user_entity_id(w2_balance_name in varchar2)
                          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES(get_user_entity_id, WNDS,WNPS);

FUNCTION  get_context_id(w2_context_name in varchar2)
                          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES(get_context_id, WNDS,WNPS);

FUNCTION  get_w2_bal_amt(w2_asg_act_id   in number,
                         w2_balance_name in varchar2,
                         w2_tax_unit_id  in varchar2,
                         w2_jurisdiction_code in varchar2,
                         w2_jurisdiction_level in number)
                          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES(get_w2_bal_amt, WNDS,WNPS);

FUNCTION  get_w2_arch_bal(w2_asg_act_id in number,
                         w2_balance_name in varchar2,
                         w2_tax_unit_id in number DEFAULT NULL,
                         w2_jurisdiction_code in  varchar2 DEFAULT NULL,
                         --w2_tax_unit_id  in number,
                         --w2_jurisdiction_code in varchar2,
                         w2_jurisdiction_level in number)
                          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES(get_w2_arch_bal, WNDS);

FUNCTION get_w2_organization_id(w2_asg_id in number,
                                w2_effective_date in date)
			  RETURN NUMBER;
	 PRAGMA RESTRICT_REFERENCES(get_w2_organization_id, WNDS,WNPS);

FUNCTION get_w2_location_id(w2_asg_id in number,
                            w2_effective_date in date)
                          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES(get_w2_location_id, WNDS,WNPS);

FUNCTION get_w2_postal_code(w2_person_id in number,
                            w2_effective_date in date)
                          RETURN VARCHAR2;
         PRAGMA RESTRICT_REFERENCES(get_w2_postal_code, WNDS,WNPS);

FUNCTION get_w2_employee_name(w2_person_id IN NUMBER, w2_effective_date IN DATE)
RETURN VARCHAR2;
	PRAGMA RESTRICT_REFERENCES(get_w2_employee_name, WNDS,WNPS);

FUNCTION get_w2_state_ein      (   w2_tax_unit_id in number,
				w2_state_abbrev in varchar2)
				RETURN varchar2;
	 PRAGMA RESTRICT_REFERENCES(get_w2_state_ein, WNDS,WNPS);

FUNCTION get_w2_state_uin      (   w2_tax_unit_id in number,
                                w2_state_abbrev in varchar2)
                                RETURN varchar2;
         PRAGMA RESTRICT_REFERENCES(get_w2_state_uin, WNDS,WNPS);

FUNCTION get_w2_high_comp_amt  (w2_rownum in number,
				w2_restrict in number,
				w2_bal_amt in number)
				RETURN number;
	PRAGMA RESTRICT_REFERENCES(get_w2_high_comp_amt, WNDS,WNPS);

FUNCTION get_w2_box_15 (w2_asg_act_id   in number,
                        w2_balance_name in varchar2,
                        w2_tax_unit_id  in number,
                        w2_jurisdiction_code in varchar2,
                        w2_jurisdiction_level in number
                        ) RETURN varchar2;
	PRAGMA RESTRICT_REFERENCES(get_w2_box_15, WNDS,WNPS);

FUNCTION get_w2_box_15 (w2_asg_act_id   in number,
                        w2_balance_name in varchar2,
                        w2_tax_unit_id  in number,
                        w2_jurisdiction_code in varchar2,
                        w2_jurisdiction_level in number,
                        w2_effective_date in date ) RETURN varchar2;
	PRAGMA RESTRICT_REFERENCES(get_w2_box_15, WNDS,WNPS);

FUNCTION get_w2_tax_unit_item ( w2_tax_unit_id in number,
                                w2_payroll_action_id in number,
                                w2_tax_unit_item in varchar2)
                                RETURN varchar2;
         PRAGMA RESTRICT_REFERENCES(get_w2_tax_unit_item, WNDS,WNPS);

FUNCTION get_tax_unit_addr_line (w2_tax_unit_id in  number,
                                 w2_addr_item in varchar2)
                                 RETURN varchar2 ;
         PRAGMA RESTRICT_REFERENCES(get_tax_unit_addr_line, WNDS,WNPS);

FUNCTION get_tax_unit_bg(w2_tax_unit_id   in number)
                                 RETURN number;
         PRAGMA RESTRICT_REFERENCES(get_tax_unit_bg, WNDS,WNPS);

FUNCTION get_per_item (w2_assignment_action_id in   number,
                       w2_per_item             in   varchar2)
                       RETURN VARCHAR2;
         PRAGMA RESTRICT_REFERENCES(get_per_item, WNDS,WNPS);

FUNCTION get_state_item (w2_tax_unit_id   in number,
                         w2_jurisdiction_code in varchar2,
                         w2_payroll_action_id in number,
                         w2_state_item in varchar2)
                         RETURN VARCHAR2;
         PRAGMA RESTRICT_REFERENCES(get_state_item, WNDS,WNPS);

FUNCTION get_leav_reason (w2_leaving_reason   in varchar2)
                         RETURN VARCHAR2;
         PRAGMA RESTRICT_REFERENCES(get_leav_reason, WNDS,WNPS);

PROCEDURE GET_COUNTY_TAX_INFO ( p_jurisdiction_code in Varchar2 ,
                                p_tax_year           in number,
                                p_tax_rate           out nocopy number,
                                P_mh_tax_rate        out nocopy number,
                                P_mh_tax_limit       out nocopy number,
                                P_occ_mh_tax_limit   out nocopy number,
                                P_occ_mh_wage_limit  out nocopy number,
                                P_mh_tax_wage_limit  out nocopy number
                              );


PROCEDURE get_agent_tax_unit_id( p_business_group_id in number,
                                 p_year              in number,
                                 p_agent_tax_unit_id out nocopy number,
                                 p_error_mesg        out nocopy varchar2 ) ;

FUNCTION  get_w2_userra_bal(w2_asg_act_id in number,
                            w2_tax_unit_id in number DEFAULT NULL,
                            w2_jurisdiction_code in  varchar2 DEFAULT NULL,
                            w2_jurisdiction_level in number,
                            p_userra_code in varchar2
                            )
                          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES(get_w2_userra_bal, WNDS,WNPS);

FUNCTION  get_w2_box17_label (p_tax_unit_id    in number,
                              p_state_abbrev   in varchar2)
return varchar2;

FUNCTION get_last_deffer_year ( p_ass_action_id in number)

return varchar2;

  FUNCTION get_w2_employee_number(w2_nat_ident in varchar2, w2_effective_date in date)
                          RETURN varchar2;
  FUNCTION get_w2_worker_compensation(w2_asg_id in number, w2_effective_date in date)
                          RETURN varchar2;
  FUNCTION get_w2_location_cd(w2_asg_id in number, w2_effective_date in date)
                          RETURN varchar2;
end hr_us_w2_rep;


/
