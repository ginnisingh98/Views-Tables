--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TYPE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TYPE_RULES_PKG" as
/* $Header: pyetr01t.pkb 115.0 99/07/17 06:02:13 porting ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_element_type_rules_pkg
  Purpose
    Supports the ETR block in the form PAYWSDRP (Define Element and
    Distributuion Set.
  Notes

  History
    24-Mar-94  J.S.Hobbs   40.0         Date created.
    22-Apr-94  J.S.Hobbs   40.1         Added rtrim to Lock_Row.
    25-Jul-95  A.R.R.Mills 40.4         Changed tokenised message
					'HR_6056_ELE_SET_CLASS_EXISTS'
					to hard coded message
					'HR_7701_ELE_SET_CLASS_EXIST'.


============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   include_element                                                       --
 -- Purpose                                                                 --
 --   Adds an element to a set NB. this may involve adding an include       --
 --   element rule or removing an exclude element rule.                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure include_element
 (
  p_element_set_id    number,
  p_element_type_id   number,
  p_classification_id number,
  p_element_set_type  varchar2
 ) is
--
   cursor csr_class_rule is
     select ecr.classification_id
     from   pay_ele_classification_rules ecr
     where  ecr.element_set_id = p_element_set_id
       and  ecr.classification_id = p_classification_id
       and  not exists
	      (select null
	       from   pay_element_type_rules etr
	       where  etr.element_set_id = ecr.element_set_id
		 and  etr.element_type_id = p_element_type_id
		 and  etr.include_or_exclude = 'E');
--
   v_dummy number;
--
 begin
--
   -- Lock element set to preserve the current definition.
   pay_element_sets_pkg.lock_element_set
     (p_element_set_id);
--
   -- Check to see if the element rule to be inserted will clash with an
   -- existing classification rule ie. an element type can only be included
   -- once - either by a classification rule or an include element rule.
   open csr_class_rule;
   fetch csr_class_rule into v_dummy;
   if csr_class_rule%found then
     close csr_class_rule;
     hr_utility.set_message(801, 'HR_7102_ELE_SET_CLASS_EXISTS');
     hr_utility.raise_error;
   else
     close csr_class_rule;
   end if;
--
   -- If an element type rule is being added to a distribution set then make
   -- sure that all the elements belong to the same debit or credit status.
   if p_element_set_type = 'D' then
--
     pay_element_sets_pkg.chk_debit_or_credit
       (p_element_set_id,
        p_classification_id);
--
   end if;
--
   -- Create an include element type rule for the element.
   insert into pay_element_type_rules
   (element_type_id,
    element_set_id,
    include_or_exclude,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   select
    p_element_type_id,
    p_element_set_id,
    'I',
    trunc(sysdate),
    0,
    0,
    0,
    trunc(sysdate)
   from  sys.dual
   where not exists
          (select null
           from   pay_element_type_rules etr
           where  etr.element_set_id = p_element_set_id
             and  etr.element_type_id = p_element_type_id);
--
   -- Element rule could not be created as there already exists an element rule
   -- for this element. Remove the element rule if it is excluded ie. this will
   -- then make the element part of the set.
   if sql%notfound then
--
     delete from pay_element_type_rules etr
     where  etr.element_set_id = p_element_set_id
       and  etr.element_type_id = p_element_type_id
       and  etr.include_or_exclude = 'E';
--
     -- The insert of an include element rule and the removal of an exclude
     -- element rule have both failed which means the element is already part
     -- of the set.
     if sql%notfound then
       hr_utility.set_message(801, 'HR_7701_ELE_SET_CLASS_EXIST');
       hr_utility.raise_error;
     end if;
--
   end if;
--
 end include_element;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   exclude_element                                                       --
 -- Purpose                                                                 --
 --   Removes an element from a set NB. this may involve adding an exclude  --
 --   element rule or removing an include element rule.                     --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure exclude_element
 (
  p_element_set_id  number,
  p_element_type_id number
 ) is
--
 begin
--
   -- Lock element set to preserve the current definition.
   pay_element_sets_pkg.lock_element_set
     (p_element_set_id);
--
   -- Create an exclude element type rule for the element.
   insert into pay_element_type_rules
   (element_type_id,
    element_set_id,
    include_or_exclude,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   select
    p_element_type_id,
    p_element_set_id,
    'E',
    trunc(sysdate),
    0,
    0,
    0,
    trunc(sysdate)
   from  sys.dual
   where not exists
          (select null
           from   pay_element_type_rules etr
           where  etr.element_set_id = p_element_set_id
             and  etr.element_type_id = p_element_type_id);
--
   -- Element rule could not be created as there already exists an element rule
   -- for this element. Remove the element rule if it is included ie. this will
   -- then remove the element from the set.
   if sql%notfound then
--
     delete from pay_element_type_rules etr
     where  etr.element_set_id = p_element_set_id
       and  etr.element_type_id = p_element_type_id
       and  etr.include_or_exclude = 'I';
--
   end if;
--
 end exclude_element;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of an element rule   --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                      X_Element_Type_Id                     NUMBER,
                      X_Element_Set_Id                      NUMBER,
                      X_Include_Or_Exclude                  VARCHAR2,
                      X_Last_Update_Date                    DATE,
                      X_Last_Updated_By                     NUMBER,
                      X_Last_Update_Login                   NUMBER,
                      X_Created_By                          NUMBER,
                      X_Creation_Date                       DATE) IS
--
   CURSOR C IS SELECT rowid FROM pay_element_type_rules
               WHERE  element_set_id = X_Element_Set_Id
                 AND  element_type_id = X_Element_Type_Id;
--
 BEGIN
--
   INSERT INTO pay_element_type_rules
   (element_type_id,
    element_set_id,
    include_or_exclude,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   VALUES
   (X_Element_Type_Id,
    X_Element_Set_Id,
    X_Include_Or_Exclude,
    X_Last_Update_Date,
    X_Last_Updated_By,
    X_Last_Update_Login,
    X_Created_By,
    X_Creation_Date);
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_type_rules_pkg.insert_row');
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
 --   of an element rule by applying a lock on an element rule within the   --
 --   Define Element and Distribution Set form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Element_Type_Id                       NUMBER,
                    X_Element_Set_Id                        NUMBER,
                    X_Include_Or_Exclude                    VARCHAR2) IS
--
   CURSOR C IS SELECT * FROM pay_element_type_rules
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
                                  'pay_element_type_rules_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces.
   Recinfo.include_or_exclude := rtrim(Recinfo.include_or_exclude);
--
   if (    (   (Recinfo.element_type_id = X_Element_Type_Id)
            OR (    (Recinfo.element_type_id IS NULL)
                AND (X_Element_Type_Id IS NULL)))
       AND (   (Recinfo.element_set_id = X_Element_Set_Id)
            OR (    (Recinfo.element_set_id IS NULL)
                AND (X_Element_Set_Id IS NULL)))
       AND (   (Recinfo.include_or_exclude = X_Include_Or_Exclude)
            OR (    (Recinfo.include_or_exclude IS NULL)
                AND (X_Include_Or_Exclude IS NULL)))
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
 --   Table handler procedure that supports the update of an element rule   --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Element_Type_Id                     NUMBER,
                      X_Element_Set_Id                      NUMBER,
                      X_Include_Or_Exclude                  VARCHAR2,
                      X_Last_Update_Date                    DATE,
                      X_Last_Updated_By                     NUMBER,
                      X_Last_Update_Login                   NUMBER) IS
 BEGIN
--
   UPDATE pay_element_type_rules
   SET element_type_id        =    X_Element_Type_Id,
       element_set_id         =    X_Element_Set_Id,
       include_or_exclude     =    X_Include_Or_Exclude,
       last_update_date       =    X_Last_Update_Date,
       last_updated_by        =    X_Last_Updated_By,
       last_update_login      =    X_Last_Update_Login
   WHERE rowid = X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_type_rules_pkg.update_row');
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
 --   Table handler procedure that supports the delete of an element rule   --
 --   via the Define Element and Distributuion Set form.                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
 BEGIN
--
   DELETE FROM pay_element_type_rules
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_element_type_rules_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
END PAY_ELEMENT_TYPE_RULES_PKG;

/
