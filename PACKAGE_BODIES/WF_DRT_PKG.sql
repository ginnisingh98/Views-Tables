--------------------------------------------------------
--  DDL for Package Body WF_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DRT_PKG" AS
/* $Header: wfdrtpb.pls 120.0.12010000.5 2018/06/13 04:33:18 nsanika noship $ */

  g_plsqlName varchar2(35) := 'wf.plsql.WF_DRT_PKG.';

  -- wf_hr_drc
  --   Implement Core HR specific DRC for HR entity type
  -- IN:
  --   person_id - HR person id
  -- OUT:
  --   result_tbl - DRC record structure
  --
  PROCEDURE wf_hr_drc(person_id       IN         number,
                      result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_api varchar2(100) := g_plsqlName ||'wf_hr_drc';
    l_count number;
    l_username WF_LOCAL_ROLES.NAME%TYPE;
    l_person_id number := person_id;

    --cursor to get active workflows of the given user
    cursor openWorkflows is
       select item_type, item_key
       from WF_ITEM_ATTRIBUTE_VALUES
       where substr(text_value,1,320) = substr(l_username,1,320)
       union
       select message_type item_type, item_key
       from wf_notifications
       where notification_id in
             (select notification_id
	      from WF_NOTIFICATION_ATTRIBUTES
	      where substr(text_value,1,320) = substr(l_username,1,320))
       union
       select item_type, item_key
       from WF_ITEM_ACTIVITY_STATUSES
       where (assigned_user = l_username
       or performed_by = l_username)
       union
       select message_type item_type, item_key
       from wf_notifications
       where (recipient_role = l_username
       or more_info_role = l_username
       or original_recipient = l_username
       or from_role = l_username
       or responder = l_username);

  BEGIN

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'Begin, person_id:'||person_id);
    begin
      --get the user name from HR person id
      -- Bug 27938611 : remove person_id = person_id with local varibale to avoid fetching full data
      select name
      into l_username
      from wf_local_roles
      where orig_system = 'PER_ROLE'
      and orig_system_id in
          (select person_id
	   from per_all_people_f
	   where person_id = l_person_id);
    exception
      when NO_DATA_FOUND then
	WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'No HR person exists with person_id:'||person_id);
        wf_core.context('WF_DRT_PKG','wf_hr_drc',to_char(person_id));
	raise;
    end;

    select count(1)
    into l_count
    from wf_items
    where owner_role = l_username
    and end_date is NULL
    and rownum = 1;

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'The open wf items count owned by user is:'||l_count);

    --Add row to DRC record structure with status Error when there are
    --active workflows owned by given user
    if(l_count >= 1) then
       WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_ERROR, l_api,
                            'Adding DRC record with error message code WF_ACTIVE_WOKFLOWS_EXIST');
       per_drt_pkg.add_to_results(person_id => person_id,
	       entity_type => 'HR',
	       status => 'E',
	       msgcode => 'WF_ACTIVE_WOKFLOWS_EXIST',
	       msgaplid => 0,
	       result_tbl => result_tbl);
     else
         for rec_wf_items in openWorkflows loop
            select count(1)
            into l_count
            from wf_items
            where item_type = rec_wf_items.item_type
            and item_key = rec_wf_items.item_key
            and item_type <> 'WFERROR'
            and end_date is NULL;

            WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                      'The open wf items count for item type:' || rec_wf_items.item_type || ', item key:'
                      || rec_wf_items.item_key ||' is:'||l_count);

	    --Add row to DRC record structure with status Error when there are active workflows for given user
	    if(l_count >= 1) then
	       WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_ERROR, l_api,
                   'Adding DRC record with error message code WF_ACTIVE_WOKFLOWS_EXIST for user:'||l_username);
	       per_drt_pkg.add_to_results(person_id => person_id,
		   entity_type => 'HR',
	           status => 'E',
	           msgcode => 'WF_ACTIVE_WOKFLOWS_EXIST',
	           msgaplid => 0,
	           result_tbl => result_tbl);
               exit;
            end if;
	 end loop;
     end if;

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'End, person_id:'||person_id);
  exception
    when OTHERS then
      wf_core.context('WF_DRT_PKG','wf_hr_drc',to_char(person_id));
      raise;
  END wf_hr_drc;

  -- wf_tca_drc
  --   Implement Core HR specific DRC for TCA entity type
  -- IN:
  --   person_id - TCA person id
  -- OUT:
  --   result_tbl - DRC record structure
  --
  PROCEDURE wf_tca_drc(person_id       IN         number,
                       result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_api varchar2(100) := g_plsqlName || 'wf_tca_drc';
    l_count number;
    l_username WF_LOCAL_ROLES.NAME%TYPE;

    --cursor to get active workflows of the given user
    cursor openWorkflows is
       select item_type, item_key
       from WF_ITEM_ATTRIBUTE_VALUES
       where substr(text_value,1,320) = substr(l_username,1,320)
       union
       select message_type item_type, item_key
       from wf_notifications
       where notification_id in
             (select notification_id
	      from WF_NOTIFICATION_ATTRIBUTES
	      where substr(text_value,1,320) = substr(l_username,1,320))
       union
       select item_type, item_key
       from WF_ITEM_ACTIVITY_STATUSES
       where (assigned_user = l_username
       or performed_by = l_username)
       union
       select message_type item_type, item_key
       from wf_notifications
       where (recipient_role = l_username
       or more_info_role = l_username
       or original_recipient = l_username
       or from_role = l_username
       or responder = l_username);

  BEGIN

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'Begin, person_id:'||person_id);
    begin
      select name
      into l_username
      from wf_local_roles
      where orig_system = 'HZ_PARTY'
      and orig_system_id in
          (select party_id
	   from hz_parties
	   where party_type = 'PERSON'
	   and party_id = person_id);
    exception
      when NO_DATA_FOUND then
	WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'No TCA person exists with person_id:'||person_id);
        wf_core.context('WF_DRT_PKG','wf_hr_drc',to_char(person_id));
	raise;
    end;

    select count(1)
    into l_count
    from wf_items
    where owner_role = l_username
    and end_date is NULL
    and rownum = 1;

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'The open wf items count owned by user is:'||l_count);

    --Add row to DRC record structure with status Error when there are active workflows owned by given user
    if(l_count >= 1) then
       WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_ERROR, l_api,
                            'Adding DRC record with error message code WF_ACTIVE_WOKFLOWS_EXIST');
       per_drt_pkg.add_to_results(person_id => person_id,
	       entity_type => 'FND',
	       status => 'E',
	       msgcode => 'WF_ACTIVE_WOKFLOWS_EXIST',
	       msgaplid => 0,
	       result_tbl => result_tbl);
     else
         for rec_wf_items in openWorkflows loop
            select count(1)
            into l_count
            from wf_items
            where item_type = rec_wf_items.item_type
	    and item_key = rec_wf_items.item_key
	    and item_type <> 'WFERROR'
	    and end_date is NULL;

            WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                      'The open wf items count for item type:' || rec_wf_items.item_type || ', item key:'
                      || rec_wf_items.item_key ||' is:'||l_count);

	    --Add row to DRC record structure with status Error when there are active workflows for given user
	    if(l_count >= 1) then
	       WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_ERROR, l_api,
                   'Adding DRC record with error message code WF_ACTIVE_WOKFLOWS_EXIST for user:'||l_username);
	       per_drt_pkg.add_to_results(person_id => person_id,
		   entity_type => 'FND',
	           status => 'E',
	           msgcode => 'WF_ACTIVE_WOKFLOWS_EXIST',
	           msgaplid => 0,
	           result_tbl => result_tbl);
	       exit;
            end if;
	 end loop;
     end if;

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'End, person_id:'||person_id);
  exception
    when OTHERS then
      wf_core.context('WF_DRT_PKG','wf_tca_drc',to_char(person_id));
      raise;
  END wf_tca_drc;

  -- wf_fnd_drc
  --   Implement Core HR specific DRC for FND entity type
  -- IN:
  --   person_id - FND user id
  -- OUT:
  --   result_tbl - DRC record structure
  --
  PROCEDURE wf_fnd_drc(person_id       IN           number,
                       result_tbl     OUT NOCOPY   per_drt_pkg.result_tbl_type)
  IS
    l_api varchar2(100) := g_plsqlName || 'wf_fnd_drc';
    l_count number;
    l_username WF_LOCAL_ROLES.NAME%TYPE;

    --cursor to get active workflows of the given user
    cursor openWorkflows is
       select item_type, item_key
       from WF_ITEM_ATTRIBUTE_VALUES
       where substr(text_value,1,320) = substr(l_username,1,320)
       union
       select message_type item_type, item_key
       from wf_notifications
       where notification_id in
              (select notification_id
	       from WF_NOTIFICATION_ATTRIBUTES
	       where substr(text_value,1,320) = substr(l_username,1,320))
       union
       select item_type, item_key
       from WF_ITEM_ACTIVITY_STATUSES
       where (assigned_user = l_username
       or performed_by = l_username)
       union
       select message_type item_type, item_key
       from wf_notifications
       where (recipient_role = l_username
       or more_info_role = l_username
       or original_recipient = l_username
       or from_role = l_username
       or responder = l_username);

  BEGIN

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'Begin, person_id:'||person_id);
    begin
      select user_name
      into l_username
      from fnd_user
      where user_id = person_id;
    exception
      when NO_DATA_FOUND then
	WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'No FND user exists with person_id:'||person_id);
        wf_core.context('WF_DRT_PKG','wf_hr_drc',to_char(person_id));
	raise;
    end;

    select count(1)
    into l_count
    from wf_items
    where owner_role = l_username
    and end_date is NULL
    and rownum = 1;

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
               'The open wf items count owned by user is:'||l_count);
    --Add row to DRC record structure with status Error when there are
    --active workflows owned by given user
    if(l_count >= 1) then
       WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_ERROR, l_api,
                            'Adding DRC record with error message code WF_ACTIVE_WOKFLOWS_EXIST');
       per_drt_pkg.add_to_results(person_id => person_id,
	       entity_type => 'FND',
	       status => 'E',
	       msgcode => 'WF_ACTIVE_WOKFLOWS_EXIST',
	       msgaplid => 0,
	       result_tbl => result_tbl);
     else
         for rec_wf_items in openWorkflows loop
            select count(1)
            into l_count
            from wf_items
            where item_type = rec_wf_items.item_type
            and item_key = rec_wf_items.item_key
            and item_type <> 'WFERROR'
            and end_date is NULL;

            WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                 'The open wf items count for item type:' || rec_wf_items.item_type || ', item key:'
                      || rec_wf_items.item_key ||' is:'||l_count);

	    --Add row to DRC record structure with status Error when there are active workflows for given user
	    if(l_count >= 1) then
	       WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_ERROR, l_api,
                   'Adding DRC record with error message code WF_ACTIVE_WOKFLOWS_EXIST for user:'||l_username);
	       per_drt_pkg.add_to_results(person_id => person_id,
		   entity_type => 'FND',
	           status => 'E',
	           msgcode => 'WF_ACTIVE_WOKFLOWS_EXIST',
	           msgaplid => 0,
	           result_tbl => result_tbl);
	       exit;
            end if;
	 end loop;
     end if;

    WF_LOG_PKG.string2(WF_LOG_PKG.LEVEL_STATEMENT, l_api,
                            'End, person_id:'||person_id);
  exception
    when OTHERS then
      wf_core.context('WF_DRT_PKG','wf_fnd_drc',to_char(person_id));
      raise;
  END wf_fnd_drc;

END WF_DRT_PKG;

/
