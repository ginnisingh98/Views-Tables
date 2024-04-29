--------------------------------------------------------
--  DDL for Package Body WSH_CARRIER_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CARRIER_SERVICES_PKG" as
/* $Header: WSHCVTHB.pls 120.4 2006/05/29 07:10:47 jnpinto noship $ */

--- Package Name: WSH_CARRIER_SERVICES_PKG
--- Pupose:       Table Handlers for table WSH_CARRIER_SERVICES
--- Note:         Please set tabstop=3 to read file with proper alignment

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CARRIER_SERVICES_PKG';
--
PROCEDURE Create_Carrier_Service
(
  p_Carrier_Service_Info       IN     CSRecType DEFAULT NULL
, p_commit                     IN    VARCHAR2 DEFAULT FND_API.G_FALSE
, x_Rowid                OUT NOCOPY     VARCHAR2
, x_Carrier_Service_id         OUT NOCOPY     NUMBER
, x_Return_Status              OUT NOCOPY     VARCHAR2
, x_position                   OUT NOCOPY     NUMBER
, x_procedure                  OUT NOCOPY     VARCHAR2
, x_sqlerr                     OUT NOCOPY     VARCHAR2
, x_sql_code                   OUT NOCOPY     VARCHAR2
)
IS

CURSOR C_Next_id
IS
SELECT wsh_carrier_services_s.nextval
FROM sys.dual;


CURSOR C_New_Rowid(p_carrier_service_id NUMBER)
IS
SELECT rowid
FROM WSH_CARRIER_SERVICES
WHERE carrier_service_id = p_carrier_service_id;

l_rowid                         rowid;
l_smc                           NUMBER;
no_data_found                   EXCEPTION;
l_err varchar2(100);

others                  EXCEPTION;
l_carrier_service_id            NUMBER;

