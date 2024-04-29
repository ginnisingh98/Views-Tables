--------------------------------------------------------
--  DDL for Package Body WSH_CREATE_CARRIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CREATE_CARRIERS_PKG" as
/* $Header: WSHCATHB.pls 120.10.12010000.2 2008/09/18 08:52:39 sankarun ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CREATE_CARRIERS_PKG';
--

PROCEDURE CREATE_CARRIERINFO (
  P_Carrier_info              IN  CARecType,
  P_COMMIT                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  X_ROWID                     OUT NOCOPY  VARCHAR2,
  X_CARRIER_PARTY_ID          OUT NOCOPY  NUMBER,
  X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
  X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
  X_POSITION                  OUT NOCOPY  NUMBER,
  X_PROCEDURE                 OUT NOCOPY  VARCHAR2,
  X_SQLERR                    OUT NOCOPY  VARCHAR2,
  X_SQL_CODE                  OUT NOCOPY  VARCHAR2 ) IS

   --  General Declarations.
     l_return_status            varchar2(100);
     l_msg_count                number;
     l_msg_data                 varchar2(2000);
     l_party_number             varchar2(100);
     l_profile_id               number;
     l_code_assignment_id       number;
     l_exception_msg            varchar2(1000);
     HZ_FAIL_EXCEPTION          exception;
     insert_failed              exception;
     OTHERS                     exception;
     l_position                 number;
     l_call_procedure           varchar2(100);
   -- Bug 7391414 variables to hold profile option value 'HZ GENERATE PARTY NUMBER'
     l_hz_profile_option        varchar2(2);
     l_hz_profile_set           boolean;

   --  Declarations for Party 'ORGANIZATION' Creation.
     l_org_rec                  HZ_PARTY_V2PUB.organization_rec_type;
     l_carrier_party_id         number;

   --  Declaration for Code Assignment.
     l_code_assignment_rec_type HZ_CLASSIFICATION_V2PUB.Code_Assignment_Rec_Type;

    -- Party Usage
     l_party_usg_assignment_rec HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
     l_party_usg_end_date DATE;

     l_sql_code       number;
     l_sqlcode        number;
     l_sqlerr         varchar2(2000);

   CURSOR Get_Rowid(p_carrier_id NUMBER) IS
     SELECT rowid
     FROM   wsh_carriers
     WHERE  carrier_id = p_carrier_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CARRIERINFO';
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
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CARRIER_NAME',P_Carrier_info.CARRIER_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_CODE',P_Carrier_info.FREIGHT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.STATUS',P_Carrier_info.STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SCAC_CODE',P_Carrier_info.SCAC_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MANIFESTING_ENABLED',P_Carrier_info.MANIFESTING_ENABLED);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CURRENCY_CODE',P_Carrier_info.CURRENCY_CODE);
      -- Pack J
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_NUM_STOPS_PERMITTED',P_Carrier_info.MAX_NUM_STOPS_PERMITTED);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_DISTANCE',P_Carrier_info.MAX_TOTAL_DISTANCE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_TIME',P_Carrier_info.MAX_TOTAL_TIME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ALLOW_INTERSPERSE_LOAD',P_Carrier_info.ALLOW_INTERSPERSE_LOAD);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_LAYOVER_TIME',P_Carrier_info.MAX_LAYOVER_TIME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_LAYOVER_TIME',P_Carrier_info.MIN_LAYOVER_TIME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR',P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_DRIVING_TIME_IN_24HR',P_Carrier_info.MAX_DRIVING_TIME_IN_24HR);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_DUTY_TIME_IN_24HR',P_Carrier_info.MAX_DUTY_TIME_IN_24HR);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DISTANCE',P_Carrier_info.MAX_CM_DISTANCE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_TIME',P_Carrier_info.MAX_CM_TIME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DH_DISTANCE',P_Carrier_info.MAX_CM_DH_DISTANCE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_WIDTH',P_Carrier_info.MAX_SIZE_WIDTH);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_HEIGHT',P_Carrier_info.MAX_SIZE_HEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_LENGTH',P_Carrier_info.MAX_SIZE_LENGTH);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_WIDTH',P_Carrier_info.MIN_SIZE_WIDTH);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_HEIGHT',P_Carrier_info.MIN_SIZE_HEIGHT);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_LENGTH',P_Carrier_info.MIN_SIZE_LENGTH);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.TIME_UOM',P_Carrier_info.TIME_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIMENSION_UOM',P_Carrier_info.DIMENSION_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DISTANCE_UOM',P_Carrier_info.DISTANCE_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_OUT_OF_ROUTE',P_Carrier_info.MAX_OUT_OF_ROUTE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_FREE_DH_MILEAGE',P_Carrier_info.CM_FREE_DH_MILEAGE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_CM_DISTANCE',P_Carrier_info.MIN_CM_DISTANCE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_FIRST_LOAD_DISCOUNT',P_Carrier_info.CM_FIRST_LOAD_DISCOUNT);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_CM_TIME',P_Carrier_info.MIN_CM_TIME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.UNIT_RATE_BASIS',P_Carrier_info.UNIT_RATE_BASIS);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.WEIGHT_UOM',P_Carrier_info.WEIGHT_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.VOLUME_UOM',P_Carrier_info.VOLUME_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.GENERIC_FLAG',P_Carrier_info.GENERIC_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL',P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL',P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SUPPLIER_ID',P_Carrier_info.SUPPLIER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SUPPLIER_SITE_ID',P_Carrier_info.SUPPLIER_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_RATE_VARIANT',P_Carrier_info.CM_RATE_VARIANT);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DISTANCE_CALCULATION_METHOD',P_Carrier_info.DISTANCE_CALCULATION_METHOD);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ALLOW_CONTINUOUS_MOVE',P_Carrier_info.ALLOW_CONTINUOUS_MOVE);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DH_TIME',P_Carrier_info.MAX_CM_DH_TIME);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL',P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL);
      -- R12 Code changes
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_DIMENSIONAL_FACTOR',P_Carrier_info.DIM_DIMENSIONAL_FACTOR);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_WEIGHT_UOM',P_Carrier_info.DIM_WEIGHT_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_VOLUME_UOM',P_Carrier_info.DIM_VOLUME_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_DIMENSION_UOM',P_Carrier_info.DIM_DIMENSION_UOM);
      WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_MIN_PACK_VOL',P_Carrier_info.DIM_MIN_PACK_VOL);
      -- R12 Code changes
  END IF;
  --

     l_return_status := 'S';

  -- Initialize Messages.
     fnd_msg_pub.initialize();

  -- Put Information into Org_rec.

      l_org_rec.organization_name := P_Carrier_info.CARRIER_NAME;
      l_org_rec.created_by_module := 'ORACLE_SHIPPING';
     -- l_org_rec.party_rec.status  := P_Carrier_info.STATUS;
       l_org_rec.party_rec.status  := 'A';

  -- Set the Autogenerate Party Number to 'Yes'.
  -- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER' to Yes if it is No or Null
    l_hz_profile_set := false;
    l_hz_profile_option := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');

    IF (l_hz_profile_option = 'N' or l_hz_profile_option is null ) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Setting profile option  HZ_GENERATE_PARTY_NUMBER to Yes');
        END IF;
        fnd_profile.put('HZ_GENERATE_PARTY_NUMBER','Y');
        l_hz_profile_set := true;
    END IF;


  -- Create Carrier Organization.

      l_position := 10;
      l_call_procedure := 'Calling TCA API Create_Organization';

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_PUB.CREATE_ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

          HZ_PARTY_V2PUB.Create_Organization
           (
             p_init_msg_list     => FND_API.G_TRUE,
             p_organization_rec  => l_org_rec,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data,
             x_party_id          => l_carrier_party_id,
             x_party_number      => l_party_number,
             x_profile_id        => l_profile_id
           );

  -- Bug 7391414 Setting the profile option 'HZ GENERATE PARTY NUMBER'  to previous value
	IF l_hz_profile_set THEN
	    IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Reverting the value of profile option HZ_GENERATE_PARTY_NUMBER');
	     END IF;
	    fnd_profile.put('HZ_GENERATE_PARTY_NUMBER',l_hz_profile_option);
	END IF;

          IF (l_return_status <> 'S') THEN
             x_return_status := l_return_status;
             RAISE HZ_FAIL_EXCEPTION;
          END IF;

     x_carrier_party_id := l_carrier_party_id;

     -- Party Usage
     IF (P_Carrier_info.STATUS = 'A') THEN
      l_party_usg_end_date  := null;

     ELSE
      l_party_usg_end_date  := sysdate;
     END IF;

     l_party_usg_assignment_rec.party_id := l_carrier_party_id;
     l_party_usg_assignment_rec.party_usage_code := 'TRANSPORTATION_PROVIDER';
     l_party_usg_assignment_rec.effective_start_date := sysdate;
     l_party_usg_assignment_rec.effective_end_date := l_party_usg_end_date;
     l_party_usg_assignment_rec.created_by_module := 'WSH';
     l_position := 20;
     l_call_procedure := 'Calling assign_party_usage ';

     HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
      p_init_msg_list            => FND_API.G_TRUE,
      p_validation_level => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_LOW,
      p_party_usg_assignment_rec => l_party_usg_assignment_rec,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);
      IF (l_return_status <> 'S') THEN
        x_return_status := l_return_status;
        RAISE HZ_FAIL_EXCEPTION;
      END IF;

      -- End Party Usage

     l_position := 30;
     l_call_procedure := 'Inserting into WSH_CARRIERS table';

         INSERT INTO WSH_CARRIERS
         (
            CARRIER_ID,
            --Bug2313801      NAME,
            FREIGHT_CODE,
            SCAC_CODE,
            MANIFESTING_ENABLED_FLAG,
            CURRENCY_CODE,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            -- Pack J
            MAX_NUM_STOPS_PERMITTED,
            MAX_TOTAL_DISTANCE,
            MAX_TOTAL_TIME,
            ALLOW_INTERSPERSE_LOAD,
            MAX_LAYOVER_TIME,
            MIN_LAYOVER_TIME,
            MAX_TOTAL_DISTANCE_IN_24HR,
            MAX_DRIVING_TIME_IN_24HR,
            MAX_DUTY_TIME_IN_24HR,
            MAX_CM_DISTANCE,
            MAX_CM_TIME,
            MAX_CM_DH_DISTANCE,
            MAX_SIZE_WIDTH,
            MAX_SIZE_HEIGHT,
            MAX_SIZE_LENGTH,
            MIN_SIZE_WIDTH,
            MIN_SIZE_HEIGHT,
            MIN_SIZE_LENGTH,
            TIME_UOM,
            DIMENSION_UOM,
            DISTANCE_UOM,
            MAX_OUT_OF_ROUTE,
            CM_FREE_DH_MILEAGE,
            MIN_CM_DISTANCE,
            CM_FIRST_LOAD_DISCOUNT,
            MIN_CM_TIME,
            UNIT_RATE_BASIS,
            WEIGHT_UOM,
            VOLUME_UOM,
            GENERIC_FLAG,
            FREIGHT_BILL_AUTO_APPROVAL,
            FREIGHT_AUDIT_LINE_LEVEL,
            SUPPLIER_ID,
            SUPPLIER_SITE_ID,
            CM_RATE_VARIANT,
            DISTANCE_CALCULATION_METHOD,
            ALLOW_CONTINUOUS_MOVE,
            MAX_CM_DH_TIME,
            ORIGIN_DSTN_SURCHARGE_LEVEL)
         VALUES (
            l_carrier_party_id,
            --Bug2313801  p_carrier_name,
            P_Carrier_info.FREIGHT_CODE,
            P_Carrier_info.SCAC_CODE,
            P_Carrier_info.MANIFESTING_ENABLED,
            P_Carrier_info.CURRENCY_CODE,
            P_Carrier_info.Attribute_Category,
            P_Carrier_info.Attribute1,
            P_Carrier_info.Attribute2,
            P_Carrier_info.Attribute3,
            P_Carrier_info.Attribute4,
            P_Carrier_info.Attribute5,
            P_Carrier_info.Attribute6,
            P_Carrier_info.Attribute7,
            P_Carrier_info.Attribute8,
            P_Carrier_info.Attribute9,
            P_Carrier_info.Attribute10,
            P_Carrier_info.Attribute11,
            P_Carrier_info.Attribute12,
            P_Carrier_info.Attribute13,
            P_Carrier_info.Attribute14,
            P_Carrier_info.Attribute15,
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID,
            -- Pack J
            P_Carrier_info.MAX_NUM_STOPS_PERMITTED,
            P_Carrier_info.MAX_TOTAL_DISTANCE,
            P_Carrier_info.MAX_TOTAL_TIME,
            P_Carrier_info.ALLOW_INTERSPERSE_LOAD,
            P_Carrier_info.MAX_LAYOVER_TIME,
            P_Carrier_info.MIN_LAYOVER_TIME,
            P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR,
            P_Carrier_info.MAX_DRIVING_TIME_IN_24HR,
            P_Carrier_info.MAX_DUTY_TIME_IN_24HR,
            P_Carrier_info.MAX_CM_DISTANCE,
            P_Carrier_info.MAX_CM_TIME,
            P_Carrier_info.MAX_CM_DH_DISTANCE,
            P_Carrier_info.MAX_SIZE_WIDTH,
            P_Carrier_info.MAX_SIZE_HEIGHT,
            P_Carrier_info.MAX_SIZE_LENGTH,
            P_Carrier_info.MIN_SIZE_WIDTH,
            P_Carrier_info.MIN_SIZE_HEIGHT,
            P_Carrier_info.MIN_SIZE_LENGTH,
            P_Carrier_info.TIME_UOM,
            P_Carrier_info.DIMENSION_UOM,
            P_Carrier_info.DISTANCE_UOM,
            P_Carrier_info.MAX_OUT_OF_ROUTE,
            P_Carrier_info.CM_FREE_DH_MILEAGE,
            P_Carrier_info.MIN_CM_DISTANCE,
            P_Carrier_info.CM_FIRST_LOAD_DISCOUNT,
            P_Carrier_info.MIN_CM_TIME,
            P_Carrier_info.UNIT_RATE_BASIS,
            P_Carrier_info.WEIGHT_UOM,
            P_Carrier_info.VOLUME_UOM,
            P_Carrier_info.GENERIC_FLAG,
            P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL,
            P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL,
            P_Carrier_info.SUPPLIER_ID,
            P_Carrier_info.SUPPLIER_SITE_ID,
            P_Carrier_info.CM_RATE_VARIANT,
            P_Carrier_info.DISTANCE_CALCULATION_METHOD,
            P_Carrier_info.ALLOW_CONTINUOUS_MOVE,
            P_Carrier_info.MAX_CM_DH_TIME,
            P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL);

      OPEN Get_rowid(l_carrier_party_id);
      FETCH Get_Rowid INTO x_rowid;

         IF Get_Rowid%NOTFOUND THEN
           l_return_status := 'E';
           x_return_status := l_return_status;
           RAISE Insert_Failed;
         END IF;

      CLOSE Get_Rowid;

      x_return_status := l_return_status;

IF FND_API.To_Boolean(p_commit) THEN
  COMMIT;
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
       x_exception_msg := 'NO_DATA_FOUND Exception Raised';
       x_position := l_position;
       x_procedure := l_call_procedure;
       x_sqlerr := sqlerrm;
       x_sql_code := sqlcode;
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
       x_procedure := l_call_procedure;
       x_sqlerr := sqlerrm;
       x_sql_code := sqlcode;

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'HZ_FAIL_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:HZ_FAIL_EXCEPTION');
       END IF;
       --

   WHEN INSERT_FAILED THEN
        x_exception_msg := 'Insert Failed Exception';
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'INSERT_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INSERT_FAILED');
        END IF;
        --

   WHEN OTHERS THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      x_return_status := 'E';
      x_exception_msg := 'WHEN OTHERS Exception Raise';
      x_position := l_position;
      x_procedure := l_call_procedure;
      x_sqlerr := sqlerrm;
      x_sql_code := sqlcode;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

END CREATE_CARRIERINFO;


PROCEDURE UPDATE_CARRIERINFO
  (
      P_Carrier_info              IN  CARecType,
      p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      x_return_status             OUT NOCOPY  VARCHAR2,
      x_exception_msg             OUT NOCOPY  VARCHAR2,
      x_procedure                 OUT NOCOPY  VARCHAR2,
      x_position                  OUT NOCOPY  NUMBER,
      x_sqlerr                    OUT NOCOPY  VARCHAR2,
      x_sql_code                  OUT NOCOPY  VARCHAR2 ) IS

  l_org_rec                  hz_party_v2pub.organization_rec_type;
  l_return_status            varchar2(100);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);
  l_party_id                 number;
  l_party_number             varchar2(100);
  l_profile_id               number;
  l_exception_msg            varchar2(1000);
  HZ_FAIL_EXCEPTION          exception;
  OTHERS                     exception;
  l_status                   varchar2(100);
  l_object_version_number    number;
  l_position                 number;
  l_call_procedure           varchar2(100);

  CURSOR Get_Object_Version_Number(l_carrier_party_id NUMBER) IS
    SELECT object_version_number
    FROM   hz_parties
    WHERE  party_id = l_carrier_party_id;
-- Party Usage
  CURSOR Get_Carrier_Status(l_carrier_party_id NUMBER) IS
    SELECT active, party_usg_assignment_id
    FROM wsh_carriers_v
    WHERE carrier_id = l_carrier_party_id;

    l_party_usg_assignment_rec HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_party_usg_assignment_id NUMBER;
-- Party Usage

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CARRIERINFO';
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
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CARRIER_ID',P_Carrier_info.CARRIER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_CODE',P_Carrier_info.FREIGHT_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CARRIER_NAME',P_Carrier_info.CARRIER_NAME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.STATUS',P_Carrier_info.STATUS);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SCAC_CODE',P_Carrier_info.SCAC_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MANIFESTING_ENABLED',P_Carrier_info.MANIFESTING_ENABLED);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CURRENCY_CODE',P_Carrier_info.CURRENCY_CODE);
          -- Pack J
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_NUM_STOPS_PERMITTED',P_Carrier_info.MAX_NUM_STOPS_PERMITTED);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_DISTANCE',P_Carrier_info.MAX_TOTAL_DISTANCE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_TIME',P_Carrier_info.MAX_TOTAL_TIME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ALLOW_INTERSPERSE_LOAD',P_Carrier_info.ALLOW_INTERSPERSE_LOAD);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_LAYOVER_TIME',P_Carrier_info.MAX_LAYOVER_TIME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_LAYOVER_TIME',P_Carrier_info.MIN_LAYOVER_TIME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR',P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_DRIVING_TIME_IN_24HR',P_Carrier_info.MAX_DRIVING_TIME_IN_24HR);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_DUTY_TIME_IN_24HR',P_Carrier_info.MAX_DUTY_TIME_IN_24HR);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DISTANCE',P_Carrier_info.MAX_CM_DISTANCE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_TIME',P_Carrier_info.MAX_CM_TIME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DH_DISTANCE',P_Carrier_info.MAX_CM_DH_DISTANCE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_WIDTH',P_Carrier_info.MAX_SIZE_WIDTH);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_HEIGHT',P_Carrier_info.MAX_SIZE_HEIGHT);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_LENGTH',P_Carrier_info.MAX_SIZE_LENGTH);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_WIDTH',P_Carrier_info.MIN_SIZE_WIDTH);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_HEIGHT',P_Carrier_info.MIN_SIZE_HEIGHT);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_LENGTH',P_Carrier_info.MIN_SIZE_LENGTH);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.TIME_UOM',P_Carrier_info.TIME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIMENSION_UOM',P_Carrier_info.DIMENSION_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DISTANCE_UOM',P_Carrier_info.DISTANCE_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_OUT_OF_ROUTE',P_Carrier_info.MAX_OUT_OF_ROUTE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_FREE_DH_MILEAGE',P_Carrier_info.CM_FREE_DH_MILEAGE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_CM_DISTANCE',P_Carrier_info.MIN_CM_DISTANCE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_FIRST_LOAD_DISCOUNT',P_Carrier_info.CM_FIRST_LOAD_DISCOUNT);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_CM_TIME',P_Carrier_info.MIN_CM_TIME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.UNIT_RATE_BASIS',P_Carrier_info.UNIT_RATE_BASIS);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.WEIGHT_UOM',P_Carrier_info.WEIGHT_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.VOLUME_UOM',P_Carrier_info.VOLUME_UOM);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.GENERIC_FLAG',P_Carrier_info.GENERIC_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL',P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL',P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SUPPLIER_ID',P_Carrier_info.SUPPLIER_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SUPPLIER_SITE_ID',P_Carrier_info.SUPPLIER_SITE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_RATE_VARIANT',P_Carrier_info.CM_RATE_VARIANT);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DISTANCE_CALCULATION_METHOD',P_Carrier_info.DISTANCE_CALCULATION_METHOD);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ALLOW_CONTINUOUS_MOVE',P_Carrier_info.ALLOW_CONTINUOUS_MOVE);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DH_TIME',P_Carrier_info.MAX_CM_DH_TIME);
          WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL',P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL);
	  -- R12 Code changes
	  WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_DIMENSIONAL_FACTOR',P_Carrier_info.DIM_DIMENSIONAL_FACTOR);
	  WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_WEIGHT_UOM',P_Carrier_info.DIM_WEIGHT_UOM);
	  WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_VOLUME_UOM',P_Carrier_info.DIM_VOLUME_UOM);
	  WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_DIMENSION_UOM',P_Carrier_info.DIM_DIMENSION_UOM);
	  WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_MIN_PACK_VOL',P_Carrier_info.DIM_MIN_PACK_VOL);
	  -- R12 Code changes
      END IF;
      --
      l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      x_return_status := l_return_status;
   -- Initialize Messages.
      fnd_msg_pub.initialize();

   -- Put Information into Org_rec.

      l_org_rec.organization_name   := P_Carrier_info.CARRIER_NAME;
      l_org_rec.party_rec.party_id  := P_Carrier_info.CARRIER_ID;
      --l_org_rec.party_rec.status    := P_Carrier_info.STATUS;

   -- Get last_update_date for the Carrier.

      OPEN Get_Object_Version_Number(P_Carrier_info.CARRIER_ID);
      FETCH Get_Object_Version_Number INTO l_object_version_number;
      CLOSE Get_Object_Version_Number;

   -- Update the Organization information i.e. the Carrier Name.

      l_position := 10;
      l_call_procedure := 'Calling TCA API Update_Organization';

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit HZ_PARTY_PUB.UPDATE_ORGANIZATION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

          HZ_PARTY_V2PUB.Update_Organization
           (
             p_init_msg_list                => FND_API.G_TRUE,
             p_organization_rec             => l_org_rec,
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
          -- Party Usage
      OPEN get_carrier_status(P_Carrier_info.CARRIER_ID);
      FETCH get_carrier_status INTO l_status,l_party_usg_assignment_id;
      CLOSE get_carrier_status;

      IF(l_status <> P_Carrier_info.STATUS) THEN
        l_position := 20;
        l_call_procedure := 'Updating party usage status';
        IF(P_Carrier_info.STATUS = 'A') THEN

          l_party_usg_assignment_rec.party_id := P_Carrier_info.CARRIER_ID;
          l_party_usg_assignment_rec.party_usage_code := 'TRANSPORTATION_PROVIDER';
          l_party_usg_assignment_rec.effective_start_date := sysdate;
          l_party_usg_assignment_rec.effective_end_date := null;
          l_party_usg_assignment_rec.created_by_module := 'WSH';

          HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
          	p_init_msg_list => FND_API.G_TRUE,
          	p_party_usg_assignment_rec => l_party_usg_assignment_rec,
          	x_return_status => l_return_status,
          	x_msg_count => l_msg_count,
	          x_msg_data=> l_msg_data);
        ELSIF(P_Carrier_info.STATUS = 'I') THEN

          HZ_PARTY_USG_ASSIGNMENT_PVT.inactivate_usg_assignment (
          p_init_msg_list => FND_API.G_TRUE,
          p_validation_level => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_MEDIUM,
          p_party_usg_assignment_id => l_party_usg_assignment_id,
          p_party_id=> P_Carrier_info.CARRIER_ID,
          p_party_usage_code=> 'TRANSPORTATION_PROVIDER',
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data=>l_msg_data);

        END IF;
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE HZ_FAIL_EXCEPTION;
        END IF;
      END IF;

      -- END Party Usage
      l_position := 30;
      l_call_procedure := 'Updating WSH_CARRIERS table';
      --bug 5598102 creation_date and created_by removed from update statement
        UPDATE WSH_CARRIERS
        SET   scac_code                = P_Carrier_info.SCAC_CODE,
              currency_code            = P_Carrier_info.CURRENCY_CODE,
              manifesting_enabled_flag = P_Carrier_info.MANIFESTING_ENABLED,
              attribute_category       = P_Carrier_info.Attribute_Category,
              attribute1               = P_Carrier_info.Attribute1,
              attribute2               = P_Carrier_info.Attribute2,
              attribute3               = P_Carrier_info.Attribute3,
              attribute4               = P_Carrier_info.Attribute4,
              attribute5               = P_Carrier_info.Attribute5,
              attribute6               = P_Carrier_info.Attribute6,
              attribute7               = P_Carrier_info.Attribute7,
              attribute8               = P_Carrier_info.Attribute8,
              attribute9               = P_Carrier_info.Attribute9,
              attribute10              = P_Carrier_info.Attribute10,
              attribute11              = P_Carrier_info.Attribute11,
              attribute12              = P_Carrier_info.Attribute12,
              attribute13              = P_Carrier_info.Attribute13,
              attribute14              = P_Carrier_info.Attribute14,
              attribute15              = P_Carrier_info.Attribute15,
              last_update_date         = sysdate,
              last_updated_by          = FND_GLOBAL.USER_ID,
              last_update_login        = FND_GLOBAL.login_id,
              -- Pack J
              MAX_NUM_STOPS_PERMITTED        = P_Carrier_info.MAX_NUM_STOPS_PERMITTED,
              MAX_TOTAL_DISTANCE             = P_Carrier_info.MAX_TOTAL_DISTANCE,
              MAX_TOTAL_TIME                 = P_Carrier_info.MAX_TOTAL_TIME,
              ALLOW_INTERSPERSE_LOAD         = P_Carrier_info.ALLOW_INTERSPERSE_LOAD,
              MAX_LAYOVER_TIME               = P_Carrier_info.MAX_LAYOVER_TIME,
              MIN_LAYOVER_TIME               = P_Carrier_info.MIN_LAYOVER_TIME,
              MAX_TOTAL_DISTANCE_IN_24HR     = P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR,
              MAX_DRIVING_TIME_IN_24HR       = P_Carrier_info.MAX_DRIVING_TIME_IN_24HR,
              MAX_DUTY_TIME_IN_24HR          = P_Carrier_info.MAX_DUTY_TIME_IN_24HR,
              MAX_CM_DISTANCE                = P_Carrier_info.MAX_CM_DISTANCE,
              MAX_CM_TIME                    = P_Carrier_info.MAX_CM_TIME,
              MAX_CM_DH_DISTANCE             = P_Carrier_info.MAX_CM_DH_DISTANCE,
              MAX_SIZE_WIDTH                 = P_Carrier_info.MAX_SIZE_WIDTH,
              MAX_SIZE_HEIGHT                = P_Carrier_info.MAX_SIZE_HEIGHT,
              MAX_SIZE_LENGTH                = P_Carrier_info.MAX_SIZE_LENGTH,
              MIN_SIZE_WIDTH                 = P_Carrier_info.MIN_SIZE_WIDTH,
              MIN_SIZE_HEIGHT                = P_Carrier_info.MIN_SIZE_HEIGHT,
              MIN_SIZE_LENGTH                = P_Carrier_info.MIN_SIZE_LENGTH,
              TIME_UOM                       = P_Carrier_info.TIME_UOM,
              DIMENSION_UOM                  = P_Carrier_info.DIMENSION_UOM,
              DISTANCE_UOM                   = P_Carrier_info.DISTANCE_UOM,
              MAX_OUT_OF_ROUTE               = P_Carrier_info.MAX_OUT_OF_ROUTE,
              CM_FREE_DH_MILEAGE             = P_Carrier_info.CM_FREE_DH_MILEAGE,
              MIN_CM_DISTANCE                = P_Carrier_info.MIN_CM_DISTANCE,
              CM_FIRST_LOAD_DISCOUNT         = P_Carrier_info.CM_FIRST_LOAD_DISCOUNT,
              MIN_CM_TIME                    = P_Carrier_info.MIN_CM_TIME,
              UNIT_RATE_BASIS                = P_Carrier_info.UNIT_RATE_BASIS,
              WEIGHT_UOM                     = P_Carrier_info.WEIGHT_UOM,
              VOLUME_UOM                     = P_Carrier_info.VOLUME_UOM,
              GENERIC_FLAG                   = P_Carrier_info.GENERIC_FLAG,
              FREIGHT_BILL_AUTO_APPROVAL     = P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL,
              FREIGHT_AUDIT_LINE_LEVEL       = P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL,
              SUPPLIER_ID                    = P_Carrier_info.SUPPLIER_ID,
              SUPPLIER_SITE_ID               = P_Carrier_info.SUPPLIER_SITE_ID,
              CM_RATE_VARIANT                = P_Carrier_info.CM_RATE_VARIANT,
              DISTANCE_CALCULATION_METHOD    = P_Carrier_info.DISTANCE_CALCULATION_METHOD,
              ALLOW_CONTINUOUS_MOVE          = P_Carrier_info.ALLOW_CONTINUOUS_MOVE,
              MAX_CM_DH_TIME                 = P_Carrier_info.MAX_CM_DH_TIME,
              ORIGIN_DSTN_SURCHARGE_LEVEL    = P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL
        WHERE carrier_id = P_Carrier_info.CARRIER_ID;

            IF SQL%NOTFOUND THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               RAISE OTHERS;
            END IF;

       --Inserted hint for performance bug 3639958
       --bug 5598102 creation_date and created_by removed from update statement
       UPDATE  /*+ index(ORG_FREIGHT_TL ORG_FREIGHT_TL_U1) */ ORG_FREIGHT_TL
       SET    description  =  SUBSTR(P_Carrier_info.CARRIER_NAME,1,80),
              attribute_category       = P_Carrier_info.Attribute_Category,
              attribute1               = P_Carrier_info.Attribute1,
              attribute2               = P_Carrier_info.Attribute2,
              attribute3               = P_Carrier_info.Attribute3,
              attribute4               = P_Carrier_info.Attribute4,
              attribute5               = P_Carrier_info.Attribute5,
              attribute6               = P_Carrier_info.Attribute6,
              attribute7               = P_Carrier_info.Attribute7,
              attribute8               = P_Carrier_info.Attribute8,
              attribute9               = P_Carrier_info.Attribute9,
              attribute10              = P_Carrier_info.Attribute10,
              attribute11              = P_Carrier_info.Attribute11,
              attribute12              = P_Carrier_info.Attribute12,
              attribute13              = P_Carrier_info.Attribute13,
              attribute14              = P_Carrier_info.Attribute14,
              attribute15              = P_Carrier_info.Attribute15,
              last_update_date         = sysdate,
              last_updated_by          = FND_GLOBAL.USER_ID,
              last_update_login        = FND_GLOBAL.login_id
       WHERE  freight_code = P_Carrier_info.FREIGHT_CODE;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
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
       x_exception_msg := 'Exception: No Data Found';
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       x_procedure := l_call_procedure;
       x_position   := l_position;
       x_sqlerr := sqlerrm;
       x_sql_code := sqlcode;

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
       x_procedure := l_call_procedure;
       x_position   := l_position;
       x_sqlerr := sqlerrm;
       x_sql_code := sqlcode;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'HZ_FAIL_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:HZ_FAIL_EXCEPTION');
     END IF;
     --

     WHEN OTHERS THEN
       x_exception_msg := 'Exception: Others';
       x_procedure := l_call_procedure;
       x_position := l_position;
       x_sqlerr := sqlerrm;
       x_sql_code := sqlcode;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --

