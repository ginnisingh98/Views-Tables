--------------------------------------------------------
--  DDL for Package Body FND_GRANTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GRANTS_PKG" as
/* $Header: AFSCGNTB.pls 120.6 2006/04/29 02:28:43 stadepal ship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30):= 'FND_GRANTS_PKG';
  G_LOG_HEAD    CONSTANT VARCHAR2(30):= 'fnd.plsql.FND_GRANTS_PKG.';

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GRANT_GUID in RAW,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_ID in NUMBER,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECGRP_ID in NUMBER default -1,
  X_CTX_RESP_ID in NUMBER default -1,
  X_CTX_RESP_APPL_ID in NUMBER default -1,
  X_CTX_ORG_ID in NUMBER default -1,
  X_NAME in VARCHAR2 default null,
  X_DESCRIPTION in varchar2 default null
) is
  cursor C is select ROWID from FND_GRANTS
    where GRANT_GUID = HEXTORAW(X_GRANT_GUID)
    ;
  -- Bug 5059644. Added an explicit HEXTORAW to improve the performance.
  -- HEXTORAW is added for all grant_guid bindvariables used in FND_GRANTS
  -- SQL statement.

  l_orig_system    varchar2(48) := NULL;
  l_orig_system_id number       := NULL;
  l_instance_pk1_value      varchar2(256);
  l_instance_pk2_value      varchar2(256);
  l_instance_pk3_value      varchar2(256);
  l_instance_pk4_value      varchar2(256);
  l_instance_pk5_value      varchar2(256);
  l_grantee_key             varchar2(240);
  resp_id	number := NULL;
  app_id 	number := NULL;

begin

  /* Figure out how to populate the orig_... columns from the grantee_key*/
  wf_directory.GetRoleOrigSysInfo(
      Role => x_grantee_key,
      Orig_System => l_orig_system,
      Orig_System_Id => l_orig_system_id);


  /* only allowed grantee_key is 'GLOBAL' for grantee_type 'GLOBAL'*/
  if(x_grantee_type = 'GLOBAL') then
    l_grantee_key := 'GLOBAL';
  else
        l_grantee_key := x_grantee_key;
  end if;

  if(x_instance_pk1_value is NULL) then
    l_instance_pk1_value := '*NULL*';
  else
    l_instance_pk1_value := x_instance_pk1_value;
  end if;

  if(x_instance_pk2_value is NULL) then
    l_instance_pk2_value := '*NULL*';
  else
    l_instance_pk2_value := x_instance_pk2_value;
  end if;

  if(x_instance_pk3_value is NULL) then
    l_instance_pk3_value := '*NULL*';
  else
    l_instance_pk3_value := x_instance_pk3_value;
  end if;

  if(x_instance_pk4_value is NULL) then
    l_instance_pk4_value := '*NULL*';
  else
    l_instance_pk4_value := x_instance_pk4_value;
  end if;

  if(x_instance_pk5_value is NULL) then
    l_instance_pk5_value := '*NULL*';
  else
    l_instance_pk5_value := x_instance_pk5_value;
  end if;

  insert into FND_GRANTS (
    GRANT_GUID,
    GRANTEE_TYPE,
    GRANTEE_KEY,
    MENU_ID,
    START_DATE,
    END_DATE,
    OBJECT_ID,
    INSTANCE_TYPE,
    INSTANCE_SET_ID,
    INSTANCE_PK1_VALUE,
    INSTANCE_PK2_VALUE,
    INSTANCE_PK3_VALUE,
    INSTANCE_PK4_VALUE,
    INSTANCE_PK5_VALUE,
    PROGRAM_NAME,
    PROGRAM_TAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PARAMETER1,
    PARAMETER2,
    PARAMETER3,
    PARAMETER4,
    PARAMETER5,
    PARAMETER6,
    PARAMETER7,
    PARAMETER8,
    PARAMETER9,
    PARAMETER10,
    CTX_SECGRP_ID,
    CTX_RESP_ID,
    CTX_RESP_APPL_ID,
    CTX_ORG_ID,
    GRANTEE_ORIG_SYSTEM,
    GRANTEE_ORIG_SYSTEM_ID,
    NAME,
    DESCRIPTION
 ) values (
    X_GRANT_GUID,
    X_GRANTEE_TYPE,
    L_GRANTEE_KEY,
    X_MENU_ID,
    X_START_DATE,
    X_END_DATE,
    X_OBJECT_ID,
    X_INSTANCE_TYPE,
    X_INSTANCE_SET_ID,
    L_INSTANCE_PK1_VALUE,
    L_INSTANCE_PK2_VALUE,
    L_INSTANCE_PK3_VALUE,
    L_INSTANCE_PK4_VALUE,
    L_INSTANCE_PK5_VALUE,
    X_PROGRAM_NAME,
    X_PROGRAM_TAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PARAMETER1,
    X_PARAMETER2,
    X_PARAMETER3,
    X_PARAMETER4,
    X_PARAMETER5,
    X_PARAMETER6,
    X_PARAMETER7,
    X_PARAMETER8,
    X_PARAMETER9,
    X_PARAMETER10,
    X_CTX_SECGRP_ID,
    X_CTX_RESP_ID,
    X_CTX_RESP_APPL_ID,
    X_CTX_ORG_ID,
    l_orig_system,
    l_orig_system_id,
    X_NAME,
    X_DESCRIPTION
  );

  -- Added for Function Security Cache Invalidation Project
  -- bug 3554601 - Only raise the event if it is Function Security not for
  -- Data Security events.
  if ( X_OBJECT_ID = -1 ) then
    fnd_function_security_cache.insert_grant(X_GRANT_GUID, X_GRANTEE_TYPE, L_GRANTEE_KEY);
  end if;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_GRANT_GUID in RAW,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_ID in NUMBER,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECGRP_ID in NUMBER default -1,
  X_CTX_RESP_ID in NUMBER default -1,
  X_CTX_RESP_APPL_ID in NUMBER default -1,
  X_CTX_ORG_ID in NUMBER default -1,
  X_NAME in VARCHAR2 default null,
  X_DESCRIPTION in VARCHAR2 default null
) is
  cursor c is select
      GRANTEE_TYPE,
      GRANTEE_KEY,
      MENU_ID,
      START_DATE,
      END_DATE,
      OBJECT_ID,
      INSTANCE_TYPE,
      INSTANCE_SET_ID,
      INSTANCE_PK1_VALUE,
      INSTANCE_PK2_VALUE,
      INSTANCE_PK3_VALUE,
      INSTANCE_PK4_VALUE,
      INSTANCE_PK5_VALUE,
      PARAMETER1,
      PARAMETER2,
      PARAMETER3,
      PARAMETER4,
      PARAMETER5,
      PARAMETER6,
      PARAMETER7,
      PARAMETER8,
      PARAMETER9,
      PARAMETER10,
      CTX_SECGRP_ID,
      CTX_RESP_ID,
      CTX_RESP_APPL_ID,
      CTX_ORG_ID,
      PROGRAM_NAME,
      PROGRAM_TAG,
      NAME,
      DESCRIPTION
    from FND_GRANTS
    where GRANT_GUID = hextoraw(X_GRANT_GUID)
    for update of GRANT_GUID nowait;
  recinfo c%rowtype;

  l_instance_pk1_value      varchar2(256);
  l_instance_pk2_value      varchar2(256);
  l_instance_pk3_value      varchar2(256);
  l_instance_pk4_value      varchar2(256);
  l_instance_pk5_value      varchar2(256);
  l_grantee_key             varchar2(240);
  resp_id       number := NULL;
  app_id        number := NULL;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  /* only allowed grantee_key is 'GLOBAL' for grantee_type 'GLOBAL'*/
  if(x_grantee_type = 'GLOBAL') then
    l_grantee_key := 'GLOBAL';
  else
    l_grantee_key := x_grantee_key;
  end if;

  if(x_instance_pk1_value is NULL) then
    l_instance_pk1_value := '*NULL*';
  else
    l_instance_pk1_value := x_instance_pk1_value;
  end if;

  if(x_instance_pk2_value is NULL) then
    l_instance_pk2_value := '*NULL*';
  else
    l_instance_pk2_value := x_instance_pk2_value;
  end if;

  if(x_instance_pk3_value is NULL) then
    l_instance_pk3_value := '*NULL*';
  else
    l_instance_pk3_value := x_instance_pk3_value;
  end if;

  if(x_instance_pk4_value is NULL) then
    l_instance_pk4_value := '*NULL*';
  else
    l_instance_pk4_value := x_instance_pk4_value;
  end if;

  if(x_instance_pk5_value is NULL) then
    l_instance_pk5_value := '*NULL*';
  else
    l_instance_pk5_value := x_instance_pk5_value;
  end if;


  if (    (recinfo.GRANTEE_TYPE = X_GRANTEE_TYPE)
      AND (   (recinfo.GRANTEE_KEY = X_GRANTEE_KEY)
           OR (recinfo.GRANTEE_KEY = L_GRANTEE_KEY))
      AND (recinfo.MENU_ID = X_MENU_ID)
      AND (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND (recinfo.OBJECT_ID = X_OBJECT_ID)
      AND (recinfo.INSTANCE_TYPE = X_INSTANCE_TYPE)
      AND ((recinfo.INSTANCE_SET_ID = X_INSTANCE_SET_ID)
           OR ((recinfo.INSTANCE_SET_ID is null)
               AND (X_INSTANCE_SET_ID is null)))
      AND ((recinfo.INSTANCE_PK1_VALUE = L_INSTANCE_PK1_VALUE)
           OR ((recinfo.INSTANCE_PK1_VALUE is null)
               AND (X_INSTANCE_PK1_VALUE is null)))
      AND ((recinfo.INSTANCE_PK2_VALUE = L_INSTANCE_PK2_VALUE)
           OR ((recinfo.INSTANCE_PK2_VALUE is null)
               AND (X_INSTANCE_PK2_VALUE is null)))
      AND ((recinfo.INSTANCE_PK3_VALUE = L_INSTANCE_PK3_VALUE)
           OR ((recinfo.INSTANCE_PK3_VALUE is null)
               AND (X_INSTANCE_PK3_VALUE is null)))
      AND ((recinfo.INSTANCE_PK4_VALUE = L_INSTANCE_PK4_VALUE)
           OR ((recinfo.INSTANCE_PK4_VALUE is null)
               AND (X_INSTANCE_PK4_VALUE is null)))
      AND ((recinfo.INSTANCE_PK5_VALUE = L_INSTANCE_PK5_VALUE)
           OR ((recinfo.INSTANCE_PK5_VALUE is null)
               AND (X_INSTANCE_PK5_VALUE is null)))
      AND ((recinfo.PROGRAM_NAME = X_PROGRAM_NAME)
           OR ((recinfo.PROGRAM_NAME is null) AND (X_PROGRAM_NAME is null)))
      AND ((recinfo.PROGRAM_TAG = X_PROGRAM_TAG)
           OR ((recinfo.PROGRAM_TAG is null) AND (X_PROGRAM_TAG is null)))
      AND ((recinfo.PARAMETER1 = X_PARAMETER1)
           OR ((recinfo.PARAMETER1 is null) AND (X_PARAMETER1 is null)))
      AND ((recinfo.PARAMETER2 = X_PARAMETER2)
           OR ((recinfo.PARAMETER2 is null) AND (X_PARAMETER2 is null)))
      AND ((recinfo.PARAMETER3 = X_PARAMETER3)
           OR ((recinfo.PARAMETER3 is null) AND (X_PARAMETER3 is null)))
      AND ((recinfo.PARAMETER4 = X_PARAMETER4)
           OR ((recinfo.PARAMETER4 is null) AND (X_PARAMETER4 is null)))
      AND ((recinfo.PARAMETER5 = X_PARAMETER5)
           OR ((recinfo.PARAMETER5 is null) AND (X_PARAMETER5 is null)))
      AND ((recinfo.PARAMETER6 = X_PARAMETER6)
           OR ((recinfo.PARAMETER6 is null) AND (X_PARAMETER6 is null)))
      AND ((recinfo.PARAMETER7 = X_PARAMETER7)
           OR ((recinfo.PARAMETER7 is null) AND (X_PARAMETER7 is null)))
      AND ((recinfo.PARAMETER8 = X_PARAMETER8)
           OR ((recinfo.PARAMETER8 is null) AND (X_PARAMETER8 is null)))
      AND ((recinfo.PARAMETER9 = X_PARAMETER9)
           OR ((recinfo.PARAMETER9 is null) AND (X_PARAMETER9 is null)))
      AND ((recinfo.PARAMETER10 = X_PARAMETER10)
           OR ((recinfo.PARAMETER10 is null) AND (X_PARAMETER10 is null)))
      AND ((recinfo.CTX_SECGRP_ID = X_CTX_SECGRP_ID)
           OR ((recinfo.CTX_SECGRP_ID is null) AND (X_CTX_SECGRP_ID is null)))
      AND ((recinfo.CTX_RESP_ID = X_CTX_RESP_ID)
           OR ((recinfo.CTX_RESP_ID is null) AND (X_CTX_RESP_ID is null)))
      AND ((recinfo.CTX_RESP_APPL_ID = X_CTX_RESP_APPL_ID)
           OR ((recinfo.CTX_RESP_APPL_ID is null)
               AND (X_CTX_RESP_APPL_ID is null)))
      AND ((recinfo.CTX_ORG_ID = X_CTX_ORG_ID)
           OR ((recinfo.CTX_ORG_ID is null) AND (X_CTX_ORG_ID is null)))
      AND ((recinfo.NAME = X_NAME)
           OR ((recinfo.NAME is null) AND (X_NAME is null)))
      AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_GRANT_GUID in RAW,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_ID in NUMBER,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECGRP_ID in NUMBER default -1,
  X_CTX_RESP_ID in NUMBER default -1,
  X_CTX_RESP_APPL_ID in NUMBER default -1,
  X_CTX_ORG_ID in NUMBER default -1,
  X_NAME in VARCHAR2 default '*NOTPASSED*',
  X_DESCRIPTION in VARCHAR2 default '*NOTPASSED*'
) is

  l_orig_system    varchar2(48) := NULL;
  l_orig_system_id number       := NULL;
  l_instance_pk1_value      varchar2(256);
  l_instance_pk2_value      varchar2(256);
  l_instance_pk3_value      varchar2(256);
  l_instance_pk4_value      varchar2(256);
  l_instance_pk5_value      varchar2(256);
  l_grantee_key             varchar2(240);
  resp_id       number := NULL;
  app_id        number := NULL;

begin

  /* Figure out how to populate the orig_... columns from the grantee_key*/
  wf_directory.GetRoleOrigSysInfo(
      Role => x_grantee_key,
      Orig_System => l_orig_system,
      Orig_System_Id => l_orig_system_id);


  /* only allowed grantee_key is 'GLOBAL' for grantee_type 'GLOBAL'*/
  if(x_grantee_type = 'GLOBAL') then
    l_grantee_key := 'GLOBAL';
  else
    l_grantee_key := x_grantee_key;
  end if;

 if(x_instance_pk1_value is NULL) then
    l_instance_pk1_value := '*NULL*';
  else
    l_instance_pk1_value := x_instance_pk1_value;
  end if;

  if(x_instance_pk2_value is NULL) then
    l_instance_pk2_value := '*NULL*';
  else
    l_instance_pk2_value := x_instance_pk2_value;
  end if;

  if(x_instance_pk3_value is NULL) then
    l_instance_pk3_value := '*NULL*';
  else
    l_instance_pk3_value := x_instance_pk3_value;
  end if;

  if(x_instance_pk4_value is NULL) then
    l_instance_pk4_value := '*NULL*';
  else
    l_instance_pk4_value := x_instance_pk4_value;
  end if;

  if(x_instance_pk5_value is NULL) then
    l_instance_pk5_value := '*NULL*';
  else
    l_instance_pk5_value := x_instance_pk5_value;
  end if;

  if((x_name = '*NOTPASSED*') or (x_description = '*NOTPASSED*')) then

    if ((x_name is NULL) or (x_description is NULL)) then
     /* Mixing NULL with *NOTPASSED* not allowed. */
     fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
     fnd_message.set_token('REASON',
            'UPDATE_ROW caller mixed NULL with *NOTPASSED* on grant guid:'
            ||X_GRANT_GUID);
     app_exception.raise_exception;
    end if;

    /* First version of update does not include name, description */
    update FND_GRANTS set
      GRANTEE_TYPE = X_GRANTEE_TYPE,
      GRANTEE_KEY = L_GRANTEE_KEY,
      MENU_ID = X_MENU_ID,
      START_DATE = X_START_DATE,
      END_DATE = X_END_DATE,
      OBJECT_ID = X_OBJECT_ID,
      INSTANCE_TYPE = X_INSTANCE_TYPE,
      INSTANCE_SET_ID = X_INSTANCE_SET_ID,
      INSTANCE_PK1_VALUE = L_INSTANCE_PK1_VALUE,
      INSTANCE_PK2_VALUE = L_INSTANCE_PK2_VALUE,
      INSTANCE_PK3_VALUE = L_INSTANCE_PK3_VALUE,
      INSTANCE_PK4_VALUE = L_INSTANCE_PK4_VALUE,
      INSTANCE_PK5_VALUE = L_INSTANCE_PK5_VALUE,
      PARAMETER1 = X_PARAMETER1,
      PARAMETER2 = X_PARAMETER2,
      PARAMETER3 = X_PARAMETER3,
      PARAMETER4 = X_PARAMETER4,
      PARAMETER5 = X_PARAMETER5,
      PARAMETER6 = X_PARAMETER6,
      PARAMETER7 = X_PARAMETER7,
      PARAMETER8 = X_PARAMETER8,
      PARAMETER9 = X_PARAMETER9,
      PARAMETER10 = X_PARAMETER10,
      CTX_SECGRP_ID = X_CTX_SECGRP_ID,
      CTX_RESP_ID = X_CTX_RESP_ID,
      CTX_RESP_APPL_ID = X_CTX_RESP_APPL_ID,
      CTX_ORG_ID = X_CTX_ORG_ID,
      PROGRAM_NAME = X_PROGRAM_NAME,
      PROGRAM_TAG = X_PROGRAM_TAG,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      GRANTEE_ORIG_SYSTEM = l_orig_system,
      GRANTEE_ORIG_SYSTEM_ID = l_orig_system_id
    where GRANT_GUID = hextoraw(X_GRANT_GUID);
  else
    /* Second version of update includes name, description */
    update FND_GRANTS set
      GRANTEE_TYPE = X_GRANTEE_TYPE,
      GRANTEE_KEY = L_GRANTEE_KEY,
      MENU_ID = X_MENU_ID,
      START_DATE = X_START_DATE,
      END_DATE = X_END_DATE,
      OBJECT_ID = X_OBJECT_ID,
      INSTANCE_TYPE = X_INSTANCE_TYPE,
      INSTANCE_SET_ID = X_INSTANCE_SET_ID,
      INSTANCE_PK1_VALUE = L_INSTANCE_PK1_VALUE,
      INSTANCE_PK2_VALUE = L_INSTANCE_PK2_VALUE,
      INSTANCE_PK3_VALUE = L_INSTANCE_PK3_VALUE,
      INSTANCE_PK4_VALUE = L_INSTANCE_PK4_VALUE,
      INSTANCE_PK5_VALUE = L_INSTANCE_PK5_VALUE,
      PARAMETER1 = X_PARAMETER1,
      PARAMETER2 = X_PARAMETER2,
      PARAMETER3 = X_PARAMETER3,
      PARAMETER4 = X_PARAMETER4,
      PARAMETER5 = X_PARAMETER5,
      PARAMETER6 = X_PARAMETER6,
      PARAMETER7 = X_PARAMETER7,
      PARAMETER8 = X_PARAMETER8,
      PARAMETER9 = X_PARAMETER9,
      PARAMETER10 = X_PARAMETER10,
      CTX_SECGRP_ID = X_CTX_SECGRP_ID,
      CTX_RESP_ID = X_CTX_RESP_ID,
      CTX_RESP_APPL_ID = X_CTX_RESP_APPL_ID,
      CTX_ORG_ID = X_CTX_ORG_ID,
      PROGRAM_NAME = X_PROGRAM_NAME,
      PROGRAM_TAG = X_PROGRAM_TAG,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      GRANTEE_ORIG_SYSTEM = l_orig_system,
      GRANTEE_ORIG_SYSTEM_ID = l_orig_system_id,
      NAME = x_name,
      DESCRIPTION = x_description
    where GRANT_GUID = hextoraw(X_GRANT_GUID);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  else
    -- Added for Function Security Cache Invalidation Project
    -- bug 3554601 - Only raise the event if it is Function Security not for
    -- Data Security events.
    if ( X_OBJECT_ID = -1 ) then
      fnd_function_security_cache.update_grant(X_GRANT_GUID, X_GRANTEE_TYPE, L_GRANTEE_KEY);
    end if;
  end if;

end UPDATE_ROW;

/* Overloaded version below.  Use that; this is the obsolete form. */
procedure LOAD_ROW (
  X_GRANT_GUID in VARCHAR2,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_START_DATE in VARCHAR2,
  X_END_DATE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin

fnd_grants_pkg.LOAD_ROW (
  X_GRANT_GUID => X_GRANT_GUID,
  X_GRANTEE_TYPE => X_GRANTEE_TYPE,
  X_GRANTEE_KEY => X_GRANTEE_KEY,
  X_MENU_NAME => X_MENU_NAME,
  X_START_DATE => X_START_DATE,
  X_END_DATE => X_END_DATE,
  X_OBJ_NAME => X_OBJ_NAME,
  X_INSTANCE_TYPE => X_INSTANCE_TYPE,
  X_INSTANCE_SET_NAME => X_INSTANCE_SET_NAME,
  X_INSTANCE_PK1_VALUE => X_INSTANCE_PK1_VALUE,
  X_INSTANCE_PK2_VALUE => X_INSTANCE_PK2_VALUE,
  X_INSTANCE_PK3_VALUE => X_INSTANCE_PK3_VALUE,
  X_INSTANCE_PK4_VALUE => X_INSTANCE_PK4_VALUE,
  X_INSTANCE_PK5_VALUE => X_INSTANCE_PK5_VALUE,
  X_PROGRAM_NAME => X_PROGRAM_NAME,
  X_PROGRAM_TAG => X_PROGRAM_TAG,
  X_OWNER => X_OWNER,
  X_CUSTOM_MODE => X_CUSTOM_MODE,
  X_LAST_UPDATE_DATE => null
);
end LOAD_ROW;

/* Overloaded version above.  This is the new version.  Use this. */
procedure LOAD_ROW (
  X_GRANT_GUID in VARCHAR2,
  X_GRANTEE_TYPE in VARCHAR2,
  X_GRANTEE_KEY in VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_START_DATE in VARCHAR2,
  X_END_DATE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_TYPE in VARCHAR2,
  X_INSTANCE_SET_NAME in VARCHAR2,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_PROGRAM_NAME in VARCHAR2,
  X_PROGRAM_TAG in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_PARAMETER1 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER2 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER3 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER4 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER5 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER6 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER7 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER8 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER9 IN VARCHAR2 DEFAULT NULL,
  X_PARAMETER10 IN VARCHAR2 DEFAULT NULL,
  X_CTX_SECURITY_GROUP_KEY in VARCHAR2 default '*GLOBAL*',
  X_CTX_RESP_KEY in VARCHAR2 default '*GLOBAL*',
  X_CTX_RESP_APP_SHORT_NAME in VARCHAR2 default '*GLOBAL*',
  X_CTX_ORGANIZATION in VARCHAR2 default '*GLOBAL*',
  X_NAME in VARCHAR2 default '*NOTPASSED*',
  X_DESCRIPTION in VARCHAR2 default '*NOTPASSED*'
) is
  obj_id number := NULL;
  mnu_id number := NULL;
  ins_set_id number := NULL;
  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  secgrp_id number    := -1;
  resp_id   number    := -1;
  respl_id   number    := -1;
  resp_appl_id number := -1;
  org_id    number    := -1;
  l_instance_pk1_value      varchar2(256);
  l_instance_pk2_value      varchar2(256);
  l_instance_pk3_value      varchar2(256);
  l_instance_pk4_value      varchar2(256);
  l_instance_pk5_value      varchar2(256);
  l_grantee_key             varchar2(240);
  l_name                    varchar2(80);
  l_description             varchar2(320);
  app_id        number := NULL;

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  -- object_name and menu_name have reference command in afsload.lct
  -- So we don't have to worry about whether it is valid or not because

  if (X_OBJ_NAME is not NULL) then
    if (X_OBJ_NAME = 'GLOBAL') then
      obj_id := -1;
    else
      begin
        select object_id
        into obj_id
        from fnd_objects
        where obj_name = X_OBJ_NAME;
      exception
        when no_data_found then
          obj_id := NULL;
      end;
    end if;
    if (obj_id is NULL) then
       FND_MESSAGE.SET_NAME('FND', 'SQL_NO_DATA_FOUND');
       FND_MESSAGE.SET_TOKEN('VALUE', X_OBJ_NAME);
       FND_MESSAGE.SET_TOKEN('COLUMN', 'OBJ_NAME');
       FND_MESSAGE.SET_TOKEN('TABLE', 'FND_OBJECTS');
       app_exception.raise_exception;
    end if;
  else
    obj_id := NULL;
  end if;

  if (X_MENU_NAME is not NULL) then
    begin
      select menu_id
      into mnu_id
      from fnd_menus
      where menu_name = X_MENU_NAME;
    exception
      when no_data_found then
        mnu_id := NULL;
    end;
    if (mnu_id is NULL) then
       FND_MESSAGE.SET_NAME('FND', 'SQL_NO_DATA_FOUND');
       FND_MESSAGE.SET_TOKEN('VALUE', X_MENU_NAME);
       FND_MESSAGE.SET_TOKEN('COLUMN', 'MENU_NAME');
       FND_MESSAGE.SET_TOKEN('TABLE', 'FND_MENUS');
       app_exception.raise_exception;
    end if;
  else
    mnu_id := NULL;
  end if;


  if (X_INSTANCE_SET_NAME is not NULL) then
    begin
      select instance_set_id
      into ins_set_id
      from fnd_object_instance_sets
      where instance_set_name = X_INSTANCE_SET_NAME;
    exception
      when no_data_found then
        ins_set_id := NULL;
    end;
    if (ins_set_id is NULL) then
       FND_MESSAGE.SET_NAME('FND', 'SQL_NO_DATA_FOUND');
       FND_MESSAGE.SET_TOKEN('VALUE', X_INSTANCE_SET_NAME);
       FND_MESSAGE.SET_TOKEN('COLUMN', 'INSTANCE_SET_NAME');
       FND_MESSAGE.SET_TOKEN('TABLE', 'FND_OBJECT_INSTANCE_SETS');
       app_exception.raise_exception;
    end if;
  else
    ins_set_id := NULL;
  end if;


  if((X_CTX_SECURITY_GROUP_KEY is not NULL)
     AND (X_CTX_SECURITY_GROUP_KEY <> '*GLOBAL*'))then
    begin
     select security_group_id into secgrp_id
       from   fnd_security_groups
      where  security_group_key = X_CTX_SECURITY_GROUP_KEY;
    exception
      when no_data_found then
        secgrp_id := -1;
    end;
    if (secgrp_id = -1) then
       FND_MESSAGE.SET_NAME('FND', 'SQL_NO_DATA_FOUND');
       FND_MESSAGE.SET_TOKEN('VALUE', X_CTX_SECURITY_GROUP_KEY);
       FND_MESSAGE.SET_TOKEN('COLUMN', 'SECURITY_GROUP_KEY');
       FND_MESSAGE.SET_TOKEN('TABLE', 'FND_SECURITY_GROUPS');
       app_exception.raise_exception;
    end if;
  else
     secgrp_id := -1;
  end if;

  if((X_CTX_RESP_APP_SHORT_NAME is not NULL)
     AND (X_CTX_RESP_APP_SHORT_NAME <> '*GLOBAL*'))then
    begin
      select application_id into resp_appl_id
        from   fnd_application
       where  application_short_name = X_CTX_RESP_APP_SHORT_NAME;
    exception
      when no_data_found then
        resp_appl_id := -1;
    end;
    if (resp_appl_id = -1) then
       FND_MESSAGE.SET_NAME('FND', 'SQL_NO_DATA_FOUND');
       FND_MESSAGE.SET_TOKEN('VALUE', X_CTX_RESP_APP_SHORT_NAME);
       FND_MESSAGE.SET_TOKEN('COLUMN', 'APPLICATION_SHORT_NAME');
       FND_MESSAGE.SET_TOKEN('TABLE', 'FND_APPLICATION');
       app_exception.raise_exception;
    end if;
  else
     resp_appl_id := -1;
  end if;

  if((X_CTX_RESP_KEY is not NULL)
     AND (X_CTX_RESP_KEY <> '*GLOBAL*'))then
    begin
      select responsibility_id into resp_id
        from   fnd_responsibility
       where  responsibility_key = X_CTX_RESP_KEY
         and  application_id = resp_appl_id;
    exception
      when no_data_found then
        resp_id := -1;
    end;
    if (resp_id = -1) then
       FND_MESSAGE.SET_NAME('FND', 'SQL_NO_DATA_FOUND');
       FND_MESSAGE.SET_TOKEN('VALUE', X_CTX_RESP_KEY);
       FND_MESSAGE.SET_TOKEN('COLUMN', 'RESPONSIBILITY_KEY');
       FND_MESSAGE.SET_TOKEN('TABLE', 'FND_RESPONSIBILITY');
       app_exception.raise_exception;
    end if;
  else
     resp_id := -1;
  end if;

  if((X_CTX_ORGANIZATION is not NULL)
     AND (X_CTX_ORGANIZATION <> '*GLOBAL*'))then
     org_id := to_number(X_CTX_ORGANIZATION);
  else
     org_id := -1;
  end if;

  /* only allowed grantee_key is 'GLOBAL' for grantee_type 'GLOBAL'*/
  if(x_grantee_type = 'GLOBAL') then
    l_grantee_key := 'GLOBAL';
  else
   if ((instr(x_grantee_key, 'FND_RESP')= 1) and (instr(x_grantee_key,'FND_RESP|')=0))
    then
     app_id := to_number(substr(x_grantee_key, 9, instr(x_grantee_key, ':')-9));
     respl_id := to_number(substr(x_grantee_key, instr(x_grantee_key, ':')+1));
     l_grantee_key := fnd_user_resp_groups_api.upgrade_resp_role(respl_id, app_id);
     else
        l_grantee_key := x_grantee_key;
     end if;
  end if;

  if(x_instance_pk1_value is NULL) then
    l_instance_pk1_value := '*NULL*';
  else
    l_instance_pk1_value := x_instance_pk1_value;
  end if;

  if(x_instance_pk2_value is NULL) then
    l_instance_pk2_value := '*NULL*';
  else
    l_instance_pk2_value := x_instance_pk2_value;
  end if;

  if(x_instance_pk3_value is NULL) then
    l_instance_pk3_value := '*NULL*';
  else
    l_instance_pk3_value := x_instance_pk3_value;
  end if;

  if(x_instance_pk4_value is NULL) then
    l_instance_pk4_value := '*NULL*';
  else
    l_instance_pk4_value := x_instance_pk4_value;
  end if;

  if(x_instance_pk5_value is NULL) then
    l_instance_pk5_value := '*NULL*';
  else
    l_instance_pk5_value := x_instance_pk5_value;
  end if;


  /* If there isn't yet any row, this will raise a no_data_found*/
  /* exception and a new row will get inserted. */
  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from fnd_grants
  where grant_guid = hextoraw(X_GRANT_GUID);

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    FND_GRANTS_PKG.UPDATE_ROW(
      X_GRANT_GUID => hextoraw(X_GRANT_GUID),
      X_GRANTEE_TYPE => X_GRANTEE_TYPE,
      X_GRANTEE_KEY => L_GRANTEE_KEY,
      X_MENU_ID => mnu_id,
      X_START_DATE => to_date(X_START_DATE, 'YYYY/MM/DD'),
      X_END_DATE => to_date(X_END_DATE, 'YYYY/MM/DD'),
      X_OBJECT_ID => obj_id,
      X_INSTANCE_TYPE => X_INSTANCE_TYPE,
      X_INSTANCE_SET_ID => ins_set_id,
      X_INSTANCE_PK1_VALUE => L_INSTANCE_PK1_VALUE,
      X_INSTANCE_PK2_VALUE => L_INSTANCE_PK2_VALUE,
      X_INSTANCE_PK3_VALUE => L_INSTANCE_PK3_VALUE,
      X_INSTANCE_PK4_VALUE => L_INSTANCE_PK4_VALUE,
      X_INSTANCE_PK5_VALUE => L_INSTANCE_PK5_VALUE,
      X_PARAMETER1 => X_PARAMETER1,
      X_PARAMETER2 => X_PARAMETER2,
      X_PARAMETER3 => X_PARAMETER3,
      X_PARAMETER4 => X_PARAMETER4,
      X_PARAMETER5 => X_PARAMETER5,
      X_PARAMETER6 => X_PARAMETER6,
      X_PARAMETER7 => X_PARAMETER7,
      X_PARAMETER8 => X_PARAMETER8,
      X_PARAMETER9 => X_PARAMETER9,
      X_PARAMETER10 => X_PARAMETER10,
      X_CTX_SECGRP_ID => secgrp_id,
      X_CTX_RESP_ID => resp_id,
      X_CTX_RESP_APPL_ID => resp_appl_id,
      X_CTX_ORG_ID => org_id,
      X_PROGRAM_NAME => X_PROGRAM_NAME,
      X_PROGRAM_TAG => X_PROGRAM_TAG,
      X_LAST_UPDATE_DATE => f_ludate,
      X_LAST_UPDATED_BY => f_luby,
      X_LAST_UPDATE_LOGIN => 0,
      X_NAME => x_name,
      X_DESCRIPTION => x_description);
  end if;

exception
  when NO_DATA_FOUND then
    if (obj_id is not null and
        mnu_id is not null) then

    if(x_name = '*NOTPASSED*') then
      l_name := NULL;
    else
      l_name := x_name;
    end if;

    if(x_description = '*NOTPASSED*') then
      l_description := NULL;
    else
      l_description := x_description;
    end if;


    FND_GRANTS_PKG.INSERT_ROW(
    X_ROWID => row_id,
    X_GRANT_GUID => hextoraw(X_GRANT_GUID),
    X_GRANTEE_TYPE => X_GRANTEE_TYPE,
    X_GRANTEE_KEY => L_GRANTEE_KEY,
    X_MENU_ID => mnu_id,
    X_START_DATE => to_date(X_START_DATE, 'YYYY/MM/DD'),
    X_END_DATE => to_date(X_END_DATE, 'YYYY/MM/DD'),
    X_OBJECT_ID => obj_id,
    X_INSTANCE_TYPE => X_INSTANCE_TYPE,
    X_INSTANCE_SET_ID => ins_set_id,
    X_INSTANCE_PK1_VALUE => L_INSTANCE_PK1_VALUE,
    X_INSTANCE_PK2_VALUE => L_INSTANCE_PK2_VALUE,
    X_INSTANCE_PK3_VALUE => L_INSTANCE_PK3_VALUE,
    X_INSTANCE_PK4_VALUE => L_INSTANCE_PK4_VALUE,
    X_INSTANCE_PK5_VALUE => L_INSTANCE_PK5_VALUE,
    X_PARAMETER1 => X_PARAMETER1,
    X_PARAMETER2 => X_PARAMETER2,
    X_PARAMETER3 => X_PARAMETER3,
    X_PARAMETER4 => X_PARAMETER4,
    X_PARAMETER5 => X_PARAMETER5,
    X_PARAMETER6 => X_PARAMETER6,
    X_PARAMETER7 => X_PARAMETER7,
    X_PARAMETER8 => X_PARAMETER8,
    X_PARAMETER9 => X_PARAMETER9,
    X_PARAMETER10 => X_PARAMETER10,
    X_CTX_SECGRP_ID => secgrp_id,
    X_CTX_RESP_ID => resp_id,
    X_CTX_RESP_APPL_ID => resp_appl_id,
    X_CTX_ORG_ID => org_id,
    X_PROGRAM_NAME => X_PROGRAM_NAME,
    X_PROGRAM_TAG => X_PROGRAM_TAG,
    X_CREATION_DATE  => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0,
    X_NAME => l_name,
    X_DESCRIPTION =>l_description
    );
    else
     -- Data corruption. Bad menu or bad instance set or bad object.
     fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
     fnd_message.set_token('REASON',
                  'Error- data corruption for GRANT:'||X_GRANT_GUID);
     app_exception.raise_exception;

    end if;
end LOAD_ROW;

PROCEDURE grant_function
  (
   p_api_version     IN  NUMBER,
   p_menu_name       IN  VARCHAR2,
   p_object_name     IN  VARCHAR2,
   p_instance_type   IN  VARCHAR2,
   p_instance_set_id     IN  NUMBER  DEFAULT NULL,
   p_instance_pk1_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_grantee_type   IN  VARCHAR2 DEFAULT 'USER',
   p_grantee_key    IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   p_program_name   IN  VARCHAR2 DEFAULT NULL,
   p_program_tag    IN  VARCHAR2 DEFAULT NULL,
   x_grant_guid     OUT NOCOPY RAW,
   x_success        OUT NOCOPY VARCHAR, /* Boolean */
   x_errorcode      OUT NOCOPY NUMBER,
   p_parameter1     IN  VARCHAR2 DEFAULT NULL,
   p_parameter2     IN  VARCHAR2 DEFAULT NULL,
   p_parameter3     IN  VARCHAR2 DEFAULT NULL,
   p_parameter4     IN  VARCHAR2 DEFAULT NULL,
   p_parameter5     IN  VARCHAR2 DEFAULT NULL,
   p_parameter6     IN  VARCHAR2 DEFAULT NULL,
   p_parameter7     IN  VARCHAR2 DEFAULT NULL,
   p_parameter8     IN  VARCHAR2 DEFAULT NULL,
   p_parameter9     IN  VARCHAR2 DEFAULT NULL,
   p_parameter10    IN  VARCHAR2 DEFAULT NULL,
   p_ctx_secgrp_id    IN NUMBER default -1,
   p_ctx_resp_id      IN NUMBER default -1,
   p_ctx_resp_appl_id IN NUMBER default -1,
   p_ctx_org_id       IN NUMBER default -1,
   p_name             in VARCHAR2 default null,
   p_description      in VARCHAR2 default null
  ) is

    l_api_name CONSTANT VARCHAR2(30):= 'GRANT_FUNCTION';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version           CONSTANT NUMBER := 1.0;
    l_menu_id              fnd_grants.menu_id%TYPE;
    l_sys_date              DATE := Sysdate;
    l_user_id                number:=fnd_global.user_id;
    l_grant_guid              raw(16);
    l_row_id                varchar2(18) ;
    l_object_id             number;
    l_grantee_key varchar2(240);
    resp_id       number := NULL;
    app_id        number := NULL;

    CURSOR get_menu_id(p_menu_name VARCHAR2)  IS
     SELECT menu_id
      FROM fnd_menus
      WHERE menu_name =p_menu_name;


    CURSOR get_object_id (p_object_name varchar2) is
    select object_id
    from fnd_objects
    where obj_name=p_object_name;
  BEGIN
         x_grant_guid := NULL;
         x_success := FND_API.G_FALSE ;
         x_errorcode:=-1;

         IF NOT FND_API.Compatible_API_Call (l_api_version,
                                p_api_version   ,
                        l_api_name  ,
                        G_PKG_NAME)
         THEN
           if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then

             fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
             fnd_message.set_token('ROUTINE',
                                     G_PKG_NAME||'.'||l_api_name);
             fnd_message.set_token('REASON',
                  'Unsupported version '|| to_char(p_api_version)||
                  ' passed to API; expecting version '||
                  to_char(l_api_version));
             fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                   G_log_head || l_api_name || '.end_bad_api_ver',
                   FALSE);
           end if;
           x_success := FND_API.G_FALSE;
           x_errorcode:=-1;
           return;
         END IF;


     --  Initialize API return status to success
         x_success := FND_API.G_TRUE;


        -- Step 2
        -- get role id for from FND_MENUS
        OPEN get_menu_id(p_menu_name);
        FETCH get_menu_id INTO l_menu_id;
        IF (get_menu_id%NOTFOUND) THEN
          CLOSE  get_menu_id;
          fnd_message.set_name('FND','FND_INVALID_MENU_NAME');
          fnd_msg_pub.ADD; /* Add for backward compatibility because in */
                            /* the past this API put messages on fnd_msg_pub */
                            /* stack.  That's obsolete.  FND_MESSAGE is now */
                            /* used. */
          fnd_message.set_name('FND','FND_INVALID_MENU_NAME');
          x_success := FND_API.G_FALSE ;
          x_errorcode:=1;
          return;
        END IF;
        CLOSE  get_menu_id;

        ---Step 3.
        --- Get object_id from the fnd_objects
        if (p_object_name = 'GLOBAL') then
           l_object_id := -1;
        else
          open get_object_id(p_object_name);
          fetch get_object_id into l_object_id;
          if (get_object_id%NOTFOUND) then
            close get_object_id;
            fnd_message.set_name('FND','FND_INVALID_OBJECT_NAME');
            fnd_msg_pub.ADD; /* Add for backward compatibility because in */
                            /* the past this API put messages on fnd_msg_pub */
                            /* stack.  That's obsolete.  FND_MESSAGE is now */
                            /* used. */
            fnd_message.set_name('FND','FND_INVALID_OBJECT_NAME');
            x_success := FND_API.G_FALSE ;
            x_errorcode:=1;
            return;
          end if ;
          close get_object_id;
        end if;


        -- Step 4.
        -- Insert a row
          select sys_guid()
          into l_grant_guid
          from dual;



          INSERT_ROW (
          X_ROWID  =>l_row_id,
          X_GRANT_GUID =>l_grant_guid,
          X_GRANTEE_TYPE=>p_grantee_type,
          X_GRANTEE_KEY =>p_grantee_key,
          X_menu_id =>l_menu_id,
          X_START_DATE =>p_start_date,
          X_END_DATE =>p_end_date,
          X_OBJECT_ID =>l_object_id,
          X_INSTANCE_TYPE =>p_instance_type,
          x_instance_set_id =>p_instance_set_id,
          X_INSTANCE_PK1_VALUE =>p_instance_PK1_value,
          X_INSTANCE_PK2_VALUE =>p_instance_PK2_value,
          X_INSTANCE_PK3_VALUE =>p_instance_PK3_value,
          X_INSTANCE_PK4_VALUE =>p_instance_PK4_value,
          X_INSTANCE_PK5_VALUE =>p_instance_PK5_value,
          X_PARAMETER1 => P_PARAMETER1,
          X_PARAMETER2 => P_PARAMETER2,
          X_PARAMETER3 => P_PARAMETER3,
          X_PARAMETER4 => P_PARAMETER4,
          X_PARAMETER5 => P_PARAMETER5,
          X_PARAMETER6 => P_PARAMETER6,
          X_PARAMETER7 => P_PARAMETER7,
          X_PARAMETER8 => P_PARAMETER8,
          X_PARAMETER9 => P_PARAMETER9,
          X_PARAMETER10 => P_PARAMETER10,
          X_CTX_SECGRP_ID => P_CTX_SECGRP_ID,
          X_CTX_RESP_ID => P_CTX_RESP_ID,
          X_CTX_RESP_APPL_ID => P_CTX_RESP_APPL_ID,
          X_CTX_ORG_ID => P_CTX_ORG_ID,
          X_PROGRAM_NAME =>p_program_name,
          X_PROGRAM_TAG  =>p_program_tag,
          X_CREATION_DATE =>l_sys_date,
          X_CREATED_BY =>l_user_id,
          X_LAST_UPDATE_DATE =>l_sys_date,
          X_LAST_UPDATED_BY =>l_user_id,
          X_LAST_UPDATE_LOGIN =>l_user_id,
          X_NAME => p_name,
          X_DESCRIPTION => p_description
        ) ;

        x_grant_guid:=l_grant_guid;
        x_success := FND_API.G_TRUE;
        x_errorcode := NULL;

  END grant_function;



  PROCEDURE revoke_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid       IN  raw,
   x_success        OUT NOCOPY VARCHAR2, /* Boolean */
   x_errorcode      OUT NOCOPY NUMBER
  ) is

    l_api_name CONSTANT VARCHAR2(30) := 'revoke_grant';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version           CONSTANT NUMBER := 1.0;


  BEGIN
     x_success := FND_API.G_FALSE ;
         x_errorcode:=-1;

        -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call (l_api_version,
                        p_api_version   ,
                        l_api_name  ,
                        G_PKG_NAME)
       THEN
         if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
             fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
             fnd_message.set_token('ROUTINE',
                                     G_PKG_NAME||'.'||l_api_name);
             fnd_message.set_token('REASON',
                  'Unsupported version '|| to_char(p_api_version)||
                  ' passed to API; expecting version '||
                  to_char(l_api_version));
             fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                   G_log_head || l_api_name || '.end_bad_api_ver',
                   FALSE);
         end if;
         x_success := FND_API.G_FALSE ;
         x_errorcode:=-1;
             return;
       END IF;

           DELETE_ROW ( X_GRANT_GUID=> p_grant_guid);
           x_success := FND_API.G_TRUE;
       x_errorcode:=NULL;

  END revoke_grant;
  ----------------------------------------------------------------------------


  /* Please call overloaded update_grant below.  This version is obsolete */
  PROCEDURE update_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid       IN  raw,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_success        OUT NOCOPY VARCHAR2
  ) is
  begin
        update_grant(p_api_version => p_api_version,
                     p_grant_guid  => p_grant_guid,
                     p_start_date  => p_start_date,
                     p_end_date    => p_end_date,
                     p_name        => '*NOTPASSED*',
                     p_description => '*NOTPASSED*',
                     x_success     => x_success);

  END update_grant;



  /* This is the new version of update_grant for new code to use */
  PROCEDURE update_grant
  (
   p_api_version    IN  NUMBER,
   p_grant_guid       IN  raw,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   p_name           IN  VARCHAR2,
   p_description    IN  VARCHAR2,
   x_success        OUT NOCOPY VARCHAR2
  ) is

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_GRANT';

        -- On addition of any Required parameters the major version needs
        -- to change i.e. for eg. 1.X to 2.X.
        -- On addition of any Optional parameters the minor version needs
        -- to change i.e. for eg. X.6 to X.7.
    l_api_version           CONSTANT NUMBER := 1.0;
    l_grantee_type          VARCHAR2(8);
    l_grantee_key           VARCHAR2(240);
    l_object_id             NUMBER;

  BEGIN
     x_success := FND_API.G_FALSE ;

       -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                 p_api_version  ,
                 l_api_name ,
                 G_PKG_NAME)
         THEN
           if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
             fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
             fnd_message.set_token('ROUTINE',
                                     G_PKG_NAME||'.'||l_api_name);
             fnd_message.set_token('REASON',
                  'Unsupported version '|| to_char(p_api_version)||
                  ' passed to API; expecting version '||
                  to_char(l_api_version));
             fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                   G_log_head || l_api_name || '.end_bad_api_ver',
                   FALSE);
           end if;
       x_success := FND_API.G_FALSE ;
           return;
     END IF;

         if((p_name = '*NOTPASSED*') or (p_description = '*NOTPASSED*')) then

           if ((p_name is NULL) or (p_description is NULL)) then
             /* Mixing NULL with *NOTPASSED* not allowed. */
             fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
             fnd_message.set_token('REASON',
              'UPDATE_GRANT caller mixed NULL with *NOTPASSED* on grant guid:'
              ||P_GRANT_GUID);
             app_exception.raise_exception;
           end if;
           /* Don't update name and description */
           UPDATE   fnd_grants
         SET    start_date=p_start_date,
                end_date=p_end_date
         WHERE grant_guid= hextoraw(p_grant_guid);
         else
           /* This version updates name and description */
           UPDATE   fnd_grants
         SET    start_date=p_start_date,
                end_date=p_end_date,
                        name = p_name,
                        description = p_description
         WHERE grant_guid= hextoraw(p_grant_guid);
         end if;

         -- Added for Function Security Cache Invalidation Project
         -- bug 3554601 added object_id to verify Function Security
         select grantee_type, grantee_key, object_id
         into   l_grantee_type, l_grantee_key, l_object_id
         from   fnd_grants
         where  grant_guid= hextoraw(p_grant_guid);

         -- bug 3554601 - Only raise the event if it is Function Security not for
         -- Data Security events.
         if ( l_object_id = -1 ) then
            fnd_function_security_cache.update_grant(p_grant_guid, l_grantee_type, l_grantee_key);
         end if;

         x_success:=fnd_api.g_true;

  END update_grant;


  ----------------------------------------------------------------------------
  PROCEDURE lock_grant
  (
   p_grant_guid       IN  raw,
   p_menu_id        IN  NUMBER,
   p_object_id      IN  number,
   p_instance_type IN  varchar2,
   p_instance_set_id in number,
   p_instance_pk1_value   IN  VARCHAR2,
   p_instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
   p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
   p_grantee_type    in varchar2 default 'USER',
   p_grantee_key       IN  varchar2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   p_program_name   IN  VARCHAR2,
   p_program_tag    IN  VARCHAR2,
   p_parameter1     IN  VARCHAR2 DEFAULT NULL,
   p_parameter2     IN  VARCHAR2 DEFAULT NULL,
   p_parameter3     IN  VARCHAR2 DEFAULT NULL,
   p_parameter4     IN  VARCHAR2 DEFAULT NULL,
   p_parameter5     IN  VARCHAR2 DEFAULT NULL,
   p_parameter6     IN  VARCHAR2 DEFAULT NULL,
   p_parameter7     IN  VARCHAR2 DEFAULT NULL,
   p_parameter8     IN  VARCHAR2 DEFAULT NULL,
   p_parameter9     IN  VARCHAR2 DEFAULT NULL,
   p_parameter10    IN  VARCHAR2 DEFAULT NULL,
   p_ctx_secgrp_id    IN NUMBER default -1,
   p_ctx_resp_id      IN NUMBER default -1,
   p_ctx_resp_appl_id IN NUMBER default -1,
   p_ctx_org_id       IN NUMBER default -1,
   p_name             IN VARCHAR2 default null,
   p_description      IN VARCHAR2 default null
  ) is
 -- l_object_id  number;
  BEGIN

     LOCK_ROW (
      X_GRANT_GUID =>p_grant_guid,
      X_GRANTEE_TYPE =>p_grantee_type,
      X_GRANTEE_key =>p_grantee_key,
      X_menu_ID =>p_menu_id,
      X_START_DATE =>p_start_date,
      X_END_DATE =>p_end_date,
      X_OBJECT_ID =>p_object_id,
      X_INSTANCE_TYPE =>p_instance_type,
      X_INSTANCE_SET_ID =>p_instance_set_id,
      X_INSTANCE_PK1_VALUE =>p_instance_pk1_value,
      X_INSTANCE_PK2_VALUE =>p_instance_pk2_value,
      X_INSTANCE_PK3_VALUE =>p_instance_pk3_value,
      X_INSTANCE_PK4_VALUE =>p_instance_pk4_value,
      X_INSTANCE_PK5_VALUE =>p_instance_pk5_value,
      X_PROGRAM_NAME =>p_program_name,
      X_PROGRAM_TAG =>p_program_tag,
      X_PARAMETER1 => P_PARAMETER1,
      X_PARAMETER2 => P_PARAMETER2,
      X_PARAMETER3 => P_PARAMETER3,
      X_PARAMETER4 => P_PARAMETER4,
      X_PARAMETER5 => P_PARAMETER5,
      X_PARAMETER6 => P_PARAMETER6,
      X_PARAMETER7 => P_PARAMETER7,
      X_PARAMETER8 => P_PARAMETER8,
      X_PARAMETER9 => P_PARAMETER9,
      X_PARAMETER10 => P_PARAMETER10,
      X_CTX_SECGRP_ID => P_CTX_SECGRP_ID,
      X_CTX_RESP_ID => P_CTX_RESP_ID,
      X_CTX_RESP_APPL_ID => P_CTX_RESP_APPL_ID,
      X_CTX_ORG_ID => P_CTX_ORG_ID,
      X_NAME => P_NAME,
      X_DESCRIPTION => P_DESCRIPTION
    );

 END lock_grant;

