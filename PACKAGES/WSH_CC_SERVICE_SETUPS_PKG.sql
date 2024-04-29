--------------------------------------------------------
--  DDL for Package WSH_CC_SERVICE_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CC_SERVICE_SETUPS_PKG" AUTHID CURRENT_USER AS
   /* $Header: WSHSSTHS.pls 115.3 2002/06/03 12:32:06 pkm ship        $ */

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*--------------------------------------------------------_-*/
 /*  --
   -- Purpose
   --  Insert a row into WSH_CC_SERVICE_SETUPS_PKG entity
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
   -- Input parameters for clear cross service setup informations
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
   --   p_CC_SERVICE_SEQUENCE_ID  - Clear Cross Service sequence Id ( PK)

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
   p_SERVICE_TYPE_CODE       IN VARCHAR2,
   p_SERVICE_VERSION         IN VARCHAR2 default null,
   p_SERVICE_HANDLER         IN VARCHAR2,
   p_SERVICE_DEFAULT_THRESHOLD  IN NUMBER default null,
   p_COUNTRY_MATCH_FLAG      IN VARCHAR2 default null,
   p_RED_FLAG                IN VARCHAR2 default null,
   p_SHIP_FROM_COUNTRY_SCHEME  IN VARCHAR2 default null,
   p_SHIP_FROM_COUNTRY_DOMAIN  IN VARCHAR2 default null,
   p_SHIP_TO_COUNTRY_SCHEME    IN VARCHAR2 default null,
   p_SHIP_TO_COUNTRY_DOMAIN    IN VARCHAR2 default null,
   p_CHARGE_SCHEME             IN VARCHAR2 default null,
   p_CHARGE_DOMAIN             IN VARCHAR2 default null,
   p_SERVICE_PRIORITY          IN NUMBER   default null,
   p_WF_ITEM_TYPE              IN VARCHAR2 default null,
   p_WF_ACTIVITY               IN VARCHAR2 default null,
   p_CC_SERVICE_SEQUENCE_ID  OUT  NUMBER
   );
  /*----------------------------------------------------------*/
   /* Update_Row Procedure                                     */
    /*--------------------------------------------------------_-*/
	/*  --
	 -- Purpose
      --  Update a row into wsh_cc_service_setups entity
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
	 -- Input parameters for Clear Cross Service Setups Informations
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
   p_SERVICE_TYPE_CODE       IN VARCHAR2,
   p_SERVICE_VERSION         IN VARCHAR2 default null,
   p_SERVICE_HANDLER         IN VARCHAR2,
   p_SERVICE_DEFAULT_THRESHOLD  IN NUMBER,
   p_COUNTRY_MATCH_FLAG      IN VARCHAR2,
   p_RED_FLAG                IN VARCHAR2,
   p_SHIP_FROM_COUNTRY_SCHEME  IN VARCHAR2,
   p_SHIP_FROM_COUNTRY_DOMAIN  IN VARCHAR2,
   p_SHIP_TO_COUNTRY_SCHEME    IN VARCHAR2,
   p_SHIP_TO_COUNTRY_DOMAIN    IN VARCHAR2,
   p_CHARGE_SCHEME             IN VARCHAR2,
   p_CHARGE_DOMAIN             IN VARCHAR2,
   p_SERVICE_PRIORITY          IN NUMBER,
   p_WF_ITEM_TYPE              IN VARCHAR2,
   p_WF_ACTIVITY               IN VARCHAR2,
   p_CC_SERVICE_SEQUENCE_ID  IN  NUMBER
   ) ;
  /*----------------------------------------------------------*/
   /* Delete_Row Procedure                                     */
    /*--------------------------------------------------------_-*/
	/*  --
	 -- Purpose
      --  Delete a row from wsh_cc_users entity
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
	 -- Input parameters for Clear Cross Users Informations
         --     p_CC_SERVICE_SEQUENCE_ID  - Seq Id (PK)
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
   p_CC_SERVICE_SEQUENCE_ID     IN  NUMBER
  );
 /*----------------------------------------------------------*/
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Check Lock a row of WSH_CC_SERVICE_SETUPS entity for the given cc seq id
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
   -- Input parameters for clear cross service setups informations
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
   p_SERVICE_TYPE_CODE       IN VARCHAR2,
   p_SERVICE_VERSION         IN VARCHAR2 default null,
   p_SERVICE_HANDLER         IN VARCHAR2,
   p_SERVICE_DEFAULT_THRESHOLD  IN NUMBER,
   p_COUNTRY_MATCH_FLAG      IN VARCHAR2,
   p_RED_FLAG                IN VARCHAR2,
   p_SHIP_FROM_COUNTRY_SCHEME  IN VARCHAR2,
   p_SHIP_FROM_COUNTRY_DOMAIN  IN VARCHAR2,
   p_SHIP_TO_COUNTRY_SCHEME    IN VARCHAR2,
   p_SHIP_TO_COUNTRY_DOMAIN    IN VARCHAR2,
   p_CHARGE_SCHEME             IN VARCHAR2,
   P_CHARGE_DOMAIN             IN VARCHAR2,
   P_SERVICE_PRIORITY          IN NUMBER,
   P_WF_ITEM_TYPE              IN VARCHAR2,
   P_WF_ACTIVITY               IN VARCHAR2,
   p_CC_SERVICE_SEQUENCE_ID  IN  NUMBER,
   p_rowid                   IN VARCHAR2
  );
END WSH_CC_SERVICE_SETUPS_PKG;

 

/
