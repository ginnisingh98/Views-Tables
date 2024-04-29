--------------------------------------------------------
--  DDL for Package Body CS_TZ_GET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TZ_GET_DETAILS_PVT" AS
/* $Header: csvtzgdb.pls 120.2 2005/11/09 10:15:17 pnkalari ship $ */

/*******************************************************************************
  -- Start of comments
  -- API name            : Get_GMT_DEVIATION
  -- Type                : Private
  -- Pre-reqs            : None.
  -- Function            : This procedure finds the GMT offset of p_end_tz_id
  --
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  --                         p_start_tz_id             NUMBER
  --                         p_end_tz_id               NUMBER
  --                         p_Time_Lag                NUMBER
  -- OUT                 :
  --
  --                         x_GMT_DEV                 NUMBER
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments

*******************************************************************************/

  PROCEDURE GET_GMT_DEVIATION(P_API_VERSION    IN  NUMBER,
                              P_INIT_MSG_LIST  IN  VARCHAR2,
                              P_START_TZ_ID    IN  NUMBER,
                              P_END_TZ_ID      IN  NUMBER,
                              P_TIME_LAG       IN  NUMBER,
                              X_GMT_DEV        OUT NOCOPY NUMBER,
                              X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                              X_MSG_COUNT      OUT NOCOPY NUMBER,
                              X_MSG_DATA       OUT NOCOPY VARCHAR2)

  IS

  l_api_version      number := 1.0 ;
  l_return_status    VARCHAR2(2);
  l_start_tz_id      number;
  l_end_tz_id        number;
  l_time_lag         number;
  l_status           varchar2(2);
  l_name             varchar2(80);
  l_g_name           varchar2(80);
  l_date             date;
  l_s_GMT_dev        number;
  l_e_GMT_dev        number;
  l_msg_count        number;
  l_msg_data         varchar2(2000);
  l_api_name         varchar2(30) := 'GET_GMT_DEVIATION';

  BEGIN

    SAVEPOINT get_gmt_deviation;

    l_start_tz_id := P_START_TZ_ID;
    l_end_tz_id := P_END_TZ_ID;
    l_time_lag  := P_TIME_LAG;

    --  Current System date is used in the Get_Timezone procedure to find out
    --  the Daylight Savings  time for the current year, if applicable.

     l_date := sysdate;

    --  If END  Time Zone Id is not null, then calculate the GMT offset
    --  and return that value.
    --  If it is null, then calculate the GMT offset of the Start  Time and
    --  subtract the time lag to find out the GMT offset of the End time


    IF  (l_end_tz_id  IS NOT NULL) THEN

      HZ_TIMEZONE_PUB.Get_Timezone_GMT_Deviation(p_api_version,
                                                 p_init_msg_list,
                                                 l_end_tz_id,
                                                 l_date,
                                                 l_e_GMT_dev,
                                                 l_g_name,
                                                 l_name,
                                                 l_return_status,
                                                 l_msg_Count,
                                                 l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;

      X_GMT_DEV := l_e_GMT_dev;

    ELSIF  (l_start_tz_id  IS NOT NULL) THEN

      HZ_TIMEZONE_PUB.Get_Timezone_GMT_Deviation (p_api_version,
                                                  p_init_msg_list,
                                                  l_start_tz_id,
                                                  l_date,
                                                  l_s_GMT_dev,
                                                  l_g_name,
                                                  l_name,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF  ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;

      -- If time lag is null, then return the GMT offset of the Server time.

      IF  (l_time_lag  IS NOT NULL) THEN
         X_GMT_DEV := l_s_GMT_dev - l_time_lag;
      ELSE
         X_GMT_DEV := l_s_GMT_dev;
      END IF;
    END IF;

    x_return_status := l_return_status;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  get_gmt_deviation;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                   p_data => x_msg_data ,
                                   p_encoded => fnd_api.g_false );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  get_gmt_deviation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                   p_data => x_msg_data ,
                                   p_encoded => fnd_api.g_false );

     WHEN OTHERS THEN
        ROLLBACK TO  get_gmt_deviation;
        x_return_status := FND_API.G_RET_STS_unexp_error ;

        IF fnd_msg_pub.check_msg_level( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
        END IF;

        fnd_msg_pub.count_and_get (p_count =>x_msg_count ,
                                   p_data => x_msg_data ,
                                   p_encoded => fnd_api.g_false );

  END;


/*******************************************************************************
  -- Start of comments
  -- API name            : Get_Leadtime
  -- Type                : Private
  -- Pre-reqs            : None.
  -- Function            : This procedure finds the time difference between
  --                       two given timezones
  --
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  --                         p_start_tz_id             NUMBER    Required
  --                         p_end_tz_id               NUMBER    Required
  -- OUT                 :
  --
  --                         x_leadtime                NUMBER
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments
*******************************************************************************/


  PROCEDURE GET_LEADTIME(P_API_VERSION    IN  NUMBER,
                         P_INIT_MSG_LIST  IN  VARCHAR2,
                         P_START_TZ_ID    IN  NUMBER,
                         P_END_TZ_ID      IN  NUMBER,
                         X_LEADTIME       OUT NOCOPY NUMBER,
                         X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT      OUT NOCOPY NUMBER,
                         X_MSG_DATA       OUT NOCOPY VARCHAR2)

  IS


  l_api_version     number := 1.0 ;
  l_return_status    VARCHAR2(2);
  l_start_tz_id     number;
  l_end_tz_id       number;
  l_status          varchar2(2);
  l_name            varchar2(80);
  l_g_name          varchar2(80);
  l_date            date;
  l_s_GMT_dev       number;
  l_e_GMT_dev       number;
  l_msg_count       number;
  l_msg_data        varchar2(2000);
  l_api_name         varchar2(30) := 'GET_LEADTIME';


  BEGIN

    SAVEPOINT get_leadtime;

    l_start_tz_id := P_START_TZ_ID;
    l_end_tz_id := P_END_TZ_ID;

    --  Current System date is used in the Get_Timezone procedure
    --  to find out the Daylight Savings  time for the current year,
    --  if applicable.

    l_date := sysdate;

    --  Find the time deviation from the GMT for both the timezonesi
    --  if the sites are in two  different  time zones.

    IF  (l_start_tz_id <> l_end_tz_id)

    THEN

    -- Calls the procedure to find the difference between the time
    -- in each Time zone and GMT. The return values l_s_GMT_dev and
    -- l_e_GMT_dev store the  time difference.

      HZ_TIMEZONE_PUB.Get_Timezone_GMT_Deviation(p_api_version,
                                                 p_init_msg_list,
                                                 l_start_tz_id,
                                                 l_date,
                                                 l_s_GMT_dev,
                                                 l_g_name,
                                                 l_name,
                                                 l_return_status,
                                                 l_msg_count,
                                                 l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF ;

      HZ_TIMEZONE_PUB.Get_Timezone_GMT_Deviation(p_api_version,
                                                 p_init_msg_list,
                                                 l_end_tz_id,
                                                 l_date,
                                                 l_e_GMT_dev,
                                                 l_g_name,
                                                 l_name,
                                                 l_return_status,
                                                 l_msg_count,
                                                 l_msg_data);

       IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         RAISE FND_API.G_EXC_ERROR ;
       ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF ;

       -- Calculate the timelag between two timezones.

       x_leadtime  := l_s_GMT_dev - l_e_GMT_dev;

     ELSE

	  l_return_status := FND_API.G_RET_STS_SUCCESS;
	  x_leadtime      := 0;

     END IF;

     x_return_status := l_return_status;

   EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO get_leadtime;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                  p_data => x_msg_data ,
                                  p_encoded => fnd_api.g_false );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO get_leadtime;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                   p_data => x_msg_data ,
                                   p_encoded => fnd_api.g_false );

     WHEN OTHERS THEN
       ROLLBACK TO get_leadtime;
       x_return_status := FND_API.G_RET_STS_unexp_error ;

       IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
       END IF;

       fnd_msg_pub.count_and_get ( p_count =>x_msg_count ,
                                   p_data => x_msg_data ,
                                   p_encoded => fnd_api.g_false );

   END;


