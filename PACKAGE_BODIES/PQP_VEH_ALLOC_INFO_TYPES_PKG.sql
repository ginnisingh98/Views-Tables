--------------------------------------------------------
--  DDL for Package Body PQP_VEH_ALLOC_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEH_ALLOC_INFO_TYPES_PKG" as
/* $Header: pqpvehalloceit.pkb 120.0 2005/05/29 02:23:27 appldev noship $ */
------------------------------------------------------------------------------
/*
==============================================================================

         03-dec-04      sshetty       Created.
==============================================================================
                                                                            */
------------------------------------------------------------------------------+
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
PROCEDURE UNIQUENESS_CHECK(P_INFORMATION_TYPE           VARCHAR2,
                           P_ACTIVE_INACTIVE_FLAG       VARCHAR2,
                           P_LEGISLATION_CODE           VARCHAR2,
                           P_ROWID                      VARCHAR2,
                           P_DESCRIPTION                VARCHAR2)
IS
L_DUMMY1  number;
CURSOR C1 IS
 	select  1
 	from    pqp_veh_alloc_info_types t
 	where   upper(t.description) =  upper(P_DESCRIPTION)
 	and     nvl(t.legislation_code, nvl(P_LEGISLATION_CODE, 'XXX') )
        	  =  nvl(P_LEGISLATION_CODE, 'XXX')
 	and     (P_ROWID        is null
        	 or P_ROWID    <> t.rowid);
BEGIN
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
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from pqp_veh_alloc_info_types
    where INFORMATION_TYPE = X_INFORMATION_TYPE
    ;
begin
  insert into pqp_veh_alloc_info_types (
    INFORMATION_TYPE,
    ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INFORMATION_TYPE,
    X_ACTIVE_INACTIVE_FLAG,
    X_MULTIPLE_OCCURENCES_FLAG,
    X_LEGISLATION_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_DESCRIPTION,
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
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ACTIVE_INACTIVE_FLAG,
      MULTIPLE_OCCURENCES_FLAG,
      LEGISLATION_CODE,
      OBJECT_VERSION_NUMBER
    from pqp_veh_alloc_info_types
    where INFORMATION_TYPE = X_INFORMATION_TYPE
    for update of INFORMATION_TYPE nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ACTIVE_INACTIVE_FLAG = X_ACTIVE_INACTIVE_FLAG)
      AND (recinfo.MULTIPLE_OCCURENCES_FLAG = X_MULTIPLE_OCCURENCES_FLAG)
      AND ((recinfo.LEGISLATION_CODE = X_LEGISLATION_CODE)
           OR ((recinfo.LEGISLATION_CODE is null) AND (X_LEGISLATION_CODE is null)))
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
  X_INFORMATION_TYPE in VARCHAR2,
  X_ACTIVE_INACTIVE_FLAG in VARCHAR2,
  X_MULTIPLE_OCCURENCES_FLAG in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update pqp_veh_alloc_info_types set
    ACTIVE_INACTIVE_FLAG = X_ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG = X_MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INFORMATION_TYPE = X_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 end UPDATE_ROW;

procedure DELETE_ROW (
  X_INFORMATION_TYPE in VARCHAR2
) is
begin

  delete from pqp_veh_alloc_info_types
  where INFORMATION_TYPE = X_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW
  (X_INFORMATION_TYPE         in varchar2
  ,X_ACTIVE_INACTIVE_FLAG     in varchar2
  ,X_MULTIPLE_OCCURENCES_FLAG in varchar2
  ,X_DESCRIPTION              in varchar2
  ,X_LEGISLATION_CODE         in varchar2
  ,X_OBJECT_VERSION_NUMBER    in number
  ,X_OWNER                    in varchar2
  ,X_LAST_UPDATE_DATE         in date
  )
is
  l_proc                        VARCHAR2(61) := 'pqp_veh_alloc_info_types_PKG.LOAD_ROW';
  l_rowid                       rowid;
  l_created_by                  pqp_veh_alloc_info_types.created_by%TYPE             := 0;
  l_creation_date               pqp_veh_alloc_info_types.creation_date%TYPE          := SYSDATE;
  l_last_update_date            pqp_veh_alloc_info_types.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by             pqp_veh_alloc_info_types.last_updated_by%TYPE         := 0;
  l_last_update_login           pqp_veh_alloc_info_types.last_update_login%TYPE      := 0;
begin
  -- Translate developer keys to internal parameters
  if X_OWNER = 'ORACLE' then
    l_created_by := 2;
    l_last_updated_by := 2;
  end if;
  -- Update or insert row as appropriate
  begin
    UPDATE_ROW
      (X_INFORMATION_TYPE         => X_INFORMATION_TYPE
      ,X_ACTIVE_INACTIVE_FLAG     => X_ACTIVE_INACTIVE_FLAG
      ,X_MULTIPLE_OCCURENCES_FLAG => X_MULTIPLE_OCCURENCES_FLAG
      ,X_DESCRIPTION              => X_DESCRIPTION
      ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
      ,X_OBJECT_VERSION_NUMBER    => X_OBJECT_VERSION_NUMBER
      ,X_LAST_UPDATE_DATE         => X_LAST_UPDATE_DATE --l_last_update_date
      ,X_LAST_UPDATED_BY          => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN        => l_last_update_login
      );
  exception
    when no_data_found then
      INSERT_ROW
        (X_ROWID                    => l_rowid
        ,X_INFORMATION_TYPE         => X_INFORMATION_TYPE
        ,X_ACTIVE_INACTIVE_FLAG     => X_ACTIVE_INACTIVE_FLAG
        ,X_MULTIPLE_OCCURENCES_FLAG => X_MULTIPLE_OCCURENCES_FLAG
        ,X_DESCRIPTION              => X_DESCRIPTION
        ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
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
  (X_INFORMATION_TYPE in varchar2
  ,X_DESCRIPTION      in varchar2
  ,X_OWNER            in varchar2
  )
is
begin
  UPDATE pqp_veh_alloc_info_types
     SET description = X_DESCRIPTION
        ,last_update_date = SYSDATE
        ,last_updated_by = DECODE(X_OWNER,'ORACLE',2,1)
        ,last_update_login = 0
   WHERE USERENV('LANG')  =  (select language_code from fnd_languages
                            where installed_flag = 'B')
     AND information_type = X_INFORMATION_TYPE;
end TRANSLATE_ROW;


END pqp_veh_alloc_info_types_pkg;

/