END UPDATE_CARRIERINFO;

PROCEDURE Lock_Carriers (
      P_Carrier_info              IN  CARecType,
      p_rowid                  IN  VARCHAR2,
      x_return_status          OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_lock_row IS
SELECT *
FROM   wsh_carriers
WHERE  rowid = p_rowid
FOR UPDATE of Carrier_id NOWAIT;
RecInfo C_Lock_Row%ROWTYPE;

--4708730
CURSOR get_carrier_details is
SELECT carrier_name,active
FROM wsh_carriers_v
WHERE  carrier_id =P_Carrier_info.CARRIER_id;
Rec_carrier_details   get_carrier_details%ROWTYPE;

record_locked  EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);
others                         Exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_CARRIERS';
--

BEGIN

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
       WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CARRIER_ID',P_Carrier_info.CARRIER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_CODE',P_Carrier_info.FREIGHT_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CARRIER_NAME',P_Carrier_info.CARRIER_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.STATUS',P_Carrier_info.STATUS);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SCAC_CODE',P_Carrier_info.SCAC_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MANIFESTING_ENABLED',P_Carrier_info.MANIFESTING_ENABLED);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CURRENCY_CODE',P_Carrier_info.CURRENCY_CODE);
       -- Pack J
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_NUM_STOPS_PERMITTED',P_Carrier_info.MAX_NUM_STOPS_PERMITTED);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_DISTANCE',P_Carrier_info.MAX_TOTAL_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_TIME',P_Carrier_info.MAX_TOTAL_TIME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ALLOW_INTERSPERSE_LOAD',P_Carrier_info.ALLOW_INTERSPERSE_LOAD);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_LAYOVER_TIME',P_Carrier_info.MAX_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_LAYOVER_TIME',P_Carrier_info.MIN_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR',P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_DRIVING_TIME_IN_24HR',P_Carrier_info.MAX_DRIVING_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_DUTY_TIME_IN_24HR',P_Carrier_info.MAX_DUTY_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DISTANCE',P_Carrier_info.MAX_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_TIME',P_Carrier_info.MAX_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DH_DISTANCE',P_Carrier_info.MAX_CM_DH_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_WIDTH',P_Carrier_info.MAX_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_HEIGHT',P_Carrier_info.MAX_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_SIZE_LENGTH',P_Carrier_info.MAX_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_WIDTH',P_Carrier_info.MIN_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_HEIGHT',P_Carrier_info.MIN_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_SIZE_LENGTH',P_Carrier_info.MIN_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.TIME_UOM',P_Carrier_info.TIME_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIMENSION_UOM',P_Carrier_info.DIMENSION_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DISTANCE_UOM',P_Carrier_info.DISTANCE_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_OUT_OF_ROUTE',P_Carrier_info.MAX_OUT_OF_ROUTE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_FREE_DH_MILEAGE',P_Carrier_info.CM_FREE_DH_MILEAGE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_CM_DISTANCE',P_Carrier_info.MIN_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_FIRST_LOAD_DISCOUNT',P_Carrier_info.CM_FIRST_LOAD_DISCOUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MIN_CM_TIME',P_Carrier_info.MIN_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.UNIT_RATE_BASIS',P_Carrier_info.UNIT_RATE_BASIS);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.WEIGHT_UOM',P_Carrier_info.WEIGHT_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.VOLUME_UOM',P_Carrier_info.VOLUME_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.GENERIC_FLAG',P_Carrier_info.GENERIC_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL',P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL',P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SUPPLIER_ID',P_Carrier_info.SUPPLIER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.SUPPLIER_SITE_ID',P_Carrier_info.SUPPLIER_SITE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.CM_RATE_VARIANT',P_Carrier_info.CM_RATE_VARIANT);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DISTANCE_CALCULATION_METHOD',P_Carrier_info.DISTANCE_CALCULATION_METHOD);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ALLOW_CONTINUOUS_MOVE',P_Carrier_info.ALLOW_CONTINUOUS_MOVE);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.MAX_CM_DH_TIME',P_Carrier_info.MAX_CM_DH_TIME);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL',P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL);
       -- R12 Code changes
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_DIMENSIONAL_FACTOR',P_Carrier_info.DIM_DIMENSIONAL_FACTOR);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_WEIGHT_UOM',P_Carrier_info.DIM_WEIGHT_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_VOLUME_UOM',P_Carrier_info.DIM_VOLUME_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_DIMENSION_UOM',P_Carrier_info.DIM_DIMENSION_UOM);
       WSH_DEBUG_SV.log(l_module_name,'P_Carrier_info.DIM_MIN_PACK_VOL',P_Carrier_info.DIM_MIN_PACK_VOL);
      -- R12 Code changes
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN C_lock_row;
   FETCH C_lock_row INTO Recinfo;

   IF (C_lock_row%NOTFOUND) THEN
      CLOSE C_lock_row;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status);
      RETURN;
   END IF;

   CLOSE C_lock_row;

   OPEN get_carrier_details;
   FETCH get_carrier_details INTO Rec_carrier_details;
   CLOSE get_carrier_details;

   IF (   (Recinfo.Carrier_Id = P_Carrier_info.CARRIER_ID)
      AND (Recinfo.Freight_code = P_Carrier_info.FREIGHT_CODE)
     --Bug2313801 bug 4708730 party_name and status included
     AND (Rec_carrier_details.carrier_name = P_Carrier_info.CARRIER_NAME)
     AND ( (Rec_carrier_details.active = P_Carrier_info.STATUS)
        OR (   (Rec_carrier_details.active is NULL)
            AND (P_Carrier_info.STATUS IS NULL)))
     AND ( (Recinfo.scac_code = P_Carrier_info.SCAC_CODE)
        OR (   (Recinfo.scac_code is NULL)
            AND (P_Carrier_info.SCAC_CODE IS NULL)))
     AND ( (Recinfo.currency_code = P_Carrier_info.CURRENCY_CODE)
        OR (   (Recinfo.currency_code is NULL)
            AND (P_Carrier_info.CURRENCY_CODE IS NULL)))
    AND ( (Recinfo.manifesting_enabled_flag = P_Carrier_info.MANIFESTING_ENABLED)
        OR (   (Recinfo.manifesting_enabled_flag IS NULL)
           AND (P_Carrier_info.MANIFESTING_ENABLED is NULL)))
     AND ( (Recinfo.Attribute_Category = P_Carrier_info.Attribute_Category)
        OR (   (Recinfo.Attribute_Category is NULL)
            AND (P_Carrier_info.Attribute_Category IS NULL)))
     AND ( (Recinfo.Attribute1 = P_Carrier_info.Attribute1)
        OR (   (Recinfo.Attribute1 IS NULL)
           AND (P_Carrier_info.Attribute1 is NULL)))
     AND ( (Recinfo.Attribute2 = P_Carrier_info.Attribute2)
        OR (   (Recinfo.Attribute2 IS NULL)
           AND (P_Carrier_info.Attribute2 is NULL)))
     AND ( (Recinfo.Attribute3 = P_Carrier_info.Attribute3)
        OR (   (Recinfo.Attribute3 IS NULL)
          AND (P_Carrier_info.Attribute3 is NULL)))
     AND ( (Recinfo.Attribute4 = P_Carrier_info.Attribute4)
        OR (   (Recinfo.Attribute4 IS NULL)
           AND (P_Carrier_info.Attribute4 is NULL)))
     AND ( (Recinfo.Attribute5 = P_Carrier_info.Attribute5)
        OR (   (Recinfo.Attribute5 IS NULL)
           AND (P_Carrier_info.Attribute5 is NULL)))
     AND ( (Recinfo.Attribute6 = P_Carrier_info.Attribute6)
        OR (   (Recinfo.Attribute6 IS NULL)
           AND (P_Carrier_info.Attribute6 is NULL)))
     AND ( (Recinfo.Attribute7 = P_Carrier_info.Attribute7)
       OR (   (Recinfo.Attribute7 IS NULL)
          AND (P_Carrier_info.Attribute7 is NULL)))
     AND ( (Recinfo.Attribute8 = P_Carrier_info.Attribute8)
       OR (   (Recinfo.Attribute8 IS NULL)
           AND (P_Carrier_info.Attribute8 is NULL)))
     AND ( (Recinfo.Attribute9 = P_Carrier_info.Attribute9)
       OR (   (Recinfo.Attribute9 IS NULL)
          AND (P_Carrier_info.Attribute9 is NULL)))
     AND ( (Recinfo.Attribute10 = P_Carrier_info.Attribute10)
       OR (   (Recinfo.Attribute10 IS NULL)
          AND (P_Carrier_info.Attribute10 is NULL)))
     AND ( (Recinfo.Attribute11 = P_Carrier_info.Attribute11)
        OR (   (Recinfo.Attribute11 IS NULL)
          AND (P_Carrier_info.Attribute11 is NULL)))
     AND ( (Recinfo.Attribute12 = P_Carrier_info.Attribute12)
       OR (   (Recinfo.Attribute12 IS NULL)
          AND (P_Carrier_info.Attribute12 is NULL)))
     AND ( (Recinfo.Attribute13 = P_Carrier_info.Attribute13)
       OR (   (Recinfo.Attribute13 IS NULL)
          AND (P_Carrier_info.Attribute13 is NULL)))
     AND ( (Recinfo.Attribute14 = P_Carrier_info.Attribute14)
       OR (   (Recinfo.Attribute14 IS NULL)
          AND (P_Carrier_info.Attribute14 is NULL)))
     AND ( (Recinfo.Attribute15 = P_Carrier_info.Attribute15)
       OR (   (Recinfo.Attribute15 IS NULL)
          AND (P_Carrier_info.Attribute15 is NULL)))
     -- Pack J
     AND ( (Recinfo.MAX_NUM_STOPS_PERMITTED = P_Carrier_info.MAX_NUM_STOPS_PERMITTED)
       OR (   (Recinfo.MAX_NUM_STOPS_PERMITTED IS NULL)
             AND (P_Carrier_info.MAX_NUM_STOPS_PERMITTED is NULL)))
     AND ( (Recinfo.MAX_TOTAL_DISTANCE = P_Carrier_info.MAX_TOTAL_DISTANCE)
       OR (   (Recinfo.MAX_TOTAL_DISTANCE IS NULL)
         AND (P_Carrier_info.MAX_TOTAL_DISTANCE is NULL)))
     AND ( (Recinfo.MAX_TOTAL_TIME = P_Carrier_info.MAX_TOTAL_TIME)
       OR (   (Recinfo.MAX_TOTAL_TIME IS NULL)
         AND (P_Carrier_info.MAX_TOTAL_TIME is NULL)))
     AND ( (Recinfo.ALLOW_INTERSPERSE_LOAD = P_Carrier_info.ALLOW_INTERSPERSE_LOAD)
       OR (   (Recinfo.ALLOW_INTERSPERSE_LOAD IS NULL)
         AND (P_Carrier_info.ALLOW_INTERSPERSE_LOAD is NULL)))
     AND ( (Recinfo.MAX_LAYOVER_TIME = P_Carrier_info.MAX_LAYOVER_TIME)
       OR (   (Recinfo.MAX_LAYOVER_TIME IS NULL)
         AND (P_Carrier_info.MAX_LAYOVER_TIME is NULL)))
     AND ( (Recinfo.MIN_LAYOVER_TIME = P_Carrier_info.MIN_LAYOVER_TIME)
       OR (   (Recinfo.MIN_LAYOVER_TIME IS NULL)
         AND (P_Carrier_info.MIN_LAYOVER_TIME is NULL)))
     AND ( (Recinfo.MAX_TOTAL_DISTANCE_IN_24HR = P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR)
       OR (   (Recinfo.MAX_TOTAL_DISTANCE_IN_24HR IS NULL)
         AND (P_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR is NULL)))
     AND ( (Recinfo.MAX_DRIVING_TIME_IN_24HR = P_Carrier_info.MAX_DRIVING_TIME_IN_24HR)
       OR (   (Recinfo.MAX_DRIVING_TIME_IN_24HR IS NULL)
         AND (P_Carrier_info.MAX_DRIVING_TIME_IN_24HR is NULL)))
     AND ( (Recinfo.MAX_DUTY_TIME_IN_24HR = P_Carrier_info.MAX_DUTY_TIME_IN_24HR)
       OR (   (Recinfo.MAX_DUTY_TIME_IN_24HR IS NULL)
         AND (P_Carrier_info.MAX_DUTY_TIME_IN_24HR is NULL)))
     AND ( (Recinfo.MAX_CM_DISTANCE = P_Carrier_info.MAX_CM_DISTANCE)
       OR (   (Recinfo.MAX_CM_DISTANCE IS NULL)
         AND (P_Carrier_info.MAX_CM_DISTANCE is NULL)))
     AND ( (Recinfo.MAX_CM_TIME = P_Carrier_info.MAX_CM_TIME)
       OR (   (Recinfo.MAX_CM_TIME IS NULL)
         AND (P_Carrier_info.MAX_CM_TIME is NULL)))
     AND ( (Recinfo.MAX_CM_DH_DISTANCE = P_Carrier_info.MAX_CM_DH_DISTANCE )
       OR (   (Recinfo.MAX_CM_DH_DISTANCE IS NULL)
         AND (P_Carrier_info.MAX_CM_DH_DISTANCE is NULL)))
     AND ( (Recinfo.MAX_SIZE_WIDTH = P_Carrier_info.MAX_SIZE_WIDTH )
       OR (   (Recinfo.MAX_SIZE_WIDTH IS NULL)
         AND (P_Carrier_info.MAX_SIZE_WIDTH is NULL)))
     AND ( (Recinfo.MAX_SIZE_HEIGHT = P_Carrier_info.MAX_SIZE_HEIGHT )
       OR (   (Recinfo.MAX_SIZE_HEIGHT IS NULL)
         AND (P_Carrier_info.MAX_SIZE_HEIGHT is NULL)))
     AND ( (Recinfo.MAX_SIZE_LENGTH = P_Carrier_info.MAX_SIZE_LENGTH )
       OR (   (Recinfo.MAX_SIZE_LENGTH IS NULL)
         AND (P_Carrier_info.MAX_SIZE_LENGTH is NULL)))
     AND ( (Recinfo.MIN_SIZE_WIDTH = P_Carrier_info.MIN_SIZE_WIDTH )
       OR (   (Recinfo.MIN_SIZE_WIDTH IS NULL)
         AND (P_Carrier_info.MIN_SIZE_WIDTH is NULL)))
     AND ( (Recinfo.MIN_SIZE_HEIGHT = P_Carrier_info.MIN_SIZE_HEIGHT )
       OR (   (Recinfo.MIN_SIZE_HEIGHT IS NULL)
         AND (P_Carrier_info.MIN_SIZE_HEIGHT is NULL)))
     AND ( (Recinfo.MIN_SIZE_LENGTH = P_Carrier_info.MIN_SIZE_LENGTH )
       OR (   (Recinfo.MIN_SIZE_LENGTH IS NULL)
         AND (P_Carrier_info.MIN_SIZE_LENGTH is NULL)))
     AND ( (Recinfo.TIME_UOM = P_Carrier_info.TIME_UOM )
       OR (   (Recinfo.TIME_UOM IS NULL)
         AND (P_Carrier_info.TIME_UOM is NULL)))
     AND ( (Recinfo.DIMENSION_UOM = P_Carrier_info.DIMENSION_UOM )
       OR (   (Recinfo.DIMENSION_UOM IS NULL)
         AND (P_Carrier_info.DIMENSION_UOM is NULL)))
     AND ( (Recinfo.DISTANCE_UOM = P_Carrier_info.DISTANCE_UOM )
       OR (   (Recinfo.DISTANCE_UOM IS NULL)
         AND (P_Carrier_info.DISTANCE_UOM is NULL)))
     AND ( (Recinfo.MAX_OUT_OF_ROUTE = P_Carrier_info.MAX_OUT_OF_ROUTE)
       OR (   (Recinfo.MAX_OUT_OF_ROUTE IS NULL)
         AND (P_Carrier_info.MAX_OUT_OF_ROUTE is NULL)))
     AND ( (Recinfo.CM_FREE_DH_MILEAGE = P_Carrier_info.CM_FREE_DH_MILEAGE)
       OR (   (Recinfo.CM_FREE_DH_MILEAGE IS NULL)
         AND (P_Carrier_info.CM_FREE_DH_MILEAGE is NULL)))
     AND ( (Recinfo.MIN_CM_DISTANCE = P_Carrier_info.MIN_CM_DISTANCE )
       OR (   (Recinfo.MIN_CM_DISTANCE IS NULL)
         AND (P_Carrier_info.MIN_CM_DISTANCE is NULL)))
     AND ( (Recinfo.CM_FIRST_LOAD_DISCOUNT = P_Carrier_info.CM_FIRST_LOAD_DISCOUNT )
       OR (   (Recinfo.CM_FIRST_LOAD_DISCOUNT        IS NULL)
         AND (P_Carrier_info.CM_FIRST_LOAD_DISCOUNT is NULL)))
     AND ( (Recinfo.MIN_CM_TIME = P_Carrier_info.MIN_CM_TIME )
       OR (   (Recinfo.MIN_CM_TIME IS NULL)
         AND (P_Carrier_info.MIN_CM_TIME is NULL)))
     AND ( (Recinfo.UNIT_RATE_BASIS = P_Carrier_info.UNIT_RATE_BASIS )
       OR (   (Recinfo.UNIT_RATE_BASIS IS NULL)
         AND (P_Carrier_info.UNIT_RATE_BASIS is NULL)))
     AND ( (Recinfo.WEIGHT_UOM = P_Carrier_info.WEIGHT_UOM )
       OR (   (Recinfo.WEIGHT_UOM IS NULL)
         AND (P_Carrier_info.WEIGHT_UOM is NULL)))
     AND ( (Recinfo.VOLUME_UOM = P_Carrier_info.VOLUME_UOM )
       OR (   (Recinfo.VOLUME_UOM IS NULL)
         AND (P_Carrier_info.VOLUME_UOM is NULL)))
     AND ( (Recinfo.GENERIC_FLAG = P_Carrier_info.GENERIC_FLAG )
       OR (   (Recinfo.GENERIC_FLAG IS NULL)
         AND (P_Carrier_info.GENERIC_FLAG is NULL)))
     AND ( (Recinfo.FREIGHT_BILL_AUTO_APPROVAL = P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL)
       OR (   (Recinfo.FREIGHT_BILL_AUTO_APPROVAL IS NULL)
         AND (P_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL is NULL)))
     AND ( (Recinfo.FREIGHT_AUDIT_LINE_LEVEL = P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL)
       OR (   (Recinfo.FREIGHT_AUDIT_LINE_LEVEL IS NULL)
         AND (P_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL is NULL)))
     AND ( (Recinfo.SUPPLIER_ID = P_Carrier_info.SUPPLIER_ID )
       OR (   (Recinfo.SUPPLIER_ID IS NULL)
         AND (P_Carrier_info.SUPPLIER_ID is NULL)))
     AND ( (Recinfo.SUPPLIER_SITE_ID = P_Carrier_info.SUPPLIER_SITE_ID)
       OR (   (Recinfo.SUPPLIER_SITE_ID IS NULL)
         AND (P_Carrier_info.SUPPLIER_SITE_ID is NULL)))
     AND ( (Recinfo.CM_RATE_VARIANT = P_Carrier_info.CM_RATE_VARIANT)
       OR (   (Recinfo.CM_RATE_VARIANT IS NULL)
         AND (P_Carrier_info.CM_RATE_VARIANT is NULL)))
     AND ( (Recinfo.DISTANCE_CALCULATION_METHOD = P_Carrier_info.DISTANCE_CALCULATION_METHOD)
       OR (   (Recinfo.DISTANCE_CALCULATION_METHOD IS NULL)
         AND (P_Carrier_info.DISTANCE_CALCULATION_METHOD is NULL)))
     AND ((Recinfo.ALLOW_CONTINUOUS_MOVE = P_Carrier_info.ALLOW_CONTINUOUS_MOVE)
         OR ((Recinfo.ALLOW_CONTINUOUS_MOVE IS NULL)
            AND (P_Carrier_info.ALLOW_CONTINUOUS_MOVE is NULL)))
     AND ((Recinfo.MAX_CM_DH_TIME = P_Carrier_info.MAX_CM_DH_TIME)
         OR ((Recinfo.MAX_CM_DH_TIME IS NULL)
            AND (P_Carrier_info.MAX_CM_DH_TIME is NULL)))
     AND ((Recinfo.ORIGIN_DSTN_SURCHARGE_LEVEL = P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL)
         OR ((Recinfo.ORIGIN_DSTN_SURCHARGE_LEVEL IS NULL)
            AND (P_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL is NULL)))
      ) THEN
     RETURN;
   ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION
