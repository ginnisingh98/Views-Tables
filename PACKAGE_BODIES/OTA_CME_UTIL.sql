--------------------------------------------------------
--  DDL for Package Body OTA_CME_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CME_UTIL" as
/* $Header: otcmewrs.pkb 120.14.12010000.2 2008/11/07 09:35:18 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= '  OTA_CME_UTIL.';  -- Global package name
--
CURSOR get_enrl_status(csr_activity_version_id    IN ota_activity_versions.activity_version_id%TYPE,
                       csr_cert_period_start_date in ota_cert_prd_enrollments.cert_period_start_date%type,
                       csr_cert_period_end_date in ota_cert_prd_enrollments.cert_period_end_date%type,
                       csr_person_id in ota_cert_enrollments.person_id%TYPE,
                       csr_contact_id in ota_cert_enrollments.contact_id%TYPE) IS
SELECT DECODE(bst.type,'C','Z',bst.type) status,
       evt.event_type,
       tdb.DATE_STATUS_CHANGED,
       evt.COURSE_START_DATE,
       evt.COURSE_END_DATE
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   and (
   --sync sched, online(conf) or offline(ILT)
   --sync always have an end date
      ( evt.event_type = 'SCHEDULED' and
        evt.course_start_date >= csr_cert_period_start_date and
          evt.course_end_date <= csr_cert_period_end_date )
       or
   --async selfpaced, online(selfp) or offline(CBT)
   --async have opt end date
   (event_type ='SELFPACED'  and
     (csr_cert_period_end_date >= evt.course_start_date) AND
       ((evt.course_end_date is null) or
        (evt.course_end_date IS NOT NULL AND evt.course_end_date >= csr_cert_period_start_date))))
   AND evt.activity_version_id = csr_activity_version_id
    AND ((csr_person_id IS NOT NULL AND tdb.delegate_person_id = csr_person_id)
                   OR (csr_contact_id IS NOT NULL AND tdb.delegate_contact_id = csr_contact_id)
                 )
    order by status;
--

PROCEDURE get_enrl_status_on_update(p_activity_version_id    IN ota_activity_versions.activity_version_id%TYPE,
                               p_cert_prd_enrollment_id  IN ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
			       p_booking_status_type     OUT NOCOPY ota_booking_status_types.type%TYPE,
                               p_date_status_changed     OUT NOCOPY ota_delegate_bookings.date_status_changed%TYPE)
IS

CURSOR csr_cert_enrl IS
SELECT cre.person_id, cre.contact_id, cpe.cert_period_start_date, cpe.cert_period_end_date
 FROM ota_cert_enrollments cre,
      ota_cert_prd_enrollments cpe
 where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id
   and cpe.cert_enrollment_id = cre.cert_enrollment_id;

l_proc       VARCHAR2(72) :=      g_package|| 'get_enrl_status_on_update';

l_person_id ota_cert_enrollments.person_id%TYPE;
l_contact_id ota_cert_enrollments.contact_id%TYPE;
l_cert_period_start_date ota_cert_prd_enrollments.cert_period_start_date%type;
l_cert_period_end_date ota_cert_prd_enrollments.cert_period_start_date%type;

l_enroll_status  VARCHAR2(30);
l_date_status_changed   ota_delegate_bookings.date_status_changed%TYPE;

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

    OPEN csr_cert_enrl;
    FETCH csr_cert_enrl into l_person_id, l_contact_id, l_cert_period_start_date, l_cert_period_end_date;
    CLOSE csr_cert_enrl;

    FOR rec_enr IN get_enrl_status(p_activity_version_id,
                                       l_cert_period_start_date,
                                       l_cert_period_end_date,
                                       l_person_id,
                                       l_contact_id)
    	LOOP
              l_enroll_status := rec_enr.status ;
              l_date_status_changed := rec_enr.date_status_changed;
             EXIT;
    END LOOP;


    p_booking_status_type := l_enroll_status;
    p_date_status_changed := l_date_status_changed;

    hr_utility.set_location(' Step:'|| l_proc, 20);
  --
EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,30);
     p_booking_status_type := null;
     p_date_status_changed := null;

END get_enrl_status_on_update;

--  ---------------------------------------------------------------------------
--  |----------------------< calculate_cme_status >-----------------------------|
--  ---------------------------------------------------------------------------
PROCEDURE calculate_cme_status(p_activity_version_id      IN ota_activity_versions.activity_version_id%TYPE,
                               p_cert_prd_enrollment_id   IN ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
                               p_mode in varchar2,
                               p_member_status_code       OUT nocopy VARCHAR2,
                               p_completion_date          OUT nocopy DATE)
 IS

 CURSOR csr_cert_enrl IS
SELECT cre.person_id, cre.contact_id, cpe.cert_period_start_date, cpe.cert_period_end_date
 FROM ota_cert_enrollments cre,
      ota_cert_prd_enrollments cpe
 where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id
   and cpe.cert_enrollment_id = cre.cert_enrollment_id;

 l_proc             VARCHAR2(72) :=      g_package|| 'calculate_cme_status';

l_person_id ota_cert_enrollments.person_id%TYPE;
l_contact_id ota_cert_enrollments.contact_id%TYPE;
l_cert_period_start_date ota_cert_prd_enrollments.cert_period_start_date%type;
l_cert_period_end_date ota_cert_prd_enrollments.cert_period_start_date%type;

l_enroll_status  VARCHAR2(30);
l_date_status_changed   ota_delegate_bookings.date_status_changed%TYPE;
l_event_type ota_events.event_type%type;
l_course_start_date ota_events.course_start_date%type;
l_course_end_date ota_events.course_end_date%type;

 BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 10);

    OPEN csr_cert_enrl;
    FETCH csr_cert_enrl into l_person_id, l_contact_id, l_cert_period_start_date, l_cert_period_end_date;
    CLOSE csr_cert_enrl;

 hr_utility.set_location('Entering:'|| l_proc, 20);

    FOR rec_enr IN get_enrl_status(p_activity_version_id,
                                   l_cert_period_start_date,
                                   l_cert_period_end_date,
                                   l_person_id,
                                   l_contact_id)
	LOOP
          l_enroll_status := rec_enr.status ;
          l_date_status_changed := rec_enr.date_status_changed;
          l_event_type := rec_enr.event_type;
          l_course_start_date := rec_enr.course_start_date;
          l_course_end_date := rec_enr.course_end_date;
         EXIT;
    END LOOP;

hr_utility.set_location('Entering:'|| l_proc, 30);

 if p_mode = 'C' then

     --don't consider past attended enrls during cert mbr enrl create
     -- enable selfpaced event enrl compl in the past as Active for next cert prd comps
     if l_enroll_status = 'A' and
          -- Bug 4515924 --rec_enr.event_type = 'SELFPACED' then
          (l_event_type = 'SELFPACED' AND
           ((l_cert_period_end_date >= l_course_start_date) AND
	            ((l_course_end_date is null) or
	            (l_course_end_date IS NOT NULL AND l_course_end_date >= l_cert_period_start_date))
          )) THEN
            p_member_status_code := 'ACTIVE';-- intreprit cme status as Active
            p_completion_date := null;
     ELSIF ( l_enroll_status='P'
	     OR l_enroll_status='W'
	     OR l_enroll_status ='R') THEN
        	p_member_status_code := 'ACTIVE';
        	p_completion_date    := null;
     ELSE
        	p_member_status_code := 'PLANNED';
        	p_completion_date    := null;
     END IF;

 elsif p_mode = 'U' then
      --consider attended enrls only during the cert prd start and end dates.
      IF ( l_enroll_status='A' ) THEN
          p_member_status_code := 'COMPLETED';
     	  p_completion_date    := l_date_status_changed;
      ELSIF ( l_enroll_status='P'
	      OR l_enroll_status='W'
	      OR l_enroll_status ='R') THEN
     	  p_member_status_code := 'ACTIVE';
 	      p_completion_date    := null;
      ELSE
    	 p_member_status_code := 'PLANNED';
	     p_completion_date    := null;
     END IF;
 end if;

 hr_utility.set_location('Step:'|| l_proc, 40);

 EXCEPTION
    WHEN others THEN
        hr_utility.set_location('LEAVING:'|| l_proc, 50);
        p_member_status_code := 'PLANNED';
        p_completion_date := null;
        RAISE;

END calculate_cme_status;


--  ---------------------------------------------------------------------------
--  |----------------------< update_cme_status >-------------------|
--  ---------------------------------------------------------------------------
PROCEDURE update_cme_status (p_event_id           IN ota_events.event_id%TYPE,
                                        p_person_id          IN ota_cert_enrollments.person_id%TYPE,
    				        p_contact_id         IN ota_cert_enrollments.contact_id%TYPE,
                                        p_cert_prd_enrollment_ids  OUT NOCOPY varchar2)
IS

l_proc  VARCHAR2(72) :=      g_package|| 'update_cme_status';

  CURSOR evt_det IS
    SELECT evt.activity_version_id,
           ocu.online_flag
      FROM ota_events evt,
           ota_offerings ofr,
           ota_category_usages ocu
     WHERE evt.event_id = p_event_id
       AND evt.parent_offering_id = ofr.offering_id
       AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID;


CURSOR csr_cme_info(csr_activity_version_id  number) IS
SELECT cme.cert_mbr_enrollment_id,
       cpe.cert_prd_enrollment_id,
       cme.object_version_number,
       cmb.certification_member_id,
       cme.member_status_code
  FROM ota_certification_members cmb,
       ota_cert_mbr_enrollments cme,
       ota_cert_prd_enrollments cpe,
       ota_cert_enrollments cre
 WHERE
        cre.cert_enrollment_id = cpe.cert_enrollment_id
    AND cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
    AND cme.cert_member_id = cmb.certification_member_id
    AND cmb.object_id = csr_activity_version_id
    AND (( p_person_id IS NOT NULL AND cre.person_id = p_person_id)
                OR (p_contact_id IS NOT NULL AND cre.contact_id = p_contact_id))
    AND cme.member_status_code <> 'CANCELLED'
    --pull only curr periods
    AND trunc(sysdate) between trunc(cpe.cert_period_start_date) and trunc(cpe.cert_period_end_date)
    -- don't consider expired prds
    AND cpe.period_status_code <> 'EXPIRED';

  l_activity_version_id  ota_activity_versions.activity_version_id%TYPE;
  l_online_flag ota_category_usages.online_flag%type;
  l_enroll_type          ota_booking_status_types.type%TYPE;
  l_member_status_code   ota_cert_mbr_enrollments.member_status_code%TYPE;
  l_completion_date      ota_cert_mbr_enrollments.completion_date%TYPE;
  l_date_status_changed  ota_delegate_bookings.date_status_changed%TYPE;

  --variables to store old values
  l_old_member_status           ota_cert_mbr_enrollments.member_status_code%TYPE;

  l_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE;
  l_cert_prd_enrollment_ids varchar2(4000) := '';

BEGIN

    hr_utility.set_location(' Step:'||l_proc,10);

    OPEN evt_det;
    FETCH evt_det
     INTO l_activity_version_id, l_online_flag;
    CLOSE evt_det;

        hr_utility.set_location(' Step:'|| l_proc, 20);


        FOR rec_cme_info IN csr_cme_info(l_activity_version_id)

            LOOP

              get_enrl_status_on_update(p_activity_version_id     => l_activity_version_id,
                               p_cert_prd_enrollment_id  => rec_cme_info.cert_prd_enrollment_id,
                               p_booking_status_type     => l_enroll_type,
                               p_date_status_changed     => l_date_status_changed);
              l_completion_date := null;

              IF l_enroll_type = 'A' THEN
                if l_online_flag = 'Y' then
                   --skip updating cme rollup, since player would update appr cme
                   exit;
                end if;
                l_member_status_code := 'COMPLETED';
                l_completion_date := l_date_status_changed;
              ELSIF ( l_enroll_type = 'P'
                  OR l_enroll_type = 'W'
                  OR l_enroll_type = 'R') THEN
                  l_member_status_code := 'ACTIVE';
              ELSE l_member_status_code := 'PLANNED';
              END IF;

              l_old_member_status        := rec_cme_info.member_status_code;

              IF l_old_member_status <> l_member_status_code THEN
                --call upd cme api after lck
	        ota_cert_mbr_enrollment_api.update_cert_mbr_enrollment
                        (p_effective_date           => sysdate
                        ,p_object_version_number    => rec_cme_info.object_version_number
                        ,p_cert_member_id           => rec_cme_info.certification_member_id
                        ,p_cert_prd_enrollment_id   => rec_cme_info.cert_prd_enrollment_id
                        ,p_cert_mbr_enrollment_id   => rec_cme_info.cert_mbr_enrollment_id
                        ,p_member_status_code       => l_member_status_code
                        ,p_completion_date          => l_completion_date);


                Update_cpe_status(rec_cme_info.cert_mbr_enrollment_id, l_cert_prd_enrollment_id);

                --populate OUT cert_prd_enrollment_ids params
		IF l_cert_prd_enrollment_id IS NOT NULL THEN
	          if l_cert_prd_enrollment_ids = '' or l_cert_prd_enrollment_ids is null then
	            l_cert_prd_enrollment_ids := l_cert_prd_enrollment_id;
	          else
	            l_cert_prd_enrollment_ids := l_cert_prd_enrollment_ids || '^' || l_cert_prd_enrollment_id;
  	          end if;
	        END IF;

              END IF;




            END LOOP;

    p_cert_prd_enrollment_ids := l_cert_prd_enrollment_ids;
     hr_utility.set_location(' Step:'||l_proc,30);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,40);
     p_cert_prd_enrollment_ids := null;
       --MULTI MESSAGE SUPPORT

END update_cme_status;

--  ---------------------------------------------------------------------------
--  |----------------------< Update_cpe_status >--------------------------|
--  ---------------------------------------------------------------------------
--
-- This procedure will get called when a cme is Updated or Cancelled
Procedure Update_cpe_status( p_cert_mbr_enrollment_id    IN ota_cert_mbr_enrollments.cert_mbr_enrollment_id%TYPE
                             ,p_cert_prd_enrollment_id    OUT NOCOPY varchar2
                             ,p_completion_date in date default sysdate)
is

CURSOR csr_cpe_cme
    IS
    SELECT cre.certification_id,
           cpe.cert_enrollment_id,
           cpe.cert_prd_enrollment_id,
           cpe.period_status_code
      FROM ota_cert_enrollments cre,
           ota_cert_prd_enrollments cpe,
           ota_cert_mbr_enrollments cme
     WHERE cre.cert_enrollment_id = cpe.cert_enrollment_id
       AND cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
       AND cpe.period_status_code not in ('CANCELLED', 'EXPIRED')
       AND cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id
       AND trunc(sysdate) between trunc(cpe.cert_period_start_date) and trunc(cpe.cert_period_end_date);

CURSOR csr_cpe_status(csr_cert_prd_enrollment_id number)
    IS
    SELECT cpe.period_status_code
      FROM ota_cert_prd_enrollments cpe
     WHERE cpe.cert_prd_enrollment_id = csr_cert_prd_enrollment_id;

/*
CURSOR csr_cpe_update(csr_cert_prd_enrollment_id number)
    IS
    SELECT cpe.object_version_number
      FROM ota_cert_prd_enrollments cpe
     WHERE cpe.cert_prd_enrollment_id = csr_cert_prd_enrollment_id;

CURSOR csr_cre_update(csr_cert_enrollment_id number)
    IS
    SELECT cre.object_version_number
      FROM ota_cert_enrollments cre
     where cre.cert_enrollment_id = csr_cert_enrollment_id;


--  l_exists                 	ota_cert_prd_enrollments.cert_mbr_enrollment_id%TYPE;
  cre_object_version_number  	ota_cert_enrollments.object_version_number%type;
  cpe_object_version_number  	ota_cert_prd_enrollments.object_version_number%type;
  l_period_status_code     	ota_cert_prd_enrollments.period_status_code%TYPE;
  l_certification_status_code 	ota_cert_enrollments.certification_status_code%TYPE;
  l_chk_cert_prd_compl varchar2(1);
  l_completion_date date;
*/
rec_cpe_status  csr_cpe_status%rowtype;
l_period_status_code     	ota_cert_prd_enrollments.period_status_code%TYPE;
l_certification_status_code 	ota_cert_enrollments.certification_status_code%TYPE;

  l_proc  VARCHAR2(72) :=      g_package|| 'Update_cpe_status';

