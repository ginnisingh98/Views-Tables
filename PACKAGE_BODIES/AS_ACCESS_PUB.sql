--------------------------------------------------------
--  DDL for Package Body AS_ACCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_ACCESS_PUB" as
/* $Header: asxpacsb.pls 120.2 2005/08/10 04:22:58 appldev ship $ */
--
-- NAME
-- AS_ACCESS_PUB
--
-- HISTORY
--   8/28/98            JKORNBER     CREATED
--   9/18/98		AWU          UPDATED
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_ACCESS_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxpacsb.pls';

/*
procedure get_person_id(p_salesforce_id in varchar2,
			  x_person_id OUT NOCOPY varchar2)

is
	cursor get_person_id_csr is
	select employee_person_id
	from as_salesforce
	where salesforce_id = p_salesforce_id;

begin
	open get_person_id_csr;
	fetch get_person_id_csr into x_person_id;

	if (get_person_id_csr%NOTFOUND)
	then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
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
*/

Procedure Convert_Pub_Sales_Team_To_Pvt(pub_rec IN AS_ACCESS_PUB.SALES_TEAM_REC_TYPE,
                                        pvt_rec OUT NOCOPY AS_ACCESS_PVT.SALES_TEAM_REC_TYPE) IS
Begin

   pvt_rec.access_id := pub_rec.access_id;
   pvt_rec.freeze_flag := pub_rec.freeze_flag;
   pvt_rec.reassign_flag := pub_rec.reassign_flag;
   pvt_rec.team_leader_flag := pub_rec.team_leader_flag;
   pvt_rec.customer_id := pub_rec.customer_id;
   pvt_rec.address_id := pub_rec.address_id;
   pvt_rec.salesforce_id := pub_rec.salesforce_id;
   pvt_rec.partner_customer_id := pub_rec.partner_customer_id;
   pvt_rec.partner_address_id := pub_rec.partner_address_id;
   pvt_rec.lead_id := pub_rec.lead_id;
   pvt_rec.person_id := pub_rec.person_id;
   pvt_rec.freeze_date := pub_rec.freeze_date;
   pvt_rec.reassign_reason := pub_rec.reassign_reason;
   pvt_rec.reassign_request_date := pub_rec.reassign_request_date;
   pvt_rec.reassign_requested_person_id := pub_rec.reassign_requested_person_id;
   pvt_rec.downloadable_flag := pub_rec.downloadable_flag;
   pvt_rec.attribute_category := pub_rec.attribute_category;
   pvt_rec.attribute1 := pub_rec.attribute1;
   pvt_rec.attribute2 := pub_rec.attribute2;
   pvt_rec.attribute3 := pub_rec.attribute3;
   pvt_rec.attribute4 := pub_rec.attribute4;
   pvt_rec.attribute5 := pub_rec.attribute5;
   pvt_rec.attribute6 := pub_rec.attribute6;
   pvt_rec.attribute7 := pub_rec.attribute7;
   pvt_rec.attribute8 := pub_rec.attribute8;
   pvt_rec.attribute9 := pub_rec.attribute9;
   pvt_rec.attribute10 := pub_rec.attribute10;
   pvt_rec.attribute11 := pub_rec.attribute11;
   pvt_rec.attribute12 := pub_rec.attribute12;
   pvt_rec.attribute13 := pub_rec.attribute13;
   pvt_rec.attribute14 := pub_rec.attribute14;
   pvt_rec.attribute15 := pub_rec.attribute15;
   pvt_rec.last_update_date	:= pub_rec.last_update_date;
   pvt_rec.last_updated_by	:= pub_rec.last_updated_by;
   pvt_rec.creation_date	:= pub_rec.creation_date;
   pvt_rec.created_by		:= pub_rec.created_by;
   pvt_rec.last_update_login    := pub_rec.last_update_login;
   pvt_rec.sales_group_id := pub_rec.sales_group_id;
   pvt_rec.sales_lead_id := pub_rec.sales_lead_id;
   pvt_rec.salesforce_role_code := pub_rec.salesforce_role_code;
   pvt_rec.salesforce_relationship_code := pub_rec.salesforce_relationship_code;
   pvt_rec.partner_cont_party_id := pub_rec.partner_cont_party_id;
   pvt_rec.owner_flag := pub_rec.owner_flag;
   pvt_rec.created_by_tap_flag := pub_rec.created_by_tap_flag;
   pvt_rec.prm_keep_flag := pub_rec.prm_keep_flag;
   pvt_rec.contributor_flag := pub_rec.contributor_flag; -- Added for ASNB
