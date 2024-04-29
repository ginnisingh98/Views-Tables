--------------------------------------------------------
--  DDL for Package Body WSH_CC_PARAMETER_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CC_PARAMETER_SETUPS_PKG" as
/* $Header: WSHCCTHB.pls 115.2 2002/06/03 12:30:23 pkm ship       $ */
  --  Global constant holding the package name
  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'WSH_CC_PARAMETER_SETUPS_PKG';

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Insert a row into WSH_CC_PARAMETER_SETUPS_B entity
   --  Insert a row into WSH_CC_PARAMETER_SETUPS_TL entity
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
   -- Input parameters for clear cross parameter setups information
   -- P_PARAMETER_ID 		Unique sequence generated parameter ID
   -- P_PARAMETER_NAME 		Parameter Name (Internally identified)
   -- P_VALUE 			User Defined Value for the Parameter.
   -- P_DEFAULT_VALUE 		System defined Seeded Value for the Parameter.
   -- P_USER_SETTABLE 		User can Override the default.
   -- P_USER_PARAMETER_NAME 	User Parameter name
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
   --   p_PARAMETER_ID  - Clear Cross Parameter Id ( PK)
   --*/


procedure INSERT_ROW (
   p_api_version        	IN    NUMBER                       	,
   p_init_msg_list      	IN    VARCHAR2 := fnd_api.g_false  	,
   p_commit             	IN    VARCHAR2 := fnd_api.g_false  	,
   x_return_status      	OUT   VARCHAR2                     	,
   x_msg_count          	OUT   NUMBER                       	,
   x_msg_data           	OUT   VARCHAR2                     	,
   P_PARAMETER_ID       	OUT 	NUMBER				,
   P_PARAMETER_NAME 		IN 	VARCHAR2			,
   P_VALUE 			IN 	VARCHAR2			,
   P_DEFAULT_VALUE 		IN 	VARCHAR2			,
   P_USER_SETTABLE 		IN 	VARCHAR2			,
   P_USER_PARAMETER_NAME 	IN 	VARCHAR2			,
   P_DESCRIPTION 		IN 	VARCHAR2
) is

    	l_parameter_id 	NUMBER;
   	l_api_name        CONSTANT VARCHAR2(30)      := 'Insert_Row';
   	l_api_version     number := 1.0;

begin

