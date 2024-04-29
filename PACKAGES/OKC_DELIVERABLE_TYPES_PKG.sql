--------------------------------------------------------
--  DDL for Package OKC_DELIVERABLE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DELIVERABLE_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: OKCDELTYPESS.pls 120.0 2005/10/06 15:58:24 amakalin noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_DELIVERABLE_TYPE_CODE in VARCHAR2,
  X_INTERNAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_DELIVERABLE_TYPE_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
end OKC_DELIVERABLE_TYPES_PKG;

 

/
