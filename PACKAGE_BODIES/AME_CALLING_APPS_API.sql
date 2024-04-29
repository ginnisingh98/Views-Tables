--------------------------------------------------------
--  DDL for Package Body AME_CALLING_APPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CALLING_APPS_API" AS
/* $Header: amecaapi.pkb 120.6 2006/08/09 06:53:23 pvelugul noship $ */
X_AME_INSTALLATION_LEVEL varchar2(255);
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
  X_APPLICATION_SHORT_NAME   in           VARCHAR2,
  X_TRANSACTION_TYPE_ID      in           VARCHAR2,
  X_CALLING_APPS_ROWID       out nocopy   VARCHAR2,
  X_FND_APPLICATION_ID       out nocopy   NUMBER,
  X_APPLICATION_ID           out nocopy   NUMBER,
  X_CURRENT_OWNER            out nocopy   NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy   VARCHAR2,
  X_USAGE_ROWID              out nocopy   VARCHAR2,
  X_CURRENT_USAGE_OWNER      out nocopy   NUMBER,
  X_CURRENT_USAGE_LUD        out nocopy   VARCHAR2,
  X_CURRENT_ITEM_ID_QUERY    out nocopy   VARCHAR2,
  X_CURRENT_APP_OVN          out nocopy   VARCHAR2,
  X_CURRENT_USAGE_OVN        out nocopy   VARCHAR2
) is

  cursor CSR_GET_FND_APPLICATION_ID is
  select APPLICATION_ID
    from FND_APPLICATION_VL
   where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  cursor CSR_GET_CURRENT_CALLING_APP
   (
   X_FND_APPLICATION_ID in NUMBER,
   X_TRANSACTION_TYPE_ID in VARCHAR2
   )
   is select ROWID, nvl(OBJECT_VERSION_NUMBER,1),APPLICATION_ID,
         LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')
    from AME_CALLING_APPS
   where FND_APPLICATION_ID = X_FND_APPLICATION_ID
     and nvl(TRANSACTION_TYPE_ID,'NULL')
       = nvl(X_TRANSACTION_TYPE_ID,'NULL')
     and sysdate between START_DATE
     and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_CURRENT_USAGE
   (
   X_APPLICATION_ID in NUMBER
   ) is
   select ROWID,
         nvl(OBJECT_VERSION_NUMBER,1),
         LAST_UPDATED_BY,
         to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         ITEM_ID_QUERY
   from AME_ITEM_CLASS_USAGES
   where APPLICATION_ID = X_APPLICATION_ID
     and ITEM_CLASS_ID  = 2
     and sysdate between START_DATE
     and nvl(END_DATE  - (1/86400), sysdate);
  applicationId number;
begin
  X_CURRENT_APP_OVN := 1;
  X_CURRENT_USAGE_OVN := 1;
  open  CSR_GET_FND_APPLICATION_ID;
  fetch CSR_GET_FND_APPLICATION_ID into X_FND_APPLICATION_ID;
  if (CSR_GET_FND_APPLICATION_ID%notfound) then
     X_FND_APPLICATION_ID := null;
  end if;
  close CSR_GET_FND_APPLICATION_ID;
--
-- this sets the x_application_id if there
-- dependant on the x_transaction_type_id value passed in
--
  if X_TRANSACTION_TYPE_ID is null then
    X_APPLICATION_ID := X_FND_APPLICATION_ID;
  else
    X_APPLICATION_ID := null;
  end if;
--
-- if there is a current row as well as retrieving the rowid
-- assign the x_application_id as well.
--
  if X_FND_APPLICATION_ID is not null then
     -- check for current calling applications row
    open CSR_GET_CURRENT_CALLING_APP
    (
      X_FND_APPLICATION_ID,
      X_TRANSACTION_TYPE_ID
    );
    fetch CSR_GET_CURRENT_CALLING_APP into X_CALLING_APPS_ROWID,
                                           X_CURRENT_APP_OVN,
                                           applicationId,
                                           X_CURRENT_OWNER,
                                           X_CURRENT_LAST_UPDATE_DATE;
    X_APPLICATION_ID := applicationId;
    if (CSR_GET_CURRENT_CALLING_APP%notfound) then
       X_CALLING_APPS_ROWID:= null;
    end if;
    close CSR_GET_CURRENT_CALLING_APP;
    --
    -- get current item class usage from ame_item_class_usages, if AME11510
    -- patch is already applied
    --
    if(X_AME_INSTALLATION_LEVEL is not null and applicationId is not null) then
      open CSR_GET_CURRENT_USAGE(applicationId);
      fetch CSR_GET_CURRENT_USAGE into X_USAGE_ROWID,
                                       X_CURRENT_USAGE_OVN,
                                       X_CURRENT_USAGE_OWNER,
                                       X_CURRENT_USAGE_LUD,
                                       X_CURRENT_ITEM_ID_QUERY;
      if CSR_GET_CURRENT_USAGE%notfound then
        X_USAGE_ROWID := null;
      end if;
      close CSR_GET_CURRENT_USAGE;
    end if;
  end if;
