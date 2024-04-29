--------------------------------------------------------
--  DDL for Package EC_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_XML_UTILS" AUTHID CURRENT_USER AS
-- $Header: ECXMLUTS.pls 115.2 99/08/19 16:09:44 porting ship $

PROCEDURE create_toplevel_vo
	(
	i_singular_name		IN	varchar2,
	i_plural_name		IN	varchar2,
	i_entity_object		IN	varchar2,
	i_select_clause		IN	varchar2,
	i_from_clause		IN	varchar2,
	i_where_clause		IN	varchar2,
	i_orderby_clause	IN	varchar2,
	i_attributes_to_hide	IN	varchar2,
	i_product_code		OUT	varchar2,
	i_apps_error_code	OUT	varchar2,
	i_parameter0		OUT	varchar2,
	i_parameter1		OUT	varchar2,
	i_parameter2		OUT	varchar2,
	i_parameter3		OUT	varchar2,
	i_parameter4		OUT	varchar2,
	i_error_string		OUT	varchar2
	);

PROCEDURE create_child_vo
	(
	i_singular_name			IN	varchar2,
	i_plural_name			IN	varchar2,
	i_entity_object			IN	varchar2,
	i_select_clause			IN	varchar2,
	i_from_clause			IN	varchar2,
	i_where_clause			IN	varchar2,
	i_orderby_clause		IN	varchar2,
	i_attributes_to_hide		IN	varchar2,
	i_parent_data_object		IN	varchar2,
	i_bind_parent_attributealiases	IN	varchar2,
	i_bind_child_attributealiases	IN	varchar2,
	i_bind_child_attributecolumns	IN	varchar2,
	i_product_code			OUT	varchar2,
	i_apps_error_code		OUT	varchar2,
	i_parameter0			OUT	varchar2,
	i_parameter1			OUT	varchar2,
	i_parameter2			OUT	varchar2,
	i_parameter3			OUT	varchar2,
	i_parameter4			OUT	varchar2,
	i_error_string			OUT	varchar2
	);

PROCEDURE produce_xml
	(
	i_file_name		IN	varchar2,
	i_product_code		OUT	varchar2,
	i_apps_error_code	OUT	varchar2,
	i_parameter0		OUT	varchar2,
	i_parameter1		OUT	varchar2,
	i_parameter2		OUT	varchar2,
	i_parameter3		OUT	varchar2,
	i_parameter4		OUT	varchar2,
	i_error_string		OUT	varchar2
	);

PROCEDURE consume_xml
	(
	i_file_name		IN	varchar2,
	i_apps_error_code	OUT	varchar2,
	i_parameter0		OUT	varchar2,
	i_parameter1		OUT	varchar2,
	i_parameter2		OUT	varchar2,
	i_parameter3		OUT	varchar2,
	i_parameter4		OUT	varchar2,
	i_error_string		OUT	varchar2,
	i_viewolistner_class	IN	varchar2
	);


PROCEDURE create_vo_tree
	(
	i_map_id		IN	number,
	i_run_id		IN	number
	);

PROCEDURE ec_xml_processor_out_generic
	(
      	c_map_id 		IN 	PLS_INTEGER,
      	c_run_id 		IN 	PLS_INTEGER,
      	c_output_path 		IN 	VARCHAR2,
      	c_file_name 		IN 	VARCHAR2
	);


PROCEDURE ec_xml_processor_in_generic
	(
      	c_map_id 		IN 	PLS_INTEGER,
      	c_run_id 		OUT 	PLS_INTEGER,
      	c_output_path 		IN 	VARCHAR2,
      	c_file_name 		IN 	VARCHAR2
	);

END EC_XML_UTILS;


 

/
