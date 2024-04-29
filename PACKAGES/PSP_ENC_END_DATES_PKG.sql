--------------------------------------------------------
--  DDL for Package PSP_ENC_END_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_END_DATES_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPENEDS.pls 115.9 2002/11/19 11:36:10 ddubey psp2376993.sql $  */

/* Introduced x_prev_enc_end_date as a part of Enh. bug 2259310 */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENC_END_DATE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_PERIOD_END_DATE in DATE,
  X_EFF_START_DATE in DATE,
  X_EFF_END_DATE in DATE,
  X_DEFAULT_ORG_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_MODE in VARCHAR2 default 'R',
  X_PREV_ENC_END_DATE IN DATE DEFAULT NULL
  );

/* Introduced x_prev_enc_end_date as a part of Enh. bug 2259310 */
procedure LOCK_ROW (
  X_ENC_END_DATE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_PERIOD_END_DATE in DATE,
  X_EFF_START_DATE in DATE,
  X_EFF_END_DATE in DATE,
  X_DEFAULT_ORG_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_PREV_ENC_END_DATE IN DATE DEFAULT NULL
);

/* Introduced x_prev_enc_end_date as a part of Enh. bug 2259310 */
procedure UPDATE_ROW (
  X_ENC_END_DATE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_PERIOD_END_DATE in DATE,
  X_EFF_START_DATE in DATE,
  X_EFF_END_DATE in DATE,
  X_DEFAULT_ORG_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_MODE in VARCHAR2 default 'R',
  X_PREV_ENC_END_DATE IN DATE DEFAULT NULL
  );

/* Introduced x_prev_enc_end_date as a part of Enh. bug 2259310 */
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENC_END_DATE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_PERIOD_END_DATE in DATE,
  X_EFF_START_DATE in DATE,
  X_EFF_END_DATE in DATE,
  X_DEFAULT_ORG_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_MODE in VARCHAR2 default 'R',
  X_PREV_ENC_END_DATE IN DATE DEFAULT NULL
  );
procedure DELETE_ROW (
  X_ENC_END_DATE_ID in NUMBER
);
end PSP_ENC_END_DATES_PKG;

 

/