--------------------------------------------------------
--  DDL for Package Body JTF_UM_BUSINESS_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_BUSINESS_USER_PVT" as
/* $Header: JTFVUBRB.pls 120.2.12010000.2 2008/08/14 21:23:49 dbowles ship $ */
-- Start of Comments
-- Package name     : JTF_UM_BUSINESS_USER_PVT
-- Purpose          :
--   This package contains specification business user registration
G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_UM_BUSINESS_USER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'JTFVUBRB.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_MODULE          VARCHAR2(40) := 'JTF.UM.PLSQL.REGBUSINESSUSER';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(G_MODULE);
NEWLINE	VARCHAR2(1) := fnd_global.newline;
G_CREATED_BY_MODULE VARCHAR2(20):= 'JTA_USER_MANAGEMENT';
/**
 * Procedure   :  RegisterBusinessUser
 * Type        :  Private
 * Pre_reqs    :
 * Description :
 * Parameters  :
 *
 * input parameters ()
 *     param  requester_user_name     (*)
 *  (*) required fields
 *
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
 *
 * Errors      : Expected Errors
 *
 * Other Comments :
 */
Procedure RegisterBusinessUser
(
    P_Api_Version_Number        IN      NUMBER,
    P_Init_Msg_List             IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                    IN      VARCHAR2     := FND_API.G_FALSE,
    P_self_service_user         IN      VARCHAR2     := FND_API.G_FALSE,
    P_um_person_Rec             IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Person_Rec_type,
    P_um_organization_Rec       IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Organization_Rec_type,
    X_Return_Status             out NOCOPY     VARCHAR2,
    X_Msg_Count                 out NOCOPY     NUMBER,
    X_Msg_data                  out NOCOPY     VARCHAR2
) IS
l_api_version_number            number  := 1.0;
l_person_rec                    HZ_PARTY_V2PUB.PERSON_REC_TYPE;
l_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
l_party_number                  varchar2(100);
l_org_contact_id	            NUMBER;
l_party_rel_id		            NUMBER;
l_party_id		                NUMBER;
l_contact_preference_id             NUMBER;
l_search_value                  varchar2(360);
l_profile_id                    number;
l_contact_point_id              number;
l_contact_point_rec             HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
l_email_rec                     HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
l_phone_rec                     HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
l_api_name                      varchar2(50) := 'RegisterBusinessUser';
l_check_existing_org_option     varchar2(10) := 'N';
l_org_contact_rec               HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
l_party_rel_rec                 HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
l_password_Date                 date := null;
l_create_organization           boolean := false;
l_privacy_preference varchar2(5);
cursor c_user_id(p_user_name in varchar2) is select user_id from fnd_user where user_name = p_user_name;
BEGIN
    JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module => G_MODULE,
                    p_message   => l_api_name);
   -- Standard Start of API savepoint
    SAVEPOINT RegisterBusinessUser;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- API body
    --
  -- creating a person in TCA schema
  JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE, p_message   => 'invoking HZ_PARTY_V2PUB.create_person with first and last name');
  l_person_rec.person_first_name := P_um_person_Rec.first_name;
  l_person_rec.person_last_name  := P_um_person_Rec.last_name;
  l_person_rec.created_by_module := G_CREATED_BY_MODULE;
  l_person_rec.application_id    := 690;
  l_privacy_preference := p_um_person_rec.privacy_preference;
  HZ_PARTY_V2PUB.create_person (
    p_person_rec                 => l_person_rec,
    x_party_id                   => p_um_person_rec.party_id,
    x_party_number               => l_party_number,
    x_profile_id                 => l_profile_id,
    x_return_status              => X_Return_Status,
    x_msg_count                  => X_Msg_Count,
    x_msg_data                   => X_Msg_Data);
