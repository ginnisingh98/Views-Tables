--------------------------------------------------------
--  DDL for Package Body UMX_REGISTRATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REGISTRATION_UTIL" as
/* $Header: UMXUTILB.pls 120.15.12010000.8 2017/11/22 11:53:32 avelu ship $ */

  -- Procedure
  -- check_approval_status
  -- (DEPRECATED API)
  -- Description
  --    check if request has been approved or not
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure Check_Approval_Status (item_type    in  varchar2,
                                   item_key     in  varchar2,
                                   activity_id  in  number,
                                   command      in  varchar2,
                                   resultout    out NOCOPY varchar2) is
    l_approval_result varchar2 (30);
  BEGIN
  /*
  **logging enter of method
  */

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkApprovalStatus.begin','');
    end if;

    if (command = 'RUN') then
      l_approval_result := wf_engine.getitemattrtext (itemtype => item_type,
                                                     itemkey => item_key,
                                                     aname => 'APPROVAL_RESULT',
                                                     ignore_notfound => false);

      if (l_approval_result is not null and l_approval_result = 'APPROVED') then
        resultout := 'COMPLETE:APPROVED';
      else
        resultout := 'COMPLETE:REJECTED';
      end if;
    end if;
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkApprovalStatus.end','');
    end if;
  END Check_Approval_Status;

  -- function to check if approval workflow has to be launched or not
  -- commenting out isadmin until decision is made on how to handle it
  -- will always return false.
  function check_admin_priv (l_requested_by_user_id in number)
                                             return boolean is

  begin


  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkadminpriv.begin',
                'RequestedByUserid: '||l_requested_by_user_id);
  end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkadminpriv.end','Return false');
    end if;

    return false;
  end check_admin_priv;


 --Function
 --Check_admin_grants
 -- this function checks if the requested_by_user_id has the grants
 -- and that will skip the approval for additional access regservices.

  function check_admin_grants (l_requested_by_user_id in number) return boolean is

    cursor getUsername is
      select user_name
      from fnd_user
      where user_id = l_requested_by_user_id
      and  nvl (start_date, SYSDATE) <= SYSDATE
      and nvl (end_date, SYSDATE + 1) > SYSDATE ;

    count int;
    priv boolean;
    l_username FND_USER.USER_NAME%TYPE;

  begin


  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkadmingrants.begin',
                'RequestedByUserid: '||l_requested_by_user_id);
  end if;

    open getUsername;
    fetch getUsername into l_username;

    if (getUsername%notfound) then
    close getUsername;
    raise_application_error ('-20000',' Invalid Requested_by_user_id was passed to check admin priv');
    end if;
    close getUsername;

    priv := fnd_function.test_instance (function_name => 'UMX_SYSTEM_ACCT_ADMINSTRATION',
                          user_name  => l_username);

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkadmingrants.end',
                'return : ');
   end if;

    return priv;



  end check_admin_grants;

  -- Procedure
  -- print_Event_params
  -- prints all the event obj params
  --
  procedure print_Event_params (p_event in wf_event_t) is
  l_parameter_list wf_parameter_list_t;
  i number ;
  BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   l_parameter_list := p_event.getparameterlist ();
   for i in 1..l_parameter_list.count loop
     if (lower(l_parameter_list (i).getName()) not like '%password%') then
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXUTILB.print','name:'||l_parameter_list (i).getName ()||
                 ' value:'||l_parameter_list (i).getValue ());
     end if;
   end loop;
   end if;

  END print_event_params;

  --
  -- Procedure
  -- add_Param_to_Event
  -- adds the parameter name value pair to the event object
  --

  Procedure add_param_to_event (p_item_type in varchar2,
                                p_item_key  in varchar2,
                                p_attr_name in varchar2,
                                p_attr_value in varchar2) is
    l_event wf_event_t;
  BEGIN
    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.addparamtoevent.begin','');
    end if;

    l_event := wf_engine.getitemattrevent (itemtype => p_item_type,
                                          itemkey => p_item_key,
                                          name => 'REGISTRATION_DATA');
    l_event.addParametertoList (p_attr_name,p_attr_value);
    wf_engine.setitemattrevent (itemtype => p_item_type,
                               itemkey => p_item_key,
                               name => 'REGISTRATION_DATA',
                               event => l_event);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       if (lower(p_attr_name) not like '%password%') then
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                     'fnd.plsql.UMXUTILB.addparamtoevent','name: '||p_attr_name
                      ||' value: '||p_attr_value);
       end if;
    end if;
    EXCEPTION
     WHEN others THEN
     raise;
  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.addparamtoevent.end','');
  end if;
  END add_param_to_event;

  --
  -- Procedure
  -- assign_wf_role
  --
  -- Description
  -- populate the wf_local_roles table with information from workflow
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure assign_wf_role (item_type    in  varchar2,
                            item_key     in  varchar2,
                            activity_id  in  number,
                            command      in  varchar2,
                            resultout    out NOCOPY varchar2) is

    l_wf_role_name wf_local_roles.name%type;
    l_requested_for_user_id  fnd_user.user_id%type;
    l_user_name  fnd_user.user_name%type;
    l_user_role_start_date DATE;
    l_user_role_expiration_date DATE;
    l_justification UMX_REG_REQUESTS.JUSTIFICATION%TYPE;
    l_regsvc_disp_name umx_reg_services_tl.display_name%type;

    cursor get_username_from_userid (p_user_id in number) is
      select user_name
      from fnd_user
      where user_id = p_user_id;

  BEGIN

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.assignwfRole.begin','itemkey: '||item_key);
    end if;

    if (command = 'RUN') then
      l_wf_role_name := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname => 'WF_ROLE_NAME',
                                                  ignore_notfound => false);


      l_user_role_start_date := nvl(fnd_date.canonical_to_date (
                                  wf_engine.getitemattrtext (itemtype => item_type,
                                    itemkey => item_key,
                                    aname => 'REQUESTED_START_DATE',
                                    ignore_notfound => false)),sysdate);

     if l_user_role_start_date < sysdate then
          l_user_role_start_date := sysdate;
     end if;

      l_user_role_expiration_date :=  fnd_date.canonical_to_date (
                                       wf_engine.getitemattrtext (itemtype => item_type,
                                         itemkey => item_key,
                                         aname => 'REQUESTED_END_DATE',
                                         ignore_notfound => false));

      l_requested_for_user_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                         itemkey => item_key,
                                                         aname => 'REQUESTED_FOR_USER_ID',
                                                         ignore_notfound => false);

      l_user_name := wf_engine.getitemattrtext (itemtype => item_type,
                                               itemkey => item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => false);

      if (l_user_name is null) then
        open get_username_from_userid (l_requested_for_user_id);
        fetch get_username_from_userid into l_user_name;
        close get_username_from_userid;
      end if;

      if (l_user_name is not null and l_wf_role_name is not null) then

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXUTILB','invoking propagateuserrole '||
                'rolename:'||l_wf_role_name||' username:'||l_user_name);
        end if;

        l_justification := wf_engine.getitemattrtext (
                             itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'JUSTIFICATION');

        if (l_justification is null) or (l_justification = '') then
          -- Jusification is null or empty string.  In that case, get the default
          -- justification from the FND Message.
          l_regsvc_disp_name := wf_engine.getitemattrtext (
              itemtype => item_type,
              itemkey  => item_key,
              aname    => 'REGSVC_DISP_NAME');

          fnd_message.set_name (application => 'FND',
                                name        => 'UMX_ROLE_DEFAULT_JUSTIFICATION');
          fnd_message.set_token (token => 'REG_PROCESS_DISPLAY_NAME',
                                 value => l_regsvc_disp_name);
          l_justification := fnd_message.get;
        end if;

        wf_local_synch.propagateUserRole (p_user_name        => l_user_name,
                                          p_role_name        => l_wf_role_name,
                                          p_start_date       => l_user_role_start_date,
                                          p_expiration_date  => l_user_role_expiration_date,
                                          p_raiseErrors      => true,
                                          p_assignmentReason => l_justification);

        UMX_REG_REQUESTS_PKG.UPDATE_ROW (X_REG_REQUEST_ID => to_number (item_key),
                                         X_STATUS_CODE => 'APPROVED');
     end if;
      resultout := 'COMPLETE';
    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.assignwfRole.end','itemkey: '||item_key);
   end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'assign_wf_role', item_type, item_key, activity_id);
      raise;
  END assign_wf_role;

  --
  -- Procedure
  -- check_approval_defined
  -- Description
  --    check if ame approval has been defined for this registration service.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure check_approval_defined (item_type    in  varchar2,
                                    item_key     in  varchar2,
                                    activity_id  in  number,
                                    command      in  varchar2,
                                    resultout    out NOCOPY varchar2) is

    l_ame_transaction_type_id AME_TRANSACTION_TYPES_V.TRANSACTION_TYPE_ID%TYPE;
    l_ame_application_id AME_TRANSACTION_TYPES_V.FND_APPLICATION_ID%TYPE;
    l_reg_svc_code UMX_REG_SERVICES_B.REG_SERVICE_CODE%TYPE;
    l_reg_svc_type UMX_REG_SERVICES_B.REG_SERVICE_TYPE%TYPE;
    l_requested_by_user_id fnd_user.user_id%type;
    l_requested_for_user_id fnd_user.user_id%type;
    l_rby_userid_string WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_rfor_userid_string WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_launch_workflow boolean := false;

  BEGIN
  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkapprovaldefined.begin','itemkey: '||item_key);
  end if;

    if (command = 'RUN') then
      l_ame_transaction_type_id := wf_engine.getitemattrtext (
          itemtype => item_type,
          itemkey => item_key,
          aname => 'AME_TRANSACTION_TYPE_ID',
          ignore_notfound => false);

      l_ame_application_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                        itemkey => item_key,
                                                        aname => 'AME_APPLICATION_ID',
                                                        ignore_notfound => false);

      l_reg_svc_code := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname => 'REG_SERVICE_CODE',
                                                  ignore_notfound => false);

      l_reg_svc_type := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname => 'REG_SERVICE_TYPE',
                                                  ignore_notfound => false);
      l_rby_userid_string := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                 aname => 'REQUESTED_BY_USER_ID',
                                                  ignore_notfound => false);
      l_requested_by_user_id := to_number (l_rby_userid_string);
      l_rfor_userid_string := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname => 'REQUESTED_FOR_USER_ID',
                                                  ignore_notfound => false);
      l_requested_for_user_id := to_number (l_rfor_userid_string);

      -- continue launching the approval wf if one is defined and the
      -- requested by user is not the one approver privilages
      -- skip the approval if logged in user is privilaged admin
      -- launch the workflow even if the admin is privilaged but request is ADMIN_CREATION

     if ((l_reg_svc_type = 'SELF_SERVICE') or
         (l_reg_svc_type = 'ADMIN_ADDITIONAL_ACCESS')) then

         l_launch_workflow := true;

     elsif ((l_reg_svc_type = 'ADDITIONAL_ACCESS' and
            not check_admin_priv (l_requested_by_user_id) and
            not check_admin_grants (l_requested_by_user_id)) or
            l_requested_by_user_id = l_requested_for_user_id) then

         l_launch_workflow := true;

     elsif (l_reg_svc_type = 'ADMIN_CREATION' and
             not check_admin_priv (l_requested_by_user_id)) then

         l_launch_workflow := true;

     end if;

     if (l_launch_workflow and
        l_ame_transaction_type_id is not null and
         l_ame_application_id is not null) then

        resultout := 'COMPLETE:Y';
        wf_engine.setItemattrtext (itemtype => item_type,
                                   itemkey  => item_key,
                                   aname  => 'NOTIFICATION_CONTEXT',
                                   avalue => 'APPROVAL_REQUIRED');

      else
        resultout := 'COMPLETE:N';
      end if;
    end if;

 if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkapprovaldefined.end','itemkey: '||item_key);
 end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'check_approval_defined', item_type, item_key, activity_id);
      raise;
  END check_approval_defined;

  --
  -- Procedure
  -- check_idnty_vrfy_reqd
  -- Description
  -- Check if identity verification is required
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure check_idnty_vrfy_reqd (item_type    in  varchar2,
                                   item_key     in  varchar2,
                                   activity_id  in  number,
                                   command      in  varchar2,
                                   resultout    out NOCOPY varchar2) is

    l_identity_vrfy_reqd UMX_REG_SERVICES_B.EMAIL_VERIFICATION_FLAG%TYPE;
  BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUTILB.checkidntyvrfyreqd.begin',
                     'itemkey: '||item_key);
  end if;

    if (command = 'RUN') then
      l_identity_vrfy_reqd := wf_engine.getitemattrtext (itemtype => item_type,
                                                        itemkey => item_key,
                                                        aname => 'IDENTITY_VERIFICATION_REQD',
                                                        ignore_notfound => true);
      if (l_identity_vrfy_reqd is not null AND l_identity_vrfy_reqd = 'Y') then
        wf_engine.setItemattrtext (itemtype => item_type,
                                   itemkey  => item_key,
                                   aname  => 'NOTIFICATION_CONTEXT',
                                   avalue => 'IDENTITY_VERIFICATION');
        -- update the status in the reg table to VERIFYING
        UMX_REG_REQUESTS_PKG.update_row (
                             X_REG_REQUEST_ID => item_key,
                             X_STATUS_CODE => 'VERIFYING');

        resultout := 'COMPLETE:REQUIRED';
      else
        resultout := 'COMPLETE:NOTREQUIRED';
      end if;
    end if;

 if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkidntyvrfyreqd.end',
                'itemkey: '||item_key);
 end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'check_idnty_vrfy_reqd', item_type, item_key, activity_id);
      raise;
  END check_idnty_vrfy_reqd;

  --
  -- Procedure
  -- check_mandatory_attributes
  -- Description
  --      Check if all the mandatory attributes are available.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure check_mandatory_attributes (item_type    in  varchar2,
                                        item_key     in  varchar2,
                                        activity_id  in  number,
                                        command      in  varchar2,
                                        resultout    out NOCOPY varchar2) is

    l_message_tokens    varchar2 (100);
    l_missing_attribute boolean := false;
    l_username          fnd_user.user_name%type;

  BEGIN

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXUTILB.check_mandatory_attributes.begin',
                      'item_type: '|| item_type || ' | itemkey: '||item_key);
    end if;

    if (command = 'RUN') then

      -- First check the user name.
      l_username := wf_engine.getitemattrtext (itemtype => item_type,
                                               itemkey => item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => true);

      if (l_username is null) then
        l_missing_attribute := true;
        l_message_tokens := 'REQUESTED_USERNAME';
      end if;

      if (l_missing_attribute) then

        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                          'fnd.plsql.UMXUTILB.check_mandatory_attributes.end',
                          'Exception occurs because mandatory attribute (s) is/are missing: ' || l_message_tokens);
        end if;

        fnd_message.set_name (application => 'FND',
                              name        => 'UMX_MANDATORY_ATTRIBUTES_ERROR');
        fnd_message.set_token (token => 'ATTRIBUTE_NAMES',
                               value => l_message_tokens);

        raise_application_error ('-20000', fnd_message.get);
      end if;
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXUTILB.check_mandatory_attributes.end',
                      'item_type: '|| item_type || ' | itemkey: '|| item_key);
    end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'check_mandatory_attributes', item_type, item_key, activity_id);
      raise;
  END check_mandatory_attributes;

  -- Procedure
  --  create_reg_request
  -- Description
  --  Wrapper around UMX_REG_REQUESTS_PVT.create_reg_srv_request
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure create_reg_request (p_item_type    in  varchar2,
                                p_item_key     in  varchar2,
                                p_activity_id  in  number,
                                p_command      in  varchar2,
                                p_resultout    out NOCOPY varchar2) is

    l_reg_request_id            UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE;
    l_requested_for_user_id     UMX_REG_REQUESTS.REQUESTED_FOR_USER_ID%TYPE ;
    l_requested_by_user_id      UMX_REG_REQUESTS.REQUESTED_BY_USER_ID%TYPE ;
    l_requested_for_party_id    UMX_REG_REQUESTS.REQUESTED_FOR_PARTY_ID%TYPE ;
    l_requested_username        UMX_REG_REQUESTS.REQUESTED_USERNAME%TYPE ;
    l_wf_role_name              UMX_REG_REQUESTS.WF_ROLE_NAME%TYPE ;
    l_reg_service_code          UMX_REG_REQUESTS.REG_SERVICE_CODE%TYPE ;
    l_reg_service_type          UMX_REG_REQUESTS.REG_SERVICE_TYPE%TYPE;
    l_ame_application_id        UMX_REG_REQUESTS.AME_APPLICATION_ID%TYPE ;
    l_ame_transaction_type_id   UMX_REG_REQUESTS.AME_TRANSACTION_TYPE_ID%TYPE ;
    l_request_status_code       UMX_REG_REQUESTS.STATUS_CODE%TYPE;
    l_justification UMX_REG_REQUESTS.JUSTIFICATION%TYPE ;
    l_requested_start_date DATE;
    l_requested_end_date DATE;

    l_event wf_event_t;

  BEGIN

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.createregrequest.begin',
                'itemkey: '||p_item_key);
   end if;



    if (p_command = 'RUN') then

     /**
      ** this is the first method in the workflow so log all the
      ** parameters passed to it (all params in event object).
      **/

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

          l_event := wf_engine.getitemattrevent (itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                name => 'REGISTRATION_DATA');
          print_Event_params (p_event => l_event);
      end if;

      l_reg_request_id := To_Number (p_item_key);
      l_requested_for_user_id := wf_engine.getitemattrtext (
                                   itemtype => p_item_type,
                                   itemkey => p_item_key,
                                   aname => 'REQUESTED_FOR_USER_ID',
                                   ignore_notfound => true);

      l_requested_by_user_id := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'REQUESTED_BY_USER_ID',
                                                ignore_notfound => false);

      l_requested_for_party_id := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'PERSON_PARTY_ID',
                                                ignore_notfound => true);

      l_requested_username := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'REQUESTED_USERNAME',
                                                ignore_notfound => false);

      l_wf_role_name := wf_engine.getitemattrtext (itemtype => p_item_type,
                                                  itemkey => p_item_key,
                                                  aname => 'WF_ROLE_NAME',
                                                  ignore_notfound => true);
      l_reg_service_code := wf_engine.getitemattrtext (
                                                  itemtype => p_item_type,
                                                  itemkey => p_item_key,
                                                  aname => 'REG_SERVICE_CODE',
                                                  ignore_notfound => false);
      l_reg_service_type := wf_engine.getitemattrtext (
                                                  itemtype => p_item_type,
                                                  itemkey => p_item_key,
                                                  aname => 'REG_SERVICE_TYPE',
                                                  ignore_notfound => false);
      l_ame_application_id := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'AME_APPLICATION_ID',
                                                ignore_notfound => true);

      l_ame_transaction_type_id := wf_engine.getitemattrtext (
                                              itemtype => p_item_type,
                                              itemkey => p_item_key,
                                              aname => 'AME_TRANSACTION_TYPE_ID',
                                              ignore_notfound => true);

      l_request_status_code := 'PENDING';
      l_justification := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'JUSTIFICATION',
                                                ignore_notfound => true);

      l_requested_start_date := fnd_date.canonical_to_date (
                        wf_engine.getitemattrtext (itemtype => p_item_type,
                          itemkey => p_item_key,
                          aname => 'REQUESTED_START_DATE',
                          ignore_notfound => false));

      l_requested_end_date :=  fnd_date.canonical_to_date (
                      wf_engine.getitemattrtext (itemtype => p_item_type,
                        itemkey => p_item_key,
                        aname => 'REQUESTED_END_DATE',
                        ignore_notfound => false));

      UMX_REG_REQUESTS_PKG.insert_row (
        x_reg_request_id   => l_reg_request_id ,
        x_reg_service_type => l_reg_service_type,
        x_status_code => l_request_status_code,
        x_requested_by_user_id => l_requested_by_user_id,
        x_requested_for_user_id => l_requested_for_user_id,
        x_requested_for_party_id => l_requested_for_party_id,
        x_requested_username => l_requested_username,
        x_requested_start_date => nvl (l_requested_start_date,sysdate),
        x_requested_end_date => l_requested_end_date,
        x_wf_role_name => l_wf_role_name,
        x_reg_service_code => l_reg_service_code,
        x_ame_application_id => l_ame_application_id,
        x_ame_transaction_type_id => l_ame_transaction_type_id,
        x_justification => l_justification);
    end if;

 if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.createregrequest.end',
                'itemkey: '||p_item_key);
 end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'create_reg_request', p_item_type, p_item_key, p_activity_id);
      raise;

  END create_reg_request;

  -- Procedure
  --  Reserve UserName
  -- Description
  --  Wrapper around Fnd_user_pkg.create_username with status as pending
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure reserve_username (p_item_type    in  varchar2,
                              p_item_key     in  varchar2,
                              p_activity_id  in  number,
                              p_command      in  varchar2,
                              p_resultout    out NOCOPY varchar2) is

    l_username FND_USER.USER_NAME%TYPE;
    l_person_party_id HZ_PARTIES.party_id%TYPE;
    l_temp_party_id varchar2 (25);
    l_password varchar2 (100);
    l_expire_password varchar2 (25);
    l_user_id number;
    l_temp_user_id varchar2 (25);
    l_email_address FND_USER.EMAIL_ADDRESS%TYPE;
    l_fax FND_USER.FAX%TYPE;
    l_password_date DATE;
    l_password_message VARCHAR2 (300);
    l_return_status pls_integer;

  BEGIN

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUTILB.reserveusername.begin',
                     'itemkey: '||p_item_key);
    end if;

    if (p_command = 'RUN') then
      l_username :=  wf_engine.getitemattrtext (itemtype => p_item_type,
                                               itemkey => p_item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => true);

      l_temp_party_id :=  wf_engine.getitemattrtext (itemtype => p_item_type,
                                                    itemkey => p_item_key,
                                                    aname => 'PERSON_PARTY_ID',
                                                    ignore_notfound => true);
      if l_temp_party_id is not null then
        l_person_party_id := to_number (l_temp_party_id);
      end if;

      l_password := wf_engine.getitemattrtext (itemtype => p_item_type,
                                              itemkey => p_item_key,
                                              aname => 'PASSWORD',
                                              ignore_notfound => true);

      l_expire_password := wf_engine.getitemattrtext (itemtype => p_item_type,
                                                     itemkey => p_item_key,
                                                     aname => 'EXPIRE_PASSWORD',
                                                     ignore_notfound => true);

      l_email_address := wf_engine.getitemattrtext (itemtype => p_item_type,
                                                   itemkey => p_item_key,
                                                   aname => 'EMAIL_ADDRESS',
                                                   ignore_notfound => false);

      l_fax := wf_engine.getitemattrtext (itemtype => p_item_type,
                                         itemkey => p_item_key,
                                         aname => 'FAX',
                                         ignore_notfound => false);

      --invoke this api after fnd provides the correct api
      -- change the password date to null if reg_service_type is admin_creation


      if (l_expire_password = 'Y') then
        l_password_date := null;
        --l_password_message := l_password;
      else
        l_password_date := sysdate;
        --get this from fnd messages
        --l_password_message := fnd_message.get_string ('FND', 'UMX_NTFY_DSPLY_PASSWD');
      end if;

      --Since we store encrypted password in this DISPLAY_PASSWORD, always store the password instead of message despite self service or admin user creation.
     l_password_message := l_password;
     add_param_to_event (p_item_type, p_item_key, 'DISPLAY_PASSWORD', l_password_message);

      -- Check if the username is available
      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                       'fnd.plsql.UMXUTILB.reserveusername',
                       'Before invoking fnd_user_pkg.TestUserName API with username is ' || l_username);
      end if;

      l_return_status := fnd_user_pkg.TestUserName (x_user_name => l_username);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                       'fnd.plsql.UMXUTILB.reserveusername',
                       'After invoking fnd_user_pkg.TestUserName API with return status is ' || l_return_status);
      end if;

      if ((l_return_status = fnd_user_pkg.USER_INVALID_NAME) or
          (l_return_status = fnd_user_pkg.USER_EXISTS_IN_FND) or
          (l_return_status = fnd_user_pkg.USER_EXISTS_NO_LINK_ALLOWED)) then
        -- There is problem with the username.  Throw error
        raise_application_error ('-20000', fnd_message.get);
      else
        add_param_to_event (p_item_type, p_item_key, 'TESTUSERNAME_RET_STATUS', l_return_status);
      end if;

      if (l_return_status = fnd_user_pkg.user_synched) then
        -- Because the account will be synched, we no longer needs to keep
        -- the user password in apps.  Password will be managed "EXTERNALLY".
        l_password := null;
        wf_engine.setitemattrtext (itemtype => p_item_type,
                                   itemkey  => p_item_key,
                                   aname    => 'PASSWORD',
                                   avalue   => l_password);
        add_param_to_event (p_item_type, p_item_key, 'DISPLAY_PASSWORD', l_password);
      end if;

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                       'fnd.plsql.UMXUTILB.reserveusername',
                       'Before invoking UMX_REG_REQUESTS_PVT.reserve_username API.');
      end if;

      l_user_id := UMX_REG_REQUESTS_PVT.reserve_username (
                   p_reg_request_id       => p_item_key, -- item key is regid
                   p_username             => l_username,
                   p_owner                => NULL,
                   p_unencrypted_password => l_password,
                   p_password_date        => l_password_date,
                   p_email_address        => l_email_address,
                   p_fax                  => l_fax,
                   p_person_party_id      => l_person_party_id);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                       'fnd.plsql.UMXUTILB.reserveusername',
                       'userid: '||l_user_id);
      end if;

      if (l_user_id is not null) then
        l_temp_user_id := to_char (l_user_id);
        wf_engine.setitemattrtext (itemtype => p_item_type,
                                   itemkey =>p_item_key,
                                   aname => 'REQUESTED_FOR_USER_ID',
                                   avalue => l_temp_user_id);

        add_param_to_event (p_item_type,p_item_key,'REQUESTED_FOR_USER_ID',l_temp_user_id);

        p_resultout := 'COMPLETE:T';
      else
        p_resultout := 'COMPLETE:N';
      end if;
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXUTILB.reserveusername.end',
                      'itemkey: '||p_item_key);
    end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'reserve_username', p_item_type, p_item_key, p_activity_id);
      raise;
  END reserve_username;

  -- Procedure
  --  activate_userName
  -- Description
  --  Wrapper around Fnd_user_pkg.update_username with status as approved
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure activate_username (p_item_type    in  varchar2,
                               p_item_key     in  varchar2,
                               p_activity_id  in  number,
                               p_command      in  varchar2,
                               p_resultout    out NOCOPY varchar2) is
    l_person_party_id VARCHAR2 (30);
    l_user_name fnd_user.user_name%type;
    l_start_date  DATE;
    l_end_date DATE;
  BEGIN

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.activateusername.begin',
                'itemkey: '||p_item_key);
   end if;


    if (p_command = 'RUN') then
      l_person_party_id :=  wf_engine.getitemattrtext (itemtype => p_item_type,
                                                      itemkey => p_item_key,
                                                      aname => 'PERSON_PARTY_ID',
                                                      ignore_notfound => false);

      l_user_name := wf_engine.getitemattrtext (itemtype => p_item_type,
                                               itemkey => p_item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => false);

      l_start_date := fnd_date.canonical_to_date (
                        wf_engine.getitemattrtext (itemtype => p_item_type,
                          itemkey => p_item_key,
                          aname => 'REQUESTED_START_DATE',
                          ignore_notfound => false));

      l_end_date :=  fnd_date.canonical_to_date (
                      wf_engine.getitemattrtext (itemtype => p_item_type,
                        itemkey => p_item_key,
                        aname => 'REQUESTED_END_DATE',
                        ignore_notfound => false));
      if (l_person_party_id is not null) then
        -- call new fnd apis when provided
        -- change all the dates appropriately and check how to get the format
        umx_reg_requests_pvt.approve_username_reg_request (
                         p_reg_request_id  => to_number (p_item_key),
                         p_username       => l_user_name,
                         p_person_party_id => to_number (l_person_party_id),
                         p_start_date     => l_start_date,
                         p_end_date     => l_end_date);
     else
     -- raise an error cannot activate user account with a person_party_id
     -- there was an error somewhere not traped as party_id should not be
     -- null here

     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                'fnd.plsql.UMXUTILB.launchusernamepolicy',
                'person_party_id is null in activate username');
     end if;

        raise_application_error ('-20000','person_party_id not passed to activate username ');
     end if;
      p_resultout := 'COMPLETE';
    end if;

 if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.activateusername.end',
                'itemkey: '||p_item_key);
 end if;

  END activate_username;

  -- Procedure
  --  release_userName
  -- Description
  --  Wrapper around Fnd_user_pkg.delete_username with status as cancelled
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure release_username (p_item_type    in  varchar2,
                              p_item_key     in  varchar2,
                              p_activity_id  in  number,
                              p_command      in  varchar2,
                              p_resultout    out NOCOPY varchar2) is

    l_username FND_USER.user_name%type;
    l_userid FND_USER.user_id%type;

  BEGIN

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.releaseusername.begin',
                'itemkey: '||p_item_key);
   end if;

    if (p_command = 'RUN') then
      l_username := wf_engine.getitemattrtext (itemtype => p_item_type,
                                               itemkey => p_item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => false);

      l_userid := wf_engine.getitemattrtext (itemtype => p_item_type,
                                             itemkey => p_item_key,
                                             aname => 'REQUESTED_FOR_USER_ID',
                                             ignore_notfound => false);


      umx_reg_requests_pvt.reject_username_reg_request (
          p_reg_request_id => p_item_key,
          p_user_id  => l_userid,
          p_username => l_username);

    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.releaseusername.end',
                'itemkey: '||p_item_key);
   end if;

  END release_username;

  -- Procedure
  --  increment_sequence
  -- Description
  -- Procedure which increments the sequence used for raising the events
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure increment_sequence (p_item_type    in  varchar2,
                                p_item_key     in  varchar2,
                                p_activity_id  in  number,
                                p_command      in  varchar2,
                                p_resultout    out NOCOPY varchar2) is

    l_event_key varchar2 (25);
    l_temp_event_key number;
    l_event_type varchar2 (25);

  BEGIN

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.incrementsequence.begin',
                'itemkey: '||p_item_key);
   end if;

    if (p_command = 'RUN') then

      l_event_type :=  wf_engine.getActivityAttrText (itemtype => p_item_type,
                                                     itemkey => p_item_key,
                                                     actid => p_activity_id,
                                                     aname => 'EVENT_TYPE',
                                                     ignore_notfound => true);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                          'fnd.plsql.UMXUTILB.incrementsequence',
                          'eventtype: '||l_event_type);
      end if;

      if (l_event_type = 'GENERIC') then
        select UMX_EVENTS_S.nextval into l_temp_event_key from dual;
      else
        select UMX_REG_REQUESTS_S.nextval into l_temp_event_key from dual;
      end if;

      l_event_key := to_char (l_temp_event_key);
      wf_engine.setitemattrtext (itemtype => p_item_type,
                                itemkey =>p_item_key,
                                aname => 'EVENT_KEY_SEQUENCE',
                                avalue => l_event_key);
      p_resultout := 'COMPLETE';

    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.incrementsequence.end',
                'itemkey: '||p_item_key);
   end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'increment_sequence', p_item_type, p_item_key, p_activity_id);
      raise;

  END increment_sequence;

  --
  -- Procedure
  -- Check_password_null
  -- (DEPRECATED API)
  -- Description
  --      Check if the password is null
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure check_password_null (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2) is

    l_password varchar2 (100);

  BEGIN

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkpasswordnull.begin',
                'itemkey: '||item_key);
   end if;

    if (command = 'RUN') then
      l_password :=   wf_engine.getitemattrtext (itemtype => item_type,
                                                itemkey => item_key,
                                                aname => 'PASSWORD',
                                                ignore_notfound => false);

      if (l_password is null) then
        resultout := 'COMPLETE:Y';
        wf_engine.setitemattrtext (itemtype => item_type,
                                   itemkey => item_key,
                                   aname  => 'EXPIRE_PASSWORD',
                                   avalue => 'Y');
      else
        resultout := 'COMPLETE:N';
      end if;
    end if;

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkpasswordnull.end',
                'itemkey: '||item_key);
  end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'check_username_null', item_type, item_key, activity_id);
      raise;
  END check_password_null;

  --
  --  Function
  --  set_event_object
  --
  -- Description
  -- This method sets back the changes made to parameters in subscribers back to
  -- the the main workflow.
  -- IN
  -- p_attr_name varchar2
  --  this is the attrname that needs to be added to parent wf and event obj
  -- p_attr_value varchar2
  --  this is the attrvalue of the attrname to be added to parentwf and event
  -- IN/OUT
  -- p_event - WF_EVENT_T which holds the data that needs to passed from/to
  --           subscriber of the event
  --
  function set_event_object (p_event in out NOCOPY WF_EVENT_T,
                             p_attr_name in VARCHAR2 DEFAULT NULL,
                             p_attr_value in VARCHAR2 DEFAULT NULL)
                             return varchar2 is

    l_parent_itemtype WF_ITEMS.ITEM_TYPE%TYPE;
    l_parent_itemkey WF_ITEMS.ITEM_KEY%TYPE;
  begin

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (lower(p_attr_name) not like '%password%') then
           FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.seteventobject.begin',
                'attrname: '||p_attr_name ||
                ' attrvalue: '|| p_attr_value);
      end if;
   end if;

    l_parent_itemtype := p_event.getvalueforparameter ('UMX_PARENT_ITEM_TYPE');
    l_parent_itemkey := p_event.getvalueforparameter ('UMX_PARENT_ITEM_KEY');

    -- set attrname and attrvalue into workflow if they are not null

    if (p_attr_name is not null) then

      p_event.addParametertoList (p_attr_name, p_attr_value);
