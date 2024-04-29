--------------------------------------------------------
--  DDL for Package Body WSH_CARRIERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CARRIERS_GRP" AS
/* $Header: WSHCAGPB.pls 120.5 2005/10/28 17:47:54 somanaam noship $ */
--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_CARRIERS_GRP';

  --========================================================================
  -- PROCEDURE : Create_Update_Carrier
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code ( CREATE,UPDATE and CREATE_UPDATE )
  --             p_rec_attr_tab          Table of attributes for the carrier entity
  --             p_carrier_name          carrier Name
  --             p_status                status
  --             x_car_out_rec_tab       Table of carrier_id
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : Creates or updates a record in wsh_carriers
  --========================================================================
  PROCEDURE Create_Update_Carrier
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_rec_attr_tab           IN   Carrier_Rec_Type,
        p_carrier_name           IN   VARCHAR2,
        p_status                 IN   VARCHAR2,
        x_car_out_rec_tab        OUT  NOCOPY Carrier_Out_Rec_Type,
        x_return_status          OUT  NOCOPY VARCHAR2,
        x_msg_count              OUT  NOCOPY NUMBER,
        x_msg_data               OUT  NOCOPY VARCHAR2)
  IS

      CURSOR get_carrier_id(p_carrier_name VARCHAR2,fr_code VARCHAR2) is
        SELECT carrier_id
        FROM WSH_CARRIERS car, HZ_PARTIES par
        WHERE car.carrier_id = par.PARTY_ID
        AND par.PARTY_NAME = p_carrier_name
        AND car.FREIGHT_CODE = fr_code;

      CURSOR get_ftcode_carrier_id(fr_code VARCHAR2) is
        SELECT carrier_id
        FROM WSH_CARRIERS
        WHERE FREIGHT_CODE = fr_code;


      l_debug_on BOOLEAN;

      l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_CARRIER';

      l_index                  NUMBER;
      l_num_warnings           NUMBER := 0;
      l_num_errors             NUMBER := 0;
      l_return_status          VARCHAR2(1) := 'S';
      l_exception_msg          VARCHAR2(1000);
      l_position               NUMBER;
      l_action_code            VARCHAR2(200);
      l_call_procedure         VARCHAR2(100);
      l_sql_code               NUMBER;
      l_sqlerr                 VARCHAR2(2000);


      l_api_version_number     CONSTANT NUMBER := 1.0;
      l_api_name               CONSTANT VARCHAR2(30):= 'Create_Update_Carrier';
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(32767);

      l_input_param_flag      BOOLEAN := TRUE;
      l_param_name            VARCHAR2(100);

      l_Carrier_Info           WSH_CREATE_CARRIERS_PKG.CARecType;
      l_carrier_id             NUMBER := 0;
      l_rowid                  VARCHAR2(4000);

      --- Bug 3392826 Start: Validation

      -- Cursors for Carrier Validation

      CURSOR Get_SCAC_Code_Create(p_scac_code VARCHAR2) IS
         SELECT carrier_id
         FROM   wsh_carriers
         WHERE  SCAC_CODE = p_scac_code;

      CURSOR Get_SCAC_Code_Update(p_carrier_id NUMBER, p_scac_code VARCHAR2) IS
         SELECT carrier_id
         FROM   wsh_carriers
         WHERE  SCAC_CODE = p_scac_code
	 AND    carrier_id <> p_carrier_id;


      CURSOR Get_Freight_Code_Create(p_freight_code VARCHAR2) IS
         SELECT carrier_id
         FROM   wsh_carriers
         WHERE  upper(FREIGHT_CODE) = upper(p_freight_code);

     CURSOR Get_Freight_Code_Update(p_carrier_id NUMBER, p_freight_code VARCHAR2) IS
         SELECT carrier_id
         FROM   wsh_carriers
         WHERE  upper(FREIGHT_CODE) = upper(p_freight_code)
	 AND    carrier_id <> p_carrier_id;

      CURSOR Get_Carrier_Name_Create(p_carrier_name VARCHAR2) IS
         SELECT carrier_id
         FROM   wsh_carriers_v wc
         WHERE  wc.active= 'A'  AND
                upper(wc.carrier_name) = upper(p_carrier_name);

     CURSOR Get_Carrier_Name_Update(p_carrier_id NUMBER,p_carrier_name VARCHAR2) IS
         SELECT carrier_id
         FROM    wsh_carriers_v wc
         WHERE  wc.active = 'A'
         AND  upper(wc.carrier_name) = upper(p_carrier_name)
         AND   wc.carrier_id <> p_carrier_id;

      CURSOR Check_Generic_Carr(p_freight_code VARCHAR2) IS
         SELECT carrier_name
         FROM   wsh_carriers_v
         WHERE  nvl(generic_flag, 'N') = 'Y' AND
                freight_code <> nvl(p_freight_code, ' ') AND
                active = 'A';

      l_carrier_name  VARCHAR2(360) := null;
      l_car_id        NUMBER;
      l_count         NUMBER;
      l_supplier_id   NUMBER;

      --- Bug 3392826 End

  BEGIN

      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
      )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.push (l_module_name);
        wsh_debug_sv.log (l_module_name,'action_code',p_action_code);
      END IF;
      IF p_action_code IS NULL THEN
        l_param_name := 'action_code';
        l_input_param_flag := FALSE;
      ELSIF p_carrier_name IS NULL  THEN
        l_param_name := 'p_carrier_name';
        l_input_param_flag := FALSE;
      ELSIF p_rec_attr_tab.FREIGHT_CODE IS NULL  THEN
        l_param_name := 'Carrier_Rec_Type.freight_code';
        l_input_param_flag := FALSE;
      END IF;

      IF not l_input_param_flag THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      OPEN get_carrier_id(p_carrier_name,p_rec_attr_tab.FREIGHT_CODE);
      FETCH get_carrier_id INTO l_carrier_id;

      IF  get_carrier_id%NOTFOUND THEN

          l_carrier_id :=0;
          OPEN get_ftcode_carrier_id(p_rec_attr_tab.FREIGHT_CODE);

            FETCH get_ftcode_carrier_id INTO l_carrier_id;
            IF  get_ftcode_carrier_id%NOTFOUND THEN
              l_carrier_id := 0;
            END IF;

            close get_ftcode_carrier_id;
      END IF;
      close get_carrier_id;

      IF p_action_code = 'CREATE_UPDATE' THEN
        IF  l_carrier_id = 0 THEN
          l_action_code := 'CREATE';
        ELSE
          l_action_code := 'UPDATE';
        END IF;
      END IF;


      -- DFF Assignment
      l_Carrier_Info.ATTRIBUTE_CATEGORY            := p_rec_attr_tab.ATTRIBUTE_CATEGORY;
      l_Carrier_Info.ATTRIBUTE1                    := p_rec_attr_tab.ATTRIBUTE1;
      l_Carrier_Info.ATTRIBUTE2                    := p_rec_attr_tab.ATTRIBUTE2;
      l_Carrier_Info.ATTRIBUTE3                    := p_rec_attr_tab.ATTRIBUTE3;
      l_Carrier_Info.ATTRIBUTE4                    := p_rec_attr_tab.ATTRIBUTE4;
      l_Carrier_Info.ATTRIBUTE5                    := p_rec_attr_tab.ATTRIBUTE5;
      l_Carrier_Info.ATTRIBUTE6                    := p_rec_attr_tab.ATTRIBUTE6;
      l_Carrier_Info.ATTRIBUTE7                    := p_rec_attr_tab.ATTRIBUTE7;
      l_Carrier_Info.ATTRIBUTE8                    := p_rec_attr_tab.ATTRIBUTE8;
      l_Carrier_Info.ATTRIBUTE9                    := p_rec_attr_tab.ATTRIBUTE9;
      l_Carrier_Info.ATTRIBUTE10                   := p_rec_attr_tab.ATTRIBUTE10;
      l_Carrier_Info.ATTRIBUTE11                   := p_rec_attr_tab.ATTRIBUTE11;
      l_Carrier_Info.ATTRIBUTE12                   := p_rec_attr_tab.ATTRIBUTE12;
      l_Carrier_Info.ATTRIBUTE13                   := p_rec_attr_tab.ATTRIBUTE13;
      l_Carrier_Info.ATTRIBUTE14                   := p_rec_attr_tab.ATTRIBUTE14;
      l_Carrier_Info.ATTRIBUTE15                   := p_rec_attr_tab.ATTRIBUTE15;

      -- Pack J
      l_Carrier_Info.CARRIER_NAME                  := p_carrier_name;
      l_Carrier_Info.FREIGHT_CODE                  := p_rec_attr_tab.FREIGHT_CODE;
      l_Carrier_Info.STATUS                        := p_status;
      l_Carrier_Info.SCAC_CODE                     := p_rec_attr_tab.SCAC_CODE;
      l_Carrier_Info.MANIFESTING_ENABLED           := p_rec_attr_tab.MANIFESTING_ENABLED_FLAG;
      l_Carrier_Info.CURRENCY_CODE                 := p_rec_attr_tab.CURRENCY_CODE;

      l_Carrier_info.GENERIC_FLAG                  := p_rec_attr_tab.GENERIC_FLAG;
      l_Carrier_info.WEIGHT_UOM                    := p_rec_attr_tab.WEIGHT_UOM;
      l_Carrier_info.TIME_UOM                      := p_rec_attr_tab.TIME_UOM;
      l_Carrier_info.DIMENSION_UOM                 := p_rec_attr_tab.DIMENSION_UOM;
      l_Carrier_info.VOLUME_UOM                    := p_rec_attr_tab.VOLUME_UOM;
      l_Carrier_info.DISTANCE_UOM                  := p_rec_attr_tab.DISTANCE_UOM;
      l_Carrier_info.SUPPLIER_ID                   := p_rec_attr_tab.SUPPLIER_ID;
      l_Carrier_info.SUPPLIER_SITE_ID              := p_rec_attr_tab.SUPPLIER_SITE_ID;
      l_Carrier_info.FREIGHT_BILL_AUTO_APPROVAL    := p_rec_attr_tab.FREIGHT_BILL_AUTO_APPROVAL;
      l_Carrier_info.FREIGHT_AUDIT_LINE_LEVEL      := p_rec_attr_tab.FREIGHT_AUDIT_LINE_LEVEL;
      l_Carrier_info.DISTANCE_CALCULATION_METHOD   := p_rec_attr_tab.DISTANCE_CALCULATION_METHOD;
      l_Carrier_info.CM_RATE_VARIANT               := p_rec_attr_tab.CM_RATE_VARIANT;
      l_Carrier_info.UNIT_RATE_BASIS               := p_rec_attr_tab.UNIT_RATE_BASIS;
      l_Carrier_info.MAX_OUT_OF_ROUTE              := p_rec_attr_tab.MAX_OUT_OF_ROUTE;
      l_Carrier_info.CM_FIRST_LOAD_DISCOUNT        := p_rec_attr_tab.CM_FIRST_LOAD_DISCOUNT;
      l_Carrier_info.CM_FREE_DH_MILEAGE            := p_rec_attr_tab.CM_FREE_DH_MILEAGE;
      l_Carrier_info.MIN_CM_TIME                   := p_rec_attr_tab.MIN_CM_TIME;
      l_Carrier_info.MIN_CM_DISTANCE               := p_rec_attr_tab.MIN_CM_DISTANCE;
      l_Carrier_info.ALLOW_INTERSPERSE_LOAD        := p_rec_attr_tab.ALLOW_INTERSPERSE_LOAD;
      l_Carrier_info.MAX_NUM_STOPS_PERMITTED       := p_rec_attr_tab.MAX_NUM_STOPS_PERMITTED;
      l_Carrier_info.MAX_TOTAL_DISTANCE            := p_rec_attr_tab.MAX_TOTAL_DISTANCE;
      l_Carrier_info.MAX_TOTAL_TIME                := p_rec_attr_tab.MAX_TOTAL_TIME;
      l_Carrier_info.MAX_CM_TIME                   := p_rec_attr_tab.MAX_CM_TIME;
      l_Carrier_info.MAX_CM_DISTANCE               := p_rec_attr_tab.MAX_CM_DISTANCE;
      l_Carrier_info.MAX_CM_DH_DISTANCE            := p_rec_attr_tab.MAX_CM_DH_DISTANCE;
      l_Carrier_info.MAX_LAYOVER_TIME              := p_rec_attr_tab.MAX_LAYOVER_TIME;
      l_Carrier_info.MIN_LAYOVER_TIME              := p_rec_attr_tab.MIN_LAYOVER_TIME;
      l_Carrier_info.MAX_TOTAL_DISTANCE_IN_24HR    := p_rec_attr_tab.MAX_TOTAL_DISTANCE_IN_24HR;
      l_Carrier_info.MAX_DRIVING_TIME_IN_24HR      := p_rec_attr_tab.MAX_DRIVING_TIME_IN_24HR;
      l_Carrier_info.MAX_DUTY_TIME_IN_24HR         := p_rec_attr_tab.MAX_DUTY_TIME_IN_24HR;
      l_Carrier_info.MIN_SIZE_LENGTH               := p_rec_attr_tab.MIN_SIZE_LENGTH;
      l_Carrier_info.MAX_SIZE_LENGTH               := p_rec_attr_tab.MAX_SIZE_LENGTH;
      l_Carrier_info.MIN_SIZE_HEIGHT               := p_rec_attr_tab.MIN_SIZE_HEIGHT;
      l_Carrier_info.MAX_SIZE_HEIGHT               := p_rec_attr_tab.MAX_SIZE_HEIGHT;
      l_Carrier_info.MIN_SIZE_WIDTH                := p_rec_attr_tab.MIN_SIZE_WIDTH;
      l_Carrier_info.MAX_SIZE_WIDTH                := p_rec_attr_tab.MAX_SIZE_WIDTH;
      l_Carrier_info.ALLOW_INTERSPERSE_LOAD        := p_rec_attr_tab.ALLOW_INTERSPERSE_LOAD;
      l_Carrier_info.MAX_CM_DH_TIME                := p_rec_attr_tab.MAX_CM_DH_TIME;
      l_Carrier_info.ORIGIN_DSTN_SURCHARGE_LEVEL   := p_rec_attr_tab.ORIGIN_DSTN_SURCHARGE_LEVEL;

      IF p_action_code = 'CREATE' OR l_action_code = 'CREATE' THEN

      --- Bug 3392826 Start: Validation for carriers

            -- SCAC code
            OPEN  Get_SCAC_Code_Create(l_Carrier_Info.SCAC_CODE);
            FETCH Get_SCAC_Code_Create INTO l_car_id;
	    IF Get_SCAC_Code_Create%FOUND THEN
	        FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_SCAC_CODE_EXISTS');
                x_return_status := wsh_util_core.g_ret_sts_error;
                wsh_util_core.add_message(x_return_status,l_module_name);
                RAISE FND_API.G_EXC_ERROR;
	    END IF;
            CLOSE Get_SCAC_Code_Create;

            -- freight code
            OPEN  Get_Freight_Code_Create(l_Carrier_Info.FREIGHT_CODE);
            FETCH Get_Freight_Code_Create INTO l_car_id;
	    IF  Get_Freight_Code_Create%FOUND THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_FRG_CODE_EXISTS');
		x_return_status := wsh_util_core.g_ret_sts_error;
		wsh_util_core.add_message(x_return_status,l_module_name);
		RAISE FND_API.G_EXC_ERROR;
	    END IF;
            CLOSE Get_Freight_Code_Create;

	     -- Carrier name
	    OPEN  Get_Carrier_Name_Create(l_Carrier_Info.CARRIER_NAME);
            FETCH Get_Carrier_Name_Create INTO l_car_id;

            IF Get_Carrier_Name_Create%FOUND THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_NAME_EXISTS');
		x_return_status := wsh_util_core.g_ret_sts_error;
		wsh_util_core.add_message(x_return_status,l_module_name);
		RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE Get_Carrier_Name_Create;


            -- Carrier already designated as Generic Carrier
	    IF l_Carrier_info.GENERIC_FLAG = 'Y' THEN

                OPEN  Check_Generic_Carr(l_Carrier_Info.FREIGHT_CODE);
   	        FETCH Check_Generic_Carr INTO l_carrier_name;
    	        CLOSE Check_Generic_Carr;

	        IF l_carrier_name IS NOT NULL THEN
		    FND_MESSAGE.SET_NAME('WSH','WSH_GENERIC_CARRIER_EXISTS');
	            FND_MESSAGE.SET_TOKEN('CARRIER_NAME', l_carrier_name);
		    x_return_status := wsh_util_core.g_ret_sts_error;
		    wsh_util_core.add_message(x_return_status,l_module_name);
		    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;
      --- Bug 3392826 End

	              WSH_CREATE_CARRIERS_PKG.CREATE_CARRIERINFO
                (
                 P_CARRIER_INFO        => l_Carrier_Info,
                 P_COMMIT              => p_commit,
                 X_ROWID               => l_rowid,
                 X_CARRIER_PARTY_ID    => l_carrier_id,
                 X_RETURN_STATUS       => l_return_status,
                 X_EXCEPTION_MSG       => l_exception_msg,
                 X_POSITION            => l_position,
                 X_PROCEDURE           => l_call_procedure,
                 X_SQLERR              => l_sqlerr,
                 X_SQL_CODE            => l_sql_code
              );

                WSH_UTIL_CORE.api_post_call
                (
                 p_return_status    =>l_return_status,
                 x_num_warnings     =>l_num_warnings,
                 x_num_errors       =>l_num_errors
                );
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'return status WSH_CREATE_CARRIERS_PKG.CREATE_CARRIERINFO',l_return_status);
        END IF;

      ELSIF p_action_code = 'UPDATE' OR l_action_code = 'UPDATE' THEN

        -- Pack J
        l_Carrier_info.CARRIER_ID := l_carrier_id;

      --- Bug 3392826 Start: Validation for carriers

        -- SCAC code
        OPEN  Get_SCAC_Code_Update(l_Carrier_Info.carrier_id, l_Carrier_Info.SCAC_CODE);
        FETCH Get_SCAC_Code_Update INTO l_car_id;
	IF Get_SCAC_Code_Update%FOUND  THEN
	   FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_SCAC_CODE_EXISTS');
           x_return_status := wsh_util_core.g_ret_sts_error;
           wsh_util_core.add_message(x_return_status,l_module_name);
           RAISE FND_API.G_EXC_ERROR;
	END IF;
        CLOSE Get_SCAC_Code_Update;

            -- Carrier name
	    OPEN  Get_Carrier_Name_Update(l_Carrier_Info.carrier_id, l_Carrier_Info.CARRIER_NAME);
            FETCH Get_Carrier_Name_Update INTO l_car_id;

            IF Get_Carrier_Name_Update%FOUND THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_NAME_EXISTS');
		x_return_status := wsh_util_core.g_ret_sts_error;
		wsh_util_core.add_message(x_return_status,l_module_name);
		RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE Get_Carrier_Name_Update;


            -- Carrier already designated as Generic Carrier
	    IF l_Carrier_info.GENERIC_FLAG = 'Y' THEN
	       l_Carrier_info.GENERIC_FLAG := 'N';
            END IF;

	 --- Bug 3392826 End

        -- If carrier is deactivated,
        -- deactivate Services and Organization Assignments.
        IF p_status = 'I' THEN
          WSH_CREATE_CARRIERS_PKG.CARRIER_DEACTIVATE
                (
                 p_carrier_id          => l_carrier_id,
                 X_RETURN_STATUS       => l_return_status,
                 X_EXCEPTION_MSG       => l_exception_msg,
                 X_POSITION            => l_position,
                 X_PROCEDURE           => l_call_procedure,
                 X_SQLERR              => l_sqlerr,
                 X_SQL_CODE            => l_sql_code
                );
        END IF;

        WSH_UTIL_CORE.api_post_call
                (
                 p_return_status    =>l_return_status,
                 x_num_warnings     =>l_num_warnings,
                 x_num_errors       =>l_num_errors
                );


        WSH_CREATE_CARRIERS_PKG.UPDATE_CARRIERINFO
                (
                 P_CARRIER_INFO        => l_Carrier_Info,
                 P_COMMIT              => p_commit,
                 X_RETURN_STATUS       => l_return_status,
                 X_EXCEPTION_MSG       => l_exception_msg,
                 X_POSITION            => l_position,
                 X_PROCEDURE           => l_call_procedure,
                 X_SQLERR              => l_sqlerr,
                 X_SQL_CODE            => l_sql_code
              );

        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'return status WSH_CREATE_CARRIERS_PKG.UPDATE_CARRIERINFO',l_return_status);
        END IF;

      END IF;
      WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                  x_num_warnings     =>l_num_warnings,
                                  x_num_errors       =>l_num_errors
                                  );
      x_car_out_rec_tab.rowid := l_rowid;
      x_car_out_rec_tab.carrier_id := l_carrier_id;
      x_return_status := l_return_status;
      IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
      END IF;
      EXCEPTION
       --
       --
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
             p_count  => x_msg_count,
             p_data  =>  x_msg_data,
             p_encoded => FND_API.G_FALSE
          );

          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

	  IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

        WHEN OTHERS THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

	  IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

  END Create_Update_Carrier;

  --========================================================================
  -- PROCEDURE : Create_Update_Carrier_Service
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code ( CREATE,UPDATE and CREATE_UPDATE )
  --             p_rec_attr_tab          Table of attributes for the carrier service entity
  --             x_car_ser_out_rec_tab   Table of carrier_service_id, and ship_method_code.
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : Creates or updates a record in wsh_carrier_services
  --========================================================================
  PROCEDURE Create_Update_Carrier_Service
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_rec_attr_tab           IN   Carrier_Service_Rec_Type,
        x_car_ser_out_rec_tab    OUT  NOCOPY Carrier_Ser_Out_Rec_Type,
        x_return_status          OUT  NOCOPY VARCHAR2,
        x_msg_count              OUT  NOCOPY NUMBER,
        x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
      l_debug_on BOOLEAN;

      l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_CARRIER_SERVICE';

      l_index                  NUMBER;
      l_num_warnings           NUMBER := 0;
      l_num_errors             NUMBER := 0;
      l_return_status          VARCHAR2(1) := 'S';
      l_exception_msg          VARCHAR2(1000);
      l_position               NUMBER;
      l_action_code            VARCHAR2(200);
      l_call_procedure         VARCHAR2(100);
      l_sql_code               NUMBER;
      l_sqlerr                 VARCHAR2(2000);


      l_api_version_number     CONSTANT NUMBER := 1.0;
      l_api_name               CONSTANT VARCHAR2(30):= 'Create_Update_Carrier_Service';
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(32767);

      l_input_param_flag      BOOLEAN := TRUE;
      l_param_name            VARCHAR2(100);

      l_carrier_ser_tab        WSH_CARRIER_SERVICES_PKG.CSRecType;
      l_carrier_service_id     NUMBER;
      l_rowid                  VARCHAR2(4000) := NULL;

      l_service_level_code     VARCHAR2(4000);
      l_sl_time_uom_desc       VARCHAR2(4000);
      l_mode_of_trans_code     VARCHAR2(4000);
      l_freight_code           VARCHAR2(4000);
      l_ship_method_code       VARCHAR2(4000);
      l_ship_method_meaning    VARCHAR2(4000);

      CURSOR get_carrier_ser_id(p_carrier_id INTEGER,p_service_level_code VARCHAR2, p_mode_of_transport VARCHAR2) is
        SELECT carrier_id
        FROM WSH_CARRIER_SERVICES
        WHERE carrier_id = p_carrier_id
        AND service_level = p_service_level_code
        AND MODE_OF_TRANSPORT = p_mode_of_transport;


      CURSOR get_freight_code(p_carrier_id INTEGER) is
        SELECT freight_code
        FROM WSH_CARRIERS
        WHERE carrier_id = p_carrier_id;



      CURSOR get_rowid_shpcode(p_carrier_id INTEGER, p_service_level VARCHAR2, p_mode_of_transport VARCHAR2) is
        SELECT rowid,ship_method_code
        FROM wsh_carrier_services
        WHERE carrier_id= p_carrier_id
        AND   service_level = p_service_level
        AND   mode_of_transport = p_mode_of_transport;

      --- Bug 3392826 Start: Validation for Services
      -- Cursors for Services Validation

      CURSOR Check_Duplicate(p_mode_of_transport VARCHAR2, p_service_level VARCHAR2, p_carrier_id NUMBER) IS
	 SELECT count(*)
	 FROM   wsh_carrier_services
	 WHERE  mode_of_transport = p_mode_of_transport AND
	        service_level     = p_service_level AND
		carrier_id = p_carrier_id;

      CURSOR Check_Duplicate_SMM_Create(p_ship_method_meaning VARCHAR2) IS
	 SELECT rowid
	 FROM   wsh_carrier_services
	 WHERE  SHIP_METHOD_MEANING = p_ship_method_meaning;

      CURSOR Check_Duplicate_SMM_Update(p_rowid VARCHAR2, p_ship_method_meaning VARCHAR2) IS
	 SELECT rowid
	 FROM   wsh_carrier_services
	 WHERE  SHIP_METHOD_MEANING = p_ship_method_meaning
	 AND    rowid <> p_rowid;

      l_count NUMBER := 0;
      l_serv_rowid    VARCHAR2(4000) := NULL;

      --- Bug 3392826 End

    BEGIN

      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;


      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
      )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.push (l_module_name);
        wsh_debug_sv.log (l_module_name,'action_code',p_action_code);
      END IF;
      IF p_action_code IS NULL THEN
        l_param_name := 'action_code';
        l_input_param_flag := FALSE;
      ELSIF p_rec_attr_tab.carrier_id IS NULL THEN
        l_param_name := 'carrier_id';
        l_input_param_flag := FALSE;
      ELSIF p_rec_attr_tab.SERVICE_LEVEL IS NULL THEN
        l_param_name := 'SERVICE_LEVEL(CODE)';
        l_input_param_flag := FALSE;
      ELSIF p_rec_attr_tab.MODE_OF_TRANSPORT IS NULL THEN
        l_param_name := 'MODE_OF_TRANSPORT(CODE)';
        l_input_param_flag := FALSE;
      END IF;

      IF not l_input_param_flag THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --

      IF p_action_code = 'CREATE_UPDATE' THEN
        OPEN get_carrier_ser_id(p_rec_attr_tab.carrier_id,p_rec_attr_tab.SERVICE_LEVEL,p_rec_attr_tab.MODE_OF_TRANSPORT);
        FETCH get_carrier_ser_id INTO l_carrier_service_id;
        IF get_carrier_ser_id%NOTFOUND  THEN
          l_action_code := 'CREATE';
        ELSE
          l_action_code := 'UPDATE';

        END IF;
        close get_carrier_ser_id;
      END IF;

      OPEN get_freight_code(p_rec_attr_tab.carrier_id);
      FETCH get_freight_code INTO l_freight_code;
      close get_freight_code;
      Get_Meanings
      (
        x_service_level      => l_service_level_code,
        service_level_code => p_rec_attr_tab.SERVICE_LEVEL,
        x_mode_of_transport  => l_mode_of_trans_code,
        mode_of_trans_code => p_rec_attr_tab.MODE_OF_TRANSPORT,
        sl_time_uom        => p_rec_attr_tab.SL_TIME_UOM,
        x_sl_time_uom_desc   => l_sl_time_uom_desc
      );
      l_ship_method_meaning := p_rec_attr_tab.SHIP_METHOD_MEANING;
      IF l_ship_method_meaning IS NULL THEN
        l_ship_method_meaning := l_freight_code || '-' || p_rec_attr_tab.MODE_OF_TRANSPORT || '-' || substr(l_service_level_code,1,48);
      END IF;

      l_carrier_ser_tab.Carrier_Service_id := p_rec_attr_tab.CARRIER_SERVICE_ID;
      l_carrier_ser_tab.Carrier_Id         := p_rec_attr_tab.CARRIER_ID;
      l_carrier_ser_tab.mode_of_transport  := p_rec_attr_tab.MODE_OF_TRANSPORT;
      l_carrier_ser_tab.Enabled_Flag       := p_rec_attr_tab.ENABLED_FLAG;
      l_carrier_ser_tab.sl_time_uom        := p_rec_attr_tab.SL_TIME_UOM;
      l_carrier_ser_tab.service_level      := p_rec_attr_tab.SERVICE_LEVEL;
      l_carrier_ser_tab.min_sl_time        := p_rec_attr_tab.MIN_SL_TIME;
      l_carrier_ser_tab.max_sl_time        := p_rec_attr_tab.MAX_SL_TIME;
      l_carrier_ser_tab.Web_Enabled        := p_rec_attr_tab.WEB_ENABLED;
      l_carrier_ser_tab.ship_method_meaning:= l_ship_method_meaning;
      l_carrier_ser_tab.ATTRIBUTE_CATEGORY := p_rec_attr_tab.ATTRIBUTE_CATEGORY;
      l_carrier_ser_tab.ATTRIBUTE1         := p_rec_attr_tab.ATTRIBUTE1;
      l_carrier_ser_tab.ATTRIBUTE2         := p_rec_attr_tab.ATTRIBUTE2;
      l_carrier_ser_tab.ATTRIBUTE3         := p_rec_attr_tab.ATTRIBUTE3;
      l_carrier_ser_tab.ATTRIBUTE4         := p_rec_attr_tab.ATTRIBUTE4;
      l_carrier_ser_tab.ATTRIBUTE5         := p_rec_attr_tab.ATTRIBUTE5;
      l_carrier_ser_tab.ATTRIBUTE6         := p_rec_attr_tab.ATTRIBUTE6;
      l_carrier_ser_tab.ATTRIBUTE7         := p_rec_attr_tab.ATTRIBUTE7;
      l_carrier_ser_tab.ATTRIBUTE8         := p_rec_attr_tab.ATTRIBUTE8;
      l_carrier_ser_tab.ATTRIBUTE9         := p_rec_attr_tab.ATTRIBUTE9;
      l_carrier_ser_tab.ATTRIBUTE10        := p_rec_attr_tab.ATTRIBUTE10;
      l_carrier_ser_tab.ATTRIBUTE11        := p_rec_attr_tab.ATTRIBUTE11;
      l_carrier_ser_tab.ATTRIBUTE12        := p_rec_attr_tab.ATTRIBUTE12;
      l_carrier_ser_tab.ATTRIBUTE13        := p_rec_attr_tab.ATTRIBUTE13;
      l_carrier_ser_tab.ATTRIBUTE14        := p_rec_attr_tab.ATTRIBUTE14;
      l_carrier_ser_tab.ATTRIBUTE15        := p_rec_attr_tab.ATTRIBUTE15;
      l_carrier_ser_tab.Creation_Date      := SYSDATE;
      l_carrier_ser_tab.Created_By         := fnd_global.user_id;
      l_carrier_ser_tab.Last_Update_Date   := SYSDATE;
      l_carrier_ser_tab.Last_Updated_By    := fnd_global.user_id;

      -- Pack J
      l_carrier_ser_tab.MAX_NUM_STOPS_PERMITTED        := p_rec_attr_tab.MAX_NUM_STOPS_PERMITTED;
      l_carrier_ser_tab.MAX_TOTAL_DISTANCE             := p_rec_attr_tab.MAX_TOTAL_DISTANCE;
      l_carrier_ser_tab.MAX_TOTAL_TIME                 := p_rec_attr_tab.MAX_TOTAL_TIME;
      l_carrier_ser_tab.ALLOW_INTERSPERSE_LOAD         := p_rec_attr_tab.ALLOW_INTERSPERSE_LOAD;
      l_carrier_ser_tab.MAX_LAYOVER_TIME               := p_rec_attr_tab.MAX_LAYOVER_TIME;
      l_carrier_ser_tab.MIN_LAYOVER_TIME               := p_rec_attr_tab.MIN_LAYOVER_TIME;
      l_carrier_ser_tab.MAX_TOTAL_DISTANCE_IN_24HR     := p_rec_attr_tab.MAX_TOTAL_DISTANCE_IN_24HR;
      l_carrier_ser_tab.MAX_DRIVING_TIME_IN_24HR       := p_rec_attr_tab.MAX_DRIVING_TIME_IN_24HR;
      l_carrier_ser_tab.MAX_DUTY_TIME_IN_24HR          := p_rec_attr_tab.MAX_DUTY_TIME_IN_24HR;
      l_carrier_ser_tab.MAX_CM_DISTANCE                := p_rec_attr_tab.MAX_CM_DISTANCE;
      l_carrier_ser_tab.MAX_CM_TIME                    := p_rec_attr_tab.MAX_CM_TIME;
      l_carrier_ser_tab.MAX_CM_DH_DISTANCE             := p_rec_attr_tab.MAX_CM_DH_DISTANCE;
      l_carrier_ser_tab.MAX_SIZE_WIDTH                 := p_rec_attr_tab.MAX_SIZE_WIDTH;
      l_carrier_ser_tab.MAX_SIZE_HEIGHT                := p_rec_attr_tab.MAX_SIZE_HEIGHT;
      l_carrier_ser_tab.MAX_SIZE_LENGTH                := p_rec_attr_tab.MAX_SIZE_LENGTH;
      l_carrier_ser_tab.MIN_SIZE_WIDTH                 := p_rec_attr_tab.MIN_SIZE_WIDTH;
      l_carrier_ser_tab.MIN_SIZE_HEIGHT                := p_rec_attr_tab.MIN_SIZE_HEIGHT;
      l_carrier_ser_tab.MIN_SIZE_LENGTH                := p_rec_attr_tab.MIN_SIZE_LENGTH;
      l_carrier_ser_tab.MAX_OUT_OF_ROUTE               := p_rec_attr_tab.MAX_OUT_OF_ROUTE;
      l_carrier_ser_tab.CM_FREE_DH_MILEAGE             := p_rec_attr_tab.CM_FREE_DH_MILEAGE;
      l_carrier_ser_tab.MIN_CM_DISTANCE                := p_rec_attr_tab.MIN_CM_DISTANCE;
      l_carrier_ser_tab.CM_FIRST_LOAD_DISCOUNT         := p_rec_attr_tab.CM_FIRST_LOAD_DISCOUNT;
      l_carrier_ser_tab.MIN_CM_TIME                    := p_rec_attr_tab.MIN_CM_TIME;
      l_carrier_ser_tab.UNIT_RATE_BASIS                := p_rec_attr_tab.UNIT_RATE_BASIS;
      l_carrier_ser_tab.CM_RATE_VARIANT                := p_rec_attr_tab.CM_RATE_VARIANT;
      l_carrier_ser_tab.DISTANCE_CALCULATION_METHOD    := p_rec_attr_tab.DISTANCE_CALCULATION_METHOD;
      l_carrier_ser_tab.ALLOW_INTERSPERSE_LOAD         := p_rec_attr_tab.ALLOW_INTERSPERSE_LOAD;
      l_carrier_ser_tab.MAX_CM_DH_TIME                 := p_rec_attr_tab.MAX_CM_DH_TIME;
      l_carrier_ser_tab.ORIGIN_DSTN_SURCHARGE_LEVEL    := p_rec_attr_tab.ORIGIN_DSTN_SURCHARGE_LEVEL;

      IF p_action_code = 'CREATE' OR l_action_code = 'CREATE' THEN
        Generate_Ship_Method
        (
          service_level_code  => p_rec_attr_tab.SERVICE_LEVEL,
          freight_code        => l_freight_code,
          mode_of_trans_code  => l_mode_of_trans_code,
          ship_method_meaning => l_ship_method_meaning,
          x_ship_method_code  => l_ship_method_code
        );
        l_carrier_ser_tab.ship_method_code   := l_ship_method_code;

        --- Bug 3392826 Start: Validation for Services
	-- Record with this combination already exists.
        IF ((l_carrier_ser_tab.mode_of_transport IS NOT NULL) AND
	   (l_carrier_ser_tab.service_level IS NOT NULL)) THEN
	    OPEN Check_Duplicate(l_carrier_ser_tab.mode_of_transport, l_carrier_ser_tab.service_level, l_carrier_ser_tab.Carrier_Id);
	    FETCH Check_Duplicate INTO l_count;
	    CLOSE Check_Duplicate;

	    IF l_count >0 THEN
	      fnd_message.set_name('WSH','WSH_DUPLICATE_RECORD');
	      x_return_status := wsh_util_core.g_ret_sts_error;
	      wsh_util_core.add_message(x_return_status,l_module_name);
	      RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         --- This Ship Method Meaning is already existing.
         OPEN Check_Duplicate_SMM_Create(l_carrier_ser_tab.ship_method_meaning);
         FETCH Check_Duplicate_SMM_Create INTO l_serv_rowid;
	 IF Check_Duplicate_SMM_Create%FOUND THEN
	    fnd_message.set_name('WSH','WSH_SHIP_METHOD_EXISTS');
	    x_return_status := wsh_util_core.g_ret_sts_error;
	    wsh_util_core.add_message(x_return_status,l_module_name);
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
         CLOSE Check_Duplicate_SMM_Create;
        --- Bug 3392826 End: Validation for Services


	WSH_CARRIER_SERVICES_PKG.Create_Carrier_Service
                (
                 p_Carrier_Service_Info => l_carrier_ser_tab,
                 P_COMMIT              => p_commit,
                 X_ROWID               => l_rowid,
                 X_CARRIER_SERVICE_ID  => l_carrier_service_id,
                 X_RETURN_STATUS       => l_return_status,
                 X_POSITION            => l_position,
                 X_PROCEDURE           => l_call_procedure,
                 X_SQLERR              => l_sqlerr,
                 X_SQL_CODE            => l_sql_code
        );
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'return status WSH_CREATE_CARRIERS_PKG.Create_Carrier_Service',l_return_status);
        END IF;

      ELSIF p_action_code = 'UPDATE' OR l_action_code = 'UPDATE' THEN

        OPEN get_rowid_shpcode(p_rec_attr_tab.CARRIER_ID, p_rec_attr_tab.SERVICE_LEVEL, p_rec_attr_tab.MODE_OF_TRANSPORT);
        fetch get_rowid_shpcode INTO l_rowid,l_ship_method_code;
        close get_rowid_shpcode;

        --- Bug 3392826 Start: Validation for Services
	--- This Ship Method is already existing.
        OPEN Check_Duplicate_SMM_Update(l_rowid, l_carrier_ser_tab.ship_method_meaning);
        FETCH Check_Duplicate_SMM_Update INTO l_serv_rowid;
	IF Check_Duplicate_SMM_Update%FOUND THEN
            fnd_message.set_name('WSH','WSH_SHIP_METHOD_EXISTS');
	    x_return_status := wsh_util_core.g_ret_sts_error;
	    wsh_util_core.add_message(x_return_status,l_module_name);
	    RAISE FND_API.G_EXC_ERROR;
	END IF;
        CLOSE Check_Duplicate_SMM_Update;
        --- Bug 3392826 End: Validation for Services


	IF l_rowid IS NOT NULL THEN
          l_carrier_ser_tab.ship_method_code   := l_ship_method_code;
          WSH_CARRIER_SERVICES_PKG.Update_Carrier_Service
                (
                 p_Carrier_Service_Info => l_carrier_ser_tab,
                 P_ROWID               => l_rowid,
                 P_COMMIT              => p_commit,
                 X_RETURN_STATUS       => l_return_status,
                 X_POSITION            => l_position,
                 X_PROCEDURE           => l_call_procedure,
                 X_SQLERR              => l_sqlerr,
                 X_SQL_CODE            => l_sql_code,
                 X_EXCEPTION_MSG       => l_exception_msg
          );
        END IF;

        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'return status WSH_CREATE_CARRIERS_PKG.Update_Carrier_Service',l_return_status);
        END IF;

      END IF;
      WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                  x_num_warnings     =>l_num_warnings,
                                  x_num_errors       =>l_num_errors
                                  );
      x_car_ser_out_rec_tab.rowid := l_rowid;
      x_car_ser_out_rec_tab.carrier_service_id := l_carrier_service_id;
      x_car_ser_out_rec_tab.ship_method_code   := l_ship_method_code;
      x_return_status := l_return_status;

      IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
      END IF;
      EXCEPTION
       --
       --
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
             p_count  => x_msg_count,
             p_data  =>  x_msg_data,
             p_encoded => FND_API.G_FALSE
          );

          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

        WHEN OTHERS THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

	  IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

  END Create_Update_Carrier_Service;

  --========================================================================
  -- PROCEDURE : Assign_Org_Carrier_Service
  --
  --
  -- PARAMETERS: p_api_version           known api version error buffer
  --             p_init_msg_list         FND_API.G_TRUE to reset list
  --             x_return_status         return status
  --             x_msg_count             number of messages in the list
  --             x_msg_data              text of messages
  --             p_action_code           action_code (ASSIGN/UNASSIGN)
  --             p_rec_attr_tab          Table of attributes for the organization carrier service entity
  --             x_orgcar_ser_out_rec_tab   Table of orgcarrier_service_id and ship_method_code.
  -- VERSION   : current version         1.0
  --             initial version         1.0
  -- COMMENT   : Creates or updates a record in wsh_org_carrier_services
  --========================================================================
  PROCEDURE Assign_Org_Carrier_Service
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_rec_org_car_ser_tab    IN   Org_Carrier_Service_Rec_Type,
        p_rec_car_dff_tab        IN   Carrier_Info_Dff_Type,
        p_shp_methods_dff        IN   Ship_Method_Dff_Type,
        x_orgcar_ser_out_rec_tab OUT  NOCOPY Org_Carrier_Ser_Out_Rec_Type,
        x_return_status          OUT  NOCOPY VARCHAR2,
        x_msg_count              OUT  NOCOPY NUMBER,
        x_msg_data               OUT  NOCOPY VARCHAR2)
  IS
    l_debug_on BOOLEAN;

    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_ORG_CARRIER_SERVICE';

    l_index                  NUMBER;
    l_num_warnings           NUMBER := 0;
    l_num_errors             NUMBER := 0;
    l_return_status          VARCHAR2(1) := 'S';
    l_exception_msg          VARCHAR2(1000);
    l_position               NUMBER;
    l_action_code            VARCHAR2(200);
    l_call_procedure         VARCHAR2(100);
    l_sql_code               NUMBER;
    l_sqlerr                 VARCHAR2(2000);


    l_api_version_number     CONSTANT NUMBER := 1.0;
    l_api_name               CONSTANT VARCHAR2(30):= 'Assign_Org_Carrier_Service';
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(32767);

    l_input_param_flag      BOOLEAN := TRUE;
    l_param_name            VARCHAR2(100);

    l_org_car_ser_tab        WSH_ORG_CARRIER_SERVICES_PKG.OCSRecType;
    l_car_info_tab           WSH_ORG_CARRIER_SERVICES_PKG.CarRecType;
    l_shp_method_rec         WSH_CARRIER_SHIP_METHODS_PKG.CSMRecType;

    l_org_carrier_service_id NUMBER;
    l_rowid                  VARCHAR2(4000);

    l_carrier_id             NUMBER;
    l_service_level          VARCHAR2(200);
    l_shp_method_code        VARCHAR2(4000);

    l_freight_code           VARCHAR2(4000);
    l_carrier_name           VARCHAR2(4000);

    CURSOR get_carrier_ser_info(p_carrier_service_id NUMBER) IS
      SELECT CARRIER_ID,SERVICE_LEVEL,SHIP_METHOD_CODE
      FROM WSH_CARRIER_SERVICES
      WHERE carrier_service_id = p_carrier_service_id
      AND enabled_flag = 'Y';

    CURSOR get_carrier_info(p_carrier_id NUMBER) IS
        SELECT car.freight_code,par.PARTY_NAME
        FROM WSH_CARRIERS car, HZ_PARTIES par
        WHERE car.carrier_id = p_carrier_id
        AND car.carrier_id = par.PARTY_ID;

    CURSOR get_org_carser_info(p_carrier_service_id NUMBER,p_org_id NUMBER) IS
        SELECT  org_carrier_service_id,rowid
        FROM wsh_Org_Carrier_Services
        WHERE carrier_service_id = p_carrier_service_id
        AND organization_id = p_org_id;

  BEGIN
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
      )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.push (l_module_name);
        wsh_debug_sv.log (l_module_name,'action_code',p_action_code);
      END IF;
      IF p_action_code IS NULL THEN
        l_param_name := 'action_code';
        l_input_param_flag := FALSE;
      ELSIF p_rec_org_car_ser_tab.Carrier_Service_id IS NULL  THEN
        l_param_name := 'carrier_service_id';
        l_input_param_flag := FALSE;
      ELSIF p_rec_org_car_ser_tab.ORGANIZATION_ID IS NULL THEN
        l_param_name := 'organization_id';
        l_input_param_flag := FALSE;
      END IF;

      IF not l_input_param_flag THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status,l_module_name);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      OPEN get_carrier_ser_info(p_rec_org_car_ser_tab.Carrier_Service_id);
      FETCH get_carrier_ser_info INTO l_carrier_id,l_service_level,l_shp_method_code;
      if(get_carrier_ser_info%FOUND) THEN
        OPEN get_carrier_info(l_carrier_id);
        FETCH get_carrier_info INTO l_freight_code,l_carrier_name;
        close get_carrier_info;

        OPEN get_org_carser_info(p_rec_org_car_ser_tab.Carrier_Service_id,p_rec_org_car_ser_tab.ORGANIZATION_ID);
        FETCh get_org_carser_info INTO l_org_carrier_service_id,l_rowid;
        close get_org_carser_info;

        l_org_car_ser_tab.CARRIER_SERVICE_ID :=   p_rec_org_car_ser_tab.Carrier_Service_id;
        -- Can't update enabled flag of carrier service while assigning.
        --l_org_car_ser_tab.ENABLED_FLAG       :=   p_rec_org_car_ser_tab.Enabled_FLAG;
        l_org_car_ser_tab.ORGANIZATION_ID    :=   p_rec_org_car_ser_tab.ORGANIZATION_ID;
        l_org_car_ser_tab.ATTRIBUTE_CATEGORY :=   p_rec_org_car_ser_tab.ATTRIBUTE_CATEGORY;
        l_org_car_ser_tab.ATTRIBUTE1         :=   p_rec_org_car_ser_tab.ATTRIBUTE1;
        l_org_car_ser_tab.ATTRIBUTE2         :=   p_rec_org_car_ser_tab.ATTRIBUTE2;
        l_org_car_ser_tab.ATTRIBUTE3         :=   p_rec_org_car_ser_tab.ATTRIBUTE3;
        l_org_car_ser_tab.ATTRIBUTE4         :=   p_rec_org_car_ser_tab.ATTRIBUTE4;
        l_org_car_ser_tab.ATTRIBUTE5         :=   p_rec_org_car_ser_tab.ATTRIBUTE5;
        l_org_car_ser_tab.ATTRIBUTE6         :=   p_rec_org_car_ser_tab.ATTRIBUTE6;
        l_org_car_ser_tab.ATTRIBUTE7         :=   p_rec_org_car_ser_tab.ATTRIBUTE7;
        l_org_car_ser_tab.ATTRIBUTE8         :=   p_rec_org_car_ser_tab.ATTRIBUTE8;
        l_org_car_ser_tab.ATTRIBUTE9         :=   p_rec_org_car_ser_tab.ATTRIBUTE9;
        l_org_car_ser_tab.ATTRIBUTE10        :=   p_rec_org_car_ser_tab.ATTRIBUTE10;
        l_org_car_ser_tab.ATTRIBUTE11        :=   p_rec_org_car_ser_tab.ATTRIBUTE11;
        l_org_car_ser_tab.ATTRIBUTE12        :=   p_rec_org_car_ser_tab.ATTRIBUTE12;
        l_org_car_ser_tab.ATTRIBUTE13        :=   p_rec_org_car_ser_tab.ATTRIBUTE13;
        l_org_car_ser_tab.ATTRIBUTE14        :=   p_rec_org_car_ser_tab.ATTRIBUTE14;
        l_org_car_ser_tab.ATTRIBUTE15        :=   p_rec_org_car_ser_tab.ATTRIBUTE15;
        l_org_car_ser_tab.CREATION_DATE      :=   SYSDATE;
        l_org_car_ser_tab.CREATED_BY         :=   fnd_global.user_id;
        l_org_car_ser_tab.LAST_UPDATE_DATE   :=   SYSDATE;
        l_org_car_ser_tab.LAST_UPDATED_BY    :=   fnd_global.user_id;

        -- BugFix#3296461
        l_org_car_ser_tab.DISTRIBUTION_ACCOUNT := p_rec_org_car_ser_tab.DISTRIBUTION_ACCOUNT;

        l_car_info_tab.P_FREIGHT_CODE       :=    l_freight_code;
        l_car_info_tab.P_CARRIER_NAME       :=    substrb(l_carrier_name, 1, 80);
        l_car_info_tab.ATTRIBUTE_CATEGORY   :=    p_rec_car_dff_tab.ATTRIBUTE_CATEGORY;
        l_car_info_tab.ATTRIBUTE1           :=    p_rec_car_dff_tab.ATTRIBUTE1;
        l_car_info_tab.ATTRIBUTE2           :=    p_rec_car_dff_tab.ATTRIBUTE2;
        l_car_info_tab.ATTRIBUTE3           :=    p_rec_car_dff_tab.ATTRIBUTE3;
        l_car_info_tab.ATTRIBUTE4           :=    p_rec_car_dff_tab.ATTRIBUTE4;
        l_car_info_tab.ATTRIBUTE5           :=    p_rec_car_dff_tab.ATTRIBUTE5;
        l_car_info_tab.ATTRIBUTE6           :=    p_rec_car_dff_tab.ATTRIBUTE6;
        l_car_info_tab.ATTRIBUTE7           :=    p_rec_car_dff_tab.ATTRIBUTE7;
        l_car_info_tab.ATTRIBUTE8           :=    p_rec_car_dff_tab.ATTRIBUTE8;
        l_car_info_tab.ATTRIBUTE9           :=    p_rec_car_dff_tab.ATTRIBUTE9;
        l_car_info_tab.ATTRIBUTE10          :=    p_rec_car_dff_tab.ATTRIBUTE10;
        l_car_info_tab.ATTRIBUTE11          :=    p_rec_car_dff_tab.ATTRIBUTE11;
        l_car_info_tab.ATTRIBUTE12          :=    p_rec_car_dff_tab.ATTRIBUTE12;
        l_car_info_tab.ATTRIBUTE13          :=    p_rec_car_dff_tab.ATTRIBUTE13;
        l_car_info_tab.ATTRIBUTE14          :=    p_rec_car_dff_tab.ATTRIBUTE14;
        l_car_info_tab.ATTRIBUTE15          :=    p_rec_car_dff_tab.ATTRIBUTE15;
        l_car_info_tab.CREATION_DATE        :=    SYSDATE;
        l_car_info_tab.CREATED_BY           :=    fnd_global.user_id;
        l_car_info_tab.LAST_UPDATE_DATE     :=    SYSDATE;
        l_car_info_tab.LAST_UPDATED_BY      :=    fnd_global.user_id;



        l_shp_method_rec.Carrier_Id         :=    l_carrier_id;
        l_shp_method_rec.ship_method_code   :=    l_shp_method_code;
        l_shp_method_rec.freight_code       :=    l_freight_code;
        l_shp_method_rec.service_level      :=    l_service_level;
        l_shp_method_rec.organization_id    :=    p_rec_org_car_ser_tab.ORGANIZATION_ID;
        l_shp_method_rec.ATTRIBUTE_CATEGORY :=    p_shp_methods_dff.ATTRIBUTE_CATEGORY;
        l_shp_method_rec.ATTRIBUTE1         :=    p_shp_methods_dff.ATTRIBUTE1;
        l_shp_method_rec.ATTRIBUTE2         :=    p_shp_methods_dff.ATTRIBUTE2;
        l_shp_method_rec.ATTRIBUTE3         :=    p_shp_methods_dff.ATTRIBUTE3;
        l_shp_method_rec.ATTRIBUTE4         :=    p_shp_methods_dff.ATTRIBUTE4;
        l_shp_method_rec.ATTRIBUTE5         :=    p_shp_methods_dff.ATTRIBUTE5;
        l_shp_method_rec.ATTRIBUTE6         :=    p_shp_methods_dff.ATTRIBUTE6;
        l_shp_method_rec.ATTRIBUTE7         :=    p_shp_methods_dff.ATTRIBUTE7;
        l_shp_method_rec.ATTRIBUTE8         :=    p_shp_methods_dff.ATTRIBUTE8;
        l_shp_method_rec.ATTRIBUTE9         :=    p_shp_methods_dff.ATTRIBUTE9;
        l_shp_method_rec.ATTRIBUTE10        :=    p_shp_methods_dff.ATTRIBUTE10;
        l_shp_method_rec.ATTRIBUTE11        :=    p_shp_methods_dff.ATTRIBUTE11;
        l_shp_method_rec.ATTRIBUTE12        :=    p_shp_methods_dff.ATTRIBUTE12;
        l_shp_method_rec.ATTRIBUTE13        :=    p_shp_methods_dff.ATTRIBUTE13;
        l_shp_method_rec.ATTRIBUTE14        :=    p_shp_methods_dff.ATTRIBUTE14;
        l_shp_method_rec.ATTRIBUTE15        :=    p_shp_methods_dff.ATTRIBUTE15;
        l_shp_method_rec.CREATION_DATE      :=    SYSDATE;
        l_shp_method_rec.CREATED_BY         :=    fnd_global.user_id;
        l_shp_method_rec.LAST_UPDATE_DATE   :=    SYSDATE;
        l_shp_method_rec.LAST_UPDATED_BY    :=    fnd_global.user_id;
        IF p_action_code = 'ASSIGN' THEN
                  l_shp_method_rec.Enabled_Flag       :=    'Y';
                  l_org_car_ser_tab.ENABLED_FLAG       := 'Y';
        ELSIF p_action_code = 'UNASSIGN' THEN
                  l_shp_method_rec.Enabled_Flag       :=    'N';
                  l_org_car_ser_tab.ENABLED_FLAG       := 'N';
        END IF;
        IF p_action_code = 'ASSIGN' OR p_action_code = 'UNASSIGN' THEN

          WSH_ORG_CARRIER_SERVICES_PKG.assign_org_carrier_service
                  (
                   p_Org_Carrier_Service_info  =>  l_org_car_ser_tab,
                   p_carrier_info              =>  l_car_info_tab,
                   p_csm_info                  =>  l_shp_method_rec,
                   P_COMMIT                    => p_commit,
                   X_ROWID                     =>  l_rowid,
                   X_ORG_CARRIER_SERVICE_ID    =>  l_org_carrier_service_id,
                   X_RETURN_STATUS             =>  l_return_status,
                   X_POSITION                  =>  l_position,
                   X_PROCEDURE                 =>  l_call_procedure,
                   X_SQLERR                    =>  l_sqlerr,
                   X_SQL_CODE                  =>  l_sql_code,
                   x_exception_msg             =>  l_exception_msg
          );
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'return status WSH_CREATE_CARRIERS_PKG.assign_org_carrier_service',l_return_status);
          END IF;
        WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                    x_num_warnings     =>l_num_warnings,
                                    x_num_errors       =>l_num_errors
                                    );
        END IF;
        x_orgcar_ser_out_rec_tab.rowid := l_rowid;
        x_orgcar_ser_out_rec_tab.org_carrier_service_id := l_org_carrier_service_id;
        x_orgcar_ser_out_rec_tab.carrier_service_id := p_rec_org_car_ser_tab.Carrier_Service_id;
        x_return_status := l_return_status;
        IF FND_API.To_Boolean(p_commit) THEN
            COMMIT WORK;
        END IF;
      END IF;
      close get_carrier_ser_info;

      EXCEPTION
       --
       --
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
             p_count  => x_msg_count,
             p_data  =>  x_msg_data,
             p_encoded => FND_API.G_FALSE
          );
          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

        WHEN OTHERS THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

	  IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

  END Assign_Org_Carrier_Service;

  --========================================================================
    -- PROCEDURE : Assign_Org_Carrier
    --
    --
    -- PARAMETERS: p_api_version           known api version error buffer
    --             p_init_msg_list         FND_API.G_TRUE to reset list
    --             x_return_status         return status
    --             x_msg_count             number of messages in the list
    --             x_msg_data              text of messages
    --             p_action_code           action_code (ASSIGN/UNASSIGN)
    --             p_rec_attr_tab          Table of attributes for the organization carrier service entity
    --             x_orgcar_ser_out_tab   Table of orgcarrier_service_id and ship_method_code.
    -- VERSION   : current version         1.0
    --             initial version         1.0
    -- COMMENT   : The Organization is assigned to all present carrier services the carrier at that poing of time
    --            Creates or updates a record in wsh_org_carrier_services,org_freight_tl,wsh_carrier_ship_methods
    --========================================================================
  PROCEDURE Assign_Org_Carrier
      ( p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_action_code            IN   VARCHAR2,
        p_carrier_id             IN   NUMBER,
        p_organization_id        IN   NUMBER,
        x_orgcar_ser_out_tab     OUT NOCOPY Org_Carrier_Ser_Out_Tab_Type,
        x_return_status          OUT NOCOPY VARCHAR2,
        x_msg_count              OUT NOCOPY NUMBER,
        x_msg_data               OUT NOCOPY VARCHAR2) IS


  l_debug_on BOOLEAN;

  l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_ORG_CARRIER_SERVICE';

  l_index                  NUMBER :=0;
  l_num_warnings           NUMBER := 0;
  l_num_errors             NUMBER := 0;
  l_return_status          VARCHAR2(1) := 'S';
  l_exception_msg          VARCHAR2(1000);
  l_position               NUMBER;
  l_action_code            VARCHAR2(200);
  l_call_procedure         VARCHAR2(100);
  l_sql_code               NUMBER;
  l_sqlerr                 VARCHAR2(2000);


  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30):= 'Assign_Org_Carrier_Service';
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(32767);

  l_input_param_flag      BOOLEAN := TRUE;
  l_param_name            VARCHAR2(100);
  l_carrier_service_id    NUMBER;

  p_rec_org_car_ser_tab   Org_Carrier_Service_Rec_Type;
  p_rec_car_info_tab      Carrier_Info_Dff_Type;
  p_car_shp_methods       Ship_Method_Dff_Type;
  p_car_ser_out_rec       WSH_CARRIERS_GRP.Org_Carrier_Ser_Out_Rec_Type;
  p_car_ser_out_rec_tab   Org_Carrier_Ser_Out_Tab_Type;

  CURSOR get_carrier_service_ids(p_carrier_id NUMBER) IS
  SELECT carrier_service_id
  FROM WSH_CARRIER_SERVICES
  WHERE carrier_id = p_carrier_id
  AND enabled_flag = 'Y';

  BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    IF NOT FND_API.Compatible_API_Call
    ( l_api_version_number,
      p_api_version_number,
      l_api_name,
      G_PKG_NAME
    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'action_code',p_action_code);
    END IF;
    IF p_action_code IS NULL THEN
      l_param_name := 'action_code';
      l_input_param_flag := FALSE;
    ELSIF p_carrier_id IS NULL THEN
      l_param_name := 'p_carrier_id';
      l_input_param_flag := FALSE;
    ELSIF p_organization_id IS NULL THEN
      l_param_name := 'p_organization_id';
      l_input_param_flag := FALSE;

    END IF;

    IF not l_input_param_flag THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
      x_return_status := wsh_util_core.g_ret_sts_error;
      wsh_util_core.add_message(x_return_status,l_module_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    OPEN get_carrier_service_ids(p_carrier_id);
    LOOP
    FETCH get_carrier_service_ids INTO l_carrier_service_id;
    EXIT WHEN (get_carrier_service_ids%NOTFOUND);
      p_rec_org_car_ser_tab.CARRIER_SERVICE_ID := l_carrier_service_id;
      p_rec_org_car_ser_tab.ORGANIZATION_ID := p_organization_id;

      p_rec_org_car_ser_tab.CREATION_DATE := SYSDATE;
      p_rec_org_car_ser_tab.CREATED_BY := fnd_global.user_id;
      p_rec_org_car_ser_tab.LAST_UPDATE_DATE := SYSDATE;
      p_rec_org_car_ser_tab.LAST_UPDATED_BY :=fnd_global.user_id;

      p_rec_car_info_tab.CREATION_DATE := SYSDATE;
      p_rec_car_info_tab.CREATED_BY := fnd_global.user_id;
      p_rec_car_info_tab.LAST_UPDATE_DATE := SYSDATE;
      p_rec_car_info_tab.LAST_UPDATED_BY :=fnd_global.user_id;

      p_car_shp_methods.CREATION_DATE := SYSDATE;
      p_car_shp_methods.CREATED_BY := fnd_global.user_id;
      p_car_shp_methods.LAST_UPDATE_DATE := SYSDATE;
      p_car_shp_methods.LAST_UPDATED_BY := fnd_global.user_id;

      Assign_Org_Carrier_Service(
        p_action_code          =>p_action_code,
        p_rec_org_car_ser_tab  =>p_rec_org_car_ser_tab,
        p_rec_car_dff_tab      =>p_rec_car_info_tab,
        p_shp_methods_dff      =>p_car_shp_methods,
        x_orgcar_ser_out_rec_tab  =>p_car_ser_out_rec,
        p_api_version_number => 1.0,
        p_init_msg_list => p_init_msg_list,
        p_commit => p_commit,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
      );
      IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'return status WSH_CREATE_CARRIERS_PKG.Assign_Org_Carrier_Service',l_return_status);
      END IF;
      WSH_UTIL_CORE.api_post_call(p_return_status    =>l_return_status,
                                    x_num_warnings     =>l_num_warnings,
                                    x_num_errors       =>l_num_errors
                                    );
      x_orgcar_ser_out_tab(l_index) := p_car_ser_out_rec;
      l_index := l_index+1;
    END LOOP;
    CLOSE get_carrier_service_ids;
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    EXCEPTION
       --
       --
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
             p_count  => x_msg_count,
             p_data  =>  x_msg_data,
             p_encoded => FND_API.G_FALSE
          );
          IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

	  IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

        WHEN OTHERS THEN

          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
          x_msg_data := l_sqlerr;
          FND_MSG_PUB.Count_And_Get
          (
            p_count  => x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
          );

	  IF x_msg_data IS NULL THEN
	    x_msg_count := 1;
	    x_msg_data := l_sqlerr;
	  END IF;

	  IF l_debug_on THEN
            wsh_debug_sv.log (l_module_name,'l_exception_msg',l_exception_msg);
            wsh_debug_sv.log (l_module_name,'l_position',l_position);
            wsh_debug_sv.log (l_module_name,'l_procedure',l_call_procedure);
            wsh_debug_sv.log (l_module_name,'l_sqlerr',l_sqlerr);
            wsh_debug_sv.log (l_module_name,'l_sql_code',l_sql_code);
          END IF;

  END Assign_Org_Carrier;

  PROCEDURE Get_Meanings
  (

    sl_time_uom         IN   VARCHAR2,
    service_level_code  IN  VARCHAR2,
    mode_of_trans_code  IN  VARCHAR2,
    x_service_level     OUT NOCOPY VARCHAR2,
    x_mode_of_transport OUT NOCOPY VARCHAR2,
    x_sl_time_uom_desc  OUT NOCOPY VARCHAR2
  )


  IS

    BEGIN

      IF (SERVICE_LEVEL_CODE IS NOT NULL) THEN
        SELECT meaning
        INTO x_service_level
        FROM WSH_LOOKUPS
        WHERE LOOKUP_TYPE = 'WSH_SERVICE_LEVELS'
        AND LOOKUP_CODE = SERVICE_LEVEL_CODE;
      END IF;
      IF (MODE_OF_TRANS_CODE IS NOT NULL) THEN
        SELECT meaning
        INTO x_mode_of_transport
        FROM WSH_LOOKUPS
        WHERE LOOKUP_TYPE = 'WSH_MODE_OF_TRANSPORT'
        AND LOOKUP_CODE = MODE_OF_TRANS_CODE;
      END IF;
      IF (SL_TIME_UOM IS NOT NULL) THEN
        select UNIT_OF_MEASURE
        INTO   x_sl_time_uom_desc
        FROM   MTL_UNITS_OF_MEASURE_VL
        WHERE  UOM_CLASS LIKE 'Time'
        AND    UOM_CODE = SL_TIME_UOM;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
  END Get_Meanings;


  PROCEDURE Generate_Ship_Method
  (
      service_level_code  IN  VARCHAR2,
      freight_code        IN  VARCHAR2,
      mode_of_trans_code  IN  VARCHAR2,
      ship_method_meaning IN  VARCHAR2 DEFAULT NULL,
      x_ship_method_code  OUT NOCOPY VARCHAR2
  )
  IS

    l_initial       VARCHAR2(6);
    l_MOT           VARCHAR2(1);
    l_carrier       VARCHAR2(10);
    l_service_level VARCHAR2(10);
    l_code          VARCHAR2(30);
    l_code1         VARCHAR2(8);
    l_count         NUMBER;
    l_maxnum        NUMBER;
    l_sm            VARCHAR2(80);


    CURSOR Check_Ship_Method_Exists(p_ship_method_code VARCHAR2) IS
      SELECT count(*)
      FROM   fnd_lookup_values_vl
      WHERE  lookup_code = p_ship_method_code
      AND    lookup_type = 'SHIP_METHOD';



    CURSOR Get_Ship_Method_By_Meaning(p_ship_method_meaning VARCHAR2) IS
      SELECT lookup_code
      FROM   fnd_lookup_values_vl
      WHERE  meaning = p_ship_method_meaning
      AND    lookup_type = 'SHIP_METHOD';


     BEGIN

       -- iSetup bug 3924555
       -- return the existing Ship_Method for the given Ship_Method_Meaning
       -- if this Ship_Method_Meaning exists in WSH_CARRIER_SERVICES
       --   error will be caught by Check_Duplicate_SMM_Create cursor
       -- otherwise, it means the lookup value exists but no Carrier Service
       --   exists in WSH_CARRIER_SERVICES, which is the bug case.

       IF (ship_method_meaning IS NOT NULL) THEN

         OPEN Get_Ship_Method_By_Meaning(ship_method_meaning);
         FETCH Get_Ship_Method_By_Meaning INTO l_code;
         CLOSE Get_Ship_Method_By_Meaning;

         IF (l_code IS NOT NULL) THEN
           x_ship_method_code := l_code;
           return;
         END IF;
       END IF;

      --------------------------------------------------------------
      --  The following code is to generate the SHIP_METHOD_CODE.
      --------------------------------------------------------------

       l_initial := '000001';
       l_MOT     := SUBSTR(mode_of_trans_code,1,1);
       l_carrier := RTRIM(SUBSTR(freight_code,1,10),' ');
       l_service_level := RTRIM(SUBSTR(service_level_code,1,10),' ');

       l_code := l_initial || '_' || l_carrier || '_' || l_MOT || '_' || l_service_level;



       OPEN Check_Ship_Method_Exists(l_code);
       FETCH Check_Ship_Method_Exists INTO l_count;
       CLOSE Check_Ship_Method_Exists;

         IF l_count > 0  THEN

           SELECT max(to_number(substr(lookup_code,1,6)))
           INTO   l_maxnum
           FROM   fnd_lookup_values_vl
           WHERE substr(lookup_code,7, length(lookup_code)) = substr(l_code,7,length(l_code))
           AND   lookup_type = 'SHIP_METHOD';

           SELECT lpad(to_char(l_maxnum),6,'0') into l_code1 from dual;

           l_code := lpad(to_char(to_number(substr(l_code1,1,6))+1),6,'0')||substr(l_code,7,length(l_code));

         END IF;


       x_ship_method_code:= l_code;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        null;
     END Generate_Ship_Method;

    --========================================================================
    -- PROCEDURE : Get_Carrier_Name
    --
    --
    -- PARAMETERS: p_carrier_id            carrier_id for which name is desired
    --             x_carrier_name          carrier name given id
    --             x_freight_code          carrier freight code given id from wsh_carriers
    --
    --========================================================================
  PROCEDURE Get_Carrier_Name
  (
    p_carrier_id    IN  NUMBER,
    x_carrier_name  OUT NOCOPY VARCHAR2,
    x_freight_code  OUT NOCOPY VARCHAR2
  ) IS

  CURSOR get_carrier_name IS
    SELECT party_name, freight_code
    FROM   wsh_carriers, hz_parties
    WHERE  carrier_id =party_id
    AND    carrier_id= p_carrier_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CARRIER_NAME';