l_child_update_flag varchar2(1) := 'N';
BEGIN
        hr_utility.set_location(' Step:'|| l_proc, 10);

    FOR rec_cpe_cme in csr_cpe_cme LOOP
        l_period_status_code := rec_cpe_cme.period_status_code;
         --update cpe rec
         ota_cpe_util.update_cpe_status(rec_cpe_cme.cert_prd_enrollment_id, l_certification_status_code, null, null, l_child_update_flag, p_completion_date);

         open csr_cpe_status(rec_cpe_cme.cert_prd_enrollment_id);
         fetch csr_cpe_status into rec_cpe_status;
         close csr_cpe_status;

         --check for status change and populate param out cert_prd_enrollment_id
         IF l_period_status_code <> rec_cpe_status.period_status_code THEN
            p_cert_prd_enrollment_id := rec_cpe_cme.cert_prd_enrollment_id;
         END IF;

     END LOOP;

    hr_utility.set_location(' Step:'|| l_proc, 20);
EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,30);
     p_cert_prd_enrollment_id := null;
       --MULTI MESSAGE SUPPORT

END Update_cpe_status;

--  ---------------------------------------------------------------------------
--  |----------------------< update_cme_status >------------------------------|
--  ---------------------------------------------------------------------------
PROCEDURE update_cme_status (p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
IS

l_proc  VARCHAR2(72) :=      g_package|| 'update_cme_status';


CURSOR csr_cme_info IS
SELECT cme.cert_mbr_enrollment_id,
       cme.cert_prd_enrollment_id,
       cme.object_version_number,
       cmb.object_id,
       cmb.certification_member_id,
       cme.member_status_code
  FROM ota_certification_members cmb,
       ota_cert_mbr_enrollments cme
 WHERE cme.cert_member_id = cmb.certification_member_id
    AND cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id;
    --AND cme.member_status_code <> 'CANCELLED';

  l_enroll_type          ota_booking_status_types.type%TYPE;
  l_member_status_code   ota_cert_mbr_enrollments.member_status_code%TYPE;
  l_completion_date      ota_cert_mbr_enrollments.completion_date%TYPE;
  l_date_status_changed  ota_delegate_bookings.date_status_changed%TYPE;

  --variables to store old values
  l_old_member_status           ota_cert_mbr_enrollments.member_status_code%TYPE;

  l_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE;
  l_cert_prd_enrollment_ids varchar2(4000) := '';

  rec_cme_info csr_cme_info%ROWTYPE;

BEGIN

        hr_utility.set_location(' Step:'||l_proc,10);

        open csr_cme_info;
        fetch csr_cme_info into rec_cme_info;
        close csr_cme_info;

        get_enrl_status_on_update(p_activity_version_id     => rec_cme_info.object_id,
                               p_cert_prd_enrollment_id  => rec_cme_info.cert_prd_enrollment_id,
                               p_booking_status_type     => l_enroll_type,
                               p_date_status_changed     => l_date_status_changed);
        l_completion_date := null;

        IF l_enroll_type = 'A' THEN
                l_member_status_code := 'COMPLETED';
                l_completion_date := l_date_status_changed;
        ELSIF ( l_enroll_type = 'P'
                  OR l_enroll_type = 'W'
                  OR l_enroll_type = 'R') THEN
                  l_member_status_code := 'ACTIVE';
        ELSE l_member_status_code := 'PLANNED';
        END IF;

        l_old_member_status        := rec_cme_info.member_status_code;

        IF l_old_member_status <> l_member_status_code THEN
                --call upd cme api after lck
	        ota_cert_mbr_enrollment_api.update_cert_mbr_enrollment
                        (p_effective_date           => sysdate
                        ,p_object_version_number    => rec_cme_info.object_version_number
                        ,p_cert_member_id           => rec_cme_info.certification_member_id
                        ,p_cert_prd_enrollment_id   => rec_cme_info.cert_prd_enrollment_id
                        ,p_cert_mbr_enrollment_id   => rec_cme_info.cert_mbr_enrollment_id
                        ,p_member_status_code       => l_member_status_code
                        ,p_completion_date          => l_completion_date);
        END IF;

     hr_utility.set_location(' Step:'||l_proc,30);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,40);
       --MULTI MESSAGE SUPPORT

