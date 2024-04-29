--------------------------------------------------------
--  DDL for Package Body WSH_CC_USERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CC_USERS_PKG" AS
   /* $Header: WSHUSTHB.pls 115.3 2002/06/03 12:32:33 pkm ship        $ */
  --  Global constant holding the package name
  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'WSH_CC_USERS_PKG';

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Insert a row into WSH_CC_USERS entity
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --           whether or not to commit the changes to database
   --
   -- Input parameters for clear cross users informations
   --     p_APPLICATION_ID --Application ID added.
   --     p_MASTER_ORGANIZATION_ID   - Master Org
   --     p_ORGANIZATION_ID   - Org
   --     p_APPLICATION_USER_ID  - Application User
   --     p_CC_USER_ID - Clear Cross User
   --     p_ENCRYPTED_USER_PASSWORD - Password
   --
   -- Output Parameters
   --   x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)
   --   p_CC_USER_SEQUENCE_ID  - Clear Cross sequence Id ( PK)
   --*/

 PROCEDURE Insert_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT     VARCHAR2                        ,
   x_msg_count          OUT     NUMBER                          ,
   x_msg_data           OUT     VARCHAR2                        ,
   p_APPLICATION_ID          IN  NUMBER,
   p_MASTER_ORGANIZATION_ID  IN  NUMBER,
   p_ORGANIZATION_ID         IN  NUMBER default null,
   p_APPLICATION_USER_ID     IN  NUMBER default null,
   p_CC_USER_ID              IN  VARCHAR2,
   p_ENCRYPTED_USER_PASSWORD IN  VARCHAR2,
   p_CC_USER_SEQUENCE_ID    OUT  NUMBER
  )
IS
   l_CC_USER_SEQUENCE_ID NUMBER ;
   l_api_name        CONSTANT VARCHAR2(30)      := 'Insert_Row';
   l_api_version     number := 1.0;
begin
--dbms_output.put_line('begin api');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_USERS_PKG;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version   ,
                                       p_api_version   ,
							    l_api_name      ,
							    G_PKG_NAME )
  THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INCOMPATIBLE_API_CALL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --dbms_output.put_line('begin api-2');

  select wsh_cc_user_setups_s.nextval into l_CC_USER_SEQUENCE_ID from dual;
  /* Validate input parameters if any */

  -- Insert a row into wsh_cc_users entity with all detail information
    insert into wsh_cc_user_setups
    ( CC_USER_SEQUENCE_ID
     ,APPLICATION_ID
     ,MASTER_ORGANIZATION_ID
     ,ORGANIZATION_ID
     ,APPLICATION_USER_ID
     ,CC_USER_ID
     ,ENCRYPTED_USER_PASSWORD
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     )
    values (
     l_CC_USER_SEQUENCE_ID
    ,p_APPLICATION_ID
    ,p_MASTER_ORGANIZATION_ID
    ,p_ORGANIZATION_ID
    ,p_APPLICATION_USER_ID
    ,p_CC_USER_ID
    ,p_ENCRYPTED_USER_PASSWORD
    ,sysdate
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.user_id
    ,FND_GLOBAL.login_id
    ) ;
  IF SQL%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INSERT_FAILED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;
--dbms_output.put_line('Seq Id got it '||l_CC_USER_SEQUENCE_ID||'success');
  x_return_status := fnd_api.g_ret_sts_success;
  p_CC_USER_SEQUENCE_ID := l_CC_USER_SEQUENCE_ID;
  -- End of API body
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count         =>      x_msg_count,
     p_data          =>      x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO WSH_CC_USERS_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO WSH_CC_USERS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
     ROLLBACK TO WSH_CC_USERS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF   FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (    G_PKG_NAME      ,
	       l_api_name
        );
	END IF;
	FND_MSG_PUB.Count_And_Get
	(       p_count         =>      x_msg_count,
	        p_data          =>      x_msg_data
 	 );