End Convert_Pub_Sales_Team_To_Pvt;


PROCEDURE Create_SalesTeam
(       p_api_version_number            IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 DEFAULT  FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						DEFAULT  FND_API.G_VALID_LEVEL_FULL,
         p_access_profile_rec	IN access_profile_rec_type,
	p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_access_id                     OUT NOCOPY     NUMBER
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Create_SalesTeam';
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_pvt_sales_team_rec  AS_ACCESS_PVT.Sales_Team_Rec_Type;
  l_sales_team_rec sales_team_rec_type;
  l_access_id number;
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.Create_SalesTeam';
BEGIN
	SAVEPOINT CREATE_SALESTEAM_PUB;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
                        FND_MESSAGE.Set_Token('ROW', 'AS_ACCESS', TRUE);
                        FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	 -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list )
       THEN
          FND_MSG_PUB.initialize;
       END IF;

        --  Initialize API return status to success
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_sales_team_rec := p_sales_team_rec;
    Convert_Pub_Sales_Team_To_Pvt(l_sales_team_rec, l_pvt_sales_team_rec);
 --   get_person_id(l_sales_team_rec.salesforce_id, l_pvt_sales_team_rec.person_id);



       AS_ACCESS_PVT.Create_SalesTeam
       (    p_api_version_number    =>  2.0,
            p_commit                =>  p_commit,
	    p_validation_level      =>  p_validation_level,
	     p_access_profile_rec	  =>  p_access_profile_rec,
            p_check_access_flag     =>  p_check_access_flag,
	       p_admin_flag            =>  p_admin_flag,
	       p_admin_group_id        =>  p_admin_group_id,
	       p_identity_salesforce_id => p_identity_salesforce_id,
            p_sales_team_rec        =>  l_pvt_sales_team_rec,
            x_return_status         =>  x_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data,
            x_access_id             =>  x_access_id
       );


       IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
       ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
		RAISE fnd_api.g_exc_unexpected_error;
       END IF;

    -- Assign return access_id to rec type so that it can pass the created access_id
    -- to post User_Hook

	  l_pvt_sales_team_rec.access_id := x_access_id;


 EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END Create_SalesTeam;


PROCEDURE Update_SalesTeam
(       p_api_version_number              IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						DEFAULT  FND_API.G_VALID_LEVEL_FULL,
        p_access_profile_rec	IN access_profile_rec_type,
	p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        x_access_id                     OUT NOCOPY     NUMBER
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Update_SalesTeam';
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_pvt_sales_team_rec  AS_ACCESS_PVT.Sales_Team_Rec_Type;
  l_access_id number;
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.Update_SalesTeam';
BEGIN
	SAVEPOINT UPDATE_SALESTEAM_PUB;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
                        FND_MESSAGE.Set_Token('ROW', 'AS_ACCESS', TRUE);
                        FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	 -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list )
       THEN
          FND_MSG_PUB.initialize;
       END IF;

        --  Initialize API return status to success
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    Convert_Pub_Sales_Team_To_Pvt(p_sales_team_rec, l_pvt_sales_team_rec);
--    get_person_id(p_sales_team_rec.salesforce_id, l_pvt_sales_team_rec.person_id);

       AS_ACCESS_PVT.Update_SalesTeam
       (       p_api_version_number    =>  2.0,
	      p_commit                =>  p_commit,
            p_validation_level      =>  p_validation_level,
	    p_access_profile_rec	  =>  p_access_profile_rec,
            p_check_access_flag     =>  p_check_access_flag,
	       p_admin_flag            =>  p_admin_flag,
	       p_admin_group_id        =>  p_admin_group_id,
	       p_identity_salesforce_id => p_identity_salesforce_id,
            p_sales_team_rec        =>  l_pvt_sales_team_rec,
            x_return_status         =>  x_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data,
            x_access_id             =>  x_access_id
       );

       IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
       ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
		RAISE fnd_api.g_exc_unexpected_error;
       END IF;




      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END Update_SalesTeam;


