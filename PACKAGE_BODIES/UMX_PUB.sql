--------------------------------------------------------
--  DDL for Package Body UMX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_PUB" AS
/* $Header: UMXPRRSB.pls 120.5.12010000.2 2009/07/22 19:00:12 jstyles ship $ */

  -- Function         :  get_attribute_value
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  Get the attribute value from the workflow.
  -- input parameters :
  -- @param  p_reg_request_id
  --    Description : Registration Request ID
  --    Required    : Yes
  -- @param  p_attribute_name
  --    Description : Attribute name
  --    Required    : Yes
  -- Output           :
  --    Description : Attribute value
  --
  function get_attribute_value (
    p_reg_request_id in UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE,
    p_attribute_name in varchar2
  ) return varchar2 is

  l_value varchar2 (4000);
  l_registration_data wf_event_t;

  begin

    l_value := wf_engine.GetItemAttrText (
        itemtype        => UMX_REGISTRATION_UTIL.G_ITEM_TYPE,
        itemkey         => p_reg_request_id,
        aname           => p_attribute_name,
        ignore_notfound => true);

    if (l_value is null) then

      -- Try to get the attribute value from the Event Object
      l_registration_data :=
        wf_engine.getitemattrevent (itemtype => UMX_REGISTRATION_UTIL.G_ITEM_TYPE,
            itemkey  => p_reg_request_id,
            name     => 'REGISTRATION_DATA');

      l_value := wf_event.GetValueForParameter (
                   p_name          => p_attribute_name,
                   p_parameterlist => l_registration_data.getParameterList);
    end if;
    return (l_value);

  end get_attribute_value;

  --
  -- Procedure        :  assign_role
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API will assign or launch wf to assign role.
  -- Input Parameters (Mandatory):
  -- p_registration_data : Table of record type of UMX_REGISTRATION_DATA
  -- Output Parameters:
  -- p_registration_data : Table of record type of UMX_REGISTRATION_DATA
  --

  procedure assign_role (p_registration_data in out NOCOPY UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL) IS

    x_return_status varchar2 (4000);
    x_message_data varchar2 (4000);
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXPRRSB.assignRole.begin', '');
    end if;

    UMX_PUB.assign_role (p_registration_data, x_return_status, x_message_data);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'fnd.plsql.UMXPRRSB.assignRole.end', '');
    end if;
  end assign_role;


  procedure assign_role (p_registration_data in out NOCOPY UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL
    , x_return_status out NOCOPY varchar2
 		, x_message_data out NOCOPY varchar2) IS
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXPRRSB.assignRole.begin', '');
    end if;

    UMX_REGISTRATION_PVT.assign_role (p_registration_data, x_return_status, x_message_data);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXPRRSB.assignRole.end', '');
    end if;
  end assign_role;

  --
  -- Procedure        :  updateWfAttribute
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API can be invoked by anyone who registers a pl/sql subscription to
  --                     UMX raised Business Events during registration. This api will update the main
  -- 			 User Management workflow event(payload) object and also the corresponding
  --			 workflow attribute. If p_attr_name doesnt exist in the workflow, one is created.
  --                     This API can also be called by anyone who has a custom notification workflow
  --			 defined, and want this name value pair to be reflected in the main workflow;
  --			 this name value pair will be available to rest of subscriptions and workflow
  --			 activities.
  -- thi
  -- Input Parameters (Mandatory):
  -- p_event : Oracle Worflow WF_EVENT_T object type
  -- Input params (Optional)
  -- p_attr_name : Varchar2, name of the attribute, maps to workflow attribute name.
  -- p_attr_value : varchar2, value of the attribute, maps to workflow attibute string value.

  -- Output Parameters:
  -- p_event : Oracle Worflow WF_EVENT_T object type
  --
  procedure updateWfAttribute (p_event in out NOCOPY WF_EVENT_T,
  			       p_attr_name in VARCHAR2 DEFAULT NULL,
			       p_attr_value in VARCHAR2 DEFAULT NULL) is
  l_status varchar2(30);
  begin
   l_status := umx_registration_util.set_event_object (p_event => p_event,
                                                       p_attr_name => p_attr_name,
						       p_attr_value => p_attr_value);
   EXCEPTION
   WHEN OTHERS THEN
   RAISE;
  end updateWfAttribute;
  --
  -- Procedure        :  notification_process_done
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This api will restart the sleeping main workflow.
  procedure Notification_Process_Done (item_type    in  varchar2,
                                       item_key     in  varchar2,
                                       activity_id  in  number,
                                       command      in  varchar2,
                                       resultout    out NOCOPY varchar2) is
  BEGIN

   UMX_NOTIFICATION_UTIL.Notification_process_done
                                 ( item_type => item_type,
				   item_key  => item_key,
				   activity_id => activity_id,
				   command => command,
				   resultout => resultout);

   EXCEPTION
   WHEN OTHERS THEN
   RAISE;

  END Notification_process_done;

  --
  -- Procedure        :  get_suggested_username
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API will return the suggested user name for a person.
  --                     The user name will be generated via the
  --                     oracle.apps.fnd.umx.username.generate Business Event
  --                     which will be raised by this API.  The event could
  --                     return a null value as the user name if the user name
  --                     could not be generated.
  -- Input Parameters :
  -- @param     p_person_party_id
  --    Description:  Person Party ID of the person who to generate
  --                  a username for.
  --    Required   :  N
  -- Output Parameters :
  --   x_suggested_username: Username generated by the Username Policy. May return null.
  --
  --
  procedure get_suggested_username (p_person_party_id    in HZ_PARTIES.PARTY_ID%TYPE default null,
                                    x_suggested_username out nocopy FND_USER.USER_NAME%TYPE) is
  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXPRRSB.get_suggested_username.begin',
                      'p_person_party_id: ' || p_person_party_id);
    end if;

    UMX_USERNAME_POLICY_PVT.get_suggested_username (p_person_party_id    => p_person_party_id,
                                                    x_suggested_username => x_suggested_username);

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXPRRSB.get_suggested_username.end',
                      'x_suggested_username: ' || x_suggested_username);
    end if;

  end get_suggested_username;

  --
  -- Procedure        :  get_username_policy_desc
  -- Type             :  Public
  -- Pre_reqs         :  None
  -- Description      :  This API will return the description of the user name
  --                     policy.  The return parameters / user name policy is
  --                     based on the UMX: User Name Policy (UMX_USERNAME_POLICY)
  --                     profile option, which points to a LOOKUP TYPE that
  --                     should include the following:
  --
  --                       LOOKUP CODES: DESCRIPTION, PROMPT, HINT
  --
  --                     with the appropriate LOOKUP MEANING defined. Example:
  --
  --                       LOOKUP TYPE: UMX_USERNAME_POLICY:EMAIL
  --
  --  LOOKUP CODE    MEANING                     DESCRIPTION
  --  -----------    --------------------------  -------------------------------
  --  PROMPT         User Name                   Prompt of the user name text
  --                                             input field.
  --
  --  DESCRIPTION    User Names must be based    Description of the policy
  --                 on Email Address
  --
  --  HINT           example: michael@email.com  Example of what the username should
  --                                             look like.
  --
  -- Input Parameters :
  -- Output Parameters :
  -- x_policy_code:      User Name Policy code. Preseeded policies are:
  --
  --                     Code: UMX_USERNAME_POLICY:EMAIL
  --                     Meaning: User name should be defined as Email Address.
  --                              Product teams may choose to hide the email
  --                              field in any account creation / registration
  --                              UI's as long as the entered username (email)
  --                              is copied into the fnd_user.email_address field
  --                              as well.
  --
  --                     Code: UMX_USERNAME_POLICY:NONE
  --                     Meaning: No username policy / format defined, freetext
  --
  --                     Code: Anything else, this would be a custom policy defined
  --                           at a client site.
  --
  -- x_description:      User Name Policy description. May be null. For example:
  --
  --                       "User Names must be based on <b>Email Address</b>".
  --                       The description can be displayed as a quick tip in
  --                       the user account creation/registration page.
  --
  -- x_prompt:           Prompt of the User Name field. Defaults to "User Name" if
  --                     none is defined in the policy.
  --
  -- x_hint:             An example of the user name format. May be null. For
  --                     example:
  --
  --                       "(example: first.last@domain.com)"
  --
  --                     The hint can be displayed as an inline hint below the
  --                     User Name field in any user account creation/registration
  --                     page.
  --
  --
  procedure get_username_policy_desc
                (x_policy_code out nocopy FND_LOOKUP_TYPES.LOOKUP_TYPE%TYPE,
                 x_description out nocopy FND_LOOKUP_VALUES.MEANING%TYPE,
                 x_prompt      out nocopy FND_LOOKUP_VALUES.MEANING%TYPE,
                 x_hint        out nocopy FND_LOOKUP_VALUES.MEANING%TYPE) is

  begin

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXPRRSB.get_username_policy_desc.begin', '');
    end if;

    UMX_USERNAME_POLICY_PVT.get_username_policy_desc (x_policy_code => x_policy_code,
                                                      x_description => x_description,
                                                      x_prompt      => x_prompt,
                                                      x_hint        => x_hint);


    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXPRRSB.get_username_policy_desc.end',
                      'x_policy_code: ' || x_policy_code ||
                      ' | x_description: ' || x_description ||
                      ' | x_prompt: '      || x_prompt ||
                      ' | x_hint: '        || x_hint);
    end if;

  end get_username_policy_desc;

END UMX_PUB;

/
