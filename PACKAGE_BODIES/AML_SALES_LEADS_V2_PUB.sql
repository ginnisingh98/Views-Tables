--------------------------------------------------------
--  DDL for Package Body AML_SALES_LEADS_V2_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_SALES_LEADS_V2_PUB" as
/* $Header: amlpaslb.pls 120.2 2005/11/07 16:37:28 solin noship $ */
-- Start of Comments
-- Package name     : AML_SALES_LEADS_V2_PUB
-- Purpose          : Sales Leads Management
-- NOTE             : This is atomic public API to create lead.
-- History
--     08/27/2000 AANJARIA  Created.
--
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEADS_V2_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlpaslb.pls';


-- *********************************************************************
--  Procedure  : Create_sales_lead
--  Description: Atomic procedure to create lead and associated entities
-- *********************************************************************


PROCEDURE Create_sales_lead (
    P_Api_Version_Number     IN  NUMBER,
    P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN  VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN  VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Salesgroup_Id          IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN  AS_UTILITY_PUB.Profile_Tbl_Type
                                 := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                 := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    P_SALES_LEAD_LINE_Tbl    IN  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_type
                                 := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_Tbl,
    P_SALES_LEAD_CONTACT_Tbl IN  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type
                                 := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_CONTACT_Tbl,
    P_Lead_note              IN  VARCHAR2 DEFAULT NULL,
    P_Note_type              IN  VARCHAR2 DEFAULT NULL,
    X_SALES_LEAD_ID           OUT NOCOPY NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_type,
    X_SALES_LEAD_CNT_OUT_Tbl  OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type,
    X_note_id                 OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
IS

    l_api_name                CONSTANT VARCHAR2(30) := 'Create_sales_lead';
    l_api_version_number      CONSTANT NUMBER       := 2.0;
    l_salesforce_id           NUMBER;
    l_group_id                NUMBER;
    l_party_type              VARCHAR2(30);
    l_org_contact_id          NUMBER;

    l_classification_tbl      as_interest_pub.interest_tbl_type;
    l_interest_use_code       VARCHAR2(30);
    l_interest_out_id         NUMBER;
    l_sales_lead_id           NUMBER;

    l_note_context_rec        jtf_notes_pub.jtf_note_contexts_rec_type;
    l_note_context_rec_tbl    jtf_notes_pub.jtf_note_contexts_tbl_type;

    CURSOR C_get_slaesforce(c_user_id NUMBER)
    IS
    SELECT JS.RESOURCE_ID
    FROM   JTF_RS_RESOURCE_EXTNS JS
    WHERE  JS.USER_ID = C_User_Id;

    CURSOR c_get_group_id (c_resource_id NUMBER)
    IS
     SELECT MAX(grp.group_id) salesgroup_id
     FROM   JTF_RS_GROUP_MEMBERS mem,
            JTF_RS_ROLE_RELATIONS rrel,
            JTF_RS_ROLES_B role,
            JTF_RS_GROUP_USAGES u,
            JTF_RS_GROUPS_B grp
     WHERE  mem.group_member_id     = rrel.role_resource_id AND
            rrel.role_resource_type = 'RS_GROUP_MEMBER' AND
            rrel.role_id            = role.role_id AND
            role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM') AND
            mem.delete_flag         <> 'Y' AND
            rrel.delete_flag        <> 'Y' AND
            sysdate BETWEEN rrel.start_date_active AND
               NVL(rrel.end_date_active, SYSDATE) AND
            mem.group_id            = u.group_id AND
            u.usage                 in ('SALES','PRM') AND
            mem.group_id            = grp.group_id AND
            sysdate BETWEEN grp.start_date_active AND
               NVL(grp.end_date_active,sysdate) AND
            mem.resource_id         = c_resource_id;

      CURSOR C_get_party_type (p_customer_id IN NUMBER)
      IS
        SELECT party_type
	FROM   hz_parties
	WHERE  party_id = p_customer_id;

      CURSOR C_get_org_contact_id (p_customer_id IN NUMBER, p_contact_id IN NUMBER)
      IS
        SELECT org_contact_id
	FROM   hz_org_contacts hzoc, hz_relationships hzr
        WHERE  hzoc.party_relationship_id = hzr.relationship_id
        AND    subject_id = p_customer_id
        AND    object_id  = p_contact_id;

BEGIN
      SAVEPOINT Create_sales_lead_pub;

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_salesforce_id := P_Identity_Salesforce_Id;

      IF l_salesforce_id IS NULL OR l_salesforce_id = FND_API.G_MISS_NUM
      THEN
         OPEN  C_Get_SLAESFORCE(fnd_global.user_id);
         FETCH C_Get_SLAESFORCE
         INTO  l_salesforce_id;
         CLOSE C_Get_SLAESFORCE;

         If (l_salesforce_id is null) then
            l_salesforce_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
         End if;
      END IF;

      IF P_Salesgroup_Id = FND_API.G_MISS_NUM
      THEN
          OPEN c_get_group_id (l_salesforce_id);
          FETCH c_get_group_id INTO l_group_id;
          CLOSE c_get_group_id;
      ELSE
          l_group_id := P_Salesgroup_Id;
      END IF;

-- Create Sales Lead

      AS_SALES_LEADS_PVT.create_sales_lead(
            p_api_version_number         => 2.0,
            p_init_msg_list              => P_Init_Msg_List,
            p_commit                     => P_Commit,
            p_validation_level           => P_Validation_Level,
            p_check_access_flag          => P_Check_Access_Flag,
            p_admin_flag                 => P_Admin_Flag,
            p_admin_group_id             => P_Admin_Group_Id,
            p_identity_salesforce_id     => l_salesforce_id,
            p_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            p_sales_lead_rec             => P_SALES_LEAD_Rec,
            p_sales_lead_line_tbl        => p_sales_lead_line_tbl,
            p_sales_lead_contact_tbl     => p_sales_lead_contact_tbl,
            x_sales_lead_id              => l_sales_lead_id,
            x_return_status              => x_return_status,
            x_msg_count                  => x_MSG_COUNT,
            x_msg_data                   => x_msg_data,
            x_sales_lead_line_out_tbl    => x_sales_lead_line_out_tbl,
            x_sales_lead_cnt_out_tbl     => x_sales_lead_cnt_out_tbl);


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Sales lead id '
				   ||to_char(l_sales_lead_id)||'created');

      --dbms_output.put_line('sales lead id '||to_char(l_sales_lead_id));

