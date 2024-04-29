--------------------------------------------------------
--  DDL for Package FLM_SEQ_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_SEQ_ATTRIBUTES_PKG" AUTHID CURRENT_USER as
/* $Header: FLMSQATS.pls 120.0 2005/06/08 15:51:33 asuherma noship $ */

procedure LOAD_SEED_ROW(
	  x_upload_mode			in      varchar2,
	  x_custom_mode                 in      varchar2,
          x_attribute_id		in	number,
	  x_attribute_name		in	varchar2,
	  x_description			in	varchar2,
	  x_user_defined_flag		in	varchar2,
          x_attribute_type		in	number,
          x_attribute_source		in	varchar2,
          x_attribute_value_type	in	number,
	  x_owner			in	varchar2,
	  x_last_update_date            in      varchar2);

procedure TRANSLATE_ROW(
          x_custom_mode                 in      varchar2,
          x_attribute_id                in      number,
          x_description                 in      varchar2,
          x_owner                       in      varchar2,
          x_last_update_date            in      varchar2);


procedure LOAD_ROW(
	  x_custom_mode                 in      varchar2,
          x_attribute_id		in	number,
	  x_attribute_name		in	varchar2,
	  x_description			in	varchar2,
	  x_user_defined_flag		in	varchar2,
          x_attribute_type		in	number,
          x_attribute_source		in	varchar2,
          x_attribute_value_type	in	number,
	  x_owner			in	varchar2,
	  x_last_update_date            in      varchar2);

end FLM_SEQ_ATTRIBUTES_PKG;

 

/
