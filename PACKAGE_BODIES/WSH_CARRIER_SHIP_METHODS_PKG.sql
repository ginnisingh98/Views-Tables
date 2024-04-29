--------------------------------------------------------
--  DDL for Package Body WSH_CARRIER_SHIP_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CARRIER_SHIP_METHODS_PKG" as
/* $Header: WSHCSTHB.pls 115.14 2002/11/18 20:12:26 nparikh ship $ */

--- Package Name: WSH_CARRIER_SHIP_METHODS_PKG
--- Pupose:       Table Handlers for table WSH_CARRIER_SHIP_METHODS
--- Note:         Please set tabstop=3 to read file with proper alignment

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CARRIER_SHIP_METHODS_PKG';
--
PROCEDURE Create_Carrier_Ship_Method(
  p_Carrier_Ship_Method_Info       IN     CSMRecType
, x_Rowid            					  OUT NOCOPY  VARCHAR2
, x_Carrier_Ship_Method_id            OUT NOCOPY  NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_Next_id
IS
SELECT wsh_carrier_ship_methods_s.nextval
FROM sys.dual;

CURSOR C_New_Rowid
IS
SELECT rowid
FROM WSH_CARRIER_SHIP_METHODS
WHERE carrier_ship_method_id = x_carrier_ship_method_id;

no_data_found                   EXCEPTION;
others		                    EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CARRIER_SHIP_METHOD';
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
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Ship_Method_Id',
                            p_Carrier_Ship_Method_Info.Carrier_Ship_Method_Id);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                            p_Carrier_Ship_Method_Info.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'organization_id',
                            p_Carrier_Ship_Method_Info.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'carrier_site_id',
                             p_Carrier_Ship_Method_Info.carrier_site_id);
      WSH_DEBUG_SV.log(l_module_name,'Freight_code',
                             p_Carrier_Ship_Method_Info.Freight_code);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',
                             p_Carrier_Ship_Method_Info.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'Enabled_Flag',
                             p_Carrier_Ship_Method_Info.Enabled_Flag);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                             p_Carrier_Ship_Method_Info.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'Attribute1',
                             p_Carrier_Ship_Method_Info.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'Attribute2',
                             p_Carrier_Ship_Method_Info.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'Attribute3',
                             p_Carrier_Ship_Method_Info.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'Attribute4',
                             p_Carrier_Ship_Method_Info.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'Attribute5',
                             p_Carrier_Ship_Method_Info.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'Attribute6',
                             p_Carrier_Ship_Method_Info.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'Attribute7',
                             p_Carrier_Ship_Method_Info.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'Attribute8',
                             p_Carrier_Ship_Method_Info.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'Attribute9',
                             p_Carrier_Ship_Method_Info.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'Attribute10',
                             p_Carrier_Ship_Method_Info.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'Attribute11',
                             p_Carrier_Ship_Method_Info.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'Attribute12',
                             p_Carrier_Ship_Method_Info.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'Attribute13',
                             p_Carrier_Ship_Method_Info.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'Attribute14',
                             p_Carrier_Ship_Method_Info.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'Attribute15',
                             p_Carrier_Ship_Method_Info.attribute15);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF (X_Carrier_ship_method_id is NULL) THEN
      OPEN C_Next_id;
      FETCH C_Next_id INTO X_Carrier_Ship_Method_Id;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'X_Carrier_Ship_Method_Id',
                                           X_Carrier_Ship_Method_Id);
        END IF;
      CLOSE C_Next_id;
   END IF;
   INSERT INTO wsh_carrier_ship_methods(
      carrier_ship_method_id,
	   carrier_id,
	   ship_method_code,
	   freight_code,
	   service_level,
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
	   last_update_login,
	   web_enabled
	   )
	   VALUES (
        x_Carrier_Ship_Method_id,
	   p_Carrier_Ship_Method_Info.Carrier_Id,
	   p_Carrier_Ship_Method_Info.Ship_Method_Code,
	   p_Carrier_Ship_Method_Info.freight_code,
	   p_Carrier_Ship_Method_Info.service_level,
	   p_Carrier_Ship_Method_Info.carrier_site_id,
	   p_Carrier_Ship_Method_Info.organization_id,
	   p_Carrier_Ship_Method_Info.Enabled_Flag,
	   p_Carrier_Ship_Method_Info.Attribute_Category,
	   p_Carrier_Ship_Method_Info.Attribute1,
	   p_Carrier_Ship_Method_Info.Attribute2,
	   p_Carrier_Ship_Method_Info.Attribute3,
	   p_Carrier_Ship_Method_Info.Attribute4,
	   p_Carrier_Ship_Method_Info.Attribute5,
	   p_Carrier_Ship_Method_Info.Attribute6,
	   p_Carrier_Ship_Method_Info.Attribute7,
	   p_Carrier_Ship_Method_Info.Attribute8,
	   p_Carrier_Ship_Method_Info.Attribute9,
	   p_Carrier_Ship_Method_Info.Attribute10,
	   p_Carrier_Ship_Method_Info.Attribute11,
	   p_Carrier_Ship_Method_Info.Attribute12,
	   p_Carrier_Ship_Method_Info.Attribute13,
	   p_Carrier_Ship_Method_Info.Attribute14,
	   p_Carrier_Ship_Method_Info.Attribute15,
	   p_Carrier_Ship_Method_Info.Creation_date,
	   p_Carrier_Ship_Method_Info.Created_By,
	   p_Carrier_Ship_Method_Info.Last_Update_Date,
	   p_Carrier_Ship_Method_Info.Last_Updated_By,
	   p_Carrier_Ship_Method_Info.Last_Update_Login,
	   p_Carrier_Ship_Method_Info.web_enabled
	   );

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'After insert' );
   END IF;
   OPEN C_New_Rowid;
	FETCH C_New_Rowid INTO x_rowid;
	IF (C_New_Rowid%NOTFOUND) THEN
		CLOSE C_New_Rowid;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'C_New_Rowid%NOTFOUND');
                END IF;
		RAISE others;
         END IF;
   CLOSE C_New_Rowid;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
		WHEN others THEN
			x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			WSH_UTIL_CORE.Default_Handler('WSH_CARRIER_SHIP_METHODS_PKG.Update_Carrier_Ship_Method', l_module_name);
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END Create_Carrier_Ship_Method;

