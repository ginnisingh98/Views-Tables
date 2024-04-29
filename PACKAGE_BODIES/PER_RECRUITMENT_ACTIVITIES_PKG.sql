--------------------------------------------------------
--  DDL for Package Body PER_RECRUITMENT_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RECRUITMENT_ACTIVITIES_PKG" as
/* $Header: perca01t.pkb 115.4 2003/02/11 11:55:00 eumenyio ship $ */
--
/*  +=======================================================================+
    |           Copyright (c) 1993 Oracle Corporation                       |
    |              Redwood Shores, California, USA                          |
    |                   All rights reserved.                                |
    +=======================================================================+
 Name
    per_recruitment_activities_pkg
  Purpose
    Supports the ACTIVITY block in the form PERWSDRA (Define Recruitment
    Activity).
  Notes
    Changed X_Parent_Recruitment_Activity_Id to X_Parent_Rec_Activity_Id
    because was too long otherwise.

  History
    21-Feb-94  H.Minton   40.0         Date created.
    01-JUL-94  H.Minton  40.1          Added procedure chk_auth_date
    23-NOV-94  rfine      70.4         Suppressed index on business_group_id
    29-JAN-95  D.Kerr     70.6         Removed WHO-columns for Set8 changes
    24-JUL-95  AForte     70.6		Changed tokenised message
	       AMills			'HR_6695_RAC_PER_NOT_VALID' for
					'HR_7696_RAC_PER_NOT_VALID',
					'HR_7697_RAC_PER_NOT_VALID'
    17-NOV-95  JThuringer 70.9         Removed ampersand from change history -
                                       this was causing an
                                       "expected symbol name is missing" error
    22-MAR-96  A.Mills    70.10        Altered procedure chk_vacancy_dates to
                                       accept and test on p_rec_activity_id.
                                       Cursor changed.
    05-MAR-97  J.Alloun   70.11        Changed all occurances of system.dual
                                       to sys.dual for next release requirements.
============================================================================*/
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_Unique_Name                                                     --
-- Purpose                                                                 --
--   checks that the recruitment activity name is unique. Called from the  --
--   client side package ACTIVITY_ITEMS from the procedure 'name'. Called  --
--   on WHEN-VALIDATE-ITEM from Name.                                      --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Check_Unique_Name(P_Name    			VARCHAR2,
                            P_Business_group_id 	NUMBER,
                            P_rowid                     VARCHAR2)  IS

   CURSOR name_exists IS
                       SELECT 1
                       FROM   per_recruitment_activities rec
                       WHERE  upper(rec.NAME) = upper(p_Name)
                       AND    rec.business_group_id + 0 = P_business_group_id
                       AND    (P_rowid <> rec.rowid
                              or P_rowid is NULL);
v_dummy number;
--
BEGIN
--
    OPEN name_exists;
    FETCH name_exists INTO v_dummy;
    IF name_exists%found THEN
       CLOSE name_exists;
       hr_utility.set_message(801, 'HR_6113_RAC_EXISTS');
       hr_utility.raise_error;
    ELSe CLOSE name_exists;
    END IF;
END Check_Unique_Name;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_references,                                                       --
-- Purpose                                                                 --
--   checks that deletes cannot take place of a recruitment activity if    --
--   there are vacancies i.e recruitment_activities_for the recruitment-   --
--   activity, or if the recruitment activity is being used in an          --
--   assignment or if the recruitment activity is a parent.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --

-----------------------------------------------------------------------------
--
PROCEDURE Check_references(P_recruitment_activity_id    NUMBER,
                           P_Business_group_id          NUMBER) IS
--
--

  CURSOR csr_asg
               (
                P_recruitment_activity_id   NUMBER,
                P_Business_group_id         NUMBER
               ) IS
    SELECT asg.recruitment_activity_id
    FROM   per_assignments_F asg
    WHERE  asg.recruitment_activity_id  = P_recruitment_activity_id
    AND    asg.business_group_id + 0        = P_Business_group_id;
--
--
  CURSOR csr_rec_acts
                    (
                     P_recruitment_activity_id   NUMBER,
                     P_Business_group_id         NUMBER
                    ) IS
    SELECT acts.recruitment_activity_id
    FROM   per_recruitment_activities acts
    WHERE  acts.parent_recruitment_activity_id = P_recruitment_activity_id
    AND    acts.business_group_id + 0              = P_Business_group_id;
