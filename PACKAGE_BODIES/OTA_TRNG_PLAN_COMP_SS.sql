--------------------------------------------------------
--  DDL for Package Body OTA_TRNG_PLAN_COMP_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRNG_PLAN_COMP_SS" as
/* $Header: ottpmwrs.pkb 120.1 2006/05/11 05:34:11 rdola noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= '  ota_trng_plan_comp_ss.';  -- Global package name

--
--  ---------------------------------------------------------------------------
--  |----------------------< update_tpc_enroll_status_chg >--------------------------|
--  ---------------------------------------------------------------------------
--

PROCEDURE update_tpc_enroll_status_chg (p_event_id IN ota_events.event_id%TYPE,
                                        p_person_id IN ota_training_plans.person_id%TYPE,
					-- Modified for Bug#3479186
    				        p_contact_id IN ota_training_plans.contact_id%TYPE,
                                        p_learning_path_ids OUT NOCOPY varchar2)
--p_status_id in ota_booking_status_types.booking_status_type_id%type)
IS

l_proc  VARCHAR2(72) :=      g_package|| 'update_tpc_enroll_status_chg';


--GET ALL THE TPC'S WHICH HAVE PASSED EVENT AS MEMBER
  CURSOR csr_tpm_info(csr_activity_version_id number, csr_evt_start_date date,csr_evt_end_date date,csr_evt_type varchar2) IS
  SELECT otpm.training_plan_member_id,
         otpm.object_version_number,otpm.earliest_start_date, otpm.target_completion_date
--  otpm.member_status_type_id
  FROM ota_training_plan_members otpm,
       ota_training_plans otp
 WHERE otp.training_plan_id = otpm.training_plan_id
  -- AND otp.person_id = p_person_id
  AND (( p_person_id IS NOT NULL AND otp.person_id = p_person_id)
                OR (p_contact_id IS NOT NULL AND otp.contact_id = p_contact_id))
   AND otpm.activity_version_id = csr_activity_version_id
   and otpm.member_status_type_id <> 'CANCELLED'
--   AND otpm.target_completion_date IS NOT NULL
--Modified for Bug#3855721
   AND(otp.learning_path_id IS NOT NULL OR ( otpm.earliest_start_date <= csr_evt_start_date
   AND
   (csr_evt_end_date IS NOT NULL
   AND otpm.target_completion_date >= csr_evt_end_date)
   or (csr_evt_type = 'SELFPACED'
           AND otpm.target_completion_date >= csr_evt_start_date)));

  CURSOR evt_det IS
  SELECT activity_version_id,
         course_start_date,
         course_end_date,
         event_type
    FROM ota_events
   WHERE event_id = p_event_id;



  l_evt_start_date       DATE;
  l_evt_end_date         DATE;
  l_activity_version_id  NUMBER(9);
  l_evt_type             VARCHAR2(30);
  l_enroll_type          varchar2(30);
  l_member_status_type   ota_training_plan_members.member_status_type_id%TYPE;
/*  l_exists               ota_training_plan_members.training_plan_member_id%TYPE;
  l_name                 ota_training_plans.name%type;
  l_object_version_number  ota_training_plans.object_version_number%type;
  l_time_period_id        ota_training_plans.time_period_id%type;
  l_budget_currency       ota_training_plans.budget_currency%type;
  */

BEGIN


    OPEN evt_det;
    FETCH evt_det
     INTO l_activity_version_id,
          l_evt_start_date,
          l_evt_end_date ,
          l_evt_type;

       IF evt_det%FOUND THEN

        CLOSE evt_det;

        hr_utility.set_location(' Step:'|| l_proc, 20);

           /* open evt_type;
            fetch evt_type into l_evt_Type;
            close evt_type;  */

        FOR rec IN csr_tpm_info(l_activity_version_id,l_evt_start_date,l_evt_end_date,l_evt_type)

            LOOP

		-- Modified for Bug#3479186
                    l_enroll_type := ota_trng_plan_util_ss.get_enroll_status(p_person_id,p_contact_id,rec.training_plan_member_id);

           IF l_enroll_type = 'A' THEN
              l_member_status_type := 'OTA_COMPLETED';
            ELSIF ( l_enroll_type = 'P'
              OR l_enroll_type = 'W'
              OR l_enroll_type = 'R') THEN
              l_member_status_type := 'ACTIVE';
            ELSE l_member_status_type := 'OTA_PLANNED';
          END IF;
                  --call upd tpm api after lck
		 ota_tpm_api.update_training_plan_member
                        (p_effective_date => sysdate
                        ,p_object_version_number => rec.object_version_number
                        ,p_training_plan_member_id => rec.training_plan_member_id
                        ,p_member_status_type_id => l_member_status_type
                        ,p_earliest_start_date => rec.earliest_start_date
                        ,p_target_completion_date => rec.target_completion_date
                        ,p_activity_version_id => l_activity_version_id);

