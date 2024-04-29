--------------------------------------------------------
--  DDL for Package Body ASO_PARTY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PARTY_INT" as
/* $Header: asoiptyb.pls 120.4.12010000.15 2015/02/13 08:14:19 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_PARTY_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- Changes made : 10/15/02 By Suyog Kulkarni
-- Changed calls to some TCA API's as per new packages in Version 2 TCA API's.
-- The following procedures were modified as part of version 2 changes
-- 1) Create_Customer_Account
-- 2) Create_Acct_Site
-- 3) Create_Acct_Site_Use
-- 4) Create_Contact
-- 5) Create_Contact_Role
-- 6) Create_Org_Contact_ord
-- 7) Create_Party_Site_Use
-- 8) Create_Cust_Acct_Relationship
-- 9) Update_Party

--Removed the following procedures as they are no longer being used:
--1) Create_Org_Contact
--2) Create_Contact_Points
--3)Create_Contact_Restriction
--4) Update_Party_Site
--5) update_Org_Contact
--6) Update_Contact_Points
--7) Update_Contact_Restriction

-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_PARTY_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiptyb.pls';

PROCEDURE Create_Party(
        p_party_rec             IN      PARTY_REC_TYPE,
        x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_party_id              OUT NOCOPY /* file.sql.39 change */   NUMBER)
IS
    l_api_name          VARCHAR2(40) := 'Create_Party';
   -- l_organization_rec  HZ_PARTY_PUB.Organization_Rec_Type;
   l_organization_rec  HZ_PARTY_V2PUB.Organization_Rec_Type;
    l_party_number      NUMBER;
    l_profile_id        NUMBER;
   -- l_person_rec        HZ_PARTY_PUB.Person_Rec_Type;
    l_person_rec              HZ_PARTY_V2PUB.person_rec_type;
    --l_party_rec     HZ_PARTY_PUB.Party_Rec_Type := HZ_PARTY_PUB.G_MISS_PARTY_REC;
    l_party_rec      HZ_PARTY_V2PUB.party_rec_type :=  HZ_PARTY_V2PUB.G_MISS_PARTY_REC;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
BEGIN
    SAVEPOINT CREATE_PARTY_PVT;
    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   l_person_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   l_organization_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';

  -- Column has been removed in version 2 api
    --l_party_rec.TOTAL_NUM_OF_ORDERS := 0;

    IF p_party_rec.party_type = 'ORGANIZATION'
                AND p_party_rec.party_name IS NOT NULL
                AND p_party_rec.party_name <> FND_API.G_MISS_CHAR THEN
        l_organization_rec.organization_name := p_party_rec.party_name;
        l_organization_rec.curr_fy_potential_revenue := p_party_rec.curr_fy_potential_revenue;
        l_organization_rec.employees_total  := p_party_rec.num_of_employees;
           l_organization_rec.party_rec        := l_party_rec;
/*
   The call to this api has been moved to a diff package in version 2 api
   Original Call:		 HZ_PARTY_PUB.Create_Organization
*/

    HZ_PARTY_V2PUB.create_organization (
    p_init_msg_list                    => FND_API.G_FALSE,
    p_organization_rec                 => l_organization_rec,
    x_return_status                    => x_return_status,
    x_msg_count                        => x_msg_count,
    x_msg_data                         => x_msg_data,
    x_party_id                         => x_party_id,
    x_party_number                     => l_party_number,
    x_profile_id                       => l_profile_id );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_party:after create_org:x_party_id '||x_party_id, 1, 'N');
aso_debug_pub.add('create_party:after create_org:x_return_status '||x_return_status, 1, 'N');
END IF;
    ELSIF p_party_rec.party_type = 'PERSON'
                AND p_party_rec.person_first_name IS NOT NULL
                AND p_party_rec.person_first_name <> FND_API.G_MISS_CHAR THEN
/*
   Column Names have been changed in version 2 api's

        l_person_rec.pre_name_adjunct := p_party_rec.person_title;
        l_person_rec.first_name := p_party_rec.person_first_name;
        l_person_rec.middle_name := p_party_rec.person_middle_name;
        l_person_rec.last_name := p_party_rec.person_last_name;
*/

        l_person_rec.person_pre_name_adjunct := p_party_rec.person_title;
        l_person_rec.person_first_name := p_party_rec.person_first_name;
        l_person_rec.person_middle_name := p_party_rec.person_middle_name;
        l_person_rec.person_last_name := p_party_rec.person_last_name;
        l_person_rec.known_as  := p_party_rec.person_known_as;
        l_person_rec.date_of_birth := p_party_rec.date_of_birth;
        l_person_rec.personal_income := p_party_rec.personal_income;
           l_person_rec.party_rec       := l_party_rec;
