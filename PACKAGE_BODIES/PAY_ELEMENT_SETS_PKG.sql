--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_SETS_PKG" as
/* $Header: pyels01t.pkb 120.1 2005/09/30 00:32:03 tvankayl noship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_element_sets_pkg
  Purpose
    Supports the ELS block in the form PAYWSDRP (Define Element and
    Distributuion Set.
  Notes

  History
    24-Mar-94  J.S.Hobbs   40.0         Date created.
    22-Apr-94  J.S.Hobbs   40.1         Added rtrim to Lock_Row.
    05-Mar-97  J.Alloun    40.7         Changed all occurances of system.dual
                                        to sys.dual for next release requirements.
   22-Sep-05  Shisriva      115.3        Changes for MLS enabling and dual maintenance.
   26-Sep-05  Shisriva      115.4        Added dbdrv commands.
   26-Sep-05  Shisriva      115.5        Removed gscc violation for in out parameters.
						     Added NOCOPY for two parameters.
   30-Sep-05  tvankayl      115.6        Added delete validation for element
                                         sets of element_set_type = 'E'.
                                         The changes were initially made in
                                         the branch version 115.2.1159.2.
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   lock_element_set                                                      --
 -- Purpose                                                                 --
 --   Places a lock on the element set.                                     --
 -- Arguments                                                               --
 --   See Be;ow.                                                            --
 -- Notes                                                                   --
 --   Used when maintaining the members of an element set ie. when dealing  --
 --   with element type rules and classification rules.                     --
 -----------------------------------------------------------------------------
--
g_dummy	number(1);	-- Dummy for cursor returns which are not needed.
g_business_group_id number(15); -- For validating translation.
g_legislation_code varchar2(150); -- For validating translation.
--
 procedure lock_element_set
 (
  p_element_set_id number
 ) is
--
   cursor csr_element_set is
     select els.element_set_id
     from   pay_element_sets els
     where  els.element_set_id = p_element_set_id
     for update;
--
   v_dummy number;
--
 begin
--
   open csr_element_set;
   fetch csr_element_set into v_dummy;
   if csr_element_set%notfound then
     close csr_element_set;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_sets_pkg.lock_element_set');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   else
     close csr_element_set;
   end if;
--
 end lock_element_set;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_debit_or_credit                                                   --
 -- Purpose                                                                 --
 --   When creating a distribution set all the elements within the set must --
 --   have the same debit or credit status ie. the combination of element   --
 --   rules and classification rules should result in a set of elements     --
 --   that have the same debit or credit status.                            --
 -- Arguments                                                               --
 --   p_classification_id - If adding an element type rule then this is the --
 --                         classification_of the element being added.      --
 --                         If adding a classification rule then this is    --
 --                         classification_of of the classification being   --
 --                         added.                                          --
 -- Notes                                                                   --
 --   This is used when adding element type or classification rules.        --
 -----------------------------------------------------------------------------
--
 procedure chk_debit_or_credit
 (
  p_element_set_id    number,
  p_classification_id number
 ) is
--
   cursor csr_debit_or_credit_ele_rule is
     select ecl.costing_debit_or_credit
     from   pay_element_classifications ecl
     where  ecl.classification_id = p_classification_id
       and  exists
            (select null
             from   pay_element_type_rules etr,
		    pay_element_types_f et,
                    pay_element_classifications ecl2
             where  etr.element_set_id = p_element_set_id
	       and  et.element_type_id = etr.element_type_id
               and  ecl2.classification_id = et.classification_id
               and  ecl2.costing_debit_or_credit <>
                      ecl.costing_debit_or_credit);
--
   cursor csr_debit_or_credit_class_rule is
     select ecl.costing_debit_or_credit
     from   pay_element_classifications ecl
     where  ecl.classification_id = p_classification_id
       and  exists
            (select null
             from   pay_ele_classification_rules ecr,
                    pay_element_classifications ecl2
             where  ecr.element_set_id = p_element_set_id
               and  ecl2.classification_id = ecr.classification_id
               and  ecl2.costing_debit_or_credit <>
                      ecl.costing_debit_or_credit);
--
   v_debit_or_credit_code varchar2(30);
--
 begin
--
   -- Make sure that all elements are the same regarding debit or credit
   -- status NB. this checks for existing element type rules for the element
   -- set.
   open csr_debit_or_credit_ele_rule;
   fetch csr_debit_or_credit_ele_rule into v_debit_or_credit_code;
   if csr_debit_or_credit_ele_rule%found then
     close csr_debit_or_credit_ele_rule;
     hr_utility.set_message(801, 'HR_6547_ELE_SET_CR_OR_DB');
     hr_utility.set_message_token('CREDIT_OR_DEBIT', '???');
     hr_utility.raise_error;
   else
     close csr_debit_or_credit_ele_rule;
   end if;
--
   -- Make sure that all elements are the same regarding debit or credit
   -- status NB. this checks for existing element classification rules for
   -- the element set.
   open csr_debit_or_credit_class_rule;
   fetch csr_debit_or_credit_class_rule into v_debit_or_credit_code;
   if csr_debit_or_credit_class_rule%found then
     close csr_debit_or_credit_class_rule;
     hr_utility.set_message(801, 'HR_6547_ELE_SET_CR_OR_DB');
     hr_utility.set_message_token('CREDIT_OR_DEBIT', '???');
     hr_utility.raise_error;
   else
     close csr_debit_or_credit_class_rule;
   end if;
--
 end chk_debit_or_credit;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   check_unique_set                                                      --
 -- Purpose                                                                 --
 --   Makes sure the element set name is unique within the legislation and  --
 --   business group.                                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure check_unique_set
 (
  p_rowid             varchar2,
  p_business_group_id number,
  p_legislation_code  varchar2,
  p_element_set_name  varchar2
 ) is
--
   cursor csr_unique_set is
     select els.element_set_id
     from   pay_element_sets els
     where  upper(els.element_set_name) = upper(p_element_set_name)
       and  nvl(els.business_group_id,nvl(p_business_group_id,0)) =
	      nvl(p_business_group_id,0)
       and  nvl(els.legislation_code,nvl(p_legislation_code,' ')) =
	      nvl(p_legislation_code,' ')
       and  (p_rowid is null or
	    (p_rowid is not null and chartorowid(p_rowid) <> els.rowid));
--
   v_dummy number;
--
 begin
--
   open csr_unique_set;
   fetch csr_unique_set into v_dummy;
   if csr_unique_set%found then
     close csr_unique_set;
     hr_utility.set_message(801, 'HR_6055_ELE_SET_UNIQUE_NAME');
     hr_utility.raise_error;
   else
     close csr_unique_set;
   end if;
--
 end check_unique_set;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_delete_element_set                                                --
 -- Purpose                                                                 --
 --   Checks to see if the element set is being used.                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Checks PAY_RESTRICTION_VALUES, PAY_ELEMENT_LINKS_F and                --
 --   PAY_PAYROLL_ACTIONS.                                                  --
 -----------------------------------------------------------------------------
--
 procedure chk_delete_element_set
 (
  p_element_set_id   number,
  p_element_set_type varchar2
 ) is
--
   cursor csr_element_links is
     select el.element_set_id
     from   pay_element_links_f el
     where  el.element_set_id = p_element_set_id;
--
   cursor csr_payroll_actions is
     select pa.element_set_id
     from   pay_payroll_actions pa
     where  pa.element_set_id = p_element_set_id;
--
   cursor csr_restriction_values is
     select fnd_number.canonical_to_number(rv.value)
     from  pay_restriction_values rv
     where rv.restriction_code = 'ELEMENT_SET'
       and rv.value = to_char(p_element_set_id);
--
   cursor csr_element_set_usages is
     select egu.element_set_id
     from   pay_event_group_usages egu
     where  egu.element_set_id = p_element_set_id;
--
   v_dummy number;
--
 begin
--
   -- Element links can only use Distribution Sets.
   if p_element_set_type = 'D' then
--
     open csr_element_links;
     fetch csr_element_links into v_dummy;
     if csr_element_links%found then
       close csr_element_links;
       hr_utility.set_message(801, 'HR_6051_ELE_SET_SET_DELETES');
       hr_utility.raise_error;
     else
       close csr_element_links;
     end if;
--
   -- Payroll actions can only use Run Sets.
   elsif p_element_set_type = 'R' then
--
     open csr_payroll_actions;
     fetch csr_payroll_actions into v_dummy;
     if csr_payroll_actions%found then
       close csr_payroll_actions;
       hr_utility.set_message(801, 'HR_6054_ELE_SET_SET_DELETES');
       hr_utility.raise_error;
     else
       close csr_payroll_actions;
     end if;
--
   -- Forms customization can only use Customization Sets.
   elsif p_element_set_type = 'C' then
--
     open csr_restriction_values;
     fetch csr_restriction_values into v_dummy;
     if csr_restriction_values%found then
       close csr_restriction_values;
       hr_utility.set_message(801, 'HR_6050_ELE_SET_SET_DELETES');
       hr_utility.raise_error;
     else
       close csr_restriction_values;
     end if;
   elsif p_element_set_type = 'E' then

     open csr_element_set_usages;
     fetch csr_element_set_usages into v_dummy;
     if csr_element_set_usages%found then
       close csr_element_set_usages;
       hr_utility.set_message(801, 'PAY_294526_ECU_CHILD_EXISTS');
       hr_utility.raise_error;
     else
       close csr_element_set_usages;
     end if;
--
  end if;
--
 end chk_delete_element_set;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   delete_element_set_cascade                                            --
 -- Purpose                                                                 --
 --   Removes all children of an element set.                               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Removes PAY_ELEMENT_TYPE_RULES and PAY_ELE_CLASSIFICATION_RULES.      --
 -----------------------------------------------------------------------------
--
 procedure delete_element_set_cascade
 (
  p_element_set_id number
 ) is
--
 begin
--
   delete from pay_element_type_rules
   where  element_set_id = p_element_set_id;
--
   delete from pay_ele_classification_rules
   where  element_set_id = p_element_set_id;
--
 end delete_element_set_cascade;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of an element set    --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,
                      X_Element_Set_Id              IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Element_Set_Name                    VARCHAR2,
                      X_Element_Set_Type                    VARCHAR2,
                      X_Comments                            VARCHAR2,
                      -- Extra Columns
                      X_Session_Business_Group_Id           NUMBER,
                      X_Session_Legislation_Code            VARCHAR2) IS
--
   CURSOR C IS SELECT rowid FROM pay_element_sets
               WHERE  element_set_id = X_Element_Set_Id;
--
   CURSOR C2 IS SELECT pay_element_sets_s.nextval FROM sys.dual;
--
 BEGIN
--
   check_unique_set
     (X_Rowid,
      X_Session_Business_Group_Id,
      X_Session_Legislation_Code,
      X_Element_Set_Name);
--
   if (X_Element_Set_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Element_Set_Id;
     CLOSE C2;
   end if;
--
--MLS validation for uniqueness-----------------
 validate_translation (X_Element_Set_Id,
                      userenv('lang'),
                      X_Element_Set_Name,
                      X_Business_Group_Id,
                      X_Legislation_Code);
---
   INSERT INTO pay_element_sets
   (element_set_id,
    business_group_id,
    legislation_code,
    element_set_name,
    element_set_type,
    comments
    )
   VALUES
   (X_Element_Set_Id,
    X_Business_Group_Id,
    X_Legislation_Code,
    X_Element_Set_Name,
    X_Element_Set_Type,
    X_Comments
    );
--
---For MLS----------------------------------------------------------------------
if(PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y') then
pay_est_ins.ins_tl(userenv('LANG'),x_element_set_id,x_element_set_name);
end if;
--------------------------------------------------------------------------------
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_sets_pkg.insert_row');
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
 --   of an element set by applying a lock on an element set within the     --
 --   Define Element and Distribution Set form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Element_Set_Id                        NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Element_Set_Name                      VARCHAR2,
                    X_Element_Set_Type                      VARCHAR2,
                    X_Comments                              VARCHAR2) IS
--
   CURSOR C IS SELECT * FROM  pay_element_sets
               WHERE  rowid = X_Rowid FOR UPDATE of Element_Set_Id NOWAIT;
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
                                  'pay_element_sets_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces.
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.element_set_name := rtrim(Recinfo.element_set_name);
   Recinfo.element_set_type := rtrim(Recinfo.element_set_type);
   Recinfo.comments := rtrim(Recinfo.comments);
--
   if (    (   (Recinfo.element_set_id = X_Element_Set_Id)
            OR (    (Recinfo.element_set_id IS NULL)
                AND (X_Element_Set_Id IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.element_set_name = X_Element_Set_Name)
            OR (    (Recinfo.element_set_name IS NULL)
                AND (X_Element_Set_Name IS NULL)))
       AND (   (Recinfo.element_set_type = X_Element_Set_Type)
            OR (    (Recinfo.element_set_type IS NULL)
                AND (X_Element_Set_Type IS NULL)))
       AND (   (Recinfo.comments = X_Comments)
            OR (    (Recinfo.comments IS NULL)
                AND (X_Comments IS NULL)))
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
 --   Table handler procedure that supports the update of an element set    --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Element_Set_Id                      NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Element_Set_Name                    VARCHAR2,
                      X_Element_Set_Type                    VARCHAR2,
                      X_Comments                            VARCHAR2,
                      -- Extra Columns
                      X_Session_Business_Group_Id           NUMBER,
                      X_Session_Legislation_Code            VARCHAR2,
		      X_Base_Element_Set_Name in varchar2 default hr_api.g_varchar2) IS
 BEGIN
--
   check_unique_set
     (X_Rowid,
      X_Session_Business_Group_Id,
      X_Session_Legislation_Code,
      X_Element_Set_Name);
--
UPDATE pay_element_sets
   SET element_set_id       =    X_Element_Set_Id,
       business_group_id    =    X_Business_Group_Id,
       legislation_code     =    X_Legislation_Code,
       element_set_name     =    X_Element_Set_Name,
       element_set_type     =    X_Element_Set_Type,
       comments             =    X_Comments
   WHERE rowid = X_rowid;

--For MLS-----------------------------------------------------------------------
---For sustaining dual maintenance----------
if(PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y') then
   --MLS validation for uniqueness-----------------

 validate_translation (X_Element_Set_Id,
                      userenv('lang'),
                      X_Element_Set_Name,
                      X_Business_Group_Id,
                      X_Legislation_Code);
---
   UPDATE pay_element_sets
   SET element_set_id       =    X_Element_Set_Id,
       business_group_id    =    X_Business_Group_Id,
       legislation_code     =    X_Legislation_Code,
       element_set_name     =    X_Base_Element_Set_Name,
       element_set_type     =    X_Element_Set_Type,
       comments             =    X_Comments
   WHERE rowid = X_rowid;
--
pay_est_upd.upd_tl(userenv('LANG'),x_element_set_id,X_Element_Set_Name);
end if;
--------------------------------------------------------------------------------
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_sets_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of an element set    --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
                      -- Extra Columns
                      X_Element_Set_Id                      NUMBER,
                      X_Element_Set_Type                    VARCHAR2) IS
 BEGIN
--
   chk_delete_element_set
     (X_Element_Set_Id,
      X_Element_Set_Type);
--
   delete_element_set_cascade
     (X_Element_Set_Id);
--
---For MLS----------------------------------------------------------------------
if(PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y') then
pay_est_del.del_tl(x_element_set_id);
end if;
--------------------------------------------------------------------------------
--
   DELETE FROM pay_element_sets
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_sets_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
--MLS Additions---
--
procedure ADD_LANGUAGE
is
begin
  delete from PAY_ELEMENT_SETS_TL T
  where not exists
    (select NULL
     from PAY_ELEMENT_SETS B
     where B.ELEMENT_SET_ID = T.ELEMENT_SET_ID
    );
  update PAY_ELEMENT_SETS_TL T
  set (ELEMENT_SET_NAME) =
  (select B.ELEMENT_SET_NAME
   from PAY_ELEMENT_SETS_TL B
   where B.ELEMENT_SET_ID = T.ELEMENT_SET_ID
   and B.LANGUAGE = T.SOURCE_LANG)
  where (T.ELEMENT_SET_ID,T.LANGUAGE) in
  (select SUBT.ELEMENT_SET_ID,SUBT.LANGUAGE
    from PAY_ELEMENT_SETS_TL SUBB, PAY_ELEMENT_SETS_TL SUBT
    where SUBB.ELEMENT_SET_ID = SUBT.ELEMENT_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ELEMENT_SET_NAME <> SUBT.ELEMENT_SET_NAME
  ));

  insert into PAY_ELEMENT_SETS_TL (
    ELEMENT_SET_ID,
    ELEMENT_SET_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ELEMENT_SET_ID,
    B.ELEMENT_SET_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_ELEMENT_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_ELEMENT_SETS_TL T
    where T.ELEMENT_SET_ID = B.ELEMENT_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
procedure TRANSLATE_ROW (X_B_ELEMENT_SET_NAME in VARCHAR2,
					    X_B_LEGISLATION_CODE in VARCHAR2,
					    X_ELEMENT_SET_NAME in VARCHAR2,
					    X_OWNER in VARCHAR2) is
begin
  UPDATE PAY_ELEMENT_SETS_TL
    SET ELEMENT_SET_NAME = nvl(X_ELEMENT_SET_NAME,ELEMENT_SET_NAME),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND ELEMENT_SET_ID in
        (select ELEMENT_SET_ID
           from PAY_ELEMENT_SETS
          where nvl(ELEMENT_SET_NAME,'~null~')=nvl(X_B_ELEMENT_SET_NAME,'~null~')
            and nvl(LEGISLATION_CODE,'~null~') = nvl(X_B_LEGISLATION_CODE,'~null~')
            and BUSINESS_GROUP_ID is NULL);
  if (sql%notfound) then
  null;
  end if;
end TRANSLATE_ROW;
--
--
procedure set_translation_globals( p_business_group_id IN NUMBER
                                 , p_legislation_code  IN NUMBER) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--
procedure validate_translation(element_set_id	NUMBER,
			       language		VARCHAR2,
			       element_set_name	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
                               p_legislation_code IN VARCHAR2 DEFAULT NULL) IS
/*

This procedure fails if a user_table translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated user_table names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_element_set_name IN VARCHAR2,
                     p_element_set_id IN NUMBER,
                     p_bus_grp_id IN NUMBER,
		     p_leg_code IN varchar2)  IS
       SELECT  1
	 FROM  pay_element_sets_tl est,
	       pay_element_sets    els
	 WHERE upper(est.element_set_name)=upper(p_element_set_name)
	 AND   est.element_set_id = els.element_set_id
	 AND   est.language = p_language
	 AND   (els.element_set_id <> p_element_set_id OR p_element_set_id IS NULL)
	 AND   (nvl(els.business_group_id,-1) = nvl(p_bus_grp_id,-1) OR p_bus_grp_id IS NULL)
	 AND   (nvl(els.LEGISLATION_CODE,'~null~') = nvl(p_leg_code,'~null~') OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80);
       l_business_group_id NUMBER;
       l_legislation_code VARCHAR2(150);

BEGIN
   l_package_name  := 'PAY_ELEMENT_SETS_PKG.VALIDATE_TRANSLATION';
   l_business_group_id := p_business_group_id;
   l_legislation_code  := p_legislation_code;
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, element_set_name,element_set_id,
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

--
function return_dml_status
return boolean
IS
begin
return g_dml_status;
end return_dml_status;
--
--
END PAY_ELEMENT_SETS_PKG;

/