END update_cme_status;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_if_cme_exists >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_if_cme_exists
  (p_cmb_id    IN     ota_certification_members.certification_member_id%TYPE
   , p_return_status OUT  NOCOPY VARCHAR2)
  IS
--
--
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'chk_if_cme_exists';
  --
  cursor sel_cme_exists is
    select 'Y'
      from ota_cert_mbr_enrollments cme
     where cme.cert_member_id = p_cmb_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --

  p_return_status := 'S';

  Open  sel_cme_exists;
  fetch sel_cme_exists into v_exists;
  --
  if sel_cme_exists%found then
    --
    close sel_cme_exists;
    --
    p_return_status := 'E';
      --
  else
    close sel_cme_exists;

  end if;
  --

  hr_utility.set_location(' Step:'|| v_proc, 30);

END chk_if_cme_exists;

-- ----------------------------------------------------------------------------
-- |-----------------------< refresh_cme       >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure refresh_cme(p_cert_prd_enrollment_id in ota_cert_mbr_enrollments.cert_prd_enrollment_id%type) IS

--cpe csr
CURSOR csr_cpe IS
select
       cre.certification_id,
       cpe.business_group_id
FROM ota_cert_enrollments cre,
     ota_cert_prd_enrollments cpe,
     ota_certifications_b crt
