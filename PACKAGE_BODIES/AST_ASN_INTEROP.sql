--------------------------------------------------------
--  DDL for Package Body AST_ASN_INTEROP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_ASN_INTEROP" as
/* $Header: astasnib.pls 120.2 2006/03/25 05:51:40 savadhan noship $ */
-- Start of Comments
-- Package name     : AST_ASN_INTEROP
-- Purpose          :
-- History          :
--    02-10-04 SUBABU  Created
-- End of Comments
--
G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'AST_ASN_INTEROP';
PROCEDURE RECONCILE_SALESCREDIT(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_lead_id			 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    ) IS

CURSOR CUR_SALESCREDIT IS
       SELECT salesforce_id,salesgroup_id,lead_line_id,person_id,credit_percent
         FROM as_sales_credits
	WHERE lead_id = p_lead_id;

l_prev_lead_line_id NUMBER;
l_salesforce_id     NUMBER;
l_sales_group_id    NUMBER;
l_person_id         NUMBER;
l_api_name          CONSTANT VARCHAR2(30) := 'RECONCILE_SALESCREDIT';
l_debug        BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT RECONCILE_SALESCREDIT_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        SELECT PERSON_ID,SALESFORCE_ID,SALES_GROUP_ID
          INTO l_person_id,l_salesforce_id,l_sales_group_id
	  FROM AS_ACCESSES_ALL
	 WHERE LEAD_ID    = p_lead_id
	   AND OWNER_FLAG = 'Y';
    EXCEPTION
        WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
             FND_MESSAGE.Set_Name('AST', 'AST_ASN_INTEROP_MUST_OWNER');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
    END;

    IF nvl(x_return_status,'N') <> 'E' THEN
    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Sales Force Id: ' || l_salesforce_id || ' Sales Group Id :' || l_sales_group_id ||' Person id :'||l_person_id );
    END IF;
		UPDATE  AS_SALES_CREDITS
		   SET	SALESFORCE_ID    =  l_salesforce_id,
			SALESGROUP_ID    =  l_sales_group_id,
			PERSON_ID        =  l_person_id,
			LAST_UPDATE_DATE = SYSDATE
		WHERE   LEAD_ID          =  P_LEAD_ID
		  AND   (SALESFORCE_ID   <>  l_salesforce_id
		  or   nvl(SALESGROUP_ID,0)   <>  nvl(l_sales_group_id,0))
		  AND  NVL(DEFAULTED_FROM_OWNER_FLAG,'N') = 'Y';

		UPDATE	AS_ACCESSES_ALL acc
		SET	object_version_number =  nvl(object_version_number,0) + 1,
			acc.team_leader_flag = 'Y'
		WHERE	acc.LEAD_ID = p_lead_id
		and	team_leader_flag = 'N'
		and	exists
		(
			select 	'x'
			from 	as_sales_credits
			where 	lead_id=acc.lead_id
			and   	salesforce_id=acc.salesforce_id
			and 	salesgroup_id =acc.sales_group_id
		);
    END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);
END RECONCILE_SALESCREDIT;

PROCEDURE CHECK_SALES_STAGE(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_sales_lead_id		 IN    NUMBER,
    X_sales_stage_id             OUT NOCOPY NUMBER,
    X_sales_methodology_id       OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2)
IS
 cursor c_lead(p_sales_lead_id NUMBER) is
  select SALES_METHODOLOGY_ID, SALES_STAGE_ID
  from as_sales_leads
  where sales_lead_id = p_sales_lead_id;

cursor c_sales_stage(p_sales_stage_id NUMBER) is
   select applicability
     from as_sales_stages_all_vl
    where sales_stage_id = p_sales_stage_id;

