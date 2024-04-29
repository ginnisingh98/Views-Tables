--------------------------------------------------------
--  DDL for Package Body WSH_CARRIER_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CARRIER_ADDRESS_PKG" as
/* $Header: WSHADTHB.pls 120.1 2005/10/28 01:12:24 skattama noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CARRIER_ADDRESS_PKG';
--

/*--------------------------------------------------------------
  PROCEDURE :   Create_AddressInfo
  PURPOSE   :   This procedure creates a location, party site and
                and party site use.
  ---------------------------------------------------------------*/

PROCEDURE  Create_Addressinfo (
  p_carrier_id                IN NUMBER ,
  p_status                    IN VARCHAR2 ,
  p_site_NUMBER               IN OUT NOCOPY VARCHAR2 ,
  p_address1                  IN VARCHAR2 ,
  p_address2                  IN VARCHAR2 ,
  p_address3                  IN VARCHAR2 ,
  p_address4                  IN VARCHAR2 ,
  p_city                      IN VARCHAR2 ,
  p_state                     IN VARCHAR2 ,
  p_province                  IN VARCHAR2 ,
  p_postal_code               IN VARCHAR2 ,
  p_country                   IN VARCHAR2 ,
  p_county                    IN VARCHAR2 ,
  x_location_id               IN OUT NOCOPY  NUMBER ,
  x_party_site_id             IN OUT NOCOPY  NUMBER ,
  x_return_status             OUT NOCOPY  VARCHAR2  ,
  x_exception_msg             OUT NOCOPY  VARCHAR2  ,
  x_position                  OUT NOCOPY  NUMBER    ,
  x_procedure                 OUT NOCOPY  VARCHAR2  ,
  x_sqlerr                    OUT NOCOPY  VARCHAR2  ,
  x_sql_code                  OUT NOCOPY  VARCHAR2 )  IS

   --  General Declarations.
    l_return_status            VARCHAR2(100);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_party_NUMBER             VARCHAR2(100);
    l_profile_id               NUMBER;
    l_exception_msg            VARCHAR2(1000);
    HZ_FAIL_EXCEPTION          exception;
    l_position                 NUMBER;
    l_procedure                VARCHAR2(100);

   --  Declarations for 'GENERAL_MAIL_TO' type site.
    l_address_party_site_id    NUMBER;
    l_site_use_type_id         NUMBER;
    l_site_use_rec             HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_site_rec                 HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_party_site_id            NUMBER;
    l_party_site_use_id        NUMBER;
    l_party_site_NUMBER        VARCHAR2(100);

   --  Declarations for Location Creation.
    l_loc_rec               HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_loc_id                NUMBER;

   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_ADDRESSINFO';
   --

