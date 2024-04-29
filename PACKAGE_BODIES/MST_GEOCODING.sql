--------------------------------------------------------
--  DDL for Package Body MST_GEOCODING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_GEOCODING" AS
/*$Header: MSTGEOCB.pls 115.9 2004/01/13 01:24:47 jnhuang noship $*/


Function Get_local_time(p_location_id IN number,
                        p_server_time IN date) return DATE is
 p_api_version                     NUMBER;
 p_init_msg_list                   VARCHAR2(80);
 p_timezone_code                   VARCHAR2(80);
 p_timezone_id                     NUMBER;
 x_GMT_deviation                   NUMBER;
 x_timezone_short_code             VARCHAR2(30);
 x_name                            VARCHAR2(240);
 x_return_status                   VARCHAR2(80);
 x_msg_count                       VARCHAR2(80);
 x_msg_data                        VARCHAR2(2048);

 l_server_timezone_id              NUMBER;
 l_server_timezone_code            VARCHAR2(80);
 l_server_timezone_short_code      VARCHAR2(30);
 l_server_gmt_offset               NUMBER;
 l_name                            VARCHAR2(240);

BEGIN

  p_api_version := 1;
  p_init_msg_list := NULL;
  l_server_gmt_offset := -8;

  l_server_timezone_id := to_number( FND_PROFILE.VALUE('SERVER_TIMEZONE_ID') );

  BEGIN

     select TIMEZONE_CODE
     into   l_server_timezone_code
     from   FND_TIMEZONES_VL
     where  UPGRADE_TZ_ID = l_server_timezone_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       return p_server_time;

  END;

  -- Now get the GMT offset for the server. It will be used later
  -- to convert to local time

  HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     l_server_timezone_id,
     l_server_timezone_code,
     p_server_time,
     l_server_gmt_offset,
     l_server_timezone_short_code,
     l_name,
     x_return_status,
     x_msg_count,
     x_msg_data );


  BEGIN

     select FND.UPGRADE_TZ_ID, FND.TIMEZONE_CODE
     into   p_timezone_id, p_timezone_code
     from   WSH_LOCATIONS WSH, FND_TIMEZONES_VL FND
     where  WSH.TIMEZONE_CODE = FND.TIMEZONE_CODE AND
            WSH.WSH_LOCATION_ID = p_location_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       return p_server_time;
  END;

  -- The following API call gets the GMT offset for the location

  HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     p_timezone_id,
     p_timezone_code,
     p_server_time,
     x_GMT_deviation,
     x_timezone_short_code,
     x_name,
     x_return_status,
     x_msg_count,
     x_msg_data );

   IF (x_GMT_deviation IS NOT NULL) THEN
       return p_server_time + (x_GMT_deviation - l_server_gmt_offset)/24.0 ;
   ELSE
       return p_server_time;
   END IF;

END Get_local_time;

Function Get_server_time(p_location_id IN number,
                         p_local_time IN date) return DATE is
 p_api_version                     NUMBER;
 p_init_msg_list                   VARCHAR2(80);
 p_timezone_id                     NUMBER;
 p_timezone_code                   VARCHAR2(80);

 x_GMT_deviation                   NUMBER;
 x_timezone_short_code             VARCHAR2(30);
 x_name                            VARCHAR2(240);
 x_return_status                   VARCHAR2(80);
 x_msg_count                       VARCHAR2(80);
 x_msg_data                        VARCHAR2(2048);

 l_server_timezone_id              NUMBER;
 l_server_timezone_code            VARCHAR2(80);
 l_server_timezone_short_code      VARCHAR2(30);
 l_server_gmt_offset               NUMBER;
 l_name                            VARCHAR2(240);


