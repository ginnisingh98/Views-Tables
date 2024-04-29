--------------------------------------------------------
--  DDL for Package Body CSD_RO_BULLETINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RO_BULLETINS_PVT" as
/* $Header: csdvrobb.pls 120.5.12010000.4 2008/11/18 20:46:49 swai ship $ */
-- Start of Comments
-- Package name     : CSD_RO_BULLETINS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSD_RO_BULLETINS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvrobb.pls';

-- Global variable for storing the debug level
G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  CREATE_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_RO_BULLETIN_Rec         IN   CSD_RO_BULLETIN_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--       x_RO_BULLETIN_ID          OUT  NOCOPY NUMBER
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE CREATE_RO_BULLETIN(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_ro_bulletin_rec            IN   RO_BULLETIN_REC_TYPE,
   x_ro_bulletin_id             OUT  NOCOPY NUMBER,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2
) IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'CREATE_RO_BULLETINS';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;
BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT CREATE_RO_BULLETIN_PVT;

   --* Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                        p_api_version_number,
                                        c_API_NAME,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --* Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   --* Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --* logic starts here *--


   --* Invoke table handler(CSD_RO_BULLETINS_PKG.Insert_Row)
   CSD_RO_BULLETINS_PKG.INSERT_ROW(
       px_ro_bulletin_id  => x_ro_bulletin_id
      ,p_repair_line_id  => p_ro_bulletin_rec.repair_line_id
      ,p_bulletin_id  => p_ro_bulletin_rec.bulletin_id
      ,p_last_viewed_date  => p_ro_bulletin_rec.last_viewed_date
      ,p_last_viewed_by  => p_ro_bulletin_rec.last_viewed_by
      ,p_source_type  => p_ro_bulletin_rec.source_type
      ,p_source_id  => p_ro_bulletin_rec.source_id
      ,p_object_version_number  => p_ro_bulletin_rec.object_version_number
      ,p_created_by  => FND_GLOBAL.USER_ID
      ,p_creation_date  => sysdate
      ,p_last_updated_by  => FND_GLOBAL.USER_ID
      ,p_last_update_date  => sysdate
      ,p_last_update_login  => FND_GLOBAL.LOGIN_ID);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --* logic ends here *--

   --* Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   --* Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_SQLCODE => SQLCODE
            ,P_SQLERRM => SQLERRM
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
END CREATE_RO_BULLETIN;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  UPDATE_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_RO_BULLETIN_Rec         IN   RO_BULLETIN_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE UPDATE_RO_BULLETIN(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_ro_bulletin_rec            IN   RO_BULLETIN_Rec_Type,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2
) IS

   ---- cursors ----
   CURSOR cur_get_ro_bulletin(p_ro_bulletin_id Number) IS
     SELECT ro_bulletin_id,
            repair_line_id,
            bulletin_id,
            last_viewed_date,
            last_viewed_by,
            source_type,
            source_id,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
      FROM  csd_ro_bulletins
      WHERE ro_bulletin_id = p_ro_bulletin_id
      FOR UPDATE NOWAIT;

   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'UPDATE_RO_BULLETIN';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;

   ---- Local Variables ----
   l_ref_ro_bulletin_rec RO_BULLETIN_REC_TYPE;
   l_rowid               ROWID;
BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT UPDATE_RO_BULLETIN_PVT;

   --* Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                        p_api_version_number,
                                        c_API_NAME,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --* Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
       FND_MSG_PUB.initialize;
   END IF;

   --* Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --* logic starts here *--

   OPEN cur_get_ro_bulletin( p_ro_bulletin_rec.RO_BULLETIN_ID);
   FETCH cur_get_ro_bulletin INTO
      l_ref_ro_bulletin_rec.ro_bulletin_id,
      l_ref_ro_bulletin_rec.repair_line_id,
      l_ref_ro_bulletin_rec.bulletin_id,
      l_ref_ro_bulletin_rec.last_viewed_date,
      l_ref_ro_bulletin_rec.last_viewed_by,
      l_ref_ro_bulletin_rec.source_type,
      l_ref_ro_bulletin_rec.source_id,
      l_ref_ro_bulletin_rec.object_version_number,
      l_ref_ro_bulletin_rec.created_by,
      l_ref_ro_bulletin_rec.creation_date,
      l_ref_ro_bulletin_rec.last_updated_by,
      l_ref_ro_bulletin_rec.last_update_date,
      l_ref_ro_bulletin_rec.last_update_login;

  IF ( cur_get_ro_bulletin%NOTFOUND) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('CSD', 'CSD_RO_BTNS_NO_RECORD_FOUND'); -- no record is returned for the query
        FND_MESSAGE.set_token( 'BULLETIN_ID', p_ro_bulletin_rec.RO_BULLETIN_ID);
        FND_MSG_PUB.Add;
     END IF;
     CLOSE cur_get_ro_bulletin;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE cur_get_ro_bulletin;

  --* NOTE: add validation logic here if needed


  --* Invoke table handler(CSD_RO_BULLETINS_PKG.Update_Row)
  CSD_RO_BULLETINS_PKG.UPDATE_ROW(
     p_ro_bulletin_id         => p_ro_bulletin_rec.ro_bulletin_id
    ,p_repair_line_id         => p_ro_bulletin_rec.repair_line_id
    ,p_bulletin_id            => p_ro_bulletin_rec.bulletin_id
    ,p_last_viewed_date       => p_ro_bulletin_rec.last_viewed_date
    ,p_last_viewed_by         => p_ro_bulletin_rec.last_viewed_by
    ,p_source_type            => p_ro_bulletin_rec.source_type
    ,p_source_id              => p_ro_bulletin_rec.source_id
    ,p_object_version_number  => p_ro_bulletin_rec.object_version_number
    ,p_created_by             => FND_API.G_MISS_NUM
    ,p_creation_date          => FND_API.G_MISS_DATE
    ,p_last_updated_by        => FND_GLOBAL.USER_ID
    ,p_last_update_date       => SYSDATE
    ,p_last_update_login      => p_ro_bulletin_rec.last_update_login);

  --* logic ends here *--

  --* Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;


  --* Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
           ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);
END UPDATE_RO_BULLETIN;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  DELETE_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ro_bulletin_id          IN   NUMBER     Required
--
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE DELETE_RO_BULLETIN(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_ro_bulletin_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
 ) IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'DELETE_RO_BULLETIN';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;

BEGIN
  --* Standard Start of API savepoint
  SAVEPOINT DELETE_RO_BULLETIN_PVT;

  --* Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                       p_api_version_number,
                                       c_API_NAME,
                                       G_PKG_NAME)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --* Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  --* Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --* logic starts here *--

  --* Invoke table handler(CSD_RO_BULLETINS_PKG.Delete_Row)
  CSD_RO_BULLETINS_PKG.DELETE_ROW(p_ro_bulletin_id  => p_ro_bulletin_id);


  -- logic ends here *--

  --* Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;


  --* Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
           ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);