BEGIN

   --  Initialize the status to SUCCESS.

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_SITE_NUMBER',P_SITE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS1',P_ADDRESS1);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS2',P_ADDRESS2);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS3',P_ADDRESS3);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS4',P_ADDRESS4);
      WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
      WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
      WSH_DEBUG_SV.log(l_module_name,'P_PROVINCE',P_PROVINCE);
      WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE',P_POSTAL_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
      WSH_DEBUG_SV.log(l_module_name,'P_COUNTY',P_COUNTY);
   END IF;
   --
       l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --  Initialize Messages.
       fnd_msg_pub.initialize();

   --  Put information into l_loc_rec.
       l_loc_rec.address1          := p_address1;
       l_loc_rec.address2          := p_address2;
       l_loc_rec.address3          := p_address3;
       l_loc_rec.address4          := p_address4;
       l_loc_rec.city              := substr(p_city,0,60);
       l_loc_rec.state             := p_state;
       l_loc_rec.postal_code       := p_postal_code;
       l_loc_rec.province          := substr(p_province,0,60);
       l_loc_rec.country           := substr(p_country,0,60);
       l_loc_rec.county            := substr(p_county,0,60);
       l_loc_rec.created_by_module := 'ORACLE_SHIPPING';

   --  Create Location.

      l_position := 10;
      l_procedure := 'Calling TCA API Create_Location';

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_LOCATION_V2PUB.CREATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

         HZ_LOCATION_V2PUB.Create_Location
	   (
             p_init_msg_list   => FND_API.G_TRUE,
             p_location_rec    => l_loc_rec,
             x_location_id     => l_loc_id,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data
	   );

           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
             x_return_status := l_return_status;
             RAISE HZ_FAIL_EXCEPTION;
           END IF;

   --  Get the Location ID.
       x_location_id := l_loc_id;

   ---------------------------------------------------
   --  Create the Site Information by calling the
   --  TCA API: HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE.
   ---------------------------------------------------

   --  Put information into l_site_rec.

       l_site_rec.party_id          := p_carrier_id;
       l_site_rec.location_id       := l_loc_id;
       l_site_rec.status            := p_status;
       l_site_rec.party_site_NUMBER := p_site_NUMBER;
       l_site_rec.created_by_module := 'ORACLE_SHIPPING';


   --  Create the Party Site.

       l_position := 20;
       l_procedure := 'Calling TCA API Create_Location';

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_SITE_V2PUB.Create_Party_Site',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --

          HZ_PARTY_SITE_V2PUB.Create_Party_Site
           (
               p_init_msg_list     => FND_API.G_TRUE,
               p_party_site_rec    => l_site_rec,
               x_party_site_id     => l_party_site_id,
               x_party_site_NUMBER => l_party_site_NUMBER,
               x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
               x_msg_data          => l_msg_data
           );

          p_site_number := l_party_site_NUMBER;

          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE HZ_FAIL_EXCEPTION;
          END IF;

    --  Get the Party Site ID.

        x_party_site_id := l_party_site_id;


    --------------------------------------------------------
    --  Create the Party Site Use Information by calling the
    --  TCA API: hz_party_site_v2pub.create_party_site_use.
    --------------------------------------------------------

    -- Put the information into site_rec.
       -- l_site_use_rec.begin_date        := trunc(SYSDATE);
       l_site_use_rec.site_use_type     := 'GENERAL_MAIL_TO';
       l_site_use_rec.party_site_id     := l_party_site_id;
       l_site_use_rec.created_by_module := 'ORACLE_SHIPPING';

    -- Create a Party site use.

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_SITE_V2PUB.Create_Party_Site_Use',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --

         HZ_PARTY_SITE_V2PUB.Create_Party_Site_Use
         (
           p_init_msg_list       => FND_API.G_TRUE,
           p_party_site_use_rec  => l_site_use_rec,
           x_party_site_use_id   => l_party_site_use_id,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data
         );

         IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE HZ_FAIL_EXCEPTION;
         END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

  EXCEPTION

    WHEN HZ_FAIL_EXCEPTION THEN
      x_exception_msg := l_msg_data;
      x_position      := l_position;
      x_procedure     := l_procedure;
      x_sqlerr        := sqlerrm;
      x_sql_code      := sqlcode;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'HZ_FAIL_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:HZ_FAIL_EXCEPTION');
      END IF;
      --

END CREATE_ADDRESSINFO;

/*--------------------------------------------------------------
  PROCEDURE :   Update_AddressInfo
  PURPOSE   :   This procedure updates the location information
  ---------------------------------------------------------------*/

