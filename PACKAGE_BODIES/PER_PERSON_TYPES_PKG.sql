--------------------------------------------------------
--  DDL for Package Body PER_PERSON_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERSON_TYPES_PKG" as
/* $Header: pedpt01t.pkb 115.15 2004/06/21 06:21:04 njaladi ship $ */
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
PROCEDURE check_duplicate_name(p_business_group_id  in     number,
			       p_user_person_type   in     varchar2,
			       p_rowid              in     varchar2) is
--
-- Suppression of BG index(+ 0) is removed
-- to avoid FTS
-- Bug #3646157
--
cursor csr_user_name  is select null
		         from   per_person_types_tl pttl,
                                per_person_types    pt
	                 where  pt.business_group_id = p_business_group_id
		         and    upper(pttl.user_person_type) = upper(p_user_person_type)
		         and    (pt.rowid <> p_rowid
		                 or  p_rowid is null)
                         and    pt.person_type_id = pttl.person_type_id
                         and    pttl.LANGUAGE = userenv('LANG');
--
g_dummy_number number;
v_not_unique boolean := FALSE;
--
-- Check the user name is unique
--
begin
  --
  open csr_user_name;
  fetch csr_user_name into g_dummy_number;
  v_not_unique := csr_user_name%FOUND;
  close csr_user_name;
  --
  if v_not_unique then
    hr_utility.set_message(801,'HR_6163_SETUP_DUP');
    hr_utility.raise_error;
  end if;
  --
end check_duplicate_name;
--
PROCEDURE check_duplicate_system_name (p_business_group_id in number,
                                       p_system_name       in varchar2,
                                       p_default_flag      in varchar2,
                                       p_rowid             in varchar2) is
--
-- Suppression of BG index(+ 0) is removed
-- to avoid FTS
-- Bug #3646157
--
cursor csr_system_name is select null
                          from hr_lookups lu, per_person_types pt
                          where pt.business_group_id = p_business_group_id
                          and   lu.meaning = p_system_name
                          and   lu.lookup_type = 'PERSON_TYPE'
                          and   lu.lookup_code = pt.system_person_type
                          and   pt.default_flag = 'Y'
                          and   p_default_flag = 'Y'
                          and (pt.rowid <> p_rowid
                          or   p_rowid is null);

dummy_number number;
not_unique boolean := FALSE;

begin
hr_utility.set_location('BG id '||to_char(p_business_group_Id),1);
hr_utility.set_location('system name '||p_system_name,2);
hr_utility.set_location('default flag'||p_default_flag,3);
hr_utility.set_location('row id'||p_rowid,4);

  open csr_system_name;
  fetch csr_system_name into dummy_number;
  not_unique := csr_system_name%FOUND;
  close csr_system_name;

  if not_unique then
     hr_utility.set_message (800,'HR_52775_SYS_PRIM_DEFAULT');
     hr_utility.raise_error;
  end if;

end check_duplicate_system_name;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Person_Type_Id               IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Active_Flag                         VARCHAR2,
                     X_Default_Flag                        VARCHAR2,
		     X_System_Person_Type                  VARCHAR2,
		     X_System_Name                         VARCHAR2,
                     X_User_Person_Type                    VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM per_person_types
             WHERE person_type_id  = X_Person_Type_Id;

   CURSOR C2 IS SELECT per_person_types_s.nextval FROM sys.dual;

