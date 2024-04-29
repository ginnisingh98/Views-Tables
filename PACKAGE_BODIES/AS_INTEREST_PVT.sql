--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_PVT" as
/* $Header: asxvintb.pls 120.2 2005/08/04 22:16:50 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):='AS_INTEREST_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxvintb.pls';

/* Remove dependency on global variable, use FND_GLOBAL.xxx directly
G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
*/
--
-- NAME
--   AS_INTEREST_PVT
--
-- PURPOSE
--   This is a private API used to create interests (Company Classifications,
--  Contact Interests, or Lead Classifications).
--
-- NOTES
--   Create_Interest is a private OSM routine, that should not be called by modules
--   outside of OSM
--
-- HISTORY
--   11/12/96   JKORNBER                Created
--   08/28/98   AWU         Add update_interest
--                  Add interest_id, customer_id, address_id,
--                  contact_id and lead_id into
--                  interest record
--                  Changed interest rec default value NULL to
--                  FND_API.G_MISS for update purpose
--


/***************************  PRIVATE ROUTINES *********************************/

 -- Conversion Routines
  PROCEDURE convert_miss_interest_rec(p_interest_rec IN  INTEREST_REC_TYPE,
                                 x_interest_rec OUT NOCOPY  INTEREST_REC_TYPE) is
  l_interest_rec INTEREST_REC_TYPE := p_interest_rec;
  Begin
    if (l_interest_rec.interest_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.interest_id := NULL;
    end if;
    if (l_interest_rec.customer_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.customer_id := NULL;
    end if;
    if (l_interest_rec.address_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.address_id := NULL;
    end if;
    if (l_interest_rec.contact_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.contact_id := NULL;
    end if;
    if (l_interest_rec.lead_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.lead_id := NULL;
    end if;
    if (l_interest_rec.interest_type_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.interest_type_id := NULL;
    end if;
    if (l_interest_rec.primary_interest_code_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.primary_interest_code_id := NULL;
    end if;
    if (l_interest_rec.secondary_interest_code_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.secondary_interest_code_id := NULL;
    end if;
    if (l_interest_rec.status_code = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.status_code := NULL;
    end if;
    if (l_interest_rec.status = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.status := NULL;
    end if;
    if (l_interest_rec.description = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.description := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE_CATEGORY := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE1 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE2 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE3 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE4 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE5 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE6 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE7 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE8 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE9 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE10 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE11 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE12 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE13 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE14 := NULL;
    end if;
    if (l_interest_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR)
    then
        l_interest_rec.ATTRIBUTE15 := NULL;
    end if;
    if (l_interest_rec.product_category_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.product_category_id := NULL;
    end if;
    if (l_interest_rec.product_cat_set_id = FND_API.G_MISS_NUM)
    then
        l_interest_rec.product_cat_set_id := NULL;
    end if;

    x_interest_rec := l_interest_rec;

end convert_miss_interest_rec;

  -- Name
  --  Invalid_Use
  --
  -- Purpose
  --  Function to determine if the interest_use_code is consistent with
  --  the ids passed into the create_interest procedure.
  --  Returns True if the interest_use_code and ids are inconsistent,
  --  True if consistent otherwise.
  --
  FUNCTION INVALID_USE (p_interest_use_code VARCHAR2,
          p_customer_id NUMBER,
          p_address_id NUMBER,
          p_contact_id NUMBER,
          p_lead_id NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF ( (p_interest_use_code = 'LEAD_CLASSIFICATION')
      and (p_customer_id is NOT NULL
         --  and p_address_id is NOT NULL
           and p_lead_id is NOT NULL) )
    THEN
      return FALSE;

    ELSIF ( (p_interest_use_code = 'COMPANY_CLASSIFICATION')
      and ( p_customer_id is NOT NULL))
       -- and p_address_id is NOT NULL) )
    THEN
      return FALSE;

    ELSIF ( (p_interest_use_code = 'CONTACT_INTEREST')
      and ( p_customer_id is NOT NULL))
--        and p_address_id is NOT NULL) )
    THEN
      return FALSE;

    ELSE
      return TRUE;
    END IF;
  END INVALID_USE;


 PROCEDURE Validate_party_id (
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
  FROM  HZ_PARTIES CUST
  WHERE CUST.PARTY_TYPE in ('PERSON', 'ORGANIZATION', 'PARTY_RELATIONSHIP')
        AND CUST.STATUS IN ('A','I')
        AND party_id = X_Party_Id;

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
        FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
        FND_MSG_PUB.ADD;
     END IF;
  END IF;
  close C_Party_Exists;

  FND_MSG_PUB.Count_And_Get
  ( p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
  );

END Validate_party_id;

  PROCEDURE Validate_Product_Category ( p_interest_id                 IN  NUMBER,
                                        p_product_category_id         IN  NUMBER,
                                        p_product_cat_set_id          IN  NUMBER,
                                        p_interest_status_code        IN  VARCHAR2,
                                        p_return_status   OUT NOCOPY VARCHAR2
                                      );

  PROCEDURE Validate_Interest_Type (  p_interest_type_id            IN  NUMBER,
                                      p_primary_interest_code_id    IN  NUMBER,
                                      p_secondary_interest_code_id  IN  NUMBER,
                                      p_interest_status_code        IN  VARCHAR2,
                                      p_return_status   OUT NOCOPY VARCHAR2
                                   );


  PROCEDURE Validate_Interest ( p_interest_use_code IN VARCHAR2,
                                p_interest_rec    IN  INTEREST_REC_TYPE,
                                p_return_status   OUT NOCOPY VARCHAR2
                              )
  IS
    l_return_status   VARCHAR2(1);
    l_interest_fields_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_interest_rec INTEREST_REC_TYPE := p_interest_rec;
  BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    --convert_miss_interest_rec(l_interest_rec,l_interest_rec);

    -- Interest Validation
    --

    IF (p_interest_use_code = 'CONTACT_INTEREST')
    THEN
        Validate_Product_Category( p_interest_id                 => l_interest_rec.interest_id,
                                   p_product_category_id         => l_interest_rec.product_category_id,
                                   p_product_cat_set_id          => l_interest_rec.product_cat_set_id,
                                   p_interest_status_code        => l_interest_rec.status_code,
                                   p_return_status               => l_interest_fields_status
                                 );
    ELSE
        Validate_Interest_Type(  p_interest_type_id            => l_interest_rec.interest_type_id,
                                 p_primary_interest_code_id    => l_interest_rec.primary_interest_code_id,
                                 p_secondary_interest_code_id  => l_interest_rec.secondary_interest_code_id,
                                 p_interest_status_code        => l_interest_rec.status_code,
                                 p_return_status               => l_interest_fields_status
                              );
    END IF;

      IF l_interest_fields_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_ROW_NOT_PROCESSED');
          FND_MESSAGE.Set_Token('ROW', 'AS_INTEREST', TRUE);
          FND_MSG_PUB.ADD;
        END IF;
      END IF;

    p_return_status := l_return_status;

  END Validate_Interest;


/***************************  PUBLIC ROUTINES  *********************************/

  PROCEDURE Create_Interest(  p_api_version_number  IN  NUMBER,
                              p_init_msg_list       IN  VARCHAR2  := FND_API.G_FALSE,
                              p_commit              IN  VARCHAR2  := FND_API.G_FALSE,
                              p_validation_level    IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                              p_interest_tbl        IN  INTEREST_TBL_TYPE := G_MISS_INTEREST_TBL,
                              p_customer_id         IN  NUMBER,
                              p_address_id          IN  NUMBER,
                              p_contact_id          IN  NUMBER,
                              p_lead_id             IN  NUMBER,
                              p_interest_use_code   IN  VARCHAR2,
                        p_check_access_flag   IN  VARCHAR2,
                        p_admin_flag          IN  VARCHAR2,
                        p_admin_group_id      IN  NUMBER,
                        p_identity_salesforce_id  IN NUMBER,
                              p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
                              p_return_status       OUT NOCOPY VARCHAR2,
                              p_msg_count           OUT NOCOPY NUMBER,
                              p_msg_data            OUT NOCOPY VARCHAR2,
                              p_interest_out_tbl    OUT NOCOPY INTEREST_OUT_TBL_TYPE
                            )
  IS
    l_api_name            CONSTANT VARCHAR2(30) := 'Create_Interest';
    l_api_version_number  CONSTANT NUMBER       := 2.0;

    l_interest_count    CONSTANT NUMBER   := p_interest_tbl.count;
    l_return_status     VARCHAR2(1);    -- Local return status equal to p_return_status
    l_interests_inserted  NUMBER := 0;  -- Number of successful inserts
    l_interest_tbl INTEREST_TBL_TYPE;

    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_count             NUMBER := 0;

    -- Local insert variables
    l_rowid         ROWID;
    l_interest_id   NUMBER;
    l_identity_sales_member_rec      AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_update_access_flag  VARCHAR2(1);

    -- Local status table
    TYPE l_interest_status_tbl  IS TABLE OF     VARCHAR2(1) INDEX BY BINARY_INTEGER;
    l_return_status_tbl   l_interest_status_tbl;
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    x_lead_id NUMBER;

    CURSOR duplicate_cat_cur(p_customer_id IN NUMBER,
                             p_product_category_id IN NUMBER,
                             p_product_cat_set_id IN NUMBER) IS
        select 1
        from AS_INTERESTS_ALL
        where customer_id = p_customer_id
        and interest_use_code = 'CONTACT_INTEREST'
        and product_category_id = p_product_category_id
        and product_cat_set_id = p_product_cat_set_id;

  l_module CONSTANT VARCHAR2(255) := 'as.plsql.intpv.Create_Interest';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT CREATE_INTEREST_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
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
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('AS', 'Pvt Interest API: Start');
      FND_MSG_PUB.Add;
    END IF;

    --  Initialize API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;
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
    -- ******************************************************************

    IF(p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN

       AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser
       ( p_api_version_number => 2.0
        ,p_salesforce_id => p_identity_salesforce_id
        ,p_admin_group_id => p_admin_group_id
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,x_sales_member_rec => l_identity_sales_member_rec);

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Get_CurrentUser fail');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) and
       l_interest_count <> 0
    THEN

      -- Insure that all required parameters exist
      --
      IF (p_customer_id is NULL or p_customer_id = FND_API.G_MISS_NUM)
      THEN
        p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ID', FALSE);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;

/*      ELSIF (p_address_id is NULL or p_address_id = FND_API.G_MISS_NUM)
      THEN
        p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'ADDRESS_ID', FALSE);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR; */

      END IF;

       -- validate customer_id
      validate_party_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_customer_id,
              x_return_status          => l_return_status,
              x_msg_count              => l_msg_count,
              x_msg_data               => l_msg_data);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      -- check to see if the address_id and customer_id passed are valid.
     if (p_address_id is not NULL and p_address_id <> FND_API.G_MISS_NUM)
     then
        AS_TCA_PVT.VALIDATE_PARTY_SITE_ID(
              p_init_msg_list => p_init_msg_list
           ,p_party_id      => p_customer_id
             ,p_party_site_id => p_address_id
             ,x_return_status => l_return_status
             ,x_msg_count     => l_msg_count
             ,x_msg_data      => l_msg_data);

        if l_return_status = FND_API.G_RET_STS_ERROR then
           raise FND_API.G_EXC_ERROR;
         elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
      end if;

      -- if the contact_id is passed check to see if it is valid.
      if (p_contact_id is not null and p_contact_id <> FND_API.G_MISS_NUM)
     then
        AS_TCA_PVT.VALIDATE_CONTACT_ID(
              p_init_msg_list => p_init_msg_list
           ,p_party_id      => p_customer_id
             ,p_contact_id    => p_contact_id
             ,x_return_status => l_return_status
             ,x_msg_count     => l_msg_count
             ,x_msg_data      => l_msg_data);

        if l_return_status = FND_API.G_RET_STS_ERROR then
           raise FND_API.G_EXC_ERROR;
         elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
      end if;

      -- If the interest use code is not consistent with the ids that are passed in
      -- then return an error
      IF INVALID_USE (p_interest_use_code, p_customer_id, p_address_id,
        p_contact_id, p_lead_id)
      THEN
        p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_USE_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_interest_use_code, FALSE);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

 -- check access here

    IF(p_check_access_flag = 'Y') THEN
       IF (p_lead_id is NULL or p_lead_id = FND_API.G_MISS_NUM) THEN
          AS_ACCESS_PUB.has_updateCustomerAccess
          ( p_api_version_number     => 2.0
           ,p_init_msg_list          => p_init_msg_list
           ,p_validation_level       => p_validation_level
           ,p_access_profile_rec     => p_access_profile_rec
           ,p_admin_flag             => p_admin_flag
           ,p_admin_group_id         => p_admin_group_id
           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
           ,p_customer_id            => p_customer_id
           ,p_check_access_flag      => 'Y'
           ,p_identity_salesforce_id => p_identity_salesforce_id
           ,p_partner_cont_party_id  => NULL
           ,x_return_status         => l_return_status
           ,x_msg_count             => l_msg_count
           ,x_msg_data              => l_msg_data
           ,x_update_access_flag    => l_update_access_flag
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateCustomerAccess fail');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_update_access_flag <> 'Y') THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
                FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       ELSE
          AS_ACCESS_PUB.has_updateOpportunityAccess
          ( p_api_version_number     => 2.0
           ,p_init_msg_list          => p_init_msg_list
           ,p_validation_level       => p_validation_level
           ,p_access_profile_rec     => p_access_profile_rec
           ,p_admin_flag             => p_admin_flag
           ,p_admin_group_id         => p_admin_group_id
           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
           ,p_opportunity_id         => p_lead_id
           ,p_check_access_flag      => 'Y'
           ,p_identity_salesforce_id => p_identity_salesforce_id
           ,p_partner_cont_party_id  => Null
           ,x_return_status          => p_return_status
           ,x_msg_count              => l_msg_count
           ,x_msg_data               => l_msg_data
           ,x_update_access_flag     => l_update_access_flag
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_update_access_flag <> 'Y') THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
                FND_MSG_PUB.ADD;
             END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
    END IF;

    --
    --  Loop through the pl/sql interest table, and insert the records into
    --  AS_INTERESTS
    --
    FOR l_curr_row IN 1..l_interest_count
    LOOP

      ----------------- Start of Processing Interest Record  -----------------------
      BEGIN
        -- Progress Message
        --
    /*    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
          FND_MESSAGE.Set_Token ('ROW', 'AS_INTEREST', TRUE);
          FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
          FND_MSG_PUB.Add;
        END IF;
    */
        -- Row savepoint
        SAVEPOINT CREATE_INTEREST_PVT_ROW;

        l_return_status_tbl(l_curr_row) := FND_API.G_RET_STS_SUCCESS;

        -- If the validation level is full, then validate the interest record
        --
        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL)
        THEN

          -- Debug Message
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
          THEN
            FND_MESSAGE.Set_Name('AS', 'Validating Record');
            FND_MSG_PUB.Add;
          END IF;

          Validate_Interest ( p_interest_use_code, p_interest_tbl(l_curr_row), l_return_status );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;

       OPEN duplicate_cat_cur(p_customer_id,
                              p_interest_tbl(l_curr_row).product_category_id,
                              p_interest_tbl(l_curr_row).product_cat_set_id);
       FETCH duplicate_cat_cur INTO l_count;
       IF (duplicate_cat_cur%FOUND)
       THEN
            FND_MESSAGE.Set_Name('AS', 'AS_DUPLICATE_MAPPING');
            FND_MSG_PUB.Add;
            Close duplicate_cat_cur;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
       Close duplicate_cat_cur;

       -- remarked by ACNG, 07/06/2000
        convert_miss_interest_rec(p_interest_tbl(l_curr_row), l_interest_tbl(l_curr_row));

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
          FND_MESSAGE.Set_Name('AS', 'Inserting Record');
          FND_MSG_PUB.Add;
        END IF;

        -- Clear values for next insert
        l_rowid := NULL;
        l_interest_id := NULL;

        -- Insert interest row
        AS_INTERESTS_PKG.Insert_Row ( X_Rowid                       => l_rowid,
                                      X_Interest_Id                 => l_interest_tbl(l_curr_row).interest_id,
                                      X_Last_Update_Date            =>sysdate,
                                      X_Last_Updated_By             =>FND_GLOBAL.User_Id,
                                      X_Creation_Date               => SYSDATE,
                                      X_Created_By                  =>FND_GLOBAL.User_Id,
                                      X_Last_Update_Login           =>FND_GLOBAL.Conc_Login_Id,
                                      X_Request_Id                  => FND_GLOBAL.Conc_Request_Id,
                                      X_Program_Application_Id      => FND_GLOBAL.Prog_Appl_Id,
                                      X_Program_Id                  => FND_GLOBAL.Conc_Program_Id,
                                      X_Program_Update_Date         => SYSDATE,
                                      X_Interest_Use_Code           => p_interest_use_code,
                                      X_Interest_Type_Id            => l_interest_tbl(l_curr_row).Interest_Type_Id,
                                      X_Contact_Id                  => p_contact_id,
                                      X_Customer_Id                 => p_customer_id,
                                      X_Address_Id                  => p_address_id,
                                      X_Lead_Id                     => p_lead_id,
                                      X_Primary_Interest_Code_Id    => l_interest_tbl(l_curr_row).Primary_Interest_Code_Id,
                                      X_Secondary_Interest_Code_Id  => l_interest_tbl(l_curr_row).Secondary_Interest_Code_Id,
                                      X_Status_Code                 => l_interest_tbl(l_curr_row).Status_Code,
                                      X_Description                 => l_interest_tbl(l_curr_row).description,
                                      X_Attribute_Category          => l_interest_tbl(l_curr_row).Attribute_Category,
                                      X_Attribute1                  => l_interest_tbl(l_curr_row).Attribute1,
                                      X_Attribute2                  => l_interest_tbl(l_curr_row).Attribute2,
                                      X_Attribute3                  => l_interest_tbl(l_curr_row).Attribute3,
                                      X_Attribute4                  => l_interest_tbl(l_curr_row).Attribute4,
                                      X_Attribute5                  => l_interest_tbl(l_curr_row).Attribute5,
                                      X_Attribute6                  => l_interest_tbl(l_curr_row).Attribute6,
                                      X_Attribute7                  => l_interest_tbl(l_curr_row).Attribute7,
                                      X_Attribute8                  => l_interest_tbl(l_curr_row).Attribute8,
                                      X_Attribute9                  => l_interest_tbl(l_curr_row).Attribute9,
                                      X_Attribute10                 => l_interest_tbl(l_curr_row).Attribute10,
                                      X_Attribute11                 => l_interest_tbl(l_curr_row).Attribute11,
                                      X_Attribute12                 => l_interest_tbl(l_curr_row).Attribute12,
                                      X_Attribute13                 => l_interest_tbl(l_curr_row).Attribute13,
                                      X_Attribute14                 => l_interest_tbl(l_curr_row).Attribute14,
                                      X_Attribute15                 => l_interest_tbl(l_curr_row).Attribute15,
                                      X_Product_Category_Id         => l_interest_tbl(l_curr_row).Product_Category_Id,
                                      X_Product_Cat_Set_Id          => l_interest_tbl(l_curr_row).Product_Cat_Set_Id
                                      );

        p_interest_out_tbl(l_curr_row).interest_id := l_interest_tbl(l_curr_row).interest_id;
        l_interests_inserted := l_interests_inserted + 1;

        -- Handle exceptions within the loop, so that other rows will be processed if possible
        --
        EXCEPTION

           WHEN FND_API.G_EXC_ERROR THEN

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => P_MSG_COUNT
                ,X_MSG_DATA => P_MSG_DATA
                ,X_RETURN_STATUS => l_RETURN_STATUS);

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => P_MSG_COUNT
                ,X_MSG_DATA => P_MSG_DATA
                ,X_RETURN_STATUS => l_RETURN_STATUS);

           WHEN OTHERS THEN

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
          ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => P_MSG_COUNT
                ,X_MSG_DATA => P_MSG_DATA
                ,X_RETURN_STATUS => l_RETURN_STATUS);

      END;
        ---------------- End of Processing Interest Record  -----------------------

    END LOOP;

      -- Fix bug 2304022
      IF (p_lead_id is not NULL AND p_lead_id <> FND_API.G_MISS_NUM) THEN
        IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Opportunity Real Time API ');
    END IF;
      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          p_lead_id		       => p_LEAD_ID,
          X_Return_Status              => l_return_status,
          X_Msg_Count                  => l_msg_count,
          X_Msg_Data                   => l_msg_data
        );

        IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Opportunity Real Time API fail');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    -- Calculate the return status
    FOR l_curr_row IN 1..l_interest_count
    LOOP
      IF l_return_status_tbl(l_curr_row) = FND_API.G_RET_STS_ERROR
      THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        l_return_status := FND_API.G_RET_STS_ERROR;

        EXIT;
      END IF;
      IF l_return_status_tbl(l_curr_row) = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        EXIT;
      END IF;
    END LOOP;

    --
    -- End of API body.
    --

    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) and
      l_interests_inserted > 0
    THEN
      FND_MESSAGE.Set_Name('AS', 'API_ROWS_INSERTED');
      FND_MESSAGE.Set_Token('ROW', 'AS_INTEREST', TRUE);
      FND_MESSAGE.Set_Token('NUMBER', to_char(l_interests_inserted), FALSE);
      FND_MSG_PUB.Add;
    END IF;


    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) and
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
      FND_MESSAGE.Set_Token('ROW', 'AS_INTEREST', TRUE);
      FND_MSG_PUB.Add;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('AS', 'Pvt Interest API: End');
      FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count           =>      p_msg_count,
                               p_data            =>      p_msg_data
                              );

    --
    -- Normal API Exception handling, if exception occurs outside of interest processing loop
    --
    EXCEPTION

           WHEN FND_API.G_EXC_ERROR THEN

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => P_MSG_COUNT
                ,X_MSG_DATA => P_MSG_DATA
                ,X_RETURN_STATUS => l_RETURN_STATUS);

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => P_MSG_COUNT
                ,X_MSG_DATA => P_MSG_DATA
                ,X_RETURN_STATUS => l_RETURN_STATUS);

           WHEN OTHERS THEN

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
          ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => P_MSG_COUNT
                ,X_MSG_DATA => P_MSG_DATA
                ,X_RETURN_STATUS => l_RETURN_STATUS);

  END Create_Interest;

