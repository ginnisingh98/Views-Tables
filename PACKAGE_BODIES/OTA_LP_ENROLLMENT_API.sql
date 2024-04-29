--------------------------------------------------------
--  DDL for Package Body OTA_LP_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_ENROLLMENT_API" as
/* $Header: otlpeapi.pkb 120.7.12010000.2 2009/05/21 09:36:15 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_LP_ENROLLMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_LP_ENROLLMENT    >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_lp_enrollment
(
 p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_learning_path_id             in number,
  p_person_id                    in number           default null,
  p_contact_id                   in number           default null,
  p_path_status_code             in varchar2,
  p_enrollment_source_code       in varchar2,
  p_no_of_mandatory_courses      in number           default null,
  p_no_of_completed_courses      in number           default null,
  p_completion_target_date       in date             default null,
  p_completion_date               in date             default null,
  p_creator_person_id            in number           default null,
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
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_IS_HISTORY_FLAG              in varchar2         default 'N',
  p_lp_enrollment_id             out nocopy number,
  p_object_version_number        out nocopy number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_lp_enrollment';
  l_lp_enrollment_id number;
  l_object_version_number   number;
  l_effective_date date;

  -- competency update associated with lps
  l_item_key		wf_items.item_key%TYPE;
  g_dummy             varchar2(1);

  CURSOR get_info_for_comp IS
  SELECT null
    FROM ota_learning_paths lps
   WHERE lps.learning_path_id = p_learning_path_id
     AND lps.path_source_code = 'CATALOG';

 cursor get_lp_type is
   select path_source_code
   from ota_learning_paths
   where learning_path_id = p_learning_path_id;

   l_type ota_learning_paths.path_source_code%type;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_LP_ENROLLMENT;
  l_effective_date := trunc(p_effective_date);


  begin
  ota_lp_enrollment_bk1.create_lp_enrollment_b
  (  p_effective_date               => p_effective_date
    ,p_validate                     => p_validate
    ,p_learning_path_id             => p_learning_path_id
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_path_status_code             => p_path_status_code
    ,p_enrollment_source_code       => p_enrollment_source_code
    ,p_no_of_mandatory_courses      => p_no_of_mandatory_courses
    ,p_no_of_completed_courses      => p_no_of_completed_courses
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date               => p_completion_date
    ,p_creator_person_id             => p_creator_person_id
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
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LP_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_lpe_ins.ins
  (
   p_effective_date                 =>   p_effective_date
  ,p_learning_path_id               =>   p_learning_path_id
  ,p_path_status_code               =>   p_path_status_code
  ,p_enrollment_source_code         =>   p_enrollment_source_code
  ,p_business_group_id              =>   p_business_group_id
  ,p_person_id                      =>   p_person_id
  ,p_contact_id                     =>   p_contact_id
  ,p_no_of_mandatory_courses        =>   p_no_of_mandatory_courses
  ,p_no_of_completed_courses        =>   p_no_of_completed_courses
  ,p_completion_target_date         =>   p_completion_target_date
  ,p_completion_date                =>   p_completion_date
  ,p_creator_person_id              =>   p_creator_person_id
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
  ,p_attribute21                    =>   p_attribute21
  ,p_attribute22                    =>   p_attribute22
  ,p_attribute23                    =>   p_attribute23
  ,p_attribute24                    =>   p_attribute24
  ,p_attribute25                    =>   p_attribute25
  ,p_attribute26                    =>   p_attribute26
  ,p_attribute27                    =>   p_attribute27
  ,p_attribute28                    =>   p_attribute28
  ,p_attribute29                    =>   p_attribute29
  ,p_attribute30                    =>   p_attribute30
  ,p_IS_HISTORY_FLAG                =>   p_IS_HISTORY_FLAG
  ,p_lp_enrollment_id               =>   l_lp_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_lp_enrollment_id        := l_lp_enrollment_id;
  p_object_version_number   := l_object_version_number;



  begin
  ota_lp_enrollment_bk1.create_lp_enrollment_a
  (  p_effective_date               => p_effective_date
    ,p_validate                     => p_validate
    ,p_learning_path_id             => p_learning_path_id
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_path_status_code             => p_path_status_code
    ,p_enrollment_source_code       => p_enrollment_source_code
    ,p_no_of_mandatory_courses      => p_no_of_mandatory_courses
    ,p_no_of_completed_courses      => p_no_of_completed_courses
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date              => p_completion_date
    ,p_creator_person_id            => p_creator_person_id
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
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LP_ENROLLMENT'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

     -- Added to check and test LP completion notifications
  IF p_path_status_code = 'COMPLETED' THEN
    OTA_LP_NOTIFY_SS.create_wf_process(
            p_lp_notification_type => 'LP_COMPLETE',
            p_lp_enrollment_id => p_lp_enrollment_id);
  END IF;
  -- End of added code to test LP Completion Notifications
  --competency update associated with LP
   OPEN get_info_for_comp;
  FETCH get_info_for_comp INTO g_dummy;
        IF get_info_for_comp%FOUND THEN
	   --Modified for Bug#3864084
           IF p_path_status_code = 'COMPLETED' AND p_person_id IS NOT NULL
	   and ('Y' = ota_lrng_path_util.is_path_successful(p_lp_enrollment_id => p_lp_enrollment_id))
	   THEN
              ota_competence_ss.create_wf_process(p_process		=> 'OTA_COMPETENCE_UPDATE_JSP_PRC',
                                                  p_itemtype		=> 'HRSSA',
                                                  p_person_id 		=> p_person_id,
                                                  p_eventid		=> null,
                                                  p_learningpath_ids	=> to_char(p_learning_path_id),
                                                  p_itemkey		=> l_item_key);
           END IF;
         END IF;
  CLOSE get_info_for_comp;

  -- fire notifications to Learner
open get_lp_type;
fetch get_lp_type into l_type;
close get_lp_type;

if l_type = 'CATALOG' or l_type = 'MANAGER' then

OTA_INITIALIZATION_WF.init_lp_wf(p_item_type => 'HRSSA',
                                p_lp_enrollment_id => p_lp_enrollment_id,
                                p_event_fired => 'LP_SUBSCRIBE');


end if;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_LP_ENROLLMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_lp_enrollment_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_LP_ENROLLMENT;
    p_lp_enrollment_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_lp_enrollment;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_LP_ENROLLMENT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_lp_enrollment
  (
 p_effective_date               in date,
  p_lp_enrollment_id             in number,
  p_object_version_number        in out nocopy number,
  p_person_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_path_status_code             in varchar2         default hr_api.g_varchar2,
  p_enrollment_source_code       in varchar2         default hr_api.g_varchar2,
  p_no_of_mandatory_courses      in number           default hr_api.g_number,
  p_no_of_completed_courses      in number           default hr_api.g_number,
  p_completion_target_date       in date             default hr_api.g_date,
  p_completion_date              in date             default hr_api.g_date,
  p_creator_person_id            in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_is_history_flag              in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false
   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Learning Path';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;

  -- competency update associated with lps
  l_item_key		wf_items.item_key%TYPE;
  l_learning_path_id    ota_lp_enrollments.learning_path_id%TYPE;
  l_person_id           ota_lp_enrollments.person_id%TYPE;
  l_path_status_code    ota_lp_enrollments.path_status_code%TYPE;
  l_proceed varchar2(1) := 'Y';


  CURSOR get_info_for_comp IS
	   --Modified for Bug#3864084
  SELECT lps.learning_path_id, lpe.person_id
    FROM ota_learning_paths lps,
         ota_lp_enrollments lpe
   WHERE lps.learning_path_id = lpe.learning_path_id
     AND lpe.lp_enrollment_id = p_lp_enrollment_id
     AND lps.path_source_code = 'CATALOG';

  --- modified by dbatra for source_type='SUITABILITY'
  Cursor is_suitability_LP is
  SELECT lps.learning_path_id
    FROM ota_learning_paths lps,
         ota_lp_enrollments lpe
   WHERE lps.learning_path_id = lpe.learning_path_id
     AND lpe.lp_enrollment_id = p_lp_enrollment_id
     AND lps.source_function_code = 'SUITABILITY';

      cursor get_lp_type is
   select lps.path_source_code , lpe.path_status_code
   from ota_learning_paths lps, ota_lp_enrollments lpe
   where lps.learning_path_id = lpe.learning_path_id
     AND lpe.lp_enrollment_id = p_lp_enrollment_id;

   l_type ota_learning_paths.path_source_code%type;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_LP_ENROLLMENT;
  l_effective_date := trunc(p_effective_date);

  begin
  ota_lp_enrollment_bk2.update_lp_enrollment_b
  (p_effective_date               => p_effective_date
    ,p_lp_enrollment_id             => p_lp_enrollment_id
    ,p_object_version_number        => l_object_version_number
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_path_status_code             => p_path_status_code
    ,p_enrollment_source_code       => p_enrollment_source_code
    ,p_no_of_mandatory_courses      => p_no_of_mandatory_courses
    ,p_no_of_completed_courses      => p_no_of_completed_courses
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date              => p_completion_date
    ,p_creator_person_id            => p_creator_person_id
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
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => p_validate
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LP_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

-- fire notifications to Learner
open get_lp_type;
fetch get_lp_type into l_type, l_path_status_code;
close get_lp_type;

  -- check for suitability LP
   OPEN is_suitability_LP;
   FETCH is_suitability_LP INTO l_learning_path_id;
   close is_suitability_LP;

     if l_learning_path_id is not null and p_path_status_code='COMPLETED' then
     -- don't update lp enrollment status to completed
        l_proceed :='N';
     end if;

  --
  -- Process Logic
  --
 if l_proceed = 'Y' then
 ota_lpe_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_lp_enrollment_id               =>   p_lp_enrollment_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_path_status_code               =>   p_path_status_code
  ,p_enrollment_source_code         =>   p_enrollment_source_code
  ,p_business_group_id              =>   p_business_group_id
  ,p_person_id                      =>   p_person_id
  ,p_contact_id                     =>   p_contact_id
  ,p_no_of_mandatory_courses        =>   p_no_of_mandatory_courses
  ,p_no_of_completed_courses        =>   p_no_of_completed_courses
  ,p_completion_target_date         =>   p_completion_target_date
  ,p_completion_date                =>   p_completion_date
  ,p_creator_person_id              =>   p_creator_person_id
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
  ,p_attribute21                    =>   p_attribute21
  ,p_attribute22                    =>   p_attribute22
  ,p_attribute23                    =>   p_attribute23
  ,p_attribute24                    =>   p_attribute24
  ,p_attribute25                    =>   p_attribute25
  ,p_attribute26                    =>   p_attribute26
  ,p_attribute27                    =>   p_attribute27
  ,p_attribute28                    =>   p_attribute28
  ,p_attribute29                    =>   p_attribute29
  ,p_attribute30                    =>   p_attribute30
  ,p_IS_HISTORY_FLAG                =>   p_IS_HISTORY_FLAG
  );
 end if;

  begin
  ota_lp_enrollment_bk2.update_lp_enrollment_a
  (p_effective_date               => p_effective_date
    ,p_lp_enrollment_id             => p_lp_enrollment_id
    ,p_object_version_number        => l_object_version_number
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_path_status_code             => p_path_status_code
    ,p_enrollment_source_code       => p_enrollment_source_code
    ,p_no_of_mandatory_courses      => p_no_of_mandatory_courses
    ,p_no_of_completed_courses      => p_no_of_completed_courses
    ,p_completion_target_date       => p_completion_target_date
    ,p_completion_date              => p_completion_date
    ,p_creator_person_id            => p_creator_person_id
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
    ,p_IS_HISTORY_FLAG              => p_IS_HISTORY_FLAG
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => p_validate
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LP_ENROLLMENT'
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
  p_object_version_number  := l_object_version_number;

  --competency update associated with LP
   OPEN get_info_for_comp;
  -- Modified for Bug#3864084
  FETCH get_info_for_comp INTO l_learning_path_id, l_person_id;
        IF get_info_for_comp%FOUND THEN
           IF p_path_status_code = 'COMPLETED' AND l_person_id IS NOT NULL
	   and ('Y' = ota_lrng_path_util.is_path_successful(p_lp_enrollment_id => p_lp_enrollment_id))
	   --Added for bug#5054787
	   AND l_path_status_code <> 'COMPLETED'
	   THEN
              ota_competence_ss.create_wf_process(p_process		=> 'OTA_COMPETENCE_UPDATE_JSP_PRC',
                                                  p_itemtype		=> 'HRSSA',
                                                  p_person_id 	        => l_person_id,
                                                  p_eventid		=> null,
                                                  p_learningpath_ids	=> to_char(l_learning_path_id),
                                                  p_itemkey		=> l_item_key);
           END IF;
         END IF;
  CLOSE get_info_for_comp;
  --
      -- Added to check and test LP completion notifications
  -- IF p_path_status_code = 'COMPLETED' THEN
  IF p_path_status_code = 'COMPLETED'
   AND l_proceed ='Y'
    --Added for bug#5054787
   AND l_path_status_code <> 'COMPLETED' THEN
    OTA_LP_NOTIFY_SS.create_wf_process(
            p_lp_notification_type => 'LP_COMPLETE',
            p_lp_enrollment_id => p_lp_enrollment_id);
  END IF;
  -- End of added code to test LP Completion Notifications

if (l_type = 'CATALOG' or l_type = 'MANAGER') and
p_path_status_code = 'CANCELLED' and l_proceed ='Y' then

OTA_INITIALIZATION_WF.init_lp_wf(p_item_type => 'HRSSA',
                                p_lp_enrollment_id => p_lp_enrollment_id,
                                p_event_fired => 'LP_UNSUBSCRIBE');
end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_LP_ENROLLMENT;
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
    rollback to UPDATE_LP_ENROLLMENT;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_lp_enrollment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_LP_ENROLLMENT >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_enrollment
  (p_lp_enrollment_id              in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'DELETE_LP_ENROLLMENT';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_LP_ENROLLMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  ota_lp_enrollment_bk3.delete_lp_enrollment_b
  (p_lp_enrollment_id             => p_lp_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LP_ENROLLMENT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  ota_lpe_del.del
  (
  p_lp_enrollment_id         => p_lp_enrollment_id             ,
  p_object_version_number    => p_object_version_number
  );


  begin
  ota_lp_enrollment_bk3.delete_lp_enrollment_a
  (p_lp_enrollment_id             => p_lp_enrollment_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LP_ENROLLMENT'
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
    rollback to DELETE_LP_ENROLLMENT;
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
    rollback to DELETE_LP_ENROLLMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_lp_enrollment;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< SUBSCRIBE_TO_LEARNING_PATH>-------------------------|
-- ----------------------------------------------------------------------------
procedure subscribe_to_learning_path
  (p_validate in boolean default false
  ,p_learning_path_id IN NUMBER
  ,p_person_id IN NUMBER default null
  ,p_contact_id IN NUMBER default null
  ,p_enrollment_source_code IN VARCHAR2
   ,p_business_group_id IN NUMBER
   ,p_creator_person_id IN NUMBER
   ,p_attribute_category IN VARCHAR2 default NULL
       ,p_attribute1                   IN VARCHAR2 default NULL
    ,p_attribute2                   IN VARCHAR2 default NULL
    ,p_attribute3                   IN VARCHAR2 default NULL
    ,p_attribute4                  IN VARCHAR2 default NULL
    ,p_attribute5                  IN VARCHAR2 default NULL
    ,p_attribute6                   IN VARCHAR2 default NULL
    ,p_attribute7                  IN VARCHAR2 default NULL
    ,p_attribute8                 IN VARCHAR2 default NULL
    ,p_attribute9                 IN VARCHAR2 default NULL
    ,p_attribute10                 IN VARCHAR2 default NULL
    ,p_attribute11              IN VARCHAR2 default NULL
    ,p_attribute12               IN VARCHAR2 default NULL
    ,p_attribute13               IN VARCHAR2 default NULL
    ,p_attribute14                IN VARCHAR2 default NULL
    ,p_attribute15                IN VARCHAR2 default NULL
    ,p_attribute16                  IN VARCHAR2 default NULL
    ,p_attribute17                 IN VARCHAR2 default NULL
    ,p_attribute18                 IN VARCHAR2 default NULL
    ,p_attribute19                IN VARCHAR2 default NULL
    ,p_attribute20                 IN VARCHAR2 default NULL
    ,p_attribute21                 IN VARCHAR2 default NULL
    ,p_attribute22                IN VARCHAR2 default NULL
    ,p_attribute23               IN VARCHAR2 default NULL
    ,p_attribute24                 IN VARCHAR2 default NULL
    ,p_attribute25              IN VARCHAR2 default NULL
    ,p_attribute26                 IN VARCHAR2 default NULL
    ,p_attribute27                  IN VARCHAR2 default NULL
    ,p_attribute28                  IN VARCHAR2 default NULL
    ,p_attribute29                 IN VARCHAR2 default NULL
    ,p_attribute30                  IN VARCHAR2 default NULL
  ,p_lp_enrollment_id OUT NOCOPY number
  ,p_path_status_code OUT NOCOPY VARCHAR2
  ) IS
l_total_number_of_courses number;

CURSOR csr_get_lp_details IS
select duration
from ota_learning_paths
where learning_path_id = p_learning_path_id;

CURSOR csr_get_lpms IS
select learning_path_member_id, activity_version_id, duration, learning_path_section_id
from ota_learning_path_members
where learning_path_id = p_learning_path_id;

CURSOR csr_get_lpe_details IS
select path_status_code, no_of_completed_courses, object_version_number, completion_date
FROM ota_lp_enrollments
where lp_enrollment_id = p_lp_enrollment_id;

l_proc    varchar2(72) := g_package || ' subscribe_to_learning_path';
l_lp_rec csr_get_lp_details%ROWTYPE;
l_lpm_rec csr_get_lpms%ROWTYPE;
l_lpe_rec csr_get_lpe_details%ROWTYPE;
l_no_of_completed_courses NUMBER;
l_completion_status VARCHAR2(30);
l_object_version_number1 number;
l_object_version_number2 number;
l_completion_date DATE;
l_lp_member_enrollment_id NUMBER;

l_attribute_category VARCHAR2(30) := p_attribute_category;
l_attribute1 VARCHAR2(150) := p_attribute1 ;
l_attribute2 VARCHAR2(150) := p_attribute2 ;
l_attribute3 VARCHAR2(150) := p_attribute3 ;
l_attribute4 VARCHAR2(150) := p_attribute4 ;
l_attribute5 VARCHAR2(150) := p_attribute5 ;
l_attribute6 VARCHAR2(150) := p_attribute6 ;
l_attribute7 VARCHAR2(150) := p_attribute7 ;
l_attribute8 VARCHAR2(150) := p_attribute8 ;
l_attribute9 VARCHAR2(150) := p_attribute9 ;
l_attribute10 VARCHAR2(150) := p_attribute10 ;
l_attribute11 VARCHAR2(150) := p_attribute11 ;
l_attribute12 VARCHAR2(150) := p_attribute12 ;
l_attribute13 VARCHAR2(150) := p_attribute13 ;
l_attribute14 VARCHAR2(150) := p_attribute14 ;
l_attribute15 VARCHAR2(150) := p_attribute15 ;
l_attribute16 VARCHAR2(150) := p_attribute16 ;
l_attribute17 VARCHAR2(150) := p_attribute17 ;
l_attribute18 VARCHAR2(150) := p_attribute18 ;
l_attribute19 VARCHAR2(150) := p_attribute19 ;
l_attribute20 VARCHAR2(150) := p_attribute20 ;
l_attribute21 VARCHAR2(150) := p_attribute21 ;
l_attribute22 VARCHAR2(150) := p_attribute22 ;
l_attribute23 VARCHAR2(150) := p_attribute23 ;
l_attribute24 VARCHAR2(150) := p_attribute24 ;
l_attribute25 VARCHAR2(150) := p_attribute25 ;
l_attribute26 VARCHAR2(150) := p_attribute26 ;
l_attribute27 VARCHAR2(150) := p_attribute27 ;
l_attribute28 VARCHAR2(150) := p_attribute28 ;
l_attribute29 VARCHAR2(150) := p_attribute29 ;
l_attribute30 VARCHAR2(150) := p_attribute30 ;

  BEGIN

     l_total_number_of_courses := ota_lrng_path_util.get_no_of_mandatory_courses(p_learning_path_id => p_learning_path_id
														,p_path_source_code => 'CATALOG');
      OPEN csr_get_lp_details;
      FETCH csr_get_lp_details INTO l_lp_rec;
      CLOSE csr_get_lp_details;

      savepoint create_lp_subscription;
      ota_utility.Get_Default_Value_Dff(
					   appl_short_name => 'OTA'
                      ,flex_field_name => 'OTA_LP_ENROLLMENTS'
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
					  ,p_attribute21                  => l_attribute21
					  ,p_attribute22                  => l_attribute22
					  ,p_attribute23                  => l_attribute23
					  ,p_attribute24                  => l_attribute24
					  ,p_attribute25                  => l_attribute25
					  ,p_attribute26                  => l_attribute26
					  ,p_attribute27                  => l_attribute27
					  ,p_attribute28                  => l_attribute28
					  ,p_attribute29                  => l_attribute29
					  ,p_attribute30                  => l_attribute30);

     ota_lp_enrollment_api.create_lp_enrollment(
      p_effective_date => trunc(sysdate)
	 ,p_validate => p_validate
	 ,p_learning_path_id => p_learning_path_id
	  ,p_person_id => p_person_id
	  ,p_contact_id => p_contact_id
	  ,p_path_status_code => 'ACTIVE'
	  ,p_enrollment_source_code => p_enrollment_source_code
	  ,p_no_of_mandatory_courses =>l_total_number_of_courses
	  ,p_completion_target_date =>  sysdate + l_lp_rec.duration -1
      ,p_business_group_id => p_business_group_id
	  ,p_lp_enrollment_id => p_lp_enrollment_id
      ,p_object_version_number => l_object_version_number1
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
    ,p_attribute21                  => l_attribute21
    ,p_attribute22                  => l_attribute22
    ,p_attribute23                  => l_attribute23
    ,p_attribute24                  => l_attribute24
    ,p_attribute25                  => l_attribute25
    ,p_attribute26                  => l_attribute26
    ,p_attribute27                  => l_attribute27
    ,p_attribute28                  => l_attribute28
    ,p_attribute29                  => l_attribute29
    ,p_attribute30                  => l_attribute30
    -- Added for bug#5161382
    ,p_creator_person_id            => p_creator_person_id
	  );
l_attribute_category := NULL;
l_attribute1  := NULL  ;
l_attribute2  := NULL  ;
l_attribute3  := NULL  ;
l_attribute4  := NULL  ;
l_attribute5  := NULL  ;
l_attribute6  := NULL  ;
l_attribute7  := NULL  ;
l_attribute8  := NULL  ;
l_attribute9  := NULL  ;
l_attribute10  := NULL  ;
l_attribute11  := NULL  ;
l_attribute12  := NULL  ;
l_attribute13  := NULL  ;
l_attribute14  := NULL  ;
l_attribute15  := NULL  ;
l_attribute16  := NULL  ;
l_attribute17  := NULL  ;
l_attribute18  := NULL  ;
l_attribute19  := NULL  ;
l_attribute20  := NULL ;
l_attribute21  := NULL  ;
l_attribute22  := NULL  ;
l_attribute23  := NULL  ;
l_attribute24  := NULL  ;
l_attribute25  := NULL  ;
l_attribute26  := NULL  ;
l_attribute27  := NULL  ;
l_attribute28  := NULL  ;
l_attribute29  := NULL  ;
l_attribute30  := NULL  ;

     ota_utility.Get_Default_Value_Dff(
					   appl_short_name => 'OTA'
                      ,flex_field_name => 'OTA_LP_MEMBER_ENROLLMENTS'
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
					  ,p_attribute21                  => l_attribute21
					  ,p_attribute22                  => l_attribute22
					  ,p_attribute23                  => l_attribute23
					  ,p_attribute24                  => l_attribute24
					  ,p_attribute25                  => l_attribute25
					  ,p_attribute26                  => l_attribute26
					  ,p_attribute27                  => l_attribute27
					  ,p_attribute28                  => l_attribute28
					  ,p_attribute29                  => l_attribute29
					  ,p_attribute30                  => l_attribute30);
     FOR l_lpm_rec IN csr_get_lpms LOOP
        ota_lp_member_enrollment_api.create_lp_member_enrollment(
	     p_effective_date => trunc(sysdate)
	    ,p_validate => p_validate
	    ,p_lp_enrollment_id => p_lp_enrollment_id
	    ,p_learning_path_section_id => l_lpm_rec.learning_path_section_id
	    ,p_learning_path_member_id => l_lpm_rec.learning_path_member_id
	    ,p_member_status_code => 'PLANNED'
	    ,p_completion_target_date => l_lpm_rec.duration + sysdate -1
	    ,p_business_group_id => p_business_group_id
	    ,p_lp_member_enrollment_id => l_lp_member_enrollment_id
        ,p_object_version_number => l_object_version_number2
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
					  ,p_attribute21                  => l_attribute21
					  ,p_attribute22                  => l_attribute22
					  ,p_attribute23                  => l_attribute23
					  ,p_attribute24                  => l_attribute24
					  ,p_attribute25                  => l_attribute25
					  ,p_attribute26                  => l_attribute26
					  ,p_attribute27                  => l_attribute27
					  ,p_attribute28                  => l_attribute28
					  ,p_attribute29                  => l_attribute29
					  ,p_attribute30                  => l_attribute30    );
     END LOOP;

     OPEN csr_get_lpe_details;
     FETCH csr_get_lpe_details INTO l_lpe_rec;
     CLOSE csr_get_lpe_details;

     l_no_of_completed_courses := ota_lrng_path_util.get_no_of_completed_courses(
                                       p_lp_enrollment_id => p_lp_enrollment_id,
                                       p_path_source_code => 'CATALOG');
     p_path_status_code := l_lpe_rec.path_status_code;
     l_completion_date := l_lpe_rec.completion_date;

     --Bug 4615753
     --this update is reqd for no_of_completed_courses values at lpe
     --which wouldn't be populated otherwise and call to chk_complete_path_ok
     --would never return 'S' even if all its components are in Completed status
     ota_lp_enrollment_api.update_lp_enrollment
                       (p_effective_date               => sysdate
                       ,p_validate => p_validate
                       ,p_lp_enrollment_id             => p_lp_enrollment_id
                       ,p_object_version_number        => l_lpe_rec.object_version_number
		               ,p_no_of_completed_courses      => l_no_of_completed_courses
                       ,p_path_status_code             => p_path_status_code
                       ,p_completion_date              => l_completion_date);

     l_completion_status := ota_lrng_path_util.chk_complete_path_ok(p_lp_enrollment_id => p_lp_enrollment_id);

     IF l_completion_status = 'S' THEN
          p_path_status_code := 'COMPLETED';
          --l_completion_date := trunc(sysdate);
          l_completion_date := ota_lrng_path_member_util.get_lp_completion_date(p_lp_enrollment_id);
          --mark lpe as Completed
          OPEN csr_get_lpe_details;
          FETCH csr_get_lpe_details INTO l_lpe_rec;
          CLOSE csr_get_lpe_details;

          ota_lp_enrollment_api.update_lp_enrollment
                       (p_effective_date               => sysdate
                       ,p_validate                     => p_validate
                       ,p_lp_enrollment_id             => p_lp_enrollment_id
                       ,p_object_version_number        => l_lpe_rec.object_version_number
                       ,p_path_status_code             => p_path_status_code
                       ,p_completion_date              => l_completion_date);
     END IF;

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
    rollback to create_lp_subscription;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_lp_enrollment_id  := null;
    p_path_status_code := null;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_lp_subscription;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_lp_enrollment_id  := null;
    p_path_status_code := null;

    hr_utility.set_location(' Leaving:' || l_proc,50);
    raise;
  END subscribe_to_learning_path;
end ota_lp_enrollment_api;


/
