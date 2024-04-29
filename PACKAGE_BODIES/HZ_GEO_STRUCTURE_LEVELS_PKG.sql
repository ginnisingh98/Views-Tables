--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCTURE_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCTURE_LEVELS_PKG" AS
/*$Header: ARHGSTTB.pls 120.1 2005/07/28 02:05:31 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN  NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_relationship_type_id                  IN     NUMBER,
    x_country_code                          IN     VARCHAR2,
    x_geography_element_column              IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
    x_addr_val_level                        IN     VARCHAR2
) IS


BEGIN

   --dbms_output.put_line.PUT_LINE('relationship_type_id is '||to_char(x_relationship_type_id));

      INSERT INTO HZ_GEO_STRUCTURE_LEVELS (
        geography_id,
        geography_type,
        parent_geography_type,
        object_version_number,
        relationship_type_id,
        country_code,
        geography_element_column,
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
        request_id,
        addr_val_level
      )
      VALUES (
        DECODE(x_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_id),
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        DECODE(x_parent_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_geography_type),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_relationship_type_id,
               FND_API.G_MISS_NUM, NULL,
               x_relationship_type_id),
        DECODE(x_country_code,
               FND_API.G_MISS_CHAR, NULL,
               x_country_code),
        DECODE(x_geography_element_column,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element_column),
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
        hz_utility_v2pub.request_id,
        DECODE(x_addr_val_level,
               FND_API.G_MISS_CHAR, NULL,
               x_addr_val_level)
      ) RETURNING
        rowid
      INTO
        x_rowid;

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_relationship_type_id                  IN     NUMBER,
    x_country_code                          IN     VARCHAR2,
    x_geography_element_column              IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS
BEGIN

    UPDATE HZ_GEO_STRUCTURE_LEVELS
    SET
      geography_id =
        DECODE(x_geography_id,
               NULL, geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_id),
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
      parent_geography_type =
        DECODE(x_parent_geography_type,
               NULL, parent_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_geography_type),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      relationship_type_id =
        DECODE(x_relationship_type_id,
               NULL, relationship_type_id,
               FND_API.G_MISS_NUM, NULL,
               x_relationship_type_id),
      country_code =
        DECODE(x_country_code,
               NULL, country_code,
               FND_API.G_MISS_CHAR, NULL,
               x_country_code),
      geography_element_column =
        DECODE(x_geography_element_column,
               NULL, geography_element_column,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_element_column),
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
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_relationship_type_id                  IN     NUMBER,
    x_country_code                          IN     VARCHAR2,
    x_geography_element_column              IN     VARCHAR2,
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
      SELECT * FROM hz_geo_structure_levels
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
    AND ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
    AND ( ( Recinfo.parent_geography_type = x_parent_geography_type )
        OR ( ( Recinfo.parent_geography_type IS NULL )
          AND (  x_parent_geography_type IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.relationship_type_id = x_relationship_type_id )
        OR ( ( Recinfo.relationship_type_id IS NULL )
          AND (  x_relationship_type_id IS NULL ) ) )
    AND ( ( Recinfo.country_code = x_country_code )
        OR ( ( Recinfo.country_code IS NULL )
          AND (  x_country_code IS NULL ) ) )
    AND ( ( Recinfo.geography_element_column = x_geography_element_column )
        OR ( ( Recinfo.geography_element_column IS NULL )
          AND (  x_geography_element_column IS NULL ) ) )
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
    x_geography_type                        IN OUT    NOCOPY VARCHAR2,
    x_parent_geography_type                 IN OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_relationship_type_id                  OUT    NOCOPY NUMBER,
    x_country_code                          OUT    NOCOPY VARCHAR2,
    x_geography_element_column              OUT    NOCOPY VARCHAR2,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(geography_id, FND_API.G_MISS_NUM),
      NVL(geography_type, FND_API.G_MISS_CHAR),
      NVL(parent_geography_type, FND_API.G_MISS_CHAR),
      NVL(relationship_type_id, FND_API.G_MISS_NUM),
      NVL(country_code, FND_API.G_MISS_CHAR),
      NVL(geography_element_column, FND_API.G_MISS_CHAR),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(program_login_id, FND_API.G_MISS_NUM)
    INTO
      x_geography_id,
      x_geography_type,
      x_parent_geography_type,
      x_relationship_type_id,
      x_country_code,
      x_geography_element_column,
      x_created_by_module,
      x_application_id,
      x_program_login_id
    FROM HZ_GEO_STRUCTURE_LEVELS
    WHERE geography_id = x_geography_id
      AND geography_type = x_geography_type
      AND parent_geography_type = x_parent_geography_type;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'geo_structure_levels_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_geography_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_geography_id                          IN     NUMBER,
    x_geography_type                        IN     VARCHAR2,
    x_parent_geography_type                 IN     VARCHAR2

) IS
BEGIN

    DELETE FROM HZ_GEO_STRUCTURE_LEVELS
    WHERE geography_id = x_geography_id
      AND geography_type = x_geography_type
      AND parent_geography_type = x_parent_geography_type;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_GEO_STRUCTURE_LEVELS_PKG;

/
