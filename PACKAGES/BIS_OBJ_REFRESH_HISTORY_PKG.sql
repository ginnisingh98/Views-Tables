--------------------------------------------------------
--  DDL for Package BIS_OBJ_REFRESH_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_OBJ_REFRESH_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: BISOBTHS.pls 120.0 2005/05/31 18:29 appldev noship $*/

PROCEDURE Insert_Row (  p_Prog_request_id                NUMBER ,
			p_Object_type                   VARCHAR2,
			p_Object_name                   VARCHAR2,
			p_Refresh_type			VARCHAR2,
			p_Object_row_count               NUMBER,
			p_Object_space_usage            NUMBER ,
			p_Tablespace_name               VARCHAR2,
			p_Free_tablespace_size          VARCHAR2,
			p_Creation_date                  DATE,
			p_Created_by                     NUMBER,
			p_Last_update_date               DATE,
			p_Last_updated_by                NUMBER
                      );

FUNCTION Update_Row (  p_Prog_request_id                NUMBER ,
			p_new_Prog_request_id                NUMBER DEFAULT NULL,
			p_Object_type                   VARCHAR2 DEFAULT NULL,
			p_Object_name                   VARCHAR2 DEFAULT NULL,
			p_Refresh_type			VARCHAR2 DEFAULT NULL,
			p_Object_row_count               NUMBER DEFAULT NULL,
			p_Object_space_usage            NUMBER DEFAULT NULL ,
			p_Tablespace_name               VARCHAR2 DEFAULT NULL,
			p_Free_tablespace_size          VARCHAR2 DEFAULT NULL,
			p_Last_update_date               DATE,
			p_Last_updated_by                NUMBER) RETURN BOOLEAN;

PROCEDURE Delete_Row (p_prog_req_id number);

END BIS_OBJ_REFRESH_HISTORY_PKG;

 

/