-- Start of Comments
--
--  API name    : Update Interest
--  Type        : Private
--  Function    : Update Account, Contact, or Lead Classification Interest
--  Pre-reqs    : Account, contact, or lead exists
--  Parameters
--  IN      :
--          p_api_version_number    IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_commit            IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
--          p_interest_rec      IN INTEREST_REC_TYPE    Optional
--          p_interest_use_code IN  VARCHAR2    Required
--              (LEAD_CLASSIFICATION, COMPANY_CLASSIFICATION,
--               CONTACT_INTEREST)
--
--  OUT     :
--          x_return_status     OUT VARCHAR2(1)
--          x_msg_count     OUT NUMBER
--          x_msg_data      OUT VARCHAR2(2000)
--          x_interest_id       OUT     NUMBER
--
--
--  Version :   Current version 2.0
--              Initial Version
--           Initial version    2.0
--
--  Notes:
--          Validation proceeds as follows:
--              For lead classification: lead_id, customer_id,
--                  address_id must exist
--              For contact interest: contact_id, customer_id,
--                  address_id must exists
--              For account interest: customer_id, address_id must exists
--          For each interest, the interest type must be denoted properly
--              (i.e. for updating lead classifications, the interest
--              type must be denoted as a lead classification interest)
--
--
-- End of Comments
PROCEDURE Update_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
     p_check_access_flag   IN  VARCHAR2,
     p_admin_flag          IN  VARCHAR2,
     p_admin_group_id      IN  NUMBER,
     p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    x_interest_id       OUT NOCOPY     NUMBER
) is

 l_api_name            CONSTANT VARCHAR2(30) := 'Update_Interest';
    l_api_version_number  CONSTANT NUMBER       := 2.0;
    l_return_status     VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_rowid         ROWID;
    l_identity_sales_member_rec      AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_last_update_date DATE;
    l_update_access_flag VARCHAR2(1);
    l_count             NUMBER := 0;

    x_lead_id NUMBER;

    cursor get_interest_info_csr is
    SELECT rowid, last_update_date
    FROM   as_interests
    WHERE  interest_id = p_interest_rec.interest_id
    FOR UPDATE of interest_Id  NOWAIT;

    CURSOR duplicate_cat_cur(p_customer_id IN NUMBER,
                             p_interest_id IN NUMBER,
                             p_product_category_id IN NUMBER,
                             p_product_cat_set_id IN NUMBER) IS
    select 1
    from AS_INTERESTS_ALL
    where customer_id = p_customer_id
    and interest_use_code = 'CONTACT_INTEREST'
    and product_category_id = p_product_category_id
    and product_cat_set_id = p_product_cat_set_id
    and interest_id <> p_interest_id;

    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intpv.Update_Interest';
  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_INTEREST_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
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
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('AS', 'Pvt Interest API: Start');
      FND_MSG_PUB.Add;
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

    IF(p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN

       AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
         p_api_version_number => 2.0
        ,p_salesforce_id => p_identity_salesforce_id
       ,p_admin_group_id => p_admin_group_id
        ,x_return_status => l_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
        ,x_sales_member_rec => l_identity_sales_member_rec);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Get_CurrentUser fail');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
    THEN

      -- Insure that all required parameters exist
      --
      IF (p_interest_rec.customer_id is NULL or p_interest_rec.customer_id = FND_API.G_MISS_NUM) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_ID', FALSE);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- check to see if the address_id and customer_id passed are valid.
     if p_interest_rec.address_id is not NULL and p_interest_rec.address_id <> FND_API.G_MISS_NUM
     then
        AS_TCA_PVT.VALIDATE_PARTY_SITE_ID(
              p_init_msg_list => p_init_msg_list
           ,p_party_id      => p_interest_rec.customer_id
             ,p_party_site_id => p_interest_rec.address_id
             ,x_return_status => l_return_status
             ,x_msg_count     => l_msg_count
             ,x_msg_data      => l_msg_data);

        if l_return_status = FND_API.G_RET_STS_ERROR then
           raise FND_API.G_EXC_ERROR;
         elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
      end if;

      -- if the contact_id is passed check to see if it is valid.
      if p_interest_rec.contact_id is not null and p_interest_rec.contact_id <> FND_API.G_MISS_NUM
     then
        AS_TCA_PVT.VALIDATE_CONTACT_ID(
              p_init_msg_list => p_init_msg_list
           ,p_party_id      => p_interest_rec.customer_id
             ,p_contact_id    => p_interest_rec.contact_id
             ,x_return_status => l_return_status
             ,x_msg_count     => l_msg_count
             ,x_msg_data      => l_msg_data);

        if l_return_status = FND_API.G_RET_STS_ERROR then
           raise FND_API.G_EXC_ERROR;
         elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
      end if;

      -- If the interest use code is not consistent with the ids that are passed in
      -- then return an error
      IF INVALID_USE (p_interest_use_code, p_interest_rec.customer_id, p_interest_rec.address_id,
        p_interest_rec.contact_id, p_interest_rec.lead_id)
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_USE_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_interest_use_code, FALSE);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    -- check access here

    IF(p_check_access_flag = 'Y') THEN
       IF (p_interest_rec.lead_id is NULL or p_interest_rec.lead_id = FND_API.G_MISS_NUM) THEN
          AS_ACCESS_PUB.has_updateCustomerAccess
          ( p_api_version_number     => 2.0
           ,p_init_msg_list          => p_init_msg_list
           ,p_validation_level       => p_validation_level
           ,p_access_profile_rec     => p_access_profile_rec
           ,p_admin_flag             => p_admin_flag
           ,p_admin_group_id         => p_admin_group_id
           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
           ,p_customer_id            => p_interest_rec.customer_id
           ,p_check_access_flag      => 'Y'
           ,p_identity_salesforce_id => p_identity_salesforce_id
           ,p_partner_cont_party_id  => NULL
           ,x_return_status         => l_return_status
           ,x_msg_count             => l_msg_count
           ,x_msg_data              => l_msg_data
           ,x_update_access_flag    => l_update_access_flag
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateCustomerAccess fail');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_update_access_flag <> 'Y') THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
                FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       ELSE
          AS_ACCESS_PUB.has_updateOpportunityAccess
          ( p_api_version_number     => 2.0
          ,p_init_msg_list          => p_init_msg_list
           ,p_validation_level       => p_validation_level
           ,p_access_profile_rec     => p_access_profile_rec
           ,p_admin_flag             => p_admin_flag
           ,p_admin_group_id         => p_admin_group_id
           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
           ,p_opportunity_id         => p_interest_rec.lead_id
           ,p_check_access_flag      => 'Y'
           ,p_identity_salesforce_id => p_identity_salesforce_id
           ,p_partner_cont_party_id  => Null
           ,x_return_status          => l_return_status
           ,x_msg_count              => l_msg_count
           ,x_msg_data               => l_msg_data
           ,x_update_access_flag     => l_update_access_flag
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_updateOpportunityAccess fail');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (l_update_access_flag <> 'Y') THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
                FND_MSG_PUB.ADD;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
    END IF;

    -- If the validation level is full, then validate the interest record
        --
        IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL)
        THEN

          -- Debug Message
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
          THEN
            FND_MESSAGE.Set_Name('AS', 'Validating Record');
            FND_MSG_PUB.Add;
          END IF;

          Validate_Interest ( p_interest_use_code, p_interest_rec, l_return_status );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;

       OPEN duplicate_cat_cur(p_interest_rec.customer_id,
                              p_interest_rec.interest_id,
                              p_interest_rec.product_category_id,
                              p_interest_rec.product_cat_set_id);
       FETCH duplicate_cat_cur INTO l_count;
       IF (duplicate_cat_cur%FOUND)
       THEN
            FND_MESSAGE.Set_Name('AS', 'AS_DUPLICATE_MAPPING');
            FND_MSG_PUB.Add;
            Close duplicate_cat_cur;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
       Close duplicate_cat_cur;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
          FND_MESSAGE.Set_Name('AS', 'Updating Record');
          FND_MSG_PUB.Add;
        END IF;

    -- lock rows before update

    open get_interest_info_csr;
    fetch get_interest_info_csr into l_rowid, l_last_update_date;
    close get_interest_info_csr;

    if (p_interest_rec.last_update_date is NULL
        or p_interest_rec.last_update_date = FND_API.G_MISS_DATE)
        then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
             FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if (l_last_update_date <> p_interest_rec.last_update_date)
    then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
            FND_MESSAGE.Set_Token('INFO', 'AS_INTERESTS', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    else

        AS_INTERESTS_PKG.Update_Row (     X_Rowid                       => l_rowid,
                                      X_Interest_Id                 => p_interest_rec.interest_id,
                                      X_Last_Update_Date            => SYSDATE,
                                      X_Last_Updated_By             => FND_GLOBAL.USER_ID,
                                      X_Last_Update_Login           => FND_GLOBAL.Conc_Login_Id,
                                      X_Request_Id                  => FND_GLOBAL.Conc_Request_Id,
                                      X_Program_Application_Id      => FND_GLOBAL.Prog_Appl_Id,
                                      X_Program_Id                  => FND_GLOBAL.Conc_Program_Id,
                                      X_Program_Update_Date         => SYSDATE,
                                      X_Interest_Use_Code           => p_interest_use_code,
                                      X_Interest_Type_Id            => p_interest_rec.Interest_Type_Id,
                                      X_Contact_Id                  => p_interest_rec.contact_id,
                                      X_Customer_Id                 => p_interest_rec.customer_id,
                                      X_Address_Id                  => p_interest_rec.address_id,
                                      X_Lead_Id                     => p_interest_rec.lead_id,
                                      X_Primary_Interest_Code_Id    => p_interest_rec.Primary_Interest_Code_Id,
                                      X_Secondary_Interest_Code_Id  => p_interest_rec.Secondary_Interest_Code_Id,
                                      X_Status_Code                 => p_interest_rec.Status_Code,
                                      X_Description                 => p_interest_rec.description,
                                      X_Attribute_Category          => p_interest_rec.Attribute_Category,
                                      X_Attribute1                  => p_interest_rec.Attribute1,
                                      X_Attribute2                  => p_interest_rec.Attribute2,
                                      X_Attribute3                  => p_interest_rec.Attribute3,
                                      X_Attribute4                  => p_interest_rec.Attribute4,
                                      X_Attribute5                  => p_interest_rec.Attribute5,
                                      X_Attribute6                  => p_interest_rec.Attribute6,
                                      X_Attribute7                  => p_interest_rec.Attribute7,
                                      X_Attribute8                  => p_interest_rec.Attribute8,
                                      X_Attribute9                  => p_interest_rec.Attribute9,
                                      X_Attribute10                 => p_interest_rec.Attribute10,
                                      X_Attribute11                 => p_interest_rec.Attribute11,
                                      X_Attribute12                 => p_interest_rec.Attribute12,
                                      X_Attribute13                 => p_interest_rec.Attribute13,
                                      X_Attribute14                 => p_interest_rec.Attribute14,
                                      X_Attribute15                 => p_interest_rec.Attribute15,
                                      X_Product_Category_Id         => p_interest_rec.Product_Category_Id,
                                      X_Product_Cat_Set_Id          => p_interest_rec.Product_Cat_Set_Id
                                      );
        end if;
    x_interest_id := p_interest_rec.interest_id;

      -- Fix bug 2304022
      IF (p_interest_rec.lead_id is not NULL AND
      p_interest_rec.lead_id <> FND_API.G_MISS_NUM) THEN
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Opportunity Real Time API');
      END IF;
      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
	  P_Commit                     => FND_API.G_FALSE,
          p_lead_id		       => p_interest_rec.lead_id,
          X_Return_Status              => l_return_status,
          X_Msg_Count                  => l_msg_count,
          X_Msg_Data                   => l_msg_data
        );

        IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Opportunity Real Time API fail');
        END IF;
            RAISE FND_API.G_EXC_ERROR;

        END IF;
    END IF;


-- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) and
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
      FND_MESSAGE.Set_Token('ROW', 'AS_INTEREST', TRUE);
      FND_MSG_PUB.Add;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('AS', 'Pvt Interest API: End');
      FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count           =>      x_msg_count,
                               p_data            =>      x_msg_data
                              );

    EXCEPTION

           WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
             ROLLBACK TO UPDATE_INTEREST_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR ;

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
               FND_MESSAGE.Set_Name('AS', 'API_CANNOT_RESERVE_RECORD');
               FND_MESSAGE.Set_Token('INFO', 'UPDATE_INTEREST', FALSE);
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

  END Update_Interest;

