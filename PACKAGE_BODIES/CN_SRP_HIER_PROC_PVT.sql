--------------------------------------------------------
--  DDL for Package Body CN_SRP_HIER_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_HIER_PROC_PVT" AS
  /*$Header: cnvsrhrb.pls 115.16 2002/11/21 21:19:11 hlchen ship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30):='cn_srp_hier_proc_pvt';
G_LAST_UPDATE_DATE          DATE := Sysdate;
G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
G_CREATION_DATE             DATE := Sysdate;
G_CREATED_BY                NUMBER := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

--{{{ find_end_date
FUNCTION find_end_date (p_date1 date,
                        p_date2 date) RETURN date IS
BEGIN
   IF p_date1 IS NULL THEN
      RETURN p_date2;
   ELSIF p_date2 IS NULL THEN
      RETURN p_date1;
   ELSE
      RETURN least(p_date1 , p_date2);
   END IF;
END find_end_date;
--}}}

--{{{ get_ancestor_group
-- API name 	: get_ancestor_group
-- Type	        : Private.
-- Pre-reqs	: None
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_group               IN input_group_type Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_group               OUT group_tbl_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_ancestor_group
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_group                 IN  input_group_type,
  x_group                 IN OUT NOCOPY group_tbl_type,
  p_level                 IN number := 0) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'get_ancestor_group';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter      NUMBER(15) := 0;
   l_group        input_group_type;

   CURSOR groups_csr IS
     SELECT parent_comp_group_id parent_group_id,
       trunc(start_date_active) start_date, trunc(end_date_active) end_date
	FROM cn_qm_group_hier
	WHERE comp_group_id = p_group.group_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_ancestor_group;

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
   l_counter := x_group.count;
   FOR eachgroup IN groups_csr LOOP

      IF (eachgroup.start_date <= p_group.effective_date AND
        (eachgroup.end_date IS NULL
        OR eachgroup.end_date >= p_group.effective_date)) THEN

         l_counter := x_group.count + 1;
         x_group(l_counter).group_id   := eachgroup.parent_group_id;
	 x_group(l_counter).start_date := eachgroup.start_date;
         x_group(l_counter).end_date   := eachgroup.end_date;
         x_group(l_counter).hier_level := p_level+1;

         l_group.group_id := eachgroup.parent_group_id;
         l_group.effective_date := p_group.effective_date;

         get_ancestor_group
           ( p_api_version   => 1.0,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_group         => l_group,
           x_group         => x_group,
           p_level         => p_level + 1);

      END IF;

   END LOOP;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_ancestor_group;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_ancestor_group;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO get_ancestor_group;
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
	p_data                  =>      x_msg_data               );

END get_ancestor_group;
--}}}

--{{{ get_descendant_group
-- API name 	: get_descendant_group
-- Type	        : Private.
-- Pre-reqs	: None
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_group               IN input_group_type Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_group               OUT group_tbl_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_descendant_group
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_group                 IN  input_group_type,
  x_group                 IN OUT NOCOPY group_tbl_type,
  p_level                 IN number) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'get_descendant_group';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter      NUMBER(15) := 0;
   l_group        input_group_type;

   CURSOR groups_csr IS
      SELECT comp_group_id group_id,
	trunc(start_date_active) start_date,
	trunc(end_date_active) end_date
	FROM cn_qm_group_hier
	WHERE parent_comp_group_id = p_group.group_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_descendant_group;

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
   l_counter := x_group.count;
   FOR eachgroup IN groups_csr LOOP

      IF (eachgroup.start_date <= p_group.effective_date AND
        (eachgroup.end_date IS NULL
        OR eachgroup.end_date >= p_group.effective_date)) THEN

         l_counter :=  x_group.count + 1;
         x_group(l_counter).group_id   := eachgroup.group_id;
         x_group(l_counter).start_date := eachgroup.start_date;
	 x_group(l_counter).end_date   := eachgroup.end_date;
         x_group(l_counter).hier_level := p_level + 1;

         l_group.group_id := eachgroup.group_id;
         l_group.effective_date := p_group.effective_date;

         get_descendant_group
           ( p_api_version   => 1.0,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_group         => l_group,
           x_group         => x_group,
           p_level         => p_level + 1);

      END IF;

   END LOOP;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_descendant_group;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_descendant_group;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO get_descendant_group;
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
	p_data                  =>      x_msg_data               );

END get_descendant_group;
--}}}

--{{{ get_managers
-- Start of comments
--    API name        : Get_Managers
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
--                      p_salesrep_id         IN NUMBER       Required
--                      p_comp_group_id       IN NUMBER       Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_salesrep_tbl        OUT srp_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Managers
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_salesrep_id                 IN      number                          ,
  p_comp_group_id               IN      number                          ,
  p_effective_date              IN      date                            ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ,
  x_salesrep_tbl                OUT NOCOPY     srp_role_group_tbl_type         ,
  x_returned_rows               OUT NOCOPY     integer                         ) IS

   l_api_name                      CONSTANT VARCHAR2(30) := 'Get_Managers';
   l_api_version                   CONSTANT NUMBER       := 1.0;
   l_comp_group_id                 number := 0;
   l_count                         number := 0;

   CURSOR l_srp_role_id_csr IS
     SELECT srp_role_id, comp_group_id, trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active
       FROM cn_qm_srp_groups
       WHERE srp_id = p_salesrep_id
       AND manager_flag = 'N';

   CURSOR l_mgr_role_id_csr IS
     SELECT manager_srp_id, comp_group_id, trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active, role_id
       FROM cn_qm_mgr_groups
       WHERE comp_group_id = l_comp_group_id;

   CURSOR l_parent_grp_srp_csr IS
     SELECT srp_id, comp_group_id, trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active, role_id
       FROM cn_qm_srp_groups
       WHERE comp_group_id = l_comp_group_id;

   CURSOR l_mgr_group_csr is
     SELECT 1
       FROM cn_qm_mgr_groups
       WHERE manager_srp_id = p_salesrep_id;

   CURSOR l_parent_group_csr is
     SELECT parent_comp_group_id
       FROM cn_qm_group_hier
       WHERE comp_group_id = l_comp_group_id
       AND trunc(start_date_active) <= p_effective_date
       AND (trunc(end_date_active) >= p_effective_date
       OR end_date_active IS NULL);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_managers_pvt;
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
   -- select the group_member_ids for this srp
   FOR eachrow in l_srp_role_id_csr LOOP
      -- filter the rows that contain the effective date
      IF (eachrow.start_date_active <= p_effective_date and
        (eachrow.end_date_active >= p_effective_date or
        eachrow.end_date_active is null)) THEN
         -- get the manager group member ids for each row
         -- get the srp ids for each of those groups
         l_comp_group_id := eachrow.comp_group_id;
         FOR eachassgn in l_mgr_role_id_csr LOOP
            IF (eachassgn.start_date_active <= p_effective_date and
              (eachassgn.end_date_active >= p_effective_date or
              eachassgn.end_date_active is null)) THEN
               l_count := l_count + 1;
               x_salesrep_tbl(l_count).salesrep_id := eachassgn.manager_srp_id;
               x_salesrep_tbl(l_count).group_id := eachassgn.comp_group_id;
               x_salesrep_tbl(l_count).role_id := eachassgn.role_id;
               x_salesrep_tbl(l_count).start_date := eachassgn.start_date_active;
               x_salesrep_tbl(l_count).end_date := eachassgn.end_date_active;
            END IF;
         END LOOP;
      END IF;
   END LOOP;

   -- we need to handle the fact that this person could be a manager of the
   -- group; which means that we have to get all the salesreps and managers
   -- from the parent group
   IF (l_count = 0) THEN
      FOR eachrow in l_mgr_group_csr LOOP
         l_count := l_count + 1;
      END LOOP;
      IF (l_count > 0) THEN
         l_count := 0;
         l_comp_group_id := p_comp_group_id;
         -- this means that the salesrep in a manager in the group
         OPEN l_parent_group_csr;
         FETCH l_parent_group_csr INTO l_comp_group_id;
         CLOSE l_parent_group_csr;

         --make sure that we do not return a wrong row
         --with the person as manager FOR himself
         IF (l_comp_group_id = p_comp_group_id) THEN
            RETURN;
         END IF;

         -- salesreps in parent groups do not count as managers
         -- so this section is commented out
         --FOR eachsrpassgn IN l_parent_grp_srp_csr LOOP
         --   l_count := l_count + 1;
         --   x_salesrep_tbl(l_count) := eachsrpassgn.srp_id;
         --END LOOP;
         FOR eachmgrassgn IN l_mgr_role_id_csr LOOP
            l_count := l_count + 1;
            x_salesrep_tbl(l_count).salesrep_id := eachmgrassgn.manager_srp_id;
            x_salesrep_tbl(l_count).group_id := eachmgrassgn.comp_group_id;
            x_salesrep_tbl(l_count).role_id := eachmgrassgn.role_id;
            x_salesrep_tbl(l_count).start_date := eachmgrassgn.start_date_active;
            x_salesrep_tbl(l_count).end_date := eachmgrassgn.end_date_active;
         END LOOP;
      END IF;
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
     ROLLBACK TO get_managers_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_managers_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO get_managers_pvt;
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
END Get_Managers;
--}}}

--{{{ get_salesreps
-- Start of comments
--    API name        : Get_Salesreps
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
--                      p_salesrep_id         IN NUMBER       Required
--                      p_comp_group_id       IN NUMBER       Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_salesrep_tbl        OUT srp_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Salesreps
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_salesrep_id                 IN      number                          ,
  p_comp_group_id               IN      number                          ,
  p_effective_date              IN      date                            ,
  p_return_current              IN      varchar2 := 'N'                 ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ,
  x_salesrep_tbl                OUT NOCOPY     srp_role_group_tbl_type         ,
  x_returned_rows               OUT NOCOPY     integer                         ) IS

   l_api_name                      CONSTANT VARCHAR2(30) := 'Get_Salesreps';
   l_api_version                   CONSTANT NUMBER       := 1.0;
   l_comp_group_id                 number := 0;
   l_count                         number := 0;

   CURSOR l_mgr_role_id_csr IS
     SELECT srp_role_id, comp_group_id, trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active, role_id, manager_srp_id
       FROM cn_qm_mgr_groups
       WHERE manager_srp_id = p_salesrep_id
       AND comp_group_id = p_comp_group_id;

   CURSOR l_srp_role_id_csr IS
     SELECT srp_id, comp_group_id, trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active, role_id
       FROM cn_qm_srp_groups
       WHERE comp_group_id = l_comp_group_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_salesreps_pvt;
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
   -- select the group_member_ids for this srp
   FOR eachrow in l_mgr_role_id_csr LOOP
      -- filter the rows that contain the effective date
      IF (eachrow.start_date_active <= p_effective_date and
        (eachrow.end_date_active >= p_effective_date or
        eachrow.end_date_active is null)) THEN
         -- get the manager group member ids for each row
         -- get the srp ids for each of those groups
         IF (p_return_current = 'Y') THEN
            l_count := l_count + 1;
            x_salesrep_tbl(l_count).salesrep_id := p_salesrep_id;
            x_salesrep_tbl(l_count).group_id := eachrow.comp_group_id;
            x_salesrep_tbl(l_count).role_id := eachrow.role_id;
            x_salesrep_tbl(l_count).start_date := eachrow.start_date_active;
            x_salesrep_tbl(l_count).end_date := eachrow.end_date_active;
         END IF;
         l_comp_group_id := p_comp_group_id;
         FOR eachassgn in l_srp_role_id_csr LOOP
            IF (eachassgn.start_date_active <= p_effective_date and
              (eachassgn.end_date_active >= p_effective_date or
              eachassgn.end_date_active is null)) THEN
               l_count := l_count + 1;
               x_salesrep_tbl(l_count).salesrep_id := eachassgn.srp_id;
               x_salesrep_tbl(l_count).group_id := eachassgn.comp_group_id;
               x_salesrep_tbl(l_count).role_id := eachassgn.role_id;
               x_salesrep_tbl(l_count).start_date := eachassgn.start_date_active;
               x_salesrep_tbl(l_count).end_date := eachassgn.end_date_active;
               x_salesrep_tbl(l_count).mgr_srp_id := p_salesrep_id;
            END IF;
         END LOOP;
      END IF;
   END LOOP;

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
     ROLLBACK TO get_salesreps_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_salesreps_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO get_salesreps_pvt;
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
END Get_Salesreps;
--}}}

--{{{ get_ancestor_salesreps

-- Start of comments
--    API name        : Get_Ancestor_Salesreps
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
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_group_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Ancestor_Salesreps
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_group_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name       CONSTANT VARCHAR2(30) := 'get_ancestor_salesreps';
   l_api_version    CONSTANT NUMBER       := 1.0;

   l_counter        NUMBER(15);
   l_group          input_group_type;
   l_ancestor_group group_tbl_type;
   l_srp_tbl        srp_role_group_tbl_type;
   l_returned_rows  number;

   CURSOR managers_csr(p_group_id NUMBER) IS
     SELECT manager_srp_id salesrep_id, role_id ,comp_group_id,
       trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active
       FROM cn_qm_mgr_groups
       WHERE comp_group_id = p_group_id
       AND manager_srp_id <> p_srp.salesrep_id
       AND manager_flag = 'Y';

   CURSOR members_csr(p_group_id NUMBER) IS
     SELECT srp_id salesrep_id, role_id, comp_group_id,
       trunc(start_date_active) start_date, trunc(end_date_active) end_date
       FROM cn_qm_mgr_srp_groups
       WHERE comp_group_id = p_group_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_ancestor_salesrep;

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

   l_counter := 0;

   -- find all managers in this group

   FOR eachmgr IN managers_csr(p_srp.group_id) LOOP

      IF (eachmgr.start_date_active <= p_srp.effective_date AND
              (eachmgr.end_date_active IS NULL
              OR eachmgr.end_date_active >= p_srp.effective_date)) THEN

         get_managers(p_api_version     => 1.0,
           p_salesrep_id                => eachmgr.salesrep_id,
           p_comp_group_id              => p_srp.group_id,
           p_effective_date             => p_srp.effective_date,
           x_return_status              => x_return_status,
           x_msg_count                  => x_msg_count,
           x_msg_data                   => x_msg_data,
           x_salesrep_tbl               => l_srp_tbl,
           x_returned_rows              => l_returned_rows);
         IF (l_srp_tbl.count > 0) THEN
            FOR i in l_srp_tbl.first .. l_srp_tbl.last LOOP
               l_counter := l_counter + 1;
               x_srp(l_counter).salesrep_id := eachmgr.salesrep_id;
               x_srp(l_counter).group_id    := p_srp.group_id;
               x_srp(l_counter).role_id     := eachmgr.role_id;
               x_srp(l_counter).start_date  := eachmgr.start_date_active;
               x_srp(l_counter).end_date    := eachmgr.end_date_active;
               x_srp(l_counter).mgr_srp_id := l_srp_tbl(i).salesrep_id;
            END LOOP;
         END IF;
      END IF;

   END LOOP;

   -- loop through reach ancestor group.
   l_group.group_id := p_srp.group_id;
   l_group.effective_date := p_srp.effective_date;

   get_ancestor_group
     ( p_api_version   => 1.0,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_group         => l_group,
       x_group         => l_ancestor_group);

   IF x_return_status = FND_API.g_ret_sts_error THEN

      RAISE FND_API.g_exc_error;

   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

      RAISE FND_API.g_exc_unexpected_error;

   END IF;

   IF( l_ancestor_group.COUNT > 0) THEN
      FOR eachgroup IN l_ancestor_group.first .. l_ancestor_group.last LOOP

         FOR eachsrp IN members_csr(l_ancestor_group(eachgroup).group_id) LOOP

	    IF (eachsrp.start_date <= p_srp.effective_date AND
              (eachsrp.end_date IS NULL
              OR eachsrp.end_date >= p_srp.effective_date)) THEN

               l_srp_tbl.DELETE;
               get_managers(p_api_version     => 1.0,
                 p_salesrep_id                => eachsrp.salesrep_id,
                 p_comp_group_id              => l_ancestor_group(eachgroup).group_id,
                 p_effective_date             => p_srp.effective_date,
                 x_return_status              => x_return_status,
                 x_msg_count                  => x_msg_count,
                 x_msg_data                   => x_msg_data,
                 x_salesrep_tbl               => l_srp_tbl,
                 x_returned_rows              => l_returned_rows);

               IF (l_srp_tbl.count > 0) THEN
                  FOR i in l_srp_tbl.first .. l_srp_tbl.last LOOP
                     l_counter := l_counter + 1;
                     x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;
                     x_srp(l_counter).group_id    :=
                       l_ancestor_group(eachgroup).group_id;
                     x_srp(l_counter).role_id := eachsrp.role_id;
                     x_srp(l_counter).start_date  := eachsrp.start_date;
                     x_srp(l_counter).end_date    := eachsrp.end_date;
                     x_srp(l_counter).mgr_srp_id := l_srp_tbl(i).salesrep_id;
                  END LOOP;
               END IF;


	    END IF; -- end of check date_range_overlap

	 END LOOP; -- end of eachsrp

      END LOOP; -- end of eachgroup
   END IF;


   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_ancestor_salesrep;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_ancestor_salesrep;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO get_ancestor_salesrep;
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
	p_data                  =>      x_msg_data               );

END Get_Ancestor_Salesreps;

--}}}

--{{{ get_descendant_salesreps

-- Start of comments
--    API name        : Get_Descendant_Salesreps
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
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_group_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Descendant_Salesreps
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_group_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'get_descendant_salesreps';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter        NUMBER(15) := 0;
   l_group          input_group_type;
   l_descendant_group group_tbl_type;
   l_mgr_flag       VARCHAR2(1) := 'N';
   l_srp_tbl        srp_role_group_tbl_type;
   l_returned_rows  number;

   CURSOR members_csr(p_group_id NUMBER) IS
     SELECT srp_id salesrep_id, trunc(start_date_active) start_date,
       trunc(end_date_active) end_date, role_id, comp_group_id, manager_flag
       FROM cn_qm_mgr_srp_groups
       WHERE comp_group_id = p_group_id
       ORDER BY manager_flag DESC;

   CURSOR mgr_check IS
      SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_descendant_salesreps;

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

   IF (p_return_current = 'Y') THEN
      FOR eachmem IN members_csr(p_srp.group_id) LOOP
         IF (eachmem.start_date <= p_srp.effective_date AND
              (eachmem.end_date IS NULL
              OR eachmem.end_date >= p_srp.effective_date))
           AND eachmem.salesrep_id = p_srp.salesrep_id THEN

            l_counter := l_counter + 1;
            x_srp(l_counter).salesrep_id := eachmem.salesrep_id;
            x_srp(l_counter).group_id    := p_srp.group_id;
            x_srp(l_counter).role_id    := eachmem.role_id;
            x_srp(l_counter).start_date  := eachmem.start_date;
            x_srp(l_counter).end_date    := eachmem.end_date;
            x_srp(l_counter).mgr_srp_id := p_srp.salesrep_id;
            x_srp(l_counter).hier_level := 0;
         END IF;
      END LOOP;
   END IF;


   -- if p_srp.salesrep_id is a manager, get the other members of his own group
   OPEN mgr_check;
   FETCH mgr_check INTO l_mgr_flag;
   CLOSE mgr_check;

   IF (l_mgr_flag = 'Y') THEN
      FOR eachmem IN members_csr(p_srp.group_id) LOOP
         IF (eachmem.start_date <= p_srp.effective_date AND
              (eachmem.end_date IS NULL
              OR eachmem.end_date >= p_srp.effective_date))
           AND eachmem.salesrep_id <> p_srp.salesrep_id THEN

            l_counter := l_counter + 1;
	    x_srp(l_counter).salesrep_id := eachmem.salesrep_id;
	    x_srp(l_counter).group_id    := p_srp.group_id;
	    x_srp(l_counter).role_id    := eachmem.role_id;
            x_srp(l_counter).start_date  := eachmem.start_date;
            x_srp(l_counter).end_date    := eachmem.end_date;
            x_srp(l_counter).mgr_srp_id := p_srp.salesrep_id;
            x_srp(l_counter).hier_level := 0;
	 END IF;
      END LOOP;


   -- initialize l_group
   l_group.group_id := p_srp.group_id;
   l_group.effective_date := p_srp.effective_date;

   get_descendant_group
     ( p_api_version   => 1.0,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_group         => l_group,
       x_group         => l_descendant_group,
       p_level         => 0);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (l_descendant_group.COUNT > 0) THEN
      FOR eachgroup IN l_descendant_group.first .. l_descendant_group.last LOOP
         FOR eachsrp IN members_csr(l_descendant_group(eachgroup).group_id) LOOP
	    IF (eachsrp.start_date <= p_srp.effective_date AND
              (eachsrp.end_date IS NULL
              OR eachsrp.end_date >= p_srp.effective_date)) THEN

               l_counter := l_counter + 1;
               x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;
               x_srp(l_counter).group_id    :=
                 l_descendant_group(eachgroup).group_id;
               x_srp(l_counter).role_id    := eachsrp.role_id;
               x_srp(l_counter).start_date  := eachsrp.start_date;
               x_srp(l_counter).end_date    := eachsrp.end_date;
               x_srp(l_counter).mgr_srp_id := eachsrp.salesrep_id;
               x_srp(l_counter).hier_level := l_descendant_group(eachgroup).hier_level;
            END IF; -- end of check date_range_overlap
	 END LOOP; -- end of eachsrp
      END LOOP; -- end of eachgroup
   END IF;

   END IF; -- end of IF (l_mgr_flag = 'Y') THEN

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_descendant_salesreps;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_descendant_salesreps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO get_descendant_salesreps;
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
	p_data                  =>      x_msg_data               );

END Get_Descendant_Salesreps;

--}}}
--{{{ get_descendant_group_mbrs

-- Start of comments
--    API name        : Get_Descendant_group_mbrs
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
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT group_mbr_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_Descendant_group_mbrs
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  p_level                  IN  number := 0,
  p_first_level_only       IN  varchar2 := 'N',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    IN OUT NOCOPY group_mbr_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'Get_Descendant_group_mbrs';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter        NUMBER(15) := 0;

   l_srp          srp_group_rec_type;

   l_mgr_srp_id     NUMBER;
   l_returned_rows  number;
   l_mgr_flag VARCHAR2(1);

   CURSOR groups_csr(p_group_id NUMBER, i_level NUMBER) IS
     SELECT
      g.group_id group_id,
        trunc(g.start_date_active) start_date,
        trunc(g.end_date_active) end_date
      FROM jtf_rs_groups_vl g, jtf_rs_group_usages u
      WHERE
          g.group_id = p_group_id
         AND  g.group_id = u.group_id
         AND u.usage='SF_PLANNING'
         AND i_level = 0
      UNION ALL
    SELECT  r.group_id group_id,
        trunc(r.start_date_active) start_date,
        trunc(r.end_date_active) end_date
     FROM jtf_rs_grp_relations r,
      jtf_rs_group_usages u1,
      jtf_rs_group_usages u2
     WHERE
       u1.group_id = r.group_id
      AND u2.group_id = r.related_group_id
      AND u1.usage='SF_PLANNING'
      AND u2.usage='SF_PLANNING'
      AND r.delete_flag = 'N'
      AND r.related_group_id = p_group_id
   ;

   CURSOR grp_members_csr(p_group_id NUMBER) IS
     SELECT DISTINCT jrs.salesrep_id salesrep_id
       FROM jtf_rs_group_members jgm,
            jtf_rs_salesreps_mo_v jrs
       WHERE jgm.group_id = p_group_id
       AND jgm.resource_id = jrs.resource_id
       AND nvl(jgm.delete_flag,'N') = 'N'
     ;

   CURSOR grp_mgr(p_group_id NUMBER) IS
      SELECT NVL(MAX(manager_srp_id),0) -- will return null if grp has no manager
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_group_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);

   CURSOR mgr_check IS
      SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Descendant_group_mbrs;


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

   -- If salesrep is not a manager then dont proceed
  OPEN mgr_check;
  FETCH mgr_check INTO l_mgr_flag;
  CLOSE mgr_check;

  IF (l_mgr_flag = 'Y') THEN


   l_counter := x_srp.count;

   -- dbms_output.put_line('lcount = ' || to_char(l_counter));


   FOR eachgroup IN groups_csr(p_srp.group_id, p_level) LOOP

   -- dbms_output.put_line('par ' || to_char(p_srp.group_id) || 'chi ' || to_char(eachgroup.group_id));


      IF (eachgroup.start_date <= p_srp.effective_date AND
        (eachgroup.end_date IS NULL
        OR eachgroup.end_date >= p_srp.effective_date)) THEN

        FOR each_grp_member IN grp_members_csr (eachgroup.group_id) LOOP

         l_counter :=  x_srp.count + 1;

         OPEN grp_mgr(eachgroup.group_id);
          FETCH grp_mgr INTO l_mgr_srp_id;
         CLOSE grp_mgr;


         IF l_mgr_srp_id = each_grp_member.salesrep_id THEN

           x_srp(l_counter).group_id   := eachgroup.group_id;
           x_srp(l_counter).salesrep_id   := each_grp_member.salesrep_id;
           x_srp(l_counter).mgr_srp_id   := p_srp.salesrep_id;
           x_srp(l_counter).hier_level := p_level + 1;

           -- dbms_output.put_line('   ++mgr=' || to_char( p_srp.salesrep_id) || 'srp=' || to_char(each_grp_member.salesrep_id));

         ELSE
           x_srp(l_counter).group_id   := eachgroup.group_id;
           x_srp(l_counter).salesrep_id   := each_grp_member.salesrep_id;
           x_srp(l_counter).mgr_srp_id   := l_mgr_srp_id;
           x_srp(l_counter).hier_level := p_level + 1;

           --      dbms_output.put_line('  +-mgr=' || to_char( l_mgr_srp_id) || 'srp=' || to_char(each_grp_member.salesrep_id));
         END IF;

       END LOOP;

         l_srp.group_id := eachgroup.group_id;
         l_srp.effective_date := p_srp.effective_date;
         l_srp.salesrep_id := l_mgr_srp_id;

         -- dbms_output.put_line('GRP=' || to_char(l_srp.group_id) || ' LEV=' || to_char(p_level));

       IF l_srp.group_id <> p_srp.group_id
            AND p_first_level_only = 'N' THEN

         get_descendant_group_mbrs
           ( p_api_version   => 1.0,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_srp         => l_srp,
           x_srp         => x_srp,
           p_level         => p_level + 1,
           x_returned_rows => x_returned_rows);

       END IF;

      END IF;

   END LOOP;

  END IF;  -- If salesrep is a manager

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Descendant_group_mbrs;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Descendant_group_mbrs;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO Get_Descendant_group_mbrs;
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
	p_data                  =>      x_msg_data               );

END Get_Descendant_group_mbrs;

-- ***********************************
-- TBD : MO
-- ***********************************
PROCEDURE Get_MO_Descendant_group_mbrs
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  p_level                  IN  number := 0,
  p_first_level_only       IN  varchar2 := 'N',
  p_is_multiorg            IN  VARCHAR2 := 'N',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    IN OUT NOCOPY group_mbr_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'Get_Descendant_group_mbrs';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter        NUMBER(15) := 0;

   l_srp          srp_group_rec_type;

   l_mgr_srp_id     NUMBER;
   l_returned_rows  number;
   l_mgr_flag VARCHAR2(1);

   CURSOR groups_csr(p_group_id NUMBER, i_level NUMBER) IS
     SELECT
      g.group_id group_id,
        trunc(g.start_date_active) start_date,
        trunc(g.end_date_active) end_date
      FROM jtf_rs_groups_vl g, jtf_rs_group_usages u
      WHERE
          g.group_id = p_group_id
         AND  g.group_id = u.group_id
         AND u.usage='SF_PLANNING'
         AND i_level = 0
      UNION ALL
    SELECT  r.group_id group_id,
        trunc(r.start_date_active) start_date,
        trunc(r.end_date_active) end_date
     FROM jtf_rs_grp_relations r,
      jtf_rs_group_usages u1,
      jtf_rs_group_usages u2
     WHERE
       u1.group_id = r.group_id
      AND u2.group_id = r.related_group_id
      AND u1.usage='SF_PLANNING'
      AND u2.usage='SF_PLANNING'
      AND r.delete_flag = 'N'
      AND r.related_group_id = p_group_id
   ;

   CURSOR grp_members_csr(p_group_id NUMBER) IS
     SELECT DISTINCT jrs.salesrep_id salesrep_id
       FROM jtf_rs_group_members jgm,
            jtf_rs_salesreps_mo_v jrs
       WHERE jgm.group_id = p_group_id
       AND jgm.resource_id = jrs.resource_id
       AND nvl(jgm.delete_flag,'N') = 'N'
     ;

   CURSOR grp_mgr(p_group_id NUMBER) IS
      SELECT NVL(MAX(manager_srp_id),0) -- will return null if grp has no manager
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_group_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);

   CURSOR mgr_check IS
      SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);

   -- Added Multi Orged based Cursors

      CURSOR mo_grp_mgr IS
      SELECT NVL(MAX(jrs.salesrep_id),0) manager_srp_id
        FROM
         jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
         jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u,
         cn_srp_role_dtls srd
        WHERE
          jg.group_id = jgm.group_id
          and jgm.manager_flag = 'Y'
          and jrs.resource_id = jgm.resource_id
          and u.group_id = jgm.group_id
          and u.usage = 'SF_PLANNING'
          and jrr.role_resource_type = 'RS_INDIVIDUAL'
          and jrr.role_resource_id = jrs.resource_id
          and jrr.role_id = jgm.role_id
          and jrr.role_id = jr.role_id
          and jr.role_type_code = 'SALES_COMP'
          and jrr.delete_flag <> 'Y'
          and jrr.start_date_active <= jgm.start_date_active
          and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
          AND jrs.SALESREP_ID > 0
          AND srd.srp_role_id = jrr.role_relate_id
          AND jgm.group_id = p_srp.group_id
          AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
          AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date);

      CURSOR mo_mgr_check IS
      SELECT jgm.manager_flag manager_flag
        FROM
         jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
         jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u,
         cn_srp_role_dtls srd
        WHERE
          jg.group_id = jgm.group_id
          and jgm.manager_flag = 'Y'
          and jrs.resource_id = jgm.resource_id
          and u.group_id = jgm.group_id
          and u.usage = 'SF_PLANNING'
          and jrr.role_resource_type = 'RS_INDIVIDUAL'
          and jrr.role_resource_id = jrs.resource_id
          and jrr.role_id = jgm.role_id
          and jrr.role_id = jr.role_id
          and jr.role_type_code = 'SALES_COMP'
          and jrr.delete_flag <> 'Y'
          and jrr.start_date_active <= jgm.start_date_active
          and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
          AND jrs.SALESREP_ID > 0
          AND srd.srp_role_id = jrr.role_relate_id
          AND jgm.group_id = p_srp.group_id
          AND jrs.salesrep_id = p_srp.salesrep_id
          AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
          AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date);

     TYPE   RC_TYPE IS REF CURSOR;
     mgr_check_rc RC_TYPE;
     grp_mgr_rc   RC_TYPE;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_MO_Descendant_group_mbrs;


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

   -- If salesrep is not a manager then dont proceed
  --OPEN mgr_check;
  --FETCH mgr_check INTO l_mgr_flag;
  --CLOSE mgr_check;

  IF p_is_multiorg = 'Y' THEN
      OPEN mgr_check_rc FOR SELECT jgm.manager_flag manager_flag
         FROM
            jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
             jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u,
             cn_srp_role_dtls srd
         WHERE
          jg.group_id = jgm.group_id
          and jgm.manager_flag = 'Y'
          and jrs.resource_id = jgm.resource_id
          and u.group_id = jgm.group_id
          and u.usage = 'SF_PLANNING'
          and jrr.role_resource_type = 'RS_INDIVIDUAL'
          and jrr.role_resource_id = jrs.resource_id
          and jrr.role_id = jgm.role_id
          and jrr.role_id = jr.role_id
          and jr.role_type_code = 'SALES_COMP'
          and jrr.delete_flag <> 'Y'
          and jrr.start_date_active <= jgm.start_date_active
          and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
          AND jrs.SALESREP_ID > 0
          AND srd.srp_role_id = jrr.role_relate_id
          AND jgm.group_id = p_srp.group_id
          AND jrs.salesrep_id = p_srp.salesrep_id
          AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
          AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date);
  ELSE
      OPEN mgr_check_rc FOR SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);
  END IF;

  LOOP
     FETCH mgr_check_rc INTO l_mgr_flag;
      EXIT WHEN mgr_check_rc%NOTFOUND;
  END LOOP;
  CLOSE  mgr_check_rc;

  IF (l_mgr_flag = 'Y') THEN


   l_counter := x_srp.count;

   -- dbms_output.put_line('lcount = ' || to_char(l_counter));


   FOR eachgroup IN groups_csr(p_srp.group_id, p_level) LOOP

   -- dbms_output.put_line('par ' || to_char(p_srp.group_id) || 'chi ' || to_char(eachgroup.group_id));


      IF (eachgroup.start_date <= p_srp.effective_date AND
        (eachgroup.end_date IS NULL
        OR eachgroup.end_date >= p_srp.effective_date)) THEN

        FOR each_grp_member IN grp_members_csr (eachgroup.group_id) LOOP

         l_counter :=  x_srp.count + 1;

         -- OPEN grp_mgr(eachgroup.group_id);
         -- FETCH grp_mgr INTO l_mgr_srp_id;
         -- CLOSE grp_mgr;
         IF p_is_multiorg = 'Y' THEN
            OPEN grp_mgr_rc FOR SELECT NVL(MAX(jrs.salesrep_id),0) manager_srp_id
                 FROM
                 jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
                 jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u,
                 cn_srp_role_dtls srd
                WHERE
                  jg.group_id = jgm.group_id
                  and jgm.manager_flag = 'Y'
                  and jrs.resource_id = jgm.resource_id
                  and u.group_id = jgm.group_id
                  and u.usage = 'SF_PLANNING'
                  and jrr.role_resource_type = 'RS_INDIVIDUAL'
                  and jrr.role_resource_id = jrs.resource_id
                  and jrr.role_id = jgm.role_id
                  and jrr.role_id = jr.role_id
                  and jr.role_type_code = 'SALES_COMP'
                  and jrr.delete_flag <> 'Y'
                  and jrr.start_date_active <= jgm.start_date_active
                  and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
                  AND jrs.SALESREP_ID > 0
                  AND srd.srp_role_id = jrr.role_relate_id
                  AND jgm.group_id = eachgroup.group_id
                  AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
                  AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date);
           ELSE
               OPEN grp_mgr_rc FOR SELECT NVL(MAX(manager_srp_id),0)
               FROM cn_qm_mgr_groups
               WHERE comp_group_id = eachgroup.group_id
               AND (trunc(start_date_active) <= p_srp.effective_date)
               AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);
           END IF;

           LOOP
             FETCH grp_mgr_rc INTO l_mgr_srp_id;
             EXIT WHEN grp_mgr_rc%NOTFOUND;
           END LOOP;
           CLOSE  grp_mgr_rc;


         IF l_mgr_srp_id = each_grp_member.salesrep_id THEN

           x_srp(l_counter).group_id   := eachgroup.group_id;
           x_srp(l_counter).salesrep_id   := each_grp_member.salesrep_id;
           x_srp(l_counter).mgr_srp_id   := p_srp.salesrep_id;
           x_srp(l_counter).hier_level := p_level + 1;

           -- dbms_output.put_line('   ++mgr=' || to_char( p_srp.salesrep_id) || 'srp=' || to_char(each_grp_member.salesrep_id));

         ELSE
           x_srp(l_counter).group_id   := eachgroup.group_id;
           x_srp(l_counter).salesrep_id   := each_grp_member.salesrep_id;
           x_srp(l_counter).mgr_srp_id   := l_mgr_srp_id;
           x_srp(l_counter).hier_level := p_level + 1;

           --      dbms_output.put_line('  +-mgr=' || to_char( l_mgr_srp_id) || 'srp=' || to_char(each_grp_member.salesrep_id));
         END IF;

       END LOOP;

         l_srp.group_id := eachgroup.group_id;
         l_srp.effective_date := p_srp.effective_date;
         l_srp.salesrep_id := l_mgr_srp_id;

         -- dbms_output.put_line('GRP=' || to_char(l_srp.group_id) || ' LEV=' || to_char(p_level));

       IF l_srp.group_id <> p_srp.group_id
            AND p_first_level_only = 'N' THEN

         get_mo_descendant_group_mbrs
           ( p_api_version   => 1.0,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_srp         => l_srp,
           p_is_multiorg => p_is_multiorg,
           x_srp         => x_srp,
           p_level         => p_level + 1,
           x_returned_rows => x_returned_rows);

       END IF;

      END IF;

   END LOOP;

  END IF;  -- If salesrep is a manager

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_MO_Descendant_group_mbrs;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_MO_Descendant_group_mbrs;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO Get_MO_Descendant_group_mbrs;
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
	p_data                  =>      x_msg_data               );

END Get_MO_Descendant_group_mbrs;


--}}}


--{{{ get_desc_role_info

-- Start of comments
--    API name        : Get_Desc_role_info
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
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_role_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_desc_role_info
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_info_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'get_desc_role_info';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter        NUMBER(15) := 0;
   l_group          input_group_type;
   l_descendant_group group_tbl_type;
   l_mgr_flag       VARCHAR2(1) := 'N';
   l_srp_tbl        srp_role_group_tbl_type;
   l_returned_rows  number;


   CURSOR members_csr(p_group_id NUMBER) IS
     SELECT srd.srp_role_id, srd.srp_id, job_title_id, overlay_flag, non_std_flag, srd.role_id role_id,
       g.role_name role_name, job_discretion, status, plan_activate_status, club_eligible_flag,
       org_code, trunc(start_date) start_date, trunc(end_date) end_date, g.comp_group_id group_id
       FROM cn_qm_mgr_srp_groups g,
            cn_srp_role_dtls_v srd
       WHERE g.comp_group_id = p_group_id
        AND g.srp_role_id = srd.srp_role_id
        AND (trunc(srd.start_date) <= p_srp.effective_date)
        AND (srd.end_date IS NULL OR trunc(srd.end_date) >= p_srp.effective_date)
        AND (trunc(g.start_date_active) <= p_srp.effective_date)
        AND (g.end_date_active IS NULL OR trunc(g.end_date_active) >= p_srp.effective_date)
        AND srd.job_title_id <> -99
       ORDER BY g.manager_flag DESC;

   CURSOR mgr_check IS
      SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_desc_role_info;

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

   -- if p_srp.salesrep_id is a manager, get the other members of his own group

   OPEN mgr_check;
   FETCH mgr_check INTO l_mgr_flag;
   CLOSE mgr_check;


   IF l_mgr_flag = 'Y' THEN


      l_counter := 0;

      FOR eachmem IN members_csr(p_srp.group_id) LOOP
         IF (eachmem.start_date <= p_srp.effective_date AND
              (eachmem.end_date IS NULL
              OR eachmem.end_date >= p_srp.effective_date))
           AND
            (
             (p_return_current = 'N' AND eachmem.srp_id <> p_srp.salesrep_id )
               OR (p_return_current = 'Y')
            )
         THEN


            l_counter := l_counter + 1;


	     x_srp(l_counter).srp_role_id := eachmem.srp_role_id   ;
	     x_srp(l_counter).srp_id  := eachmem.srp_id           ;
	     x_srp(l_counter).overlay_flag := eachmem.overlay_flag      ;
	     x_srp(l_counter).non_std_flag := eachmem.non_std_flag      ;
	     x_srp(l_counter).role_id := eachmem.role_id           ;
	     x_srp(l_counter).role_name := eachmem.role_name         ;
	     x_srp(l_counter).job_title_id := eachmem.job_title_id      ;
	     x_srp(l_counter).job_discretion := eachmem.job_discretion    ;
	     x_srp(l_counter).status := eachmem.status            ;
	     x_srp(l_counter).plan_activate_status := eachmem.plan_activate_status;
	     x_srp(l_counter).club_eligible_flag := eachmem.club_eligible_flag;
	     x_srp(l_counter).org_code := eachmem.org_code          ;
	     x_srp(l_counter).start_date := eachmem.start_date        ;
	     x_srp(l_counter).end_date := eachmem.end_date          ;
	     x_srp(l_counter).group_id := eachmem.group_id          ;


	 END IF;
      END LOOP;



   -- initialize l_group
   l_group.group_id := p_srp.group_id;
   l_group.effective_date := p_srp.effective_date;

   get_descendant_group
     ( p_api_version   => 1.0,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_group         => l_group,
       x_group         => l_descendant_group,
       p_level         => 0);


   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   IF (l_descendant_group.COUNT > 0) THEN
      FOR eachgroup IN l_descendant_group.first .. l_descendant_group.last LOOP
         FOR eachsrp IN members_csr(l_descendant_group(eachgroup).group_id) LOOP
	    IF (eachsrp.start_date <= p_srp.effective_date AND
              (eachsrp.end_date IS NULL
              OR eachsrp.end_date >= p_srp.effective_date)) THEN

             l_counter := l_counter + 1;

	     x_srp(l_counter).srp_role_id := eachsrp.srp_role_id       ;
	     x_srp(l_counter).srp_id  := eachsrp.srp_id           ;
	     x_srp(l_counter).overlay_flag := eachsrp.overlay_flag      ;
	     x_srp(l_counter).non_std_flag := eachsrp.non_std_flag      ;
	     x_srp(l_counter).role_id := eachsrp.role_id           ;
	     x_srp(l_counter).role_name := eachsrp.role_name         ;
	     x_srp(l_counter).job_title_id := eachsrp.job_title_id      ;
	     x_srp(l_counter).job_discretion := eachsrp.job_discretion    ;
	     x_srp(l_counter).status := eachsrp.status            ;
	     x_srp(l_counter).plan_activate_status := eachsrp.plan_activate_status;
	     x_srp(l_counter).club_eligible_flag := eachsrp.club_eligible_flag;
	     x_srp(l_counter).org_code := eachsrp.org_code          ;
	     x_srp(l_counter).start_date := eachsrp.start_date        ;
	     x_srp(l_counter).end_date := eachsrp.end_date          ;
	     x_srp(l_counter).group_id := eachsrp.group_id          ;

            END IF; -- end of check date_range_overlap
	 END LOOP; -- end of eachsrp
      END LOOP; -- end of eachgroup
   END IF;

   END IF;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_desc_role_info;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_desc_role_info;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO get_desc_role_info;
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
	p_data                  =>      x_msg_data               );

END Get_Desc_role_info;


-- ***********************************
-- TBD : MO
-- ***********************************
PROCEDURE Get_MO_desc_role_info
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  p_return_current         IN  varchar2 := 'Y',
  p_is_multiorg            IN  VARCHAR2 := 'N',
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_info_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'Get_MO_desc_role_info';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_counter        NUMBER(15) := 0;
   l_group          input_group_type;
   l_descendant_group group_tbl_type;
   l_mgr_flag       VARCHAR2(1) := 'N';
   l_srp_tbl        srp_role_group_tbl_type;
   l_returned_rows  number;


   CURSOR members_csr(p_group_id NUMBER) IS
     SELECT srd.srp_role_id, srd.srp_id, job_title_id, overlay_flag, non_std_flag, srd.role_id role_id,
       g.role_name role_name, job_discretion, status, plan_activate_status, club_eligible_flag,
       org_code, trunc(start_date) start_date, trunc(end_date) end_date, g.comp_group_id group_id
       FROM cn_qm_mgr_srp_groups g,
            cn_srp_role_dtls_v srd
       WHERE g.comp_group_id = p_group_id
        AND g.srp_role_id = srd.srp_role_id
        AND (trunc(srd.start_date) <= p_srp.effective_date)
        AND (srd.end_date IS NULL OR trunc(srd.end_date) >= p_srp.effective_date)
        AND (trunc(g.start_date_active) <= p_srp.effective_date)
        AND (g.end_date_active IS NULL OR trunc(g.end_date_active) >= p_srp.effective_date)
        AND srd.job_title_id <> -99
       ORDER BY g.manager_flag DESC;

   CURSOR mgr_check IS
      SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);

     -- COLLAPSED cn_qm_mgr_srp_groups
     CURSOR mo_members_csr(p_group_id NUMBER) IS
     SELECT srdd.srp_role_id, srdd.srp_id, srdd.job_title_id, srdd.overlay_flag, srdd.non_std_flag,
            srdd.role_id role_id,srdd.job_discretion, srdd.status, srdd.plan_activate_status, srdd.club_eligible_flag,
            srdd.org_code,trunc(srdd.start_date) start_date, trunc(srdd.end_date) end_date,
            jgm.role_name role_name,jgm.group_id group_id
       FROM
            jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
            jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u ,
            cn_srp_role_dtls_v srdd
       WHERE
          jg.group_id = jgm.group_id
          and (jgm.manager_flag = 'Y' or jgm.member_flag = 'Y')
          and jrs.resource_id = jgm.resource_id
          and u.group_id = jgm.group_id
          and u.usage = 'SF_PLANNING'
          and jrr.role_resource_type = 'RS_INDIVIDUAL'
          and jrr.role_resource_id = jrs.resource_id
          and jrr.role_id = jgm.role_id
          and jrr.role_id = jr.role_id
          and jr.role_type_code = 'SALES_COMP'
          and jrr.delete_flag <> 'Y'
          and jrr.start_date_active <= jgm.start_date_active
          and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
          AND jrs.SALESREP_ID > 0
          AND srdd.srp_role_id = jrr.role_relate_id
          AND jgm.group_id = p_group_id -- Added before this.
          AND jrr.role_relate_id = srdd.srp_role_id
          AND (trunc(srdd.start_date) <= p_srp.effective_date)
          AND (srdd.end_date IS NULL OR trunc(srdd.end_date) >= p_srp.effective_date)
          AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
          AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date)
          AND srdd.job_title_id <> -99
       ORDER BY jgm.manager_flag DESC;

     -- COLLAPSED cn_qm_mgr_srp_groups
     CURSOR mo_mgr_check IS
      SELECT jgm.manager_flag manager_flag
        FROM
         jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
         jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u,
         cn_srp_role_dtls srd
        WHERE
          jg.group_id = jgm.group_id
          and jgm.manager_flag = 'Y'
          and jrs.resource_id = jgm.resource_id
          and u.group_id = jgm.group_id
          and u.usage = 'SF_PLANNING'
          and jrr.role_resource_type = 'RS_INDIVIDUAL'
          and jrr.role_resource_id = jrs.resource_id
          and jrr.role_id = jgm.role_id
          and jrr.role_id = jr.role_id
          and jr.role_type_code = 'SALES_COMP'
          and jrr.delete_flag <> 'Y'
          and jrr.start_date_active <= jgm.start_date_active
          and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
          AND jrs.SALESREP_ID > 0
          AND srd.srp_role_id = jrr.role_relate_id
          AND jgm.group_id = p_srp.group_id
          AND jrs.salesrep_id = p_srp.salesrep_id
          AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
          AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date);

     TYPE   RC_TYPE IS REF CURSOR;
     TYPE   RET_RC_TYPE IS REF CURSOR RETURN members_csr%ROWTYPE;
     member_csr_rec members_csr%ROWTYPE;
     eachmem members_csr%ROWTYPE;
     eachsrp members_csr%ROWTYPE;

     mgr_check_rc RC_TYPE;
     members_csr_rc RET_RC_TYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_MO_desc_role_info;

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

   -- if p_srp.salesrep_id is a manager, get the other members of his own group
   /*
   OPEN mgr_check;
   FETCH mgr_check INTO l_mgr_flag;
   CLOSE mgr_check;
   */

   IF p_is_multiorg = 'Y' THEN
       OPEN mgr_check_rc FOR
        SELECT jgm.manager_flag manager_flag
        FROM
         jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
         jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u,
         cn_srp_role_dtls srd
        WHERE
          jg.group_id = jgm.group_id
          and jgm.manager_flag = 'Y'
          and jrs.resource_id = jgm.resource_id
          and u.group_id = jgm.group_id
          and u.usage = 'SF_PLANNING'
          and jrr.role_resource_type = 'RS_INDIVIDUAL'
          and jrr.role_resource_id = jrs.resource_id
          and jrr.role_id = jgm.role_id
          and jrr.role_id = jr.role_id
          and jr.role_type_code = 'SALES_COMP'
          and jrr.delete_flag <> 'Y'
          and jrr.start_date_active <= jgm.start_date_active
          and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
          AND jrs.SALESREP_ID > 0
          AND srd.srp_role_id = jrr.role_relate_id
          AND jgm.group_id = p_srp.group_id
          AND jrs.salesrep_id = p_srp.salesrep_id
          AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
          AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date);
    ELSE
          OPEN mgr_check_rc FOR       SELECT manager_flag
        FROM cn_qm_mgr_groups
        WHERE comp_group_id = p_srp.group_id
        AND manager_srp_id = p_srp.salesrep_id
        AND (trunc(start_date_active) <= p_srp.effective_date)
        AND (end_date_active IS NULL OR trunc(end_date_active) >= p_srp.effective_date);
    END IF;

    -- Cursor mgr_check_rc already opened above
    LOOP
          FETCH mgr_check_rc INTO l_mgr_flag;
          EXIT WHEN mgr_check_rc%NOTFOUND;
    END LOOP;
    CLOSE mgr_check_rc;


   IF l_mgr_flag = 'Y' THEN

       IF p_is_multiorg = 'Y' THEN
           OPEN members_csr_rc FOR SELECT srdd.srp_role_id, srdd.srp_id, srdd.job_title_id, srdd.overlay_flag, srdd.non_std_flag,
                srdd.role_id role_id,jgm.role_name role_name,srdd.job_discretion, srdd.status, srdd.plan_activate_status, srdd.club_eligible_flag,
                srdd.org_code,trunc(srdd.start_date) start_date, trunc(srdd.end_date) end_date,
                jgm.group_id group_id
           FROM
            jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
            jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u ,
            cn_srp_role_dtls_v srdd
           WHERE
              jg.group_id = jgm.group_id
              and (jgm.manager_flag = 'Y' or jgm.member_flag = 'Y')
              and jrs.resource_id = jgm.resource_id
              and u.group_id = jgm.group_id
              and u.usage = 'SF_PLANNING'
              and jrr.role_resource_type = 'RS_INDIVIDUAL'
              and jrr.role_resource_id = jrs.resource_id
              and jrr.role_id = jgm.role_id
              and jrr.role_id = jr.role_id
              and jr.role_type_code = 'SALES_COMP'
              and jrr.delete_flag <> 'Y'
              and jrr.start_date_active <= jgm.start_date_active
              and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
              AND jrs.SALESREP_ID > 0
              AND srdd.srp_role_id = jrr.role_relate_id
              AND jgm.group_id = p_srp.group_id -- Added before this.
              AND jrr.role_relate_id = srdd.srp_role_id
              AND (trunc(srdd.start_date) <= p_srp.effective_date)
              AND (srdd.end_date IS NULL OR trunc(srdd.end_date) >= p_srp.effective_date)
              AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
              AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date)
              AND srdd.job_title_id <> -99
              ORDER BY jgm.manager_flag DESC;
       ELSE
           OPEN members_csr_rc FOR SELECT srd.srp_role_id, srd.srp_id, job_title_id, overlay_flag, non_std_flag, srd.role_id role_id,
               g.role_name role_name, job_discretion, status, plan_activate_status, club_eligible_flag,
               org_code, trunc(start_date) start_date, trunc(end_date) end_date, g.comp_group_id group_id
           FROM cn_qm_mgr_srp_groups g,
                cn_srp_role_dtls_v srd
           WHERE g.comp_group_id = p_srp.group_id
                AND g.srp_role_id = srd.srp_role_id
                AND (trunc(srd.start_date) <= p_srp.effective_date)
                AND (srd.end_date IS NULL OR trunc(srd.end_date) >= p_srp.effective_date)
                AND (trunc(g.start_date_active) <= p_srp.effective_date)
                AND (g.end_date_active IS NULL OR trunc(g.end_date_active) >= p_srp.effective_date)
                AND srd.job_title_id <> -99
               ORDER BY g.manager_flag DESC;
       END IF;

      l_counter := 0;
      LOOP
          FETCH members_csr_rc INTO eachmem;
          EXIT WHEN members_csr_rc%NOTFOUND;

          IF (eachmem.start_date <= p_srp.effective_date AND
              (eachmem.end_date IS NULL
              OR eachmem.end_date >= p_srp.effective_date))
           AND
            (
             (p_return_current = 'N' AND eachmem.srp_id <> p_srp.salesrep_id )
               OR (p_return_current = 'Y')
            )
          THEN


            l_counter := l_counter + 1;


	     x_srp(l_counter).srp_role_id := eachmem.srp_role_id   ;
	     x_srp(l_counter).srp_id  := eachmem.srp_id           ;
	     x_srp(l_counter).overlay_flag := eachmem.overlay_flag      ;
	     x_srp(l_counter).non_std_flag := eachmem.non_std_flag      ;
	     x_srp(l_counter).role_id := eachmem.role_id           ;
	     x_srp(l_counter).role_name := eachmem.role_name         ;
	     x_srp(l_counter).job_title_id := eachmem.job_title_id      ;
	     x_srp(l_counter).job_discretion := eachmem.job_discretion    ;
	     x_srp(l_counter).status := eachmem.status            ;
	     x_srp(l_counter).plan_activate_status := eachmem.plan_activate_status;
	     x_srp(l_counter).club_eligible_flag := eachmem.club_eligible_flag;
	     x_srp(l_counter).org_code := eachmem.org_code          ;
	     x_srp(l_counter).start_date := eachmem.start_date        ;
	     x_srp(l_counter).end_date := eachmem.end_date          ;
	     x_srp(l_counter).group_id := eachmem.group_id          ;


   	  END IF;
      END LOOP;
      CLOSE members_csr_rc;


   -- initialize l_group
   l_group.group_id := p_srp.group_id;
   l_group.effective_date := p_srp.effective_date;

   get_descendant_group
     ( p_api_version   => 1.0,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_group         => l_group,
       x_group         => l_descendant_group,
       p_level         => 0);


   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   IF (l_descendant_group.COUNT > 0) THEN
      FOR eachgroup IN l_descendant_group.first .. l_descendant_group.last LOOP
           IF p_is_multiorg = 'Y' THEN
               OPEN members_csr_rc FOR SELECT srdd.srp_role_id, srdd.srp_id, srdd.job_title_id, srdd.overlay_flag, srdd.non_std_flag,
                srdd.role_id role_id,jgm.role_name role_name,srdd.job_discretion, srdd.status, srdd.plan_activate_status, srdd.club_eligible_flag,
                srdd.org_code,trunc(srdd.start_date) start_date, trunc(srdd.end_date) end_date,
                jgm.group_id group_id
               FROM
                jtf_rs_groups_vl jg, jtf_rs_role_relations  jrr, jtf_rs_salesreps jrs,
                jtf_rs_roles_b jr,jtf_rs_group_mbr_role_vl jgm, jtf_rs_group_usages u ,
                cn_srp_role_dtls_v srdd
               WHERE
                  jg.group_id = jgm.group_id
                  and (jgm.manager_flag = 'Y' or jgm.member_flag = 'Y')
                  and jrs.resource_id = jgm.resource_id
                  and u.group_id = jgm.group_id
                  and u.usage = 'SF_PLANNING'
                  and jrr.role_resource_type = 'RS_INDIVIDUAL'
                  and jrr.role_resource_id = jrs.resource_id
                  and jrr.role_id = jgm.role_id
                  and jrr.role_id = jr.role_id
                  and jr.role_type_code = 'SALES_COMP'
                  and jrr.delete_flag <> 'Y'
                  and jrr.start_date_active <= jgm.start_date_active
                  and (jrr.end_date_active is null or jrr.end_date_active >= jgm.end_date_active)
                  AND jrs.SALESREP_ID > 0
                  AND srdd.srp_role_id = jrr.role_relate_id
                  AND jgm.group_id = l_descendant_group(eachgroup).group_id -- Added before this.
                  AND jrr.role_relate_id = srdd.srp_role_id
                  AND (trunc(srdd.start_date) <= p_srp.effective_date)
                  AND (srdd.end_date IS NULL OR trunc(srdd.end_date) >= p_srp.effective_date)
                  AND (trunc(jgm.start_date_active) <= p_srp.effective_date)
                  AND (jgm.end_date_active IS NULL OR trunc(jgm.end_date_active) >= p_srp.effective_date)
                  AND srdd.job_title_id <> -99
                  ORDER BY jgm.manager_flag DESC;
               ELSE
                   OPEN members_csr_rc FOR SELECT srd.srp_role_id, srd.srp_id, job_title_id, overlay_flag, non_std_flag, srd.role_id role_id,
                   g.role_name role_name, job_discretion, status, plan_activate_status, club_eligible_flag,
                   org_code, trunc(start_date) start_date, trunc(end_date) end_date, g.comp_group_id group_id
                   FROM cn_qm_mgr_srp_groups g,
                    cn_srp_role_dtls_v srd
                   WHERE g.comp_group_id = l_descendant_group(eachgroup).group_id
                    AND g.srp_role_id = srd.srp_role_id
                    AND (trunc(srd.start_date) <= p_srp.effective_date)
                    AND (srd.end_date IS NULL OR trunc(srd.end_date) >= p_srp.effective_date)
                    AND (trunc(g.start_date_active) <= p_srp.effective_date)
                    AND (g.end_date_active IS NULL OR trunc(g.end_date_active) >= p_srp.effective_date)
                    AND srd.job_title_id <> -99
                   ORDER BY g.manager_flag DESC;
             END IF;

             LOOP
                FETCH members_csr_rc INTO eachsrp;
                EXIT WHEN members_csr_rc%NOTFOUND;
        	    IF (eachsrp.start_date <= p_srp.effective_date AND
                   (eachsrp.end_date IS NULL
                    OR eachsrp.end_date >= p_srp.effective_date)) THEN

                     l_counter := l_counter + 1;
            	     x_srp(l_counter).srp_role_id := eachsrp.srp_role_id       ;
            	     x_srp(l_counter).srp_id  := eachsrp.srp_id           ;
            	     x_srp(l_counter).overlay_flag := eachsrp.overlay_flag      ;
            	     x_srp(l_counter).non_std_flag := eachsrp.non_std_flag      ;
            	     x_srp(l_counter).role_id := eachsrp.role_id           ;
                     x_srp(l_counter).role_name := eachsrp.role_name         ;
            	     x_srp(l_counter).job_title_id := eachsrp.job_title_id      ;
            	     x_srp(l_counter).job_discretion := eachsrp.job_discretion    ;
                     x_srp(l_counter).status := eachsrp.status            ;
            	     x_srp(l_counter).plan_activate_status := eachsrp.plan_activate_status;
            	     x_srp(l_counter).club_eligible_flag := eachsrp.club_eligible_flag;
            	     x_srp(l_counter).org_code := eachsrp.org_code          ;
            	     x_srp(l_counter).start_date := eachsrp.start_date        ;
            	     x_srp(l_counter).end_date := eachsrp.end_date          ;
            	     x_srp(l_counter).group_id := eachsrp.group_id          ;
                END IF; -- end of check date_range_overlap
	  END LOOP; -- end of eachsrp
      CLOSE members_csr_rc;
      END LOOP; -- end of eachgroup
   END IF;

   END IF;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_MO_desc_role_info;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_MO_desc_role_info;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO Get_MO_desc_role_info;
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
	p_data                  =>      x_msg_data               );

