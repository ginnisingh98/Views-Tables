--------------------------------------------------------
--  DDL for Package PAY_CA_MAG_ROE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_MAG_ROE" AUTHID CURRENT_USER as
/* $Header: pycaremg.pkh 115.2 2004/01/19 17:55:03 pganguly noship $ */

TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
level_cnt	number;

cursor cur_mag_roe is
select 'ASSIGNMENT_ACTION_ID=C', pai.locked_action_id
from
	pay_assignment_actions paa,
	pay_payroll_actions    ppa,
	pay_action_interlocks  pai
where
	ppa.payroll_action_id=pay_magtape_generic.get_parameter_value
				('TRANSFER_PAYROLL_ACTION_ID') and
	ppa.payroll_action_id=paa.payroll_action_id and
	paa.assignment_action_id= pai.locking_action_id;


procedure range_cursor(p_pactid in  number,
                       p_sqlstr out nocopy varchar2);

procedure create_assignment_act(p_pactid in number,
                          p_stperson in number,
                          p_endperson in number,
                          p_chunk in number);

end pay_ca_mag_roe;

 

/
