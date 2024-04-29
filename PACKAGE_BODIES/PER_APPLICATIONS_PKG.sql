--------------------------------------------------------
--  DDL for Package Body PER_APPLICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APPLICATIONS_PKG" as
/* $Header: peapp01t.pkb 120.0.12010000.4 2009/04/23 05:54:04 skura ship $ */
/* =========================================================================
    Name
      per_applications_pkg
    Purpose
      Supports the Termination Details Block (APL) in the form
          PERWSTAP - Terminate Applicant.
  ==========================================================================
*/
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_prev_ass_type_id                                                  --
-- Purpose                                                                 --
--  to populate a field in the F4 form PERWSTAP, needed for the procedure  --
--  del_letter_term when terminating an applicant.                         --
-- Arguments
--  see below
-- Notes                                                                   --
-----------------------------------------------------------------------------
FUNCTION get_prev_ass_type_id(P_Business_Group_id   NUMBER,
                              p_person_id           NUMBER,
                              p_application_id      NUMBER,
                              p_date_end            DATE) return NUMBER  IS

    CURSOR c_get_ass_type IS
          SELECT a.assignment_status_type_id
          FROM   per_assignments_f a
          WHERE  a.person_id         = p_person_id
          AND    A.business_group_id + 0 = p_business_group_id
          AND    A.APPLICATION_ID    = p_application_id
          AND    p_date_end    between A.EFFECTIVE_START_DATE
                               and     A.EFFECTIVE_END_DATE;                  --
--
v_prev_asg_status_id    NUMBER(15);
--
   BEGIN
--
      OPEN c_get_ass_type;
      FETCH c_get_ass_type INTO v_prev_asg_status_id;
      CLOSE c_get_ass_type;
      RETURN v_prev_asg_status_id;
--
   END get_prev_ass_type_id;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- PRIVATE PROCEDURE
-- Name
-- term-update_ass_bud_val
-- Purpose
-- Required due to the date tracking of the assignment budget values table.
-- To delete all assignment budget values where they start after the assignment termination
-- end date.
-- Also for the row where the termination date is between the start and end dates,the assignment budget value's effective
-- end date will need to be changed to reflect the change of the assignment's effective end date.
-- Arguments
-- see below
--
-- Notes
-- Although this could have been included within the Hr_Assignments package due to the deletion of the
-- assignment being made within this package it was felt that this proc should also be included in here.
--
-- SASmith 17-APR-1998
-------------------------------------------------------------------------------------------------------
PROCEDURE term_update_ass_bud_val(p_application_id     NUMBER
                                 ,p_person_id          NUMBER
                                 ,p_business_group_id  NUMBER
                                 ,p_date_end           DATE
                                 ,p_last_updated_by    NUMBER
                                 ,p_last_update_login  NUMBER)  IS

--
p_del_flag     VARCHAR2(1)  := 'N';

--
 -- Look at all assignments for the application to be terminated.
 -- Check for and delete any assignment budget value rows where they start after the termination
 -- end date.
 --
  --
  -- Start of fix for WWBUG 1408379
  --
  cursor c1 is
    select abv1.*
    from   PER_ALL_ASSIGNMENTS_F paa,
           per_assignment_budget_values_f abv1
    where  paa.APPLICATION_ID = p_application_id
    and    paa.PERSON_ID = p_person_id
    and    paa.business_group_id = p_business_group_id
    and    paa.ASSIGNMENT_TYPE = 'A'
    and    paa.assignment_id = abv1.assignment_id
    and    p_date_end
           between abv1.effective_start_date
           and     abv1.effective_end_date;
  --
  l_c1 c1%rowtype;
  l_old ben_abv_ler.g_abv_ler_rec;
  l_new ben_abv_ler.g_abv_ler_rec;
  --
  -- End of fix for WWBUG 1408379
  --
 BEGIN
 p_del_flag := 'N';

 hr_utility.set_location('PER_APPLICATIONS_PKG.term_update_ass_bud_val',5);
 hr_utility.set_location(p_date_end,6);

 BEGIN

      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       Select null
       from PER_ALL_ASSIGNMENTS_F paa, per_assignment_budget_values_f abv
       where paa.APPLICATION_ID        = p_application_id
       and   paa.PERSON_ID             = p_person_id
       and   paa.business_group_id + 0 = p_business_group_id
       and   paa.ASSIGNMENT_TYPE      = 'A'
       and   paa.assignment_id        = abv.assignment_id
       and   abv.effective_start_date > p_date_end);


   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag = 'Y' THEN
   --
   hr_utility.set_location('PER_APPLICATIONS_PKG.term_update_ass_bud_val',10);
   --
      delete from per_assignment_budget_values_f abv
      where exists (
      Select null
       from PER_ALL_ASSIGNMENTS_F paa, per_assignment_budget_values_f abv1
       where paa.APPLICATION_ID        = p_application_id
       and   paa.PERSON_ID             = p_person_id
       and   paa.business_group_id + 0 = p_business_group_id
       and   paa.ASSIGNMENT_TYPE      = 'A'
       and   paa.assignment_id        = abv1.assignment_id
       and   abv1.assignment_id       = abv.assignment_id
       and   abv1.effective_start_date > p_date_end
       and   abv1.effective_start_date = abv.effective_start_date);


   END IF;

   p_del_flag := 'N';
   --
   hr_utility.set_location('PER_APPLICATIONS_PKG.term_update_ass_bud_val',15);
  --
  -- Check for and update any assignment budget value row(s) where the termination end date occurs during the
  -- life of the assignment budget value row(s).
  --

 BEGIN

   select 'Y'
   into   p_del_flag
   from   sys.dual
   where exists (
     Select null
       from PER_ALL_ASSIGNMENTS_F paa, per_assignment_budget_values_f abv
       where paa.APPLICATION_ID        = p_application_id
       and   paa.PERSON_ID             = p_person_id
       and   paa.business_group_id + 0 = p_business_group_id
       and   paa.ASSIGNMENT_TYPE      = 'A'
       and   paa.assignment_id        = abv.assignment_id
       and   p_date_end between abv.effective_start_date and abv.effective_end_date);


    EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;

   IF p_del_flag = 'Y' THEN
   --
     hr_utility.set_location('PER_APPLICATIONS_PKG.term_update_ass_bud_val',20);
   --
     --
     -- Start of fix for WWBUG 1408379
     --
     open c1;
       --
       loop
         --
         fetch c1 into l_c1;
         exit when c1%notfound;
         --
         update per_assignment_budget_values_f abv
         set abv.effective_end_date = p_date_end,
             abv.last_updated_by    = P_LAST_UPDATED_BY,
             abv.last_update_login  = P_LAST_UPDATE_LOGIN,
             abv.last_update_date   = sysdate
         where abv.assignment_budget_value_id=l_c1.assignment_budget_value_id
         and   abv.effective_start_date = l_c1.effective_start_date
         and   abv.effective_end_date = l_c1.effective_end_date;
         --
         l_old.assignment_id := l_c1.assignment_id;
         l_old.business_group_id := l_c1.business_group_id;
         l_old.value := l_c1.value;
         l_old.assignment_budget_value_id := l_c1.assignment_budget_value_id;
         l_old.effective_start_date := l_c1.effective_start_date;
         l_old.effective_end_date := l_c1.effective_end_date;
         l_new.assignment_id := l_c1.assignment_id;
         l_new.business_group_id := l_c1.business_group_id;
         l_new.value := l_c1.value;
         l_new.assignment_budget_value_id := l_c1.assignment_budget_value_id;
         l_new.effective_start_date := l_c1.effective_start_date;
         l_new.effective_end_date := p_date_end;
         --
         ben_abv_ler.ler_chk(p_old            => l_old,
                             p_new            => l_new,
                             p_effective_date => l_c1.effective_start_date);
         --
       end loop;
       --
     close c1;
     --
   END IF;

END term_update_ass_bud_val;

----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- PRIVATE PROCEDURE
-- Name
-- cancel_update_ass_bud
-- Purpose
-- Required due to the date tracking of the assignment budget values table.
-- To cancel the termination of the assignment budget values. The requirement is for the LAST assignment
-- budget value row's effective end date to be opened out to be the same as the assignment's
-- effective end date. This is required where the termination is being cancelled.
--
-- Arguments
-- see below
-- Notes
-- Although this could have been included within the Hr_Assignments package due to the deletion of the
-- assignment being made within this package it was felt that this proc should also be included in here.
--
--
-- SASmith 17-APR-1998
-----------------------------------------------------------------------------------------------
PROCEDURE cancel_update_ass_bud_val(p_application_id   NUMBER
                                 ,p_person_id          NUMBER
                                 ,p_business_group_id  NUMBER
                                 ,p_date_end           DATE
                                 ,p_end_of_time        DATE
                                 ,p_last_updated_by    NUMBER
                                 ,p_last_update_login  NUMBER)  IS

--
p_del_flag     VARCHAR2(1)  := 'N';

 --
  --
  -- Start of fix for WWBUG 1408379
  --
  cursor c1 is
    select abv1.*
    from   PER_ALL_ASSIGNMENTS_F paa,
           per_assignment_budget_values_f abv1
     where paa.APPLICATION_ID = p_application_id
     and   paa.PERSON_ID = p_person_id
     and   paa.business_group_id = p_business_group_id
     and   paa.ASSIGNMENT_TYPE = 'A'
     and   abv1.assignment_id = paa.assignment_id
     and   abv1.effective_end_date = p_date_end;
  --
  l_c1 c1%rowtype;
  l_old ben_abv_ler.g_abv_ler_rec;
  l_new ben_abv_ler.g_abv_ler_rec;
  --
  -- End of fix for WWBUG 1408379
  --
 BEGIN
 p_del_flag := 'N';

 hr_utility.set_location('PER_APPLICATIONS_PKG.cancel_update_ass_bud_val',5);

  --
 BEGIN

   select 'Y'
   into   p_del_flag
   from   sys.dual
   where exists (
       Select null
       from PER_ALL_ASSIGNMENTS_F paa
       where paa.APPLICATION_ID         = p_application_id
       and   paa.PERSON_ID              = p_person_id
       and   paa.business_group_id + 0  = p_business_group_id
       and   paa.ASSIGNMENT_TYPE        = 'A'
       and   exists                       (Select abv.assignment_id
                               from  per_assignment_budget_values_f abv
                                  where abv.assignment_id = paa.assignment_id
                                  and   abv.effective_end_date = p_date_end));

   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;

   IF p_del_flag = 'Y' THEN
   --
     hr_utility.set_location('PER_APPLICATIONS_PKG.cancel_update_ass_bud_val',10);
   --
     --
     -- Start of fix for WWBUG 1408379
     --
     open c1;
       --
       loop
         --
         fetch c1 into l_c1;
         exit when c1%notfound;
         --
         update per_assignment_budget_values_f abv
         set abv.effective_end_date = p_end_of_time,
             abv.last_updated_by = P_LAST_UPDATED_BY,
             abv.last_update_login = P_LAST_UPDATE_LOGIN,
             abv.last_update_date =  sysdate
         where abv.assignment_budget_value_id = l_c1.assignment_budget_value_id
         and   abv.effective_start_date = l_c1.effective_start_date
         and   abv.effective_end_date   = l_c1.effective_end_date;
         --
         l_old.assignment_id := l_c1.assignment_id;
         l_old.business_group_id := l_c1.business_group_id;
         l_old.value := l_c1.value;
         l_old.assignment_budget_value_id := l_c1.assignment_budget_value_id;
         l_old.effective_start_date := l_c1.effective_start_date;
         l_old.effective_end_date := l_c1.effective_end_date;
         l_old.assignment_id := l_c1.assignment_id;
         l_old.business_group_id := l_c1.business_group_id;
         l_old.value := l_c1.value;
         l_old.assignment_budget_value_id := l_c1.assignment_budget_value_id;
         l_old.effective_start_date := l_c1.effective_start_date;
         l_old.effective_end_date := p_end_of_time;
         --
         ben_abv_ler.ler_chk(p_old            => l_old,
                             p_new            => l_new,
                             p_effective_date => l_c1.effective_start_date);
         --
       end loop;
       --
     close c1;
     --
   END IF;

END cancel_update_ass_bud_val;


-------------------------------------------------------------------------------


