--------------------------------------------------------
--  DDL for Package PV_GE_BENEFITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_BENEFITS_PKG" AUTHID CURRENT_USER as
/* $Header: pvxtpgbs.pls 120.1 2005/06/30 14:54:12 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BENEFIT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_BENEFIT_STATUS_CODE in VARCHAR2,
  X_BENEFIT_CODE in VARCHAR2,
  X_DELETE_FLAG in VARCHAR2,
  X_ADDITIONAL_INFO_1 in NUMBER,
  X_ADDITIONAL_INFO_2 in VARCHAR2,
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
  X_BENEFIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_BENEFIT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_BENEFIT_STATUS_CODE in VARCHAR2,
  X_BENEFIT_CODE in VARCHAR2,
  X_DELETE_FLAG in VARCHAR2,
  X_ADDITIONAL_INFO_1 in NUMBER,
  X_ADDITIONAL_INFO_2 in VARCHAR2,
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
  X_BENEFIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_BENEFIT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_BENEFIT_STATUS_CODE in VARCHAR2,
  X_BENEFIT_CODE in VARCHAR2,
  X_DELETE_FLAG in VARCHAR2,
  X_ADDITIONAL_INFO_1 in NUMBER,
  X_ADDITIONAL_INFO_2 in VARCHAR2,
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
  X_BENEFIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_BENEFIT_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure UPDATE_SEED_ROW (
  X_BENEFIT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_BENEFIT_STATUS_CODE in VARCHAR2,
  X_BENEFIT_CODE in VARCHAR2,
  X_DELETE_FLAG in VARCHAR2,
  X_ADDITIONAL_INFO_1 in NUMBER,
  X_ADDITIONAL_INFO_2 in VARCHAR2,
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
  X_BENEFIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure SEED_UPDATE_ROW (
  X_BENEFIT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_BENEFIT_STATUS_CODE in VARCHAR2,
  X_BENEFIT_CODE in VARCHAR2,
  X_DELETE_FLAG in VARCHAR2,
  X_ADDITIONAL_INFO_1 in NUMBER,
  X_ADDITIONAL_INFO_2 in VARCHAR2,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
PROCEDURE load_seed_row
( p_UPLOAD_MODE                 in VARCHAR2,
  p_BENEFIT_ID			IN NUMBER,
  p_BENEFIT_TYPE_CODE		in VARCHAR2,
  p_BENEFIT_STATUS_CODE		in VARCHAR2,
  p_BENEFIT_CODE		in VARCHAR2,
  p_DELETE_FLAG			in VARCHAR2,
  p_ADDITIONAL_INFO_1		in NUMBER,
  p_ADDITIONAL_INFO_2		in VARCHAR2,
  p_ATTRIBUTE_CATEGORY		in VARCHAR2,
  p_ATTRIBUTE1			in VARCHAR2,
  p_ATTRIBUTE2			in VARCHAR2,
  p_ATTRIBUTE3			in VARCHAR2,
  p_ATTRIBUTE4			in VARCHAR2,
  p_ATTRIBUTE5			in VARCHAR2,
  p_ATTRIBUTE6			in VARCHAR2,
  p_ATTRIBUTE7			in VARCHAR2,
  p_ATTRIBUTE8			in VARCHAR2,
  p_ATTRIBUTE9			in VARCHAR2,
  p_ATTRIBUTE10			in VARCHAR2,
  p_ATTRIBUTE11			in VARCHAR2,
  p_ATTRIBUTE12			in VARCHAR2,
  p_ATTRIBUTE13			in VARCHAR2,
  p_ATTRIBUTE14			in VARCHAR2,
  p_ATTRIBUTE15			in VARCHAR2,
  p_BENEFIT_NAME		in VARCHAR2,
  p_DESCRIPTION			in VARCHAR2,
  p_owner			in VARCHAR2 );

PROCEDURE LOAD_ROW
( p_BENEFIT_ID			IN NUMBER,
  p_BENEFIT_TYPE_CODE		in VARCHAR2,
  p_BENEFIT_STATUS_CODE		in VARCHAR2,
  p_BENEFIT_CODE		in VARCHAR2,
  p_DELETE_FLAG			in VARCHAR2,
  p_ADDITIONAL_INFO_1		in NUMBER,
  p_ADDITIONAL_INFO_2		in VARCHAR2,
  p_ATTRIBUTE_CATEGORY		in VARCHAR2,
  p_ATTRIBUTE1			in VARCHAR2,
  p_ATTRIBUTE2			in VARCHAR2,
  p_ATTRIBUTE3			in VARCHAR2,
  p_ATTRIBUTE4			in VARCHAR2,
  p_ATTRIBUTE5			in VARCHAR2,
  p_ATTRIBUTE6			in VARCHAR2,
  p_ATTRIBUTE7			in VARCHAR2,
  p_ATTRIBUTE8			in VARCHAR2,
  p_ATTRIBUTE9			in VARCHAR2,
  p_ATTRIBUTE10			in VARCHAR2,
  p_ATTRIBUTE11			in VARCHAR2,
  p_ATTRIBUTE12			in VARCHAR2,
  p_ATTRIBUTE13			in VARCHAR2,
  p_ATTRIBUTE14			in VARCHAR2,
  p_ATTRIBUTE15			in VARCHAR2,
  p_BENEFIT_NAME		in VARCHAR2,
  p_DESCRIPTION			in VARCHAR2,
  p_owner			in VARCHAR2 );

procedure TRANSLATE_ROW(
       p_benefit_id	   in VARCHAR2
     , p_benefit_name      in VARCHAR2
     , p_description       in VARCHAR2
     , p_owner             in VARCHAR2
 );
end PV_GE_BENEFITS_PKG;

 

/