-- Start of Comments
--
--      API name        : Delete_SalesTeam
--      Type            : Public
--      Function        : Delete sales team member records from the
--			  sales team (access table)
--
--      Pre-reqs        : Existing sales team record
--
--      Paramaeters     :
--      IN              :
--			p_api_version_number          	IN      NUMBER,
--		        p_init_msg_list                 IN      VARCHAR2
--		        p_commit                        IN      VARCHAR2
--    		        p_validation_level		IN	NUMBER
--      OUT             :
--                      x_return_status         OUT NOCOPY     VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY     NUMBER
--                      x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                              Initial Version
--                      Initial version         1.0
--
--      Notes:          API for delete either an customer or opportunity
--			sales team
--
--
-- End of Comments

PROCEDURE Delete_SalesTeam
(       p_api_version_number          	IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2
                                                DEFAULT  FND_API.G_FALSE,
	p_validation_level		IN	NUMBER
						DEFAULT  FND_API.G_VALID_LEVEL_FULL,
	p_access_profile_rec	IN access_profile_rec_type,
        p_check_access_flag             IN      VARCHAR2,
	   p_admin_flag                    IN      VARCHAR2,
	   p_admin_group_id                IN      NUMBER,
	   p_identity_salesforce_id        IN      NUMBER,
        p_sales_team_rec                IN      SALES_TEAM_REC_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
) is
 l_api_name            CONSTANT VARCHAR2(30) := 'Delete_SalesTeam';
 l_api_version_number  CONSTANT NUMBER       := 2.0;
 l_pvt_sales_team_rec  AS_ACCESS_PVT.Sales_Team_Rec_Type;
 l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
 l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.Delete_SalesTeam';

begin
	SAVEPOINT DELETE_SALESTEAM_PUB;
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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_ACCESS_PVT.delete_salesTeam');
      END IF;
                Convert_Pub_Sales_Team_To_Pvt(p_sales_team_rec, l_pvt_sales_team_rec);



       as_access_pvt.Delete_SalesTeam
		(P_Api_Version_Number         => 2.0,
		P_Init_Msg_List              => FND_API.G_FALSE,
		P_Commit                     => FND_API.G_FALSE,
		p_validation_level	     => P_Validation_Level,
		p_access_profile_rec	  =>  p_access_profile_rec,
		p_check_access_flag          => p_check_access_flag,
		 p_admin_flag                => p_admin_flag,
		p_admin_group_id             => p_admin_group_id,
		p_identity_salesforce_id     => p_identity_salesforce_id,
		p_sales_team_rec             => l_pvt_sales_team_rec,
		x_return_status              => x_return_status,
		x_msg_count                  => x_msg_count,
		x_msg_data                   => x_msg_data
		);
	 IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End delete_salesteam;

Procedure validate_accessProfiles
(	p_init_msg_list       IN       VARCHAR2 DEFAULT  FND_API.G_FALSE,
	p_access_profile_rec IN ACCESS_PROFILE_REC_TYPE,
	x_return_status       OUT NOCOPY      VARCHAR2,
        x_msg_count           OUT NOCOPY      NUMBER,
        x_msg_data            OUT NOCOPY      VARCHAR2
) is

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.validate_accessProfiles';

begin
	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Val Access Profile start');
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	 if p_access_profile_rec.cust_access_profile_value = 'T'
               and (p_access_profile_rec.lead_access_profile_value in ('F', 'P')
	or p_access_profile_rec.opp_access_profile_value in ('F', 'P'))
	then
 		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_INVALID_COMINATION');
			FND_MSG_PUB.ADD;
		END IF;
	end if;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Val Access Profile end');
	END IF;

	FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

end;



