--------------------------------------------------------
--  DDL for Package EAM_ENABLE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ENABLE_WF_PKG" AUTHID CURRENT_USER as
/* $Header: EAMVWFES.pls 120.0 2005/10/17 00:42:47 cboppana noship $ */

procedure LOAD_SEED_ROW(
	  x_upload_mode				in      varchar2,
	  x_custom_mode                 	in      varchar2,
          x_maintenance_object_source	in	number,
	  x_enable_workflow			in	varchar2,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

procedure LOAD_ROW(
	  x_custom_mode                 	in      varchar2,
          x_maintenance_object_source			in	number,
	  x_enable_workflow			in	varchar2,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

end EAM_ENABLE_WF_PKG;

 

/
