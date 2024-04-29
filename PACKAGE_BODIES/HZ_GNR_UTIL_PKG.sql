--------------------------------------------------------
--  DDL for Package Body HZ_GNR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GNR_UTIL_PKG" AS
/*$Header: ARHGNRUB.pls 120.33.12010000.2 2009/02/16 06:52:37 rgokavar ship $ */


  --------------------------------------
   -- declaration of private global varibles
   --------------------------------------

   g_debug_count   NUMBER := 0;
   --g_debug         BOOLEAN := FALSE;

   --------------------------------------
   -- declaration of private procedures and functions
   --------------------------------------

   /*PROCEDURE enable_debug;

   PROCEDURE disable_debug;
   */

   --------------------------------------
   -- private procedures and functions
   --------------------------------------

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
  END enable_debug;      -- end procedure
  */
  --------------------------------------
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
/**
  Function : gnr_exists

  DESCRIPTION :
     Function to tell if the GNR already processed for a given
     location record or not.

  ARGUMENTS  :
     IN   p_location_id NUMBER
     IN   p_location_table_name VARCHAR2

  RETURNS : BOOLEAN
     TRUE  : If GNR exists
     FALSE : If GNR does not exists

   MODIFICATION HISTORY:
   17-FEB-2006   Baiju.nair    Created

**/
  FUNCTION gnr_exists(p_location_id IN NUMBER,
                      p_location_table_name IN VARCHAR2) RETURN BOOLEAN IS

    CURSOR c_gnr IS
    SELECT MAP_STATUS
    FROM   HZ_GEO_NAME_REFERENCE_LOG
    WHERE  LOCATION_TABLE_NAME = p_location_table_name
    AND    LOCATION_ID = p_location_id;

    l_address_status   VARCHAR2(30);
    l_return_value     BOOLEAN;

  BEGIN

    OPEN c_gnr;
    FETCH c_gnr INTO l_address_status;
      IF c_gnr%NOTFOUND THEN
        l_return_value := FALSE;
      ELSE
        l_return_value := TRUE;
      END IF;
    CLOSE c_gnr;

    RETURN l_return_value;

  END gnr_exists;

  --------------------------------------

/**
  Function : location_updation_allowed

  DESCRIPTION :
     Function to tell if the location can be updated or not. It directly calls
     ARH_ADDR_PKG.check_tran_for_all_accts to do this validation. This function is
     just a wrapper for ease of use in GNR code

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED :
     ARH_ADDR_PKG

  ARGUMENTS  :
     IN   p_location_id NUMBER

  RETURNS : BOOLEAN
     TRUE  : Location updation is allowed
     FALSE : Location updation is not allowed

   MODIFICATION HISTORY:
   16-FEB-2006   Nishant Singhai    Created

**/
  FUNCTION location_updation_allowed(p_location_id IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    -- Tax location Validation
    IF ARH_ADDR_PKG.check_tran_for_all_accts(p_location_id) THEN
      -- Transaction exists
      RETURN FALSE;
    ELSE
      -- Transaction does not exists. OK to update location.
      RETURN TRUE;
    END IF;
  END location_updation_allowed;

/**
   Procedure : pre_location_update

  DESCRIPTION :
    Procedure to do pre-update processing for a given location record. This will
    be used in GNR program, where it updates the location components.

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED :
     HZ_LOCATION_V2PUB
     hz_fuzzy_pub
     hz_timezone_pub

  ARGUMENTS  :
     IN      p_old_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE

     IN OUT  p_new_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
     IN OUT  p_other_location_params HZ_GNR_UTIL_PKG.location_other_param_rec_type
	         (extendible - for future use)

   MODIFICATION HISTORY:
     16-FEB-2006   Nishant Singhai    Created
**/
PROCEDURE pre_location_update (
     p_old_location_rec      IN            HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_new_location_rec      IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_other_location_params IN OUT NOCOPY HZ_GNR_UTIL_PKG.loc_other_param_rec_type,
     x_return_status         OUT NOCOPY    VARCHAR2,
     x_msg_count             OUT NOCOPY    NUMBER,
     x_msg_data              OUT NOCOPY    VARCHAR2
) IS

l_changed_flag    VARCHAR2(10);
l_message_count   NUMBER;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1000);
l_return_status   VARCHAR2(30);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get timezone id for changed location, if timezone_id is NULL
  -- Same code as in HZ_LOCATION_V2PUB.UPDATE_LOCATION (to make it modular)
   IF (p_new_location_rec.country IS NOT NULL AND
        NVL(UPPER(p_old_location_rec.country), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.country))
     OR (p_new_location_rec.city IS NOT NULL AND
         NVL(UPPER(p_old_location_rec.city), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.city))
     OR (p_new_location_rec.state IS NOT NULL AND
         NVL(UPPER(p_old_location_rec.state), fnd_api.g_miss_char)<> UPPER(p_new_location_rec.state))
     OR (p_new_location_rec.postal_code IS NOT NULL AND
         NVL(UPPER(p_old_location_rec.postal_code), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.postal_code))
   THEN
     l_changed_flag := 'Y';
   END IF;

   IF ((l_changed_flag = 'Y') AND
       (p_new_location_rec.timezone_id IS NULL
	    OR p_new_location_rec.timezone_id = fnd_api.g_miss_num)
	   )
   THEN

        l_message_count := fnd_msg_pub.count_msg();
        hz_timezone_pub.get_timezone_id(
                p_api_version   => 1.0,
                p_init_msg_list => FND_API.G_FALSE,
                p_postal_code   => p_new_location_rec.postal_code,
                p_city          => p_new_location_rec.city,
                p_state         => p_new_location_rec.state,
                p_country       => p_new_location_rec.country,
                x_timezone_id   => p_new_location_rec.timezone_id,
                x_return_status => l_return_status ,
                x_msg_count     => l_msg_count ,
                x_msg_data      => l_msg_data);

                IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                  -- we don't raise error
                  p_new_location_rec.timezone_id := fnd_api.g_miss_num;
                  FOR i IN 1..(l_msg_count - l_message_count) LOOP
                     fnd_msg_pub.delete_msg(l_msg_count - l_message_count + 1 - i);
                  END LOOP;
                  l_return_status := FND_API.G_RET_STS_SUCCESS;
                END IF;
   END IF;

    -- call address key generation program
    p_new_location_rec.address_key := hz_fuzzy_pub.generate_key (
						               'ADDRESS',
						               NULL,
						               p_new_location_rec.address1,
						               p_new_location_rec.address2,
						               p_new_location_rec.address3,
						               p_new_location_rec.address4,
						               p_new_location_rec.postal_code,
						               NULL,
						               NULL
						             );

   -- x_return_status to be ignored as it it be always success
   x_return_status :=  l_return_status;

EXCEPTION WHEN OTHERS THEN
  NULL;
END pre_location_update;

/**
   Procedure : post_location_update

  DESCRIPTION :
    Procedure to do post-update processing for a given location record. This will
    be used in GNR program, where it updates the location components.

  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED :
     HZ_LOCATION_V2PUB
     HZ_UTILITY_V2PUB
     HZ_DQM_SYNC
     HZ_BUSINESS_EVENT_V2PVT
     HZ_POPULATE_BOT_PKG

  ARGUMENTS  :
     IN      p_old_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE

     IN OUT  p_new_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
     IN OUT  p_other_location_params HZ_GNR_UTIL_PKG.location_other_param_rec_type
	         (extendible - for future use)

   MODIFICATION HISTORY:
     16-FEB-2006   Nishant Singhai    Created
**/
PROCEDURE post_location_update (
     p_old_location_rec      IN            HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_new_location_rec      IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
     p_other_location_params IN OUT NOCOPY HZ_GNR_UTIL_PKG.loc_other_param_rec_type,
     x_return_status         OUT NOCOPY    VARCHAR2,
     x_msg_count             OUT NOCOPY    NUMBER,
     x_msg_data              OUT NOCOPY    VARCHAR2
) IS

  l_last_updated_by   NUMBER; -- hz_utility_v2pub.last_updated_by;
  l_creation_date     DATE;   -- hz_utility_v2pub.creation_date;
  l_created_by        NUMBER; -- hz_utility_v2pub.created_by;
  l_last_update_date  DATE;   -- hz_utility_v2pub.last_update_date;
  l_last_update_login NUMBER; -- hz_utility_v2pub.last_update_login;
  l_program_id        NUMBER; -- hz_utility_v2pub.program_id;
  l_conc_login_id     NUMBER; -- fnd_global.conc_login_id;
  l_program_application_id NUMBER; --hz_utility_v2pub.program_application_id;
  l_request_id        NUMBER; -- NVL(hz_utility_v2pub.request_id, -1);
  l_program_update_date DATE; -- hz_utility_v2pub.program_update_date;

BEGIN

   -- Initialize variables (perf improvement bug 5130993)
   l_last_updated_by   := hz_utility_v2pub.last_updated_by;
   l_creation_date     := hz_utility_v2pub.creation_date;
   l_created_by        := hz_utility_v2pub.created_by;
   l_last_update_date  := hz_utility_v2pub.last_update_date;
   l_last_update_login := hz_utility_v2pub.last_update_login;
   l_program_id        := hz_utility_v2pub.program_id;
   l_conc_login_id     := fnd_global.conc_login_id;
   l_program_application_id := hz_utility_v2pub.program_application_id;
   l_request_id        := NVL(hz_utility_v2pub.request_id, -1);
   l_program_update_date := hz_utility_v2pub.program_update_date;

    -- update de-normalized location components in HZ_PARTIES for parties
    -- having this location as an identifying location. There can be multiple
    -- such parties.
      DECLARE
        l_party_id                   NUMBER;

        CURSOR c1 IS
          SELECT hps.party_id
          FROM   hz_party_sites hps
          WHERE  hps.location_id = p_new_location_rec.location_id
          AND    hps.identifying_address_flag = 'Y';
      BEGIN
        IF (p_new_location_rec.country IS NOT NULL AND
            NVL(UPPER(p_old_location_rec.country), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.country))
           OR (p_new_location_rec.address1 IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.address1),fnd_api.g_miss_char) <> UPPER(p_new_location_rec.address1))
           OR (p_new_location_rec.address2 IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.address2),fnd_api.g_miss_char) <> UPPER(p_new_location_rec.address2))
           OR (p_new_location_rec.address3 IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.address3),fnd_api.g_miss_char) <> UPPER(p_new_location_rec.address3))
           OR (p_new_location_rec.address4 IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.address4),fnd_api.g_miss_char) <> UPPER(p_new_location_rec.address4))
           OR (p_new_location_rec.city IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.city), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.city))
           OR (p_new_location_rec.postal_code IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.postal_code), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.postal_code))
           OR (p_new_location_rec.state IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.state), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.state))
           OR (p_new_location_rec.province IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.province),fnd_api.g_miss_char) <> UPPER(p_new_location_rec.province))
           OR (p_new_location_rec.county IS NOT NULL AND
               NVL(UPPER(p_old_location_rec.county), fnd_api.g_miss_char) <> UPPER(p_new_location_rec.county))
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
                                  p_prefix =>'INFO:',
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
                 SET    country     = p_new_location_rec.country,
                        address1    = p_new_location_rec.address1,
                        address2    = p_new_location_rec.address2,
                        address3    = p_new_location_rec.address3,
                        address4    = p_new_location_rec.address4,
                        city        = p_new_location_rec.city,
                        postal_code = p_new_location_rec.postal_code,
                        state       = p_new_location_rec.state,
                        province    = p_new_location_rec.province,
                        county      = p_new_location_rec.county,
                        last_update_date     = l_last_update_date,
                        last_updated_by      = l_last_updated_by,
                        last_update_login    = l_last_update_login,
                        request_id           = l_request_id,
                        program_id           = l_program_id,
                        program_application_id = l_program_application_id,
                        program_update_date  = l_program_update_date
                 WHERE  party_id = l_party_id;

              END IF; -- Only if address is not a Remit to.
            END LOOP;
            CLOSE c1;

          EXCEPTION
            WHEN OTHERS THEN
             /*
			  fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
              fnd_message.set_token('TABLE', 'HZ_PARTIES');
              fnd_msg_pub.add;
             */
              CLOSE c1;
             -- RAISE fnd_api.g_exc_error;
          END;
        END IF; -- location components have been modified
      END;

    -- Call to indicate location update to DQM
    HZ_DQM_SYNC.sync_location(p_new_location_rec.location_id,'U');

    -- Invoke business event system.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.
    --  l_old_location_rec.orig_system := p_location_rec.orig_system;
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_location_event (
          p_new_location_rec,
          p_old_location_rec);
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_locations(
          p_operation   => 'U',
          p_location_id => p_new_location_rec.location_id );
      END IF;

EXCEPTION WHEN OTHERS THEN
  NULL;
END post_location_update;
---------------------------------------

/**
 * procedure delGNR
 *
 * DESCRIPTION
 *    This is to delete the rows from GNR table
 *     for a given combination of location id and table
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *    None. Only gnrins and gnrl in this package
 *    procedure use this.
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   OUT:
 *   x_status   Y in case of success, otherwise error message name
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */
--------------------------------------
 PROCEDURE delGNR (
       p_locid       IN number,
       p_loctbl      IN varchar2,
       x_status      OUT NOCOPY varchar2
 ) IS

 BEGIN

   -- initializing the return status
   x_status := fnd_api.g_ret_sts_success;

   -- delete thing the location id and table name combination from gnr

   DELETE FROM hz_geo_name_references
   WHERE location_id = p_locid AND
           location_table_name = p_loctbl;
 EXCEPTION
 WHEN others THEN
     --dbms_output.put_line('error in del gnr' ||sqlerrm);
     x_status :=  fnd_api.g_ret_sts_unexp_error;
 END delGNR;
--------------------------------------
-- procedures and functions
--------------------------------------
/**
 * PROCEDURE getMapId
 *
 * DESCRIPTION
 *    This private procedure is used to gets the
 *    map identifier for a given location id, loc table name
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *
 *   OUT:
 *   x_mapId    map identifier
 *   x_status   Y in case of success, otherwise error message name
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */
 ----------------------------------------------
 PROCEDURE getMapId(
   p_locId       IN NUMBER,
   p_locTbl      IN VARCHAR2,
   x_cntry      OUT NOCOPY VARCHAR2,
   x_mapId      OUT NOCOPY NUMBER,
   x_status      OUT NOCOPY VARCHAR2
 ) IS

  l_addrstyle varchar2(30);
  l_sql1      varchar2(1000);
  l_eflag varchar2(2);

 BEGIN
     x_status := fnd_api.g_ret_sts_success; -- defaulting the sucess status.
 /* flow:
  1. getcntrystyle()
  2. if both addrstyle and country are not null,
     get mapId using both else use country
  */
  --dbms_output.put_line('***bfr getcntrystyle');
  hz_gnr_util_pkg.getcntrystyle(p_locid,p_loctbl,x_cntry,l_addrstyle,x_status);

  IF (x_status <> fnd_api.g_ret_sts_success) THEN
      -- there is some error in getcntrystyle(), hence exit
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  --dbms_output.put_line('***after getcntrystyle');

  -- as getcntrystyle() validates the country - in this procedure
  -- there is no need to validate it again.

  /* if performance mandates, the following execute immediate stmts against
     the map tbl can be converted into cursor stmts later.- srikanth
   */

   -- no data found can come from any of the three sqls in this procedure.
   -- hence, to identify them appropriately to give user friedly mesg
   -- l_eflag is used.

  IF (l_addrstyle IS NULL) THEN
    l_sql1 := 'select map_id from hz_geo_struct_map where loc_tbl_name =:tbl and
                country_code = :cntry and address_style is null';
    l_eflag := 'AN'; -- address style null case

    execute IMMEDIATE l_sql1 INTO x_mapId USING IN p_loctbl, x_cntry;
  ELSE
    l_sql1 := 'select map_id from hz_geo_struct_map where loc_tbl_name =:tbl and
             country_code = :cntry and address_style = :style';
    l_eflag := 'A'; -- address style case

    execute IMMEDIATE l_sql1 INTO x_mapId USING IN p_loctbl, x_cntry, l_addrstyle;
  END IF;

 EXCEPTION
  WHEN no_data_found THEN

    IF (l_eflag IS NULL) THEN
      -- no map details for given map record
      x_status :=  fnd_api.G_RET_STS_ERROR;
      --dbms_output.put_line('***bfr mesglog() in exception');
      mesglog(p_locid,p_loctbl,'HZ_GEO_NO_MAP_DTL', 'COUNTRY_CODE', x_cntry, NULL, NULL);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_eflag = 'AN') THEN
      -- address style case is null case
      x_status :=  fnd_api.G_RET_STS_ERROR;
      --dbms_output.put_line('***bfr mesglog() when address style is null');
      mesglog(p_locid,p_loctbl,'HZ_GEO_NOMAP', 'COUNTRY', x_cntry, NULL, NULL);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_eflag = 'A') THEN
      -- address style and country code combinatio does not exist
      x_status :=  fnd_api.G_RET_STS_ERROR;
      --dbms_output.put_line('***bfr mesglog() when address style is not null');
      mesglog(p_locid,p_loctbl,'HZ_GEO_NOMAP_ASTYLE', 'COUNTRY', x_cntry, 'STYLE', l_addrstyle);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 END getMapId;