/*******************************************************************************

  -- Start of comments
  -- API name            : Get_Leadtime
  -- Type                : Private
  -- Pre-reqs            : None.
  -- Function            : This procedure finds the lead time lag between
  --                       two cities given the Timezone of one City and
  --                       the City name, State the Country it belongs to
  --                       for the other
  --
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  --                         p_start_tz_id             NUMBER    Required
  --                         p_end_zip_code            VARCHAR2  Required
  --                         p_end_city                VARCHAR2  Required
  --                         p_end_state               VARCHAR2  Required
  --                         p_end_country             VARCHAR2  Required
  --
  -- OUT                 :
  --
  --                         x_GMT_DEV                 NUMBER
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments
*******************************************************************************/


  PROCEDURE  GET_LEADTIME (P_API_VERSION   IN      NUMBER,
                           P_INIT_MSG_LIST IN      VARCHAR2,
                           P_START_TZ_ID   IN      NUMBER,
     			   P_END_ZIP_CODE  IN      VARCHAR2,
                           P_END_CITY      IN      VARCHAR2,
                           P_END_STATE     IN      VARCHAR2,
                           P_END_COUNTRY   IN      VARCHAR2,
                           X_LEADTIME      OUT  NOCOPY  NUMBER,
                           X_RETURN_STATUS OUT  NOCOPY   VARCHAR2,
                           X_MSG_COUNT     OUT  NOCOPY   NUMBER,
                           X_MSG_DATA      OUT  NOCOPY   VARCHAR2)


  IS


  l_api_version        number := 1.0 ;
  l_return_status      VARCHAR2(2) ;
  l_start_tz_id        number;
  l_end_tz_id          number;
  l_status             varchar2(2);
  l_name               varchar2(80);
  l_g_name             varchar2(80);
  l_date               date;
  l_s_GMT_dev          number;
  l_e_GMT_dev          number;
  l_msg_count          number;
  l_msg_data           varchar2(2000);
  l_api_name           varchar2(30) := 'GET_LEADTIME';


  BEGIN

    SAVEPOINT get_leadtime;

    l_start_tz_id := P_START_TZ_ID;

    -- Find the Time Zone Id for a given city. End City is the city
    -- given.
    -- Commented out this code becasue of post_query error
  /*  HZ_TIMEZONE_PUB.Get_Timezone_ID (p_api_version,
                                     p_init_msg_list,
	    						  p_end_zip_code,
                                     p_end_city,
                                     p_end_state,
                                     p_end_country,
                                     l_end_tz_id,
                                     l_return_status,
                                     l_msg_count,
                                     l_msg_data);

    IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;

    --  Current System date is used in the Get_Timezone procedure to
    --  find out the Daylight Savings  time for the current year, if applicable.

    l_date := sysdate;
   */

    --  Find the time deviation from the GMT for both the timezones
    --  if the sites are in two different  time zones.

    IF  (l_start_tz_id <> l_end_tz_id)

    THEN

     -- Calls the procedure to find the difference between the time in
     -- each Time zone and GMT. The return values l_s_GMT_dev and
     -- l_e_GMT_dev store the  time difference.

       HZ_TIMEZONE_PUB.Get_Timezone_GMT_Deviation(p_api_version,
                                                  p_init_msg_list,
                                                  l_start_tz_id,
                                                  l_date,
                                                  l_s_GMT_dev,
                                                  l_g_name,
                                                  l_name,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);


       IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         RAISE FND_API.G_EXC_ERROR ;
       ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF ;


       HZ_TIMEZONE_PUB.Get_Timezone_GMT_Deviation(p_api_version,
                                                  p_init_msg_list,
                                                  l_end_tz_id,
                                                  l_date,
                                                  l_e_GMT_dev,
                                                  l_g_name,
                                                  l_name,
                                                  l_return_status,
                                                  l_msg_count,
                                                  l_msg_data);

       IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         RAISE FND_API.G_EXC_ERROR ;
       ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF ;


       -- Calculate the timelag between two timezones.

       x_leadtime  := l_s_GMT_dev - l_e_GMT_dev;

     ELSE

	  l_return_status := FND_API.G_RET_STS_SUCCESS;
	  x_leadtime      := 0;


     END IF;

     x_return_status := l_return_status;

   EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO get_leadtime;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                  p_data => x_msg_data ,
                                  p_encoded => fnd_api.g_false );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO get_leadtime;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                  p_data => x_msg_data ,
                                  p_encoded => fnd_api.g_false );

     WHEN OTHERS THEN
       ROLLBACK TO get_leadtime;
       x_return_status := FND_API.G_RET_STS_unexp_error ;

       IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
       END IF;

       fnd_msg_pub.count_and_get (p_count =>x_msg_count ,
                                  p_data => x_msg_data ,
                                  p_encoded => fnd_api.g_false );

   END;
