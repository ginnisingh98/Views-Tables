--------------------------------------------------------
--  DDL for Package Body AS_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ACCESS_PVT" as
/* $Header: asxvacsb.pls 120.6.12010000.2 2009/02/19 06:09:56 sariff ship $ */
--
-- NAME
-- AS_ACCESS_PVT
--
-- HISTORY
--   7/17/98  AWU     CREATED
--   1/25/99  HUCHEN  Added Convert_Miss_SalesTeam_Rec procedure and invocation
--   06/27/00 AWU     More modifications based on new business logic
--   07/10/00 AWU     Took out Convert_Miss_SalesTeam_Rec procedure in 11i
--                    and made more business logic changes
--   07/13/00 AWU     added has_xxxAccess implementations
--   09/13/00 ACNG    add partner_exist_csr back so that user can pass in
--                    partner information without partner_cont_party_id
--                    when create sales team
--                    Check partner_customer_id is not null when there is
--                    no partner_cont_party_id or person_id pass in

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_ACCESS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxvacsb.pls';

FUNCTION salesTeam_flags_are_Valid(p_sales_team_rec IN OUT NOCOPY SALES_TEAM_REC_TYPE)
RETURN BOOLEAN IS
begin
    if (p_sales_team_rec.freeze_flag is NOT NULL
	and p_sales_team_rec.freeze_flag <> FND_API.G_MISS_CHAR)
    then
	if (AS_FOUNDATION_PVT.get_lookupMeaning('YES/NO',
		p_sales_team_rec.freeze_flag, AS_FOUNDATION_PVT.G_AR_LOOKUPS )
		is NULL)
	then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'FREEZE_FLAG', FALSE);
			FND_MESSAGE.Set_Token('VALUE', p_sales_team_rec.freeze_flag, FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		return false;
	end if;
    end if;

    if (p_sales_team_rec.reassign_flag is NOT NULL
	and p_sales_team_rec.reassign_flag <> FND_API.G_MISS_CHAR)
    then
	if (AS_FOUNDATION_PVT.get_lookupMeaning('YES/NO',
		p_sales_team_rec.reassign_flag, AS_FOUNDATION_PVT.G_AR_LOOKUPS )
		is NULL)
	then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'REASSIGN_FLAG', FALSE);
			FND_MESSAGE.Set_Token('VALUE', p_sales_team_rec.reassign_flag, FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		return false;
	end if;
    end if;

    if (p_sales_team_rec.team_leader_flag is NOT NULL
	and p_sales_team_rec.team_leader_flag <> FND_API.G_MISS_CHAR)
    then
	if (AS_FOUNDATION_PVT.get_lookupMeaning('YES/NO',
		p_sales_team_rec.team_leader_flag, AS_FOUNDATION_PVT.G_AR_LOOKUPS )
		is NULL)
	then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'TEAM_LEADER_FLAG', FALSE);
			FND_MESSAGE.Set_Token('VALUE', p_sales_team_rec.team_leader_flag, FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		return false;
	end if;
     end if;

	return true;
end;

procedure get_person_id(p_salesforce_id in varchar2,
			  x_person_id OUT NOCOPY varchar2)

is
	cursor get_person_id_csr is
	select employee_person_id
	from as_salesforce_v
	where salesforce_id = p_salesforce_id;

begin
	open get_person_id_csr;
	fetch get_person_id_csr into x_person_id;

	if (get_person_id_csr%NOTFOUND)
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'SALESFORCE_ID', FALSE);
			fnd_message.set_token('VALUE', p_salesforce_id, FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		 raise FND_API.G_EXC_ERROR;
	end if;
	close get_person_id_csr;
end;

procedure get_accessProfileValues(px_access_profile_rec in OUT NOCOPY
					AS_ACCESS_PUB.Access_Profile_Rec_Type)

is
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.get_accessProfileValues';
begin
	 IF px_access_profile_rec.opp_access_profile_value IS NULL OR
       px_access_profile_rec.opp_access_profile_value = FND_API.G_MISS_CHAR
    THEN
	px_access_profile_rec.opp_access_profile_value
		:= FND_PROFILE.Value('AS_OPP_ACCESS');
    END IF;

    IF px_access_profile_rec.lead_access_profile_value IS NULL OR
       px_access_profile_rec.lead_access_profile_value = FND_API.G_MISS_CHAR
    THEN
	px_access_profile_rec.lead_access_profile_value
		:= FND_PROFILE.Value('AS_LEAD_ACCESS');
    END IF;

    IF px_access_profile_rec.cust_access_profile_value IS NULL OR
       px_access_profile_rec.cust_access_profile_value = FND_API.G_MISS_CHAR
    THEN
	px_access_profile_rec.cust_access_profile_value
		:= FND_PROFILE.Value('AS_CUST_ACCESS');
    END IF;

    IF px_access_profile_rec.mgr_update_profile_value IS NULL OR
       px_access_profile_rec.mgr_update_profile_value = FND_API.G_MISS_CHAR
    THEN
	px_access_profile_rec.mgr_update_profile_value
		:= FND_PROFILE.Value('AS_MGR_UPDATE');
    END IF;

    IF px_access_profile_rec.admin_update_profile_value IS NULL OR
       px_access_profile_rec.admin_update_profile_value = FND_API.G_MISS_CHAR
    THEN
	px_access_profile_rec.admin_update_profile_value
		:= FND_PROFILE.Value('AS_ADMIN_UPDATE');
    END IF;
	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'AS_CUST_ACCESS: ' ||
px_access_profile_rec.cust_access_profile_value);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'AS_OPP_ACCESS: ' ||
px_access_profile_rec.opp_access_profile_value);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'AS_LEAD_ACCESS: ' ||
px_access_profile_rec.lead_access_profile_value);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'AS_MGR_UPDATE: ' ||
px_access_profile_rec.mgr_update_profile_value);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'AS_ADMIN_UPDATE: ' ||
px_access_profile_rec.mgr_update_profile_value);
	END IF;

end  get_accessProfileValues;


--- has_leadOwnerAccess is a private procedure currently.
procedure has_leadOwnerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
        ,p_access_profile_rec   IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_deleteLeadAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is
	select	'X'
	from	as_accesses_all a
	where	a.sales_lead_id = p_sales_lead_id
	  and   a.owner_flag = 'Y'
          and   a.salesforce_id = p_identity_salesforce_id;

	cursor manager_access_csr(p_resource_id number) is

	 select	'X'
	from	as_accesses_all a
	where	a.sales_lead_id = p_sales_lead_id
	and	EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
			 and (rm.parent_resource_id = rm.resource_id
				and a.owner_flag ='Y'
			       or (rm.parent_resource_id <> rm.resource_id)));

	cursor mgr_i_access_csr(p_resource_id number) is
        select	'X'
	from	as_accesses_all a
	where	a.sales_lead_id = p_sales_lead_id
         and    a.owner_flag = 'Y'
	and	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id));

	cursor admin_access_csr is
	select	'x'
	from	as_accesses_all a
	where	a.sales_lead_id = p_sales_lead_id
	and	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id
			 and ((rm.salesforce_id = p_identity_salesforce_id
				and a.owner_flag ='Y')
			     or (rm.salesforce_id <> p_identity_salesforce_id)));

	cursor admin_i_access_csr is
	select	'x'
	from	as_accesses_all a
	where	a.sales_lead_id = p_sales_lead_id
        and     a.owner_flag = 'Y'
	and	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

	cursor am_mgr_access_csr(p_resource_id number) is
	select 'x'
	from as_sales_leads lead, as_accesses_all a, as_rpt_managers_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.resource_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_resource_id = p_resource_id
	and lead.sales_lead_id = p_sales_lead_id;

       cursor am_admin_access_csr is
	select 'x'
	from as_sales_leads lead, as_accesses_all a, as_rpt_admins_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.salesforce_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_sales_group_id = p_admin_group_id
	and lead.sales_lead_id = p_sales_lead_id;

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_leadOwnerAccess';
begin
-- Standard call to check for call compatibility.
/*      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
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
*/
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_sales_lead_id: ' || p_sales_lead_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_admin_group_id: ' || p_admin_group_id);
	END IF;

      --
      -- API body
      --

	 -- Initialize access flag to 'N'
         x_update_access_flag := 'N';

  if p_check_access_flag = 'N'
  then
	x_update_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'
	-- PRM security
	open resource_access_csr;
	fetch resource_access_csr into l_tmp;
/*	if p_partner_cont_party_id is not null
		and  p_partner_cont_party_id <> FND_API.G_MISS_NUM
	then
		if (resource_access_csr%FOUND)
                then
			x_update_access_flag := 'Y';
			close resource_access_csr;
			return;
		end if;
	end if; */
/*	if p_person_id is null or p_person_id = fnd_api.g_miss_num
	then
		get_person_id(p_identity_salesforce_id, l_person_id);
	else
		l_person_id := p_person_id;
	end if;
	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'person id: ' || l_person_id);
*/
	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

/* per nilesh, even lead access profile is full, owner privilege is not
granted. Need to base on sales team or hierarchy */
/*	if l_access_profile_rec.lead_access_profile_value = 'F'
	then
		x_update_access_flag := 'Y';
	elsif resource_access_csr%FOUND */

        if resource_access_csr%FOUND
	then
		x_update_access_flag := 'Y';
	else
		if nvl(p_admin_flag,'N') <> 'Y'
		then
			if l_access_profile_rec.mgr_update_profile_value = 'U'
			then
				open manager_access_csr(p_identity_salesforce_id);
				fetch manager_access_csr into l_tmp;
				if manager_access_csr%FOUND
					-- First check if mgr's subordinate
					--   which are not 'AM'
				then
					x_update_access_flag := 'Y';
				else    -- if mgr's subordinate which are 'AM'
					open am_mgr_access_csr(p_identity_salesforce_id);
					fetch am_mgr_access_csr into l_tmp;
					if am_mgr_access_csr%FOUND
					then
						x_update_access_flag := 'Y';
					end if;
					close am_mgr_access_csr;
				end if; -- manager_access_csr%FOUND
				close manager_access_csr;
			elsif l_access_profile_rec.mgr_update_profile_value ='I'
			then
				open mgr_i_access_csr(p_identity_salesforce_id);
				fetch mgr_i_access_csr into l_tmp;
				if mgr_i_access_csr%FOUND
				then
					x_update_access_flag := 'Y';
				end if;
				close mgr_i_access_csr;
			end if; -- l_access_profile_rec.mgr_update_profile_value = 'U'
		elsif l_access_profile_rec.admin_update_profile_value = 'U'
		then
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if admin_access_csr%FOUND
                        then
				x_update_access_flag := 'Y';
	                else
				open am_admin_access_csr;
				fetch am_admin_access_csr into l_tmp;
				if am_admin_access_csr%FOUND
				then
					x_update_access_flag := 'Y';
				end if;
				close am_admin_access_csr;
			end if; -- admin_access_csr%FOUND
			close admin_access_csr;
		elsif l_access_profile_rec.admin_update_profile_value = 'I'
	        then
			open admin_i_access_csr;
			fetch admin_i_access_csr into l_tmp;
			if admin_i_access_csr%FOUND
                        then
				x_update_access_flag := 'Y';
			end if;
			close admin_i_access_csr;
		end if; -- if p_admin_flag <> 'Y'
	end if;
	close resource_access_csr;
   end if; --  if p_check_access_flag = 'N'
      --
      -- End of API body.
      --

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_update_access_flag: ' || x_update_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		    ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_leadOwnerAccess;


--- has_oppOwnerAccess is a private procedure currently.
procedure has_oppOwnerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
        ,p_access_profile_rec   IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_lead_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_oppOwnerAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is
	select	'X'
	from	as_accesses_all a
	where	a.lead_id = p_lead_id
	  and   a.owner_flag = 'Y'
          and   a.salesforce_id = p_identity_salesforce_id;

        cursor manager_access_csr(p_resource_id number) is
        select	'X'
	from	as_accesses_all a
	where	a.lead_id = p_lead_id
	and	EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
			 and (rm.parent_resource_id = rm.resource_id
				and a.owner_flag ='Y'
			       or (rm.parent_resource_id <> rm.resource_id)));

        cursor am_mgr_access_csr(p_resource_id number) is
	select 'x'
	from as_leads_all lead, as_accesses_all a, as_rpt_managers_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.resource_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_resource_id = p_resource_id
	and lead.lead_id = p_lead_id;

        cursor mgr_i_access_csr(p_resource_id number) is
        select	'X'
	from	as_accesses_all a
	where	a.lead_id = p_lead_id
        and    a.owner_flag = 'Y'
	and	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			 where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id));

        cursor admin_access_csr is
	select	'x'
	from	as_accesses_all a
	where	a.lead_id = p_lead_id
	and	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id
			 and ((rm.salesforce_id = p_identity_salesforce_id
				and a.owner_flag ='Y')
			     or (rm.salesforce_id <> p_identity_salesforce_id)));

	cursor admin_i_access_csr is
	select	'x'
	from	as_accesses_all a
	where	a.lead_id = p_lead_id
        and     a.owner_flag = 'Y'
	and	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

       cursor am_admin_access_csr is
       select 'x'
       from as_leads_all lead, as_accesses_all a, as_rpt_admins_v rm
       where lead.customer_id = a.customer_id
       and a.salesforce_id = rm.salesforce_id
       and a.salesforce_role_code = 'AM'
       and rm.parent_sales_group_id = p_admin_group_id
       and lead.lead_id = p_lead_id;

       l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
       l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_oppOwnerAccess';


