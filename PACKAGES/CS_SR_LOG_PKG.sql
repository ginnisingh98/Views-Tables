--------------------------------------------------------
--  DDL for Package CS_SR_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: csvsrlgs.pls 115.0 2000/02/29 19:47:44 pkm ship      $ */
-- Start of Comments
-- Package name     : CS_SR_LOG_PKG
-- Purpose          : package has a function that outputs the log
--                    for the fulfillment report
-- History          :
-- NOTE             :
-- End of Comments

--create or replace PACKAGE  CS_DIARY_PKG IS
  FUNCTION SR_LOG (p_incident_id varchar2,
		  p_public_notes_only varchar2 DEFAULT 'Y',
		  p_order_by varchar2 DEFAULT 'Y')
		  Return varchar2 ;

  PROCEDURE audit_display(x_source_type varchar2,
                        x_last_update_date date,
                        x_owner        varchar2,
                        x_severity_old varchar2,
			         x_severity_new varchar2,
			         x_type_old     varchar2,
			         x_type_new     varchar2,
			         x_status_old   varchar2,
                   	    x_status_new   varchar2,
                   	    x_urgency_old  varchar2,
                        x_urgency_new  varchar2,
                  	    x_group_old    varchar2,
                   	    x_group_new    varchar2,
                   	    x_owner_old    varchar2,
                   	    x_owner_new    varchar2,
                   	    x_date_old     varchar2,
                   	    x_date_new     varchar2,
							    x_obligation_date_new   varchar2 ,
	    						x_obligation_date_old  varchar2 ,
	    						x_site_id_new   varchar2 ,
	    						x_site_id_old  varchar2 ,
	    						x_old_bill_to_contact_name  varchar2 ,
	    						x_new_bill_to_contact_name  varchar2 ,
	    						x_old_ship_to_contact_name  varchar2 ,
	    						x_new_ship_to_contact_name  varchar2 ,
	    						x_old_platform_name   varchar2 ,
	    						x_new_platform_name  varchar2 ,
	    						x_old_platform_version_name   varchar2 ,
	    						x_new_platform_version_name   varchar2 ,
	    						x_old_description   varchar2 ,
	    						x_new_description  varchar2 ,
	    						x_old_language   varchar2 ,
	    						x_new_language  varchar2 ,
			         x_details OUT VARCHAR2) ;

PROCEDURE TASK_NOTES ( x_task_id NUMBER,
                       x_details OUT VARCHAR2);

  gs_newline varchar2(1) := substr('

',1,1);

END;

 

/
