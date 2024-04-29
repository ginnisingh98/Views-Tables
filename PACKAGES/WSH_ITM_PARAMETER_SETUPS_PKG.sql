--------------------------------------------------------
--  DDL for Package WSH_ITM_PARAMETER_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_PARAMETER_SETUPS_PKG" AUTHID CURRENT_USER as
 /* $Header: WSHITTHS.pls 120.0.12010000.1 2008/07/29 06:15:41 appldev ship $ */

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*--------------------------------------------------------_-*/
 /*  --
   -- Purpose
   --  Insert a row into WSH_ITM_PARAMETER_SETUPS_B entity.
   --  Insert a row into WSH_ITM_PARAMETER_SETUPS_TL entity.
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
   -- Input parameters
   -- P_PARAMETER_NAME		Internal Name for the Parameter.
   -- P_VALUE 			Parameter value.
   -- P_DEFAULT_VALUE		Parameter Default Value.
   -- P_USER_SETTABLE		User can Override.
   -- P_USER_PARAMETER_NAME     Parameter name identified by the user.
   -- P_DESCRIPTION 		Brief Description of the Parameter.
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


procedure INSERT_ROW (
   p_api_version        	IN    NUMBER                       	,
   p_init_msg_list      	IN    VARCHAR2 := fnd_api.g_false  	,
   p_commit             	IN    VARCHAR2 := fnd_api.g_false  	,
   x_return_status      	OUT NOCOPY    VARCHAR2                     	,
   x_msg_count          	OUT NOCOPY    NUMBER                       	,
   x_msg_data           	OUT NOCOPY    VARCHAR2                     	,
   P_PARAMETER_ID       	OUT NOCOPY      NUMBER				,
   P_PARAMETER_NAME 		IN 	VARCHAR2			,
   P_VALUE 			IN 	VARCHAR2			,
   P_DEFAULT_VALUE 		IN 	VARCHAR2			,
   P_USER_SETTABLE 		IN 	VARCHAR2			,
   P_USER_PARAMETER_NAME 	IN 	VARCHAR2			,
   P_DESCRIPTION 		IN 	VARCHAR2
);

 /*----------------------------------------------------------*/
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Check Lock a row of WSH_ITM_PARAMETER_SETUPS_B entity.
   --  Check Lock a row of WSH_ITM_PARAMETER_SETUPS_TL entity.
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
   -- Input parameters
   --
   -- P_PARAMETER_ID            Parameter ID
   -- P_PARAMETER_NAME		Internal Name for the Parameter.
   -- P_VALUE 			Parameter value.
   -- P_DEFAULT_VALUE		Parameter Default Value.
   -- P_USER_SETTABLE		User can Override.
   -- P_USER_PARAMETER_NAME     Parameter name identified by the user.
   -- P_DESCRIPTION 		Brief Description of the Parameter.
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
procedure LOCK_ROW (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
  P_PARAMETER_ID 	IN	 NUMBER,
  P_PARAMETER_NAME 	IN 	 VARCHAR2,
  P_VALUE 		IN	 VARCHAR2,
  P_DEFAULT_VALUE 	IN	 VARCHAR2,
  P_USER_SETTABLE 	IN 	 VARCHAR2,
  P_USER_PARAMETER_NAME IN	 VARCHAR2,
  P_DESCRIPTION 	IN 	 VARCHAR2
);

  /*----------------------------------------------------------*/
   /* Update_Row Procedure                                     */
    /*--------------------------------------------------------_-*/
	/*  --
   -- Purpose
   --  Update a row into WSH_ITM_parameter_setups_b entity
   --  Update a row into WSH_ITM_parameter_setups_tl entity
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
   -- Input parameters
   -- P_PARAMETER_ID            Parameter ID.
   -- P_PARAMETER_NAME		Internal Name for the Parameter.
   -- P_VALUE 			Parameter value.
   -- P_DEFAULT_VALUE		Parameter Default Value.
   -- P_USER_SETTABLE		User can Override.
   -- P_USER_PARAMETER_NAME     Parameter name identified by the user.
   -- P_DESCRIPTION 		Brief Description of the Parameter.
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



procedure UPDATE_ROW (
   p_api_version        	IN     NUMBER                     ,
   p_init_msg_list      	IN     VARCHAR2 := fnd_api.g_false,
   p_commit             	IN     VARCHAR2 := fnd_api.g_false,
   x_return_status      	OUT NOCOPY     VARCHAR2                   ,
   x_msg_count          	OUT NOCOPY     NUMBER                     ,
   x_msg_data           	OUT NOCOPY     VARCHAR2                   ,
  P_PARAMETER_ID 		IN 	NUMBER			,
  P_PARAMETER_NAME 		IN 	VARCHAR2			,
  P_VALUE 			IN 	VARCHAR2			,
  P_DEFAULT_VALUE 		IN 	VARCHAR2			,
  P_USER_SETTABLE 		IN 	VARCHAR2			,
  P_USER_PARAMETER_NAME 	IN 	VARCHAR2			,
  P_DESCRIPTION 		IN 	VARCHAR2
);

  /*----------------------------------------------------------*/
   /* Delete_Row Procedure                                     */
    /*--------------------------------------------------------_-*/
/*  --
   -- Purpose
   --  Delete a row from WSH_ITM_parameter_setups_b entity
   --  Delete a row from WSH_ITM_parameter_setups_tl entity
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

procedure DELETE_ROW (
   p_api_version        	IN      NUMBER                          ,
   p_init_msg_list     		IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             	IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      	OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          	OUT NOCOPY      NUMBER                          ,
   x_msg_data           	OUT NOCOPY      VARCHAR2                        ,
   P_PARAMETER_ID 		IN 	  NUMBER
);

  /*----------------------------------------------------------*/
   /* Add_Language Procedure                                     */
    /*--------------------------------------------------------_-*/
procedure ADD_LANGUAGE;

  /*----------------------------------------------------------*/
   /* Translate_Row Procedure                                     */
    /*--------------------------------------------------------_-*/
PROCEDURE translate_row
  (
   x_parameter_id             IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_user_parameter_name      IN  VARCHAR2 ,
   x_description              IN  VARCHAR2);

  /*----------------------------------------------------------*/
   /* Load_Row Procedure                                     */
    /*--------------------------------------------------------_-*/
PROCEDURE load_row
  (
   x_parameter_id             IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_parameter_name           IN  VARCHAR2 ,
   x_user_parameter_name      IN  VARCHAR2 ,
   x_value		      IN  VARCHAR2 ,
   x_user_settable            IN  VARCHAR2 ,
   x_default_value            IN  VARCHAR2 ,
   x_description              IN  VARCHAR2);

end WSH_ITM_PARAMETER_SETUPS_PKG;

/
