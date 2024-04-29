--------------------------------------------------------
--  DDL for Package Body AME_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTIONS_API" AS
/* $Header: ameanapi.pkb 120.8.12000000.2 2007/04/19 08:04:56 prasashe noship $ */
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
  X_ACTION_TYPE_NAME in VARCHAR2,
  X_PARAMETER_TWO    in VARCHAR2,
  X_PARAMETER        in out nocopy VARCHAR2,
  X_ACTION_ID        out nocopy NUMBER,
  X_ACTION_ROWID     out nocopy VARCHAR2,
  X_ACTION_TYPE_ID   out nocopy NUMBER,
  X_CURRENT_OWNER    out nocopy NUMBER,
  X_CURRENT_LAST_UPDATE_DATE out nocopy VARCHAR2,
  X_CURRENT_OVN      out nocopy NUMBER
) is
  cursor CSR_GET_ACTION_TYPE_ID
  (
    X_ACTION_TYPE_NAME in VARCHAR2
  ) is
   select ACTION_TYPE_ID
   from   AME_ACTION_TYPES
   where  NAME = X_ACTION_TYPE_NAME
	    and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate);
  cursor CSR_GET_CURRENT_ACTION
  (
    X_ACTION_TYPE_ID in NUMBER,
    X_PARAMETER      in VARCHAR2,
    X_PARAMETER_TWO  in VARCHAR2
  ) is select ACTION_ID, ROWID,
          LAST_UPDATED_BY,
          to_char(LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
          nvl(OBJECT_VERSION_NUMBER,1)
     from AME_ACTIONS
    where ACTION_TYPE_ID = X_ACTION_TYPE_ID
      and nvl(PARAMETER,'NULL')      = nvl(X_PARAMETER,'NULL')
      and nvl(PARAMETER_TWO,'NULL')  = nvl(X_PARAMETER_TWO,'NULL')
	    and sysdate between START_DATE
			 and nvl(END_DATE  - (1/86400), sysdate)
    order by LAST_UPDATE_DATE desc;
  cursor CSR_GET_APPROVAL_GROUP_ID
  (
    X_APPROVAL_GROUP_NAME in VARCHAR2
  ) is
   select APPROVAL_GROUP_ID
   from   AME_APPROVAL_GROUPS
   where  NAME = X_APPROVAL_GROUP_NAME
   and    sysdate between START_DATE
                  and nvl(end_date - (1/86400), sysdate);
  L_PARAMETER   NUMBER;
begin
  X_CURRENT_OVN := 1;
  open CSR_GET_ACTION_TYPE_ID (
    X_ACTION_TYPE_NAME
  );
  fetch CSR_GET_ACTION_TYPE_ID into X_ACTION_TYPE_ID;
    if (CSR_GET_ACTION_TYPE_ID%notfound) then
      X_ACTION_TYPE_ID := null;
    end if;
  close CSR_GET_ACTION_TYPE_ID;

  if X_ACTION_TYPE_ID is not null
  then
  --
  -- Determine if the action type is one that is based on groups.
  --
  if X_ACTION_TYPE_NAME in ('approval-group chain of authority'
                           ,'pre-chain-of-authority approvals'
                           ,'post-chain-of-authority approvals'
                           ) then
    open CSR_GET_APPROVAL_GROUP_ID(X_PARAMETER);
    fetch CSR_GET_APPROVAL_GROUP_ID into L_PARAMETER;
    if (CSR_GET_APPROVAL_GROUP_ID%found) then
      X_PARAMETER := TO_CHAR(L_PARAMETER);
    else
      X_PARAMETER := null;
    end if;
    close CSR_GET_APPROVAL_GROUP_ID;
  end if;
  open CSR_GET_CURRENT_ACTION (
    X_ACTION_TYPE_ID,
    X_PARAMETER,
    X_PARAMETER_TWO
  );
  fetch CSR_GET_CURRENT_ACTION into X_ACTION_ID, X_ACTION_ROWID,
                      X_CURRENT_OWNER, X_CURRENT_LAST_UPDATE_DATE,X_CURRENT_OVN;
    if (CSR_GET_CURRENT_ACTION%notfound) then
      X_ACTION_ROWID := null;
    end if;
  close CSR_GET_CURRENT_ACTION;
  end if;
end KEY_TO_IDS;
function DO_UPDATE_INSERT(X_OWNER in NUMBER,
                   X_CURRENT_OWNER in NUMBER,
                   X_LAST_UPDATE_DATE in VARCHAR2,
                   X_CURRENT_LAST_UPDATE_DATE in VARCHAR2,
                   X_CUSTOM_MODE in VARCHAR2 default null)
return boolean as
begin
  if X_CUSTOM_MODE = 'FORCE' then
    return true;
  end if;
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
                   X_CREATED_BY in VARCHAR2,
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
 X_ACTION_ID                       in NUMBER,
 X_ACTION_TYPE_ID                  in NUMBER,
 X_PARAMETER                       in VARCHAR2,
 X_PARAMETER_TWO                   in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_DESCRIPTION                     in VARCHAR2,
 X_OBJECT_VERSION_NUMBER           in NUMBER
 )
 is
