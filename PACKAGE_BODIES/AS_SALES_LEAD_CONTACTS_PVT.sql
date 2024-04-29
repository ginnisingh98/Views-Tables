--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_CONTACTS_PVT" as
/* $Header: asxvslcb.pls 120.0.12010000.2 2010/02/15 10:17:17 sariff ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_CONTACTS_PVT
-- Purpose          : Sales Leads Contacts
-- NOTE             :
-- History          :
--      04/09/2001 FFANG  Created.
--
-- END of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_CONTACTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvslcb.pls';


-- *************************
--   Validation Procedures
-- *************************
--
-- Item level validation procedures
--

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Validate_CONTACT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID		 IN   NUMBER,
    P_CONTACT_ID                 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    -- solin, 02/01/2001, replace view AS_PARTY_ORG_CONTACTS_V with HZ tables
/*
    CURSOR 	C_CONTACT_ID_Exists(c_contact_id NUMBER) IS
        SELECT 'X'
        FROM HZ_CONTACT_POINTS CONT_POINT,
             HZ_PARTIES PARTY,
             HZ_PARTIES PARTY2,
             HZ_PARTY_RELATIONSHIPS REL,
             HZ_ORG_CONTACTS ORG_CONT
        WHERE ORG_CONT.PARTY_RELATIONSHIP_ID = REL.PARTY_RELATIONSHIP_ID
          AND REL.OBJECT_ID = PARTY.PARTY_ID
          AND REL.PARTY_ID = PARTY2.PARTY_ID
          AND CONT_POINT.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
          AND CONT_POINT.OWNER_TABLE_ID(+) = PARTY.PARTY_ID
          AND CONT_POINT.CONTACT_POINT_TYPE(+) = 'EMAIL'
          AND ORG_CONT.ORG_CONTACT_ID = c_contact_id
          AND PARTY.PARTY_ID = P_CUSTOMER_ID;
*/

    -- ffang 100401, bug 2031450, HZ_RELATIONSHIPS should be used to replace
    -- HZ_PARTY_RELATIONSHIPS
    CURSOR  C_CONTACT_ID_Exists(c_contact_id NUMBER) IS
        SELECT 'X'
        FROM -- HZ_CONTACT_POINTS CONT_POINT,
             HZ_PARTIES PARTY,
             HZ_PARTIES PARTY2,
             HZ_RELATIONSHIPS REL,
             HZ_ORG_CONTACTS ORG_CONT
        WHERE ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
          AND REL.OBJECT_ID = PARTY.PARTY_ID AND REL.PARTY_ID = PARTY2.PARTY_ID
          -- AND CONT_POINT.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
          -- AND CONT_POINT.OWNER_TABLE_ID(+) = PARTY.PARTY_ID
          -- AND CONT_POINT.CONTACT_POINT_TYPE(+) = 'EMAIL'
          AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
          AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
          AND ORG_CONT.ORG_CONTACT_ID = c_contact_id
          AND PARTY.PARTY_ID = P_CUSTOMER_ID   --;
          -- ffang 100901, bug 2039435, add checking on status
          AND PARTY.STATUS IN ('A', 'I');


--     FROM AS_PARTY_ORG_CONTACTS_V
--     WHERE contact_id = c_contact_id
--     AND   customer_id = P_CUSTOMER_ID;

  l_val  VARCHAR2(1);

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CONTACT_ID is NOT NULL) and
         (p_CONTACT_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_CONTACT_ID_Exists (p_CONTACT_ID);
          FETCH C_CONTACT_ID_Exists into l_val;
          IF C_CONTACT_ID_Exists%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Private API: CONTACT_ID is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'CONTACT_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  p_CONTACT_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_CONTACT_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


END Validate_CONTACT_ID;


PROCEDURE Validate_CONTACT_PARTY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID		 IN   NUMBER,
    P_CONTACT_PARTY_ID           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR  C_CONTACT_PARTY_ID_Exists (c_CONTACT_PARTY_ID NUMBER) IS
        Select 'X'
        from hz_relationships
        where party_id = c_CONTACT_PARTY_ID
          and object_id = P_CUSTOMER_ID
          and subject_table_name = 'HZ_PARTIES'
          and object_table_name = 'HZ_PARTIES'   --;
          --and relationship_code = 'CONTACT_OF';
          -- ffang 100901, bug 2039435, add checking on status
          AND STATUS IN ('A', 'I');

        /* ffang 083001, use hz_relationships instead of hz_party_relationships
        SELECT 'X'
        FROM  HZ_PARTY_RELATIONSHIPS
        WHERE object_id = P_CUSTOMER_ID
          AND party_id = c_CONTACT_PARTY_ID;
        */

    l_val   VARCHAR2(1);
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- ffang 092000 for bug 1406761
      -- validate NOT NULL column
      IF (p_CONTACT_PARTY_ID is NULL)
      THEN
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API: Violate NOT NULL(CONTACT_PARTY_ID)');
          END IF;

          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'CONTACT_PARTY_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE   -- p_CONTACT_PARTY_ID is NOT NULL

          -- Calling from Create APIs, CONTACT_PARTY_ID can not be G_MISS_NUM
          IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE) and
             (p_CONTACT_PARTY_ID = FND_API.G_MISS_NUM)
          THEN
              -- IF (AS_DEBUG_ERROR_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                   'Private API: CONTACT_PARTY_ID is missing'); END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_CONTACT_PARTY_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;

          -- If CONTACT_PARTY_ID <> G_MISS_NUM, check if it is valid
          ELSIF (p_CONTACT_PARTY_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_CONTACT_PARTY_ID_Exists (p_CONTACT_PARTY_ID);
              FETCH C_CONTACT_PARTY_ID_Exists into l_val;
              IF C_CONTACT_PARTY_ID_Exists%NOTFOUND
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN

                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'Private API: CONTACT_PARTY_ID is invalid');
                  END IF;

                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'COLUMN',
                      p_token1_value  => 'CONTACT_PARTY_ID',
                      p_token2        => 'VALUE',
                      p_token2_value  =>  p_CONTACT_PARTY_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              -- ffang 092800: Forgot to close cursor
              CLOSE C_CONTACT_PARTY_ID_Exists;
              -- end ffang 092800
          END IF;
      END IF;
      -- end ffang 092000 for bug 1406761

      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CONTACT_PARTY_ID;


