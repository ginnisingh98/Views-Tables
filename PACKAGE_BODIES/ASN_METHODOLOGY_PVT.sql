--------------------------------------------------------
--  DDL for Package Body ASN_METHODOLOGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASN_METHODOLOGY_PVT" AS
/* $Header: asnvmthb.pls 120.2 2006/08/23 19:35:17 ujayaram noship $ */

   G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ASN_METHODOLOGY_PVT';
   PROCEDURE create_sales_meth_data
     ( P_Api_Version_Number         IN   NUMBER,
       P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
       P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
       p_object_type_code           IN   VARCHAR2,
       p_object_id                  IN   VARCHAR2,
       p_sales_methodology_id       IN   NUMBER,
       X_Return_Status              OUT  NOCOPY VARCHAR2,
       X_Msg_Count                  OUT  NOCOPY NUMBER,
       X_Msg_Data                   OUT  NOCOPY VARCHAR2
     )
    IS
      G_PROC_NAME CONSTANT VARCHAR2(200) := 'asn.plsql.ASN_METHODOLOGY_PVT.Create_Sales_Meth_Data';

      G_USER_ID	  NUMBER := FND_GLOBAL.USER_ID;
      G_LOGIN_ID  NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

      /* Logging related constants */
      G_PROC_LEVEL NUMBER := FND_LOG.LEVEL_PROCEDURE;
      G_STMT_LEVEL NUMBER := FND_LOG.LEVEL_STATEMENT;
      G_EXCP_LEVEL NUMBER := FND_LOG.LEVEL_EXCEPTION;
      G_DEBUG_LEVEL NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

      CURSOR c_meth_stage_map(p_meth_id NUMBER) IS
         SELECT sales_stage_id, template_id
         FROM AS_SALES_METH_STAGE_MAP
         WHERE sales_methodology_id = p_meth_id;

      CURSOR c_tmpl_sect_map(p_template_id NUMBER) IS
         SELECT section_id, display_sequence
         FROM ASO_SUP_TMPL_SECT_MAP
         WHERE template_id = p_template_id;

      CURSOR c_next_meth_stage_instance_id IS
         SELECT AS_METH_STAGE_INSTANCES_S.nextval
         FROM DUAL;

      CURSOR c_relationship_exists(p_object_type_code VARCHAR2,
                                  p_object_id NUMBER,
                                  p_related_object_type_code VARCHAR2,
                                  p_relationship_type VARCHAR2) IS
         SELECT 1
         FROM AS_RELATIONSHIPS
         WHERE object_type_code = p_object_type_code
         AND object_id = p_object_id
         AND relationship_type_code = p_relationship_type
         AND related_object_type_code = p_related_object_type_code
         AND ROWNUM = 1;

      cursor c_methodology_exists(p_meth_id NUMBER) IS
         SELECT 1
         FROM AS_SALES_METHODOLOGY_B
         WHERE sales_methodology_id = p_meth_id;

      Cursor c_sect_comp_responses(p_template_id NUMBER) IS
         SELECT secomp.sect_comp_map_id
	    ,null
         ,secomp.default_response_id
	    ,'N'
         FROM ASO_SUP_TMPL_SECT_MAP tempsec,
              ASO_SUP_SECT_COMP_MAP secomp
         WHERE secomp.section_id = tempsec.SECTION_ID
         AND tempsec.TEMPLATE_ID = p_template_id
         AND secomp.default_response_id IS NOT NULL;


      l_meth_stage_instance_id NUMBER := NULL;
      l_template_id NUMBER := NULL;
      l_template_instance_id NUMBER := NULL;
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2(30) := 'Create_Sales_Meth_Data';
      l_sales_cycle_data_exists NUMBER := 0;
      l_object_exists NUMBER := 0;
      l_methodology_exists NUMBER := 0;

      l_comp_sect_map_id JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
      l_response_id      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
      l_response_value   JTF_VARCHAR2_TABLE_2000 := JTF_VARCHAR2_TABLE_2000();
      l_mult_ans_flag    JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();


   BEGIN
     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'begin');
     END IF;

      SAVEPOINT CREATE_SALES_METH_DATA_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- BEGIN API BODY

      -- Validate object_type_code
      IF p_object_type_code <> 'LEAD' AND p_object_type_code <> 'OPPORTUNITY' THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASN', 'ASN_CMMN_OBJTYPE_INV_ERR');
            FND_MSG_PUB.ADD;
            IF (G_EXCP_LEVEL >= G_DEBUG_LEVEL)
            THEN
              FND_LOG.String(G_EXCP_LEVEL,
                             G_PROC_NAME,
                             'ASN_CMMN_OBJTYPE_INV_ERR');
            END IF;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Validate sales methodology ID
      OPEN c_methodology_exists(p_sales_methodology_id);
      FETCH c_methodology_exists INTO l_methodology_exists;
      CLOSE c_methodology_exists;
      IF l_methodology_exists = 0
      THEN
        /* Log that sales methodology doesn't exist. If sales methodology
           does not exists, sales transactional data would not be created.
           Procedure returns. */
        IF G_EXCP_LEVEL >= G_DEBUG_LEVEL
        THEN
          FND_LOG.String(G_EXCP_LEVEL,
                         G_PROC_NAME,
                         'ASN_CMMN_SLSMETH_INV_ERR');
        END IF;
        RETURN;
      END IF;

      -- If sales cycle transactional data already exists, return
      OPEN c_relationship_exists(p_object_type_code, p_object_id,
                                 'METH_STAGE_INSTANCE', 'SALES_CYCLE');
      FETCH c_relationship_exists INTO l_sales_cycle_data_exists;
      CLOSE c_relationship_exists;

      IF l_sales_cycle_data_exists = 1 THEN
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );
          IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
          THEN
            FND_LOG.String(G_PROC_LEVEL,
                           G_PROC_NAME,
                           'Sales cycle transactional data already exists. Return.');
          END IF;
          RETURN;
      END IF;

      IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
      THEN
        FND_LOG.String(G_STMT_LEVEL,
                       G_PROC_NAME,
                       'Creating sales cycle transactional data...');
      END IF;


      -- Create sales cycle transactional data
      FOR l_meth_stage_data IN c_meth_stage_map(p_sales_methodology_id) LOOP
         l_template_id := l_meth_stage_data.template_id;
         IF l_template_id IS NOT NULL THEN
            OPEN c_next_meth_stage_instance_id;
            FETCH c_next_meth_stage_instance_id INTO l_meth_stage_instance_id;
            CLOSE c_next_meth_stage_instance_id;

            -- Create sales stage instance
            insert into AS_METH_STAGE_INSTANCES
               (METH_STAGE_INSTANCE_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                OBJECT_VERSION_NUMBER,
                SALES_METHODOLOGY_ID,
                SALES_STAGE_ID,
                COMPLETE_FLAG)
             values
                (l_meth_stage_instance_id,
                 SYSDATE,
                 G_USER_ID,
                 SYSDATE,
                 G_USER_ID,
                 G_LOGIN_ID,
                 1,
                 p_sales_methodology_id,
                 l_meth_stage_data.sales_stage_id,
                 'N');

              -- Create relationship between the object and the sales stage instance
              insert into as_relationships
                 (RELATIONSHIP_ID,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER,
                  OBJECT_TYPE_CODE,
                  OBJECT_ID,
                  RELATED_OBJECT_TYPE_CODE,
                  RELATED_OBJECT_ID,
                  RELATIONSHIP_TYPE_CODE)
              values
                 (as_relationships_s.nextval,
                  SYSDATE,
                  G_USER_ID,
                  SYSDATE,
                  G_USER_ID,
                  G_LOGIN_ID,
                  1,
                  p_object_type_code,
                  p_object_id,
                  'METH_STAGE_INSTANCE',
                  l_meth_stage_instance_id,
                  'SALES_CYCLE');

            -- Create sales methodology step instances

            FOR l_tmpl_sect_data IN c_tmpl_sect_map(l_template_id) LOOP
               insert into as_meth_step_instances
                  (METH_STEP_INSTANCE_ID,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   OBJECT_VERSION_NUMBER,
                   METH_STAGE_INSTANCE_ID,
                   TEMPLATE_ID,
                   SECTION_ID,
                   DISPLAY_SEQUENCE,
                   COMPLETE_FLAG)
                values
                   (as_meth_step_instances_s.nextval,
                    SYSDATE,
                    G_USER_ID,
                    SYSDATE,
                    G_USER_ID,
                    G_LOGIN_ID,
                    1,
                    l_meth_stage_instance_id,
                    l_template_id,
                    l_tmpl_sect_data.section_id,
                    l_tmpl_sect_data.display_sequence,
                    'N');
            END LOOP;

            OPEN c_sect_comp_responses(l_template_id);
	  	    FETCH c_sect_comp_responses BULK COLLECT INTO l_comp_sect_map_id, l_response_value, l_response_id, l_mult_ans_flag;
			CLOSE c_sect_comp_responses;

            ASO_SUP_CAPTURE_DATA_PKG.create_template_instance
            ( p_version_number => p_api_version_number,
              p_init_msg_list => p_init_msg_list,
              p_commit => p_commit,
              p_template_id => l_template_id,
              p_comp_sect_map_id => l_comp_sect_map_id,
              p_response_value => l_response_value,
              p_response_id => l_response_id,
              p_mult_ans_flag => l_mult_ans_flag,
              p_owner_table_name => 'AS_METH_STAGE_INSTANCES',
              p_owner_table_id => l_meth_stage_instance_id,
              x_template_instance_id => l_template_instance_id,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data
             );

            IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
            THEN
              FND_LOG.String(G_STMT_LEVEL,
                       G_PROC_NAME,
                       'Return from call to ASO SSup: x_template_instance_id '
					   ||l_template_instance_id||' x_return_status'||x_return_status);
            END IF;

         END IF; -- END IF l_template_id IS NOT NULL

      END LOOP;


      -- END API BODY
     IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
      THEN
        FND_LOG.String(G_PROC_LEVEL,
                       G_PROC_NAME,
                       'end');
      END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

        IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
        THEN
          FND_LOG.String(G_PROC_LEVEL,
                         G_PROC_NAME,
                         'end');
        END IF;
   END create_sales_meth_data;


END ASN_METHODOLOGY_PVT;

/
