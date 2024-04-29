--------------------------------------------------------
--  DDL for Package Body HZ_ADAPTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADAPTERS_PKG" AS
/*$Header: ARHADPTB.pls 115.0 2003/08/13 23:47:14 acng noship $ */

  PROCEDURE Insert_Row(
    x_adapter_id                     IN OUT NOCOPY NUMBER,
    x_adapter_content_source         IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_synchronous_flag               IN VARCHAR2,
    x_invoke_method_code             IN VARCHAR2,
    x_message_format_code            IN VARCHAR2,
    x_host_address                   IN VARCHAR2,
    x_username                       IN VARCHAR2,
    x_encrypted_password             IN VARCHAR2,
    x_maximum_batch_size             IN NUMBER,
    x_default_batch_size             IN NUMBER,
    x_default_replace_status_level   IN VARCHAR2,
    x_object_version_number          IN NUMBER
  ) IS

    l_success                               VARCHAR2(1) := 'N';
    l_primary_key_passed                    BOOLEAN := FALSE;

  BEGIN

    IF x_adapter_id IS NOT NULL AND
       x_adapter_id <> fnd_api.g_miss_num
    THEN
        l_primary_key_passed := TRUE;
    END IF;

    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO HZ_ADAPTERS(
          adapter_id,
          adapter_content_source,
          enabled_flag,
          synchronous_flag,
          invoke_method_code,
          message_format_code,
          host_address,
          username,
          encrypted_password,
          maximum_batch_size,
          default_batch_size,
          default_replace_status_level,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          object_version_number
        ) VALUES (
          DECODE(x_adapter_id, fnd_api.g_miss_num, hz_adapters_s.NEXTVAL,
                 NULL, hz_adapters_s.NEXTVAL, x_adapter_id),
          DECODE(x_adapter_content_source,
                 fnd_api.g_miss_char, NULL, x_adapter_content_source),
          DECODE(x_enabled_flag,
                 fnd_api.g_miss_char, NULL, x_enabled_flag),
          DECODE(x_synchronous_flag,
                 fnd_api.g_miss_char, NULL, x_synchronous_flag),
          DECODE(x_invoke_method_code,
                 fnd_api.g_miss_char, NULL, x_invoke_method_code),
          DECODE(x_message_format_code,
                 fnd_api.g_miss_char, NULL, x_message_format_code),
          DECODE(x_host_address,
                 fnd_api.g_miss_char, NULL, x_host_address),
          DECODE(x_username,
                 fnd_api.g_miss_char, NULL, x_username),
          DECODE(x_encrypted_password,
                 fnd_api.g_miss_char, NULL, x_encrypted_password),
          DECODE(x_maximum_batch_size,
                 fnd_api.g_miss_num, NULL, x_maximum_batch_size),
          DECODE(x_default_batch_size,
                 fnd_api.g_miss_num, NULL, x_default_batch_size),
          DECODE(x_default_replace_status_level,
                 fnd_api.g_miss_char, NULL, x_default_replace_status_level),
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by,
          hz_utility_v2pub.creation_date,
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.last_update_login,
          DECODE(x_object_version_number, fnd_api.g_miss_num, NULL, x_object_version_number)
       ) RETURNING
         adapter_id
       INTO
         x_ADAPTER_ID;

       l_success := 'Y';

     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN
         IF INSTRB(SQLERRM, 'HZ_ADAPTERS_U1') <> 0 OR
            INSTRB(SQLERRM, 'HZ_ADAPTERS_PK') <> 0
         THEN
           IF l_primary_key_passed THEN
             fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
             fnd_message.set_token('COLUMN', 'adapter_id');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;
           END IF;

           DECLARE
             l_temp_adapter_id   NUMBER;
             l_max_adapter_id    NUMBER;
           BEGIN
             l_temp_adapter_id := 0;
             SELECT max(ADAPTER_ID) INTO l_max_adapter_id
             FROM HZ_ADAPTERS;
             WHILE l_temp_adapter_id <= l_max_adapter_id LOOP
               SELECT HZ_ADAPTERS_S.NEXTVAL
               INTO l_temp_adapter_id FROM dual;
             END LOOP;
           END;
         ELSE
             RAISE;
         END IF;
      END;
    END LOOP;
  End Insert_Row;

  PROCEDURE Update_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_adapter_id                     IN NUMBER,
    x_adapter_content_source         IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_synchronous_flag               IN VARCHAR2,
    x_invoke_method_code             IN VARCHAR2,
    x_message_format_code            IN VARCHAR2,
    x_host_address                   IN VARCHAR2,
    x_username                       IN VARCHAR2,
    x_encrypted_password             IN VARCHAR2,
    x_maximum_batch_size             IN NUMBER,
    x_default_batch_size             IN NUMBER,
    x_default_replace_status_level   IN VARCHAR2,
    x_object_version_number          IN NUMBER
  ) IS

  BEGIN

    UPDATE hz_adapters
    SET   adapter_id = DECODE(x_adapter_id, NULL, adapter_id,
                              fnd_api.g_miss_num, NULL, x_adapter_id),
          adapter_content_source = DECODE(x_adapter_content_source,
                            NULL, adapter_content_source,
                            fnd_api.g_miss_char, NULL, x_adapter_content_source),
          enabled_flag = DECODE(x_enabled_flag, NULL, enabled_flag,
                            fnd_api.g_miss_char, NULL, x_enabled_flag),
          synchronous_flag = DECODE(x_synchronous_flag, NULL, synchronous_flag,
                            fnd_api.g_miss_char, NULL, x_synchronous_flag),
          invoke_method_code = DECODE(x_invoke_method_code, NULL, invoke_method_code,
                            fnd_api.g_miss_char, NULL, x_invoke_method_code),
          message_format_code = DECODE(x_message_format_code, NULL, message_format_code,
                            fnd_api.g_miss_char, NULL, x_message_format_code),
          host_address = DECODE(x_host_address, NULL, host_address,
                            fnd_api.g_miss_char, NULL, x_host_address),
          username = DECODE(x_username, NULL, username,
                            fnd_api.g_miss_char, NULL, x_username),
          encrypted_password = DECODE(x_encrypted_password, NULL, encrypted_password,
                            fnd_api.g_miss_char, NULL, x_encrypted_password),
          maximum_batch_size = DECODE(x_maximum_batch_size, NULL, maximum_batch_size,
                            fnd_api.g_miss_num, NULL, x_maximum_batch_size),
          default_batch_size = DECODE(x_default_batch_size, NULL, default_batch_size,
                            fnd_api.g_miss_num, NULL, x_default_batch_size),
          default_replace_status_level = DECODE(x_default_replace_status_level,
                                                NULL, default_replace_status_level,
                                                fnd_api.g_miss_char,
                                                NULL, x_default_replace_status_level),
          last_update_date = hz_utility_v2pub.last_update_date,
          last_updated_by = hz_utility_v2pub.last_updated_by,
          creation_date = creation_date,
          created_by = created_by,
          last_update_login = hz_utility_v2pub.last_update_login,
          object_version_number = DECODE(x_object_version_number,
                                         NULL, object_version_number,
                                         fnd_api.g_miss_num, NULL,
                                         x_object_version_number)

    WHERE rowid = x_rowid;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
  END Update_Row;

  PROCEDURE Lock_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_adapter_id                     IN NUMBER,
    x_adapter_content_source         IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_synchronous_flag               IN VARCHAR2,
    x_invoke_method_code             IN VARCHAR2,
    x_message_format_code            IN VARCHAR2,
    x_host_address                   IN VARCHAR2,
    x_username                       IN VARCHAR2,
    x_encrypted_password             IN VARCHAR2,
    x_maximum_batch_size             IN NUMBER,
    x_default_batch_size             IN NUMBER,
    x_default_replace_status_level   IN VARCHAR2,
    x_last_update_date               IN DATE,
    x_last_updated_by                IN NUMBER,
    x_creation_date                  IN DATE,
    x_created_by                     IN NUMBER,
    x_last_update_login              IN NUMBER,
    x_object_version_number          IN NUMBER
  ) IS

    CURSOR c IS
      SELECT *
      FROM   hz_adapters
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
        AND ((recinfo.adapter_content_source = x_adapter_content_source)
            OR ((recinfo.adapter_content_source IS NULL)
                 AND (x_adapter_content_source IS NULL)))
        AND ((recinfo.enabled_flag = x_enabled_flag)
            OR ((recinfo.enabled_flag IS NULL)
                 AND (x_enabled_flag IS NULL)))
        AND ((recinfo.synchronous_flag = x_synchronous_flag)
            OR ((recinfo.synchronous_flag IS NULL)
                 AND (x_synchronous_flag IS NULL)))
        AND ((recinfo.invoke_method_code = x_invoke_method_code)
            OR ((recinfo.invoke_method_code IS NULL)
                 AND (x_invoke_method_code IS NULL)))
        AND ((recinfo.message_format_code = x_message_format_code)
            OR ((recinfo.message_format_code IS NULL)
                 AND (x_message_format_code IS NULL)))
        AND ((recinfo.host_address = x_host_address)
            OR ((recinfo.host_address IS NULL)
                 AND (x_host_address IS NULL)))
        AND ((recinfo.username = x_username)
            OR ((recinfo.username IS NULL)
                 AND (x_username IS NULL)))
        AND ((recinfo.encrypted_password = x_encrypted_password)
            OR ((recinfo.encrypted_password IS NULL)
                 AND (x_encrypted_password IS NULL)))
        AND ((recinfo.maximum_batch_size = x_maximum_batch_size)
            OR ((recinfo.maximum_batch_size IS NULL)
                 AND (x_maximum_batch_size IS NULL)))
        AND ((recinfo.default_batch_size = x_default_batch_size)
            OR ((recinfo.default_batch_size IS NULL)
                 AND (x_default_batch_size IS NULL)))
        AND ((recinfo.default_replace_status_level = x_default_replace_status_level)
            OR ((recinfo.default_replace_status_level IS NULL)
                 AND (x_default_replace_status_level IS NULL)))
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
  END lock_row;


  PROCEDURE delete_row (x_adapter_id IN NUMBER) IS
  BEGIN
    DELETE FROM hz_adapters
    WHERE adapter_id = x_adapter_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

END HZ_ADAPTERS_PKG;

/