PROCEDURE Validate_PHONE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CONTACT_ID		 IN   NUMBER,
    P_CONTACT_PARTY_ID		 IN   NUMBER,
    P_PHONE_ID                   IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    -- ffang012501, use HZ_CONTACT_POINTS instead of AS_PARTY_PHONES_V
    CURSOR 	C_PHONE_ID_Exists(c_phone_id NUMBER) IS
        SELECT 'X'
        FROM HZ_CONTACT_POINTS
        WHERE contact_point_id = c_phone_id
          AND owner_table_name = 'HZ_PARTIES'
          AND owner_table_id = P_CONTACT_PARTY_ID
          AND CONTACT_POINT_TYPE IN ( 'PHONE', 'FAX')    --;
          -- ffang 100901, bug 2039435, add checking on status
          AND STATUS IN ('A', 'I');

    l_val  VARCHAR2(1);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PHONE_ID is NOT NULL) and
         (p_PHONE_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_PHONE_ID_Exists (p_PHONE_ID);
          FETCH C_PHONE_ID_Exists into l_val;
          IF C_PHONE_ID_Exists%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Private API: PHONE_ID is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'PHONE_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  p_PHONE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PHONE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PHONE_ID;


PROCEDURE Validate_CONTACT_ROLE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CONTACT_ROLE_CODE          IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and ENABLED_FLAG = 'Y';

    l_val VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate contact role code'); END IF;

      -- Validate contact role code
      IF (p_contact_role_code is NOT NULL
          AND p_contact_role_code <> FND_API.G_MISS_CHAR)
      THEN
        OPEN C_Lookup_Exists ( p_contact_role_code, 'LEAD_CONTACT_ROLE');
        FETCH C_Lookup_Exists into l_val;

        IF C_Lookup_Exists%NOTFOUND
        THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'CONTACT_ROLE_CODE',
              p_token2        => 'VALUE',
              p_token2_value  =>  p_CONTACT_ROLE_CODE );
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Lookup_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_CONTACT_ROLE_CODE;


--
-- Record Level Validation
--


--
--  Inter-record level validation
--


--
--  validation procedures
--

