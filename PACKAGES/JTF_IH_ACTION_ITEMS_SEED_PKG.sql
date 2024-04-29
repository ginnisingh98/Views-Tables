--------------------------------------------------------
--  DDL for Package JTF_IH_ACTION_ITEMS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_ACTION_ITEMS_SEED_PKG" AUTHID CURRENT_USER as
/* $Header: JTFIHAIS.pls 120.2 2005/07/08 07:52:51 nchouras ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ACTION_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_ITEM in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ACTIVE in VARCHAR2 DEFAULT NULL);
procedure LOCK_ROW (
  X_ACTION_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_ITEM in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_ACTION_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTION_ITEM in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ACTIVE in VARCHAR2 DEFAULT NULL
);
procedure DELETE_ROW (
  X_ACTION_ITEM_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW (
  X_ACTION_ITEM_ID in NUMBER,
  X_ACTION_ITEM in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_ACTIVE in VARCHAR2 DEFAULT NULL
);
procedure TRANSLATE_ROW (
  X_ACTION_ITEM_ID in NUMBER,
  X_ACTION_ITEM in VARCHAR2,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2
);

procedure LOAD_SEED_ROW (
  X_ACTION_ITEM_ID in NUMBER,
  X_ACTION_ITEM in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SHORT_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_ACTIVE in VARCHAR2 DEFAULT NULL,
  X_UPLOAD_MODE in VARCHAR2
);

end JTF_IH_ACTION_ITEMS_SEED_PKG;

 

/