if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
    IF ( P_um_organization_Rec.organization_number is null ) then
        --l_check_existing_org_option := nvl(fnd_profile.get('JTF_CHECK_EXISTING_ORG', l_check_existing_org_option ), l_check_existing_org_option );
        l_create_organization   := true;
        fnd_profile.get('JTF_CHECK_EXISTING_ORG', l_check_existing_org_option );
        if ( l_check_existing_org_option = 'Y' ) then
            l_search_value  := P_um_organization_Rec.organization_name;
            if ( not Find_Organization(
                x_org_rec           => P_um_organization_Rec,
                p_search_value      => l_search_value,
                p_use_name          => true ) ) then
                Create_Organization(
                    P_Api_Version_Number        =>  P_Api_Version_Number,
                    P_Init_Msg_List             =>  P_Init_Msg_List,
                    P_Commit                    =>  P_Commit,
                    P_um_person_Rec             =>  P_um_person_Rec ,
                    P_um_organization_Rec       =>  P_um_organization_Rec,
                    X_Return_Status             =>  X_Return_Status,
                    X_Msg_Count                 =>  X_Msg_Count,
                    X_Msg_data                  =>  X_Msg_data );
                if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
            end if;
        else
                Create_Organization(
                    P_Api_Version_Number        =>  P_Api_Version_Number,
                    P_Init_Msg_List             =>  P_Init_Msg_List,
                    P_Commit                    =>  P_Commit,
                    P_um_person_Rec             =>  P_um_person_Rec ,
                    P_um_organization_Rec       =>  P_um_organization_Rec,
                    X_Return_Status             =>  X_Return_Status,
                    X_Msg_Count                 =>  X_Msg_Count,
                    X_Msg_data                  =>  X_Msg_data );
                if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
        end if;
    ELSE
        l_search_value    := P_um_organization_Rec.organization_number;
        if ( not Find_Organization(
            x_org_rec           => P_um_organization_Rec,
            p_search_value      => l_search_value,
            p_use_name          => false ) ) then
            FND_MESSAGE.Set_Name('JTF', 'JTA_UM_ORGANIZATION_NOT_FOUND');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;
  END IF;
--l_party_rel_rec.party_rec.total_num_of_orders   :=  0;
l_party_rel_rec.subject_id                      :=  p_um_person_rec.party_id;
l_party_rel_rec.subject_type                    :=  'PERSON';
l_party_rel_rec.subject_table_name             :=  'HZ_PARTIES';
l_party_rel_rec.relationship_type               :=  'EMPLOYMENT';
l_party_rel_rec.relationship_code              :=  'EMPLOYEE_OF';
l_party_rel_rec.start_date                     := nvl(p_um_person_rec.start_Date_active, sysdate);
l_party_rel_rec.object_id                       :=  p_um_organization_rec.org_party_id;
l_party_rel_rec.object_type                    :=  'ORGANIZATION';
l_party_rel_rec.object_table_name             :=  'HZ_PARTIES';
l_party_rel_rec.created_by_module := G_CREATED_BY_MODULE;
l_party_rel_rec.application_id    := 690;
l_org_contact_rec.party_rel_rec                 :=  l_party_rel_rec;
l_org_contact_rec.created_by_module := G_CREATED_BY_MODULE;
l_org_contact_rec.application_id    := 690;
HZ_PARTY_CONTACT_V2PUB.create_org_contact (
        p_init_msg_list             =>  P_Init_Msg_List,
        p_org_contact_rec	        =>  l_org_contact_rec,
        x_org_contact_id            =>  p_um_organization_rec.org_contact_party_id,
        x_party_rel_id              =>  l_party_rel_id,
        x_party_id                  =>  l_party_id,
        x_party_number              =>  l_party_number,
        x_return_status             =>  X_Return_Status,
        x_msg_count                 =>  X_Msg_Count,
        x_msg_data                  =>  X_Msg_data
        );
if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
/*if ( l_create_organization ) then
    --JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_ACCOUNT(P_um_organization_Rec.org_contact_party_id, 'PRIMARYUSERNEW', P_um_organization_Rec.org_party_id );
    -- should send l_party_id as the param which is the
    JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_ACCOUNT(l_party_id, 'PRIMARYUSERNEW', P_um_organization_Rec.org_party_id );
end if;
*/
  -- if it is a self service user then set the password date to sysdate so
  -- that the user is not prompted at the first logon
  if (p_self_service_user = FND_API.G_TRUE) then
    l_password_date := sysdate;
  end if;
 --Start Changes for Reserve-Release User Name: 3899304
