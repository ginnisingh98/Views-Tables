--------------------------------------------------------
--  DDL for Package RRS_SITE_GROUP_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_SITE_GROUP_NODES_PKG" AUTHID CURRENT_USER as
/* $Header: RRSSGNPS.pls 120.0 2005/09/29 21:10 swbhatna noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SITE_GROUP_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_SITE_GROUP_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_SITE_GROUP_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_SITE_GROUP_NODE_ID in NUMBER
);
procedure ADD_LANGUAGE;

end RRS_SITE_GROUP_NODES_PKG;

/