BEGIN

   if (X_Person_Type_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Person_Type_Id;
     CLOSE C2;
   end if;

  INSERT INTO per_person_types(
          person_type_id,
          business_group_id,
          active_flag,
          default_flag,
          system_person_type,
          user_person_type
         ) VALUES (
          X_Person_Type_Id,
          X_Business_Group_Id,
          X_Active_Flag,
          X_Default_Flag,
          X_System_Person_Type,
          X_User_Person_Type

  );
-- MLS
  insert into PER_PERSON_TYPES_TL (
    PERSON_TYPE_ID,
    USER_PERSON_TYPE,
--    LAST_UPDATE_DATE,
--    LAST_UPDATED_BY,
--    LAST_UPDATE_LOGIN,
--    CREATED_BY,
--    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_Person_Type_Id,
    X_User_Person_Type,
--    X_LAST_UPDATE_DATE,
--    X_LAST_UPDATED_BY,
--    X_LAST_UPDATE_LOGIN,
--    X_CREATED_BY,
--    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PER_PERSON_TYPES_TL T
    where T.PERSON_TYPE_ID = X_Person_Type_Id
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','Insert_Row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Person_Type_Id                        NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Active_Flag                           VARCHAR2,
                   X_Default_Flag                          VARCHAR2,
                   X_System_Person_Type                    VARCHAR2,
                   X_User_Person_Type                      VARCHAR2
) IS
  CURSOR C IS
      SELECT ppt.person_type_id,
             ppt.business_group_id,
             ppt.active_flag,
             ppt.default_flag,
             ppt.system_person_type,
             ppt_tl.user_person_type
      FROM   per_person_types ppt,
             per_person_types_tl ppt_tl
      WHERE  ppt.rowid = X_Rowid
      AND    ppt.person_type_id = ppt_tl.person_type_id
      AND    ppt_tl.language = userenv('LANG')
      FOR UPDATE of ppt.person_type_id           NOWAIT;
  Recinfo C%ROWTYPE;
--MLS
  cursor c1 is select
      USER_PERSON_TYPE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PER_PERSON_TYPES_TL
    where PERSON_TYPE_ID = X_Person_Type_Id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERSON_TYPE_ID nowait;
--
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','Lock_Row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
  CLOSE C;
  --
  Recinfo.active_flag := rtrim(Recinfo.active_flag);
  Recinfo.default_flag := rtrim(Recinfo.default_flag);
  Recinfo.system_person_type := rtrim(Recinfo.system_person_type);
  Recinfo.user_person_type := rtrim(Recinfo.user_person_type);
  --
  if (
          (   (Recinfo.person_type_id = X_Person_Type_Id)
           OR (    (Recinfo.person_type_id IS NULL)
               AND (X_Person_Type_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.active_flag = X_Active_Flag)
           OR (    (Recinfo.active_flag IS NULL)
               AND (X_Active_Flag IS NULL)))
      AND (   (Recinfo.default_flag = X_Default_Flag)
           OR (    (Recinfo.default_flag IS NULL)
               AND (X_Default_Flag IS NULL)))
      AND (   (Recinfo.system_person_type = X_System_Person_Type)
           OR (    (Recinfo.system_person_type IS NULL)
               AND (X_System_Person_Type IS NULL)))
      AND (   (Recinfo.user_person_type = X_User_Person_Type)
           OR (    (Recinfo.user_person_type IS NULL)
               AND (X_User_Person_Type IS NULL)))
          ) then
    -- return;
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

-- MLS
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_PERSON_TYPE = X_User_Person_Type)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
--
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Person_Type_Id                      NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Active_Flag                         VARCHAR2,
                     X_Default_Flag                        VARCHAR2,
		     X_System_Person_Type                  VARCHAR2,
		     X_System_Name                         VARCHAR2,
                     X_User_Person_Type                    VARCHAR2
) IS

BEGIN

  UPDATE per_person_types
  SET

    person_type_id                            =    X_Person_Type_Id,
    business_group_id                         =    X_Business_Group_Id,
    active_flag                               =    X_Active_Flag,
    default_flag                              =    X_Default_Flag,
    system_person_type                        =    X_System_Person_Type,
    user_person_type                          =    X_User_Person_Type
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','Update_Row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;

-- MLS
  update PER_PERSON_TYPES_TL set
    USER_PERSON_TYPE = X_User_Person_Type,
--    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
--    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
--    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PERSON_TYPE_ID = X_Person_Type_Id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
--

END Update_Row;

PROCEDURE Delete_Row(X_Rowid          VARCHAR2,
		     X_Default_flag   varchar2,
		     X_Person_type_Id number) IS
BEGIN
   --
   if   X_Default_flag = 'Y' then
	hr_utility.set_message(801,'HR_6618_PERSON_TYPE_NO_DEL_DEF');
        hr_utility.raise_error;
   end if;
  --
  -- if the system name is in use then disallow the deletion
  --
  Check_System_Delete(X_Person_type_Id);
  --