WHEN RECORD_LOCKED THEN

IF (C_Lock_Row%ISOPEN) then
CLOSE C_Lock_Row;
END IF;
IF (get_carrier_details%ISOPEN) then
CLOSE get_carrier_details;
END IF;
FND_MESSAGE.Set_Name('WSH', 'WSH_FORM_RECORD_IS_CHANGED');
app_exception.raise_exception;
    WHEN others THEN
IF (C_Lock_Row%ISOPEN) then
CLOSE C_Lock_Row;
END IF;
IF (get_carrier_details%ISOPEN) then
CLOSE get_carrier_details;
END IF;
       x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       WSH_UTIL_CORE.Default_Handler('WSH_CREATE_CARRIERS_PKG.Lock_Carrier');

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --

END Lock_Carriers;


PROCEDURE Create_Code_Assgn(
       p_carrier_id          IN       NUMBER,
       p_class_code          IN       VARCHAR2,
       p_enabled             IN       VARCHAR2,
       x_code_assignment_id     OUT NOCOPY    NUMBER,
       x_return_status          OUT NOCOPY    VARCHAR2,
       x_position               OUT NOCOPY    NUMBER,
       x_procedure              OUT NOCOPY    VARCHAR2,
       x_exception_msg          OUT NOCOPY    VARCHAR2,
       x_sql_code               OUT NOCOPY    NUMBER,
       x_sqlerr                 OUT NOCOPY    VARCHAR2 ) IS

   -- General Declarations
     l_return_status            varchar2(100);
     l_msg_count                number;
     l_msg_data                 varchar2(2000);
     l_party_number             varchar2(100);
     HZ_FAIL_EXCEPTION          exception;
     OTHERS                     exception;
     l_position                 number;
     l_code_assignment_id       number;
     l_call_procedure           varchar2(200);

     l_code_assignment_rec_type HZ_CLASSIFICATION_V2PUB.Code_Assignment_Rec_Type;