begin
-- Standard call to check for call compatibility.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_lead_id: ' || p_lead_id);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'allow change opp owner profile: ' || fnd_profile.value('AS_ALLOW_CHANGE_OPP_OWNER') );
      END IF;


      --
      -- API body
      --

      -- Initialize access flag to 'N'
         x_update_access_flag := 'N';

      IF p_check_access_flag = 'N'
      THEN
          x_update_access_flag := 'Y';
      ELSE -- if p_check_access_flag = 'Y'
	-- PRM security

          if fnd_profile.value('AS_ALLOW_CHANGE_OPP_OWNER') = 'Y'
          then
              x_update_access_flag := 'Y';
          end if;

          l_access_profile_rec := p_access_profile_rec;
	  get_accessProfileValues(l_access_profile_rec);

	  open resource_access_csr;
	  fetch resource_access_csr into l_tmp;

          if (resource_access_csr%FOUND)
              then
	          x_update_access_flag := 'Y';
		  close resource_access_csr;
		  return;
           else
		if nvl(p_admin_flag,'N') <> 'Y'
		then
		    if l_access_profile_rec.mgr_update_profile_value = 'U'
		    then
		        open manager_access_csr(p_identity_salesforce_id);
			fetch manager_access_csr into l_tmp;
			if manager_access_csr%FOUND
			-- First check if mgr's subordinate
			--   which are not 'AM'
			then
			    x_update_access_flag := 'Y';

                        else    -- if mgr's subordinate which are 'AM'
			    open am_mgr_access_csr(p_identity_salesforce_id);
			    fetch am_mgr_access_csr into l_tmp;
			    if am_mgr_access_csr%FOUND
			    then
			        x_update_access_flag := 'Y';
			     end if;
			     close am_mgr_access_csr;
                         close manager_access_csr;
                         end if; -- manager_access_csr%FOUND

                     elsif l_access_profile_rec.mgr_update_profile_value ='I'
			 then
			     open mgr_i_access_csr(p_identity_salesforce_id);
			     fetch mgr_i_access_csr into l_tmp;
			     if mgr_i_access_csr%FOUND
			     then
			         x_update_access_flag := 'Y';

			     end if;
                             close mgr_i_access_csr;
                     end if; -- l_access_profile_rec.mgr_update_profile_value = 'U'

                 elsif l_access_profile_rec.admin_update_profile_value = 'U'
		 then
		     open admin_access_csr;
		     fetch admin_access_csr into l_tmp;
		     if admin_access_csr%FOUND
                     then
		         x_update_access_flag := 'Y';
	             else
			 open am_admin_access_csr;
			 fetch am_admin_access_csr into l_tmp;
			 if am_admin_access_csr%FOUND
			 then
			     x_update_access_flag := 'Y';
			 end if;
			 close am_admin_access_csr;
		      end if; -- admin_access_csr%FOUND
		      close admin_access_csr;
		 elsif l_access_profile_rec.admin_update_profile_value = 'I'
	         then
		      open admin_i_access_csr;
		      fetch admin_i_access_csr into l_tmp;
		      if admin_i_access_csr%FOUND
                      then
		          x_update_access_flag := 'Y';
		      end if;
		      close admin_i_access_csr;
                 end if;--nvl(p_admin_flag,'N') <> 'Y'
          close resource_access_csr;
	  end if;
       END IF;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_update_access_flag: ' || x_update_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		    ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_oppOwnerAccess;



function is_account_manager (p_salesforce_id in number, p_customer_id in number)
RETURN BOOLEAN IS
	cursor account_mgr_csr is
		select 'x'
		from as_accesses_all
		where salesforce_id = p_salesforce_id
		and salesforce_role_code = 'AM'
		and customer_id = p_customer_id
		and lead_id is null
		and sales_lead_id is null;
l_tmp varchar2(1);
begin
	open account_mgr_csr;
	fetch account_mgr_csr into l_tmp;
	if account_mgr_csr%FOUND
	then
		close account_mgr_csr;
		return true;
	else
		close account_mgr_csr;
		return false;
	end if;
end is_account_manager;

function is_sales_lead_owner_row (p_access_id in number)
RETURN BOOLEAN IS
        cursor owner_csr is
                select 'x'
                from as_accesses_all
                where access_id = p_access_id
                 and owner_flag = 'Y';

l_tmp varchar2(1);
begin
        open owner_csr;
        fetch owner_csr into l_tmp;
        if owner_csr%FOUND
        then
                close owner_csr;
                return true;
        else
                close owner_csr;
                return false;
        end if;
end is_sales_lead_owner_row;

procedure unmark_opp_owner_flag(p_lead_id in number, p_access_id in number) is

	cursor owner_exist_csr is
		select 'x'
		from as_accesses_all
		where lead_id = p_lead_id
                and access_id <> p_access_id
		and owner_flag = 'Y';

l_var varchar2(1);
begin
	open owner_exist_csr;
	fetch owner_exist_csr into l_var;
	close owner_exist_csr;

	if l_var is not null
	then
		update as_accesses_all
		set object_version_number =  nvl(object_version_number,0) + 1, owner_flag = 'N'
		where lead_id = p_lead_id
                and access_id <> p_access_id;
	end if;
end unmark_opp_owner_flag;


procedure unmark_owner_flag(p_sales_lead_id in number, p_access_id in number) is

	cursor owner_exist_csr is
		select 'x'
		from as_accesses_all
		where sales_lead_id = p_sales_lead_id
                and access_id <> p_access_id
		and owner_flag = 'Y';

l_var varchar2(1);
begin
	open owner_exist_csr;
	fetch owner_exist_csr into l_var;
	close owner_exist_csr;

	if l_var is not null
	then
		update as_accesses_all
		set object_version_number =  nvl(object_version_number,0) + 1, owner_flag = 'N'
		where sales_lead_id = p_sales_lead_id
                and access_id <> p_access_id;
	end if;
end unmark_owner_flag;

PROCEDURE Validate_PERSON_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_PERSON_ID        IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    Cursor C_Check_Assign_Person (X_person_id NUMBER) IS
      SELECT 'X'
      FROM   per_all_people_f per,
             jtf_rs_resource_extns res
      WHERE  per.person_id = X_person_id
      AND    TRUNC(SYSDATE) BETWEEN per.effective_start_date
             AND per.effective_end_date
      AND    res.category = 'EMPLOYEE'
      AND    res.source_id = per.person_id;

    l_val	VARCHAR2(1);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Validate_PERSON_ID';
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate person id');

	 -- Validate PERSON_ID
	 IF (p_person_id IS NOT NULL
          AND p_person_id <> FND_API.G_MISS_NUM)
	 THEN
        OPEN C_Check_Assign_Person (p_person_id);
        FETCH C_Check_Assign_Person INTO l_val;
        IF (C_Check_Assign_Person%NOTFOUND)
        THEN
          AS_UTILITY_PVT.Set_Message(
                p_module        => l_module,
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'PERSON_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  P_PERSON_ID );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Check_Assign_Person;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END;


PROCEDURE Validate_SALESFORCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_SALESFORCE_ID    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    Cursor C_Check_Assign_Salesforce (X_Assign_Id NUMBER) IS

      SELECT 'X'
      FROM   jtf_rs_resource_extns res,
	     jtf_rs_role_relations rrel,
	     jtf_rs_roles_b role
      WHERE  sysdate between res.start_date_active  and nvl(res.end_date_active,sysdate)
      AND    sysdate between rrel.start_date_active and nvl(rrel.end_date_active,sysdate)
      AND    res.resource_id = rrel.role_resource_id
      AND    rrel.role_resource_type = 'RS_INDIVIDUAL'
      AND    rrel.role_id = role.role_id
      AND    role.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
      AND    role.admin_flag = 'N'
      AND    res.resource_id = X_Assign_Id
      AND    res.category in ('EMPLOYEE','PARTY');

    l_val	VARCHAR2(1);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Validate_SALESFORCE_ID';

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate salesforce id');


	 IF (p_salesforce_id IS NOT NULL
          AND p_salesforce_id <> FND_API.G_MISS_NUM)
	 THEN
        OPEN C_Check_Assign_Salesforce (p_salesforce_id);
        FETCH C_Check_Assign_Salesforce INTO l_val;
        IF (C_Check_Assign_Salesforce%NOTFOUND)
        THEN
          AS_UTILITY_PVT.Set_Message(
                p_module        => l_module,
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'SALESFORCE_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  P_SALESFORCE_ID );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Check_Assign_Salesforce;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END;

procedure validate_sales_group_id(
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_sales_group_id      IN       NUMBER,
	  p_salesforce_id       IN       NUMBER,
          x_return_status       OUT NOCOPY      VARCHAR2,
          x_msg_count           OUT NOCOPY      NUMBER,
          x_msg_data            OUT NOCOPY      VARCHAR2
) IS

  l_val            VARCHAR2(1);
  l_return_status  VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_salesrep_group';
	CURSOR VALIDATE_SALESGROUP (p_SALESGROUP_ID NUMBER)
	IS
	      SELECT 'X'
	      FROM   jtf_rs_groups_b grp
	      WHERE  sysdate between GRP.start_date_active and nvl(GRP.end_date_active,sysdate)
	      AND    grp.group_id = p_SALESGROUP_ID ;

	CURSOR VALIDATE_COMBINATION (p_SALESREP_ID NUMBER, p_SALESGROUP_ID NUMBER)
	IS
		SELECT 'X'
		  FROM jtf_rs_group_members GRPMEM
		 WHERE resource_id = p_SALESREP_ID
		   AND group_id = p_SALESGROUP_ID
		   AND delete_flag = 'N'
		   AND EXISTS
			(SELECT 'X'
			   FROM jtf_rs_role_relations REL
			  WHERE role_resource_type = 'RS_GROUP_MEMBER'
			    AND delete_flag = 'N'
			    AND sysdate between REL.start_date_active and nvl(REL.end_date_active,sysdate)
			    AND REL.role_resource_id = GRPMEM.group_member_id
			    AND role_id IN (SELECT role_id FROM jtf_rs_roles_b WHERE role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')));
begin
-- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN  VALIDATE_SALESGROUP (p_sales_group_id);
  FETCH VALIDATE_SALESGROUP into l_val;
  IF VALIDATE_SALESGROUP%NOTFOUND THEN
      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		    'Private API: SALES_GROUP_ID is not valid');
      END IF;
      IF FND_PROFILE.value('ASF_BYPASS_GRP_VALIDATION') = 'Y' THEN
	  FND_MESSAGE.Set_Name('AS', 'AS_UNSET_BYP_GRP_VALIDN_PROF');
	  FND_MSG_PUB.ADD;
      ELSE
	AS_UTILITY_PVT.Set_Message(
	  p_module        => l_module,
	  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	  p_msg_name      => 'API_INVALID_ID',
	  p_token1        => 'COLUMN',
	  p_token1_value  => 'SALESGROUP_ID',
	  p_token2        => 'VALUE',
	  p_token2_value  => p_sales_group_id );
       END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE VALIDATE_SALESGROUP;

  OPEN  VALIDATE_COMBINATION (p_salesforce_id,p_sales_group_id);
  FETCH VALIDATE_COMBINATION into l_val;
  IF VALIDATE_COMBINATION%NOTFOUND THEN
      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		    'Private API: SALES_GROUP_ID,SALESFORCE_ID is not valid');
      END IF;
      IF FND_PROFILE.value('ASF_BYPASS_GRP_VALIDATION') = 'Y' THEN
	    FND_MESSAGE.Set_Name('AS', 'AS_UNSET_BYP_GRP_VALIDN_PROF');
	    FND_MSG_PUB.ADD;
      ELSE
	AS_UTILITY_PVT.Set_Message(
	  p_module        => l_module,
	  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	  p_msg_name      => 'API_INVALID_ID',
	  p_token1        => 'COLUMN',
	  p_token1_value  => 'SALESFORCE/SALESGROUP COMBINATION',
	  p_token2        => 'VALUE',
	  p_token2_value  => to_char(p_salesforce_id) || '/' || to_char(p_sales_group_id) );
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE VALIDATE_COMBINATION;
  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_sales_group_id;


PROCEDURE Validate_SALES_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE
   ,P_Sales_Lead_Id              IN   NUMBER
   ,X_Return_Status              OUT NOCOPY  VARCHAR2
   ,X_Msg_Count                  OUT NOCOPY  NUMBER
   ,X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Sales_Lead_Id_Exists (X_Sales_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM  as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

  l_val	VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Validate_SALES_LEAD_ID';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Validate Sales Lead Id');
      END IF;

      -- Validate Sales Lead Id
      OPEN  C_Sales_Lead_Id_Exists (p_Sales_Lead_Id);
      FETCH C_Sales_Lead_Id_Exists into l_val;

      IF C_Sales_Lead_Id_Exists%NOTFOUND
        THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'SALES_LEAD_ID', FALSE);
              FND_MESSAGE.Set_Token('VALUE', p_Sales_Lead_Id, FALSE);
              FND_MSG_PUB.ADD;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
        CLOSE C_Sales_Lead_Id_Exists ;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_SALES_LEAD_ID;

PROCEDURE Validate_Opportunity_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE
   ,P_Lead_Id              IN   NUMBER
   ,X_Return_Status              OUT NOCOPY  VARCHAR2
   ,X_Msg_Count                  OUT NOCOPY  NUMBER
   ,X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_Id_Exists (X_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM  as_leads_all
      WHERE lead_id = X_Lead_Id;

  l_val	VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Validate_Opportunity_ID';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Validate Sales Lead Id');
      END IF;

      -- Validate Lead Id
      OPEN  C_Lead_Id_Exists (p_Lead_Id);
      FETCH C_Lead_Id_Exists into l_val;

      IF C_Lead_Id_Exists%NOTFOUND
        THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'LEAD_ID', FALSE);
              FND_MESSAGE.Set_Token('VALUE', p_Lead_Id, FALSE);
              FND_MSG_PUB.ADD;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
        CLOSE C_Lead_Id_Exists ;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_Opportunity_ID;

PROCEDURE Validate_partner_party_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          x_return_status       OUT NOCOPY      VARCHAR2,
          x_msg_count           OUT NOCOPY      NUMBER,
          x_msg_data            OUT NOCOPY      VARCHAR2
) IS

  l_val            VARCHAR2(1);
  l_return_status  VARCHAR2(1);

  CURSOR C_Party_Exists (X_Party_Id NUMBER) IS
  SELECT  1
  FROM  HZ_PARTIES
  WHERE party_id = X_Party_Id;

BEGIN

  -- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  open C_Party_Exists(p_party_id);
  fetch C_Party_Exists into l_val;
  IF (C_Party_Exists%NOTFOUND) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PARTNER_CUSTOMER_ID', FALSE);
        FND_MSG_PUB.ADD;
     END IF;
  END IF;
  close C_Party_Exists;

  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_partner_party_id;

