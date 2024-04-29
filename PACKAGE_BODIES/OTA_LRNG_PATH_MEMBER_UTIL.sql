--------------------------------------------------------
--  DDL for Package Body OTA_LRNG_PATH_MEMBER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LRNG_PATH_MEMBER_UTIL" as
/* $Header: otlpmwrs.pkb 120.0.12010000.4 2009/06/04 08:53:06 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= '  ota_lrng_path_member_util.';  -- Global package name
--

--  ---------------------------------------------------------------------------
--  |----------------------< get_enrollment_status >--------------------------|
--  ---------------------------------------------------------------------------
FUNCTION get_enrollment_status(p_person_id                IN ota_learning_paths.person_id%TYPE,
			                   p_contact_id               IN ota_learning_paths.contact_id%TYPE,
                               p_activity_version_id      IN ota_learning_path_members.activity_version_id%TYPE,
                               p_lp_member_enrollment_id  IN ota_lp_member_enrollments.lp_member_enrollment_id%TYPE DEFAULT NULL,
                               p_return_code              IN VARCHAR2)
  RETURN VARCHAR2 IS

CURSOR csr_lp_enr IS
SELECT DECODE(bst.type,'C','Z',bst.type) status,
       bst.name
  FROM ota_learning_path_members lpm,
       ota_lp_member_enrollments lme,
       ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types_vl bst
 WHERE lpm.activity_version_id = evt.activity_version_id
   AND evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND lme.learning_path_member_id = lpm.learning_path_member_id
   AND lme.lp_member_enrollment_id = p_lp_member_enrollment_id
   AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id)
		 )
 ORDER BY status, evt.course_start_date;


CURSOR csr_act_enr IS
SELECT DECODE(bst.type,'C','Z',bst.type) status,
       bst.name
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types_vl bst
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND evt.activity_version_id = p_activity_version_id
    AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id)
		 )
 ORDER BY status, evt.course_start_date;

l_proc  VARCHAR2(72) :=      g_package|| 'get_enrollment_status';

l_status_type     ota_booking_status_types.type%TYPE;
l_status_name     ota_booking_status_types_vl.name%TYPE := null;
l_return          ota_booking_status_types_vl.name%TYPE;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

    IF p_lp_member_enrollment_id IS NOT NULL THEN
       FOR rec_lp_enr IN csr_lp_enr
       LOOP
         l_status_type     := rec_lp_enr.status ;
         l_status_name     := rec_lp_enr.name;
         EXIT;
       END LOOP;
  ELSE
       FOR rec_act_enr IN csr_act_enr
       LOOP
         l_status_type     := rec_act_enr.status ;
         l_status_name     := rec_act_enr.name;
         EXIT;
       END LOOP;
   END IF;

      IF p_return_code = 'NAME' THEN
         IF l_status_name IS NULL THEN
            l_status_name := ota_utility.get_message('OTA','OTA_13080_NOT_ENROLLED');
         END IF;
         l_return := l_status_name;
    ELSE l_return := l_status_type;
     END IF;

    hr_utility.set_location(' Step:'|| l_proc, 20);
 RETURN l_return;

END get_enrollment_status;


--  ---------------------------------------------------------------------------
--  |----------------------< get_enrollment_status >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE get_enrollment_status(p_person_id               IN ota_learning_paths.person_id%TYPE,
			        p_contact_id 	          IN ota_learning_paths.contact_id%TYPE,
                                p_activity_version_id      IN ota_learning_path_members.activity_version_id%TYPE,
                                p_lp_member_enrollment_id IN ota_lp_member_enrollments.lp_member_enrollment_id%TYPE,
                                p_booking_status_type     OUT NOCOPY ota_booking_status_types.type%TYPE,
                                p_date_status_changed     OUT NOCOPY ota_delegate_bookings.date_status_changed%TYPE)
 IS


CURSOR csr_lp_enr IS
SELECT DECODE(bst.type,'C','Z',bst.type) status,
       tdb.date_status_changed
  FROM ota_learning_path_members lpm,
       ota_lp_member_enrollments lme,
       ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
 WHERE lpm.activity_version_id = evt.activity_version_id
   AND evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND lme.learning_path_member_id = lpm.learning_path_member_id
   AND lme.lp_member_enrollment_id = p_lp_member_enrollment_id
   AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id)
		 )
 ORDER BY status, evt.course_start_date;

CURSOR csr_act_enr IS
SELECT DECODE(bst.type,'C','Z',bst.type) status,
       tdb.date_status_changed
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types_vl bst
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND evt.activity_version_id = p_activity_version_id
    AND ((p_person_id IS NOT NULL AND tdb.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND tdb.delegate_contact_id = p_contact_id)
		 )
 ORDER BY status, evt.course_start_date;

l_proc  VARCHAR2(72) :=      g_package|| 'get_enrollment_status';

v_enroll_status  VARCHAR2(30);
v_date_status_changed   ota_delegate_bookings.date_status_changed%TYPE;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);
    IF p_lp_member_enrollment_id IS NOT NULL THEN
       FOR rec_lp_enr IN csr_lp_enr
       LOOP
        v_enroll_status := rec_lp_enr.status ;
        v_date_status_changed := rec_lp_enr.date_status_changed;
         EXIT;
       END LOOP;
    ELSE
       FOR rec_act_enr IN csr_act_enr
       LOOP
        v_enroll_status := rec_act_enr.status ;
        v_date_status_changed := rec_act_enr.date_status_changed;
         EXIT;
       END LOOP;
   END IF;

    p_booking_status_type := v_enroll_status;
    p_date_status_changed := v_date_status_changed;

    hr_utility.set_location(' Step:'|| l_proc, 20);

END get_enrollment_status;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_enrollment_exist >--------------------------|
-- ---------------------------------------------------------------------------
FUNCTION chk_enrollment_exist(p_person_id               IN ota_learning_paths.person_id%TYPE,
		      	              p_contact_id              IN ota_learning_paths.contact_id%TYPE,
                              p_learning_path_member_id IN ota_learning_path_members.learning_path_member_id%TYPE)
RETURN boolean
IS
CURSOR chk_enr IS
SELECT NULL
  FROM ota_events e,
       ota_activity_versions a,
       ota_delegate_bookings b,
       ota_booking_status_types s,
       ota_learning_path_members lpm
 WHERE e.event_id = b.event_id
   AND lpm.activity_version_id = a.activity_version_id
    AND e.activity_version_id = a.activity_version_id
    AND b.booking_status_type_id = s.booking_status_type_id
    AND ((p_person_id IS NOT NULL AND b.delegate_person_id = p_person_id)
                   OR (p_contact_id IS NOT NULL AND b.delegate_contact_id = p_contact_id)
		 )
    AND lpm.learning_path_member_id = p_learning_path_member_id;

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
--  |----------------------< calculate_lme_status >-----------------------------|
--  ---------------------------------------------------------------------------
PROCEDURE calculate_lme_status(p_activity_version_id      IN ota_activity_versions.activity_version_id%TYPE,
                               p_lp_enrollment_id         IN ota_lp_enrollments.lp_enrollment_id%TYPE,
                               p_member_status_code       OUT nocopy VARCHAR2,
                               p_completion_date          OUT nocopy DATE)
 IS

 l_proc             VARCHAR2(72) :=      g_package|| 'calculate_lme_status';
 l_enroll_status    VARCHAR2(30);
 l_date_status_changed DATE;
 l_person_id        ota_learning_paths.person_id%TYPE;
 l_contact_id       ota_learning_paths.contact_id%TYPE;

 BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 10);

 SELECT lpe.person_id, lpe.contact_id
 INTO l_person_id , l_contact_id
 FROM ota_lp_enrollments lpe
 where lpe.lp_enrollment_id = p_lp_enrollment_id;

 get_enrollment_status(p_person_id               => l_person_id,
                       p_contact_id              => l_contact_id,
                       p_activity_version_id     => p_activity_version_id,
                       p_lp_member_enrollment_id => null,
                       p_booking_status_type     => l_enroll_status,
                       p_date_status_changed     => l_date_status_changed);

 IF ( l_enroll_status='A' ) THEN

    p_member_status_code := 'COMPLETED';
    --p_completion_date    := l_date_status_changed;
    p_completion_date := get_lpm_completion_date(null,p_activity_version_id,l_person_id,l_contact_id);

 ELSIF ( l_enroll_status='P'
         OR l_enroll_status='W'
         OR l_enroll_status ='R') THEN

    p_member_status_code := 'ACTIVE';
    p_completion_date    := null;
 ELSE
    p_member_status_code := 'PLANNED';
    p_completion_date    := null;
 END IF;

 hr_utility.set_location('LEAVING:'|| l_proc, 20);

 EXCEPTION
    WHEN others THEN
        p_member_status_code := 'PLANNED';
        RAISE;

END calculate_lme_status;

--  ---------------------------------------------------------------------------
--  |----------------------< get_lme_status >-----------------------------|
--  ---------------------------------------------------------------------------
FUNCTION get_lme_status(p_activity_version_id      IN ota_activity_versions.activity_version_id%TYPE,
                        p_person_id                  IN ota_learning_paths.person_id%TYPE,
       			        p_contact_id                 IN ota_learning_paths.contact_id%TYPE)
RETURN VARCHAR2
 IS

 l_proc             VARCHAR2(72) :=      g_package|| 'get_lme_status';
 l_enroll_status    VARCHAR2(30);
 l_member_status_code VARCHAR2(30);
 l_date_status_changed DATE;
 l_person_id        ota_learning_paths.person_id%TYPE;
 l_contact_id       ota_learning_paths.contact_id%TYPE;

 BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 10);

 get_enrollment_status(p_person_id               => p_person_id,
                       p_contact_id              => p_contact_id,
                       p_activity_version_id     => p_activity_version_id,
                       p_lp_member_enrollment_id => null,
                       p_booking_status_type     => l_enroll_status,
                       p_date_status_changed     => l_date_status_changed);

 IF ( l_enroll_status='A' ) THEN

    l_member_status_code := 'COMPLETED';


 ELSIF ( l_enroll_status='P'
         OR l_enroll_status='W'
         OR l_enroll_status ='R') THEN

    l_member_status_code := 'ACTIVE';

 ELSE
    l_member_status_code := 'PLANNED';

 END IF;

 hr_utility.set_location('LEAVING:'|| l_proc, 20);

 RETURN l_member_status_code;

END get_lme_status;


-- ----------------------------------------------------------------------------
--  |----------------------< get_lpc_completed_courses   >---------------------|
--  ---------------------------------------------------------------------------
FUNCTION get_lpc_completed_courses(p_learning_path_section_id IN ota_lp_sections.learning_path_section_id%TYPE)
  RETURN NUMBER IS

CURSOR csr_lpc_comp IS
SELECT count(lp_member_enrollment_id)
  FROM ota_lp_member_enrollments
 WHERE learning_path_section_id = p_learning_path_section_id
   AND member_status_code = 'COMPLETED';

l_proc  VARCHAR2(72) :=      g_package|| 'get_lpc_completed_courses';

l_completed_courses   ota_lp_enrollments.no_of_completed_courses%TYPE;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);
    OPEN csr_lpc_comp;
   FETCH csr_lpc_comp INTO l_completed_courses;
   CLOSE csr_lpc_comp;

    hr_utility.set_location(' Step:'|| l_proc, 20);
 RETURN l_completed_courses;

END get_lpc_completed_courses;

-- ----------------------------------------------------------------------------
--  |----------------------< chk_section_completion_type >---------------------|
--  ---------------------------------------------------------------------------
FUNCTION chk_section_completion_type(p_learning_path_member_id IN ota_learning_path_members.learning_path_member_id%TYPE)
  RETURN VARCHAR2 IS

CURSOR csr_lpc_dtl IS
SELECT completion_type_code
  FROM ota_lp_sections lpc,
       ota_learning_path_members lpm
 WHERE lpc.learning_path_section_id = lpm.learning_path_section_id
   AND lpm.learning_path_member_id = p_learning_path_member_id;

l_proc  VARCHAR2(72) :=      g_package|| 'chk_section_completion_type';

l_completion_type     ota_lp_sections.completion_type_code%TYPE;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);
    OPEN csr_lpc_dtl;
   FETCH csr_lpc_dtl INTO l_completion_type;
   CLOSE csr_lpc_dtl;

    hr_utility.set_location(' Step:'|| l_proc, 20);
 RETURN l_completion_type;

END chk_section_completion_type;

-- ----------------------------------------------------------------------------
-- |---------------------------<  get_valid_enroll  >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_valid_enroll (p_person_id                  IN ota_learning_paths.person_id%TYPE
			                ,p_contact_id                IN ota_learning_paths.contact_id%TYPE
                            ,p_lp_member_enrollment_id   IN ota_lp_member_enrollments.lp_member_enrollment_id%TYPE
                            ,p_return_status             OUT nocopy VARCHAR2)
IS
    l_enr_type VARCHAR2(30);
    l_proc  VARCHAR2(72) :=      g_package|| 'get_valid_enroll';
BEGIN

  l_enr_type:= get_enrollment_status(p_person_id               => p_person_id,
                                     p_contact_id              => p_contact_id,
                                     p_activity_version_id     => null,
                                     p_lp_member_enrollment_id => p_lp_member_enrollment_id,
                                     p_return_code             => 'TYPE');
  p_return_status := 'S';

  IF ( l_enr_type IS NOT NULL AND l_enr_type <> 'Z' ) THEN
    p_return_status := 'E';
  END IF;

END get_valid_enroll;



--  ---------------------------------------------------------------------------
--  |----------------------< update_lme_enroll_status_chg >--------------------------|
--  ---------------------------------------------------------------------------
PROCEDURE update_lme_enroll_status_chg (p_event_id           IN ota_events.event_id%TYPE,
                                        p_person_id          IN ota_lp_enrollments.person_id%TYPE,
    				        p_contact_id         IN ota_lp_enrollments.contact_id%TYPE,
                                        p_lp_enrollment_ids  OUT NOCOPY varchar2)
IS

l_proc  VARCHAR2(72) :=      g_package|| 'update_lme_enroll_status_chg';


  CURSOR evt_det IS
  SELECT activity_version_id
    FROM ota_events
   WHERE event_id = p_event_id;

  --get all the lpms which have the passed event as a component
  CURSOR csr_lpm_info(csr_activity_version_id  number) IS
  SELECT olme.lp_member_enrollment_id,
         olpe.lp_enrollment_id,
         olme.object_version_number,
         olpm.learning_path_section_id,
         olpm.learning_path_member_id,
         olpe.no_of_completed_courses,
         olpe.no_of_mandatory_courses,
         olme.member_status_code,
         olme.event_id
    FROM ota_learning_path_members olpm,
         ota_lp_member_enrollments olme,
         ota_lp_enrollments olpe
   WHERE olpe.learning_path_id = olpm.learning_path_id
     AND olpm.learning_path_member_id = olme.learning_path_member_id
     AND olpe.lp_enrollment_id = olme.lp_enrollment_id
     AND (( p_person_id IS NOT NULL AND olpe.person_id = p_person_id)
                OR (p_contact_id IS NOT NULL AND olpe.contact_id = p_contact_id))
     AND olpm.activity_version_id = csr_activity_version_id
     AND olme.member_status_code <> 'CANCELLED';

  l_activity_version_id  ota_activity_versions.activity_version_id%TYPE;
  l_lp_section_id        ota_lp_sections.learning_path_section_id%TYPE;
  l_completion_type_code ota_lp_sections.completion_type_code%TYPE;
  l_enroll_type          ota_booking_status_types.type%TYPE;
  l_member_status_code   ota_lp_member_enrollments.member_status_code%TYPE;
  l_completion_date      ota_lp_enrollments.completion_date%TYPE;
  l_date_status_changed  ota_delegate_bookings.date_status_changed%TYPE;
  l_completed_courses 	 ota_lp_enrollments.no_of_completed_courses%TYPE := 0;
  l_mandatory_courses	 ota_lp_enrollments.no_of_mandatory_courses%TYPE;
  l_section_completed_courses ota_lp_enrollments.no_of_completed_courses%TYPE;

  --variables to store old values
  l_old_completed_courses	ota_lp_enrollments.no_of_completed_courses%TYPE;
  l_old_mandatory_courses	ota_lp_enrollments.no_of_mandatory_courses%TYPE;
  l_old_member_status           ota_lp_member_enrollments.member_status_code%TYPE;
  l_event_id ota_events.event_id%TYPE;


BEGIN


    OPEN evt_det;
    FETCH evt_det
     INTO l_activity_version_id;
    CLOSE evt_det;

        hr_utility.set_location(' Step:'|| l_proc, 20);

        FOR rec IN csr_lpm_info(l_activity_version_id)

            LOOP

         get_enrollment_status(p_person_id               => p_person_id,
                               p_contact_id              => p_contact_id,
                               p_activity_version_id     => l_activity_version_id,
                               p_lp_member_enrollment_id => rec.lp_member_enrollment_id,
                               p_booking_status_type     => l_enroll_type,
                               p_date_status_changed     => l_date_status_changed);
             l_completion_date := null;
	     l_event_id := rec.event_id;

           IF l_enroll_type = 'A' THEN
              l_member_status_code := 'COMPLETED';
              --l_completion_date := l_date_status_changed;
              l_completion_date := get_lpm_completion_date(rec.lp_member_enrollment_id,null, null,null);
            ELSIF ( l_enroll_type = 'P'
              OR l_enroll_type = 'W'
              OR l_enroll_type = 'R') THEN
              l_member_status_code := 'ACTIVE';
            ELSE
		l_member_status_code := 'PLANNED';
		l_event_id := null;
          END IF;
                 l_old_member_status        := rec.member_status_code;

                 IF l_old_member_status <> l_member_status_code THEN
                  --call upd lme api after lck
		 ota_lp_member_enrollment_api.update_lp_member_enrollment
                        (p_effective_date           => sysdate
                        ,p_object_version_number    => rec.object_version_number
                        ,p_learning_path_member_id  => rec.learning_path_member_id
                        ,p_lp_enrollment_id         => rec.lp_enrollment_id
                        ,p_lp_member_enrollment_id  => rec.lp_member_enrollment_id
                        ,p_member_status_code       => l_member_status_code
                        ,p_completion_date          => l_completion_date
			,p_event_id                 => l_event_id);


                 l_completion_type_code     := chk_section_completion_type(rec.learning_path_member_id);
                 l_old_mandatory_courses    := NVL(rec.no_of_mandatory_courses,0);
                 l_old_completed_courses    := NVL(rec.no_of_completed_courses,0);
                 l_completed_courses        := l_old_completed_courses;


                 IF l_old_member_status IN ('PLANNED', 'ACTIVE', 'AWAITING_APPROVAL') and l_member_status_code = 'COMPLETED' THEN

                        IF l_completion_type_code = 'M' THEN
                               l_completed_courses := l_old_completed_courses +1 ;
                     ELSIF l_completion_type_code = 'S' THEN
                           l_section_completed_courses := get_lpc_completed_courses(rec.learning_path_section_id);
                           IF l_old_completed_courses < l_old_mandatory_courses THEN
                               l_completed_courses := l_old_completed_courses +1 ;
                           END IF;
                       END IF;
                END IF;
                 IF l_old_member_status = 'COMPLETED' and l_member_status_code <> 'COMPLETED' THEN
                        IF l_completion_type_code = 'M' THEN
                           l_completed_courses := l_old_completed_courses -1;
                     ELSIF l_completion_type_code = 'S' THEN
                           l_section_completed_courses := get_lpc_completed_courses(rec.learning_path_section_id);
                           IF l_old_completed_courses <= l_old_mandatory_courses AND
                              l_section_completed_courses < l_old_mandatory_courses THEN
                              l_completed_courses := l_old_completed_courses - 1 ;
                           END IF;
                       END IF;
                END IF;


        Update_lpe_lme_change(rec.lp_member_enrollment_id, l_completed_courses, p_lp_enrollment_ids);

        END IF;
            END LOOP;

    hr_utility.set_location(' Step:'|| l_proc, 30);

       --MULTI MESSAGE SUPPORT


END update_lme_enroll_status_chg;

--  ---------------------------------------------------------------------------
--  |----------------------< Update_lpe_lme_change >--------------------------|
--  ---------------------------------------------------------------------------
--
-- This procedure will get called only when a tpc is Cancelled
Procedure Update_lpe_lme_change( p_lp_member_enrollment_id    ota_lp_member_enrollments.lp_member_enrollment_id%TYPE)
is

CURSOR csr_lpe_with_lme
    IS
    SELECT lpe.lp_enrollment_id,
           lpe.path_status_code
      FROM ota_lp_enrollments lpe,
           ota_lp_member_enrollments lme
     WHERE lpe.lp_enrollment_id = lme.lp_enrollment_id
       AND lpe.path_status_code <> 'CANCELLED'
       AND lme.lp_member_enrollment_id = p_lp_member_enrollment_id;

CURSOR csr_lpe_update(csr_lp_enrollment_id number)
    IS
    SELECT lpe.object_version_number
      FROM ota_lp_enrollments lpe
     WHERE lpe.lp_enrollment_id = csr_lp_enrollment_id;


  l_exists                 ota_lp_member_enrollments.lp_member_enrollment_id%TYPE;
  l_object_version_number  ota_lp_enrollments.object_version_number%type;
  l_path_status_code       ota_lp_enrollments.path_status_code%TYPE;
  l_complete_ok            varchar2(1);

BEGIN
    FOR rec1 in csr_lpe_with_lme LOOP
        l_path_status_code :=rec1.path_status_code;
        l_complete_ok := ota_lrng_path_util.chk_complete_path_ok(rec1.lp_enrollment_id);
        IF l_complete_ok = 'S'
            AND rec1.path_status_code = 'ACTIVE'
          THEN
          -- The Plan can be completed
            l_path_status_code := 'COMPLETED';
        ELSIF l_complete_ok = 'F' AND rec1.path_status_code = 'COMPLETED' THEN
            l_path_status_code := 'ACTIVE';
        END IF;

        IF l_path_status_code <> rec1.path_status_code THEN
              OPEN csr_lpe_update(rec1.lp_enrollment_id);
              FETCH csr_lpe_update into l_object_version_number;
              IF csr_lpe_update%FOUND then
			     CLOSE csr_lpe_update;
                 ota_lp_enrollment_api.update_lp_enrollment
                            (p_effective_date               => sysdate
                            ,p_lp_enrollment_id             => rec1.lp_enrollment_id
                            ,p_object_version_number        => l_object_version_number
                            ,p_path_status_code             => l_path_status_code);

              ELSE
                  CLOSE csr_lpe_update;
              END IF;
         END IF;
     END LOOP;
END Update_lpe_lme_change;


Procedure Update_lpe_lme_change (p_lp_member_enrollment_id  ota_lp_member_enrollments.lp_member_enrollment_id%TYPE,
                                 p_no_of_completed_courses  ota_lp_enrollments.no_of_completed_courses%TYPE,
                                 p_lp_enrollment_ids        OUT NOCOPY VARCHAR2)
is

CURSOR csr_lpe_with_lme
    IS
    SELECT lpe.lp_enrollment_id,
           lpe.path_status_code,
           lpe.learning_path_id,
           lpe.no_of_mandatory_courses
      FROM ota_lp_enrollments lpe,
           ota_lp_member_enrollments lme
     WHERE lpe.lp_enrollment_id = lme.lp_enrollment_id
       AND lpe.path_status_code <> 'CANCELLED'
       AND lme.lp_member_enrollment_id = p_lp_member_enrollment_id;


CURSOR csr_lpe_update(csr_lp_enrollment_id number)
    IS
    SELECT lpe.object_version_number
      FROM ota_lp_enrollments lpe
     WHERE lpe.lp_enrollment_id = csr_lp_enrollment_id;

  l_exists                 ota_lp_member_enrollments.lp_member_enrollment_id%TYPE;
  l_object_version_number  ota_lp_enrollments.object_version_number%type;
  l_path_status_code       ota_lp_enrollments.path_status_code%TYPE;
  l_completion_date        DATE;
  l_complete_ok            varchar2(1);
  l_lp_enrollment_ids      varchar2(4000) := '';

BEGIN
    FOR rec1 in csr_lpe_with_lme LOOP
        l_path_status_code :=rec1.path_status_code;
        l_complete_ok := ota_lrng_path_util.chk_complete_path_ok(rec1.lp_enrollment_id); --Bug#7028384
        -- IF p_no_of_completed_courses = rec1.no_of_mandatory_courses AND
          IF rec1.path_status_code = 'ACTIVE' AND l_complete_ok = 'S'
	  THEN
          -- The Plan can be completed
            l_path_status_code := 'COMPLETED';

            IF rec1.lp_enrollment_id IS NOT NULL THEN
                if l_lp_enrollment_ids = '' or l_lp_enrollment_ids is null then
                l_lp_enrollment_ids := rec1.lp_enrollment_id;
                else
                l_lp_enrollment_ids := l_lp_enrollment_ids || '^' || rec1.lp_enrollment_id;

                end if;
            END IF;
        ELSIF p_no_of_completed_courses < rec1.no_of_mandatory_courses AND rec1.path_status_code = 'COMPLETED' THEN
            l_path_status_code := 'ACTIVE';
        END IF;

              OPEN csr_lpe_update(rec1.lp_enrollment_id);
              FETCH csr_lpe_update into l_object_version_number;
              IF csr_lpe_update%FOUND then
			     CLOSE csr_lpe_update;
                 IF l_path_status_code = 'COMPLETED' THEN
                    --l_completion_date := sysdate;
                    l_completion_date := get_lp_completion_date(rec1.lp_enrollment_id);
                 ELSE
                    l_completion_date := null;
                 END IF;
                 ota_lp_enrollment_api.update_lp_enrollment
                            (p_effective_date               => sysdate
                            ,p_lp_enrollment_id             => rec1.lp_enrollment_id
                            ,p_object_version_number        => l_object_version_number
                            ,p_path_status_code             => l_path_status_code
                            ,p_no_of_completed_courses      => p_no_of_completed_courses
                            ,p_completion_date              => l_completion_date);

              ELSE
                  CLOSE csr_lpe_update;
         END IF;
     END LOOP;
     p_lp_enrollment_ids := l_lp_enrollment_ids;
END Update_lpe_lme_change;

-- ----------------------------------------------------------------------------
-- |----------------------<create_talent_mgmt_lpm>-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_talent_mgmt_lpm
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_business_group_id            IN     NUMBER
  ,p_learning_path_id             IN     NUMBER    DEFAULT NULL
  ,p_lp_enrollment_id             IN     NUMBER    DEFAULT NULL
  ,p_learning_path_section_id     IN     NUMBER    DEFAULT NULL
  ,p_path_name		          IN     VARCHAR2  DEFAULT NULL
  ,p_path_purpose                 IN     VARCHAR2  DEFAULT NULL
  ,p_path_status_code             IN     VARCHAR2
  ,p_path_start_date_active       IN     DATE DEFAULT NULL
  ,p_path_end_date_active         IN     DATE      DEFAULT NULL
  ,p_source_function_code	  IN     VARCHAR2
  ,p_assignment_id		  IN 	 NUMBER    DEFAULT NULL
  ,p_source_id		   	  IN 	 NUMBER    DEFAULT NULL
  ,p_creator_person_id		  IN 	 NUMBER
  ,p_person_id			  IN     NUMBER
  ,p_display_to_learner_flag      IN     VARCHAR2
  ,p_activity_version_id          IN     NUMBER
  ,p_course_sequence              IN     NUMBER
  ,p_member_status_code	          IN     VARCHAR2  DEFAULT NULL
  ,p_completion_target_date       IN     DATE
  ,p_notify_days_before_target	  IN 	 NUMBER
  ,p_object_version_NUMBER        OUT NOCOPY NUMBER
  ,p_return_status                OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_learning_path_id             ota_learning_paths.learning_path_id%TYPE := p_learning_path_id;
  l_lp_enrollment_id             ota_lp_enrollments.lp_enrollment_id%TYPE;
  l_learning_path_section_id     ota_lp_sections.learning_path_section_id%TYPE;
  l_learning_path_member_id      ota_learning_path_members.learning_path_member_id%TYPE;
  l_lp_member_enrollment_id      ota_lp_member_enrollments.lp_member_enrollment_id%TYPE;

  l_lp_ovn                       number;
  l_lpe_ovn                      number;
  l_lpc_ovn                      number;
  l_lpm_ovn                      number;
  l_lme_ovn                      number;

  l_lp_rtn_status                varchar2(30);
  l_lpe_rtn_status               varchar2(30);
  l_lpc_rtn_status               varchar2(30);
  l_lpm_rtn_status               varchar2(30);
  l_lme_rtn_status               varchar2(30);
  l_member_status_code           varchar2(30) := p_member_status_code;
  l_exists                       boolean;

  l_proc                         varchar2(72) := g_package ||'create_talent_mgmt_lpm';
  l_path_source_code             ota_learning_paths.path_source_code%TYPE;
  l_path_name                    ota_lp_sections_tl.name%TYPE := p_path_name;

  CURSOR csr_get_lp IS
  SELECT lps.learning_path_id,
         lpe.lp_enrollment_id,
         lpc.learning_path_section_id
    FROM ota_learning_paths  lps,
         ota_lp_enrollments lpe,
         ota_lp_sections lpc
   WHERE lps.learning_path_id = lpe.learning_path_id
     AND lpc.learning_path_id = lps.learning_path_id
     AND lps.path_source_code = 'TALENT_MGMT'
     AND lps.source_function_code = p_source_function_code
     AND (p_source_id IS NULL OR (p_source_id IS NOT NULL AND lps.source_id = p_source_id))
     AND (p_assignment_id IS NULL OR (p_assignment_id IS NOT NULL AND lps.assignment_id = p_assignment_id));

  CURSOR csr_get_lpe IS
  SELECT lp_enrollment_id
    FROM ota_lp_enrollments
   WHERE learning_path_id = l_learning_path_id
     AND person_id = p_person_id;

  CURSOR csr_get_lpc IS
  SELECT learning_path_section_id
    FROM ota_lp_sections
   WHERE learning_path_id = l_learning_path_id
     AND completion_type_code = 'M';

  CURSOR csr_get_lpm IS
  SELECT learning_path_member_id
    FROM ota_learning_path_members
   WHERE learning_path_section_id = l_learning_path_section_id
     AND activity_version_id = p_activity_version_id;

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT create_talent_mgmt_lpm;

  --
  -- Check if the call is from SSHR - Appraisal / Suitability Matching / Succession Planning
  --

      -- SSHR call should have person Id. Mandatory check for personId.
      hr_api.mandatory_arg_error
          (p_api_name       =>  l_proc
          ,p_argument       => 'p_person_id'
          ,p_argument_value =>  p_person_id
          );
      IF p_learning_path_id IS NULL THEN
          OPEN csr_get_lp;
         FETCH csr_get_lp INTO l_learning_path_id,
                               l_lp_enrollment_id,
                               l_learning_path_section_id;
               l_exists := csr_get_lp%FOUND;
         CLOSE csr_get_lp;
      ELSE
          l_learning_path_id := p_learning_path_id;
          l_lp_enrollment_id := p_lp_enrollment_id;
          l_learning_path_section_id := p_learning_path_section_id;
      END IF;

          IF NOT l_exists THEN
             ota_learning_path_swi.create_learning_path
          (p_effective_date               => 	p_effective_date
          ,p_validate                     =>	p_validate
     	      ,p_path_name                    =>	l_path_name
	    ,p_business_group_id            =>	p_business_group_id
	    ,p_duration                     =>	null
    	      ,p_duration_units               => 	null
	    ,p_start_date_active            =>    NVL(p_path_start_date_active, trunc(sysdate))
	    ,p_end_date_active              =>	p_path_end_date_active
    	      ,p_description                  => 	null
	    ,p_objectives           	  =>    null
    	      ,p_keywords                     =>    null
	    ,p_purpose                      =>    p_path_purpose
    	      ,p_path_source_code             =>    'TALENT_MGMT'
	    ,p_source_function_code         =>    p_source_function_code
    	      ,p_assignment_id                =>    p_assignment_id
	     ,p_source_id                    =>    p_source_id
    	      ,p_notify_days_before_target    =>    null
	    ,p_person_id                    =>    p_person_id
    	      ,p_display_to_learner_flag      =>    p_display_to_learner_flag
  	    ,p_learning_path_id             =>    l_learning_path_id
    	      ,p_object_version_number        =>    l_lp_ovn
	    ,p_return_status                =>    l_lp_rtn_status
          );

  l_learning_path_id := ota_lrng_path_util.get_talent_mgmt_lp
                                  (p_person_id            => p_person_id
                                  ,p_source_function_code => p_source_function_code
                                  ,p_source_id            => p_source_id
                                  ,p_assignment_id        => p_assignment_id
                                  ,p_business_group_id    => p_business_group_id);


          -- If Learning Path is not created, rollback and return
           if (l_lp_rtn_status  = 'E') then
              ROLLBACK TO create_talent_mgmt_lpm;
              p_object_version_number        := NULL;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;

         ota_lp_enrollment_swi.create_lp_enrollment
          (p_effective_date               => 	p_effective_date
          ,p_validate                     => 	p_validate
          ,p_learning_path_id             =>    l_learning_path_id
          ,p_person_id                    =>    p_person_id
          ,p_path_status_code             =>    p_path_status_code
          ,p_enrollment_source_code       =>	'TALENT_MGMT'
          ,p_completion_target_date       =>    p_completion_target_date
          ,p_creator_person_id            =>    p_creator_person_id
          ,p_business_group_id            =>    p_business_group_id
          ,p_lp_enrollment_id             =>    l_lp_enrollment_id
          ,p_object_version_number        =>    l_lpe_ovn
          ,p_return_status                =>    l_lpe_rtn_status
          );

           OPEN csr_get_lpe;
          FETCH csr_get_lpe INTO l_lp_enrollment_id;
          CLOSE csr_get_lpe;


          -- If Learning Path enrollment is not created, rollback and return
           if (l_lpe_rtn_status  = 'E') then
              ROLLBACK TO create_talent_mgmt_lpm;
              p_object_version_number        := NULL;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;

         ota_lp_section_swi.create_lp_section
          (p_validate                     => 	p_validate
          ,p_effective_date               => 	p_effective_date
          ,p_business_group_id            => 	p_business_group_id
          ,p_section_name  	   	  =>    l_path_name
          ,p_learning_path_id             =>    l_learning_path_id
          ,p_section_sequence		  =>    1
          ,p_completion_type_code         =>    'M'
          ,p_learning_path_section_id     =>    l_learning_path_section_id
          ,p_object_version_number        =>    l_lpc_ovn
          ,p_return_status                =>    l_lpc_rtn_status
          );

           OPEN csr_get_lpc;
          FETCH csr_get_lpc INTO l_learning_path_section_id;
          CLOSE csr_get_lpc;


          -- If Learning Path section is not created, rollback and return
           if (l_lpc_rtn_status  = 'E') then
              ROLLBACK TO create_talent_mgmt_lpm;
              p_object_version_number        := NULL;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;
        END IF;

          ota_lp_member_swi.create_learning_path_member
          (p_validate                     => 	p_validate
          ,p_effective_date               => 	p_effective_date
          ,p_business_group_id            => 	p_business_group_id
          ,p_learning_path_id             =>    l_learning_path_id
          ,p_activity_version_id          =>    p_activity_version_id
          ,p_course_sequence              =>    p_course_sequence
          ,p_learning_path_section_id     =>    l_learning_path_section_id
          ,p_notify_days_before_target    =>    p_notify_days_before_target
          ,p_learning_path_member_id      =>    l_learning_path_member_id
          ,p_object_version_number        =>    l_lpm_ovn
          ,p_return_status                =>    l_lpm_rtn_status
          );

           OPEN csr_get_lpm;
          FETCH csr_get_lpm INTO l_learning_path_member_id;
          CLOSE csr_get_lpm;


          -- If Learning Path member is not created, rollback and return
           if (l_lpm_rtn_status  = 'E') then
              ROLLBACK TO create_talent_mgmt_lpm;
              p_object_version_number        := NULL;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;


          ota_lp_member_enrollment_swi.create_lp_member_enrollment
          (p_effective_date               => 	p_effective_date
          ,p_validate                     => 	p_validate
          ,p_lp_enrollment_id             => 	l_lp_enrollment_id
          ,p_learning_path_section_id     =>    l_learning_path_section_id
          ,p_learning_path_member_id      =>    l_learning_path_member_id
          ,p_member_status_code           =>    p_member_status_code
          ,p_completion_target_date       =>    p_completion_target_date
          ,p_business_group_id            => 	p_business_group_id
          ,p_lp_member_enrollment_id      =>    l_lp_member_enrollment_id
          ,p_object_version_number        =>    l_lme_ovn
          ,p_return_status                =>    l_lme_rtn_status
          );


  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO create_talent_mgmt_lpm;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_NUMBER        := NULL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO create_talent_mgmt_lpm;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_NUMBER        := NULL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END create_talent_mgmt_lpm;

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |----------------------<update_talent_mgmt_lp >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_talent_mgmt_lp
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_mode                         IN     VARCHAR2
  ,p_learning_path_id             IN     NUMBER    DEFAULT NULL
  ,p_lp_enrollment_id             IN     NUMBER    DEFAULT NULL
  ,p_source_function_code	  IN     VARCHAR2
  ,p_assignment_id		  IN 	 NUMBER    DEFAULT NULL
  ,p_source_id		   	  IN 	 NUMBER    DEFAULT NULL
  ,p_person_id			  IN     NUMBER
  ,p_display_to_learner_flag      IN     VARCHAR2
  ,p_lps_ovn                      IN OUT NOCOPY NUMBER
  ,p_lpe_ovn                      IN OUT NOCOPY NUMBER
  ,p_return_status                OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_path_status_code             ota_lp_enrollments.path_status_code%TYPE;
  l_member_status_code           ota_lp_member_enrollments.member_status_code%TYPE;

  l_learning_path_id             ota_learning_paths.learning_path_id%TYPE := p_learning_path_id;
  l_lp_enrollment_id             ota_lp_enrollments.lp_enrollment_id%TYPE;
  l_lp_member_enrollment_id      ota_lp_member_enrollments.lp_member_enrollment_id%TYPE;
  l_no_of_mandatory_courses      ota_lp_enrollments.no_of_mandatory_courses%TYPE;
  l_no_of_completed_courses      ota_lp_enrollments.no_of_completed_courses%TYPE;
  l_completion_date              ota_lp_enrollments.completion_date%TYPE := null;

  l_lp_ovn                       number;
  l_lpe_ovn                      number;
  l_lme_ovn                      number;

  l_lp_rtn_status                varchar2(30);
  l_lpe_rtn_status               varchar2(30);
  l_lme_rtn_status               varchar2(30);

  l_proc                         varchar2(72) := g_package ||'update_talent_mgmt_lp';

  CURSOR csr_get_lp IS
  SELECT lps.learning_path_id,
         lps.object_version_number lps_ovn,
         lpe.lp_enrollment_id,
         lpe.object_version_number lpe_ovn
    FROM ota_learning_paths  lps,
         ota_lp_enrollments lpe
   WHERE lps.learning_path_id = lpe.learning_path_id
     AND lps.path_source_code = 'TALENT_MGMT'
     AND lps.source_function_code = p_source_function_code
     AND (p_source_id IS NULL OR (p_source_id IS NOT NULL AND lps.source_id = p_source_id))
     AND (p_assignment_id IS NULL OR (p_assignment_id IS NOT NULL AND lps.assignment_id = p_assignment_id));

  CURSOR csr_get_appr_lme IS
  SELECT lme.lp_member_enrollment_id,
         lme.object_version_number,
         lme.learning_path_member_id,
         lme.lp_enrollment_id
    FROM ota_lp_member_enrollments lme,
         ota_learning_path_members lpm
   WHERE lme.learning_path_member_id = lpm.learning_path_member_id
     AND lpm.learning_path_id = l_learning_path_id
     AND lme.member_status_code = 'AWAITING_APPROVAL';

  CURSOR csr_get_cncl_lme IS
  SELECT lme.lp_member_enrollment_id,
         lme.object_version_number
    FROM ota_lp_member_enrollments lme,
         ota_learning_path_members lpm
   WHERE lme.learning_path_member_id = lpm.learning_path_member_id
     AND lpm.learning_path_id = l_learning_path_id
     AND lme.member_status_code <> 'CANCELLED';

   CURSOR csr_get_lpe_dtls(lp_id NUMBER, lpe_id NUMBER) IS
   SELECT ota_lrng_path_util.get_no_of_mandatory_courses(lp_id,'TALENT_MGMT') mandatory_courses,
          ota_lrng_path_util.get_no_of_completed_courses(lpe_id,'TALENT_MGMT') completed_courses
     FROM dual;


BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT update_talent_mgmt_lp;

  --
  -- Check if the call is from SSHR - Appraisal / Suitability Matching / Succession Planning
  --

      -- SSHR call should have person Id. Mandatory check for personId.
      hr_api.mandatory_arg_error
          (p_api_name       =>  l_proc
          ,p_argument       => 'p_person_id'
          ,p_argument_value =>  p_person_id
          );
      IF p_learning_path_id IS NULL THEN
          OPEN csr_get_lp;
         FETCH csr_get_lp INTO l_learning_path_id,
                               l_lp_ovn,
                               l_lp_enrollment_id,
                               l_lpe_ovn;
         CLOSE csr_get_lp;
      ELSE
          l_learning_path_id := p_learning_path_id;
          l_lp_enrollment_id := p_lp_enrollment_id;
          l_lp_ovn := p_lps_ovn;
          l_lpe_ovn := p_lpe_ovn;
      END IF;


    IF p_mode = 'APPROVED' THEN
       l_path_status_code := 'ACTIVE';
  ELSE l_path_status_code := 'CANCELLED';
   END IF;

         ota_learning_path_swi.update_learning_path
          (p_effective_date               => 	p_effective_date
          ,p_learning_path_id             =>    l_learning_path_id
          ,p_object_version_number        =>    l_lp_ovn
          ,p_display_to_learner_flag      =>    p_display_to_learner_flag
          ,p_validate                     =>	p_validate
          ,p_return_status                =>    l_lp_rtn_status
          );


          -- If Learning Path is not updated, rollback and return
           if (l_lp_rtn_status  = 'E') then
              ROLLBACK TO update_talent_mgmt_lp;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;

         ota_lp_enrollment_swi.update_lp_enrollment
          (p_effective_date               => 	p_effective_date
          ,p_lp_enrollment_id             =>    l_lp_enrollment_id
          ,p_object_version_number        =>    l_lpe_ovn
          ,p_path_status_code             =>    l_path_status_code
          ,p_return_status                =>    l_lpe_rtn_status
          );

          -- If Learning Path enrollment is not created, rollback and return
           if (l_lpe_rtn_status  = 'E') then
              ROLLBACK TO update_talent_mgmt_lp;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;

      IF p_mode = 'APPROVED' THEN
         l_member_status_code := 'PLANNED';

          FOR appr_rec IN csr_get_appr_lme
         LOOP

              l_lme_ovn := appr_rec.object_version_number;

              ota_lp_member_enrollment_swi.update_lp_member_enrollment
               (p_effective_date               =>    p_effective_date
               ,p_lp_member_enrollment_id      =>    appr_rec.lp_member_enrollment_id
               ,p_lp_enrollment_id             =>    appr_rec.lp_enrollment_id
               ,p_learning_path_member_id      =>    appr_rec.learning_path_member_id
               ,p_object_version_number        =>    l_lme_ovn
               ,p_validate                     =>    p_validate
               ,p_member_status_code           =>    l_member_status_code
               ,p_return_status                =>    l_lme_rtn_status
               );

               if (l_lme_rtn_status  = 'E') then
                  ROLLBACK TO update_talent_mgmt_lp;
                  p_return_status := hr_multi_message.get_return_status_disable;
                  return;
              end if;

          END LOOP;

          OPEN csr_get_lpe_dtls(l_learning_path_id, l_lp_enrollment_id);
         FETCH csr_get_lpe_dtls INTO l_no_of_mandatory_courses,
                                     l_no_of_completed_courses;
         CLOSE csr_get_lpe_dtls;

             IF l_no_of_mandatory_courses = l_no_of_completed_courses THEN
                l_path_status_code := 'COMPLETED';
                l_completion_date := get_lp_completion_date(l_lp_enrollment_id);
            END IF;


         ota_lp_enrollment_swi.update_lp_enrollment
          (p_effective_date               => 	p_effective_date
          ,p_lp_enrollment_id             =>    l_lp_enrollment_id
          ,p_object_version_number        =>    l_lpe_ovn
          ,p_no_of_mandatory_courses      =>    l_no_of_mandatory_courses
          ,p_no_of_completed_courses      =>    l_no_of_completed_courses
          ,p_path_status_code             =>    l_path_status_code
          ,p_completion_date              =>    l_completion_date
          ,p_return_status                =>    l_lpe_rtn_status
          );


          -- If Learning Path enrollment is not created, rollback and return
           if (l_lpe_rtn_status  = 'E') then
              ROLLBACK TO update_talent_mgmt_lp;
              p_return_status := hr_multi_message.get_return_status_disable;
              return;
          end if;



    ELSE

              l_member_status_code := 'CANCELLED';

          FOR cncl_rec IN csr_get_cncl_lme
         LOOP
              l_lme_ovn := cncl_rec.object_version_number;

              ota_lp_member_enrollment_swi.update_lp_member_enrollment
               (p_effective_date               =>    p_effective_date
               ,p_lp_member_enrollment_id      =>    cncl_rec.lp_member_enrollment_id
               ,p_object_version_number        =>    l_lme_ovn
               ,p_validate                     =>    p_validate
               ,p_member_status_code           =>    l_member_status_code
               ,p_return_status                =>    l_lme_rtn_status
               );

               if (l_lme_rtn_status  = 'E') then
                  ROLLBACK TO update_talent_mgmt_lp;
                  p_return_status := hr_multi_message.get_return_status_disable;
                  return;
              end if;

         END LOOP;
     END IF;

  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO update_talent_mgmt_lp;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO update_talent_mgmt_lp;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END update_talent_mgmt_lp;
-- ----------------------------------------------------------------------------
-- |-------------------< chk_no_of_mandatory_courses >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_no_of_mandatory_courses
  (p_learning_path_member_id    IN     ota_learning_path_members.learning_path_member_id%TYPE
   , p_return_status OUT  NOCOPY VARCHAR2)
  IS
--
  l_proc  VARCHAR2(72) :=      g_package|| 'chk_no_of_mandatory_courses';
  l_exists VARCHAR2(1);
  l_lpm_count          NUMBER;
  l_lpc_id             ota_lp_sections.learning_path_section_id%TYPE;
  l_mandatory_courses  ota_lp_sections.no_of_mandatory_courses%TYPE;
--
CURSOR get_section_info IS
SELECT lpm.learning_path_section_id,
       lpc.no_of_mandatory_courses
  FROM ota_learning_path_members lpm,
       ota_lp_sections lpc
 WHERE lpm.learning_path_section_id = lpc.learning_path_section_id
   AND lpc.completion_type_code = 'S'
   AND lpm.learning_path_member_id = p_learning_path_member_id;

CURSOR get_lpm_count IS
SELECT count(learning_path_member_id)
  FROM ota_learning_path_members
 WHERE learning_path_section_id = l_lpc_id;

BEGIN
  --


  hr_utility.set_location(' Step:'|| l_proc, 30);


    p_return_status := 'S';
  OPEN get_section_info;
 FETCH get_section_info INTO l_lpc_id, l_mandatory_courses;
        IF get_section_info%FOUND THEN
            OPEN get_lpm_count;
           FETCH get_lpm_count INTO l_lpm_count;
           CLOSE get_lpm_count;
                  IF l_lpm_count <= l_mandatory_courses THEN
                     p_return_status := 'E';
                 --    fnd_message.set_name('OTA', 'OTA_13076_LPC_MNDTRY_ACT_ERR');
                 --    fnd_message.raise_error;
                 END IF;
       END IF;
 CLOSE get_section_info;

  hr_utility.set_location(' Leaving:'||l_proc, 90);
END chk_no_of_mandatory_courses;

FUNCTION get_class_completion_date(p_event_id IN ota_events.event_id%type,
  			                       p_person_id	IN	NUMBER,
                                   p_contact_id IN ota_attempts.user_type%type)
RETURN DATE IS

 CURSOR class_type IS
 SELECT ocu.synchronous_flag,
       ocu.online_flag
 FROM ota_events oev,
     ota_offerings ofr,
     ota_category_usages ocu
 WHERE oev.parent_offering_id = ofr.offering_id
 AND ocu.category_usage_Id = ofr.delivery_mode_id
 AND oev.event_id = p_event_id;

 CURSOR get_online_compl_date_p(p_event_id IN ota_events.event_id%type,
                                        p_user_id	IN	ota_attempts.user_id%type,
                                        p_user_type IN ota_attempts.user_type%type) IS
 SELECT ota_timezone_util.get_dateDT(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), ocu.Online_Flag, ota_timezone_util.get_server_timezone_code) completion_date
 FROM ota_events oev,
      ota_offerings ofr,
      ota_performances opf,
      ota_category_usages ocu,
      ota_delegate_bookings odb,
      ota_booking_status_types obst
 WHERE oev.parent_offering_id = ofr.offering_id
 AND ofr.learning_object_id = opf.learning_object_id
 AND ocu.category_usage_Id = ofr.delivery_mode_id
 AND opf.completed_date is not null
 AND oev.event_id = p_event_id
 AND opf.User_id = p_user_id
 AND opf.User_type = p_user_type
 AND odb.booking_status_type_id = obst.booking_status_type_id
 AND obst.type = 'A'
 AND odb.delegate_person_id = p_person_id
 AND oev.event_id = odb.event_id;

 CURSOR get_online_compl_date_c(p_event_id IN ota_events.event_id%type,
                                        p_user_id	IN	ota_attempts.user_id%type,
                                        p_user_type IN ota_attempts.user_type%type) IS
 SELECT ota_timezone_util.get_dateDT(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), ocu.Online_Flag, ota_timezone_util.get_server_timezone_code) completion_date
 FROM ota_events oev,
      ota_offerings ofr,
      ota_performances opf,
      ota_category_usages ocu,
      ota_delegate_bookings odb,
      ota_booking_status_types obst
 WHERE oev.parent_offering_id = ofr.offering_id
 AND ofr.learning_object_id = opf.learning_object_id
 AND ocu.category_usage_Id = ofr.delivery_mode_id
 AND opf.completed_date is not null
 AND oev.event_id = p_event_id
 AND opf.User_id = p_user_id
 AND opf.User_type = p_user_type
 AND odb.booking_status_type_id = obst.booking_status_type_id
 AND obst.type = 'A'
 AND odb.delegate_contact_id = p_contact_id
 AND oev.event_id = odb.event_id;

 CURSOR get_offsync_class_compl_date_p IS
 SELECT to_date(to_char(nvl(oev.course_end_date,trunc(sysdate)),'YYYY/MM/DD') || ' ' || nvl(oev.course_end_time,'23:59'), 'YYYY MM/DD HH24:MI') event_end_date
 FROM ota_events oev,
      ota_delegate_bookings odb,
      ota_booking_status_types obst
 WHERE oev.event_id = p_event_id
 AND oev.event_id = odb.event_id
 AND odb.booking_status_type_id = obst.booking_status_type_id
 AND obst.type = 'A'
 AND odb.delegate_person_id = p_person_id;

 CURSOR get_offsync_class_compl_date_c IS
 SELECT to_date(to_char(nvl(oev.course_end_date,trunc(sysdate)),'YYYY/MM/DD') || ' ' || nvl(oev.course_end_time,'23:59'), 'YYYY MM/DD HH24:MI') event_end_date
 FROM ota_events oev,
      ota_delegate_bookings odb,
      ota_booking_status_types obst
 WHERE oev.event_id = p_event_id
 AND oev.event_id = odb.event_id
 AND odb.booking_status_type_id = obst.booking_status_type_id
 AND obst.type = 'A'
 AND odb.delegate_contact_id = p_contact_id;

 CURSOR get_offasync_compl_date_p IS
 SELECT odb.date_status_changed
 FROM ota_delegate_bookings odb,
     ota_booking_status_types obst
 WHERE odb.booking_status_type_id = obst.booking_status_type_id
 AND obst.type = 'A'
 AND odb.delegate_person_id = p_person_id
 AND odb.event_id = p_event_id;

 CURSOR get_offasync_compl_date_c IS
 SELECT odb.date_status_changed
 FROM ota_delegate_bookings odb,
     ota_booking_status_types obst
 WHERE odb.booking_status_type_id = obst.booking_status_type_id
 AND obst.type = 'A'
 AND odb.delegate_contact_id = p_contact_id
 AND odb.event_id = p_event_id;

 l_sync_flag ota_category_usages.synchronous_flag%type;
 l_online_flag ota_category_usages.online_flag%type;
 l_completion_date date:= null;
 l_user_id	ota_attempts.user_id%type;
 l_user_type ota_attempts.user_type%type;

BEGIN

 OPEN class_type;
 FETCH class_type into l_sync_flag, l_online_flag;
 CLOSE class_type;

 if(l_online_flag = 'Y') then
    --get the compeltion date from ota_performances
    l_user_id := nvl(p_person_id, p_contact_id);
    if(p_person_id is not null) then
        l_user_type := 'E';

        OPEN get_online_compl_date_p(p_event_id, l_user_id, l_user_type);
        FETCH get_online_compl_date_p into l_completion_date;
        CLOSE get_online_compl_date_p;

    else
        l_user_type := 'C';

        OPEN get_online_compl_date_c(p_event_id, l_user_id, l_user_type);
        FETCH get_online_compl_date_c into l_completion_date;
        CLOSE get_online_compl_date_c;

    end if;

 elsif(l_online_flag = 'N' and l_sync_flag = 'Y') then
    --get the end date of the class as compeltion date
    if(p_person_id is not null) then
        OPEN get_offsync_class_compl_date_p;
        FETCH get_offsync_class_compl_date_p into l_completion_date;
        CLOSE get_offsync_class_compl_date_p;
    else
        OPEN get_offsync_class_compl_date_c;
        FETCH get_offsync_class_compl_date_c into l_completion_date;
        CLOSE get_offsync_class_compl_date_c;
     end if;

 elsif(l_online_flag = 'N' and l_sync_flag = 'N') then
    --get the date_status_changed of the class as compeltion date
    if(p_person_id is not null) then
        OPEN get_offasync_compl_date_p;
        FETCH get_offasync_compl_date_p into l_completion_date;
        CLOSE get_offasync_compl_date_p;
    else
        OPEN get_offasync_compl_date_c;
        FETCH get_offasync_compl_date_c into l_completion_date;
        CLOSE get_offasync_compl_date_c;
    end if;
 end if;

 RETURN l_completion_date;

END get_class_completion_date;

FUNCTION get_lp_completion_date(p_lp_enrollment_id ota_lp_enrollments.lp_enrollment_id%TYPE)
RETURN DATE IS

 CURSOR get_completion_date IS
 SELECT max(ota_lrng_path_member_util.get_class_completion_date(oev.event_id,lpe.person_id, lpe.contact_id)) completion_date
 FROM ota_lp_enrollments lpe,
     ota_learning_path_members lpm,
     ota_events oev
 WHERE lpe.learning_path_id = lpm.learning_path_id
 AND oev.activity_version_id = lpm.activity_version_id
 AND lpe.lp_enrollment_id = p_lp_enrollment_id;

 l_completion_date date := null;

BEGIN
    if(ota_lrng_path_util.chk_complete_path_ok(p_lp_enrollment_id) = 'S') then
        OPEN get_completion_date;
        FETCH get_completion_date into l_completion_date;
        CLOSE get_completion_date;
    end if;

    RETURN l_completion_date;

END get_lp_completion_date;

FUNCTION get_lpm_completion_date(p_lp_member_enrollment_id ota_lp_member_enrollments.lp_member_enrollment_id%TYPE,
                                 p_activity_version_id ota_activity_versions.activity_version_id%TYPE,
                                 p_person_id  ota_lp_enrollments.person_id%TYPE,
			                     p_contact_id ota_lp_enrollments.contact_id%TYPE)
RETURN DATE IS

 CURSOR get_lpm_completion_date IS
 SELECT max(ota_lrng_path_member_util.get_class_completion_date(oev.event_id,lpe.person_id, lpe.contact_id)) completion_date
 FROM ota_lp_enrollments lpe,
     ota_learning_path_members lpm,
     ota_lp_member_enrollments lpme,
     ota_events oev
 WHERE lpe.learning_path_id = lpm.learning_path_id
 AND oev.activity_version_id = lpm.activity_version_id
 AND lpe.lp_enrollment_id = lpme.lp_enrollment_id
 AND lpme.learning_path_member_id = lpm.learning_path_member_id
 AND lpme.lp_member_enrollment_id = p_lp_member_enrollment_id;

 CURSOR get_crs_completion_date IS
 SELECT max(ota_lrng_path_member_util.get_class_completion_date(oev.event_id,p_person_id, p_contact_id)) completion_date
 FROM ota_events oev
 WHERE oev.activity_version_id = p_activity_version_id;

 l_completion_date date := null;

BEGIN
    if(p_lp_member_enrollment_id is not null) then
        OPEN get_lpm_completion_date;
        FETCH get_lpm_completion_date into l_completion_date;
        CLOSE get_lpm_completion_date;
    elsif (p_activity_version_id is not null) then
        OPEN get_crs_completion_date;
        FETCH get_crs_completion_date into l_completion_date;
        CLOSE get_crs_completion_date;
    end if;

    RETURN l_completion_date;

END get_lpm_completion_date;

END ota_lrng_path_member_util;


/
