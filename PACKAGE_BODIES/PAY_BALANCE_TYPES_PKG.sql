--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_TYPES_PKG" as
/* $Header: pyblt01t.pkb 120.1 2005/11/07 09:45:38 arashid noship $ */
--
-- dummy variable for values returned from cursors that are not needed
--
g_dummy_number number(30);
--
g_business_group_id number(15);   -- For validating translation.
g_legislation_code  varchar2(150);-- For validating translation.
--
-------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_legislation_code  IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code  := p_legislation_code;
END;
-------------------------------------------------------------------------------
procedure validate_translation(balance_type_id IN NUMBER,
			       language IN VARCHAR2,
			       balance_name IN VARCHAR2,
			       reporting_name IN VARCHAR2) IS
/*

This procedure fails if a balance name or reporting name translation is already
present in the table for a given language.  Otherwise, no action is performed.
It is used to ensure uniqueness of translated balance and reporting names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form


     cursor c_translation(p_language        IN VARCHAR2,
                          p_balance_name    IN VARCHAR2,
                          p_reporting_name  IN VARCHAR2,
                          p_balance_type_id IN NUMBER,
                          p_mode            IN VARCHAR2)  IS
     SELECT  1
	 FROM  pay_balance_types_tl bttl,
	       pay_balance_types    bt
	 WHERE ((p_mode = 'BALANCE_NAME' and
             upper(bttl.balance_name) = upper(translate(p_balance_name,
                                              '_',' '))) or
            (p_mode = 'REPORTING_NAME' and
             upper(bttl.reporting_name) = upper(translate(p_reporting_name,
                                                '_',' '))))
	 AND   bttl.balance_type_id = bt.balance_type_id
	 AND   bttl.language = p_language
	 AND   ( bt.balance_type_id <> p_balance_type_id        OR p_balance_type_id   is null )
     AND   ( g_business_group_id = bt.business_group_id + 0 OR g_business_group_id is null )
     AND   ( g_legislation_code  = bt.legislation_code      OR g_legislation_code  is null );


   l_package_name VARCHAR2(80) := 'PAY_BALANCE_TYPES_PKG.VALIDATE_TRANSLATION';
   l_name  pay_balance_types.balance_name%type := balance_name;
   l_dummy varchar2(100);

BEGIN
    hr_utility.set_location (l_package_name,1);

    BEGIN
        hr_chkfmt.checkformat (l_name,
                              'PAY_NAME',
                              l_dummy, null, null, 'N', l_dummy, null);
        hr_utility.set_location (l_package_name,2);

    EXCEPTION
        when app_exception.application_exception then
            hr_utility.set_location (l_package_name,3);
            fnd_message.set_name ('PAY','PAY_6365_ELEMENT_NO_DB_NAME'); -- checkformat failure
            fnd_message.raise_error;
    END;

    hr_utility.set_location (l_package_name,10);
    OPEN c_translation(language
                       , balance_name
                       , reporting_name
                       , balance_type_id
                       , 'BALANCE_NAME');
    hr_utility.set_location (l_package_name,20);

    FETCH c_translation INTO g_dummy_number;
    hr_utility.set_location (l_package_name,25);

    IF c_translation%NOTFOUND THEN
    	hr_utility.set_location (l_package_name,30);
        CLOSE c_translation;
    ELSE
    	hr_utility.set_location (l_package_name,40);
        CLOSE c_translation;
        fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
        fnd_message.raise_error;
    END IF;

    OPEN c_translation(language
                      , balance_name
                      , reporting_name
                      , balance_type_id
                      , 'REPORTING_NAME');
    hr_utility.set_location (l_package_name,50);
    FETCH c_translation INTO g_dummy_number;
    hr_utility.set_location (l_package_name,55);

    IF c_translation%NOTFOUND THEN
    	hr_utility.set_location (l_package_name,60);
        CLOSE c_translation;
    ELSE
    	hr_utility.set_location (l_package_name,70);
        CLOSE c_translation;
        fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
        fnd_message.raise_error;
    END IF;

    hr_utility.set_location ('Leaving: '||l_package_name,140);
END validate_translation;

-----------------------------------------------------------------------------
-- Name
--   chk_balance_category_rule
--
-- Purpose
--   Checks whether column balance_category_id is mandatory for the current
--   legislation. It will only be mandatory when the legislation delivers
--   the legislation rule row and an upgrade script for populating all balances
--   with a balance category.
-----------------------------------------------------------------------------
function chk_balance_category_rule
(p_legislation_code  varchar2
,p_business_group_id number default null
)
return boolean is
--
l_proc     varchar2(72) := 'pay_balance_types_pkg.chk_balance_category';
l_leg_code pay_balance_types.legislation_code%type;
--
cursor get_legislation(p_bg_id number)
is
select pbg.legislation_code
from   per_business_groups pbg
where  pbg.business_group_id = p_bg_id;
--
cursor get_leg_rule(p_leg_code varchar2)
is
select rule_mode
from   pay_legislation_rules
where  rule_type = 'BAL_CATEGORY_MANDATORY'
and    legislation_code = p_leg_code;
--
l_rule_mode pay_legislation_rules.rule_mode%type;
--
begin
hr_utility.set_location('Entering '||l_proc, 5);
--
hr_utility.trace('leg code '||p_legislation_code);
hr_utility.trace('bg: '||to_char(p_business_group_id));
if p_legislation_code is null then
  if p_business_group_id is not null then
    open  get_legislation(p_business_group_id);
    fetch get_legislation into l_leg_code;
    if get_legislation%notfound then
      --
      close get_legislation;
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_message(801, 'PAY_34260_BG_HAS_NO_LEG');
      hr_utility.raise_error;
      --
    else
      hr_utility.set_location(l_proc, 15);
      close get_legislation;
    end if;
  else -- bg is null, so global row being checked, category cannot be mandatory
    hr_utility.set_location(l_proc, 20);
    return false;
  end if;
else -- p_legislation is not null
  hr_utility.set_location(l_proc, 25);
  l_leg_code := p_legislation_code;
end if;
--
-- check the legislation_rule BAL_CATEGORY_MANDATORY
--
open  get_leg_rule(l_leg_code);
fetch get_leg_rule into l_rule_mode;
if get_leg_rule%notfound
or l_rule_mode = 'N' then
  --
  hr_utility.set_location(l_proc, 30);
  close get_leg_rule;
  return false;
  --
else
  hr_utility.set_location(l_proc, 35);
  close get_leg_rule;
  return true;
end if;
end chk_balance_category_rule;
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_balance_type                                                      --
 -- Purpose                                                                 --
 --   Validates the balance type ie. unique name, only one remuneration     --
 --   balance etc ...                                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure chk_balance_type
 (
  p_row_id                       varchar2,
  p_business_group_id            number,
  p_legislation_code             varchar2,
  p_balance_name                 varchar2,
  p_reporting_name               varchar2,
  p_assignment_remuneration_flag varchar2
 ) is
--
   v_bal_type_id number;
   v_result_text varchar2(80);
   v_bg_leg_code varchar2(30);
--
   cursor csr_unique_check(p_mode varchar2) is
     select bt.balance_type_id
     from   pay_balance_types bt
     ,      per_business_groups_perf bg
     where  ((p_mode = 'BALANCE_NAME'
     and    upper(bt.balance_name) = upper(translate(p_balance_name,'_',' ')))
     or     (p_mode = 'REPORTING_NAME'
     and    upper(bt.reporting_name) = upper(translate(p_reporting_name,'_',' ')))
     or     (p_mode = 'ASSIGNMENT_RENUMERATION_ALLOWED_FLAG'
     and    bt.assignment_remuneration_flag = 'Y'))
     and    bt.business_group_id = bg.business_group_id (+)
     and    ((p_business_group_id is not null
     and    nvl(bt.business_group_id,-1) = p_business_group_id
     or     nvl(bt.legislation_code,' ') = v_bg_leg_code)
     or     (p_legislation_code is not null
     and    nvl(bt.legislation_code,' ') = p_legislation_code
     or     bt.business_group_id is not null
     and    bt.legislation_code = p_legislation_code)
     or     bt.business_group_id is null
     and    bt.legislation_code is null)
     and    (p_row_id is null
     or     (p_row_id is not null
     and    chartorowid(p_row_id) <> bt.rowid));
--
    cursor csr_bg_leg_code is
      select  legislation_code
      from    per_business_groups
      where   business_group_id = p_business_group_id;
--
 begin
--
   if ((p_business_group_id is not null) and
       (p_legislation_code is null))  then
     open  csr_bg_leg_code;
     fetch csr_bg_leg_code into v_bg_leg_code;
     close csr_bg_leg_code;
   else
     v_bg_leg_code := p_legislation_code;
   end if;
--
   -- BALANCE_NAME has been set.
   if p_balance_name is not null then
--
     -- Make sure format of BALANCE_NAME is correct ie. can create an database
     -- item.
     begin
       v_result_text := p_balance_name;
       hr_chkfmt.checkformat
         (v_result_text,
          'PAY_NAME',
          v_result_text,
          null,
          null,
          'N',
          v_result_text,
          null);
     exception
       when hr_utility.hr_error then
         hr_utility.set_message(801, 'HR_6016_ALL_RES_WORDS');
         hr_utility.set_message_token('VALUE_NAME', 'This');
         raise;
     end;
--
     -- Make sure balance name being created is unique within BG / LEG CODE.
     open csr_unique_check('BALANCE_NAME');
     fetch csr_unique_check into v_bal_type_id;
     if csr_unique_check%found then
       close csr_unique_check;
       hr_utility.set_message(801, 'HR_6108_BAL_UNI_BALANCE');
       hr_utility.raise_error;
     else
       close csr_unique_check;
     end if;
--
   end if;
--
   -- REPORTING_NAME has been set.
   if p_reporting_name is not null then
--
--
     -- Make sure reporting name being created is unique within BG / LEG CODE.
     open csr_unique_check('REPORTING_NAME');
     fetch csr_unique_check into v_bal_type_id;
     if csr_unique_check%found then
       close csr_unique_check;
       hr_utility.set_message(801, 'HR_6108_BAL_UNI_BALANCE');
       hr_utility.raise_error;
     else
       close csr_unique_check;
     end if;
--
   end if;
--
   -- ASSIGNMENT_RENUMERATION_ALLOWED_FLAG has been set to 'Y'.
   if p_assignment_remuneration_flag = 'Y' then
--
     -- Make sure there is only one balance that can be used for remuneration
     -- within BG / LEG CODE.
     open csr_unique_check('ASSIGNMENT_RENUMERATION_ALLOWED_FLAG');
     fetch csr_unique_check into v_bal_type_id;
     if csr_unique_check%found then
       close csr_unique_check;
       hr_utility.set_message(801, 'HR_6957_PAY_ONLY_ONE_RENUM');
       hr_utility.raise_error;
     else
       close csr_unique_check;
     end if;
--
   end if;
--
 end chk_balance_type;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   balance_type_cascade_delete                                           --
 -- Purpose                                                                 --
 --   Removes children of balance type on removal of a balance.             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure balance_type_cascade_delete
 (
  p_balance_type_id number
 ) is
--
   cursor get_pbas(p_def_bal number) is
   select balance_attribute_id
   from   pay_balance_attributes
   where  defined_balance_id = p_def_bal;
   --
   cursor csr_def_bals is
     select db.defined_balance_id
     from   pay_defined_balances db
     where  db.balance_type_id = p_balance_type_id
     for update;
--
 begin
--
hr_utility.set_location('Entering balance_type_cascade_delete', 5);
--
   delete from pay_balance_feeds_f bf
   where  bf.balance_type_id = p_balance_type_id;
--
   hr_utility.set_location('balance_type_cascade_delete', 10);
--
   delete from pay_balance_classifications bc
   where  bc.balance_type_id = p_balance_type_id;
--
   hr_utility.set_location('balance_type_cascade_delete', 15);
--
   for v_db_rec in csr_def_bals loop
--
   hr_utility.set_location('balance_type_cascade_delete', 20);
     --
     -- Make sure defined balance is not used by an organization payment
     -- method or a backpay set.
     pay_defined_balances_pkg.chk_delete_defined_balance
       (v_db_rec.defined_balance_id);
--
-- need to delete child rows of pay_defined_balances. User entities are don
-- in trigger pay_defined_balances_brd, going to delete for new table
-- pay_balance_attributes here.
--
     hr_utility.set_location('balance_type_cascade_delete',2);
     --
     for each_pba in get_pbas(v_db_rec.defined_balance_id) loop
        pay_balance_attribute_api.delete_balance_attribute
           (p_balance_attribute_id => each_pba.balance_attribute_id);
     end loop;
     --
     hr_utility.set_location('balance_type_cascade_delete',3);
     delete from pay_defined_balances
     where  current of csr_def_bals;
--
   end loop;
--
 end balance_type_cascade_delete;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a balance via the --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Balance_Type_Id              IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Currency_Code                       VARCHAR2,
                      X_Assignment_Remuneration_Flag        VARCHAR2,
                      X_Balance_Name                        VARCHAR2,
-- --
                      X_Base_Balance_Name                   VARCHAR2,
-- --
                      X_Balance_Uom                         VARCHAR2,
                      X_Comments                            VARCHAR2,
                      X_Legislation_Subgroup                VARCHAR2,
                      X_Reporting_Name                      VARCHAR2,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      x_balance_category_id                 number default null,
                      x_base_balance_type_id                number default null,
                      x_input_value_id                      number default null)
IS
--
   CURSOR C IS SELECT rowid FROM pay_balance_types
               WHERE  balance_type_id = X_Balance_Type_Id;
--
   CURSOR C2 IS SELECT pay_balance_types_s.nextval FROM sys.dual;
--
 BEGIN
--
   -- Make sure balance type is valid ie. unique name only one remuneration
   -- balance etc ...
   chk_balance_type
     (X_Rowid,
      X_Business_Group_Id,
      X_Legislation_Code,
      X_Balance_Name,
      X_Reporting_Name,
      X_Assignment_Remuneration_Flag);
--
-- Check if balance_category should be mandatory
--
  if chk_balance_category_rule(x_legislation_code
                              ,x_business_group_id) then
  --
    if x_balance_category_id is null then
    --
      hr_utility.set_location('pay_balance_types_pkg.insert_row', 10);
      hr_utility.set_message(801, 'PAY_34261_CAT_IS_MANDATORY');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
   if (X_Balance_Type_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Balance_Type_Id;
     CLOSE C2;
   end if;
--
   INSERT INTO pay_balance_types
   (balance_type_id,
    business_group_id,
    legislation_code,
    currency_code,
    assignment_remuneration_flag,
    balance_name,
    balance_uom,
    comments,
    legislation_subgroup,
    reporting_name,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    balance_category_id,
    base_balance_type_id,
    input_value_id)
   VALUES
   (X_Balance_Type_Id,
    X_Business_Group_Id,
    X_Legislation_Code,
    X_Currency_Code,
    X_Assignment_Remuneration_Flag,
    --X_Balance_Name,
-- --
    X_Base_Balance_Name,
-- --
    X_Balance_Uom,
    X_Comments,
    X_Legislation_Subgroup,
    X_Reporting_Name,
    X_Attribute_Category,
    X_Attribute1,
    X_Attribute2,
    X_Attribute3,
    X_Attribute4,
    X_Attribute5,
    X_Attribute6,
    X_Attribute7,
    X_Attribute8,
    X_Attribute9,
    X_Attribute10,
    X_Attribute11,
    X_Attribute12,
    X_Attribute13,
    X_Attribute14,
    X_Attribute15,
    X_Attribute16,
    X_Attribute17,
    X_Attribute18,
    X_Attribute19,
    X_Attribute20,
    x_balance_category_id,
    x_base_balance_type_id,
    x_input_value_id);
--
-- **************************************************************************
--  insert into MLS table (TL)
--
  insert into PAY_BALANCE_TYPES_TL (
    BALANCE_TYPE_ID,
    BALANCE_NAME,
    REPORTING_NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_Balance_Type_Id,
    X_Balance_Name,
    X_Reporting_Name,
    sysdate,
    sysdate,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PAY_BALANCE_TYPES_TL T
    where T.BALANCE_TYPE_ID = X_Balance_Type_Id
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
--
-- *******************************************************************************
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_types_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a balance by applying a lock on a balance in the Define Balance    --
 --   Type form.                                                            --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Currency_Code                         VARCHAR2,
                    X_Assignment_Remuneration_Flag          VARCHAR2,
                    --X_Balance_Name                        VARCHAR2,
-- --
                    X_Base_Balance_Name                     VARCHAR2,
-- --
                    X_Balance_Uom                           VARCHAR2,
                    X_Comments                              VARCHAR2,
                    X_Legislation_Subgroup                  VARCHAR2,
                    X_Reporting_Name                        VARCHAR2,
                    X_Attribute_Category                    VARCHAR2,
                    X_Attribute1                            VARCHAR2,
                    X_Attribute2                            VARCHAR2,
                    X_Attribute3                            VARCHAR2,
                    X_Attribute4                            VARCHAR2,
                    X_Attribute5                            VARCHAR2,
                    X_Attribute6                            VARCHAR2,
                    X_Attribute7                            VARCHAR2,
                    X_Attribute8                            VARCHAR2,
                    X_Attribute9                            VARCHAR2,
                    X_Attribute10                           VARCHAR2,
                    X_Attribute11                           VARCHAR2,
                    X_Attribute12                           VARCHAR2,
                    X_Attribute13                           VARCHAR2,
                    X_Attribute14                           VARCHAR2,
                    X_Attribute15                           VARCHAR2,
                    X_Attribute16                           VARCHAR2,
                    X_Attribute17                           VARCHAR2,
                    X_Attribute18                           VARCHAR2,
                    X_Attribute19                           VARCHAR2,
                    X_Attribute20                           VARCHAR2,
                    x_balance_category_id                   number default null,
                    x_base_balance_type_id                  number default null,
                    x_input_value_id                        number default null)
IS
--
   CURSOR C IS SELECT * FROM pay_balance_types
               WHERE  rowid = X_Rowid FOR UPDATE of Balance_Type_Id NOWAIT;
--
--
-- ***************************************************************************
-- cursor for MLS
--
cursor csr_balance_type_tl is
  select BALANCE_NAME,
         REPORTING_NAME,
         decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
  from PAY_BALANCE_TYPES_TL
  where BALANCE_TYPE_ID = X_BALANCE_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  for update of BALANCE_TYPE_ID nowait;
--
-- ***************************************************************************
l_mls_count    NUMBER :=0;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_types_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
/** sbilling **/
-- removed explicit lock of _TL table,
-- the MLS strategy requires that the base table is locked before update of the
-- _TL table can take place,
-- which implies it is not necessary to lock both tables.
-- ***************************************************************************
-- code for MLS
--
-- for tlinfo in csr_balance_type_tl LOOP
--    l_mls_count := l_mls_count +1;
--  if (tlinfo.BASELANG = 'Y') then
--    if (    (tlinfo.BALANCE_NAME = X_BALANCE_NAME)
--        AND ((tlinfo.REPORTING_NAME = X_REPORTING_NAME)
--             OR ((tlinfo.REPORTING_NAME is null) AND (X_REPORTING_NAME is null)))
--    ) then
--      null;
--    else
--      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
--      app_exception.raise_exception;
--    end if;
--  end if;
--end loop;
--
--if (l_mls_count=0) then -- Trap system errors
--  close csr_balance_type_tl;
--  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
--  hr_utility.set_message_token ('PROCEDURE','PAY_BALANCE_TYPES_PKG.LOCK_TL_ROW');
--end if;
--
-- ***************************************************************************
   -- Remove trailing spaces.
   Recinfo.attribute13 := rtrim(Recinfo.attribute13);
   Recinfo.attribute14 := rtrim(Recinfo.attribute14);
   Recinfo.attribute15 := rtrim(Recinfo.attribute15);
   Recinfo.attribute16 := rtrim(Recinfo.attribute16);
   Recinfo.attribute17 := rtrim(Recinfo.attribute17);
   Recinfo.attribute18 := rtrim(Recinfo.attribute18);
   Recinfo.attribute19 := rtrim(Recinfo.attribute19);
   Recinfo.attribute20 := rtrim(Recinfo.attribute20);
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.currency_code := rtrim(Recinfo.currency_code);
   Recinfo.assignment_remuneration_flag :=
     rtrim(Recinfo.assignment_remuneration_flag);
   Recinfo.balance_name := rtrim(Recinfo.balance_name);
   Recinfo.balance_uom := rtrim(Recinfo.balance_uom);
   Recinfo.comments := rtrim(Recinfo.comments);
   Recinfo.legislation_subgroup := rtrim(Recinfo.legislation_subgroup);
   Recinfo.reporting_name := rtrim(Recinfo.reporting_name);
   Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
   Recinfo.attribute1 := rtrim(Recinfo.attribute1);
   Recinfo.attribute2 := rtrim(Recinfo.attribute2);
   Recinfo.attribute3 := rtrim(Recinfo.attribute3);
   Recinfo.attribute4 := rtrim(Recinfo.attribute4);
   Recinfo.attribute5 := rtrim(Recinfo.attribute5);
   Recinfo.attribute6 := rtrim(Recinfo.attribute6);
   Recinfo.attribute7 := rtrim(Recinfo.attribute7);
   Recinfo.attribute8 := rtrim(Recinfo.attribute8);
   Recinfo.attribute9 := rtrim(Recinfo.attribute9);
   Recinfo.attribute10 := rtrim(Recinfo.attribute10);
   Recinfo.attribute11 := rtrim(Recinfo.attribute11);
   Recinfo.attribute12 := rtrim(Recinfo.attribute12);
   Recinfo.balance_category_id := rtrim(Recinfo.balance_category_id);
   Recinfo.base_balance_type_id := rtrim(Recinfo.base_balance_type_id);
   Recinfo.input_value_id := rtrim(Recinfo.input_value_id);