PROCEDURE Validate_sales_lead_contact(
    P_Init_Msg_List          IN  VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level       IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode        IN  VARCHAR2,
    P_SALES_LEAD_CONTACT_Rec IN  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Rec_Type,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name   CONSTANT VARCHAR2(30) := 'Validate_sales_lead_contact';
    l_Return_Status       VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
      THEN
          -- Perform item level validation
          AS_SALES_LEADS_PVT.Validate_CUSTOMER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_ID            => P_SALES_LEAD_CONTACT_Rec.CUSTOMER_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          -- ffang 081001, bug 1930170, if no addres_id, then skip validation
          IF (P_SALES_LEAD_CONTACT_Rec.ADDRESS_ID IS NOT NULL and
              P_SALES_LEAD_CONTACT_Rec.ADDRESS_ID <> FND_API.G_MISS_NUM)
          THEN
              AS_SALES_LEADS_PVT.Validate_ADDRESS_ID(
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_validation_mode    => p_validation_mode,
                  p_CUSTOMER_ID        => P_SALES_LEAD_CONTACT_Rec.CUSTOMER_ID,
                  p_ADDRESS_ID         => P_SALES_LEAD_CONTACT_Rec.ADDRESS_ID,
                  x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  -- raise FND_API.G_EXC_ERROR;
              END IF;
          END IF;

          Validate_CONTACT_PARTY_ID(
              p_init_msg_list      => FND_API.G_FALSE,
              p_validation_mode    => p_validation_mode,
	         p_CUSTOMER_ID        => P_SALES_LEAD_CONTACT_Rec.CUSTOMER_ID,
              p_CONTACT_PARTY_ID   => P_SALES_LEAD_CONTACT_Rec.CONTACT_PARTY_ID,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CONTACT_ID(
              p_init_msg_list      => FND_API.G_FALSE,
              p_validation_mode    => p_validation_mode,
	         p_CUSTOMER_ID        => P_SALES_LEAD_CONTACT_Rec.CUSTOMER_ID,
              p_CONTACT_ID         => P_SALES_LEAD_CONTACT_Rec.CONTACT_ID,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PHONE_ID(
              p_init_msg_list      => FND_API.G_FALSE,
              p_validation_mode    => p_validation_mode,
              p_CONTACT_ID         => P_SALES_LEAD_CONTACT_Rec.CONTACT_ID,
              p_CONTACT_PARTY_ID   => P_SALES_LEAD_CONTACT_Rec.CONTACT_PARTY_ID,
              p_PHONE_ID           => P_SALES_LEAD_CONTACT_Rec.PHONE_ID,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CONTACT_ROLE_CODE(
              p_init_msg_list     => FND_API.G_FALSE,
              p_validation_mode   => p_validation_mode,
              p_CONTACT_ROLE_CODE => P_SALES_LEAD_CONTACT_Rec.CONTACT_ROLE_CODE,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          AS_SALES_LEADS_PVT.Validate_FLAGS(
              p_init_msg_list     => FND_API.G_FALSE,
              p_validation_mode   => p_validation_mode,
              p_Flag_Value        =>
                                  P_SALES_LEAD_CONTACT_Rec.PRIMARY_CONTACT_FLAG,
              p_Flag_Type         => 'PRIMARY_CONTACT_FLAG',
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- FFANG 112700 For bug 1512008, instead of erroring out once a invalid
	 -- column was found, raise the exception after all validation procedures
	 -- have been gone through.
	 x_return_status := l_return_status;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
      END IF;
	 -- END FFANG 112700

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;
END Validate_sales_lead_contact;


-- ***************************
--   Sales Lead Contact APIs
-- ***************************

PROCEDURE Create_sales_lead_contacts(
    P_Api_Version_Number     IN  NUMBER,
    P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN  VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN  VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN  NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN  AS_UTILITY_PUB.Profile_Tbl_Type
                           := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl IN  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type
                           := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_CONTACT_Tbl,
    P_SALES_LEAD_ID          IN  NUMBER,
    X_SALES_LEAD_CNT_OUT_Tbl OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    )

 IS
 -- for bug 2098158 ckapoor - change cursor to retrieve the phone and party id of contact also
    Cursor  C_Get_Primary_Contact ( c_SALES_LEAD_ID NUMBER ) IS
       SELECT  slc.LEAD_CONTACT_ID, slc.CONTACT_PARTY_ID, slc.PHONE_ID, r.subject_id
       FROM    as_sales_lead_contacts slc, hz_relationships r
       WHERE   slc.sales_lead_id = c_SALES_LEAD_ID
               and slc.enabled_flag = 'Y'
               and slc.primary_contact_flag = 'Y'
               and r.party_id = slc.contact_party_id
               and r.object_id = slc.customer_id;

-- Bug 3357273 - MASS1R10:11510:FUNC:CONTACT NOT MARKED'PRIMARY'WHEN LEAD HAS MORE THAN 1 CONTACT

      CURSOR C_Sales_Lead_Id_Exists ( c_SALES_LEAD_ID NUMBER ) IS
      SELECT count(1)
      FROM  as_sales_lead_contacts
      WHERE sales_lead_id = c_SALES_LEAD_ID;


    l_val	NUMBER; -- data type changed to Number for bug 9378908

-- end bug 3357273


    l_api_name           CONSTANT VARCHAR2(30) := 'Create_sales_lead_contacts';
    l_api_version_number CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_SALES_LEAD_CONTACT_rec    AS_SALES_LEADS_PUB.sales_lead_contact_rec_type;
    l_lead_contact_id           NUMBER;
    l_update_access_flag        VARCHAR2(1);
    l_member_role               VARCHAR2(5);
    l_member_access             VARCHAR2(5);
    l_contact_party_id          NUMBER;
    l_cnt_person_party_id	NUMBER;
    l_contact_phone_id		NUMBER;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT CREATE_SALES_LEAD_CONTACTS_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' Start');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

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
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                p_token1        => 'PROFILE',
                p_token1_value  => 'USER_ID');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_validation_level = fnd_api.g_valid_level_full)
    THEN
        AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
            p_api_version_number => 2.0
           ,p_init_msg_list      => p_init_msg_list
           ,p_salesforce_id      => P_Identity_Salesforce_Id
           ,p_admin_group_id     => p_admin_group_id
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,x_sales_member_rec   => l_identity_sales_member_rec);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


-- Bug 3357273 - MASS1R10:11510:FUNC:CONTACT NOT MARKED'PRIMARY'WHEN LEAD HAS MORE THAN 1 CONTACT

  OPEN  C_Sales_Lead_Id_Exists(p_sales_lead_id) ;
        FETCH C_Sales_Lead_Id_Exists into l_val;
  CLOSE C_Sales_Lead_Id_Exists ;

-- end bug 3357273


   FOR l_curr_row IN 1..p_sales_lead_contact_tbl.count LOOP
        x_sales_lead_cnt_out_tbl(l_curr_row).return_status
                                              := FND_API.G_RET_STS_SUCCESS;

        -- Progress Message
        --
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
            FND_MESSAGE.Set_Token ('ROW', 'AS_SALES_LEAD_CONTACT', TRUE);
            FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
            FND_MSG_PUB.Add;
        END IF;

        l_sales_lead_contact_rec := p_sales_lead_contact_tbl(l_curr_row);
        l_sales_lead_contact_rec.sales_lead_id := p_sales_lead_id;


      IF (l_val=0)
        THEN
        -- 11.5.10 ckapoor Primary contact changes for Rivendell

--	   if (  (p_sales_lead_contact_tbl.count = 1) and (l_curr_row=1)) then
   	   if (l_curr_row=1) then
		if (l_sales_lead_contact_rec.primary_contact_flag <> 'Y')
	        then

	           IF (AS_DEBUG_LOW_ON) THEN

			AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			                                     'CK:force setting primary contact flag');
		   END IF;


			l_sales_lead_contact_rec.primary_contact_flag := 'Y';
	        end if;
	   end if;
     end if; --        IF (l_val=0)

	-- 11.5.10 end ckapoor




        -- Debug message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Validate_contact');
        END IF;

        -- Invoke validation procedures
        Validate_sales_lead_contact(
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
            P_SALES_LEAD_CONTACT_Rec  =>  l_SALES_LEAD_CONTACT_Rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            x_sales_lead_cnt_out_tbl(l_curr_row).return_status:=x_return_status;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_SALES_LEAD_CONTACT_rec.ENABLED_FLAG IS NULL OR
           l_SALES_LEAD_CONTACT_rec.ENABLED_FLAG = FND_API.G_MISS_CHAR
        THEN
            l_SALES_LEAD_CONTACT_rec.ENABLED_FLAG := 'Y';
        END IF;

        IF(P_Check_Access_Flag = 'Y') THEN
            -- Call Get_Access_Profiles to get access_profile_rec
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Get_Access_Profiles');
            END IF;

            AS_SALES_LEADS_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_sales_lead_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Has_updateLeadAccess');

            END IF;

            AS_ACCESS_PUB.Has_updateLeadAccess(
                p_api_version_number  => 2.0
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_validation_level    => p_validation_level
               ,p_access_profile_rec  => l_access_profile_rec
               ,p_admin_flag          => p_admin_flag
               ,p_admin_group_id      => p_admin_group_id
               ,p_person_id   => l_identity_sales_member_rec.employee_person_id
               ,p_sales_lead_id       => l_sales_lead_contact_rec.sales_lead_id
               ,p_check_access_flag   => p_check_access_flag  -- should be 'Y'
               ,p_identity_salesforce_id => p_identity_salesforce_id
               ,p_partner_cont_party_id => NULL
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ,x_update_access_flag  => l_update_access_flag);

            IF l_update_access_flag <> 'Y' THEN
                IF (AS_DEBUG_ERROR_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                             'API_NO_CREATE_PRIVILEGE');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        -- IF the record has primary_contact_flag set to 'Y' and there is
        -- another primary contact record for the same sales_lead_id existed
        -- then update the existing primary contact record's
        -- primary_contact_flag to 'N'
        IF l_SALES_LEAD_CONTACT_Rec.primary_contact_flag = 'Y'
        THEN
            OPEN C_Get_Primary_Contact(p_SALES_LEAD_ID);
            FETCH C_Get_Primary_Contact into l_lead_contact_id,
                                             l_contact_party_id, l_contact_phone_id, l_cnt_person_party_id;

            IF C_Get_Primary_Contact%FOUND THEN
                UPDATE AS_SALES_LEAD_CONTACTS
                SET primary_contact_flag = 'N'
                WHERE lead_contact_id = l_lead_contact_id;
            END IF;
            CLOSE C_Get_Primary_Contact;
        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling CONTACTS_Insert_Row');
        END IF;

        l_lead_contact_id := l_sales_lead_contact_rec.lead_contact_id;

        -- Invoke table handler
        AS_SALES_LEAD_CONTACTS_PKG.SALES_LEAD_CONTACTS_Insert_Row(
             px_LEAD_CONTACT_ID  => l_LEAD_CONTACT_ID,
             p_SALES_LEAD_ID  => l_SALES_LEAD_CONTACT_rec.SALES_LEAD_ID,
             p_CONTACT_ID  => l_SALES_LEAD_CONTACT_rec.CONTACT_ID,
             p_CONTACT_PARTY_ID => l_SALES_LEAD_CONTACT_rec.CONTACT_PARTY_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
             p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
             p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
             p_PROGRAM_UPDATE_DATE  => SYSDATE,
             p_ENABLED_FLAG  => l_SALES_LEAD_CONTACT_rec.ENABLED_FLAG,
             p_RANK  => l_SALES_LEAD_CONTACT_rec.RANK,
             p_CUSTOMER_ID  => l_SALES_LEAD_CONTACT_rec.CUSTOMER_ID,
             p_ADDRESS_ID  => l_SALES_LEAD_CONTACT_rec.ADDRESS_ID,
             p_PHONE_ID  => l_SALES_LEAD_CONTACT_rec.PHONE_ID,
             p_CONTACT_ROLE_CODE => l_SALES_LEAD_CONTACT_rec.CONTACT_ROLE_CODE,
             p_PRIMARY_CONTACT_FLAG  =>
                                l_SALES_LEAD_CONTACT_rec.PRIMARY_CONTACT_FLAG,
             p_ATTRIBUTE_CATEGORY =>l_SALES_LEAD_CONTACT_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE13,
             p_ATTRIBUTE14  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE14,
             p_ATTRIBUTE15  => l_SALES_LEAD_CONTACT_rec.ATTRIBUTE15);
          -- p_SECURITY_GROUP_ID => l_SALES_LEAD_CONTACT_rec.SECURITY_GROUP_ID);

        x_sales_lead_cnt_out_tbl(l_curr_row).lead_contact_id
                                                         := l_lead_contact_id;
        x_sales_lead_cnt_out_tbl(l_curr_row).return_status := x_return_status;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END LOOP;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Updating the header table for last updated');
    END IF;

      UPDATE as_sales_leads
      SET last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.USER_ID,
          last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE sales_lead_id = p_sales_lead_id;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Calling Check_primary_contact');
    END IF;

    -- Check IF there is only one primary contact
    Check_primary_contact (
         P_Api_Version_Number         => 2.0
        ,P_Init_Msg_List              => FND_API.G_FALSE
        ,P_Commit                     => FND_API.G_FALSE
        ,p_validation_level           => P_Validation_Level
        ,P_Check_Access_Flag          => P_Check_Access_Flag
        ,P_Admin_Flag                 => P_Admin_Flag
        ,P_Admin_Group_Id             => P_Admin_Group_Id
        ,P_identity_salesforce_id     => P_identity_salesforce_id
        ,P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl
        ,P_SALES_LEAD_ID              => P_SALES_LEAD_ID
        ,X_Return_Status              => x_Return_Status
        ,X_Msg_Count                  => X_Msg_Count
        ,X_Msg_Data                   => X_Msg_Data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ffang 082801, for bug 1939730, denorm primary contact's
    -- contact_party_id to as_sales_leads.primary_contact_party_id
    -- ckapoor 011102 , for bug 2098158, denorm the party id of the
    -- primary contact (not the relationship) to as_sales_leads.primary_cnt_person_party_id
    -- also denorm the phone_id of primary contact to as_sales_leads.primary_contact_phone_id

    OPEN C_Get_Primary_Contact(p_SALES_LEAD_ID);
    FETCH C_Get_Primary_Contact into l_lead_contact_id, l_contact_party_id, l_contact_phone_id, l_cnt_person_party_id;
    IF C_Get_Primary_Contact%FOUND THEN
        UPDATE AS_SALES_LEADS
        SET PRIMARY_CONTACT_PARTY_ID = l_contact_party_id,
            PRIMARY_CONTACT_PHONE_ID = l_contact_phone_id,
            PRIMARY_CNT_PERSON_PARTY_ID = l_cnt_person_party_id
        WHERE sales_lead_id = p_SALES_LEAD_ID;
    ELSE   -- no primary contact found
        UPDATE AS_SALES_LEADS
        SET PRIMARY_CONTACT_PARTY_ID = NULL,
        PRIMARY_CONTACT_PHONE_ID = NULL,
        PRIMARY_CNT_PERSON_PARTY_ID = NULL
        WHERE sales_lead_id = p_SALES_LEAD_ID;
    END IF;

    CLOSE C_Get_Primary_Contact;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Primary Contact for '||p_SALES_LEAD_ID||':'
                                 ||l_contact_party_id);
    END IF;

    --
    -- END of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' End');
    END IF;


    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

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
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END Create_sales_lead_contacts;


PROCEDURE Update_sales_lead_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id     IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl     IN
                    AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl     OUT
                    AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    Cursor C_Get_contact(c_LEAD_CONTACT_ID Number) IS
        Select LAST_UPDATE_DATE
        From  AS_SALES_LEAD_CONTACTS
        Where lead_contact_id = c_LEAD_CONTACT_ID
        For Update NOWAIT;

    l_api_name           CONSTANT VARCHAR2(30) := 'Update_sales_lead_contacts';
    l_api_version_number CONSTANT NUMBER   := 2.0;
    -- Local Variables
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_tar_SALES_LEAD_CONTACT_rec AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Rec_Type;
    l_sales_lead_id             NUMBER;
    l_last_update_date          DATE;
    l_update_access_flag        VARCHAR2(1);
    l_member_role               VARCHAR2(5);
    l_member_access             VARCHAR2(5);
    l_contact_party_id          NUMBER;
    l_contact_phone_id		NUMBER;
    l_cnt_person_party_id	NUMBER;



     -- for bug 2098158 ckapoor - change cursor to retrieve the phone and party id of contact also
    Cursor  C_Get_Pri_Contact ( c_SALES_LEAD_ID NUMBER ) IS
       SELECT  slc.CONTACT_PARTY_ID, slc.PHONE_ID, r.subject_id
       FROM    as_sales_lead_contacts slc, hz_relationships r
       WHERE   slc.sales_lead_id = c_SALES_LEAD_ID
               and slc.enabled_flag = 'Y'
               and slc.primary_contact_flag = 'Y'
               and r.party_id = slc.contact_party_id
               and r.object_id = slc.customer_id;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_SALES_LEAD_CONTACTS_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' Start');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    --

    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************
    IF FND_GLOBAL.User_Id IS NULL
    THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                p_token1        => 'PROFILE',
                p_token1_value  => 'USER_ID');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_validation_level = fnd_api.g_valid_level_full)
    THEN
        AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
            p_api_version_number => 2.0
           ,p_init_msg_list      => p_init_msg_list
           ,p_salesforce_id      => P_Identity_Salesforce_Id
           ,p_admin_group_id     => p_admin_group_id
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,x_sales_member_rec   => l_identity_sales_member_rec);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR l_curr_row IN 1..p_sales_lead_contact_tbl.count LOOP
        x_sales_lead_cnt_out_tbl(l_curr_row).return_status
                                               := FND_API.G_RET_STS_SUCCESS;

        -- Progress Message
        --
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
            FND_MESSAGE.Set_Token ('ROW', 'SALES_LEAD_CONTACT', TRUE);
            FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
            FND_MSG_PUB.Add;
        END IF;

        l_tar_sales_lead_contact_rec := p_sales_lead_contact_tbl(l_curr_row);

        IF (AS_DEBUG_LOW_ON) THEN



        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'lead_contact_id: ' || l_tar_sales_lead_contact_rec.lead_contact_id);

        END IF;

        -- Debug message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Validate_sales_lead');
        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Open C_Get_sales_lead_contact');
        END IF;

        Open C_Get_contact(l_tar_SALES_LEAD_CONTACT_rec.LEAD_CONTACT_ID);
        Fetch C_Get_contact into l_last_update_date;

        IF ( C_Get_contact%NOTFOUND) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
              FND_MESSAGE.Set_Token ('INFO', 'SALES_LEAD_CONTACT', FALSE);
              FND_MSG_PUB.Add;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Close C_Get_sales_lead_contact');
        END IF;
        Close C_Get_contact;

        -- Check Whether record has been changed by someone else
        IF (l_tar_SALES_LEAD_CONTACT_rec.last_update_date is NULL or
           l_tar_SALES_LEAD_CONTACT_rec.last_update_date = FND_API.G_MISS_Date )
        THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'LAST_UPDATE_DATE', FALSE);
                FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
        END IF;

        IF (l_tar_SALES_LEAD_CONTACT_rec.last_update_date <> l_last_update_date)
        THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'SALES_LEAD_CONTACT', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

        -- Debug message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                    'Calling Validate_sales_lead_contact');
        END IF;

        -- Invoke validation procedures
        Validate_sales_lead_contact(
                    p_init_msg_list    => FND_API.G_FALSE,
                    p_validation_level => p_validation_level,
                    p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
                    P_SALES_LEAD_CONTACT_Rec  =>  l_tar_SALES_LEAD_CONTACT_Rec,
                    x_return_status    => x_return_status,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            x_sales_lead_cnt_out_tbl(l_curr_row).return_status:=x_return_status;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF(P_Check_Access_Flag = 'Y') THEN
            -- Call Get_Access_Profiles to get access_profile_rec
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Get_Access_Profiles');
            END IF;

            AS_SALES_LEADS_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_sales_lead_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Has_updateLeadAccess');

            END IF;

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
             'sales_lead_id: ' || l_tar_sales_lead_contact_rec.sales_lead_id);

            END IF;
            AS_ACCESS_PUB.Has_updateLeadAccess(
                p_api_version_number  => 2.0
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_validation_level    => p_validation_level
               ,p_access_profile_rec  => l_access_profile_rec
               ,p_admin_flag          => p_admin_flag
               ,p_admin_group_id      => p_admin_group_id
               ,p_person_id   => l_identity_sales_member_rec.employee_person_id
               ,p_sales_lead_id    => l_tar_sales_lead_contact_rec.sales_lead_id
               ,p_check_access_flag   => p_check_access_flag  -- should be 'Y'
               ,p_identity_salesforce_id => p_identity_salesforce_id
               ,p_partner_cont_party_id => NULL
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ,x_update_access_flag  => l_update_access_flag);

            IF l_update_access_flag <> 'Y' THEN
                IF (AS_DEBUG_ERROR_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                             'API_NO_CREATE_PRIVILEGE');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        -- Check whether  the record is marked as primary contact; IF yes,
        -- update the primary contact already in the table
        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Updating existing primary cont');
        END IF;

        IF l_tar_SALES_LEAD_CONTACT_Rec.primary_contact_flag = 'Y'
        THEN
            UPDATE as_sales_lead_contacts
            SET  primary_contact_flag  = 'N'
            WHERE sales_lead_id = l_tar_SALES_LEAD_CONTACT_Rec.sales_lead_id
                  and PRIMARY_CONTACT_FLAG = 'Y'
                  and enabled_flag = 'Y';
        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling CONTACTS_Update_Row');
        END IF;
        -- Invoke table handler
        AS_SALES_LEAD_CONTACTS_PKG.SALES_LEAD_CONTACTS_Update_Row(
            p_LEAD_CONTACT_ID  => l_tar_SALES_LEAD_CONTACT_rec.LEAD_CONTACT_ID,
            p_SALES_LEAD_ID  => l_tar_SALES_LEAD_CONTACT_rec.SALES_LEAD_ID,
            p_CONTACT_ID  => l_tar_SALES_LEAD_CONTACT_rec.CONTACT_ID,
            p_CONTACT_PARTY_ID => l_tar_SALES_LEAD_CONTACT_rec.CONTACT_PARTY_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_CREATION_DATE  => l_tar_SALES_LEAD_CONTACT_rec.CREATION_DATE,
            p_CREATED_BY  => l_tar_SALES_LEAD_CONTACT_rec.CREATED_BY,
            p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
            p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
            p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
            p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
            p_PROGRAM_UPDATE_DATE  => SYSDATE,
            p_ENABLED_FLAG  => NVL(l_tar_SALES_LEAD_CONTACT_rec.ENABLED_FLAG,
                                   'Y'),
            p_RANK  => l_tar_SALES_LEAD_CONTACT_rec.RANK,
            p_CUSTOMER_ID  => l_tar_SALES_LEAD_CONTACT_rec.CUSTOMER_ID,
            p_ADDRESS_ID  => l_tar_SALES_LEAD_CONTACT_rec.ADDRESS_ID,
            p_PHONE_ID  => l_tar_SALES_LEAD_CONTACT_rec.PHONE_ID,
            p_CONTACT_ROLE_CODE  =>
                               l_tar_SALES_LEAD_CONTACT_rec.CONTACT_ROLE_CODE,
            p_PRIMARY_CONTACT_FLAG =>
                             l_tar_SALES_LEAD_CONTACT_rec.PRIMARY_CONTACT_FLAG,
            p_ATTRIBUTE_CATEGORY =>
                           l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_tar_SALES_LEAD_CONTACT_rec.ATTRIBUTE15);
            -- p_SECURITY_GROUP_ID =>
            --            l_tar_SALES_LEAD_CONTACT_rec.SECURITY_GROUP_ID);

        x_sales_lead_cnt_out_tbl(l_curr_row).lead_contact_id
                         := l_tar_sales_lead_contact_rec.lead_contact_id;
        x_sales_lead_cnt_out_tbl(l_curr_row).return_status := x_return_status;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END LOOP;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Updating the header table for last updated');
    END IF;

      UPDATE as_sales_leads
      SET last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.USER_ID,
          last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      WHERE sales_lead_id = l_tar_SALES_LEAD_CONTACT_Rec.sales_lead_id;


    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Calling Check_primary_contact');
    END IF;

    -- Check IF there is only one primary contact
    Check_primary_contact (
        P_Api_Version_Number         => 2.0
       ,P_Init_Msg_List              => FND_API.G_FALSE
       ,P_Commit                     => FND_API.G_FALSE
       ,p_validation_level           => P_Validation_Level
       ,P_Check_Access_Flag          => P_Check_Access_Flag
       ,P_Admin_Flag                 => P_Admin_Flag
       ,P_Admin_Group_Id             => P_Admin_Group_Id
       ,P_identity_salesforce_id     => P_identity_salesforce_id
       ,P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl
       ,P_SALES_LEAD_ID        => l_tar_SALES_LEAD_CONTACT_Rec.sales_lead_id
       ,X_Return_Status              => x_Return_Status
       ,X_Msg_Count                  => X_Msg_Count
       ,X_Msg_Data                   => X_Msg_Data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ffang 082801, for bug 1939730, denorm primary contact's
    -- contact_party_id to as_sales_leads.primary_contact_party_id

-- ckapoor 011102 , for bug 2098158, denorm the party id of the
-- primary contact (not the relationship) to as_sales_leads.primary_cnt_person_party_id
-- also denorm the phone_id of primary contact to as_sales_leads.primary_contact_phone_id


    OPEN C_Get_Pri_Contact(l_tar_SALES_LEAD_CONTACT_rec.SALES_LEAD_ID);
    FETCH C_Get_Pri_Contact into l_contact_party_id, l_contact_phone_id, l_cnt_person_party_id;
    IF C_Get_Pri_Contact%FOUND THEN
        UPDATE AS_SALES_LEADS
        SET PRIMARY_CONTACT_PARTY_ID = l_contact_party_id,
            PRIMARY_CONTACT_PHONE_ID = l_contact_phone_id,
            PRIMARY_CNT_PERSON_PARTY_ID = l_cnt_person_party_id
        WHERE sales_lead_id = l_tar_SALES_LEAD_CONTACT_rec.SALES_LEAD_ID;
    ELSE   -- no primary contact found
        UPDATE AS_SALES_LEADS
        SET PRIMARY_CONTACT_PARTY_ID = NULL,
	    PRIMARY_CONTACT_PHONE_ID = NULL,
	    PRIMARY_CNT_PERSON_PARTY_ID = NULL

        WHERE sales_lead_id = l_tar_SALES_LEAD_CONTACT_rec.SALES_LEAD_ID;
    END IF;

    CLOSE C_Get_Pri_Contact;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Primary Contact for '||
                                 l_tar_SALES_LEAD_CONTACT_rec.SALES_LEAD_ID||':'
                                 ||l_contact_party_id);
    END IF;

    --
    -- END of API body.
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' End');
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END Update_sales_lead_contacts;


