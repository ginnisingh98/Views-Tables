--------------------------------------------------------
--  DDL for Package Body HZ_GNR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GNR_PUB" AS
/*$Header: ARHGNRPB.pls 120.9 2006/06/16 18:34:36 nsinghai noship $ */

  -----------------------------------------------------------------------------+
  -- Package variables
  -----------------------------------------------------------------------------+
  l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRPB:HZ_GNR_PUB';
  l_module                 VARCHAR2(30) ;
  l_debug_prefix           VARCHAR2(30) ;

PROCEDURE process_gnr (
    p_location_table_name  IN         VARCHAR2,
    p_location_id          IN         NUMBER,
    p_call_type            IN         VARCHAR2,
    p_init_msg_list        IN         VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2) IS

    l_return_status   VARCHAR2(1);
    l_addr_val_level  VARCHAR2(30);
    l_addr_warn_msg   VARCHAR2(2000);
    l_addr_val_status VARCHAR2(1);

    CURSOR c_loc_hz (p_location_id in number) IS
    SELECT
      LOCATION_ID,
      ADDRESS_STYLE,
      COUNTRY,
      STATE,
      PROVINCE,
      COUNTY,
      CITY,
      POSTAL_CODE,
      POSTAL_PLUS4_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10
    FROM HZ_LOCATIONS WHERE LOCATION_ID = p_location_id;

  BEGIN
    -- initializing the retun value
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF upper(p_location_table_name) = 'HR_LOCATIONS_ALL' THEN

      IF p_call_type = 'U' THEN
        HZ_GNR_PKG.delete_gnr(
                 p_locId       => p_location_id,
                 p_locTbl      => upper(p_location_table_name),
                 x_status      => l_return_status
                 );
      END IF;
      HZ_GNR_PKG.validateHrLoc(
                 P_LOCATION_ID => p_location_id,
                 X_STATUS      => l_return_status);

    ELSIF upper(p_location_table_name) = 'HZ_LOCATIONS' THEN

      IF p_call_type = 'U' THEN
        HZ_GNR_PKG.delete_gnr(
                 p_locId       => p_location_id,
                 p_locTbl      => upper(p_location_table_name),
                 x_status      => l_return_status
                 );
      END IF;

      FOR l_c_loc_hz in c_loc_hz(p_location_id)  LOOP
        HZ_GNR_PKG.validateLoc(
          P_LOCATION_ID               => l_c_loc_hz.LOCATION_ID,
          P_USAGE_CODE                => 'ALL',
          P_ADDRESS_STYLE             => l_c_loc_hz.ADDRESS_STYLE,
          P_COUNTRY                   => l_c_loc_hz.COUNTRY,
          P_STATE                     => l_c_loc_hz.STATE,
          P_PROVINCE                  => l_c_loc_hz.PROVINCE,
          P_COUNTY                    => l_c_loc_hz.COUNTY,
          P_CITY                      => l_c_loc_hz.CITY,
          P_POSTAL_CODE               => l_c_loc_hz.POSTAL_CODE,
          P_POSTAL_PLUS4_CODE         => l_c_loc_hz.POSTAL_PLUS4_CODE,
          P_ATTRIBUTE1                => l_c_loc_hz.ATTRIBUTE1,
          P_ATTRIBUTE2                => l_c_loc_hz.ATTRIBUTE2,
          P_ATTRIBUTE3                => l_c_loc_hz.ATTRIBUTE3,
          P_ATTRIBUTE4                => l_c_loc_hz.ATTRIBUTE4,
          P_ATTRIBUTE5                => l_c_loc_hz.ATTRIBUTE5,
          P_ATTRIBUTE6                => l_c_loc_hz.ATTRIBUTE6,
          P_ATTRIBUTE7                => l_c_loc_hz.ATTRIBUTE7,
          P_ATTRIBUTE8                => l_c_loc_hz.ATTRIBUTE8,
          P_ATTRIBUTE9                => l_c_loc_hz.ATTRIBUTE9,
          P_ATTRIBUTE10               => l_c_loc_hz.ATTRIBUTE10,
          P_CALLED_FROM               => 'GNR',
          X_ADDR_VAL_LEVEL            => l_addr_val_level,
          X_ADDR_WARN_MSG             => l_addr_warn_msg,
          X_ADDR_VAL_STATUS           => l_addr_val_status,
          X_STATUS                    => l_return_status);
      END LOOP;

    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN
       x_return_status := 'U';
  END process_gnr;

  -- Function to fetch address validation level after considering both product level
  -- profile and country level setting.
  -- If country level profile is not set or set to no validation, then application
  -- level profile will be ignored.
  FUNCTION get_addr_val_level(p_country_code IN VARCHAR2) RETURN VARCHAR2 IS

    l_addr_val_level varchar2(30);
    l_addr_val_level_temp varchar2(30);

    CURSOR c_addr_val(p_country_code IN VARCHAR2) IS
    select ADDR_VAL_LEVEL
    from hz_geo_structure_levels
    where PARENT_GEOGRAPHY_TYPE = 'COUNTRY'
    and  COUNTRY_CODE = p_country_code;
  BEGIN
    OPEN c_addr_val(p_country_code);
    FETCH c_addr_val INTO l_addr_val_level;
    CLOSE c_addr_val;

    -- Fix for Bug 4970612 added by nsinghai on 25-Jan-2006
    -- If country setting is NO VALIDATION, then ignore application level profile
    IF ((l_addr_val_level IS NULL) OR (l_addr_val_level = 'NONE'))THEN
      RETURN 'NONE';
    END IF;
    -- For validation level NONE, it will return from above. So do not need to
    -- check the same in next condition
    IF (l_addr_val_level IS NOT NULL) THEN
      l_addr_val_level_temp := FND_PROFILE.value( 'HZ_APP_ADDR_VAL');
    END IF;
    IF l_addr_val_level_temp IS NOT NULL THEN
      RETURN l_addr_val_level_temp;
    END IF;
    RETURN l_addr_val_level;
  END get_addr_val_level;

  PROCEDURE get_addr_val_status(
    p_location_table_name  IN         VARCHAR2,
    p_location_id          IN         NUMBER,
    p_usage_code           IN         VARCHAR2,
    x_is_validated          OUT NOCOPY VARCHAR2,
    x_address_status       OUT NOCOPY VARCHAR2) IS

    l_address_status   VARCHAR2(30);

    CURSOR c_gnr IS
    SELECT MAP_STATUS
    FROM   HZ_GEO_NAME_REFERENCE_LOG
    WHERE  LOCATION_TABLE_NAME = p_location_table_name
    AND    LOCATION_ID = p_location_id
    AND    USAGE_CODE = p_usage_code;
  BEGIN
    OPEN c_gnr;
    FETCH c_gnr INTO l_address_status;
      IF c_gnr%NOTFOUND THEN
        x_is_validated := FND_API.G_FALSE;
      ELSE
        x_is_validated := FND_API.G_TRUE;
        x_address_status := l_address_status;
      END IF;
    CLOSE c_gnr;
  END get_addr_val_status;

  PROCEDURE validateLoc (
    p_location_id          IN         NUMBER,
    p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
    x_addr_val_level       OUT NOCOPY VARCHAR2,
    x_addr_warn_msg        OUT NOCOPY VARCHAR2,
    x_addr_val_status      OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
	p_create_gnr_record    IN  VARCHAR2) IS

    l_location_id NUMBER;

    CURSOR c_loc (p_location_id in number) IS
    SELECT
      LOCATION_ID,
      ADDRESS_STYLE,
      COUNTRY,
      STATE,
      PROVINCE,
      COUNTY,
      CITY,
      POSTAL_CODE,
      POSTAL_PLUS4_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10
    FROM HZ_LOCATIONS WHERE LOCATION_ID = p_location_id;

  BEGIN

    -- Fix for Bug 5262208 (07-JUN-2006 Nishant). Added new parameter p_create_gnr_record
    -- If p_create_gnr_record is passed as N in this signature of validateLoc, then
    -- we will pass location id as NULL, so that it does not create GNR record and
    -- only does address validation. If Y is passed, GNR will be created.
    IF (NVL(p_create_gnr_record,'Y') <> 'N') THEN
      l_location_id := p_location_id;
    ELSE
      l_location_id := NULL;
    END IF;

    FOR l_c_loc in c_loc(p_location_id) LOOP
      validateLoc(
        P_LOCATION_ID               => l_location_id,
        P_USAGE_CODE                => 'GEOGRAPHY',
        P_ADDRESS_STYLE             => l_c_loc.ADDRESS_STYLE,
        P_COUNTRY                   => l_c_loc.COUNTRY,
        P_STATE                     => l_c_loc.STATE,
        P_PROVINCE                  => l_c_loc.PROVINCE,
        P_COUNTY                    => l_c_loc.COUNTY,
        P_CITY                      => l_c_loc.CITY,
        P_POSTAL_CODE               => l_c_loc.POSTAL_CODE,
        P_POSTAL_PLUS4_CODE         => l_c_loc.POSTAL_PLUS4_CODE,
        P_ATTRIBUTE1                => l_c_loc.ATTRIBUTE1,
        P_ATTRIBUTE2                => l_c_loc.ATTRIBUTE2,
        P_ATTRIBUTE3                => l_c_loc.ATTRIBUTE3,
        P_ATTRIBUTE4                => l_c_loc.ATTRIBUTE4,
        P_ATTRIBUTE5                => l_c_loc.ATTRIBUTE5,
        P_ATTRIBUTE6                => l_c_loc.ATTRIBUTE6,
        P_ATTRIBUTE7                => l_c_loc.ATTRIBUTE7,
        P_ATTRIBUTE8                => l_c_loc.ATTRIBUTE8,
        P_ATTRIBUTE9                => l_c_loc.ATTRIBUTE9,
        P_ATTRIBUTE10               => l_c_loc.ATTRIBUTE10,
        X_ADDR_VAL_LEVEL            => x_addr_val_level,
        X_ADDR_WARN_MSG             => x_addr_warn_msg,
        X_ADDR_VAL_STATUS           => x_addr_val_status,
        X_RETURN_STATUS             => x_return_status,
        X_MSG_COUNT                 => x_msg_count,
        X_MSG_DATA                  => x_msg_data);
     END LOOP;
  END validateLoc;

  PROCEDURE validateLoc(
    p_location_id               IN NUMBER,
    p_init_msg_list             IN VARCHAR2,
    p_usage_code                IN VARCHAR2,
    p_address_style             IN VARCHAR2,
    p_country                   IN VARCHAR2,
    p_state                     IN VARCHAR2,
    p_province                  IN VARCHAR2,
    p_county                    IN VARCHAR2,
    p_city                      IN VARCHAR2,
    p_postal_code               IN VARCHAR2,
    p_postal_plus4_code         IN VARCHAR2,
    p_attribute1                IN VARCHAR2,
    p_attribute2                IN VARCHAR2,
    p_attribute3                IN VARCHAR2,
    p_attribute4                IN VARCHAR2,
    p_attribute5                IN VARCHAR2,
    p_attribute6                IN VARCHAR2,
    p_attribute7                IN VARCHAR2,
    p_attribute8                IN VARCHAR2,
    p_attribute9                IN VARCHAR2,
    p_attribute10               IN VARCHAR2,
    x_addr_val_level            OUT NOCOPY VARCHAR2,
    x_addr_warn_msg             OUT NOCOPY VARCHAR2,
    x_addr_val_status           OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2) IS

    l_status            VARCHAR2(1);
    l_msg_count_before  NUMBER;
    l_msg_count_after   NUMBER;
    l_message_text      VARCHAR2(1000);

  BEGIN
    l_module := 'validateLoc';

    -- read the count of messages already stacked before doing validation
    l_msg_count_before := NVL(fnd_msg_pub.Count_Msg,0);

    HZ_GNR_PKG.validateLoc(
      P_LOCATION_ID               => P_LOCATION_ID,
      P_USAGE_CODE                => P_USAGE_CODE,
      P_ADDRESS_STYLE             => P_ADDRESS_STYLE,
      P_COUNTRY                   => P_COUNTRY,
      P_STATE                     => P_STATE,
      P_PROVINCE                  => P_PROVINCE,
      P_COUNTY                    => P_COUNTY,
      P_CITY                      => P_CITY,
      P_POSTAL_CODE               => P_POSTAL_CODE,
      P_POSTAL_PLUS4_CODE         => P_POSTAL_PLUS4_CODE,
      P_ATTRIBUTE1                => P_ATTRIBUTE1,
      P_ATTRIBUTE2                => P_ATTRIBUTE2,
      P_ATTRIBUTE3                => P_ATTRIBUTE3,
      P_ATTRIBUTE4                => P_ATTRIBUTE4,
      P_ATTRIBUTE5                => P_ATTRIBUTE5,
      P_ATTRIBUTE6                => P_ATTRIBUTE6,
      P_ATTRIBUTE7                => P_ATTRIBUTE7,
      P_ATTRIBUTE8                => P_ATTRIBUTE8,
      P_ATTRIBUTE9                => P_ATTRIBUTE9,
      P_ATTRIBUTE10               => P_ATTRIBUTE10,
      P_CALLED_FROM               => 'VALIDATE',
      P_LOCK_FLAG                 => FND_API.G_TRUE,
      X_ADDR_VAL_LEVEL            => x_addr_val_level,
      X_ADDR_WARN_MSG             => x_addr_warn_msg,
      X_ADDR_VAL_STATUS           => x_addr_val_status,
      X_STATUS                    => l_status);

      l_msg_count_after := NVL(fnd_msg_pub.Count_Msg,0);
      x_msg_count       := l_msg_count_after;
      x_return_status   := l_status;

      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
           (p_message       => 'After HZ_GNR_PKG.validateLoc. l_msg_count_before:'||
		                       l_msg_count_before||':l_msg_count_after:'||l_msg_count_after||
							   ':x_return_status:'||x_return_status||':x_addr_val_status:'||
							   x_addr_val_status,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;

      -- Get warning as well as stacked message out in x_msg_data parameter
      -- This is for ease of use for other teams which can read only x_msg_data
      -- for output of message text for Warning as well as Error case.
      -- Message stack is not being cleared, so that if some one wants to read that
      -- data, it is still available.
      -- Nishant (for Bug 5262208 + convenience method as discussion with Vivek and Vinoo)
      -- (15-Jun-2006)
      IF (l_status = FND_API.G_RET_STS_SUCCESS AND
           x_addr_val_status = 'W') THEN
          x_msg_data := x_addr_warn_msg;
      ELSIF
         (l_status <> FND_API.G_RET_STS_SUCCESS) THEN

  	     IF (l_msg_count_after > l_msg_count_before) THEN
           FOR i IN l_msg_count_before+1..l_msg_count_after LOOP
             l_message_text := SUBSTR(l_message_text||fnd_msg_pub.get(p_msg_index => i  ,
	                                                p_encoded	=> 'F'),1,1000);
           END LOOP;
           x_msg_data := l_message_text;
		 END IF;
      END IF;

      IF (x_addr_val_status IS NULL) THEN
        x_addr_val_status := l_status;
      END IF;

      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
           (p_message       => 'l_status:'||l_status||':x_msg_data:'||x_msg_data,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;

  EXCEPTION WHEN
    OTHERS THEN
      IF (l_status IS NOT NULL) THEN
        x_return_status := l_status;
      ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (x_addr_val_status IS NULL) THEN
        x_addr_val_status := x_return_status;
      END IF;

      IF (l_status = FND_API.G_RET_STS_SUCCESS AND
           x_addr_val_status = 'W') THEN
          x_msg_data := x_addr_warn_msg;
      ELSE

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        --Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data );

      END IF;

      -- FND Logging for debug purpose
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
           (p_message       => 'EXCEPTION :'||SQLERRM,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_exception,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;

  END validateLoc;

END HZ_GNR_PUB;

/