--
--
  v_dummy_id              number;
--
--

  BEGIN
--
        OPEN csr_asg(P_recruitment_activity_id,
                     P_Business_group_id);
        FETCH csr_asg into v_dummy_id;
        IF csr_asg%found then
          CLOSE csr_asg;
           hr_utility.set_message(800,'HR_6682_RAC_RECRUIT_ASG_EXIST');
           hr_utility.raise_error;
        ELSE
          CLOSE csr_asg;
       END IF;
--
--
       OPEN csr_rec_acts(P_recruitment_activity_id,
                         P_Business_group_id);
       FETCH csr_rec_acts into v_dummy_id;
       IF csr_rec_acts%found then
          CLOSE csr_rec_acts;
            hr_utility.set_message(800,'HR_6111_RAC_RECRUIT_SUB_ACTS');
            hr_utility.raise_error;
        ELSE
          CLOSE csr_rec_acts;
        END IF;
--
--
   END check_References;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_org_date                                                          --
-- Purpose                                                                 --
--    Checks that on update of the Activity Start that the organization is --
--    not invalidated.                                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   Called from the client side the WVI for the date_start                --
 -----------------------------------------------------------------------------
--
--
   PROCEDURE chk_org_date(P_date_start 	     DATE,
                         P_org_run_by_Id     NUMBER,
                         P_Business_Group_id NUMBER) IS
--
     CURSOR csr_org_dates IS
      SELECT organization_id
      FROM   hr_organization_units
      WHERE  organization_id   =  P_org_run_by_Id
      AND    business_group_id + 0 =  P_Business_Group_id
      AND    date_from         <= P_date_start
      AND    ((date_to is null) or
             (date_to is not null and date_to >= P_date_start));
--
--
  v_dummy_id              NUMBER;
--
--

       BEGIN
             OPEN csr_org_dates;
              FETCH csr_org_dates into v_dummy_id;
              IF csr_org_dates%notfound then
                 CLOSE csr_org_dates;
                  hr_utility.set_message(800,'HR_6122_RAC_ORG_NOT_VALID');
                  hr_utility.raise_error;
              ELSE
                  CLOSE csr_org_dates;
              END IF;
--
--

     END chk_org_date;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_auth_date                                                         --
-- Purpose                                                                 --
--    Checks that on update of the Activity Start that the authoriser   is --
--    not invalidated.                                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   Called from the client side the WVI for the date_start                --
-----------------------------------------------------------------------------
--
--
   PROCEDURE chk_auth_date(P_date_start        	       DATE,
                           P_authorising_person_id     NUMBER,
                           P_Business_Group_id         NUMBER) IS