--dbms_output.put_line('begin api');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_PARAMETER_SETUPS_PKG;
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

  SELECT WSH_CC_PARAMETER_SETUPS_S.NEXTVAL into l_parameter_id FROM dual;

  insert into WSH_CC_PARAMETER_SETUPS_B (
    PARAMETER_ID,
    PARAMETER_NAME,
    VALUE,
    DEFAULT_VALUE,
    USER_SETTABLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
values (
    l_PARAMETER_ID,
    P_PARAMETER_NAME,
    P_VALUE,
    P_DEFAULT_VALUE,
    P_USER_SETTABLE,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id
  );

  IF SQL%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INSERT_FAILED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;
--dbms_output.put_line('Seq Id got it '||l_parameter_ID||'success');
  x_return_status := fnd_api.g_ret_sts_success;
  p_parameter_id := l_parameter_id;
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


  insert into WSH_CC_PARAMETER_SETUPS_TL (
    PARAMETER_ID,
    USER_PARAMETER_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    l_PARAMETER_ID,
    P_USER_PARAMETER_NAME,
    P_DESCRIPTION,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WSH_CC_PARAMETER_SETUPS_TL T
    where T.PARAMETER_ID = l_PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  IF SQL%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INSERT_FAILED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;
--dbms_output.put_line('Seq Id got it '||l_parameter_ID||'success');
  x_return_status := fnd_api.g_ret_sts_success;
  p_parameter_id := l_parameter_id;
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
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
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

end INSERT_ROW;

 /*----------------------------------------------------------*/
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Check Lock a row of WSH_CC_PARAMETER_SETUPS entity
   --  for the given parameter id
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
   -- Input parameters for clear cross parameter setups information
   -- P_PARAMETER_ID 		Unique sequence generated parameter ID
   -- P_PARAMETER_NAME 		Parameter Name (Internally identified)
   -- P_VALUE 			User Defined Value for the Parameter.
   -- P_DEFAULT_VALUE 		System defined Seeded Value for the Parameter.
   -- P_USER_SETTABLE 		User can Override the default.
   -- P_USER_PARAMETER_NAME 	User Parameter name
   -- P_DESCRIPTION 		Brief Description of the Parameter.
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
  p_api_version         IN      NUMBER                      ,
  p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false ,
  p_commit              IN      VARCHAR2 := fnd_api.g_false ,
  x_return_status       OUT     VARCHAR2                    ,
  x_msg_count           OUT     NUMBER                      ,
  x_msg_data            OUT     VARCHAR2                    ,
  P_PARAMETER_ID    	IN      NUMBER			    ,
  P_PARAMETER_NAME 	IN      VARCHAR2		    ,
  P_VALUE 		IN      VARCHAR2		    ,
  P_DEFAULT_VALUE 	IN      VARCHAR2		    ,
  P_USER_SETTABLE 	IN      VARCHAR2		    ,
  P_USER_PARAMETER_NAME IN      VARCHAR2		    ,
  P_DESCRIPTION 	IN      VARCHAR2
) is

  cursor c is select
      PARAMETER_NAME,
      VALUE,
      DEFAULT_VALUE,
      USER_SETTABLE
    from WSH_CC_PARAMETER_SETUPS_B
    where PARAMETER_ID = P_PARAMETER_ID
    for update of PARAMETER_ID nowait;
  recinfo c%rowtype;

   l_api_name        CONSTANT VARCHAR2(30) := 'Lock_Row'  ;
   l_api_version     number := 1.0;


  cursor c1 is select
      USER_PARAMETER_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WSH_CC_PARAMETER_SETUPS_TL
    where PARAMETER_ID = P_PARAMETER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PARAMETER_ID nowait;

begin

--dbms_output.put_line('begin');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_PARAMETER_SETUPS_PKG;
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

  -- Check Lock a row of wsh_cc_parameter_setups

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PARAMETER_NAME = p_PARAMETER_NAME)
           OR ((recinfo.PARAMETER_NAME is null) AND (p_PARAMETER_NAME is null)))
      AND ((recinfo.VALUE = p_VALUE)
           OR ((recinfo.VALUE is null) AND (p_VALUE is null)))
      AND ((recinfo.DEFAULT_VALUE = p_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE is null) AND (p_DEFAULT_VALUE is null)))
      AND ((recinfo.USER_SETTABLE = p_USER_SETTABLE)
           OR ((recinfo.USER_SETTABLE is null) AND (p_USER_SETTABLE is null)))
  ) then
	x_return_status := FND_API.G_RET_STS_SUCCESS;
  else
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.USER_PARAMETER_NAME = p_USER_PARAMETER_NAME)
               OR ((tlinfo.USER_PARAMETER_NAME is null) AND (p_USER_PARAMETER_NAME is null)))
          AND ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_DESCRIPTION is null)))
      ) then
	x_return_status := FND_API.G_RET_STS_SUCCESS;
      else
    x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
 EXCEPTION
 WHEN others THEN
     IF (c%ISOPEN) then
         close c;
	End if;
     IF (c1%ISOPEN) then
         close c1;
	End if;
