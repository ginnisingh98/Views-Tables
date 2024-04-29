--------------------------------------------------------
--  DDL for Package Body PER_VACANCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VACANCIES_PKG" as
/* $Header: pevac01t.pkb 120.3.12010000.9 2010/04/08 10:23:05 karthmoh ship $ */
/*   +=======================================================================+
     |           Copyright (c) 1993 Oracle Corporation                       |
     |              Redwood Shores, California, USA                          |
     |                   All rights reserved.                                |
     +=======================================================================+
Name
    per_vacancies_pkg
  Purpose
    Supports the VACANCY block in the form PERWSVAC (Define Requistion and
    Vacancy).
  Notes
    This package also contains one function which returns values for the
    FOLDER block of the View Vacancies form. The Function is B_Counter.

  History
    13-APR-94  H.Minton   70.0         Date created.

    23-MAY-94  H.Minton   70.1         Added new functions for View Vacancies
                                       - PERWILVA, folder form.

    28-JUN-94  D.Kerr     70.2         Fixed ref_int checks.

    ??         A.Roussel  70.3         Removed Rems for 10G Install

    25-AUG-94  H.Minton   70.4         Bug 824 - amended date format on csr
                                       current folder.

                          70.5         Amended header info.

    23-NOV-94  RFine      70.6         Suppressed index on business_group_id

    19-JAN-95  D.Kerr     70.8         Removed WHO- columns

    17-MAY-95  D.Kerr    70.9         1. Fixed usage check in
                                       D_from_updt_rec_act_chk
                                       Removed unncessary business group
                                       parameter from this procedure.
                                       2. Added check to per_assignments
                                       to check_references and call
                                       this procedure from delete_row.

    05-MAR-97  J.Alloun   70.10        Changed all occurances of system.dual
                                       to sys.dual for next release requirements.

    26-JAN-98  I.Harding  110.2        Added vacancy_category parameter to
                                       insert, update and lock procs.

    22-APR-98  D.Kerr     110.3        658840: removed date conversions in
                                       csr_current in folder_current.

    25-FEB-98  B.Goodsell 115.2        Added Budget Measurement columns to
                                       Table Handler procedures
    21-MAY-99  C.Carter   115.3        Removed set_token call after error
                                       message 6125.
    05-Oct-99  SCNair     115.4        Date Track position related changes
    12-Jun-00  hsajja     115.5        Changed HR_POSITIONS to HR_POSITIONS_F
                                       and corresponding effective_date changes
    26-Jun-00  C.Carter   115.6        Changed PER_JOBS to PER_JOBS_V.
    07-SEP-01  A.Cowan    115.7-10     Cascade vacancy enhancement
                                       bug # 1923803
    26-Jun-03  vanantha   115.12       Added a procedure D_to_updt_org_chk
                                       to validate end date for Vacancy
                                       with respect to Org end date.
    06-Jul-05 ghshanka    115.14       modified the cursor def in the procedure
                                       D_from_updt_person so that it can
                                       validate the cross business group
                                       profile option also.
    03-JUL-06  avarri     115.15       Modiifed the procedure Check_Unique_Name
                                       for 4262036.
    04-Nov-08  sidsaxen   115.17       Added procedure end_date_irec_RA, end_date_PER_RA
                                       and stubbed procedure D_from_updt_rec_act_chk
                                       for bug 6497289
    24-Feb-09  lbodired   115.19       Modified the procedure UPDATE_ROW
				       for the bug 7592739
    01-Jun-09 sidsaxen    115.23       bug 8518955, handled NULL while updating
                                       per_all_assignments_f in per_vacancies_pkg.update_row
    08-APR-10 karthmoh     120.3.12010000.9  Modified/Added Procedures for ER#8530112
============================================================================*/
----------------------------------------------------------------------------
--
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   To ensure the referential integrity when a vacancy is deleted from the--
--   Define Requisition and Vacancy form.                                  --
--   Checks that the vacancy is not used in a recruitment activity
--   or by an assignment.
-----------------------------------------------------------------------------
--
 PROCEDURE Check_References(P_vacancy_id               NUMBER ) is
     CURSOR c_check_references1 IS
            SELECT distinct(PV.NAME)
            FROM   PER_VACANCIES PV,
                   PER_ALL_ASSIGNMENTS_F PAF
            WHERE  PAF.VACANCY_ID        = P_vacancy_id
            AND    PV.VACANCY_ID         = P_vacancy_id
            AND    PAF.VACANCY_ID        = PV.VACANCY_ID;

   CURSOR c_check_ref_2 IS
                  SELECT PV.NAME
                  FROM   PER_VACANCIES PV
                     ,   PER_RECRUITMENT_ACTIVITY_FOR PRAF
                  WHERE  PRAF.VACANCY_ID        = P_vacancy_id
                  AND    PV.VACANCY_ID          = P_vacancy_id ;

--
V_name   VARCHAR2(30);
--

BEGIN
--
     OPEN c_check_references1;
     FETCH c_check_references1 into V_name;
     IF c_check_references1%FOUND THEN
       CLOSE c_check_references1;
       fnd_message.set_name('PER','HR_6125_REQS_VACS_DEL_ASSIGN');
       hr_utility.raise_error;
     ELSE CLOSE c_check_references1;
     END IF;
--
   OPEN c_check_ref_2;
   FETCH c_check_ref_2 into V_name;
   IF c_check_ref_2%FOUND THEN
     CLOSE c_check_ref_2;
     fnd_message.set_name('PER','HR_6126_REQS_VACS_DEL_REC_ACTY');
     fnd_message.set_token('VACANCY_NAME',V_name);
     hr_utility.raise_error;
   ELSE CLOSE c_check_ref_2;
   END IF;
--
 END Check_References;
----------------------------------------------------------------------------
--
-- Name                                                                    --
--   B_counter                                                             --
-- Purpose                                                                 --
--   The purpose of this function is to return the values for the FOLDER
--   block of the forms VIEW VACANCIES.
-----------------------------------------------------------------------------
FUNCTION B_counter(P_Business_group_id         NUMBER,
                    P_vacancy_id               NUMBER,
                    P_legislation_code         VARCHAR2,
                    P_vac_type                 VARCHAR2) return NUMBER IS

   CURSOR csr_counter IS
       SELECT COUNT(distinct ass.assignment_id)
        FROM   PER_ALL_ASSIGNMENTS ASS,
               PER_ASSIGNMENT_STATUS_TYPES a
        where  nvl(A.BUSINESS_GROUP_ID,P_Business_group_id) =
               P_Business_group_id
        and    ass.business_group_id + 0         = P_Business_group_id
        and    ass.ASSIGNMENT_TYPE           = 'A'
        and    ass.ASSIGNMENT_STATUS_TYPE_ID = A.ASSIGNMENT_STATUS_TYPE_ID
        and    nvl(a.LEGISLATION_CODE,P_legislation_code) =
               P_legislation_code
        and    A.PER_SYSTEM_STATUS           = P_vac_type
        and    ass.vacancy_id                = P_vacancy_id;

--
    v_number_of_asgs   NUMBER(15);
--
     BEGIN
        OPEN csr_counter;
        FETCH csr_counter into v_number_of_asgs;
        CLOSE csr_counter;
        RETURN v_number_of_asgs;
     END B_counter;