--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   del_letter_term                                                       --
-- Purpose                                                                 --
--   on termination of an applicant's application delete any letter request--
--   lines for the applicant's assignments if they exist for assigment status-
--   types other than TERM_APL.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--  NB. The applicant status TERM_APL is never held on the applicant's     --
-- assignment record.
-----------------------------------------------------------------------------
PROCEDURE del_letter_term(p_person_id           NUMBER,
                          p_business_group_id   NUMBER,
                          p_date_end            DATE,
                          p_application_id      NUMBER,
                          P_dummy_asg_stat_id   NUMBER) IS

    CURSOR c_letter_stat_exists IS
       SELECT  1
       FROM    PER_LETTER_GEN_STATUSES PLG
       WHERE   PLG.business_group_id + 0         = p_business_group_id
       AND     PLG.ASSIGNMENT_STATUS_TYPE_ID = P_dummy_asg_stat_id
       AND     PLG.ENABLED_FLAG              = 'Y';

   CURSOR c_chk_lines IS
       SELECT distinct(1)
       FROM   per_letter_request_lines l
       WHERE  L.person_id                  = p_person_id
       AND    l.business_group_id + 0          = p_business_group_id
       AND    l.assignment_status_type_id  = P_dummy_asg_stat_id
       AND EXISTS
              (SELECT NULL
               FROM   per_assignments_f A
               WHERE  a.business_group_id + 0        = p_business_group_id
               AND    a.person_id                = p_person_id
               AND    a.assignment_status_type_id = P_dummy_asg_stat_id
               AND    a.assignment_type           = 'A'
               AND    a.application_id            = p_application_id
               AND    a.assignment_id             = l.assignment_id);

   CURSOR c_chk_empty_requests IS
         SELECT 1
         FROM   per_letter_requests r
         WHERE  NOT EXISTS
         (SELECT NULL
         FROM   per_letter_request_lines L
         WHERE  r.letter_request_id = l.letter_request_id);


----
v_stat_exists                NUMBER(1);
v_lines_exist                NUMBER(1);
v_empty_requests             NUMBER(1);
-----

BEGIN
--
     OPEN c_letter_stat_exists;
     FETCH c_letter_stat_exists INTO v_stat_exists;
     IF c_letter_stat_exists%FOUND THEN
           CLOSE c_letter_stat_exists;
--
            OPEN c_chk_lines;
            FETCH c_chk_lines INTO v_lines_exist;
            IF c_chk_lines%FOUND THEN
                CLOSE c_chk_lines;
                DELETE FROM PER_LETTER_REQUEST_LINES l
                 WHERE  l.person_id                 = p_person_id
                 AND    l.assignment_status_type_id = P_dummy_asg_stat_id
                 AND    l.business_group_id + 0         = p_business_group_id;
--
                OPEN c_chk_empty_requests;
                FETCH c_chk_empty_requests INTO v_empty_requests;
                IF c_chk_empty_requests%FOUND THEN
                      CLOSE c_chk_empty_requests;
--
                      DELETE FROM per_letter_requests R
                      WHERE  r.business_group_id   = p_business_group_id
                      AND    r.request_status      = 'PENDING'
                      AND    r.auto_or_manual      = 'AUTO'
                      AND    NOT EXISTS
                            (SELECT null
                            FROM Per_letter_request_lines l
                            WHERE l.letter_request_id  = r.letter_request_id
                            AND   l.business_group_id + 0  = p_business_group_id);
--
                ELSE CLOSE c_chk_empty_requests;
                END IF;
           ELSE CLOSE c_chk_lines;
           END IF;
       ELSE CLOSE c_letter_stat_exists;
       END IF;
--
END del_letter_term;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   insert_letter_term                                                    --
-- Purpose                                                                 --
--   to insert letter request if needs be and to insert letter request lines-
--   when the user specifies a termination status(otional) when doing an   --
--   applicant termination.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE insert_letter_term(P_business_group_id   NUMBER,
                             p_application_id      NUMBER,
                             p_person_id           NUMBER,
                             p_session_date        DATE,
                             p_last_updated_by     NUMBER,
                             p_last_update_login   NUMBER,
                             p_assignment_status_type_id NUMBER ) IS

    CURSOR ck_gen_stats IS
    SELECT  1
    FROM    per_letter_gen_statuses s
    WHERE   S.business_group_id + 0         = P_business_group_id
    AND     s.assignment_status_type_id = p_assignment_status_type_id
    AND     s.enabled_flag              = 'Y';


    CURSOR csr_let_req IS
     SELECT R.LETTER_REQUEST_ID,
            r.letter_type_id
     FROM   PER_LETTER_REQUESTS R,
            PER_LETTER_GEN_STATUSES s
     WHERE  r.business_group_id + 0         = p_business_group_id
     AND    s.business_group_id + 0         = p_business_group_id
     AND    r.LETTER_TYPE_ID            = S.LETTER_TYPE_ID
     AND    s.ASSIGNMENT_STATUS_TYPE_ID = p_assignment_status_type_id
     AND    s.ENABLED_FLAG              = 'Y'
     AND    R.REQUEST_STATUS            = 'PENDING'
     AND    R.AUTO_OR_MANUAL            = 'AUTO';

   CURSOR test_new_req IS
    SELECT 1
    FROM   per_letter_gen_statuses s
    WHERE  S.business_group_id + 0         = P_business_group_id
    AND    s.assignment_status_type_id = p_assignment_status_type_id
    AND    s.enabled_flag                 = 'Y'
    AND    NOT EXISTS
           (SELECT NULL
            FROM per_letter_requests r
            WHERE  r.letter_type_id    = S.letter_type_id
            AND    R.business_group_id + 0 = P_business_group_id
            AND    r.request_status    = 'PENDING'
            AND    r.auto_or_manual    = 'AUTO');

   CURSOR csr_letter_type IS
         SELECT  distinct(s.letter_type_id)
         FROM    per_letter_gen_statuses s
         WHERE   s.business_group_id + 0        = p_business_group_id
         AND     s.assignment_status_type_id    = p_assignment_status_type_id
         AND     s.enabled_flag                 = 'Y'
         AND     s.letter_type_id NOT IN (SELECT distinct(r.letter_type_id)
                                          FROM   per_letter_requests r
                                          WHERE  r.business_group_id + 0
                                                  = p_business_group_id
                                          and    r.REQUEST_STATUS
                                                  = 'PENDING'
                                          and    r.AUTO_OR_MANUAL
                                                  = 'AUTO');

    CURSOR csr_assign IS
            SELECT ASSIGNMENT_ID
            FROM   PER_ASSIGNMENTS_f
            WHERE  business_group_id + 0     = p_business_group_id
            AND    PERSON_ID             = p_person_id
            AND    APPLICATION_ID        = p_application_id
            AND    ASSIGNMENT_TYPE       = 'A'
            and    effective_start_date <= p_session_date
            and    effective_end_date   > p_session_date;

--
-- Cursor added for bug 3680947.
--
CURSOR csr_check_manual_or_auto IS
SELECT 1
FROM  PER_LETTER_REQUESTS PLR,
      PER_LETTER_GEN_STATUSES PLGS
WHERE PLGS.business_group_id + 0 = p_business_group_id
AND   PLR.business_group_id +0 = p_business_group_id
AND   PLGS.assignment_status_type_id = p_assignment_status_type_id
AND   PLR.letter_type_id = PLGS.letter_type_id
AND   PLR.auto_or_manual = 'MANUAL';
--
--
v_dummy_asg_id      NUMBER(1);
v_letter_request_id NUMBER(15);
v_test_new_req      NUMBER(1);
v_letter_type       NUMBER(15);
v_assignment_id    per_assignments_f.assignment_id%TYPE;
l_dummy_number    number; -- Added for bug 3680947.

--

BEGIN
     --
     -- Fix for bug 3680947 starts here.
     --
     open csr_check_manual_or_auto;
     fetch csr_check_manual_or_auto into l_dummy_number;
     if csr_check_manual_or_auto%found then
       close csr_check_manual_or_auto;
       return;
     end if;
     close csr_check_manual_or_auto;
     --
     -- Fix for bug 3680947 ends here.
     --
     OPEN ck_gen_stats;
     FETCH ck_gen_stats INTO v_dummy_asg_id;
     IF ck_gen_stats%FOUND THEN
        CLOSE ck_gen_stats;
        OPEN csr_let_req;
        LOOP
        FETCH csr_let_req into v_letter_request_id,v_letter_type;
        EXIT when csr_let_req%NOTFOUND;
        INSERT INTO PER_LETTER_REQUEST_LINES
          (
                  LETTER_REQUEST_LINE_ID
          ,       BUSINESS_GROUP_ID
          ,       LETTER_REQUEST_ID
          ,       PERSON_ID
          ,       ASSIGNMENT_ID
          ,       ASSIGNMENT_STATUS_TYPE_ID
          ,       DATE_FROM
          ,       LAST_UPDATE_DATE
          ,       LAST_UPDATED_BY
          ,       LAST_UPDATE_LOGIN
          ,       CREATED_BY
          ,       CREATION_DATE)
          select
                  PER_LETTER_REQUEST_LINES_S.nextval
          ,       p_business_group_id
          ,       v_letter_request_id
          ,       p_person_id
          ,       a.ASSIGNMENT_ID
          ,       p_assignment_status_type_id
          ,       p_session_date
          ,       trunc(SYSDATE)
          ,       p_last_updated_by
          ,       p_last_update_login
          ,       p_last_updated_by
          ,       trunc(SYSDATE)
          FROM    PER_LETTER_REQUESTS r
          ,       PER_LETTER_GEN_STATUSES s
          ,       PER_ASSIGNMENTS     a
          WHERE   R.LETTER_TYPE_ID                = S.LETTER_TYPE_ID
          AND     R.LETTER_TYPE_ID                = v_letter_type
          AND     R.letter_request_id             = v_letter_request_id -- Added for bug3680947.
          AND     R.REQUEST_STATUS                = 'PENDING'
          AND     S.ASSIGNMENT_STATUS_TYPE_ID     = p_assignment_status_type_id
          AND     S.business_group_id + 0             = R.business_group_id + 0
          AND     S.BUSINESS_GROUP_ID + 0         = p_business_group_id
          AND     s.ENABLED_FLAG                  = 'Y'
          AND     a.BUSINESS_GROUP_ID + 0          = p_business_group_id
          AND     a.PERSON_ID                      = p_person_id
          AND     a.APPLICATION_ID                 = p_application_id
          and     not exists
                          (select null
                           from   PER_LETTER_REQUEST_LINES l
                           where  l.PERSON_ID                = p_person_id
                           AND    A.PERSON_ID                = p_person_id
                           and    l.ASSIGNMENT_ID            = a.ASSIGNMENT_ID
                           and    l.ASSIGNMENT_STATUS_TYPE_ID =
                             p_assignment_status_type_id
                 and    l.LETTER_REQUEST_ID = v_letter_request_id
                 and    l.business_group_id + 0 = p_business_group_id
                 and    l.business_group_id + 0 = A.business_group_id + 0
                 and    l.business_group_id + 0 = p_business_group_id);
         END LOOP;
         CLOSE CSR_LET_REQ;
--

        OPEN test_new_req;
        FETCH test_new_req INTO v_test_new_req;
        IF test_new_req%FOUND THEN
           CLOSE test_new_req;
--
           OPEN csr_letter_type;
           LOOP
           FETCH csr_letter_type into v_letter_type;
           EXIT WHEN csr_letter_type%NOTFOUND;
               insert into PER_LETTER_REQUESTS(
                       LETTER_REQUEST_ID
               ,       BUSINESS_GROUP_ID
               ,       LETTER_TYPE_ID
               ,       DATE_FROM
               ,       REQUEST_STATUS
               ,       AUTO_OR_MANUAL
               ,       LAST_UPDATE_DATE
               ,       LAST_UPDATED_BY
               ,       LAST_UPDATE_LOGIN
               ,       CREATED_BY
               ,       CREATION_DATE)
               select  PER_LETTER_REQUESTS_S.nextval
               ,       P_Business_group_id
               ,       v_letter_type
               ,       P_session_date
               ,       'PENDING'
               ,       'AUTO'
               ,       trunc(SYSDATE)
               ,       p_last_updated_by
               ,       p_last_update_login
               ,       p_last_updated_by
               ,       trunc(SYSDATE)
               from sys.dual;
          END LOOP;
         CLOSE csr_letter_type;
