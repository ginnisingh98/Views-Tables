--------------------------------------------------------
--  DDL for Package Body JTF_HOOK_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_HOOK_DATA_PUB" AS
/* $Header: jtfpihdb.pls 115.6 2000/11/21 09:31:49 pkm ship        $ */

G_PKG_NAME  	CONSTANT VARCHAR2(30):='JTF_HOOK_DATA_PUB';
G_FILE_NAME   	CONSTANT VARCHAR2(12):='jtfpihdb.pls';

G_LOGIN_ID	NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID	NUMBER := FND_GLOBAL.USER_ID;

PROCEDURE JTF_HOOK_DATA_PUB_INSERT (
  p_api_version_number	IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 	:= FND_API.G_FALSE,
  p_commit		IN      VARCHAR		:= FND_API.G_FALSE,

  p_hook_data		IN 	HOOK_DATA_REC_TYPE,

  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2
)
AS
	--******** local variable for standards **********
     	l_api_name		CONSTANT VARCHAR2(30)	:= 'JTF_HOOK_DATA_PUB_INSERT';
	l_api_version_number	NUMBER 	:= p_api_version_number;
	l_return_status 	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
	l_commit		VARCHAR2(1)	:= FND_API.G_FALSE;
	l_object_version_number NUMBER :=NULL;

        l_hook_id		NUMBER :=NULL;
        l_exe_order             NUMBER :=NULL;
	CURSOR C IS SELECT JTF_USER_HOOKS_S.NEXTVAL FROM sys.dual;

BEGIN
      -- ******* Standard Begins ********

      -- Standard Start of API savepoint
      SAVEPOINT	JTF_HOOK_DATA_PUB_INSERT;

--       -- Standard call to check for call compatibility.
--       IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME)
--       THEN
--           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--       END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

--*********************

   -- Check for the constraint of the logical primary key
   SELECT count(*) into l_hook_id
   FROM JTF_HOOKS_DATA
   WHERE product_code = p_hook_data.p_ProductCode
   AND package_name   = p_hook_data.p_PackageName
   AND api_name       = p_hook_data.p_ApiName
   AND HOOK_TYPE      = p_hook_data.p_HookType
   AND HOOK_PACKAGE   = p_hook_data.p_HookPackage
   AND HOOK_API       = p_hook_data.p_HookApi;

   IF (l_hook_id > 0) THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Use Sequence as the unique key
   OPEN C;
   FETCH C INTO l_hook_id;
   CLOSE C;
   l_exe_order := p_hook_data.p_ExecutionOrder;
   If (p_hook_data.p_ExecutionOrder IS NULL) OR (p_hook_data.p_ExecutionOrder = FND_API.G_MISS_NUM) then
	l_exe_order := l_hook_id;
   End If;

   INSERT INTO JTF_HOOKS_DATA (	HOOK_ID,
				PRODUCT_CODE,
				PACKAGE_NAME,
				API_NAME,
				EXECUTE_FLAG,
				PROCESSING_TYPE,
				HOOK_TYPE,
				HOOK_PACKAGE,
				HOOK_API,
				EXECUTION_ORDER,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN )

			      VALUES (  l_hook_id,
					p_hook_data.p_ProductCode,
					p_hook_data.p_PackageName,
					p_hook_data.p_ApiName,
                                        p_hook_data.p_ExecuteFlag,
					p_hook_data.p_ProcessingType,
					p_hook_data.p_HookType,
					p_hook_data.p_HookPackage,
                                        p_hook_data.p_HookApi,
					l_exe_order,
					G_USER_ID, SYSDATE, G_USER_ID, SYSDATE, G_LOGIN_ID );


--*********************

-- ******** Standard Ends ***********
--
-- End of main API body.

   -- Standard check of p_commit.
   IF (FND_API.To_Boolean(p_commit)) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get( p_count       	=>      x_msg_count,
				p_data        	=>      x_msg_data );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	  ROLLBACK TO JTF_HOOK_DATA_PUB_INSERT;
	  x_return_status := FND_API.G_RET_STS_ERROR ;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	  ROLLBACK TO JTF_HOOK_DATA_PUB_INSERT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );


    WHEN OTHERS THEN

	  ROLLBACK TO JTF_HOOK_DATA_PUB_INSERT;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	  THEN
    	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    	END IF;

	  FND_MSG_PUB.Count_And_Get
	( p_count    	=>      x_msg_count,
	  p_data       	=>      x_msg_data );

END JTF_HOOK_DATA_PUB_INSERT;

END JTF_HOOK_DATA_PUB;

/
