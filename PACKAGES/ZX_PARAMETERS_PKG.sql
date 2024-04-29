--------------------------------------------------------
--  DDL for Package ZX_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: zxiparameters.pls 120.2 2005/10/05 22:10:55 vsidhart ship $ */
procedure INSERT_ROW (
  X_TAX_PARAMETER_CODE in VARCHAR2,
  X_TAX_PARAMETER_TYPE in VARCHAR2,
  X_FORMAT_TYPE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GENERATE_GET_FLAG in VARCHAR2,
  X_ALLOW_OVERRIDE in VARCHAR2,
  X_TAX_PARAMETER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure TRANSLATE_ROW
( X_TAX_PARAMETER_CODE in VARCHAR2,
  X_OWNER              in VARCHAR2,
  X_TAX_PARAMETER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE   in VARCHAR2,
  X_CUSTOM_MODE        in VARCHAR2) ;


PROCEDURE LOAD_ROW
( X_TAX_PARAMETER_CODE in VARCHAR2,
  X_OWNER              in VARCHAR2,
  X_TAX_PARAMETER_TYPE in VARCHAR2,
  X_FORMAT_TYPE        in VARCHAR2,
  X_MAX_SIZE           in VARCHAR2,
  X_ENABLED_FLAG       in VARCHAR2,
  X_GENERATE_GET_FLAG  in VARCHAR2,
  X_TAX_PARAMETER_NAME in VARCHAR2,
  X_ALLOW_OVERRIDE     in VARCHAR2,
  X_LAST_UPDATE_DATE   in VARCHAR2,
  X_CUSTOM_MODE        in VARCHAR2) ;


PROCEDURE add_language;

end ZX_PARAMETERS_PKG;


 

/