PROCEDURE Lock_Carrier_Ship_Method (
  p_rowid                          IN     VARCHAR2
, p_Carrier_Ship_Method_Info       IN     CSMRecType
, x_Return_Status                     OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_lock_row IS
SELECT *
FROM   wsh_carrier_ship_methods
WHERE  rowid = p_rowid
FOR UPDATE of Carrier_Ship_Method_id NOWAIT;

Recinfo C_lock_row%ROWTYPE;
others                         Exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_CARRIER_SHIP_METHOD';
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
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Ship_Method_Id',
                            p_Carrier_Ship_Method_Info.Carrier_Ship_Method_Id);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                            p_Carrier_Ship_Method_Info.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'organization_id',
                            p_Carrier_Ship_Method_Info.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'carrier_site_id',
                             p_Carrier_Ship_Method_Info.carrier_site_id);
      WSH_DEBUG_SV.log(l_module_name,'Freight_code',
                             p_Carrier_Ship_Method_Info.Freight_code);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',
                             p_Carrier_Ship_Method_Info.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'Enabled_Flag',
                             p_Carrier_Ship_Method_Info.Enabled_Flag);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                             p_Carrier_Ship_Method_Info.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'Attribute1',
                             p_Carrier_Ship_Method_Info.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'Attribute2',
                             p_Carrier_Ship_Method_Info.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'Attribute3',
                             p_Carrier_Ship_Method_Info.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'Attribute4',
                             p_Carrier_Ship_Method_Info.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'Attribute5',
                             p_Carrier_Ship_Method_Info.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'Attribute6',
                             p_Carrier_Ship_Method_Info.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'Attribute7',
                             p_Carrier_Ship_Method_Info.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'Attribute8',
                             p_Carrier_Ship_Method_Info.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'Attribute9',
                             p_Carrier_Ship_Method_Info.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'Attribute10',
                             p_Carrier_Ship_Method_Info.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'Attribute11',
                             p_Carrier_Ship_Method_Info.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'Attribute12',
                             p_Carrier_Ship_Method_Info.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'Attribute13',
                             p_Carrier_Ship_Method_Info.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'Attribute14',
                             p_Carrier_Ship_Method_Info.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'Attribute15',
                             p_Carrier_Ship_Method_Info.attribute15);
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
         WSH_DEBUG_SV.log(l_module_name,'C_lock_row%NOTFOUND');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
   END IF;
   CLOSE C_lock_row;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Ship_Method_Id',
                                      Recinfo.Carrier_Ship_Method_Id);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                                      Recinfo.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'organization_id',
                                      Recinfo.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'carrier_site_id',Recinfo.carrier_site_id);
      WSH_DEBUG_SV.log(l_module_name,'Freight_code',Recinfo.Freight_code);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',Recinfo.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'Enabled_Flag',Recinfo.Enabled_Flag);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                      Recinfo.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'Attribute1',Recinfo.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'Attribute2',Recinfo.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'Attribute3',Recinfo.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'Attribute4',Recinfo.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'Attribute5',Recinfo.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'Attribute6',Recinfo.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'Attribute7',Recinfo.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'Attribute8',Recinfo.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'Attribute9',Recinfo.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'Attribute10',Recinfo.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'Attribute11',Recinfo.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'Attribute12',Recinfo.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'Attribute13',Recinfo.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'Attribute14',Recinfo.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'Attribute15',Recinfo.attribute15);
   END IF;
   IF (   (Recinfo.Carrier_Ship_Method_Id = p_Carrier_Ship_Method_Info.Carrier_Ship_Method_Id)
      AND (Recinfo.Ship_Method_Code = p_Carrier_Ship_Method_Info.Ship_Method_Code)
	   AND ( (Recinfo.organization_id = p_Carrier_Ship_Method_Info.organization_id)
	      OR (   (Recinfo.organization_id is NULL)
	  	      AND (p_Carrier_Ship_Method_Info.organization_id IS NULL)))
        AND ( (Recinfo.carrier_site_id = p_Carrier_Ship_Method_Info.carrier_site_id)
	      OR (   (Recinfo.carrier_site_id is NULL)
	          AND (p_Carrier_Ship_Method_Info.carrier_site_id IS NULL)))
	   AND ( (Recinfo.Freight_code = p_Carrier_Ship_Method_Info.Freight_code)
	      OR (   (Recinfo.Freight_code is NULL)
	  	      AND (p_Carrier_Ship_Method_Info.Freight_code IS NULL)))
	   AND ( (Recinfo.Service_level = p_Carrier_Ship_Method_Info.Service_level)
	      OR (   (Recinfo.Service_level is NULL)
	  	      AND (p_Carrier_Ship_Method_Info.Service_level IS NULL)))
      AND (Recinfo.Enabled_Flag = p_Carrier_Ship_Method_Info.Enabled_Flag)
	   AND ( (Recinfo.Attribute_Category = p_Carrier_Ship_Method_Info.Attribute_Category)
	      OR (   (Recinfo.Attribute_Category is NULL)
	  	      AND (p_Carrier_Ship_Method_Info.Attribute_Category IS NULL)))
	   AND ( (Recinfo.Attribute1 = p_Carrier_Ship_Method_Info.Attribute1)
	      OR (   (Recinfo.Attribute1 IS NULL)
	         AND (p_Carrier_Ship_Method_Info.Attribute1 is NULL)))
	   AND ( (Recinfo.Attribute2 = p_Carrier_Ship_Method_Info.Attribute2)
	      OR (   (Recinfo.Attribute2 IS NULL)
	         AND (p_Carrier_Ship_Method_Info.Attribute2 is NULL)))
	   AND ( (Recinfo.Attribute3 = p_Carrier_Ship_Method_Info.Attribute3)
	      OR (   (Recinfo.Attribute3 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute3 is NULL)))
	   AND ( (Recinfo.Attribute4 = p_Carrier_Ship_Method_Info.Attribute4)
	      OR (   (Recinfo.Attribute4 IS NULL)
	         AND (p_Carrier_Ship_Method_Info.Attribute4 is NULL)))
	   AND ( (Recinfo.Attribute5 = p_Carrier_Ship_Method_Info.Attribute5)
	      OR (   (Recinfo.Attribute5 IS NULL)
	         AND (p_Carrier_Ship_Method_Info.Attribute5 is NULL)))
	   AND ( (Recinfo.Attribute6 = p_Carrier_Ship_Method_Info.Attribute6)
	      OR (   (Recinfo.Attribute6 IS NULL)
	         AND (p_Carrier_Ship_Method_Info.Attribute6 is NULL)))
	   AND ( (Recinfo.Attribute7 = p_Carrier_Ship_Method_Info.Attribute7)
		   OR (   (Recinfo.Attribute7 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute7 is NULL)))
	   AND ( (Recinfo.Attribute8 = p_Carrier_Ship_Method_Info.Attribute8)
		   OR (   (Recinfo.Attribute8 IS NULL)
	         AND (p_Carrier_Ship_Method_Info.Attribute8 is NULL)))
	   AND ( (Recinfo.Attribute9 = p_Carrier_Ship_Method_Info.Attribute9)
		   OR (   (Recinfo.Attribute9 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute9 is NULL)))
	   AND ( (Recinfo.Attribute10 = p_Carrier_Ship_Method_Info.Attribute10)
		   OR (   (Recinfo.Attribute10 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute10 is NULL)))
	   AND ( (Recinfo.Attribute11 = p_Carrier_Ship_Method_Info.Attribute11)
	      OR (   (Recinfo.Attribute11 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute11 is NULL)))
	   AND ( (Recinfo.Attribute12 = p_Carrier_Ship_Method_Info.Attribute12)
		   OR (   (Recinfo.Attribute12 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute12 is NULL)))
	   AND ( (Recinfo.Attribute13 = p_Carrier_Ship_Method_Info.Attribute13)
		   OR (   (Recinfo.Attribute13 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute13 is NULL)))
	   AND ( (Recinfo.Attribute14 = p_Carrier_Ship_Method_Info.Attribute14)
		   OR (   (Recinfo.Attribute14 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute14 is NULL)))
	   AND ( (Recinfo.Attribute15 = p_Carrier_Ship_Method_Info.Attribute15)
		   OR (   (Recinfo.Attribute15 IS NULL)
		      AND (p_Carrier_Ship_Method_Info.Attribute15 is NULL)))
	   AND (Recinfo.Web_Enabled = p_Carrier_Ship_Method_Info.Web_Enabled)
      ) THEN
	   --
	   IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Matched');
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   RETURN;
   ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'APP_EXCEPTION.Raise_Exception');
      END IF;
      APP_EXCEPTION.Raise_Exception;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
		WHEN others THEN
			x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			WSH_UTIL_CORE.Default_Handler('WSH_CARRIER_SHIP_METHODS_PKG.Lock_Carrier_Ship_Method',l_module_name);
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END Lock_Carrier_Ship_Method;