--Thes checks are required only if member status has been updated to Completed


    --    IF l_enroll_type='A' then

        Update_tp_tpc_change(rec.training_plan_member_id, p_learning_path_ids);

       /*     FOR rec1 in csr_tp_with_tpc(rec.training_plan_member_id)
            LOOP
 ---check if all the components under this tP are completed or cancelled
                    open csr_tp_with_valid_tpc(rec1.training_plan_id);
                    fetch csr_tp_with_valid_tpc into l_exists;
                    IF csr_tp_with_valid_tpc%NOTFOUND then

			        CLOSE csr_tp_with_valid_tpc;

                --check if this TP  has flag set to Y
                        OPEN csr_tp_update(rec1.training_plan_id);
                        FETCH csr_tp_update into l_name,l_object_version_number,l_time_period_id,l_budget_currency;
                        IF csr_tp_update%FOUND then
				        CLOSE csr_tp_update;
                        --update TP
                            ota_tps_api.update_training_plan
                            (p_effective_date               => sysdate
                            ,p_training_plan_id             => rec1.training_plan_id
                            ,p_object_version_NUMBER        => l_object_version_number
                            ,p_plan_status_type_id          => 'COMPLETED'
                            ,p_name                         => l_name
                            ,p_time_period_id               => l_time_period_id
                            ,p_budget_currency              => l_budget_currency);


                        END IF;
                        CLOSE csr_tp_update;

                    END IF;

                    CLOSE csr_tp_with_valid_tpc;

            END LOOP;*/

     --   END IF;



--update TP status
            END LOOP;

    ELSE
        CLOSE evt_Det;
    END IF;

    hr_utility.set_location(' Step:'|| l_proc, 30);

       --MULTI MESSAGE SUPPORT


END update_tpc_enroll_status_chg;
--  ---------------------------------------------------------------------------
--  |----------------------< update_tpc_evt_change >--------------------------|
--  ---------------------------------------------------------------------------
--
--checkes component status on change of enrollment status
PROCEDURE update_tpc_evt_change (p_event_id IN ota_Events.event_id%TYPE,
                                 p_course_start_date IN ota_events.course_start_date%TYPE,
                                 p_course_end_date IN ota_events.course_end_date%TYPE)
IS
/* Commented out for bug#5086156
CURSOR csr_tpm IS
SELECT tpm.training_plan_member_id,
       tp.person_id,
       -- Modified for Bug#3479186
       tp.contact_id,
       tpm.object_version_number
  FROM ota_training_plans tp,
       ota_training_plan_members tpm,
       ota_events oe,
       ota_delegate_bookings odb,
       ota_booking_status_types bst
 WHERE oe.event_id = odb.event_id
   AND odb.booking_status_type_id=bst.booking_status_type_id
   AND bst.type <>'C'
-- and bst.active_flag='Y'
   AND oe.activity_version_id = tpm.activity_version_id
   AND tpm.training_plan_id = tp.training_plan_id
--Modified for Bug#3855721
   -- AND odb.delegate_person_id = tp.person_id
   AND (odb.delegate_person_id = tp.person_id OR odb.delegate_contact_id = tp.contact_id)
   AND oe.event_id = p_event_id
   AND tpm.member_status_type_id NOT IN ('CANCELLED', 'OTA_AWAITING_APPROVAL','OTA_COMPLETED')
   AND (tpm.target_completion_date <nvl(p_course_start_date, hr_api.g_eot)
       or tpm.earliest_start_date > nvl(p_course_end_date, hr_api.g_eot)) ;
*/

   l_proc               VARCHAR2(72) :=      g_package|| 'update_tpc_evt_date_change';
   l_enroll_status      VARCHAR2(30);
   l_member_status_type VARCHAR2(30);

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);
/*
    FOR rec IN csr_tpm
    LOOP

        hr_utility.set_location(' Step:'|| l_proc, 20);
        l_enroll_status := ota_trng_plan_util_ss.get_enroll_status (p_person_id               => rec.person_id,
					-- Modified for Bug#3479186
	                                      p_contact_id => rec.contact_id,
                                              p_training_plan_member_id => rec.training_plan_member_id);
          IF ( l_enroll_status = 'P'
              OR l_enroll_status = 'W'
              OR l_enroll_status = 'R') THEN

            fnd_message.set_name('OTA', 'OTA_13187_TPM_EVT_DATES');
            fnd_message.raise_error;
            EXIT;
            --  l_member_status_type := 'ACTIVE';
       --  ELSE l_member_status_type := 'OTA_PLANNED';
          END IF;



    END LOOP;
*/
        hr_utility.set_location(' Step:'|| l_proc, 30);

