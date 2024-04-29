--------------------------------------------------------
--  DDL for Package Body AME_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_MIGRATION_PKG" as
  /* $Header: amecpmig.pkb 120.1 2006/12/26 13:14:52 avarri noship $ */
  procedure log_message
    (p_message       varchar2
    ,p_errorcode     integer default -20002
    )  as
    l_log_id integer;
    pragma autonomous_transaction;
  begin
    select ame_exceptions_log_s.nextval
      into l_log_id
      from dual;

    insert into ame_exceptions_log
      (log_id,package_name,routine_name,transaction_id,application_id,exception_number,exception_string)
     values
      (l_log_id,'ame_migration_pkg','sql code block','','',p_errorcode,to_char(sysdate, 'YYYY:MM:DD:HH24:MI:SS')|| p_message);
     commit;
  exception
    when others then
      rollback;
  end log_message;
  --+
  PROCEDURE assign_role(p_role_name IN varchar2
                       ,p_justification IN varchar2
                       ,p_requested_start_date IN varchar2
                       ,p_requested_end_date IN varchar2
                       ,p_requested_for_user_id IN varchar2) is
    l_registration_data UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL;
  begin
    --+
    l_registration_data(1).attr_name := 'wf_role_name';
    l_registration_data(1).attr_value := p_role_name;

    l_registration_data(2).attr_name := 'justification';
    l_registration_data(2).attr_value := p_justification;

    l_registration_data(3).attr_name := 'requested_start_date';
    l_registration_data(3).attr_value := null;

    l_registration_data(4).attr_name := 'requested_end_date';
    l_registration_data(4).attr_value := null;

    l_registration_data(5).attr_name := 'requested_for_user_id';
    l_registration_data(5).attr_value := p_requested_for_user_id;

    umx_pub.assign_role(p_registration_data => l_registration_data);
    --+
  exception
    WHEN OTHERS then
      raise;
  END assign_role;
  --+
  procedure grant_all_rows(p_user_name in varchar2) is
    l_grant_guid raw(16);
    l_success varchar2(1);
    l_error_code number;
  --+
  begin
    --+
    fnd_grants_pkg.grant_function
      (
       p_api_version     => 1.0,
       p_menu_name       => 'AME_TRANS_TYPE_DATA_PERM_SET',
       p_object_name     => 'AME_TRANSACTION_TYPES',
       p_instance_type   => 'GLOBAL',
       p_instance_set_id     => NULL,
       p_instance_pk1_value  => NULL,
       p_instance_pk2_value  => NULL,
       p_instance_pk3_value  => NULL,
       p_instance_pk4_value  => NULL,
       p_instance_pk5_value  => NULL,
       p_grantee_type        =>'USER',
       p_grantee_key         => p_user_name,
       p_start_date          => sysdate,
       p_end_date            => null,
       p_program_name        => NULL,
       p_program_tag         => NULL,
       x_grant_guid     => l_grant_guid,
       x_success        => l_success, /* Boolean */
       x_errorcode      => l_error_code,
       p_parameter1     => NULL,
       p_parameter2     => NULL,
       p_parameter3     => NULL,
       p_parameter4     => NULL,
       p_parameter5     => NULL,
       p_parameter6     => NULL,
       p_parameter7     => NULL,
       p_parameter8     => NULL,
       p_parameter9     => NULL,
       p_parameter10    => NULL,
       p_ctx_secgrp_id    => -1,
       p_ctx_resp_id      => -1,
       p_ctx_resp_appl_id => -1,
       p_ctx_org_id       => -1,
       p_name             => null,
       p_description      => null
      );
      --+
  end grant_all_rows;
  --+
  procedure grant_instance(p_user_name in varchar2
                          ,p_fnd_application_id in number
                          ,p_transaction_type_id IN varchar2) is
    l_grant_guid raw(16);
    l_success varchar2(1);
    l_error_code number;
  --+
  begin
    --+
    fnd_grants_pkg.grant_function
      (
       p_api_version     => 1.0,
       p_menu_name       => 'AME_TRANS_TYPE_DATA_PERM_SET',
       p_object_name     => 'AME_TRANSACTION_TYPES',
       p_instance_type   => 'INSTANCE',
       p_instance_set_id     => NULL,
       p_instance_pk1_value  => p_fnd_application_id,
       p_instance_pk2_value  => p_transaction_type_id,
       p_instance_pk3_value  => NULL,
       p_instance_pk4_value  => NULL,
       p_instance_pk5_value  => NULL,
       p_grantee_type        =>'USER',
       p_grantee_key         => p_user_name,
       p_start_date          => sysdate,
       p_end_date            => null,
       p_program_name        => NULL,
       p_program_tag         => NULL,
       x_grant_guid     => l_grant_guid,
       x_success        => l_success, /* Boolean */
       x_errorcode      => l_error_code,
       p_parameter1     => NULL,
       p_parameter2     => NULL,
       p_parameter3     => NULL,
       p_parameter4     => NULL,
       p_parameter5     => NULL,
       p_parameter6     => NULL,
       p_parameter7     => NULL,
       p_parameter8     => NULL,
       p_parameter9     => NULL,
       p_parameter10    => NULL,
       p_ctx_secgrp_id    => -1,
       p_ctx_resp_id      => -1,
       p_ctx_resp_appl_id => -1,
       p_ctx_org_id       => -1,
       p_name             => null,
       p_description      => null
      );
    --+
  end grant_instance;
  --+
  procedure migrate_amea_users
      (errbuf                 out nocopy varchar2
      ,retcode                out nocopy number
      ) as
    --+
    cursor get_all_ame_users is
      select userresp.user_id
            ,resp.responsibility_key
            ,resp.responsibility_id
            ,resp.application_id
            ,users.user_name
            ,userresp.security_group_id
            ,appl.application_short_name
            ,sec.security_group_key
        from fnd_user_resp_groups  userresp
            ,fnd_responsibility_vl resp
            ,fnd_user users
            ,fnd_application appl
            ,fnd_security_groups sec
        where resp.responsibility_id = userresp.responsibility_id
          and resp.responsibility_key in ('AMELIMUSER'
                       ,'AMEGENUSER'
                       ,'AMEAPPADM'
                       )
          and users.user_id = userresp.user_id
          and appl.application_id = resp.application_id
          and sec.security_group_id = userresp.security_group_id
          and users.start_date <= sysdate and
                (users.end_date is null or users.end_date > sysdate)
          and userresp.start_date <= sysdate and
                (userresp.end_date is null or userresp.end_date > sysdate)
          and resp.start_date <= sysdate and
                (resp.end_date is null or resp.end_date > sysdate)
          order by userresp.user_id, resp.responsibility_key;
    --+
    cursor get_sec_web_attr(p_user_id in number) is
      select aca.fnd_application_id
            ,aca.transaction_type_id
        from ak_web_user_sec_attr_values sec
            ,fnd_application app
            ,ame_calling_apps aca
      where sec.attribute_code = 'AME_INTERNAL_TRANS_TYPE_ID'
        and app.application_short_name = 'ICX'
        and sec.attribute_application_id = app.application_id
        and sec.web_user_id = p_user_id
        and sysdate between aca.start_date AND nvl(aca.end_date-1/86400,sysdate)
        and aca.application_id = sec.NUMBER_VALUE;
    --+
    cursor get_old_responsibilities is
      select responsibility_id
            ,application_id
        from fnd_responsibility_vl
        where responsibility_key in ('AMEAPPADM', 'AMEGENUSER', 'AMELIMUSER')
          and start_date <= sysdate and
                (end_date is null or end_date > sysdate);
    --+
    l_current_user_id number;
    l_all_users_mig boolean;
    --+
  begin
   --+
   /* Assign AME_APP_ADMIN role to users with AMEAPPADM responsibility
    * Assign AME_BUS_ANALYST role to users with AMEGENUSER and AMELIMUSER responsibility
    * Grant all rows of ame_calling_apps using all_rows grant on object 'AME_TRANSACTION_TYPES' to
    * AMEGENUSER and AMEAPPADM
    * Grant all rows represented by securing attributes on object 'AME_TRANSACTION_TYPES' to AMELIMUSER
    */
    --+
    log_message ('AME User Responsibility Migration Process started at ' ||
                    to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
    --+
    errbuf := null;
    retcode := 0;
    l_current_user_id := null;
    --+
    for rec in get_all_ame_users loop
      --+
      log_message ('User: '||rec.user_name||' responsibility: '||rec.responsibility_key
                   ||' security_group_id: '||rec.security_group_key);
      --+
      if rec.responsibility_key = 'AMEAPPADM' then
        --+
        begin
          --+
          l_current_user_id := rec.user_id;
          --+
          assign_role(p_role_name => 'UMX|AME_APP_ADMIN'
                     ,p_justification => 'AME Admin User Migration: '||rec.user_id
                     ,p_requested_start_date => null
                     ,p_requested_end_date => null
                     ,p_requested_for_user_id => rec.user_id);
          --+
          grant_all_rows(p_user_name => rec.user_name);
          --+
          fnd_user_pkg.DelResp(username   => rec.user_name,
                               resp_app       => rec.application_short_name,
                               resp_key       =>rec.responsibility_key,
                               security_group => rec.security_group_key);
          commit;
        --+
        exception
          when others then
            log_message ('User Responsibility Migration Failed at AMEAPPADM resp for user '
                          ||rec.user_name || '. Error: '||sqlerrm);
            retcode := 1;
            rollback;
        end;
      --+
      elsif rec.responsibility_key = 'AMEGENUSER' THEN
        --+
        begin
          if(l_current_user_id is null or l_current_user_id <> rec.user_id) then
            assign_role(p_role_name => 'UMX|AME_BUS_ANALYST'
                       ,p_justification => 'AME General User Migration: '||rec.user_id
                       ,p_requested_start_date => null
                       ,p_requested_end_date => null
                       ,p_requested_for_user_id => rec.user_id);

            --+
            grant_all_rows(p_user_name => rec.user_name);
            --+
            l_current_user_id := rec.user_id;
          end if;
          --+
          fnd_user_pkg.DelResp (username   => rec.user_name,
                                resp_app       => rec.application_short_name,
                                resp_key       =>rec.responsibility_key,
                                security_group => rec.security_group_key);
          commit;
        --+
        exception
          when others then
            log_message('User Responsibility Migration Failed at AMEGENUSER resp for user '
                         ||rec.user_name||'. Error: '||sqlerrm);
            retcode := 1;
            rollback;
        end;
      --+
      elsif rec.responsibility_key = 'AMELIMUSER' then
        --+
        begin
          --+
          if(l_current_user_id is null or l_current_user_id <> rec.user_id) then
            --+
            assign_role(p_role_name => 'UMX|AME_BUS_ANALYST'
                       ,p_justification => 'AME Limited User Migration: '||rec.user_id
                       ,p_requested_start_date => null
                       ,p_requested_end_date => null
                       ,p_requested_for_user_id => rec.user_id);

            --+
            for secattr in get_sec_web_attr(p_user_id => rec.user_id) loop
              --+
              log_message('user: '||rec.user_name||' securing attribute: '||
                           secattr.fnd_application_id||', '||secattr.transaction_type_id);
              --+
              grant_instance(p_user_name => rec.user_name
                            ,p_fnd_application_id => secattr.fnd_application_id
                            ,p_transaction_type_id => secattr.transaction_type_id);
              --+
            end loop;
            l_current_user_id := rec.user_id;
          end if;
          --+
          fnd_user_pkg.DelResp (username   => rec.user_name,
                                resp_app       => rec.application_short_name,
                                resp_key       =>rec.responsibility_key,
                                security_group => rec.security_group_key);
          commit;
        exception
          when others then
            log_message('User Responsibility Migration Failed at AMELIMUSER resp for user '
                         ||rec.user_name||'. Error: '||sqlerrm);
            retcode := 1;
            rollback;
        end;
      --+
      end if;
    --+
    end loop;
    --+
    l_all_users_mig := true;
    for rec in get_all_ame_users loop
      l_all_users_mig := false;
      exit;
    END loop;
    --+
    if(l_all_users_mig = true) then
      --end date all old responsibilities
      for rec in get_old_responsibilities loop
        fnd_responsibility_pkg.DELETE_ROW (
                        X_RESPONSIBILITY_ID => rec.responsibility_id
                        ,X_APPLICATION_ID => rec.application_id
                        );
      end loop;
    end if;
    --+
    log_message('User Responsibility Migration Completed Successfully at '||
                 to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
    --+
    if(retcode = 1) then
      errbuf := 'Migration of users failed for some users. Check ame_exceptions_log for more details.';
    else
      errbuf := 'Migration successfully completed for all users.';
    end if;
    --+
  end migrate_amea_users;
  --+
  procedure migrate_item_class_usages
      (errbuf                 out nocopy varchar2
      ,retcode                out nocopy number
      ) as
  begin
    --+
    log_message('Item Class Usages Migration Started at '||
                 to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
    --Set all par_mode for header from 'P' to 'S'
    update ame_item_class_usages itu
       set itu.item_class_par_mode = 'S'
      where itu.item_class_par_mode = 'P'
        and sysdate between itu.start_date
              and nvl(itu.end_date - (1/86400), sysdate)
        and exists (select null
                      from ame_item_classes itc
                      where itc.name = 'header'
                        and itc.item_class_id = itu.item_class_id
                        and sysdate between itc.start_date
                              and nvl(itc.end_date - (1/86400), sysdate)
                    );
    --+
    --+Correct all item_id_queries
    --+
    update ame_item_class_usages itu
       set itu.item_id_query = 'select :transactionId from dual'
      where itu.item_id_query = 'select :transaction_id from dual'
        and sysdate between itu.start_date
              and nvl(itu.end_date - (1/86400), sysdate)
        and exists (select null
                      from ame_item_classes itc
                      where itc.name = 'header'
                        and itc.item_class_id = itu.item_class_id
                        and sysdate between itc.start_date
                              and nvl(itc.end_date - (1/86400), sysdate)
                    );
    --+
    errbuf := 'Migration of item class usages successful';
    retcode := 0;
    --+
    log_message('Item Class Usages Migration Completed successfully at '||
                 to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
  exception
    when others then
      errbuf := 'Migration of item class usages failed.';
      retcode := 1;
  end migrate_item_class_usages;
  --+
  procedure migrate_all
      (errbuf                 out nocopy varchar2
      ,retcode                out nocopy number
      ) as
  l_prog_appl varchar2(100);
  l_prog      varchar2(100);
  l_request_id   number;
  --+
  cursor get_program_application is
    select application_short_name
      from fnd_application
      where application_id = fnd_global.prog_appl_id;
  --+
  cursor get_program is
    select concurrent_program_name
      from fnd_concurrent_programs
      where concurrent_program_id = fnd_global.conc_program_id;
  --+
  begin
    --+
    log_message('All Migration Started at '||
                 to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
    --+
    open get_program_application;
    fetch get_program_application into l_prog_appl;
    --+
    if(get_program_application%NOTFOUND) then
      close get_program_application;
      errbuf := 'Failed. Could not find concurrent program application.';
      retcode := 1;
      return;
    end if;
    close get_program_application;
    --+
    open get_program;
    fetch get_program into l_prog;
    --+
    if(get_program%NOTFOUND) then
      close get_program;
      errbuf := 'Failed. Could not find concurrent program.';
      retcode := 1;
      return;
    end if;
    close get_program;
    --+
    errbuf := errbuf || ' application ' || l_prog_appl ||
              ' program ' || l_prog;
    --+
    l_request_id := fnd_request.submit_request (
                                                application => l_prog_appl,
                                                program     => l_prog,
                                                argument1   => 'Migrate Users'
                                                );
    --+
    errbuf := errbuf || ' Migrate users Request Id: '||l_request_id;
    --+
    l_request_id := fnd_request.submit_request (
                                                application => l_prog_appl,
                                                program     => l_prog,
                                                argument1   => 'Migrate Item Class Usages'
                                                );
    --+
    errbuf := errbuf || ' Migrate item class usages Request Id: '||l_request_id;
    --+
    retcode := 0;
    --+
    log_message('All Migration completed at '||
                 to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
  --+
  end migrate_all;
  --+
  procedure migrate_to_ameb
    (errbuf                 out nocopy varchar2
    ,retcode                out nocopy number
    ,migration_type         in varchar2
    ) as
  begin
    if(migration_type = 'Migrate Users') then
      migrate_amea_users(errbuf => errbuf
                        ,retcode => retcode
                        );
    elsif (migration_type = 'Migrate Item Class Usages') then
      migrate_item_class_usages(errbuf => errbuf
                               ,retcode => retcode
                               );
    elsif (migration_type = 'Migrate All') then
      migrate_all(errbuf => errbuf
                 ,retcode => retcode
                 );
    else
    --+
      log_message('Invalid parameter to concurrent program '||
                   migration_type || ' ' ||
                   to_char(sysdate,'YYYY:MM:DD:HH24:MI:SS'));
      errbuf := 'Invalid parameter to concurrent program.';
      retcode := 1;
    end if;
  end migrate_to_ameb;
  --+
end ame_migration_pkg;

/
