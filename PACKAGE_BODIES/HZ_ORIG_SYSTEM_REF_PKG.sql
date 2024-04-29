--------------------------------------------------------
--  DDL for Package Body HZ_ORIG_SYSTEM_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORIG_SYSTEM_REF_PKG" AS
/*$Header: ARHOSRTB.pls 120.6 2006/12/14 22:16:27 awu noship $ */

PROCEDURE Insert_Row (
    x_orig_system_ref_id                    IN OUT NOCOPY NUMBER,
    x_orig_system                           IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
--raji
    x_party_id                              IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_reason_code                           IN     VARCHAR2,
    x_old_orig_system_reference              IN     VARCHAR2,
    x_start_date_active                     IN     DATE,
    x_end_date_active                       IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2
) IS

BEGIN

    IF x_orig_system_ref_id = FND_API.G_MISS_NUM THEN
      x_orig_system_ref_id := NULL;
    END IF;

    INSERT INTO HZ_ORIG_SYS_REFERENCES (
        orig_system_ref_id,
        orig_system,
        orig_system_reference,
        owner_table_name,
        owner_table_id,
--raji
        party_id,
        status,
        reason_code,
        old_orig_system_reference,
        start_date_active,
        end_date_active,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        object_version_number,
        created_by_module,
        application_id,
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
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
      )
      VALUES (
        DECODE(x_orig_system_ref_id,
               FND_API.G_MISS_NUM, HZ_ORIG_SYSTEM_REF_S.NEXTVAL,
               NULL, HZ_ORIG_SYSTEM_REF_S.NEXTVAL,
               x_orig_system_ref_id),
        DECODE(x_orig_system,
               FND_API.G_MISS_CHAR, NULL,
               x_orig_system),
        DECODE(x_orig_system_reference,
               FND_API.G_MISS_CHAR, NULL,
               x_orig_system_reference),
        DECODE(x_owner_table_name,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_name),
        DECODE(x_owner_table_id,
               FND_API.G_MISS_NUM, NULL,
               x_owner_table_id),
--raji
        DECODE(x_party_id,
               FND_API.G_MISS_NUM,NULL,
               x_party_id),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        DECODE(x_reason_code,
               FND_API.G_MISS_CHAR, NULL,
               x_reason_code),
        DECODE(x_old_orig_system_reference,
               FND_API.G_MISS_CHAR, NULL,
               x_old_orig_system_reference),
        DECODE(x_start_date_active,
               FND_API.G_MISS_DATE, SYSDATE,TO_DATE(NULL), SYSDATE,
               x_start_date_active),
        DECODE(x_end_date_active,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_end_date_active),
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login,
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, 'MOSR',NULL, 'MOSR',
               x_created_by_module),
        hz_utility_v2pub.application_id,
        DECODE(x_attribute_category,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute_category),
        DECODE(x_attribute1,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute1),
        DECODE(x_attribute2,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute2),
        DECODE(x_attribute3,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute3),
        DECODE(x_attribute4,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute4),
        DECODE(x_attribute5,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute5),
        DECODE(x_attribute6,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute6),
        DECODE(x_attribute7,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute7),
        DECODE(x_attribute8,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute8),
        DECODE(x_attribute9,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute9),
        DECODE(x_attribute10,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute10),
        DECODE(x_attribute11,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute11),
        DECODE(x_attribute12,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute12),
        DECODE(x_attribute13,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute13),
        DECODE(x_attribute14,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute14),
        DECODE(x_attribute15,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute15),
        DECODE(x_attribute16,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute16),
        DECODE(x_attribute17,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute17),
        DECODE(x_attribute18,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute18),
        DECODE(x_attribute19,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute19),
        DECODE(x_attribute20,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute20)
      ) returning orig_system_ref_id into x_orig_system_ref_id;

END Insert_Row;

