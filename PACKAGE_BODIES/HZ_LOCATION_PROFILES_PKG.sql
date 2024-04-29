--------------------------------------------------------
--  DDL for Package Body HZ_LOCATION_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATION_PROFILES_PKG" AS
/*$Header: ARHLOCPB.pls 115.1 2003/08/14 00:22:41 acng noship $ */

  PROCEDURE insert_row (
    x_location_profile_id                   IN OUT NOCOPY NUMBER,
    x_location_id                           IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_validation_sst_flag                   IN     VARCHAR2,
    x_validation_status_code                IN     VARCHAR2,
    x_date_validated                        IN     DATE,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_prov_state_admin_code                 IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
  ) IS

    l_success                               VARCHAR2(1) := 'N';
    l_primary_key_passed                    BOOLEAN := FALSE;

  BEGIN

    -- The following lines are used to take care of the situation
    -- when content_source_type is not USER_ENTERED, because of
    -- policy funcation, when we do unique validation, we cannot
    -- see all of the records. Thus, we have to double check here
    -- and raise corresponding exception. We donot need to do anything
    -- for those tables without polity functions.

    IF x_location_profile_id IS NOT NULL AND
       x_location_profile_id <> fnd_api.g_miss_num
    THEN
        l_primary_key_passed := TRUE;
    END IF;

    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO hz_location_profiles (
          location_profile_id,
          location_id,
          actual_content_source,
          effective_start_date,
          effective_end_date,
          validation_sst_flag,
          validation_status_code,
          date_validated,
          address1,
          address2,
          address3,
          address4,
          city,
          postal_code,
          prov_state_admin_code,
          county,
          country,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          object_version_number
        )
        VALUES (
          DECODE(x_location_profile_id,
                 fnd_api.g_miss_num, hz_location_profiles_s.NEXTVAL,
                 NULL, hz_location_profiles_s.NEXTVAL,
                 x_location_profile_id),
          DECODE(x_location_id, fnd_api.g_miss_num, NULL, x_location_id),
          DECODE(x_actual_content_source, fnd_api.g_miss_char, NULL, x_actual_content_source),
          DECODE(x_effective_start_date, fnd_api.g_miss_date, TO_DATE(NULL), x_effective_start_date),
          DECODE(x_effective_end_date, fnd_api.g_miss_date, TO_DATE(NULL), x_effective_end_date),
          DECODE(x_validation_sst_flag, fnd_api.g_miss_char, NULL, x_validation_sst_flag),
          DECODE(x_validation_status_code, fnd_api.g_miss_char, NULL, x_validation_status_code),
          DECODE(x_date_validated, fnd_api.g_miss_date, TO_DATE(NULL), x_date_validated),
          DECODE(x_address1, fnd_api.g_miss_char, NULL, x_address1),
          DECODE(x_address2, fnd_api.g_miss_char, NULL, x_address2),
          DECODE(x_address3, fnd_api.g_miss_char, NULL, x_address3),
          DECODE(x_address4, fnd_api.g_miss_char, NULL, x_address4),
          DECODE(x_city, fnd_api.g_miss_char, NULL, x_city),
          DECODE(x_postal_code, fnd_api.g_miss_char, NULL, x_postal_code),
          DECODE(x_prov_state_admin_code, fnd_api.g_miss_char, NULL, x_prov_state_admin_code),
          DECODE(x_county, fnd_api.g_miss_char, NULL, x_county),
          DECODE(x_country, fnd_api.g_miss_char, NULL, x_country),
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by,
          hz_utility_v2pub.creation_date,
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.last_update_login,
          DECODE(x_object_version_number, fnd_api.g_miss_num, NULL, x_object_version_number)
        ) RETURNING
          location_profile_id
        INTO
          x_location_profile_id;

        l_success := 'Y';

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          IF INSTRB(SQLERRM, 'HZ_LOCATION_PROFILES_U1') <> 0 OR
             INSTRB(SQLERRM, 'HZ_LOCATION_PROFILES_PK') <> 0
          THEN
            IF l_primary_key_passed THEN
              fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
              fnd_message.set_token('COLUMN', 'location_profile_id');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;

            DECLARE
              l_temp_profile_id   NUMBER;
              l_max_profile_id    NUMBER;
            BEGIN
              l_temp_profile_id := 0;
              SELECT max(LOCATION_PROFILE_ID) INTO l_max_profile_id
              FROM HZ_LOCATION_PROFILES;
              WHILE l_temp_profile_id <= l_max_profile_id LOOP
                SELECT HZ_LOCATION_PROFILES_S.NEXTVAL
                INTO l_temp_profile_id FROM dual;
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
    x_location_profile_id                   IN     NUMBER,
    x_location_id                           IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_validation_sst_flag                   IN     VARCHAR2,
    x_validation_status_code                IN     VARCHAR2,
    x_date_validated                        IN     DATE,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_prov_state_admin_code                 IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
  ) IS
  BEGIN
    UPDATE hz_location_profiles
    SET    location_profile_id = DECODE(x_location_profile_id,
                                NULL, location_profile_id,
                                fnd_api.g_miss_num, NULL,
                                x_location_profile_id),
           location_id = DECODE(x_location_id,
                            NULL, location_id,
                            fnd_api.g_miss_num, NULL,
                            x_location_id),
           actual_content_source = DECODE(x_actual_content_source,
                                        NULL, actual_content_source,
                                        fnd_api.g_miss_char, NULL,
                                        x_actual_content_source),
           effective_start_date = DECODE(x_effective_start_date,
                                           NULL, effective_start_date,
                                           fnd_api.g_miss_date, NULL,
                                           x_effective_start_date),
           effective_end_date = DECODE(x_effective_end_date,
                                           NULL, effective_end_date,
                                           fnd_api.g_miss_date, NULL,
                                           x_effective_end_date),
           validation_sst_flag = DECODE(x_validation_sst_flag,
                                        NULL, validation_sst_flag,
                                        fnd_api.g_miss_char, NULL,
                                        x_validation_sst_flag),
           validation_status_code = DECODE(x_validation_status_code,
                                        NULL, validation_status_code,
                                        fnd_api.g_miss_char, NULL,
                                        x_validation_status_code),
           date_validated = DECODE(x_date_validated,
                               NULL, date_validated,
                               fnd_api.g_miss_date, NULL,
                               x_date_validated),
           address1 = DECODE(x_address1,
                             NULL, address1,
                             fnd_api.g_miss_char, NULL,
                             x_address1),
           address2 = DECODE(x_address2,
                             NULL, address2,
                             fnd_api.g_miss_char, NULL,
                             x_address2),
           address3 = DECODE(x_address3,
                             NULL, address3,
                             fnd_api.g_miss_char, NULL,
                             x_address3),
           address4 = DECODE(x_address4,
                             NULL, address4,
                             fnd_api.g_miss_char, NULL,
                             x_address4),
           city = DECODE(x_city,
                         NULL, city,
                         fnd_api.g_miss_char, NULL,
                         x_city),
           postal_code = DECODE(x_postal_code,
                                NULL, postal_code,
                                fnd_api.g_miss_char, NULL,
                                x_postal_code),
           prov_state_admin_code = DECODE(x_prov_state_admin_code,
                          NULL, prov_state_admin_code,
                          fnd_api.g_miss_char, NULL,
                          x_prov_state_admin_code),
           county = DECODE(x_county,
                           NULL, county,
                           fnd_api.g_miss_char, NULL,
                           x_county),
           country = DECODE(x_country,
                            NULL, country,
                            fnd_api.g_miss_char, NULL,
                            x_country),
           last_update_date = hz_utility_v2pub.last_update_date,
           last_updated_by = hz_utility_v2pub.last_updated_by,
           creation_date = creation_date,
           created_by = created_by,
           last_update_login = hz_utility_v2pub.last_update_login,
           object_version_number = DECODE(x_object_version_number,
                                          NULL, object_version_number,
                                          fnd_api.g_miss_num, NULL,
                                          x_object_version_number)
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;


  PROCEDURE lock_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_location_profile_id                   IN     NUMBER,
    x_location_id                           IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_validation_sst_flag                   IN     VARCHAR2,
    x_validation_status_code                IN     VARCHAR2,
    x_date_validated                        IN     DATE,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_prov_state_admin_code                 IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
  ) IS

    CURSOR c IS
      SELECT *
      FROM   hz_location_profiles
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

    IF (((recinfo.location_profile_id = x_location_profile_id)
         OR ((recinfo.location_profile_id IS NULL)
              AND (x_location_profile_id IS NULL)))
        AND ((recinfo.location_id = x_location_id)
            OR ((recinfo.location_id IS NULL)
                 AND (x_location_id IS NULL)))
        AND ((recinfo.actual_content_source = x_actual_content_source)
             OR ((recinfo.actual_content_source IS NULL)
                 AND (x_actual_content_source IS NULL)))
        AND ((recinfo.effective_start_date = x_effective_start_date)
             OR ((recinfo.effective_start_date IS NULL)
                 AND (x_effective_start_date IS NULL)))
        AND ((recinfo.effective_end_date = x_effective_end_date)
             OR ((recinfo.effective_end_date IS NULL)
                 AND (x_effective_end_date IS NULL)))
        AND ((recinfo.validation_sst_flag = x_validation_sst_flag)
             OR ((recinfo.validation_sst_flag IS NULL)
                 AND (x_validation_sst_flag IS NULL)))
        AND ((recinfo.validation_status_code = x_validation_status_code)
             OR ((recinfo.validation_status_code IS NULL)
                 AND (x_validation_status_code IS NULL)))
        AND ((recinfo.date_validated = x_date_validated)
             OR ((recinfo.date_validated IS NULL)
                 AND (x_date_validated IS NULL)))
        AND ((recinfo.address1 = x_address1)
             OR ((recinfo.address1 IS NULL)
                 AND (x_address1 IS NULL)))
        AND ((recinfo.address2 = x_address2)
             OR ((recinfo.address2 IS NULL)
                 AND (x_address2 IS NULL)))
        AND ((recinfo.address3 = x_address3)
             OR ((recinfo.address3 IS NULL)
                 AND (x_address3 IS NULL)))
        AND ((recinfo.address4 = x_address4)
             OR ((recinfo.address4 IS NULL)
                 AND (x_address4 IS NULL)))
        AND ((recinfo.city = x_city)
             OR ((recinfo.city IS NULL)
                 AND (x_city IS NULL)))
        AND ((recinfo.postal_code = x_postal_code)
             OR ((recinfo.postal_code IS NULL)
                 AND (x_postal_code IS NULL)))
        AND ((recinfo.prov_state_admin_code = x_prov_state_admin_code)
             OR ((recinfo.prov_state_admin_code IS NULL)
                 AND (x_prov_state_admin_code IS NULL)))
        AND ((recinfo.county = x_county)
             OR ((recinfo.county IS NULL)
                 AND (x_county IS NULL)))
        AND ((recinfo.country = x_country)
             OR ((recinfo.country IS NULL)
                 AND (x_country IS NULL)))
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


  PROCEDURE delete_row (x_location_profile_id IN NUMBER) IS
  BEGIN
    DELETE FROM hz_location_profiles
    WHERE location_profile_id = x_location_profile_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

END hz_location_profiles_pkg;

/
