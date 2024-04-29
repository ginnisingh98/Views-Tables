--------------------------------------------------------
--  DDL for Package WIP_PREF_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PREF_DEF_PKG" AUTHID CURRENT_USER as
/* $Header: WIPPRFDS.pls 120.1 2005/06/24 17:10:06 asuherma noship $ */

procedure LOAD_SEED_ROW(
	  x_upload_mode				in      varchar2,
	  x_custom_mode                 	in      varchar2,
          x_preference_id			in	number,
	  x_preference_code			in	number,
          x_preference_type			in	number,
	  x_preference_source			in	varchar2,
	  x_preference_value_lookup_type	in	varchar2,
          x_module_id				in	number,
          x_usage_level				in	number,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

procedure LOAD_ROW(
          x_custom_mode                         in      varchar2,
          x_preference_id                       in      number,
          x_preference_code                     in      number,
          x_preference_type                     in      number,
          x_preference_source                   in      varchar2,
          x_preference_value_lookup_type        in      varchar2,
          x_module_id                           in      number,
          x_usage_level                           in      number,
          x_owner                               in      varchar2,
          x_last_update_date                    in      varchar2);

end WIP_PREF_DEF_PKG;

 

/
