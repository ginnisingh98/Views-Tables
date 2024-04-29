--------------------------------------------------------
--  DDL for Package Body WSH_ITM_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_ERROR_PKG" AS
   /* $Header: WSHITERB.pls 115.3 2002/12/12 12:01:46 bradha ship $ */

  --  Global constant holding the package name
  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'WSH_ITM_ERROR_PKG';

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Insert a row into WSH_ITM_RESPONSE_RULES entity
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
   --     p_VENDOR_ID -- Vendor Id
   --     P_VENDOR   -- Service Provider
   --     P_ERROR_TYPE   -- Error Type
   --     P_ERROR_CODE  -- Error Code
   --     P_INTERPRETED_CODE  -- Interpreted Code
   --
   --*/

 PROCEDURE Insert_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID          IN      NUMBER,
   p_VENDOR             IN      VARCHAR2,
   p_ERROR_TYPE         IN      VARCHAR2,
   p_ERROR_CODE         IN      VARCHAR2,
   p_INTERPRETED_CODE         IN      VARCHAR2,
   X_ROWID              OUT NOCOPY     VARCHAR2
  )
IS
   l_api_name        CONSTANT VARCHAR2(30)      := 'Insert_Row';
   l_api_version     number := 1.0;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_ITM_ERROR_PKG;

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

    insert into wsh_itm_response_rules
     (VENDOR_ID,
      ERROR_TYPE,
      ERROR_CODE,
      INTERPRETED_VALUE_CODE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN
     )
    values (
     p_VENDOR_ID
    ,p_error_type
    ,p_error_code
    ,p_interpreted_code
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

  x_return_status := fnd_api.g_ret_sts_success;

     SELECT rowid
     INTO   x_rowid
     FROM   wsh_itm_response_rules
     WHERE  vendor_id = p_vendor_id
     AND    nvl(error_code,-99) = nvl(p_error_code,-99)
     AND    error_type = p_error_type
     AND    interpreted_value_code = p_interpreted_code;


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
        ROLLBACK TO WSH_ITM_ERROR_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (   p_count         =>      x_msg_count,
	   p_data          =>      x_msg_data
	   );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO WSH_ITM_ERROR_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
         (  p_count         =>      x_msg_count,
            p_data          =>      x_msg_data
         );
     WHEN OTHERS THEN
        ROLLBACK TO WSH_ITM_ERROR_PKG;
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
   --  Update a row into WSH_ITM_RESPONSE_RULES entity
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
   --     p_VENDOR_ID -- Vendor Id
   --     P_VENDOR   -- Service Provider
   --     P_ERROR_TYPE   -- Error Type
   --     P_ERROR_CODE  -- Error Code
   --     P_INTERPRETED_CODE  -- Interpreted Code
   --     P_ROWID
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
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID          IN      NUMBER,
   p_VENDOR             IN      VARCHAR2,
   p_ERROR_TYPE         IN      VARCHAR2,
   p_ERROR_CODE         IN      VARCHAR2,
   p_INTERPRETED_CODE   IN      VARCHAR2,
   p_ROWID              IN      VARCHAR2
  )
IS
   l_api_name        CONSTANT VARCHAR2(30) := 'Update_Row'  ;
   l_api_version     number := 1.0;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  WSH_ITM_ERROR_PKG;

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

  -- Update a row into wsh_itm_users entity with all detail information
  -- for the given cc seq id

   UPDATE WSH_ITM_RESPONSE_RULES
   SET
      VENDOR_ID                = P_VENDOR_ID
     ,ERROR_TYPE               = P_ERROR_TYPE
     ,ERROR_CODE               = P_ERROR_CODE
     ,INTERPRETED_VALUE_CODE   = P_INTERPRETED_CODE
     ,LAST_UPDATE_DATE         = sysdate
     ,LAST_UPDATED_BY          = FND_GLOBAL.user_id
     ,LAST_UPDATE_LOGIN        = FND_GLOBAL.login_id
   WHERE rowid = p_rowid;

      IF SQL%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_FAILED');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

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
     ROLLBACK TO WSH_ITM_ERROR_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO WSH_ITM_ERROR_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
     ROLLBACK TO WSH_ITM_ERROR_PKG;
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
   --  Delete a row from WSH_ITM_RESPONE_RULES entity
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
   --    p_rowid
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
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_rowid              IN      VARCHAR2
  )
IS
   l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Row'  ;
   l_api_version     number := 1.0;

   BEGIN

    -- Standard Start of API savepoint
      SAVEPOINT  WSH_ITM_ERROR_PKG;

    -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
                 ( l_api_version   ,
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


     DELETE FROM WSH_ITM_RESPONSE_RULES
     WHERE rowid = p_rowid;

        IF SQL%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_DELETE_FAILED');
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR ;
        END IF;

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
     ROLLBACK TO WSH_ITM_ERROR_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO WSH_ITM_ERROR_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );

   WHEN OTHERS THEN
     ROLLBACK TO WSH_ITM_ERROR_PKG;
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
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Lock a row into WSH_ITM_RESPONSE_RULES entity
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
   --     p_VENDOR_ID       --Vendor Id
   --     P_VENDOR   -- Service Provider
   --     P_ERROR_TYPE   -- Error Type
   --     P_ERROR_CODE  -- Error Code
   --     P_INTERPRETED_CODE  -- Interpreted Code
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
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID               IN  NUMBER,
   p_VENDOR             IN      VARCHAR2,
   p_ERROR_TYPE         IN      VARCHAR2,
   p_ERROR_CODE         IN      VARCHAR2,
   p_INTERPRETED_CODE   IN      VARCHAR2,
   p_ROWID              IN      VARCHAR2
  )
IS

   changed exception;
   others exception;
   CURSOR lock_row IS
   SELECT *
   FROM WSH_ITM_RESPONSE_RULES
   WHERE rowid = p_rowid
   FOR UPDATE OF  VENDOR_ID NOWAIT;

   Recinfo lock_row%ROWTYPE;

   l_api_name        CONSTANT VARCHAR2(30) := 'Lock_Row'  ;
   l_api_version     number := 1.0;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  WSH_ITM_ERROR_PKG;

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

      OPEN lock_row;
      FETCH lock_row into Recinfo;

         IF (lock_row%NOTFOUND) THEN
           CLOSE lock_row;
           Raise Others;
         END IF;

        IF ( (Recinfo.vendor_id = p_vendor_id)
          AND (Recinfo.error_type =p_error_type)
          AND ((Recinfo.error_code =p_error_code) OR
                ( (Recinfo.error_code is null)
		  AND (p_error_code is null )))
          AND (Recinfo.interpreted_value_code =p_interpreted_code)
           ) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
         x_return_status := FND_API.G_RET_STS_ERROR;
         Raise Changed;
      END IF;
      CLOSE lock_row;

 EXCEPTION
 WHEN Changed then
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
 WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
End Lock_Row;
END WSH_ITM_ERROR_PKG;

/