-- Procedure to validate the party__site_id
--
-- Validation:
--    Check if this party is in the HZ_PARTY_SITES table
--
-- NOTES:
--
PROCEDURE Validate_partner_party_site_id (
          p_init_msg_list       IN       VARCHAR2 := FND_API.G_FALSE,
          p_party_id            IN       NUMBER,
          p_party_site_id       IN       NUMBER,
          x_return_status       OUT NOCOPY      VARCHAR2,
          x_msg_count           OUT NOCOPY      NUMBER,
          x_msg_data            OUT NOCOPY      VARCHAR2
) IS

  l_val_1          VARCHAR2(1);
  l_val_2          VARCHAR2(1);
  l_return_status  VARCHAR2(1);

  CURSOR C_Party_Site_Exists (X_Party_Id NUMBER, X_Party_Site_Id NUMBER) IS
  SELECT  1
  FROM  AS_PARTY_ADDRESSES_V
  WHERE party_id = X_Party_Id
  AND party_site_id = X_Party_Site_Id;

  -- C_Party_Site_Exists_For_Partner_Party
  CURSOR C_Party_Site_Exists_Partner (X_Party_Id NUMBER, X_Party_Site_Id NUMBER) IS
    SELECT 1
    FROM AS_PARTY_ADDRESSES_V
    WHERE party_id = (SELECT PARTNER_PARTY_ID FROM PV_PARTNER_PROFILES WHERE PARTNER_ID = X_Party_Id)
  AND party_site_id = X_Party_Site_Id;

BEGIN

  -- initialize message list if p_init_msg_list is set to TRUE;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  open C_Party_Site_Exists(p_party_id, p_party_site_id);
  fetch C_Party_Site_Exists into l_val_1;

  IF (C_Party_Site_Exists%NOTFOUND) THEN

       open C_Party_Site_Exists_Partner(p_party_id, p_party_site_id);
       fetch C_Party_Site_Exists_Partner into l_val_2;

  	IF (C_Party_Site_Exists_Partner%NOTFOUND) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'PARTNER_ADDRESS_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
       END IF;

       close C_Party_Site_Exists_Partner;
  END IF;
  close C_Party_Site_Exists;


  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_partner_party_site_id;



-- Validate the sales team record:
--   All necessary sales team information is present
--   The customer_id, opportunity id and sales_lead_id are valid
--   also include address_id if profile options set to 'Y'
--   The sales team is not a duplicate (warn only)
--   All the lookups are valid
--   Sales group id is valid
PROCEDURE Validate_SalesTeamItems
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
) is
	cursor partner_exist_csr is
		select 1
		from as_salesforce_v
		where salesforce_id = p_sales_team_rec.salesforce_id
		and type = 'PARTNER';