PROCEDURE Delete_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
     p_check_access_flag   in  varchar2,
     p_admin_flag          in  varchar2,
     p_admin_group_id      in  number,
     p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2
) is
cursor get_interest_info_csr(p_interest_id NUMBER) is
        select 1
        from as_interests_all
        where interest_id = p_interest_id;

    l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Interest';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_return_status VARCHAR2(1);
    l_member_access VARCHAR2(1);
    l_member_role VARCHAR2(1);
    l_val NUMBER;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_update_access_flag varchar2(1);
        x_lead_id NUMBER;
        l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
        l_module CONSTANT VARCHAR2(255) := 'as.plsql.intpv.Delete_Interest';
begin
    -- Standard Start of API savepoint
    SAVEPOINT DELETE_INTEREST_PVT;

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

    if (p_interest_rec.interest_id is NULL)
    then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_ID', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
    end if;

    open get_interest_info_csr(p_interest_rec.interest_id);
    fetch get_interest_info_csr into l_val;

    if (get_interest_info_csr%NOTFOUND)
    then
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_ID', FALSE);
        fnd_message.set_token('VALUE', p_interest_rec.interest_id, FALSE);
        FND_MSG_PUB.ADD;
    END IF;
    close get_interest_info_csr;
        raise FND_API.G_EXC_ERROR;
    End if;
   if p_check_access_flag = 'Y'
   then
    IF p_interest_rec.lead_id is NULL or p_interest_rec.lead_id = FND_API.G_MISS_NUM
    THEN
       AS_ACCESS_PUB.has_updateCustomerAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_customer_id            => p_interest_rec.customer_id
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
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_DELETE_PRIVILEGE');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     ELSE
    AS_ACCESS_PUB.has_updateOpportunityAccess
       ( p_api_version_number     => 2.0
        ,p_init_msg_list          => p_init_msg_list
        ,p_validation_level       => p_validation_level
        ,p_access_profile_rec     => p_access_profile_rec
        ,p_admin_flag             => p_admin_flag
        ,p_admin_group_id         => p_admin_group_id
        ,p_person_id              => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id         => p_interest_rec.lead_id
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
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AS', 'API_NO_DELETE_PRIVILEGE');
             FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   end if; -- p_check_access_flag = 'Y'

    delete from as_interests_all
    where interest_id = p_interest_rec.interest_id;

      -- Fix bug 2304022
      IF (p_interest_rec.lead_id is not NULL AND
      p_interest_rec.lead_id <> FND_API.G_MISS_NUM) THEN
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Opportunity Real Time API');
      END IF;
      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          p_lead_id                    => p_interest_rec.lead_id,
          X_Return_Status              => l_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data
        );

        IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Opportunity Real Time API fail');
            END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

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


