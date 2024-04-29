--------------------------------------------------------
--  DDL for Package Body WSH_ORG_CARRIER_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ORG_CARRIER_SERVICES_PKG" as
/* $Header: WSHOCTHB.pls 120.1.12000000.2 2007/07/20 06:08:51 jnpinto ship $ */

--- Package Name: WSH_ORG_CARRIER_SERVICES_PKG
--- Pupose:       Table Handlers for table WSH_ORG_CARRIER_SERVICES
--- Note:         Please set tabstop=3 to read file with proper alignment

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ORG_CARRIER_SERVICES_PKG';
--
PROCEDURE Assign_Org_Carrier_Service
 (
      p_org_Carrier_Service_Info    IN     OCSRecType
    , p_carrier_info                IN CarRecType
    , p_csm_info                    IN WSH_CARRIER_SHIP_METHODS_PKG.CSMRecType
    , p_commit                      IN VARCHAR2 DEFAULT FND_API.G_FALSE
    , x_Rowid            	    IN OUT NOCOPY  VARCHAR2
    , x_Org_Carrier_Service_id      IN OUT NOCOPY  NUMBER
    , x_Return_Status                  OUT NOCOPY  VARCHAR2
    , x_position                       OUT NOCOPY  VARCHAR2
    , x_procedure                      OUT NOCOPY  VARCHAR2
    , x_sqlerr                         OUT NOCOPY  VARCHAR2
    , x_sql_code                       OUT NOCOPY  VARCHAR2
    , x_exception_msg                  OUT NOCOPY  VARCHAR2
 )
IS

CURSOR C_Next_id
IS
SELECT wsh_org_Carrier_Services_s.nextval
FROM sys.dual;


CURSOR C_New_Rowid(p_org_carrier_service_id NUMBER)
IS
SELECT rowid
FROM WSH_org_Carrier_ServiceS
WHERE org_Carrier_Service_id = p_org_Carrier_Service_id;

---  Bug 2796816
CURSOR c_distribution_account(p_freight_code varchar2,p_organization_id number) is
SELECT distribution_account
FROM  ORG_FREIGHT_TL
WHERE  freight_code = p_freight_code
and  organization_id = p_organization_id;

CURSOR c_service_exists
(p_carrier_service_id number,p_freight_code varchar2,p_organization_id number) is
SELECT  'Y'
FROM wsh_org_carrier_services wocs,
wsh_carrier_services_v wcs,
wsh_carriers_v wc
WHERE wc.carrier_id = wcs.carrier_id
and wocs.carrier_service_id = wcs.carrier_service_id
and wocs.carrier_service_id <> p_carrier_service_id
and wc.freight_code = p_freight_code
and wocs.organization_id = p_organization_id
and wocs.enabled_flag = 'Y'
and rownum =1;

--bug 6126916: cursor to fetch org_freight_tl details
CURSOR c_get_org_freight_tl( p_freight_code varchar2, p_organization_id number) is
   select * from org_freight_tl
   where  freight_code = p_freight_code
   and    organization_id = p_organization_id
   and    language = userenv('LANG');

l_org_carrier_service_id NUMBER;
l_rowid             rowid;
l_disable_date      DATE;
l_oft_rowid             rowid;
l_csm_rowid             VARCHAR2(40);
l_procedure         VARCHAR2(500);
l_position          NUMBER;
l_carrier_ship_method_id NUMBER;
l_csm_info          WSH_CARRIER_SHIP_METHODS_PKG.CSMRecType;

--Variable added for bug 6126916
l_org_freight_tl_info c_get_org_freight_tl%rowtype;