END update_tpc_evt_change;

-- ----------------------------------------------------------------------------
-- |---------------------------<  validate_TPC  >-------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_tpc
(  p_mode in varchar2
  ,p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_business_group_id            IN     number
  ,p_training_plan_id             IN     number
  ,p_activity_version_id          IN     NUMBER    DEFAULT NULL
  ,p_activity_definition_id       IN     NUMBER    DEFAULT NULL
  ,p_member_status_type_id        IN     VARCHAR2
  ,p_target_completion_date       IN     date      DEFAULT NULL
  ,p_attribute_category           IN     VARCHAR2  DEFAULT NULL
  ,p_attribute1                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute2                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute3                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute4                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute5                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute6                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute7                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute8                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute9                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute10                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute11                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute12                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute13                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute14                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute15                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute16                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute17                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute18                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute19                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute20                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute21                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute22                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute23                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute24                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute25                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute26                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute27                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute28                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute29                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute30                  IN     VARCHAR2  DEFAULT NULL
  ,p_assignment_id                IN     NUMBER    DEFAULT NULL
  ,p_source_id                    IN     NUMBER    DEFAULT NULL
  ,p_source_function              IN     VARCHAR2  DEFAULT NULL
  ,p_cancellation_reason          IN     VARCHAR2  DEFAULT NULL
  ,p_earliest_start_date          IN     date      DEFAULT NULL
  ,p_training_plan_member_id      IN     number
  ,p_creator_person_id            IN    number
  ,p_object_version_NUMBER        IN OUT NOCOPY number
  ,p_return_status                OUT NOCOPY VARCHAR2)

  is
  l_proc    VARCHAR2(72) := g_package ||'validate_TPC';
  l_object_version_number number;
  l_training_plan_member_id number;

  begin
    hr_utility.set_location(' Entering:' || l_proc,10);

--    SAVEPOINT validate_TPC_proc;

    if p_mode= 'INSERT' then
    ota_tpm_swi.create_training_plan_member
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_training_plan_id             => p_training_plan_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_definition_id       => p_activity_definition_id
    ,p_member_status_type_id        => p_member_status_type_id
    ,p_target_completion_date       => p_target_completion_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_source_function              => p_source_function
    ,p_cancellation_reason          => p_cancellation_reason
    ,p_earliest_start_date          => p_earliest_start_date
    ,p_training_plan_member_id      => l_training_plan_member_id
    ,p_object_version_NUMBER        => l_object_version_number
    ,p_creator_person_id            => p_creator_person_id
    ,p_return_status                => p_return_status
    );

    elsif p_mode = 'UPDATE' then

    ota_tpm_swi.update_training_plan_member
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_training_plan_member_id      => p_training_plan_member_id
    ,p_object_version_NUMBER        => p_object_version_number
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_definition_id       => p_activity_definition_id
    ,p_member_status_type_id        => p_member_status_type_id
    ,p_target_completion_date       => p_target_completion_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_source_function              => p_source_function
    ,p_cancellation_reason          => p_cancellation_reason
    ,p_earliest_start_date          => p_earliest_start_date
    ,p_creator_person_id            => p_creator_person_id
    ,p_return_status                => p_return_status
    );
    end if;