--
     CURSOR csr_auth_date IS
           SELECT p.person_id
           FROM   per_people_f p
           WHERE  p.person_id              = P_authorising_person_id
           AND    p.current_employee_flag  = 'Y'
           AND    (p.business_group_id =  P_Business_Group_id OR
                nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
           AND    P_date_start
                  between p.effective_start_date and p.effective_end_date;
--
--
  v_dummy_id              NUMBER;
--
--

       BEGIN
             OPEN csr_auth_date;
              FETCH csr_auth_date into v_dummy_id;
              IF csr_auth_date%notfound then
                 CLOSE csr_auth_date;
                  hr_utility.set_message(800,'HR_7697_RAC_PER_NOT_VALID');
                  hr_utility.raise_error;
              ELSE
                  CLOSE csr_auth_date;
              END IF;
--
--

     END chk_auth_date;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_int_cont_date                                                     --
-- Purpose                                                                 --
--    Checks that on update of the Activity Start that the internal contact--
--     is not invalidated.                                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   Called from the client side the WVI for the date_start                --
-----------------------------------------------------------------------------
--
--
   PROCEDURE chk_int_cont_date(P_date_start        	 DATE,
                           P_internal_contact_person_id  NUMBER,
                           P_Business_Group_id           NUMBER) IS
--
     CURSOR csr_int_con_date IS
           SELECT p.person_id
           FROM   per_people_f p
           WHERE  p.person_id              = P_internal_contact_person_id
           AND    p.current_employee_flag  = 'Y'
           AND    p.employee_number is not null
           AND    (nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'Y'
                  OR p.business_group_id =  P_Business_Group_id)
           AND    P_date_start
                  between p.effective_start_date and p.effective_end_date;
--
--
  v_dummy_id              NUMBER;
--
--
       BEGIN
             OPEN csr_int_con_date;
              FETCH csr_int_con_date into v_dummy_id;
              IF csr_int_con_date%notfound then
                 CLOSE csr_int_con_date;
                  hr_utility.set_message(800,'HR_7696_RAC_PER_NOT_VALID');
                  hr_utility.raise_error;
              ELSE
                  CLOSE csr_int_con_date;
              END IF;
--
--
     END chk_int_cont_date;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_parent_dates                                                      --
-- Purpose                                                                 --
--   Item handler procedure. Supports the validation on Date Start in the  --
--   ACTIVITY block                                                        --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_parent_dates(P_date_start        DATE,
                           P_Business_Group_id NUMBER,
                           P_parent_rec_id    NUMBER)  IS
--
     CURSOR csr_par_rec_dates  IS

       SELECT recruitment_activity_id
       FROM   per_recruitment_activities
       WHERE  recruitment_activity_id  =    P_parent_rec_id
       AND    business_group_id + 0        =    P_Business_Group_id
       AND    date_start               <=   P_date_start
       AND    ((date_end is null) or
               (date_end is not null and date_end >= P_date_start));
--
--
  v_dummy_id              NUMBER;
--
--
       BEGIN
              OPEN csr_par_rec_dates;
               FETCH csr_par_rec_dates into v_dummy_id;
               IF csr_par_rec_dates%notfound then
                  CLOSE csr_par_rec_dates;
                   hr_utility.set_message(800,'HR_6461_RAC_PARENT_RAC_INVALID');
                   hr_utility.raise_error;
                ELSE
                  CLOSE csr_par_rec_dates;
                END IF;
--
--
      END chk_parent_dates;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_vacancy_dates                                                     --
-- Purpose                                                                 --
--   Item handler procedure. Supports the validation on Date Start in the  --
--   ACTIVITY block                                                        --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_vacancy_dates(P_date_start              DATE,
                            P_Business_Group_id       NUMBER,
                            P_rec_activity_id              NUMBER) IS
--
     CURSOR csr_vac_dates IS
       SELECT raf.vacancy_id
       FROM   per_vacancies v,
              per_recruitment_activity_for raf
       WHERE  raf.recruitment_activity_id     =    P_rec_activity_id
       AND    v.business_group_id + 0        =    P_Business_Group_id
       AND    raf.vacancy_id  = v.vacancy_id
       AND    (v.date_from        >   P_date_start
       OR     (v.date_to is not null and
                v.date_to < P_date_start));
--
--
  v_dummy_id              NUMBER;
--
--
       BEGIN
              OPEN csr_vac_dates;
               FETCH csr_vac_dates into v_dummy_id;
                 IF csr_vac_dates%found then
                  CLOSE csr_vac_dates;
                   hr_utility.set_message(800,'HR_6121_RAC_VACANCY_NOT_VALID');
                   hr_utility.raise_error;
                 ELSE
                   CLOSE csr_vac_dates;
                 END IF;
--
--
      END chk_vacancy_dates;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_child_rec_dates                                                   --
-- Purpose                                                                 --
--   Item handler procedure. Supports the validation on Date Start in the  --
--   ACTIVITY block                                                        --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_child_rec_dates(P_date_start              DATE,
                              P_Business_Group_id       NUMBER,
                              P_rec_act_id              NUMBER)  IS
--
     CURSOR csr_chk_exist_child IS
       SELECT 1
       FROM   per_recruitment_activities
       WHERE  parent_recruitment_activity_id = P_rec_act_id
       AND    business_group_id + 0              = P_Business_Group_id;
--

     CURSOR csr_child_dates IS
       SELECT parent_recruitment_activity_id
       FROM   per_recruitment_activities
       WHERE  parent_recruitment_activity_id =  P_rec_act_id
       AND    business_group_id + 0              =  P_Business_Group_id
       AND    P_date_start                   > date_start;
--
--
  v_dummy_id              NUMBER;
--
--
       BEGIN
           v_dummy_id := null;

           OPEN csr_chk_exist_child;
            FETCH csr_chk_exist_child into v_dummy_id;
              IF csr_chk_exist_child%found then
                 v_dummy_id := null;
                 CLOSE csr_chk_exist_child;
                 OPEN csr_child_dates;
                  FETCH csr_child_dates into v_dummy_id;
                    IF csr_child_dates%found then
                     CLOSE csr_child_dates;
                     hr_utility.set_message(800,'HR_6621_RAC_CHILD_BEFORE_RAC');
                     hr_utility.raise_error;
                    ELSE
                     CLOSE csr_child_dates;
                    END IF;
              END IF;
--
--
      END chk_child_rec_dates;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_child_end_dates                                                   --
-- Purpose                                                                 --
--   Item handler procedure. Supports the validation on Date Start in the  --
--   ACTIVITY block                                                        --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
PROCEDURE chk_child_end_dates(P_date_end                 DATE,
                              P_Business_Group_id        NUMBER,
                              P_rec_act_id               NUMBER)  IS
--
     CURSOR csr_chk_exist_child IS
       SELECT 1
       FROM   per_recruitment_activities
       WHERE  parent_recruitment_activity_id = P_rec_act_id
       AND    business_group_id + 0              = P_Business_Group_id;
--

     CURSOR csr_child_dates IS
       SELECT parent_recruitment_activity_id
       FROM   per_recruitment_activities
       WHERE  parent_recruitment_activity_id =  P_rec_act_id
       AND    business_group_id + 0              =  P_Business_Group_id
       AND    P_date_end                     <  date_start;
--
--
  v_dummy_id              NUMBER;
--
--
       BEGIN
           v_dummy_id := null;

           OPEN csr_chk_exist_child;
            FETCH csr_chk_exist_child into v_dummy_id;
              IF csr_chk_exist_child%found then
                 v_dummy_id := null;
                 CLOSE csr_chk_exist_child;
                 OPEN csr_child_dates;
                  FETCH csr_child_dates into v_dummy_id;
                    IF csr_child_dates%found then
                     CLOSE csr_child_dates;
                     hr_utility.set_message(800,'HR_6622_RAC_CHILD_AFTER_RAC');
                     hr_utility.raise_error;
                    ELSE
                     CLOSE csr_child_dates;
                    END IF;
              END IF;
--
--
      END chk_child_end_dates;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   default_currency_code
-- Purpose                                                                 --
--    to find the currency code for the Business Group of the Recrutiment  --
--    activity.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
FUNCTION default_currency_code(P_Business_Group_id  NUMBER) return VARCHAR2 IS
--
	CURSOR csr_currency IS
          SELECT currency_code
          FROM   per_business_groups
          WHERE  business_group_id = P_Business_Group_Id;
--
    v_default_currency   VARCHAR2(100);
--
     BEGIN
         v_default_currency := null;
         OPEN csr_currency;
           FETCH csr_currency into v_default_currency;
             CLOSE csr_currency;
      RETURN v_default_currency;
--
     END default_currency_code;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Insert_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure. Supports the insert of an ACTIVITY via the   --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
 -----------------------------------------------------------------------------
--

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Recruitment_Activity_Id             IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Authorising_Person_Id               NUMBER,
                     X_Run_By_Organization_Id              NUMBER,
                     X_Internal_Contact_Person_Id          NUMBER,
                     X_Parent_Rec_Activity_Id      NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Date_Start                          DATE,
                     X_Name                                VARCHAR2,
                     X_Actual_Cost                         VARCHAR2,
                     X_Comments                            varchar2,
                     X_Contact_Telephone_Number            VARCHAR2,
                     X_Date_Closing                        DATE,
                     X_Date_End                            DATE,
                     X_External_Contact                    VARCHAR2,
                     X_Planned_Cost                        VARCHAR2,
                     X_Type                                VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
 ) IS
   CURSOR C IS
            SELECT rowid
            FROM   PER_RECRUITMENT_ACTIVITIES
            WHERE  recruitment_activity_id = X_Recruitment_Activity_Id;



   CURSOR C2 IS
             SELECT per_recruitment_activities_s.nextval
             FROM sys.dual;

