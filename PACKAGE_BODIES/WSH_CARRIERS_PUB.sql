--------------------------------------------------------
--  DDL for Package Body WSH_CARRIERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CARRIERS_PUB" AS
/* $Header: WSHCAPBB.pls 120.0.12010000.2 2010/06/14 12:43:57 gbhargav noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_CARRIERS_PUB';

--===================
-- PROCEDURES
--===================

   --========================================================================
   -- PROCEDURE : Assign_Org_Carrier_Service         PUBLIC
   --
   -- PARAMETERS: p_api_version_number    known api version error number
   --             p_init_msg_list         FND_API.G_TRUE to reset list
   --             p_commit                FND_API.G_TRUE  to commit.
   --             p_action_code            Valid action codes are
   --                                     'ASSIGN','UNASSIGN'
   --             p_org_info_tab          Input table variable containing org_id and org_code for which needs to be assigned/unassigned
   --             p_carrier_id            Carrier Id of the carrier
   --             p_freight_code          Freight code
   --             p_carrier_service_id    Carrier service Id to be assigned/unassigned to Organization
   --             p_ship_method_code      Ship Method code
   --             p_ship_method           Ship Method meaning
   --             x_car_out_rec_tab       Out table variable containing carrier_service_id and org_carrier_service_id updated/inserted
   --             x_return_status         return status
   --             x_msg_count             number of messages in the list
   --             x_msg_data              text of messages
   --
   -- VERSION   : current version         1.0
   --             initial version         1.0
   -- COMMENT   : This procedure is used to perform an action specified in p_action_code on the carrier service
   --
   --             If p_action_code is 'ASSIGN' then new record will be inserted in WCSM ,WOCS and org_fieight_tl,
   --                                  if records are already existing then existing records will be updated
   --             If p_action_code is 'UNASSIGN' then existing record in WCSM and WOCS will be disabled .
   --                                  if records are not existing then records will be inserted in disabled status
   --                                  in WCSM ,WOCS and org_fieight_tl
   --
   --             If org_id and org_code are both passed in p_org_info_tab then only org_id is considered than org_code.
   --
   --             If p_carrier_service_id is passed then p_carrier_id , p_freight_code , p_ship_method_code and p_ship_method parameters are ignored
   --
   --             If p_ship_method_code or p_ship_method is passed then on associated carrier service action will be performed.
   --             If p_ship_method_code and p_ship_method both are passed then only p_ship_method_code is used.
   --             If p_ship_method_code or p_ship_method is passed then p_carrier_id/p_freight_code are ignored

   --             If p_carrier_id or p_freight_code is passed then action will be performed on all associated carrier services.
   --             If p_carrier_id and p_freight_code  both are passed then only p_carrier_id is considered.
  --
   --DESCRIPTION: Organization Assignment/Unassignment for a carrier / carrier service / ship method is possible from Application .
   --             This Public API is created to fulfill the same requirement.
   --========================================================================

   PROCEDURE Assign_Org_Carrier_Service
       ( p_api_version_number     IN   NUMBER,
         p_init_msg_list          IN   VARCHAR2,
         p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
         p_action_code            IN   VARCHAR2,
         p_org_info_tab           IN   WSH_CARRIERS_PUB.Org_Info_Tab_Type,
         p_carrier_id             IN   NUMBER DEFAULT NULL,
         p_freight_code           IN   VARCHAR2 DEFAULT NULL,
         p_carrier_service_id     IN   NUMBER DEFAULT NULL,
         p_ship_method_code       IN   VARCHAR2 DEFAULT NULL,
         p_ship_method            IN   VARCHAR2 DEFAULT NULL,
         x_car_out_rec_tab        OUT NOCOPY wsh_carriers_grp.Org_Carrier_Ser_Out_Tab_Type,
         x_return_status          OUT NOCOPY VARCHAR2,
         x_msg_count              OUT NOCOPY NUMBER,
         x_msg_data               OUT NOCOPY VARCHAR2 )
   IS
       l_api_version_number     CONSTANT NUMBER :=1.0 ;
       l_api_name               CONSTANT VARCHAR2(30):= 'Assign_Org_Carrier_Service';
       l_carrier_id             NUMBER ;
       l_freight_code           WSH_CARRIERS.Freight_code%TYPE ;
       l_org_info_tab           WSH_CARRIERS_PUB.Org_Info_Tab_Type;
       l_carrier_service_id     NUMBER ;
       l_carrier_service_info_tab Carrier_Ser_DFF_Tab_Type;
       l_ship_method_code       WSH_CARRIER_SERVICES.Ship_Method_Code%TYPE ;
       l_ship_method            WSH_CARRIER_SERVICES.Ship_Method_Meaning%TYPE ;
       l_carrier_service_exists VARCHAR2(1);
       l_shp_methods_dff        WSH_CARRIERS_GRP.Ship_Method_Dff_Type;
       l_rec_org_car_ser_tab    WSH_CARRIERS_GRP.Org_Carrier_Service_Rec_Type;
       l_rec_car_info_tab       WSH_CARRIERS_GRP.Carrier_Info_Dff_Type; --Passed as null in grp API
       l_car_ser_out_rec        WSH_CARRIERS_GRP.Org_Carrier_Ser_Out_Rec_Type;
       l_param_name             VARCHAR2(100);
       l_num_errors             NUMBER ;
       l_num_warnings           NUMBER ;
       l_return_status          VARCHAR2(10);
       l_msg_count              NUMBER;
       l_msg_data               VARCHAR2(32767);
       l_input_param_flag       BOOLEAN ;
       l_temp                   NUMBER;

       --Cursor to fetch carrier service DFF.
       CURSOR c_check_carrier_ser_exists(l_carrier_service_id NUMBER)    IS
         SELECT CARRIER_SERVICE_ID,
         ATTRIBUTE_CATEGORY ,
         ATTRIBUTE1 ,
         ATTRIBUTE2 ,
         ATTRIBUTE3 ,
         ATTRIBUTE4 ,
         ATTRIBUTE5 ,
         ATTRIBUTE6 ,
         ATTRIBUTE7 ,
         ATTRIBUTE8 ,
         ATTRIBUTE9 ,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15
         FROM WSH_CARRIER_SERVICES
         WHERE carrier_service_id = l_carrier_service_id
         AND enabled_flag = 'Y';

       --Cursor to fetch carrier_service_id and DFF.
       CURSOR c_check_carrier_sm_exists(l_ship_method_code VARCHAR2)    IS
         SELECT CARRIER_SERVICE_ID,
         ATTRIBUTE_CATEGORY ,
         ATTRIBUTE1 ,
         ATTRIBUTE2 ,
         ATTRIBUTE3 ,
         ATTRIBUTE4 ,
         ATTRIBUTE5 ,
         ATTRIBUTE6 ,
         ATTRIBUTE7 ,
         ATTRIBUTE8 ,
         ATTRIBUTE9 ,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15
         FROM WSH_CARRIER_SERVICES
         WHERE ship_method_code = l_ship_method_code
         AND enabled_flag = 'Y';

       --Cursor to fetch carrier service details
       CURSOR get_carrier_ser_info(l_carrier_id NUMBER) IS
         SELECT CARRIER_SERVICE_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
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
         ATTRIBUTE15
         FROM WSH_CARRIER_SERVICES
         WHERE carrier_id = l_carrier_id
         AND enabled_flag = 'Y';

       --
       l_debug_on BOOLEAN;
       --
       l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Assign_Org_Carrier_Service';

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
         wsh_debug_sv.log (l_module_name,'Action_code',p_action_code);
         wsh_debug_sv.log (l_module_name,'p_org_info_tab.count',p_org_info_tab.count);
         wsh_debug_sv.log (l_module_name,'Carrier_id',p_carrier_id);
         wsh_debug_sv.log (l_module_name,'Freight_code',p_freight_code);
         wsh_debug_sv.log (l_module_name,'Carrier_service_id',p_carrier_service_id);
         wsh_debug_sv.log (l_module_name,'Ship_method_code',p_ship_method_code);
         wsh_debug_sv.log (l_module_name,'Ship_method',p_ship_method);
       END IF;

       l_return_status       := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       l_carrier_id          := p_carrier_id ;
       l_freight_code        := p_freight_code;
       l_carrier_service_id  := p_carrier_service_id;
       l_ship_method_code    := p_ship_method_code ;
       l_ship_method         := p_ship_method ;
       l_num_errors          := 0;
       l_num_warnings        := 0;
       l_input_param_flag    := TRUE;
       l_temp                := 0;

       l_temp := p_org_info_tab.FIRST;

       IF l_temp is not null THEN
             LOOP
                -- Exchange the org values from p_org_info_tab to l_org_info_tab only if either org_id / org_code is not null.
                IF ( NVL(p_org_info_tab(l_temp).org_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM ) OR
                   ( NVL(p_org_info_tab(l_temp).org_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR ) THEN
                --{
                   l_org_info_tab(l_org_info_tab.count+1).org_id := p_org_info_tab(l_temp).org_id;
                   l_org_info_tab(l_org_info_tab.count).org_code := p_org_info_tab(l_temp).org_code;
                --}
                END IF;

                EXIT WHEN ( l_temp = p_org_info_tab.LAST );
                l_temp := p_org_info_tab.NEXT(l_temp);
             END LOOP;
       END IF;

       IF p_action_code IS NULL THEN
       --{
            l_param_name := 'action_code';
            l_input_param_flag := FALSE;
       --}
       ELSIF (l_org_info_tab.count = 0 ) THEN
       --{
            l_param_name := 'organization_id or organization_code';
            l_input_param_flag := FALSE;
       --}
       ELSIF (l_carrier_service_id IS NULL AND l_ship_method_code IS NULL AND
              l_ship_method IS NULL AND l_carrier_id IS NULL AND l_freight_code is NULL) THEN
       --{
            l_param_name := 'Carrier_service_id/Ship_method_code/Ship_method/Carrier_id/Freight_code';
            l_input_param_flag := FALSE;
       --}
       END IF;

       IF NOT  l_input_param_flag THEN
       --{
            FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_param_name);
            x_return_status := wsh_util_core.g_ret_sts_error;
            wsh_util_core.add_message(x_return_status,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
       --}
       END IF;

       IF p_action_code NOT IN ('ASSIGN','UNASSIGN') THEN
       --{
            FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
            FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action_code);
            x_return_status := wsh_util_core.g_ret_sts_error;
            wsh_util_core.add_message(x_return_status,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
       --}
       END IF;

       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'l_org_info_tab.count',l_org_info_tab.count);
       END IF;

       --Organization validation
       IF ( l_org_info_tab.count > 0 )  THEN
       --{

            FOR i in l_org_info_tab.FIRST..l_org_info_tab.LAST LOOP
            --{
               IF l_debug_on THEN
                  wsh_debug_sv.logmsg(l_module_name,'Calling wsh_util_validate.validate_org',WSH_DEBUG_SV.C_PROC_LEVEL);
                  wsh_debug_sv.log(l_module_name,'l_org_info_tab('||i||').org_id',l_org_info_tab(i).org_id);
                  wsh_debug_sv.log(l_module_name,'l_org_info_tab('||i||').org_code',l_org_info_tab(i).org_code);
               END IF;

               WSH_UTIL_VALIDATE.validate_org(
                      p_org_id         => l_org_info_tab(i).org_id,         --Out param
                      p_org_code       => l_org_info_tab(i).org_code,
                      x_return_status  => l_return_status );

               IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Return Status After Calling wsh_util_validate.validate_org',l_return_status);
               END IF;

               WSH_UTIL_CORE.api_post_call(
                      p_return_status     => l_return_status,
                      x_num_warnings      => l_num_warnings,
                      x_num_errors        => l_num_errors);
            --}
            END LOOP;

            --Carrier service validation
            IF (l_carrier_service_id  IS NOT NULL ) THEN
            --{
                 IF l_debug_on THEN
                     wsh_debug_sv.log(l_module_name,'Fetching wsh_carrier_services data for Carrier Service Id',l_carrier_service_id);
                 END IF;
                 OPEN c_check_carrier_ser_exists(l_carrier_service_id);
                 FETCH c_check_carrier_ser_exists INTO  l_carrier_service_info_tab(1);

                 IF (c_check_carrier_ser_exists%NOTFOUND) THEN
                 --{
                      CLOSE c_check_carrier_ser_exists;
                      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');   --Bug 9706100  added error message
                      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Carrier Service Id');
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      wsh_util_core.add_message(x_return_status,l_module_name);
                      RAISE  FND_API.G_EXC_ERROR;
                 --}
                 END IF;

                 CLOSE c_check_carrier_ser_exists;
            --}End of Carrier service validation
            --Ship method validation
            ELSIF ((l_ship_method_code IS NOT NULL ) OR (l_ship_method IS NOT NULL )) THEN
            --{

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling wsh_util_validate.validate_ship_method',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_UTIL_VALIDATE.validate_ship_method(
                        p_ship_method_code  => l_ship_method_code,   --Out param
                        p_ship_method_name  => l_ship_method,        --Out param
                        x_return_status     => l_return_status);

                 IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name,'Return Status After Calling wsh_util_validate.validate_ship_method',l_return_status);
                 END IF;

                 WSH_UTIL_CORE.api_post_call(
                        p_return_status     => l_return_status,
                        x_num_warnings      => l_num_warnings,
                        x_num_errors        => l_num_errors);

                 IF l_debug_on THEN
                     wsh_debug_sv.log(l_module_name,'Fetching wsh_carrier_services data for ship method code',l_ship_method_code);
                 END IF;

                 --Fetch carrier_serivce_id and corresponding DFF.
                 OPEN c_check_carrier_sm_exists (l_ship_method_code);
                 FETCH c_check_carrier_sm_exists INTO l_carrier_service_info_tab(1) ;

                 IF (c_check_carrier_sm_exists%NOTFOUND) THEN
                 --{
                      CLOSE c_check_carrier_sm_exists;
                      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_SHIP_METHOD');  --Bug 9706100  added error message
                      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      wsh_util_core.add_message(x_return_status,l_module_name);
                      RAISE  FND_API.G_EXC_ERROR;
                 --}
                 END IF;

                 CLOSE c_check_carrier_sm_exists;
            --}--End of Ship method validation
            --Carrier validation
            ELSIF ((l_carrier_id  IS NOT NULL ) OR (l_freight_code IS NOT NULL))  THEN
            --{
                 IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'Calling WSH_UTIL_VALIDATE.Validate_Freight_Code',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;

                 WSH_UTIL_VALIDATE.Validate_Freight_Code(
                         x_Carrier_id      => l_carrier_id,  --out param
                         p_freight_code    => l_freight_code,
                         x_return_status   => l_return_status);

                 IF l_debug_on THEN
                   wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_UTIL_VALIDATE.Validate_Freight_Code',l_return_status);
                 END IF;

                 WSH_UTIL_CORE.api_post_call(
                        p_return_status     => l_return_status,
                        x_num_warnings      => l_num_warnings,
                        x_num_errors        => l_num_errors);

                OPEN get_carrier_ser_info(l_carrier_id);
                FETCH get_carrier_ser_info BULK COLLECT INTO  l_carrier_service_info_tab;
                CLOSE get_carrier_ser_info;
            --}
            END IF;
            --End of Carrier validation

            IF l_carrier_service_info_tab.COUNT > 0 THEN
            --{
                 --Call Group API
                 FOR l_index IN l_carrier_service_info_tab.FIRST..l_carrier_service_info_tab.LAST LOOP
                 --{
                      --Not populating WHO columns in l_shp_methods_dff as they are overridden in grp API.
                      l_shp_methods_dff.ATTRIBUTE_CATEGORY := l_carrier_service_info_tab(l_index).ATTRIBUTE_CATEGORY;
                      l_shp_methods_dff.ATTRIBUTE1 := l_carrier_service_info_tab(l_index).ATTRIBUTE1 ;
                      l_shp_methods_dff.ATTRIBUTE2 := l_carrier_service_info_tab(l_index).ATTRIBUTE2 ;
                      l_shp_methods_dff.ATTRIBUTE3 := l_carrier_service_info_tab(l_index).ATTRIBUTE3;
                      l_shp_methods_dff.ATTRIBUTE4 := l_carrier_service_info_tab(l_index).ATTRIBUTE4 ;
                      l_shp_methods_dff.ATTRIBUTE5 := l_carrier_service_info_tab(l_index).ATTRIBUTE5 ;
                      l_shp_methods_dff.ATTRIBUTE6 := l_carrier_service_info_tab(l_index).ATTRIBUTE6 ;
                      l_shp_methods_dff.ATTRIBUTE7 := l_carrier_service_info_tab(l_index).ATTRIBUTE7 ;
                      l_shp_methods_dff.ATTRIBUTE8 := l_carrier_service_info_tab(l_index).ATTRIBUTE8 ;
                      l_shp_methods_dff.ATTRIBUTE9 := l_carrier_service_info_tab(l_index).ATTRIBUTE9 ;
                      l_shp_methods_dff.ATTRIBUTE10 := l_carrier_service_info_tab(l_index).ATTRIBUTE10;
                      l_shp_methods_dff.ATTRIBUTE11 := l_carrier_service_info_tab(l_index).ATTRIBUTE11;
                      l_shp_methods_dff.ATTRIBUTE12 := l_carrier_service_info_tab(l_index).ATTRIBUTE12 ;
                      l_shp_methods_dff.ATTRIBUTE13 := l_carrier_service_info_tab(l_index).ATTRIBUTE13 ;
                      l_shp_methods_dff.ATTRIBUTE14 := l_carrier_service_info_tab(l_index).ATTRIBUTE14 ;
                      l_shp_methods_dff.ATTRIBUTE15 := l_carrier_service_info_tab(l_index).ATTRIBUTE15 ;

                      l_rec_org_car_ser_tab.CARRIER_SERVICE_ID := l_carrier_service_info_tab(l_index).carrier_service_id;

                      -- Assigning the carrier service to all orgs which are passed in the parameter.
                      -- Org Loop
                      FOR j in l_org_info_tab.FIRST..l_org_info_tab.LAST LOOP
                      --{
                         l_rec_org_car_ser_tab.ORGANIZATION_ID := l_org_info_tab(j).org_id; -- This keeps changing as we iterate through l_org_info_tab
                         -- removing the reference of previous buffer.
                         l_car_ser_out_rec := null;

                         IF l_debug_on THEN
                            wsh_debug_sv.log(l_module_name,'Carrier_service_id',l_carrier_service_info_tab(l_index).carrier_service_id);
                            wsh_debug_sv.log(l_module_name,'Organization_id',l_rec_org_car_ser_tab.ORGANIZATION_ID);
                            wsh_debug_sv.logmsg(l_module_name,'Calling WSH_CARRIERS_GRP.Assign_Org_Carrier_Service',WSH_DEBUG_SV.C_PROC_LEVEL);
                         END IF;

                         WSH_CARRIERS_GRP.Assign_Org_Carrier_Service(
                                p_api_version_number     => p_api_version_number,
                                p_init_msg_list          => p_init_msg_list,
                                p_commit                 => p_commit,
                                p_action_code            => p_action_code,
                                p_rec_org_car_ser_tab    => l_rec_org_car_ser_tab,
                                p_rec_car_dff_tab        => l_rec_car_info_tab,
                                p_shp_methods_dff        => l_shp_methods_dff,
                                x_orgcar_ser_out_rec_tab => l_car_ser_out_rec,
                                x_return_status          => l_return_status,
                                x_msg_count              => l_msg_count,
                                x_msg_data               => l_msg_data );

                         IF l_debug_on THEN
                            wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_CARRIERS_GRP.Assign_Org_Carrier_Service',l_return_status);
                         END IF;

                         WSH_UTIL_CORE.api_post_call(
                                p_return_status     => l_return_status,
                                x_num_warnings      => l_num_warnings,
                                x_num_errors        => l_num_errors);

                         x_car_out_rec_tab(x_car_out_rec_tab.count + 1) := l_car_ser_out_rec;

                         IF l_debug_on THEN
                            wsh_debug_sv.log(l_module_name,'x_car_out_rec_tab(' || To_Char (x_car_out_rec_tab.count) || ').carrier_service_id',x_car_out_rec_tab(x_car_out_rec_tab.count).carrier_service_id);
                            wsh_debug_sv.log(l_module_name,'x_car_out_rec_tab(' || To_Char (x_car_out_rec_tab.count) || ').org_carrier_service_id',x_car_out_rec_tab(x_car_out_rec_tab.count).org_carrier_service_id);
                         END IF;
                      --}
                      END LOOP;
                      --Org Loop
                 --}
                 END LOOP;

            --} If l_carrier_service_info_tab.COUNT > 0
            ELSE
            --{
                 IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name,'** No eligible carrier services found **');
                 END IF;
            --}
            END IF;
       --}
       END IF; --End of Organization validation

      IF l_num_warnings > 0 THEN
         x_return_status := wsh_util_core.g_ret_sts_warning;
       ELSE
         x_return_status := wsh_util_core.g_ret_sts_success;
       END IF;
       --
       FND_MSG_PUB.Count_And_Get (
            p_count => x_msg_count,
            p_data  => x_msg_data );
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --{
           IF c_check_carrier_ser_exists%ISOPEN THEN
             CLOSE c_check_carrier_ser_exists;
           END IF;

           IF c_check_carrier_sm_exists%ISOPEN THEN
             CLOSE c_check_carrier_sm_exists;
           END IF;

           IF get_carrier_ser_info%ISOPEN THEN
             CLOSE get_carrier_ser_info;
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;
           -- Get message count and data
           FND_MSG_PUB.Count_And_Get (
                 p_count => x_msg_count,
                 p_data  => x_msg_data );
           --
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Expected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
           END IF;
           --
       --}
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --{
            IF c_check_carrier_ser_exists%ISOPEN THEN
              CLOSE c_check_carrier_ser_exists;
            END IF;

            IF c_check_carrier_sm_exists%ISOPEN THEN
              CLOSE c_check_carrier_sm_exists;
            END IF;

            IF get_carrier_ser_info%ISOPEN THEN
              CLOSE get_carrier_ser_info;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            -- Get message count and data
            FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count ,
                  p_data  => x_msg_data );
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
            END IF;
       --}
       WHEN OTHERS THEN
       --{
            IF c_check_carrier_ser_exists%ISOPEN THEN
              CLOSE c_check_carrier_ser_exists;
            END IF;

            IF c_check_carrier_sm_exists%ISOPEN THEN
              CLOSE c_check_carrier_sm_exists;
            END IF;

            IF get_carrier_ser_info%ISOPEN THEN
              CLOSE get_carrier_ser_info;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg
              (
                 G_PKG_NAME
                 , '_x_'
              );
            END IF;

            -- Get message count and data
            FND_MSG_PUB.Count_And_Get (
                  p_count => x_msg_count ,
                  p_data  => x_msg_data );
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            END IF;
       --}

   END Assign_Org_Carrier_Service;

END WSH_CARRIERS_PUB;

/