PROCEDURE Update_Carrier_Ship_Method (
  p_rowid                          IN     VARCHAR2
, p_Carrier_Ship_Method_Info       IN     CSMRecType
, x_Return_Status                     OUT NOCOPY  VARCHAR2
)
IS
others                             			EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CARRIER_SHIP_METHOD';
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
      WSH_DEBUG_SV.log(l_module_name,'Carrier_Ship_Method_Id',
                            p_Carrier_Ship_Method_Info.Carrier_Ship_Method_Id);
      WSH_DEBUG_SV.log(l_module_name,'Ship_Method_Code',
                            p_Carrier_Ship_Method_Info.Ship_Method_Code);
      WSH_DEBUG_SV.log(l_module_name,'organization_id',
                            p_Carrier_Ship_Method_Info.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'carrier_site_id',
                             p_Carrier_Ship_Method_Info.carrier_site_id);
      WSH_DEBUG_SV.log(l_module_name,'Freight_code',
                             p_Carrier_Ship_Method_Info.Freight_code);
      WSH_DEBUG_SV.log(l_module_name,'Service_level',
                             p_Carrier_Ship_Method_Info.Service_level);
      WSH_DEBUG_SV.log(l_module_name,'Enabled_Flag',
                             p_Carrier_Ship_Method_Info.Enabled_Flag);
      WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                             p_Carrier_Ship_Method_Info.Attribute_Category);
      WSH_DEBUG_SV.log(l_module_name,'Attribute1',
                             p_Carrier_Ship_Method_Info.attribute1);
      WSH_DEBUG_SV.log(l_module_name,'Attribute2',
                             p_Carrier_Ship_Method_Info.attribute2);
      WSH_DEBUG_SV.log(l_module_name,'Attribute3',
                             p_Carrier_Ship_Method_Info.attribute3);
      WSH_DEBUG_SV.log(l_module_name,'Attribute4',
                             p_Carrier_Ship_Method_Info.attribute4);
      WSH_DEBUG_SV.log(l_module_name,'Attribute5',
                             p_Carrier_Ship_Method_Info.attribute5);
      WSH_DEBUG_SV.log(l_module_name,'Attribute6',
                             p_Carrier_Ship_Method_Info.attribute6);
      WSH_DEBUG_SV.log(l_module_name,'Attribute7',
                             p_Carrier_Ship_Method_Info.attribute7);
      WSH_DEBUG_SV.log(l_module_name,'Attribute8',
                             p_Carrier_Ship_Method_Info.attribute8);
      WSH_DEBUG_SV.log(l_module_name,'Attribute9',
                             p_Carrier_Ship_Method_Info.attribute9);
      WSH_DEBUG_SV.log(l_module_name,'Attribute10',
                             p_Carrier_Ship_Method_Info.attribute10);
      WSH_DEBUG_SV.log(l_module_name,'Attribute11',
                             p_Carrier_Ship_Method_Info.attribute11);
      WSH_DEBUG_SV.log(l_module_name,'Attribute12',
                             p_Carrier_Ship_Method_Info.attribute12);
      WSH_DEBUG_SV.log(l_module_name,'Attribute13',
                             p_Carrier_Ship_Method_Info.attribute13);
      WSH_DEBUG_SV.log(l_module_name,'Attribute14',
                             p_Carrier_Ship_Method_Info.attribute14);
      WSH_DEBUG_SV.log(l_module_name,'Attribute15',
                             p_Carrier_Ship_Method_Info.attribute15);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   UPDATE wsh_carrier_ship_methods
   SET
      carrier_id					= p_Carrier_Ship_Method_Info.Carrier_id,
	   ship_method_code			     = p_Carrier_Ship_Method_Info.Ship_Method_Code,
	   freight_code                    = p_Carrier_Ship_Method_Info.Freight_code,
	   service_level                   = p_Carrier_Ship_Method_Info.Service_level,
	   carrier_site_id                 = p_Carrier_Ship_Method_Info.carrier_site_id,
	   organization_id                 = p_Carrier_Ship_Method_Info.organization_id,
	   enabled_flag				= p_Carrier_Ship_Method_Info.Enabled_Flag,
	   attribute_category		     = p_Carrier_Ship_Method_Info.Attribute_Category,
	   attribute1					= p_Carrier_Ship_Method_Info.Attribute1,
	   attribute2					= p_Carrier_Ship_Method_Info.Attribute2,
	   attribute3					= p_Carrier_Ship_Method_Info.Attribute3,
	   attribute4					= p_Carrier_Ship_Method_Info.Attribute4,
	   attribute5					= p_Carrier_Ship_Method_Info.Attribute5,
	   attribute6					= p_Carrier_Ship_Method_Info.Attribute6,
	   attribute7					= p_Carrier_Ship_Method_Info.Attribute7,
	   attribute8					= p_Carrier_Ship_Method_Info.Attribute8,
	   attribute9					= p_Carrier_Ship_Method_Info.Attribute9,
	   attribute10					= p_Carrier_Ship_Method_Info.Attribute10,
	   attribute11					= p_Carrier_Ship_Method_Info.Attribute11,
	   attribute12					= p_Carrier_Ship_Method_Info.Attribute12,
	   attribute13					= p_Carrier_Ship_Method_Info.Attribute13,
	   attribute14					= p_Carrier_Ship_Method_Info.Attribute14,
	   attribute15					= p_Carrier_Ship_Method_Info.Attribute15,
	   last_update_date			     = p_Carrier_Ship_Method_Info.Last_Update_Date,
	   last_updated_by			     = p_Carrier_Ship_Method_Info.Last_Updated_By,
	   last_update_login			= p_Carrier_Ship_Method_Info.Last_Update_Login,
	   web_enabled                         = p_Carrier_Ship_Method_Info.Web_Enabled
