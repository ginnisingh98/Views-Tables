--------------------------------------------------------
--  DDL for Package Body HZ_DSS_SCHEME_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_SCHEME_FUNCTIONS_PKG" AS
/* $Header: ARHPDSFB.pls 115.1 2002/09/30 06:26:02 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_security_scheme_code                  IN     VARCHAR2,
    x_data_operation_code                   IN     VARCHAR2,
    x_function_id                           IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_DSS_SCHEME_FUNCTIONS (
        security_scheme_code,
        data_operation_code,
        function_id,
        status,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number
      )
      VALUES (
        DECODE(x_security_scheme_code,
               FND_API.G_MISS_CHAR, NULL,
               x_security_scheme_code),
        DECODE(x_data_operation_code,
               FND_API.G_MISS_CHAR, NULL,
               x_data_operation_code),
        DECODE(x_function_id,
               FND_API.G_MISS_NUM, NULL,
               x_function_id),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_login,
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number)
      ) RETURNING
        rowid
      INTO
        x_rowid;

      l_success := 'Y';


    END;
    END LOOP;

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
  --x_security_scheme_code                  IN     VARCHAR2,
  --x_data_operation_code                   IN     VARCHAR2,
  --x_function_id                           IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS
BEGIN

    UPDATE HZ_DSS_SCHEME_FUNCTIONS
    SET
      /*
      security_scheme_code =
        DECODE(x_security_scheme_code,
               NULL, security_scheme_code,
               FND_API.G_MISS_CHAR, NULL,
               x_security_scheme_code),
      data_operation_code =
        DECODE(x_data_operation_code,
               NULL, data_operation_code,
               FND_API.G_MISS_CHAR, NULL,
               x_data_operation_code),
      function_id =
        DECODE(x_function_id,
               NULL, function_id,
               FND_API.G_MISS_NUM, NULL,
               x_function_id),
      */
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
      last_update_date = hz_utility_v2pub.last_update_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      creation_date = creation_date,
      created_by = created_by,
      last_update_login = hz_utility_v2pub.last_update_login,
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number)
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_security_scheme_code                  IN     VARCHAR2,
    x_data_operation_code                   IN     VARCHAR2,
    x_function_id                           IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_dss_scheme_functions
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
        ( ( Recinfo.security_scheme_code = x_security_scheme_code )
        OR ( ( Recinfo.security_scheme_code IS NULL )
          AND (  x_security_scheme_code IS NULL ) ) )
    AND ( ( Recinfo.data_operation_code = x_data_operation_code )
        OR ( ( Recinfo.data_operation_code IS NULL )
          AND (  x_data_operation_code IS NULL ) ) )
    AND ( ( Recinfo.function_id = x_function_id )
        OR ( ( Recinfo.function_id IS NULL )
          AND (  x_function_id IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_security_scheme_code                  IN           VARCHAR2,
    x_data_operation_code                   IN           VARCHAR2,
    x_function_id                           IN            NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(status, FND_API.G_MISS_CHAR)
    INTO
       x_status
    FROM HZ_DSS_SCHEME_FUNCTIONS
    WHERE security_scheme_code = x_security_scheme_code
          AND data_operation_code = x_data_operation_code
          AND function_id = x_function_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'dss_entity_profile');
      FND_MESSAGE.SET_TOKEN('VALUE', x_security_scheme_code);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_security_scheme_code                  IN     VARCHAR2,
    x_data_operation_code                   IN     VARCHAR2,
    x_function_id                           IN      NUMBER
) IS
BEGIN

    DELETE FROM HZ_DSS_SCHEME_FUNCTIONS
    WHERE security_scheme_code = x_security_scheme_code
          AND data_operation_code = x_data_operation_code
          AND function_id = x_function_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_DSS_SCHEME_FUNCTIONS_PKG;

/