where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id
  and cre.certification_id = crt.certification_id
  and cpe.cert_enrollment_id = cre.cert_enrollment_id;

--csr for new courses since last unsubscribe
CURSOR csr_new_crs(p_certification_id in number) IS
select
  cmb.CERTIFICATION_MEMBER_ID
, cmb.CERTIFICATION_ID
, cmb.OBJECT_ID
, cmb.OBJECT_TYPE
, cmb.MEMBER_SEQUENCE
, cmb.START_DATE_ACTIVE
, cmb.END_DATE_ACTIVE
 from ota_certification_members cmb
where cmb.certification_id = p_certification_id
and trunc(sysdate) between trunc(cmb.START_DATE_ACTIVE)
and nvl(trunc(cmb.end_date_active), to_date('4712/12/31', 'YYYY/MM/DD'))
and cmb.OBJECT_TYPE = 'H'
and not exists (select
                  null
                  from ota_cert_mbr_enrollments cme2,
                       ota_certification_members cmb2
                 where cme2.cert_member_id = cmb2.certification_member_id
                   and cme2.cert_prd_enrollment_id = p_cert_prd_enrollment_id
                   and cmb2.object_id = cmb.object_id
                   and cmb2.OBJECT_TYPE = 'H');

--end dated courses since last unsubscribe
CURSOR csr_end_crs IS
SELECT cme.cert_mbr_enrollment_id,
       cme.object_version_number,
       cmb.certification_member_id,
       cme.member_status_code,
       cmb.object_id
  FROM ota_certification_members cmb,
       ota_cert_mbr_enrollments cme
 WHERE
        cme.cert_prd_enrollment_id = p_cert_prd_enrollment_id
    AND cme.cert_member_id = cmb.certification_member_id
    AND cme.member_status_code <> 'CANCELLED'
    AND cmb.object_type = 'H'
    and not exists (select
              null
              from ota_certification_members cmb2
             where cmb2.OBJECT_ID = cmb.object_id
               and cmb2.OBJECT_type = 'H'
               and trunc(sysdate) between trunc(cmb.START_DATE_ACTIVE)
               and nvl(trunc(cmb.end_date_active), to_date('4712/12/31', 'YYYY/MM/DD')));

