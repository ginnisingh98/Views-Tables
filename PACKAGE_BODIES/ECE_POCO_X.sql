--------------------------------------------------------
--  DDL for Package Body ECE_POCO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_POCO_X" AS
-- $Header: ECPOCOXB.pls 115.3 2003/11/03 12:26:38 arsriniv ship $

/* -----------------------------------------------------------------------
REM
REM	PROCEDURE POPULATE_EXT_HEADER
REM		This procedure can be modified by the user to utilize the EDI
REM		Extension Tables
REM
REM ------------------------------------------------------------------------
*/
   PROCEDURE populate_ext_header(
      l_fkey      IN NUMBER,
      l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type) IS

      BEGIN

         NULL;

      END populate_ext_header;

/* -----------------------------------------------------------------------
REM
REM	PROCEDURE POPULATE_EXT_LINE
REM		This procedure can be modified by the user to utilize the EDI
REM		Extension Tables
REM
REM ------------------------------------------------------------------------
*/
   PROCEDURE populate_ext_line(
      l_fkey      IN NUMBER,
      l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type) IS

      BEGIN

         NULL;

      END populate_ext_line;

/* -----------------------------------------------------------------------
REM
REM	PROCEDURE POPULATE_EXT_SHIPMENT
REM		This procedure can be modified by the user to utilize the EDI
REM		Extension Tables
REM
REM ------------------------------------------------------------------------
*/
   PROCEDURE populate_ext_shipment(
      l_fkey      IN NUMBER,
      l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type) IS

      BEGIN

         NULL;

      END populate_ext_shipment;

/* -----------------------------------------------------------------------
REM
REM	PROCEDURE POPULATE_EXT_PROJECT
REM		This procedure can be modified by the user to utilize the EDI
REM		Extension Tables
REM
REM ------------------------------------------------------------------------
*/
   PROCEDURE populate_ext_project(
      l_fkey      IN NUMBER,
      l_plsql_tbl IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type) IS

      BEGIN

         NULL;

      END populate_ext_project;

END ece_poco_x;


/