BEGIN

     l_code_assignment_rec_type.owner_table_name    := 'HZ_PARTIES';
     l_code_assignment_rec_type.owner_table_id      := p_carrier_id;
     l_code_assignment_rec_type.created_by_module   := 'ORACLE_SHIPPING';
     l_code_assignment_rec_type.class_category      := 'TRANSPORTATION_PROVIDERS';
     l_code_assignment_rec_type.class_code          := p_class_code;
     l_code_assignment_Rec_type.primary_flag        := 'Y';
     l_code_assignment_rec_type.status              := p_enabled;
     l_code_assignment_rec_type.content_source_type := 'USER_ENTERED';
     l_code_assignment_rec_type.start_date_active   := sysdate;

     l_position := 10;
     l_call_procedure := 'Calling TCA API Create_Code_Assignment';

       HZ_CLASSIFICATION_V2PUB.Create_Code_Assignment
        (  p_init_msg_list        => FND_API.G_TRUE,
           p_code_assignment_rec  => l_code_assignment_rec_type,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           x_code_assignment_id   => l_code_assignment_id );

           IF l_return_status <> 'S' THEN
              x_return_status := l_return_status;
              Raise Hz_Fail_Exception;
           END IF;

           x_code_assignment_id := l_code_assignment_id;

EXCEPTION

     WHEN NO_DATA_FOUND THEN
        x_exception_msg := 'NO_DATA_FOUND Exception Raised';
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;
        x_return_status := 'E';

     WHEN HZ_FAIL_EXCEPTION THEN
        x_exception_msg := l_msg_data;
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;

     WHEN OTHERS THEN
        l_position := 11;
        x_exception_msg := 'WHEN OTHERS Exception Raise';
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;
        x_return_status := 'E';