l_proc                  varchar2(72) := g_package||'refresh_cme';

l_attribute_category  VARCHAR2(30) := NULL;
l_attribute1 VARCHAR2(150) := NULL;
l_attribute2  VARCHAR2(150) := NULL;
l_attribute3  VARCHAR2(150) := NULL;
l_attribute4  VARCHAR2(150) := NULL;
l_attribute5  VARCHAR2(150) := NULL;
l_attribute6  VARCHAR2(150) := NULL;
l_attribute7  VARCHAR2(150) := NULL;
l_attribute8  VARCHAR2(150) := NULL;
l_attribute9  VARCHAR2(150) := NULL;
l_attribute10 VARCHAR2(150) := NULL;
l_attribute11 VARCHAR2(150) := NULL;
l_attribute12 VARCHAR2(150) := NULL;
l_attribute13 VARCHAR2(150) := NULL;
l_attribute14 VARCHAR2(150) := NULL;
l_attribute15 VARCHAR2(150) := NULL;
l_attribute16 VARCHAR2(150) := NULL;
l_attribute17 VARCHAR2(150) := NULL;
l_attribute18 VARCHAR2(150) := NULL;
l_attribute19 VARCHAR2(150) := NULL;
l_attribute20 VARCHAR2(150) := NULL;

p_attribute_category  VARCHAR2(30) := NULL;
p_attribute1 VARCHAR2(150) := NULL;
p_attribute2  VARCHAR2(150) := NULL;
p_attribute3  VARCHAR2(150) := NULL;
p_attribute4  VARCHAR2(150) := NULL;
p_attribute5  VARCHAR2(150) := NULL;
p_attribute6  VARCHAR2(150) := NULL;
p_attribute7  VARCHAR2(150) := NULL;
p_attribute8  VARCHAR2(150) := NULL;
p_attribute9  VARCHAR2(150) := NULL;
p_attribute10 VARCHAR2(150) := NULL;
p_attribute11 VARCHAR2(150) := NULL;
p_attribute12 VARCHAR2(150) := NULL;
p_attribute13 VARCHAR2(150) := NULL;
p_attribute14 VARCHAR2(150) := NULL;
p_attribute15 VARCHAR2(150) := NULL;
p_attribute16 VARCHAR2(150) := NULL;
p_attribute17 VARCHAR2(150) := NULL;
p_attribute18 VARCHAR2(150) := NULL;
p_attribute19 VARCHAR2(150) := NULL;
p_attribute20 VARCHAR2(150) := NULL;

