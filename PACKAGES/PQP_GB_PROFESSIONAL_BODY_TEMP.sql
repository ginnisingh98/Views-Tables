--------------------------------------------------------
--  DDL for Package PQP_GB_PROFESSIONAL_BODY_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PROFESSIONAL_BODY_TEMP" AUTHID CURRENT_USER AS
/* $Header: pqgbpbtp.pkh 120.1 2005/05/30 00:12:18 rvishwan noship $*/


-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'GB';
   g_template_leg_subgroup   VARCHAR2(30);
------------------------------------------------------------------------
FUNCTION create_user_template
           (p_professional_body_name        in varchar2
           ,p_ele_name                      in varchar2
           ,p_ele_reporting_name            in varchar2
           ,p_ele_description               in varchar2   default null
           ,p_ele_processing_type           in varchar2
           ,p_ele_third_party_payment       in varchar2   default 'Y'
           ,p_override_amount               in varchar2   default 'N'
           ,p_professional_body_level_bal   in varchar2
           ,p_professional_body_level_yn    in varchar2
           ,p_ele_eff_start_date            in date       default null
           ,p_ele_eff_end_date              in date       default null
           ,p_bg_id                         in number
           )
   RETURN NUMBER;
--
PROCEDURE delete_user_template
           (p_professional_body_name       in varchar2
           ,p_professional_body_level_bal  in varchar2
           ,p_business_group_id            in number
           ,p_ele_type_id                  in number
           ,p_ele_name                     in varchar2
           ,p_effective_date               in date
           );
--
END pqp_gb_professional_body_temp;

 

/
