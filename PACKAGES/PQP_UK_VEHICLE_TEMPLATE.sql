--------------------------------------------------------
--  DDL for Package PQP_UK_VEHICLE_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_UK_VEHICLE_TEMPLATE" AUTHID CURRENT_USER as
/* $Header: pqukcmtp.pkh 120.0 2005/05/29 02:13:02 appldev noship $ */


-- Legislation Subgroup Code for all template elements.
   g_template_leg_code       VARCHAR2(30) := 'GB';
   g_template_leg_subgroup   VARCHAR2(30);
------------------------------------------------------------------------
FUNCTION create_user_template
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_ele_processing_type   in varchar2
           ,p_ele_priority          in number       default NULL
           ,p_ele_standard_link     in varchar2     default 'N'
           ,p_veh_type              in varchar2
           ,p_table_indicator_flg   in varchar2
           ,p_table_name            in varchar2
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_bg_id                 in number
           )
   RETURN NUMBER ;
--
PROCEDURE delete_user_template
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date    	in date
           );

--
END pqp_uk_vehicle_template ;

 

/