BEGIN
   IF (X_Recruitment_Activity_Id is NULL) then
     OPEN C2;
       FETCH C2 INTO X_Recruitment_Activity_Id;
     CLOSE C2;
   end IF;
  INSERT INTO PER_RECRUITMENT_ACTIVITIES(
          recruitment_activity_id,
          business_group_id,
          authorising_person_id,
          run_by_organization_id,
          internal_contact_person_id,
          parent_recruitment_activity_id,
          currency_code,
          date_start,
          name,
          actual_cost,
          comments,
          contact_telephone_number,
          date_closing,
          date_end,
          external_contact,
          planned_cost,
          type,
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
          attribute20
         ) VALUES (
          X_Recruitment_Activity_Id,
          X_Business_Group_Id,
          X_Authorising_Person_Id,
          X_Run_By_Organization_Id,
          X_Internal_Contact_Person_Id,
          X_Parent_Rec_Activity_Id,
          X_Currency_Code,
          X_Date_Start,
          X_Name,
          X_Actual_Cost,
          X_Comments,
          X_Contact_Telephone_Number,
          X_Date_Closing,
          X_Date_End,
          X_External_Contact,
          X_Planned_Cost,
          X_Type,
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
          X_Attribute20);

  OPEN C;
     FETCH C INTO X_Rowid;
  IF (C%NOTFOUND) then
    CLOSE C;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                 'per_recruitment_activity_pkg.insert_row');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
  end IF;
  CLOSE C;

