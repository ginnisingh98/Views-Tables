--------------------------------------------------------
--  DDL for Package Body HR_VALID_GRADE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_VALID_GRADE_API" as
/* $Header: pevgrapi.pkb 120.0 2005/05/31 22:57:51 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_valid_grade_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_valid_grade >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_valid_grade
  (p_validate                      in     boolean  default false
  ,p_grade_id                      in     number
  ,p_date_from                     in     date
  ,p_effective_date		           in 	  date    --Added for bug# 1760707
  ,p_comments                      in     varchar2 default null
  ,p_date_to                       in     date     default null
  ,p_job_id                        in     number   default null
  ,p_position_id                   in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_valid_grade_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id   per_valid_grades.business_group_id%TYPE;
  l_proc                varchar2(72) := g_package||'create_valid_grade';

  --
  --
  --   Variables added for before and after busines process
  --
  l_valid_grade_id           number;
  l_object_version_number    number;
  l_date_from		     date;
  l_date_to		     date;


  cursor csr_bus_grp is
  select gra.business_group_id
    from per_grades gra
   where gra.grade_id = p_grade_id;
  --
  begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_valid_grade;
  l_date_from :=trunc(p_date_from);
  l_date_to   :=trunc(p_date_to);
  --
  -- Check that p_grade_id is not null as it is used in the cursor.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'grade_id',
     p_argument_value => p_grade_id);
  --
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Get business_group_id using grade_id.
  --
  open  csr_bus_grp;
  fetch csr_bus_grp
   into l_business_group_id;
  --
  if csr_bus_grp%notfound then
    close csr_bus_grp;
    hr_utility.set_message(801, 'HR_51082_GRADE_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  --
  close csr_bus_grp;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Call before Process User Hook point create_valid_grade
  --
  begin
    hr_valid_grade_bk1.create_valid_grade_b
    (p_business_group_id             => l_business_group_id
    ,p_grade_id                      => p_grade_id
    ,p_date_from                     => l_date_from
    ,p_effective_date		     => p_effective_date   --Added for bug# 1760707
    ,p_comments                      => p_comments
    ,p_date_to                       => l_date_to
    ,p_job_id                        => p_job_id
    ,p_position_id                   => p_position_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
     );
   exception
    when hr_api.Cannot_Find_Prog_Unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VALID_GRADE'
        ,p_hook_type   => 'BP'
        );
  --
  --
  -- End of API User Hook for the before process hook point create_valid_grade
   end;
  --
  --
  -- Insert Valid Grade details.
  --
  per_vgr_ins.ins
  (p_valid_grade_id               => l_valid_grade_id
  ,p_business_group_id            => l_business_group_id
  ,p_grade_id                     => p_grade_id
  ,p_date_from                    => p_date_from
  ,p_effective_date		          => p_effective_date  --Added for bug# 1760707
  ,p_comments                     => p_comments
  ,p_date_to                      => l_date_to
  ,p_job_id                       => p_job_id
  ,p_position_id                  => p_position_id
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
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => FALSE
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call after Process User Hook point create_valid_grade
  --
  begin
    hr_valid_grade_bk1.create_valid_grade_a
    (p_business_group_id             => l_business_group_id
    ,p_grade_id                      => p_grade_id
    ,p_date_from                     => l_date_from
    ,p_effective_date		     => p_effective_date   --Added for bug# 1760707
    ,p_comments                      => p_comments
    ,p_date_to                       => l_date_to
    ,p_job_id                        => p_job_id
    ,p_position_id                   => p_position_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_valid_grade_id                => l_valid_grade_id
    ,p_object_version_number         => l_object_version_number
    );
  exception
    when hr_api.Cannot_Find_Prog_Unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VALID_GRADE'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of API User Hook for the after process hook point create_valid_grade
  --
  end;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --  Set all output arguments
  --
    p_valid_grade_id                :=  l_valid_grade_id;
    p_object_version_number         :=  l_object_version_number;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
  exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_valid_grade;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_valid_grade_id             := null;
    p_object_version_number      := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_valid_grade;
    -- Reset IN OUT parameters and set OUT parameters
     p_valid_grade_id             := null;
    p_object_version_number      := null;
    raise;
    --
    -- End of fix.
    --
--
end create_valid_grade;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_valid_grades >-----------------------|
-- ----------------------------------------------------------------------------
procedure update_valid_grades_for_job
              (p_business_group_id    number,
               p_job_id               number,
               p_date_to              date)
               is
--
begin
   --
   -- Update valid grade end dates to match the end date of the
   -- job where the end date of the job is earlier than the end
   -- date of the valid grade.or the previous end dates matched.
   --
   --
   update per_valid_grades vg
   set vg.date_to =
   (select least(nvl(p_date_to, to_date('12/31/4712','mm/dd/yyyy')),
                 nvl(g.date_to, to_date('12/31/4712','mm/dd/yyyy')))
         from   per_grades g
    where  g.grade_id          = vg.grade_id
    and    g.business_group_id + 0 = p_business_group_id)
   where vg.business_group_id + 0 = p_business_group_id
   and   vg.job_id            = p_job_id
   and   nvl(vg.date_to, to_date('12/31/4712','mm/dd/yyyy')) > p_date_to;
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','update_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
   --
end update_valid_grades_for_job;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_valid_grades >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_valid_grades_for_job
              (p_business_group_id    number,
               p_job_id               number,
               p_date_to              date) is
--
begin
   --
   -- Valid grades are deleted if the end date of the job
   -- has been made earlier than the start date of the
   -- valid grade.
   --
   --
   delete from per_valid_grades vg
   where  vg.business_group_id + 0 = p_business_group_id
   and    vg.job_id            = p_job_id
   and    vg.date_from         > p_date_to;
   --
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','delete_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
end delete_valid_grades_for_job;
end hr_valid_grade_api;
--

/