End Insert_Row;
 /*----------------------------------------------------------*/
 /* Update_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Update a row into WSH_CC_USERS entity for the given cc seq id
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --           whether or not to commit the changes to database
   --
   -- Input parameters for clear cross users informations
   --     p_APPLICATION_ID --Application added
   --     p_MASTER_ORGANIZATION_ID   -- Master Org
   --     p_ORGANIZATION_ID   --Org
   --     p_APPLICATION_USER_ID  -- Application User
   --     p_CC_USER_ID -- Clear Cross User
   --     p_ENCRYPTED_USER_PASSWORD -- Password
   --     p_CC_USER_SEQUENCE_ID  -- CC Seq Id
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

   --*/
 PROCEDURE Update_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT     VARCHAR2                        ,
   x_msg_count          OUT     NUMBER                          ,
   x_msg_data           OUT     VARCHAR2                        ,
   p_APPLICATION_ID          IN  NUMBER,
   p_MASTER_ORGANIZATION_ID  IN  NUMBER,
   p_ORGANIZATION_ID         IN  NUMBER default fnd_api.g_miss_num,
   p_APPLICATION_USER_ID     IN  NUMBER default fnd_api.g_miss_num,
   p_CC_USER_ID              IN  VARCHAR2,
   p_ENCRYPTED_USER_PASSWORD IN  VARCHAR2,
   p_CC_USER_SEQUENCE_ID     IN  NUMBER
  )
IS
   l_api_name        CONSTANT VARCHAR2(30) := 'Update_Row'  ;
   l_api_version     number := 1.0;
BEGIN
--dbms_output.put_line('begin');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_USERS_PKG;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version   ,
                                       p_api_version   ,
				       l_api_name      ,
				       G_PKG_NAME )
  THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INCOMPATIBLE_API_CALL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Update a row into wsh_cc_users entity with all detail information
  -- for the given cc seq id

 update wsh_cc_user_setups
 SET
  APPLICATION_ID           = p_APPLICATION_ID
 ,MASTER_ORGANIZATION_ID   = p_MASTER_ORGANIZATION_ID
 ,ORGANIZATION_ID         = decode(p_ORGANIZATION_ID,fnd_api.g_miss_num,
                            ORGANIZATION_ID,p_ORGANIZATION_ID)
 ,APPLICATION_USER_ID     = decode(p_APPLICATION_USER_ID,fnd_api.g_miss_num,
                            APPLICATION_USER_ID,p_APPLICATION_USER_ID)
 ,CC_USER_ID              = p_CC_USER_ID
 ,ENCRYPTED_USER_PASSWORD = p_ENCRYPTED_USER_PASSWORD
 ,LAST_UPDATE_DATE         = sysdate
 ,LAST_UPDATED_BY          = FND_GLOBAL.user_id
 ,LAST_UPDATE_LOGIN        = FND_GLOBAL.login_id
  where cc_user_sequence_id = p_cc_user_sequence_id ;
  IF SQL%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_FAILED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;
--dbms_output.put_line('begin-5');
  x_return_status := fnd_api.g_ret_sts_success;

  -- End of API body
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count         =>      x_msg_count,
     p_data          =>      x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_USERS_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_USERS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_USERS_PKG;
     x_return_status := 'W';
     IF   FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (    G_PKG_NAME      ,
	       l_api_name
        );
	END IF;
	FND_MSG_PUB.Count_And_Get
	(       p_count         =>      x_msg_count,
	        p_data          =>      x_msg_data
 	 );

End Update_Row;
 /*----------------------------------------------------------*/
 /* Delete_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Delete a row from WSH_CC_USERS entity for the given cc seq id
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --           whether or not to commit the changes to database
   --
   -- Input parameters for clear cross users informations
   --     p_CC_USER_SEQUENCE_ID  -- CC Seq Id
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

   --*/
 PROCEDURE Delete_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT     VARCHAR2                        ,
   x_msg_count          OUT     NUMBER                          ,
   x_msg_data           OUT     VARCHAR2                        ,
   p_CC_USER_SEQUENCE_ID     IN  NUMBER
  )
IS
   l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Row'  ;
   l_api_version     number := 1.0;
BEGIN
--dbms_output.put_line('begin');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_USERS_PKG;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version   ,
                                       p_api_version   ,
				       l_api_name      ,
				       G_PKG_NAME )
  THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INCOMPATIBLE_API_CALL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Delete a row from wsh_cc_users entity
  -- for the given cc seq id

 DELETE from wsh_cc_user_setups
 WHERE cc_user_sequence_id = p_cc_user_sequence_id ;
  IF SQL%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_DELETE_FAILED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;