l_position                      NUMBER;
l_procedure                     VARCHAR2(50);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CARRIER_SERVICE';
--
BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Service_ID',
                                    p_Carrier_Service_Info.Carrier_Service_ID);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                                    p_Carrier_Service_Info.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Meaning',
                                    p_Carrier_Service_Info.Ship_Method_Meaning);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',
                                    p_Carrier_Service_Info.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'min_sl_time',
                                    p_Carrier_Service_Info.min_sl_time);
      WSH_DEBUG_SV.log(l_module_name,'max_sl_time',
                                    p_Carrier_Service_Info.max_sl_time);
      WSH_DEBUG_SV.log(l_module_name,'sl_time_uom',
                                    p_Carrier_Service_Info.sl_time_uom);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                    p_Carrier_Service_Info.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'attribute1',
                                    p_Carrier_Service_Info.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'attribute2',
                                    p_Carrier_Service_Info.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'attribute3',
                                    p_Carrier_Service_Info.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'attribute4',
                                    p_Carrier_Service_Info.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'attribute5',
                                    p_Carrier_Service_Info.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'attribute6',
                                    p_Carrier_Service_Info.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'attribute7',
                                    p_Carrier_Service_Info.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'attribute8',
                                    p_Carrier_Service_Info.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'attribute9',
                                    p_Carrier_Service_Info.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'attribute10',
                                    p_Carrier_Service_Info.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'attribute11',
                                    p_Carrier_Service_Info.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'attribute12',
                                    p_Carrier_Service_Info.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'attribute13',
                                    p_Carrier_Service_Info.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'attribute14',
                                    p_Carrier_Service_Info.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'attribute15',
                                    p_Carrier_Service_Info.attribute15);
      -- Pack J Enhancement

       WSH_DEBUG_SV.log(l_module_name, 'MAX_NUM_STOPS_PERMITTED',
                                 p_Carrier_Service_Info.MAX_NUM_STOPS_PERMITTED);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_DISTANCE',
                                 p_Carrier_Service_Info.MAX_TOTAL_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_TIME',
                                 p_Carrier_Service_Info.MAX_TOTAL_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'ALLOW_INTERSPERSE_LOAD',
                                 p_Carrier_Service_Info.ALLOW_INTERSPERSE_LOAD);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_LAYOVER_TIME',
                                 p_Carrier_Service_Info.MAX_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_LAYOVER_TIME',
                                 p_Carrier_Service_Info.MIN_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_DISTANCE_IN_24HR',
                                 p_Carrier_Service_Info.MAX_TOTAL_DISTANCE_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_DRIVING_TIME_IN_24HR',
                                 p_Carrier_Service_Info.MAX_DRIVING_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_DUTY_TIME_IN_24HR',
                                 p_Carrier_Service_Info.MAX_DUTY_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DISTANCE',
                                 p_Carrier_Service_Info.MAX_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_TIME',
                                 p_Carrier_Service_Info.MAX_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DH_DISTANCE',
                                 p_Carrier_Service_Info.MAX_CM_DH_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_WIDTH',
                                 p_Carrier_Service_Info.MAX_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_HEIGHT',
                                 p_Carrier_Service_Info.MAX_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_LENGTH',
                                 p_Carrier_Service_Info.MAX_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_WIDTH',
                                 p_Carrier_Service_Info.MIN_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_HEIGHT',
                                 p_Carrier_Service_Info.MIN_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_LENGTH',
                                 p_Carrier_Service_Info.MIN_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_OUT_OF_ROUTE',
                                 p_Carrier_Service_Info.MAX_OUT_OF_ROUTE);
       WSH_DEBUG_SV.log(l_module_name, 'CM_FREE_DH_MILEAGE',
                                 p_Carrier_Service_Info.CM_FREE_DH_MILEAGE);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_CM_DISTANCE',
                                 p_Carrier_Service_Info.MIN_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'CM_FIRST_LOAD_DISCOUNT',
                                 p_Carrier_Service_Info.CM_FIRST_LOAD_DISCOUNT);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_CM_TIME',
                                 p_Carrier_Service_Info.MIN_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'UNIT_RATE_BASIS',
                                 p_Carrier_Service_Info.UNIT_RATE_BASIS);
       WSH_DEBUG_SV.log(l_module_name, 'CM_RATE_VARIANT',
                                 p_Carrier_Service_Info.CM_RATE_VARIANT);
       WSH_DEBUG_SV.log(l_module_name, 'DISTANCE_CALCULATION_METHOD',
                                 p_Carrier_Service_Info.DISTANCE_CALCULATION_METHOD);
       WSH_DEBUG_SV.log(l_module_name, 'ORIGIN_DSTN_SURCHARGE_LEVEL',
                                 p_Carrier_Service_Info.ORIGIN_DSTN_SURCHARGE_LEVEL);
       WSH_DEBUG_SV.log(l_module_name, 'ALLOW_CONTINUOUS_MOVE',
                                 p_Carrier_Service_Info.ALLOW_CONTINUOUS_MOVE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DH_TIME',
                                 p_Carrier_Service_Info.MAX_CM_DH_TIME);
      -- R12 Code changes
       WSH_DEBUG_SV.log(l_module_name, 'DIM_DIMENSIONA_FACTOR',
                                 p_Carrier_Service_Info.DIM_DIMENSIONAL_FACTOR);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_WEIGHT_UOM',
                                 p_Carrier_Service_Info.DIM_WEIGHT_UOM);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_VOLUME_UOM',
                                 p_Carrier_Service_Info.DIM_VOLUME_UOM);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_DIMENSION_UOM',
                                 p_Carrier_Service_Info.DIM_DIMENSION_UOM);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_MIN_PACK_VOL',
                                 p_Carrier_Service_Info.DIM_MIN_PACK_VOL);
       WSH_DEBUG_SV.log(l_module_name, 'DEFAULT_VEHICLE_TYPE_ID',
                                 p_Carrier_Service_Info.DEFAULT_VEHICLE_TYPE_ID);
      -- R12 Code changes
       WSH_DEBUG_SV.log(l_module_name, 'UPDATE_MOT_SL',
                                 p_Carrier_Service_Info.UPDATE_MOT_SL);
  END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF (l_Carrier_service_id is NULL) THEN
      OPEN C_Next_id;
      FETCH C_Next_id INTO l_Carrier_Service_Id;
      CLOSE C_Next_id;
   END IF;

  Select count(*)
  into l_smc
  From fnd_lookup_values
  Where lookup_type like 'SHIP_METHOD' and
  lookup_code like p_Carrier_Service_Info.ship_method_code;
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_Carrier_Service_Id',
                                                l_Carrier_Service_Id);
     WSH_DEBUG_SV.log(l_module_name,'l_smc',l_smc);
  END IF;

  IF (l_smc = 0) then
      l_position := 10;
      l_procedure := 'Calling FND_LOOKUP_VALUE_PKG.INSERT_ROW';
      FND_LOOKUP_VALUES_PKG.INSERT_ROW(
      X_ROWID => l_rowid,
      X_LOOKUP_TYPE => 'SHIP_METHOD',
      X_SECURITY_GROUP_ID => 0,
      X_VIEW_APPLICATION_ID =>3,
      X_LOOKUP_CODE => p_Carrier_Service_Info.ship_method_code,
      X_TAG => NULL,
      X_ATTRIBUTE_CATEGORY => NULL,
      X_ATTRIBUTE1 => NULL,
      X_ATTRIBUTE2 => NULL,
      X_ATTRIBUTE3 => NULL,
      X_ATTRIBUTE4 => NULL,
      X_ENABLED_FLAG => 'Y',
      X_START_DATE_ACTIVE => SYSDATE,
      X_END_DATE_ACTIVE => NULL,
      X_TERRITORY_CODE => NULL,
      X_ATTRIBUTE5 => NULL,
      X_ATTRIBUTE6 => NULL,
      X_ATTRIBUTE7 => NULL,
      X_ATTRIBUTE8 => NULL,
      X_ATTRIBUTE9 => NULL,
      X_ATTRIBUTE10 => NULL,
      X_ATTRIBUTE11 => NULL,
      X_ATTRIBUTE12 => NULL,
      X_ATTRIBUTE13 => NULL,
      X_ATTRIBUTE14 => NULL,
      X_ATTRIBUTE15 => NULL,
      X_MEANING => p_Carrier_Service_Info.ship_method_meaning,
      X_DESCRIPTION => p_Carrier_Service_Info.ship_method_meaning,
      X_CREATION_DATE => sysdate,
      X_CREATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);

  END IF;

  l_position := 20;
  l_procedure := 'Inserting Into Wsh_Carrier_Services';

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Inserting into wsh_carrier_services');
  END IF;

  INSERT INTO wsh_carrier_services(
           carrier_service_id,
     carrier_id,
           mode_of_transport,
     enabled_flag,
     web_enabled,
     service_level,
           min_sl_time,
           max_sl_time,
           sl_time_uom,
     ship_method_code,
           ship_method_meaning,
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
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     -- Pack J Enhancement
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
     MAX_OUT_OF_ROUTE,
     CM_FREE_DH_MILEAGE,
     MIN_CM_DISTANCE,
     CM_FIRST_LOAD_DISCOUNT,
     MIN_CM_TIME,
     UNIT_RATE_BASIS,
     CM_RATE_VARIANT,
     DISTANCE_CALCULATION_METHOD,
     ALLOW_CONTINUOUS_MOVE,
     MAX_CM_DH_TIME,
     ORIGIN_DSTN_SURCHARGE_LEVEL,
     UPDATE_MOT_SL
     )
     VALUES (
     l_carrier_service_id,
     p_Carrier_Service_Info.Carrier_Id,
     p_Carrier_Service_Info.mode_of_transport,
     p_Carrier_Service_Info.Enabled_Flag,
     p_Carrier_Service_Info.web_enabled,
     p_Carrier_Service_Info.service_level,
     p_Carrier_Service_Info.min_sl_time,
     p_Carrier_Service_Info.max_sl_time,
     p_Carrier_Service_Info.sl_time_uom,
     p_Carrier_Service_Info.Ship_Method_Code,
     p_Carrier_Service_Info.Ship_Method_Meaning,
     p_Carrier_Service_Info.Attribute_Category,
     p_Carrier_Service_Info.Attribute1,
     p_Carrier_Service_Info.Attribute2,
     p_Carrier_Service_Info.Attribute3,
     p_Carrier_Service_Info.Attribute4,
     p_Carrier_Service_Info.Attribute5,
     p_Carrier_Service_Info.Attribute6,
     p_Carrier_Service_Info.Attribute7,
     p_Carrier_Service_Info.Attribute8,
     p_Carrier_Service_Info.Attribute9,
     p_Carrier_Service_Info.Attribute10,
     p_Carrier_Service_Info.Attribute11,
     p_Carrier_Service_Info.Attribute12,
     p_Carrier_Service_Info.Attribute13,
     p_Carrier_Service_Info.Attribute14,
     p_Carrier_Service_Info.Attribute15,
     p_Carrier_Service_Info.Creation_date,
     p_Carrier_Service_Info.Created_By,
     p_Carrier_Service_Info.Last_Update_Date,
     p_Carrier_Service_Info.Last_Updated_By,
     p_Carrier_Service_Info.Last_Update_Login,
     -- Pack J Enhancement
     p_Carrier_Service_Info.MAX_NUM_STOPS_PERMITTED,
     p_Carrier_Service_Info.MAX_TOTAL_DISTANCE,
     p_Carrier_Service_Info.MAX_TOTAL_TIME,
     p_Carrier_Service_Info.ALLOW_INTERSPERSE_LOAD,
     p_Carrier_Service_Info.MAX_LAYOVER_TIME,
     p_Carrier_Service_Info.MIN_LAYOVER_TIME,
     p_Carrier_Service_Info.MAX_TOTAL_DISTANCE_IN_24HR,
     p_Carrier_Service_Info.MAX_DRIVING_TIME_IN_24HR,
     p_Carrier_Service_Info.MAX_DUTY_TIME_IN_24HR,
     p_Carrier_Service_Info.MAX_CM_DISTANCE,
     p_Carrier_Service_Info.MAX_CM_TIME,
     p_Carrier_Service_Info.MAX_CM_DH_DISTANCE,
     p_Carrier_Service_Info.MAX_SIZE_WIDTH,
     p_Carrier_Service_Info.MAX_SIZE_HEIGHT,
     p_Carrier_Service_Info.MAX_SIZE_LENGTH,
     p_Carrier_Service_Info.MIN_SIZE_WIDTH,
     p_Carrier_Service_Info.MIN_SIZE_HEIGHT,
     p_Carrier_Service_Info.MIN_SIZE_LENGTH,
     p_Carrier_Service_Info.MAX_OUT_OF_ROUTE,
     p_Carrier_Service_Info.CM_FREE_DH_MILEAGE,
     p_Carrier_Service_Info.MIN_CM_DISTANCE,
     p_Carrier_Service_Info.CM_FIRST_LOAD_DISCOUNT,
     p_Carrier_Service_Info.MIN_CM_TIME,
     p_Carrier_Service_Info.UNIT_RATE_BASIS,
     p_Carrier_Service_Info.CM_RATE_VARIANT,
     p_Carrier_Service_Info.DISTANCE_CALCULATION_METHOD,
     p_Carrier_Service_Info.ALLOW_CONTINUOUS_MOVE,
     p_Carrier_Service_Info.MAX_CM_DH_TIME,
     p_Carrier_Service_Info.ORIGIN_DSTN_SURCHARGE_LEVEL,
     p_Carrier_Service_Info.UPDATE_MOT_SL
      );

      l_position := 30;
      l_procedure := 'Checking rowid Into Wsh_Carrier_Services';

   OPEN C_New_Rowid(l_carrier_service_id);
  FETCH C_New_Rowid INTO x_rowid;
  IF (C_New_Rowid%NOTFOUND) THEN
    CLOSE C_New_Rowid;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'C_New_Rowid%NOTFOUND');
                END IF;
    RAISE others;
         END IF;

   x_carrier_service_id := l_carrier_service_id;

   IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
       WHEN others THEN
           X_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           X_position := l_position;
           X_procedure := l_procedure;
           X_SQLERR := SQLERRM;
           X_sql_code  := SQLCODE;
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
           --
