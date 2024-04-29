--------------------------------------------------------
--  DDL for Package Body WSH_FREIGHT_COSTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FREIGHT_COSTS_GRP" as
/* $Header: WSHFCGPB.pls 120.6.12010000.7 2010/02/25 16:54:30 sankarun ship $ */
-- standard global constants
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_FREIGHT_COSTS_GRP';


--===================
-- PROCEDURES
--===================
PROCEDURE Validate_freight_cost_type(
  p_freight_cost_type        	IN 	 VARCHAR2
, x_freight_cost_type_id		IN OUT NOCOPY  NUMBER
, x_return_status                OUT NOCOPY  VARCHAR2
)
IS
invalid_type        EXCEPTION;
l_type_id           NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_FREIGHT_COST_TYPE';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE',P_FREIGHT_COST_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'X_FREIGHT_COST_TYPE_ID',X_FREIGHT_COST_TYPE_ID);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (x_freight_cost_type_id IS NULL) THEN
		IF (p_freight_cost_type <> FND_API.G_MISS_CHAR) THEN
			SELECT freight_cost_type_id INTO x_freight_cost_type_id
			FROM wsh_freight_cost_types
			WHERE name = p_freight_cost_type;
			IF (SQL%NOTFOUND) THEN
				RAISE invalid_type;
			END IF;
		END IF;
	ELSE
		SELECT freight_cost_type_id INTO l_type_id
		FROM wsh_freight_cost_types
		WHERE freight_cost_type_id = x_freight_cost_type_id;
		IF (SQL%NOTFOUND) THEN
			RAISE invalid_type;
		END IF;
	END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,
                             'x_freight_cost_type_id',x_freight_cost_type_id);
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
	EXCEPTION
		WHEN No_Data_Found THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
			END IF;
			--
		WHEN Invalid_Type THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TYPE');
			END IF;
			--
		WHEN others THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                         --
                         IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                         END IF;
                         --
END validate_freight_cost_type;