-- MLS
  delete from PER_PERSON_TYPES_TL
  where PERSON_TYPE_ID = X_Person_Type_Id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
--
  DELETE FROM per_person_types
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','Delete_Row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
END Delete_Row;

PROCEDURE Check_Delete (X_Business_Group_Id  NUMBER) IS
          System_Name   VARCHAR2(30);
-- Suppression of BG index(+ 0) is removed
-- to avoid FTS
-- Bug #3646157
          CURSOR C IS SELECT hr.meaning
                      from  hr_lookups hr
                      WHERE hr.lookup_type = 'PERSON_TYPE'
                      and not exists
	                  (select null
		           from per_person_types ppt
                           where hr.lookup_code = ppt.system_person_type
		           AND PPT.business_group_id = X_Business_Group_Id
		           AND   PPT.active_flag = 'Y'
		           AND   PPT.default_flag = 'Y'
			   HAVING COUNT(PPT.system_person_type) = 1);

BEGIN
     --
     -- There must be at least one type of system name in existence
     --
     OPEN C;
     FETCH C INTO System_Name;
     CLOSE C;

     if System_Name is not null then
	 hr_utility.set_message(801,'HR_6318_SYS_PRIM_DEFAULT');
         hr_utility.set_message_token('SYSTEM_NAME',System_Name);
         hr_utility.raise_error;
     end if;

END Check_Delete;

PROCEDURE Check_Default (X_Business_Group_Id IN NUMBER) IS
--
l_system_name_nodefault hr_lookups.meaning%TYPE;
l_system_name_default hr_lookups.meaning%TYPE;
--
-- Cursor to pull back all of the System Names that don't have a default
-- Person Type record.
--
-- Suppression of BG index(+ 0) is removed
-- to avoid FTS
-- Bug #3646157
--
CURSOR csr_nodefault IS
  SELECT hr.meaning
  FROM   hr_lookups hr
  WHERE  hr.lookup_type = 'PERSON_TYPE'
  AND    EXISTS
	 (SELECT null
          FROM   per_person_types ppt
          WHERE  hr.lookup_code = ppt.system_person_type
          AND    ppt.business_group_id = X_Business_Group_Id
          AND    ppt.active_flag = 'Y'
          AND    ppt.default_flag = 'Y'
          HAVING COUNT(PPT.system_person_type) < 1);
--
-- Cursor to pull back all of the System Names that have more than one
-- default Person Type record.
--
-- Suppression of BG index(+ 0) is removed
-- to avoid FTS
-- Bug #3646157
--
CURSOR csr_default IS
  SELECT hr.meaning
  FROM   hr_lookups hr
  WHERE  hr.lookup_type = 'PERSON_TYPE'
  AND    EXISTS
	 (SELECT null
          FROM   per_person_types ppt
          WHERE  hr.lookup_code = ppt.system_person_type
          AND    ppt.business_group_id = X_Business_Group_Id
          AND    ppt.active_flag = 'Y'
          AND    ppt.default_flag = 'Y'
          HAVING COUNT(PPT.system_person_type) > 1);
--
BEGIN

   --
   -- Check to see if there are any system names with no default records
   -- and raise an error if there are.
   --

   OPEN  csr_nodefault;
   FETCH csr_nodefault INTO l_system_name_nodefault;
   CLOSE csr_nodefault;

   IF l_system_name_nodefault IS NOT NULL THEN
      hr_utility.set_message(800,'HR_289007_SYS_PRIM_NODEFAULT');
      hr_utility.set_message_token('SYSTEM_NAME',l_system_name_nodefault);
      hr_utility.raise_error;
   END IF;

   --
   -- Check to see if there are any system names with more than one default
   -- record and raise an error message if there are.
   --

   OPEN  csr_default;
   FETCH csr_default INTO l_system_name_default;
   CLOSE csr_default;

   IF l_system_name_default IS NOT NULL THEN
      hr_utility.set_message(800,'HR_6318_SYS_PRIM_DEFAULT');
      hr_utility.set_message_token('SYSTEM_NAME',l_system_name_default);
      hr_utility.raise_error;
   END IF;