BEGIN
  p_api_version := 1;
  p_init_msg_list := NULL;
  l_server_gmt_offset := -8;

  l_server_timezone_id := to_number( FND_PROFILE.VALUE('SERVER_TIMEZONE_ID') );

  BEGIN

     select TIMEZONE_CODE
     into   l_server_timezone_code
     from   FND_TIMEZONES_VL
     where  UPGRADE_TZ_ID = l_server_timezone_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       return p_local_time;

  END;

  -- Now get the GMT offset for the server. It will be used later
  -- to convert to local time

  HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     l_server_timezone_id,
     l_server_timezone_code,
     p_local_time,
     l_server_gmt_offset,
     l_server_timezone_short_code,
     l_name,
     x_return_status,
     x_msg_count,
     x_msg_data );

  BEGIN
     select FND.UPGRADE_TZ_ID, FND.TIMEZONE_CODE
     into   p_timezone_id, p_timezone_code
     from   WSH_LOCATIONS WSH, FND_TIMEZONES_VL FND
     where  WSH.TIMEZONE_CODE = FND.TIMEZONE_CODE AND
            WSH.WSH_LOCATION_ID = p_location_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     return p_local_time;

  END;

  -- The following API call gets the GMT offset for the location

  HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     p_timezone_id,
     p_timezone_code,
     p_local_time,
     x_GMT_deviation,
     x_timezone_short_code,
     x_name,
     x_return_status,
     x_msg_count,
     x_msg_data );

  IF (x_GMT_deviation IS NOT NULL) THEN
     return p_local_time + (l_server_gmt_offset - x_GMT_deviation)/24.0;
  ELSE
     return p_local_time;
  END IF;

END Get_server_time;


Function Get_timezone_code(p_location_id IN number,
                           p_date IN date) return VARCHAR2 is
 p_api_version                     NUMBER;
 p_init_msg_list                   VARCHAR2(80);
 p_timezone_id                     NUMBER;
 p_timezone_code                   VARCHAR2(80);
 x_gmt_deviation                   NUMBER;
 x_timezone_short_code             VARCHAR2(30);
 x_name                            VARCHAR2(240);
 x_return_status                   VARCHAR2(80);
 x_msg_count                       VARCHAR2(80);
 x_msg_data                        VARCHAR2(2048);

BEGIN

  p_api_version := 1;
  p_init_msg_list := NULL;
  x_timezone_short_code := NULL;

  -- If the date is NULL, then the time zone code should also be NULL

  IF (p_date IS NULL) THEN
     return x_timezone_short_code;
  END IF;

  -- Initialize timezone_code to server timezone code
  -- If no information exists in WSH_LOCATIONS or HZ_TIMEZONES, we will
  -- return the server timezone code

  p_timezone_id := to_number( FND_PROFILE.VALUE('SERVER_TIMEZONE_ID') );

  BEGIN

     select TIMEZONE_CODE
     into   p_timezone_code
     from   FND_TIMEZONES_VL
     where  UPGRADE_TZ_ID = p_timezone_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       return x_timezone_short_code;

  END;

  HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     p_timezone_id,
     p_timezone_code,
     p_date,
     x_gmt_deviation,
     x_timezone_short_code,
     x_name,
     x_return_status,
     x_msg_count,
     x_msg_data );


  -- Finished getting the server time zone short code
  -- Now get the local specific time zone short code

  BEGIN
     select FND.UPGRADE_TZ_ID, FND.TIMEZONE_CODE
     into   p_timezone_id, p_timezone_code
     from   WSH_LOCATIONS WSH, FND_TIMEZONES_VL FND
     where  WSH.TIMEZONE_CODE = FND.TIMEZONE_CODE AND
            WSH.WSH_LOCATION_ID = p_location_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     return x_timezone_short_code;

  END;

    HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     p_timezone_id,
     p_timezone_code,
     p_date,
     x_gmt_deviation,
     x_timezone_short_code,
     x_name,
     x_return_status,
     x_msg_count,
     x_msg_data );

  return x_timezone_short_code;

END Get_timezone_code;

Function Get_server_timezone_code(p_date IN date) return VARCHAR2 is
 p_api_version                     NUMBER;
 p_init_msg_list                   VARCHAR2(80);
 p_timezone_id                     NUMBER;
 p_timezone_code                   VARCHAR2(80);
 x_gmt_deviation                   NUMBER;
 x_timezone_short_code             VARCHAR2(30);
 x_name                            VARCHAR2(240);
 x_return_status                   VARCHAR2(80);
 x_msg_count                       VARCHAR2(80);
 x_msg_data                        VARCHAR2(2048);