END Create_Carrier_Service;

PROCEDURE Lock_Carrier_Service (
  p_rowid                  IN     VARCHAR2
, p_Carrier_Service_Info   IN     CSRecType  DEFAULT NULL
, x_Return_Status          OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_lock_row IS
-- SELECT *
SELECT
     carrier_service_id,
     carrier_id,
     mode_of_transport,
     enabled_flag,
     web_enabled,
     service_level,
     min_sl_time,
     max_sl_time,
     sl_time_uom,
     ship_method_code,
     ship_method_meaning,
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
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     -- Pack J Enhancement
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
     MAX_OUT_OF_ROUTE,
     CM_FREE_DH_MILEAGE,
     MIN_CM_DISTANCE,
     CM_FIRST_LOAD_DISCOUNT,
     MIN_CM_TIME,
     UNIT_RATE_BASIS,
     CM_RATE_VARIANT,
     DISTANCE_CALCULATION_METHOD,
     ALLOW_CONTINUOUS_MOVE,
     MAX_CM_DH_TIME,
     ORIGIN_DSTN_SURCHARGE_LEVEL,
     UPDATE_MOT_SL
FROM   wsh_carrier_services
WHERE  rowid = p_rowid
FOR UPDATE of Carrier_Service_id NOWAIT;

CURSOR C_lookup_row IS
-- Bug#3330869
-- SELECT *
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
FROM   FND_LOOKUP_VALUES
where LOOKUP_TYPE = 'SHIP_METHOD'
and SECURITY_GROUP_ID = 0
and VIEW_APPLICATION_ID = 3
and LOOKUP_CODE = p_Carrier_Service_Info.SHIP_METHOD_CODE;

Recinfo C_lock_row%ROWTYPE;
lookupinfo C_lookup_row%ROWTYPE;

record_locked  EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);
others                         Exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_CARRIER_SERVICE';
--
BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Service_ID',
                                    p_Carrier_Service_Info.Carrier_Service_ID);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                                    p_Carrier_Service_Info.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Meaning',
                                    p_Carrier_Service_Info.Ship_Method_Meaning);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',
                                    p_Carrier_Service_Info.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'min_sl_time',
                                    p_Carrier_Service_Info.min_sl_time);
      WSH_DEBUG_SV.log(l_module_name,'max_sl_time',
                                    p_Carrier_Service_Info.max_sl_time);
      WSH_DEBUG_SV.log(l_module_name,'sl_time_uom',
                                    p_Carrier_Service_Info.sl_time_uom);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                    p_Carrier_Service_Info.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'attribute1',
                                    p_Carrier_Service_Info.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'attribute2',
                                    p_Carrier_Service_Info.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'attribute3',
                                    p_Carrier_Service_Info.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'attribute4',
                                    p_Carrier_Service_Info.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'attribute5',
                                    p_Carrier_Service_Info.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'attribute6',
                                    p_Carrier_Service_Info.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'attribute7',
                                    p_Carrier_Service_Info.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'attribute8',
                                    p_Carrier_Service_Info.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'attribute9',
                                    p_Carrier_Service_Info.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'attribute10',
                                    p_Carrier_Service_Info.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'attribute11',
                                    p_Carrier_Service_Info.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'attribute12',
                                    p_Carrier_Service_Info.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'attribute13',
                                    p_Carrier_Service_Info.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'attribute14',
                                    p_Carrier_Service_Info.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'attribute15',
                                    p_Carrier_Service_Info.attribute15);

      -- Pack J Enhancement
       WSH_DEBUG_SV.log(l_module_name, 'MAX_NUM_STOPS_PERMITTED',
                                 p_Carrier_Service_Info.MAX_NUM_STOPS_PERMITTED);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_DISTANCE',
                                 p_Carrier_Service_Info.MAX_TOTAL_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_TIME',
                                 p_Carrier_Service_Info.MAX_TOTAL_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'ALLOW_INTERSPERSE_LOAD',
                                 p_Carrier_Service_Info.ALLOW_INTERSPERSE_LOAD);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_LAYOVER_TIME',
                                 p_Carrier_Service_Info.MAX_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_LAYOVER_TIME',
                                 p_Carrier_Service_Info.MIN_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_DISTANCE_IN_24HR',
                                 p_Carrier_Service_Info.MAX_TOTAL_DISTANCE_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_DRIVING_TIME_IN_24HR',
                                 p_Carrier_Service_Info.MAX_DRIVING_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_DUTY_TIME_IN_24HR',
                                 p_Carrier_Service_Info.MAX_DUTY_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DISTANCE',
                                 p_Carrier_Service_Info.MAX_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_TIME',
                                 p_Carrier_Service_Info.MAX_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DH_DISTANCE',
                                 p_Carrier_Service_Info.MAX_CM_DH_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_WIDTH',
                                 p_Carrier_Service_Info.MAX_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_HEIGHT',
                                 p_Carrier_Service_Info.MAX_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_LENGTH',
                                 p_Carrier_Service_Info.MAX_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_WIDTH',
                                 p_Carrier_Service_Info.MIN_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_HEIGHT',
                                 p_Carrier_Service_Info.MIN_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_LENGTH',
                                 p_Carrier_Service_Info.MIN_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_OUT_OF_ROUTE',
                                 p_Carrier_Service_Info.MAX_OUT_OF_ROUTE);
       WSH_DEBUG_SV.log(l_module_name, 'CM_FREE_DH_MILEAGE',
                                 p_Carrier_Service_Info.CM_FREE_DH_MILEAGE);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_CM_DISTANCE',
                                 p_Carrier_Service_Info.MIN_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'CM_FIRST_LOAD_DISCOUNT',
                                 p_Carrier_Service_Info.CM_FIRST_LOAD_DISCOUNT);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_CM_TIME',
                                 p_Carrier_Service_Info.MIN_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'UNIT_RATE_BASIS',
                                 p_Carrier_Service_Info.UNIT_RATE_BASIS);
       WSH_DEBUG_SV.log(l_module_name, 'CM_RATE_VARIANT',
                                 p_Carrier_Service_Info.CM_RATE_VARIANT);
       WSH_DEBUG_SV.log(l_module_name, 'DISTANCE_CALCULATION_METHOD',
                                 p_Carrier_Service_Info.DISTANCE_CALCULATION_METHOD);
       WSH_DEBUG_SV.log(l_module_name, 'ORIGIN_DSTN_SURCHARGE_LEVEL',
                                 p_Carrier_Service_Info.ORIGIN_DSTN_SURCHARGE_LEVEL);
       WSH_DEBUG_SV.log(l_module_name, 'ALLOW_CONTINUOUS_MOVE',
                                 p_Carrier_Service_Info.ALLOW_CONTINUOUS_MOVE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DH_TIME',
                                 p_Carrier_Service_Info.MAX_CM_DH_TIME);
      -- R12 Code changes
       WSH_DEBUG_SV.log(l_module_name, 'DIM_DIMENSIONA_FACTOR',
                                 p_Carrier_Service_Info.DIM_DIMENSIONAL_FACTOR);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_WEIGHT_UOM',
                                 p_Carrier_Service_Info.DIM_WEIGHT_UOM);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_VOLUME_UOM',
                                 p_Carrier_Service_Info.DIM_VOLUME_UOM);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_DIMENSION_UOM',
                                 p_Carrier_Service_Info.DIM_DIMENSION_UOM);
       WSH_DEBUG_SV.log(l_module_name, 'DIM_MIN_PACK_VOL',
                                 p_Carrier_Service_Info.DIM_MIN_PACK_VOL);
       WSH_DEBUG_SV.log(l_module_name, 'DEFAULT_VEHICLE_TYPE_ID',
                                 p_Carrier_Service_Info.DEFAULT_VEHICLE_TYPE_ID);
       WSH_DEBUG_SV.log(l_module_name, 'UPDATE_MOT_SL',
                                 p_Carrier_Service_Info.UPDATE_MOT_SL);
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
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;
   CLOSE C_lock_row;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Service_ID',
                                    Recinfo.Carrier_Service_ID);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                                    Recinfo.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Meaning',
                                    Recinfo.Ship_Method_Meaning);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',
                                    Recinfo.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'min_sl_time',
                                    Recinfo.min_sl_time);
      WSH_DEBUG_SV.log(l_module_name,'max_sl_time',
                                    Recinfo.max_sl_time);
      WSH_DEBUG_SV.log(l_module_name,'sl_time_uom',
                                    Recinfo.sl_time_uom);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                    Recinfo.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'attribute1',
                                    Recinfo.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'attribute2',
                                    Recinfo.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'attribute3',
                                    Recinfo.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'attribute4',
                                    Recinfo.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'attribute5',
                                    Recinfo.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'attribute6',
                                    Recinfo.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'attribute7',
                                    Recinfo.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'attribute8',
                                    Recinfo.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'attribute9',
                                    Recinfo.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'attribute10',
                                    Recinfo.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'attribute11',
                                    Recinfo.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'attribute12',
                                    Recinfo.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'attribute13',
                                    Recinfo.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'attribute14',
                                    Recinfo.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'attribute15',
                                    Recinfo.attribute15);
      -- Pack J Enhancement
       WSH_DEBUG_SV.log(l_module_name, 'MAX_NUM_STOPS_PERMITTED',
                                 Recinfo.MAX_NUM_STOPS_PERMITTED);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_DISTANCE',
                                 Recinfo.MAX_TOTAL_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_TIME',
                                 Recinfo.MAX_TOTAL_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'ALLOW_INTERSPERSE_LOAD',
                                 Recinfo.ALLOW_INTERSPERSE_LOAD);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_LAYOVER_TIME',
                                 Recinfo.MAX_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_LAYOVER_TIME',
                                 Recinfo.MIN_LAYOVER_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_TOTAL_DISTANCE_IN_24HR',
                                 Recinfo.MAX_TOTAL_DISTANCE_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_DRIVING_TIME_IN_24HR',
                                 Recinfo.MAX_DRIVING_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_DUTY_TIME_IN_24HR',
                                 Recinfo.MAX_DUTY_TIME_IN_24HR);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DISTANCE',
                                 Recinfo.MAX_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_TIME',
                                 Recinfo.MAX_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DH_DISTANCE',
                                 Recinfo.MAX_CM_DH_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_WIDTH',
                                 Recinfo.MAX_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_HEIGHT',
                                 Recinfo.MAX_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_SIZE_LENGTH',
                                 Recinfo.MAX_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_WIDTH',
                                 Recinfo.MIN_SIZE_WIDTH);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_HEIGHT',
                                 Recinfo.MIN_SIZE_HEIGHT);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_SIZE_LENGTH',
                                 Recinfo.MIN_SIZE_LENGTH);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_OUT_OF_ROUTE',
                                 Recinfo.MAX_OUT_OF_ROUTE);
       WSH_DEBUG_SV.log(l_module_name, 'CM_FREE_DH_MILEAGE',
                                 Recinfo.CM_FREE_DH_MILEAGE);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_CM_DISTANCE',
                                 Recinfo.MIN_CM_DISTANCE);
       WSH_DEBUG_SV.log(l_module_name, 'CM_FIRST_LOAD_DISCOUNT',
                                 Recinfo.CM_FIRST_LOAD_DISCOUNT);
       WSH_DEBUG_SV.log(l_module_name, 'MIN_CM_TIME',
                                 Recinfo.MIN_CM_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'UNIT_RATE_BASIS',
                                 Recinfo.UNIT_RATE_BASIS);
       WSH_DEBUG_SV.log(l_module_name, 'CM_RATE_VARIANT',
                                 Recinfo.CM_RATE_VARIANT);
       WSH_DEBUG_SV.log(l_module_name, 'DISTANCE_CALCULATION_METHOD',
                                 Recinfo.DISTANCE_CALCULATION_METHOD);
       WSH_DEBUG_SV.log(l_module_name, 'ORIGIN_DSTN_SURCHARGE_LEVEL',
                                 Recinfo.ORIGIN_DSTN_SURCHARGE_LEVEL);
       WSH_DEBUG_SV.log(l_module_name, 'MAX_CM_DH_TIME',
                                 Recinfo.MAX_CM_DH_TIME);
       WSH_DEBUG_SV.log(l_module_name, 'ALLOW_CONTINUOUS_MOVE',
                                 Recinfo.ALLOW_CONTINUOUS_MOVE);
   END IF;
   --
   IF (   (Recinfo.Carrier_Service_Id = p_Carrier_Service_Info.Carrier_Service_Id)
      AND (Recinfo.Ship_Method_Code = p_Carrier_Service_Info.Ship_Method_Code)
      AND ( (Recinfo.Service_level = p_Carrier_Service_Info.Service_level)
        OR (   (Recinfo.Service_level is NULL)
            AND (p_Carrier_Service_Info.Service_level IS NULL)))
     AND ( (Recinfo.min_sl_time = p_Carrier_Service_Info.min_sl_time)
        OR (   (Recinfo.min_sl_time is NULL)
            AND (p_Carrier_Service_Info.min_sl_time IS NULL)))
     AND ( (Recinfo.max_sl_time = p_Carrier_Service_Info.max_sl_time)
        OR (   (Recinfo.max_sl_time is NULL)
            AND (p_Carrier_Service_Info.max_sl_time IS NULL)))
     AND ( (Recinfo.sl_time_uom = p_Carrier_Service_Info.sl_time_uom)
        OR (   (Recinfo.sl_time_uom is NULL)
            AND (p_Carrier_Service_Info.sl_time_uom IS NULL)))
      AND (Recinfo.Enabled_Flag = p_Carrier_Service_Info.Enabled_Flag)
     AND ( (Recinfo.Attribute_Category = p_Carrier_Service_Info.Attribute_Category)
        OR (   (Recinfo.Attribute_Category is NULL)
            AND (p_Carrier_Service_Info.Attribute_Category IS NULL)))
     AND ( (Recinfo.Attribute1 = p_Carrier_Service_Info.Attribute1)
        OR (   (Recinfo.Attribute1 IS NULL)
           AND (p_Carrier_Service_Info.Attribute1 is NULL)))
     AND ( (Recinfo.Attribute2 = p_Carrier_Service_Info.Attribute2)
        OR (   (Recinfo.Attribute2 IS NULL)
           AND (p_Carrier_Service_Info.Attribute2 is NULL)))
     AND ( (Recinfo.Attribute3 = p_Carrier_Service_Info.Attribute3)
        OR (   (Recinfo.Attribute3 IS NULL)
          AND (p_Carrier_Service_Info.Attribute3 is NULL)))
     AND ( (Recinfo.Attribute4 = p_Carrier_Service_Info.Attribute4)
        OR (   (Recinfo.Attribute4 IS NULL)
           AND (p_Carrier_Service_Info.Attribute4 is NULL)))
     AND ( (Recinfo.Attribute5 = p_Carrier_Service_Info.Attribute5)
        OR (   (Recinfo.Attribute5 IS NULL)
           AND (p_Carrier_Service_Info.Attribute5 is NULL)))
     AND ( (Recinfo.Attribute6 = p_Carrier_Service_Info.Attribute6)
        OR (   (Recinfo.Attribute6 IS NULL)
           AND (p_Carrier_Service_Info.Attribute6 is NULL)))
     AND ( (Recinfo.Attribute7 = p_Carrier_Service_Info.Attribute7)
       OR (   (Recinfo.Attribute7 IS NULL)
          AND (p_Carrier_Service_Info.Attribute7 is NULL)))
     AND ( (Recinfo.Attribute8 = p_Carrier_Service_Info.Attribute8)
       OR (   (Recinfo.Attribute8 IS NULL)
           AND (p_Carrier_Service_Info.Attribute8 is NULL)))
     AND ( (Recinfo.Attribute9 = p_Carrier_Service_Info.Attribute9)
       OR (   (Recinfo.Attribute9 IS NULL)
          AND (p_Carrier_Service_Info.Attribute9 is NULL)))
     AND ( (Recinfo.Attribute10 = p_Carrier_Service_Info.Attribute10)
       OR (   (Recinfo.Attribute10 IS NULL)
          AND (p_Carrier_Service_Info.Attribute10 is NULL)))
     AND ( (Recinfo.Attribute11 = p_Carrier_Service_Info.Attribute11)
        OR (   (Recinfo.Attribute11 IS NULL)
          AND (p_Carrier_Service_Info.Attribute11 is NULL)))
     AND ( (Recinfo.Attribute12 = p_Carrier_Service_Info.Attribute12)
       OR (   (Recinfo.Attribute12 IS NULL)
          AND (p_Carrier_Service_Info.Attribute12 is NULL)))
     AND ( (Recinfo.Attribute13 = p_Carrier_Service_Info.Attribute13)
       OR (   (Recinfo.Attribute13 IS NULL)
          AND (p_Carrier_Service_Info.Attribute13 is NULL)))
     AND ( (Recinfo.Attribute14 = p_Carrier_Service_Info.Attribute14)
       OR (   (Recinfo.Attribute14 IS NULL)
          AND (p_Carrier_Service_Info.Attribute14 is NULL)))
     AND ( (Recinfo.Attribute15 = p_Carrier_Service_Info.Attribute15)
       OR (   (Recinfo.Attribute15 IS NULL)
          AND (p_Carrier_Service_Info.Attribute15 is NULL)))
     AND (Recinfo.Web_Enabled = p_Carrier_Service_Info.Web_Enabled)
     AND ( (Recinfo.Mode_of_Transport = p_Carrier_Service_Info.Mode_of_Transport)
        OR (   (Recinfo.Mode_of_Transport is NULL)
            AND (p_Carrier_Service_Info.Mode_of_Transport IS NULL)))
     -- Pack J enhancement
     AND ((Recinfo.MAX_NUM_STOPS_PERMITTED = p_Carrier_Service_Info.MAX_NUM_STOPS_PERMITTED)
         OR ((Recinfo.MAX_NUM_STOPS_PERMITTED IS NULL)
            AND (p_Carrier_Service_Info.MAX_NUM_STOPS_PERMITTED is NULL)))
     AND ((Recinfo.MAX_TOTAL_DISTANCE = p_Carrier_Service_Info.MAX_TOTAL_DISTANCE)
         OR ((Recinfo.MAX_TOTAL_DISTANCE IS NULL)
            AND (p_Carrier_Service_Info.MAX_TOTAL_DISTANCE is NULL)))
     AND ((Recinfo.MAX_TOTAL_TIME = p_Carrier_Service_Info.MAX_TOTAL_TIME)
         OR ((Recinfo.MAX_TOTAL_TIME IS NULL)
            AND (p_Carrier_Service_Info.MAX_TOTAL_TIME is NULL)))
     AND ((Recinfo.ALLOW_INTERSPERSE_LOAD = p_Carrier_Service_Info.ALLOW_INTERSPERSE_LOAD)
         OR ((Recinfo.ALLOW_INTERSPERSE_LOAD IS NULL)
            AND (p_Carrier_Service_Info.ALLOW_INTERSPERSE_LOAD is NULL)))
     AND ((Recinfo.MAX_LAYOVER_TIME = p_Carrier_Service_Info.MAX_LAYOVER_TIME )
         OR ((Recinfo.MAX_LAYOVER_TIME IS NULL)
            AND (p_Carrier_Service_Info.MAX_LAYOVER_TIME is NULL)))
     AND ((Recinfo.MIN_LAYOVER_TIME = p_Carrier_Service_Info.MIN_LAYOVER_TIME )
         OR ((Recinfo.MIN_LAYOVER_TIME IS NULL)
            AND (p_Carrier_Service_Info.MIN_LAYOVER_TIME is NULL)))
     AND ((Recinfo.MAX_TOTAL_DISTANCE_IN_24HR = p_Carrier_Service_Info.MAX_TOTAL_DISTANCE_IN_24HR)
         OR ((Recinfo.MAX_TOTAL_DISTANCE_IN_24HR IS NULL)
            AND (p_Carrier_Service_Info.MAX_TOTAL_DISTANCE_IN_24HR is NULL)))
     AND ((Recinfo.MAX_DRIVING_TIME_IN_24HR = p_Carrier_Service_Info.MAX_DRIVING_TIME_IN_24HR)
         OR ((Recinfo.MAX_DRIVING_TIME_IN_24HR IS NULL)
            AND (p_Carrier_Service_Info.MAX_DRIVING_TIME_IN_24HR is NULL)))
     AND ((Recinfo.MAX_DUTY_TIME_IN_24HR = p_Carrier_Service_Info.MAX_DUTY_TIME_IN_24HR )
         OR ((Recinfo.MAX_DUTY_TIME_IN_24HR IS NULL)
            AND (p_Carrier_Service_Info.MAX_DUTY_TIME_IN_24HR is NULL)))
     AND ((Recinfo.MAX_CM_DISTANCE = p_Carrier_Service_Info.MAX_CM_DISTANCE )
         OR ((Recinfo.MAX_CM_DISTANCE IS NULL)
            AND (p_Carrier_Service_Info.MAX_CM_DISTANCE is NULL)))
     AND ((Recinfo.MAX_CM_TIME = p_Carrier_Service_Info.MAX_CM_TIME)
         OR ((Recinfo.MAX_CM_TIME IS NULL)
            AND (p_Carrier_Service_Info.MAX_CM_TIME is NULL)))
     AND ((Recinfo.MAX_CM_DH_DISTANCE = p_Carrier_Service_Info.MAX_CM_DH_DISTANCE)
         OR ((Recinfo.MAX_CM_DH_DISTANCE IS NULL)
            AND (p_Carrier_Service_Info.MAX_CM_DH_DISTANCE is NULL)))
     AND ((Recinfo.MAX_SIZE_WIDTH = p_Carrier_Service_Info.MAX_SIZE_WIDTH )
         OR ((Recinfo.MAX_SIZE_WIDTH IS NULL)
            AND (p_Carrier_Service_Info.MAX_SIZE_WIDTH is NULL)))
     AND ((Recinfo.MAX_SIZE_HEIGHT = p_Carrier_Service_Info.MAX_SIZE_HEIGHT)
         OR ((Recinfo.MAX_SIZE_HEIGHT IS NULL)
            AND (p_Carrier_Service_Info.MAX_SIZE_HEIGHT is NULL)))
     AND ((Recinfo.MAX_SIZE_LENGTH = p_Carrier_Service_Info.MAX_SIZE_LENGTH )
         OR ((Recinfo.MAX_SIZE_LENGTH IS NULL)
            AND (p_Carrier_Service_Info.MAX_SIZE_LENGTH is NULL)))
     AND ((Recinfo.MIN_SIZE_WIDTH = p_Carrier_Service_Info.MIN_SIZE_WIDTH)
         OR ((Recinfo.MIN_SIZE_WIDTH IS NULL)
            AND (p_Carrier_Service_Info.MIN_SIZE_WIDTH is NULL)))
     AND ((Recinfo.MIN_SIZE_HEIGHT = p_Carrier_Service_Info.MIN_SIZE_HEIGHT)
         OR ((Recinfo.MIN_SIZE_HEIGHT IS NULL)
            AND (p_Carrier_Service_Info.MIN_SIZE_HEIGHT is NULL)))
     AND ((Recinfo.MIN_SIZE_LENGTH = p_Carrier_Service_Info.MIN_SIZE_LENGTH)
         OR ((Recinfo.MIN_SIZE_LENGTH IS NULL)
            AND (p_Carrier_Service_Info.MIN_SIZE_LENGTH is NULL)))
     AND ((Recinfo.MAX_OUT_OF_ROUTE = p_Carrier_Service_Info.MAX_OUT_OF_ROUTE)
         OR ((Recinfo.MAX_OUT_OF_ROUTE IS NULL)
            AND (p_Carrier_Service_Info.MAX_OUT_OF_ROUTE is NULL)))
     AND ((Recinfo.CM_FREE_DH_MILEAGE = p_Carrier_Service_Info.CM_FREE_DH_MILEAGE)
         OR ((Recinfo.CM_FREE_DH_MILEAGE IS NULL)
            AND (p_Carrier_Service_Info.CM_FREE_DH_MILEAGE is NULL)))
     AND ((Recinfo.MIN_CM_DISTANCE = p_Carrier_Service_Info.MIN_CM_DISTANCE)
         OR ((Recinfo.MIN_CM_DISTANCE IS NULL)
            AND (p_Carrier_Service_Info.MIN_CM_DISTANCE is NULL)))
     AND ((Recinfo.CM_FIRST_LOAD_DISCOUNT = p_Carrier_Service_Info.CM_FIRST_LOAD_DISCOUNT)
         OR ((Recinfo.CM_FIRST_LOAD_DISCOUNT IS NULL)
            AND (p_Carrier_Service_Info.CM_FIRST_LOAD_DISCOUNT is NULL)))
     AND ((Recinfo.MIN_CM_TIME = p_Carrier_Service_Info.MIN_CM_TIME)
         OR ((Recinfo.MIN_CM_TIME IS NULL)
            AND (p_Carrier_Service_Info.MIN_CM_TIME is NULL)))
     AND ((Recinfo.UNIT_RATE_BASIS = p_Carrier_Service_Info.UNIT_RATE_BASIS)
         OR ((Recinfo.UNIT_RATE_BASIS IS NULL)
            AND (p_Carrier_Service_Info.UNIT_RATE_BASIS is NULL)))
     AND ((Recinfo.DISTANCE_CALCULATION_METHOD = p_Carrier_Service_Info.DISTANCE_CALCULATION_METHOD)
         OR ((Recinfo.DISTANCE_CALCULATION_METHOD IS NULL)
            AND (p_Carrier_Service_Info.DISTANCE_CALCULATION_METHOD is NULL)))
     AND ((Recinfo.CM_RATE_VARIANT = p_Carrier_Service_Info.CM_RATE_VARIANT)
         OR ((Recinfo.CM_RATE_VARIANT IS NULL)
            AND (p_Carrier_Service_Info.CM_RATE_VARIANT is NULL)))
     AND ((Recinfo.ALLOW_CONTINUOUS_MOVE = p_Carrier_Service_Info.ALLOW_CONTINUOUS_MOVE)
         OR ((Recinfo.ALLOW_CONTINUOUS_MOVE IS NULL)
            AND (p_Carrier_Service_Info.ALLOW_CONTINUOUS_MOVE is NULL)))
     AND ((Recinfo.MAX_CM_DH_TIME = p_Carrier_Service_Info.MAX_CM_DH_TIME)
         OR ((Recinfo.MAX_CM_DH_TIME IS NULL)
            AND (p_Carrier_Service_Info.MAX_CM_DH_TIME is NULL)))
     AND ((Recinfo.ORIGIN_DSTN_SURCHARGE_LEVEL = p_Carrier_Service_Info.ORIGIN_DSTN_SURCHARGE_LEVEL)
         OR ((Recinfo.ORIGIN_DSTN_SURCHARGE_LEVEL IS NULL)
            AND (p_Carrier_Service_Info.ORIGIN_DSTN_SURCHARGE_LEVEL is NULL)))
      )
     AND ((Recinfo.UPDATE_MOT_SL = p_Carrier_Service_Info.UPDATE_MOT_SL)
         OR ((Recinfo.UPDATE_MOT_SL IS NULL)
            AND (p_Carrier_Service_Info.UPDATE_MOT_SL is NULL)))
   THEN
     --
     IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'All matched');
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
   ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
       IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_CHANGED');
       END IF;
      APP_EXCEPTION.Raise_Exception;
   END IF;

   OPEN C_lookup_row;
   FETCH C_lookup_row INTO lookupinfo;

   IF (C_lookup_row%NOTFOUND) THEN
      CLOSE C_lookup_row;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');
      WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
   END IF;
   CLOSE C_lookup_row;
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Before FND_LOOKUP_VALUES_PKG.LOCK_ROW');
   END IF;

   FND_LOOKUP_VALUES_PKG.LOCK_ROW(
        X_LOOKUP_TYPE => 'SHIP_METHOD',
        X_SECURITY_GROUP_ID => 0,
        X_VIEW_APPLICATION_ID => 3,
        X_LOOKUP_CODE => lookupinfo.LOOKUP_CODE,
        X_TAG => lookupinfo.TAG,
        X_ATTRIBUTE_CATEGORY => lookupinfo.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => lookupinfo.ATTRIBUTE1,
        X_ATTRIBUTE2 => lookupinfo.ATTRIBUTE2,
        X_ATTRIBUTE3 => lookupinfo.ATTRIBUTE3,
        X_ATTRIBUTE4 => lookupinfo.ATTRIBUTE4,
        X_ENABLED_FLAG => p_Carrier_Service_Info.Enabled_Flag,
        X_START_DATE_ACTIVE => lookupinfo.START_DATE_ACTIVE,
        X_END_DATE_ACTIVE => lookupinfo.END_DATE_ACTIVE,
        X_TERRITORY_CODE => lookupinfo.TERRITORY_CODE,
        X_ATTRIBUTE5 => lookupinfo.ATTRIBUTE5,
        X_ATTRIBUTE6 => lookupinfo.ATTRIBUTE6,
        X_ATTRIBUTE7 => lookupinfo.ATTRIBUTE7,
        X_ATTRIBUTE8 => lookupinfo.ATTRIBUTE8,
        X_ATTRIBUTE9 => lookupinfo.ATTRIBUTE9,
        X_ATTRIBUTE10 => lookupinfo.ATTRIBUTE10,
        X_ATTRIBUTE11 => lookupinfo.ATTRIBUTE11,
        X_ATTRIBUTE12 => lookupinfo.ATTRIBUTE12,
        X_ATTRIBUTE13 => lookupinfo.ATTRIBUTE13,
        X_ATTRIBUTE14 => lookupinfo.ATTRIBUTE14,
        X_ATTRIBUTE15 => lookupinfo.ATTRIBUTE15,
        X_MEANING => lookupinfo.MEANING,
        X_DESCRIPTION => lookupinfo.DESCRIPTION);


   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION

WHEN RECORD_LOCKED THEN

IF (C_Lock_Row%ISOPEN) THEN
CLOSE C_Lock_Row;
END IF;

IF (C_lookup_row%ISOPEN) THEN
CLOSE C_lookup_row;
END IF;

FND_MESSAGE.Set_Name('WSH', 'WSH_FORM_RECORD_IS_CHANGED');
app_exception.raise_exception;

     WHEN others THEN

IF (C_Lock_Row%ISOPEN) THEN
CLOSE C_Lock_Row;
END IF;

IF (C_lookup_row%ISOPEN) THEN
CLOSE C_lookup_row;
END IF;

	  x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          WSH_UTIL_CORE.Default_Handler('WSH_CARRIER_SERVICES_PKG.Lock_Carrier_Service',l_module_name);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
          END IF;
          --
END Lock_Carrier_Service;

PROCEDURE Update_Carrier_Service
(
    p_rowid                    IN     VARCHAR2
  , p_Carrier_Service_Info     IN     CSRecType  DEFAULT NULL
  , p_commit                   IN   VARCHAR2 DEFAULT FND_API.G_FALSE
  , x_Return_Status            OUT NOCOPY     VARCHAR2
  , x_position                 OUT NOCOPY     NUMBER
  , x_procedure                OUT NOCOPY     VARCHAR2
  , x_sqlerr                   OUT NOCOPY     VARCHAR2
  , x_sql_code                 OUT NOCOPY     VARCHAR2
  , x_exception_msg             OUT NOCOPY     VARCHAR2
)
IS