END Check_Default;

PROCEDURE Check_System_Delete(X_Person_Type_Id in NUMBER) IS
--
-- Cursor modifed to include the check on per_person_type_usages_f
-- Bug# 2561337
--
-- modified the cursor definition for better performance
-- Bug #3646157
cursor csr_system is
            select null
              from dual
            where exists (
                           (select null
                            from per_people_f
                            where person_type_id = X_person_type_id)
                          UNION
                           (select null
                            from per_person_type_usages_f
                            where person_type_id= X_person_type_id)
			 );
--
g_dummy_number number;
v_system_used boolean := FALSE;
--
begin
    --
    -- Check the person type is not being used before the record is
    -- deleted
    --
    open csr_system;
    fetch csr_system into g_dummy_number;
    v_system_used := csr_system%FOUND;
    close csr_system;
    --
    if v_system_used then
	 hr_utility.set_message(801,'HR_6619_PERSON_TYPE_EXISTS');
         hr_utility.raise_error;
    end if;
    --
END Check_System_Delete;
--
procedure LOAD_ROW
  (X_PERSON_TYPE         in VARCHAR2
  ,X_BUSINESS_GROUP_NAME in VARCHAR2
  ,X_ACTIVE_FLAG         in VARCHAR2
  ,X_DEFAULT_FLAG        in VARCHAR2
  ,X_SYSTEM_PERSON_TYPE  in VARCHAR2
  ,X_USER_PERSON_TYPE    in VARCHAR2
  ,X_OWNER               in VARCHAR2
  )
is
  cursor csr_business_group
    (x_name in hr_all_organization_units.name%TYPE
    )
  is
    select org.organization_id
      from per_business_groups org
     where org.name = x_name;
  l_business_group csr_business_group%ROWTYPE;
  cursor csr_person_type
    (x_user_person_type in per_person_types.user_person_type%TYPE
    ,x_business_group_id in per_person_types.business_group_id%TYPE
    )
  is
    select ptp.person_type_id
          ,ptp.rowid
      from per_person_types ptp
     where ptp.user_person_type = x_user_person_type
       and ptp.business_group_id = x_business_group_id;
  l_person_type csr_person_type%ROWTYPE;