--

  BEGIN

      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
      END IF;

      OPEN get_carrier_name;
      FETCH get_carrier_name INTO x_carrier_name, x_freight_code;
      CLOSE get_carrier_name;

      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;

  END Get_Carrier_Name;

  --========================================================================
  -- PROCEDURE : get_carrier_service_mode
  --
  --========================================================================
  PROCEDURE get_carrier_service_mode
  (
    p_carrier_service_inout_rec  IN  OUT NOCOPY Carrier_Service_InOut_Rec_Type,
    x_return_status              OUT NOCOPY VARCHAR2
  ) IS

  CURSOR   get_carrier_service_mode IS
    SELECT wc.carrier_id,
           wc.freight_code,
           wc.scac_code,
           wc.manifesting_enabled_flag,
           wc.currency_code,
           nvl(wc.generic_flag, 'N'),
           wcs.carrier_service_id,
           wcs.service_level,
           wcs.mode_of_transport,
           wcs.ship_method_code
    FROM   wsh_carriers wc,
           wsh_carrier_services wcs
    WHERE  wc.carrier_id = wcs.carrier_id
    AND    ( wcs.ship_method_code = p_carrier_service_inout_rec.ship_method_code OR
             wcs.carrier_service_id = p_carrier_service_inout_rec.carrier_service_id);

  Invalid_ship_method   exception;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_carrier_service_mode';
  --
  BEGIN
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_carrier_service_inout_rec.ship_method_code',p_carrier_service_inout_rec.ship_method_code);
      WSH_DEBUG_SV.log(l_module_name,'p_carrier_service_inout_rec.carrier_service_id',p_carrier_service_inout_rec.carrier_service_id);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    OPEN get_carrier_service_mode;
    FETCH get_carrier_service_mode INTO p_carrier_service_inout_rec;
    IF get_carrier_service_mode%NOTFOUND THEN
       raise Invalid_ship_method;
    END IF;
    CLOSE get_carrier_service_mode;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    WHEN Invalid_ship_method THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      fnd_message.set_name('WSH', 'WSH_GET_SERVICE_MODE_ERROR');
      wsh_util_core.add_message(wsh_util_core.g_ret_sts_success);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Ship Method Code or Carrier Service ID is not valid');
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_ship_method');
     END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      --
 END get_carrier_service_mode;

END WSH_CARRIERS_GRP;


/