CURSOR C_lookup_row(p_ship_method_code VARCHAR2) IS
--Bug3330869    SELECT *
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
FROM   FND_LOOKUP_VALUES
where LOOKUP_TYPE = 'SHIP_METHOD'
and SECURITY_GROUP_ID = 0
and VIEW_APPLICATION_ID = 3
and LOOKUP_CODE = p_ship_method_code;

CURSOR C_freight_code(x_rowid VARCHAR2) IS
SELECT freight_code
FROM WSH_CARRIERS car,WSH_CARRIER_SERVICES carser
WHERE carser.carrier_id = car.carrier_id
and carser.rowid=x_rowid;

l_freight_code VARCHAR(100);

lookupinfo C_lookup_row%ROWTYPE;
others              EXCEPTION;
l_position          NUMBER;
l_procedure         VARCHAR2(100);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CARRIER_SERVICE';
--
BEGIN
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
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_position := 10;
   l_procedure := 'Updating WSH_CARRIER_SERVICES';

   UPDATE wsh_carrier_services
   SET
       service_level       = p_Carrier_Service_Info.Service_level,
       mode_of_transport   = p_Carrier_Service_Info.mode_of_transport,
       min_sl_time         = p_Carrier_Service_Info.min_sl_time,
       max_sl_time         = p_Carrier_Service_Info.max_sl_time,
       sl_time_uom         = p_Carrier_Service_Info.sl_time_uom,
       enabled_flag         = p_Carrier_Service_Info.Enabled_Flag,
       web_enabled         = p_Carrier_Service_Info.Web_Enabled,
       ship_method_code    = p_Carrier_Service_Info.Ship_Method_Code,
       ship_method_meaning = p_Carrier_Service_Info.Ship_Method_Meaning,
       attribute_category  = p_Carrier_Service_Info.Attribute_Category,
       attribute1          = p_Carrier_Service_Info.Attribute1,
       attribute2          = p_Carrier_Service_Info.Attribute2,
       attribute3          = p_Carrier_Service_Info.Attribute3,
       attribute4          = p_Carrier_Service_Info.Attribute4,
       attribute5          = p_Carrier_Service_Info.Attribute5,
       attribute6          = p_Carrier_Service_Info.Attribute6,
       attribute7          = p_Carrier_Service_Info.Attribute7,
       attribute8          = p_Carrier_Service_Info.Attribute8,
       attribute9          = p_Carrier_Service_Info.Attribute9,
       attribute10         = p_Carrier_Service_Info.Attribute10,
       attribute11         = p_Carrier_Service_Info.Attribute11,
       attribute12         = p_Carrier_Service_Info.Attribute12,
       attribute13         = p_Carrier_Service_Info.Attribute13,
       attribute14         = p_Carrier_Service_Info.Attribute14,
       attribute15         = p_Carrier_Service_Info.Attribute15,
       last_update_date    = p_Carrier_Service_Info.Last_Update_Date,
       last_updated_by     = p_Carrier_Service_Info.Last_Updated_By,
       last_update_login   = p_Carrier_Service_Info.Last_Update_Login,
       -- Pack J Enhancement
       MAX_NUM_STOPS_PERMITTED        = p_Carrier_Service_Info.MAX_NUM_STOPS_PERMITTED,
       MAX_TOTAL_DISTANCE             = p_Carrier_Service_Info.MAX_TOTAL_DISTANCE,
       MAX_TOTAL_TIME                 = p_Carrier_Service_Info.MAX_TOTAL_TIME,
       ALLOW_INTERSPERSE_LOAD         = p_Carrier_Service_Info.ALLOW_INTERSPERSE_LOAD,
       MAX_LAYOVER_TIME               = p_Carrier_Service_Info.MAX_LAYOVER_TIME,
       MIN_LAYOVER_TIME               = p_Carrier_Service_Info.MIN_LAYOVER_TIME,
       MAX_TOTAL_DISTANCE_IN_24HR     = p_Carrier_Service_Info.MAX_TOTAL_DISTANCE_IN_24HR,
       MAX_DRIVING_TIME_IN_24HR       = p_Carrier_Service_Info.MAX_DRIVING_TIME_IN_24HR,
       MAX_DUTY_TIME_IN_24HR          = p_Carrier_Service_Info.MAX_DUTY_TIME_IN_24HR,
       MAX_CM_DISTANCE                = p_Carrier_Service_Info.MAX_CM_DISTANCE,
       MAX_CM_TIME                    = p_Carrier_Service_Info.MAX_CM_TIME,
       MAX_CM_DH_DISTANCE             = p_Carrier_Service_Info.MAX_CM_DH_DISTANCE,
       MAX_SIZE_WIDTH                 = p_Carrier_Service_Info.MAX_SIZE_WIDTH,
       MAX_SIZE_HEIGHT                = p_Carrier_Service_Info.MAX_SIZE_HEIGHT,
       MAX_SIZE_LENGTH                = p_Carrier_Service_Info.MAX_SIZE_LENGTH,
       MIN_SIZE_WIDTH                 = p_Carrier_Service_Info.MIN_SIZE_WIDTH,
       MIN_SIZE_HEIGHT                = p_Carrier_Service_Info.MIN_SIZE_HEIGHT,
       MIN_SIZE_LENGTH                = p_Carrier_Service_Info.MIN_SIZE_LENGTH,
       MAX_OUT_OF_ROUTE               = p_Carrier_Service_Info.MAX_OUT_OF_ROUTE,
       CM_FREE_DH_MILEAGE             = p_Carrier_Service_Info.CM_FREE_DH_MILEAGE,
       MIN_CM_DISTANCE                = p_Carrier_Service_Info.MIN_CM_DISTANCE,
       CM_FIRST_LOAD_DISCOUNT         = p_Carrier_Service_Info.CM_FIRST_LOAD_DISCOUNT,
       MIN_CM_TIME                    = p_Carrier_Service_Info.MIN_CM_TIME,
       UNIT_RATE_BASIS                = p_Carrier_Service_Info.UNIT_RATE_BASIS,
       CM_RATE_VARIANT                = p_Carrier_Service_Info.CM_RATE_VARIANT,
       DISTANCE_CALCULATION_METHOD    = p_Carrier_Service_Info.DISTANCE_CALCULATION_METHOD,
       ALLOW_CONTINUOUS_MOVE          = p_Carrier_Service_Info.ALLOW_CONTINUOUS_MOVE,
       MAX_CM_DH_TIME                 = p_Carrier_Service_Info.MAX_CM_DH_TIME,
       ORIGIN_DSTN_SURCHARGE_LEVEL    = p_Carrier_Service_Info.ORIGIN_DSTN_SURCHARGE_LEVEL,
       UPDATE_MOT_SL                  = p_Carrier_Service_Info.UPDATE_MOT_SL
   WHERE rowid = p_rowid;

   IF (SQL%NOTFOUND) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'SQL%NOTFOUND');
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      RAISE NO_DATA_FOUND;
   END IF;

   l_position := 20;
   l_procedure := 'Fetching from cursor';

   l_procedure := p_carrier_service_info.ship_method_code;
   OPEN C_lookup_row(p_carrier_service_info.ship_method_code);
   FETCH C_lookup_row INTO lookupinfo;

      IF (C_lookup_row%NOTFOUND) THEN
         CLOSE C_lookup_row;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'C_lookup_row%NOTFOUND');
           WSH_DEBUG_SV.log(l_module_name, 'Cursor opened successfully called from update_carrier_service procedure'); --Bug3330869
         END IF;
         RAISE NO_DATA_FOUND;
      END IF;

   CLOSE C_lookup_row;

   l_position := 30;
   l_procedure := 'Updating FND_LOOKUP_VALUES';

   -----------------------------------------------------
   --  Bug 2361153 : Ship_Method_Meaning is passed to the
   --  X_DESCRIPTION parameter.
   -----------------------------------------------------

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
    X_ENABLED_FLAG        => p_Carrier_Service_Info.ENABLED_FLAG,
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
    X_MEANING             => p_Carrier_Service_Info.SHIP_METHOD_MEANING,
    X_DESCRIPTION         => p_Carrier_Service_Info.SHIP_METHOD_MEANING,
    X_LAST_UPDATE_DATE    => sysdate,
    X_LAST_UPDATED_BY     => FND_GLOBAL.USER_ID,
    X_LAST_UPDATE_LOGIN   => FND_GLOBAL.LOGIN_ID
   );

  l_position := 40;
  l_procedure := 'Updating WSH_CARRIER_SHIP_METHODS';
   OPEN C_freight_code(p_rowid);
   FETCH C_freight_code INTO l_freight_code;
   IF C_freight_code%found THEN
     UPDATE WSH_CARRIER_SHIP_METHODS
      SET WEB_ENABLED  =  p_Carrier_Service_Info.Web_Enabled,
          LAST_UPDATE_DATE =sysdate,
          LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
          ATTRIBUTE1 = p_Carrier_Service_Info.Attribute1,
          ATTRIBUTE2 = p_Carrier_Service_Info.Attribute2,
          ATTRIBUTE3 = p_Carrier_Service_Info.Attribute3,
          ATTRIBUTE4 = p_Carrier_Service_Info.Attribute4,
          ATTRIBUTE5 = p_Carrier_Service_Info.Attribute5,
          ATTRIBUTE6 = p_Carrier_Service_Info.Attribute6,
          ATTRIBUTE7 = p_Carrier_Service_Info.Attribute7,
          ATTRIBUTE8 = p_Carrier_Service_Info.Attribute8,
          ATTRIBUTE9 = p_Carrier_Service_Info.Attribute9,
          ATTRIBUTE10 = p_Carrier_Service_Info.Attribute10,
          ATTRIBUTE11 = p_Carrier_Service_Info.Attribute11,
          ATTRIBUTE12 = p_Carrier_Service_Info.Attribute12,
          ATTRIBUTE13 = p_Carrier_Service_Info.Attribute13,
          ATTRIBUTE14 = p_Carrier_Service_Info.Attribute14,
          ATTRIBUTE15 = p_Carrier_Service_Info.Attribute15
     WHERE  FREIGHT_CODE =  l_freight_code
     AND SHIP_METHOD_CODE =  p_Carrier_Service_Info.Ship_Method_Code;
   END IF;
   CLOSE C_freight_code;

   IF FND_API.To_Boolean(p_commit) THEN
     COMMIT;
   END IF;
   --

   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'LOOKUP_CODE',lookupinfo.LOOKUP_CODE);
       WSH_DEBUG_SV.log(l_module_name,'TAG',lookupinfo.TAG);
       WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE_CATEGORY',
                                             lookupinfo.ATTRIBUTE_CATEGORY);
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
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
         END IF;
         --
       WHEN OTHERS THEN
         x_exception_msg := 'EXCEPTION : Others';
         x_position := l_position;
         x_procedure := l_procedure;
         x_sqlerr    := sqlerrm;
         x_sql_code   := sqlcode;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Update_Carrier_Service;