End DELETE_RO_BULLETIN;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  LOCK_RO_BULLETIN
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ro_bulletin_rec         IN   RO_BULLETIN_REC_TYPE  Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History: Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE LOCK_RO_BULLETIN(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_ro_bulletin_rec            IN   RO_BULLETIN_Rec_Type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
)IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'LOCK_RO_BULLETIN';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;

BEGIN
  --* Standard Start of API savepoint
  SAVEPOINT DELETE_RO_BULLETIN_PVT;

  --* Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                       p_api_version_number,
                                       c_API_NAME,
                                       G_PKG_NAME)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --* Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  --* Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --* logic starts here *--

  -- Invoke table handler(CSD_RO_BULLETINS_PKG.Lock_Row)
  CSD_RO_BULLETINS_PKG.LOCK_ROW(
      p_ro_bulletin_id  => p_ro_bulletin_rec.ro_bulletin_id
     ,p_object_version_number  => p_ro_bulletin_rec.object_version_number);

  --* logic ends here *--

  --* Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;


  --* Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
           ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);
END LOCK_RO_BULLETIN;



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  LINK_BULLETINS_TO_RO
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_repair_line_id          IN   NUMBER     Required
--       px_ro_sc_ids_tbl          IN OUT NOCOPY   CSD_RO_SC_IDS_TBL_TYPE Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History:  Jan-16-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE LINK_BULLETINS_TO_RO(
   p_api_version_number         IN            NUMBER,
   p_init_msg_list              IN            VARCHAR2   := FND_API.G_FALSE,
   p_commit                     IN            VARCHAR2   := FND_API.G_FALSE,
   p_validation_level           IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
   p_repair_line_id             IN            NUMBER,
   px_ro_sc_ids_tbl             IN OUT NOCOPY CSD_RO_SC_IDS_TBL_TYPE,
   x_return_status              OUT    NOCOPY VARCHAR2,
   x_msg_count                  OUT    NOCOPY NUMBER,
   x_msg_data                   OUT    NOCOPY VARCHAR2
) IS
   ---- local constants ----
   c_API_NAME                CONSTANT VARCHAR2(30) := 'LINK_BULLETINS_TO_RO';
   c_API_VERSION_NUMBER      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;

   ---- local viariables ----
   l_ro_bulletin_id    NUMBER         := NULL;
   l_rule_matching_rec CSD_RULES_ENGINE_PVT.CSD_RULE_MATCHING_REC_TYPE;
   l_rule_input_rec    CSD_RULES_ENGINE_PVT.CSD_RULE_INPUT_REC_TYPE;
   l_bulletin_id       NUMBER         := NULL;
   l_rule_id           NUMBER         := NULL;
   l_rule_results_tbl  CSD_RULES_ENGINE_PVT.CSD_RULE_RESULTS_TBL_TYPE;
   l_rule_results_rec  CSD_RULES_ENGINE_PVT.CSD_RULE_RESULTS_REC_TYPE;
   l_rec_ind           INTEGER        := NULL;
   l_repln_rec         CSD_REPAIRS_PUB.REPLN_Rec_Type;

BEGIN
  --* Standard Start of API savepoint
  SAVEPOINT LINK_BULLETINS_TO_RO_PVT;

  --* Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                       p_api_version_number,
                                       c_API_NAME,
                                       G_PKG_NAME)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --* Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;

  --* Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --* logic starts here *--

  --* first update bulletin check date via pvt
  l_repln_rec.bulletin_check_date := sysdate;

  --** debug starts!!
  --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK bulletin_check_date = ' || l_repln_rec.bulletin_check_date);
  --** debug ends!!

  l_repln_rec.object_version_number := GET_CSD_REPAIRS_OBJ_VER_NUM(p_repair_line_id);
  CSD_REPAIRS_PVT.update_repair_order(
      p_api_version_number     => p_api_version_number,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      p_validation_level       => p_validation_level,
      p_repair_line_id         => p_repair_line_id,
      p_repln_rec              => l_repln_rec,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('CSD', 'CSD_UPDATE_REPAIR_FAILED');
        FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF; --* end IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) *--

  /*  BEGIN: Algorithm:
  *   (1) init l_rule_matching_rec with
  *       l_rule_matching_rec.rule_match_code := CSD_RULES_ENGINE_PVT.G_RULE_MATCH_ALL;
  *       l_rule_matching_rec.rule_type := CSD_RULES_ENGINE_PVT.G_RULE_TYPE_BULLETIN;
  *       l_rule_matching_rec.rule_input_rec := l_rule_input_rec;
  *       l_rule_input_rec.repair_line_Id := p_repair_line_id;
  *   (2) call   CSD_RULES_ENGINE_PVT.PROCESS_RULE_MATCHING(
  *                       p_api_version         => p_api_version,
  *                       p_commit              => p_commit,
  *                       p_init_msg_list       => p_init_msg_list,
  *                       p_validation_level    => p_validation_level,
  *                       px_rule_matching_rec  => l_rule_matching_rec,
  *                       x_return_status       => l_return_status,
  *                       x_msg_count           => x_msg_count,
  *                       x_msg_data            => x_msg_data);
  *   (3) FOR EACH rule_results_rec in rule_results_tbl  LOOP
  *          IF Bulletin is active and published THEN
  *             IF freq_code = ONE_REPAIR THEN
  *                IF (NOT exists in csd_ro_bulletins check based on repair ) THEN
  *                   Call Create new link procecure
  *                END IF;
  *             ELSIF freq_code = ONE_INSTANCE THEN
  *                IF (NOT exists in csd_ro_bulletins check based on instance) THEN
  *                   Call Create new link proceure
  *                END IF;
  *             END IF;
  *          END IF;
  *       END LOOP;
  *   (4) Create new link procedure:
  *       - adds a new rec in csd_ro_bulletins
  *       - adds ro service codes id to ro services codes table
  *       - check if escalated, if yes, place holder for setting escalated on RO
  *       - check if work flow, if yes, place holder for launching workflow
  *       - add associated SCs to SC list
  *   END: Algorithm */
  --* init l_rule_matching_rec
  l_rule_matching_rec.rule_match_code := CSD_RULES_ENGINE_PVT.G_RULE_MATCH_ALL;
  l_rule_matching_rec.rule_type := CSD_RULES_ENGINE_PVT.G_RULE_TYPE_BULLETIN;

  l_rule_input_rec.repair_line_Id := p_repair_line_id; -- must assign this val to rec first
  l_rule_matching_rec.rule_input_rec := l_rule_input_rec;


  CSD_RULES_ENGINE_PVT.PROCESS_RULE_MATCHING(
        p_api_version_number  => p_api_version_number,
        p_commit              => p_commit,
        p_init_msg_list       => p_init_msg_list,
        p_validation_level    => p_validation_level,
        px_rule_matching_rec  => l_rule_matching_rec,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
   );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('CSD', 'CSD_RULE_MATCH_FAILED');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --** debug starts!!
  --dbms_output.put_line('in LINK_BULLETINS_TO_RO x_return_status = ' || x_return_status);
  --** debug ends!!


  l_rule_results_tbl := l_rule_matching_rec.RULE_RESULTS_TBL;

  l_rec_ind := l_rule_results_tbl.FIRST;

  --** debug starts!!
  --dbms_output.put_line('in LINK_BULLETINS_TO_RO l_rec_ind = ' || l_rec_ind);
  --** debug ends!!

  LOOP
     EXIT WHEN l_rec_ind IS NULL;
     l_rule_results_rec := l_rule_results_tbl(l_rec_ind);
     --* loop logic begins
     l_bulletin_id := l_rule_results_rec.defaulting_value;
     l_rule_id := l_rule_results_rec.rule_id;
     --** debug starts!!
     --dbms_output.put_line('in LINK_BULLETINS_TO_RO LOOP p_repair_line_id = ' || p_repair_line_id);
     --dbms_output.put_line('in LINK_BULLETINS_TO_RO LOOP l_bulletin_id = ' || l_bulletin_id);
     --dbms_output.put_line('in LINK_BULLETINS_TO_RO LOOP l_rule_id = ' || l_rule_id);
     --** debug ends!!

     CREATE_NEW_RO_BULLETIN_LINK(
         p_api_version_number  => p_api_version_number,
         p_commit              => p_commit,
         p_init_msg_list       => p_init_msg_list,
         p_validation_level    => p_validation_level,
         p_repair_line_id      => p_repair_line_id,
         p_bulletin_id         => l_bulletin_id,
         p_rule_id             => l_rule_id,
         px_ro_sc_ids_tbl      => px_ro_sc_ids_tbl,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data
     );
     --** debug starts!!
     -- dbms_output.put_line('in LINK_BULLETINS_TO_RO ONE_REPAIR - after create new link, x_return_status =  ' || x_return_status);
     --** debug ends!!
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('CSD', 'CSD_CREATE_RO_BLTN_LINK_FAILED');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
     END IF; -- end IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN --
     --* loop logic ends

     l_rec_ind := l_rule_results_tbl.NEXT(l_rec_ind);
  END LOOP; --* END loop that loops through all recs in the tbl *--
  --* logic ends here *--

  --* Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  --* Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
            P_API_NAME => c_API_NAME
           ,P_PKG_NAME => G_PKG_NAME
           ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
           ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
           ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS);
