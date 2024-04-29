--------------------------------------------------------
--  DDL for Package PAY_AU_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyauparc.pkh 120.0.12010000.1 2008/07/27 22:05:51 appldev ship $ */

procedure range_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type
,p_sql                      out NOCOPY varchar2
);

procedure initialization_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type);

procedure assignment_action_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type
,p_start_person             in per_all_people_f.person_id%type
,p_end_person               in per_all_people_f.person_id%type
,p_chunk                    in number
);

procedure archive_code
(p_assignment_action_id     in pay_assignment_actions.assignment_action_id%type
,p_effective_date           in pay_payroll_actions.effective_date%type
);

end pay_au_payslip_archive;

/
