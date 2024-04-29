--------------------------------------------------------
--  DDL for Package Body HZ_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATIONS_PKG" AS
/*$Header: ARHLOCTB.pls 120.3 2005/07/29 01:24:49 jhuang ship $ */

  g_miss_content_source_type                CONSTANT VARCHAR2(30) := 'USER_ENTERED';

  -- J. del Callar: global variable for the default geometry status
  g_default_geometry_status_code            VARCHAR2(30) := 'DIRTY';

  PROCEDURE insert_row (
    x_location_id                           IN OUT NOCOPY NUMBER,
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
    x_orig_system_reference                 IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_state                                 IN     VARCHAR2,
    x_province                              IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_address_key                           IN     VARCHAR2,
    x_address_style                         IN     VARCHAR2,
    x_validated_flag                        IN     VARCHAR2,
    x_address_lines_phonetic                IN     VARCHAR2,
    x_po_box_number                         IN     VARCHAR2,
    x_house_number                          IN     VARCHAR2,
    x_street_suffix                         IN     VARCHAR2,
    x_street                                IN     VARCHAR2,
    x_street_number                         IN     VARCHAR2,
    x_floor                                 IN     VARCHAR2,
    x_suite                                 IN     VARCHAR2,
    x_postal_plus4_code                     IN     VARCHAR2,
    x_position                              IN     VARCHAR2,
    x_location_directions                   IN     VARCHAR2,
    x_address_effective_date                IN     DATE,
    x_address_expiration_date               IN     DATE,
    x_clli_code                             IN     VARCHAR2,
    x_language                              IN     VARCHAR2,
    x_short_description                     IN     VARCHAR2,
    x_description                           IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_loc_hierarchy_id                      IN     NUMBER,
    x_sales_tax_geocode                     IN     VARCHAR2,
    x_sales_tax_inside_city_limits          IN     VARCHAR2,
    x_fa_location_id                        IN     NUMBER,
    x_geometry                              IN     mdsys.sdo_geometry,
    x_object_version_number                 IN     NUMBER,
    x_timezone_id                           IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2,
    x_geometry_status_code                  IN     VARCHAR2 DEFAULT NULL,
    -- BUG 2670546
    x_delivery_point_code                   IN     VARCHAR2
  ) IS

    l_success                               VARCHAR2(1) := 'N';
    l_geometry                              mdsys.sdo_geometry := NULL;
    l_primary_key_passed                    BOOLEAN := FALSE;

  BEGIN

    -- The following lines are used to take care of the situation
    -- when content_source_type is not USER_ENTERED, because of
    -- policy funcation, when we do unique validation, we cannot
    -- see all of the records. Thus, we have to double check here
    -- and raise corresponding exception. We donot need to do anything
    -- for those tables without polity functions.

    IF x_location_id IS NOT NULL AND
       x_location_id <> fnd_api.g_miss_num
    THEN
        l_primary_key_passed := TRUE;
    END IF;

    IF x_geometry.sdo_gtype <> FND_API.G_MISS_NUM OR
       x_geometry.sdo_srid <> FND_API.G_MISS_NUM OR
       x_geometry.sdo_point IS NOT NULL OR
       x_geometry.sdo_elem_info IS NOT NULL OR
       x_geometry.sdo_ordinates IS NOT NULL
    THEN
        l_geometry := x_GEOMETRY;
    END IF;

    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO hz_locations (
          location_id,
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
          orig_system_reference,
          country,
          address1,
          address2,
          address3,
          address4,
          city,
          postal_code,
          state,
          province,
          county,
          address_key,
          address_style,
          validated_flag,
          address_lines_phonetic,
          postal_plus4_code,
          position,
          location_directions,
          address_effective_date,
          address_expiration_date,
          clli_code,
          language,
          short_description,
          description,
          content_source_type,
          loc_hierarchy_id,
          sales_tax_geocode,
          sales_tax_inside_city_limits,
          fa_location_id,
          geometry,
          object_version_number,
          timezone_id,
          created_by_module,
          application_id,
          actual_content_source,
          geometry_status_code,
          -- Bug 2670546
          delivery_point_code
        )
        VALUES (
          DECODE(x_location_id,
                 fnd_api.g_miss_num, hr_locations_s.NEXTVAL,
                 NULL, hr_locations_s.NEXTVAL,
                 x_location_id),
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
                 fnd_api.g_miss_char, NULL,
                 x_attribute_category),
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
          DECODE(x_orig_system_reference,
                 fnd_api.g_miss_char, TO_CHAR(NVL(x_location_id,
                                                  hr_locations_s.CURRVAL)),
                 NULL, TO_CHAR(NVL(x_location_id, hr_locations_s.CURRVAL)),
                 x_orig_system_reference),
          DECODE(x_country, fnd_api.g_miss_char, NULL, x_country),
          DECODE(x_address1, fnd_api.g_miss_char, NULL, x_address1),
          DECODE(x_address2, fnd_api.g_miss_char, NULL, x_address2),
          DECODE(x_address3, fnd_api.g_miss_char, NULL, x_address3),
          DECODE(x_address4, fnd_api.g_miss_char, NULL, x_address4),
          DECODE(x_city, fnd_api.g_miss_char, NULL, x_city),
          DECODE(x_postal_code, fnd_api.g_miss_char, NULL, x_postal_code),
          DECODE(x_state, fnd_api.g_miss_char, NULL, x_state),
          DECODE(x_province, fnd_api.g_miss_char, NULL, x_province),
          DECODE(x_county, fnd_api.g_miss_char, NULL, x_county),
          DECODE(x_address_key, fnd_api.g_miss_char, NULL, x_address_key),
          DECODE(x_address_style, fnd_api.g_miss_char, NULL, x_address_style),
          DECODE(x_validated_flag,
                 fnd_api.g_miss_char, 'N',
                 NULL, 'N',
                 x_validated_flag),
          DECODE(x_address_lines_phonetic,
                 fnd_api.g_miss_char, NULL,
                 x_address_lines_phonetic),
          DECODE(x_postal_plus4_code,
                 fnd_api.g_miss_char, NULL,
                 x_postal_plus4_code),
          DECODE(x_position, fnd_api.g_miss_char, NULL, x_position),
          DECODE(x_location_directions,
                 fnd_api.g_miss_char, NULL,
                 x_location_directions),
          DECODE(x_address_effective_date,
                 fnd_api.g_miss_date, TO_DATE(NULL),
                 x_address_effective_date),
          DECODE(x_address_expiration_date,
                 fnd_api.g_miss_date, TO_DATE(NULL),
                 x_address_expiration_date),
          DECODE(x_clli_code, fnd_api.g_miss_char, NULL, x_clli_code),
          DECODE(x_language, fnd_api.g_miss_char, NULL, x_language),
          DECODE(x_short_description,
                 fnd_api.g_miss_char, NULL,
                 x_short_description),
          DECODE(x_description, fnd_api.g_miss_char, NULL, x_description),
          DECODE(x_content_source_type,
                 fnd_api.g_miss_char, g_miss_content_source_type,
                 NULL, g_miss_content_source_type,
                 x_content_source_type),
          DECODE(x_loc_hierarchy_id,
                 fnd_api.g_miss_num, NULL,
                 x_loc_hierarchy_id),
          DECODE(x_sales_tax_geocode,
                 fnd_api.g_miss_char, NULL,
                 x_sales_tax_geocode),
          DECODE(x_sales_tax_inside_city_limits,
                 fnd_api.g_miss_char, '1',
                 NULL, '1',
                 x_sales_tax_inside_city_limits),
          DECODE(x_fa_location_id, fnd_api.g_miss_num, NULL, x_fa_location_id),
          l_geometry,
          DECODE(x_object_version_number,
                 fnd_api.g_miss_num, NULL,
                 x_object_version_number),
          DECODE(x_timezone_id, fnd_api.g_miss_num, NULL, x_timezone_id),
          DECODE(x_created_by_module,
                 fnd_api.g_miss_char, NULL,
                 x_created_by_module),
          DECODE(x_application_id, fnd_api.g_miss_num, NULL, x_application_id),
          DECODE(x_actual_content_source,
                 fnd_api.g_miss_char, g_miss_content_source_type,
                 NULL, g_miss_content_source_type,
                 x_actual_content_source),
          DECODE(x_geometry_status_code,
                 NULL, g_default_geometry_status_code,
                 fnd_api.g_miss_char, NULL,
                 x_geometry_status_code),
          -- Bug 2670546.
          DECODE(x_delivery_point_code,
                 fnd_api.g_miss_char,
                 NULL,
                 x_delivery_point_code)
        ) RETURNING
          location_id
        INTO
          x_location_id;

        l_success := 'Y';

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          IF INSTRB(SQLERRM, 'HZ_LOCATIONS_U1') <> 0 OR
             INSTRB(SQLERRM, 'HZ_LOCATIONS_PK') <> 0
          THEN
            IF l_primary_key_passed THEN
              fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
              fnd_message.set_token('COLUMN', 'location_id');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;

            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);
            BEGIN
              l_count := 1;
              WHILE l_count > 0 LOOP
                SELECT hr_locations_s.NEXTVAL
                INTO   x_location_id
                FROM   dual;

                BEGIN
                  SELECT 'Y'
                  INTO   l_dummy
                  FROM   hz_locations hl
                  WHERE  hl.location_id = x_location_id;
                  l_count := 1;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_count := 0;
                END;
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
    x_location_id                           IN     NUMBER,
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
    x_orig_system_reference                 IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_state                                 IN     VARCHAR2,
    x_province                              IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_address_key                           IN     VARCHAR2,
    x_address_style                         IN     VARCHAR2,
    x_validated_flag                        IN     VARCHAR2,
    x_address_lines_phonetic                IN     VARCHAR2,
    x_po_box_number                         IN     VARCHAR2,
    x_house_number                          IN     VARCHAR2,
    x_street_suffix                         IN     VARCHAR2,
    x_street                                IN     VARCHAR2,
    x_street_number                         IN     VARCHAR2,
    x_floor                                 IN     VARCHAR2,
    x_suite                                 IN     VARCHAR2,
    x_postal_plus4_code                     IN     VARCHAR2,
    x_position                              IN     VARCHAR2,
    x_location_directions                   IN     VARCHAR2,
    x_address_effective_date                IN     DATE,
    x_address_expiration_date               IN     DATE,
    x_clli_code                             IN     VARCHAR2,
    x_language                              IN     VARCHAR2,
    x_short_description                     IN     VARCHAR2,
    x_description                           IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_loc_hierarchy_id                      IN     NUMBER,
    x_sales_tax_geocode                     IN     VARCHAR2,
    x_sales_tax_inside_city_limits          IN     VARCHAR2,
    x_fa_location_id                        IN     NUMBER,
    x_geometry                              IN     mdsys.sdo_geometry,
    x_object_version_number                 IN     NUMBER,
    x_timezone_id                           IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2 DEFAULT NULL,
    x_geometry_status_code                  IN     VARCHAR2 DEFAULT NULL,
    -- Bug 2670546
    x_delivery_point_code                   IN     VARCHAR2
  ) IS
  BEGIN
    UPDATE hz_locations
    SET    location_id = DECODE(x_location_id,
                                NULL, location_id,
                                fnd_api.g_miss_num, NULL,
                                x_location_id),
           last_update_date = hz_utility_v2pub.last_update_date,
           last_updated_by = hz_utility_v2pub.last_updated_by,
           creation_date = creation_date,
           created_by = created_by,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id = hz_utility_v2pub.request_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = hz_utility_v2pub.program_update_date,
           attribute_category = DECODE(x_attribute_category,
                                       NULL, attribute_category,
                                       fnd_api.g_miss_char, NULL,
                                       x_attribute_category),
           attribute1 = DECODE(x_attribute1,
                               NULL, attribute1,
                               fnd_api.g_miss_char, NULL,
                               x_attribute1),
           attribute2 = DECODE(x_attribute2,
                               NULL, attribute2,
                               fnd_api.g_miss_char, NULL,
                               x_attribute2),
           attribute3 = DECODE(x_attribute3,
                               NULL, attribute3,
                               fnd_api.g_miss_char, NULL,
                               x_attribute3),
           attribute4 = DECODE(x_attribute4,
                               NULL, attribute4,
                               fnd_api.g_miss_char, NULL,
                               x_attribute4),
           attribute5 = DECODE(x_attribute5,
                               NULL, attribute5,
                               fnd_api.g_miss_char, NULL,
                               x_attribute5),
           attribute6 = DECODE(x_attribute6,
                               NULL, attribute6,
                               fnd_api.g_miss_char, NULL,
                               x_attribute6),
           attribute7 = DECODE(x_attribute7,
                               NULL, attribute7,
                               fnd_api.g_miss_char, NULL,
                               x_attribute7),
           attribute8 = DECODE(x_attribute8,
                               NULL, attribute8,
                               fnd_api.g_miss_char, NULL,
                               x_attribute8),
           attribute9 = DECODE(x_attribute9,
                               NULL, attribute9,
                               fnd_api.g_miss_char, NULL,
                               x_attribute9),
           attribute10 = DECODE(x_attribute10,
                                NULL, attribute10,
                                fnd_api.g_miss_char, NULL,
                                x_attribute10),
           attribute11 = DECODE(x_attribute11,
                                NULL, attribute11,
                                fnd_api.g_miss_char, NULL,
                                x_attribute11),
           attribute12 = DECODE(x_attribute12,
                                NULL, attribute12,
                                fnd_api.g_miss_char, NULL,
                                x_attribute12),
           attribute13 = DECODE(x_attribute13,
                                NULL, attribute13,
                                fnd_api.g_miss_char, NULL,
                                x_attribute13),
           attribute14 = DECODE(x_attribute14,
                                NULL, attribute14,
                                fnd_api.g_miss_char, NULL,
                                x_attribute14),
           attribute15 = DECODE(x_attribute15,
                                NULL, attribute15,
                                fnd_api.g_miss_char, NULL,
                                x_attribute15),
           attribute16 = DECODE(x_attribute16,
                                NULL, attribute16,
                                fnd_api.g_miss_char, NULL,
                                x_attribute16),
           attribute17 = DECODE(x_attribute17,
                                NULL, attribute17,
                                fnd_api.g_miss_char, NULL,
                                x_attribute17),
           attribute18 = DECODE(x_attribute18,
                                NULL, attribute18,
                                fnd_api.g_miss_char, NULL,
                                x_attribute18),
           attribute19 = DECODE(x_attribute19,
                                NULL, attribute19,
                                fnd_api.g_miss_char, NULL,
                                x_attribute19),
           attribute20 = DECODE(x_attribute20,
                                NULL, attribute20,
                                fnd_api.g_miss_char, NULL,
                                x_attribute20),
           orig_system_reference
             = DECODE(x_orig_system_reference,
                      NULL, orig_system_reference,
                      fnd_api.g_miss_char, orig_system_reference,
                      x_orig_system_reference),
           country = DECODE(x_country,
                            NULL, country,
                            fnd_api.g_miss_char, NULL,
                            x_country),
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
           state = DECODE(x_state,
                          NULL, state,
                          fnd_api.g_miss_char, NULL,
                          x_state),
           province = DECODE(x_province,
                             NULL, province,
                             fnd_api.g_miss_char, NULL,
                             x_province),
           county = DECODE(x_county,
                           NULL, county,
                           fnd_api.g_miss_char, NULL,
                           x_county),
           address_key = DECODE(x_address_key,
                                NULL, address_key,
                                fnd_api.g_miss_char, NULL,
                                x_address_key),
           address_style = DECODE(x_address_style,
                                  NULL, address_style,
                                  fnd_api.g_miss_char, NULL,
                                  x_address_style),
           validated_flag = DECODE(x_validated_flag,
                                   NULL, validated_flag,
                                   fnd_api.g_miss_char, 'N',
                                   x_validated_flag),
           address_lines_phonetic = DECODE(x_address_lines_phonetic,
                                           NULL, address_lines_phonetic,
                                           fnd_api.g_miss_char, NULL,
                                           x_address_lines_phonetic),
           postal_plus4_code = DECODE(x_postal_plus4_code,
                                      NULL, postal_plus4_code,
                                      fnd_api.g_miss_char, NULL,
                                      x_postal_plus4_code),
           position = DECODE(x_position,
                             NULL, position,
                             fnd_api.g_miss_char, NULL,
                             x_position),
           location_directions = DECODE(x_location_directions,
                                        NULL, location_directions,
                                        fnd_api.g_miss_char, NULL,
                                        x_location_directions),
           address_effective_date = DECODE(x_address_effective_date,
                                           NULL, address_effective_date,
                                           fnd_api.g_miss_date, NULL,
                                           x_address_effective_date),
           address_expiration_date = DECODE(x_address_expiration_date,
                                            NULL, address_expiration_date,
                                            fnd_api.g_miss_date, NULL,
                                            x_address_expiration_date),
           clli_code = DECODE(x_clli_code,
                              NULL, clli_code,
                              fnd_api.g_miss_char, NULL,
                              x_clli_code),
           language = DECODE(x_language,
                             NULL, language,
                             fnd_api.g_miss_char, NULL,
                             x_language),
           short_description = DECODE(x_short_description,
                                      NULL, short_description,
                                      fnd_api.g_miss_char, NULL,
                                      x_short_description),
           description = DECODE(x_description,
                                NULL, description,
                                fnd_api.g_miss_char, NULL,
                                x_description),
           content_source_type = DECODE(x_content_source_type,
                                        NULL, content_source_type,
                                        fnd_api.g_miss_char, NULL,
                                        x_content_source_type),
           loc_hierarchy_id = DECODE(x_loc_hierarchy_id,
                                     NULL, loc_hierarchy_id,
                                     fnd_api.g_miss_num, NULL,
                                     x_loc_hierarchy_id),
           sales_tax_geocode = DECODE(x_sales_tax_geocode,
                                      NULL, sales_tax_geocode,
                                      fnd_api.g_miss_char, NULL,
                                      x_sales_tax_geocode),
           sales_tax_inside_city_limits
             = DECODE(x_sales_tax_inside_city_limits,
                      NULL, sales_tax_inside_city_limits,
                      fnd_api.g_miss_char, '1',
                      x_sales_tax_inside_city_limits),
           fa_location_id = DECODE(x_fa_location_id,
                                   NULL, fa_location_id,
                                   fnd_api.g_miss_num, NULL,
                                   x_fa_location_id),
           geometry = x_geometry,
           object_version_number = DECODE(x_object_version_number,
                                          NULL, object_version_number,
                                          fnd_api.g_miss_num, NULL,
                                          x_object_version_number),
           timezone_id = DECODE(x_timezone_id,
                                NULL, timezone_id,
                                fnd_api.g_miss_num, NULL,
                                x_timezone_id),
           created_by_module = DECODE(x_created_by_module,
                                      NULL, created_by_module,
                                      fnd_api.g_miss_char, NULL,
                                      x_created_by_module),
           application_id = DECODE(x_application_id,
                                   NULL, application_id,
                                   fnd_api.g_miss_num, NULL,
                                   x_application_id),
           actual_content_source = DECODE(x_actual_content_source,
                                        NULL, actual_content_source,
                                        fnd_api.g_miss_char, NULL,
                                        x_actual_content_source),
           geometry_status_code = DECODE(x_geometry_status_code,
                                         NULL, geometry_status_code,
                                         fnd_api.g_miss_char, NULL,
                                         x_geometry_status_code),
           -- Bug 2670546.
           delivery_point_code  = DECODE(x_delivery_point_code,
                                         NULL,delivery_point_code,
                                         fnd_api.g_miss_char,NULL,
                                         x_delivery_point_code)
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;


  PROCEDURE lock_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_location_id                           IN     NUMBER,
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
    x_orig_system_reference                 IN     VARCHAR2,
    x_country                               IN     VARCHAR2,
    x_address1                              IN     VARCHAR2,
    x_address2                              IN     VARCHAR2,
    x_address3                              IN     VARCHAR2,
    x_address4                              IN     VARCHAR2,
    x_city                                  IN     VARCHAR2,
    x_postal_code                           IN     VARCHAR2,
    x_state                                 IN     VARCHAR2,
    x_province                              IN     VARCHAR2,
    x_county                                IN     VARCHAR2,
    x_address_key                           IN     VARCHAR2,
    x_address_style                         IN     VARCHAR2,
    x_validated_flag                        IN     VARCHAR2,
    x_address_lines_phonetic                IN     VARCHAR2,
    x_po_box_number                         IN     VARCHAR2,
    x_house_number                          IN     VARCHAR2,
    x_street_suffix                         IN     VARCHAR2,
    x_street                                IN     VARCHAR2,
    x_street_number                         IN     VARCHAR2,
    x_floor                                 IN     VARCHAR2,
    x_suite                                 IN     VARCHAR2,
    x_postal_plus4_code                     IN     VARCHAR2,
    x_position                              IN     VARCHAR2,
    x_location_directions                   IN     VARCHAR2,
    x_address_effective_date                IN     DATE,
    x_address_expiration_date               IN     DATE,
    x_clli_code                             IN     VARCHAR2,
    x_language                              IN     VARCHAR2,
    x_short_description                     IN     VARCHAR2,
    x_description                           IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_loc_hierarchy_id                      IN     NUMBER,
    x_sales_tax_geocode                     IN     VARCHAR2,
    x_sales_tax_inside_city_limits          IN     VARCHAR2,
    x_fa_location_id                        IN     NUMBER,
    x_geometry                              IN     mdsys.sdo_geometry,
    x_object_version_number                 IN     NUMBER,
    x_timezone_id                           IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_actual_content_source                 IN     VARCHAR2 DEFAULT NULL,
    x_geometry_status_code                  IN     VARCHAR2 DEFAULT NULL,
    -- Bug 2670546
    x_delivery_point_code                   IN     VARCHAR2
  ) IS

    CURSOR c IS
      SELECT *
      FROM   hz_locations
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

    IF (((recinfo.location_id = x_location_id)
         OR ((recinfo.location_id IS NULL)
              AND (x_location_id IS NULL)))
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
        AND ((recinfo.orig_system_reference = x_orig_system_reference)
             OR ((recinfo.orig_system_reference IS NULL)
                 AND (x_orig_system_reference IS NULL)))
        AND ((recinfo.country = x_country)
             OR ((recinfo.country IS NULL)
                 AND (x_country IS NULL)))
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
        AND ((recinfo.state = x_state)
             OR ((recinfo.state IS NULL)
                 AND (x_state IS NULL)))
        AND ((recinfo.province = x_province)
             OR ((recinfo.province IS NULL)
                 AND (x_province IS NULL)))
        AND ((recinfo.county = x_county)
             OR ((recinfo.county IS NULL)
                 AND (x_county IS NULL)))
        AND ((recinfo.address_key = x_address_key)
             OR ((recinfo.address_key IS NULL)
                 AND (x_address_key IS NULL)))
        AND ((recinfo.address_style = x_address_style)
             OR ((recinfo.address_style IS NULL)
                 AND (x_address_style IS NULL)))
        AND ((recinfo.validated_flag = x_validated_flag)
             OR ((recinfo.validated_flag IS NULL)
                 AND (x_validated_flag IS NULL)))
        AND ((recinfo.address_lines_phonetic = x_address_lines_phonetic)
             OR ((recinfo.address_lines_phonetic IS NULL)
                 AND (x_address_lines_phonetic IS NULL)))
        AND ((recinfo.postal_plus4_code = x_postal_plus4_code)
             OR ((recinfo.postal_plus4_code IS NULL)
                 AND (x_postal_plus4_code IS NULL)))
        AND ((recinfo.position = x_position)
             OR ((recinfo.position IS NULL)
                 AND (x_position IS NULL)))
        AND ((recinfo.location_directions = x_location_directions)
             OR ((recinfo.location_directions IS NULL)
                 AND (x_location_directions IS NULL)))
        AND ((recinfo.address_effective_date = x_address_effective_date)
             OR ((recinfo.address_effective_date IS NULL)
                 AND (x_address_effective_date IS NULL)))
        AND ((recinfo.address_expiration_date = x_address_expiration_date)
             OR ((recinfo.address_expiration_date IS NULL)
                 AND (x_address_expiration_date IS NULL)))
        AND ((recinfo.clli_code = x_clli_code)
             OR ((recinfo.clli_code IS NULL)
                 AND (x_clli_code IS NULL)))
        AND ((recinfo.language = x_language)
             OR ((recinfo.language IS NULL)
                 AND (x_language IS NULL)))
        AND ((recinfo.short_description = x_short_description)
             OR ((recinfo.short_description IS NULL)
                 AND (x_short_description IS NULL)))
        AND ((recinfo.description = x_description)
             OR ((recinfo.description IS NULL)
                 AND (x_description IS NULL)))
        AND ((recinfo.content_source_type = x_content_source_type)
             OR ((recinfo.content_source_type IS NULL)
                 AND (x_content_source_type IS NULL)))
        AND ((recinfo.loc_hierarchy_id = x_loc_hierarchy_id)
             OR ((recinfo.loc_hierarchy_id IS NULL)
                 AND (x_loc_hierarchy_id IS NULL)))
        AND ((recinfo.sales_tax_geocode = x_sales_tax_geocode)
             OR ((recinfo.sales_tax_geocode IS NULL)
                 AND (x_sales_tax_geocode IS NULL)))
        AND ((recinfo.sales_tax_inside_city_limits
              = x_sales_tax_inside_city_limits)
             OR ((recinfo.sales_tax_inside_city_limits IS NULL)
                 AND (x_sales_tax_inside_city_limits IS NULL)))
        AND ((recinfo.fa_location_id = x_fa_location_id)
             OR ((recinfo.fa_location_id IS NULL)
                 AND (x_fa_location_id IS NULL)))
        AND ((recinfo.object_version_number = x_object_version_number)
             OR ((recinfo.object_version_number IS NULL)
                 AND (x_object_version_number IS NULL)))
        AND ((recinfo.timezone_id = x_timezone_id)
             OR ((recinfo.timezone_id IS NULL)
                 AND (x_timezone_id IS NULL)))
        AND ((recinfo.created_by_module = x_created_by_module)
             OR ((recinfo.created_by_module IS NULL)
                 AND (x_created_by_module IS NULL)))
        AND ((recinfo.application_id = x_application_id)
             OR ((recinfo.application_id IS NULL)
                 AND (x_application_id IS NULL)))
        AND ((recinfo.actual_content_source = x_actual_content_source)
             OR ((recinfo.actual_content_source IS NULL)
                 AND (x_actual_content_source IS NULL)))
        AND ((recinfo.geometry_status_code = x_geometry_status_code)
             OR ((recinfo.geometry_status_code IS NULL)
                 AND (x_geometry_status_code IS NULL)))
        -- Bug 2670546
        AND ((recinfo.delivery_point_code = x_delivery_point_code)
             OR (( recinfo.delivery_point_code IS NULL)
                 AND (x_delivery_point_code IS NULL))))
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
  END lock_row;


  PROCEDURE select_row (
    x_location_id                           IN OUT NOCOPY NUMBER,
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
    x_orig_system_reference                 OUT NOCOPY    VARCHAR2,
    x_country                               OUT NOCOPY    VARCHAR2,
    x_address1                              OUT NOCOPY    VARCHAR2,
    x_address2                              OUT NOCOPY    VARCHAR2,
    x_address3                              OUT NOCOPY    VARCHAR2,
    x_address4                              OUT NOCOPY    VARCHAR2,
    x_city                                  OUT NOCOPY    VARCHAR2,
    x_postal_code                           OUT NOCOPY    VARCHAR2,
    x_state                                 OUT NOCOPY    VARCHAR2,
    x_province                              OUT NOCOPY    VARCHAR2,
    x_county                                OUT NOCOPY    VARCHAR2,
    x_address_key                           OUT NOCOPY    VARCHAR2,
    x_address_style                         OUT NOCOPY    VARCHAR2,
    x_validated_flag                        OUT NOCOPY    VARCHAR2,
    x_address_lines_phonetic                OUT NOCOPY    VARCHAR2,
    x_po_box_number                         OUT NOCOPY    VARCHAR2,
    x_house_number                          OUT NOCOPY    VARCHAR2,
    x_street_suffix                         OUT NOCOPY    VARCHAR2,
    x_street                                OUT NOCOPY    VARCHAR2,
    x_street_number                         OUT NOCOPY    VARCHAR2,
    x_floor                                 OUT NOCOPY    VARCHAR2,
    x_suite                                 OUT NOCOPY    VARCHAR2,
    x_postal_plus4_code                     OUT NOCOPY    VARCHAR2,
    x_position                              OUT NOCOPY    VARCHAR2,
    x_location_directions                   OUT NOCOPY    VARCHAR2,
    x_address_effective_date                OUT NOCOPY    DATE,
    x_address_expiration_date               OUT NOCOPY    DATE,
    x_clli_code                             OUT NOCOPY    VARCHAR2,
    x_language                              OUT NOCOPY    VARCHAR2,
    x_short_description                     OUT NOCOPY    VARCHAR2,
    x_description                           OUT NOCOPY    VARCHAR2,
    x_content_source_type                   OUT NOCOPY    VARCHAR2,
    x_loc_hierarchy_id                      OUT NOCOPY    NUMBER,
    x_sales_tax_geocode                     OUT NOCOPY    VARCHAR2,
    x_sales_tax_inside_city_limits          OUT NOCOPY    VARCHAR2,
    x_fa_location_id                        OUT NOCOPY    NUMBER,
    x_geometry                              OUT NOCOPY    mdsys.sdo_geometry,
    x_timezone_id                           OUT NOCOPY    NUMBER,
    x_created_by_module                     OUT NOCOPY    VARCHAR2,
    x_application_id                        OUT NOCOPY    NUMBER,
    x_actual_content_source                 OUT NOCOPY    VARCHAR2,
    x_geometry_status_code                  OUT NOCOPY    VARCHAR2,
    -- Bug 2670546
    x_delivery_point_code                   OUT NOCOPY    VARCHAR2
  ) IS
  BEGIN
    SELECT NVL(location_id, fnd_api.g_miss_num),
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
           NVL(orig_system_reference, fnd_api.g_miss_char),
           NVL(country, fnd_api.g_miss_char),
           NVL(address1, fnd_api.g_miss_char),
           NVL(address2, fnd_api.g_miss_char),
           NVL(address3, fnd_api.g_miss_char),
           NVL(address4, fnd_api.g_miss_char),
           NVL(city, fnd_api.g_miss_char),
           NVL(postal_code, fnd_api.g_miss_char),
           NVL(state, fnd_api.g_miss_char),
           NVL(province, fnd_api.g_miss_char),
           NVL(county, fnd_api.g_miss_char),
           NVL(address_key, fnd_api.g_miss_char),
           NVL(address_style, fnd_api.g_miss_char),
           NVL(validated_flag, fnd_api.g_miss_char),
           NVL(address_lines_phonetic, fnd_api.g_miss_char),
           NVL(po_box_number, fnd_api.g_miss_char),
           NVL(house_number, fnd_api.g_miss_char),
           NVL(street_suffix, fnd_api.g_miss_char),
           NVL(street, fnd_api.g_miss_char),
           NVL(street_number, fnd_api.g_miss_char),
           NVL(floor, fnd_api.g_miss_char),
           NVL(suite, fnd_api.g_miss_char),
           NVL(postal_plus4_code, fnd_api.g_miss_char),
           NVL(position, fnd_api.g_miss_char),
           NVL(location_directions, fnd_api.g_miss_char),
           NVL(address_effective_date, fnd_api.g_miss_date),
           NVL(address_expiration_date, fnd_api.g_miss_date),
           NVL(clli_code, fnd_api.g_miss_char),
           NVL(language, fnd_api.g_miss_char),
           NVL(short_description, fnd_api.g_miss_char),
           NVL(description, fnd_api.g_miss_char),
           NVL(content_source_type, fnd_api.g_miss_char),
           NVL(loc_hierarchy_id, fnd_api.g_miss_num),
           sales_tax_geocode,
           NVL(sales_tax_inside_city_limits, fnd_api.g_miss_char),
           NVL(fa_location_id, fnd_api.g_miss_num),
           geometry,
           NVL(timezone_id, fnd_api.g_miss_num),
           NVL(created_by_module, fnd_api.g_miss_char),
           NVL(application_id, fnd_api.g_miss_num),
           NVL(actual_content_source, fnd_api.g_miss_char),
           NVL(geometry_status_code, fnd_api.g_miss_char),
           -- Bug 2670546
           NVL(delivery_point_code,fnd_api.g_miss_char)
    INTO   x_location_id,
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
           x_orig_system_reference,
           x_country,
           x_address1,
           x_address2,
           x_address3,
           x_address4,
           x_city,
           x_postal_code,
           x_state,
           x_province,
           x_county,
           x_address_key,
           x_address_style,
           x_validated_flag,
           x_address_lines_phonetic,
           x_po_box_number,
           x_house_number,
           x_street_suffix,
           x_street,
           x_street_number,
           x_floor,
           x_suite,
           x_postal_plus4_code,
           x_position,
           x_location_directions,
           x_address_effective_date,
           x_address_expiration_date,
           x_clli_code,
           x_language,
           x_short_description,
           x_description,
           x_content_source_type,
           x_loc_hierarchy_id,
           x_sales_tax_geocode,
           x_sales_tax_inside_city_limits,
           x_fa_location_id,
           x_geometry,
           x_timezone_id,
           x_created_by_module,
           x_application_id,
           x_actual_content_source,
           x_geometry_status_code,
           -- Bug 2670546
           x_delivery_point_code
    FROM   hz_locations
    WHERE  location_id = x_location_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'location_rec');
      fnd_message.set_token('VALUE', TO_CHAR(x_location_id));
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
  END select_row;

  PROCEDURE delete_row (x_location_id IN NUMBER) IS
  BEGIN
    DELETE FROM hz_locations
    WHERE location_id = x_location_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;
END hz_locations_pkg;

/
