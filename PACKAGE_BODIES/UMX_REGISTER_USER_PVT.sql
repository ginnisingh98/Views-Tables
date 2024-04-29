--------------------------------------------------------
--  DDL for Package Body UMX_REGISTER_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REGISTER_USER_PVT" as
  /* $Header: UMXIBURB.pls 120.5.12010000.2 2013/09/26 19:19:13 ctilley ship $ */
  -- Start of Comments
  -- Package name     : UMX_REGISTER_USER_PVT
  -- Purpose          :
  --   This package contains specification  user registration


Procedure CreatePersonPartyInternal (p_event in out NOCOPY WF_EVENT_T,
                                    p_person_party_id out NOCOPY varchar2)
IS

  --l_person_party_id hz_parties.party_id%type;
  l_first_name hz_parties.person_first_name%type;
  l_last_name hz_parties.person_last_name%type;
  l_middle_name hz_parties.person_middle_name%type;
  l_pre_name_adjunct hz_parties.person_pre_name_adjunct%type;
  l_person_name_suffix hz_parties.person_name_suffix%type;

  l_party_number hz_parties.party_number%type;
  l_person_rec HZ_PARTY_V2PUB.PERSON_REC_TYPE;
  l_profile_id                        NUMBER;


  X_Return_Status               VARCHAR2 (20);
  X_Msg_Count                   NUMBER;
  X_Msg_data                    VARCHAR2 (300);


BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXIBURB.createpersonpartyinternal.begin','');
  end if;


  -- read from the event object
  l_first_name := p_event.getvalueforparameter ('FIRST_NAME');
  l_last_name := p_event.getvalueforparameter ('LAST_NAME');
  l_middle_name := p_event.getvalueforparameter ('MIDDLE_NAME');
  l_pre_name_adjunct := p_event.getvalueforparameter ('PRE_NAME_ADJUNCT');

  l_person_name_suffix := p_event.getvalueforparameter ('PERSON_SUFFIX');


   --populate the person record

  l_person_rec.person_first_name := l_first_name;
  l_person_rec.person_middle_name := l_middle_name;
  l_person_rec.person_last_name  := l_last_name;
  l_person_rec.person_pre_name_adjunct := l_pre_name_adjunct;
  l_person_rec.person_name_suffix := l_person_name_suffix;
  l_person_rec.created_by_module := G_CREATED_BY_MODULE;
  l_person_rec.application_id    := 0;

  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXIBURB.createpersonpartyinternal',
                'invoking Hz_party_v2_pub.createperson');
  end if;


  HZ_PARTY_V2PUB.create_person (
    p_person_rec                 => l_person_rec,
    x_party_id                   => p_person_party_id,
    x_party_number               => l_party_number,
    x_profile_id                 => l_profile_id,
    x_return_status              => X_Return_Status,
    x_msg_count                  => X_Msg_Count,
    x_msg_data                   => X_Msg_Data);

  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXIBURB.createpersonpartyinternal',
                'completed Hz_party_v2_pub.createperson: ' || x_return_status);
  end if;

  if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXIBURB.createpersonpartyinternal.end','');
  end if;

END CreatePersonPartyInternal;



Procedure CreateContactPointInternal (p_event in out NOCOPY WF_EVENT_T,
                                     p_contact_party_id in  varchar2)
IS


  l_contact_point_id hz_contact_points.contact_point_id%type;
  l_contact_preference_id hz_contact_preferences.contact_preference_id%type;
  l_email_format HZ_CONTACT_POINTS.email_format%type;
  l_email_address HZ_CONTACT_POINTS.email_address%type;
  --initially this was raw phone num changed to phone_number
  -- bug #3483248
  l_primary_phone HZ_CONTACT_POINTS.phone_number%type;
  l_area_code HZ_CONTACT_POINTS.phone_area_code%type;
  l_country_code HZ_CONTACT_POINTS.phone_country_code%type;
  l_phone_purpose HZ_CONTACT_POINTS.contact_point_purpose%type;
  l_phone_extension HZ_CONTACT_POINTS.phone_extension%type;
  l_profile_id   number;


  l_contact_point_rec    HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
  l_email_rec            HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
  l_phone_rec            HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;

  X_Return_Status               VARCHAR2 (20);
  X_Msg_Count                   NUMBER;
  X_Msg_data                    VARCHAR2 (300);

BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXIBURB.createcontactpointinternal.begin','');
  end if;

-- get the values from event object
  l_email_address := p_event.getvalueforparameter ('EMAIL_ADDRESS');
  l_email_format := p_event.getvalueforparameter ('EMAIL_PREFERENCE');
  l_primary_phone := p_event.getvalueforparameter ('PRIMARY_PHONE');
  l_area_code     := p_event.getvalueforparameter ('AREA_CODE');
  l_country_code  := p_event.getvalueforparameter ('COUNTRY_CODE');
  l_phone_purpose := p_event.getvalueforparameter ('PHONE_PURPOSE');
  l_phone_extension := p_event.getvalueforparameter ('PHONE_EXTENSION');


--populate the record

  l_contact_point_rec.status :=             'A';
  l_contact_point_rec.owner_table_name :=   'HZ_PARTIES';
  l_contact_point_rec.owner_table_id :=     p_contact_party_id;
  l_contact_point_rec.primary_flag :=       'Y';
  l_contact_point_rec.created_by_module :=  G_CREATED_BY_MODULE;
  l_contact_point_rec.application_id    :=  0;

  if l_email_address is not null then
    l_contact_point_rec.contact_point_type := 'EMAIL';

    l_email_rec.email_address := l_email_address;
    l_email_rec.email_format  := l_email_format;



    HZ_CONTACT_POINT_V2PUB.create_contact_point (
    p_contact_point_rec           => l_contact_point_rec,
    p_email_rec                   => l_email_rec,
    x_contact_point_id            => l_contact_point_id,
    x_return_status              => X_Return_Status,
    x_msg_count                  => X_Msg_Count,
    x_msg_data                   => X_Msg_Data);


    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXIBURB.createcontactpointinternal',
                'processed HZ_CONTACT_POINT_V2 mail: ' || x_return_status);
    end if;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

  end if; --mail address not null



  if l_primary_phone is not null then
    l_contact_point_rec.contact_point_type := 'PHONE';
    l_contact_point_rec.contact_point_purpose := l_phone_purpose;
    --bug #3483248
    l_phone_rec.phone_number := l_primary_phone;
    l_phone_rec.phone_area_code := l_area_code;
    l_phone_rec.phone_country_code := l_country_code;
    l_phone_rec.phone_extension := l_phone_extension;
    l_phone_rec.phone_line_type := 'GEN';

    HZ_CONTACT_POINT_V2PUB.create_contact_point (
      p_contact_point_rec               => l_contact_point_rec,
      p_phone_rec                       => l_phone_rec,
      x_contact_point_id                => l_contact_point_id,
      x_return_status                   => X_Return_Status,
      x_msg_count                       => X_Msg_Count,
      x_msg_data                        => X_Msg_Data );


      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXIBURB.createcontactpointinternal',
                'processed HZ_CONTACT_POINT_V2 phone: ' || x_return_status);
      end if;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;


  end if;

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXIBURB.createcontactpointinternal.end','');
  end if;

END CreateContactPointInternal;






--
-- Procedure
-- Registerb2bUser_Internal
-- Description
--    check if ame approval has been defined for this registration service.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity (instance id).
--   command  - Run/Cancel/Timeout
-- OUT
--  resultout - result of the process based on which the next step is followed

Procedure RegisterB2BUser_Internal (p_event in out NOCOPY WF_EVENT_T,
                               p_person_party_id out NOCOPy varchar2) IS


