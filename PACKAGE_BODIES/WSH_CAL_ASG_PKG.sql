--------------------------------------------------------
--  DDL for Package Body WSH_CAL_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CAL_ASG_PKG" AS
-- $Header: WSHCAPKB.pls 115.10 2003/07/22 07:50:03 msutar ship $

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_CAL_ASG_PKG';
-- add your constants here if any

--========================================================================
-- PROCEDURE : Create_Cal_Asg          PUBLIC
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Sets up a transportation calendar
--========================================================================
PROCEDURE Create_Cal_Asg
( p_api_version_number      IN  NUMBER
, p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
, p_cal_asg_info            IN  CalAsgRecType DEFAULT NULL
, x_return_status           OUT NOCOPY  VARCHAR2
, x_msg_count               OUT NOCOPY  NUMBER
, x_msg_data                OUT NOCOPY  VARCHAR2
, x_Calendar_Aassignment_Id OUT NOCOPY  NUMBER
)
IS
  -- <insert here your local variables declaration>
  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Create_Cal_Asg';

  CURSOR get_cal_id IS
  SELECT WSH_CALENDAR_ASSIGNMENTS_S.NextVal
  FROM   sys.dual;

  l_cal_id NUMBER;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CAL_ASG';
  --
BEGIN
  --  Standard call to check for call compatibility
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CALENDAR_TYPE',p_cal_asg_info.CALENDAR_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ASSOCIATION_TYPE',p_cal_asg_info.ASSOCIATION_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ENABLED_FLAG',p_cal_asg_info.ENABLED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CALENDAR_CODE',p_cal_asg_info.CALENDAR_CODE);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ORGANIZATION_ID',p_cal_asg_info.ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.LOCATION_ID',p_cal_asg_info.LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.VENDOR_ID',p_cal_asg_info.VENDOR_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.VENDOR_SITE_ID',p_cal_asg_info.VENDOR_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CUSTOMER_ID',p_cal_asg_info.CUSTOMER_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CUSTOMER_SITE_USE_ID',p_cal_asg_info.CUSTOMER_SITE_USE_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.REIGHT_CODE',p_cal_asg_info.FREIGHT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.FREIGHT_ORG_ID',p_cal_asg_info.FREIGHT_ORG_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CARRIER_ID',p_cal_asg_info.VENDOR_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CARRIER_SITE_ID',p_cal_asg_info.VENDOR_SITE_ID);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_api_name
         , G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- <begin procedure logic>
    OPEN  get_cal_id;
    FETCH get_cal_id INTO l_cal_id;
    CLOSE get_cal_id;

    x_Calendar_Aassignment_Id := l_cal_id;

    INSERT INTO WSH_CALENDAR_ASSIGNMENTS
             (CALENDAR_ASSIGNMENT_ID,
              CALENDAR_CODE,
              CALENDAR_TYPE,
              ASSOCIATION_TYPE,
              ENABLED_FLAG,
              ORGANIZATION_ID,
              LOCATION_ID,
              VENDOR_ID,
              VENDOR_SITE_ID,
              CUSTOMER_ID,
              CUSTOMER_SITE_USE_ID,
              FREIGHT_CODE,
              FREIGHT_ORG_ID,
              CARRIER_ID,
              CARRIER_SITE_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
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
             )
             VALUES
             (l_cal_id,
              p_cal_asg_info.calendar_code,
              p_cal_asg_info.calendar_type,
              p_cal_asg_info.association_type,
              p_cal_asg_info.enabled_flag,
              p_cal_asg_info.organization_id,
              p_cal_asg_info.location_id,
              p_cal_asg_info.vendor_id,
              p_cal_asg_info.vendor_site_id,
              p_cal_asg_info.customer_id,
              p_cal_asg_info.customer_site_use_id,
              p_cal_asg_info.freight_code,
              p_cal_asg_info.freight_org_id,
              p_cal_asg_info.carrier_id,
              p_cal_asg_info.carrier_site_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              p_cal_asg_info.ATTRIBUTE_CATEGORY,
              p_cal_asg_info.ATTRIBUTE1,
              p_cal_asg_info.ATTRIBUTE2,
              p_cal_asg_info.ATTRIBUTE3,
              p_cal_asg_info.ATTRIBUTE4,
              p_cal_asg_info.ATTRIBUTE5,
              p_cal_asg_info.ATTRIBUTE6,
              p_cal_asg_info.ATTRIBUTE7,
              p_cal_asg_info.ATTRIBUTE8,
              p_cal_asg_info.ATTRIBUTE9,
              p_cal_asg_info.ATTRIBUTE10,
              p_cal_asg_info.ATTRIBUTE11,
              p_cal_asg_info.ATTRIBUTE12,
              p_cal_asg_info.ATTRIBUTE13,
              p_cal_asg_info.ATTRIBUTE14,
              p_cal_asg_info.ATTRIBUTE15
              );

  -- <end of API logic>
  -- report success
  -- commenting out as this value is set in above procedure
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get
  ( p_count => x_msg_count
  , p_data  => x_msg_data
  );
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Create_Cal_Asg'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Create_Cal_Asg;
--========================================================================
-- PROCEDURE : Update_Cal_Asg            PUBLIC
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_calendar_assignment_id  Primary Key
--             p_calendar_code         New Calendar Code
--             p_enabled_flag          Is calendar enabled?
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Updates the calendar code for an association
--========================================================================
PROCEDURE Update_Cal_Asg
( p_api_version_number    IN  NUMBER
, p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
, p_calendar_asgmt_id     IN  NUMBER
, p_cal_asg_info          IN  CalAsgRecType DEFAULT NULL
, x_return_status         OUT NOCOPY  VARCHAR2
, x_msg_count             OUT NOCOPY  NUMBER
, x_msg_data              OUT NOCOPY  VARCHAR2
) IS
  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Update_Cal_Asg';
  -- <insert here your local variables declaration>
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CAL_ASG';
  --