begin
  insert into AME_ACTIONS
  (
   ACTION_ID,
   ACTION_TYPE_ID,
   PARAMETER,
   PARAMETER_TWO,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   START_DATE,
   END_DATE,
   DESCRIPTION,
   OBJECT_VERSION_NUMBER
  ) values (
   X_ACTION_ID,
   X_ACTION_TYPE_ID,
   X_PARAMETER,
   X_PARAMETER_TWO,
   X_CREATED_BY,
   X_CREATION_DATE,
   X_LAST_UPDATED_BY,
   X_LAST_UPDATE_DATE,
   X_LAST_UPDATE_LOGIN,
   X_START_DATE,
   AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
   X_DESCRIPTION,
   X_OBJECT_VERSION_NUMBER);
end INSERT_ROW;

procedure INSERT_TL_ROW (
  X_ACTION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER) is
 begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
  insert into AME_ACTIONS_TL
    (ACTION_ID
    ,DESCRIPTION
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,LANGUAGE
    ,SOURCE_LANG
    ) select X_ACTION_ID,
             X_DESCRIPTION,
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
                           from AME_ACTIONS_TL T
                          where T.ACTION_ID = X_ACTION_ID
                            and T.LANGUAGE = L.LANGUAGE_CODE);
END insert_tl_row;

procedure UPDATE_TL_ROW (
  X_ACTION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
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
       FROM AME_ACTIONS_TL
       WHERE ACTION_ID = X_ACTION_ID
       AND LANGUAGE = USERENV('LANG');

   if DO_UPDATE_INSERT
     (X_LAST_UPDATED_BY
     ,X_CURRENT_OWNER
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_LAST_UPDATE_DATE)
     ,AME_SEED_UTILITY.DATE_AS_STRING(X_CURRENT_LAST_UPDATE_DATE)
     ,X_CUSTOM_MODE) then
      update AME_ACTIONS_TL
         set DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
             SOURCE_LANG = userenv('LANG'),
             LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
             LAST_UPDATED_BY = X_LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN = 0
       where ACTION_ID = X_ACTION_ID
         and userenv('LANG') in (LANGUAGE,SOURCE_LANG);
   end if;
exception
  when no_data_found then
    null;
end UPDATE_TL_ROW;

procedure UPDATE_ROW (
 X_ACTION_ROWID             in VARCHAR2,
 X_END_DATE                 in DATE)
 is
begin
  update AME_ACTIONS set
   END_DATE            = X_END_DATE
  where ROWID          = X_ACTION_ROWID;
end UPDATE_ROW;

procedure FORCE_UPDATE_ROW (
  X_ROWID                      in VARCHAR2,
  X_DESCRIPTION                in VARCHAR2,
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
  update AME_ACTIONS
     set DESCRIPTION = X_DESCRIPTION,
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
  X_ACTION_ID      in NUMBER
) is
begin
  if AME_SEED_UTILITY.MLS_ENABLED then
    delete from AME_ACTIONS_TL
    where ACTION_ID = X_ACTION_ID;
  end if;
  delete from AME_ACTIONS
  where ACTION_ID =   X_ACTION_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
