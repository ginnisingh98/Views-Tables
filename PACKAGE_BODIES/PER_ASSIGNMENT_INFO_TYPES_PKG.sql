--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENT_INFO_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENT_INFO_TYPES_PKG" as
/* $Header: peait01t.pkb 115.3 99/07/17 18:28:42 porting shi $ */
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
 	from    per_assignment_info_types t
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
  X_ROWID in out VARCHAR2,
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
  cursor C is select ROWID from PER_ASSIGNMENT_INFO_TYPES
    where INFORMATION_TYPE = X_INFORMATION_TYPE
    ;
begin
  insert into PER_ASSIGNMENT_INFO_TYPES (
    INFORMATION_TYPE,
    ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE,
    REQUEST_ID,
    OBJECT_VERSION_NUMBER,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PER_ASSIGNMENT_INFO_TYPES_TL (
    INFORMATION_TYPE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INFORMATION_TYPE,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PER_ASSIGNMENT_INFO_TYPES_TL T
    where T.INFORMATION_TYPE = X_INFORMATION_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);

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
    from PER_ASSIGNMENT_INFO_TYPES
    where INFORMATION_TYPE = X_INFORMATION_TYPE
    for update of INFORMATION_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PER_ASSIGNMENT_INFO_TYPES_TL
    where INFORMATION_TYPE = X_INFORMATION_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INFORMATION_TYPE nowait;
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

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
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
  update PER_ASSIGNMENT_INFO_TYPES set
    ACTIVE_INACTIVE_FLAG = X_ACTIVE_INACTIVE_FLAG,
    MULTIPLE_OCCURENCES_FLAG = X_MULTIPLE_OCCURENCES_FLAG,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    REQUEST_ID = X_REQUEST_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INFORMATION_TYPE = X_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PER_ASSIGNMENT_INFO_TYPES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INFORMATION_TYPE = X_INFORMATION_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INFORMATION_TYPE in VARCHAR2
) is
begin
  delete from PER_ASSIGNMENT_INFO_TYPES_TL
  where INFORMATION_TYPE = X_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PER_ASSIGNMENT_INFO_TYPES
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
  l_proc                        VARCHAR2(61) := 'PER_ASSIGNMENT_INFO_TYPES_PKG.LOAD_ROW';
  l_rowid                       rowid;
  l_request_id                  per_assignment_info_types.request_id%TYPE;
  l_progam_application_id       per_assignment_info_types.program_application_id%TYPE;
  l_program_id                  per_assignment_info_types.program_id%TYPE;
  l_program_update_date         per_assignment_info_types.program_update_date%TYPE;
  l_created_by                  per_assignment_info_types.created_by%TYPE             := 0;
  l_creation_date               per_assignment_info_types.creation_date%TYPE          := SYSDATE;
  l_last_update_date            per_assignment_info_types.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by             per_assignment_info_types.last_updated_by%TYPE         := 0;
  l_last_update_login           per_assignment_info_types.last_update_login%TYPE      := 0;
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
  UPDATE per_assignment_info_types_tl
     SET description = X_DESCRIPTION
        ,last_update_date = SYSDATE
        ,last_updated_by = DECODE(X_OWNER,'SEED',1,0)
        ,last_update_login = 0
        ,source_lang = USERENV('LANG')
   WHERE USERENV('LANG') IN (language,source_lang)
     AND information_type = X_INFORMATION_TYPE;
end TRANSLATE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PER_ASSIGNMENT_INFO_TYPES_TL T
  where not exists
    (select NULL
    from PER_ASSIGNMENT_INFO_TYPES B
    where B.INFORMATION_TYPE = T.INFORMATION_TYPE
    );

  update PER_ASSIGNMENT_INFO_TYPES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from PER_ASSIGNMENT_INFO_TYPES_TL B
    where B.INFORMATION_TYPE = T.INFORMATION_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INFORMATION_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.INFORMATION_TYPE,
      SUBT.LANGUAGE
    from PER_ASSIGNMENT_INFO_TYPES_TL SUBB, PER_ASSIGNMENT_INFO_TYPES_TL SUBT
    where SUBB.INFORMATION_TYPE = SUBT.INFORMATION_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PER_ASSIGNMENT_INFO_TYPES_TL (
    INFORMATION_TYPE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INFORMATION_TYPE,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_ASSIGNMENT_INFO_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_ASSIGNMENT_INFO_TYPES_TL T
    where T.INFORMATION_TYPE = B.INFORMATION_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_translation(information_type IN VARCHAR2,
			       language IN VARCHAR2,
			       description IN VARCHAR2)
			       IS
/*

This procedure fails if a description translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated descriptions.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_description IN VARCHAR2,
                     p_information_type IN VARCHAR2)
		     IS
       SELECT  1
	 FROM  per_assignment_info_types_tl aitt,
	       per_assignment_info_types ait
	 WHERE upper(aitt.description)=upper(p_description)
	 AND   aitt.information_type = ait.information_type
	 AND   aitt.language = p_language
	 AND   (ait.information_type <> p_information_type
	       OR p_information_type IS NULL)
	 ;

       l_package_name VARCHAR2(80) := 'PER_ASSIGNMENT_INFO_TYPES_PKG.VALIDATE_TRANSLATION';

BEGIN
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, description,information_type);
      	hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,60);
	  CLOSE c_translation;
       ELSE
      	hr_utility.set_location (l_package_name,70);
	  CLOSE c_translation;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
      	hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
--------------------------------------------------------------------------------

--
END PER_ASSIGNMENT_INFO_TYPES_PKG;

/