--
         OPEN csr_assign;
         LOOP
         FETCH csr_assign INTO v_assignment_id;
         EXIT WHEN csr_assign%NOTFOUND;
         INSERT INTO PER_LETTER_REQUEST_LINES
         (
                 LETTER_REQUEST_LINE_ID
         ,       BUSINESS_GROUP_ID
         ,       LETTER_REQUEST_ID
         ,       PERSON_ID
         ,       ASSIGNMENT_ID
         ,       ASSIGNMENT_STATUS_TYPE_ID
         ,       DATE_FROM
         ,       LAST_UPDATE_DATE
         ,       LAST_UPDATED_BY
         ,       LAST_UPDATE_LOGIN
         ,       CREATED_BY
         ,       CREATION_DATE)
         select
                 PER_LETTER_REQUEST_LINES_S.nextval
         ,       P_Business_group_id
         ,       r.LETTER_REQUEST_ID
         ,       P_person_id
         ,       v_assignment_id
         ,       p_assignment_status_type_id
         ,       p_session_date
         ,      trunc(SYSDATE)
         ,       p_last_updated_by
         ,       p_last_update_login
         ,       p_last_updated_by
         ,       trunc(SYSDATE)
         FROM    PER_LETTER_REQUESTS R
         ,       PER_LETTER_GEN_STATUSES s
         WHERE   R.LETTER_TYPE_ID                = S.LETTER_TYPE_ID
         AND     p_assignment_status_type_id     = S.ASSIGNMENT_STATUS_TYPE_ID
         AND     S.business_group_id + 0             = R.business_group_id + 0
         AND     S.BUSINESS_GROUP_ID + 0         = P_Business_group_id
         AND     R.REQUEST_STATUS                = 'PENDING'
         AND     R.AUTO_OR_MANUAL                = 'AUTO'
         AND     r.DATE_FROM                     = p_session_date
         AND     s.ENABLED_FLAG                  = 'Y'
         AND     NOT EXISTS
                 (SELECT NULL
                 FROM   per_letter_request_lines L
                 WHERE  L.person_id                = P_person_id
                 AND    L.assignment_id            = v_assignment_id
                 AND    L.assignment_status_type_id =
                             p_assignment_status_type_id
                 AND    L.letter_request_id = r.letter_request_id
                 AND    L.business_group_id + 0 = r.business_group_id + 0
                 AND    L.business_group_id + 0 = P_Business_group_id);
          END LOOP;
          CLOSE csr_assign;
--
        ELSE CLOSE test_new_req;
        END IF;
--
     ELSE CLOSE ck_gen_stats;
     END IF;
--
END insert_letter_term;

-----------------------------------------------------------------------------
-- Name                                                                    --
--   del_letters_cancel                                                    --
-- Purpose                                                                 --
--   on cancellation of a termination ensure that any letter lines for the --
--   applicant are deleted if the status is TERM_APL for the letter.
--   Delete any rougue letter requests that have no letter lines since they
--   have just been deleted.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE del_letters_cancel(p_business_group_id NUMBER,
                             P_person_id         NUMBER,
                             p_application_id    NUMBER
                            ) IS

        CURSOR c_term_apl_stat IS
         SELECT 1
         FROM   per_letter_gen_statuses s
         ,      per_assignment_status_types a
         WHERE  s.business_group_id + 0         = p_business_group_id
         AND    a.assignment_status_type_id = s.assignment_status_type_id
         AND    a.per_system_status         = 'TERM_APL'
         AND    s.enabled_flag              = 'Y';

        CURSOR c_chk_lines IS
         SELECT distinct(1)
         FROM   per_letter_request_lines L
         ,      per_assignments_f       a
         WHERE  l.person_id               = P_person_id
         AND    l.business_group_id + 0       = p_business_group_id
         AND    l.assignment_id           = a.assignment_id
         AND    a.person_id               = P_person_id
         AND    a.business_group_id + 0       = p_business_group_id
         AND    a.assignment_type         = 'A'
         AND    a.application_id          = p_application_id;

       CURSOR csr_let_req_id IS
          SELECT r.letter_request_id
          FROM   PER_LETTER_REQUESTS R,
                 PER_LETTER_GEN_STATUSES s,
                 PER_ASSIGNMENT_STATUS_TYPES T
          WHERE  r.business_group_id + 0         = p_business_group_id
          AND    s.business_group_id + 0         = p_business_group_id
          AND    r.LETTER_TYPE_ID            = S.LETTER_TYPE_ID
          AND    s.ASSIGNMENT_STATUS_TYPE_ID = T.ASSIGNMENT_STATUS_TYPE_ID
          AND    T.PER_SYSTEM_STATUS         = 'TERM_APL'
          AND    s.ENABLED_FLAG              = 'Y'
          AND    R.REQUEST_STATUS            = 'PENDING'
          AND    r.auto_or_manual            = 'AUTO';

        CURSOR csr_odd_reqs IS
          SELECT R.LETTER_REQUEST_ID
          FROM   PER_LETTER_REQUESTS R,
                 PER_LETTER_GEN_STATUSES s,
                 PER_ASSIGNMENT_STATUS_TYPES T
          WHERE  r.business_group_id + 0         = p_business_group_id
          AND    s.business_group_id + 0         = p_business_group_id
          AND    r.LETTER_TYPE_ID            = S.LETTER_TYPE_ID
          AND    s.ASSIGNMENT_STATUS_TYPE_ID = T.ASSIGNMENT_STATUS_TYPE_ID
          AND    T.PER_SYSTEM_STATUS         = 'TERM_APL'
          and    s.ENABLED_FLAG              = 'Y'
          and    R.REQUEST_STATUS            = 'PENDING'
          and    R.AUTO_OR_MANUAL            = 'AUTO'
          and not exists
             (select null
              from  PER_LETTER_REQUEST_LINES l
              where l.LETTER_REQUEST_ID      = R.LETTER_REQUEST_ID
              and   l.business_group_id + 0      = r.business_group_id + 0
              and   l.business_group_id + 0      = p_business_group_id);

------
v_c_term_apl_stat    NUMBER(1);
v_c_lines            NUMBER(1);
v_letter_request_id csr_let_req_id%rowtype;
v_csr_odd_reqs      csr_odd_reqs%rowtype;
----

  BEGIN
       OPEN c_term_apl_stat;
       FETCH c_term_apl_stat INTO v_c_term_apl_stat;
        IF c_term_apl_stat%FOUND THEN
           CLOSE c_term_apl_stat;
           OPEN c_chk_lines;
           FETCH c_chk_lines INTO v_c_lines;
           IF c_chk_lines%FOUND THEN
              CLOSE c_chk_lines;
              OPEN csr_let_req_id;
              FETCH csr_let_req_id INTO v_letter_request_id;
              IF csr_let_req_id%FOUND THEN
                   CLOSE csr_let_req_id;
                   FOR csr_let_req_id_rec IN csr_let_req_id LOOP
--
                   DELETE FROM per_letter_request_lines lrL
                   WHERE  lrl.business_group_id + 0 = p_business_group_id
                   AND    lrl.letter_request_id =
                                  csr_let_req_id_REC.letter_request_id
                   AND    lrl.person_id         = P_person_id
                   AND    lrl.person_id         = P_person_id
                   AND EXISTS
                    (SELECT NULL
                     FROM   per_assignments_f a
                     WHERE  a.assignment_id      = lrl.assignment_id
                     AND    a.person_id          = P_person_id
                     AND    a.application_id     = p_application_id
                     AND    a.business_group_id + 0  = P_business_group_id);
--
                     END LOOP;
                   OPEN csr_odd_reqs;
                   FETCH csr_odd_reqs INTO v_csr_odd_reqs;
                   IF csr_odd_reqs%FOUND THEN
                      CLOSE csr_odd_reqs;
--
                      FOR csr_odd_reqs_rec IN csr_odd_reqs LOOP
                      DELETE FROM per_letter_requests R
                      WHERE  r.letter_request_id =
                                             csr_odd_reqs_REC.letter_request_id
                      AND    r.business_group_id + 0  = p_business_group_id;
                      END LOOP;
                  ELSE CLOSE csr_odd_reqs;
                  END IF;
--
             ELSE CLOSE csr_let_req_id;
             END IF;
--
         ELSE CLOSE c_chk_lines;
         END IF;
--
       ELSE CLOSE c_term_apl_stat;
       END IF;
--
  END del_letters_cancel;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   cancel_chk_current_emp                                                --
-- Purpose                                                                 --
--   to ensure that if the applicant has been hired as an employee that the -
--   user cannot canel a termination of the applicant's application
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--  called from the client PERWSTAP pre-cancellation
-----------------------------------------------------------------------------
PROCEDURE cancel_chk_current_emp(p_person_id         NUMBER,
                                 p_business_group_id NUMBER,
                                 p_date_end 	     DATE)   IS

--
-- Bug 3380724 Starts Here
-- Description : The cursor is modified so that the cursor is checking whether the
--               application is terminated by the user or by the system while hiring
--               him into the Job.
   CURSOR c_hired_emp IS
    SELECT 1
      FROM   per_all_people_f pap
      WHERE  pap.person_id             = p_person_id
      AND    pap.applicant_number IS NOT NULL
      and    EXISTS(SELECT 1   -- If hired app table has appl with end date and SUCCESSFUL_FLAG = 'Y'
             from per_applications app
             where app.person_id        = p_person_id
             AND   app.business_group_id +  0 = p_business_group_id
             and app.DATE_END = p_date_end
             and nvl(app.SUCCESSFUL_FLAG,'N') = 'Y'
      )
      AND    pap.effective_start_date = p_date_end + 1 -- If hired pap table has emp record with date_end+1
      AND    EXISTS
             (SELECT 1
              FROM  per_person_types PP
              WHERE pp.person_type_id        = pap.person_type_id
              AND   PP.business_group_id + 0 = p_business_group_id
              AND   pp.active_flag           ='Y'
              AND   pp.system_person_type IN ('EMP'));
--
-- Bug 3380724 Ends Here
--
-- VT 05/21/96 #364623 added NOT EXISTS criteria to CURSOR above
-----
v_dummy_hired_emp    NUMBER(1);
-----

  BEGIN
      OPEN c_hired_emp;
      FETCH c_hired_emp INTO v_dummy_hired_emp;
      IF c_hired_emp%FOUND THEN
         CLOSE c_hired_emp;
         hr_utility.set_message(800,'PER_7594_APP_TERM_EMP_HIRE');
         hr_utility.raise_error;
      ELSE CLOSE c_hired_emp;
      END IF;
  END cancel_chk_current_emp;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   cancel_update_assigns                                                 --
-- Purpose                                                                 --
--   on cancelling a termination open the applicant assignments to the end of
--   time.
--   If the applicant was entered through the Quick Entry screen with a    --
--   status of TERM_APL i.e just for recording purposes then the applicant --
--   assignment must be re-opened with the status of ACTIVE_APL.           --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE cancel_update_assigns(p_person_id         NUMBER,
                                p_business_group_id NUMBER,
                                P_date_end          DATE,
                                P_application_id    NUMBER,
                                p_legislation_code  VARCHAR2,
                                P_end_of_time       DATE,
                                P_last_updated_by   NUMBER,
                                p_last_update_login NUMBER) IS

     CURSOR c_chk_prv_status IS
       select 1
        from    per_assignment_status_types t
        ,       per_assignments_f          asg
        where   asg.person_id                   = p_person_id
        and     nvl(t.business_group_id,
                 p_business_group_id)           = p_business_group_id
        and     t.PER_SYSTEM_STATUS             = 'TERM_APL'
        and     asg.effective_start_date       <= P_date_end
        and     asg.effective_end_date         >= P_date_end
        and     asg.business_group_id + 0           = p_business_group_id
        and     asg.application_id              = P_application_id
        and     t.assignment_status_type_id     = asg.assignment_status_type_id;

--
    CURSOR get_actve_apl IS
      SELECT  a.assignment_status_type_id
      FROM    per_assignment_status_types a
      ,       per_ass_status_type_amends b
      WHERE   a.per_system_status                 = 'ACTIVE_APL'
      AND     b.assignment_status_type_id(+)      = a.assignment_status_type_id
      AND     b.business_group_id(+) + 0          = p_business_group_id
      AND     nvl(a.business_group_id, p_business_group_id) =
              p_business_group_id
      AND     nvl(a.legislation_codE,
                        p_legislation_code)       = p_legislation_code
      AND     NVL(B.ACTIVE_FLAG,A.ACTIVE_FLAG)    = 'Y'
      and     nvl(B.DEFAULT_FLAG, A.DEFAULT_FLAG) = 'Y';
--
v_dummy_ast          NUMBER(1);
v_act_ass_stat_id    NUMBER(15);
--

BEGIN
      OPEN c_chk_prv_status;
      FETCH c_chk_prv_status INTO v_dummy_ast;
      IF c_chk_prv_status%FOUND THEN
         CLOSE c_chk_prv_status;
         OPEN get_actve_apl;
         FETCH get_actve_apl INTO v_act_ass_stat_id;
         CLOSE get_actve_apl;
         UPDATE  PER_ALL_ASSIGNMENTS_F A
         SET     A.LAST_UPDATE_DATE          = trunc(sysdate)
         ,       A.LAST_UPDATED_BY           = P_last_updated_by
         ,       A.LAST_UPDATE_LOGIN         = p_last_update_login
         ,       A.EFFECTIVE_END_DATE        = P_end_of_time
         ,       A.ASSIGNMENT_STATUS_TYPE_ID = v_act_ass_stat_id
         WHERE   A.APPLICATION_ID            = P_application_id
         AND     A.PERSON_ID                 = p_person_id
         AND     A.business_group_id + 0         = p_business_group_id
         AND     A.ASSIGNMENT_TYPE           = 'A'
         AND     A.EFFECTIVE_END_DATE        = P_date_end;


        -- call to new proc required due to date tracking assignment budget values. To cancel termination
        -- of the assignment budget values.
        --SASmith 17-APR-1998
        cancel_update_ass_bud_val(p_application_id
                                 ,p_person_id
                                 ,p_business_group_id
                                 ,p_date_end
                                 ,p_end_of_time
                                 ,p_last_updated_by
                                 ,p_last_update_login);
