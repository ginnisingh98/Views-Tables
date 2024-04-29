--------------------------------------------------------
--  DDL for Package GMS_OVERRIDE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_OVERRIDE_SCHEDULES_PKG" AUTHID CURRENT_USER as
/* $Header: gmsicovs.pls 120.1 2005/07/26 14:22:30 appldev ship $ */

PROCEDURE Insert_Row(p_rowid          		IN OUT NOCOPY		VARCHAR2,
		     p_award_id       		IN		NUMBER,
		     p_project_id 		IN		NUMBER,
                     p_task_id    		IN		NUMBER,
                     p_idc_schedule_id  	IN		NUMBER,
                     p_cost_ind_sch_fixed_date 	IN  		DATE,
 		     p_mode 			IN		VARCHAR2 default 'R');

PROCEDURE Update_Row(p_rowid          		IN 		VARCHAR2,
		     p_project_id 		IN		NUMBER,
		     p_task_id    		IN		NUMBER,
		     p_idc_schedule_id   	IN		NUMBER,
	  	     p_cost_ind_sch_fixed_date 	IN  		DATE,
		     p_mode			IN 		VARCHAR2 default 'R');

PROCEDURE Delete_Row(p_rowid             	IN 		VARCHAR2);

PROCEDURE Lock_Row(p_rowid          		IN 		VARCHAR2,
		   p_award_id       		IN		NUMBER,
		   p_project_id 		IN		NUMBER,
		   p_task_id    		IN		NUMBER,
		   p_idc_schedule_id   		IN		NUMBER,
		   p_cost_ind_sch_fixed_date   	IN  		DATE);


END GMS_OVERRIDE_SCHEDULES_PKG;

 

/
