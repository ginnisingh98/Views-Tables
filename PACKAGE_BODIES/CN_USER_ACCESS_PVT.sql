--------------------------------------------------------
--  DDL for Package Body CN_USER_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_USER_ACCESS_PVT" AS
--$Header: cnvurasb.pls 115.10 2003/12/30 22:36:42 sbadami noship $

G_PKG_NAME                  CONSTANT VARCHAR2(30):= 'CN_USER_ACCESS_PVT';

-- Start of comments
--    API name        : Create_User_Access
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--                      x_user_access_id
--    Version         : 1.0
--
-- End of comments

PROCEDURE Create_User_Access
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      user_access_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_user_access_id             OUT NOCOPY     NUMBER) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Create_User_Access';
   l_api_version                CONSTANT NUMBER       := 1.0;

   l_newrec                     user_access_rec_type := p_rec;
   l_count                      NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_User_Access;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --  make sure the access level for the current comp group and org
   --  isn't already assigned
   select count(user_access_id) into l_count
     from cn_user_accesses
    where user_id      = l_newrec.user_id
     and comp_group_id = l_newrec.comp_group_id
     and org_code      = l_newrec.org_code;
   IF l_count > 0 THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_ACCESS_DUP_ERR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   cn_user_access_pkg.insert_row(l_newrec);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_User_Access;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_User_Access;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Create_User_Access;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Create_User_Access;

-- Start of comments
--    API name        : Update_User_Access
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_rec of table rec type
--    OUT             : standard params
--    Version         : 1.0
--
-- End of comments

PROCEDURE Update_User_Access
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rec                        IN      user_access_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Update_User_Access';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_newrec                     user_access_rec_type := p_rec;
   l_count                      NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_User_Access;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- make sure record to be updated exists.
   select count(*) into l_count
     from cn_user_accesses
    where user_access_id = l_newrec.user_access_id;

   if l_count = 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_UPDATE_REC');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   --  make sure the access level for the current comp group and org
   --  isn't already assigned
   select count(user_access_id) into l_count
     from cn_user_accesses
    where user_id         = l_newrec.user_id
      and comp_group_id   = l_newrec.comp_group_id
      and org_code        = l_newrec.org_code
      and user_access_id <> l_newrec.user_access_id;
   IF l_count > 0 THEN
      FND_MESSAGE.SET_NAME ('CN' , 'CN_ACCESS_DUP_ERR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- make sure the object version number hasn't changed in the meantime
   cn_user_access_pkg.lock_row(l_newrec.user_access_id,
			       l_newrec.object_version_number);

   cn_user_access_pkg.update_row(l_newrec);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_User_Access;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_User_Access;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Update_User_Access;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Update_User_Access;

-- Start of comments
--    API name        : Delete_User_Access
--    Pre-reqs        : None.
--    IN              : standard params
--                      p_user_access_id
--    OUT             : standard params
--    Version         : 1.0
--
-- End of comments

PROCEDURE Delete_User_Access
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_user_access_id             IN      NUMBER,
   p_object_version_number      IN      NUMBER,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_User_Access';
   l_api_version                CONSTANT NUMBER       := 1.0;
   l_count                      NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_User_Access;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- make sure record to be deleted exists.
   select count(*) into l_count
     from cn_user_accesses
    where user_access_id = p_user_access_id;

   if l_count = 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_DEL_REC');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- make sure the object version number hasn't changed in the meantime
   cn_user_access_pkg.lock_row(p_user_access_id,
			       p_object_version_number);

   cn_user_access_pkg.delete_row(p_user_access_id);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_User_Access;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_User_Access;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Job_Role;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Delete_User_Access;

-- Start of comments
--    API name        : Get_Accesses - Private
--    Pre-reqs        : None.
--    IN              : range params
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Accesses
  (p_range_low                  IN      NUMBER,
   p_range_high                 IN      NUMBER,
   x_total_rows                 OUT NOCOPY     NUMBER,
   x_result_tbl                 OUT NOCOPY     user_access_sum_tbl_type) IS

   rec                          user_access_sum_rec_type;
   l_index                      NUMBER := 0;

   l_org_id                     VARCHAR2(30);

   cursor get_data (c_fm_resp_key IN VARCHAR2) is
   SELECT DISTINCT f.user_id, p.full_name, f.user_name
     FROM fnd_user_resp_groups fr, fnd_user f,
          fnd_responsibility_vl r, per_all_people_f p
    WHERE f.user_id = fr.user_id
      AND fr.responsibility_id = r.responsibility_id
      AND r.application_id = 283
      AND r.responsibility_key = c_fm_resp_key
      AND f.employee_id = p.person_id(+)
     AND trunc(sysdate) BETWEEN p.effective_start_date(+) AND
      nvl(p.effective_end_date(+), trunc(sysdate))
   ORDER BY 3,2;

   cursor get_resp IS
     SELECT responsibility_id, responsibility_key
       FROM fnd_responsibility
       WHERE application_id = 283
     AND sysdate BETWEEN start_date AND nvl(end_date, sysdate)
       ;

    l_fm_resp_key VARCHAR2(30) := NULL;

BEGIN
   x_total_rows   := 0;

   l_org_id := fnd_profile.value('ORG_ID');

   FOR resp_rec IN get_resp LOOP
      IF fnd_profile.value_specific(name => 'CN_SFP_RESP_GROUP', responsibility_id => resp_rec.responsibility_id) = 'CN_SF_FINANCE_MGR' THEN
	 IF NVL(fnd_profile.value_specific(name => 'ORG_ID', responsibility_id => resp_rec.responsibility_id),-9999) = nvl(l_org_id,-9999) THEN
	    l_fm_resp_key := resp_rec.responsibility_key;
	    END IF;
      END IF;
   END LOOP;

   /* Add this check
   IF l_fm_resp_key IS NULL THEN
      IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('CN', 'CN_QM_NO_FM');
            FND_MSG_PUB.Add;
       END IF;
      RAISE FND_API.G_EXC_error;
   END IF;
   */



   open get_data(l_fm_resp_key);
   loop
      fetch get_data into rec;
      exit when get_data%notfound;

      x_total_rows := x_total_rows + 1;
      if (x_total_rows between p_range_low and p_range_high) OR
         (p_range_high = -1) then
         l_index := l_index + 1;
         x_result_tbl(l_index) := rec;
      end if;
   end loop;
   close get_data;

END Get_Accesses;

-- Start of comments
--    API name        : Get_Access_Details - Private
--    Pre-reqs        : None.
--    IN              : p_user_id
--    OUT             : x_result_tbl
--    Version :         Current version       1.0
--
-- End of comments

PROCEDURE Get_Access_Details
  (p_user_id                    IN      NUMBER,
   x_result_tbl                 OUT NOCOPY     user_access_tbl_type) IS

   l_count                      NUMBER  := 1;

   cursor get_data is
   SELECT user_access_id, user_id, comp_group_id, org_code, access_code,
	  object_version_number
     FROM cn_user_accesses
    WHERE user_id = p_user_id
    ORDER BY 3,5;

BEGIN
   for c in get_data loop
      x_result_tbl(l_count).user_access_id        := c.user_access_id;
      x_result_tbl(l_count).user_id               := c.user_id;
      x_result_tbl(l_count).comp_group_id         := c.comp_group_id;
      x_result_tbl(l_count).org_code              := c.org_code;
      x_result_tbl(l_count).access_code           := c.access_code;
      x_result_tbl(l_count).object_version_number := c.object_version_number;
      l_count := l_count + 1;
   end loop;
END Get_Access_Details;

END CN_USER_ACCESS_PVT;

/
