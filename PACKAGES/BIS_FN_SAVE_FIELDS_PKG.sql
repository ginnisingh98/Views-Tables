--------------------------------------------------------
--  DDL for Package BIS_FN_SAVE_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FN_SAVE_FIELDS_PKG" AUTHID CURRENT_USER as
/* $Header: BISVSFNS.pls 115.0 1999/11/19 16:10:27 pkm ship    $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |    BISVSFNS.pls
REM |
REM | DESCRIPTION                                                           |
REM |     PL/SQL spec for package:  BIS_FN_SAVE_FIELDS_PKG
REM |
REM +=======================================================================+
*/
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2,
  X_ATTRIBUTE_CODE in VARCHAR2
);
procedure UPDATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_FIELD in VARCHAR2
);
END BIS_FN_SAVE_FIELDS_PKG;

 

/