PROCEDURE Delete_Freight_Costs (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_pub_freight_costs		IN     WSH_FREIGHT_COSTS_GRP.PubFreightCostRecType
)
IS
l_return_status            VARCHAR2(30);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FREIGHT_COSTS';
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
       WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
       WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	WSH_FREIGHT_COSTS_PVT.Delete_freight_cost(
		p_rowid       			=>   	NULL,
		p_freight_cost_id   	=>   	p_pub_freight_costs.freight_cost_id,
		x_return_status     	=>   	x_return_status);

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
	EXCEPTION
	WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     		FND_MSG_PUB.Add_Exc_Msg (
				G_PKG_NAME,
				'_x_'
				);
		END IF;
     	--  Get message count and data
     FND_MSG_PUB.Count_And_Get (
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Delete_Freight_Costs;


--Harmonizing Project I :heali
PROCEDURE map_freightgrp_to_pvt(
   p_grp_freight_rec IN PubFreightCostRecType,
   x_pvt_freight_rec OUT NOCOPY WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type,
   x_return_status OUT NOCOPY VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME|| '.' || 'MAP_FREIGHTPUB_TO_PVT';
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
       WSH_DEBUG_SV.log(l_module_name,'p_grp_freight_rec.FREIGHT_COST_ID',p_grp_freight_rec.FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_grp_freight_rec.FREIGHT_COST_TYPE_ID',p_grp_freight_rec.FREIGHT_COST_TYPE_ID);
   END IF;
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_pvt_freight_rec.FREIGHT_COST_ID		 := p_grp_freight_rec.FREIGHT_COST_ID;
  x_pvt_freight_rec.FREIGHT_COST_TYPE_ID	 := p_grp_freight_rec.FREIGHT_COST_TYPE_ID;
  x_pvt_freight_rec.UNIT_AMOUNT			 := p_grp_freight_rec.UNIT_AMOUNT;
  x_pvt_freight_rec.CALCULATION_METHOD		 := p_grp_freight_rec.CALCULATION_METHOD;
  x_pvt_freight_rec.UOM				 := p_grp_freight_rec.UOM;
  x_pvt_freight_rec.QUANTITY			 := p_grp_freight_rec.QUANTITY;
  x_pvt_freight_rec.TOTAL_AMOUNT		 := p_grp_freight_rec.TOTAL_AMOUNT;
  x_pvt_freight_rec.CURRENCY_CODE		 := p_grp_freight_rec.CURRENCY_CODE;
  x_pvt_freight_rec.CONVERSION_DATE		 := p_grp_freight_rec.CONVERSION_DATE;
  x_pvt_freight_rec.CONVERSION_RATE		 := p_grp_freight_rec.CONVERSION_RATE;
  x_pvt_freight_rec.CONVERSION_TYPE_CODE	 := p_grp_freight_rec.CONVERSION_TYPE_CODE;
  x_pvt_freight_rec.TRIP_ID			 := p_grp_freight_rec.TRIP_ID;
  x_pvt_freight_rec.STOP_ID			 := p_grp_freight_rec.STOP_ID;
  x_pvt_freight_rec.DELIVERY_ID			 := p_grp_freight_rec.DELIVERY_ID;
  x_pvt_freight_rec.DELIVERY_LEG_ID		 := p_grp_freight_rec.DELIVERY_LEG_ID;
  x_pvt_freight_rec.DELIVERY_DETAIL_ID		 := p_grp_freight_rec.DELIVERY_DETAIL_ID;
  x_pvt_freight_rec.ATTRIBUTE_CATEGORY		 := p_grp_freight_rec.ATTRIBUTE_CATEGORY;
  x_pvt_freight_rec.ATTRIBUTE1		   	 := p_grp_freight_rec.ATTRIBUTE1;
  x_pvt_freight_rec.ATTRIBUTE2		   	 := p_grp_freight_rec.ATTRIBUTE2;
  x_pvt_freight_rec.ATTRIBUTE3		   	 := p_grp_freight_rec.ATTRIBUTE3;
  x_pvt_freight_rec.ATTRIBUTE4		   	 := p_grp_freight_rec.ATTRIBUTE4;
  x_pvt_freight_rec.ATTRIBUTE5			 := p_grp_freight_rec.ATTRIBUTE5;
  x_pvt_freight_rec.ATTRIBUTE6			 := p_grp_freight_rec.ATTRIBUTE6;
  x_pvt_freight_rec.ATTRIBUTE7			 := p_grp_freight_rec.ATTRIBUTE7;
  x_pvt_freight_rec.ATTRIBUTE8			 := p_grp_freight_rec.ATTRIBUTE8;
  x_pvt_freight_rec.ATTRIBUTE9			 := p_grp_freight_rec.ATTRIBUTE9;
  x_pvt_freight_rec.ATTRIBUTE10			 := p_grp_freight_rec.ATTRIBUTE10;
  x_pvt_freight_rec.ATTRIBUTE11			 := p_grp_freight_rec.ATTRIBUTE11;
  x_pvt_freight_rec.ATTRIBUTE12			 := p_grp_freight_rec.ATTRIBUTE12;
  x_pvt_freight_rec.ATTRIBUTE13			 := p_grp_freight_rec.ATTRIBUTE13;
  x_pvt_freight_rec.ATTRIBUTE14			 := p_grp_freight_rec.ATTRIBUTE14;
  x_pvt_freight_rec.ATTRIBUTE15			 := p_grp_freight_rec.ATTRIBUTE15;
  x_pvt_freight_rec.CREATION_DATE		 := p_grp_freight_rec.CREATION_DATE;
  x_pvt_freight_rec.CREATED_BY		   	 := p_grp_freight_rec.CREATED_BY;
  x_pvt_freight_rec.LAST_UPDATE_DATE		 := p_grp_freight_rec.LAST_UPDATE_DATE;
  x_pvt_freight_rec.LAST_UPDATED_BY		 := p_grp_freight_rec.LAST_UPDATED_BY;
  x_pvt_freight_rec.LAST_UPDATE_LOGIN		 := p_grp_freight_rec.LAST_UPDATE_LOGIN;
  x_pvt_freight_rec.PROGRAM_APPLICATION_ID	 := p_grp_freight_rec.PROGRAM_APPLICATION_ID;
  x_pvt_freight_rec.PROGRAM_ID			 := p_grp_freight_rec.PROGRAM_ID;
  x_pvt_freight_rec.PROGRAM_UPDATE_DATE		 := p_grp_freight_rec.PROGRAM_UPDATE_DATE;
  x_pvt_freight_rec.REQUEST_ID			 := p_grp_freight_rec.REQUEST_ID;
  x_pvt_freight_rec.PRICING_LIST_HEADER_ID	 := p_grp_freight_rec.PRICING_LIST_HEADER_ID;
  x_pvt_freight_rec.PRICING_LIST_LINE_ID	 := p_grp_freight_rec.PRICING_LIST_LINE_ID;
  x_pvt_freight_rec.APPLIED_TO_CHARGE_ID	 := p_grp_freight_rec.APPLIED_TO_CHARGE_ID;
  x_pvt_freight_rec.CHARGE_UNIT_VALUE		 := p_grp_freight_rec.CHARGE_UNIT_VALUE;
  x_pvt_freight_rec.CHARGE_SOURCE_CODE		 := p_grp_freight_rec.CHARGE_SOURCE_CODE;
  x_pvt_freight_rec.LINE_TYPE_CODE		 := p_grp_freight_rec.LINE_TYPE_CODE;
  x_pvt_freight_rec.ESTIMATED_FLAG	 	 := p_grp_freight_rec.ESTIMATED_FLAG;
  x_pvt_freight_rec.FREIGHT_CODE		 := p_grp_freight_rec.FREIGHT_CODE;
  x_pvt_freight_rec.TRIP_NAME			 := p_grp_freight_rec.TRIP_NAME;
  x_pvt_freight_rec.DELIVERY_NAME		 := p_grp_freight_rec.DELIVERY_NAME;
  x_pvt_freight_rec.FREIGHT_COST_TYPE		 := p_grp_freight_rec.FREIGHT_COST_TYPE;
  x_pvt_freight_rec.STOP_LOCATION_ID		 := p_grp_freight_rec.STOP_LOCATION_ID;
  x_pvt_freight_rec.PLANNED_DEP_DATE 		 := p_grp_freight_rec.PLANNED_DEP_DATE;
  x_pvt_freight_rec.COMMODITY_CATEGORY_ID	 := p_grp_freight_rec.COMMODITY_CATEGORY_ID;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.map_freightgrp_to_pvt',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END map_freightgrp_to_pvt;


PROCEDURE Get_Disabled_List  (
  p_freight_rec          IN  WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type
, p_action               IN  VARCHAR2 DEFAULT 'UPDATE'
, p_caller               IN  VARCHAR2
, x_freight_rec          OUT NOCOPY WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';

  l_disabled_list               WSH_UTIL_CORE.column_tab_type;
  l_db_col_rec                  WSH_TRIPS_PVT.trip_rec_type;
  l_return_status               VARCHAR2(30);
  l_field_name                  VARCHAR2(100);
  l_conversion_type             VARCHAR2(100); --Bugfix 8736256

  CURSOR c_tbl_rec IS
  SELECT  FREIGHT_COST_ID
	, FREIGHT_COST_TYPE_ID
	, UNIT_AMOUNT
	, CALCULATION_METHOD
	, UOM
	, QUANTITY
	, TOTAL_AMOUNT
	, CURRENCY_CODE
	, CONVERSION_DATE
	, CONVERSION_RATE
	, CONVERSION_TYPE_CODE
	, TRIP_ID
	, STOP_ID
	, DELIVERY_ID
	, DELIVERY_LEG_ID
	, DELIVERY_DETAIL_ID
	, ATTRIBUTE_CATEGORY
	, ATTRIBUTE1
	, ATTRIBUTE2
	, ATTRIBUTE3
	, ATTRIBUTE4
	, ATTRIBUTE5
	, ATTRIBUTE6
	, ATTRIBUTE7
	, ATTRIBUTE8
	, ATTRIBUTE9
	, ATTRIBUTE10
	, ATTRIBUTE11
	, ATTRIBUTE12
	, ATTRIBUTE13
	, ATTRIBUTE14
	, ATTRIBUTE15
	, CREATION_DATE
	, CREATED_BY
	, LAST_UPDATE_DATE
	, LAST_UPDATED_BY
	, LAST_UPDATE_LOGIN
	, PROGRAM_APPLICATION_ID
	, PROGRAM_ID
	, PROGRAM_UPDATE_DATE
	, REQUEST_ID
	, PRICING_LIST_HEADER_ID
	, PRICING_LIST_LINE_ID
	, APPLIED_TO_CHARGE_ID
	, CHARGE_UNIT_VALUE
	, CHARGE_SOURCE_CODE
	, LINE_TYPE_CODE
	, ESTIMATED_FLAG
	, FREIGHT_CODE
	, NULL TRIP_NAME
	, NULL DELIVERY_NAME
	, NULL FREIGHT_COST_TYPE
	, NULL STOP_LOCATION_ID
	, NULL PLANNED_DEP_DATE
        , COMMODITY_CATEGORY_ID
        , BILLABLE_QUANTITY
        , BILLABLE_UOM
        , BILLABLE_BASIS
  FROM  wsh_freight_costs
  WHERE FREIGHT_COST_ID= p_freight_rec.freight_cost_id;

l_freight_rec	WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;

e_dp_no_entity EXCEPTION;
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
      WSH_DEBUG_SV.log(l_module_name,'freight_cost_id',p_freight_rec.freight_cost_id);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  p_action = 'UPDATE' THEN
     OPEN c_tbl_rec;
     FETCH c_tbl_rec INTO x_freight_rec;
       IF c_tbl_rec%NOTFOUND THEN
          CLOSE c_tbl_rec;
          RAISE e_dp_no_entity;
       END IF;
     CLOSE c_tbl_rec;
  END IF;

  IF p_action = 'CREATE' THEN
    x_freight_rec.CREATION_DATE:= SYSDATE;
    x_freight_rec.CREATED_BY:= FND_GLOBAL.USER_ID;

    -- Standalone TPW FP bug 8579149
    -- Found a regression of the bug 8736256 while working in TPW FP bug
    -- Moving the fix done has a part of bug 8736256 inside if loop,
    -- validating only if conversion_type_code is not null
    --Bug 8640930
    IF NOT(nvl(p_freight_rec.conversion_type_code,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR ) THEN

      --Bugfix 8736256 Start -- Validate Conversion Type Code
       BEGIN
           SELECT conversion_type INTO l_conversion_type
           FROM gl_daily_conversion_types
           WHERE conversion_type = p_freight_rec.conversion_type_code;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN

			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occurred for conversion type.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
			END IF;

       END;
       --Bugfix 8736256 End

       x_freight_rec.CONVERSION_TYPE_CODE:=  p_freight_rec.conversion_type_code;
       x_freight_rec.CONVERSION_DATE:= SYSDATE;
    END IF;

  END IF;

  x_freight_rec.LAST_UPDATE_DATE:= SYSDATE;
  x_freight_rec.LAST_UPDATED_BY:= FND_GLOBAL.USER_ID;
  x_freight_rec.LAST_UPDATE_LOGIN:= FND_GLOBAL.USER_ID;


     IF ( p_freight_rec.FREIGHT_COST_TYPE_ID <> FND_API.G_MISS_NUM ) THEN
        x_freight_rec.FREIGHT_COST_TYPE_ID := p_freight_rec.FREIGHT_COST_TYPE_ID;
     END IF;
     IF ( p_freight_rec.UNIT_AMOUNT <> FND_API.G_MISS_NUM
          OR p_freight_rec.UNIT_AMOUNT IS NULL ) THEN
        x_freight_rec.UNIT_AMOUNT:= p_freight_rec.UNIT_AMOUNT;
     END IF;
     IF ( p_freight_rec.CALCULATION_METHOD <> FND_API.G_MISS_CHAR
          OR p_freight_rec.CALCULATION_METHOD IS NULL ) THEN
        x_freight_rec.CALCULATION_METHOD:= p_freight_rec.CALCULATION_METHOD;
     END IF;
     IF ( p_freight_rec.UOM <> FND_API.G_MISS_CHAR
          OR p_freight_rec.UOM IS NULL ) THEN
        x_freight_rec.UOM:= p_freight_rec.UOM;
     END IF;
     IF ( p_freight_rec.QUANTITY <> FND_API.G_MISS_NUM
          OR p_freight_rec.QUANTITY IS NULL) THEN
        x_freight_rec.QUANTITY:= p_freight_rec.QUANTITY;
     END IF;
     IF ( p_freight_rec.TOTAL_AMOUNT <> FND_API.G_MISS_NUM
          OR p_freight_rec.TOTAL_AMOUNT IS NULL) THEN
        x_freight_rec.TOTAL_AMOUNT:= p_freight_rec.TOTAL_AMOUNT;
     END IF;
     IF ( p_freight_rec.CURRENCY_CODE <> FND_API.G_MISS_CHAR
          OR p_freight_rec.CURRENCY_CODE IS NULL) THEN
        x_freight_rec.CURRENCY_CODE:= p_freight_rec.CURRENCY_CODE;
     END IF;
     IF ( p_freight_rec.CONVERSION_RATE <> FND_API.G_MISS_NUM
          OR p_freight_rec.CONVERSION_RATE IS NULL) THEN
        x_freight_rec.CONVERSION_RATE:= p_freight_rec.CONVERSION_RATE;
     END IF;
     IF ( p_freight_rec.TRIP_ID <> FND_API.G_MISS_NUM
          OR p_freight_rec.TRIP_ID IS NULL) THEN
        x_freight_rec.TRIP_ID:= p_freight_rec.TRIP_ID;
     END IF;

     IF ( p_freight_rec.STOP_ID <> FND_API.G_MISS_NUM
          OR  p_freight_rec.STOP_ID IS NULL) THEN
        x_freight_rec.STOP_ID:= p_freight_rec.STOP_ID;
     END IF;

     IF ( p_freight_rec.DELIVERY_ID <> FND_API.G_MISS_NUM
          OR p_freight_rec.DELIVERY_ID IS NULL) THEN
        x_freight_rec.DELIVERY_ID:= p_freight_rec.DELIVERY_ID;
     END IF;

     IF ( p_freight_rec.DELIVERY_LEG_ID <> FND_API.G_MISS_NUM
         OR p_freight_rec.DELIVERY_LEG_ID IS NULL) THEN
        x_freight_rec.DELIVERY_LEG_ID:= p_freight_rec.DELIVERY_LEG_ID;
     END IF;
     IF ( p_freight_rec.DELIVERY_DETAIL_ID <> FND_API.G_MISS_NUM
          OR p_freight_rec.DELIVERY_DETAIL_ID IS NULL) THEN
        x_freight_rec.DELIVERY_DETAIL_ID:= p_freight_rec.DELIVERY_DETAIL_ID;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE_CATEGORY IS NULL) THEN
        x_freight_rec.ATTRIBUTE_CATEGORY:= p_freight_rec.ATTRIBUTE_CATEGORY;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE1 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE1 IS NULL) THEN
        x_freight_rec.ATTRIBUTE1:= p_freight_rec.ATTRIBUTE1;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE2 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE2 IS NULL) THEN
        x_freight_rec.ATTRIBUTE2:= p_freight_rec.ATTRIBUTE2;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE3 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE3 IS NULL) THEN
        x_freight_rec.ATTRIBUTE3:= p_freight_rec.ATTRIBUTE3;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE4 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE4 IS NULL) THEN
        x_freight_rec.ATTRIBUTE4:= p_freight_rec.ATTRIBUTE4;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE5 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE5 IS NULL) THEN
        x_freight_rec.ATTRIBUTE5:= p_freight_rec.ATTRIBUTE5;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE6 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE6 IS NULL) THEN
        x_freight_rec.ATTRIBUTE6:= p_freight_rec.ATTRIBUTE6;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE7 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE7 IS NULL) THEN
        x_freight_rec.ATTRIBUTE7:= p_freight_rec.ATTRIBUTE7;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE8 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE8 IS NULL) THEN
        x_freight_rec.ATTRIBUTE8:= p_freight_rec.ATTRIBUTE8;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE9 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE9 IS NULL) THEN
        x_freight_rec.ATTRIBUTE9:= p_freight_rec.ATTRIBUTE9;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE10 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE10 IS NULL) THEN
        x_freight_rec.ATTRIBUTE10:= p_freight_rec.ATTRIBUTE10;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE11 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE11 IS NULL) THEN
        x_freight_rec.ATTRIBUTE11:= p_freight_rec.ATTRIBUTE11;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE12 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE12 IS NULL) THEN
        x_freight_rec.ATTRIBUTE12:= p_freight_rec.ATTRIBUTE12;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE13 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE13 IS NULL) THEN
        x_freight_rec.ATTRIBUTE13:= p_freight_rec.ATTRIBUTE13;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE14 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE14 IS NULL) THEN
        x_freight_rec.ATTRIBUTE14:= p_freight_rec.ATTRIBUTE14;
     END IF;
     IF ( p_freight_rec.ATTRIBUTE15 <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ATTRIBUTE15 IS NULL) THEN
        x_freight_rec.ATTRIBUTE15:= p_freight_rec.ATTRIBUTE15;
     END IF;

     IF ( p_freight_rec.PROGRAM_APPLICATION_ID <> FND_API.G_MISS_NUM
         OR p_freight_rec.PROGRAM_APPLICATION_ID IS NULL) THEN
        x_freight_rec.PROGRAM_APPLICATION_ID:= p_freight_rec.PROGRAM_APPLICATION_ID;
     END IF;
     IF ( p_freight_rec.PROGRAM_ID <> FND_API.G_MISS_NUM
          OR p_freight_rec.PROGRAM_ID  IS NULL) THEN
        x_freight_rec.PROGRAM_ID:= p_freight_rec.PROGRAM_ID;
     END IF;
     IF ( p_freight_rec.PROGRAM_UPDATE_DATE <> FND_API.G_MISS_DATE
          OR p_freight_rec.PROGRAM_UPDATE_DATE IS NULL) THEN
        x_freight_rec.PROGRAM_UPDATE_DATE:= p_freight_rec.PROGRAM_UPDATE_DATE;
     END IF;
     IF ( p_freight_rec.REQUEST_ID <> FND_API.G_MISS_NUM
          OR p_freight_rec.REQUEST_ID IS NULL) THEN
        x_freight_rec.REQUEST_ID:= p_freight_rec.REQUEST_ID;
     END IF;
     IF ( p_freight_rec.FREIGHT_CODE <> FND_API.G_MISS_CHAR
          OR p_freight_rec.FREIGHT_CODE IS NULL) THEN
        x_freight_rec.FREIGHT_CODE:= p_freight_rec.FREIGHT_CODE;
     END IF;
     IF ( p_freight_rec.LINE_TYPE_CODE <> FND_API.G_MISS_CHAR
          OR p_freight_rec.LINE_TYPE_CODE IS NULL) THEN
        x_freight_rec.LINE_TYPE_CODE:= p_freight_rec.FREIGHT_CODE;
     END IF;
     IF ( p_freight_rec.PRICING_LIST_HEADER_ID <> FND_API.G_MISS_NUM
         OR p_freight_rec.PRICING_LIST_HEADER_ID IS NULL) THEN
        x_freight_rec.PRICING_LIST_HEADER_ID:= p_freight_rec.PRICING_LIST_HEADER_ID;
     END IF;
     IF ( p_freight_rec.PRICING_LIST_LINE_ID <> FND_API.G_MISS_NUM
          OR p_freight_rec.PRICING_LIST_LINE_ID IS NULL) THEN
        x_freight_rec.PRICING_LIST_LINE_ID:= p_freight_rec.PRICING_LIST_LINE_ID;
     END IF;
     IF ( p_freight_rec.APPLIED_TO_CHARGE_ID <> FND_API.G_MISS_NUM
         OR p_freight_rec.APPLIED_TO_CHARGE_ID IS NULL) THEN
        x_freight_rec.APPLIED_TO_CHARGE_ID:= p_freight_rec.APPLIED_TO_CHARGE_ID;
     END IF;
     IF ( p_freight_rec.CHARGE_UNIT_VALUE <> FND_API.G_MISS_NUM
         OR p_freight_rec.CHARGE_UNIT_VALUE IS NULL) THEN
        x_freight_rec.CHARGE_UNIT_VALUE:= p_freight_rec.CHARGE_UNIT_VALUE;
     END IF;
     IF ( p_freight_rec.CHARGE_SOURCE_CODE <> FND_API.G_MISS_CHAR
         OR p_freight_rec.CHARGE_SOURCE_CODE IS NULL) THEN
        x_freight_rec.CHARGE_SOURCE_CODE:= p_freight_rec.CHARGE_SOURCE_CODE;
     END IF;
     IF ( p_freight_rec.ESTIMATED_FLAG <> FND_API.G_MISS_CHAR
          OR p_freight_rec.ESTIMATED_FLAG IS NULL) THEN
        x_freight_rec.ESTIMATED_FLAG:= p_freight_rec.ESTIMATED_FLAG;
     END IF;
     IF ( p_freight_rec.FREIGHT_COST_TYPE <> FND_API.G_MISS_CHAR
         OR p_freight_rec.FREIGHT_COST_TYPE IS NULL) THEN
        x_freight_rec.FREIGHT_COST_TYPE := p_freight_rec.FREIGHT_COST_TYPE;
     END IF;
     IF ( p_freight_rec.COMMODITY_CATEGORY_ID <> FND_API.G_MISS_NUM
         OR p_freight_rec.COMMODITY_CATEGORY_ID IS NULL) THEN
        x_freight_rec.COMMODITY_CATEGORY_ID := p_freight_rec.COMMODITY_CATEGORY_ID;
     END IF;

     --bug 3614196
     --trip_name, stop_location_id, planned_dep_date, delivery_name
     --need to copied to output record
     IF ( p_freight_rec.TRIP_NAME <> FND_API.G_MISS_CHAR
          OR p_freight_rec.TRIP_NAME IS NULL) THEN
        x_freight_rec.TRIP_NAME:= p_freight_rec.TRIP_NAME;
     END IF;

     IF ( p_freight_rec.STOP_LOCATION_ID <> FND_API.G_MISS_NUM
          OR  p_freight_rec.STOP_LOCATION_ID IS NULL) THEN
        x_freight_rec.STOP_LOCATION_ID:= p_freight_rec.STOP_LOCATION_ID;
     END IF;

     IF ( p_freight_rec.PLANNED_DEP_DATE <> FND_API.G_MISS_DATE
          OR  p_freight_rec.PLANNED_DEP_DATE IS NULL) THEN
        x_freight_rec.PLANNED_DEP_DATE:= p_freight_rec.PLANNED_DEP_DATE;
     END IF;

    IF ( p_freight_rec.DELIVERY_NAME <> FND_API.G_MISS_CHAR
          OR p_freight_rec.DELIVERY_NAME IS NULL) THEN
        x_freight_rec.DELIVERY_NAME:= p_freight_rec.DELIVERY_NAME;
     END IF;


  IF (p_caller IN ('FTE_RATING'))  THEN

    IF (p_freight_rec.BILLABLE_QUANTITY <> FND_API.G_MISS_NUM
        OR p_freight_rec.BILLABLE_QUANTITY IS NULL) THEN
      x_freight_rec.BILLABLE_QUANTITY := p_freight_rec.BILLABLE_QUANTITY;
    END IF;

    IF (p_freight_rec.BILLABLE_UOM <> FND_API.G_MISS_CHAR
        OR p_freight_rec.BILLABLE_UOM IS NULL) THEN
      x_freight_rec.BILLABLE_UOM := p_freight_rec.BILLABLE_UOM;
    END IF;

    IF (p_freight_rec.BILLABLE_BASIS <> FND_API.G_MISS_CHAR
        OR p_freight_rec.BILLABLE_BASIS IS NULL) THEN
      x_freight_rec.BILLABLE_BASIS := p_freight_rec.BILLABLE_BASIS;
    END IF;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
    WHEN e_dp_no_entity THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      wsh_util_core.default_handler('WSH_FREIGHT_COSTS_GRP.get_disabled_list',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Get_Disabled_List;

PROCEDURE Create_Update_Freight_Costs(
p_api_version_number     IN     NUMBER,
p_init_msg_list          IN     VARCHAR2,
p_commit                 IN     VARCHAR2,
p_freight_info_tab       IN     freight_rec_tab_type,
p_in_rec                 IN     freightInRecType,
x_out_tab                OUT    NOCOPY freight_out_tab_type,
x_return_status          OUT    NOCOPY VARCHAR2,
x_msg_count              OUT    NOCOPY NUMBER,
x_msg_data               OUT    NOCOPY VARCHAR2) IS

l_api_version_number   	CONSTANT NUMBER := 1.0;
l_api_name   		CONSTANT VARCHAR2(30) := 'Create_Update_Freight_Costs';
l_debug_on BOOLEAN;
l_module_name 		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_FREIGHT_COSTS';

RECORD_LOCKED          EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);