PROCEDURE Delete_sales_lead_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl     IN
                  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl     OUT
                  AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
    CURSOR C_Get_cont_del(c_LEAD_CONTACT_ID Number) IS
        SELECT
           SALES_LEAD_ID,
           PRIMARY_CONTACT_FLAG,
           CONTACT_PARTY_ID
        FROM  AS_SALES_LEAD_CONTACTS
        WHERE lead_contact_id = c_LEAD_CONTACT_ID;

    l_api_name           CONSTANT VARCHAR2(30) := 'Delete_sales_lead_contacts';
    l_api_version_number CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_sales_lead_contact_rec     AS_SALES_LEADS_PUB.Sales_Lead_Contact_Rec_Type;
    l_sales_lead_id              NUMBER;
    l_primary_contact_flag       VARCHAR2(1);
    l_contact_party_id           NUMBER;
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALES_LEAD_CONTACTS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      --  Api body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      FOR l_curr_row IN 1..p_sales_lead_contact_tbl.count LOOP
        x_sales_lead_cnt_out_tbl(l_curr_row).return_status
                                                := FND_API.G_RET_STS_SUCCESS;

        -- Progress Message
        --
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
            FND_MESSAGE.Set_Token ('ROW', 'SALES_LEAD_CONTACT', TRUE);
            FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
            FND_MSG_PUB.Add;
        END IF;

        l_sales_lead_contact_rec := p_sales_lead_contact_tbl(l_curr_row);

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Open C_Get_cont_del');
        END IF;

        -- Get the whole record
        Open C_Get_cont_del(l_SALES_LEAD_CONTACT_rec.LEAD_CONTACT_ID);
        Fetch C_Get_cont_del into l_sales_lead_id, l_primary_contact_flag,
                                  l_contact_party_id;

        IF ( C_Get_cont_del%NOTFOUND) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
              FND_MESSAGE.Set_Token ('INFO', 'SALES_LEAD_CONTACT', FALSE);
              FND_MSG_PUB.Add;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Close C_Get_cont_del');
        END IF;
        Close C_Get_cont_del;

        IF(P_Check_Access_Flag = 'Y') THEN
            -- Call Get_Access_Profiles to get access_profile_rec
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Get_Access_Profiles');
            END IF;

            AS_SALES_LEADS_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_sales_lead_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Calling Has_updateLeadAccess');

            END IF;

            AS_ACCESS_PUB.Has_updateLeadAccess(
                p_api_version_number  => 2.0
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_validation_level    => p_validation_level
               ,p_access_profile_rec  => l_access_profile_rec
               ,p_admin_flag          => p_admin_flag
               ,p_admin_group_id      => p_admin_group_id
               ,p_person_id   => l_identity_sales_member_rec.employee_person_id
               ,p_sales_lead_id       => l_sales_lead_id
               ,p_check_access_flag   => p_check_access_flag  -- should be 'Y'
               ,p_identity_salesforce_id => p_identity_salesforce_id
               ,p_partner_cont_party_id => NULL
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ,x_update_access_flag  => l_update_access_flag);

            IF l_update_access_flag <> 'Y' THEN
                IF (AS_DEBUG_ERROR_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                             'API_NO_CREATE_PRIVILEGE');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling CONTACTS_Delete_Row');
        END IF;

        -- Invoke table handler
        AS_SALES_LEAD_CONTACTS_PKG.SALES_LEAD_CONTACTS_Delete_Row(
            p_LEAD_CONTACT_ID  => l_SALES_LEAD_CONTACT_rec.LEAD_CONTACT_ID);

        x_sales_lead_cnt_out_tbl(l_curr_row).lead_contact_id
                                  := l_sales_lead_contact_rec.lead_contact_id;
        x_sales_lead_cnt_out_tbl(l_curr_row).return_status := x_return_status;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

	    -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Updating the header table for last updated');
        END IF;

        UPDATE as_sales_leads
        SET last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.USER_ID,
          last_update_login = FND_GLOBAL.CONC_LOGIN_ID
        WHERE sales_lead_id = l_sales_lead_id;


        -- ffang 090601, if primary contact is deleted, update as_sales_leads
        -- to clean up primary_contact_party_id
        -- ckapoor 011102 bug 2098158 clean up primary_contact_phone_id and primary_cnt_person_party_id
        IF l_PRIMARY_CONTACT_FLAG = 'Y' THEN
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Primary contact is deleted');
            END IF;
            update as_sales_leads
            set primary_contact_party_id = NULL,
            	primary_contact_phone_id = NULL,
            	primary_cnt_person_party_id = NULL
            where sales_lead_id = l_sales_lead_id
              and primary_contact_party_id = l_contact_party_id;
        END IF;
      END LOOP;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Delete_sales_lead_contacts;