end Delete_Interest;

  PROCEDURE Validate_Product_Category ( p_interest_id                 IN  NUMBER,
                                        p_product_category_id         IN  NUMBER,
                                        p_product_cat_set_id          IN  NUMBER,
                                        p_interest_status_code        IN  VARCHAR2,
                                        p_return_status   OUT NOCOPY VARCHAR2
                                      )
  IS

    CURSOR  C_GET_OLD_PROD_CAT_INFO(l_interest_id NUMBER) IS
        SELECT  PRODUCT_CATEGORY_ID, PRODUCT_CAT_SET_ID
        FROM    AS_INTERESTS_ALL
        WHERE   INTEREST_ID = l_interest_id;

    l_return_status   VARCHAR2(1);
    l_interest_fields_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_old_product_category_id NUMBER;
    l_old_product_cat_set_id NUMBER;
    l_validation_level VARCHAR2(1) := 'L';
  BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Interest Validation
    --
    IF ((p_product_category_id is NULL)
      or (p_product_category_id = FND_API.G_MISS_NUM))
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PRODUCT_CATEGORY_ID', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
    ELSIF ((p_product_cat_set_id is NULL)
          or (p_product_cat_set_id = FND_API.G_MISS_NUM))
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'PRODUCT_CAT_SET_ID', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
    ELSE
      -- Insure that all ids are valid
      --
          OPEN C_GET_OLD_PROD_CAT_INFO ( p_interest_id );
          Fetch C_GET_OLD_PROD_CAT_INFO INTO l_old_product_category_id, l_old_product_cat_set_id;

          IF ((l_old_product_category_id is NOT NULL) and
              (l_old_product_cat_set_id is NOT NULL) and
              (l_old_product_category_id = p_product_category_id) and
              (l_old_product_cat_set_id = p_product_cat_set_id))
          THEN
                l_validation_level := 'L';
          ELSE
                l_validation_level := 'H';
          END IF;

          AS_OPP_LINE_PVT.Validate_Prod_Cat_Fields ( p_product_category_id         => p_product_category_id,
                                     p_product_cat_set_id          => p_product_cat_set_id,
                                     p_validation_level            => l_validation_level,
                                     x_return_status               => l_interest_fields_status
                                   );

      IF l_interest_fields_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    -- Now validate interest status
    --
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
        Validate_Int_Status_For_PC(p_product_category_id         => p_product_category_id,
                                   p_product_cat_set_id          => p_product_cat_set_id,
                                   p_interest_status_code        => p_interest_status_code,
                                   p_return_status               => l_return_status);
    END IF;

    p_return_status := l_return_status;

  END Validate_Product_Category;


  PROCEDURE Validate_Interest_Type (  p_interest_type_id            IN  NUMBER,
                                      p_primary_interest_code_id    IN  NUMBER,
                                      p_secondary_interest_code_id  IN  NUMBER,
                                      p_interest_status_code        IN  VARCHAR2,
                                      p_return_status   OUT NOCOPY VARCHAR2
                                   )
  IS
    l_return_status   VARCHAR2(1);
    l_interest_fields_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Interest Validation
    --
    IF ((p_interest_type_id is NULL)
      or (p_interest_type_id = FND_API.G_MISS_NUM))
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_TYPE_ID', FALSE);
        FND_MSG_PUB.ADD;
      END IF;

    ELSE
      -- Insure that all ids are valid
      --
      Validate_Int_Type_Fields( p_interest_type_id            => p_interest_type_id,
                                p_primary_interest_code_id    => p_primary_interest_code_id,
                                p_secondary_interest_code_id  => p_secondary_interest_code_id,
                                p_return_status               => l_interest_fields_status
                              );

      IF l_interest_fields_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    -- Now validate interest status
    --
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
        Validate_Int_Status(p_interest_type_id            => p_interest_type_id,
                            p_primary_interest_code_id    => p_primary_interest_code_id,
                            p_secondary_interest_code_id  => p_secondary_interest_code_id,
                            p_interest_status_code        => p_interest_status_code,
                            p_return_status               => l_return_status);
    END IF;

    p_return_status := l_return_status;

  END Validate_Interest_Type;

  -- Procedure validates interest type ids and returns SUCCESS if all ids are
  -- valid, ERROR otherwise
  -- Procedure assumes that at least the interest type exists
  --
  PROCEDURE Validate_Int_Type_Fields (  p_interest_type_id            IN  NUMBER,
                                        p_primary_interest_code_id    IN  NUMBER,
                                        p_secondary_interest_code_id  IN  NUMBER,
                                        p_return_status               OUT NOCOPY VARCHAR2
                                     )
  Is
    CURSOR C_Int_Type_Exists (X_Int_Type_Id NUMBER) IS
      SELECT  'X'
      FROM  as_interest_types_b
      WHERE Interest_Type_Id = X_Int_Type_Id;

    CURSOR C_Prim_Int_Code_Exists (X_Int_Code_Id NUMBER,
                                   X_Int_Type_Id NUMBER) IS
      SELECT 'X'
      FROM  As_Interest_Codes_B Pic
      WHERE Pic.Interest_Type_Id = X_Int_Type_Id
        and Pic.Interest_Code_Id = X_Int_Code_Id
        and Pic.Parent_Interest_Code_Id Is Null;

    CURSOR C_Sec_Int_Code_Exists (X_Sec_Int_Code_Id NUMBER,
                                  X_Int_Code_Id NUMBER,
                                  X_Int_Type_Id NUMBER) IS
      SELECT 'X'
      FROM  As_Interest_Codes_B Sic
      WHERE Sic.Interest_Type_Id = X_Int_Type_Id
        And Sic.Interest_Code_Id = X_Sec_Int_Code_Id
        And Sic.Parent_Interest_Code_Id = X_Int_Code_Id;

    l_variable VARCHAR2(1);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  Begin

    OPEN C_Int_Type_Exists (p_interest_type_id);
    FETCH C_Int_Type_Exists INTO l_variable;

    IF (C_Int_Type_Exists%NOTFOUND)
    THEN
      IF FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
            FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_TYPE', FALSE);
            FND_MESSAGE.Set_Token('VALUE', p_interest_type_id, FALSE);
          FND_MSG_PUB.Add;
      END IF;

      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE C_Int_Type_Exists;


    IF p_primary_interest_code_id is NOT NULL
    and p_primary_interest_code_id <> FND_API.G_MISS_NUM
    THEN
      OPEN C_Prim_Int_Code_Exists ( p_primary_interest_code_id,
                                    p_interest_type_id);
      FETCH C_Prim_Int_Code_Exists INTO l_variable;

      IF (C_Prim_Int_Code_Exists%NOTFOUND)
      THEN
        IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_Msg_Lvl_Error)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'PRIMARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_primary_interest_code_id, FALSE);
          FND_MSG_PUB.Add;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
        CLOSE C_Prim_Int_Code_Exists;
    END IF;


    IF p_secondary_interest_code_id is NOT NULL
    and p_secondary_interest_code_id <> FND_API.G_MISS_NUM
    THEN
      OPEN C_Sec_Int_Code_Exists (p_secondary_interest_code_id,
                                  p_primary_interest_code_id,
                                  p_interest_type_id);
      FETCH C_Sec_Int_Code_Exists INTO l_variable;
      IF (C_Sec_Int_Code_Exists%NOTFOUND)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'SECONDARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_secondary_interest_code_id, FALSE);
          FND_MSG_PUB.ADD;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE C_Sec_Int_Code_Exists;
    END IF;

    p_return_status := l_return_status;

  END Validate_Int_Type_Fields;

  -- Procedure validates interest status and returns SUCCESS if status is
  -- valid, ERROR otherwise
  -- Procedure assumes that at least the interest type exists
  --
  PROCEDURE Validate_Int_Status (  p_interest_type_id            IN  NUMBER,
                                   p_primary_interest_code_id    IN  NUMBER,
                                   p_secondary_interest_code_id  IN  NUMBER,
                                   p_interest_status_code        IN  VARCHAR2,
                                   p_return_status               OUT NOCOPY VARCHAR2
                                )
  Is
    CURSOR C_Int_Status_Exists (X_Int_Status_Code Varchar2,
                                X_Int_Type_Id Number) IS
      SELECT  'X'
      FROM  As_Interest_Statuses
      WHERE Interest_Type_Id = X_Int_Type_Id
        And Interest_Status_Code = X_Int_Status_Code;

    l_variable VARCHAR2(1);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  Begin

    IF p_interest_status_code is NOT NULL
    and p_interest_status_code <> FND_API.G_MISS_CHAR
    THEN
      OPEN C_Int_Status_Exists (p_interest_status_code,
      p_interest_type_id);
      FETCH C_Int_Status_Exists INTO l_variable;
      IF (C_Int_Status_Exists%NOTFOUND)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_STATUS', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_interest_status_code, FALSE);
          FND_MSG_PUB.ADD;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE C_Int_Status_Exists;
    END IF;

    p_return_status := l_return_status;

  END Validate_Int_Status;

  -- Procedure validates interest status for product catalog and returns SUCCESS if status is
  -- valid, ERROR otherwise
  -- Procedure assumes that at least the product category exists
  --
  PROCEDURE Validate_Int_Status_For_PC (  p_product_category_id         IN  NUMBER,
                                          p_product_cat_set_id          IN  NUMBER,
                                          p_interest_status_code        IN  VARCHAR2,
                                          p_return_status               OUT NOCOPY VARCHAR2
                                        )
  Is
    CURSOR C_Int_Status_Exists (X_Int_Status_Code Varchar2,
                                X_Product_Category_Id Number,
                                X_Product_Cat_Set_Id Number) IS
      SELECT  'X'
      FROM  As_Interest_Statuses
      WHERE Product_Category_Id = X_Product_Category_Id
        And Product_Cat_Set_Id = X_Product_Cat_Set_Id
        And Interest_Status_Code = X_Int_Status_Code;

    l_variable VARCHAR2(1);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  Begin

    IF p_interest_status_code is NOT NULL
    and p_interest_status_code <> FND_API.G_MISS_CHAR
    THEN
      OPEN C_Int_Status_Exists (p_interest_status_code,
      p_product_category_id, p_product_cat_set_id);
      FETCH C_Int_Status_Exists INTO l_variable;
      IF (C_Int_Status_Exists%NOTFOUND)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
          FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_STATUS', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_interest_status_code, FALSE);
          FND_MSG_PUB.ADD;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE C_Int_Status_Exists;
    END IF;

    p_return_status := l_return_status;

  END Validate_Int_Status_For_PC;

END AS_INTEREST_PVT;

/
