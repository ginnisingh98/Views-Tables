--------------------------------------------------------
--  DDL for Package Body CN_ADD_TBH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ADD_TBH_PVT" AS
  /*$Header: cnvatbhb.pls 115.8 2003/05/02 18:48:56 fting ship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_ADD_TBH_PVT';

-- Start of comments
--    API name        : Create_TBH - Private.
--    Pre-reqs        : None.
--    IN              : standard params
--                      mgr_srp_id, emp_num, comp_group, job_title_id, role_id
--                      start+end date for srp, mgr assignment, job assignment
--    OUT             : standard params
--                      x_srp_id
--    Version         : 1.0
-- End of comments

PROCEDURE Create_TBH
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mgr_srp_id                 IN      NUMBER,
   p_name                       IN      VARCHAR2,
   p_emp_num                    IN      VARCHAR2,
   p_comp_group_id              IN      NUMBER,
   p_start_date_active          IN      DATE,
   p_end_date_active            IN      DATE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_srp_id                     OUT NOCOPY     NUMBER) IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_TBH';
   l_api_version               CONSTANT NUMBER       := 1.0;

   l_resource_id                        NUMBER;
   l_resource_number                    NUMBER;
   l_srp_id                             NUMBER;
   l_return_status                      VARCHAR2(1);
   l_msg_count                          NUMBER;
   l_msg_data                           VARCHAR2(2000);
   l_mgr_sct_id                         NUMBER;
   l_group_member_id                    NUMBER;

   cursor mgr_info is
   select s.sales_credit_type_id
     from cn_rs_salesreps s,
	  jtf_rs_resource_extns r
    where s.salesrep_id = p_mgr_srp_id
      and s.resource_id = r.resource_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_TBH;

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

   -- create the resource
   -- create the salesrep
   -- create the role, job_title, and comp group assignment
   -- create the manager assignment

   -- inherit properties from manager
   open  mgr_info;
   fetch mgr_info into l_mgr_sct_id;
   if mgr_info%notfound then
      close mgr_info;
      RAISE FND_API.G_EXC_ERROR;
   end if;
   close mgr_info;

   jtf_rs_resource_pub.create_resource
     (P_API_VERSION             => 1.0,
      P_CATEGORY                => 'TBH',
      P_START_DATE_ACTIVE       => p_start_date_active,
      P_END_DATE_ACTIVE         => p_end_date_active,
      P_RESOURCE_NAME         => p_name,
      P_SOURCE_NAME         => p_name,

      -- all other properties are left as null (they aren't required)
      X_RETURN_STATUS           => l_return_status,
      X_MSG_COUNT               => l_msg_count,
      X_MSG_DATA                => l_msg_data,
      X_RESOURCE_ID             => l_resource_id,
      X_RESOURCE_NUMBER         => l_resource_number);
   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   jtf_rs_salesreps_pub.create_salesrep
     (P_API_VERSION             => 1.0,
      P_RESOURCE_ID             => l_resource_id,
      P_NAME                    => p_name,
      P_SALESREP_NUMBER         => p_emp_num,
      P_START_DATE_ACTIVE       => p_start_date_active,  -- same as resource
      P_END_DATE_ACTIVE         => p_end_date_active,    -- same as resource

      -- inherited
      P_SALES_CREDIT_TYPE_ID    => l_mgr_sct_id,

      -- all other properties are left as null (they aren't required)
      X_RETURN_STATUS           => l_return_status,
      X_MSG_COUNT               => l_msg_count,
      X_MSG_DATA                => l_msg_data,
      X_SALESREP_ID             => l_srp_id);
   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   x_srp_id := l_srp_id;

   -- assign the salesrep to the given compensation group for as long as
   -- he is active
   jtf_rs_group_members_pub.create_resource_group_members
     (P_API_VERSION          => 1.0,
      P_GROUP_ID             => p_comp_group_id,
      P_GROUP_NUMBER         => null,   -- not needed... looked up from ID
      P_RESOURCE_ID          => l_resource_id,
      P_RESOURCE_NUMBER      => null,   -- not needed... looked up from ID
      X_RETURN_STATUS        => l_return_status,
      X_MSG_COUNT            => l_msg_count,
      X_MSG_DATA             => l_msg_data,
      X_GROUP_MEMBER_ID      => l_group_member_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      -- pass on warning on msg stack that plan type couldn't be created
      FND_MESSAGE.SET_NAME('CN', 'CN_SRP_GROUP_ERR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

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
      ROLLBACK TO Create_TBH;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_TBH;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
     WHEN OTHERS THEN
      ROLLBACK TO Create_TBH;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count   => x_msg_count,
         p_data    => x_msg_data,
         p_encoded => FND_API.G_FALSE);
END Create_TBH;

-- Given a manager's employee number, create the next sequence number
-- for a TBH under that manager
FUNCTION Get_TBH_Emp_Num
  (p_mgr_emp_num                IN      VARCHAR2) RETURN NUMBER IS

     tbh_pre  varchar2(31) := p_mgr_emp_num || '-';
     res      number := 1;

     cursor tbh_nums is
     select to_number(replace(emp_num,tbh_pre,'')) n
       from cn_srp_hr_data
      where emp_num like tbh_pre || '%'
        and emp_num not like tbh_pre || '%-%'
        and category = 'TBH'
      order by n;
BEGIN
   for c in tbh_nums loop
      if c.n > res then
         return res;
      end if;
      res := res + 1;
   end loop;
   return res;
EXCEPTION
   when others then
      return 1;
END Get_TBH_Emp_Num;

END CN_ADD_TBH_PVT;

/