----------------------------------------------------------------------------
--
-- Name                                                                    --
--   folder_hires                                                          --
-- Purpose                                                                 --
--   the purpose of this function is to return the number of applicants who
--   have been hired as employees as a result of being hired into a vacancy.
--   This function is used by the folder form PERWILVA - View Vacancies.
-----------------------------------------------------------------------------
FUNCTION folder_hires(P_Business_group_id        NUMBER,
                      P_vacancy_id               NUMBER
                      ) return NUMBER IS

    CURSOR csr_hires IS
     SELECT COUNT(*)
     FROM   PER_ALL_ASSIGNMENTS A
     WHERE  A.business_group_id + 0 = P_Business_group_id
     AND    A.VACANCY_ID        = P_vacancy_id
     AND    A.ASSIGNMENT_TYPE =   'E';

--
    v_vac_hires   NUMBER(15);
--
     BEGIN
        OPEN csr_hires;
        FETCH csr_hires into v_vac_hires;
        CLOSE csr_hires;
        RETURN v_vac_hires;
     END folder_hires;

----------------------------------------------------------------------------
-- Name                                                                    --
--   folder_current                                                        --
-- Purpose                                                                 --
--   the purpose of this function is to return the number of current openings
--   for the vacancy as of the session date i.e it is the initial number of
--   openings for the vacancy as when the vacancy was defined minus the
--   number of applicants who have been hired into the vacancy.
-----------------------------------------------------------------------------
FUNCTION folder_current(P_Business_group_id        NUMBER,
                        P_vacancy_id               NUMBER,
                        P_session_date             DATE
                        ) return NUMBER IS

    CURSOR csr_current IS
     SELECT  COUNT(DISTINCT A.ASSIGNMENT_ID)
     FROM    PER_ALL_ASSIGNMENTS A
     WHERE   A.VACANCY_ID           = P_vacancy_id
     AND     A.business_group_id + 0    = P_Business_group_id
     AND     A.ASSIGNMENT_TYPE      = 'E'
     AND     A.EFFECTIVE_START_DATE <= P_session_date ;


--
    v_vac_current           NUMBER(15);
--
     BEGIN
        OPEN csr_current;
        FETCH csr_current into v_vac_current;
        CLOSE csr_current;
        RETURN v_vac_current;
    END folder_current;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Chk_appl_exists                                                       --
-- Purpose                                                                 --
--   Verify the effective date, you cannot change the effective date of    --
--   this vacancy to a future date as applications exist within the vacancy--
--   availability period.                                                  --
--   Called from WHEN-VALIDATE-ITEM in the vacancy block.                  --
--                                                                         --
-----------------------------------------------------------------------------
--
procedure chk_appl_exists (P_vacancy_id		NUMBER,
                           P_vac_date_from       DATE,
                           P_vac_date_to         DATE,
	                   P_end_of_time	 DATE
		           )
is
 cursor csr_appl_exists
 is
  select '1'
  from per_all_assignments_f
  where vacancy_id =P_vacancy_id
  and effective_start_date < P_vac_date_from
  and assignment_type = 'A';

 l_flag varchar2(1);

begin

 open csr_appl_exists ;

 fetch csr_appl_exists into l_flag;

 if csr_appl_exists%found then
  close csr_appl_exists;
   fnd_message.set_name('PER','HR_449819_VACS_APL_ACTS');
   hr_utility.raise_error;
 else
  close csr_appl_exists;
 end if;

end chk_appl_exists;
----------------------------------------------------------------------------_
-- Name                                                                    --
--   Check_Unique_Name                                                     --
-- Purpose                                                                 --
--   checks that the vacancy name is unique within the requisition.        --
--   Called from the client side package VACANCY_ITEMS from the procedure  --
-----------------------------------------------------------------------------
--
-- Modified for 4262036.
PROCEDURE Check_Unique_Name(P_Name                      VARCHAR2,
                            P_business_group_id         NUMBER,
                            P_rowid                     VARCHAR2)  IS

   CURSOR name_exists IS
                       SELECT v.name
                       FROM   PER_ALL_VACANCIES  v
                       WHERE  v.NAME                = P_Name
                       AND    v.business_group_id   = P_business_group_id
                       AND    (P_rowid             <> v.rowid
                                                    or P_rowid is NULL);
v_req_name VARCHAR2(30);
--
BEGIN
--
  OPEN name_exists;
  FETCH name_exists into v_req_name;
     IF name_exists%found THEN
        CLOSE name_exists;
        fnd_message.set_name('PER', 'HR_6638_VACS_UNIQUE_VAC_NAME');
        fnd_message.set_token('REQ_NAME',v_req_name);
        hr_utility.raise_error;
     ELSE CLOSE name_exists;
     END IF;
END Check_Unique_Name;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_in_req_dates                                                    --
-- Purpose                                                                 --
--   Ensure that the vacancy date from are witin the requisition dates.    --
--   Called from WHEN-VALIDATE-ITEM in the vacancy block.                  --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Check_in_req_dates(P_requisition_id           NUMBER,
                             P_Business_group_id        NUMBER,
                             P_vac_date_from            DATE)   IS

    CURSOR c_check_in_req_dates IS
           SELECT 1
           FROM   PER_REQUISITIONS PR
           WHERE  PR.REQUISITION_ID    = P_requisition_id
           AND    PR.business_group_id + 0 = P_Business_group_id
           AND    P_vac_date_from      < PR.DATE_FROM;


v_dummy         NUMBER(1);
--
   BEGIN
--
  OPEN c_check_in_req_dates;
  FETCH c_check_in_req_dates into v_dummy;
     IF c_check_in_req_dates%found THEN
        CLOSE c_check_in_req_dates;
        fnd_message.set_name('PER', 'HR_6640_VACS_IN_REQ_DATES');
        hr_utility.raise_error;
     ELSE CLOSE c_check_in_req_dates;
     END IF;
END Check_in_req_dates;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Chk_dt_to_in_req_dates                                                --
-- Purpose                                                                 --
--   Ensure that the vacancy date from are witin the requisition dates.    --
--   Called from WHEN-VALIDATE-ITEM in the vacancy block.                  --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Chk_dt_to_in_req_dates(P_requisition_id               NUMBER,
                                 P_Business_group_id            NUMBER,
                                 P_vac_date_to                  DATE)   IS

    CURSOR c_in_req_dt IS
           SELECT 1
           FROM   PER_REQUISITIONS PR
           WHERE  PR.REQUISITION_ID    = P_requisition_id
           AND    PR.business_group_id + 0 = P_Business_group_id
           AND    NVL(P_vac_date_to,to_date('31-12-4712','DD-MM-YYYY'))        > PR.DATE_TO;


v_dummy         NUMBER(1);
--
   BEGIN
--
  OPEN c_in_req_dt;
  FETCH c_in_req_dt into v_dummy;
     IF c_in_req_dt%found THEN
        CLOSE c_in_req_dt;
        fnd_message.set_name('PER','HR_6843_VACS_DATE_TO_VAC');
        hr_utility.raise_error;
     ELSE CLOSE c_in_req_dt;
     END IF;