end KEY_TO_IDS;
function DO_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2 default null)
return boolean as
begin
  return AME_SEED_UTILITY.MERGE_ROW_TEST
    (X_OWNER                     => X_OWNER
    ,X_CURRENT_OWNER             => X_CURRENT_OWNER
    ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
    ,X_CUSTOM_MODE               => X_CUSTOM_MODE
    );
end DO_UPDATE_INSERT;
function DO_TL_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CREATED_BY in varchar2,
                   X_CUSTOM_MODE in VARCHAR2 default null)
return boolean as
begin
  if X_CUSTOM_MODE = 'FORCE' then
    return true;
  end if;
  if AME_SEED_UTILITY.IS_SEED_USER(X_CREATED_BY) then
    return true;
  else
    return AME_SEED_UTILITY.TL_MERGE_ROW_TEST
      (X_OWNER                     => X_OWNER
      ,X_CURRENT_OWNER             => X_CURRENT_OWNER
      ,X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
      ,X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE
      ,X_CUSTOM_MODE               => X_CUSTOM_MODE
      );
  end if;
  return(false);
end DO_TL_UPDATE_INSERT;
procedure INSERT_ROW (
 X_FND_APPLICATION_ID                in NUMBER,
 X_APPLICATION_NAME                  in VARCHAR2,
 X_TRANSACTION_TYPE_ID               in VARCHAR2,
 X_APPLICATION_ID                    in NUMBER,
 X_CREATED_BY                        in NUMBER,
 X_CREATION_DATE                     in DATE,
 X_LAST_UPDATED_BY                   in NUMBER,
 X_LAST_UPDATE_DATE                  in DATE,
 X_LAST_UPDATE_LOGIN                 in NUMBER,
 X_START_DATE                        in DATE,
 X_LINE_ITEM_ID_QUERY                in VARCHAR2,
 X_OBJECT_VERSION_NUMBER             in NUMBER
 )
 is
 begin

  insert into AME_CALLING_APPS
  (
   FND_APPLICATION_ID,
   APPLICATION_NAME,
   TRANSACTION_TYPE_ID,
   APPLICATION_ID,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   LINE_ITEM_ID_QUERY,
   OBJECT_VERSION_NUMBER
  )  select
   X_FND_APPLICATION_ID,
   X_APPLICATION_NAME,
   X_TRANSACTION_TYPE_ID,
   X_APPLICATION_ID,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_LINE_ITEM_ID_QUERY,
   X_OBJECT_VERSION_NUMBER
   from sys.dual;
end INSERT_ROW;
--
procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_APPLICATION_NAME           in VARCHAR2,
  X_APPLICATION_ID             in NUMBER,
  X_LINE_ITEM_ID_QUERY         in VARCHAR2,
  X_CREATED_BY                 in NUMBER,
  X_CREATION_DATE              in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATE_LOGIN          in NUMBER,
  X_START_DATE                 in DATE,
  X_END_DATE                   in DATE,
  X_OBJECT_VERSION_NUMBER      in NUMBER
) is
begin
  update AME_CALLING_APPS
     set APPLICATION_NAME = X_APPLICATION_NAME,
         APPLICATION_ID = X_APPLICATION_ID,
         LINE_ITEM_ID_QUERY = X_LINE_ITEM_ID_QUERY,
         CREATED_BY = X_CREATED_BY,
         CREATION_DATE = X_CREATION_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
         START_DATE = X_START_DATE,
         END_DATE = X_END_DATE,
         OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
   where ROWID = X_ROWID;
end FORCE_UPDATE_ROW;

procedure INSERT_USAGE_ROW (
 X_APPLICATION_ID              in NUMBER,
 X_ITEM_CLASS_ID                   in NUMBER,
 X_ITEM_ID_QUERY                   in VARCHAR2,
 X_ITEM_CLASS_ORDER_NUMBER         in NUMBER,
 X_ITEM_CLASS_PAR_MODE             in VARCHAR2,
 X_ITEM_CLASS_SUBLIST_MODE         in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER
 )
 is
