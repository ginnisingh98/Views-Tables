--------------------------------------------------------
--  DDL for Package Body BEN_COVERED_DEPENDENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COVERED_DEPENDENTS_PKG" as
/* $Header: pebcd01t.pkb 115.1 2004/03/25 17:31 ynegoro ship $ */
----------------- Insert_Row ------------------------------------
PROCEDURE Insert_Row(P_Rowid                   	IN OUT nocopy VARCHAR2,
                     P_Covered_Dependent_Id     IN OUT nocopy NUMBER,
                     P_Contact_Relationship_Id         NUMBER,
                     P_Element_Entry_Id                NUMBER,
                     P_Effective_Start_Date            DATE,
                     P_Effective_End_Date              DATE ) IS
    --
    CURSOR C IS SELECT rowid
		FROM   ben_covered_dependents_f
                WHERE  covered_dependent_id = P_Covered_Dependent_Id
		AND    element_entry_id     = P_Element_Entry_ID
		;
    --
    CURSOR C2 IS SELECT ben_covered_dependents_s.nextval
		 FROM   sys.dual;
    --
    --
BEGIN
     if (P_Covered_Dependent_Id is NULL) then
       OPEN C2;
       FETCH C2 INTO P_Covered_Dependent_Id;
       CLOSE C2;
     end if;
     --
       INSERT INTO ben_covered_dependents_f (
              covered_dependent_id,
              contact_relationship_id,
              element_entry_id,
              effective_start_date,
              effective_end_date)
        VALUES
	    ( P_Covered_Dependent_Id,
              P_Contact_Relationship_Id,
              P_Element_Entry_Id,
              P_Effective_Start_Date,
              P_Effective_End_Date
             );
    --
    OPEN C;
    --
    FETCH C INTO P_Rowid;
    --
    --
    if (C%NOTFOUND) then
      CLOSE C;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','INSERT_ROW');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    end if;
    --
    CLOSE C;
    --
END Insert_Row;
--
-------------- Lock_Row --------------------------------------
--
PROCEDURE Lock_Row(P_Rowid                            VARCHAR2,
                   P_Covered_Dependent_Id             NUMBER,
                   P_Contact_Relationship_Id          NUMBER,
                   P_Element_Entry_Id                 NUMBER,
                   P_Effective_Start_Date             DATE,
                   P_Effective_End_Date               DATE ) IS
    --
    --
    CURSOR C IS
        SELECT *
        FROM   ben_covered_dependents_f
        WHERE  rowid = P_Rowid
        FOR UPDATE of Covered_Dependent_Id NOWAIT;
    --
    --
    Recinfo C%ROWTYPE;
    --
    --
BEGIN
    --
    OPEN C;
    --
    FETCH C INTO Recinfo;
    --
    if (C%NOTFOUND) then
      CLOSE C;
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','LOCK_ROW');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    end if;
    --
    CLOSE C;
    --
    if (       (   (Recinfo.covered_dependent_id =  P_Covered_Dependent_Id)
                OR (    (Recinfo.covered_dependent_id IS NULL)
                    AND (P_Covered_Dependent_Id IS NULL)))
           AND (   (Recinfo.contact_relationship_id =  P_Contact_Relationship_Id)
                OR (    (Recinfo.contact_relationship_id IS NULL)
                    AND (P_Contact_Relationship_Id IS NULL)))
           AND (   (Recinfo.element_entry_id =  P_Element_Entry_Id)
                OR (    (Recinfo.element_entry_id IS NULL)
                    AND (P_Element_Entry_Id IS NULL)))
           AND (   (Recinfo.effective_start_date =  P_Effective_Start_Date)
                OR (    (Recinfo.effective_start_date IS NULL)
                    AND (P_Effective_Start_Date IS NULL)))
           AND (   (Recinfo.effective_end_date =  P_Effective_End_Date)
                OR (    (Recinfo.effective_end_date IS NULL)
                    AND (P_Effective_End_Date IS NULL)))
      ) then
      return;
    --
    else
    --
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    --
    end if;
--
--
END Lock_Row;
--
----------------- Update_Row -------------------------------
--
-- This is to be used for a date-effective delete of the element
-- entry.  The form PERBECVD does not provide for an update of
-- the covered dependent records.
--
PROCEDURE Update_Row (P_Rowid				VARCHAR2,
		       P_Covered_Dependent_Id		NUMBER,
		       P_Contact_Relationship_Id	NUMBER,
		       P_Element_Entry_Id		NUMBER,
		       P_Effective_Start_Date		DATE,
		       P_Effective_End_Date		DATE
		      ) IS
BEGIN
 --
 UPDATE ben_covered_dependents_f
 SET
	covered_dependent_id	= P_Covered_Dependent_Id,
	contact_relationship_id = P_Contact_Relationship_Id,
	element_entry_id	= P_Element_Entry_Id,
	effective_start_date	= P_Effective_Start_Date,
	effective_end_date	= P_Effective_End_Date
 WHERE
	rowid = P_Rowid;
 --
 if (SQL%NOTFOUND) then
    --
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','UPDATE_ROW');
        hr_utility.set_message_token('STEP','20');
        hr_utility.raise_error;
    --
 end if;
--
END Update_Row;
--
----------------- Delete_Row -------------------------------
--
PROCEDURE Delete_Row(P_Rowid VARCHAR2) IS
--
BEGIN
    --
    DELETE FROM ben_covered_dependents_f
    WHERE rowid = P_Rowid;
    --
    if (SQL%NOTFOUND) then
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','DELETE_ROW');
        hr_utility.set_message_token('STEP','1');
        hr_utility.raise_error;
    end if;
    --
END Delete_Row;
--
---------------- Test_Path_To_PERBECVD --------------------
--
PROCEDURE Test_Path_To_PERBECVD (P_Element_Entry_ID NUMBER) IS
 --
 cursor c_chk_asg_benefit is
   select 'OK'
   from
	  ben_benefit_classifications	ben,
	  pay_element_types_f		ele,
	  fnd_sessions			fnd,
 	  per_assignments_f		asg,
	  pay_element_links_f		link,
	  pay_element_entries_f 	ent
   where
	  ent.element_entry_id		= P_element_entry_id
   and    ent.assignment_id		= asg.assignment_id
   --  and    asg.primary_flag		= 'Y'     -- BUG3300263
   and	  ent.element_link_id   	= link.element_link_id
   and	  link.element_type_id  	= ele.element_type_id
   and    ele.benefit_classification_id = ben.benefit_classification_id
   and    ben.dependents_allowed_flag 	= 'Y'
   and    fnd.session_id		= userenv('sessionid')
   and
	  fnd.effective_date between	ent.effective_start_date
			     and	ent.effective_end_date
   and    fnd.effective_date between	ele.effective_start_date
			     and	ele.effective_end_date
   and    fnd.effective_date between	link.effective_start_date
			     and	link.effective_end_date
   and    fnd.effective_date between	asg.effective_start_date
			     and	asg.effective_end_date;
 --
 l_deps_allowed_for_primary_asg varchar2(20);

BEGIN

  open c_chk_asg_benefit;

  fetch c_chk_asg_benefit into l_deps_allowed_for_primary_asg;

  if c_chk_asg_benefit%notfound then
     close c_chk_asg_benefit;
     hr_utility.set_message(801, 'PAY_7980_COV_DEP_FORM_NOT_NAV');
     hr_utility.raise_error;
  end if;

  close c_chk_asg_benefit;


END Test_Path_To_PERBECVD;
--
--
END BEN_COVERED_DEPENDENTS_PKG;

/
