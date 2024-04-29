--------------------------------------------------------
--  DDL for Package BSC_MO_LOADER_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_LOADER_CONFIG_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMOCFS.pls 120.0 2005/06/01 16:37:37 appldev noship $ */
TYPE CurTyp IS REF CURSOR;

PROCEDURE ConfigureActualization;
PROCEDURE ReConfigureUploadFieldsIndic(Indic IN NUMBER) ;
PROCEDURE ReCreateMaterializedViewsIndic(Indic in number) ;
PROCEDURE Corrections;

PROCEDURE InsertOriginTables(arrTables IN DBMS_SQL.VARCHAR2_TABLE ,
                            arrOriginTables IN OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE ) ;

Function isBasicTable(p_table_name IN VARCHAR2) RETURN Boolean ;
END BSC_MO_LOADER_CONFIG_PKG;

 

/
