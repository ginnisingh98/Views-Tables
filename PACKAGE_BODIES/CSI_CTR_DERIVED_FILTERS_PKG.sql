--------------------------------------------------------
--  DDL for Package Body CSI_CTR_DERIVED_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_CTR_DERIVED_FILTERS_PKG" as
/* $Header: csitcdfb.pls 120.1 2008/04/03 21:53:21 devijay ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_DERIVED_FILTERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcdfb.pls';

PROCEDURE Insert_Row(
	px_COUNTER_DERIVED_FILTER_ID       IN OUT NOCOPY NUMBER
 	,p_COUNTER_ID                      NUMBER
 	,p_SEQ_NO                          NUMBER
 	,p_LEFT_PARENT                     VARCHAR2
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_RELATIONAL_OPERATOR             VARCHAR2
 	,p_RIGHT_VALUE                     VARCHAR2
 	,p_RIGHT_PARENT                    VARCHAR2
 	,p_LOGICAL_OPERATOR                VARCHAR2
 	,p_START_DATE_ACTIVE               DATE
 	,p_END_DATE_ACTIVE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                 NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
 	,p_ATTRIBUTE1                      VARCHAR2
 	,p_ATTRIBUTE2                      VARCHAR2
 	,p_ATTRIBUTE3                      VARCHAR2
 	,p_ATTRIBUTE4                      VARCHAR2
 	,p_ATTRIBUTE5                      VARCHAR2
 	,p_ATTRIBUTE6                      VARCHAR2
 	,p_ATTRIBUTE7                      VARCHAR2
 	,p_ATTRIBUTE8                      VARCHAR2
 	,p_ATTRIBUTE9                      VARCHAR2
 	,p_ATTRIBUTE10                     VARCHAR2
 	,p_ATTRIBUTE11                     VARCHAR2
 	,p_ATTRIBUTE12                     VARCHAR2
 	,p_ATTRIBUTE13                     VARCHAR2
 	,p_ATTRIBUTE14                     VARCHAR2
 	,p_ATTRIBUTE15                     VARCHAR2
 	,p_ATTRIBUTE_CATEGORY              VARCHAR2
 	,p_SECURITY_GROUP_ID               NUMBER
 	,p_MIGRATED_FLAG                   VARCHAR2
		) IS

	CURSOR C1 IS
	SELECT	CSI_CTR_DERIVED_FILTERS_S.nextval
	FROM	dual;
BEGIN
	IF (px_COUNTER_DERIVED_FILTER_ID IS NULL) OR (px_COUNTER_DERIVED_FILTER_ID = FND_API.G_MISS_NUM) THEN
		OPEN C1;
		FETCH C1 INTO px_COUNTER_DERIVED_FILTER_ID;
		CLOSE C1;
	END IF;

	INSERT INTO CSI_COUNTER_DERIVED_FILTERS(
		COUNTER_DERIVED_FILTER_ID
 		,COUNTER_ID
 		,SEQ_NO
 		,LEFT_PARENT
 		,COUNTER_PROPERTY_ID
 		,RELATIONAL_OPERATOR
 		,RIGHT_VALUE
 		,RIGHT_PARENT
 		,LOGICAL_OPERATOR
 		,START_DATE_ACTIVE
 		,END_DATE_ACTIVE
 		,OBJECT_VERSION_NUMBER
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,CREATION_DATE
 		,CREATED_BY
 		,LAST_UPDATE_LOGIN
 		,ATTRIBUTE1
 		,ATTRIBUTE2
 		,ATTRIBUTE3
 		,ATTRIBUTE4
 		,ATTRIBUTE5
 		,ATTRIBUTE6
 		,ATTRIBUTE7
 		,ATTRIBUTE8
 		,ATTRIBUTE9
 		,ATTRIBUTE10
 		,ATTRIBUTE11
 		,ATTRIBUTE12
 		,ATTRIBUTE13
 		,ATTRIBUTE14
 		,ATTRIBUTE15
 		,ATTRIBUTE_CATEGORY
 		,SECURITY_GROUP_ID
 		,MIGRATED_FLAG
		)
	VALUES(
		px_COUNTER_DERIVED_FILTER_ID
 		,decode(p_COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
 		,decode(p_SEQ_NO, FND_API.G_MISS_NUM, NULL, p_SEQ_NO)
 		,decode(p_LEFT_PARENT, FND_API.G_MISS_CHAR, NULL, p_LEFT_PARENT)
 		,decode(p_COUNTER_PROPERTY_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_PROPERTY_ID)
 		,decode(p_RELATIONAL_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_RELATIONAL_OPERATOR)
 		,decode(p_RIGHT_VALUE, FND_API.G_MISS_CHAR, NULL, p_RIGHT_VALUE)
 		,decode(p_RIGHT_PARENT, FND_API.G_MISS_CHAR, NULL, p_RIGHT_PARENT)
 		,decode(p_LOGICAL_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_LOGICAL_OPERATOR)
 		,decode(p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE_ACTIVE)
 		,decode(p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE_ACTIVE)
 		,decode(p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
 		,decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
 		,decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
 		,decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
 		,decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
 		,decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
 		,decode(p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
 		,decode(p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
 		,decode(p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
 		,decode(p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
 		,decode(p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
 		,decode(p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
 		,decode(p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
 		,decode(p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
 		,decode(p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
 		,decode(p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
 		,decode(p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
 		,decode(p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
 		,decode(p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
 		,decode(p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
 		,decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
 		,decode(p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
 		,decode(p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID)
 		,decode(p_MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_MIGRATED_FLAG)
		);

End Insert_Row;

PROCEDURE Update_Row(
	p_COUNTER_DERIVED_FILTER_ID        NUMBER
 	,p_COUNTER_ID                      NUMBER
 	,p_SEQ_NO                          NUMBER
 	,p_LEFT_PARENT                     VARCHAR2
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_RELATIONAL_OPERATOR             VARCHAR2
 	,p_RIGHT_VALUE                     VARCHAR2
 	,p_RIGHT_PARENT                    VARCHAR2
 	,p_LOGICAL_OPERATOR                VARCHAR2
 	,p_START_DATE_ACTIVE               DATE
 	,p_END_DATE_ACTIVE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                 NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
 	,p_ATTRIBUTE1                      VARCHAR2
 	,p_ATTRIBUTE2                      VARCHAR2
 	,p_ATTRIBUTE3                      VARCHAR2
 	,p_ATTRIBUTE4                      VARCHAR2
 	,p_ATTRIBUTE5                      VARCHAR2
 	,p_ATTRIBUTE6                      VARCHAR2
 	,p_ATTRIBUTE7                      VARCHAR2
 	,p_ATTRIBUTE8                      VARCHAR2
 	,p_ATTRIBUTE9                      VARCHAR2
 	,p_ATTRIBUTE10                     VARCHAR2
 	,p_ATTRIBUTE11                     VARCHAR2
 	,p_ATTRIBUTE12                     VARCHAR2
 	,p_ATTRIBUTE13                     VARCHAR2
 	,p_ATTRIBUTE14                     VARCHAR2
 	,p_ATTRIBUTE15                     VARCHAR2
 	,p_ATTRIBUTE_CATEGORY              VARCHAR2
 	,p_SECURITY_GROUP_ID               NUMBER
 	,p_MIGRATED_FLAG                   VARCHAR2
        ) IS
BEGIN
	UPDATE CSI_COUNTER_DERIVED_FILTERS
	SET
 		COUNTER_ID = decode(p_COUNTER_ID, NULL, COUNTER_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_ID)
 		,SEQ_NO = decode(p_SEQ_NO, NULL, SEQ_NO, FND_API.G_MISS_NUM, NULL, p_SEQ_NO)
 		,LEFT_PARENT = decode(p_LEFT_PARENT, NULL, LEFT_PARENT, FND_API.G_MISS_CHAR, NULL, p_LEFT_PARENT)
 		,COUNTER_PROPERTY_ID = decode(p_COUNTER_PROPERTY_ID, NULL, COUNTER_PROPERTY_ID, FND_API.G_MISS_NUM, NULL, p_COUNTER_PROPERTY_ID)
 		,RELATIONAL_OPERATOR = decode(p_RELATIONAL_OPERATOR, NULL, RELATIONAL_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_RELATIONAL_OPERATOR)
 		,RIGHT_VALUE = decode(p_RIGHT_VALUE, NULL, RIGHT_VALUE, FND_API.G_MISS_CHAR, NULL, p_RIGHT_VALUE)
 		,RIGHT_PARENT = decode(p_RIGHT_PARENT, NULL, RIGHT_PARENT, FND_API.G_MISS_CHAR, NULL, p_RIGHT_PARENT)
 		,LOGICAL_OPERATOR = decode(p_LOGICAL_OPERATOR, NULL, LOGICAL_OPERATOR, FND_API.G_MISS_CHAR, NULL, p_LOGICAL_OPERATOR)
 		,START_DATE_ACTIVE = decode(p_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_START_DATE_ACTIVE)
 		,END_DATE_ACTIVE = decode(p_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_END_DATE_ACTIVE)
 		,OBJECT_VERSION_NUMBER = decode(p_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
 		,LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, NULL, LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE)
 		,LAST_UPDATED_BY = decode(p_LAST_UPDATED_BY, NULL, LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
 		,CREATION_DATE = decode(p_CREATION_DATE, NULL, CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
	    ,CREATED_BY = decode(p_CREATED_BY, NULL, CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
 		,LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN, NULL, LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
 		,ATTRIBUTE1 = decode(p_ATTRIBUTE1, NULL, ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
 		,ATTRIBUTE2 = decode(p_ATTRIBUTE2, NULL, ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
 		,ATTRIBUTE3 = decode(p_ATTRIBUTE3, NULL, ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
 		,ATTRIBUTE4 = decode(p_ATTRIBUTE4, NULL, ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
 		,ATTRIBUTE5 = decode(p_ATTRIBUTE5, NULL, ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
 		,ATTRIBUTE6 = decode(p_ATTRIBUTE6, NULL, ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
 		,ATTRIBUTE7 = decode(p_ATTRIBUTE7, NULL, ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
 		,ATTRIBUTE8 = decode(p_ATTRIBUTE8, NULL, ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
 		,ATTRIBUTE9 = decode(p_ATTRIBUTE9, NULL, ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
 		,ATTRIBUTE10 = decode(p_ATTRIBUTE10, NULL, ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
 		,ATTRIBUTE11 = decode(p_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
 		,ATTRIBUTE12 = decode(p_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
 		,ATTRIBUTE13 = decode(p_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
 		,ATTRIBUTE14 = decode(p_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
 		,ATTRIBUTE15 = decode(p_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
 		,ATTRIBUTE_CATEGORY = decode(p_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
 		,SECURITY_GROUP_ID = decode(p_SECURITY_GROUP_ID, NULL, SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID)
 		,MIGRATED_FLAG = decode(p_MIGRATED_FLAG, NULL, MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_MIGRATED_FLAG)
	WHERE COUNTER_DERIVED_FILTER_ID = p_COUNTER_DERIVED_FILTER_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Lock_Row(
	p_COUNTER_DERIVED_FILTER_ID        NUMBER
 	,p_COUNTER_ID                      NUMBER
 	,p_SEQ_NO                          NUMBER
 	,p_LEFT_PARENT                     VARCHAR2
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_RELATIONAL_OPERATOR             VARCHAR2
 	,p_RIGHT_VALUE                     VARCHAR2
 	,p_RIGHT_PARENT                    VARCHAR2
 	,p_LOGICAL_OPERATOR                VARCHAR2
 	,p_START_DATE_ACTIVE               DATE
 	,p_END_DATE_ACTIVE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                 NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
 	,p_ATTRIBUTE1                      VARCHAR2
 	,p_ATTRIBUTE2                      VARCHAR2
 	,p_ATTRIBUTE3                      VARCHAR2
 	,p_ATTRIBUTE4                      VARCHAR2
 	,p_ATTRIBUTE5                      VARCHAR2
 	,p_ATTRIBUTE6                      VARCHAR2
 	,p_ATTRIBUTE7                      VARCHAR2
 	,p_ATTRIBUTE8                      VARCHAR2
 	,p_ATTRIBUTE9                      VARCHAR2
 	,p_ATTRIBUTE10                     VARCHAR2
 	,p_ATTRIBUTE11                     VARCHAR2
 	,p_ATTRIBUTE12                     VARCHAR2
 	,p_ATTRIBUTE13                     VARCHAR2
 	,p_ATTRIBUTE14                     VARCHAR2
 	,p_ATTRIBUTE15                     VARCHAR2
 	,p_ATTRIBUTE_CATEGORY              VARCHAR2
 	,p_SECURITY_GROUP_ID               NUMBER
 	,p_MIGRATED_FLAG                   VARCHAR2
        ) IS

	CURSOR C1 IS
	SELECT *
	FROM CSI_COUNTER_DERIVED_FILTERS
	WHERE COUNTER_DERIVED_FILTER_ID = p_COUNTER_DERIVED_FILTER_ID
	FOR UPDATE of COUNTER_DERIVED_FILTER_ID NOWAIT;
	Recinfo C1%ROWTYPE;
BEGIN
	OPEN C1;
	FETCH C1 INTO Recinfo;
	IF (C1%NOTFOUND) THEN
		CLOSE C1;
		FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
	CLOSE C1;

	IF (
		(Recinfo.COUNTER_DERIVED_FILTER_ID = p_COUNTER_DERIVED_FILTER_ID)
 		AND ((Recinfo.COUNTER_ID = p_COUNTER_ID) OR ((Recinfo.COUNTER_ID IS NULL) AND (p_COUNTER_ID IS NULL)))
 		AND ((Recinfo.SEQ_NO = p_SEQ_NO) OR ((Recinfo.SEQ_NO IS NULL) AND (p_SEQ_NO IS NULL)))
 		AND ((Recinfo.LEFT_PARENT = p_LEFT_PARENT) OR ((Recinfo.LEFT_PARENT IS NULL) AND (p_LEFT_PARENT IS NULL)))
 		AND ((Recinfo.COUNTER_PROPERTY_ID = p_COUNTER_PROPERTY_ID) OR ((Recinfo.COUNTER_PROPERTY_ID IS NULL) AND (p_COUNTER_PROPERTY_ID IS NULL)))
 		AND ((Recinfo.RELATIONAL_OPERATOR = p_RELATIONAL_OPERATOR) OR ((Recinfo.RELATIONAL_OPERATOR IS NULL) AND (p_RELATIONAL_OPERATOR IS NULL)))
 		AND ((Recinfo.RIGHT_VALUE = p_RIGHT_VALUE) OR ((Recinfo.RIGHT_VALUE IS NULL) AND (p_RIGHT_VALUE IS NULL)))
 		AND ((Recinfo.RIGHT_PARENT = p_RIGHT_PARENT) OR ((Recinfo.RIGHT_PARENT IS NULL) AND (p_RIGHT_PARENT IS NULL)))
 		AND ((Recinfo.LOGICAL_OPERATOR = p_LOGICAL_OPERATOR) OR ((Recinfo.LOGICAL_OPERATOR IS NULL) AND (p_LOGICAL_OPERATOR IS NULL)))
 		AND ((Recinfo.START_DATE_ACTIVE = p_START_DATE_ACTIVE) OR ((Recinfo.START_DATE_ACTIVE IS NULL) AND (p_START_DATE_ACTIVE IS NULL)))
 		AND ((Recinfo.END_DATE_ACTIVE = p_END_DATE_ACTIVE) OR ((Recinfo.END_DATE_ACTIVE IS NULL) AND (p_END_DATE_ACTIVE IS NULL)))
 		AND ((Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) OR ((Recinfo.OBJECT_VERSION_NUMBER IS NULL) AND (p_OBJECT_VERSION_NUMBER IS NULL)))
 		AND ((Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) OR ((Recinfo.LAST_UPDATE_DATE IS NULL) AND (p_LAST_UPDATE_DATE IS NULL)))
 		AND ((Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) OR ((Recinfo.LAST_UPDATED_BY IS NULL) AND (p_LAST_UPDATED_BY IS NULL)))
 		AND ((Recinfo.CREATION_DATE = p_CREATION_DATE) OR ((Recinfo.CREATION_DATE IS NULL) AND (p_CREATION_DATE IS NULL)))
 		AND ((Recinfo.CREATED_BY = p_CREATED_BY) OR ((Recinfo.CREATED_BY IS NULL) AND (p_CREATED_BY IS NULL)))
 		AND ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN) OR ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND (p_LAST_UPDATE_LOGIN IS NULL)))
 		AND ((Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1) OR ((Recinfo.ATTRIBUTE1 IS NULL) AND (p_ATTRIBUTE1 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2) OR ((Recinfo.ATTRIBUTE2 IS NULL) AND (p_ATTRIBUTE2 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3) OR ((Recinfo.ATTRIBUTE3 IS NULL) AND (p_ATTRIBUTE3 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4) OR ((Recinfo.ATTRIBUTE4 IS NULL) AND (p_ATTRIBUTE4 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5) OR ((Recinfo.ATTRIBUTE5 IS NULL) AND (p_ATTRIBUTE5 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6) OR ((Recinfo.ATTRIBUTE6 IS NULL) AND (p_ATTRIBUTE6 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7) OR ((Recinfo.ATTRIBUTE7 IS NULL) AND (p_ATTRIBUTE7 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8) OR ((Recinfo.ATTRIBUTE8 IS NULL) AND (p_ATTRIBUTE8 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9) OR ((Recinfo.ATTRIBUTE9 IS NULL) AND (p_ATTRIBUTE9 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10) OR ((Recinfo.ATTRIBUTE10 IS NULL) AND (p_ATTRIBUTE10 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11) OR ((Recinfo.ATTRIBUTE11 IS NULL) AND (p_ATTRIBUTE11 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12) OR ((Recinfo.ATTRIBUTE12 IS NULL) AND (p_ATTRIBUTE12 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13) OR ((Recinfo.ATTRIBUTE13 IS NULL) AND (p_ATTRIBUTE13 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14) OR ((Recinfo.ATTRIBUTE14 IS NULL) AND (p_ATTRIBUTE14 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15) OR ((Recinfo.ATTRIBUTE15 IS NULL) AND (p_ATTRIBUTE15 IS NULL)))
 		AND ((Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY) OR ((Recinfo.ATTRIBUTE_CATEGORY IS NULL) AND (p_ATTRIBUTE_CATEGORY IS NULL)))
 		AND ((Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID) OR ((Recinfo.SECURITY_GROUP_ID IS NULL) AND (p_SECURITY_GROUP_ID IS NULL)))
 		AND ((Recinfo.MIGRATED_FLAG = p_MIGRATED_FLAG) OR ((Recinfo.MIGRATED_FLAG IS NULL) AND (p_MIGRATED_FLAG IS NULL)))
	    ) THEN
		RETURN;
   ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE Delete_Row(
	p_COUNTER_DERIVED_FILTER_ID        NUMBER
	) IS
BEGIN
	DELETE FROM CSI_COUNTER_DERIVED_FILTERS
	WHERE COUNTER_DERIVED_FILTER_ID = p_COUNTER_DERIVED_FILTER_ID;

   IF (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   END IF;
END Delete_Row;

End CSI_CTR_DERIVED_FILTERS_PKG;

/