END LINK_BULLETINS_TO_RO;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  CREATE_NEW_RO_BULLETIN_LINK
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_repair_line_id          IN   NUMBER     Required
--       p_bulletin_id             IN   NUMBER     Required
--       px_sc_ids_tbl             IN OUT NOCOPY  CSD_RO_SC_IDS_TBL_TYPE Required
--   OUT:
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY VARCHAR2
--   History:  Jan-17-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
PROCEDURE CREATE_NEW_RO_BULLETIN_LINK(
   p_api_version_number  IN            NUMBER,
   p_commit              IN            VARCHAR2,
   p_init_msg_list       IN            VARCHAR2,
   p_validation_level    IN            NUMBER,
   p_repair_line_id      IN            NUMBER,
   p_bulletin_id         IN            NUMBER,
   p_rule_id             IN            NUMBER,
   px_ro_sc_ids_tbl      IN OUT NOCOPY CSD_RO_SC_IDS_TBL_TYPE,
   x_return_status       OUT    NOCOPY VARCHAR2,
   x_msg_count           OUT    NOCOPY NUMBER,
   x_msg_data            OUT    NOCOPY VARCHAR2
) IS
   ---- local constants ----
   c_api_name                CONSTANT VARCHAR2(30) := 'CREATE_NEW_RO_BULLETIN_LINK';
   c_api_version_number      CONSTANT NUMBER       := G_L_API_VERSION_NUMBER;
   -- For setting WF engine threshold
   c_wf_negative_threshold   CONSTANT NUMBER        := -1;

   ---- local variables ----
   l_ro_bulletin_rec      RO_BULLETIN_REC_TYPE;
   l_ro_bulletin_id       NUMBER                := NULL;
   l_tbl_ind              NUMBER                := NULL;
   l_escalation_code      VARCHAR2(30)          := NULL;
   l_wf_item_type         VARCHAR2(8)           := NULL;
   l_wf_process_name      VARCHAR2(30)          := NULL;
   l_wf_item_key          VARCHAR2(240)         := NULL;
   l_wf_current_threshold NUMBER                := NULL;
   l_repln_rec            CSD_REPAIRS_PUB.REPLN_Rec_Type;
   l_instance_id          NUMBER                := NULL;
   l_freq_code            VARCHAR2(30)          := NULL;
   l_create_new_ro_bulletin_link VARCHAR2(1)    := FND_API.G_FALSE;

   ---- cursors ----

   CURSOR cur_get_bulletin_info(p_bulletin_id NUMBER) IS
      SELECT escalation_code,
             wf_item_type,
             wf_process_name
      FROM   csd_bulletins_b
      WHERE  bulletin_id = p_bulletin_id
   ; --* end cur_get_bulletin_info *--

   --* get service bulletin ids for this bulletin that has been linked *--
   --* to an RO                                                        *--
   CURSOR cur_get_ro_sc_ids(p_bulletin_id NUMBER) IS
      SELECT b.service_code_id
      FROM   csd_bulletins_b a, csd_bulletin_scs b
      WHERE  a.bulletin_id = b.bulletin_id
      AND    a.bulletin_id = p_bulletin_id
   ; --* end cur_get_ro_sc_ids *--
   ro_sc_id_rec cur_get_ro_sc_ids%ROWTYPE;

   -- swai: move cursors to this procedure since bulletin check
   -- has been moved to this procedure.

   --* returns freq_code of only if bulletin is active *--
   --*    and published                                *--
   CURSOR cur_get_bulletin_freq_code(p_bulletin_id NUMBER) IS
      SELECT frequency_code
      FROM  csd_bulletins_b
      WHERE bulletin_id = p_bulletin_id
      AND   published_flag = FND_API.G_TRUE
      AND   sysdate BETWEEN NVL(active_from,sysdate)
                    AND     NVL(active_to, sysdate)
   ; --* end CURSOR cur_get_bulletin_freq_code *--

   --* returns ro_bulletin_id in csd_ro_bulletins *--
   --* based on repair_line_id                    *--
   CURSOR cur_check_by_repair(p_repair_line_id NUMBER,
                              p_bulletin_id    NUMBER) IS
      SELECT a.ro_bulletin_id
      FROM   csd_ro_bulletins a
      WHERE  a.repair_line_id = p_repair_line_id
      AND    a.bulletin_id = p_bulletin_id
   ; --* end CURSOR cur_check_by_repair *--

   CURSOR cur_check_by_instance(p_instance_id NUMBER,
                                p_bulletin_id NUMBER) IS
      SELECT a.ro_bulletin_id
      FROM   csd_ro_bulletins a
      WHERE  a.repair_line_id IN
               (SELECT repair_line_id
                FROM   csd_repairs
                WHERE  customer_product_id = p_instance_id)
      AND    a.bulletin_id = p_bulletin_id
   ; --* end cur_check_by_instance *--
