--------------------------------------------------------
--  DDL for Package Body IEX_WRITEOFF_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WRITEOFF_OBJECTS_PVT" as
/* $Header: iexvwobb.pls 120.1 2007/10/31 12:30:14 ehuh ship $ */

PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
-- Start of Comments
-- Package name     : IEX_writeoff_objects_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvwobb.pls';

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


PROCEDURE create_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_writeoff_obj_rec           IN    writeoff_obj_rec_Type
   ,X_writeoff_object_id         OUT  NOCOPY NUMBER
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_WRITEOFF_OBJECTS';
l_api_name_full	          CONSTANT VARCHAR2(150) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
v_writeoff_object_id      IEX_writeoff_objects.writeoff_object_id%TYPE;
v_object_version_number   IEX_writeoff_objects.object_version_number%TYPE;
v_rowid                    VARCHAR2(24);

Cursor c2 is SELECT IEX_writeoff_objects_S.nextval from dual;

 BEGIN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
                   'IEX_writeoff_objects_PVT.create_writeoff_objects *** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_WRITEOFF_OBJECTS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number,
                                           l_api_name, G_PKG_NAME) then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('After Compatibility Check');
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
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


      v_object_version_number :=1;

      OPEN C2;
      FETCH C2 INTO v_writeoff_object_id;
      CLOSE C2;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('writeoff_object_id is => '||v_writeoff_object_id);
      END IF;

      IF (p_writeoff_obj_rec.writeoff_id IS NULL)  THEN
              AddMissingArgMsg(p_api_name    =>  l_api_name_full,
                               p_param_name  =>  'writeoff_id' );
              RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_writeoff_obj_rec.adjustment_amount IS NULL)  THEN
  	           AddMissingArgMsg(p_api_name    =>  l_api_name_full,
                                    p_param_name  =>  'adjustment_amount' );
               RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_writeoff_obj_rec.transaction_id IS NULL)  THEN
  	         AddMissingArgMsg(p_api_name    =>  l_api_name_full,
                                  p_param_name  =>  'transaction_id' );
                 RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_writeoff_obj_rec.adjustment_reason_code IS NULL)  THEN
  	         AddMissingArgMsg(p_api_name    =>  l_api_name_full,
                                  p_param_name  =>  'adjustment_reason_code' );
             RAISE FND_API.G_EXC_ERROR;
       END IF;


       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Before Calling iex_writeoff_objects_pkg.insert_row');
       END IF;

      IEX_writeoff_objects_PKG.Insert_Row(
          x_rowid                     => v_rowid,
          x_WRITEOFF_OBJECT_ID        => v_writeoff_object_id,
          x_WRITEOFF_ID               => p_writeoff_obj_rec.WRITEOFF_ID,
          x_OBJECT_VERSION_NUMBER     => v_OBJECT_VERSION_NUMBER,
          x_CONTRACT_ID               => p_writeoff_obj_rec.CONTRACT_ID,
          x_CONS_INVOICE_ID           => p_writeoff_obj_rec.CONS_INVOICE_ID,
          x_CONS_INVOICE_LINE_ID      => p_writeoff_obj_rec.CONS_INVOICE_LINE_ID,
          x_TRANSACTION_ID            => p_writeoff_obj_rec.TRANSACTION_ID,
          x_ADJUSTMENT_AMOUNT         => p_writeoff_obj_rec.ADJUSTMENT_AMOUNT,
          x_ADJUSTMENT_REASON_CODE    => p_writeoff_obj_rec.adjustment_reason_code,
          x_RECEVIABLES_ADJUSTMENT_ID => p_writeoff_obj_rec.RECEVIABLES_ADJUSTMENT_ID,
          x_REQUEST_ID                => p_writeoff_obj_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID   => p_writeoff_obj_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID               => p_writeoff_obj_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE      => p_writeoff_obj_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY       => p_writeoff_obj_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => p_writeoff_obj_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => p_writeoff_obj_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => p_writeoff_obj_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => p_writeoff_obj_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => p_writeoff_obj_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => p_writeoff_obj_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => p_writeoff_obj_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => p_writeoff_obj_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => p_writeoff_obj_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => p_writeoff_obj_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => p_writeoff_obj_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => p_writeoff_obj_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => p_writeoff_obj_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => p_writeoff_obj_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => p_writeoff_obj_rec.ATTRIBUTE15,
          x_CREATED_BY  => FND_GLOBAL.USER_ID,
          X_CREATION_DATE  => SYSDATE,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          x_WRITEOFF_STATUS  => p_writeoff_obj_rec.WRITEOFF_STATUS,
          x_WRITEOFF_TYPE_ID  => p_writeoff_obj_rec.WRITEOFF_TYPE_ID,
          x_WRITEOFF_TYPE => p_writeoff_obj_rec.WRITEOFF_TYPE,
          x_customer_trx_id => p_writeoff_obj_rec.customer_trx_id,
          x_customer_trx_line_id => p_writeoff_obj_rec.customer_trx_line_id);


        x_writeoff_object_id := v_writeoff_object_id;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('After Calling iex_writeoff_objects_pkg.insert_row'||
        'and writeoff_object_id => '||x_writeoff_object_id);
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
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_writeoff_objects_PVT.create_writeoff_objects ******** ');
     END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_WRITEOFF_OBJECTS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_WRITEOFF_OBJECTS_PVT;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO CREATE_WRITEOFF_OBJECTS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End create_writeoff_objects;



