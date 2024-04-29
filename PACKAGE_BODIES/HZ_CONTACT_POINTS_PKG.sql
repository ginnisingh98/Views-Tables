--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_POINTS_PKG" AS
/*$Header: ARHCPTTB.pls 120.5 2006/05/05 09:19:20 pkasturi ship $ */

  G_MISS_CONTENT_SOURCE_TYPE                CONSTANT VARCHAR2(30) := 'USER_ENTERED';

  PROCEDURE insert_row (
    x_contact_point_id                      IN OUT NOCOPY NUMBER,
    x_contact_point_type                    IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
    x_primary_flag                          IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2,
    x_edi_transaction_handling              IN     VARCHAR2,
    x_edi_id_number                         IN     VARCHAR2,
    x_edi_payment_method                    IN     VARCHAR2,
    x_edi_payment_format                    IN     VARCHAR2,
    x_edi_remittance_method                 IN     VARCHAR2,
    x_edi_remittance_instruction            IN     VARCHAR2,
    x_edi_tp_header_id                      IN     NUMBER,
    x_edi_ece_tp_location_code              IN     VARCHAR2,
    x_eft_transmission_program_id           IN     NUMBER,
    x_eft_printing_program_id               IN     NUMBER,
    x_eft_user_number                       IN     VARCHAR2,
    x_eft_swift_code                        IN     VARCHAR2,
    x_email_format                          IN     VARCHAR2,
    x_email_address                         IN     VARCHAR2,
    x_phone_calling_calendar                IN     VARCHAR2,
    x_last_contact_dt_time                  IN     DATE,
    x_timezone_id                           IN     NUMBER,
    x_phone_area_code                       IN     VARCHAR2,
    x_phone_country_code                    IN     VARCHAR2,
    x_phone_number                          IN     VARCHAR2,
    x_phone_extension                       IN     VARCHAR2,
    x_phone_line_type                       IN     VARCHAR2,
    x_telex_number                          IN     VARCHAR2,
    x_web_type                              IN     VARCHAR2,
    x_url                                   IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_raw_phone_number                      IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_contact_point_purpose                 IN     VARCHAR2,
    x_primary_by_purpose                    IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_transposed_phone_number               IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
  ) IS

    l_success                               VARCHAR2(1) := 'N';

    l_primary_key_passed                    BOOLEAN := FALSE;

  BEGIN

    -- The following lines are used to take care of the situation
    -- when content_source_type IS not USER_ENTERED, because of
    -- policy funcation, when we do unique validation, we cannot
    -- see all of the records. Thus, we have to double check here
    -- and raise corresponding exception. We donot need to do anything
    -- for those tables without policy functions.

    IF x_contact_point_id IS NOT NULL AND
       x_contact_point_id <> fnd_api.g_miss_num
    THEN
        l_primary_key_passed := TRUE;
    END IF;

    IF x_contact_point_id = fnd_api.g_miss_num THEN
      x_contact_point_id := NULL;
    END IF;

    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO HZ_CONTACT_POINTS (
          contact_point_id,
          contact_point_type,
          status,
          owner_table_name,
          owner_table_id,
          primary_flag,
          orig_system_reference,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
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
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          edi_transaction_handling,
          edi_id_number,
          edi_payment_method,
          edi_payment_format,
          edi_remittance_method,
          edi_remittance_instruction,
          edi_tp_header_id,
          edi_ece_tp_location_code,
          eft_transmission_program_id,
          eft_printing_program_id,
          eft_user_number,
          eft_swift_code,
          email_format,
          email_address,
          phone_calling_calendar,
          last_contact_dt_time,
          timezone_id,
          phone_area_code,
          phone_country_code,
          phone_number,
          phone_extension,
          phone_line_type,
          telex_number,
          web_type,
          url,
          content_source_type,
          raw_phone_number,
          object_version_number,
          contact_point_purpose,
          primary_by_purpose,
          created_by_module,
          application_id,
          transposed_phone_number,
          ACTUAL_CONTENT_SOURCE
        )
        VALUES (
          DECODE(x_contact_point_id,
                 fnd_api.g_miss_num, hz_contact_points_s.NEXTVAL,
                 NULL, hz_contact_points_s.nextval,
                 x_contact_point_id),
          DECODE(x_contact_point_type,
                 fnd_api.g_miss_char, NULL, x_contact_point_type),
          DECODE(x_status, fnd_api.g_miss_char, 'A', NULL, 'A', x_status),
          DECODE(x_owner_table_name,
                 fnd_api.g_miss_char, NULL, x_owner_table_name),
          DECODE(x_owner_table_id,
                 fnd_api.g_miss_num, NULL, x_owner_table_id),
          DECODE(x_primary_flag,
                 fnd_api.g_miss_char, 'N', NULL, 'N', x_primary_flag),
          DECODE(x_orig_system_reference,
                 fnd_api.g_miss_char, TO_CHAR(NVL(x_contact_point_id,
                                                 hz_contact_points_s.CURRVAL)),
                 NULL, TO_CHAR(NVL(x_contact_point_id,
                                   hz_contact_points_s.CURRVAL)),
                 x_orig_system_reference),
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by,
          hz_utility_v2pub.creation_date,
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.last_update_login,
          hz_utility_v2pub.request_id,
          hz_utility_v2pub.program_application_id,
          hz_utility_v2pub.program_id,
          hz_utility_v2pub.program_update_date,
          DECODE(x_attribute_category,
                 fnd_api.g_miss_char, NULL, x_attribute_category),
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
          DECODE(x_attribute16, fnd_api.g_miss_char, NULL, x_attribute16),
          DECODE(x_attribute17, fnd_api.g_miss_char, NULL, x_attribute17),
          DECODE(x_attribute18, fnd_api.g_miss_char, NULL, x_attribute18),
          DECODE(x_attribute19, fnd_api.g_miss_char, NULL, x_attribute19),
          DECODE(x_attribute20, fnd_api.g_miss_char, NULL, x_attribute20),
          DECODE(x_edi_transaction_handling,
                 fnd_api.g_miss_char, NULL, x_edi_transaction_handling),
          DECODE(x_edi_id_number, fnd_api.g_miss_char, NULL, x_edi_id_number),
          DECODE(x_edi_payment_method,
                 fnd_api.g_miss_char, NULL, x_edi_payment_method),
          DECODE(x_edi_payment_format,
                 fnd_api.g_miss_char, NULL, x_edi_payment_format),
          DECODE(x_edi_remittance_method,
                 fnd_api.g_miss_char, NULL, x_edi_remittance_method),
          DECODE(x_edi_remittance_instruction,
                 fnd_api.g_miss_char, NULL, x_edi_remittance_instruction),
          DECODE(x_edi_tp_header_id,
                 fnd_api.g_miss_num, NULL, x_edi_tp_header_id),
          DECODE(x_edi_ece_tp_location_code,
                 fnd_api.g_miss_char, NULL, x_edi_ece_tp_location_code),
          DECODE(x_eft_transmission_program_id,
                 fnd_api.g_miss_num, NULL, x_eft_transmission_program_id),
          DECODE(x_eft_printing_program_id,
                 fnd_api.g_miss_num, NULL, x_eft_printing_program_id),
          DECODE(x_eft_user_number,
                 fnd_api.g_miss_char, NULL, x_eft_user_number),
          DECODE(x_eft_swift_code,
                 fnd_api.g_miss_char, NULL, x_eft_swift_code),
      ---Bug No. 4359226
          DECODE(x_email_format,
                 fnd_api.g_miss_char, DECODE(x_contact_point_type,
                                             'EMAIL', 'MAILTEXT', NULL),
                 NULL, DECODE(x_contact_point_type, 'EMAIL', 'MAILTEXT', NULL),
                 x_email_format),
      ----Bug No. 4359226
      --Bug 4355133
          SUBSTRB(DECODE(x_email_address, fnd_api.g_miss_char, NULL,
	  x_email_address),1,320),
          DECODE(x_phone_calling_calendar,
                 fnd_api.g_miss_char, NULL, x_phone_calling_calendar),
          DECODE(x_last_contact_dt_time,
                 fnd_api.g_miss_date, to_date(NULL), x_last_contact_dt_time),
          DECODE(x_timezone_id, fnd_api.g_miss_num, NULL, x_timezone_id),
          DECODE(x_phone_area_code,
                 fnd_api.g_miss_char, NULL, x_phone_area_code),
          DECODE(x_phone_country_code,
                 fnd_api.g_miss_char, NULL, x_phone_country_code),
          DECODE(x_phone_number, fnd_api.g_miss_char, NULL, x_phone_number),
          DECODE(x_phone_extension,
                 fnd_api.g_miss_char, NULL, x_phone_extension),
          DECODE(x_phone_line_type,
                 fnd_api.g_miss_char, NULL, x_phone_line_type),
          DECODE(x_telex_number, fnd_api.g_miss_char, NULL, x_telex_number),
          DECODE(x_web_type, fnd_api.g_miss_char, NULL, x_web_type),
          DECODE(x_url, fnd_api.g_miss_char, NULL, x_url),
          DECODE(x_content_source_type,
                 fnd_api.g_miss_char, g_miss_content_source_type,
                 NULL, g_miss_content_source_type,
                 x_content_source_type),
          DECODE(x_raw_phone_number,
                 fnd_api.g_miss_char, NULL, x_raw_phone_number),
          DECODE(x_object_version_number,
                 fnd_api.g_miss_num, NULL, x_object_version_number),
          DECODE(x_contact_point_purpose,
                 fnd_api.g_miss_char, NULL, x_contact_point_purpose),
          DECODE(x_primary_by_purpose,
                 fnd_api.g_miss_char, 'N', NULL, 'N', x_primary_by_purpose),
          DECODE(x_created_by_module,
                 fnd_api.g_miss_char, NULL, x_created_by_module),
          DECODE(x_application_id,
                 fnd_api.g_miss_num, NULL, x_application_id),
          DECODE(x_transposed_phone_number,
                 fnd_api.g_miss_char, NULL, x_transposed_phone_number),
          DECODE(x_actual_content_source,
                 fnd_api.g_miss_char, g_miss_content_source_type,
                 NULL, g_miss_content_source_type,
                 x_actual_content_source )
        )
        RETURNING contact_point_id INTO x_contact_point_id;

        l_success := 'Y';

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          IF INSTRB(SQLERRM, 'HZ_CONTACT_POINTS_U1') <> 0 OR
             INSTRB(SQLERRM, 'HZ_CONTACT_POINTS_PK') <> 0
          THEN
            IF l_primary_key_passed THEN
              fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
              fnd_message.set_token('COLUMN', 'contact_point_id');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;

            -- code to find a valid contact point ID.
            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);

              CURSOR c_idseq IS
                SELECT hz_contact_points_s.NEXTVAL
                FROM dual;
              CURSOR c_cpchk IS
                SELECT 'Y'
                FROM   hz_contact_points
                WHERE  contact_point_id = x_contact_point_id;
            BEGIN
              l_count := 1;

              WHILE l_count > 0 LOOP
                OPEN c_idseq;
                FETCH c_idseq INTO x_contact_point_id;

                IF c_idseq%NOTFOUND THEN
                  CLOSE c_idseq;
                  RAISE NO_DATA_FOUND;
                ELSE
                  CLOSE c_idseq;
                END IF;

                OPEN c_cpchk;
                FETCH c_cpchk INTO l_dummy;

                IF c_cpchk%NOTFOUND THEN
                  l_count := 0;
                ELSE
                  l_count := 1;
                END IF;

                CLOSE c_cpchk;
              END LOOP;
            END;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP;
  END insert_row;

  PROCEDURE update_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_contact_point_id                      IN     NUMBER,
    x_contact_point_type                    IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
    x_primary_flag                          IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2,
    x_edi_transaction_handling              IN     VARCHAR2,
    x_edi_id_number                         IN     VARCHAR2,
    x_edi_payment_method                    IN     VARCHAR2,
    x_edi_payment_format                    IN     VARCHAR2,
    x_edi_remittance_method                 IN     VARCHAR2,
    x_edi_remittance_instruction            IN     VARCHAR2,
    x_edi_tp_header_id                      IN     NUMBER,
    x_edi_ece_tp_location_code              IN     VARCHAR2,
    x_eft_transmission_program_id           IN     NUMBER,
    x_eft_printing_program_id               IN     NUMBER,
    x_eft_user_number                       IN     VARCHAR2,
    x_eft_swift_code                        IN     VARCHAR2,
    x_email_format                          IN     VARCHAR2,
    x_email_address                         IN     VARCHAR2,
    x_phone_calling_calendar                IN     VARCHAR2,
    x_last_contact_dt_time                  IN     DATE,
    x_timezone_id                           IN     NUMBER,
    x_phone_area_code                       IN     VARCHAR2,
    x_phone_country_code                    IN     VARCHAR2,
    x_phone_number                          IN     VARCHAR2,
    x_phone_extension                       IN     VARCHAR2,
    x_phone_line_type                       IN     VARCHAR2,
    x_telex_number                          IN     VARCHAR2,
    x_web_type                              IN     VARCHAR2,
    x_url                                   IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_raw_phone_number                      IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_contact_point_purpose                 IN     VARCHAR2,
    x_primary_by_purpose                    IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_transposed_phone_number               IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2 DEFAULT NULL
  ) IS

  BEGIN

    UPDATE hz_contact_points SET
      contact_point_id          = DECODE(x_contact_point_id,
                                         NULL, contact_point_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_contact_point_id),
      contact_point_type        = DECODE(x_contact_point_type,
                                         NULL, contact_point_type,
                                         fnd_api.g_miss_char, NULL,
                                         x_contact_point_type),
      status                    = DECODE(x_status,
                                         NULL, status,
                                         fnd_api.g_miss_char, 'A',
                                         x_status),
      owner_table_name          = DECODE(x_owner_table_name,
                                         NULL, owner_table_name,
                                         fnd_api.g_miss_char, NULL,
                                         x_owner_table_name),
      owner_table_id            = DECODE(x_owner_table_id,
                                         NULL, owner_table_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_owner_table_id),
      primary_flag              = DECODE(x_primary_flag,
                                         NULL, primary_flag,
                                         fnd_api.g_miss_char, 'N',
                                         x_primary_flag),
      orig_system_reference     = DECODE(x_orig_system_reference,
                                         NULL, orig_system_reference,
                                         fnd_api.g_miss_char,
                                           TO_CHAR(x_contact_point_id),
                                         x_orig_system_reference),
      last_update_date          = hz_utility_v2pub.last_update_date,
      last_updated_by           = hz_utility_v2pub.last_updated_by,
      creation_date             = creation_date,
      created_by                = created_by,
      last_update_login         = hz_utility_v2pub.last_update_login,
      request_id                = hz_utility_v2pub.request_id,
      program_application_id    = hz_utility_v2pub.program_application_id,
      program_id                = hz_utility_v2pub.program_id,
      program_update_date       = hz_utility_v2pub.program_update_date,
      attribute_category        = DECODE(x_attribute_category,
                                         NULL, attribute_category,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute_category),
      attribute1                = DECODE(x_attribute1,
                                         NULL, attribute1,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute1),
      attribute2                = DECODE(x_attribute2,
                                         NULL, attribute2,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute2),
      attribute3                = DECODE(x_attribute3,
                                         NULL, attribute3,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute3),
      attribute4                = DECODE(x_attribute4,
                                         NULL, attribute4,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute4),
      attribute5                = DECODE(x_attribute5,
                                         NULL, attribute5,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute5),
      attribute6                = DECODE(x_attribute6,
                                         NULL, attribute6,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute6),
      attribute7                = DECODE(x_attribute7,
                                         NULL, attribute7,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute7),
      attribute8                = DECODE(x_attribute8,
                                         NULL, attribute8,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute8),
      attribute9                = DECODE(x_attribute9,
                                         NULL, attribute9,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute9),
      attribute10               = DECODE(x_attribute10,
                                         NULL, attribute10,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute10),
      attribute11               = DECODE(x_attribute11,
                                         NULL, attribute11,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute11),
      attribute12               = DECODE(x_attribute12,
                                         NULL, attribute12,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute12),
      attribute13               = DECODE(x_attribute13,
                                         NULL, attribute13,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute13),
      attribute14               = DECODE(x_attribute14,
                                         NULL, attribute14,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute14),
      attribute15               = DECODE(x_attribute15,
                                         NULL, attribute15,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute15),
      attribute16               = DECODE(x_attribute16,
                                         NULL, attribute16,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute16),
      attribute17               = DECODE(x_attribute17,
                                         NULL, attribute17,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute17),
      attribute18               = DECODE(x_attribute18,
                                         NULL, attribute18,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute18),
      attribute19               = DECODE(x_attribute19,
                                         NULL, attribute19,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute19),
      attribute20               = DECODE(x_attribute20,
                                         NULL, attribute20,
                                         fnd_api.g_miss_char, NULL,
                                         x_attribute20),
      edi_transaction_handling  = DECODE(x_edi_transaction_handling,
                                         NULL, edi_transaction_handling,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_transaction_handling),
      edi_id_number             = DECODE(x_edi_id_number,
                                         NULL, edi_id_number,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_id_number),
      edi_payment_method        = DECODE(x_edi_payment_method,
                                         NULL, edi_payment_method,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_payment_method),
      edi_payment_format        = DECODE(x_edi_payment_format,
                                         NULL, edi_payment_format,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_payment_format),
      edi_remittance_method     = DECODE(x_edi_remittance_method,
                                         NULL, edi_remittance_method,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_remittance_method),
      edi_remittance_instruction= DECODE(x_edi_remittance_instruction,
                                         NULL, edi_remittance_instruction,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_remittance_instruction),
      edi_tp_header_id          = DECODE(x_edi_tp_header_id,
                                         NULL, edi_tp_header_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_edi_tp_header_id),
      edi_ece_tp_location_code  = DECODE(x_edi_ece_tp_location_code,
                                         NULL, edi_ece_tp_location_code,
                                         fnd_api.g_miss_char, NULL,
                                         x_edi_ece_tp_location_code),
      eft_transmission_program_id=DECODE(x_eft_transmission_program_id,
                                         NULL, eft_transmission_program_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_eft_transmission_program_id),
      eft_printing_program_id   = DECODE(x_eft_printing_program_id,
                                         NULL, eft_printing_program_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_eft_printing_program_id),
      eft_user_number           = DECODE(x_eft_user_number,
                                         NULL, eft_user_number,
                                         fnd_api.g_miss_char, NULL,
                                         x_eft_user_number),
      eft_swift_code            = DECODE(x_eft_swift_code,
                                         NULL, eft_swift_code,
                                         fnd_api.g_miss_char, NULL,
                                         x_eft_swift_code),
      email_format              = DECODE(x_email_format,
                                         NULL, email_format,
                                         fnd_api.g_miss_char, NULL,
                                         x_email_format),
     --Bug 4355133
     email_address             = SUBSTRB(DECODE(x_email_address,
                                         NULL, email_address,
                                         fnd_api.g_miss_char, NULL,
                                         x_email_address),1,320),
      phone_calling_calendar    = DECODE(x_phone_calling_calendar,
                                         NULL, phone_calling_calendar,
                                         fnd_api.g_miss_char, NULL,
                                         x_phone_calling_calendar),
      last_contact_dt_time      = DECODE(x_last_contact_dt_time,
                                         NULL, last_contact_dt_time,
                                         fnd_api.g_miss_date, NULL,
                                         x_last_contact_dt_time),
      timezone_id               = DECODE(x_timezone_id,
                                         NULL, timezone_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_timezone_id),
      phone_area_code           = DECODE(x_phone_area_code,
                                         NULL, phone_area_code,
                                         fnd_api.g_miss_char, NULL,
                                         x_phone_area_code),
      phone_country_code        = DECODE(x_phone_country_code,
                                         NULL, phone_country_code,
                                         fnd_api.g_miss_char, NULL,
                                         x_phone_country_code),
      phone_number              = DECODE(x_phone_number,
                                         NULL, phone_number,
                                         fnd_api.g_miss_char, NULL,
                                         x_phone_number),
      phone_extension           = DECODE(x_phone_extension,
                                         NULL, phone_extension,
                                         fnd_api.g_miss_char, NULL,
                                         x_phone_extension),
      phone_line_type           = DECODE(x_phone_line_type,
                                         NULL, phone_line_type,
                                         fnd_api.g_miss_char, NULL,
                                         x_phone_line_type),
      telex_number              = DECODE(x_telex_number,
                                         NULL, telex_number,
                                         fnd_api.g_miss_char, NULL,
                                         x_telex_number),
      web_type                  = DECODE(x_web_type,
                                         NULL, web_type,
                                         fnd_api.g_miss_char, NULL,
                                         x_web_type),
      url                       = DECODE(x_url,
                                         NULL, url,
                                         fnd_api.g_miss_char, NULL,
                                         x_url),
      content_source_type       = DECODE(x_content_source_type,
                                         NULL, content_source_type,
                                         fnd_api.g_miss_char, NULL,
                                         x_content_source_type),
      raw_phone_number          = DECODE(x_raw_phone_number,
                                         NULL, raw_phone_number,
                                         fnd_api.g_miss_char, NULL,
                                         x_raw_phone_number),
      object_version_number     = DECODE(x_object_version_number,
                                         NULL, object_version_number,
                                         fnd_api.g_miss_num, NULL,
                                         x_object_version_number),
      contact_point_purpose     = DECODE(x_contact_point_purpose,
                                         NULL, contact_point_purpose,
                                         fnd_api.g_miss_char, NULL,
                                         x_contact_point_purpose),
      primary_by_purpose        = DECODE(x_primary_by_purpose,
                                         NULL, primary_by_purpose,
                                         fnd_api.g_miss_char, 'N',
                                         x_primary_by_purpose),
      created_by_module         = DECODE(x_created_by_module,
                                         NULL, created_by_module,
                                         fnd_api.g_miss_char, NULL,
                                         x_created_by_module),
      application_id            = DECODE(x_application_id,
                                         NULL, application_id,
                                         fnd_api.g_miss_num, NULL,
                                         x_application_id),
      transposed_phone_number   = DECODE(x_transposed_phone_number,
                                         NULL, transposed_phone_number,
                                         fnd_api.g_miss_char, NULL,
                                         x_transposed_phone_number),
      actual_content_source     = DECODE(x_actual_content_source,
                                         NULL, actual_content_source,
                                         fnd_api.g_miss_char, NULL,
                                         x_actual_content_source)
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

  END update_row;

  PROCEDURE lock_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_contact_point_id                      IN     NUMBER,
    x_contact_point_type                    IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_owner_table_name                      IN     VARCHAR2,
    x_owner_table_id                        IN     NUMBER,
    x_primary_flag                          IN     VARCHAR2,
    x_orig_system_reference                 IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2,
    x_edi_transaction_handling              IN     VARCHAR2,
    x_edi_id_number                         IN     VARCHAR2,
    x_edi_payment_method                    IN     VARCHAR2,
    x_edi_payment_format                    IN     VARCHAR2,
    x_edi_remittance_method                 IN     VARCHAR2,
    x_edi_remittance_instruction            IN     VARCHAR2,
    x_edi_tp_header_id                      IN     NUMBER,
    x_edi_ece_tp_location_code              IN     VARCHAR2,
    x_eft_transmission_program_id           IN     NUMBER,
    x_eft_printing_program_id               IN     NUMBER,
    x_eft_user_number                       IN     VARCHAR2,
    x_eft_swift_code                        IN     VARCHAR2,
    x_email_format                          IN     VARCHAR2,
    x_email_address                         IN     VARCHAR2,
    x_phone_calling_calendar                IN     VARCHAR2,
    x_last_contact_dt_time                  IN     DATE,
    x_timezone_id                           IN     NUMBER,
    x_phone_area_code                       IN     VARCHAR2,
    x_phone_country_code                    IN     VARCHAR2,
    x_phone_number                          IN     VARCHAR2,
    x_phone_extension                       IN     VARCHAR2,
    x_phone_line_type                       IN     VARCHAR2,
    x_telex_number                          IN     VARCHAR2,
    x_web_type                              IN     VARCHAR2,
    x_url                                   IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_raw_phone_number                      IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_contact_point_purpose                 IN     VARCHAR2,
    x_primary_by_purpose                    IN     VARCHAR2,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_transposed_phone_number               IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2 DEFAULT NULL
  ) IS

    CURSOR c IS
      SELECT *
      FROM   hz_contact_points
      WHERE  ROWID = x_rowid
      FOR UPDATE NOWAIT;
    recinfo C%ROWTYPE;

  BEGIN

    OPEN c;
    FETCH c INTO recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
    END IF;
    CLOSE c;

    IF (((recinfo.contact_point_id = x_contact_point_id)
         OR ((recinfo.contact_point_id IS NULL)
             AND (x_contact_point_id IS NULL)))
        AND ((recinfo.contact_point_type = x_contact_point_type)
             OR ((recinfo.contact_point_type IS NULL)
                 AND (x_contact_point_type IS NULL)))
        AND ((recinfo.status = x_status)
             OR ((recinfo.status IS NULL)
                 AND (x_status IS NULL)))
        AND ((recinfo.owner_table_name = x_owner_table_name)
             OR ((recinfo.owner_table_name IS NULL)
                 AND (x_owner_table_name IS NULL)))
        AND ((recinfo.owner_table_id = x_owner_table_id)
             OR ((recinfo.owner_table_id IS NULL)
                 AND (x_owner_table_id IS NULL)))
        AND ((recinfo.primary_flag = x_primary_flag)
             OR ((recinfo.primary_flag IS NULL)
                 AND (x_primary_flag IS NULL)))
        AND ((recinfo.orig_system_reference = x_orig_system_reference)
             OR ((recinfo.orig_system_reference IS NULL)
                 AND (x_orig_system_reference IS NULL)))
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
        AND ((recinfo.attribute16 = x_attribute16)
             OR ((recinfo.attribute16 IS NULL)
                 AND (x_attribute16 IS NULL)))
        AND ((recinfo.attribute17 = x_attribute17)
             OR ((recinfo.attribute17 IS NULL)
                 AND (x_attribute17 IS NULL)))
        AND ((recinfo.attribute18 = x_attribute18)
             OR ((recinfo.attribute18 IS NULL)
                 AND (x_attribute18 IS NULL)))
        AND ((recinfo.attribute19 = x_attribute19)
             OR ((recinfo.attribute19 IS NULL)
                 AND (x_attribute19 IS NULL)))
        AND ((recinfo.attribute20 = x_attribute20)
             OR ((recinfo.attribute20 IS NULL)
                 AND (x_attribute20 IS NULL)))
        AND ((recinfo.edi_transaction_handling = x_edi_transaction_handling)
             OR ((recinfo.edi_transaction_handling IS NULL)
                 AND (x_edi_transaction_handling IS NULL)))
        AND ((recinfo.edi_id_number = x_edi_id_number)
             OR ((recinfo.edi_id_number IS NULL)
                 AND (x_edi_id_number IS NULL)))
        AND ((recinfo.edi_payment_method = x_edi_payment_method)
             OR ((recinfo.edi_payment_method IS NULL)
                 AND (x_edi_payment_method IS NULL)))
        AND ((recinfo.edi_payment_format = x_edi_payment_format)
             OR ((recinfo.edi_payment_format IS NULL)
                 AND (x_edi_payment_format IS NULL)))
        AND ((recinfo.edi_remittance_method = x_edi_remittance_method)
             OR ((recinfo.edi_remittance_method IS NULL)
                 AND (x_edi_remittance_method IS NULL)))
        AND ((recinfo.edi_remittance_instruction
              = x_edi_remittance_instruction)
             OR ((recinfo.edi_remittance_instruction IS NULL)
                 AND (x_edi_remittance_instruction IS NULL)))
        AND ((recinfo.edi_tp_header_id = x_edi_tp_header_id)
             OR ((recinfo.edi_tp_header_id IS NULL)
                 AND (x_edi_tp_header_id IS NULL)))
        AND ((recinfo.edi_ece_tp_location_code = x_edi_ece_tp_location_code)
             OR ((recinfo.edi_ece_tp_location_code IS NULL)
                 AND (x_edi_ece_tp_location_code IS NULL)))
        AND ((recinfo.eft_transmission_program_id=x_eft_transmission_program_id)
             OR ((recinfo.eft_transmission_program_id IS NULL)
                 AND (x_eft_transmission_program_id IS NULL)))
        AND ((recinfo.eft_printing_program_id = x_eft_printing_program_id)
             OR ((recinfo.eft_printing_program_id IS NULL)
                 AND (x_eft_printing_program_id IS NULL)))
        AND ((recinfo.eft_user_number = x_eft_user_number)
             OR ((recinfo.eft_user_number IS NULL)
                 AND (x_eft_user_number IS NULL)))
        AND ((recinfo.eft_swift_code = x_eft_swift_code)
             OR ((recinfo.eft_swift_code IS NULL)
                 AND (x_eft_swift_code IS NULL)))
        AND ((recinfo.email_format = x_email_format)
             OR ((recinfo.email_format IS NULL)
                 AND (x_email_format IS NULL)))
        AND ((recinfo.email_address = x_email_address)
             OR ((recinfo.email_address IS NULL)
                 AND (x_email_address IS NULL)))
        AND ((recinfo.phone_calling_calendar = x_phone_calling_calendar)
             OR ((recinfo.phone_calling_calendar IS NULL)
                 AND (x_phone_calling_calendar IS NULL)))
        AND ((recinfo.last_contact_dt_time = x_last_contact_dt_time)
             OR ((recinfo.last_contact_dt_time IS NULL)
                 AND (x_last_contact_dt_time IS NULL)))
        AND ((recinfo.timezone_id = x_timezone_id)
             OR ((recinfo.timezone_id IS NULL)
                 AND (x_timezone_id IS NULL)))
        AND ((recinfo.phone_area_code = x_phone_area_code)
             OR ((recinfo.phone_area_code IS NULL)
                 AND (x_phone_area_code IS NULL)))
        AND ((recinfo.phone_country_code = x_phone_country_code)
             OR ((recinfo.phone_country_code IS NULL)
                 AND (x_phone_country_code IS NULL)))
        AND ((recinfo.phone_number = x_phone_number)
             OR ((recinfo.phone_number IS NULL)
                 AND (x_phone_number IS NULL)))
        AND ((recinfo.phone_extension = x_phone_extension)
             OR ((recinfo.phone_extension IS NULL)
                 AND (x_phone_extension IS NULL)))
        AND ((recinfo.phone_line_type = x_phone_line_type)
             OR ((recinfo.phone_line_type IS NULL)
                 AND (x_phone_line_type IS NULL)))
        AND ((recinfo.telex_number = x_telex_number)
             OR ((recinfo.telex_number IS NULL)
                 AND (x_telex_number IS NULL)))
        AND ((recinfo.web_type = x_web_type)
             OR ((recinfo.web_type IS NULL)
                 AND (x_web_type IS NULL)))
        AND ((recinfo.url = x_url)
             OR ((recinfo.url IS NULL)
                 AND (x_url IS NULL)))
        AND ((recinfo.content_source_type = x_content_source_type)
             OR ((recinfo.content_source_type IS NULL)
                 AND (x_content_source_type IS NULL)))
        AND ((recinfo.raw_phone_number = x_raw_phone_number)
             OR ((recinfo.raw_phone_number IS NULL)
                 AND (x_raw_phone_number IS NULL)))
        AND ((recinfo.object_version_number = x_object_version_number)
             OR ((recinfo.object_version_number IS NULL)
                 AND (x_object_version_number IS NULL)))
        AND ((recinfo.contact_point_purpose = x_contact_point_purpose)
             OR ((recinfo.contact_point_purpose IS NULL)
                 AND (x_contact_point_purpose IS NULL)))
        AND ((recinfo.primary_by_purpose = x_primary_by_purpose)
             OR ((recinfo.primary_by_purpose IS NULL)
                 AND (x_primary_by_purpose IS NULL)))
        AND ((recinfo.created_by_module = x_created_by_module)
             OR ((recinfo.created_by_module IS NULL)
                 AND (x_created_by_module IS NULL)))
        AND ((recinfo.application_id = x_application_id)
             OR ((recinfo.application_id IS NULL)
                 AND (x_application_id IS NULL)))
        AND ((recinfo.transposed_phone_number = x_transposed_phone_number)
             OR ((recinfo.transposed_phone_number IS NULL)
                 AND (x_transposed_phone_number IS NULL)))
        AND ((recinfo.content_source_type = x_content_source_type)
             OR ((recinfo.content_source_type IS NULL)
                 AND (x_content_source_type IS NULL)))
        )
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
  END lock_row;

  PROCEDURE select_row (
    x_contact_point_id                      IN OUT NOCOPY NUMBER,
    x_contact_point_type                    OUT NOCOPY    VARCHAR2,
    x_status                                OUT NOCOPY    VARCHAR2,
    x_owner_table_name                      OUT NOCOPY    VARCHAR2,
    x_owner_table_id                        OUT NOCOPY    NUMBER,
    x_primary_flag                          OUT NOCOPY    VARCHAR2,
    x_orig_system_reference                 OUT NOCOPY    VARCHAR2,
    x_attribute_category                    OUT NOCOPY    VARCHAR2,
    x_attribute1                            OUT NOCOPY    VARCHAR2,
    x_attribute2                            OUT NOCOPY    VARCHAR2,
    x_attribute3                            OUT NOCOPY    VARCHAR2,
    x_attribute4                            OUT NOCOPY    VARCHAR2,
    x_attribute5                            OUT NOCOPY    VARCHAR2,
    x_attribute6                            OUT NOCOPY    VARCHAR2,
    x_attribute7                            OUT NOCOPY    VARCHAR2,
    x_attribute8                            OUT NOCOPY    VARCHAR2,
    x_attribute9                            OUT NOCOPY    VARCHAR2,
    x_attribute10                           OUT NOCOPY    VARCHAR2,
    x_attribute11                           OUT NOCOPY    VARCHAR2,
    x_attribute12                           OUT NOCOPY    VARCHAR2,
    x_attribute13                           OUT NOCOPY    VARCHAR2,
    x_attribute14                           OUT NOCOPY    VARCHAR2,
    x_attribute15                           OUT NOCOPY    VARCHAR2,
    x_attribute16                           OUT NOCOPY    VARCHAR2,
    x_attribute17                           OUT NOCOPY    VARCHAR2,
    x_attribute18                           OUT NOCOPY    VARCHAR2,
    x_attribute19                           OUT NOCOPY    VARCHAR2,
    x_attribute20                           OUT NOCOPY    VARCHAR2,
    x_edi_transaction_handling              OUT NOCOPY    VARCHAR2,
    x_edi_id_number                         OUT NOCOPY    VARCHAR2,
    x_edi_payment_method                    OUT NOCOPY    VARCHAR2,
    x_edi_payment_format                    OUT NOCOPY    VARCHAR2,
    x_edi_remittance_method                 OUT NOCOPY    VARCHAR2,
    x_edi_remittance_instruction            OUT NOCOPY    VARCHAR2,
    x_edi_tp_header_id                      OUT NOCOPY    NUMBER,
    x_edi_ece_tp_location_code              OUT NOCOPY    VARCHAR2,
    x_eft_transmission_program_id           OUT NOCOPY    NUMBER,
    x_eft_printing_program_id               OUT NOCOPY    NUMBER,
    x_eft_user_number                       OUT NOCOPY    VARCHAR2,
    x_eft_swift_code                        OUT NOCOPY    VARCHAR2,
    x_email_format                          OUT NOCOPY    VARCHAR2,
    x_email_address                         OUT NOCOPY    VARCHAR2,
    x_phone_calling_calendar                OUT NOCOPY    VARCHAR2,
    x_last_contact_dt_time                  OUT NOCOPY    DATE,
    x_timezone_id                           OUT NOCOPY    NUMBER,
    x_phone_area_code                       OUT NOCOPY    VARCHAR2,
    x_phone_country_code                    OUT NOCOPY    VARCHAR2,
    x_phone_number                          OUT NOCOPY    VARCHAR2,
    x_phone_extension                       OUT NOCOPY    VARCHAR2,
    x_phone_line_type                       OUT NOCOPY    VARCHAR2,
    x_telex_number                          OUT NOCOPY    VARCHAR2,
    x_web_type                              OUT NOCOPY    VARCHAR2,
    x_url                                   OUT NOCOPY    VARCHAR2,
    x_content_source_type                   OUT NOCOPY    VARCHAR2,
    x_raw_phone_number                      OUT NOCOPY    VARCHAR2,
    x_contact_point_purpose                 OUT NOCOPY    VARCHAR2,
    x_primary_by_purpose                    OUT NOCOPY    VARCHAR2,
    x_created_by_module                     OUT NOCOPY    VARCHAR2,
    x_application_id                        OUT NOCOPY    NUMBER,
    x_transposed_phone_number               OUT NOCOPY    VARCHAR2,
    x_actual_content_source                 OUT NOCOPY    VARCHAR2
  ) IS

  CURSOR c_cp IS
    SELECT NVL(contact_point_id, fnd_api.g_miss_num),
           NVL(contact_point_type, fnd_api.g_miss_char),
           NVL(status, fnd_api.g_miss_char),
           NVL(owner_table_name, fnd_api.g_miss_char),
           NVL(owner_table_id, fnd_api.g_miss_num),
           NVL(primary_flag, fnd_api.g_miss_char),
           NVL(orig_system_reference, fnd_api.g_miss_char),
           NVL(attribute_category, fnd_api.g_miss_char),
           NVL(attribute1, fnd_api.g_miss_char),
           NVL(attribute2, fnd_api.g_miss_char),
           NVL(attribute3, fnd_api.g_miss_char),
           NVL(attribute4, fnd_api.g_miss_char),
           NVL(attribute5, fnd_api.g_miss_char),
           NVL(attribute6, fnd_api.g_miss_char),
           NVL(attribute7, fnd_api.g_miss_char),
           NVL(attribute8, fnd_api.g_miss_char),
           NVL(attribute9, fnd_api.g_miss_char),
           NVL(attribute10, fnd_api.g_miss_char),
           NVL(attribute11, fnd_api.g_miss_char),
           NVL(attribute12, fnd_api.g_miss_char),
           NVL(attribute13, fnd_api.g_miss_char),
           NVL(attribute14, fnd_api.g_miss_char),
           NVL(attribute15, fnd_api.g_miss_char),
           NVL(attribute16, fnd_api.g_miss_char),
           NVL(attribute17, fnd_api.g_miss_char),
           NVL(attribute18, fnd_api.g_miss_char),
           NVL(attribute19, fnd_api.g_miss_char),
           NVL(attribute20, fnd_api.g_miss_char),
           NVL(edi_transaction_handling, fnd_api.g_miss_char),
           NVL(edi_id_number, fnd_api.g_miss_char),
           NVL(edi_payment_method, fnd_api.g_miss_char),
           NVL(edi_payment_format, fnd_api.g_miss_char),
           NVL(edi_remittance_method, fnd_api.g_miss_char),
           NVL(edi_remittance_instruction, fnd_api.g_miss_char),
           NVL(edi_tp_header_id, fnd_api.g_miss_num),
           NVL(edi_ece_tp_location_code, fnd_api.g_miss_char),
           NVL(x_eft_transmission_program_id, fnd_api.g_miss_num),
           NVL(x_eft_printing_program_id, fnd_api.g_miss_num),
           NVL(x_eft_user_number, fnd_api.g_miss_char),
           NVL(x_eft_swift_code, fnd_api.g_miss_char),
           NVL(email_format, fnd_api.g_miss_char),
           NVL(email_address, fnd_api.g_miss_char),
           NVL(phone_calling_calendar, fnd_api.g_miss_char),
           NVL(last_contact_dt_time, fnd_api.g_miss_date),
           NVL(timezone_id, fnd_api.g_miss_num),
           NVL(phone_area_code, fnd_api.g_miss_char),
           NVL(phone_country_code, fnd_api.g_miss_char),
           NVL(phone_number, fnd_api.g_miss_char),
           NVL(phone_extension, fnd_api.g_miss_char),
           NVL(phone_line_type, fnd_api.g_miss_char),
           NVL(telex_number, fnd_api.g_miss_char),
           NVL(web_type, fnd_api.g_miss_char),
           NVL(url, fnd_api.g_miss_char),
           NVL(content_source_type, fnd_api.g_miss_char),
           NVL(raw_phone_number, fnd_api.g_miss_char),
           NVL(contact_point_purpose, fnd_api.g_miss_char),
           NVL(primary_by_purpose, fnd_api.g_miss_char),
           NVL(created_by_module, fnd_api.g_miss_char),
           NVL(application_id, fnd_api.g_miss_num),
           NVL(transposed_phone_number, fnd_api.g_miss_char),
           NVL(actual_content_source, fnd_api.g_miss_char)
    FROM   hz_contact_points
    WHERE  contact_point_id = x_contact_point_id;
  BEGIN
    OPEN c_cp;
    FETCH c_cp
    INTO  x_contact_point_id,
          x_contact_point_type,
          x_status,
          x_owner_table_name,
          x_owner_table_id,
          x_primary_flag,
          x_orig_system_reference,
          x_attribute_category,
          x_attribute1,
          x_attribute2,
          x_attribute3,
          x_attribute4,
          x_attribute5,
          x_attribute6,
          x_attribute7,
          x_attribute8,
          x_attribute9,
          x_attribute10,
          x_attribute11,
          x_attribute12,
          x_attribute13,
          x_attribute14,
          x_attribute15,
          x_attribute16,
          x_attribute17,
          x_attribute18,
          x_attribute19,
          x_attribute20,
          x_edi_transaction_handling,
          x_edi_id_number,
          x_edi_payment_method,
          x_edi_payment_format,
          x_edi_remittance_method,
          x_edi_remittance_instruction,
          x_edi_tp_header_id,
          x_edi_ece_tp_location_code,
          x_eft_transmission_program_id,
          x_eft_printing_program_id,
          x_eft_user_number,
          x_eft_swift_code,
          x_email_format,
          x_email_address,
          x_phone_calling_calendar,
          x_last_contact_dt_time,
          x_timezone_id,
          x_phone_area_code,
          x_phone_country_code,
          x_phone_number,
          x_phone_extension,
          x_phone_line_type,
          x_telex_number,
          x_web_type,
          x_url,
          x_content_source_type,
          x_raw_phone_number,
          x_contact_point_purpose,
          x_primary_by_purpose,
          x_created_by_module,
          x_application_id,
          x_transposed_phone_number,
          x_actual_content_source;

    IF c_cp%NOTFOUND THEN
      CLOSE c_cp;
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'contact_point_rec');
      fnd_message.set_token('VALUE', TO_CHAR(x_contact_point_id));
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    ELSE
      CLOSE c_cp;
    END IF;

  END select_row;

  PROCEDURE delete_row (x_contact_point_id IN NUMBER) IS
  BEGIN

    DELETE FROM hz_contact_points
    WHERE contact_point_id = x_contact_point_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

END hz_contact_points_pkg;

/