PROCEDURE  UPDATE_ADDRESSINFO
   (
     P_CARRIER_PARTY_ID IN  NUMBER,
     P_SITE_NUMBER      IN  VARCHAR2,
     P_STATUS           IN  VARCHAR2,
     P_PARTY_SITE_ID    IN  NUMBER,
     P_LOCATION_ID      IN  NUMBER,
     P_ADDRESS1         IN  VARCHAR2,
     P_ADDRESS2         IN  VARCHAR2,
     P_ADDRESS3         IN  VARCHAR2,
     P_ADDRESS4         IN  VARCHAR2,
     P_CITY             IN  VARCHAR2,
     P_STATE            IN  VARCHAR2,
     P_PROVINCE         IN  VARCHAR2,
     P_POSTAL_CODE      IN  VARCHAR2,
     P_COUNTRY          IN  VARCHAR2,
     P_COUNTY           IN  VARCHAR2,
     X_RETURN_STATUS    OUT NOCOPY  VARCHAR2,
     X_EXCEPTION_MSG    OUT NOCOPY  VARCHAR2,
     X_POSITION         OUT NOCOPY  NUMBER,
     X_PROCEDURE        OUT NOCOPY  VARCHAR2,
     X_SQLERR           OUT NOCOPY  VARCHAR2,
     X_SQL_CODE         OUT NOCOPY  VARCHAR2
    )

is

  l_site_rec                 HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
  l_position                 NUMBER;
  l_procedure                VARCHAR2(100);
  l_loc_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
  l_return_status            VARCHAR2(100);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_party_id                 NUMBER;
  l_party_NUMBER             VARCHAR2(100);
  l_profile_id               NUMBER;
  HZ_FAIL_EXCEPTION          EXCEPTION;
  l_location_id              NUMBER;

  l_site_object_NUMBER       NUMBER;
  l_location_object_NUMBER   NUMBER;

CURSOR Get_Site_Object_Number(p_party_site_id NUMBER) IS
  select object_version_NUMBER
  from   hz_party_sites
  where  party_site_id = p_party_site_id;

CURSOR Get_Location_Object_Number(p_location_id NUMBER) IS
  select object_version_number
  from   hz_locations
  where  location_id = p_location_id;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ADDRESSINFO';
  --


BEGIN

  -- Initialize the status to SUCCESS.

   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_PARTY_ID',P_CARRIER_PARTY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_SITE_NUMBER',P_SITE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_PARTY_SITE_ID',P_PARTY_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS1',P_ADDRESS1);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS2',P_ADDRESS2);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS3',P_ADDRESS3);
      WSH_DEBUG_SV.log(l_module_name,'P_ADDRESS4',P_ADDRESS4);
      WSH_DEBUG_SV.log(l_module_name,'P_CITY',P_CITY);
      WSH_DEBUG_SV.log(l_module_name,'P_STATE',P_STATE);
      WSH_DEBUG_SV.log(l_module_name,'P_PROVINCE',P_PROVINCE);
      WSH_DEBUG_SV.log(l_module_name,'P_POSTAL_CODE',P_POSTAL_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY',P_COUNTRY);
      WSH_DEBUG_SV.log(l_module_name,'P_COUNTY',P_COUNTY);
   END IF;
   --

     l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Initialize Messages.
     fnd_msg_pub.initialize();

  -- Put Information into site_rec.
    l_site_rec.party_site_id     := p_party_site_id;
    --  l_site_rec.party_id          := p_carrier_party_id;
    --  l_site_rec.location_id       := p_location_id;
    --  l_site_rec.party_site_number := p_site_number;
    l_site_rec.status            := p_status;

  -- Get last_update_date for the Party Site.
    OPEN Get_Site_Object_Number(p_party_site_id);
    FETCH Get_Site_Object_Number INTO l_site_object_number;
    CLOSE Get_Site_Object_Number;

  -- Update the Party Site Information.

    l_position := 10;
    l_procedure := 'Calling TCA API Update_Party_site';

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_SITE_V2PUB.Update_Party_Site',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --

      HZ_PARTY_SITE_V2PUB.Update_Party_Site
       (
          p_init_msg_list         => FND_API.G_TRUE,
          p_party_site_rec        => l_site_rec,
          p_object_version_number => l_site_object_number,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data
       );

         IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE HZ_FAIL_EXCEPTION;
         END IF;

   -- Put Information into loc_rec.
     l_loc_rec.location_id         := p_location_id;
     l_loc_rec.country             := substr(p_country,0,60);
     l_loc_rec.county              := nvl(substr(p_county,0,60), fnd_api.g_miss_char);
     l_loc_rec.address1            := p_address1;
     l_loc_rec.address2            := nvl(p_address2, fnd_api.g_miss_char);
     l_loc_rec.address3            := nvl(p_address3, fnd_api.g_miss_char);
     L_loc_rec.address4            := nvl(p_address4, fnd_api.g_miss_char);
     l_loc_rec.city                := nvl(substr(p_city,0,60), fnd_api.g_miss_char);
     l_loc_rec.state               := nvl(p_state, fnd_api.g_miss_char);
     l_loc_rec.postal_code         := nvl(p_postal_code, fnd_api.g_miss_char);
     l_loc_rec.province            := nvl(substr(p_province,0,60), fnd_api.g_miss_char);

  -- Get last_update_date for the Location.

     OPEN Get_Location_Object_Number(p_location_id);
     FETCH  Get_Location_Object_Number INTO l_location_object_number;
     CLOSE Get_Location_Object_Number;

  -- Update the Location Information.
     l_position := 20;
     l_procedure := 'Calling TCA API Update_Location';

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_LOCATION_V2PUB.Update_Location',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

         HZ_LOCATION_V2PUB.Update_Location
          (
            p_init_msg_list          => FND_API.G_TRUE,
            p_location_rec           => l_loc_rec,
            p_object_version_number  => l_location_object_number,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data
          );


          IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE HZ_FAIL_EXCEPTION;
          END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
WHEN NO_DATA_FOUND THEN
      x_exception_msg := 'EXCEPTION : No Data Found';
      x_position := l_position;
      x_procedure := l_procedure;
      x_sqlerr    := sqlerrm;
      x_sql_code   := sqlcode;
      x_return_status := 'E';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
      END IF;
      --


WHEN HZ_FAIL_EXCEPTION THEN
      x_exception_msg := l_msg_data;
      x_position := l_position;
      x_procedure := l_procedure;
      x_sqlerr    := sqlerrm;
      x_sql_code   := sqlcode;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'HZ_FAIL_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:HZ_FAIL_EXCEPTION');
      END IF;
      --