--  ROLLBACK to validate_TPC_proc;

  p_object_version_number:=null;
  p_return_status:= hr_multi_message.get_return_status_disable;

  hr_utility.set_location(' LEAVING:' || l_proc,20);

  end validate_TPC;

--  ---------------------------------------------------------------------------
--  |----------------------< Update_tpc_sshr_change >--------------------------|
--  ---------------------------------------------------------------------------
--

Procedure Update_tpc_sshr_change(
p_training_plan_member_id  ota_training_plan_members.training_plan_member_id%type,
p_person_id  ota_training_plans.person_id%type,
p_mode varchar2)
is

Cursor get_tpc_detail
is
Select object_version_number from
ota_training_plan_members
where training_plan_member_id=p_training_plan_member_id;

 l_enroll_type          varchar2(30);
 l_object_version_number Number(9);
 l_member_status_type varchar2(30);

begin


          open  get_tpc_detail;
          fetch get_tpc_detail into l_object_version_number;
          close get_tpc_detail;

    if p_mode='APPROVE' then

-- Modified for Bug#3479186
        l_enroll_type := ota_trng_plan_util_ss.get_enroll_status(p_person_id,NULL,p_training_plan_member_id);

           IF l_enroll_type = 'A' THEN
              l_member_status_type := 'OTA_COMPLETED';
            ELSIF ( l_enroll_type = 'P'
              OR l_enroll_type = 'W'
              OR l_enroll_type = 'R') THEN
              l_member_status_type := 'ACTIVE';
            ELSE l_member_status_type := 'OTA_PLANNED';
          END IF;


                  --call upd tpm api after lck
		 ota_tpm_api.update_training_plan_member
                        (p_effective_date => sysdate
                        ,p_object_version_number => l_object_version_number
                        ,p_training_plan_member_id => p_training_plan_member_id
                        ,p_member_status_type_id => l_member_status_type);



    elsif p_mode='REJECT' then
    l_member_status_type :='CANCELLED';

             ota_tpm_api.update_training_plan_member
                        (p_effective_date => sysdate
                        ,p_object_version_number => l_object_version_number
                        ,p_training_plan_member_id => p_training_plan_member_id
                        ,p_member_status_type_id => l_member_status_type);

    end if;


end Update_tpc_sshr_change;