-----------------------------------------

--------------------------------------
/**
 * procedure getmaprec
 *
 * description
 *     this private procedure is used to gets
 *     1. the map record for a given location.
 *     2. populates component values from loc rec
 *
 * external procedures/functions accessed
 *
 * arguments
 *   in:
 *
 *     p_locid               location identifier
 *     p_loctbl              location table
 *
 *   out:
 *
 *   x_mltbl   table of records that has
 *              geo element, type and loc components and their values
 *   x_status   y in case of success, otherwise error message name
 *   x_mapId   map identifier
 *   x_cntry   country code
 *
 * notes
 * following are the exceptions raised
 * hz_geo_nomap
 * hz_geo_nomap_astyle
 * HZ_GEO_NO_MAP_DTL
 * modification history
 *
 *
 */
 PROCEDURE getmaprec(
   p_locid       IN number,
   p_loctbl      IN varchar2,
   x_mltbl      OUT NOCOPY maploc_rec_tbl_type,
   x_mapId      OUT NOCOPY NUMBER,
   x_cntry    OUT NOCOPY varchar2,
   x_status     OUT NOCOPY varchar2
 )IS

  -- temp variable declaration
--  l_cntry     varchar2(2);
  l_addrstyle varchar2(30);
  l_sql1      varchar2(1000);
  l_mapdtl    hz_geo_struct_map_dtl%ROWTYPE;
  i           number;
  l_eflag varchar2(2);
  l_debug_prefix    VARCHAR2(30) := '';

  CURSOR c1 (cp_map_id number) IS
   SELECT loc_seq_num, loc_component,
          geography_type, geo_element_col
   FROM  hz_geo_struct_map_dtl
   WHERE map_id = cp_map_id
   ORDER BY loc_seq_num ASC;

 BEGIN
   x_status := fnd_api.g_ret_sts_success; -- defaulting the sucess status.
    -- Check if API is called in debug mode. If yes, enable debug.
       --enable_debug;

 /* flow:
  1. given a mapid , gte map details
  2. if both addrstyle and country are not null, get map rec using both
     else use country to fetch map rec
  3. getlocrec() is called to get the component details.
  */

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'bfr getMapId()',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

      hz_gnr_util_pkg.getMapId(p_locid, p_loctbl, x_cntry, x_mapId, x_status );

  -- given a mapid, get the details of the map
  IF (x_status <> fnd_api.g_ret_sts_success) THEN
   -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'getMapId() failed',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

      -- there is some error in getcntrystyle(), hence exit
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  i := 1;
  FOR c1rec IN c1(x_mapId)
  LOOP
      x_mltbl(i).loc_seq_num     := c1rec.loc_seq_num;
      x_mltbl(i).loc_component   := c1rec.loc_component;
      x_mltbl(i).geography_type  := c1rec.geography_type;
      x_mltbl(i).geo_element_col := c1rec.geo_element_col;
      i := i+1;
  END LOOP;
    --disable_debug;
 EXCEPTION
  WHEN no_data_found THEN

   -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'in getMapRec Exception blk. No data found',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

    RAISE FND_API.G_EXC_ERROR;
 END getmaprec;
-----------------------------------------
/**
 * procedure getlocrec
 *
 * description
 *     this private procedure is used to get
 * the location record. in addition, this would return
 *  country code address style of the location records
 *  in separate variables.
 *
 * external procedures/functions accessed
 *
 * arguments
 *   in:
 *
 *     p_locid               location identifier
 *     p_loctbl              location table
 *
 *   out:
 *
 *     x_cntry                country code
 *     x_addrstyle           address style
 *     x_hrla      rec type for hr_locations_all
 *     x_hzl       rec type for hz_locations
 *     x_po        rec type for po_vendor_sites_all
 *
 * exceptions raised
 *
 *  HZ_GEO_LOC_TABLE_INVALID
 *  hz_geo_invalid_country
 *  hz_geo_no_loc_rec
 *
 * notes
 *
 *
 * modification history
 *
 *
 */
 PROCEDURE getlocrec (
   p_locid     IN number,
   p_loctbl    IN varchar2,
   x_mltbl     IN OUT NOCOPY maploc_rec_tbl_type,
   x_status    OUT NOCOPY varchar2
 ) IS

 l_sql_1 varchar2(1000);
 l_len   number;
 l_debug_prefix  VARCHAR2(30) := '';

 BEGIN
   x_status := fnd_api.g_ret_sts_success; -- defaulting the sucess status.

   l_sql_1 := 'select ';
   FOR i IN x_mltbl.first..x_mltbl.last
   LOOP
     l_sql_1 := l_sql_1||x_mltbl(i).loc_component||',';
   END LOOP;
   l_sql_1 := SUBSTRB(l_sql_1, 1, LENGTHB(l_sql_1)-1);
   l_sql_1 := l_sql_1||' from '|| p_loctbl||' where ';

   -- Removed PO_VENDOR_SITES_ALL from the below if condition. Bug # 4584465
   --IF p_loctbl = 'PO_VENDOR_SITES_ALL' THEN
   -- check to see if theer are multiple rows for the same id.
   --   l_sql_1 := l_sql_1||' vendor_site_id = :id and rownum =1 ';
   --ELSE
   --  l_sql_1 := l_sql_1||' location_id = :id and rownum =1 ';
   --END IF;
   l_sql_1 := l_sql_1||' location_id = :id and rownum =1 ';

   l_len := x_mltbl.count;

   IF (l_len = 1) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval USING IN p_locid;
   ELSIF (l_len = 2) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 3) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 4) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 5) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval, x_mltbl(5).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 6) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval, x_mltbl(5).loc_compval, x_mltbl(6).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 7) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval, x_mltbl(5).loc_compval, x_mltbl(6).loc_compval,
     x_mltbl(7).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 8) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval, x_mltbl(5).loc_compval, x_mltbl(6).loc_compval,
     x_mltbl(7).loc_compval,x_mltbl(8).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 9) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval, x_mltbl(5).loc_compval, x_mltbl(6).loc_compval,
     x_mltbl(7).loc_compval,x_mltbl(8).loc_compval,x_mltbl(9).loc_compval
     USING IN p_locid;
   ELSIF (l_len = 10) THEN
     execute IMMEDIATE l_sql_1
     INTO x_mltbl(1).loc_compval, x_mltbl(2).loc_compval,x_mltbl(3).loc_compval,
     x_mltbl(4).loc_compval, x_mltbl(5).loc_compval, x_mltbl(6).loc_compval,
     x_mltbl(7).loc_compval,x_mltbl(8).loc_compval,x_mltbl(9).loc_compval
     ,x_mltbl(10).loc_compval
     USING IN p_locid;
   ELSE
     x_status :=  fnd_api.G_RET_STS_ERROR;
     mesglog(p_locid,p_loctbl,'HZ_GEO_TOO_MANY_MAP_DTLS', NULL, NULL, NULL, NULL);
     RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
 WHEN no_data_found THEN
   x_status :=  fnd_api.G_RET_STS_ERROR;
   mesglog(p_locid,p_loctbl,'HZ_GEO_NO_LOC_REC', 'LOC_ID',p_locid, 'TABLE_NAME', p_loctbl);
   RAISE FND_API.G_EXC_ERROR;
 END getlocrec;
-------------------------------------------
/**
 * procedure getcntrystyle
 *
 * description
 *     this private procedure is used to get the country code address style for a location.
 *
 * external procedures/functions accessed
 *
 * arguments
 *   in:
 *
 *     p_locid               location identifier
 *     p_loctbl              location table
 *
 *   out:
 *
 *     x_cntry                country code
 *     x_addrstyle           address style
 *
 * exceptions raised
 *
 *  HZ_GEO_LOC_TABLE_INVALID
 *  hz_geo_invalid_country
 *  hz_geo_no_loc_rec
 *
 * notes
 *
 *
 * modification history
 *
 *
 */

 PROCEDURE getcntrystyle (
       p_locid       IN number,
       p_loctbl      IN varchar2,
       x_cntry       OUT NOCOPY  varchar2,
       x_addrstyle   OUT  NOCOPY varchar2,
       x_status      OUT  NOCOPY varchar2
 ) IS

 l_sql_1 varchar2(500);
 l_sql_2 varchar2(500);
 l_sql_3 varchar2(500);
 l_sql_4 varchar2(300);
 l_tmp   number;
 l_len  number;
 l_debug_prefix    VARCHAR2(30) := '';

 BEGIN
 x_status := fnd_api.g_ret_sts_success; -- defaulting the sucess status.
    -- Check if API is called in debug mode. If yes, enable debug.
       --enable_debug;
 -- three sql statements are necessary depending for three location tables.
 -- the three tables are:
 --
 l_sql_3 := 'select country, style from hr_locations_all where location_id = :id and  rownum = 1 ';
 l_sql_2 := 'select country, address_style from hz_locations where location_id = :id and rownum =1 ';
-- l_sql_1 := 'select country, address_style from po_vendor_sites_all where vendor_site_id = :id and rownum =1 ';

 l_sql_4 := 'select 1 from fnd_territories f where f.territory_code = :code';

    -- Removed PO_VENDOR_SITES_ALL from the below if condition. Bug # 4584465
    --IF p_loctbl = 'PO_VENDOR_SITES_ALL' THEN
       -- Debug info.
    --   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    --	   hz_utility_v2pub.debug(p_message=>'***sql for po_vendor_sites:'||l_sql_1,
    --			          p_prefix =>l_debug_prefix,
    --			          p_msg_level=>fnd_log.level_statement);
    --      END IF;
    --     execute IMMEDIATE l_sql_1 INTO x_cntry, x_addrstyle USING IN p_locid;
    IF p_loctbl = 'HZ_LOCATIONS' THEN
       -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'***sql for hz_locations'||l_sql_2,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;
       execute IMMEDIATE l_sql_2 INTO x_cntry, x_addrstyle USING IN p_locid;
    ELSIF p_loctbl = 'HR_LOCATIONS_ALL' THEN
       -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'***sql for HR_LOCATIONS_ALL'||l_sql_3,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;
       execute IMMEDIATE l_sql_3 INTO x_cntry, x_addrstyle USING IN p_locid;
    ELSE
      -- this means that the supplied table name is not supported by gnr in hz.k
      x_status :=  fnd_api.G_RET_STS_ERROR;
       -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'***bfr mesglog() when tbl name is invalid',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      mesglog(p_locid,p_loctbl,'HZ_GEO_LOC_TABLE_INVALID', NULL, NULL, NULL, NULL);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (x_cntry IS NULL) THEN
       -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'country code is null',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
       END IF;
       x_status :=  fnd_api.G_RET_STS_ERROR;
       mesglog(p_locid,p_loctbl,'HZ_GEO_INVALID_COUNTRY', 'LOC_ID',p_locid, 'TABLE_NAME', p_loctbl);
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       l_len := LENGTHB(x_cntry);
       IF l_len = 2 THEN
          execute IMMEDIATE l_sql_4 INTO l_tmp USING IN x_cntry;
          IF (l_tmp <> 1) THEN
            x_status :=  fnd_api.G_RET_STS_ERROR;
               mesglog(p_locid,p_loctbl,'HZ_GEO_INVALID_COUNTRY', 'LOC_ID',p_locid, 'TABLE_NAME', p_loctbl);
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       ELSE
         x_status :=  fnd_api.G_RET_STS_ERROR;
         mesglog(p_locid,p_loctbl,'HZ_GEO_INVALID_COUNTRY', 'LOC_ID',p_locid, 'TABLE_NAME', p_loctbl);
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --disable_debug;
EXCEPTION
 WHEN no_data_found THEN
   x_status :=  fnd_api.G_RET_STS_ERROR;
       -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'***bfr mesglog() in no data found',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
   mesglog(p_locid,p_loctbl,'HZ_GEO_NO_LOC_REC', 'LOC_ID',p_locid, 'TABLE_NAME', p_loctbl);
   RAISE FND_API.G_EXC_ERROR;

 END getcntrystyle;
----------------------------------------------------

/**
 * procedure gnrins
 *
 * description
 *     this private procedure is used to insert or update the
 *     gnr table.
 *     this procedure will update if the same location id and
 *     geography id combination is existing otherwise this will insert.
 *
 * external procedures/functions accessed
 *
 * arguments
 *   in:
 *
 *     p_locid               location identifier
 *     p_loctbl              location table
 *
 *     p_maptbl   table of records that has location sequence number,
 *              geo element, type and loc components and their values
 *
 *   out:
 *
 *     x_status       procedure status
 *
 *
 * exceptions raised
 *
 *
 * notes
 *
 *
 * modification history
 *
 *
 */
