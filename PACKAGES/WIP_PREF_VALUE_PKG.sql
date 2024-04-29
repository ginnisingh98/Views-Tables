--------------------------------------------------------
--  DDL for Package WIP_PREF_VALUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PREF_VALUE_PKG" AUTHID CURRENT_USER as
/* $Header: WIPPRFVS.pls 120.0 2005/06/20 18:05:58 asuherma noship $ */

procedure LOAD_SEED_ROW(
	  x_upload_mode				in      varchar2,
	  x_custom_mode                 	in      varchar2,
          x_preference_value_id			in	number,
	  x_preference_id			in	number,
          x_level_id				in	number,
          x_sequence_number			in	number,
          x_attribute_name			in	varchar2,
          x_attribute_value_code		in	varchar2,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

procedure LOAD_ROW(
	  x_custom_mode                 	in      varchar2,
          x_preference_value_id			in	number,
	  x_preference_id			in	number,
          x_level_id				in	number,
          x_sequence_number			in	number,
          x_attribute_name			in	varchar2,
          x_attribute_value_code		in	varchar2,
	  x_owner				in	varchar2,
	  x_last_update_date            	in      varchar2);

end WIP_PREF_VALUE_PKG;

 

/
