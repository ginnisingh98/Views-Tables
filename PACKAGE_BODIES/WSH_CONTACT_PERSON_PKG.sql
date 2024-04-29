--------------------------------------------------------
--  DDL for Package Body WSH_CONTACT_PERSON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONTACT_PERSON_PKG" as
/* $Header: WSHCPTHB.pls 120.1.12010000.2 2008/09/18 08:54:11 sankarun ship $ */

/*============================================================================
Procedure: CREATE_CONTACTPERSON
Purpose  : Creates another party for the contact person.
=============================================================================*/

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CONTACT_PERSON_PKG';
--

PROCEDURE CREATE_CONTACTPERSON(
  P_CARRIER_PARTY_ID          IN  NUMBER,
  P_STATUS                    IN  VARCHAR2,
  P_PERSON_NAME_PRE_ADJUNCT   IN  VARCHAR2,
  P_PERSON_FIRST_NAME         IN  VARCHAR2 ,
  P_PERSON_LAST_NAME          IN  VARCHAR2 ,
  X_RELATIONSHIP_PARTY_ID     OUT NOCOPY  NUMBER,
  X_PERSON_PARTY_ID           OUT NOCOPY  NUMBER,
  X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
  X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
  X_POSITION                  OUT NOCOPY  NUMBER,
  X_PROCEDURE                 OUT NOCOPY  VARCHAR2,
  X_SQLERR                    OUT NOCOPY  VARCHAR2,
  X_SQL_CODE                  OUT NOCOPY  VARCHAR2
  )
  IS

  -------------------------
  --  General Declarations.
  -------------------------

  l_return_status            varchar2(100);
  l_msg_count                number;
  l_position                 number;
  l_call_procedure           varchar2(100);
  l_msg_data                 varchar2(2000);
  l_party_number             varchar2(100);
  l_profile_id               number;
  l_relationship_id          number;
  l_exception_msg            varchar2(1000);
  HZ_FAIL_EXCEPTION          exception;
  l_party_relationship_id    number;
  l_relationship_party_id    number;

  ---------------------------------------------
  --  Declarations for Party 'PERSON' Creation.
  ---------------------------------------------

  l_per_rec                  HZ_PARTY_V2PUB.person_rec_type;
  l_person_party_id          number;

  l_rel_rec_type             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

 -- Bug 7391414 variables to hold profile option value 'HZ GENERATE PARTY NUMBER'
  l_hz_profile_option        varchar2(2);
  l_hz_profile_set           boolean;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CONTACTPERSON';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_PARTY_ID',P_CARRIER_PARTY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_NAME_PRE_ADJUNCT',P_PERSON_NAME_PRE_ADJUNCT);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_FIRST_NAME',P_PERSON_FIRST_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_LAST_NAME',P_PERSON_LAST_NAME);
  END IF;
  --

       l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --  Initialize Messages.
       fnd_msg_pub.initialize();


  --  Put Information into per_rec.

      l_per_rec.person_pre_name_adjunct := P_PERSON_NAME_PRE_ADJUNCT;
      l_per_rec.person_first_name       := P_PERSON_FIRST_NAME;
      l_per_rec.person_last_name        := P_PERSON_LAST_NAME;
      l_per_rec.created_by_module := 'ORACLE_SHIPPING';
      l_per_rec.party_rec.status := p_status;

      l_position := 10;
      l_call_procedure := 'Calling TCA API Create_Person';

  -- Set the Autogenerate Party Number to 'Yes'.
  -- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER' to Yes if it is No or Null
    l_hz_profile_set := false;
    l_hz_profile_option := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');

    IF (l_hz_profile_option = 'N' or l_hz_profile_option is null ) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Setting profile option HZ_GENERATE_PARTY_NUMBER to Yes');
        END IF;
        fnd_profile.put('HZ_GENERATE_PARTY_NUMBER','Y');
        l_hz_profile_set := true;
    END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_V2PUB.CREATE_PERSON',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

         HZ_PARTY_V2PUB.Create_Person
          (
            p_init_msg_list  => FND_API.G_TRUE,
            p_person_rec     => l_per_rec,
            x_party_id       => l_person_party_id,
            x_party_number   => l_party_number,
            x_profile_id     => l_profile_id,
            x_return_status  => l_return_status,
            x_msg_count      => l_msg_count,
            x_msg_data       => l_msg_data
          );

       -- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER'  to previous value
	IF l_hz_profile_set THEN
	     IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Reverting the value of profile option HZ_GENERATE_PARTY_NUMBER');
	     END IF;
             fnd_profile.put('HZ_GENERATE_PARTY_NUMBER',l_hz_profile_option);
	END IF;

         IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE HZ_FAIL_EXCEPTION;
         END IF;

         x_person_party_id := l_person_party_id;


  --  Put Information into party_rel_rec.
      l_rel_rec_type.relationship_type       := 'EMPLOYMENT';
      l_rel_rec_type.relationship_code       := 'EMPLOYEE_OF';
      l_rel_rec_type.subject_id              := l_person_party_id;
      l_rel_rec_type.subject_table_name      := 'HZ_PARTIES';
      l_rel_rec_type.subject_type            := 'PERSON';
      l_rel_rec_type.object_id               := p_carrier_party_id;
      l_rel_rec_type.object_table_name       := 'HZ_PARTIES';
      l_rel_rec_type.object_type             := 'ORGANIZATION';
      l_rel_rec_type.start_date              := sysdate;
      l_rel_rec_type.created_by_module       := 'ORACLE_SHIPPING';
      l_rel_rec_type.party_rec.status        := P_STATUS;


  --  Create relationship between contact person and organization.

      l_position := 20;
      l_call_procedure := 'Calling TCA API Create_Relationship';

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_RELATIONSHIP_V2PUB.CREATE_RELATIONSHIP',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

        HZ_RELATIONSHIP_V2PUB.Create_Relationship
        (
          p_init_msg_list     => FND_API.G_TRUE,
          p_relationship_rec  => l_rel_rec_type,
          x_relationship_id   => l_relationship_id,
          x_party_id          => l_relationship_party_id,
          x_party_number      => l_party_number,
          x_return_status     => l_return_status,
          x_msg_count         => l_msg_count,
          x_msg_data          => l_msg_data
        );

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE HZ_FAIL_EXCEPTION;
        END IF;

       x_relationship_party_id := l_relationship_party_id;
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
      x_procedure     := l_call_procedure;
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

