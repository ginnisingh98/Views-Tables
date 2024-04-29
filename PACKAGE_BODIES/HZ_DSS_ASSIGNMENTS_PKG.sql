--------------------------------------------------------
--  DDL for Package Body HZ_DSS_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_ASSIGNMENTS_PKG" AS
/* $Header: ARHPDSAB.pls 115.2 2002/10/10 01:41:46 chsaulit noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_assignment_id                         IN OUT NOCOPY NUMBER,
    x_status                                IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id1                       IN     VARCHAR2,
    x_owner_table_id2                       IN     VARCHAR2,
    x_owner_table_id3                       IN     VARCHAR2,
    x_owner_table_id4                       IN     VARCHAR2,
    x_owner_table_id5                       IN     VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_DSS_ASSIGNMENTS (
        assignment_id,
        status,
        owner_table_name,
        owner_table_id1,
        owner_table_id2,
        owner_table_id3,
        owner_table_id4,
        owner_table_id5,
        dss_group_code,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number
      )
      VALUES (
        DECODE(x_assignment_id,
               FND_API.G_MISS_NUM, HZ_DSS_ASSIGNMENTS_S.NEXTVAL,
               NULL, HZ_DSS_ASSIGNMENTS_S.NEXTVAL,
               x_assignment_id),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        DECODE(x_owner_table_name,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_name),
        DECODE(x_owner_table_id1,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id1),
        DECODE(x_owner_table_id2,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id2),
        DECODE(x_owner_table_id3,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id3),
        DECODE(x_owner_table_id4,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id4),
        DECODE(x_owner_table_id5,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id5),
        DECODE(x_dss_group_code,
               FND_API.G_MISS_CHAR, NULL,
               x_dss_group_code),
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_login,
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number)
      ) RETURNING
        rowid,
        assignment_id
      INTO
        x_rowid,
        x_assignment_id;

      l_success := 'Y';

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_DSS_ASSIGNMENTS_U1') <> 0 THEN
        DECLARE
          l_count             NUMBER;
          l_dummy             VARCHAR2(1);
        BEGIN
          l_count := 1;
          WHILE l_count > 0 LOOP
            SELECT HZ_DSS_ASSIGNMENTS_S.NEXTVAL
            INTO x_assignment_id FROM dual;
            BEGIN
              SELECT 'Y' INTO l_dummy
              FROM HZ_DSS_ASSIGNMENTS
              WHERE assignment_id = x_assignment_id;
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
    x_status                                IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id1                       IN     VARCHAR2,
    x_owner_table_id2                       IN     VARCHAR2,
    x_owner_table_id3                       IN     VARCHAR2,
    x_owner_table_id4                       IN     VARCHAR2,
    x_owner_table_id5                       IN     VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS
BEGIN

    UPDATE HZ_DSS_ASSIGNMENTS
    SET
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
      owner_table_name =
        DECODE(x_owner_table_name,
               NULL, owner_table_name,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_name),
      owner_table_id1 =
        DECODE(x_owner_table_id1,
               NULL, owner_table_id1,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id1),
      owner_table_id2 =
        DECODE(x_owner_table_id2,
               NULL, owner_table_id2,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id2),
      owner_table_id3 =
        DECODE(x_owner_table_id3,
               NULL, owner_table_id3,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id3),
      owner_table_id4 =
        DECODE(x_owner_table_id4,
               NULL, owner_table_id4,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id4),
      owner_table_id5 =
        DECODE(x_owner_table_id5,
               NULL, owner_table_id5,
               FND_API.G_MISS_CHAR, NULL,
               x_owner_table_id5),
      dss_group_code =
        DECODE(x_dss_group_code,
               NULL, dss_group_code,
               FND_API.G_MISS_CHAR, NULL,
               x_dss_group_code),
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
    x_assignment_id                         IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id1                       IN     VARCHAR2,
    x_owner_table_id2                       IN     VARCHAR2,
    x_owner_table_id3                       IN     VARCHAR2,
    x_owner_table_id4                       IN     VARCHAR2,
    x_owner_table_id5                       IN     VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_dss_assignments
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
        ( ( Recinfo.assignment_id = x_assignment_id )
        OR ( ( Recinfo.assignment_id IS NULL )
          AND (  x_assignment_id IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.owner_table_name = x_owner_table_name )
        OR ( ( Recinfo.owner_table_name IS NULL )
          AND (  x_owner_table_name IS NULL ) ) )
    AND ( ( Recinfo.owner_table_id1 = x_owner_table_id1 )
        OR ( ( Recinfo.owner_table_id1 IS NULL )
          AND (  x_owner_table_id1 IS NULL ) ) )
    AND ( ( Recinfo.owner_table_id2 = x_owner_table_id2 )
        OR ( ( Recinfo.owner_table_id2 IS NULL )
          AND (  x_owner_table_id2 IS NULL ) ) )
    AND ( ( Recinfo.owner_table_id3 = x_owner_table_id3 )
        OR ( ( Recinfo.owner_table_id3 IS NULL )
          AND (  x_owner_table_id3 IS NULL ) ) )
    AND ( ( Recinfo.owner_table_id4 = x_owner_table_id4 )
        OR ( ( Recinfo.owner_table_id4 IS NULL )
          AND (  x_owner_table_id4 IS NULL ) ) )
    AND ( ( Recinfo.owner_table_id5 = x_owner_table_id5 )
        OR ( ( Recinfo.owner_table_id5 IS NULL )
          AND (  x_owner_table_id5 IS NULL ) ) )
    AND ( ( Recinfo.dss_group_code = x_dss_group_code )
        OR ( ( Recinfo.dss_group_code IS NULL )
          AND (  x_dss_group_code IS NULL ) ) )
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
    AND ( ( Recinfo.object_version_number = x_object_version_number)
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
    x_assignment_id                         IN OUT NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_owner_table_name                      OUT    NOCOPY VARCHAR2,
    x_owner_table_id1                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id2                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id3                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id4                       OUT    NOCOPY VARCHAR2,
    x_owner_table_id5                       OUT    NOCOPY VARCHAR2,
    x_dss_group_code                        OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(assignment_id, FND_API.G_MISS_NUM),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(owner_table_name, FND_API.G_MISS_CHAR),
      NVL(owner_table_id1, FND_API.G_MISS_CHAR),
      NVL(owner_table_id2, FND_API.G_MISS_CHAR),
      NVL(owner_table_id3, FND_API.G_MISS_CHAR),
      NVL(owner_table_id4, FND_API.G_MISS_CHAR),
      NVL(owner_table_id5, FND_API.G_MISS_CHAR),
      NVL(dss_group_code, FND_API.G_MISS_CHAR),
      NVL(object_version_number, FND_API.G_MISS_NUM)
    INTO
      x_assignment_id,
      x_status,
      x_owner_table_name,
      x_owner_table_id1,
      x_owner_table_id2,
      x_owner_table_id3,
      x_owner_table_id4,
      x_owner_table_id5,
      x_dss_group_code,
      x_object_version_number
    FROM HZ_DSS_ASSIGNMENTS
    WHERE assignment_id = x_assignment_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'dss_assignment');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_assignment_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_assignment_id                         IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_DSS_ASSIGNMENTS
    WHERE assignment_id = x_assignment_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_DSS_ASSIGNMENTS_PKG;

/