-- Create Interest
/* --Commenting out till we get patch from sales for AS_INTEREST_PUB API
      -- Get party type
      OPEN C_get_party_type(p_sales_lead_rec.customer_id);
      FETCH C_get_party_type INTO l_party_type;
      CLOSE C_get_party_type;

      IF p_sales_lead_rec.primary_cnt_person_party_id IS NOT NULL THEN
      -- Get org_contact_id
      OPEN C_get_org_contact_id (p_sales_lead_rec.customer_id, p_sales_lead_rec.primary_cnt_person_party_id);
      FETCH C_get_org_contact_id into l_org_contact_id;
      CLOSE C_get_org_contact_id;
      END IF;

      For i IN 1..p_sales_lead_line_tbl.count Loop
        l_classification_tbl(i).customer_id := p_sales_lead_rec.customer_id;
        l_classification_tbl(i).address_id  := p_sales_lead_rec.address_id;
        l_classification_tbl(i).contact_id  := l_org_contact_id;
        l_classification_tbl(i).category_id  := p_sales_lead_line_tbl(i).category_id;
--        l_classification_tbl(i).interest_type_id := p_sales_lead_line_tbl(i).interest_type_id;
--        l_classification_tbl(i).primary_interest_code_id := p_sales_lead_line_tbl(i).primary_interest_code_id;
--        l_classification_tbl(i).secondary_interest_code_id := p_sales_lead_line_tbl(i).secondary_interest_code_id;

        IF l_party_type = 'PERSON' THEN
            l_interest_use_code := 'CONTACT_INTEREST';
        ELSIF l_party_type = 'ORGANIZATION' THEN
            l_interest_use_code := 'COMPANY_CLASSIFICATION' ;
        END IF;

        AS_INTEREST_PUB.Create_Interest(
            p_api_version_number     => 2.0 ,
            p_init_msg_list          => FND_API.G_FALSE,
            p_Commit                 => FND_API.G_FALSE,
            p_interest_rec           => l_classification_tbl(i),
            p_customer_id            => p_sales_lead_rec.customer_id,
            p_address_id             => p_sales_lead_rec.address_id,
            p_contact_id             => l_org_contact_id,
            p_lead_id                => null,
            p_interest_use_code      => l_interest_use_code,
            p_check_access_flag      => 'N',
            p_admin_flag             => P_Admin_Flag,
            p_admin_group_id         => P_Admin_Group_Id,
            p_identity_salesforce_id => l_salesforce_id,
            p_access_profile_rec     => null,
            p_return_status          => x_return_status,
            p_msg_count              => x_msg_count,
            p_msg_data               => x_msg_data,
            p_interest_out_id        => l_interest_out_id) ;
      End Loop;


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --dbms_output.put_line('Interest created');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Interest created');
*/