l_val NUMBER:=0;
l_sales_team_rec SALES_TEAM_REC_TYPE;
l_check_address  VARCHAR2(1);
begin
	l_sales_team_rec := p_sales_team_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open partner_exist_csr;
	fetch partner_exist_csr into l_val;
	close partner_exist_csr;

	-- uncomment partner_exist_csr%NOTFOUND
	-- if user pass in PARTNER type information without any partner_cont_party_id
	-- then allow them to do so

	if (p_sales_team_rec.person_id is NULL
		or p_sales_team_rec.person_id = FND_API.G_MISS_NUM)
		and (l_val <> 1)
		and (p_sales_team_rec.partner_cont_party_id is NULL
		or p_sales_team_rec. partner_cont_party_id = FND_API.G_MISS_NUM)
	then
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'PERSON_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		raise FND_API.G_EXC_ERROR;
	end if;
	IF (p_sales_team_rec.partner_customer_id IS NULL
          or p_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM)
	THEN
		-- validate employee person id
		Validate_PERSON_ID(
		p_init_msg_list          => FND_API.G_FALSE,
		p_PERSON_ID    => p_sales_team_rec.PERSON_ID,
		x_return_status          => x_return_status,
		x_msg_count              => x_msg_count,
		 x_msg_data               => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			-- raise FND_API.G_EXC_ERROR;
                END IF;


		-- validate employee salesforce id
		Validate_SALESFORCE_ID(
		p_init_msg_list           => FND_API.G_FALSE,
		p_SALESFORCE_ID => p_sales_team_rec.SALESFORCE_ID,
		x_return_status           => x_return_status,
		x_msg_count               => x_msg_count,
		x_msg_data                => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
		END IF;
	end if;

	if (p_sales_team_rec.customer_id is NULL
		or p_sales_team_rec.customer_id = FND_API.G_MISS_NUM)
	  or (p_sales_team_rec.salesforce_id is NULL
		or p_sales_team_rec.salesforce_id = FND_API.G_MISS_NUM)
	then
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ID, SALESFORCE_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		 raise FND_API.G_EXC_ERROR;
	end if;


	if (l_val = 1) and (p_sales_team_rec.partner_customer_id is NULL or
	        p_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM)
		and (p_sales_team_rec.partner_cont_party_id is NULL
		or p_sales_team_rec. partner_cont_party_id = FND_API.G_MISS_NUM)
	then
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'PARTNER_CUSTOMER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		raise FND_API.G_EXC_ERROR;
	end if;

	if (p_sales_team_rec.partner_customer_id is NULL or
	        p_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM)
		and (p_sales_team_rec.partner_cont_party_id is NULL
		or p_sales_team_rec. partner_cont_party_id = FND_API.G_MISS_NUM)
		and (p_sales_team_rec.sales_group_id is NULL
		or p_sales_team_rec.sales_group_id = FND_API.G_MISS_NUM)
	then
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'SALES_GROUP_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		raise FND_API.G_EXC_ERROR;
	end if;

/*
	open partner_exist_csr;
	fetch partner_exist_csr into l_val;
	if partner_exist_csr%FOUND
	   and (p_sales_team_rec.partner_customer_id is NULL or
	        p_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM)
	then
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'PARTNER_CUSTOMER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
	end if;
     close partner_exist_csr;
*/
	-- validate sales_group_id
	if (p_sales_team_rec.sales_group_id is not null)
           and (p_sales_team_rec.sales_group_id<> fnd_api.g_miss_num)
	then
		validate_sales_group_id(
		p_init_msg_list          => FND_API.G_FALSE,
		p_sales_group_id         => p_sales_team_rec.sales_group_id,
		p_salesforce_id          => p_sales_team_rec.salesforce_id,
		x_return_status          => x_return_status,
		x_msg_count              => x_msg_count,
		x_msg_data               => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			raise FND_API.G_EXC_ERROR;
		END IF;
	end if;


        -- validate customer_id
          AS_TCA_PVT.validate_party_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_sales_team_rec.customer_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      IF(p_sales_team_rec.address_id is not null
	and p_sales_team_rec.address_id <> fnd_api.g_miss_num ) then
        -- validate address_id
          AS_TCA_PVT.validate_party_site_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_sales_team_rec.customer_id,
              p_party_site_id          => p_sales_team_rec.address_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;


      IF(p_sales_team_rec.partner_customer_id is not null
	and p_sales_team_rec.partner_customer_id <> fnd_api.g_miss_num )
	and
	(p_sales_team_rec.partner_address_id is not null
	and p_sales_team_rec.partner_address_id <> fnd_api.g_miss_num ) then

          validate_partner_party_site_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_sales_team_rec.partner_customer_id,
              p_party_site_id          => p_sales_team_rec.partner_address_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      if (p_sales_team_rec.partner_customer_id is not null
	and p_sales_team_rec.partner_customer_id <> fnd_api.g_miss_num )
      then
          validate_partner_party_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_sales_team_rec.partner_customer_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      end if;



	-- validate sales_lead_id
	if (p_sales_team_rec.sales_lead_id is NOT NULL
		and p_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
	then
		 Validate_Sales_Lead_Id (
		P_Init_Msg_List              => FND_API.G_FALSE
		,P_Sales_Lead_Id              => P_sales_team_rec.Sales_Lead_Id
		,X_Return_Status              => X_Return_Status
		,X_Msg_Count                  => X_Msg_Count
		,X_Msg_Data                   => X_Msg_Data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			raise FND_API.G_EXC_ERROR;
		END IF;
	end if;

	-- validate opportunity_id
	if (p_sales_team_rec.lead_id is NOT NULL
		and p_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
	then
		 Validate_Opportunity_Id (
		P_Init_Msg_List              => FND_API.G_FALSE
		,P_Lead_Id              => p_sales_team_rec.lead_id
		,X_Return_Status              => X_Return_Status
		,X_Msg_Count                  => X_Msg_Count
		,X_Msg_Data                   => X_Msg_Data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			raise FND_API.G_EXC_ERROR;
		 END IF;
	end if;


    if not salesTeam_flags_are_valid( l_sales_team_rec )
    then
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
		x_return_status := fnd_api.g_ret_sts_error;
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_INFO');
                FND_MESSAGE.Set_Token('ROW', 'AS_ACCESSES', TRUE);
                FND_MSG_PUB.ADD;
	    END IF;
    end if;

end Validate_SalesTeamItems;

-- Perform sales team duplication check.  Note that this only produces a
-- warning to let the user know that a possible duplicate sales team has
-- been inserted, it is not an Error

function duplicate_salesTeam(p_sales_team_rec in SALES_TEAM_REC_TYPE) return boolean
is
	cursor get_dup_salesTeam_csr is
		select access_id
		from as_accesses
		where customer_id = p_sales_team_rec.customer_id
		and nvl(lead_id, -99) = nvl(p_sales_team_rec.lead_id, -99)
		and nvl(sales_lead_id, -99) = nvl(p_sales_team_rec.sales_lead_id, -99)
		and salesforce_id = p_sales_team_rec.salesforce_id
		and nvl(sales_group_id, -99) = nvl(p_sales_team_rec.sales_group_id, -99);


l_val NUMBER;
begin

	open get_dup_salesTeam_csr;
	fetch get_dup_salesTeam_csr into l_val;
	if (get_dup_salesTeam_csr%FOUND)
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_DUP_SALESTEAM');
			FND_MSG_PUB.ADD;
		END IF;
		return TRUE;
	else
		return FALSE;
	end if;
	close get_dup_salesTeam_csr;
end duplicate_salesTeam;

PROCEDURE Create_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_access_id                 	OUT NOCOPY     NUMBER
) is

l_api_name    	CONSTANT VARCHAR2(30) := 'Create_SalesTeam';
l_api_version_number  CONSTANT NUMBER   := 2.0;
l_rowid     	ROWID;
l_access_id NUMBER;
l_return_status VARCHAR2(1);
l_member_access VARCHAR2(1);
l_member_role VARCHAR2(1);
l_sales_team_rec SALES_TEAM_REC_TYPE;
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_internal_update_access number;
l_open_flag VARCHAR2(1);
l_update_access_flag varchar2(1);
l_object_creation_date date;
l_lead_rank_score number;

        cursor get_opp_open_flag_csr(pc_lead_id number) is
          select decode(st.opp_open_status_flag,'N',NULL,st.opp_open_status_flag)
          from as_leads_all ld, as_statuses_b st
          where ld.lead_id = pc_lead_id
          and ld.status = st.status_code(+);

        cursor get_lead_open_flag_csr(pc_sales_lead_id number) is
          select decode(st.opp_open_status_flag,'N',NULL,st.opp_open_status_flag)
          from as_sales_leads ld, as_statuses_b st
          where ld.sales_lead_id = pc_sales_lead_id
          and ld.status_code = st.status_code(+);

        cursor get_lead_rank_score_csr(pc_sales_lead_id number) is
          select rank.min_score
          from as_sales_lead_ranks_b rank, as_sales_leads sl
          where sl.sales_lead_id = pc_sales_lead_id
          and sl.lead_rank_id = rank.rank_id(+);

        cursor get_lead_creation_date_csr(pc_sales_lead_id number) is
          select sl.creation_date
          from as_sales_leads sl
          where sl.sales_lead_id = pc_sales_lead_id;

	cursor get_dup_access_id_csr(p_sales_team_rec in SALES_TEAM_REC_TYPE) is
		select access_id
		from as_accesses
		where customer_id = p_sales_team_rec.customer_id
		and nvl(address_id, -99) = nvl(p_sales_team_rec.address_id, -99)
		and nvl(lead_id, -99) = nvl(p_sales_team_rec.lead_id, -99)
		and nvl(sales_lead_id, -99) = nvl(p_sales_team_rec.sales_lead_id, -99)
		and salesforce_id = p_sales_team_rec.salesforce_id
		and nvl(sales_group_id, -99) = nvl(p_sales_team_rec.sales_group_id, -99)
                and nvl(salesforce_role_code, 'X') = nvl(p_sales_team_rec.salesforce_role_code, 'X');

	cursor lc_resource_type (pc_resource_id number) is
		select source_id
		from jtf_rs_resource_extns
		where resource_id = pc_resource_id
		and category = 'PARTY';

l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Create_SalesTeam';

begin
	-- Standard Start of API savepoint
	SAVEPOINT CREATE_SALESTEAM_PVT;

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

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- API body
    --

    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************
    IF FND_GLOBAL.User_Id IS NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
            FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   if p_validation_level = FND_API.G_VALID_LEVEL_FULL
   then

	AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id =>  p_identity_salesforce_id
	 , p_admin_group_id => p_admin_group_id
         ,x_return_status => l_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    end if;

    -- ******************************************************************

   l_sales_team_rec := p_sales_team_rec;

   	if l_sales_team_rec.partner_cont_party_id is null
		or l_sales_team_rec.partner_cont_party_id = fnd_api.g_miss_num
	then
		open lc_resource_type (l_sales_team_rec.salesforce_id);
		fetch lc_resource_type into l_sales_team_rec.partner_cont_party_id;
		close lc_resource_type;
	end if;

    IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
    THEN
        Validate_SalesTeamItems(
		p_api_version_number	=> 2.0,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
		p_sales_team_rec        => l_sales_team_rec,
		x_return_status         => x_return_status,
		x_msg_count             => x_msg_count,
		x_msg_data              => x_msg_data);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     end if;

   if p_check_access_flag = 'Y'
   then
    IF (p_sales_team_rec.lead_id is NULL or p_sales_team_rec.lead_id = FND_API.G_MISS_NUM)
	 and (p_sales_team_rec.sales_lead_id is NULL or p_sales_team_rec.sales_lead_id = FND_API.G_MISS_NUM)
    THEN
       AS_ACCESS_PUB.has_updateCustomerAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_customer_id            => p_sales_team_rec.customer_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => NULL
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,x_update_access_flag    => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
      ELSIF (p_sales_team_rec.lead_id is not NULL and p_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
      then

	AS_ACCESS_PUB.has_updateOpportunityAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id         => p_sales_team_rec.lead_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => Null
        ,x_return_status          => l_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
        ,x_update_access_flag     => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSIF (p_sales_team_rec.sales_lead_id is not NULL and p_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
      then
        AS_ACCESS_PUB.has_updateLeadAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_sales_lead_id         => p_sales_team_rec.sales_lead_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => Null
        ,x_return_status          => l_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
        ,x_update_access_flag     => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   end if; -- p_check_access_flag = 'Y'

	if l_sales_team_rec.address_id = FND_API.G_MISS_NUM then
	  l_sales_team_rec.address_id := NULL;
	end if;
	if l_sales_team_rec.lead_id = FND_API.G_MISS_NUM then
	  l_sales_team_rec.lead_id := NULL;
	end if;
	if l_sales_team_rec.sales_lead_id = FND_API.G_MISS_NUM then
	  l_sales_team_rec.sales_lead_id := NULL;
	end if;
	if l_sales_team_rec.sales_group_id = FND_API.G_MISS_NUM then
	  l_sales_team_rec.sales_group_id := NULL;
	end if;

        if l_sales_team_rec.salesforce_role_code = FND_API.G_MISS_CHAR then
	  l_sales_team_rec.salesforce_role_code := NULL;
	end if;

        --Owner is always a team leader
        if l_sales_team_rec.owner_flag = 'Y' then
	  l_sales_team_rec.team_leader_flag := 'Y';
	end if;


        if duplicate_salesTeam(l_sales_team_rec)
        then
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--	open get_dup_access_id_csr(l_sales_team_rec);
	--	fetch get_dup_access_id_csr into x_access_id;
	--	close get_dup_access_id_csr;
		return;
         end if;

	if l_sales_team_rec.reassign_flag = 'Y'
		and l_sales_team_rec.reassign_reason is null
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'reassign_reason', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		 raise fnd_api.g_exc_error;
	end if;

        --if  (l_sales_team_rec.sales_lead_id is NOT NULL
        --         and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
	--	and l_sales_team_rec.owner_flag = 'Y'
	--	and p_check_access_flag = 'Y'

        if  (l_sales_team_rec.sales_lead_id is NOT NULL
             and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
             and l_sales_team_rec.owner_flag = 'Y'
             and fnd_profile.value('AS_ALLOW_CHANGE_LEAD_OWNER')<>'Y'
             and p_check_access_flag = 'Y'
	then
		 has_leadOwnerAccess
			( p_api_version_number     => 2.0
			,p_init_msg_list          => p_init_msg_list
			,p_validation_level       => p_validation_level
			,p_access_profile_rec     => p_access_profile_rec
			,p_admin_flag             => p_admin_flag
			 ,p_admin_group_id         => p_admin_group_id
			,p_person_id              =>l_identity_sales_member_rec.employee_person_id
			,p_sales_lead_id         => p_sales_team_rec.sales_lead_id
			,p_check_access_flag      => 'Y'
			,p_identity_salesforce_id => p_identity_salesforce_id
			,p_partner_cont_party_id  => Null
			,x_return_status          => l_return_status
			,x_msg_count              => x_msg_count
			,x_msg_data               => x_msg_data
			,x_update_access_flag     => l_update_access_flag
		);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
				AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateLeadAccess fail');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (l_update_access_flag <> 'Y') THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.Set_Name('AS', 'API_NO_OWNER_PRIVILEGE');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
        end if; -- check owner privilege


        if  (l_sales_team_rec.lead_id is NOT NULL
             and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
             and l_sales_team_rec.owner_flag = 'Y'
             and fnd_profile.value('AS_ALLOW_CHANGE_OPP_OWNER')<>'Y'
             --and p_check_access_flag = 'Y'
        then
              has_oppOwnerAccess
			( p_api_version_number     => 2.0
			  ,p_init_msg_list          => p_init_msg_list
			  ,p_validation_level       => p_validation_level
			  ,p_access_profile_rec     => p_access_profile_rec
			  ,p_admin_flag             => p_admin_flag
			  ,p_admin_group_id         => p_admin_group_id
			  ,p_person_id              =>l_identity_sales_member_rec.employee_person_id
			  ,p_lead_id                => p_sales_team_rec.lead_id
			  ,p_check_access_flag      => 'Y'
			  ,p_identity_salesforce_id => p_identity_salesforce_id
			  ,p_partner_cont_party_id  => Null
			  ,x_return_status          => l_return_status
			  ,x_msg_count              => x_msg_count
			  ,x_msg_data               => x_msg_data
			  ,x_update_access_flag     => l_update_access_flag		        );
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                     	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOppAccess fail');
		 END IF;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;

	    IF (l_update_access_flag <> 'Y') THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		     FND_MESSAGE.Set_Name('AS', 'API_NO_OPP_OWNER_PRIVILEGE');
		     FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	    END IF;

         end if;





	-- Account manager
        if l_sales_team_rec.salesforce_role_code = 'AM'
		and (nvl(fnd_profile.value('AS_DEF_CUST_ST_ROLE'),'PS') <>'AM')

	then
		if not is_account_manager(p_identity_salesforce_id, l_sales_team_rec.customer_id)
		     and (nvl(fnd_profile.value('AS_CUST_ACCESS'),'F') <>'F')
		   -- if login person is not account manager and not full access,he can't make other
                   -- people account manager

		then
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.Set_Name('AS','API_NO_ACC_MGR_PRIVILEGE');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;
        -- changes made by Jean. for HP security enhancement
	--if (l_sales_team_rec.lead_id is NOT NULL
	--	 and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
        --      or (l_sales_team_rec.sales_lead_id is NOT NULL
	--	 and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
	--  then
		 if l_sales_team_rec.team_leader_flag = 'Y' or l_sales_team_rec.owner_flag = 'Y'
		 then
			l_internal_update_access := 1;
		 else   l_internal_update_access := 0;
		 end if;
	 --  else l_internal_update_access := 1;
	 --  end if;
	if l_sales_team_rec.freeze_flag is null
		or l_sales_team_rec.freeze_flag = fnd_api.g_miss_char
	then
		l_sales_team_rec.freeze_flag := Nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');
	end if;

	--if l_sales_team_rec.owner_flag = 'Y' and (l_sales_team_rec.sales_lead_id is NOT NULL
        --         and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)

	--then
	--	unmark_owner_flag(l_sales_team_rec.sales_lead_id);
	--end if;

        --if l_sales_team_rec.owner_flag = 'Y' and (l_sales_team_rec.lead_id is NOT NULL
        --          and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)

	--then
	--	unmark_opp_owner_flag(l_sales_team_rec.lead_id);
	--end if;

     if l_sales_team_rec.lead_id is not null
     then
       open get_opp_open_flag_csr(l_sales_team_rec.lead_id);
       fetch get_opp_open_flag_csr into l_open_flag;
       close get_opp_open_flag_csr;
     end if;

     if l_sales_team_rec.sales_lead_id is not null
     then
       open get_lead_open_flag_csr(l_sales_team_rec.sales_lead_id);
       fetch get_lead_open_flag_csr into l_open_flag;
       close get_lead_open_flag_csr;

       open get_lead_rank_score_csr(l_sales_team_rec.sales_lead_id);
       fetch get_lead_rank_score_csr into l_lead_rank_score;
       close get_lead_rank_score_csr;

       if(l_lead_rank_score is null) then
         l_lead_rank_score := 0;
       end if;

       open get_lead_creation_date_csr(l_sales_team_rec.sales_lead_id);
       fetch get_lead_creation_date_csr into l_object_creation_date;
       close get_lead_creation_date_csr;

     end if;

     as_accesses_pkg.insert_row(
		X_Rowid                => l_rowid,
		X_Access_Id            => l_access_id,
		X_Last_Update_Date     => SYSDATE,
		X_Last_Updated_By      => FND_GLOBAL.User_Id,
		X_Creation_Date        => SYSDATE,
		X_Created_By           => FND_GLOBAL.User_Id,
		X_Last_Update_Login    => FND_GLOBAL.Conc_Login_Id,
		X_Access_Type          => 'X',
		X_Freeze_Flag          => l_sales_team_rec.freeze_flag,
		X_Reassign_Flag        => l_sales_team_rec.reassign_flag,
		X_Team_Leader_Flag     => l_sales_team_rec.team_leader_flag,
		X_Person_Id            => l_sales_team_rec.person_id,
		X_Customer_Id          => l_sales_team_rec.customer_id,
		X_Address_Id           => l_sales_team_rec.address_id,
		X_Salesforce_id        => l_sales_team_rec.salesforce_id,
		X_Created_Person_Id    => l_sales_team_rec.created_person_id,
		X_Partner_Customer_id  => l_sales_team_rec.partner_customer_id,
		X_Partner_Address_id   => l_sales_team_rec.partner_address_id,
		X_Lead_Id              => l_sales_team_rec.lead_id,
		X_Freeze_Date          => l_sales_team_rec.freeze_date,
		X_Reassign_Reason      => l_sales_team_rec.reassign_reason,
		X_Reassign_request_date      => l_sales_team_rec.reassign_request_date,
		X_Reassign_requested_person_id => l_sales_team_rec.reassign_requested_person_id,
		X_Attribute_Category   => l_sales_team_rec.attribute_category,
		X_Attribute1           => l_sales_team_rec.attribute1,
		X_Attribute2           => l_sales_team_rec.attribute2,
		X_Attribute3           => l_sales_team_rec.attribute3,
		X_Attribute4           => l_sales_team_rec.attribute4,
		X_Attribute5           => l_sales_team_rec.attribute5,
		X_Attribute6           => l_sales_team_rec.attribute6,
		X_Attribute7           => l_sales_team_rec.attribute7,
		X_Attribute8           => l_sales_team_rec.attribute8,
		X_Attribute9           => l_sales_team_rec.attribute9,
		X_Attribute10          => l_sales_team_rec.attribute10,
		X_Attribute11          => l_sales_team_rec.attribute11,
		X_Attribute12          => l_sales_team_rec.attribute12,
		X_Attribute13          => l_sales_team_rec.attribute13,
		X_Attribute14          => l_sales_team_rec.attribute14,
		X_Attribute15          => l_sales_team_rec.attribute15,
		X_Sales_group_id       => l_sales_team_rec.sales_group_id,
		X_Sales_lead_id        => l_sales_team_rec.sales_lead_id,
		X_Internal_update_access => l_internal_update_access,
		X_Partner_Cont_Party_Id => l_sales_team_rec.partner_cont_party_id,
		 X_owner_flag	    =>   l_sales_team_rec.owner_flag,
		X_created_by_tap_flag	 =>l_sales_team_rec.created_by_tap_flag,
		X_prm_keep_flag      =>   l_sales_team_rec.prm_keep_flag,
		X_Salesforce_Role_Code => l_sales_team_rec.salesforce_role_code,
		X_Salesforce_Relationship_Code => l_sales_team_rec.salesforce_relationship_code,
                X_open_flag        => l_open_flag,
                X_lead_rank_score  => l_lead_rank_score,
                X_object_creation_date => l_object_creation_date,
		X_contributor_flag =>l_sales_team_rec.contributor_flag); -- Added for ASNB

		x_access_id := l_access_id;
                x_return_status := l_return_status;

               if is_sales_lead_owner_row(x_access_id)
               then
                  update as_leads_all set object_version_number =  nvl(object_version_number,0) + 1, owner_salesforce_id = l_sales_team_rec.salesforce_id,
                  owner_sales_group_id = l_sales_team_rec.sales_group_id
                  where lead_id = l_sales_team_rec.lead_id;
               end if;

               if is_sales_lead_owner_row(x_access_id)
                  and (l_sales_team_rec.sales_lead_id is NOT NULL
                  and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)

               then
	          unmark_owner_flag(l_sales_team_rec.sales_lead_id, x_access_id);
	       end if;

               if is_sales_lead_owner_row(x_access_id)
                  and (l_sales_team_rec.lead_id is NOT NULL
                  and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
               then
	          unmark_opp_owner_flag(l_sales_team_rec.lead_id, x_access_id);
	       end if;


    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data            =>    x_msg_data
      );


 EXCEPTION

         WHEN DUP_VAL_ON_INDEX THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
		open get_dup_access_id_csr(l_sales_team_rec);
		fetch get_dup_access_id_csr into x_access_id;
		close get_dup_access_id_csr;
	        FND_MESSAGE.Set_Name('AS', 'API_DUP_SALESTEAM');
	        FND_MSG_PUB.ADD;

         END IF;

         WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end  Create_SalesTeam;


PROCEDURE Delete_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
) is

	cursor get_access_info_csr(p_access_id NUMBER) is
		select 1
		from as_accesses
		where access_id = p_access_id;

	l_api_name    	CONSTANT VARCHAR2(30) := 'Delete_SalesTeam';
	l_api_version_number  CONSTANT NUMBER   := 2.0;
	l_return_status VARCHAR2(1);
	l_member_access VARCHAR2(1);
	l_member_role VARCHAR2(1);
	l_val NUMBER;
	l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
	l_update_access_flag varchar2(1);
    l_is_owner varchar2(1);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Delete_SalesTeam';

begin
	-- Standard Start of API savepoint
	SAVEPOINT DELETE_SALESTEAM_PVT;

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

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- API body
    --

    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************
    IF FND_GLOBAL.User_Id IS NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
            FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     if p_validation_level = FND_API.G_VALID_LEVEL_FULL
     then

	AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id =>  p_identity_salesforce_id
	 , p_admin_group_id => p_admin_group_id
         ,x_return_status => l_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    end if;


    -- ******************************************************************

    if (p_sales_team_rec.access_id is NULL)
    then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'ACCESS_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
    end if;

    open get_access_info_csr(p_sales_team_rec.access_id);
    fetch get_access_info_csr into l_val;

    if (get_access_info_csr%NOTFOUND)
    then
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
		FND_MESSAGE.Set_Token('COLUMN', 'ACCESS_ID', FALSE);
		fnd_message.set_token('VALUE', p_sales_team_rec.access_id, FALSE);
		FND_MSG_PUB.ADD;
	END IF;
	close get_access_info_csr;
        raise FND_API.G_EXC_ERROR;
    End if;

   if p_check_access_flag = 'Y'
   then
    IF (p_sales_team_rec.lead_id is NULL or p_sales_team_rec.lead_id = FND_API.G_MISS_NUM)
	 and (p_sales_team_rec.sales_lead_id is NULL or p_sales_team_rec.sales_lead_id = FND_API.G_MISS_NUM)
    THEN
       AS_ACCESS_PUB.has_updateCustomerAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_customer_id            => p_sales_team_rec.customer_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => NULL
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,x_update_access_flag    => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_DELETE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSIF (p_sales_team_rec.lead_id is not NULL and p_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
     then

        AS_ACCESS_PUB.has_updateOpportunityAccess
            ( p_api_version_number     => 2.0
             ,p_init_msg_list          => p_init_msg_list
             ,p_validation_level       => p_validation_level
             ,p_access_profile_rec     => p_access_profile_rec
             ,p_admin_flag             => p_admin_flag
             ,p_admin_group_id         => p_admin_group_id
             ,p_person_id              => l_identity_sales_member_rec.employee_person_id
             ,p_opportunity_id         => p_sales_team_rec.lead_id
             ,p_check_access_flag      => 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
             ,p_partner_cont_party_id  => Null
             ,x_return_status          => l_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data
             ,x_update_access_flag     => l_update_access_flag
            );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               IF (l_update_access_flag <> 'Y') THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('AS', 'API_NO_DELETE_PRIVILEGE');
                      FND_MSG_PUB.ADD;
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

     ELSIF (p_sales_team_rec.sales_lead_id is not NULL and p_sales_team_rec.sales_lead_id <>FND_API.G_MISS_NUM)
     then
		has_updateLeadAccess
		( p_api_version_number     => 2.0
		,p_init_msg_list          => p_init_msg_list
		,p_validation_level       => p_validation_level
		,p_access_profile_rec     => p_access_profile_rec
		,p_admin_flag             => p_admin_flag
		,p_admin_group_id         => p_admin_group_id
		,p_person_id              =>l_identity_sales_member_rec.employee_person_id
		 ,p_sales_lead_id         => p_sales_team_rec.sales_lead_id
		 ,p_check_access_flag      => 'Y'
		,p_identity_salesforce_id => p_identity_salesforce_id
		,p_partner_cont_party_id  => Null
		,x_return_status          => l_return_status
		,x_msg_count              => x_msg_count
		,x_msg_data               => x_msg_data
		,x_update_access_flag     => l_update_access_flag
		);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
				AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (l_update_access_flag <> 'Y') THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
       --end if; -- owner check
     END IF;
   end if; -- p_check_access_flag = 'Y'

   IF (p_sales_team_rec.lead_id is not NULL and p_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
     then
        if is_sales_lead_owner_row(p_sales_team_rec.access_id)
	then  -- only owner can delete owner row
	    has_oppOwnerAccess
	    ( p_api_version_number     => 2.0
	      ,p_init_msg_list          => p_init_msg_list
	      ,p_validation_level       => p_validation_level
	      ,p_access_profile_rec     => p_access_profile_rec
	      ,p_admin_flag             => p_admin_flag
	      ,p_admin_group_id         => p_admin_group_id
	      ,p_person_id              =>l_identity_sales_member_rec.employee_person_id
	      ,p_lead_id         => p_sales_team_rec.lead_id
	      ,p_check_access_flag      => 'Y'
	      ,p_identity_salesforce_id => p_identity_salesforce_id
	      ,p_partner_cont_party_id  => Null
	      ,x_return_status          => l_return_status
	      ,x_msg_count              => x_msg_count
	      ,x_msg_data               => x_msg_data
	      ,x_update_access_flag     => l_update_access_flag
             );

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOppAccess fail');
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	    IF (l_update_access_flag <> 'Y') THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		    FND_MESSAGE.Set_Name('AS', 'API_NO_OPP_OWNER_PRIVILEGE');
		    FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	     END IF;
        end if; -- is_sales_lead_owner_row(p_sales_team_rec.access_id)
   END IF;

   IF (p_sales_team_rec.sales_lead_id is not NULL and p_sales_team_rec.sales_lead_id <>FND_API.G_MISS_NUM)
     then
	if is_sales_lead_owner_row(p_sales_team_rec.access_id)
	then  -- only owner can delete owner row
		has_leadOwnerAccess
			( p_api_version_number     => 2.0
			,p_init_msg_list          => p_init_msg_list
			,p_validation_level       => p_validation_level
			,p_access_profile_rec     => p_access_profile_rec
			,p_admin_flag             => p_admin_flag
			 ,p_admin_group_id         => p_admin_group_id
			,p_person_id              =>l_identity_sales_member_rec.employee_person_id
			,p_sales_lead_id         => p_sales_team_rec.sales_lead_id
			,p_check_access_flag      => 'Y'
			,p_identity_salesforce_id => p_identity_salesforce_id
			,p_partner_cont_party_id  => Null
			,x_return_status          => l_return_status
			,x_msg_count              => x_msg_count
			,x_msg_data               => x_msg_data
			,x_update_access_flag     => l_update_access_flag
		);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
				AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateLeadAccess fail');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (l_update_access_flag <> 'Y') THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.Set_Name('AS', 'API_NO_OWNER_PRIVILEGE');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
        end if;
    END IF;

    l_is_owner := 'N';

    delete from as_accesses
    where access_id = p_sales_team_rec.access_id;
-- the call of AS_OPP_OWNER_PVT.ASSIGN_OPPOWNER removed  since OTS UI is validating before deleting
--     somebody has to be an owner of the opportunity


    x_return_status := l_return_status;

    --
    -- End of API body.
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );

 EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		   ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end Delete_SalesTeam;

PROCEDURE Update_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                := FND_API.G_FALSE,
        p_validation_level		IN	NUMBER
						:= FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec IN AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_access_id                 	OUT NOCOPY     NUMBER
) is

l_api_name    	CONSTANT VARCHAR2(30) := 'Update_SalesTeam';
l_api_version_number  CONSTANT NUMBER   := 2.0;
l_rowid ROWID;
l_member_access VARCHAR2(1);
l_member_role VARCHAR2(1);
l_return_status VARCHAR2(1);
l_last_update_date DATE;
l_sales_team_rec SALES_TEAM_REC_TYPE;
l_internal_update_access number;
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_update_access_flag varchar2(1);
l_owner_flag varchar2(1);
l_salesforce_role_code varchar2(30);

cursor get_salesTeam_info_csr is
	select rowid, last_update_date
	from as_accesses
	where access_id = p_sales_team_rec.access_id
	for update of access_id nowait;

cursor get_owner_flag (p_access_id number) is
       select owner_flag
       from as_accesses_all
       where access_id = p_access_id;

cursor get_salesforce_role_code (p_access_id number) is
       select salesforce_role_code
       from as_accesses_all
       where access_id = p_access_id;

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.Update_SalesTeam';

begin
	-- Standard Start of API savepoint
	SAVEPOINT UPDATE_SALESTEAM_PVT;

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

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- API body
    --

    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************
    IF FND_GLOBAL.User_Id IS NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
            FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if p_validation_level = FND_API.G_VALID_LEVEL_FULL
     then

	AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id =>  p_identity_salesforce_id
	 , p_admin_group_id => p_admin_group_id
         ,x_return_status => l_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    end if;


   -- ******************************************************************

    l_sales_team_rec := p_sales_team_rec;

    if (l_sales_team_rec.access_id is NULL)
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'ACCESS_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
	end if;


      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
      THEN
		Validate_SalesTeamItems(
		p_api_version_number	=> 2.0,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
		p_sales_team_rec        => l_sales_team_rec,
		x_return_status         => x_return_status,
		x_msg_count             => x_msg_count,
		x_msg_data              => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      end if;

      if p_check_access_flag = 'Y'
   then
    IF (p_sales_team_rec.lead_id is NULL or p_sales_team_rec.lead_id = FND_API.G_MISS_NUM)
	and (p_sales_team_rec.sales_lead_id is NULL or p_sales_team_rec.sales_lead_id = FND_API.G_MISS_NUM)
    THEN
       AS_ACCESS_PUB.has_updateCustomerAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_customer_id            => p_sales_team_rec.customer_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => NULL
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,x_update_access_flag    => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSIF (p_sales_team_rec.lead_id is not NULL and p_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
     then
	AS_ACCESS_PUB.has_updateOpportunityAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id         => p_sales_team_rec.lead_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => Null
        ,x_return_status          => l_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
        ,x_update_access_flag     => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSIF (p_sales_team_rec.sales_lead_id is not NULL and p_sales_team_rec.sales_lead_id <>FND_API.G_MISS_NUM)
     then
        AS_ACCESS_PUB.has_updateLeadAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              =>l_identity_sales_member_rec.employee_person_id
        ,p_sales_lead_id         => p_sales_team_rec.sales_lead_id
        ,p_check_access_flag      => 'Y'
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => Null
        ,x_return_status          => l_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
        ,x_update_access_flag     => l_update_access_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateLeadAccess fail');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF (l_update_access_flag <> 'Y') THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   end if; -- p_check_access_flag = 'Y'

   IF (p_sales_team_rec.lead_id is not NULL and p_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
     then
          open get_owner_flag (l_sales_team_rec.access_id);
	  fetch get_owner_flag into l_owner_flag;
	  close get_owner_flag;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'l_owner_flag: ' || nvl(l_owner_flag, 'N') || '');

          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'l_sales_team_rec.owner_flag: ' || nvl(l_sales_team_rec.owner_flag, 'N') || '');
          END IF;


          if( l_sales_team_rec.owner_flag <>FND_API.G_MISS_CHAR and (nvl(l_owner_flag, 'N') <> nvl(l_sales_team_rec.owner_flag, 'N')))
          then
              has_oppOwnerAccess
			( p_api_version_number     => 2.0
			  ,p_init_msg_list          => p_init_msg_list
			  ,p_validation_level       => p_validation_level
			  ,p_access_profile_rec     => p_access_profile_rec
			  ,p_admin_flag             => p_admin_flag
			  ,p_admin_group_id         => p_admin_group_id
			  ,p_person_id              =>l_identity_sales_member_rec.employee_person_id
			  ,p_lead_id                => p_sales_team_rec.lead_id
			  ,p_check_access_flag      => 'Y'
			  ,p_identity_salesforce_id => p_identity_salesforce_id
			  ,p_partner_cont_party_id  => Null
			  ,x_return_status          => l_return_status
			  ,x_msg_count              => x_msg_count
			  ,x_msg_data               => x_msg_data
			  ,x_update_access_flag     => l_update_access_flag		        );
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                     	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOppAccess fail');
		 END IF;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;

	    IF (l_update_access_flag <> 'Y') THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		     FND_MESSAGE.Set_Name('AS', 'API_NO_OPP_OWNER_PRIVILEGE');
		     FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	    END IF;

         end if; --(nvl(l_owner_flag, 'N') <> nvl(l_sales_team_rec.owner_flag, 'N'))

    END IF;


	open get_salesTeam_info_csr;
	fetch get_salesTeam_info_csr into l_rowid, l_last_update_date;
	close  get_salesTeam_info_csr;

	if (l_sales_team_rec.last_update_date is NULL
	    or l_sales_team_rec.last_update_date = FND_API.G_MISS_DATE)
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			 FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	end if;
	if (l_last_update_date <> l_sales_team_rec.last_update_date)
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
			FND_MESSAGE.Set_Token('INFO', 'AS_ACCESSES', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
        end if;

	 --if (l_sales_team_rec.lead_id is NOT NULL)
	 --	 and (l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM) then
		 if l_sales_team_rec.team_leader_flag = 'Y'
		 then
			l_internal_update_access := 1;
		 else   l_internal_update_access := 0;
		 end if;
	 --else l_internal_update_access := 1;
	 --end if;

	 --if  (l_sales_team_rec.sales_lead_id is NOT NULL
         --        and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
         --       and l_sales_team_rec.owner_flag = 'Y'
	 --	and p_check_access_flag = 'Y'
	 --	and fnd_profile.value('AS_ALLOW_CHANGE_LEAD_OWNER')<>'Y'

        if  (l_sales_team_rec.sales_lead_id is NOT NULL
             and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)
             and l_sales_team_rec.owner_flag = 'Y'
	     and fnd_profile.value('AS_ALLOW_CHANGE_LEAD_OWNER')<>'Y'

        then
             open get_owner_flag (l_sales_team_rec.access_id);
	     fetch get_owner_flag into l_owner_flag;
	     close get_owner_flag;

             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'l_owner_flag: ' || nvl(l_owner_flag, 'N') || '');

             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'l_sales_team_rec.owner_flag: ' || nvl(l_sales_team_rec.owner_flag, 'N') || '');

             if(nvl(l_owner_flag, 'N') <> nvl(l_sales_team_rec.owner_flag, 'N'))
             then

		has_leadOwnerAccess
			( p_api_version_number     => 2.0
			,p_init_msg_list          => p_init_msg_list
			,p_validation_level       => p_validation_level
			,p_access_profile_rec     => p_access_profile_rec
			,p_admin_flag             => p_admin_flag
			 ,p_admin_group_id         => p_admin_group_id
			,p_person_id              =>l_identity_sales_member_rec.employee_person_id
			,p_sales_lead_id         => p_sales_team_rec.sales_lead_id
			,p_check_access_flag      => 'Y'
			,p_identity_salesforce_id => p_identity_salesforce_id
			,p_partner_cont_party_id  => Null
			,x_return_status          => l_return_status
			,x_msg_count              => x_msg_count
			,x_msg_data               => x_msg_data
			,x_update_access_flag     => l_update_access_flag
		);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
				AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateLeadAccess fail');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (l_update_access_flag <> 'Y') THEN
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				FND_MESSAGE.Set_Name('AS', 'API_NO_OWNER_PRIVILEGE');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
           end if;
        end if;

        open get_salesforce_role_code (l_sales_team_rec.access_id);
	fetch get_salesforce_role_code into l_salesforce_role_code;
	close get_salesforce_role_code;

	 -- below if condition modified for bug 8266750
	 -- Account manager
        if ((nvl(l_salesforce_role_code,'X') <> nvl(l_sales_team_rec.salesforce_role_code,'X'))
	           and is_account_manager(l_sales_team_rec.salesforce_id,l_sales_team_rec.customer_id))


                -- if want to update someone to be account manager
		-- or update 'AM' to be not 'AM'
	then
		if not is_account_manager(p_identity_salesforce_id, l_sales_team_rec.customer_id)
		  and (nvl(fnd_profile.value('AS_CUST_ACCESS'),'F') <>'F')
		   -- if login person is not account manager,he can't make other
                   -- people account manager or not account manager

		then
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				FND_MESSAGE.Set_Name('AS','API_NO_ACC_MGR_PRIVILEGE');
				FND_MSG_PUB.ADD;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;

	if l_sales_team_rec.reassign_flag = 'Y'
		and (l_sales_team_rec.reassign_reason is null
			or l_sales_team_rec.reassign_reason = fnd_api.g_miss_char)
	then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'reassign_reason', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		 raise fnd_api.g_exc_error;
	end if;
         --if l_sales_team_rec.owner_flag = 'Y' and (l_sales_team_rec.sales_lead_id is NOT NULL
         --        and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)

        --then
        --        unmark_owner_flag(l_sales_team_rec.sales_lead_id);
        --end if;

        --if l_sales_team_rec.owner_flag = 'Y' and (l_sales_team_rec.lead_id is NOT NULL
        --         and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)

	--then
	--	unmark_opp_owner_flag(l_sales_team_rec.lead_id);
	--end if;


         -- Owner is always a team leader
         if l_sales_team_rec.owner_flag = 'Y'
         then
             l_sales_team_rec.team_leader_flag :='Y';
         end if;

         if l_sales_team_rec.owner_flag <> 'Y' and (l_sales_team_rec.lead_id is NOT NULL and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
         then
            l_sales_team_rec.owner_flag := FND_API.G_MISS_CHAR;
         end if;


	  as_accesses_pkg.update_row(
		X_Rowid                => l_rowid,
		X_Access_Id            => l_sales_team_rec.access_id,
		X_Last_Update_Date     => SYSDATE,
		X_Last_Updated_By      => FND_GLOBAL.User_Id,
		X_Last_Update_Login    => FND_GLOBAL.Conc_Login_Id,
		X_Access_Type          => 'X',
		X_Freeze_Flag          => l_sales_team_rec.freeze_flag,
		X_Reassign_Flag        => l_sales_team_rec.reassign_flag,
		X_Team_Leader_Flag     => l_sales_team_rec.team_leader_flag,
		X_Person_Id            => l_sales_team_rec.person_id,
		X_Customer_Id          => l_sales_team_rec.customer_id,
		X_Address_Id           => l_sales_team_rec.address_id,
		X_Salesforce_id        => l_sales_team_rec.salesforce_id,
		X_Created_Person_Id    => l_sales_team_rec.created_person_id,
		X_Partner_Customer_id  => l_sales_team_rec.partner_customer_id,
		X_Partner_Address_id   => l_sales_team_rec.partner_address_id,
		X_Lead_Id              => l_sales_team_rec.lead_id,
		X_Freeze_Date          => l_sales_team_rec.freeze_date,
		X_Reassign_Reason      => l_sales_team_rec.reassign_reason,
		X_Reassign_request_date    => l_sales_team_rec.reassign_request_date,
		X_Reassign_requested_person_id => l_sales_team_rec.reassign_requested_person_id,
		X_Attribute_Category   => l_sales_team_rec.attribute_category,
		X_Attribute1           => l_sales_team_rec.attribute1,
		X_Attribute2           => l_sales_team_rec.attribute2,
		X_Attribute3           => l_sales_team_rec.attribute3,
		X_Attribute4           => l_sales_team_rec.attribute4,
		X_Attribute5           => l_sales_team_rec.attribute5,
		X_Attribute6           => l_sales_team_rec.attribute6,
		X_Attribute7           => l_sales_team_rec.attribute7,
		X_Attribute8           => l_sales_team_rec.attribute8,
		X_Attribute9           => l_sales_team_rec.attribute9,
		X_Attribute10          => l_sales_team_rec.attribute10,
		X_Attribute11          => l_sales_team_rec.attribute11,
		X_Attribute12          => l_sales_team_rec.attribute12,
		X_Attribute13          => l_sales_team_rec.attribute13,
		X_Attribute14          => l_sales_team_rec.attribute14,
		X_Attribute15          => l_sales_team_rec.attribute15,
		X_Sales_group_id       => l_sales_team_rec.sales_group_id,
		X_Sales_lead_id        => l_sales_team_rec.sales_lead_id,
		X_Internal_update_access => l_internal_update_access,
		X_Partner_Cont_Party_Id =>l_sales_team_rec.partner_cont_party_id,
		 X_owner_flag	    =>   l_sales_team_rec.owner_flag,
		X_created_by_tap_flag	 =>l_sales_team_rec.created_by_tap_flag,
		X_prm_keep_flag      =>   l_sales_team_rec.prm_keep_flag,
		X_Salesforce_Role_Code => l_sales_team_rec.salesforce_role_code,
		X_Salesforce_Relationship_Code => l_sales_team_rec.salesforce_relationship_code,
		X_contributor_flag =>l_sales_team_rec.contributor_flag); -- Added for ASNB

		x_access_id := l_sales_team_rec.access_id;

		x_return_status := l_return_status;

                if is_sales_lead_owner_row(l_sales_team_rec.access_id)
                then
                    update as_leads_all set object_version_number =  nvl(object_version_number,0) + 1, owner_salesforce_id = l_sales_team_rec.salesforce_id,
                    --owner_sales_group_id = l_sales_team_rec.sales_group_id
                    owner_sales_group_id = (select sales_group_id from as_accesses_all where access_id =  l_sales_team_rec.access_id)
                    where lead_id = l_sales_team_rec.lead_id;
                end if;

                               if is_sales_lead_owner_row(x_access_id)
                  and (l_sales_team_rec.sales_lead_id is NOT NULL
                  and l_sales_team_rec.sales_lead_id <> FND_API.G_MISS_NUM)

               then
	          unmark_owner_flag(l_sales_team_rec.sales_lead_id, x_access_id);
	       end if;

               if is_sales_lead_owner_row(x_access_id)
                  and (l_sales_team_rec.lead_id is NOT NULL
                  and l_sales_team_rec.lead_id <> FND_API.G_MISS_NUM)
               then
	          unmark_opp_owner_flag(l_sales_team_rec.lead_id, x_access_id);
	       end if;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );


  EXCEPTION

      WHEN DUP_VAL_ON_INDEX THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                  FND_MESSAGE.Set_Name('AS', 'API_DUP_SALESTEAM');
	          FND_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;


    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
	ROLLBACK TO UPDATE_SALESTEAM_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		FND_MESSAGE.Set_Name('AS', 'API_CANNOT_RESERVE_RECORD');
		FND_MESSAGE.Set_Token('INFO', 'UPDATE_SALESTEAM', FALSE);
		FND_MSG_PUB.Add;
        END IF;

     WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		   ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end Update_SalesTeam;


function is_party_person (p_customer_id in number)
RETURN BOOLEAN IS
	cursor get_party_person_csr is
		select 'x'
		from hz_parties
		where party_id = p_customer_id
		and party_type = 'PERSON';
l_tmp varchar2(1);
begin
	open get_party_person_csr;
	fetch get_party_person_csr into l_tmp;
	if get_party_person_csr%FOUND
	then
		close get_party_person_csr;
		return true;
	else
		close get_party_person_csr;
		return false;
	end if;
end is_party_person;

-- private procedure which is called in has_viewCustomerAccess
-- person's access will be based on the access privilege of related organization
-- this procedure only handle the case of as_cust_profile = 'T'. Other cases are
-- handled in has_viewCustomerAccess
procedure has_viewPersonAccess
(       p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_identity_salesforce_id  IN NUMBER
	,x_view_access_flag	OUT NOCOPY VARCHAR2
) is

l_tmp varchar2(1);
l_person_id number;

	cursor resource_access_csr is

		select 'X'
		from as_accesses_all a, hz_parties p,hz_relationships rel
		where a.customer_id = rel.object_id
		and rel.object_id = p.party_id
		and p.party_type in ('ORGANIZATION','PERSON')
		and rel.subject_id = p_customer_id
		and a.salesforce_id = p_identity_salesforce_id
		and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		AND rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		and rownum = 1;


	cursor manager_access_csr(p_resource_id number) is

		select 'X'
		from as_accesses_all a, as_rpt_managers_v rm,
		     hz_parties p,hz_relationships rel
		where a.customer_id = rel.object_id
		and rel.object_id = p.party_id
		and p.party_type in ('ORGANIZATION','PERSON')
		and a.salesforce_id = rm.resource_id
		and rel.subject_id = p_customer_id
		and rm.parent_resource_id = p_resource_id
		and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		AND rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		and rownum = 1;

	cursor admin_access_csr is

                select 'X'
                from hz_parties p, hz_relationships rel
                where rel.object_id = p.party_id
                and p.party_type in ('ORGANIZATION','PERSON')
                and rel.subject_id = p_customer_id
                and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
                and rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
                and exists (select 1 from as_accesses_all a ,as_rpt_admins_v rm
                            where a.salesforce_id = rm.salesforce_id
                            and a.customer_id = rel.object_id
                            and rm.parent_sales_group_id = p_admin_group_id)
                and rownum = 1;

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_viewPersonAccess';

begin


	-- Debug Message
	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'has_viewPersonAccess: start ');

	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
	END IF;

	l_person_id := p_person_id;
	x_view_access_flag := 'N';
   	open resource_access_csr;
	fetch resource_access_csr into l_tmp;
	if (resource_access_csr%FOUND)
		-- access record exists for the login user itself
	then
		x_view_access_flag := 'Y';
	elsif nvl(p_admin_flag,'N') <> 'Y'
	then
		open manager_access_csr(p_identity_salesforce_id);
		fetch manager_access_csr into l_tmp;
		if (manager_access_csr%FOUND)
		then
			x_view_access_flag := 'Y';
		end if; -- mgr
		close  manager_access_csr;
	else
		open admin_access_csr;
		fetch admin_access_csr into l_tmp;
		if   admin_access_csr%FOUND
		then
			x_view_access_flag := 'Y';
		end if; -- admin
		close admin_access_csr;
	end if;
	close resource_access_csr;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_view_access_flag: ' || x_view_access_flag);
	-- Debug Message

	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'has_viewPersonAccess: end ');


	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
	END IF;

end has_viewPersonAccess;

-- private procedure which is called in has_updateCustomerAccess
-- person's access will be based on the access privilege of related organization
-- this procedure only handle the case of as_cust_profile in ('P', 'T'). Other cases are
-- handled in has_updateCustomerAccess

procedure has_updatePersonAccess
(	p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_identity_salesforce_id  IN NUMBER
	,x_update_access_flag	OUT NOCOPY VARCHAR2
)is

l_tmp varchar2(1);
l_person_id number;

	cursor resource_access_csr is

		select 'X'
		from as_accesses_all a, hz_parties p,hz_relationships rel
		where a.customer_id = rel.object_id
		and rel.object_id = p.party_id
		and p.party_type in ('ORGANIZATION','PERSON')
		and rel.subject_id = p_customer_id
		and a.salesforce_id = p_identity_salesforce_id
		and a.lead_id is null
		and a.sales_lead_id is null
                and a.team_leader_flag = 'Y'
		and rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		AND rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
		and rownum = 1;

	cursor manager_access_csr(p_resource_id number) is
		select	'X'
		from 	as_accesses_all a,
                        hz_parties p, hz_relationships rel
		where 	a.customer_id = rel.object_id
                and rel.object_id = p.party_id
                and p.party_type in ('ORGANIZATION','PERSON')
                and rel.subject_id = p_customer_id
		and a.lead_id is null
		and a.sales_lead_id is null
                and rel.subject_table_name = 'HZ_PARTIES'
                and rel.object_table_name = 'HZ_PARTIES'
		and 	(EXISTS (select 'X'
			 from   as_rpt_managers_v rm
                         where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
                         and ((rm.parent_resource_id = rm.resource_id
                               and a.team_leader_flag = 'Y')
                              or (rm.parent_resource_id <> rm.resource_id))));

	cursor mgr_i_access_csr(p_resource_id number) is
                select	'X'
	        from 	as_accesses_all a, hz_parties p, hz_relationships rel
	        where 	a.customer_id = rel.object_id
                and rel.object_id = p.party_id
                and p.party_type in ('ORGANIZATION','PERSON')
                and rel.subject_id = p_customer_id
                and a.lead_id is null
                and a.sales_lead_id is null
                and a.team_leader_flag = 'Y'
	        and 	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id));

	cursor admin_access_csr is
		select	'X'
		from 	as_accesses_all a, hz_parties p, hz_relationships rel
		where 	a.customer_id = rel.object_id
                and rel.object_id = p.party_id
                and p.party_type in ('ORGANIZATION','PERSON')
                and rel.subject_id = p_customer_id
		and a.lead_id is null
		and a.sales_lead_id is null
                and rel.object_table_name = 'HZ_PARTIES'
                and rel.subject_table_name = 'HZ_PARTIES'
		and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id
			 and ((rm.salesforce_id = p_identity_salesforce_id
				and a.team_leader_flag = 'Y')
			       or (rm.salesforce_id <> p_identity_salesforce_id)));

	cursor admin_i_access_csr is
	select	'x'
	from 	as_accesses_all a, hz_parties p, hz_relationships rel
	where 	a.customer_id = rel.object_id
        and rel.object_id = p.party_id
        and p.party_type in ('ORGANIZATION', 'PERSON')
        and rel.subject_id = p_customer_id
        and a.lead_id is null
        and a.sales_lead_id is null
        and              a.team_leader_flag = 'Y'
        and rel.object_table_name = 'HZ_PARTIES'
        and rel.subject_table_name = 'HZ_PARTIES'
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_updatePersonAccess';
begin

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updatePersonAccess start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

	l_person_id := p_person_id;
	 -- Initialize access flag to 'N'
         x_update_access_flag := 'N';

	open resource_access_csr;
        fetch resource_access_csr into l_tmp;
	if (resource_access_csr%FOUND)
		-- access record exists for the login user itself
	then
		x_update_access_flag := 'Y';
	else --  access record doesn't exist for the login user

	     if nvl(p_admin_flag,'N') <> 'Y' -- mgr
             then if p_access_profile_rec.mgr_update_profile_value = 'U'
 	          then
			open manager_access_csr(p_identity_salesforce_id);
			fetch manager_access_csr into l_tmp;
			if (manager_access_csr%FOUND)
			then
				x_update_access_flag := 'Y';
			end if;
                        close manager_access_csr;
                  elsif p_access_profile_rec.mgr_update_profile_value = 'I'
                  then
                        open mgr_i_access_csr(p_identity_salesforce_id);
                        fetch mgr_i_access_csr into l_tmp;
                        if(mgr_i_access_csr%FOUND)
                        then
                                x_update_access_flag := 'Y';
                        end if;
                        close mgr_i_access_csr;
		  end if;  -- mgr
	     else if p_access_profile_rec.admin_update_profile_value = 'U'
		  then
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if (admin_access_csr%FOUND)
			then
				x_update_access_flag := 'Y';
			end if;
                        close admin_access_csr;
                  elsif p_access_profile_rec.admin_update_profile_value = 'I'
                  then
                        open admin_i_access_csr;
                        fetch admin_i_access_csr into l_tmp;
                        if(admin_i_access_csr%FOUND)
                        then
                                x_update_access_flag := 'Y';
                        end if;
                        close admin_i_access_csr;
		  end if;  -- admin
	    end if; --nvl(p_admin_flag,'N') <> 'Y' -- mgr
	end if;
	close resource_access_csr;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'has_updatePersonAccess end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

end  has_updatePersonAccess;


procedure has_viewCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_viewCustomerAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is

		select	'X'
		from 	as_accesses_all
		where 	customer_id = p_customer_id
		and	salesforce_id = p_identity_salesforce_id;


	cursor manager_access_csr(p_resource_id number) is
		select	'X'
		from 	as_accesses_all a
		where 	customer_id = p_customer_id
		and 	(EXISTS (select 'X'
			 from   as_rpt_managers_v rm
                         where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id));

	cursor admin_access_csr is
		select	'X'
		from 	as_accesses_all a
		where 	customer_id = p_customer_id
		and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);
	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_viewCustomerAccess';

begin

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'customer_id: ' || p_customer_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'admin_group_id: ' || p_admin_group_id);
        END IF;

      -- Initialize access flag to 'N'
      x_view_access_flag := 'N';


  if p_check_access_flag = 'N'
  then
	x_view_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'
	--partner security checking. Return point
	if p_partner_cont_party_id is not null
		and  p_partner_cont_party_id <> FND_API.G_MISS_NUM
	then
		open resource_access_csr;
		fetch resource_access_csr into l_tmp;
		if (resource_access_csr%FOUND)
                then
			x_view_access_flag := 'Y';
			close resource_access_csr;
			return;
		end if;
		close resource_access_csr;
	end if;
/*
	if p_person_id is null or p_person_id = fnd_api.g_miss_num
	then
		get_person_id(p_identity_salesforce_id, l_person_id);
	else
		l_person_id := p_person_id;
	end if;
		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'person id: ' || l_person_id);
*/
	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

     if l_access_profile_rec.cust_access_profile_value in ('F', 'P')
    	then
     		x_view_access_flag := 'Y';
--    	elsif l_access_profile_rec.lead_access_profile_value = 'T'
--	   and l_access_profile_rec.opp_access_profile_value = 'T'
--	then
-- Fix bug 1623713
     else
		if nvl(p_admin_flag,'N') <> 'Y'
		then
			open manager_access_csr(p_identity_salesforce_id);
			fetch manager_access_csr into l_tmp;
			if (manager_access_csr%FOUND)
			then
				x_view_access_flag := 'Y';
			end if; -- mgr
			close  manager_access_csr;
		else
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if   admin_access_csr%FOUND
			then
				x_view_access_flag := 'Y';
			end if; -- admin
			close admin_access_csr;
		end if; -- profile combination is ('T', don't care, don't care)
	end if;  -- if l_access_profile_rec.cust_access_profile_value in ('F','P')

	if x_view_access_flag = 'N' and is_party_person(p_customer_id)
	then
		has_viewPersonAccess(
	        p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_customer_id		=> p_customer_id
		,p_identity_salesforce_id => p_identity_salesforce_id
		,x_view_access_flag	   => x_view_access_flag
		);
	end if;
  end if; -- if p_check_access_flag = 'N'

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_view_access_flag: ' || x_view_access_flag);
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_viewCustomerAccess;

procedure has_updateCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
)is
l_api_name            CONSTANT VARCHAR2(30) := 'has_updateCustomerAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is

		select	'X'
		from 	as_accesses_all
		where 	customer_id = p_customer_id
		and lead_id is null
		and sales_lead_id is null
                and team_leader_flag = 'Y'
		and	salesforce_id = p_identity_salesforce_id;


	cursor manager_access_csr(p_resource_id number) is
		select	'X'
		from 	as_accesses_all a
		where 	customer_id = p_customer_id
		and lead_id is null
		and sales_lead_id is null
		and 	(EXISTS (select 'X'
			 from   as_rpt_managers_v rm
                         where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
                         and ((rm.parent_resource_id = rm.resource_id
                               and a.team_leader_flag = 'Y')
                              or (rm.parent_resource_id <> rm.resource_id))));

	cursor mgr_i_access_csr(p_resource_id number) is
                select	'X'
	        from 	as_accesses_all a
	        where 	a.customer_id = p_customer_id
                and lead_id is null
                and sales_lead_id is null
                and    a.team_leader_flag = 'Y'
	        and 	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id));

	cursor admin_access_csr is
		select	'X'
		from 	as_accesses_all a
		where 	customer_id = p_customer_id
		and lead_id is null
		and sales_lead_id is null
		and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id
			 and ((rm.salesforce_id = p_identity_salesforce_id
				and a.team_leader_flag = 'Y')
			       or (rm.salesforce_id <> p_identity_salesforce_id)));

	cursor admin_i_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.customer_id = p_customer_id
        and lead_id is null
        and sales_lead_id is null
        and              a.team_leader_flag = 'Y'
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_updateCustomerAccess';

begin
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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'customer_id: ' || p_customer_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'admin_group_id: ' || p_admin_group_id);
	END IF;

      --
      -- API body
      --
	 -- Initialize access flag to 'N'
         x_update_access_flag := 'N';

  if p_check_access_flag = 'N'
  then
	x_update_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'
	open resource_access_csr;
	fetch resource_access_csr into l_tmp;
	if p_partner_cont_party_id is not null
		and  p_partner_cont_party_id <> FND_API.G_MISS_NUM
	then
		if (resource_access_csr%FOUND)
                then
			x_update_access_flag := 'Y';
			close resource_access_csr;
			return;
		end if;
	end if;
/*
	if p_person_id is null or p_person_id = fnd_api.g_miss_num
	then
		get_person_id(p_identity_salesforce_id, l_person_id);
	else
		l_person_id := p_person_id;
	end if;
	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'person id: ' || l_person_id);
*/
	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

	if l_access_profile_rec.cust_access_profile_value = 'F' then
        	x_update_access_flag := 'Y';
	elsif (resource_access_csr%FOUND)
		-- profile is 'P' or 'T' and access record exists for the login
                -- user itself
	then
		x_update_access_flag := 'Y';
	else --  profile is 'P' or 'T' and access record doesn't exist for the
             --  login user

	     if nvl(p_admin_flag,'N') <> 'Y' -- mgr
             then
               if l_access_profile_rec.mgr_update_profile_value = 'U'
 	          then
			open manager_access_csr(p_identity_salesforce_id);
			fetch manager_access_csr into l_tmp;
			if (manager_access_csr%FOUND)
			then
				x_update_access_flag := 'Y';
			end if;
                        close manager_access_csr;
	        elsif l_access_profile_rec.mgr_update_profile_value = 'I'
                  then
                        open mgr_i_access_csr(p_identity_salesforce_id);
                        fetch mgr_i_access_csr into l_tmp;
                        if(mgr_i_access_csr%FOUND)
                        then
                                x_update_access_flag := 'Y';
                        end if;
                        close mgr_i_access_csr;
                end if; -- mgr
	     else
               if l_access_profile_rec.admin_update_profile_value = 'U'
		  then
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if (admin_access_csr%FOUND)
			then
				x_update_access_flag := 'Y';
			end if;
                        close admin_access_csr;
                elsif l_access_profile_rec.admin_update_profile_value = 'I'
                  then
                        open admin_i_access_Csr;
                        fetch admin_i_access_csr into l_tmp;
                        if(admin_i_access_csr%FOUND)
                        then
                              x_update_access_flag := 'Y';
                        end if;
                        close admin_i_access_csr;
               end if;  -- admin
	    end if; --  (resource_access_csr%FOUND)
	end if;
	close resource_access_csr;

	if x_update_access_flag = 'N' and is_party_person(p_customer_id)
	then
		has_updatePersonAccess(
		p_access_profile_rec   => l_access_profile_rec
	        ,p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_customer_id		=> p_customer_id
		,p_identity_salesforce_id => p_identity_salesforce_id
		,x_update_access_flag	   => x_update_access_flag
		);
	end if;
  end if; --if p_check_access_flag = 'N'

     IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_update_access_flag: ' || x_update_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end  has_updateCustomerAccess;


procedure has_updateLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_updateLeadAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is
	select	'X'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
	  and    (a.team_leader_flag = 'Y' or a.owner_flag = 'Y')
          and   a.salesforce_id = p_identity_salesforce_id;

	cursor manager_access_csr(p_resource_id number) is

	 select	'X'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
	and 	EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
			 and (rm.parent_resource_id = rm.resource_id
				and (a.team_leader_flag = 'Y' or a.owner_flag = 'Y')
			       or (rm.parent_resource_id <> rm.resource_id)));

	cursor mgr_i_access_csr(p_resource_id number) is
        select	'X'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
         and    (a.team_leader_flag = 'Y' or a.owner_flag = 'Y')
	and 	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id));

	cursor admin_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id
			 and (rm.salesforce_id = p_identity_salesforce_id
				and (a.team_leader_flag = 'Y' or a.owner_flag = 'Y')
			       or (rm.salesforce_id <> p_identity_salesforce_id)));

	cursor admin_i_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
        and     (a.team_leader_flag = 'Y' or a.owner_flag = 'Y')
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

	cursor am_mgr_access_csr(p_resource_id number) is
	select 'x'
	from as_sales_leads lead, as_accesses_all a, as_rpt_managers_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.resource_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_resource_id = p_resource_id
	and lead.sales_lead_id = p_sales_lead_id;

       cursor am_admin_access_csr is
	select 'x'
	from as_sales_leads lead, as_accesses_all a, as_rpt_admins_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.salesforce_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_sales_group_id = p_admin_group_id
	and lead.sales_lead_id = p_sales_lead_id;

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_updateLeadAccess';
begin
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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_sales_lead_id: ' || p_sales_lead_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_admin_group_id: ' || p_admin_group_id);
        END IF;

      --
      -- API body
      --

	 -- Initialize access flag to 'N'
         x_update_access_flag := 'N';

  if p_check_access_flag = 'N'
  then
	x_update_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'
	-- PRM security
	open resource_access_csr;
	fetch resource_access_csr into l_tmp;