begin
  --do not populate usage row if AME11510 full patch has not been applied
  if X_AME_INSTALLATION_LEVEL IS NULL then
    return;
  end if;
  insert into AME_ITEM_CLASS_USAGES
  (
   APPLICATION_ID,
   ITEM_CLASS_ID,
   ITEM_ID_QUERY,
   ITEM_CLASS_ORDER_NUMBER,
   ITEM_CLASS_PAR_MODE,
   ITEM_CLASS_SUBLIST_MODE,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   OBJECT_VERSION_NUMBER
  ) values (
   X_APPLICATION_ID,
   X_ITEM_CLASS_ID,
   X_ITEM_ID_QUERY,
   X_ITEM_CLASS_ORDER_NUMBER,
   X_ITEM_CLASS_PAR_MODE,
   X_ITEM_CLASS_SUBLIST_MODE,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_OBJECT_VERSION_NUMBER);
end INSERT_USAGE_ROW;

procedure FORCE_UPDATE_USAGE_ROW (
  X_ROWID                      in VARCHAR2,
  X_ITEM_ID_QUERY              in VARCHAR2,
  X_ITEM_CLASS_ORDER_NUMBER    in NUMBER,
  X_ITEM_CLASS_PAR_MODE        in VARCHAR2,
  X_ITEM_CLASS_SUBLIST_MODE    in VARCHAR2,
  X_CREATED_BY                 in NUMBER,
  X_CREATION_DATE              in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATE_LOGIN          in NUMBER,
  X_START_DATE                 in DATE,
  X_END_DATE                   in DATE,
  X_OBJECT_VERSION_NUMBER      in NUMBER
) is
begin
  update AME_ITEM_CLASS_USAGES
     set ITEM_ID_QUERY = X_ITEM_ID_QUERY,
         ITEM_CLASS_ORDER_NUMBER = X_ITEM_CLASS_ORDER_NUMBER,
         ITEM_CLASS_PAR_MODE = X_ITEM_CLASS_PAR_MODE,
         ITEM_CLASS_SUBLIST_MODE = X_ITEM_CLASS_SUBLIST_MODE,
         CREATED_BY = X_CREATED_BY,
         CREATION_DATE = X_CREATION_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
         START_DATE = X_START_DATE,
         END_DATE = X_END_DATE,
         OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
   where ROWID = X_ROWID;
end FORCE_UPDATE_USAGE_ROW;

procedure INSERT_TL_ROW (
  X_APPLICATION_ID in NUMBER,
  X_APPLICATION_NAME in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER) is
 begin
  if not AME_SEED_UTILITY.MLS_ENABLED then
    return;
  end if;

  insert into AME_CALLING_APPS_TL
    (APPLICATION_ID
    ,APPLICATION_NAME
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,LANGUAGE
    ,SOURCE_LANG
    ) select X_APPLICATION_ID,
             X_APPLICATION_NAME,
             X_CREATED_BY,
             X_CREATION_DATE,
             X_LAST_UPDATED_BY,
             X_LAST_UPDATE_DATE,
             X_LAST_UPDATE_LOGIN,
             L.LANGUAGE_CODE,
             userenv('LANG')
        from FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
         and not exists (select null
                           from AME_CALLING_APPS_TL T
                          where T.APPLICATION_ID = X_APPLICATION_ID
                            and T.LANGUAGE = L.LANGUAGE_CODE);
  END insert_tl_row;

procedure UPDATE_TL_ROW (
  X_APPLICATION_ID in NUMBER,
  X_APPLICATION_NAME in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CUSTOM_MODE in VARCHAR2) is
  X_CURRENT_OWNER  NUMBER;
  X_CURRENT_LAST_UPDATE_DATE DATE;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;

    select LAST_UPDATED_BY,
           LAST_UPDATE_DATE
       into X_CURRENT_OWNER,
            X_CURRENT_LAST_UPDATE_DATE
       FROM AME_CALLING_APPS_TL
       WHERE APPLICATION_ID = X_APPLICATION_ID
       AND LANGUAGE = USERENV('LANG');

   if DO_UPDATE_INSERT
     (X_LAST_UPDATED_BY
     ,X_CURRENT_OWNER
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_LAST_UPDATE_DATE)
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_CURRENT_LAST_UPDATE_DATE)
     ,X_CUSTOM_MODE) then
      update AME_CALLING_APPS_TL
         set APPLICATION_NAME = nvl(X_APPLICATION_NAME,APPLICATION_NAME),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where APPLICATION_ID = X_APPLICATION_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
   end if;
