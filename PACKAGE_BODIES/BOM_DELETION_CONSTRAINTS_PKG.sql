--------------------------------------------------------
--  DDL for Package Body BOM_DELETION_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DELETION_CONSTRAINTS_PKG" as
/* $Header: bompconb.pls 120.2 2005/07/18 03:06:43 bbpatel noship $ */

  PROCEDURE Check_Unique(X_Sql_Statement_Name VARCHAR2) IS
    DUMMY NUMBER;
  BEGIN
    SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
      (SELECT 1 FROM BOM_DELETE_SQL_STATEMENTS
       WHERE SQL_STATEMENT_NAME = X_Sql_Statement_Name
       );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('BOM', 'BOM_DEL_CON_STMT_ALREADY_EXIST'); --bug:4495612 Changed the error message
        FND_MESSAGE.SET_TOKEN('NAME', X_Sql_Statement_Name, FALSE);
        APP_EXCEPTION.RAISE_EXCEPTION;
  END Check_Unique;

END BOM_DELETION_CONSTRAINTS_PKG;

/
