--------------------------------------------------------
--  DDL for Package Body ASO_SUP_TEMPLATE_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SUP_TEMPLATE_DATA_PVT" as
/* $Header: asovstmb.pls 120.1.12010000.2 2015/02/10 08:26:20 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_SUP_TEMPLATE_DATA_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(100):= 'ASO_SUP_TEMPLATE_DATA_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovstmb.pls';

FUNCTION Validate_Template(
     p_template_context  IN   VARCHAR2,
     p_template_level      IN      VARCHAR2)
RETURN VARCHAR2
IS


    x_return_status    VARCHAR2(1);
    l_context_count    VARCHAR2(1);
    l_level_count      VARCHAR2(1);
    l_lookup_code      VARCHAR2(240);


CURSOR c_template_context (p_templ_context VARCHAR2) IS

         SELECT LOOKUP_CODE
         from ASO_LOOKUPS
         where LOOKUP_TYPE = 'ASO_SUP_TEMPLATE_CONTEXT'
         AND    lookup_code = p_templ_context
	    and enabled_flag = 'Y'
         and sysdate between nvl(start_date_active, sysdate)
	    and nvl(end_date_active,sysdate);

/*
	SELECT  lookup_code
     FROM   fnd_lookup_values
     WHERE  lookup_type = 'ASO_SUP_TEMPLATE_CONTEXT'
     AND    lookup_code = p_templ_context
     AND    view_application_id = 697
     AND    LANGUAGE = userenv('LANG')
     and    ENABLED_FLAG = 'Y';
*/

CURSOR c_template_level (p_lookup_type VARCHAR2,p_templ_level VARCHAR2) IS
     SELECT  'X'
     FROM   fnd_lookup_values
     WHERE  lookup_type = p_lookup_type
     AND    lookup_code = p_templ_level
     AND    view_application_id = 697
     AND    LANGUAGE = userenv('LANG')
     and    ENABLED_FLAG = 'Y';

BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('Validate_Template: p_template_context :'||p_template_context, 1, 'N');
     aso_debug_pub.add('Validate_Template: p_template_level :'||p_template_level, 1, 'N');
    END IF;

    -- Validate the template context
    OPEN c_template_context(p_template_context);

    FETCH c_template_context INTO l_lookup_code;
    IF c_template_context%NOTFOUND THEN

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
         FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
         FND_MESSAGE.Set_Token ('COLUMN' , 'TEMPLATE CONTEXT', FALSE );
         FND_MESSAGE.Set_Token ('VALUE' ,p_template_context, FALSE );
            FND_MSG_PUB.ADD;
      END IF;
         x_return_status :=  FND_API.G_RET_STS_ERROR;
      RETURN x_return_status;
    END IF;

    CLOSE c_template_context;

   -- Validate the template level
    OPEN c_template_level(l_lookup_code,p_template_level);

    FETCH c_template_level INTO l_level_count;

    IF c_template_level%NOTFOUND THEN

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
         FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
         FND_MESSAGE.Set_Token ('COLUMN' , 'TEMPLATE LEVEL', FALSE );
         FND_MESSAGE.Set_Token ('VALUE' ,p_template_level, FALSE );
            FND_MSG_PUB.ADD;
      END IF;
         x_return_status :=  FND_API.G_RET_STS_ERROR;
      RETURN x_return_status;

    END IF;

    CLOSE c_template_level;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Validate_Template: x_return_status: '||x_return_status, 1, 'N');
     END IF;

RETURN x_return_status;

END Validate_Template;

PROCEDURE CREATE_TEMPLATE
(
 P_Api_Version_Number          IN         NUMBER,
 P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
 P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
 P_TEMPLATE_REC     IN          ASO_SUP_TEMPLATE_DATA_PVT.TEMPLATE_REC_TYPE,
 X_Template_id                 OUT NOCOPY /* file.sql.39 change */           NUMBER,
 X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 )

IS

l_api_name                    VARCHAR2 ( 150 ) := 'CREATE_TEMPLATE';
l_api_version_number CONSTANT NUMBER := 1.0;
row_id                        varchar2(64);
l_TEMPLATE_id                 NUMBER;
l_return_status               VARCHAR2(1);

BEGIN


-- Establish a standard save point
      SAVEPOINT CREATE_TEMPLATE_PVT;

-- Standard call to check for call compatability
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;


--  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

-- API BODY
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ('CREATE_TEMPLATE : Begin' , 1, 'N' );
     aso_debug_pub.add('CREATE_TEMPLATE : p_template_context :'||P_TEMPLATE_REC.TEMPLATE_CONTEXT, 1, 'N');
     aso_debug_pub.add('CREATE_TEMPLATE : p_template_level :'||P_TEMPLATE_REC.TEMPLATE_LEVEL, 1, 'N');
      END IF;