BEGIN

  p_api_version := 1;
  p_init_msg_list := NULL;
  x_timezone_short_code := NULL;

  -- If the date is NULL, then the time zone code should also be NULL

  IF (p_date IS NULL) THEN
     return x_timezone_short_code;
  END IF;

  -- Initialize timezone_code to server timezone code
  -- If no information exists in WSH_LOCATIONS or HZ_TIMEZONES, we will
  -- return the server timezone code

  p_timezone_id := to_number( FND_PROFILE.VALUE('SERVER_TIMEZONE_ID') );

  BEGIN

     select TIMEZONE_CODE
     into   p_timezone_code
     from   FND_TIMEZONES_VL
     where  UPGRADE_TZ_ID = p_timezone_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       return x_timezone_short_code;

  END;

  HZ_TIMEZONE_PUB.Get_Timezone_Short_Code(
     p_api_version,
     p_init_msg_list,
     p_timezone_id,
     p_timezone_code,
     p_date,
     x_gmt_deviation,
     x_timezone_short_code,
     x_name,
     x_return_status,
     x_msg_count,
     x_msg_data );

  return x_timezone_short_code;

END Get_server_timezone_code;


Procedure Get_facility_parameters(p_api_version IN NUMBER
, p_init_msg_list IN VARCHAR2
, x_pallet_load_rate OUT NOCOPY NUMBER
, x_pallet_unload_rate OUT NOCOPY NUMBER
, x_non_pallet_load_rate OUT NOCOPY NUMBER
, x_non_pallet_unload_rate OUT NOCOPY NUMBER
, x_pallet_handling_uom OUT NOCOPY VARCHAR2
, x_non_pallet_handling_uom OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2

) is

v_statement          varchar2(20000);
l_return_status      varchar2(10);
p_global_user_id     number;
p_is_spliced         number;
p_SqlErrM            varchar2(2000);

BEGIN

     p_global_user_id := -9999;

     x_pallet_load_rate := NULL;
     x_pallet_unload_rate := NULL;
     x_non_pallet_load_rate := NULL;
     x_non_pallet_unload_rate := NULL;
     x_pallet_handling_uom := NULL;
     x_non_pallet_handling_uom:= NULL;


     v_statement :=
             'select ' ||
             'PALLETIZED_LOADING_RATE, ' ||
             'PALLETIZED_UNLOADING_RATE, ' ||
             'NON_PALLETIZED_LOADING_RATE, ' ||
             'NON_PALLETIZED_UNLOADING_RATE, ' ||
             'PALLETIZED_WEIGHT_UOM, ' ||
             'NON_PALLETIZED_WEIGHT_UOM ' ||
             'from MST_PARAMETERS ' ||
             'where USER_ID = :p_global_user_id';

     select COUNT(*)
     into p_is_spliced
     from FND_APPLICATION
     where APPLICATION_SHORT_NAME = 'MST';


     IF (p_is_spliced = 1) THEN
        EXECUTE IMMEDIATE v_statement
        INTO              x_pallet_load_rate,
                          x_pallet_unload_rate,
                          x_non_pallet_load_rate,
                          x_non_pallet_unload_rate,
                          x_pallet_handling_uom,
                          x_non_pallet_handling_uom
          USING p_global_user_id ;

          IF    (x_pallet_handling_uom = '34') THEN
                    x_pallet_handling_uom := 'PALLET';
          ELSIF (x_pallet_handling_uom = '35') THEN
                    x_pallet_handling_uom := 'CONTAINER';
          END IF;

          IF    (x_non_pallet_handling_uom = '35') THEN
                    x_non_pallet_handling_uom := 'CONTAINER';
          END IF;

     END IF;


EXCEPTION
  WHEN OTHERS THEN
    p_SqlErrM := sqlerrm||' (Error in Get_facility_parameters)';

END Get_facility_parameters;

END MST_GEOCODING;

/