--   API Name:  Check_primary_contact

PROCEDURE Check_primary_contact (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                        := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    Cursor C_Get_Primary_Contact_Count ( X_SALES_LEAD_ID NUMBER) IS
       SELECT  count(*)
       FROM    as_sales_lead_contacts
       WHERE   sales_lead_id = X_SALES_LEAD_ID
               and enabled_flag = 'Y'
               and primary_contact_flag = 'Y';
    l_count                      NUMBER;
    l_api_name            CONSTANT VARCHAR2(30) := 'Check_primary_contact';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_cnt varchar2(2);
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      --      Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      --  Api body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN C_Get_Primary_Contact_Count (P_SALES_LEAD_ID);
      FETCH C_Get_Primary_Contact_Count into l_count;
      IF C_Get_Primary_Contact_Count%NOTFOUND THEN
	  -- Debug Message
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                    'Private API: No primary contact');
          END IF;
      END IF;
      CLOSE C_Get_Primary_Contact_Count;

      IF l_count > 1 THEN
          -- Debug Message
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'More than one primary contact');
          END IF;
          AS_UTILITY_PVT.Set_Message(p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                               p_msg_name => 'API_PRIMARY_CONTACT_DUP_FOUND');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Check_primary_contact;


END AS_SALES_LEAD_CONTACTS_PVT;

/