END Chk_dt_to_in_req_dates;
--
----------------------------------------------------------------------------
-- Name                                                                    --
--   Date_from_upd_validation                                              --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate any of the      --
--   vacancy_for region.
-----------------------------------------------------------------------------
PROCEDURE Date_from_upd_validation(
                                    Pz_vac_date_from       DATE,
                                    Pz_business_group_id   NUMBER,
                                    Pz_start_of_time         DATE,
                                    Pz_end_of_time         DATE,
                                    Pz_organization_id     NUMBER,
                                    Pz_position_id         NUMBER,
                                    Pz_people_group_id     NUMBER,
                                    Pz_job_id              NUMBER,
                                    Pz_grade_id            NUMBER,
                                    Pz_recruiter_id        NUMBER,
                                    Pz_location_id         NUMBER
                                    ) IS

 BEGIN
  IF Pz_organization_id IS NOT NULL THEN
    PER_VACANCIES_PKG.D_from_updt_org_chk(
                               P_Business_group_id   => Pz_business_group_id,
                               P_vac_date_from       => Pz_vac_date_from,
                               P_organization_id     => Pz_organization_id);
  END IF;

  IF Pz_position_id IS NOT NULL THEN
    PER_VACANCIES_PKG.D_from_updt_pos_chk(
                       P_Business_group_id   => Pz_business_group_id,
                       P_vac_date_from       => Pz_vac_date_from,
                       P_position_id         => Pz_position_id);
  END IF;

  IF Pz_people_group_id IS NOT NULL THEN
    PER_VACANCIES_PKG.D_from_updt_grp_chk(
                             P_vac_date_from       => Pz_vac_date_from,
                             P_start_of_time         => Pz_start_of_time,
                             P_people_group_id     => Pz_people_group_id);
  END IF;

  IF Pz_job_id IS NOT NULL THEN
   PER_VACANCIES_PKG.D_from_updt_job_chk(
                                  P_vac_date_from      => Pz_vac_date_from,
                                  P_Business_group_id  => Pz_business_group_id,
                                  P_job_id             => Pz_job_id);
  END IF;

  IF Pz_grade_id IS NOT NULL THEN
   PER_VACANCIES_PKG.D_from_updt_grd_chk
                          (P_vac_date_from     => Pz_vac_date_from,
                           P_business_group_id => Pz_business_group_id,
                           P_grade_id          => Pz_grade_id);
  END IF;

  IF Pz_location_id IS NOT NULL THEN
   PER_VACANCIES_PKG.D_from_updt_loc_chk(
                                    P_vac_date_from       => Pz_vac_date_from,
                                    P_end_of_time         => Pz_end_of_time,
                                    P_location_id         => Pz_location_id);
  END IF;


  IF Pz_recruiter_id IS NOT NULL THEN
   PER_VACANCIES_PKG.D_from_updt_person(
                                P_vac_date_from       => Pz_vac_date_from,
                                P_recruiter_id        => Pz_recruiter_id,
                                P_business_group_id   => Pz_business_group_id);
  END IF;

 END Date_from_upd_validation;

-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_rec_act_chk                                               --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate any recruitment --
--   activity that may be using the vacancy.                               --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
PROCEDURE D_from_updt_rec_act_chk(P_vacancy_id          NUMBER,
                                  P_vac_date_from       DATE,
                                  P_vac_date_to         DATE,
                                  P_end_of_time         DATE)   IS

        -- This cursor retrieves a row if there is a recruitment activity
        -- using the given vacancy where either of its start/end dates
        -- are outside the vacancy dates.
        CURSOR c_rec_act_chk IS
                SELECT 1
                FROM  PER_RECRUITMENT_ACTIVITY_FOR F,
                      PER_RECRUITMENT_ACTIVITIES   ACTS
                WHERE F.VACANCY_ID              = P_vacancy_id
                AND   F.RECRUITMENT_ACTIVITY_ID = ACTS.RECRUITMENT_ACTIVITY_ID
                AND   ( ACTS.DATE_START < P_vac_date_from
                        OR nvl(ACTS.DATE_END,p_end_of_time) > nvl(P_vac_date_to, P_end_of_time) ) ;

--
v_dummy         NUMBER(1);
--
 BEGIN
--
-- stubbed for bug 6497289
hr_utility.set_location('Entering: D_from_updt_rec_act_chk',10);
/*
      OPEN c_rec_act_chk;
      FETCH c_rec_act_chk into v_dummy;
         IF c_rec_act_chk%found THEN
            CLOSE c_rec_act_chk;
            fnd_message.set_name('PER','HR_6641_VACS_REC_ACTS');
            hr_utility.raise_error;
         ELSE CLOSE c_rec_act_chk;
         END IF;
*/
hr_utility.set_location('Leaving: D_from_updt_rec_act_chk',100);
--
END D_from_updt_rec_act_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_org_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the organization--
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
PROCEDURE D_from_updt_org_chk(P_Business_group_id   NUMBER,
                              P_vac_date_from       DATE,
                              P_organization_id     NUMBER)    IS

        CURSOR c_org_chk IS
                SELECT 1
                FROM  HR_ORGANIZATION_UNITS HOU
                WHERE HOU.ORGANIZATION_ID    = P_organization_id
                AND   HOU.business_group_id + 0  = P_Business_group_id
                AND   P_vac_date_from        < HOU.DATE_FROM;

--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_org_chk;
      FETCH c_org_chk into v_dummy;
         IF c_org_chk%found THEN
            CLOSE c_org_chk;
            fnd_message.set_name('PER','HR_6188_REQS_VACS_DATE_FROM');
            fnd_message.set_token('PART','organization');
            hr_utility.raise_error;
         ELSE CLOSE c_org_chk;
         END IF;
--
END D_from_updt_org_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_to_updt_org_chk                                                     --
-- Purpose                                                                 --
--   Ensure that the vacancy date_to does not invalidate the organization  --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.
-----------------------------------------------------------------------------
--
PROCEDURE D_to_updt_org_chk(P_Business_group_id   NUMBER,
                              P_vac_date_to       DATE,
                              P_organization_id     NUMBER)    IS

        CURSOR c_org_chk IS
                SELECT date_to
                FROM  HR_ORGANIZATION_UNITS HOU
                WHERE HOU.ORGANIZATION_ID    = P_organization_id
                AND   HOU.business_group_id + 0  = P_Business_group_id
                AND   P_vac_date_to > nvl(HOU.date_to, hr_api.g_eot);

--
v_dummy         NUMBER(1);
v_date          Date;
--
 BEGIN
--
      OPEN c_org_chk;
      FETCH c_org_chk into v_date;

        IF c_org_chk%found THEN
            CLOSE c_org_chk;
            fnd_message.set_name('PER',' HR_289199_ORG_VACS_DATE_TO');
            fnd_message.set_token('DATE',v_date);
            hr_utility.raise_error;
         ELSE CLOSE c_org_chk;
         END IF;
--
END D_to_updt_org_chk;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_pos_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the position    --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_pos_chk(P_Business_group_id   NUMBER,
                                P_vac_date_from       DATE,
                                P_position_id         NUMBER)    IS
 --
 -- Changed 05-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked positions requirement
        CURSOR c_pos_chk IS
                SELECT 1
                FROM  HR_POSITIONS_F POS
                WHERE POS.POSITION_ID       =  P_position_id
                AND   POS.business_group_id + 0  = P_Business_group_id
                AND   P_vac_date_from        < POS.DATE_EFFECTIVE;

