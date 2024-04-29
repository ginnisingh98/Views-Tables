--------------------------------------------------------
--  DDL for Package OKC_RESP_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RESP_PARTIES_PKG" AUTHID CURRENT_USER as
/* $Header: OKCRPARTYS.pls 120.1 2005/06/22 10:39:31 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_TYPE_CLASS in VARCHAR2,
  X_RESP_PARTY_CODE in VARCHAR2,
  X_INTENT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERNAL_EXTERNAL_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ALTERNATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_DOCUMENT_TYPE_CLASS in VARCHAR2,
  X_RESP_PARTY_CODE in VARCHAR2,
  X_INTENT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERNAL_EXTERNAL_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ALTERNATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_DOCUMENT_TYPE_CLASS in VARCHAR2,
  X_RESP_PARTY_CODE in VARCHAR2,
  X_INTENT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTERNAL_EXTERNAL_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ALTERNATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_DOCUMENT_TYPE_CLASS in VARCHAR2,
  X_RESP_PARTY_CODE in VARCHAR2,
  X_INTENT in VARCHAR2
);
procedure ADD_LANGUAGE;
end OKC_RESP_PARTIES_PKG;

 

/