/*
   The call to this api has been moved to a diff package in version 2 api

   Original Call:        HZ_PARTY_PUB.Create_Person
*/

    HZ_PARTY_V2PUB.create_person (
    p_init_msg_list                    => FND_API.G_FALSE,
    p_person_rec                       => l_person_rec,
    x_party_id                         => x_party_id,
    x_party_number                     => l_party_number,
    x_profile_id                       => l_profile_id,
    x_return_status                    => x_return_status,
    x_msg_count                        => x_msg_count,
    x_msg_data                         => x_msg_data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_party:after create_per:x_return_status '||x_return_status, 1, 'N');
aso_debug_pub.add('create_party:after create_per:x_party_id '||x_party_id, 1, 'N');
END IF;
    END IF;
    if  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Party;

PROCEDURE Create_Party_Site(
        p_party_site_rec        IN      PARTY_SITE_REC_TYPE,
        x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_party_site_id         OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

   /* CURSOR c_site_use_type(p_type_name VARCHAR2) IS
        SELECT site_use_type_id FROM HZ_SITE_USE_TYPES
        WHERE name = p_type_name;*/

    l_api_name                  VARCHAR2(40) := 'Create_Party_Site';
    l_site_use_type_id          NUMBER;
--    l_location_rec              HZ_LOCATION_PUB.Location_Rec_Type;
      l_location_rec              HZ_LOCATION_V2PUB.Location_Rec_Type;
      l_location_id               NUMBER;
--    l_site_use_type_rec         HZ_PARTY_PUB.SITE_USE_TYPE_REC_TYPE;

--  Record definitions have been moved to a diff package in version 2 api
    --l_party_site_rec            HZ_PARTY_PUB.Party_Site_Rec_Type;
    --l_party_site_use_rec        HZ_PARTY_PUB.Party_Site_Use_Rec_Type;
    l_party_site_rec            HZ_PARTY_SITE_V2PUB.Party_Site_Rec_Type;
    l_party_site_use_rec        HZ_PARTY_SITE_V2PUB.Party_Site_Use_Rec_Type;

    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_party_site_use_id         NUMBER;
    l_party_site_number         NUMBER;

BEGIN
    SAVEPOINT CREATE_PARTY_SITE_PVT;
    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


-- Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   l_party_site_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   l_party_site_use_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   l_location_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';


    l_location_rec.address1 := p_party_site_rec.location.address1;
    l_location_rec.address2 := p_party_site_rec.location.address2;
    l_location_rec.address3 := p_party_site_rec.location.address3;
    l_location_rec.address4 := p_party_site_rec.location.address4;
    l_location_rec.country      := p_party_site_rec.location.country;
    l_location_rec.city        := p_party_site_rec.location.city;
    l_location_rec.postal_code := p_party_site_rec.location.postal_code;
    l_location_rec.state       := p_party_site_rec.location.state;
    l_location_rec.province    := p_party_site_rec.location.province;
    l_location_rec.county      := p_party_site_rec.location.county;


    l_location_rec.ORIG_SYSTEM_REFERENCE := -1;
    l_location_rec.CONTENT_SOURCE_TYPE := 'USER_ENTERED';

/*
 The call to this api has been moved to a diff package in version 2 api
 Original Call:    HZ_LOCATION_PUB.Create_Location

*/

    HZ_LOCATION_V2PUB.create_location (
    p_init_msg_list                    =>  FND_API.G_FALSE,
    p_location_rec                      => l_location_rec,
    x_location_id                       => l_location_id,
    x_return_status                    => x_return_status,
    x_msg_count                        => x_msg_count ,
    x_msg_data                          => x_msg_data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_party_site:after create_loc:l_location_id '||l_location_id, 1, 'N');
aso_debug_pub.add('create_party_site:after create_loc:x_return_status '||x_return_status, 1, 'N');
END IF;
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

        l_party_site_rec.party_id := p_party_site_rec.party_id;
        l_party_site_rec.location_id := l_location_id;
        l_party_site_rec.identifying_address_flag := p_party_site_rec.primary_flag;

/*
  The call to this api has been moved to a diff package in version 2 api
  Original Call:      HZ_PARTY_PUB.Create_Party_Site
*/

    HZ_PARTY_SITE_V2PUB.create_party_site (
    p_init_msg_list                 => FND_API.G_FALSE,
    p_party_site_rec                => l_party_site_rec,
    x_party_site_id                 => x_party_site_id,
    x_party_site_number             => l_party_site_number,
    x_return_status                 => x_return_status,
    x_msg_count                     => x_msg_count,
    x_msg_data                      => x_msg_data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_party_site:after create_site:x_party_site_id '||x_party_site_id, 1, 'N');
aso_debug_pub.add('create_party_site:after create_site:x_return_status '||x_return_status, 1, 'N');
END IF;
     else
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

         l_party_site_use_rec.party_site_id := x_party_site_id;
   --      l_party_site_use_rec.begin_date    := sysdate;
         l_party_site_use_rec.site_use_type := p_party_site_rec.party_site_use_type;

/*
  The call to this api has been moved to a diff package in version 2 api

  Original Call:       HZ_PARTY_PUB.Create_Party_Site_Use
*/

    HZ_PARTY_SITE_V2PUB.create_party_site_use (
    p_init_msg_list                 => FND_API.G_FALSE,
    p_party_site_use_rec            => l_party_site_use_rec,
    x_party_site_use_id             => l_party_site_use_id,
    x_return_status                 => x_return_status,
    x_msg_count                     => x_msg_count,
    x_msg_data                      => x_msg_data );


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_party_site:after create_site_use:x_return_status '||x_return_status, 1, 'N');
aso_debug_pub.add('create_party_site:after create_site_use:l_party_site_use_id '||l_party_site_use_id, 1, 'N
');
END IF;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      else
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Party_Site;

PROCEDURE Update_Party(
        p_party_rec                 IN PARTY_REC_TYPE,
        x_return_status             OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_msg_count                 OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data                  OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
l_api_name         VARCHAR2(40) := 'Update_Party' ;
/*  The record defintions have been moved to a diff package in version 2 api.
l_Person_rec       HZ_PARTY_PUB.Person_rec_Type DEFAULT HZ_PARTY_PUB.G_MISS_PERSON_REC;
l_Organization_rec HZ_PARTY_PUB.Organization_rec_Type;
l_party_rec        HZ_PARTY_PUB.Party_rec_Type := HZ_PARTY_PUB.G_MISS_PARTY_REC;
*/
l_Person_rec       HZ_PARTY_V2PUB.Person_rec_Type; /*  DEFAULT HZ_PARTY_V2PUB.G_MISS_PERSON_REC; */
l_Organization_rec HZ_PARTY_V2PUB.Organization_rec_Type;
l_party_rec        HZ_PARTY_V2PUB.Party_rec_Type; /* := HZ_PARTY_V2PUB.G_MISS_PARTY_REC; */

l_Party_Id                          NUMBER;

/* The record definition has been moved as part of version 2 api
l_party_rel_rec    HZ_PARTY_PUB.PARTY_REL_REC_TYPE
                  := HZ_PARTY_PUB.G_MISS_PARTY_REL_REC;
*/

l_party_object_version_number      NUMBER;
l_object_version_number            NUMBER;
l_party_rel_rec    HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE
                  :=  HZ_RELATIONSHIP_V2PUB.G_MISS_REL_REC;
l_profile_id       NUMBER;
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_party_relationship_id  number;

l_last_update_date DATE;
l_party_rel_last_update_date DATE;
begin
   SAVEPOINT UPDATE_PARTY_PVT;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Initializing the created_by_module column for all the records as per
 -- changes in version 2 api's.

    l_person_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
    l_organization_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';

  --l_party_rec.TOTAL_NUM_OF_ORDERS := p_party_rec.TOTAL_NUM_OF_ORDERS;
  if p_party_rec.PARTY_TYPE = 'PERSON' then
    l_person_rec.party_rec             :=  l_party_rec;
    IF p_party_rec.party_id <> FND_API.G_MISS_NUM THEN
    l_person_rec.party_rec.party_id    :=  p_party_rec.party_id;
    END IF;
    IF p_party_rec.person_first_name <> FND_API.G_MISS_CHAR THEN
    l_person_rec.person_FIRST_NAME            :=  p_party_rec.person_first_name;
    END IF;
    IF p_party_rec.person_middle_name <> FND_API.G_MISS_CHAR THEN
    l_person_rec.person_MIDDLE_NAME           :=  p_party_rec.person_middle_name;
    END IF;
    IF p_party_rec.person_last_name <> FND_API.G_MISS_CHAR THEN
    l_person_rec.person_LAST_NAME             :=  p_party_rec.person_last_name;
    END IF;
    IF p_party_rec.person_title <> FND_API.G_MISS_CHAR THEN
    l_person_rec.person_TITLE                 :=  p_party_rec.person_title;
    END IF;
    IF p_party_rec.DATE_OF_BIRTH <> FND_API.G_MISS_DATE THEN
    l_person_rec.DATE_OF_BIRTH         :=  p_party_rec.DATE_OF_BIRTH;
    END IF;
    IF p_party_rec.person_known_as <> FND_API.G_MISS_CHAR THEN
    l_person_rec.KNOWN_AS              :=  p_party_rec.person_known_as;
    END IF;
    IF p_party_rec.PERSONAL_INCOME <> FND_API.G_MISS_NUM THEN
    l_person_rec.PERSONAL_INCOME       :=  p_party_rec.PERSONAL_INCOME;
    END IF;
    l_last_update_date                 :=  p_party_rec.LAST_UPDATE_DATE;

/*
 The call to the api has been moved to a diff package in version 2 api
 Original Call:   HZ_PARTY_PUB.update_person
*/

-- Getting the object version number
-- This is used by API to lock the object being updated

        BEGIN
        -- Intialize the variable as it used multiple times in this procedure
        l_party_object_version_number := FND_API.G_MISS_NUM;

        SELECT OBJECT_VERSION_NUMBER
        INTO   l_party_object_version_number
        FROM   HZ_PARTIES
        WHERE  PARTY_ID = p_party_rec.party_id;

        EXCEPTION
        WHEN OTHERS THEN
        l_party_object_version_number := FND_API.G_MISS_NUM;
        END;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('update_pty:before update_per', 1, 'N');
aso_debug_pub.add('update_pty:object_version_number  '||l_party_object_version_number, 1, 'N');
END IF;

HZ_PARTY_V2PUB.update_person (
    p_init_msg_list                    => FND_API.G_FALSE,
    p_person_rec                       => l_PERSON_REC,
    p_party_object_version_number      => l_party_object_version_number,
    x_profile_id                       => l_profile_id,
    x_return_status                    => x_return_status,
    x_msg_count                        => x_msg_count ,
    x_msg_data                         => x_msg_data
);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('update_pty:after update_per:x_return_status '||x_return_status, 1, 'N');
aso_debug_pub.add('update_pty:after update_per:p_party_rec.party_id '||p_party_rec.party_id, 1, 'N');
END IF;

  elsif p_party_rec.party_type =  'ORGANIZATION' THEN
--        AND p_party_rec.party_name IS NOT NULL
--        AND p_party_rec.party_name <> FND_API.G_MISS_CHAR THEN
    l_organization_rec.party_rec         := l_party_rec;
    l_organization_rec.party_rec.party_id   := p_party_rec.party_id;
--    l_organization_rec.ORGANIZATION_NAME    := p_party_rec.party_name;
    l_organization_rec.CURR_FY_POTENTIAL_REVENUE    := p_party_rec.CURR_FY_POTENTIAL_REVENUE;
    l_organization_rec.EMPLOYEES_TOTAL      := p_party_rec.num_of_employees;

    l_last_update_date     := p_party_rec.last_update_date;

/*
 The call to this api has been moved to a diff package in version 2 api
 Original Call:   HZ_PARTY_PUB.update_organization
*/

-- Getting the object version number
-- This is used by API to lock the object being updated

        BEGIN
        -- Intialize the variable as it used multiple times in this procedure
        l_party_object_version_number := FND_API.G_MISS_NUM;

        SELECT OBJECT_VERSION_NUMBER
        INTO   l_party_object_version_number
        FROM   HZ_PARTIES
        WHERE  PARTY_ID = p_party_rec.party_id;

        EXCEPTION
        WHEN OTHERS THEN
        l_party_object_version_number := FND_API.G_MISS_NUM;
        END;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('update_pty:before update_organization', 1, 'N');
aso_debug_pub.add('update_pty:object_version_number  '||l_party_object_version_number, 1, 'N');
END IF;


HZ_PARTY_V2PUB.update_organization (
    p_init_msg_list                    => FND_API.G_FALSE,
    p_organization_rec                 => l_organization_rec ,
    p_party_object_version_number      => l_party_object_version_number,
    x_profile_id                       => l_profile_id ,
    x_return_status                    => x_return_status ,
    x_msg_count                        => x_msg_count ,
    x_msg_data                         => x_msg_data
);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('update_pty:after update_org:x_return_status '||x_return_status, 1, 'N');
aso_debug_pub.add('update_pty:after update_org:p_party_rec.party_id '||p_party_rec.party_id, 1, 'N');
END IF;
  elsif p_party_rec.party_type = 'PARTY_RELATIONSHIP' THEN
    l_party_rel_rec.party_rec := l_party_rec;
    l_party_rel_rec.party_rec.party_id := p_party_rec.party_id;
    l_last_update_date                 :=  p_party_rec.LAST_UPDATE_DATE;

    SELECT last_update_date, relationship_id
    INTO l_party_rel_last_update_date,l_party_relationship_id
    from hz_relationships
    where party_id = p_party_rec.party_id
    and SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    and OBJECT_TABLE_NAME(+) = 'HZ_PARTIES';


    l_party_rel_rec.relationship_id := l_party_relationship_id;

/*
   The call to this api has been moved to a diff package in version 2 api
   Original Call:  HZ_PARTY_PUB.update_party_relationship

*/

-- Getting the object version number
-- This is used by API to lock the object being updated

        BEGIN
        -- Intialize the variable as it used multiple times in this procedure
        l_party_object_version_number := FND_API.G_MISS_NUM;

        SELECT OBJECT_VERSION_NUMBER
        INTO   l_party_object_version_number
        FROM   HZ_PARTIES
        WHERE  PARTY_ID = p_party_rec.party_id;

        SELECT OBJECT_VERSION_NUMBER
        INTO   l_object_version_number
        FROM   HZ_RELATIONSHIPS
        WHERE  RELATIONSHIP_ID  = l_party_relationship_id
        AND    DIRECTIONAL_FLAG = 'F';

        EXCEPTION
        WHEN OTHERS THEN
        l_party_object_version_number := FND_API.G_MISS_NUM;
        l_object_version_number := FND_API.G_MISS_NUM;
        END;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('update_pty:before update_reltn', 1, 'N');
aso_debug_pub.add('update_pty:object_version_number  '||l_party_object_version_number, 1, 'N');
END IF;

HZ_RELATIONSHIP_V2PUB.update_relationship (
    p_init_msg_list               =>  FND_API.G_FALSE,
    p_relationship_rec            => l_party_rel_rec ,
    p_object_version_number       => l_object_version_number,
    p_party_object_version_number => l_party_object_version_number,
    x_return_status               => x_return_status,
    x_msg_count                   => x_msg_count,
    x_msg_data                    => x_msg_data
);



IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('update_pty:after update_reltn:x_return_status '||x_return_status, 1, 'N');
aso_debug_pub.add('update_pty:after update_reltn:p_party_rec.party_id '||p_party_rec.party_id, 1, 'N');
END IF;
  end if; -- end party type

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
           ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  -- End of API body
  --
end Update_Party;

PROCEDURE Validate_CustAccount(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_cust_account_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
    CURSOR C_Account IS
	SELECT status, account_activation_date, account_termination_date FROM HZ_CUST_ACCOUNTS
	WHERE cust_account_id = p_cust_account_id;

    l_api_name          VARCHAR2(40) := 'Validate_CustAccount' ;
    l_account_status	VARCHAR2(1);
    l_activation_date	DATE;
    l_termination_date		DATE;
BEGIN
    SAVEPOINT VALIDATE_CUSTACCOUNT_PVT;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('validate cust_acct:p_cust_account_id '||p_cust_account_id, 1, 'N');
END IF;
    IF (p_cust_account_id IS NOT NULL AND p_cust_account_id <> FND_API.G_MISS_NUM) THEN
        OPEN C_Account;
	FETCH C_Account INTO l_account_status, l_activation_date, l_termination_date;
        IF (C_Account%NOTFOUND OR
	    (sysdate NOT BETWEEN NVL(l_activation_date, sysdate) AND
						NVL(l_termination_date, sysdate))OR
			l_account_status <> 'A') THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		    FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
		    FND_MESSAGE.Set_Token('COLUMN', 'CUST_ACCOUNT', FALSE);
		    FND_MSG_PUB.ADD;
	       END IF;
        END IF;
	    CLOSE C_Account;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('validate cust_acct:x_return_status '||x_return_status, 1, 'N');
END IF;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Validate_CustAccount;


PROCEDURE Create_Customer_Account(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,P_Qte_REC   IN ASO_QUOTE_PUB.Qte_Header_Rec_Type
  ,P_Account_number IN NUMBER := FND_API.G_MISS_NUM
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_acct_id           OUT NOCOPY /* file.sql.39 change */   NUMBER
    )
   IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(45) := 'Create_Customer_Account';

       CURSOR C_source_codes(l_source_code_id NUMBER) Is
         SELECT source_code
         FROM ams_source_codes
         WHERE source_code_id = l_source_code_id;

       CURSOR C_party_info (l_party_id NUMBER) IS
         SELECT party_type, party_name
         FROM hz_parties
         WHERE party_id = l_party_id;

       CURSOR C_acct_number IS
         SELECT aso_account_number_s.nextval
         FROM  dual;

       CURSOR c_party_rel_rec(l_party_id NUMBER) IS
        SELECT object_id from
        hz_relationships
        where party_id = l_party_id
        and SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
        and OBJECT_TABLE_NAME(+) = 'HZ_PARTIES';

-- The record definitions have been moved to a different package in version 2 api
--      account_rec	        hz_customer_accounts_pub.account_rec_type;
        account_rec	        HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;

--	   person_rec              hz_party_pub.person_rec_type;
        person_rec              HZ_PARTY_V2PUB.person_rec_type;

--      organization_rec        hz_party_pub.organization_rec_type;
        organization_rec        HZ_PARTY_V2PUB.organization_rec_type;

--	   cust_profile_rec	       hz_customer_accounts_pub.cust_profile_rec_type;
        cust_profile_rec	       HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;

--	   p_party_rec		hz_party_pub.party_rec_type;
        p_party_rec      HZ_PARTY_V2PUB.party_rec_type;

        l_acct_id               NUMBER;
        l_account_number        VARCHAR2(30);
        l_party_id              NUMBER;
        l_party_number          VARCHAR2(30);
        l_party_name          VARCHAR2(360);
	   l_profile_id		NUMBER;
        l_return_status  VARCHAR2(1);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(2000);
        l_gen_cust_num          VARCHAR2(3);
        l_party_type            VARCHAR2(30);
        customer_party_id     NUMBER;

    BEGIN
---- Initialize---------------------

     SAVEPOINT CREATE_CUSTOMER_ACCOUNT_PVT;

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
x_return_status := FND_API.g_ret_sts_success;

-- Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   account_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   person_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   organization_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   cust_profile_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';

-- if needed generate account_number.
	SELECT generate_customer_number INTO l_gen_cust_num
	FROM ar_system_parameters;

-- typically should be set to 'Y' if no we will try to create a new one.
-- however, this could error out

        IF l_gen_cust_num = 'N' and p_account_number <> FND_API.G_MISS_NUM THEN

               account_rec.account_number := p_account_number;

        ELSIF l_gen_cust_num = 'N'
              and ( p_account_number = FND_API.G_MISS_NUM
              or p_account_number is null) THEN

               OPEN C_acct_number;
               FETCH C_acct_number into  account_rec.account_number;
               CLOSE C_acct_number;

               account_rec.account_number := 'ASO'||account_rec.account_number;

        END IF;

-- figure OUT NOCOPY /* file.sql.39 change */ if the party is a person or an organization

     OPEN C_party_info(p_qte_rec.party_id);
       FETCH C_party_info INTO l_party_type, l_party_name;
       IF (C_party_info%NOTFOUND) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'PARTY ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
       END IF;
       CLOSE C_party_info;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create cust_acct:l_party_type '||l_party_type, 1, 'N');
aso_debug_pub.add('create cust_acct:l_party_name '||l_party_name, 1, 'N');
END IF;
    IF l_party_type = 'PARTY_RELATIONSHIP' THEN
      OPEN c_party_rel_rec(p_qte_rec.party_id);
      FETCH c_party_rel_rec INTO customer_party_id;
      CLOSE c_party_rel_rec;

      OPEN C_party_info(Customer_Party_id);
	 FETCH C_party_info INTO l_party_type, l_party_name;
	 CLOSE C_party_info;

    ELSE
      customer_party_id := p_qte_rec.party_id;
    END IF;
--    account_rec.cust_account_id :=null;
--    account_rec.status := 'I';

account_rec.account_name := substr(l_party_name,1,240);

-- if marketing source code is valid then pass the source code
    IF p_qte_rec.marketing_source_code is not NULL
      AND p_qte_rec.marketing_source_code_id <> FND_API.G_MISS_NUM THEN

         OPEN C_source_codes( p_qte_rec.marketing_source_code_id);
         FETCH C_source_codes INTO account_rec.source_code;
         IF (C_source_codes%NOTFOUND) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_INFO');
              FND_MESSAGE.Set_Token('COLUMN', 'SOURCE CODES', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
        END IF;
        CLOSE C_source_codes;

      END IF;  -- source codes

   -- will test this for patch set C
    --account_rec.payment_term_id  := to_number(FND_PROFILE.VALUE('ASO_PAYMENT_TERM'));

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create cust_acct:l_party_type '||l_party_type, 1, 'N');
aso_debug_pub.add('create cust_acct:account_rec.account_name '||account_rec.account_name, 1, 'N');
END IF;
-- if party is a person
    IF l_party_type = 'PERSON' THEN

      person_rec.party_rec := p_party_rec;
      person_rec.party_rec.party_id := customer_party_id;
/*
      The call to create_account procedure has been moved to
      a new package in TCA version 2 API's

     Original Call:  hz_customer_accounts_pub.create_account
*/

      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
      p_init_msg_list                         => FND_API.G_FALSE,
      p_cust_account_rec                      => account_rec,
      p_person_rec                            => person_rec,
      p_customer_profile_rec                  => cust_profile_rec,
      p_create_profile_amt                    => 'Y',
      x_cust_account_id                       => l_acct_id,
      x_account_number                        => l_account_number,
      x_party_id                              => l_party_id	,
      x_party_number                          => l_party_number,
      x_profile_id                            => l_profile_id,
      x_return_status                         => l_return_status,
      x_msg_count                             => l_msg_count,
      x_msg_data                              => l_msg_data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create cust_acct:after create_acct:l_acct_id '||l_acct_id, 1, 'N');
END IF;

-- if party is an organization
     ELSIF l_party_type = 'ORGANIZATION' THEN

        organization_rec.party_rec := p_party_rec;
        organization_rec.party_rec.party_id := customer_party_id;
/*
      The call to create_account procedure has been moved to
      a new package in TCA version 2 API's

      Original Call:  hz_customer_accounts_pub.create_account
*/
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
      p_init_msg_list                         => FND_API.G_FALSE,
      p_cust_account_rec                      => account_rec,
      p_organization_rec                      => organization_rec,
      p_customer_profile_rec                  => cust_profile_rec,
      p_create_profile_amt                    => 'Y',
      x_cust_account_id                       => l_acct_id,
      x_account_number                        => l_account_number,
      x_party_id                              => l_party_id	,
      x_party_number                          => l_party_number,
      x_profile_id                            => l_profile_id,
      x_return_status                         => l_return_status,
      x_msg_count                             => l_msg_count,
      x_msg_data                              => l_msg_data  );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create cust_acct:after create_acct:l_acct_id '||l_acct_id, 1, 'N');
END IF;
    END IF;


    IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'ACCT ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
    ELSE
     x_acct_id  := l_acct_id;
    END IF;
 FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

 END Create_Customer_Account;


PROCEDURE Create_ACCT_SITE ( p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_Cust_Account_Id NUMBER
  ,p_Party_Site_Id NUMBER
  ,p_Acct_site     VARCHAR2 := 'NONE'
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_customer_site_id  OUT NOCOPY /* file.sql.39 change */   NUMBER
   )
    IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'Create_ACCT_SITE';

 -- acct site need not be verified

       CURSOR C_acct_site (account_id NUMBER, site_id NUMBER) IS
           SELECT cust_acct_site_id
           FROM hz_cust_acct_sites
           WHERE cust_account_id = Account_Id
           AND party_site_id    = Site_Id;
-- The record definition has been moved to a diff. package in VERSION 2 API.
--        p_acct_site_Rec           hz_customer_accounts_pub.acct_site_rec_type;
          p_acct_site_Rec           HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;

		l_customer_site_id        NUMBER := NULL;

  BEGIN
   ---- Initialize---------------------

   SAVEPOINT CREATE_ACCT_SITE_PVT;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
 IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
    x_return_status := FND_API.g_ret_sts_success;

 -- Intializing created_by_module as required in version 2 api for the record structure

   p_acct_site_Rec.created_by_module := 'ASO_CUSTOMER_DATA';


    Open C_acct_site (p_cust_account_id, p_party_site_id);
    Fetch C_acct_site into l_customer_site_id;
    IF (C_acct_site%NOTFOUND) THEN
      l_customer_site_id := null;
    END IF;
    Close C_acct_site;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site:before create_site:l_customer_site_id '||l_customer_site_id, 1, 'N');
END IF;
    IF l_customer_site_id is not NULL THEN
       x_customer_site_id :=  l_customer_site_id ;
    ELSE
    p_acct_site_rec.cust_account_id := P_cust_account_id;
    p_acct_site_rec.party_site_id   := P_party_site_id;
/*
      The call to create_account_site procedure has been moved to
      a new package in TCA version 2 API's

    Original Call: hz_customer_accounts_pub.create_account_site
*/

    HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_acct_site_rec                    => p_acct_site_rec,
    x_cust_acct_site_id                     => l_customer_site_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site:after create_site:l_customer_site_id '||l_customer_site_id, 1, 'N');
aso_debug_pub.add('create acct_site:after create_site:x_return_status '||x_return_status, 1, 'N');
END IF;
    IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'ACCT SITE', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
    ELSE
           x_customer_site_id :=  l_customer_site_id ;
    END IF;

   END IF; -- customer site id not nul
   FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
  END Create_acct_site;


PROCEDURE Create_ACCT_SITE_USES (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
-- ,p_validation_level IN  NUMBER    := FND_API.g_valid_level_full
  ,P_Cust_Account_Id   IN  NUMBER
  ,P_Party_Site_Id     IN  NUMBER
  ,P_cust_acct_site_id IN  NUMBER    := NULL
  ,P_Acct_Site_type    IN  VARCHAR2  := 'NONE'
  ,x_cust_acct_site_id OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_site_use_id  OUT NOCOPY /* file.sql.39 change */   NUMBER
  )
     IS
       CURSOR C_site_use(acct_site_id NUMBER, Site_type VARCHAR2) IS
         SELECT site_use_id
         FROM hz_cust_site_uses
         WHERE cust_acct_site_id = acct_site_id
         AND site_use_code = Site_type
         AND status = 'A';

       CURSOR party_site_use(l_party_site_id NUMBER, Site_type VARCHAR2) IS
         SELECT party_site_use_id
         FROM hz_party_site_uses
         WHERE party_site_id = l_party_site_id
         AND site_use_type = Site_type
         AND status = 'A';

-- this is arbitrary. we are doing it because location is needed for site uses.
       CURSOR C_location(l_party_site_id NUMBER) IS
        Select hzl.city
        From hz_locations hzl,hz_party_sites hps
        Where hps.party_site_id = p_party_site_id
        And hzl.location_id = hps.location_id;


        l_api_version CONSTANT NUMBER       := 1.0;
        l_api_name    CONSTANT VARCHAR2(45) := 'Create_ACCT_SITE_USES';

        l_location          VARCHAR2(60);
--        p_acct_site_uses_Rec  hz_customer_accounts_pub.acct_site_uses_rec_type;
--    	p_cust_profile_rec    hz_customer_accounts_pub.cust_profile_rec_type;

--  The above two record types have been moved to diff. packages in VERSION 2 API's.

        p_acct_site_uses_Rec  HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
    	   p_cust_profile_rec    HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;

        l_site_use_id             NUMBER := NULL;


       l_Cust_Account_Id NUMBER  := p_Cust_Account_Id ;
       l_Party_Site_Id   NUMBER  := P_Party_Site_Id;
       l_Acct_Site_type VARCHAR2(30) := P_Acct_Site_type ;
       lx_party_site_use_id NUMBER;
       l_party_site_use number;
	  l_profile varchar2(1);
     BEGIN

        ---- Initialize---------------------

     SAVEPOINT CREATE_ACCT_SITE_USES_PVT;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
    ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;

 -- Intializing created_by_module as required in version 2 api for the record structure

    p_acct_site_uses_Rec.created_by_module := 'ASO_CUSTOMER_DATA';
    p_cust_profile_rec.created_by_module := 'ASO_CUSTOMER_DATA';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:p_cust_acct_site_id '||p_cust_acct_site_id, 1, 'N');
END IF;
	IF (p_cust_acct_site_id IS NULL) OR
	   (p_cust_acct_site_id = FND_API.G_MISS_NUM) THEN
           Create_ACCT_SITE(p_api_version       => 1.0
                        ,p_Cust_Account_Id  => l_cust_account_id
                        ,p_Party_Site_Id => l_party_site_id
                        ,p_Acct_site     => l_Acct_Site_type
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      =>   x_msg_data
                        ,x_customer_site_id  => x_cust_acct_site_id
                        ) ;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:after create_site:x_cust_acct_site_id '||x_cust_acct_site_id, 1, 'N');
END IF;
           IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
           END IF;
	END IF;

        IF x_cust_acct_site_id is not null and x_cust_acct_site_id <> FND_API.G_MISS_NUM then
          p_acct_site_uses_Rec.cust_acct_site_id := x_cust_acct_site_id;
        ELSE
          p_acct_site_uses_Rec.cust_acct_site_id := p_cust_acct_site_id;
	  x_cust_acct_site_id := p_cust_acct_site_id;
        END IF;

          p_acct_site_uses_Rec.site_use_code    := l_Acct_Site_type ;

       Open C_site_use(x_cust_acct_site_id,p_acct_site_uses_Rec.site_use_code);
         Fetch C_site_use into l_site_use_id;
         IF (C_site_use%NOTFOUND) THEN
              l_site_use_id := null;
         END IF;
         Close C_site_use;


         IF l_site_use_id is not NULL then
             x_site_use_id := l_site_use_id  ;
         ELSE

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:x_site_use_id '||x_site_use_id, 1, 'N');
END IF;
           OPEN C_location(l_party_site_id);
           FETCH C_location into l_location;
           IF (C_location%NOTFOUND) THEN
              l_location := 'NO_LOCATION';
           END IF;
           CLOSE C_location;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:l_location '||l_location, 1, 'N');
END IF;


--   added for bug 2291297
         SELECT AUTO_SITE_NUMBERING INTO l_profile
         FROM AR_SYSTEM_PARAMETERS;

     IF l_profile = 'N' then
           p_acct_site_uses_Rec.location := substr(l_Acct_Site_type ||' ' ||
								    l_location ||' ' ||
					 to_char(p_acct_site_uses_Rec.cust_acct_site_id), 1, 40) ;
     END IF;
            -- since this is the first site use rec create it as a primary
            /* don't flag address as primary. bug 1512188 */
            --    p_acct_site_uses_Rec.primary_flag := 'Y';
/*
 The call to create_acct_site_uses has been moved to a diff. package in VERSION 2 API's.

  Original Call:         hz_customer_accounts_pub.create_acct_site_uses
*/

    HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_site_use_rec                     => p_acct_site_uses_rec,
    p_customer_profile_rec                  => p_cust_profile_rec,
    p_create_profile                        => FND_API.G_FALSE,
    p_create_profile_amt                    => FND_API.G_FALSE,
    x_site_use_id                           => l_site_use_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:create_acct_site_use:x_return_status '||x_return_status, 1, 'N');
aso_debug_pub.add('create acct_site_use:create_acct_site_use:l_site_use_id '||l_site_use_id, 1, 'N');
END IF;

           IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'ACCT_SITE_USES', FALSE);
                FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
           ELSE
                x_site_use_id := l_site_use_id;
           END IF;
         END IF; -- x_site_use not null

        IF (l_party_site_id IS NOT NULL AND l_party_site_id <> FND_API.G_MISS_NUM) AND
           (l_acct_site_type IS NOT NULL AND l_acct_site_type <> FND_API.G_MISS_CHAR) THEN

           OPEN party_site_use(l_party_site_id,l_acct_site_type);
           FETCH party_site_use into l_party_site_use;
           CLOSE party_site_use;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:create_party_site_use:l_party_site_use '||l_party_site_use, 1, 'N');
END IF;
           IF l_party_site_use = NULL OR l_party_site_use = FND_API.G_MISS_NUM then
              Create_Party_Site_Use(
                p_api_version          => 1.0,
            	p_party_site_id	       => l_party_site_id,
                p_party_site_use_type  => l_acct_site_type,
            	x_party_site_use_id	   => lx_party_site_use_id,
           		x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create acct_site_use:create_party_site_use:lx_party_site_use_id '||lx_party_site_use_id, 1, 'N');
END IF;
           end if;
           IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
           END IF;
        END IF;
    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
        		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
   END Create_acct_site_uses;


PROCEDURE Create_Contact ( p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_party_id            IN  NUMBER    := NULL
  ,p_Org_Contact_Id      IN  NUMBER
  ,p_Cust_account_id     IN  NUMBER
  ,p_Role_type           IN       VARCHAR2 := 'CONTACT'
  ,p_Begin_date          IN DATE := sysdate
   ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */   NUMBER
     )
    IS


     CURSOR C_contact (l_party_id NUMBER, l_cust_account_id NumbER,
                       l_role_type varchar2 )IS
      SELECT cust_account_role_id
      FROM hz_cust_account_roles
      WHERE party_id = l_party_id
      AND cust_account_id = l_cust_account_id
      AND role_type = l_role_type;

     CURSOR C_party(l_org_contact_id NUMBER) IS
      SELECT par.party_id
      FROM hz_relationships par,
           hz_org_contacts     org
      WHERE org.party_relationship_id = par.relationship_id
      AND org.org_contact_id  = l_org_contact_id
	and par.subject_type = 'PERSON'
	 and par.subject_table_name ='HZ_PARTIES';

      l_api_version CONSTANT NUMBER       := 1.0;
      l_api_name    CONSTANT VARCHAR2(45) := 'Create_Contact';
      l_role_type               VARCHAR2(30);
      l_party_id                NUMBER;
--   The record definition has been moved to a new package in VERSION 2 API.
--   p_cust_acct_roles_rec  hz_customer_accounts_pub.cust_acct_roles_rec_type;
     p_cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;

	l_cust_account_role_id    NUMBER := NULL;


    BEGIN

        SAVEPOINT CREATE_CONTACT_PVT;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

-- Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   p_cust_acct_roles_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create con:p_party_id '||p_party_id, 1, 'N');
aso_debug_pub.add('create con:p_org_contact_id '||p_org_contact_id, 1, 'N');
END IF;
   l_party_id := p_party_id;
   IF l_party_id is  NULL
     OR  l_party_id = FND_API.G_MISS_NUM THEN

      IF p_org_contact_id is not NULL
       AND p_org_contact_id <> FND_API.G_MISS_NUM THEN

      OPEN C_party(p_org_contact_id);
      FETCH C_party INTO l_party_id;
         IF (C_party%NOTFOUND) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID FOR GIVEN ORG CONTACT', FALSE);
              FND_MSG_PUB.ADD;
            END IF;
          raise FND_API.G_EXC_ERROR;
         END IF;
      Close C_party;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create con:derive from org_contact:l_party_id '||l_party_id, 1, 'N');
END IF;

     END IF;   -- org contact id is not null
  END IF;      -- party id is null

  IF (l_party_id is not NULL AND l_party_id <>  FND_API.G_MISS_NUM) THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create con:l_party_id '||l_party_id, 1, 'N');
END IF;
 -- for now role type is always 'CONTACT'
     l_role_type := 'CONTACT';

-- check if the contact already exists. if not create it

        OPEN  C_contact (l_party_id, p_cust_account_id, l_role_type);
        FETCH C_contact INTO  l_cust_account_role_id;
           IF (C_contact%NOTFOUND) THEN
              l_cust_account_role_id := NULL;
           END IF;
        CLOSE  C_contact;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create con:l_cust_account_role_id '||l_cust_account_role_id, 1, 'N');
aso_debug_pub.add('create con:before create_acct_role:p_cust_account_id '||p_cust_account_id, 1, 'N');
END IF;

       IF  l_cust_account_role_id is not NULL THEN
           x_cust_account_role_id:= l_cust_account_role_id;
       ELSE

           p_cust_acct_roles_rec.party_id        := l_party_id;
           p_cust_acct_roles_rec.cust_account_id := p_cust_account_id;
           p_cust_acct_roles_rec.role_type       := l_role_type;

	-- The begin_date column has been deleted in record structure in version 2 api.
	--      p_cust_acct_roles_rec.begin_date       := p_begin_date;

/*
The call to create_cust_acct_roles has been moved to a new package in version 2 api.
 Original Call: hz_customer_accounts_pub.create_cust_acct_roles
*/

/*** Fix for R12.1.1 bug 12776643 ***/

  --  MO_GLOBAL.INIT('M');


    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_account_role_rec                 => p_cust_acct_roles_rec,
    x_cust_account_role_id                  => x_cust_account_role_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create con:after create_acct_role:x_cust_account_role_id '||x_cust_account_role_id, 1, 'N');
END IF;
             IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'ACCT_ROLE', FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
             ELSE
                x_cust_account_role_id:= l_cust_account_role_id;
             END IF;
       END IF;

  END IF; -- party and org are null


 FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

    END Create_Contact ;



-- this procedure is called only from the aso_order_int.
-- the return parameters are specific to the usage in aso_order_int


PROCEDURE Create_ORG_CONTACT_ord (
      p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_party_id NUMBER
  ,p_header_Party_Id NUMBER  := NULL
  ,p_acct_id  NUMBER         := NULL
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_org_contact_id    OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_party_id          OUT NOCOPY /* file.sql.39 change */   NUMBER
   )
     IS
     l_api_version CONSTANT NUMBER       := 1.0;
     l_api_name    CONSTANT VARCHAR2(45) := 'Create_ORG_CONTACT_ORD';

       Cursor C_org_contact (l_party_id NUMBER, l_header_party_id NUMBER) IS
        SELECT OC.org_contact_id
        FROM hz_org_contacts oc, hz_parties p, hz_relationships pr
        WHERE p.party_id = l_party_id
        AND p.party_id = pr.subject_id
        AND pr.object_id = l_header_party_id
        AND (pr.relationship_type = 'CONTACT'
           OR pr.relationship_type = 'CONTACT_OF')
        AND oc.party_relationship_id = pr.relationship_id;

        l_org_contact_id          NUMBER;
        l_header_party_id         NUMBER;
        -- p_org_contact_rec        hz_party_pub.org_contact_rec_type;
         p_org_contact_rec   HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
         x_party_rel_id           NUMBER;
         x_party_number           NUMBER;
         l_party_type             VARCHAR2(50);

     BEGIN
        SAVEPOINT CREATE_ORG_CONTACT_ORD_PVT;

        IF FND_API.to_boolean(p_init_msg_list) THEN
              FND_MSG_PUB.initialize;
        END IF;
         IF NOT FND_API.compatible_api_call(
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
            ) THEN
              RAISE FND_API.g_exc_unexpected_error;
         END IF;
         x_return_status := FND_API.g_ret_sts_success;

--Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

    p_org_contact_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';


       x_party_id := null;
       x_org_contact_id := null;
       l_header_party_id  := p_header_party_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create org_con_ord:l_header_party_id '||l_header_party_id, 1, 'N');
END IF;
        -- this is called if only account is passed and not the party
        IF l_header_party_id is NULL
               or l_header_party_id = FND_API.G_MISS_NUM THEN
             -- get the party id from acct id
           SELECT acct.party_id, par.party_type
           INTO l_header_party_id, l_party_type
           FROM aso_i_cust_accounts_v acct,
                aso_i_parties_v       par
           WHERE acct.cust_account_id = p_acct_id
           AND      acct.party_id = par.party_id;
           IF (SQL%NOTFOUND) THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
              FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
            END IF;
        END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create org_con_ord:l_header_party_id '||l_header_party_id, 1, 'N');
aso_debug_pub.add('create org_con_ord:l_party_type '||l_party_type, 1, 'N');
END IF;

/*--- As per Edd Jentzsch suggestion we need not create an org contact for a
--  B2C case.

    IF l_party_type = 'PERSON' THEN
        l_org_contact_id := NULL;
        x_party_id       := l_header_party_id;
    ELSE

*/

  -- kchervel added this if condition as a work around to avoid orders from
  -- failing when trying to create a relationship for itself.

  IF p_party_id <> l_header_party_id THEN

        Open C_org_contact(p_party_id, l_header_party_id);
        Fetch C_org_contact into l_org_contact_id;
        IF (C_org_contact%NOTFOUND) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      fnd_message.set_name('ASO', 'ORG_CONTACT_ID');
  	      FND_MSG_PUB.Add;
	   END IF;
          -- RAISE FND_API.G_EXC_ERROR;
           l_org_contact_id := NULL;
        END IF;
        Close C_org_contact;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create org_con_ord:l_org_contact_id '||l_org_contact_id, 1, 'N');
END IF;

   IF l_org_contact_id is NULL
     OR l_org_contact_id = FND_API.G_MISS_NUM THEN

     p_org_contact_rec.party_rel_rec.subject_id := p_party_id;
     p_org_contact_rec.party_rel_rec.object_id  := l_header_party_id;
  --   p_org_contact_rec.party_rel_rec.party_relationship_type := 'CONTACT_OF';
  -- In version 2 api, column has been renamed to relationship_type
	p_org_contact_rec.party_rel_rec.relationship_type := 'CONTACT_OF';
	p_org_contact_rec.party_rel_rec.start_date := sysdate;

/*
The call to Create_Org_Contact has been moved to a diff package in version 2 api.
  Original Call:  HZ_PARTY_PUB.create_org_contact
*/

HZ_PARTY_CONTACT_V2PUB.create_org_contact (
    p_init_msg_list                    => FND_API.G_FALSE,
    p_org_contact_rec                  => p_org_contact_rec,
    x_org_contact_id                   => l_org_contact_id,
    x_party_rel_id                     => x_party_rel_id,
    x_party_id                         => x_party_id,
    x_party_number                     => x_party_number,
    x_return_status                    => x_return_status,
    x_msg_count                        => x_msg_count,
    x_msg_data                         => x_msg_data  );


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create org_con_ord:after create_org_con:l_org_contact_id '||l_org_contact_id, 1, 'N');
aso_debug_pub.add('create org_con_ord:after create_org_con:x_return_status '||x_return_status, 1, 'N');
END IF;
         IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'ORG_CONTACT', FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
       END IF;
    END IF; -- org contact is null

        x_org_contact_id := l_org_contact_id;

    END IF; -- party id not equal to header party id

--  END IF; -- for 'PERSON' type


 FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_ORG_CONTACT_ord ;


PROCEDURE Create_Contact_Role ( p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_party_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_Cust_account_id     IN  NUMBER
  ,p_cust_account_site_id IN NUMBER  := FND_API.G_MISS_NUM
  ,p_Role_type           IN       VARCHAR2 := 'CONTACT'
  ,p_responsibility_type IN VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_Begin_date          IN DATE := sysdate
  ,p_role_id            IN  NUMBER  :=  FND_API.G_MISS_NUM
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'Create_Contact_Role';

--p_cust_acct_roles_rec  hz_customer_accounts_pub.cust_acct_roles_rec_type;
--p_role_resp_rec       hz_customer_accounts_pub.role_resp_rec_type;
-- The above two record definitions have been moved to a diff package in version 2 api's.
p_cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;
p_role_resp_rec       HZ_CUST_ACCOUNT_ROLE_V2PUB.role_responsibility_rec_type;

l_responsibility_id NUMBER;

CURSOR C_Get_Resp(role_id NUMBER, role_type VARCHAR2) IS
 SELECT responsibility_id
 FROM hz_role_responsibility
 WHERE cust_account_role_id = role_id
 AND responsibility_type = role_type;

BEGIN
  SAVEPOINT CREATE_CONTACT_ROLE_PVT;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
-- Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   p_cust_acct_roles_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   p_role_resp_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_contact_role: p_party_id: '||p_party_id,1,'N');
aso_debug_pub.add('create_contact_role: p_cust_account_id: '||p_cust_account_id,1,'N');
aso_debug_pub.add('create_contact_role: p_cust_account_site_id: '||p_cust_account_site_id,1,'N');
aso_debug_pub.add('create_contact_role: p_role_type: '||p_role_type,1,'N');
aso_debug_pub.add('create_contact_role: p_responsibility_type: '||p_responsibility_type,1,'N');
aso_debug_pub.add('create_contact_role: p_begin_date: '||p_begin_date,1,'N');
aso_debug_pub.add('create_contact_role: p_role_id: '||p_role_id,1,'N');
END IF;

 IF p_role_id IS NULL OR p_role_id = FND_API.G_MISS_NUM THEN
   p_cust_acct_roles_rec.party_id        := p_party_id;
   p_cust_acct_roles_rec.cust_account_id := p_cust_account_id;
   p_cust_acct_roles_rec.role_type       := p_role_type;

-- Begin_date column has been deleted in version 2 api record
--   p_cust_acct_roles_rec.begin_date      := p_begin_date;

    p_cust_acct_roles_rec.cust_acct_site_id := p_cust_account_site_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before create cust acct roles',1,'N');
END IF;

/*
 The call to create_cust_acct_roles has been moved to a diff package in version 2 api.
  Original Call:  hz_customer_accounts_pub.create_cust_acct_roles
*/


/*** Fix for R12.1.1 bug 12776643 ***/

 --   MO_GLOBAL.INIT('M'); /* Commented as per Bug 13473812 */

    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_account_role_rec                 => p_cust_acct_roles_rec,
    x_cust_account_role_id                  => x_cust_account_role_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_contact_role:after create_cust_acct_role: x_return_status: '||x_return_status,1,'N');
END IF;
   IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
     x_cust_account_role_id := NULL;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
       FND_MESSAGE.Set_Token('COLUMN', 'ACCT_ROLE', FALSE);
       FND_MSG_PUB.ADD;
     END IF;
     raise FND_API.G_EXC_ERROR;
   END IF;
  ELSE
    x_cust_account_role_id := p_role_id;
  END IF;

 OPEN C_Get_Resp(x_cust_account_role_id, p_responsibility_type);
 FETCH C_Get_Resp INTO l_responsibility_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_contact_role:l_responsibility_id: '||l_responsibility_id,1,'N');
END IF;
 IF C_Get_Resp%NOTFOUND THEN

   IF p_cust_account_site_id is not NULL AND
      p_cust_account_site_id <>  FND_API.G_MISS_NUM THEN
      p_role_resp_rec.cust_account_role_id := x_cust_account_role_id;
      p_role_resp_rec.responsibility_type := p_responsibility_type;

/*
 The call to create_role_resp has been moved to a diff package in version 2 api.

 Original Call:      HZ_CUSTOMER_ACCOUNTS_PUB.create_role_resp
*/


    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility (
    p_init_msg_list                         =>  FND_API.G_FALSE,
    p_role_responsibility_rec               => p_role_resp_rec,
    x_responsibility_id                     => l_responsibility_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_contact_role:after create_role_resp: x_return_status: '||x_return_status,1,'N');
END IF;
     IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
        FND_MESSAGE.Set_Token('COLUMN', 'ACCT_ROLE', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
     raise FND_API.G_EXC_ERROR;
     END IF;
   END IF;
 END IF;

 CLOSE C_Get_Resp;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Create_Contact_Role;

Procedure GET_ACCT_SITE_USES(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,P_Cust_Account_Id   IN  NUMBER
  ,P_Party_Site_Id     IN  NUMBER
  ,P_Acct_Site_type    IN  VARCHAR2 := 'NONE'
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_site_use_id  OUT NOCOPY /* file.sql.39 change */   NUMBER
   )
  IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(45) := 'GET_ACCT_SITE_USES';

 BEGIN
   ---- Initialize---------------------

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('ASO_PARTY_INT.get_acct_site_use:P_Acct_Site_type: '||P_Acct_Site_type,1,'N');
END IF;

   ASO_MAP_QUOTE_ORDER_INT.get_acct_site_uses (
       p_party_site_id   => P_Party_Site_Id,
       p_acct_site_type  => P_Acct_Site_Type,
       p_cust_account_id => P_Cust_Account_Id,
       x_return_status   => x_return_status,
       x_site_use_id     => x_site_use_id
   );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('ASO_PARTY_INT.get_acct_site_use:x_site_use_id: '||x_site_use_id,1,'N');
END IF;

END GET_ACCT_SITE_USES;


PROCEDURE Create_Customer_Account(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    P_Party_id          IN      NUMBER,
    P_Account_number    IN      NUMBER := FND_API.G_MISS_NUM,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_cust_acct_id      OUT NOCOPY /* file.sql.39 change */   NUMBER)
    IS

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(45) := 'Create_Customer_Account';

    CURSOR C_source_codes(l_source_code_id NUMBER) Is
        SELECT source_code
        FROM ams_source_codes
        WHERE source_code_id = l_source_code_id;

    CURSOR C_party_info (l_party_id NUMBER) IS
        SELECT party_type, party_name
        FROM hz_parties
        WHERE party_id = l_party_id;

    CURSOR C_acct_number IS
        SELECT aso_account_number_s.nextval
        FROM  dual;

    CURSOR c_party_rel_rec(l_party_id NUMBER) IS
        SELECT object_id from
        hz_relationships
        where party_id = l_party_id
        and object_table_name = 'HZ_PARTIES'
	   and subject_type = 'PERSON'
	   and subject_table_name = 'HZ_PARTIES';

-- The record definitions have been moved to a different package in version 2 api
--      account_rec         hz_customer_accounts_pub.account_rec_type;
        account_rec         HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;

--      person_rec              hz_party_pub.person_rec_type;
        person_rec              HZ_PARTY_V2PUB.person_rec_type;

--      organization_rec        hz_party_pub.organization_rec_type;
        organization_rec        HZ_PARTY_V2PUB.organization_rec_type;

--      cust_profile_rec        hz_customer_accounts_pub.cust_profile_rec_type;
        cust_profile_rec        HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;

--      p_party_rec      hz_party_pub.party_rec_type;
        p_party_rec      HZ_PARTY_V2PUB.party_rec_type;

    l_acct_id          NUMBER;
    l_account_number   VARCHAR2(30);
    l_party_id         NUMBER;
    l_party_number     VARCHAR2(30);
    l_profile_id	   NUMBER;
    l_gen_cust_num     VARCHAR2(3);
    l_party_type       VARCHAR2(30);
    l_party_name	   VARCHAR2(360);
    customer_party_id  NUMBER;
    g_pkg_name         VARCHAR2(200) := 'CREATE_CUSTOMER_ACCOUNT';

BEGIN

---- Initialize---------------------
    SAVEPOINT CREATE_CUSTOMER_ACCOUNT_PVT;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
    ) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;

-- Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   account_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   person_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   organization_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';
   cust_profile_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';


    -- if needed generate account_number.
	SELECT generate_customer_number INTO l_gen_cust_num
	FROM ar_system_parameters;
    -- typically should be set to 'Y' if no we will try to create a new one.
    -- however, this could error out
    IF l_gen_cust_num = 'Y' and p_account_number <> FND_API.G_MISS_NUM THEN
        account_rec.account_number := p_account_number;
    ELSIF l_gen_cust_num = 'N'
        and (p_account_number = FND_API.G_MISS_NUM or p_account_number is null) THEN
        OPEN C_acct_number;
            FETCH C_acct_number into account_rec.account_number;
        CLOSE C_acct_number;
        account_rec.account_number := 'ASO'||account_rec.account_number;
    END IF;
    -- figure OUT NOCOPY /* file.sql.39 change */ if the party is a person or an organization
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_cust_acct:P_Party_id: '||P_Party_id,1,'N');
END IF;
    OPEN C_party_info(P_Party_id);
        FETCH C_party_info INTO l_party_type, l_party_name;
        IF (C_party_info%NOTFOUND) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PARTY ID', FALSE);
                FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
        END IF;
    CLOSE C_party_info;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_cust_acct:l_party_type: '||l_party_type,1,'N');
END IF;
    -- if party is a relationship
    IF l_party_type = 'PARTY_RELATIONSHIP' THEN
        OPEN c_party_rel_rec(P_Party_id);
            FETCH c_party_rel_rec INTO customer_party_id;
        CLOSE c_party_rel_rec;

    OPEN C_party_info(customer_party_id);
    FETCH C_party_info INTO l_party_type, l_party_name;
        IF (C_party_info%NOTFOUND) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PARTY ID', FALSE);
                FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
        END IF;
    CLOSE C_party_info;

    ELSE
        customer_party_id := P_Party_id;
    END IF;

	account_rec.account_name := substr(l_party_name,1,240);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_cust_acct:l_party_type: '||l_party_type,1,'N');
aso_debug_pub.add('create_cust_acct:l_party_type: '||l_party_name,1,'N');
aso_debug_pub.add('create_cust_acct:customer_party_id: '||customer_party_id,1,'N');
END IF;
    -- if party is a person
    IF l_party_type = 'PERSON' THEN
        person_rec.party_rec := p_party_rec;
        person_rec.party_rec.party_id := customer_party_id;

/*
      The call to create_account procedure has been moved to
      a new package in TCA version 2 API's

      Original Call:        hz_customer_accounts_pub.create_account

*/


      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
      p_init_msg_list                         => FND_API.G_FALSE,
      p_cust_account_rec                      => account_rec,
      p_person_rec                            => person_rec,
      p_customer_profile_rec                  => cust_profile_rec,
      p_create_profile_amt                    => 'Y',
      x_cust_account_id                       => l_acct_id,
      x_account_number                        => l_account_number,
      x_party_id                              => l_party_id ,
      x_party_number                          => l_party_number,
      x_profile_id                            => l_profile_id,
      x_return_status                         => x_return_status,
      x_msg_count                             => x_msg_count,
      x_msg_data                              => x_msg_data );

    -- if party is an organization
    ELSIF l_party_type = 'ORGANIZATION' THEN
        organization_rec.party_rec := p_party_rec;
        organization_rec.party_rec.party_id := customer_party_id;

/*
      The call to create_account procedure has been moved to
      a new package in TCA version 2 API's

      Original Call:        hz_customer_accounts_pub.create_account
*/

      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
      p_init_msg_list                         => FND_API.G_FALSE,
      p_cust_account_rec                      => account_rec,
      p_organization_rec                      => organization_rec,
      p_customer_profile_rec                  => cust_profile_rec,
      p_create_profile_amt                    => 'Y',
      x_cust_account_id                       => l_acct_id,
      x_account_number                        => l_account_number,
      x_party_id                              => l_party_id ,
      x_party_number                          => l_party_number,
      x_profile_id                            => l_profile_id,
      x_return_status                         => x_return_status,
      x_msg_count                             => x_msg_count,
      x_msg_data                              => x_msg_data  );


    END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_cust_acct:after create_acct:l_acct_id: '||l_acct_id,1,'N');
END IF;
    IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'ACCT ID', FALSE);
            FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
    ELSE
        x_cust_acct_id  := l_acct_id;
    END IF;

    FND_MSG_PUB.Count_And_Get(
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

END Create_Customer_Account;

PROCEDURE Create_Cust_Acct_Relationship(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    p_sold_to_cust_account	IN NUMBER,
    p_related_cust_account	IN NUMBER,
    p_relationship_type		IN VARCHAR2,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'CREATE_CUST_ACCT_RELATIONSHIP';
l_cust_acct_id NUMBER;
-- l_create_cust_account VARCHAR2(1)
--  := FND_PROFILE.Value('ASO_CREATE_CUST_ACCOUNT');
--l_cust_acct_relate_rec
--  hz_cust_acct_info_pub.cust_acct_relate_rec_type;
-- The above record has been moved to a new package in version 2 api.
l_cust_acct_relate_rec    HZ_CUST_ACCOUNT_V2PUB.cust_acct_relate_rec_type;


BEGIN

  SAVEPOINT Create_Cust_Acct_Relationship;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
    ) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

  x_return_status := FND_API.g_ret_sts_success;

--Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   l_cust_acct_relate_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';


  --setup the cust_acct_related_rec
  l_cust_acct_relate_rec.cust_account_id := p_related_cust_account;
  l_cust_acct_relate_rec.related_cust_account_id := p_sold_to_cust_account;
  l_cust_acct_relate_rec.relationship_type := 'ALL';
  l_cust_acct_relate_rec.customer_reciprocal_flag := 'N';
  --Fix for Bug 5855375
  l_cust_acct_relate_rec.bill_to_flag := 'N';
  l_cust_acct_relate_rec.ship_to_flag := 'N';

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('p_related_cust_account = ' || p_related_cust_account, 1,'N');
  aso_debug_pub.add('sold_to_cust_account = ' || p_sold_to_cust_account, 1,'N');
  aso_debug_pub.add('relationship_type = ' || p_relationship_type,1,'N');
  END IF;

  IF p_relationship_type = 'BILL_TO' then
    l_cust_acct_relate_rec.bill_to_flag := 'Y';
  elsif p_relationship_type = 'SHIP_TO' then
    l_cust_acct_relate_rec.ship_to_flag := 'Y';
  else
    RAISE FND_API.G_EXC_ERROR;
  end if;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('enter cust1 and finish setup',1,'N');
  END IF;

/*
 The call to .create_cust_acct_relate has been moved to a diff package in version 2 api
  Original Call:    HZ_CUST_ACCT_INFO_PUB.create_cust_acct_relate
*/

    HZ_CUST_ACCOUNT_V2PUB.create_cust_acct_relate (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_acct_relate_rec                  => l_cust_acct_relate_rec,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data   );

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('finish call create_cust_acct_relate and ' || x_return_status, 1, 'N');
  END IF;

  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

    FND_MSG_PUB.Count_And_Get(
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

END Create_Cust_Acct_Relationship;

PROCEDURE update_Cust_Acct_Relationship(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    p_sold_to_cust_account	IN NUMBER,
    p_related_cust_account	IN NUMBER,
    p_relationship_type		IN VARCHAR2,
   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
l_cust_object_version_number      NUMBER;
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(45) := 'update_Cust_Acct_Relationship';
l_cust_acct_id NUMBER;
-- l_create_cust_account VARCHAR2(1)
--  := FND_PROFILE.Value('ASO_CREATE_CUST_ACCOUNT');
--l_cust_acct_relate_rec
--  hz_cust_acct_info_pub.cust_acct_relate_rec_type;
-- The above record has been moved to a new package in version 2 api.
l_cust_acct_relate_rec    HZ_CUST_ACCOUNT_V2PUB.cust_acct_relate_rec_type;

--Bug 18718639 - GSIAP:ERROR ASO_CHECK_TCA_PVT.CUST_ACCT_RELATIONSHIP WHEN INTERFACE TO OM
--used synonym hz_cust_acct_relate instead of table hz_cust_acct_relate_all
-- Added condtion for status for bug 20434198
Cursor OBJ_VER_NUM(p_related_cust_account number  , p_sold_to_cust_account number) is
SELECT OBJECT_VERSION_NUMBER
         FROM hz_cust_acct_relate
  WHERE cust_account_id = p_related_cust_account
    AND related_cust_account_id = p_sold_to_cust_account
    AND STATUS='A';
BEGIN

  SAVEPOINT update_Cust_Acct_Relationship;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
    ) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

  x_return_status := FND_API.g_ret_sts_success;

--Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.
     --commented for bug 15988240
   --l_cust_acct_relate_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';


  --setup the cust_acct_related_rec
  l_cust_acct_relate_rec.cust_account_id := p_related_cust_account;
  l_cust_acct_relate_rec.related_cust_account_id := p_sold_to_cust_account;
  l_cust_acct_relate_rec.relationship_type := 'ALL';
  l_cust_acct_relate_rec.customer_reciprocal_flag := 'N';

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('p_related_cust_account = ' || p_related_cust_account, 1,'N');
  aso_debug_pub.add('sold_to_cust_account = ' || p_sold_to_cust_account, 1,'N');
  aso_debug_pub.add('relationship_type = ' || p_relationship_type,1,'N');
  END IF;

  IF p_relationship_type = 'BILL_TO' then
    l_cust_acct_relate_rec.bill_to_flag := 'Y';
  elsif p_relationship_type = 'SHIP_TO' then
    l_cust_acct_relate_rec.ship_to_flag := 'Y';
  else
    RAISE FND_API.G_EXC_ERROR;
  end if;

begin
 -- l_cust_object_version_number := FND_API.G_MISS_NUM;

 OPEN OBJ_VER_NUM(p_related_cust_account , p_sold_to_cust_account );
 FETCH OBJ_VER_NUM  INTO l_cust_object_version_number;
 aso_debug_pub.add(' l_cust_object_version_number  = ' || l_cust_object_version_number);

   /* SELECT OBJECT_VERSION_NUMBER
      INTO   l_cust_object_version_number
    FROM hz_cust_acct_relate_ALL
  WHERE cust_account_id = p_related_cust_account
    AND related_cust_account_id = p_sold_to_cust_account ; */

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_cust_object_version_number := FND_API.G_MISS_NUM;
end;
/*
 The call to .create_cust_acct_relate has been moved to a diff package in version 2 api
  Original Call:    HZ_CUST_ACCT_INFO_PUB.create_cust_acct_relate
*/
aso_debug_pub.add('before calling  HZ_CUST_ACCOUNT_V2PUB.update_cust_acct_relate ');
    HZ_CUST_ACCOUNT_V2PUB.update_cust_acct_relate (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_acct_relate_rec                  => l_cust_acct_relate_rec,
    p_object_version_number                 => l_cust_object_version_number,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data   );

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('finish call update_cust_acct_relate and ' || x_return_status, 1, 'N');
  END IF;

  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
   aso_debug_pub.add('finish call update_cust_acct_relateRAISE FND_API.G_EXC_ERROR');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

    FND_MSG_PUB.Count_And_Get(
        p_count          =>   x_msg_count,
        p_data           =>   x_msg_data);

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
		aso_debug_pub.add('Exception  FND_API.G_EXC_ERROR' );
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		aso_debug_pub.add(' Exception FND_API.G_EXC_UNEXPECTED_ERROR' );
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

        WHEN OTHERS THEN
		aso_debug_pub.add(' Exception OTHERS' );
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME          => L_API_NAME,
                P_PKG_NAME          => G_PKG_NAME,
                P_EXCEPTION_LEVEL   => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE      => ASO_UTILITY_PVT.G_PVT,
                P_SQLCODE           => SQLCODE,
                P_SQLERRM           => SQLERRM,
                X_MSG_COUNT         => X_MSG_COUNT,
                X_MSG_DATA          => X_MSG_DATA,
                X_RETURN_STATUS     => X_RETURN_STATUS);

END update_Cust_Acct_Relationship;

PROCEDURE Create_Party_Site_Use(
    p_api_version          IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.g_false,
    p_commit               IN   VARCHAR2  := FND_API.g_false,
     p_party_site_id            IN NUMBER,
    p_party_site_use_type  IN   VARCHAR2,
     x_party_site_use_id    OUT NOCOPY /* file.sql.39 change */      NUMBER,
	x_return_status		   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

    l_api_name              CONSTANT VARCHAR2(45) := 'Create_Party_Site_Use';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_party_site_use_rec  	HZ_PARTY_SITE_V2PUB.Party_Site_Use_Rec_Type;

BEGIN
    SAVEPOINT CREATE_PARTY_SITE_USE_PVT;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
    ) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--Initializing the created_by_module column for all the records as per
-- changes in version 2 api's.

   l_party_site_use_rec.Created_by_Module := 'ASO_CUSTOMER_DATA';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_pty_site_use:before create_pty_site_use:p_party_site_id ' || p_party_site_id, 1, 'N');
aso_debug_pub.add('create_pty_site_use:before create_pty_site_use:p_party_site_use_type ' || p_party_site_use_type, 1, 'N');
END IF;
	 l_party_site_use_rec.party_site_id := p_party_site_id;

--  Begin_date has been deleted in version 2 api.
--	 l_party_site_use_rec.begin_date    := sysdate;

	 l_party_site_use_rec.site_use_type := p_party_site_use_type;
/*
The call to Create_Party_Site_Use has been moved to diff package in version 2 api.
  Original Call:     HZ_PARTY_PUB.Create_Party_Site_Use
*/

    HZ_PARTY_SITE_V2PUB.create_party_site_use (
    p_init_msg_list                 => FND_API.G_FALSE,
    p_party_site_use_rec            => l_party_site_use_rec,
    x_party_site_use_id             => x_party_site_use_id,
    x_return_status                 => x_return_status,
    x_msg_count                     => x_msg_count,
    x_msg_data                      => x_msg_data  );


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('create_pty_site_use:after create_pty_site_use:x_party_site_use_id ' || x_party_site_use_id, 1, 'N');
aso_debug_pub.add('create_pty_site_use:after create_pty_site_use:x_return_status ' || x_return_status, 1, 'N');
END IF;
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Party_Site_Use;

End ASO_PARTY_INT;

/