/*====================================================================================================+
==
==  Procedure name        : Customer_Preferred_Time_Zone
==
==  Description           :
==    This procedure derives the time zone in the following order :
==    Incident timezone, Contact address timezone, Contact phone timezone, User entered contact timezone,
==    Customer address timezone, Customer phone timezone, and Server timezone.
==  Modification History  :
==
==  Date        Name       Desc
==  ----------  ---------  ---------------------------------------------
==  11/09/2005  PNKALARI   Bug Fixed 4705669. Replace timezone_code with name in timezone_name cursor.
======================================================================================================*/
PROCEDURE CUSTOMER_PREFERRED_TIME_ZONE
( p_incident_id            IN  NUMBER
, p_task_id                IN  NUMBER
, p_resource_id            IN  NUMBER
, p_cont_pref_time_zone_id IN  NUMBER
, p_incident_location_id   IN  NUMBER DEFAULT NULL
, p_incident_location_type IN VARCHAR2 DEFAULT NULL
, p_contact_party_id       IN  NUMBER DEFAULT NULL
, p_contact_phone_id       IN  NUMBER DEFAULT NULL
, p_contact_address_id     IN  NUMBER DEFAULT NULL
, p_customer_id            IN  NUMBER DEFAULT NULL
, p_customer_phone_id      IN  NUMBER DEFAULT NULL
, p_customer_address_id    IN  NUMBER DEFAULT NULL
, x_timezone_id            OUT NOCOPY NUMBER
, x_timezone_name          OUT NOCOPY VARCHAR2
)
IS