--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_pos_chk;
      FETCH c_pos_chk into v_dummy;
         IF c_pos_chk%found THEN
            CLOSE c_pos_chk;
            fnd_message.set_name('PER','HR_6188_REQS_VACS_DATE_FROM');
            fnd_message.set_token('PART','position');
            hr_utility.raise_error;
         ELSE CLOSE c_pos_chk;
         END IF;
END D_from_updt_pos_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_grp_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the group       --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_grp_chk(P_vac_date_from       DATE,
                                P_start_of_time         DATE,
                                P_people_group_id     NUMBER)    IS

        CURSOR c_grp_chk IS
                SELECT 1
                FROM  PAY_PEOPLE_GROUPS PPG
                WHERE PPG.PEOPLE_GROUP_ID    = P_people_group_id
                AND   P_vac_date_from        < nvl(PPG.START_DATE_ACTIVE,
                                                   P_start_of_time);

--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_grp_chk;
      FETCH c_grp_chk into v_dummy;
         IF c_grp_chk%found THEN
            CLOSE c_grp_chk;
            fnd_message.set_name('PER','HR_6188_REQS_VACS_DATE_FROM');
            fnd_message.set_token('PART','group');
            hr_utility.raise_error;
         ELSE CLOSE c_grp_chk;
         END IF;
END D_from_updt_grp_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_job_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the job         --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_job_chk(P_vac_date_from       DATE,
                                P_business_group_id   NUMBER,
                                P_job_id              NUMBER)    IS

        CURSOR c_job_chk IS
                SELECT 1
                FROM  PER_JOBS_V PJ
                WHERE PJ.JOB_ID            = P_job_id
                AND   PJ.business_group_id + 0 = P_business_group_id
                AND   P_vac_date_from      < PJ.DATE_FROM;

--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_job_chk;
      FETCH c_job_chk into v_dummy;
         IF c_job_chk%found THEN
            CLOSE c_job_chk;
            fnd_message.set_name('PER','HR_6188_REQS_VACS_DATE_FROM');
            fnd_message.set_token('PART','job');
            hr_utility.raise_error;
         ELSE CLOSE c_job_chk;
         END IF;
END D_from_updt_job_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_grd_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the grade       --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_grd_chk(P_vac_date_from       DATE,
                                P_business_group_id   NUMBER,
                                P_grade_id            NUMBER)    IS

        CURSOR c_grade_chk IS
                SELECT 1
                FROM  PER_GRADES PG
                WHERE PG.GRADE_ID          = P_grade_id
                AND   PG.business_group_id + 0 = P_business_group_id
                AND   P_vac_date_from      < PG.DATE_FROM;

--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_grade_chk;
      FETCH c_grade_chk into v_dummy;
         IF c_grade_chk%found THEN
            CLOSE c_grade_chk;
            fnd_message.set_name('PER','HR_6188_REQS_VACS_DATE_FROM');
            fnd_message.set_token('PART','grade');
            hr_utility.raise_error;
         ELSE CLOSE c_grade_chk;
         END IF;
END D_from_updt_grd_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_loc_chk                                                   --
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the location    --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_loc_chk(P_vac_date_from       DATE,
                                P_end_of_time         DATE,
                                P_location_id         NUMBER)    IS

        CURSOR c_loc_chk IS
                SELECT 1
                FROM  HR_LOCATIONS HL
                WHERE HL.LOCATION_ID       = P_location_id
                AND   P_vac_date_from    > nvl(HL.INACTIVE_DATE,P_end_of_time);

--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_loc_chk;
      FETCH c_loc_chk into v_dummy;
         IF c_loc_chk%found THEN
            CLOSE c_loc_chk;
            fnd_message.set_name('PER','HR_6188_REQS_VACS_DATE_FROM');
            fnd_message.set_token('PART','location');
            hr_utility.raise_error;
         ELSE CLOSE c_loc_chk;
         END IF;
END D_from_updt_loc_chk;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   D_from_updt_person
-- Purpose                                                                 --
--   Ensure that the vacancy date_from does not invalidate the recruiter   --
--   part of the vacancy.                                                  --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
  PROCEDURE D_from_updt_person(P_vac_date_from       DATE,
                               P_recruiter_id        NUMBER,
                               P_business_group_id   NUMBER) IS
  -- bug 4475075 in the following cursor commented out the business group
  -- validation condition and redifined .
        CURSOR c_person IS
                SELECT 1
                FROM  PER_ALL_PEOPLE_F P
                WHERE P.PERSON_ID         = P_recruiter_id
                -- AND   P.business_group_id + 0 = P_business_group_id
                AND  ( P.business_group_id  = P_business_group_id or
                     nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                AND   P_vac_date_from    BETWEEN p.effective_start_date
                                         AND     p.effective_end_date;
  -- bug 447505 ends here
--
v_dummy         NUMBER(1);
--
 BEGIN
--
      OPEN c_person;
      FETCH c_person into v_dummy;
         IF c_person%notfound THEN
            CLOSE c_person;
            fnd_message.set_name('PER','HR_6642_VACS_RECRUITER');
            hr_utility.raise_error;
         ELSE CLOSE c_person;
        END IF;
END D_from_updt_person;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_people_group_id
-- Purpose                                                                 --
--   to get the people_group_structure for the group key flexfield in the  --
--   vacancy zone of PERWSVAC.                                             --
-- Arguments                                                               --
--   see below.                                                            --
-----------------------------------------------------------------------------
FUNCTION get_people_group(P_Business_Group_id  NUMBER)  return VARCHAR2 IS

        CURSOR c_pg IS
               Select people_group_structure
               From   per_business_groups
               Where  business_group_id + 0   = P_Business_Group_id;

--
    v_people_group_structure   VARCHAR2(240);
--
     BEGIN
        OPEN c_pg;
        FETCH c_pg into v_people_group_structure;
        CLOSE c_pg;
        RETURN v_people_group_structure;
     END get_people_group;
-----------------------------------------------------------------------------

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Vacancy_Id                   IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Requisition_Id                      NUMBER,
                     X_People_Group_Id                     NUMBER,
                     X_People_Group_Name                   VARCHAR2,
                     X_Location_Id                         NUMBER,
                     X_Recruiter_Id                        NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Description                         VARCHAR2,
                     X_Vacancy_category                    varchar2,
                     X_Number_Of_Openings                  NUMBER,
                     X_Status                              VARCHAR2,
                     X_Budget_Measurement_Type             VARCHAR2,
                     X_Budget_Measurement_Value            NUMBER,
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
                     X_Attribute20                         VARCHAR2 )
IS
   CURSOR C IS SELECT rowid
               FROM  PER_VACANCIES
               WHERE vacancy_id = X_Vacancy_Id;


    CURSOR C2 IS SELECT per_vacancies_s.nextval
                 FROM  sys.dual;
