--------------------------------------------------------
--  DDL for Package WIP_PREF_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PREF_LEVEL_PKG" AUTHID CURRENT_USER as
/* $Header: WIPPRFLS.pls 120.0 2005/06/20 18:04:37 asuherma noship $ */

procedure LOAD_SEED_ROW(
	  x_upload_mode				in      varchar2,
	  x_custom_mode                 	in      varchar2,
          x_level_id				in	number,
	  x_level_code				in	number,
          x_resp_key				in	varchar2,
	  x_organization_id			in	number,
	  x_department_id			in	number,
          x_module_id				in	number,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

procedure LOAD_ROW(
	  x_custom_mode                 	in      varchar2,
          x_level_id				in	number,
	  x_level_code				in	number,
          x_resp_key				in	varchar2,
	  x_organization_id			in	number,
	  x_department_id			in	number,
          x_module_id				in	number,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

end WIP_PREF_LEVEL_PKG;

 

/
