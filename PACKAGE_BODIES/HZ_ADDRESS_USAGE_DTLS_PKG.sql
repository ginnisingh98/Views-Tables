--------------------------------------------------------
--  DDL for Package Body HZ_ADDRESS_USAGE_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADDRESS_USAGE_DTLS_PKG" AS
/*$Header: ARHGNRTB.pls 120.1 2005/08/26 17:54:23 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_dtl_id                          IN OUT NOCOPY NUMBER,
    x_usage_id                              IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

--    WHILE l_success = 'N' LOOP
--    BEGIN
      INSERT INTO HZ_ADDRESS_USAGE_DTLS (
        usage_dtl_id,
        usage_id,
        geography_type,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        object_version_number,
        created_by_module,
        application_id
      )
      VALUES (
        DECODE(x_usage_dtl_id,
               FND_API.G_MISS_NUM, HZ_ADDRESS_USAGE_DTLS_S.NEXTVAL,
               NULL, HZ_ADDRESS_USAGE_DTLS_S.NEXTVAL,
               x_usage_dtl_id),
        DECODE(x_usage_id,
               FND_API.G_MISS_NUM, NULL,
               x_usage_id),
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login,
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        DECODE(x_application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id)
      ) RETURNING
        rowid,
        usage_dtl_id
      INTO
        x_rowid,
        x_usage_dtl_id;
/*
      l_success := 'Y';

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_ADDRESS_USAGE_DTLS_U1') <> 0 THEN
        DECLARE
          l_count             NUMBER;
          l_dummy             VARCHAR2(1);
        BEGIN
          l_count := 1;
          WHILE l_count > 0 LOOP
            SELECT HZ_ADDRESS_USAGE_DTLS_S.NEXTVAL
            INTO x_usage_dtl_id FROM dual;
            BEGIN
              SELECT 'Y' INTO l_dummy
              FROM HZ_ADDRESS_USAGE_DTLS
              WHERE usage_dtl_id = x_usage_dtl_id;
              l_count := 1;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_count := 0;
            END;
          END LOOP;
        END;
        END IF;

    END;
    END LOOP;
*/
END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_dtl_id                          IN     NUMBER,
    x_usage_id                              IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
) IS
BEGIN

    UPDATE HZ_ADDRESS_USAGE_DTLS
    SET
      usage_dtl_id =
        DECODE(x_usage_dtl_id,
               NULL, usage_dtl_id,
               FND_API.G_MISS_NUM, NULL,
               x_usage_dtl_id),
      usage_id =
        DECODE(x_usage_id,
               NULL, usage_id,
               FND_API.G_MISS_NUM, NULL,
               x_usage_id),
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
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
      application_id =
        DECODE(x_application_id,
               NULL, application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id)
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_usage_dtl_id                          IN     NUMBER,
    x_usage_id                              IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_address_usage_dtls
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
        ( ( Recinfo.usage_dtl_id = x_usage_dtl_id )
        OR ( ( Recinfo.usage_dtl_id IS NULL )
          AND (  x_usage_dtl_id IS NULL ) ) )
    AND ( ( Recinfo.usage_id = x_usage_id )
        OR ( ( Recinfo.usage_id IS NULL )
          AND (  x_usage_id IS NULL ) ) )
    AND ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
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
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_usage_dtl_id                          IN OUT NOCOPY NUMBER,
    x_usage_id                              OUT    NOCOPY NUMBER,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(usage_dtl_id, FND_API.G_MISS_NUM),
      NVL(usage_id, FND_API.G_MISS_NUM),
      NVL(geography_type, FND_API.G_MISS_CHAR),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM)
    INTO
      x_usage_dtl_id,
      x_usage_id,
      x_geography_type,
      x_created_by_module,
      x_application_id
    FROM HZ_ADDRESS_USAGE_DTLS
    WHERE usage_dtl_id = x_usage_dtl_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'address_usage_dtls_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_usage_dtl_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_usage_dtl_id                          IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_ADDRESS_USAGE_DTLS
    WHERE usage_dtl_id = x_usage_dtl_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_ADDRESS_USAGE_DTLS_PKG;

/
