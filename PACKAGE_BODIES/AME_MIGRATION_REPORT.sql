--------------------------------------------------------
--  DDL for Package Body AME_MIGRATION_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_MIGRATION_REPORT" as
/* $Header: amemigrp.pkb 120.0 2005/07/26 06:03 mbocutt noship $ */
  -- Constants
  dynamicPreApprover constant varchar2(50) := 'dynamic pre-approver';
  dynamicPostApprover constant varchar2(50) := 'dynamic post-approver';
  --
  -- Type declaration
  --
  type approver_rec is record(
    id                 integer
   ,user_id            integer
   ,user_name          varchar2(100)
   ,source             varchar2(100)
   ,source_object      ame_util.longStringType
   ,description        varchar2(1000)
   );
  type approvers_table is table of approver_rec index by binary_integer;
  type person_rec is record(
    person_id          integer
   ,wf_role_name       varchar2(320)
   ,full_name          varchar2(100)
   );
  type person_table is table of person_rec index by binary_integer;
  --
  -- variable declaration
  --
  approversToBeMigrated approvers_table;
  invalidUsers          approvers_table;
  migratedApprovers     approvers_table;
  personList            person_table;
--
-- P R I V A T E   R O U T I N E S
--
--
-- Proc: addApprover
--
  procedure addApprover(id            integer
                       ,user_id       integer  default null
                       ,user_name     varchar2 default null
                       ,source        varchar2
                       ,source_object varchar2
                       ,description   varchar2
                       ,approvers in out nocopy approvers_table) as
    tableIndex number;
    --
    --
    --
    cursor c_person (p_person_id number) is
      select person_id, full_name
        from per_all_people_f
       where person_id = p_person_id
         and sysdate between effective_start_date and effective_end_date;
  begin
    tableIndex := approvers.count + 1;
    approvers(tableIndex).id            := id;
    approvers(tableIndex).user_id       := user_id;
    approvers(tableIndex).user_name     := user_name;
    approvers(tableIndex).source        := source;
    approvers(tableIndex).source_object := source_object;
    approvers(tableIndex).description   := description;
    if not personList.exists(id) then
      open c_person(id);
      fetch c_person
      into  personList(id).person_id, personList(id).full_name;
      if c_person%found then
         personList(id).wf_role_name := 'AME_MIGRATION_'||personList(id).person_id;
      else
         personList(id).wf_role_name := 'AME_INVALID_APPROVER';
      end if;
      close c_person;
    end if;
  end addApprover;
  --
  -- Proc: sortApproversTable
  --
  procedure sortApproversTable(approvers in out nocopy approvers_table) as
    l_appr_rec   approver_rec;
    l_person_id  number;
    l_appr_total integer;
  begin
    l_appr_total := approvers.count;
    for i in 1..l_appr_total loop
      for j in i+1..l_appr_total loop
        if approvers(j).id < approvers(i).id then
          l_appr_rec   := approvers(i);
          approvers(i) := approvers(j);
          approvers(j) := l_appr_rec;
        end if;
      end loop;
    end loop;
  end sortApproversTable;
  --
  -- Proc wrapAndPrint (Assuming there is only 5 columns to be printed)
  --
  procedure wrapAndPrint(pTotalPrintColumns number
                        ,pStartPos          number
                        ,pValue1 varchar2, pWidth1  number
                        ,pValue2 varchar2 default null ,pWidth2  number default null
                        ,pValue3 varchar2 default null ,pWidth3  number default null
                        ,pValue4 varchar2 default null ,pWidth4  number default null
                        ,pValue5 varchar2 default null ,pWidth5  number default null
                        ,pSpacer number default 2
                        ) as
    --
    Type NumberArray is varray(5) of integer;
    Type ValueArray is varray(5) of varchar2(100);
    --
    widthArray  NumberArray;
    valueList   ValueArray;
    --
    l_print_string  varchar2(200);
    l_temp_string   varchar2(200);
    l_word_pos      number;
    l_value_length  number;
    --
    function print_not_over return boolean is
    begin
      for i in 1..pTotalPrintColumns loop
        if lengthb(valueList(i)) > 0 then
          return true;
        end if;
      end loop;
      return false;
    end;
  begin
    if pTotalPrintColumns < 1 or pTotalPrintColumns > 5 then
      return;
    end if;
    widthArray  := NumberArray(pWidth1,pWidth2,pWidth3,pWidth4,pWidth5);
    valueList   := ValueArray(pValue1,pValue2,pValue3,pValue4,pValue5);
    while (print_not_over) loop
      l_print_string := rpad(fnd_global.local_chr(32), pStartPos, fnd_global.local_chr(32));
      for i in 1..pTotalPrintColumns loop
        --
        l_value_length := lengthb(valueList(i));
        if l_value_length = 0 then
          l_temp_string := fnd_global.local_chr(32);
        elsif l_value_length <= widthArray(i) then
          l_temp_string := valueList(i);
          valueList(i)  := '';
        else
          --
          --we do not want to break the sentence abruptly, hence try to find the last word
          --upto where we can truncate
          --
          --try to if we can find a word that is separated by space
          --if not try to find a word separated by tab
          --if not it looks like a single word and hence needs doing a substrb at column width
          --
          l_word_pos     := instrb(substrb(valueList(i),1, widthArray(i)), fnd_global.local_chr(32),-1);
          if l_word_pos = 0 then
            --check for tab
            l_word_pos     := instrb(substrb(valueList(i),1,widthArray(i)),  fnd_global.local_chr(9),-1);
            if l_word_pos = 0 then
              l_word_pos := widthArray(i);
            end if;
          end if;
          l_temp_string := substrb(valueList(i), 1, l_word_pos);
          valueList(i)   := substrb(valueList(i), l_word_pos+1);
        end if;
        --
        l_temp_string := rpad(l_temp_string,widthArray(i)+pSpacer,fnd_global.local_chr(32));
        l_print_string := l_print_string || l_temp_string;
        --
      end loop;
      fnd_file.put_line(fnd_file.output, l_print_string);
    end loop;
  end wrapAndPrint;
