--------------------------------------------------------
--  DDL for Package Body PAY_ELE_CLASS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELE_CLASS_RULES_PKG" as
/* $Header: pyecr01t.pkb 115.3 2002/12/16 17:45:56 dsaxby ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_ele_class_rules_pkg
  Purpose
    Supports the ECR block in the form PAYWSDRP (Define Element and
    Distributuion Set.
  Notes

  HIStory
    24-Mar-94  J.S.Hobbs   40.0         Date created.
    25-JUL-95  AMILLS      40.4         Replaced tokenised message
                                        'HR_6056_ELE_SET_CLASS_EXISTS' with h/c
                                        'HR_7879_ELE_SET_UNIQUE_RULES'.
    24-FEB-99  J. Moyano  115.1         MLS Changes. Reference to
                                        pay_element_classification_tl table
                                        in cursor csr_classification_name.
    16-DEC-02  D. Saxby   115.3 2692195 Nocopy changes.
--
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_classification_name                                               --
 -- Purpose                                                                 --
 --   Returns the classification name for a particular classification_id.   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
 function get_classification_name
 (
  p_classification_id number
 ) return varchar2 is
--
   cursor csr_classification_name is
     select ecl_tl.classification_name
     from   pay_element_classifications_tl ecl_tl,
            pay_element_classifications ecl
     where  ecl.classification_id = ecl_tl.classification_id
     and    ecl.classification_id = p_classification_id
     and    userenv('LANG') = ecl_tl.language;
--
   v_classification_name pay_element_classifications.classification_name%type;
--
 begin
--
   open csr_classification_name;
   fetch csr_classification_name into v_classification_name;
   if csr_classification_name%notfound then
     close csr_classification_name;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                           'pay_ele_class_rules_pkg.get_classification_name');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   else
     close csr_classification_name;
   end if;
--
   return v_classification_name;
--
 end get_classification_name;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_insert_ele_classification                                         --
 -- Purpose                                                                 --
 --   Validates the creation of a classification rule.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Makes sure that each primary element classification can only be used  --
 --   once within an element set.                                           --
 --   Makes sure there are no element type rules for the classification ie. --
 --   there are no include element type rules for the classification.     . --
 -----------------------------------------------------------------------------
--
 procedure chk_insert_ele_classification
 (
  p_rowid               varchar2,
  p_element_set_id      number,
  p_classification_id   number
 ) is
--
   cursor csr_ele_class_rule is
     select ecr.classification_id
     from   pay_ele_classification_rules ecr
     where  ecr.element_set_id = p_element_set_id
       and  ecr.classification_id = p_classification_id
       and  (p_rowid is null or
            (p_rowid is not null and chartorowid(p_rowid) <> ecr.rowid));
--
   cursor csr_ele_type_rule is
     select etr.element_type_id
     from   pay_element_type_rules etr,
	    pay_element_types_f et
     where  etr.element_set_id = p_element_set_id
       and  et.element_type_id = etr.element_type_id
       and  et.classification_id = p_classification_id;
--
   v_dummy number;
--
 begin
--
   open csr_ele_class_rule;
   fetch csr_ele_class_rule into v_dummy;
   if csr_ele_class_rule%found then
     close csr_ele_class_rule;
     hr_utility.set_message(801, 'HR_7879_ELE_SET_UNIQUE_RULES');
     hr_utility.raise_error;
   else
     close csr_ele_class_rule;
   end if;
--
   open csr_ele_type_rule;
   fetch csr_ele_type_rule into v_dummy;
   if csr_ele_type_rule%found then
     close csr_ele_type_rule;
     hr_utility.set_message(801, 'HR_6014_ELE_SET_RULES_EXIST');
     hr_utility.set_message_token('INS_OR_DEL', 'insert');
     hr_utility.set_message_token('CLASSIFICATION_NAME',
				  get_classification_name(p_classification_id));
     hr_utility.set_message_token('INC_OR_EXC', 'included');
     hr_utility.raise_error;
   else
     close csr_ele_type_rule;
   end if;
--
 end chk_insert_ele_classification;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_delete_ele_classification                                         --
 -- Purpose                                                                 --
 --   Validates the removal of a classification rule.                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Makes sure there are no element type rules for the classification ie. --
 --   there are no exclude element type rules for the classification.     . --
 -----------------------------------------------------------------------------
--
 procedure chk_delete_ele_classification
 (
  p_element_set_id      number,
  p_classification_id   number
 ) is
--
   cursor csr_ele_type_rule is
     select etr.element_type_id
     from   pay_element_type_rules etr,
	    pay_element_types_f et
     where  etr.element_set_id = p_element_set_id
       and  et.element_type_id = etr.element_type_id
       and  et.classification_id = p_classification_id;
--
   v_dummy number;
--
 begin
--
   open csr_ele_type_rule;
   fetch csr_ele_type_rule into v_dummy;
   if csr_ele_type_rule%found then
     close csr_ele_type_rule;
     hr_utility.set_message(801, 'HR_6014_ELE_SET_RULES_EXIST');
     hr_utility.set_message_token('INS_OR_DEL', 'delete');
     hr_utility.set_message_token('CLASSIFICATION_NAME',
				  get_classification_name(p_classification_id));
     hr_utility.set_message_token('INC_OR_EXC', 'excluded');
     hr_utility.raise_error;
   else
     close csr_ele_type_rule;
   end if;
--
 end chk_delete_ele_classification;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a classification  --
 --   rule via the Define Element and Distributuion Set form.               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Element_Set_Id               IN OUT NOCOPY NUMBER,
                      X_Classification_Id                          NUMBER,
                      -- Extra Columns
                      X_Element_Set_Type                    VARCHAR2) IS
--
   CURSOR C IS SELECT rowid FROM pay_ele_classification_rules
               WHERE  element_set_id = X_Element_Set_Id
                 AND  classification_id = X_Classification_Id;
--
 BEGIN
--
   -- Lock element set to preserve the current definition.
   pay_element_sets_pkg.lock_element_set
     (X_Element_Set_Id);
--
   chk_insert_ele_classification
     (X_Rowid,
      X_Element_Set_Id,
      X_Classification_Id);
--
   -- If adding a classification to a distribution set make sure the debit or
   -- credit status is the same for all elements within the set.
   if X_Element_Set_Type = 'D' then
--
     pay_element_sets_pkg.chk_debit_or_credit
       (X_Element_Set_Id,
        X_Classification_Id);
--
   end if;
--
   INSERT INTO pay_ele_classification_rules
   (element_set_id,
    classification_id)
   VALUES
   (X_Element_Set_Id,
    X_Classification_Id);
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_ele_class_rules_pkg.insert_row');
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
 --   of a classification rule by applying a lock on a classification rule  --
 --   within the Define Element and Distribution Set form.                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Element_Set_Id                        NUMBER,
                    X_Classification_Id                     NUMBER) IS
--
   CURSOR C IS SELECT * FROM  pay_ele_classification_rules
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
                                  'pay_ele_class_rules_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   if (    (   (Recinfo.element_set_id = X_Element_Set_Id)
            OR (    (Recinfo.element_set_id IS NULL)
                AND (X_Element_Set_Id IS NULL)))
       AND (   (Recinfo.classification_id = X_Classification_Id)
            OR (    (Recinfo.classification_id IS NULL)
                AND (X_Classification_Id IS NULL)))
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
 --   Table handler procedure that supports the update of a classification  --
 --   rule via the Define Element and Distributuion Set form.               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Element_Set_Id                      NUMBER,
                      X_Classification_Id                   NUMBER) IS
 BEGIN
--
   UPDATE pay_ele_classification_rules
   SET element_set_id      =    X_Element_Set_Id,
       classification_id   =    X_Classification_Id
   WHERE rowid = X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_ele_class_rules_pkg.update_row');
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
 --   Table handler procedure that supports the delete of a classification  --
 --   rule via the Define Element and Distributuion Set form.               --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
		      -- Extra Columns
                      X_Element_Set_Id                      NUMBER,
                      X_Classification_Id                   NUMBER) IS
 BEGIN
--
   -- Lock element set to preserve the current definition.
   pay_element_sets_pkg.lock_element_set
     (X_Element_Set_Id);
--
   chk_delete_ele_classification
     (X_Element_Set_Id,
      X_Classification_Id);
--
   DELETE FROM pay_ele_classification_rules
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_ele_class_rules_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
END PAY_ELE_CLASS_RULES_PKG;

/