--
    ELSE CLOSE c_chk_prv_status;
--
         UPDATE  PER_ALL_ASSIGNMENTS_F A
          SET     A.LAST_UPDATE_DATE   = trunc(sysdate)
          ,       A.LAST_UPDATED_BY    = P_last_updated_by
          ,       A.LAST_UPDATE_LOGIN  = p_last_update_login
          ,       A.EFFECTIVE_END_DATE = P_end_of_time
          WHERE   A.APPLICATION_ID     = P_application_id
          AND     A.PERSON_ID          = p_person_id
          AND     A.business_group_id + 0  = p_business_group_id
          AND     A.ASSIGNMENT_TYPE    = 'A'
          AND     A.EFFECTIVE_END_DATE = P_date_end;

        -- call to new proc required due to date tracking assignment budget values. To cancel termination
        -- of the assignment budget values.
        --SASmith 17-APR-1998
        cancel_update_ass_bud_val(p_application_id
                                 ,p_person_id
                                 ,p_business_group_id
                                 ,p_date_end
                                 ,p_end_of_time
                                 ,p_last_updated_by
                                 ,p_last_update_login);
    END IF;
END cancel_update_assigns;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   term_update_assignments                                               --
-- Purpose                                                                 --
--   when terminating an applicant close down all the applicant assignments
--   as of the termination date.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE term_update_assignments(p_person_id         NUMBER,
                                  p_business_group_id NUMBER,
                                  P_date_end          DATE,
                                  P_application_id    NUMBER,
                                  p_last_updated_by   NUMBER,
                                  p_last_update_login NUMBER) IS

--     CURSOR c_chk_assigns IS
--      SELECT 1
--      FROM    per_all_assignments_f a
--      WHERE   a.application_id    = P_application_id
--      AND     a.person_id         = p_person_id
--      AND     a.business_group_id + 0 = p_business_group_id
--      AND     a.assignment_type   = 'A'
--      AND     a.effective_start_date > P_date_end;
--
--dummy_assign    NUMBER(1);
--
    cursor csr_get_future_assignments is
      select assignment_id, object_version_number, effective_start_date
        from per_all_assignments_f a
     WHERE   a.application_id        = P_application_id
       AND   a.person_id             = p_person_id
       AND   a.business_group_id     = p_business_group_id
       AND   a.assignment_type       = 'A'
       AND   a.effective_start_date > P_date_end
       AND    not exists
      (select 'Y'
        from per_all_assignments_f paf2
         where paf2.assignment_id = a.assignment_id
           and paf2.effective_start_date < a.EFFECTIVE_START_DATE);
    --
    l_validation_start_date        DATE;
    l_validation_end_date          DATE;
    l_effective_start_date         DATE;
    l_effective_end_date           DATE;
    l_business_group_id            hr_all_organization_units.organization_id%TYPE;
    l_org_now_no_manager_warning   BOOLEAN;
--
BEGIN
    -- Delete all future assignments
    FOR l_assignment in csr_get_future_assignments LOOP
        per_asg_del.del
          (p_assignment_id                => l_assignment.assignment_id
          ,p_object_version_number        => l_assignment.object_version_number
          ,p_effective_date               => l_assignment.effective_start_date --p_date_end+1
          ,p_datetrack_mode               => hr_api.g_zap
          ,p_effective_start_date         => l_effective_start_date
          ,p_effective_end_date           => l_effective_end_date
          ,p_business_group_id            => l_business_group_id
          ,p_validation_start_date        => l_validation_start_date
          ,p_validation_end_date          => l_validation_end_date
          ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
          );
    END LOOP;
    -- Delete DT updates
    DELETE per_all_assignments_f a
     WHERE   a.application_id        = P_application_id
       AND   a.person_id             = p_person_id
       AND   a.business_group_id     = p_business_group_id
       AND   a.assignment_type       = 'A'
       AND   a.effective_start_date > P_date_end;

    -- Terminate assignments

     UPDATE  per_all_assignments_f paa
     SET     paa.last_update_date   = trunc(sysdate),
             paa.last_updated_by    = p_last_updated_by,
             paa.last_update_login  = p_last_update_login,
             paa.EFFECTIVE_END_DATE = P_date_end
     where   paa.APPLICATION_ID     = P_application_id
     and     paa.PERSON_ID          = p_person_id
     and     paa.business_group_id + 0  = p_business_group_id
     and     paa.ASSIGNMENT_TYPE    = 'A'
     and     paa.EFFECTIVE_END_DATE =
             (select max(pa2.EFFECTIVE_END_DATE)
              from PER_ALL_ASSIGNMENTS_F pa2
              where pa2.PERSON_ID          = p_person_id
              and   pa2.assignment_id      = paa.assignment_id -- 3957964 >>
              and   pa2.effective_end_date > p_date_end        -- <<
              and   pa2.APPLICATION_ID     = P_application_id);

    -- call to new proc due to date tracking of assignment budget values. This will terminate the
    -- assignment budget values related to the assignment being terminated.
    --SASmith 17-APR-1998

    term_update_ass_bud_val(p_application_id
                            ,p_person_id
                            ,p_business_group_id
                            ,p_date_end
                            ,p_last_updated_by
                            ,p_last_update_login);
    --
END term_update_assignments;
--
--
--
PROCEDURE canc_chk_fut_per_changes(p_person_id      NUMBER,
                                   p_application_id NUMBER,
                                   p_date_end       DATE     ) is
--
cursor c1 is
   SELECT 1
   FROM   PER_ALL_PEOPLE_F PAPF
   WHERE  PAPF.PERSON_ID = P_PERSON_ID
   AND    PAPF.EFFECTIVE_START_DATE > P_DATE_END + 1 ;
--
l_dummy number  ;
BEGIN
--
  open c1 ;
  fetch c1 into l_dummy ;
  if c1%found then
     close c1 ;
     hr_utility.set_message(801,'HR_6385_APP_TERM_FUT_CHANGES' );
     hr_utility.raise_error ;
  end if;
  close c1 ;
end canc_chk_fut_per_changes ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Name                                                                    --
--   term_chk_per_assign_changes                                           --
-- Purpose                                                                 --
--   check that the applicant has no future person record changes after the
--   apparent termination date since this would prohibit a termination.    --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE term_chk_fut_per_changes(p_person_id         NUMBER,
                                      p_business_group_id NUMBER,
                                      P_date_end          DATE) IS
          CURSOR c_per_changes IS
            SELECT 1
            FROM   per_all_people_f papf
            WHERE  papf.person_id            = p_person_id
            AND    papf.effective_start_date > P_date_end
            AND    papf.business_group_id + 0    = p_business_group_id;
------
v_dummy_number    NUMBER(1);
---
BEGIN
        OPEN c_per_changes;
        FETCH c_per_changes INTO v_dummy_number;
        IF c_per_changes%FOUND THEN
           CLOSE c_per_changes;
           hr_utility.set_message(800,'HR_6382_APP_TERM_FUTURE_PPT');
           hr_utility.set_message_token('DATE',P_date_end);
           hr_utility.raise_error;
        ELSE CLOSE c_per_changes;
        END IF;
--
END term_chk_fut_per_changes;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   term_chk_fut_assign_changes                                           --
-- Purpose                                                                 --
--   if future assignment changes of any sort exist for the person, then   --
--   the user cannot terminate the application.                            --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE term_chk_fut_assign_changes(p_person_id         NUMBER,
                                      p_business_group_id NUMBER,
                                      P_date_end          DATE) IS
      CURSOR c_assign_changes IS
        SELECT 1
        FROM   PER_ALL_ASSIGNMENTS_F PAAF
        WHERE  PAAF.PERSON_ID            = p_person_id
        AND    PAAF.business_group_id + 0    = p_business_group_id
        AND    PAAF.EFFECTIVE_START_DATE > P_date_end;
------
v_number    NUMBER(1);
---
BEGIN
     OPEN c_assign_changes;
     FETCH c_assign_changes INTO v_number;
     IF c_assign_changes%FOUND THEN
        CLOSE c_assign_changes;
        hr_utility.set_message(800,'HR_6583_APP_TERM_FUT_ASS');
        hr_utility.set_message_token('DATE',P_date_end);
        hr_utility.raise_error;
    ELSE CLOSE c_assign_changes;
    END IF;
--
END term_chk_fut_assign_changes;

-----------------------------------------------------------------------------
-- Name                                                                    --
--   maint_security_cancel                                                 --
-- Purpose                                                                 --
--   Stubbed as part of the ex-person security enhancements.               --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE maint_security_cancel(p_person_id        NUMBER) IS

--
BEGIN
  --
  NULL;
  --
END maint_security_cancel;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   maint_security_term                                                   --
-- Purpose                                                                 --
--   Stubbed as part of the ex-person security enhancements.               --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE maint_security_term(p_person_id        NUMBER) IS

BEGIN
  --
  NULL;
  --
END maint_security_term;


-----------------------------------------------------------------------------
-- Name                                                                    --
--   sec_statuses_cancel                                                   --
-- Purpose                                                                 --
--   to nuliify any secondary assignment statuses end dates on the applicant's
--   assignments if they are currently the same as the termination date when
--   the applicant was terminated.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE sec_statuses_cancel(p_end_date          DATE,
                           p_application_id     NUMBER,
                           p_business_group_id  NUMBER,
                           p_last_updated_by    NUMBER,
                           p_last_update_login  NUMBER,
                           p_person_id          NUMBER)    IS

        CURSOR c_sec_stat_cancel IS
           select sa.assignment_id
           from   per_secondary_ass_statuses sa
           where  sa.business_group_id + 0 = p_business_group_id
           and    sa.end_date              = p_end_date
           and    exists
              ( SELECT s.assignment_id
                    FROM PER_SECONDARY_ASS_STATUSES s
                    where  s.business_group_id + 0  = p_business_group_id
                    and    s.end_date           = p_end_date
                    and    sa.assignment_id     = s.assignment_id
                    and exists
             (select null
                from   per_assignments_f paf
                where  paf.person_id          = p_person_id
                and    paf.application_id     = p_application_id
                and    paf.assignment_type    = 'A'
                and    paf.effective_end_date = p_end_date
                and    paf.assignment_id      = s.assignment_id));
--
v_assignment_id   NUMBER(15);
--

 BEGIN
         OPEN c_sec_stat_cancel;
         LOOP
         FETCH c_sec_stat_cancel into v_assignment_id;
         EXIT WHEN c_sec_stat_cancel%NOTFOUND;
             UPDATE per_secondary_ass_statuses s
             SET   s.END_DATE           = NULL
             ,     s.LAST_UPDATE_DATE   = trunc(SYSDATE)
             ,     s.LAST_UPDATED_BY    = p_last_updated_by
             ,     s.LAST_UPDATE_LOGIN  = p_last_update_login
             WHERE  s.assignment_id     = v_assignment_id
             AND   s.business_group_id + 0  = p_business_group_id
             AND   s.END_DATE           = p_end_date;
         END LOOP;
         CLOSE c_sec_stat_cancel;
--
END sec_statuses_cancel;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   sec_statuses_term                                                     --
-- Purpose                                                                 --
--   to delete any future sec.statuses when terminating an applicant. Puts an
--   end date as of the applicant's termination date for any secondary
--   applicant assignment statuses that start before the termination date
--   and which don't have end dates before the termination end date.       --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
procedure sec_statuses_term(p_end_date           date
                           ,p_application_id     number
                           ,p_business_group_id  number
                           ,p_last_updated_by    number
                           ,p_last_update_login  number
                           ,p_person_id          number) is
  -- WWbug 633263
  -- Modified cursor for performance improvements by removing the full table
  -- scan on per_secondary_ass_statuses.
  -- This was achieved by removing the sub-query
  cursor chk_sec_stat is
    select  1
    from    per_secondary_ass_statuses s
           ,per_assignments_f          a
    where   s.business_group_id + 0    = p_business_group_id
    and     s.start_date is not null
    and     a.business_group_id + 0    = p_business_group_id
    and     a.person_id                = p_person_id
    and     s.assignment_id            = a.assignment_id
    and     a.application_id           = p_application_id
    and     a.assignment_type          = 'A'
    and     p_end_date
    between a.effective_start_date
    and     a.effective_end_date;
  -- WWbug 633263
  -- Modified cursor for performance improvements by removing the full table
  -- scan on per_secondary_ass_statuses.
  -- This was achieved by removing the sub-query
  cursor c_sec_stat is
    select  sa.assignment_id
    from    per_secondary_ass_statuses sa
           ,per_assignments_f          paf
    where   sa.business_group_id + 0 = p_business_group_id
    and     sa.start_date           <= p_end_date
    and     (sa.end_date is null
    or       sa.end_date             > p_end_date)
    and     sa.assignment_id       = paf.assignment_id
    and     paf.person_id          = p_person_id
    and     paf.application_id     = p_application_id
    and     paf.assignment_type    = 'A'
    and     p_end_date
    between paf.effective_start_date
    and     paf.effective_end_date;