BEGIN

   if (X_Vacancy_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Vacancy_Id;
     CLOSE C2;
   end if;
   CHK_POS_BUDGET_VAL(X_Position_Id,X_Date_From,X_Organization_Id,X_Number_Of_Openings,X_Vacancy_Id);
  INSERT INTO PER_VACANCIES(
          vacancy_id,
          business_group_id,
          position_id,
          job_id,
          grade_id,
          organization_id,
          requisition_id,
          people_group_id,
          location_id,
          recruiter_id,
          date_from,
          name,
          comments,
          date_to,
          description,
          vacancy_category,
          number_of_openings,
          status,
          budget_measurement_type,
          budget_measurement_value,
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
          X_Vacancy_Id,
          X_Business_Group_Id,
          X_Position_Id,
          X_Job_Id,
          X_Grade_Id,
          X_Organization_Id,
          X_Requisition_Id,
          X_People_Group_Id,
          X_Location_Id,
          X_Recruiter_Id,
          X_Date_From,
          X_Name,
          X_Comments,
          X_Date_To,
          X_Description,
          X_vacancy_category,
          X_Number_Of_Openings,
          X_Status,
          X_Budget_Measurement_Type,
          X_Budget_Measurement_Value,
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
          X_Attribute20 );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                 'per_vacancies_pkg.insert_row');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
  end if;
  CLOSE C;
--
  per_applicant_pkg.update_group ( x_people_group_id,
                                   x_people_group_name ) ;
--
END Insert_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Lock_Row                                                              --
-- Purpose                                                                 --
--   Table handler procedure that supports the insert , update and delete  --
--   of a vacancy by applying a lock on a vacancy in the Define            --
--   Requisition and Vacnacy form.                                         --
-- Arguments                                                               --
-- Notes                                                                   --
-----------------------------------------------------------------------------
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Vacancy_Id                            NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Position_Id                           NUMBER,
                   X_Job_Id                                NUMBER,
                   X_Grade_Id                              NUMBER,
                   X_Organization_Id                       NUMBER,
                   X_Requisition_Id                        NUMBER,
                   X_People_Group_Id                       NUMBER,
                   X_Location_Id                           NUMBER,
                   X_Recruiter_Id                          NUMBER,
                   X_Date_From                             DATE,
                   X_Name                                  VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Date_To                               DATE,
                   X_Description                           VARCHAR2,
                   X_Vacancy_category                      varchar2,
                   X_Number_Of_Openings                    NUMBER,
                   X_Status                                VARCHAR2,
                   X_Budget_Measurement_Type               VARCHAR2,
                   X_Budget_Measurement_Value              NUMBER,
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
                   X_Attribute20                           VARCHAR2)
IS
  CURSOR C IS
      SELECT *
      FROM   PER_VACANCIES
      WHERE  rowid = X_Rowid
      FOR UPDATE of Vacancy_Id NOWAIT;
BEGIN
  OPEN C;
  FETCH C INTO g_Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_vacancies_pkb.lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
