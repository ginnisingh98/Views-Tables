--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_CLASS_PKG" as
/* $Header: pydec.pkb 120.0 2005/05/29 01:49:24 appldev noship $ */
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
function NAME_NOT_UNIQUE (
--
--******************************************************************************
--* Returns TRUE if the classification name is not unique within the legislation
--******************************************************************************
--
-- Parameters are:
--
	p_classification_name	varchar2,
	p_legislation_code	varchar2,
        p_business_group_id     number,
	p_rowid			varchar2)
--
return boolean is
--
v_match_found	boolean;
--
cursor csr_matching_name is
	select	1
	from	pay_element_classifications
	where	upper(classification_name) = upper(p_classification_name)
  	and	nvl(legislation_code,nvl(p_legislation_code, ' '))
			= nvl(p_legislation_code, ' ')
  	and     (p_rowid is null
  		or (p_rowid is not null and p_rowid <> rowid))
        and     business_group_id = p_business_group_id;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',1);
--
open csr_matching_name;
fetch csr_matching_name into g_dummy;
v_match_found := csr_matching_name%found;
close csr_matching_name;
--
if v_match_found then
  hr_utility.set_message (801,'HR_6310_ELE_CLASS_NAME');
  hr_utility.raise_error;
end if;
--
return v_match_found;
--
end name_not_unique;
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--------------------------------------------------------------------------------
procedure validate_translation(classification_id IN NUMBER,
			       language IN VARCHAR2,
			       classification_name IN VARCHAR2,
			       description IN VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT null) IS
