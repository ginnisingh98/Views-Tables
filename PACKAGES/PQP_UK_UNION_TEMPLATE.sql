--------------------------------------------------------
--  DDL for Package PQP_UK_UNION_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_UK_UNION_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqgbundt.pkh 120.1 2005/05/30 00:12:36 rvishwan noship $ */


-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'GB';
   g_template_leg_subgroup   VARCHAR2(30);
------------------------------------------------------------------------
FUNCTION create_user_template
           (p_frm_union_name                IN VARCHAR2
           -- Convert to Org_ID = Extra Element Info #1
           ,p_frm_element_name              IN VARCHAR2
           -- <BASENAME>
           ,p_frm_reporting_name            IN VARCHAR2
           -- IF NULL THEN = <BASENAME>
           ,p_frm_description               IN VARCHAR2   DEFAULT NULL
           --
--         ,p_frm_classification            IN VARCHAR2
           -- Always 'Voluntary Deduction'
           ,p_frm_processing_type           IN VARCHAR2
           -- 'N'on-Recurring or 'R'ecurring
           ,p_frm_override_amount           IN VARCHAR2   DEFAULT 'N'
           -- 'Y'es/'N'o
           ,p_frm_tax_relief                IN VARCHAR2   DEFAULT 'N'
           -- 'Y'es/'N'o
           ,p_frm_supplementary_levy        IN VARCHAR2   DEFAULT 'N'
           -- 'Y'es/'N'o
           ,p_frm_union_level_balance       IN VARCHAR2
           -- Mandatory
           ,p_frm_union_level_balance_yn    IN VARCHAR2
           -- Mandatory 'Y'es/'N'o
           ,p_frm_rate_type                 IN VARCHAR2   DEFAULT NULL
           -- Extra Element Info #2
           ,p_frm_fund_list                 IN VARCHAR2   DEFAULT NULL
           -- Name of the Lookup Type for funds selected
           ,p_frm_effective_start_date      IN DATE       DEFAULT NULL
           -- Standard
           ,p_frm_effective_end_date        IN DATE       DEFAULT NULL
           -- Standard
           ,p_frm_business_group_id         IN NUMBER
           -- Standard Business Group ID
           )
   RETURN NUMBER; -- The union element type core object id
--
PROCEDURE delete_user_template
           (p_frm_union_name               IN VARCHAR2
           ,p_frm_union_level_balance      IN VARCHAR2
           ,p_frm_element_type_id          IN NUMBER
           ,p_frm_element_name             IN VARCHAR2
           ,p_frm_business_group_id        IN NUMBER
           ,p_frm_effective_date           IN DATE
           );
--
END pqp_uk_union_template;

 

/