--  ---------------------------------------------------------------------------
--  |----------------------< Update_tp_tpc_change >--------------------------|
--  ---------------------------------------------------------------------------
--
-- This procedure will get called only when a tpc is Cancelled
/*
Procedure Update_tp_tpc_change
(p_training_plan_member_id ota_training_plan_members.training_plan_member_id%type)
is

--get all the TP corresponding to a particular TP member
CURSOR csr_tp_with_tpc
    IS
    SELECT otp.training_plan_id
           , otp.plan_status_type_id
    FROM ota_training_plans otp,
            ota_training_plan_members otpm
    WHERE otp.training_plan_id=otpm.training_plan_id
    and otp.plan_status_type_id <> 'CANCELLED'
    --and otp.plan_status_type_id <> 'COMPLETED'
    -- Modified from COMPLETED to OTA_COMPLETED
   and otp.plan_status_type_id <> 'OTA_COMPLETED'
    and otpm.training_plan_member_id=p_training_plan_member_id;

--check if selected TP has any component not in Cancelled or completed status
    CURSOR csr_tp_with_valid_tpc(csr_training_plan_id number)
    IS
    SELECT otpm.training_plan_member_id
      FROM ota_training_plan_members otpm
     WHERE otpm.member_status_type_id <>'CANCELLED'
       and otpm.member_status_type_id <>'OTA_COMPLETED'
       and otpm.training_plan_id=csr_training_plan_id
       and rownum=1;

--check if flag has been set to y
    CURSOR csr_tp_update(csr_training_plan_id number)
    IS
    SELECT otp.name,
           otp.object_version_number,
           otp.time_period_id,
           otp.budget_currency
      FROM ota_training_plans otp,
           ota_training_plan_members otpm
     WHERE otp.training_plan_id = csr_training_plan_id
       AND otp.training_plan_id = otpm.training_plan_id
       AND otpm.member_status_type_id = 'OTA_COMPLETED'
       AND additional_member_flag = 'N';

  l_exists               ota_training_plan_members.training_plan_member_id%TYPE;
  l_name                 ota_training_plans.name%type;
  l_object_version_number  ota_training_plans.object_version_number%type;
  l_time_period_id        ota_training_plans.time_period_id%type;
  l_budget_currency       ota_training_plans.budget_currency%type;
  l_plan_status_type_id   ota_training_plans.plan_status_type_id%type;

begin

          FOR rec1 in csr_tp_with_tpc
            LOOP
                IF rec1.plan_status_type_id <> 'OTA_COMPLETED' THEN
 ---check if all the components under this tP are completed or cancelled
                    open csr_tp_with_valid_tpc(rec1.training_plan_id);
                    fetch csr_tp_with_valid_tpc into l_exists;
                    IF csr_tp_with_valid_tpc%NOTFOUND then

			        CLOSE csr_tp_with_valid_tpc;


                --check if this TP  has flag set to Y
                        OPEN csr_tp_update(rec1.training_plan_id);
                        FETCH csr_tp_update into l_name,l_object_version_number,l_time_period_id,l_budget_currency;
                        IF csr_tp_update%FOUND then
				        CLOSE csr_tp_update;
                        --update TP
                            ota_tps_api.update_training_plan
                            (p_effective_date               => sysdate
                            ,p_training_plan_id             => rec1.training_plan_id
                            ,p_object_version_NUMBER        => l_object_version_number
			    -- Modified to use OTA_COMPLETED
                            ,p_plan_status_type_id          => 'OTA_COMPLETED'
                            ,p_name                         => l_name
                            ,p_time_period_id               => l_time_period_id
                            ,p_budget_currency              => l_budget_currency);

                        ELSE

                        CLOSE csr_tp_update;

                        END IF;


                    CLOSE csr_tp_with_valid_tpc;

                    END IF;

              ELSE

              END IF;

            END LOOP;




end Update_tp_tpc_change;
*/
Procedure Update_tp_tpc_change
(p_training_plan_member_id ota_training_plan_members.training_plan_member_id%type)
is

CURSOR csr_tp_with_tpc
    IS
    SELECT otp.training_plan_id
           , otp.plan_status_type_id
           , otp.additional_member_flag
    FROM ota_training_plans otp,
            ota_training_plan_members otpm
    WHERE otp.training_plan_id=otpm.training_plan_id
    and otp.plan_status_type_id <> 'CANCELLED'
    and otpm.training_plan_member_id=p_training_plan_member_id;


CURSOR csr_tp_update(csr_training_plan_id number)
    IS
    SELECT otp.name,
           otp.object_version_number,
           otp.time_period_id,
           otp.budget_currency
     FROM ota_training_plans otp
     WHERE otp.training_plan_id = csr_training_plan_id;


  l_exists               ota_training_plan_members.training_plan_member_id%TYPE;
  l_name                 ota_training_plans.name%type;
  l_object_version_number  ota_training_plans.object_version_number%type;
  l_time_period_id        ota_training_plans.time_period_id%type;
  l_budget_currency       ota_training_plans.budget_currency%type;
  l_plan_status_type_id   ota_training_plans.plan_status_type_id%type;
  l_complete_ok      varchar2(1);

BEGIN
    FOR rec1 in csr_tp_with_tpc LOOP
        l_plan_status_type_id :=rec1.plan_status_type_id;
        l_complete_ok := ota_trng_plan_util_ss.chk_complete_plan_ok(rec1.training_plan_id);
        IF l_complete_ok = 'S'
            AND rec1.plan_status_type_id = 'ACTIVE'
          -- Bug3499850  AND rec1.additional_member_flag = 'N' THEN
          THEN
          -- The Plan can be completed
            l_plan_status_type_id := 'OTA_COMPLETED';
        ELSIF l_complete_ok = 'F' AND rec1.plan_status_type_id = 'OTA_COMPLETED' THEN
            l_plan_status_type_id := 'ACTIVE';
        END IF;

        IF l_plan_status_type_id <> rec1.plan_status_type_id THEN
              OPEN csr_tp_update(rec1.training_plan_id);
              FETCH csr_tp_update into l_name,l_object_version_number,l_time_period_id,l_budget_currency;
              IF csr_tp_update%FOUND then
			     CLOSE csr_tp_update;
                 ota_tps_api.update_training_plan
                            (p_effective_date               => sysdate
                            ,p_training_plan_id             => rec1.training_plan_id
                            ,p_object_version_number        => l_object_version_number
                            ,p_plan_status_type_id          => l_plan_status_type_id
                            ,p_name                         => l_name
                            ,p_time_period_id               => l_time_period_id
                            ,p_budget_currency              => l_budget_currency);

              ELSE
                  CLOSE csr_tp_update;
              END IF;
         END IF;
     END LOOP;