/*
FND_USER_PKG.CreateUser (
    x_user_name                 => p_um_person_rec.user_name,
    x_owner                     => null,
    x_unencrypted_password      => p_um_person_rec.password,
    x_password_date             => l_password_date,
    x_start_date                => nvl( p_um_person_rec.start_date_active, sysdate),
    x_email_address             => p_um_person_rec.email_address,
    x_customer_id	            => l_party_id
    );
  */
  -- reserve this username dont create a FND_USER with this name

  p_um_person_rec.user_id :=fnd_user_pkg.CreatePendingUser (
        x_user_name                  => p_um_person_rec.user_name,
        x_owner                      => null,
        x_unencrypted_password       => p_um_person_rec.password,
        x_password_date              => l_password_date,
        x_email_address              => p_um_person_rec.email_address,
       x_person_party_id            => p_um_person_rec.party_id
        );

	fnd_user_pkg.UpdateUser(
			x_user_name=>p_um_person_rec.user_name,
			x_owner=>null,
			x_customer_id=>l_party_id
			);

--for i in c_user_id(upper(p_um_person_rec.user_name)) loop
--    p_um_person_rec.user_id := i.user_id;
--end loop;
l_contact_point_rec.status            :=  'A';
l_contact_point_rec.owner_table_name  :=  'HZ_PARTIES';
l_contact_point_rec.owner_table_id    :=  l_party_id;
l_contact_point_rec.primary_flag      :=  'Y';
l_contact_point_rec.created_by_module :=  G_CREATED_BY_MODULE;
l_contact_point_rec.application_id    :=  690;
if ( p_um_person_rec.email_address is not NULL ) then
    l_contact_point_rec.contact_point_type := 'EMAIL';
    l_email_rec.email_address := p_um_person_rec.email_address;
    l_email_rec.email_format  := 'MAILTEXT';
    HZ_CONTACT_POINT_V2PUB.create_contact_point (
        p_contact_point_rec           => l_contact_point_rec,
        p_email_rec                   => l_email_rec,
        x_contact_point_id            => l_contact_point_id,
        x_return_status               => X_Return_Status,
        x_msg_count                   => X_Msg_Count,
        x_msg_data                    => X_Msg_Data);
end if;
if ( p_um_person_rec.phone_number is not NULL ) then
    l_contact_point_rec.contact_point_type := 'PHONE';
    l_phone_rec.phone_area_code := nvl( p_um_person_rec.phone_area_code, '' );
    l_phone_rec.phone_number := p_um_person_rec.phone_number;
    l_phone_rec.phone_line_type := 'GEN';
    HZ_CONTACT_POINT_V2PUB.create_contact_point (
      p_contact_point_rec               => l_contact_point_rec,
      p_phone_rec                       => l_phone_rec,
      x_contact_point_id                => l_contact_point_id,
      x_return_status                   => X_Return_Status,
      x_msg_count                       => X_Msg_Count,
      x_msg_data                        => X_Msg_Data );
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
end if;
    JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_ACCOUNT with party id ' || p_um_person_rec.party_id || ' usertypekey INDIVIDUALUSER');
    --JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_ACCOUNT(p_um_person_rec.party_id, 'BUSINESSUSER');
     if (l_privacy_preference = 'YES') then
   l_contact_preference_rec.preference_code := 'DO';
   else
   l_contact_preference_rec.preference_code := 'DO_NOT';
   end if;
     -- call Hz_contact_preference api to populate the
     -- preference to recieve marketing/promotion mails
  JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference for creating preference of receiving email preference:'||l_privacy_preference);
     l_contact_preference_rec.contact_level_table := 'HZ_PARTIES';
     -- populate contact level id with l_party_id which is the relationship_id
     l_contact_preference_rec.contact_level_table_id := l_party_id;
     l_contact_preference_rec.contact_type := 'EMAIL';
     l_contact_preference_rec.requested_by := 'PARTY';
     l_contact_preference_rec.created_by_module := G_CREATED_BY_MODULE;
     l_contact_preference_rec.application_id := 690;
     HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
     --p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
     p_contact_preference_rec          => l_contact_preference_rec,
     x_contact_preference_id           => l_contact_preference_id,
     x_return_status                   => x_return_status,
     x_msg_count                       => x_msg_count,
     x_msg_data                        => x_msg_data
     );
    if l_is_debug_parameter_on then
    JTF_DEBUG_PUB.LOG_PARAMETERS( p_module => G_MODULE,
    p_message => 'create contact preferece'||' l_cont_preference_id:'||l_contact_preference_id || ' returnStatus:'||x_return_status);
    end if;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);
    JTF_DEBUG_PUB.LOG_EXITING_METHOD(
                    p_module => G_MODULE,
                    p_message   => l_api_name);
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
       WHEN OTHERS THEN
	  JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
