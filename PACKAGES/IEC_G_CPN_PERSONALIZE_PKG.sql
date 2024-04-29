--------------------------------------------------------
--  DDL for Package IEC_G_CPN_PERSONALIZE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_G_CPN_PERSONALIZE_PKG" AUTHID CURRENT_USER as
/* $Header: IECCPS.pls 120.1 2005/06/17 12:06:09 appldev  $ */

procedure INSERT_ROW ( -- what determines the order of params?
  X_ROWID out nocopy VARCHAR2,
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
);

procedure UPDATE_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER
);

procedure TRANSLATE_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  P_OWNER IN VARCHAR2
);

procedure LOAD_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OWNER_REF in VARCHAR2
);


procedure LOAD_SEED_ROW (
  X_UPLOAD_MODE in VARCHAR2,
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OWNER_REF in VARCHAR2
);

procedure ADD_LANGUAGE;

end IEC_G_CPN_PERSONALIZE_PKG;

 

/