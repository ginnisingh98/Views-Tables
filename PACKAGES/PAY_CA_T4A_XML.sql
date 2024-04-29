--------------------------------------------------------
--  DDL for Package PAY_CA_T4A_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_T4A_XML" AUTHID CURRENT_USER as
/* $Header: pycat4axml.pkh 120.0.12010000.1 2009/09/08 07:49:45 sapalani noship $ */
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
   25-AUG-2009  sapalani    115.0  Created.
*/

procedure get_asg_xml;
procedure get_header_xml;
procedure get_trailer_xml;

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
from pay_assignment_actions
where assignment_action_id=pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
      and substr(serial_number,29,1)='N';

level_cnt   NUMBER :=0;
g_err_emp   varchar2(1);
g_aa_id     number;
g_pa_id     number;

end pay_ca_t4a_xml;

/
