--------------------------------------------------------
--  DDL for Package OKC_BUS_DOC_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_BUS_DOC_EVENTS_PVT" AUTHID CURRENT_USER as
/* $Header: OKCVBDES.pls 120.0 2005/05/25 22:50:29 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BUS_DOC_EVENT_ID in NUMBER,
  X_BUSINESS_EVENT_CODE in VARCHAR2,
  X_BUS_DOC_TYPE in VARCHAR2,
  X_BEFORE_AFTER in VARCHAR2,
  X_START_END_QUALIFIER in VARCHAR2,
  X_MEANING in VARCHAR2,
  --X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_BUS_DOC_EVENT_ID in NUMBER,
  X_BUSINESS_EVENT_CODE in VARCHAR2,
  X_BUS_DOC_TYPE in VARCHAR2,
  X_BEFORE_AFTER in VARCHAR2,
  X_START_END_QUALIFIER in VARCHAR2,
  X_MEANING in VARCHAR2
  --X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_BUS_DOC_EVENT_ID in NUMBER,
  X_BUSINESS_EVENT_CODE in VARCHAR2,
  X_BUS_DOC_TYPE in VARCHAR2,
  X_BEFORE_AFTER in VARCHAR2,
  X_START_END_QUALIFIER in VARCHAR2,
  X_MEANING in VARCHAR2,
  --X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_BUS_DOC_EVENT_ID in NUMBER
);

procedure ADD_LANGUAGE;


end OKC_BUS_DOC_EVENTS_PVT;

 

/
