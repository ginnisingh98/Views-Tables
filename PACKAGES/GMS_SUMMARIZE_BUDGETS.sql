--------------------------------------------------------
--  DDL for Package GMS_SUMMARIZE_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_SUMMARIZE_BUDGETS" AUTHID CURRENT_USER AS
-- $Header: gmsbusus.pls 120.1 2007/02/06 09:49:15 rshaik ship $

G_multi_funding VARCHAR2(1) ;
G_pa_res_list_id NUMBER ;
G_project_bem  VARCHAR2(1000);
G_PA_RES_LIST_ID_NONE NUMBER ;

PROCEDURE summarize_baselined_versions (x_project_id  		NUMBER
				        ,x_time_phased_type_code VARCHAR2
					,x_app_short_name 	OUT NOCOPY VARCHAR2
					,RETCODE 		OUT NOCOPY VARCHAR2
					,ERRBUF  		OUT NOCOPY VARCHAR2);

END;

/
