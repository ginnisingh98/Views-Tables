--------------------------------------------------------
--  DDL for Package PER_CAGR_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAGR_APIS_PKG" AUTHID CURRENT_USER as
/* $Header: peapilct.pkh 120.1 2006/06/20 09:24:02 bshukla noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CAGR_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_API_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure TRANSLATE_ROW (
  X_API_NAME1                  in VARCHAR2 default null,
  X_API_NAME                   in VARCHAR2,
  X_OWNER                      in VARCHAR2  );


procedure LOAD_ROW (
  X_API_NAME                  in VARCHAR2,
  X_CATEGORY_NAME 	      in VARCHAR2,
  X_OWNER                     in VARCHAR2,
  X_OBJECT_VERSION_NUMBER     in NUMBER);

procedure LOCK_ROW (
  X_CAGR_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_API_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_CAGR_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_API_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_CAGR_API_ID in NUMBER
);
procedure ADD_LANGUAGE;
end PER_CAGR_APIS_PKG;

 

/
