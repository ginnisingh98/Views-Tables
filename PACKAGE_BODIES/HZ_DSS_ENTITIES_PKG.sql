--------------------------------------------------------
--  DDL for Package Body HZ_DSS_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_ENTITIES_PKG" AS
/* $Header: ARHPDSEB.pls 115.3 2003/01/07 19:25:24 jypandey noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_entity_id                             IN OUT NOCOPY NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_id                             IN     NUMBER,
    x_instance_set_id                       IN     NUMBER,
    x_parent_entity_id                      IN     NUMBER,
    x_parent_fk_column1                     IN     VARCHAR2,
    x_parent_fk_column2                     IN     VARCHAR2,
    x_parent_fk_column3                     IN     VARCHAR2,
    x_parent_fk_column4                     IN     VARCHAR2,
    x_parent_fk_column5                     IN     VARCHAR2,
    x_group_assignment_level                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_DSS_ENTITIES (
        entity_id,
        status,
        object_id,
        instance_set_id,
        parent_entity_id,
        parent_fk_column1,
        parent_fk_column2,
        parent_fk_column3,
        parent_fk_column4,
        parent_fk_column5,
        group_assignment_level,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number
      )
      VALUES (
        DECODE(x_entity_id,
               FND_API.G_MISS_NUM, HZ_DSS_ENTITIES_S.NEXTVAL,
               NULL, HZ_DSS_ENTITIES_S.NEXTVAL,
               x_entity_id),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        DECODE(x_object_id,
               FND_API.G_MISS_NUM, NULL,
               x_object_id),
        DECODE(x_instance_set_id,
               FND_API.G_MISS_NUM, NULL,
               x_instance_set_id),
        DECODE(x_parent_entity_id,
               FND_API.G_MISS_NUM, NULL,
               x_parent_entity_id),
        DECODE(x_parent_fk_column1,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column1),
        DECODE(x_parent_fk_column2,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column2),
        DECODE(x_parent_fk_column3,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column3),
        DECODE(x_parent_fk_column4,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column4),
        DECODE(x_parent_fk_column5,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column5),
        DECODE(x_group_assignment_level,
               FND_API.G_MISS_CHAR, NULL,
               x_group_assignment_level),
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
        entity_id
      INTO
        x_rowid,
        x_entity_id;

      l_success := 'Y';

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_DSS_ENTITIES_U1') <> 0 THEN
        DECLARE
          l_count             NUMBER;
          l_dummy             VARCHAR2(1);
        BEGIN
          l_count := 1;
          WHILE l_count > 0 LOOP
            SELECT HZ_DSS_ENTITIES_S.NEXTVAL
            INTO x_entity_id FROM dual;
            BEGIN
              SELECT 'Y' INTO l_dummy
              FROM HZ_DSS_ENTITIES
              WHERE entity_id = x_entity_id;
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
    x_object_id                             IN     NUMBER,
    x_instance_set_id                       IN     NUMBER,
    x_parent_entity_id                      IN     NUMBER,
    x_parent_fk_column1                     IN     VARCHAR2,
    x_parent_fk_column2                     IN     VARCHAR2,
    x_parent_fk_column3                     IN     VARCHAR2,
    x_parent_fk_column4                     IN     VARCHAR2,
    x_parent_fk_column5                     IN     VARCHAR2,
    x_group_assignment_level                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS
BEGIN

    UPDATE HZ_DSS_ENTITIES
    SET
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
     --Bug:2620112 Allow updates to following columns
     parent_entity_id =
        DECODE(x_parent_entity_id,
               NULL, parent_entity_id,
               FND_API.G_MISS_NUM, NULL,
               x_parent_entity_id),
       parent_fk_column1 =
        DECODE(x_parent_fk_column1,
               NULL, parent_fk_column1,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column1),
      parent_fk_column2 =
        DECODE(x_parent_fk_column2,
               NULL, parent_fk_column2,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column2),
      parent_fk_column3 =
        DECODE(x_parent_fk_column3,
               NULL, parent_fk_column3,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column3),
      parent_fk_column4 =
        DECODE(x_parent_fk_column4,
               NULL, parent_fk_column4,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column4),
      parent_fk_column5 =
        DECODE(x_parent_fk_column5,
               NULL, parent_fk_column5,
               FND_API.G_MISS_CHAR, NULL,
               x_parent_fk_column5),
      group_assignment_level =
        DECODE(x_group_assignment_level,
               NULL, group_assignment_level,
               FND_API.G_MISS_CHAR, NULL,
               x_group_assignment_level),
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
    x_entity_id                             IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_id                             IN     NUMBER,
    x_instance_set_id                       IN     NUMBER,
    x_parent_entity_id                      IN     NUMBER,
    x_parent_fk_column1                     IN     VARCHAR2,
    x_parent_fk_column2                     IN     VARCHAR2,
    x_parent_fk_column3                     IN     VARCHAR2,
    x_parent_fk_column4                     IN     VARCHAR2,
    x_parent_fk_column5                     IN     VARCHAR2,
    x_group_assignment_level                IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_dss_entities
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
        ( ( Recinfo.entity_id = x_entity_id )
        OR ( ( Recinfo.entity_id IS NULL )
          AND (  x_entity_id IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.object_id = x_object_id )
        OR ( ( Recinfo.object_id IS NULL )
          AND (  x_object_id IS NULL ) ) )
    AND ( ( Recinfo.instance_set_id = x_instance_set_id )
        OR ( ( Recinfo.instance_set_id IS NULL )
          AND (  x_instance_set_id IS NULL ) ) )
    AND ( ( Recinfo.parent_entity_id = x_parent_entity_id )
        OR ( ( Recinfo.parent_entity_id IS NULL )
          AND (  x_parent_entity_id IS NULL ) ) )
    AND ( ( Recinfo.parent_fk_column1 = x_parent_fk_column1 )
        OR ( ( Recinfo.parent_fk_column1 IS NULL )
          AND (  x_parent_fk_column1 IS NULL ) ) )
    AND ( ( Recinfo.parent_fk_column2 = x_parent_fk_column2 )
        OR ( ( Recinfo.parent_fk_column2 IS NULL )
          AND (  x_parent_fk_column2 IS NULL ) ) )
    AND ( ( Recinfo.parent_fk_column3 = x_parent_fk_column3 )
        OR ( ( Recinfo.parent_fk_column3 IS NULL )
          AND (  x_parent_fk_column3 IS NULL ) ) )
    AND ( ( Recinfo.parent_fk_column4 = x_parent_fk_column4 )
        OR ( ( Recinfo.parent_fk_column4 IS NULL )
          AND (  x_parent_fk_column4 IS NULL ) ) )
    AND ( ( Recinfo.parent_fk_column5 = x_parent_fk_column5 )
        OR ( ( Recinfo.parent_fk_column5 IS NULL )
          AND (  x_parent_fk_column5 IS NULL ) ) )
    AND ( ( Recinfo.group_assignment_level = x_group_assignment_level )
        OR ( ( Recinfo.group_assignment_level IS NULL )
          AND (  x_group_assignment_level IS NULL ) ) )
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
    x_entity_id                             IN OUT NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_object_id                             OUT    NOCOPY NUMBER,
    x_instance_set_id                       OUT    NOCOPY NUMBER,
    x_parent_entity_id                      OUT    NOCOPY NUMBER,
    x_parent_fk_column1                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column2                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column3                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column4                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column5                     OUT    NOCOPY VARCHAR2,
    x_group_assignment_level                OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(entity_id, FND_API.G_MISS_NUM),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(object_id, FND_API.G_MISS_NUM),
      NVL(instance_set_id, FND_API.G_MISS_NUM),
      NVL(parent_entity_id, FND_API.G_MISS_NUM),
      NVL(parent_fk_column1, FND_API.G_MISS_CHAR),
      NVL(parent_fk_column2, FND_API.G_MISS_CHAR),
      NVL(parent_fk_column3, FND_API.G_MISS_CHAR),
      NVL(parent_fk_column4, FND_API.G_MISS_CHAR),
      NVL(parent_fk_column5, FND_API.G_MISS_CHAR),
      NVL(group_assignment_level, FND_API.G_MISS_CHAR),
      NVL(object_version_number, FND_API.G_MISS_NUM)
    INTO
      x_entity_id,
      x_status,
      x_object_id,
      x_instance_set_id,
      x_parent_entity_id,
      x_parent_fk_column1,
      x_parent_fk_column2,
      x_parent_fk_column3,
      x_parent_fk_column4,
      x_parent_fk_column5,
      x_group_assignment_level,
      x_object_version_number
    FROM HZ_DSS_ENTITIES
    WHERE entity_id = x_entity_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'dss_entity_profile');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_entity_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_entity_id                             IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_DSS_ENTITIES
    WHERE entity_id = x_entity_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_DSS_ENTITIES_PKG;

/