WHEN OTHERS THEN
      x_exception_msg := 'EXCEPTION : Others';
      x_position := l_position;
      x_procedure := l_procedure;
      x_sqlerr    := sqlerrm;
      x_sql_code   := sqlcode;
      x_return_status := 'E';

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

END UPDATE_ADDRESSINFO;

/*--------------------------------------------------------------
  PROCEDURE :   Concatenate_Address
  PURPOSE   :   This procedure concatenates the various address
                components.
  ---------------------------------------------------------------*/

FUNCTION Concatenate_Address(
    p_address1     IN VARCHAR2,
    p_address2     IN VARCHAR2,
    p_address3     IN VARCHAR2,
    p_address4     IN VARCHAR2,
    p_city         IN VARCHAR2,
    p_postal_code  IN VARCHAR2,
    p_state        IN VARCHAR2,
    p_province     IN VARCHAR2,
    p_country      IN VARCHAR2,
    p_county       IN VARCHAR2 ) return VARCHAR2 IS

l_address   VARCHAR2(1500);

BEGIN

   --
   l_address := p_address1;

   IF ( p_address2 IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_address2;
   END IF;

   IF ( p_address3 IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_address3;
   END IF;

   IF ( p_address4 IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_address4;
   END IF;

   IF ( p_city IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_city;
   END IF;

   IF ( p_county IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_county;
   END IF;

   IF ( p_state IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_state;
   END IF;

   IF ( p_province IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_province;
   END IF;

   IF ( p_postal_code IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_postal_code;
   END IF;

   IF ( p_country IS NOT NULL ) THEN
      l_address := l_address || ', ' || p_country;
   END IF;

   RETURN( l_address );

END;

END WSH_CARRIER_ADDRESS_PKG;

/