exception
  when no_data_found then
    null;
end UPDATE_TL_ROW;

procedure UPDATE_ROW (
 X_CALLING_APPS_ROWID                in VARCHAR2,
 X_END_DATE                          in DATE)
 is
begin
  update AME_CALLING_APPS set
   END_DATE            = X_END_DATE
  where ROWID          = X_CALLING_APPS_ROWID;
end UPDATE_ROW;

procedure UPDATE_USAGE_ROW (
         X_USAGE_ROWID        in VARCHAR2,
         X_END_DATE           in DATE) is
begin
--do not populate usage row if AME11510 full patch has not been applied
  if X_AME_INSTALLATION_LEVEL IS NULL then
    return;
  end if;
  update AME_ITEM_CLASS_USAGES
  set END_DATE  = X_END_DATE
  where ROWID   = X_USAGE_ROWID;
end UPDATE_USAGE_ROW;

procedure DELETE_ROW (
  X_FND_APPLICATION_ID   in NUMBER,
  X_TRANSACTION_TYPE_ID  in VARCHAR2,
  X_APPLICATION_ID       in NUMBER
) is
begin
  if AME_SEED_UTILITY.MLS_ENABLED then
    delete from AME_CALLING_APPS_TL
    where APPLICATION_ID in (select APPLICATION_ID
                               from AME_CALLING_APPS
                              where FND_APPLICATION_ID = X_FND_APPLICATION_ID
                                and nvl(TRANSACTION_TYPE_ID,'NULL') = nvl(X_TRANSACTION_TYPE_ID,'NULL'));
  end if;
  delete from AME_CALLING_APPS
  where FND_APPLICATION_ID = X_FND_APPLICATION_ID
    and nvl(TRANSACTION_TYPE_ID,'NULL') = nvl(X_TRANSACTION_TYPE_ID,'NULL');
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--
-- this piece of code runs when an AME seed data patch based upon the
-- older style of ldts is run.
-- this logic is also represented in amem0031.sql and amem0032.sql.
-- it runs within this api when a transaction type is being applied
-- after the AME mother patch has been run.
-- it inserts rows into the ame_action_type_config
-- and ame_approval_group_config tables and
-- attribute usages for USE_WORKFLOW, REJECTION_RESPONSE and
-- REPEAT_SUBSTITUTION attributes where they do not exist.
--
procedure RUN_CONFIG_USAGES_ROWS(X_APPLICATION_ID in NUMBER,
                                 X_LAST_UPDATE_DATE in VARCHAR2,
                                 X_CREATED_BY in NUMBER
)
is
  cursor getApprovalGroup is
  select aag.approval_group_id, aag.name, aag.start_date, aag.end_date
  from   ame_approval_groups aag
  where  aag.start_date =
    (select max(start_date)
       from ame_approval_groups aag2
      where aag.approval_group_id = aag2.approval_group_id)
  order by aag.approval_group_id;
  cursor getActionType is
  select aat.action_type_id,
         aat.name,
         aat.created_by,
         aat.last_updated_by,
         aat.start_date,
         aat.end_date
  from   ame_action_types aat
  where  aat.start_date =
    (select max(start_date)
       from ame_action_types aat2
      where aat.action_type_id = aat2.action_type_id)
  and ((end_date is null)
     or (aat.start_date <> aat.end_date))
    order by aat.action_type_id;
 -- REJECTION_RESPONSE
 cursor getRejectionAttributeId is
  select attribute_id
    from ame_attributes
   where name = ame_util.rejectionResponseAttribute
     and (sysdate between start_date
     and nvl(end_date - (1/86400),sysdate));
 -- USE_WORKFLOW
 cursor getUseWorkflowId is
  select attribute_id
    from ame_attributes
   where name = ame_util.useWorkflowAttribute
     and (sysdate between start_date
     and nvl(end_date - (1/86400),sysdate));
 --REPEAT_SUBSTITUTIONS
 cursor getRepeatSubAttributeId is
  select attribute_id
    from ame_attributes
   where name = 'REPEAT_SUBSTITUTIONS'
     and (sysdate between start_date
     and nvl(end_date - (1/86400),sysdate));