--
  v_dummy    number(1);
--
begin
  open chk_sec_stat;
  fetch chk_sec_stat into v_dummy;
  if chk_sec_stat%found then
     close chk_sec_stat;
     -- WWbug 633263
     -- Modified cursor for performance improvements by removing the full table
     -- scan on per_secondary_ass_statuses.
     -- This was achieved by replacing the EXISTS sub-query with an IN sub-query
     delete from per_secondary_ass_statuses s
     where  s.business_group_id + 0   = p_business_group_id
     and    trunc(s.start_date)       > p_end_date
     and    s.assignment_id in
           (select  a.assignment_id
            from    per_assignments_f a
            where   a.business_group_id + 0 = p_business_group_id
            and     a.person_id         = p_person_id
            and     a.application_id    = p_application_id
            and     a.assignment_type   = 'A'
            and     p_end_date
            between a.effective_start_date
            and     a.effective_end_date);
     -- WWbug 633263
     -- Cleared up the previous code with a cursor for loop
     for csr_rec in c_sec_stat loop
       update per_secondary_ass_statuses s
       set    s.end_date             = p_end_date
       ,      s.last_update_date     = trunc(sysdate)
       ,      s.last_updated_by      = p_last_updated_by
       ,      s.last_update_login    = p_last_update_login
       where  s.assignment_id         = csr_rec.assignment_id
       and    s.business_group_id + 0 = p_business_group_id
       and    s.start_date           <= p_end_date
       and    (s.end_date is null
       or     s.end_date > p_end_date);
     end loop;
     --
  else
    -- WWbug 633263
    -- Closed the cursor which was previously not closed
    close chk_sec_stat;
  end if;
end sec_statuses_term;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   del_interviews_term                                                   --
-- Purpose                                                                 --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE del_interviews_term(P_person_id               NUMBER,
                              P_date_end                DATE,
                              P_Business_group_id       NUMBER,
                              P_application_id          NUMBER)  IS
        CURSOR chk_events IS
            SELECT E.EVENT_ID
            FROM  PER_EVENTS   E
            ,     PER_ASSIGNMENTS_F A
            WHERE A.PERSON_ID         = P_person_id
            AND   E.business_group_id + 0 = p_business_group_id
            AND   A.business_group_id + 0 = p_business_group_id
            AND   A.APPLICATION_ID    = P_application_id
            AND   E.ASSIGNMENT_ID      = A.ASSIGNMENT_ID
            AND   E.DATE_START        >= P_date_end
            AND   E.EVENT_OR_INTERVIEW = 'I';


    CURSOR chk_bookings IS
            SELECT distinct(1)
             FROM  PER_BOOKINGS B
             ,     PER_EVENTS   E
             ,     PER_ASSIGNMENTS_F A
             WHERE A.PERSON_ID         = P_person_id
             AND   A.APPLICATION_ID    = P_application_id
             AND   B.EVENT_ID          = E.EVENT_ID
             AND   E.DATE_START        >= P_date_end
             AND   E.EVENT_OR_INTERVIEW = 'I'
             AND   E.ASSIGNMENT_ID      = A.ASSIGNMENT_ID;
--
-- the person_id on per_bookings is the employee who is doing the
-- interviewing of the applicant and is NOT the applicant.
--

        CURSOR c_viewers IS
             select B.PERSON_ID,B.BOOKING_ID
             from   PER_BOOKINGS B
             ,      PER_EVENTS   E
             ,      PER_ASSIGNMENTS A
             where  B.business_group_id + 0 = p_business_group_id
              and   E.business_group_id + 0 = p_business_group_id
              and   A.business_group_id + 0 = p_business_group_id
              and   A.PERSON_ID         = p_person_id
              and   A.APPLICATION_ID    = p_application_id
              and   B.EVENT_ID          = E.EVENT_ID
              and   E.DATE_START        >= P_date_end
              and   E.EVENT_OR_INTERVIEW = 'I'
              and   E.ASSIGNMENT_ID      = A.ASSIGNMENT_ID;

V_dummy_events chk_events%rowtype;
v_dummy_bookings  NUMBER(1);
r_interviewers c_viewers%rowtype;
l_event_found     BOOLEAN;

  BEGIN
      OPEN chk_events;
      FETCH chk_events into V_dummy_events;
--
      l_event_found := chk_events%found;
       IF l_event_found THEN
         CLOSE chk_events;
         OPEN chk_bookings;
         FETCH chk_bookings into v_dummy_bookings;
--
            IF chk_bookings%found THEN
               CLOSE chk_bookings;
               OPEN c_viewers;
               FETCH c_viewers into r_interviewers;
               CLOSE c_viewers;
                 FOR c_viewers_rec IN c_viewers LOOP
                 DELETE FROM per_bookings bk
                 WHERE   bk.business_group_id + 0 = p_business_group_id
                 AND     bk.booking_id        = c_viewers_rec.BOOKING_ID
                 AND     bk.person_id         = c_viewers_rec.PERSON_ID;
                 END LOOP;

                  FOR chk_events_rec IN chk_events LOOP
                  DELETE FROM per_events ev
                  WHERE  ev.event_id          = chk_events_rec.event_id
                  AND    ev.business_group_id + 0 = p_business_group_id;
                  END LOOP;
--
               ELSE CLOSE chk_bookings;
                     FOR chk_events_rec IN chk_events LOOP
                     DELETE FROM per_events ev
                     WHERE  ev.event_id          = chk_events_rec.event_id
                     AND    ev.business_group_id + 0 = p_business_group_id;
                     END LOOP;

--
            END IF;
      END IF;
  END del_interviews_term;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   maintain_ppt_cancel                                                   --
-- Purpose                                                                 --
--   When cancelling an already terminated application this procedure ensures
--   that the last record is deleted from the person table i.e the one that
--   has a person_type_id of TERM_APL so that the person reverts back to an
--   APL and secondly it opens out the now new last record by putting an
--   effective_end_date on PER_PEOPLE_F as of the end_of_time.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE maintain_ppt_cancel(P_person_id       NUMBER,
                      P_Business_group_id   NUMBER,
                              P_date_end                DATE,
                              P_last_updated_by         NUMBER,
                              P_last_update_login       NUMBER,
                              P_end_of_time             DATE)  IS
--
  BEGIN
    DELETE FROM per_all_people_f papf
    WHERE       papf.person_id               = P_person_id
    AND         papf.business_group_id + 0   = P_Business_group_id
    AND         papf.effective_start_date    = P_date_end + 1;
--
     UPDATE  per_all_people_f papf
     SET     papf.effective_end_date  = P_end_of_time
     ,       papf.last_updated_by     = P_last_updated_by
     ,       papf.last_update_date    = trunc(sysdate)
     ,       papf.last_update_login   = P_last_update_login
     WHERE   papf.person_id           = P_person_id
     AND     papf.BUSINESS_GROUP_ID + 0  = P_Business_group_id
     AND     papf.effective_end_date  = P_date_end;
--
  END maintain_ppt_cancel;
----------------------------------------------------------------------------
-- Name                                                                    --
--   chk_not_already_termed                                                --
-- Purpose                                                                 --
--   To ensure that the user cannot terminate an application which has already
--   been terminated.
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
-----------------------------------------------------------------------------
PROCEDURE chk_not_already_termed(P_Business_group_id         NUMBER,
                                 P_person_id                 NUMBER,
                                 P_application_id            NUMBER,
                                 P_date_end                  DATE)  IS
--

        CURSOR c_chk_already_term IS
          SELECT 1
          FROM  PER_APPLICATIONS PA
          WHERE PA.business_group_id + 0 = P_Business_group_id
          AND   PA.PERSON_ID         = P_person_id
          AND   PA.APPLICATION_ID    = P_application_id
          AND   PA.DATE_END IS NOT NULL;
         -- AND   PA.DATE_END          = P_date_end; /* Fix for bug 8433186 */

V_dummy_1    NUMBER(1);
--
BEGIN

  OPEN c_chk_already_term;
  FETCH c_chk_already_term into V_dummy_1;
  IF c_chk_already_term%found THEN
     CLOSE c_chk_already_term;
     hr_utility.set_message(800,'HR_7105_APPL_ALREADY_TERMED');
     hr_utility.raise_error;
  ELSE
    CLOSE c_chk_already_term;
  END IF;
END chk_not_already_termed;
-----------------------------------------------------------------------------
-- Name                                                                    --
--   maintain_ppt_term                                                     --
-- Purpose                                                                 --
--   This procedure maintains the person's record when going from an       --
--   applicant to an ex-applicant.                                         --
--   In particular this maintiains the person_type_id on per_all_people_f  --
--   by closing down the record in per_all_people_f as of the end date of  --
--   the person's application and inserting a row with the new person_type_id
--   on the next day.                                                      --
-- Arguments                                                               --
--   See below.                                                            --
-- Notes                                                                   --
--                                                                         --
-------------------------------------------------------------------------------
PROCEDURE maintain_ppt_term(P_Business_group_id         NUMBER,
                            P_person_id                 NUMBER,
                            P_date_end                  DATE,
                            P_end_of_time               DATE,
                            P_last_updated_by           NUMBER,
                            P_last_update_login         NUMBER) IS
--
BEGIN
      UPDATE  per_all_people_f papf
      set     PAPF.effective_end_date = P_date_end
      ,       PAPF.last_updated_by    = P_last_updated_by
      ,       PAPF.last_update_date   = trunc(sysdate)
      ,       PAPF.last_update_login  = P_last_update_login
      where   PAPF.person_id          = P_person_id
      and     P_date_end BETWEEN
              PAPF.effective_start_date AND PAPF.effective_end_date
      and     PAPF.business_group_id + 0  = P_Business_group_id;
