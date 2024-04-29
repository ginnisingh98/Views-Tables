--------------------------------------------------------
--  DDL for Package Body CN_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLLUP_PVT" AS
--$Header: cnvrollb.pls 120.3 2005/09/12 10:58:57 ymao ship $

G_PKG_NAME         CONSTANT VARCHAR2(30):='cn_rollup_pvt';

-- API name 	: get_active_role
-- Type	        : Private.
-- Pre-reqs	: None
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_active_role
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_srp                   IN  srp_group_rec_type,
    x_role                  OUT NOCOPY role_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_active_role';
     l_api_version  CONSTANT NUMBER       := 1.0;

     l_counter     NUMBER(15);

     CURSOR roles_csr IS
	SELECT
	  role_id,
	  greatest(start_date_active, p_srp.start_date) start_date,
	  least(nvl(end_date_active, p_srp.end_date), nvl(p_srp.end_date, end_date_active)) end_date,
	  manager_flag
	  FROM cn_srp_comp_groups_v
	  WHERE comp_group_id = p_srp.group_id
	  AND salesrep_id = p_srp.salesrep_id
      AND org_id = p_org_id
	  AND (end_date_active IS NULL OR p_srp.start_date <= end_date_active)
	    AND (p_srp.end_date IS NULL OR p_srp.end_date >= start_date_active);
BEGIN
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
   FOR eachrole IN roles_csr LOOP
      x_role(l_counter).role_id      := eachrole.role_id;
      x_role(l_counter).manager_flag := eachrole.manager_flag;
      x_role(l_counter).start_date   := eachrole.start_date;
      x_role(l_counter).end_date     := eachrole.end_date;
      l_counter := l_counter + 1;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	    p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_active_role.exception',
		       		     sqlerrm);
    end if;

END get_active_role;

-- API name 	: get_active_group_member
-- Type	        : Private.
-- Pre-reqs	: None
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_active_group_member
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_group                 IN  group_rec_type,
    x_group_mem             OUT NOCOPY group_mem_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_active_group_member';
     l_api_version  CONSTANT NUMBER       := 1.0;

     CURSOR group_members_csr IS
	SELECT
	  salesrep_id,
	  role_id,
	  manager_flag,
	  greatest(start_date_active, p_group.start_date) start_date,
	  least(nvl(end_date_active, p_group.end_date), nvl(p_group.end_date, end_date_active)) end_date
	  FROM cn_srp_comp_groups_v
	  WHERE comp_group_id = p_group.group_id
      AND org_id = p_org_id
	  AND (end_date_active IS NULL OR p_group.start_date <= end_date_active)
	    AND (p_group.end_date IS NULL OR p_group.end_date >= start_date_active);

     l_counter     NUMBER(15);
BEGIN
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
   FOR eachmem IN group_members_csr LOOP
      x_group_mem(l_counter).salesrep_id  := eachmem.salesrep_id;
      x_group_mem(l_counter).role_id      := eachmem.role_id;
      x_group_mem(l_counter).manager_flag := eachmem.manager_flag;
      x_group_mem(l_counter).start_date   := eachmem.start_date;
      x_group_mem(l_counter).end_date     := eachmem.end_date;

      l_counter := l_counter + 1;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_active_group_member.exception',
		       		     sqlerrm);
    end if;
END get_active_group_member;

-- API name 	: get_active_group_member
-- Type	        : Private.
-- Pre-reqs	: None
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_active_group_member
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_group                 IN  group_tbl_type,
    x_group_mem             OUT NOCOPY srp_group_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_active_group_member';
     l_api_version  CONSTANT NUMBER       := 1.0;

     l_counter     NUMBER(15);

     l_group_member cn_rollup_pvt.group_mem_tbl_type;
BEGIN
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
   FOR eachgrp IN p_group.first .. p_group.last LOOP
      get_active_group_member
	(p_api_version       => 1.0,
	 x_return_status     => x_return_status,
	 x_msg_count         => x_msg_count,
	 x_msg_data          => x_msg_data,
     p_org_id            => p_org_id,
	 p_group             => p_group(eachgrp),
	 x_group_mem         => l_group_member);

      IF l_group_member.COUNT >0 THEN
	 FOR  i IN l_group_member.first .. l_group_member.last LOOP
	    x_group_mem(l_counter).salesrep_id  := l_group_member(i).salesrep_id;
	    x_group_mem(l_counter).group_id     := p_group(eachgrp).group_id;
	    x_group_mem(l_counter).start_date   := l_group_member(i).start_date;
	    x_group_mem(l_counter).end_date     := l_group_member(i).end_date;
	    x_group_mem(l_counter).level        := p_group(eachgrp).level;

	    l_counter := l_counter + 1;
	 END LOOP;
      END IF;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_active_group_member.exception',
		       		     sqlerrm);
    end if;
