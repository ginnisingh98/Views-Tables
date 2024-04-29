--------------------------------------------------------
--  DDL for Package PQP_GB_STAKEHOLDER_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_STAKEHOLDER_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqgbstht.pkh 120.1 2005/05/30 00:12:29 rvishwan noship $ */



   g_proc                    VARCHAR2(31) := 'pqp_gb_stakeholder_template.';
   -- Legislation Subgroup Code for all template elements.
   g_template_leg_code       VARCHAR2(30) := 'GB';
   g_template_leg_subgroup   VARCHAR2(30);

FUNCTION create_user_template
           (p_frm_sd_scheme_name           IN    VARCHAR2 -- 'Stakeholder'
           ,p_frm_sd_contribution_method   IN    VARCHAR2 -- Ex Rule Eme Cntrbn
           ,p_frm_sd_employee_contribution IN    NUMBER
           ,p_frm_be_element_name          IN    VARCHAR2
           ,p_frm_be_reporting_name        IN    VARCHAR2
--         ,p_frm_be_classification        --    Always 'Voluntary Deductions'
           ,p_frm_be_description           IN    VARCHAR2 DEFAULT NULL
           ,p_frm_ae_employer_contribution IN    VARCHAR2 DEFAULT 'N' --Ex Rule
           ,p_frm_ae_type                  IN    VARCHAR2 DEFAULT NULL
           ,p_frm_ae_rate                  IN    NUMBER   DEFAULT NULL
           ,p_frm_ctl_effective_start_date IN    DATE     DEFAULT NULL
           ,p_frm_ctl_effective_end_date   IN    DATE     DEFAULT NULL
           ,p_frm_ctl_business_group_id    IN    NUMBER
           )
   RETURN NUMBER ; -- Base Element Core Object ID
--
PROCEDURE delete_user_template
            (p_frm_ctl_business_group_id     IN     NUMBER
            ,p_frm_ctl_element_type_id       IN     NUMBER
            ,p_frm_be_element_name           IN     VARCHAR2
            ,p_frm_ctl_effective_start_date  IN     DATE
            );

--
END pqp_gb_stakeholder_template;

 

/
