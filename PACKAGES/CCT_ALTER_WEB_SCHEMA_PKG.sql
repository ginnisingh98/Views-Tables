--------------------------------------------------------
--  DDL for Package CCT_ALTER_WEB_SCHEMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_ALTER_WEB_SCHEMA_PKG" AUTHID CURRENT_USER AS
/* $Header: cctupaws.pls 120.0 2005/06/02 10:06:40 appldev noship $ */
   PROCEDURE modify_column_delault (schema_name IN VARCHAR2,
		 table_name IN VARCHAR2, col_name IN VARCHAR2);


   PROCEDURE update_null_object_versions;

   PROCEDURE update_route_param_operator(schema_name IN VARCHAR2);

END cct_alter_web_schema_pkg;

 

/
