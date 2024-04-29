--------------------------------------------------------
--  DDL for Package EDR_IDX_XML_ELEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_IDX_XML_ELEMENT_PKG" AUTHID CURRENT_USER as
/* $Header: EDRGMLS.pls 120.1.12000000.1 2007/01/18 05:53:43 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_SECTION_NAME in VARCHAR2,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2);

--Bug 3783242 : Start
--New overloaded insert row procedure without index_section_name
--and row id.
--this proc is called from the original insert_row in the table handler
--all the time. so now the index section name is always determined
--in this proc itself and the passed value is ignored by definition
--the reason we still need the original insert_row is because the
--OATLEntity standards mandates that all parameters be present for the
--proc

procedure INSERT_ROW (
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2);
--Bug 3783242 : End

procedure LOCK_ROW (
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_SECTION_NAME in VARCHAR2,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_ELEMENT_ID in NUMBER,
  X_XML_ELEMENT in VARCHAR2,
  X_DTD_ROOT_ELEMENT in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INDEX_SECTION_NAME in VARCHAR2,
  X_INDEX_TAG in VARCHAR2,
  X_STATUS in CHAR,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure DELETE_ROW (
  X_ELEMENT_ID in NUMBER
);
procedure ADD_LANGUAGE;
end EDR_IDX_XML_ELEMENT_PKG;

 

/
