--------------------------------------------------------
--  DDL for Package Body HZ_LOCATION_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATION_V2PUB" AS
/*$Header: ARH2LOSB.pls 120.35.12010000.4 2009/08/04 06:13:04 rgokavar ship $ */

  --------------------------------------
  -- declaration of private global varibles
  --------------------------------------

  g_debug_count                     NUMBER := 0;
  --g_debug                           BOOLEAN := FALSE;

  -- Bug 2197181: added for mix-n-match project.

  g_loc_mixnmatch_enabled           VARCHAR2(1);
  g_loc_selected_datasources        VARCHAR2(255);
  g_loc_is_datasource_selected      VARCHAR2(1) := 'N';
  g_loc_entity_attr_id              NUMBER;

  --------------------------------------
  -- declaration of private procedures and functions
  --------------------------------------

  /*PROCEDURE enable_debug;

  PROCEDURE disable_debug;
  */


  PROCEDURE do_create_location(
    p_location_rec                  IN OUT  NOCOPY location_rec_type,
    x_location_id                   OUT NOCOPY     NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
  );

  -- Modified the below procedure to add new parameters for address validation.
  -- This is for bug # 4652309. The new parameters will be passed thro the
  -- new update_location overloaded API.
  PROCEDURE do_update_location(
    p_location_rec                  IN OUT  NOCOPY location_rec_type,
    p_do_addr_val                   IN             VARCHAR2,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    x_addr_val_status               OUT NOCOPY     VARCHAR2,
    x_addr_warn_msg                 OUT NOCOPY     VARCHAR2,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
  );

  PROCEDURE fill_geometry(
    p_loc_rec                       IN OUT  NOCOPY location_rec_type,
    x_return_status                 OUT NOCOPY     VARCHAR2
  );

  PROCEDURE update_location_search(
       p_old_location_rec IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
       p_new_location_rec IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
  );

  FUNCTION isModified(p_old_value IN VARCHAR2,
                       p_new_value IN VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE check_obsolete_columns (
      p_create_update_flag          IN     VARCHAR2,
      p_location_rec                IN     location_rec_type,
      p_old_location_rec            IN     location_rec_type DEFAULT NULL,
      x_return_status               IN OUT NOCOPY VARCHAR2
  );

  --------------------------------------
  -- private procedures and functions
  --------------------------------------

  /**
   * PRIVATE PROCEDURE enable_debug
   *
   * DESCRIPTION
   *     Turn on debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     HZ_UTILITY_V2PUB.enable_debug
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Jianying Huang      o Created.
   *
   */

  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;

    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;
  */


  /**
   * PRIVATE PROCEDURE disable_debug
   *
   * DESCRIPTION
   *     Turn off debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     HZ_UTILITY_V2PUB.disable_debug
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Jianying Huang      o Created.
   *
   */

  /*PROCEDURE disable_debug IS
  BEGIN
    IF g_debug THEN
      g_debug_count := g_debug_count - 1;
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
      END IF;
    END IF;
  END disable_debug;
  */

  PROCEDURE do_create_location (
    p_location_rec                  IN OUT    NOCOPY location_rec_type,
    x_location_id                   OUT NOCOPY       NUMBER,
    x_return_status                 IN OUT NOCOPY    VARCHAR2
  ) IS
    l_rowid                                   ROWID := NULL;
    l_key                                     VARCHAR2(2000);
    l_dummy                                   VARCHAR2(1);
    l_debug_prefix                            VARCHAR2(30) := '';
    l_orig_sys_reference_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    l_msg_count number;
    l_message_count             NUMBER;
    l_msg_data varchar2(2000);
    l_return_status varchar2(1);
    l_timezone_id number;

-- ACNG add call to location profile: BEGIN
    l_location_profile_id    NUMBER := NULL;
    l_prov_state_admin_code  VARCHAR2(60);
    l_end_date               DATE;
-- ACNG add call to location profile: END

    CURSOR val IS
      SELECT 'Y'
      FROM   hz_locations hl
      WHERE  hl.location_id = p_location_rec.location_id;
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_location (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --If primary key value is passed, check for uniqueness.
    IF p_location_rec.location_id IS NOT NULL AND
       p_location_rec.location_id <> fnd_api.g_miss_num
    THEN
      -- J. del Callar: changed from select...into to a cursor.  It's faster
      -- for the default condition, which is no duplicates found.
      OPEN val;
      FETCH val INTO l_dummy;
      IF val%FOUND THEN
        CLOSE val;
        fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
        fnd_message.set_token('COLUMN', 'location_id');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE val;
    END IF;

    -- validate the input record
    hz_registry_validate_v2pub.validate_location(
      'C',
      p_location_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call address key generation program
    l_key := hz_fuzzy_pub.generate_key (
               'ADDRESS',
               NULL,
               p_location_rec.address1,
               p_location_rec.address2,
               p_location_rec.address3,
               p_location_rec.address4,
               p_location_rec.postal_code,
               NULL,
               NULL
             );

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Key Generated : '||l_key,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    p_location_rec.address_key := l_key;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.insert_row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- this is for handling orig_system_reference defaulting
    IF p_location_rec.location_id = fnd_api.g_miss_num THEN
      p_location_rec.location_id := NULL;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'p_location_rec.actual_content_source = '||
                             p_location_rec.actual_content_source,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;
--Bug#8616119
--When Timezone Id not found then we don't raise error
--While removing messages for loop index is not crrect
--Corrected the Index
     if p_location_rec.timezone_id is null or
           p_location_rec.timezone_id = fnd_api.g_miss_num
    then
        l_message_count := fnd_msg_pub.count_msg();
        hz_timezone_pub.get_timezone_id(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                p_postal_code => p_location_rec.postal_code,
                p_city => p_location_rec.city,
                p_state => p_location_rec.state,
                p_country => p_location_rec.country,
                x_timezone_id => l_timezone_id,
                x_return_status => l_return_status ,
                x_msg_count =>l_msg_count ,
                x_msg_data => l_msg_data);
        if l_return_status <> fnd_api.g_ret_sts_success
        then  -- we don't raise error
                l_timezone_id := null;
/*                FOR i IN 1..(l_msg_count - l_message_count) LOOP
                    fnd_msg_pub.delete_msg(l_msg_count - l_message_count + 1 - i);
                END LOOP;
*/
--Bug#8616119
                 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                     hz_utility_v2pub.debug(p_message=>'TimeZone Id not found. Messages are deleted from msg stack',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                 END IF;
                 FOR i IN REVERSE (l_message_count + 1)..l_msg_count LOOP
                     fnd_msg_pub.delete_msg(i);
                 END LOOP;
                l_return_status := FND_API.G_RET_STS_SUCCESS;
        end if;
    -- fix for bug # 5286032.
    -- the above derived timezone_id was not passing into the insert_row procedure.
    p_location_rec.timezone_id := l_timezone_id;
    end if;


    -- call table-handler to insert the record
    hz_locations_pkg.insert_row (
      x_location_id                  => p_location_rec.location_id,
      x_attribute_category           => p_location_rec.attribute_category,
      x_attribute1                   => p_location_rec.attribute1,
      x_attribute2                   => p_location_rec.attribute2,
      x_attribute3                   => p_location_rec.attribute3,
      x_attribute4                   => p_location_rec.attribute4,
      x_attribute5                   => p_location_rec.attribute5,
      x_attribute6                   => p_location_rec.attribute6,
      x_attribute7                   => p_location_rec.attribute7,
      x_attribute8                   => p_location_rec.attribute8,
      x_attribute9                   => p_location_rec.attribute9,
      x_attribute10                  => p_location_rec.attribute10,
      x_attribute11                  => p_location_rec.attribute11,
      x_attribute12                  => p_location_rec.attribute12,
      x_attribute13                  => p_location_rec.attribute13,
      x_attribute14                  => p_location_rec.attribute14,
      x_attribute15                  => p_location_rec.attribute15,
      x_attribute16                  => p_location_rec.attribute16,
      x_attribute17                  => p_location_rec.attribute17,
      x_attribute18                  => p_location_rec.attribute18,
      x_attribute19                  => p_location_rec.attribute19,
      x_attribute20                  => p_location_rec.attribute20,
      x_orig_system_reference        => p_location_rec.orig_system_reference,
      x_country                      => p_location_rec.country,
      x_address1                     => p_location_rec.address1,
      x_address2                     => p_location_rec.address2,
      x_address3                     => p_location_rec.address3,
      x_address4                     => p_location_rec.address4,
      x_city                         => p_location_rec.city,
      x_postal_code                  => p_location_rec.postal_code,
      x_state                        => p_location_rec.state,
      x_province                     => p_location_rec.province,
      x_county                       => p_location_rec.county,
      x_address_key                  => p_location_rec.address_key,
      x_address_style                => p_location_rec.address_style,
      x_validated_flag               => p_location_rec.validated_flag,
      x_address_lines_phonetic       => p_location_rec.address_lines_phonetic,
      x_po_box_number                => p_location_rec.po_box_number,
      x_house_number                 => p_location_rec.house_number,
      x_street_suffix                => p_location_rec.street_suffix,
      x_street                       => p_location_rec.street,
      x_street_number                => p_location_rec.street_number,
      x_floor                        => p_location_rec.floor,
      x_suite                        => p_location_rec.suite,
      x_postal_plus4_code            => p_location_rec.postal_plus4_code,
      x_position                     => p_location_rec.position,
      x_location_directions          => p_location_rec.location_directions,
      x_address_effective_date       => p_location_rec.address_effective_date,
      x_address_expiration_date      => p_location_rec.address_expiration_date,
      x_clli_code                    => p_location_rec.clli_code,
      x_language                     => p_location_rec.language,
      x_short_description            => p_location_rec.short_description,
      x_description                  => p_location_rec.description,
      x_content_source_type          => p_location_rec.content_source_type,
      x_loc_hierarchy_id             => p_location_rec.loc_hierarchy_id,
      x_sales_tax_geocode            => p_location_rec.sales_tax_geocode,
      x_sales_tax_inside_city_limits => p_location_rec.sales_tax_inside_city_limits,
      x_fa_location_id               => p_location_rec.fa_location_id,
      x_geometry                     => p_location_rec.geometry,
      x_object_version_number        => 1,
      x_timezone_id                  => p_location_rec.timezone_id,
      x_created_by_module            => p_location_rec.created_by_module,
      x_application_id               => p_location_rec.application_id,
      x_geometry_status_code         => p_location_rec.geometry_status_code,

      x_actual_content_source        => p_location_rec.actual_content_source,
      -- Bug 2670546.
      x_delivery_point_code          => p_location_rec.delivery_point_code
   );

    x_location_id := p_location_rec.location_id;

-- ACNG add call to location profile: BEGIN

   IF(p_location_rec.state IS NOT NULL) THEN
     l_prov_state_admin_code := p_location_rec.state;
   ELSIF(p_location_rec.province IS NOT NULL) THEN
     l_prov_state_admin_code := p_location_rec.province;
   ELSE
     l_prov_state_admin_code := NULL;
   END IF;

   l_end_date := to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI');

   hz_location_profiles_pkg.Insert_Row (
       x_location_profile_id         => l_location_profile_id
      ,x_location_id                 => x_location_id
      ,x_actual_content_source       => p_location_rec.actual_content_source
      ,x_effective_start_date        => sysdate
      ,x_effective_end_date          => l_end_date
      ,x_validation_sst_flag         => 'Y'
      ,x_validation_status_code      => NULL
      ,x_date_validated              => NULL
      ,x_address1                    => p_location_rec.address1
      ,x_address2                    => p_location_rec.address2
      ,x_address3                    => p_location_rec.address3
      ,x_address4                    => p_location_rec.address4
      ,x_city                        => p_location_rec.city
      ,x_postal_code                 => p_location_rec.postal_code
      ,x_prov_state_admin_code       => l_prov_state_admin_code
      ,x_county                      => p_location_rec.county
      ,x_country                     => p_location_rec.country
      ,x_object_version_number       => 1
   );
-- ACNG add call to location profile: END

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.insert_row (-) ' ||
                                 'x_location_id = ' || p_location_rec.location_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
-- ACNG add call to location profile: BEGIN
        hz_utility_v2pub.debug(p_message=>'hz_location_profiles_pkg.insert_row (-) ' ||
                                 'l_location_profile_id = ' || l_location_profile_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
-- ACNG add call to location profile: END
        hz_utility_v2pub.debug(p_message=>'do_create_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);

    END IF;

    if p_location_rec.orig_system is not null
         and p_location_rec.orig_system <>fnd_api.g_miss_char
      then
                l_orig_sys_reference_rec.orig_system := p_location_rec.orig_system;
                l_orig_sys_reference_rec.orig_system_reference := p_location_rec.orig_system_reference;
                l_orig_sys_reference_rec.owner_table_name := 'HZ_LOCATIONS';
                l_orig_sys_reference_rec.owner_table_id := p_location_rec.location_id;
                l_orig_sys_reference_rec.created_by_module := p_location_rec.created_by_module;

                hz_orig_system_ref_pub.create_orig_system_reference(
                        FND_API.G_FALSE,
                        l_orig_sys_reference_rec,
                        x_return_status,
                        l_msg_count,
                        l_msg_data);
                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
      end if;


  END do_create_location;

  -- Modified the below procedure to add new parameters for address validation.
  -- This is for bug # 4652309. The new parameters will be passed thro the
  -- new update_location overloaded API.
  PROCEDURE do_update_location(
    p_location_rec                  IN OUT  NOCOPY LOCATION_REC_TYPE,
    p_do_addr_val                   IN             VARCHAR2,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    x_addr_val_status               OUT NOCOPY     VARCHAR2,
    x_addr_warn_msg                 OUT NOCOPY     VARCHAR2,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
  ) IS

    l_object_version_number NUMBER;
    l_rowid                 ROWID;
    l_geometry              hz_locations.geometry%TYPE := hz_geometry_default;
    l_key                   VARCHAR2(2000);
    l_debug_prefix          VARCHAR2(30) := '';
    db_city                 hz_locations.city%TYPE;
    db_state                hz_locations.state%TYPE;
    db_country              hz_locations.country%TYPE;
    db_county               hz_locations.county%TYPE;
    db_province             hz_locations.province%TYPE;
    db_postal_code          hz_locations.postal_code%TYPE;
    db_address1             hz_locations.address1%TYPE;
    db_address2             hz_locations.address2%TYPE;
    db_address3             hz_locations.address3%TYPE;
    db_address4             hz_locations.address4%TYPE;
    db_content_source_type  hz_locations.content_source_type%TYPE;

-- ACNG add call to location profile: BEGIN
    l_location_profile_rec  hz_location_profile_pvt.location_profile_rec_type;
    l_profile_content_source  VARCHAR2(30);
    l_return_status           VARCHAR2(30);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_tax_validation_failed   VARCHAR2(1);
    l_allow_update_std        VARCHAR2(1);
    l_date_validated          DATE;
    l_validation_status_code  VARCHAR2(30);
-- ACNG add call to location profile: END

    -- Bug 2983977
    l_loc_id                  NUMBER;
--  Bug 4693719 : Added for local assignment
    l_acs  hz_locations.actual_content_source%TYPE;
    db_actual_content_source  hz_locations.actual_content_source%TYPE;


  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_location (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

     -- if party_site_id is not passed in, but orig system parameters are passed in
    -- get party_site_id

      IF (p_location_rec.orig_system is not null
         and p_location_rec.orig_system <>fnd_api.g_miss_char)
       and (p_location_rec.orig_system_reference is not null
         and p_location_rec.orig_system_reference <>fnd_api.g_miss_char)
       and (p_location_rec.location_id = FND_API.G_MISS_NUM or p_location_rec.location_id is null) THEN
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_location_rec.orig_system,
                        p_orig_system_reference => p_location_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_LOCATIONS',
                        x_owner_table_id => p_location_rec.location_id,
                        x_return_status => x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;

    -- check whether record has been updated by another user

    -- Bug 2197181: selecting actual_content_source for  mix-n-match project.

    BEGIN
      SELECT hl.object_version_number,
             hl.rowid,
             hl.geometry,
             hl.country,
             hl.address1,
             hl.address2,
             hl.address3,
             hl.address4,
             hl.city,
             hl.postal_code,
             hl.state,
             hl.province,
             hl.county,
             hl.content_source_type,
             hl.actual_content_source,
         --  Bug 4693719 : select ACS
             hl.actual_content_source,
             hl.date_validated,
             hl.validation_status_code
      INTO   l_object_version_number,
             l_rowid,
             l_geometry,
             db_country,
             db_address1,
             db_address2,
             db_address3,
             db_address4,
             db_city,
             db_postal_code,
             db_state,
             db_province,
             db_county,
             db_content_source_type,
             l_profile_content_source,
             db_actual_content_source,
             l_date_validated,
             l_validation_status_code
      FROM   hz_locations hl
      WHERE  hl.location_id = p_location_rec.location_id
      FOR    UPDATE OF hl.location_id NOWAIT;

      IF NOT ((p_object_version_number IS NULL
               AND l_object_version_number IS NULL)
              OR (p_object_version_number IS NOT NULL AND
                  l_object_version_number IS NOT NULL AND
                  p_object_version_number = l_object_version_number))
      THEN
        fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
        fnd_message.set_token('TABLE', 'hz_locations');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      p_object_version_number := NVL(l_object_version_number, 1) + 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'location');
        fnd_message.set_token('VALUE',
                              NVL(TO_CHAR(p_location_rec.location_id),'null'));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

-- ACNG
    -- raise error if the update location profile option is turned off and
    -- the address has been validated before
    l_allow_update_std := nvl(fnd_profile.value('HZ_UPDATE_STD_ADDRESS'), 'Y');
    IF(l_allow_update_std = 'N' AND
       l_date_validated IS NOT NULL AND
       l_validation_status_code IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_NO_UPDATE');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF(p_location_rec.actual_content_source IS NOT NULL) THEN
      IF(l_profile_content_source <> p_location_rec.actual_content_source) THEN
        l_profile_content_source := p_location_rec.actual_content_source;
        --  Bug 4693719 : ACS should not be set to NULL
--        p_location_rec.actual_content_source := NULL;
      END IF;
    END IF;
-- ACNG

    -- call for validations.
    hz_registry_validate_v2pub.validate_location(
      'U',
      p_location_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- conditions to check if p_location_rec.geometry holds the default value.

    IF p_location_rec.geometry.sdo_gtype <> fnd_api.g_miss_num
       OR p_location_rec.geometry.sdo_srid <> fnd_api.g_miss_num
       OR p_location_rec.geometry.sdo_point IS NOT NULL
       OR p_location_rec.geometry.sdo_elem_info IS NOT NULL
       OR p_location_rec.geometry.sdo_ordinates IS NOT NULL
       OR p_location_rec.geometry IS NULL
    THEN
      l_geometry := p_location_rec.geometry;
    END IF;

    -- call address key generation program
    l_key := hz_fuzzy_pub.generate_key (
               'ADDRESS',
               NULL,
               p_location_rec.address1,
               p_location_rec.address2,
               p_location_rec.address3,
               p_location_rec.address4,
               p_location_rec.postal_code,
               NULL,
               NULL
             );

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Key generated : '||l_key,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    p_location_rec.address_key := l_key;
    p_location_rec.geometry := l_geometry;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.Update_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

--  Bug 4693719 : pass NULL if the secure data is not updated
   IF HZ_UTILITY_V2PUB.G_UPDATE_ACS = 'Y' THEN
       l_acs := nvl(p_location_rec.actual_content_source, 'USER_ENTERED');
   ELSE
       l_acs := NULL;
   END IF;

    -- call to table-handler to update the record
    hz_locations_pkg.update_row (
      x_rowid                        => l_rowid,
      x_location_id                  => p_location_rec.location_id,
      x_attribute_category           => p_location_rec.attribute_category,
      x_attribute1                   => p_location_rec.attribute1,
      x_attribute2                   => p_location_rec.attribute2,
      x_attribute3                   => p_location_rec.attribute3,
      x_attribute4                   => p_location_rec.attribute4,
      x_attribute5                   => p_location_rec.attribute5,
      x_attribute6                   => p_location_rec.attribute6,
      x_attribute7                   => p_location_rec.attribute7,
      x_attribute8                   => p_location_rec.attribute8,
      x_attribute9                   => p_location_rec.attribute9,
      x_attribute10                  => p_location_rec.attribute10,
      x_attribute11                  => p_location_rec.attribute11,
      x_attribute12                  => p_location_rec.attribute12,
      x_attribute13                  => p_location_rec.attribute13,
      x_attribute14                  => p_location_rec.attribute14,
      x_attribute15                  => p_location_rec.attribute15,
      x_attribute16                  => p_location_rec.attribute16,
      x_attribute17                  => p_location_rec.attribute17,
      x_attribute18                  => p_location_rec.attribute18,
      x_attribute19                  => p_location_rec.attribute19,
      x_attribute20                  => p_location_rec.attribute20,
      x_orig_system_reference        => p_location_rec.orig_system_reference,
      x_country                      => p_location_rec.country,
      x_address1                     => p_location_rec.address1,
      x_address2                     => p_location_rec.address2,
      x_address3                     => p_location_rec.address3,
      x_address4                     => p_location_rec.address4,
      x_city                         => p_location_rec.city,
      x_postal_code                  => p_location_rec.postal_code,
      x_state                        => p_location_rec.state,
      x_province                     => p_location_rec.province,
      x_county                       => p_location_rec.county,
      x_address_key                  => p_location_rec.address_key,
      x_address_style                => p_location_rec.address_style,
      x_validated_flag               => p_location_rec.validated_flag,
      x_address_lines_phonetic       => p_location_rec.address_lines_phonetic,
      x_po_box_number                => p_location_rec.po_box_number,
      x_house_number                 => p_location_rec.house_number,
      x_street_suffix                => p_location_rec.street_suffix,
      x_street                       => p_location_rec.street,
      x_street_number                => p_location_rec.street_number,
      x_floor                        => p_location_rec.floor,
      x_suite                        => p_location_rec.suite,
      x_postal_plus4_code            => p_location_rec.postal_plus4_code,
      x_position                     => p_location_rec.position,
      x_location_directions          => p_location_rec.location_directions,
      x_address_effective_date       => p_location_rec.address_effective_date,
      x_address_expiration_date      => p_location_rec.address_expiration_date,
      x_clli_code                    => p_location_rec.clli_code,
      x_language                     => p_location_rec.language,
      x_short_description            => p_location_rec.short_description,
      x_description                  => p_location_rec.description,
      -- Bug 2197181 : content_source_type is obsolete and it is non-updateable.
      x_content_source_type          => NULL,
      x_loc_hierarchy_id             => p_location_rec.loc_hierarchy_id,
      x_sales_tax_geocode            => p_location_rec.sales_tax_geocode,
      x_sales_tax_inside_city_limits => p_location_rec.sales_tax_inside_city_limits,
      x_fa_location_id               => p_location_rec.fa_location_id,
      x_geometry                     => p_location_rec.geometry,
      x_object_version_number        => p_object_version_number,
      x_timezone_id                  => p_location_rec.timezone_id,
      x_created_by_module            => p_location_rec.created_by_module,
      x_application_id               => p_location_rec.application_id,
      x_geometry_status_code         => p_location_rec.geometry_status_code,
   --  Bug 4693719 : Pass correct value for ACS
      x_actual_content_source        => l_acs,
      -- Bug 2670546
      x_delivery_point_code          => p_location_rec.delivery_point_code
   );

-- ACNG add call to location profile: BEGIN
-- check if change occur on those columns where affecting location profile
-- and also if the l_actual_content_source is not USER_ENTERED or DNB
-- if yes, then do update.  Otherwise, do nothing

   IF((p_location_rec.country IS NOT NULL AND
       NVL(db_country, fnd_api.g_miss_char) <> p_location_rec.country)
     OR (p_location_rec.address1 IS NOT NULL AND
       NVL(db_address1,fnd_api.g_miss_char) <> p_location_rec.address1)
     OR (p_location_rec.address2 IS NOT NULL AND
       NVL(db_address2,fnd_api.g_miss_char) <> p_location_rec.address2)
     OR (p_location_rec.address3 IS NOT NULL AND
       NVL(db_address3,fnd_api.g_miss_char) <> p_location_rec.address3)
     OR (p_location_rec.address4 IS NOT NULL AND
       NVL(db_address4,fnd_api.g_miss_char) <> p_location_rec.address4)
     OR (p_location_rec.city IS NOT NULL AND
       NVL(db_city, fnd_api.g_miss_char) <> p_location_rec.city)
     OR (p_location_rec.postal_code IS NOT NULL AND
       NVL(db_postal_code, fnd_api.g_miss_char) <> p_location_rec.postal_code)
     OR (p_location_rec.state IS NOT NULL AND
       NVL(db_state, fnd_api.g_miss_char) <> p_location_rec.state)
     OR (p_location_rec.province IS NOT NULL AND
       NVL(db_province,fnd_api.g_miss_char) <> p_location_rec.province)
     OR (p_location_rec.county IS NOT NULL AND
       NVL(db_county, fnd_api.g_miss_char) <> p_location_rec.county))
     --OR NOT(l_profile_content_source in ('USER_ENTERED', 'DNB'))
   THEN

     l_location_profile_rec.location_profile_id := NULL;
     l_location_profile_rec.location_id := p_location_rec.location_id;
     --  Bug 4693719 : Keep ACS in sync with hz_locations
     l_location_profile_rec.actual_content_source := nvl(l_acs, l_profile_content_source);
     l_location_profile_rec.effective_start_date := NULL;
     l_location_profile_rec.effective_end_date := NULL;
     l_location_profile_rec.date_validated := NULL;
     l_location_profile_rec.city := p_location_rec.city;

     -- Bug 3395521.Passed the old database values if the user had passed NULL
     -- for the following columns.
     l_location_profile_rec.city := NVL(p_location_rec.city,db_city);
     l_location_profile_rec.postal_code := NVL(p_location_rec.postal_code,db_postal_code);
     l_location_profile_rec.county := NVL(p_location_rec.county,db_county);
     l_location_profile_rec.country := NVL(p_location_rec.country,db_country);
     l_location_profile_rec.address1 := NVL(p_location_rec.address1,db_address1);
     l_location_profile_rec.address2 := NVL(p_location_rec.address2,db_address2);
     l_location_profile_rec.address3 := NVL(p_location_rec.address3,db_address3);
     l_location_profile_rec.address4 := NVL(p_location_rec.address4,db_address4);
     l_location_profile_rec.validation_status_code := fnd_api.g_miss_char;
     l_location_profile_rec.date_validated := fnd_api.g_miss_date;

     IF(p_location_rec.state IS NULL) THEN
       IF(p_location_rec.province IS NULL) OR (p_location_rec.province = fnd_api.g_miss_char) THEN
         l_location_profile_rec.prov_state_admin_code := db_state;
       ELSE
         IF(db_state IS NULL) THEN
           l_location_profile_rec.prov_state_admin_code := p_location_rec.province;
         ELSE
           l_location_profile_rec.prov_state_admin_code := db_state;
         END IF;
       END IF;
     ELSIF(p_location_rec.state = fnd_api.g_miss_char) THEN
       IF(p_location_rec.province IS NULL) THEN
         l_location_profile_rec.prov_state_admin_code := db_province;
       ELSIF(p_location_rec.province = fnd_api.g_miss_char) THEN
         l_location_profile_rec.prov_state_admin_code := fnd_api.g_miss_char;
       ELSE
         l_location_profile_rec.prov_state_admin_code := p_location_rec.province;
       END IF;
     ELSE
       l_location_profile_rec.prov_state_admin_code := p_location_rec.state;
     END IF;

     l_return_status := FND_API.G_RET_STS_SUCCESS;

     hz_location_profile_pvt.update_location_profile (
       p_location_profile_rec      => l_location_profile_rec
      ,x_return_status             => l_return_status
      ,x_msg_count                 => l_msg_count
      ,x_msg_data                  => l_msg_data );

     IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE fnd_api.g_exc_error;
     ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;

   END IF;

-- ACNG add call to location profile: END

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.update_row (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- update de-normalized location components in HZ_PARTIES for parties
    -- having this location as an identifying location. There can be multiple
    -- such parties.

   -- Bug 2197181: As part of Mix n Match project, the location components
   -- need to be de-normalized irrespective of the content_source, hence
   -- commenting out NOCOPY the condition.

--    IF db_content_source_type = 'USER_ENTERED'
--    THEN
      DECLARE
        l_party_id                   NUMBER;

        CURSOR c1 IS
          SELECT hps.party_id
          FROM   hz_party_sites hps
          WHERE  hps.location_id = p_location_rec.location_id
          AND    hps.identifying_address_flag = 'Y';
      BEGIN
        IF (p_location_rec.country IS NOT NULL AND
            NVL(db_country, fnd_api.g_miss_char) <> p_location_rec.country)
           OR (p_location_rec.address1 IS NOT NULL AND
               NVL(db_address1,fnd_api.g_miss_char) <> p_location_rec.address1)
           OR (p_location_rec.address2 IS NOT NULL AND
               NVL(db_address2,fnd_api.g_miss_char) <> p_location_rec.address2)
           OR (p_location_rec.address3 IS NOT NULL AND
               NVL(db_address3,fnd_api.g_miss_char) <> p_location_rec.address3)
           OR (p_location_rec.address4 IS NOT NULL AND
               NVL(db_address4,fnd_api.g_miss_char) <> p_location_rec.address4)
           OR (p_location_rec.city IS NOT NULL AND
               NVL(db_city, fnd_api.g_miss_char) <> p_location_rec.city)
           OR (p_location_rec.postal_code IS NOT NULL AND
               NVL(db_postal_code, fnd_api.g_miss_char) <> p_location_rec.postal_code)
           OR (p_location_rec.state IS NOT NULL AND
               NVL(db_state, fnd_api.g_miss_char) <> p_location_rec.state)
           OR (p_location_rec.province IS NOT NULL AND
               NVL(db_province,fnd_api.g_miss_char) <> p_location_rec.province)
           OR (p_location_rec.county IS NOT NULL AND
               NVL(db_county, fnd_api.g_miss_char) <> p_location_rec.county)
        THEN
          BEGIN
            OPEN c1;
            LOOP
              FETCH c1 INTO l_party_id;
              EXIT WHEN c1%NOTFOUND;

              -- Debug info.
              IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'Denormalizing party with ID: ' ||
                                         l_party_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
              END IF;

              -- Bug 2246041: Denormalization should not be done for Remit To
              --              Addresses.

              IF l_party_id <> -1 THEN
                 SELECT party_id
                 INTO   l_party_id
                 FROM   hz_parties
                 WHERE  party_id = l_party_id
                 FOR UPDATE NOWAIT;

                 UPDATE hz_parties
                 SET    country     = DECODE(p_location_rec.country,
                                          NULL, db_country,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.country),
                        address1    = DECODE(p_location_rec.address1,
                                          NULL, db_address1,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.address1),
                        address2    = DECODE(p_location_rec.address2,
                                          NULL, db_address2,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.address2),
                        address3    = DECODE(p_location_rec.address3,
                                          NULL, db_address3,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.address3),
                        address4    = DECODE(p_location_rec.address4,
                                          NULL, db_address4,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.address4),
                        city        = DECODE(p_location_rec.city,
                                          NULL, db_city,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.city),
                        postal_code = DECODE(p_location_rec.postal_code,
                                          NULL, db_postal_code,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.postal_code),
                        state       = DECODE(p_location_rec.state,
                                          NULL, db_state,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.state),
                        province    = DECODE(p_location_rec.province,
                                          NULL, db_province,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.province),
                        county      = DECODE(p_location_rec.county,
                                          NULL, db_county,
                                          fnd_api.g_miss_char, NULL,
                                          p_location_rec.county),
                        last_update_date     = hz_utility_v2pub.last_update_date,
                        last_updated_by      = hz_utility_v2pub.last_updated_by,
                        last_update_login    = hz_utility_v2pub.last_update_login,
                        request_id           = hz_utility_v2pub.request_id,
                        program_id           = hz_utility_v2pub.program_id,
                        program_application_id = hz_utility_v2pub.program_application_id,
                        program_update_date  = hz_utility_v2pub.program_update_date
                 WHERE  party_id = l_party_id;

              END IF; -- Only if address is not a Remit to.
            END LOOP;
            CLOSE c1;

          EXCEPTION
            WHEN OTHERS THEN
              fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
              fnd_message.set_token('TABLE', 'HZ_PARTIES');
              fnd_msg_pub.add;
              CLOSE c1;
              RAISE fnd_api.g_exc_error;
          END;
        END IF; -- location components have been modified
      END;
--    END IF;  -- p_location_rec.content_source_type = 'USER_ENTERED'


    -- Bug 2983977.Added call to update loc_assignment records corresponding to this location_id.

    HZ_TAX_ASSIGNMENT_V2PUB.update_loc_assignment (
          p_location_id          => p_location_rec.location_id,
          p_do_addr_val          => p_do_addr_val,
          x_addr_val_status      => x_addr_val_status,
          x_addr_warn_msg        => x_addr_warn_msg,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data);

     IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE fnd_api.g_exc_error;
     ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;



    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  END do_update_location;

  PROCEDURE fill_geometry(
    p_loc_rec            IN OUT            NOCOPY LOCATION_REC_TYPE,
    x_return_status         OUT NOCOPY            VARCHAR2
  ) IS
    l_api_version                CONSTANT  NUMBER := 1.0;
    l_csf_installed_flag                   VARCHAR2(30) := 'N';
    l_cursor                               VARCHAR2(2000);
    l_country                              VARCHAR2(100);
    l_state                                VARCHAR2(100);
    l_city                                 VARCHAR2(100);
    l_zip                                  VARCHAR2(100);
    l_hn                                   VARCHAR2(100);
    l_st                                   VARCHAR2(400);

  BEGIN
    -- Bug 2334810: Obsoleted code that was superseded by the eLocations
    -- integration by removing references to CSF_LF*
    x_return_status := 'N';
  END fill_geometry;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_location
 *
 * DESCRIPTION
 *     Creates location(overloaded procedure with address validation).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *     p_do_addr_val                  Do address validation if 'Y'
 *   IN/OUT:
 *   OUT:
 *     x_location_id                  Location ID.
 *     x_addr_val_status              Address validation status based on address validation level.
 *     x_addr_warn_msg                Warning message if x_addr_val_status is 'W'
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-04-2005    Baiju Nair        o Created.
 *
 */

PROCEDURE create_location (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_location_rec                     IN      LOCATION_REC_TYPE,
    p_do_addr_val                      IN             VARCHAR2,
    x_location_id                      OUT NOCOPY     NUMBER,
    x_addr_val_status                  OUT NOCOPY     VARCHAR2,
    x_addr_warn_msg                    OUT NOCOPY     VARCHAR2,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY    VARCHAR2
) IS

    l_location_rec                      LOCATION_REC_TYPE := p_location_rec;
    l_fill_geo_status                   VARCHAR2(10);
    l_debug_prefix                     VARCHAR2(30) := '';

    -- Bug 3594731: fix the bug 3517181 in the main code line.

    dss_return_status           VARCHAR2(1);
    dss_msg_count               NUMBER;
    dss_msg_data                VARCHAR2(2000);
    l_test_security             VARCHAR2(1);

    l_addr_val_level  VARCHAR2(30);

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_location;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_location (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_addr_val_status := NULL;

    fill_geometry(l_location_rec, l_fill_geo_status);

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity. Then assign the actual_content_source
    -- to the real data source. The value of content_source_type is
    -- depended on if data source is seleted. If it is selected, we reset
    -- content_source_type to user-entered. We also check if user
    -- has the privilege to create user-entered data if mix-n-match
    -- is enabled.

    -- Bug 2444678: Removed caching.

/*  SSM SST Integration and Extension
 *  For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    -- IF g_loc_mixnmatch_enabled IS NULL THEN
    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_loc_entity_attr_id,
      p_mixnmatch_enabled              => g_loc_mixnmatch_enabled,
      p_selected_datasources           => g_loc_selected_datasources );
    -- END IF;
*/

    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_loc_entity_attr_id,
      p_mixnmatch_enabled              => g_loc_mixnmatch_enabled,
      p_selected_datasources           => g_loc_selected_datasources,
      p_content_source_type            => l_location_rec.content_source_type,
      p_actual_content_source          => l_location_rec.actual_content_source,
      x_is_datasource_selected         => g_loc_is_datasource_selected,
      x_return_status                  => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'C',
        p_location_rec               => l_location_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- call to business logic.
    do_create_location(
                       l_location_rec,
                       x_location_id,
                       x_return_status);

    -- If p_do_addr_val = 'Y' and create_location is success, call the address validation procedure.
    IF (p_do_addr_val = 'Y' AND x_location_id is NOT NULL AND x_return_status = FND_API.g_ret_sts_success) THEN
      HZ_GNR_PUB.validateLoc(
           p_location_id          => x_location_id,
           p_init_msg_list        => FND_API.G_FALSE,
           x_addr_val_level       => l_addr_val_level,
           x_addr_warn_msg        => x_addr_warn_msg,
           x_addr_val_status      => x_addr_val_status,
           x_return_status        => x_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
           RAISE FND_API.G_EXC_ERROR;
       end if;

	END IF;


    -- Bug 3711629: remove the dss check in create location API.
    /*
    -- Bug 3594731: fix the bug 3517181 in the main code line.
    -- IN A NUTSHELL THE DSS CHECK THAT IS NEEDED IN THE LOCATION API, FOR SECURING
    -- THE HZ_LOCATIONS ENTITY WAS INADVERTENTLY MISSED DURING THE CODING PHASE OF
    -- THE DSS PROJECT

    l_test_security :=
      hz_dss_util_pub.test_instance(
        p_operation_code     => 'INSERT',
        p_db_object_name     => 'HZ_LOCATIONS',
        p_instance_pk1_value => x_location_id,
        p_user_name          => fnd_global.user_name,
        x_return_status      => dss_return_status,
        x_msg_count          => dss_msg_count,
        x_msg_data           => dss_msg_data);

    IF dss_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_SECURITY_FAIL');
      FND_MESSAGE.SET_TOKEN('USER_NAME',fnd_global.user_name);
      FND_MESSAGE.SET_TOKEN('OPER_NAME','INSERT');
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME','HZ_LOCATIONS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    -- Invoke business event system.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status = FND_API.G_RET_STS_SUCCESS /*AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_loc_is_datasource_selected = 'Y'*/
    THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_location_event (
          l_location_rec);
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_locations(
          p_operation   => 'I',
          p_location_id => x_location_id );
      END IF;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_location;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_location;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_location;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_location;

/**
 * PROCEDURE create_location
 *
 * DESCRIPTION
 *     Creates location.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_location_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *   IN/OUT:
 *   OUT:
 *     x_location_id                  Location ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *   01-03-2005    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                       For non-profile entities, the concept of
 *                                       select/de-select data-sources is obsoleted.
 */

PROCEDURE create_location (
    p_init_msg_list              IN     VARCHAR2:= FND_API.G_FALSE,
    p_location_rec               IN     LOCATION_REC_TYPE,
    x_location_id                OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
) IS

  l_addr_val_status  VARCHAR2(30);
  l_addr_warn_msg    VARCHAR2(2000);

BEGIN

   create_location(
          p_init_msg_list       => p_init_msg_list,
          p_location_rec        => p_location_rec,
          p_do_addr_val         => 'N',
          x_location_id         => x_location_id,
          x_addr_val_status     => l_addr_val_status,
          x_addr_warn_msg       => l_addr_warn_msg,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);

   EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
END create_location;

/**
 * PROCEDURE update_location
 *
 * DESCRIPTION
 *     Updates location(overloaded procedure with address validation).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *     p_do_addr_val                  Do address validation if 'Y'
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_addr_val_status              Address validation status based on address validation level.
 *     x_addr_warn_msg                Warning message if x_addr_val_status is 'W'
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-04-2005    Baiju Nair        o Created.
 *
 */

PROCEDURE update_location (
    p_init_msg_list             IN      VARCHAR2:=FND_API.G_FALSE,
    p_location_rec              IN      LOCATION_REC_TYPE,
    p_do_addr_val               IN             VARCHAR2,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_addr_val_status           OUT NOCOPY     VARCHAR2,
    x_addr_warn_msg             OUT NOCOPY     VARCHAR2,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

    CURSOR c_standalone_location IS
    SELECT 1
    FROM   hz_party_sites
    WHERE  location_id = p_location_rec.location_id
    AND    status NOT IN ('M', 'D')
    AND    ROWNUM = 1;

    l_location_rec                     LOCATION_REC_TYPE := p_location_rec;
    l_old_location_rec                 LOCATION_REC_TYPE;
    l_fill_geo_status                  VARCHAR2(10);
    l_data_source_from                 VARCHAR2(30);

    l_msg_count number;
    l_message_count number;
    l_msg_data varchar2(2000);
    l_return_status varchar2(1);

    l_changed_flag varchar2(1) := 'N';
    l_debug_prefix                     VARCHAR2(30) := '';

    -- Bug 3594731: fix the bug 3517181 in the main code line.

    dss_return_status                  VARCHAR2(1);
    dss_msg_count                      NUMBER;
    dss_msg_data                       VARCHAR2(2000);
    l_test_security                    VARCHAR2(1);
    l_dummy                            NUMBER;
    l_standalone_location              VARCHAR2(1);

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_location;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_location (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- if location_id is not passed in, but orig system parameters are passed in
    -- get location_id

    IF (p_location_rec.orig_system is not null
        and p_location_rec.orig_system <>fnd_api.g_miss_char)
       and (p_location_rec.orig_system_reference is not null
       and p_location_rec.orig_system_reference <>fnd_api.g_miss_char)
       and (p_location_rec.location_id = FND_API.G_MISS_NUM or p_location_rec.location_id is null) THEN
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_location_rec.orig_system,
                        p_orig_system_reference => p_location_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_LOCATIONS',
                        x_owner_table_id => l_location_rec.location_id,
                        x_return_status => x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
    END IF;

    -- Bug 3711629: remove the dss check in create location API.
    -- during update, skip the dss check if the location is
    -- a standalone location.
    -- Bug 3818648: check dss profile before call test_instance.
    --
    -- Bug 3594731: fix the bug 3517181 in the main code line.
    -- IN A NUTSHELL THE DSS CHECK THAT IS NEEDED IN THE LOCATION API, FOR SECURING
    -- THE HZ_LOCATIONS ENTITY WAS INADVERTENTLY MISSED DURING THE CODING PHASE OF
    -- THE DSS PROJECT

    IF  NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' THEN

      OPEN c_standalone_location;
      FETCH c_standalone_location INTO l_dummy;
      IF c_standalone_location%FOUND THEN
        l_standalone_location := 'N';
      ELSE
        l_standalone_location := 'Y';
      END IF;
      CLOSE c_standalone_location;

      IF l_standalone_location = 'N' THEN
        l_test_security :=
          hz_dss_util_pub.test_instance(
            p_operation_code     => 'UPDATE',
            p_db_object_name     => 'HZ_LOCATIONS',
            p_instance_pk1_value => l_location_rec.location_id,
            p_user_name          => fnd_global.user_name,
            x_return_status      => dss_return_status,
            x_msg_count          => dss_msg_count,
            x_msg_data           => dss_msg_data);

        IF dss_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) THEN
          --
          -- Bug 3835601: replaced the dss message with a more user friendly message
          --
          FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_UPDATE_PRIVILEGE');
          FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                                fnd_message.get_string('AR', 'HZ_DSS_PARTY_ADDRESSES'));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    -- Get old records. Will be used by business event system.
    get_location_rec (
        p_location_id                        => l_location_rec.location_id,
        x_location_rec                       => l_old_location_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    fill_geometry(l_location_rec, l_fill_geo_status);

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

    -- IF g_loc_mixnmatch_enabled IS NULL THEN
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_LOCATIONS',
      p_entity_attr_id                 => g_loc_entity_attr_id,
      p_mixnmatch_enabled              => g_loc_mixnmatch_enabled,
      p_selected_datasources           => g_loc_selected_datasources );
*/
    -- END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    g_loc_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_loc_selected_datasources,
        p_actual_content_source          => l_old_location_rec.actual_content_source );
*/
       IF (p_location_rec.country IS NOT NULL AND
            NVL(l_old_location_rec.country, fnd_api.g_miss_char) <> p_location_rec.country)
        OR (p_location_rec.city IS NOT NULL AND
               NVL(l_old_location_rec.city, fnd_api.g_miss_char) <> p_location_rec.city)
        OR (p_location_rec.state IS NOT NULL AND
               NVL(l_old_location_rec.state, fnd_api.g_miss_char) <>p_location_rec.state)
        OR (p_location_rec.postal_code IS NOT NULL AND
        NVL(l_old_location_rec.postal_code, fnd_api.g_miss_char) <> p_location_rec.postal_code)
    then
        l_changed_flag := 'Y';
    end if;
--Bug#8616119
--When Timezone Id not found then we don't raise error
--While removing messages for loop index is not crrect
--Corrected the Index
    if l_changed_flag = 'Y' and (p_location_rec.timezone_id is null or p_location_rec.timezone_id = fnd_api.g_miss_num)
    then
        if p_location_rec.country IS NULL
        then
                l_location_rec.country := l_old_location_rec.country;
        end if;
        if p_location_rec.postal_code IS NULL
        then
                l_location_rec.postal_code := l_old_location_rec.postal_code;
        end if;
        if p_location_rec.city IS NULL
        then
                l_location_rec.city := l_old_location_rec.city;
        end if;
        if p_location_rec.state IS NULL
        then
                l_location_rec.state := l_old_location_rec.state;
        end if;
        l_message_count := fnd_msg_pub.count_msg();
        hz_timezone_pub.get_timezone_id(
                p_api_version => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                p_postal_code => l_location_rec.postal_code,
                p_city => l_location_rec.city,
                p_state => l_location_rec.state,
                p_country => l_location_rec.country,
                x_timezone_id => l_location_rec.timezone_id,
                x_return_status => l_return_status ,
                x_msg_count =>l_msg_count ,
                x_msg_data => l_msg_data);
                if l_return_status <> fnd_api.g_ret_sts_success
                then  -- we don't raise error
                        l_location_rec.timezone_id := fnd_api.g_miss_num;
/*                        FOR i IN 1..(l_msg_count - l_message_count) LOOP
                            fnd_msg_pub.delete_msg(l_msg_count - l_message_count + 1 - i);
                        END LOOP;
*/--Bug#8616119
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                          hz_utility_v2pub.debug(p_message=>'TimeZone Id not found. Messages are deleted from msg stack',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                        END IF;
                        FOR i IN REVERSE (l_message_count + 1)..l_msg_count LOOP
                           fnd_msg_pub.delete_msg(i);
                        END LOOP;
                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                end if;
    end if;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'U',
        p_location_rec               => l_location_rec,
        p_old_location_rec           => l_old_location_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- call to business logic.
    -- Modified the below call to pass new parameters for address validation.
    -- This is for bug # 4652309. The new parameters will be passed thro the
    -- new update_location overloaded API. If it is called from old
    -- update_location API, then p_do_addr_val will be 'N'
    do_update_location(
                       l_location_rec,
                       p_do_addr_val,
                       p_object_version_number,
                       x_addr_val_status,
                       x_addr_warn_msg,
                       x_return_status);

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'Before the Supplier Denorm Call',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    AP_TCA_SUPPLIER_SYNC_PKG.SYNC_Supplier_Sites(x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 x_location_id   => l_location_rec.location_id,
                                                 x_party_site_id => NULL);

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_prefix=>l_debug_prefix,p_message=>'After the Supplier Denorm Call',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call to indicate location update to DQM
    HZ_DQM_SYNC.sync_location(l_location_rec.location_id,'U');
    IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      update_location_search(l_old_location_rec,l_location_rec);
    END IF;

    -- Invoke business event system.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status = FND_API.G_RET_STS_SUCCESS /*AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_loc_is_datasource_selected = 'Y'*/
    THEN
      l_old_location_rec.orig_system := p_location_rec.orig_system;
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_location_event (
          l_location_rec,
          l_old_location_rec);
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_locations(
          p_operation   => 'U',
          p_location_id => l_location_rec.location_id );
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_location;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_location;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_location;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_location (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_location;

/**
 * PROCEDURE update_location
 *
 * DESCRIPTION
 *     Updates location.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_location_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_location_rec                 Location record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *   01-03-2005    Rajib Ranjan Borah  o SSM SST Integration and Extension.
 *                                       For non-profile entities, the concept of
 *                                       select/de-select data-sources is obsoleted.
 *
 */

PROCEDURE update_location (
    p_init_msg_list             IN      VARCHAR2:=FND_API.G_FALSE,
    p_location_rec              IN      LOCATION_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

  l_addr_val_status  VARCHAR2(30);
  l_addr_warn_msg    VARCHAR2(2000);

BEGIN

   update_location(
          p_init_msg_list          => p_init_msg_list,
          p_location_rec           => p_location_rec,
          p_do_addr_val            => 'N',
          p_object_version_number  => p_object_version_number,
          x_addr_val_status        => l_addr_val_status,
          x_addr_warn_msg          => l_addr_warn_msg,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

   EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
END update_location;

  /**
   * PROCEDURE get_location_rec
   *
   * DESCRIPTION
   *     Gets location record.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     hz_locations_PKG.Select_Row
   *
   * ARGUMENTS
   *   IN:
   *     p_init_msg_list      Initialize message stack if it is set to
   *                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
   *     p_location_id        Location ID.
   *   IN/OUT:
   *   OUT:
   *     x_location_rec       Location record.
   *     x_return_status      Return status after the call. The status can
   *                          be FND_API.G_RET_STS_SUCCESS (success),
   *                          FND_API.G_RET_STS_ERROR (error),
   *                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
   *     x_msg_count          Number of messages in message stack.
   *     x_msg_data           Message text if x_msg_count is 1.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Indrajit Sen        o Created.
   *   25-JAN-2002   Joe del Callar      Bug 2200569: added the column
   *                                     geometry status for spatial data
   *                                     integration.
   *   14-NOV-2003   Rajib Ranjan Borah  o Bug 2670546.Reintroduced column
   *                                     delivery_point_code
   */

  PROCEDURE get_location_rec (
    p_init_msg_list                         IN     VARCHAR2 := fnd_api.g_false,
    p_location_id                           IN     NUMBER,
    x_location_rec                          OUT    NOCOPY location_rec_type,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_location_rec (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check whether primary key has been passed in.
    IF p_location_id IS NULL OR
       p_location_id = fnd_api.g_miss_num THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
      fnd_message.set_token('COLUMN', 'location_id');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_location_rec.location_id := p_location_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.Select_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    hz_locations_pkg.select_row (
      x_location_id                  => x_location_rec.location_id,
      x_attribute_category           => x_location_rec.attribute_category,
      x_attribute1                   => x_location_rec.attribute1,
      x_attribute2                   => x_location_rec.attribute2,
      x_attribute3                   => x_location_rec.attribute3,
      x_attribute4                   => x_location_rec.attribute4,
      x_attribute5                   => x_location_rec.attribute5,
      x_attribute6                   => x_location_rec.attribute6,
      x_attribute7                   => x_location_rec.attribute7,
      x_attribute8                   => x_location_rec.attribute8,
      x_attribute9                   => x_location_rec.attribute9,
      x_attribute10                  => x_location_rec.attribute10,
      x_attribute11                  => x_location_rec.attribute11,
      x_attribute12                  => x_location_rec.attribute12,
      x_attribute13                  => x_location_rec.attribute13,
      x_attribute14                  => x_location_rec.attribute14,
      x_attribute15                  => x_location_rec.attribute15,
      x_attribute16                  => x_location_rec.attribute16,
      x_attribute17                  => x_location_rec.attribute17,
      x_attribute18                  => x_location_rec.attribute18,
      x_attribute19                  => x_location_rec.attribute19,
      x_attribute20                  => x_location_rec.attribute20,
      x_orig_system_reference        => x_location_rec.orig_system_reference,
      x_country                      => x_location_rec.country,
      x_address1                     => x_location_rec.address1,
      x_address2                     => x_location_rec.address2,
      x_address3                     => x_location_rec.address3,
      x_address4                     => x_location_rec.address4,
      x_city                         => x_location_rec.city,
      x_postal_code                  => x_location_rec.postal_code,
      x_state                        => x_location_rec.state,
      x_province                     => x_location_rec.province,
      x_county                       => x_location_rec.county,
      x_address_key                  => x_location_rec.address_key,
      x_address_style                => x_location_rec.address_style,
      x_validated_flag               => x_location_rec.validated_flag,
      x_address_lines_phonetic       => x_location_rec.address_lines_phonetic,
      x_po_box_number                => x_location_rec.po_box_number,
      x_house_number                 => x_location_rec.house_number,
      x_street_suffix                => x_location_rec.street_suffix,
      x_street                       => x_location_rec.street,
      x_street_number                => x_location_rec.street_number,
      x_floor                        => x_location_rec.floor,
      x_suite                        => x_location_rec.suite,
      x_postal_plus4_code            => x_location_rec.postal_plus4_code,
      x_position                     => x_location_rec.position,
      x_location_directions          => x_location_rec.location_directions,
      x_address_effective_date       => x_location_rec.address_effective_date,
      x_address_expiration_date      => x_location_rec.address_expiration_date,
      x_clli_code                    => x_location_rec.clli_code,
      x_language                     => x_location_rec.language,
      x_short_description            => x_location_rec.short_description,
      x_description                  => x_location_rec.description,
      x_content_source_type          => x_location_rec.content_source_type,
      x_loc_hierarchy_id             => x_location_rec.loc_hierarchy_id,
      x_sales_tax_geocode            => x_location_rec.sales_tax_geocode,
      x_sales_tax_inside_city_limits => x_location_rec.sales_tax_inside_city_limits,
      x_fa_location_id               => x_location_rec.fa_location_id,
      x_geometry                     => x_location_rec.geometry,
      x_timezone_id                  => x_location_rec.timezone_id,
      x_created_by_module            => x_location_rec.created_by_module,
      x_application_id               => x_location_rec.application_id,
      x_geometry_status_code         => x_location_rec.geometry_status_code,
      x_actual_content_source        => x_location_rec.actual_content_source,
      -- Bug 2670546
      x_delivery_point_code          => x_location_rec.delivery_point_code
   );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.select_row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_location_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_location_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'get_location_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_location_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

  END get_location_rec;

/**
 * PROCEDURE fill_geometry_for_locations
 *
 * DESCRIPTION
 *     Concurrent program to fill geometry column in hz_locations.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   OUT:
 *     p_errbuf                       Error buffer.
 *     p_retcode                      Return code.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE fill_geometry_for_locations(
    p_errbuf              OUT NOCOPY VARCHAR2,
    p_retcode             OUT NOCOPY NUMBER
) IS
    l_status                  VARCHAR2(10);
    l_count                   NUMBER;
    l_loc_rec                 LOCATION_REC_TYPE;
    CURSOR c_locations IS
        SELECT COUNTRY,
               STATE,
               CITY,
               POSTAL_CODE,
               ADDRESS1,
               STREET,
               STREET_SUFFIX,
               STREET_NUMBER,
               HOUSE_NUMBER
        FROM   hz_locations
        WHERE  GEOMETRY IS NULL OR
               GEOMETRY = hz_geometry_default
        FOR UPDATE OF GEOMETRY;

BEGIN

    p_retcode := 0;
    l_count   := 0;
    FOR rec IN c_locations
    LOOP
        l_loc_rec.country := rec.country;
        l_loc_rec.state := rec.state;
        l_loc_rec.city := rec.city;
        l_loc_rec.postal_code := rec.postal_code;
        l_loc_rec.address1 := rec.address1;
        l_loc_rec.street := rec.street;
        l_loc_rec.street_suffix := rec.street_suffix;
        l_loc_rec.street_number := rec.street_number;
        l_loc_rec.house_number := rec.house_number;

        fill_geometry(l_loc_rec, l_status);

        IF (l_status = 'E') THEN
            EXIT;
        ELSIF (l_status = 'Y') THEN
            UPDATE hz_locations SET GEOMETRY = l_loc_rec.geometry
            WHERE CURRENT OF c_locations;
            l_count := l_count + 1;
        END IF;
    END LOOP;
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Records processed: ' || l_count);

EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in filling geometry column: ' || SQLERRM);

END fill_geometry_for_locations;
/*----------------------------------------------------------------------------*
 | procedure                                                                   |
 |    update_location_search                                                  |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure updates the address_text column of                       |
 |    hz_cust_acct_sites_all with the NULL value                              |
 |    only to change the address_text column status                           |
 |    so that interMedia index can be created on it to perform text searches. |
 |                                                                            |
 | NOTE :- After Calling this procedure the user has to execute the           |
 |         Customer Text Data Creation concurrent program to see the changes. |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |    p_old_location_rec                                                      |
 |    p_location_rec                                                          |
 |   OUTPUT                                                                   |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    15-Mar-2004    Ramesh Ch   Created                                       |
 *----------------------------------------------------------------------------*/

PROCEDURE update_location_search(p_old_location_rec IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
                                 p_new_location_rec IN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
                                )
IS
  Cursor c_locations(p_location_id NUMBER) IS
  SELECT ac.CUST_ACCT_SITE_ID
    FROM HZ_LOCATIONS loc, HZ_PARTY_SITES ps,
         HZ_CUST_ACCT_SITES_ALL ac
    WHERE loc.LOCATION_ID=p_location_id
    AND loc.LOCATION_ID = ps.LOCATION_ID
    AND ps.PARTY_SITE_ID=ac.PARTY_SITE_ID;
TYPE siteidtab IS TABLE OF HZ_CUST_ACCT_SITES_ALL.CUST_ACCT_SITE_ID%TYPE;
l_siteidtab siteidtab;

BEGIN
 savepoint update_location_search;
 -- Bug Fix:4006266
 IF(    isModified(p_old_location_rec.address1    ,p_new_location_rec.address1)
    OR  isModified(p_old_location_rec.address2    ,p_new_location_rec.address2)
    OR  isModified(p_old_location_rec.address3    ,p_new_location_rec.address3)
    OR  isModified(p_old_location_rec.address4    ,p_new_location_rec.address4)
    OR  isModified(p_old_location_rec.city        ,p_new_location_rec.city)
    OR  isModified(p_old_location_rec.state       ,p_new_location_rec.state)
    OR  isModified(p_old_location_rec.postal_code ,p_new_location_rec.postal_code)
    OR  isModified(p_old_location_rec.province    ,p_new_location_rec.province)
 ) THEN
   OPEN c_locations(p_old_location_rec.location_id);
   FETCH c_locations BULK COLLECT INTO l_siteidtab;
   CLOSE c_locations;
   IF l_siteidtab.COUNT >0 THEN
    FORALL i IN l_siteidtab.FIRST..l_siteidtab.LAST
      update HZ_CUST_ACCT_SITES_ALL set address_text=NULL where cust_acct_site_id=l_siteidtab(i);
   END IF;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK TO update_location_search;
   RAISE;
END;
FUNCTION isModified(p_old_value IN VARCHAR2,p_new_value IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  IF p_new_value IS NOT NULL AND p_new_value <> FND_API.G_MISS_CHAR THEN
     RETURN NVL(NOT (p_old_value=p_new_value),TRUE);
  ELSIF (p_old_value IS NOT NULL AND p_old_value <> FND_API.G_MISS_CHAR)
         AND p_new_value = FND_API.G_MISS_CHAR THEN
     RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

/**
 * PRIVATE PROCEDURE check_obsolete_columns
 *
 * DESCRIPTION
 *     Check if user is using obsolete columns.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   07-25-2005    Jianying Huang      o Created.
 *
 */

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_location_rec                IN     location_rec_type,
    p_old_location_rec            IN     location_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    -- check floor
    IF (p_create_update_flag = 'C' AND
        p_location_rec.floor IS NOT NULL AND
        p_location_rec.floor <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.floor IS NOT NULL AND
        p_location_rec.floor <> p_old_location_rec.floor)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'floor');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check house_number
    IF (p_create_update_flag = 'C' AND
        p_location_rec.house_number IS NOT NULL AND
        p_location_rec.house_number <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.house_number IS NOT NULL AND
        p_location_rec.house_number <> p_old_location_rec.house_number)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'house_number');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check po_box_number
    IF (p_create_update_flag = 'C' AND
        p_location_rec.po_box_number IS NOT NULL AND
        p_location_rec.po_box_number <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.po_box_number IS NOT NULL AND
        p_location_rec.po_box_number <> p_old_location_rec.po_box_number)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'po_box_number');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check street
    IF (p_create_update_flag = 'C' AND
        p_location_rec.street IS NOT NULL AND
        p_location_rec.street <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.street IS NOT NULL AND
        p_location_rec.street <> p_old_location_rec.street)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'street');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check street_number
    IF (p_create_update_flag = 'C' AND
        p_location_rec.street_number IS NOT NULL AND
        p_location_rec.street_number <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.street_number IS NOT NULL AND
        p_location_rec.street_number <> p_old_location_rec.street_number)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'street_number');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check street_suffix
    IF (p_create_update_flag = 'C' AND
        p_location_rec.street_suffix IS NOT NULL AND
        p_location_rec.street_suffix <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.street_suffix IS NOT NULL AND
        p_location_rec.street_suffix <> p_old_location_rec.street_suffix)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'street_suffix');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- check suite
    IF (p_create_update_flag = 'C' AND
        p_location_rec.suite IS NOT NULL AND
        p_location_rec.suite <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_location_rec.suite IS NOT NULL AND
        p_location_rec.suite <> p_old_location_rec.suite)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'suite');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END check_obsolete_columns;

END HZ_LOCATION_V2PUB;

/
