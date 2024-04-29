--------------------------------------------------------
--  DDL for Package PA_STATUS_COLUMN_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUS_COLUMN_SETUP_PKG" AUTHID CURRENT_USER as
/* $Header: PAREPSCS.pls 120.4 2005/08/19 16:50:33 mwasowic ship $ */
-- g_insertflag is used to indicate whether the system should upload data into
--   the PA_STATUS_COLUMN_SETUP table. Upload is yes when g_insertflag is true
--   and no if g_insertflag is false.
g_insertflag    BOOLEAN := NULL;
procedure INSERT_ROW (
  X_FOLDER_CODE 	     in	VARCHAR2,
  X_COLUMN_ORDER	     in NUMBER,
  X_FORMAT_CODE              in VARCHAR2,
  X_COLUMN_NAME     	     in VARCHAR2,
  X_CURRENCY_FORMAT_FLAG     in	VARCHAR2,
  X_TOTAL_FLAG               in VARCHAR2,
  X_COLUMN_PROMPT     	     in VARCHAR2,
  X_CREATION_DATE            in DATE,
  X_CREATED_BY               in NUMBER,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER);
procedure TRANSLATE_ROW (
  X_FOLDER_CODE            in VARCHAR2,
  X_COLUMN_ORDER           in NUMBER,
  X_FORMAT_CODE            in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_COLUMN_PROMPT          in VARCHAR2);
procedure GET_INSERT_STATUS (
  X_INSERTFLAG   out NOCOPY BOOLEAN --File.Sql.39 bug 4440895
);
end PA_STATUS_COLUMN_SETUP_PKG;

 

/