END Create_Code_Assgn;


PROCEDURE Update_Code_Assgn(
       p_class_code          IN    VARCHAR2,
       p_enabled             IN    VARCHAR2,
       p_code_assignment_id  IN    NUMBER,
       x_return_status       OUT NOCOPY    VARCHAR2,
       x_position            OUT NOCOPY    NUMBER,
       x_procedure           OUT NOCOPY    VARCHAR2,
       x_exception_msg       OUT NOCOPY    VARCHAR2,
       x_sql_code            OUT NOCOPY    NUMBER,
       x_sqlerr              OUT NOCOPY    VARCHAR2 ) IS

   --  General Declarations

     l_return_status            varchar2(100);
     l_msg_count                number;
     l_msg_data                 varchar2(2000);
     l_party_number             varchar2(100);
     HZ_FAIL_EXCEPTION          exception;
     OTHERS                     exception;
     l_position                 number;
     l_code_assignment_id       number;
     l_object_version_number    number;
     l_call_procedure           varchar2(200);

l_code_assignment_rec_type HZ_CLASSIFICATION_V2PUB.Code_Assignment_Rec_Type;

CURSOR Get_Object_Version_Number IS
  SELECT object_version_number
  FROM   hz_code_assignments
  WHERE  code_assignment_id = p_code_assignment_id;


