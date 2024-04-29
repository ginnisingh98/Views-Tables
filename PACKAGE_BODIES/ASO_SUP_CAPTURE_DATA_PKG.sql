--------------------------------------------------------
--  DDL for Package Body ASO_SUP_CAPTURE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SUP_CAPTURE_DATA_PKG" AS
/* $Header: asospdcb.pls 120.1 2005/06/29 16:05:03 appldev ship $ */

 G_PKG_NAME VARCHAR2(50):= 'ASO_SUP_CAPTURE_DATA_PKG';

PROCEDURE create_template_instance(
                  p_template_id IN NUMBER,
                  p_owner_table_name IN VARCHAR2,
                  p_owner_table_id IN NUMBER,
                  p_created_by IN NUMBER,
                  p_last_updated_by IN NUMBER,
                  p_last_update_login IN NUMBER,
                  p_commit  IN   VARCHAR2 := FND_API.G_FALSE,
			   x_template_instance_id OUT NOCOPY /* file.sql.39 change */  NUMBER,
                  X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                  X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
                  X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2) IS

l_template_instance_id NUMBER;
l_api_name varchar2(100) := 'create_temp_instance';

BEGIN

       SAVEPOINT create_temp_instance_int;

	--BEGIN
        SELECT aso_sup_tmpl_instance_s.NEXTVAL
        INTO l_template_instance_id
        FROM DUAL;

        x_template_instance_id := l_template_instance_id;

        INSERT INTO aso_sup_tmpl_instance
        (   TEMPLATE_INSTANCE_ID,
            TEMPLATE_ID,
            OWNER_TABLE_NAME,
            OWNER_TABLE_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            CREATION_DATE,
            CREATED_BY )
        VALUES
        (   l_template_instance_id,
            p_template_id,
            p_owner_table_name,
            p_owner_table_id,
            SYSDATE, p_last_updated_by, p_last_update_login, SYSDATE, p_created_by);

        --COMMIT;

    --EXCEPTION
        --WHEN OTHERS THEN
            --x_template_instance_id := 0;
    --END;

    IF fnd_api.to_boolean (p_commit) THEN
	 COMMIT WORK;
    END IF;

EXCEPTION

     WHEN OTHERS THEN
         x_template_instance_id := 0;
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);


END create_template_instance;

PROCEDURE update_data (
                  p_template_instance_id IN NUMBER,
                  p_sect_comp_map_id IN NUMBER,
                  p_created_by IN NUMBER,
                  p_last_updated_by IN NUMBER,
                  p_last_update_login IN NUMBER,
                  p_response_id IN NUMBER,
                  p_response_value IN VARCHAR2,
                  p_multiple_response_flag IN VARCHAR2,
                  p_commit  IN   VARCHAR2 := FND_API.G_FALSE,
                  X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                  X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
                  X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2) IS


l_exists VARCHAR2(2);
l_api_name varchar2(50):= 'update_data';
BEGIN

   SAVEPOINT update_data_int;

    BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM aso_sup_instance_value
        WHERE template_instance_id = p_template_instance_id
        AND sect_comp_map_id = p_sect_comp_map_id
        AND ROWNUM = 1 ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        l_exists := 'N';
    END;

    BEGIN
        IF ( p_multiple_response_flag = 'Y') THEN l_exists := 'N'; END IF;
        --IF ( p_multiple_response_flag = 'X') THEN l_exists := 'X'; END IF;
    END;
    IF (l_exists = 'Y') THEN
        BEGIN
            UPDATE aso_sup_instance_value
            SET created_by = p_created_by,
                last_updated_by = p_last_updated_by,
                last_update_login  = p_last_update_login,
                response_id  = p_response_id,
                value  = p_response_value
            WHERE template_instance_id = p_template_instance_id
            AND sect_comp_map_id = p_sect_comp_map_id;
        END;
    ELSE
        IF (l_exists = 'N') THEN
        BEGIN
            INSERT INTO aso_sup_instance_value
                (instance_value_id, template_instance_id,
                 sect_comp_map_id, created_by, last_updated_by,
                 last_update_login, response_id, value,
                 last_update_date, creation_date)
            VALUES
                (aso_sup_inst_value_s.nextval, p_template_instance_id,
                 p_sect_comp_map_id, p_created_by, p_last_updated_by,
                 p_last_update_login, p_response_id, p_response_value,
                 SYSDATE, SYSDATE);
        END;
        END IF;
    END IF;
    --COMMIT;
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