procedure LOAD_ROW (
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_PARAMETER        in VARCHAR2,
          X_PARAMETER_TWO    in VARCHAR2,
          X_DESCRIPTION      in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
  X_ACTION_ID NUMBER;
  X_ACTION_ROWID ROWID;
  X_ACTION_TYPE_ID NUMBER;
  X_CREATED_BY NUMBER;
  X_CURRENT_LAST_UPDATE_DATE VARCHAR2(19);
  X_CURRENT_OWNER NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  L_PARAMETER VARCHAR2(320);
  X_CURRENT_OVN NUMBER;
begin
-- retrieve information for the current row
  L_PARAMETER := X_PARAMETER;
  KEY_TO_IDS (
  X_ACTION_TYPE_NAME,
  X_PARAMETER_TWO,
  L_PARAMETER,
  X_ACTION_ID,
  X_ACTION_ROWID,
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
   begin
-- the current row was not found insert a new row
   if X_ACTION_TYPE_ID is not null then
     if X_ACTION_ROWID is null then
       if X_ACTION_ID is null then
         select ame_actions_s.nextval
         into X_ACTION_ID
         from dual;
       end if;
       INSERT_ROW (
         X_ACTION_ID,
         X_ACTION_TYPE_ID,
         L_PARAMETER,
         X_PARAMETER_TWO,
         X_CREATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATED_BY,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_LAST_UPDATE_LOGIN,
         to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
         X_DESCRIPTION,
         1
         );
       INSERT_TL_ROW
       (
       X_ACTION_ID,
       X_DESCRIPTION,
       X_CREATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATED_BY,
       to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_LOGIN
       );
     else
       if X_CUSTOM_MODE = 'FORCE' then
         FORCE_UPDATE_ROW
           (
           X_ACTION_ROWID,
           X_DESCRIPTION,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           AME_SEED_UTILITY.GET_DEFAULT_END_DATE,
           X_CURRENT_OVN + 1
           );
         UPDATE_TL_ROW
           (
           X_ACTION_ID,
           X_DESCRIPTION,
           X_CREATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATED_BY,
           to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
           X_LAST_UPDATE_LOGIN,
           X_CUSTOM_MODE
           );
       else
-- the current row was found end date the current row
-- insert a row with the same action type id
         if DO_UPDATE_INSERT(AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
                      X_CURRENT_OWNER,
                      X_LAST_UPDATE_DATE,
                      X_CURRENT_LAST_UPDATE_DATE) then
           UPDATE_ROW (
             X_ACTION_ROWID,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS')-(1/86400));
           INSERT_ROW (
             X_ACTION_ID,
             X_ACTION_TYPE_ID,
             L_PARAMETER,
             X_PARAMETER_TWO,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_DESCRIPTION,
             X_CURRENT_OVN + 1
             );
           UPDATE_TL_ROW
             (
             X_ACTION_ID,
             X_DESCRIPTION,
             X_CREATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATED_BY,
             to_date(X_LAST_UPDATE_DATE,'YYYY/MM/DD HH24:MI:SS'),
             X_LAST_UPDATE_LOGIN,
             X_CUSTOM_MODE
             );
         end if;
       end if;
     end if;
   else
-- nothing was found do not process
     null;
   end if;
  end;
exception
    when others then
    ame_util.runtimeException('ame_actions_usages_api',
                         'load_row',
                         sqlcode,
                         sqlerrm);
        raise;
end LOAD_ROW;

procedure LOAD_ROW (
          X_ACTION_TYPE_NAME in VARCHAR2,
          X_PARAMETER        in VARCHAR2,
          X_DESCRIPTION      in VARCHAR2,
          X_OWNER            in VARCHAR2,
          X_LAST_UPDATE_DATE in VARCHAR2,
          X_CUSTOM_MODE      in VARCHAR2
)
is
begin
null;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_ACTION_TYPE_NAME          in VARCHAR2,
  X_PARAMETER                 in VARCHAR2,
  X_PARAMETER_TWO             in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_OWNER                     in VARCHAR2,
  X_LAST_UPDATE_DATE          in VARCHAR2,
  X_CUSTOM_MODE               in VARCHAR2) as
  X_CURRENT_OWNER            NUMBER;
  X_CURRENT_LAST_UPDATE_DATE varchar2(20);
  X_CREATED_BY               varchar2(100);
  X_ACTION_ID           number;
  X_APPROVAL_GROUP_ID   number;
  X_TEMP_PARAMETER      varchar2(320);
  begin
    if not AME_SEED_UTILITY.MLS_ENABLED then
      return;
    end if;
    begin
      X_TEMP_PARAMETER := X_PARAMETER;
      if X_ACTION_TYPE_NAME  in (ame_util.groupChainApprovalTypeName
                                ,ame_util.preApprovalTypeName
                                ,ame_util.postApprovalTypeName) then
        begin
          select approval_group_id
            into X_APPROVAL_GROUP_ID
            from ame_approval_groups
           where name = X_PARAMETER
             and sysdate between start_date and nvl(end_date, sysdate);
        X_TEMP_PARAMETER := to_char(X_APPROVAL_GROUP_ID);
        exception
          when no_data_found then
            null;
        end;
      end if;
      select ACTTL.LAST_UPDATED_BY,
             AME_SEED_UTILITY.DATE_AS_STRING(ACTTL.LAST_UPDATE_DATE),
             AME_SEED_UTILITY.OWNER_AS_STRING(ACTTL.CREATED_BY),
             ACT.ACTION_ID
        into X_CURRENT_OWNER,
             X_CURRENT_LAST_UPDATE_DATE,
             X_CREATED_BY,
             X_ACTION_ID
        from AME_ACTIONS_TL ACTTL,
             AME_ACTIONS ACT,
             AME_ACTION_TYPES AAT
       where AAT.NAME = X_ACTION_TYPE_NAME
         and AAT.ACTION_TYPE_ID = ACT.ACTION_TYPE_ID
         and nvl(ACT.PARAMETER,'NULL') = nvl(X_TEMP_PARAMETER,'NULL')
         and nvl(ACT.PARAMETER_TWO,'NULL') = nvl(X_PARAMETER_TWO,'NULL')
         and sysdate between AAT.START_DATE and nvl(AAT.END_DATE - (1/86400),sysdate)
         and sysdate between ACT.START_DATE and nvl(ACT.END_DATE - (1/86400),sysdate)
         and ACTTL.ACTION_ID = ACT.ACTION_ID
         and ACTTL.LANGUAGE = userenv('LANG')
         and (X_ACTION_TYPE_NAME <> ame_util.finalAuthorityTypeName
              or (X_ACTION_TYPE_NAME = ame_util.finalAuthorityTypeName and
                  ACT.ACTION_ID = (
                                   select MIN(ACTION_ID)
                                     from ame_actions aac,ame_action_types aaty
                                    where aac.action_type_id = aaty.action_type_id
                                      and aaty.name = X_ACTION_TYPE_NAME
                                      and sysdate between aac.start_date
                                                      and nvl(aac.end_date,sysdate)
                                      and sysdate between aaty.start_date
                                                      and nvl(aaty.end_date,sysdate)
                                  )
                 )
             );
      if  DO_TL_UPDATE_INSERT
          (X_OWNER                     => AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
           X_CURRENT_OWNER             => X_CURRENT_OWNER,
           X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE,
           X_CURRENT_LAST_UPDATE_DATE  => X_CURRENT_LAST_UPDATE_DATE,
           X_CREATED_BY                => X_CREATED_BY,
           X_CUSTOM_MODE               => X_CUSTOM_MODE) then
        update AME_ACTIONS_TL ACTTL
           set DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
               SOURCE_LANG = userenv('LANG'),
               LAST_UPDATE_DATE = AME_SEED_UTILITY.DATE_AS_DATE(X_LAST_UPDATE_DATE),
               LAST_UPDATED_BY = AME_SEED_UTILITY.OWNER_AS_INTEGER(X_OWNER),
               LAST_UPDATE_LOGIN = 0
         where ACTTL.ACTION_ID = X_ACTION_ID
           and userenv('LANG') in (ACTTL.LANGUAGE,ACTTL.SOURCE_LANG);
      end if;
    exception
      when no_data_found then
        null;
    end;
  end TRANSLATE_ROW;

END AME_ACTIONS_API;

/
