--------------------------------------------------------
--  DDL for Package Body WSH_FREIGHT_COST_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FREIGHT_COST_TYPES_PVT" AS
/* $Header: WSHFCTPB.pls 115.3 2002/11/13 20:08:08 nparikh ship $ */
-- Package internal global variables
g_Return_Status         VARCHAR2(1);

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FREIGHT_COST_TYPES_PVT';
--
PROCEDURE Create_Freight_Cost_Type(
  p_freight_cost_type_info        IN     Freight_Cost_Type_Rec_Type
, x_rowid                         OUT NOCOPY  VARCHAR2
, x_freight_cost_type_id               OUT NOCOPY  NUMBER
, x_return_status                 OUT NOCOPY  VARCHAR2
)
IS
CURSOR C_Next_Freight_Cost_Type_Id
IS
SELECT wsh_freight_cost_types_s.nextval
FROM sys.dual;

CURSOR c_new_row_id
IS
SELECT rowid
FROM wsh_freight_cost_types
WHERE freight_cost_type_id = x_freight_cost_type_id;

create_failure         EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_FREIGHT_COST_TYPE';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.FREIGHT_COST_TYPE_ID',p_freight_cost_type_info.freight_cost_type_id);
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.NAME',p_freight_cost_type_info.name);
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.FREIGHT_COST_TYPE_CODE',p_freight_cost_type_info.freight_cost_type_code);
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.AMOUNT',p_freight_cost_type_info.AMOUNT);
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.CURRENCY_CODE',p_freight_cost_type_info.currency_code);
	    WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.CHARGE_MAP_FLAG',p_freight_cost_type_info.charge_map_flag);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_freight_cost_type_id := p_freight_cost_type_info.freight_cost_type_id;
	IF (x_freight_cost_type_id IS NULL) THEN
		LOOP
			OPEN C_Next_Freight_Cost_Type_Id;
			FETCH C_Next_Freight_Cost_Type_Id INTO x_freight_cost_type_id;
			CLOSE C_Next_Freight_Cost_Type_Id;

			IF (x_freight_cost_type_id IS NOT NULL) THEN
				x_rowid := NULL;
				OPEN c_new_row_id;
				FETCH c_new_row_id INTO x_rowid;
				CLOSE c_new_row_id;

				IF (x_rowid IS NULL) THEN
					EXIT;
				END IF;
			ELSE
				EXIT;
			END IF;
		END LOOP;
	END IF;

	INSERT INTO wsh_freight_cost_types(
		freight_cost_type_id,
		name,
		freight_cost_type_code,
		amount,
		currency_code,
		description,
		start_date_active,
		end_date_active,
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
   	        program_application_id,
   	        program_id,
   	        program_update_date,
   	        request_id,
   	        charge_map_flag
   	) VALUES (
   	x_freight_cost_type_id,
	p_freight_cost_type_info.name,
	p_freight_cost_type_info.freight_cost_type_code,
	p_freight_cost_type_info.amount,
	p_freight_cost_type_info.currency_code,
	p_freight_cost_type_info.description,
	p_freight_cost_type_info.start_date_active,
	p_freight_cost_type_info.end_date_active,
	p_freight_cost_type_info.attribute_category,
	p_freight_cost_type_info.attribute1,
	p_freight_cost_type_info.attribute2,
	p_freight_cost_type_info.attribute3,
	p_freight_cost_type_info.attribute4,
	p_freight_cost_type_info.attribute5,
	p_freight_cost_type_info.attribute6,
	p_freight_cost_type_info.attribute7,
	p_freight_cost_type_info.attribute8,
	p_freight_cost_type_info.attribute9,
	p_freight_cost_type_info.attribute10,
	p_freight_cost_type_info.attribute11,
	p_freight_cost_type_info.attribute12,
	p_freight_cost_type_info.attribute13,
	p_freight_cost_type_info.attribute14,
	p_freight_cost_type_info.attribute15,
	p_freight_cost_type_info.creation_date,
	p_freight_cost_type_info.created_by,
	p_freight_cost_type_info.last_update_date,
	p_freight_cost_type_info.last_updated_by,
	p_freight_cost_type_info.last_update_login,
	p_freight_cost_type_info.program_application_id,
	p_freight_cost_type_info.program_id,
	p_freight_cost_type_info.program_update_date,
	p_freight_cost_type_info.request_id,
   	p_freight_cost_type_info.charge_map_flag
   	);

	OPEN C_New_row_id;
	FETCH C_New_row_id INTO x_rowid;

   IF (C_New_row_id%NOTFOUND) THEN
		CLOSE C_New_row_id;
		RAISE create_failure;
   END IF;

	CLOSE C_new_row_id;

