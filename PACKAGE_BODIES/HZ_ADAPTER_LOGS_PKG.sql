--------------------------------------------------------
--  DDL for Package Body HZ_ADAPTER_LOGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADAPTER_LOGS_PKG" AS
/*$Header: ARHADLGB.pls 115.1 2003/08/15 22:23:17 acng noship $ */

PROCEDURE Insert_Row(
    x_adapter_log_id              IN OUT NOCOPY NUMBER,
    x_created_by_module              IN VARCHAR2,
    x_created_by_module_id           IN NUMBER,
    x_http_status_code               IN VARCHAR2,
    x_request_id                     IN NUMBER,
    --x_out_doc                        IN XMLTYPE,
    --x_in_doc                         IN XMLTYPE,
    x_object_version_number          IN NUMBER
) IS

  l_success                               VARCHAR2(1) := 'N';
  l_primary_key_passed                    BOOLEAN := FALSE;

  BEGIN


    IF x_adapter_log_id IS NOT NULL AND
       x_adapter_log_id <> fnd_api.g_miss_num
    THEN
        l_primary_key_passed := TRUE;
    END IF;

    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO HZ_ADAPTER_LOGS (
          adapter_log_id,
          created_by_module,
          created_by_module_id,
          http_status_code,
          --out_doc,
          --in_doc,
          object_version_number,
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by
        ) VALUES (
          DECODE(x_adapter_log_id,
                 fnd_api.g_miss_num, hz_adapter_logs_s.NEXTVAL,
                 NULL, hz_adapter_logs_s.NEXTVAL,
                 x_adapter_log_id),
          DECODE(x_created_by_module, fnd_api.g_miss_char, NULL, x_created_by_module),
          DECODE(x_created_by_module_id, fnd_api.g_miss_num, NULL, x_created_by_module_id),
          DECODE(x_http_status_code, fnd_api.g_miss_char, NULL, x_http_status_code),
          --x_out_doc,
          --x_in_doc,
          DECODE(x_object_version_number, fnd_api.g_miss_num, NULL, x_object_version_number),
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.creation_date,
          hz_utility_v2pub.last_update_login,
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by
        ) RETURNING
          adapter_log_id
        INTO
          x_ADAPTER_LOG_ID;

        l_success := 'Y';

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          IF INSTRB(SQLERRM, 'HZ_ADAPTER_LOGS_U1') <> 0 OR
             INSTRB(SQLERRM, 'HZ_ADAPTER_LOGS_PK') <> 0
          THEN
            IF l_primary_key_passed THEN
              fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
              fnd_message.set_token('COLUMN', 'adapter_log_id');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;

            DECLARE
              l_temp_adptlog_id   NUMBER;
              l_max_adptlog_id    NUMBER;
            BEGIN
              l_temp_adptlog_id := 0;
              SELECT max(ADAPTER_LOG_ID) INTO l_max_adptlog_id
              FROM HZ_ADAPTER_LOGS;
              WHILE l_temp_adptlog_id < l_max_adptlog_id LOOP
                SELECT HZ_ADAPTER_LOGS_S.NEXTVAL
                INTO l_temp_adptlog_id FROM dual;
              END LOOP;
            END;
          ELSE
            RAISE;
          END IF;
       END;
    END LOOP;
End Insert_Row;

PROCEDURE Update_Row(
    x_rowid                      IN OUT NOCOPY VARCHAR2,
    x_adapter_log_id                 IN NUMBER,
    x_created_by_module              IN VARCHAR2,
    x_created_by_module_id           IN NUMBER,
    x_http_status_code               IN VARCHAR2,
    x_request_id                     IN NUMBER,
    --x_out_doc                        IN XMLTYPE,
    --x_in_doc                         IN XMLTYPE,
    x_object_version_number          IN NUMBER
) IS
   BEGIN
   UPDATE HZ_ADAPTER_LOGS
   SET adapter_log_id = DECODE(x_adapter_log_id,
                               NULL, adapter_log_id,
                               fnd_api.g_miss_num, NULL,
                               x_adapter_log_id),
       created_by_module = DECODE(x_created_by_module,
                           NULL, created_by_module,
                           fnd_api.g_miss_char, NULL,
                           x_created_by_module),
       created_by_module_id = DECODE(x_created_by_module_id,
                                     NULL, created_by_module_id,
                                     fnd_api.g_miss_num, NULL,
                                     x_created_by_module_id),
       http_status_code = DECODE(x_http_status_code,
                                 NULL, http_status_code,
                                 fnd_api.g_miss_char, NULL,
                                 x_http_status_code),
       request_id = DECODE(x_request_id, NULL, request_id,
                           fnd_api.g_miss_num, NULL,
                           x_request_id),
       --out_doc = DECODE(x_out_doc, NULL, out_doc, x_out_doc),
       --in_doc = DECODE(x_in_doc, NULL, in_doc, x_in_doc),
       last_update_date = hz_utility_v2pub.last_update_date,
       last_updated_by = hz_utility_v2pub.last_updated_by,
       creation_date = creation_date,
       created_by = created_by,
       last_update_login = hz_utility_v2pub.last_update_login,
       object_version_number = DECODE(x_object_version_number,
                                      NULL, object_version_number,
                                      fnd_api.g_miss_num, NULL,
                                      x_object_version_number)
    where rowid = x_rowid;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Lock_Row(
    x_rowid                      IN OUT NOCOPY VARCHAR2,
    x_adapter_log_id                 IN NUMBER,
    x_created_by_module              IN VARCHAR2,
    x_created_by_module_id           IN NUMBER,
    x_http_status_code               IN VARCHAR2,
    x_request_id                     IN NUMBER,
    --x_out_doc                        IN XMLTYPE,
    --x_in_doc                         IN XMLTYPE,
    x_last_update_date               IN DATE,
    x_last_updated_by                IN NUMBER,
    x_creation_date                  IN DATE,
    x_created_by                     IN NUMBER,
    x_last_update_login              IN NUMBER,
    x_object_version_number          IN NUMBER ) IS

  CURSOR c IS
      SELECT *
      FROM   hz_adapter_logs
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

    IF (((recinfo.adapter_log_id = x_adapter_log_id)
          OR ((recinfo.adapter_log_id IS NULL)
               AND (x_adapter_log_id IS NULL)))
      AND ((recinfo.created_by_module = x_created_by_module)
          OR ((recinfo.created_by_module IS NULL)
               AND (x_created_by_module IS NULL)))
      AND ((recinfo.created_by_module_id = x_created_by_module_id)
           OR ((recinfo.created_by_module_id IS NULL)
               AND (x_created_by_module_id IS NULL)))
      AND ((recinfo.http_status_code = x_http_status_code)
           OR ((recinfo.http_status_code IS NULL)
               AND (x_http_status_code IS NULL)))
      AND ((recinfo.request_id = x_request_id)
           OR ((recinfo.request_id IS NULL)
               AND (x_request_id IS NULL)))
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



PROCEDURE delete_row (x_adapter_log_id IN NUMBER) IS
BEGIN

  DELETE FROM hz_adapter_logs
  WHERE adapter_log_id = x_adapter_log_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;


END HZ_ADAPTER_LOGS_PKG;

/