l_tz_id                   NUMBER ;
l_incident_location_type  VARCHAR2(20) ;
l_incident_location_id    NUMBER ;

  -- Cursor to derive time zone from Charges API.

  -- Cursor to derive Task location type
  CURSOR task_address_location_type IS
    SELECT a.incident_location_id, a.incident_location_type
    FROM  cs_incidents_all_b a, jtf_tasks_b b
    WHERE a.incident_id = b.source_object_id
      AND b.source_object_type_code = 'SR'
      AND b.task_id = p_task_id ;

  -- Cursor to derive Task time zone for party site
  CURSOR task_party_site_timezone IS
    SELECT b.timezone_id
    FROM   hz_party_sites a, hz_locations b
    WHERE  a.location_id = b.location_id
      --AND  a.identifying_address_flag = 'Y'
      AND  a.party_site_id = l_incident_location_id ;

  -- Cursor to derive Task time zone for location
  CURSOR task_location_timezone IS
    SELECT timezone_id
    FROM   hz_locations
    WHERE  location_id = l_incident_location_id ;

  -- Cursor to derive time zone for technician
  CURSOR technician_timezone IS
    SELECT time_zone
    FROM jtf_rs_resource_extns_vl
    WHERE resource_id = p_resource_id ;

  -- Cursor to derive time zone for Primary Contact address
  CURSOR contact_timezone IS
    SELECT b.timezone_id
    FROM   hz_party_sites a, hz_locations b, cs_hz_sr_contact_points c
    WHERE  a.party_id = c.party_id
      AND  a.identifying_address_flag = 'Y'
      AND  c.primary_flag = 'Y'
      AND  a.location_id = b.location_id
      AND  c.incident_id = p_incident_id ;

  -- Cursor to derive time zone for Primary Contact phone
  CURSOR contact_cont_point_tz IS
    SELECT a.timezone_id
    FROM   hz_contact_points a, cs_hz_sr_contact_points b
    WHERE  a.owner_table_id = b.party_id
      AND  a.contact_point_type = b.contact_point_type
      AND  b.contact_point_type = 'PHONE'
      AND  a.primary_flag = b.primary_flag
      AND  b.primary_flag = 'Y'
      AND  b.incident_id = p_incident_id ;

  -- Cursor to derive time zone for contact entered on UI
  CURSOR cont_pref_time_zone_id IS
    SELECT time_zone_id
    FROM   cs_incidents_all_b
    WHERE  incident_id = p_incident_id;

  -- Cursor to derive time zone for Customer address
  CURSOR customer_timezone IS
    SELECT b.timezone_id
    FROM   hz_party_sites a, hz_locations b, cs_incidents_all_b c
    WHERE  a.party_id = c.customer_id
      AND  a.identifying_address_flag = 'Y'
      AND  a.location_id = b.location_id
      AND  c.incident_id = p_incident_id ;

  -- Cursor to derive time zone for Customer phone
  CURSOR customer_cont_point_tz IS
    SELECT a.timezone_id
    FROM   hz_contact_points a, cs_incidents_all_b b
    WHERE  a.owner_table_id = b.customer_id
    AND    a.contact_point_type = 'PHONE'
    AND    a.primary_flag = 'Y'
    AND    b.incident_id = p_incident_id ;


  -- Cursor to derive time zone from SR Form and SR Tab.

  -- Cursor to derive time zone for party site
  CURSOR f_incident_party_site_timezone IS
    SELECT b.timezone_id
    FROM   hz_party_sites a, hz_locations b
    WHERE  a.location_id = b.location_id
      --AND  a.identifying_address_flag = 'Y'
      AND  a.party_site_id = p_incident_location_id ;

  -- Cursor to derive time zone for location
  CURSOR f_incident_location_timezone IS
    SELECT timezone_id
    FROM   hz_locations
    WHERE  location_id = p_incident_location_id ;

  -- Cursor to derive time zone for Primary Contact address
  CURSOR f_contact_timezone IS
    SELECT b.timezone_id
    FROM   hz_party_sites a, hz_locations b
    WHERE  a.location_id = b.location_id
      AND  a.identifying_address_flag = 'Y'
      AND  a.party_id = p_contact_party_id ;

  -- Cursor to derive time zone for Primary Contact phone
  CURSOR f_contact_cont_point_tz IS
    SELECT timezone_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
      AND  primary_flag = 'Y'
      AND  owner_table_id = p_contact_party_id ;

  -- Cursor to derive time zone for Customer address
  CURSOR f_customer_timezone IS
    SELECT b.timezone_id
    FROM   hz_party_sites a, hz_locations b
    WHERE  a.location_id = b.location_id
      AND  a.identifying_address_flag = 'Y'
      AND  a.party_id = p_customer_id ;

  -- Cursor to derive time zone for Customer phone
  CURSOR f_customer_cont_point_tz IS
    SELECT timezone_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
      AND  primary_flag = 'Y'
      AND  owner_table_id = p_customer_id ;

  -- Cursor to derive time zone name from time zone id
  CURSOR timezone_name IS
    SELECT name
    FROM   fnd_timezones_vl
    WHERE  upgrade_tz_id = l_tz_id ;