/*	if p_partner_cont_party_id is not null
		and  p_partner_cont_party_id <> FND_API.G_MISS_NUM
	then
		if (resource_access_csr%FOUND)
                then
			x_update_access_flag := 'Y';
			close resource_access_csr;
			return;
		end if;
	end if; */
/*
	if p_person_id is null or p_person_id = fnd_api.g_miss_num
	then
		get_person_id(p_identity_salesforce_id, l_person_id);
	else
		l_person_id := p_person_id;
	end if;
	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'person id: ' || l_person_id);
*/
	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

	if l_access_profile_rec.lead_access_profile_value = 'F'
	then
		x_update_access_flag := 'Y';
	elsif resource_access_csr%FOUND
	then
		x_update_access_flag := 'Y';
	else
		if nvl(p_admin_flag,'N') <> 'Y'
		then
			if l_access_profile_rec.mgr_update_profile_value = 'U'
			then
				open manager_access_csr(p_identity_salesforce_id);
				fetch manager_access_csr into l_tmp;
				if manager_access_csr%FOUND
					-- First check if mgr's subordinate
					--   which are not 'AM'
				then
					x_update_access_flag := 'Y';
				else    -- if mgr's subordinate which are 'AM'
					open am_mgr_access_csr(p_identity_salesforce_id);
					fetch am_mgr_access_csr into l_tmp;
					if am_mgr_access_csr%FOUND
					then
						x_update_access_flag := 'Y';
					end if;
					close am_mgr_access_csr;
				end if; -- manager_access_csr%FOUND
				close manager_access_csr;
			elsif l_access_profile_rec.mgr_update_profile_value = 'I'
			then
				open mgr_i_access_csr(p_identity_salesforce_id);
				fetch mgr_i_access_csr into l_tmp;
				if mgr_i_access_csr%FOUND
				then
					x_update_access_flag := 'Y';
				end if;
				close mgr_i_access_csr;
			end if; -- l_access_profile_rec.mgr_update_profile_value = 'U'
		elsif l_access_profile_rec.admin_update_profile_value = 'U'
		then
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if admin_access_csr%FOUND
                        then
				x_update_access_flag := 'Y';
	                else
				open am_admin_access_csr;
				fetch am_admin_access_csr into l_tmp;
				if am_admin_access_csr%FOUND
				then
					x_update_access_flag := 'Y';
				end if;
				close am_admin_access_csr;
			end if; -- admin_access_csr%FOUND
			close admin_access_csr;
		elsif l_access_profile_rec.admin_update_profile_value = 'I'
	        then
			open admin_i_access_csr;
			fetch admin_i_access_csr into l_tmp;
			if admin_i_access_csr%FOUND
                        then
				x_update_access_flag := 'Y';
			end if;
			close admin_i_access_csr;
		end if; -- if p_admin_flag <> 'Y'
	end if;
	close resource_access_csr;
   end if; --  if p_check_access_flag = 'N'
      --
      -- End of API body.
      --

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_update_access_flag: ' || x_update_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		    ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_updateLeadAccess;