CURSOR get_freight_cost_type_del(p_freight_cost_type_id NUMBER) IS
 SELECT currency_code, amount
 FROM 	wsh_freight_cost_types
 WHERE  freight_cost_type_id=p_freight_cost_type_id;

--J-IB-JCKWOK
CURSOR c_detail_rec(v_detail_id NUMBER ) IS
SELECT delivery_detail_id ,
       organization_id,
       released_status,
       container_flag,
       source_code,
       lpn_id,
       line_direction,
       ship_from_location_id,
       move_order_line_id, -- R12, X-dock project
       NULL,    -- OTM R12
       client_id -- LSP PROJECT :Just added for dependency
FROM   wsh_delivery_details
WHERE  delivery_detail_id = v_detail_id;

CURSOR c_trip_rec(v_trip_id NUMBER ) IS
SELECT trip_id,
       NULL,  --       organization_id,
       status_code,
       planned_flag,
       load_tender_status, -- R12 Select Carrier dependent change
       lane_id,
       shipments_type_flag,
       NVL(ignore_for_planning, 'N')  --OTM R12,glog proj
FROM   wsh_trips
WHERE  trip_id = v_trip_id;

CURSOR c_stop_rec(v_stop_id NUMBER ) IS
SELECT stop_id,
       NULL, --       organization_id,
       status_code,
       shipments_type_flag
