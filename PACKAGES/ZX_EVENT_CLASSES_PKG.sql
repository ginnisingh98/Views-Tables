--------------------------------------------------------
--  DDL for Package ZX_EVENT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_EVENT_CLASSES_PKG" AUTHID CURRENT_USER as
/* $Header: zxievents.pls 120.5 2006/10/27 17:12:33 appradha ship $ */

procedure INSERT_ROW (
  X_TAX_EVENT_CLASS_CODE    in VARCHAR2,
  X_NORMAL_SIGN_FLAG        in VARCHAR2,
  X_INTRCMP_TX_CLS_CODE     IN VARCHAR2,
  X_CREATION_DATE           in DATE,
  X_CREATED_BY              in NUMBER,
  X_LAST_UPDATE_DATE        in DATE,
  X_LAST_UPDATED_BY         in NUMBER,
  X_LAST_UPDATE_LOGIN       in NUMBER,
  X_TAX_EVENT_CLASS_NAME    in VARCHAR2);


procedure TRANSLATE_ROW
( X_OWNER                   in VARCHAR2,
  X_TAX_EVENT_CLASS_CODE    in VARCHAR2,
  X_TAX_EVENT_CLASS_NAME    in VARCHAR2,
  X_LAST_UPDATE_DATE        in VARCHAR2,
  X_CUSTOM_MODE             in VARCHAR2 );


PROCEDURE LOAD_ROW
 (X_OWNER                   in VARCHAR2 ,
  X_TAX_EVENT_CLASS_CODE    in VARCHAR2,
  X_NORMAL_SIGN_FLAG        in VARCHAR2,
  X_INTRCMP_TX_CLS_CODE     IN VARCHAR2,
  X_LAST_UPDATE_DATE        in VARCHAR2,
  X_TAX_EVENT_CLASS_NAME    in VARCHAR2,
  X_CUSTOM_MODE             in VARCHAR2);

PROCEDURE add_language;

end ZX_EVENT_CLASSES_PKG;


 

/