--
-- Generate reprot
--
  procedure printReport as
  -- Variables
  curr_person_id  integer;
  prev_person_id  integer;
  --
  -- Custom Handlers
  --
    cursor customHandlers is
      select acty.name,
             acty.procedure_name
      from ame_action_types acty
      where  acty.created_by <> 1 and
        not exists (select null
                    from ame_action_types
                    where procedure_name = acty.procedure_name and
                      created_by = 1 and
                      sysdate between start_date and
                         nvl(end_date - (ame_util.oneSecond), sysdate)) and
        sysdate between acty.start_date and
                    nvl(acty.end_date - (ame_util.oneSecond), sysdate);
  --
  --Dynamic action types - to be moved to approval groups
  --
    cursor dynamicActionTypes is
      select acty.name action_type
        ,act.description action
        ,act.parameter source_attribute
      from ame_actions act,
        ame_action_types acty
      where act.action_type_id = acty.action_type_id and
        acty.name in (dynamicPreApprover, dynamicPostApprover) and
        sysdate between act.start_date and nvl(act.end_date - (ame_util.oneSecond), sysdate) and
        sysdate between acty.start_date and nvl(acty.end_date - (ame_util.oneSecond), sysdate);
  begin
     fnd_file.put_line(fnd_file.output, rpad('Test 1', 11, ' ')||': HR People - To be migrated');
     fnd_file.put_line(fnd_file.output, rpad('Data Changes', 11, ' ')||': This lists down all the people (used within AME) that will get migrated to WF_ROLES');
     fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
     fnd_file.put_line(fnd_file.output, rpad('Name', 52, ' ') ||rpad('WF_ROLES.NAME', 50,' '));
     fnd_file.put_line(fnd_file.output, lpad(' ', 5, ' ')||rpad('Source Table', 32, ' ')||rpad('Source Object', 42,' ') || rpad('Description', 50,' '));
     fnd_file.put_line(fnd_file.output, rpad('-', 132, '-'));
     if  approversToBeMigrated.count > 0 then
       curr_person_id := -1;
       for i in 1..approversToBeMigrated.count loop
         if(curr_person_id <> approversToBeMigrated(i).id) then
           curr_person_id := approversToBeMigrated(i).id;
           fnd_file.put_line(fnd_file.output, '--');
           fnd_file.put_line(fnd_file.output, '--');
           wrapAndPrint(pTotalPrintColumns => 2
                        ,pStartPos         => 1
                        ,pValue1           => personList(curr_person_id).full_name
                        ,pWidth1           => 50
                        ,pValue2           => personList(curr_person_id).wf_role_name
                        ,pWidth2           => 50);
         end if;
         if approversToBeMigrated(i).source_object is null then
           wrapAndPrint(pTotalPrintColumns => 1
                        ,pStartPos         => 6
                        ,pValue1           => approversToBeMigrated(i).source
                        ,pWidth1            => 30);
         else
           wrapAndPrint(pTotalPrintColumns => 3
                        ,pStartPos         => 6
                        ,pValue1           => approversToBeMigrated(i).source
                        ,pWidth1            => 30
                        ,pValue2           => approversToBeMigrated(i).source_object
                        ,pWidth2            => 40
                        ,pValue3           => approversToBeMigrated(i).description
                        ,pWidth3            => 50);
         end if;
       end loop;
     end if;
       --
       --
       --
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Test 2', 11, ' ')||': HR People - Already migrated');
       fnd_file.put_line(fnd_file.output, rpad('Data Changes', 11, ' ')||': This lists down all the people (used within AME) already migrated to WF_ROLES');
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Name', 52, ' ') ||rpad('WF_ROLES.NAME', 50,' '));
       fnd_file.put_line(fnd_file.output, lpad(' ', 5, ' ')||rpad('Source Table', 32, ' ')||rpad('Source Object', 42,' ') || rpad('Description', 50,' '));
       fnd_file.put_line(fnd_file.output, rpad('-', 132, '-'));
       if  migratedApprovers.count > 0 then
         curr_person_id := -1;
         for i in 1..migratedApprovers.count loop
           if(curr_person_id <> migratedApprovers(i).id) then
             curr_person_id := migratedApprovers(i).id;
             fnd_file.put_line(fnd_file.output, '--');
             fnd_file.put_line(fnd_file.output, '--');
             wrapAndPrint(pTotalPrintColumns => 2
                         ,pStartPos         => 1
                         ,pValue1           => personList(curr_person_id).full_name
                         ,pWidth1            => 50
                         ,pValue2           => personList(curr_person_id).wf_role_name
                         ,pWidth2            => 50);
           end if;
           if migratedApprovers(i).source_object is null then
             wrapAndPrint(pTotalPrintColumns => 1
                         ,pStartPos         => 6
                         ,pValue1           => migratedApprovers(i).source
                         ,pWidth1            => 30);
           else
             wrapAndPrint(pTotalPrintColumns => 3
                         ,pStartPos         => 6
                         ,pValue1           => migratedApprovers(i).source
                         ,pWidth1            => 30
                         ,pValue2           => migratedApprovers(i).source_object
                         ,pWidth2            => 40
                         ,pValue3           => migratedApprovers(i).description
                         ,pWidth3            => 50);
           end if;
         end loop;
       end if;
       --
       --
       --
       fnd_file.put_line(fnd_file.output, '--');
       fnd_file.put_line(fnd_file.output, '--');
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Test 3', 11, ' ')||': FND User');
       fnd_file.put_line(fnd_file.output, rpad('Data Changes', 11, ' ')||': This table lists all the FND User (linked to a person) used within AME.');
       fnd_file.put_line(fnd_file.output, lpad(' ', 11, ' ')||': Before migration these approvers are shown as FND Users.');
       fnd_file.put_line(fnd_file.output, lpad(' ', 11, ' ')||': After migration these approvers will be shown as HR People.');
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Source', 32, ' ') ||rpad('Source Name', 32,' ') || rpad('Migrated From', 32,' ') ||rpad('Migrated To', 30,' '));
       fnd_file.put_line(fnd_file.output, lpad('(User Name)', 75, ' ') ||lpad('(HR People)', 32,' '));
       fnd_file.put_line(fnd_file.output, rpad('-', 132, '-'));
       if  invalidUsers.count > 0 then
         for i in 1..invalidUsers.count loop
          wrapAndPrint(pTotalPrintColumns => 4
                      ,pStartPos         => 1
                      ,pValue1           => invalidUsers(i).source
                      ,pWidth1            => 30
                      ,pValue2           => invalidUsers(i).source_object
                      ,pWidth2            => 30
                      ,pValue3           => invalidUsers(i).user_name
                      ,pWidth3            => 30
                      ,pValue4           => personList(invalidUsers(i).id).full_name
                      ,pWidth4            => 30);
         end loop;
       end if;
       --
       --dynamic pre/post-approver types - which need to be migrated to the corresponding approval groups
       --
       fnd_file.put_line(fnd_file.output, '--');
       fnd_file.put_line(fnd_file.output, '--');
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Test 4', 11, ' ')||': Dynamic Approval Types');
       fnd_file.put_line(fnd_file.output, rpad('Data Changes', 11, ' ')||': "dynamic pre-approver" and "dynamic post-approver" actions will be moved over to use Approval Groups.');
       fnd_file.put_line(fnd_file.output, rpad(' ', 11, ' ')||'  And the groups will be created with prefix "Dyn. Pre" and "Dyn. Post" respectively');
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Action Type', 32, ' ') ||rpad('Action', 52,' ')|| rpad('"source attribute"', 30,' '));
       fnd_file.put_line(fnd_file.output, rpad('-', 132, '-'));
       for r in dynamicActionTypes loop
          wrapAndPrint(pTotalPrintColumns => 3
                      ,pStartPos         => 1
                      ,pValue1           => r.action_type
                      ,pWidth1            => 30
                      ,pValue2           => r.action
                      ,pWidth2            => 50
                      ,pValue3           => r.source_attribute
                      ,pWidth3            => 30);
       end loop;
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
    --------------------------------------------------------------------
    -- get custom handlers which require to be re-written
    --------------------------------------------------------------------
       fnd_file.put_line(fnd_file.output, rpad('Test 5', 11, ' ')||': Custom Handlers');
       fnd_file.put_line(fnd_file.output, rpad('Data Changes', 11, ' ')||': The following Custom Handlers (Action Types) will need to be re-written.');
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, rpad('Action Type Name', 52, ' ') ||rpad('Handler Name', 50,' '));
       fnd_file.put_line(fnd_file.output, rpad('-', 132, '-'));
       for r in customHandlers loop
         wrapAndPrint(pTotalPrintColumns => 2
                     ,pStartPos         => 1
                     ,pValue1           => r.name
                     ,pWidth1            => 50
                     ,pValue2           => r.procedure_name
                     ,pWidth2            => 50);
       end loop;
       fnd_file.put_line(fnd_file.output, rpad('=', 132, '='));
       fnd_file.put_line(fnd_file.output, '*** End of Report ***');
     end printReport;
