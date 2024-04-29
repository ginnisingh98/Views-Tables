--------------------------------------------------------
--  DDL for Package Body AME_ATTRIBUTE_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATTRIBUTE_USAGES_API" AS
/* $Header: ameauapi.pkb 120.3 2006/03/10 07:19:52 pvelugul noship $ */
X_AME_INSTALLATION_LEVEL varchar2(255);

function CALCULATE_USE_COUNT
  (X_ATTRIBUTE_ID ame_attribute_usages.attribute_id%type,
   X_APPLICATION_ID ame_attribute_usages.application_id%type)
    return integer as
  cursor RULE_CURSOR
   (X_APPLICATION_ID  ame_attribute_usages.application_id%type) is
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
    MANDATORY_COUNT integer;
    NEW_USE_COUNT integer;
    RULE_COUNT integer;
    TEMP_COUNT integer;
  begin
  NEW_USE_COUNT := 0;
  select COUNT(*)
    into MANDATORY_COUNT
    from AME_MANDATORY_ATTRIBUTES
   where ATTRIBUTE_ID = X_ATTRIBUTE_ID
     and ACTION_TYPE_ID = ame_util.mandAttActionTypeId
     and SYSDATE between START_DATE
     and nvl(END_DATE  - (1/86400), sysdate);
  if (MANDATORY_COUNT > 0) then
    NEW_USE_COUNT := 0;
  else
    for TEMPRULE in RULE_CURSOR(X_APPLICATION_ID => X_APPLICATION_ID) loop
      select count(*)
        into TEMP_COUNT
        from AME_CONDITIONS,
             AME_CONDITION_USAGES
       where AME_CONDITIONS.ATTRIBUTE_ID = X_ATTRIBUTE_ID
         and AME_CONDITIONS.CONDITION_ID = AME_CONDITION_USAGES.CONDITION_ID
         and AME_CONDITION_USAGES.RULE_ID = TEMPRULE.RULE_ID
         and sysdate between AME_CONDITIONS.START_DATE
         and nvl(AME_CONDITIONS.END_DATE - (1/86400), sysdate)
         and ((sysdate between AME_CONDITION_USAGES.START_DATE
         and nvl(AME_CONDITION_USAGES.END_DATE - (1/86400), sysdate))
          or (sysdate < AME_CONDITION_USAGES.START_DATE
         and AME_CONDITION_USAGES.START_DATE <
             nvl(AME_CONDITION_USAGES.END_DATE,
                 AME_CONDITION_USAGES.START_DATE + (1/86400))));
      if(TEMP_COUNT > 0) then
        NEW_USE_COUNT := NEW_USE_COUNT + 1;
      else
        if TEMPRULE.ACTION_ID is null then
           -- action_id is already migrated from ame_rules to ame_action_usages
          select count(*)
            into TEMP_COUNT
            from AME_MANDATORY_ATTRIBUTES,
                 AME_ACTIONS,
                 AME_ACTION_USAGES
           where AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID = X_ATTRIBUTE_ID
             and AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID =
                 AME_ACTIONS.ACTION_TYPE_ID
             and AME_ACTIONS.ACTION_ID = AME_ACTION_USAGES.ACTION_ID
             and AME_ACTION_USAGES.RULE_ID = TEMPRULE.RULE_ID
             and sysdate between AME_MANDATORY_ATTRIBUTES.START_DATE
             and nvl(AME_MANDATORY_ATTRIBUTES.END_DATE - (1/86400), sysdate)
             and sysdate between AME_ACTIONS.START_DATE
             and nvl(AME_ACTIONS.END_DATE - (1/86400), sysdate)
             and ((sysdate between AME_ACTION_USAGES.START_DATE
             and nvl(AME_ACTION_USAGES.END_DATE - (1/86400), sysdate))
             or (sysdate < AME_ACTION_USAGES.START_DATE
             and AME_ACTION_USAGES.START_DATE < nvl(AME_ACTION_USAGES.END_DATE,
                 AME_ACTION_USAGES.START_DATE + (1/86400))));
        else
           -- action_id is yet to be migrated from ame_rules to ame_action_usages
          select count(*)
            into TEMP_COUNT
            from AME_MANDATORY_ATTRIBUTES,
                 AME_ACTIONS,
                 AME_RULES
           where AME_MANDATORY_ATTRIBUTES.ATTRIBUTE_ID = X_ATTRIBUTE_ID
             and AME_MANDATORY_ATTRIBUTES.ACTION_TYPE_ID =
                 AME_ACTIONS.ACTION_TYPE_ID
             and AME_ACTIONS.ACTION_ID = AME_RULES.ACTION_ID
             and AME_RULES.RULE_ID = TEMPRULE.RULE_ID
             and sysdate between AME_MANDATORY_ATTRIBUTES.START_DATE
             and nvl(AME_MANDATORY_ATTRIBUTES.END_DATE - (1/86400), sysdate)
             and sysdate between AME_ACTIONS.START_DATE
             and nvl(AME_ACTIONS.END_DATE - (1/86400), sysdate)
             and ((sysdate between AME_RULES.START_DATE
             and nvl(AME_RULES.END_DATE - (1/86400), sysdate))
             or (sysdate < AME_RULES.START_DATE
             and AME_RULES.START_DATE < nvl(AME_RULES.END_DATE,
                 AME_RULES.START_DATE + (1/86400))));
        end if;
        if(TEMP_COUNT > 0) then
          NEW_USE_COUNT := NEW_USE_COUNT + 1;
        end if;
      end if;
    end loop;
  end if;
  return(NEW_USE_COUNT);
  exception
  when others then
    ame_util.runtimeException('ame_attribute_usages_api',
                              'CALCULATE_USE_COUNT',
                              sqlcode,
                              sqlerrm);
    raise;
    return(null);