END RegisterBusinessUser;
/**
 * Procedure   :  Create_Organization
 * Type        :  Private
 * Pre_reqs    :
 * Description :
 * Parameters  :
 *
 * input parameters ()
 *     param  requester_user_name     (*)
 *  (*) required fields
 *
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
 *
 * Errors      : Expected Errors
 *
 * Other Comments :
 */
Procedure Create_Organization
(
    P_Api_Version_Number        IN      NUMBER,
    P_Init_Msg_List             IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                    IN      VARCHAR2     := FND_API.G_FALSE,
    P_um_person_Rec             IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Person_Rec_type,
    P_um_organization_Rec       IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Organization_Rec_type,
    X_Return_Status             out NOCOPY     VARCHAR2,
    X_Msg_Count                 out NOCOPY     NUMBER,
    X_Msg_data                  out NOCOPY     VARCHAR2
) IS
l_api_version_number            number := 1.0;
l_person_rec                    HZ_PARTY_V2PUB.PERSON_REC_TYPE;
l_HzOrganizationRec             HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
l_profile_id                    number;
l_contact_point_id              number;
l_contact_point_rec             HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
l_location_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_location_id                   l_location_rec.location_id%TYPE;
l_party_site_rec                HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
l_party_site_id                 l_party_site_rec.party_site_id%type;
l_party_site_number             l_party_site_rec.party_site_number%type;
l_email_rec                     HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
l_phone_rec                     HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
l_api_name                      varchar2(50) := 'Create_Organization';
BEGIN
    JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module => G_MODULE, p_message   => l_api_name);
   -- Standard Start of API savepoint
    SAVEPOINT create_organization;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number, p_api_version_number, l_api_name, G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- API body
    --
l_HzOrganizationRec.organization_name   := P_um_organization_Rec.organization_name;
l_HzOrganizationRec.created_by_module   := G_CREATED_BY_MODULE;
l_HzOrganizationRec.application_id      := 690;
HZ_PARTY_V2PUB.create_organization(
    p_init_msg_list                    =>   P_Init_Msg_List,
    p_organization_rec                 =>   l_HzOrganizationRec,
    x_return_status                    =>   X_Return_Status,
    x_msg_count                        =>   X_Msg_Count,
    x_msg_data                         =>   X_Msg_data,
    x_party_id                         =>   P_um_organization_Rec.org_party_id,
    x_party_number                     =>   P_um_organization_Rec.organization_number, --check to see if this is null or not, if null get nextval from HZ_GENERATE_PARTY_NUMBER
    x_profile_id                       =>   l_profile_id
);
if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
l_location_rec.address1                :=  P_um_organization_Rec.address1;
l_location_rec.address2                :=  P_um_organization_Rec.address2;
l_location_rec.address3                :=  P_um_organization_Rec.address3;
l_location_rec.address4                :=  P_um_organization_Rec.address4;
l_location_rec.city                    :=  P_um_organization_Rec.city;
l_location_rec.state                   :=  P_um_organization_Rec.state;
l_location_rec.postal_code             :=  P_um_organization_Rec.postal_code;
l_location_rec.country                 :=  P_um_organization_Rec.country;
l_location_rec.county                  :=  P_um_organization_Rec.county;
l_location_rec.province                :=  P_um_organization_Rec.province;
l_location_rec.address_lines_phonetic  :=  P_um_organization_Rec.altaddress;
l_location_rec.created_by_module    :=  G_CREATED_BY_MODULE;
l_location_rec.application_id       :=  690;
HZ_LOCATION_V2PUB.create_location(
    p_init_msg_list                     =>  P_Init_Msg_List,
    p_location_rec                      =>  l_location_rec,
    x_location_id                       =>  l_location_id,
    x_return_status                     =>  X_Return_Status,
    x_msg_count                         =>  X_Msg_Count,
    x_msg_data                          =>  X_Msg_data );
if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
l_party_site_rec.location_id    := l_location_id;
l_party_site_rec.party_id       := P_um_organization_Rec.org_party_id;
l_party_site_rec.created_by_module    :=  G_CREATED_BY_MODULE;
l_party_site_rec.application_id       :=  690;
HZ_PARTY_SITE_V2PUB.create_party_site(
    p_init_msg_list                     =>  P_Init_Msg_List,
    p_party_site_rec                    =>  l_party_site_rec,
    x_party_site_id                     =>  l_party_site_id,
    x_party_site_number                 =>  l_party_site_number,
    x_return_status                     =>  X_Return_Status,
    x_msg_count                         =>  X_Msg_Count,
    x_msg_data                          =>  X_Msg_data );