--

     INSERT INTO per_all_people_f
       (PERSON_ID ,EFFECTIVE_START_DATE ,EFFECTIVE_END_DATE
       ,BUSINESS_GROUP_ID ,PERSON_TYPE_ID ,LAST_NAME
       ,START_DATE ,APPLICANT_NUMBER
       ,COMMENT_ID
       ,CURRENT_APPLICANT_FLAG
       ,CURRENT_EMP_OR_APL_FLAG
       ,CURRENT_EMPLOYEE_FLAG
       ,CURRENT_NPW_FLAG
       ,DATE_EMPLOYEE_DATA_VERIFIED
       ,DATE_OF_BIRTH ,EMAIL_ADDRESS
       ,EMPLOYEE_NUMBER ,EXPENSE_CHECK_SEND_TO_ADDRESS
       ,FIRST_NAME ,FULL_NAME
       ,KNOWN_AS ,MARITAL_STATUS ,MIDDLE_NAMES
       ,NATIONALITY ,NATIONAL_IDENTIFIER ,PREVIOUS_LAST_NAME
       ,REGISTERED_DISABLED_FLAG ,SEX ,TITLE
       ,VENDOR_ID ,WORK_TELEPHONE ,REQUEST_ID
       ,PROGRAM_APPLICATION_ID ,PROGRAM_ID
       ,PROGRAM_UPDATE_DATE ,ATTRIBUTE_CATEGORY
       ,ATTRIBUTE1 ,ATTRIBUTE2 ,ATTRIBUTE3 ,ATTRIBUTE4 ,ATTRIBUTE5
       ,ATTRIBUTE6 ,ATTRIBUTE7 ,ATTRIBUTE8 ,ATTRIBUTE9 ,ATTRIBUTE10
       ,ATTRIBUTE11 ,ATTRIBUTE12 ,ATTRIBUTE13 ,ATTRIBUTE14
       ,ATTRIBUTE15 ,ATTRIBUTE16 ,ATTRIBUTE17 ,ATTRIBUTE18 ,ATTRIBUTE19
       ,ATTRIBUTE20 , ATTRIBUTE21 ,ATTRIBUTE22 ,ATTRIBUTE23 ,ATTRIBUTE24
       ,ATTRIBUTE25 ,ATTRIBUTE26 ,ATTRIBUTE27 ,ATTRIBUTE28 ,ATTRIBUTE29
       ,ATTRIBUTE30 , LAST_UPDATE_DATE ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN ,CREATED_BY ,CREATION_DATE
       ,PER_INFORMATION_CATEGORY
       ,PER_INFORMATION1
       ,PER_INFORMATION2
       ,PER_INFORMATION3
       ,PER_INFORMATION4
       ,PER_INFORMATION5
       ,PER_INFORMATION6
       ,PER_INFORMATION7
       ,PER_INFORMATION8
       ,PER_INFORMATION9
       ,PER_INFORMATION10
       ,PER_INFORMATION11
       ,PER_INFORMATION12
       ,PER_INFORMATION13
       ,PER_INFORMATION14
       ,PER_INFORMATION15
       ,PER_INFORMATION16
       ,PER_INFORMATION17
       ,PER_INFORMATION18
       ,PER_INFORMATION19
       ,PER_INFORMATION20
       ,PER_INFORMATION21
       ,PER_INFORMATION22
       ,PER_INFORMATION23
       ,PER_INFORMATION24
       ,PER_INFORMATION25
       ,PER_INFORMATION26
       ,PER_INFORMATION27
       ,PER_INFORMATION28
       ,PER_INFORMATION29
       ,PER_INFORMATION30
       ,BACKGROUND_CHECK_STATUS
       ,BACKGROUND_DATE_CHECK
       ,BLOOD_TYPE
       ,CORRESPONDENCE_LANGUAGE
       ,FAST_PATH_EMPLOYEE
       ,FTE_CAPACITY
       ,HOLD_APPLICANT_DATE_UNTIL
       ,HONORS
       ,INTERNAL_LOCATION
       ,LAST_MEDICAL_TEST_BY
       ,LAST_MEDICAL_TEST_DATE
       ,MAILSTOP
       ,OFFICE_NUMBER
       ,ON_MILITARY_SERVICE
       ,ORDER_NAME
       ,PRE_NAME_ADJUNCT
       ,PROJECTED_START_DATE
       ,REHIRE_AUTHORIZOR
       ,REHIRE_REASON
       ,REHIRE_RECOMMENDATION
       ,RESUME_EXISTS
       ,RESUME_LAST_UPDATED
       ,SECOND_PASSPORT_EXISTS
       ,STUDENT_STATUS
       ,SUFFIX
       ,WORK_SCHEDULE
     ,town_of_birth
     ,region_of_birth
     ,country_of_birth
     ,global_person_id
     ,party_id
        ,original_date_of_hire

        --Bug2974671 starts here.

        ,BENEFIT_GROUP_ID
        ,COORD_BEN_MED_PLN_NO
        ,COORD_BEN_NO_CVG_FLAG
        ,DPDNT_ADOPTION_DATE
        ,DPDNT_VLNTRY_SVCE_FLAG
        ,USES_TOBACCO_FLAG

        -- Bug2974671 ends here.
        ,NPW_NUMBER -- Added for Fix for #3184546
        )
  select PAPF.PERSON_ID
      ,PAPF.EFFECTIVE_END_DATE+1
      ,P_end_of_time
      ,PAPF.BUSINESS_GROUP_ID ,PPT.PERSON_TYPE_ID
      ,PAPF.LAST_NAME ,PAPF.START_DATE
      ,PAPF.APPLICANT_NUMBER ,PAPF.COMMENT_ID
      ,null
      ,PAPF.CURRENT_EMPLOYEE_FLAG
      ,PAPF.CURRENT_EMPLOYEE_FLAG
      ,PAPF.CURRENT_NPW_FLAG
      ,PAPF.DATE_EMPLOYEE_DATA_VERIFIED
      ,PAPF.DATE_OF_BIRTH
      ,PAPF.EMAIL_ADDRESS
      ,PAPF.EMPLOYEE_NUMBER
      ,PAPF.EXPENSE_CHECK_SEND_TO_ADDRESS
      ,PAPF.FIRST_NAME ,PAPF.FULL_NAME
      ,PAPF.KNOWN_AS ,PAPF.MARITAL_STATUS
      ,PAPF.MIDDLE_NAMES ,PAPF.NATIONALITY
      ,PAPF.NATIONAL_IDENTIFIER
      ,PAPF.PREVIOUS_LAST_NAME
      ,PAPF.REGISTERED_DISABLED_FLAG
      ,PAPF.SEX ,PAPF.TITLE ,PAPF.VENDOR_ID
      ,PAPF.WORK_TELEPHONE ,PAPF.REQUEST_ID
      ,PAPF.PROGRAM_APPLICATION_ID
      ,PAPF.PROGRAM_ID
      ,PAPF.PROGRAM_UPDATE_DATE
      ,PAPF.ATTRIBUTE_CATEGORY
      ,PAPF.ATTRIBUTE1 ,PAPF.ATTRIBUTE2
      ,PAPF.ATTRIBUTE3 ,PAPF.ATTRIBUTE4
      ,PAPF.ATTRIBUTE5 ,PAPF.ATTRIBUTE6
      ,PAPF.ATTRIBUTE7 ,PAPF.ATTRIBUTE8
      ,PAPF.ATTRIBUTE9 ,PAPF.ATTRIBUTE10
      ,PAPF.ATTRIBUTE11 ,PAPF.ATTRIBUTE12
      ,PAPF.ATTRIBUTE13 ,PAPF.ATTRIBUTE14
      ,PAPF.ATTRIBUTE15 ,PAPF.ATTRIBUTE16
      ,PAPF.ATTRIBUTE17 ,PAPF.ATTRIBUTE18
      ,PAPF.ATTRIBUTE19 ,PAPF.ATTRIBUTE20
      ,PAPF.ATTRIBUTE21 ,PAPF.ATTRIBUTE22
      ,PAPF.ATTRIBUTE23 ,PAPF.ATTRIBUTE24
      ,PAPF.ATTRIBUTE25 ,PAPF.ATTRIBUTE26
      ,PAPF.ATTRIBUTE27 ,PAPF.ATTRIBUTE28
      ,PAPF.ATTRIBUTE29 ,PAPF.ATTRIBUTE30
      ,PAPF.LAST_UPDATE_DATE ,PAPF.LAST_UPDATED_BY
      ,PAPF.LAST_UPDATE_LOGIN ,PAPF.CREATED_BY
      ,PAPF.CREATION_DATE
      ,PAPF.PER_INFORMATION_CATEGORY
      ,PAPF.PER_INFORMATION1
      ,PAPF.PER_INFORMATION2
      ,PAPF.PER_INFORMATION3
      ,PAPF.PER_INFORMATION4
      ,PAPF.PER_INFORMATION5
      ,PAPF.PER_INFORMATION6
      ,PAPF.PER_INFORMATION7
      ,PAPF.PER_INFORMATION8
      ,PAPF.PER_INFORMATION9
      ,PAPF.PER_INFORMATION10
      ,PAPF.PER_INFORMATION11
      ,PAPF.PER_INFORMATION12
      ,PAPF.PER_INFORMATION13
      ,PAPF.PER_INFORMATION14
      ,PAPF.PER_INFORMATION15
      ,PAPF.PER_INFORMATION16
      ,PAPF.PER_INFORMATION17
      ,PAPF.PER_INFORMATION18
      ,PAPF.PER_INFORMATION19
      ,PAPF.PER_INFORMATION20
      ,PAPF.PER_INFORMATION21
      ,PAPF.PER_INFORMATION22
      ,PAPF.PER_INFORMATION23
      ,PAPF.PER_INFORMATION24
      ,PAPF.PER_INFORMATION25
      ,PAPF.PER_INFORMATION26
      ,PAPF.PER_INFORMATION27
      ,PAPF.PER_INFORMATION28
      ,PAPF.PER_INFORMATION29
      ,PAPF.PER_INFORMATION30
      ,PAPF.BACKGROUND_CHECK_STATUS
      ,PAPF.BACKGROUND_DATE_CHECK
      ,PAPF.BLOOD_TYPE
      ,PAPF.CORRESPONDENCE_LANGUAGE
      ,PAPF.FAST_PATH_EMPLOYEE
      ,PAPF.FTE_CAPACITY
      ,PAPF.HOLD_APPLICANT_DATE_UNTIL
      ,PAPF.HONORS
      ,PAPF.INTERNAL_LOCATION
      ,PAPF.LAST_MEDICAL_TEST_BY
      ,PAPF.LAST_MEDICAL_TEST_DATE
      ,PAPF.MAILSTOP
      ,PAPF.OFFICE_NUMBER
      ,PAPF.ON_MILITARY_SERVICE
      ,PAPF.ORDER_NAME
      ,PAPF.PRE_NAME_ADJUNCT
      ,PAPF.PROJECTED_START_DATE
      ,PAPF.REHIRE_AUTHORIZOR
      ,PAPF.REHIRE_REASON
      ,PAPF.REHIRE_RECOMMENDATION
      ,PAPF.RESUME_EXISTS
      ,PAPF.RESUME_LAST_UPDATED
      ,PAPF.SECOND_PASSPORT_EXISTS
      ,PAPF.STUDENT_STATUS
      ,PAPF.SUFFIX
      ,PAPF.WORK_SCHEDULE
    ,PAPF.town_of_birth
    ,PAPF.region_of_birth
    ,PAPF.country_of_birth
    ,PAPF.global_person_id
    ,PAPF.party_id
    ,PAPF.original_date_of_hire

    -- Bug2974671 starts here.

    ,PAPF.BENEFIT_GROUP_ID
         ,PAPF.COORD_BEN_MED_PLN_NO
         ,PAPF.COORD_BEN_NO_CVG_FLAG
         ,PAPF.DPDNT_ADOPTION_DATE
         ,PAPF.DPDNT_VLNTRY_SVCE_FLAG
         ,PAPF.USES_TOBACCO_FLAG

         --Bug2974671 ends here.
         ,PAPF.NPW_NUMBER -- Added for Fix for #3184546

                 FROM per_all_people_f PAPF,
                      PER_PERSON_TYPES PPT,
                      per_person_types PPT2
                WHERE PAPF.person_id          = P_person_id
                  AND PAPF.effective_end_date = P_date_end
                  AND PPT.business_group_id   = P_business_group_id
              and PAPF.business_group_id + 0  = P_Business_group_id
                  AND PPT.default_flag        = 'Y'
                  AND PPT2.person_type_id     = PAPF.person_type_id
                  AND PPT.system_person_type =
                      decode(PPT2.system_person_type,'APL',         'EX_APL'
                                                    ,'APL_EX_APL',  'EX_APL'
                                                    ,'EMP_APL',     'EMP'
                                                    ,'EX_EMP',      'EX_APL'
                                                    ,'EX_EMP_APL',  'EX_EMP' -- Added for fix of #3311891
                                                    ,'EX_APL');

--
END maintain_ppt_term;
--
--
-- 3652025:
-- -------------------------------------------------------------------------- +
-- Name: cancel_ptu_updates
-- Description: Performs PTU updates whenever there is a reverse termination.
--
-------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                        IN OUT NOCOPY VARCHAR2,
                     p_Application_Id                      IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Person_Id                           NUMBER,
                     p_Date_Received                       DATE,
                     p_Comments                            VARCHAR2,
                     p_Current_Employer                    VARCHAR2,
                     p_Date_End                            DATE,
                     p_Projected_Hire_Date                 DATE,
                     p_Successful_Flag                     VARCHAR2,
                     p_Termination_Reason                  VARCHAR2,
                     p_Appl_Attribute_Category             VARCHAR2,
                     p_Appl_Attribute1                     VARCHAR2,
                     p_Appl_Attribute2                     VARCHAR2,
                     p_Appl_Attribute3                     VARCHAR2,
                     p_Appl_Attribute4                     VARCHAR2,
                     p_Appl_Attribute5                     VARCHAR2,
                     p_Appl_Attribute6                     VARCHAR2,
                     p_Appl_Attribute7                     VARCHAR2,
                     p_Appl_Attribute8                     VARCHAR2,
                     p_Appl_Attribute9                     VARCHAR2,
                     p_Appl_Attribute10                    VARCHAR2,
                     p_Appl_Attribute11                    VARCHAR2,
                     p_Appl_Attribute12                    VARCHAR2,
                     p_Appl_Attribute13                    VARCHAR2,
                     p_Appl_Attribute14                    VARCHAR2,
                     p_Appl_Attribute15                    VARCHAR2,
                     p_Appl_Attribute16                    VARCHAR2,
                     p_Appl_Attribute17                    VARCHAR2,
                     p_Appl_Attribute18                    VARCHAR2,
                     p_Appl_Attribute19                    VARCHAR2,
                     p_Appl_Attribute20                    VARCHAR2,
                     p_Last_Update_Date                    DATE,
                     p_Last_Updated_By                     NUMBER,
                     p_Last_Update_Login                   NUMBER,
                     p_Created_By                          NUMBER,
                     p_Creation_Date                       DATE
 ) IS
   CURSOR C IS SELECT rowid FROM PER_APPLICATIONS
             WHERE application_id = p_Application_Id;
    CURSOR C2 IS SELECT per_applications_s.nextval FROM sys.dual;
