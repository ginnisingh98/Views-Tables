--------------------------------------------------------
--  DDL for Package Body WSH_CARRIER_VEHICLE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CARRIER_VEHICLE_TYPES_PKG" as
/* $Header: WSHVTTHB.pls 115.0 2003/06/26 10:58:48 msutar noship $ */

--- Package Name: WSH_CARRIER_VEHICLE_TYPES_PKG
--- Pupose:       Table Handlers for table WSH_CARRIER_VEHICLE_TYPES_PKG
--- Note:         Please set tabstop=3 to read file with proper alignment

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CARRIER_VEHICLE_TYPES_PKG';
--
procedure Create_Carrier_Vehicle_Type (
   P_Carrier_Vehicle_Info      IN  CVTRecType,
   X_ROWID                     OUT NOCOPY  VARCHAR2,
   X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
   X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
   X_POSITION                  OUT NOCOPY  NUMBER,
   X_PROCEDURE                 OUT NOCOPY  VARCHAR2,
   X_SQLERR                    OUT NOCOPY  VARCHAR2,
   X_SQL_CODE                  OUT NOCOPY  VARCHAR2
) is

  --
  -- Debug Statements
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Carrier_Vehicle_Type';
  --

begin

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
     WSH_DEBUG_SV.log(l_module_name,'CARRIER_ID',
                                   P_Carrier_Vehicle_Info.CARRIER_ID);
     WSH_DEBUG_SV.log(l_module_name,'VEHICLE_TYPE_ID',
                                   P_Carrier_Vehicle_Info.VEHICLE_TYPE_ID);
     WSH_DEBUG_SV.log(l_module_name,'ASSIGNED_FLAG',
                                   P_Carrier_Vehicle_Info.ASSIGNED_FLAG);
     WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                   P_Carrier_Vehicle_Info.Attribute_Category);
     WSH_DEBUG_SV.log(l_module_name,'attribute1',
                                   P_Carrier_Vehicle_Info.attribute1);
     WSH_DEBUG_SV.log(l_module_name,'attribute2',
                                   P_Carrier_Vehicle_Info.attribute2);
     WSH_DEBUG_SV.log(l_module_name,'attribute3',
                                   P_Carrier_Vehicle_Info.attribute3);
     WSH_DEBUG_SV.log(l_module_name,'attribute4',
                                   P_Carrier_Vehicle_Info.attribute4);
     WSH_DEBUG_SV.log(l_module_name,'attribute5',
                                   P_Carrier_Vehicle_Info.attribute5);
     WSH_DEBUG_SV.log(l_module_name,'attribute6',
                                   P_Carrier_Vehicle_Info.attribute6);
     WSH_DEBUG_SV.log(l_module_name,'attribute7',
                                   P_Carrier_Vehicle_Info.attribute7);
     WSH_DEBUG_SV.log(l_module_name,'attribute8',
                                   P_Carrier_Vehicle_Info.attribute8);
     WSH_DEBUG_SV.log(l_module_name,'attribute9',
                                   P_Carrier_Vehicle_Info.attribute9);
     WSH_DEBUG_SV.log(l_module_name,'attribute10',
                                   P_Carrier_Vehicle_Info.attribute10);
     WSH_DEBUG_SV.log(l_module_name,'attribute11',
                                   P_Carrier_Vehicle_Info.attribute11);
     WSH_DEBUG_SV.log(l_module_name,'attribute12',
                                   P_Carrier_Vehicle_Info.attribute12);
     WSH_DEBUG_SV.log(l_module_name,'attribute13',
                                   P_Carrier_Vehicle_Info.attribute13);
     WSH_DEBUG_SV.log(l_module_name,'attribute14',
                                   P_Carrier_Vehicle_Info.attribute14);
     WSH_DEBUG_SV.log(l_module_name,'attribute15',
                                   P_Carrier_Vehicle_Info.attribute15);
  END IF;
  --

  X_RETURN_STATUS := 'S';

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Inserting into WSH_CARRIER_VEHICLE_TYPES');
  END IF;

  insert into WSH_CARRIER_VEHICLE_TYPES (
    CARRIER_ID,
    VEHICLE_TYPE_ID,
    ASSIGNED_FLAG,
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
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_Carrier_Vehicle_Info.CARRIER_ID,
    P_Carrier_Vehicle_Info.VEHICLE_TYPE_ID,
    P_Carrier_Vehicle_Info.ASSIGNED_FLAG,
    P_Carrier_Vehicle_Info.ATTRIBUTE_CATEGORY,
    P_Carrier_Vehicle_Info.ATTRIBUTE1,
    P_Carrier_Vehicle_Info.ATTRIBUTE2,
    P_Carrier_Vehicle_Info.ATTRIBUTE3,
    P_Carrier_Vehicle_Info.ATTRIBUTE4,
    P_Carrier_Vehicle_Info.ATTRIBUTE5,
    P_Carrier_Vehicle_Info.ATTRIBUTE6,
    P_Carrier_Vehicle_Info.ATTRIBUTE7,
    P_Carrier_Vehicle_Info.ATTRIBUTE8,
    P_Carrier_Vehicle_Info.ATTRIBUTE9,
    P_Carrier_Vehicle_Info.ATTRIBUTE10,
    P_Carrier_Vehicle_Info.ATTRIBUTE11,
    P_Carrier_Vehicle_Info.ATTRIBUTE12,
    P_Carrier_Vehicle_Info.ATTRIBUTE13,
    P_Carrier_Vehicle_Info.ATTRIBUTE14,
    P_Carrier_Vehicle_Info.ATTRIBUTE15,
    P_Carrier_Vehicle_Info.CREATION_DATE,
    P_Carrier_Vehicle_Info.CREATED_BY,
    P_Carrier_Vehicle_Info.LAST_UPDATE_DATE,
    P_Carrier_Vehicle_Info.LAST_UPDATED_BY,
    P_Carrier_Vehicle_Info.LAST_UPDATE_LOGIN
  ) returning rowid into X_ROWID;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