BEGIN
  --  Standard call to check for call compatibility
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'p_calendar_asgmt_id',p_calendar_asgmt_id);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CALENDAR_CODE',p_cal_asg_info.CALENDAR_CODE);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ENABLED_FLAG',p_cal_asg_info.ENABLED_FLAG);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_api_name
         ,   G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- <begin procedure logic>
  UPDATE WSH_CALENDAR_ASSIGNMENTS
  SET ENABLED_FLAG       = p_cal_asg_info.enabled_flag
    , CALENDAR_CODE      = p_cal_asg_info.calendar_code
    , ATTRIBUTE_CATEGORY = p_cal_asg_info.ATTRIBUTE_CATEGORY
    , ATTRIBUTE1         = p_cal_asg_info.ATTRIBUTE1
    , ATTRIBUTE2         = p_cal_asg_info.ATTRIBUTE2
    , ATTRIBUTE3         = p_cal_asg_info.ATTRIBUTE3
    , ATTRIBUTE4         = p_cal_asg_info.ATTRIBUTE4
    , ATTRIBUTE5         = p_cal_asg_info.ATTRIBUTE5
    , ATTRIBUTE6         = p_cal_asg_info.ATTRIBUTE6
    , ATTRIBUTE7         = p_cal_asg_info.ATTRIBUTE7
    , ATTRIBUTE8         = p_cal_asg_info.ATTRIBUTE8
    , ATTRIBUTE9         = p_cal_asg_info.ATTRIBUTE9
    , ATTRIBUTE10        = p_cal_asg_info.ATTRIBUTE10
    , ATTRIBUTE11        = p_cal_asg_info.ATTRIBUTE11
    , ATTRIBUTE12        = p_cal_asg_info.ATTRIBUTE12
    , ATTRIBUTE13        = p_cal_asg_info.ATTRIBUTE13
    , ATTRIBUTE14        = p_cal_asg_info.ATTRIBUTE14
    , ATTRIBUTE15        = p_cal_asg_info.ATTRIBUTE15
    , LAST_UPDATE_DATE   = sysdate
    , LAST_UPDATED_BY    = FND_GLOBAL.user_id
    , LAST_UPDATE_LOGIN  = FND_GLOBAL.login_id
  WHERE CALENDAR_ASSIGNMENT_ID = p_calendar_asgmt_id;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- <end of API logic>
  -- report success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get
  ( p_count => x_msg_count
  , p_data  => x_msg_data
  );
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Update_Cal_Asg'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Update_Cal_Asg;
--========================================================================
-- PROCEDURE : Lock_Cal_Asg            PUBLIC
-- PARAMETERS: p_calendar_assignment_id  Primary key
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Validates a shipping or receiving date against a shipping
--========================================================================
PROCEDURE Lock_Cal_Asg
( p_calendar_assignment_id     IN  NUMBER
, p_cal_asg_info               IN  CalAsgRecType DEFAULT NULL
)
IS
  CURSOR lock_row IS
  SELECT CALENDAR_CODE,
         ENABLED_FLAG,
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
  FROM wsh_calendar_assignments
  WHERE calendar_assignment_id = p_calendar_assignment_id
  FOR UPDATE OF calendar_assignment_id NOWAIT;

  Recinfo lock_row%ROWTYPE;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_CAL_ASG';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CALENDAR_ASSIGNMENT_ID',P_CALENDAR_ASSIGNMENT_ID);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.CALENDAR_CODE',p_cal_asg_info.CALENDAR_CODE);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ENABLED_FLAG',p_cal_asg_info.ENABLED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE_CATEGORY',p_cal_asg_info.ATTRIBUTE_CATEGORY);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE1',p_cal_asg_info.ATTRIBUTE1);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE2',p_cal_asg_info.ATTRIBUTE2);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE3',p_cal_asg_info.ATTRIBUTE3);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE4',p_cal_asg_info.ATTRIBUTE4);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE5',p_cal_asg_info.ATTRIBUTE5);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE6',p_cal_asg_info.ATTRIBUTE6);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE7',p_cal_asg_info.ATTRIBUTE7);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE8',p_cal_asg_info.ATTRIBUTE8);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE9',p_cal_asg_info.ATTRIBUTE9);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE10',p_cal_asg_info.ATTRIBUTE10);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE11',p_cal_asg_info.ATTRIBUTE11);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE12',p_cal_asg_info.ATTRIBUTE12);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE13',p_cal_asg_info.ATTRIBUTE13);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE14',p_cal_asg_info.ATTRIBUTE14);
      WSH_DEBUG_SV.log(l_module_name,'p_cal_asg_info.ATTRIBUTE15',p_cal_asg_info.ATTRIBUTE15);
  END IF;
  --
  OPEN  lock_row;
  FETCH lock_row INTO Recinfo;
  IF (lock_row%NOTFOUND) THEN
      CLOSE lock_row;
     FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
     WSH_UTIL_CORE.ADD_MESSAGE('E');
     APP_EXCEPTION.Raise_exception;
  END IF;
  CLOSE lock_row;
     IF (((recinfo.CALENDAR_CODE = p_cal_asg_info.CALENDAR_CODE)
           OR ((recinfo.CALENDAR_CODE is null) AND (p_cal_asg_info.CALENDAR_CODE is null)))
      AND ((recinfo.ENABLED_FLAG = p_cal_asg_info.ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (p_cal_asg_info.ENABLED_FLAG is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = p_cal_asg_info.ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (p_cal_asg_info.ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = p_cal_asg_info.ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (p_cal_asg_info.ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = p_cal_asg_info.ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (p_cal_asg_info.ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = p_cal_asg_info.ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (p_cal_asg_info.ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = p_cal_asg_info.ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (p_cal_asg_info.ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = p_cal_asg_info.ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (p_cal_asg_info.ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = p_cal_asg_info.ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (p_cal_asg_info.ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = p_cal_asg_info.ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (p_cal_asg_info.ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = p_cal_asg_info.ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (p_cal_asg_info.ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = p_cal_asg_info.ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (p_cal_asg_info.ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = p_cal_asg_info.ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (p_cal_asg_info.ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = p_cal_asg_info.ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (p_cal_asg_info.ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = p_cal_asg_info.ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (p_cal_asg_info.ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = p_cal_asg_info.ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (p_cal_asg_info.ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = p_cal_asg_info.ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (p_cal_asg_info.ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = p_cal_asg_info.ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (p_cal_asg_info.ATTRIBUTE15 is null)))
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
        WSH_UTIL_CORE.ADD_MESSAGE('E');
        APP_EXCEPTION.Raise_Exception;
     END IF;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
END Lock_Cal_Asg;
--========================================================================
-- PROCEDURE : Delete_Cal_Asg            PUBLIC
-- PARAMETERS: p_api_version_number      known api versionerror buffer
--             p_init_msg_list           FND_API.G_TRUE to reset list
--             x_return_status           return status
--             x_msg_count               number of messages in the list
--             x_msg_data                text of messages
--             p_rowid                   Row ID to lock
--             p_calendar_assignment_id  primary key
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Deletes a calendar assignment.
--                      The order in which it looks at the parameters
--                      are:
--                      - p_rowid
--                      - p_calendar_assignment_id
--========================================================================
PROCEDURE Delete_Cal_Asg
( p_api_version_number IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_calendar_assignment_id IN  NUMBER
) IS

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_CAL_ASG';
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
         WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
         WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
         WSH_DEBUG_SV.log(l_module_name,'P_CALENDAR_ASSIGNMENT_ID',P_CALENDAR_ASSIGNMENT_ID);
     END IF;
     --
     IF p_calendar_assignment_id IS NOT NULL THEN
        DELETE FROM wsh_calendar_assignments
        WHERE  calendar_assignment_id = p_calendar_assignment_id;
     END IF;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
END Delete_Cal_Asg;

END WSH_CAL_ASG_PKG;

/
