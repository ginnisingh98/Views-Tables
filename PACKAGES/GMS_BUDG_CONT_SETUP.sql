--------------------------------------------------------
--  DDL for Package GMS_BUDG_CONT_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BUDG_CONT_SETUP" AUTHID CURRENT_USER AS
-- $Header: gmsbudcs.pls 120.2 2006/04/25 04:44:27 cmishra ship $

procedure insert_rec(x_project_id    		NUMBER
                    ,x_funds_control_code VARCHAR2
                    ,x_award_id			NUMBER
                    ,x_task_id			NUMBER
                    ,x_parent_member_id		NUMBER
                    ,x_resource_list_member_id	NUMBER);

procedure create_records (x_project_id  		NUMBER
                          ,x_award_id			NUMBER
			  ,x_entry_level_code 		VARCHAR2
			  ,x_resource_list_Id		NUMBER
                          ,x_group_resource_type_id	NUMBER
			  ,p_calling_mode     IN        VARCHAR2 DEFAULT 'BASELINE'
			  ,RETCODE 			OUT NOCOPY NUMBER
			  ,ERRBUF  			OUT NOCOPY VARCHAR2);

PROCEDURE bud_ctrl_create (p_project_id		     IN	   NUMBER
			   ,p_award_id		     IN	   NUMBER
			   ,p_prev_entry_level_code  IN    pa_budget_entry_methods.entry_level_code%type
			   ,p_entry_level_code       IN    pa_budget_entry_methods.entry_level_code%type
			   ,p_resource_list_id       IN    NUMBER
			   ,p_group_resource_type_id IN    NUMBER
                           ,x_err_code               OUT NOCOPY    NUMBER
                           ,x_err_stage              OUT NOCOPY    VARCHAR2);

END;

 

/
