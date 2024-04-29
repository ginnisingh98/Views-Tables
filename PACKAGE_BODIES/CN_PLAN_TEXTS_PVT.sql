--------------------------------------------------------
--  DDL for Package Body CN_PLAN_TEXTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLAN_TEXTS_PVT" AS
/* $Header: cnvsptb.pls 115.16 2002/11/21 21:18:53 hlchen ship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_PLAN_TEXTS_PVT';




CURSOR validate_role_state (c_role_id IN NUMBER)  IS
SELECT 1
    FROM cn_srp_role_dtls_v s, cn_role_quota_cates r
    WHERE s.status not in ('PENDING','ACCEPTED')
    AND s.role_id = r.role_id
    AND r.role_model_id is NULL
    AND s.role_model_id is NULL
    AND s.role_id = c_role_id;

PROCEDURE validate_role(c_role_id IN NUMBER) IS
    l_dummy NUMBER ;
BEGIN

   OPEN validate_role_state(c_role_id) ;
   FETCH validate_role_state INTO l_dummy;
   IF (validate_role_state%found) THEN
      CLOSE validate_role_state;
      fnd_message.set_name('CN', 'CN_ROLE_DETAIL_ASGNED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;
   CLOSE validate_role_state;

END ;

-- Start of comments
--    API name        : Create_Plan_Text
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_plan_text           IN  plan_text_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Plan_Text (
  p_api_version                IN      NUMBER,
  p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_plan_text                  IN      plan_text_rec_type,
  x_return_status              OUT NOCOPY     VARCHAR2,
  x_msg_count                  OUT NOCOPY     NUMBER,
  x_msg_data                   OUT NOCOPY     VARCHAR2
) IS

  G_LAST_UPDATE_DATE          DATE := Sysdate;
  G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
  G_CREATION_DATE             DATE := Sysdate;
  G_CREATED_BY                NUMBER := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

  l_api_name         CONSTANT VARCHAR2(30) := 'Create_Plan_Text';
  l_api_version      CONSTANT NUMBER       := 1.0;

  l_plan_text_id NUMBER;
  l_temp_count   NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Plan_Text;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   IF ( p_plan_text.role_id is NULL ) OR
      ( p_plan_text.text_type is NULL )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
  FND_MESSAGE.SET_TOKEN('INPUT_NAME', 'Role or Text Type');
  FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

  -- CHECK THE ROLE SETUP


  validate_role( p_plan_text.role_id ) ;


   -- same plan text is not allowed to be
   -- assigned twice
   SELECT count(1)
     INTO l_temp_count
     FROM cn_plan_texts
    WHERE role_id = p_plan_text.role_id
      AND nvl(role_model_id, -1) = nvl(p_plan_text.role_model_id, -1)
      AND text_type = p_plan_text.text_type
      AND ( quota_category_id is NULL OR
            quota_category_id = nvl(p_plan_text.quota_category_id,
                                      quota_category_id)
          )
      AND ( sequence_id is NULL OR
            sequence_id = nvl(p_plan_text.sequence_id, sequence_id)
          );

   IF l_temp_count > 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  FND_MESSAGE.SET_NAME ('CN' , 'CN_ASSIGN_CANT_SAME');
  FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   SELECT cn_plan_texts_s.NEXTVAL INTO l_plan_text_id FROM DUAL;

   CN_PLAN_TEXTS_PKG.Insert_Row
   (
    P_PLAN_TEXT_ID       => l_plan_text_id,
    P_ROLE_ID            => p_plan_text.role_id,
    P_SEQUENCE_ID        => p_plan_text.sequence_id,
    P_QUOTA_CATEGORY_ID  => p_plan_text.quota_category_id,
    P_TEXT_TYPE          => p_plan_text.text_type,
    P_TEXT               => p_plan_text.text,
    P_TEXT2              => p_plan_text.text2,
    P_OBJECT_VERSION_NUMBER  => 1,
    P_ROLE_MODEL_ID      => p_plan_text.role_model_id,
    P_CREATION_DATE      => G_CREATION_DATE,
    P_CREATED_BY         => G_CREATED_BY,
    P_LAST_UPDATE_DATE   => G_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY    => G_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN  => G_LAST_UPDATE_LOGIN
   );

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Plan_Text;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Plan_Text;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Create_Plan_Text;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Create_Plan_Text;



-- Start of comments
--      API name        : Update_Plan_Text
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_plan_text         IN plan_text_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Plan_Text (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_plan_text                   IN      plan_text_rec_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  G_LAST_UPDATE_DATE          DATE := Sysdate;
  G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

  l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Plan_Text';
  l_api_version        CONSTANT NUMBER        := 1.0;

  CURSOR l_cr (P_PLAN_TEXT_ID NUMBER) IS
    SELECT
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15
    FROM cn_plan_texts
    WHERE plan_text_id = P_PLAN_TEXT_ID;

  l_plan_text l_cr%ROWTYPE;
  l_temp_count NUMBER;
  l_dummy      NUMBER ;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Plan_Text;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   IF ( p_plan_text.role_id is NULL ) OR
      ( p_plan_text.text_type is NULL )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
  FND_MESSAGE.SET_TOKEN('INPUT_NAME', 'Role or Text Type');
  FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

/*
   OPEN validate_role_state(p_plan_text.role_id) ;
   FETCH validate_role_state INTO l_dummy;
   IF (validate_role_state%found) THEN
      CLOSE validate_role_state;
      fnd_message.set_name('CN', 'CN_ROLE_DETAIL_ASGNED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;
   CLOSE validate_role_state;
*/

  validate_role (p_plan_text.role_id ) ;

   -- same plan text is not allowed to be
   -- assigned twice
   SELECT count(1)
     INTO l_temp_count
     FROM cn_plan_texts
    WHERE role_id = p_plan_text.role_id
      AND nvl(role_model_id, -1) = nvl(p_plan_text.role_model_id, -1)
      AND text_type = p_plan_text.text_type
      AND ( quota_category_id is NULL OR
            quota_category_id = nvl(p_plan_text.quota_category_id,
                                    quota_category_id)
          )
      AND ( sequence_id is NULL OR
            sequence_id = nvl(p_plan_text.sequence_id, sequence_id)
          )
      AND plan_text_id <> p_plan_text.plan_text_id
          ;

   IF l_temp_count > 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  FND_MESSAGE.SET_NAME ('CN' , 'CN_ASSIGN_CANT_SAME');
  FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_cr(p_plan_text.plan_text_id);
   FETCH l_cr into l_plan_text;
   CLOSE l_cr;

   -- check object version number
   IF l_plan_text.object_version_number <>
                     p_plan_text.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

   CN_PLAN_TEXTS_PKG.Update_Row
   (
    P_PLAN_TEXT_ID       => p_plan_text.plan_text_id,
    P_ROLE_ID            => p_plan_text.role_id,
    P_SEQUENCE_ID        => p_plan_text.sequence_id,
    P_QUOTA_CATEGORY_ID  => p_plan_text.quota_category_id,
    P_TEXT_TYPE          => p_plan_text.text_type,
    P_TEXT               => p_plan_text.text,
    P_TEXT2              => p_plan_text.text2,
    P_OBJECT_VERSION_NUMBER   => p_plan_text.object_version_number + 1,
    P_ROLE_MODEL_ID      => p_plan_text.role_model_id,
    P_ATTRIBUTE_CATEGORY => l_plan_text.attribute_category,
    P_ATTRIBUTE1         => l_plan_text.attribute1,
    P_ATTRIBUTE2         => l_plan_text.attribute2,
    P_ATTRIBUTE3         => l_plan_text.attribute3,
    P_ATTRIBUTE4         => l_plan_text.attribute4,
    P_ATTRIBUTE5         => l_plan_text.attribute5,
    P_ATTRIBUTE6         => l_plan_text.attribute6,
    P_ATTRIBUTE7         => l_plan_text.attribute7,
    P_ATTRIBUTE8         => l_plan_text.attribute8,
    P_ATTRIBUTE9         => l_plan_text.attribute9,
    P_ATTRIBUTE10        => l_plan_text.attribute10,
    P_ATTRIBUTE11        => l_plan_text.attribute11,
    P_ATTRIBUTE12        => l_plan_text.attribute12,
    P_ATTRIBUTE13        => l_plan_text.attribute13,
    P_ATTRIBUTE14        => l_plan_text.attribute14,
    P_ATTRIBUTE15        => l_plan_text.attribute15,
    P_LAST_UPDATE_DATE   => G_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY    => G_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN  => G_LAST_UPDATE_LOGIN
   );

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Plan_Text;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Plan_Text;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Plan_Text;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Update_Plan_Text;