END Insert_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Lock_Row                                                              --
-- Purpose                                                                 --
--   Table handler procedure that supports the insert , update and delete  --
--   of an activity by applying a lock on an activity in the Define        --
--   Recruitment Activity form.                                            --
-- Arguments                                                               --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Recruitment_Activity_Id               NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Authorising_Person_Id                 NUMBER,
                   X_Run_By_Organization_Id                NUMBER,
                   X_Internal_Contact_Person_Id            NUMBER,
                   X_Parent_Rec_Activity_Id        NUMBER,
                   X_Currency_Code                         VARCHAR2,
                   X_Date_Start                            DATE,
                   X_Name                                  VARCHAR2,
                   X_Actual_Cost                           VARCHAR2,
                   X_Comments                              varchar2,
                   X_Contact_Telephone_Number              VARCHAR2,
                   X_Date_Closing                          DATE,
                   X_Date_End                              DATE,
                   X_External_Contact                      VARCHAR2,
                   X_Planned_Cost                          VARCHAR2,
                   X_Type                                  VARCHAR2,
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
                   X_Attribute20                           VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_RECRUITMENT_ACTIVITIES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Recruitment_Activity_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
     FETCH C INTO Recinfo;
     IF (C%NOTFOUND) then
     CLOSE C;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruitment_activity_pkg.lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end IF;
  CLOSE C;
