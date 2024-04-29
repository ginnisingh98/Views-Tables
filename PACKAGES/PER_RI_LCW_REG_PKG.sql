--------------------------------------------------------
--  DDL for Package PER_RI_LCW_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_LCW_REG_PKG" AUTHID CURRENT_USER AS
/* $Header: perrilcw.pkh 120.0.12010000.2 2009/07/24 12:08:29 sbrahmad noship $ */
PROCEDURE per_ri_lcw_register
           (p_workbench_item_code            In  Varchar2
 	   ,p_setup_task_code            In  Varchar2
           ,p_setup_task_name            In  Varchar2
	   ,p_setup_task_seq		     In  Number
	   ,p_setup_sub_task_code            In  Varchar2
           ,p_setup_sub_task_name            In  Varchar2
           ,p_setup_sub_task_action          In  Varchar2
           ,p_legislation_code               In  Varchar2
	   ,p_sub_task_seq		     In  Number
	   ,p_object_version_number	     In Out nocopy Number
	   ,p_msg 			     Out  nocopy Varchar2

     );


PROCEDURE per_ri_lcw_delete (
			     p_workbench_item_code            In  Varchar2
           		     ,p_setup_task_code            In  Varchar2
	   	            ,p_setup_sub_task_code            In  Varchar2
	   	            ,p_object_version_number 	      In  Number
	   	            );

PROCEDURE create_lcw_oaf_function(
           p_function_name  IN  Varchar2
           ,p_user_function_name IN Varchar2
);

PROCEDURE delete_lcw_oaf_function(
           p_function_name IN Varchar2
);

END;


/
