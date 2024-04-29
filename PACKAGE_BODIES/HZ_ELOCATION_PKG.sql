--------------------------------------------------------
--  DDL for Package Body HZ_ELOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ELOCATION_PKG" AS
/*$Header: ARHELOCB.pls 120.17.12010000.2 2008/11/12 01:03:40 nsinghai ship $*/

  g_sets_per_commit CONSTANT NUMBER := 5;
  g_file_debug               BOOLEAN := FALSE;
  g_cp_detail       CONSTANT VARCHAR2(1) := FND_PROFILE.VALUE('HZ_CP_DETAIL');

  --------------------------------------
  -- private procedures and functions
  --------------------------------------
  --
  -- PRIVATE PROCEDURE enable_debug
  -- DESCRIPTION
  --     Turn on debug mode.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     HZ_UTILITY_V2PUB.enable_debug
  -- MODIFICATION HISTORY
  --   01-10-2002    Herve Yu
  --------------------------------------
  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;
    IF G_DEBUG_COUNT = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
        IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' THEN
          g_file_debug := TRUE;
        END IF;
      END IF;
    END IF;
  END enable_debug;
  */

  --------------------------------------
  -- PRIVATE PROCEDURE disable_debug
  -- DESCRIPTION
  --     Turn off debug mode.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     HZ_UTILITY_V2PUB.disable_debug
  -- MODIFICATION HISTORY
  --   01-10-2002 Herve Yu
  --------------------------------------
  /*PROCEDURE disable_debug IS
  BEGIN
    IF g_debug THEN
      g_debug_count := g_debug_count - 1;
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
        g_file_debug := FALSE;
      END IF;
    END IF;
  END disable_debug;
  */

  --------------------------------------
  -- Copy the status for the upper layer
  --------------------------------------
  PROCEDURE status_handler(
    l_return_status IN VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      NULL;
    ELSIF x_return_status = 'W'
          AND l_return_status = fnd_api.g_ret_sts_success
    THEN
      NULL;
    ELSE
      x_return_status := l_return_status;
    END IF;
  END status_handler;

  PROCEDURE trace_handler (msg IN VARCHAR2) IS
    v   VARCHAR2(2000);
  BEGIN
    v := hz_geocode_pkg.remove_whitespace(msg);
    v := TRIM(v);
    IF v IS NOT NULL THEN
-- Fix perf bug 3669930, 4220460, cache profile option value into global variable
      IF g_cp_detail = 'Y' THEN
        fnd_file.put_line(fnd_file.output,v);
      END IF;
      fnd_file.put_line(fnd_file.log,v);
    END IF;
  END trace_handler;

  --------------------------------------
  -- PRIVATE PROCEDURE time_put_line
  -- DESCRIPTION
  --     Utility routine for performance testing.  Prints the argument with
  --     a timestamp.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     hz_utility_v2pub.debug
  -- MODIFICATION HISTORY
  --   01-10-2002 J. del Callar
  --------------------------------------
  /*PROCEDURE time_put_line (msg IN VARCHAR2) IS
  BEGIN
    IF g_file_debug THEN
      fnd_file.put_line(fnd_file.log,
                        TO_CHAR(SYSDATE, 'HH:MI:SS') ||
                          ': ' || SUBSTRB(msg, 1, 240));
    ELSE
      hz_utility_v2pub.debug(TO_CHAR(SYSDATE, 'HH:MI:SS') ||
                             ': ' || SUBSTRB(msg, 1, 240));
    END IF;
  END time_put_line;
  */
  PROCEDURE time_put_line (msg IN VARCHAR2) IS
  BEGIN
      fnd_file.put_line(fnd_file.log,
                        TO_CHAR(SYSDATE, 'HH:MI:SS') ||
                          ': ' || SUBSTRB(msg, 1, 240));
  END time_put_line;

  -------------------------------------------------------------
  -- Call the HZ_LOCATIONS_PKG Table handler to update location
  -------------------------------------------------------------
  PROCEDURE update_geo_location (
    p_location_id   IN        NUMBER,
    p_geo           IN        mdsys.sdo_geometry,
    p_geo_status    IN        VARCHAR2,
    x_count         IN OUT NOCOPY    NUMBER,
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2
  ) IS
    l_rowid          VARCHAR2(1000);
    l_debug_prefix   VARCHAR2(30) := '';
    CURSOR curowid IS
      SELECT rowid
      FROM   hz_locations
      WHERE  location_id = p_location_id;
  BEGIN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.update_geo_location for location_id :'||
					  TO_CHAR(p_location_id)||'(+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    OPEN curowid;
    FETCH curowid INTO l_rowid;
    IF curowid%NOTFOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('AR', 'HZ_NO_LOCATION_FOUND');
      fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
      fnd_msg_pub.add;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug(p_message=>'No Record found : Error',
	                        p_prefix=>'ERROR',
			        p_msg_level=>fnd_log.level_error);
      END IF;
    ELSE
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.update_row for location_id :' ||
					  TO_CHAR(p_location_id)||'(+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;
      hz_locations_pkg.update_row (
        x_rowid                          => l_rowid,
        x_location_id                    => p_location_id,
        x_attribute_category             => NULL,
        x_attribute1                     => NULL,
        x_attribute2                     => NULL,
        x_attribute3                     => NULL,
        x_attribute4                     => NULL,
        x_attribute5                     => NULL,
        x_attribute6                     => NULL,
        x_attribute7                     => NULL,
        x_attribute8                     => NULL,
        x_attribute9                     => NULL,
        x_attribute10                    => NULL,
        x_attribute11                    => NULL,
        x_attribute12                    => NULL,
        x_attribute13                    => NULL,
        x_attribute14                    => NULL,
        x_attribute15                    => NULL,
        x_attribute16                    => NULL,
        x_attribute17                    => NULL,
        x_attribute18                    => NULL,
        x_attribute19                    => NULL,
        x_attribute20                    => NULL,
        x_orig_system_reference          => NULL,
        x_country                        => NULL,
        x_address1                       => NULL,
        x_address2                       => NULL,
        x_address3                       => NULL,
        x_address4                       => NULL,
        x_city                           => NULL,
        x_postal_code                    => NULL,
        x_state                          => NULL,
        x_province                       => NULL,
        x_county                         => NULL,
        x_address_key                    => NULL,
        x_address_style                  => NULL,
        x_validated_flag                 => NULL,
        x_address_lines_phonetic         => NULL,
        x_po_box_number                  => NULL,
        x_house_number                   => NULL,
        x_street_suffix                  => NULL,
        x_street                         => NULL,
        x_street_number                  => NULL,
        x_floor                          => NULL,
        x_suite                          => NULL,
        x_postal_plus4_code              => NULL,
        x_position                       => NULL,
        x_location_directions            => NULL,
        x_address_effective_date         => NULL,
        x_address_expiration_date        => NULL,
        x_clli_code                      => NULL,
        x_language                       => NULL,
        x_short_description              => NULL,
        x_description                    => NULL,
        x_content_source_type            => NULL,
        x_loc_hierarchy_id               => NULL,
        x_sales_tax_geocode              => NULL,
        x_sales_tax_inside_city_limits   => NULL,
        x_fa_location_id                 => NULL,
        x_geometry                       => p_geo,
        x_geometry_status_code           => p_geo_status,
        x_object_version_number          => NULL,
        x_timezone_id                    => NULL,
        x_created_by_module              => NULL,
        x_application_id                 => NULL,
	--3326341.
	x_delivery_point_code            => NULL
	);

      x_count := x_count + 1;

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Location successfully updated for location_id :'||TO_CHAR(p_location_id),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.update_row for location_id :' ||
					   TO_CHAR(p_location_id)||'(-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

-- Fix perf bug 3669930, 4220460, cache profile option value into global variable
      IF g_cp_detail = 'Y' THEN
        fnd_message.set_name('AR','HZ_LOCATION_UPDATED');
        fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
        fnd_msg_pub.add;
      END IF;
    END IF;
    CLOSE curowid;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_locations_pkg.update_geo_location for location_id :'
					  || TO_CHAR(p_location_id)||'(-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
  END update_geo_location;

  --------------------------------------
  -- PUBLIC PROCEDURE update_geometry
  -- DESCRIPTION
  --   Synchronized geometry in hz_locations with latitude and longitude from
  --   Oracle's eLocation service.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   fnd_message
  --   fnd_msg_pub
  -- MODIFICATION HISTORY
  --   01-10-2002 H. Yu         Created.
  --   03-21-2002 J. del Callar Bug 2252141: Added call to spatial index
  --                            rebuild.
  --   10-03-2005 swbhatna	ER 4549508: Modified code to handle update of Spatial Information
  --				for Standalone Locations,ie. Locations without any Party Site information.
  --------------------------------------
  PROCEDURE update_geometry (
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_loc_type	      IN  VARCHAR2 DEFAULT 'P',
    p_site_use_type   IN  VARCHAR2 DEFAULT NULL,
    p_country         IN  VARCHAR2 DEFAULT NULL,
    p_iden_addr_only  IN  VARCHAR2 DEFAULT 'N',
    p_incremental     IN  VARCHAR2 DEFAULT 'N',
    p_all_partial     IN  VARCHAR2 DEFAULT 'ALL',
    p_nb_row_update   IN  VARCHAR2 DEFAULT 'ALL',
    p_nb_row          IN  NUMBER   DEFAULT 20,
    p_nb_try          IN  NUMBER   DEFAULT 3

  ) IS
    TYPE locationlist IS TABLE OF hz_locations.location_id%TYPE;
    TYPE addresslist  IS TABLE OF hz_locations.address1%TYPE;
    TYPE citylist     IS TABLE OF hz_locations.city%TYPE;
    TYPE pcodelist    IS TABLE OF hz_locations.postal_code%TYPE;
    TYPE statelist    IS TABLE OF hz_locations.state%TYPE;
    TYPE countrylist  IS TABLE OF hz_locations.country%TYPE;
    TYPE countylist   IS TABLE OF hz_locations.county%TYPE;
    TYPE provincelist IS TABLE OF hz_locations.province%TYPE;
    l_location_ids    locationlist;
    l_address1s       addresslist;
    l_address2s       addresslist;
    l_address3s       addresslist;
    l_address4s       addresslist;
    l_cities          citylist;
    l_postal_codes    pcodelist;
    l_states          statelist;
    l_countries       countrylist;
    l_counties        countylist;
    l_provinces       provincelist;

    -- run this query if the party site use is specified,
    -- we are NOT running in incremental mode
    -- and we are NOT running for Standalone Locations
    -- and p_country was not passed
    CURSOR cu_loc1a (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_site_uses hpsu,
                           hz_party_sites     hps
                     WHERE hpsu.site_use_type = p_site_use_type
                     AND hpsu.party_site_id = hps.party_site_id
                     AND hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2);

    -- run this query if the party site use is specified,
    -- run this query if the party site use is specified,
    -- we are NOT running in incremental mode
    -- and we are NOT running for Standalone Locations
    -- and p_country was passed
    CURSOR cu_loc1ac (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_site_uses hpsu,
                           hz_party_sites     hps
                     WHERE hpsu.site_use_type = p_site_use_type
                     AND hpsu.party_site_id = hps.party_site_id
                     AND hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND hl.country = p_country
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2);

    -- run this query if the party site use is specified,
    -- we are running in incremental mode.
    -- and we are NOT running for Standalone Locations
    -- and p_country was not passed
    CURSOR cu_loc1b (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_site_uses hpsu,
                           hz_party_sites     hps
                     WHERE hpsu.site_use_type = p_site_use_type
                     AND hpsu.party_site_id = hps.party_site_id
                     AND hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND (hl.geometry_status_code = 'DIRTY' OR hl.geometry_status_code IS NULL);

    -- run this query if the party site use is specified,
    -- we are running in incremental mode.
    -- and we are NOT running for Standalone Locations
    -- and p_country was passed
    CURSOR cu_loc1bc (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_site_uses hpsu,
                           hz_party_sites     hps
                     WHERE hpsu.site_use_type = p_site_use_type
                     AND hpsu.party_site_id = hps.party_site_id
                     AND hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND hl.country = p_country
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND (hl.geometry_status_code = 'DIRTY' OR hl.geometry_status_code IS NULL);

    -- run this query if party site use is not specified,
    -- we are NOT running in incremental mode
    -- and we are NOT running for Standalone Locations
    -- and p_country was not passed
    CURSOR cu_loc2a (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_sites hps
                     WHERE hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2);

    -- run this query if party site use is not specified,
    -- we are NOT running in incremental mode
    -- and we are NOT running for Standalone Locations
    -- and p_country was passed
    CURSOR cu_loc2ac (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_sites hps
                     WHERE hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND hl.country = p_country
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2);

    -- run this query if party site use is not specified,
    -- we are running in incremental mode
    -- and we are NOT running for Standalone Locations
    CURSOR cu_loc2b (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_sites hps
                     WHERE hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND (hl.geometry_status_code = 'DIRTY' OR hl.geometry_status_code IS NULL);

    -- run this query if party site use is not specified,
    -- we are running in incremental mode
    -- and we are NOT running for Standalone Locations
    -- and p_country was passed
    CURSOR cu_loc2bc (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  EXISTS (SELECT 1
                     FROM  hz_party_sites hps
                     WHERE hps.identifying_address_flag = DECODE(p_iden_addr_only, 'Y', 'Y', hps.identifying_address_flag)
                     AND hps.location_id = hl.location_id)
      AND hl.country = p_country
      AND NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND (hl.geometry_status_code = 'DIRTY' OR hl.geometry_status_code IS NULL);

    -- run this query if we are running for Standalone Locations
    -- and NOT in incremental mode
    -- and p_country was not passed
    CURSOR cu_loc3a (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND    NOT EXISTS (SELECT 1
                         FROM HZ_PARTY_SITES hps
                         WHERE hps.location_id = hl.location_id );

    -- run this query if we are running for Standalone Locations
    -- and NOT in incremental mode
    -- and p_country was passed
    CURSOR cu_loc3ac (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  hl.country = p_country
      AND    NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND    NOT EXISTS (SELECT 1
                         FROM HZ_PARTY_SITES hps
                         WHERE hps.location_id = hl.location_id );

    -- run this query if we are running for Standalone Locations
    -- and in incremental mode
    -- and p_country was not passed
    CURSOR cu_loc3b (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND    (hl.geometry_status_code = 'DIRTY' OR hl.geometry_status_code IS NULL)
      AND    NOT EXISTS (SELECT 1
                         FROM HZ_PARTY_SITES hps
                         WHERE hps.location_id = hl.location_id );

    -- run this query if we are running for Standalone Locations
    -- and in incremental mode
    -- and p_country was passed
    CURSOR cu_loc3bc (p_request_id IN NUMBER) IS
      SELECT hl.location_id, hl.address1, hl.address2, hl.address3, hl.address4,
             hl.city, hl.postal_code, hl.state, hl.country, hl.county, hl.province
      FROM   hz_locations hl
      WHERE  hl.country = p_country
      AND    NVL(hl.request_id, -1) <> NVL(p_request_id, -2)
      AND    (hl.geometry_status_code = 'DIRTY' OR hl.geometry_status_code IS NULL)
      AND    NOT EXISTS (SELECT 1
                         FROM HZ_PARTY_SITES hps
                         WHERE hps.location_id = hl.location_id );

    l_array           hz_geocode_pkg.loc_array := hz_geocode_pkg.loc_array();
    l_rec             hz_location_v2pub.location_rec_type;
    l_http_ad         VARCHAR2(200);
    l_proxy           VARCHAR2(100);
    l_port            VARCHAR2(10);
    l_port_num        NUMBER;
    x_return_status   VARCHAR2(10);
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(2000);
    cpt               NUMBER := 0;
    cpt_update        NUMBER := 0;
    l_nb_row_update   NUMBER DEFAULT NULL;
    l_nb_update       NUMBER;
    l_str_exe         VARCHAR2(500);
    expect_http_ad    EXCEPTION;
    exchttp           EXCEPTION;
    port_number       EXCEPTION;
    nlsnumexp         EXCEPTION;
    morethanmaxrow    EXCEPTION;
    atleastonerow     EXCEPTION;
    msg               VARCHAR2(2000);
    l_return_status   VARCHAR2(10);
    l_set_size        NUMBER;
    l_request_id      NUMBER := hz_utility_v2pub.request_id;
    i                 NUMBER;
    l_nb_retries      NUMBER := NVL(p_nb_try, 3);
    l_batch_size      NUMBER := NVL(p_nb_row, hz_geocode_pkg.g_max_rows);
    l_retcode         VARCHAR2(10);
    l_errbuf          VARCHAR2(4000);
    l_proxy_var       VARCHAR2(240);
    l_port_var        VARCHAR2(240);
    l_debug_prefix    VARCHAR2(30) := '';
  BEGIN

    --enable_debug;

    l_nb_update := 0;
    l_set_size := l_batch_size * g_sets_per_commit;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.update_geometry (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;



    x_return_status := fnd_api.g_ret_sts_success;
    l_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.initialize;

    retcode := '0';
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get_string('FND',
                                             'CONC-START PROGRAM EXECUTION'));
    fnd_file.put_line(fnd_file.log, '');

    fnd_file.put_line(fnd_file.output,
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS: '));
    fnd_file.put_line(fnd_file.output,
                      fnd_message.get_string('FND',
                                             'CONC-START PROGRAM EXECUTION'));

    IF hz_geocode_pkg.is_nls_num_char_pt_com <> 'Y' THEN
      l_str_exe := 'ALTER SESSION SET nls_numeric_characters = ''.,''';
      EXECUTE IMMEDIATE l_str_exe;
    END IF;

    IF p_all_partial  <> 'ALL' THEN
      IF p_nb_row_update IS NULL OR p_nb_row_update = 'ALL' THEN
        l_nb_row_update := 1000;
      ELSE
        l_nb_row_update := TO_NUMBER(p_nb_row_update);
      END IF;
      IF l_nb_row_update IS NULL OR l_nb_row_update <= 0 THEN
        time_put_line('At least one row error.');
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'At least one row error.',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;
        RAISE atleastonerow;
      END IF;
    END IF;

    IF l_batch_size > hz_geocode_pkg.g_max_rows THEN
      RAISE morethanmaxrow;
    END IF;

    -- Get the website we're supposed to access for geospatial information.
    fnd_profile.get('HZ_GEOCODE_WEBSITE', l_http_ad);
    IF l_http_ad IS NULL THEN
      time_put_line('HTTP address missing');
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'HTTP address missing',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      RAISE expect_http_ad;
    END IF;

    -- Only get the proxy server if we need it - check the proxy bypass list.
    IF hz_geocode_pkg.in_bypass_list(
         l_http_ad,
         fnd_profile.value('WEB_PROXY_BYPASS_DOMAINS')
       )
    THEN
      -- site is in the bypass list.
      l_proxy_var := 'Null proxy';
      l_port_var  := 'Null port';
      l_proxy     := NULL;
      l_port      := NULL;
    ELSE
      -- site is not in the bypass list.
      -- First, attempt to get proxy value from FND.  If the proxy name is not
      -- found, try the TCA values regardless of whether the port is found.
      l_proxy_var := 'WEB_PROXY_HOST';
      l_port_var  := 'WEB_PROXY_PORT';
      l_proxy     := fnd_profile.value(l_proxy_var);
      l_port      := fnd_profile.value(l_port_var);
    END IF;

    -- log the profile options that are being used to run this program.
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get_string('FND', 'PROFILES-VALUES'));
    fnd_file.put_line(fnd_file.log, 'HZ_GEOCODE_WEBSITE: ' || l_http_ad);
    fnd_file.put_line(fnd_file.log, l_proxy_var || ':   ' || l_proxy);
    fnd_file.put_line(fnd_file.log, l_port_var || ':   ' || l_port);
    fnd_file.put_line(fnd_file.log, '');

    -- repeat in the output file.
    fnd_file.put_line(fnd_file.output,
                      fnd_message.get_string('FND', 'PROFILES-VALUES'));
    fnd_file.put_line(fnd_file.output, 'HZ_GEOCODE_WEBSITE: ' || l_http_ad);
    fnd_file.put_line(fnd_file.output, l_proxy_var || ':   ' || l_proxy);
    fnd_file.put_line(fnd_file.output, l_port_var || ':   ' || l_port);
    fnd_file.put_line(fnd_file.output, '');

    -- repeat in debug output.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'HZ_GEOCODE_WEBSITE: ' || l_http_ad,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>l_proxy_var || ':   ' || l_proxy,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>l_port_var || ':   ' || l_port,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_port IS NOT NULL THEN
      -- J. del Callar: set the port number and handle non-numeric values
      BEGIN
        l_port_num := TO_NUMBER(l_port);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE port_number;
      END;
    ELSE
      l_port_num := NULL;
    END IF;

    -- J. del Callar: main transaction loop: process all records picked up
    -- by cu_loc and commit every l_set_size records.
    LOOP
      -- J. del Callar: re-open the cursor only if it has been closed by the
      -- commit statement, or if it has not been opened before.

      -- swbhatna: Added IF loop to check for p_loc_type value. If 'P', then earlier code remains intact
      IF p_loc_type = 'P' THEN

        IF p_site_use_type IS NOT NULL AND p_incremental = 'N' THEN
          -- J. del Callar: use cu_loc1a for non-null site uses
          -- and non-incremental mode.
          IF(p_country IS NULL) THEN
            IF NOT cu_loc1a%ISOPEN THEN
              OPEN cu_loc1a (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 1a with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
              END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc1a BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc1a%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
              IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
	                               p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
	                               p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          ELSE -- cu_loc1a/cu_loc1ac check p_country is null or not
            IF NOT cu_loc1ac%ISOPEN THEN
              OPEN cu_loc1ac (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 1ac with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'country=' || p_country,
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
              END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc1ac BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc1ac%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
	                               p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          END IF; -- cu_loc1a/cu_loc1ac check p_country is null or not

        ELSIF p_site_use_type IS NOT NULL AND p_incremental = 'Y' THEN
          -- J. del Callar: use cu_loc1b for non-null site uses
          -- and incremental mode.
          IF(p_country IS NULL) THEN
            IF NOT cu_loc1b%ISOPEN THEN
              OPEN cu_loc1b (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 1b with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc1b BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc1b%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
	                               p_prefix=>'WARNING',
		                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
	                               p_prefix=>'WARNING',
			               p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          ELSE -- cu_loc1b/cu_loc1bc, check if p_country is null or not
            IF NOT cu_loc1bc%ISOPEN THEN
              OPEN cu_loc1bc (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 1bc with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'country=' || p_country,
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc1bc BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc1bc%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
	                               p_prefix=>'WARNING',
		                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
	                               p_prefix=>'WARNING',
			               p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          END IF; -- cu_loc1b/cu_loc1bc, check if p_country is null or not

        ELSIF p_site_use_type IS NULL AND p_incremental = 'N' THEN
          -- J. del Callar: use cu_loc2a for null site uses
          -- and non-incremental mode.
          IF(p_country IS NULL) THEN
            IF NOT cu_loc2a%ISOPEN THEN
              OPEN cu_loc2a (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 2a with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc2a BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc2a%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          ELSE -- cu_loc2a/cu_loc2ac, check if p_country is null or not
            IF NOT cu_loc2ac%ISOPEN THEN
              OPEN cu_loc2ac (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 2ac with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'country=' || p_country,
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc2ac BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc2ac%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          END IF; -- cu_loc2a/cu_loc2ac, check if p_country is null or not

        ELSIF p_site_use_type IS NULL AND p_incremental = 'Y' THEN
          -- J. del Callar use cu_loc2b for null site uses
          -- and incremental mode.
          IF(p_country IS NULL) THEN
            IF NOT cu_loc2b%ISOPEN THEN
              OPEN cu_loc2b (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 2b with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc2b BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc2b%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
              IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          ELSE -- cu_loc2b/cu_loc2bc, check if p_country is null or not
            IF NOT cu_loc2bc%ISOPEN THEN
              OPEN cu_loc2bc (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 2bc with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'country=' || p_country,
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- J. del Callar: fetch the next set of location information.
            FETCH cu_loc2bc BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- J. del Callar: exit the loop if we've processed all records
            IF cu_loc2bc%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
              IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          END IF; -- cu_loc2b/cu_loc2bc, check if p_country is null or not
        END IF;

      -- swbhatna: If p_loc_type = 'S', then open cursor
      -- cu_loc3a or cu_loc3b depending on p_incremental value
      ELSIF p_loc_type = 'S' THEN

        IF p_incremental = 'N' THEN
          -- swbhatna: use cu_loc3a for updating standalone locations
          -- and in non-incremental mode.

          IF(p_country IS NULL) THEN
            IF NOT cu_loc3a%ISOPEN THEN
              OPEN cu_loc3a (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 3a with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'loc_type=' || NVL(p_loc_type, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- swbhatna: fetch the next set of location information.
            FETCH cu_loc3a BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- swbhatna: exit the loop if we've processed all records
            IF cu_loc3a%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          ELSE -- cu_loc3a/cu_loc3ac, check if p_country is null or not
            IF NOT cu_loc3ac%ISOPEN THEN
              OPEN cu_loc3ac (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 3ac with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'country=' || p_country,
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'loc_type=' || NVL(p_loc_type, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- swbhatna: fetch the next set of location information.
            FETCH cu_loc3ac BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- swbhatna: exit the loop if we've processed all records
            IF cu_loc3ac%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
	      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
            END IF;
          END IF; -- cu_loc3a/cu_loc3ac, check if p_country is null or not

        ELSIF p_incremental = 'Y' THEN
          -- swbhatna: use cu_loc3b for updating standalone locations
          -- and in incremental mode.

          IF(p_country IS NULL) THEN
            IF NOT cu_loc3b%ISOPEN THEN
              OPEN cu_loc3b (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 3b with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'loc_type=' || NVL(p_loc_type, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- swbhatna: fetch the next set of location information.
            FETCH cu_loc3b BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- swbhatna: exit the loop if we've processed all records
            IF cu_loc3b%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
              IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
              EXIT;
            END IF;
          ELSE -- cu_loc3b/cu_loc3bc, check if p_country is null or not
            IF NOT cu_loc3bc%ISOPEN THEN
              OPEN cu_loc3bc (l_request_id);
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Opening cursor 3bc with args:',
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'site_use_type=' || NVL(p_site_use_type,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'country=' || p_country,
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'iden_addr_only=' || NVL(p_iden_addr_only,'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'request_id=' || NVL(TO_CHAR(l_request_id), 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'incremental=' || NVL(p_incremental, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	        hz_utility_v2pub.debug(p_message=>'loc_type=' || NVL(p_loc_type, 'NULL'),
                                       p_prefix =>l_debug_prefix,
                                       p_msg_level=>fnd_log.level_statement);
	      END IF;
            END IF;

            -- swbhatna: fetch the next set of location information.
            FETCH cu_loc3bc BULK COLLECT
            INTO  l_location_ids, l_address1s, l_address2s, l_address3s, l_address4s,
                  l_cities, l_postal_codes, l_states, l_countries, l_counties, l_provinces
            LIMIT l_set_size;

            -- swbhatna: exit the loop if we've processed all records
            IF cu_loc3bc%NOTFOUND AND l_location_ids.COUNT <= 0 THEN
              time_put_line('Exiting because of NOTFOUND condition');
              time_put_line('Count=' || l_location_ids.COUNT);
              IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	        hz_utility_v2pub.debug(p_message=>'Exiting because of NOTFOUND condition',
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
	        hz_utility_v2pub.debug(p_message=>'Count=' || l_location_ids.COUNT,
                                       p_prefix=>'WARNING',
                                       p_msg_level=>fnd_log.level_exception);
              END IF;
            END IF;
          END IF; -- cu_loc3b/cu_loc3bc, check if p_country is null or not
        END IF;

      ELSE
        l_return_status := fnd_api.g_ret_sts_unexp_error;
        time_put_line('Unexpected mode encountered');
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Unexpected mode encountered',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;
      END IF;
      -- J. del Callar: exit the loop if no records were fetched the first time
      IF l_location_ids.COUNT = 0 THEN
        time_put_line('Exiting because COUNT=0');
	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Exiting because COUNT=0',
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
        END IF;
        EXIT;
      END IF;

      -- J. del Callar: exit the loop if our update limit has been exceeded.
      IF p_all_partial <> 'ALL' AND cpt_update >= l_nb_row_update THEN
        time_put_line('Exiting because partial=' || p_all_partial);
        time_put_line('cpt_update=' || cpt_update);
        time_put_line('nb_row_update=' || l_nb_row_update);
	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Exiting because partial=' || p_all_partial,
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
	   hz_utility_v2pub.debug(p_message=>'cpt_update=' || cpt_update,
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
	   hz_utility_v2pub.debug(p_message=>'nb_row_update=' || l_nb_row_update,
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
        END IF;
        EXIT;
      END IF;

      -- J. del Callar: main update loop: process up to l_set_size records.
      FOR i IN l_location_ids.first..l_location_ids.last LOOP
        cpt_update := cpt_update + 1;

        -- J. del Callar: copy the cursor values into a new location array rec
        l_array.EXTEND;
        cpt := cpt + 1;
        l_array(cpt).location_id := l_location_ids(i);
        l_array(cpt).address1    := l_address1s(i);
        l_array(cpt).address2    := l_address2s(i);
        l_array(cpt).address3    := l_address3s(i);
        l_array(cpt).address4    := l_address4s(i);
        l_array(cpt).city        := l_cities(i);
        l_array(cpt).postal_code := l_postal_codes(i);
        l_array(cpt).state       := l_states(i);
        l_array(cpt).country     := l_countries(i);
        l_array(cpt).province    := l_provinces(i);
        l_array(cpt).county      := l_counties(i);

          fnd_file.put_line(fnd_file.log,
                            'Processing location '||l_array(cpt).location_id);
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Processing location ' || l_array(cpt).location_id,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

        -- execute the synchronization routine every l_batch_size, or
        -- if we have reached the last record to be updated, or
        -- if we have exceeded our update limit.
        IF cpt >= l_batch_size
           OR i = l_location_ids.last
           OR (p_all_partial <> 'ALL' AND cpt_update >= l_nb_row_update)
        THEN
          -- Process the records in the array.
          hz_geocode_pkg.get_spatial_coords(
            p_loc_array            => l_array,
            p_name                 => NULL,
            p_http_ad              => l_http_ad,
            p_proxy                => l_proxy,
            p_port                 => l_port,
            p_retry                => l_nb_retries,
            x_return_status        => l_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data
          );

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            time_put_line('Unexpected error encountered');
	    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	           hz_utility_v2pub.debug(p_message=>'Unexpected error encountered',
	                                  p_prefix=>'ERROR',
			                  p_msg_level=>fnd_log.level_error);
	    END IF;

            -- Close the open cursor (depends on the site use type and the
            -- update mode).
		IF p_loc_type = 'P' THEN
                  IF p_site_use_type IS NOT NULL AND p_incremental = 'N' THEN
                    -- J. del Callar: use cu_loc1a for non-null site uses
                    -- and non-incremental mode.
                    IF (p_country IS NULL) THEN
                      CLOSE cu_loc1a;
                    ELSE
                      CLOSE cu_loc1ac;
                    END IF;
                  ELSIF p_site_use_type IS NOT NULL AND p_incremental = 'Y' THEN
                    -- J. del Callar: use cu_loc1b for non-null site uses
                    -- and incremental mode.
                    IF (p_country IS NULL) THEN
                      CLOSE cu_loc1b;
                    ELSE
                      CLOSE cu_loc1bc;
                    END IF;
                  ELSIF p_site_use_type IS NULL AND p_incremental = 'N' THEN
                    -- J. del Callar: use cu_loc2a for null site uses
                    -- and non-incremental mode.
                    IF (p_country IS NULL) THEN
                      CLOSE cu_loc2a;
                    ELSE
                      CLOSE cu_loc2ac;
                    END IF;
                  ELSIF p_site_use_type IS NULL AND p_incremental = 'Y' THEN
                    -- J. del Callar use cu_loc2b for null site uses
                    -- and incremental mode.
                    IF (p_country IS NULL) THEN
                      CLOSE cu_loc2b;
                    ELSE
                      CLOSE cu_loc2bc;
                    END IF;
                  END IF;
                ELSIF p_loc_type = 'S' THEN
                  IF p_incremental = 'N' THEN
                    -- swbhatna: use cu_loc3a for updating Standalone locations
                    -- and in non-incremental mode.
                    IF (p_country IS NULL) THEN
                      CLOSE cu_loc3a;
                    ELSE
                      CLOSE cu_loc3ac;
                    END IF;
                  ELSIF p_incremental = 'Y' THEN
                    -- swbhatna: use cu_loc3b for updating Standalone locations
                    -- and in incremental mode.
                    IF (p_country IS NULL) THEN
                      CLOSE cu_loc3b;
                    ELSE
                      CLOSE cu_loc3bc;
                    END IF;
                  END IF;
		END IF;

            status_handler(l_return_status, x_return_status);

            l_array.DELETE;
            RAISE exchttp;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            FOR j IN 1..fnd_msg_pub.count_msg LOOP
              msg := SUBSTRB(fnd_msg_pub.get(j, fnd_api.g_false),1,256);
              trace_handler(msg);
            END LOOP;
            -- J. del Callar: Re-initialize the stack for the next set.
            fnd_msg_pub.initialize;
            status_handler(l_return_status, x_return_status);
          END IF;

          FOR j IN 1..l_array.COUNT LOOP
            -- J. del Callar: update the geometry and status of each of the
            -- location records.
            update_geo_location(
              p_location_id   => l_array(j).location_id,
              p_geo           => l_array(j).geometry,
              p_geo_status    => l_array(j).geometry_status_code,
              x_count         => l_nb_update,
              x_return_status => l_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data
            );
          END LOOP;

          status_handler(l_return_status, x_return_status);
          l_array.DELETE;
          cpt := 0;
        END IF;

        -- J. del Callar: exit the loop if our update limit has been exceeded.
        IF p_all_partial <> 'ALL' AND cpt_update >= l_nb_row_update THEN
          time_put_line('Exiting due to update limit.');
	  IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'Exiting due to update limit.',
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);

          END IF;
          EXIT;
        END IF;
      END LOOP;

      -- J. del Callar: commit every l_set_size records, and clear all arrays.
      COMMIT;

      -- Fix bug 3612034, close cursor and then reopen it again due to
      -- snapshot too old problem
      fnd_file.put_line(fnd_file.log,'Process committed');

      IF p_loc_type = 'P' THEN
		IF p_site_use_type IS NOT NULL AND p_incremental = 'N' THEN
                  IF (p_country IS NULL) THEN
                    CLOSE cu_loc1a;
                    OPEN cu_loc1a(l_request_id);
                  ELSE
                    CLOSE cu_loc1ac;
                    OPEN cu_loc1ac(l_request_id);
                  END IF;
		ELSIF p_site_use_type IS NOT NULL AND p_incremental = 'Y' THEN
                  IF (p_country IS NULL) THEN
                    CLOSE cu_loc1b;
                    OPEN cu_loc1b(l_request_id);
                  ELSE
                    CLOSE cu_loc1bc;
                    OPEN cu_loc1bc(l_request_id);
                  END IF;
		ELSIF p_site_use_type IS NULL AND p_incremental = 'N' THEN
                  IF (p_country IS NULL) THEN
                    CLOSE cu_loc2a;
                    OPEN cu_loc2a(l_request_id);
                  ELSE
                    CLOSE cu_loc2ac;
                    OPEN cu_loc2ac(l_request_id);
                  END IF;
		ELSIF p_site_use_type IS NULL AND p_incremental = 'Y' THEN
                  IF (p_country IS NULL) THEN
                    CLOSE cu_loc2b;
                    OPEN cu_loc2b(l_request_id);
                  ELSE
                    CLOSE cu_loc2bc;
                    OPEN cu_loc2bc(l_request_id);
                  END IF;
	        END IF;
      ELSIF p_loc_type = 'S' THEN
		IF p_incremental = 'N' THEN
                  IF (p_country IS NULL) THEN
			CLOSE cu_loc3a;
			OPEN cu_loc3a(l_request_id);
                  ELSE
			CLOSE cu_loc3ac;
			OPEN cu_loc3ac(l_request_id);
                  END IF;
		ELSIF p_incremental = 'Y' THEN
                  IF (p_country IS NULL) THEN
			CLOSE cu_loc3b;
			OPEN cu_loc3b(l_request_id);
                  ELSE
			CLOSE cu_loc3bc;
			OPEN cu_loc3bc(l_request_id);
                  END IF;
		END IF;
      END IF;

      l_location_ids.DELETE;
      l_address1s.DELETE;
      l_address2s.DELETE;
      l_address3s.DELETE;
      l_address4s.DELETE;
      l_cities.DELETE;
      l_postal_codes.DELETE;
      l_counties.DELETE;
      l_states.DELETE;
      l_provinces.DELETE;
      l_countries.DELETE;
    END LOOP;

    -- J. del Callar: close the cursor if it has not been closed by the
    -- commit statement.
    IF p_loc_type = 'P' THEN
	  IF p_site_use_type IS NOT NULL AND p_incremental = 'N' THEN
	      -- J. del Callar: use cu_loc1a for non-null site uses
	      -- and non-incremental mode.
            IF(p_country IS NULL) THEN
	      IF cu_loc1a%ISOPEN THEN
		CLOSE cu_loc1a;
	      END IF;
            ELSE
	      IF cu_loc1ac%ISOPEN THEN
		CLOSE cu_loc1ac;
	      END IF;
            END IF;
	  ELSIF p_site_use_type IS NOT NULL AND p_incremental = 'Y' THEN
	      -- J. del Callar: use cu_loc1b for non-null site uses
	      -- and incremental mode.
            IF(p_country IS NULL) THEN
	      IF cu_loc1b%ISOPEN THEN
		CLOSE cu_loc1b;
	      END IF;
            ELSE
	      IF cu_loc1bc%ISOPEN THEN
		CLOSE cu_loc1bc;
	      END IF;
            END IF;
	  ELSIF p_site_use_type IS NULL AND p_incremental = 'N' THEN
	      -- J. del Callar: use cu_loc2a for null site uses
	      -- and non-incremental mode.
            IF(p_country IS NULL) THEN
	      IF cu_loc2a%ISOPEN THEN
		CLOSE cu_loc2a;
	      END IF;
            ELSE
	      IF cu_loc2ac%ISOPEN THEN
		CLOSE cu_loc2ac;
	      END IF;
            END IF;
	  ELSIF p_site_use_type IS NULL AND p_incremental = 'Y' THEN
	      -- J. del Callar use cu_loc2b for null site uses
	      -- and incremental mode.
            IF(p_country IS NULL) THEN
	      IF cu_loc2b%ISOPEN THEN
		CLOSE cu_loc2b;
	      END IF;
            ELSE
	      IF cu_loc2bc%ISOPEN THEN
		CLOSE cu_loc2bc;
	      END IF;
            END IF;
	  END IF;
    ELSIF p_loc_type = 'S' THEN
	    IF p_incremental = 'N' THEN
		-- swbhatna: use cu_loc3a for updating Standalone locations
		-- and in non-incremental mode.
              IF(p_country IS NULL) THEN
 	        IF cu_loc3a%ISOPEN THEN
		  CLOSE cu_loc3a;
	        END IF;
              ELSE
 	        IF cu_loc3ac%ISOPEN THEN
		  CLOSE cu_loc3ac;
	        END IF;
              END IF;
	    ELSIF p_incremental = 'Y' THEN
		-- swbhatna: use cu_loc3b for updating Standalone locations
		-- and in incremental mode.
              IF(p_country IS NULL) THEN
 	        IF cu_loc3b%ISOPEN THEN
		  CLOSE cu_loc3b;
	        END IF;
              ELSE
 	        IF cu_loc3bc%ISOPEN THEN
		  CLOSE cu_loc3bc;
	        END IF;
              END IF;
	    END IF;
    END IF;

    -- J. del Callar, bug 2252141: changed to always print out NOCOPY the message
    -- stack.
    FOR j IN 1..fnd_msg_pub.count_msg LOOP
      msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256)
               || fnd_global.local_chr(10);
      trace_handler(msg);
    END LOOP;
    fnd_message.clear;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      retcode := '1';
      -- J. del Callar: instruct user to look at log if warnings are found.
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');
      fnd_file.put_line(fnd_file.output, errbuf);
    END IF;

    -- J. del Callar: reflect successful program termination in output and
    -- log files.
    fnd_file.put_line(fnd_file.output,
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS: '));
    fnd_file.put_line(fnd_file.output,
                      fnd_message.get_string('FND',
                                             'CONC-CP SUCCESSFUL TERMINATION'));
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get_string('FND',
                                             'CONC-CP SUCCESSFUL TERMINATION'));

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.update_geometry (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --disable_debug;

  EXCEPTION
    WHEN expect_http_ad THEN
      fnd_message.set_name('AR','HZ_MISSING_HTTP_SITE');
      fnd_msg_pub.add;
      FOR j IN 1..fnd_msg_pub.count_msg LOOP
        msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256) ||
               fnd_global.local_chr(10);
        trace_handler(msg);
      END LOOP;
      fnd_message.clear;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name ||'.update_geometry (- expect_http_ad)',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');

    WHEN port_number THEN
      fnd_message.set_name('AR','HZ_PORT_NUMBER_EXPECTED');
      fnd_message.set_token('PORT', l_port);
      fnd_msg_pub.add;
      FOR j IN 1..fnd_msg_pub.count_msg LOOP
        msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256) ||
               fnd_global.local_chr(10);
        trace_handler(msg);
      END LOOP;
      fnd_message.clear;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name||'.update_geometry (- port_number)',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');

    WHEN nlsnumexp THEN
      fnd_message.set_name('AR','HZ_NUMERIC_CHAR_SET');
      fnd_msg_pub.add;
      FOR j IN 1..fnd_msg_pub.count_msg LOOP
        msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256) ||
               fnd_global.local_chr(10);
        trace_handler(msg);
      END LOOP;
      fnd_message.clear;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name||'.update_geometry (- nlsnumexp)',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');

    WHEN atleastonerow THEN
      fnd_message.set_name('AR','HZ_AT_LEAST_ONE_ROW');
      fnd_msg_pub.add;
      FOR j IN 1..fnd_msg_pub.count_msg LOOP
        msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256) ||
               fnd_global.local_chr(10);
        trace_handler(msg);
      END LOOP;
      fnd_message.clear;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name ||'.update_geometry (- atleastonerow)',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');

    WHEN morethanmaxrow THEN
      fnd_message.set_name('AR','HZ_MAX_BATCH_SIZE_EXCEEDED');
      fnd_message.set_token('MAX', hz_geocode_pkg.g_max_rows);
      fnd_msg_pub.add;
      FOR j IN 1..fnd_msg_pub.count_msg LOOP
        msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256) ||
               fnd_global.local_chr(10);
        trace_handler(msg);
      END LOOP;
      fnd_message.clear;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name ||'.update_geometry (- morethanmaxrow)',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');

    WHEN exchttp THEN
      FOR j IN 1..fnd_msg_pub.count_msg LOOP
        msg := SUBSTRB(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,256) ||
               fnd_global.local_chr(10);
        trace_handler(msg);
      END LOOP;
      fnd_message.clear;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name||'.update_geometry (- exchttp)',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, SQLERRM);
      msg := SQLERRM;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name||'.update_geometry (- others)',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>'msg='||SUBSTRB(msg, 1, 250),
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      --disable_debug;
      retcode := '2';
      errbuf := fnd_message.get_string('FND', 'CONC-CHECK LOG FOR DETAILS');
  END update_geometry;

  --------------------------------------
  -- PUBLIC PROCEDURE rebuild_location_index
  -- DESCRIPTION
  --   Rebuilds the spatial index on HZ_LOCATIONS.GEOMETRY.  Rebuilding the
  --   spatial index is required so that the index performs adequately and
  --   that queries can accurately extract the spatial data.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   fnd_message
  --   fnd_msg_pub
  -- ARGUMENTS
  --   IN:
  --     p_concurrent_mode              Set to 'Y' if the rebuild is running
  --                                    as its own concurrent program.  Set to
  --                                    'N' to indicate that the rebuild was
  --                                    called from another PL/SQL program.
  --   OUT:
  --     errbuf                         Standard AOL concurrent program error
  --                                    buffer.
  --     retcode                        Standard AOL concurrent program return
  --                                    code.  If the rebuild is not being run
  --                                    independently, the calling program
  --                                    should check the value of this return.
  -- MODIFICATION HISTORY
  --   03-20-2002 J. del Callar         Created.
  --   24-SEP-02  P.Suresh              Bug No : 2685781. Added code to
  --                                    recreate the spatial index.
  --   15-SEP-04  Arnold Ng             Bug No : 3872778. Put enable policy
  --                                    function at exception block.
  --   11-NOV-2008 Nishant Singhai      Bug 7262437 : changed insert statement
  --                                    from view user_sdo_geom_metadata to
  --                                    table MDSYS.SDO_GEOM_METADATA_TABLE
  --                                    in insert proper table owner for HZ_LOCATIONS
  --                                    when setup data is created from conc. program.
  --------------------------------------
  PROCEDURE rebuild_location_index (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY VARCHAR2,
    p_concurrent_mode   IN  VARCHAR2 DEFAULT 'Y'
  ) IS
    l_rebuild_string    VARCHAR2(100) := 'ALTER INDEX ' || g_index_owner ||
                                         '.' || g_index_name || ' REBUILD ' ||
                                         'PARAMETERS(''sdo_commit_interval=' ||
                                         g_commit_interval || ''')';
    CURSOR c_index (x_index_owner IN VARCHAR2) IS
           SELECT status, domidx_opstatus
           FROM   sys.all_indexes
           WHERE  index_name = 'HZ_LOCATIONS_N15' and owner = x_index_owner;
/* Fix perf bug 4956727
    CURSOR c_policies  IS
           SELECT object_owner, object_name, policy_name
           FROM   sys.all_policies
           WHERE  enable LIKE 'Y%'
           AND object_name = 'HZ_LOCATIONS';
*/
    CURSOR c_policies(l_schema VARCHAR2)  IS
           SELECT object_owner, object_name, policy_name
           FROM   sys.dba_policies
           WHERE  enable = 'YES'
           AND object_owner = l_schema
           AND object_name = 'HZ_LOCATIONS';

  TYPE t_namelist IS TABLE OF VARCHAR2(30);
  l_owners                    t_namelist;
  l_objects                   t_namelist;
  l_policies                  t_namelist;
  str                         varchar2(1000);
  l_status                    sys.all_indexes.status%type;
  l_domidx_opstatus           sys.all_indexes.DOMIDX_OPSTATUS%type;
  x_dummy                     BOOLEAN;
  x_status                    varchar2(30);
  x_ind                       varchar2(30);
  x_index_owner               varchar2(50);
  x_drop_index                varchar2(255);
  x_del_meta                  varchar2(255);
  x_ins_meta                  varchar2(2000);
  l_debug_prefix	      VARCHAR2(30) := '';

BEGIN
  --enable_debug;
  x_dummy := fnd_installation.GET_APP_INFO('AR',x_status,x_ind,x_index_owner);
  OPEN c_policies(x_index_owner);
       FETCH c_policies BULK COLLECT INTO l_owners, l_objects, l_policies;
  CLOSE c_policies;
  -- disable currently enabled policies
  FOR l_count IN 1..l_owners.COUNT LOOP
      dbms_rls.enable_policy(l_owners(l_count)  , l_objects(l_count),
                             l_policies(l_count), FALSE);
  END LOOP;
  OPEN c_index(x_index_owner);
    FETCH c_index into l_status,l_domidx_opstatus;
      IF c_index%NOTFOUND THEN  /* Index is Missing */
          -- Delete Meta Data
          -- Bug 7262437 : Changed deleting from view to directly from table
/*          x_del_meta :=  'Delete user_sdo_geom_metadata
                          Where  table_name = ''HZ_LOCATIONS''
                            And  column_name= ''GEOMETRY''';
*/
          x_del_meta :=  'Delete MDSYS.SDO_GEOM_METADATA_TABLE
                          Where  sdo_table_name = ''HZ_LOCATIONS''
                            AND  sdo_column_name= ''GEOMETRY''
	                    AND  sdo_owner      = '''||x_index_owner||'''';
          EXECUTE IMMEDIATE x_del_meta;
          -- Create Meta Data
          -- Bug 7262437 : Changed inserting directly into table insteda of view
          -- to avoid default user name (APPS) getting inserted in sdo_owner column
/*          x_ins_meta :=  'INSERT INTO user_sdo_geom_metadata (
                          table_name, column_name, diminfo, srid ) VALUES (
                         ''HZ_LOCATIONS'', ''GEOMETRY'',
                           mdsys.sdo_dim_array(
                           mdsys.sdo_dim_element(''longitude'', -180, 180, 0.00005),
                           mdsys.sdo_dim_element(''latitude'', -90, 90, 0.00005)), 8307 )';
*/
          x_ins_meta :=  'INSERT INTO MDSYS.SDO_GEOM_METADATA_TABLE (
                          sdo_owner, sdo_table_name, sdo_column_name, sdo_diminfo, sdo_srid ) VALUES ('''
						  ||x_index_owner||''', '||
                         '''HZ_LOCATIONS'', ''GEOMETRY'',
                           mdsys.sdo_dim_array(
                           mdsys.sdo_dim_element(''longitude'', -180, 180, 0.00005),
                           mdsys.sdo_dim_element(''latitude'', -90, 90, 0.00005)), 8307 )';

          EXECUTE IMMEDIATE x_ins_meta;
          -- Create Index
          Create_Index;
      ELSIF c_index%FOUND THEN
         IF l_status <> 'VALID' OR l_domidx_opstatus <> 'VALID' THEN
           /* Index Is Invalid */
            -- Drop Index
            x_drop_index := 'drop index '||x_index_owner||'.'|| 'HZ_LOCATIONS_N15 force';
            EXECUTE IMMEDIATE x_drop_index;
            -- Create Index
            Create_Index;
         ELSE   /* Index Exists and Valid */
	   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>g_pkg_name||'.rebuild_location_index (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
	   END IF;
           -- Initialize the return code only if we are running as an independent
           -- concurrent program.  We do not want to change the value of the return
           -- code if it has been initialized by the calling program.
           IF p_concurrent_mode = 'Y' THEN
              retcode := '0';
           END IF;
	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'rebuilding with:' || l_rebuild_string,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
           EXECUTE IMMEDIATE l_rebuild_string;
         END IF; /* Index Is Invalid */
      END IF;    /* Index is Missing */

       -- notify the user that the spatial index was successfully rebuilt, and of
       -- successful concurrent program termination only if we are running as a
       -- concurrent program.
       IF p_concurrent_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log,
                        fnd_message.get_string('AR', 'HZ_GEO_INDEX_REBUILT'));
          fnd_file.put_line(fnd_file.output,
                      fnd_message.get_string('AR', 'HZ_GEO_INDEX_REBUILT'));
          fnd_file.put_line(fnd_file.log,
                        fnd_message.get_string('FND', 'CONC-CP SUCCESSFUL TERMINATION'));
          fnd_file.put_line(fnd_file.output,
                        fnd_message.get_string('FND', 'CONC-CP SUCCESSFUL TERMINATION'));
      ELSE
        -- otherwise, just push the error onto the stack.
         fnd_message.set_name('AR', 'HZ_GEO_INDEX_REBUILT');
         fnd_msg_pub.add;
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.rebuild_location_index (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;
    Close c_index;
    --disable_debug;
    -- restore previous state: re-enable previously enabled policies
    FOR l_count IN 1..l_owners.COUNT LOOP
    dbms_rls.enable_policy(l_owners(l_count), l_objects(l_count),
                           l_policies(l_count), TRUE);
    END LOOP;
  -- clean up.
  l_owners.DELETE;
  l_objects.DELETE;
  l_policies.DELETE;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);

      -- log the error only if we are running as a concurrent program.
      -- otherwise, push the error onto the stack.
      IF p_concurrent_mode = 'Y' THEN
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.put_line(fnd_file.output,
                          fnd_message.get_string('FND',
                                                 'CONC-CHECK LOG FOR DETAILS'));
      ELSE
        fnd_msg_pub.add;
      END IF;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name||' Error:',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>SQLERRM,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.rebuild_location_index (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;
      -- bug fix 3872778 enable policy function
      FOR l_count IN 1..l_owners.COUNT LOOP
        dbms_rls.enable_policy(l_owners(l_count), l_objects(l_count),
                               l_policies(l_count), TRUE);
      END LOOP;
      --disable_debug;
      retcode := '2';
      errbuf := SQLERRM;
  END rebuild_location_index;

PROCEDURE Create_Index
IS
  object_exists         EXCEPTION;
  column_not_found      EXCEPTION;
  domainobj_exists      EXCEPTION;
  no_metadata_found     EXCEPTION;

  PRAGMA EXCEPTION_INIT(object_exists, -955);
  PRAGMA EXCEPTION_INIT(column_not_found, -904);
  PRAGMA EXCEPTION_INIT(domainobj_exists, -29879);
  PRAGMA EXCEPTION_INIT(no_metadata_found, -13203);

  l_exec_string VARCHAR2(1000) ;
  x_dummy              BOOLEAN;
  x_status             varchar2(30);
  x_ind                varchar2(30);
  x_index_owner        varchar2(50);
  check_tspace_exist   varchar2(100);  --Bug 3299301
  physical_tspace_name varchar2(100);  --Bug 3299301
BEGIN
x_dummy := fnd_installation.GET_APP_INFO('AR',x_status,x_ind,x_index_owner);
AD_TSPACE_UTIL.get_tablespace_name('AR','TRANSACTION_INDEXES','Y',check_tspace_exist,physical_tspace_name);
l_exec_string := 'CREATE INDEX '||x_index_owner||'.'|| 'hz_locations_n15 ON '||x_index_owner||'.'||
                 'hz_locations(geometry) INDEXTYPE IS mdsys.spatial_index parameters(''TABLESPACE='||
                 physical_tspace_name||''')';  --Bug 3299301
  -- create the index
  BEGIN
    if(check_tspace_exist = 'Y') THEN  --Bug 3299301
      EXECUTE IMMEDIATE l_exec_string;
    end if;
  EXCEPTION
    WHEN column_not_found THEN
      NULL;
    WHEN object_exists THEN
      NULL;
    WHEN domainobj_exists THEN
      NULL;
    WHEN no_metadata_found THEN
      NULL;
  END;

END Create_Index;
END hz_elocation_pkg;

/
