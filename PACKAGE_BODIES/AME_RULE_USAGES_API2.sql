--------------------------------------------------------
--  DDL for Package Body AME_RULE_USAGES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULE_USAGES_API2" AS
/* $Header: amersapi.pkb 120.2 2005/10/14 04:13 ubhat noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  X_CREATED_BY := AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER);
  X_LAST_UPDATED_BY := AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER);
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

procedure KEY_TO_IDS (
  X_RULE_KEY                 in  VARCHAR2,
  X_APPLICATION_SHORT_NAME   in  VARCHAR2,
  X_TRANSACTION_TYPE_ID      in  VARCHAR2,
  X_RULE_USAGE               out nocopy VARCHAR2,
  X_RULE_ID                  out nocopy NUMBER,
  X_ITEM_ID                  out nocopy NUMBER
) is
  cursor CSR_GET_ITEM_ID
  (
    X_APPLICATION_SHORT_NAME in VARCHAR2,
    X_TRANSACTION_TYPE_ID    in VARCHAR2
  ) is
   select ACA.APPLICATION_ID
   from   AME_CALLING_APPS ACA,
          FND_APPLICATION_VL FA
   where  FA.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
     and  nvl(ACA.TRANSACTION_TYPE_ID,'NULL') = nvl(X_TRANSACTION_TYPE_ID,'NULL')
     and  FA.APPLICATION_ID = ACA.FND_APPLICATION_ID
     and sysdate between ACA.START_DATE
       and nvl(ACA.END_DATE - (1/86400), sysdate);

  cursor CSR_GET_RULE_ID
  (
   X_RULE_KEY      in VARCHAR2
  ) is
  select RULE_ID
    from AME_RULES
   where RULE_KEY = X_RULE_KEY;

  cursor CSR_GET_RULE_USAGE
  (
   X_ITEM_ID       in NUMBER,
   X_RULE_ID       in NUMBER
  ) is
  select 'FOUND'
    from AME_RULE_USAGES
   where RULE_ID  = X_RULE_ID
     and ITEM_ID  = X_ITEM_ID;

begin
  open CSR_GET_ITEM_ID (
    X_APPLICATION_SHORT_NAME,
    X_TRANSACTION_TYPE_ID
  );
  fetch CSR_GET_ITEM_ID into X_ITEM_ID;
    if (CSR_GET_ITEM_ID%notfound) then
      X_ITEM_ID := null;
    end if;
  close CSR_GET_ITEM_ID;

  open CSR_GET_RULE_ID (
    X_RULE_KEY
  );
  fetch CSR_GET_RULE_ID into X_RULE_ID;
    if (CSR_GET_RULE_ID%notfound) then
      X_RULE_ID := null;
    end if;
  close CSR_GET_RULE_ID;

  if (X_ITEM_ID is not null) and (X_RULE_ID is not null) then
    open CSR_GET_RULE_USAGE (
      X_ITEM_ID, X_RULE_ID
    );
    fetch CSR_GET_RULE_USAGE into X_RULE_USAGE;
    if (CSR_GET_RULE_USAGE%notfound) then
      X_RULE_USAGE := 'NOTFOUND';
    end if;
    close CSR_GET_RULE_USAGE;
  end if;

end KEY_TO_IDS;

procedure KEY_TO_IDS_2 (
  X_RULE_ID                  in  NUMBER,
  X_APPLICATION_SHORT_NAME   in  VARCHAR2,
  X_TRANSACTION_TYPE_ID      in  VARCHAR2,
  X_ITEM_ID                  out nocopy NUMBER,
  X_RULE_USAGE_COUNT         out nocopy NUMBER
) is
  cursor CSR_GET_ITEM_ID
  (
    X_APPLICATION_SHORT_NAME in VARCHAR2,
    X_TRANSACTION_TYPE_ID    in VARCHAR2
  ) is
   select ACA.APPLICATION_ID
   from   AME_CALLING_APPS ACA,
          FND_APPLICATION_VL FA
   where  FA.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
     and  nvl(ACA.TRANSACTION_TYPE_ID,'NULL') = nvl(X_TRANSACTION_TYPE_ID,'NULL')
     and  FA.APPLICATION_ID = ACA.FND_APPLICATION_ID
     and ((ACA.START_DATE - (1/86400)) <= sysdate)
     and (((ACA.END_DATE  - (1/86400)) >= sysdate)
      or (ACA.END_DATE is null));

  cursor CSR_GET_RULE_USAGE_COUNT
  (
   X_ITEM_ID       in NUMBER,
   X_RULE_ID       in NUMBER
  ) is
  select COUNT(*)
    from AME_RULE_USAGES
   where RULE_ID = X_RULE_ID
     and ITEM_ID = X_ITEM_ID;

begin
  open CSR_GET_ITEM_ID (
    X_APPLICATION_SHORT_NAME,
    X_TRANSACTION_TYPE_ID
  );
  fetch CSR_GET_ITEM_ID into X_ITEM_ID;
    if (CSR_GET_ITEM_ID%notfound) then
      X_ITEM_ID := null;
    end if;
  close CSR_GET_ITEM_ID;

  if X_ITEM_ID is not null then
    open CSR_GET_RULE_USAGE_COUNT (
      X_ITEM_ID, X_RULE_ID
    );
    fetch CSR_GET_RULE_USAGE_COUNT into X_RULE_USAGE_COUNT;
    close CSR_GET_RULE_USAGE_COUNT;
  end if;

end KEY_TO_IDS_2;

function CALCULATE_USE_COUNT(X_ATTRIBUTE_ID ame_attribute_usages.attribute_id%type,
                           X_APPLICATION_ID ame_attribute_usages.application_id%type) return integer as
  cursor RULE_CURSOR(X_APPLICATION_ID  in integer) is
  select  AME_RULE_USAGES.RULE_ID, AME_RULES.ACTION_ID
    from AME_RULES, AME_RULE_USAGES
   where AME_RULES.RULE_ID =  AME_RULE_USAGES.RULE_ID
     and AME_RULE_USAGES.ITEM_ID = X_APPLICATION_ID
     and ((sysdate between AME_RULES.START_DATE
            and nvl(AME_RULES.END_DATE - (1/86400), sysdate))
      or (sysdate < AME_RULES.START_DATE
            and AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,
                          AME_RULES.START_DATE + (1/86400))))
     and ((sysdate between AME_RULE_USAGES.START_DATE
     and nvl(AME_RULE_USAGES.END_DATE - (1/86400), sysdate))
      or (sysdate < AME_RULE_USAGES.START_DATE
     and AME_RULE_USAGES.START_DATE < nvl(AME_RULE_USAGES.END_DATE,
                          AME_RULE_USAGES.START_DATE + (1/86400))));
    RULE_COUNT integer;
    TEMP_COUNT integer;
    NEW_USE_COUNT integer;
  begin
   NEW_USE_COUNT := 0;
   for TEMPRULE in RULE_CURSOR(X_APPLICATION_ID => X_APPLICATION_ID) loop
     select count(*)
     into TEMP_COUNT
     from AME_CONDITIONS,
          AME_CONDITION_USAGES
     where
      AME_CONDITIONS.ATTRIBUTE_ID = X_ATTRIBUTE_ID and
      AME_CONDITIONS.CONDITION_ID = AME_CONDITION_USAGES.CONDITION_ID and
      AME_CONDITION_USAGES.RULE_ID = TEMPRULE.RULE_ID and
      sysdate between AME_CONDITIONS.START_DATE and
                nvl(AME_CONDITIONS.END_DATE - (1/86400), sysdate) and
      ((sysdate between AME_CONDITION_USAGES.START_DATE and
            nvl(AME_CONDITION_USAGES.END_DATE - (1/86400), sysdate)) or
       (sysdate < AME_CONDITION_USAGES.START_DATE and
        AME_CONDITION_USAGES.START_DATE < nvl(AME_CONDITION_USAGES.END_DATE,
                           AME_CONDITION_USAGES.START_DATE + (1/86400))));
    if(TEMP_COUNT > 0) then
       NEW_USE_COUNT := NEW_USE_COUNT + 1;
    else
       if(TEMPRULE.ACTION_ID is null) then
         -- action_id is already migrated from ame_rules to ame_action_usages
         select count(*)
         into TEMP_COUNT
         from
           AME_MANDATORY_ATTRIBUTES,
           AME_ACTIONS,
           AME_ACTION_USAGES
         where
          AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID = X_ATTRIBUTE_ID and
          AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
          AME_ACTIONS.ACTION_ID = AME_ACTION_USAGES.ACTION_ID and
          AME_ACTION_USAGES.RULE_ID = TEMPRULE.RULE_ID and
          sysdate between AME_MANDATORY_ATTRIBUTES.START_DATE and
                    nvl(AME_MANDATORY_ATTRIBUTES.END_DATE - (1/86400), sysdate) and
          sysdate between AME_ACTIONS.START_DATE and
                    nvl(AME_ACTIONS.END_DATE - (1/86400), sysdate) and
          ((sysdate between AME_ACTION_USAGES.START_DATE and
                     nvl(AME_ACTION_USAGES.END_DATE - (1/86400), sysdate)) or
           (sysdate < AME_ACTION_USAGES.START_DATE and
            AME_ACTION_USAGES.START_DATE < nvl(AME_ACTION_USAGES.END_DATE,
                               AME_ACTION_USAGES.START_DATE + (1/86400))));
       else
         select count(*)
         into TEMP_COUNT
         from
           AME_MANDATORY_ATTRIBUTES,
           AME_ACTIONS,
           AME_RULES
         where
          AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID = X_ATTRIBUTE_ID and
          AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
          AME_ACTIONS.ACTION_ID = AME_RULES.ACTION_ID and
          AME_RULES.RULE_ID = TEMPRULE.RULE_ID and
          sysdate between AME_MANDATORY_ATTRIBUTES.START_DATE and
                    nvl(AME_MANDATORY_ATTRIBUTES.END_DATE - (1/86400), sysdate) and
          sysdate between AME_ACTIONS.START_DATE and
                    nvl(AME_ACTIONS.END_DATE - (1/86400), sysdate) and
          ((sysdate between AME_RULES.START_DATE and
                     nvl(AME_RULES.END_DATE - (1/86400), sysdate)) or
           (sysdate < AME_RULES.START_DATE and
            AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,
                               AME_RULES.START_DATE + (1/86400))));
       end if;
       if(TEMP_COUNT > 0) then
          NEW_USE_COUNT := NEW_USE_COUNT + 1;
       end if;
     end if;
   end loop;
   return(NEW_USE_COUNT);
  exception
    when others then
      ame_util.runtimeException('ame_attribute_usages_api2',
                                'calculate_use_count',
                                sqlcode,
                                sqlerrm);
     raise;
     return(null);
end CALCULATE_USE_COUNT;

procedure CHANGE_ATTRIBUTE_USAGES_COUNT(X_RULE_ID ame_rule_usages.rule_id%type,
                                        X_APPLICATION_ID ame_rule_usages.item_id%type) is
  cursor GET_USED_ATTRIBUTES (X_RULE_ID ame_rule_usages.rule_id%type) is
    select AME_CONDITIONS.ATTRIBUTE_ID
    from  AME_CONDITIONS,
      AME_CONDITION_USAGES
    where
      AME_CONDITIONS.CONDITION_TYPE in (AME_UTIL.ORDINARYCONDITIONTYPE,
                                        AME_UTIL.EXCEPTIONCONDITIONTYPE) and
      AME_CONDITION_USAGES.RULE_ID = X_RULE_ID and
      AME_CONDITION_USAGES.CONDITION_ID = AME_CONDITIONS.CONDITION_ID and
      (AME_CONDITIONS.START_DATE <= sysdate and
        (AME_CONDITIONS.END_DATE is null or sysdate < AME_CONDITIONS.END_DATE)) and
      ((sysdate between AME_CONDITION_USAGES.START_DATE and
           nvl(AME_CONDITION_USAGES.END_DATE - (1/86400), sysdate)) or
       (sysdate < AME_CONDITION_USAGES.START_DATE and
        AME_CONDITION_USAGES.START_DATE < nvl(AME_CONDITION_USAGES.END_DATE,
                         AME_CONDITION_USAGES.START_DATE + (1/86400))))
      union
      select AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID
      from AME_MANDATORY_ATTRIBUTES,
       AME_ACTION_USAGES,
       AME_ACTIONS
      where
       AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
       AME_ACTIONS.ACTION_ID = AME_ACTION_USAGES.ACTION_ID and
       AME_ACTION_USAGES.RULE_ID = X_RULE_ID and
       (AME_MANDATORY_ATTRIBUTES.START_DATE <= sysdate and
       (AME_MANDATORY_ATTRIBUTES.END_DATE is null or sysdate < AME_MANDATORY_ATTRIBUTES.END_DATE)) and
       ((sysdate between AME_ACTION_USAGES.START_DATE and
           nvl(AME_ACTION_USAGES.END_DATE - (1/86400), sysdate)) or
        (sysdate < AME_ACTION_USAGES.START_DATE and
         AME_ACTION_USAGES.START_DATE < nvl(AME_ACTION_USAGES.END_DATE,AME_ACTION_USAGES.START_DATE
                                                 + (1/86400)))) and
        (AME_ACTIONS.START_DATE <= sysdate and
        (AME_ACTIONS.END_DATE is null or sysdate < AME_ACTIONS.END_DATE))
      union
      select AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID
      from AME_MANDATORY_ATTRIBUTES,
       AME_RULES,
       AME_ACTIONS
      where
       AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID = AME_ACTIONS.ACTION_TYPE_ID and
       AME_ACTIONS.ACTION_ID = AME_RULES.ACTION_ID and
       AME_RULES.ACTION_ID is not null and
       AME_RULES.RULE_ID = X_RULE_ID and
       (AME_MANDATORY_ATTRIBUTES.START_DATE <= sysdate and
       (AME_MANDATORY_ATTRIBUTES.END_DATE is null or sysdate < AME_MANDATORY_ATTRIBUTES.END_DATE)) and
       ((sysdate between AME_RULES.START_DATE and
           nvl(AME_RULES.END_DATE - (1/86400), sysdate)) or
        (sysdate < AME_RULES.START_DATE and
         AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,AME_RULES.START_DATE
                                                 + (1/86400)))) and
        (AME_ACTIONS.START_DATE <= sysdate and
        (AME_ACTIONS.END_DATE is null or sysdate < AME_ACTIONS.END_DATE));
  ATTRIBUTE_IDS_LIST ame_util.idList;
  X_USE_COUNT ame_attribute_usages.use_count%type;
begin
  for ATTRIBUTE_REC in GET_USED_ATTRIBUTES(X_RULE_ID => X_RULE_ID) loop
    -- calculate use count
    X_USE_COUNT := CALCULATE_USE_COUNT(ATTRIBUTE_REC.ATTRIBUTE_ID, X_APPLICATION_ID);
    -- update ame_attribute_usages
    update AME_ATTRIBUTE_USAGES
    set  USE_COUNT = X_USE_COUNT
    where
     ATTRIBUTE_ID = ATTRIBUTE_REC.ATTRIBUTE_ID and
     APPLICATION_ID = X_APPLICATION_ID and
     sysdate between START_DATE and
               nvl(END_DATE - (1/86400), sysdate);
  end loop;
end CHANGE_ATTRIBUTE_USAGES_COUNT;

  procedure create_parallel_config
    (x_rule_id in integer
    ,x_application_id in integer
    ) as
    cursor rule_action_cursor is
      select aa.action_id,
             aa.action_type_id,
             aat.name,
             aa.parameter
        from ame_rule_usages aru,
             ame_action_usages aau,
             ame_actions aa,
             ame_action_types aat
       where aru.rule_id = x_rule_id
         and aru.item_id = x_application_id
         and sysdate between aat.start_date and nvl(aat.end_date,sysdate)
         and sysdate between aa.start_date and nvl(aa.end_date,sysdate)
         and (sysdate between aru.start_date and nvl(aru.end_date,sysdate) or
              aru.start_date > sysdate and nvl(aru.end_date,aru.start_date + (1/86400)) < aru.start_date)
         and (sysdate between aau.start_date and nvl(aau.end_date,sysdate) or
              aau.start_date > sysdate and nvl(aau.end_date,aau.start_date + (1/86400)) < aau.start_date)
         and aru.rule_id = aau.rule_id
         and aau.action_id = aa.action_id
         and aa.action_type_id = aat.action_type_id;
    cursor group_action_type_cursor(c_action_type_id integer) is
      select null
        from ame_action_types
       where sysdate between start_date and nvl(end_date,sysdate)
         and action_type_id = c_action_type_id
         and name in ('pre-chain-of-authority approvals'
                     ,'post-chain-of-authority approvals'
                     ,'approval-group chain of authority');
    x_action_type_id integer;
    x_action_id integer;
    x_action_type_name varchar2(100);
    x_group_based_action varchar2 (10);
    x_parameter varchar2(320);
    x_approval_group_id integer;
    x_dummy varchar2(10);
  begin
    AME_SEED_UTILITY.INIT_AME_INSTALLATION_LEVEL;
    if AME_SEED_UTILITY.AME_INSTALLATION_LEVEL is null or to_number(AME_SEED_UTILITY.AME_INSTALLATION_LEVEL)  < 2 then
      return;
    end if;
    open rule_action_cursor;
    loop
      fetch rule_action_cursor
       into x_action_id,
            x_action_type_id,
            x_action_type_name,
            x_parameter;
      exit when rule_action_cursor%notfound;

      open group_action_type_cursor(x_action_type_id);
      fetch group_action_type_cursor into x_dummy;
      if group_action_type_cursor%found then
        x_group_based_action := 'Y';
        x_approval_group_id := to_number(x_parameter);
      else
        x_group_based_action := 'N';
        x_approval_group_id := null;
      end if;
      close group_action_type_cursor;

      ame_seed_utility.create_parallel_config
        (x_action_type_id
        ,x_action_type_name
        ,x_action_id
        ,x_approval_group_id
        );
    end loop;
    close rule_action_cursor;
  end create_parallel_config;

procedure INSERT_ROW (
 X_ITEM_ID                         in NUMBER,
 X_RULE_ID                         in NUMBER,
 X_APPROVER_CATEGORY               in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
 is
begin

  insert into AME_RULE_USAGES
  (
   ITEM_ID,
   RULE_ID,
   APPROVER_CATEGORY,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER
  ) values (
   X_ITEM_ID,
   X_RULE_ID,
   X_APPROVER_CATEGORY,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER);
   CHANGE_ATTRIBUTE_USAGES_COUNT(X_RULE_ID => X_RULE_ID,
                                 X_APPLICATION_ID => X_ITEM_ID);
end INSERT_ROW;

procedure DELETE_ROW (
  X_ITEM_ID in NUMBER,
  X_RULE_ID in NUMBER
) is
begin
  delete from AME_RULE_USAGES
  where ITEM_ID = X_ITEM_ID
    and RULE_ID = X_RULE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
          X_RULE_KEY               in VARCHAR2,
          X_RULE_ID                in VARCHAR2,
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TRANSACTION_TYPE_ID    in VARCHAR2,
          X_APPROVER_CATEGORY      in VARCHAR2,
          X_OWNER                  in VARCHAR2,
          X_LAST_UPDATE_DATE       in VARCHAR2,
          X_CUSTOM_MODE            in VARCHAR2
)
is
  X_ITEM_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER VARCHAR2(100);
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_RULE_ID_LOAD NUMBER;
  X_RULE_USAGE VARCHAR2(20);
  X_RULE_USAGE_COUNT NUMBER :=0;
begin
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
if X_RULE_ID > 0 then
-- drive off RULE_KEY
  X_RULE_ID_LOAD := null;
  KEY_TO_IDS (
    X_RULE_KEY,
    X_APPLICATION_SHORT_NAME,
    X_TRANSACTION_TYPE_ID,
    X_RULE_USAGE,
    X_RULE_ID_LOAD,
    X_ITEM_ID
  );
-- the current row was not found insert a new row
   if (X_RULE_USAGE = 'NOTFOUND') then
     INSERT_ROW (
       X_ITEM_ID,
       X_RULE_ID_LOAD,
       X_APPROVER_CATEGORY,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       1);
     create_parallel_config
       (x_rule_id => x_rule_id_load
       ,x_application_id => x_item_id);
   end if;
-- the current row was found end date the current row
-- do not update or insert
else
-- drive off RULE_ID
  KEY_TO_IDS_2 (
    X_RULE_ID,
    X_APPLICATION_SHORT_NAME,
    X_TRANSACTION_TYPE_ID,
    X_ITEM_ID,
    X_RULE_USAGE_COUNT
  );
-- the current row was not found insert a new row
   if    (X_RULE_USAGE_COUNT = 0)
     and (X_ITEM_ID is not null) then
     INSERT_ROW (
       X_ITEM_ID,
       X_RULE_ID,
       X_APPROVER_CATEGORY,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       1);
     create_parallel_config
       (x_rule_id => x_rule_id
       ,x_application_id => x_item_id);
   end if;
end if;
exception
    when others then
    ame_util.runtimeException('ame_rules_usages_api2',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;
--
END AME_RULE_USAGES_API2;

/