authorityRuleTypeCount      integer     :=0;
customOrderNumber           integer     :=20;
votingRegimeValue           varchar2(1) := null;
-- variable to hold approval group order number
groupOrderNumber            integer     :=0;
X_REJECTION_RESPONSE_ID     number;
X_REPEAT_SUBSTITUTIONS_ID   number;
X_USE_WORKFLOW_ID           number;
begin
  -- if AME11510 full patch is not applied then return
  if X_AME_INSTALLATION_LEVEL is null then
    return;
  end if;
  if X_AME_INSTALLATION_LEVEL is not null and to_number(X_AME_INSTALLATION_LEVEL) < 2 then
    for groupsRec in getApprovalGroup loop
      groupOrderNumber := groupOrderNumber + 1;
        insert into ame_approval_group_config
         (application_id,
          approval_group_id,
          voting_regime,
          order_number,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          start_date,
          end_date,
          object_version_number)
          select X_APPLICATION_ID,
          groupsRec.approval_group_id,
          ame_util.orderNumberVoting,
          groupOrderNumber,
          x_created_by,
          sysdate,
          x_created_by,
          sysdate,
          null,
          groupsRec.start_date,
          groupsRec.end_date,
          1
        from sys.dual
        where not exists
         (select null
            from ame_approval_group_config
           where application_id = X_APPLICATION_ID
             and approval_group_id = groupsRec.approval_group_id
             and ((sysdate between start_date
                   and nvl(end_date - (1/86400),sysdate))
                    or (groupsRec.start_date between start_date
                        and nvl(end_date,start_date))));
    end loop;
    for actionRec in getActionType loop
      -- determine the value for the voting regime column
      select count(*)
      into   authorityRuleTypeCount
      from   ame_action_type_usages
      where  action_type_id = actionRec.action_type_id
      and    rule_type      = ame_util.authorityRuleType;
      if authorityRuleTypeCount > 0 then
        votingRegimeValue := ame_util.serializedVoting;
      else
        votingRegimeValue := null;
      end if;
      if actionRec.created_by <> ame_util.seededDataCreatedById then
        customOrderNumber := customOrderNumber + 1;
      end if;
      insert into ame_action_type_config
           (application_id,
            action_type_id,
            voting_regime,
            order_number,
            chain_ordering_mode,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            start_date,
            end_date,
            object_version_number)
          select
            X_APPLICATION_ID,
            actionRec.action_type_id,
            votingRegimeValue,
            decode(actionRec.name,
                   ame_util.preApprovalTypeName, 1,
                   ame_util.dynamicPreApprover, 2,
                   ame_util.absoluteJobLevelTypeName, 1,
                   ame_util.relativeJobLevelTypeName, 2,
                   ame_util.supervisoryLevelTypeName, 3,
                   ame_util.positionTypeName, 4,
                   ame_util.positionLevelTypeName, 5,
                   ame_util.managerFinalApproverTypeName, 6,
                   ame_util.finalApproverOnlyTypeName, 7,
                   ame_util.lineItemJobLevelTypeName, 8,
                   ame_util.dualChainsAuthorityTypeName, 9,
                   ame_util.groupChainApprovalTypeName, 10,
                   ame_util.nonFinalAuthority, 1,
                   ame_util.finalAuthorityTypeName, 2,
                   ame_util.substitutionTypeName, 1,
                   ame_util.postApprovalTypeName, 1,
                   ame_util.dynamicPostApprover, 2,
                   customOrderNumber),
            ame_util.serialChainsMode,
            actionRec.created_by,
            sysdate,
            actionRec.last_updated_by,
            sysdate,
            null,
            actionRec.start_date,
            actionRec.end_date,
            1
           from sys.dual
           where not exists
                (select null
                   from ame_action_type_config
                  where application_id = X_APPLICATION_ID
                    and action_type_id = actionRec.action_type_id
                    and ((sysdate between start_date
                    and nvl(end_date - (1/86400),sysdate))
                    or (actionRec.start_date between start_date
                        and nvl(end_date,start_date))));
    end loop;
  end if;
  -- insert an attribute usage for rejectionResponse
  open  getRejectionAttributeId;
  fetch getRejectionAttributeId into X_REJECTION_RESPONSE_ID;
  if (getRejectionAttributeId%found) then
    insert into AME_ATTRIBUTE_USAGES
    (ATTRIBUTE_ID,
    APPLICATION_ID,
    QUERY_STRING,
    USE_COUNT,
    IS_STATIC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    START_DATE,
    END_DATE,
    USER_EDITABLE,
    VALUE_SET_ID,
    OBJECT_VERSION_NUMBER
   )
    select
    X_REJECTION_RESPONSE_ID,
    X_APPLICATION_ID,
    ame_util.stopAllItems,
    0,
    ame_util.booleanTrue,
    x_created_by,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    x_created_by,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    0,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
    ame_util.booleanTrue,
    null,
    1
    from sys.dual
    where not exists
        (select null
           from ame_attribute_usages
          where application_id = X_APPLICATION_ID
            and attribute_id = X_REJECTION_RESPONSE_ID
            and (sysdate between start_date
            and nvl(end_date - (1/86400),sysdate)));
  end if;
  close getRejectionAttributeId;
  -- insert an attribute usage for useWorkflow
  open  getUseWorkflowId;
  fetch getUseWorkflowId into X_USE_WORKFLOW_ID;
  if (getUseWorkflowId%found) then
    insert into AME_ATTRIBUTE_USAGES
   (ATTRIBUTE_ID,
    APPLICATION_ID,
    QUERY_STRING,
    USE_COUNT,
    IS_STATIC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    START_DATE,
    END_DATE,
    USER_EDITABLE,
    VALUE_SET_ID,
    OBJECT_VERSION_NUMBER
   )
    select
    X_USE_WORKFLOW_ID,
    X_APPLICATION_ID,
    ame_util.booleanAttributeTrue,
    0,
    ame_util.booleanTrue,
    x_created_by,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    x_created_by,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    0,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
    ame_util.booleanTrue,
    null,
    1
    from sys.dual
    where not exists
         (select null
            from ame_attribute_usages
           where application_id = X_APPLICATION_ID
             and attribute_id   = X_USE_WORKFLOW_ID
             and (sysdate between start_date
             and nvl(end_date - (1/86400),sysdate)));
  end if;
  close getUseWorkflowId;
  --
  -- Create usage for REPEAT_SUBSTITUTIONS mandatory attributes
  --
  open  getRepeatSubAttributeId;
  fetch getRepeatSubAttributeId into X_REPEAT_SUBSTITUTIONS_ID;
  if (getRepeatSubAttributeId%found) then
    insert into AME_ATTRIBUTE_USAGES
    (ATTRIBUTE_ID,
    APPLICATION_ID,
    QUERY_STRING,
    USE_COUNT,
    IS_STATIC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    START_DATE,
    END_DATE,
    USER_EDITABLE,
    VALUE_SET_ID,
    OBJECT_VERSION_NUMBER
   )
    select
    X_REPEAT_SUBSTITUTIONS_ID,
    X_APPLICATION_ID,
    ame_util.booleanAttributeFalse,
    0,
    ame_util.booleanTrue,
    x_created_by,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    x_created_by,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    0,
    to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
    AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
    ame_util.booleanTrue,
    null,
    1
    from sys.dual
    where not exists
        (select null
           from ame_attribute_usages
          where application_id = X_APPLICATION_ID
            and attribute_id   = X_REPEAT_SUBSTITUTIONS_ID
            and (sysdate between start_date
            and nvl(end_date - (1/86400),sysdate)));
  end if;
  close getRepeatSubAttributeId;
