--------------------------------------------------------
--  DDL for Package Body OTA_CERT_PRD_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERT_PRD_ENROLLMENT_API" as
/* $Header: otcpeapi.pkb 120.13.12010000.3 2008/09/22 10:52:35 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_CERT_PRD_ENROLLMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_cert_prd_enrollment    >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cert_prd_enrollment
(
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_cert_enrollment_id           in number,
  p_period_status_code           in varchar2,
  p_completion_date              in date             default null,
  p_cert_period_start_date       in date             default null,
  p_cert_period_end_date         in date             default null,
  p_business_group_id            in number,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_expiration_date              in date             default null,
  p_cert_prd_enrollment_id       out nocopy number,
  p_object_version_number        out nocopy number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_cert_prd_enrollment';
  l_cert_prd_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_cert_prd_enrollment;
  l_effective_date := trunc(p_effective_date);


  begin
  OTA_CERT_PRD_ENROLLMENT_bk1.create_cert_prd_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_period_status_code           => p_period_status_code
    ,p_completion_date              => p_completion_date
    ,p_cert_period_start_date       => p_cert_period_start_date
    ,p_cert_period_end_date         => p_cert_period_end_date
    ,p_business_group_id            => p_business_group_id
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
    ,p_expiration_date              => p_expiration_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cert_prd_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_cpe_ins.ins
  (
   p_effective_date                 =>   p_effective_date
  ,p_cert_enrollment_id             =>   p_cert_enrollment_id
  ,p_period_status_code             =>   p_period_status_code
  ,p_cert_period_start_date         =>   p_cert_period_start_date
  ,p_cert_period_end_date           =>   p_cert_period_end_date
  ,p_completion_date                =>   p_completion_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_expiration_date                =>   p_expiration_date
  ,p_cert_prd_enrollment_id         =>   l_cert_prd_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_cert_prd_enrollment_id        := l_cert_prd_enrollment_id;
  p_object_version_number         := l_object_version_number;



  begin
  OTA_CERT_PRD_ENROLLMENT_bk1.create_cert_prd_enrollment_a
   ( p_effective_date               => p_effective_date
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_period_status_code           => p_period_status_code
    ,p_completion_date              => p_completion_date
    ,p_cert_period_start_date       => p_cert_period_start_date
    ,p_cert_period_end_date         => p_cert_period_end_date
    ,p_business_group_id            => p_business_group_id
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
    ,p_expiration_date              => p_expiration_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cert_prd_enrollment'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_cert_prd_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cert_prd_enrollment_id  := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_cert_prd_enrollment;
    p_cert_prd_enrollment_id  := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cert_prd_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_cert_prd_enrollment >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cert_prd_enrollment
  (p_effective_date               in     date
  ,p_cert_prd_enrollment_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_cert_enrollment_id           in     number
  ,p_period_status_code           in     varchar2
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_cert_period_start_date       in     date      default hr_api.g_date
  ,p_cert_period_end_date         in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_expiration_date              in     date      default hr_api.g_date
  ,p_validate                     in     boolean          default false
   ) is
  --
  -- Declare cursors and local variables
  --
CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.RENEWAL_DURATION
        , b.RENEWAL_DURATION_UNITS
        , b.NOTIFY_DAYS_BEFORE_EXPIRE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.RENEWABLE_FLAG
        , b.VALIDITY_START_TYPE
        , b.PUBLIC_FLAG
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
        , cre.earliest_enroll_date
        , cre.expiration_date
from ota_certifications_b b,
     ota_cert_enrollments cre
where b.certification_id = cre.certification_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_cert_enrl IS
select cert_enrollment_id,
         certification_id,
         certification_status_code,
         object_version_number,
         completion_date,
         is_history_flag,
	 person_id,
	 earliest_enroll_date
FROM ota_cert_enrollments
where cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_max_cpe_exp_dt IS
select
        max(cpe.expiration_date)
from ota_cert_prd_enrollments cpe,
     ota_cert_enrollments cre
where cpe.cert_enrollment_id = cre.cert_enrollment_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_old_cpe_exp_dt IS
select
        cpe.expiration_date
from ota_cert_prd_enrollments cpe
where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id;

l_proc                    varchar2(72) := g_package||' update_cert_prd_enrollment';
l_object_version_number   number := p_object_version_number;
l_effective_date date;
l_item_key wf_items.item_key%type;

rec_crt csr_crt%rowtype;
l_cert_enrl_rec csr_cert_enrl%ROWTYPE;

l_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;
l_expiration_date ota_cert_enrollments.expiration_date%type;
l_max_expiration_date date;
l_update_cre_dates_flag varchar2(1) := 'N';
l_cert_period_start_date date :=p_cert_period_start_date;
l_cert_period_end_date date :=p_cert_period_end_date;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_cert_prd_enrollment;
  l_effective_date := trunc(p_effective_date);

  --initialize l_expiration_date with passed p_expiration_date
  if p_expiration_date is not null then
     l_expiration_date := p_expiration_date;
  else
     --get old value into l_expiration_date
     open csr_old_cpe_exp_dt;
     fetch csr_old_cpe_exp_dt into l_expiration_date;
     close csr_old_cpe_exp_dt;
  end if;

  OPEN csr_crt;
  FETCH csr_crt INTO rec_crt;
  CLOSE csr_crt;

  if (rec_crt.RENEWABLE_FLAG = 'Y' and p_period_status_code = 'COMPLETED') then
      --update cre dates
      --recalc exp date, and earliest enroll dates  for next period
      OPEN csr_max_cpe_exp_dt;
      FETCH csr_max_cpe_exp_dt INTO l_max_expiration_date;
      CLOSE csr_max_cpe_exp_dt;

      OPEN csr_cert_enrl;
      FETCH csr_cert_enrl INTO l_cert_enrl_rec;
      CLOSE csr_cert_enrl;

      if rec_crt.INITIAL_COMPLETION_DURATION is not null then
          --populate exp date
          if rec_crt.VALIDITY_START_TYPE = 'T' then
        	 --get the max exp date for cre
       	     	 l_expiration_date := l_max_expiration_date;
          elsif (rec_crt.VALIDITY_START_TYPE = 'A') then
        	if(p_completion_date is not null) then
        	   l_expiration_date := p_completion_date + rec_crt.validity_duration;
        	else
                l_expiration_date := trunc(sysdate) + rec_crt.validity_duration;
            end if;
	  end if;

          /*
          validity start type = T
            - renewal_duration null means, renewal from actual compl
            - renewal_duration same as validity_duration means, renewal from due date

          validity start type = A
            - renewal_duration null means, renewal from actual compl
            - renewal_duration same as validity_duration means, renewal from due date
          */

          --populate earliest_enrollment_date
          if rec_crt.renewal_duration is not null then
              if (rec_crt.validity_duration = rec_crt.renewal_duration) then
                 --renew from due date
        	 --get the existing earl date and upd same
        	 l_earliest_enroll_date := l_cert_enrl_rec.earliest_enroll_date;
	      else
		 l_earliest_enroll_date := l_expiration_date - rec_crt.renewal_duration;
	      end if;
          else
              --earl enr dt imm after compl
	       if(p_completion_date is not null) then
	           l_earliest_enroll_date := p_completion_date;
	       else
                l_earliest_enroll_date := trunc(sysdate);
            end if;
          end if;

          l_update_cre_dates_flag := 'Y';

     elsif rec_crt.INITIAL_COMPLETION_DATE is not null then
          --populate exp date at cre
          if rec_crt.VALIDITY_START_TYPE = 'T' then
             --get the max exp date for cre
       	     l_expiration_date := l_max_expiration_date;
       	  end if;

          --get the existing earl date and upd same
	  l_earliest_enroll_date := l_cert_enrl_rec.earliest_enroll_date;
       	  l_update_cre_dates_flag := 'Y';
     end if;


      --update cre rec for any modified dates
      if (l_update_cre_dates_flag = 'Y') then
	  ota_cert_enrollment_api.update_cert_enrollment
	      (p_effective_date               => sysdate
	       ,p_cert_enrollment_id           => p_cert_enrollment_id
	       ,p_certification_id             => rec_crt.certification_id
	       ,p_object_version_number        => l_cert_enrl_rec.object_version_number
	       ,p_certification_status_code    => l_cert_enrl_rec.certification_status_code
	       ,p_is_history_flag              => l_cert_enrl_rec.is_history_flag
	       ,p_completion_date              => p_completion_date
	       ,p_expiration_date              => l_expiration_date
	       ,p_earliest_enroll_date         => l_earliest_enroll_date
		   );
      end if;
  end if; --end of RENEWAL COMPLETE


  begin
  OTA_CERT_PRD_ENROLLMENT_bk2.update_cert_prd_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_period_status_code           => p_period_status_code
    ,p_completion_date              => p_completion_date
    ,p_cert_period_start_date       => p_cert_period_start_date
    ,p_cert_period_end_date         => p_cert_period_end_date
    ,p_business_group_id            => p_business_group_id
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
    ,p_expiration_date              => p_expiration_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cert_prd_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Process Logic
  --

  ota_cpe_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_cert_prd_enrollment_id         =>   p_cert_prd_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_cert_enrollment_id             =>   p_cert_enrollment_id
  ,p_period_status_code             =>   p_period_status_code
  ,p_cert_period_start_date         =>   p_cert_period_start_date
  ,p_cert_period_end_date           =>   p_cert_period_end_date
  ,p_completion_date                =>   p_completion_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
   --expiration_date would be re-calculated for COMPL status
  ,p_expiration_date                =>   l_expiration_date
  );

  begin
  OTA_CERT_PRD_ENROLLMENT_bk2.update_cert_prd_enrollment_a
  (  p_effective_date               => p_effective_date
    ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
    ,p_object_version_number        => p_object_version_number
    ,p_cert_enrollment_id           => p_cert_enrollment_id
    ,p_period_status_code           => p_period_status_code
    ,p_completion_date              => p_completion_date
    ,p_cert_period_start_date       => p_cert_period_start_date
    ,p_cert_period_end_date         => p_cert_period_end_date
    ,p_business_group_id            => p_business_group_id
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
    ,p_expiration_date              => p_expiration_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cert_prd_enrollment'
        ,p_hook_type   => 'AP'
        );
  end;


  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --fire competency update/CERT completion notifications
  OPEN csr_cert_enrl;
  FETCH csr_cert_enrl INTO l_cert_enrl_rec;
  CLOSE csr_cert_enrl;

  if p_period_status_code = 'COMPLETED' and l_cert_enrl_rec.person_id is not null then

    OTA_INITIALIZATION_WF.initialize_cert_ntf_wf(p_item_type     => 'OTWF',
					p_person_id 	         => l_cert_enrl_rec.person_id,
					p_certification_id       => l_cert_enrl_rec.certification_id,
					p_cert_prd_enrollment_id => p_cert_prd_enrollment_id,
					p_cert_ntf_type          => 'CERT_COMPLETION');

    If (p_cert_period_start_date = hr_api.g_date) then
    l_cert_period_start_date :=
    ota_cpe_shd.g_old_rec.cert_period_start_date;
  End If;
  If (p_cert_period_end_date = hr_api.g_date) then
    l_cert_period_end_date :=
    ota_cpe_shd.g_old_rec.cert_period_end_date;
  End If;

  if ('Y' = ota_cpe_util.is_cert_success_complete(p_cert_prd_enrollment_id => p_cert_prd_enrollment_id,
                p_cert_period_start_date       => l_cert_period_start_date
                ,p_cert_period_end_date         => l_cert_period_end_date,
                p_person_id => l_cert_enrl_rec.person_id)) then
    ota_competence_ss.create_wf_process(p_process     =>'OTA_COMPETENCE_UPDATE_JSP_PRC',
           p_itemtype         =>'HRSSA',
           p_person_id     => l_cert_enrl_rec.person_id,
           p_eventid       =>null,
           p_learningpath_ids => null,
            p_certification_id => l_cert_enrl_rec.certification_id ,
           p_itemkey    =>l_item_key);

  end if;

  end if;

  if p_period_status_code = 'CANCELLED' and l_cert_enrl_rec.person_id is not null then

    OTA_INITIALIZATION_WF.initialize_cert_ntf_wf(p_item_type => 'OTWF',
                                  p_person_id => l_cert_enrl_rec.person_id ,
                                  p_certification_id => l_cert_enrl_rec.certification_id,
                                  p_cert_prd_enrollment_id => p_cert_prd_enrollment_id,
                                  p_cert_ntf_type => 'CERT_UNENROLL');


  end if;

  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_cert_prd_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_cert_prd_enrollment;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cert_prd_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_cert_prd_enrollment >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_prd_enrollment
  (p_cert_prd_enrollment_id        in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'DELETE_cert_prd_enrollment';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_cert_prd_enrollment;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  OTA_CERT_PRD_ENROLLMENT_bk3.delete_cert_prd_enrollment_b
  (p_cert_prd_enrollment_id         => p_cert_prd_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cert_prd_enrollment'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_cpe_del.del
  (
  p_cert_prd_enrollment_id   => p_cert_prd_enrollment_id             ,
  p_object_version_number    => p_object_version_number
  );


  begin
  OTA_CERT_PRD_ENROLLMENT_bk3.delete_cert_prd_enrollment_a
  (p_cert_prd_enrollment_id         => p_cert_prd_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cert_prd_enrollment'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_cert_prd_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_cert_prd_enrollment;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_cert_prd_enrollment;

-- ----------------------------------------------------------------------------
-- |-------------------------< renew_cert_prd_enrollment >-------------------|
-- ----------------------------------------------------------------------------
procedure renew_cert_prd_enrollment(p_validate in boolean default false
		       		    ,p_cert_enrollment_id in number
		       		    ,p_cert_period_start_date in date default sysdate
				    ,p_cert_prd_enrollment_id OUT NOCOPY number
				    ,p_certification_status_code OUT NOCOPY VARCHAR2)
is

CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.RENEWAL_DURATION
        , b.RENEWAL_DURATION_UNITS
        , b.NOTIFY_DAYS_BEFORE_EXPIRE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.RENEWABLE_FLAG
        , b.VALIDITY_START_TYPE
        , b.PUBLIC_FLAG
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
from ota_certifications_b b,
     ota_cert_enrollments cre
where cre.certification_id = b.certification_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;


CURSOR csr_cert_enrl IS
select certification_id,
     cert_enrollment_id,
     business_group_id,
     certification_status_code,
     object_version_number,
     completion_date
FROM ota_cert_enrollments
where cert_enrollment_id = p_cert_enrollment_id;

l_proc    varchar2(72) := g_package || ' renew_cert_prd_enrollment';

rec_crt csr_crt%rowtype;
l_cert_enrl_rec csr_cert_enrl%ROWTYPE;

l_cert_enrollment_id ota_cert_enrollments.cert_enrollment_id%type;
l_cert_prd_enrollment_id  ota_cert_prd_enrollments.cert_prd_enrollment_id%type;

p_effective_date DATE;
p_business_group_id DATE;

l_certification_status_code VARCHAR2(30);

l_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;
l_expiration_date ota_cert_enrollments.expiration_date%type;

p_expiration_date date;


BEGIN

    hr_multi_message.enable_message_list;
    savepoint renew_cert_prd_enrollment_api;

    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    if (rec_crt.renewable_flag = 'Y') then
           ota_cpe_util.calc_cre_dates(p_cert_enrollment_id, rec_crt.certification_id, null, l_earliest_enroll_date, l_expiration_date, p_cert_period_start_date);
    end if; --end renewal flag

    ota_cpe_util.create_cpe_rec(p_cert_enrollment_id => p_cert_enrollment_id,
    				p_expiration_date => l_expiration_date,
    				p_cert_period_start_date => p_cert_period_start_date,
				p_cert_prd_enrollment_id => l_cert_prd_enrollment_id,
				p_certification_status_code => l_certification_status_code);


    OPEN csr_cert_enrl;
    FETCH csr_cert_enrl INTO l_cert_enrl_rec;
    CLOSE csr_cert_enrl;

    ota_cert_enrollment_api.update_cert_enrollment
			(p_effective_date => trunc(sysdate)
			,p_cert_enrollment_id           => p_cert_enrollment_id
			,p_certification_id             => l_cert_enrl_rec.certification_id
			,p_object_version_number        => l_cert_enrl_rec.object_version_number
			,p_certification_status_code    => l_cert_enrl_rec.certification_status_code
			,p_is_history_flag              => 'N'
			,p_earliest_enroll_date         => l_earliest_enroll_date
			);

    --set output params
    p_cert_prd_enrollment_id := l_cert_prd_enrollment_id;
    p_certification_status_code := l_certification_status_code;


    if p_validate then
     raise hr_api.validate_enabled;
    end if;

exception
  when hr_api.validate_enabled then
    --
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to renew_cert_prd_enrollment_api;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_cert_prd_enrollment_id  := null;
    p_certification_status_code := null;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to renew_cert_prd_enrollment_api;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_cert_prd_enrollment_id  := null;
    p_certification_status_code := null;

    hr_utility.set_location(' Leaving:' || l_proc,50);
    raise;
END renew_cert_prd_enrollment;
--
end OTA_CERT_PRD_ENROLLMENT_api;

/