END CREATE_CONTACTPERSON;


PROCEDURE UPDATE_CONTACTPERSON (
   P_CARRIER_PARTY_ID            IN     NUMBER,
   P_PERSON_PARTY_ID IN          OUT NOCOPY     NUMBER,
   P_PERSON_NAME_PRE_ADJUNCT     IN     VARCHAR2,
   P_PERSON_FIRST_NAME           IN     VARCHAR2,
   P_PERSON_LAST_NAME            IN     VARCHAR2,
   P_STATUS                      IN     VARCHAR2,
   P_CONTACT_POINT_ID            IN OUT NOCOPY  NUMBER,
   X_RETURN_STATUS                  OUT NOCOPY  VARCHAR2,
   X_EXCEPTION_MSG                  OUT NOCOPY  VARCHAR2,
   X_POSITION                       OUT NOCOPY  NUMBER,
   X_PROCEDURE                      OUT NOCOPY  VARCHAR2,
   X_SQLERR                         OUT NOCOPY  VARCHAR2,
   X_SQL_CODE                       OUT NOCOPY  VARCHAR2) IS

  l_person_rec               HZ_PARTY_V2PUB.person_rec_type;
  l_return_status            varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_profile_id               number;
  l_object_version_number    number;
  HZ_FAIL_EXCEPTION          exception;
  l_position                 number;
  l_call_procedure           varchar2(100);

CURSOR Get_Object_Version_Number(p_person_party_id NUMBER) IS
  select object_version_number
  from   hz_parties
  where  party_id = p_person_party_id;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONTACTPERSON';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_PARTY_ID',P_CARRIER_PARTY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_PARTY_ID',P_PERSON_PARTY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_POINT_ID',P_CONTACT_POINT_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_NAME_PRE_ADJUNCT',P_PERSON_NAME_PRE_ADJUNCT);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_FIRST_NAME',P_PERSON_FIRST_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_PERSON_LAST_NAME',P_PERSON_LAST_NAME);
  END IF;
  --

  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Initialize Messages.

  fnd_msg_pub.initialize();

--Put Information into person_rec.

  l_person_rec.person_pre_name_adjunct     := nvl(p_person_name_pre_adjunct, fnd_api.g_miss_char);
  l_person_rec.person_first_name           := nvl(p_person_first_name, fnd_api.g_miss_char);
  l_person_rec.person_last_name            := p_person_last_name;
  l_person_rec.party_rec.party_id          := p_person_party_id;
  l_person_rec.party_rec.status            := p_status;

--Get Object_Version_Number for the Person.

  OPEN Get_Object_Version_Number(p_person_party_id);
  FETCH Get_Object_Version_Number INTO l_object_version_number;
  CLOSE Get_Object_Version_Number ;

--Update the Person information.

  l_position := 10;
  l_call_procedure := 'Calling TCA API Update_Person';

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_V2PUB.UPDATE_PERSON',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

      HZ_PARTY_V2PUB.Update_Person
       (
          p_init_msg_list                => FND_API.G_TRUE,
          p_person_rec                   => l_person_rec,
          p_party_object_version_number  => l_object_version_number,
          x_profile_id                   => l_profile_id,
          x_return_status                => l_return_status,
          x_msg_count                    => l_msg_count,
          x_msg_data                     => l_msg_data
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
      x_procedure := l_call_procedure;
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
      x_procedure := l_call_procedure;
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
      x_procedure := l_call_procedure;
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

END UPDATE_CONTACTPERSON;

END WSH_CONTACT_PERSON_PKG;

/
