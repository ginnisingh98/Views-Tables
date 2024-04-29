--------------------------------------------------------
--  DDL for Package PA_ADW_DIMENSION_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADW_DIMENSION_STATUS_PKG" AUTHID CURRENT_USER as
/*  $Header: PAADWDSS.pls 115.1 99/08/05 12:59:22 porting shi $ */
procedure INSERT_ROW (
 X_DIMENSION_CODE                 IN VARCHAR2,
 X_DIMENSION_NAME                  IN VARCHAR2,
 X_STATUS_CODE                     IN VARCHAR2,
 X_UPDATE_ALLOWED                  IN VARCHAR2,
 X_LAST_UPDATE_DATE                IN DATE,
 X_LAST_UPDATED_BY                 IN NUMBER,
 X_CREATION_DATE                   IN DATE,
 X_CREATED_BY                      IN NUMBER,
 X_LAST_UPDATE_LOGIN               IN  NUMBER);

procedure TRANSLATE_ROW (
  X_DIMENSION_CODE		IN VARCHAR2,
  X_DIMENSION_NAME		IN VARCHAR2,
  X_OWNER			IN VARCHAR2);

procedure UPDATE_ROW (
 X_DIMENSION_CODE                  IN VARCHAR2,
 X_DIMENSION_NAME                  IN VARCHAR2,
 X_STATUS_CODE                     IN VARCHAR2,
 X_UPDATE_ALLOWED                  IN VARCHAR2,
 X_LAST_UPDATE_DATE                IN DATE,
 X_LAST_UPDATED_BY                 IN NUMBER,
 X_LAST_UPDATE_LOGIN               IN  NUMBER);

end PA_ADW_DIMENSION_STATUS_PKG;

 

/
