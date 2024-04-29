--------------------------------------------------------
--  DDL for Package BOM_DELETION_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DELETION_CONSTRAINTS_PKG" AUTHID CURRENT_USER as
/* $Header: bompcons.pls 115.1 99/07/16 05:47:48 porting ship $ */

  PROCEDURE Check_Unique(X_Sql_Statement_Name VARCHAR2);

END BOM_DELETION_CONSTRAINTS_PKG;

 

/
