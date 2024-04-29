--------------------------------------------------------
--  DDL for Package Body WSH_ORG_CARRIER_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ORG_CARRIER_SITES_PKG" as
/* $Header: WSHOSTHB.pls 115.1 2002/11/13 20:11:27 nparikh noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ORG_CARRIER_SITES_PKG';
--

PROCEDURE ASSIGN_ORG_CARRIER_SITE(
  p_Org_Carrier_Site_info          IN     OCSRecType
, x_Rowid                          IN OUT NOCOPY  VARCHAR2
, x_Org_Carrier_site_id            IN OUT NOCOPY  NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
, x_position                          OUT NOCOPY  VARCHAR2
, x_procedure                         OUT NOCOPY  VARCHAR2
, x_sqlerr                            OUT NOCOPY  VARCHAR2
, x_sql_code                          OUT NOCOPY  VARCHAR2
, x_exception_msg                     OUT NOCOPY  VARCHAR2 )

IS

CURSOR C_Next_id
IS
SELECT wsh_org_Carrier_sites_s.nextval
FROM sys.dual;


CURSOR C_New_Rowid(p_org_carrier_site_id NUMBER)
IS
SELECT rowid
FROM   WSH_org_Carrier_sites
WHERE org_Carrier_site_id = p_org_Carrier_site_id;

l_org_carrier_site_id       NUMBER;
l_rowid                     rowid;
l_disable_date              DATE;
l_oft_rowid                 rowid;
l_csm_rowid                 VARCHAR2(40);
l_procedure                 VARCHAR2(500);
l_position                  NUMBER;

NO_DATA_FOUND       EXCEPTION;
OTHERS		    EXCEPTION;
l_return_status     VARCHAR2(10);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_ORG_CARRIER_SITE';
--

BEGIN

   --
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
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Site_ID',p_org_Carrier_site_Info.Carrier_Site_ID);
      WSH_DEBUG_SV.log(l_module_name,'Organization_ID',p_org_Carrier_site_Info.Organization_id);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',p_org_Carrier_site_Info.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'attribute1',p_org_Carrier_site_Info.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'attribute2',p_org_Carrier_site_Info.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'attribute3',p_org_Carrier_site_Info.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'attribute4',p_org_Carrier_site_Info.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'attribute5',p_org_Carrier_site_Info.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'attribute6',p_org_Carrier_site_Info.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'attribute7',p_org_Carrier_site_Info.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'attribute8',p_org_Carrier_site_Info.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'attribute9',p_org_Carrier_site_Info.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'attribute10',p_org_Carrier_site_Info.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'attribute11',p_org_Carrier_site_Info.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'attribute12',p_org_Carrier_site_Info.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'attribute13',p_org_Carrier_site_Info.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'attribute14',p_org_Carrier_site_Info.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'attribute15',p_org_Carrier_site_Info.attribute15);
   END IF;
   --
   --


   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF (X_Org_Carrier_site_id is NULL) THEN
      OPEN C_Next_id;
      FETCH C_Next_id INTO l_Org_Carrier_site_Id;
      CLOSE C_Next_id;
     l_position := 10;
     l_procedure := 'Inserting into Wsh_org_carrier_sites';

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Inserting into WSH_ORG_CARRIER_SITES',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --

     INSERT INTO WSH_ORG_CARRIER_SITES
     (   org_Carrier_site_id,
         carrier_site_id,
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
         l_org_Carrier_Site_id,
	 p_org_Carrier_site_Info.carrier_site_id,
	 p_org_Carrier_site_Info.organization_id,
	 p_org_Carrier_site_Info.Enabled_Flag,
	 p_org_Carrier_site_Info.Attribute_Category,
	 p_org_Carrier_site_Info.Attribute1,
	 p_org_Carrier_site_Info.Attribute2,
	 p_org_Carrier_site_Info.Attribute3,
	 p_org_Carrier_site_Info.Attribute4,
	 p_org_Carrier_site_Info.Attribute5,
	 p_org_Carrier_site_Info.Attribute6,
	 p_org_Carrier_site_Info.Attribute7,
	 p_org_Carrier_site_Info.Attribute8,
	 p_org_Carrier_site_Info.Attribute9,
	 p_org_Carrier_site_Info.Attribute10,
	 p_org_Carrier_site_Info.Attribute11,
	 p_org_Carrier_site_Info.Attribute12,
	 p_org_Carrier_site_Info.Attribute13,
	 p_org_Carrier_site_Info.Attribute14,
	 p_org_Carrier_site_Info.Attribute15,
	 sysdate,
	 fnd_global.user_id,
	 sysdate,
	 fnd_global.user_id,
	 fnd_global.login_id);

         OPEN C_New_Rowid(l_org_carrier_site_id);
	 FETCH C_New_Rowid INTO l_rowid;
	 IF (C_New_Rowid%NOTFOUND) THEN
            CLOSE C_New_Rowid;
	    RAISE others;
         END IF;

     x_org_carrier_site_id := l_org_carrier_site_id;
     x_rowid := l_rowid;
ELSE

    L_POSITION := 20;
    L_PROCEDURE := 'Updating WSH_ORG_CARRIER_SITES';

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Updating WSH_ORG_CARRIER_SITES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --

    UPDATE WSH_ORG_CARRIER_SITES
    SET
      enabled_flag        = p_org_Carrier_site_Info.Enabled_Flag,
      attribute_category  = p_org_Carrier_site_Info.Attribute_Category,
      attribute1	       = p_org_Carrier_site_Info.Attribute1,
      attribute2	       = p_org_Carrier_site_Info.Attribute2,
      attribute3	       = p_org_Carrier_site_Info.Attribute3,
      attribute4	       = p_org_Carrier_site_Info.Attribute4,
      attribute5	       = p_org_Carrier_site_Info.Attribute5,
      attribute6	       = p_org_Carrier_site_Info.Attribute6,
      attribute7	       = p_org_Carrier_site_Info.Attribute7,
      attribute8	       = p_org_Carrier_site_Info.Attribute8,
      attribute9	       = p_org_Carrier_site_Info.Attribute9,
      attribute10	       = p_org_Carrier_site_Info.Attribute10,
      attribute11	       = p_org_Carrier_site_Info.Attribute11,
      attribute12	       = p_org_Carrier_site_Info.Attribute12,
      attribute13	       = p_org_Carrier_site_Info.Attribute13,
      attribute14	       = p_org_Carrier_site_Info.Attribute14,
      attribute15	       = p_org_Carrier_site_Info.Attribute15,
      last_update_date    = sysdate,
      last_updated_by     = fnd_global.user_id,
      last_update_login   = fnd_global.login_id
    WHERE rowid = x_rowid;

        IF (SQL%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;

END IF;

COMMIT;

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
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

   --
   -- Debug Statements
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

END Assign_Org_Carrier_Site;

PROCEDURE Lock_Org_Carrier_Site (
  p_rowid                       IN     VARCHAR2
, p_org_Carrier_site_Info       IN     OCSRecType
, x_Return_Status                  OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_lock_row IS
SELECT *
FROM   wsh_Org_Carrier_sites
WHERE  rowid = p_rowid
FOR UPDATE of Org_Carrier_site_id NOWAIT;

Recinfo C_lock_row%ROWTYPE;

others                         Exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ORG_CARRIER_SITE';
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

   IF (   (Recinfo.Enabled_Flag = p_org_Carrier_site_Info.Enabled_Flag)
	   AND ( (Recinfo.Attribute_Category = p_org_Carrier_site_Info.Attribute_Category)
	      OR (   (Recinfo.Attribute_Category is NULL)
	  	      AND (p_org_Carrier_site_Info.Attribute_Category IS NULL)))
	   AND ( (Recinfo.Attribute1 = p_org_Carrier_site_Info.Attribute1)
	      OR (   (Recinfo.Attribute1 IS NULL)
	         AND (p_org_Carrier_site_Info.Attribute1 is NULL)))
	   AND ( (Recinfo.Attribute2 = p_org_Carrier_site_Info.Attribute2)
	      OR (   (Recinfo.Attribute2 IS NULL)
	         AND (p_org_Carrier_site_Info.Attribute2 is NULL)))
	   AND ( (Recinfo.Attribute3 = p_org_Carrier_site_Info.Attribute3)
	      OR (   (Recinfo.Attribute3 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute3 is NULL)))
	   AND ( (Recinfo.Attribute4 = p_org_Carrier_site_Info.Attribute4)
	      OR (   (Recinfo.Attribute4 IS NULL)
	         AND (p_org_Carrier_site_Info.Attribute4 is NULL)))
	   AND ( (Recinfo.Attribute5 = p_org_Carrier_site_Info.Attribute5)
	      OR (   (Recinfo.Attribute5 IS NULL)
	         AND (p_org_Carrier_site_Info.Attribute5 is NULL)))
	   AND ( (Recinfo.Attribute6 = p_org_Carrier_site_Info.Attribute6)
	      OR (   (Recinfo.Attribute6 IS NULL)
	         AND (p_org_Carrier_site_Info.Attribute6 is NULL)))
	   AND ( (Recinfo.Attribute7 = p_org_Carrier_site_Info.Attribute7)
		   OR (   (Recinfo.Attribute7 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute7 is NULL)))
	   AND ( (Recinfo.Attribute8 = p_org_Carrier_site_Info.Attribute8)
		   OR (   (Recinfo.Attribute8 IS NULL)
	         AND (p_org_Carrier_site_Info.Attribute8 is NULL)))
	   AND ( (Recinfo.Attribute9 = p_org_Carrier_site_Info.Attribute9)
		   OR (   (Recinfo.Attribute9 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute9 is NULL)))
	   AND ( (Recinfo.Attribute10 = p_org_Carrier_site_Info.Attribute10)
		   OR (   (Recinfo.Attribute10 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute10 is NULL)))
	   AND ( (Recinfo.Attribute11 = p_org_Carrier_site_Info.Attribute11)
	      OR (   (Recinfo.Attribute11 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute11 is NULL)))
	   AND ( (Recinfo.Attribute12 = p_org_Carrier_site_Info.Attribute12)
		   OR (   (Recinfo.Attribute12 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute12 is NULL)))
	   AND ( (Recinfo.Attribute13 = p_org_Carrier_site_Info.Attribute13)
		   OR (   (Recinfo.Attribute13 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute13 is NULL)))
	   AND ( (Recinfo.Attribute14 = p_org_Carrier_site_Info.Attribute14)
		   OR (   (Recinfo.Attribute14 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute14 is NULL)))
	   AND ( (Recinfo.Attribute15 = p_org_Carrier_site_Info.Attribute15)
		   OR (   (Recinfo.Attribute15 IS NULL)
		      AND (p_org_Carrier_site_Info.Attribute15 is NULL)))
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
  WSH_UTIL_CORE.Default_Handler('WSH_ORG_CARRIER_SITES_PKG.Lock_Org_Carrier_Site',l_module_name);

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --

END Lock_Org_Carrier_Site;

END WSH_ORG_CARRIER_SITES_PKG;

/