procedure has_viewCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
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
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_viewCustomerAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_viewCustomerAccess');
      END IF;


	as_access_pvt.has_viewCustomerAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_customer_id		=> p_customer_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_view_access_flag	=> x_view_access_flag);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_viewCustomerAccess ;

procedure has_updateCustomerAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
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
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_updateCustomerAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_updateCustomerAccess');
      END IF;


	as_access_pvt.has_updateCustomerAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_customer_id		=> p_customer_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_update_access_flag	=> x_update_access_flag);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end  has_updateCustomerAccess;

procedure has_updateLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
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
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_updateLeadAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_updateLeadAccess');
      END IF;


	as_access_pvt.has_updateLeadAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_sales_lead_id	=> p_sales_lead_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_update_access_flag	=> x_update_access_flag);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_updateLeadAccess;

procedure has_updateOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
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
l_api_name            CONSTANT VARCHAR2(30) := 'has_updateOpportunityAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_updateOpportunityAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_updateOpportunityAccess');
      END IF;


	as_access_pvt.has_updateOpportunityAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_opportunity_id	=> p_opportunity_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_update_access_flag	=> x_update_access_flag);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_updateOpportunityAccess;

procedure validate_id_combination(p_security_id	IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,x_valid_flag    OUT NOCOPY VARCHAR2) is

	cursor org_contact_exist_csr is
		select 'x'
		from hz_relationships
		where subject_id = p_person_party_id
		 and object_id = p_security_id
		 and SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		 AND   OBJECT_TABLE_NAME = 'HZ_PARTIES';

	cursor opp_contact_exist_csr is
		select 'x'
		from as_lead_contacts cont,
		     hz_relationships rel
		where cont.contact_party_id = rel.party_id
		  and rel.subject_id = p_person_party_id
		  and cont.lead_id = p_security_id
		and SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		 AND   OBJECT_TABLE_NAME = 'HZ_PARTIES';
	cursor lead_contact_exist_csr is
		select 'x'
		from as_sales_lead_contacts cont,
		     hz_relationships rel
		where cont.contact_party_id = rel.party_id
		  and rel.subject_id = p_person_party_id
		  and cont.sales_lead_id = p_security_id
		and SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		 AND   OBJECT_TABLE_NAME = 'HZ_PARTIES';
l_var varchar2(1);
begin
	x_valid_flag := 'Y';
	if p_security_type = 'ORGANIZATION'
	   and FND_PROFILE.Value('AS_CUST_ACCESS') <> 'F'
	then
		open org_contact_exist_csr;
		fetch  org_contact_exist_csr into l_var;
		if  org_contact_exist_csr%FOUND
		then
			x_valid_flag := 'Y';
		else
			x_valid_flag := 'N';

		end if;
		close org_contact_exist_csr;
	elsif  p_security_type = 'OPPORTUNITY'
		and FND_PROFILE.Value('AS_OPP_ACCESS') <> 'F'
	then
		open opp_contact_exist_csr;
		fetch  opp_contact_exist_csr into l_var;
		if  opp_contact_exist_csr%FOUND
		then
			x_valid_flag := 'Y';
		else
			x_valid_flag := 'N';

		end if;
		close opp_contact_exist_csr;
	elsif  p_security_type = 'LEAD'
		and FND_PROFILE.Value('AS_LEAD_ACCESS') <> 'F'
	then
		open lead_contact_exist_csr;
		fetch  lead_contact_exist_csr into l_var;
		if  lead_contact_exist_csr%FOUND
		then
			x_valid_flag := 'Y';
		else
			x_valid_flag := 'N';

		end if;
		close lead_contact_exist_csr;
	elsif p_security_type is NULL -- for consumer, no validation needed
	then
		x_valid_flag := 'Y';
	end if;
end validate_id_combination;

