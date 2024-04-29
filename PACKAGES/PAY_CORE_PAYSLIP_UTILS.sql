--------------------------------------------------------
--  DDL for Package PAY_CORE_PAYSLIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_PAYSLIP_UTILS" AUTHID CURRENT_USER AS
/* $Header: pycopysl.pkh 115.0 2004/04/02 01:43:55 tbattoo noship $ */

PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2);

function get_max_nor_act_seq(p_payroll_action_id    in number,
                             p_assignment_action_id in number,
                             p_effective_date       in date)
return number;

PROCEDURE action_creation (pactid in number,
                           stperson in number,
                           endperson in number,
                           chunk in number,
                           p_report_type in varchar2,
                           p_report_qualifier in varchar2);

PROCEDURE generate_child_actions (p_assactid in number,
                        p_effective_date in date);

END pay_core_payslip_utils;

 

/