-- modify this to check if the attr has been defined earlier
--if not then add and set
      begin
      wf_engine.setitemattrtext (itemtype => l_parent_itemtype,
                            itemkey => l_parent_itemkey,
                            aname => p_attr_name,
                            avalue => p_attr_value);
      EXCEPTION
      WHEN OTHERS THEN
      wf_engine.additemattr (itemtype => l_parent_itemtype,
                                itemkey => l_parent_itemkey,
                                aname => p_attr_name,
                                text_value => p_attr_value);
      end;

     end if;



    -- set the event object into workflow
    wf_engine.setitemattrevent (itemtype => l_parent_itemtype,
                               itemkey => l_parent_itemkey,
                               name => 'REGISTRATION_DATA',
                               event => p_event);

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.seteventobject.end',
                '');
   end if;

    /**
    ** log all the params in event obj
    **/

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
     then
          print_Event_params (p_event => p_event);
    end if;

	return 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      raise;
  end set_event_object;

  --  update_reg_request
  -- Description
  --  Wrapper around UMX_REG_REQUESTS_PVT.update_reg
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure update_reg_request (p_item_type    in  varchar2,
                                p_item_key     in  varchar2,
                                p_activity_id  in  number,
                                p_command      in  varchar2,
                                p_resultout    out NOCOPY varchar2) is

    CURSOR getRegRequest (p_reg_request_id in number) is

      select  STATUS_CODE
      from   UMX_REG_REQUESTS
      where  REG_REQUEST_ID = p_reg_request_id;

    l_reg_request umx_reg_requests_pvt.reg_request_type;
    l_reg_request_id UMX_REG_REQUESTS.REG_REQUEST_ID%TYPE;
    l_status_code UMX_REG_REQUESTS.status_code%TYPE;

    l_event wf_event_t;

  BEGIN

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.updateregrequest.begin',
                'itemkey: '||p_item_key);
   end if;

   /**
    ** log all the parameters in event object
   **/

    if (p_command = 'RUN') then

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

         l_event := wf_engine.getitemattrevent (itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                name => 'REGISTRATION_DATA');
         print_Event_params (p_event => l_event);
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXUTILB',
                        'regrequestid: '||p_item_key);
      end if;

      open getRegRequest (p_reg_request_id => to_number (p_item_key));

      fetch getRegRequest into l_status_code;

      if (getRegRequest%notfound) then
        close getRegRequest;
        raise_application_error ('-20000','Invalid reg_request_id in update regrequest');
      end if;

      close getRegRequest;

      l_reg_request.reg_request_id := p_item_key;
      l_reg_request.requested_for_user_id := wf_engine.getitemattrtext (
                                   itemtype => p_item_type,
                                   itemkey => p_item_key,
                                   aname => 'REQUESTED_FOR_USER_ID',
                                   ignore_notfound => true);

      l_reg_request.requested_by_userid := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'REQUESTED_BY_USER_ID',
                                                ignore_notfound => false);

      l_reg_request.requested_for_party_id := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'PERSON_PARTY_ID',
                                                ignore_notfound => true);

      l_reg_request.requested_username := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'REQUESTED_USERNAME',
                                                ignore_notfound => false);

      l_reg_request.wf_role_name := wf_engine.getitemattrtext (itemtype => p_item_type,
                                                  itemkey => p_item_key,
                                                  aname => 'WF_ROLE_NAME',
                                                  ignore_notfound => true);
      l_reg_request.reg_service_code := wf_engine.getitemattrtext (
                                                  itemtype => p_item_type,
                                                  itemkey => p_item_key,
                                                  aname => 'REG_SERVICE_CODE',
                                                  ignore_notfound => false);
      l_reg_request.reg_service_type := wf_engine.getitemattrtext (
                                                  itemtype => p_item_type,
                                                  itemkey => p_item_key,
                                                  aname => 'REG_SERVICE_TYPE',
                                                  ignore_notfound => false);
      l_reg_request.ame_application_id := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'AME_APPLICATION_ID',
                                                ignore_notfound => true);

      l_reg_request.ame_transaction_type_id := wf_engine.getitemattrtext (
                                              itemtype => p_item_type,
                                              itemkey => p_item_key,
                                              aname => 'AME_TRANSACTION_TYPE_ID',
                                              ignore_notfound => true);

      l_reg_request.justification := wf_engine.getitemattrtext (
                                                itemtype => p_item_type,
                                                itemkey => p_item_key,
                                                aname => 'JUSTIFICATION',
                                                ignore_notfound => true);

      l_reg_request.requested_start_date := fnd_date.canonical_to_date (
                        wf_engine.getitemattrtext (itemtype => p_item_type,
                          itemkey => p_item_key,
                          aname => 'REQUESTED_START_DATE',
                          ignore_notfound => false));

      l_reg_request.requested_end_date :=  fnd_date.canonical_to_date (
                      wf_engine.getitemattrtext (itemtype => p_item_type,
                        itemkey => p_item_key,
                        aname => 'REQUESTED_END_DATE',
                        ignore_notfound => false));


      if  (l_status_code = 'UNASSIGNED') then
        -- We need to update the status code to Pending
        l_reg_request.status_code := 'PENDING';
      end if;
        --update the reg request with latest details
        UMX_REG_REQUESTS_PVT.update_reg_request (p_reg_request => l_reg_request);


      p_resultout := 'COMPLETE';
    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.updateregrequests.end',
                'itemkey: '||p_item_key);
   end if;

   EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'Update_Reg_request', p_item_type, p_item_key);
      raise;

  END update_reg_request;

  procedure LaunchEvent (item_type    in  varchar2,
                         item_key     in  varchar2,
                         activity_id  in  number,
                         command      in  varchar2,
                         resultout    out NOCOPY varchar2) is

    l_event wf_event_t;
    l_parameter_list wf_parameter_list_t;
    l_event_key number;
    l_person_party_id fnd_user.person_party_id%type;
  BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.launchevent.begin',
                'itemkey: '||item_key);
  end if;

    if (command = 'RUN') then
      l_person_party_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                     itemkey => item_key,
                                                     aname => 'PERSON_PARTY_ID',
                                                     ignore_notfound => false);

      if (l_person_party_id is null) then

        l_event := wf_engine.getitemattrevent (itemtype => item_type,
                                              itemkey => item_key,
                                              name => 'REGISTRATION_DATA');
        l_parameter_list := l_event.getParameterlist ();

        select UMX_EVENTS_S.nextval into l_event_key from dual;
        wf_event.raise ('oracle.apps.fnd.umx.createpersonparty',l_event_key,null,l_parameter_list,sysdate);

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXUTILB.launchevent',
                        'event_key: '||l_event_key);
        end if;


      end if;
    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.launchevent.end',
                'itemkey: '||item_key);
   end if;

   EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'LaunchEvent', item_type, item_key);
      raise;

  END LaunchEvent;

  -- one more temp work around for launching notificationwf
  procedure Start_Notification_Wf (item_type    in  varchar2,
                                   item_key     in  varchar2,
                                   activity_id  in  number,
                                   command      in  varchar2,
                                   resultout    out NOCOPY varchar2) is

    l_event wf_event_t;
    l_parameter_list wf_parameter_list_t;
    l_event_key number;
    l_notification_context varchar2 (25);
    l_notification_event wf_events.name%type;
  BEGIN

    if (command = 'RUN') then
      l_notification_context := wf_engine.getitemattrtext (itemtype => item_type,
                                 itemkey => item_key,
                                 aname => 'NOTIFICATION_CONTEXT',
                                 ignore_notfound => false);
      l_notification_event := wf_engine.getitemattrtext (itemtype => item_type,
                                 itemkey => item_key,
                                 aname => 'WF_NOTIFICATION_EVENT',
                                 ignore_notfound => false);

      l_event := wf_engine.getitemattrevent (itemtype => item_type,
                                            itemkey => item_key,
                                            name => 'REGISTRATION_DATA');

      l_parameter_list := l_event.getParameterList ();

      wf_event.addparametertolist ('NOTIFICATION_CONTEXT', l_notification_context,l_parameter_list);

      select UMX_EVENTS_S.nextval into l_event_key from dual;
      wf_event.raise (p_event_name => l_notification_event,
                      p_event_key  => l_event_key,
                      p_parameters => l_parameter_list);
    end if;
  EXCEPTION
     WHEN others THEN
       Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'Start_notification_wf', item_type, item_key, activity_id);
       raise;
  END Start_Notification_Wf;

  -- Procedure
  --      create_ad_hoc_role
  --
  -- Description
  -- populate the wf_local_roles table with information from workflow
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure create_ad_hoc_role (item_type   in  varchar2,
                                item_key    in  varchar2,
                                activity_id in  number,
                                command     in  varchar2,
                                resultout   out NOCOPY varchar2) is

    l_user_name fnd_user.user_name%type;
    l_email_address fnd_user.email_address%type;
    l_person_first_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_person_last_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_person_middle_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_prefix WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_suffix WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_requested_for_user_id WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_reg_svc_type WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;

    l_return_status  varchar2 (10);
    l_msg_count number;
    l_msg_data   varchar2 (280);
    l_formatted_name  varchar2 (300);
    l_formatted_lines_cnt number;
    l_formatted_name_tbl hz_format_pub.string_tbl_type;

    l_ad_hoc_role WF_ACTIVITY_ATTRIBUTES.text_default%type;

  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXUTILB.createadhocrole.begin',
                        'item_type: ' || item_type ||
                        ' item_key: ' || item_key);
      end if;

      -- if additional access workflow then we dont have to create adhoc role
      -- as it is already a system user
      l_reg_svc_type := wf_engine.getItemattrtext (
                          itemtype => item_type,
                          itemkey  => item_key,
                          aname    => 'REG_SERVICE_TYPE');

      if ((l_reg_svc_type <> 'ADDITIONAL_ACCESS') and
          (l_reg_svc_type <> 'ADMIN_ADDITIONAL_ACCESS')) then

        --check if the adhoc user has already been created then just reactivate
        l_ad_hoc_role := wf_engine.getItemattrtext (
            itemtype => item_type,
            itemkey  => item_key,
            aname    => 'USER_ROLE_NAME');

        if (l_ad_hoc_role is null) then

          l_person_first_name := wf_engine.getItemattrtext (
                                   itemtype => item_type,
                                   itemkey  => item_key,
                                   aname    => 'FIRST_NAME');

          l_person_middle_name := wf_engine.getItemattrtext (
                                    itemtype => item_type,
                                    itemkey  => item_key,
                                    aname    => 'MIDDLE_NAME');

          l_person_last_name := wf_engine.getItemattrtext (
                                  itemtype => item_type,
                                  itemkey  => item_key,
                                  aname    => 'LAST_NAME');

          l_prefix := wf_engine.getitemattrtext (
                        itemtype => item_type,
                        itemkey => item_key,
                        aname => 'PRE_NAME_ADJUNCT');

          l_suffix := wf_engine.getitemattrtext (
                        itemtype => item_type,
                        itemkey => item_key,
                        aname => 'PERSON_SUFFIX');

          if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                            'fnd.plsql.UMXUTILB.createadhocrole',
                            'calling hz_format_pub.format_name with ' ||
                            'p_person_first_name=>' || l_person_first_name ||
                            ', p_person_middle_name=>' || l_person_middle_name ||
                            ', p_person_last_name=>' || l_person_last_name ||
                            ', p_person_title=>' || l_prefix ||
                            ', and p_person_name_suffix=>' || l_suffix);
          end if;

          hz_format_pub.format_name (
              p_person_first_name   => l_person_first_name ,
              p_person_middle_name  => l_person_middle_name,
              p_person_last_name    => l_person_last_name,
              p_person_title        => l_prefix,
              p_person_name_suffix  => l_suffix,
              x_return_status       => l_return_status,
              x_msg_count           => l_msg_count,
              x_msg_data            => l_msg_data,
              x_formatted_name      => l_formatted_name,
              x_formatted_lines_cnt => l_formatted_lines_cnt,
              x_formatted_name_tbl  => l_formatted_name_tbl);

          if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                            'fnd.plsql.UMXUTILB.createadhocrole',
                            'Done calling hz_format_pub.format_name with ' ||
                            'x_return_status=>' || l_return_status ||
                            ', x_msg_count=>' || l_msg_data ||
                            ', x_formatted_name=>' || l_formatted_name ||
                            ', x_formatted_lines_cnt=>' || l_formatted_lines_cnt);
          end if;

          l_ad_hoc_role := '~UMX_' || item_key;

          -- We don't care if hz_format_pub fails, just create a formatted name
          -- with first name and last name.
          if (l_formatted_name is null) then
            l_formatted_name := l_person_first_name || ' ' || l_person_last_name;
          end if;

          wf_engine.setItemattrtext (
              itemtype => item_type,
              itemkey  => item_key,
              aname    => 'FORMATED_NAME',
              avalue   => l_formatted_name);

          add_param_to_event (p_item_type  => item_type,
                              p_item_key   => item_key,
                              p_attr_name  => 'FORMATED_NAME',
                              p_attr_value => l_formatted_name);

          l_email_address := wf_engine.getItemattrtext (
              itemtype => item_type,
              itemkey  => item_key,
              aname => 'EMAIL_ADDRESS');

          if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                            'fnd.plsql.UMXUTILB.createadhocrole',
                            'before calling wf_directory.CreateAdHocRole:' ||
                            ' l_ad_hoc_role: ' || l_ad_hoc_role ||
                            ' l_formatted_name: ' || l_formatted_name ||
                            ' l_email_address: ' || l_email_address);
          end if;

          wf_directory.CreateAdHocRole (
              role_name             => l_ad_hoc_role,
              role_display_name     => l_formatted_name,
              email_address         => l_email_address,
              owner_tag             => 'FND');

          if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                            'fnd.plsql.UMXUTILB.createadhocrole',
                            'After calling wf_directory.CreateAdHocRole.');
          end if;
        end if;

      else

        -- this regsvctype is additional accessrequest notification
        -- set USER_ROLE_NAME as the logged in USER_NAME and formating
        -- is taken care in UMXNTFSB.pls

        l_requested_for_user_id := wf_engine.getItemattrtext (
            itemtype => item_type,
            itemkey  => item_key,
            aname    => 'REQUESTED_FOR_USER_ID');

        if (l_requested_for_user_id is not null) then

          select user_name into l_user_name
          from fnd_user
          where user_id = l_requested_for_user_id;

          l_ad_hoc_role := l_user_name;

        end if;
      end if;-- end for additional_access loop

      wf_engine.setItemattrtext (
          itemtype => item_type,
          itemkey  => item_key,
          aname    => 'USER_ROLE_NAME',
          avalue   => l_ad_hoc_role);

      add_param_to_event (
          p_item_type  => item_type,
          p_item_key   => item_key,
          p_attr_name  => 'USER_ROLE_NAME',
          p_attr_value => l_ad_hoc_role);

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXUTILB.createadhocrole.end', '');
      end if;
    end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_NOTIFICATION_UTIL', 'create_ad_hoc_role',
                       item_type, item_key, activity_id);
      raise;
  END create_ad_hoc_role;

  --
  -- Procedure
  --      release_ad_hoc_role
  --
  -- Description
  -- remove the adhoc role
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure release_ad_hoc_role (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2) is

    l_adhoc_role_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_reg_svc_type WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;

  begin

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXUTILB.releaseadhocrole.end',
                        'item_type: ' || item_type ||
                        ' item_key: ' || item_key);
      end if;

      -- There is no need to release adhoc user in additional_access request
      -- since there is no adhoc user created.
      l_reg_svc_type := wf_engine.getItemattrtext (
          itemtype => item_type,
          itemkey  => item_key,
          aname    => 'REG_SERVICE_TYPE');

      if ((l_reg_svc_type <> 'ADDITIONAL_ACCESS') and
          (l_reg_svc_type <> 'ADMIN_ADDITIONAL_ACCESS')) then

        l_adhoc_role_name := wf_engine.getItemattrtext (
                                itemtype => item_type,
                                itemkey  => item_key,
                                aname    => 'USER_ROLE_NAME');

        if (l_adhoc_role_name = '~UMX_' || item_key) then
          wf_directory.setAdHocRoleStatus (role_name => l_adhoc_role_name,
                                           status    => 'INACTIVE');

          -- The expiration_date is set to +30 based on the recommandation from WF.
          wf_directory.setAdHocRoleExpiration (role_name       => l_adhoc_role_name,
                                               expiration_date => sysdate + 30);
        end if;

      end if;

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXUTILB.releaseadhocrole.end', '');
      end if;
    end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_NOTIFICATION_UTIL', 'release_ad_hoc_role',
                       item_type, item_key, activity_id);
      raise;

  end release_ad_hoc_role;