if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;
l_contact_point_rec.status            :=  'A';
l_contact_point_rec.owner_table_name  :=  'HZ_PARTIES';
l_contact_point_rec.owner_table_id    :=  P_um_organization_Rec.org_party_id;
l_contact_point_rec.primary_flag      :=  'Y';
l_contact_point_rec.created_by_module :=  G_CREATED_BY_MODULE;
l_contact_point_rec.application_id    :=  690;
if ( P_um_organization_Rec.phone_number is not NULL ) then
    l_contact_point_rec.contact_point_type := 'PHONE';
    l_phone_rec.phone_area_code := nvl( P_um_organization_Rec.phone_area_code, '' );
    l_phone_rec.phone_number := P_um_organization_Rec.phone_number;
    l_phone_rec.phone_line_type := 'GEN';
    JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE, p_message   => 'invoking HZ_CONTACT_POINT_V2PUB.create_contact_point for creating phone');
    HZ_CONTACT_POINT_V2PUB.create_contact_point (
      p_contact_point_rec               => l_contact_point_rec,
      p_phone_rec                       => l_phone_rec,
      x_contact_point_id                => l_contact_point_id,
      x_return_status                   => X_Return_Status,
      x_msg_count                       => X_Msg_Count,
      x_msg_data                        => X_Msg_Data );
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
end if;
l_contact_point_rec.primary_flag      :=  'N';
if ( p_um_organization_rec.fax_number is not NULL ) then
    l_contact_point_rec.contact_point_type := 'PHONE';
    l_phone_rec.phone_area_code := nvl( P_um_organization_Rec.fax_area_code, '' );
    l_phone_rec.phone_number := P_um_organization_Rec.fax_number;
    l_phone_rec.phone_line_type := 'FAX';
    JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE, p_message   => 'invoking HZ_CONTACT_POINT_V2PUB.create_contact_point for creating phone');
    HZ_CONTACT_POINT_V2PUB.create_contact_point (
      p_contact_point_rec               => l_contact_point_rec,
      p_phone_rec                       => l_phone_rec,
      x_contact_point_id                => l_contact_point_id,
      x_return_status                   => X_Return_Status,
      x_msg_count                       => X_Msg_Count,
      x_msg_data                        => X_Msg_Data );
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
end if;
    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
	p_count	=> x_msg_count,
	p_data	=> x_msg_data);
    JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module => G_MODULE,
                    p_message   => l_api_name);
END Create_Organization;
/**
 * Procedure   :  Find_Organization
 * Type        :  Private
 * Pre_reqs    :
 * Description :
 * Parameters  :
 *
 * input parameters ()
 *     param  requester_user_name     (*)
 *  (*) required fields
 *
 * output parameters
 *     param  x_return_status
 *     param  x_msg_data
 *     param  x_msg_count
 *
 * Errors      : Expected Errors
 *
 * Other Comments :
 */
 Function Find_Organization(
            x_org_rec       IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Organization_Rec_type,
            p_search_value  IN varchar2,
            p_use_name      IN boolean ) return boolean is
    cursor c_party_name IS
        select party_id, party_name, party_number from hz_parties where party_name = x_org_rec.organization_name;
    cursor c_party_num IS
        select party_id, party_name, party_number from hz_parties where party_number = x_org_rec.organization_number;
    l_party_rec     c_party_name%rowtype;
    ret_val         boolean := false;
begin
    if ( p_use_name ) then
        Open c_party_name;
        Fetch c_party_name into l_party_rec;
        If (c_party_name%FOUND) then
            x_org_rec.organization_number   := l_party_rec.party_number;
            x_org_rec.organization_name     := l_party_rec.party_name;
            x_org_rec.org_party_id          := l_party_rec.party_id;
            ret_val := true;
        end if;
        Close c_party_name;
    else
        Open c_party_num;
        Fetch c_party_num into l_party_rec;
        If (c_party_num%FOUND) then
            x_org_rec.organization_number   := l_party_rec.party_number;
            x_org_rec.organization_name     := l_party_rec.party_name;
            x_org_rec.org_party_id          := l_party_rec.party_id;
            ret_val := true;
        end if;
        Close c_party_num;
    end if;
    return ret_val;
end Find_Organization;
end JTF_UM_BUSINESS_USER_PVT;

/
