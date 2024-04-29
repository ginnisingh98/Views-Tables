--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_ASSIGN_PUB" AS
  /*$Header: cnpqtasb.pls 120.4 2005/11/08 03:23:47 kjayapau noship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30):='CN_QUOTA_ASSIGN_PUB';
G_LAST_UPDATE_DATE          DATE := Sysdate;
G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
G_CREATION_DATE             DATE := Sysdate;
G_CREATED_BY                NUMBER := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

-- validate_input_record
procedure validate_input_record(p_quota_assign_rec quota_assign_rec_type) IS
BEGIN
   if (p_quota_assign_rec.comp_plan_name is NULL OR
     p_quota_assign_rec.comp_plan_name = fnd_api.g_miss_char OR
     p_quota_assign_rec.quota_name IS NULL OR
     p_quota_assign_rec.quota_name = fnd_api.g_miss_char) OR
     p_quota_assign_rec.ORG_ID IS NULL OR
			p_quota_assign_rec.org_id = fnd_api.g_miss_num
     then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_REQ_PAR_MISSING');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   end if;
END;

-- validate_cp_name
function validate_cp_name(p_cp_name varchar2,p_org_id number) RETURN number IS
   l_cp_id number := 0;
   CURSOR l_cp_id_csr(p_plan_name varchar2) IS
     SELECT comp_plan_id
       FROM cn_comp_plans
       WHERE name = p_plan_name
       and org_id = p_org_id;
BEGIN
   OPEN l_cp_id_csr(p_cp_name);
   FETCH l_cp_id_csr INTO l_cp_id;
   CLOSE l_cp_id_csr;
   if (l_cp_id IS NULL OR l_cp_id = 0) then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_CP_NOT_EXIST');
         FND_MESSAGE.SET_token('CP_NAME', p_cp_name);
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   end if;
   RETURN l_cp_id;
END;

-- validate_cp_name
function validate_pe_name(p_pe_name varchar2,p_org_id number) RETURN number IS
   l_pe_id number := 0;
   CURSOR l_pe_id_csr(p_element_name varchar2) IS
     SELECT quota_id
       FROM cn_quotas_v
       WHERE name = p_element_name and org_id = p_org_id;
BEGIN
   OPEN l_pe_id_csr(p_pe_name);
   FETCH l_pe_id_csr INTO l_pe_id;
   CLOSE l_pe_id_csr;
   if (l_pe_id IS NULL OR l_pe_id = 0) then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_QUOTA');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   end if;
   RETURN l_pe_id;
END;

-- Start of comments
--    API name        : Create_Quota_Assign
--    Type            : Public
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
--                      p_quota_assign_rec    IN  quota_assign_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count                     OUT     NUMBER
--                      x_msg_data                      OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : None
--
-- End of comments
PROCEDURE Create_Quota_Assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_quota_assign_rec            IN      quota_assign_rec_type           ,
  x_return_status               OUT NOCOPY    VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Create_Quota_Assign';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   l_quota_assign_rec  quota_assign_rec_type := p_quota_assign_rec;
   l_comp_plan_id  number := 0;
   l_quota_id  number := 0;
   l_pvt_quota_assign_rec   cn_quota_assign_pvt.quota_assign_rec_type;
   l_return_status  varchar2(1);
   l_msg_count  number;
   l_msg_data   varchar2(2000);

   l_org_id NUMBER;
   l_status VARCHAR2(1);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Quota_Assign_Pub;
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
   -- Validate and Default OrgId
   l_org_id := l_quota_assign_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id, status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.CN_QUOTA_ASSIGN_PUB.Create_Quota_Assign.org_validate',
                        'Validated org_id = ' || l_org_id || ' status = '|| l_status);
   end if;
   l_quota_assign_rec.org_id := l_org_id;

   -- Validate the input first
   validate_input_record(l_quota_assign_rec);
   l_comp_plan_id := validate_cp_name(l_quota_assign_rec.comp_plan_name,l_org_id);
   l_quota_id := validate_pe_name(l_quota_assign_rec.quota_name,l_org_id);

   -- Now call the private api
   l_pvt_quota_assign_rec.comp_plan_id := l_comp_plan_id;
   l_pvt_quota_assign_rec.quota_id := l_quota_id;
   l_pvt_quota_assign_rec.quota_sequence := l_quota_assign_rec.quota_sequence;
   l_pvt_quota_assign_rec.org_id := l_org_id;

   IF (l_pvt_quota_assign_rec.quota_sequence IS NULL OR l_pvt_quota_assign_rec.quota_sequence = FND_API.G_MISS_NUM) THEN
     l_pvt_quota_assign_rec.quota_sequence :=1 ;
   END IF;


   cn_quota_assign_pvt.create_quota_assign
     ( p_api_version           =>1.0,
     p_init_msg_list         => FND_API.G_FALSE,
     p_commit                => FND_API.G_FALSE,
     p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
     p_quota_assign          => l_pvt_quota_assign_rec,
     x_return_status         => l_return_status,
     x_msg_count             => l_msg_count,
     x_msg_data              => l_msg_data);

   x_return_status := l_return_status;
   x_msg_count := l_msg_count;
   x_msg_data := l_msg_data;

   -- if the private API returned anything other than S just pass on
   -- the errors and exit
   if (l_return_status = 'E') then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_status = 'U') THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

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
     ROLLBACK TO Create_Quota_Assign_Pub;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Quota_Assign_Pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Create_Quota_Assign_Pub;
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
END Create_Quota_Assign;

-- Start of comments
--      API name      : Update_Quota_Assign
--      Type          : Public
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version       IN NUMBER       Required
--                      p_init_msg_list     IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit            IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level  IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_quota_assign_rec  IN  quota_assign_rec_type
--      OUT           : x_return_status     OUT     VARCHAR2(1)
--                      x_msg_count         OUT     NUMBER
--                      x_msg_data          OUT     VARCHAR2(2000)
--      Version :       Current version       1.0
--                      Initial version       1.0
--
--      Notes         : Note text
--
-- End of comments
PROCEDURE Update_Quota_Assign
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_quota_assign_rec          IN      quota_assign_rec_type           ,
  x_return_status                 OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY     NUMBER                          ,
  x_msg_data                      OUT NOCOPY    VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Update_Quota_Assign';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   l_quota_assign_rec  quota_assign_rec_type := p_quota_assign_rec;
   /*l_new_quota_assign_rec  quota_assign_rec_type := p_new_quota_assign_rec;*/
   l_comp_plan_id  number := 0;
   l_quota_id  number := 0;
   l_pvt_quota_assign_rec   cn_quota_assign_pvt.quota_assign_rec_type;
   l_return_status  varchar2(1);
   l_msg_count  number;
   l_msg_data   varchar2(2000);
   l_quota_assign_id  number := 0;
   l_object_version_number  number := 0;
   CURSOR l_quota_assign_id_csr(p_cp_id number, p_pe_id number)IS
     SELECT quota_assign_id, object_version_number, org_id
       FROM cn_quota_assigns
       WHERE comp_plan_id = p_cp_id
       AND quota_id = p_pe_id;

   l_org_id NUMBER;
   l_status VARCHAR2(1);
   old_org_id NUMBER;
   old_quota_id NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Quota_Assign_Pub;
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

   -- Validate and Default OrgId
   l_org_id := l_quota_assign_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id, status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.CN_QUOTA_ASSIGN_PUB.Update_Quota_Assign.org_validate',
                        'Validated org_id = ' || l_org_id || ' status = '|| l_status);
   end if;

   l_quota_assign_rec.org_id := l_org_id;

   -- Validate the input first
   validate_input_record(l_quota_assign_rec);

   if (l_quota_assign_rec.old_quota_name is NULL OR
        l_quota_assign_rec.old_quota_name = fnd_api.g_miss_char) then

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_REQ_PAR_MISSING');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
   end if;


   l_comp_plan_id := validate_cp_name(l_quota_assign_rec.comp_plan_name, l_quota_assign_rec.org_id);
   l_quota_id := validate_pe_name(l_quota_assign_rec.quota_name, l_quota_assign_rec.org_id);
   old_quota_id := validate_pe_name(l_quota_assign_rec.old_quota_name, l_quota_assign_rec.org_id);


   -- get the quota assignment id from the old rec
   OPEN l_quota_assign_id_csr(l_comp_plan_id, old_quota_id);
   FETCH l_quota_assign_id_csr INTO l_quota_assign_id , l_object_version_number, old_org_id;
   CLOSE l_quota_assign_id_csr;

   -- Org id validation

   if (l_org_id <> old_org_id) then

       FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
       if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.CN_QUOTA_ASSIGN_PUB.Update_Quota_Assign.error',
                         true);
       end if;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
         FND_MSG_PUB.Add;
       END IF;

       RAISE FND_API.G_EXC_ERROR ;
  end if;

   -- now get the quota id for the new rec if necessary
 /*  if (l_quota_assign_rec.quota_name <> fnd_api.g_miss_char OR
      l_quota_assign_rec.quota_name IS NOT NULL) then
      l_quota_id := validate_pe_name(l_quota_assign_rec.quota_name);
   end if;*/

   if (l_quota_assign_id is null or l_quota_assign_id = 0) then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PLAN_ASSIGNS');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   end if;

   -- Now call the private api
   l_pvt_quota_assign_rec.comp_plan_id := l_comp_plan_id;
   l_pvt_quota_assign_rec.quota_id := l_quota_id;
   l_pvt_quota_assign_rec.quota_sequence := l_quota_assign_rec.quota_sequence;
   IF (l_pvt_quota_assign_rec.quota_sequence IS NULL OR l_pvt_quota_assign_rec.quota_sequence = FND_API.G_MISS_NUM) THEN
      l_pvt_quota_assign_rec.quota_sequence := 1;
   END IF;

   l_pvt_quota_assign_rec.object_version_number := l_object_version_number;
   l_pvt_quota_assign_rec.quota_assign_id := l_quota_assign_id;
   l_pvt_quota_assign_rec.org_id := l_quota_assign_rec.org_id;

   cn_quota_assign_pvt.update_quota_assign
     ( p_api_version           =>1.0,
     p_init_msg_list         => FND_API.G_FALSE,
     p_commit                => FND_API.G_FALSE,
     p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
     p_quota_assign          => l_pvt_quota_assign_rec,
     x_return_status         => l_return_status,
     x_msg_count             => l_msg_count,
     x_msg_data              => l_msg_data);

   x_return_status := l_return_status;
   x_msg_count := l_msg_count;
   x_msg_data := l_msg_data;

   -- if the private API returned anything other than S just pass on
   -- the errors and exit
   if (l_return_status = 'E') then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_status = 'U') THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

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
     ROLLBACK TO Update_Quota_Assign_Pub;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Quota_Assign_Pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Quota_Assign_Pub;
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
END Update_Quota_Assign;