rec_cpe csr_cpe%rowtype;
l_cert_mbr_enrollment_id ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type;
l_object_version_number ota_cert_mbr_enrollments.object_version_number%type;

Begin
    hr_utility.set_location(' Entering:'||l_proc,10);

    open csr_cpe;
    fetch csr_cpe into rec_cpe;
    close csr_cpe;

    --check for new courses since last unsubscribe
    for new_crs in csr_new_crs(rec_cpe.certification_id)
    loop
    --create cme record

    hr_utility.set_location(' Step:'||l_proc,20);

                ota_utility.Get_Default_Value_Dff(
     					   appl_short_name => 'OTA'
                          ,flex_field_name => 'OTA_CERT_MBR_ENROLLMENTS'
                          ,p_attribute_category           => l_attribute_category
                          ,p_attribute1                   => l_attribute1
    					  ,p_attribute2                   => l_attribute2
    					  ,p_attribute3                   => l_attribute3
    					  ,p_attribute4                   => l_attribute4
    					  ,p_attribute5                   => l_attribute5
    					  ,p_attribute6                   => l_attribute6
    					  ,p_attribute7                   => l_attribute7
    					  ,p_attribute8                   => l_attribute8
    					  ,p_attribute9                   => l_attribute9
    					  ,p_attribute10                  => l_attribute10
    					  ,p_attribute11                  => l_attribute11
    					  ,p_attribute12                  => l_attribute12
    					  ,p_attribute13                  => l_attribute13
    					  ,p_attribute14                  => l_attribute14
    					  ,p_attribute15                  => l_attribute15
    					  ,p_attribute16                  => l_attribute16
    					  ,p_attribute17                  => l_attribute17
    					  ,p_attribute18                  => l_attribute18
    					  ,p_attribute19                  => l_attribute19
    					  ,p_attribute20                  => l_attribute20);

    hr_utility.set_location(' Step:'||l_proc,30);

                  ota_cert_mbr_enrollment_api.create_cert_mbr_enrollment(
         	      p_effective_date => trunc(sysdate)
        	     ,p_cert_prd_enrollment_id => p_cert_prd_enrollment_id
        	     ,p_cert_member_id => new_crs.certification_member_id
        	     ,p_member_status_code => 'PLANNED'
        	     ,p_business_group_id => rec_cpe.business_group_id
        	     ,p_cert_mbr_enrollment_id => l_cert_mbr_enrollment_id
                     ,p_object_version_number => l_object_version_number
                     ,p_attribute_category           => l_attribute_category
                     ,p_attribute1                   => l_attribute1
 		             ,p_attribute2                   => l_attribute2
    					  ,p_attribute3                   => l_attribute3
    					  ,p_attribute4                   => l_attribute4
    					  ,p_attribute5                   => l_attribute5
    					  ,p_attribute6                   => l_attribute6
    					  ,p_attribute7                   => l_attribute7
    					  ,p_attribute8                   => l_attribute8
    					  ,p_attribute9                   => l_attribute9
    					  ,p_attribute10                  => l_attribute10
    					  ,p_attribute11                  => l_attribute11
    					  ,p_attribute12                  => l_attribute12
    					  ,p_attribute13                  => l_attribute13
    					  ,p_attribute14                  => l_attribute14
    					  ,p_attribute15                  => l_attribute15
    					  ,p_attribute16                  => l_attribute16
    					  ,p_attribute17                  => l_attribute17
    					  ,p_attribute18                  => l_attribute18
    					  ,p_attribute19                  => l_attribute19
    					  ,p_attribute20                  => l_attribute20
                    );

    end loop;

    hr_utility.set_location(' Step:'||l_proc,40);

    --update cme_record to CANCELLED status for activities which are ended during re-cert
    for end_crs in csr_end_crs
    loop
    --update cme to CANCELLED
      ota_cert_mbr_enrollment_api.update_cert_mbr_enrollment
			    (p_effective_date           => sysdate
			    ,p_object_version_number    => end_crs.object_version_number
			    ,p_cert_member_id           => end_crs.certification_member_id
			    ,p_cert_prd_enrollment_id   => p_cert_prd_enrollment_id
			    ,p_cert_mbr_enrollment_id   => end_crs.cert_mbr_enrollment_id
			    ,p_member_status_code       => 'CANCELLED');
    end loop;

  hr_utility.set_location(' Step:'||l_proc,50);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,60);
