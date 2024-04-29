--------------------------------------------------------
--  DDL for Package Body PER_RECRUIT_ACTIVITY_FOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RECRUIT_ACTIVITY_FOR_PKG" as
/* $Header: percf01t.pkb 115.1 2003/02/11 11:59:32 eumenyio ship $ */
--
/*  +=======================================================================+
    |           Copyright (c) 1993 Oracle Corporation                       |
    |              Redwood Shores, California, USA                          |
    |                   All rights reserved.                                |
    +=======================================================================+
  Name
    per_recruit_activity_for_pkg
  Purpose
    Supports the VACANCY block in the form PERWSDRA (Define Recruitment
    Activity).
  Notes

  History
    21-Feb-94  H.Minton   40.0         Date created.
    23-Nov-94  rfine      70.3         Suppressed index on business_group_id
    29-Jan-95  D.Kerr	  70.5	       Removed WHO-columns for Set8 Changes.
    29-Jan-95  D.Kerr	  70.6	       Added uniqueness checks to prevent
				       duplicate vacancies for a recruitment
				       activity  G1351
    05-Mar-97  J.Alloun   70.7         Changed all occurances of system.dual
                                       to sys.dual for next release requirements.
=============================================================================*/
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_vacancy_unique
-- Purpose                                                                 --
--   Checks that the given vacancy has not already been used for
--   the given recruitment activity
-----------------------------------------------------------------------------
procedure chk_vacancy_unique ( p_vacancy_id               NUMBER,
		               p_recruitment_activity_id NUMBER ) is
  CURSOR c1 is
    SELECT 1
    FROM   per_recruitment_activity_for
    WHERE  recruitment_activity_id = p_recruitment_activity_id
    AND    vacancy_id		   = p_vacancy_id ;
l_dummy number ;
--
begin
   open c1 ;
   fetch c1 into l_dummy ;
   if c1%found then
       close c1 ;
       hr_utility.set_message(801,'HR_6120_RAC_VACACNY_EXISTS');
       hr_utility.raise_error ;
   end if;
   close c1 ;
--
end chk_vacancy_unique ;
--
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   checks that deletes cannot take place of a recruitment activity if    --
--   there are vacancies i.e recruitment_activities_for the recruitment-   --
--   activity exist.
-----------------------------------------------------------------------------
--
PROCEDURE check_References(P_recruitment_activity_id    NUMBER,
                           P_Business_group_id          NUMBER) IS
--
  CURSOR csr_rec_ac_for
                       (
                        P_recruitment_activity_id   NUMBER,
                        P_Business_group_id         NUMBER
                       ) IS
    SELECT recf.recruitment_activity_id
    FROM   per_recruitment_activity_for recf
    WHERE  recf.recruitment_activity_id = P_recruitment_activity_id
    AND    recf.business_group_id + 0       = P_Business_group_id;
--
  v_dummy_id              number;
--
--

  BEGIN
       OPEN csr_rec_ac_for(P_recruitment_activity_id,
                           P_Business_group_id);
       FETCH csr_rec_ac_for into v_dummy_id;
         IF csr_rec_ac_for%found then
         CLOSE csr_rec_ac_for;
          hr_utility.set_message(800,'HR_6110_RAC_RECRUIT_DEL_CHILD');
          hr_utility.raise_error;
         ELSE
          CLOSE csr_rec_ac_for;
         END IF;

  END check_References;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Insert_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure. Supports the insert of a VACANCY via the   --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
 -----------------------------------------------------------------------------
--

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Recruitment_Activity_For_Id         IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Vacancy_Id                          NUMBER,
                     X_Recruitment_Activity_Id             NUMBER)
IS
   CURSOR C IS
            SELECT rowid
            FROM PER_RECRUITMENT_ACTIVITY_FOR
            WHERE recruitment_activity_for_id = X_Recruitment_Activity_For_Id;


    CURSOR C2 IS
               SELECT per_recruitment_activity_for_s.nextval
               FROM sys.dual;

BEGIN
   --
   -- Check that the vacancy id has not already been used for this
   -- recruitment activity
   --
   chk_vacancy_unique ( p_recruitment_activity_id => X_recruitment_activity_id,
			p_vacancy_id		  => X_vacancy_id ) ;
   --
   if (X_Recruitment_Activity_For_Id is NULL) then
     OPEN C2;
       FETCH C2 INTO X_Recruitment_Activity_For_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_RECRUITMENT_ACTIVITY_FOR
         (recruitment_activity_for_id,
          business_group_id,
          vacancy_id,
          recruitment_activity_id)
   VALUES (
          X_Recruitment_Activity_For_Id,
          X_Business_Group_Id,
          X_Vacancy_Id,
          X_Recruitment_Activity_Id );
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruit_activity_for_pkg.insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Lock_Row                                                              --
-- Purpose                                                                 --
--   Table handler procedure that supports the insert , update and delete  --
--   of a vacancy by applying a lock on a vacancy in the Define            --
--   Recruitment Activity form.                                            --
-- Arguments                                                               --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Recruitment_Activity_For_Id           NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Vacancy_Id                            NUMBER,
                   X_Recruitment_Activity_Id               NUMBER)
IS
  CURSOR C IS
      SELECT *
      FROM   PER_RECRUITMENT_ACTIVITY_FOR
      WHERE  rowid = X_Rowid
      FOR UPDATE of Recruitment_Activity_For_Id NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruit_activity_for_pkg.lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
  if (
      (   (Recinfo.recruitment_activity_for_id = X_Recruitment_Activity_For_Id)
       OR (    (Recinfo.recruitment_activity_for_id IS NULL)
           AND (X_Recruitment_Activity_For_Id IS NULL)))
  AND (   (Recinfo.business_group_id = X_Business_Group_Id)
       OR (    (Recinfo.business_group_id IS NULL)
           AND (X_Business_Group_Id IS NULL)))
  AND (   (Recinfo.vacancy_id = X_Vacancy_Id)
       OR (    (Recinfo.vacancy_id IS NULL)
           AND (X_Vacancy_Id IS NULL)))
 AND (   (Recinfo.recruitment_activity_id = X_Recruitment_Activity_Id)
       OR (    (Recinfo.recruitment_activity_id IS NULL)
           AND (X_Recruitment_Activity_Id IS NULL)))
      ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

END Lock_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Update_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the update of a VACACNY via     --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Recruitment_Activity_For_Id         NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Vacancy_Id                          NUMBER,
                     X_Recruitment_Activity_Id             NUMBER)
IS
BEGIN
   --
   -- Check that the vacancy id has not already been used for this
   -- recruitment activity
   --
   chk_vacancy_unique ( p_recruitment_activity_id => X_recruitment_activity_id,
			p_vacancy_id		  => X_vacancy_id ) ;
   --
  UPDATE PER_RECRUITMENT_ACTIVITY_FOR
  SET

   recruitment_activity_for_id               =    X_Recruitment_Activity_For_Id,
   business_group_id                         =    X_Business_Group_Id,
   vacancy_id                                =    X_Vacancy_Id,
   recruitment_activity_id                   =    X_Recruitment_Activity_Id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruit_activity_for_pkg.update_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;

END Update_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Delete_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the delete of a VACACNY via     --
--   the Define Recruitment Activity form.                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_RECRUITMENT_ACTIVITY_FOR
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruit_activity_for_pkg.delete_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
END Delete_Row;

END PER_RECRUIT_ACTIVITY_FOR_PKG;

/
