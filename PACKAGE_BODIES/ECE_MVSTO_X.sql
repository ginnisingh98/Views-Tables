--------------------------------------------------------
--  DDL for Package Body ECE_MVSTO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_MVSTO_X" AS
-- $Header: ECMVSOXB.pls 115.1 99/07/17 05:22:53 porting shi $

/* -----------------------------------------------------------------------
REM
REM	PROCEDURE POPULATE_EXT_HEADER
REM		This procedure can be modified by the user to utilize the EDI
REM		Extension Tables
REM
REM ------------------------------------------------------------------------
*/
PROCEDURE POPULATE_EXT_HEADER(l_fkey     IN NUMBER,
                              l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type)
IS
BEGIN

null;

END POPULATE_EXT_HEADER;

/* -----------------------------------------------------------------------
REM
REM	PROCEDURE POPULATE_EXT_LINE
REM		This procedure can be modified by the user to utilize the EDI
REM		Extension Tables
REM
REM ------------------------------------------------------------------------
*/

PROCEDURE POPULATE_EXT_LINE(l_fkey     IN NUMBER,
                              l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type)
IS
BEGIN

null;

END POPULATE_EXT_LINE;

/* -----------------------------------------------------------------------
REM
REM     PROCEDURE POPULATE_EXT_LOCATION
REM             This procedure can be modified by the user to utilize the EDI
REM             Extension Tables
REM
REM ------------------------------------------------------------------------
*/

PROCEDURE POPULATE_EXT_LOCATION(l_fkey     IN NUMBER,
                              l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type)
IS
BEGIN

null;

END POPULATE_EXT_LOCATION;

END ECE_MVSTO_X;

/