END get_active_group_member;

-- API name 	: get_active_group
-- Type	        : Private.
-- Pre-reqs	: None
-- Usage	:
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_active_group
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_srp                   IN  srp_rec_type,
    x_active_group          OUT NOCOPY active_group_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_active_group';
     l_api_version  CONSTANT NUMBER       := 1.0;

     CURSOR groups_csr IS
	SELECT
	  comp_group_id,
	  role_id,
	  manager_flag,
	  greatest(start_date_active, p_srp.start_date) start_date,
	  least(nvl(end_date_active, p_srp.end_date), nvl(p_srp.end_date, end_date_active)) end_date
	FROM cn_srp_comp_groups_v
	WHERE salesrep_id = p_srp.salesrep_id
      AND org_id = p_org_id
	  AND (end_date_active IS NULL OR p_srp.start_date <= end_date_active)
	  AND (p_srp.end_date IS NULL OR p_srp.end_date >= start_date_active);

     l_counter      NUMBER(15) := 0;
BEGIN
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

   FOR eachgroup IN groups_csr LOOP
      x_active_group(l_counter).group_id     := eachgroup.comp_group_id;
      x_active_group(l_counter).role_id      := eachgroup.role_id;
      x_active_group(l_counter).manager_flag := eachgroup.manager_flag;
      x_active_group(l_counter).start_date   := eachgroup.start_date;
      x_active_group(l_counter).end_date     := eachgroup.end_date;

      l_counter := l_counter + 1;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_active_group.exception',
		       		     sqlerrm);
    end if;

END get_active_group;

-- API name 	: get_ancestor_group
-- Type	        : Private.
-- Pre-reqs	: None
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
--
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
    p_group                 IN  group_rec_type,
    x_group                 OUT NOCOPY group_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_ancestor_group';
     l_api_version  CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER(15) := 0;

     CURSOR groups_csr IS
	SELECT
	  parent_group_id,
	  denorm_level,
	  greatest(start_date_active, p_group.start_date) start_date,
	  least(nvl(end_date_active, p_group.end_date), nvl(p_group.end_date, end_date_active)) end_date
	FROM cn_groups_denorm_v
	WHERE group_id = p_group.group_id
	  AND (end_date_active IS NULL OR p_group.start_date <= end_date_active)
	  AND (p_group.end_date IS NULL OR p_group.end_date >= start_date_active);
BEGIN
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

   FOR eachgroup IN groups_csr LOOP
      x_group(l_counter).group_id   := eachgroup.parent_group_id;
      x_group(l_counter).start_date := eachgroup.start_date;
      x_group(l_counter).end_date   := eachgroup.end_date;
      x_group(l_counter).level      := eachgroup.denorm_level;

      l_counter := l_counter + 1;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_ancestor_group.exception',
		       		     sqlerrm);
    end if;

END get_ancestor_group;

-- API name 	: get_descendant_group
-- Type	        : Private.
-- Pre-reqs	: None
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
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
    p_group                 IN  group_rec_type,
    x_group                 OUT NOCOPY group_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_descendant_group';
     l_api_version  CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER(15) := 0;

     CURSOR groups_csr IS
	SELECT
	  group_id,
	  denorm_level,
	  greatest(start_date_active, p_group.start_date) start_date,
	  least(nvl(end_date_active, p_group.end_date), nvl(p_group.end_date, end_date_active)) end_date
	FROM cn_groups_denorm_v
	WHERE parent_group_id = p_group.group_id
	  AND (end_date_active IS NULL OR p_group.start_date <= end_date_active)
	  AND (p_group.end_date IS NULL OR p_group.end_date >= start_date_active);
BEGIN
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

   FOR eachgroup IN groups_csr LOOP
      x_group(l_counter).group_id   := eachgroup.group_id;
      x_group(l_counter).start_date := eachgroup.start_date;
      x_group(l_counter).end_date   := eachgroup.end_date;
      x_group(l_counter).level      := eachgroup.denorm_level;

      l_counter := l_counter + 1;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_descendant_group.exception',
		       		     sqlerrm);
    end if;

END get_descendant_group;

