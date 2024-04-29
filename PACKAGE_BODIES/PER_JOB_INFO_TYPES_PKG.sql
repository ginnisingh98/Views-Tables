--------------------------------------------------------
--  DDL for Package Body PER_JOB_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_INFO_TYPES_PKG" as
/* $Header: perjobit.pkb 115.3 2002/12/06 13:42:45 eumenyio ship $ */
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
 	from    PER_JOB_INFO_types t
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
  X_REQUEST_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PER_JOB_INFO_TYPES
    where INFORMATION_TYPE = X_INFORMATION_TYPE
    ;
begin
  insert into PER_JOB_INFO_TYPES (
    INFORMATION_TYPE,
    ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE,
    REQUEST_ID,
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
    X_REQUEST_ID,
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
  X_REQUEST_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ACTIVE_INACTIVE_FLAG,
      MULTIPLE_OCCURENCES_FLAG,
      LEGISLATION_CODE,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
    from PER_JOB_INFO_TYPES
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
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
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
  X_REQUEST_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PER_JOB_INFO_TYPES set
    ACTIVE_INACTIVE_FLAG = X_ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG = X_MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    REQUEST_ID = X_REQUEST_ID,
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

  delete from PER_JOB_INFO_TYPES
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
  )
is
  l_proc                        VARCHAR2(61) := 'PER_JOB_INFO_TYPES_PKG.LOAD_ROW';
  l_rowid                       rowid;
  l_request_id                  PER_JOB_INFO_types.request_id%TYPE;
  l_progam_application_id       PER_JOB_INFO_types.program_application_id%TYPE;
  l_program_id                  PER_JOB_INFO_types.program_id%TYPE;
  l_program_update_date         PER_JOB_INFO_types.program_update_date%TYPE;
  l_created_by                  PER_JOB_INFO_types.created_by%TYPE             := 0;
  l_creation_date               PER_JOB_INFO_types.creation_date%TYPE          := SYSDATE;
  l_last_update_date            PER_JOB_INFO_types.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by             PER_JOB_INFO_types.last_updated_by%TYPE         := 0;
  l_last_update_login           PER_JOB_INFO_types.last_update_login%TYPE      := 0;
begin
  -- Translate developer keys to internal parameters
  if X_OWNER = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
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
      ,X_REQUEST_ID               => l_request_id
      ,X_LAST_UPDATE_DATE         => l_last_update_date
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
        ,X_REQUEST_ID               => l_request_id
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
  UPDATE per_job_info_types
     SET description = X_DESCRIPTION
        ,last_update_date = SYSDATE
        ,last_updated_by = DECODE(X_OWNER,'SEED',1,0)
        ,last_update_login = 0
   WHERE USERENV('LANG') = (select language_code from fnd_languages
                            where installed_flag = 'B')
     AND information_type = X_INFORMATION_TYPE;
end TRANSLATE_ROW;


END PER_JOB_INFO_TYPES_PKG;

/