PROCEDURE Car_Ser_Unassign_AllOrg(
    p_carrier_service_id    IN  NUMBER
  , p_ship_method_code      IN  VARCHAR2
  , p_freight_code          IN  VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_exception_msg         OUT NOCOPY VARCHAR2
  , x_position              OUT NOCOPY NUMBER
  , x_procedure             OUT NOCOPY VARCHAR2
  , x_sqlerr                OUT NOCOPY VARCHAR2
  , x_sql_code              OUT NOCOPY VARCHAR2
) IS

l_position                      NUMBER;
l_procedure                     VARCHAR2(50);
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CAR_SER_UNASSIGN_ALLORG';

BEGIN
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_SERVICE_ID',p_carrier_service_id);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',p_ship_method_code);
    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',p_freight_code);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_position  := 10;
  l_procedure := 'Updating WSH_CARRIER_SHIP_METHODS';

  UPDATE wsh_carrier_ship_methods
  SET enabled_flag = 'N'
  WHERE  ship_method_code = p_ship_method_code
  AND freight_code = p_freight_code;

  l_position  := 20;
  l_procedure := 'Updating WSH_ORG_CARRIER_SERVICES';

  UPDATE wsh_org_carrier_services
  SET enabled_flag = 'N'
  WHERE carrier_service_id= p_carrier_service_id;

  --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  EXCEPTION
    WHEN OTHERS THEN
    x_exception_msg := 'EXCEPTION : Others';
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

END Car_Ser_Unassign_AllOrg;


END WSH_CARRIER_SERVICES_PKG;

/