procedure reject_request (p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2) is
Begin
--null;
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.rejectrequest.begin',
                'itemkey: '||p_item_key);
   end if;

   umx_reg_requests_pvt.reject_reg_request
                           (p_reg_request_id => to_number (p_item_key));

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.cancelusername.begin',
                'itemkey: '||p_item_key);
   end if;
End reject_request;

-- Procedure
  --  cancel_username
  -- Description
  --  Wrapper around Fnd_user_pkg.delete_username with status as cancelled
  -- this is for failed identity verification
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure cancel_username (p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2) is
    l_username FND_USER.user_name%type;
    l_userid FND_USER.user_id%type;
  Begin

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.cancelusername.begin',
                'itemkey: '||p_item_key);
   end if;

    if (p_command = 'RUN') then
      l_username := wf_engine.getitemattrtext (itemtype => p_item_type,
                                               itemkey => p_item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => false);

      l_userid := wf_engine.getitemattrtext (itemtype => p_item_type,
                                             itemkey => p_item_key,
                                             aname => 'REQUESTED_FOR_USER_ID',
                                             ignore_notfound => false);


      umx_reg_requests_pvt.cancel_username_reg_request (
          p_reg_request_id => p_item_key,
          p_user_id  => l_userid,
          p_username => l_username);

    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.cancelusername.end',
                'itemkey: '||p_item_key);
   end if;

 End cancel_username;