end RUN_CONFIG_USAGES_ROWS;
procedure LOAD_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TRANSACTION_TYPE_ID in VARCHAR2,
          X_APPLICATION_NAME    in VARCHAR2,
          X_BASE_APPLICATION_NAME in VARCHAR2,
          X_LINE_ITEM_ID_QUERY  in VARCHAR2,
          X_OWNER               in VARCHAR2,
          X_LAST_UPDATE_DATE    in VARCHAR2,
          X_CUSTOM_MODE         in VARCHAR2
)
is
  X_APPLICATION_ID              NUMBER;
  X_CALLING_APPS_ROWID          ROWID;
  X_CREATED_BY                  NUMBER;
  X_CURRENT_ITEM_ID_QUERY       ame_item_class_usages.item_id_query%type;
  X_CURRENT_LAST_UPDATE_DATE    VARCHAR2(19);
  X_CURRENT_OWNER               NUMBER;
  X_CURRENT_USAGE_OWNER         NUMBER;
  X_CURRENT_USAGE_LUD           VARCHAR2(19);
  X_FND_APPLICATION_ID          NUMBER;
  X_LAST_UPDATED_BY             NUMBER;
  X_LAST_UPDATE_LOGIN           NUMBER;
  X_USAGE_ROWID                 ROWID;
  X_NEW_LINE_ITEM_ID_QUERY      VARCHAR2(4000);
  X_CURRENT_APP_OVN             NUMBER;
  X_CURRENT_USAGE_OVN           NUMBER;
  X_BASE_APP_NAME               VARCHAR2(240);