procedure has_viewLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id		IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_viewLeadAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is
	select	'X'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
          and   a.salesforce_id = p_identity_salesforce_id;

	cursor manager_access_csr(p_resource_id number) is

	 select	'X'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
	and 	EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id);


	cursor admin_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.sales_lead_id = p_sales_lead_id
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

	cursor am_mgr_access_csr(p_resource_id number) is
	select 'x'
	from as_sales_leads lead, as_accesses_all a, as_rpt_managers_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.resource_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_resource_id = p_resource_id
	and lead.sales_lead_id = p_sales_lead_id;

       cursor am_admin_access_csr is
	select 'x'
	from as_sales_leads lead, as_accesses_all a, as_rpt_admins_v rm
	where lead.customer_id = a.customer_id
	and a.salesforce_id = rm.salesforce_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_sales_group_id = p_admin_group_id
	and lead.sales_lead_id = p_sales_lead_id;

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_viewLeadAccess';

begin
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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_sales_lead_id: ' || p_sales_lead_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_admin_group_id: ' || p_admin_group_id);
	END IF;

      --
      -- API body
      --

	 -- Initialize access flag to 'N'
         x_view_access_flag := 'N';

  if p_check_access_flag = 'N'
  then
	x_view_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'
	-- PRM security
	open resource_access_csr;
	fetch resource_access_csr into l_tmp;

	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

	if l_access_profile_rec.lead_access_profile_value in ('F','P')
	then
		x_view_access_flag := 'Y';
	elsif resource_access_csr%FOUND
	then
		x_view_access_flag := 'Y';
	else
		if nvl(p_admin_flag,'N') <> 'Y'
		then

			open manager_access_csr(p_identity_salesforce_id);
			fetch manager_access_csr into l_tmp;
			if manager_access_csr%FOUND
				-- First check if mgr's subordinate
				--   which are not 'AM'
			then
				x_view_access_flag := 'Y';
			else    -- if mgr's subordinate which are 'AM'
				open am_mgr_access_csr(p_identity_salesforce_id);
				fetch am_mgr_access_csr into l_tmp;
				if am_mgr_access_csr%FOUND
				then
					x_view_access_flag := 'Y';
				end if;
				close am_mgr_access_csr;
			end if; -- manager_access_csr%FOUND
			close manager_access_csr;
		else
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if admin_access_csr%FOUND
                        then
				x_view_access_flag := 'Y';
	                else
				open am_admin_access_csr;
				fetch am_admin_access_csr into l_tmp;
				if am_admin_access_csr%FOUND
				then
					x_view_access_flag := 'Y';
				end if;
				close am_admin_access_csr;
			end if; -- admin_access_csr%FOUND
			close admin_access_csr;
		end if; -- if p_admin_flag <> 'Y'
	end if; -- if lead_access_profile_value = 'F'
	close resource_access_csr;
   end if; --  if p_check_access_flag = 'N'
      --
      -- End of API body.
      --

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_view_access_flag: ' || x_view_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		    ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_viewLeadAccess;