-- Start of comments
--      API name        : Delete_Plan_Text
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_plan_text         IN plan_text_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Plan_Text (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_plan_text                   IN      plan_text_rec_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Plan_Text';
  l_api_version        CONSTANT NUMBER                 := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Plan_Text;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   CN_PLAN_TEXTS_PKG.Delete_Row(p_plan_text.plan_text_id);

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Plan_Text;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Plan_Text;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Delete_Plan_Text;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Delete_Plan_Text;



-- Start of comments
--      API name        : Get_Plan_Texts
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_plan_texts        OUT     plan_text_tbl_type
--                        x_updatable         OUT     VARCHAR2(1)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Plan_Texts (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  x_plan_texts                  OUT NOCOPY     plan_text_tbl_type,
  x_updatable                   OUT NOCOPY     VARCHAR2,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Get_Plan_Texts';
  l_api_version        CONSTANT NUMBER       := 1.0;

  l_ctr NUMBER;

  CURSOR l_spt_cr (P_ROLE_ID NUMBER) IS
   SELECT srp_id
     FROM cn_srp_role_dtls_v
    WHERE role_id = P_ROLE_ID
      AND role_model_id is NULL
      AND (status <> 'PENDING' or non_std_flag = 'Y' );

  CURSOR l_pts_cr (C_ROLE_ID  IN NUMBER,
                   C_ROLE_MODEL_ID  IN NUMBER) IS
    SELECT
      plan_text_id,
      role_id,
      role_model_id,
      sequence_id,
      quota_category_id,
      text_type,
      text,
      text2,
      object_version_number
    FROM cn_plan_texts
    WHERE role_id = c_role_id
      AND nvl(role_model_id, -1) = nvl(c_role_model_id, -1)
    ORDER BY sequence_id;

  l_plan_text l_pts_cr%ROWTYPE;

  l_temp_con_title  cn_sf_repositories.CONTRACT_TITLE%TYPE := NULL;
  l_temp_term_con   cn_sf_repositories.TERMS_AND_CONDITIONS%TYPE := NULL;
  l_temp_club       cn_sf_repositories.CLUB_QUAL_TEXT%TYPE := NULL;
  l_temp_app_name   cn_sf_repositories.APPROVER_NAME%TYPE := NULL;
  l_temp_app_title  cn_sf_repositories.APPROVER_TITLE%TYPE := NULL;
  l_temp_app_org    cn_sf_repositories.APPROVER_ORG_NAME%TYPE := NULL;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Plan_Texts;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   BEGIN
     SELECT contract_title, terms_and_conditions,
            club_qual_text, approver_name,
            approver_title, approver_org_name
       INTO l_temp_con_title, l_temp_term_con,
            l_temp_club, l_temp_app_name,
            l_temp_app_title, l_temp_app_org
       FROM cn_sf_repositories;
   EXCEPTION
     WHEN No_Data_Found THEN
       null;
   END;

   l_ctr := 1;

   OPEN l_pts_cr(p_role_id, p_role_model_id);
   LOOP
      FETCH l_pts_cr INTO l_plan_text;
      EXIT WHEN l_pts_cr%NOTFOUND ;

      x_plan_texts(l_ctr).plan_text_id      := l_plan_text.plan_text_id;
      x_plan_texts(l_ctr).role_id           := l_plan_text.role_id;
      x_plan_texts(l_ctr).role_model_id     := l_plan_text.role_model_id;
      x_plan_texts(l_ctr).sequence_id       := l_plan_text.sequence_id;
      x_plan_texts(l_ctr).quota_category_id := l_plan_text.quota_category_id;
      x_plan_texts(l_ctr).text_type         := l_plan_text.text_type;
      x_plan_texts(l_ctr).text              := l_plan_text.text;
      x_plan_texts(l_ctr).text2             := l_plan_text.text2;
      x_plan_texts(l_ctr).object_version_number
                                      := l_plan_text.object_version_number;

      l_ctr := l_ctr + 1;
   END LOOP;

   IF l_pts_cr%ROWCOUNT = 0 THEN
      x_plan_texts := G_MISS_PLAN_TEXT_TBL;
   END IF;

   CLOSE l_pts_cr;

   IF l_ctr = 1 THEN
     x_plan_texts(1).role_id := p_role_id;
     x_plan_texts(1).role_model_id := p_role_model_id;
     x_plan_texts(1).text_type := 'PLAN_TITLE_TEXT';
     x_plan_texts(1).text := l_temp_con_title;

     x_plan_texts(2).role_id := p_role_id;
     x_plan_texts(2).role_model_id := p_role_model_id;
     x_plan_texts(2).text_type := 'PLAN_TC_TEXT';
     x_plan_texts(2).text := l_temp_term_con;

     x_plan_texts(3).role_id := p_role_id;
     x_plan_texts(3).role_model_id := p_role_model_id;
     x_plan_texts(3).text_type := 'PLAN_CLUB_TEXT';
     x_plan_texts(3).text := l_temp_club;

     x_plan_texts(4).role_id := p_role_id;
     x_plan_texts(4).role_model_id := p_role_model_id;
     x_plan_texts(4).text_type := 'PLAN_APPR_NAME';
     x_plan_texts(4).text := l_temp_app_name;

     x_plan_texts(5).role_id := p_role_id;
     x_plan_texts(5).role_model_id := p_role_model_id;
     x_plan_texts(5).text_type := 'PLAN_APPR_TITLE';
     x_plan_texts(5).text := l_temp_app_title;

     x_plan_texts(6).role_id := p_role_id;
     x_plan_texts(6).role_model_id := p_role_model_id;
     x_plan_texts(6).text_type := 'PLAN_APPR_ORG_NAME';
     x_plan_texts(6).text := l_temp_app_org;
   END IF;

   -- check updateable or not
   OPEN l_spt_cr(p_role_id);

   FETCH l_spt_cr INTO l_ctr;
   IF l_spt_cr%NOTFOUND THEN
     x_updatable := 'T';
   ELSE
     x_updatable := 'F';
   END IF;

   CLOSE l_spt_cr;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Plan_Texts;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Plan_Texts;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Plan_Texts;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Plan_Texts;


-- Start of comments
--      API name        : Get_Fixed_Quota_Cates
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_cates       OUT     quota_cate_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Fixed_Quota_Cates (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  x_quota_cates                 OUT NOCOPY     quota_cate_tbl_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Get_Fixed_Quota_Cates';
  l_api_version        CONSTANT NUMBER       := 1.0;

  l_ctr NUMBER;

  CURSOR l_qcs_cr (C_ROLE_ID   IN  NUMBER,
                   C_ROLE_MODEL_ID  IN  NUMBER) IS
    SELECT qc.quota_category_id quota_cate_id,
           qc.name quota_name
      FROM cn_quota_categories qc,
           cn_role_quota_cates pqc
     WHERE pqc.role_id = c_role_id
       AND qc.quota_category_id = pqc.quota_category_id
       AND qc.type = 'FIXED'
       AND nvl(pqc.role_model_id, -1) = nvl(c_role_model_id, -1)
    ORDER BY quota_cate_id;

  l_quota_cate l_qcs_cr%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Fixed_Quota_Cates;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   l_ctr := 1;

   OPEN l_qcs_cr(p_role_id, p_role_model_id);
   LOOP
      FETCH l_qcs_cr INTO l_quota_cate;
      EXIT WHEN l_qcs_cr%NOTFOUND ;

      x_quota_cates(l_ctr).quota_cate_id := l_quota_cate.quota_cate_id;
      x_quota_cates(l_ctr).quota_name    := l_quota_cate.quota_name;

      l_ctr := l_ctr + 1;
   END LOOP;

   IF l_qcs_cr%ROWCOUNT = 0 THEN
      x_quota_cates := G_MISS_QUOTA_CATE_TBL;
   END IF;

   CLOSE l_qcs_cr;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Fixed_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Fixed_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Fixed_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Fixed_Quota_Cates;

-- Start of comments
--      API name        : Get_Var_Quota_Cates
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_cates       OUT     quota_cate_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Var_Quota_Cates (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  x_quota_cates                 OUT NOCOPY     quota_cate_tbl_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Get_Var_Quota_Cates';
  l_api_version        CONSTANT NUMBER       := 1.0;

  l_ctr NUMBER;

  CURSOR l_qcs_cr(c_role_id  IN  NUMBER,
                  c_role_model_id  IN  NUMBER) IS
    SELECT qc.quota_category_id quota_cate_id,
           qc.name quota_name
      FROM cn_quota_categories qc,
           cn_role_quota_cates pqc
     WHERE pqc.role_id = c_role_id
       and (NOT pqc.rate_schedule_id IS NULL)
       and qc.quota_category_id = pqc.quota_category_id
       and qc.type = 'VAR_QUOTA'
       and nvl(pqc.role_model_id, -1) = nvl(c_role_model_id, -1)
    ORDER BY quota_cate_id;

  l_quota_cate l_qcs_cr%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Var_Quota_Cates;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   l_ctr := 1;

   OPEN l_qcs_cr(p_role_id, p_role_model_id);
   LOOP
      FETCH l_qcs_cr INTO l_quota_cate;
      EXIT WHEN l_qcs_cr%NOTFOUND ;

      x_quota_cates(l_ctr).quota_cate_id := l_quota_cate.quota_cate_id;

      IF l_quota_cate.quota_cate_id = -1000 THEN
        SELECT meaning
          INTO x_quota_cates(l_ctr).quota_name
          FROM cn_lookups
         WHERE lookup_type = 'QUOTA_CATEGORY'
           AND lookup_code = 'TOTAL_QUOTA';
      ELSE
        x_quota_cates(l_ctr).quota_name := l_quota_cate.quota_name;
      END IF;

      l_ctr := l_ctr + 1;
   END LOOP;

   IF l_qcs_cr%ROWCOUNT = 0 THEN
      x_quota_cates := G_MISS_QUOTA_CATE_TBL;
   END IF;

   CLOSE l_qcs_cr;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Var_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Var_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Var_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Var_Quota_Cates;


-- Start of comments
--      API name        : Get_Quota_Cates
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_cates       OUT     quota_cate_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Quota_Cates (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  p_quota_cate_type             IN      VARCHAR2,
  x_quota_cates                 OUT NOCOPY     quota_cate_tbl_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Get_Quota_Cates';
  l_api_version        CONSTANT NUMBER       := 1.0;

  l_ctr NUMBER;

  CURSOR l_qcs_cr(c_role_id  IN  NUMBER,
                  c_role_model_id  IN  NUMBER,
                  c_quota_cate_type IN VARCHAR) IS
    SELECT qc.quota_category_id quota_cate_id,
           qc.name quota_name
      FROM cn_quota_categories qc,
           cn_role_quota_cates pqc
     WHERE pqc.role_id = c_role_id
       and (NOT pqc.rate_schedule_id IS NULL)
       and qc.quota_category_id = pqc.quota_category_id
       and qc.type = c_quota_cate_type
       and nvl(pqc.role_model_id, -1) = nvl(c_role_model_id, -1)
    ORDER BY quota_cate_id;

  l_quota_cate l_qcs_cr%ROWTYPE;
  l_quota_type VARCHAR2(2000) ;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Quota_Cates;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   l_ctr := 1;

   l_quota_type := p_quota_cate_type ;

   OPEN l_qcs_cr(p_role_id, p_role_model_id,l_quota_type);
   LOOP
      FETCH l_qcs_cr INTO l_quota_cate;
      EXIT WHEN l_qcs_cr%NOTFOUND ;

      x_quota_cates(l_ctr).quota_cate_id := l_quota_cate.quota_cate_id;

      IF l_quota_cate.quota_cate_id = -1000 THEN
        SELECT meaning
          INTO x_quota_cates(l_ctr).quota_name
          FROM cn_lookups
         WHERE lookup_type = 'QUOTA_CATEGORY'
           AND lookup_code = 'TOTAL_QUOTA';
      ELSE
        x_quota_cates(l_ctr).quota_name := l_quota_cate.quota_name;
      END IF;

      l_ctr := l_ctr + 1;
   END LOOP;

   IF l_qcs_cr%ROWCOUNT = 0 THEN
      x_quota_cates := G_MISS_QUOTA_CATE_TBL;
   END IF;

   CLOSE l_qcs_cr;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Quota_Cates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Quota_Cates;


-- Start of comments
--      API name        : Get_Role_Name
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_role_name    OUT     VARCHAR2(80)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Role_Name (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  x_role_name                   OUT NOCOPY     VARCHAR2,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'Get_Role_Name';
  l_api_version        CONSTANT NUMBER       := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Role_Name;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   IF p_role_model_id is NULL THEN
     SELECT name INTO x_role_name
       FROM cn_role_details_v
      WHERE role_id = P_ROLE_ID;
   ELSE
     SELECT name INTO x_role_name
       FROM cn_role_models
      WHERE role_model_id = P_ROLE_MODEL_ID;
   END IF;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Role_Name;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Role_Name;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Role_Name;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Role_Name;



  FUNCTION Get_Text (
     p_role_id IN NUMBER,
     p_text_type IN VARCHAR2,
     p_quota_category_id IN NUMBER := NULL,
     p_role_model_id IN NUMBER := NULL)
  RETURN VARCHAR2
  IS

    l_ret_val    VARCHAR2(4000) := NULL ;
    l_ret_text2  VARCHAR2(4000) := NULL ;
    l_loop_count NUMBER;

    CURSOR qc_rate_text_cur(
     i_role_id IN NUMBER,
     i_quota_category_id IN NUMBER,
     i_text_type IN VARCHAR2)
    IS
    SELECT  text,
            NVL(text2, ' ') text2
    FROM  cn_plan_texts
    WHERE role_id = i_role_id
    AND NVL(role_model_id, 0) = NVL(p_role_model_id, 0)
    AND quota_category_id = i_quota_category_id
    AND text_type = i_text_type
    ;

    CURSOR plan_level_text_cur (i_role_id IN NUMBER, i_text_type IN VARCHAR2)
    IS
    SELECT  NVL(text,  ' ') text,
            NVL(text2, ' ') text2
    FROM cn_plan_texts
    WHERE role_id = i_role_id
    AND NVL(role_model_id, 0) = NVL(p_role_model_id, 0)
    AND text_type = i_text_type
    ORDER BY sequence_id
    ;

  BEGIN

     IF p_text_type =   'QC_QUOTA_DISP_NAME'
       OR p_text_type = 'QC_ATT_TBL_DISP_INFO'
       OR p_text_type = 'QC_RT_TIER_DISP_NAME'
     THEN
        l_loop_count := 0;
        FOR qc_rate_text_rec IN qc_rate_text_cur(p_role_id, p_quota_category_id, p_text_type)
        LOOP
            l_ret_val := qc_rate_text_rec.text;
            l_ret_text2   := qc_rate_text_rec.text2;
            l_loop_count := l_loop_count + 1;
        END LOOP;
     END IF;

     IF    p_text_type = 'PLAN_CLUB_TEXT'
       OR  p_text_type = 'PLAN_NON_QUOTA_TEXT'
       OR  p_text_type = 'PLAN_QUOTA_DISPLAY_TEXT'
       OR  p_text_type = 'PLAN_APPR_NAME'
       OR  p_text_type = 'PLAN_APPR_TITLE'
       OR  p_text_type = 'PLAN_APPR_ORG_NAME'
       OR  p_text_type = 'PLAN_TC_TEXT'
       OR  p_text_type = 'PLAN_DISP_TOT_FLAG'
       OR  p_text_type = 'PLAN_DISP_PCT_TGT_FLAG'
       or  p_text_type = 'PLAN_TITLE_TEXT'
     THEN
        l_loop_count := 0;
        FOR plan_level_text_rec IN plan_level_text_cur(p_role_id, p_text_type)
        LOOP
           l_ret_val    := plan_level_text_rec.text;
           l_ret_text2  := plan_level_text_rec.text2;
           l_loop_count := l_loop_count + 1;
        END LOOP;
     END IF;
      RETURN l_ret_val ;
  EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END Get_Text;


END CN_PLAN_TEXTS_PVT;

/