l_org_contact_id                    NUMBER;
l_party_rel_id                      NUMBER;
l_profile_id                        NUMBER;
l_org_party_id                      NUMBER;

l_org_contact_rec               HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
l_party_rel_rec                 HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
x_org_contact_party_id          NUMBER;
l_party_id                      NUMBER;-- to be used for contactpoints
l_party_number                  VARCHAR2 (100);

X_Return_Status               VARCHAR2 (20);
X_Msg_Count                   NUMBER;
X_Msg_data                    VARCHAR2 (300);

Begin
--null;
-- create person.
if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.Registerb2bUser_Internal.begin',
        '');
end if;


  CreatePersonPartyInternal (p_event, p_person_party_id);

--  l_org_party_id := p_event.getvalueforparameter ('ORG_PARTY_ID');

-- create org relation for this personpartyId and the organization Number

l_org_party_id := p_event.getvalueforparameter ('ORGANIZATION_PARTY_ID');

l_party_rel_rec.subject_id                    :=  p_person_party_id;
l_party_rel_rec.subject_type                  :=  'PERSON';
l_party_rel_rec.subject_table_name            :=  'HZ_PARTIES';
l_party_rel_rec.relationship_type             :=  'EMPLOYMENT';
l_party_rel_rec.relationship_code             :=  'EMPLOYEE_OF';
l_party_rel_rec.start_date                    :=  sysdate; -- change later
l_party_rel_rec.object_id                     :=  l_org_party_id;
l_party_rel_rec.object_type                   :=  'ORGANIZATION';
l_party_rel_rec.object_table_name             :=  'HZ_PARTIES';
l_party_rel_rec.created_by_module             := G_CREATED_BY_MODULE;
l_party_rel_rec.application_id                := 0;
l_org_contact_rec.party_rel_rec               :=  l_party_rel_rec;
l_org_contact_rec.created_by_module           := G_CREATED_BY_MODULE;
l_org_contact_rec.application_id              := 0;

HZ_PARTY_CONTACT_V2PUB.create_org_contact (
        --p_init_msg_list             =>  P_Init_Msg_List,
        p_org_contact_rec          =>  l_org_contact_rec,
        x_org_contact_id           =>  x_org_contact_party_id,
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

CreateContactPointInternal (p_event, to_char (l_party_id));

-- create contact

if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.Registerb2bUser_Internal.end',
        '');
end if;
end RegisterB2BUser_Internal;


  --
  -- Procedure
  -- RegisterB2CUser_Internal
  -- Description
  --    check if ame approval has been defined for this registration service.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

Procedure RegisterB2CUser_Internal (p_event in out NOCOPY WF_EVENT_T,
                                 p_person_party_id out NOCOPY varchar2 )

  IS
l_contact_preference_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
l_contact_preference VARCHAR2 (5);
l_contact_preference_id number;
X_Return_Status               VARCHAR2 (20);
X_Msg_Count                   NUMBER;
X_Msg_data                    VARCHAR2 (300);
BEGIN

if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.RegisterB2CUser_Internal.begin',
        '');
end if;
  -- Create individual person party

  CreatePersonPartyInternal (p_event,p_person_party_id);
  CreateContactPointInternal (p_event,p_person_party_id);

  -- populate contact preference
  l_contact_preference := p_event.getvalueforparameter ('CONTACT_PREFERENCE');

  if (l_contact_preference = 'Y') then
  l_contact_preference_rec.preference_code := 'DO';
  else
  l_contact_preference_rec.preference_code := 'DO_NOT';
  end if;

  l_contact_preference_rec.contact_level_table := 'HZ_PARTIES';
  l_contact_preference_rec.contact_level_table_id := p_person_party_id;
  l_contact_preference_rec.contact_type := 'EMAIL';
  l_contact_preference_rec.requested_by := 'INTERNAL';
  l_contact_preference_rec.created_by_module := G_CREATED_BY_MODULE;
  l_contact_preference_rec.application_id := 0;

  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
       'fnd.plsql.UMXIBURB.RegisterB2CUser_Internal',
        'invoking hz_createContactpreference for party_id:' || p_person_party_id);
  end if;

  HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
     p_contact_preference_rec          => l_contact_preference_rec,
     x_contact_preference_id           => l_contact_preference_id,
     x_return_status                   => x_return_status,
     x_msg_count                       => x_msg_count,
     x_msg_data                        => x_msg_data
     );

  if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.RegisterB2CUser_Internal.end',
        '');