cursor c_first_sales_stage(p_sales_method_id NUMBER) is
    SELECT  stage.sales_stage_id
      FROM  as_sales_stages_all_vl stage, as_sales_meth_stage_map map1
     WHERE  stage.sales_stage_id = map1.sales_stage_id
       AND  nvl(stage.applicability,'BOTH') in ('OPPORTUNITY', 'BOTH')
       AND  nvl(stage.ENABLED_FLAG,'Y') = 'Y'
       AND  trunc(sysdate) between trunc(nvl(START_DATE_ACTIVE,sysdate))
       AND  trunc(nvl(END_DATE_ACTIVE,sysdate))
       AND  map1.sales_methodology_id  =  p_sales_method_id
  ORDER BY  STAGE_SEQUENCE;

  l_sales_methodology_id  NUMBER;
  l_sales_stage_id        NUMBER;
  l_applicability         VARCHAR2(100);
  l_api_name              CONSTANT VARCHAR2(40) := 'CHECK_SALES_STAGE';
  l_debug        BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_last_update_date date;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CHECK_SALES_STAGE_PVT;
      -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
    OPEN c_lead(p_sales_lead_id);
    FETCH c_lead INTO l_sales_methodology_id,l_sales_stage_id;
    CLOSE c_lead;

   IF l_sales_methodology_id IS NOT NULL  THEN
       IF l_sales_stage_id IS NOT NULL THEN
          OPEN c_sales_stage(l_sales_stage_id);
          FETCH c_sales_stage INTO l_applicability;
          CLOSE c_sales_stage;
	END IF;
	IF l_sales_stage_id  IS NULL or
	   nvl(l_applicability,'BOTH') NOT IN ('OPPORTUNITY', 'BOTH') THEN
              OPEN c_first_sales_stage(l_sales_methodology_id);
	      FETCH c_first_sales_stage INTO l_sales_stage_id;
	      IF c_first_sales_stage%NOTFOUND THEN
		     x_return_status :='E';
  	             CLOSE c_first_sales_stage;
		     FND_MESSAGE.Set_Name('AST', 'AST_STAGE_NOT_SETUP_FOR_METH');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
	      END IF;
	      CLOSE c_first_sales_stage;
	END IF;
     END IF;
    X_sales_stage_id       := l_sales_stage_id;
    X_sales_methodology_id := l_sales_methodology_id;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);
END CHECK_SALES_STAGE;

PROCEDURE RECONCILE_SALESMETHODOLOGY(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_lead_id		         IN    NUMBER,
    p_sales_stage_id             IN    NUMBER,
    p_sales_methodology_id       IN    NUMBER,
    P_Admin_Flag                 IN  VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN  NUMBER,
    P_Identity_Salesforce_Id     IN  NUMBER       := NULL,
    P_identity_salesgroup_id     IN  NUMBER       := NULL,
    P_profile_tbl                IN  AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    ) is


cursor c_opp(p_lead_id NUMBER) is
  select last_update_date
  from as_leads_all
  where lead_id = p_lead_id;

  l_api_name              CONSTANT VARCHAR2(40) := 'RECONCILE_SALESMETHODOLOGY';
  header_rec  		  AS_OPPORTUNITY_PUB.Header_Rec_Type;
  l_debug        BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_lead_id		  NUMBER;
  l_last_update_date date;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT RECONCILE_SALESMETHODOLOGY_PVT;
      -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN  c_opp(p_lead_id);
	FETCH c_opp into l_last_update_date;
	CLOSE c_opp;
    IF p_sales_methodology_id IS NOT NULL  THEN
	header_rec.sales_stage_id       := p_sales_stage_id;
	header_rec.Sales_Methodology_Id := p_sales_methodology_id;
    END IF;
	header_rec.lead_id	        := p_lead_id;
	header_rec.owner_salesforce_id  := P_Identity_Salesforce_Id;
	header_rec.owner_sales_group_id := P_identity_salesgroup_id;
	header_rec.last_update_date     := l_last_update_date;
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Before calling Update opp Header Lead id : ' || p_lead_id ||' Sales Force id :'|| P_Identity_Salesforce_Id ||
			      ' Sales Group Id :' || P_identity_salesgroup_id  ||
			      ' Sales Methodology id :'||p_sales_methodology_id );
    END IF;
		AS_OPPORTUNITY_PUB.Update_Opp_header
		(
		    p_api_version_number        => p_api_version_number,
		    p_init_msg_list             => p_init_msg_list,
		    p_commit                    => p_commit,
		    p_validation_level          => p_validation_level,
		    p_header_rec                => header_rec,
		    p_check_access_flag         => 'Y',
		    p_admin_flag                => p_admin_flag,
		    p_admin_group_id            => P_Admin_Group_Id,
		    p_identity_salesforce_id    => P_Identity_Salesforce_Id,
		    p_profile_tbl               => P_profile_tbl,
		    x_return_status             => x_return_status,
                    p_partner_cont_party_id     => NULL,
		    x_msg_count                 => x_msg_count,
		    x_msg_data                  => x_msg_data,
		    x_lead_id                   => l_lead_id
		);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           		RAISE FND_API.G_EXC_ERROR;
      		END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
      AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
	   P_API_NAME => L_API_NAME
	  ,P_PKG_NAME => G_PKG_NAME
	  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
	  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
	  ,X_MSG_COUNT => X_MSG_COUNT
	  ,X_MSG_DATA => X_MSG_DATA
	  ,X_RETURN_STATUS => X_RETURN_STATUS);
 END RECONCILE_SALESMETHODOLOGY;

END AST_ASN_INTEROP;

/
