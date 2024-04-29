--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_IDENTIFIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_IDENTIFIERS_PKG" AS
/*$Header: ARHGIDTB.pls 115.2 2003/02/19 00:26:53 smattegu noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN  NUMBER,
    x_identifier_subtype                       IN     VARCHAR2,
    x_identifier_value                      IN     VARCHAR2,
    x_geo_data_provider                     IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_identifier_type                   IN     VARCHAR2,
    x_primary_flag                          IN     VARCHAR2,
    x_language_code                         IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_geography_type                        IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS


BEGIN
   --dbms_output.put_line.PUT_LINE('before  identifier insert in tblhandler');
   --dbms_output.put_line.PUT_LINE('geography_id '||to_char(x_geography_id)||',subtype '||x_identifier_subtype||',value '||x_identifier_value ||',provider '||x_geo_data_provider||', version '||to_char(x_object_version_number));
   --dbms_output.put_line.PUT_LINE('type '||x_identifier_type||',p_flag '||x_primary_flag||',use '||x_geography_use|| ',geo_type '||x_geography_type);

      INSERT INTO HZ_GEOGRAPHY_IDENTIFIERS (
        geography_id,
        identifier_subtype,
        identifier_value,
        geo_data_provider,
        object_version_number,
        identifier_type,
        primary_flag,
        language_code,
        geography_use,
        geography_type,
        created_by_module,
        last_updated_by,
        creation_date,
        created_by,
        last_update_date,
        last_update_login,
        application_id,
        program_id,
        program_login_id,
        program_application_id,
        request_id
      )
      VALUES (
        DECODE(x_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_id),
        DECODE(x_identifier_subtype,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_subtype),
        DECODE(x_identifier_value,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_value),
        DECODE(x_geo_data_provider,
               FND_API.G_MISS_CHAR, NULL,
               x_geo_data_provider),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_identifier_type,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_type),
        DECODE(x_primary_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_primary_flag),
        DECODE(x_language_code,
               FND_API.G_MISS_CHAR, NULL,
               x_language_code),
        DECODE(x_geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login,
        DECODE(x_application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
        hz_utility_v2pub.program_id,
        DECODE(x_program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.request_id
      ) RETURNING
        rowid
      INTO
        x_rowid;

     --dbms_output.put_line.PUT_LINE('after identifier insert in tblhandler rowid is '||x_rowid);

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_identifier_subtype                       IN     VARCHAR2,
    x_identifier_value                      IN     VARCHAR2,
    x_geo_data_provider                     IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_identifier_type                   IN     VARCHAR2,
    x_primary_flag                          IN     VARCHAR2,
    x_language_code                         IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_geography_type                        IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS
BEGIN

    UPDATE HZ_GEOGRAPHY_IDENTIFIERS
    SET
      geography_id =
        DECODE(x_geography_id,
               NULL, geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_id),
      identifier_subtype =
        DECODE(x_identifier_subtype,
               NULL, identifier_subtype,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_subtype),
      identifier_value =
        DECODE(x_identifier_value,
               NULL, identifier_value,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_value),
      geo_data_provider =
        DECODE(x_geo_data_provider,
               NULL, geo_data_provider,
               FND_API.G_MISS_CHAR, NULL,
               x_geo_data_provider),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      identifier_type =
        DECODE(x_identifier_type,
               NULL, identifier_type,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_type),
      primary_flag =
        DECODE(x_primary_flag,
               NULL, primary_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_primary_flag),
      language_code =
        DECODE(x_language_code,
               NULL, language_code,
               FND_API.G_MISS_CHAR, NULL,
               x_language_code),
      geography_use =
        DECODE(x_geography_use,
               NULL, geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
      created_by_module =
        DECODE(x_created_by_module,
               NULL, created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
      last_updated_by = hz_utility_v2pub.last_updated_by,
      creation_date = creation_date,
      created_by = created_by,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      application_id =
        DECODE(x_application_id,
               NULL, application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
      program_id = hz_utility_v2pub.program_id,
      program_login_id =
        DECODE(x_program_login_id,
               NULL, program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
      program_application_id = hz_utility_v2pub.program_application_id,
      request_id = hz_utility_v2pub.request_id
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_identifier_subtype                       IN     VARCHAR2,
    x_identifier_value                      IN     VARCHAR2,
    x_geo_data_provider                     IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_identifier_type                   IN     VARCHAR2,
    x_primary_flag                          IN     VARCHAR2,
    x_language_code                         IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_geography_type                        IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_application_id                        IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_request_id                            IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_geography_identifiers
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
        ( ( Recinfo.geography_id = x_geography_id )
        OR ( ( Recinfo.geography_id IS NULL )
          AND (  x_geography_id IS NULL ) ) )
    AND ( ( Recinfo.identifier_subtype = x_identifier_subtype )
        OR ( ( Recinfo.identifier_subtype IS NULL )
          AND (  x_identifier_subtype IS NULL ) ) )
    AND ( ( Recinfo.identifier_value = x_identifier_value )
        OR ( ( Recinfo.identifier_value IS NULL )
          AND (  x_identifier_value IS NULL ) ) )
    AND ( ( Recinfo.geo_data_provider = x_geo_data_provider )
        OR ( ( Recinfo.geo_data_provider IS NULL )
          AND (  x_geo_data_provider IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.identifier_type = x_identifier_type )
        OR ( ( Recinfo.identifier_type IS NULL )
          AND (  x_identifier_type IS NULL ) ) )
    AND ( ( Recinfo.primary_flag = x_primary_flag )
        OR ( ( Recinfo.primary_flag IS NULL )
          AND (  x_primary_flag IS NULL ) ) )
    AND ( ( Recinfo.language_code = x_language_code )
        OR ( ( Recinfo.language_code IS NULL )
          AND (  x_language_code IS NULL ) ) )
    AND ( ( Recinfo.geography_use = x_geography_use )
        OR ( ( Recinfo.geography_use IS NULL )
          AND (  x_geography_use IS NULL ) ) )
    AND ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.program_id = x_program_id )
        OR ( ( Recinfo.program_id IS NULL )
          AND (  x_program_id IS NULL ) ) )
    AND ( ( Recinfo.program_login_id = x_program_login_id )
        OR ( ( Recinfo.program_login_id IS NULL )
          AND (  x_program_login_id IS NULL ) ) )
    AND ( ( Recinfo.program_application_id = x_program_application_id )
        OR ( ( Recinfo.program_application_id IS NULL )
          AND (  x_program_application_id IS NULL ) ) )
    AND ( ( Recinfo.request_id = x_request_id )
        OR ( ( Recinfo.request_id IS NULL )
          AND (  x_request_id IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_geography_id                          IN OUT NOCOPY NUMBER,
    x_identifier_subtype                       IN OUT    NOCOPY VARCHAR2,
    x_identifier_value                      IN OUT    NOCOPY VARCHAR2,
    x_geo_data_provider                     IN OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_identifier_type                   IN  OUT   NOCOPY VARCHAR2,
    x_primary_flag                          OUT    NOCOPY VARCHAR2,
    x_language_code                         OUT    NOCOPY VARCHAR2,
    x_geography_use                         OUT    NOCOPY VARCHAR2,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(geography_id, FND_API.G_MISS_NUM),
      NVL(identifier_subtype, FND_API.G_MISS_CHAR),
      NVL(identifier_value, FND_API.G_MISS_CHAR),
      NVL(geo_data_provider, FND_API.G_MISS_CHAR),
      NVL(identifier_type, FND_API.G_MISS_CHAR),
      NVL(primary_flag, FND_API.G_MISS_CHAR),
      NVL(language_code, FND_API.G_MISS_CHAR),
      NVL(geography_use, FND_API.G_MISS_CHAR),
      NVL(geography_type, FND_API.G_MISS_CHAR),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(program_login_id, FND_API.G_MISS_NUM)
    INTO
      x_geography_id,
      x_identifier_subtype,
      x_identifier_value,
      x_geo_data_provider,
      x_identifier_type,
      x_primary_flag,
      x_language_code,
      x_geography_use,
      x_geography_type,
      x_created_by_module,
      x_application_id,
      x_program_login_id
    FROM HZ_GEOGRAPHY_IDENTIFIERS
    WHERE geography_id = x_geography_id
      AND identifier_subtype = x_identifier_subtype
      AND identifier_value = x_identifier_value
      AND language_code = x_language_code
      AND identifier_type = x_identifier_type;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'geography_identifiers_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_geography_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_geography_id                          IN     NUMBER,
    x_identifier_subtype                    IN     VARCHAR2,
    x_identifier_value                      IN     VARCHAR2,
    x_language_code                         IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2
   ) IS
BEGIN

    DELETE FROM HZ_GEOGRAPHY_IDENTIFIERS
    WHERE geography_id = x_geography_id
      AND identifier_subtype = x_identifier_subtype
      AND identifier_value = x_identifier_value
      AND language_code = x_language_code
      AND identifier_type = x_identifier_type;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_GEOGRAPHY_IDENTIFIERS_PKG;

/