end if;
END RegisterB2CUser_Internal;


   --
  --  Function
  --  create_person_party
  --
  -- Description
  -- This method is a subscriber to the event oracle.apps.fnd.umx.createpersonp
  -- TCA apis are used to populate into hz tables
  -- based on the page from where this is invoked, a B2B or B2C party is created
  -- IN
  -- the signature follows Workflow business events standards
  --  p_subscription_guid  - Run/Cancel/Timeout
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --

function create_person_party (p_subscription_guid in raw,
                             p_event in out NOCOPY WF_EVENT_T)
                             return varchar2 is



BEGIN

if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.Createpersonparty.begin',
        '');
end if;

-- removing all the implimentation since we split this into two subscriptions
-- register_individual_user and register_business_user
-- this code should never be invoked. Disabled the subscription
 return 'ERROR';
END create_person_party;

  --
  -- Procedure
  --   Get_Party_Email_Address
  -- Description
  --   This API will ...
  --     Get the email address from the person party.
  --   If email is missing, then ...
  --     Get the email address from the party relationship.
  --   If email is still missing, then return null
  --
  -- IN
  --   p_person_party_id - The party ID of the person defined in hz_parties table
  -- OUT
  --   x_email_address   - Email address of the person

  Procedure Get_Party_Email_Address (p_person_party_id in  hz_parties.party_id%type,
                                     x_email_address   out NOCOPY hz_parties.email_address%type) is

    cursor get_email_from_person_party (p_person_party_id in hz_parties.party_id%type) is
      select email_address
      from   hz_parties
      where  party_id = p_person_party_id;

    cursor get_email_from_party_rel (p_person_party_id in hz_parties.party_id%type) is
      select hzp_rel.email_address
      from  hz_parties hzp_rel, hz_relationships hzr
      where hzr.subject_id = p_person_party_id
      and   hzr.party_id = hzp_rel.party_id
      and   hzp_rel.email_address is not null;

  begin

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXIBURB.GetPartyEmailAddress.begin',
                      'personPartyId: ' || p_person_party_id);
    end if;

    open get_email_from_person_party (p_person_party_id);
    fetch get_email_from_person_party into x_email_address;
    close get_email_from_person_party;

    if (x_email_address is null) then
      -- We need to get the email address from Party Relationship table
      open get_email_from_party_rel (p_person_party_id);
      fetch get_email_from_party_rel into x_email_address;
      close get_email_from_party_rel;
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXIBURB.getpartyemailaddress.end',
                      'emailAddress: ' || x_email_address);
 end if;

  end Get_Party_Email_Address;

FUNCTION GET_PERSON_EMAIL_ADDRESS (p_person_party_id in  hz_parties.party_id%type) return varchar2 is

l_email_address hz_parties.email_address%type;
begin

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.getpersonemailaddress.begin',
        'Invoking getPartyemailaddress:' || p_person_party_id);
  end if;

  Get_Party_Email_Address (p_person_party_id => p_person_party_id,
                           x_email_address   => l_email_address);

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
        'fnd.plsql.UMXIBURB.getpersonemailaddress.end',
        'after getPartyemailaddress:' || l_email_address);
  end if;

 return l_email_address;

