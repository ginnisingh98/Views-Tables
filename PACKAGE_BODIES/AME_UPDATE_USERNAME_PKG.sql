--------------------------------------------------------
--  DDL for Package Body AME_UPDATE_USERNAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_UPDATE_USERNAME_PKG" as
/* $Header: ameupdun.pkb 120.4 2006/12/26 13:23:42 avarri noship $ */

  procedure log_message
    (p_message       varchar2
    ,p_errorcode     integer default -20002
    )  as
    l_log_id integer;
  begin
    select ame_exceptions_log_s.nextval
      into l_log_id
      from dual;

    insert into ame_exceptions_log
      (log_id,package_name,routine_name,transaction_id,application_id,exception_number,exception_string)
     values
      (l_log_id,'ame_update_username_pkg','update_username','','',p_errorcode,to_char(sysdate, 'YYYY:MM:DD:HH24:MI:SS')|| p_message);

  end log_message;

  procedure update_username
    (itemtype    in            varchar2
    ,itemkey     in            varchar2
    ,actid       in            number
    ,funcmode    in            varchar2
    ,resultout   in out nocopy varchar2
    ) as

    l_event_key varchar2(650);
    l_old_name  varchar2(320);
    l_new_name  varchar2(320);
    l_delim_pos integer;
    l_success   boolean;
    wf_yes      varchar2(1);
    wf_no       varchar2(1);
    admin_approver varchar2(320);
    l_event wf_event_t;
  begin
    wf_yes := 'Y';
    wf_no := 'N';
    l_success := true;

    if funcmode = 'RUN' then

      log_message ('AME User Name Migration Process started at ' || to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));

      l_event_key := wf_engine.GetItemAttrText
                       (itemtype  => itemtype
                       ,itemkey   => itemkey
                       ,aname     => 'AMEUPDUN_EVENT_KEY'
                       );
      log_message ('Event Key Recieved is ' || l_event_key);

      l_event := wf_engine.GetItemAttrEvent
                       (itemtype  => itemtype
                       ,itemkey   => itemkey
                       ,name     => 'AMEUPDUN_EVENT_MSG'
                       );
      log_message ('Event msg Recieved ');

      l_new_name := l_event.getValueForParameter('USER_NAME');
      l_old_name := l_event.getValueForParameter('OLD_USER_NAME');

      log_message ('Old user name is ' || l_old_name);
      log_message ('New user name is ' || l_new_name);
      log_message ('Migrating variable_value field in ame_config_vars');
      begin
        update ame_config_vars acv
           set acv.variable_value = l_new_name
         where acv.variable_value = l_old_name
           and acv.variable_name = 'adminApprover';
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating parameter field in ame_approval_group_items');
      begin
        update ame_approval_group_items aagi
           set aagi.parameter = l_new_name
         where aagi.parameter = l_old_name
           and aagi.parameter_name = 'wf_roles_name';
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating parameter field in ame_approval_group_members');
      begin
        update ame_approval_group_members aagm
           set aagm.parameter = l_new_name
         where aagm.parameter = l_old_name
           and aagm.parameter_name = 'wf_roles_name';
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating parameter_two field in ame_conditions');
      begin
        update ame_conditions ac
           set ac.parameter_two = l_new_name
         where ac.parameter_two = l_old_name
           and ac.attribute_id = 0;
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating parameter,description fields in ame_actions');
      begin
        update ame_actions aa
           set aa.parameter = l_new_name,
               aa.description = replace(aa.description,l_old_name,l_new_name)
         where aa.parameter = l_old_name
           and exists (select aat.action_type_id
                         from ame_action_types aat
                        where aat.action_type_id = aa.action_type_id
                          and aat.name = 'substitution');
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating name field in ame_temp_old_approver_lists');
      begin
        update ame_temp_old_approver_lists atoal
           set atoal.name = l_new_name
         where atoal.name = l_old_name;
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating name field in ame_temp_insertions');
      begin
        update ame_temp_insertions ati
           set ati.name = l_new_name
         where ati.name = l_old_name;
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating name field in ame_temp_deletions');
      begin
        update ame_temp_deletions atd
           set atd.name = l_new_name
         where atd.name = l_old_name;
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating parameter field in ame_temp_insertions');
      begin
        update ame_temp_insertions ati
           set ati.parameter = l_new_name ||
                               substrb(ati.parameter
                                      ,instrb(ati.parameter
                                             ,fnd_global.local_chr(11)
                                             ,1
                                             ,1)
                                      ,(lengthb(ati.parameter) - instrb(ati.parameter
                                                                       ,fnd_global.local_chr(11)
                                                                       ,1
                                                                       ,1) + 1))
         where ati.order_type in ('before approver','after approver')
           and instrb(ati.parameter,l_old_name,1,1) = 1;
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating description field in ame_temp_insertions');
      begin
        update ame_temp_insertions ati
           set ati.description = decode(order_type
                                       ,'after_approver'
                                       ,'Always put the new approver right after the following approver:  ' || l_new_name
                                       ,'Always put the new approver right before the following approver:  ' || l_new_name)
         where ati.order_type in ('before approver','after approver')
           and exists (select aca.application_id
                         from ame_calling_apps aca
                        where aca.application_id = ati.application_id)
           and instrb(ati.parameter,l_new_name,1,1) = 1
           and exists (select wr.name
                         from wf_roles wr
                        where wr.name = l_new_name
                          and wr.orig_system = 'FND_USR');
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;

      log_message('Migrating name field in ame_trans_approval_history');
      begin
        update ame_trans_approval_history atah
           set atah.name = l_new_name
         where atah.name = l_old_name;
        if sql%found then
          log_message('Migrated ' || sql%rowcount || ' rows successfully');
        else
          log_message('No Rows Migrated');
        end if;
      exception
        when others then
          rollback;
          log_message('Migration Failed');
          log_message(sqlerrm,sqlcode);
          l_success := false;
      end;
      log_message('AME User Name Migration Process completed at ' || to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
    end if;

    begin
      select variable_value
        into admin_approver
        from ame_config_vars
       where sysdate between start_date and nvl(end_date - (1/86400),sysdate)
         and variable_name = 'adminApprover'
         and (application_id is null or application_id = 0)
         and rownum < 2;
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'AMEUPDUN_ADMIN_APPROVER'
        ,avalue   => admin_approver);
    exception
      when others then
        admin_approver := 'SYSADMIN';
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMEUPDUN_ADMIN_APPROVER'
          ,avalue   => admin_approver);
    end;

    if l_success then
      resultout := wf_engine.eng_completed || ':' || wf_yes;
    else
      resultout := wf_engine.eng_completed || ':' || wf_no;
    end if;

    return;

  exception
    when others then
      rollback;
      begin
        select variable_value
          into admin_approver
          from ame_config_vars
         where sysdate between start_date and nvl(end_date - (1/86400),sysdate)
           and variable_name = 'adminApprover'
           and (application_id is null or application_id = 0)
           and rownum < 2;
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMEUPDUN_ADMIN_APPROVER'
          ,avalue   => admin_approver);
      exception
        when others then
          admin_approver := 'SYSADMIN';
          wf_engine.SetItemAttrText
            (itemtype => itemtype
            ,itemkey  => itemkey
            ,aname    => 'AMEUPDUN_ADMIN_APPROVER'
            ,avalue   => admin_approver);
      end;
      log_message('Migration Failed Completely');
      log_message(sqlerrm,sqlcode);
      resultout := wf_engine.eng_completed || ':' || wf_no;
      return;
  end update_username;

end ame_update_username_pkg;

/
