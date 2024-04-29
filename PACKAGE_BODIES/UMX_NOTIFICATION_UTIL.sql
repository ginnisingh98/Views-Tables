--------------------------------------------------------
--  DDL for Package Body UMX_NOTIFICATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_NOTIFICATION_UTIL" as
/* $Header: UMXNTFSB.pls 120.10.12010000.6 2017/11/17 04:10:11 avelu ship $ */
  -- Start of Comments
  -- Package name     : UMX_NOTIFICATION_UTIL
  -- Purpose          :
  --   This package contains body  for notification details

  --
  -- Procedure
  --      Check_Context
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
  procedure Check_Context (item_type    in  varchar2,
                           item_key     in  varchar2,
                           activity_id  in  number,
                           command      in  varchar2,
                           resultout    out NOCOPY varchar2)IS

    l_context varchar2 (30);
    i number;
    l_parameter_list wf_parameter_list_t := null;
    l_event wf_event_t;
    l_requested_username fnd_user.user_name%type;
    l_return_status pls_integer;
    l_registration_data wf_event_t;
		l_manual_password_reset varchar2(10);

  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.CheckContext.begin', 'Begin');
      end if;

      /**
      ** this is the first method print all the variables in the event obj
      **/

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

        l_event := wf_engine.getitemattrevent (itemtype => item_type,
                                               itemkey => item_key,
                                               name => 'REGISTRATION_DATA');

        l_parameter_list := l_event.getparameterlist ();

        for i in 1..l_parameter_list.count loop
          if (lower(l_parameter_list (i).getName ()) not like '%password%') then
              FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                          'fnd.plsql.UMXNTFSB.check_context',
                          ' parameter name:'||l_parameter_list (i).getName ()||
                          ' value:'||l_parameter_list (i).getValue ());
          end if;
        end loop;
      end if;

      l_context := wf_engine.getitemattrtext (itemtype => item_type,
                                              itemkey => item_key,
                                              aname =>'NOTIFICATION_CONTEXT',
                                              ignore_notfound => false);
      if (l_context is not null) then

        if l_context = 'IDENTITY_VERIFICATION' then
          resultout := 'COMPLETE:IDENTITY_VERIFICATION';

        elsif l_context = 'APPROVAL_REQUIRED' then
          resultout := 'COMPLETE:APPROVAL_REQUIRED';

        elsif l_context = 'APPROVAL_CONFIRMATION' then
          -- We have to call the fnd_user_pkg.testusername api to find out
          -- whether oid is enable.  If that is the case, then we have to
          -- send a differnet notification.
          l_requested_username := wf_engine.getitemattrtext (itemtype => item_type,
                                                             itemkey => item_key,
                                                             aname =>'REQUESTED_USERNAME');
          l_registration_data :=
             wf_engine.getitemattrevent (item_type, item_key, 'REGISTRATION_DATA');

          if (l_parameter_list is null) then
            l_parameter_list := l_registration_data.getParameterList;
          end if;

          l_return_status := wf_event.GetValueForParameter (
                                        p_name          => 'TESTUSERNAME_RET_STATUS',
                                        p_parameterlist => l_parameter_list);

				 l_manual_password_reset := fnd_profile.value('MANUAL_PWD_RESET');



          if (l_return_status = fnd_user_pkg.user_synched) then
            resultout := 'COMPLETE:APPROVAL_CONFIRMATION_SYNCHED';
          else
               		 if (l_manual_password_reset is not null and l_manual_password_reset = 'N') then
						            resultout := 'COMPLETE:SECURE_APPROVAL_CONFIRMATION';
  								 else
  											resultout := 'COMPLETE:APPROVAL_CONFIRMATION';
									 end if;
          end if;
        elsif l_context = 'REJECTION' then
          resultout := 'COMPLETE:REJECTION';
        end if;

      end if;

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       'fnd.plsql.UMXNTFSB.CheckContext.end', 'End');
      end if;

    end if;
  END Check_Context;

  --
  -- Procedure
  --      Notification_process_done
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
  procedure Notification_Process_Done (item_type    in  varchar2,
                                       item_key     in  varchar2,
                                       activity_id  in  number,
                                       command      in  varchar2,
                                       resultout    out NOCOPY varchar2) IS

    l_registration_data wf_event_t;
    --l_parameter_list wf_parameter_list_t;
	l_parameter_list wf_parameter_list_t := wf_parameter_list_t();	--bug# 7110551
    l_parent_itemkey WF_ITEMS.ITEM_KEY%TYPE;
    l_approval_result varchar2 (30);
	aname varchar2(30);		--bug# 7110551
    avalue varchar2(2000);	--bug# 7110551
    pList wf_parameter_list_t;	--bug# 7110551
    j number := 1;	--bug# 7110551

  BEGIN

    if (command = 'RUN') then
      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.notificationprocessdone.begin', 'Begin');
      end if;

      l_registration_data :=
         wf_engine.getitemattrevent (item_type,item_key,'REGISTRATION_DATA');

      l_approval_result :=
         wf_engine.getItemattrtext (item_type,item_key,'APPROVAL_RESULT',false);

	  /*l_parameter_list := l_registration_data.getparameterlist ();*/	--bug# 7110551
	  /*Fix for bug# 7110551
		Remove the unwanted parameter '#CONTEXT' which contains the value 'UMXREGWF:item_key' (where item_key is the item_key value for UMXREGWF workflow)
		from the parameter list being passed to the event.
		Because of this parameter the parent_item_key and item_key for UMXREGWF workflow
		are being set to same value by the WF engine.
	  */
	  pList := l_registration_data.getparameterlist ();
      j := 1;
      for i in pList.first .. pList.last loop
       aname := pList(i).GetName;
       avalue := pList(i).GetValue;
       begin
         if aname <> '#CONTEXT' then
           l_parameter_list.extend;
           l_parameter_list(j) := WF_PARAMETER_T(aname,avalue);
           j := j+1;
         end if;
      end;
      end loop;

      wf_event.addParametertoList ('APPROVAL_RESULT',l_approval_result,l_parameter_list);

      l_parent_itemkey :=
         wf_engine.getItemattrtext (item_type,item_key,'UMX_PARENT_ITEM_KEY',false);

      wf_event.raise ('oracle.apps.fnd.umx.notificationdone', l_parent_itemkey,
                      null,l_parameter_list,sysdate);
      resultout := 'COMPLETE';

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.notificationprocessdone.end', 'End');
      end if;
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      Wf_Core.Context ('UMX_NOTIFICATION_UTIL', 'notification_process_done',
                       item_type, item_key, activity_id);
      raise;
  END Notification_Process_Done;

  -- Procedure
  --      GetNextApprover
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
  procedure GetNextApprover (item_type    in  varchar2,
                             item_key     in  varchar2,
                             activity_id  in  number,
                             command      in  varchar2,
                             resultout    out NOCOPY varchar2) IS

    l_ame_transaction_type_id WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_ame_application_id  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_reg_request_id  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_approver_name fnd_user.USER_NAME%TYPE;
    l_display_name wf_users.display_name%type;
    l_next_approver ame_util.approverRecord2;
    l_requested_for_user_id fnd_user.user_id%type;
    l_registration_data wf_event_t;
    l_requested_for_party_id hz_parties.party_id%type;
    l_user_role_name wf_local_roles.name%type;
    l_person_first_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_person_last_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_person_middle_name WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_prefix WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_suffix WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_return_status varchar2 (10);
    l_requester_email_address fnd_user.email_address%type;
    l_role_display_name wf_local_roles.display_name%type;
    l_reg_service_type  WF_ACTIVITY_ATTRIBUTES.text_default%type;

    l_msg_count number;
    l_msg_data  varchar2 (280);
    l_formatted_lines_cnt number;
    l_formatted_name_tbl hz_format_pub.string_tbl_type;
    l_event wf_event_t;
    l_status varchar2 (15);

    cursor getusername (l_user_id in fnd_user.user_id%type) is
      select user_name
      from fnd_user where user_id = l_user_id;

  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.getnextapprover.begin', 'Begin');
      end if;

      l_ame_application_id := wf_engine.getitemattrtext (
                                itemtype        => item_type,
                                itemkey         => item_key,
                                aname           => 'AME_APPLICATION_ID',
                                ignore_notfound => false);

      l_ame_transaction_type_id := wf_engine.getitemattrtext (
                                     itemtype        => item_type,
                                     itemkey         => item_key,
                                     aname           => 'AME_TRANSACTION_TYPE_ID',
                                     ignore_notfound => false);

      l_reg_request_id := wf_engine.getitemattrtext (
                            itemtype        => item_type,
                            itemkey         => item_key,
                            aname           => 'UMX_PARENT_ITEM_KEY',
                            ignore_notfound => false);

      l_next_approver := umx_reg_requests_pvt.getNextApproverPvt (p_ame_application_id      => l_ame_application_id,
                                                                  p_ame_transaction_type_id => l_ame_transaction_type_id,
                                                                  p_reg_request_id          => l_reg_request_id);
      l_approver_name := l_next_approver.name;

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
            'fnd.plsql.UMXNTFSB.getnextapprover',
            'approver name:'|| l_approver_name);
      end if;

      if (l_approver_name is not null) then

        wf_engine.setItemattrtext (itemtype => item_type,
                                   itemkey  => item_key,
                                   aname    => 'APPROVER_NAME',
                                   avalue   => l_approver_name);

        l_user_role_name := wf_engine.getItemattrtext (
            itemtype => item_type,
            itemkey  => item_key,
            aname    => 'USER_ROLE_NAME');

        if (l_user_role_name is null) then

          -- add the performer role in notification to be the username
          -- who is requesting account
          -- We have to first check to see if the requester has a user account.

          l_reg_service_type :=
                  wf_engine.getItemattrtext (itemtype => item_type,
                                             itemkey  => item_key,
                                             aname    => 'REG_SERVICE_TYPE');

          if ((l_reg_service_type = 'ADMIN_CREATION') or
              (l_reg_service_type = 'SELF_SERVICE')) then

            -- The requester doesn't have a user account and is requesting a
            -- user account.  Check if the person id exists.  If the person ID
            -- exists, then we will use the WF role of that person.

            l_registration_data :=
               wf_engine.getitemattrevent (item_type, item_key, 'REGISTRATION_DATA');
            l_requested_for_party_id := wf_event.GetValueForParameter (
                                   p_name          => 'PERSON_PARTY_ID',
                                   p_parameterlist => l_registration_data.getParameterList);

            if (l_requested_for_party_id is not null) then

              -- Get the Person WF Role
              wf_directory.GetUserName (
                  p_orig_system    => 'HZ_PARTY',
                  p_orig_system_id => l_requested_for_party_id,
                  p_name           => l_user_role_name,
                  p_display_name   => l_display_name);

            else
              -- l_requested_for_party_id is null.  Create an ad hoc role.
              l_person_first_name := wf_engine.getItemattrtext (
                  itemtype => item_type,
                  itemkey  => item_key,
                  aname    => 'FIRST_NAME');

              l_person_last_name := wf_engine.getItemattrtext (
                                      itemtype => item_type,
                                      itemkey  => item_key,
                                      aname    => 'LAST_NAME');

              l_person_middle_name := wf_engine.getItemattrtext (
                                        itemtype => item_type,
                                        itemkey  => item_key,
                                        aname    => 'MIDDLE_NAME');

              l_suffix := wf_engine.getitemattrtext (
                            itemtype => item_type,
                            itemkey  => item_key,
                            aname    => 'PERSON_SUFFIX');

              l_prefix := wf_engine.getitemattrtext (
                            itemtype => item_type,
                            itemkey  => item_key,
                            aname    => 'PRE_NAME_ADJUNCT');

              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                    'fnd.plsql.UMXNTFSB.getnextapprover',
                    'Before calling hz_format_pub.format_name (' ||
                    l_person_first_name || ',' || l_person_middle_name ||
                    l_person_last_name || ',' || l_prefix ||
                    l_suffix || ')');
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
                  x_formatted_name      => l_role_display_name,
                  x_formatted_lines_cnt => l_formatted_lines_cnt,
                  x_formatted_name_tbl  => l_formatted_name_tbl);

              if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                    'fnd.plsql.UMXNTFSB.getnextapprover',
                    'After calling hz_format_pub.format_name (' ||
                    l_return_status || ',' || l_msg_count ||
                    l_role_display_name || ',' || l_formatted_lines_cnt || ')');
              end if;

              l_user_role_name := '~UMX_' || l_reg_request_id;

              l_requester_email_address := wf_engine.getitemattrtext (
                                             itemtype => item_type,
                                             itemkey  => item_key,
                                             aname    => 'EMAIL_ADDRESS');

              wf_directory.CreateAdHocRole (role_name         => l_user_role_name,
                                            role_display_name => l_role_display_name,
                                            email_address     => l_requester_email_address,
                                            owner_tag         => 'FND');

            end if;

          else

            -- REG_SERVICE_TYPE is ADDITIONAL_ACCESS
            l_requested_for_user_id :=
                    wf_engine.getItemattrtext (itemtype => item_type,
                                               itemkey  => item_key,
                                               aname    => 'REQUESTED_FOR_USER_ID');

            open getUserName (l_requested_for_user_id);
            fetch getUserName into l_user_role_name;
            close getUserName;

          end if;

          wf_engine.setItemattrtext (itemtype => item_type,
                                     itemkey  => item_key,
                                     aname  => 'USER_ROLE_NAME',
                                     avalue => l_user_role_name);

          l_event := wf_engine.getitemattrevent (itemtype => item_type,
                                                itemkey => item_key,
                                                name => 'REGISTRATION_DATA');

          l_status := UMX_REGISTRATION_UTIL.set_event_object (
                                                p_event => l_event,
                                                p_attr_name => 'USER_ROLE_NAME',
                                                p_attr_value => l_user_role_name);

          wf_engine.setitemattrevent (itemtype => item_type,
                                      itemkey  => item_key,
                                      name     => 'REGISTRATION_DATA',
                                      event    => l_event);
        end if;
        resultout := 'COMPLETE:T';
      else
        resultout := 'COMPLETE:F';
      end if;

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.getnextapprover.end', 'End');
      end if;
    end if;

  EXCEPTION
    WHEN others THEN
      Wf_Core.Context ('UMX_NOTIFICATION_UTIL', 'getNextApprover', item_type, item_key);
      raise;

  END GetNextApprover;

  -- Procedure
  --      get_recipient_username
  --
  -- Description
  -- Return the username of the notification recipient.
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure get_recipient_username (item_type    in  varchar2,
                                    item_key     in  varchar2,
                                    activity_id  in  number,
                                    command      in  varchar2,
                                    resultout    out NOCOPY varchar2) is

    --l_context WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_display_name varchar2 (100);
    l_first_name WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_last_name WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_middle_name WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_suffix  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_prefix  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_requested_for_user_id  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_username  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_email_address  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_primary_phone  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_phone_area_code  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_phone_country_code  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_justification  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_reg_service_type  WF_ACTIVITY_ATTRIBUTES.text_default%type;
    l_mins  WF_ACTIVITY_ATTRIBUTES.number_default%type;
    l_days  WF_ACTIVITY_ATTRIBUTES.number_default%type;
    l_registration_data wf_event_t;
    l_person_party_id hz_parties.party_id%type;

    x_return_status varchar2 (10);
    x_msg_count number;
    x_msg_data varchar2 (280);
    x_formatted_name varchar2 (300);
    x_formatted_phone varchar2 (300);
    x_formatted_lines_cnt number;
    x_formatted_name_tbl hz_format_pub.string_tbl_type;

    cursor get_username_from_userid (p_user_id in number) is
      select fu.user_name, fu.email_address, hzp.Person_first_name,
             hzp.Person_last_name, hzp.Person_middle_name, hzp.person_Name_suffix,
             hzp.person_pre_name_adjunct
      from fnd_user fu, hz_parties hzp
      where fu.user_id = p_user_id
      and   hzp.party_id(+) = fu.person_party_id;


  begin

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       'fnd.plsql.UMXNTFSB.getreceipientusername.begin', 'Begin');
      end if;

      l_first_name := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'FIRST_NAME',
                               ignore_notfound => true);

      l_last_name := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'LAST_NAME',
                               ignore_notfound => true);

      l_middle_name := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'MIDDLE_NAME',
                               ignore_notfound => true);

      l_suffix := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'PERSON_SUFFIX',
                               ignore_notfound => true);

      l_prefix := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'PRE_NAME_ADJUNCT',
                               ignore_notfound => true);

      l_requested_for_user_id := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'REQUESTED_FOR_USER_ID',
                               ignore_notfound => false);

      l_username := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'REQUESTED_USERNAME',
                               ignore_notfound => false);

      l_reg_service_type := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'REG_SERVICE_TYPE',
                               ignore_notfound => false);


     /**
      ** this is for additional access workflow where username will not be passed
      **/
      if (((l_reg_service_type = 'ADDITIONAL_ACCESS') or
           (l_reg_service_type = 'ADMIN_ADDITIONAL_ACCESS')) and
          (l_requested_for_user_id is not null)) then

        open get_username_from_userid (l_requested_for_user_id);
        fetch get_username_from_userid
        into l_username,l_email_address,l_first_name,
             l_last_name,l_middle_name,l_suffix,l_prefix;

        wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'REQUESTED_USERNAME',
                      avalue => l_username);

        wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'EMAIL_ADDRESS',
                      avalue => l_email_address);

        if (get_username_from_userid%notfound) then
          close get_username_from_userid;
          raise_application_error ('-20000','invalid userid to send notification.');
        end if;

        close get_username_from_userid;

      end if;

      hz_format_pub.format_name (
                       p_person_first_name =>l_first_name ,
                       p_person_middle_name => l_middle_name,
                       p_person_last_name => l_last_name,
                       p_person_title => l_prefix,
                       p_person_name_suffix => l_suffix,
                       x_return_status => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_formatted_name => x_formatted_name,
                       x_formatted_lines_cnt => x_formatted_lines_cnt,
                       x_formatted_name_tbl     => x_formatted_name_tbl);

      wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'USER_DISPLAY_NAME',
                      avalue => LOWER (l_username));

      if (x_formatted_name is null) then
        -- The formatted name is missing due to first name, last name, etc are missing.
        -- Get the formatted name from person party id
        -- Get the person party id from the event message
        l_registration_data :=
           wf_engine.getitemattrevent (item_type, item_key, 'REGISTRATION_DATA');
        l_person_party_id := wf_event.GetValueForParameter (
                               p_name          => 'PERSON_PARTY_ID',
                               p_parameterlist => l_registration_data.getParameterList);
        if (l_person_party_id is null) then
           x_formatted_name := l_username;
        else
           x_formatted_name := hz_format_pub.format_name (p_party_id => l_person_party_id);
        end if;
      end if;

      wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'FORMATED_NAME',
                      avalue => x_formatted_name);

      -- getting a formated phone number

      l_primary_phone := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'PRIMARY_PHONE',
                               ignore_notfound => false);

      l_phone_country_code := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'COUNTRY_CODE',
                               ignore_notfound => false);

      l_phone_area_code := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'AREA_CODE',
                               ignore_notfound => false);

      -- phone extension is not available in phone formating

      HZ_FORMAT_PHONE_V2PUB.phone_display (
                    p_phone_country_code => l_phone_country_code,
                    p_phone_area_code => l_phone_area_code,
                    p_phone_number => l_primary_phone,
                    x_formatted_phone_number => x_formatted_phone,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data );

      wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'FORMATED_PHONE',
                      avalue => x_formatted_phone);
      --justification
      l_justification := wf_engine.getitemattrtext (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'JUSTIFICATION',
                               ignore_notfound => false);

      if (l_justification is null ) then

        wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'JUSTIFICATION',
                      avalue => fnd_message.get_string ('FND','UMX_NOT_AVAIL'));
      end if;

      --convert the mins timeout to days.
      l_mins := wf_engine.GetItemAttrNumber (
                               itemtype => item_type,
                               itemkey => item_key,
                               aname =>'MINS_TO_TIMEOUT',
                               ignore_notfound => true);
      if (l_mins > 0) then
        l_days := l_mins / 1440;
        wf_engine.setItemattrtext (
                      itemtype => item_type,
                      itemkey  => item_key,
                      aname  => 'DAYS_TO_TIMEOUT',
                      avalue => l_days);
      end if;

      resultout := 'COMPLETE:';

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       'fnd.plsql.UMXNTFSB.getrecipientusername.end', 'End');
      end if;

    end if; --command = run

    EXCEPTION
      WHEN others THEN
        Wf_Core.Context ('UMX_NOTIFICATION_UTIL', 'getRecipientUsername', item_type, item_key);
        raise;
  end get_recipient_username;

  procedure throw_exception (item_type    in  varchar2,
                             item_key     in  varchar2,
                             activity_id  in  number,
                             command      in  varchar2,
                             resultout    out NOCOPY varchar2) is
  begin
    if (command = 'RUN') then
      raise_application_error ('-20000', 'error out');
    end if;
  end throw_exception;

  procedure UpdateApprovalStatus (item_type    in  varchar2,
                                  item_key     in  varchar2,
                                  activity_id  in  number,
                                  command      in  varchar2,
                                  resultout    out NOCOPY varchar2) IS

    l_ame_transaction_type_id WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_ame_application_id  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_reg_request_id  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_current_approver ame_util.approverRecord2;

  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.updateapprovalstatus.begin', 'Begin');
      end if;

      -- get the next approver record again, this will not increment
      -- approver chain it returns the same approver
      l_ame_application_id := wf_engine.getitemattrtext (
                                itemtype => item_type,
                                itemkey => item_key,
                                aname =>'AME_APPLICATION_ID',
                                ignore_notfound => false);

      l_ame_transaction_type_id := wf_engine.getitemattrtext (
          itemtype => item_type,
          itemkey => item_key,
          aname =>'AME_TRANSACTION_TYPE_ID',
          ignore_notfound => false);

      l_reg_request_id := wf_engine.getitemattrtext (
                            itemtype => item_type,
                            itemkey => item_key,
                            aname =>'UMX_PARENT_ITEM_KEY',
                            ignore_notfound => false);

      --populate the l_current_approver record
      l_current_approver := umx_reg_requests_pvt.getNextApproverPvt (p_ame_application_id      => l_ame_application_id,
                                                                  p_ame_transaction_type_id => l_ame_transaction_type_id,
                                                                  p_reg_request_id          => l_reg_request_id);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXNTFSB.updateapprovalstatus',
                        'approver username:'|| l_current_approver.name);
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXNTFSB.updateapprovalstatus',
                        'Before calling ame_api2.updateapprovalstatus (' ||
                        l_ame_application_id || ',' || l_ame_transaction_type_id || ',' ||
                        l_reg_request_id || ',' || l_current_approver.name || ')');
      end if;

      l_current_approver.approval_status := ame_util.approvedStatus;
      ame_api2.updateapprovalstatus (applicationIdIn   => l_ame_application_id,
                                     transactionTypeIn => l_ame_transaction_type_id,
                                     transactionIdIn   => l_reg_request_id,
                                     approverIn        => l_current_approver);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXNTFSB.updateapprovalstatus',
                        'After calling ame_api2.updateapprovalstatus.');
      end if;

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.updateapprovalstatus.end', 'End');
      end if;

    end if;

  EXCEPTION
  WHEN others THEN
     Wf_Core.Context ('UMX_NOTIFICATION_UTIL', 'updateApprovalStatus', item_type, item_key);
     raise;

  END UpdateApprovalStatus;

  procedure UpdateRejectedStatus (item_type   in  varchar2,
                                  item_key    in  varchar2,
                                  activity_id in  number,
                                  command     in  varchar2,
                                  resultout   out NOCOPY varchar2) IS

    l_ame_transaction_type_id WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_ame_application_id  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_reg_request_id  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_rejection_reason  WF_ACTIVITY_ATTRIBUTES.text_default%TYPE;
    l_current_approver ame_util.approverRecord2;
    l_event wf_event_t;
    l_status varchar2 (15);

  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.updateRejectedStatus.begin', 'Begin');
      end if;

      -- get the next approver record again, this will not increment
      -- approver chain it returns the same approver
      l_ame_application_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname =>'AME_APPLICATION_ID',
                                                  ignore_notfound => false);
      l_ame_transaction_type_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname =>'AME_TRANSACTION_TYPE_ID',
                                                  ignore_notfound => false);
      l_reg_request_id := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname =>'UMX_PARENT_ITEM_KEY',
                                                  ignore_notfound => false);
      l_rejection_reason := wf_engine.getitemattrtext (itemtype => item_type,
                                                  itemkey => item_key,
                                                  aname =>'WF_NOTE',
                                                  ignore_notfound => false);

      --populate the l_current_approver record
      l_current_approver := umx_reg_requests_pvt.getNextApproverPvt (p_ame_application_id      => l_ame_application_id,
                                                                  p_ame_transaction_type_id => l_ame_transaction_type_id,
                                                                  p_reg_request_id          => l_reg_request_id);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXNTFSB.updateRejectedStatus',
                        'approver username:'|| l_current_approver.name);
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXNTFSB.updateRejectedStatus',
                        'Before calling ame_api2.updateapprovalstatus (' ||
                        l_ame_application_id || ',' || l_ame_transaction_type_id || ',' ||
                        l_reg_request_id || ',' || l_current_approver.name || ')');
      end if;

      l_current_approver.approval_status := ame_util.rejectStatus;
      ame_api2.updateapprovalstatus (applicationIdIn   => l_ame_application_id,
                                     transactionTypeIn => l_ame_transaction_type_id,
                                     transactionIdIn   => l_reg_request_id,
                                     approverIn        => l_current_approver);

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                        'fnd.plsql.UMXNTFSB.updateRejectedStatus',
                        'After calling ame_api2.updateapprovalstatus.');
      end if;

      -- populate the rejected reason into event object, and main wf
      -- so that, this will go into rejection notification
      l_event := wf_engine.getitemattrevent (itemtype => item_type,
                                             itemkey => item_key,
                                             name => 'REGISTRATION_DATA');

      l_status := UMX_REGISTRATION_UTIL.set_event_object (
                                            p_event => l_event,
                                            p_attr_name => 'WF_NOTE',
                                            p_attr_value => l_rejection_reason);

      wf_engine.setitemattrevent (itemtype => item_type,
                                  itemkey  => item_key,
                                  name     => 'REGISTRATION_DATA',
                                  event    => l_event);

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.updaterejectedstatus.end', 'End');
      end if;

    end if;

  EXCEPTION
    WHEN others THEN
      wf_core.context ('UMX_NOTIFICATION_UTIL', 'UpdateRejectedStatus', item_type, item_key);
      raise;
  END UpdateRejectedStatus;

  -- Procedure
  --      query_role_display_name
  --
  -- Description
  -- query the wf_local_roles table for role_display_name
  -- also query the username for this request if it was not passed (ART,SMART)
  -- IN
  --   itemtype  - A valid item type from (WF_ITEM_TYPES table).
  --   itemkey   - A string generated from the application object's primary key.
  --   actid     - The function activity (instance id).
  --   funcmode  - Run/Cancel/Timeout
  -- OUT
  --   resultout - result of the process based on which the next step is followed
  procedure query_role_display_name (item_type    in  varchar2,
                                     item_key     in  varchar2,
                                     activity_id  in  number,
                                     command      in  varchar2,
                                     resultout    out NOCOPY varchar2) is

    l_role_name wf_local_roles.name%type;
    l_role_display_name wf_all_roles_vl.display_name%type;

  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.queryroledisplayname.begin', 'Begin');
      end if;

      l_role_name := wf_engine.getitemattrtext (itemtype => item_type,
                                                itemkey => item_key,
                                                aname =>'WF_ROLE_NAME',
                                                ignore_notfound => false);

      if (l_role_name is not null) then

        begin
          select display_name into l_role_display_name
          from wf_all_roles_vl
          where name = l_role_name;
        exception
          when NO_DATA_FOUND THEN
            l_role_display_name :='';
        end;

      end if;

      if (l_role_display_name is not null) then
        wf_engine.setitemattrtext (itemtype => item_type,
                                   itemkey => item_key,
                                   aname  => 'ROLE_DISPLAY_NAME',
                                   avalue => l_role_display_name);
      end if;

      resultout := 'COMPLETE';

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.queryRoleDisplayName.end',
                        'roleDisplayName:'|| l_role_display_name);
      end if;
    end if;

  END query_role_display_name;

  -- Procedure
  --   getDecryptedPassword
  --
  -- Description
  -- Since we cannot store  decrypted password in table, the password has to be decrypted during run time.
  -- And this can be achived by using a document type attribute. This method is attached to the attribute
  -- DECRYPT_PWD. It will be called internally by workflow(run time) while emnbedding the attribute in the message body.
  -- IN
  --   document_id  - the encrypted pass
  --   display_type   - internally passed by WF
  -- IN OUT
  --   document     - decrypted password
  --   document_type  - Defualt plain/text
  procedure getUnencryptedPassword (document_id in varchar2,
																  display_type in varchar2,
  																document in out nocopy varchar2,
   																document_type in out nocopy varchar2) is
  begin

      document:=icx_call.decrypt(document_id);
     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.getUnencryptedPassword.end',
                        'decryption done');
      end if;
 end;

end UMX_NOTIFICATION_UTIL;

/
