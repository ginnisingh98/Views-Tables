--------------------------------------------------------
--  DDL for Package Body AME_MAN_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_MAN_ATTRIBUTES_API" AS
/* $Header: amemaapi.pkb 120.2 2005/10/14 04:13:11 ubhat noship $ */
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
  X_ATTRIBUTE_NAME   in VARCHAR2,
  X_ACTION_TYPE_NAME in VARCHAR2,
  X_MAN_ATTRIBUTE_ROWID out nocopy VARCHAR2,
  X_ATTRIBUTE_ID     out nocopy NUMBER,
  X_ACTION_TYPE_ID   out nocopy NUMBER,
  X_CURRENT_OWNER    out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN out nocopy NUMBER
) is
  cursor CSR_GET_ATTRIBUTE_ID
  (
    X_ATTRIBUTE_NAME in VARCHAR2
  ) is
    select ATTRIBUTE_ID
      from AME_ATTRIBUTES
     where NAME = X_ATTRIBUTE_NAME
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_ACTION_TYPE_ID
  (
    X_ACTION_TYPE_NAME in VARCHAR2
  ) is
    select nvl(ACTION_TYPE_ID, null)
      from AME_ACTION_TYPES
     where NAME = X_ACTION_TYPE_NAME
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);

  cursor CSR_GET_CURRENT_MAN_ATTRIBUTE
  (
    X_ATTRIBUTE_ID   in NUMBER,
    X_ACTION_TYPE_ID in NUMBER
  )
  is select ROWID,
            LAST_UPDATED_BY,
            to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
            nvl(OBJECT_VERSION_NUMBER,1)
       from AME_MANDATORY_ATTRIBUTES
    where ATTRIBUTE_ID   = X_ATTRIBUTE_ID
      and ACTION_TYPE_ID = X_ACTION_TYPE_ID
      and sysdate between START_DATE
       and nvl(END_DATE  - (1/86400), sysdate);
begin
  open  CSR_GET_ATTRIBUTE_ID (
    X_ATTRIBUTE_NAME
  );
  fetch CSR_GET_ATTRIBUTE_ID into X_ATTRIBUTE_ID;
    if (CSR_GET_ATTRIBUTE_ID%notfound) then
       X_ATTRIBUTE_ID := null;
    end if;
  close CSR_GET_ATTRIBUTE_ID;

  if X_ACTION_TYPE_NAME = 'MANDATORY_ATTRIBUTE' THEN
    X_ACTION_TYPE_ID := -1;
  else
    open  CSR_GET_ACTION_TYPE_ID (
      X_ACTION_TYPE_NAME
    );
    fetch CSR_GET_ACTION_TYPE_ID into X_ACTION_TYPE_ID;
    close CSR_GET_ACTION_TYPE_ID;
  end if;

  if X_ATTRIBUTE_ID is not null and X_ACTION_TYPE_ID is not null then
    open CSR_GET_CURRENT_MAN_ATTRIBUTE
    (
      X_ATTRIBUTE_ID,
      X_ACTION_TYPE_ID
     );
    fetch CSR_GET_CURRENT_MAN_ATTRIBUTE into X_MAN_ATTRIBUTE_ROWID,
                                             X_CURRENT_OWNER,
                                             X_CURRENT_LAST_UPDATE_DATE,
                                             X_CURRENT_OVN;
    if (CSR_GET_CURRENT_MAN_ATTRIBUTE%notfound) then
      X_MAN_ATTRIBUTE_ROWID := null;
    end if;
    close CSR_GET_CURRENT_MAN_ATTRIBUTE;
  end if;

end KEY_TO_IDS;
function DO_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CUSTOM_MODE in varchar2 default null)
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

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
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
  update AME_MANDATORY_ATTRIBUTES
     set CREATED_BY = X_CREATED_BY,
         CREATION_DATE = X_CREATION_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
         START_DATE = X_START_DATE,
         END_DATE = X_END_DATE,
         OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
   where ROWID = X_ROWID;
end FORCE_UPDATE_ROW;

procedure INSERT_ROW (
 X_ATTRIBUTE_ID                    in NUMBER,
 X_ACTION_TYPE_ID                  in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER
 )
 is
  lockHandle varchar2(500);
  returnValue integer;
begin

  DBMS_LOCK.ALLOCATE_UNIQUE (lockname =>'AME_MANDATORY_ATTRIBUTES.'||to_char(X_ATTRIBUTE_ID)
                                  ||'.'||to_char(X_ACTION_TYPE_ID),lockhandle => lockHandle);
  returnValue := DBMS_LOCK.REQUEST(lockhandle => lockHandle,timeout => 0,release_on_commit => true);
  if returnValue = 0  then
    insert into AME_MANDATORY_ATTRIBUTES
    (
     ATTRIBUTE_ID,
     ACTION_TYPE_ID,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     START_DATE,
     END_DATE,
     OBJECT_VERSION_NUMBER
    ) values (
     X_ATTRIBUTE_ID,
     X_ACTION_TYPE_ID,
     X_CREATED_BY,
     X_CREATION_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN,
     X_START_DATE,
     AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
     X_OBJECT_VERSION_NUMBER);
  end if;
end INSERT_ROW;

procedure UPDATE_ROW (
 X_MAN_ATTRIBUTE_ROWID           in VARCHAR2,
 X_END_DATE                      in DATE)
 is