BEGIN

  OPEN Get_Object_Version_Number;
  FETCH Get_Object_Version_Number INTO l_object_version_number;
  CLOSE Get_Object_Version_Number;

   l_code_assignment_rec_type.code_assignment_id    := p_code_assignment_id;
   l_code_assignment_rec_type.class_category        := 'TRANSPORTATION_PROVIDERS';
   l_code_assignment_rec_type.primary_flag          := 'N';
   l_code_assignment_rec_type.status                := p_enabled;

     HZ_CLASSIFICATION_V2PUB.Update_Code_Assignment(
         p_init_msg_list             => FND_API.G_TRUE,
         p_code_assignment_rec       => l_code_assignment_rec_type,
         p_object_version_number     => l_object_version_number,
         x_return_status             => l_return_status,
         x_msg_count                 => l_msg_count,
         x_msg_data                  => l_msg_data );

         IF l_return_status <> 'S' THEN
            x_return_status := l_return_status;
            Raise Hz_Fail_Exception;
         END IF;

EXCEPTION



     WHEN NO_DATA_FOUND THEN
        x_exception_msg := 'NO_DATA_FOUND Exception Raised';
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;
        x_return_status := 'E';

     WHEN HZ_FAIL_EXCEPTION THEN
        x_exception_msg := l_msg_data;
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;

     WHEN OTHERS THEN
        x_exception_msg := 'WHEN OTHERS Exception Raise';
        x_position := l_position;
        x_procedure := l_call_procedure;
        x_sqlerr := sqlerrm;
        x_sql_code := sqlcode;
        x_return_status := 'E';

