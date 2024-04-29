--------------------------------------------------------
--  DDL for Package Body IEX_BALI_FILTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_BALI_FILTERS_PVT" as
/* $Header: iexvbflb.pls 120.3 2004/06/04 19:59:04 jsanju noship $ */

PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
-- Start of Comments
-- Package name     : IEX_BALI_FILTERS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvbflb.pls';

--private procedure
/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
        fnd_message.set_token('API_NAME', p_api_name);
        fnd_message.set_token('MISSING_PARAM', p_param_name);
        fnd_msg_pub.add;

END AddMissingArgMsg;


PROCEDURE create_BALI_FILTERS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_bali_filter_rec            IN   bali_filter_rec_type,
    X_bali_filter_id             OUT  NOCOPY NUMBER
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_BALI_FILTERS';
l_api_name_full	          CONSTANT VARCHAR2(150) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
v_bali_filter_id          IEX_BALI_FILTERS.bali_filter_id%TYPE;
v_object_version_number   IEX_BALI_FILTERS.object_version_number%TYPE;
v_rowid                    VARCHAR2(24);

Cursor c2 is SELECT IEX_BALI_FILTERS_S.nextval from dual;

 BEGIN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
                   'IEX_BALI_FILTERS_PVT.create_BALI_FILTERS *** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_BALI_FILTERS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('After Compatibility Check');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('After Global user Check');
      END IF;


      --object version Number
        v_object_version_number :=1;

       -- get bali_filter_id
       OPEN C2;
       FETCH C2 INTO v_bali_filter_id;
       CLOSE C2;
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('bali_filter_id is => '||v_bali_filter_id);
       END IF;

      	--bali_filter_name check
          IF (P_bali_filter_rec.bali_filter_name IS NULL)  THEN
              AddMissingArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'bali_filter_name' );
                    RAISE FND_API.G_EXC_ERROR;
 		 END IF;

         --bali_col_alias
          IF (P_bali_filter_rec.bali_col_alias IS NULL)  THEN
  	           AddMissingArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'bali_col_alias' );
               RAISE FND_API.G_EXC_ERROR;
		END IF;

         --bali_col_condition_value
          IF (P_bali_filter_rec.bali_col_condition_value IS NULL)  THEN
  	         AddMissingArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'bali_col_condition_value' );
             RAISE FND_API.G_EXC_ERROR;
		END IF;

        --bali_col_value
          IF (P_bali_filter_rec.bali_col_value IS NULL)  THEN
  	         AddMissingArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'bali_col_value' );
             RAISE FND_API.G_EXC_ERROR;
		END IF;


       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('Before Calling iex_BALI_FILTERS_pkg.insert_row');
       END IF;
       -- Invoke table handler(IEX_BALI_FILTERS_PKG.Insert_Row)
      IEX_BALI_FILTERS_PKG.Insert_Row(
          x_rowid                     => v_rowid,
          x_bali_filter_id            => v_bali_filter_id,
          x_bali_filter_name          => P_bali_filter_rec.bali_filter_name,
          x_bali_datasource           => P_bali_filter_rec.bali_datasource,
          x_bali_user_id              =>P_bali_filter_rec.bali_user_id,
          x_bali_col_alias             => P_bali_filter_rec.bali_col_alias,
          x_bali_col_data_type         => P_bali_filter_rec.bali_col_data_type
         ,x_bali_col_label_text        => P_bali_filter_rec.bali_col_label_text
         ,x_bali_col_condition_code    => P_bali_filter_rec.bali_col_condition_code
         ,x_bali_col_condition_value   => P_bali_filter_rec.bali_col_condition_value
         ,x_bali_col_value             => P_bali_filter_rec.bali_col_value
         ,x_right_parenthesis_code     => P_bali_filter_rec.right_parenthesis_code
         ,x_left_parenthesis_code      => P_bali_filter_rec.left_parenthesis_code
         ,x_boolean_operator_code      => P_bali_filter_rec.boolean_operator_code
          ,x_OBJECT_VERSION_NUMBER     => v_OBJECT_VERSION_NUMBER,
          x_REQUEST_ID                => P_bali_filter_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID   => P_bali_filter_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID               => P_bali_filter_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE      => P_bali_filter_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY       => P_bali_filter_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => P_bali_filter_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => P_bali_filter_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => P_bali_filter_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => P_bali_filter_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => P_bali_filter_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => P_bali_filter_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => P_bali_filter_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => P_bali_filter_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => P_bali_filter_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => P_bali_filter_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => P_bali_filter_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => P_bali_filter_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => P_bali_filter_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => P_bali_filter_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => P_bali_filter_rec.ATTRIBUTE15,
          x_CREATED_BY  => FND_GLOBAL.USER_ID,
          X_CREATION_DATE  => SYSDATE,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID);



      -- Hint: Primary key should be returned.
        x_bali_filter_id := v_bali_filter_id;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('After Calling iex_BALI_FILTERS_pkg.insert_row'||
        'and bali_filter_id => '||x_bali_filter_id);