END Update_tp_tpc_change;


Procedure Update_tp_tpc_change
(p_training_plan_member_id ota_training_plan_members.training_plan_member_id%type
,p_learning_path_ids  OUT NOCOPY varchar2)
is

CURSOR csr_tp_with_tpc
    IS
    SELECT otp.training_plan_id
           , otp.plan_status_type_id
           , otp.additional_member_flag
           , otp.learning_path_id
    FROM ota_training_plans otp,
            ota_training_plan_members otpm
    WHERE otp.training_plan_id=otpm.training_plan_id
    and otp.plan_status_type_id <> 'CANCELLED'
    and otpm.training_plan_member_id=p_training_plan_member_id;


CURSOR csr_tp_update(csr_training_plan_id number)
    IS
    SELECT otp.name,
           otp.object_version_number,
           otp.time_period_id,
           otp.budget_currency
     FROM ota_training_plans otp
     WHERE otp.training_plan_id = csr_training_plan_id;


  l_exists               ota_training_plan_members.training_plan_member_id%TYPE;
  l_name                 ota_training_plans.name%type;
  l_object_version_number  ota_training_plans.object_version_number%type;
  l_time_period_id        ota_training_plans.time_period_id%type;
  l_budget_currency       ota_training_plans.budget_currency%type;
  l_plan_status_type_id   ota_training_plans.plan_status_type_id%type;
  l_complete_ok      varchar2(1);
  l_learning_path_ids varchar2(4000) := '';

BEGIN
    FOR rec1 in csr_tp_with_tpc LOOP
        l_plan_status_type_id :=rec1.plan_status_type_id;
        l_complete_ok := ota_trng_plan_util_ss.chk_complete_plan_ok(rec1.training_plan_id);
        IF l_complete_ok = 'S'
            AND rec1.plan_status_type_id = 'ACTIVE'
          -- Bug3499850  AND rec1.additional_member_flag = 'N' THEN
	  THEN
          -- The Plan can be completed
            l_plan_status_type_id := 'OTA_COMPLETED';
            IF rec1.learning_path_id IS NOT NULL THEN
                if l_learning_path_ids = '' or l_learning_path_ids is null then
                l_learning_path_ids := rec1.learning_path_id;
                else
                l_learning_path_ids := l_learning_path_ids || '^' || rec1.learning_path_id;

                end if;
-- l_learning_path_ids := l_learning_path_ids || '^' || rec1.learning_path_id;
            END IF;
        ELSIF l_complete_ok = 'F' AND rec1.plan_status_type_id = 'OTA_COMPLETED' THEN
            l_plan_status_type_id := 'ACTIVE';
        END IF;

        IF l_plan_status_type_id <> rec1.plan_status_type_id THEN
              OPEN csr_tp_update(rec1.training_plan_id);
              FETCH csr_tp_update into l_name,l_object_version_number,l_time_period_id,l_budget_currency;
              IF csr_tp_update%FOUND then
			     CLOSE csr_tp_update;
                 ota_tps_api.update_training_plan
                            (p_effective_date               => sysdate
                            ,p_training_plan_id             => rec1.training_plan_id
                            ,p_object_version_number        => l_object_version_number
                            ,p_plan_status_type_id          => l_plan_status_type_id
                            ,p_name                         => l_name
                            ,p_time_period_id               => l_time_period_id
                            ,p_budget_currency              => l_budget_currency);

              ELSE
                  CLOSE csr_tp_update;
              END IF;
         END IF;
     END LOOP;
     p_learning_path_ids := l_learning_path_ids;
END Update_tp_tpc_change;

END ota_trng_plan_comp_ss;


/
