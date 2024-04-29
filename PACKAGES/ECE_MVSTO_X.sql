--------------------------------------------------------
--  DDL for Package ECE_MVSTO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_MVSTO_X" AUTHID CURRENT_USER AS
-- $Header: ECMVSOXS.pls 115.1 99/07/17 05:22:58 porting shi $

PROCEDURE POPULATE_EXT_HEADER(l_fkey      IN NUMBER,
			l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);

PROCEDURE POPULATE_EXT_LINE(l_fkey      IN NUMBER,
			l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);

PROCEDURE POPULATE_EXT_LOCATION(l_fkey      IN NUMBER,
			l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);
end ECE_MVSTO_X;


 

/
