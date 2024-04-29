--------------------------------------------------------
--  DDL for Package HR_FR_ASG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_ASG_RULES" AUTHID CURRENT_USER AS
/* $Header: pefrasgr.pkh 115.5 2002/03/15 04:19:15 pkm ship      $ */
--
procedure mandatory_checks(
        p_assignment_id     in number,
        p_payroll_id        in number,
        p_establishment_id  in number,
        p_contract_id       in number,
        p_assignment_type   in varchar2);

procedure mandatory_checks_ins(
        p_assignment_id     in number,
        p_effective_start_date in date,
        p_effective_end_date in date,
        p_payroll_id        in number,
        p_establishment_id  in number,
        p_contract_id       in number,
        p_period_of_service_id in number,
        p_assignment_type   in varchar2);
--
END HR_FR_ASG_RULES;

 

/