END refresh_cme;

Function chk_active_cme_enrl(p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2
IS

cursor csr_active_enrl is
SELECT
           s.type                          Enrollment_Status_Type
FROM       ota_events e,
           ota_events_tl et,
           ota_activity_versions a,
           ota_delegate_bookings b,
           ota_booking_status_types_VL s,
           ota_cert_enrollments cre,
           ota_cert_prd_enrollments cpe,
           ota_cert_mbr_enrollments cme,
           ota_certification_members cmb,
           ota_offerings ofr,
           ota_category_usages c
WHERE   e.event_id = b.event_id
    AND cre.cert_enrollment_id = cpe.cert_enrollment_id
    AND cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
    AND e.event_id= et.event_id
    AND s.type <> 'C'
    AND et.language = USERENV('LANG')
    AND cme.cert_member_id = cmb.certification_member_id
    AND cmb.object_id = a.activity_version_id
    AND cmb.object_type = 'H'
    AND e.parent_offering_id = ofr.offering_id
    AND e.activity_version_id = a.activity_version_id
    AND b.booking_status_type_id = s.booking_status_type_id
    AND ((cre.person_id IS NOT NULL AND b.delegate_person_id = cre.person_id) OR (cre.CONTACT_ID IS NOT NULL AND b.delegate_contact_id = cre.contact_id))
    AND E.PARENT_OFFERING_ID=OFR.OFFERING_ID
    AND OFR.DELIVERY_MODE_ID = C.CATEGORY_USAGE_ID
    AND      cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id
    AND ((cre.person_id IS NOT NULL AND b.delegate_person_id = cre.person_id) OR (cre.CONTACT_ID IS NOT NULL AND b.delegate_contact_id = cre.contact_id))
    AND ( ( e.course_start_date >= cert_period_start_date
            and nvl(e.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) <= cert_period_end_date )
           or (event_type ='SELFPACED'  and    ((cert_period_end_date >= e.course_start_date)
           AND     ((e.course_end_date is null) or     (e.course_end_date IS NOT NULL AND e.course_end_date >= cert_period_start_date)))));

l_proc    VARCHAR2(72) := g_package ||'chk_active_cme_enrl';


l_enrollment_Status_Type ota_booking_status_types.Type%type;
l_return_flag varchar2(1) := 'F';

begin

      hr_utility.set_location(' Entering:' || l_proc,10);

      FOR rec IN csr_active_enrl
      LOOP
	 l_enrollment_Status_Type := rec.enrollment_Status_Type;
         l_return_flag := 'T';
         exit;
      END LOOP;

      return l_return_flag;
EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN l_return_flag;
end chk_active_cme_enrl;


END OTA_CME_UTIL;


/