FROM wsh_trip_stops
WHERE stop_id = v_stop_id;

CURSOR c_del_rec(v_del_id NUMBER ) IS
SELECT delivery_id,
       organization_id,
       status_code,
       planned_flag,
       shipment_direction,
       delivery_type, -- MDC
       NVL(ignore_for_planning, 'N'),  --OTM R12, glog proj
       NVL(tms_interface_flag,WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT),   --OTM R12, glog proj
       NULL,   -- --OTM R12,
       client_id -- LSP PROJECT : Just added for dependency.
FROM   wsh_new_deliveries
WHERE  delivery_id = v_del_id;

l_detail_rec            WSH_DETAILS_VALIDATIONS.detail_rec_type;
l_del_rec               WSH_DELIVERY_VALIDATIONS.dlvy_rec_type;
l_trip_rec              WSH_TRIP_VALIDATIONS.trip_rec_type;
l_stop_rec              WSH_TRIP_STOPS_VALIDATIONS.stop_rec_type;
l_detail_rec_tab        WSH_DETAILS_VALIDATIONS.detail_rec_tab_type;
l_del_rec_tab           WSH_DELIVERY_VALIDATIONS.dlvy_rec_tab_type;
l_trip_rec_tab          WSH_TRIP_VALIDATIONS.trip_rec_tab_type;
l_stop_rec_tab          WSH_TRIP_STOPS_VALIDATIONS.stop_rec_tab_type;

