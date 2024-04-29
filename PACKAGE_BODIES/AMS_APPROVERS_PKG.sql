--------------------------------------------------------
--  DDL for Package Body AMS_APPROVERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVERS_PKG" as
/* $Header: amslaprb.pls 120.1 2005/06/27 05:38:04 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_APPROVER_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  --X_SECURITY_GROUP_ID in NUMBER,
  X_AMS_APPROVAL_DETAIL_ID in NUMBER,
  X_APPROVER_SEQ in NUMBER,
  X_APPROVER_TYPE in VARCHAR2,
  X_OBJECT_APPROVER_ID in NUMBER,
  X_NOTIFICATION_TYPE in VARCHAR2,
  X_NOTIFICATION_TIMEOUT in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_APPROVERS (
    SEEDED_FLAG,
    ACTIVE_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    APPROVER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    --SECURITY_GROUP_ID,
    AMS_APPROVAL_DETAIL_ID,
    APPROVER_SEQ,
    APPROVER_TYPE,
    OBJECT_APPROVER_ID,
    NOTIFICATION_TYPE,
    NOTIFICATION_TIMEOUT
  ) values (
    X_SEEDED_FLAG,
    nvl(X_ACTIVE_FLAG, 'Y'),
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_APPROVER_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    --X_SECURITY_GROUP_ID,
    X_AMS_APPROVAL_DETAIL_ID,
    X_APPROVER_SEQ,
    X_APPROVER_TYPE,
    X_OBJECT_APPROVER_ID,
    X_NOTIFICATION_TYPE,
    X_NOTIFICATION_TIMEOUT
    );

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPROVER_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
 -- X_SECURITY_GROUP_ID in NUMBER,
  X_AMS_APPROVAL_DETAIL_ID in NUMBER,
  X_APPROVER_SEQ in NUMBER,
  X_APPROVER_TYPE in VARCHAR2,
  X_OBJECT_APPROVER_ID in NUMBER,
  X_NOTIFICATION_TYPE in VARCHAR2,
  X_NOTIFICATION_TIMEOUT in NUMBER
) is
  cursor c1 is select
      SEEDED_FLAG,
      ACTIVE_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      OBJECT_VERSION_NUMBER,
      --SECURITY_GROUP_ID,
      AMS_APPROVAL_DETAIL_ID,
      APPROVER_SEQ,
      APPROVER_TYPE,
      OBJECT_APPROVER_ID,
      NOTIFICATION_TYPE,
      NOTIFICATION_TIMEOUT,
      APPROVER_ID
    from AMS_APPROVERS
    where APPROVER_ID = X_APPROVER_ID
    for update of APPROVER_ID nowait;
begin
  for tlinfo in c1 loop
    if (    (tlinfo.APPROVER_ID = X_APPROVER_ID)
        AND ((tlinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((tlinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
        AND ((tlinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
           OR ((tlinfo.ACTIVE_FLAG is null) AND (X_ACTIVE_FLAG is null)))
        AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((tlinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
        AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
        AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
        --AND ((tlinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
          -- OR ((tlinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
        AND (tlinfo.AMS_APPROVAL_DETAIL_ID = X_AMS_APPROVAL_DETAIL_ID)
        AND ((tlinfo.APPROVER_SEQ = X_APPROVER_SEQ)
           OR ((tlinfo.APPROVER_SEQ is null) AND (X_APPROVER_SEQ is null)))
        AND ((tlinfo.APPROVER_TYPE = X_APPROVER_TYPE)
           OR ((tlinfo.APPROVER_TYPE is null) AND (X_APPROVER_TYPE is null)))
        AND ((tlinfo.OBJECT_APPROVER_ID = X_OBJECT_APPROVER_ID)
           OR ((tlinfo.OBJECT_APPROVER_ID is null) AND (X_OBJECT_APPROVER_ID is null)))
        AND ((tlinfo.NOTIFICATION_TYPE = X_NOTIFICATION_TYPE)
           OR ((tlinfo.NOTIFICATION_TYPE is null) AND (X_NOTIFICATION_TYPE is null)))
        AND ((tlinfo.NOTIFICATION_TIMEOUT = X_NOTIFICATION_TIMEOUT)
           OR ((tlinfo.NOTIFICATION_TIMEOUT is null) AND (X_NOTIFICATION_TIMEOUT is null)))
      ) then
        null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPROVER_ID in NUMBER,
  X_SEEDED_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
 -- X_SECURITY_GROUP_ID in NUMBER,
  X_AMS_APPROVAL_DETAIL_ID in NUMBER,
  X_APPROVER_SEQ in NUMBER,
  X_APPROVER_TYPE in VARCHAR2,
  X_OBJECT_APPROVER_ID in NUMBER,
  X_NOTIFICATION_TYPE in VARCHAR2,
  X_NOTIFICATION_TIMEOUT in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_APPROVERS set
    SEEDED_FLAG = X_SEEDED_FLAG,
    ACTIVE_FLAG = nvl(X_ACTIVE_FLAG, 'Y'),
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    --SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    AMS_APPROVAL_DETAIL_ID = X_AMS_APPROVAL_DETAIL_ID,
    APPROVER_SEQ = X_APPROVER_SEQ,
    APPROVER_TYPE = X_APPROVER_TYPE,
    OBJECT_APPROVER_ID = X_OBJECT_APPROVER_ID,
    NOTIFICATION_TYPE = X_NOTIFICATION_TYPE,
    NOTIFICATION_TIMEOUT = X_NOTIFICATION_TIMEOUT,
    APPROVER_ID = X_APPROVER_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPROVER_ID = X_APPROVER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPROVER_ID in NUMBER
) is
begin
  delete from AMS_APPROVERS
  where APPROVER_ID = X_APPROVER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
   X_APPROVER_ID in NUMBER,
   X_SEEDED_FLAG in VARCHAR2,
   X_ACTIVE_FLAG in VARCHAR2,
   X_START_DATE_ACTIVE in DATE,
   X_END_DATE_ACTIVE in DATE,
   X_OBJECT_VERSION_NUMBER in NUMBER,
   --X_SECURITY_GROUP_ID in NUMBER,
   X_AMS_APPROVAL_DETAIL_ID in NUMBER,
   X_APPROVER_SEQ in NUMBER,
   X_APPROVER_TYPE in VARCHAR2,
   X_OBJECT_APPROVER_ID in NUMBER,
   X_NOTIFICATION_TYPE in VARCHAR2,
   X_NOTIFICATION_TIMEOUT in NUMBER,
   X_OWNER in VARCHAR2
   ) IS
l_user_id number := 0;
l_obj_verno  number;
l_approver_id  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

  cursor  c_obj_verno is
  select object_version_number
  from    AMS_APPROVERS
  where  approver_id =  X_APPROVER_ID;

  cursor c_chk_apr_exists is
  select 'x'
  from    AMS_APPROVERS
  where  approver_id =  X_APPROVER_ID;

  cursor c_get_apr_id is
  select AMS_APPROVERS_S.nextval
  from dual;

BEGIN
    if X_OWNER = 'SEED' then
       l_user_id := 1;
    end if;

    open c_chk_apr_exists;
    fetch c_chk_apr_exists into l_dummy_char;
    if c_chk_apr_exists%notfound
    then
       close c_chk_apr_exists;
       if X_APPROVER_ID is null
       then
          open c_get_apr_id;
          fetch c_get_apr_id into l_approver_id;
          close c_get_apr_id;
       else
          l_approver_id := X_APPROVER_ID;
       end if;
       l_obj_verno := 1;
       AMS_APPROVERS_PKG.INSERT_ROW(
	    X_ROWID  => l_row_id,
	    X_APPROVER_ID => l_approver_id,
	    X_SEEDED_FLAG => X_SEEDED_FLAG,
	    X_ACTIVE_FLAG => X_ACTIVE_FLAG,
	    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
	    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
	    X_OBJECT_VERSION_NUMBER => l_obj_verno,
	    --X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
	    X_AMS_APPROVAL_DETAIL_ID => X_AMS_APPROVAL_DETAIL_ID,
	    X_APPROVER_SEQ => X_APPROVER_SEQ,
	    X_APPROVER_TYPE => X_APPROVER_TYPE,
	    X_OBJECT_APPROVER_ID => X_OBJECT_APPROVER_ID,
	    X_NOTIFICATION_TYPE => X_NOTIFICATION_TYPE,
	    X_NOTIFICATION_TIMEOUT => X_NOTIFICATION_TYPE,
	    X_CREATION_DATE => SYSDATE,
	    X_CREATED_BY => l_user_id,
	    X_LAST_UPDATE_DATE => SYSDATE,
	    X_LAST_UPDATED_BY => l_user_id,
	    X_LAST_UPDATE_LOGIN => 0
	    );
    else
       close c_chk_apr_exists;
       open c_obj_verno;
       fetch c_obj_verno into l_obj_verno;
       close c_obj_verno;
       -- assigning value for l_user_status_id
       l_approver_id := X_APPROVER_ID;
       AMS_APPROVERS_PKG.UPDATE_ROW(
	     X_APPROVER_ID => l_approver_id,
	     X_SEEDED_FLAG => X_SEEDED_FLAG,
	     X_ACTIVE_FLAG => X_ACTIVE_FLAG,
	     X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
	     X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
	     X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
	     --X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
	     X_AMS_APPROVAL_DETAIL_ID => X_AMS_APPROVAL_DETAIL_ID,
	     X_APPROVER_SEQ => X_APPROVER_SEQ,
	     X_APPROVER_TYPE => X_APPROVER_TYPE,
	     X_OBJECT_APPROVER_ID => X_OBJECT_APPROVER_ID,
	     X_NOTIFICATION_TYPE => X_NOTIFICATION_TYPE,
	     X_NOTIFICATION_TIMEOUT => X_NOTIFICATION_TIMEOUT,
	     X_LAST_UPDATE_DATE => SYSDATE,
	     X_LAST_UPDATED_BY => l_user_id,
	     X_LAST_UPDATE_LOGIN => 0
	   );
    END IF;

END LOAD_ROW;

END AMS_APPROVERS_PKG;



/
