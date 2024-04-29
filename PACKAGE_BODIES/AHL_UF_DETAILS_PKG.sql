--------------------------------------------------------
--  DDL for Package Body AHL_UF_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UF_DETAILS_PKG" as
/* $Header: AHLLUFDB.pls 115.1 2002/12/04 22:45:55 sracha noship $ */
PROCEDURE INSERT_ROW (
        X_UF_DETAIL_ID            IN OUT NOCOPY NUMBER,
        X_OBJECT_VERSION_NUMBER   IN     NUMBER,
        X_CREATED_BY              IN     NUMBER,
        X_CREATION_DATE           IN     DATE,
        X_LAST_UPDATED_BY         IN     NUMBER,
        X_LAST_UPDATE_DATE        IN     DATE,
        X_LAST_UPDATE_LOGIN       IN     NUMBER,
        X_UF_HEADER_ID            IN     NUMBER,
        X_UOM_CODE                IN     VARCHAR2,
        X_START_DATE              IN     DATE,
        X_END_DATE                IN     DATE,
        X_USAGE_PER_DAY           IN     NUMBER,
        X_ATTRIBUTE_CATEGORY      IN     VARCHAR2,
        X_ATTRIBUTE1              IN     VARCHAR2,
        X_ATTRIBUTE2              IN     VARCHAR2,
        X_ATTRIBUTE3              IN     VARCHAR2,
        X_ATTRIBUTE4              IN     VARCHAR2,
        X_ATTRIBUTE5              IN     VARCHAR2,
        X_ATTRIBUTE6              IN     VARCHAR2,
        X_ATTRIBUTE7              IN     VARCHAR2,
        X_ATTRIBUTE8              IN     VARCHAR2,
        X_ATTRIBUTE9              IN     VARCHAR2,
        X_ATTRIBUTE10             IN     VARCHAR2,
        X_ATTRIBUTE11             IN     VARCHAR2,
        X_ATTRIBUTE12             IN     VARCHAR2,
        X_ATTRIBUTE13             IN     VARCHAR2,
        X_ATTRIBUTE14             IN     VARCHAR2,
        X_ATTRIBUTE15             IN     VARCHAR2
) IS


BEGIN
  insert into AHL_UF_DETAILS (
    UF_DETAIL_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    UF_HEADER_ID,
    UOM_CODE,
    START_DATE,
    END_DATE,
    USAGE_PER_DAY,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15
   )  values (
        AHL_UF_DETAILS_S.NEXTVAL,
        X_OBJECT_VERSION_NUMBER,
        X_CREATED_BY,
        X_CREATION_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN,
        X_UF_HEADER_ID,
        X_UOM_CODE,
        X_START_DATE,
        X_END_DATE,
        X_USAGE_PER_DAY,
        X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1,
        X_ATTRIBUTE2,
        X_ATTRIBUTE3,
        X_ATTRIBUTE4,
        X_ATTRIBUTE5,
        X_ATTRIBUTE6,
        X_ATTRIBUTE7,
        X_ATTRIBUTE8,
        X_ATTRIBUTE9,
        X_ATTRIBUTE10,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15

) RETURNING UF_DETAIL_ID INTO X_UF_DETAIL_ID;
EXCEPTION
    WHEN OTHERS THEN
        IF(SQLCODE = -1) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_UF_DUP_DET');
            FND_MESSAGE.Set_Token('START_DATE',x_start_date);
            FND_MESSAGE.Set_Token('END_DATE',x_end_date);
            FND_MESSAGE.Set_Token('UOM_CODE',x_uom_code);
            FND_MESSAGE.Set_Token('USAGE_PER_DAY',x_usage_per_day);
            FND_MSG_PUB.ADD;
        ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END INSERT_ROW;


PROCEDURE UPDATE_ROW (

        X_UF_DETAIL_ID            IN     NUMBER,
        X_OBJECT_VERSION_NUMBER   IN     NUMBER,
        X_LAST_UPDATED_BY         IN     NUMBER,
        X_LAST_UPDATE_DATE        IN     DATE,
        X_LAST_UPDATE_LOGIN       IN     NUMBER,
        X_UF_HEADER_ID            IN     NUMBER,
        X_UOM_CODE                IN     VARCHAR2,
        X_START_DATE              IN     DATE,
        X_END_DATE                IN     DATE,
        X_USAGE_PER_DAY           IN     NUMBER,
        X_ATTRIBUTE_CATEGORY      IN     VARCHAR2,
        X_ATTRIBUTE1              IN     VARCHAR2,
        X_ATTRIBUTE2              IN     VARCHAR2,
        X_ATTRIBUTE3              IN     VARCHAR2,
        X_ATTRIBUTE4              IN     VARCHAR2,
        X_ATTRIBUTE5              IN     VARCHAR2,
        X_ATTRIBUTE6              IN     VARCHAR2,
        X_ATTRIBUTE7              IN     VARCHAR2,
        X_ATTRIBUTE8              IN     VARCHAR2,
        X_ATTRIBUTE9              IN     VARCHAR2,
        X_ATTRIBUTE10             IN     VARCHAR2,
        X_ATTRIBUTE11             IN     VARCHAR2,
        X_ATTRIBUTE12             IN     VARCHAR2,
        X_ATTRIBUTE13             IN     VARCHAR2,
        X_ATTRIBUTE14             IN     VARCHAR2,
        X_ATTRIBUTE15             IN     VARCHAR2
) IS


BEGIN
  update AHL_UF_DETAILS set
    UF_DETAIL_ID = X_UF_DETAIL_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    UF_HEADER_ID = X_UF_HEADER_ID,
    UOM_CODE = X_UOM_CODE,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    USAGE_PER_DAY = X_USAGE_PER_DAY,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15
  where UF_DETAIL_ID = X_UF_DETAIL_ID
  and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER - 1;

  IF (SQL%NOTFOUND) then
    RAISE no_data_found;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  X_UF_DETAIL_ID in NUMBER
) is

BEGIN

  delete from AHL_UF_DETAILS
  where UF_DETAIL_ID = X_UF_DETAIL_ID;

  IF (SQL%NOTFOUND) then
    RAISE no_data_found;
  END IF;

END DELETE_ROW;

END AHL_UF_DETAILS_PKG;

/
