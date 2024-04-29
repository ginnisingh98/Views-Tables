--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_INFO_TYPES_PKG" as
/* $Header: payetpit.pkb 115.0 2002/12/16 06:25:30 scchakra noship $ */
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
procedure INSERT_ROW (
  P_ROWID                    in out nocopy VARCHAR2,
  P_INFORMATION_TYPE         in VARCHAR2,
  P_ACTIVE_INACTIVE_FLAG     in VARCHAR2,
  P_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  P_LEGISLATION_CODE         in VARCHAR2,
  P_OBJECT_VERSION_NUMBER    in NUMBER,
  P_DESCRIPTION              in VARCHAR2
) is
  cursor C is select ROWID from PAY_ELEMENT_TYPE_INFO_TYPES
    where INFORMATION_TYPE = P_INFORMATION_TYPE;
begin
  --
  insert into PAY_ELEMENT_TYPE_INFO_TYPES
  (
    INFORMATION_TYPE,
    ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION
  )
  values
  (
    P_INFORMATION_TYPE,
    P_ACTIVE_INACTIVE_FLAG,
    P_MULTIPLE_OCCURENCES_FLAG,
    P_LEGISLATION_CODE,
    P_OBJECT_VERSION_NUMBER,
    P_DESCRIPTION
  );
  --
  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  --
end INSERT_ROW;
--
procedure UPDATE_ROW (
  P_INFORMATION_TYPE         in VARCHAR2,
  P_ACTIVE_INACTIVE_FLAG     in VARCHAR2,
  P_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  P_LEGISLATION_CODE         in VARCHAR2,
  P_OBJECT_VERSION_NUMBER    in NUMBER,
  P_DESCRIPTION              in VARCHAR2
) is
begin
  --
  update PAY_ELEMENT_TYPE_INFO_TYPES set
    ACTIVE_INACTIVE_FLAG     = P_ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG = P_MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE         = P_LEGISLATION_CODE,
    OBJECT_VERSION_NUMBER    = P_OBJECT_VERSION_NUMBER,
    DESCRIPTION              = P_DESCRIPTION
  where INFORMATION_TYPE     = P_INFORMATION_TYPE;
  --
  if (sql%notfound) then
    raise no_data_found;
  end if;
  --
end UPDATE_ROW;
--
procedure LOAD_ROW
  (P_INFORMATION_TYPE         in varchar2
  ,P_ACTIVE_INACTIVE_FLAG     in varchar2
  ,P_MULTIPLE_OCCURENCES_FLAG in varchar2
  ,P_DESCRIPTION              in varchar2
  ,P_LEGISLATION_CODE         in varchar2
  ,P_OBJECT_VERSION_NUMBER    in number
  ,P_OWNER                    in varchar2
  )
is
  l_proc               VARCHAR2(61) := 'PAY_ELEMENT_INFO_TYPES_PKG.LOAD_ROW';
  l_rowid              rowid;
begin
  -- Translate developer keys to internal parameters
  if P_OWNER = 'SEED' then
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => 1
      );
  else
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => -1
      );
  end if;
  -- Update or insert row as appropriate
  begin
    UPDATE_ROW
      (P_INFORMATION_TYPE         => P_INFORMATION_TYPE
      ,P_ACTIVE_INACTIVE_FLAG     => P_ACTIVE_INACTIVE_FLAG
      ,P_MULTIPLE_OCCURENCES_FLAG => P_MULTIPLE_OCCURENCES_FLAG
      ,P_DESCRIPTION              => P_DESCRIPTION
      ,P_LEGISLATION_CODE         => P_LEGISLATION_CODE
      ,P_OBJECT_VERSION_NUMBER    => P_OBJECT_VERSION_NUMBER
      );
  exception
    when no_data_found then
      INSERT_ROW
        (P_ROWID                    => l_rowid
        ,P_INFORMATION_TYPE         => P_INFORMATION_TYPE
        ,P_ACTIVE_INACTIVE_FLAG     => P_ACTIVE_INACTIVE_FLAG
        ,P_MULTIPLE_OCCURENCES_FLAG => P_MULTIPLE_OCCURENCES_FLAG
        ,P_DESCRIPTION              => P_DESCRIPTION
        ,P_LEGISLATION_CODE         => P_LEGISLATION_CODE
        ,P_OBJECT_VERSION_NUMBER    => P_OBJECT_VERSION_NUMBER
        );
  end;
  --
end LOAD_ROW;
--
procedure TRANSLATE_ROW
  (P_INFORMATION_TYPE in varchar2
  ,P_DESCRIPTION      in varchar2
  ,P_OWNER            in varchar2
  )
is
begin
  --
  if P_OWNER = 'SEED' then
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => 1
      );
  else
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => -1
      );
  end if;
  --
  update pay_element_type_info_types
     set description = p_description
   where userenv('LANG') = (select language_code from fnd_languages
                            where installed_flag = 'B')
     AND information_type = p_information_type;
  --
end TRANSLATE_ROW;

--
END PAY_ELEMENT_INFO_TYPES_PKG;

/