WHERE rowid = p_rowid;

   IF (SQL%NOTFOUND) THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'SQL%NOTFOUND');
      END IF;
      --
      RAISE NO_DATA_FOUND;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			FND_MESSAGE.Set_Name('WSH', 'WSH_CSM_NOT_FOUND');
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			WSH_UTIL_CORE.Add_Message(x_return_status,
                                                             l_module_name);
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
			END IF;
			--
      WHEN others THEN
           WSH_UTIL_CORE.Default_Handler('WSH_CARRIER_SHIP_METHODS_PKG.Update_Carrier_Ship_Method', l_module_name);
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	   END IF;
	   --
END Update_Carrier_Ship_Method;

PROCEDURE Delete_Carrier_Ship_Method(
  p_rowid                          IN     VARCHAR2 := NULL
, p_Carrier_Ship_Method_id         IN     NUMBER
, x_Return_Status                     OUT NOCOPY  VARCHAR2
)
IS

CURSOR C_CSM_id
IS
SELECT carrier_ship_method_id
FROM wsh_carrier_ship_methods
WHERE rowid = p_rowid;

l_csm_id                                  NUMBER;
others                                    EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_CARRIER_SHIP_METHOD';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_SHIP_METHOD_ID',P_CARRIER_SHIP_METHOD_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF (p_rowid IS NOT NULL) THEN
		OPEN C_CSM_id;
		FETCH C_CSM_id INTO l_csm_id;
		CLOSE C_CSM_ID;
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_csm_id',l_csm_id);
   END IF;
   IF (l_csm_id IS NULL) THEN
		l_csm_id := p_Carrier_Ship_Method_id;
   END IF;

   IF (p_Carrier_Ship_Method_id IS NOT NULL) THEN
		DELETE FROM wsh_carrier_ship_methods
      WHERE carrier_ship_method_id = l_csm_id;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   ELSE
		RAISE others;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION
        WHEN others THEN
            WSH_UTIL_CORE.Default_Handler('WSH_CARRIER_SHIP_METHODS_PKG.Delete_Carrier_Ship_Method',l_module_name);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	    END IF;
	    --
END Delete_Carrier_Ship_Method;


END WSH_CARRIER_SHIP_METHODS_PKG;

/