l_valid_index_tab       wsh_util_core.id_tab_type;
l_valid_id_tab          wsh_util_core.id_tab_type;
l_error_ids             wsh_util_core.id_tab_type;
--J-IB-JCKWOK

l_currency_code		VARCHAR2(30);
l_amount		NUMBER;
l_return_status   	VARCHAR2(30);
l_counter		NUMBER;
l_counts          	NUMBER;
l_num_entity      	NUMBER:=0;
l_trip_id         	NUMBER := NULL;
l_stop_id         	NUMBER := NULL;
l_delivery_id     	NUMBER := NULL;
l_rowid           	VARCHAR2(30) := NULL;
l_num_errors            NUMBER :=0;
l_num_warnings          NUMBER :=0;
l_index                 NUMBER;
l_freight_info_tab      freight_rec_tab_type;
--
--OTM R12, glog proj
l_adjusted_amount       NUMBER;
--
l_status                VARCHAR2(1):= 'N';     --Bugfix 6816437
l_name                  VARCHAR2(1000):= NULL; --Bugfix 6816437
l_stop_loc_id           NUMBER := NULL;        --Bugfix 6816437
l_entity_name           VARCHAR2(30):= NULL;   --Bugfix 6816437
l_con_flag              VARCHAR2(1) := 'N';    --Bugfix 6816437

BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 SAVEPOINT Create_Update_Freight_Costs_Gp;
 IF l_debug_on THEN
  WSH_DEBUG_SV.push(l_module_name);
  --
  WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
  WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
  WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
  WSH_DEBUG_SV.log(l_module_name,'p_in_rec.caller',p_in_rec.caller);
  WSH_DEBUG_SV.log(l_module_name,'p_in_rec.action_code',p_in_rec.action_code);
  WSH_DEBUG_SV.log(l_module_name,'p_in_rec.phase',p_in_rec.phase);
 END IF;
 --
 IF NOT FND_API.Compatible_API_Call(l_api_version_number, p_api_version_number,l_api_name,G_PKG_NAME) THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Not compatible');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
 END IF;

 IF (p_in_rec.caller IS NULL) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.caller');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;
 IF (nvl(p_in_rec.phase,1) <> 1) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.phase');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;
 IF (p_in_rec.action_code IS NULL OR p_in_rec.action_code NOT IN ('CREATE','UPDATE') ) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    FND_MESSAGE.SET_TOKEN('FIELD_NAME','p_in_rec.action_code');
    wsh_util_core.add_message(x_return_status,l_module_name);
    raise fnd_api.g_exc_error;
 END IF;

 WSH_ACTIONS_LEVELS.set_validation_level (
        p_entity                => 'FRST',
        p_caller                => p_in_rec.caller,
        p_phase                 => p_in_rec.phase,
        p_action                => p_in_rec.action_code,
        x_return_status         => l_return_status);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'WSH_ACTIONS_LEVELS.set_validation_level l_return_status',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'C_FREIGHT_UNIT_AMT_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_UNIT_AMT_LVL));
    WSH_DEBUG_SV.log(l_module_name,'C_FREIGHT_CONV_RATE_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CONV_RATE_LVL));
    WSH_DEBUG_SV.log(l_module_name,'C_FREIGHT_CURR_CODE_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CURR_CODE_LVL));
    WSH_DEBUG_SV.log(l_module_name,'C_PARENT_ENTITY_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL));
    WSH_DEBUG_SV.log(l_module_name,'C_FREIGHT_COST_TYPE_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_COST_TYPE_LVL));
    WSH_DEBUG_SV.log(l_module_name,'C_ACTION_ENABLED_LVL',WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL));
 END IF;

 WSH_UTIL_CORE.api_post_call(p_return_status    => l_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors);

 l_freight_info_tab:=p_freight_info_tab;
 l_index := p_freight_info_tab.FIRST;
 --
 WHILE l_index IS NOT NULL LOOP
 --
 BEGIN
    --
    SAVEPOINT create_update_freight_loop;

    --
    --J-IB-JCKWOK
    --
    IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DISABLED_LIST_LVL) = 1 )  THEN
     Get_Disabled_List (
        p_freight_rec          => p_freight_info_tab(l_index),
        p_action               => p_in_rec.action_code,
        p_caller               => p_in_rec.caller,
        x_freight_rec          => l_freight_info_tab(l_index),
        x_return_status        => l_return_status);
    END IF;


    WSH_UTIL_CORE.api_post_call(p_return_status    => l_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors);

    IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_COST_TYPE_LVL)=1) THEN
        IF (l_freight_info_tab(l_index).freight_cost_type IS NULL AND
   		l_freight_info_tab(l_index).freight_cost_type_id IS NULL) THEN

           l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.api_post_call(p_return_status    => l_return_status,
                                x_num_warnings     =>l_num_warnings,
                                x_num_errors       =>l_num_errors,
                                p_module_name      => l_module_name,
                                p_msg_data         =>  'WSH_REQUIRED_FIELD_NULL',
                                p_token1           => 'FIELD_NAME',
                                p_value1           => 'freight_cost_type');
        ELSE
           validate_freight_cost_type(
                        p_freight_cost_type     => l_freight_info_tab(l_index).freight_cost_type,
                        x_freight_cost_type_id  => l_freight_info_tab(l_index).freight_cost_type_id,
                        x_return_status         => l_return_status);
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'validate_freight_cost_type l_return_status',l_return_status);
           END IF;

           WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'freight_cost_type');

           IF (l_freight_info_tab(l_index).currency_code IS NULL
                OR l_freight_info_tab(l_index).unit_amount IS NULL) THEN
              OPEN  get_freight_cost_type_del(l_freight_info_tab(l_index).freight_cost_type_id);
              FETCH get_freight_cost_type_del INTO l_currency_code,l_amount;
              CLOSE get_freight_cost_type_del;

             l_freight_info_tab(l_index).currency_code :=nvl(l_freight_info_tab(l_index).currency_code,
                                                                                                    l_currency_code);
             l_freight_info_tab(l_index).unit_amount :=nvl(l_freight_info_tab(l_index).unit_amount,l_amount);
           END IF;
        END IF;
    END IF;

    IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_UNIT_AMT_LVL)=1) THEN
        --Bug 3266333
        WSH_UTIL_VALIDATE.validate_negative(
		        p_value          => l_freight_info_tab(l_index).unit_amount,
			p_field_name     => 'unit_amount',
			x_return_status  => l_return_status );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Negative x_return_status',l_return_status);
        END IF;
        WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'unit_amount');
    END IF;

    IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CONV_RATE_LVL)=1) THEN
        --Bug 3266333
	WSH_UTIL_VALIDATE.validate_negative(
		        p_value          => l_freight_info_tab(l_index).conversion_rate,
			p_field_name     => 'conversion_rate',
			x_return_status  => l_return_status );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Negative x_return_status',l_return_status);
        END IF;
        WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'conversion_rate');
    END IF;

    IF ((WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_FREIGHT_CURR_CODE_LVL)=1)
         AND (l_freight_info_tab(l_index).currency_code <>FND_API.G_MISS_CHAR)) THEN
        WSH_UTIL_VALIDATE.validate_currency(
			p_currency_code	  => l_freight_info_tab(l_index).currency_code,
			p_currency_name	  => NULL,
			p_amount	  => l_freight_info_tab(l_index).unit_amount,
			x_return_status	  => l_return_status,
                        x_adjusted_amount => l_adjusted_amount); -- OTM R12, glog proj

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Currency l_return_status',l_return_status);
        END IF;

        WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'currency_code');
    END IF;

    IF ((l_freight_info_tab(l_index).trip_id IS NOT NULL ) OR l_freight_info_tab(l_index).trip_name IS NOT NULL) THEN
       l_num_entity := l_num_entity +1;
    END IF;
    IF ((l_freight_info_tab(l_index).stop_id IS NOT NULL) OR
                                                       l_freight_info_tab(l_index).stop_location_id IS NOT NULL) THEN
       l_num_entity := l_num_entity +1;
    END IF;
    IF ((l_freight_info_tab(l_index).delivery_id IS NOT NULL) OR
                                                          l_freight_info_tab(l_index).delivery_name IS NOT NULL) THEN
       l_num_entity := l_num_entity +1;
    END IF;
    IF (l_freight_info_tab(l_index).delivery_leg_id IS NOT NULL) THEN
       l_num_entity := l_num_entity +1;
    END IF;
    IF (l_freight_info_tab(l_index).delivery_detail_id IS NOT NULL) THEN
       l_num_entity := l_num_entity +1;
    END IF;

    IF (l_num_entity > 1 ) THEN
       WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_FC_ONE_MASTER_ENTITY');

    END IF;


    l_num_entity := 0;

    IF ((l_freight_info_tab(l_index).trip_id IS NOT NULL ) OR l_freight_info_tab(l_index).trip_name IS NOT NULL) THEN
       IF (l_freight_info_tab(l_index).trip_id IS NULL) THEN
          IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
             WSH_UTIL_VALIDATE.Validate_Trip_name(
		p_trip_id      	=> l_trip_id,
		p_trip_name    	=> l_freight_info_tab(l_index).trip_name,
		x_return_status => l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_Trip_name x_return_status',l_return_status);
             END IF;
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'trip_name');
          END IF;
       ELSE
          l_trip_id := l_freight_info_tab(l_index).trip_id;
       END IF;

       l_num_entity := l_num_entity + 1;