NO_DATA_FOUND       EXCEPTION;
OTHERS		    EXCEPTION;
Failed_in_CSM       EXCEPTION;
l_return_status     VARCHAR2(10);
l_service_exists  varchar2(2) := 'N';   ---  2796816
l_distribution_account  ORG_FREIGHT_TL.distribution_account%type;
l_orgfgt_update_allowed VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_ORG_CARRIER_SERVICE';
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
       WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
       WSH_DEBUG_SV.log(l_module_name,'X_ORG_CARRIER_SERVICE_ID',X_ORG_CARRIER_SERVICE_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_org_Carrier_Service_Info.Enabled_Flag = 'N' THEN
     l_disable_date := sysdate;
   ELSE
     l_disable_date := NULL;
   END IF;

 IF (X_Org_Carrier_Service_id is NULL) THEN
      OPEN C_Next_id;
      FETCH C_Next_id INTO l_Org_Carrier_Service_Id;
      CLOSE C_Next_id;

     l_position := 10;
     l_procedure := 'Inserting into Wsh_org_carrier_services';

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Inserting into WSH_ORG_CARRIER_SERVICES',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

     INSERT INTO wsh_org_Carrier_Services
     (   org_Carrier_Service_id,
         carrier_service_id,
         organization_id,
         enabled_flag,
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
	 last_update_login
      ) VALUES (
         l_org_Carrier_Service_id,
	 p_org_Carrier_Service_Info.carrier_service_id,
	 p_org_Carrier_Service_Info.organization_id,
	 p_org_Carrier_Service_Info.Enabled_Flag,
	 p_org_Carrier_Service_Info.Attribute_Category,
	 p_org_Carrier_Service_Info.Attribute1,
	 p_org_Carrier_Service_Info.Attribute2,
	 p_org_Carrier_Service_Info.Attribute3,
	 p_org_Carrier_Service_Info.Attribute4,
	 p_org_Carrier_Service_Info.Attribute5,
	 p_org_Carrier_Service_Info.Attribute6,
	 p_org_Carrier_Service_Info.Attribute7,
	 p_org_Carrier_Service_Info.Attribute8,
	 p_org_Carrier_Service_Info.Attribute9,
	 p_org_Carrier_Service_Info.Attribute10,
	 p_org_Carrier_Service_Info.Attribute11,
	 p_org_Carrier_Service_Info.Attribute12,
	 p_org_Carrier_Service_Info.Attribute13,
	 p_org_Carrier_Service_Info.Attribute14,
	 p_org_Carrier_Service_Info.Attribute15,
	 sysdate,
	 fnd_global.user_id,
	 sysdate,
	 fnd_global.user_id,
	 fnd_global.login_id);

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Rows inserted',SQL%ROWCOUNT);
         END IF;
   OPEN C_New_Rowid(l_org_carrier_service_id);
	FETCH C_New_Rowid INTO l_rowid;
	IF (C_New_Rowid%NOTFOUND) THEN
		CLOSE C_New_Rowid;
		RAISE others;
      END IF;

     l_position := 20;
     l_procedure := 'Inserting into ORG_FREIGHT_TL';
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit ORG_FREIGHT_TL_PKG.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
ORG_FREIGHT_TL_PKG.INSERT_ROW(
    X_ROWID => l_oft_rowid,
    X_FREIGHT_CODE => p_carrier_info.P_FREIGHT_CODE,
    X_FREIGHT_CODE_TL => p_carrier_info.P_FREIGHT_CODE,
    X_ORGANIZATION_ID => p_org_carrier_service_info.ORGANIZATION_ID,
    X_DISABLE_DATE => l_disable_date,
    X_DISTRIBUTION_ACCOUNT => p_org_Carrier_Service_Info.DISTRIBUTION_ACCOUNT, -- BugFix#3296461
   --bug 6126916: While inserting, populate NULL values for DFF attributes
   --(similar to GDF attributes)
    X_ATTRIBUTE_CATEGORY => NULL,
    X_ATTRIBUTE1  => NULL,
    X_ATTRIBUTE2  => NULL,
    X_ATTRIBUTE3  => NULL,
    X_ATTRIBUTE4  => NULL,
    X_ATTRIBUTE5  => NULL,
    X_ATTRIBUTE6  => NULL,
    X_ATTRIBUTE7  => NULL,
    X_ATTRIBUTE8  => NULL,
    X_ATTRIBUTE9  => NULL,
    X_ATTRIBUTE10 => NULL,
    X_ATTRIBUTE11 => NULL,
    X_ATTRIBUTE12 => NULL,
    X_ATTRIBUTE13 => NULL,
    X_ATTRIBUTE14 => NULL,
    X_ATTRIBUTE15 => NULL,
    X_GLOBAL_ATTRIBUTE1  => NULL,
    X_GLOBAL_ATTRIBUTE2  => NULL,
    X_GLOBAL_ATTRIBUTE3  => NULL,
    X_GLOBAL_ATTRIBUTE4  => NULL,
    X_GLOBAL_ATTRIBUTE5  => NULL,
    X_GLOBAL_ATTRIBUTE6  => NULL,
    X_GLOBAL_ATTRIBUTE7  => NULL,
    X_GLOBAL_ATTRIBUTE8  => NULL,
    X_GLOBAL_ATTRIBUTE9  => NULL,
    X_GLOBAL_ATTRIBUTE10 => NULL,
    X_GLOBAL_ATTRIBUTE11 => NULL,
    X_GLOBAL_ATTRIBUTE12 => NULL,
    X_GLOBAL_ATTRIBUTE13 => NULL,
    X_GLOBAL_ATTRIBUTE14 => NULL,
    X_GLOBAL_ATTRIBUTE15 => NULL,
    X_GLOBAL_ATTRIBUTE16 => NULL,
    X_GLOBAL_ATTRIBUTE17 => NULL,
    X_GLOBAL_ATTRIBUTE18 => NULL,
    X_GLOBAL_ATTRIBUTE19 => NULL,
    X_GLOBAL_ATTRIBUTE20 => NULL,
    X_GLOBAL_ATTRIBUTE_CATEGORY => NULL,
    X_DESCRIPTION => SUBSTRB(p_carrier_info.P_CARRIER_NAME,1,80),
    X_CREATION_DATE => SYSDATE, -- Bug 5478419
    X_CREATED_BY => p_carrier_info.CREATED_BY,
    X_LAST_UPDATE_DATE => SYSDATE, -- Bug 5478419
    X_LAST_UPDATED_BY => p_carrier_info.LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => p_carrier_info.LAST_UPDATE_LOGIN);

     l_position := 30;
     l_procedure := 'Updating Org_Freight_TL';

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Updating ORG_FREIGHT_TL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

     UPDATE ORG_FREIGHT_TL
     SET    party_id = p_csm_info.carrier_id,
            disable_date = l_disable_date
     WHERE  freight_code = p_carrier_info.p_freight_code
     and    organization_id = p_org_carrier_service_info.organization_id;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
     END IF;
        IF SQL%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
        END IF;

     l_position := 40;
     l_procedure := 'Calling Create_Carrier_Ship_Method';

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CARRIER_SHIP_METHODS_PKG.Create_Carrier_Ship_Method',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

        WSH_CARRIER_SHIP_METHODS_PKG.Create_Carrier_Ship_Method
        (
           p_carrier_ship_method_info    => p_CSM_info,
           x_rowid                       => l_csm_rowid,
           x_carrier_ship_method_id      => l_carrier_ship_method_id,
           x_return_status               => l_return_status
         );

        IF (l_return_status <> 'S') THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           --  RAISE Failed_In_CSM;
        END IF;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        END IF;
    x_org_carrier_service_id := l_org_carrier_service_id;
    x_rowid := l_rowid;

ELSE

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Updating WSH_ORG_CARRIER_SERVICES',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
    L_POSITION := 20;
    L_PROCEDURE := 'Updating WSH_ORG_CARRIER_SERVICES';

   UPDATE wsh_Org_Carrier_Services
   SET
   enabled_flag        = p_org_Carrier_Service_Info.Enabled_Flag,
   attribute_category  = p_org_Carrier_Service_Info.Attribute_Category,
   attribute1	       = p_org_Carrier_Service_Info.Attribute1,
   attribute2	       = p_org_Carrier_Service_Info.Attribute2,
   attribute3	       = p_org_Carrier_Service_Info.Attribute3,
   attribute4	       = p_org_Carrier_Service_Info.Attribute4,
   attribute5	       = p_org_Carrier_Service_Info.Attribute5,
   attribute6	       = p_org_Carrier_Service_Info.Attribute6,
   attribute7	       = p_org_Carrier_Service_Info.Attribute7,
   attribute8	       = p_org_Carrier_Service_Info.Attribute8,
   attribute9	       = p_org_Carrier_Service_Info.Attribute9,
   attribute10	       = p_org_Carrier_Service_Info.Attribute10,
   attribute11	       = p_org_Carrier_Service_Info.Attribute11,
   attribute12	       = p_org_Carrier_Service_Info.Attribute12,
   attribute13	       = p_org_Carrier_Service_Info.Attribute13,
   attribute14	       = p_org_Carrier_Service_Info.Attribute14,
   attribute15	       = p_org_Carrier_Service_Info.Attribute15,
   last_update_date    = p_org_Carrier_Service_Info.Last_Update_Date,
   last_updated_by     = p_org_Carrier_Service_Info.Last_Updated_By,
   last_update_login   = p_org_Carrier_Service_Info.Last_Update_Login
   WHERE rowid = x_rowid;

        IF (SQL%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;

    L_POSITION := 30;
    L_PROCEDURE := 'Updating WSH_CARRIER_SHIP_METHODS';

        UPDATE WSH_CARRIER_SHIP_METHODS
        SET    ENABLED_FLAG = p_org_Carrier_Service_Info.Enabled_Flag,
               WEB_ENABLED  = p_csm_info.web_enabled
        WHERE  ORGANIZATION_ID =  p_csm_info.organization_id
        AND    SHIP_METHOD_CODE = p_csm_info.ship_method_code;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

--  Bug 2796816 Start
    OPEN c_distribution_account(p_carrier_info.p_freight_code,p_org_carrier_service_info.organization_id);
    FETCH c_distribution_account into l_distribution_account;
    CLOSE c_distribution_account;

    IF p_org_Carrier_Service_Info.Enabled_Flag = 'N' THEN
     OPEN c_service_exists(p_org_Carrier_Service_Info.carrier_service_id,p_carrier_info.p_freight_code,
                           p_org_carrier_service_info.organization_id);
     FETCH c_service_exists into l_service_exists;
     CLOSE c_service_exists;
    END IF;

    IF p_org_Carrier_Service_Info.Enabled_Flag = 'N' and l_service_exists = 'Y' THEN
        l_disable_date := NULL;
    END IF;
--  Bug 2796816 End


    --  Bug 3537378 : Do not call ORG_FREIGHT_TL.Update_Row if Enabled Flag is N and SERVICE exist is N
    --  Should not Update the Org. Fgt. Record, Nothing to Update in Org. Freight
    --  Functionality: Inactivating a Org. Car. Svc. SHOULD NOT Disable/Inactivate an Org.Fgt.tl record
    IF ( p_org_Carrier_Service_Info.Enabled_Flag = 'N' and l_service_exists = 'N' ) THEN
       l_orgfgt_update_allowed := 'N';
    ELSE
       l_orgfgt_update_allowed := 'Y';
    END IF;


    L_POSITION := 40;
    L_PROCEDURE := 'Calling ORG_FREIGHT_TL.Update_Row';
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit ORG_FREIGHT_TL_PKG.UPDATE_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

  --  Bug 3537378
  IF (l_orgfgt_update_allowed = 'Y') THEN -- Update Allowled
  --
  --Start of fix for bug 6126916: Get Org_Freight_Tl details
  OPEN  c_get_org_freight_tl( p_carrier_info.P_FREIGHT_CODE, p_org_carrier_service_info.ORGANIZATION_ID );
  FETCH c_get_org_freight_tl into l_org_freight_tl_info;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'No of rows fetched from cursor c_get_org_freight_tl: ' || c_get_org_freight_tl%ROWCOUNT);
  END IF;
  --
  CLOSE c_get_org_freight_tl;
  --End of fix for bug 6126916

  ORG_FREIGHT_TL_PKG.UPDATE_ROW(
    X_FREIGHT_CODE => p_carrier_info.P_FREIGHT_CODE,
    X_FREIGHT_CODE_TL => p_carrier_info.P_FREIGHT_CODE,
    X_ORGANIZATION_ID => p_org_carrier_service_info.ORGANIZATION_ID,
    X_DISABLE_DATE => l_disable_date,
    X_DISTRIBUTION_ACCOUNT => nvl(p_org_Carrier_Service_Info.DISTRIBUTION_ACCOUNT, l_distribution_account),
    --Bug 6126916: While updating, populate DFF and GDF values from
    --             Org_Freight_Tl table
    X_ATTRIBUTE_CATEGORY => l_org_freight_tl_info.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1  => l_org_freight_tl_info.ATTRIBUTE1,
    X_ATTRIBUTE2  => l_org_freight_tl_info.ATTRIBUTE2,
    X_ATTRIBUTE3  => l_org_freight_tl_info.ATTRIBUTE3,
    X_ATTRIBUTE4  => l_org_freight_tl_info.ATTRIBUTE4,
    X_ATTRIBUTE5  => l_org_freight_tl_info.ATTRIBUTE5,
    X_ATTRIBUTE6  => l_org_freight_tl_info.ATTRIBUTE6,
    X_ATTRIBUTE7  => l_org_freight_tl_info.ATTRIBUTE7,
    X_ATTRIBUTE8  => l_org_freight_tl_info.ATTRIBUTE8,
    X_ATTRIBUTE9  => l_org_freight_tl_info.ATTRIBUTE9,
    X_ATTRIBUTE10 => l_org_freight_tl_info.ATTRIBUTE10,
    X_ATTRIBUTE11 => l_org_freight_tl_info.ATTRIBUTE11,
    X_ATTRIBUTE12 => l_org_freight_tl_info.ATTRIBUTE12,
    X_ATTRIBUTE13 => l_org_freight_tl_info.ATTRIBUTE13,
    X_ATTRIBUTE14 => l_org_freight_tl_info.ATTRIBUTE14,
    X_ATTRIBUTE15 => l_org_freight_tl_info.ATTRIBUTE15,
    X_GLOBAL_ATTRIBUTE1  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE1,
    X_GLOBAL_ATTRIBUTE2  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE2,
    X_GLOBAL_ATTRIBUTE3  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE3,
    X_GLOBAL_ATTRIBUTE4  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE4,
    X_GLOBAL_ATTRIBUTE5  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE5,
    X_GLOBAL_ATTRIBUTE6  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE6,
    X_GLOBAL_ATTRIBUTE7  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE7,
    X_GLOBAL_ATTRIBUTE8  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE8,
    X_GLOBAL_ATTRIBUTE9  => l_org_freight_tl_info.GLOBAL_ATTRIBUTE9,
    X_GLOBAL_ATTRIBUTE10 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE10,
    X_GLOBAL_ATTRIBUTE11 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE11,
    X_GLOBAL_ATTRIBUTE12 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE12,
    X_GLOBAL_ATTRIBUTE13 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE13,
    X_GLOBAL_ATTRIBUTE14 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE14,
    X_GLOBAL_ATTRIBUTE15 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE15,
    X_GLOBAL_ATTRIBUTE16 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE16,
    X_GLOBAL_ATTRIBUTE17 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE17,
    X_GLOBAL_ATTRIBUTE18 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE18,
    X_GLOBAL_ATTRIBUTE19 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE19,
    X_GLOBAL_ATTRIBUTE20 => l_org_freight_tl_info.GLOBAL_ATTRIBUTE20,
    X_GLOBAL_ATTRIBUTE_CATEGORY => l_org_freight_tl_info.GLOBAL_ATTRIBUTE_CATEGORY,
    X_DESCRIPTION =>substrb(p_carrier_info.P_CARRIER_NAME,1,80),
    X_LAST_UPDATE_DATE => SYSDATE, -- Bug 5478419
    X_LAST_UPDATED_BY => p_carrier_info.LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => p_carrier_info.LAST_UPDATE_LOGIN);

    L_POSITION := 50;
    L_PROCEDURE := 'Updating ORG_FREIGHT_TL';

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Updating ORG_FREIGHT_TL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

     UPDATE ORG_FREIGHT_TL
     SET    party_id = p_csm_info.carrier_id
     WHERE  freight_code = p_carrier_info.p_freight_code
     and    organization_id = p_org_carrier_service_info.organization_id;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Update with carrier_id '||p_csm_info.carrier_id,SQL%ROWCOUNT);
     END IF;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;

  END IF; -- End Update Allowled

END IF;
  IF FND_API.To_Boolean(p_commit) THEN
     COMMIT;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'COMMIT');
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
      WHEN Failed_In_CSM THEN
          x_exception_msg := 'EXCEPTION: Failed in CSM';
      x_position := l_position;
      x_procedure := l_procedure;
      x_sqlerr    := sqlerrm;
      x_sql_code   := sqlcode;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FAILED_IN_CSM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FAILED_IN_CSM');
      END IF;
      --
     WHEN OTHERS THEN
      x_exception_msg := 'EXCEPTION : Others';
      x_position := l_position;
      x_procedure := l_procedure;
      x_sqlerr    := sqlerrm;
      x_sql_code := sqlcode;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Assign_Org_Carrier_Service;