begin
  update AME_MANDATORY_ATTRIBUTES set
   END_DATE             = X_END_DATE
  where ROWID           = X_MAN_ATTRIBUTE_ROWID;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ATTRIBUTE_ID   in NUMBER,
  X_ACTION_TYPE_ID in NUMBER
) is
begin
  delete from AME_MANDATORY_ATTRIBUTES
  where ATTRIBUTE_ID   = X_ATTRIBUTE_ID
    and ACTION_TYPE_ID = X_ACTION_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
          X_ATTRIBUTE_NAME   in VARCHAR2,
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_MAN_ATTRIBUTE_ROWID ROWID;
  X_ATTRIBUTE_ID NUMBER;
  X_ACTION_TYPE_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_LINE_ATTRIBUTE_NAME       ame_attributes.name%type := null;
  X_CURRENT_OVN NUMBER;
begin
  --detect if ame full patch has been applied
  X_AME_INSTALLATION_LEVEL:=fnd_profile.value('AME_INSTALLATION_LEVEL');
  if X_AME_INSTALLATION_LEVEL is not null then
    if (X_ATTRIBUTE_NAME in (
                             ame_util.transactionDateAttribute,
                             ame_util.transactionGroupAttribute,
                             ame_util.transactionOrgAttribute,
                             ame_util.transactionRequestorAttribute,
                             ame_util.transactionReqUserAttribute,
                             ame_util.transactionSetOfBooksAttribute
                            ) and
            X_ACTION_TYPE_NAME = 'MANDATORY_ATTRIBUTE') then
        return;
     end if;
    --
    -- checking for EVALUATE_PRIORITIES_PER_LINE_ITEM
    -- and USE_RESTRICTIVE_LINE_ITEM_EVALUATION attributes
    -- being uploaded
    --
    if X_ATTRIBUTE_NAME = ame_util.evalPrioritiesPerLIAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.evalPrioritiesPerItemAttribute;
    end if;
    if X_ATTRIBUTE_NAME =  ame_util.restrictiveLIEvalAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.restrictiveItemEvalAttribute;
    end if;
  end if;

  if  X_AME_INSTALLATION_LEVEL is null then
    if X_ATTRIBUTE_NAME in (ame_util.useWorkflowAttribute
                            ,ame_util.rejectionResponseAttribute
                            ,'REPEAT_SUBSTITUTIONS'
                            ,ame_util.nonDefStartingPointPosAttr
                            ,ame_util.nonDefPosStructureAttr
                            ,ame_util.transactionReqPositionAttr
                            ,ame_util.topPositionIdAttribute)then
       return;
    end if;
    if (X_ATTRIBUTE_NAME in (
                               ame_util.transactionDateAttribute,
                               ame_util.transactionGroupAttribute,
                               ame_util.transactionOrgAttribute,
                               ame_util.transactionRequestorAttribute,
                               ame_util.transactionReqUserAttribute,
                               ame_util.transactionSetOfBooksAttribute
                              ) and
              X_ACTION_TYPE_NAME <> 'MANDATORY_ATTRIBUTE') then
          return;
    end if;
    -- checking for EVALUATE_PRIORITIES_PER_ITEM
    -- and USE_RESTRICTIVE_ITEM_EVALUATION attributes
    -- being uploaded
    --
    if X_ATTRIBUTE_NAME = ame_util.evalPrioritiesPerItemAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.evalPrioritiesPerLIAttribute;
    end if;
    if X_ATTRIBUTE_NAME =  ame_util.restrictiveItemEvalAttribute
      then X_LINE_ATTRIBUTE_NAME := ame_util.restrictiveLIEvalAttribute;
    end if;
  end if;
-- retrieve information for the current row
KEY_TO_IDS (
  nvl(X_LINE_ATTRIBUTE_NAME,X_ATTRIBUTE_NAME),
  X_ACTION_TYPE_NAME,
  X_MAN_ATTRIBUTE_ROWID,
  X_ATTRIBUTE_ID,
  X_ACTION_TYPE_ID,
  X_CURRENT_OWNER,
  X_CURRENT_LAST_UPDATE_DATE,
  X_CURRENT_OVN
);
-- obtain who column details
OWNER_TO_WHO (
  X_OWNER,
  X_CREATED_BY,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN
);
-- the current row was not found insert a new row
 if (X_ATTRIBUTE_ID is not null) and
    (X_ACTION_TYPE_ID is not null) then
   if X_MAN_ATTRIBUTE_ROWID is null then
    INSERT_ROW (
      X_ATTRIBUTE_ID,
      X_ACTION_TYPE_ID,
      X_CREATED_BY,
      to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
      X_LAST_UPDATED_BY,
      to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
      X_LAST_UPDATE_LOGIN,
      to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
      1);
-- the current row was found end date the current row
-- insert a row with the same action type id
   else
     if X_CUSTOM_MODE = 'FORCE' then
       FORCE_UPDATE_ROW (
         X_MAN_ATTRIBUTE_ROWID,
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
           X_MAN_ATTRIBUTE_ROWID,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
         INSERT_ROW (
           X_ATTRIBUTE_ID,
           X_ACTION_TYPE_ID,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_CURRENT_OVN + 1);
       end if;
     end if;
   end if;
 else
   null;
 end if;

exception
    when others then
    ame_util.runtimeException('ame_mandatory_attributes_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_ATTRIBUTE_NAME                  in VARCHAR2,
  X_ACTION_TYPE_NAME                in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_UPLOAD_MODE                     in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2) as
begin
  if X_UPLOAD_MODE = 'NLS' then
    null;
  else
    LOAD_ROW
      (X_ATTRIBUTE_NAME   => X_ATTRIBUTE_NAME
      ,X_ACTION_TYPE_NAME => X_ACTION_TYPE_NAME
      ,X_OWNER            => X_OWNER
      ,X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE
      ,X_CUSTOM_MODE      => X_CUSTOM_MODE
      );
  end if;
end LOAD_SEED_ROW;
END AME_MAN_ATTRIBUTES_API;

/
