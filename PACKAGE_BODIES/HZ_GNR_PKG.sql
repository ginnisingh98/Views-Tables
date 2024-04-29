--------------------------------------------------------
--  DDL for Package Body HZ_GNR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GNR_PKG" AS
/*$Header: ARHGNRCB.pls 120.28 2008/03/11 08:36:57 nshinde ship $ */

--  G_SUCCESS varchar2(30) := 'SUCCESS';
--  G_ERROR   varchar2(30) := 'ERROR';

------------
  -- New local procedure created to compile package for fixing bug 5521521
  -- This will be very rarely called only when Admin changes Geography setup
  -- and then tries to create address. (21-Sep-2006 Nishant)
  PROCEDURE recompile_pkg (p_pkg_name IN VARCHAR2)IS
    PRAGMA AUTONOMOUS_TRANSACTION;

	l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRCB:HZ_GNR_PKG';
    l_module        CONSTANT VARCHAR2(30) := 'ADDRESS_VALIDATION';
    l_debug_prefix  CONSTANT VARCHAR2(30) := '';

  BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
         (p_message      => 'Begin Compile Package '||p_pkg_name,
          p_prefix        => l_debug_prefix,
          p_msg_level     => fnd_log.level_statement,
          p_module_prefix => l_module_prefix,
          p_module        => l_module
         );
    END IF;

    EXECUTE IMMEDIATE 'ALTER PACKAGE '||p_pkg_name||' COMPILE';

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
         (p_message      => 'Completed Compiling Package '||p_pkg_name,
          p_prefix        => l_debug_prefix,
          p_msg_level     => fnd_log.level_statement,
          p_module_prefix => l_module_prefix,
          p_module        => l_module
         );
    END IF;

    COMMIT;
  EXCEPTION WHEN OTHERS THEN

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
         (p_message      => 'EXCEPTION during compiling Package '||p_pkg_name||
		                    ':'||SQLERRM,
          p_prefix        => l_debug_prefix,
          p_msg_level     => fnd_log.level_statement,
          p_module_prefix => l_module_prefix,
          p_module        => l_module
         );
    END IF;
    COMMIT;
  END recompile_pkg;
------------

  FUNCTION get_map_id(p_country in varchar2,p_loc_table in varchar2,p_address_style in varchar2) RETURN NUMBER IS
    l_map_id number;
    CURSOR c_map IS
    SELECT MAP_ID
    FROM   hz_geo_struct_map
    WHERE  COUNTRY_CODE = p_country
    AND    LOC_TBL_NAME = p_loc_table
    AND    NVL(ADDRESS_STYLE,'X_NOSTYLE_X') = NVL(p_address_style,'X_NOSTYLE_X');

    CURSOR c_style_null_map IS
    SELECT MAP_ID
    FROM   hz_geo_struct_map
    WHERE  COUNTRY_CODE = p_country
    AND    LOC_TBL_NAME = p_loc_table
    AND    ADDRESS_STYLE IS NULL;
  BEGIN
    OPEN  c_map;
    FETCH c_map INTO l_map_id;
    IF c_map%NOTFOUND THEN
      OPEN  c_style_null_map;
      FETCH c_style_null_map INTO l_map_id;
      CLOSE c_style_null_map;
    END IF;
    CLOSE c_map;
    RETURN l_map_id;
  END get_map_id;

  -- Added by Nishant on 24-Aug-2005 for fetching country code from
  -- HZ_GEOGRAPHY_IDENTIFIER. If no country code found, it will return
  -- back original passed in value.
  FUNCTION get_country_code(pv_country IN VARCHAR2) RETURN VARCHAR2 IS
    l_country_code VARCHAR2(10);

   CURSOR c_country_code (l_country VARCHAR2)IS
	SELECT hgo.identifier_value
	FROM   hz_geography_identifiers hgo
	WHERE  hgo.identifier_subtype = 'ISO_COUNTRY_CODE'
	AND    hgo.identifier_type = 'CODE'
	AND    hgo.geography_use = 'MASTER_REF'
	AND    hgo.geography_type = 'COUNTRY'
	AND    hgo.primary_flag  = 'Y' -- fix for bug 5400607 (Nishant 20-Jul-2006)
	AND    EXISTS ( SELECT '1'
	                FROM   hz_geography_identifiers hgi
	                WHERE  hgi.geography_use = 'MASTER_REF'
	                AND    hgi.geography_type = 'COUNTRY'
	                AND    hgi.geography_id = hgo.geography_id
	                AND    UPPER(hgi.identifier_value) = l_country
	               );

  BEGIN

    OPEN c_country_code (UPPER(pv_country));
    FETCH c_country_code INTO l_country_code;
    CLOSE c_country_code;

    -- If found country code, return it.
    -- Otherwise return back the passed in value.
	IF (l_country_code IS NOT NULL) THEN
	  RETURN l_country_code;
	ELSE
	  RETURN pv_country;
	END IF;

  END get_country_code;

/**
 *  Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA
 *                          All rights reserved.
 *=======================================================================
 * FILE       ARHGNRCB.pls
 *
 * PROCEDURE    create_geo_name_ref
 *
 * DESCRIPTION
 *     This is the procedure which is called by the
 *     concurrent request. This will spawn off the workers
 *
 * RELATED PACKAGES
 *
 * PUBLIC VARIABLES
 *
 * PUBLIC FUNCTIONS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   20-JAN-2003   Satyadeep           o Created.
 *                 Chandrashekar
 *   11-Oct-2005   Nishant Singhai     o Modified for bug 4645523. If no. of worker
 *                                       profile is set to 0 or less, then default it
 *                                       to 1.
 *   11-Mar-2008   Neeraj Shinde       o Modified for bug 6860045. Sub request should
 *                                       run immediately. Converted the scheduled time
 *                                       of sub request in 24 Hour format.
 */

PROCEDURE create_geo_name_ref (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_location_table_name   IN      VARCHAR2,
        p_run_type              IN      VARCHAR2,
        p_usage_code            IN      VARCHAR2,
        p_country_code          IN      VARCHAR2,
        p_from_location_id      IN      VARCHAR2,
        p_to_location_id        IN      VARCHAR2,
        p_start_date            IN      VARCHAR2,
        p_end_date              IN      VARCHAR2
) IS

  l_from_location_id   NUMBER;
  l_to_location_id     NUMBER;
  l_loc_tbl_name       VARCHAR2(30);
  l_start_date         DATE;
  l_end_date           DATE;
  l_num_of_workers     NUMBER;
  l_commit_size        NUMBER;
  l_usage_count        NUMBER;
  l_run_type_count     NUMBER;
  l_country_code_count NUMBER;

  TYPE nTable IS TABLE OF NUMBER index by binary_integer;
  l_sub_requests nTable;


