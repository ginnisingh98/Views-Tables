--------------------------------------------------------
--  DDL for Package PER_RI_WORKBENCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_WORKBENCH_PKG" AUTHID CURRENT_USER As
/* $Header: perriwkb.pkh 120.2.12010000.1 2008/07/28 05:49:23 appldev ship $ */
Procedure load_workbench_item_row
  (   p_workbench_item_code            In  Varchar2
     ,p_workbench_item_name            In  Varchar2
     ,p_workbench_item_description     In  Varchar2
     ,p_menu_name                      In  Varchar2
     ,p_workbench_item_sequence        In  Number
     ,p_workbench_parent_item_code     In  Varchar2
     ,p_workbench_item_creation_date   In  Date
     ,p_workbench_item_type            In  Varchar2
     ,p_effective_date                 In  Date
 ) ;

Procedure translate_workbench_item_row
          (p_workbench_item_code         Varchar2
          ,p_workbench_item_name         Varchar2
          ,p_workbench_item_description  Varchar2
                                      );
Procedure load_setup_task_row
			  (p_setup_task_code                In     varchar2
			  ,p_workbench_item_code            in     varchar2
			  ,p_setup_task_name                In     Varchar2
			  ,p_setup_task_description         In     Varchar2
			  ,p_setup_task_sequence            in     number
			  ,p_setup_task_status              in     varchar2
			  ,p_setup_task_creation_date       in     date
			  ,p_setup_task_last_mod_date       in     date
			  ,p_setup_task_type                in     varchar2
			  ,p_setup_task_action              in     varchar2
			  ,p_effective_date                 in     date
			   );

Procedure translate_setup_task_row
          (p_setup_task_code                In     varchar2
          ,p_setup_task_name                In     Varchar2
          ,p_setup_task_description         In     Varchar2
			 );


Procedure load_setup_sub_task_row
		    (p_setup_sub_task_code                 In  Varchar2
			 ,p_setup_sub_task_name	           In  Varchar2
			 ,p_setup_sub_task_description	  In  Varchar2
			 ,p_setup_task_code                In  Varchar2
			 ,p_setup_sub_task_sequence        In  Number
			 ,p_setup_sub_task_status          In  Varchar2
			 ,p_setup_sub_task_type            In  Varchar2
			 ,p_setup_sub_task_dp_link         In  Varchar2
			 ,p_setup_sub_task_action          In  Varchar2
			 ,p_setup_sub_task_creation_date   In  Date
			 ,p_setup_sub_task_last_mod_date   In  Date
                         ,p_legislation_code               In  Varchar2
			 ,p_effective_date                 In  Date
			  );

Procedure translate_setup_sub_task_row
          (p_setup_sub_task_code                In     varchar2
          ,p_setup_sub_task_name                In     Varchar2
          ,p_setup_sub_task_description         In     Varchar2
          );


Procedure load_view_report_row
          (p_workbench_view_report_code     In Varchar2
          ,p_workbench_view_report_name     In Varchar2
          ,p_wb_view_report_description     In Varchar2
          ,p_workbench_item_code            In Varchar2
          ,p_workbench_view_report_type     In Varchar2
          ,p_workbench_view_report_action   In Varchar2
          ,p_workbench_view_country         In Varchar2
          ,p_wb_view_report_instruction     In Varchar2
          ,p_effective_date                 In  Date
	      ,p_primary_industry               In  Varchar2
          ,p_enabled_flag                   In Varchar2 default 'Y'
           );

Procedure translate_view_report_row
          (p_workbench_view_report_code     In Varchar2
          ,p_workbench_view_report_name     In Varchar2
          ,p_wb_view_report_description     In Varchar2
          );
Procedure load_workbench_item_dependency
          (p_workbench_item_code            In Varchar2
          ,p_dependent_item_code            In Varchar2
          ,p_dependency_item_sequence       In Number
          );

Procedure sync_dp_user_keys
          (p_setup_sub_task_code            In Varchar2
          ,p_business_group_id              In Number
          );
Procedure set_id_flex_num
          (p_setup_sub_task_code  In Varchar2
          ,p_business_group_id    In Number);
Procedure crp_insert_request
		  (p_setup_task_code In varchar2,
		   p_context_code In varchar2,
		   p_request_id In varchar2,
                   p_bg_id      In Number);

Function chk_dff_structure(p_flexfield_name In Varchar2
                          ,p_legislation_code In Varchar2
			  ,p_app_id In Varchar2
                          ) Return Varchar2;

end per_ri_workbench_pkg;

/