EXCEPTION

     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);


END update_data;


PROCEDURE delete_data (
                  p_template_instance_id IN NUMBER,
                  p_sect_comp_map_id IN NUMBER,
                  p_commit  IN   VARCHAR2 := FND_API.G_FALSE,
                  X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                  X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
                  X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2) IS
l_api_name varchar2(50) := 'delete_data';

BEGIN

         SAVEPOINT delete_data_int;

    BEGIN
        DELETE FROM aso_sup_instance_value
        WHERE template_instance_id = p_template_instance_id
        AND sect_comp_map_id = p_sect_comp_map_id;
    END;
    --COMMIT;
    IF fnd_api.to_boolean (p_commit) THEN
      COMMIT WORK;
    END IF;

EXCEPTION

     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);


END delete_data;


Procedure create_template_instance (
 	    P_VERSION_NUMBER		      IN   NUMBER,
    	 P_INIT_MSG_LIST        	IN   VARCHAR2     := FND_API.G_FALSE,
    	 P_COMMIT                IN   VARCHAR2     := FND_API.G_FALSE,
    	 P_Template_id           IN   NUMBER       := FND_API.G_MISS_NUM,
			   P_comp_sect_map_id      IN   JTF_NUMBER_TABLE,
			   P_response_value        IN   JTF_VARCHAR2_TABLE_2000,
			   P_response_id           IN   JTF_NUMBER_TABLE,
			   P_mult_ans_flag         IN   JTF_VARCHAR2_TABLE_100,
			   P_owner_table_name      IN   VARCHAR2     := FND_API.G_MISS_CHAR,
			   P_owner_table_id        IN   NUMBER       := FND_API.G_MISS_NUM,
			   X_template_instance_id  OUT NOCOPY /* file.sql.39 change */   NUMBER,
			   X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    	 X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    	 X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2)  IS

	   l_compSectMapId    	aso_sup_instance_value.SECT_COMP_MAP_ID%TYPE;
	   l_responseValue   	aso_sup_instance_value.VALUE%TYPE;
	   l_responseId       	aso_sup_instance_value.RESPONSE_ID%TYPE;
	   l_multAnsFlag      	VARCHAR2(1);
	   l_ownerTableName   	ASO_SUP_TMPL_INSTANCE.OWNER_TABLE_NAME%TYPE;
	   l_ownerTableId     	ASO_SUP_TMPL_INSTANCE.OWNER_TABLE_ID%TYPE ;
	   l_templateInstance   ASO_SUP_TMPL_INSTANCE.TEMPLATE_INSTANCE_ID%TYPE;
	   l_templateId         ASO_SUP_TMPL_INSTANCE.TEMPLATE_ID%TYPE ;
    l_createdBy          NUMBER := to_number( fnd_profile.value('USER_ID') );
	   l_lastUpdatedBy      NUMBER :=l_createdBy;
	   l_lastUpdateLogin    NUMBER := to_number( fnd_profile.value('LOGIN_ID') );
	   lx_returnStatus    	VARCHAR2(50);
    lx_msgCount        	NUMBER;
    lx_msgData         	VARCHAR2(2000);
	   lx_templateInstanceId NUMBER;
	   l_temp               NUMBER :=0;

	   l_compSectMapIds     JTF_NUMBER_TABLE := p_comp_sect_map_id;
    l_responseIds	       JTF_NUMBER_TABLE := P_response_id ;
	   l_responseValues     JTF_VARCHAR2_TABLE_2000 :=P_response_value;
	   l_multAnsFlags       JTF_VARCHAR2_TABLE_100   := P_mult_ans_flag;
    l_api_version  NUMBER := 1.0;
    l_api_name VARCHAR2(50) := 'create_template_instance';

    -- hyang: for bug 2710767
    lx_status                     VARCHAR2(1);
    l_header_id                   NUMBER;

    Cursor get_header_id (p_qte_line_id NUMBER ) IS
    SELECT quote_header_id
    FROM   aso_quote_lines_all
    WHERE  quote_line_id = p_qte_line_id;


    L_RETURN_STATUS      VARCHAR2(1);

	 BEGIN

       -- Enable  debug message
     Aso_Quote_Util_Pvt.Enable_Debug_Pvt;
     -- Standard Start of API savepoint
     -- hyang: for bug 2710767, added pkg_type suffix to the savepoint.
      SAVEPOINT create_template_instance_int;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                         	                 p_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                G_PKG_NAME || l_api_name||'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)THEN
              FND_MESSAGE.Set_Name(' + appShortName +',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


	  IF P_owner_table_id IS NOT NULL   THEN

      -- hyang: for bug 2710767
      -- sales supp enhancement changes bug 2940126
	 IF p_owner_table_name = 'ASO_QUOTE_HEADERS' THEN
         l_header_id := P_owner_table_id;
      ELSIF p_owner_table_name = 'ASO_QUOTE_LINES' THEN
	    OPEN get_header_id(P_owner_table_id);
	    FETCH get_header_id INTO l_header_id;
	    CLOSE get_header_id;
      END IF;

      -- Check for lock if the table name is for Quoting
	 -- bug 3154810
	 IF ( (p_owner_table_name = 'ASO_QUOTE_HEADERS')
        OR (p_owner_table_name = 'ASO_QUOTE_LINES') ) THEN

	   ASO_CONC_REQ_INT.Lock_Exists(
          p_quote_header_id => l_header_id,
          x_status          => lx_status);

        IF (lx_status = FND_API.G_TRUE) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; -- table name check

	    l_ownerTableName   := P_owner_table_name;
	   	l_ownerTableId     := P_owner_table_id;
    	l_templateId       := p_template_id;

		    CREATE_TEMPLATE_INSTANCE(
		                      p_template_id 		 =>	 l_templateId,
						  p_owner_table_name     =>  l_ownerTableName,
						  p_owner_table_id       =>  l_ownerTableId,
						  p_created_by           =>  l_createdBy,
						  p_last_updated_by      =>  l_lastUpdatedBy,
						  p_last_update_login    =>  l_lastUpdateLogin,
						  p_commit               =>  p_commit,
						  x_template_instance_id =>  lx_templateInstanceId,
                                X_RETURN_STATUS         =>   L_RETURN_STATUS,
                                X_MSG_COUNT             =>   X_MSG_COUNT,
                                X_MSG_DATA              =>   X_MSG_DATA
                                );
             IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                 x_return_status            := l_return_status;
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

	X_template_instance_id := lx_templateInstanceId;
		  l_templateInstance := lx_templateInstanceId;
    ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'x_template_instance_id '|| l_templateInstance);


	   END IF;


	  FOR l_sectLoop  IN  1..l_compSectMapIds.COUNT  LOOP
    IF (l_multAnsFlags(l_sectLoop) <> 'Y') THEN
  		 	 update_data (
			     p_template_instance_id => l_templateInstance,
		   		 p_sect_comp_map_id     => l_compSectMapIds(l_sectLoop),
				    p_created_by           => l_createdBy,
				    p_last_updated_by      => l_lastUpdatedBy,
				    p_last_update_login    =>l_lastUpdateLogin,
				    p_response_id          =>l_responseIds(l_sectLoop),
				    p_response_value       => l_responseValues(l_sectLoop),
				    p_multiple_response_flag => l_multAnsFlags(l_sectLoop),
			         p_commit               =>  p_commit,
                        X_RETURN_STATUS         =>   L_RETURN_STATUS,
                        X_MSG_COUNT             =>   X_MSG_COUNT,
                        X_MSG_DATA              =>   X_MSG_DATA
                       );

             IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                 x_return_status            := l_return_status;
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

	    ELSE
  		   IF (l_temp <> l_compSectMapIds(l_sectLoop)) THEN

              delete_data (
		          p_template_instance_id => l_templateInstance,
		          p_sect_comp_map_id     => l_compSectMapIds(l_sectLoop),
			     p_commit               =>  p_commit,
                    X_RETURN_STATUS         =>   L_RETURN_STATUS,
                    X_MSG_COUNT             =>   X_MSG_COUNT,
                    X_MSG_DATA              =>   X_MSG_DATA
				);


                  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                        x_return_status            := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

                    l_temp := l_compSectMapIds(l_sectLoop);

             END IF;
				update_data (
			          p_template_instance_id => l_templateInstance,
				     p_sect_comp_map_id     => l_compSectMapIds(l_sectLoop),
				     p_created_by           => l_createdBy,
				     p_last_updated_by      => l_lastUpdatedBy,
				     p_last_update_login    =>l_lastUpdateLogin,
				     p_response_id          =>l_responseIds(l_sectLoop),
				     p_response_value       => l_responseValues(l_sectLoop),
				     p_multiple_response_flag => l_multAnsFlags(l_sectLoop),
			          p_commit               =>  p_commit,
                         X_RETURN_STATUS         =>   L_RETURN_STATUS,
                         X_MSG_COUNT             =>   X_MSG_COUNT,
                         X_MSG_DATA              =>   X_MSG_DATA
                         );

                 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                        x_return_status            := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

           END IF;

	 END LOOP;
  --disable the  debug message
   ASO_Quote_Util_Pvt.disable_debug_pvt;
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
      ASO_Quote_Util_Pvt.disable_debug_pvt;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
       ASO_Quote_Util_Pvt.disable_debug_pvt;
     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
         ASO_Quote_Util_Pvt.disable_debug_pvt;
	END create_template_instance;