procedure DELETE_ROW (
    X_GRANT_GUID in RAW
) is

    l_grantee_type          VARCHAR2(8);
    l_grantee_key           VARCHAR2(240);
    l_object_id             NUMBER;

begin
    -- Pick out the row first, before it gets deleted.
    -- bug 3554601 added object_id to verify Function Security
    select  grantee_type, grantee_key, object_id
    into    l_grantee_type, l_grantee_key, l_object_id
    from    fnd_grants
    where   grant_guid= hextoraw(X_GRANT_GUID);

    delete from FND_GRANTS
    where GRANT_GUID = hextoraw(X_GRANT_GUID);

    if (sql%notfound) then
        raise no_data_found;
    else
        -- Added for Function Security Cache Invalidation Project
        -- bug 3554601 - Only raise the event if it is Function Security not for
        -- Data Security events.
        if ( l_object_id = -1 ) then
          fnd_function_security_cache.delete_grant(X_GRANT_GUID, l_grantee_type, l_grantee_key);
        end if;
    end if;
end DELETE_ROW;


PROCEDURE delete_grant(
                       p_grantee_type        IN VARCHAR2 DEFAULT NULL,
                       p_grantee_key         IN VARCHAR2 DEFAULT NULL,
                       p_object_name         IN VARCHAR2 DEFAULT NULL,
                       p_instance_type       IN VARCHAR2 DEFAULT NULL,
                       p_instance_set_id     IN NUMBER   DEFAULT NULL,
                       p_instance_pk1_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk2_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk3_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk4_value  IN VARCHAR2 DEFAULT NULL,
                       p_instance_pk5_value  IN VARCHAR2 DEFAULT NULL,
                       p_menu_name           IN VARCHAR2 DEFAULT NULL,
                       p_program_name        IN VARCHAR2 DEFAULT NULL,
                       p_program_tag         IN VARCHAR2 DEFAULT NULL,
                       x_success             OUT NOCOPY VARCHAR,
                       x_errcode             OUT NOCOPY NUMBER)IS

    type sql_curs_type is REF CURSOR;     -- bug3625804 Reference cursor type
    del_sql_stmt   VARCHAR2(5000);   -- bug3625804 delete statement
    sel_sql_stmt   VARCHAR2(5000);   -- bug3625804 select statement
    sel_sql_curs   sql_curs_type;    -- bug3625804 sel SQL cursor
    where_clause   VARCHAR2(5000);   -- bug3625804 where clause
    grantee_stmt   VARCHAR2(500);
    object_stmt    VARCHAR2(500);
    l_object_id    NUMBER;
    menu_stmt      VARCHAR2(500);
    l_menu_id      NUMBER;
    program_stmt   VARCHAR2(500);
    l_grant_guid   RAW(16);
    invalid_args   EXCEPTION;

    CURSOR get_menu_id(p_menu_name VARCHAR2) IS
        SELECT menu_id
        FROM FND_MENUS
        WHERE menu_name = p_menu_name;

    CURSOR get_object_id(p_object_name VARCHAR2) IS
        SELECT object_id
        FROM fnd_objects
        WHERE obj_name = p_object_name;

 BEGIN

    IF(p_grantee_type is NULL AND p_object_name is NULL AND p_menu_name IS NULL
       AND p_program_name is NULL) THEN
        fnd_message.set_name('FND','FND_ROUTINE_INVALID_ARGS');
        fnd_message.set_token('ROUTINE',
         'FND_GRANTS_DELETE_PKG.delete_grant()');
        fnd_msg_pub.ADD; /* Add for backward compatibility because in */
                             /* the past this API put messages on fnd_msg_pub */
                             /* stack.  That's obsolete.  FND_MESSAGE is now */
                             /* used. */
        fnd_message.set_name('FND','FND_ROUTINE_INVALID_ARGS');
        fnd_message.set_token('ROUTINE',
         'FND_GRANTS_DELETE_PKG.delete_grant()');
        x_success := 'F';
        x_errcode := -1;
        return;
    END IF;

    -- bug3625804 initialize the delete and select statement

    del_sql_stmt := 'DELETE FROM FND_GRANTS';
    sel_sql_stmt := 'SELECT GRANT_GUID FROM FND_GRANTS';
    where_clause := fnd_global.newline||'WHERE 1=1 ';

    grantee_stmt := fnd_global.newline||'AND grantee_type = '''||
      replace(p_grantee_type, '''', '''''')||''' AND grantee_key = '''||
      replace(p_grantee_key, '''', '''''')||'''';

    IF(p_object_name is NOT NULL ) THEN
        if (p_object_name = 'GLOBAL') then
           l_object_id := -1;
        else
          OPEN get_object_id(p_object_name);
          FETCH get_object_id INTO l_object_id;
          IF(get_object_id%NOTFOUND) THEN
              CLOSE get_object_id;
              fnd_message.set_name('FND','FND_INVALID_OBJECT_NAME');
              fnd_msg_pub.ADD; /* Add for backward compatibility because in */
                             /* the past this API put messages on fnd_msg_pub */
                             /* stack.  That's obsolete.  FND_MESSAGE is now */
                             /* used. */
              fnd_message.set_name('FND','FND_INVALID_OBJECT_NAME');
              x_success := 'F';
              x_errcode := 1;
              return;
          END IF;
         CLOSE get_object_id; 	-- bug5122727 moved to inside of if block
        end if;
        object_stmt := fnd_global.newline||'AND object_id = '||l_object_id||' AND instance_type = '''||replace(p_instance_type, '''', '''''')||'''';

        IF(p_instance_type = 'SET') THEN
            IF(p_instance_set_id IS NOT NULL) THEN
                 object_stmt := object_stmt||
                 ' AND instance_set_id = '||p_instance_set_id;
            END IF;
        ELSIF(p_instance_type = 'INSTANCE') THEN
            IF(p_instance_pk1_value IS NOT NULL) THEN
                 object_stmt := object_stmt||' AND instance_pk1_value = '''||
                   replace(p_instance_pk1_value, '''', '''''')||'''';
            END IF;

            IF(p_instance_pk2_value IS NOT NULL) THEN
                 object_stmt := object_stmt||' AND instance_pk2_value = '''||
                   replace(p_instance_pk2_value, '''', '''''')||'''';
            END IF;

            IF(p_instance_pk3_value IS NOT NULL) THEN
                object_stmt := object_stmt||' AND instance_pk3_value = '''||
                   replace(p_instance_pk3_value, '''', '''''')||'''';
            END IF;

            IF(p_instance_pk4_value IS NOT NULL) THEN
                object_stmt := object_stmt||' AND instance_pk4_value = '''||
                   replace(p_instance_pk4_value, '''', '''''')||'''';
            END IF;

            IF(p_instance_pk5_value IS NOT NULL) THEN
                object_stmt := object_stmt||' AND instance_pk5_value = '''||
                   replace(p_instance_pk5_value, '''', '''''')||'''';
            END IF;
         END IF;
    END IF;
   IF(p_menu_name IS NOT NULL) THEN
        OPEN get_menu_id(p_menu_name);
        FETCH get_menu_id INTO l_menu_id;
        IF(get_menu_id%NOTFOUND) THEN
           CLOSE get_menu_id;
           fnd_message.set_name('FND','FND_INVALID_MENU_NAME');
           fnd_msg_pub.ADD; /* Add for backward compatibility because in */
                             /* the past this API put messages on fnd_msg_pub */
                             /* stack.  That's obsolete.  FND_MESSAGE is now */
                             /* used. */
           fnd_message.set_name('FND','FND_INVALID_MENU_NAME');
           x_success := 'F';
           x_errcode := 1;
           return;
        END IF;
        CLOSE get_menu_id;
        menu_stmt := fnd_global.newline||'AND menu_id = '||l_menu_id;
    END IF;

    program_stmt := fnd_global.newline||'AND program_name = '''||replace(p_program_name, '''', '''''')||'''';

    IF(p_program_tag IS NOT NULL ) THEN
       program_stmt := program_stmt||' AND program_tag = '''||
         replace(p_program_tag, '''', '''''')||'''';
    END IF;

    --bug3625804 - Modified code to build a where clause instead of
    --             the delete SQL as it was before.

    IF(p_grantee_type IS NOT NULL) THEN
       where_clause := where_clause||grantee_stmt;
    END IF;

    IF(p_object_name IS NOT NULL) THEN
       IF(p_grantee_type IS NOT NULL)THEN
          where_clause := where_clause||object_stmt;
       END IF;
    END IF;

    IF(p_menu_name IS NOT NULL) THEN
       IF(p_grantee_type IS NOT NULL or p_object_name IS NOT NULL) THEN
          where_clause := where_clause||menu_stmt;
       END IF;
    END IF;

    IF(p_program_name IS NOT NULL) THEN
       IF(p_grantee_type IS NOT NULL or p_object_name IS NOT NULL
          or p_menu_name IS NOT NULL) THEN
          where_clause := where_clause||program_stmt;
       END IF;
    END IF;

    -- bug3625804 append the built where clause

    del_sql_stmt := del_sql_stmt||where_clause;

    EXECUTE IMMEDIATE del_sql_stmt;

   -- bug3625804 check if function security then create cursor
   --            to select object_id and grant_guid in order
   --            to raise the delete_grant event.

   IF ((p_object_name is NULL ) or (l_object_id = -1)) THEN

      sel_sql_stmt := sel_sql_stmt||where_clause||' and object_id = -1';

      OPEN sel_sql_curs FOR sel_sql_stmt;

      LOOP
        FETCH sel_sql_curs INTO l_grant_guid;
        EXIT when sel_sql_curs%notfound;

       -- Added for Function Security Cache Invalidation Project
       -- bug 3554601 - Only raise the event if it is Function Security not for
       -- Data Security events.
       fnd_function_security_cache.delete_grant(l_grant_guid, p_grantee_type, p_grantee_key);
      END LOOP;
   END IF;
      x_success := 'T';
      x_errcode := NULL;
END delete_grant;


 -- fill_in_orig_columns
 --    This routine is mostly for AOL internal use by this loader itself;
 --    it fills in the columns grantee_orig_system and
 --    grantee_orig_system_id from the grantee_key.
 procedure fill_in_orig_columns(p_grant_guid IN  raw) is

   l_grantee_type   varchar2(8);
   l_grantee_key    varchar2(240);
   l_orig_system    varchar2(48) := NULL;
   l_orig_system_id number       := NULL;
   l_object_id      NUMBER;
 begin
   -- bug 3554601 added object_id to verify Function Security
   select   grantee_type, grantee_key, object_id
   into     l_grantee_type, l_grantee_key, l_object_id
   from fnd_grants
   where grant_guid = hextoraw(p_grant_guid);

  wf_directory.GetRoleOrigSysInfo(
      Role => l_grantee_key,
      Orig_System => l_orig_system,
      Orig_System_Id => l_orig_system_id);

   UPDATE fnd_grants
      SET grantee_orig_system = l_orig_system,
          grantee_orig_system_id = l_orig_system_id
    WHERE grant_guid= hextoraw(p_grant_guid);

    -- Added for Function Security Cache Invalidation Project
    -- bug 3554601 - Only raise the event if it is Function Security not for
    -- Data Security events.
    if ( l_object_id = -1 ) then
      fnd_function_security_cache.update_grant(p_grant_guid, l_grantee_type, l_grantee_key);
    end if;

 end fill_in_orig_columns;

 -- fill_in_missing_orig_columns
 --    This routine is mostly for AOL internal use at upgrade time;
 --    it fills in the columns grantee_orig_system and
 --    grantee_orig_system_id from the grantee_key for all grants that
 --    are missing them.
 --    This should not be called at runtime because every time it runs
 --    it will revisit some rows.
 --    Runtime code should call this package to manipulate the data so
 --    it will automatically keep the orig_ columns in sync without
 --    the need to call this routine.
 procedure fill_in_missing_orig_columns is
   cursor find_missing_cols_c is
     select grant_guid
       from fnd_grants
      where grantee_key is not NULL
        and grantee_orig_system is NULL;
 begin
   for c1 in find_missing_cols_c loop
      fill_in_orig_columns(c1.grant_guid);
   end loop;
 end fill_in_missing_orig_columns;

/* CONVERT_NULLS- For install time use only, not a */
/* runtime routine.  This routine will convert NULL to '*NULL*' in the */
/* columns INSTANCE_PKX_VALUE in the table FND_GRANTS. */
/* The reason for this routine is that we decided to have those columns be */
/* non-NULL in order to speed up queries that go against different numbers */
/* of pk columns.  This should be run once at patch application time and */
/* should never need to be run again.  This will be included in the ATG */
/* data security patch. */
/* returns number of rows converted. */
function CONVERT_NULLS return NUMBER is

 l_grantee_type   varchar2(8);
 l_grantee_key    varchar2(240);

 cursor c1 is
  select grant_guid,
         instance_pk1_value,
         instance_pk2_value,
         instance_pk3_value,
         instance_pk4_value,
         instance_pk5_value
   from fnd_grants
  where    (instance_pk1_value is NULL)
        or (instance_pk2_value is NULL)
        or (instance_pk3_value is NULL)
        or (instance_pk4_value is NULL)
        or (instance_pk5_value is NULL);
  l_pk1 varchar2(256);
  l_pk2 varchar2(256);
  l_pk3 varchar2(256);
  l_pk4 varchar2(256);
  l_pk5 varchar2(256);
  l_guid RAW(16);
  i INTEGER;
  l_object_id NUMBER;
begin
  i := 0;
  for c1rec in c1 loop
    l_pk1 := c1rec.instance_pk1_value;
    l_pk2 := c1rec.instance_pk2_value;
    l_pk3 := c1rec.instance_pk3_value;
    l_pk4 := c1rec.instance_pk4_value;
    l_pk5 := c1rec.instance_pk5_value;
    l_guid := c1rec.grant_guid;

    if(l_pk1 is NULL) then
      l_pk1 := '*NULL*';
    end if;
    if(l_pk2 is NULL) then
      l_pk2 := '*NULL*';
    end if;
    if(l_pk3 is NULL) then
      l_pk3 := '*NULL*';
    end if;
    if(l_pk4 is NULL) then
      l_pk4 := '*NULL*';
    end if;
    if(l_pk5 is NULL) then
      l_pk5 := '*NULL*';
    end if;

    -- bug 3554601 added object_id to verify Function Security
    select  grantee_type, grantee_key, object_id
    into    l_grantee_type, l_grantee_key, l_object_id
    from fnd_grants
    where grant_guid = hextoraw(l_guid);

    update fnd_grants set
       instance_pk1_value = l_pk1,
       instance_pk2_value = l_pk2,
       instance_pk3_value = l_pk3,
       instance_pk4_value = l_pk4,
       instance_pk5_value = l_pk5
    where
       grant_guid = hextoraw(l_guid);

    -- Added for Function Security Cache Invalidation Project
    -- bug 3554601 - Only raise the event if it is Function Security not for
    -- Data Security events.
    if ( l_object_id = -1 ) then
        fnd_function_security_cache.update_grant(l_guid, l_grantee_type, l_grantee_key);
    end if;

    if (mod(i, 100) = 0) then
      commit;
    end if;

    i := i+1;
  end loop;
  commit;
  return i;
end;

end FND_GRANTS_PKG;

/
