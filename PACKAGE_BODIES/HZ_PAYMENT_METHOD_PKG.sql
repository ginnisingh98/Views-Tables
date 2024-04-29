--------------------------------------------------------
--  DDL for Package Body HZ_PAYMENT_METHOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PAYMENT_METHOD_PKG" AS
/*$Header: ARHPYMTB.pls 120.0 2005/07/06 21:12:55 acng noship $ */

  PROCEDURE Insert_Row(
    x_cust_receipt_method_id         IN OUT NOCOPY NUMBER,
    x_customer_id                    IN NUMBER,
    x_receipt_method_id              IN NUMBER,
    x_primary_flag                   IN VARCHAR2,
    x_site_use_id                    IN NUMBER,
    x_start_date                     IN DATE,
    x_end_date                       IN DATE,
    x_attribute_category             IN VARCHAR2,
    x_attribute1                     IN VARCHAR2,
    x_attribute2                     IN VARCHAR2,
    x_attribute3                     IN VARCHAR2,
    x_attribute4                     IN VARCHAR2,
    x_attribute5                     IN VARCHAR2,
    x_attribute6                     IN VARCHAR2,
    x_attribute7                     IN VARCHAR2,
    x_attribute8                     IN VARCHAR2,
    x_attribute9                     IN VARCHAR2,
    x_attribute10                    IN VARCHAR2,
    x_attribute11                    IN VARCHAR2,
    x_attribute12                    IN VARCHAR2,
    x_attribute13                    IN VARCHAR2,
    x_attribute14                    IN VARCHAR2,
    x_attribute15                    IN VARCHAR2
  ) IS
    l_success                               VARCHAR2(1) := 'N';
    l_primary_key_passed                    BOOLEAN := FALSE;
  BEGIN
    IF x_cust_receipt_method_id IS NOT NULL AND
       x_cust_receipt_method_id <> fnd_api.g_miss_num
    THEN
        l_primary_key_passed := TRUE;
    END IF;

    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO RA_CUST_RECEIPT_METHODS(
          cust_receipt_method_id,
          customer_id,
          receipt_method_id,
          primary_flag,
          site_use_id,
          start_date,
          end_date,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date
        ) VALUES (
          DECODE(x_cust_receipt_method_id, fnd_api.g_miss_num,
                 ra_cust_receipt_methods_s.NEXTVAL,
                 NULL, ra_cust_receipt_methods_s.NEXTVAL, x_cust_receipt_method_id),
          DECODE(x_customer_id, fnd_api.g_miss_num, NULL, x_customer_id),
          DECODE(x_receipt_method_id, fnd_api.g_miss_num, NULL, x_receipt_method_id),
          DECODE(x_primary_flag, fnd_api.g_miss_char, NULL, x_primary_flag),
          DECODE(x_site_use_id, fnd_api.g_miss_num, NULL, x_site_use_id),
          DECODE(x_start_date, fnd_api.g_miss_date, NULL, x_start_date),
          DECODE(x_end_date, fnd_api.g_miss_date, NULL, x_end_date),
          DECODE(x_attribute_category, fnd_api.g_miss_char, NULL, x_attribute_category),
          DECODE(x_attribute1, fnd_api.g_miss_char, NULL, x_attribute1),
          DECODE(x_attribute2, fnd_api.g_miss_char, NULL, x_attribute2),
          DECODE(x_attribute3, fnd_api.g_miss_char, NULL, x_attribute3),
          DECODE(x_attribute4, fnd_api.g_miss_char, NULL, x_attribute4),
          DECODE(x_attribute5, fnd_api.g_miss_char, NULL, x_attribute5),
          DECODE(x_attribute6, fnd_api.g_miss_char, NULL, x_attribute6),
          DECODE(x_attribute7, fnd_api.g_miss_char, NULL, x_attribute7),
          DECODE(x_attribute8, fnd_api.g_miss_char, NULL, x_attribute8),
          DECODE(x_attribute9, fnd_api.g_miss_char, NULL, x_attribute9),
          DECODE(x_attribute10, fnd_api.g_miss_char, NULL, x_attribute10),
          DECODE(x_attribute11, fnd_api.g_miss_char, NULL, x_attribute11),
          DECODE(x_attribute12, fnd_api.g_miss_char, NULL, x_attribute12),
          DECODE(x_attribute13, fnd_api.g_miss_char, NULL, x_attribute13),
          DECODE(x_attribute14, fnd_api.g_miss_char, NULL, x_attribute14),
          DECODE(x_attribute15, fnd_api.g_miss_char, NULL, x_attribute15),
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by,
          hz_utility_v2pub.creation_date,
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.last_update_login,
          hz_utility_v2pub.request_id,
          hz_utility_v2pub.program_application_id,
          hz_utility_v2pub.program_id,
          hz_utility_v2pub.program_update_date
       ) RETURNING
         cust_receipt_method_id
       INTO
         x_cust_receipt_method_id;

       l_success := 'Y';

     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN
         IF INSTRB(SQLERRM, 'RA_CUST_RECEIPT_METHODS_U1') <> 0 OR
            INSTRB(SQLERRM, 'RA_CUST_RECEIPT_METHODS_PK') <> 0
         THEN
           IF l_primary_key_passed THEN
             fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
             fnd_message.set_token('COLUMN', 'cust_receipt_method_id');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;
           END IF;

           DECLARE
             l_temp_crm_id   NUMBER;
             l_max_crm_id   NUMBER;
           BEGIN
             l_temp_crm_id := 0;
             SELECT max(cust_receipt_method_id) INTO l_max_crm_id
             FROM RA_CUST_RECEIPT_METHODS;
             WHILE l_temp_crm_id <= l_max_crm_id LOOP
               SELECT RA_CUST_RECEIPT_METHODS_S.NEXTVAL
               INTO l_temp_crm_id FROM dual;
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
    x_cust_receipt_method_id         IN NUMBER,
    x_customer_id                    IN NUMBER,
    x_receipt_method_id              IN NUMBER,
    x_primary_flag                   IN VARCHAR2,
    x_site_use_id                    IN NUMBER,
    x_start_date                     IN DATE,
    x_end_date                       IN DATE,
    x_attribute_category             IN VARCHAR2,
    x_attribute1                     IN VARCHAR2,
    x_attribute2                     IN VARCHAR2,
    x_attribute3                     IN VARCHAR2,
    x_attribute4                     IN VARCHAR2,
    x_attribute5                     IN VARCHAR2,
    x_attribute6                     IN VARCHAR2,
    x_attribute7                     IN VARCHAR2,
    x_attribute8                     IN VARCHAR2,
    x_attribute9                     IN VARCHAR2,
    x_attribute10                    IN VARCHAR2,
    x_attribute11                    IN VARCHAR2,
    x_attribute12                    IN VARCHAR2,
    x_attribute13                    IN VARCHAR2,
    x_attribute14                    IN VARCHAR2,
    x_attribute15                    IN VARCHAR2
  ) IS

  BEGIN

    UPDATE ra_cust_receipt_methods
    SET   cust_receipt_method_id = DECODE(x_cust_receipt_method_id, NULL,
                            cust_receipt_method_id, fnd_api.g_miss_num, NULL,
                            x_cust_receipt_method_id),
          customer_id = DECODE(x_customer_id, NULL, customer_id, fnd_api.g_miss_num,
                            NULL, x_customer_id),
          receipt_method_id = DECODE(x_receipt_method_id, NULL, receipt_method_id,
                            fnd_api.g_miss_num, NULL, x_receipt_method_id),
          primary_flag = DECODE(x_primary_flag, NULL, primary_flag,
                            fnd_api.g_miss_char, NULL, x_primary_flag),
          site_use_id = DECODE(x_site_use_id, NULL, site_use_id,
                            fnd_api.g_miss_num, NULL, x_site_use_id),
          start_date = DECODE(x_start_date, NULL, start_date,
                            fnd_api.g_miss_date, NULL, x_start_date),
          end_date = DECODE(x_end_date, NULL, end_date,
                            fnd_api.g_miss_date, NULL, x_end_date),
          attribute_category = DECODE(x_attribute_category, NULL, attribute_category,
                            fnd_api.g_miss_char, NULL, x_attribute_category),
          attribute1 = DECODE(x_attribute1, NULL, attribute1, fnd_api.g_miss_char,
                              NULL, x_attribute1),
          attribute2 = DECODE(x_attribute2, NULL, attribute2, fnd_api.g_miss_char,
                              NULL, x_attribute2),
          attribute3 = DECODE(x_attribute3, NULL, attribute3, fnd_api.g_miss_char,
                              NULL, x_attribute3),
          attribute4 = DECODE(x_attribute4, NULL, attribute4, fnd_api.g_miss_char,
                              NULL, x_attribute4),
          attribute5 = DECODE(x_attribute5, NULL, attribute5, fnd_api.g_miss_char,
                              NULL, x_attribute5),
          attribute6 = DECODE(x_attribute6, NULL, attribute6, fnd_api.g_miss_char,
                              NULL, x_attribute6),
          attribute7 = DECODE(x_attribute7, NULL, attribute7, fnd_api.g_miss_char,
                              NULL, x_attribute7),
          attribute8 = DECODE(x_attribute8, NULL, attribute8, fnd_api.g_miss_char,
                              NULL, x_attribute8),
          attribute9 = DECODE(x_attribute9, NULL, attribute9, fnd_api.g_miss_char,
                              NULL, x_attribute9),
          attribute10 = DECODE(x_attribute10, NULL, attribute10, fnd_api.g_miss_char,
                              NULL, x_attribute10),
          last_update_date = hz_utility_v2pub.last_update_date,
          last_updated_by = hz_utility_v2pub.last_updated_by,
          creation_date = creation_date,
          created_by = created_by,
          last_update_login = hz_utility_v2pub.last_update_login,
          request_id = hz_utility_v2pub.request_id,
          program_application_id = hz_utility_v2pub.program_application_id,
          program_id = hz_utility_v2pub.program_id,
          program_update_date = hz_utility_v2pub.program_update_date
    WHERE rowid = x_rowid;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
  END Update_Row;

  PROCEDURE Lock_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_cust_receipt_method_id         IN NUMBER,
    x_customer_id                    IN NUMBER,
    x_receipt_method_id              IN NUMBER,
    x_primary_flag                   IN VARCHAR2,
    x_site_use_id                    IN NUMBER,
    x_start_date                     IN DATE,
    x_end_date                       IN DATE,
    x_attribute_category             IN VARCHAR2,
    x_attribute1                     IN VARCHAR2,
    x_attribute2                     IN VARCHAR2,
    x_attribute3                     IN VARCHAR2,
    x_attribute4                     IN VARCHAR2,
    x_attribute5                     IN VARCHAR2,
    x_attribute6                     IN VARCHAR2,
    x_attribute7                     IN VARCHAR2,
    x_attribute8                     IN VARCHAR2,
    x_attribute9                     IN VARCHAR2,
    x_attribute10                    IN VARCHAR2,
    x_attribute11                    IN VARCHAR2,
    x_attribute12                    IN VARCHAR2,
    x_attribute13                    IN VARCHAR2,
    x_attribute14                    IN VARCHAR2,
    x_attribute15                    IN VARCHAR2,
    x_last_update_date               IN DATE,
    x_last_updated_by                IN NUMBER,
    x_creation_date                  IN DATE,
    x_created_by                     IN NUMBER,
    x_last_update_login              IN NUMBER,
    x_request_id                     IN NUMBER,
    x_program_application_id         IN NUMBER,
    x_program_id                     IN NUMBER,
    x_program_update_date            IN DATE
  ) IS

    CURSOR c IS
      SELECT *
      FROM   ra_cust_receipt_methods
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

    IF (((recinfo.cust_receipt_method_id = x_cust_receipt_method_id)
         OR ((recinfo.cust_receipt_method_id IS NULL)
              AND (x_cust_receipt_method_id IS NULL)))
        AND ((recinfo.customer_id = x_customer_id)
            OR ((recinfo.customer_id IS NULL)
                 AND (x_customer_id IS NULL)))
        AND ((recinfo.receipt_method_id = x_receipt_method_id)
            OR ((recinfo.receipt_method_id IS NULL)
                 AND (x_receipt_method_id IS NULL)))
        AND ((recinfo.primary_flag = x_primary_flag)
            OR ((recinfo.primary_flag IS NULL)
                 AND (x_primary_flag IS NULL)))
        AND ((recinfo.site_use_id = x_site_use_id)
            OR ((recinfo.site_use_id IS NULL)
                 AND (x_site_use_id IS NULL)))
        AND ((recinfo.start_date = x_start_date)
            OR ((recinfo.start_date IS NULL)
                 AND (x_start_date IS NULL)))
        AND ((recinfo.end_date = x_end_date)
            OR ((recinfo.end_date IS NULL)
                 AND (x_start_date IS NULL)))
        AND ((recinfo.attribute_category = x_attribute_category)
            OR ((recinfo.attribute_category IS NULL)
                 AND (x_attribute_category IS NULL)))
        AND ((recinfo.attribute1 = x_attribute1)
            OR ((recinfo.attribute1 IS NULL)
                 AND (x_attribute1 IS NULL)))
        AND ((recinfo.attribute2 = x_attribute2)
            OR ((recinfo.attribute2 IS NULL)
                 AND (x_attribute2 IS NULL)))
        AND ((recinfo.attribute3 = x_attribute3)
            OR ((recinfo.attribute3 IS NULL)
                 AND (x_attribute3 IS NULL)))
        AND ((recinfo.attribute4 = x_attribute4)
            OR ((recinfo.attribute4 IS NULL)
                 AND (x_attribute4 IS NULL)))
        AND ((recinfo.attribute5 = x_attribute5)
            OR ((recinfo.attribute5 IS NULL)
                 AND (x_attribute5 IS NULL)))
        AND ((recinfo.attribute6 = x_attribute6)
            OR ((recinfo.attribute6 IS NULL)
                 AND (x_attribute6 IS NULL)))
        AND ((recinfo.attribute7 = x_attribute7)
            OR ((recinfo.attribute7 IS NULL)
                 AND (x_attribute7 IS NULL)))
        AND ((recinfo.attribute8 = x_attribute8)
            OR ((recinfo.attribute8 IS NULL)
                 AND (x_attribute8 IS NULL)))
        AND ((recinfo.attribute9 = x_attribute9)
            OR ((recinfo.attribute9 IS NULL)
                 AND (x_attribute9 IS NULL)))
        AND ((recinfo.attribute10 = x_attribute10)
            OR ((recinfo.attribute10 IS NULL)
                 AND (x_attribute10 IS NULL)))
        AND ((recinfo.attribute11 = x_attribute11)
            OR ((recinfo.attribute11 IS NULL)
                 AND (x_attribute11 IS NULL)))
        AND ((recinfo.attribute12 = x_attribute12)
            OR ((recinfo.attribute12 IS NULL)
                 AND (x_attribute12 IS NULL)))
        AND ((recinfo.attribute13 = x_attribute13)
            OR ((recinfo.attribute13 IS NULL)
                 AND (x_attribute13 IS NULL)))
        AND ((recinfo.attribute14 = x_attribute14)
            OR ((recinfo.attribute14 IS NULL)
                 AND (x_attribute14 IS NULL)))
        AND ((recinfo.attribute15 = x_attribute15)
            OR ((recinfo.attribute15 IS NULL)
                 AND (x_attribute15 IS NULL)))
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
        AND ((recinfo.request_id = x_request_id)
             OR ((recinfo.request_id IS NULL)
                 AND (x_request_id IS NULL)))
        AND ((recinfo.program_application_id = x_program_application_id)
             OR ((recinfo.program_application_id IS NULL)
                 AND (x_program_application_id IS NULL)))
        AND ((recinfo.program_id = x_program_id)
             OR ((recinfo.program_id IS NULL)
                 AND (x_program_id IS NULL)))
        AND ((recinfo.program_update_date = x_program_update_date)
             OR ((recinfo.program_update_date IS NULL)
                 AND (x_program_update_date IS NULL)))
    )
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
  END lock_row;


  PROCEDURE delete_row (x_cust_receipt_method_id IN NUMBER) IS
  BEGIN
    DELETE FROM ra_cust_receipt_methods
    WHERE cust_receipt_method_id = x_cust_receipt_method_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

END HZ_PAYMENT_METHOD_PKG;

/