--
-- P U B L I C   R O U T I N E S
--
  --
  -- proc generateReport
  --
  procedure generateReport(errbuf  out nocopy varchar2,
                           retcode out nocopy number) as
    --
    -- Variables
    --
    appIndustry         VARCHAR2(30);
    appOracleSchema     VARCHAR2(30);
    appStatus           VARCHAR2(30);
    is11510Applied      varchar2(255);
    isAppInstalled      BOOLEAN;
    lmConditionDesc     varchar2(100);
    --
    --
    --
    cursor c_AME_11510_Patch (table_owner varchar2) is
      select 'Y'
      from all_tables
      where table_name = 'AME_ACTION_USAGES'
        and owner      = table_owner;
    --
    -- Before Migration Cursors
    --
    --
    -- ame_temp_old_approver_lists
    --
    cursor c_oldAppr_NoWFRoles is
      select distinct oldappr.person_id person_id
        from ame_temp_old_approver_lists oldappr
       where oldappr.person_id is not null
         and not exists (select null
                         from wf_roles wf
                          where wf.orig_system_id = oldappr.person_id
                            and wf.orig_system = 'PER'
                            and wf.status      = 'ACTIVE'
                            and (wf.expiration_date is null or
                                sysdate < wf.expiration_date)
                            and rownum < 2);
    --
    -- ame_temp_deletions
    --
    cursor c_delAppr_NoWfRoles is
      select distinct del.person_id person_id
        from ame_temp_deletions del
       where del.person_id is not null
         and not exists (select null from wf_roles wf
                          where wf.orig_system_id = del.person_id
                            and wf.orig_system    = 'PER'
                            and wf.status         = 'ACTIVE'
                            and (wf.expiration_date is null or
                                 sysdate < wf.expiration_date)
                            and rownum < 2);
    --
    -- ame_temp_insertions
    --
    cursor c_insAppr_NoWfRoles is
      select distinct ins.person_id person_id
        from ame_temp_insertions ins
       where ins.person_id is not null
         and not exists (select null from wf_roles wf
                          where wf.orig_system_id = ins.person_id
                            and wf.orig_system    = 'PER'
                            and wf.status         = 'ACTIVE'
                            and (wf.expiration_date is null or
                                 sysdate < wf.expiration_date)
                            and rownum < 2);
  --
  -- ame_conditions - LM
  --
    cursor c_condPerson_NoWfRoles is
      select distinct cond.condition_id
             ,cond.parameter_one
             ,cond.parameter_two person_id
        from ame_conditions cond
       where cond.parameter_one in ('any_approver_person_id','final_approver_person_id')
         and not exists (select null from wf_roles wf
                          where wf.orig_system_id = cond.parameter_two
                            and wf.orig_system    = 'PER'
                            and wf.status         = 'ACTIVE'
                            and (wf.expiration_date is null or
                                 sysdate < wf.expiration_date)
                            and rownum < 2);
  --
  -- ame_approval_group_items
  --
    cursor c_grpItems_NoWfRoles is
      select distinct grpitems.approval_group_id
             ,parameter person_id
             ,grp.name
        from ame_approval_group_items grpitems
          ,ame_approval_groups grp
       where grpitems.parameter_name = ame_util.approverPersonId
         and grp.approval_group_id = grpitems.approval_group_id
         and grp.start_date = (select max(start_date)
                               from ame_approval_groups
                               where approval_group_id = grp.approval_group_id)
         and not exists (select null from wf_roles wf
                          where wf.orig_system_id = grpitems.parameter
                            and wf.orig_system    = 'PER'
                            and wf.status         = 'ACTIVE'
                            and (wf.expiration_date is null or
                                 sysdate < wf.expiration_date)
                            and rownum < 2);
  --
  -- ame_approval_group_members
  --
    cursor c_grpMem_NoWfRoles is
      select  distinct grpmem.approval_group_id
              ,grpmem.parameter person_id
              ,grp.name
        from ame_approval_group_members grpmem
          ,ame_approval_groups grp
       where grpmem.parameter_name = ame_util.approverPersonId
         and grp.approval_group_id = grpmem.approval_group_id
         and grp.start_date = (select max(start_date)
                               from ame_approval_groups
                               where approval_group_id = grp.approval_group_id)
         and not exists (select null from wf_roles wf
                          where wf.orig_system_id = grpmem.parameter
                            and wf.orig_system    = 'PER'
                            and wf.status         = 'ACTIVE'
                            and (wf.expiration_date is null or
                                 sysdate < wf.expiration_date)
                            and rownum < 2);
  --
  -- ame_config_vars (adminApprover)
  --
    cursor c_configVar_NoWfRoles is
      select substrb(config1.variable_value, 11, instrb(config1.variable_value,',')-11) person_id
        from ame_config_vars config1
       where config1.variable_name = 'adminApprover'
         and config1.variable_value like 'person_id%'
         and not exists (select null from ame_config_vars config2
                          where config2.rowid = config1.rowid
                           --and config2.variable_value like 'person_id:,user_id%'
                           and substrb(config2.variable_value,1,12) in ('person_id:,u','person_id:0,'))
         and not exists (select null from wf_roles wf
                          where wf.orig_system_id = substrb(config1.variable_value, 11, instrb(config1.variable_value,',')-11)
                            and wf.orig_system    = 'PER'
                            and wf.status         = 'ACTIVE'
                            and (wf.expiration_date is null or
                                 sysdate < wf.expiration_date)
                            and rownum < 2);
  --
  -- ame_actions - substitution
  --
    cursor c_substituteAction_NoWFRoles is
      select distinct action_id, substrb(parameter, instrb(parameter,':')+1) person_id, description
      from ame_actions
      where parameter like 'person_id:%'
        and exists (select null
                    from ame_action_types
                    where name = ame_util.substitutionTypeName
                     and action_type_id = ame_actions.action_type_id
                     and rownum < 2)
        and not exists (select null
                        from wf_roles wf
                        where wf.orig_system_id = substrb(ame_actions.parameter, instrb(ame_actions.parameter,':')+1)
                          and wf.orig_system    = 'PER'
                          and wf.status         = 'ACTIVE'
                          and (wf.expiration_date is null or
                             sysdate < wf.expiration_date)
                          and rownum < 2);
    --
    -- After Migration Cursors (Already migrated)
    --
  --
  --ame_temp_old_approver_lists
  --
    cursor c_migrated_oldAppr is
      select distinct oldappr.person_id person_id
        from ame_temp_old_approver_lists oldappr
       where oldappr.person_id is not null
         and exists (select null
                       from wf_roles wf
                     where wf.orig_system_id = oldappr.person_id
                       and wf.orig_system = 'PER'
                       and wf.status      = 'ACTIVE'
                       and (wf.expiration_date is null or
                          sysdate < wf.expiration_date)
                       and name like 'AME_MIGRATION%'
                       and rownum < 2);
  --
  --ame_temp_deletions
  --
    cursor c_migrated_delAppr is
      select distinct del.person_id person_id
        from ame_temp_deletions del
       where del.person_id is not null
         and exists (select null
                     from wf_roles wf
                     where wf.orig_system_id = del.person_id
                       and wf.orig_system    = 'PER'
                       and wf.status         = 'ACTIVE'
                       and (wf.expiration_date is null or
                           sysdate < wf.expiration_date)
                       and name like 'AME_MIGRATION%'
                       and rownum < 2);
  --
  --ame_temp_insertions
  --
    cursor c_migrated_insAppr is
      select distinct ins.person_id person_id
        from ame_temp_insertions ins
       where ins.person_id is not null
         and exists (select null
                     from wf_roles wf
                     where wf.orig_system_id = ins.person_id
                       and wf.orig_system    = 'PER'
                       and wf.status         = 'ACTIVE'
                       and (wf.expiration_date is null or
                            sysdate < wf.expiration_date)
                       and name like 'AME_MIGRATION%'
                       and rownum < 2);
  --
  -- ame_conditions - LM
  --
    cursor c_migrated_condPerson is
      select distinct cond.condition_id
             ,cond.parameter_one
             ,substrb(cond.parameter_two, instrb(cond.parameter_two,'AME_MIGRATION_')+14) person_id
             ,cond.parameter_two
        from ame_conditions cond
       where cond.parameter_one in ('any_approver','final_approver')
         and cond.parameter_two like 'AME_MIGRATION%'
         and exists (select null
                     from wf_roles wf
                     where wf.name = cond.parameter_two
                       and wf.orig_system    = 'PER'
                       and wf.status         = 'ACTIVE'
                       and (wf.expiration_date is null or
                            sysdate < wf.expiration_date)
                       and rownum < 2);
  --
  --ame_approval_group_items
  --
    cursor c_migrated_grpItems is
      select distinct grpitems.approval_group_id
             ,substrb(parameter, instrb(parameter,'AME_MIGRATION_')+14) person_id
             ,parameter
             ,grp.name
        from ame_approval_group_items grpitems
          ,ame_approval_groups grp
       where grpitems.parameter_name = 'wf_roles_name'
         and grp.approval_group_id = grpitems.approval_group_id
         and grp.start_date = (select max(start_date)
                               from ame_approval_groups
                               where approval_group_id = grp.approval_group_id)
         and parameter like 'AME_MIGRATION%'
         and exists (select null from wf_roles wf
                     where wf.name = grpitems.parameter
                       and wf.orig_system    = 'PER'
                       and wf.status         = 'ACTIVE'
                       and (wf.expiration_date is null or
                            sysdate < wf.expiration_date)
                       and rownum < 2);
  --
  --ame_approval_group_members
  --
    cursor c_migrated_grpMem is
      select  distinct grpmem.approval_group_id
              ,substrb(grpmem.parameter,instrb(grpmem.parameter,'AME_MIGRATION_')+14) person_id
              ,grpmem.parameter
              ,grp.name
        from ame_approval_group_members grpmem
          ,ame_approval_groups grp
       where grpmem.parameter_name = 'wf_roles_name'
         and grp.approval_group_id = grpmem.approval_group_id
         and grp.start_date = (select max(start_date)
                               from ame_approval_groups
                               where approval_group_id = grp.approval_group_id)
         and grpmem.parameter like 'AME_MIGRATION%'
         and exists (select null from wf_roles wf
                     where wf.name = grpmem.parameter
                       and wf.orig_system    = 'PER'
                       and wf.status         = 'ACTIVE'
                       and (wf.expiration_date is null or
                            sysdate < wf.expiration_date)
                       and rownum < 2);
  --
  --ame_config_vars (adminApprover)
  --
    cursor c_migrated_configVar is
      select substrb(config1.variable_value, instrb(config1.variable_value,'AME_MIGRATION_')+14) person_id
        from ame_config_vars config1
       where config1.variable_name = 'adminApprover'
         and config1.variable_value like 'AME_MIGRATION%'
         and exists (select null from wf_roles wf
                     where name = config1.variable_value
                       and wf.orig_system    = 'PER'
                       and wf.status         = 'ACTIVE'
                       and (wf.expiration_date is null or
                            sysdate < wf.expiration_date)
                       and rownum < 2);
  --
  --ame_actions - substitution
  --
    cursor c_migrated_substituteAction is
      select distinct action_id, substrb(parameter, instrb(parameter,'AME_MIGRATION_')+14) person_id, description
      from ame_actions
      where parameter like 'AME_MIGRATION%'
        and exists (select null
                    from ame_action_types
                    where name = ame_util.substitutionTypeName
                     and action_type_id = ame_actions.action_type_id
                     and rownum < 2)
        and exists (select null
                    from wf_roles wf
                    where wf.name = ame_actions.parameter
                      and wf.orig_system    = 'PER'
                      and wf.status         = 'ACTIVE'
                      and (wf.expiration_date is null or
                         sysdate < wf.expiration_date)
                      and rownum < 2);
  --
  -- *********** Invalid Users in AME ***********
  --
  --
  --ame_temp_old_approver_lists
  --
    cursor c_oldAppr_InvalidUser is
      select distinct oldappr.user_id
             ,fnd.employee_id person_id
             ,fnd.user_name
        from ame_temp_old_approver_lists oldappr
          ,fnd_user fnd
       where oldappr.user_id is not null
         and oldappr.person_id is null
         and fnd.employee_id is not null
         and oldappr.user_id = fnd.user_id;
  --
  --ame_temp_deletions
  --
    cursor c_delAppr_InvalidUser is
      select distinct del.user_id user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_temp_deletions del
          ,fnd_user fnd
       where del.user_id   is not null
         and del.person_id is null
         and fnd.employee_id is not null
         and fnd.user_id = del.user_id;
  --
  --ame_temp_insertions
  --
    cursor c_insAppr_InvalidUser is
      select distinct ins.user_id user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_temp_insertions ins
          ,fnd_user fnd
       where ins.user_id   is not null
         and ins.person_id is null
         and fnd.employee_id is not null
         and fnd.user_id = ins.user_id;
  --
  --ame_conditions - LM
  --
    cursor c_condUser_InvalidUser is
      select distinct condition_id
            ,cond.parameter_two user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_conditions cond
          ,fnd_user fnd
       where cond.parameter_one in ('any_approver_user_id','final_approver_user_id')
         and fnd.employee_id is not null
         and cond.parameter_two = to_char(fnd.user_id);
  --
  --ame_approval_group_items
  --
    cursor c_grpItems_InvalidUser is
      select distinct grp.name
             ,grpitems.parameter user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_approval_group_items grpitems
          ,ame_approval_groups grp
          ,fnd_user fnd
       where grpitems.parameter_name = 'user_id'
         and fnd.employee_id is not null
         and grpitems.parameter = to_char(fnd.user_id)
         and grp.approval_group_id = grpitems.approval_group_id
         and grp.start_date = (select max(start_date)
                               from ame_approval_groups
                               where approval_group_id = grp.approval_group_id);
  --
  --ame_approval_group_members
  --
    cursor c_grpMem_InvalidUser is
      select distinct grp.name
             ,grpmems.parameter user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_approval_group_members grpmems
          ,ame_approval_groups grp
          ,fnd_user fnd
       where grpmems.parameter_name = 'user_id'
         and fnd.employee_id is not null
         and grpmems.parameter = to_char(fnd.user_id)
         and grp.approval_group_id = grpmems.approval_group_id
         and grp.start_date = (select max(start_date)
                               from ame_approval_groups
                               where approval_group_id = grp.approval_group_id);
  --
  --ame_config_vars (adminApprover)
  --
    cursor c_configVar_InvalidUser is
      select distinct substrb(config1.variable_value, instrb(config1.variable_value,':',-1)+1 ) user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_config_vars config1
          ,fnd_user fnd
       where config1.variable_name = 'adminApprover'
         and config1.variable_value like 'person_id:%'
         and lengthb(substrb(config1.variable_value, instrb(config1.variable_value,':',-1)+1 )) > 0
         and fnd.employee_id is not null
         and substrb(config1.variable_value, instrb(config1.variable_value,':',-1)+1 ) = to_char(fnd.user_id);
    --
    -- ame_actions (substitution)
    --
    cursor c_substituteAction_InvalidUser is
      select distinct action_id
             ,substrb(parameter, instrb(parameter,':')+1) user_id
            ,fnd.employee_id person_id
            ,fnd.user_name
        from ame_actions
          ,fnd_user fnd
       where parameter like 'user_id:%'
         and fnd.employee_id is not null
         and substrb(parameter, instrb(parameter,':')+1) = to_char(fnd.user_id)
         and exists (select null
                       from ame_action_types
                      where name           = ame_util.substitutionTypeName
                        and action_type_id = ame_actions.action_type_id
                        and rownum < 2);