BEGIN
   --* Standard Start of API savepoint
   SAVEPOINT CREATE_NEW_RO_BLTN_LINK_PVT;

   --* Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( c_API_VERSION_NUMBER,
                                        p_api_version_number,
                                        c_API_NAME,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --* Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   --* Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN cur_get_bulletin_freq_code(p_bulletin_id); -- get freq code of active, published bulletins
   FETCH cur_get_bulletin_freq_code
      INTO l_freq_code;
   --** debug starts!!
   --dbms_output.put_line('in LINK_BULLETINS_TO_RO LOOP l_freq_code = ' || l_freq_code);
   --** debug ends!!

   -- swai: relocated code for checking bulletin frequency from LINK_BULLETINS_TO_RO
   -- to CREATE_NEW_RO_BULLETIN_LINK, since this logic is needed whenever linking
   -- a bulletin to an RO.
   IF ( cur_get_bulletin_freq_code%NOTFOUND) THEN -- not active, so go on to the next rec
      CLOSE cur_get_bulletin_freq_code;
   ELSE
      CLOSE cur_get_bulletin_freq_code;
      IF (l_freq_code = G_FREQ_ONE_REPAIR) THEN
         OPEN cur_check_by_repair(p_repair_line_id, p_bulletin_id);
         FETCH cur_check_by_repair INTO l_ro_bulletin_id;
         --** debug starts!!
         --dbms_output.put_line('in LINK_BULLETINS_TO_RO ONE_REPAIR - before l_ro_bulletin_id' ||  l_ro_bulletin_id);
         --** debug ends!!

         IF ( cur_check_by_repair%NOTFOUND) THEN -- does not exist, so create new link
            --** debug starts!!
            --dbms_output.put_line('in LINK_BULLETINS_TO_RO ONE_REPAIR - not found');
            --** debug ends!!
            l_create_new_ro_bulletin_link := FND_API.G_TRUE;
         END IF; -- end IF ( cur_check_by_repair%NOTFOUND) THEN --
         CLOSE cur_check_by_repair; -- close cursor
      ELSIF (l_freq_code = G_FREQ_ONE_INSTANCE) THEN
         l_instance_id := CSD_RULES_ENGINE_PVT.GET_RO_INSTANCE_ID(p_repair_line_id);
         --** debug starts!!
         --dbms_output.put_line('in LINK_BULLETINS_TO_RO INSTANCE - l_instance_id =  ' || l_instance_id);
         --** debug ends!!

         IF (l_instance_id IS NOT NULL) AND (l_instance_Id <> FND_API.G_MISS_NUM) THEN
            OPEN cur_check_by_instance(l_instance_id, p_bulletin_id);
            FETCH cur_check_by_instance INTO l_ro_bulletin_id;

            --** debug starts!!
            --dbms_output.put_line('in LINK_BULLETINS_TO_RO INSTANCE - l_ro_bulletin_id =  ' || l_ro_bulletin_id );
            --** debug ends!!

            --** debug starts!!
            --dbms_output.put_line('in LINK_BULLETINS_TO_RO found ONE_INSTANCE - l_instance_id = ' ||  l_instance_id);
            --dbms_output.put_line('in LINK_BULLETINS_TO_RO found ONE_INSTANCE - p_bulletin_id = ' ||  p_bulletin_id);
            --dbms_output.put_line('in LINK_BULLETINS_TO_RO found ONE_INSTANCE - before l_ro_bulletin_id = ' ||  l_ro_bulletin_id);
            --** debug ends!!

            IF ( cur_check_by_instance%NOTFOUND) THEN
               --** debug starts!!
               --dbms_output.put_line('in LINK_BULLETINS_TO_RO ONE_INSTANCE - before create_new_ro_bulletin_link ');
               --** debug ends!!
               l_create_new_ro_bulletin_link := FND_API.G_TRUE;
            END IF; --* end IF ( cur_check_by_instance%NOTFOUND) *--
            CLOSE cur_check_by_instance; -- close cursor
         END IF; --* end (l_instance_id IS NOT NULL)... *--
      ELSE --* unrecognized code
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; --* end IF (l_freq_code = G_FREQ_ONE_REPAIR)  *--
   END IF; --* end IF ( cur_get_bulletin_freq_code%NOTFOUND) *--

   --* logic starts here *--
   /*   BEGIN: Algorithm
   *   (1) adds a new rec in csd_ro_bulletins
   *       create l_ro_bulletin_rec
   *       create_ro_bulletin
   *   (2) adds ro service codes id to ro services codes table
   *       cur_get_ro_sc_ids(service_code_id, repair_line_id)
   *   (3) check if escalated, if yes, place holder for setting escalated on RO
   *       cur_get_bulletin_info
   *   (4) check if work flow, if yes, place holder for launching workflow
   *       cur_get_bulletin_info
   *   (5) add associated SCs to SC list
   *   END: Algorithm */
 IF (l_create_new_ro_bulletin_link = FND_API.G_TRUE) THEN
   --* link ro bulletin
   l_ro_bulletin_rec.repair_line_id        := p_repair_line_id;
   l_ro_bulletin_rec.bulletin_id           := p_bulletin_id;
   l_ro_bulletin_rec.source_type           := G_SOURCE_TYPE_RULE;
   l_ro_bulletin_rec.source_id             := p_rule_id;
   l_ro_bulletin_rec.object_version_number := G_OBJ_VERSION_NUMBER_1;
   l_ro_bulletin_rec.last_update_login     := FND_GLOBAL.USER_ID;

   CREATE_RO_BULLETIN(
      p_api_version_number => p_api_version_number,
      p_init_msg_list      => p_init_msg_list,
      p_commit             => p_commit,
      p_validation_level   => p_validation_level,
      p_ro_bulletin_rec    => l_ro_bulletin_rec,
      x_ro_bulletin_id     => l_ro_bulletin_id,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('CSD', 'CSD_CREATE_RO_BLTN_FAILED');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; --* end IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) *--

   --* ##################Call csd_repairs_pvt to update Bulletin check date

   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK x_return_status = ' || x_return_status);
   --** debug ends!!

   --* get ro service codes (sc) ids and append to table
   --* cursor for loop, cursor is implicitly open/closed
   l_tbl_ind := px_ro_sc_ids_tbl.COUNT;
   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK before scs loop l_tbl_ind = ' || l_tbl_ind);
   --** debug ends!!
   FOR ro_sc_id_rec IN cur_get_ro_sc_ids(p_bulletin_id)
   LOOP
      l_tbl_ind := l_tbl_ind+1;
      px_ro_sc_ids_tbl(l_tbl_ind) := ro_sc_id_rec.service_code_id;
      --** debug starts!!
      --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK during scs loop sc = ' || ro_sc_id_rec.service_code_id);
      --** debug ends!!

   END LOOP;

   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK after scs loop ');
   --** debug ends!!


   --* get escalation/workflow info, place holder for logic later
   OPEN cur_get_bulletin_info(p_bulletin_id);
   FETCH cur_get_bulletin_info
   INTO l_escalation_code,
        l_wf_item_type,
        l_wf_process_name;
   CLOSE cur_get_bulletin_info;

   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK l_escalation_code = ' || l_escalation_code);
   --** debug ends!!

   --* update csd_repairs with escalation_code
   --*  via csd_repairs_pvt


   IF (l_escalation_code IS NOT NULL ) THEN --* pass in when not null
      l_repln_rec.escalation_code := l_escalation_code;
   ELSE
      l_repln_rec.escalation_code := FND_API.G_MISS_CHAR; --* don't wipe out old value
   END IF; --* end IF (l_escalation_code IS NOT NULL ) *--

   l_repln_rec.object_version_number := GET_CSD_REPAIRS_OBJ_VER_NUM(p_repair_line_id);


   CSD_REPAIRS_PVT.update_repair_order(
      p_api_version_number     => p_api_version_number,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      p_validation_level       => p_validation_level,
      p_repair_line_id         => p_repair_line_id,
      p_repln_rec              => l_repln_rec,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('CSD', 'CSD_UPDATE_REPAIR_FAILED');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF; --* end IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) *--



   --* launch workflow
   IF (l_wf_item_type IS NOT NULL) THEN
      SELECT TO_CHAR(CSD_WF_ITEM_KEY_S.NEXTVAL)
                INTO l_wf_item_key
                FROM DUAL;

      --* Get the current threshold
      l_wf_current_threshold := Wf_Engine.threshold;

      --* Defer the wf process
      Wf_Engine.threshold := c_wf_negative_threshold;


      Wf_Engine.CreateProcess(itemtype => l_wf_item_type,
                              itemkey  => l_wf_item_key,
                              process  => l_wf_process_name --,
                              -- user_key => NULL,
                              -- owner_role => NULL
                              );

      Wf_Engine.StartProcess(itemtype => l_wf_item_type,
                             itemkey  => l_wf_item_key
                             );


      --* Set engine to orginal threshold.
      --* Otherwise all WF process in this session will be deferred.
      Wf_Engine.threshold := l_wf_current_threshold;
   END IF; --* end IF (l_wf_item_type IS NOT NULL) *--

   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK after get_bulletin_info ');
   --** debug ends!!

 END IF; --* end IF (l_create_new_ro_bulletin_link = FND_API.G_TRUE) *--
   --* logic ends here *--

   --* Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK after check for p_commit ');
   --** debug ends!!

   --* Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   --** debug starts!!
   --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK after count_and_get x_return_statu =  ' || x_return_status);
   --** debug ends!!

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --** debug starts!!
         --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK exception 1 ');
         --** debug ends!!

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --** debug starts!!
         --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK exception 2 ');
         --** debug ends!!

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         --** debug starts!!
         --dbms_output.put_line('in CREATE_NEW_RO_BULLETIN_LINK exception 3 ');
         --** debug ends!!

         JTF_PLSQL_API.HANDLE_EXCEPTIONS(
             P_API_NAME => c_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
            ,P_SQLCODE => SQLCODE
            ,P_SQLERRM => SQLERRM
            ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
END CREATE_NEW_RO_BULLETIN_LINK;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  GET_CSD_REPAIRS_OBJ_VER_NUM
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_repair_line_id          IN   NUMBER     Required
--   OUT:
--       NUMBER obj_ver_num
--   History:  Jan-17-2008    rfieldma    created
-- -------------------
--   End of Comments
-- -------------------
FUNCTION GET_CSD_REPAIRS_OBJ_VER_NUM(
   p_repair_line_id      IN            NUMBER
) RETURN NUMBER IS
   ---- local vars ----
   l_obj_ver_num  NUMBER  := NULL;
   ---- cursors ----
   CURSOR cur_get_obj_ver_num(p_repair_line_id NUMBER) IS
      SELECT object_version_number
      FROM   csd_repairs
      WHERE  repair_line_id = p_repair_line_id
   ; --* end cur_get_obj_ver_num *--

BEGIN
   OPEN cur_get_obj_ver_num(p_repair_line_id);
   FETCH cur_get_obj_ver_num INTO l_obj_ver_num;
   CLOSE cur_get_obj_ver_num;

   RETURN l_obj_ver_num;
END GET_CSD_REPAIRS_OBJ_VER_NUM;


/*--------------------------------------------------------------------*/
/* procedure name: LINK_BULLETINS_TO_REPAIRS_CP                       */
/* description : Links all active bulletins to all matching repairs   */
/*                                                                    */
/* STANDARD PARAMETERS                                                */
/*  In Parameters :                                                   */
/*                                                                    */
/*  Output Parameters:                                                */
/*   errbuf              VARCHAR2      Error message                  */
/*   retcode             VARCHAR2      Error Code                     */
/*                                                                    */
/* NON-STANDARD PARAMETERS                                            */
/*   In Parameters                                                    */
/*    p_params   RO_BULLETIN_PARAMS_REC_TYPE   Req                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LINK_BULLETINS_TO_REPAIRS_CP (
    errbuf             OUT NOCOPY    varchar2,
    retcode            OUT NOCOPY    varchar2,
    --concurrent program parameters go here
    p_BULLETIN_TYPE_CODE IN   VARCHAR2      := NULL,
    p_RO_FLOW_STATUS_ID  IN   NUMBER        := NULL,
    p_RO_INV_ORG_ID      IN   NUMBER        := NULL,
    p_RO_REPAIR_ORG_ID   IN   NUMBER        := NULL,
    p_RO_INV_ITEM_ID     IN   NUMBER        := NULL
    )
IS
    -- CURSORS --
    CURSOR c_all_active_bulletins (p_bulletin_type_code varchar2)
    IS
    select bulletin_id
    from csd_bulletins_b
    where published_flag = 'T'
    and sysdate between nvl(active_from, sysdate-1) and nvl(active_to, sysdate+1)
    and bulletin_type_code = nvl(p_bulletin_type_code, bulletin_type_code);

    CURSOR c_bulletin_rules (p_bulletin_id number)
    IS
    select rule_id
    from CSD_RULES_B
    where attribute1 = p_bulletin_id
    and rule_type_code = 'BULLETIN';

    -- CONCURRENT PROGRAM RETURN STATUSES --
    l_success_status    CONSTANT VARCHAR2(1) := '0';
    l_warning_status    CONSTANT VARCHAR2(1) := '1';
    l_error_status      CONSTANT VARCHAR2(1) := '2';

    -- STANDARD API and DEBUG CONSTANTS --
    l_api_name          CONSTANT VARCHAR2(30)   := 'LINK_BULLETINS_TO_REPAIRS_CP';
    l_api_version       CONSTANT NUMBER         := 1.0;

    -- VARIABLES FOR FND LOG --
    l_error_level         NUMBER         := FND_LOG.LEVEL_ERROR;
    l_mod_name            VARCHAR2(2000) := 'csd.plsql.csd_ro_bulletins_pvt.link_bulletins_to_repairs_conc_prog';

    -- VARIABLES --
    l_return_status       VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(20000);
    l_current_bulletin_id NUMBER;
    l_bulletin_rule_id    NUMBER;
    l_cp_params           RO_BULLETIN_PARAMS_REC_TYPE;

BEGIN
    -- Initialize the error code and error buffer
    retcode := l_success_status;
    errbuf  := '';

    -- Initialize the l_cp_params
    l_cp_params.bulletin_type_code := p_bulletin_type_code;
    l_cp_params.ro_flow_status_id  := p_ro_flow_status_id;
    l_cp_params.ro_inv_org_id      := p_ro_inv_org_id;
    l_cp_params.ro_repair_org_id   := p_ro_repair_org_id;
    l_cp_params.ro_inv_item_id     := p_ro_inv_item_id;

    -- Debug messages
    --dbms_output.put_line('At the Beginning of link_bulletins_to_repairs_conc_prog');

    -- go through each active bulletin to link.
    OPEN c_all_active_bulletins(p_bulletin_type_code);
    LOOP
        FETCH c_all_active_bulletins INTO l_current_bulletin_id;
        EXIT when c_all_active_bulletins%NOTFOUND;

        -- go through each rule to link.
        OPEN c_bulletin_rules(l_current_bulletin_id);
        LOOP
            FETCH c_bulletin_rules INTO l_bulletin_rule_id;
            EXIT when c_bulletin_rules%NOTFOUND;

            -- Debug messages
            --dbms_output.put_line('Calling LINK_BULLETIN_FOR_RULE');
            l_return_status := FND_API.G_RET_STS_SUCCESS;

            LINK_BULLETIN_FOR_RULE(
                p_api_version_number   =>  l_api_version,
                p_commit               =>  FND_API.G_TRUE,
                p_init_msg_list        =>  FND_API.G_TRUE,
                p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
                x_return_status        =>  l_return_status,
                x_msg_count            =>  l_msg_count,
                x_msg_data             =>  l_msg_data,
                p_bulletin_id          =>  l_current_bulletin_id,
                p_bulletin_rule_id     =>  l_bulletin_rule_id,
                p_params               =>  l_cp_params
               );

            -- Debug messages
            --dbms_output.put_line('Return Status from LINK_BULLETIN_FOR_RULE :'||l_return_status);

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                -- Concatenate the message from the message stack
                IF l_msg_count > 1 then
                    FOR i IN 1..l_msg_count LOOP
                        l_msg_data := l_msg_data||FND_MSG_PUB.Get(i,FND_API.G_FALSE) ;
                    END LOOP ;
                END IF ;
                --dbms_output.put_line(l_msg_data);
                -- Do not exit out of loop:
                -- keep going, but set the retcode to record error status
                retcode := l_error_status;
                errbuf  := errbuf + l_msg_data;
            END IF;

        END LOOP;
        IF c_bulletin_rules%ISOPEN THEN
            close c_bulletin_rules;
        END IF;
    END LOOP;
    IF c_all_active_bulletins%ISOPEN THEN
        close c_all_active_bulletins;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       retcode := l_error_status;
       errbuf  := l_msg_data;
   WHEN Others then
       -- Handle others exception
       retcode := l_error_status;
       errbuf  := l_msg_data;
END LINK_BULLETINS_TO_REPAIRS_CP;


/*--------------------------------------------------------------------*/
/* procedure name: LINK_BULLETIN_FOR_RULE                             */
/* description : Given a single rule, find all matching repair orders */
/*               and link them to the given bulletin, if applicable   */
/*                                                                    */
/* Called from : PROCEDURE  LINK_BULLETINS_TO_ALL_REPAIRS             */
/* Input Parm  :                                                      */
/*    p_bulletin_id           NUMBER     Optional                     */
/*                                       If bulletin id is provided,  */
/*                                       it will be used without      */
/*                                       validaing against the rule   */
/*                                       If p_bulletin_id = null,     */
/*                                       bulletin_id will be derrived */
/*                                       from p_bulletin_rule_id      */
/*    p_bulletin_rule_id      NUMBER     Req                          */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LINK_BULLETIN_FOR_RULE (
    p_api_version_number   IN   NUMBER,
    p_commit               IN   VARCHAR2,
    p_init_msg_list        IN   VARCHAR2,
    p_validation_level     IN   NUMBER,
    x_return_status        OUT  NOCOPY  VARCHAR2,
    x_msg_count            OUT  NOCOPY  NUMBER,
    x_msg_data             OUT  NOCOPY  VARCHAR2,
    p_bulletin_id          IN   NUMBER := NULL,
    p_bulletin_rule_id     IN   NUMBER,
    p_params               IN   RO_BULLETIN_PARAMS_REC_TYPE
)
IS
    -- TYPE FOR DYNAMIC CURSOR --
    TYPE REPAIR_ORDER_CURSOR IS REF CURSOR;

    -- CURSORS --
    CURSOR c_get_bulletin_id (p_rule_id number)
    IS
    select to_number(attribute1) bulletin_id
    from CSD_RULES_B
    where rule_id = p_rule_id;


    -- STANDARD CONSTANTS
    l_api_name             CONSTANT VARCHAR2(30)   := 'LINK_BULLETIN_FOR_RULE';
    l_api_version          CONSTANT NUMBER         := 1.0;

    -- VARIABLES FOR FND LOG --
    l_error_level  number   := FND_LOG.LEVEL_ERROR;
    l_mod_name     varchar2(2000) := 'csd.plsql.csd_ro_bulletins_pvt.link_bulletin_for_rule';

    --VARIABLES --
    l_sql_query           VARCHAR2(32767) := null;
    l_repair_order_cursor REPAIR_ORDER_CURSOR;
    l_repair_line_id      NUMBER;
    l_service_codes       CSD_RO_SC_IDS_TBL_TYPE;
    l_bulletin_id         NUMBER;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  LINK_BULLETIN_FOR_RULE;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log the api name in the log file
    --dbms_output.put_line('At the Beginning of LINK_BULLETIN_FOR_RULE');
    --dbms_output.put_line('p_bulletin_id   ='||p_bulletin_id);
    --dbms_output.put_line('p_bulletin_rule_id       ='||p_bulletin_rule_id);

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version_number,
                                        l_api_name   ,
                                        G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    -- initialize bulletin_id
    IF (p_bulletin_id is null) THEN
        OPEN c_get_bulletin_id(p_bulletin_rule_id);
        FETCH c_get_bulletin_id into l_bulletin_id;
        IF (c_get_bulletin_id%NOTFOUND) THEN
            RAISE FND_API.G_EXC_ERROR;
            CLOSE c_get_bulletin_id;
        END IF;
        CLOSE c_get_bulletin_id;
    ELSE
        l_bulletin_id := p_bulletin_id;
    END IF;

    -- get all the matching ROs for the given rule
    l_sql_query := CSD_RULES_ENGINE_PVT.GET_RULE_SQL_FOR_RO(p_bulletin_rule_id);

    -- exclude any repair orders in closed state
    l_sql_query := l_sql_query || ' AND dra.status <> ''C''';

    -- exclude any repair orders that are already liked to the bulletin
    l_sql_query := l_sql_query || ' AND not exists ( select ''X'' from csd_ro_bulletins bul'
                               || ' where bul.source_id = ' || p_bulletin_rule_id
                               || ' and bul.repair_line_id =  dra.repair_line_id )';

    -- Add on additional query criteria from concurrent program params --
    IF (p_params.ro_flow_status_id is not null) THEN
        l_sql_query := l_sql_query ||
                       'and dra.FLOW_STATUS_ID = nvl('
                       || p_params.ro_flow_status_id
                       ||', dra.FLOW_STATUS_ID)';
    END IF;

    IF (p_params.ro_inv_org_id is not null) THEN
        l_sql_query := l_sql_query ||
                       'and dra.INVENTORY_ORG_ID = nvl('
                       || p_params.ro_inv_org_id
                       ||', dra.INVENTORY_ORG_ID)';
    END IF;

    IF (p_params.ro_repair_org_id is not null) THEN
        l_sql_query := l_sql_query ||
                       'and dra.OWNING_ORGANIZATION_ID = nvl('
                       || p_params.ro_repair_org_id
                       ||', dra.OWNING_ORGANIZATION_ID)';
    END IF;

    IF (p_params.ro_inv_item_id is not null) THEN
        l_sql_query := l_sql_query ||
                       'and dra.INVENTORY_ITEM_ID = nvl('
                       || p_params.ro_inv_item_id
                       ||', dra.INVENTORY_ITEM_ID)';
    END IF;
    -- END of concurrent program params --

    OPEN l_repair_order_cursor FOR l_sql_query;  -- (results should go into l_repair_orders)
    -- link the matching ROs to the bulletin passed in.
    LOOP
        FETCH l_repair_order_cursor INTO l_repair_line_id;
        EXIT WHEN l_repair_order_cursor%NOTFOUND;
        CREATE_NEW_RO_BULLETIN_LINK(
           p_api_version_number  => 1.0,
           p_commit              => FND_API.G_FALSE,
           p_init_msg_list       => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           p_repair_line_id      => l_repair_line_id,
           p_bulletin_id         => l_bulletin_id,
           p_rule_id             => p_bulletin_rule_id,
           px_ro_sc_ids_tbl      => l_service_codes,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data
        );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.put_line('CREATE_NEW_RO_BULLETIN_LINK failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Link the service codes from the bulletin to the repair order
        APPLY_BULLETIN_SCS_TO_RO (
           p_api_version_number  => 1.0,
           p_commit              => FND_API.G_FALSE,
           p_init_msg_list       => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_service_codes       => l_service_codes,
           p_repair_line_id      => l_repair_line_id);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.put_line('APPLY_BULLETIN_SCS_TO_RO failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --dbms_output.put_line('In FND_API.G_EXC_ERROR exception');
        -- As we are committing the processed records  in the inner APIs
        -- so we rollback only if the p_commit='F'
        IF NOT(FND_API.To_Boolean( p_commit )) THEN
            ROLLBACK TO LINK_BULLETIN_FOR_RULE;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --dbms_output.put_line('In FND_API.G_EXC_UNEXPECTED_ERROR exception');
        IF ( l_error_level >= G_debug_level)  THEN
            fnd_message.set_name('CSD','CSD_SQL_ERROR');
            fnd_message.set_token('SQLERRM',SQLERRM);
            fnd_message.set_token('SQLCODE',SQLCODE);
            fnd_log.message(l_error_level,l_mod_name,FALSE);
        END If;
        -- As we are committing the processed records  in the inner APIs
        -- so we rollback only if the p_commit='F'
        IF NOT(FND_API.To_Boolean( p_commit )) THEN
            ROLLBACK TO LINK_BULLETIN_FOR_RULE;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
        --dbms_output.put_line('In OTHERS exception');
        IF ( l_error_level >= G_debug_level)  THEN
            fnd_message.set_name('CSD','CSD_SQL_ERROR');
            fnd_message.set_token('SQLERRM',SQLERRM);
            fnd_message.set_token('SQLCODE',SQLCODE);
            fnd_log.message(l_error_level,l_mod_name,FALSE);
        END If;
        -- As we are committing the processed records  in the inner APIs
        -- so we rollback only if the p_commit='F'
        IF NOT(FND_API.To_Boolean( p_commit )) THEN
            ROLLBACK TO LINK_BULLETIN_FOR_RULE;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                     l_api_name  );
        END IF;
        FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

END LINK_BULLETIN_FOR_RULE;

/*--------------------------------------------------------------------*/
/* procedure name: APPLY_BULLETIN_SCS_TO_RO                           */
/* description : Given set of service codes from a service bulletin   */
/*               mark them as applicable for a repair order           */
/*                                                                    */
/* Called from : PROCEDURE  LINK_BULLETIN_FOR_RULE                    */
/* Input Parm  :                                                      */
/*    p_service_codes       CSD_RO_SC_IDS_TBL_TYPE     Req            */
/*    p_repair_line_id      NUMBER                     Req            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE APPLY_BULLETIN_SCS_TO_RO (
    p_api_version_number   IN   NUMBER,
    p_commit               IN   VARCHAR2,
    p_init_msg_list        IN   VARCHAR2,
    p_validation_level     IN   NUMBER,
    x_return_status        OUT  NOCOPY  VARCHAR2,
    x_msg_count            OUT  NOCOPY  NUMBER,
    x_msg_data             OUT  NOCOPY  VARCHAR2,
    p_service_codes        IN   CSD_RO_SC_IDS_TBL_TYPE,
    p_repair_line_id       IN   NUMBER
)
IS
    -- CURSORS --
    CURSOR c_validate_sc_domain (p_service_code_id number,
                                 p_repair_line_id number)
    IS
    SELECT 'X'
    FROM
        csd_sc_domains_v dom, CSD_REPAIRS dra
    WHERE dom.service_code_id = p_service_code_id
    AND dra.repair_line_id = p_repair_line_id
    AND (dom.inventory_item_id = dra.inventory_item_id
         OR  (dom.category_set_id = fnd_profile.value('CSD_DEFAULT_CATEGORY_SET')
              AND dom.category_id in ( SELECT DISTINCT  cat.category_id
                                         FROM mtl_item_categories_v cat
                                        WHERE cat.inventory_item_id = dra.inventory_item_id)
             )
         );

    CURSOR c_get_ro_service_code (p_service_code_id number,
                                  p_repair_line_id number)
    IS
    SELECT   ro_service_code_id
            ,object_version_number
            ,repair_line_id
            ,service_code_id
            ,source_type_code
            ,source_solution_id
            ,applicable_flag
            ,applied_to_est_flag
            ,applied_to_work_flag
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,service_item_id
     FROM CSD_RO_SERVICE_CODES
    WHERE repair_line_id = p_repair_line_id
      AND service_code_id = p_service_code_id;


    CURSOR c_get_ro_item (p_repair_line_id number)
    IS
    SELECT inventory_item_id
      FROM CSD_REPAIRS
     WHERE repair_line_id = p_repair_line_id;

    -- STANDARD CONSTANTS
    l_api_name             CONSTANT VARCHAR2(30)   := 'APPLY_BULLETIN_SCS_TO_RO';
    l_api_version          CONSTANT NUMBER         := 1.0;

    -- VARIABLES FOR FND LOG --
    l_error_level  number   := FND_LOG.LEVEL_ERROR;
    l_mod_name     varchar2(2000) := 'csd.plsql.csd_ro_bulletins_pvt.apply_bulletin_scs_to_ro';

    -- VARIABLES --
    l_in_domain            VARCHAR2(1);
    l_ro_service_code_rec  CSD_RO_SERVICE_CODES_PVT.RO_SERVICE_CODE_REC_TYPE;
    l_ro_service_code_id   NUMBER;
    l_obj_ver_number       NUMBER;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  APPLY_BULLETIN_SCS_TO_RO;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log the api name in the log file
    --dbms_output.put_line('At the Beginning of APPLY_BULLETIN_SCS_TO_RO');
    --dbms_output.put_line('p_repair_line_id   ='||p_repair_line_id);

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version_number,
                                        l_api_name   ,
                                        G_PKG_NAME   )
       THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    FOR i IN 1.. p_service_codes.count LOOP
        -- check if SC is for this repair order item
        -- if the cursor returns  result, then the repair order item
        -- is within the service code domain
        OPEN c_validate_sc_domain(p_service_codes(i), p_repair_line_id);
        FETCH c_validate_sc_domain INTO l_in_domain;
        CLOSE c_validate_sc_domain;

        IF (l_in_domain is not null) THEN
            -- get the existing record, if there is one
            OPEN c_get_ro_service_code(p_service_codes(i), p_repair_line_id);
            FETCH c_get_ro_service_code INTO
                 l_ro_service_code_rec.ro_service_code_id
                ,l_ro_service_code_rec.object_version_number
                ,l_ro_service_code_rec.repair_line_id
                ,l_ro_service_code_rec.service_code_id
                ,l_ro_service_code_rec.source_type_code
                ,l_ro_service_code_rec.source_solution_id
                ,l_ro_service_code_rec.applicable_flag
                ,l_ro_service_code_rec.applied_to_est_flag
                ,l_ro_service_code_rec.applied_to_work_flag
                ,l_ro_service_code_rec.attribute_category
                ,l_ro_service_code_rec.attribute1
                ,l_ro_service_code_rec.attribute2
                ,l_ro_service_code_rec.attribute3
                ,l_ro_service_code_rec.attribute4
                ,l_ro_service_code_rec.attribute5
                ,l_ro_service_code_rec.attribute6
                ,l_ro_service_code_rec.attribute7
                ,l_ro_service_code_rec.attribute8
                ,l_ro_service_code_rec.attribute9
                ,l_ro_service_code_rec.attribute10
                ,l_ro_service_code_rec.attribute11
                ,l_ro_service_code_rec.attribute12
                ,l_ro_service_code_rec.attribute13
                ,l_ro_service_code_rec.attribute14
                ,l_ro_service_code_rec.attribute15
                ,l_ro_service_code_rec.service_item_id;
            CLOSE c_get_ro_service_code;

            -- if there is an existing record,then set it to applicable
            -- if it is not already  marked as applicable.
            IF (l_ro_service_code_rec.ro_service_code_id is not null) THEN
                IF (nvl(l_ro_service_code_rec.applicable_flag, 'N') <> 'Y') THEN
                    l_ro_service_code_rec.applicable_flag := 'Y';
                    CSD_RO_SERVICE_CODES_PVT.Update_RO_Service_Code (
                      p_api_version             => l_api_version,
                      p_commit                  => FND_API.G_FALSE,
                      p_init_msg_list           => FND_API.G_FALSE,
                      p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                      x_return_status           => x_return_status,
                      x_msg_count               => x_msg_count,
                      x_msg_data                => x_msg_data,
                      p_ro_service_code_rec     => l_ro_service_code_rec,
                      x_obj_ver_number          => l_obj_ver_number
                      );
                END IF;
            ELSE -- if there is no existing record, then create one.
                l_ro_service_code_rec.repair_line_id := p_repair_line_id;
                l_ro_service_code_rec.service_code_id := p_service_codes(i);
                l_ro_service_code_rec.source_type_code := 'MANUAL';
                l_ro_service_code_rec.applicable_flag := 'Y';
                OPEN c_get_ro_item(p_repair_line_id);
                FETCH c_get_ro_item INTO l_ro_service_code_rec.service_item_id;
                CLOSE c_get_ro_item;

                CSD_RO_SERVICE_CODES_PVT.Create_RO_Service_Code (
                  p_api_version             => l_api_version,
                  p_commit                  => FND_API.G_FALSE,
                  p_init_msg_list           => FND_API.G_FALSE,
                  p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                  x_return_status           => x_return_status,
                  x_msg_count               => x_msg_count,
                  x_msg_data                => x_msg_data,
                  p_ro_service_code_rec     => l_ro_service_code_rec  ,
                  x_ro_service_code_id      => l_ro_service_code_id
                  );
            END IF;
            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.put_line('CREATE_RO_SERVICE_CODE failed');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF; -- end if (l_in_domain is not null)

    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --dbms_output.put_line('In FND_API.G_EXC_ERROR exception');
        ROLLBACK TO APPLY_BULLETIN_SCS_TO_RO;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --dbms_output.put_line('In FND_API.G_EXC_UNEXPECTED_ERROR exception');
        IF ( l_error_level >= G_debug_level)  THEN
            fnd_message.set_name('CSD','CSD_SQL_ERROR');
            fnd_message.set_token('SQLERRM',SQLERRM);
            fnd_message.set_token('SQLCODE',SQLCODE);
            fnd_log.message(l_error_level,l_mod_name,FALSE);
        END If;
        ROLLBACK TO APPLY_BULLETIN_SCS_TO_RO;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
       -- dbms_output.put_line('In OTHERS exception' );
        IF ( l_error_level >= G_debug_level)  THEN
            fnd_message.set_name('CSD','CSD_SQL_ERROR');
            fnd_message.set_token('SQLERRM',SQLERRM);
            fnd_message.set_token('SQLCODE',SQLCODE);
            fnd_log.message(l_error_level,l_mod_name,FALSE);
        END If;
        ROLLBACK TO APPLY_BULLETIN_SCS_TO_RO;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                     l_api_name  );
        END IF;
        FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );

END APPLY_BULLETIN_SCS_TO_RO;

END CSD_RO_BULLETINS_PVT; /* Package body ends*/

/