/*
has_updatePersonAccess:
p_security_id is the id which has relationship to the p_person_party_id.
For example, to check access for contact person(1000) of opportunity (2222),
you need to pass in p_security_id = 2222, p_security_type = 'OPPORTUNITY'
and p_person_party_id = 1000
values allowed for p_security_id are org party_id, opportunity_id,sales_lead_id
and null.
p_security_type allowed are 'ORGANIZATION', 'OPPORTUNITY','LEAD' and null
p_person_party_id is person's party id. This id is required to check person's
update access. To check consumer access, you can pass in null for
p_security_id and p_security_type */
procedure has_updatePersonAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_security_id		IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_update_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_updatePersonAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_valid_flag varchar2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_updatePersonAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_security_id: ' || p_security_id);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_security_type: ' || p_security_type);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_person_party_id: ' || p_person_party_id);
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_update_access_flag := 'N';
	 validate_id_combination(p_security_id => p_security_id
				,p_security_type => p_security_type
				,p_person_party_id => p_person_party_id
				,x_valid_flag   => l_valid_flag);
	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'valid id flag: ' || l_valid_flag);
	END IF;
	if l_valid_flag = 'N'
	then
		x_update_access_flag := 'N';
	else
		if p_security_type = 'ORGANIZATION'
		then
			as_access_pvt.has_updateCustomerAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_customer_id   	=> p_security_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_update_access_flag	=> x_update_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		elsif p_security_type = 'OPPORTUNITY'
		then
			as_access_pvt.has_updateOpportunityAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_opportunity_id   	=> p_security_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_update_access_flag	=> x_update_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		elsif p_security_type = 'LEAD'
		then
			as_access_pvt.has_updateLeadAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_sales_lead_id   	=> p_security_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_update_access_flag	=> x_update_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		elsif p_security_type is null and p_security_id is null
		then
			as_access_pvt.has_updateCustomerAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_customer_id   	=> p_person_party_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_update_access_flag	=> x_update_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
	       END IF; -- if p_security_type = 'ORGANIZATION'
	end if; --if l_valid_flag = 'N'

      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_updatePersonAccess;

procedure has_viewPersonAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_security_id		IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_view_access_flag	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_viewPersonAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_valid_flag varchar2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_viewPersonAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_security_id: ' || p_security_id);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_security_type: ' || p_security_type);
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'p_person_party_id: ' || p_person_party_id);
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_view_access_flag := 'N';
	 validate_id_combination(p_security_id => p_security_id
				,p_security_type => p_security_type
				,p_person_party_id => p_person_party_id
				,x_valid_flag   => l_valid_flag);
	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'valid id flag: ' || l_valid_flag);
	END IF;

	if l_valid_flag = 'N'
	then
		x_view_access_flag := 'N';
	else
		if p_security_type = 'ORGANIZATION'
		then
			as_access_pvt.has_viewCustomerAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_customer_id   	=> p_security_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_view_access_flag	=> x_view_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		elsif p_security_type = 'OPPORTUNITY'
		then
			as_access_pvt.has_viewOpportunityAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_opportunity_id   	=> p_security_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_view_access_flag	=> x_view_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		elsif p_security_type = 'LEAD'
		then
			as_access_pvt.has_viewLeadAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_sales_lead_id   	=> p_security_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_view_access_flag	=> x_view_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		elsif p_security_type is null and p_security_id is null
		then
			as_access_pvt.has_viewCustomerAccess
			(p_api_version_number	=> 2.0
			,p_init_msg_list        => FND_API.G_FALSE
			,p_validation_level	=> p_validation_level
			,p_access_profile_rec	=> p_access_profile_rec
			,p_admin_flag		=> p_admin_flag
			,p_admin_group_id	=> p_admin_group_id
			,p_person_id		=> p_person_id
			,p_customer_id   	=> p_person_party_id
			,p_check_access_flag    => p_check_access_flag
			,p_identity_salesforce_id =>p_identity_salesforce_id
			,p_partner_cont_party_id  =>p_partner_cont_party_id
			,x_return_status	  =>x_return_status
			,x_msg_count		=> x_msg_count
			,x_msg_data		=> x_msg_data
			,x_view_access_flag	=> x_view_access_flag);

			IF x_return_status = FND_API.G_RET_STS_ERROR then
				raise FND_API.G_EXC_ERROR;
			elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
	       END IF; -- if p_security_type = 'ORGANIZATION'
	end if; --if l_valid_flag = 'N'

      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_viewPersonAccess;