--
begin
  --detect current installation level of AME
  X_AME_INSTALLATION_LEVEL:= fnd_profile.value('AME_INSTALLATION_LEVEL');
  if X_BASE_APPLICATION_NAME is null then
    X_BASE_APP_NAME := X_APPLICATION_NAME;
  else
    X_BASE_APP_NAME := X_BASE_APPLICATION_NAME;
  end if;
 -- retrieve information for the current row
  KEY_TO_IDS (
    X_APPLICATION_SHORT_NAME,
    X_TRANSACTION_TYPE_ID,
    X_CALLING_APPS_ROWID,
    X_FND_APPLICATION_ID,
    X_APPLICATION_ID,
    X_CURRENT_OWNER,
    X_CURRENT_LAST_UPDATE_DATE,
    X_USAGE_ROWID,
    X_CURRENT_USAGE_OWNER,
    X_CURRENT_USAGE_LUD,
    X_CURRENT_ITEM_ID_QUERY,
    X_CURRENT_APP_OVN,
    X_CURRENT_USAGE_OVN);

 -- obtain who column details
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
--
-- detect whether the config rows have to be inserted for this transaction type

--
--chang line_item_id_query value
--case 1: if full patch is applied make it null
--case 2: if not applied , retain its value
  X_NEW_LINE_ITEM_ID_QUERY:= X_LINE_ITEM_ID_QUERY;
  if X_AME_INSTALLATION_LEVEL is not null then
    X_NEW_LINE_ITEM_ID_QUERY:= null;
  end if;
  begin
  -- the current row was not found insert a new row for
  -- ame_calling_apps, a new item class usages
  -- for header (required) and line item class (optional)
   if X_FND_APPLICATION_ID is not null then
     if (X_CALLING_APPS_ROWID is null) and
        (X_APPLICATION_ID is null) then
       -- derive a new application id
       select ame_applications_s.nextval
       into X_APPLICATION_ID
       from dual;
       INSERT_ROW (
         X_FND_APPLICATION_ID,
         X_BASE_APP_NAME,
         X_TRANSACTION_TYPE_ID,
         X_APPLICATION_ID,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_NEW_LINE_ITEM_ID_QUERY,
         1);
       INSERT_TL_ROW
         (
         X_APPLICATION_ID,
         X_APPLICATION_NAME,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN
         );
       -- insert new row for ame_item_class_usages header
       INSERT_USAGE_ROW (
         X_APPLICATION_ID,
         1,
         'select :transactionId from dual',
         1,
         'S',
         'S',
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         1);
         if X_LINE_ITEM_ID_QUERY is not null then
         -- insert new row for ame_item_class_usages header
           INSERT_USAGE_ROW (
             X_APPLICATION_ID,
             2,
             X_LINE_ITEM_ID_QUERY,
             2,
             'S',
             'S',
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             1);
         end if;

         RUN_CONFIG_USAGES_ROWS(X_APPLICATION_ID,
                                X_LAST_UPDATE_DATE,
                                X_CREATED_BY);
  -- the current row was found end date the current row
  -- insert a row with the same application id
     else
       if X_CUSTOM_MODE = 'FORCE' then
         FORCE_UPDATE_ROW (
           X_CALLING_APPS_ROWID,
           X_BASE_APP_NAME,
           X_APPLICATION_ID,
           X_NEW_LINE_ITEM_ID_QUERY,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
           X_CURRENT_APP_OVN + 1
           );
         UPDATE_TL_ROW
           (
           X_APPLICATION_ID,
           X_APPLICATION_NAME,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           X_CUSTOM_MODE
           );
         if X_LINE_ITEM_ID_QUERY is not null and
            X_LINE_ITEM_ID_QUERY <> X_CURRENT_ITEM_ID_QUERY then
           FORCE_UPDATE_USAGE_ROW (
             X_USAGE_ROWID,
             X_LINE_ITEM_ID_QUERY,
             2,
             'S',
             'S',
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
             X_CURRENT_USAGE_OVN + 1
             );
         end if;
       else
         if DO_UPDATE_INSERT
          (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE) then
           UPDATE_ROW (
             X_CALLING_APPS_ROWID,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
           INSERT_ROW (
             X_FND_APPLICATION_ID,
             X_BASE_APP_NAME,
             X_TRANSACTION_TYPE_ID,
             X_APPLICATION_ID,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_NEW_LINE_ITEM_ID_QUERY,
             X_CURRENT_APP_OVN + 1);

             UPDATE_TL_ROW
             (
             X_APPLICATION_ID,
             X_APPLICATION_NAME,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             X_CUSTOM_MODE
             );
             --+
             if X_LINE_ITEM_ID_QUERY is not null and
                X_LINE_ITEM_ID_QUERY <> X_CURRENT_ITEM_ID_QUERY and
                DO_UPDATE_INSERT(AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
                                 X_CURRENT_USAGE_OWNER,
                                 X_LAST_UPDATE_DATE,
                                 X_CURRENT_USAGE_LUD) then
                UPDATE_USAGE_ROW (
                           X_USAGE_ROWID,
                           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400)
                           );
               INSERT_USAGE_ROW (
                 X_APPLICATION_ID,
                 2,
                 X_LINE_ITEM_ID_QUERY,
                 2,
                 'S',
                 'S',
                 X_CREATED_BY,
                 to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
                 X_LAST_UPDATED_BY,
                 to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
                 X_LAST_UPDATE_LOGIN,
                 to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
                 X_CURRENT_USAGE_OVN + 1);
             end if;
         end if;
       end if;
      end if;
    end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_calling_apps_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

  procedure TRANSLATE_ROW
    (X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_APPLICATION_NAME       in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
    X_CURRENT_OWNER            NUMBER;
    X_CURRENT_LAST_UPDATE_DATE varchar2(20);
    X_CREATED_BY               varchar2(100);
    X_APPLICATION_ID           number;
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;

    begin
      select ACATL.LAST_UPDATED_BY,
             AME_SEED_UTILITY.DATE_AS_STRING(ACATL.LAST_UPDATE_DATE),
             AME_SEED_UTILITY.OWNER_AS_STRING(ACATL.CREATED_BY),
             ACA.APPLICATION_ID
        into X_CURRENT_OWNER,
             X_CURRENT_LAST_UPDATE_DATE,
             X_CREATED_BY,
             X_APPLICATION_ID
        from AME_CALLING_APPS_TL ACATL,
             AME_CALLING_APPS ACA,
             FND_APPLICATION_VL FAV
       where FAV.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
         and FAV.APPLICATION_ID = ACA.FND_APPLICATION_ID
         and ((ACA.TRANSACTION_TYPE_ID is null and X_TRANSACTION_TYPE_ID is null) or
             ACA.TRANSACTION_TYPE_ID = X_TRANSACTION_TYPE_ID)
         and sysdate between ACA.START_DATE and nvl(ACA.END_DATE - (1/86400),sysdate)
         and ACATL.APPLICATION_ID = ACA.APPLICATION_ID
         and ACATL.LANGUAGE = userenv('LANG');
      if  DO_TL_UPDATE_INSERT
          (X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER             => X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE,
           X_CREATED_BY                => X_CREATED_BY,
           X_CUSTOM_MODE               => X_CUSTOM_MODE) then
        update AME_CALLING_APPS_TL ACATL
           set APPLICATION_NAME = nvl(X_APPLICATION_NAME,APPLICATION_NAME),
               SOURCE_LANG = userenv('LANG'),
               LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               LAST_UPDATE_LOGIN = 0
         where ACATL.APPLICATION_ID = X_APPLICATION_ID
           and userenv('LANG') in (ACATL.LANGUAGE,ACATL.SOURCE_LANG);
      end if;
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

  procedure LOAD_SEED_ROW
    (X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_APPLICATION_NAME       in varchar2
    ,X_BASE_APPLICATION_NAME  in varchar2
    ,X_LINE_ITEM_ID_QUERY     in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
  begin
    if X_UPLOAD_MODE = 'NLS' then
      TRANSLATE_ROW
        (X_APPLICATION_SHORT_NAME  => X_APPLICATION_SHORT_NAME
        ,X_TRANSACTION_TYPE_ID     => X_TRANSACTION_TYPE_ID
        ,X_APPLICATION_NAME        => X_APPLICATION_NAME
        ,X_OWNER                   => X_OWNER
        ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
        ,X_CUSTOM_MODE             => X_CUSTOM_MODE
        );
    else
      LOAD_ROW
        (X_APPLICATION_SHORT_NAME  => X_APPLICATION_SHORT_NAME
        ,X_TRANSACTION_TYPE_ID     => X_TRANSACTION_TYPE_ID
        ,X_APPLICATION_NAME        => X_APPLICATION_NAME
        ,X_BASE_APPLICATION_NAME   => X_BASE_APPLICATION_NAME
        ,X_LINE_ITEM_ID_QUERY      => X_LINE_ITEM_ID_QUERY
        ,X_OWNER                   => X_OWNER
        ,X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE
        ,X_CUSTOM_MODE             => X_CUSTOM_MODE
        );
    end if;
  end LOAD_SEED_ROW;
END AME_CALLING_APPS_API;

/