-- Procedure
  --  update_user_status
  -- Description
  --  This method is to set the reg status to pending from veryfing
  -- this is for sucessful identity verification
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

procedure update_user_status (p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2) is
    l_userid FND_USER.user_id%type;
  Begin

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.updateuserstatus.begin',
                'itemkey: '||p_item_key);
   end if;

    if (p_command = 'RUN') then

      l_userid := wf_engine.getitemattrtext (itemtype => p_item_type,
                                             itemkey => p_item_key,
                                             aname => 'REQUESTED_FOR_USER_ID',
                                             ignore_notfound => false);

      -- set the status from verifying to pending
      UMX_REG_REQUESTS_PKG.update_row (X_REG_REQUEST_ID => to_number (p_item_key),
                                        X_STATUS_CODE => 'PENDING');

    end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.updateuserstatus.end',
                'itemkey: '||p_item_key);
   end if;

 End update_user_status;

  -- Procedure
  --      Launch_Custom_event
  --
  -- Description
  -- Launches the Custom Event, if one is defined.
  -- It also adds the context into event object
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure Launch_Custom_Event (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2) is

    l_custom_event wf_events.name%type;
    l_custom_event_context WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_parameter_list wf_parameter_list_t;
    l_event wf_event_t;
    l_event_key number;
    l_reg_svc_type UMX_REG_SERVICES_B.REG_SERVICE_TYPE%TYPE;

  begin

    l_reg_svc_type := wf_engine.getitemattrtext (itemtype => item_type,
                                                 itemkey  => item_key,
                                                 aname    => 'REG_SERVICE_TYPE');

    l_custom_event_context :=  wf_engine.getActivityAttrText (
                                itemtype => item_type,
                                itemkey  => item_key,
                                actid    => activity_id,
                                aname    => 'UMX_CUSTOM_EVENT_CONTEXT');

    if not ((l_reg_svc_type = 'ADMIN_CREATION' or
             l_reg_svc_type = 'SELF_SERVICE') and
            (l_custom_event_context = 'ROLE APPROVED')) then

      -- If the request is ADMIN_CREATION or SELF_SERVICE, we only have to raise
      -- the event during before and after the account is created.  We don't have
      -- to raise the event when it is role approved.

      l_custom_event := wf_engine.getitemattrtext (itemtype => item_type,
                                                   itemkey  => item_key,
                                                   aname    => 'CUSTOM_EVENT_NAME');

      if (l_custom_event is not null) then
        if (l_custom_event_context is not null) then

          add_param_to_event (p_item_type  => item_type,
                              p_item_key   => item_key,
                              p_attr_name  => 'UMX_CUSTOM_EVENT_CONTEXT',
                              p_attr_value => l_custom_event_context);

          select UMX_EVENTS_S.nextval into l_event_key from dual;

          l_event := wf_engine.getitemattrevent (itemtype => item_type,
                                                 itemkey  => item_key,
                                                 name     => 'REGISTRATION_DATA');

          l_parameter_list := l_event.getParameterlist ();
          wf_event.raise (l_custom_event, l_event_key, null, l_parameter_list, sysdate);

        else
         raise_application_error ('-200001','Event Context is missing in UMX_REGISTRATION_UTIL.Launch_Custom_Event API.');
        end if;
      end if;
    end if;
  End Launch_Custom_Event;

  --
  -- Procedure
  --   ICM_VIOLATION_CHECK
  --
  -- Description
  --   This API will call the ICM API to check if there are any violation
  --   with the requested role.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure ICM_VIOLATION_CHECK (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2) is

    l_icm_enabled           varchar2 (1);
    l_requested_for_user_id fnd_user.user_id%type;
    l_wf_role_name          wf_local_roles.name%type;
    l_wf_role_names         jtf_varchar2_table_400;
    l_amw_results_table     AMW_VIOLATION_PVT.g_varchar2_hashtable;
    l_has_violations        varchar2 (1);
    l_icm_region            varchar2 (4000);

  BEGIN

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK.begin',
                      'item_type='  || item_type ||
                      ', item_key=' || item_key);
    end if;

    -- First check the UMX_ENABLE_ICM_VALIDATION profile option value
    fnd_profile.get (name => 'UMX_ENABLE_ICM_VALIDATION',
                     val  => l_icm_enabled);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
          'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK',
          'Is ICM enabled? ' || l_icm_enabled);
    end if;

    if (l_icm_enabled = 'Y') then
      -- Call the ICM API Here
      if (AMW_VIOLATION_PVT.Is_ICM_Installed = 'Y') then

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
              'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK',
              'ICM is installed.');
        end if;

        l_requested_for_user_id := wf_engine.getitemattrtext (
                                     itemtype        => item_type,
                                     itemkey         => item_key,
                                     aname           => 'REQUESTED_FOR_USER_ID',
                                     ignore_notfound => false);

        l_wf_role_name := wf_engine.getitemattrtext (
                            itemtype        => item_type,
                            itemkey         => item_key,
                            aname           => 'WF_ROLE_NAME',
                            ignore_notfound => false);

        -- Initialize the jtf_varchar2_table_400 table.
        l_wf_role_names := jtf_varchar2_table_400 ();
        l_wf_role_names.EXTEND;
        l_wf_role_names (1) := l_wf_role_name;

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
              'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK',
              'Before calling AMW_VIOLATION_PVT.Has_Violations_For_Mode with p_user_id=' || l_requested_for_user_id ||
              ', p_role_names=' || l_wf_role_name || ', and p_mode=APPROVE');
        end if;

        AMW_VIOLATION_PVT.Has_Violations_For_Mode (
            p_user_id          => l_requested_for_user_id,
            p_role_names       => l_wf_role_names,
            p_mode             => 'APPROVE',
            x_violat_hashtable => l_amw_results_table);

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
              'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK',
              'After calling AMW_VIOLATION_PVT.Has_Violations_For_Mode');
        end if;

        l_has_violations := l_amw_results_table ('HasViolations');

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
              'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK',
              'l_has_violations is ' || l_has_violations);
        end if;

        if (l_has_violations = 'Y') then
          -- add parameters to the main workflow
          l_icm_region := l_amw_results_table ('ViolationDetail');

          if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK',
                'l_icm_region is ' || l_icm_region);
          end if;

          add_param_to_event (p_item_type  => item_type,
                              p_item_key   => item_key,
                              p_attr_name  => 'ICM_VIOLATION',
                              p_attr_value => l_has_violations);

          wf_engine.setItemattrtext (itemtype => item_type,
                                     itemkey  => item_key,
                                     aname    => 'ICM_VIOLATION',
                                     avalue   => l_has_violations);

          if (l_icm_region is not null) then
            l_icm_region := 'JSP:/OA_HTML/OA.jsp?OAFunc=' || l_icm_region;
            add_param_to_event (p_item_type  => item_type,
                                p_item_key   => item_key,
                                p_attr_name  => 'ICM_DETAIL_REGION',
                                p_attr_value => l_icm_region);

            wf_engine.setItemattrtext (itemtype => item_type,
                                       itemkey  => item_key,
                                       aname    => 'ICM_DETAIL_REGION',
                                       avalue   => l_icm_region);
          end if;
        end if;
      end if;
    end if;

    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXUTILB.ICM_VIOLATION_CHECK.end',
                      'l_has_violations=' || l_has_violations ||
                      ', l_icm_region=' || l_icm_region);
    end if;

  EXCEPTION
    WHEN others THEN
    raise;

  END ICM_VIOLATION_CHECK;

  --
  -- Procedure
  -- launch_username_policy
  -- (DEPRECATED API)
  -- Description
  -- This method launches the username policy wf, if username passed to
  -- registration workflow is null.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed

  procedure launch_username_policy (item_type    in  varchar2,
                                    item_key     in  varchar2,
                                    activity_id  in  number,
                                    command      in  varchar2,
                                    resultout    out NOCOPY varchar2) is

    l_person_party_id    HZ_PARTIES.PARTY_ID%TYPE ;
    l_suggested_username FND_USER.USER_NAME%TYPE;

  BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.launchusernamepolicy.begin',
                'itemkey: '||item_key);
  end if;

    if (command = 'RUN') then
      l_person_party_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                      itemkey => item_key,
                                                      aname => 'PERSON_PARTY_ID',
                                                      ignore_notfound => true);

      UMX_USERNAME_POLICY_PVT.get_suggested_username (
          p_person_party_id    => l_person_party_id,
          x_suggested_username => l_suggested_username);

      if (l_suggested_username is null) then
        resultout := 'COMPLETE:F';
      else
        wf_engine.setitemattrtext (itemtype => item_type,
                                   itemkey =>item_key,
                                   aname => 'REQUESTED_USERNAME',
                                   avalue => l_suggested_username);
        add_param_to_event (p_item_type => item_type,
                           p_item_key  => item_key,
                           p_attr_name => 'REQUESTED_USERNAME' ,
                           p_attr_value => l_suggested_username);
        resultout :='COMPLETE:T';
      end if;
    end if;

 if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.launchusernamepolicy.end',
                'itemkey: '||item_key);
 end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'launch_username_policy', item_type, item_key, activity_id);
      raise;
  END launch_username_policy;

  --
  -- Procedure
  -- Check_userName_null
  -- (DEPRECATED API)
  -- Description
  --      Check if the username is null
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   command  - Run/Cancel/Timeout
  -- OUT
  --  resultout - result of the process based on which the next step is followed
  procedure check_username_null (item_type    in  varchar2,
                                 item_key     in  varchar2,
                                 activity_id  in  number,
                                 command      in  varchar2,
                                 resultout    out NOCOPY varchar2) is

    l_username FND_USER.USER_NAME%TYPE;
  BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkusernamenull.begin',
                'itemkey: '||item_key);
  end if;

    if (command = 'RUN') then
      l_username := wf_engine.getitemattrtext (itemtype => item_type,
                                               itemkey => item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => true);

      if (l_username is null) then
        resultout := 'COMPLETE:Y';
      else
        resultout := 'COMPLETE:N';
      end if;
    end if;

 if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.checkusernamenull.end',
                'itemkey: '||item_key);
 end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_REGISTRATION_UTIL', 'check_username_null', item_type, item_key, activity_id);
      raise;
  END check_username_null;

 -- procedure custom_code
 -- (DEPRECATED API)
 -- This api should not have been invoked,
 -- it will be done only if username policy failed
 procedure custom_code (p_item_type    in  varchar2,
                                 p_item_key     in  varchar2,
                                 p_activity_id  in  number,
                                 p_command      in  varchar2,
                                 p_resultout    out NOCOPY varchar2) is
 begin
  raise_application_error ('-20001','User Name Policy failed, username is null');
 end custom_code;


 -- procedure LAUNCH_RESETPWD_WF
 --
 -- Description
 -- This api launches reset password WF which emails password reset link to user.
 -- it will be done only if 'MANUAL_PWD_RESET' profile is turned off.
 -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity(instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT

  procedure LAUNCH_RESETPWD_WF (item_type    in  varchar2,
                          item_key     in  varchar2,
                          activity_id  in  number,
                          command      in  varchar2,
                          resultout    out NOCOPY varchar2) is

   l_username FND_USER.USER_NAME%TYPE;
   l_resultout varchar2(100);
   l_message_name varchar2(100);
   l_manual_password_reset varchar2(20);
  begin

   /* The below code is part of password framework project which is not backported yet.
       This api is been included only for code compatibility.


     l_username := wf_engine.getitemattrtext (itemtype => item_type,
                                               itemkey => item_key,
                                               aname => 'REQUESTED_USERNAME',
                                               ignore_notfound => true);
     l_manual_password_reset := fnd_profile.value('MANUAL_PWD_RESET');

		 if (l_manual_password_reset is not null and l_manual_password_reset = 'N') then
       umx_login_help_pvt.ForgottenPwd(p_username  =>  l_username,
											p_parent_item_key   => item_key,
											p_orig_page => null,
                      x_return_status     => l_resultout,
                      x_message_name      => l_message_name);
        resultout := 'COMPLETE:T';
      else
        resultout := 'COMPLETE:F';
      end if; */

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                'fnd.plsql.UMXUTILB.LAUNCH_RESETPWD_WF',
                'Returning false');
    end if;
    resultout := 'COMPLETE:F';

  end;

END UMX_REGISTRATION_UTIL;

/