begin
  --
  --
  --
  isAppInstalled := FND_INSTALLATION.GET_APP_INFO ('PER',
                                                   appStatus,
                                                   appIndustry,
                                                   appOracleSchema);
 /* open c_AME_11510_Patch(appOracleSchema);
  fetch c_AME_11510_Patch
  into is11510Applied;
  close c_AME_11510_Patch;*/
  is11510Applied:= fnd_profile.value('AME_INSTALLATION_LEVEL');

  --
  -- ************* Approvers To be Migrated *************
  --
  --
  --ame_config_vars - to be migrated
  --
  for r in c_configVar_NoWfRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_config_vars'
               ,source_object => 'n/a'
               ,description => 'n/a'
               ,approvers => approversToBeMigrated);
  end loop;
  --
  --ame_conditions - to be migrated
  --
  for r in c_condPerson_NoWfRoles loop
    if r.parameter_one = 'any_approver_person_id' then
      lmConditionDesc := 'Any approver is person';
    else --final_approver_person_id
      lmConditionDesc := 'The final approver is person';
    end if;
    addApprover(id => r.person_id
               ,source => 'ame_conditions'
               ,source_object => 'condition_id : '||r.condition_id
               ,description   => lmConditionDesc
               ,approvers     => approversToBeMigrated);
  end loop;
  --
  --ame_approval_group_items - to be migrated
  --
  for r in c_grpItems_NoWfRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_approval_group_items'
               ,source_object => 'approval_group_id : '||r.approval_group_id
               ,description => r.name
               ,approvers => approversToBeMigrated);
  end loop;
  --
  --ame_approval_group_members - to be migrated
  --
  for r in c_grpMem_NoWfRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_approval_group_members'
               ,source_object => 'approval_group_id : '||r.approval_group_id
               ,description => r.name
               ,approvers => approversToBeMigrated);
  end loop;
  --
  -- ame_actions - Substitution - to be migrated
  --
  for r in c_substituteAction_NoWfRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_actions'
               ,source_object => 'action_id : '||r.action_id
               ,description => r.description
               ,approvers => approversToBeMigrated);
  end loop;
  --
  --ame_temp_deletions - to be migrated
  --
  for r in c_delAppr_NoWfRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_temp_deletions'
               ,source_object => 'n/a'
               ,description => 'n/a'
               ,approvers => approversToBeMigrated);
  end loop;
  --
  -- ame_temp_insertions - to be migrated
  --
  for r in c_insAppr_NoWfRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_temp_insertions'
               ,source_object => 'n/a'
               ,description => 'n/a'
               ,approvers => approversToBeMigrated);
  end loop;
  --
  -- ame_temp_old_approver_lists - to be migrated
  --
  for r in c_oldAppr_NoWFRoles loop
    addApprover(id => r.person_id
               ,source => 'ame_temp_old_approver_lists'
               ,source_object => 'n/a'
               ,description => 'n/a'
               ,approvers => approversToBeMigrated);
  end loop;
  --
  -- Sort the approver list
  --
  sortApproversTable(approversToBeMigrated);
  --
  -- ************ Approvers - Already Migrated ************
  --
  if is11510Applied is not null then
    --
    --ame_config_vars - already migrated
    --
    for r in c_migrated_configVar loop
      addApprover(id => r.person_id
                 ,source => 'ame_config_vars'
                 ,source_object => 'n/a'
                 ,description => 'n/a'
                 ,approvers => migratedApprovers);
    end loop;
    --
    --ame_conditions - already migrated
    --
    for r in c_migrated_condPerson loop
      if r.parameter_one = 'any_approver' then
        lmConditionDesc := 'Any approver is person';
      else --final_approver
        lmConditionDesc := 'The final approver is person';
      end if;
      addApprover(id => r.person_id
                 ,source => 'ame_conditions'
                 ,source_object => 'condition_id : '||r.condition_id
                 ,description   => lmConditionDesc
                 ,approvers     => migratedApprovers);
    end loop;
    --
    --ame_approval_group_items - already migrated
    --
    for r in c_migrated_grpItems loop
      addApprover(id => r.person_id
                 ,source => 'ame_approval_group_items'
                 ,source_object => 'approval_group_id : '||r.approval_group_id
                 ,description => r.name
                 ,approvers => migratedApprovers);
    end loop;
    --
    --ame_approval_group_members - already migrated
    --
    for r in c_migrated_grpMem loop
      addApprover(id => r.person_id
                 ,source => 'ame_approval_group_members'
                 ,source_object => 'approval_group_id : '||r.approval_group_id
                 ,description => r.name
                 ,approvers => migratedApprovers);
    end loop;
    --
    -- ame_actions - Substitution - already migrated
    --
    for r in c_migrated_substituteAction loop
      addApprover(id => r.person_id
                 ,source => 'ame_actions'
                 ,source_object => 'action_id : '||r.action_id
                 ,description => r.description
                 ,approvers => migratedApprovers);
    end loop;
    --
    --ame_temp_deletions - already migrated
    --
    for r in c_migrated_delAppr loop
      addApprover(id => r.person_id
                 ,source => 'ame_temp_deletions'
                 ,source_object => 'n/a'
                 ,description => 'n/a'
                 ,approvers => migratedApprovers);
    end loop;
    --
    -- ame_temp_insertions - already migrated
    --
    for r in c_migrated_insAppr loop
      addApprover(id => r.person_id
                 ,source => 'ame_temp_insertions'
                 ,source_object => 'n/a'
                 ,description => 'n/a'
                 ,approvers => migratedApprovers);
    end loop;
    --
    -- ame_temp_old_approver_lists - to be migrated
    --
    for r in c_migrated_oldAppr loop
      addApprover(id => r.person_id
                 ,source => 'ame_temp_old_approver_lists'
                 ,source_object => 'n/a'
                 ,description => 'n/a'
                 ,approvers => migratedApprovers);
    end loop;
    --
    -- Sort the approver list
    --
    sortApproversTable(migratedApprovers);
  end if;
    --
    -- ******** Invalid Users ********
    --
    --
    --ame_temp_old_approver_lists
    --
    for r in c_oldAppr_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'AME Runtime Table'
                 ,source_object => 'ame_temp_old_approver_lists'
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    --ame_temp_deletions
    --
    for r in c_delAppr_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'AME Runtime Table'
                 ,source_object => 'ame_temp_deletions'
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    --ame_temp_insertions
    --
    for r in c_insAppr_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'AME Runtime Table'
                 ,source_object => 'ame_temp_insertions'
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    --ame_conditions
    --
    for r in c_condUser_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'ame_conditions'
                 ,source_object => 'condition_id:'||r.condition_id
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    --ame_approval_group_items
    --
    for r in c_grpItems_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'ame_approval_group_items'
                 ,source_object => 'group_name:'||r.name
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    --ame_approval_group_members
    --
    for r in c_grpMem_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'ame_approval_group_members'
                 ,source_object => 'group_name:'||r.name
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    --ame_config_vars (adminApprover)
    --
    for r in c_configVar_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'AME Configuration Table'
                 ,source_object => 'ame_config_vars'
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    -- ame_actions (substitution)
    --
    for r in c_substituteAction_InvalidUser loop
      addApprover(id => r.person_id
                 ,user_id => r.user_id
                 ,user_name => r.user_name
                 ,source => 'ame_actions'
                 ,source_object => 'action_id:'||r.action_id
                 ,description => null
                 ,approvers => invalidUsers);
    end loop;
    --
    -- Sort the invalid users
    --
    sortApproversTable(invalidUsers);
    --
    -- Print Report
    --
    printReport;
    --
    retcode := 0;
    errbuf := 'Report is Now Complete.';
  exception
    when others then
      rollback;
      if c_AME_11510_Patch%isOpen then
        close c_AME_11510_Patch;
      end if;
  end generateReport;
end;

/