-----------------------------------------------------------
 PROCEDURE gnrins (
       p_locid       IN number,
       p_loctbl      IN varchar2,
       p_maptbl      IN maploc_rec_tbl_type,
       x_status      OUT NOCOPY varchar2
 ) IS
 l_debug_prefix    VARCHAR2(30) := '';

  l_last_updated_by   NUMBER; -- hz_utility_v2pub.last_updated_by;
  l_creation_date     DATE;   -- hz_utility_v2pub.creation_date;
  l_created_by        NUMBER; -- hz_utility_v2pub.created_by;
  l_last_update_date  DATE;   -- hz_utility_v2pub.last_update_date;
  l_last_update_login NUMBER; -- hz_utility_v2pub.last_update_login;
  l_program_id        NUMBER; -- hz_utility_v2pub.program_id;
  l_conc_login_id     NUMBER; -- fnd_global.conc_login_id;
  l_program_application_id NUMBER; --hz_utility_v2pub.program_application_id;
  l_request_id        NUMBER; -- NVL(hz_utility_v2pub.request_id, -1);

 BEGIN

   /*
   flow:
   1. delete the locId and locTbl combination
   2. loop through the table of records and insert
   */

  -- Initialize variables (perf improvement bug 5130993)
  l_last_updated_by   := hz_utility_v2pub.last_updated_by;
  l_creation_date     := hz_utility_v2pub.creation_date;
  l_created_by        := hz_utility_v2pub.created_by;
  l_last_update_date  := hz_utility_v2pub.last_update_date;
  l_last_update_login := hz_utility_v2pub.last_update_login;
  l_program_id        := hz_utility_v2pub.program_id;
  l_conc_login_id     := fnd_global.conc_login_id;
  l_program_application_id := hz_utility_v2pub.program_application_id;
  l_request_id        := NVL(hz_utility_v2pub.request_id, -1);

   -- initializing the return status
   x_status := fnd_api.g_ret_sts_success;

    -- Check if API is called in debug mode. If yes, enable debug.
       --enable_debug;


   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'deleting loc id, table name combo from gnr',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'bfr delgnr()',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

   -- delete thing the location id and table name combination from gnr
 delgnr(p_locid,p_loctbl,x_status);

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'aft delGnr()',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

   IF x_status = FND_API.G_RET_STS_SUCCESS THEN
      FOR i IN p_maptbl.first .. p_maptbl.last
      LOOP
       IF (x_status = FND_API.G_RET_STS_SUCCESS) AND
          (p_maptbl(i).geography_id IS NOT NULL) THEN
        BEGIN
           INSERT INTO hz_geo_name_references
             (location_id, geography_id, location_table_name,
             object_version_number, geography_type, last_updated_by,
             creation_date, created_by, last_update_date,
             last_update_login, program_id, program_login_id,
             program_application_id,request_id)
           VALUES
             (p_locid, p_maptbl(i).geography_id,p_loctbl,
             1, p_maptbl(i).geography_type, l_last_updated_by,
             l_creation_date, l_created_by,
             l_last_update_date, l_last_update_login,
             l_program_id, l_conc_login_id,
             l_program_application_id, l_request_id);
         --disable_debug;
         EXCEPTION
         WHEN others THEN

           -- Debug info.
	       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		  hz_utility_v2pub.debug(p_message=>'error in ins gnr rec',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	       END IF;
	       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		   hz_utility_v2pub.debug(p_message=>'loc id:'||p_locid,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		   hz_utility_v2pub.debug(p_message=>'loc tbl:'||p_loctbl,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		   hz_utility_v2pub.debug(p_message=>'loc comp type:'||p_maptbl(i).geography_type,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
		   hz_utility_v2pub.debug(p_message=>'loc comp geo id:'||p_maptbl(i).geography_id,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	       END IF;

           x_status :=  fnd_api.g_ret_sts_unexp_error;
         END;
       END IF;
      END LOOP;
   ELSE
     x_status :=  fnd_api.g_ret_sts_unexp_error;
   END IF;
    --disable_debug;
 EXCEPTION
 WHEN others THEN

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'in gnrIns() excep blk',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'sqlerrm:'||sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

   x_status :=  fnd_api.g_ret_sts_unexp_error;
 END gnrins;
 -----------------------------------------------------------
/**
 * procedure gnrl
 *
 * description
 *     this private procedure is used to insert or update the
 *     gnr log table. this log table will be updated irrespective
 *     of whether the gnring of a location record is sucessfull or not.
 *
 * external procedures/functions accessed
 *
 * arguments
 *   in:
 *     p_locid        location identifier
 *     p_loctbl       location table
 *     p_mapstatus    sucess, error or warning
 *   in out:
 *     x_status       procedure return status/message name
 *                    that must be logged along with map status.
 *
 *
 * exceptions raised
 *
 *
 * notes
 *
 *
 * modification history
 *
 *
 */

 PROCEDURE gnrl (
       p_locid       IN number,
       p_loctbl      IN varchar2,
       p_mapStatus   IN varchar2,
       p_mesg        IN varchar2
 ) IS

 l_status varchar2(1);
 l_debug_prefix    VARCHAR2(30) := '';

  l_last_updated_by   NUMBER; -- hz_utility_v2pub.last_updated_by;
  l_creation_date     DATE;   -- hz_utility_v2pub.creation_date;
  l_created_by        NUMBER; -- hz_utility_v2pub.created_by;
  l_last_update_date  DATE;   -- hz_utility_v2pub.last_update_date;
  l_last_update_login NUMBER; -- hz_utility_v2pub.last_update_login;
  l_program_id        NUMBER; -- hz_utility_v2pub.program_id;
  l_conc_login_id     NUMBER; -- fnd_global.conc_login_id;
  l_program_application_id NUMBER; --hz_utility_v2pub.program_application_id;
  l_request_id        NUMBER; -- NVL(hz_utility_v2pub.request_id, -1);

 BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
       --enable_debug;
   -- flow:
   -- 1. delete the records with (locId, locTbl) combination
   --
   -- 2. in case of map status being error, delete records from gnr
   --    table also.
   --
   -- 3. insert the record in the GNRL

   -- Initialize variables (perf improvement bug 5130993)
   l_last_updated_by   := hz_utility_v2pub.last_updated_by;
   l_creation_date     := hz_utility_v2pub.creation_date;
   l_created_by        := hz_utility_v2pub.created_by;
   l_last_update_date  := hz_utility_v2pub.last_update_date;
   l_last_update_login := hz_utility_v2pub.last_update_login;
   l_program_id        := hz_utility_v2pub.program_id;
   l_conc_login_id     := fnd_global.conc_login_id;
   l_program_application_id := hz_utility_v2pub.program_application_id;
   l_request_id        := NVL(hz_utility_v2pub.request_id, -1);

   -- initializing the return status
   l_status := fnd_api.g_ret_sts_success;


   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'in gnrl(), bfr deleting locid, tbl nm combo',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

   -- delete thing the location id and table name combination from gnr
   BEGIN
     DELETE FROM hz_geo_name_reference_log
     WHERE location_id = p_locid
     AND location_table_name = p_loctbl;
   EXCEPTION
   WHEN others THEN

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'excep when deleting locid, tbl nm combo frm gnrl tbl',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

     RAISE FND_API.G_EXC_ERROR;
 --    x_status :=  fnd_api.g_ret_sts_unexp_error;
   END;


   -- This is to make the GNRL and GNR table in sync.
   -- In the case of GNR being sucess - gnrins() function
   -- deletes and re-creates rows for locationId and table
   -- combinations. Only in the case of Error, as gnrins() will not be called
   -- when ever there is a need to provide the previously GNRed
   -- location id and table combination but still need to write the
   -- result of the latest run in GNRL table comment the following
   -- delete statement.

   IF (p_mapStatus = FND_API.G_RET_STS_ERROR) THEN

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'bfr delGNR()',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

     delGNR(p_locid,p_loctbl, l_status);

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'aft delGNR()',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;

   END IF;

   IF (l_status = fnd_api.g_ret_sts_success) THEN
     INSERT INTO hz_geo_name_reference_log
     (location_id, location_table_name,
      message_text,
      object_version_number, map_status,
      last_updated_by, creation_date,
      created_by, last_update_date,
      last_update_login, program_id,
      program_login_id,program_application_id,request_id)
     VALUES
     (p_locid, p_loctbl, p_mesg, 1, p_mapStatus,
      l_last_updated_by, l_creation_date,
      l_created_by, l_last_update_date,
      l_last_update_login, l_program_id,
      l_conc_login_id, l_program_application_id, l_request_id);

    ELSE

   -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'unable to insert into GNRL tbl',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>'sqlerrm:'||sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;

         RAISE FND_API.G_EXC_ERROR;
    END IF;

    --disable_debug;
--   x_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN others THEN

   -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'in gnrl excep blk',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'sqlerrm:'||sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
       END IF;

     RAISE FND_API.G_EXC_ERROR;
     --     x_status :=  fnd_api.g_ret_sts_unexp_error;
 END gnrl;
----------------------------------------------
/**
* Procedure to write a message to the out file
**/
----------------------------------------------
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;
----------------------------------------------
/**
* Procedure to write a message to the log file
**/
----------------------------------------------
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put_line(fnd_file.log,message);
  END IF;
END log;
----------------------------------------------
/**
* Procedure to write a message to the out and log files
**/
----------------------------------------------
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message);
END outandlog;
----------------------------------------------
/**
* procedure to fetch messages of the stack and log the error
**/
----------------------------------------------

PROCEDURE logerr IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;
 -- FND_MSG_PUB.Delete_Msg;
END logerr;
----------------------------------------------
/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
----------------------------------------------
FUNCTION logerror RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || ' ' || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;
----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the log file also.
*/
----------------------------------------------
PROCEDURE mesglog(
   p_locId     IN NUMBER,
   p_locTbl    IN VARCHAR2,
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2,
   p_tkn1_val     IN      VARCHAR2,
   p_tkn2_name    IN      VARCHAR2,
   p_tkn2_val     IN      VARCHAR2
   ) IS
BEGIN

  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;
  --hz_gnr_util_pkg.gnrl(p_locid,p_loctbl,G_ERROR,FND_MSG_PUB.Get(p_encoded => FND_API.G_TRUE));
  hz_gnr_util_pkg.gnrl(p_locid,p_loctbl,FND_API.G_RET_STS_ERROR,FND_MSG_PUB.Get(p_encoded => FND_API.G_TRUE));
END mesglog;
----------------------------------------------
FUNCTION getQuery(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type,
   p_mdu_tbl              IN  maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 ) RETURN VARCHAR2 IS

    -- Bug 6507596 : Changed length of query variables to handle more than 5 geography elements
    -- In such cases, for example, for 6 parameters, length of l_where itself becomes 1844
    -- causing l_query to be > 2000
    l_query varchar2(9000);  -- (2000)
    l_select varchar2(1000); -- (2000)
    l_where varchar2(7000);  -- (2000)
    l_from varchar2(1000);   -- (2000)
    i number;
    l_lowest_value_index number;

BEGIN

    x_status := FND_API.g_ret_sts_success;

    IF P_MDU_TBL.COUNT = 1 THEN
      RETURN NULL;
    END IF;

    l_select := 'SELECT g.GEOGRAPHY_ID,g.MULTIPLE_PARENT_FLAG';
    l_select := l_select||',GEOGRAPHY_ELEMENT1_ID';
    l_from   := ' FROM   HZ_GEOGRAPHIES g ';
    l_where  := ' WHERE  g.GEOGRAPHY_USE = ''MASTER_REF''';
    l_where  := l_where||' AND    g.COUNTRY_CODE = :country_code';
    -- Added +0 in the below line to fix the performance bug # 4642581
    l_where  := l_where||' AND    g.GEOGRAPHY_ELEMENT1_ID+0 = :id1';
    l_where  := l_where||' AND    SYSDATE BETWEEN g.START_DATE AND g.END_DATE ';


    i := 0;
    IF P_MAP_DTLS_TBL.COUNT > 1 THEN
      i := P_MAP_DTLS_TBL.FIRST;
      i := P_MAP_DTLS_TBL.NEXT(i);
      LOOP
        l_select := l_select||','||P_MAP_DTLS_TBL(i).GEO_ELEMENT_COL||'_ID';
        EXIT WHEN i = P_MAP_DTLS_TBL.LAST;
        i := P_MAP_DTLS_TBL.NEXT(i);
      END LOOP;
    END IF;

    -- Derive the index of the lowest value passed.
    i := 0;
    IF P_MDU_TBL.COUNT > 1 THEN
      i := P_MDU_TBL.FIRST;
      i := P_MDU_TBL.NEXT(i);
      LOOP
        IF P_MDU_TBL(i).LOC_COMPVAL IS NOT NULL THEN
          l_lowest_value_index := i;
        END IF;
        EXIT WHEN i = P_MDU_TBL.LAST;
        i := P_MDU_TBL.NEXT(i);
      END LOOP;
    END IF;

    i := 0;
    IF P_MDU_TBL.COUNT > 1 THEN
      i := P_MDU_TBL.FIRST;
      i := P_MDU_TBL.NEXT(i);
      LOOP
        IF P_MDU_TBL(i).LOC_COMPVAL IS NOT NULL THEN
          IF i = l_lowest_value_index THEN
            -- lowest passed in value will not be null in element column
            -- So the OR clause to deal the multiparent element column null value is not required.
            l_where  := l_where||' AND EXISTS( SELECT NULL FROM HZ_GEOGRAPHY_IDENTIFIERS i'||i;
            l_where  := l_where||' WHERE i'||i||'.GEOGRAPHY_TYPE = :l_type'||i;
            l_where  := l_where||' AND    i'||i||'.GEOGRAPHY_USE = ''MASTER_REF''';
            l_where  := l_where||' AND    g.'||P_MDU_TBL(i).GEO_ELEMENT_COL||'_ID = i'||i||'.GEOGRAPHY_ID ';
            l_where  := l_where||' AND upper(i'||i||'.IDENTIFIER_VALUE) = upper(:l_val'||i||'))';
          ELSE
            l_where  := l_where||' AND (EXISTS( SELECT /*+  index(i'||i||',HZ_GEOGRAPHY_IDENTIFIERS_U1) */ NULL FROM HZ_GEOGRAPHY_IDENTIFIERS i'||i;
            l_where  := l_where||' WHERE i'||i||'.GEOGRAPHY_TYPE = :l_type'||i;
            l_where  := l_where||' AND    i'||i||'.GEOGRAPHY_USE = ''MASTER_REF''';
            l_where  := l_where||' AND    g.'||P_MDU_TBL(i).GEO_ELEMENT_COL||'_ID = i'||i||'.GEOGRAPHY_ID ';
            l_where  := l_where||' AND upper(i'||i||'.IDENTIFIER_VALUE) = upper(:l_val'||i||'))';
            l_where  := l_where||' OR (g.multiple_parent_flag = ''Y'' AND g.'||P_MDU_TBL(i).GEO_ELEMENT_COL||'_ID IS NULL))';
          END IF;
        ELSE
          l_where  := l_where||' AND :l_type'||i||' = ''X''  AND :l_val'||i||' =''X''';
        END IF;

        IF i = P_MDU_TBL.LAST THEN
          l_where := l_where || ' AND g.GEOGRAPHY_TYPE = :geography_type';
          l_where := l_where || ' AND rownum < 3';
          EXIT;
        END IF;

        i := P_MDU_TBL.NEXT(i);
      END LOOP;
    END IF;
    l_query := l_select || l_from || l_where;
    RETURN l_query;
END getQuery;
--------------------------------------
--------------------------------------
-- Below function is for creating the query when there is a cause MULTIPLE_MATCH
-- In this case the query is same as the query created by getQuery function except that
-- this also add the check to verify the identifier_type is NAME
-- Fix for bug #
FUNCTION getQueryforMultiMatch(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type,
   p_mdu_tbl              IN  maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 ) RETURN VARCHAR2 IS

    -- Bug 6507596 : Changed length of query variables to handle more than 5 geography elements
    -- In such cases, for example, for 6 parameters, length of l_where itself becomes 1844
    -- causing l_query to be > 2000
    l_query varchar2(9000);  -- (2000)
    l_select varchar2(1000); -- (2000)
    l_where varchar2(7000);  -- (2000)
    l_from varchar2(1000);   -- (2000)
    i number;
    l_lowest_value_index number;

BEGIN

    x_status := FND_API.g_ret_sts_success;

    IF P_MDU_TBL.COUNT = 1 THEN
      RETURN NULL;
    END IF;

    l_select := 'SELECT g.GEOGRAPHY_ID,g.MULTIPLE_PARENT_FLAG';
    l_select := l_select||',GEOGRAPHY_ELEMENT1_ID';
    l_from   := ' FROM   HZ_GEOGRAPHIES g ';
    l_where  := ' WHERE  g.GEOGRAPHY_USE = ''MASTER_REF''';
    l_where  := l_where||' AND    g.COUNTRY_CODE = :country_code';
    -- Added +0 in the below line to fix the performance bug # 4642581
    l_where  := l_where||' AND    g.GEOGRAPHY_ELEMENT1_ID+0 = :id1';
    l_where  := l_where||' AND    SYSDATE BETWEEN g.START_DATE AND g.END_DATE ';


    i := 0;
    IF P_MAP_DTLS_TBL.COUNT > 1 THEN
      i := P_MAP_DTLS_TBL.FIRST;
      i := P_MAP_DTLS_TBL.NEXT(i);
      LOOP
        l_select := l_select||','||P_MAP_DTLS_TBL(i).GEO_ELEMENT_COL||'_ID';
        EXIT WHEN i = P_MAP_DTLS_TBL.LAST;
        i := P_MAP_DTLS_TBL.NEXT(i);
      END LOOP;
    END IF;

    -- Derive the index of the lowest value passed.
    i := 0;
    IF P_MDU_TBL.COUNT > 1 THEN
      i := P_MDU_TBL.FIRST;
      i := P_MDU_TBL.NEXT(i);
      LOOP
        IF P_MDU_TBL(i).LOC_COMPVAL IS NOT NULL THEN
          l_lowest_value_index := i;
        END IF;
        EXIT WHEN i = P_MDU_TBL.LAST;
        i := P_MDU_TBL.NEXT(i);
      END LOOP;
    END IF;

    i := 0;
    IF P_MDU_TBL.COUNT > 1 THEN
      i := P_MDU_TBL.FIRST;
      i := P_MDU_TBL.NEXT(i);
      LOOP
        IF P_MDU_TBL(i).LOC_COMPVAL IS NOT NULL THEN
          IF i = l_lowest_value_index THEN
            -- lowest passed in value will not be null in element column
            -- So the OR clause to deal the multiparent element column null value is not required.
            l_where  := l_where||' AND EXISTS( SELECT NULL FROM HZ_GEOGRAPHY_IDENTIFIERS i'||i;
            l_where  := l_where||' WHERE i'||i||'.GEOGRAPHY_TYPE = :l_type'||i;
            l_where  := l_where||' AND    i'||i||'.GEOGRAPHY_USE = ''MASTER_REF''';
            l_where  := l_where||' AND    g.'||P_MDU_TBL(i).GEO_ELEMENT_COL||'_ID = i'||i||'.GEOGRAPHY_ID ';
            l_where  := l_where||' AND upper(i'||i||'.IDENTIFIER_VALUE) = upper(:l_val'||i||')';
            l_where  := l_where||' AND i'||i||'.IDENTIFIER_TYPE = ''NAME''';
            l_where  := l_where||' AND i'||i||'.PRIMARY_FLAG = ''Y'')';
          ELSE
            l_where  := l_where||' AND (EXISTS( SELECT /*+  index(i'||i||',HZ_GEOGRAPHY_IDENTIFIERS_U1) */ NULL FROM HZ_GEOGRAPHY_IDENTIFIERS i'||i;
            l_where  := l_where||' WHERE i'||i||'.GEOGRAPHY_TYPE = :l_type'||i;
            l_where  := l_where||' AND    i'||i||'.GEOGRAPHY_USE = ''MASTER_REF''';
            l_where  := l_where||' AND    g.'||P_MDU_TBL(i).GEO_ELEMENT_COL||'_ID = i'||i||'.GEOGRAPHY_ID ';
            l_where  := l_where||' AND upper(i'||i||'.IDENTIFIER_VALUE) = upper(:l_val'||i||')';
            l_where  := l_where||' AND i'||i||'.IDENTIFIER_TYPE = ''NAME''';
            l_where  := l_where||' AND i'||i||'.PRIMARY_FLAG = ''Y'')';
            l_where  := l_where||' OR (g.multiple_parent_flag = ''Y'' AND g.'||P_MDU_TBL(i).GEO_ELEMENT_COL||'_ID IS NULL))';
          END IF;
        ELSE
          l_where  := l_where||' AND :l_type'||i||' = ''X''  AND :l_val'||i||' =''X''';
        END IF;

        IF i = P_MDU_TBL.LAST THEN
          l_where := l_where || ' AND g.GEOGRAPHY_TYPE = :geography_type';
          l_where := l_where || ' AND rownum < 3';
          EXIT;
        END IF;

        i := P_MDU_TBL.NEXT(i);
      END LOOP;
    END IF;
    l_query := l_select || l_from || l_where;
    RETURN l_query;
END getQueryforMultiMatch;
--------------------------------------
--------------------------------------
  PROCEDURE reverse_tbl(P_MAP_DTLS_TBL IN HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE,
                        X_MAP_DTLS_TBL IN OUT NOCOPY HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE) IS

    l_map_dtls_tbl HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;
    i number;
    j number;
  BEGIN
    l_map_dtls_tbl := P_MAP_DTLS_TBL;
    IF l_map_dtls_tbl.COUNT > 0 THEN
      i := l_map_dtls_tbl.FIRST;
      LOOP
        IF i = l_map_dtls_tbl.LAST THEN
          IF X_MAP_DTLS_TBL.COUNT > 0 THEN
            j := X_MAP_DTLS_TBL.LAST + 1;
          ELSE
            j := 1;
          END IF;
          X_MAP_DTLS_TBL(j).LOC_SEQ_NUM      := l_map_dtls_tbl(i).LOC_SEQ_NUM;
          X_MAP_DTLS_TBL(j).LOC_COMPONENT    := l_map_dtls_tbl(i).LOC_COMPONENT;
          X_MAP_DTLS_TBL(j).GEOGRAPHY_TYPE   := l_map_dtls_tbl(i).GEOGRAPHY_TYPE;
          X_MAP_DTLS_TBL(j).GEO_ELEMENT_COL  := l_map_dtls_tbl(i).GEO_ELEMENT_COL;
          X_MAP_DTLS_TBL(j).LOC_COMPVAL      := l_map_dtls_tbl(i).LOC_COMPVAL;
          X_MAP_DTLS_TBL(j).GEOGRAPHY_ID     := l_map_dtls_tbl(i).GEOGRAPHY_ID;
          l_map_dtls_tbl.DELETE(i);
          reverse_tbl(l_map_dtls_tbl,X_MAP_DTLS_TBL);
          EXIT;
        END IF;
        i := l_map_dtls_tbl.NEXT(i);
      END LOOP;
    END IF;
  END reverse_tbl;
--------------------------------------
--------------------------------------
FUNCTION get_geo_id(p_geography_type IN VARCHAR2,p_mdtl_derived_tbl IN maploc_rec_tbl_type) RETURN NUMBER IS
  i number;
BEGIN
  IF p_mdtl_derived_tbl.COUNT > 0 THEN
    i := p_mdtl_derived_tbl.FIRST;
    LOOP
      IF p_mdtl_derived_tbl(i).GEOGRAPHY_TYPE = p_geography_type AND p_mdtl_derived_tbl(i).GEOGRAPHY_ID IS NOT NULL THEN
        RETURN p_mdtl_derived_tbl(i).GEOGRAPHY_ID;
      END IF;
      EXIT WHEN i = p_mdtl_derived_tbl.LAST;
      i := p_mdtl_derived_tbl.NEXT(i);
    END LOOP;
  END IF;
  RETURN NULL;
END get_geo_id;
--------------------------------------
--------------------------------------
FUNCTION get_usage_val_status(p_map_dtls_tbl IN maploc_rec_tbl_type,p_mdu_tbl IN maploc_rec_tbl_type) RETURN VARCHAR2 IS
  i number;
BEGIN
    IF p_mdu_tbl.COUNT > 0 THEN
      i := p_mdu_tbl.FIRST;
      LOOP
        IF get_geo_id(p_mdu_tbl(i).GEOGRAPHY_TYPE,p_map_dtls_tbl) IS NULL THEN
          RETURN FND_API.G_RET_STS_ERROR; -- Usage level validation has to go through.
        END IF;
        EXIT WHEN i = p_mdu_tbl.LAST;
        i := p_mdu_tbl.NEXT(i);
      END LOOP;
    END IF;
  RETURN FND_API.G_RET_STS_SUCCESS;
END get_usage_val_status;
--------------------------------------
-- The below finction is to get the address validation status
-- depends on the map status and address validation level
--------------------------------------
FUNCTION getAddrValStatus(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type,
   p_mdu_tbl              IN  maploc_rec_tbl_type,
   p_called_from          IN  VARCHAR2,
   p_addr_val_level       IN  VARCHAR2,
   x_addr_warn_msg        OUT NOCOPY VARCHAR2,
   x_map_status           IN  VARCHAR2,
   x_status               IN  OUT NOCOPY VARCHAR2
 ) RETURN VARCHAR2 IS
   l_addr_val_status VARCHAR2(2);
   i                 NUMBER;
   l_missing_elements VARCHAR2(2000);
   l_invalid_elements VARCHAR2(2000);
   l_addr_warn_msg    VARCHAR2(2000);

   l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRUB:HZ_GNR_UTIL_PKG';
   l_module        CONSTANT VARCHAR2(30) := 'ADDRESS_VALIDATION';
   l_debug_prefix           VARCHAR2(30);
BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     hz_utility_v2pub.debug
          (p_message      => 'Begin of getAddrValStatus procedure',
           p_prefix        => l_debug_prefix,
           p_msg_level     => fnd_log.level_procedure,
           p_module_prefix => l_module_prefix,
           p_module        => l_module
          );
   END IF;

   l_addr_val_status := fnd_api.g_ret_sts_success;
   l_missing_elements := NULL;
   -- If the map status = 'S' returm addr_val_status as 'S'
   IF x_map_status = 'S' then
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
           (p_message      => ' Map status is S. So, return address validation status as S ',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;
      RETURN l_addr_val_status;
   -- If the called from is GNR returm addr_val_status as x_return_status
   ELSIF p_called_from = 'GNR' then
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
           (p_message      => ' Called from is GNR. So, return address validation status and return status as S ',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;
      l_addr_val_status := x_status;
      RETURN l_addr_val_status;
   -- If the map status is 'E' and called from is <> GNR
   ELSE
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
           (p_message      => ' Map status is E. Check for address validation level.',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;
      -- If validation level is NONE, return addr_val_status as 'S'
      IF p_addr_val_level = 'NONE' then
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
             (p_message      => ' Address validation level is NONE. So, return address validation status and return status as S',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
         END IF;
         -- If the addr_val_level is NONE, both return_status and addr_val_status
         -- will be set to success even if the validation fails.
         x_status := l_addr_val_status;
         RETURN l_addr_val_status;
      -- If validation level is ERROR, return addr_val_status as 'E'
      -- also set the message with the missing parameters.
      ELSIF p_addr_val_level = 'ERROR' then
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
             (p_message      => ' Address validation level is ERROR.',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
         END IF;
         l_addr_val_status := fnd_api.g_ret_sts_error;
         IF p_mdu_tbl.COUNT > 0 THEN
            i := p_mdu_tbl.FIRST;
            LOOP
               IF p_map_dtls_tbl(i).GEOGRAPHY_ID IS NULL THEN
                  l_addr_val_status := fnd_api.g_ret_sts_error;
                  IF l_missing_elements is NULL then
                     l_missing_elements := p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
                  ELSE
                     l_missing_elements := l_missing_elements ||', ' || p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
                  END IF;
               END IF;
               EXIT WHEN i = p_mdu_tbl.LAST;
               i := p_mdu_tbl.NEXT(i);
            END LOOP;
         END IF;
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
             (p_message      => 'Please enter valid address elements : '||l_missing_elements,
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
         END IF;
         FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_ADDRESS');
         FND_MESSAGE.SET_TOKEN('P_MISSING_ELEMENTS', l_missing_elements);
         FND_MSG_PUB.ADD;
         RETURN l_addr_val_status;
      -- If validation level is WARNING, check the minimum parameters passed.
      -- If yes, set the addr_val_status to 'W' and return status to 'S'
      -- If not, set the message with the missing parameters
      ELSIF p_addr_val_level = 'WARNING' then
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
             (p_message      => ' Address validation level is WARNING.',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
         END IF;
         l_addr_val_status := 'W';
         x_status := fnd_api.g_ret_sts_success;
         IF p_mdu_tbl.COUNT > 0 THEN
            i := p_mdu_tbl.FIRST;
            LOOP
               -- Remove the code the find out the missing elements in case of WARNING
               -- This is to allow null values for Warning address validation level. Bug # 5011366
               -- IF p_map_dtls_tbl(i).LOC_COMPVAL IS NULL THEN
               --    l_addr_val_status := fnd_api.g_ret_sts_error;
               --    IF l_missing_elements is NULL then
               --       l_missing_elements := p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
               --    ELSE
               --       l_missing_elements := l_missing_elements ||', ' || p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
               --    END IF;
               -- ELSE
                  IF p_map_dtls_tbl(i).GEOGRAPHY_ID IS NULL THEN
                     IF l_invalid_elements is NULL then
                        l_invalid_elements := p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
                     ELSE
                        l_invalid_elements := l_invalid_elements ||', ' || p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
                     END IF;
                  END IF;
               -- END IF;
               EXIT WHEN i = p_mdu_tbl.LAST;
               i := p_mdu_tbl.NEXT(i);
            END LOOP;
            -- IF l_missing_elements is NULL then
               FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_WARN_ADDRESS');
               FND_MESSAGE.SET_TOKEN('P_ALL_ELEMENTS', l_invalid_elements);
               x_addr_warn_msg := FND_MESSAGE.get;
               x_status := fnd_api.g_ret_sts_success;
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message      => 'These address elements are not validated : '||l_invalid_elements,
                    p_prefix        => l_debug_prefix,
                    p_msg_level     => fnd_log.level_statement,
                    p_module_prefix => l_module_prefix,
                    p_module        => l_module
                   );
               END IF;
            -- ELSE
            --    FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NULL_ADDRESS');
            --    FND_MESSAGE.SET_TOKEN('P_MISSING_ELEMENTS', l_missing_elements);
            --    FND_MSG_PUB.ADD;
            --    x_status := l_addr_val_status;
            --    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            --      hz_utility_v2pub.debug
            --        (p_message      => 'Please enter required address elements : '||l_missing_elements,
            --         p_prefix        => l_debug_prefix,
            --         p_msg_level     => fnd_log.level_statement,
            --         p_module_prefix => l_module_prefix,
            --         p_module        => l_module
            --        );
            --    END IF;
            -- END IF;
            RETURN l_addr_val_status;
         END IF;

         l_addr_val_status := 'W';
         RETURN l_addr_val_status;
      -- If validation level is MINIMUM, check the minimum parameters passed.
      -- If yes, set the addr_val_status to 'S' and return status to 'S'
      -- If not, set the message with the missing parameters
      ELSIF p_addr_val_level = 'MINIMUM' then
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
             (p_message      => ' Address validation level is MINIMUM.',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
         END IF;
         IF p_mdu_tbl.COUNT > 0 THEN
            i := p_mdu_tbl.FIRST;
            LOOP
               IF p_map_dtls_tbl(i).LOC_COMPVAL IS NULL THEN
                  l_addr_val_status := fnd_api.g_ret_sts_error;
                  IF l_missing_elements is NULL then
                     l_missing_elements := p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
                  ELSE
                     l_missing_elements := l_missing_elements ||', ' || p_map_dtls_tbl(i).GEOGRAPHY_TYPE;
                  END IF;
               END IF;
               EXIT WHEN i = p_mdu_tbl.LAST;
               i := p_mdu_tbl.NEXT(i);
            END LOOP;

            IF l_missing_elements is NULL then
               x_status := fnd_api.g_ret_sts_success;
            ELSE
               FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NULL_ADDRESS');
               FND_MESSAGE.SET_TOKEN('P_MISSING_ELEMENTS', l_missing_elements);
               FND_MSG_PUB.ADD;
--               hk_debugl('Please enter required address elements: '|| l_missing_elements);
--               hk_debugl('l_addr_val_status : '|| l_addr_val_status);
               x_status := l_addr_val_status;
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message      => 'Please enter required address elements : '||l_missing_elements,
                    p_prefix        => l_debug_prefix,
                    p_msg_level     => fnd_log.level_statement,
                    p_module_prefix => l_module_prefix,
                    p_module        => l_module
                   );
               END IF;
            END IF;

            RETURN l_addr_val_status;
         END IF;
      END IF;
   END IF;
END;
--------------------------------------
--------------------------------------
-- This function will be called only if the validation for entire map is a failure.
FUNCTION do_usage_val(
  p_cause                 IN VARCHAR2,
  p_map_dtls_tbl          IN maploc_rec_tbl_type,
  p_mdu_tbl               IN maploc_rec_tbl_type,
  x_mdtl_derived_tbl      IN OUT NOCOPY maploc_rec_tbl_type,
  x_status                OUT NOCOPY varchar2
 ) RETURN BOOLEAN IS
  l_mapped_value_count number;
  l_usage_value_count  number;
  i                    number;

BEGIN
  x_status := FND_API.g_ret_sts_success;

  IF p_map_dtls_tbl.COUNT = p_mdu_tbl.COUNT THEN
    -- Validation for the entire map is already performed. IF the counts are equal, the mapping for the usage is same
    -- as the total mapping. So no need to repeat the same validation.
    IF (p_cause <> 'MISSING_CHILD' AND p_cause <> 'NO_MATCH') THEN
      x_mdtl_derived_tbl :=  p_map_dtls_tbl;
    END IF;
    RETURN FALSE;
  ELSE
    l_mapped_value_count := 0;
    l_usage_value_count  := 0;

    i:=0;
    IF p_map_dtls_tbl.COUNT > 0 THEN
      i := p_map_dtls_tbl.FIRST;
      LOOP
        IF p_map_dtls_tbl(i).LOC_COMPVAL IS NOT NULL THEN
          l_mapped_value_count := l_mapped_value_count + 1;
        END IF;
        EXIT WHEN i = p_map_dtls_tbl.LAST;
        i := p_map_dtls_tbl.NEXT(i);
      END LOOP;
    END IF;

    i:=0;
    IF p_mdu_tbl.COUNT > 0 THEN
      i := p_mdu_tbl.FIRST;
      LOOP
        IF p_mdu_tbl(i).LOC_COMPVAL IS NOT NULL THEN
          l_usage_value_count := l_usage_value_count + 1;
        END IF;
        EXIT WHEN i = p_mdu_tbl.LAST;
        i := p_mdu_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF l_mapped_value_count = l_usage_value_count THEN
      -- Even if the mapping for a usage is a subset of total mapping, if the passed in values are the same
      -- We will not be able to derive additional information from Geography model
      -- So no need to repeat the same validation.
      IF (p_cause <> 'MISSING_CHILD' AND p_cause <> 'NO_MATCH' and p_cause <> 'MULTIPLE_PARENT') THEN
        x_mdtl_derived_tbl :=  p_map_dtls_tbl;
      END IF;
      RETURN FALSE;
    END IF;
  END IF;

  IF p_cause = 'MISSING_CHILD' THEN
    i:=0;
    IF p_mdu_tbl.COUNT > 0 THEN
      i := p_mdu_tbl.FIRST;
      LOOP
        IF get_geo_id(p_mdu_tbl(i).GEOGRAPHY_TYPE,x_mdtl_derived_tbl) IS NULL THEN
          RETURN TRUE; -- Usage level validation has to go through.
        END IF;
        EXIT WHEN i = p_mdu_tbl.LAST;
        i := p_mdu_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN FALSE; -- All the Usage level mapped columns were derived. So no need to repeat the validation.
  END IF;

  RETURN TRUE; -- Usage level validation has to go through.
END do_usage_val;
--------------------------------------
--------------------------------------
PROCEDURE fill_values(
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type
 ) IS
  i number;
  l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRUB:HZ_GNR_UTIL_PKG';
  l_module        CONSTANT VARCHAR2(30) := 'ADDRESS_VALIDATION';
  l_debug_prefix           VARCHAR2(30);
BEGIN

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    hz_utility_v2pub.debug
         (p_message      => 'Begin of fill_values procedure',
          p_prefix        => l_debug_prefix,
          p_msg_level     => fnd_log.level_procedure,
          p_module_prefix => l_module_prefix,
          p_module        => l_module
         );
  END IF;
  IF x_map_dtls_tbl.COUNT > 0 THEN
    i:= x_map_dtls_tbl.FIRST;
    -- Added the below line to skip the first record from the table (COUNTRY)
    i := i+1;
    LOOP
      IF (x_map_dtls_tbl(i).GEOGRAPHY_ID IS NOT NULL) THEN
--      IF (x_map_dtls_tbl(i).GEOGRAPHY_ID IS NOT NULL AND x_map_dtls_tbl(i).LOC_COMPVAL IS NULL) THEN
        SELECT GEOGRAPHY_NAME, GEOGRAPHY_CODE
        INTO x_map_dtls_tbl(i).LOC_COMPVAL, x_map_dtls_tbl(i).GEOGRAPHY_CODE
        FROM HZ_GEOGRAPHIES
        WHERE GEOGRAPHY_ID = x_map_dtls_tbl(i).GEOGRAPHY_ID;
      END IF;
      EXIT WHEN i = x_map_dtls_tbl.LAST;
      i := x_map_dtls_tbl.NEXT(i);
    END LOOP;
  END IF;
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    hz_utility_v2pub.debug
         (p_message      => 'End of fill_values procedure',
          p_prefix        => l_debug_prefix,
          p_msg_level     => fnd_log.level_procedure,
          p_module_prefix => l_module_prefix,
          p_module        => l_module
         );
  END IF;
END fill_values;
--------------------------------------
--------------------------------------
PROCEDURE putLocCompValues(
   p_map_dtls_tbl         IN maploc_rec_tbl_type,
   x_loc_components_rec   IN OUT NOCOPY loc_components_rec_type
 ) IS

  FUNCTION map_exists(p_location_component IN VARCHAR2,
                      p_map_dtls_tbl       IN maploc_rec_tbl_type
                      ) RETURN BOOLEAN IS
    i number;
  BEGIN
    IF p_map_dtls_tbl.COUNT > 0 THEN
      i:= p_map_dtls_tbl.FIRST;
      LOOP
        IF p_map_dtls_tbl(i).GEOGRAPHY_ID IS NOT NULL AND p_map_dtls_tbl(i).LOC_COMPONENT = p_location_component THEN
          RETURN TRUE;
        END IF;
        EXIT WHEN i = p_map_dtls_tbl.LAST;
        i := p_map_dtls_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN FALSE;
  END map_exists;

  FUNCTION getValue(p_location_component IN VARCHAR2,
                    p_map_dtls_tbl       IN maploc_rec_tbl_type
                    ) RETURN VARCHAR2 IS
    i number :=0;
  BEGIN
    IF p_map_dtls_tbl.COUNT > 0 THEN
      i:= p_map_dtls_tbl.FIRST;
      LOOP
        IF p_map_dtls_tbl(i).LOC_COMPONENT = p_location_component THEN
          RETURN p_map_dtls_tbl(i).LOC_COMPVAL;
        END IF;
        EXIT WHEN i = p_map_dtls_tbl.LAST;
        i := p_map_dtls_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN NULL;
  END getValue;

BEGIN

  -- This API will overwrite the location component, only if that component is mapped and which has a valid geography id
  --  in the map details table.
  IF map_exists ('COUNTRY',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.COUNTRY := getValue('COUNTRY',p_map_dtls_tbl);
  END IF;
  IF map_exists ('CITY',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.CITY := getValue('CITY',p_map_dtls_tbl);
  END IF;
  --Bug 8241862
   IF map_exists ('POSTAL_CODE',p_map_dtls_tbl) = TRUE THEN
      IF(HZ_GNR_UTIL_PKG.postal_code_to_validate(x_loc_components_rec.COUNTRY,x_loc_components_rec.POSTAL_CODE)=getValue('POSTAL_CODE',p_map_dtls_tbl)) THEN
         NULL;
      ELSE
         x_loc_components_rec.POSTAL_CODE := getValue('POSTAL_CODE',p_map_dtls_tbl);
      END IF;
  END IF;
  IF map_exists ('STATE',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.STATE := getValue('STATE',p_map_dtls_tbl);
  END IF;
  IF map_exists ('PROVINCE',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.PROVINCE := getValue('PROVINCE',p_map_dtls_tbl);
  END IF;
  IF map_exists ('COUNTY',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.COUNTY := getValue('COUNTY',p_map_dtls_tbl);
  END IF;
  IF map_exists ('POSTAL_PLUS4_CODE',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.POSTAL_PLUS4_CODE := getValue('POSTAL_PLUS4_CODE',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE1',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE1 := getValue('ATTRIBUTE1',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE2',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE2 := getValue('ATTRIBUTE2',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE3',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE3 := getValue('ATTRIBUTE3',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE4',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE4 := getValue('ATTRIBUTE4',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE5',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE5 := getValue('ATTRIBUTE5',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE6',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE6 := getValue('ATTRIBUTE6',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE7',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE7 := getValue('ATTRIBUTE7',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE8',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE8 := getValue('ATTRIBUTE8',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE9',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE9 := getValue('ATTRIBUTE9',p_map_dtls_tbl);
  END IF;
  IF map_exists ('ATTRIBUTE10',p_map_dtls_tbl) = TRUE THEN
    x_loc_components_rec.ATTRIBUTE10 := getValue('ATTRIBUTE10',p_map_dtls_tbl);
  END IF;
END putLocCompValues;

--------------------------------------
  PROCEDURE update_location (
       p_location_id            IN number,
       p_loc_components_rec     IN  loc_components_rec_type,
       p_lock_flag              IN varchar2,
       p_map_dtls_tbl           IN maploc_rec_tbl_type,
       x_status                 OUT NOCOPY varchar2
  ) IS


    db_city                       VARCHAR2(60);
    db_state                      VARCHAR2(60);
    db_country                    VARCHAR2(60);
    db_county                     VARCHAR2(60);
    db_province                   VARCHAR2(60);
    db_postal_code                VARCHAR2(60);
    db_postal_plus4_code          VARCHAR2(60);
    db_attribute1                 VARCHAR2(150);
    db_attribute2                 VARCHAR2(150);
    db_attribute3                 VARCHAR2(150);
    db_attribute4                 VARCHAR2(150);
    db_attribute5                 VARCHAR2(150);
    db_attribute6                 VARCHAR2(150);
    db_attribute7                 VARCHAR2(150);
    db_attribute8                 VARCHAR2(150);
    db_attribute9                 VARCHAR2(150);
    db_attribute10                VARCHAR2(150);
    db_wh_update_date             DATE;

    l_location_profile_rec  hz_location_profile_pvt.location_profile_rec_type;
    l_loc_components_rec loc_components_rec_type;
    l_old_location_rec      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_new_location_rec      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_other_param_rec       HZ_GNR_UTIL_PKG.loc_other_param_rec_type;
    l_wh_update_date             DATE;
    l_address1                   VARCHAR2(240);
    l_address2                   VARCHAR2(240);
    l_address3                   VARCHAR2(240);
    l_address4                   VARCHAR2(240);
    l_actual_content_source VARCHAR2(30);
    l_address_key                VARCHAR2(500);
    l_time_zone_id               NUMBER;
    l_return_status         VARCHAR2(30);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    ll_return_status         VARCHAR2(30);
    ll_msg_count             NUMBER;
    ll_msg_data              VARCHAR2(2000);

  BEGIN
    l_loc_components_rec := p_loc_components_rec;
    -- if p_loc_flag is not true then the location has been locked already.

    -- If the Location updation is allowed
    IF location_updation_allowed(p_location_id) then

    IF p_lock_flag = 'T' OR p_lock_flag = FND_API.G_TRUE  THEN
        -- get location components
        BEGIN
            SELECT COUNTRY, CITY,  STATE, COUNTY, PROVINCE,  POSTAL_CODE,POSTAL_PLUS4_CODE,
                   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
                   ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
                   WH_UPDATE_DATE, ADDRESS1, ADDRESS2, ADDRESS3, ADDRESS4, ACTUAL_CONTENT_SOURCE,
                   TIMEZONE_ID, ADDRESS_KEY
            INTO   l_loc_components_rec.country, l_loc_components_rec.city, l_loc_components_rec.state,
                   l_loc_components_rec.county, l_loc_components_rec.province,
                   l_loc_components_rec.postal_code, l_loc_components_rec.postal_plus4_code,
                   l_loc_components_rec.attribute1,l_loc_components_rec.attribute2,
                   l_loc_components_rec.attribute3,l_loc_components_rec.attribute4,
                   l_loc_components_rec.attribute5, l_loc_components_rec.attribute6,
                   l_loc_components_rec.attribute7,l_loc_components_rec.attribute8,
                   l_loc_components_rec.attribute9,l_loc_components_rec.attribute10,
                   l_wh_update_date, l_address1, l_address2, l_address3, l_address4
                 , l_actual_content_source, l_time_zone_id, l_address_key
            FROM   HZ_LOCATIONS
            WHERE  LOCATION_ID = p_location_id
            FOR UPDATE OF LOCATION_ID NOWAIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
                FND_MESSAGE.SET_TOKEN('RECORD', 'hz_locations');
                FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_location_id));
                FND_MSG_PUB.ADD;
                x_status := FND_API.G_RET_STS_ERROR;
        END;  -- end of SELECT

    ELSE -- do not lock the location record
        -- get location components
        BEGIN
            SELECT COUNTRY, CITY,  STATE, COUNTY, PROVINCE,  POSTAL_CODE,POSTAL_PLUS4_CODE,
                   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
                   ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
                   WH_UPDATE_DATE, ADDRESS1, ADDRESS2, ADDRESS3, ADDRESS4, ACTUAL_CONTENT_SOURCE,
                   TIMEZONE_ID, ADDRESS_KEY
            INTO   l_loc_components_rec.country, l_loc_components_rec.city, l_loc_components_rec.state,
                   l_loc_components_rec.county, l_loc_components_rec.province,
                   l_loc_components_rec.postal_code, l_loc_components_rec.postal_plus4_code,
                   l_loc_components_rec.attribute1,l_loc_components_rec.attribute2,
                   l_loc_components_rec.attribute3,l_loc_components_rec.attribute4,
                   l_loc_components_rec.attribute5, l_loc_components_rec.attribute6,
                   l_loc_components_rec.attribute7,l_loc_components_rec.attribute8,
                   l_loc_components_rec.attribute9,l_loc_components_rec.attribute10,
                   l_wh_update_date, l_address1, l_address2, l_address3, l_address4
                 , l_actual_content_source, l_time_zone_id, l_address_key
            FROM   HZ_LOCATIONS
            WHERE  LOCATION_ID = p_location_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
                FND_MESSAGE.SET_TOKEN('RECORD', 'hz_locations');
                FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_location_id));
                FND_MSG_PUB.ADD;
                x_status := FND_API.G_RET_STS_ERROR;
        END;  -- end of SELECT ;
    END IF;

    db_country            :=      l_loc_components_rec.country;
    db_city               :=      l_loc_components_rec.city ;
    db_state              :=      l_loc_components_rec.state ;
    db_county             :=      l_loc_components_rec.county ;
    db_province           :=      l_loc_components_rec.province;
    db_postal_code        :=      l_loc_components_rec.postal_code;
    db_postal_plus4_code  :=      l_loc_components_rec.postal_plus4_code;
    db_attribute1         :=      l_loc_components_rec.attribute1;
    db_attribute2         :=      l_loc_components_rec.attribute2;
    db_attribute3         :=      l_loc_components_rec.attribute3;
    db_attribute4         :=      l_loc_components_rec.attribute4;
    db_attribute5         :=      l_loc_components_rec.attribute5;
    db_attribute6         :=      l_loc_components_rec.attribute6;
    db_attribute7         :=      l_loc_components_rec.attribute7;
    db_attribute8         :=      l_loc_components_rec.attribute8;
    db_attribute9         :=      l_loc_components_rec.attribute9;
    db_attribute10        :=      l_loc_components_rec.attribute10;
    db_wh_update_date     :=      l_wh_update_date;

    putLocCompValues(p_map_dtls_tbl,l_loc_components_rec);

    -- Fix for Bug 5231893. Added UPPER to make case insensitive comaprison. It does not make sense to update
    -- location rec as part of GNR creation, just because fetched value from hz_locations is in different case
    -- than that derived from HZ_GEOGRAPHIES. It also improves performance by not updating that location rec
    -- and doing subsequent processes related to update_location. (18-MAY-2006 Nishant)
    IF       NVL(UPPER(db_country),fnd_api.g_miss_char)    = NVL(UPPER(l_loc_components_rec.country),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_city),fnd_api.g_miss_char)       = NVL(UPPER(l_loc_components_rec.city),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_state),fnd_api.g_miss_char)      = NVL(UPPER(l_loc_components_rec.state),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_county),fnd_api.g_miss_char)     = NVL(UPPER(l_loc_components_rec.county),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_province),fnd_api.g_miss_char)   = NVL(UPPER(l_loc_components_rec.province),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_postal_code),fnd_api.g_miss_char)= NVL(UPPER(l_loc_components_rec.postal_code),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute1),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute1),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute2),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute2),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute3),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute3),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute4),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute4),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute5),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute5),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute6),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute6),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute7),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute7),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute8),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute8),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute9),fnd_api.g_miss_char) = NVL(UPPER(l_loc_components_rec.attribute9),fnd_api.g_miss_char)
        AND  NVL(UPPER(db_attribute10),fnd_api.g_miss_char)= NVL(UPPER(l_loc_components_rec.attribute10),fnd_api.g_miss_char)
    THEN
        NULL;
    ELSE

         -- Old location record will have the data from database.
         l_old_location_rec.location_id := p_location_id;
         l_old_location_rec.country := db_country;
         l_old_location_rec.city := db_city;
         l_old_location_rec.state := db_state;
         l_old_location_rec.county := db_county;
         l_old_location_rec.province := db_province;
         l_old_location_rec.postal_code := db_postal_code;
         l_old_location_rec.postal_plus4_code := db_postal_plus4_code;
         l_old_location_rec.attribute1 := db_attribute1;
         l_old_location_rec.attribute2 := db_attribute2;
         l_old_location_rec.attribute3 := db_attribute3;
         l_old_location_rec.attribute4 := db_attribute4;
         l_old_location_rec.attribute5 := db_attribute5;
         l_old_location_rec.attribute6 := db_attribute6;
         l_old_location_rec.attribute7 := db_attribute7;
         l_old_location_rec.attribute8 := db_attribute8;
         l_old_location_rec.attribute9 := db_attribute9;
         l_old_location_rec.attribute10 := db_attribute10;
         l_old_location_rec.address1 := l_address1;
         l_old_location_rec.address2 := l_address2;
         l_old_location_rec.address3 := l_address3;
         l_old_location_rec.address4 := l_address4;
         l_old_location_rec.timezone_id := l_time_zone_id;
         l_old_location_rec.address_key := l_address_key;

         -- Old location record will have the data derived by GNR.
         -- If country, city, state or postal_code is changed
         -- set the timezone_id is NULL so that pre_location_update
         -- will get the timezone based on new values.
         l_new_location_rec.location_id := p_location_id;
         l_new_location_rec.country := l_loc_components_rec.country;
         l_new_location_rec.city := l_loc_components_rec.city;
         l_new_location_rec.state := l_loc_components_rec.state;
         l_new_location_rec.county := l_loc_components_rec.county;
         l_new_location_rec.province := l_loc_components_rec.province;
         l_new_location_rec.postal_code := l_loc_components_rec.postal_code;
         l_new_location_rec.postal_plus4_code := l_loc_components_rec.postal_plus4_code;
         l_new_location_rec.attribute1 := l_loc_components_rec.attribute1;
         l_new_location_rec.attribute2 := l_loc_components_rec.attribute2;
         l_new_location_rec.attribute3 := l_loc_components_rec.attribute3;
         l_new_location_rec.attribute4 := l_loc_components_rec.attribute4;
         l_new_location_rec.attribute5 := l_loc_components_rec.attribute5;
         l_new_location_rec.attribute6 := l_loc_components_rec.attribute6;
         l_new_location_rec.attribute7 := l_loc_components_rec.attribute7;
         l_new_location_rec.attribute8 := l_loc_components_rec.attribute8;
         l_new_location_rec.attribute9 := l_loc_components_rec.attribute9;
         l_new_location_rec.attribute10 := l_loc_components_rec.attribute10;
         l_new_location_rec.address1 := l_address1;
         l_new_location_rec.address2 := l_address2;
         l_new_location_rec.address3 := l_address3;
         l_new_location_rec.address4 := l_address4;
         l_new_location_rec.address_key := l_address_key;
         IF (l_new_location_rec.country IS NOT NULL AND
            NVL(UPPER(l_old_location_rec.country), fnd_api.g_miss_char) <> UPPER(l_new_location_rec.country))
            OR
			(l_new_location_rec.city IS NOT NULL AND
            NVL(UPPER(l_old_location_rec.city), fnd_api.g_miss_char) <> UPPER(l_new_location_rec.city))
            OR
			(l_new_location_rec.state IS NOT NULL AND
            NVL(UPPER(l_old_location_rec.state), fnd_api.g_miss_char) <> UPPER(l_new_location_rec.state))
            OR
			(l_new_location_rec.postal_code IS NOT NULL AND
            NVL(UPPER(l_old_location_rec.postal_code), fnd_api.g_miss_char) <> UPPER(l_new_location_rec.postal_code))
          THEN
             l_new_location_rec.timezone_id := NULL;
          ELSE
             l_new_location_rec.timezone_id := l_time_zone_id;
          END IF;

        -- Call pre_location_update to get timezone_id and address_key.
        begin
           pre_location_update( p_old_location_rec      => l_old_location_rec,
                                p_new_location_rec      => l_new_location_rec,
                                p_other_location_params => l_other_param_rec,
                                x_return_status         => ll_return_status,
                                x_msg_count             => ll_msg_count,
                                x_msg_data              => ll_msg_data );
        exception when others then
           null;
        end;

        UPDATE HZ_LOCATIONS
        SET
            COUNTRY      =   l_loc_components_rec.country,
            CITY         =   l_loc_components_rec.city ,
            STATE        =   l_loc_components_rec.state ,
            COUNTY       =   l_loc_components_rec.county ,
            PROVINCE     =   l_loc_components_rec.province,
            POSTAL_CODE  =   l_loc_components_rec.postal_code,
            ATTRIBUTE1   =   l_loc_components_rec.attribute1,
            ATTRIBUTE2   =   l_loc_components_rec.attribute2,
            ATTRIBUTE3   =   l_loc_components_rec.attribute3,
            ATTRIBUTE4   =   l_loc_components_rec.attribute4,
            ATTRIBUTE5   =   l_loc_components_rec.attribute5,
            ATTRIBUTE6   =   l_loc_components_rec.attribute6,
            ATTRIBUTE7   =   l_loc_components_rec.attribute7,
            ATTRIBUTE8   =   l_loc_components_rec.attribute8,
            ATTRIBUTE9   =   l_loc_components_rec.attribute9,
            ATTRIBUTE10  =   l_loc_components_rec.attribute10,
            TIMEZONE_ID  =   l_new_location_rec.timezone_id,
            ADDRESS_KEY  =   l_new_location_rec.address_key
        WHERE  LOCATION_ID = p_location_id;

        -- fix for bug # 4169728.  Set address_text to null in hz_cust_acct_sites_all table if,
        -- city, state, province or postal_code changes in hz_location table.
        -- address_text column in hz_cust_acct_sites_all is populated by the concurrent program,
        -- "Customer text data creation and indexing", if address_text is null.
        IF      nvl(UPPER(db_city),fnd_api.g_miss_char)         =   nvl(UPPER(l_loc_components_rec.city),fnd_api.g_miss_char)
           AND  nvl(UPPER(db_state),fnd_api.g_miss_char)        =   nvl(UPPER(l_loc_components_rec.state),fnd_api.g_miss_char)
           AND  nvl(UPPER(db_province),fnd_api.g_miss_char)     =   nvl(UPPER(l_loc_components_rec.province),fnd_api.g_miss_char)
           AND  nvl(UPPER(db_postal_code),fnd_api.g_miss_char)  =   nvl(UPPER(l_loc_components_rec.postal_code),fnd_api.g_miss_char)
        THEN
           NULL;
        ELSE
           UPDATE hz_cust_acct_sites_all cas
           SET cas.address_text = null
           WHERE cas.address_text IS NOT NULL
           AND EXISTS
           ( SELECT 1
             FROM HZ_PARTY_SITES ps
             WHERE ps.location_id = p_location_id
             AND cas.party_site_id = ps.party_site_id );
        END IF;

        IF       nvl(UPPER(db_country),fnd_api.g_miss_char)      =   nvl(UPPER(l_loc_components_rec.country),fnd_api.g_miss_char)
            AND  nvl(UPPER(db_city),fnd_api.g_miss_char)         =   nvl(UPPER(l_loc_components_rec.city),fnd_api.g_miss_char)
            AND  nvl(UPPER(db_state),fnd_api.g_miss_char)        =   nvl(UPPER(l_loc_components_rec.state),fnd_api.g_miss_char)
            AND  nvl(UPPER(db_county),fnd_api.g_miss_char)       =   nvl(UPPER(l_loc_components_rec.county),fnd_api.g_miss_char)
            AND  nvl(UPPER(db_province),fnd_api.g_miss_char)     =   nvl(UPPER(l_loc_components_rec.province),fnd_api.g_miss_char)
            AND  nvl(UPPER(db_postal_code),fnd_api.g_miss_char)  =   nvl(UPPER(l_loc_components_rec.postal_code),fnd_api.g_miss_char)
        THEN
            NULL;
        ELSE
            l_location_profile_rec.location_profile_id := NULL;
            l_location_profile_rec.location_id := p_location_id;
            l_location_profile_rec.actual_content_source := l_actual_content_source;
            l_location_profile_rec.effective_start_date := NULL;
            l_location_profile_rec.effective_end_date := NULL;
            l_location_profile_rec.date_validated := NULL;
            l_location_profile_rec.city := l_loc_components_rec.city;
            l_location_profile_rec.postal_code := l_loc_components_rec.postal_code;
            l_location_profile_rec.county := l_loc_components_rec.county;
            l_location_profile_rec.country := l_loc_components_rec.country;
            l_location_profile_rec.address1 := l_address1;
            l_location_profile_rec.address2 := l_address2;
            l_location_profile_rec.address3 := l_address3;
            l_location_profile_rec.address4 := l_address4;

            IF(l_loc_components_rec.state IS NOT NULL) THEN
                l_location_profile_rec.prov_state_admin_code := l_loc_components_rec.state;
            ELSIF(l_loc_components_rec.province IS NOT NULL) THEN
                l_location_profile_rec.prov_state_admin_code := l_loc_components_rec.province;
            ELSE
                l_location_profile_rec.prov_state_admin_code := NULL;
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

       -- Call post_location_update to do post update process.
       -- 1. Update de-normalized location components in HZ_PARTIES
       -- 2. Call to indicate location update to DQM(HZ_DQM_SYNC.sync_location).
       -- 3. 6.	Invoke business event system.
       begin
          post_location_update( p_old_location_rec      => l_old_location_rec,
                                p_new_location_rec      => l_new_location_rec,
                                p_other_location_params => l_other_param_rec,
                                x_return_status         => ll_return_status,
                                x_msg_count             => ll_msg_count,
                                x_msg_data              => ll_msg_data );
       exception when others then
          null;
       end;
    END IF;
    END IF;

  END update_location;