PROCEDURE Update_Row (
    x_orig_system_ref_id                    IN     NUMBER,
    x_orig_system                           IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
--raji
    x_party_id                              IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_reason_code                           IN     VARCHAR2,
    x_old_orig_system_reference              IN     VARCHAR2,
    x_start_date_active                     IN     DATE,
    x_end_date_active                       IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2
) IS
BEGIN

    UPDATE HZ_ORIG_SYS_REFERENCES
    SET
      orig_system_ref_id =
        DECODE(x_orig_system_ref_id,
               NULL, orig_system_ref_id,
               FND_API.G_MISS_NUM, NULL,
               x_orig_system_ref_id),
      orig_system =
        DECODE(x_orig_system,
               NULL, orig_system,
               FND_API.G_MISS_CHAR, NULL,
               x_orig_system),
      orig_system_reference =
        DECODE(x_orig_system_reference,
               NULL, orig_system_reference,
               FND_API.G_MISS_CHAR, NULL,
               x_orig_system_reference),
      owner_table_name =
        DECODE(x_owner_table_name,
               NULL, owner_table_name,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_name),
      owner_table_id =
        DECODE(x_owner_table_id,
               NULL, owner_table_id,
               FND_API.G_MISS_NUM, NULL,
               x_owner_table_id),
--raji
      party_id =
        DECODE(x_party_id,
               NULL,party_id,
               FND_API.G_MISS_NUM, NULL,
               x_party_id),
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
      reason_code =
        DECODE(x_reason_code,
               NULL, reason_code,
               FND_API.G_MISS_CHAR, NULL,
               x_reason_code),
      old_orig_system_reference =
        DECODE(x_old_orig_system_reference,
               NULL, old_orig_system_reference,
               FND_API.G_MISS_CHAR, NULL,
               x_old_orig_system_reference),
      start_date_active =
        DECODE(x_start_date_active,
               NULL, start_date_active,
               FND_API.G_MISS_DATE, NULL,
               x_start_date_active),
      end_date_active =
        DECODE(x_end_date_active,
               NULL, end_date_active,
               FND_API.G_MISS_DATE, NULL,
               x_end_date_active),
      created_by = created_by,
      creation_date = creation_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      created_by_module =
        DECODE(x_created_by_module,
               NULL, created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
      application_id = hz_utility_v2pub.application_id,
      attribute_category =
        DECODE(x_attribute_category,
               NULL, attribute_category,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute_category),
      attribute1 =
        DECODE(x_attribute1,
               NULL, attribute1,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute1),
      attribute2 =
        DECODE(x_attribute2,
               NULL, attribute2,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute2),
      attribute3 =
        DECODE(x_attribute3,
               NULL, attribute3,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute3),
      attribute4 =
        DECODE(x_attribute4,
               NULL, attribute4,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute4),
      attribute5 =
        DECODE(x_attribute5,
               NULL, attribute5,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute5),
      attribute6 =
        DECODE(x_attribute6,
               NULL, attribute6,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute6),
      attribute7 =
        DECODE(x_attribute7,
               NULL, attribute7,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute7),
      attribute8 =
        DECODE(x_attribute8,
               NULL, attribute8,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute8),
      attribute9 =
        DECODE(x_attribute9,
               NULL, attribute9,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute9),
      attribute10 =
        DECODE(x_attribute10,
               NULL, attribute10,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute10),
      attribute11 =
        DECODE(x_attribute11,
               NULL, attribute11,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute11),
      attribute12 =
        DECODE(x_attribute12,
               NULL, attribute12,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute12),
      attribute13 =
        DECODE(x_attribute13,
               NULL, attribute13,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute13),
      attribute14 =
        DECODE(x_attribute14,
               NULL, attribute14,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute14),
      attribute15 =
        DECODE(x_attribute15,
               NULL, attribute15,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute15),
      attribute16 =
        DECODE(x_attribute16,
               NULL, attribute16,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute16),
      attribute17 =
        DECODE(x_attribute17,
               NULL, attribute17,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute17),
      attribute18 =
        DECODE(x_attribute18,
               NULL, attribute18,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute18),
      attribute19 =
        DECODE(x_attribute19,
               NULL, attribute19,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute19),
      attribute20 =
        DECODE(x_attribute20,
               NULL, attribute20,
               FND_API.G_MISS_CHAR, NULL,
               x_attribute20)
    WHERE ORIG_SYSTEM_REF_ID = X_ORIG_SYSTEM_REF_ID;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_orig_system_ref_id                    IN     NUMBER,
    x_orig_system                           IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
--raji
    x_party_id                              IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_reason_code                           IN     VARCHAR2,
    x_old_orig_system_reference              IN     VARCHAR2,
    x_start_date_active                     IN     DATE,
    x_end_date_active                       IN     DATE,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2
) IS

    CURSOR c IS
      SELECT * FROM HZ_ORIG_SYS_REFERENCES
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

