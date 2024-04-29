--------------------------------------------------------
--  DDL for Package Body JTF_UM_INDIVIDUAL_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_INDIVIDUAL_USER_PVT" as
/* $Header: JTFVUIRB.pls 120.2.12010000.4 2008/08/14 21:22:06 dbowles ship $ */
-- Start of Comments
-- Package name     : JTF_UM_INDIVIDUAL_USER_PVT
-- Purpose          :
--   This package contains specification individual user registration


G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_UM_INDIVIDUAL_USER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'JTFVUIRB.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

G_MODULE          VARCHAR2(40) := 'JTF.UM.PLSQL.REGINDIVIDUALUSER';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(G_MODULE);
G_CREATED_BY_MODULE VARCHAR2(20) := 'JTA_USER_MANAGEMENT';
NEWLINE	VARCHAR2(1) := fnd_global.newline;

Procedure createPersonAndContact(
    P_um_person_Rec          IN out NOCOPY   JTF_UM_REGISTER_USER_PVT.Person_Rec_type)IS

    X_Return_Status               VARCHAR2(20);
    X_Msg_Count                   NUMBER;
    X_Msg_data                    VARCHAR2(300);
l_api_version_number number := 1.0;
l_person_rec HZ_PARTY_V2PUB.PERSON_REC_TYPE;
l_party_number varchar2(100);
l_profile_id   number;
l_contact_point_id number;
l_contact_preference_id number;
l_contact_point_rec    HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
l_email_rec            HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
l_phone_rec            HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
l_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
l_api_name varchar2(50) := 'createPersonAndContact';
l_privacy_preference varchar2(5);
begin
  JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module => G_MODULE,
                    p_message   => l_api_name);

    -- creating a person in TCA schema

  JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking HZ_PARTY_V2PUB.create_person with first and last name');

  l_person_rec.person_first_name := P_um_person_Rec.first_name;
  l_person_rec.person_last_name  := P_um_person_Rec.last_name;
  l_person_rec.created_by_module := G_CREATED_BY_MODULE;
  l_person_rec.application_id    := 690;
  l_privacy_preference           := P_um_person_Rec.privacy_preference;

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

      -- creating contact points for the user

  JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking HZ_CONTACT_POINT_V2PUB.create_contact_point for creating email');

  l_contact_point_rec.status :=             'A';
  l_contact_point_rec.owner_table_name :=        'HZ_PARTIES';
  l_contact_point_rec.owner_table_id :=     p_um_person_rec.party_id;
  l_contact_point_rec.primary_flag :=            'Y';
  l_contact_point_rec.created_by_module := G_CREATED_BY_MODULE;
  l_contact_point_rec.application_id    := 690;

  if p_um_person_rec.email_address is not NULL then
    l_contact_point_rec.contact_point_type := 'EMAIL';

    l_email_rec.email_address := p_um_person_rec.email_address;
    l_email_rec.email_format  := 'MAILTEXT';

    HZ_CONTACT_POINT_V2PUB.create_contact_point (
    p_contact_point_rec           => l_contact_point_rec,
    p_email_rec                   => l_email_rec,
    x_contact_point_id            => l_contact_point_id,
    x_return_status              => X_Return_Status,
    x_msg_count                  => X_Msg_Count,
    x_msg_data                   => X_Msg_Data);


    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    if l_is_debug_parameter_on then
    JTF_DEBUG_PUB.LOG_PARAMETERS( p_module => G_MODULE,
                    p_message => 'privacyPreference: '|| l_privacy_preference);
    end if;

   if (l_privacy_preference = 'YES') then
     l_contact_preference_rec.preference_code := 'DO';

   else
     l_contact_preference_rec.preference_code := 'DO_NOT';
   end if;
     -- call Hz_contact_preference api to populate the
     -- preference to recieve marketing/promotion mails
  JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference for creating preference of receiving email');
     l_contact_preference_rec.contact_level_table := 'HZ_PARTIES';
     l_contact_preference_rec.contact_level_table_id := p_um_person_rec.party_id;
     l_contact_preference_rec.contact_type := 'EMAIL';
     l_contact_preference_rec.requested_by := 'INTERNAL';
     l_contact_preference_rec.created_by_module := G_CREATED_BY_MODULE;
     l_contact_preference_rec.application_id := 690;
     HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
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

  end if;

  if p_um_person_rec.phone_number is not NULL then
    l_contact_point_rec.contact_point_type := 'PHONE';

   JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking HZ_CONTACT_POINT_V2PUB.create_contact_point for creating phone');
    l_phone_rec.phone_area_code := p_um_person_rec.phone_area_code;
    l_phone_rec.phone_number := p_um_person_rec.phone_number;
    l_phone_rec.phone_line_type := 'GEN';

    HZ_CONTACT_POINT_V2PUB.create_contact_point (
      p_contact_point_rec           => l_contact_point_rec,
      p_phone_rec                   => l_phone_rec,
      x_contact_point_id            => l_contact_point_id,
      x_return_status              => X_Return_Status,
      x_msg_count                  => X_Msg_Count,
      x_msg_data                   => X_Msg_Data);

      if x_return_status <> FND_API.G_RET_STS_SUCCESS then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

    end if;

      JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module => G_MODULE,
                    p_message   => l_api_name);

