--------------------------------------------------------
--  DDL for Package IEC_O_RECYCLING_ALGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_O_RECYCLING_ALGS_PKG" AUTHID CURRENT_USER as
/* $Header: IECHRCYS.pls 115.10 2004/02/12 18:41:22 jcmoore ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ALGORITHM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_ALGORITHM_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARENT_ID in NUMBER);
procedure LOCK_ROW (
  X_ALGORITHM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_ALGORITHM_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_ALGORITHM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_ALGORITHM_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_ALGORITHM_ID in NUMBER
);
procedure ADD_LANGUAGE;
end IEC_O_RECYCLING_ALGS_PKG;

 

/