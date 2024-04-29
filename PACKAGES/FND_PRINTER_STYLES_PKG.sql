--------------------------------------------------------
--  DDL for Package FND_PRINTER_STYLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PRINTER_STYLES_PKG" AUTHID CURRENT_USER as
/* $Header: AFPRRPSS.pls 120.2 2005/08/19 20:17:38 ckclark ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PRINTER_STYLE_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_WIDTH in NUMBER,
  X_LENGTH in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_SRW_DRIVER in VARCHAR2,
  X_HEADER_FLAG in VARCHAR2,
  X_USER_PRINTER_STYLE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_PRINTER_STYLE_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_WIDTH in NUMBER,
  X_LENGTH in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_SRW_DRIVER in VARCHAR2,
  X_HEADER_FLAG in VARCHAR2,
  X_USER_PRINTER_STYLE_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_PRINTER_STYLE_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_WIDTH in NUMBER,
  X_LENGTH in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ORIENTATION in VARCHAR2,
  X_SRW_DRIVER in VARCHAR2,
  X_HEADER_FLAG in VARCHAR2,
  X_USER_PRINTER_STYLE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PRINTER_STYLE_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;
end FND_PRINTER_STYLES_PKG;

 

/