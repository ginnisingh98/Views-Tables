--------------------------------------------------------
--  DDL for Package WSH_ITM_USERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_USERS_PKG" AUTHID CURRENT_USER AS
   /* $Header: WSHITUTS.pls 115.3 2002/12/12 12:07:35 bradha ship $ */

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*--------------------------------------------------------_-*/
 /*  --
   -- Purpose
   --  Insert a row into WSH_ITM_USERS entity
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
   --     p_APPLICATION_ID --Application ID added
   --     p_MASTER_ORGANIZATION_ID   - Master Org
   --     p_ORGANIZATION_ID   - Org
   --     p_APPLICATION_USER_ID  - Application User
   --     p_USER_ID - User
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

   --*/

PROCEDURE Insert_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID               IN  NUMBER,
   p_APPLICATION_ID          IN  NUMBER,
   p_MASTER_ORGANIZATION_ID  IN  NUMBER,
   p_ORGANIZATION_ID         IN  NUMBER default null,
   p_APPLICATION_USER_ID     IN  NUMBER default null,
   p_USER_ID              IN  VARCHAR2,
   p_ENCRYPTED_USER_PASSWORD IN  VARCHAR2,
   p_ITM_USER_SEQUENCE_ID    OUT NOCOPY   NUMBER
  );

/*----------------------------------------------------------*/
 /* Update_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Update a row into WS_ITM_USERS entity for the given cc seq id
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
   --     p_VENDOR_ID
   --     p_APPLICATION_ID --Application added
   --     p_MASTER_ORGANIZATION_ID   -- Master Org
   --     p_ORGANIZATION_ID   --Org
   --     p_APPLICATION_USER_ID  -- Application User
   --     p_USER_ID -- User
   --     p_ENCRYPTED_USER_PASSWORD -- Password
   --     p_ITM_USER_SEQUENCE_ID  -- Seq Id
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
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID               IN  NUMBER,
   p_APPLICATION_ID          IN  NUMBER,
   p_MASTER_ORGANIZATION_ID  IN  NUMBER,
   p_ORGANIZATION_ID         IN  NUMBER ,
   p_APPLICATION_USER_ID     IN  NUMBER ,
   p_USER_ID              IN  VARCHAR2,
   p_ENCRYPTED_USER_PASSWORD IN  VARCHAR2,
   p_ITM_USER_SEQUENCE_ID     IN  NUMBER
  );

 /*----------------------------------------------------------*/
 /* Delete_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Delete a row from WSH_ITM_USERS entity for the given cc seq id
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
   --     p_ITM_USER_SEQUENCE_ID  -- ITM Seq Id
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
   p_ITM_USER_SEQUENCE_ID     IN  NUMBER
  );

/*----------------------------------------------------------*/
 /*----------------------------------------------------------*/
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Lock a row into WSH_ITM_USERS entity for the given cc seq id
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
   --     p_MASTER_ORGANIZATION_ID   -- Master Org
   --     p_APPLICATION_ID --Application_id added.
   --     p_ORGANIZATION_ID   --Org
   --     p_APPLICATION_USER_ID  -- Application User
   --     p_ITM_USER_ID --  ITM User ID
   --     p_ENCRYPTED_USER_PASSWORD -- Password
   --     p_ITM_SEQUENCE_ID  -- ITM Seq Id
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
   p_APPLICATION_ID          IN  NUMBER,
   p_MASTER_ORGANIZATION_ID  IN  NUMBER,
   p_ORGANIZATION_ID         IN  NUMBER ,
   p_APPLICATION_USER_ID     IN  NUMBER ,
   p_USER_ID              IN  VARCHAR2,
   p_ENCRYPTED_USER_PASSWORD IN  VARCHAR2,
   p_ITM_USER_SEQUENCE_ID     IN  NUMBER,
   p_rowid                   IN VARCHAR2
  );

END WSH_ITM_USERS_PKG;

 

/