END Update_Code_Assgn;

PROCEDURE Get_Site_Trans_Details(
    p_carrier_id         IN         NUMBER
  , p_organization_id    IN         NUMBER
  , x_site_trans_rec     OUT NOCOPY Site_Rec_Type
  , x_return_status      OUT NOCOPY VARCHAR2 ) IS

CURSOR Get_Site_Details IS
  SELECT
    WCS.CARRIER_ID,
    WCS.CARRIER_SITE_ID,
    WCS.EMAIL_ADDRESS,
    WCS.AUTO_ACCEPT_LOAD_TENDER,
    WCS.TENDER_WAIT_TIME,
    WCS.WAIT_TIME_UOM,
    WCS.WEIGHT_THRESHOLD_UPPER,
    WCS.WEIGHT_THRESHOLD_LOWER,
    WCS.VOLUME_THRESHOLD_UPPER,
    WCS.VOLUME_THRESHOLD_LOWER,
    WCS.ENABLE_AUTO_TENDER, -- R12 Code changes
    WCS.TENDER_TRANSMISSION_METHOD
  FROM
    WSH_CARRIER_SITES WCS,
    WSH_ORG_CARRIER_SITES WOCS
  WHERE
    WCS.CARRIER_ID = p_carrier_id AND
    WOCS.ORGANIZATION_ID = p_organization_id AND
    WOCS.CARRIER_SITE_ID = WCS.CARRIER_SITE_ID AND
    WOCS.ENABLED_FLAG = 'Y';

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Site_Details';
--

BEGIN

   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);

   END IF;
   --

   x_Return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN Get_Site_Details;
   FETCH Get_Site_Details INTO
         x_site_trans_rec.carrier_id,
         x_site_trans_rec.carrier_site_id,
         x_site_trans_rec.email_address,
         x_site_trans_rec.auto_accept_load_tender,
         x_site_trans_rec.tender_wait_time,
         x_site_trans_rec.wait_time_uom,
         x_site_trans_rec.weight_threshold_upper,
         x_site_trans_rec.weight_threshold_lower,
         x_site_trans_rec.volume_threshold_upper,
         x_site_trans_rec.volume_threshold_lower,
	 x_site_trans_rec.enable_auto_tender,
         x_site_trans_rec.TENDER_TRANSMISSION_METHOD;
   CLOSE Get_Site_Details;

     IF x_site_trans_rec.carrier_id IS NULL THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION

  WHEN OTHERS THEN

   x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --

END Get_Site_Trans_Details;

