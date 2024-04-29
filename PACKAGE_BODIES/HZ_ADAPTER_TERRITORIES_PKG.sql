--------------------------------------------------------
--  DDL for Package Body HZ_ADAPTER_TERRITORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADAPTER_TERRITORIES_PKG" AS
/*$Header: ARHADTTB.pls 115.0 2003/08/13 23:49:48 acng noship $ */

PROCEDURE Insert_Row(
   x_adapter_id                     IN NUMBER,
   x_territory_code                 IN VARCHAR2,
   x_enabled_flag                   IN VARCHAR2,
   x_default_flag                   IN VARCHAR2,
   x_object_version_number          IN NUMBER
) IS

BEGIN

   INSERT INTO HZ_ADAPTER_TERRITORIES(
       adapter_id,
       territory_code,
       enabled_flag,
       default_flag,
       created_by,
       creation_date,
       last_update_login,
       last_update_date,
       last_updated_by,
       object_version_number
   ) VALUES (
       DECODE(x_adapter_id, fnd_api.g_miss_num, NULL, x_adapter_id),
       DECODE(x_territory_code, fnd_api.g_miss_char, NULL, x_territory_code),
       DECODE(x_enabled_flag, fnd_api.g_miss_char, NULL, x_enabled_flag),
       DECODE(x_default_flag, fnd_api.g_miss_char, NULL, x_default_flag),
       hz_utility_v2pub.created_by,
       hz_utility_v2pub.creation_date,
       hz_utility_v2pub.last_update_login,
       hz_utility_v2pub.last_update_date,
       hz_utility_v2pub.last_updated_by,
       DECODE(x_object_version_number, fnd_api.g_miss_num, NULL, x_object_version_number)
   );

End Insert_Row;

  PROCEDURE Update_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_adapter_id                     IN NUMBER,
    x_territory_code                 IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_default_flag                   IN VARCHAR2,
    x_object_version_number          IN NUMBER
  ) IS

  BEGIN
    UPDATE HZ_ADAPTER_TERRITORIES
    SET adapter_id = DECODE(x_adapter_id, NULL, adapter_id,
                            fnd_api.g_miss_num, NULL, x_adapter_id),
       territory_code = DECODE(x_territory_code, NULL, territory_code,
                             fnd_api.g_miss_char, NULL, x_territory_code),
       enabled_flag = DECODE(x_enabled_flag, NULL, enabled_flag,
                             fnd_api.g_miss_char, NULL, x_enabled_flag),
       default_flag = DECODE(x_default_flag, NULL, default_flag,
                             fnd_api.g_miss_char, NULL, x_default_flag),
       last_update_date = hz_utility_v2pub.last_update_date,
       last_updated_by = hz_utility_v2pub.last_updated_by,
       creation_date = creation_date,
       created_by = created_by,
       last_update_login = hz_utility_v2pub.last_update_login,
       object_version_number = DECODE(x_object_version_number,
                                      NULL, object_version_number,
                                      fnd_api.g_miss_num, NULL,
                                      x_object_version_number)
    WHERE ROWID = x_ROWID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
  END Update_Row;

PROCEDURE Lock_Row(
   x_rowid                          IN OUT NOCOPY VARCHAR2,
   x_adapter_id                     IN NUMBER,
   x_territory_code                 IN VARCHAR2,
   x_enabled_flag                   IN VARCHAR2,
   x_default_flag                   IN VARCHAR2,
   x_last_update_date               IN DATE,
   x_last_updated_by                IN NUMBER,
   x_creation_date                  IN DATE,
   x_created_by                     IN NUMBER,
   x_last_update_login              IN NUMBER,
   x_object_version_number          IN NUMBER
) IS

    CURSOR c IS
      SELECT *
      FROM   hz_adapter_territories
      WHERE  ROWID = x_rowid
      FOR UPDATE NOWAIT;

    recinfo c%ROWTYPE;
  BEGIN
    OPEN c;
    FETCH c INTO recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE c;

    IF (((recinfo.adapter_id = x_adapter_id)
         OR ((recinfo.adapter_id IS NULL)
              AND (x_adapter_id IS NULL)))
        AND ((recinfo.territory_code = x_territory_code)
            OR ((recinfo.territory_code IS NULL)
                 AND (x_territory_code IS NULL)))
        AND ((recinfo.enabled_flag = x_enabled_flag)
            OR ((recinfo.enabled_flag IS NULL)
                 AND (x_enabled_flag IS NULL)))
        AND ((recinfo.default_flag = x_default_flag)
            OR ((recinfo.default_flag IS NULL)
                 AND (x_default_flag IS NULL)))
        AND ((recinfo.last_update_date = x_last_update_date)
             OR ((recinfo.last_update_date IS NULL)
                 AND (x_last_update_date IS NULL)))
        AND ((recinfo.last_updated_by = x_last_updated_by)
             OR ((recinfo.last_updated_by IS NULL)
                 AND (x_last_updated_by IS NULL)))
        AND ((recinfo.creation_date = x_creation_date)
             OR ((recinfo.creation_date IS NULL)
                 AND (x_creation_date IS NULL)))
        AND ((recinfo.created_by = x_created_by)
             OR ((recinfo.created_by IS NULL)
                 AND (x_created_by IS NULL)))
        AND ((recinfo.last_update_login = x_last_update_login)
             OR ((recinfo.last_update_login IS NULL)
                 AND (x_last_update_login IS NULL)))
        AND ((recinfo.object_version_number = x_object_version_number)
             OR ((recinfo.object_version_number IS NULL)
                 AND (x_object_version_number IS NULL)))
    )
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;

END Lock_Row;

  PROCEDURE delete_row (x_adapter_id IN NUMBER, x_territory_code IN VARCHAR2) IS
  BEGIN
    DELETE FROM hz_adapter_territories
    WHERE adapter_id = x_adapter_id
    AND territory_code = x_territory_code;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

END HZ_ADAPTER_TERRITORIES_PKG;

/
