--------------------------------------------------------
--  DDL for Package Body PER_RESTR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RESTR_VALUES_PKG" as
/* $Header: perpeprv.pkb 115.3 2002/12/06 14:46:06 eumenyio noship $ */
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
PROCEDURE UNIQUENESS_CHECK(P_APPLICATION_SHORT_NAME     VARCHAR2,
                           P_FORM_NAME              VARCHAR2,
                           P_NAME                   VARCHAR2,
                           P_BUSINESS_GROUP_NAME    VARCHAR2,
                           P_LEGISLATION_CODE       VARCHAR2,
                           P_RESTRICTION_CODE       VARCHAR2,
                           P_VALUE                  VARCHAR2,
                           P_ROWID                  VARCHAR2)
IS
L_DUMMY1  number;
l_appl_id number;
l_cr_id number;
CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(P_APPLICATION_SHORT_NAME);
  cursor C_CR_ID is
    select customized_restriction_id
    from PAY_CUSTOMIZED_RESTRICTIONS pcr
    where
      pcr.application_id = l_appl_id
      and pcr.form_name = P_FORM_NAME
      and pcr.name = P_NAME
      and pcr.legislation_code = P_LEGISLATION_CODE;
CURSOR C1 IS
 	select  1
 	from    PAY_RESTRICTION_VALUES prv
        where   prv.customized_restriction_id = l_cr_id
        and     prv.restriction_code = P_RESTRICTION_CODE
        and     prv.value            = P_VALUE
 	and     (P_ROWID        is null
        	 or P_ROWID    <> prv.rowid);
BEGIN
 OPEN C_APPL;
 FETCH C_APPL INTO l_appl_id;
 CLOSE C_APPL;
 OPEN C_CR_ID;
 FETCH C_CR_ID INTO l_cr_id;
 CLOSE C_CR_ID;
 OPEN C1;
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
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_cr_id number;
l_appl_id number;
  cursor C_APPL is
    select application_id
    from fnd_application
    where application_short_name = upper(X_APPLICATION_SHORT_NAME);
  cursor C_CR_ID is
    select customized_restriction_id
    from PAY_CUSTOMIZED_RESTRICTIONS pcr
    where
      pcr.application_id = l_appl_id
      and pcr.form_name = X_FORM_NAME
      and pcr.name = X_NAME
      and (X_LEGISLATION_CODE is null or
          (X_LEGISLATION_CODE is not null
           and pcr.legislation_code = X_LEGISLATION_CODE));
  cursor C is
    select ROWID
    from PAY_RESTRICTION_VALUES prv
    where prv.customized_restriction_id = l_cr_id
    and     prv.value = X_VALUE
    and     prv.restriction_code = X_RESTRICTION_CODE
    ;
begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_CR_ID;
  fetch C_CR_ID into l_cr_id;
  close C_CR_ID;
  insert into PAY_RESTRICTION_VALUES (
    CUSTOMIZED_RESTRICTION_ID,
    RESTRICTION_CODE,
    VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    l_cr_id,
    X_RESTRICTION_CODE,
    X_VALUE,
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
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
) is
l_appl_id number;
l_cr_id number;
  cursor C_APPL is
    select application_id
    from fnd_application
    where application_short_name = upper(X_APPLICATION_SHORT_NAME);
  cursor C_CR_ID is
    select customized_restriction_id
    from PAY_CUSTOMIZED_RESTRICTIONS pcr
    where
      pcr.application_id = l_appl_id
      and pcr.form_name = X_FORM_NAME
      and pcr.name = X_NAME
      and nvl(pcr.legislation_code,'XXX') = nvl(X_LEGISLATION_CODE,'XXX');
  cursor c is select
    RESTRICTION_CODE,
    VALUE
    from PAY_RESTRICTION_VALUES prv
    where prv.CUSTOMIZED_RESTRICTION_ID = l_cr_id
    and     prv.value = X_VALUE
    and     prv.restriction_code = X_RESTRICTION_CODE
    for update of VALUE nowait;
  recinfo c%rowtype;

begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_CR_ID;
  fetch C_CR_ID into l_cr_id;
  close C_CR_ID;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.RESTRICTION_CODE = X_RESTRICTION_CODE)
      AND (recinfo.VALUE = X_VALUE)
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
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_RESTRICTION_CODE_NEW in VARCHAR2,
  X_VALUE_NEW in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_appl_id number;
l_cr_id number;
cursor C_APPL is
  select application_id
  from fnd_application
  where application_short_name = X_APPLICATION_SHORT_NAME;
  cursor C_CR_ID is
    select customized_restriction_id
    from PAY_CUSTOMIZED_RESTRICTIONS pcr
    where
      pcr.application_id = l_appl_id
      and pcr.form_name = X_FORM_NAME
      and pcr.name = X_NAME
      and nvl(pcr.legislation_code,'XXX') = nvl(X_LEGISLATION_CODE,'XXX');
begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_CR_ID;
  fetch C_CR_ID into l_cr_id;
  close C_CR_ID;
  update PAY_RESTRICTION_VALUES set
    RESTRICTION_CODE = X_RESTRICTION_CODE_NEW ,
    VALUE = X_VALUE_NEW,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CUSTOMIZED_RESTRICTION_ID = l_cr_id
    and     value = X_VALUE
    and     restriction_code = X_RESTRICTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
) is
l_appl_id number;
l_cr_id number;
cursor C_APPL is
  select application_id
  from fnd_application
  where application_short_name = X_APPLICATION_SHORT_NAME;
  cursor C_CR_ID is
    select customized_restriction_id
    from PAY_CUSTOMIZED_RESTRICTIONS pcr
    where
      pcr.application_id = l_appl_id
      and pcr.form_name = X_FORM_NAME
      and pcr.name = X_NAME
      and pcr.legislation_code = X_LEGISLATION_CODE;
begin
  open C_APPL;
  fetch C_APPL into l_appl_id;
  close C_APPL;
  open C_CR_ID;
  fetch C_CR_ID into l_cr_id;
  close C_CR_ID;

  delete from PAY_RESTRICTION_VALUES
  where CUSTOMIZED_RESTRICTION_ID = l_cr_id
    and     value = X_VALUE
    and     restriction_code = X_RESTRICTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW
  (X_APPLICATION_SHORT_NAME   in varchar2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_OWNER in VARCHAR2
  )
is
  l_proc                        VARCHAR2(61) := 'PER_RESTR_VALUES_PKG.LOAD_ROW';
  l_rowid                       rowid;
  l_created_by                  PAY_RESTRICTION_VALUES.created_by%TYPE             := 0;
  l_creation_date               PAY_RESTRICTION_VALUES.creation_date%TYPE          := SYSDATE;
  l_last_update_date            PAY_RESTRICTION_VALUES.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by             PAY_RESTRICTION_VALUES.last_updated_by%TYPE         := 0;
  l_last_update_login           PAY_RESTRICTION_VALUES.last_update_login%TYPE      := 0;
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
      ,X_FORM_NAME                => X_FORM_NAME
      ,X_NAME                     => X_NAME
      ,X_BUSINESS_GROUP_NAME      => X_BUSINESS_GROUP_NAME
      ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
      ,X_RESTRICTION_CODE         => X_RESTRICTION_CODE
      ,X_VALUE                    => X_VALUE
      ,X_RESTRICTION_CODE_NEW     => X_RESTRICTION_CODE
      ,X_VALUE_NEW                => X_VALUE
      ,X_LAST_UPDATE_DATE         => l_last_update_date
      ,X_LAST_UPDATED_BY          => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN        => l_last_update_login
      );
  exception
    when no_data_found then
      INSERT_ROW
        (X_ROWID                    => l_rowid
        ,X_APPLICATION_SHORT_NAME   => X_APPLICATION_SHORT_NAME
        ,X_FORM_NAME                => X_FORM_NAME
        ,X_NAME                     => X_NAME
        ,X_BUSINESS_GROUP_NAME      => X_BUSINESS_GROUP_NAME
        ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
        ,X_RESTRICTION_CODE         => X_RESTRICTION_CODE
        ,X_VALUE                    => X_VALUE
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
  (X_APPLICATION_SHORT_NAME in varchar2,
  X_FORM_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_RESTRICTION_CODE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_OWNER            in varchar2
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


END PER_RESTR_VALUES_PKG;

/