--
   if (    (   (Recinfo.balance_type_id = X_Balance_Type_Id)
            OR (    (Recinfo.balance_type_id IS NULL)
                AND (X_Balance_Type_Id IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.currency_code = X_Currency_Code)
            OR (    (Recinfo.currency_code IS NULL)
                AND (X_Currency_Code IS NULL)))
       AND (   (Recinfo.assignment_remuneration_flag =
                X_Assignment_Remuneration_Flag)
            OR (    (Recinfo.assignment_remuneration_flag IS NULL)
                AND (X_Assignment_Remuneration_Flag IS NULL)))
-- --
--     AND (   (Recinfo.balance_name = X_Balance_Name)
--          OR (    (Recinfo.balance_name IS NULL)
--              AND (X_Balance_Name IS NULL)))
       AND (   (Recinfo.balance_name = X_Base_Balance_Name)
            OR (    (Recinfo.balance_name IS NULL)
                AND (X_Base_Balance_Name IS NULL)))
-- --
       AND (   (Recinfo.balance_uom = X_Balance_Uom)
            OR (    (Recinfo.balance_uom IS NULL)
                AND (X_Balance_Uom IS NULL)))
       AND (   (Recinfo.comments = X_Comments)
            OR (    (Recinfo.comments IS NULL)
                AND (X_Comments IS NULL)))
       AND (   (Recinfo.legislation_subgroup = X_Legislation_Subgroup)
            OR (    (Recinfo.legislation_subgroup IS NULL)
                AND (X_Legislation_Subgroup IS NULL)))
       AND (   (Recinfo.reporting_name = X_Reporting_Name)
            OR (    (Recinfo.reporting_name IS NULL)
                AND (X_Reporting_Name IS NULL)))
       AND (   (Recinfo.attribute_category = X_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (X_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 = X_Attribute1)
            OR (    (Recinfo.attribute1 IS NULL)
                AND (X_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 = X_Attribute2)
            OR (    (Recinfo.attribute2 IS NULL)
                AND (X_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 = X_Attribute3)
            OR (    (Recinfo.attribute3 IS NULL)
                AND (X_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 = X_Attribute4)
            OR (    (Recinfo.attribute4 IS NULL)
                AND (X_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 = X_Attribute5)
            OR (    (Recinfo.attribute5 IS NULL)
                AND (X_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 = X_Attribute6)
            OR (    (Recinfo.attribute6 IS NULL)
                AND (X_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 = X_Attribute7)
            OR (    (Recinfo.attribute7 IS NULL)
                AND (X_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 = X_Attribute8)
            OR (    (Recinfo.attribute8 IS NULL)
                AND (X_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 = X_Attribute9)
            OR (    (Recinfo.attribute9 IS NULL)
                AND (X_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 = X_Attribute10)
            OR (    (Recinfo.attribute10 IS NULL)
                AND (X_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 = X_Attribute11)
            OR (    (Recinfo.attribute11 IS NULL)
                AND (X_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 = X_Attribute12)
            OR (    (Recinfo.attribute12 IS NULL)
                AND (X_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 = X_Attribute13)
            OR (    (Recinfo.attribute13 IS NULL)
                AND (X_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 = X_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (X_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 = X_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (X_Attribute15 IS NULL)))
       AND (   (Recinfo.attribute16 = X_Attribute16)
            OR (    (Recinfo.attribute16 IS NULL)
                AND (X_Attribute16 IS NULL)))
       AND (   (Recinfo.attribute17 = X_Attribute17)
            OR (    (Recinfo.attribute17 IS NULL)
                AND (X_Attribute17 IS NULL)))
       AND (   (Recinfo.attribute18 = X_Attribute18)
            OR (    (Recinfo.attribute18 IS NULL)
                AND (X_Attribute18 IS NULL)))
       AND (   (Recinfo.attribute19 = X_Attribute19)
            OR (    (Recinfo.attribute19 IS NULL)
                AND (X_Attribute19 IS NULL)))
       AND (   (Recinfo.attribute20 = X_Attribute20)
            OR (    (Recinfo.attribute20 IS NULL)
                AND (X_Attribute20 IS NULL)))
       AND (   (Recinfo.balance_category_id = x_balance_category_id)
            OR (    (Recinfo.balance_category_id IS NULL)
                AND (x_balance_category_id IS NULL)))
       AND (   (Recinfo.base_balance_type_id = x_base_balance_type_id)
            OR (    (Recinfo.base_balance_type_id IS NULL)
                AND (x_base_balance_type_id IS NULL)))
       AND (   (Recinfo.input_value_id = x_input_value_id)
            OR (    (Recinfo.input_value_id IS NULL)
                AND (x_input_value_id IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a balance via the --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Currency_Code                       VARCHAR2,
                      X_Assignment_Remuneration_Flag        VARCHAR2,
                      X_Balance_Name                        VARCHAR2,
		      X_Base_Balance_Name                   VARCHAR2,
                      X_Balance_Uom                         VARCHAR2,
                      X_Comments                            VARCHAR2,
                      X_Legislation_Subgroup                VARCHAR2,
                      X_Reporting_Name                      VARCHAR2,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      x_balance_category_id                 number default null,
                      x_base_balance_type_id                number default null,
                      x_input_value_id                      number default null)
 IS
--
 BEGIN
--
   -- Make sure balance type is valid ie. unique name only one remuneration
   -- balance etc ...
   chk_balance_type
     (X_Rowid,
      X_Business_Group_Id,
      X_Legislation_Code,
      X_Balance_Name,
      X_Reporting_Name,
      X_Assignment_Remuneration_Flag);
--
-- Check if balance_category should be mandatory
--
hr_utility.trace('upd_leg: '||x_legislation_code);
hr_utility.trace('upd_bg: '||to_char(x_business_group_id));
hr_utility.trace('upd_cat: '||x_balance_category_id);
  if chk_balance_category_rule(x_legislation_code
                              ,x_business_group_id) then
  --
    if x_balance_category_id is null then
    --
      hr_utility.set_location('pay_balance_types_pkg.insert_row', 10);
      hr_utility.set_message(801, 'PAY_34261_CAT_IS_MANDATORY');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
   UPDATE pay_balance_types
   SET balance_type_id                =    X_Balance_Type_Id,
       business_group_id              =    X_Business_Group_Id,
       legislation_code               =    X_Legislation_Code,
       currency_code                  =    X_Currency_Code,
       assignment_remuneration_flag   =    X_Assignment_Remuneration_Flag,
-- --
       balance_name                   =    X_Base_Balance_Name,
-- --
       balance_uom                    =    X_Balance_Uom,
       comments                       =    X_Comments,
       legislation_subgroup           =    X_Legislation_Subgroup,
       reporting_name                 =    X_Reporting_Name,
       attribute_category             =    X_Attribute_Category,
       attribute1                     =    X_Attribute1,
       attribute2                     =    X_Attribute2,
       attribute3                     =    X_Attribute3,
       attribute4                     =    X_Attribute4,
       attribute5                     =    X_Attribute5,
       attribute6                     =    X_Attribute6,
       attribute7                     =    X_Attribute7,
       attribute8                     =    X_Attribute8,
       attribute9                     =    X_Attribute9,
       attribute10                    =    X_Attribute10,
       attribute11                    =    X_Attribute11,
       attribute12                    =    X_Attribute12,
       attribute13                    =    X_Attribute13,
       attribute14                    =    X_Attribute14,
       attribute15                    =    X_Attribute15,
       attribute16                    =    X_Attribute16,
       attribute17                    =    X_Attribute17,
       attribute18                    =    X_Attribute18,
       attribute19                    =    X_Attribute19,
       attribute20                    =    X_Attribute20,
       balance_category_id            =    x_balance_category_id,
       base_balance_type_id           =    x_base_balance_type_id,
       input_value_id                 =    x_input_value_id

   WHERE rowid = X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_types_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
-- ****************************************************************************************
--
--  update MLS table (TL)
--
  update PAY_BALANCE_TYPES_TL
  set BALANCE_NAME        = X_BALANCE_NAME,
      REPORTING_NAME      = X_REPORTING_NAME,
      LAST_UPDATE_DATE    = sysdate,
      SOURCE_LANG         = userenv('LANG')
  where BALANCE_TYPE_ID = X_BALANCE_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--
--
if (sql%notfound) then	-- trap system errors during update
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token ('PROCEDURE','PAY_BALANCE_TYPES_PKG.UPDATE_TL_ROW');
end if;
--
-- ***************************************************************************************
--
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a balance via the --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid            VARCHAR2,
		      -- Extra Columns
		      X_Balance_Type_Id  NUMBER) IS
--
 BEGIN
--
   -- Remove balance feeds, balance classifications and defined balances.
   balance_type_cascade_delete(X_Balance_Type_Id);
--
   DELETE FROM pay_balance_types
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_balance_types_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
-- ****************************************************************************
--
-- delete from MLS table (TL)
--
--
-- bugfix 1229606
-- only delete data from the translated tables if the date track mode is ZAP,
-- for all other date track modes the data should remain untouched
--
--if p_delete_mode = 'ZAP' then

  delete from PAY_BALANCE_TYPES_TL
  where BALANCE_TYPE_ID = X_BALANCE_TYPE_ID;
--
  if sql%notfound then -- trap system errors during deletion
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PAY_BALANCE_TYPES_PKG.DELETE_TL_ROW');
  end if;

--end if;
--
-- ****************************************************************************
--
 END Delete_Row;
--
--
--
------------------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_BALANCE_TYPES_TL T
  where not exists
    (select NULL
    from PAY_BALANCE_TYPES B
    where B.BALANCE_TYPE_ID = T.BALANCE_TYPE_ID
    );

  update PAY_BALANCE_TYPES_TL T set (
      BALANCE_NAME,
      REPORTING_NAME
    ) = (select
      B.BALANCE_NAME,
      B.REPORTING_NAME
    from PAY_BALANCE_TYPES_TL B
    where B.BALANCE_TYPE_ID = T.BALANCE_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BALANCE_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BALANCE_TYPE_ID,
      SUBT.LANGUAGE
    from PAY_BALANCE_TYPES_TL SUBB, PAY_BALANCE_TYPES_TL SUBT
    where SUBB.BALANCE_TYPE_ID = SUBT.BALANCE_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.BALANCE_NAME <> SUBT.BALANCE_NAME
      or SUBB.REPORTING_NAME <> SUBT.REPORTING_NAME
      or (SUBB.REPORTING_NAME is null and SUBT.REPORTING_NAME is not null)
      or (SUBB.REPORTING_NAME is not null and SUBT.REPORTING_NAME is null)
  ));

  insert into PAY_BALANCE_TYPES_TL (
    BALANCE_TYPE_ID,
    BALANCE_NAME,
    REPORTING_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BALANCE_TYPE_ID,
    B.BALANCE_NAME,
    B.REPORTING_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_BALANCE_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_BALANCE_TYPES_TL T
    where T.BALANCE_TYPE_ID = B.BALANCE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-----------------------------------------------------------------------------
procedure unique_chk(X_B_BALANCE_NAME in VARCHAR2, X_B_LEGISLATION_CODE in VARCHAR2)
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM pay_balance_types
  WHERE nvl(BALANCE_NAME,'~null~') = nvl(X_B_BALANCE_NAME,'~null~')
    and nvl(LEGISLATION_CODE,'~null~') = nvl(X_B_LEGISLATION_CODE,'~null~')
    and BUSINESS_GROUP_ID is NULL;
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_BALANCE_TYPES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_BALANCE_TYPES_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
end unique_chk;
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_B_BALANCE_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_BALANCE_NAME in VARCHAR2,
   X_REPORTING_NAME in VARCHAR2,
   X_OWNER in VARCHAR2) is
--
-- Fetch the element_type_id. This used to be a sub-query in the update
-- statement.
--
cursor csr_bal_id is
select balance_type_id
from   pay_balance_types
where  nvl(balance_name,'~null~')=nvl(x_b_balance_name,'~null~')
and    nvl(legislation_code,'~null~') = nvl(x_b_legislation_code,'~null~')
and    business_group_id is null
;
--
-- Fetch information for the _TL rows that will be affected by the update.
--
cursor csr_tl_info
(p_balance_type_id in number
,p_language        in varchar2
) is
select balance_name
,      language
from   pay_balance_types_tl
where  balance_type_id = p_balance_type_id
and    p_language in (language, source_lang)
;
--
l_balance_type_id number;
l_found           boolean;
i                 binary_integer := 1;
l_langs           dbms_sql.varchar2s;
l_lang            varchar2(100);
begin
  --
  -- Fetch the balance_type_id.
  --
  open  csr_bal_id;
  fetch csr_bal_id
  into  l_balance_type_id
  ;
  l_found := csr_bal_id%found;
  close csr_bal_id;

  l_lang := userenv('LANG');

  if l_found then
    --
    -- Check if database item translations are supported.
    --
    if ff_dbi_utils_pkg.translations_supported
       (p_legislation_code => x_b_legislation_code
       ) then
      for crec in  csr_tl_info
                   (p_balance_type_id => l_balance_type_id
                   ,p_language        => l_lang
                   ) loop
        if upper(crec.balance_name) <> upper(x_balance_name) then
          l_langs(i) := crec.language;
          i := i + 1;
        end if;
      end loop;
    end if;

    UPDATE pay_balance_types_tl
    SET    balance_name = nvl(x_balance_name,balance_name),
           reporting_name = nvl(x_reporting_name,reporting_name),
           last_update_date = Sysdate,
           last_updated_by = decode(x_owner,'SEED',1,0),
           last_update_login = 0,
           source_lang = userenv('LANG')
    WHERE  userenv('LANG') IN (language,source_lang)
    AND    balance_type_id = l_balance_type_id
    ;

    --
    -- Write any changes to PAY_DYNDBI_CHANGES.
    --
    if l_langs.count <> 0 then
      pay_dyndbi_changes_pkg.balance_type_change
      (p_balance_type_id => l_balance_type_id
      ,p_languages       => l_langs
      );
    end if;
  end if;
end TRANSLATE_ROW;
--------------------------------------------------------------------------------
END PAY_BALANCE_TYPES_PKG;

/