--Bugfix 6816437 Start  --Code has been written to check the oe interface flag when inserting/updating Freight Cost Record and display warning
        IF p_in_rec.caller = 'PLSQL' THEN
          BEGIN
                   SELECT 'Y',wt.name into l_status,l_name
                     FROM wsh_trips wt, wsh_trip_stops wts, wsh_delivery_legs wdl, wsh_new_deliveries wnd,
                          wsh_delivery_assignments wda, wsh_delivery_details wdd
                    WHERE wt.trip_id = l_trip_id
                      AND wts.trip_id = wt.trip_id
                      AND wdl.pick_up_stop_id = wts.stop_id
                      AND wnd.delivery_id = wdl.delivery_id
                      AND wda.delivery_id = wnd.delivery_id
                      AND wdd.delivery_detail_id = wda.delivery_detail_id
                      AND wdd.oe_interfaced_flag = 'Y'
                      AND ROWNUM = 1;

              IF l_status = 'Y' THEN
                 WSH_UTIL_CORE.api_post_call(p_return_status    => WSH_UTIL_CORE.G_RET_STS_WARNING,
                                             x_num_warnings     => l_num_warnings,
                                             x_num_errors       => l_num_errors,
                                             p_module_name      => l_module_name,
                                             p_msg_data         => 'WSH_FC_OTHER_WARN',
                                             p_token1           => 'ENTITY_NAME',
                                             p_value1           => 'trip',
                                             p_token2           => 'ENTITY_ID',
                                             p_value2           => l_name);
              END IF;
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
             NULL;
          END;
        END IF;
--Bugfix 6816437 End

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
          SELECT COUNT(*) INTO l_counts
          FROM wsh_trips
            WHERE trip_id = l_trip_id
          AND ROWNUM = 1;

          IF (l_counts = 0) THEN
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_FC_ONE_MASTER_ENTITY');
          END IF;
       END IF;

    ELSIF ((l_freight_info_tab(l_index).stop_id IS NOT NULL) OR l_freight_info_tab(l_index).stop_location_id IS NOT NULL) THEN
       IF (l_freight_info_tab(l_index).stop_id IS NULL) THEN
          IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
         	  WSH_UTIL_VALIDATE.Validate_stop_name(
					p_stop_id       	=>l_stop_id,
					p_trip_id    		=>l_freight_info_tab(l_index).trip_name,
					p_stop_location_id  	=>l_freight_info_tab(l_index).stop_location_id,
					p_planned_dep_date  	=>l_freight_info_tab(l_index).planned_dep_date,
					x_return_status 	=>l_return_status);

             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_stop_name x_return_status',l_return_status);
             END IF;
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'stop_name');
          END IF;
       ELSE
          l_stop_id := l_freight_info_tab(l_index).stop_id;
       END IF;

       l_num_entity := l_num_entity + 1;

--Bugfix 6816437 Start  --Code has been written to check the oe interface flag when inserting/updating Freight Cost Record
        IF p_in_rec.caller = 'PLSQL' THEN
          BEGIN
                   SELECT 'Y',wts.stop_location_id into l_status,l_stop_loc_id
                     FROM wsh_trip_stops wts, wsh_delivery_legs wdl, wsh_new_deliveries wnd,
                          wsh_delivery_assignments wda, wsh_delivery_details wdd
                    WHERE wts.stop_id = l_stop_id
                      AND (wdl.pick_up_stop_id = wts.stop_id OR wdl.drop_off_stop_id = wts.stop_id)
                      AND wnd.delivery_id = wdl.delivery_id
                      AND wda.delivery_id = wnd.delivery_id
                      AND wdd.delivery_detail_id = wda.delivery_detail_id
                      AND wdd.oe_interfaced_flag = 'Y'
                      AND ROWNUM = 1;
              IF l_status = 'Y' THEN
                 l_name := wsh_util_core.get_location_description(l_stop_loc_id,'NEW UI CODE INFO');
                 WSH_UTIL_CORE.api_post_call(p_return_status    => WSH_UTIL_CORE.G_RET_STS_WARNING,
                                             x_num_warnings     => l_num_warnings,
                                             x_num_errors       => l_num_errors,
                                             p_module_name      => l_module_name,
                                             p_msg_data         =>  'WSH_FC_OTHER_WARN',
                                             p_token1           => 'ENTITY_NAME',
                                             p_value1           => 'stop',
                                             p_token2           => 'ENTITY_ID',
                                             p_value2           => l_name);
              END IF;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
            NULL;
          END;
        END IF;
--Bugfix 6816437 End

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
          SELECT COUNT(*) INTO l_counts
          FROM wsh_trip_stops
          WHERE stop_id = l_stop_id
          AND ROWNUM = 1;

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_counts',l_counts);
          END IF;
          IF (l_counts = 0) THEN
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_FC_ONE_MASTER_ENTITY');
          END IF;
       END IF;

    ELSIF ((l_freight_info_tab(l_index).delivery_id IS NOT NULL) OR l_freight_info_tab(l_index).delivery_name IS NOT NULL) THEN
       IF (l_freight_info_tab(l_index).delivery_id IS NULL OR l_freight_info_tab(l_index).delivery_name IS NOT NULL) THEN
          IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
             WSH_UTIL_VALIDATE.Validate_delivery_name(
		p_delivery_id      	=>l_delivery_id,
		p_delivery_name    	=>l_freight_info_tab(l_index).delivery_name,
		x_return_status 	=>l_return_status);

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'WSH_UTIL_VALIDATE.Validate_delivery_name x_return_status',l_return_status);
             END IF;
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_INVALID_PARAMETER',
                                   p_token1           => 'PARAMETER',
                                   p_value1           => 'delivery_name');
          END IF;
       ELSE
          l_delivery_id := l_freight_info_tab(l_index).delivery_id;
       END IF;

       l_num_entity := l_num_entity + 1;

--Bugfix 6816437 Start  --Code has been written to check the oe interface flag when inserting/updating Freight Cost Record
        IF p_in_rec.caller = 'PLSQL' THEN
          BEGIN
                   SELECT 'Y',wnd.name into l_status,l_name
                     FROM wsh_new_deliveries wnd, wsh_delivery_assignments wda, wsh_delivery_details wdd
                    WHERE wnd.delivery_id = l_delivery_id
                      AND wda.delivery_id = wnd.delivery_id
                      AND wdd.delivery_detail_id = wda.delivery_detail_id
                      AND wdd.oe_interfaced_flag = 'Y'
                      AND ROWNUM = 1;
              IF l_status = 'Y' THEN
                 WSH_UTIL_CORE.api_post_call(p_return_status    => WSH_UTIL_CORE.G_RET_STS_WARNING,
                                             x_num_warnings     => l_num_warnings,
                                             x_num_errors       => l_num_errors,
                                             p_module_name      => l_module_name,
                                             p_msg_data         =>  'WSH_FC_OTHER_WARN',
                                             p_token1           => 'ENTITY_NAME',
                                             p_value1           => 'delivery',
                                             p_token2           => 'ENTITY_ID',
                                             p_value2           => l_name);
              END IF;
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
             NULL;
          END;
        END IF;
