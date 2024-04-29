--------------------------------------------------------
--  DDL for Package XDO_CURRENCY_FORMAT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_CURRENCY_FORMAT_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: XDOCURFS.pls 120.1 2005/12/27 12:09:26 bgkim noship $ */

procedure INSERT_ROW (
          P_FORMAT_SET_CODE in VARCHAR2,
          P_FORMAT_SET_NAME in VARCHAR2,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          P_FORMAT_SET_CODE in VARCHAR2,
          P_FORMAT_SET_NAME in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure ADD_LANGUAGE;

end XDO_CURRENCY_FORMAT_SETS_PKG;

 

/
