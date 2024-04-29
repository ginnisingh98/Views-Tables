--------------------------------------------------------
--  DDL for Package PAY_FR_DADS_ESTAB_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_DADS_ESTAB_COMP" AUTHID CURRENT_USER AS
/* $Header: pyfrdesc.pkh 115.3 2003/12/10 02:39:54 abhaduri noship $ */
  --
 --
  TYPE cre_info_issue_rec is RECORD
  (cre_estab_id   hr_organization_information.organization_id%TYPE,
   cre_name       hr_all_organization_units_tl.name%TYPE,
   cre_siren      hr_organization_information.org_information1%TYPE,
   cre_nic        varchar2(7),
   cre_media      hr_organization_information.org_information1%TYPE ,
   address_to_use hr_organization_information.org_information2%TYPE);
   --
  g_cre_info_issue cre_info_issue_rec;
  --
  PROCEDURE S10_00_issue_estab(p_param_reference          IN VARCHAR2,
                                p_param_issuing_estab_id  IN NUMBER,
                                p_param_business_group_id IN NUMBER,
				p_payroll_action_id       IN NUMBER,
                                p_cre_info_issue          OUT NOCOPY g_cre_info_issue%TYPE);

  --
  PROCEDURE S10_01_issue_person(p_issuing_estab_id    IN NUMBER,
  				p_payroll_action_id   IN NUMBER);
  --
  PROCEDURE S20_comp_info(p_company_id        IN NUMBER,
                          p_cre_info_issue    IN g_cre_info_issue%TYPE,
                          p_dads_start_date   IN DATE,
                          p_dads_end_date     IN DATE,
			  p_payroll_action_id IN NUMBER);
  --
  PROCEDURE S80_insee_estab (p_estab_id          IN NUMBER,
                             p_payroll_action_id IN NUMBER,
                             p_dads_end_date     IN DATE);
  --
END;

 

/