--Bugfix 6816437 End

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
          SELECT COUNT(*) INTO l_counts
          FROM wsh_new_deliveries
          WHERE delivery_id = l_delivery_id
          AND ROWNUM = 1;

          IF (l_counts = 0) THEN
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_FC_ONE_MASTER_ENTITY');
          END IF;
       END IF;

    ELSIF (l_freight_info_tab(l_index).delivery_leg_id IS NOT NULL) THEN
       l_num_entity := l_num_entity + 1;

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
          SELECT delivery_id INTO l_counts
          FROM wsh_delivery_legs
          WHERE delivery_leg_id = l_freight_info_tab(l_index).delivery_leg_id
          AND ROWNUM = 1;

          IF (l_counts = 0) THEN
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_FC_ONE_MASTER_ENTITY');
          END IF;
       END IF;

    ELSIF (l_freight_info_tab(l_index).delivery_detail_id IS NOT NULL) THEN
       l_num_entity := l_num_entity + 1;

--Bugfix 6816437 Start  --Code has been written to check the oe interface flag when inserting/updating Freight Cost Record
        IF p_in_rec.caller = 'PLSQL' THEN
          BEGIN
                   SELECT container_flag,container_name into l_con_flag,l_name
                     FROM wsh_delivery_details
                    WHERE delivery_detail_id = l_freight_info_tab(l_index).delivery_detail_id;

                    IF l_con_flag = 'Y' THEN
                       l_entity_name := 'LPN';
                      SELECT 'Y' into l_status
                        FROM wsh_delivery_details
                       WHERE delivery_detail_id in (SELECT delivery_detail_id
                                                      FROM wsh_delivery_assignments
                                                     WHERE parent_delivery_detail_id = l_freight_info_tab(l_index).delivery_detail_id)
                         AND oe_interfaced_flag = 'Y'
                         AND container_flag = 'N'
                         AND ROWNUM = 1;
                    ELSE
                       l_entity_name := 'Delivery line';
                      SELECT oe_interfaced_flag,delivery_detail_id into l_status,l_name
                        FROM wsh_delivery_details
                       WHERE delivery_detail_id = l_freight_info_tab(l_index).delivery_detail_id;
                    END IF;

              IF l_status = 'Y' THEN
                 WSH_UTIL_CORE.api_post_call(p_return_status    => WSH_UTIL_CORE.G_RET_STS_WARNING,
                                             x_num_warnings     => l_num_warnings,
                                             x_num_errors       => l_num_errors,
                                             p_module_name      => l_module_name,
                                             p_msg_data         => 'WSH_FC_DET_WARN',
                                             p_token1           => 'ENTITY_NAME',
                                             p_value1           => l_entity_name,
                                             p_token2           => 'ENTITY_ID',
                                             p_value2           => l_name);
              END IF;
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
             NULL;
          END;
        END IF;
