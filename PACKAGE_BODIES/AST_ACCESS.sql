--------------------------------------------------------
--  DDL for Package Body AST_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_ACCESS" AS
/* $Header: astuaccb.pls 115.7 2004/02/18 10:54:57 rkumares ship $ */

  G_Debug  BOOLEAN := TRUE;

  PROCEDURE Log_Mesg
    (p_message IN VARCHAR2,
     p_date  IN  VARCHAR2 DEFAULT 'N') IS
  BEGIN
    IF G_Debug THEN
      AST_DEBUG_PUB.LogMessage(debug_msg  => p_message,
                               print_date => p_date);
    END IF;
  END; -- End procedure Log_Mesg

  PROCEDURE Initialize IS
  BEGIN
	G_ACCESS_REC_TYPE.Cust_Access_Profile_Value  := NVL(FND_PROFILE.VALUE('AS_CUST_ACCESS'),'F');
	G_ACCESS_REC_TYPE.Lead_Access_Profile_Value  := NVL(FND_PROFILE.VALUE('AS_LEAD_ACCESS'),'F');
    G_ACCESS_REC_TYPE.Opp_Access_Profile_Value   := NVL(FND_PROFILE.VALUE('AS_OPP_ACCESS'),'F');
    G_ACCESS_REC_TYPE.Mgr_Update_Profile_Value   := NVL(FND_PROFILE.VALUE('AS_MGR_UPDATE'),'R');
    G_ACCESS_REC_TYPE.Admin_Update_Profile_Value := NVL(FND_PROFILE.VALUE('AS_ADMIN_UPDATE'),'R');
  END;

  PROCEDURE Has_Create_LeadOppAccess
  ( p_admin_flag         VARCHAR2,
    p_opplead_ident      VARCHAR2,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    IF p_admin_flag = 'Y' THEN
      IF p_opplead_ident = 'O' THEN
        FND_MESSAGE.Set_Name('AST', 'AST_OPP_ADMIN_PREVLGE');
        FND_MSG_PUB.ADD;
      ELSE
        FND_MESSAGE.Set_Name('AST', 'AST_LEAD_ADMIN_PREVLGE');
        FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF (p_admin_flag =  'N') THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;
  END Has_Create_LeadOppAccess;

  PROCEDURE Has_UpdateLeadAccess
  ( p_sales_lead_id      NUMBER,
    p_admin_flag         VARCHAR2,
    p_admin_group_id     NUMBER,
    p_person_id          NUMBER,
    p_resource_id        NUMBER,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  ) IS
    l_accessFlag            VARCHAR2(1);
    l_true                  VARCHAR2(1) := FND_API.G_TRUE;
    l_false                 VARCHAR2(1) := FND_API.G_FALSE;
    l_validation_level_full NUMBER      := FND_API.G_VALID_LEVEL_FULL;
    l_msg_count	            NUMBER;
    l_msg_data	            VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_ret_stat_success      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    Initialize;
	AS_ACCESS_PUB.Has_UpdateLeadAccess
    ( p_api_version_Number	   => 2.0,
      p_init_msg_list		   => l_false,
      p_validation_level	   => l_validation_level_full,
      p_access_profile_rec	   => G_Access_Rec_Type,
      p_admin_flag		       => p_admin_flag,
      p_admin_group_id	       => p_admin_group_id,
      p_person_id		       => p_person_id,
      p_sales_lead_id		   => p_sales_lead_Id,
      p_check_access_flag	   => 'Y',
      p_identity_salesforce_id => p_resource_id,
      p_partner_cont_party_id  => NULL,
      x_return_status		   => l_return_status,
      x_msg_count		       => l_msg_count,
      x_msg_data		       => l_msg_data,
      x_update_access_flag	   => l_accessflag
    );

    IF l_accessflag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
	IF x_return_status <> l_ret_stat_success THEN
      FND_MESSAGE.Set_Name('AST', 'AST_LEAD_NOUPDATE_ACCESS');
      FND_MSG_PUB.ADD;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
	END IF;
  END Has_UpdateLeadAccess;

  PROCEDURE Has_LeadOwnerAccess
  ( p_sales_lead_id      NUMBER,
    p_admin_flag         VARCHAR2,
    p_admin_group_id     NUMBER,
    p_person_id          NUMBER,
    p_resource_id        NUMBER,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  ) IS
    l_accessFlag            VARCHAR2(1);
    l_true                  VARCHAR2(1) := FND_API.G_TRUE;
    l_false                 VARCHAR2(1) := FND_API.G_FALSE;
    l_validation_level_full NUMBER      := FND_API.G_VALID_LEVEL_FULL;
    l_msg_count	            NUMBER;
    l_msg_data	            VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_ret_stat_success      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    Initialize;
    l_accessFlag := nvl(fnd_profile.value('AS_ALLOW_CHANGE_LEAD_OWNER'),'N');
    if (l_accessFlag <> 'Y') then
	AS_ACCESS_PVT.has_LeadOwnerAccess
    ( p_api_version_Number	   => 2.0,
      p_init_msg_list		   => l_false,
      p_validation_level	   => l_validation_level_full,
      p_access_profile_rec	   => G_Access_Rec_Type,
      p_admin_flag		       => p_admin_flag,
      p_admin_group_id	       => p_admin_group_id,
      p_person_id		       => p_person_id,
      p_sales_lead_id		   => p_sales_lead_Id,
      p_check_access_flag	   => 'Y',
      p_identity_salesforce_id => p_resource_id,
      p_partner_cont_party_id  => NULL,
      x_return_status		   => l_return_status,
      x_msg_count		       => l_msg_count,
      x_msg_data		       => l_msg_data,
      x_update_access_flag	   => l_accessFlag
    );
    end if;
    IF l_accessflag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
	IF x_return_status <> l_ret_stat_success THEN
      FND_MESSAGE.Set_Name('AST', 'AST_NO_LEAD_OWNR_CHANGE_ACCESS');
      FND_MSG_PUB.ADD;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
	END IF;
  END Has_LeadOwnerAccess;

  PROCEDURE Has_UpdateOpportunityAccess
  ( p_lead_id      NUMBER,
    p_admin_flag         VARCHAR2,
    p_admin_group_id     NUMBER,
    p_person_id          NUMBER,
    p_resource_id        NUMBER,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2
  ) IS
    l_accessFlag            VARCHAR2(1);
    l_true                  VARCHAR2(1) := FND_API.G_TRUE;
    l_false                 VARCHAR2(1) := FND_API.G_FALSE;
    l_validation_level_full NUMBER      := FND_API.G_VALID_LEVEL_FULL;
    l_msg_count	            NUMBER;
    l_msg_data	            VARCHAR2(2000);
    l_return_status         VARCHAR2(1);
    l_ret_stat_success      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    Initialize;
    AS_ACCESS_PUB.has_updateOpportunityAccess
    ( p_api_version_Number	   => 2.0,
      p_init_msg_list		   => l_false,
      p_validation_level	   => l_validation_level_full,
      p_access_profile_rec	   => G_Access_Rec_Type,
      p_admin_flag		       => p_admin_flag,
      p_admin_group_id	       => p_admin_group_id,
      p_person_id		       => p_person_id,
      p_opportunity_id		   => p_lead_Id,
      p_check_access_flag	   => 'Y',
      p_identity_salesforce_id => p_resource_id,
      p_partner_cont_party_id  => NULL,
      x_return_status		   => l_return_status,
      x_msg_count		       => l_msg_count,
      x_msg_data		       => l_msg_data,
      x_update_access_flag	   => l_accessflag
    );

    IF l_accessflag <> 'Y' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
	IF x_return_status <> l_ret_stat_success THEN
      FND_MESSAGE.Set_Name('AST', 'AST_OPP_NOUPDATE_ACCESS');
      FND_MSG_PUB.ADD;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
	END IF;
  END Has_UpdateOpportunityAccess;

END AST_ACCESS; -- End package body AST_ACCESS

/