end createPersonAndContact;



Procedure RegisterIndividualUser(P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    P_self_service_user       IN   VARCHAR2     := FND_API.G_FALSE,
    P_um_person_Rec          IN out NOCOPY   JTF_UM_REGISTER_USER_PVT.Person_Rec_type,
    X_Return_Status              out NOCOPY  VARCHAR2,
    X_Msg_Count                  out NOCOPY  NUMBER,
    X_Msg_data                   out NOCOPY  VARCHAR2) IS

l_api_version_number number := 1.0;
l_api_name          varchar2(50) := 'RegisterIndividualUser';
l_password_Date        date := null;

/*cursor c_user_id(p_user_name in varchar2) is
select user_id
from fnd_user
where user_name = p_user_name;*/

BEGIN

    JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module => G_MODULE,
                    p_message   => l_api_name);


   -- Standard Start of API savepoint
    SAVEPOINT RegisterIndividualUser;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
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

  -- creating a person and contacts in TCA schema
  createPersonAndContact(P_um_person_Rec);


  -- creating a  user in fnd schema
   JTF_DEBUG_PUB. LOG_EVENT( p_module    => G_MODULE,
                    p_message   => 'invoking FND_USER_PKG.CreateUser with username, password, email and customer id '||p_um_person_rec.party_id);

  -- if it is a self service user then set the password date to sysdate so
  -- that the user is not prompted at the first logon
  if (p_self_service_user = FND_API.G_TRUE) then
    l_password_date := sysdate;
  end if;

-- Start Changes for Reserve-Release User Name: 3899304
/*
  FND_USER_PKG.CreateUser (
    x_user_name                 => p_um_person_rec.user_name,
    x_owner                     => null,
    x_unencrypted_password      => p_um_person_rec.password,
    x_password_date             => l_password_date,
    x_start_date                => nvl( p_um_person_rec.start_date_active, sysdate),
    x_email_address             => p_um_person_rec.email_address,
    x_customer_id	        => p_um_person_rec.party_id) ;

*/
 -- reserve this username dont create a FND_USER with this name
 p_um_person_rec.user_id := fnd_user_pkg.CreatePendingUser (
        x_user_name                  => p_um_person_rec.user_name,
        x_owner                      => null,
        x_unencrypted_password       => p_um_person_rec.password,
        x_password_date              => l_password_date,
        x_email_address              => p_um_person_rec.email_address

        );

 fnd_user_pkg.UpdateUser(
	  		 x_user_name=>p_um_person_rec.user_name,
			 x_owner=>null,
			 x_customer_id=>p_um_person_rec.party_id);

   -- for i in c_user_id(upper(p_um_person_rec.user_name)) loop
     --p_um_person_rec.user_id := i.user_id;
    --end loop;

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
END RegisterIndividualUser;

end JTF_UM_INDIVIDUAL_USER_PVT;

/
