--------------------------------------------------------
--  DDL for Package QP_LIST_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIST_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: QPXLHDRS.pls 120.1 2005/06/10 08:00:42 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_SHIP_METHOD_CODE in VARCHAR2,
  X_FREIGHT_TERMS_CODE in VARCHAR2,
  X_LIST_HEADER_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AUTOMATIC_FLAG in VARCHAR2,
  X_LIST_TYPE_CODE in VARCHAR2,
  X_TERMS_ID in NUMBER,
  X_ROUNDING_FACTOR in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER  DEFAULT NULL,
  X_PROGRAM_ID in NUMBER  DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE in DATE  DEFAULT NULL,
  X_DISCOUNT_LINES_FLAG in VARCHAR2  DEFAULT NULL,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_VERSION_NO in VARCHAR2  DEFAULT NULL,
  X_COMMENTS in VARCHAR2  DEFAULT NULL,
  X_GSA_INDICATOR in VARCHAR2  DEFAULT NULL,
  X_PRORATE_FLAG in VARCHAR2  DEFAULT NULL,
  X_SOURCE_SYSTEM_CODE in VARCHAR2  DEFAULT NULL,
  X_ASK_FOR_FLAG in VARCHAR2  DEFAULT NULL,
  X_PARENT_LIST_HEADER_ID in NUMBER  DEFAULT NULL,
  X_START_DATE_ACTIVE_FIRST in DATE  DEFAULT NULL,
  X_END_DATE_ACTIVE_FIRST in DATE  DEFAULT NULL,
  X_ACTIVE_DATE_FIRST_TYPE in VARCHAR2  DEFAULT NULL,
  X_START_DATE_ACTIVE_SECOND in DATE  DEFAULT NULL,
  X_END_DATE_ACTIVE_SECOND in DATE  DEFAULT NULL,
  X_ACTIVE_DATE_SECOND_TYPE in VARCHAR2  DEFAULT NULL,
  X_ACTIVE_FLAG in VARCHAR2  DEFAULT NULL,
  X_MOBILE_DOWNLOAD in VARCHAR2  DEFAULT NULL,
  X_CURRENCY_HEADER_ID in NUMBER  DEFAULT NULL,
  X_PTE_CODE in VARCHAR2  DEFAULT NULL,
  X_LIST_SOURCE_CODE in VARCHAR2  DEFAULT NULL,
  X_ORIG_SYSTEM_HEADER_REF in VARCHAR2  DEFAULT NULL,
  X_GLOBAL_FLAG in VARCHAR2  DEFAULT NULL,
  X_ORIG_ORG_ID in NUMBER  DEFAULT NULL,
  X_VIEW_FLAG in VARCHAR2  DEFAULT NULL,
  X_UPDATE_FLAG in VARCHAR2  DEFAULT NULL
  );

procedure LOCK_ROW (
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_SHIP_METHOD_CODE in VARCHAR2,
  X_FREIGHT_TERMS_CODE in VARCHAR2,
  X_LIST_HEADER_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AUTOMATIC_FLAG in VARCHAR2,
  X_LIST_TYPE_CODE in VARCHAR2,
  X_TERMS_ID in NUMBER,
  X_ROUNDING_FACTOR in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER  DEFAULT NULL,
  X_PROGRAM_ID in NUMBER  DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE in DATE  DEFAULT NULL,
  X_DISCOUNT_LINES_FLAG in VARCHAR2  DEFAULT NULL,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_VERSION_NO in VARCHAR2  DEFAULT NULL,
  X_COMMENTS in VARCHAR2  DEFAULT NULL,
  X_GSA_INDICATOR in VARCHAR2  DEFAULT NULL,
  X_PRORATE_FLAG in VARCHAR2  DEFAULT NULL,
  X_SOURCE_SYSTEM_CODE in VARCHAR2  DEFAULT NULL,
  X_ASK_FOR_FLAG in VARCHAR2  DEFAULT NULL,
  X_PARENT_LIST_HEADER_ID in NUMBER  DEFAULT NULL,
  X_START_DATE_ACTIVE_FIRST in DATE  DEFAULT NULL,
  X_END_DATE_ACTIVE_FIRST in DATE  DEFAULT NULL,
  X_ACTIVE_DATE_FIRST_TYPE in VARCHAR2  DEFAULT NULL,
  X_START_DATE_ACTIVE_SECOND in DATE  DEFAULT NULL,
  X_END_DATE_ACTIVE_SECOND in DATE  DEFAULT NULL,
  X_ACTIVE_DATE_SECOND_TYPE in VARCHAR2  DEFAULT NULL,
  X_ACTIVE_FLAG in VARCHAR2  DEFAULT NULL,
  X_MOBILE_DOWNLOAD in VARCHAR2  DEFAULT NULL,
  X_CURRENCY_HEADER_ID in NUMBER  DEFAULT NULL,
  X_PTE_CODE in VARCHAR2  DEFAULT NULL,
  X_LIST_SOURCE_CODE in VARCHAR2  DEFAULT NULL,
  X_ORIG_SYSTEM_HEADER_REF in VARCHAR2  DEFAULT NULL,
  X_GLOBAL_FLAG in VARCHAR2  DEFAULT NULL,
  X_ORIG_ORG_ID in NUMBER  DEFAULT NULL,
  X_VIEW_FLAG in VARCHAR2  DEFAULT NULL,
  X_UPDATE_FLAG in VARCHAR2  DEFAULT NULL
);