procedure has_updateOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_updateOppurtunityAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_update_access_flag varchar2(1);
l_org_id NUMBER;
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is
	select	'X'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
	  and    a.team_leader_flag = 'Y'
          and   a.salesforce_id = p_identity_salesforce_id;

	cursor manager_access_csr(p_resource_id number) is

	 select	'X'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
	and 	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
             and sysdate between rm.start_date_active and nvl(rm.end_date_active, sysdate)
			 and ((rm.parent_resource_id = rm.resource_id
				and a.team_leader_flag = 'Y')
			       or (rm.parent_resource_id <> rm.resource_id))));

	cursor mgr_i_access_csr(p_resource_id number) is
        select	'X'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
         and    a.team_leader_flag = 'Y'
	and 	(EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			 and    rm.parent_resource_id = p_resource_id
             and sysdate between rm.start_date_active and nvl(rm.end_date_active, sysdate)
             ));

	cursor admin_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id
			 and ((rm.salesforce_id = p_identity_salesforce_id
				and a.team_leader_flag = 'Y')
			       or (rm.salesforce_id <> p_identity_salesforce_id)));

	cursor admin_i_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
        and              a.team_leader_flag = 'Y'
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);

	cursor am_mgr_access_csr(p_resource_id number) is
	select 'x'
	from as_leads opp, as_accesses_all a, as_rpt_managers_v rm
	where opp.customer_id = a.customer_id
	and a.salesforce_id = rm.resource_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_resource_id = p_resource_id
	and opp.lead_id = p_opportunity_id
    and sysdate between rm.start_date_active and nvl(rm.end_date_active, sysdate);

       cursor am_admin_access_csr is
	select 'x'
	from as_leads opp, as_accesses_all a, as_rpt_admins_v rm
	where opp.customer_id = a.customer_id
	and a.salesforce_id = rm.salesforce_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_sales_group_id = p_admin_group_id
	and opp.lead_id = p_opportunity_id;

	cursor find_lead_org is
	select org_id
	from as_leads_all
	where lead_id = p_opportunity_id;

	cursor c_org_access(p_org_id NUMBER) is
    select 'Y'
    from hr_operating_units hr
    where hr.organization_id = p_org_id
    and mo_global.check_access(hr.organization_id) = 'Y';

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_updateOpportunityAccess';

