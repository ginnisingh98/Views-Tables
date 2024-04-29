--------------------------------------------------------
--  DDL for Package EDW_APPS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_APPS_INT" AUTHID CURRENT_USER AS
/*$Header: EDWAPPSS.pls 115.2 2002/12/05 01:12:13 arsantha ship $*/

PROCEDURE registerSourceViews
(p_flex_view_name 	IN VARCHAR2,
p_generated_view_name 	IN VARCHAR2,
p_collection_view_name 	IN VARCHAR2,
p_Interface_table_name 	IN VARCHAR2,
p_object_name		IN VARCHAR2,
p_level_name		IN VARCHAR2,
p_version		IN VARCHAR2);

PROCEDURE removeSourceViews
(p_object_name		IN VARCHAR2,
 p_version		IN VARCHAR2);

PROCEDURE registerFlexAssignments
( p_object_name			IN VARCHAR2,
p_flex_view_name		IN VARCHAR2,
p_flex_field_code		IN VARCHAR2,
p_flex_field_prefix		IN VARCHAR2,
p_application_id		IN NUMBER,
p_application_short_name	IN VARCHAR2,
p_flex_field_type		IN VARCHAR2,
p_flex_field_name		IN VARCHAR2,
p_version			IN VARCHAR2);

PROCEDURE removeFlexAssignments
( p_object_name			IN VARCHAR2,
  p_version			IN VARCHAR2);

END EDW_APPS_INT;

 

/