-- Start of comments
--      API name      : Delete_Quota_Assign
--      Type          : Public
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version       IN NUMBER       Required
--                      p_init_msg_list     IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit            IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level  IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_quota_assign_rec  IN  quota_assign_rec_type
--      OUT           : x_return_status     OUT     VARCHAR2(1)
--                      x_msg_count         OUT     NUMBER
--                      x_msg_data          OUT     VARCHAR2(2000)
--      Version :       Current version       1.0
--                      Initial version       1.0
--
--      Notes         : Note text
--
-- End of comments
PROCEDURE Delete_Quota_Assign
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_quota_assign_rec            IN      quota_assign_rec_type           ,
  x_return_status                 OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY    NUMBER                          ,
  x_msg_data                      OUT NOCOPY    VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Delete_Quota_Assign';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   l_quota_assign_rec  quota_assign_rec_type := p_quota_assign_rec;
   l_comp_plan_id  number := 0;
   l_quota_id  number := 0;
   l_pvt_quota_assign_rec   cn_quota_assign_pvt.quota_assign_rec_type;
   l_return_status  varchar2(1);
   l_msg_count  number;
   l_msg_data   varchar2(2000);
   l_quota_assign_id  number := 0;
   l_object_version_number  number := 0;
   CURSOR l_quota_assign_id_csr(p_cp_id number, p_pe_id number)IS
     SELECT quota_assign_id, object_version_number, org_id
       FROM cn_quota_assigns
       WHERE comp_plan_id = p_cp_id
       AND quota_id = p_pe_id;

   l_org_id NUMBER;
   l_status VARCHAR2(1);
   old_org_id NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Quota_Assign_Pub;
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
   -- Validate and Default OrgId
   l_org_id := l_quota_assign_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id, status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'cn.plsql.CN_QUOTA_ASSIGN_PUB.Delete_Quota_Assign.org_validate',
                        'Validated org_id = ' || l_org_id || ' status = '|| l_status);
   end if;

   l_quota_assign_rec.org_id := l_org_id;


   -- Validate the input first
   validate_input_record(l_quota_assign_rec);
   l_comp_plan_id := validate_cp_name(l_quota_assign_rec.comp_plan_name,l_quota_assign_rec.org_id);
   l_quota_id := validate_pe_name(l_quota_assign_rec.quota_name,l_quota_assign_rec.org_id);

   -- get the quota assignment id
   OPEN l_quota_assign_id_csr(l_comp_plan_id, l_quota_id);
   FETCH l_quota_assign_id_csr INTO l_quota_assign_id , l_object_version_number, old_org_id;
   CLOSE l_quota_assign_id_csr;

   -- Org id validation

    if (l_org_id <> old_org_id) then

	  FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
	  if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
			    'cn.plsql.CN_QUOTA_ASSIGN_PUB.Delete_Quota_Assign.error',
			    true);
	  end if;

	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
	    FND_MSG_PUB.Add;
	  END IF;

	  RAISE FND_API.G_EXC_ERROR ;
   end if;

   if (l_quota_assign_id is null or l_quota_assign_id = 0) then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PLAN_ASSIGNS');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   end if;

   -- Now call the private api
   l_pvt_quota_assign_rec.comp_plan_id := l_comp_plan_id;
   l_pvt_quota_assign_rec.quota_id := l_quota_id;
   l_pvt_quota_assign_rec.quota_sequence := l_quota_assign_rec.quota_sequence;
   l_pvt_quota_assign_rec.object_version_number := l_object_version_number;
   l_pvt_quota_assign_rec.quota_assign_id := l_quota_assign_id;
	 l_pvt_quota_assign_rec.org_id := l_quota_assign_rec.org_id;

   cn_quota_assign_pvt.delete_quota_assign
     ( p_api_version           =>1.0,
     p_init_msg_list         => FND_API.G_FALSE,
     p_commit                => FND_API.G_FALSE,
     p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
     p_quota_assign          => l_pvt_quota_assign_rec,
     x_return_status         => l_return_status,
     x_msg_count             => l_msg_count,
     x_msg_data              => l_msg_data);

   x_return_status := l_return_status;
   x_msg_count := l_msg_count;
   x_msg_data := l_msg_data;

   -- if the private API returned anything other than S just pass on
   -- the errors and exit
   if (l_return_status = 'E') then
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_status = 'U') THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

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
     ROLLBACK TO Delete_Quota_Assign_Pub;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Quota_Assign_Pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Delete_Quota_Assign_Pub;
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
END Delete_Quota_Assign;

END CN_QUOTA_ASSIGN_PUB;

/