--dbms_output.put_line('begin-5');
  x_return_status := fnd_api.g_ret_sts_success;

  -- End of API body
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count         =>      x_msg_count,
     p_data          =>      x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_USERS_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_USERS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_USERS_PKG;
     x_return_status := 'W';
     IF   FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (    G_PKG_NAME      ,
	       l_api_name
        );
	END IF;
	FND_MSG_PUB.Count_And_Get
	(       p_count         =>      x_msg_count,
	        p_data          =>      x_msg_data
 	 );

End Delete_Row;
 /*----------------------------------------------------------*/
 /*----------------------------------------------------------*/
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Lock a row into WSH_CC_USERS entity for the given cc seq id
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --           whether or not to commit the changes to database
   --
   -- Input parameters for clear cross users informations
   --     p_MASTER_ORGANIZATION_ID   -- Master Org
   --     p_APPLICATION_ID --Application_id added.
   --     p_ORGANIZATION_ID   --Org
   --     p_APPLICATION_USER_ID  -- Application User
   --     p_CC_USER_ID -- Clear Cross User
   --     p_ENCRYPTED_USER_PASSWORD -- Password
   --     p_CC_SEQUENCE_ID  -- CC Seq Id
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

   --*/
 PROCEDURE Lock_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT     VARCHAR2                        ,
   x_msg_count          OUT     NUMBER                          ,
   x_msg_data           OUT     VARCHAR2                        ,
   p_APPLICATION_ID          IN  NUMBER,
   p_MASTER_ORGANIZATION_ID  IN  NUMBER,
   p_ORGANIZATION_ID         IN  NUMBER default fnd_api.g_miss_num,
   p_APPLICATION_USER_ID     IN  NUMBER default fnd_api.g_miss_num,
   p_CC_USER_ID              IN  VARCHAR2,
   p_ENCRYPTED_USER_PASSWORD IN  VARCHAR2,
   p_CC_USER_SEQUENCE_ID     IN  NUMBER,
   p_rowid                   IN VARCHAR2
  )
IS
   CURSOR lock_row IS
   SELECT *
   FROM wsh_cc_user_setups
   WHERE rowid = p_rowid
   FOR UPDATE OF CC_USER_SEQUENCE_ID NOWAIT;

   Recinfo lock_row%ROWTYPE;

   l_api_name        CONSTANT VARCHAR2(30) := 'Lock_Row'  ;
   l_api_version     number := 1.0;
BEGIN
--dbms_output.put_line('begin');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_USERS_PKG;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version   ,
                                       p_api_version   ,
				       l_api_name      ,
				       G_PKG_NAME )
  THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INCOMPATIBLE_API_CALL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check Lock a row into wsh_cc_users entity with all detail information
  OPEN lock_row;
  FETCH lock_row into Recinfo;

  IF (lock_row%NOTFOUND) THEN
     CLOSE lock_row;
     FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
     app_exception.raise_exception;
  END IF;
  CLOSE lock_row;

  IF (
	     (Recinfo.CC_USER_SEQUENCE_ID = p_CC_USER_SEQUENCE_ID)
     AND ((Recinfo.master_organization_id =p_master_organization_id) OR
	    ( (Recinfo.master_organization_id is null)
		  AND (p_master_organization_id is null )))
     AND ((Recinfo.organization_id =p_organization_id) OR
	    ( (Recinfo.organization_id is null)
		  AND (p_organization_id is null )))
     AND ((Recinfo.cc_user_id =p_cc_user_id) OR
	    ( (Recinfo.cc_user_id is null)
		  AND (p_cc_user_id is null )))
     AND ((Recinfo.application_user_id =p_application_user_id) OR
	    ( (Recinfo.application_user_id is null)
		  AND (p_application_user_id is null )))
     AND ((Recinfo.encrypted_user_password =p_encrypted_user_password) OR
	    ( (Recinfo.encrypted_user_password is null)
		  AND (p_encrypted_user_password is null )))
     AND ((Recinfo.application_id =p_APPLICATION_ID) OR
            ( (Recinfo.application_id IS NULL)
                  AND (p_APPLICATION_ID IS NULL)))
     ) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
 EXCEPTION
 WHEN others THEN
     IF (lock_row%ISOPEN) then
         close lock_row;
	End if;
End Lock_Row;
END WSH_CC_USERS_PKG;

/