l_return_status :=
               Validate_Template(
                   p_template_context =>P_TEMPLATE_REC.TEMPLATE_CONTEXT,
                   p_template_level => P_TEMPLATE_REC.TEMPLATE_LEVEL);

          IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             x_return_status            := l_return_status;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

 ASO_SUP_TEMPLATE_PKG.INSERT_ROW (
  PX_ROWID => row_id,
  PX_TEMPLATE_ID             => L_TEMPLATE_ID,
  P_CREATION_DATE            => P_TEMPLATE_REC.CREATION_DATE ,
  P_CREATED_BY               => P_TEMPLATE_REC.CREATED_BY ,
  P_LAST_UPDATE_DATE         => P_TEMPLATE_REC.LAST_UPDATE_DATE ,
  P_LAST_UPDATED_BY          => P_TEMPLATE_REC.LAST_UPDATED_BY ,
  P_LAST_UPDATE_LOGIN        => P_TEMPLATE_REC.LAST_UPDATE_LOGIN ,
  P_TEMPLATE_NAME            => P_TEMPLATE_REC.TEMPLATE_NAME,
  P_DESCRIPTION              => P_TEMPLATE_REC.DESCRIPTION,
  P_TEMPLATE_LEVEL           => P_TEMPLATE_REC.TEMPLATE_LEVEL,
  P_TEMPLATE_CONTEXT         => P_TEMPLATE_REC.TEMPLATE_CONTEXT,
  p_context                  => P_TEMPLATE_REC.context,
  P_ATTRIBUTE1               => P_TEMPLATE_REC.ATTRIBUTE1,
  P_ATTRIBUTE2               => P_TEMPLATE_REC.ATTRIBUTE2,
  P_ATTRIBUTE3               => P_TEMPLATE_REC.ATTRIBUTE3,
  P_ATTRIBUTE4               => P_TEMPLATE_REC.ATTRIBUTE4,
  P_ATTRIBUTE5               => P_TEMPLATE_REC.ATTRIBUTE5,
  P_ATTRIBUTE6               => P_TEMPLATE_REC.ATTRIBUTE6,
  P_ATTRIBUTE7               => P_TEMPLATE_REC.ATTRIBUTE7,
  P_ATTRIBUTE8               => P_TEMPLATE_REC.ATTRIBUTE8,
  P_ATTRIBUTE9               => P_TEMPLATE_REC.ATTRIBUTE9,
  P_ATTRIBUTE10              => P_TEMPLATE_REC.ATTRIBUTE10,
  P_ATTRIBUTE11              => P_TEMPLATE_REC.ATTRIBUTE11,
  P_ATTRIBUTE12              => P_TEMPLATE_REC.ATTRIBUTE12,
  P_ATTRIBUTE13              => P_TEMPLATE_REC.ATTRIBUTE13,
  P_ATTRIBUTE14              => P_TEMPLATE_REC.ATTRIBUTE14,
  P_ATTRIBUTE15              => P_TEMPLATE_REC.ATTRIBUTE15,
  P_ATTRIBUTE16              => P_TEMPLATE_REC.ATTRIBUTE16,
  P_ATTRIBUTE17              => P_TEMPLATE_REC.ATTRIBUTE17,
  P_ATTRIBUTE18              => P_TEMPLATE_REC.ATTRIBUTE18,
  P_ATTRIBUTE19              => P_TEMPLATE_REC.ATTRIBUTE19,
  P_ATTRIBUTE20              => P_TEMPLATE_REC.ATTRIBUTE20
  );

	  X_Template_id := l_template_id;


      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ( 'CREATE_TEMPLATE:  end' , 1 , 'N' );
      END IF;

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );
   WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );


END CREATE_TEMPLATE;


PROCEDURE Update_Template
(
 P_Api_Version_Number          IN         NUMBER,
 P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
 P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
 P_TEMPLATE_REC     IN          ASO_SUP_TEMPLATE_DATA_PVT.TEMPLATE_REC_TYPE,
 X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
 X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 )

IS

l_api_name                    VARCHAR2 ( 150 ) := 'UPDATE_TEMPLATE';
l_api_version_number CONSTANT NUMBER := 1.0;
row_id                        varchar2(64);
l_TEMPLATE_id                 NUMBER;
l_return_status               VARCHAR2(1);

-- Start : code change done for Bug 20470801
  Cursor C_Template_level(P_TEMPLATE_ID VARCHAR2) Is
  Select Template_level
  From aso_sup_template_vl
  Where template_id = P_TEMPLATE_ID;

  l_Template_level varchar2(100);
  -- End : code change done for Bug 20470801

BEGIN
-- Establish a standard save point
      SAVEPOINT UPDATE_TEMPLATE_PVT;

