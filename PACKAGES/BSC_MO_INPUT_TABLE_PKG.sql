--------------------------------------------------------
--  DDL for Package BSC_MO_INPUT_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_INPUT_TABLE_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMOIPS.pls 120.0 2005/06/01 16:10:44 appldev noship $ */
PROCEDURE InputTables;
Function getMaxTableIndex(startsWith IN VARCHAR2) return NUMBER ;
PROCEDURE Load_b_t_Tables_From_DB ;
TYPE CurTyp IS REF CURSOR;
g_unique VARCHAR2(20) := 'UNIQUE_COLS';
g_target VARCHAR2(20) := 'UNIQUE_COLS_TGT';


END BSC_MO_INPUT_TABLE_PKG ;

 

/