/*

This procedure fails if a classification translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated classification names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_class_name IN VARCHAR2,
                     p_class_id IN NUMBER,
                     p_bus_grp_id IN NUMBER,
		     p_leg_code IN varchar2)  IS
       SELECT  1
	 FROM  pay_element_classifications_tl ect,
	       pay_element_classifications ecl
	 WHERE upper(ect.classification_name)=upper(p_class_name)
	 AND   ect.classification_id = ecl.classification_id
	 AND   ect.language = p_language
	 AND   (ecl.classification_id <> p_class_id OR p_class_id IS NULL)
	 AND   (ecl.business_group_id = p_bus_grp_id OR p_bus_grp_id IS NULL)
	 AND   (ecl.legislation_code = p_leg_code OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80);
       l_business_group_id NUMBER;
       l_legislation_code VARCHAR2(150);

BEGIN
   l_package_name  := 'PAY_ELEMENT_CLASS_PKG.VALIDATE_TRANSLATION';
   l_business_group_id := nvl(p_business_group_id, g_business_group_id);
   l_legislation_code  := nvl(p_legislation_code, g_legislation_code);
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, classification_name,classification_id,
		     l_business_group_id,l_legislation_code);
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
function DELETION_ALLOWED (
--
--******************************************************************************
--* Returns TRUE if all deletion checks are passed.			       *
--******************************************************************************
--
-- Parameters are:
--
	p_classification_id	varchar2)
--
return boolean is
--
classification_type		varchar2(10);
children_found			boolean;
primary_classification		boolean;
secondary_classification	boolean;
--
cursor csr_class_type is
	select	decode (parent_classification_id,
			null,'PRIMARY',
				'SECONDARY')
	from	pay_element_classifications
	where	classification_id	 = p_classification_id;
--
function CHILD_CLASSIFICATIONS return boolean is
-- Check for child secondary classifications
	cursor csr_2ndary_classifications is
		select	1
		from	pay_element_classifications
		where	parent_classification_id	= p_classification_id;
	--
	begin
	hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',3);
	open csr_2ndary_classifications;
	fetch csr_2ndary_classifications into g_dummy;
	children_found := csr_2ndary_classifications%found;
	close csr_2ndary_classifications;
	if children_found then
	  hr_utility.set_message (801,'HR_6313_ELE_CLASS_DEL_EC');
	end if;
	return children_found;
	end child_classifications;
	--
function CHILD_ELEMENTS return boolean is
-- Check for child element types
	cursor csr_element_types is
		select	1
		from	pay_element_types_f
		where	classification_id	= p_classification_id;
	--
	begin
	hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',4);
	open csr_element_types;
	fetch csr_element_types into g_dummy;
	children_found := csr_element_types%found;
	close csr_element_types;
	if children_found then
	  hr_utility.set_message (801,'HR_6314_ELE_CLASS_DEL_ET');
	end if;
	return children_found;
	end child_elements;
	--
function CHILD_CLASS_RULES return boolean is
-- Check for child classification rules
	cursor csr_class_rules is
		select	1
		from	pay_ele_classification_rules
		where	classification_id	= p_classification_id;
	--
	begin
	hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',5);
	open csr_class_rules;
	fetch csr_class_rules into g_dummy;
	children_found := csr_class_rules%found;
	close csr_class_rules;
	if children_found then
	  hr_utility.set_message (801,'HR_6315_ELE_CLASS_DEL_ECR');
	end if;
	return children_found;
	end child_class_rules;
	--
function CHILD_BALANCE_CLASSES return boolean is
-- Check for child balance classifications
	cursor csr_balance_classes is
		select	1
		from	pay_balance_classifications
		where	classification_id       = p_classification_id;
	--
	begin
	hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',6);
	open csr_balance_classes;
	fetch csr_balance_classes into g_dummy;
	children_found := csr_balance_classes%found;
	close csr_balance_classes;
	if children_found then
	  hr_utility.set_message (801,'HR_6316_ELE_CLASS_DEL_BC');
	end if;
	return children_found;
	end child_balance_classes;
	--
function CHILD_SUB_CLASS_RULES return boolean is
-- Check for child sub-classification rules
	cursor csr_sub_class_rules is
		select	1
		from	pay_sub_classification_rules_f
		where   classification_id       = p_classification_id;
	--
	begin
	hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',7);
	open csr_sub_class_rules;
	fetch csr_sub_class_rules into g_dummy;
	children_found := csr_sub_class_rules%found;
	close csr_sub_class_rules;
	if children_found then
	  hr_utility.set_message (801,'HR_6317_ELE_CLASS_DEL_SCR');
	end if;
	return children_found;
	end child_sub_class_rules;
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',1);
--
-- Find out whether this is a primary or secondary classification
--
open csr_class_type;
fetch csr_class_type into classification_type;
primary_classification := (classification_type = 'PRIMARY');
secondary_classification := (classification_type = 'SECONDARY');
close csr_class_type;
--
hr_utility.set_location ('PAY_ELEMENT_CLASSIFICATIONS_PKG',2);
--
-- Checks for deletion permission
--
if child_balance_classes
	--
	or ((	primary_classification
		and (	child_classifications
			or child_elements
			or child_class_rules	))
	--
	or (	secondary_classification
		and child_sub_class_rules)) then
  --
  hr_utility.trace ('Deletion not allowed');
  hr_utility.raise_error;
  return FALSE;
  --
else
  hr_utility.trace ('Deletion allowed');
  return TRUE;
end if;
--
end deletion_allowed;
--------------------------------------------------------------------------------
function USER_CAN_MODIFY_PRIMARY (p_legislation_code varchar2) return boolean is
--
--******************************************************************************
--* Returns TRUE if there are no seeded primary classifications for the user's *
--* legislation                                                 	       *
--******************************************************************************
--
cursor csr_personnel is
	select	1
	from	fnd_product_installations
	where	application_id	= 800
	and	status		= 'I';
--
cursor csr_seeded_data is
	select	1
	from	pay_element_classifications
	where	legislation_code	= p_legislation_code
	and	business_group_id is null;
--
cursor csr_localised is
        select 'x'
        from   hr_legislation_installations li
        where  li.legislation_code = p_legislation_code;

v_modifiable	boolean := TRUE;
v_local         varchar2(1);
--
begin
--
hr_utility.set_location ('PAY_ELEMENT_CLASS_PKG',1);
--
open csr_personnel;
open csr_seeded_data;
--
fetch csr_seeded_data into g_dummy;
fetch csr_personnel into g_dummy;
--
if (csr_personnel%notfound
	or csr_seeded_data%found) then
  v_modifiable := FALSE;
end if;
--
close csr_seeded_data;
close csr_personnel;
--
open csr_localised;
--
fetch csr_localised into v_local;
--
if csr_localised%notfound then
  null;
else
   v_modifiable := FALSE;
end if;
--
hr_utility.set_location ('PAY_ELEMENT_CLASS_PKG',10);
return v_modifiable;
--
end user_can_modify_primary;
--------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CLASSIFICATION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_COSTABLE_FLAG in VARCHAR2,
  X_DEFAULT_HIGH_PRIORITY in NUMBER,
  X_DEFAULT_LOW_PRIORITY in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_DISTRIBUTABLE_OVER_FLAG in VARCHAR2,
  X_NON_PAYMENTS_FLAG in VARCHAR2,
  X_COSTING_DEBIT_OR_CREDIT in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_CREATE_BY_DEFAULT_FLAG in VARCHAR2,
  X_BALANCE_INITIALIZATION_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_FREQ_RULE_ENABLED in VARCHAR2 default null
) is
  cursor C is select ROWID from PAY_ELEMENT_CLASSIFICATIONS
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    ;
begin
  insert into PAY_ELEMENT_CLASSIFICATIONS (
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    BUSINESS_GROUP_ID,
    LEGISLATION_CODE,
    LEGISLATION_SUBGROUP,
    COSTABLE_FLAG,
    DEFAULT_HIGH_PRIORITY,
    DEFAULT_LOW_PRIORITY,
    DEFAULT_PRIORITY,
    DISTRIBUTABLE_OVER_FLAG,
    NON_PAYMENTS_FLAG,
    COSTING_DEBIT_OR_CREDIT,
    PARENT_CLASSIFICATION_ID,
    CREATE_BY_DEFAULT_FLAG,
    BALANCE_INITIALIZATION_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    FREQ_RULE_ENABLED
  ) values (
    X_CLASSIFICATION_ID,
    X_CLASSIFICATION_NAME,
    X_BUSINESS_GROUP_ID,
    X_LEGISLATION_CODE,
    X_LEGISLATION_SUBGROUP,
    X_COSTABLE_FLAG,
    X_DEFAULT_HIGH_PRIORITY,
    X_DEFAULT_LOW_PRIORITY,
    X_DEFAULT_PRIORITY,
    X_DISTRIBUTABLE_OVER_FLAG,
    X_NON_PAYMENTS_FLAG,
    X_COSTING_DEBIT_OR_CREDIT,
    X_PARENT_CLASSIFICATION_ID,
    X_CREATE_BY_DEFAULT_FLAG,
    X_BALANCE_INITIALIZATION_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_FREQ_RULE_ENABLED
  );

  insert into PAY_ELEMENT_CLASSIFICATIONS_TL (
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CLASSIFICATION_ID,
    X_CLASSIFICATION_NAME,
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
    from PAY_ELEMENT_CLASSIFICATIONS_TL T
    where T.CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;
--------------------------------------------------------------------------------
procedure LOCK_ROW (
  X_CLASSIFICATION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_COSTABLE_FLAG in VARCHAR2,
  X_DEFAULT_HIGH_PRIORITY in NUMBER,
  X_DEFAULT_LOW_PRIORITY in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_DISTRIBUTABLE_OVER_FLAG in VARCHAR2,
  X_NON_PAYMENTS_FLAG in VARCHAR2,
  X_COSTING_DEBIT_OR_CREDIT in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_CREATE_BY_DEFAULT_FLAG in VARCHAR2,
  X_BALANCE_INITIALIZATION_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FREQ_RULE_ENABLED in VARCHAR2 default null
) is
  cursor c is select
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      LEGISLATION_SUBGROUP,
      COSTABLE_FLAG,
      DEFAULT_HIGH_PRIORITY,
      DEFAULT_LOW_PRIORITY,
      DEFAULT_PRIORITY,
      DISTRIBUTABLE_OVER_FLAG,
      NON_PAYMENTS_FLAG,
      COSTING_DEBIT_OR_CREDIT,
      PARENT_CLASSIFICATION_ID,
      CREATE_BY_DEFAULT_FLAG,
      BALANCE_INITIALIZATION_FLAG,
      OBJECT_VERSION_NUMBER,
      FREQ_RULE_ENABLED
    from PAY_ELEMENT_CLASSIFICATIONS
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    for update of CLASSIFICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CLASSIFICATION_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PAY_ELEMENT_CLASSIFICATIONS_TL
    where CLASSIFICATION_ID = X_CLASSIFICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CLASSIFICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID)
           OR ((recinfo.BUSINESS_GROUP_ID is null) AND (X_BUSINESS_GROUP_ID is null)))
      AND ((recinfo.LEGISLATION_CODE = X_LEGISLATION_CODE)
           OR ((recinfo.LEGISLATION_CODE is null) AND (X_LEGISLATION_CODE is null)))
      AND ((recinfo.LEGISLATION_SUBGROUP = X_LEGISLATION_SUBGROUP)
           OR ((recinfo.LEGISLATION_SUBGROUP is null) AND (X_LEGISLATION_SUBGROUP is null)))
      AND ((recinfo.COSTABLE_FLAG = X_COSTABLE_FLAG)
           OR ((recinfo.COSTABLE_FLAG is null) AND (X_COSTABLE_FLAG is null)))
      AND ((recinfo.DEFAULT_HIGH_PRIORITY = X_DEFAULT_HIGH_PRIORITY)
           OR ((recinfo.DEFAULT_HIGH_PRIORITY is null) AND (X_DEFAULT_HIGH_PRIORITY is null)))
      AND ((recinfo.DEFAULT_LOW_PRIORITY = X_DEFAULT_LOW_PRIORITY)
           OR ((recinfo.DEFAULT_LOW_PRIORITY is null) AND (X_DEFAULT_LOW_PRIORITY is null)))
      AND ((recinfo.DEFAULT_PRIORITY = X_DEFAULT_PRIORITY)
           OR ((recinfo.DEFAULT_PRIORITY is null) AND (X_DEFAULT_PRIORITY is null)))
      AND ((recinfo.DISTRIBUTABLE_OVER_FLAG = X_DISTRIBUTABLE_OVER_FLAG)
           OR ((recinfo.DISTRIBUTABLE_OVER_FLAG is null) AND (X_DISTRIBUTABLE_OVER_FLAG is null)))
      AND ((recinfo.NON_PAYMENTS_FLAG = X_NON_PAYMENTS_FLAG)
           OR ((recinfo.NON_PAYMENTS_FLAG is null) AND (X_NON_PAYMENTS_FLAG is null)))
      AND ((recinfo.COSTING_DEBIT_OR_CREDIT = X_COSTING_DEBIT_OR_CREDIT)
           OR ((recinfo.COSTING_DEBIT_OR_CREDIT is null) AND (X_COSTING_DEBIT_OR_CREDIT is null)))
      AND ((recinfo.PARENT_CLASSIFICATION_ID = X_PARENT_CLASSIFICATION_ID)
           OR ((recinfo.PARENT_CLASSIFICATION_ID is null) AND (X_PARENT_CLASSIFICATION_ID is null)))
      AND ((recinfo.CREATE_BY_DEFAULT_FLAG = X_CREATE_BY_DEFAULT_FLAG)
           OR ((recinfo.CREATE_BY_DEFAULT_FLAG is null) AND (X_CREATE_BY_DEFAULT_FLAG is null)))
      AND ((recinfo.BALANCE_INITIALIZATION_FLAG = X_BALANCE_INITIALIZATION_FLAG)
           OR ((recinfo.BALANCE_INITIALIZATION_FLAG is null) AND (X_BALANCE_INITIALIZATION_FLAG is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.FREQ_RULE_ENABLED = X_FREQ_RULE_ENABLED)
           OR ((recinfo.FREQ_RULE_ENABLED is null) AND (X_FREQ_RULE_ENABLED is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CLASSIFICATION_NAME = X_CLASSIFICATION_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
--------------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_CLASSIFICATION_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_LEGISLATION_SUBGROUP in VARCHAR2,
  X_COSTABLE_FLAG in VARCHAR2,
  X_DEFAULT_HIGH_PRIORITY in NUMBER,
  X_DEFAULT_LOW_PRIORITY in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_DISTRIBUTABLE_OVER_FLAG in VARCHAR2,
  X_NON_PAYMENTS_FLAG in VARCHAR2,
  X_COSTING_DEBIT_OR_CREDIT in VARCHAR2,
  X_PARENT_CLASSIFICATION_ID in NUMBER,
  X_CREATE_BY_DEFAULT_FLAG in VARCHAR2,
  X_BALANCE_INITIALIZATION_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_MESG_FLG          out nocopy     Boolean,
  X_FREQ_RULE_ENABLED in VARCHAR2 default null
) is

 P_SOURCE_LANG            PAY_ELEMENT_CLASSIFICATIONS_TL.SOURCE_LANG%type;
begin
	begin
        select source_lang
               into P_SOURCE_LANG
            from PAY_ELEMENT_CLASSIFICATIONS_TL
        where
           CLASSIFICATION_ID = X_CLASSIFICATION_ID
           and userenv('LANG') = LANGUAGE;
        Exception
           when no_data_found then
             raise no_data_found;
        end;

   if P_SOURCE_LANG = userenv('LANG') then
    X_MESG_FLG :=false;
   else
    X_MESG_FLG :=true;
   end if;

  update PAY_ELEMENT_CLASSIFICATIONS set
   CLASSIFICATION_NAME= decode(P_SOURCE_LANG,userenv('LANG'),X_CLASSIFICATION_NAME,CLASSIFICATION_NAME),
    BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    LEGISLATION_SUBGROUP = X_LEGISLATION_SUBGROUP,
    COSTABLE_FLAG = X_COSTABLE_FLAG,
    DEFAULT_HIGH_PRIORITY = X_DEFAULT_HIGH_PRIORITY,
    DEFAULT_LOW_PRIORITY = X_DEFAULT_LOW_PRIORITY,
    DEFAULT_PRIORITY = X_DEFAULT_PRIORITY,
    DISTRIBUTABLE_OVER_FLAG = X_DISTRIBUTABLE_OVER_FLAG,
    NON_PAYMENTS_FLAG = X_NON_PAYMENTS_FLAG,
    COSTING_DEBIT_OR_CREDIT = X_COSTING_DEBIT_OR_CREDIT,
    PARENT_CLASSIFICATION_ID = X_PARENT_CLASSIFICATION_ID,
    CREATE_BY_DEFAULT_FLAG = X_CREATE_BY_DEFAULT_FLAG,
    BALANCE_INITIALIZATION_FLAG = X_BALANCE_INITIALIZATION_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    FREQ_RULE_ENABLED = X_FREQ_RULE_ENABLED
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PAY_ELEMENT_CLASSIFICATIONS_TL set
    CLASSIFICATION_NAME = X_CLASSIFICATION_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
--------------------------------------------------------------------------------
procedure DELETE_ROW (
  X_CLASSIFICATION_ID in NUMBER
) is
begin
  delete from PAY_ELEMENT_CLASSIFICATIONS_TL
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PAY_ELEMENT_CLASSIFICATIONS
  where CLASSIFICATION_ID = X_CLASSIFICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--------------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_ELEMENT_CLASSIFICATIONS_TL T
  where not exists
    (select NULL
    from PAY_ELEMENT_CLASSIFICATIONS B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    );

  update PAY_ELEMENT_CLASSIFICATIONS_TL T set (
      CLASSIFICATION_NAME,
      DESCRIPTION
    ) = (select
      B.CLASSIFICATION_NAME,
      B.DESCRIPTION
    from PAY_ELEMENT_CLASSIFICATIONS_TL B
    where B.CLASSIFICATION_ID = T.CLASSIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CLASSIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CLASSIFICATION_ID,
      SUBT.LANGUAGE
    from PAY_ELEMENT_CLASSIFICATIONS_TL SUBB, PAY_ELEMENT_CLASSIFICATIONS_TL SUBT
    where SUBB.CLASSIFICATION_ID = SUBT.CLASSIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CLASSIFICATION_NAME <> SUBT.CLASSIFICATION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PAY_ELEMENT_CLASSIFICATIONS_TL (
    CLASSIFICATION_ID,
    CLASSIFICATION_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CLASSIFICATION_ID,
    B.CLASSIFICATION_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_ELEMENT_CLASSIFICATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_ELEMENT_CLASSIFICATIONS_TL T
    where T.CLASSIFICATION_ID = B.CLASSIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--------------------------------------------------------------------------------
procedure unique_chk(E_CLASSIFICATION_NAME in VARCHAR2, E_LEGISLATION_CODE in VARCHAR2)
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM PAY_ELEMENT_CLASSIFICATIONS
  WHERE nvl(CLASSIFICATION_NAME,'~null~') = nvl(E_CLASSIFICATION_NAME,'~null~')
    and nvl(LEGISLATION_CODE,'~null~') = nvl(E_LEGISLATION_CODE,'~null~')
    and BUSINESS_GROUP_ID is NULL;
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_ELEMENT_CLASS_PKB.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_ELEMENT_CLASS_PKB.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
end unique_chk;
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
  X_E_CLASSIFICATION_NAME in VARCHAR2,
  X_E_LEGISLATION_CODE in VARCHAR2,
  X_CLASSIFICATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) is
begin
  -- unique_chk(X_E_CLASSIFICATION_NAME,X_E_LEGISLATION_CODE);
  --
  UPDATE pay_element_classifications_tl
     SET CLASSIFICATION_NAME = nvl(X_CLASSIFICATION_NAME,CLASSIFICATION_NAME),
        description = nvl(x_description,description),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND CLASSIFICATION_ID in
        (select CLASSIFICATION_ID
           from pay_element_classifications
          where nvl(CLASSIFICATION_NAME,'~null~')=nvl(X_E_CLASSIFICATION_NAME,'~null~')
            and nvl(LEGISLATION_CODE,'~null~') = nvl(X_E_LEGISLATION_CODE,'~null~')
            and BUSINESS_GROUP_ID is NULL);
  --
  if (sql%notfound) then  -- trap system errors during update
  --   hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  --   hr_utility.set_message_token ('PROCEDURE','PAY_ELEMENT_CLASS_PKB.TRANSLATE_ROW');
  --   hr_utility.set_message_token('STEP','1');
  --   hr_utility.raise_error;
  null;
  end if;
end TRANSLATE_ROW;
--------------------------------------------------------------------------------
end PAY_ELEMENT_CLASS_PKG;

/