end LOCK_ROW;

 /*----------------------------------------------------------*/
 /* Update_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Update a row into WSH_CC_parameter_setups_b entity
   --  Update a row into WSH_CC_parameter_setups_tl entity
   --  for the given parameter id
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
   -- Input parameters for clear cross parameter setups informations
   -- P_PARAMETER_ID 		Unique sequence generated parameter ID
   -- P_PARAMETER_NAME 		Parameter Name (Internally identified)
   -- P_VALUE 			User Defined Value for the Parameter.
   -- P_DEFAULT_VALUE 		System defined Seeded Value for the Parameter.
   -- P_USER_SETTABLE 		User can Override the default.
   -- P_USER_PARAMETER_NAME 	User Parameter name
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
  p_api_version        IN      NUMBER                       ,
  p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false  ,
  p_commit             IN      VARCHAR2 := fnd_api.g_false  ,
  x_return_status      OUT     VARCHAR2                     ,
  x_msg_count          OUT     NUMBER                       ,
  x_msg_data           OUT     VARCHAR2                     ,
  P_PARAMETER_ID 	IN 	NUMBER			    ,
  P_PARAMETER_NAME 	IN 	VARCHAR2		    ,
  P_VALUE 		IN 	VARCHAR2		    ,
  P_DEFAULT_VALUE 	IN 	VARCHAR2		    ,
  P_USER_SETTABLE 	IN 	VARCHAR2		    ,
  P_USER_PARAMETER_NAME IN 	VARCHAR2		    ,
  P_DESCRIPTION 	IN 	VARCHAR2
) is

   l_api_name        CONSTANT VARCHAR2(30) := 'Update_Row'  ;
   l_api_version     number := 1.0;

begin

--dbms_output.put_line('begin');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_PARAMETER_SETUPS_PKG;
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

  -- Update a row into wsh_cc_parameter_setups entity with all detail information
  -- for the given parameter id

  update WSH_CC_PARAMETER_SETUPS_B set
    PARAMETER_NAME = P_PARAMETER_NAME,
    VALUE = P_VALUE,
    DEFAULT_VALUE = P_DEFAULT_VALUE,
    USER_SETTABLE = P_USER_SETTABLE,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = FND_GLOBAL.user_id,
    LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
  where PARAMETER_ID = P_PARAMETER_ID;

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

  update WSH_CC_PARAMETER_SETUPS_TL set
    USER_PARAMETER_NAME 	= P_USER_PARAMETER_NAME,
    DESCRIPTION 			= P_DESCRIPTION,
    SOURCE_LANG 			= userenv('LANG')
  where PARAMETER_ID = P_PARAMETER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

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
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
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

end UPDATE_ROW;

 /*----------------------------------------------------------*/
 /* Delete_Row Procedure                                     */
 /*----------------------------------------------------------*/
 /*  --
   -- Purpose
   --  Delete a row from WSH_CC_PARAMETER_SETUPS_B entity
   --  Delete a row from WSH_CC_PARAMETER_SETUPS_TL entity
   --  for the given  parameter id
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
   -- Input parameters for clear cross parameters informations
   --     p_PARAMETER_ID  -- parameter id
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
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT     VARCHAR2                        ,
   x_msg_count          OUT     NUMBER                          ,
   x_msg_data           OUT     VARCHAR2                        ,
   P_PARAMETER_ID 	IN      NUMBER
) is

   l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Row'  ;
   l_api_version     number := 1.0;

begin

--dbms_output.put_line('begin');
  -- Standard Start of API savepoint
  SAVEPOINT  WSH_CC_PARAMETER_SETUPS_PKG;
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

  -- Delete a row from wsh_cc_parameter_setups entity
  -- for the given parameter id


  delete from WSH_CC_PARAMETER_SETUPS_TL
  where PARAMETER_ID = P_PARAMETER_ID;

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

  delete from WSH_CC_PARAMETER_SETUPS_B
  where PARAMETER_ID = p_PARAMETER_ID;

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
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
       (       p_count         =>      x_msg_count,
	          p_data          =>      x_msg_data
	   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count,
	           p_data          =>      x_msg_data
        );
   WHEN OTHERS THEN
--dbms_output.put_line(sqlerrm);
     ROLLBACK TO WSH_CC_PARAMETER_SETUPS_PKG;
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

end DELETE_ROW;

 /*----------------------------------------------------------*/
 /* Add_Language Procedure                                     */
 /*----------------------------------------------------------*/
