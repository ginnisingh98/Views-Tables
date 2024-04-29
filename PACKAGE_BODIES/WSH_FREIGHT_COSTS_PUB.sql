--------------------------------------------------------
--  DDL for Package Body WSH_FREIGHT_COSTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FREIGHT_COSTS_PUB" as
/* $Header: WSHFCPBB.pls 115.6 2002/11/18 20:18:40 nparikh ship $ */
-- standard global constants
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_FREIGHT_COSTS_PUB';


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
BEGIN
	--
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


	EXCEPTION
		WHEN No_Data_Found THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WHEN Invalid_Type THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WHEN others THEN
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END validate_freight_cost_type;

PROCEDURE Delete_Freight_Costs (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_pub_freight_costs		IN     WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType
)
IS
l_return_status            VARCHAR2(30);
BEGIN
   --
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	WSH_FREIGHT_COSTS_PVT.Delete_freight_cost(
		p_rowid       			=>   	NULL,
		p_freight_cost_id   	=>   	p_pub_freight_costs.freight_cost_id,
		x_return_status     	=>   	x_return_status);

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
END Delete_Freight_Costs;


--Harmonizing Project **heali
PROCEDURE map_freightpub_to_pvt(
   p_pub_freight_rec IN PubFreightCostRecType,
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
       WSH_DEBUG_SV.log(l_module_name,'p_pub_freight_rec.FREIGHT_COST_ID',p_pub_freight_rec.FREIGHT_COST_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_pub_freight_rec.FREIGHT_COST_TYPE_ID',p_pub_freight_rec.FREIGHT_COST_TYPE_ID);
   END IF;
   --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_pvt_freight_rec.FREIGHT_COST_ID		 := p_pub_freight_rec.FREIGHT_COST_ID;
  x_pvt_freight_rec.FREIGHT_COST_TYPE_ID	 := p_pub_freight_rec.FREIGHT_COST_TYPE_ID;
  x_pvt_freight_rec.UNIT_AMOUNT			 := p_pub_freight_rec.UNIT_AMOUNT;
  x_pvt_freight_rec.CALCULATION_METHOD		 := FND_API.G_MISS_CHAR;
  x_pvt_freight_rec.UOM				 := FND_API.G_MISS_CHAR;
  x_pvt_freight_rec.QUANTITY			 := FND_API.G_MISS_NUM;
  x_pvt_freight_rec.TOTAL_AMOUNT		 := FND_API.G_MISS_NUM;
  x_pvt_freight_rec.CURRENCY_CODE		 := p_pub_freight_rec.CURRENCY_CODE;
  x_pvt_freight_rec.CONVERSION_DATE		 := p_pub_freight_rec.CONVERSION_DATE;
  x_pvt_freight_rec.CONVERSION_RATE		 := p_pub_freight_rec.CONVERSION_RATE;
  x_pvt_freight_rec.CONVERSION_TYPE_CODE	 := p_pub_freight_rec.CONVERSION_TYPE_CODE;
  x_pvt_freight_rec.TRIP_ID			 := p_pub_freight_rec.TRIP_ID;
  x_pvt_freight_rec.STOP_ID			 := p_pub_freight_rec.STOP_ID;
  x_pvt_freight_rec.DELIVERY_ID			 := p_pub_freight_rec.DELIVERY_ID;
  x_pvt_freight_rec.DELIVERY_LEG_ID		 := p_pub_freight_rec.DELIVERY_LEG_ID;
  x_pvt_freight_rec.DELIVERY_DETAIL_ID		 := p_pub_freight_rec.DELIVERY_DETAIL_ID;
  x_pvt_freight_rec.ATTRIBUTE_CATEGORY		 := p_pub_freight_rec.ATTRIBUTE_CATEGORY;
  x_pvt_freight_rec.ATTRIBUTE1		   	 := p_pub_freight_rec.ATTRIBUTE1;
  x_pvt_freight_rec.ATTRIBUTE2		   	 := p_pub_freight_rec.ATTRIBUTE2;
  x_pvt_freight_rec.ATTRIBUTE3		   	 := p_pub_freight_rec.ATTRIBUTE3;
  x_pvt_freight_rec.ATTRIBUTE4		   	 := p_pub_freight_rec.ATTRIBUTE4;
  x_pvt_freight_rec.ATTRIBUTE5			 := p_pub_freight_rec.ATTRIBUTE5;
  x_pvt_freight_rec.ATTRIBUTE6			 := p_pub_freight_rec.ATTRIBUTE6;
  x_pvt_freight_rec.ATTRIBUTE7			 := p_pub_freight_rec.ATTRIBUTE7;
  x_pvt_freight_rec.ATTRIBUTE8			 := p_pub_freight_rec.ATTRIBUTE8;
  x_pvt_freight_rec.ATTRIBUTE9			 := p_pub_freight_rec.ATTRIBUTE9;
  x_pvt_freight_rec.ATTRIBUTE10			 := p_pub_freight_rec.ATTRIBUTE10;
  x_pvt_freight_rec.ATTRIBUTE11			 := p_pub_freight_rec.ATTRIBUTE11;
  x_pvt_freight_rec.ATTRIBUTE12			 := p_pub_freight_rec.ATTRIBUTE12;
  x_pvt_freight_rec.ATTRIBUTE13			 := p_pub_freight_rec.ATTRIBUTE13;
  x_pvt_freight_rec.ATTRIBUTE14			 := p_pub_freight_rec.ATTRIBUTE14;
  x_pvt_freight_rec.ATTRIBUTE15			 := p_pub_freight_rec.ATTRIBUTE15;
  x_pvt_freight_rec.CREATION_DATE		 := p_pub_freight_rec.CREATION_DATE;
  x_pvt_freight_rec.CREATED_BY		   	 := p_pub_freight_rec.CREATED_BY;
  x_pvt_freight_rec.LAST_UPDATE_DATE		 := p_pub_freight_rec.LAST_UPDATE_DATE;
  x_pvt_freight_rec.LAST_UPDATED_BY		 := p_pub_freight_rec.LAST_UPDATED_BY;
  x_pvt_freight_rec.LAST_UPDATE_LOGIN		 := p_pub_freight_rec.LAST_UPDATE_LOGIN;
  x_pvt_freight_rec.PROGRAM_APPLICATION_ID	 := p_pub_freight_rec.PROGRAM_APPLICATION_ID;
  x_pvt_freight_rec.PROGRAM_ID			 := p_pub_freight_rec.PROGRAM_ID;
  x_pvt_freight_rec.PROGRAM_UPDATE_DATE		 := p_pub_freight_rec.PROGRAM_UPDATE_DATE;
  x_pvt_freight_rec.REQUEST_ID			 := p_pub_freight_rec.REQUEST_ID;

  x_pvt_freight_rec.PRICING_LIST_HEADER_ID	 := FND_API.G_MISS_NUM;
  x_pvt_freight_rec.PRICING_LIST_LINE_ID	 := FND_API.G_MISS_NUM;
  x_pvt_freight_rec.APPLIED_TO_CHARGE_ID	 := FND_API.G_MISS_NUM;
  x_pvt_freight_rec.CHARGE_UNIT_VALUE		 := FND_API.G_MISS_NUM;
  x_pvt_freight_rec.CHARGE_SOURCE_CODE		 := FND_API.G_MISS_CHAR;
  x_pvt_freight_rec.LINE_TYPE_CODE		 := FND_API.G_MISS_CHAR;
  x_pvt_freight_rec.ESTIMATED_FLAG	 	 := FND_API.G_MISS_CHAR;
  x_pvt_freight_rec.FREIGHT_CODE		 := FND_API.G_MISS_CHAR;
  x_pvt_freight_rec.TRIP_NAME			 := p_pub_freight_rec.TRIP_NAME;
  x_pvt_freight_rec.DELIVERY_NAME		 := p_pub_freight_rec.DELIVERY_NAME;
  x_pvt_freight_rec.FREIGHT_COST_TYPE		 := p_pub_freight_rec.FREIGHT_COST_TYPE;
  x_pvt_freight_rec.STOP_LOCATION_ID		 := p_pub_freight_rec.STOP_LOCATION_ID;
  x_pvt_freight_rec.PLANNED_DEP_DATE 		 := p_pub_freight_rec.PLANNED_DEP_DATE;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_FTE_INTEGRATION.map_freightpub_to_pvt',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END;

--========================================================================
-- PROCEDURE : Create_Update_Freight_Costs
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
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                   OUT NOCOPY  NUMBER
, x_msg_data                    OUT NOCOPY  VARCHAR2
, p_pub_freight_costs   IN     WSH_FREIGHT_COSTS_PUB.PubFreightCostRecType
, p_action_code            IN     VARCHAR2
, x_freight_cost_id           OUT NOCOPY  NUMBER) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Update_Freight_Costs';

l_api_version_number   	CONSTANT NUMBER := 1.0;
l_api_name   		CONSTANT VARCHAR2(30) := 'Create_Update_Freight_Costs';

l_pvt_freight_rec	WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_in_rec		WSH_FREIGHT_COSTS_GRP.FreightInRecType;
l_freight_info_tab      WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type;
l_out_tab               WSH_FREIGHT_COSTS_GRP.freight_out_tab_type;

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
      wsh_debug_sv.push (l_module_name, 'Create_Update_Freight_Costs');
   END IF;

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,p_api_version_number ,l_api_name ,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   map_freightpub_to_pvt(
   	p_pub_freight_rec 	=> p_pub_freight_costs ,
   	x_pvt_freight_rec 	=> l_pvt_freight_rec,
   	x_return_status 	=> x_return_status);
   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'map_freightpub_to_pvt x_return_status',x_return_status);
   END IF;

   IF ( x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   l_in_rec.caller:='PLSQL';
   l_in_rec.phase:= 1;

   IF (p_pub_freight_costs.action_code IS NOT NULL and p_pub_freight_costs.action_code <> FND_API.G_MISS_CHAR) THEN
      l_in_rec.action_code:= p_pub_freight_costs.action_code;
   ELSE
      l_in_rec.action_code:= p_action_code;
   END IF;

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

   FND_MSG_PUB.Count_And_Get (
       p_count => x_msg_count,
       p_data  => x_msg_data);

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;

  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     FND_MSG_PUB.Count_And_Get (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE);
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',
                                         WSH_DEBUG_SV.C_EXCEP_LEVEL);
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
END Create_Update_Freight_Costs;

--Harmonizing Project **heali


END WSH_FREIGHT_COSTS_PUB;

/