--Bugfix 6816437 End

       IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PARENT_ENTITY_LVL)=1) THEN
          SELECT COUNT(delivery_detail_id) INTO l_counts
          FROM wsh_delivery_details
          WHERE delivery_detail_id = l_freight_info_tab(l_index).delivery_detail_id
          AND ROWNUM = 1;

          IF (l_counts = 0) THEN
             WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_FC_ONE_MASTER_ENTITY');
          END IF;
       END IF;
    END IF;

    l_freight_info_tab(l_index).trip_id   := l_trip_id;
    l_freight_info_tab(l_index).stop_id   := l_stop_id;
    l_freight_info_tab(l_index).delivery_id := l_delivery_id;

    --Following changes for bug 3614196
    -- moved the code for is_action_enabled. Only after validations are done, entity ids would have a value.
    -- Add nvl with g_miss_num

    --J-IB-JCKWOK
    --
    IF nvl(l_freight_info_tab(l_index).DELIVERY_DETAIL_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
       --
       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
          --
          OPEN c_detail_rec(l_freight_info_tab(l_index).DELIVERY_DETAIL_ID);
          FETCH c_detail_rec INTO l_detail_rec_tab(1);
          --
          IF c_detail_rec%NOTFOUND THEN
             --
             CLOSE c_detail_rec;
             FND_MESSAGE.SET_NAME('WSH','WSH_DETAIL_NOT_EXIST');
             FND_MESSAGE.SET_TOKEN('DETAIL_ID', l_freight_info_tab(l_index).DELIVERY_DETAIL_ID);
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
             IF l_debug_on THEN
                wsh_debug_sv.log (l_module_name,'WSH_DETAIL_NOT_EXIST');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
             --
          END IF;
          --
          CLOSE c_detail_rec;
          --
          WSH_DETAILS_VALIDATIONS.Is_Action_Enabled(
                p_del_detail_rec_tab      => l_detail_rec_tab,
                p_action                  => 'ASSIGN-FREIGHT-COSTS',
                p_caller                  => p_in_rec.caller,
                p_deliveryid              => NULL,
                x_return_status           => l_return_status,
                x_valid_ids               => l_valid_id_tab ,
                x_error_ids               => l_error_ids ,
                x_valid_index_tab         => l_valid_index_tab);
          --
          WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                            x_num_warnings     =>l_num_warnings,
                            x_num_errors       =>l_num_errors);
          --
       END IF;
       --
    ELSIF nvl(l_freight_info_tab(l_index).DELIVERY_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
       --
       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
         OPEN c_del_rec(l_freight_info_tab(l_index).DELIVERY_ID);
         FETCH c_del_rec INTO l_del_rec_tab(1);
         --
         IF c_del_rec%NOTFOUND THEN
            CLOSE c_del_rec;
            FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_NOT_EXIST');
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_freight_info_tab(l_index).DELIVERY_NAME);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name,'WSH_DELIVERY_NOT_EXIST');
            END IF;
            --
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         --
         CLOSE c_del_rec;
         --
         WSH_DELIVERY_VALIDATIONS.Is_Action_Enabled(
                p_dlvy_rec_tab            => l_del_rec_tab,
                p_action                  => 'ASSIGN-FREIGHT-COSTS',
                p_caller                  => p_in_rec.caller,
                x_return_status           => l_return_status,
                x_valid_ids               => l_valid_id_tab ,
                x_error_ids               => l_error_ids ,
                x_valid_index_tab         => l_valid_index_tab);

         WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                            x_num_warnings     =>l_num_warnings,
                            x_num_errors       =>l_num_errors);
       END IF;
       --
    ELSIF nvl(l_freight_info_tab(l_index).TRIP_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
       --
       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
         OPEN c_trip_rec(l_freight_info_tab(l_index).TRIP_ID);
         FETCH c_trip_rec INTO l_trip_rec_tab(1);
         --
         IF c_trip_rec%NOTFOUND THEN
            CLOSE c_trip_rec;
            FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_NOT_EXIST');
            FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_freight_info_tab(l_index).TRIP_NAME);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name,'WSH_TRIP_NOT_EXIST');
            END IF;
            --
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         --
         CLOSE c_trip_rec;
         --
         WSH_TRIP_VALIDATIONS.Is_Action_Enabled(
                p_trip_rec_tab            => l_trip_rec_tab,
                p_action                  => 'ASSIGN-FREIGHT-COSTS',
                p_caller                  => p_in_rec.caller,
                x_return_status           => l_return_status,
                x_valid_ids               => l_valid_id_tab ,
                x_error_ids               => l_error_ids ,
                x_valid_index_tab         => l_valid_index_tab);

         WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                            x_num_warnings     =>l_num_warnings,
                            x_num_errors       =>l_num_errors);
       END IF;
       --
    ELSIF nvl(l_freight_info_tab(l_index).STOP_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
       --
       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_ACTION_ENABLED_LVL) = 1 THEN
         OPEN c_stop_rec(l_freight_info_tab(l_index).STOP_ID);
         FETCH c_stop_rec INTO l_stop_rec_tab(1);
         --
         IF c_stop_rec%NOTFOUND THEN
            CLOSE c_stop_rec;
            FND_MESSAGE.SET_NAME('WSH','WSH_STOP_NOT_EXIST');
            FND_MESSAGE.SET_TOKEN('STOP_ID', l_freight_info_tab(l_index).STOP_ID);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            --
            IF l_debug_on THEN
               wsh_debug_sv.log (l_module_name,'WSH_STOP_NOT_EXIST');
            END IF;
            --
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         --
         CLOSE c_stop_rec;
         --
         WSH_TRIP_STOPS_VALIDATIONS.Is_Action_Enabled(
                p_stop_rec_tab            => l_stop_rec_tab,
                p_action                  => 'ASSIGN-FREIGHT-COSTS',
                p_caller                  => p_in_rec.caller,
                x_return_status           => l_return_status,
                x_valid_ids               => l_valid_id_tab ,
                x_error_ids               => l_error_ids ,
                x_valid_index_tab         => l_valid_index_tab);

         WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                            x_num_warnings     =>l_num_warnings,
                            x_num_errors       =>l_num_errors);
       END IF;
       --
    END IF;


    IF (p_in_rec.action_code= 'CREATE') THEN
       WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
				p_freight_cost_info    	=> l_freight_info_tab(l_index),
				x_rowid			=> x_out_tab(l_index).rowid,
				x_freight_cost_id	=> x_out_tab(l_index).freight_cost_id,
				x_return_status  	=> l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost x_freight_cost_id,x_return_status',
                         x_out_tab(l_index).freight_cost_id||','||l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_CREATE_FAILURE',
                                   p_token1           => 'ENTITY',
                                   p_value1           => 'Freight_Cost');

    ELSIF (p_in_rec.action_code= 'UPDATE') THEN
       WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
                p_rowid			=> NULL,
		p_freight_cost_info    	=> l_freight_info_tab(l_index),
		x_return_status  	=> l_return_status);

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Update_Freight_Costs x_return_status',l_return_status);
       END IF;
       WSH_UTIL_CORE.api_post_call(
                                   p_return_status    => l_return_status,
                                   x_num_warnings     => l_num_warnings,
                                   x_num_errors       => l_num_errors,
                                   p_module_name      => l_module_name,
                                   p_msg_data         =>  'WSH_PUB_UPDATE_FAILURE',
                                   p_token1           => 'ENTITY',
                                   p_value1           => 'Freight_Cost');
    END IF;

 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- OTM R12, glog proj
      IF get_freight_cost_type_del%ISOPEN THEN
        CLOSE get_freight_cost_type_del;
      END IF;
      IF c_detail_rec%ISOPEN THEN
        CLOSE c_detail_rec;
      END IF;
      IF c_trip_rec%ISOPEN THEN
        CLOSE c_trip_rec;
      END IF;
      IF c_stop_rec%ISOPEN THEN
        CLOSE c_stop_rec;
      END IF;
      IF c_del_rec%ISOPEN THEN
        CLOSE c_del_rec;
      END IF;
      ROLLBACK to create_update_freight_loop;

    WHEN fnd_api.g_exc_unexpected_error THEN
      -- OTM R12, glog proj
      IF get_freight_cost_type_del%ISOPEN THEN
        CLOSE get_freight_cost_type_del;
      END IF;
      IF c_detail_rec%ISOPEN THEN
        CLOSE c_detail_rec;
      END IF;
      IF c_trip_rec%ISOPEN THEN
        CLOSE c_trip_rec;
      END IF;
      IF c_stop_rec%ISOPEN THEN
        CLOSE c_stop_rec;
      END IF;
      IF c_del_rec%ISOPEN THEN
        CLOSE c_del_rec;
      END IF;
      ROLLBACK to create_update_freight_loop;

    WHEN others THEN
      -- OTM R12, glog proj
      IF get_freight_cost_type_del%ISOPEN THEN
        CLOSE get_freight_cost_type_del;
      END IF;
      IF c_detail_rec%ISOPEN THEN
        CLOSE c_detail_rec;
      END IF;
      IF c_trip_rec%ISOPEN THEN
        CLOSE c_trip_rec;
      END IF;
      IF c_stop_rec%ISOPEN THEN
        CLOSE c_stop_rec;
      END IF;
      IF c_del_rec%ISOPEN THEN
        CLOSE c_del_rec;
      END IF;
      ROLLBACK to create_update_freight_loop;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END;

    l_index := p_freight_info_tab.NEXT(l_index);
 END LOOP;

 IF (l_num_errors = p_freight_info_tab.count ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
 ELSIF (l_num_errors > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    RAISE WSH_UTIL_CORE.G_EXC_WARNING;
 ELSIF (l_num_warnings > 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    RAISE WSH_UTIL_CORE.G_EXC_WARNING;
 ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 END IF;


 IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
 END IF;

 FND_MSG_PUB.Count_And_Get (
		p_count => x_msg_count,
		p_data  => x_msg_data);

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN RECORD_LOCKED THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
     wsh_util_core.add_message(x_return_status,l_module_name);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
     END IF;
     Rollback to Create_Update_Freight_Costs_Gp;

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     Rollback to Create_Update_Freight_Costs_Gp;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;
     Rollback to Create_Update_Freight_Costs_Gp;

  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
     END IF;

  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     Rollback to Create_Update_Freight_Costs_Gp;
END Create_Update_Freight_Costs;


--========================================================================
-- PROCEDURE : Create_Update_Freight_Costs   Wrapper API
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--         		p_changed_attributes    changed attributes for delivery details
--             p_action_code           action to perform
--
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--========================================================================
PROCEDURE Create_Update_Freight_Costs (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status          OUT NOCOPY  VARCHAR2
, x_msg_count              OUT NOCOPY  NUMBER
, x_msg_data               OUT NOCOPY  VARCHAR2
, p_pub_freight_costs	   IN     WSH_FREIGHT_COSTS_GRP.PubFreightCostRecType
, p_action_code            IN     VARCHAR2
, x_freight_cost_id           OUT NOCOPY  NUMBER
)
IS

l_api_version_number   	CONSTANT NUMBER := 1.0;
l_api_name   		CONSTANT VARCHAR2(30) := 'Create_Update_Freight_Costs';
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_FREIGHT_COSTS';

l_pvt_freight_rec	WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_in_rec		FreightInRecType;
l_freight_info_tab      freight_rec_tab_type;
l_out_tab               freight_out_tab_type;
BEGIN

   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_freightgrp_to_pvt (
                p_grp_freight_rec	=> p_pub_freight_costs,
                x_pvt_freight_rec	=> l_pvt_freight_rec,
                x_return_status 	=> x_return_status);
   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'map_freightgrp_to_pvt x_return_status',x_return_status);
   END IF;
   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   l_in_rec.caller := 'WSH_GRP';
   l_in_rec.phase := 1;
   l_in_rec.action_code := p_action_code;
   l_freight_info_tab(1) := l_pvt_freight_rec;

   WSH_INTERFACE_GRP.Create_Update_Freight_Costs(
      p_api_version_number     => p_api_version_number,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      p_freight_info_tab       => l_freight_info_tab,
      p_in_rec                 => l_in_rec,
      x_out_tab                => l_out_tab );

    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_out_tab.COUNT > 0 ) THEN
       x_freight_cost_id := l_out_tab(l_out_tab.FIRST).freight_cost_id;
    END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;


  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.default_handler ('WSH_TRIP_STOPS_GRP.CREATE_UPDATE_STOP');
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Create_Update_Freight_Costs;
--Harmonizing Project I :heali

END WSH_FREIGHT_COSTS_GRP;

/