-- Create Lead Note and Context


        If ((l_sales_lead_id is not null)
	    AND (p_sales_lead_rec.customer_id is not null)
            AND ((p_lead_note is not null) OR (p_lead_note  <> FND_API.G_MISS_CHAR))
           )
        THEN
	--Assign values to context rec type
	l_note_context_rec.NOTE_CONTEXT_TYPE    := 'LEAD';
	l_note_context_rec.NOTE_CONTEXT_TYPE_ID := l_sales_lead_id;
	l_note_context_rec.LAST_UPDATE_DATE     := SYSDATE;
	l_note_context_rec.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
	l_note_context_rec.CREATION_DATE        := SYSDATE;
	l_note_context_rec.CREATED_BY           := FND_GLOBAL.USER_ID;
	l_note_context_rec.LAST_UPDATE_LOGIN    := FND_GLOBAL.USER_ID;

	l_note_context_rec_tbl(1) := l_note_context_rec;

	l_note_context_rec.NOTE_CONTEXT_TYPE    := 'PARTY_ORGANIZATION';
	l_note_context_rec.NOTE_CONTEXT_TYPE_ID := p_sales_lead_rec.customer_id;
	l_note_context_rec.LAST_UPDATE_DATE     := SYSDATE;
	l_note_context_rec.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
	l_note_context_rec.CREATION_DATE        := SYSDATE;
	l_note_context_rec.CREATED_BY           := FND_GLOBAL.USER_ID;
	l_note_context_rec.LAST_UPDATE_LOGIN    := FND_GLOBAL.USER_ID;

	l_note_context_rec_tbl(2) := l_note_context_rec;

	-- Call Jtf_notes_pub.create_note()

	JTF_NOTES_PUB.Create_Note (
	p_parent_note_id        => NULL
	, p_jtf_note_id         => NULL
	, p_api_version         => 1.0
	, p_init_msg_list       => 'T'
	, p_commit              => 'F'
	, p_validation_level    => 100
	, x_return_status       => x_return_status
	, x_msg_count           => x_msg_count
	, x_msg_data            => x_msg_data
	, p_org_id              => NULL
	, p_source_object_id    => l_sales_lead_id
	, p_source_object_code  => 'LEAD'
	, p_notes               => p_lead_note
	, p_notes_detail        => NULL --EMPTY_CLOB()
	, p_note_status         => NULL
	, p_entered_by          => FND_GLOBAL.USER_ID
	, p_entered_date        => SYSDATE
	, x_jtf_note_id         => x_note_id
	, p_last_update_date    => SYSDATE
	, p_last_updated_by     => FND_GLOBAL.USER_ID
	, p_creation_date       => SYSDATE
	, p_created_by          => FND_GLOBAL.USER_ID
	, p_last_update_login   => FND_GLOBAL.USER_ID
	, p_attribute1          => NULL
	, p_attribute2          => NULL
	, p_attribute3          => NULL
	, p_attribute4          => NULL
	, p_attribute5          => NULL
	, p_attribute6          => NULL
	, p_attribute7          => NULL
	, p_attribute8          => NULL
	, p_attribute9          => NULL
	, p_attribute10         => NULL
	, p_attribute11         => NULL
	, p_attribute12         => NULL
	, p_attribute13         => NULL
	, p_attribute14         => NULL
	, p_attribute15         => NULL
	, p_context             => NULL
	, p_note_type           => NVL(p_note_type,'AS_USER')
	, p_jtf_note_contexts_tab => l_note_context_rec_tbl
	);

      --dbms_output.put_line (x_return_status);
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Note id '
				   ||to_char(x_note_id)||'created');

      --dbms_output.put_line('note id '||to_char(x_note_id));

      END IF; --if lead_note is not null

-- Process Lead after creation
      AS_SALES_LEAD_ENGINE_PVT.Lead_Process_After_Create(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            p_Admin_Flag                 => p_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => l_salesforce_id,
            P_Salesgroup_Id              => l_group_Id,
            P_Sales_Lead_Id              => l_sales_lead_id,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --dbms_output.put_line('lead processed.');
      x_sales_lead_id := l_sales_lead_id;
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Lead Processing completed ');

      --
      -- End of API body
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
	/*
	  WHEN others THEN
	  dbms_output.put_line('EXCEPTION RAISED: -->');
	  FOR l_msg_index IN 1..x_msg_count LOOP
	     fnd_message.set_encoded(fnd_msg_pub.get(l_msg_index));
	     dbms_output.put_line(fnd_message.get);
	  END LOOP;
	*/

	  WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  END Create_sales_lead;

END AML_SALES_LEADS_V2_PUB;

/
