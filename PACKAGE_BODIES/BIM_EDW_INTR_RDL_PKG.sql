--------------------------------------------------------
--  DDL for Package Body BIM_EDW_INTR_RDL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_EDW_INTR_RDL_PKG" AS
/*$Header: bimdrdib.pls 120.0 2005/05/31 13:17:37 appldev noship $*/

L_SYSDATE            DATE   ;
L_EXCEPTION_MSG      VARCHAR2(2000) := NULL;

L_NUM_ROWS_INSERTED  INTEGER         := 0;
L_DURATION           NUMBER          := 0;
L_BIM_SCHEMA         VARCHAR2(30);
L_STATUS             VARCHAR2(30);
L_INDUSTRY           VARCHAR2(30);

PROCEDURE POPULATE(
		  ERRBUF       OUT NOCOPY VARCHAR2
		, RETCODE      OUT NOCOPY VARCHAR2
            )  IS
BEGIN

NULL;

END POPULATE;


PROCEDURE POPULATE_INTRCTNS IS
BEGIN

NULL;

END POPULATE_INTRCTNS;


PROCEDURE UPDATE_TEMP_TABLE IS
BEGIN

NULL;

END UPDATE_TEMP_TABLE;

PROCEDURE POPULATE_INSTEAD_OF_VIEW IS
BEGIN

NULL;

END POPULATE_INSTEAD_OF_VIEW;

FUNCTION SETUP RETURN BOOLEAN IS
  l_dir     VARCHAR2(400);
BEGIN

NULL;

END SETUP;

PROCEDURE WRAPUP (
             P_SUCCESSFUL         BOOLEAN
          ,  P_ROWS_PROCESSED     NUMBER := 0
          ,  P_EXCEPTION_MSG      VARCHAR2 := NULL ) IS
BEGIN

NULL;

END WRAPUP;

END BIM_EDW_INTR_RDL_PKG;

/
