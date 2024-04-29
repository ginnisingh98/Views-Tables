--------------------------------------------------------
--  DDL for Package Body CSF_RESOURCE_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_RESOURCE_ADDRESS_PVT" AS
  /* $Header: CSFVADRB.pls 120.13.12010000.25 2010/04/06 08:41:47 rajukum ship $ */

  g_debug         VARCHAR2(1);
  g_debug_level   NUMBER;
  g_res_add_prof  VARCHAR2(200);

  -- Declaration of a private procedure for getting default trip location
  PROCEDURE get_default_location(p_resource_id NUMBER,
                               p_resource_type VARCHAR2,
                               x_address_rec OUT NOCOPY address_rec_type);

  g_emp_res_query CONSTANT VARCHAR2(1500) :=
    ' SELECT p.party_id
           , s.party_site_id
           , l.location_id
           , SUBSTR(l.short_description, INSTR(l.short_description, '' '', -1) + 1) address_id
           , l.address1 street
           , l.postal_code
           , l.city
           , l.state
           , l.country
           , t.territory_short_name
           , l.geometry
           , s.start_date_active
           , s.end_date_active
        FROM jtf_rs_resource_extns_vl r
           , per_people_f pf
           , hz_parties p
           , hz_party_sites s
           , hz_locations l
           , fnd_territories_vl t
       WHERE r.resource_id = :resource_id
         AND pf.person_id = r.source_id
         AND pf.party_id = p.party_id (+)
         AND p.party_id = s.party_id (+)
         AND NVL(s.status, ''A'') = ''A''
         AND s.location_id = l.location_id (+)
         AND l.country = t.territory_code(+)
       ORDER BY s.party_site_id NULLS LAST, s.last_update_date DESC';

  g_party_res_query CONSTANT VARCHAR2(1500) :=
    ' SELECT r.source_id party_id
           , s.party_site_id
           , l.location_id
           , SUBSTR(l.short_description, INSTR(l.short_description, '' '', -1) + 1) address_id
           , l.address1 street
           , l.postal_code
           , l.city
           , l.state
           , l.country
           , t.territory_short_name
           , l.geometry
           , s.start_date_active
           , s.end_date_active
        FROM jtf_rs_resource_extns_vl r
           , hz_party_sites s
           , hz_locations l
           , fnd_territories_vl t
       WHERE r.resource_id = :resource_id
         AND r.source_id = s.party_id (+)
         AND NVL(s.status, ''A'') = ''A''
         AND s.location_id = l.location_id (+)
         AND l.country = t.territory_code(+)
       ORDER BY s.party_site_id NULLS LAST, s.last_update_date DESC';

  g_other_res_query CONSTANT VARCHAR2(1000) :=
    ' SELECT p.party_id
           , s.party_site_id
           , l.location_id
           , SUBSTR(l.short_description, INSTR(l.short_description, '' '', -1) + 1) address_id
           , l.address1 street
           , l.postal_code
           , l.city
           , l.state
           , l.country
           , t.territory_short_name
           , l.geometry
           , s.start_date_active
           , s.end_date_active
        FROM hz_parties p
           , hz_party_sites s
           , hz_locations l
           , fnd_territories_vl t
       WHERE p.person_last_name  = :res_type_id_string
         AND p.person_first_name = :dep_arr_party_name
         AND s.party_id          = p.party_id
         AND l.location_id       = s.location_id
         AND l.country           = t.territory_code
       ORDER BY s.last_update_date DESC';

  g_emp_sub_inv_qry CONSTANT VARCHAR2(2000) :=
  '
    select    hp.party_id
           , hps.party_site_id
           , hzl.location_id
           , SUBSTR(hzl.short_description, INSTR(hzl.short_description, '' '',-1) + 1) address_id
           , hzl.address1 street
           , hzl.postal_code
           , hzl.city
           , hzl.state
           , hzl.country
           , t.territory_short_name
           , hzl.geometry
           , hps.start_date_active
           , hps.end_date_active
    from  hz_locations hzl,
          hz_party_sites hps,
          hz_cust_acct_sites hzacs,
          hz_cust_site_uses hzacus,
          hz_parties hp,
          hz_cust_accounts hzca,
          csp_rs_cust_relations ccr
          ,fnd_territories_vl t
    where hzl.location_id =hps.location_id
	  and   hzl.country = t.territory_code(+)
    and   hps.party_id=hp.party_id
    and   hzacs.party_site_id=hps.party_site_id
    and   hzacs.cust_acct_site_id= hzacus.cust_acct_site_id
    and   hzacus.site_use_code = ''SHIP_TO''
    and   hzacus.PRIMARY_FLAG=''Y''
    and   hp.party_id=hzca.party_id
    and   hzca.cust_account_id=ccr.customer_id
    and  ccr.resource_id=:resource_id
	ORDER BY hps.party_site_id NULLS LAST, hps.last_update_date DESC';



  PROCEDURE init_package IS
  BEGIN
    g_debug       := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
    g_debug_level := NVL(fnd_profile.value('AFLOG_LEVEL'), fnd_log.level_event);
  END init_package;

  PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
  BEGIN
    IF g_debug = 'Y' AND p_level >= g_debug_level THEN
      IF fnd_file.log > 0 THEN
        IF p_message = ' ' THEN
          fnd_file.put_line(fnd_file.log, '');
        ELSE
          fnd_file.put_line(fnd_file.log, rpad(p_module, 20) || ': ' || p_message);
        END IF;
      ELSE
        fnd_log.string(p_level, 'csf.plsql.CSF_RESOURCE_ADDRESS_PVT.' || p_module, p_message);
      END IF;
    END IF;
    --dbms_output.put_line(rpad(p_module, 20) || ': ' || p_message);
  END debug;

  /**
    * Finds out whether the passed value is a Number or not.
    */
  FUNCTION is_number(p_num_char IN VARCHAR2) RETURN BOOLEAN AS
    n NUMBER;
  BEGIN
    IF p_num_char IS NULL THEN
      RETURN FALSE;
    END IF;
    n  := to_number(p_num_char);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_number;

  /**
   * This function finds out whether the first word is a Building Number or not.
   * This is called if Address Line 2, 3 or 4 is also filled apart from Address Line 1.
   * The logic followed is exactly as given in BuildingNum.isBuildingNumber (BuildingNum.java).
   */
  FUNCTION is_address_line_valid(p_address_line IN VARCHAR2, p_country_code VARCHAR2)
    RETURN BOOLEAN IS
    l_address_line  hz_locations.address1%TYPE;
    l_first_word    hz_locations.address1%TYPE;
    l_count_words   NUMBER;
    l_sep_index     NUMBER;
  BEGIN
    l_address_line := trim(p_address_line);

    -- Trim off multiple spaces inbetween
    WHILE INSTR(l_address_line, '  ') <> 0 LOOP
      l_address_line := REPLACE(l_address_line, '  ', ' ');
    END LOOP;

    -- Count the number of words
    l_count_words := LENGTH(l_address_line) - LENGTH(REPLACE(l_address_line, ' ')) + 1;

    IF p_country_code = 'US' THEN
      IF l_count_words > 1 THEN
        l_first_word  := SUBSTR(l_address_line, 1, INSTR(l_address_line, ' ')-1);

        -- Building Number in Numeric Format
        IF is_number(l_first_word) THEN
          RETURN TRUE;
        END IF;

        IF LENGTH(l_first_word) = 1 THEN   -- One Letter word and not a number
          RETURN FALSE;
        END IF;

        -- Xnum Format
        IF is_number(SUBSTR(l_first_word, 2)) THEN
          RETURN TRUE;
        END IF;

        -- numX Format
        IF is_number(SUBSTR(l_first_word, 1, LENGTH(l_first_word) - 1)) THEN
          RETURN TRUE;
        END IF;

        -- numXnum or XnumXnum Format
        IF NOT is_number(SUBSTR(l_first_word, 1, 1)) THEN   -- XnumXnum Format
          l_first_word  := SUBSTR(l_first_word, 2); -- Becomes numXnum Format
        END IF;

        l_sep_index   := INSTR(
                           l_first_word
                         , REPLACE(TRANSLATE(l_first_word, '0123456789', '0'), '0')
                         );

        -- Since the First Character is already removed, the first character
        -- shouldnt be an alphabet Similarly last shouldnt be a character
        IF l_sep_index = 1 OR l_sep_index = LENGTH(l_first_word) THEN
          RETURN FALSE;
        END IF;

        l_first_word  :=    SUBSTR(l_first_word, 1, l_sep_index - 1)
                         || SUBSTR(l_first_word, l_sep_index + 1);

        IF is_number(l_first_word) THEN
          RETURN TRUE;
        END IF;
      END IF;
    END IF;

    RETURN FALSE;
  END is_address_line_valid;

  FUNCTION choose_address_line(
    p_address1         IN        VARCHAR2
  , p_address2         IN        VARCHAR2 DEFAULT NULL
  , p_address3         IN        VARCHAR2 DEFAULT NULL
  , p_address4         IN        VARCHAR2 DEFAULT NULL
  , p_country_code     IN        VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF NVL(p_address4, '_') <> '_' AND is_address_line_valid(p_address4, p_country_code) THEN
      RETURN p_address4;
    ELSIF NVL(p_address3, '_') <> '_' AND is_address_line_valid(p_address3, p_country_code) THEN
      RETURN p_address3;
    ELSIF NVL(p_address2, '_') <> '_' AND is_address_line_valid(p_address2, p_country_code) THEN
      RETURN p_address2;
    ELSE
      RETURN p_address1;
    END IF;
  END choose_address_line;

   PROCEDURE update_location (
      p_location_rec              IN      hz_location_v2pub.LOCATION_REC_TYPE,
      p_object_version_number     IN OUT NOCOPY  NUMBER,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER,
      x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  pragma autonomous_transaction;
  BEGIN
          hz_location_v2pub.update_location(
          p_location_rec => p_location_rec
        , p_object_version_number => p_object_version_number
        , x_return_status => x_return_status
        , x_msg_count => x_msg_count
        , x_msg_data => x_msg_data );
        commit;
  END;

  PROCEDURE resolve_address(
    p_api_version       IN        NUMBER
  , p_init_msg_list     IN        VARCHAR2
  , p_commit            IN        VARCHAR2
  , x_return_status    OUT NOCOPY VARCHAR2
  , x_msg_count        OUT NOCOPY NUMBER
  , x_msg_data         OUT NOCOPY VARCHAR2
  , p_location_id       IN        NUMBER
  , p_building_num      IN        VARCHAR2
  , p_address1          IN        VARCHAR2
  , p_address2          IN        VARCHAR2
  , p_address3          IN        VARCHAR2
  , p_address4          IN        VARCHAR2
  , p_city              IN        VARCHAR2
  , p_state             IN        VARCHAR2
  , p_postalcode        IN        VARCHAR2
  , p_county            IN        VARCHAR2
  , p_province          IN        VARCHAR2
  , p_country           IN        VARCHAR2
  , p_country_code      IN        VARCHAR2
  , p_alternate         in        varchar2
  , p_update_address    IN        VARCHAR2 DEFAULT 'F'
  , x_geometry         OUT NOCOPY mdsys.sdo_geometry
  ) IS
    l_api_name     CONSTANT VARCHAR2(50) := 'RESOLVE_ADDRESS';
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_resultarray         csf_lf_pub.csf_lf_resultarray;
    l_call_lf             BOOLEAN;
    l_roadname            hz_locations.address1%TYPE;
    l_location_ovn        NUMBER;
    l_location_rec        hz_location_v2pub.location_rec_type;
    l_road                VARCHAR2(200);

    CURSOR c_location_locking_info IS
      SELECT object_version_number
        FROM HZ_LOCATIONS
        WHERE LOCATION_ID = p_location_id;

  BEGIN
    SAVEPOINT resolve_address_pub;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug THEN
      debug('Resolving the Address corresponding to Location #' || p_location_id, l_api_name, fnd_log.level_procedure);
      debug('  --> Address1     = ' || p_address1, l_api_name, fnd_log.level_statement);
      debug('  --> City         = ' || p_city, l_api_name, fnd_log.level_statement);
      debug('  --> State        = ' || p_state, l_api_name, fnd_log.level_statement);
      debug('  --> Zip          = ' || p_postalcode, l_api_name, fnd_log.level_statement);
      debug('  --> Country      = ' || p_country, l_api_name, fnd_log.level_statement);
      debug('  --> Country Code = ' || p_country_code, l_api_name, fnd_log.level_statement);
      debug('  --> Update Addr  = ' || p_update_address, l_api_name, fnd_log.level_statement);
    END IF;

    -- Location Finder Profiles. Check whether Resolve Address needs to be called.
    IF l_debug THEN
      debug('CSF: Location Finder Installed = ' || fnd_profile.VALUE('CSF_LF_INSTALLED'), l_api_name, fnd_log.level_statement);
      debug('CSR: Create Location           = ' || fnd_profile.VALUE('CREATELOCATION'), l_api_name, fnd_log.level_statement);
    END IF;

   -- Fix for bug 9299548   . Commented below code so that LF is always called
   -- l_call_lf :=     (NVL(fnd_profile.VALUE('CSF_LF_INSTALLED'),'N') = 'Y')
   --              AND (NVL(fnd_profile.VALUE('CREATELOCATION'),'N') = 'Y');

    l_call_lf := true;

    IF l_call_lf THEN
      IF NVL(p_address4,'_') <> '_' THEN
        l_roadname := p_address4;
      ELSIF NVL(p_address3,'_') <> '_' THEN
        l_roadname := p_address3;
      ELSIF NVL(p_address2,'_') <> '_' THEN
        l_roadname := p_address2;
      ELSE
        l_roadname := p_address1;
      END IF;

    IF l_debug THEN
      debug('Before call to csf_lf_pub.csf_lf_resolveaddress ', l_api_name, fnd_log.level_statement);
    END IF;

      csf_lf_pub.csf_lf_resolveaddress(
        p_api_version                => l_api_version
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_country                    => NVL(p_country, '_')
      , p_state                      => NVL(p_state, '_')
      , p_county                     => NVL(p_county, '_')
      , p_province                   => NVL(p_province, '_')
      , p_city                       => NVL(p_city, '_')
      , p_postalcode                 => NVL(p_postalcode, '_')
      , p_roadname                   => NVL(l_roadname, '_')
      , p_buildingnum                => NVL(p_building_num, '_')
      , p_alternate                  => NVL(l_roadname, '_')
      , x_resultsarray               => l_resultarray
      );

    IF l_debug THEN
      debug('After call to csf_lf_pub.csf_lf_resolveaddress ', l_api_name, fnd_log.level_statement);
    END IF;

   IF l_resultarray IS NOT NULL THEN
        x_geometry   := l_resultarray(1).locus;
        IF(l_resultarray(1).buildingnum = '_') THEN
          l_road       := initcap(l_resultarray(1).road);
        ELSE
          l_road       := l_resultarray(1).buildingnum || ' ' || initcap(l_resultarray(1).road);
        END IF;
        IF l_debug THEN
          debug('Inside l_resultarray IS NOT NULL ', l_api_name, fnd_log.level_statement);
          debug('l_road = ' || l_road, l_api_name, fnd_log.level_statement);
        END IF;
   END IF;

   if x_return_status <> fnd_api.g_ret_sts_success then
          debug('Error: ' || x_msg_data, l_api_name, fnd_log.level_error);
          fnd_message.set_name ('CSF', 'CSF_LF_RAISED_ERROR');
          fnd_message.set_token ('LOCATION_ID',p_location_id);
   END IF;

   IF l_debug and x_geometry is not null THEN
        debug('  --> Longitude = ' || x_geometry.sdo_ordinates(1), l_api_name, fnd_log.level_statement);
        debug('  --> Latitude  = ' || x_geometry.sdo_ordinates(2), l_api_name, fnd_log.level_statement);
        debug('  --> Segment   = ' || x_geometry.sdo_ordinates(5), l_api_name, fnd_log.level_statement);
      END IF;
   ELSE
     l_roadname := p_address1;
     l_road     := p_address1;
     IF l_debug THEN
           debug('Considering the l_roadname and l_road as same as  p_address1 = ' || l_roadname, l_api_name, fnd_log.level_procedure);
     END IF;
   END IF;

  IF p_update_address = 'T' THEN
      IF p_address1 = l_roadname THEN
        l_location_rec.address1 := l_road;
         IF l_debug THEN
           debug('Considering the address1 for resolving street. Modified address1 = ' || l_location_rec.address1, l_api_name, fnd_log.level_procedure);
         END IF;
      ELSIF p_address2 = l_roadname THEN
        l_location_rec.address2 := l_road;
         IF l_debug THEN
           debug('Considering the address2 for resolving street. Modified address2 = ' || l_location_rec.address2, l_api_name, fnd_log.level_procedure);
         END IF;
      ELSIF p_address3 = l_roadname THEN
        l_location_rec.address3 := l_road;
          IF l_debug THEN
           debug('Considering the address3 for resolving street. Modified address3 = ' || l_location_rec.address3, l_api_name, fnd_log.level_procedure);
         END IF;
      ELSIF p_address4 = l_roadname THEN
        l_location_rec.address4 := l_road;
        IF l_debug THEN
           debug('Considering the address4 for resolving street. Modified address4 = ' || l_location_rec.address4, l_api_name, fnd_log.level_procedure);
         END IF;
      END IF;
     IF p_city = '_' THEN
        l_location_rec.city := '';
      ELSE
        l_location_rec.city := p_city;
      END IF;

      IF p_state = '_' THEN
        l_location_rec.state := '';
      ELSE
    l_location_rec.state := p_state;
      END IF;

      IF p_postalcode = '_' THEN
        l_location_rec.postal_code := '';
      ELSE
        l_location_rec.postal_code := p_postalcode;
      END IF;

      l_location_rec.country := p_country_code;
    END IF;

    IF x_return_status = 'S' THEN
      l_location_rec.geometry_status_code := 'GOOD';
    elsif x_return_status = 'E' then
      l_location_rec.geometry_status_code := 'ERROR';
    end if;

      l_location_rec.geometry  := x_geometry;
      l_location_rec.location_id := p_location_id;
      l_location_rec.created_by_module := null;

      OPEN c_location_locking_info;
      FETCH c_location_locking_info INTO l_location_ovn;
      CLOSE c_location_locking_info;

      -- Updating the location record (it updates both hz_parties and
      -- hz_locations)

      update_location(
        p_location_rec => l_location_rec
      , p_object_version_number => l_location_ovn
      , x_return_status => x_return_status
      , x_msg_count => x_msg_count
      , x_msg_data => x_msg_data );


      if x_return_status <> fnd_api.g_ret_sts_success then
        debug('Error: ' || x_msg_data, l_api_name, fnd_log.level_error);
        fnd_message.set_name ('CSF', 'CSF_HZ_UPD_LOC_ERROR');
        fnd_message.set_token ('LOCATION_ID', p_location_id);
      END IF;

      IF (l_resultarray IS NULL OR l_resultarray.COUNT > 1) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      if l_debug then
        debug('Message: ' || fnd_message.get, l_api_name, fnd_log.level_error);
      END IF;
      ROLLBACK TO resolve_address_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_debug THEN
        debug('Unexpected Error: ' || x_msg_data, l_api_name, fnd_log.level_unexpected);
      END IF;
      ROLLBACK TO resolve_address_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF l_debug THEN
        debug('Exception: SQLCODE = ' || SQLCODE || ' : SQLERRM = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO resolve_address_pub;
  END resolve_address;

  FUNCTION are_addresses_equal(
    p_address1 address_rec_type
  , p_address2 address_rec_type
  )
    RETURN BOOLEAN IS
    l_api_name     CONSTANT VARCHAR2(50) := 'ARE_ADDRESSES_EQUAL';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
  BEGIN
    IF l_debug THEN
      debug('Checking for the Equality of two addresses', l_api_name, fnd_log.level_procedure);
      debug('Address#1', l_api_name, fnd_log.level_statement);
      debug('  --> Street  : ' || p_address1.street, l_api_name, fnd_log.level_statement);
      debug('  --> City    : ' || p_address1.city, l_api_name, fnd_log.level_statement);
      debug('  --> State   : ' || p_address1.state, l_api_name, fnd_log.level_statement);
      debug('  --> Zip     : ' || p_address1.postal_code, l_api_name, fnd_log.level_statement);
      debug('  --> Country : ' || p_address1.country, l_api_name, fnd_log.level_statement);
      debug('  --> Terr SN : ' || p_address1.territory_short_name, l_api_name, fnd_log.level_statement);
      debug('Address#2', l_api_name, fnd_log.level_statement);
      debug('  --> Street  : ' || p_address2.street, l_api_name, fnd_log.level_statement);
      debug('  --> City    : ' || p_address2.city, l_api_name, fnd_log.level_statement);
      debug('  --> State   : ' || p_address2.state, l_api_name, fnd_log.level_statement);
      debug('  --> Zip     : ' || p_address2.postal_code, l_api_name, fnd_log.level_statement);
      debug('  --> Country : ' || p_address2.country, l_api_name, fnd_log.level_statement);
      debug('  --> Terr SN : ' || p_address2.territory_short_name, l_api_name, fnd_log.level_statement);
    END IF;

    IF NVL(UPPER(p_address1.street), '@#$') <> NVL(UPPER(p_address2.street), '@#$') THEN
      RETURN FALSE;
    END IF;

    IF NVL(p_address1.postal_code, '@#$') <> NVL(p_address2.postal_code, '@#$') THEN
      RETURN FALSE;
    END IF;

    IF NVL(UPPER(p_address1.city), '@#$') <> NVL(UPPER(p_address2.city), '@#$') THEN
      RETURN FALSE;
    END IF;

    IF NVL(UPPER(p_address1.state), '@#$') <> NVL(UPPER(p_address2.state), '@#$') THEN
      RETURN FALSE;
    END IF;

    -- Value of country might be in Full Form or Short Form
    IF (    NVL(UPPER(p_address1.country), '@#$')              <> NVL(UPPER(p_address2.country), '@#$')
        AND NVL(UPPER(p_address1.territory_short_name), '@#$') <> NVL(UPPER(p_address2.territory_short_name), '@#$')
        AND NVL(UPPER(p_address1.country), '@#$')              <> NVL(UPPER(p_address2.territory_short_name), '@#$')
        AND NVL(UPPER(p_address1.territory_short_name), '@#$') <> NVL(UPPER(p_address2.country), '@#$') )
    THEN
      RETURN FALSE;
    END IF;

    IF l_debug THEN
      debug('Addresses are equal', l_api_name, fnd_log.level_statement);
    END IF;
    RETURN TRUE;
  END are_addresses_equal;

  /**
    * Get the Party Site Addresses for the Parties created for the Resource.
    */
  PROCEDURE get_party_addresses(
    p_resource_id      IN         NUMBER
  , p_resource_type    IN         VARCHAR2
  , p_date             IN         DATE
  , x_address_tbl     OUT NOCOPY  address_tbl_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(50) := 'GET_PARTY_ADDRESSES';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    TYPE ref_cursor_type IS REF CURSOR;
    c_parties       ref_cursor_type;
    l_address_rec   address_rec_type;
  BEGIN
    IF l_debug THEN
      debug('Finding the Parties associated with Resource ID = ' || p_resource_id, l_api_name, fnd_log.level_procedure);
    END IF;

    x_address_tbl := address_tbl_type();
    IF g_res_add_prof is null
    THEN
      g_res_add_prof := 'RS_HRMS_ADD';
    END IF;
    -- Find out whether we can use the Parties already created by the Source Module
    IF p_resource_type IN ('RS_EMPLOYEE', 'RS_PARTY','RS_SUPPLIER_CONTACT') THEN
      IF p_resource_type = 'RS_EMPLOYEE' and g_res_add_prof = 'RS_HRMS_ADD' THEN
        OPEN c_parties FOR g_emp_res_query USING p_resource_id;
      ELSIF p_resource_type = 'RS_PARTY' and g_res_add_prof = 'RS_HRMS_ADD' THEN
        OPEN c_parties FOR g_party_res_query USING p_resource_id;
	   --  following code was added for 6962522
      ELSIF  p_resource_type IN( 'RS_EMPLOYEE', 'RS_SUPPLIER_CONTACT', 'RS_PARTY') and g_res_add_prof = 'RS_SUBINV_ADD' THEN
        OPEN c_parties FOR g_emp_sub_inv_qry USING p_resource_id;
      END IF;

      IF c_parties%ISOPEN
      then
          LOOP
            FETCH c_parties INTO l_address_rec;
            EXIT WHEN c_parties%NOTFOUND;
            x_address_tbl.extend();
            x_address_tbl(c_parties%ROWCOUNT) := l_address_rec;
          END LOOP;
          CLOSE c_parties;
      END IF;
      IF l_debug THEN
        debug('  Number of Parties found = ' || x_address_tbl.COUNT, l_api_name, fnd_log.level_statement);
      END IF;

    END IF;

     IF x_address_tbl.COUNT > 0 THEN
      RETURN;
     END IF;

    -- No Parties created by the Source Module were fetched.
    -- Search for Parties created by this Module.

    OPEN c_parties FOR g_other_res_query USING (p_resource_type || ' ' || p_resource_id), g_st_party_fname;
    LOOP
      FETCH c_parties INTO l_address_rec;
      EXIT WHEN c_parties%NOTFOUND;
      x_address_tbl.extend();
      x_address_tbl(c_parties%ROWCOUNT) := l_address_rec;
    END LOOP;
    CLOSE c_parties;

    IF l_debug THEN
      debug('  Number of Parties found upon retrying = ' || x_address_tbl.COUNT, l_api_name, fnd_log.level_statement);
    END IF;

  END get_party_addresses;

  /**
    * Get the Home Addresses of the Resource as defined in HRMS People
    * Management form.
    */
  PROCEDURE get_home_addresses(
    p_resource_id    IN         NUMBER
  , p_resource_type  IN         VARCHAR2
  , p_date           IN         DATE
  , x_address       OUT NOCOPY  address_rec_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(50) := 'GET_HOME_ADDRESSES';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    CURSOR c_home_addresses(b_resource_id NUMBER, b_date DATE) IS
      SELECT a.address_id
           , a.address_line1 street
           , a.postal_code
           , a.town_or_city city
           , a.region_2 state
           , a.country
           , t.territory_short_name
           , a.date_from start_date_active
           , a.date_to end_date_active
        FROM per_addresses a
           , jtf_rs_resource_extns r
           , fnd_territories_vl t
       WHERE r.resource_id = b_resource_id
         AND a.person_id = r.source_id
         AND a.country = t.territory_code
         AND TRUNC(a.date_from) <= TRUNC(b_date)
         AND TRUNC(NVL(a.date_to, b_date + 1)) >= TRUNC(b_date)
       ORDER BY a.primary_flag DESC, a.date_from DESC;

    l_home_address c_home_addresses%ROWTYPE;
  BEGIN
    IF l_debug THEN
      debug('Finding the addresses associated with Resource ID = ' || p_resource_id, l_api_name, fnd_log.level_procedure);
    END IF;

    OPEN c_home_addresses (p_resource_id, p_date);
    FETCH c_home_addresses INTO l_home_address;
    CLOSE c_home_addresses;

    x_address.address_id           := l_home_address.address_id;
    x_address.street               := l_home_address.street;
    x_address.postal_code          := l_home_address.postal_code;
    x_address.city                 := l_home_address.city;
    x_address.state                := l_home_address.state;
    x_address.country              := l_home_address.country;
    x_address.territory_short_name := l_home_address.territory_short_name;
    x_address.start_date_active    := l_home_address.start_date_active;
    x_address.end_date_active      := l_home_address.end_date_active;


    IF l_debug THEN
      IF x_address.address_id IS NOT NULL THEN
        debug('  Found a Address: Address ID = ' || x_address.address_id, l_api_name, fnd_log.level_statement);
      ELSE
        debug('  Found no Home Address', l_api_name, fnd_log.level_statement);
      END IF;
    END IF;
  END get_home_addresses;

  PROCEDURE match_home_to_party(
    p_home_addr_rec        IN        address_rec_type
  , p_party_addr_tbl       IN        address_tbl_type
  , x_matched_address_rec OUT NOCOPY address_rec_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(50) := 'MATCH_HOME_TO_PARTY';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
  BEGIN
    x_matched_address_rec := p_home_addr_rec;

    IF p_party_addr_tbl IS NULL OR p_party_addr_tbl.COUNT = 0 THEN
      RETURN;
    END IF;

    -- If no Parties match exactly, atleast we can make use of the existing Party ID.
    x_matched_address_rec.party_id := p_party_addr_tbl(1).party_id;

    FOR i IN 1..p_party_addr_tbl.COUNT LOOP
      IF p_home_addr_rec.address_id = p_party_addr_tbl(i).address_id THEN
        x_matched_address_rec := p_party_addr_tbl(i);

        x_matched_address_rec.start_date_active := p_home_addr_rec.start_date_active;
        x_matched_address_rec.end_date_active   := p_home_addr_rec.end_date_active;
        EXIT;
      END IF;
    END LOOP;

    IF l_debug THEN
      IF x_matched_address_rec.party_site_id IS NULL THEN
        debug('Best Address ID (#' || p_home_addr_rec.address_id || ') doesnt match with any Party Site', l_api_name, fnd_log.level_statement);
      ELSE
        debug('Best Address ID (#' || p_home_addr_rec.address_id || ') matches with Party Site ID = ' || x_matched_address_rec.party_site_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;
  END match_home_to_party;

  PROCEDURE create_resource_party_link(
    p_api_version       IN             NUMBER
  , p_init_msg_list     IN             VARCHAR2
  , p_commit            IN             VARCHAR2
  , x_return_status    OUT     NOCOPY  VARCHAR2
  , x_msg_count        OUT     NOCOPY  NUMBER
  , x_msg_data         OUT     NOCOPY  VARCHAR2
  , p_resource_id                      NUMBER
  , p_resource_type                    VARCHAR2
  , p_address           IN OUT NOCOPY  address_rec_type
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(50) := 'CREATE_RESOURCE_PARTY_LINK';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_location_rec       hz_location_v2pub.location_rec_type;
    l_person_rec         hz_party_v2pub.person_rec_type;
    l_party_site_rec     hz_party_site_v2pub.party_site_rec_type;

    l_profile_id          NUMBER;
    l_party_number        VARCHAR2(30);
    l_party_site_number   VARCHAR2(30);

    -- Get an arbitrary country (territory) code
    CURSOR c_terr IS
      SELECT territory_code FROM fnd_territories WHERE ROWNUM = 1;
  BEGIN
    IF l_debug THEN
      debug('Creating the Resource Party Link for Resource ID = ' || p_resource_id, l_api_name, fnd_log.level_procedure);
    END IF;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

  --  SAVEPOINT create_party;

    -- Street and Country are NOT NULL columns in HZ_LOCATIONS
    IF p_address.country IS NULL THEN
      l_location_rec.address1 := '_';
      OPEN c_terr;
      FETCH c_terr INTO l_location_rec.country;
      IF c_terr%NOTFOUND THEN
        RAISE no_data_found;
      END IF;
      CLOSE c_terr;
    ELSE
      l_location_rec.short_description := p_resource_type || ' ' || p_resource_id || ' ' || p_address.address_id;
      l_location_rec.address1          := NVL(p_address.street, '_');
      l_location_rec.city              := p_address.city;
      l_location_rec.state             := p_address.state;
      l_location_rec.postal_code       := p_address.postal_code;
      l_location_rec.country           := p_address.country;
   --   l_location_rec.county           := p_address.county;
   --   l_location_rec.province           := p_address.province;
    END IF;

    IF l_debug THEN
      debug('Creating Location Record in HZ_LOCATIONS', l_api_name, fnd_log.level_statement);
      debug('  --> Address1 = ' || l_location_rec.address1, l_api_name, fnd_log.level_statement);
      debug('  --> City     = ' || l_location_rec.city, l_api_name, fnd_log.level_statement);
      debug('  --> State    = ' || l_location_rec.state, l_api_name, fnd_log.level_statement);
      debug('  --> Zip      = ' || l_location_rec.postal_code, l_api_name, fnd_log.level_statement);
      debug('  --> Country  = ' || l_location_rec.country, l_api_name, fnd_log.level_statement);
    END IF;

    l_location_rec.created_by_module := 'CSFDEAR'; -- Calling Module 'CSF: Departure Arrival'

    hz_location_v2pub.create_location(
      p_init_msg_list              => fnd_api.g_false
    , p_location_rec               => l_location_rec
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_location_id                => p_address.location_id
    );
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('HZ_LOCATION_V2PUB.CREATE returned error: Error = ' || fnd_msg_pub.get(fnd_msg_pub.g_last), l_api_name, fnd_log.level_error);
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF l_debug THEN
        debug('HZ_LOCATION_V2PUB.CREATE was successful. Location ID = ' || p_address.location_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    IF p_address.party_id IS NULL THEN
      l_person_rec.person_first_name := g_st_party_fname;
      l_person_rec.person_last_name  := p_resource_type || ' ' || p_resource_id;
      l_person_rec.created_by_module := 'CSFDEAR'; -- Calling Module 'CSF: Departure Arrival'


      -- If the profile "Generate Party Number" is No, then
      -- TCA expects the caller to pass the party number.
      IF fnd_profile.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
        SELECT hz_party_number_s.NEXTVAL INTO l_person_rec.party_rec.party_number
          FROM dual;
      END IF;

      IF l_debug THEN
        debug('Creating Party Record in HZ_PARTIES', l_api_name, fnd_log.level_statement);
        debug('  --> Party Number = ' || l_person_rec.party_rec.party_number, l_api_name, fnd_log.level_statement);
        debug('  --> First Name   = ' || l_person_rec.person_first_name, l_api_name, fnd_log.level_statement);
        debug('  --> Last Name    = ' || l_person_rec.person_last_name, l_api_name, fnd_log.level_statement);
      END IF;

      hz_party_v2pub.create_person(
        p_init_msg_list              => fnd_api.g_false
      , p_person_rec                 => l_person_rec
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_party_id                   => p_address.party_id
      , x_party_number               => l_party_number
      , x_profile_id                 => l_profile_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
          debug('HZ_PARTY_V2PUB.CREATE returned error: Error = ' || fnd_msg_pub.get(fnd_msg_pub.g_last), l_api_name, fnd_log.level_error);
        END IF;
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      ELSE
        IF l_debug THEN
          debug('HZ_PARTY_V2PUB.CREATE_P was successful: Party ID = ' || p_address.party_id, l_api_name, fnd_log.level_statement);
        END IF;
      END IF;
    ELSE
      IF l_debug THEN
        debug('Party already exists. Using it. Party ID = ' || p_address.party_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    l_party_site_rec.location_id       := p_address.location_id;
    l_party_site_rec.party_id          := p_address.party_id;
    l_party_site_rec.created_by_module := 'CSFDEAR'; -- Calling Module 'CSF: Departure Arrival'

    -- If the profile "Generate Party Number" is No, then
    -- TCA expects the caller to pass the party number.
    IF fnd_profile.VALUE('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN
      SELECT hz_party_site_number_s.NEXTVAL INTO l_party_site_rec.party_site_number
        FROM dual;
    END IF;

    IF l_debug THEN
      debug('Creating Party Site Record in HZ_PARTY_SITES', l_api_name, fnd_log.level_statement);
      debug('  --> Party Site Number = ' || l_party_site_rec.party_site_number, l_api_name, fnd_log.level_statement);
      debug('  --> Party ID          = ' || l_party_site_rec.party_id, l_api_name, fnd_log.level_statement);
      debug('  --> Location ID       = ' || l_party_site_rec.location_id, l_api_name, fnd_log.level_statement);
    END IF;

    hz_party_site_v2pub.create_party_site(
      p_init_msg_list              => fnd_api.g_false
    , p_party_site_rec             => l_party_site_rec
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_party_site_id              => p_address.party_site_id
    , x_party_site_number          => l_party_site_number
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('HZ_PARTY_SITE_V2PUB.CREATE returned error: Error = ' || fnd_msg_pub.get(fnd_msg_pub.g_last), l_api_name, fnd_log.level_error);
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF l_debug THEN
        debug('HZ_PARTY_SITE_V2PUB.CREATE_PS was successful. Party Site ID = ' || p_address.party_site_id, l_api_name, fnd_log.level_error);
      END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('Expected Error: ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;

    --  ROLLBACK TO create_party;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('Unexpected Error: ' || x_msg_data, l_api_name, fnd_log.level_unexpected);
      END IF;

    --  ROLLBACK TO create_party;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      IF l_debug THEN
        debug('Exception: SQLCODE = ' || SQLCODE || ' : SQLERRM = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      END IF;

    --  ROLLBACK TO create_party;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_resource_party_link;

  PROCEDURE get_resource_address(
    p_api_version         IN           NUMBER
  , p_init_msg_list       IN           VARCHAR2
  , p_commit              IN           VARCHAR2
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_resource_id         IN           NUMBER
  , p_resource_type       IN           VARCHAR2
  , p_res_shift_add       IN           VARCHAR2 DEFAULT NULL
  , p_date                IN           DATE
  , x_address_rec        OUT NOCOPY    address_rec_type
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(50) := 'GET_RESOURCE_PARTY_INFO';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_home_address               address_rec_type;
    l_party_addresses_tbl        address_tbl_type;
    l_validate_address           BOOLEAN;
    l_change_address             VARCHAR2(1);


  BEGIN

    IF l_debug THEN
      debug(   'Getting the Party Information for Resource ID = '
            || p_resource_id || '( ' || p_resource_type || ') on ' || p_date
            , l_api_name, fnd_log.level_procedure);
    END IF;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

   -- SAVEPOINT resource_party_info;

    G_RES_ADD_PROF := p_res_shift_add;



  	IF g_res_add_prof is null OR g_res_add_prof = 'RS_DEFAULT_TRIP'
  	THEN

    	get_default_location( p_resource_id     => p_resource_id
                          , p_resource_type   => p_resource_type
                          , x_address_rec      => x_address_rec);
    END IF;

    -- Get the Resource Home address as stored in HRMS for the Resource.
    IF x_address_rec.street is null
    THEN
      IF p_resource_type = 'RS_EMPLOYEE' and ( g_res_add_prof in ('RS_HRMS_ADD','RS_DEFAULT_TRIP')
                                               OR g_res_add_prof is null)
       THEN

        get_home_addresses(
          p_resource_id     => p_resource_id
        , p_resource_type   => p_resource_type
        , p_date            => p_date
        , x_address         => l_home_address
        );
        IF l_home_address.address_id is null
        then
          get_default_location( p_resource_id     => p_resource_id
                          , p_resource_type   => p_resource_type
                          , x_address_rec      => x_address_rec);
        ELSE
          g_res_add_prof := 'RS_HRMS_ADD';
        END IF;
      END IF;
    END IF;
    -- Get the Party Site Address corresponding to the Resource if there is no default trip location.
    IF x_address_rec.street is  null and l_home_address.address_id is null
    THEN

          get_party_addresses(
            p_resource_id     => p_resource_id
          , p_resource_type   => p_resource_type
          , p_date            => p_date
          , x_address_tbl     => l_party_addresses_tbl
          );
    END IF;
    -- The Resource has home addresses defined.
    IF l_home_address.address_id IS NOT NULL THEN
      -- Fetch the Party corresponding to the first Home Address.
       get_party_addresses(
            p_resource_id     => p_resource_id
          , p_resource_type   => p_resource_type
          , p_date            => p_date
          , x_address_tbl     => l_party_addresses_tbl
          );
      match_home_to_party(
        p_home_addr_rec       => l_home_address
      , p_party_addr_tbl      => l_party_addresses_tbl
      , x_matched_address_rec => x_address_rec
      );

    ELSIF l_party_addresses_tbl IS NOT NULL AND l_party_addresses_tbl.COUNT > 0 THEN
      IF l_debug THEN
        debug('No Home Address found. But found a Party. Using it', l_api_name, fnd_log.level_statement);
      END IF;

      -- There is no home address. Pick the first Party Fetched.
      x_address_rec := l_party_addresses_tbl(1);
    END IF;

    -- If there is no Location created for the Address, create it.
    IF x_address_rec.location_id IS NULL THEN
      IF l_debug THEN
        debug('Since Location is not created.... Creating it', l_api_name, fnd_log.level_statement);
      END IF;

      create_resource_party_link(
        p_api_version      => l_api_version
      , p_init_msg_list    => fnd_api.g_false
      , p_commit           => fnd_api.g_false
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      , p_resource_id      => p_resource_id
      , p_resource_type    => p_resource_type
      , p_address          => x_address_rec
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      l_validate_address := TRUE;
    ELSIF l_home_address.address_id IS NOT NULL AND NOT are_addresses_equal(l_home_address, x_address_rec) THEN
      IF l_debug THEN
        debug('Location is already created.... Needs Updation', l_api_name, fnd_log.level_statement);
      END IF;
      l_change_address   := fnd_api.g_true;
      l_validate_address := TRUE;

      x_address_rec.street               := l_home_address.street;
      x_address_rec.city                 := l_home_address.city;
      x_address_rec.state                := l_home_address.state;
      x_address_rec.postal_code          := l_home_address.postal_code;
      x_address_rec.territory_short_name := l_home_address.territory_short_name;
      x_address_rec.country              := l_home_address.country;
    ELSIF x_address_rec.geometry IS NULL THEN
      IF l_debug THEN
        debug('Location is already created.... Needs Geocoding', l_api_name, fnd_log.level_statement);
      END IF;
      l_validate_address := TRUE;
    END IF;

    -- Resolve the address if its a new Resource or Address has changed.
    -- Right now only Employee Resource / Party Resource can have an Address. So Resolving only for them.
    IF l_validate_address AND p_resource_type IN ('RS_EMPLOYEE', 'RS_PARTY') THEN
      IF l_debug THEN
        debug('Resolving the Address again', l_api_name, fnd_log.level_statement);
      END IF;
      resolve_address(
        p_api_version     => l_api_version
      , x_return_status   => x_return_status
      , x_msg_count       => x_msg_count
      , x_msg_data        => x_msg_data
      , p_location_id     => x_address_rec.location_id
      , p_address1        => x_address_rec.street
      , p_city            => x_address_rec.city
      , p_state           => x_address_rec.state
      , p_postalcode      => x_address_rec.postal_code
      , p_country         => x_address_rec.territory_short_name
      , p_country_code    => x_address_rec.country
      , p_update_address  => l_change_address
      , x_geometry        => x_address_rec.geometry
      );

      -- Dont error out . Scheduler will handle it appro.
      x_return_status := fnd_api.g_ret_sts_success;
    END IF;

    IF l_debug THEN
      debug('Returning Resource Party Info', l_api_name, fnd_log.level_statement);
      debug('  --> Party Site ID = ' || x_address_rec.party_site_id, l_api_name, fnd_log.level_statement);
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('Expected Error: ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;

    --  ROLLBACK TO resource_party_info;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('Unexpected Error: ' || x_msg_data, l_api_name, fnd_log.level_unexpected);
      END IF;

    --  ROLLBACK TO resource_party_info;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      IF l_debug THEN
        debug('Exception: SQLCODE = ' || SQLCODE || ' : SQLERRM = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      END IF;

    --  ROLLBACK TO resource_party_info;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END get_resource_address;

  PROCEDURE get_resource_party_info(
    p_api_version         IN          NUMBER
  , p_init_msg_list       IN          VARCHAR2 DEFAULT NULL
  , p_commit              IN          VARCHAR2 DEFAULT NULL
  , x_return_status      OUT  NOCOPY  VARCHAR2
  , x_msg_count          OUT  NOCOPY  NUMBER
  , x_msg_data           OUT  NOCOPY  VARCHAR2
  , p_resource_id         IN          NUMBER
  , p_resource_type       IN          VARCHAR2
  , p_date                IN          DATE
  , x_party_id           OUT  NOCOPY  NUMBER
  , x_party_site_id      OUT  NOCOPY  NUMBER
  , x_location_id        OUT  NOCOPY  NUMBER
  ) IS
    l_address address_rec_type;
  BEGIN
    get_resource_address(
      p_api_version        => p_api_version
    , p_init_msg_list      => p_init_msg_list
    , p_commit             => p_commit
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_resource_id        => p_resource_id
    , p_resource_type      => p_resource_type
    , p_date               => p_date
    , x_address_rec        => l_address
    );

    IF x_return_status = fnd_api.g_ret_sts_success THEN
      x_party_id      := l_address.party_id;
      x_party_site_id := l_address.party_site_id;
      x_location_id   := l_address.location_id;
    END IF;
  END get_resource_party_info;



 PROCEDURE create_one_time_address(
    p_api_version       IN             NUMBER
  , p_init_msg_list     IN             VARCHAR2
  , p_commit            IN             VARCHAR2
  , x_return_status    OUT     NOCOPY  VARCHAR2
  , x_msg_count        OUT     NOCOPY  NUMBER
  , x_msg_data         OUT     NOCOPY  VARCHAR2
  , p_resource_id                      NUMBER
  , p_resource_type                    VARCHAR2
  , p_address           IN OUT NOCOPY  address_rec_type1
  ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(50) := 'CREATE_RESOURCE_PARTY_LINK';
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';

    l_location_rec       hz_location_v2pub.location_rec_type;
    l_person_rec         hz_party_v2pub.person_rec_type;
    l_party_site_rec     hz_party_site_v2pub.party_site_rec_type;

    l_profile_id          NUMBER;
    l_party_number        VARCHAR2(30);
    l_party_site_number   VARCHAR2(30);

    -- Get an arbitrary country (territory) code
    CURSOR c_terr IS
      SELECT territory_code FROM fnd_territories WHERE ROWNUM = 1;


  BEGIN
    IF l_debug THEN
      debug('Creating the Resource Party Link for Resource ID = ' || p_resource_id, l_api_name, fnd_log.level_procedure);
    END IF;


    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT create_party;

    -- Street and Country are NOT NULL columns in HZ_LOCATIONS
    IF p_address.country IS NULL THEN
      l_location_rec.address1 := '_';
      OPEN c_terr;
      FETCH c_terr INTO l_location_rec.country;
      IF c_terr%NOTFOUND THEN
        RAISE no_data_found;
      END IF;
      CLOSE c_terr;

    ELSE

      l_location_rec.short_description := p_resource_type || ' ' || p_resource_id || ' ' || p_address.address_id;

      l_location_rec.address1          := NVL(p_address.street, '_');

      l_location_rec.city              := p_address.city;

      l_location_rec.state             := p_address.state;

      l_location_rec.postal_code       := p_address.postal_code;

      l_location_rec.country           := p_address.country;

      l_location_rec.county           := p_address.county;

      l_location_rec.province           := p_address.province;

    END IF;

    IF l_debug THEN
      debug('Creating Location Record in HZ_LOCATIONS', l_api_name, fnd_log.level_statement);
      debug('  --> Address1 = ' || l_location_rec.address1, l_api_name, fnd_log.level_statement);
      debug('  --> City     = ' || l_location_rec.city, l_api_name, fnd_log.level_statement);
      debug('  --> State    = ' || l_location_rec.state, l_api_name, fnd_log.level_statement);
      debug('  --> Zip      = ' || l_location_rec.postal_code, l_api_name, fnd_log.level_statement);
      debug('  --> Country  = ' || l_location_rec.country, l_api_name, fnd_log.level_statement);
    END IF;

    l_location_rec.created_by_module := 'CSFDEAR'; -- Calling Module 'CSF: Departure Arrival'

    hz_location_v2pub.create_location(
      p_init_msg_list              => fnd_api.g_false
    , p_location_rec               => l_location_rec
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_location_id                => p_address.location_id
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('HZ_LOCATION_V2PUB.CREATE returned error: Error = ' || fnd_msg_pub.get(fnd_msg_pub.g_last), l_api_name, fnd_log.level_error);
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF l_debug THEN
        debug('HZ_LOCATION_V2PUB.CREATE was successful. Location ID = ' || p_address.location_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    IF p_address.party_id IS NULL THEN
      l_person_rec.person_first_name := g_st_party_fname;
      l_person_rec.person_last_name  := p_resource_type || ' ' || p_resource_id;
      l_person_rec.created_by_module := 'CSFDEAR'; -- Calling Module 'CSF: Departure Arrival'


      -- If the profile "Generate Party Number" is No, then
      -- TCA expects the caller to pass the party number.
      IF fnd_profile.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
        SELECT hz_party_number_s.NEXTVAL INTO l_person_rec.party_rec.party_number
          FROM dual;
      END IF;

      IF l_debug THEN
        debug('Creating Party Record in HZ_PARTIES', l_api_name, fnd_log.level_statement);
        debug('  --> Party Number = ' || l_person_rec.party_rec.party_number, l_api_name, fnd_log.level_statement);
        debug('  --> First Name   = ' || l_person_rec.person_first_name, l_api_name, fnd_log.level_statement);
        debug('  --> Last Name    = ' || l_person_rec.person_last_name, l_api_name, fnd_log.level_statement);
      END IF;

      hz_party_v2pub.create_person(
        p_init_msg_list              => fnd_api.g_false
      , p_person_rec                 => l_person_rec
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_party_id                   => p_address.party_id
      , x_party_number               => l_party_number
      , x_profile_id                 => l_profile_id
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug THEN
          fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
          debug('HZ_PARTY_V2PUB.CREATE returned error: Error = ' || fnd_msg_pub.get(fnd_msg_pub.g_last), l_api_name, fnd_log.level_error);
        END IF;
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        RAISE fnd_api.g_exc_error;
      ELSE
        IF l_debug THEN
          debug('HZ_PARTY_V2PUB.CREATE_P was successful: Party ID = ' || p_address.party_id, l_api_name, fnd_log.level_statement);
        END IF;
      END IF;
    ELSE
      IF l_debug THEN
        debug('Party already exists. Using it. Party ID = ' || p_address.party_id, l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    l_party_site_rec.location_id       := p_address.location_id;
    l_party_site_rec.party_id          := p_address.party_id;
    l_party_site_rec.created_by_module := 'CSFDEAR'; -- Calling Module 'CSF: Departure Arrival'

    -- If the profile "Generate Party Number" is No, then
    -- TCA expects the caller to pass the party number.
    IF fnd_profile.VALUE('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN
      SELECT hz_party_site_number_s.NEXTVAL INTO l_party_site_rec.party_site_number
        FROM dual;
    END IF;

    IF l_debug THEN
      debug('Creating Party Site Record in HZ_PARTY_SITES', l_api_name, fnd_log.level_statement);
      debug('  --> Party Site Number = ' || l_party_site_rec.party_site_number, l_api_name, fnd_log.level_statement);
      debug('  --> Party ID          = ' || l_party_site_rec.party_id, l_api_name, fnd_log.level_statement);
      debug('  --> Location ID       = ' || l_party_site_rec.location_id, l_api_name, fnd_log.level_statement);
    END IF;

    hz_party_site_v2pub.create_party_site(
      p_init_msg_list              => fnd_api.g_false
    , p_party_site_rec             => l_party_site_rec
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_party_site_id              => p_address.party_site_id
    , x_party_site_number          => l_party_site_number
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('HZ_PARTY_SITE_V2PUB.CREATE returned error: Error = ' || fnd_msg_pub.get(fnd_msg_pub.g_last), l_api_name, fnd_log.level_error);
      END IF;
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF l_debug THEN
        debug('HZ_PARTY_SITE_V2PUB.CREATE_PS was successful. Party Site ID = ' || p_address.party_site_id, l_api_name, fnd_log.level_error);
      END IF;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('Expected Error: ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;

      ROLLBACK TO create_party;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_debug THEN
        fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
        debug('Unexpected Error: ' || x_msg_data, l_api_name, fnd_log.level_unexpected);
      END IF;

      ROLLBACK TO create_party;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
    WHEN OTHERS THEN
      IF l_debug THEN
        debug('Exception: SQLCODE = ' || SQLCODE || ' : SQLERRM = ' || SQLERRM, l_api_name, fnd_log.level_unexpected);
      END IF;

      ROLLBACK TO create_party;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END create_one_time_address;


procedure create_location(p_api_version in number
                          , p_init_msg_list in varchar2
                          , p_commit in varchar2
                          , x_return_status out nocopy varchar2
                          , x_msg_data out nocopy varchar2
                          , x_msg_count out nocopy number
                          , p_resource_id in number
                          , p_resource_type in varchar2
                          , x_address_rec in  out nocopy csf_resource_address_pvt.address_rec_type1)
is
begin

create_one_time_address(
    p_api_version =>  p_api_version
  , p_init_msg_list =>  p_init_msg_list
  , p_commit          =>  p_commit
  , x_return_status   =>x_return_status
  , x_msg_count       =>x_msg_count
  , x_msg_data        =>x_msg_data
  , p_resource_id     =>p_resource_id
  , p_resource_type   =>p_resource_type
  , p_address         => x_address_rec
);
end;

PROCEDURE get_default_location(p_resource_id NUMBER,
                               p_resource_type VARCHAR2,
                               x_address_rec OUT NOCOPY address_rec_type)
IS
CURSOR c_trip_location
IS
select hl.location_id,
       hps.party_site_id,
       hps.party_id,
       hl.address1,
       hl.postal_code,
       hl.city,
       hl.state,
       hl.country,
       t.territory_short_name,
       HPS.START_DATE_ACTIVE,
       HPS.END_DATE_ACTIVE
FROM  csp_rs_cust_relations csc
    , hz_locations hl
    , fnd_territories_vl t
    , hz_party_sites hps
WHERE csc.resource_id=p_resource_id
  AND   csc.resource_type = p_resource_type
  AND csc.default_trip_start = hl.location_id(+)
  AND hl.country = t.territory_code(+)
  AND hps.location_id = HL.location_id
  AND csc.default_trip_start is not null;

l_trip_location c_trip_location%rowtype;

BEGIN

    open c_trip_location;
    fetch c_trip_location into l_trip_location;
    IF c_trip_location%found
    THEN
      x_address_rec.street               := l_trip_location.address1;
      x_address_rec.postal_code          := l_trip_location.postal_code;
      x_address_rec.city                 := l_trip_location.city;
      x_address_rec.state                := l_trip_location.state;
      x_address_rec.country              := l_trip_location.country;
      x_address_rec.territory_short_name := l_trip_location.territory_short_name;
      x_address_rec.start_date_active    := l_trip_location.start_date_active;
      x_address_rec.end_date_active      := l_trip_location.end_date_active;
      x_address_rec.location_id          := l_trip_location.location_id;
      x_address_rec.party_site_id         := l_trip_location.party_site_id;
      x_address_rec.party_id              := l_trip_location.party_id;
    END IF;
    close c_trip_location;

END;

BEGIN
  init_package;
END csf_resource_address_pvt;

/
