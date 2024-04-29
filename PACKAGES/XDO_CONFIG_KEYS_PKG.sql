--------------------------------------------------------
--  DDL for Package XDO_CONFIG_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_CONFIG_KEYS_PKG" AUTHID CURRENT_USER as
/* $Header: XDOCFGKS.pls 120.0 2005/09/01 20:26:13 bokim noship $ */

procedure INSERT_ROW (
          P_VALUE_ID in NUMBER,
          P_VALUE_KEY in RAW,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
          P_VALUE_ID in NUMBER,
          P_VALUE_KEY in RAW,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
          P_VALUE_ID in NUMBER
);

procedure LOAD_ROW (
          P_VALUE_ID in NUMBER,
          P_VALUE_KEY in RAW,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
);

end XDO_CONFIG_KEYS_PKG;

 

/