end GET_PERSON_EMAIL_ADDRESS;

  --
  --  Function
  --  Register_Business_user
  --
  -- Description
  -- This method is a subscriber to the event oracle.apps.fnd.umx.b2bparty.create
  -- TCA apis are used to populate into hz tables
  -- This method creates a business User
  -- IN
  -- the signature follows Workflow business events standards
  --  p_subscription_guid  - Run/Cancel/Timeout
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --
  function Register_Business_User (p_subscription_guid in raw,
                                   p_event in out NOCOPY WF_EVENT_T) return varchar2 is

    l_parameter_list wf_parameter_list_t;
    l_success VARCHAR2 (10);
    p_person_party_id varchar2 (30);

  BEGIN

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXIBURB.Register_Business_User.begin',
                     'Begin');
    end if;

    if (p_event.getValueForParameter ('UMX_CUSTOM_EVENT_CONTEXT') = UMX_PUB.BEFORE_ACT_ACTIVATION) then


      /**
      **log all the params passed to this subscription
      */
      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        l_parameter_list := p_event.getparameterlist ();
        for i in 1..l_parameter_list.count loop
         if (lower(l_parameter_list(i).getName()) not like '%password%') then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                          'fnd.plsql.UMXIBURB.Register_Business_User',
                          'name:' || l_parameter_list (i).getName () ||
                          ' value:' || l_parameter_list (i).getValue ());
         end if;
        end loop;
      end if;

      --create B2B party and populate the event object back to main workflow

      RegisterB2BUser_Internal (p_event,p_person_party_id);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXIBURB.Register_Business_User',
                        'Invoking setevent object personPartyId: ' || p_person_party_id);
      end if;

      l_success := UMX_REGISTRATION_UTIL.set_event_object (p_event, 'PERSON_PARTY_ID', p_person_party_id);
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXIBURB.Register_Business_User.end',
                      'End');
    end if;
    return 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXIBURB.Register_Business_User',
                        'Exception occurs');
      end if;

      WF_CORE.CONTEXT ('UMX_REGISTER_USER_PVT', 'REGISTER_BUSINESS_USER',
                      p_event.getEventName ( ),p_subscription_guid,
                      sqlerrm,sqlcode);

      WF_EVENT.SetErrorInfo (p_event,'ERROR');

      return 'ERROR';

  END Register_Business_User;


  --
  --  Function
  --  Register_Individual_User
  --
  -- Description
  -- This method is a subscriber to the event oracle.apps.fnd.umx.b2cparty.create
  -- TCA apis are used to populate into hz tables
  -- This method creates a business User
  -- IN
  -- the signature follows Workflow business events standards
  --  p_subscription_guid  - Run/Cancel/Timeout
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --
  function Register_Individual_user (p_subscription_guid in raw,
                                     p_event in out NOCOPY WF_EVENT_T) return varchar2 is

    l_parameter_list wf_parameter_list_t;
    l_success VARCHAR2 (10);
    p_person_party_id varchar2 (30);

  BEGIN

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXIBURB.Register_Individual_user.begin',
                      'Begin');
    end if;

    if (p_event.getValueForParameter ('UMX_CUSTOM_EVENT_CONTEXT') = UMX_PUB.BEFORE_ACT_ACTIVATION) then

      /**
      **log all the params passed to this subscription
      */

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

        l_parameter_list := p_event.getparameterlist ();
        for i in 1..l_parameter_list.count loop
         if (lower(l_parameter_list (i).getName ()) not like '%password%') then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                          'fnd.plsql.UMXIBURB.Register_Individual_user','name:' || l_parameter_list (i).getName () ||
                          ' value:' || l_parameter_list (i).getValue ());
         end if;
        end loop;

      end if;

      --create B2C party and populate the event object back to main workflow
      RegisterB2CUser_Internal (p_event, p_person_party_id);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXIBURB.Register_Individual_user',
                        'Invoking setevent object personPartyId: ' || p_person_party_id);
      end if;

      l_success := UMX_REGISTRATION_UTIL.set_event_object (p_event,'PERSON_PARTY_ID', p_person_party_id);

    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXIBURB.Register_Individual_user.end',
                      'End');
    end if;
    return 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN

      WF_CORE.CONTEXT ('UMX_REGISTER_USER_PVT', 'REGISTER_Individual_user',
                      p_event.getEventName (), p_subscription_guid,
                      sqlerrm,sqlcode);
      WF_EVENT.SetErrorInfo (p_event,'ERROR');
      return 'ERROR';

  END Register_Individual_User;

  --
  -- Function
  --   userExists
  -- Description
  --   This API is no longer a wrapper for fnd_user_pkg.userExists.  It will
  --   query from fnd_user table and it
  --   will return 'Y' if username is being used and
  --   'N' if username is not being used.
  -- IN
  --   p_user_name - User name
  -- OUT
  --   'Y' - User name is being used.
  --   'N' - User name is not being used.
  function userExists (p_user_name in  fnd_user.user_name%type) return varchar2 is
    retString varchar2 (1);

  cursor get_fnd_user is
    select 'Y' from fnd_user where user_name = p_user_name;

  begin
    open get_fnd_user;
    fetch get_fnd_user into retString;
    if (get_fnd_user%notfound) then
      retString := 'N';
    end if;
    close get_fnd_user;

    return retString;
  end userExists;

  --
  -- Procedure
  --   TestUserName
  -- Description
  --   This API is a wrapper to fnd_user_pkg.TestUserName.
  --   "This api test whether a username exists in FND and/or in OID."
  -- IN
  --   p_user_name - User name to be tested.
  -- OUT
  --   x_return_status - The following statuses are defined in fnd_user_pkg:
  --     USER_OK_CREATE : User does not exist in either FND or OID
  --     USER_INVALID_NAME : User name is not valid
  --     USER_EXISTS_IN_FND : User exists in FND
  --     USER_SYNCHED : User exists in OID and next time when this user gets created
  --                  in FND, the two will be synched together.
  --     USER_EXISTS_NO_LINK_ALLOWED: User exists in OID and no synching allowed.
  --   x_message_app_name - The application short name of the message in the fnd
  --                        message stack that contents the detail message.
  --   x_message_name - The message name of the message in the FND message stack that
  --                    contents the detail message.
  --   x_message_text - The detail message in the FND message stack.
  ----------------------------------------------------------------------------
  Procedure TestUserName (p_user_name        in  fnd_user.user_name%type,
                          x_return_status    out nocopy pls_integer,
                          x_message_app_name out nocopy fnd_application.application_short_name%type,
                          x_message_name     out nocopy fnd_new_messages.message_name%type,
                          x_message_text     out nocopy fnd_new_messages.message_text%type) is

    l_encoded_message varchar2 (32100);

  begin

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXIBURB.TestUserName.begin',
                     'p_user_name=' || p_user_name);
    end if;

    x_return_status := fnd_user_pkg.TestUserName (x_user_name => p_user_name);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT, 'fnd.plsql.UMXIBURB.TestUserName',
                     'After invoking fnd_user_pkg.TestUserName x_return_status=>' || x_return_status);
    end if;

    if (x_return_status = fnd_user_pkg.USER_SYNCHED) then
      x_message_app_name := 'FND';
      x_message_name := 'UMX_REG_USER_SYNCHED_CONF_MSG';
    elsif not (x_return_status = fnd_user_pkg.USER_OK_CREATE) then
      l_encoded_message := fnd_message.get_encoded;
      fnd_message.parse_encoded (encoded_message => l_encoded_message,
                                 app_short_name  => x_message_app_name,
                                 message_name    => x_message_name);
      fnd_message.set_encoded (l_encoded_message);
      x_message_text := fnd_message.get;
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXIBURB.TestUserName.end',
                     'x_message_app_name=' || x_message_app_name || ' x_message_name=' || x_message_name ||
                     ' x_message_text=' || x_message_text);
    end if;

  end TestUserName;

end UMX_REGISTER_USER_PVT;

/