-- Standard call to check for call compatability
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;


--  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      -- Start : code change done for Bug 20470801
      If P_TEMPLATE_REC.TEMPLATE_LEVEL Is Null Then
         Open C_Template_level(P_TEMPLATE_REC.TEMPLATE_ID);
         Fetch C_Template_level Into l_Template_level;
         Close C_Template_level;
      Else
         l_Template_level := P_TEMPLATE_REC.TEMPLATE_LEVEL;
      End If;
      -- End : code change done for Bug 20470801

-- API BODY
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ('UPDATE_TEMPLATE : Begin' , 1, 'N' );
     aso_debug_pub.add('UPDATE_TEMPLATE : p_template_context :'||P_TEMPLATE_REC.TEMPLATE_CONTEXT, 1, 'N');
     aso_debug_pub.add('UPDATE_TEMPLATE : p_template_level :'||l_Template_level, 1, 'N');
      END IF;

l_return_status :=
               Validate_Template(
                   p_template_context =>P_TEMPLATE_REC.TEMPLATE_CONTEXT,
                --   p_template_level => P_TEMPLATE_REC.TEMPLATE_LEVEL);
		   p_template_level => l_Template_level);  -- code change done for Bug 20470801

          IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             x_return_status            := l_return_status;
             RAISE FND_API.G_EXC_ERROR;
          END IF;


ASO_SUP_TEMPLATE_PKG.UPDATE_ROW (
  P_TEMPLATE_ID              => P_TEMPLATE_REC.TEMPLATE_ID,
  P_LAST_UPDATE_DATE         => P_TEMPLATE_REC.LAST_UPDATE_DATE ,
  P_LAST_UPDATED_BY          => P_TEMPLATE_REC.LAST_UPDATED_BY ,
  P_LAST_UPDATE_LOGIN        => P_TEMPLATE_REC.LAST_UPDATE_LOGIN ,
  P_TEMPLATE_NAME            => P_TEMPLATE_REC.TEMPLATE_NAME,
  P_DESCRIPTION              => P_TEMPLATE_REC.DESCRIPTION,
--  P_TEMPLATE_LEVEL           => P_TEMPLATE_REC.TEMPLATE_LEVEL,
  P_TEMPLATE_LEVEL           => l_Template_level,                -- code change done for Bug 20470801
  P_TEMPLATE_CONTEXT         => P_TEMPLATE_REC.TEMPLATE_CONTEXT,
  p_context                  => P_TEMPLATE_REC.context,
  P_ATTRIBUTE1               => P_TEMPLATE_REC.ATTRIBUTE1,
  P_ATTRIBUTE2               => P_TEMPLATE_REC.ATTRIBUTE2,
  P_ATTRIBUTE3               => P_TEMPLATE_REC.ATTRIBUTE3,
  P_ATTRIBUTE4               => P_TEMPLATE_REC.ATTRIBUTE4,
  P_ATTRIBUTE5               => P_TEMPLATE_REC.ATTRIBUTE5,
  P_ATTRIBUTE6               => P_TEMPLATE_REC.ATTRIBUTE6,
  P_ATTRIBUTE7               => P_TEMPLATE_REC.ATTRIBUTE7,
  P_ATTRIBUTE8               => P_TEMPLATE_REC.ATTRIBUTE8,
  P_ATTRIBUTE9               => P_TEMPLATE_REC.ATTRIBUTE9,
  P_ATTRIBUTE10              => P_TEMPLATE_REC.ATTRIBUTE10,
  P_ATTRIBUTE11              => P_TEMPLATE_REC.ATTRIBUTE11,
  P_ATTRIBUTE12              => P_TEMPLATE_REC.ATTRIBUTE12,
  P_ATTRIBUTE13              => P_TEMPLATE_REC.ATTRIBUTE13,
  P_ATTRIBUTE14              => P_TEMPLATE_REC.ATTRIBUTE14,
  P_ATTRIBUTE15              => P_TEMPLATE_REC.ATTRIBUTE15,
  P_ATTRIBUTE16              => P_TEMPLATE_REC.ATTRIBUTE16,
  P_ATTRIBUTE17              => P_TEMPLATE_REC.ATTRIBUTE17,
  P_ATTRIBUTE18              => P_TEMPLATE_REC.ATTRIBUTE18,
  P_ATTRIBUTE19              => P_TEMPLATE_REC.ATTRIBUTE19,
  P_ATTRIBUTE20              => P_TEMPLATE_REC.ATTRIBUTE20
  );


      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ( 'UPDATE_TEMPLATE:  end' , 1 , 'N' );
      END IF;

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );
   WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );
END Update_Template;
End ASO_SUP_TEMPLATE_DATA_PVT;

/
