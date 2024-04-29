--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE_INFO_TYPES_SEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE_INFO_TYPES_SEC_PKG" as
/* $Header: perpeits.pkb 115.2 2002/12/06 14:11:04 eumenyio noship $ */
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
PROCEDURE UNIQUENESS_CHECK(P_APPLICATION_SHORT_NAME     VARCHAR2,
                           P_RESPONSIBILITY_KEY         VARCHAR2,
                           P_INFO_TYPE_TABLE_NAME       VARCHAR2,
                           P_INFORMATION_TYPE           VARCHAR2,
                           P_ROWID                      VARCHAR2)
IS
L_DUMMY1  number;
l_appl_id number;
l_resp_id number;
CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(P_APPLICATION_SHORT_NAME);
CURSOR C_RESP IS
        select responsibility_id
        from fnd_responsibility_vl
        where responsibility_key = P_RESPONSIBILITY_KEY;
CURSOR C1 (c1_p_appl_id number, c1_p_resp_id number) IS
 	select  1
 	from    PER_INFO_TYPE_SECURITY t
        where   t.application_id = c1_p_appl_id
        and     t.responsibility_id = c1_p_resp_id
        and     t.info_type_table_name = P_INFO_TYPE_TABLE_NAME
        and     t.information_type = P_INFORMATION_TYPE
 	and     (P_ROWID        is null
        	 or P_ROWID    <> t.rowid);
BEGIN
 OPEN C_APPL;
 FETCH C_APPL INTO l_appl_id;
 CLOSE C_APPL;
 OPEN C_RESP;
 FETCH C_RESP INTO l_resp_id;
 CLOSE C_RESP;
 OPEN C1(l_appl_id, l_resp_id);
 FETCH C1 INTO L_DUMMY1;
 IF C1%NOTFOUND THEN
  CLOSE C1;
 ELSE
  CLOSE C1;
  hr_utility.set_message('801','HR_7777_DEF_DESCR_EXISTS');
  hr_utility.raise_error;
 END IF;
end UNIQUENESS_CHECK;
--
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_sec_id number;
l_appl_id number;
l_resp_id number;
  cursor C_APPL is
    select application_id
    from fnd_application
    where application_short_name = upper(X_APPLICATION_SHORT_NAME);
  cursor C_RESP is
    select responsibility_id
    from fnd_responsibility_vl
    where responsibility_key = X_RESPONSIBILITY_KEY;
  cursor C_SEC_ID is
    select per_info_type_security_s.nextval
    from sys.dual;
  cursor C is select ROWID from PER_INFO_TYPE_SECURITY
    where application_id = l_appl_id
    and responsibility_id = l_resp_id
    and info_type_table_name = X_INFO_TYPE_TABLE_NAME
    and INFORMATION_TYPE = X_INFORMATION_TYPE
    ;
begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_RESP;
  fetch C_RESP into l_resp_id;
  close C_RESP;
  open C_SEC_ID;
  fetch C_SEC_ID into l_sec_id;
  close C_SEC_ID;
  insert into PER_INFO_TYPE_SECURITY (
    PER_INFO_TYPE_SECURITY_ID,
    APPLICATION_ID,
    RESPONSIBILITY_ID,
    INFO_TYPE_TABLE_NAME,
    INFORMATION_TYPE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    l_sec_id,
    l_appl_id,
    l_resp_id,
    X_INFO_TYPE_TABLE_NAME,
    X_INFORMATION_TYPE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPLICATION_SHORT_NAME VARCHAR2,
  X_RESPONSIBILITY_KEY VARCHAR2,
  X_INFO_TYPE_TABLE_NAME VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
l_appl_id number;
l_resp_id number;
  cursor C_APPL is
    select application_id
    from fnd_application
    where application_short_name = upper(X_APPLICATION_SHORT_NAME);
  cursor C_RESP is
    select responsibility_id
    from fnd_responsibility_vl
    where responsibility_key = X_RESPONSIBILITY_KEY;
  cursor c (c_p_appl_id number, c_p_resp_id number) is select
      INFORMATION_TYPE,
      OBJECT_VERSION_NUMBER
    from PER_INFO_TYPE_SECURITY
    where APPLICATION_ID = c_p_appl_id
    and RESPONSIBILITY_ID = c_p_resp_id
    and INFO_TYPE_TABLE_NAME = X_INFO_TYPE_TABLE_NAME
    and INFORMATION_TYPE = X_INFORMATION_TYPE
    for update of INFORMATION_TYPE nowait;
  recinfo c%rowtype;

begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_RESP;
  fetch C_RESP into l_resp_id;
  close C_RESP;
  open c(l_appl_id, l_resp_id);
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.INFORMATION_TYPE = X_INFORMATION_TYPE)
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2,
  X_INFORMATION_TYPE_NEW in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_appl_id number;
l_resp_id number;
cursor C_APPL is
  select application_id
  from fnd_application
  where application_short_name = X_APPLICATION_SHORT_NAME;
cursor C_RESP is
  select responsibility_id
  from fnd_responsibility_vl
  where responsibility_key = X_RESPONSIBILITY_KEY;
begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_RESP;
  fetch C_RESP into l_resp_id;
  close C_RESP;
  update PER_INFO_TYPE_SECURITY set
    INFORMATION_TYPE = X_INFORMATION_TYPE_NEW,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = l_appl_id
    and RESPONSIBILITY_ID = l_resp_id
    and INFO_TYPE_TABLE_NAME = X_INFO_TYPE_TABLE_NAME
    and INFORMATION_TYPE = X_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_RESPONSIBILITY_KEY  in VARCHAR2,
  X_INFO_TYPE_TABLE_NAME in VARCHAR2,
  X_INFORMATION_TYPE in VARCHAR2
) is
l_appl_id number;
l_resp_id number;
cursor C_APPL is
  select application_id
  from fnd_application
  where application_short_name = X_APPLICATION_SHORT_NAME;
cursor C_RESP is
  select responsibility_id
  from fnd_responsibility_vl
  where responsibility_key = X_RESPONSIBILITY_KEY;
begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_RESP;
  fetch C_RESP into l_resp_id;
  close C_RESP;

  delete from PER_INFO_TYPE_SECURITY
  where APPLICATION_ID = l_appl_id
  and RESPONSIBILITY_ID = l_resp_id
  and INFO_TYPE_TABLE_NAME = X_INFO_TYPE_TABLE_NAME
  and INFORMATION_TYPE = X_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW
  (X_APPLICATION_SHORT_NAME   in varchar2
  ,X_RESPONSIBILITY_KEY       in varchar2
  ,X_INFO_TYPE_TABLE_NAME     in varchar2
  ,X_INFORMATION_TYPE         in varchar2
  ,X_INFORMATION_TYPE_NEW     in varchar2
  ,X_OBJECT_VERSION_NUMBER    in number
  ,X_OWNER                    in varchar2
  )
is
  l_proc                        VARCHAR2(61) := 'PER_PEOPLE_INFO_TYPES_SEC_PKG.LOAD_ROW';
  l_rowid                       rowid;
  l_created_by                  PER_PEOPLE_INFO_types.created_by%TYPE             := 0;
  l_creation_date               PER_PEOPLE_INFO_types.creation_date%TYPE          := SYSDATE;
  l_last_update_date            PER_PEOPLE_INFO_types.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by             PER_PEOPLE_INFO_types.last_updated_by%TYPE         := 0;
  l_last_update_login           PER_PEOPLE_INFO_types.last_update_login%TYPE      := 0;
begin
  -- Translate developer keys to internal parameters
  if X_OWNER = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  end if;
  -- Update or insert row as appropriate
  begin
    UPDATE_ROW
      (X_APPLICATION_SHORT_NAME   => X_APPLICATION_SHORT_NAME
      ,X_RESPONSIBILITY_KEY       => X_RESPONSIBILITY_KEY
      ,X_INFO_TYPE_TABLE_NAME     => X_INFO_TYPE_TABLE_NAME
      ,X_INFORMATION_TYPE         => X_INFORMATION_TYPE
      ,X_INFORMATION_TYPE_NEW     => X_INFORMATION_TYPE
      ,X_OBJECT_VERSION_NUMBER    => X_OBJECT_VERSION_NUMBER
      ,X_LAST_UPDATE_DATE         => l_last_update_date
      ,X_LAST_UPDATED_BY          => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN        => l_last_update_login
      );
  exception
    when no_data_found then
      INSERT_ROW
        (X_ROWID                    => l_rowid
        ,X_APPLICATION_SHORT_NAME   => X_APPLICATION_SHORT_NAME
        ,X_RESPONSIBILITY_KEY       => X_RESPONSIBILITY_KEY
        ,X_INFO_TYPE_TABLE_NAME     => X_INFO_TYPE_TABLE_NAME
        ,X_INFORMATION_TYPE         => X_INFORMATION_TYPE
        ,X_OBJECT_VERSION_NUMBER    => X_OBJECT_VERSION_NUMBER
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );
  end;
--
end LOAD_ROW;

procedure TRANSLATE_ROW
  (X_APPLICATION_SHORT_NAME in varchar2
  ,X_RESPONSIBILITY_KEY  in varchar2
  ,X_INFO_TYPE_TABLE_NAME in varchar2
  ,X_INFORMATION_TYPE in varchar2
  ,X_DESCRIPTION      in varchar2
  ,X_OWNER            in varchar2
  )
is
begin
null;
/*
  UPDATE per_info_type_security
     SET description = X_DESCRIPTION
        ,last_update_date = SYSDATE
        ,last_updated_by = DECODE(X_OWNER,'SEED',1,0)
        ,last_update_login = 0
   WHERE USERENV('LANG')  =  (select language_code from fnd_languages
                            where installed_flag = 'B')
     AND application_id = l_appl_id
     AND responsibility_id = l_resp_id
     AND info_type_table_name = X_INFO_TYPE_TABLE_NAME
     AND information_type = X_INFORMATION_TYPE;
*/
end TRANSLATE_ROW;


END PER_PEOPLE_INFO_TYPES_SEC_PKG;

/