PROCEDURE update_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_writeoff_obj_rec           IN    writeoff_obj_rec_Type,
     x_return_status              OUT  NOCOPY VARCHAR2
    ,x_msg_count                  OUT  NOCOPY NUMBER
    ,x_msg_data                   OUT  NOCOPY VARCHAR2
    ,XO_OBJECT_VERSION_NUMBER     OUT  NOCOPY NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(60) := 'UPDATE_WRITEOFF_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
v_object_version_number IEX_writeoff_objects.object_version_number%TYPE
                         :=p_writeoff_obj_rec.object_version_number;

 BEGIN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
        'IEX_writeoff_objects_PVT.update_writeoff_objects *** ');
     END IF;

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_WRITEOFF_OBJECTS_PVT;

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
      IEX_DEBUG_PUB.LogMessage('Before Calling iex_writeoff_objects_pkg.lock_row');
      END IF;
      -- Invoke table handler(IEX_writeoff_objects_PKG.Update_Row)
      -- call locking table handler
      IEX_writeoff_objects_PKG.lock_row (
         p_writeoff_obj_rec.writeoff_object_id,
         v_object_version_number
      );

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Before Calling iex_writeoff_objects_pkg.update_row');
      END IF;

      IEX_writeoff_objects_PKG.Update_Row(
          x_WRITEOFF_OBJECT_ID        => p_writeoff_obj_rec.writeoff_object_id,
          x_WRITEOFF_ID               => p_writeoff_obj_rec.WRITEOFF_ID,
          x_OBJECT_VERSION_NUMBER     => v_OBJECT_VERSION_NUMBER + 1,
          x_CONTRACT_ID               => p_writeoff_obj_rec.CONTRACT_ID,
          x_CONS_INVOICE_ID           => p_writeoff_obj_rec.CONS_INVOICE_ID,
          x_CONS_INVOICE_LINE_ID      => p_writeoff_obj_rec.CONS_INVOICE_LINE_ID,
          x_TRANSACTION_ID            => p_writeoff_obj_rec.TRANSACTION_ID,
          x_ADJUSTMENT_AMOUNT         => p_writeoff_obj_rec.ADJUSTMENT_AMOUNT,
          x_ADJUSTMENT_REASON_CODE    => p_writeoff_obj_rec.adjustment_reason_code,
          x_RECEVIABLES_ADJUSTMENT_ID => p_writeoff_obj_rec.RECEVIABLES_ADJUSTMENT_ID,
          x_REQUEST_ID                => p_writeoff_obj_rec.REQUEST_ID,
          x_PROGRAM_APPLICATION_ID   => p_writeoff_obj_rec.PROGRAM_APPLICATION_ID,
          x_PROGRAM_ID               => p_writeoff_obj_rec.PROGRAM_ID,
          x_PROGRAM_UPDATE_DATE      => p_writeoff_obj_rec.PROGRAM_UPDATE_DATE,
          x_ATTRIBUTE_CATEGORY       => p_writeoff_obj_rec.ATTRIBUTE_CATEGORY,
          x_ATTRIBUTE1  => p_writeoff_obj_rec.ATTRIBUTE1,
          x_ATTRIBUTE2  => p_writeoff_obj_rec.ATTRIBUTE2,
          x_ATTRIBUTE3  => p_writeoff_obj_rec.ATTRIBUTE3,
          x_ATTRIBUTE4  => p_writeoff_obj_rec.ATTRIBUTE4,
          x_ATTRIBUTE5  => p_writeoff_obj_rec.ATTRIBUTE5,
          x_ATTRIBUTE6  => p_writeoff_obj_rec.ATTRIBUTE6,
          x_ATTRIBUTE7  => p_writeoff_obj_rec.ATTRIBUTE7,
          x_ATTRIBUTE8  => p_writeoff_obj_rec.ATTRIBUTE8,
          x_ATTRIBUTE9  => p_writeoff_obj_rec.ATTRIBUTE9,
          x_ATTRIBUTE10  => p_writeoff_obj_rec.ATTRIBUTE10,
          x_ATTRIBUTE11  => p_writeoff_obj_rec.ATTRIBUTE11,
          x_ATTRIBUTE12  => p_writeoff_obj_rec.ATTRIBUTE12,
          x_ATTRIBUTE13  => p_writeoff_obj_rec.ATTRIBUTE13,
          x_ATTRIBUTE14  => p_writeoff_obj_rec.ATTRIBUTE14,
          x_ATTRIBUTE15  => p_writeoff_obj_rec.ATTRIBUTE15,
          x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          X_LAST_UPDATE_DATE  => SYSDATE,
          x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          x_WRITEOFF_STATUS  => p_writeoff_obj_rec.WRITEOFF_STATUS,
          x_WRITEOFF_TYPE_ID  => p_writeoff_obj_rec.WRITEOFF_TYPE_ID,
          x_WRITEOFF_TYPE => p_writeoff_obj_rec.WRITEOFF_TYPE,
          x_customer_trx_id => p_writeoff_obj_rec.customer_trx_id,
          x_customer_trx_line_id => p_writeoff_obj_rec.customer_trx_line_id);


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
          'IEX_writeoff_objects_PVT.update_writeoff_objects ** ');
      END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_WRITEOFF_OBJECTS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_WRITEOFF_OBJECTS_PVT;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO UPDATE_WRITEOFF_OBJECTS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End update_writeoff_objects;



PROCEDURE delete_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_writeoff_object_id         IN NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2
    ,x_msg_count                  OUT  NOCOPY NUMBER
    ,x_msg_data                   OUT  NOCOPY VARCHAR2    )

 IS
l_api_name                CONSTANT VARCHAR2(50) := 'DELETE_WRITEOFF_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_WRITEOFF_OBJECTS_PVT;

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
      iex_writeoff_objects_pkg.delete_row (p_writeoff_object_id);

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
                ROLLBACK TO DELETE_WRITEOFF_OBJECTS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_WRITEOFF_OBJECTS_PVT;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO DELETE_WRITEOFF_OBJECTS_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End delete_writeoff_objects;


End IEX_WRITEOFF_OBJECTS_PVT;

/