exception
  WHEN OTHERS THEN
     x_return_status := 'E';
     x_exception_msg := 'WHEN OTHERS Exception Raise';
     x_procedure := 'Inserting into WSH_CARRIER_VEHICLE_TYPES table';
     x_position := 0;
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

end Create_Carrier_Vehicle_Type;

procedure Update_Carrier_Vehicle_Type (
   P_Carrier_Vehicle_Info          IN  CVTRecType,
   P_ROWID                         IN  VARCHAR2,
   X_RETURN_STATUS                 OUT NOCOPY  VARCHAR2,
   X_EXCEPTION_MSG                 OUT NOCOPY  VARCHAR2,
   X_PROCEDURE                     OUT NOCOPY  VARCHAR2,
   X_POSITION                      OUT NOCOPY  NUMBER,
   X_SQLERR                        OUT NOCOPY  VARCHAR2,
   X_SQL_CODE                      OUT NOCOPY  VARCHAR2
   ) is

   UPDATE_FAILED exception;

  --
  -- Debug Statements
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Update_Carrier_Vehicle_Type';
  --

begin

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
     WSH_DEBUG_SV.log(l_module_name,'CARRIER_ID',
                                   P_Carrier_Vehicle_Info.CARRIER_ID);
     WSH_DEBUG_SV.log(l_module_name,'VEHICLE_TYPE_ID',
                                   P_Carrier_Vehicle_Info.VEHICLE_TYPE_ID);
     WSH_DEBUG_SV.log(l_module_name,'ASSIGNED_FLAG',
                                   P_Carrier_Vehicle_Info.ASSIGNED_FLAG);
     WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                   P_Carrier_Vehicle_Info.Attribute_Category);
     WSH_DEBUG_SV.log(l_module_name,'attribute1',
                                   P_Carrier_Vehicle_Info.attribute1);
     WSH_DEBUG_SV.log(l_module_name,'attribute2',
                                   P_Carrier_Vehicle_Info.attribute2);
     WSH_DEBUG_SV.log(l_module_name,'attribute3',
                                   P_Carrier_Vehicle_Info.attribute3);
     WSH_DEBUG_SV.log(l_module_name,'attribute4',
                                   P_Carrier_Vehicle_Info.attribute4);
     WSH_DEBUG_SV.log(l_module_name,'attribute5',
                                   P_Carrier_Vehicle_Info.attribute5);
     WSH_DEBUG_SV.log(l_module_name,'attribute6',
                                   P_Carrier_Vehicle_Info.attribute6);
     WSH_DEBUG_SV.log(l_module_name,'attribute7',
                                   P_Carrier_Vehicle_Info.attribute7);
     WSH_DEBUG_SV.log(l_module_name,'attribute8',
                                   P_Carrier_Vehicle_Info.attribute8);
     WSH_DEBUG_SV.log(l_module_name,'attribute9',
                                   P_Carrier_Vehicle_Info.attribute9);
     WSH_DEBUG_SV.log(l_module_name,'attribute10',
                                   P_Carrier_Vehicle_Info.attribute10);
     WSH_DEBUG_SV.log(l_module_name,'attribute11',
                                   P_Carrier_Vehicle_Info.attribute11);
     WSH_DEBUG_SV.log(l_module_name,'attribute12',
                                   P_Carrier_Vehicle_Info.attribute12);
     WSH_DEBUG_SV.log(l_module_name,'attribute13',
                                   P_Carrier_Vehicle_Info.attribute13);
     WSH_DEBUG_SV.log(l_module_name,'attribute14',
                                   P_Carrier_Vehicle_Info.attribute14);
     WSH_DEBUG_SV.log(l_module_name,'attribute15',
                                   P_Carrier_Vehicle_Info.attribute15);
  END IF;
  --

  x_return_status := 'S';

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Updating into WSH_CARRIER_VEHICLE_TYPES');
  END IF;

  update WSH_CARRIER_VEHICLE_TYPES set
    VEHICLE_TYPE_ID     = P_Carrier_Vehicle_Info.VEHICLE_TYPE_ID,
    ASSIGNED_FLAG 	= P_Carrier_Vehicle_Info.ASSIGNED_FLAG,
    ATTRIBUTE_CATEGORY 	= P_Carrier_Vehicle_Info.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 		= P_Carrier_Vehicle_Info.ATTRIBUTE1,
    ATTRIBUTE2 		= P_Carrier_Vehicle_Info.ATTRIBUTE2,
    ATTRIBUTE3 		= P_Carrier_Vehicle_Info.ATTRIBUTE3,
    ATTRIBUTE4 		= P_Carrier_Vehicle_Info.ATTRIBUTE4,
    ATTRIBUTE5 		= P_Carrier_Vehicle_Info.ATTRIBUTE5,
    ATTRIBUTE6 		= P_Carrier_Vehicle_Info.ATTRIBUTE6,
    ATTRIBUTE7 		= P_Carrier_Vehicle_Info.ATTRIBUTE7,
    ATTRIBUTE8 		= P_Carrier_Vehicle_Info.ATTRIBUTE8,
    ATTRIBUTE9 		= P_Carrier_Vehicle_Info.ATTRIBUTE9,
    ATTRIBUTE10 	= P_Carrier_Vehicle_Info.ATTRIBUTE10,
    ATTRIBUTE11 	= P_Carrier_Vehicle_Info.ATTRIBUTE11,
    ATTRIBUTE12 	= P_Carrier_Vehicle_Info.ATTRIBUTE12,
    ATTRIBUTE13 	= P_Carrier_Vehicle_Info.ATTRIBUTE13,
    ATTRIBUTE14 	= P_Carrier_Vehicle_Info.ATTRIBUTE14,
    ATTRIBUTE15 	= P_Carrier_Vehicle_Info.ATTRIBUTE15,
    LAST_UPDATE_DATE 	= P_Carrier_Vehicle_Info.LAST_UPDATE_DATE,
    LAST_UPDATED_BY 	= P_Carrier_Vehicle_Info.LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 	= P_Carrier_Vehicle_Info.LAST_UPDATE_LOGIN
  where ROWID = P_ROWID;

  if (sql%notfound) then
    x_return_status := 'E';
    raise UPDATE_FAILED;
  end if;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