PROCEDURE Carrier_Deactivate(
    p_carrier_id        IN  NUMBER
   ,x_return_status     OUT NOCOPY     VARCHAR2
   ,x_position          OUT NOCOPY     NUMBER
   ,x_exception_msg     OUT NOCOPY     VARCHAR2
   ,x_procedure         OUT NOCOPY     VARCHAR2
   ,x_sqlerr            OUT NOCOPY     VARCHAR2
   ,x_sql_code          OUT NOCOPY     VARCHAR2
) IS

  CURSOR C_get_carrier_services(p_carrier_id NUMBER)  IS
  SELECT carrier_service_id
  FROM wsh_carrier_services
  WHERE carrier_id = p_carrier_id;

  CURSOR C_get_carrier_sites(p_carrier_id NUMBER)  IS
  SELECT party_site_id
  FROM hz_party_sites
  WHERE party_id=p_carrier_id;


  CURSOR Get_Site_Object_Number(p_party_site_id NUMBER) IS
  select object_version_number
  from   hz_party_sites
  where  party_site_id = p_party_site_id;


  CURSOR C_lookup_row(p_ship_method_code VARCHAR2) IS
  --Bug3330869  SELECT *
  SELECT LOOKUP_CODE,
         TAG,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         START_DATE_ACTIVE,
         END_DATE_ACTIVE,
         TERRITORY_CODE,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         MEANING,
         DESCRIPTION
  FROM   fnd_lookup_values
  where lookup_type = 'SHIP_METHOD'
  and security_group_id = 0
  and view_application_id = 3
  and lookup_code = p_ship_method_code;

  lookupinfo C_lookup_row%ROWTYPE;

  CURSOR C_get_FREIGHT_code(p_carrier_id NUMBER)  IS
  SELECT freight_code
  FROM wsh_carriers
  WHERE carrier_id = p_carrier_id;

  CURSOR C_get_ship_method_code(p_carrier_service_id NUMBER)  IS
  SELECT ship_method_code
  FROM wsh_carrier_services
  WHERE carrier_service_id = p_carrier_service_id;

  hz_fail_exception      EXCEPTION;
  unassignall_fail_exception EXCEPTION;
  l_carrier_service_id   NUMBER;
  l_ship_method_code     VARCHAR(200);
  l_return_status        VARCHAR2(200);

  l_position              NUMBER;
  l_procedure             VARCHAR2(50);
  l_sqlerr                VARCHAR2(150);
  l_sql_code              VARCHAR2(50);
  l_exception_msg         VARCHAR(150);

  l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Carrier_Deactivate';

  l_site_rec                 HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
  l_loc_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

  l_site_object_number    NUMBER;
  l_carrier_site_id       NUMBER;

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_freight_code          VARCHAR(200);

  BEGIN
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',p_carrier_id);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- Deactivation of Carrier Services

    OPEN  C_get_freight_code(p_carrier_id);
    FETCH C_get_freight_code INTO l_freight_code;
    CLOSE C_get_freight_code;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Deactivating Carrier Services of',p_carrier_id);
      WSH_DEBUG_SV.log(l_module_name,'L_FREIGHT_CODE',l_freight_code);
    END IF;

    OPEN  C_get_carrier_services(p_carrier_id);
    FETCH C_get_carrier_services INTO l_carrier_service_id;
    -- Looping for each carrier service ID
    WHILE C_get_carrier_services%FOUND
    LOOP
      OPEN  C_get_ship_method_code(l_carrier_service_id);
      FETCH C_get_ship_method_code INTO l_ship_method_code;
      CLOSE C_get_ship_method_code;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'L_CARRIER_SERVICE_ID',l_carrier_service_id);
        WSH_DEBUG_SV.log(l_module_name,'L_SHIP_METHOD_CODE',l_ship_method_code);
      END IF;

      IF l_ship_method_code IS NOT NULL THEN
        l_position := 10;
        l_procedure := 'Calling Car_Ser_Unassign_AllOrg';

        -- Unassigning Organization from Carrier service
        WSH_CARRIER_SERVICES_PKG.Car_Ser_Unassign_AllOrg(
          p_carrier_service_id => l_carrier_service_id,
          p_ship_method_code => l_ship_method_code,
          p_freight_code => l_freight_code,
          x_exception_msg => l_exception_msg,
          x_return_status => l_return_status,
          x_position => l_position,
          x_procedure => l_procedure,
          x_sqlerr => l_sqlerr,
          x_sql_code => l_sql_code
        );

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE UNASSIGNALL_FAIL_EXCEPTION;
        END IF;

        l_position := 20;
        l_procedure := 'Fetching from cursor';
        -- Disable SHIP_METHOD Look Up value.
        OPEN C_lookup_row(l_ship_method_code);
        FETCH C_lookup_row INTO lookupinfo;

        IF (C_lookup_row%NOTFOUND) THEN
          CLOSE C_lookup_row;
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'C_lookup_row%NOTFOUND');
          END IF;
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE C_lookup_row;

        l_position  := 30;
        l_procedure := 'Updating FND_LOOKUP_VALUES';

        FND_LOOKUP_VALUES_PKG.UPDATE_ROW
        (
          X_LOOKUP_TYPE         => 'SHIP_METHOD',
          X_SECURITY_GROUP_ID   => 0,
          X_VIEW_APPLICATION_ID => 3,
          X_LOOKUP_CODE         => lookupinfo.LOOKUP_CODE,
          X_TAG                 => lookupinfo.TAG,
          X_ATTRIBUTE_CATEGORY  => lookupinfo.ATTRIBUTE_CATEGORY,
          X_ATTRIBUTE1          => lookupinfo.ATTRIBUTE1,
          X_ATTRIBUTE2          => lookupinfo.ATTRIBUTE2,
          X_ATTRIBUTE3          => lookupinfo.ATTRIBUTE3,
          X_ATTRIBUTE4          => lookupinfo.ATTRIBUTE4,
          X_ENABLED_FLAG        => 'N',
          X_START_DATE_ACTIVE   => lookupinfo.START_DATE_ACTIVE,
          X_END_DATE_ACTIVE     => lookupinfo.END_DATE_ACTIVE,
          X_TERRITORY_CODE      => lookupinfo.TERRITORY_CODE,
          X_ATTRIBUTE5          => lookupinfo.ATTRIBUTE5,
          X_ATTRIBUTE6          => lookupinfo.ATTRIBUTE6,
          X_ATTRIBUTE7          => lookupinfo.ATTRIBUTE7,
          X_ATTRIBUTE8          => lookupinfo.ATTRIBUTE8,
          X_ATTRIBUTE9          => lookupinfo.ATTRIBUTE9,
          X_ATTRIBUTE10         => lookupinfo.ATTRIBUTE10,
          X_ATTRIBUTE11         => lookupinfo.ATTRIBUTE11,
          X_ATTRIBUTE12         => lookupinfo.ATTRIBUTE12,
          X_ATTRIBUTE13         => lookupinfo.ATTRIBUTE13,
          X_ATTRIBUTE14         => lookupinfo.ATTRIBUTE14,
          X_ATTRIBUTE15         => lookupinfo.ATTRIBUTE15,
          X_MEANING             => lookupinfo.MEANING,
          X_DESCRIPTION         => lookupinfo.DESCRIPTION,
          X_LAST_UPDATE_DATE    => sysdate,
          X_LAST_UPDATED_BY     => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_LOGIN   => FND_GLOBAL.LOGIN_ID
       );
      END IF;
      FETCH C_get_carrier_services INTO l_carrier_service_id;
    END LOOP;
  CLOSE C_get_carrier_services;

  -- Update to Deactivate All Carrier Services.
  UPDATE WSH_CARRIER_SERVICES
  SET ENABLED_FLAG        = 'N'
  WHERE carrier_id= p_carrier_id;

  -- Deactivation of Carrier Services
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'De-Activating Carrier Sites of',p_carrier_id);
  END IF;

  OPEN C_get_carrier_sites(p_carrier_id);
  FETCH C_get_carrier_sites INTO l_carrier_site_id;
  -- Looping for each carrier site ID

  WHILE C_get_carrier_sites%FOUND
  LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_carrier_site_id',l_carrier_site_id);
    END IF;
    l_site_rec.party_site_id  := l_carrier_site_id;
    l_site_rec.status         := 'I';

    OPEN Get_Site_Object_Number(l_carrier_site_id);
    FETCH Get_Site_Object_Number INTO l_site_object_number;
    CLOSE Get_Site_Object_Number;

    l_position  := 40;
    l_procedure := 'Unassigning Org from Carrier Sites';
    -- Unassigning Org from Carrier Sites
    UPDATE WSH_ORG_CARRIER_SITES
    SET ENABLED_FLAG = 'N'
    WHERE  CARRIER_SITE_ID = l_carrier_site_id;

    l_position  := 50;
    l_procedure := 'Deactivation of Carrier Sites';

    -- Deactivating Party Site.
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
    FETCH C_get_carrier_sites INTO l_carrier_site_id;
  END LOOP;
  CLOSE C_get_carrier_sites;

  -- Unassign Vehicle Types
  UPDATE WSH_CARRIER_VEHICLE_TYPES
  SET    ASSIGNED_FLAG = 'N'
  WHERE  CARRIER_ID = p_carrier_id;

  UPDATE ORG_FREIGHT_TL
  SET DISABLE_DATE = SYSDATE
  WHERE party_id=p_carrier_id and DISABLE_DATE is NULL;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN UNASSIGNALL_FAIL_EXCEPTION THEN

    x_exception_msg := 'EXCEPTION : UNASSIGNALL_FAIL_EXCEPTION' || l_exception_msg;
    x_position      := l_position;
    x_procedure     := l_procedure;
    x_sqlerr        := sqlerrm;
    x_sql_code      := sqlcode;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'UNASSIGNALL_FAIL_EXCEPTION error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UNASSIGNALL_FAIL_EXCEPTION');
    END IF;
    --
  WHEN HZ_FAIL_EXCEPTION THEN
    x_exception_msg := l_msg_data;
    x_position      := l_position;
    x_procedure     := l_procedure;
    x_sqlerr        := sqlerrm;
    x_sql_code      := sqlcode;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'HZ_FAIL_EXCEPTION error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:HZ_FAIL_EXCEPTION');
    END IF;
    --
  WHEN NO_DATA_FOUND THEN
    x_exception_msg := 'EXCEPTION : NO_DATA_FOUND';
    x_position      := l_position;
    x_procedure     := l_procedure;
    x_sqlerr        := sqlerrm;
    x_sql_code      := sqlcode;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,' No Data Found Exception occurred. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;

  WHEN OTHERS THEN
    x_exception_msg := 'EXCEPTION : OTHERS';
    x_position      := l_position;
    x_procedure     := l_procedure;
    x_sqlerr        := sqlerrm;
    x_sql_code      := sqlcode;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Carrier_Deactivate;


END WSH_CREATE_CARRIERS_PKG;

/
