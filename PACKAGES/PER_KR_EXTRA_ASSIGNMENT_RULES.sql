--------------------------------------------------------
--  DDL for Package PER_KR_EXTRA_ASSIGNMENT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_EXTRA_ASSIGNMENT_RULES" AUTHID CURRENT_USER as
/* $Header: pekrexas.pkh 120.0 2005/05/31 11:05:38 appldev noship $ */
--
procedure chk_establishment_id(
            p_establishment_id   in number,
            p_assignment_type    in varchar2,
            p_payroll_id         in number,
            p_effective_date     in date);
--
procedure chk_establishment_id_upd(
            p_establishment_id   in number,
            p_establishment_id_o in number,
            p_assignment_type    in varchar2,
            p_payroll_id         in number,
            p_effective_date     in date);
--
end per_kr_extra_assignment_rules;

 

/
