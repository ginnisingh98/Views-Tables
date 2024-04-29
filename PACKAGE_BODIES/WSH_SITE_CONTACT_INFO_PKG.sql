--------------------------------------------------------
--  DDL for Package Body WSH_SITE_CONTACT_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SITE_CONTACT_INFO_PKG" as
/* $Header: WSHSITHB.pls 120.1 2005/10/28 02:18:06 skattama noship $ */

/*============================================================================
Procedure: CREATE_CONTACTINFO
Purpose  :  Creates Contact points for the Site Contacts
=============================================================================*/

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SITE_CONTACT_INFO_PKG';
--

PROCEDURE CREATE_CONTACTINFO
 (
    P_RELATIONSHIP_PARTY_ID     IN  NUMBER,
    P_COUNTRY_CODE              IN  VARCHAR2,
    P_AREA_CODE                 IN  VARCHAR2,
    P_PHONE_NUMBER              IN  VARCHAR2,
    P_EXTENSION                 IN  VARCHAR2,
    P_PHONE_LINE_TYPE           IN  VARCHAR2,
    X_CONTACT_POINT_ID          OUT NOCOPY  NUMBER,
    X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
    X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
    X_SQLERR                    OUT NOCOPY  VARCHAR2,
    X_SQL_CODE                  OUT NOCOPY  VARCHAR2,
    X_POSITION                  OUT NOCOPY  NUMBER,
    X_PROCEDURE                 OUT NOCOPY  VARCHAR2
  )
  IS

  ------------------------
  --  General Declarations.
  ------------------------

  l_return_status            varchar2(100);
  l_position                 number;
  l_procedure                varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_party_number             varchar2(100);
  l_profile_id               number;
  l_exception_msg            varchar2(1000);
  HZ_FAIL_EXCEPTION          exception;

  l_party_relationship_id    number;
  l_relationship_party_id    number;

  ------------------------------------------------------------------
  --  Declarations for Contact Point Creation for the above Relation.
  ------------------------------------------------------------------

  l_contact_point_id         NUMBER;
  l_contact_points_rec_type  hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec_type           hz_contact_point_v2pub.phone_rec_type;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CONTACTINFO';
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
      WSH_DEBUG_SV.log(l_module_name,'P_RELATIONSHIP_PARTY_ID',P_RELATIONSHIP_PARTY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_AREA_CODE',P_AREA_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_PHONE_NUMBER',P_PHONE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_EXTENSION',P_EXTENSION);
      WSH_DEBUG_SV.log(l_module_name,'P_PHONE_LINE_TYPE',P_PHONE_LINE_TYPE);
  END IF;
  --

  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --  Initialize Messages.

  fnd_msg_pub.initialize();


  --  Put information into phone_rec_type and contact_points.

  l_phone_rec_type.phone_number       := P_PHONE_NUMBER;
  l_phone_rec_type.phone_area_code    := P_AREA_CODE;
  l_phone_rec_type.phone_country_code := P_COUNTRY_CODE;
  l_phone_rec_type.phone_extension    := P_EXTENSION;
  l_phone_rec_type.phone_line_type    := p_phone_line_type;

  l_contact_points_rec_type.contact_point_type     := 'PHONE';
  l_contact_points_rec_type.owner_table_name       := 'HZ_PARTIES';
  l_contact_points_rec_type.owner_table_id         := p_relationship_party_id;
  --  l_contact_points_rec_type.primary_flag       := p_primary;
  --  l_contact_points_rec_type.status             := p_status;
  l_contact_points_rec_type.created_by_module      := 'ORACLE_SHIPPING';

  --  Create the contact point information.

   l_position := 10;
   l_procedure := 'Calling TCA API Create_Contact_Points';

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_CONTACT_POINT_V2PUB.CREATE_CONTACT_POINT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

    HZ_CONTACT_POINT_V2PUB.Create_Contact_Point
     (   p_init_msg_list       => FND_API.G_TRUE,
         p_contact_point_rec   => l_contact_points_rec_type,
         p_phone_rec           => l_phone_rec_type,
         x_contact_point_id    => l_contact_point_id,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
     );

     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       x_return_status := l_return_status;
       RAISE HZ_FAIL_EXCEPTION;
     END IF;

     x_contact_point_id := l_contact_point_id;

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

END CREATE_CONTACTINFO;

PROCEDURE UPDATE_CONTACTINFO(
    P_CONTACT_POINT_ID          IN  NUMBER,
    P_COUNTRY_CODE              IN  VARCHAR2,
    P_AREA_CODE                 IN  VARCHAR2,
    P_PHONE_NUMBER              IN  VARCHAR2,
    P_EXTENSION                 IN  VARCHAR2,
    P_PHONE_LINE_TYPE           IN  VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
    X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
    X_POSITION                  OUT NOCOPY  NUMBER,
    X_PROCEDURE                 OUT NOCOPY  VARCHAR2,
    X_SQLERR                    OUT NOCOPY  VARCHAR2,
    X_SQL_CODE                  OUT NOCOPY  VARCHAR2 ) IS

  l_contact_points_rec_type  hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec_type           hz_contact_point_v2pub.phone_rec_type;
  l_return_status            varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_exception_msg            varchar2(1000);
  HZ_FAIL_EXCEPTION          exception;
  l_status                   varchar2(100);
  l_contact_point_id         NUMBER;
  l_position                 number;
  l_procedure                varchar2(50);
  l_object_version_number    number;
  l_party_relationship_id    number;
  l_relationship_party_id    number;

CURSOR Get_Object_Version_Number(p_contact_point_id NUMBER) IS
  select object_version_number
  from   hz_contact_points
  where  contact_point_id = p_contact_point_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONTACTINFO';
--

BEGIN

--Initialize the status to SUCCESS.

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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_POINT_ID',P_CONTACT_POINT_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_COUNTRY_CODE',P_COUNTRY_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_AREA_CODE',P_AREA_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_PHONE_NUMBER',P_PHONE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_EXTENSION',P_EXTENSION);
      WSH_DEBUG_SV.log(l_module_name,'P_PHONE_LINE_TYPE',P_PHONE_LINE_TYPE);
  END IF;
  --

  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Initialize Messages.

  fnd_msg_pub.initialize();


--Put Information into email_rec, phone_rec.

  l_phone_rec_type.phone_number                := P_PHONE_NUMBER;
  l_phone_rec_type.phone_area_code             := nvl(P_AREA_CODE, fnd_api.g_miss_char);
  l_phone_rec_type.phone_country_code          := nvl(P_COUNTRY_CODE, fnd_api.g_miss_char);
  l_phone_rec_type.phone_extension             := nvl(P_EXTENSION, fnd_api.g_miss_char);
  l_phone_rec_type.phone_line_type             := p_phone_line_type;

  l_contact_points_rec_type.contact_point_type := 'PHONE';
  l_contact_points_rec_type.owner_table_name   := 'HZ_PARTIES';
  --  l_contact_points_rec_type.primary_flag       := p_primary;
  --  l_contact_points_rec_type.status             := p_status;
  l_contact_points_rec_type.contact_point_id   := p_contact_point_id;

--Get last_update_date for the Contact Point.

  OPEN Get_Object_Version_Number (p_contact_point_id);
  FETCH Get_Object_Version_Number INTO l_object_version_number;
  CLOSE  Get_Object_Version_Number;

--Update the contact point information.

  l_position := 10;
  l_procedure := 'Calling Update_Contact_Points';

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_CONTACT_POINT_V2PUB.UPDATE_CONTACT_POINT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

     HZ_CONTACT_POINT_V2PUB.Update_Contact_Point
      (
        p_init_msg_list           => FND_API.G_TRUE,
        p_contact_point_rec       => l_contact_points_rec_type,
        p_phone_rec               => l_phone_rec_type,
        p_object_version_number   => l_object_version_number,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data
      );

--In case of errors, set x_return_status and raise exception.

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

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --

END UPDATE_CONTACTINFO;

END WSH_SITE_CONTACT_INFO_PKG;

/