--
-- Debug Statements
--
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'x_freight_cost_type_id',x_freight_cost_type_id);
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
   EXCEPTION
	WHEN create_failure THEN
		wsh_util_core.default_handler('WSH_FREIGHT_COST_TYPES_PVT.CREATE_FREIGHT_COST_TYPE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'CREATE_FAILURE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CREATE_FAILURE');
		END IF;
		--
	WHEN others THEN
		wsh_util_core.default_handler('WSH_FREIGHT_COST_TYPES_PVT.CREATE_FREIGHT_COST_TYPE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Create_Freight_Cost_Type;

PROCEDURE Update_Freight_Cost_Type(
  p_rowid                      IN     VARCHAR2
, p_freight_cost_type_info     IN     Freight_Cost_Type_Rec_Type
, x_return_status              OUT NOCOPY  VARCHAR2
)
IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_FREIGHT_COST_TYPE';
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
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.FREIGHT_COST_TYPE_ID',p_freight_cost_type_info.freight_cost_type_id);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.NAME',p_freight_cost_type_info.name);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_INFO.FREIGHT_COST_TYPE_CODE',p_freight_cost_type_info.freight_cost_type_code);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	UPDATE wsh_freight_cost_types
   SET
	   name                      = p_freight_cost_type_info.name,
	   freight_cost_type_code    = p_freight_cost_type_info.freight_cost_type_code,
	   amount                    = p_freight_cost_type_info.amount,
	   currency_code             = p_freight_cost_type_info.currency_code,
	   description               = p_freight_cost_type_info.description,
	   start_date_active         = p_freight_cost_type_info.start_date_active,
	   end_date_active           = p_freight_cost_type_info.end_date_active,
	   attribute_category        = p_freight_cost_type_info.attribute_category,
	   attribute1                = p_freight_cost_type_info.attribute1,
	   attribute2                = p_freight_cost_type_info.attribute2,
	   attribute3                = p_freight_cost_type_info.attribute3,
	   attribute4                = p_freight_cost_type_info.attribute4,
	   attribute5                = p_freight_cost_type_info.attribute5,
	   attribute6                = p_freight_cost_type_info.attribute6,
	   attribute7                = p_freight_cost_type_info.attribute7,
	   attribute8                = p_freight_cost_type_info.attribute8,
	   attribute9                = p_freight_cost_type_info.attribute9,
	   attribute10               = p_freight_cost_type_info.attribute10,
	   attribute11               = p_freight_cost_type_info.attribute11,
	   attribute12               = p_freight_cost_type_info.attribute12,
	   attribute13               = p_freight_cost_type_info.attribute13,
	   attribute14               = p_freight_cost_type_info.attribute14,
	   attribute15               = p_freight_cost_type_info.attribute15,
	   creation_date             = p_freight_cost_type_info.creation_date,
	   created_by                = p_freight_cost_type_info.created_by,
	   last_update_date          = p_freight_cost_type_info.last_update_date,
	   last_updated_by           = p_freight_cost_type_info.last_updated_by,
	   last_update_login         = p_freight_cost_type_info.last_update_login,
	   program_application_id    = p_freight_cost_type_info.program_application_id,
	   program_id                = p_freight_cost_type_info.program_id,
	   program_update_date	     = p_freight_cost_type_info.program_update_date,
	   request_id                = p_freight_cost_type_info.request_id,
	   charge_map_flag           = p_freight_cost_type_info.charge_map_flag
   WHERE freight_cost_type_id = p_freight_cost_type_info.freight_cost_type_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
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
	WHEN others THEN
		wsh_util_core.default_handler('WSH_FREIGHT_COST_TYPES_PVT.UPDATE_FREIGHT_COST_TYPE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
		--
END Update_Freight_Cost_Type;

PROCEDURE Lock_Freight_Cost_Type(
  p_rowid                      IN     VARCHAR2
, p_freight_cost_type_info          IN     Freight_Cost_Type_Rec_Type
)
IS

CURSOR lock_row IS
SELECT *
FROM wsh_freight_cost_types
WHERE rowid = p_rowid
FOR UPDATE OF freight_cost_type_id NOWAIT;

Recinfo lock_row%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_FREIGHT_COST_TYPE';
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
   END IF;
   --
   OPEN lock_row;
   FETCH lock_row INTO Recinfo;

	IF (lock_row%NOTFOUND) THEN
	   CLOSE lock_row;
	   FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	   app_exception.raise_exception;
	END IF;

	CLOSE lock_row;
	IF (     (Recinfo.freight_cost_type_id = p_freight_cost_type_info.freight_cost_type_id)
	   AND   (   (Recinfo.name = p_freight_cost_type_info.name)
                  or (Recinfo.name is null
                      and p_freight_cost_type_info.name is null))
      	   AND   (Recinfo.freight_cost_type_code = p_freight_cost_type_info.freight_cost_type_code)
       	   AND   (Recinfo.amount = p_freight_cost_type_info.amount)
           AND   (Recinfo.currency_code = p_freight_cost_type_info.currency_code)
	   AND   (   (Recinfo.description = p_freight_cost_type_info.description)
                  or (Recinfo.description is null
                      and p_freight_cost_type_info.description is null))
       	   AND   (   (Recinfo.start_date_active = p_freight_cost_type_info.start_date_active)
                  or (Recinfo.start_date_active is null
                      and p_freight_cost_type_info.start_date_active is null))
      	   AND   (   (Recinfo.end_date_active = p_freight_cost_type_info.end_date_active)
                  or (Recinfo.end_date_active is null
                      and p_freight_cost_type_info.end_date_active is null))
 	   AND   (  (Recinfo.attribute_category = p_freight_cost_type_info.attribute_category)
		   OR    (  (p_freight_cost_type_info.attribute_category IS NULL)
		      AND   (Recinfo.attribute_category IS NULL)))
       	   AND   (  (Recinfo.attribute1 = p_freight_cost_type_info.attribute1)
		   OR    (  (p_freight_cost_type_info.attribute1 IS NULL)
		      AND   (Recinfo.attribute1 IS NULL)))
	   AND   (  (Recinfo.attribute2 = p_freight_cost_type_info.attribute2)
		   OR    (  (p_freight_cost_type_info.attribute2 IS NULL)
		      AND   (Recinfo.attribute2 IS NULL)))
	   AND   (  (Recinfo.attribute3 = p_freight_cost_type_info.attribute3)
		   OR    (  (p_freight_cost_type_info.attribute3 IS NULL)
		      AND   (Recinfo.attribute3 IS NULL)))
	   AND   (  (Recinfo.attribute4 = p_freight_cost_type_info.attribute4)
		   OR    (  (p_freight_cost_type_info.attribute4 IS NULL)
		      AND   (Recinfo.attribute4 IS NULL)))
	   AND   (  (Recinfo.attribute5 = p_freight_cost_type_info.attribute5)
		   OR    (  (p_freight_cost_type_info.attribute5 IS NULL)
		      AND   (Recinfo.attribute5 IS NULL)))
	   AND   (  (Recinfo.attribute6 = p_freight_cost_type_info.attribute6)
		   OR    (  (p_freight_cost_type_info.attribute6 IS NULL)
		      AND   (Recinfo.attribute6 IS NULL)))
	   AND   (  (Recinfo.attribute7 = p_freight_cost_type_info.attribute7)
		   OR    (  (p_freight_cost_type_info.attribute7 IS NULL)
		      AND   (Recinfo.attribute7 IS NULL)))
	   AND   (  (Recinfo.attribute8 = p_freight_cost_type_info.attribute8)
		   OR    (  (p_freight_cost_type_info.attribute8 IS NULL)
		      AND   (Recinfo.attribute8 IS NULL)))
	   AND   (  (Recinfo.attribute9 = p_freight_cost_type_info.attribute9)
		  	OR    (  (p_freight_cost_type_info.attribute9 IS NULL)
		      AND   (Recinfo.attribute9 IS NULL)))
	   AND   (  (Recinfo.attribute10 = p_freight_cost_type_info.attribute10)
		   OR    (  (p_freight_cost_type_info.attribute10 IS NULL)
		      AND   (Recinfo.attribute10 IS NULL)))
	   AND   (  (Recinfo.attribute11 = p_freight_cost_type_info.attribute11)
		   OR    (  (p_freight_cost_type_info.attribute11 IS NULL)
		      AND   (Recinfo.attribute11 IS NULL)))
	   AND   (  (Recinfo.attribute12 = p_freight_cost_type_info.attribute12)
		   OR    (  (p_freight_cost_type_info.attribute12 IS NULL)
		      AND   (Recinfo.attribute12 IS NULL)))
	   AND   (  (Recinfo.attribute13 = p_freight_cost_type_info.attribute13)
		   OR    (  (p_freight_cost_type_info.attribute13 IS NULL)
		      AND   (Recinfo.attribute13 IS NULL)))
	   AND   (  (Recinfo.attribute14 = p_freight_cost_type_info.attribute14)
		   OR    (  (p_freight_cost_type_info.attribute14 IS NULL)
		      AND   (Recinfo.attribute14 IS NULL)))
	   AND   (  (Recinfo.attribute15 = p_freight_cost_type_info.attribute15)
		   OR    (  (p_freight_cost_type_info.attribute15 IS NULL)
		      AND   (Recinfo.attribute15 IS NULL)))
	   AND   (Recinfo.creation_date = p_freight_cost_type_info.creation_date)
	   AND   (Recinfo.created_by = p_freight_cost_type_info.created_by)
	   AND   (Recinfo.last_update_date = p_freight_cost_type_info.last_update_date)
	   AND   (Recinfo.last_update_login = p_freight_cost_type_info.last_update_login)
        ) THEN
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   RETURN;
	ELSE
	   FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
	   app_exception.raise_exception;
	END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN others THEN
	wsh_util_core.default_handler('WSH_FREIGHT_COST_TYPES_PVT.LOCK_FREIGHT_COST_TYPE');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
        raise;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Lock_Freight_Cost_Type;

PROCEDURE Delete_Freight_Cost_Type(
  p_rowid                    IN     VARCHAR2
, p_freight_cost_type_id     IN     NUMBER
, x_return_status	     OUT NOCOPY  VARCHAR2
)
IS
CURSOR C_Get_Freight_cost_type_id
IS
SELECT freight_cost_type_id
FROM wsh_freight_cost_types
WHERE rowid = p_rowid;

l_freight_cost_type_id		NUMBER;
row_not_found                   EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FREIGHT_COST_TYPE';
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
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_COST_TYPE_ID',P_FREIGHT_COST_TYPE_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_freight_cost_type_id := p_freight_cost_type_id;

   IF (p_rowid IS NOT NULL) THEN
	OPEN C_Get_freight_cost_type_id;
	FETCH C_get_freight_cost_type_id INTO l_freight_cost_type_id;
	CLOSE C_Get_Freight_cost_type_id;
   END IF;

   IF (l_freight_cost_type_id IS NOT NULL) THEN
	DELETE FROM wsh_freight_cost_types
	WHERE freight_cost_type_id = p_freight_cost_type_id;
   ELSE
	RAISE row_not_found;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	WHEN row_not_found THEN
		wsh_util_core.default_handler('WSH_FREIGHT_COST_TYPES_PVT.DELETE_FREIGHT_COST_TYPE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'ROW_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ROW_NOT_FOUND');
		END IF;
		--
	WHEN others THEN
		wsh_util_core.default_handler('WSH_FREIGHT_COST_TYPES_PVT.DELETE_FREIGHT_COST_TYPE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
		--
END Delete_Freight_Cost_Type;

END WSH_FREIGHT_COST_TYPES_PVT;

/
