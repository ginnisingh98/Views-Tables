--------------------------------------------------------
--  DDL for Package Body PAY_BAL_CLASSIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BAL_CLASSIFICATIONS_PKG" as
/* $Header: pyblc01t.pkb 115.5 2002/12/06 14:20:26 alogue ship $ */
--
 /*==========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
  Name
    pay_bal_classifications_pkg
  Purpose
    Used by PAYWSDBT (Define Balance Type) for the balance classification
    block (BLC).
  Notes

  History
    01-Mar-94  J.S.Hobbs   40.0         Date created.
    20-Apr-94  J.S.Hobbs   40.1         Added rtrim to Lock_Row.
    01-Feb-95  J.S.Hobbs   40.5         Removed aol WHO columns.
    24-Apr-95  J.S.Hobbs   40.6         Added extra validation to stop the
                                        mixing of manual and automatic balance
                                        feeds (via classifications).
    05-Mar-97  J.Alloun    40.7         Changed all occurances of system.dual
                                        to sys.dual for next release
                                        requirements.
    16-NOV-2001 RThirlby  115.2  930964 New parameter X_mode added to procedure
             delivered in patch 2000669 insert_row so that the startup mode
                                        (either GENERIC, STARTUP or USER) can
                                        be identified. This is required, as a
                                        enhancement request was made where by
                                        functionality for chk_bal_clasification
                                        if different depending on what mode
                                        you are in. In USER mode there is no
                                        change. In STARTUP mode, it is now
                                        possible to feed a balance from more
                                        than one secondary classifcation.
    16-NOV-2001 RThirlby  115.3         Added commit to end of file for GSCC
                                        standards.
    01-JUL-2002 RCallaghan 115.4        Added checkfile line.
    06-DEC-2002 ALogue     115.5        NOCOPY changes.  Bug 2692195
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_balance_classification                                            --
 -- Purpose                                                                 --
 --   Make sure the balance classification is unique ie. only one           --
 --   classification per family is allowed for a balance.                   --
 --   Bug 930964 - It is now possible to have more than one balance         --
 --                classification per family, when in STARTUP mode.         --
 --                The restriction will remain for USER mode, to help       --
 --                prevent users creating duplicate feeds to balances.      --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   Bug 930964 - Added new parameter p_mode. The where clause restriction --
 --                alters depending on this value. This should be left null --
 --                when in USER mode.
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 procedure chk_balance_classification
 (
  p_row_id            varchar2,
  p_balance_type_id   number,
  p_classification_id number,
  p_mode              varchar2 default null
 ) is
   --
   cursor csr_unique_bal_classification (p_startup_mode varchar2) is
      select ecl.classification_id
      from   pay_element_classifications ecl
      where  ecl.classification_id = p_classification_id
        and  not exists
             (select null
              from   pay_balance_classifications bcl
              where  bcl.balance_type_id = p_balance_type_id
      	        and  bcl.classification_id = ecl.classification_id
	        and  (p_row_id is null or
	             (p_row_id is not null and
		      chartorowid(p_row_id) <> bcl.rowid)))
        and ((p_startup_mode is null
        and ((ecl.parent_classification_id is null and
              not exists
      	      (select null
      	        from   pay_balance_classifications bcl2,
      	               pay_element_classifications ecl2
      	        where  bcl2.balance_type_id = p_balance_type_id
      	          and  ecl2.classification_id = bcl2.classification_id
      	          and  ecl2.parent_classification_id = ecl.classification_id
	          and  (p_row_id is null or
	               (p_row_id is not null and
		        chartorowid(p_row_id) <> bcl2.rowid))))
         or  (ecl.parent_classification_id is not null and
              not exists
              (select null
               from   pay_balance_classifications bcl3,
      	              pay_element_classifications ecl3
               where  bcl3.balance_type_id = p_balance_type_id
                 and  ecl3.classification_id = bcl3.classification_id
                 and (ecl3.parent_classification_id =
			ecl.parent_classification_id or
      	              ecl3.classification_id =
			ecl.parent_classification_id)
	          and  (p_row_id is null or
	               (p_row_id is not null and
		        chartorowid(p_row_id) <> bcl3.rowid))))))
          or (p_startup_mode is not null));
   --
   v_bal_classification_id number;
   l_mode                  varchar2(10);
   --
 begin
   --
   -- If p_mode is passed through as USER, set it to null. It should only
   -- be populated if in STARTUP or GENERIC mode.
   --
   if p_mode = 'USER' then
      l_mode := '';
   else
      l_mode := p_mode;
   end if;
   --
   open csr_unique_bal_classification(l_mode);
   fetch csr_unique_bal_classification into v_bal_classification_id;
   if csr_unique_bal_classification%notfound then
     close csr_unique_bal_classification;
     hr_utility.set_message(801, 'HR_6116_BAL_UNI_CLAS');
     hr_utility.raise_error;
   else
     close csr_unique_bal_classification;
   end if;
   --
 end chk_balance_classification;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a balance         --
 --   classification via the Define Balance Type form.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 --   Bug 930964 - new parameter X_mode, to enable different functionality  --
 --                in chk_balance_classification depending on the startup   --
 --                mode. See chk_balance_classification for more details.   --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                     IN OUT NOCOPY VARCHAR2,
                      X_Balance_Classification_Id IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id                NUMBER,
                      X_Legislation_Code                 VARCHAR2,
                      X_Balance_Type_Id                  NUMBER,
                      X_Classification_Id                NUMBER,
                      X_Scale                            NUMBER,
                      X_Legislation_Subgroup             VARCHAR2,
                      X_mode                             VARCHAR2 default null)
 IS
   --
   CURSOR C IS SELECT rowid FROM pay_balance_classifications
               WHERE  balance_classification_id = X_Balance_Classification_Id;
   --
   CURSOR C2 IS SELECT pay_balance_classifications_s.nextval FROM sys.dual;
   --
 BEGIN
   --
   -- Lock balance type to stop other users changing the balance.
   --
   hr_balance_feeds.lock_balance_type(X_Balance_Type_Id);
   --
   -- Make sure that balance is not fed by manual balance feeds which would
   -- disable the use of classifications and therefore make this operation
   -- invalid.
   --
   if hr_balance_feeds.manual_bal_feeds_exist(X_Balance_Type_Id) then
     hr_utility.set_message(801, 'HR_7445_BAL_CLASS_NO_CREATE');
     hr_utility.raise_error;
   end if;
   --
   -- Make sure that there are no duplicate balance classifications NB. there
   -- can only be one classification per family ie. one of parent and its sub
   -- classifications.
   --
   chk_balance_classification
     (X_RowId,
      X_Balance_Type_Id,
      X_Classification_Id,
      X_mode);
   --
   if (X_Balance_Classification_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Balance_Classification_Id;
     CLOSE C2;
   end if;
   --
   INSERT INTO pay_balance_classifications
   (balance_classification_id,
    business_group_id,
    legislation_code,
    balance_type_id,
    classification_id,
    scale,
    legislation_subgroup)
   VALUES
   (X_Balance_Classification_Id,
    X_Business_Group_Id,
    X_Legislation_Code,
    X_Balance_Type_Id,
    X_Classification_Id,
    X_Scale,
    X_Legislation_Subgroup);
   --
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_bal_classifications_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
   --
   -- Create balance feeds for elements with the same Classification /
   -- Sub Classification which have a Pay Value that has the same
   -- Units as the balance and also the same currency if the
   -- Units are money.
   --
   hr_balance_feeds.ins_bf_bal_class
     (X_Balance_Type_Id,
      X_Balance_Classification_Id);
   --
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a balance classification by applying a lock on a balance           --
 --   classification in the Define Balance Type form.                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Balance_Classification_Id             NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Classification_Id                     NUMBER,
                    X_Scale                                 NUMBER,
                    X_Legislation_Subgroup                  VARCHAR2) IS
   --
   CURSOR C IS SELECT * FROM pay_balance_classifications
               WHERE  rowid = X_Rowid FOR UPDATE of Balance_Classification_Id
	       NOWAIT;
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
                                  'pay_bal_classifications_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
   --
   -- Remove trailing spaces.
   --
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.legislation_subgroup := rtrim(Recinfo.legislation_subgroup);
   --
   if (    (   (Recinfo.balance_classification_id = X_Balance_Classification_Id)
            OR (    (Recinfo.balance_classification_id IS NULL)
                AND (X_Balance_Classification_Id IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.balance_type_id = X_Balance_Type_Id)
            OR (    (Recinfo.balance_type_id IS NULL)
                AND (X_Balance_Type_Id IS NULL)))
       AND (   (Recinfo.classification_id = X_Classification_Id)
            OR (    (Recinfo.classification_id IS NULL)
                AND (X_Classification_Id IS NULL)))
       AND (   (Recinfo.scale = X_Scale)
            OR (    (Recinfo.scale IS NULL)
                AND (X_Scale IS NULL)))
       AND (   (Recinfo.legislation_subgroup = X_Legislation_Subgroup)
            OR (    (Recinfo.legislation_subgroup IS NULL)
                AND (X_Legislation_Subgroup IS NULL)))
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
 --   Table handler procedure that supports the update of a balance         --
 --   classification via the Define Balance Type form.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Classification_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Classification_Id                   NUMBER,
                      X_Scale                               NUMBER,
                      X_Legislation_Subgroup                VARCHAR2) IS
 BEGIN
   --
   UPDATE pay_balance_classifications
   SET balance_classification_id       =    X_Balance_Classification_Id,
       business_group_id               =    X_Business_Group_Id,
       legislation_code                =    X_Legislation_Code,
       balance_type_id                 =    X_Balance_Type_Id,
       classification_id               =    X_Classification_Id,
       scale                           =    X_Scale,
       legislation_subgroup            =    X_Legislation_Subgroup
   WHERE rowid = X_rowid;
   --
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_bal_classifications_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   --
   -- Update all balance feeds that are linked to the balance classification
   -- NB. the only attribute that can be updated is Add or Subtract.
   --
   hr_balance_feeds.upd_del_bf_bal_class
     ('UPDATE',
      X_Balance_Classification_Id,
      X_Scale);
   --
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a balance         --
 --   classification via the Define Balance Type form.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                      VARCHAR2,
                      -- Extra Columns
                      X_Balance_Classification_Id  NUMBER) IS
 BEGIN
   --
   -- Remove all balance feeds that are linked to the balance classification.
   --
   hr_balance_feeds.upd_del_bf_bal_class
     ('DELETE',
      X_Balance_Classification_Id,
      null);
   --
   DELETE FROM pay_balance_classifications
   WHERE  rowid = X_Rowid;
   --
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_bal_classifications_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   --
 END Delete_Row;
--
END PAY_BAL_CLASSIFICATIONS_PKG;

/