exception
   WHEN UPDATE_FAILED THEN
     x_exception_msg := 'Update Failed Exception';
     x_procedure := 'Updating into WSH_CARRIER_VEHICLE_TYPES table';
     x_position := 0;
     x_sqlerr := sqlerrm;
     x_sql_code := sqlcode;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_FAILED');
     END IF;
     --
   WHEN OTHERS THEN
     x_return_status := 'E';
     x_exception_msg := 'WHEN OTHERS Exception Raise';
     x_procedure := 'Updating into WSH_CARRIER_VEHICLE_TYPES table';
     x_position := 0;
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
end Update_Carrier_Vehicle_Type;

procedure Lock_Carrier_Vehicle_Type (
   P_Carrier_Vehicle_Info IN  CVTRecType,
   P_ROWID                IN  VARCHAR2,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2
) is
  cursor c is select
      VEHICLE_TYPE_ID,
      ASSIGNED_FLAG,
      ATTRIBUTE_CATEGORY,
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
    from WSH_CARRIER_VEHICLE_TYPES
    where ROWID = P_ROWID
    for update of CARRIER_ID nowait;

    recinfo c%rowtype;

  --
  -- Debug Statements
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Lock_Carrier_Vehicle_Type';
  --
begin

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
     WSH_DEBUG_SV.log(l_module_name,'CARRIER_ID',
                                   P_Carrier_Vehicle_Info.CARRIER_ID);
     WSH_DEBUG_SV.log(l_module_name,'VEHICLE_TYPE_ID',
                                   P_Carrier_Vehicle_Info.VEHICLE_TYPE_ID);
     WSH_DEBUG_SV.log(l_module_name,'ASSIGNED_FLAG',
                                   P_Carrier_Vehicle_Info.ASSIGNED_FLAG);
     WSH_DEBUG_SV.log(l_module_name,'Attribute_Category',
                                   P_Carrier_Vehicle_Info.Attribute_Category);
     WSH_DEBUG_SV.log(l_module_name,'attribute1',
                                   P_Carrier_Vehicle_Info.attribute1);
     WSH_DEBUG_SV.log(l_module_name,'attribute2',
                                   P_Carrier_Vehicle_Info.attribute2);
     WSH_DEBUG_SV.log(l_module_name,'attribute3',
                                   P_Carrier_Vehicle_Info.attribute3);
     WSH_DEBUG_SV.log(l_module_name,'attribute4',
                                   P_Carrier_Vehicle_Info.attribute4);
     WSH_DEBUG_SV.log(l_module_name,'attribute5',
                                   P_Carrier_Vehicle_Info.attribute5);
     WSH_DEBUG_SV.log(l_module_name,'attribute6',
                                   P_Carrier_Vehicle_Info.attribute6);
     WSH_DEBUG_SV.log(l_module_name,'attribute7',
                                   P_Carrier_Vehicle_Info.attribute7);
     WSH_DEBUG_SV.log(l_module_name,'attribute8',
                                   P_Carrier_Vehicle_Info.attribute8);
     WSH_DEBUG_SV.log(l_module_name,'attribute9',
                                   P_Carrier_Vehicle_Info.attribute9);
     WSH_DEBUG_SV.log(l_module_name,'attribute10',
                                   P_Carrier_Vehicle_Info.attribute10);
     WSH_DEBUG_SV.log(l_module_name,'attribute11',
                                   P_Carrier_Vehicle_Info.attribute11);
     WSH_DEBUG_SV.log(l_module_name,'attribute12',
                                   P_Carrier_Vehicle_Info.attribute12);
     WSH_DEBUG_SV.log(l_module_name,'attribute13',
                                   P_Carrier_Vehicle_Info.attribute13);
     WSH_DEBUG_SV.log(l_module_name,'attribute14',
                                   P_Carrier_Vehicle_Info.attribute14);
     WSH_DEBUG_SV.log(l_module_name,'attribute15',
                                   P_Carrier_Vehicle_Info.attribute15);
  END IF;
  --

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.VEHICLE_TYPE_ID = P_Carrier_Vehicle_Info.VEHICLE_TYPE_ID)
      AND ((recinfo.ASSIGNED_FLAG = P_Carrier_Vehicle_Info.ASSIGNED_FLAG)
           OR ((recinfo.ASSIGNED_FLAG is null) AND (P_Carrier_Vehicle_Info.ASSIGNED_FLAG is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = P_Carrier_Vehicle_Info.ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE2 = P_Carrier_Vehicle_Info.ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_Carrier_Vehicle_Info.ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_Carrier_Vehicle_Info.ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_Carrier_Vehicle_Info.ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_Carrier_Vehicle_Info.ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_Carrier_Vehicle_Info.ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_Carrier_Vehicle_Info.ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_Carrier_Vehicle_Info.ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_Carrier_Vehicle_Info.ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = P_Carrier_Vehicle_Info.ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = P_Carrier_Vehicle_Info.ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = P_Carrier_Vehicle_Info.ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = P_Carrier_Vehicle_Info.ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = P_Carrier_Vehicle_Info.ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (P_Carrier_Vehicle_Info.ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

  return;
exception
  WHEN others THEN
     x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     WSH_UTIL_CORE.Default_Handler('WSH_CARRIER_VEHICLE_TYPES_PKG.Lock_Carrier_Vehicle_Type');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
end Lock_Carrier_Vehicle_Type;

end WSH_CARRIER_VEHICLE_TYPES_PKG;

/