end CALCULATE_USE_COUNT;
function IS_SEED_USG_RULE_MODIFIED
  (X_ATTRIBUTE_ID ame_attribute_usages.attribute_id%type,
   X_APPLICATION_ID ame_attribute_usages.application_id%type)
    return boolean as
  --
  -- Verify whether the attribute is a SEEDed attribute and is/was in use
  --
  cursor CSR_USAGE_IS_SEEDED is
    select 'Y'
    from  AME_ATTRIBUTE_USAGES
    where ATTRIBUTE_ID   = X_ATTRIBUTE_ID
     and  APPLICATION_ID = X_APPLICATION_ID
     and  LAST_UPDATED_BY not in (1,120)
     and  CREATED_BY in (1,120)
     and  sysdate between START_DATE
             and nvl(END_DATE - (1/86400), sysdate)
     and exists (select null
                 from AME_ATTRIBUTE_USAGES
                 where ATTRIBUTE_ID = X_ATTRIBUTE_ID
                   and APPLICATION_ID = X_APPLICATION_ID
                  group by ATTRIBUTE_ID, APPLICATION_ID
                  having max(USE_COUNT) > 0)
     and not exists (select null
                     from AME_ATTRIBUTES ATTR1,
                          AME_ATTRIBUTE_USAGES ATTRU1
                     where ATTR1.ATTRIBUTE_ID = X_ATTRIBUTE_ID
                       and ATTRU1.APPLICATION_ID = X_APPLICATION_ID
                       and ATTR1.ATTRIBUTE_ID = ATTRU1.ATTRIBUTE_ID
                       and ATTR1.LAST_UPDATED_BY not in (1,120)
                       and ATTR1.CREATION_DATE = ATTRU1.CREATION_DATE);
  usageIsSeeded varchar2(1);
  begin
    open CSR_USAGE_IS_SEEDED;
    fetch CSR_USAGE_IS_SEEDED
    into usageIsSeeded;
    if CSR_USAGE_IS_SEEDED%notfound then
      return(false);
    end if;
    return(true);
  exception
    when others then
      ame_util.runtimeException('ame_attribute_usages_api',
                                'IS_SEED_USG_RULE_MODIFIED',
                                sqlcode,
                                sqlerrm);
      raise;
      return(false);
end IS_SEED_USG_RULE_MODIFIED;
/*******************************************************************************************
 PROCEDURE: PRESERVE_LINE_ITEM_ID_LIST
 IN PARAMETERS : X_ATTRIBUTE_ID        -> To get 'line_item'(Y/N) value from ame_attributes table
                 X_IS_STATIC           -> Procedure written for query_string modification
                                          and query_string exists only for dynamic usages
                 X_LINE_ITEM_ID_QUERY  -> Query from calling_apps table whose occurance in
                                          X_QUERY_STRING_INOUT will be replaced by
                                          :lineItemIdList
 OUT PARAMETER : X_QUERY_STRING_INOUT
 FUNCTIONALITY : This procedure is called only for AME 1159 and prior instances of AME.
                 For dynamic usages of line item attributes, AME 11510 does not use
                 :lineItemIdList as a placeholder for line_item_id_list. Instead 11510
                 has the line_item_id_query as the subquery in the query_string.
                 When uploading 11510 format data into AME 1159 and prior instances we
                 need to search for this subquery in query_string and replace it by
                 :lineItemIdList.
Logic: Both query_string and line_item_id_query are converted into a single line format
       by replacing all occurances of newline(10),carriage return(13) and tabspaces with
       space(32). Then the line_item_id_query is truncated to eliminate order by clause.
       The position of the line_item_id_query in the query_string is located and is
       replaced by :line_item_id_list
*******************************************************************************************/
procedure REMOVE_EXTRA_SPACES(strIn in out nocopy varchar2) is
  begin
    loop
      if trim(strIn) is null or instrb(strIn,fnd_global.local_chr(32)||fnd_global.local_chr(32)) = 0 then
        exit;
      end if;
      strIn:=replace (strIn,fnd_global.local_chr(32)||fnd_global.local_chr(32),fnd_global.local_chr(32));
    end loop;
  end REMOVE_EXTRA_SPACES;