BEGIN

    OPEN c;
    FETCH c INTO Recinfo;
    IF ( c%NOTFOUND ) THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.orig_system_ref_id = x_orig_system_ref_id )
        OR ( ( Recinfo.orig_system_ref_id IS NULL )
          AND (  x_orig_system_ref_id IS NULL ) ) )
    AND ( ( Recinfo.orig_system = x_orig_system )
        OR ( ( Recinfo.orig_system IS NULL )
          AND (  x_orig_system IS NULL ) ) )
    AND ( ( Recinfo.orig_system_reference = x_orig_system_reference )
        OR ( ( Recinfo.orig_system_reference IS NULL )
          AND (  x_orig_system_reference IS NULL ) ) )
    AND ( ( Recinfo.owner_table_name = x_owner_table_name )
        OR ( ( Recinfo.owner_table_name IS NULL )
          AND (  x_owner_table_name IS NULL ) ) )
    AND ( ( Recinfo.owner_table_id = x_owner_table_id )
        OR ( ( Recinfo.owner_table_id IS NULL )
          AND (  x_owner_table_id IS NULL ) ) )
--raji
    AND ( ( Recinfo.party_id = x_party_id )
        OR ( ( Recinfo.party_id IS NULL )
         AND ( x_party_id IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.reason_code = x_reason_code )
        OR ( ( Recinfo.reason_code IS NULL )
          AND (  x_reason_code IS NULL ) ) )
    AND ( ( Recinfo.old_orig_system_reference = x_old_orig_system_reference )
        OR ( ( Recinfo.old_orig_system_reference IS NULL )
          AND (  x_old_orig_system_reference IS NULL ) ) )
    AND ( ( Recinfo.start_date_active = x_start_date_active )
        OR ( ( Recinfo.start_date_active IS NULL )
          AND (  x_start_date_active IS NULL ) ) )
    AND ( ( Recinfo.end_date_active = x_end_date_active )
        OR ( ( Recinfo.end_date_active IS NULL )
          AND (  x_end_date_active IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.attribute_category = x_attribute_category )
        OR ( ( Recinfo.attribute_category IS NULL )
          AND (  x_attribute_category IS NULL ) ) )
    AND ( ( Recinfo.attribute1 = x_attribute1 )
        OR ( ( Recinfo.attribute1 IS NULL )
          AND (  x_attribute1 IS NULL ) ) )
    AND ( ( Recinfo.attribute2 = x_attribute2 )
        OR ( ( Recinfo.attribute2 IS NULL )
          AND (  x_attribute2 IS NULL ) ) )
    AND ( ( Recinfo.attribute3 = x_attribute3 )
        OR ( ( Recinfo.attribute3 IS NULL )
          AND (  x_attribute3 IS NULL ) ) )
    AND ( ( Recinfo.attribute4 = x_attribute4 )
        OR ( ( Recinfo.attribute4 IS NULL )
          AND (  x_attribute4 IS NULL ) ) )
    AND ( ( Recinfo.attribute5 = x_attribute5 )
        OR ( ( Recinfo.attribute5 IS NULL )
          AND (  x_attribute5 IS NULL ) ) )
    AND ( ( Recinfo.attribute6 = x_attribute6 )
        OR ( ( Recinfo.attribute6 IS NULL )
          AND (  x_attribute6 IS NULL ) ) )
    AND ( ( Recinfo.attribute7 = x_attribute7 )
        OR ( ( Recinfo.attribute7 IS NULL )
          AND (  x_attribute7 IS NULL ) ) )
    AND ( ( Recinfo.attribute8 = x_attribute8 )
        OR ( ( Recinfo.attribute8 IS NULL )
          AND (  x_attribute8 IS NULL ) ) )
    AND ( ( Recinfo.attribute9 = x_attribute9 )
        OR ( ( Recinfo.attribute9 IS NULL )
          AND (  x_attribute9 IS NULL ) ) )
    AND ( ( Recinfo.attribute10 = x_attribute10 )
        OR ( ( Recinfo.attribute10 IS NULL )
          AND (  x_attribute10 IS NULL ) ) )
    AND ( ( Recinfo.attribute11 = x_attribute11 )
        OR ( ( Recinfo.attribute11 IS NULL )
          AND (  x_attribute11 IS NULL ) ) )
    AND ( ( Recinfo.attribute12 = x_attribute12 )
        OR ( ( Recinfo.attribute12 IS NULL )
          AND (  x_attribute12 IS NULL ) ) )
    AND ( ( Recinfo.attribute13 = x_attribute13 )
        OR ( ( Recinfo.attribute13 IS NULL )
          AND (  x_attribute13 IS NULL ) ) )
    AND ( ( Recinfo.attribute14 = x_attribute14 )
        OR ( ( Recinfo.attribute14 IS NULL )
          AND (  x_attribute14 IS NULL ) ) )
    AND ( ( Recinfo.attribute15 = x_attribute15 )
        OR ( ( Recinfo.attribute15 IS NULL )
          AND (  x_attribute15 IS NULL ) ) )
    AND ( ( Recinfo.attribute16 = x_attribute16 )
        OR ( ( Recinfo.attribute16 IS NULL )
          AND (  x_attribute16 IS NULL ) ) )
    AND ( ( Recinfo.attribute17 = x_attribute17 )
        OR ( ( Recinfo.attribute17 IS NULL )
          AND (  x_attribute17 IS NULL ) ) )
    AND ( ( Recinfo.attribute18 = x_attribute18 )
        OR ( ( Recinfo.attribute18 IS NULL )
          AND (  x_attribute18 IS NULL ) ) )
    AND ( ( Recinfo.attribute19 = x_attribute19 )
        OR ( ( Recinfo.attribute19 IS NULL )
          AND (  x_attribute19 IS NULL ) ) )
    AND ( ( Recinfo.attribute20 = x_attribute20 )
        OR ( ( Recinfo.attribute20 IS NULL )
          AND (  x_attribute20 IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_orig_system_ref_id                    IN OUT NOCOPY NUMBER,
    x_orig_system                           OUT    NOCOPY VARCHAR2,
    x_orig_system_reference                 OUT    NOCOPY VARCHAR2,
    x_owner_table_name                      OUT    NOCOPY VARCHAR2,
    x_owner_table_id                        OUT    NOCOPY NUMBER,
--raji
    x_party_id                              OUT    NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_reason_code                           OUT    NOCOPY VARCHAR2,
    x_old_orig_system_reference              OUT    NOCOPY VARCHAR2,
    x_start_date_active                     OUT    NOCOPY DATE,
    x_end_date_active                       OUT    NOCOPY DATE,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_attribute_category                    OUT    NOCOPY VARCHAR2,
    x_attribute1                            OUT    NOCOPY VARCHAR2,
    x_attribute2                            OUT    NOCOPY VARCHAR2,
    x_attribute3                            OUT    NOCOPY VARCHAR2,
    x_attribute4                            OUT    NOCOPY VARCHAR2,
    x_attribute5                            OUT    NOCOPY VARCHAR2,
    x_attribute6                            OUT    NOCOPY VARCHAR2,
    x_attribute7                            OUT    NOCOPY VARCHAR2,
    x_attribute8                            OUT    NOCOPY VARCHAR2,
    x_attribute9                            OUT    NOCOPY VARCHAR2,
    x_attribute10                           OUT    NOCOPY VARCHAR2,
    x_attribute11                           OUT    NOCOPY VARCHAR2,
    x_attribute12                           OUT    NOCOPY VARCHAR2,
    x_attribute13                           OUT    NOCOPY VARCHAR2,
    x_attribute14                           OUT    NOCOPY VARCHAR2,
    x_attribute15                           OUT    NOCOPY VARCHAR2,
    x_attribute16                           OUT    NOCOPY VARCHAR2,
    x_attribute17                           OUT    NOCOPY VARCHAR2,
    x_attribute18                           OUT    NOCOPY VARCHAR2,
    x_attribute19                           OUT    NOCOPY VARCHAR2,
    x_attribute20                           OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(orig_system_ref_id, FND_API.G_MISS_NUM),
      NVL(orig_system, FND_API.G_MISS_CHAR),
      NVL(orig_system_reference, FND_API.G_MISS_CHAR),
      NVL(owner_table_name, FND_API.G_MISS_CHAR),
      NVL(owner_table_id, FND_API.G_MISS_NUM),
--raji
      NVL(party_id,FND_API.G_MISS_NUM),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(reason_code, FND_API.G_MISS_CHAR),
      NVL(old_orig_system_reference, FND_API.G_MISS_CHAR),
      NVL(start_date_active, FND_API.G_MISS_DATE),
      NVL(end_date_active, FND_API.G_MISS_DATE),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(attribute_category, FND_API.G_MISS_CHAR),
      NVL(attribute1, FND_API.G_MISS_CHAR),
      NVL(attribute2, FND_API.G_MISS_CHAR),
      NVL(attribute3, FND_API.G_MISS_CHAR),
      NVL(attribute4, FND_API.G_MISS_CHAR),
      NVL(attribute5, FND_API.G_MISS_CHAR),
      NVL(attribute6, FND_API.G_MISS_CHAR),
      NVL(attribute7, FND_API.G_MISS_CHAR),
      NVL(attribute8, FND_API.G_MISS_CHAR),
      NVL(attribute9, FND_API.G_MISS_CHAR),
      NVL(attribute10, FND_API.G_MISS_CHAR),
      NVL(attribute11, FND_API.G_MISS_CHAR),
      NVL(attribute12, FND_API.G_MISS_CHAR),
      NVL(attribute13, FND_API.G_MISS_CHAR),
      NVL(attribute14, FND_API.G_MISS_CHAR),
      NVL(attribute15, FND_API.G_MISS_CHAR),
      NVL(attribute16, FND_API.G_MISS_CHAR),
      NVL(attribute17, FND_API.G_MISS_CHAR),
      NVL(attribute18, FND_API.G_MISS_CHAR),
      NVL(attribute19, FND_API.G_MISS_CHAR),
      NVL(attribute20, FND_API.G_MISS_CHAR)
    INTO
      x_orig_system_ref_id,
      x_orig_system,
      x_orig_system_reference,
      x_owner_table_name,
      x_owner_table_id,
--raji
      x_party_id,
      x_status,
      x_reason_code,
      x_old_orig_system_reference,
      x_start_date_active,
      x_end_date_active,
      x_created_by_module,
      x_application_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20
    FROM HZ_ORIG_SYS_REFERENCES
    WHERE orig_system_ref_id = x_orig_system_ref_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'orig_sys_reference_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_orig_system_ref_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_orig_system_ref_id                    IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_ORIG_SYS_REFERENCES
    WHERE orig_system_ref_id = x_orig_system_ref_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_ORIG_SYSTEM_REF_PKG;

/