--
-- Change needed to remove trailing spaces.
--
Recinfo.attribute17 := rtrim(Recinfo.attribute17);
Recinfo.attribute18 := rtrim(Recinfo.attribute18);
Recinfo.attribute19 := rtrim(Recinfo.attribute19);
Recinfo.attribute20 := rtrim(Recinfo.attribute20);
Recinfo.currency_code := rtrim(Recinfo.currency_code);
Recinfo.name := rtrim(Recinfo.name);
Recinfo.actual_cost := rtrim(Recinfo.actual_cost);
Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.contact_telephone_number := rtrim(Recinfo.contact_telephone_number);
Recinfo.external_contact := rtrim(Recinfo.external_contact);
Recinfo.planned_cost := rtrim(Recinfo.planned_cost);
Recinfo.type := rtrim(Recinfo.type);
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
Recinfo.attribute13 := rtrim(Recinfo.attribute13);
Recinfo.attribute14 := rtrim(Recinfo.attribute14);
Recinfo.attribute15 := rtrim(Recinfo.attribute15);
Recinfo.attribute16 := rtrim(Recinfo.attribute16);
--
  IF (
          (   (Recinfo.recruitment_activity_id = X_Recruitment_Activity_Id)
           OR (    (Recinfo.recruitment_activity_id IS NULL)
               AND (X_Recruitment_Activity_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.authorising_person_id = X_Authorising_Person_Id)
           OR (    (Recinfo.authorising_person_id IS NULL)
               AND (X_Authorising_Person_Id IS NULL)))
      AND (   (Recinfo.run_by_organization_id = X_Run_By_Organization_Id)
           OR (    (Recinfo.run_by_organization_id IS NULL)
               AND (X_Run_By_Organization_Id IS NULL)))
      AND (   (Recinfo.internal_contact_person_id = X_Internal_Contact_Person_Id)
           OR (    (Recinfo.internal_contact_person_id IS NULL)
               AND (X_Internal_Contact_Person_Id IS NULL)))
      AND (   (Recinfo.parent_recruitment_activity_id =
      X_Parent_Rec_Activity_Id)
           OR (    (Recinfo.parent_recruitment_activity_id IS NULL)
               AND (X_Parent_Rec_Activity_Id IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.date_start = X_Date_Start)
           OR (    (Recinfo.date_start IS NULL)
               AND (X_Date_Start IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.actual_cost = X_Actual_Cost)
           OR (    (Recinfo.actual_cost IS NULL)
               AND (X_Actual_Cost IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.contact_telephone_number = X_Contact_Telephone_Number)
           OR (    (Recinfo.contact_telephone_number IS NULL)
               AND (X_Contact_Telephone_Number IS NULL)))
      AND (   (Recinfo.date_closing = X_Date_Closing)
           OR (    (Recinfo.date_closing IS NULL)
               AND (X_Date_Closing IS NULL)))
      AND (   (Recinfo.date_end = X_Date_End)
           OR (    (Recinfo.date_end IS NULL)
               AND (X_Date_End IS NULL)))
      AND (   (Recinfo.external_contact = X_External_Contact)
           OR (    (Recinfo.external_contact IS NULL)
               AND (X_External_Contact IS NULL)))
      AND (   (Recinfo.planned_cost = X_Planned_Cost)
           OR (    (Recinfo.planned_cost IS NULL)
               AND (X_Planned_Cost IS NULL)))
      AND (   (Recinfo.type = X_Type)
           OR (    (Recinfo.type IS NULL)
               AND (X_Type IS NULL)))
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
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end IF;

END Lock_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Update_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the update of an ACTIVITY via   --
--   Define Recruitment Activity form.                                     --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Recruitment_Activity_Id             NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Authorising_Person_Id               NUMBER,
                     X_Run_By_Organization_Id              NUMBER,
                     X_Internal_Contact_Person_Id          NUMBER,
                     X_Parent_Rec_Activity_Id      NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Date_Start                          DATE,
                     X_Name                                VARCHAR2,
                     X_Actual_Cost                         VARCHAR2,
                     X_Comments                            varchar2,
                     X_Contact_Telephone_Number            VARCHAR2,
                     X_Date_Closing                        DATE,
                     X_Date_End                            DATE,
                     X_External_Contact                    VARCHAR2,
                     X_Planned_Cost                        VARCHAR2,
                     X_Type                                VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
) IS
BEGIN
  UPDATE PER_RECRUITMENT_ACTIVITIES
  SET

    recruitment_activity_id                   =    X_Recruitment_Activity_Id,
    business_group_id                         =    X_Business_Group_Id,
    authorising_person_id                     =    X_Authorising_Person_Id,
    run_by_organization_id                    =    X_Run_By_Organization_Id,
    internal_contact_person_id                =    X_Internal_Contact_Person_Id,
    parent_recruitment_activity_id            =    X_Parent_Rec_Activity_Id,
    currency_code                             =    X_Currency_Code,
    date_start                                =    X_Date_Start,
    name                                      =    X_Name,
    actual_cost                               =    X_Actual_Cost,
    comments                                  =    X_Comments,
    contact_telephone_number                  =    X_Contact_Telephone_Number,
    date_closing                              =    X_Date_Closing,
    date_end                                  =    X_Date_End,
    external_contact                          =    X_External_Contact,
    planned_cost                              =    X_Planned_Cost,
    type                                      =    X_Type,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20
  WHERE rowid = X_rowid;

  IF (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruitment_activities_pkg.update_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end IF;

END Update_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Delete_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the delete of an ACTIVITY via   --
--   the Define Recruitment Activity form.                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_RECRUITMENT_ACTIVITIES
  WHERE  rowid = X_Rowid;

  IF (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_recruitment_activites_pkg.delete_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end IF;
END Delete_Row;

END PER_RECRUITMENT_ACTIVITIES_PKG;

/