END IF;



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('****** End of Procedure =>IEX_BALI_FILTERS_PVT.create_BALI_FILTERS ****** ');
     END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_BALI_FILTERS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_BALI_FILTERS_PVT;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO CREATE_BALI_FILTERS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End create_BALI_FILTERS;



PROCEDURE update_BALI_FILTERS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_bali_filter_rec            IN    bali_filter_rec_type,
    x_return_status             OUT  NOCOPY VARCHAR2
    ,x_msg_count                OUT  NOCOPY NUMBER
    ,x_msg_data                 OUT  NOCOPY VARCHAR2
    ,XO_OBJECT_VERSION_NUMBER   OUT  NOCOPY NUMBER
    )
 IS
l_api_name                CONSTANT VARCHAR2(60) := 'UPDATE_BALI_FILTERS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
v_object_version_number IEX_BALI_FILTERS.object_version_number%TYPE
                         :=P_bali_filter_rec.object_version_number;

 BEGIN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
        'IEX_BALI_FILTERS_PVT.update_BALI_FILTERS *** ');
     END IF;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_BALI_FILTERS_PVT;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Before Calling iex_BALI_FILTERS_pkg.lock_row');
      END IF;
      -- Invoke table handler(IEX_BALI_FILTERS_PKG.Update_Row)
      -- call locking table handler
      IEX_BALI_FILTERS_PKG.lock_row (
         P_bali_filter_rec.bali_filter_id,
         v_object_version_number
      );

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Before Calling iex_BALI_FILTERS_pkg.update_row');
      END IF;

      IEX_BALI_FILTERS_PKG.Update_Row(
          x_bali_filter_id        => P_bali_filter_rec.bali_filter_id,
          x_bali_filter_name          => P_bali_filter_rec.bali_filter_name,
          x_bali_datasource           => P_bali_filter_rec.bali_datasource,
          x_bali_user_id              =>P_bali_filter_rec.bali_user_id,
          x_bali_col_alias             => P_bali_filter_rec.bali_col_alias
         ,x_bali_col_data_type         => P_bali_filter_rec.bali_col_data_type
         ,x_bali_col_label_text        => P_bali_filter_rec.bali_col_label_text
         ,x_bali_col_condition_code    => P_bali_filter_rec.bali_col_condition_code
         ,x_bali_col_condition_value   => P_bali_filter_rec.bali_col_condition_value
         ,x_bali_col_value             => P_bali_filter_rec.bali_col_value
         ,x_right_parenthesis_code     => P_bali_filter_rec.right_parenthesis_code
         ,x_left_parenthesis_code      => P_bali_filter_rec.left_parenthesis_code
         ,x_boolean_operator_code      => P_bali_filter_rec.boolean_operator_code
          ,x_OBJECT_VERSION_NUMBER     => v_OBJECT_VERSION_NUMBER + 1,
          x_REQUEST_ID                => P_bali_filter_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID   => P_bali_filter_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID               => P_bali_filter_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE      => P_bali_filter_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY       => P_bali_filter_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => P_bali_filter_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => P_bali_filter_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => P_bali_filter_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => P_bali_filter_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => P_bali_filter_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => P_bali_filter_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => P_bali_filter_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => P_bali_filter_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => P_bali_filter_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => P_bali_filter_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => P_bali_filter_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => P_bali_filter_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => P_bali_filter_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => P_bali_filter_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => P_bali_filter_rec.ATTRIBUTE15,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
     );


     --Return Version number
      xo_object_version_number := v_object_version_number + 1;
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('**** End of Procedure =>'||
          'IEX_BALI_FILTERS_PVT.update_BALI_FILTERS ** ');
      END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_BALI_FILTERS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_BALI_FILTERS_PVT;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO UPDATE_BALI_FILTERS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End update_BALI_FILTERS;



PROCEDURE  delete_BALI_FILTERS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_bali_filter_id             IN   NUMBER ,
    x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2

    )

 IS
l_api_name                CONSTANT VARCHAR2(50) := 'DELETE_BALI_FILTERS';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_BALI_FILTERS_PVT;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --

      -- call table handler to insert into jtf_tasks_temp_groups
      iex_BALI_FILTERS_pkg.delete_row (p_bali_filter_id);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_BALI_FILTERS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_BALI_FILTERS_PVT;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO DELETE_BALI_FILTERS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End delete_BALI_FILTERS;

Procedure commit_work IS
BEGIN
     COMMIT WORK;
end commit_work;
End IEX_BALI_FILTERS_PVT;

/