PROCEDURE Lock_Org_Carrier_Service (
  p_rowid                          IN     VARCHAR2
, p_org_Carrier_Service_Info       IN     OCSRecType
, x_Return_Status                     OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_lock_row IS
SELECT *
FROM   wsh_Org_Carrier_Services
WHERE  rowid = p_rowid
FOR UPDATE of Org_Carrier_Service_id NOWAIT;

Recinfo C_lock_row%ROWTYPE;

others                         Exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ORG_CARRIER_SERVICE';
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
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF (p_rowid is not null) THEN
	OPEN C_lock_row;
   FETCH C_lock_row INTO Recinfo;

   IF (C_lock_row%NOTFOUND) THEN
      CLOSE C_lock_row;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name,'x_return_status');
	END IF;
	--
	RETURN;
   END IF;
   CLOSE C_lock_row;

   IF (   (Recinfo.Enabled_Flag = p_org_Carrier_Service_Info.Enabled_Flag)
	   AND ( (Recinfo.Attribute_Category = p_org_Carrier_Service_Info.Attribute_Category)
	      OR (   (Recinfo.Attribute_Category is NULL)
	  	      AND (p_org_Carrier_Service_Info.Attribute_Category IS NULL)))
	   AND ( (Recinfo.Attribute1 = p_org_Carrier_Service_Info.Attribute1)
	      OR (   (Recinfo.Attribute1 IS NULL)
	         AND (p_org_Carrier_Service_Info.Attribute1 is NULL)))
	   AND ( (Recinfo.Attribute2 = p_org_Carrier_Service_Info.Attribute2)
	      OR (   (Recinfo.Attribute2 IS NULL)
	         AND (p_org_Carrier_Service_Info.Attribute2 is NULL)))
	   AND ( (Recinfo.Attribute3 = p_org_Carrier_Service_Info.Attribute3)
	      OR (   (Recinfo.Attribute3 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute3 is NULL)))
	   AND ( (Recinfo.Attribute4 = p_org_Carrier_Service_Info.Attribute4)
	      OR (   (Recinfo.Attribute4 IS NULL)
	         AND (p_org_Carrier_Service_Info.Attribute4 is NULL)))
	   AND ( (Recinfo.Attribute5 = p_org_Carrier_Service_Info.Attribute5)
	      OR (   (Recinfo.Attribute5 IS NULL)
	         AND (p_org_Carrier_Service_Info.Attribute5 is NULL)))
	   AND ( (Recinfo.Attribute6 = p_org_Carrier_Service_Info.Attribute6)
	      OR (   (Recinfo.Attribute6 IS NULL)
	         AND (p_org_Carrier_Service_Info.Attribute6 is NULL)))
	   AND ( (Recinfo.Attribute7 = p_org_Carrier_Service_Info.Attribute7)
		   OR (   (Recinfo.Attribute7 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute7 is NULL)))
	   AND ( (Recinfo.Attribute8 = p_org_Carrier_Service_Info.Attribute8)
		   OR (   (Recinfo.Attribute8 IS NULL)
	         AND (p_org_Carrier_Service_Info.Attribute8 is NULL)))
	   AND ( (Recinfo.Attribute9 = p_org_Carrier_Service_Info.Attribute9)
		   OR (   (Recinfo.Attribute9 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute9 is NULL)))
	   AND ( (Recinfo.Attribute10 = p_org_Carrier_Service_Info.Attribute10)
		   OR (   (Recinfo.Attribute10 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute10 is NULL)))
	   AND ( (Recinfo.Attribute11 = p_org_Carrier_Service_Info.Attribute11)
	      OR (   (Recinfo.Attribute11 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute11 is NULL)))
	   AND ( (Recinfo.Attribute12 = p_org_Carrier_Service_Info.Attribute12)
		   OR (   (Recinfo.Attribute12 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute12 is NULL)))
	   AND ( (Recinfo.Attribute13 = p_org_Carrier_Service_Info.Attribute13)
		   OR (   (Recinfo.Attribute13 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute13 is NULL)))
	   AND ( (Recinfo.Attribute14 = p_org_Carrier_Service_Info.Attribute14)
		   OR (   (Recinfo.Attribute14 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute14 is NULL)))
	   AND ( (Recinfo.Attribute15 = p_org_Carrier_Service_Info.Attribute15)
		   OR (   (Recinfo.Attribute15 IS NULL)
		      AND (p_org_Carrier_Service_Info.Attribute15 is NULL)))
      ) THEN
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name,'Nothing changed');
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
 END IF;
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
 END IF;
 --
   EXCEPTION
		WHEN others THEN
			x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			WSH_UTIL_CORE.Default_Handler('WSH_org_Carrier_ServiceS_PKG.LockOrg_Carrier_Service',l_module_name);
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END Lock_Org_Carrier_Service;

END WSH_ORG_CARRIER_SERVICES_PKG;

/