procedure has_viewLeadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
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
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_viewLeadAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_viewLeadAccess');
      END IF;


	as_access_pvt.has_viewLeadAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_sales_lead_id	=> p_sales_lead_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_view_access_flag	=> x_view_access_flag);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_viewLeadAccess;

procedure has_viewOpportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
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
l_api_name            CONSTANT VARCHAR2(30) := 'has_viewOpportunityAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_viewOpportunityAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_viewOpportunityAccess');
      END IF;


	as_access_pvt.has_viewOpportunityAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_opportunity_id	=> p_opportunity_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_view_access_flag	=> x_view_access_flag);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end has_viewOpportunityAccess;

/*
 This API is used for checking if login user has access for the pass in
organization party id. x_access_privilege might return one of the following
three values: 'N'(no access), 'R'(read only access) and 'F'(read/update access)
*/

procedure has_organizationAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_customer_id		IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_access_privilege	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_organizationAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_view_access_flag varchar2(1);
l_update_access_flag varchar2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_organizationAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_viewCustomerAccess');
      END IF;

	x_access_privilege := 'N';
	as_access_pvt.has_viewCustomerAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_customer_id		=> p_customer_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_view_access_flag	=> l_view_access_flag);

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	if l_view_access_flag = 'Y'
	then
		x_access_privilege := 'R';
		as_access_pvt.has_updateCustomerAccess
		(p_api_version_number	=> 2.0
		,p_init_msg_list        => FND_API.G_FALSE
		,p_validation_level	=> p_validation_level
		,p_access_profile_rec	=> p_access_profile_rec
		,p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_customer_id		=> p_customer_id
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id =>p_identity_salesforce_id
		,p_partner_cont_party_id  =>p_partner_cont_party_id
		,x_return_status	  =>x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag);

		IF x_return_status = FND_API.G_RET_STS_ERROR then
			raise FND_API.G_EXC_ERROR;
		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		if l_update_access_flag = 'Y'
		then
			x_access_privilege := 'F';
		end if;
	end if; -- l_view_access_flag = 'Y'

      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_organizationAccess ;

procedure has_opportunityAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_opportunity_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_access_privilege	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_opportunityAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_view_access_flag varchar2(1);
l_update_access_flag varchar2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_opportunityAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_viewCustomerAccess');
      END IF;

	x_access_privilege := 'N';
	as_access_pvt.has_viewOpportunityAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_opportunity_id	=> p_opportunity_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_view_access_flag	=> l_view_access_flag);

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	if l_view_access_flag = 'Y'
	then
		x_access_privilege := 'R';
		as_access_pvt.has_updateOpportunityAccess
		(p_api_version_number	=> 2.0
		,p_init_msg_list        => FND_API.G_FALSE
		,p_validation_level	=> p_validation_level
		,p_access_profile_rec	=> p_access_profile_rec
		,p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_opportunity_id	=> p_opportunity_id
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id =>p_identity_salesforce_id
		,p_partner_cont_party_id  =>p_partner_cont_party_id
		,x_return_status	  =>x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag);

		IF x_return_status = FND_API.G_RET_STS_ERROR then
			raise FND_API.G_EXC_ERROR;
		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		if l_update_access_flag = 'Y'
		then
			x_access_privilege := 'F';
		end if;
	end if; -- l_view_access_flag = 'Y'

      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_opportunityAccess ;