END Get_MO_desc_role_info;

--}}}



--{{{ get_all_managers
-- Start of comments
--    API name        : Get_All_Managers
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
--                      p_srp                 IN srp_group_rec_type Required
--                      p_effective_date      IN DATE         Required
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_srp                 OUT srp_role_group_tbl_type
--                      x_returned_rows       OUT INTEGER
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Get_All_Managers
  (p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  number := FND_API.G_VALID_LEVEL_FULL,
  p_srp                    IN  srp_group_rec_type,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_srp                    OUT NOCOPY srp_role_group_tbl_type,
  x_returned_rows          OUT NOCOPY number) IS

   l_api_name       CONSTANT VARCHAR2(30) := 'get_all_managers';
   l_api_version    CONSTANT NUMBER       := 1.0;

   l_comp_group_id  number := 0;
   l_counter        NUMBER(15);
   l_group          input_group_type;
   l_ancestor_group group_tbl_type;
   l_srp_tbl        srp_role_group_tbl_type;
   l_returned_rows  number;

   CURSOR l_mgr_group_csr is
     SELECT 1
       FROM cn_qm_mgr_groups
       WHERE manager_srp_id = p_srp.salesrep_id;

   CURSOR l_parent_group_csr(p_group_id NUMBER) is
     SELECT parent_comp_group_id
       FROM cn_qm_group_hier
       WHERE comp_group_id = p_group_id
       AND trunc(start_date_active) <= p_srp.effective_date
       AND (trunc(end_date_active) >= p_srp.effective_date
       OR end_date_active IS NULL);

   CURSOR managers_csr(p_group_id NUMBER) IS
     SELECT manager_srp_id salesrep_id, role_id ,comp_group_id,
       trunc(start_date_active) start_date_active,
       trunc(end_date_active) end_date_active
       FROM cn_qm_mgr_groups
       WHERE comp_group_id = p_group_id
       AND manager_srp_id <> p_srp.salesrep_id
       AND manager_flag = 'Y';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   get_all_managers;

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

   l_counter := 0;

   -- find IF this salesrep is a manager
   OPEN l_mgr_group_csr;
   FETCH l_mgr_group_csr INTO l_counter;
   CLOSE l_mgr_group_csr;

   IF (l_counter <> 0) THEN
      OPEN l_parent_group_csr(p_srp.group_id);
      FETCH l_parent_group_csr INTO l_comp_group_id;
      CLOSE l_parent_group_csr;
   ELSE
        l_comp_group_id := p_srp.group_id;
   END IF;

   l_counter := 0;
   -- find all managers in this group

   FOR eachmgr IN managers_csr(l_comp_group_id) LOOP

      IF (eachmgr.start_date_active <= p_srp.effective_date AND
              (eachmgr.end_date_active IS NULL
              OR eachmgr.end_date_active >= p_srp.effective_date)) THEN

         l_counter := l_counter + 1;
         x_srp(l_counter).salesrep_id := eachmgr.salesrep_id;
         x_srp(l_counter).group_id    := l_comp_group_id;
         x_srp(l_counter).role_id     := eachmgr.role_id;
         x_srp(l_counter).start_date  := eachmgr.start_date_active;
         x_srp(l_counter).end_date    := eachmgr.end_date_active;
         x_srp(l_counter).mgr_srp_id := 0;
         x_srp(l_counter).hier_level := 0;
      END IF;

   END LOOP;

   -- loop through reach ancestor group.
   l_group.group_id := l_comp_group_id;
   l_group.effective_date := p_srp.effective_date;

   get_ancestor_group
     ( p_api_version   => 1.0,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_group         => l_group,
       x_group         => l_ancestor_group,
       p_level         => 0);

   IF x_return_status = FND_API.g_ret_sts_error THEN

      RAISE FND_API.g_exc_error;

   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN

      RAISE FND_API.g_exc_unexpected_error;

   END IF;

   IF( l_ancestor_group.COUNT > 0) THEN
      FOR eachgroup IN l_ancestor_group.first .. l_ancestor_group.last LOOP

         FOR eachsrp IN managers_csr(l_ancestor_group(eachgroup).group_id) LOOP

	    IF (eachsrp.start_date_active <= p_srp.effective_date AND
              (eachsrp.end_date_active IS NULL
              OR eachsrp.end_date_active >= p_srp.effective_date)) THEN

               l_counter := l_counter + 1;
               x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;
               x_srp(l_counter).group_id    :=
                 l_ancestor_group(eachgroup).group_id;
               x_srp(l_counter).role_id := eachsrp.role_id;
               x_srp(l_counter).start_date  := eachsrp.start_date_active;
               x_srp(l_counter).end_date    := eachsrp.end_date_active;
               x_srp(l_counter).mgr_srp_id := 0;
               x_srp(l_counter).hier_level :=
                 l_ancestor_group(eachgroup).hier_level;
            END IF; -- end of check date_range_overlap
         END LOOP; -- end of eachsrp
      END LOOP; -- end of eachgroup
   END IF;


   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_all_managers;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_all_managers;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );

   WHEN OTHERS THEN
     ROLLBACK TO get_all_managers;
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
	p_data                  =>      x_msg_data               );

END Get_All_Managers;
--}}}

END cn_srp_hier_proc_pvt;

/