procedure UPDATE_ROW (
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_SHIP_METHOD_CODE in VARCHAR2,
  X_FREIGHT_TERMS_CODE in VARCHAR2,
  X_LIST_HEADER_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AUTOMATIC_FLAG in VARCHAR2,
  X_LIST_TYPE_CODE in VARCHAR2,
  X_TERMS_ID in NUMBER,
  X_ROUNDING_FACTOR in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER  DEFAULT NULL,
  X_PROGRAM_ID in NUMBER  DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE in DATE  DEFAULT NULL,
  X_DISCOUNT_LINES_FLAG in VARCHAR2  DEFAULT NULL,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_VERSION_NO in VARCHAR2  DEFAULT NULL,
  X_COMMENTS in VARCHAR2  DEFAULT NULL,
  X_GSA_INDICATOR in VARCHAR2  DEFAULT NULL,
  X_PRORATE_FLAG in VARCHAR2  DEFAULT NULL,
  X_SOURCE_SYSTEM_CODE in VARCHAR2  DEFAULT NULL,
  X_ASK_FOR_FLAG in VARCHAR2  DEFAULT NULL,
  X_PARENT_LIST_HEADER_ID in NUMBER  DEFAULT NULL,
  X_START_DATE_ACTIVE_FIRST in DATE  DEFAULT NULL,
  X_END_DATE_ACTIVE_FIRST in DATE  DEFAULT NULL,
  X_ACTIVE_DATE_FIRST_TYPE in VARCHAR2  DEFAULT NULL,
  X_START_DATE_ACTIVE_SECOND in DATE  DEFAULT NULL,
  X_END_DATE_ACTIVE_SECOND in DATE  DEFAULT NULL,
  X_ACTIVE_DATE_SECOND_TYPE in VARCHAR2  DEFAULT NULL,
  X_ACTIVE_FLAG in VARCHAR2  DEFAULT NULL,
  X_MOBILE_DOWNLOAD in VARCHAR2  DEFAULT NULL,
  X_CURRENCY_HEADER_ID in NUMBER  DEFAULT NULL,
  X_PTE_CODE in VARCHAR2  DEFAULT NULL,
  X_LIST_SOURCE_CODE in VARCHAR2  DEFAULT NULL,
  X_ORIG_SYSTEM_HEADER_REF in VARCHAR2  DEFAULT NULL,
  X_GLOBAL_FLAG in VARCHAR2  DEFAULT NULL,
  X_ORIG_ORG_ID in NUMBER  DEFAULT NULL,
  X_VIEW_FLAG in VARCHAR2  DEFAULT NULL,
  X_UPDATE_FLAG in VARCHAR2  DEFAULT NULL
);

procedure DELETE_ROW (
  X_LIST_HEADER_ID in NUMBER
);

procedure ADD_LANGUAGE;
end QP_LIST_HEADERS_PKG;

 

/