--------------------------------------
 PROCEDURE create_gnr (
       p_location_id            IN number,
       p_location_table_name    IN varchar2,
       p_usage_code             IN varchar2,
       p_map_status             IN varchar2,
       p_loc_components_rec     IN  loc_components_rec_type,
       p_lock_flag              IN varchar2,
       p_map_dtls_tbl           IN maploc_rec_tbl_type,
       x_status                 OUT NOCOPY varchar2
 ) IS
  i number;
  l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRUB:HZ_GNR_UTIL_PKG';
  l_module        CONSTANT VARCHAR2(30) := 'ADDRESS_VALIDATION';
  l_debug_prefix           VARCHAR2(30) := p_location_id;
  l_retain_flag            VARCHAR2(10);
  l_map_dtls_tbl           maploc_rec_tbl_type;

  l_last_updated_by   NUMBER; -- hz_utility_v2pub.last_updated_by;
  l_creation_date     DATE;   -- hz_utility_v2pub.creation_date;
  l_created_by        NUMBER; -- hz_utility_v2pub.created_by;
  l_last_update_date  DATE;   -- hz_utility_v2pub.last_update_date;
  l_last_update_login NUMBER; -- hz_utility_v2pub.last_update_login;
  l_program_id        NUMBER; -- hz_utility_v2pub.program_id;
  l_conc_login_id     NUMBER; -- fnd_global.conc_login_id;
  l_program_application_id NUMBER; --hz_utility_v2pub.program_application_id;
  l_request_id        NUMBER; -- NVL(hz_utility_v2pub.request_id, -1);
  l_api_purpose       VARCHAR2(30);

  -- Created below 2 cursors for performance reasons (perf team advice)
  -- to avoid DUP_VAL_ON_INDEX exception which is proving very costly
  -- during upgrade (Bug 5929771 : Nishant 16-APR-2007)
  l_gnr_log_exist     VARCHAR2(10);
  l_gnr_exist         VARCHAR2(10);
  l_gnr_deleted       VARCHAR2(10);

  CURSOR c_check_gnr_log_exist (p_location_id NUMBER,
                                p_location_table_name VARCHAR2,
								p_usage_code VARCHAR2) IS
   SELECT 'Y'
   FROM   hz_geo_name_reference_log
   WHERE  location_id = p_location_id
   AND    location_table_name = p_location_table_name
   AND    usage_code  = p_usage_code
  ;

  CURSOR c_check_gnr_exist (p_location_id NUMBER,
                            p_location_table_name VARCHAR2,
							p_geography_type VARCHAR2) IS
   SELECT 'Y'
   FROM   hz_geo_name_references
   WHERE  location_id = p_location_id
   AND    location_table_name = p_location_table_name
   AND    geography_type  = p_geography_type
  ;

  FUNCTION update_loc_yn(
       p_loc_components_rec     IN  loc_components_rec_type,
       p_map_dtls_tbl           IN maploc_rec_tbl_type
    ) RETURN VARCHAR2 IS
    l_map_dtls_tbl maploc_rec_tbl_type;
    l_status varchar2(1);
    l_return varchar2(1);
    i number;
    j number;
  BEGIN
    l_return := 'N';
    l_map_dtls_tbl := p_map_dtls_tbl; -- This will populate all the derived Geography IDs
    getLocCompValues(
         P_loc_table            => 'HZ_LOCATIONS',
         p_loc_components_rec   => p_loc_components_rec,
         x_map_dtls_tbl         => l_map_dtls_tbl,
         x_status               => l_status);

    IF p_map_dtls_tbl.COUNT > 0 THEN
      i := p_map_dtls_tbl.FIRST;
      LOOP
        IF p_map_dtls_tbl(i).GEOGRAPHY_ID IS NULL THEN
          EXIT;
        END IF;

        IF l_map_dtls_tbl.COUNT > 0 THEN
          j := l_map_dtls_tbl.FIRST;
          LOOP
            IF p_map_dtls_tbl(i).GEOGRAPHY_ID = l_map_dtls_tbl(j).GEOGRAPHY_ID THEN
              -- Fix for Bug 5231893 (added UPPER to do case insensitive comaprison
              -- Added on 18-May-2006 Nishant)
              IF NVL(UPPER(p_map_dtls_tbl(i).LOC_COMPVAL),FND_API.G_MISS_CHAR) <>
                 NVL(UPPER(l_map_dtls_tbl(j).LOC_COMPVAL),FND_API.G_MISS_CHAR) THEN
                l_return := 'Y';
              END IF;
            END IF;
            EXIT WHEN j = l_map_dtls_tbl.LAST;
            j := l_map_dtls_tbl.NEXT(j);
          END LOOP;
        END IF;

        EXIT WHEN i = p_map_dtls_tbl.LAST;
        i := p_map_dtls_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN l_return;
  END update_loc_yn;

  FUNCTION retain_gnr_yn(
       p_location_id            IN number,
       p_map_status             IN varchar2,
       p_map_dtls_tbl           IN maploc_rec_tbl_type
    ) RETURN VARCHAR2 IS
    l_map_dtls_tbl maploc_rec_tbl_type;
    l_old_map_status varchar2(1);
    l_geography_type varchar2(30);
    l_retain varchar2(1);
    i number;
    j number;

    cursor get_old_map_status is
    select map_status
    from   HZ_GEO_NAME_REFERENCE_LOG
    where  location_id = p_location_id
    and    map_status = 'S';

    cursor get_gnr_superloc_rec is
    select geography_type
    from   HZ_GEO_NAME_REFERENCES
    where  location_id = p_location_id
    and    geography_id in (-99,-98);

  BEGIN
    l_retain := 'N';
    l_old_map_status := 'E';

    OPEN get_old_map_status;
    FETCH get_old_map_status INTO l_old_map_status;
    IF get_old_map_status%NOTFOUND THEN
       l_old_map_status := 'E';
    END IF;
    CLOSE get_old_map_status;

    -- If old status is Success and new is Error,
    -- Check for nay record in gnr table is a Super Loc
    -- If yes, retain the old one
    if l_old_map_status = 'S' and p_map_status = 'E' then

       OPEN get_gnr_superloc_rec;
       LOOP
          FETCH get_gnr_superloc_rec INTO l_geography_type;
          EXIT WHEN get_gnr_superloc_rec%NOTFOUND;
             IF p_map_dtls_tbl.COUNT > 0 THEN
                j := l_map_dtls_tbl.FIRST;
                l_retain := 'Y';
                LOOP
                IF p_map_dtls_tbl(j).GEOGRAPHY_TYPE = l_geography_type THEN
                   if ( nvl(p_map_dtls_tbl(j).GEOGRAPHY_CODE,'NOVALUE') = 'MISSING'  OR
                        nvl(p_map_dtls_tbl(j).GEOGRAPHY_CODE,'NOVALUE') = 'UNKNOWN' ) THEN
                      l_retain := 'N';
                      EXIT;
                   end if;
                END IF;
                EXIT WHEN j = p_map_dtls_tbl.LAST;
                j := p_map_dtls_tbl.NEXT(j);
                END LOOP;
                IF l_retain = 'Y' THEN
                   EXIT;
                END IF;
             END IF;
       END LOOP;
       CLOSE get_gnr_superloc_rec;
    else
       l_retain := 'N';
    end if;

    RETURN l_retain;
  END retain_gnr_yn;

 BEGIN

   -- Initialize variables (perf improvement bug 5130993)
   l_last_updated_by   := hz_utility_v2pub.last_updated_by;
   l_creation_date     := hz_utility_v2pub.creation_date;
   l_created_by        := hz_utility_v2pub.created_by;
   l_last_update_date  := hz_utility_v2pub.last_update_date;
   l_last_update_login := hz_utility_v2pub.last_update_login;
   l_program_id        := hz_utility_v2pub.program_id;
   l_conc_login_id     := fnd_global.conc_login_id;
   l_program_application_id := hz_utility_v2pub.program_application_id;
   l_request_id        := NVL(hz_utility_v2pub.request_id, -1);
   l_api_purpose       := HZ_GNR_PKG.G_API_PURPOSE;

   x_status := FND_API.g_ret_sts_success;

   -- retain_gnr_yn will tell whether we have retain old GNR records or not.
   -- If l_retain_flag = 'Y' then exit without ceate/update of GNR and hz_location

   -- Check if call is for R12UPGRADE then we do not want to do retain_gnr_check at all
   -- This Global variable is set in HZ_GNR_PKG during making call to create GNR for R12UPGRADE
   IF ( NVL(l_api_purpose,'xxya') = 'R12UPGRADE') THEN
     l_retain_flag := 'N';
   ELSE
     l_retain_flag := retain_gnr_yn(p_location_id, p_map_status, p_map_dtls_tbl);
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
        (p_message      => 'Retain GNR Flag value l_retain_flag='||l_retain_flag,
         p_prefix        => l_debug_prefix,
         p_msg_level     => fnd_log.level_statement,
         p_module_prefix => l_module_prefix,
         p_module        => l_module
         );
   END IF;

   IF l_retain_flag = 'N' THEN -- Then only do the processing of GNR, otherwise keep old value

     l_map_dtls_tbl := p_map_dtls_tbl;

     BEGIN

       -- Bug 5929771 : Check unique value existence before inserting to avoid
       -- expensive DUP_VAL_ON_INDEX exception (Nishant 16-APR-2007)
       OPEN c_check_gnr_log_exist(p_location_id,p_location_table_name,p_usage_code);
       FETCH c_check_gnr_log_exist INTO l_gnr_log_exist;
       l_gnr_log_exist := NVL(l_gnr_log_exist,'N');
  	   CLOSE c_check_gnr_log_exist;

       IF (l_gnr_log_exist <> 'Y') THEN

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
               (p_message      => 'Before inserting record into hz_geo_name_reference_log with map status '||p_map_status,
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
         END IF;

         INSERT INTO hz_geo_name_reference_log
           (location_id, location_table_name,usage_code,
            message_text,
            object_version_number, map_status,
            last_updated_by, creation_date,
            created_by, last_update_date,
            last_update_login, program_id,
            program_login_id,program_application_id,request_id)
         VALUES
           (p_location_id, p_location_table_name, p_usage_code, NULL, 1, p_map_status,
            l_last_updated_by, l_creation_date,
            l_created_by, l_last_update_date,
            l_last_update_login, l_program_id,
            l_conc_login_id, l_program_application_id, l_request_id);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
               (p_message      => 'After inserting record into hz_geo_name_reference_log ',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
         END IF;

       ELSE -- GNR Log already exists, we will update it

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
              (p_message      => 'Before updating record into hz_geo_name_reference_log with map status '||p_map_status,
               p_prefix        => l_debug_prefix,
               p_msg_level     => fnd_log.level_statement,
               p_module_prefix => l_module_prefix,
               p_module        => l_module
              );
         END IF;

         UPDATE hz_geo_name_reference_log
         SET    map_status = p_map_status,
                object_version_number = object_version_number + 1,
                last_updated_by = l_last_updated_by,
                last_update_date = l_last_update_date,
                last_update_login = l_last_update_login
         WHERE  location_id = p_location_id
         AND    location_table_name = p_location_table_name
         AND    usage_code = p_usage_code;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             hz_utility_v2pub.debug
                (p_message      => 'After updating record into hz_geo_name_reference_log ',
                 p_prefix        => l_debug_prefix,
                 p_msg_level     => fnd_log.level_statement,
                 p_module_prefix => l_module_prefix,
                 p_module        => l_module
                );
          END IF;

          -- delete the location id and table name combination from hz_geo_name_references
          -- This call is needed only if data exists in hz_geo_name_references table
          -- blind delete is bad for performance
          IF ( nvl(l_api_purpose,'xxya') <> 'R12UPGRADE') THEN
            delGNR(p_location_id,p_location_table_name,x_status);
            l_gnr_deleted := 'Y'; -- set it to 'Y' because we just deleted it. Later we can avoid again doing this check
	      END IF;

       END IF; -- end of check if l_gnr_log_exist

     EXCEPTION WHEN DUP_VAL_ON_INDEX THEN -- should not hit this error anymore (bug 5929771)
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
                (p_message      => 'EXCEPTION DUP_VAL_ON_INDEX during GNR Log insert/update for '||
	   		                       'Location Id:'||p_location_id||',usage_code:'||p_usage_code||
				      			   ' -'||SUBSTR(SQLERRM,1,100),
                 p_prefix        => l_debug_prefix,
                 p_msg_level     => fnd_log.level_statement,
                 p_module_prefix => l_module_prefix,
                 p_module        => l_module
                );
         END IF;
      END; -- END of GNR Log Insert BEGIN Stmt

      -- Now Insert data in hz_geo_name_references table (Child table)
      IF p_map_dtls_tbl.COUNT > 0 THEN

        i := p_map_dtls_tbl.FIRST;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => 'Before inserting records into hz_geo_name_references ',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;

        LOOP
          -- intialize l_gnr_exist
		  l_gnr_exist := NULL;

          IF p_map_dtls_tbl(i).geography_id IS NOT NULL THEN

             IF p_map_dtls_tbl(i).geography_code = 'MISSING' THEN
                l_map_dtls_tbl(i).geography_id := -99;
                l_map_dtls_tbl(i).loc_compval := NULL;
             ELSIF p_map_dtls_tbl(i).geography_code = 'UNKNOWN' THEN
                l_map_dtls_tbl(i).geography_id := -98;
                l_map_dtls_tbl(i).loc_compval := NULL;
             END IF;

             BEGIN
               -- Bug 5929771 : Check unique value existence before inserting to avoid
               -- expensive DUP_VAL_ON_INDEX exception (Nishant 16-APR-2007)
               -- If it was existing before, we would have deleted it when we checked
               -- existence in GNR Log table (above).
               -- if data already deleted above then no need to perform existence check here.
               IF (l_gnr_deleted = 'Y' ) THEN
                 l_gnr_exist := 'N';
               ELSE
    			 OPEN c_check_gnr_exist(p_location_id,p_location_table_name,p_map_dtls_tbl(i).geography_type);
                 FETCH c_check_gnr_exist INTO l_gnr_exist;
                 l_gnr_exist := NVL(l_gnr_exist,'N');
                 CLOSE c_check_gnr_exist;
               END IF;

               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  hz_utility_v2pub.debug
                       (p_message      => 'For Location Id:'||p_location_id||',geo type:'||
			                               p_map_dtls_tbl(i).geography_type||', GNR Exists :'||l_gnr_exist,
                        p_prefix        => l_debug_prefix,
                        p_msg_level     => fnd_log.level_statement,
                        p_module_prefix => l_module_prefix,
                        p_module        => l_module
                       );
               END IF;

               IF (l_gnr_exist <> 'Y') THEN
                  INSERT INTO hz_geo_name_references
                    (location_id, geography_id, location_table_name,
                     object_version_number, geography_type, last_updated_by,
                     creation_date, created_by, last_update_date,
                     last_update_login, program_id, program_login_id,
                     program_application_id,request_id)
                  VALUES
                     (p_location_id, l_map_dtls_tbl(i).geography_id,p_location_table_name,
                     1, p_map_dtls_tbl(i).geography_type, l_last_updated_by,
                     l_creation_date, l_created_by,
                     l_last_update_date, l_last_update_login,
                     l_program_id, l_conc_login_id,
                     l_program_application_id, l_request_id);
               END IF;

             EXCEPTION WHEN DUP_VAL_ON_INDEX THEN -- should not hit this error anymore (bug 5929771)
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  hz_utility_v2pub.debug
                  (p_message      => 'EXCEPTION DUP_VAL_ON_INDEX during GNR insert/update for '||
			                         'Location Id:'||p_location_id||',geo_type:'||p_map_dtls_tbl(i).geography_type||
					   		   	     ' -'||SUBSTR(SQLERRM,1,100),
                   p_prefix        => l_debug_prefix,
                   p_msg_level     => fnd_log.level_statement,
                   p_module_prefix => l_module_prefix,
                   p_module        => l_module
                 );
              END IF;
            END; -- End of BEGIN for inserting in GNR Log

          ELSE -- geography_id = NULL
            EXIT;
          END IF; -- End of geography id is NOT NULL check

          EXIT WHEN i = p_map_dtls_tbl.LAST;
          i := p_map_dtls_tbl.NEXT(i);
        END LOOP;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
             (p_message      => 'After inserting records into hz_geo_name_references ',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
        END IF;

      END IF; -- END OF p_map_dtls_table.count > 0 check for inserting into GNR tables

      -- Update Location not to be done for GNR calls, only for Online Validate API
      IF ((NVL(l_api_purpose,'xxya') NOT IN ('R12UPGRADE','GNR'))
	     AND
     	  (p_location_table_name = 'HZ_LOCATIONS'
	       AND
		   update_loc_yn(p_loc_components_rec,l_map_dtls_tbl) = 'Y')) THEN

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
               (p_message      => 'Before updating record into update_location ',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;

        update_location (p_location_id, p_loc_components_rec,p_lock_flag, l_map_dtls_tbl,x_status);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
             (p_message      => 'After updating record into update_location ',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
        END IF;

      END IF; -- END of update_location

   END IF; -- END of retain_gnr check

 EXCEPTION WHEN OTHERS THEN
   x_status :=  fnd_api.g_ret_sts_unexp_error;
    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
            (p_message      => 'EXCEPTION during create_gnr for '||
		                       'Location Id:'||p_location_id||',usage_code:'||p_usage_code||
 								' -'||SUBSTR(SQLERRM,1,100),
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_exception,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
      END IF;
 END create_gnr;
--------------------------------------
--------------------------------------
FUNCTION check_GNR_For_Usage(
  p_location_id           IN NUMBER,
  p_location_table_name   IN VARCHAR2,
  p_usage_code            IN VARCHAR2,
  p_mdu_tbl               IN maploc_rec_tbl_type,
  x_status                OUT NOCOPY varchar2
 ) RETURN BOOLEAN IS

  CURSOR c_gnr(p_geography_type in varchar2) IS
  SELECT GEOGRAPHY_ID
  FROM   HZ_GEO_NAME_REFERENCES
  WHERE  LOCATION_ID = p_location_id
  AND    GEOGRAPHY_TYPE = p_geography_type
  AND    LOCATION_TABLE_NAME = p_location_table_name;

  CURSOR c_gnr_log IS
  SELECT MAP_STATUS,USAGE_CODE
  FROm   HZ_GEO_NAME_REFERENCE_LOG
  WHERE  LOCATION_ID = p_location_id
  AND    LOCATION_TABLE_NAME = p_location_table_name;

  l_gnr_exists varchar2(1);
  l_success varchar2(1);
  l_usage_log_exists varchar2(1);
  l_geography_id number;
  i number;

  l_last_updated_by   NUMBER; -- hz_utility_v2pub.last_updated_by;
  l_creation_date     DATE;   -- hz_utility_v2pub.creation_date;
  l_created_by        NUMBER; -- hz_utility_v2pub.created_by;
  l_last_update_date  DATE;   -- hz_utility_v2pub.last_update_date;
  l_last_update_login NUMBER; -- hz_utility_v2pub.last_update_login;
  l_program_id        NUMBER; -- hz_utility_v2pub.program_id;
  l_conc_login_id     NUMBER; -- fnd_global.conc_login_id;
  l_program_application_id NUMBER; --hz_utility_v2pub.program_application_id;
  l_request_id        NUMBER; -- NVL(hz_utility_v2pub.request_id, -1);

BEGIN

  -- Initialize variables (perf improvement bug 5130993)
  l_last_updated_by   := hz_utility_v2pub.last_updated_by;
  l_creation_date     := hz_utility_v2pub.creation_date;
  l_created_by        := hz_utility_v2pub.created_by;
  l_last_update_date  := hz_utility_v2pub.last_update_date;
  l_last_update_login := hz_utility_v2pub.last_update_login;
  l_program_id        := hz_utility_v2pub.program_id;
  l_conc_login_id     := fnd_global.conc_login_id;
  l_program_application_id := hz_utility_v2pub.program_application_id;
  l_request_id        := NVL(hz_utility_v2pub.request_id, -1);

  x_status := FND_API.g_ret_sts_success;

  l_success := 'N';
  l_usage_log_exists := 'N';
  FOR l_c_gnr_log IN c_gnr_log LOOP
    l_gnr_exists := 'Y';
    IF l_c_gnr_log.USAGE_CODE = p_usage_code THEN
      IF l_c_gnr_log.MAP_STATUS = 'S' THEN
        RETURN TRUE;
      ELSE
        l_usage_log_exists := 'Y';
      END IF;
    END IF;
  END LOOP;

  IF l_gnr_exists = 'Y' THEN
    l_success := 'Y';
    IF p_mdu_tbl.COUNT > 0 THEN
      i := p_mdu_tbl.FIRST;
      LOOP

        OPEN c_gnr(p_mdu_tbl(i).GEOGRAPHY_TYPE);
        FETCH c_gnr INTO l_geography_id;
        IF c_gnr%NOTFOUND THEN
          l_success := 'N';
        END IF;
        CLOSE c_gnr;
        EXIT WHEN i = p_mdu_tbl.LAST;
        i := p_mdu_tbl.NEXT(i);
      END LOOP;
    END IF;
  END IF;

  IF l_success = 'Y' THEN
    IF l_usage_log_exists = 'Y' THEN
      UPDATE hz_geo_name_reference_log
      SET    map_status = 'S',
             object_version_number = object_version_number + 1,
             last_updated_by = l_last_updated_by,
             last_update_date = l_last_update_date,
             last_update_login = l_last_update_login
      WHERE  location_id = p_location_id
      AND    location_table_name = p_location_table_name
      AND    usage_code = p_usage_code;
    ELSE
      INSERT INTO hz_geo_name_reference_log
         (location_id, location_table_name,usage_code,
          message_text,
          object_version_number, map_status,
          last_updated_by, creation_date,
          created_by, last_update_date,
          last_update_login, program_id,
          program_login_id,program_application_id,request_id)
      VALUES
         (p_location_id, p_location_table_name, p_usage_code, NULL, 1, 'S',
          l_last_updated_by,l_creation_date,
          l_created_by, l_last_update_date,
          l_last_update_login,l_program_id,
          l_conc_login_id, l_program_application_id,
          l_request_id);
    END IF;
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  RETURN FALSE;
EXCEPTION WHEN OTHERS THEN
  x_status :=  fnd_api.g_ret_sts_unexp_error;
  RETURN FALSE;
END check_GNR_For_Usage;
--------------------------------------
--------------------------------------
FUNCTION fix_multiparent(
   p_geography_id         IN NUMBER,
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type
 ) RETURN BOOLEAN IS
  i number;
  l_parent_geography_id number;
  l_parent_geography_type varchar2(30);
BEGIN
  IF x_map_dtls_tbl.COUNT > 0 THEN
    i:= x_map_dtls_tbl.FIRST;
    LOOP
      IF x_map_dtls_tbl(i).GEOGRAPHY_ID = p_geography_id THEN
        RETURN TRUE;
      END IF;

      IF (x_map_dtls_tbl(i).GEOGRAPHY_ID IS NULL AND x_map_dtls_tbl(i).LOC_COMPVAL IS NULL) THEN
        -- This is a multiple parent case and user has not passed in a value to identify a unique record.
        -- MUST be done later. (two level missing, second level value passed. If we can identify the record, it will still fail)
        -- Need to think about a new logic.
        RETURN FALSE;
      END IF;

      IF (x_map_dtls_tbl(i).GEOGRAPHY_ID IS NULL AND x_map_dtls_tbl(i).LOC_COMPVAL IS NOT NULL) THEN
      BEGIN
        SELECT g.GEOGRAPHY_ID
        INTO   x_map_dtls_tbl(i).GEOGRAPHY_ID
        FROM   HZ_GEOGRAPHIES g,HZ_HIERARCHY_NODES hn
        WHERE  g.GEOGRAPHY_ID = hn.CHILD_ID
        AND    g.GEOGRAPHY_TYPE = hn.CHILD_OBJECT_TYPE
        AND    hn.CHILD_TABLE_NAME = 'HZ_GEOGRAPHIES'
        AND    hn.HIERARCHY_TYPE  = 'MASTER_REF'
        AND    hn.PARENT_TABLE_NAME = 'HZ_GEOGRAPHIES'
        AND    hn.PARENT_ID  = l_parent_geography_id
        AND    hn.PARENT_OBJECT_TYPE = l_parent_geography_type
        AND    SYSDATE between hn.EFFECTIVE_START_DATE AND hn.EFFECTIVE_END_DATE
        AND    SYSDATE BETWEEN g.START_DATE AND g.END_DATE
        AND    EXISTS (SELECT NULL
                       FROM   HZ_GEOGRAPHY_IDENTIFIERS gi
                       WHERE  g.GEOGRAPHY_ID = gi.GEOGRAPHY_ID
                       AND    gi.GEOGRAPHY_TYPE = g.GEOGRAPHY_TYPE
                       AND    gi.GEOGRAPHY_USE = 'MASTER_REF'
                       AND    upper(gi.IDENTIFIER_VALUE) = upper(x_map_dtls_tbl(i).LOC_COMPVAL));
      EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
      END;
      END IF;

      l_parent_geography_id   := x_map_dtls_tbl(i).GEOGRAPHY_ID;
      l_parent_geography_type := x_map_dtls_tbl(i).GEOGRAPHY_TYPE;
      EXIT WHEN i = x_map_dtls_tbl.LAST;
      i := x_map_dtls_tbl.NEXT(i);
    END LOOP;
  END IF;
  RETURN TRUE;
END fix_multiparent;
--------------------------------------
-------------------------------------
PROCEDURE fix_no_match(
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 ) IS
  l_map_dtls_tbl         maploc_rec_tbl_type;
  l_map_dtls_tbl_null         maploc_rec_tbl_type;

  PROCEDURE prcess_no_match(
     p_iteration            IN NUMBER,
     p_country_geo_id       IN NUMBER,
     x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type,
     x_status               OUT NOCOPY VARCHAR2
   ) IS

    i number;
    l_child_geography_id   number;
    l_geography_id         number;
    l_geography_name       varchar2(360);
    l_child_geography_type varchar2(30);
    l_country_geo_type     varchar2(30);

  BEGIN
    x_status := FND_API.g_ret_sts_success;

    --hk_debugl('Iteration : '||to_char(p_iteration));
    l_country_geo_type := 'COUNTRY';

    IF p_iteration = 1 THEN
      l_child_geography_id   := NULL;
      l_child_geography_type := NULL;
    ELSE
      l_child_geography_id   := x_map_dtls_tbl(p_iteration-1).GEOGRAPHY_ID;
      l_child_geography_type := x_map_dtls_tbl(p_iteration-1).GEOGRAPHY_TYPE;
    END IF;

    IF x_map_dtls_tbl(p_iteration).LOC_COMPVAL IS NULL THEN
      IF l_child_geography_id IS NOT NULL THEN
        BEGIN
          SELECT g.GEOGRAPHY_ID,g.GEOGRAPHY_NAME
          INTO   l_geography_id,l_geography_name
          FROM   HZ_GEOGRAPHIES g,HZ_HIERARCHY_NODES hn
          WHERE  g.GEOGRAPHY_ID = hn.PARENT_ID
          AND    g.GEOGRAPHY_TYPE = hn.PARENT_OBJECT_TYPE
          AND    hn.PARENT_TABLE_NAME = 'HZ_GEOGRAPHIES'
          AND    hn.HIERARCHY_TYPE  = 'MASTER_REF'
          AND    hn.level_number = 1
          AND    hn.CHILD_TABLE_NAME = 'HZ_GEOGRAPHIES'
          AND    hn.CHILD_ID  = l_child_geography_id
          AND    hn.CHILD_OBJECT_TYPE = l_child_geography_type
          AND    SYSDATE between hn.EFFECTIVE_START_DATE AND hn.EFFECTIVE_END_DATE
          AND    SYSDATE BETWEEN g.START_DATE AND g.END_DATE;

          x_map_dtls_tbl(p_iteration).GEOGRAPHY_ID := l_geography_id;
          x_map_dtls_tbl(p_iteration).LOC_COMPVAL := l_geography_name;

        --hk_debugl('Case 1');
        EXCEPTION WHEN OTHERS THEN
          --hk_debugl('Case 1 Exception');
          --hk_debugl('Child Geo : '||to_char(l_child_geography_id));
          --hk_debugl('Child Geo Type : '||l_child_geography_type);
          NULL;
        END;
      END IF;
    ELSE -- Location component value is not null
      IF l_child_geography_id IS NOT NULL THEN
        BEGIN
          SELECT g.GEOGRAPHY_ID,g.GEOGRAPHY_NAME
          INTO   l_geography_id,l_geography_name
          FROM   HZ_GEOGRAPHIES g,HZ_HIERARCHY_NODES hn
-- Nishant
          --WHERE  g.GEOGRAPHY_ID = hn.PARENT_ID
          WHERE  g.GEOGRAPHY_ID = hn.PARENT_ID+0
          AND    g.GEOGRAPHY_TYPE = hn.PARENT_OBJECT_TYPE
          AND    hn.PARENT_TABLE_NAME = 'HZ_GEOGRAPHIES'
          AND    hn.HIERARCHY_TYPE  = 'MASTER_REF'
          AND    hn.level_number = 1
          AND    hn.CHILD_TABLE_NAME = 'HZ_GEOGRAPHIES'
          AND    hn.CHILD_ID  = l_child_geography_id
          AND    hn.CHILD_OBJECT_TYPE = l_child_geography_type
          AND    SYSDATE BETWEEN hn.EFFECTIVE_START_DATE AND hn.EFFECTIVE_END_DATE
          AND    SYSDATE BETWEEN g.START_DATE AND g.END_DATE
          AND    EXISTS (SELECT NULL
                         FROM   HZ_GEOGRAPHY_IDENTIFIERS gi
                         WHERE  g.GEOGRAPHY_ID = gi.GEOGRAPHY_ID
                         AND    gi.GEOGRAPHY_TYPE = g.GEOGRAPHY_TYPE
                         AND    gi.geography_type = x_map_dtls_tbl(p_iteration).GEOGRAPHY_TYPE
                         AND    gi.GEOGRAPHY_USE = 'MASTER_REF'
                         AND    upper(gi.IDENTIFIER_VALUE) = upper(x_map_dtls_tbl(p_iteration).LOC_COMPVAL));

          x_map_dtls_tbl(p_iteration).GEOGRAPHY_ID := l_geography_id;
          x_map_dtls_tbl(p_iteration).LOC_COMPVAL := l_geography_name;

        --hk_debugl('Case 2');
        EXCEPTION WHEN OTHERS THEN
          --hk_debugl('Case 2 Exception');
          --hk_debugl('Child Geo : '||to_char(l_child_geography_id));
          --hk_debugl('Child Geo Type : '||l_child_geography_type);
          --hk_debugl('Geography Type : '||x_map_dtls_tbl(p_iteration).GEOGRAPHY_TYPE);
          --hk_debugl('Loc Comp Val : '||x_map_dtls_tbl(p_iteration).LOC_COMPVAL);
          NULL;
        END;
      ELSE -- Loc compoent value is not null and child_geo_id is null
        BEGIN
          SELECT g.GEOGRAPHY_ID,g.GEOGRAPHY_NAME
          INTO   l_geography_id,l_geography_name
          FROM   HZ_GEOGRAPHIES g,HZ_HIERARCHY_NODES hn
          WHERE  g.GEOGRAPHY_ID = hn.CHILD_ID
          AND    g.GEOGRAPHY_TYPE = hn.CHILD_OBJECT_TYPE
          AND    hn.CHILD_TABLE_NAME = 'HZ_GEOGRAPHIES'
          AND    hn.HIERARCHY_TYPE  = 'MASTER_REF'
          AND    hn.level_number = x_map_dtls_tbl(p_iteration).LOC_SEQ_NUM - 1
          AND    hn.PARENT_TABLE_NAME = 'HZ_GEOGRAPHIES'
          AND    hn.PARENT_ID+0  = p_country_geo_id
          AND    hn.PARENT_OBJECT_TYPE = l_country_geo_type
          AND    SYSDATE BETWEEN hn.EFFECTIVE_START_DATE AND hn.EFFECTIVE_END_DATE
          AND    SYSDATE BETWEEN g.START_DATE AND g.END_DATE
          AND    EXISTS (SELECT NULL
                         FROM   HZ_GEOGRAPHY_IDENTIFIERS gi
                         WHERE  g.GEOGRAPHY_ID = gi.GEOGRAPHY_ID
                         AND    gi.GEOGRAPHY_TYPE = g.GEOGRAPHY_TYPE
                         AND    gi.GEOGRAPHY_USE = 'MASTER_REF'
                         AND    gi.geography_type = x_map_dtls_tbl(p_iteration).GEOGRAPHY_TYPE
                         AND    upper(gi.IDENTIFIER_VALUE) = upper(x_map_dtls_tbl(p_iteration).LOC_COMPVAL));

          x_map_dtls_tbl(p_iteration).GEOGRAPHY_ID := l_geography_id;
          x_map_dtls_tbl(p_iteration).LOC_COMPVAL := l_geography_name;

        --hk_debugl('Case 3');
        EXCEPTION WHEN OTHERS THEN
          --hk_debugl('Case 3 Exception');
          --hk_debugl('Country Geo : '||to_char(p_country_geo_id));
          --hk_debugl('Geography Type : '||x_map_dtls_tbl(p_iteration).GEOGRAPHY_TYPE);
          --hk_debugl('Loc Comp Val : '||x_map_dtls_tbl(p_iteration).LOC_COMPVAL);
          NULL;
        END;
      END IF;
    END IF;

    IF p_iteration < x_map_dtls_tbl.COUNT - 1 THEN
      prcess_no_match(p_iteration+1,p_country_geo_id,x_map_dtls_tbl,x_status);
    END IF;

  END prcess_no_match;
BEGIN
  x_status := FND_API.g_ret_sts_success;
  IF x_map_dtls_tbl.COUNT > 0 THEN
    reverse_tbl(x_map_dtls_tbl,l_map_dtls_tbl);
  END IF;

  prcess_no_match(1,x_map_dtls_tbl(1).GEOGRAPHY_ID,l_map_dtls_tbl,x_status);

  x_map_dtls_tbl := l_map_dtls_tbl_null;
  reverse_tbl(l_map_dtls_tbl,x_map_dtls_tbl);
END fix_no_match;
--------------------------------------
--------------------------------------
PROCEDURE getMinValStatus(
   p_mdu_tbl             IN  maploc_rec_tbl_type,
   x_status               IN  OUT NOCOPY VARCHAR2
 ) IS
  i number;
BEGIN
  -- If there is null component value found this API will return status "E'. If all components are not null
  -- Then success status will be returned.  else it will return the status that came in.
  IF p_mdu_tbl.COUNT > 0 THEN
    i := p_mdu_tbl.FIRST;
    LOOP
      If p_mdu_tbl(i).LOC_COMPVAL IS NULL THEN
        x_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
      EXIT WHEN i = p_mdu_tbl.LAST;
      i := p_mdu_tbl.NEXT(i);
    END LOOP;
    x_status := FND_API.g_ret_sts_success;

  END IF;
END getMinValStatus;
--------------------------------------
--------------------------------------
FUNCTION fix_child(
   x_map_dtls_tbl         IN  OUT NOCOPY maploc_rec_tbl_type
 ) RETURN BOOLEAN IS
  i number;
  l_parent_geography_id number;
  l_parent_geography_type varchar2(30);
BEGIN
  IF x_map_dtls_tbl.COUNT > 0 THEN
    i:= x_map_dtls_tbl.FIRST;
    LOOP
      IF (x_map_dtls_tbl(i).GEOGRAPHY_ID IS NULL AND x_map_dtls_tbl(i).LOC_COMPVAL IS NULL) THEN
      BEGIN
        SELECT hn.CHILD_ID
        INTO   x_map_dtls_tbl(i).GEOGRAPHY_ID
        FROM   HZ_HIERARCHY_NODES hn
        WHERE  hn.CHILD_OBJECT_TYPE = x_map_dtls_tbl(i).GEOGRAPHY_TYPE
        AND    hn.CHILD_TABLE_NAME = 'HZ_GEOGRAPHIES'
        AND    hn.HIERARCHY_TYPE  = 'MASTER_REF'
        AND    hn.PARENT_TABLE_NAME = 'HZ_GEOGRAPHIES'
        AND    hn.PARENT_ID  = l_parent_geography_id
        AND    hn.PARENT_OBJECT_TYPE = l_parent_geography_type
        AND    SYSDATE BETWEEN hn.EFFECTIVE_START_DATE AND hn.EFFECTIVE_END_DATE;
      EXCEPTION WHEN OTHERS THEN
        RETURN FALSE;
      END;
      END IF;

      l_parent_geography_id   := x_map_dtls_tbl(i).GEOGRAPHY_ID;
      l_parent_geography_type := x_map_dtls_tbl(i).GEOGRAPHY_TYPE;
      EXIT WHEN i = x_map_dtls_tbl.LAST;
      i := x_map_dtls_tbl.NEXT(i);
    END LOOP;
  END IF;
  RETURN TRUE;
END fix_child;
--------------------------------------
--------------------------------------
FUNCTION getLocCompCount(
   p_map_dtls_tbl         IN  maploc_rec_tbl_type) RETURN NUMBER IS
  i number;
  j number;
BEGIN
  j := 0;
  IF p_map_dtls_tbl.COUNT > 1 THEN
    i:= p_map_dtls_tbl.FIRST;
    i:= p_map_dtls_tbl.NEXT(i);
    LOOP
      IF p_map_dtls_tbl(i).LOC_COMPVAL IS NOT NULL THEN
       j := j + 1;
      END IF;
      EXIT WHEN i = p_map_dtls_tbl.LAST;
      i := p_map_dtls_tbl.NEXT(i);
    END LOOP;
  END IF;
  RETURN j;
END getLocCompCount;
--------------------------------------
--------------------------------------
PROCEDURE getLocCompValues(
   P_loc_table            IN VARCHAR2,
   p_loc_components_rec   IN  loc_components_rec_type,
   x_map_dtls_tbl         IN OUT NOCOPY maploc_rec_tbl_type,
   x_status               OUT NOCOPY VARCHAR2
 ) IS

  TYPE NameValueRecType IS RECORD
   (Name varchar2(30),
    Value varchar2(150));
  TYPE NameValueTblType IS TABLE OF NameValueRecType
    INDEX BY BINARY_INTEGER;

  l_name_value NameValueTblType;
  i number :=0;

  FUNCTION getValue(p_name IN VARCHAR2) RETURN VARCHAR2 IS
    i number :=0;
  BEGIN
    IF l_name_value.COUNT > 0 THEN
      i := l_name_value.FIRST;
      LOOP
        IF l_name_value(i).name = p_name THEN
          RETURN l_name_value(i).value;
        END IF;
        EXIT WHEN i = l_name_value.LAST;
        i := l_name_value.NEXT(i);
      END LOOP;
    END IF;
    RETURN NULL;
  END;

BEGIN

  x_status := FND_API.g_ret_sts_success;
  l_name_value(2).name   := 'ADDRESS_STYLE';
  l_name_value(2).value  := p_loc_components_rec.ADDRESS_STYLE;
  l_name_value(3).name   := 'COUNTRY';
  l_name_value(3).value  := p_loc_components_rec.COUNTRY;
  l_name_value(4).name   := 'CITY';
  l_name_value(4).value  := p_loc_components_rec.CITY;
  l_name_value(5).name   := 'POSTAL_CODE';
  l_name_value(5).value  := p_loc_components_rec.POSTAL_CODE;
  l_name_value(6).name   := 'STATE';
  l_name_value(6).value  := p_loc_components_rec.STATE;
  l_name_value(7).name   := 'PROVINCE';
  l_name_value(7).value  := p_loc_components_rec.PROVINCE;
  l_name_value(8).name   := 'COUNTY';
  l_name_value(8).value  := p_loc_components_rec.COUNTY;
  l_name_value(9).name   := 'VALIDATE_COUNTRY_AGAINST';
  l_name_value(9).value  := p_loc_components_rec.VALIDATE_COUNTRY_AGAINST;
  l_name_value(10).name   := 'VALIDATE_STATE_AGAINST';
  l_name_value(10).value  := p_loc_components_rec.VALIDATE_STATE_AGAINST;
  l_name_value(11).name   := 'VALIDATE_PROVINCE_AGAINST';
  l_name_value(11).value  := p_loc_components_rec.VALIDATE_PROVINCE_AGAINST;
  l_name_value(12).name   := 'POSTAL_PLUS4_CODE';
  l_name_value(12).value  := p_loc_components_rec.POSTAL_PLUS4_CODE;
  l_name_value(13).name   := 'ATTRIBUTE1';
  l_name_value(13).value  := p_loc_components_rec.ATTRIBUTE1;
  l_name_value(14).name   := 'ATTRIBUTE2';
  l_name_value(14).value  := p_loc_components_rec.ATTRIBUTE2;
  l_name_value(15).name   := 'ATTRIBUTE3';
  l_name_value(15).value  := p_loc_components_rec.ATTRIBUTE3;
  l_name_value(16).name   := 'ATTRIBUTE4';
  l_name_value(16).value  := p_loc_components_rec.ATTRIBUTE4;
  l_name_value(17).name   := 'ATTRIBUTE5';
  l_name_value(17).value  := p_loc_components_rec.ATTRIBUTE5;
  l_name_value(18).name   := 'ATTRIBUTE6';
  l_name_value(18).value  := p_loc_components_rec.ATTRIBUTE6;
  l_name_value(19).name   := 'ATTRIBUTE7';
  l_name_value(19).value  := p_loc_components_rec.ATTRIBUTE7;
  l_name_value(20).name   := 'ATTRIBUTE8';
  l_name_value(20).value  := p_loc_components_rec.ATTRIBUTE8;
  l_name_value(21).name   := 'ATTRIBUTE9';
  l_name_value(21).value  := p_loc_components_rec.ATTRIBUTE9;
  l_name_value(22).name   := 'ATTRIBUTE10';
  l_name_value(22).value  := p_loc_components_rec.ATTRIBUTE10;

  IF x_map_dtls_tbl.COUNT > 0 THEN
    i := x_map_dtls_tbl.FIRST;
    LOOP
      x_map_dtls_tbl(i).LOC_COMPVAL := getValue(x_map_dtls_tbl(i).LOC_COMPONENT);
      EXIT WHEN i = x_map_dtls_tbl.LAST;
      i := x_map_dtls_tbl.NEXT(i);
    END LOOP;
  END IF;
END;

--------------------------------------
--------------------------------------
--ER#7240974
/**
   Function : postal_code_to_validate

  DESCRIPTION :
	Based on profile(HZ_VAL_FIRST_5_DIGIT_US_ZIP) value,
	it will return the postal code that needs to be validated.

  ARGUMENTS  :
     IN   p_country_code VARCHAR2
     IN   p_postal_code  VARCHAR2

  RETURNS : VARCHAR2
    postal code that needs to be validated


   MODIFICATION HISTORY:
     17-DEC-2008   Sudhir Gokavarapu    Created

**/

FUNCTION postal_code_to_validate(
   p_country_code         IN VARCHAR2,
   p_postal_code          IN VARCHAR2
 ) RETURN VARCHAR2 IS
BEGIN

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'In postal_code_to_validate Function ',
                                  p_prefix =>'INFO:',
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Country Code : ' || p_country_code||' Postal Code : '||p_postal_code,
                                  p_prefix =>'INFO:',
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Profile HZ_VAL_FIRST_5_DIGIT_US_ZIP Value : '||fnd_profile.value('HZ_VAL_FIRST_5_DIGIT_US_ZIP'),
                                  p_prefix =>'INFO:',
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

	IF p_postal_code IS NULL THEN
	  RETURN NULL;
	END IF;

	IF p_country_code = 'US' THEN
		IF fnd_profile.value('HZ_VAL_FIRST_5_DIGIT_US_ZIP') = 'N'  THEN
			    -- Debug info.
    				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           				hz_utility_v2pub.debug(p_message=>'Returned Postal Code : '||p_postal_code,
                                  p_prefix =>'INFO:',
                                  p_msg_level=>fnd_log.level_statement);
    				END IF;

		   RETURN p_postal_code;
		ELSE
			    -- Debug info.
    				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           				hz_utility_v2pub.debug(p_message=>'Returned Postal Code : '||SUBSTR(p_postal_code,1,5),
                                  p_prefix =>'INFO:',
                                  p_msg_level=>fnd_log.level_statement);
    				END IF;

		   RETURN SUBSTR(p_postal_code,1,5);
		END IF;
    ELSE
			    -- Debug info.
    				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           				hz_utility_v2pub.debug(p_message=>'Returned Postal Code : '||p_postal_code,
                                  p_prefix =>'INFO:',
                                  p_msg_level=>fnd_log.level_statement);
    				END IF;

		RETURN p_postal_code;
	END IF;
END;

END hz_gnr_util_pkg;

/