procedure ADD_LANGUAGE
is
begin
  delete from WSH_CC_PARAMETER_SETUPS_TL T
  where not exists
    (select NULL
    from WSH_CC_PARAMETER_SETUPS_B B
    where B.PARAMETER_ID = T.PARAMETER_ID
    );

  update WSH_CC_PARAMETER_SETUPS_TL T set (
      USER_PARAMETER_NAME,
      DESCRIPTION
    ) = (select
      B.USER_PARAMETER_NAME,
      B.DESCRIPTION
    from WSH_CC_PARAMETER_SETUPS_TL B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from WSH_CC_PARAMETER_SETUPS_TL SUBB, WSH_CC_PARAMETER_SETUPS_TL SUBT
    where SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_PARAMETER_NAME <> SUBT.USER_PARAMETER_NAME
      or (SUBB.USER_PARAMETER_NAME is null and SUBT.USER_PARAMETER_NAME is not null)
      or (SUBB.USER_PARAMETER_NAME is not null and SUBT.USER_PARAMETER_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WSH_CC_PARAMETER_SETUPS_TL (
    PARAMETER_ID,
    USER_PARAMETER_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PARAMETER_ID,
    B.USER_PARAMETER_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WSH_CC_PARAMETER_SETUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WSH_CC_PARAMETER_SETUPS_TL T
    where T.PARAMETER_ID = B.PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

 /*----------------------------------------------------------*/
 /* Translate_Row Procedure                                     */
 /*----------------------------------------------------------*/
PROCEDURE translate_row
  (
   x_parameter_id           		IN  VARCHAR2 ,
   x_owner                    	IN  VARCHAR2 ,
   x_user_parameter_name       	IN  VARCHAR2 ,
   x_description        		IN  VARCHAR2
   ) IS
BEGIN
   UPDATE wsh_cc_parameter_setups_tl SET
     user_parameter_name        = x_user_parameter_name,
     description 		= x_description,
     last_update_date  		= sysdate,
     last_updated_by   		= Decode(x_owner, 'SEED', 1, 0),
     last_update_login 		= 0,
     source_lang       		= userenv('LANG')
     WHERE parameter_id 	= fnd_number.canonical_to_number(x_parameter_id)
     AND userenv('LANG') IN (language, source_lang);
END translate_row;

 /*----------------------------------------------------------*/
 /* Load_Row Procedure                                     */
 /*----------------------------------------------------------*/
PROCEDURE load_row
  (
   x_parameter_id             IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_parameter_name           IN  VARCHAR2 ,
   x_user_parameter_name      IN  VARCHAR2 ,
   x_value		      IN  VARCHAR2 ,
   x_user_settable            IN  VARCHAR2 ,
   x_default_value            IN  VARCHAR2 ,
   x_description              IN  VARCHAR2
  ) IS

BEGIN
   DECLARE
      l_parameter_id           	 NUMBER;
      l_user_id                  NUMBER := 0;
      l_row_id                   VARCHAR2(64);
      l_sysdate                  DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
         l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_parameter_id  := fnd_number.canonical_to_number(x_parameter_id);


	  update WSH_CC_PARAMETER_SETUPS_B set
	    PARAMETER_NAME = x_PARAMETER_NAME,
	    VALUE = x_VALUE,
	    DEFAULT_VALUE = x_DEFAULT_VALUE,
	    USER_SETTABLE = x_USER_SETTABLE,
	    LAST_UPDATE_DATE = l_sysdate,
	    LAST_UPDATED_BY = l_user_id,
	    LAST_UPDATE_LOGIN = 0
	  where PARAMETER_ID = l_PARAMETER_ID;

	  update WSH_CC_PARAMETER_SETUPS_TL set
	    USER_PARAMETER_NAME 	= x_USER_PARAMETER_NAME,
	    DESCRIPTION 		= x_DESCRIPTION,
	    SOURCE_LANG 		= userenv('LANG')
	  where PARAMETER_ID  		= l_PARAMETER_ID
	  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

 IF SQL%NOTFOUND THEN

insert into WSH_CC_PARAMETER_SETUPS_B (
    PARAMETER_ID,
    PARAMETER_NAME,
    VALUE,
    DEFAULT_VALUE,
    USER_SETTABLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
values (
    l_PARAMETER_ID,
    x_PARAMETER_NAME,
    x_VALUE,
    x_DEFAULT_VALUE,
    x_USER_SETTABLE,
    l_sysdate,
    l_user_id,
    l_sysdate,
    l_user_id,
    0
  );

  insert into WSH_CC_PARAMETER_SETUPS_TL (
    PARAMETER_ID,
    USER_PARAMETER_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    l_PARAMETER_ID,
    x_USER_PARAMETER_NAME,
    x_DESCRIPTION,
    l_sysdate,
    l_user_id,
    l_sysdate,
    l_user_id,
    0,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WSH_CC_PARAMETER_SETUPS_TL T
    where T.PARAMETER_ID = l_PARAMETER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

END IF;
END;
commit;
END load_row;

end WSH_CC_PARAMETER_SETUPS_PKG;

/