begin
  -- Validate input paramneters
  open csr_business_group(x_business_group_name);
  fetch csr_business_group into l_business_group;
  if csr_business_group%notfound then
    close csr_business_group;
    hr_utility.set_message(800,'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_business_group;
  -- Insert or update as appropriate
  open csr_person_type(x_person_type,l_business_group.organization_id);
  fetch csr_person_type into l_person_type;
  if csr_person_type%found then
    close csr_person_type;
    UPDATE_ROW
      (X_ROWID => l_person_type.rowid
      ,X_PERSON_TYPE_ID => l_person_type.person_type_id
      ,X_BUSINESS_GROUP_ID => l_business_group.organization_id
      ,X_ACTIVE_FLAG => X_ACTIVE_FLAG
      ,X_DEFAULT_FLAG => X_DEFAULT_FLAG
      ,X_SYSTEM_PERSON_TYPE => X_SYSTEM_PERSON_TYPE
      ,X_SYSTEM_NAME => NULL
      ,X_USER_PERSON_TYPE => X_USER_PERSON_TYPE
      );
  else
    close csr_person_type;
    INSERT_ROW
      (X_ROWID => l_person_type.rowid
      ,X_PERSON_TYPE_ID => l_person_type.person_type_id
      ,X_BUSINESS_GROUP_ID => l_business_group.organization_id
      ,X_ACTIVE_FLAG => X_ACTIVE_FLAG
      ,X_DEFAULT_FLAG => X_DEFAULT_FLAG
      ,X_SYSTEM_PERSON_TYPE => X_SYSTEM_PERSON_TYPE
      ,X_SYSTEM_NAME => NULL
      ,X_USER_PERSON_TYPE => X_USER_PERSON_TYPE
      );
  end if;
end LOAD_ROW;
--
procedure TRANSLATE_ROW
  (X_PERSON_TYPE         in VARCHAR2
  ,X_BUSINESS_GROUP_NAME in VARCHAR2
  ,X_USER_PERSON_TYPE    in VARCHAR2
  ,X_OWNER               in VARCHAR2
  )
is
  cursor csr_person_type
    (x_user_person_type in per_person_types.user_person_type%TYPE
    ,x_name             in hr_all_organization_units.name%TYPE
    )
  is
    select ptp.person_type_id
      from per_person_types ptp
          ,per_business_groups org
     where ptp.business_group_id = org.organization_id
       and ptp.user_person_type = x_user_person_type
       and org.name = x_name;
  l_person_type csr_person_type%ROWTYPE;
begin
  -- Translate keys to internal ids
  open csr_person_type(x_person_type,x_business_group_name);
  fetch csr_person_type into l_person_type;
  close csr_person_type;
  -- Update table
  UPDATE per_person_types_tl
     SET user_person_type = X_USER_PERSON_TYPE
        ,last_update_date = SYSDATE
        ,last_updated_by = DECODE(X_OWNER,'SEED',1,0)
        ,last_update_login = 1
        ,source_lang = USERENV('LANG')
   WHERE USERENV('LANG') in (language,source_lang)
     AND person_type_id = l_person_type.person_type_id;
end TRANSLATE_ROW;
--
procedure ADD_LANGUAGE
is
begin
  -- process PER_PERSON_TYPES_TL table
  delete from PER_PERSON_TYPES_TL T
  where not exists
    (select NULL
    from PER_PERSON_TYPES B
    where B.PERSON_TYPE_ID = T.PERSON_TYPE_ID
    );

  update PER_PERSON_TYPES_TL T set (
      USER_PERSON_TYPE
    ) = (select
      B.USER_PERSON_TYPE
    from PER_PERSON_TYPES_TL B
    where B.PERSON_TYPE_ID = T.PERSON_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERSON_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERSON_TYPE_ID,
      SUBT.LANGUAGE
    from PER_PERSON_TYPES_TL SUBB, PER_PERSON_TYPES_TL SUBT
    where SUBB.PERSON_TYPE_ID = SUBT.PERSON_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_PERSON_TYPE <> SUBT.USER_PERSON_TYPE
  ));

  insert into PER_PERSON_TYPES_TL (
    PERSON_TYPE_ID,
    USER_PERSON_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PERSON_TYPE_ID,
    B.USER_PERSON_TYPE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_PERSON_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_PERSON_TYPES_TL T
    where T.PERSON_TYPE_ID = B.PERSON_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  -- process PER_STARTUP_PERSON_TYPES_TL table
  -- Removed the insertion as it is redundant
--
end ADD_LANGUAGE;
--
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_translation(person_type_id IN NUMBER,
			       language IN VARCHAR2,
			       user_person_type IN VARCHAR2,
			       p_business_group_id IN NUMBER )
			       IS
/*

This procedure fails if a user person type translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated user person types.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_user_person_type IN VARCHAR2,
                     p_person_type_id IN NUMBER,
                     p_bus_grp_id IN NUMBER)
		     IS
       SELECT  1
	 FROM  per_person_types_tl pptt,
	       per_person_types ppt
	 WHERE upper(pptt.user_person_type)=upper(p_user_person_type)
	 AND   pptt.person_type_id = ppt.person_type_id
	 AND   pptt.language = p_language
	 AND   (ppt.person_type_id <> p_person_type_id OR p_person_type_id IS NULL)
	 AND   (ppt.business_group_id = p_bus_grp_id OR p_bus_grp_id IS NULL)
	 ;

       l_package_name VARCHAR2(80) := 'PER_PERSON_TYPES_PKG.VALIDATE_TRANSLATION';
       l_business_group_id NUMBER := nvl(p_business_group_id, g_business_group_id);

BEGIN
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, user_person_type,person_type_id,
		     l_business_group_id);
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

END PER_PERSON_TYPES_PKG;

/