-- API name 	: get_ancestor_salesrep
-- Type	        : Private.
-- Pre-reqs	: None
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_ancestor_salesrep
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_srp                   IN  srp_group_rec_type,
    x_srp                   OUT NOCOPY srp_group_tbl_type)
  IS
     l_api_name       CONSTANT VARCHAR2(30) := 'get_ancestor_salesrep';
     l_api_version    CONSTANT NUMBER       := 1.0;

     l_counter        NUMBER(15);
     l_group          group_rec_type;
     l_ancestor_group group_tbl_type;

     CURSOR managers_csr IS
	SELECT
	  salesrep_id,
	  greatest(start_date_active, p_srp.start_date) start_date,
	  least(nvl(end_date_active, p_srp.end_date), nvl(p_srp.end_date, end_date_active)) end_date
	FROM cn_srp_comp_groups_v
	WHERE comp_group_id = p_srp.group_id
	AND salesrep_id <> p_srp.salesrep_id
	AND manager_flag = 'Y'
    AND org_id = p_org_id
	AND (end_date_active IS NULL OR p_srp.start_date <= end_date_active)
	AND (p_srp.end_date IS NULL OR p_srp.end_date >= start_date_active);

     CURSOR members_csr(p_group_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	SELECT
	  salesrep_id,
	  greatest(start_date_active, p_start_date) start_date,
	  least(nvl(end_date_active, p_end_date), nvl(p_end_date, end_date_active)) end_date
	FROM cn_srp_comp_groups_v
       WHERE comp_group_id = p_group_id
         AND org_id = p_org_id
         AND (end_date_active IS NULL OR p_start_date <= end_date_active)
         AND (p_end_date IS NULL OR p_end_date >= start_date_active);
BEGIN
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
   FOR eachmgr IN managers_csr LOOP
      x_srp(l_counter).salesrep_id := eachmgr.salesrep_id;
      x_srp(l_counter).group_id    := p_srp.group_id;
      x_srp(l_counter).start_date  := eachmgr.start_date;
      x_srp(l_counter).end_date    := eachmgr.end_date;
      x_srp(l_counter).level       := 0;

      l_counter := l_counter + 1;
   END LOOP;

   -- loop through each ancestor group.
   l_group.group_id := p_srp.group_id;
   l_group.start_date := p_srp.start_date;
   l_group.end_date := p_srp.end_date;

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
	 FOR eachsrp IN members_csr(l_ancestor_group(eachgroup).group_id, l_ancestor_group(eachgroup).start_date, l_ancestor_group(eachgroup).end_date) LOOP
	    x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;
	    x_srp(l_counter).group_id    := l_ancestor_group(eachgroup).group_id;
	    x_srp(l_counter).start_date  := eachsrp.start_date;
	    x_srp(l_counter).end_date    := eachsrp.end_date;
	    x_srp(l_counter).level       := l_ancestor_group(eachgroup).level;

	    l_counter := l_counter + 1;
	 END LOOP; -- end of eachsrp
      END LOOP; -- end of eachgroup
   END IF;


   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_ancestor_salesrep.exception',
		       		     sqlerrm);
    end if;

END get_ancestor_salesrep;

-- API name 	: get_descendant_salesrep
-- Type	        : Private.
-- Pre-reqs	: None
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_descendant_salesrep
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_srp                   IN  srp_group_rec_type,
    x_srp                   OUT NOCOPY srp_group_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_descendant_salesrep';
     l_api_version  CONSTANT NUMBER       := 1.0;

     l_counter        NUMBER(15) := 0;
     l_group          group_rec_type;
     l_descendant_group group_tbl_type;
     l_mgr_flag       VARCHAR2(1);

     CURSOR members_csr(p_group_id NUMBER, p_start_date DATE, p_end_date DATE) IS
	SELECT
	  salesrep_id,
	  greatest(start_date_active, p_start_date) start_date,
	  least(nvl(end_date_active, p_end_date), nvl(p_end_date, end_date_active)) end_date
	FROM cn_srp_comp_groups_v
	WHERE comp_group_id = p_group_id
      AND org_id = p_org_id
	  AND (end_date_active IS NULL OR p_start_date <= end_date_active)
	  AND (p_end_date IS NULL OR p_end_date >= start_date_active);

     CURSOR mgr_check IS
	SELECT manager_flag
	  FROM cn_srp_comp_groups_v
	  WHERE comp_group_id = p_srp.group_id
      AND org_id = p_org_id
	  AND salesrep_id = p_srp.salesrep_id
	  AND (p_srp.end_date IS NULL OR start_date_active <= p_srp.end_date)
	  AND (end_date_active IS NULL OR end_date_active >= p_srp.start_date);