BEGIN

  retcode := 0;

  HZ_GNR_UTIL_PKG.outandlog('Starting Concurrent Program ''Geo Name Referencing''');
  HZ_GNR_UTIL_PKG.outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  HZ_GNR_UTIL_PKG.outandlog('NEWLINE');

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  -- Validate location table name

  IF p_location_table_name IS NULL THEN

    FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_LOC_TABLE_MAND');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;

  ELSIF p_location_table_name NOT IN ( 'HR_LOCATIONS_ALL',
                                      'HZ_LOCATIONS') THEN

    FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_LOC_TABLE_INVALID');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;

  END IF;

  l_from_location_id := to_number(p_from_location_id);
  l_to_location_id   := to_number(p_to_location_id);
  l_start_date       := fnd_date.canonical_to_date(p_start_date);
  l_end_date         := fnd_date.canonical_to_date(p_end_date);


  -- Validate location range.
  -- Both location id from and location id to should be not null
  -- OR location id from can be passed location id to can be null
  -- OR both location id from and location id to should be null

  IF l_from_location_id IS NULL THEN
    IF l_to_location_id IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_TO_LOC_NOT_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF;
  ELSE
    IF l_to_location_id IS NULL THEN
      NULL;
    ELSE
      IF l_from_location_id > l_to_location_id THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_FROM_LOC_HIGHER');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;

  -- Validate Date parameters
  -- Both Start date and End date should be not null
  -- OR Start date can be passed End date can be null
  -- OR both Start date and End date should be null

  IF l_start_date IS NULL THEN
    IF l_end_date IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_TO_DATE_NOT_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF;
  ELSE
    IF l_end_date IS NULL THEN
      NULL;
    ELSE
      IF l_start_date > l_end_date THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_START_DATE_HIGHER');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;

  -- Validate Run Type parameter
  -- 1. Run Type is Mandatory.
  -- 2. It should be either 'ALL' or 'NEW' or 'ERROR' (seeded as lookup Type HZ_GEO_GNR_RUN_TYPE)
  -- If new run type is added, message text will have to be changed.
  IF (p_run_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_RUN_TYPE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  ELSE
      SELECT COUNT(*)
      INTO  l_run_type_count
      FROM  ar_lookups
      WHERE lookup_type = 'HZ_GEO_GNR_RUN_TYPE'
      AND   lookup_code = p_run_type
      AND   TRUNC(SYSDATE) BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active, SYSDATE+1)
      AND   enabled_flag = 'Y';

      IF (l_run_type_count = 0) THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_RUN_TYPE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  -- Validate USAGE Type parameter from seeded usage from ar_lookups for
  -- lookup Type HZ_GEOGRAPHY_USAGE
  IF (p_usage_code IS NOT NULL) THEN
    SELECT COUNT(*)
    INTO  l_usage_count
    FROM  ar_lookups
    WHERE lookup_type = 'HZ_GEOGRAPHY_USAGE'
    AND   lookup_code = p_usage_code
    AND   TRUNC(SYSDATE) BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active, SYSDATE+1)
    AND   enabled_flag = 'Y';

    IF (l_usage_count = 0) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_USAGE_CODE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Validate Country Code parameter from FND_TERRITORIES
  IF (p_country_code IS NOT NULL) THEN
    SELECT COUNT(*)
    INTO   l_country_code_count
    FROM   fnd_territories
    WHERE  territory_code = p_country_code
    AND    obsolete_flag = 'N';

    IF (l_country_code_count = 0) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NOT_VALID_COUNTRY');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  l_num_of_workers := fnd_profile.VALUE('HZ_GNR_NUM_OF_WORKERS');

  -- if profile is set to a value less than 1 i.e. 0 or -ve value, then
  -- set number of workers to 1 (Fix for Bug 4645523 by Nishant on 11-Oct-2005)
  IF (NVL(l_num_of_workers,0) < 1) THEN
    l_num_of_workers := 1;
  END IF;

  HZ_GNR_UTIL_PKG.log('Spawning ' || to_char(l_num_of_workers) || ' Workers for Geo Name Referencing');

  -- Submit requests as per profile HZ_GNR_NUM_OF_WORKERS

  FOR I in 1..TO_NUMBER(l_num_of_workers) LOOP
    l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHGNRW',
                  'Geo Name Referencing Worker ' || TO_CHAR(i),
                  to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                  FALSE, TO_CHAR(i),
                  p_location_table_name,
                  p_run_type,
                  p_usage_code,
                  p_country_code,
                  p_from_location_id,
                  p_to_location_id,
                  p_start_date,
                  p_end_date,
                  to_char(l_num_of_workers)
                  );
    IF l_sub_requests(i) = 0 THEN
     HZ_GNR_UTIL_PKG.log('Error submitting worker ' || i);
     HZ_GNR_UTIL_PKG.log(fnd_message.get);
    ELSE
     HZ_GNR_UTIL_PKG.log('Submitted request for Worker ' || TO_CHAR(i) );
     HZ_GNR_UTIL_PKG.log('Request ID : ' || l_sub_requests(i));
    END IF;
    EXIT when l_sub_requests(i) = 0;
  END LOOP;

  HZ_GNR_UTIL_PKG.outandlog('Concurrent Program Execution completed ');
  HZ_GNR_UTIL_PKG.outandlog('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    HZ_GNR_UTIL_PKG.outandlog('Error: Aborting Geo Name Referencing');
    retcode := 2;
    errbuf := errbuf || HZ_GNR_UTIL_PKG.logerror;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    HZ_GNR_UTIL_PKG.outandlog('Error: Aborting Geo Name Referencing');
    retcode := 2;
    errbuf := errbuf || HZ_GNR_UTIL_PKG.logerror;
    FND_FILE.close;
  WHEN OTHERS THEN
    HZ_GNR_UTIL_PKG.outandlog('Error: Aborting Geo Name Referencing');
    retcode := 2;
    errbuf := errbuf || HZ_GNR_UTIL_PKG.logerror;
    FND_FILE.close;
END;

/**
 *  Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA
 *                          All rights reserved.
 *=======================================================================
 * FILE       ARHGNRCB.pls
 *
 * PROCEDURE    process_gnr_worker
 *
 * DESCRIPTION
 *     This is the worker procedure which would call the gnr api
 *     for the records selected from the respective table name
 *     The records selected by this worker will be determined by
 *     the worker number of this worker and total number of
 *     workers. MOD function will be used for this.
 *     mod(location_id, p_num_workers) = p_worker_number
 *     location id 200 to 210. then
 *     number of workers 5. Worker number = 1
 *     This worker will pick up 201 and 206
 *     number of workers 5. Worker number = 2
 *     This worker will pick up 202 and 207
 *     number of workers 5. Worker number = 3
 *     This worker will pick up 203 and 208
 *     number of workers 5. Worker number = 4
 *     This worker will pick up 204 and 209
 *     number of workers 5. Worker number=5 will be assigned worker number=0
 *     This worker will pick up 200 and 210
 *
 * RELATED PACKAGES
 *
 * PUBLIC VARIABLES
 *
 * PUBLIC FUNCTIONS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   20-JAN-2003   Satyadeep           o Created.
 *                 Chandrashekar
 *   29-JUN-2006   Nishant Singhai     Bug 5257371
 *
 *   25-JAN-2008   Neeraj Shinde       Bug 6750566
 */

PROCEDURE process_gnr_worker (
        errbuf                  OUT  NOCOPY   VARCHAR2,
        retcode                 OUT  NOCOPY   VARCHAR2,
        p_worker_number        	IN      VARCHAR2,
        p_location_table_name   IN      VARCHAR2,
        p_run_type              IN      VARCHAR2,
        p_usage_code            IN      VARCHAR2,
        p_country_code          IN      VARCHAR2,
        p_from_location_id      IN      VARCHAR2,
        p_to_location_id        IN      VARCHAR2,
        p_start_date            IN      VARCHAR2,
        p_end_date              IN      VARCHAR2,
        p_num_workers           IN      VARCHAR2
) IS


  l_return_status VARCHAR2(30);
  l_addr_val_level VARCHAR2(30);
  l_addr_warn_msg  VARCHAR2(2000);
  l_addr_val_status VARCHAR2(30);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_sqlerr        VARCHAR2(2000);
  l_num_workers   NUMBER;
  l_worker_number NUMBER;
  l_from_location_id   NUMBER;
  l_to_location_id     NUMBER;
  l_loc_tbl_name       VARCHAR2(30);
  l_start_date         DATE;
  l_end_date           DATE;
  l_cur_location_id    NUMBER;
  l_commit_size        NUMBER;
  l_count_num_of_rec   NUMBER;
  l_num_locations      NUMBER;
  l_num_err_locations  NUMBER;
  l_num_success_locations  NUMBER;
  l_curr_loc_msg_prefix     VARCHAR2(2000);
  l_summ_loc_msg_prefix     VARCHAR2(2000);
  l_err_loc_msg_prefix      VARCHAR2(2000);
  l_success_loc_msg_prefix  VARCHAR2(2000);

  l_run_type         VARCHAR2(100);
  l_country_code     VARCHAR2(360);
  l_usage_code       VARCHAR2(100);

  CURSOR c_loc_hr_new(p_country_code IN VARCHAR2,
                  p_from_location_id IN NUMBER,
                  p_to_location_id   IN NUMBER,
                  p_start_date       IN DATE,
                  p_end_date         IN DATE,
                  p_num_workers      IN NUMBER,
                  p_worker_number    IN NUMBER,
                  p_usage_code       IN VARCHAR2,
                  p_table_name       IN VARCHAR2
				  ) IS
  SELECT loc.location_id
  FROM   hr_locations_all loc
  WHERE (((p_from_location_id IS NOT NULL and p_to_location_id IS NOT NULL) and
          (loc.location_id BETWEEN p_from_location_id and p_to_location_id )) or
         ((p_from_location_id IS NOT NULL and p_to_location_id IS NULL) and
          (loc.location_id >= p_from_location_id)) or
          (p_from_location_id IS NULL and p_to_location_id IS NULL))
  AND   ((p_start_date IS NULL and p_end_date IS NULL) or
         (p_start_date IS NOT NULL and p_end_date IS NULL and
           trunc(loc.creation_date) >= p_start_date) or
        ((p_start_date IS NOT NULL and p_end_date IS NOT NULL) and
         (trunc(loc.creation_date) BETWEEN p_start_date and p_end_date)))
  AND  ((p_country_code IS NULL) OR
        ((p_country_code IS NOT NULL) AND
         (loc.country = UPPER(p_country_code))) OR
        ((p_country_code IS NOT NULL) AND
          (loc.country IN (SELECT hgo.identifier_value
                       FROM   hz_geography_identifiers hgo
                       WHERE  EXISTS ( SELECT '1'
                                       FROM   hz_geography_identifiers hgi
                                       WHERE  hgi.identifier_subtype = 'ISO_COUNTRY_CODE'
                                       AND    hgi.identifier_type = 'CODE'
                                       AND    hgi.geography_use = 'MASTER_REF'
                                       AND    hgi.geography_type = 'COUNTRY'
                                       AND    hgi.geography_id = hgo.geography_id
                                       AND    UPPER(hgi.identifier_value) = p_country_code
                                       )
                       )
          ))
        )
  AND  NOT EXISTS (
  	   	   		   SELECT '1'
				   FROM   hz_geo_name_reference_log gnr
				   WHERE  gnr.location_table_name = p_table_name
				   AND    gnr.usage_code = DECODE(p_usage_code,'ALL',gnr.usage_code,p_usage_code)
				   AND    loc.location_id = gnr.location_id
				   )
  AND   mod(loc.location_id, p_num_workers) = p_worker_number
  ORDER BY loc.location_id;

  CURSOR c_loc_hr_error(p_country_code IN VARCHAR2,
                  p_from_location_id IN NUMBER,
                  p_to_location_id   IN NUMBER,
                  p_start_date       IN DATE,
                  p_end_date         IN DATE,
                  p_num_workers      IN NUMBER,
                  p_worker_number    IN NUMBER,
                  p_usage_code       IN VARCHAR2,
				  p_table_name       IN VARCHAR2
				  ) IS
  SELECT loc.location_id
  FROM   hr_locations_all loc
  WHERE (((p_from_location_id IS NOT NULL and p_to_location_id IS NOT NULL) and
          (loc.location_id BETWEEN p_from_location_id and p_to_location_id )) or
         ((p_from_location_id IS NOT NULL and p_to_location_id IS NULL) and
          (loc.location_id >= p_from_location_id)) or
          (p_from_location_id IS NULL and p_to_location_id IS NULL))
  AND   ((p_start_date IS NULL and p_end_date IS NULL) or
         (p_start_date IS NOT NULL and p_end_date IS NULL and
           trunc(loc.creation_date) >= p_start_date) or
        ((p_start_date IS NOT NULL and p_end_date IS NOT NULL) and
         (trunc(loc.creation_date) BETWEEN p_start_date and p_end_date)))
  AND  ((p_country_code IS NULL) OR
        ((p_country_code IS NOT NULL) AND
         (loc.country = UPPER(p_country_code))) OR
        ((p_country_code IS NOT NULL) AND
          (loc.country IN (SELECT hgo.identifier_value
                       FROM   hz_geography_identifiers hgo
                       WHERE  EXISTS ( SELECT '1'
                                       FROM   hz_geography_identifiers hgi
                                       WHERE  hgi.identifier_subtype = 'ISO_COUNTRY_CODE'
                                       AND    hgi.identifier_type = 'CODE'
                                       AND    hgi.geography_use = 'MASTER_REF'
                                       AND    hgi.geography_type = 'COUNTRY'
                                       AND    hgi.geography_id = hgo.geography_id
                                       AND    UPPER(hgi.identifier_value) = p_country_code
                                       )
                       )
          ))
        )
  AND  EXISTS (
  	   	   		   SELECT '1'
				   FROM   hz_geo_name_reference_log gnr
				   WHERE  gnr.location_table_name = p_table_name
				   AND    gnr.usage_code = DECODE(p_usage_code,'ALL',gnr.usage_code,p_usage_code)
				   AND    gnr.map_status = 'E'
				   AND    loc.location_id = gnr.location_id
				   )
  AND   mod(loc.location_id, p_num_workers) = p_worker_number
  ORDER BY loc.location_id;

  CURSOR c_loc_hr_all(p_country_code IN VARCHAR2,
                  p_from_location_id IN NUMBER,
                  p_to_location_id   IN NUMBER,
                  p_start_date       IN DATE,
                  p_end_date         IN DATE,
                  p_num_workers      IN NUMBER,
                  p_worker_number    IN NUMBER
				  ) IS
  SELECT loc.location_id
  FROM   hr_locations_all loc
  WHERE (((p_from_location_id IS NOT NULL and p_to_location_id IS NOT NULL) and
          (loc.location_id BETWEEN p_from_location_id and p_to_location_id )) or
         ((p_from_location_id IS NOT NULL and p_to_location_id IS NULL) and
          (loc.location_id >= p_from_location_id)) or
          (p_from_location_id IS NULL and p_to_location_id IS NULL))
  AND   ((p_start_date IS NULL and p_end_date IS NULL) or
         (p_start_date IS NOT NULL and p_end_date IS NULL and
           trunc(loc.creation_date) >= p_start_date) or
        ((p_start_date IS NOT NULL and p_end_date IS NOT NULL) and
         (trunc(loc.creation_date) BETWEEN p_start_date and p_end_date)))
  AND  ((p_country_code IS NULL) OR
        ((p_country_code IS NOT NULL) AND
         (loc.country = UPPER(p_country_code))) OR
        ((p_country_code IS NOT NULL) AND
          (loc.country IN (SELECT hgo.identifier_value
                       FROM   hz_geography_identifiers hgo
                       WHERE  EXISTS ( SELECT '1'
                                       FROM   hz_geography_identifiers hgi
                                       WHERE  hgi.identifier_subtype = 'ISO_COUNTRY_CODE'
                                       AND    hgi.identifier_type = 'CODE'
                                       AND    hgi.geography_use = 'MASTER_REF'
                                       AND    hgi.geography_type = 'COUNTRY'
                                       AND    hgi.geography_id = hgo.geography_id
                                       AND    UPPER(hgi.identifier_value) = p_country_code
                                       )
                       )
          ))
        )
  AND   mod(loc.location_id, p_num_workers) = p_worker_number
  ORDER BY loc.location_id;

  CURSOR c_loc_hz_new(p_country_code     IN VARCHAR2,
                  p_from_location_id IN NUMBER,
                  p_to_location_id   IN NUMBER,
                  p_start_date       IN DATE,
                  p_end_date         IN DATE,
                  p_num_workers      IN NUMBER,
                  p_worker_number    IN NUMBER,
				  p_usage_code       IN VARCHAR2,
				  p_table_name       IN VARCHAR2) IS
  SELECT LOCATION_ID,
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
  FROM   hz_locations loc
  WHERE (((p_from_location_id IS NOT NULL and p_to_location_id IS NOT NULL) and
          (location_id BETWEEN p_from_location_id and p_to_location_id )) or
         ((p_from_location_id IS NOT NULL and p_to_location_id IS NULL) and
          ( location_id >= p_from_location_id)) or
          (p_from_location_id IS NULL and p_to_location_id IS NULL))
  AND   ((p_start_date IS NULL and p_end_date IS NULL) or
         (p_start_date IS NOT NULL and p_end_date IS NULL and
           trunc(creation_date) >= p_start_date) or
        ((p_start_date IS NOT NULL and p_end_date IS NOT NULL) and
         (trunc(creation_date) BETWEEN p_start_date and p_end_date)))
  AND  ((p_country_code IS NULL) OR
        ((p_country_code IS NOT NULL) AND
         (country = p_country_code)) OR
        ((p_country_code IS NOT NULL) AND
          (country IN (SELECT hgo.identifier_value
                       FROM   hz_geography_identifiers hgo
                       WHERE  EXISTS ( SELECT '1'
                                       FROM   hz_geography_identifiers hgi
                                       WHERE  hgi.identifier_subtype = 'ISO_COUNTRY_CODE'
                                       AND    hgi.identifier_type = 'CODE'
                                       AND    hgi.geography_use = 'MASTER_REF'
                                       AND    hgi.geography_type = 'COUNTRY'
                                       AND    hgi.geography_id = hgo.geography_id
                                       AND    UPPER(hgi.identifier_value) = p_country_code
                                       )
                       )
          ))
        )
  AND  NOT EXISTS (
  	   	   		   SELECT '1'
				   FROM   hz_geo_name_reference_log gnr
				   WHERE  gnr.location_table_name = p_table_name
				   AND    gnr.usage_code = DECODE(p_usage_code,'ALL',gnr.usage_code,p_usage_code)
				   AND    loc.location_id = gnr.location_id
				   )
  AND   mod(location_id, p_num_workers) = p_worker_number
  ORDER BY location_id;

  CURSOR c_loc_hz_error(p_country_code     IN VARCHAR2,
                  p_from_location_id IN NUMBER,
                  p_to_location_id   IN NUMBER,
                  p_start_date       IN DATE,
                  p_end_date         IN DATE,
                  p_num_workers      IN NUMBER,
                  p_worker_number    IN NUMBER,
				  p_usage_code       IN VARCHAR2,
				  p_table_name       IN VARCHAR2) IS
  SELECT LOCATION_ID,
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
  FROM   hz_locations loc
  WHERE (((p_from_location_id IS NOT NULL and p_to_location_id IS NOT NULL) and
          (location_id BETWEEN p_from_location_id and p_to_location_id )) or
         ((p_from_location_id IS NOT NULL and p_to_location_id IS NULL) and
          ( location_id >= p_from_location_id)) or
          (p_from_location_id IS NULL and p_to_location_id IS NULL))
  AND   ((p_start_date IS NULL and p_end_date IS NULL) or
         (p_start_date IS NOT NULL and p_end_date IS NULL and
           trunc(creation_date) >= p_start_date) or
        ((p_start_date IS NOT NULL and p_end_date IS NOT NULL) and
         (trunc(creation_date) BETWEEN p_start_date and p_end_date)))
  AND  ((p_country_code IS NULL) OR
        ((p_country_code IS NOT NULL) AND
         (country = p_country_code)) OR
        ((p_country_code IS NOT NULL) AND
          (country IN (SELECT hgo.identifier_value
                       FROM   hz_geography_identifiers hgo
                       WHERE  EXISTS ( SELECT '1'
                                       FROM   hz_geography_identifiers hgi
                                       WHERE  hgi.identifier_subtype = 'ISO_COUNTRY_CODE'
                                       AND    hgi.identifier_type = 'CODE'
                                       AND    hgi.geography_use = 'MASTER_REF'
                                       AND    hgi.geography_type = 'COUNTRY'
                                       AND    hgi.geography_id = hgo.geography_id
                                       AND    UPPER(hgi.identifier_value) = p_country_code
                                       )
                       )
          ))
        )
  AND  EXISTS (
  	   	   		   SELECT '1'
				   FROM   hz_geo_name_reference_log gnr
				   WHERE  gnr.location_table_name = p_table_name
				   AND    gnr.usage_code = DECODE(p_usage_code,'ALL',gnr.usage_code,p_usage_code)
				   AND    gnr.map_status = 'E'
				   AND    loc.location_id = gnr.location_id
				   )
  AND   mod(location_id, p_num_workers) = p_worker_number
  ORDER BY location_id;

  CURSOR c_loc_hz_all(p_country_code IN VARCHAR2,
                      p_from_location_id IN NUMBER,
                      p_to_location_id   IN NUMBER,
                      p_start_date       IN DATE,
                      p_end_date         IN DATE,
                      p_num_workers      IN NUMBER,
                      p_worker_number    IN NUMBER
                    ) IS
  SELECT LOCATION_ID,
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
  FROM   hz_locations loc
  WHERE (((p_from_location_id IS NOT NULL and p_to_location_id IS NOT NULL) and
          (location_id BETWEEN p_from_location_id and p_to_location_id )) or
         ((p_from_location_id IS NOT NULL and p_to_location_id IS NULL) and
          ( location_id >= p_from_location_id)) or
          (p_from_location_id IS NULL and p_to_location_id IS NULL))
  AND   ((p_start_date IS NULL and p_end_date IS NULL) or
         (p_start_date IS NOT NULL and p_end_date IS NULL and
           trunc(creation_date) >= p_start_date) or
        ((p_start_date IS NOT NULL and p_end_date IS NOT NULL) and
         (trunc(creation_date) BETWEEN p_start_date and p_end_date)))
  AND  ((p_country_code IS NULL) OR
        ((p_country_code IS NOT NULL) AND
         (country = p_country_code)) OR
        ((p_country_code IS NOT NULL) AND
          (country IN (SELECT hgo.identifier_value
                       FROM   hz_geography_identifiers hgo
                       WHERE  EXISTS ( SELECT '1'
                                       FROM   hz_geography_identifiers hgi
                                       WHERE  hgi.identifier_subtype = 'ISO_COUNTRY_CODE'
                                       AND    hgi.identifier_type = 'CODE'
                                       AND    hgi.geography_use = 'MASTER_REF'
                                       AND    hgi.geography_type = 'COUNTRY'
                                       AND    hgi.geography_id = hgo.geography_id
                                       AND    UPPER(hgi.identifier_value) = p_country_code
                                       )
                       )
          ))
        )
  AND   mod(location_id, p_num_workers) = p_worker_number
  ORDER BY location_id;

  -- R12 Upgrade cursors
  CURSOR c_r12_upg (lp_num_workers   NUMBER,
                    lp_worker_number NUMBER)
  IS
  SELECT loc.LOCATION_ID,
         loc.ADDRESS_STYLE,
         loc.COUNTRY,
         loc.STATE,
         loc.PROVINCE,
         loc.COUNTY,
         loc.CITY,
         loc.POSTAL_CODE,
         loc.POSTAL_PLUS4_CODE,
         loc.ATTRIBUTE1,
         loc.ATTRIBUTE2,
         loc.ATTRIBUTE3,
         loc.ATTRIBUTE4,
         loc.ATTRIBUTE5,
         loc.ATTRIBUTE6,
         loc.ATTRIBUTE7,
         loc.ATTRIBUTE8,
         loc.ATTRIBUTE9,
         loc.ATTRIBUTE10
  FROM   hz_locations loc
  WHERE
  -- Only locations which had Loc_assignments record before
  /*Bug 6750566 Changes Start
  EXISTS (
          SELECT NULL FROM   hz_loc_assignments_obs hlo
          WHERE loc.location_id = hlo.location_id
        )
  */
  EXISTS (
          SELECT NULL FROM hz_party_sites hps,
                           hz_cust_acct_sites_all hcasa
           WHERE loc.location_id = hps.location_id
             AND hps.party_site_id = hcasa.party_site_id
         )
  --Bug 6750566 Changes End
  AND   MOD(loc.location_id, lp_num_workers) = lp_worker_number
  --ORDER BY loc.location_id
  ;

  l_map_exist VARCHAR2(10);

  CURSOR c_r12_upg_map_cnt IS
    SELECT DISTINCT country_code
    FROM   hz_geo_struct_map
    WHERE  loc_tbl_name = 'HZ_LOCATIONS';

  TYPE mapped_country_tbl_type IS TABLE OF  VARCHAR2(10) INDEX BY BINARY_INTEGER;
  mapped_country_list mapped_country_tbl_type;

   FUNCTION check_mapping_exist(l_country_code IN VARCHAR2) RETURN VARCHAR2
   IS
   BEGIN
     IF (mapped_country_list.COUNT > 0) THEN
       FOR i IN 1..mapped_country_list.COUNT LOOP
         IF (mapped_country_list(i) = l_country_code) THEN
            RETURN 'Y';
         END IF;
       END LOOP;
       -- no match for whole loop
       RETURN 'N';
     ELSE
       RETURN 'N';
     END IF;
   END check_mapping_exist;

BEGIN
 -- IF (TO_NUMBER(p_worker_number)= 1) THEN
 --   execute IMMEDIATE 'ALTER SESSION SET TIMED_STATISTICS = TRUE';
 --   execute IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = GNR_TRACE MAX_DUMP_FILE_SIZE = 50000000 EVENTS =''10046 TRACE NAME CONTEXT FOREVER, LEVEL 8''';
 --   execute IMMEDIATE 'ALTER SESSION SET SQL_TRACE = TRUE';
 -- END IF;

  l_count_num_of_rec      := 0;
  l_num_locations         := 0;
  l_num_err_locations     := 0;
  l_num_success_locations := 0;

  l_from_location_id  := TO_NUMBER(p_from_location_id);
  l_to_location_id    := TO_NUMBER(p_to_location_id);
  l_start_date        := fnd_date.canonical_to_date(p_start_date);
  l_end_date          := fnd_date.canonical_to_date(p_end_date);
  l_num_workers       := TO_NUMBER(p_num_workers);
  l_worker_number     := TO_NUMBER(p_worker_number);
  l_commit_size       := NVL(fnd_profile.value('HZ_GNR_COMMIT_SIZE'),1000);
  l_run_type          := NVL(p_run_type,'ALL'); -- Complete refresh for passed location ids
  l_country_code      := UPPER(p_country_code);

  retcode := 0;

  -- Set l_usage_code. This depends on table name and run type.
  -- 1. If table is HR_LOCATIONS_ALL, GNR for only TAX usage is generated. It will
  --    ignore whatever usage code is passed for HZ_LOCATIONS_ALL.
  -- 2. If table is HZ_LOCATIONS,
  --    i. If run type is ALL, we delete GNR for all usages, so we will generate GNR for all usages.
  --    ii.If run type is ERROR or NEW, we will generate GNR for specific usage passed.
  --       If no usage is passed, we will generate for all usages
  IF (p_location_table_name = 'HZ_LOCATIONS') THEN
    IF (l_run_type IN ('ALL','R12UPGRADE')) THEN
      l_usage_code := 'ALL';
    ELSE
      l_usage_code  := NVL(p_usage_code,'ALL');
    END IF;
  ELSIF
    (p_location_table_name = 'HR_LOCATIONS_ALL') THEN
    l_usage_code  := 'TAX';
  ELSE
    l_usage_code  := NVL(p_usage_code,'ALL');
  END IF;

  IF l_worker_number = l_num_workers THEN
    l_worker_number := 0;
  END IF;

  HZ_GNR_UTIL_PKG.log('Starting Concurrent Program ''Geo Name Referencing Worker: '||p_worker_number||'''');
  HZ_GNR_UTIL_PKG.log('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  HZ_GNR_UTIL_PKG.log('NEWLINE');

  -- Initialize Global Variable
  -- This variable is checked in HZ_GNR_UTIL_PKG.create_gnr procedure
  -- For any address validation call from GNR this variable will be set at
  -- PROCEDURE level to 'GNR'
  -- Nishant (Perf Bug 5881539 16-APR-2007)
  HZ_GNR_PKG.G_API_PURPOSE := 'GNR';

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_CUR_LOC_PREFIX');
  l_curr_loc_msg_prefix := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_SUM_LOC_PREFIX');
  l_summ_loc_msg_prefix := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_ERR_LOC_PREFIX');
  l_err_loc_msg_prefix  := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_SUCC_LOC_PREFIX');
  l_success_loc_msg_prefix  := FND_MESSAGE.GET;

  -- Depending on the location table name passed
  -- open the appropriate cursor and call the gnr api.
  -- Commit as per commit size applicable to number of
  -- source records. The log will print the location
  -- record processed and in the end it will print the
  -- total number of records processed.

  -- Table : HR_LOCATIONS_ALL  Run Type : ALL
  IF ((p_location_table_name = 'HR_LOCATIONS_ALL') AND (l_run_type = 'ALL')) THEN

    HZ_GNR_UTIL_PKG.outandlog('Processing for Table         : HR_LOCATIONS_ALL and Run Type : ALL');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Country Code     :'||NVL(l_country_code,'NULL'));
    HZ_GNR_UTIL_PKG.outandlog('            Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            From Location Id :'||NVL(TO_CHAR(l_from_location_id),'NULL')
	                    ||': To Location Id:'||NVL(TO_CHAR(l_to_location_id),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Start Date       :'||NVL(TO_CHAR(l_start_date),'NULL')
	                    ||': End Date:'||NVL(TO_CHAR(l_end_date),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
    HZ_GNR_UTIL_PKG.outandlog(' ');

    OPEN c_loc_hr_all(l_country_code,
	              l_from_location_id,
                  l_to_location_id,
                  l_start_date,
                  l_end_date,
                  l_num_workers,
                  l_worker_number
                 );
    LOOP
      FETCH c_loc_hr_all INTO l_cur_location_id;
      EXIT WHEN c_loc_hr_all%NOTFOUND;

      l_count_num_of_rec := l_count_num_of_rec + 1;
      l_num_locations := l_num_locations + 1;

      -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

      BEGIN
        HZ_GNR_PKG.delete_gnr(p_locId    => l_cur_location_id,
				   			  p_locTbl   => p_location_table_name,
				   			  x_status   => l_return_status
   				   			  );

        HZ_GNR_PKG.validateHrLoc(l_cur_location_id,
                       l_return_status
                       );
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN OTHERS THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
      END;

      IF l_count_num_of_rec = l_commit_size THEN
        COMMIT;
        l_count_num_of_rec := 0;
      END IF;

    END LOOP;
    CLOSE c_loc_hr_all;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix ||l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');

  -- Table : HR_LOCATIONS_ALL  Run Type : NEW
  ELSIF ((p_location_table_name = 'HR_LOCATIONS_ALL') AND (l_run_type = 'NEW')) THEN

    HZ_GNR_UTIL_PKG.outandlog('Processing for Table : HR_LOCATIONS_ALL and Run Type : NEW');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Country Code     :'||NVL(l_country_code,'NULL'));
    HZ_GNR_UTIL_PKG.outandlog('            Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            From Location Id :'||NVL(TO_CHAR(l_from_location_id),'NULL')
	                    ||': To Location Id:'||NVL(TO_CHAR(l_to_location_id),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Start Date       :'||NVL(TO_CHAR(l_start_date),'NULL')
	                    ||': End Date:'||NVL(TO_CHAR(l_end_date),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
    HZ_GNR_UTIL_PKG.outandlog(' ');

    OPEN c_loc_hr_new(l_country_code,
	              l_from_location_id,
                  l_to_location_id,
                  l_start_date,
                  l_end_date,
                  l_num_workers,
                  l_worker_number,
				  l_usage_code,
				  p_location_table_name);
    LOOP
      FETCH c_loc_hr_new INTO l_cur_location_id;
      EXIT WHEN c_loc_hr_new%NOTFOUND;

      l_count_num_of_rec := l_count_num_of_rec + 1;
      l_num_locations := l_num_locations + 1;

      -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

      BEGIN
        HZ_GNR_PKG.validateHrLoc(l_cur_location_id,
                                 l_return_status
                                );
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN OTHERS THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
      END;

      IF l_count_num_of_rec = l_commit_size THEN
        COMMIT;
        l_count_num_of_rec := 0;
      END IF;

    END LOOP;
    CLOSE c_loc_hr_new;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix ||l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');

  -- Table : HR_LOCATIONS_ALL  Run Type : ERROR
  ELSIF ((p_location_table_name = 'HR_LOCATIONS_ALL') AND (l_run_type = 'ERROR')) THEN

    HZ_GNR_UTIL_PKG.outandlog('Processing for Table : HR_LOCATIONS_ALL and Run Type : ERROR');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Country Code     :'||NVL(l_country_code,'NULL'));
    HZ_GNR_UTIL_PKG.outandlog('            Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            From Location Id :'||NVL(TO_CHAR(l_from_location_id),'NULL')
	                    ||': To Location Id:'||NVL(TO_CHAR(l_to_location_id),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Start Date       :'||NVL(TO_CHAR(l_start_date),'NULL')
	                    ||': End Date:'||NVL(TO_CHAR(l_end_date),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
    HZ_GNR_UTIL_PKG.outandlog(' ');

    OPEN c_loc_hr_error(l_country_code,
	              l_from_location_id,
                  l_to_location_id,
                  l_start_date,
                  l_end_date,
                  l_num_workers,
                  l_worker_number,
				  l_usage_code,
				  p_location_table_name);
    LOOP
      FETCH c_loc_hr_error INTO l_cur_location_id;
      EXIT WHEN c_loc_hr_error%NOTFOUND;

      l_count_num_of_rec := l_count_num_of_rec + 1;
      l_num_locations := l_num_locations + 1;

      -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

      BEGIN
        HZ_GNR_PKG.validateHrLoc(l_cur_location_id,
                                 l_return_status
                                );
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN OTHERS THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
      END;

      IF l_count_num_of_rec = l_commit_size THEN
        COMMIT;
        l_count_num_of_rec := 0;
      END IF;

    END LOOP;
    CLOSE c_loc_hr_error;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix ||l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');

  -- Table : HZ_LOCATIONS  Run Type : ALL
  ELSIF ((p_location_table_name = 'HZ_LOCATIONS') AND (l_run_type = 'ALL')) THEN
    HZ_GNR_UTIL_PKG.outandlog('Processing for Table : HZ_LOCATIONS and Run Type : ALL');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Country Code     :'||NVL(l_country_code,'NULL'));
    HZ_GNR_UTIL_PKG.outandlog('            Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            From Location Id :'||NVL(TO_CHAR(l_from_location_id),'NULL')
	                    ||': To Location Id:'||NVL(TO_CHAR(l_to_location_id),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Start Date       :'||NVL(TO_CHAR(l_start_date),'NULL')
	                    ||': End Date:'||NVL(TO_CHAR(l_end_date),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
    HZ_GNR_UTIL_PKG.outandlog(' ');

    FOR l_c_loc_hz IN  c_loc_hz_all(l_country_code,
	                            l_from_location_id,
                                l_to_location_id,
                                l_start_date,
                                l_end_date,
                                l_num_workers,
                                l_worker_number
                                )
	LOOP
      l_count_num_of_rec := l_count_num_of_rec + 1;
      l_num_locations := l_num_locations + 1;

      l_cur_location_id := l_c_loc_hz.LOCATION_ID;
      -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

      BEGIN  -- added to handle unexpected error from ARH package that is
             -- called inside location_updation_allowed check (Bug 5099223)
             -- Nishant (17-Mar-2006)

        -- If the Location updation is allowed
        IF (HZ_GNR_UTIL_PKG.location_updation_allowed(l_cur_location_id) OR
            NOT(HZ_GNR_UTIL_PKG.gnr_exists(l_cur_location_id,p_location_table_name))) THEN

          BEGIN
            -- delete for all usages (l_usage_code is set to ALL for runtype ALL)
            -- Commented the below code for bug to handle "DUMMY" locations. Bug # 5022121
            -- This delete gnr will take place inside create gnr.
            --   HZ_GNR_PKG.delete_gnr(p_locId    => l_cur_location_id,
            --   			  p_locTbl   => p_location_table_name,
            --  			  x_status   => l_return_status
            --   			  );

            HZ_GNR_PKG.validateLoc(
              P_LOCATION_ID               => l_cur_location_id,
              P_USAGE_CODE                => l_usage_code,
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
          EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
              l_num_err_locations  := l_num_err_locations + 1;
              HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
              FND_MSG_PUB.Reset;
              FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
                HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
              END LOOP;
              FND_MSG_PUB.Delete_Msg;
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_num_err_locations  := l_num_err_locations + 1;
              HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
              FND_MSG_PUB.Reset;
              FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
                HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
              END LOOP;
              FND_MSG_PUB.Delete_Msg;
            WHEN OTHERS THEN
              l_num_err_locations  := l_num_err_locations + 1;
              HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
              HZ_GNR_UTIL_PKG.out(SQLERRM);
              FND_MSG_PUB.Reset;
              FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
                HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
              END LOOP;
              FND_MSG_PUB.Delete_Msg;
          END;

        ELSE
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          HZ_GNR_UTIL_PKG.out('Skipped GNR - transaction exists for this location');
        END IF;

      EXCEPTION  WHEN OTHERS THEN
         l_num_err_locations  := l_num_err_locations + 1;
         HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
         HZ_GNR_UTIL_PKG.out('Error: '||SQLERRM);
         FND_MSG_PUB.Reset;
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
         END LOOP;
         FND_MSG_PUB.Delete_Msg;
      END;

      IF l_count_num_of_rec = l_commit_size THEN
        COMMIT;
        l_count_num_of_rec := 0;
      END IF;

    END LOOP;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix || l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');

  -- Table : HZ_LOCATIONS  Run Type : NEW
  ELSIF ((p_location_table_name = 'HZ_LOCATIONS') AND (l_run_type = 'NEW')) THEN
    HZ_GNR_UTIL_PKG.outandlog('Processing for Table : HZ_LOCATIONS and Run Type : NEW');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Country Code     :'||NVL(l_country_code,'NULL'));
    HZ_GNR_UTIL_PKG.outandlog('            Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            From Location Id :'||NVL(TO_CHAR(l_from_location_id),'NULL')
	                    ||': To Location Id:'||NVL(TO_CHAR(l_to_location_id),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Start Date       :'||NVL(TO_CHAR(l_start_date),'NULL')
	                    ||': End Date:'||NVL(TO_CHAR(l_end_date),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
    HZ_GNR_UTIL_PKG.outandlog(' ');

    FOR l_c_loc_hz IN  c_loc_hz_new(l_country_code,
	                            l_from_location_id,
                                l_to_location_id,
                                l_start_date,
                                l_end_date,
                                l_num_workers,
                                l_worker_number,
								l_usage_code,
								p_location_table_name)
	LOOP
      l_count_num_of_rec := l_count_num_of_rec + 1;
      l_num_locations := l_num_locations + 1;

      l_cur_location_id := l_c_loc_hz.LOCATION_ID;
      -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

      BEGIN
        HZ_GNR_PKG.validateLoc(
          P_LOCATION_ID               => l_cur_location_id,
          P_USAGE_CODE                => l_usage_code,
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
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN OTHERS THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
      END;

      IF l_count_num_of_rec = l_commit_size THEN
        COMMIT;
        l_count_num_of_rec := 0;
      END IF;

    END LOOP;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix || l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');

  -- Table : HZ_LOCATIONS  Run Type : ERROR
  ELSIF ((p_location_table_name = 'HZ_LOCATIONS') AND (l_run_type = 'ERROR')) THEN
    HZ_GNR_UTIL_PKG.outandlog('Processing for Table : HZ_LOCATIONS and Run Type : ERROR');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Country Code     :'||NVL(l_country_code,'NULL'));
    HZ_GNR_UTIL_PKG.outandlog('            Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            From Location Id :'||NVL(TO_CHAR(l_from_location_id),'NULL')
	                    ||': To Location Id:'||NVL(TO_CHAR(l_to_location_id),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Start Date       :'||NVL(TO_CHAR(l_start_date),'NULL')
	                    ||': End Date:'||NVL(TO_CHAR(l_end_date),'NULL'));
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
    HZ_GNR_UTIL_PKG.outandlog(' ');

    FOR l_c_loc_hz IN  c_loc_hz_error(l_country_code,
	                            l_from_location_id,
                                l_to_location_id,
                                l_start_date,
                                l_end_date,
                                l_num_workers,
                                l_worker_number,
								l_usage_code,
								p_location_table_name)
	LOOP
      l_count_num_of_rec := l_count_num_of_rec + 1;
      l_num_locations := l_num_locations + 1;

      l_cur_location_id := l_c_loc_hz.LOCATION_ID;
      -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

      BEGIN
        HZ_GNR_PKG.validateLoc(
          P_LOCATION_ID               => l_cur_location_id,
          P_USAGE_CODE                => l_usage_code,
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
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
        WHEN OTHERS THEN
          l_num_err_locations  := l_num_err_locations + 1;
          HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
          FND_MSG_PUB.Reset;
          FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
            HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
          END LOOP;
          FND_MSG_PUB.Delete_Msg;
      END;

      IF l_count_num_of_rec = l_commit_size THEN
        COMMIT;
        l_count_num_of_rec := 0;
      END IF;

    END LOOP;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix || l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');

  -- Table : HZ_LOCATIONS  Run Type : R12UPGRADE
  ELSIF ((p_location_table_name = 'HZ_LOCATIONS') AND (l_run_type = 'R12UPGRADE')) THEN
    HZ_GNR_UTIL_PKG.outandlog('Processing for Table : HZ_LOCATIONS and Run Type : R12UPGRADE');
    HZ_GNR_UTIL_PKG.outandlog('Parameters: Usage Code       :'||l_usage_code);
	HZ_GNR_UTIL_PKG.outandlog('            Number of workers:'||TO_CHAR(l_num_workers));
	HZ_GNR_UTIL_PKG.outandlog('Records from HZ_LOC_ASSIGNMENTS with valid mapping are being migrated.');
    HZ_GNR_UTIL_PKG.outandlog(' ');

    -- Initialize Global Variable so that later update location is avoided
    -- This variable is checked in HZ_GNR_UTIL_PKG.create_gnr procedure
    -- Nishant (Perf Bug 5407103 4-AUG-2006)
    ------------------------------------------------------------------------
    -- Replaced by HZ_GNR_PKG.G_API_PURPOSE
    -- Nishant (Perf Bug 5881539 16-APR-2007)
    ------------------------------------------------------------------------
    -- HZ_GNR_PVT.G_USER_ATTEMPT_COUNT := 'R12UPGRADE';
    HZ_GNR_PKG.G_API_PURPOSE := 'R12UPGRADE';

    -- populate plsql table with mapped countries info
    FOR c_map_cnt_rec IN c_r12_upg_map_cnt LOOP
      mapped_country_list(mapped_country_list.COUNT+1) := c_map_cnt_rec.country_code;
    END LOOP;

    FOR l_c_loc_hz IN c_r12_upg (l_num_workers, l_worker_number) -- will fetch only 1 row
    LOOP

      l_map_exist := check_mapping_exist(l_c_loc_hz.COUNTRY);

      -- Process only if mapping exist
      IF (l_map_exist = 'Y') THEN

        l_count_num_of_rec := l_count_num_of_rec + 1;
        l_num_locations    := l_num_locations + 1;

        l_cur_location_id := l_c_loc_hz.LOCATION_ID;
        -- HZ_GNR_UTIL_PKG.log('Current location ' || l_cur_location_id);

  	    BEGIN

	    HZ_GNR_PKG.validateLoc(
	      P_LOCATION_ID               => l_c_loc_hz.LOCATION_ID,
	      P_USAGE_CODE                => l_usage_code,
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
  	    EXCEPTION
	      WHEN FND_API.G_EXC_ERROR THEN
	        l_num_err_locations  := l_num_err_locations + 1;
  	        HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
	        FND_MSG_PUB.Reset;
	        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
		      HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
	        END LOOP;
	        FND_MSG_PUB.Delete_Msg;
	      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        l_num_err_locations  := l_num_err_locations + 1;
	        HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
	        FND_MSG_PUB.Reset;
	        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
		      HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
	        END LOOP;
	        FND_MSG_PUB.Delete_Msg;
	      WHEN OTHERS THEN
	        l_num_err_locations  := l_num_err_locations + 1;
	        HZ_GNR_UTIL_PKG.out(l_curr_loc_msg_prefix ||' '|| l_cur_location_id);
	        HZ_GNR_UTIL_PKG.out(SQLERRM);
	        FND_MSG_PUB.Reset;
	        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
		      HZ_GNR_UTIL_PKG.out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
	        END LOOP;
	        FND_MSG_PUB.Delete_Msg;
	    END;

	    IF l_count_num_of_rec = l_commit_size THEN
	     COMMIT;
	     l_count_num_of_rec := 0;
	    END IF;

      END IF; -- end of mapping exist check
    END LOOP;
    COMMIT;

    l_num_success_locations := l_num_locations - l_num_err_locations;

    HZ_GNR_UTIL_PKG.log(' ');
    HZ_GNR_UTIL_PKG.log('Total number of location records processed : '|| l_num_locations);
    HZ_GNR_UTIL_PKG.log('Number of records succeeded                : '|| l_num_success_locations);
    HZ_GNR_UTIL_PKG.log('Number of records rejected                 : '|| l_num_err_locations);

    HZ_GNR_UTIL_PKG.out(' ');
    HZ_GNR_UTIL_PKG.out(l_summ_loc_msg_prefix || l_num_locations);
    HZ_GNR_UTIL_PKG.out(l_success_loc_msg_prefix || l_num_success_locations);
    HZ_GNR_UTIL_PKG.out(l_err_loc_msg_prefix || l_num_err_locations);

    HZ_GNR_UTIL_PKG.log('Geo Name Referencing process completed successfully');
  END IF;

  -- Reset Global variable
  HZ_GNR_PKG.G_API_PURPOSE := NULL;

  -- IF (TO_NUMBER(p_worker_number)= 1) THEN
  --  execute IMMEDIATE 'ALTER SESSION SET SQL_TRACE = FALSE';
  -- END IF;

EXCEPTION
  WHEN OTHERS THEN
    --IF (TO_NUMBER(p_worker_number)= 1) THEN
    --  execute IMMEDIATE 'ALTER SESSION SET SQL_TRACE = FALSE';
    --END IF;

    -- Reset Global variable
    HZ_GNR_PKG.G_API_PURPOSE := NULL;

    HZ_GNR_UTIL_PKG.outandlog('Unknown Error at Location ID: ' || l_cur_location_id || ' : ' || SQLERRM);
    HZ_GNR_UTIL_PKG.outandlog('Error: Aborting Geo Name Referencing');
    FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
      HZ_GNR_UTIL_PKG.outandlog(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
    END LOOP;

    retcode := 2;
    errbuf := 'Unexpected SQL Error at location id :' || l_cur_location_id;
    FND_FILE.close;
END;

-------------------------------------------
/**
 * PROCEDURE srchGeo
 *
 * DESCRIPTION
 *     This private procedure is used to wrap the calls for all the
 *     map specific procedure. This will call the various search
 *     procedures depending on the component level in the hierarchy
 *     for given location id and location table combination.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_locId               Location Identifier
 *     p_locTbl              Location Table
 *     p_mapId               Map Identifier
 *
 *   IN OUT:
 *   x_mapTbl   Table of records that has location sequence number,
 *              geo element, type and loc components and their values
 *   OUT:
 *   x_status   indicates if the srchGeo was sucessfull or not.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *
 */

 PROCEDURE srchGeo(
   p_locId   IN NUMBER,
   p_locTbl  IN VARCHAR2,
   p_usage_code  IN VARCHAR2,
   x_status  OUT NOCOPY VARCHAR2
 ) IS
BEGIN
NULL;
END;

  PROCEDURE delete_gnr(
   p_locId       IN NUMBER,
   p_locTbl      IN VARCHAR2,
   x_status      OUT NOCOPY VARCHAR2
   ) IS
  BEGIN

    delete from hz_geo_name_references
    where  location_table_name = p_locTbl
    and    location_id = p_locId;

    delete from hz_geo_name_reference_log
    where  location_table_name = p_locTbl
    and    location_id = p_locId;
  EXCEPTION WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END delete_gnr;

  PROCEDURE validateHrLoc(
    P_LOCATION_ID               IN NUMBER,
    X_STATUS                    OUT NOCOPY VARCHAR2) IS
    l_sql  VARCHAR2(2000);
    l_status  VARCHAR2(1);
    l_map_id number;

    l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRCB:HZ_GNR_PKG';
    l_module        CONSTANT VARCHAR2(30) := 'ADDRESS_VALIDATION';
    l_debug_prefix           VARCHAR2(30) := p_location_id;

    CURSOR c_loc(p_loc_id in number) IS
    SELECT country,style
    FROM   hr_locations_all
    WHERE  location_id = p_loc_id;
  BEGIN
    x_status := fnd_api.g_ret_sts_success; -- defaulting the sucess status.

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => 'Begin of validation procedure validateHrLoc',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_procedure,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

    FOR l_c_loc in c_loc(P_LOCATION_ID) LOOP -- only one record will be featched.
      l_map_id := get_map_id(l_c_loc.country,'HR_LOCATIONS_ALL',l_c_loc.style);
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => ' Map Id for the country : '||l_map_id,
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
      IF l_map_id IS NULL THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => ' No mapping exists for the country. Raise error and exit.',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
          (p_message      => 'Before calling HZ_GNR_MAP'||l_map_id||'.validateHrLoc',
           p_prefix        => l_debug_prefix,
           p_msg_level     => fnd_log.level_procedure,
           p_module_prefix => l_module_prefix,
           p_module        => l_module
          );
    END IF;

    l_sql := 'BEGIN HZ_GNR_MAP'||l_map_id||'.validateHrLoc(:location_id,:status); END;';
    BEGIN
      EXECUTE IMMEDIATE l_sql USING P_LOCATION_ID,OUT l_status;
    EXCEPTION WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
            (p_message      => SUBSTR(' Exception when others in '||' HZ_GNR_MAP'||l_map_id||'.validateHrLoc ' ||SQLERRM,1,255),
             p_prefix        => l_debug_prefix,
             p_msg_level     => fnd_log.level_exception,
             p_module_prefix => l_module_prefix,
             p_module        => l_module
         );
      END IF;
      x_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
          (p_message      => 'After calling HZ_GNR_MAP'||l_map_id||'.validateHrLoc Return status : '||l_status,
           p_prefix        => l_debug_prefix,
           p_msg_level     => fnd_log.level_procedure,
           p_module_prefix => l_module_prefix,
           p_module        => l_module
          );
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => 'End of validation procedure validateHrLoc',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_procedure,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

  END validateHrLoc;

  PROCEDURE validateLoc(
    P_LOCATION_ID               IN NUMBER,
    P_USAGE_CODE                IN VARCHAR2,
    P_ADDRESS_STYLE             IN VARCHAR2,
    P_COUNTRY                   IN VARCHAR2,
    P_STATE                     IN VARCHAR2,
    P_PROVINCE                  IN VARCHAR2,
    P_COUNTY                    IN VARCHAR2,
    P_CITY                      IN VARCHAR2,
    P_POSTAL_CODE               IN VARCHAR2,
    P_POSTAL_PLUS4_CODE         IN VARCHAR2,
    P_ATTRIBUTE1                IN VARCHAR2,
    P_ATTRIBUTE2                IN VARCHAR2,
    P_ATTRIBUTE3                IN VARCHAR2,
    P_ATTRIBUTE4                IN VARCHAR2,
    P_ATTRIBUTE5                IN VARCHAR2,
    P_ATTRIBUTE6                IN VARCHAR2,
    P_ATTRIBUTE7                IN VARCHAR2,
    P_ATTRIBUTE8                IN VARCHAR2,
    P_ATTRIBUTE9                IN VARCHAR2,
    P_ATTRIBUTE10               IN VARCHAR2,
    P_CALLED_FROM               IN VARCHAR2,
    P_LOCK_FLAG                 IN VARCHAR2,
    X_ADDR_VAL_LEVEL            OUT NOCOPY VARCHAR2,
    X_ADDR_WARN_MSG             OUT NOCOPY VARCHAR2,
    X_ADDR_VAL_STATUS           OUT NOCOPY VARCHAR2,
    X_STATUS                    OUT NOCOPY VARCHAR2) IS

    l_sql  VARCHAR2(2000);
    l_usage_API  VARCHAR2(30);
    l_call_map  VARCHAR2(1);
    l_status  VARCHAR2(1);
    l_addr_val_status  VARCHAR2(1);
    l_mapId number;
    i       number;
    l_cntry varchar2(2);
    l_addr_val_level varchar2(30);
    l_addr_warn_msg  varchar2(2000);
    l_country_code VARCHAR2(10);
    l_usage_tbl HZ_GNR_UTIL_PKG.usage_tbl_type;

    l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRCB:HZ_GNR_PKG';
    l_module        CONSTANT VARCHAR2(30) := 'ADDRESS_VALIDATION';
    l_debug_prefix           VARCHAR2(30) := p_location_id;

--------
    ex_pkg_invalidated_state  EXCEPTION;
    ex_pkg_altered            EXCEPTION;

    PRAGMA EXCEPTION_INIT(ex_pkg_invalidated_state, -04061);
    PRAGMA EXCEPTION_INIT(ex_pkg_altered, -04065);

--------
    CURSOR c_usage(p_map_id IN NUMBER) IS
    SELECT MAP_ID,USAGE_ID,USAGE_CODE
    FROM   hz_address_usages
    WHERE  map_id = p_map_id
    AND    status_flag = 'A'
    ORDER BY usage_id;

    FUNCTION get_usage_API(p_map_id in number,p_usage_code in varchar2) RETURN varchar2 IS
      l_usage_API  VARCHAR2(30);
      l_sql  VARCHAR2(200);

    BEGIN
      l_sql := 'BEGIN :API_Name := HZ_GNR_MAP'||p_map_id||'.get_usage_API(:usage_code); END;';
      BEGIN
        BEGIN
          EXECUTE IMMEDIATE l_sql USING OUT l_usage_API,p_usage_code;
        EXCEPTION
        -- Fix for Bug 5521521 (If Geo Admin package is recompiled, in address page,
        -- while creating location, it see package as invalid (because of OA issue)
        -- of retaining connection pool. This is a workaround to trap the invalid package
        -- exception and recompile package (till OA provides fix)
        -- Fix done on 21-Sep-2006 (Nishant))
		WHEN ex_pkg_invalidated_state THEN
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            hz_utility_v2pub.debug
            (p_message      => ' Went in get_usage_API ex_pkg_invalidated_state EXCEPTION ',
             p_prefix        => l_debug_prefix,
             p_msg_level     => fnd_log.level_procedure,
             p_module_prefix => l_module_prefix,
             p_module        => l_module
            );
           END IF;
           recompile_pkg('HZ_GNR_MAP'||l_mapId);
           EXECUTE IMMEDIATE l_sql USING OUT l_usage_API,p_usage_code;

         WHEN ex_pkg_altered THEN
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            hz_utility_v2pub.debug
            (p_message      => ' Went in get_usage_API ex_pkg_altered EXCEPTION ',
             p_prefix        => l_debug_prefix,
             p_msg_level     => fnd_log.level_procedure,
             p_module_prefix => l_module_prefix,
             p_module        => l_module
            );
           END IF;
           recompile_pkg('HZ_GNR_MAP'||l_mapId);
           EXECUTE IMMEDIATE l_sql USING OUT l_usage_API,p_usage_code;
        END;

      EXCEPTION WHEN OTHERS THEN
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => SUBSTR(' Exception when others in get_usage_API : '||SQLERRM,1,255),
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_exception,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
        RETURN l_usage_API;
      END;
      RETURN l_usage_API;
    END get_usage_API;

  BEGIN

    x_status := fnd_api.g_ret_sts_success; -- defaulting the sucess status.
    x_addr_val_status := FND_api.g_ret_sts_success; -- defaulting the sucess status.

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => 'Begin of validation procedure validateLoc',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_procedure,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

    -- Get country code. It is possible in GNR that country name is passed.
    -- It does not matter what is passed, based on passed value, get country code
    l_country_code := get_country_code(P_COUNTRY);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => ' Derived country code : '||l_country_code,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

    -- get the mapId
    l_addr_val_level := HZ_GNR_PUB.GET_ADDR_VAL_LEVEL(l_country_code);
    x_addr_val_level := l_addr_val_level;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => ' Derived address validation level : '||l_addr_val_level,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

    l_mapid := get_map_id(l_country_code,'HZ_LOCATIONS',p_address_style);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => ' Map Id for the above country : '||l_mapid,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_statement,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

    IF l_mapid IS NULL THEN
      IF l_addr_val_level <> 'NONE'  OR  p_called_from = 'GNR' THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => ' Validation level is not set to NONE or called from is GNR and no mapping for the country. ',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
        x_status := FND_API.G_RET_STS_ERROR;
        x_addr_val_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_MAP_FOR_COUNTRY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_addr_val_level = 'NONE' THEN -- Validation level is set to none and no mapping for the country
                                           -- It is not required to do any further processing even for TAX.
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => ' Validation level is set to NONE and no mapping for the country. It is not required to do any further processing even for TAX ',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
        RETURN;
      END IF;
    END IF;

    IF p_called_from = 'GNR' AND p_usage_code = 'ALL' THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
             (p_message      => ' p_called_from is GNR and usage code is ALL. So, get all valid usages into l_usage_tbl',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
      END IF;
      i := 0;
      FOR l_c_usage IN c_usage(l_mapid) LOOP
        i := i + 1;
        l_usage_tbl(i).USAGE_CODE := l_c_usage.USAGE_CODE;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => ' Usage code '|| i ||' : '||l_c_usage.USAGE_CODE,
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
      END LOOP;
    ELSE
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
             (p_message      => ' p_called_from is not GNR and usage code is '||p_usage_code,
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
      END IF;
      l_usage_tbl(1).USAGE_CODE := p_usage_code;
    END IF;

  -- do processing only if there is any usage to be processed
  IF (l_usage_tbl.COUNT > 0) THEN
    FOR i in l_usage_tbl.FIRST .. l_usage_tbl.LAST LOOP
      l_usage_API := get_usage_API(l_mapid,l_usage_tbl(i).usage_code);
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
             (p_message      => ' Name of the usage API : '||l_usage_API,
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
      END IF;
      IF l_usage_API IS NULL THEN
        IF l_addr_val_level <> 'NONE'  OR  p_called_from = 'GNR' THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            hz_utility_v2pub.debug
                 (p_message      => ' Raising the error because, validation level is other than NONE or it is called from GNR conc prog',
                  p_prefix        => l_debug_prefix,
                  p_msg_level     => fnd_log.level_statement,
                  p_module_prefix => l_module_prefix,
                  p_module        => l_module
                 );
          END IF;
          x_status := FND_API.G_RET_STS_ERROR;
          x_addr_val_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_USAGE_FOR_COUNTRY');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_addr_val_level = 'NONE' THEN -- Validation level is set to none and no usage defined for the country
                                           -- It is not required to do any further processing even for TAX.
          IF (l_usage_tbl(i).usage_code = 'TAX' OR i = l_usage_tbl.LAST) THEN
            --Even if validateion level is NONE then tax validation has to go through.
            --So record other than last happens to be of usage <> 'TAX' the tax will not go through.
            RETURN;
          END IF;
        END IF;
      END IF;

      l_call_map := 'Y';

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        hz_utility_v2pub.debug
            (p_message      => 'Before calling HZ_GNR_MAP'||l_mapId||'.'||l_usage_API,
             p_prefix        => l_debug_prefix,
             p_msg_level     => fnd_log.level_procedure,
             p_module_prefix => l_module_prefix,
             p_module        => l_module
            );
      END IF;

      l_sql := 'BEGIN HZ_GNR_MAP'||l_mapId||'.'||l_usage_API||' (';
      l_sql := l_sql || ':P_LOCATION_ID,';
      l_sql := l_sql || ':P_COUNTRY,';
      l_sql := l_sql || ':P_STATE,';
      l_sql := l_sql || ':P_PROVINCE,';
      l_sql := l_sql || ':P_COUNTY,';
      l_sql := l_sql || ':P_CITY,';
      l_sql := l_sql || ':P_POSTAL_CODE,';
      l_sql := l_sql || ':P_POSTAL_PLUS4_CODE,';
      l_sql := l_sql || ':P_ATTRIBUTE1,';
      l_sql := l_sql || ':P_ATTRIBUTE2,';
      l_sql := l_sql || ':P_ATTRIBUTE3,';
      l_sql := l_sql || ':P_ATTRIBUTE4,';
      l_sql := l_sql || ':P_ATTRIBUTE5,';
      l_sql := l_sql || ':P_ATTRIBUTE6,';
      l_sql := l_sql || ':P_ATTRIBUTE7,';
      l_sql := l_sql || ':P_ATTRIBUTE8,';
      l_sql := l_sql || ':P_ATTRIBUTE9,';
      l_sql := l_sql || ':P_ATTRIBUTE10,';
      l_sql := l_sql || ':P_LOCK_FLAG,';
      l_sql := l_sql || ':X_CALL_MAP,';
      l_sql := l_sql || ':P_CALLED_FROM,';
      l_sql := l_sql || ':P_ADDR_VAL_LEVEL,';
      l_sql := l_sql || ':X_ADDR_WARN_MSG,';
      l_sql := l_sql || ':X_ADDR_VAL_STATUS,';
      l_sql := l_sql || ':X_STATUS';
      l_sql := l_sql || '); END;';

      BEGIN
          EXECUTE IMMEDIATE l_sql USING P_LOCATION_ID,
                                      P_COUNTRY,
                                      P_STATE,
                                      P_PROVINCE,
                                      P_COUNTY,
                                      P_CITY,
                                      P_POSTAL_CODE,
                                      P_POSTAL_PLUS4_CODE,
                                      P_ATTRIBUTE1,
                                      P_ATTRIBUTE2,
                                      P_ATTRIBUTE3,
                                      P_ATTRIBUTE4,
                                      P_ATTRIBUTE5,
                                      P_ATTRIBUTE6,
                                      P_ATTRIBUTE7,
                                      P_ATTRIBUTE8,
                                      P_ATTRIBUTE9,
                                      P_ATTRIBUTE10,
                                      P_LOCK_FLAG,
                                      IN OUT L_CALL_MAP,
                                      P_CALLED_FROM,
                                      l_addr_val_level,
                                      OUT X_ADDR_WARN_MSG,
                                      IN OUT X_ADDR_VAL_STATUS,
                                      IN OUT L_STATUS;

        x_status := L_STATUS;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
              (p_message      => 'After calling HZ_GNR_MAP'||l_mapId||'.'||l_usage_API,
               p_prefix        => l_debug_prefix,
               p_msg_level     => fnd_log.level_procedure,
               p_module_prefix => l_module_prefix,
               p_module        => l_module
              );
        END IF;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
              (p_message      => ' Return status : '||L_STATUS|| ' and address validation status : '||X_ADDR_VAL_STATUS,
               p_prefix        => l_debug_prefix,
               p_msg_level     => fnd_log.level_procedure,
               p_module_prefix => l_module_prefix,
               p_module        => l_module
              );
        END IF;

      EXCEPTION
      WHEN OTHERS THEN
         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
               (p_message      => SUBSTR(' Exception when others in '||' HZ_GNR_MAP'||l_mapId||'.'||l_usage_API ||' : ' ||SQLERRM,1,255),
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_exception,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
         END IF;
         x_status := FND_API.G_RET_STS_ERROR;
      END;

      IF p_called_from = 'VALIDATE'  and l_usage_tbl(i).usage_code <> 'TAX' and p_location_id IS NOT NULL THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => 'p_called_from is VALIDATE and usage code is not TAX and location_id IS NOT NULL. So, call tax validation.',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
        l_usage_API := get_usage_API(l_mapid,'TAX');
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message      => ' Name of the usage API : '||l_usage_API,
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
               );
        END IF;
        IF l_usage_API IS NULL THEN -- there is no mapping for Tax and no GNR processing or TAX is required.
          RETURN;
        END IF;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
              (p_message      => 'Before calling HZ_GNR_MAP'||l_mapId||'.'||l_usage_API,
               p_prefix        => l_debug_prefix,
               p_msg_level     => fnd_log.level_procedure,
               p_module_prefix => l_module_prefix,
               p_module        => l_module
              );
        END IF;

        l_sql := 'BEGIN HZ_GNR_MAP'||l_mapId||'.'||l_usage_API||' (';
        l_sql := l_sql || ':P_LOCATION_ID,';
        l_sql := l_sql || ':P_COUNTRY,';
        l_sql := l_sql || ':P_STATE,';
        l_sql := l_sql || ':P_PROVINCE,';
        l_sql := l_sql || ':P_COUNTY,';
        l_sql := l_sql || ':P_CITY,';
        l_sql := l_sql || ':P_POSTAL_CODE,';
        l_sql := l_sql || ':P_POSTAL_PLUS4_CODE,';
        l_sql := l_sql || ':P_ATTRIBUTE1,';
        l_sql := l_sql || ':P_ATTRIBUTE2,';
        l_sql := l_sql || ':P_ATTRIBUTE3,';
        l_sql := l_sql || ':P_ATTRIBUTE4,';
        l_sql := l_sql || ':P_ATTRIBUTE5,';
        l_sql := l_sql || ':P_ATTRIBUTE6,';
        l_sql := l_sql || ':P_ATTRIBUTE7,';
        l_sql := l_sql || ':P_ATTRIBUTE8,';
        l_sql := l_sql || ':P_ATTRIBUTE9,';
        l_sql := l_sql || ':P_ATTRIBUTE10,';
        l_sql := l_sql || ':P_LOCK_FLAG,';
        l_sql := l_sql || ':X_CALL_MAP,';
        l_sql := l_sql || ':P_CALLED_FROM,';
        l_sql := l_sql || ':P_ADDR_VAL_LEVEL,';
        l_sql := l_sql || ':X_ADDR_WARN_MSG,';
        l_sql := l_sql || ':X_ADDR_VAL_STATUS,';
        l_sql := l_sql || ':X_STATUS';
        l_sql := l_sql || '); END;';


        BEGIN
            EXECUTE IMMEDIATE l_sql USING P_LOCATION_ID,
                                        P_COUNTRY,
                                        P_STATE,
                                        P_PROVINCE,
                                        P_COUNTY,
                                        P_CITY,
                                        P_POSTAL_CODE,
                                        P_POSTAL_PLUS4_CODE,
                                        P_ATTRIBUTE1,
                                        P_ATTRIBUTE2,
                                        P_ATTRIBUTE3,
                                        P_ATTRIBUTE4,
                                        P_ATTRIBUTE5,
                                        P_ATTRIBUTE6,
                                        P_ATTRIBUTE7,
                                        P_ATTRIBUTE8,
                                        P_ATTRIBUTE9,
                                        P_ATTRIBUTE10,
                                        P_LOCK_FLAG,
                                        IN OUT L_CALL_MAP,
                                        P_CALLED_FROM,
                                        l_addr_val_level,
                                        OUT L_ADDR_WARN_MSG,
                                        IN OUT L_ADDR_VAL_STATUS,
                                        IN OUT L_STATUS;

            -- even if Tax validation fails no need to change the overall status x_status := L_STATUS;

          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            hz_utility_v2pub.debug
                (p_message      => 'After calling HZ_GNR_MAP'||l_mapId||'.'||l_usage_API,
                 p_prefix        => l_debug_prefix,
                 p_msg_level     => fnd_log.level_procedure,
                 p_module_prefix => l_module_prefix,
                 p_module        => l_module
                );
          END IF;

          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            hz_utility_v2pub.debug
                (p_message      => ' Return status : '||L_STATUS|| ' and address validation status : '||L_ADDR_VAL_STATUS,
                 p_prefix        => l_debug_prefix,
                 p_msg_level     => fnd_log.level_procedure,
                 p_module_prefix => l_module_prefix,
                 p_module        => l_module
                );
          END IF;

          EXCEPTION  WHEN OTHERS THEN
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              hz_utility_v2pub.debug
                  (p_message      => SUBSTR(' Exception when others in '||' HZ_GNR_MAP'||l_mapId||'.'||l_usage_API ||' : ' ||SQLERRM,1,255),
                   p_prefix        => l_debug_prefix,
                   p_msg_level     => fnd_log.level_exception,
                   p_module_prefix => l_module_prefix,
                   p_module        => l_module
                  );
            END IF;
            x_status := FND_API.G_RET_STS_ERROR;
          END;
        END IF;
      END LOOP;
    ELSE
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
             (p_message      => ' There is no active usage available for validation',
              p_prefix        => l_debug_prefix,
              p_msg_level     => fnd_log.level_statement,
              p_module_prefix => l_module_prefix,
              p_module        => l_module
             );
       END IF;
       -- no active usage available to be checked
       -- we want to raise error message only if validation level is other than NONE
       -- If it is called from GNR conc prog, we will always try to create GNR
       -- irrespective of validation level.
	   IF ((l_addr_val_level <> 'NONE')  OR  (p_called_from = 'GNR')) THEN
              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                hz_utility_v2pub.debug
                    (p_message      => ' Raising the error because, validation level is other than NONE or it is called from GNR conc prog',
                     p_prefix        => l_debug_prefix,
                     p_msg_level     => fnd_log.level_statement,
                     p_module_prefix => l_module_prefix,
                     p_module        => l_module
                    );
              END IF;
	      x_status := FND_API.G_RET_STS_ERROR;
	      x_addr_val_status := FND_API.G_RET_STS_ERROR;
	      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_USAGE_FOR_COUNTRY');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   ELSE
	     NULL;
	   END IF;
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      hz_utility_v2pub.debug
           (p_message      => 'End of validation procedure validateLoc',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_procedure,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;
  END validateLoc;
END;

/
