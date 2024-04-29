--------------------------------------------------------
--  DDL for Package UMX_REGISTER_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REGISTER_USER_PVT" AUTHID CURRENT_USER as
/* $Header: UMXIBURS.pls 120.2 2005/09/01 03:34:25 kching noship $ */
-- Start of Comments
-- Package name     : UMX_REGISTER_USER_PVT
-- Purpose          :
--   This package contains specification individual user registration

--G_CREATED_BY_MODULE VARCHAR2(3) := 'UMX';
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


function create_person_party(p_subscription_guid in raw,
                             p_event in out NOCOPY WF_EVENT_T
                            ) return varchar2;

--
  -- Procedure
  -- check_approval_defined
  -- Description
  --    check if ame approval has been defined for this registration service.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

--Procedure RegisterIndividualUser(p_event in out NOCOPY WF_EVENT_T);

--
  -- Procedure
  -- check_approval_defined
  -- Description
  --    check if ame approval has been defined for this registration service.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

--Procedure RegisterBusinessUser(p_event in out NOCOPY WF_EVENT_T);


G_CREATED_BY_MODULE VARCHAR2(3) := 'UMX';

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
                                     x_email_address   out NOCOPY hz_parties.email_address%type);


  FUNCTION GET_PERSON_EMAIL_ADDRESS(p_person_party_id in  hz_parties.party_id%type) return varchar2;

  --
  --  Function
  --  Register_Individual_User
  --
  -- Description
  -- This method is a subscriber to the event oracle.apps.fnd.umx.individualuser.create
  -- TCA apis are used to populate into hz tables
  -- This method creates a business User
  -- IN
  -- the signature follows Workflow business events standards
  --  p_subscription_guid  - Run/Cancel/Timeout
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --




function Register_Individual_user(p_subscription_guid in raw,
                                p_event in out NOCOPY WF_EVENT_T)
                             return varchar2;

function Register_Business_user(p_subscription_guid in raw,
                                p_event in out NOCOPY WF_EVENT_T)
                             return varchar2;

  --
  -- Function
  --   userExists
  -- Description
  --   This API is a wrapper for fnd_user_pkg.userExists that
  --   will return 'Y' if username is being used and
  --   'N' if username is not being used.
  -- IN
  --   p_user_name - User name
  -- OUT
  --   'Y' - User name is being used.
  --   'N' - User name is not being used.
  function userExists (p_user_name in  fnd_user.user_name%type) return varchar2;

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
                          x_message_text     out nocopy fnd_new_messages.message_text%type);

end UMX_REGISTER_USER_PVT;

 

/
