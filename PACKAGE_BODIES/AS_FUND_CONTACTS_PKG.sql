--------------------------------------------------------
--  DDL for Package Body AS_FUND_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_FUND_CONTACTS_PKG" AS
/* $Header: asxiffcb.pls 115.4 2002/11/06 00:41:09 appldev ship $ */
-- Start of Comments
-- Package name     : AS_FUND_CONTACTS_PKG

G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AS_FUND_CONTACTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) 	:= 'asxiffcb.pls';

PROCEDURE insert_row(
    p_row_id             IN OUT VARCHAR2,
    p_fund_id            IN     NUMBER,
    p_party_id           IN     NUMBER,
    p_contact_role_code  IN     VARCHAR2,
    p_last_update_date   IN     DATE,
    p_last_updated_by    IN     NUMBER,
    p_creation_date      IN     DATE,
    p_created_by    	 IN     NUMBER,
    p_last_update_login  IN     NUMBER,
    p_attribute_category IN	  VARCHAR2,
    p_attribute1    	 IN	  VARCHAR2,
    p_attribute2    	 IN	  VARCHAR2,
    p_attribute3         IN     VARCHAR2,
    p_attribute4         IN     VARCHAR2,
    p_attribute5         IN     VARCHAR2,
    p_attribute6         IN     VARCHAR2,
    p_attribute7         IN     VARCHAR2,
    p_attribute8         IN     VARCHAR2,
    p_attribute9         IN     VARCHAR2,
    p_attribute10        IN     VARCHAR2,
    p_attribute11        IN     VARCHAR2,
    p_attribute12        IN     VARCHAR2,
    p_attribute13        IN     VARCHAR2,
    p_attribute14        IN     VARCHAR2,
    p_attribute15        IN     VARCHAR2) IS

BEGIN

    -- throw exception if data is null???
    INSERT INTO AS_FUND_CONTACTS (
        fund_id,
        party_id,
        contact_role_code,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15) VALUES
       (DECODE(p_fund_id, FND_API.G_MISS_NUM, NULL, p_fund_id),
        DECODE(p_party_id, FND_API.G_MISS_NUM, NULL, p_party_id),
        DECODE(p_contact_role_code, FND_API.G_MISS_CHAR, NULL, p_contact_role_code),
        DECODE(p_last_update_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_last_update_date),
        DECODE(p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
        DECODE(p_creation_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_creation_date),
        DECODE(p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by),
        DECODE(p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login),
        DECODE(p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
        DECODE(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
        DECODE(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
        DECODE(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
        DECODE(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
        DECODE(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
        DECODE(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
        DECODE(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
        DECODE(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
        DECODE(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
        DECODE(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
        DECODE(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
        DECODE(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
        DECODE(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
        DECODE(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
        DECODE(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15));

END insert_row;

PROCEDURE update_row (
    p_fund_id            IN NUMBER,
    p_party_id           IN NUMBER,
    p_contact_role_code  IN VARCHAR2,
    p_last_update_date   IN DATE,
    p_last_updated_by    IN NUMBER,
    p_creation_date      IN DATE,
    p_created_by         IN NUMBER,
    p_last_update_login  IN NUMBER,
    p_attribute_category IN VARCHAR2,
    p_attribute1    	 IN VARCHAR2,
    p_attribute2    	 IN VARCHAR2,
    p_attribute3         IN VARCHAR2,
    p_attribute4         IN VARCHAR2,
    p_attribute5         IN VARCHAR2,
    p_attribute6         IN VARCHAR2,
    p_attribute7         IN VARCHAR2,
    p_attribute8         IN VARCHAR2,
    p_attribute9         IN VARCHAR2,
    p_attribute10        IN VARCHAR2,
    p_attribute11        IN VARCHAR2,
    p_attribute12        IN VARCHAR2,
    p_attribute13        IN VARCHAR2,
    p_attribute14        IN VARCHAR2,
    p_attribute15        IN VARCHAR2) IS

BEGIN

    UPDATE AS_FUND_CONTACTS SET
        fund_id               = p_fund_id,
        party_id              = p_party_id,
        contact_role_code     = DECODE(p_contact_role_code, FND_API.G_MISS_CHAR, contact_role_code, p_contact_role_code),
        last_update_date      = DECODE(p_last_update_date, FND_API.G_MISS_DATE, last_update_date, p_last_update_date),
        last_updated_by       = DECODE(p_last_updated_by, FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by),
        creation_date         = DECODE(p_creation_date, FND_API.G_MISS_DATE, creation_date, p_creation_date),
        created_by            = DECODE(p_created_by, FND_API.G_MISS_NUM, created_by, p_created_by),
        last_update_login     = DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login),
        attribute1            = DECODE(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1),
        attribute2            = DECODE(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2),
        attribute3            = DECODE(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3),
        attribute4            = DECODE(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4),
        attribute5            = DECODE(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5),
        attribute6            = DECODE(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6),
        attribute7            = DECODE(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7),
        attribute8            = DECODE(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8),
        attribute9            = DECODE(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9),
        attribute10           = DECODE(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10),
        attribute11           = DECODE(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11),
        attribute12           = DECODE(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12),
        attribute13           = DECODE(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13),
        attribute14           = DECODE(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14),
        attribute15           = DECODE(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15),
        attribute_category    = DECODE(p_attribute_category, FND_API.G_MISS_CHAR, attribute_category, p_attribute_category)

    WHERE fund_id = p_fund_id
    AND party_id = p_party_id;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END update_row;

PROCEDURE delete_row   (
    p_fund_id IN NUMBER,
    p_party_id IN NUMBER) IS

BEGIN

    -- throw exception if data is null??
    DELETE FROM AS_FUND_CONTACTS
    WHERE fund_id = p_fund_id
    AND party_id = p_party_id;

    IF (SQL%NOTFOUND) THEN
        RAISE no_data_found;
    END IF;

END delete_row;
/*
PROCEDURE lock_row (
    p_fund_id               IN NUMBER,
    p_party_id              IN NUMBER,
    p_object_version_number IN NUMBER) IS

    CURSOR C IS SELECT object_version_number
                FROM AS_EXCHANGE_B
                WHERE fund_id = p_fund_id
                AND party_id = p_party_id
                AND object_version_number = p_object_version_number
                FOR UPDATE OF fund_id NOWAIT;

    recinfo C%rowtype;

BEGIN

    OPEN C;
    FETCH C INTO recinfo;
    IF (C%NOTFOUND) THEN
        CLOSE C;
        fnd_message.set_name('FND', 'FORM RECORD_DELETED');
        app_exception.raise_exception;
    END IF;
    CLOSE C;

    IF (recinfo.object_vesion_number = p_object_version_number) THEN
        NULL;
    ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
    END IF;

END lock_row;
*/
END AS_FUND_CONTACTS_PKG;

/
