--------------------------------------------------------
--  DDL for Package EDW_UPDATE_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_UPDATE_ATTRIBUTES" AUTHID CURRENT_USER AS
/* $Header: EDWVCONS.pls 120.0 2005/05/31 18:14:47 appldev noship $ */

g_file  utl_file.file_type;

/*FUNCTION convert_table_validated_ids
(p_object_name IN VARCHAR2,
p_log IN boolean default true,
p_logfile_dir IN VARCHAR2 default null) return BOOLEAN;
*/

FUNCTION update_stg(p_object_name IN VARCHAR2,
			p_start_mode IN VARCHAR2 default 'SQL',
			p_logfile_dir IN VARCHAR2 default null) return BOOLEAN;

Function getAppsVersion(p_instance IN VARCHAR2) return VARCHAR2 ;
--FUNCTION add_db_links_to_string(p_table IN VARCHAR2, p_link IN VARCHAR2) return VARCHAR2 ;
--FUNCTION get_ignorable_attributes(p_object_name IN VARCHAR2, p_level_name IN VARCHAR2) RETURN VARCHAR2;

flex_variables_exception EXCEPTION;
END EDW_UPDATE_ATTRIBUTES;

 

/
