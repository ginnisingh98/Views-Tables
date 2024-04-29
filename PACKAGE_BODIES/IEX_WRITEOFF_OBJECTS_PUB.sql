--------------------------------------------------------
--  DDL for Package Body IEX_WRITEOFF_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WRITEOFF_OBJECTS_PUB" as
/* $Header: iexpwobb.pls 120.1 2007/10/31 14:58:12 ehuh ship $ */

PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE AddMissingArgMsg (p_api_name	    IN	VARCHAR2,
                            p_param_name    IN	VARCHAR2 )IS
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
    P_writeoff_obj_rec           IN   writeoff_obj_rec_type ,
    X_writeoff_object_id         OUT  NOCOPY NUMBER
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_WRITEOFF_OBJECTS';
   l_api_name_full	          CONSTANT VARCHAR2(150) := g_pkg_name || '.' || l_api_name;
   l_api_version_number      CONSTANT NUMBER   := 2.0;
   l_writeoff_object_id      IEX_writeoff_objects.writeoff_object_id%TYPE;
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER ;
   l_msg_data VARCHAR2(32627);

 BEGIN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
                   'IEX_writeoff_objects_PUB.create_writeoff_objects *** ');
      END IF;
      SAVEPOINT CREATE_WRITEOFF_OBJECTS_PUB;

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number,
                                           l_api_name, G_PKG_NAME) then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('After Compatibility Check');
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list ) then
          FND_MSG_PUB.initialize;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) then
      IEX_DEBUG_PUB.LogMessage('After Global user Check');
      END IF;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Before Calling iex_writeoff_objects_pvt.create_writeoff_objects');
      END IF;
       --Call PVT
       IEX_WRITEOFF_OBJECTS_PVT.create_writeoff_objects(
         P_Api_Version_Number       =>p_Api_Version_Number
        ,P_Init_Msg_List            =>P_Init_Msg_List
        ,P_Commit                   =>p_commit
        ,P_writeoff_obj_rec         =>P_writeoff_obj_rec
        ,X_writeoff_object_id       =>l_writeoff_object_id
        ,x_return_status            =>l_return_status
        ,x_msg_count                =>l_msg_count
        ,x_msg_data                 =>l_msg_data);

      -- Hint: Primary key should be returned.
        x_writeoff_object_id := l_writeoff_object_id;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('After Calling iex_writeoff_objects_pvt.create_writeoff_objects'||
                                     'and writeoff_object_id => '||x_writeoff_object_id);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR then
           raise FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

      -- End of API body.

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) then
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_writeoff_objects_PUB.'||
                                'create_writeoff_objects ******** ');
     END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CREATE_WRITEOFF_OBJECTS_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CREATE_WRITEOFF_OBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO CREATE_WRITEOFF_OBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End create_writeoff_objects;


PROCEDURE update_writeoff_objects(
     P_Api_Version_Number         IN   NUMBER
    ,P_Init_Msg_List              IN   VARCHAR2
    ,P_Commit                     IN   VARCHAR2
    ,P_writeoff_obj_rec           IN   writeoff_obj_rec_type
    ,x_return_status              OUT  NOCOPY VARCHAR2
    ,x_msg_count                  OUT  NOCOPY NUMBER
    ,x_msg_data                   OUT  NOCOPY VARCHAR2
    ,XO_OBJECT_VERSION_NUMBER     OUT  NOCOPY NUMBER) IS

l_api_name                CONSTANT VARCHAR2(60) := 'UPDATE_WRITEOFF_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
v_object_version_number IEX_writeoff_objects.object_version_number%TYPE
                         :=p_writeoff_obj_rec.object_version_number;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(32627);

 BEGIN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
                                   'IEX_writeoff_objects_PUB.update_writeoff_objects *** ');
      END IF;

      SAVEPOINT UPDATE_WRITEOFF_OBJECTS_PUB;
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number,
                                           l_api_name, G_PKG_NAME) then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_init_msg_list ) then
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Before Calling iex_writeoff_objects_pvt.'||
                                  'update_writeoff_objects');
      END IF;
      -- Invoke pvt(IEX_writeoff_objects_PVT.update_writeoff_objects)

       IEX_WRITEOFF_OBJECTS_PVT.update_writeoff_objects(
         P_Api_Version_Number       =>p_Api_Version_Number
        ,P_Init_Msg_List            =>P_Init_Msg_List
        ,P_Commit                   =>p_commit
        ,P_writeoff_obj_rec         =>P_writeoff_obj_rec
        ,XO_object_version_number   =>v_object_version_number
        ,x_return_status            =>l_return_status
        ,x_msg_count                =>l_msg_count
        ,x_msg_data                 =>l_msg_data);

     --Return Version number
      xo_object_version_number := v_object_version_number ;
      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit ) then
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage ('**** End of Procedure =>'||
                       'IEX_writeoff_objects_PUB.update_writeoff_objects ** ');
      END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO UPDATE_WRITEOFF_OBJECTS_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO UPDATE_WRITEOFF_OBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
          WHEN OTHERS THEN
                ROLLBACK TO UPDATE_WRITEOFF_OBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
End update_writeoff_objects;

PROCEDURE delete_writeoff_objects(
     P_Api_Version_Number         IN   NUMBER
    ,P_Init_Msg_List              IN   VARCHAR2
    ,P_Commit                     IN   VARCHAR2
    ,p_writeoff_object_id         IN   NUMBER
    ,x_return_status              OUT  NOCOPY VARCHAR2
    ,x_msg_count                  OUT  NOCOPY NUMBER
    ,x_msg_data                   OUT  NOCOPY VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(50) := 'DELETE_WRITEOFF_OBJECTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(32627);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_WRITEOFF_OBJECTS_PUB;

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

      -- call pvt
       IEX_WRITEOFF_OBJECTS_PVT.delete_writeoff_objects(
         P_Api_Version_Number       =>p_Api_Version_Number
        ,P_Init_Msg_List            =>P_Init_Msg_List
        ,P_Commit                   =>p_commit
        ,P_writeoff_object_id       =>p_writeoff_object_id
        ,x_return_status            =>l_return_status
        ,x_msg_count                =>l_msg_count
        ,x_msg_data                 =>l_msg_data);


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
                ROLLBACK TO DELETE_WRITEOFF_OBJECTS_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_WRITEOFF_OBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO DELETE_WRITEOFF_OBJECTS_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

End delete_writeoff_objects;


End IEX_WRITEOFF_OBJECTS_PUB;


/
