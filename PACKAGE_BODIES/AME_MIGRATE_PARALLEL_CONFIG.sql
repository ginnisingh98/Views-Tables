--------------------------------------------------------
--  DDL for Package Body AME_MIGRATE_PARALLEL_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_MIGRATE_PARALLEL_CONFIG" as
  /* $Header: amemigcfg.pkb 120.3 2006/12/26 13:03:53 avarri noship $ */
  procedure log_message
    (p_package       varchar2
    ,p_routine       varchar2
    ,p_message       varchar2
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
      (l_log_id,p_package,p_routine,'','',p_errorcode,to_char(sysdate, 'YYYY:MM:DD:HH24:MI:SS')|| p_message);
  end log_message;

  procedure migrate_approval_group_config
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    ) as

    cursor unused_group_config_cursor is
      select aagc.application_id,
             aagc.approval_group_id
        from ame_approval_group_config aagc
       where sysdate between aagc.start_date
                         and nvl(aagc.end_date - (1/86400),sysdate)
         and not exists
               (select null
                  from ame_action_usages aau,
                       ame_rule_usages aru,
                       ame_actions aa,
                       ame_action_types aat
                 where aa.action_id = aau.action_id
                   and aau.rule_id = aru.rule_id
                   and aru.item_id = aagc.application_id
                   and sysdate between aa.start_date
                                   and nvl(aa.end_date - (1/86400),sysdate)
                   and sysdate between aat.start_date
                                   and nvl(aat.end_date - (1/86400),sysdate)
                   and aa.parameter = to_char(aagc.approval_group_id)
                   and aat.action_type_id = aa.action_type_id
                   and aat.name in ('pre-chain-of-authority approvals'
                                   ,'post-chain-of-authority approvals'
                                   ,'approval-group chain of authority')
                   and rownum < 2)
      order by aagc.application_id;

    l_application_id       integer;
    l_application_name     varchar2(240);
    l_approval_group_id    integer;
    l_approval_group_name  varchar2(50);
    l_group_count          integer;
    l_string               varchar2(300);
    l_migration_date       date;
  begin
    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,'Approval Group Config Migration');
    l_migration_date := sysdate;
    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,'Migration date:' || to_char(l_migration_date,'RRRR:MM:DD:HH24:MI:SS'));
    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,rpad('=',102,'='));
    l_group_count := 0;
    open unused_group_config_cursor;
    loop
      fetch unused_group_config_cursor
       into l_application_id,
            l_approval_group_id;

      exit when unused_group_config_cursor%notfound;

      update ame_approval_group_config master_cfg
         set master_cfg.end_date = l_migration_date
       where sysdate between master_cfg.start_date
                         and nvl(master_cfg.end_date - (1/86400),sysdate)
         and master_cfg.application_id = l_application_id
         and master_cfg.approval_group_id = l_approval_group_id;

      if lengthb(to_char(l_application_id)) < 50 then
        l_string := rpad(to_char(l_application_id),50,' ');
      else
        l_string := to_char(l_application_id);
      end if;

      l_string := l_string || '| ' || rpad(to_char(l_approval_group_id),50,' ');
      log_message('ame_migrate_parallel_config'
                 ,'migrate_approval_group_config'
                 ,l_string);

      l_group_count := l_group_count + 1;
    end loop;
    close unused_group_config_cursor;

    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,rpad('=',102,'='));
    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,'Migration Completed Successfully');
    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,'Total ' || l_group_count || ' configurations migrated');
    log_message('ame_migrate_parallel_config'
               ,'migrate_approval_group_config'
               ,'Migration completion date:' || to_char(sysdate,'RRRR:MM:DD:HH24:MI:SS'));
    commit;
    retcode := 0;
    errbuf := 'Approval Groups Migrated Successfully';
  exception
    when others then
      rollback;
      if unused_group_config_cursor%isopen then
        close unused_group_config_cursor;
        log_message('ame_migrate_parallel_config'
                   ,'migrate_approval_group_config'
                   ,'Failed during migration of ' ||
                    l_application_name ||
                    ',' ||
                    l_approval_group_name);
      end if;
      log_message('ame_migrate_parallel_config'
                 ,'migrate_approval_group_config'
                 ,'Approval Group Migration Failed');
      log_message('ame_migrate_parallel_config'
                 ,'migrate_approval_group_config'
                 ,'Cause:' || sqlerrm);
      retcode := 1;
      errbuf := 'Approval Groups Migration Failed';
  end migrate_approval_group_config;

  procedure migrate_action_type_config
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    ) as

    cursor unused_atype_config_cursor is
      select aatc.application_id,
             aatc.action_type_id
        from ame_action_type_config aatc
       where sysdate between aatc.start_date
                         and nvl(aatc.end_date - (1/86400),sysdate)
         and not exists
              (select /*+ use_nl (aa aru) */ null
                 from ame_actions aa,
                      ame_action_usages aau,
                      ame_rule_usages aru
                where sysdate between aa.start_date
                                  and nvl(aa.end_date - (1/86400),sysdate)
                  and aa.action_id = aau.action_id
                  and aau.rule_id = aru.rule_id
                  and aru.item_id = aatc.application_id
                  and aa.action_type_id = aatc.action_type_id
                  and rownum < 2)
      order by aatc.application_id;

  l_application_id       integer;
  l_application_name     varchar2(240);
  l_action_type_id       integer;
  l_action_type_name     varchar2(50);
  l_atype_count          integer;
  l_string               varchar2(300);
  l_migration_date       date;
  begin
    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,'Action Type Config Migration');
    l_migration_date := sysdate;
    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,'Migration date:' || to_char(l_migration_date,'RRRR:MM:DD:HH24:MI:SS'));
    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,rpad('=',102,'='));

    l_atype_count := 0;
    open unused_atype_config_cursor;
    loop
      fetch unused_atype_config_cursor
       into l_application_id,
            l_action_type_id;

      exit when unused_atype_config_cursor%notfound;

      update ame_action_type_config master_cfg
         set master_cfg.end_date = l_migration_date
       where sysdate between master_cfg.start_date
                         and nvl(master_cfg.end_date - (1/86400),sysdate)
         and master_cfg.application_id = l_application_id
         and master_cfg.action_type_id = l_action_type_id;

      if lengthb(to_char(l_application_id)) < 50 then
        l_string := rpad(to_char(l_application_id),50,' ');
      else
        l_string := to_char(l_application_id);
      end if;

      l_string := l_string || '| ' || rpad(to_char(l_action_type_id),50,' ');
      log_message('ame_migrate_parallel_config'
                 ,'migrate_action_type_config'
                 ,l_string);

      l_atype_count := l_atype_count + 1;
    end loop;
    close unused_atype_config_cursor;

    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,rpad('=',102,'='));
    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,'Migration Completed Successfully');
    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,'Total ' || l_atype_count || ' configurations migrated');
    log_message('ame_migrate_parallel_config'
               ,'migrate_action_type_config'
               ,'Migration completion date:' || to_char(sysdate,'RRRR:MM:DD:HH24:MI:SS'));
    -- Set the chain ordering mode for the action type configurations of
    -- those action types for which it is not applicable.
    update ame_action_type_config acf
       set chain_ordering_mode = null
          ,voting_regime       = null
     where (chain_ordering_mode is not null or
            voting_regime       is not null)
       and action_type_id not in
                     (select action_type_id
                        from ame_action_type_usages
                       where rule_type = ame_util.authorityRuleType
                         and sysdate between start_date and nvl(end_date,sysdate)
                     )
       and sysdate between start_date and nvl(end_date,sysdate);
    commit;
    retcode := 0;
    errbuf := 'Action Types Migrated Successfully';
  exception
    when others then
      rollback;
      if unused_atype_config_cursor%isopen then
        close unused_atype_config_cursor;
        log_message('ame_migrate_parallel_config'
                   ,'migrate_action_type_config'
                   ,'Failed during migration of ' ||
                    l_application_name ||
                    ',' ||
                    l_action_type_name);
      end if;
      log_message('ame_migrate_parallel_config'
                 ,'migrate_action_type_config'
                 ,'Action Types Migration Failed');
      log_message('ame_migrate_parallel_config'
                 ,'migrate_action_type_config'
                 ,'Cause:' || sqlerrm);
      retcode := 1;
      errbuf := 'Action Types Migration Failed';
  end migrate_action_type_config;

  procedure migrate_parallel_config
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    ) as
    actresult integer;
    grpresult integer;
    grperrbuf varchar2(100);
    acterrbuf varchar2(100);
  begin
    migrate_approval_group_config
      (retcode             => grpresult
      ,errbuf              => grperrbuf
      );

    migrate_action_type_config
      (retcode             => actresult
      ,errbuf              => acterrbuf
      );

    if grpresult <> 0 and
       actresult <> 0 then
      retcode := 1;
      errbuf := 'Parallelization Config Migration failed for both Groups and Action Types';
    elsif grpresult <> 0 then
      retcode := 1;
      errbuf := 'Parallelization Config Migration failed for Groups';
    elsif actresult <> 0 then
      retcode := 1;
      errbuf := 'Parallelization Config Migration failed for Action Types';
    else
      retcode := 0;
      errbuf := 'Successfully Completed the Parallelization Config Migration';
    end if;
  end migrate_parallel_config;

end ame_migrate_parallel_config;

/
