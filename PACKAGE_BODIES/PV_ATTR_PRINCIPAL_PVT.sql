--------------------------------------------------------
--  DDL for Package Body PV_ATTR_PRINCIPAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTR_PRINCIPAL_PVT" as
 /* $Header: pvxvatpb.pls 120.0 2007/12/20 07:11:02 abnagapp noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTR_PRINCIPAL_PVT
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Attr_Principal_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvatub.pls';

 G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID,-1);
 G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID,-1);

 -- Hint: Primary key needs to be returned.
 PROCEDURE Create_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type  := g_miss_Attr_Principal_rec
    ,x_Attr_Principal_id         OUT NOCOPY  NUMBER
    )


  IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Attr_Principal';
    l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status_full        VARCHAR2(1);
    l_object_version_number     NUMBER := 1;
    l_org_id                    NUMBER := FND_API.G_MISS_NUM;
    l_Attr_Principal_id        NUMBER;
    l_dummy                     NUMBER;
    l_Attr_Principal_rec       Attr_Principal_rec_type  := p_Attr_Principal_rec;

    CURSOR c_id IS
       SELECT PV.PV_Attr_PrincipalS_s.NEXTVAL
       FROM dual;

    CURSOR c_id_exists (l_id IN NUMBER) IS
       SELECT 1
       FROM PV_Attr_PrincipalS
       WHERE Attr_Principal_ID = l_id;

 BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT CREATE_Attr_Principal_PVT;

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

       -- Debug Message
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Local variable initialization

    IF p_Attr_Principal_rec.Attr_Principal_ID IS NULL
       OR p_Attr_Principal_rec.Attr_Principal_ID = FND_API.g_miss_num THEN
       LOOP
          l_dummy := NULL;
          OPEN c_id;
          FETCH c_id INTO l_Attr_Principal_ID;
          CLOSE c_id;

          OPEN c_id_exists(l_Attr_Principal_ID);
          FETCH c_id_exists INTO l_dummy;
          CLOSE c_id_exists;
          EXIT WHEN l_dummy IS NULL;
       END LOOP;
    ELSE
       l_Attr_Principal_ID := p_Attr_Principal_rec.Attr_Principal_ID;
    END IF;
       -- =========================================================================
       -- Validate Environment
       -- =========================================================================

       IF FND_GLOBAL.User_Id IS NULL
       THEN
           FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_Attr_Principal');
		   end if;

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Validate_Attr_Principal' );

           -- Populate the default required items
           l_Attr_Principal_rec.Attr_Principal_id    := l_Attr_Principal_id;
           l_Attr_Principal_rec.last_update_date      := SYSDATE;
           l_Attr_Principal_rec.last_updated_by       := G_USER_ID;
           l_Attr_Principal_rec.creation_date         := SYSDATE;
           l_Attr_Principal_rec.created_by            := G_USER_ID;
           l_Attr_Principal_rec.last_update_login     := G_LOGIN_ID;
           l_Attr_Principal_rec.object_version_number := l_object_version_number;

           -- Invoke validation procedures
           Validate_Attr_Principal(
             p_api_version_number   => 1.0
            ,p_init_msg_list        => FND_API.G_FALSE
            ,p_validation_level     => p_validation_level
            ,p_validation_mode      => JTF_PLSQL_API.g_create
            ,p_Attr_Principal_rec  => l_Attr_Principal_rec
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate_Attr_Principal' );
       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate' );
       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling create table handler');
	   END IF;

       -- Invoke table handler(PV_Attr_PrincipalS_PKG.Insert_Row)
       PV_Attr_PrincipalS_PKG.Insert_Row(
           px_Attr_Principal_id    => l_Attr_Principal_rec.Attr_Principal_id
          ,p_last_update_date       => l_Attr_Principal_rec.last_update_date
          ,p_last_updated_by        => l_Attr_Principal_rec.last_updated_by
          ,p_creation_date          => l_Attr_Principal_rec.creation_date
          ,p_created_by             => l_Attr_Principal_rec.created_by
          ,p_last_update_login      => l_Attr_Principal_rec.last_update_login
          ,px_object_version_number => l_Attr_Principal_rec.object_version_number
          ,p_attribute_id           => l_Attr_Principal_rec.attribute_id
          ,p_jtf_auth_principal_id  => l_Attr_Principal_rec.jtf_auth_principal_id
          --p_security_group_id  => l_Attr_Principal_rec.security_group_id
          );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After' );

          x_Attr_Principal_id := l_Attr_Principal_id;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
 --
 -- End of API body
 --

       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Create_Attr_Principal;


 PROCEDURE Update_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    )
  IS

 CURSOR c_get_Attr_Principal(cv_Attr_Principal_id NUMBER) IS
     SELECT *
     FROM  PV_Attr_PrincipalS
     WHERE Attr_Principal_id = cv_Attr_Principal_id;

 l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Attr_Principal';
 l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number       CONSTANT NUMBER   := 1.0;
 -- Local Variables
 l_object_version_number    NUMBER;
 l_Attr_Principal_id       NUMBER;
 l_ref_Attr_Principal_rec  c_get_Attr_Principal%ROWTYPE ;
 l_tar_Attr_Principal_rec  PV_Attr_Principal_PVT.Attr_Principal_rec_type := P_Attr_Principal_rec;
 l_rowid  ROWID;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT UPDATE_Attr_Principal_PVT;

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

       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Open Cursor to Select');
       END IF;

       OPEN c_get_Attr_Principal( l_tar_Attr_Principal_rec.Attr_Principal_id);

       FETCH c_get_Attr_Principal INTO l_ref_Attr_Principal_rec  ;

        IF ( c_get_Attr_Principal%NOTFOUND) THEN
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
			   FND_MESSAGE.set_token('MODE','Update');
			   FND_MESSAGE.set_token('ENTITY','Attr_Principal');
			   FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_Attr_Principal_rec.Attr_Principal_id));
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Debug Message
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		 PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
		 END IF;

        CLOSE     c_get_Attr_Principal;



       IF (l_tar_Attr_Principal_rec.object_version_number is NULL or
           l_tar_Attr_Principal_rec.object_version_number = FND_API.G_MISS_NUM ) Then

		   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
			   FND_MESSAGE.set_token('COLUMN',TO_CHAR(l_tar_Attr_Principal_rec.last_update_date));
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
       End if;

       -- Check Whether record has been changed by someone else
       If (l_tar_Attr_Principal_rec.object_version_number <> l_ref_Attr_Principal_rec.object_version_number) Then
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
			   FND_MESSAGE.set_token('VALUE','Attr_Principal');
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
       End if;
       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_Attr_Principal');
		   END IF;

           -- Invoke validation procedures
           Validate_Attr_Principal(
             p_api_version_number   => 1.0
            ,p_init_msg_list        => FND_API.G_FALSE
            ,p_validation_level     => p_validation_level
            ,p_validation_mode      => JTF_PLSQL_API.g_update
            ,p_Attr_Principal_rec  => p_Attr_Principal_rec
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            );

       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;


       -- Debug Message
       --PVX_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'Private API: Calling update table handler');
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
	   END IF;

       -- Invoke table handler(PV_Attr_PrincipalS_PKG.Update_Row)
       PV_Attr_PrincipalS_PKG.Update_Row(
           p_Attr_Principal_id     => p_Attr_Principal_rec.Attr_Principal_id
          ,p_last_update_date       => SYSDATE
          ,p_last_updated_by        => G_USER_ID
          --,p_creation_date          => SYSDATE
          --,p_created_by             => G_USER_ID
          ,p_last_update_login      => G_LOGIN_ID
          ,p_object_version_number  => p_Attr_Principal_rec.object_version_number
          ,p_attribute_id           => p_Attr_Principal_rec.attribute_id
          ,p_jtf_auth_principal_id  => p_Attr_Principal_rec.jtf_auth_principal_id
          --p_security_group_id  => p_Attr_Principal_rec.security_group_id
          );

          x_object_version_number := p_Attr_Principal_rec.object_version_number + 1;
       --
       -- End of API body.
       --

       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Update_Attr_Principal;


 PROCEDURE Delete_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_id         IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Attr_Principal';
 l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT DELETE_Attr_Principal_PVT;

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

       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
       -- Api body
       --
       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling delete table handler');
	   END IF;


       -- Invoke table handler(PV_Attr_PrincipalS_PKG.Delete_Row)
       PV_Attr_PrincipalS_PKG.Delete_Row(
           p_Attr_Principal_ID  => p_Attr_Principal_ID);
       --
       -- End of API body
       --

       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO DELETE_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Delete_Attr_Principal;



 -- Hint: Primary key needs to be returned.
 PROCEDURE Lock_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_Attr_Principal_id         IN   NUMBER
    ,p_object_version             IN   NUMBER
    )

  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Attr_Principal';
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_Attr_Principal_ID                  NUMBER;

 CURSOR c_Attr_Principal IS
    SELECT Attr_Principal_ID
    FROM PV_Attr_PrincipalS
    WHERE Attr_Principal_ID = p_Attr_Principal_ID
    AND object_version_number = p_object_version
    FOR UPDATE NOWAIT;

 BEGIN

       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list )
       THEN
          FND_MSG_PUB.initialize;
       END IF;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;


 ------------------------ lock -------------------------
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
   PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   OPEN c_Attr_Principal;

   FETCH c_Attr_Principal INTO l_Attr_Principal_ID;

   IF (c_Attr_Principal%NOTFOUND) THEN
     CLOSE c_Attr_Principal;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			FND_MESSAGE.set_name('PV', 'PV_API_RECORD_NOT_FOUND');
			FND_MSG_PUB.add;
		END IF;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_Attr_Principal;

  -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data);
    IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': end');
	END IF;
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_Attr_Principal_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Lock_Attr_Principal;


 PROCEDURE check_uk_items(
     p_Attr_Principal_rec IN  Attr_Principal_rec_type
    ,p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status       OUT NOCOPY VARCHAR2)
 IS
 l_valid_flag  VARCHAR2(1);

 BEGIN
       x_return_status := FND_API.g_ret_sts_success;
       IF p_validation_mode = JTF_PLSQL_API.g_create THEN
          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
          'PV_Attr_PrincipalS',
          'Attr_Principal_ID = ''' || p_Attr_Principal_rec.Attr_Principal_ID ||''''
          );
       ELSE
          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
          'PV_Attr_PrincipalS',
          'Attr_Principal_ID = ''' || p_Attr_Principal_rec.Attr_Principal_ID ||
          ''' AND Attr_Principal_ID <> ' || p_Attr_Principal_rec.Attr_Principal_ID
          );
       END IF;

       IF l_valid_flag = FND_API.g_false THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
			  FND_MESSAGE.set_token('ID',to_char(p_Attr_Principal_rec.Attr_Principal_ID) );
			  FND_MESSAGE.set_token('ENTITY','Attr_Principal');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

 END check_uk_items;

 PROCEDURE check_req_items(
     p_Attr_Principal_rec IN  Attr_Principal_rec_type
    ,p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status       OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;
--DBMS_OUTPUT.PUT_LINE('p_validation_mode = '||p_validation_mode);
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN

--DBMS_OUTPUT.PUT_LINE('BEfore calling Attr_Principal_id');
--DBMS_OUTPUT.PUT_LINE('p_Attr_Principal_rec.Attr_Principal_id = '||
--                    TO_CHAR(p_Attr_Principal_rec.Attr_Principal_id));
       IF p_Attr_Principal_rec.Attr_Principal_id = FND_API.g_miss_num
          OR p_Attr_Principal_rec.Attr_Principal_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','Attr_Principal_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.last_update_date = FND_API.g_miss_date
          OR p_Attr_Principal_rec.last_update_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_update_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.last_updated_by = FND_API.g_miss_num
          OR p_Attr_Principal_rec.last_updated_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_updated_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.creation_date = FND_API.g_miss_date
          OR p_Attr_Principal_rec.creation_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','creation_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.created_by = FND_API.g_miss_num
          OR p_Attr_Principal_rec.created_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','created_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.object_version_number = FND_API.g_miss_num
          OR p_Attr_Principal_rec.object_version_number IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','object_version_number');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;



       IF p_Attr_Principal_rec.attribute_id = FND_API.g_miss_num
          OR p_Attr_Principal_rec.attribute_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','attribute_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.jtf_auth_principal_id = FND_API.g_miss_num
          OR p_Attr_Principal_rec.jtf_auth_principal_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','jtf_auth_principal_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
    ELSE

       IF p_Attr_Principal_rec.Attr_Principal_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','Attr_Principal_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.last_update_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_update_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.last_updated_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','last_updated_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.creation_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','creation_date');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.created_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','created_by');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.object_version_number IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','object_version_number');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.attribute_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','attribute_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

       IF p_Attr_Principal_rec.jtf_auth_principal_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','enabled_flag');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
    END IF;

 END check_req_items;

 PROCEDURE check_FK_items(
     p_Attr_Principal_rec IN Attr_Principal_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_FK_items;

 PROCEDURE check_Lookup_items(
     p_Attr_Principal_rec IN Attr_Principal_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_Lookup_items;

 PROCEDURE Check_Attr_Principal_Items (
     p_Attr_Principal_rec     IN   Attr_Principal_rec_type
    ,p_validation_mode         IN   VARCHAR2
    ,x_return_status           OUT NOCOPY  VARCHAR2
    )
 IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Check_Attr_Usage_Items';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 BEGIN

    -- Check Items Uniqueness API calls
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_uk_items' );
    check_uk_items(
       p_Attr_Principal_rec => p_Attr_Principal_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    -- Check Items Required/NOT NULL API calls
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_req_items' );
    check_req_items(
       p_Attr_Principal_rec => p_Attr_Principal_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- Check Items Foreign Keys API calls
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_FK_items' );
    check_FK_items(
       p_Attr_Principal_rec => p_Attr_Principal_rec
      ,x_return_status       => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- Check Items Lookups
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_Lookup_items' );
    check_Lookup_items(
       p_Attr_Principal_rec => p_Attr_Principal_rec
      ,x_return_status => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

 END Check_Attr_Principal_Items;



 PROCEDURE Complete_Attr_Principal_Rec (
    p_Attr_Principal_rec IN Attr_Principal_rec_type
   ,x_complete_rec OUT NOCOPY Attr_Principal_rec_type
   )
 IS
    l_return_status  VARCHAR2(1);

    CURSOR c_complete IS
       SELECT *
       FROM pv_Attr_Principals
       WHERE Attr_Principal_id = p_Attr_Principal_rec.Attr_Principal_id;
    l_Attr_Principal_rec c_complete%ROWTYPE;
 BEGIN
    x_complete_rec := p_Attr_Principal_rec;

    OPEN c_complete;
    FETCH c_complete INTO l_Attr_Principal_rec;
    CLOSE c_complete;

    -- Attr_Principal_id
    IF p_Attr_Principal_rec.Attr_Principal_id = FND_API.g_miss_num THEN
       x_complete_rec.Attr_Principal_id := l_Attr_Principal_rec.Attr_Principal_id;
    END IF;

    -- last_update_date
    IF p_Attr_Principal_rec.last_update_date = FND_API.g_miss_date THEN
       x_complete_rec.last_update_date := l_Attr_Principal_rec.last_update_date;
    END IF;

    -- last_updated_by
    IF p_Attr_Principal_rec.last_updated_by = FND_API.g_miss_num THEN
       x_complete_rec.last_updated_by := l_Attr_Principal_rec.last_updated_by;
    END IF;

    -- creation_date
    IF p_Attr_Principal_rec.creation_date = FND_API.g_miss_date THEN
       x_complete_rec.creation_date := l_Attr_Principal_rec.creation_date;
    END IF;

    -- created_by
    IF p_Attr_Principal_rec.created_by = FND_API.g_miss_num THEN
       x_complete_rec.created_by := l_Attr_Principal_rec.created_by;
    END IF;

    -- last_update_login
    IF p_Attr_Principal_rec.last_update_login = FND_API.g_miss_num THEN
       x_complete_rec.last_update_login := l_Attr_Principal_rec.last_update_login;
    END IF;


    -- object_version_number
    IF p_Attr_Principal_rec.object_version_number = FND_API.g_miss_num THEN
       x_complete_rec.object_version_number := l_Attr_Principal_rec.object_version_number;
    END IF;

    -- attribute_id
    IF p_Attr_Principal_rec.attribute_id = FND_API.g_miss_num THEN
       x_complete_rec.attribute_id := l_Attr_Principal_rec.attribute_id;
    END IF;

    -- jtf_auth_principal_id
    IF p_Attr_Principal_rec.jtf_auth_principal_id = FND_API.g_miss_num THEN
       x_complete_rec.jtf_auth_principal_id := l_Attr_Principal_rec.jtf_auth_principal_id;
    END IF;

    -- security_group_id
    --IF p_Attr_Principal_rec.security_group_id = FND_API.g_miss_num THEN
    --   x_complete_rec.security_group_id := l_Attr_Principal_rec.security_group_id;
    --END IF;
    -- Note: Developers need to modify the procedure
    -- to handle any business specific requirements.
 END Complete_Attr_Principal_Rec;

 PROCEDURE Validate_Attr_Principal(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )
  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Attr_Principal';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_Attr_Principal_rec  PV_Attr_Principal_PVT.Attr_Principal_rec_type;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT VALIDATE_Attr_Principal;

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
       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
               Check_Attr_Principal_Items(
                  p_Attr_Principal_rec => p_Attr_Principal_rec
                 ,p_validation_mode     => p_validation_mode
                 ,x_return_status       => x_return_status
                 );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;
       Complete_Attr_Principal_Rec(
          p_Attr_Principal_rec => p_Attr_Principal_rec
         ,x_complete_rec        => l_Attr_Principal_rec
       );
       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
       Validate_Attr_Principal_Rec(
            p_api_version_number  => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,x_return_status       => x_return_status
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           ,p_Attr_Principal_rec => l_Attr_Principal_rec
           ,p_validation_mode     => p_validation_mode
           );

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_Attr_Principal;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_Attr_Principal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_Attr_Principal;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Validate_Attr_Principal;


 PROCEDURE Validate_Attr_Principal_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_Attr_Principal_rec        IN   Attr_Principal_rec_type
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    )
 IS
 BEGIN
       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list )
       THEN
          FND_MSG_PUB.initialize;
       END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Hint: Validate data
       -- If data not valid
       -- THEN
       -- x_return_status := FND_API.G_RET_STS_ERROR;

       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	   PVX_Utility_PVT.debug_message('Private API: Validate_dm_model_rec');
	   END IF;
       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 END Validate_Attr_Principal_Rec;

 END PV_Attr_Principal_PVT;

/