--
g_Recinfo.attribute18 := rtrim(g_Recinfo.attribute18);
g_Recinfo.attribute19 := rtrim(g_Recinfo.attribute19);
g_Recinfo.attribute20 := rtrim(g_Recinfo.attribute20);
g_Recinfo.name := rtrim(g_Recinfo.name);
g_Recinfo.comments := rtrim(g_Recinfo.comments);
g_Recinfo.description := rtrim(g_Recinfo.description);
g_Recinfo.vacancy_category := rtrim(g_Recinfo.vacancy_category);
g_Recinfo.status := rtrim(g_Recinfo.status);
g_Recinfo.budget_measurement_type := rtrim(g_Recinfo.budget_measurement_type);
g_Recinfo.attribute_category := rtrim(g_Recinfo.attribute_category);
g_Recinfo.attribute1 := rtrim(g_Recinfo.attribute1);
g_Recinfo.attribute2 := rtrim(g_Recinfo.attribute2);
g_Recinfo.attribute3 := rtrim(g_Recinfo.attribute3);
g_Recinfo.attribute4 := rtrim(g_Recinfo.attribute4);
g_Recinfo.attribute5 := rtrim(g_Recinfo.attribute5);
g_Recinfo.attribute6 := rtrim(g_Recinfo.attribute6);
g_Recinfo.attribute7 := rtrim(g_Recinfo.attribute7);
g_Recinfo.attribute8 := rtrim(g_Recinfo.attribute8);
g_Recinfo.attribute9 := rtrim(g_Recinfo.attribute9);
g_Recinfo.attribute10 := rtrim(g_Recinfo.attribute10);
g_Recinfo.attribute11 := rtrim(g_Recinfo.attribute11);
g_Recinfo.attribute12 := rtrim(g_Recinfo.attribute12);
g_Recinfo.attribute13 := rtrim(g_Recinfo.attribute13);
g_Recinfo.attribute14 := rtrim(g_Recinfo.attribute14);
g_Recinfo.attribute15 := rtrim(g_Recinfo.attribute15);
g_Recinfo.attribute16 := rtrim(g_Recinfo.attribute16);
g_Recinfo.attribute17 := rtrim(g_Recinfo.attribute17);
--
  if (
          (   (g_Recinfo.vacancy_id = X_Vacancy_Id)
           OR (    (g_Recinfo.vacancy_id IS NULL)
               AND (X_Vacancy_Id IS NULL)))
      AND (   (g_Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (g_Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (g_Recinfo.position_id = X_Position_Id)
           OR (    (g_Recinfo.position_id IS NULL)
               AND (X_Position_Id IS NULL)))
      AND (   (g_Recinfo.job_id = X_Job_Id)
           OR (    (g_Recinfo.job_id IS NULL)
               AND (X_Job_Id IS NULL)))
      AND (   (g_Recinfo.grade_id = X_Grade_Id)
           OR (    (g_Recinfo.grade_id IS NULL)
               AND (X_Grade_Id IS NULL)))
      AND (   (g_Recinfo.organization_id = X_Organization_Id)
           OR (    (g_Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (g_Recinfo.requisition_id = X_Requisition_Id)
           OR (    (g_Recinfo.requisition_id IS NULL)
               AND (X_Requisition_Id IS NULL)))
      AND (   (g_Recinfo.people_group_id = X_People_Group_Id)
           OR (    (g_Recinfo.people_group_id IS NULL)
               AND (X_People_Group_Id IS NULL)))
      AND (   (g_Recinfo.location_id = X_Location_Id)
           OR (    (g_Recinfo.location_id IS NULL)
               AND (X_Location_Id IS NULL)))
      AND (   (g_Recinfo.recruiter_id = X_Recruiter_Id)
           OR (    (g_Recinfo.recruiter_id IS NULL)
               AND (X_Recruiter_Id IS NULL)))
      AND (   (g_Recinfo.date_from = X_Date_From)
           OR (    (g_Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (g_Recinfo.name = X_Name)
           OR (    (g_Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (g_Recinfo.comments = X_Comments)
           OR (    (g_Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (g_Recinfo.date_to = X_Date_To)
           OR (    (g_Recinfo.date_to IS NULL)
               AND (X_Date_To IS NULL)))
      AND (   (g_Recinfo.description = X_Description)
           OR (    (g_Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (g_Recinfo.vacancy_category = X_vacancy_category)
           OR (    (g_Recinfo.vacancy_category IS NULL)
               AND (X_vacancy_category IS NULL)))
      AND (   (g_Recinfo.number_of_openings = X_Number_Of_Openings)
           OR (    (g_Recinfo.number_of_openings IS NULL)
               AND (X_Number_Of_Openings IS NULL)))
      AND (   (g_Recinfo.status = X_Status)
           OR (    (g_Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (g_Recinfo.budget_measurement_type = X_Budget_Measurement_Type)
           OR (    (g_Recinfo.budget_measurement_type IS NULL)
               AND (X_Budget_Measurement_Type IS NULL)))
      AND (   (g_Recinfo.budget_measurement_value = X_Budget_Measurement_Value)
           OR (    (g_Recinfo.budget_measurement_value IS NULL)
               AND (X_Budget_Measurement_Value IS NULL)))
      AND (   (g_Recinfo.attribute_category = X_Attribute_Category)
           OR (    (g_Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (g_Recinfo.attribute1 = X_Attribute1)
           OR (    (g_Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (g_Recinfo.attribute2 = X_Attribute2)
           OR (    (g_Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (g_Recinfo.attribute3 = X_Attribute3)
           OR (    (g_Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (g_Recinfo.attribute4 = X_Attribute4)
           OR (    (g_Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (g_Recinfo.attribute5 = X_Attribute5)
           OR (    (g_Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (g_Recinfo.attribute6 = X_Attribute6)
           OR (    (g_Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (g_Recinfo.attribute7 = X_Attribute7)
           OR (    (g_Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (g_Recinfo.attribute8 = X_Attribute8)
           OR (    (g_Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (g_Recinfo.attribute9 = X_Attribute9)
           OR (    (g_Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (g_Recinfo.attribute10 = X_Attribute10)
           OR (    (g_Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (g_Recinfo.attribute11 = X_Attribute11)
           OR (    (g_Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (g_Recinfo.attribute12 = X_Attribute12)
           OR (    (g_Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (g_Recinfo.attribute13 = X_Attribute13)
           OR (    (g_Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (g_Recinfo.attribute14 = X_Attribute14)
           OR (    (g_Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (g_Recinfo.attribute15 = X_Attribute15)
           OR (    (g_Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (g_Recinfo.attribute16 = X_Attribute16)
           OR (    (g_Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (g_Recinfo.attribute17 = X_Attribute17)
           OR (    (g_Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (g_Recinfo.attribute18 = X_Attribute18)
           OR (    (g_Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (g_Recinfo.attribute19 = X_Attribute19)
           OR (    (g_Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (g_Recinfo.attribute20 = X_Attribute20)
           OR (    (g_Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
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
--   Table handler procedure that supports the update of a VACANCY via     --
--   Define Requistion and Vacancy form.                                   --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--   None.                                                                 --
-----------------------------------------------------------------------------
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Vacancy_Id                          NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Requisition_Id                      NUMBER,
                     X_People_Group_Id                     NUMBER,
                     X_People_Group_Name                   VARCHAR2,
                     X_Location_Id                         NUMBER,
                     X_Recruiter_Id                        NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Description                         VARCHAR2,
                     X_Vacancy_category                    varchar2,
                     X_Number_Of_Openings                  NUMBER,
                     X_Status                              VARCHAR2,
                     X_Budget_Measurement_Type             VARCHAR2,
                     X_Budget_Measurement_Value            NUMBER,
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
l_end_of_time  date  := hr_api.g_eot;
BEGIN
--
  IF X_Organization_Id is not null then
     PER_VACANCIES_PKG.D_to_updt_org_chk(P_Business_group_id  => X_Business_group_id
                                     ,P_vac_date_to       => X_Date_To
                                     ,P_organization_id   => X_Organization_Id);
  end if;
 --
  CHK_POS_BUDGET_VAL(X_Position_Id,X_Date_From,X_Organization_Id,X_Number_Of_Openings,X_Vacancy_Id);
  UPDATE PER_VACANCIES
  SET
    vacancy_id                                =    X_Vacancy_Id,
    business_group_id                         =    X_Business_Group_Id,
    position_id                               =    X_Position_Id,
    job_id                                    =    X_Job_Id,
    grade_id                                  =    X_Grade_Id,
    organization_id                           =    X_Organization_Id,
    requisition_id                            =    X_Requisition_Id,
    people_group_id                           =    X_People_Group_Id,
    location_id                               =    X_Location_Id,
    recruiter_id                              =    X_Recruiter_Id,
    date_from                                 =    X_Date_From,
    name                                      =    X_Name,
    comments                                  =    X_Comments,
    date_to                                   =    X_Date_To,
    description                               =    X_Description,
    vacancy_category                          =    X_Vacancy_category,
    number_of_openings                        =    X_Number_Of_Openings,
    status                                    =    X_Status,
    budget_measurement_type                   =    X_Budget_Measurement_Type,
    budget_measurement_value                  =    X_Budget_Measurement_Value,
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

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'per_vacancies_pkb.update_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;


-- Cascade changes to applicants

-- Details are only cascaded to the applicant assignments when the value
-- is not null, except for position, which updates the value if the
-- organization and job have changed regardless of whether it is null.
--

-- Start changes for bug 8518955
update per_all_assignments_f asg
set    asg.organization_id = nvl(x_organization_id, asg.organization_id)
      ,asg.job_id          = x_job_id
      ,asg.grade_id        = x_grade_id
      ,asg.people_group_id = x_people_group_id
      ,asg.location_id     = x_location_id
      ,asg.recruiter_id    = x_recruiter_id
      ,asg.position_id     = x_position_id
      /*,asg.job_id          = nvl(x_job_id, asg.job_id)
      ,asg.grade_id        = nvl(x_grade_id, asg.grade_id)
      ,asg.people_group_id = nvl(x_people_group_id, asg.people_group_id)
      ,asg.location_id     = nvl(x_location_id, asg.location_id)
      ,asg.recruiter_id    = nvl(x_recruiter_id, asg.recruiter_id)
      ,asg.position_id     = decode
                          (x_organization_id||'.'||x_job_id,
                           g_recinfo.organization_id||'.'||g_recinfo.job_id,
                           nvl(x_position_id, asg.position_id),
                           x_position_id)*/
where  asg.assignment_type = 'A'
and exists ( select 1
      	     from per_all_assignments_f  f2
	     where asg.assignment_id = f2.assignment_id
 	     and f2.effective_end_date = l_end_of_time  )
and not exists ( select 1
      		 from per_all_assignments_f  f2
		 where asg.assignment_id = f2.assignment_id
		 and f2.assignment_status_type_id in (  select assignment_status_type_id
                                             		from per_assignment_status_types
                                                	where per_system_status in ('ACCEPTED')))

and    asg.vacancy_id = x_vacancy_id
and (  asg.organization_id          <> nvl(x_organization_id,
                                           asg.organization_id)
    or nvl(asg.job_id, -1)          <> nvl(x_job_id, -1)
    or nvl(asg.grade_id, -1)        <> nvl(x_grade_id,-1)
    or nvl(asg.people_group_id, -1) <> nvl(x_people_group_id,-1)
    or nvl(asg.position_id, -1)     <> nvl(x_position_id,-1)
    or nvl(asg.location_id, -1)     <> nvl(x_location_id, -1)
    or nvl(asg.recruiter_id, -1)    <> nvl(x_recruiter_id,-1)
    );

-- End changes for bug 8518955
--
  per_applicant_pkg.update_group ( x_people_group_id,
                                   x_people_group_name ) ;
--
END Update_Row;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Delete_Row                                                            --
-- Purpose                                                                 --
--   Table handler procedure that supports the delete of a VACANCY via     --
--   the Define Requistion and Vacancy form.                               --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2 , x_vacancy_id in number ) IS
BEGIN
  check_references( x_vacancy_id ) ;
  DELETE FROM PER_VACANCIES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

-- start changes for bug 6497289
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   end_date_iRec_RA                                                      --
-- Purpose                                                                 --
--   End-Date the i-Rec Site Recruitment Activity                          --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE end_date_irec_RA(P_vacancy_id        IN  NUMBER,
                          P_vac_date_from      IN  DATE,
                          P_vac_date_to        IN  DATE)   IS

l_object_version_number	number;
l_return_status		varchar2(20);

--
CURSOR c_get_irec_site_RA is
 select pra.recruitment_activity_id, pra.object_version_number
 from per_recruitment_activities pra, per_recruitment_activity_for praf
 where pra.recruitment_activity_id = praf.recruitment_activity_id
 and praf.vacancy_id = P_vacancy_id
 and pra.posting_content_id is not NULL
 and pra.recruiting_site_id is not NULL
 AND nvl(pra.date_end,to_date('31/12/4712','dd/mm/yyyy')) > p_vac_date_to;
--

begin

 hr_utility.set_location('Entering: end_date_irec_RA',10);

 hr_utility.set_location(' P_vacancy_id:'||P_vacancy_id,11);
 hr_utility.set_location(' P_vac_date_from:'||P_vac_date_from,12);
 hr_utility.set_location(' P_vac_date_to:'||P_vac_date_to,13);

 FOR Irec_site_RA IN c_get_irec_site_RA
 LOOP
  --
  hr_utility.set_location(' i-recruitment_activity_id:'||Irec_site_RA.recruitment_activity_id,15);

  l_object_version_number := Irec_site_RA.object_version_number;

  per_recruitment_activity_swi.update_recruitment_activity
  (p_recruitment_activity_id  => Irec_site_RA.recruitment_activity_id
   ,p_date_end                => P_vac_date_to
   ,p_object_version_number   => l_object_version_number
   ,p_return_status           => l_return_status
  );

  hr_utility.set_location(' l_return_status:'||l_return_status,16);
  --
 END loop;

 hr_utility.set_location('Leaving: end_date_irec_RA',100);

END end_date_irec_RA;
--

--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   end_date_per_RA                                                       --
-- Purpose                                                                 --
--   End-Date the PER Recruitment Activity                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE end_date_PER_RA(P_vacancy_id               IN NUMBER,
                          P_recruitment_activity_id  IN NUMBER,
                          P_vac_date_from            IN DATE,
                          P_vac_date_to              IN DATE)   IS

l_object_version_number	  NUMBER ;
l_recruitment_activity_id NUMBER ;
l_return_status		      VARCHAR2(20);

--
CURSOR c_per_vac_RA IS
 SELECT pra.recruitment_activity_id,pra.object_version_number
 FROM per_recruitment_activities pra, per_recruitment_activity_for praf
 WHERE pra.recruitment_activity_id = praf.recruitment_activity_id
 AND praf.vacancy_id = P_vacancy_id
 AND pra.recruitment_activity_id = P_recruitment_activity_id
 AND pra.posting_content_id is null
 AND pra.recruiting_site_id is null;
--

BEGIN

 hr_utility.set_location('Entering: end_date_per_RA',10);

 hr_utility.set_location(' P_vacancy_id: '||P_vacancy_id,11);
 hr_utility.set_location(' P_recruitment_activity_id: '||P_recruitment_activity_id,12);
 hr_utility.set_location(' P_vac_date_from: '||P_vac_date_from,13);
 hr_utility.set_location(' P_vac_date_to: '||P_vac_date_to,14);

 OPEN c_per_vac_RA;
 FETCH c_per_vac_RA INTO l_recruitment_activity_id, l_object_version_number;

 IF c_per_vac_RA%FOUND THEN
   CLOSE c_per_vac_RA;
   per_recruitment_activity_swi.update_recruitment_activity
	  (p_recruitment_activity_id  => l_recruitment_activity_id
	  ,p_date_end                 => P_vac_date_to
	  ,p_object_version_number    => l_object_version_number
	  ,p_return_status            => l_return_status
	  );
	hr_utility.set_location(' l_return_status: '||l_return_status,15);
 ELSE
   CLOSE c_per_vac_RA;
 END if;

 --
 hr_utility.set_location('Leaving: end_date_per_RA',100);

END end_date_per_RA;
--end changes for bug 6497289
-- Begin - Changes for ER#8530112

function GET_POS_HC_BUDGET_VAL(p_position_id in number default null,
															  p_effective_date in date) return number is

--
		 l_calendar varchar2(200);
	   l_budget_id number;
	   l_budget_unit1_id number;
	   l_budget_unit2_id number;
	   l_budget_unit3_id number;
	   l_unit1_name varchar2(200);
	   l_unit2_name varchar2(200);
	   l_unit3_name varchar2(200);
	   l_budgeted_hc number;
	   l_business_group_id number;

--get the business_group_id
	cursor c_bus_grp_id(p_position_id number) is
	select business_group_id
	from hr_all_positions_f
	where position_id = p_position_id;

--get the budget_id and budget_unit_id
	cursor c_budget_id(p_business_group_id number) is
		select budget_id, budget_unit1_id, budget_unit2_id, budget_unit3_id ,period_set_name
	  from pqh_budgets
	  where position_control_flag = 'Y'
	  and budgeted_entity_cd = 'POSITION'
	  and business_group_id = l_business_group_id
	  and p_effective_date between budget_start_date and budget_end_date
	  and (
	  hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'HEAD'
	  or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'HEAD'
	  or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'HEAD'
		);

--get the system type based on budget_nuit_id
	cursor c1(p_unit_id number) is
		select system_type_cd from
		per_shared_types where shared_type_id = p_unit_id;

--get the budget_detail_id
	cursor c2(p_budget_id number) is
		select bdt.budget_detail_id
		from  pqh_budget_details bdt,pqh_budget_versions bvr
		where bvr.budget_id = p_budget_id
		and p_effective_date between bvr.date_from and nvl(bvr.date_to,p_effective_date)
		and bdt.budget_version_id = bvr.budget_version_id
		and bdt.position_id = p_position_id;

--get the budget_unit_values
	cursor c3(p_budget_detail_id number) is
		select bpr.budget_unit1_value, bpr.budget_unit2_value, bpr.budget_unit3_value
		from pqh_budget_periods bpr, per_time_periods tp_s,
		per_time_periods tp_e
		where bpr.budget_detail_id = p_budget_detail_id
		and tp_s.time_period_id = bpr.start_time_period_id
		and tp_e.time_period_id = bpr.end_time_period_id
		and tp_s.period_set_name = l_calendar
		and tp_e.period_set_name = l_calendar
		and p_effective_date between tp_s.start_date and tp_e.end_date;

BEGIN
	BEGIN
		OPEN c_bus_grp_id(p_position_id);
    FETCH c_bus_grp_id into l_business_group_id;
    CLOSE c_bus_grp_id;

		hr_utility.set_location('l_business_group_id:' || l_business_group_id, 550);


		FOR l_budget_details_rec in c_budget_id(l_business_group_id)
		LOOP
			l_budget_id := l_budget_details_rec.budget_id;
			l_budget_unit1_id := l_budget_details_rec.budget_unit1_id;
			l_budget_unit2_id := l_budget_details_rec.budget_unit2_id;
			l_budget_unit3_id := l_budget_details_rec.budget_unit3_id;
			l_calendar := l_budget_details_rec.period_set_name;
		END LOOP;

    hr_utility.set_location('l_budget_id:' || l_budget_id, 600);
    hr_utility.set_location('l_calendar:' || l_calendar, 600);
    hr_utility.set_location('l_budget_unit1_id:' || l_budget_unit1_id, 600);
    hr_utility.set_location('l_budget_unit2_id:' || l_budget_unit2_id, 600);
    hr_utility.set_location('l_budget_unit3_id:' || l_budget_unit3_id, 600);
    OPEN c1(l_budget_unit1_id);
    FETCH c1 into l_unit1_name;
    CLOSE c1;
    OPEN c1(l_budget_unit2_id);
    FETCH c1 into l_unit2_name;
    CLOSE c1;
    OPEN c1(l_budget_unit3_id);
    FETCH c1 into l_unit3_name;
    CLOSE c1;
    hr_utility.set_location('l_unit1_name:' || l_unit1_name, 601);
    hr_utility.set_location('l_unit2_name:' || l_unit2_name, 601);
    hr_utility.set_location('l_unit3_name:' || l_unit3_name, 601);
	  EXCEPTION
	    WHEN others THEN
	      hr_utility.set_location('Error: ' || SQLERRM, 602);
	      RETURN l_budgeted_hc;
	 END;
	hr_utility.set_location('l_budget_id:' || l_budget_id, 602);
	for i in c2(l_budget_id) loop
	-- row corresponding to the position is picked up
		hr_utility.set_location('budget_detail_id:' || i.budget_detail_id, 603);
	  --
	  for j in c3(i.budget_detail_id) loop
	  	hr_utility.set_location('budget_unit1_value:' || j.budget_unit1_value, 604);
	    if l_unit1_name ='HEAD' then
	    	l_budgeted_hc := nvl(l_budgeted_hc,0) + nvl(j.budget_unit1_value,0);
	    elsif l_unit2_name ='HEAD' then
	      l_budgeted_hc := nvl(l_budgeted_hc,0) + nvl(j.budget_unit2_value,0);
	    elsif l_unit3_name ='HEAD' then
	      l_budgeted_hc := nvl(l_budgeted_hc,0) + nvl(j.budget_unit3_value,0);
	    end if;
	  end loop;
	end loop;
	hr_utility.set_location('l_budgeted_hc:' || l_budgeted_hc, 605);
	return l_budgeted_hc;
end;

function GET_ASGND_HC_BUDGET_VAL(p_position_id in number default null,
																 p_effective_date in date) return number is
  l_assignment_hc number;
	CURSOR c_budgeted_hc(p_position_id number) is
	select sum(nvl(value,1))
	from per_assignment_budget_values_f abv, per_all_assignments_f asn,
	per_assignment_status_types ast
	where abv.assignment_id(+) = asn.assignment_id
	and p_effective_date between asn.effective_start_date and asn.effective_end_date
	and p_effective_date between abv.effective_start_date and abv.effective_end_date
	and asn.position_id = p_position_id
	and asn.assignment_type in ('E', 'C')
	and abv.unit(+) = 'HEAD'
	and asn.assignment_status_type_id = ast.assignment_status_type_id
	and ast.per_system_status <> 'TERM_ASSIGN';
	--
	begin
	  if p_position_id is not null then
	     open c_budgeted_hc(p_position_id);
	     fetch c_budgeted_hc into l_assignment_hc;
	     close c_budgeted_hc;
	   else
	     l_assignment_hc := 0;
	   end if;
hr_utility.set_location ('l_assignment_hc GET_ASGND_HC_BUDGET_VAL '||l_assignment_hc,1);
	   return(nvl(l_assignment_hc,0));
end;

function GET_NUM_OF_VAC(p_position_id in number,
												p_effective_date in date,
 												p_vacancy_id in number) return number IS

  CURSOR csr_get_sum_of_open is
  	Select sum(number_of_openings) from
  	Per_vacancies
  	WHERE position_id = p_position_id
    and vacancy_id  <> p_vacancy_id
  	AND p_effective_date BETWEEN date_from AND
  	 nvl(date_to,to_date('31/12/4712','DD/MM/YYYY'))
		AND status in ('FILL','APPROVED','CLOSED')
  	GROUP BY position_id;

  l_no_of_vacancy number;
  Begin
	  OPEN  csr_get_sum_of_open;
  	FETCH csr_get_sum_of_open into l_no_of_vacancy;
	  CLOSE csr_get_sum_of_open;
  	RETURN (nvl(l_no_of_vacancy,0));
END;

procedure CHK_POS_BUDGET_VAL(p_position_id in number,
														 p_effective_date in date,
														 p_org_id in number,
														 p_number_of_openings in number,
														 p_vacancy_id in number) IS
  l_pos_bud_fte number;
  l_pos_bud_hc number;
  l_pos_asg_fte number;
  l_pos_asg_hc number;
  l_pos_vac_opn number;
  Begin

  hr_utility.set_location ('coming CHK_POS_BUDGET_VAL',1);

  hr_utility.set_location ('p_position_id CHK_POS_BUDGET_VAL'||p_position_id,1);
  hr_utility.set_location ('p_vacancy_id CHK_POS_BUDGET_VAL'||p_vacancy_id,1);
  hr_utility.set_location ('p_effective_date CHK_POS_BUDGET_VAL'||p_effective_date,1);

  l_pos_bud_hc := GET_POS_HC_BUDGET_VAL(p_position_id,p_effective_date);
  hr_utility.set_location ('l_pos_bud_hc CHK_POS_BUDGET_VAL'||l_pos_bud_hc,1);

  l_pos_asg_hc  := GET_ASGND_HC_BUDGET_VAL(p_position_id,p_effective_date);
  hr_utility.set_location ('l_pos_asg_hc CHK_POS_BUDGET_VAL'||l_pos_asg_hc,1);

  l_pos_vac_opn := GET_NUM_OF_VAC(p_position_id,p_effective_date,p_vacancy_id);
  hr_utility.set_location ('l_pos_vac_opn CHK_POS_BUDGET_VAL'||l_pos_vac_opn,1);

  hr_utility.set_location ('p_number_of_openings CHK_POS_BUDGET_VAL'||p_number_of_openings,1);

  If  ((l_pos_asg_hc  + l_pos_vac_opn + p_number_of_openings)  > L_pos_bud_hc) then
    hr_utility.set_location ('p_number_of_openings CHK_POS_BUDGET_VAL'||p_number_of_openings,1);
  	pqh_utility.set_message(8302,'PQH_SUM_POS_BGT_HC', p_org_id);
  	pqh_utility.raise_error;
  End If;

End;
-- End - Changes for ER#8530112

END PER_VACANCIES_PKG;

/