procedure PRESERVE_LINE_ITEM_ID_LIST(
                        X_ATTRIBUTE_ID              number,
                        X_IS_STATIC                 varchar2,
                        X_LINE_ITEM_ID_QUERY        varchar2,
                        X_QUERY_STRING_INOUT   in out nocopy varchar2
                      ) is
  X_LINE_ITEM        varchar2(1);
  queryString        varchar2(4000);
  lineItemQuery      varchar2(4000);
  lowerQueryString   varchar2(4000);
  lowerLineItemQuery varchar2(4000);
  querySubstring     varchar2(4000);
  orderByPosition    integer;
  positionForLineItemIdList  integer;
begin
  --check if the line item id query and query string both are not null
  if trim(X_LINE_ITEM_ID_QUERY) is null
    or trim(X_QUERY_STRING_INOUT) is null then
    return;
  end if;
  --if ldt is in prior AME 11510 format, return since no changes required
  if instrb(X_LINE_ITEM_ID_QUERY,':lineItemIdList') > 0 then
    return;
  end if;
  select LINE_ITEM
  into   X_LINE_ITEM
    from ame_attributes
    where ATTRIBUTE_ID=X_ATTRIBUTE_ID
          and SYSDATE between START_DATE
              and nvl(END_DATE  - (1/86400), sysdate);
  --return if this attribute is not line_item or if it has a static usage
  if X_LINE_ITEM <> 'Y' OR X_IS_STATIC = 'Y' then
    return;
  end if;
  queryString :=X_QUERY_STRING_INOUT;
  lineItemQuery :=X_LINE_ITEM_ID_QUERY;

  queryString := replace(queryString,fnd_global.local_chr(9),fnd_global.local_chr(32));
  queryString := replace(queryString,fnd_global.local_chr(10),fnd_global.local_chr(32));
  queryString := replace(queryString,fnd_global.local_chr(13),fnd_global.local_chr(32));
  REMOVE_EXTRA_SPACES(queryString);
  queryString := replace(queryString,'('||fnd_global.local_chr(32),'(');
  queryString := replace(queryString,fnd_global.local_chr(32)||')',')');

  lineItemQuery := replace(lineItemQuery,fnd_global.local_chr(9),fnd_global.local_chr(32));
  lineItemQuery := replace(lineItemQuery,fnd_global.local_chr(10),fnd_global.local_chr(32));
  lineItemQuery := replace(lineItemQuery,fnd_global.local_chr(13),fnd_global.local_chr(32));
  REMOVE_EXTRA_SPACES(lineItemQuery);
  --remove leading and trailing spaces from lineItemQuery
  lineItemQuery := trim(lineItemQuery);

  lowerQueryString :=lower(queryString);
  lowerLineItemquery :=lower(lineItemQuery);

  orderByPosition := instrb(lowerLineItemquery, 'order by', -1);
  lineItemQuery := substrb(lineItemQuery, 1, orderByPosition -2);
  lowerLineItemquery :=lower(lineItemQuery);

  positionForLineItemIdList := instrb(lowerQueryString,lowerLineItemquery);

  if(positionForLineItemIdList>0) then
    --find the portion of the query_string which matches line_item_query in original CASE
    querySubstring :=substrb(queryString,positionForLineItemIdList,lengthb(lineItemQuery));
    X_QUERY_STRING_INOUT :=replace(queryString,'('||querySubstring||')',':lineItemIdList');
  end if;
