--------------------------------------------------------
--  DDL for Package Body HZ_GEOCODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOCODE_PKG" AS
  /*$Header: ARHGEOCB.pls 120.8 2005/09/08 21:50:23 acng noship $*/

  -- private global variables

  g_warning             VARCHAR2(1) := 'W';
  g_last_valid_country  VARCHAR2(60) := NULL;

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
  PROCEDURE time_put_line (msg IN VARCHAR2) IS
  BEGIN
    hz_utility_v2pub.debug(TO_CHAR(SYSDATE, 'HH:MI:SS') ||
                           ': ' || SUBSTRB(msg, 1, 240));
  END time_put_line;

  --------------------------------------
  -- PRIVATE PROCEDURE xml_put_line
  -- DESCRIPTION
  --   Utility routine for testing.  Prints the argument in a manner that
  --   dbms_output can deal with.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     hz_utility_v2pub.debug
  -- MODIFICATION HISTORY
  --   01-10-2002 J. del Callar
  --------------------------------------
  PROCEDURE xml_put_line (msg IN VARCHAR2) IS
  BEGIN
    hz_utility_v2pub.debug('XML request:');
    FOR i IN 1..LENGTHB(msg)/240 LOOP
      hz_utility_v2pub.debug(SUBSTRB(msg, (i-1)*240+1, 240));
    END LOOP;
  END xml_put_line;

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
      END IF;
    END IF;
  END disable_debug;
  */

  --------------------------------------
  -- Copy the status for the upper layer
  --------------------------------------
  PROCEDURE status_handler (
    l_return_status IN VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      NULL;
    ELSIF x_return_status = g_warning
          AND l_return_status = fnd_api.g_ret_sts_success
    THEN
      NULL;
    ELSE
      x_return_status := l_return_status;
    END IF;
  END status_handler;

  -------------------------------------------
  -- Default XML end tag for a given node tag
  -------------------------------------------
  FUNCTION xml_end_tag (p_start_tag IN VARCHAR2) RETURN VARCHAR2 IS
    l_end_tag  VARCHAR2(2000);
    l_pos      NUMBER := 0;
  BEGIN
    l_end_tag := UPPER(p_start_tag);
    l_pos := INSTRB(l_end_tag, ' ');
    IF l_pos <> 0 THEN
      l_end_tag := SUBSTRB(l_end_tag, 1, l_pos);
    END IF;
    l_end_tag := RTRIM(LTRIM(TRIM(l_end_tag),'<'),'>');
    l_end_tag := '</'||l_end_tag||'>';
    RETURN l_end_tag;
  END xml_end_tag;

  --
  -- PRIVATE FUNCTION
  --   get_terminal_string
  --
  -- DESCRIPTION
  --   Gets the terminal string for an XML statement.  The string can either
  --   be a tag terminator (/>) or a matching end tag (e.g., </tag>).
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- MODIFICATION HISTORY
  --
  --   02-28-2002    Herve Yu           Created.
  --   04-01-2002    Joe del Callar     Changed the name to make it more
  --                                    understandable.  Put this comment in.
  --
  FUNCTION get_terminal_string (
    p_str       IN VARCHAR2,
    p_temp_sta  IN VARCHAR2,
    p_temp_end  IN VARCHAR2 DEFAULT NULL,
    p_provider  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    test_char    VARCHAR2(1);
    l_temp_sta   VARCHAR2(200);
    l_temp_end   VARCHAR2(200);
    l_str        VARCHAR2(32767);
    l_len        NUMBER;
    l_init       NUMBER;
    temp_pos     NUMBER;
    char_to_find VARCHAR2(10);
    i            NUMBER;
  BEGIN
    char_to_find := NULL;
    l_temp_sta := p_temp_sta;
    --l_temp_end := UPPER(p_temp_end);
    --l_str      := UPPER(p_str);
    l_temp_end := p_temp_end;
    l_str      := p_str;
    l_len      := LENGTHB(l_str);
    --l_temp_sta := '<'||UPPER(RTRIM(LTRIM(TRIM(l_temp_sta),'<'),'>'));
    l_temp_sta := '<'||RTRIM(LTRIM(TRIM(l_temp_sta),'<'),'>');
    l_init     := INSTRB(l_str, l_temp_sta);
    temp_pos   := l_init + LENGTHB(l_temp_sta);
    IF l_temp_end IS NULL THEN
      l_temp_end := xml_end_tag(p_temp_sta);
    END IF;
    IF INSTRB(l_str, l_temp_sta) <> 0 THEN
      LOOP
        test_char := SUBSTRB(l_str,temp_pos,1);
        temp_pos  := temp_pos + 1;
        EXIT WHEN temp_pos > l_len;
        IF test_char = '/' THEN
          test_char := SUBSTRB(l_str,temp_pos,1);
          temp_pos  := temp_pos + 1;
          IF test_char = '>' THEN
            char_to_find := '/>';
            EXIT;
          END IF;
        ELSIF test_char = '>' THEN
          char_to_find := l_temp_end;
          EXIT;
        END IF;
      END LOOP;
    END IF;
    RETURN char_to_find;
  END get_terminal_string;

  --
  -- PUBLIC FUNCTION
  --   remove_whitespace
  --
  -- DESCRIPTION
  --   Remove whitespace from a string
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- MODIFICATION HISTORY
  --
  --   02-28-2002    Joe del Callar      Created.
  --
  FUNCTION remove_whitespace (p_str IN VARCHAR2) RETURN VARCHAR2 IS
    l_str    VARCHAR2(32767);
  BEGIN
    l_str := p_str;
    l_str := RTRIM(LTRIM(l_str, fnd_global.local_chr(13)),
                   fnd_global.local_chr(13));
    l_str := RTRIM(LTRIM(l_str, fnd_global.local_chr(8)),
                   fnd_global.local_chr(8));
    l_str := RTRIM(LTRIM(l_str, fnd_global.local_chr(10)),
                   fnd_global.local_chr(10));
    l_str := RTRIM(LTRIM(l_str, fnd_global.local_chr(0)),
                   fnd_global.local_chr(0));
    l_str := RTRIM(LTRIM(l_str));
    RETURN l_str;
  END remove_whitespace;

  --
  -- PRIVATE FUNCTION
  --   xmlize_line
  --
  -- DESCRIPTION
  --   Return an XML interpretation of a single address line in HZ_LOCATIONS.
  --   The strings &, < and > have to be removed.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     HZ_UTILITY_V2PUB.enable_debug
  --
  -- MODIFICATION HISTORY
  --
  --   01-28-2002    Joe del Callar      Created.
  --   02-28-2002    J. del Callar       Generalized to also remove whitespace.
  --   04-01-2002    J. del Callar       Changed to also remove double quotes.
  --
  FUNCTION xmlize_line (p_str IN VARCHAR2) RETURN VARCHAR2 IS
    l_str    VARCHAR2(32767);
  BEGIN
    l_str := p_str;

    -- clean the string of reserved characters before returning
    l_str := REPLACE(l_str, '&');  -- get rid of ampersands
    l_str := REPLACE(l_str, '<');   -- get rid of open brackets
    l_str := REPLACE(l_str, '>');   -- get rid of close brackets
    l_str := REPLACE(l_str, '"');   -- get rid of double quotes
    l_str := REPLACE(l_str, '''');   -- get rid of double quotes
    l_str := REPLACE(l_str, '#');   -- get rid of hash
    l_str := REPLACE(l_str, '%');   -- get rid of percentage
    l_str := REPLACE(l_str, '+');   -- get rid of plus
    l_str := REPLACE(l_str, '&');  -- get rid of ampersands


    RETURN remove_whitespace(l_str);
  END xmlize_line;

  --
  -- PRIVATE PROCEDURE
  --   get_response_lines
  -- DESCRIPTION
  --   Fill a VARRAY with individual response from the website
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub.debug
  -- MODIFICATION HISTORY
  --   01-10-2002 Herve Yu
  --   04-01-2002 J. del Callar         Put comments in.  Added p_loc_array
  --                                    parameter so that this procedure can
  --                                    set the geometry status for instances
  --                                    where the location was not returned by
  --                                    the data provider.
  --

  PROCEDURE get_response_lines (
    p_str       IN     VARCHAR2,
    p_lines     IN OUT NOCOPY hz_geocode_pkg.array_t,
    p_loc_array IN OUT NOCOPY loc_array,
    p_temp_sta  IN     VARCHAR2,
    p_temp_end  IN     VARCHAR2 DEFAULT NULL,
    p_root_text IN     VARCHAR2 DEFAULT NULL,
    p_provider  IN     VARCHAR2 DEFAULT 'ELOCATION'
  ) IS
    l_init        NUMBER;
    l_end         NUMBER;
    l_str_search  VARCHAR2(32767);
    l_result      VARCHAR2(4000);
    l_len         NUMBER;
    l_break       VARCHAR2(1000);
    l_temp_sta    VARCHAR2(200);
    l_temp_end    VARCHAR2(200);
    l_provider    VARCHAR2(200);
    l_pos         NUMBER := 0;
    i             NUMBER;
    l_root_text   VARCHAR2(200);
    l_debug_prefix VARCHAR2(30) := '';
  BEGIN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.get_response_lines (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_root_text  := UPPER(p_root_text);
    l_temp_sta   := '<'||UPPER(LTRIM(p_temp_sta,'<'));
    l_temp_end   := UPPER(p_temp_end);
    i            := 0;
    l_provider   := UPPER(p_provider);
    l_len        := LENGTHB(p_str);
    l_str_search := UPPER(p_str);
    l_init       := 1;
    l_end        := INSTRB(l_str_search, l_temp_sta);
    IF l_end <> 0 THEN
      l_str_search := LTRIM(l_str_search, '<?XML VERSION="1.0" ENCODING="UTF-8" ?>');
      l_str_search := remove_whitespace(l_str_search);
      l_str_search := LTRIM(l_str_search, l_root_text);
      LOOP
        l_break      := get_terminal_string(
                          p_str       => l_str_search,
                          p_temp_sta  => l_temp_sta,
                          p_temp_end  => l_temp_end,
                          p_provider  => l_provider
                        );
        EXIT WHEN l_break IS NULL;
        l_end        := INSTRB(l_str_search, l_break);

        -- J. del Callar: ignore instances where the delimiter (l_break) is
        -- not in the search string (l_str_search).  This can occur if the
        -- user specified an end string (l_temp_end) in the call to
        -- get_terminal_string, but the string was not found in the p_str
        -- variable.
        IF l_end <> 0 THEN
          l_end        := l_end + LENGTHB(l_break);
          l_result     := SUBSTRB(l_str_search, 1, l_end);
          i            := i + 1;
          p_lines(i)   := l_result;
          l_str_search := SUBSTRB(l_str_search, l_end);
        ELSE
          -- J. del Callar: set the status of the address lines which did not
          -- get returned.
          p_loc_array(i).geometry_status_code := g_error;
          EXIT;
        END IF;
      END LOOP;
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.get_response_lines (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
  END get_response_lines;

  --
  -- PROCEDURE set_matching_geometry
  --
  -- DESCRIPTION
  --   Set the geometry and geometry_status_code attributes of the location
  --   record identified by p_location_id.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_location_id
  --     p_geometry
  --     p_geometry_status_code
  --     p_index
  --   IN/OUT:
  --     p_loc_array
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-28-2002    Joe del Callar  Created to facilitate integration with HR.
  --
  PROCEDURE set_matching_geometry (
    p_loc_array                 IN OUT NOCOPY  loc_array,
    p_location_id               IN      NUMBER,
    p_geometry                  IN      mdsys.sdo_geometry,
    p_geometry_status_code      IN      VARCHAR2,
    x_return_status             IN OUT NOCOPY  VARCHAR2,
    x_msg_count                 IN OUT NOCOPY  NUMBER,
    x_msg_data                  IN OUT NOCOPY  VARCHAR2
  ) IS
    i NUMBER;
    l_debug_prefix	VARCHAR2(30) := '';
  BEGIN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'hz_geocode_pkg.set_matching_geometry (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    FOR i IN 1..p_loc_array.COUNT LOOP
      -- find the matching location ID in the array.  set the geometry and
      -- geometry status, and return if successful.
      IF p_loc_array(i).location_id = p_location_id THEN
        p_loc_array(i).geometry             := p_geometry;
        p_loc_array(i).geometry_status_code := p_geometry_status_code;
        -- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'hz_geocode_pkg.set_matching_geometry (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
	END IF;
        RETURN;
      END IF;
    END LOOP;

    -- No matching ID was found in the array: report on this.
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('AR', 'HZ_NO_LOCATION_FOUND');
    fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
    fnd_msg_pub.add;
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Location record not found',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
    END IF;
  END set_matching_geometry;

  -------------------------------
  -- RETURN Y if country is valid
  --        N otherwise
  -------------------------------
  FUNCTION is_country_valid (
    p_country_code   IN VARCHAR2,
    p_null_ok        IN VARCHAR2 DEFAULT 'Y'
  ) RETURN VARCHAR2 IS
    CURSOR c_validcountries IS
      SELECT al.lookup_code
      FROM   ar_lookups al
      WHERE  al.lookup_type = 'HZ_SPATIAL_VALID_COUNTRIES'
             AND al.lookup_code = p_country_code;
    l_country VARCHAR2(30);
  BEGIN
    IF g_last_valid_country = p_country_code THEN
      RETURN 'Y';
    ELSIF p_null_ok = 'Y' AND p_country_code IS NULL THEN
      RETURN 'Y';
    ELSE
      OPEN c_validcountries;
      FETCH c_validcountries INTO l_country;
      IF c_validcountries%NOTFOUND THEN
        CLOSE c_validcountries;
        RETURN 'N';
      END IF;
      CLOSE c_validcountries;

      -- found a valid country, set the cached value
      g_last_valid_country := l_country;
      RETURN 'Y';
    END IF;
  END is_country_valid;

  FUNCTION success_output (v IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF INSTRB(v,'<?XML VERSION="1.0" ENCODING="UTF-8"?>') <> 0 THEN
      RETURN LTRIM(remove_whitespace(LTRIM(remove_whitespace(v),'<?XML VERSION="1.0" ENCODING="UTF-8"?>')),'<GEOCODE_RESPONSE>');
    ELSE
      RETURN v;
    END IF;
  END success_output;

  -------------------------------------------------------
  -- RETURN Y if nls_numeric_character = '.,' US standard
  --        N otherwise
  -------------------------------------------------------
  FUNCTION is_nls_num_char_pt_com RETURN VARCHAR2 IS
    CURSOR cu_nls_num IS
      SELECT vp.value
      FROM   v$parameter vp
      WHERE  LOWER(vp.name) = 'nls_numeric_characters';
    l_value VARCHAR2(10);
  BEGIN
    OPEN cu_nls_num;
    FETCH cu_nls_num INTO l_value;
    CLOSE cu_nls_num;
    IF l_value = '.,' THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END is_nls_num_char_pt_com;

  --------------------------------------------------
  -- RETURN the line "<us_form>" for the xml request
  -- if error then x_return_status := 'E'
  --------------------------------------------------
  FUNCTION compose_elocation_detail_old (
    p_location_id             NUMBER,
    p_country                 VARCHAR2,
    p_address1                VARCHAR2,
    p_address2                VARCHAR2,
    p_address3                VARCHAR2,
    p_address4                VARCHAR2,
    p_city                    VARCHAR2,
    p_postal_code             VARCHAR2,
    p_state                   VARCHAR2,
    p_name                    VARCHAR2 DEFAULT NULL,
    p_init_msg_list IN        VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2
  ) RETURN VARCHAR2 IS
    l_country          VARCHAR2(200);
    l_address1         VARCHAR2(200);
    l_address2         VARCHAR2(200);
    l_address3         VARCHAR2(200);
    l_address4         VARCHAR2(200);
    l_city             VARCHAR2(200);
    l_postal_code      VARCHAR2(200);
    l_state            VARCHAR2(200);
    l_name             VARCHAR2(200);
    us_form_str        VARCHAR2(1250);
    l_address          VARCHAR2(1000);
    notcorrectaddress  EXCEPTION;
    l_return_status    VARCHAR2(10);
    l_debug_prefix     VARCHAR2(30) := '';
  BEGIN
    l_return_status := fnd_api.g_ret_sts_success;
    l_country       := xmlize_line(p_country);
    l_city          := xmlize_line(p_city);
    l_postal_code   := xmlize_line(p_postal_code);
    l_state         := xmlize_line(p_state);
    l_name          := xmlize_line(p_name);
    l_address1      := xmlize_line(p_address1);
    l_address2      := xmlize_line(p_address2);
    l_address3      := xmlize_line(p_address3);
    l_address4      := xmlize_line(p_address4);
    us_form_str     := '';

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name ||'.compose_elocation_detail_old for location_id:'
                             || TO_CHAR(p_location_id) ||' (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF l_city IS NOT NULL AND l_state IS NOT NULL THEN
      us_form_str := '<us_form2 ';
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'City :'||l_city||' and state :'||l_state||' are not null : Success',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSIF l_postal_code IS NOT NULL THEN
      us_form_str := '<us_form1 ';
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Postal Code :'||l_postal_code||' is not null : Success',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSE
      l_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('AR', 'HZ_ZIP_OR_CITY_AND_STATE');
      fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
      fnd_msg_pub.add;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'City, state and postal code are null : Error',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
    END IF;

    -- p_name not mandatory
    IF l_name IS NOT NULL THEN
      us_form_str := us_form_str || 'name="' || l_name || '" ';
    END IF;
    l_address := l_address1;
    IF l_address2 IS NOT NULL THEN
      l_address := l_address ||' '||l_address2;
    END IF;
    IF l_address3 IS NOT NULL THEN
      l_address := l_address ||' '||l_address3;
    END IF;
    IF l_address4 IS NOT NULL THEN
      l_address := l_address ||' '||l_address4;
    END IF;

    -- Address1 is mandatory
    IF l_address IS NOT NULL THEN
      us_form_str := us_form_str || 'street="' || l_address ||'" ';
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Address : '||l_address ||' is not null : Success',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSE
      l_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('AR', 'HZ_ADDRESS_LINE_MANDATORY');
      fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
      fnd_msg_pub.add;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Address is not null : Error ',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
    END IF;

    -- City is mandatory
    IF l_city IS NOT NULL THEN
      us_form_str := us_form_str || 'city="' || l_city || '" ';
    END IF;

    -- State is mandatory
    IF l_state IS NOT NULL THEN
      us_form_str := us_form_str || 'state="' || l_state || '" ';
    END IF;

    -- Postal code is not manadatory
    IF l_postal_code IS NOT NULL THEN
      us_form_str := us_form_str || 'lastline="' || l_postal_code || '" ';
    END IF;

    --Country NULL or US
    IF is_country_valid(l_country ,'Y') <> 'Y' THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Country must be null or US : Error',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      l_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('AR', 'HZ_SPATIAL_INVALID_COUNTRY');
      fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
      fnd_message.set_token('COUNTRY', l_country);
      fnd_msg_pub.add;
    END IF;

    us_form_str := us_form_str || '/>';
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE notcorrectaddress;
    END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.compose_elocation_detail_old :'|| TO_CHAR(p_location_id) ||' (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data );

    RETURN us_form_str;
  EXCEPTION
   WHEN notcorrectaddress THEN
     us_form_str     := NULL;
     status_handler(l_return_status, x_return_status);
     fnd_msg_pub.count_and_get(
       p_encoded => fnd_api.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
     );
     RETURN us_form_str;
  END compose_elocation_detail_old;

  --
  -- PRIVATE PROCEDURE compose_elocation_detail
  --
  -- DESCRIPTION
  --   Return an XML interpretation of an address in HZ_LOCATIONS.  The XML
  --   returned will be of the following form:
  --        <unformatted country="[ISO country code]">
  --          <address_line value="Mr. Ji Yang" />
  --          <address_line value="Oracle Corp" />
  --          <address_line value="1 Oracle drive" />
  --          <address_line value="3rd floor" />
  --          <address_line value="Nashua" />
  --          <address_line value="NH" />
  --        </unformatted>
  --
  --   where each address_line value represents an American address column in
  --   HZ_LOCATIONS.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- MODIFICATION HISTORY
  --
  --   01-23-2002    Joe del Callar      Created.
  --
  --
  FUNCTION compose_elocation_detail (
    p_location_id             NUMBER,
    p_country                 VARCHAR2,
    p_address1                VARCHAR2,
    p_address2                VARCHAR2,
    p_address3                VARCHAR2,
    p_address4                VARCHAR2,
    p_city                    VARCHAR2,
    p_postal_code             VARCHAR2,
    p_county                  VARCHAR2,
    p_state                   VARCHAR2,
    p_province                VARCHAR2,
    p_name                    VARCHAR2 DEFAULT NULL,
    p_init_msg_list IN        VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2
  ) RETURN VARCHAR2 IS
    l_country                   VARCHAR2(200);
    l_address1                  VARCHAR2(240);
    l_address2                  VARCHAR2(240);
    l_address3                  VARCHAR2(240);
    l_address4                  VARCHAR2(240);
    l_city                      VARCHAR2(200);
    l_postal_code               VARCHAR2(200);
    l_state                     VARCHAR2(200);
    l_county                    VARCHAR2(200);
    l_province                  VARCHAR2(200);
    l_name                      VARCHAR2(200);
    l_xml_address               VARCHAR2(1750);
    l_line_break                VARCHAR2(200) := '"/> <address_line value="';
    l_formatted_address         VARCHAR2(1500);
    l_return_status             VARCHAR2(10);
    l_line_cnt                  NUMBER;
    l_formatted_address_tbl     hz_format_pub.string_tbl_type;
    l_debug_prefix              VARCHAR2(30) := '';
    notcorrectaddress           EXCEPTION;
  BEGIN
    l_return_status := fnd_api.g_ret_sts_success;
-- Fix perf bug 3669930, 4220460, remove xmlize_line function call for
-- some parameter.  For others, check if the value is not null, then
-- do xmlize_line
    l_country       := p_country;
    l_city          := p_city;
    IF(p_postal_code IS NOT NULL) THEN
      l_postal_code   := xmlize_line(p_postal_code);
    END IF;
    l_state         := p_state;
    l_name          := p_name;
    l_address1      := xmlize_line(p_address1);
    IF(p_address2 IS NOT NULL) THEN
      l_address2      := xmlize_line(p_address2);
    END IF;
    IF(p_address3 IS NOT NULL) THEN
      l_address3      := xmlize_line(p_address3);
    END IF;
    IF(p_address4 IS NOT NULL) THEN
      l_address4      := xmlize_line(p_address4);
    END IF;
    l_province      := p_province;
    l_county        := p_county;
    l_xml_address   := '';

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name ||
                               '.compose_elocation_detail for location_id:' ||
                               TO_CHAR(p_location_id) ||' (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check for valid countries
    IF is_country_valid(l_country ,'Y') <> 'Y' THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Country invalid',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      l_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('AR', 'HZ_SPATIAL_INVALID_COUNTRY');
      fnd_message.set_token('LOC_ID', TO_CHAR(p_location_id));
      fnd_message.set_token('COUNTRY', l_country);
      fnd_msg_pub.add;
      -- raise the error immediately and forget about processing the rest.
      RAISE notcorrectaddress;
    END IF;

    -- if state and city are not null, null out NOCOPY the postal code so that
    -- it does not get composed into the address, as eLocations has some issues
    -- with inconsistent city/state/postal code combinations.
    IF l_city IS NOT NULL AND l_state IS NOT NULL
    THEN
      l_postal_code := NULL;
    END IF;

    -- if state and province are null and the postal code is not, then null
    -- out NOCOPY the city so that eLocations does its search based only on the
    -- postal code only.
    IF l_state IS NULL
       AND l_province IS NULL
       AND l_postal_code IS NOT NULL
    THEN
      l_city := NULL;
    END IF;

    -- Set the head of the request.
    l_xml_address := '<unformatted country="' || l_country
                       || '"> <address_line value="';

    -- call the address format API
    hz_format_pub.format_eloc_address (
      p_style_code            => 'POSTAL_ADDR',
      p_style_format_code     => NULL,
      p_line_break            => l_line_break,
      p_space_replace         => ' ',
      p_from_territory_code   => l_country,
      p_address_line_1        => l_address1,
      p_address_line_2        => l_address2,
      p_address_line_3        => l_address3,
      p_address_line_4        => l_address4,
      p_city                  => l_city,
      p_postal_code           => l_postal_code,
      p_state                 => l_state,
      p_province              => l_province,
      p_county                => l_county,
      p_country               => l_country,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      x_formatted_address     => l_formatted_address,
      x_formatted_lines_cnt   => l_line_cnt,
      x_formatted_address_tbl => l_formatted_address_tbl
    );

    l_xml_address := l_xml_address || l_formatted_address
                       || '"/> </unformatted>';
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE notcorrectaddress;
    END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name ||
                               '.compose_elocation_detail :' ||
                               TO_CHAR(p_location_id) ||' (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);

    RETURN l_xml_address;
  EXCEPTION
   WHEN notcorrectaddress THEN
     l_xml_address     := NULL;
     status_handler(l_return_status, x_return_status);
     fnd_msg_pub.count_and_get(
       p_encoded => fnd_api.g_false,
       p_count => x_msg_count,
       p_data  => x_msg_data
     );
     RETURN l_xml_address;
  END compose_elocation_detail;

  ---------------------------------------------------
  -- RETURN the xml request for 1 to 12 location info
  -- If error then x_return_status = E
  ---------------------------------------------------
  FUNCTION location_xml (
    p_loc_array     IN OUT NOCOPY    loc_array,
    p_name          IN        VARCHAR2 DEFAULT NULL,
    p_provider      IN        VARCHAR2 DEFAULT 'ELOCATION',
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(10);
    xml_request     VARCHAR2(32640);
    l_count         NUMBER;
    l_form_us       VARCHAR2(2500);
    at_least_one    VARCHAR2(1);
    l_loc_rec       hz_location_v2pub.location_rec_type;
    l_debug_prefix  VARCHAR2(30):= '';
    msg             VARCHAR2(2000);
  BEGIN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.location_xml (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    l_count := p_loc_array.COUNT;
    IF l_count <> 0 THEN
       At_least_one:= 'N';
       xml_request := '';
       xml_request := 'xml_request=<?xml version="1.0" standalone="yes" ?>' ||
                      '<geocode_request vendor="elocation">'    ||
                      '<address_list>'||FND_GLOBAL.local_chr(10);
      FOR i IN 1..l_count LOOP
        l_return_status := fnd_api.g_ret_sts_success;
        l_loc_rec := p_loc_array(i);
        l_form_us :=
          compose_elocation_detail (
            p_location_id   => l_loc_rec.location_id,
            p_country       => l_loc_rec.country,
            p_address1      => l_loc_rec.address1,
            p_address2      => l_loc_rec.address2,
            p_address3      => l_loc_rec.address3,
            p_address4      => l_loc_rec.address4,
            p_city          => l_loc_rec.city,
            p_postal_code   => l_loc_rec.postal_code,
            p_county        => l_loc_rec.county,
            p_state         => l_loc_rec.state,
            p_province      => l_loc_rec.province,
            p_name          => p_name,
            p_init_msg_list => fnd_api.g_true,
            x_return_status => l_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data
          );

        -- J. del Callar: set the error status of any offending records.
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          status_handler(l_return_status, x_return_status);
          p_loc_array(i).geometry_status_code := g_error;
        END IF;

        IF l_form_us IS NOT NULL THEN
          at_least_one:='Y';
          xml_request := xml_request ||
            '<input_location id="' ||
            TO_CHAR(p_loc_array(i).location_id)||'" ' ||
            'multimatch_number= "3" >' ||
            '<input_address match_mode="relax_street_type">' ||
            l_form_us ||
            '</input_address>'  ||
            '</input_location>' || FND_GLOBAL.local_chr(10);
        END IF;
      END LOOP;
    END IF;

    IF at_least_one = 'Y' THEN
      xml_request := xml_request         ||
                     '</address_list>'   ||
                     '</geocode_request>';
    ELSE
      xml_request := '';
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.location_xml (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data );

    RETURN xml_request;
  END location_xml;

  FUNCTION elt_value
  --------------------------------------------
  -- RETURN the value of the requested element
  --        NULL if element NOT FOUND
  --------------------------------------------
  ( p_str   IN    VARCHAR2,
    p_elt   IN    VARCHAR2)
  RETURN VARCHAR2
  IS
    retVal       VARCHAR2(2000);
    l_str        VARCHAR2(4000);
    l_elt        VARCHAR2(2000);
    l_pos_deb    NUMBER;
    first_quote  NUMBER;
    second_quote NUMBER;
    l_equal      VARCHAR2(1);
    l_len        NUMBER;
    i            NUMBER;
  BEGIN
    i := 1;
    l_str  := upper(p_str);
-- Fix perf bug 3669930, 4220460, remove upper of p_elt since the pass in
-- value is always in upper case
    l_elt  := p_elt;
    l_len  := lengthb(p_elt);
    LOOP
      l_pos_deb := INSTRB(l_str, l_elt, 1, i);
      IF l_pos_deb = 0 THEN
        RETURN NULL;
      ELSE
        l_equal := SUBSTRB(l_str, l_pos_deb + l_len, 1);
        IF l_equal <> '=' THEN
          i := i + 1;
        ELSE
          EXIT;
        END IF;
      END IF;
    END LOOP;
    first_quote  := INSTRB(l_str, '"', l_pos_deb, 1);
    second_quote := INSTRB(l_str, '"', l_pos_deb, 2);
    retval := SUBSTRB(l_str,
                      first_quote + 1,
                      (second_quote - 1)-(first_quote + 1) + 1);
    RETURN retval;
  END elt_value;

  FUNCTION gen_geo
  (p_SDO_GTYPE  NUMBER,
   p_SDO_SRID   NUMBER,
   p_xlo        NUMBER,
   p_yla        NUMBER,
   p_zdp        NUMBER DEFAULT NULL,
   p_info_array mdsys.SDO_ELEM_INFO_ARRAY DEFAULT NULL,
   p_ordi_array MDSYS.SDO_ORDINATE_ARRAY DEFAULT NULL,
   p_provider   VARCHAR2 DEFAULT 'ELOCATION')
  RETURN  MDSYS.SDO_GEOMETRY
  IS
    l_geo     MDSYS.SDO_GEOMETRY;
    l_sdo_pt  MDSYS.SDO_POINT_TYPE;
  BEGIN
    -- p_sdo_gtype = 2001; --
    -- p_sdo_srid  = 8307; --
    l_sdo_pt := MDSYS.SDO_POINT_TYPE(p_xlo,
                                     p_yla,
                                     p_zdp);
    l_geo := MDSYS.SDO_GEOMETRY(p_sdo_gtype,
                                p_sdo_srid,
                                l_sdo_pt,
                                p_info_array,
                                p_ordi_array);
    RETURN l_geo;
  END gen_geo;

  PROCEDURE non_num_handle(
    Elt_name        IN VARCHAR2,
    Elt_value       IN VARCHAR2,
    p_location_id   IN NUMBER,
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2)
  IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('AR', 'HZ_NUMBER_MANDATORY');
    fnd_message.set_token('VALUE',Elt_value);
    fnd_message.set_token('ELT',Elt_name);
    fnd_message.set_token('LOC_ID',TO_CHAR(p_location_id));
    fnd_msg_pub.add;
  END non_num_handle;

  --
  -- PROCEDURE parse_one_response
  --
  -- DESCRIPTION
  --   Accept One location Xml
  --   Do Validation (GEOCODE ID mandatory, LATITUDE mandatory, LONGITUDE
  --   mandatory, STREET warn, MATCH_COUNT warn)
  --   Do update TCA Registry
  --   If error then x_return_status = E
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_str
  --   IN/OUT:
  --     x_loc_id
  --     x_geo
  --     x_geo_status
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-09-2002    Herve Yu        Created.
  --   01-28-2002    Joe del Callar  Modified to return the geometry in order
  --                                 to facilitate integration with HR.
  --

  PROCEDURE parse_one_response (
    p_str           IN        VARCHAR2,
    x_loc_id        IN OUT NOCOPY    NUMBER,
    x_geo           IN OUT NOCOPY    mdsys.sdo_geometry,
    x_geo_status    IN OUT NOCOPY    VARCHAR2,
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2
  ) IS
    l_recep             VARCHAR2(1000);
    l_long_found        BOOLEAN := FALSE;
    l_lat_found         BOOLEAN := FALSE;
    l_latitude          NUMBER;
    l_longitude         NUMBER;
    l_match_count       NUMBER;
    l_match_count_temp  VARCHAR2(1000);
    l_street            VARCHAR2(1200);
    l_debug_prefix      VARCHAR2(30) := '';
    l_return_status     VARCHAR2(10);
  BEGIN
    -- Procedure pour tester la possibilite de transformer l_recep en nombre qui soit controle
    -- Afin de capturer les erreurs evebntuellement de Alfa num.
    l_return_status := fnd_api.g_ret_sts_success;

    -- J. del Callar: set the geo status to success
    x_geo_status := g_good;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_geocode_pkg.parse_one_response (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_recep := elt_value(p_str, 'GEOCODE ID');
    IF l_recep IS NULL THEN
      l_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('AR', 'HZ_MISSING_GEOCODE_ID');
      fnd_msg_pub.add;
      status_handler(l_return_status, x_return_status);
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'No Geocode Id Found : Error',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
    END IF;

    -- J. del Callar: convert location ID into a number, but handle non-numeric
    -- value errors.
    BEGIN
      x_loc_id := TO_NUMBER(l_recep);
    EXCEPTION
      WHEN OTHERS THEN
        non_num_handle('GEOCODE ID', l_recep, x_loc_id,
                       l_return_status, x_msg_count, x_msg_data);
        status_handler(l_return_status, x_return_status);
        RETURN;
    END;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Geocode Id :'||l_recep,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- determine the match count.
    l_match_count_temp := elt_value(p_str, 'MATCH_COUNT');

    l_recep  := elt_value(p_str, 'LATITUDE');
    IF l_recep IS NULL THEN
      l_return_status := fnd_api.g_ret_sts_error;

      -- J. del Callar: report this error to the user only if a row was
      -- returned.  if a row was not returned, the error gets reported in a
      -- more meaningful way later on.
      IF l_match_count_temp <> '0' THEN
        fnd_message.set_name('AR', 'HZ_MISSING_LATITUDE');
        fnd_message.set_token('LOC_ID', TO_CHAR(x_loc_id));
        fnd_msg_pub.add;
        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Latitude not found',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	END IF;
      END IF;
      status_handler(l_return_status, x_return_status);
      l_lat_found := FALSE;
    ELSE
      -- J. del Callar: convert latitude into a number, but handle non-numeric
      -- value errors.
      BEGIN
        l_latitude := TO_NUMBER(l_recep);
      EXCEPTION
        WHEN OTHERS THEN
          non_num_handle('LATITUDE', l_recep, x_loc_id,
                         l_return_status, x_msg_count, x_msg_data);
          status_handler(l_return_status, x_return_status);
      END;
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Latitude: '||l_recep,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
     END IF;
      l_lat_found := TRUE;
    END IF;

    l_recep  := elt_value( p_str, 'LONGITUDE');
    IF l_recep IS NULL THEN
      l_return_status := fnd_api.g_ret_sts_error;

      -- J. del Callar: report this error to the user only if a row was
      -- returned.  if a row was not returned, the error gets reported in a
      -- more meaningful way later on.
      IF l_match_count_temp <> '0' THEN
        fnd_message.set_name('AR', 'HZ_MISSING_LONGITUDE');
        fnd_message.set_token('LOC_ID', TO_CHAR(x_loc_id));
        fnd_msg_pub.add;
        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Longitude not found',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	END IF;
      END IF;

      status_handler(l_return_status, x_return_status);
      l_long_found := FALSE;
    ELSE
      -- J. del Callar: convert latitude into a number, but handle non-numeric
      -- value errors.
      BEGIN
        l_longitude := TO_NUMBER(l_recep);
      EXCEPTION
        WHEN OTHERS THEN
          non_num_handle('LONGITUDE', l_recep, x_loc_id,
                         l_return_status, x_msg_count, x_msg_data);
          status_handler(l_return_status, x_return_status);
      END;
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Longitude: '||l_recep,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;


      l_long_found := TRUE;
    END IF;

    l_street := elt_value(p_str, 'STREET');

    -- J. del Callar: inform user that the city center was returned by the
    -- spatial data provider.  The message should only occur if the street is
    -- not found, but the latitude and longitude were found.
    IF l_street IS NULL AND l_lat_found AND l_long_found THEN
      l_return_status := g_warning;
      fnd_message.set_name('AR','HZ_MISSING_STREET');
      fnd_message.set_token('LOC_ID', TO_CHAR(x_loc_id));
      fnd_msg_pub.add;
      status_handler(l_return_status, x_return_status);

      -- J. del Callar: set the status reported in
      -- HZ_LOCATIONS.GEOMETRY_STATUS_CODE to NOEXACTMATCH to reflect the fact
      -- that the city or zip center was returned.
      x_geo_status := g_noexactmatch;

      -- Debug info.
      IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'The street was not found',
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);

      END IF;
    ELSE
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Street: '||l_street,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- J. del Callar: convert match count into a number and handle non-numeric
    -- errors.
    BEGIN
      l_match_count := TO_NUMBER(l_match_count_temp);

      IF l_match_count > 1 THEN
        l_return_status := g_warning;
        fnd_message.set_name('AR','HZ_NB_MATCHES');
        fnd_message.set_token('NB', l_match_count_temp);
        fnd_message.set_token('LOC_ID', TO_CHAR(x_loc_id));
        fnd_msg_pub.add;

        -- J. del Callar: set the status reported in
        -- HZ_LOCATIONS.GEOMETRY_STATUS_CODE to MULTIMATCH to reflect that
        -- multiple matches were returned.
        x_geo_status := g_multimatch;
	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Multiple matching addresses:'|| l_match_count_temp,
	                       p_prefix=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
        END IF;
      ELSIF l_match_count = 0 THEN
        l_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name('AR','HZ_NB_MATCHES');
        fnd_message.set_token('NB', l_match_count_temp);
        fnd_message.set_token('LOC_ID', TO_CHAR(x_loc_id));
        fnd_msg_pub.add;

        -- J. del Callar: no rows were returned by location service
        -- mark this as an error.
        x_geo_status := g_error;

	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'No matches (match_count=' ||
                                   l_match_count_temp ||
                                   '), update not possible.',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;

      END IF;
      status_handler(l_return_status, x_return_status);
    EXCEPTION
      WHEN OTHERS THEN
        non_num_handle('MATCH_COUNT', l_match_count_temp, x_loc_id,
                       l_return_status, x_msg_count, x_msg_data);
        status_handler(l_return_status, x_return_status);
    END;

    IF l_return_status <> fnd_api.g_ret_sts_error THEN
      x_geo := gen_geo(p_sdo_gtype => 2001,
                       p_sdo_srid  => 8307,
                       p_xlo       => l_longitude,
                       p_yla       => l_latitude);

      status_handler(l_return_status, x_return_status);
    ELSE
      x_geo := NULL;
      status_handler(l_return_status, x_return_status);
    END IF;

    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'parse_one_reponse (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
  END parse_one_response;

  --
  -- PRIVATE PROCEDURE
  --   parse_responses
  --
  -- DESCRIPTION
  --   Accept One location Xml
  --   Do Validation (GEOCODE ID mandatory, LATITUDE mandatory, LONGITUDE
  --   mandatory, STREET warn, MATCH_COUNT warn)
  --   Do update TCA Registry
  --   If error then x_return_status = E
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_str
  --   IN/OUT:
  --     x_loc_id
  --     x_geo
  --     x_geo_status
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-09-2002    Herve Yu        Created.
  --   01-28-2002    Joe del Callar  Modified to return the geometry in order
  --                                 to facilitate integration with HR.
  --
  PROCEDURE parse_responses (
    p_tab_address   IN        array_t,
    p_loc_array     IN OUT NOCOPY    loc_array,
    x_return_status IN OUT NOCOPY    VARCHAR2,
    x_msg_count     IN OUT NOCOPY    NUMBER,
    x_msg_data      IN OUT NOCOPY    VARCHAR2
  ) IS
    l_message                   VARCHAR2(4000);
    i                           NUMBER;
    j                           NUMBER;
    l_return_status             VARCHAR2(20);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_geometry                  mdsys.sdo_geometry;
    l_geometry_status_code      VARCHAR2(30);
    l_location_id               NUMBER;
    l_debug_prefix	        VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'parse_responses (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    l_return_status := fnd_api.g_ret_sts_success;
    i := p_tab_address.COUNT;
    IF i > 0 THEN
      FOR j IN 1..i LOOP
        parse_one_response(
          p_str           => p_tab_address(j),
          x_loc_id        => l_location_id,
          x_geo           => l_geometry,
          x_geo_status    => l_geometry_status_code,
          x_return_status => l_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data
        );
        status_handler(l_return_status, x_return_status);
        set_matching_geometry(p_loc_array,
                              l_location_id,
                              l_geometry,
                              l_geometry_status_code,
                              l_return_status,
                              x_msg_count,
                              x_msg_data);
        status_handler(l_return_status, x_return_status);
      END LOOP;
      -- all records with an unset geometry status are considered to be in
      -- error - set their status
      FOR j IN 1..p_loc_array.COUNT LOOP
        IF p_loc_array(j).geometry_status_code IS NULL THEN
          p_loc_array(j).geometry_status_code := g_error;
        END IF;
      END LOOP;
    END IF;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'parse_n_reponse (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
  END parse_responses;

  --
  -- PUBLIC FUNCTION
  --   in_bypass_list
  --
  -- DESCRIPTION
  --   Returns TRUE if the argument p_url_target is in p_exclusion_list, FALSE
  --   otherwise.  Used to determine whether or not to use a proxy.  This
  --   functionality can only be used with fixed-length character set
  --   exclusion lists and targets, which is okay since these are URLs.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_target_url
  --     p_exclusion_list
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   03-27-2002    J. del Callar   Created.
  --
  FUNCTION in_bypass_list (
    p_url_target        IN      VARCHAR2,
    p_exclusion_list    IN      VARCHAR2
  ) RETURN BOOLEAN IS
    l_exclusion_list    VARCHAR2(2000) := LOWER(p_exclusion_list);
    l_excluded_domain   VARCHAR2(240);
    l_delimiter         VARCHAR2(1);
    l_pos               NUMBER;
    l_url_domain        VARCHAR2(2000);
    l_debug_prefix	VARCHAR2(30) := '';
  BEGIN
    --enable_debug;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.in_bypass_list (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Checking for URL: ' || p_url_target,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'In list:',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>l_exclusion_list,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- First determine what the delimiter in the exclusion list is.  We support
    -- "|" (Java-style), "," (Netscape-style) and ";" (Microsoft-style)
    -- delimiters.  Java-style is given priority.
    IF INSTRB(l_exclusion_list, '|') > 0 THEN
      l_delimiter := '|';
    ELSIF INSTRB(l_exclusion_list, ',') > 0 THEN
      l_delimiter := ',';
    ELSIF INSTRB(l_exclusion_list, ';') > 0 THEN
      l_delimiter := ';';
    ELSE
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>g_pkg_name||'.in_bypass_list (fmt)',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      --disable_debug;

      RETURN FALSE;
    END IF;

    -- get the domain portion of the URL.
    -- first, put the domain in the same case as the exclusion list.
    l_url_domain := LOWER(p_url_target);

    -- second, remove the protocol specifier.
    l_pos := INSTRB(l_url_domain, '://');
    IF l_pos > 0 THEN
      l_url_domain := SUBSTRB(l_url_domain, l_pos+3);
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>':// found at position ' || l_pos,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'Stripped domain: ' || l_url_domain,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    l_pos := INSTRB(l_url_domain, ':/');
    IF l_pos > 0 THEN
      l_url_domain := SUBSTRB(l_url_domain, l_pos+2);
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>':/ found at position ' || l_pos,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'Stripped domain: ' || l_url_domain,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- third, remove the trailing URL information.
    l_pos := INSTRB(l_url_domain, '/');
    IF l_pos > 0 THEN
      l_url_domain := SUBSTRB(l_url_domain, 1, l_pos-1);
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'/ found at position ' || l_pos,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'Stripped domain: ' || l_url_domain,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- lastly, remove spaces in the exclusion list
    l_exclusion_list := REPLACE(l_exclusion_list, ' ');

    WHILE l_exclusion_list IS NOT NULL LOOP
      -- get the position of the 1st delimiter in the remaining exclusion list
      l_pos := INSTRB(l_exclusion_list, l_delimiter);

      IF l_pos = 0 THEN
        -- no delimiters implies that this is the last domain to be checked.
        l_excluded_domain := l_exclusion_list;
      ELSE
        -- need to do a SUBSTRB if there is a delimiter in the exclusion list
        -- to get the first domain left in the exclusion list.
        l_excluded_domain := SUBSTRB(l_exclusion_list, 1, l_pos-1);
      END IF;

      -- The domain should not have a % sign in it because it should be a
      -- domain name.  It may have a * sign in it depending on the syntax of
      -- the exclusion list.  * signs should be treated as % signs in SQL.
      l_excluded_domain := REPLACE(l_excluded_domain, '*', '%');

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Matching URL: ' || l_url_domain,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'Against dom:  ' || l_excluded_domain,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      -- check to see if the URL domain matches an excluded domain.
      IF l_url_domain LIKE '%' || l_excluded_domain THEN
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>g_pkg_name||'.in_bypass_list (match)',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;

        --disable_debug;

        -- a match was found, return a positive result.
        RETURN TRUE;
      END IF;

      IF l_pos = 0 THEN
        -- no more domains to be checked if no delimiters were found.
        l_exclusion_list := NULL;
      ELSE
        -- get the remaining domain exclusions to be checked.
        l_exclusion_list := SUBSTRB(l_exclusion_list, l_pos+1);
      END IF;
    END LOOP;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>g_pkg_name||'.in_bypass_list (eol)',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    --disable_debug;

    -- no domain match was found, return false
    RETURN FALSE;
  END in_bypass_list;

  --
  -- PUBLIC PROCEDURE
  --   get_spatial_coords
  --
  -- DESCRIPTION
  --   Build the xml request for n locations
  --   Post the Xml request
  --   Split the Response into individual responses
  --   Parse and update hz_locations with the responses
  --   If error Then x_return_status = E
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_name
  --     p_http_ad
  --     p_proxy
  --     p_port
  --     p_retry
  --     p_init_msg_list
  --   IN/OUT:
  --     p_loc_array
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-09-2002    Herve Yu        Created.
  --   01-28-2002    Joe del Callar  Modified to return the geometry in the
  --                                 loc_array structure in order to facilitate
  --                                 integration with HR.
  --

  PROCEDURE get_spatial_coords (
    p_loc_array     IN OUT NOCOPY loc_array,
    p_name          IN     VARCHAR2 DEFAULT NULL,
    p_http_ad       IN     VARCHAR2,
    p_proxy         IN     VARCHAR2 DEFAULT NULL,
    p_port          IN     NUMBER   DEFAULT NULL,
    p_retry         IN     NUMBER   DEFAULT 3,
    p_init_msg_list IN     VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status OUT NOCOPY    VARCHAR2,
    x_msg_count     OUT NOCOPY    NUMBER,
    x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    lxml             VARCHAR2(32767);
    lresp            VARCHAR2(32767);
    lrespct          VARCHAR2(200);
    ltab             array_t;
    msg              VARCHAR2(4000);
    cpt              NUMBER;
    l_return_status  VARCHAR2(10);
    l_err_resp       VARCHAR2(32767);
    exchttp          EXCEPTION;
    i                NUMBER;
    l_debug_prefix   VARCHAR2(30) := '';
  BEGIN
    --enable_debug;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.get_spatial_coords (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_return_status := fnd_api.g_ret_sts_success;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    lxml := location_xml(p_loc_array     => p_loc_array,
                         p_name          => p_name,
                         p_provider      => 'ELOCATION',
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

    status_handler(l_return_status, x_return_status);

    IF lxml IS NOT NULL THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_http_pkg.post (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;
      cpt := 0;
      LOOP
        cpt := cpt + 1;
        hz_http_pkg.post(
         doc               => lxml,
         content_type      =>'application/x-www-form-urlencoded',
         url               => p_http_ad,
         resp              => lresp,
         resp_content_type => lrespct,
         proxyserver       => p_proxy,
         proxyport         => p_port,
         err_resp          => l_err_resp,
         x_return_status   => l_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data);
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	  IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'hz_http_pkg.post failed',
	                           p_prefix=>'UNEXPECTED ERROR',
			           p_msg_level=>fnd_log.level_error);
          END IF;
	  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'hz_http_pkg.post (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
	  END IF;
          RAISE exchttp;
       END IF;
       EXIT WHEN lresp IS NOT NULL;
       EXIT WHEN cpt > p_retry;
      END LOOP;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug(p_message=>'hz_http_pkg.post (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;


      IF lresp IS NULL THEN
        -- The post did not succeed, even after several retries.  This is an
        -- unrecoverable error.
        l_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('AR','HZ_HTTP_POST_FAILED');
        fnd_message.set_token('RETRY', p_retry);
        fnd_message.set_token('LASTMSG', NVL(l_err_resp, '<NULL>'));
        fnd_msg_pub.add;

        -- Set the error status for all records in this batch
        FOR i IN 1..p_loc_array.COUNT LOOP
          p_loc_array(i).geometry_status_code := g_error;
        END LOOP;
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Null response',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;
        status_handler(l_return_status, x_return_status);
      ELSIF UPPER(lresp) NOT LIKE '%<GEOCODE_RESPONSE>%' THEN
        -- Spatial response was not parseable.  This is an unrecoverable error.
        l_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_message.set_name('AR','HZ_MALFORMED_SPATIAL_RESPONSE');
        -- limit the size of token to 200 characters, otherwise if lresp is too
        -- long, will get buffer too small error
        fnd_message.set_token('RESP', substrb(lresp,1,200));
        fnd_msg_pub.add;

        -- Set the error status for all records in this batch
        FOR i IN 1..p_loc_array.COUNT LOOP
          p_loc_array(i).geometry_status_code := g_error;
        END LOOP;
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Malformed response: '||SUBSTRB(lresp, 1, 200),
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;
        status_handler(l_return_status, x_return_status);
      ELSE
        get_response_lines(
          p_str       => lresp,
          p_lines     => ltab,
          p_temp_sta  => 'geocode',
          p_temp_end  => '</GEOCODE>',
          p_root_text => '<GEOCODE_RESPONSE>',
          p_provider  => 'ELOCATION',
          p_loc_array => p_loc_array
        );

        IF ltab.COUNT = 0 THEN
          -- Set the error status for all records in this batch since no rows
          -- were returned by the data provider.
          FOR i IN 1..p_loc_array.COUNT LOOP
            p_loc_array(i).geometry_status_code := g_error;
          END LOOP;

	  IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>g_pkg_name||'.get_response_lines returned 0 rows',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	  END IF;
        ELSE
          parse_responses(
            p_tab_address   => ltab,
            p_loc_array     => p_loc_array,
            x_return_status => l_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data
          );

          status_handler(l_return_status, x_return_status);
        END IF;
      END IF;
    END IF;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>g_pkg_name||'.get_spatial_coords (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --disable_debug;
  EXCEPTION
    WHEN exchttp THEN
      status_handler(l_return_status, x_return_status);
      --disable_debug;
  END get_spatial_coords;

END hz_geocode_pkg;

/
