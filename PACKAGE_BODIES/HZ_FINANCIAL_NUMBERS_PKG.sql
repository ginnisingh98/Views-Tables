--------------------------------------------------------
--  DDL for Package Body HZ_FINANCIAL_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FINANCIAL_NUMBERS_PKG" as
/* $Header: ARHOFNTB.pls 120.5 2005/05/25 23:51:58 achung ship $ */

G_MISS_CONTENT_SOURCE_TYPE              CONSTANT VARCHAR2(30) := 'USER_ENTERED';

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_number_id                   IN OUT NOCOPY NUMBER,
    x_financial_report_id                   IN     NUMBER,
    x_financial_number                      IN     NUMBER,
    x_financial_number_name                 IN     VARCHAR2,
    x_financial_units_applied               IN     NUMBER,
    x_financial_number_currency             IN     VARCHAR2,
    x_projected_actual_flag                 IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_FINANCIAL_NUMBERS (
        financial_number_id,
        financial_report_id,
        financial_number,
        financial_number_name,
        financial_units_applied,
        financial_number_currency,
        projected_actual_flag,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        content_source_type,
        status,
        object_version_number,
        created_by_module,
        application_id,
        actual_content_source
      )
      VALUES (
        DECODE(x_financial_number_id,
               FND_API.G_MISS_NUM, HZ_FINANCIAL_NUMBERS_S.NEXTVAL,
               NULL, HZ_FINANCIAL_NUMBERS_S.NEXTVAL,
               x_financial_number_id),
        DECODE(x_financial_report_id,
               FND_API.G_MISS_NUM, NULL,
               x_financial_report_id),
        DECODE(x_financial_number,
               FND_API.G_MISS_NUM, NULL,
               x_financial_number),
        DECODE(x_financial_number_name,
               FND_API.G_MISS_CHAR, NULL,
               x_financial_number_name),
        DECODE(x_financial_units_applied,
               FND_API.G_MISS_NUM, NULL,
               x_financial_units_applied),
        DECODE(x_financial_number_currency,
               FND_API.G_MISS_CHAR, NULL,
               x_financial_number_currency),
        DECODE(x_projected_actual_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_projected_actual_flag),
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.last_update_login,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.request_id,
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.program_id,
        hz_utility_v2pub.program_update_date,
        DECODE(x_content_source_type,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               x_content_source_type),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        hz_utility_v2pub.application_id,
        DECODE(x_actual_content_source,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               x_actual_content_source)
      ) RETURNING
        rowid,
        financial_number_id
      INTO
        x_rowid,
        x_financial_number_id;

      l_success := 'Y';

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_FINANCIAL_NUMBERS_U1') <> 0 THEN
        DECLARE
          l_count             NUMBER;
          l_dummy             VARCHAR2(1);
        BEGIN
          l_count := 1;
          WHILE l_count > 0 LOOP
            SELECT HZ_FINANCIAL_NUMBERS_S.NEXTVAL
            INTO x_financial_number_id FROM dual;
            BEGIN
              SELECT 'Y' INTO l_dummy
              FROM HZ_FINANCIAL_NUMBERS
              WHERE financial_number_id = x_financial_number_id;
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

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_number_id                   IN     NUMBER,
    x_financial_report_id                   IN     NUMBER,
    x_financial_number                      IN     NUMBER,
    x_financial_number_name                 IN     VARCHAR2,
    x_financial_units_applied               IN     NUMBER,
    x_financial_number_currency             IN     VARCHAR2,
    x_projected_actual_flag                 IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS
BEGIN

    UPDATE HZ_FINANCIAL_NUMBERS
    SET
      financial_number_id =
        DECODE(x_financial_number_id,
               NULL, financial_number_id,
               FND_API.G_MISS_NUM, NULL,
               x_financial_number_id),
      financial_report_id =
        DECODE(x_financial_report_id,
               NULL, financial_report_id,
               FND_API.G_MISS_NUM, NULL,
               x_financial_report_id),
      financial_number =
        DECODE(x_financial_number,
               NULL, financial_number,
               FND_API.G_MISS_NUM, NULL,
               x_financial_number),
      financial_number_name =
        DECODE(x_financial_number_name,
               NULL, financial_number_name,
               FND_API.G_MISS_CHAR, NULL,
               x_financial_number_name),
      financial_units_applied =
        DECODE(x_financial_units_applied,
               NULL, financial_units_applied,
               FND_API.G_MISS_NUM, NULL,
               x_financial_units_applied),
      financial_number_currency =
        DECODE(x_financial_number_currency,
               NULL, financial_number_currency,
               FND_API.G_MISS_CHAR, NULL,
               x_financial_number_currency),
      projected_actual_flag =
        DECODE(x_projected_actual_flag,
               NULL, projected_actual_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_projected_actual_flag),
      created_by = created_by,
      creation_date = creation_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      request_id = hz_utility_v2pub.request_id,
      program_application_id = hz_utility_v2pub.program_application_id,
      program_id = hz_utility_v2pub.program_id,
      program_update_date = hz_utility_v2pub.program_update_date,
      content_source_type =
        DECODE(x_content_source_type,
               NULL, content_source_type,
               FND_API.G_MISS_CHAR, NULL,
               x_content_source_type),
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
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
      application_id = hz_utility_v2pub.application_id/*,

      ** SSM SST Integration and Extension
      ** actual_content_source will not be updateable for non-SSM enabled entities.

      actual_content_source =
        DECODE(x_actual_content_source,
               NULL, actual_content_source,
               FND_API.G_MISS_CHAR, NULL,
               x_actual_content_source)    */
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_financial_number_id                   IN     NUMBER,
    x_financial_report_id                   IN     NUMBER,
    x_financial_number                      IN     NUMBER,
    x_financial_number_name                 IN     VARCHAR2,
    x_financial_units_applied               IN     NUMBER,
    x_financial_number_currency             IN     VARCHAR2,
    x_projected_actual_flag                 IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2
) IS

    CURSOR c IS
      SELECT * FROM hz_financial_numbers
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
        ( ( Recinfo.financial_number_id = x_financial_number_id )
        OR ( ( Recinfo.financial_number_id IS NULL )
          AND (  x_financial_number_id IS NULL ) ) )
    AND ( ( Recinfo.financial_report_id = x_financial_report_id )
        OR ( ( Recinfo.financial_report_id IS NULL )
          AND (  x_financial_report_id IS NULL ) ) )
    AND ( ( Recinfo.financial_number = x_financial_number )
        OR ( ( Recinfo.financial_number IS NULL )
          AND (  x_financial_number IS NULL ) ) )
    AND ( ( Recinfo.financial_number_name = x_financial_number_name )
        OR ( ( Recinfo.financial_number_name IS NULL )
          AND (  x_financial_number_name IS NULL ) ) )
    AND ( ( Recinfo.financial_units_applied = x_financial_units_applied )
        OR ( ( Recinfo.financial_units_applied IS NULL )
          AND (  x_financial_units_applied IS NULL ) ) )
    AND ( ( Recinfo.financial_number_currency = x_financial_number_currency )
        OR ( ( Recinfo.financial_number_currency IS NULL )
          AND (  x_financial_number_currency IS NULL ) ) )
    AND ( ( Recinfo.projected_actual_flag = x_projected_actual_flag )
        OR ( ( Recinfo.projected_actual_flag IS NULL )
          AND (  x_projected_actual_flag IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.request_id = x_request_id )
        OR ( ( Recinfo.request_id IS NULL )
          AND (  x_request_id IS NULL ) ) )
    AND ( ( Recinfo.program_application_id = x_program_application_id )
        OR ( ( Recinfo.program_application_id IS NULL )
          AND (  x_program_application_id IS NULL ) ) )
    AND ( ( Recinfo.program_id = x_program_id )
        OR ( ( Recinfo.program_id IS NULL )
          AND (  x_program_id IS NULL ) ) )
    AND ( ( Recinfo.program_update_date = x_program_update_date )
        OR ( ( Recinfo.program_update_date IS NULL )
          AND (  x_program_update_date IS NULL ) ) )
    AND ( ( Recinfo.content_source_type = x_content_source_type )
        OR ( ( Recinfo.content_source_type IS NULL )
          AND (  x_content_source_type IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.actual_content_source = x_actual_content_source )
        OR ( ( Recinfo.actual_content_source IS NULL )
          AND (  x_actual_content_source IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_financial_number_id                   IN OUT NOCOPY NUMBER,
    x_financial_report_id                   OUT    NOCOPY NUMBER,
    x_financial_number                      OUT    NOCOPY NUMBER,
    x_financial_number_name                 OUT    NOCOPY VARCHAR2,
    x_financial_units_applied               OUT    NOCOPY NUMBER,
    x_financial_number_currency             OUT    NOCOPY VARCHAR2,
    x_projected_actual_flag                 OUT    NOCOPY VARCHAR2,
    x_content_source_type                   OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_actual_content_source                 OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(financial_number_id, FND_API.G_MISS_NUM),
      NVL(financial_report_id, FND_API.G_MISS_NUM),
      NVL(financial_number, FND_API.G_MISS_NUM),
      NVL(financial_number_name, FND_API.G_MISS_CHAR),
      NVL(financial_units_applied, FND_API.G_MISS_NUM),
      NVL(financial_number_currency, FND_API.G_MISS_CHAR),
      NVL(projected_actual_flag, FND_API.G_MISS_CHAR),
      NVL(content_source_type, FND_API.G_MISS_CHAR),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(actual_content_source, FND_API.G_MISS_CHAR)
    INTO
      x_financial_number_id,
      x_financial_report_id,
      x_financial_number,
      x_financial_number_name,
      x_financial_units_applied,
      x_financial_number_currency,
      x_projected_actual_flag,
      x_content_source_type,
      x_status,
      x_actual_content_source
    FROM HZ_FINANCIAL_NUMBERS
    WHERE financial_number_id = x_financial_number_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'hz_financial_number_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_financial_number_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_financial_number_id                   IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_FINANCIAL_NUMBERS
    WHERE financial_number_id = x_financial_number_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_FINANCIAL_NUMBERS_PKG;

/