end PRESERVE_LINE_ITEM_ID_LIST;
procedure RECTIFY_RULE_MOD_SEED_USAGE
  (X_ATTRIBUTE_ID in ame_attribute_usages.attribute_id%type,
   X_APPLICATION_ID in ame_attribute_usages.application_id%type,
   X_LAST_UPDATE_DATE in varchar2,
   X_CURRENT_LAST_UPDATE_DATE in out nocopy varchar2 ) is
  -- get all the seeded attributes impacted by the rules, when created first time
  -- using the particular attribute
  cursor ATTRIBUTE_USAGE_DATE_CUR (startDateIn date) is
    select rowid,
           END_DATE
    from AME_ATTRIBUTE_USAGES
    where ATTRIBUTE_ID   =  X_ATTRIBUTE_ID
      and APPLICATION_ID =  X_APPLICATION_ID
      and START_DATE     >= STARTDATEIN
    order by START_DATE;
  creationDate date;
  endDate   date;
  lastUpdateDate date;
  minStartDate date;
  oneSecond number := 1/86400;
  recCounter integer;
  startDate date;
  begin
    if(to_date(X_CURRENT_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS') >=
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')) then
      select min(START_DATE)
      into   minStartDate
      from   AME_ATTRIBUTE_USAGES
      where  ATTRIBUTE_ID   = X_ATTRIBUTE_ID
        and APPLICATION_ID  = X_APPLICATION_ID
        and LAST_UPDATED_BY not in (1,120);
      recCounter := 0;
      for rec in ATTRIBUTE_USAGE_DATE_CUR(startDateIn => minStartDate)
      loop
        creationDate := minStartDate + (recCounter*oneSecond);
        startDate  := creationDate;
        lastUpdateDate := minStartDate + ((recCounter+1)*oneSecond);
        if rec.end_date is null or rec.end_date = AME_SEED_UTILITY.END_OF_TIME then
          endDate := AME_SEED_UTILITY.END_OF_TIME;
          X_CURRENT_LAST_UPDATE_DATE := lastUpdateDate;
        else
          endDate := lastUpdateDate;
        end if;
        update ame_attribute_usages
        set start_date     = startDate,
            end_date       = endDate,
            creation_date  = creationDate,
          last_update_date = lastUpdateDate
        where rowid = rec.rowid;
        recCounter   := recCounter + 1;
      end loop;
    end if;
    update AME_ATTRIBUTE_USAGES
    set    LAST_UPDATED_BY = 1
    where  ATTRIBUTE_ID    = X_ATTRIBUTE_ID
      and  APPLICATION_ID  = X_APPLICATION_ID;
  exception
    when others then
      ame_util.runtimeException('ame_attribute_usages_api',
                                'RECTIFY_RULE_MOD_SEED_USAGE',
                                sqlcode,
                                sqlerrm);
      raise;
end RECTIFY_RULE_MOD_SEED_USAGE;
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
procedure VALIDATE_IS_STATIC (
  X_IS_STATIC        in VARCHAR2
)
is
  invalidIsStaticException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  begin
    if X_IS_STATIC NOT in
      (ame_util.booleanFalse, ame_util.booleanTrue)
    then
     raise invalidIsStaticException;
    end if;
  exception
    when invalidIsStaticException then
    errorCode := -20001;
    errorMessage :=
'OAM is attempting to upload an attribute usage that is neither static or dynamic. ';
    ame_util.runtimeException(packageNameIn => 'ame_attribute_usages_api',
                               routineNameIn => 'validate_is_static',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when others then
    ame_util.runtimeException('ame_attribute_usages_api',
                         'validate_is_static',
                         sqlcode,
                         sqlerrm);
        raise;
end VALIDATE_IS_STATIC;
procedure VALIDATE_REJECTION (
  X_QUERY_STRING        in VARCHAR2
)
is
  invalidRejectionException exception;
  errorCode integer;
  errorMessage ame_util.longestStringType;
  begin
    if X_QUERY_STRING NOT in
      (ame_util.continueAllOtherItems,
       ame_util.continueOtherSubItems,
       ame_util.stopAllItems)
    then
     raise invalidRejectionException;
    end if;
  exception
    when invalidRejectionException then
    errorCode := -20001;
    errorMessage :=
'OAM is attempting to upload a REJECTION RESPONSE attribute with an invalid usage. ';
    ame_util.runtimeException(packageNameIn => 'ame_attribute_usages_api',
                               routineNameIn => 'validate_rejection',
                               exceptionNumberIn => errorCode,
                               exceptionStringIn => errorMessage);
    raise_application_error(errorCode,
                            errorMessage);
    when others then
    ame_util.runtimeException('ame_attribute_usages_api',
                         'validate_rejection',
                         sqlcode,
                         sqlerrm);
        raise;
end VALIDATE_REJECTION;
procedure KEY_TO_IDS (
  X_ATTRIBUTE_NAME           in VARCHAR2,
  X_APPLICATION_NAME         in VARCHAR2,
  X_VALUE_SET_NAME           in VARCHAR2,
  X_USAGES_ROWID             out nocopy VARCHAR2,
  X_ATTRIBUTE_ID             out nocopy NUMBER,
  X_APPLICATION_ID           out nocopy NUMBER,
  X_VALUE_SET_ID             out nocopy NUMBER,
  X_CURRENT_USER_EDITABLE    out nocopy VARCHAR2,
  X_CURRENT_OWNER            out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_LINE_ITEM_ID_QUERY       out nocopy VARCHAR2,
  X_CURRENT_OVN              out nocopy NUMBER
) is
  cursor CSR_GET_ATTRIBUTE_ID
  (
    X_ATTRIBUTE_NAME in VARCHAR2
  ) is
   select ATTRIBUTE_ID
   from   AME_ATTRIBUTES
   where  NAME = X_ATTRIBUTE_NAME
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_APPLICATION_ID
  (
    X_APPLICATION_NAME in VARCHAR2
  ) is
   select APPLICATION_ID, LINE_ITEM_ID_QUERY
   from   AME_CALLING_APPS
   where  APPLICATION_NAME = X_APPLICATION_NAME
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_CURRENT_USAGE
  (
   X_ATTRIBUTE_NAME   in varchar2,
   X_APPLICATION_NAME in varchar2
  ) is
   select ROWID, USER_EDITABLE,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
     from AME_ATTRIBUTE_USAGES
    where ATTRIBUTE_ID   = X_ATTRIBUTE_ID
      and APPLICATION_ID = X_APPLICATION_ID
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_VALUE_SET
  (
   X_VALUE_SET_NAME   in varchar2
  ) is
   select FLEX_VALUE_SET_ID
     from FND_FLEX_VALUE_SETS
    where FLEX_VALUE_SET_NAME = X_VALUE_SET_NAME;
begin
  X_CURRENT_OVN := 1;
  open CSR_GET_ATTRIBUTE_ID (
    X_ATTRIBUTE_NAME
  );
  fetch CSR_GET_ATTRIBUTE_ID into X_ATTRIBUTE_ID;
  if (CSR_GET_ATTRIBUTE_ID%notfound) then
    X_ATTRIBUTE_ID := null;
  end if;
  close CSR_GET_ATTRIBUTE_ID;

  open CSR_GET_APPLICATION_ID (
    X_APPLICATION_NAME
  );
  fetch CSR_GET_APPLICATION_ID into X_APPLICATION_ID, X_LINE_ITEM_ID_QUERY;
  if (CSR_GET_APPLICATION_ID%notfound) then
    X_APPLICATION_ID := null;
  end if;
  close CSR_GET_APPLICATION_ID;

  if (X_APPLICATION_ID is not null) and
     (X_ATTRIBUTE_ID is not null) then
    open CSR_GET_CURRENT_USAGE (
      X_ATTRIBUTE_ID,
      X_APPLICATION_ID
    );
    fetch CSR_GET_CURRENT_USAGE into X_USAGES_ROWID,
                                     X_CURRENT_USER_EDITABLE,
                                     X_CURRENT_OWNER,
                                     X_CURRENT_LAST_UPDATE_DATE,
                                     X_CURRENT_OVN;
    if (CSR_GET_CURRENT_USAGE%notfound) then
      X_USAGES_ROWID := null;
    end if;
    close CSR_GET_CURRENT_USAGE;
  else
    X_USAGES_ROWID := null;
  end if;

  if X_VALUE_SET_NAME is null then
    X_VALUE_SET_ID := null;
  else
    open CSR_VALUE_SET(X_VALUE_SET_NAME);
    fetch CSR_VALUE_SET into X_VALUE_SET_ID;
    if CSR_VALUE_SET%notfound then
      X_VALUE_SET_ID := NULL;
    end if;
    close CSR_VALUE_SET;
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

procedure GET_LINE_ITEM_CLASS_QUERY(
  X_APPLICATION_ID         in         NUMBER,
  X_LINE_ITEM_ID_QUERY_OUT out nocopy VARCHAR2
) is
  cursor CSR_GET_LINE_ITEM_CLASS_QUERY is
    select ICLU.ITEM_ID_QUERY
    from AME_ITEM_CLASSES ICLS,
         AME_ITEM_CLASS_USAGES ICLU
    where ICLU.APPLICATION_ID = X_APPLICATION_ID
      and ICLS.ITEM_CLASS_ID = ICLU.ITEM_CLASS_ID
      and ICLS.NAME = ame_util.lineitemitemclassname
      and sysdate between ICLS.START_DATE and nvl(ICLS.END_DATE - (1/86400), sysdate)
      and sysdate between ICLU.START_DATE and nvl(ICLU.END_DATE - (1/86400), sysdate);
begin
  open  CSR_GET_LINE_ITEM_CLASS_QUERY;
  fetch CSR_GET_LINE_ITEM_CLASS_QUERY
  into X_LINE_ITEM_ID_QUERY_OUT;
  if CSR_GET_LINE_ITEM_CLASS_QUERY%notfound then
    X_LINE_ITEM_ID_QUERY_OUT := null;
  end if;
  close CSR_GET_LINE_ITEM_CLASS_QUERY;
end GET_LINE_ITEM_CLASS_QUERY;

procedure QUERY_STRING_VALIDATION(
  X_QUERY_STRING in VARCHAR2,
  X_LINE_ITEM_ID_QUERY in VARCHAR2,
  X_QUERY_STRING_OUT out nocopy VARCHAR2
) is
X_BY_POSITION INTEGER;
X_ORDER_BY_POSITION INTEGER;
X_ORDER_POSITION INTEGER;
X_LINE_ITEM_QUERY ame_calling_apps.line_item_id_query%type;
X_TEMP_LINE_QUERY ame_calling_apps.line_item_id_query%type;
begin
    /* remove the order by clause from the line_item_id_query before
    replacing the place holder column :lineItemIdList with '('||X_LINE_ITEM_ID_QUERY||')'*/
    X_TEMP_LINE_QUERY := upper(X_LINE_ITEM_ID_QUERY);
    X_ORDER_BY_POSITION := instrb(X_TEMP_LINE_QUERY, 'ORDER BY', -1);
    X_ORDER_POSITION := instrb(X_TEMP_LINE_QUERY, 'ORDER', -1);
    X_BY_POSITION := instrb(X_TEMP_LINE_QUERY, 'BY', X_ORDER_POSITION+5);
    if X_ORDER_BY_POSITION > 0 then
      X_LINE_ITEM_QUERY := substrb(X_LINE_ITEM_ID_QUERY,1, X_ORDER_BY_POSITION-1);
    elsif X_ORDER_POSITION > 0 and X_BY_POSITION > 0 then
      -- Replace the blank space with tab space
      X_TEMP_LINE_QUERY := replace(X_TEMP_LINE_QUERY, fnd_global.local_chr(9), fnd_global.local_chr(32));
      -- Replace the blank space with new-line
      X_TEMP_LINE_QUERY := replace(X_TEMP_LINE_QUERY, fnd_global.local_chr(10), fnd_global.local_chr(32));
      -- Replace the blank space with carraige-return
      X_TEMP_LINE_QUERY := replace(X_TEMP_LINE_QUERY, fnd_global.local_chr(13), fnd_global.local_chr(32));
      -- Extract the characters between order and by
      X_TEMP_LINE_QUERY := substrb(X_TEMP_LINE_QUERY, X_ORDER_POSITION+5, X_BY_POSITION - (X_ORDER_POSITION+5));
      if trim(X_TEMP_LINE_QUERY) is null then
        X_LINE_ITEM_QUERY := substrb(X_LINE_ITEM_ID_QUERY, 1, X_ORDER_POSITION -1);
      end if;
    end if;
    X_QUERY_STRING_OUT := replace(X_QUERY_STRING, ':lineItemIdList',
                          '('|| X_LINE_ITEM_QUERY ||')');
end QUERY_STRING_VALIDATION;

procedure INSERT_ROW (
 X_ATTRIBUTE_ID                    in NUMBER,
 X_APPLICATION_ID                  in NUMBER,
 X_QUERY_STRING                    in VARCHAR2,
 X_USE_COUNT                       in NUMBER,
 X_IS_STATIC                       in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_USER_EDITABLE                   in VARCHAR2,
 X_VALUE_SET_ID                    in NUMBER,
 X_OBJECT_VERSION_NUMBER           in NUMBER)
  is
begin
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
  ) values (
   X_ATTRIBUTE_ID,
   X_APPLICATION_ID,
   X_QUERY_STRING,
   X_USE_COUNT,
   X_IS_STATIC,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_USER_EDITABLE,
   X_VALUE_SET_ID,
   X_OBJECT_VERSION_NUMBER
  );
end INSERT_ROW;

procedure UPDATE_ROW (
 X_USAGES_ROWID                    in VARCHAR2,
 X_END_DATE                        in DATE)
 is
begin
    update AME_ATTRIBUTE_USAGES set
      END_DATE             = X_END_DATE
    where ROWID            = X_USAGES_ROWID;
end UPDATE_ROW;

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_QUERY_STRING               in VARCHAR2,
  X_USE_COUNT                  in NUMBER,
  X_IS_STATIC                  in VARCHAR2,
  X_USER_EDITABLE              in VARCHAR2,
  X_VALUE_SET_ID               in NUMBER,
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
  update AME_ATTRIBUTE_USAGES
     set QUERY_STRING = X_QUERY_STRING,
         USE_COUNT = X_USE_COUNT,
         IS_STATIC = X_IS_STATIC,
         USER_EDITABLE = X_USER_EDITABLE,
         VALUE_SET_ID = X_VALUE_SET_ID,
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

procedure DELETE_ROW (
  X_ATTRIBUTE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
begin
  delete from AME_ATTRIBUTE_USAGES
  where ATTRIBUTE_ID =   X_ATTRIBUTE_ID
    and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
            X_ATTRIBUTE_NAME     in VARCHAR2,
            X_APPLICATION_NAME   in VARCHAR2,
            X_QUERY_STRING       in VARCHAR2,
            X_USER_EDITABLE      in VARCHAR2,
            X_IS_STATIC          in VARCHAR2,
            X_USE_COUNT          in VARCHAR2,
            X_VALUE_SET_NAME     in VARCHAR2,
            X_OWNER              in VARCHAR2,
            X_LAST_UPDATE_DATE   in VARCHAR2,
            X_CUSTOM_MODE        in VARCHAR2
)
is
  X_ATTRIBUTE_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER VARCHAR2(100);
  X_CALCULATED_USE_COUNT ame_attribute_usages.use_count%type;
  X_CURRENT_USER_EDITABLE ame_attribute_usages.user_editable%type;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_LINE_ATTRIBUTE_NAME       ame_attributes.name%type := null;
  X_LINE_ITEM_ID_QUERY ame_attribute_usages.query_string%type;
  X_QUERY_STRING_OUT ame_attribute_usages.query_string%type;
  X_USAGES_ROWID ROWID;
  X_VALUE_SET_ID NUMBER;
  X_CURRENT_OVN NUMBER;
begin
--
-- checking for EVALUATE_PRIORITIES_PER_LINE_ITEM
-- and USE_RESTRICTIVE_LINE_ITEM_EVALUATION attributes
-- being uploaded
--
--check if ame full patch for 11510 is applied
  X_AME_INSTALLATION_LEVEL:= fnd_profile.value('AME_INSTALLATION_LEVEL');
  --if full patch is not applied, and 11510 ldt is uploaded, do not upload use_workflow and rejection_response usages
  if (X_AME_INSTALLATION_LEVEL is null) and
     (X_ATTRIBUTE_NAME in (ame_util.useWorkflowAttribute
                          ,ame_util.rejectionResponseAttribute
                          ,'REPEAT_SUBSTITUTIONS'
                          ,ame_util.nonDefStartingPointPosAttr
                          ,ame_util.nonDefPosStructureAttr
                          ,ame_util.transactionReqPositionAttr
                          ,ame_util.topPositionIdAttribute)
                          ) then
    return;
  end if;

  if X_AME_INSTALLATION_LEVEL is not null then
    if X_ATTRIBUTE_NAME = ame_util.evalPrioritiesPerLIAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.evalPrioritiesPerItemAttribute;
    end if;
    if X_ATTRIBUTE_NAME =  ame_util.restrictiveLIEvalAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.restrictiveItemEvalAttribute;
    end if;
  else
    if X_ATTRIBUTE_NAME = ame_util.evalPrioritiesPerItemAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.evalPrioritiesPerLIAttribute;
    end if;
    if X_ATTRIBUTE_NAME =  ame_util.restrictiveItemEvalAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.restrictiveLIEvalAttribute;
    end if;
  end if;
--
-- validation is_static column
  VALIDATE_IS_STATIC (
    X_IS_STATIC
  );
-- validation rejection_response attributes
  if X_ATTRIBUTE_NAME = ame_util.rejectionResponseAttribute then
    VALIDATE_REJECTION(
      X_QUERY_STRING
    );
  end if;
-- retrieve information for the current row
  KEY_TO_IDS (
    nvl(X_LINE_ATTRIBUTE_NAME,X_ATTRIBUTE_NAME),
    X_APPLICATION_NAME,
    X_VALUE_SET_NAME,
    X_USAGES_ROWID,
    X_ATTRIBUTE_ID,
    X_APPLICATION_ID,
    X_VALUE_SET_ID,
    X_CURRENT_USER_EDITABLE,
    X_CURRENT_OWNER,
    X_CURRENT_LAST_UPDATE_DATE,
    X_LINE_ITEM_ID_QUERY,
    X_CURRENT_OVN);
  -- obtain who column details
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
   begin
-- the current row was not found insert a new row
-- and there is a valid application and valid attribute detected
   if (X_ATTRIBUTE_ID is not null) and
      (X_APPLICATION_ID is not null) then
     -- validate the value of query string upon lineItemIdList entries if
     -- ame11510 full patch is applied
     X_QUERY_STRING_OUT := X_QUERY_STRING;
     if trim(X_QUERY_STRING_OUT) is not null then
       if X_AME_INSTALLATION_LEVEL is not null then
         if (instrb(X_QUERY_STRING, ':lineItemIdList', -1) > 0) and
            (X_LINE_ITEM_ID_QUERY is not null) then
             QUERY_STRING_VALIDATION(
               X_QUERY_STRING,
               X_LINE_ITEM_ID_QUERY,
               X_QUERY_STRING_OUT);
         elsif (instrb(X_QUERY_STRING, ':lineItemIdList', -1) > 0) and
            (X_LINE_ITEM_ID_QUERY is null) then
            -- when 11510 patch is already applied, get LINE_ITEM_ID_QUERY from
            -- ame_item_class_usages
            GET_LINE_ITEM_CLASS_QUERY(X_APPLICATION_ID,
                                      X_LINE_ITEM_ID_QUERY);
            if X_LINE_ITEM_ID_QUERY is not null then
               QUERY_STRING_VALIDATION(
                 X_QUERY_STRING,
                 X_LINE_ITEM_ID_QUERY,
                 X_QUERY_STRING_OUT);
            end if;
         end if;
       else
         PRESERVE_LINE_ITEM_ID_LIST(
                                      X_ATTRIBUTE_ID        => X_ATTRIBUTE_ID
                                     ,X_IS_STATIC           => X_IS_STATIC
                                     ,X_LINE_ITEM_ID_QUERY  => X_LINE_ITEM_ID_QUERY
                                     ,X_QUERY_STRING_INOUT  => X_QUERY_STRING_OUT
                                   );
       end if;
     end if;
     if (X_USAGES_ROWID is null) then
       INSERT_ROW (
         X_ATTRIBUTE_ID,
         X_APPLICATION_ID,
         X_QUERY_STRING_OUT,
         to_number(X_USE_COUNT),
         X_IS_STATIC,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_USER_EDITABLE,
         X_VALUE_SET_ID,
         1);
     -- the current row was found end date the current row
     -- insert a row with the same attribute id
     else
       if(AME_SEED_UTILITY.IS_SEED_USER(X_CURRENT_OWNER) = false and
         IS_SEED_USG_RULE_MODIFIED(X_ATTRIBUTE_ID   => X_ATTRIBUTE_ID,
                                   X_APPLICATION_ID => X_APPLICATION_ID)) then
         RECTIFY_RULE_MOD_SEED_USAGE(X_ATTRIBUTE_ID             => X_ATTRIBUTE_ID,
                                     X_APPLICATION_ID           => X_APPLICATION_ID,
                                     X_LAST_UPDATE_DATE         => X_LAST_UPDATE_DATE,
                                     X_CURRENT_LAST_UPDATE_DATE => X_CURRENT_LAST_UPDATE_DATE);
          X_CURRENT_OWNER := AME_SEED_UTILITY.USER_ID_OF_SEED_USER;
       end if;
       if X_CUSTOM_MODE = 'FORCE' then
           X_CALCULATED_USE_COUNT := CALCULATE_USE_COUNT(X_ATTRIBUTE_ID => X_ATTRIBUTE_ID,
                                                         X_APPLICATION_ID => X_APPLICATION_ID);
         FORCE_UPDATE_ROW (
           X_USAGES_ROWID,
           X_QUERY_STRING_OUT,
           X_CALCULATED_USE_COUNT,
           X_IS_STATIC,
           X_USER_EDITABLE,
           X_VALUE_SET_ID,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
           X_CURRENT_OVN + 1);
       else
         if DO_UPDATE_INSERT
            (AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
             X_CURRENT_OWNER,
             X_LAST_UPDATE_DATE,
             X_CURRENT_LAST_UPDATE_DATE) then
           UPDATE_ROW (
             X_USAGES_ROWID,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
           X_CALCULATED_USE_COUNT := CALCULATE_USE_COUNT(X_ATTRIBUTE_ID => X_ATTRIBUTE_ID,
                                                         X_APPLICATION_ID => X_APPLICATION_ID);
           INSERT_ROW (
             X_ATTRIBUTE_ID,
             X_APPLICATION_ID,
             X_QUERY_STRING_OUT,
             X_CALCULATED_USE_COUNT,
             X_IS_STATIC,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_USER_EDITABLE,
             X_VALUE_SET_ID,
             X_CURRENT_OVN + 1);
         end if;
       end if;
     end if;
   end if;
   end;
exception
    when others then
    ame_util.runtimeException('ame_attribute_usages_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

  procedure LOAD_SEED_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_APPLICATION_NAME       in varchar2
    ,X_QUERY_STRING           in varchar2
    ,X_USER_EDITABLE          in varchar2
    ,X_IS_STATIC              in varchar2
    ,X_USE_COUNT              in varchar2
    ,X_VALUE_SET_NAME         in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    ) as
  begin
    if X_UPLOAD_MODE = 'NLS' then
      null;
    else
      LOAD_ROW
        (X_ATTRIBUTE_NAME         => X_ATTRIBUTE_NAME
        ,X_APPLICATION_NAME       => X_APPLICATION_NAME
        ,X_QUERY_STRING           => X_QUERY_STRING
        ,X_USER_EDITABLE          => X_USER_EDITABLE
        ,X_IS_STATIC              => X_IS_STATIC
        ,X_USE_COUNT              => X_USE_COUNT
        ,X_VALUE_SET_NAME         => X_VALUE_SET_NAME
        ,X_OWNER                  => X_OWNER
        ,X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE
        ,X_CUSTOM_MODE            => X_CUSTOM_MODE
        );
    end if;
  end LOAD_SEED_ROW;
END AME_ATTRIBUTE_USAGES_API;

/