l_task_timezone_id           NUMBER ;
l_task_timezone              VARCHAR2(50) ;

l_incident_timezone_id       NUMBER ;
l_incident_timezone          VARCHAR2(50) ;

l_technician_timezone_id     NUMBER ;
l_technician_timezone        VARCHAR2(50) ;

l_contact_timezone_id        NUMBER ;
l_contact_timezone           VARCHAR2(50) ;

l_customer_timezone_id       NUMBER ;
l_customer_timezone          VARCHAR2(50) ;

l_server_timezone_id         NUMBER ;
l_server_timezone            VARCHAR2(50) ;

l_contact_cont_point_tz_id   NUMBER ;
l_customer_cont_point_tz_id  NUMBER ;

ll_contact_cont_point_tz_id  NUMBER ;
ll_customer_cont_point_tz_id NUMBER ;

l_cont_pref_time_zone_id     NUMBER ;
ll_cont_pref_time_zone_id    NUMBER ;

BEGIN

  l_server_timezone_id      := fnd_profile.value('SERVER_TIMEZONE_ID') ;
  ll_cont_pref_time_zone_id := p_cont_pref_time_zone_id ;

  IF (p_task_id is not null) THEN

    OPEN task_address_location_type ;
    FETCH task_address_location_type into l_incident_location_id, l_incident_location_type ;
    IF (task_address_location_type%notfound) THEN
      null ;
    END IF ;
    CLOSE task_address_location_type ;

    IF(l_incident_location_id is not null AND l_incident_location_type = 'HZ_PARTY_SITE') THEN
      OPEN task_party_site_timezone ;
      FETCH task_party_site_timezone into l_task_timezone_id ;
        IF (task_party_site_timezone%notfound) THEN
          null ;
        END IF ;
      CLOSE task_party_site_timezone ;
    END IF ;

    IF(l_incident_location_id is not null AND l_incident_location_type = 'HZ_LOCATION') THEN
      OPEN task_location_timezone ;
      FETCH task_location_timezone into l_task_timezone_id ;
        IF (task_location_timezone%notfound) THEN
          null ;
        END IF ;
      CLOSE task_location_timezone ;
    END IF ;

    IF (l_task_timezone_id is not null) THEN
      l_tz_id := l_task_timezone_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_task_timezone_id ;
      RETURN ;
    END IF ;

  END IF ; -- p_task_id is not null


  IF (p_incident_id is not null) THEN

    OPEN  technician_timezone ;
    FETCH technician_timezone into l_technician_timezone_id ;
      IF (technician_timezone%notfound) THEN
        null ;
      END IF ;
    CLOSE technician_timezone ;

    IF (l_technician_timezone_id is not null) THEN
      l_tz_id := l_technician_timezone_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_technician_timezone_id ;
      RETURN ;
    END IF ;

    OPEN  contact_timezone ;
    FETCH contact_timezone into l_contact_timezone_id ;
      IF (contact_timezone%notfound) THEN
        null ;
      END IF ;
    CLOSE contact_timezone ;

    IF (l_contact_timezone_id is not null) THEN
      l_tz_id := l_contact_timezone_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_contact_timezone_id ;
      RETURN ;
    END IF ;

    OPEN  contact_cont_point_tz ;
    FETCH contact_cont_point_tz into l_contact_cont_point_tz_id ;
      IF (contact_cont_point_tz%notfound) THEN
        null ;
      END IF ;
    CLOSE contact_cont_point_tz ;

    IF (l_contact_cont_point_tz_id is not null) THEN
      l_tz_id := l_contact_cont_point_tz_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_contact_cont_point_tz_id ;
      RETURN ;
    END IF ;

    OPEN cont_pref_time_zone_id ;
    FETCH cont_pref_time_zone_id into l_cont_pref_time_zone_id ;
      IF (cont_pref_time_zone_id%notfound) THEN
        null ;
      END IF ;
    CLOSE cont_pref_time_zone_id ;

    IF (l_cont_pref_time_zone_id is not null) THEN
      l_tz_id := l_cont_pref_time_zone_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_cont_pref_time_zone_id ;
      RETURN ;
    END IF ;

    OPEN  customer_timezone ;
    FETCH customer_timezone into l_customer_timezone_id ;
      IF (customer_timezone%notfound) THEN
        null ;
      END IF ;
    CLOSE customer_timezone ;

    IF (l_customer_timezone_id is not null) THEN
      l_tz_id := l_customer_timezone_id ;
      OPEN timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_customer_timezone_id ;
      RETURN ;
    END IF ;

    OPEN  customer_cont_point_tz ;
    FETCH customer_cont_point_tz into l_customer_cont_point_tz_id ;
      IF (customer_cont_point_tz%notfound) THEN
        null ;
      END IF ;
    CLOSE customer_cont_point_tz ;

    IF (l_customer_cont_point_tz_id is not null) THEN
      l_tz_id := l_customer_cont_point_tz_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := l_customer_cont_point_tz_id ;
      RETURN ;
    END IF ;

    l_tz_id := l_server_timezone_id ;
    OPEN  timezone_name ;
    FETCH timezone_name into x_timezone_name ;
      IF (timezone_name%notfound) THEN
        null ;
      END IF ;
    CLOSE timezone_name ;
    x_timezone_id := l_server_timezone_id ;

  ELSE

    IF (p_incident_location_id is not null) THEN

      IF (p_incident_location_type = 'HZ_PARTY_SITE') THEN
        OPEN f_incident_party_site_timezone ;
        FETCH f_incident_party_site_timezone into l_incident_timezone_id ;
          IF (f_incident_party_site_timezone%notfound) THEN
            null ;
          END IF ;
        CLOSE f_incident_party_site_timezone ;
      END IF ;

      IF (p_incident_location_type = 'HZ_LOCATION') THEN
        OPEN f_incident_location_timezone ;
        FETCH f_incident_location_timezone into l_incident_timezone_id ;
          IF (f_incident_location_timezone%notfound) THEN
            null ;
          END IF ;
        CLOSE f_incident_location_timezone ;
      END IF ;

      IF (l_incident_timezone_id is not null) THEN
        l_tz_id := l_incident_timezone_id ;
        OPEN  timezone_name ;
        FETCH timezone_name into x_timezone_name ;
          IF (timezone_name%notfound) THEN
            null ;
          END IF ;
        CLOSE timezone_name ;

        x_timezone_id := l_incident_timezone_id ;
        RETURN ;
      END IF ;

    END IF ; -- p_incident_location_id is not null

    IF (p_contact_party_id is not null) THEN

      OPEN  f_contact_timezone ;
      FETCH f_contact_timezone into l_contact_timezone_id ;
        IF (f_contact_timezone%notfound) THEN
          null ;
        END IF ;
      CLOSE f_contact_timezone ;

      IF (l_contact_timezone_id is not null) THEN
        l_tz_id := l_contact_timezone_id ;
        OPEN  timezone_name ;
        FETCH timezone_name into x_timezone_name ;
          IF (timezone_name%notfound) THEN
            null ;
          END IF ;
        CLOSE timezone_name ;
        x_timezone_id := l_contact_timezone_id ;
        RETURN ;
      END IF ;

      OPEN  f_contact_cont_point_tz ;
      FETCH f_contact_cont_point_tz into ll_contact_cont_point_tz_id ;
        IF (f_contact_cont_point_tz%notfound) THEN
          null ;
        END IF ;
      CLOSE f_contact_cont_point_tz ;

      IF (ll_contact_cont_point_tz_id is not null) THEN
        l_tz_id := ll_contact_cont_point_tz_id ;
        OPEN  timezone_name ;
        FETCH timezone_name into x_timezone_name ;
          IF (timezone_name%notfound) THEN
            null ;
          END IF ;
        CLOSE timezone_name ;
        x_timezone_id := ll_contact_cont_point_tz_id ;
        RETURN ;
      END IF ;

    END IF ; -- p_contact_party_id is not null

    IF (ll_cont_pref_time_zone_id is not null) THEN
      l_tz_id := ll_cont_pref_time_zone_id ;
      OPEN  timezone_name ;
      FETCH timezone_name into x_timezone_name ;
        IF (timezone_name%notfound) THEN
          null ;
        END IF ;
      CLOSE timezone_name ;
      x_timezone_id := ll_cont_pref_time_zone_id ;
      RETURN ;
    END IF ;

    IF (p_customer_id is not null) THEN

      OPEN  f_customer_timezone ;
      FETCH f_customer_timezone into l_customer_timezone_id ;
        IF (f_customer_timezone%notfound) THEN
          null ;
        END IF ;
      CLOSE f_customer_timezone ;

      IF (l_customer_timezone_id is not null) THEN
        l_tz_id := l_customer_timezone_id ;
        OPEN  timezone_name ;
        FETCH timezone_name into x_timezone_name ;
          IF (timezone_name%notfound) THEN
            null ;
          END IF ;
        CLOSE timezone_name ;
        x_timezone_id := l_customer_timezone_id ;
        RETURN ;
      END IF ;

      OPEN  f_customer_cont_point_tz ;
      FETCH f_customer_cont_point_tz into ll_customer_cont_point_tz_id ;
        IF (f_customer_cont_point_tz%notfound) THEN
          null ;
        END IF ;
      CLOSE f_customer_cont_point_tz ;

      IF (ll_customer_cont_point_tz_id is not null) THEN
        l_tz_id := ll_customer_cont_point_tz_id ;
        OPEN  timezone_name ;
        FETCH timezone_name into x_timezone_name ;
          IF (timezone_name%notfound) THEN
            null ;
          END IF ;
        CLOSE timezone_name ;
        x_timezone_id := ll_customer_cont_point_tz_id ;
        RETURN ;
      END IF ;

    END IF ; -- p_customer_id is not null

    l_tz_id := l_server_timezone_id ;
    OPEN  timezone_name ;
    FETCH timezone_name into x_timezone_name ;
      IF (timezone_name%notfound) THEN
        null ;
      END IF ;
    CLOSE timezone_name ;
    x_timezone_id := l_server_timezone_id ;

  END IF ; -- if p_incident_id is not null

EXCEPTION
 WHEN OTHERS THEN
   NULL ;

END CUSTOMER_PREFERRED_TIME_ZONE ;


END CS_TZ_GET_DETAILS_PVT;

/
