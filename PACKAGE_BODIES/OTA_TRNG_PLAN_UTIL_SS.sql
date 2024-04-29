--------------------------------------------------------
--  DDL for Package Body OTA_TRNG_PLAN_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRNG_PLAN_UTIL_SS" as
/* $Header: ottpswrs.pkb 115.15 2004/08/29 23:33:55 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= 'ota_trng_plan_util_ss.';  -- Global package name

--  ---------------------------------------------------------------------------
--  |----------------------< chk_cancel_plan_ok >--------------------------|
--  ---------------------------------------------------------------------------
--
Function chk_cancel_plan_ok(p_training_plan_id in ota_training_plans.training_plan_id%type)
return varchar2
is

Cursor any_child is
Select tpm.training_plan_member_id from
ota_Training_plan_members tpm
where member_status_type_id<>'CANCELLED'
and training_plan_id=p_training_plan_id and rownum=1;

    l_proc    VARCHAR2(72) := g_package ||'chk_cancel_plan_ok';
    l_exists  Number(9);
    l_result  varchar2(3) :='F';

Begin

    hr_utility.set_location(' Entering:' || l_proc,10);

    open any_child;
    fetch any_child into l_exists;
    if any_child%NOTFOUND then
        l_result :='S';
    end if;
    close any_child;

    return l_result;

end chk_cancel_plan_ok;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_complete_plan_ok >--------------------------|
--  ---------------------------------------------------------------------------
--

Function chk_complete_plan_ok(p_training_plan_id in ota_training_plans.training_plan_id%type)
return varchar2
IS

Cursor any_child is
Select tpm.training_plan_member_id from
ota_Training_plan_members tpm
where member_status_type_id<>'CANCELLED'
and member_status_type_id<>'OTA_COMPLETED'
and training_plan_id=p_training_plan_id and rownum=1;

Cursor one_child_completed is
Select tpm.training_plan_member_id from
ota_training_plan_members tpm
where member_status_type_id='OTA_COMPLETED'
and training_plan_id=p_training_plan_id and rownum=1;

    l_proc    VARCHAR2(72) := g_package ||'chk_complete_plan_ok';
    l_exists  Number(9);
    l_complete Number(9);
    l_result  varchar2(3) :='F';

Begin

    hr_utility.set_location(' Entering:' || l_proc,10);

    open any_child;
    fetch any_child into l_exists;
    if any_child%NOTFOUND then
        open one_child_completed;
        fetch one_child_completed into l_complete;
        if one_child_completed%found then
            l_result :='S';
        end if;
        close one_child_completed;
    end if;
    close any_child;

    return l_result;

end chk_complete_plan_ok;


--  ---------------------------------------------------------------------------
--  |----------------------< get_enroll_status >--------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION get_enroll_status(p_person_id               IN ota_training_plans.person_id%TYPE,
			   p_contact_id IN ota_training_plans.contact_id%TYPE,
                           p_training_plan_member_id IN ota_training_plan_members.training_plan_member_id%TYPE)
                    RETURN VARCHAR2 IS


CURSOR enroll_status IS
SELECT DECODE(bst.type,'C','Z',bst.type) status
  FROM ota_training_plan_members tpm,
       ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_training_plans tps
WHERE tpm.activity_version_id=evt.activity_version_id
   AND evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
--    and bst.active_flag='Y'
  AND tps.training_plan_id = tpm.training_plan_id
  -- Modified for Bug#3855721
   AND (tps.learning_path_id IS NOT NULL OR (
        evt.course_start_date >= tpm.earliest_start_date
        AND
            (
             evt.course_end_date IS NOT NULL
             AND evt.course_end_date <= tpm.target_completion_date
            )
            OR
            (
               evt.event_type = 'SELFPACED'
             AND tpm.target_completion_date >= evt.course_start_date
             )
         ))
   AND tpm.training_plan_member_id = p_training_plan_member_id
   -- Modified for Bug#3855721
   --AND tdb.delegate_person_id = p_person_id
   AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id))
 ORDER BY status;

l_proc  VARCHAR2(72) :=      g_package|| 'get_enroll_status';

v_enroll_status  VARCHAR2(30);

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);
    FOR rec IN enroll_status
   LOOP
        v_enroll_status :=rec.status ;
        EXIT;
    END LOOP;

 RETURN v_enroll_status;

    hr_utility.set_location(' Step:'|| l_proc, 20);

END get_enroll_status;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_login_person >--------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION chk_login_person(p_training_plan_id IN ota_training_plans.training_plan_id%TYPE)
RETURN VARCHAR2
IS

l_person_id         ota_training_plans.person_id%TYPE;
l_login_person      ota_training_plans.person_id%TYPE;
l_login_customer NUMBER;
l_contact_id         ota_training_plans.contact_id%TYPE;
l_proc              VARCHAR2(72) :=      g_package|| 'chk_login_person';

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

-- Modified for Bug#3479186
    SELECT tps.person_id,tps.contact_id
     INTO l_person_id, l_contact_id
     FROM ota_training_plans tps
    WHERE tps.training_plan_id = p_training_plan_id;

    SELECT employee_id, customer_id
      INTO l_login_person, l_login_customer
      FROM fnd_user
     WHERE user_id = fnd_profile.value('USER_ID');

    hr_utility.set_location(' Step:'|| l_proc, 20);
 IF l_login_person  IS NOT NULL THEN
      IF l_login_person = l_person_id THEN
        RETURN 'E';
    ELSE
        RETURN 'M';
    END IF;
  ELSIF l_login_customer IS NOT NULL THEN
      RETURN 'E';
  END IF;



    hr_utility.set_location(' Step:'|| l_proc, 30);
END chk_login_person;


--  ---------------------------------------------------------------------------
--  |----------------------< chk_src_func_TLNTMGT >--------------------------|
--  ---------------------------------------------------------------------------
--

FUNCTION chk_src_func_tlntmgt(p_person_id IN ota_training_plans.person_id%TYPE
                              -- ,p_source_function in ota_training_plan_members.source_function%type
                               ,p_earliest_start_date IN ota_training_plan_members.earliest_start_date%TYPE
                               ,p_target_completion_date IN ota_training_plan_members.target_completion_date%TYPE
                               -- Added for Bug#3108246
                               ,p_business_group_id   IN number)
RETURN number
IS

CURSOR csr_get_TP IS
SELECT tps.Training_plan_id
  FROM
       ota_training_plans tps
 WHERE
   p_earliest_start_date >= tps.start_date
   AND (tps.end_date IS NOT NULL AND p_target_completion_date <= tps.end_date)
   AND tps.plan_source = 'TALENT_MGMT'
   AND tps.person_id = p_person_id
   -- Added for Bug#3493925
   AND tps.plan_status_type_id = 'ACTIVE'
   -- Added for Bug#3108246
   AND tps.business_group_id = p_business_group_id
   AND (tps.additional_member_flag is null or tps.additional_member_flag<>'N');

l_proc  VARCHAR2(72) :=      g_package|| 'chk_src_func_tlntmgt';

l_training_plan_id number(9) :=0;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

    OPEN csr_get_TP ;
    FETCH csr_get_TP INTO l_training_plan_id;

        CLOSE csr_get_TP;
        RETURN l_training_plan_id;

    hr_utility.set_location(' Step:'|| l_proc, 20);

END chk_src_func_tlntmgt;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_valid_act_version_dates >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE chk_valid_act_version_dates
(p_activity_version_id IN ota_activity_versions.activity_version_id%TYPE
,p_start_date IN ota_activity_versions.start_date%TYPE
,p_end_date IN ota_activity_versions.end_date%TYPE)

IS


CURSOR csr_attached_TPC
IS
SELECT tpm.training_plan_member_id
  FROM ota_training_plan_members tpm
 WHERE tpm.activity_version_id = p_activity_version_id
   AND (tpm.earliest_start_date < p_start_date
   or (p_end_date IS NOT NULL AND tpm.target_completion_date > p_end_date))
   and tpm.member_status_type_id <> 'CANCELLED'
   AND ROWNUM=1;

l_proc  VARCHAR2(72) :=      g_package|| 'chk_valid_act_version_dates';

l_act_version_id number(9);

BEGIN

     hr_utility.set_location(' Step:'|| l_proc, 10);

    OPEN csr_attached_TPC;
    FETCH csr_attached_TPC INTO l_act_version_id;
    IF csr_attached_TPC%FOUND THEN
        CLOSE csr_attached_TPC;
        fnd_message.set_name('OTA', 'OTA_13186_TPM_ACT_DATES');
        fnd_message.raise_error;
    ELSE
        CLOSE csr_attached_TPC;
    END IF;

        hr_utility.set_location(' Step:'|| l_proc, 20);
END chk_valid_act_version_dates;

-- ---------------------------------------------------------------------------
-- |----------------------< chk_enrollment_exist >--------------------------|
-- ---------------------------------------------------------------------------

FUNCTION chk_enrollment_exist ( p_person_id IN ota_training_plans.person_id%TYPE,
								 p_contact_id IN ota_training_plans.contact_id%TYPE,
                                p_training_plan_member_id IN ota_training_plan_members.training_plan_member_id%TYPE)
RETURN boolean
IS
CURSOR chk_enr IS
SELECT NULL
  FROM ota_events e,
       ota_activity_versions a,
       ota_delegate_bookings b,
       ota_booking_status_types s,
       ota_training_plan_members tpm
 WHERE e.event_id = b.event_id
   AND tpm.activity_version_id = a.activity_version_id
   AND ((e.course_start_date >= tpm.earliest_start_date
         AND e.course_end_date  <= tpm.target_completion_date )
          OR
        (e.event_type ='SELFPACED'
         AND e.course_start_date< tpm.target_completion_date
         AND e.course_end_date >= tpm.target_completion_date
         ))
    AND e.activity_version_id = a.activity_version_id
    AND b.booking_status_type_id = s.booking_status_type_id
    -- Modified for Bug#3479186
   -- AND b.delegate_person_id = p_person_id
       AND ((p_person_id IS NOT NULL AND b.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND b.delegate_contact_id = p_contact_id)
		 )
    AND tpm.training_plan_member_id = p_training_plan_member_id;

l_proc       VARCHAR2(72) :=      g_package|| 'chk_enrollment_exist';
l_return_val VARCHAR2(1);
l_found      BOOLEAN := FALSE;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

     OPEN chk_enr;
    FETCH chk_enr INTO l_return_val;
       IF chk_enr%FOUND THEN
          --
          l_found := TRUE;
          --
      END IF;
    CLOSE chk_enr;
  --
  hr_utility.set_location('Leaving '||l_proc,10);

  RETURN l_found;

END chk_enrollment_exist;

--  ---------------------------------------------------------------------------
--  |----------------------< get_enroll_status >--------------------------|
--  ---------------------------------------------------------------------------
--  DECODE(bst.type,'C','Z',bst.type):  Decode is to get the Cancelled enrollments
--  in the end because the attended overrules all others and 'P', 'R', 'W'
--  overrules 'C'.

FUNCTION get_enroll_status(p_person_id              IN ota_training_plans.person_id%TYPE,
			   p_contact_id IN ota_training_plans.contact_id%TYPE,
                           p_earliest_start_date    IN ota_training_plan_members.earliest_start_date%TYPE,
                           p_target_completion_date IN ota_training_plan_members.target_completion_date%TYPE,
                           p_activity_version_id    IN ota_training_plan_members.activity_version_id%TYPE,
                           p_training_plan_id       IN ota_training_plans.training_plan_id%TYPE,
                           p_action                 IN VARCHAR2)
                    RETURN VARCHAR2 IS


CURSOR enroll_status_dates IS
SELECT DECODE(bst.type,'C','Z',bst.type) status
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND (
        evt.course_start_date >= p_earliest_start_date
        AND
            (
             evt.course_end_date IS NOT NULL
             AND evt.course_end_date <= p_target_completion_date
            )
            OR
            (
               evt.event_type = 'SELFPACED'
             AND p_target_completion_date >= evt.course_start_date
             )
         )
   AND evt.activity_version_id = p_activity_version_id
   --AND tdb.delegate_person_id = p_person_id
    AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id)
		 )
 ORDER BY status;

CURSOR enroll_status_without_dates IS
SELECT DECODE(bst.type,'C','Z',bst.type) status
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND evt.activity_version_id = p_activity_version_id
   -- Modified for Bug#3479186
  -- AND tdb.delegate_person_id = p_person_id
  AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id)
		 )
 ORDER BY status;

CURSOR csr_plan_source IS
SELECT tps.plan_source
FROM ota_training_plans tps
where tps.training_plan_id = p_training_plan_id;

l_proc  VARCHAR2(72) :=      g_package|| 'get_enroll_status';

v_enroll_status  VARCHAR2(30);

l_plan_source                varchar2(30);

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

   -- Remove the original date checks for creating members of non tlnt mgmt sources.
   -- This is requied to determine past completed course before enrolling or creating a LP
   open csr_plan_source;
   fetch csr_plan_source into l_plan_source;
   close csr_plan_source;

   if (l_plan_source <> 'CATALOG') then
       FOR rec_dates IN enroll_status_dates
       LOOP
        v_enroll_status := rec_dates.status ;
        EXIT;
       END LOOP;
   else
      FOR rec_without_dates IN enroll_status_without_dates
      LOOP
        v_enroll_status := rec_without_dates.status ;
        EXIT;
      END LOOP;
   end if;

 RETURN v_enroll_status;

    hr_utility.set_location(' Step:'|| l_proc, 20);

END get_enroll_status;

--  ---------------------------------------------------------------------------
--  |----------------------< modify_tpc_status_on_create >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE modify_tpc_status_on_create(--p_person_id               IN ota_training_plans.person_id%TYPE,
				     -- p_contact_id IN ota_training_plans.contact_id%TYPE,
                                      p_earliest_start_date     IN ota_training_plan_members.earliest_start_date%TYPE,
                                      p_target_completion_date  IN ota_training_plan_members.target_completion_date%TYPE,
                                      p_activity_version_id     IN ota_activity_versions.activity_version_id%TYPE,
                                      p_training_plan_id        IN ota_training_plans.training_plan_id%TYPE,
                                      p_member_status_id        OUT nocopy VARCHAR2)
 IS

 l_proc             VARCHAR2(72) :=      g_package|| 'modify_tpc_status_on_create';
 l_enroll_status    VARCHAR2(30);
 l_person_id OTA_TRAINING_PLANS.PERSON_ID%TYPE;
l_contact_id  OTA_TRAINING_PLANS.CONTACT_ID%TYPE;

 BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 10);

-- Modified for Bug#3479186
 SELECT tp.person_id, tp.contact_id
 INTO l_person_id , l_contact_id
 FROM ota_training_plans tp
 where tp.training_plan_id = p_training_plan_id;


 l_enroll_status := get_enroll_status(p_person_id              => l_person_id,
			                                   p_contact_id  => l_contact_id,
                                                           p_earliest_start_date    => p_earliest_start_date,
                                                           p_target_completion_date => p_target_completion_date,
                                                           p_activity_version_id    => p_activity_version_id,
                                                           p_training_plan_id      => p_training_plan_id,
                                                           p_action                 => 'CREATE' );

 IF ( l_enroll_status='A' ) THEN

    p_member_status_id := 'OTA_COMPLETED';

 ELSIF ( l_enroll_status='P'
         OR l_enroll_status='W'
         OR l_enroll_status ='R') THEN

    p_member_status_id := 'ACTIVE';

 ELSE
    p_member_status_id := 'OTA_PLANNED';

 END IF;

 hr_utility.set_location('LEAVING:'|| l_proc, 20);

 EXCEPTION
    WHEN others THEN

        p_member_status_id := NULL;

        RAISE;

END modify_tpc_status_on_create;

--  ---------------------------------------------------------------------------
--  |----------------------< modify_tpc_status_on_update >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE modify_tpc_status_on_update(--p_person_id               IN ota_training_plans.person_id%TYPE,
                                      p_earliest_start_date     IN ota_training_plan_members.earliest_start_date%TYPE,
                                      p_target_completion_date  IN ota_training_plan_members.target_completion_date%TYPE,
                                      p_activity_version_id     IN ota_activity_versions.activity_version_id%TYPE,
                                      p_training_plan_id        IN ota_training_plans.training_plan_id%TYPE,
                                      p_member_status_id        OUT nocopy VARCHAR2)
 IS

 l_proc             VARCHAR2(72) :=      g_package|| 'modify_tpc_status_on_update';
 l_enroll_status    VARCHAR2(30);
 l_person_id OTA_TRAINING_PLANS.PERSON_ID%TYPE;
l_contact_id  OTA_TRAINING_PLANS.CONTACT_ID%TYPE;

 BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 10);

-- Modified for Bug#3479186
  SELECT tp.person_id, tp.contact_id
 INTO l_person_id , l_contact_id
 FROM ota_training_plans tp
 where tp.training_plan_id = p_training_plan_id;


 l_enroll_status := get_enroll_status(p_person_id              => l_person_id,
			                                   p_contact_id  => l_contact_id,
                                                           p_earliest_start_date    => p_earliest_start_date,
                                                           p_target_completion_date => p_target_completion_date,
                                                           p_activity_version_id    => p_activity_version_id,
                                                           p_training_plan_id      => p_training_plan_id,
                                                           p_action                 => 'UPDATE' );

 IF ( l_enroll_status='A' ) THEN

    p_member_status_id := 'OTA_COMPLETED';

 ELSIF ( l_enroll_status='P'
         OR l_enroll_status='W'
         OR l_enroll_status ='R') THEN

    p_member_status_id := 'ACTIVE';

 ELSE
    p_member_status_id := 'OTA_PLANNED';

 END IF;

 hr_utility.set_location('LEAVING:'|| l_proc, 20);

 EXCEPTION
    WHEN others THEN

        p_member_status_id := NULL;

        RAISE;

END modify_tpc_status_on_update;

-- ----------------------------------------------------------------------------
-- |---------------------------<  get_person_id  >----------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_person_id(p_training_plan_id IN ota_training_plans.training_plan_id%TYPE)
  RETURN number
IS

CURSOR csr_person_id IS
SELECT person_id
  FROM ota_training_plans
 WHERE training_plan_id = p_training_plan_id;

l_person_id number(9) := 0;

BEGIN

    OPEN csr_person_id;
    FETCH csr_person_id INTO l_person_id;
    CLOSE csr_person_id;

    IF l_person_id is null then
    l_person_id := 0;
    END IF;

    RETURN l_person_id;

END get_person_id;

-- ----------------------------------------------------------------------------
-- |---------------------------<  get_valid_enroll  >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_valid_enroll (p_person_id                  IN ota_training_plans.person_id%TYPE
			    , p_contact_id IN ota_training_plans.contact_id%TYPE
                            ,p_training_plan_member_id   IN ota_training_plan_members.training_plan_member_id%TYPE
                            ,p_return_status             OUT nocopy VARCHAR2)
IS
    l_evt_type VARCHAR2(30);
    l_proc  VARCHAR2(72) :=      g_package|| 'get_valid_enroll';
BEGIN

  l_evt_type:= get_enroll_status(p_person_id               => p_person_id,
                                 p_contact_id  => p_contact_id,
                                 p_training_plan_member_id => p_training_plan_member_id);
  p_return_status := 'S';

  IF ( l_evt_Type IS NOT NULL AND l_evt_type <> 'Z' ) THEN
    p_return_status := 'E';
  END IF;

END get_valid_enroll;

--  ---------------------------------------------------------------------------
--  |----------------------< is_personal_trng_plan >--------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION is_personal_trng_plan
RETURN BOOLEAN
IS

l_proc              VARCHAR2(72) :=      g_package|| 'is_personal_trng_plan';

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

     IF g_is_per_trng_plan IS NOT NULL
     THEN
        RETURN g_is_per_trng_plan;
     END IF;

END is_personal_trng_plan;

--  ---------------------------------------------------------------------------
--  |----------------------< is_personal_trng_plan >--------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION is_personal_trng_plan(p_training_plan_id IN ota_training_plans.training_plan_id%TYPE)
RETURN BOOLEAN
IS

l_person_id         ota_training_plans.person_id%TYPE;
l_contact_id        ota_training_plans.contact_id%TYPE;
l_proc              VARCHAR2(72) :=      g_package|| 'is_personal_trng_plan';

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

    SELECT tps.person_id, tps.contact_id
     INTO l_person_id, l_contact_id
     FROM ota_training_plans tps
    WHERE tps.training_plan_id = p_training_plan_id;

    hr_utility.set_location(' Step:'|| l_proc, 20);

     IF l_person_id IS NOT NULL OR l_contact_id IS NOT NULL
     THEN
        g_is_per_trng_plan := true;
     END IF;

    hr_utility.set_location(' Step:'|| l_proc, 30);

    RETURN g_is_per_trng_plan;
END is_personal_trng_plan;

Procedure complete_plan
(p_training_plan_id ota_training_plans.training_plan_id%type)
is

CURSOR csr_tp_update(csr_training_plan_id number)
    IS
    SELECT otp.name,
           otp.object_version_number,
           otp.time_period_id,
           otp.budget_currency
     FROM ota_training_plans otp
     WHERE otp.training_plan_id = csr_training_plan_id;


  l_name                 ota_training_plans.name%type;
  l_object_version_number  ota_training_plans.object_version_number%type;
  l_time_period_id        ota_training_plans.time_period_id%type;
  l_budget_currency       ota_training_plans.budget_currency%type;
  l_plan_status_type_id   ota_training_plans.plan_status_type_id%type;

BEGIN
        l_plan_status_type_id := 'OTA_COMPLETED';

        OPEN csr_tp_update(p_training_plan_id);
        FETCH csr_tp_update into l_name,l_object_version_number,l_time_period_id,l_budget_currency;
        IF csr_tp_update%FOUND then
           CLOSE csr_tp_update;
           ota_tps_api.update_training_plan
                       (p_effective_date               => sysdate
                       ,p_training_plan_id             => p_training_plan_id
                       ,p_object_version_number        => l_object_version_number
                       ,p_plan_status_type_id          => l_plan_status_type_id
                       ,p_name                         => l_name
                       ,p_time_period_id               => l_time_period_id
                       ,p_budget_currency              => l_budget_currency);

        ELSE
          CLOSE csr_tp_update;
        END IF;
END complete_plan;

--
END ota_trng_plan_util_ss;


/