procedure has_leadAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_sales_lead_id	IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_access_privilege	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_leadAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_view_access_flag varchar2(1);
l_update_access_flag varchar2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_leadAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling as_access_pvt.has_viewCustomerAccess');
      END IF;

	x_access_privilege := 'N';
	as_access_pvt.has_viewLeadAccess
	(p_api_version_number	=> 2.0
	,p_init_msg_list        => FND_API.G_FALSE
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> p_access_profile_rec
	,p_admin_flag		=> p_admin_flag
	,p_admin_group_id	=> p_admin_group_id
	,p_person_id		=> p_person_id
	,p_sales_lead_id	=> p_sales_lead_id
	,p_check_access_flag    => p_check_access_flag
	,p_identity_salesforce_id =>p_identity_salesforce_id
	,p_partner_cont_party_id  =>p_partner_cont_party_id
	,x_return_status	  =>x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_view_access_flag	=> l_view_access_flag);

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	if l_view_access_flag = 'Y'
	then
		x_access_privilege := 'R';
		as_access_pvt.has_updateLeadAccess
		(p_api_version_number	=> 2.0
		,p_init_msg_list        => FND_API.G_FALSE
		,p_validation_level	=> p_validation_level
		,p_access_profile_rec	=> p_access_profile_rec
		,p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_sales_lead_id	=> p_sales_lead_id
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id =>p_identity_salesforce_id
		,p_partner_cont_party_id  =>p_partner_cont_party_id
		,x_return_status	  =>x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag);

		IF x_return_status = FND_API.G_RET_STS_ERROR then
			raise FND_API.G_EXC_ERROR;
		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		if l_update_access_flag = 'Y'
		then
			x_access_privilege := 'F';
		end if;
	end if; -- l_view_access_flag = 'Y'

      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_leadAccess ;

procedure has_personAccess
(	p_api_version_number	IN NUMBER
	,p_init_msg_list        IN VARCHAR2	DEFAULT  FND_API.G_FALSE
	,p_validation_level	IN NUMBER	DEFAULT  FND_API.G_VALID_LEVEL_FULL
	,p_access_profile_rec	IN access_profile_rec_type
	,p_admin_flag		IN VARCHAR2
	,p_admin_group_id	IN NUMBER
	,p_person_id		IN NUMBER
	,p_security_id		IN NUMBER
        ,p_security_type        IN VARCHAR2
        ,p_person_party_id      IN NUMBER
	,p_check_access_flag      IN VARCHAR2
	,p_identity_salesforce_id IN NUMBER
	,p_partner_cont_party_id  IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,x_access_privilege	OUT NOCOPY VARCHAR2
) is
l_api_name            CONSTANT VARCHAR2(30) := 'has_personAccess';
l_api_version_number  CONSTANT NUMBER       := 2.0;
l_view_access_flag varchar2(1);
l_update_access_flag varchar2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.acpub.has_personAccess';

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
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	x_access_privilege := 'N';
	as_access_pub.has_viewPersonAccess
		(p_api_version_number	=> 2.0
		,p_init_msg_list        => FND_API.G_FALSE
		,p_validation_level	=> p_validation_level
		,p_access_profile_rec	=> p_access_profile_rec
		,p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_security_id		=> p_security_id
		,p_security_type        => p_security_type
		,p_person_party_id      => p_person_party_id
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id =>p_identity_salesforce_id
		,p_partner_cont_party_id  =>p_partner_cont_party_id
		,x_return_status	  =>x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_view_access_flag	=> l_view_access_flag);

		IF x_return_status = FND_API.G_RET_STS_ERROR then
			raise FND_API.G_EXC_ERROR;
		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	if l_view_access_flag = 'Y'
	then
		x_access_privilege := 'R';
		as_access_pub.has_updatePersonAccess
		(p_api_version_number	=> 2.0
		,p_init_msg_list        => FND_API.G_FALSE
		,p_validation_level	=> p_validation_level
		,p_access_profile_rec	=> p_access_profile_rec
		,p_admin_flag		=> p_admin_flag
		,p_admin_group_id	=> p_admin_group_id
		,p_person_id		=> p_person_id
		,p_security_id		=> p_security_id
		,p_security_type        => p_security_type
		,p_person_party_id      => p_person_party_id
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id =>p_identity_salesforce_id
		,p_partner_cont_party_id  =>p_partner_cont_party_id
		,x_return_status	  =>x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag);

		IF x_return_status = FND_API.G_RET_STS_ERROR then
			raise FND_API.G_EXC_ERROR;
		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		if l_update_access_flag = 'Y'
		then
			x_access_privilege := 'F';
		end if;
	end if; -- l_view_access_flag = 'Y'

      --
      -- End of API body.
      --

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
		 , P_ROLLBACK_FLAG  => 'N'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


end has_personAccess ;

END AS_ACCESS_PUB;

/