BEGIN
   if (p_Application_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO p_Application_Id;
     CLOSE C2;
   end if;
  INSERT INTO PER_APPLICATIONS(
          application_id,
          business_group_id,
          person_id,
          date_received,
          comments,
          current_employer,
          date_end,
          projected_hire_date,
          successful_flag,
          termination_reason,
          appl_attribute_category,
          appl_attribute1,
          appl_attribute2,
          appl_attribute3,
          appl_attribute4,
          appl_attribute5,
          appl_attribute6,
          appl_attribute7,
          appl_attribute8,
          appl_attribute9,
          appl_attribute10,
          appl_attribute11,
          appl_attribute12,
          appl_attribute13,
          appl_attribute14,
          appl_attribute15,
          appl_attribute16,
          appl_attribute17,
          appl_attribute18,
          appl_attribute19,
          appl_attribute20,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date
         ) VALUES (
          p_Application_Id,
          p_Business_Group_Id,
          p_Person_Id,
          p_Date_Received,
          p_Comments,
          p_Current_Employer,
          p_Date_End,
          p_Projected_Hire_Date,
          p_Successful_Flag,
          p_Termination_Reason,
          p_Appl_Attribute_Category,
          p_Appl_Attribute1,
          p_Appl_Attribute2,
          p_Appl_Attribute3,
          p_Appl_Attribute4,
          p_Appl_Attribute5,
          p_Appl_Attribute6,
          p_Appl_Attribute7,
          p_Appl_Attribute8,
          p_Appl_Attribute9,
          p_Appl_Attribute10,
          p_Appl_Attribute11,
          p_Appl_Attribute12,
          p_Appl_Attribute13,
          p_Appl_Attribute14,
          p_Appl_Attribute15,
          p_Appl_Attribute16,
          p_Appl_Attribute17,
          p_Appl_Attribute18,
          p_Appl_Attribute19,
          p_Appl_Attribute20,
          p_Last_Update_Date,
          p_Last_Updated_By,
          p_Last_Update_Login,
          p_Created_By,
          p_Creation_Date
  );

  OPEN C;
  FETCH C INTO p_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(p_Rowid                                 VARCHAR2,
                   p_Application_Id                        NUMBER,
                   p_Business_Group_Id                     NUMBER,
                   p_Person_Id                             NUMBER,
                   p_Date_Received                         DATE,
                   p_Comments                              VARCHAR2,
                   p_Current_Employer                      VARCHAR2,
                   p_Date_End                              DATE,
                   p_Projected_Hire_Date                   DATE,
                   p_Successful_Flag                       VARCHAR2,
                   p_Termination_Reason                    VARCHAR2,
                   p_Appl_Attribute_Category               VARCHAR2,
                   p_Appl_Attribute1                       VARCHAR2,
                   p_Appl_Attribute2                       VARCHAR2,
                   p_Appl_Attribute3                       VARCHAR2,
                   p_Appl_Attribute4                       VARCHAR2,
                   p_Appl_Attribute5                       VARCHAR2,
                   p_Appl_Attribute6                       VARCHAR2,
                   p_Appl_Attribute7                       VARCHAR2,
                   p_Appl_Attribute8                       VARCHAR2,
                   p_Appl_Attribute9                       VARCHAR2,
                   p_Appl_Attribute10                      VARCHAR2,
                   p_Appl_Attribute11                      VARCHAR2,
                   p_Appl_Attribute12                      VARCHAR2,
                   p_Appl_Attribute13                      VARCHAR2,
                   p_Appl_Attribute14                      VARCHAR2,
                   p_Appl_Attribute15                      VARCHAR2,
                   p_Appl_Attribute16                      VARCHAR2,
                   p_Appl_Attribute17                      VARCHAR2,
                   p_Appl_Attribute18                      VARCHAR2,
                   p_Appl_Attribute19                      VARCHAR2,
                   p_Appl_Attribute20                      VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_APPLICATIONS
      WHERE  rowid = p_Rowid
      FOR UPDATE of Application_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
--
--
Recinfo.appl_attribute4  := rtrim(Recinfo.appl_attribute4);
Recinfo.appl_attribute5  := rtrim(Recinfo.appl_attribute5);
Recinfo.appl_attribute6  := rtrim(Recinfo.appl_attribute6);
Recinfo.appl_attribute7  := rtrim(Recinfo.appl_attribute7);
Recinfo.appl_attribute8  := rtrim(Recinfo.appl_attribute8);
Recinfo.appl_attribute9  := rtrim(Recinfo.appl_attribute9);
Recinfo.appl_attribute10 := rtrim(Recinfo.appl_attribute10);
Recinfo.appl_attribute11 := rtrim(Recinfo.appl_attribute11);
Recinfo.appl_attribute12 := rtrim(Recinfo.appl_attribute12);
Recinfo.appl_attribute13 := rtrim(Recinfo.appl_attribute13);
Recinfo.appl_attribute14 := rtrim(Recinfo.appl_attribute14);
Recinfo.appl_attribute15 := rtrim(Recinfo.appl_attribute15);
Recinfo.appl_attribute16 := rtrim(Recinfo.appl_attribute16);
Recinfo.appl_attribute17 := rtrim(Recinfo.appl_attribute17);
Recinfo.appl_attribute18 := rtrim(Recinfo.appl_attribute18);
Recinfo.appl_attribute19 := rtrim(Recinfo.appl_attribute19);
Recinfo.appl_attribute20 := rtrim(Recinfo.appl_attribute20);
Recinfo.comments         := rtrim(Recinfo.comments);
Recinfo.current_employer := rtrim(Recinfo.current_employer);
Recinfo.successful_flag  := rtrim(Recinfo.successful_flag);
Recinfo.termination_reason := rtrim(Recinfo.termination_reason);
Recinfo.appl_attribute_category := rtrim(Recinfo.appl_attribute_category);
Recinfo.appl_attribute1  := rtrim(Recinfo.appl_attribute1);
Recinfo.appl_attribute3  := rtrim(Recinfo.appl_attribute3);
--
--
  if (
          (   (Recinfo.application_id = p_Application_Id)
           OR (    (Recinfo.application_id IS NULL)
               AND (p_Application_Id IS NULL)))
      AND (   (Recinfo.business_group_id = p_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (p_Business_Group_Id IS NULL)))
      AND (   (Recinfo.person_id = p_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (p_Person_Id IS NULL)))
      AND (   (Recinfo.date_received = p_Date_Received)
           OR (    (Recinfo.date_received IS NULL)
               AND (p_Date_Received IS NULL)))
      AND (   (Recinfo.comments = p_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (p_Comments IS NULL)))
      AND (   (Recinfo.current_employer = p_Current_Employer)
           OR (    (Recinfo.current_employer IS NULL)
               AND (p_Current_Employer IS NULL)))
      AND (   (Recinfo.date_end = p_Date_End)
           OR (    (Recinfo.date_end IS NULL)
               AND (p_Date_End IS NULL)))
      AND (   (Recinfo.projected_hire_date = p_Projected_Hire_Date)
           OR (    (Recinfo.projected_hire_date IS NULL)
               AND (p_Projected_Hire_Date IS NULL)))
      AND (   (Recinfo.successful_flag = p_Successful_Flag)
           OR (    (Recinfo.successful_flag IS NULL)
               AND (p_Successful_Flag IS NULL)))
      AND (   (Recinfo.termination_reason = p_Termination_Reason)
           OR (    (Recinfo.termination_reason IS NULL)
               AND (p_Termination_Reason IS NULL)))
      AND (   (Recinfo.appl_attribute_category = p_Appl_Attribute_Category)
           OR (    (Recinfo.appl_attribute_category IS NULL)
               AND (p_Appl_Attribute_Category IS NULL)))
      AND (   (Recinfo.appl_attribute1 = p_Appl_Attribute1)
           OR (    (Recinfo.appl_attribute1 IS NULL)
               AND (p_Appl_Attribute1 IS NULL)))
      AND (   (Recinfo.appl_attribute2 = p_Appl_Attribute2)
           OR (    (Recinfo.appl_attribute2 IS NULL)
               AND (p_Appl_Attribute2 IS NULL)))
      AND (   (Recinfo.appl_attribute3 = p_Appl_Attribute3)
           OR (    (Recinfo.appl_attribute3 IS NULL)
               AND (p_Appl_Attribute3 IS NULL)))
      AND (   (Recinfo.appl_attribute4 = p_Appl_Attribute4)
           OR (    (Recinfo.appl_attribute4 IS NULL)
               AND (p_Appl_Attribute4 IS NULL)))
      AND (   (Recinfo.appl_attribute5 = p_Appl_Attribute5)
           OR (    (Recinfo.appl_attribute5 IS NULL)
               AND (p_Appl_Attribute5 IS NULL)))
      AND (   (Recinfo.appl_attribute6 = p_Appl_Attribute6)
           OR (    (Recinfo.appl_attribute6 IS NULL)
               AND (p_Appl_Attribute6 IS NULL)))
      AND (   (Recinfo.appl_attribute7 = p_Appl_Attribute7)
           OR (    (Recinfo.appl_attribute7 IS NULL)
               AND (p_Appl_Attribute7 IS NULL)))
      AND (   (Recinfo.appl_attribute8 = p_Appl_Attribute8)
           OR (    (Recinfo.appl_attribute8 IS NULL)
               AND (p_Appl_Attribute8 IS NULL)))
      AND (   (Recinfo.appl_attribute9 = p_Appl_Attribute9)
           OR (    (Recinfo.appl_attribute9 IS NULL)
               AND (p_Appl_Attribute9 IS NULL)))
      AND (   (Recinfo.appl_attribute10 = p_Appl_Attribute10)
           OR (    (Recinfo.appl_attribute10 IS NULL)
               AND (p_Appl_Attribute10 IS NULL)))
      AND (   (Recinfo.appl_attribute11 = p_Appl_Attribute11)
           OR (    (Recinfo.appl_attribute11 IS NULL)
               AND (p_Appl_Attribute11 IS NULL)))
      AND (   (Recinfo.appl_attribute12 = p_Appl_Attribute12)
           OR (    (Recinfo.appl_attribute12 IS NULL)
               AND (p_Appl_Attribute12 IS NULL)))
      AND (   (Recinfo.appl_attribute13 = p_Appl_Attribute13)
           OR (    (Recinfo.appl_attribute13 IS NULL)
               AND (p_Appl_Attribute13 IS NULL)))
      AND (   (Recinfo.appl_attribute14 = p_Appl_Attribute14)
           OR (    (Recinfo.appl_attribute14 IS NULL)
               AND (p_Appl_Attribute14 IS NULL)))
      AND (   (Recinfo.appl_attribute15 = p_Appl_Attribute15)
           OR (    (Recinfo.appl_attribute15 IS NULL)
               AND (p_Appl_Attribute15 IS NULL)))
      AND (   (Recinfo.appl_attribute16 = p_Appl_Attribute16)
           OR (    (Recinfo.appl_attribute16 IS NULL)
               AND (p_Appl_Attribute16 IS NULL)))
      AND (   (Recinfo.appl_attribute17 = p_Appl_Attribute17)
           OR (    (Recinfo.appl_attribute17 IS NULL)
               AND (p_Appl_Attribute17 IS NULL)))
      AND (   (Recinfo.appl_attribute18 = p_Appl_Attribute18)
           OR (    (Recinfo.appl_attribute18 IS NULL)
               AND (p_Appl_Attribute18 IS NULL)))
      AND (   (Recinfo.appl_attribute19 = p_Appl_Attribute19)
           OR (    (Recinfo.appl_attribute19 IS NULL)
               AND (p_Appl_Attribute19 IS NULL)))
      AND (   (Recinfo.appl_attribute20 = p_Appl_Attribute20)
           OR (    (Recinfo.appl_attribute20 IS NULL)
               AND (p_Appl_Attribute20 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Application_Id                      NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Person_Id                           NUMBER,
                     p_Person_Type_Id                      NUMBER,
                     p_Date_Received                       DATE,
                     p_Comments                            VARCHAR2,
                     p_Current_Employer                    VARCHAR2,
                     p_Date_End                            DATE,
                     p_Projected_Hire_Date                 DATE,
                     p_Successful_Flag                     VARCHAR2,
                     p_Termination_Reason                  VARCHAR2,
                     p_Cancellation_Flag                   VARCHAR2, -- parameter added for Bug 3053711
                     p_Appl_Attribute_Category             VARCHAR2,
                     p_Appl_Attribute1                     VARCHAR2,
                     p_Appl_Attribute2                     VARCHAR2,
                     p_Appl_Attribute3                     VARCHAR2,
                     p_Appl_Attribute4                     VARCHAR2,
                     p_Appl_Attribute5                     VARCHAR2,
                     p_Appl_Attribute6                     VARCHAR2,
                     p_Appl_Attribute7                     VARCHAR2,
                     p_Appl_Attribute8                     VARCHAR2,
                     p_Appl_Attribute9                     VARCHAR2,
                     p_Appl_Attribute10                    VARCHAR2,
                     p_Appl_Attribute11                    VARCHAR2,
                     p_Appl_Attribute12                    VARCHAR2,
                     p_Appl_Attribute13                    VARCHAR2,
                     p_Appl_Attribute14                    VARCHAR2,
                     p_Appl_Attribute15                    VARCHAR2,
                     p_Appl_Attribute16                    VARCHAR2,
                     p_Appl_Attribute17                    VARCHAR2,
                     p_Appl_Attribute18                    VARCHAR2,
                     p_Appl_Attribute19                    VARCHAR2,
                     p_Appl_Attribute20                    VARCHAR2
) IS

--changed for 2506446 from the old select
cursor csr_ptu_row is
select   ptu.effective_start_date
from  per_person_type_usages_f ptu
       ,per_person_types ppt
where    ptu.person_id = p_person_id
and   ptu.effective_start_date > p_date_received
and   ptu.person_type_id = ppt.person_type_id
and     ppt.system_person_type = 'EX_APL'
order by ptu.effective_start_date;

--Bug 3891787 Added the cursor to check for the person_type change
cursor csr_ptu_row1
is
select   ptu.person_type_id,ptu.effective_start_date
from  per_person_type_usages_f ptu
where    ptu.person_id = p_person_id
and    p_date_end+1 between ptu.effective_start_date and
ptu.effective_start_date;

l_person_type_id   per_person_type_usages.person_id%type;
l_start_date   date;
l_date_end     date;
l_update_mode varchar2(30);

BEGIN
  hr_utility.set_location('per_applications_pkg.update_row',10);
  -- Bug 3053711 Start
  -- Added the check if flag = 'Y'
  --Commented out for the Bug 4202317
--  if p_Cancellation_Flag = 'Y' then
    UPDATE PER_APPLICATIONS
    SET
       application_id                            =    p_Application_Id,
       business_group_id                         =    p_Business_Group_Id,
       person_id                                 =    p_Person_Id,
       date_received                             =    p_Date_Received,
       comments                                  =    p_Comments,
       current_employer                          =    p_Current_Employer,
       date_end                                  =    p_Date_End,
       projected_hire_date                       =    p_Projected_Hire_Date,
       successful_flag                           =    p_Successful_Flag,
       termination_reason                        =    p_Termination_Reason,
       appl_attribute_category                   =   p_Appl_Attribute_Category,
       appl_attribute1                           =    p_Appl_Attribute1,
       appl_attribute2                           =    p_Appl_Attribute2,
       appl_attribute3                           =    p_Appl_Attribute3,
       appl_attribute4                           =    p_Appl_Attribute4,
       appl_attribute5                           =    p_Appl_Attribute5,
       appl_attribute6                           =    p_Appl_Attribute6,
       appl_attribute7                           =    p_Appl_Attribute7,
       appl_attribute8                           =    p_Appl_Attribute8,
       appl_attribute9                           =    p_Appl_Attribute9,
       appl_attribute10                          =    p_Appl_Attribute10,
       appl_attribute11                          =    p_Appl_Attribute11,
       appl_attribute12                          =    p_Appl_Attribute12,
       appl_attribute13                          =    p_Appl_Attribute13,
       appl_attribute14                          =    p_Appl_Attribute14,
       appl_attribute15                          =    p_Appl_Attribute15,
       appl_attribute16                          =    p_Appl_Attribute16,
       appl_attribute17                          =    p_Appl_Attribute17,
       appl_attribute18                          =    p_Appl_Attribute18,
       appl_attribute19                          =    p_Appl_Attribute19,
       appl_attribute20                          =    p_Appl_Attribute20
     WHERE rowid = p_rowid;
--Commented out for the Bug 4202317
  /*else
    UPDATE PER_APPLICATIONS
    SET
       application_id                            =    p_Application_Id,
       business_group_id                         =    p_Business_Group_Id,
       person_id                                 =    p_Person_Id,
       date_received                             =    p_Date_Received,
       comments                                  =    p_Comments,
       current_employer                          =    p_Current_Employer,
       date_end                                  =    p_Date_End,
       projected_hire_date                       =    p_Projected_Hire_Date,
       successful_flag                           =    p_Successful_Flag,
       termination_reason                        =    p_Termination_Reason,
       appl_attribute_category                   =    p_Appl_Attribute_Category,
       appl_attribute1                           =    p_Appl_Attribute1,
       appl_attribute2                           =    p_Appl_Attribute2,
       appl_attribute3                           =    p_Appl_Attribute3,
       appl_attribute4                           =    p_Appl_Attribute4,
       appl_attribute5                           =    p_Appl_Attribute5,
       appl_attribute6                           =    p_Appl_Attribute6,
       appl_attribute7                           =    p_Appl_Attribute7,
       appl_attribute8                           =    p_Appl_Attribute8,
       appl_attribute9                           =    p_Appl_Attribute9,
       appl_attribute10                          =    p_Appl_Attribute10,
       appl_attribute11                          =    p_Appl_Attribute11,
       appl_attribute12                          =    p_Appl_Attribute12,
       appl_attribute13                          =    p_Appl_Attribute13,
       appl_attribute14                          =    p_Appl_Attribute14,
       appl_attribute15                          =    p_Appl_Attribute15,
       appl_attribute16                          =    p_Appl_Attribute16,
       appl_attribute17                          =    p_Appl_Attribute17,
       appl_attribute18                          =    p_Appl_Attribute18,
       appl_attribute19                          =    p_Appl_Attribute19,
       appl_attribute20                          =    p_Appl_Attribute20
     WHERE rowid = p_rowid;
  end if;*/
  -- Bug 3053711 End
  hr_utility.set_location('per_applications_pkg.update_row',20);
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  hr_utility.set_location('per_applications_pkg.update_row',30);
  --
  -- Now maintain the PTU data...
  --
  -- 3652025: Another package will do the updates when performing a termination.
  -- The reverse termination is still part of this update.
  --
  if p_Date_End is not null then
      NULL;
    --
    -- Either terminating or updating an already
    -- terminated application.
    --
   -- PTU : Following code added for PTU
   --
   --hr_utility.set_location('per_applications_pkg.update_row',40);

   --Bug No 3891787 starts here
   --Open csr_ptu_row1;
   --fetch csr_ptu_row1 into l_person_type_id,l_start_date;
   --if csr_ptu_row1%notfound then
   -- null;
   --end if;
   --if nvl(l_person_type_id,-1) <> p_person_type_id then
   --  if p_date_end +1 = l_start_date then
   --    l_update_mode := hr_api.g_correction;
   --  end if;
   --  hr_per_type_usage_internal.maintain_person_type_usage
   --  (  p_effective_date  => p_Date_End+1
   --    ,p_person_id       => p_Person_id
   --    ,p_person_type_id  => p_Person_Type_Id
   --    ,p_datetrack_update_mode => l_update_mode
      /*hr_person_type_usage_info.get_default_person_type_id
               ( p_Business_Group_Id
               ,'EX_APL')*/

   --  );
   --end if;
   --close csr_ptu_row1;
   --Bug No 3891787 ends here
   --hr_utility.set_location('per_applications_pkg.update_row',50);
   -- End of PTU Changes
   --
   --    hr_per_type_usage_internal.maintain_ptu(
   --          p_action => 'TERM_APL',
   --          p_person_id => p_Person_id,
   --          p_actual_termination_date => p_Date_End);
  else
    --
    -- Either rev-terming or updating an unterminated application
    --
--    hr_per_type_usage_internal.maintain_ptu(
--          p_action => 'REV_TERM_APL',
--          p_date_start => p_date_received,
--          p_person_id => p_person_id);

      -- PTU : Following code added for PTU (and changed for bug 2506446)

      open csr_ptu_row;
      fetch csr_ptu_row into l_date_end;
      close csr_ptu_row;

        hr_utility.set_location('per_applications_pkg.p_date_received = '||to_char(p_date_received,'DD/MM/YYYY'),60);
        hr_utility.set_location('per_applications_pkg.p_date_end = '||to_char(l_date_end,'DD/MM/YYYY'),60);
        hr_utility.set_location('per_applications_pkg.p_person_id = '||to_char(p_person_id),60);

      hr_per_type_usage_internal.cancel_person_type_usage
      (
         p_effective_date         => l_date_end
        ,p_person_id              => p_person_id
        ,p_system_person_type     => 'EX_APL'
      );

      -- End of PTU Changes

  end if;
END Update_Row;
--
PROCEDURE Delete_Row(p_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_APPLICATIONS
  WHERE  rowid = p_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< maintain_irc_ass_status >----------------------|
-- ----------------------------------------------------------------------------
procedure maintain_irc_ass_status(p_person_id         number,
                                  p_business_group_id number,
                                  p_date_end          date,
                                  p_effective_date    date,
                                  p_application_id    number,
                                  p_legislation_code  varchar2,
                                  p_action            varchar2) is
   --
   l_assignment_id       per_all_assignments_f.assignment_id%Type;
   l_irc_ass_status_id   irc_assignment_statuses.assignment_status_id%Type;
   l_ass_status          per_assignment_status_types.per_system_status%Type;
   l_irc_asg_status_ovn  irc_assignment_statuses.object_version_number%Type;
   l_ass_status_type_id  per_all_assignments_f.assignment_status_type_id%Type;
   --
   -- To get the assignment status based o the action (Termination or
   -- Reverse termination)
   cursor csr_get_asg_status is
          select  a.assignment_status_type_id
          from    per_assignment_status_types a,
                  per_ass_status_type_amends b
          where   a.per_system_status = l_ass_status
          and     b.assignment_status_type_id(+) = a.assignment_status_type_id
          and     b.business_group_id(+) + 0 = p_business_group_id
          and     nvl(a.business_group_id, p_business_group_id) =
                  p_business_group_id
          and     nvl(a.legislation_codE, p_legislation_code) =
                  p_legislation_code
          and     nvl(b.active_flag, a.active_flag) = 'Y'
          and     nvl(b.default_flag, a.default_flag) = 'Y';
   --
   -- To get all the assignment id's for the concerned application to be
   -- terminated
   cursor csr_term_ass_id is
          select paa.assignment_id
          from  per_all_assignments_f paa
          where paa.application_id = p_application_id
          and   paa.person_id = p_person_id
          and   paa.business_group_id + 0  = p_business_group_id
          and   paa.assignment_type = 'A'
          and   paa.effective_end_date =
               (select max(pa2.effective_end_date)
                from per_all_assignments_f pa2
                where pa2.person_id = p_person_id
                and pa2.application_id = p_application_id);
   --
   -- To get all the assignment id's for the concerned application to be
   -- reverse terminated
   cursor csr_cancel_ass_id is
          select paa.assignment_id
          from  per_all_assignments_f paa
          where paa.application_id = p_application_id
          and   paa.person_id = p_person_id
          and   paa.business_group_id + 0 = p_business_group_id
          and   paa.assignment_type = 'A'
          and   paa.effective_end_date = p_date_end;
   --
begin
   --
   hr_utility.set_location('PER_APPLICATIONS_PKG.maintain_irc_ass_status', 10);
   --
   -- Termination of applicant
   if p_action = 'TERM' then
      --
      l_ass_status := 'TERM_APL';
      --
      hr_utility.set_location('PER_APPLICATIONS_PKG.maintain_irc_ass_status', 20);
      --
      open csr_get_asg_status;
      fetch csr_get_asg_status into l_ass_status_type_id;
      close csr_get_asg_status;
      --
      open csr_term_ass_id;
      loop
      fetch csr_term_ass_id into l_assignment_id;
      exit when csr_term_ass_id%notfound;
      --
         irc_asg_status_api.create_irc_asg_status
                 (p_assignment_id              => l_assignment_id,
                  p_assignment_status_type_id  => l_ass_status_type_id,
                  p_status_change_date         => p_effective_date,
                  p_assignment_status_id       => l_irc_ass_status_id,
                  p_object_version_number      => l_irc_asg_status_ovn);
      --
      end loop;
      close csr_term_ass_id;
      --
   -- Reverse termination of applicant
   else
      --
      l_ass_status := 'ACTIVE_APL';
      --
      hr_utility.set_location('PER_APPLICATIONS_PKG.maintain_irc_ass_status', 30);
      --
      open csr_get_asg_status;
      fetch csr_get_asg_status into l_ass_status_type_id;
      close csr_get_asg_status;
      --
      open csr_cancel_ass_id;
      loop
      fetch csr_cancel_ass_id into l_assignment_id;
      exit when csr_cancel_ass_id%notfound;
      --
         irc_asg_status_api.create_irc_asg_status
                 (p_assignment_id              => l_assignment_id,
                  p_assignment_status_type_id  => l_ass_status_type_id,
                  p_status_change_date         => p_effective_date,
                  p_assignment_status_id       => l_irc_ass_status_id,
                  p_object_version_number      => l_irc_asg_status_ovn);
      --
      end loop;
      close csr_cancel_ass_id;
      --
   end if;
   --
   hr_utility.set_location('PER_APPLICATIONS_PKG.maintain_irc_ass_status', 40);
   --
end maintain_irc_ass_status;
--
END PER_APPLICATIONS_PKG;

/
