--------------------------------------------------------
--  DDL for Package PAY_AU_PAYSUM_ALLOWANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYSUM_ALLOWANCE" AUTHID CURRENT_USER as
/* $Header: pyaupsalw.pkh 120.0.12010000.1 2009/02/06 04:36:27 skshin noship $*/
/*
*** ------------------------------------------------------------------------+
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 18 DEC 08  skshin      115.0   7571001  Initial Version
*** 23 DEC 08  skshin      115.1   7571001  added Validate/Transfer mode
*** 23 DEC 08  skshin      115.3   7571001  Broken into small procedures
*** ------------------------------------------------------------------------+
*/

TYPE recd_allowance_balance IS RECORD ( balance_name pay_balance_types.balance_name%type
                                       ,defined_balance_id pay_defined_balances.defined_balance_id%type
                                       ,balance_type_id pay_balance_types.balance_type_id%type);
TYPE tab_allowance_balance IS TABLE OF recd_allowance_balance INDEX BY BINARY_INTEGER;
t_allowance_balance tab_allowance_balance;
tl_allowance_balance tab_allowance_balance;

  procedure upgrade_allowance_bar(
                                  errbuf    out NOCOPY varchar2,
                                  retcode   out NOCOPY varchar2,
                                  p_business_group_id in HR_ALL_ORGANIZATION_UNITS.organization_id%type,
                                  p_mode in varchar2
                                  );

  procedure upgrade_ba (
                                  p_cnt in number,
                                  p_allowance_balance in tab_allowance_balance,
                                  p_business_group_id in HR_ALL_ORGANIZATION_UNITS.organization_id%type,
                                  p_mode in varchar2
                                  );

  procedure upgrade_glr (
                                  p_t_allowance_balance in tab_allowance_balance,
                                  p_tl_allowance_balance in tab_allowance_balance,
                                  p_business_group_name in per_business_groups.name%type,
                                  p_mode in varchar2
                                  ) ;

procedure check_run (
                                  p_t_allowance_balance in tab_allowance_balance,
                                  p_tl_allowance_balance in tab_allowance_balance,
                                  p_mode in varchar2
                                  ) ;

END pay_au_paysum_allowance;

/