begin
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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_opportunity_id: ' || p_opportunity_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_admin_group_id: ' || p_admin_group_id);
	END IF;

      --
      -- API body
      --

	 -- Initialize access flag to 'N'
         x_update_access_flag := 'N';

  if p_check_access_flag = 'N'
  then
	x_update_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'
	-- PRM security
	open resource_access_csr;
	fetch resource_access_csr into l_tmp;
/*	if p_partner_cont_party_id is not null
		and  p_partner_cont_party_id <> FND_API.G_MISS_NUM
	then
		if (resource_access_csr%FOUND)
                then
			x_update_access_flag := 'Y';
			close resource_access_csr;
			return;
		end if;
	end if; */
/*	if p_person_id is null or p_person_id = fnd_api.g_miss_num
	then
		get_person_id(p_identity_salesforce_id, l_person_id);
	else
		l_person_id := p_person_id;
	end if;
	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'person id: ' || l_person_id);
*/
	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

	if l_access_profile_rec.opp_access_profile_value = 'F'
	then
		x_update_access_flag := 'Y';
     elsif l_access_profile_rec.opp_access_profile_value = 'O'
	then
         -- l_update_access_flag will hold value for x_update_access_flag, NULL means unknown
         l_update_access_flag := 'N';
         /* check org full access */
		open find_lead_org;
		fetch find_lead_org into l_org_id;
		if(find_lead_org%FOUND)then
           if l_org_id IS NULL then
                l_update_access_flag := 'Y'; -- Access allowed if org_id NULL
           else
                l_update_access_flag := NULL; -- Need to check for the org id
           end if;
        end if;
        close find_lead_org;

        -- Added for MOAC
        if l_update_access_flag IS NULL then
		    open c_org_access(l_org_id);
            fetch c_org_access into l_update_access_flag;
            if c_org_access%NOTFOUND then
                l_update_access_flag := 'N';
            end if;
            close c_org_access;
        end if;

		/* for bug 1613991 */
        if l_update_access_flag = 'N' and resource_access_csr%FOUND then
            l_update_access_flag := 'Y';
        end if;

		x_update_access_flag := l_update_access_flag;

	elsif resource_access_csr%FOUND
	then
		x_update_access_flag := 'Y';
	else
		if nvl(p_admin_flag,'N') <> 'Y'
		then
			if l_access_profile_rec.mgr_update_profile_value = 'U'
			then
				open manager_access_csr(p_identity_salesforce_id);
				fetch manager_access_csr into l_tmp;
				if manager_access_csr%FOUND
					-- First check if mgr's subordinate
					--   which are not 'AM'
				then
					x_update_access_flag := 'Y';
				else    -- if mgr's subordinate which are 'AM'
					open am_mgr_access_csr(p_identity_salesforce_id);
					fetch am_mgr_access_csr into l_tmp;
					if am_mgr_access_csr%FOUND
					then
						x_update_access_flag := 'Y';
					end if;
					close am_mgr_access_csr;
				end if; -- manager_access_csr%FOUND
				close manager_access_csr;
			elsif l_access_profile_rec.mgr_update_profile_value = 'I'
			then
				open mgr_i_access_csr(p_identity_salesforce_id);
				fetch mgr_i_access_csr into l_tmp;
				if mgr_i_access_csr%FOUND
				then
					x_update_access_flag := 'Y';
				end if;
				close mgr_i_access_csr;
			end if; -- l_access_profile_rec.mgr_update_profile_value = 'U'
		elsif l_access_profile_rec.admin_update_profile_value = 'U'
		then
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if admin_access_csr%FOUND
                        then
				x_update_access_flag := 'Y';
	                else
				open am_admin_access_csr;
				fetch am_admin_access_csr into l_tmp;
				if am_admin_access_csr%FOUND
				then
					x_update_access_flag := 'Y';
				end if;
				close am_admin_access_csr;
			end if; -- admin_access_csr%FOUND
			close admin_access_csr;
		elsif l_access_profile_rec.admin_update_profile_value = 'I'
	        then
			open admin_i_access_csr;
			fetch admin_i_access_csr into l_tmp;
			if admin_i_access_csr%FOUND
                        then
				x_update_access_flag := 'Y';
			end if;
			close admin_i_access_csr;
		end if; -- if p_admin_flag <> 'Y'
	end if;
	close resource_access_csr;
   end if; --  if p_check_access_flag = 'N'
      --
      -- End of API body.
      --

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_update_access_flag: ' || x_update_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		    ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_updateOpportunityAccess;

procedure has_viewOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	:= FND_API.G_FALSE
	,p_validation_level	IN NUMBER	:= FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN as_access_pub.access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag       IN VARCHAR2
	,p_identity_salesforce_id  IN NUMBER
	,p_partner_cont_party_id   IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_viewOppurtunityAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_tmp varchar2(1);
l_view_access_flag varchar2(1);
l_org_id number;
l_person_id number;
l_access_profile_rec AS_ACCESS_PUB.Access_Profile_Rec_Type;

	cursor resource_access_csr is
	select	'X'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
          and   a.salesforce_id = p_identity_salesforce_id;

	cursor manager_access_csr(p_resource_id number) is

	select	'X'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
	and 	EXISTS (select 'x'
			 from   as_rpt_managers_v rm
			where  a.salesforce_id = rm.resource_id
			and    rm.parent_resource_id = p_resource_id
            and sysdate between rm.start_date_active and nvl(rm.end_date_active, sysdate)
            );

	cursor admin_access_csr is
	select	'x'
	from 	as_accesses_all a
	where 	a.lead_id = p_opportunity_id
	and 	EXISTS (select 'x'
			 from   as_rpt_admins_v rm
			 where  a.salesforce_id = rm.salesforce_id
			 and    rm.parent_sales_group_id = p_admin_group_id);


	cursor am_mgr_access_csr(p_resource_id number) is
	select 'x'
	from as_leads opp, as_accesses_all a, as_rpt_managers_v rm
	where opp.customer_id = a.customer_id
	and a.salesforce_id = rm.resource_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_resource_id = p_resource_id
	and opp.lead_id = p_opportunity_id
    and sysdate between rm.start_date_active and nvl(rm.end_date_active, sysdate);

       cursor am_admin_access_csr is
	select 'x'
	from as_leads opp, as_accesses_all a, as_rpt_admins_v rm
	where opp.customer_id = a.customer_id
	and a.salesforce_id = rm.salesforce_id
	and a.salesforce_role_code = 'AM'
	and rm.parent_sales_group_id = p_admin_group_id
	and opp.lead_id = p_opportunity_id;

	cursor find_lead_org is
	select org_id
	from as_leads_all
	where lead_id = p_opportunity_id;

	cursor c_org_access(p_org_id NUMBER) is
    select 'Y'
    from hr_operating_units hr
    where hr.organization_id = p_org_id
    and mo_global.check_access(hr.organization_id) = 'Y';

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.acspv.has_viewOpportunityAccess';

begin
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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_opportunity_id: ' || p_opportunity_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'ident salesforce_id: ' || p_identity_salesforce_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_admin_group_id: ' || p_admin_group_id);
	END IF;

      --
      -- API body
      --

	 -- Initialize access flag to 'N'
         x_view_access_flag := 'N';

  if p_check_access_flag = 'N'
  then
	x_view_access_flag := 'Y';
  else -- if p_check_access_flag = 'Y'

	open resource_access_csr;
	fetch resource_access_csr into l_tmp;

	l_access_profile_rec := p_access_profile_rec;
	get_accessProfileValues(l_access_profile_rec);

	if l_access_profile_rec.opp_access_profile_value in ('F','P')
	then
		x_view_access_flag := 'Y';
        elsif l_access_profile_rec.opp_access_profile_value = 'O'
	then
         /* check org full access */
         -- l_view_access_flag will hold value for x_view_access_flag, NULL means unknown
         l_view_access_flag := 'N';
         /* check org full access */
		open find_lead_org;
		fetch find_lead_org into l_org_id;
		if(find_lead_org%FOUND)then
           if l_org_id IS NULL then
                l_view_access_flag := 'Y'; -- Access allowed if org_id NULL
           else
                l_view_access_flag := NULL; -- Need to check for the org id
           end if;
        end if;
        close find_lead_org;

        -- Added for MOAC
        if l_view_access_flag IS NULL then
		    open c_org_access(l_org_id);
            fetch c_org_access into l_view_access_flag;
            if c_org_access%NOTFOUND then
                l_view_access_flag := 'N';
            end if;
            close c_org_access;
        end if;

		/* for bug 1613991 */
        if l_view_access_flag = 'N' and resource_access_csr%FOUND then
            l_view_access_flag := 'Y';
        end if;

		x_view_access_flag := l_view_access_flag;
	elsif resource_access_csr%FOUND
	then
		x_view_access_flag := 'Y';
	else
		if nvl(p_admin_flag,'N') <> 'Y'
		then
			open manager_access_csr(p_identity_salesforce_id);
			fetch manager_access_csr into l_tmp;
			if manager_access_csr%FOUND
				-- First check if mgr's subordinate
				--   which are not 'AM'
			then
				x_view_access_flag := 'Y';
			else    -- if mgr's subordinate which are 'AM'
				open am_mgr_access_csr(p_identity_salesforce_id);
				fetch am_mgr_access_csr into l_tmp;
				if am_mgr_access_csr%FOUND
				then
					x_view_access_flag := 'Y';
				end if;
				close am_mgr_access_csr;
			end if; -- manager_access_csr%FOUND
			close manager_access_csr;

		else
			open admin_access_csr;
			fetch admin_access_csr into l_tmp;
			if admin_access_csr%FOUND
                        then
				x_view_access_flag := 'Y';
	                else
				open am_admin_access_csr;
				fetch am_admin_access_csr into l_tmp;
				if am_admin_access_csr%FOUND
				then
					x_view_access_flag := 'Y';
				end if;
				close am_admin_access_csr;
			end if; -- admin_access_csr%FOUND
			close admin_access_csr;
		end if; -- if p_admin_flag <> 'Y'
	end if; -- if l_access_profile_rec.opp_access_profile_value = 'F'
	close resource_access_csr;
   end if; --  if p_check_access_flag = 'N'
      --
      -- End of API body.
      --

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'x_view_access_flag: ' || x_view_access_flag);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		  , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
		    ,P_SQLCODE => SQLCODE
		   ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_viewOpportunityAccess;



END AS_ACCESS_PVT;

/
