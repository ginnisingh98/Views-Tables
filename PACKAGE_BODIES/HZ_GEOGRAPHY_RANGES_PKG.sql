--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_RANGES_PKG" AS
/*$Header: ARHGRGTB.pls 115.0 2003/02/01 02:52:22 rnalluri noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN  NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_geography_to                          IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2,
    x_end_date                              IN     DATE,
    x_geography_type                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_master_ref_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS


BEGIN

      INSERT INTO HZ_GEOGRAPHY_RANGES (
        geography_id,
        geography_from,
        start_date,
        object_version_number,
        geography_to,
        identifier_type,
        end_date,
        geography_type,
        geography_use,
        master_ref_geography_id,
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
        DECODE(x_geography_from,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_from),
        DECODE(x_start_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_start_date),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_geography_to,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_to),
        DECODE(x_identifier_type,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_type),
        DECODE(x_end_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_end_date),
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        DECODE(x_geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
        DECODE(x_master_ref_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_master_ref_geography_id),
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

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_id                          IN     NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_geography_to                          IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2,
    x_end_date                              IN     DATE,
    x_geography_type                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_master_ref_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS
BEGIN

    UPDATE HZ_GEOGRAPHY_RANGES
    SET
      geography_id =
        DECODE(x_geography_id,
               NULL, geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_geography_id),
      geography_from =
        DECODE(x_geography_from,
               NULL, geography_from,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_from),
      start_date =
        DECODE(x_start_date,
               NULL, start_date,
               FND_API.G_MISS_DATE, NULL,
               x_start_date),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      geography_to =
        DECODE(x_geography_to,
               NULL, geography_to,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_to),
      identifier_type =
        DECODE(x_identifier_type,
               NULL, identifier_type,
               FND_API.G_MISS_CHAR, NULL,
               x_identifier_type),
      end_date =
        DECODE(x_end_date,
               NULL, end_date,
               FND_API.G_MISS_DATE, NULL,
               x_end_date),
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
      geography_use =
        DECODE(x_geography_use,
               NULL, geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
      master_ref_geography_id =
        DECODE(x_master_ref_geography_id,
               NULL, master_ref_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_master_ref_geography_id),
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
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE,
    x_object_version_number                 IN     NUMBER,
    x_geography_to                          IN     VARCHAR2,
    x_identifier_type                       IN     VARCHAR2,
    x_end_date                              IN     DATE,
    x_geography_type                        IN     VARCHAR2,
    x_geography_use                         IN     VARCHAR2,
    x_master_ref_geography_id               IN     NUMBER,
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
      SELECT * FROM hz_geography_ranges
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
    AND ( ( Recinfo.geography_from = x_geography_from )
        OR ( ( Recinfo.geography_from IS NULL )
          AND (  x_geography_from IS NULL ) ) )
    AND ( ( Recinfo.start_date = x_start_date )
        OR ( ( Recinfo.start_date IS NULL )
          AND (  x_start_date IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.geography_to = x_geography_to )
        OR ( ( Recinfo.geography_to IS NULL )
          AND (  x_geography_to IS NULL ) ) )
    AND ( ( Recinfo.identifier_type = x_identifier_type )
        OR ( ( Recinfo.identifier_type IS NULL )
          AND (  x_identifier_type IS NULL ) ) )
    AND ( ( Recinfo.end_date = x_end_date )
        OR ( ( Recinfo.end_date IS NULL )
          AND (  x_end_date IS NULL ) ) )
    AND ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
    AND ( ( Recinfo.geography_use = x_geography_use )
        OR ( ( Recinfo.geography_use IS NULL )
          AND (  x_geography_use IS NULL ) ) )
    AND ( ( Recinfo.master_ref_geography_id = x_master_ref_geography_id )
        OR ( ( Recinfo.master_ref_geography_id IS NULL )
          AND (  x_master_ref_geography_id IS NULL ) ) )
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
    x_geography_from                        IN OUT    NOCOPY VARCHAR2,
    x_start_date                            IN OUT    NOCOPY DATE,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_geography_to                          OUT    NOCOPY VARCHAR2,
    x_identifier_type                       OUT    NOCOPY VARCHAR2,
    x_end_date                              OUT    NOCOPY DATE,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_geography_use                         OUT    NOCOPY VARCHAR2,
    x_master_ref_geography_id               OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(geography_id, FND_API.G_MISS_NUM),
      NVL(geography_from, FND_API.G_MISS_CHAR),
      NVL(start_date, FND_API.G_MISS_DATE),
      NVL(geography_to, FND_API.G_MISS_CHAR),
      NVL(identifier_type, FND_API.G_MISS_CHAR),
      NVL(end_date, FND_API.G_MISS_DATE),
      NVL(geography_type, FND_API.G_MISS_CHAR),
      NVL(geography_use, FND_API.G_MISS_CHAR),
      NVL(master_ref_geography_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(program_login_id, FND_API.G_MISS_NUM)
    INTO
      x_geography_id,
      x_geography_from,
      x_start_date,
      x_geography_to,
      x_identifier_type,
      x_end_date,
      x_geography_type,
      x_geography_use,
      x_master_ref_geography_id,
      x_created_by_module,
      x_application_id,
      x_program_login_id
    FROM HZ_GEOGRAPHY_RANGES
    WHERE geography_id = x_geography_id
      AND geography_from = x_geography_from
      AND start_date = x_start_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'geography_ranges_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_geography_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_geography_id                          IN     NUMBER,
    x_geography_from                        IN     VARCHAR2,
    x_start_date                            IN     DATE
) IS
BEGIN

    DELETE FROM HZ_GEOGRAPHY_RANGES
    WHERE geography_id = x_geography_id
      AND geography_from = x_geography_from
      AND start_date = x_start_date;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_GEOGRAPHY_RANGES_PKG;

/