BEGIN
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

   IF (l_mgr_flag = 'Y') THEN
      FOR eachmem IN members_csr(p_srp.group_id, p_srp.start_date, p_srp.end_date) LOOP
	 IF eachmem.salesrep_id <> p_srp.salesrep_id THEN
	    x_srp(l_counter).salesrep_id := eachmem.salesrep_id;
	    x_srp(l_counter).group_id    := p_srp.group_id;
	    x_srp(l_counter).start_date  := eachmem.start_date;
	    x_srp(l_counter).end_date    := eachmem.end_date;
	    x_srp(l_counter).level       := 0;

	    l_counter := l_counter + 1;
	 END IF;
      END LOOP;
   END IF;

   -- initialize l_group
   l_group.group_id := p_srp.group_id;
   l_group.start_date := p_srp.start_date;
   l_group.end_date := p_srp.end_date;

   get_descendant_group
     ( p_api_version   => 1.0,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data,
       p_group         => l_group,
       x_group         => l_descendant_group);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (l_descendant_group.COUNT > 0) THEN
      FOR eachgroup IN l_descendant_group.first .. l_descendant_group.last LOOP
	 FOR eachsrp IN members_csr(l_descendant_group(eachgroup).group_id, l_descendant_group(eachgroup).start_date,l_descendant_group(eachgroup).end_date) LOOP
	    x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;
	    x_srp(l_counter).group_id    := l_descendant_group(eachgroup).group_id;
	    x_srp(l_counter).start_date  := eachsrp.start_date;
	    x_srp(l_counter).end_date    := eachsrp.end_date;
	    x_srp(l_counter).level       := l_descendant_group(eachgroup).level;

	    l_counter := l_counter + 1;
	 END LOOP; -- end of eachsrp
      END LOOP; -- end of eachgroup
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_descendant_salesrep.exception',
		       		     sqlerrm);
    end if;

END get_descendant_salesrep;

-- API name 	: get_descendant_salesrep
-- Type	        : Private.
-- Pre-reqs	: None
--
-- Parameters	:
--  IN	        : p_api_version       NUMBER      Require
-- 		  p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		  p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
--  OUT	        : x_return_status     VARCHAR2(1)
-- 		  x_msg_count	       NUMBER
-- 		  x_msg_data	       VARCHAR2(2000)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_descendant_salesrep
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_org_id                IN  NUMBER,
    p_srp                   IN  srp_rec_type,
    x_srp                   OUT NOCOPY srp_tbl_type)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'get_descendant_salesrep';
     l_api_version  CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER(15);
     l_temp         NUMBER(15);

     CURSOR groups_csr IS
      SELECT DISTINCT comp_group_id
	FROM cn_srp_comp_groups_v
	WHERE salesrep_id = p_srp.salesrep_id
    AND org_id = p_org_id
	AND (p_srp.end_date IS NULL OR start_date_active <= p_srp.end_date)
	AND (end_date_active IS NULL OR end_date_active >= p_srp.start_date);

   CURSOR members_csr (p_group_id NUMBER) IS
      SELECT DISTINCT salesrep_id
	FROM cn_srp_comp_groups_v
	WHERE comp_group_id = p_group_id
	AND salesrep_id <> p_srp.salesrep_id
    AND org_id = p_org_id
	AND (p_srp.end_date IS NULL OR start_date_active <= p_srp.end_date)
	AND (end_date_active IS NULL OR end_date_active >= p_srp.start_date);

   CURSOR descendant_csr(p_group_id NUMBER) IS
      SELECT DISTINCT salesrep_id
	FROM cn_srp_comp_groups_v srp,
	cn_groups_denorm_v hier
	WHERE srp.comp_group_id = hier.group_id
    AND srp.org_id = p_org_id
	AND hier.parent_group_id = p_group_id
	AND (p_srp.end_date IS NULL OR hier.start_date_active <= p_srp.end_date)
	AND (hier.end_date_active IS NULL OR hier.end_date_active >= p_srp.start_date)
	AND (p_srp.end_date IS NULL OR srp.start_date_active <= p_srp.end_date)
	AND (srp.end_date_active IS NULL OR srp.end_date_active >= p_srp.start_date);
BEGIN
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

   FOR eachgroup IN groups_csr LOOP
      SELECT COUNT(*)
	INTO l_temp
	FROM cn_srp_comp_groups_v
	WHERE salesrep_id = p_srp.salesrep_id
    AND org_id = p_org_id
	AND comp_group_id = eachgroup.comp_group_id
	AND manager_flag = 'Y'
	AND (p_srp.end_date IS NULL OR start_date_active <= p_srp.end_date)
	AND (end_date_active IS NULL OR end_date_active >= p_srp.start_date);

      IF l_temp > 0 THEN
	 FOR eachsrp IN members_csr(eachgroup.comp_group_id) LOOP
	    x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;

	    l_counter := l_counter + 1;
	 END LOOP; -- end of eachsrp
      END IF; -- end of l_temp check

      FOR eachsrp IN descendant_csr(eachgroup.comp_group_id) LOOP
	 x_srp(l_counter).salesrep_id := eachsrp.salesrep_id;

	 l_counter := l_counter + 1;
      END LOOP; -- End of eachsrp
   END LOOP; -- End of eachgroup
   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
	p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
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

	if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_rollup_pvt.get_descendant_salesrep.exception',
		       		     sqlerrm);
    end if;

END get_descendant_salesrep;

END cn_rollup_pvt;

/