PROCEDURE update_instance_value(
 	       P_VERSION_NUMBER		IN   NUMBER,
    	    P_INIT_MSG_LIST        	IN   VARCHAR2     := FND_API.G_FALSE,
    	    P_COMMIT                IN   VARCHAR2     := FND_API.G_FALSE,
      			P_Template_instance_id  IN   NUMBER       := FND_API.G_MISS_NUM,
			      P_comp_sect_map_id      IN   JTF_NUMBER_TABLE,
			      P_response_value        IN   JTF_VARCHAR2_TABLE_2000,
			      P_response_id           IN   JTF_NUMBER_TABLE,
			      P_mult_ans_flag         IN   JTF_VARCHAR2_TABLE_100,
			      X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    	    X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */   NUMBER,
    	    X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */   VARCHAR2)  IS

	   l_compSectMapId    aso_sup_instance_value.SECT_COMP_MAP_ID%TYPE;
	   l_responseValue   	aso_sup_instance_value.VALUE%TYPE;
	   l_responseId       aso_sup_instance_value.RESPONSE_ID%TYPE;
	   l_multAnsFlag      VARCHAR2(1);
	   l_createdBy        NUMBER := to_number( fnd_profile.value('USER_ID') );
	   l_lastUpdatedBy    NUMBER :=l_createdBy;
	   l_lastUpdateLogin  NUMBER := to_number( fnd_profile.value('LOGIN_ID') );
	   lx_returnStatus    VARCHAR2(50);
    lx_msgCount        NUMBER;
    lx_msgData         VARCHAR2(2000);
	   l_templateInstance aso_sup_instance_value.template_instance_id%TYPE :=p_template_instance_id;

	   l_compSectMapIds     JTF_NUMBER_TABLE := p_comp_sect_map_id;
    l_responseIds	    JTF_NUMBER_TABLE := P_response_id ;
	   l_responseValues     JTF_VARCHAR2_TABLE_2000 :=P_response_value;
	   l_multAnsFlags       JTF_VARCHAR2_TABLE_100   := P_mult_ans_flag;
	   l_temp               NUMBER :=0;
    l_api_version  NUMBER := 1.0;
    l_api_name VARCHAR2(50) := 'update_instance_value';

    -- hyang: for bug 2710767
    lx_status                     VARCHAR2(1);
    l_quote_header_id             NUMBER;

    CURSOR c_quote (
      lc_template_instance_id       NUMBER
    ) IS
      SELECT owner_table_id,owner_table_name
      FROM ASO_SUP_TMPL_INSTANCE
      WHERE template_instance_id = lc_template_instance_id;
        --AND owner_table_name = 'ASO_QUOTE_HEADERS';

    l_header_id                   NUMBER;
    l_owner_table_id              NUMBER;
    l_owner_table_name            VARCHAR2(240);

    Cursor get_header_id (p_qte_line_id NUMBER ) IS
    SELECT quote_header_id
    FROM   aso_quote_lines_all
    WHERE  quote_line_id = p_qte_line_id;

    L_RETURN_STATUS      VARCHAR2(1);


	 BEGIN
       -- Enable  debug message
      Aso_Quote_Util_Pvt.Enable_Debug_Pvt;
     -- Standard Start of API savepoint
     -- hyang: for bug 2710767, added pkg_type suffix to the savepoint.
      SAVEPOINT update_instance_value_int;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                         	                 p_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                    'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)THEN
              FND_MESSAGE.Set_Name(' + appShortName +',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- hyang: for bug 2710767
    OPEN c_quote (
      p_template_instance_id
    );
    FETCH c_quote INTO l_owner_table_id,l_owner_table_name;  --l_quote_header_id;
    CLOSE c_quote;

    -- sales supp enhancement changes bug 2940126
      IF l_owner_table_name = 'ASO_QUOTE_HEADERS' THEN
         l_header_id := l_owner_table_id;
      ELSIF l_owner_table_name = 'ASO_QUOTE_LINES' THEN
         OPEN get_header_id(l_owner_table_id);
         FETCH get_header_id INTO l_header_id;
         CLOSE get_header_id;
      END IF;

      -- Check for lock if the table name is for Quoting
      -- bug 3154810
	 IF ( (l_owner_table_name = 'ASO_QUOTE_HEADERS')
        OR (l_owner_table_name = 'ASO_QUOTE_LINES') ) THEN

        ASO_CONC_REQ_INT.Lock_Exists(
          p_quote_header_id => l_header_id,
          x_status          => lx_status);

         IF (lx_status = FND_API.G_TRUE) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF; -- Check for table name
	  FOR l_sectLoop  IN  1..l_compSectMapIds.COUNT  LOOP
	     IF (l_multAnsFlags(l_sectLoop) <> 'Y') THEN
    		  update_data (
			      p_template_instance_id => l_templateInstance,
				     p_sect_comp_map_id     => l_compSectMapIds(l_sectLoop),
				     p_created_by           => l_createdBy,
    				 p_last_updated_by      => l_lastUpdatedBy,
				     p_last_update_login    =>l_lastUpdateLogin,
				     p_response_id          =>l_responseIds(l_sectLoop),
				     p_response_value       => l_responseValues(l_sectLoop),
				     p_multiple_response_flag => l_multAnsFlags(l_sectLoop),
			          p_commit               =>  p_commit,
                         X_RETURN_STATUS         =>   L_RETURN_STATUS,
                         X_MSG_COUNT             =>   X_MSG_COUNT,
                         X_MSG_DATA              =>   X_MSG_DATA
                        );

                  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                        x_return_status            := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;


          ELSE
 		   IF (l_temp <> l_compSectMapIds(l_sectLoop)) THEN

                 delete_data (
		          p_template_instance_id => l_templateInstance,
		          p_sect_comp_map_id     => l_compSectMapIds(l_sectLoop),
                    p_commit               =>  p_commit,
                    X_RETURN_STATUS         =>   L_RETURN_STATUS,
                    X_MSG_COUNT             =>   X_MSG_COUNT,
                    X_MSG_DATA              =>   X_MSG_DATA
                        );

                  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                        x_return_status            := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  l_temp := l_compSectMapIds(l_sectLoop);

              END IF;
		 	  update_data (
			     p_template_instance_id => l_templateInstance,
				    p_sect_comp_map_id     => l_compSectMapIds(l_sectLoop),
				    p_created_by           => l_createdBy,
				    p_last_updated_by      => l_lastUpdatedBy,
				    p_last_update_login    => l_lastUpdateLogin,
				    p_response_id          => l_responseIds(l_sectLoop),
				    p_response_value       => l_responseValues(l_sectLoop),
				    p_multiple_response_flag => l_multAnsFlags(l_sectLoop),
			         p_commit               =>  p_commit,
                        X_RETURN_STATUS         =>   L_RETURN_STATUS,
                        X_MSG_COUNT             =>   X_MSG_COUNT,
                        X_MSG_DATA              =>   X_MSG_DATA
			   );


                  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                        x_return_status            := l_return_status;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

		 END IF;
	  END LOOP;
  --disable the  debug message
   ASO_Quote_Util_Pvt.disable_debug_pvt;
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
      ASO_Quote_Util_Pvt.disable_debug_pvt;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
       ASO_Quote_Util_Pvt.disable_debug_pvt;
     WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
         ASO_Quote_Util_Pvt.disable_debug_pvt;
 END update_instance_value;
END ASO_SUP_CAPTURE_DATA_PKG;

/
