--------------------------------------------------------
--  DDL for Package Body HR_GRADE_SCALE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GRADE_SCALE_API" as
/* $Header: pepgsapi.pkb 120.1.12000000.1 2007/01/22 01:19:48 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_grade_scale.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< get_grade_scale_starting_step >----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_grade_scale_starting_step
 (p_grade_spine_id             IN NUMBER
 ,p_effective_date             IN DATE)
RETURN NUMBER
IS
   CURSOR csr_starting_step IS
      SELECT    nvl(pgs.starting_step,1)
        FROM    per_grade_spines_f pgs
       WHERE    pgs.grade_spine_id = p_grade_spine_id
         AND    p_effective_date between pgs.effective_start_date
                                     and pgs.effective_end_date;

 l_starting_step          per_grade_spines_f.starting_step%TYPE;

BEGIN

   OPEN csr_starting_step;
   FETCH csr_starting_step into l_starting_step;
   CLOSE csr_starting_step;

RETURN l_starting_step;

END get_grade_scale_starting_step;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_grade_scale >------------------------------|
-- ----------------------------------------------------------------------------
procedure create_grade_scale
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_grade_id                       in     number
  ,p_ceiling_point_id               in     number   default null
  ,p_starting_step                  in     number   default 1
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_ceiling_step_id                   out nocopy number
  ,p_grade_spine_id                    out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
 ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                     varchar2(72) := g_package||'create_grade_scale';
   l_effective_date           date;

   --
   -- Declare out parameters
   --
   l_grade_spine_id           per_grade_spines_f.grade_spine_id%TYPE;
   l_ceiling_step_id          per_grade_spines_f.ceiling_step_id%TYPE;
   l_object_version_number    per_grade_spines_f.object_version_number%TYPE;
   l_effective_start_date     date;
   l_effective_end_date       date;

   --
   -- Declare for per_spinal_point_steps_f
   l_sequence               per_spinal_points.sequence%TYPE;
   lv_object_version_number per_spinal_point_steps_f.object_version_number%TYPE;
   --
   cursor csr_get_sequence is
   select psp.sequence
     from per_spinal_points psp
    where psp.business_group_id = p_business_group_id
      and psp.spinal_point_id = p_ceiling_point_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_grade_scale;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User hook for create_grade_scale
  --
  begin
  hr_grade_scale_bk1.create_grade_scale_b
    (p_effective_date		     => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_grade_id                      => p_grade_id
    ,p_ceiling_point_id              => p_ceiling_point_id
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE_SCALE'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_grade_scale)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  l_ceiling_step_id := null;
  --
  -- Insert Grade scale
  --
  per_pgs_ins.ins
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_parent_spine_id               => p_parent_spine_id
  ,p_grade_id                      => p_grade_id
  ,p_request_id	                   => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_ceiling_step_id               => l_ceiling_step_id
  ,p_starting_step                 => p_starting_step
  ,p_grade_spine_id                => l_grade_spine_id
  ,p_object_version_number         => l_object_version_number
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- We need to create the Grade Step (Ceiling Step), if the
  -- parameter p_ceiling_point_id is passed with a value
  --
  if p_ceiling_point_id is not null then
     -- Needs to get the sequence of the ceiling point
     open csr_get_sequence;
     fetch csr_get_sequence into l_sequence;
     close csr_get_sequence;
     -- Call hr_grade_step_api.create_grade_step
     --
     hr_grade_step_api.create_grade_step
       (p_effective_date               => p_effective_date
       ,p_validate                     => p_validate
       ,p_business_group_id            => p_business_group_id
       ,p_spinal_point_id              => p_ceiling_point_id
       ,p_grade_spine_id               => l_grade_spine_id
       ,p_sequence                     => l_sequence
       ,p_step_id                      => l_ceiling_step_id
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       ,p_object_version_number        => lv_object_version_number
       );
     --
     hr_utility.set_location(l_proc, 60);
     --
     -- Update ceiling_step_id in per_grade_spines_f
     --
     per_pgs_upd.upd
       (p_effective_date                => l_effective_date
       ,p_datetrack_mode                => 'CORRECTION'
       ,p_grade_spine_id                => l_grade_spine_id
       ,p_object_version_number         => l_object_version_number
       ,p_ceiling_step_id               => l_ceiling_step_id
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date
       );
     --
     hr_utility.set_location(l_proc, 70);
     --
  end if;
  --
  -- Call After Process hook for create_grade_scale
  --
  begin
  hr_grade_scale_bk1.create_grade_scale_a
    (p_effective_date                => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_grade_id                      => p_grade_id
    ,p_ceiling_point_id              => p_ceiling_point_id
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_grade_spine_id                => l_grade_spine_id
    ,p_ceiling_step_id               => l_ceiling_step_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE_SCALE'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of after hook process (create_grade_scale)
  --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Set OUT parameters
  --
  p_grade_spine_id        := l_grade_spine_id;
  p_ceiling_step_id       := l_ceiling_step_id;
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 90);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_grade_scale;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_grade_spine_id            := null;
     p_ceiling_step_id           := null;
     p_object_version_number     := null;
     p_effective_start_date      := null;
     p_effective_end_date        := null;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     ROLLBACK TO create_grade_scale;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 110);
     --
     p_grade_spine_id            := null;
     p_ceiling_step_id           := null;
     p_object_version_number     := null;
     p_effective_start_date      := null;
     p_effective_end_date        := null;
     --
     raise;
     --
end create_grade_scale;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_grade_scale >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_scale
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date     default hr_api.g_date
  ,p_datetrack_mode                 in     varchar2
  ,p_grade_spine_id                 in     number
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in     number   default hr_api.g_number
  ,p_parent_spine_id                in     number   default hr_api.g_number
  ,p_grade_id                       in     number   default hr_api.g_number
  ,p_ceiling_step_id                in     number   default hr_api.g_number
  ,p_starting_step                  in     number   default hr_api.g_number
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                     varchar2(72) := g_package||'update_grade_scale';
   l_effective_date           date;
   lv_object_version_number   per_grade_spines_f.object_version_number%TYPE;

   --
   -- Declare out parameters
   --
   l_object_version_number    per_grade_spines_f.object_version_number%TYPE;
   l_effective_start_date     per_grade_spines_f.effective_start_date%TYPE;
   l_effective_end_date       per_grade_spines_f.effective_end_date%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint update_grade_scale;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- store object version number passed in
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User hook for create_grade_scale
  --
  begin
  hr_grade_scale_bk2.update_grade_scale_b
    (p_effective_date		     => l_effective_date
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_business_group_id             => p_business_group_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_grade_id                      => p_grade_id
    ,p_ceiling_step_id               => p_ceiling_step_id
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_object_version_number         => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GRADE_SCALE'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (update_grade_scale)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  l_object_version_number := p_object_version_number;

  --
  -- Update Progression Point
  --
  --
  per_pgs_upd.upd
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_object_version_number         => l_object_version_number
    ,p_business_group_id             => p_business_group_id
    ,p_parent_spine_id               => p_parent_spine_id
    ,p_grade_id                      => p_grade_id
    ,p_ceiling_step_id               => p_ceiling_step_id
    ,p_starting_step                 => p_starting_step
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    );

  --
  -- Assign the out parameters.
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for update_grade_scale
  --

  begin
  hr_grade_scale_bk2.update_grade_scale_a
  (p_effective_date                => l_effective_date
  ,p_datetrack_mode                => p_datetrack_mode
  ,p_grade_spine_id                => p_grade_spine_id
  ,p_object_version_number         => l_object_version_number
  ,p_business_group_id             => p_business_group_id
  ,p_parent_spine_id               => p_parent_spine_id
  ,p_grade_id                      => p_grade_id
  ,p_ceiling_step_id               => p_ceiling_step_id
  ,p_request_id	                   => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GRADE_SCALE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (update_grade_scale)
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 60);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     rollback to update_grade_scale;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_object_version_number     := p_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     rollback to update_grade_scale;
     --
     p_object_version_number     := lv_object_version_number;
     p_effective_start_date      := null;
     p_effective_end_date        := null;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end update_grade_scale;
--
-- Fix for bug 3472194 starts here.
--
------------------ delete_child_grade_steps --------------------
--
PROCEDURE delete_child_grade_steps
  (p_validate                  in  boolean
  ,p_effective_date            in  date
  ,p_datetrack_mode            in  varchar2
  ,p_grade_spine_id            in  number
  ) IS
--
  l_proc   varchar2(72) := g_package||'delete_child_grade_steps';
--
  cursor csr_chk_placements(p_date date) is
  select 'x'
  from per_spinal_point_steps_f sps
  where sps.grade_spine_id = p_grade_spine_id
  and exists (select null
       from per_spinal_point_placements_f spp
       where spp.step_id = sps.step_id
       and   p_date < spp.effective_end_date);
--
  cursor csr_chk_assignments(p_date date) is
  select 'x'
  from per_spinal_point_steps_f sps
  where sps.grade_spine_id = p_grade_spine_id
  and exists (select null
     from per_assignments_f a
     where a.special_ceiling_step_id = sps.step_id
     and a.special_ceiling_step_id is not null
     and   p_date < a.effective_end_date);
--
  cursor csr_chk_positions(p_date date) is
  select 'x'
  from per_spinal_point_steps_f sps
  where sps.grade_spine_id = p_grade_spine_id
  and exists (select null
     from hr_all_positions_f p
     where p.entry_step_id = sps.step_id
     and   p_date < p.effective_end_date);
--
  Cursor csr_grade_steps IS
  select distinct step_id
        ,min(effective_start_date) min_eff_start_date
        ,max(effective_end_date) max_eff_end_date
  from   per_spinal_point_steps_f
  where  grade_spine_id =  p_grade_spine_id
  group by step_id;
--
  Cursor csr_step_details(p_step_id number,p_eff_date date) IS
  select object_version_number
  from   per_spinal_point_steps_f
  where  step_id = p_step_id
  and    p_eff_date between effective_start_date and effective_end_date;
--
  Cursor csr_grade_spine_esd IS
  select min(effective_start_date)
  from   per_grade_spines_f
  where  grade_spine_id = p_grade_spine_id;
--
  l_object_version_number    per_spinal_point_steps_f.object_version_number%TYPE;
  l_effective_start_date     per_spinal_point_steps_f.effective_start_date%TYPE;
  l_effective_end_date       per_spinal_point_steps_f.effective_end_date%TYPE;
  l_min_eff_start_date       date;
  l_max_eff_end_date         date;
  l_date                     date;
  l_effective_date           date;
  l_datetrack_mode           varchar2(30);
  l_exists VARCHAR2(1);
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('Datetrack mode: '||p_datetrack_mode, 15);
  --
  l_date := p_effective_date;
  --
  -- Check if the steps are used in assignments or placements or positions.
  --
  -- Get the minimum start date of grade scale.
  --
  open csr_grade_spine_esd;
  fetch csr_grade_spine_esd into l_date;
  close csr_grade_spine_esd;
  --
  -- Need to check the existence of child records based on the DT mode.
  -- For DELETE mode, no child record should exists after the effective_date.
  -- For ZAp mode, no child record should exists on any date.
  --
  if p_datetrack_mode = hr_api.g_delete then
    l_date := p_effective_date;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  open csr_chk_placements(l_date);
  fetch csr_chk_placements into l_exists;
  IF csr_chk_placements%found THEN
    close csr_chk_placements;
    hr_utility.set_message(801, 'PER_7933_DEL_GRDSPN_PLACE');
    hr_utility.raise_error;
  END IF;
  close csr_chk_placements;
  --
  hr_utility.set_location(l_proc, 30);
  --
  open csr_chk_assignments(l_date);
  fetch csr_chk_assignments into l_exists;
  IF csr_chk_assignments%found THEN
    close csr_chk_assignments;
    hr_utility.set_message(801, 'PER_7934_DEL_GRDSPN_ASS');
    hr_utility.raise_error;
  END IF;
  close csr_chk_assignments;
  --
  hr_utility.set_location(l_proc, 40);
  --
  open csr_chk_positions(l_date);
  fetch csr_chk_positions into l_exists;
  IF csr_chk_positions%found THEN
    close csr_chk_positions;
    hr_utility.set_message(800, 'PER_449137_DEL_GRDSPN_POS');
    hr_utility.raise_error;
  END IF;
  close csr_chk_positions;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Delete all the child step records before deleting the Grade Scale.
  --
  FOR grade_step_rec in csr_grade_steps LOOP
    --
    -- Re-initialize the local variables with default values.
    --
    l_effective_date := trunc(p_effective_date);
    l_datetrack_mode := p_datetrack_mode;
    --
    hr_utility.set_location(l_proc, 60);
    IF grade_step_rec.min_eff_start_date > p_effective_date AND
       p_datetrack_mode = hr_api.g_delete THEN
      --
      -- ZAP the step using min effective_start_date as effective_date.
      --
      hr_utility.set_location(l_proc, 70);
      l_effective_date := grade_step_rec.min_eff_start_date;
      l_datetrack_mode := hr_api.g_zap;
      --
    ELSIF grade_step_rec.min_eff_start_date > p_effective_date AND
          p_datetrack_mode = hr_api.g_zap THEN
      --
      -- To ZAP the step, use the min effective_start_date as effective_date.
      --
      hr_utility.set_location(l_proc, 80);
      l_effective_date := grade_step_rec.min_eff_start_date;
      --
    ELSIF grade_step_rec.max_eff_end_date <= p_effective_date AND
          p_datetrack_mode = hr_api.g_zap THEN
      --
      -- To ZAp the step, use the min effective_start_date as effective_date.
      --
      hr_utility.set_location(l_proc, 90);
      l_effective_date := grade_step_rec.min_eff_start_date;
      --
    END IF;
    --
    hr_utility.set_location('l_effective_date: '||l_effective_date, 100);
    hr_utility.set_location('l_datetrack_mode'||l_datetrack_mode, 100);
    --
    IF not (grade_step_rec.max_eff_end_date <= p_effective_date AND
          p_datetrack_mode = hr_api.g_delete) THEN
      --
      -- Get the step details.
      --
      hr_utility.set_location(l_proc, 110);
      open  csr_step_details(grade_step_rec.step_id,l_effective_date);
      fetch csr_step_details into l_object_version_number;
      close csr_step_details;
      --
      hr_utility.set_location(l_datetrack_mode||' step: '||to_char(grade_step_rec.step_id), 120);
      --
      BEGIN
        hr_grade_step_api.delete_grade_step(
            p_validate               => p_validate
           ,p_step_id                => grade_step_rec.step_id
           ,p_effective_date         => l_effective_date
           ,p_datetrack_mode         => l_datetrack_mode
           ,p_Effective_Start_Date   => l_effective_start_date
           ,p_Effective_End_Date     => l_effective_end_date
           ,p_object_version_number  => l_object_version_number
	   ,p_called_from_del_grd_scale => TRUE    --bug 4096238
        );
      hr_utility.set_location(l_proc, 130);
      EXCEPTION
        when others then
        hr_utility.set_location(l_proc, 140);
        raise;
      END;
    END IF;
    --
    hr_utility.set_location(l_proc, 150);
  END LOOP;
 hr_utility.set_location('Leaving :'||l_proc, 160);
--
END;
--
-- Fix for bug 3472194 ends here.
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_grade_scale >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Fix for bug 3472194. This procedure will delete the associated grade step
-- records for dt mode DELETE and ZAP.
--
procedure delete_grade_scale
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_grade_spine_id                in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
) IS

  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'delete_grade_scale';
  l_effective_date         date;
  lv_object_version_number per_grade_spines_f.object_version_number%TYPE;


  --
  -- Declare out variables
  --
  l_object_version_number    per_grade_spines_f.object_version_number%TYPE;
  l_effective_start_date     per_grade_spines_f.effective_start_date%TYPE;
  l_effective_end_date       per_grade_spines_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_effective_date := trunc(p_effective_date);
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint delete_grade_scale;

  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_grade_scale_bk3.delete_grade_scale_b
    (p_effective_date             =>  l_effective_date
    ,p_datetrack_mode             =>  p_datetrack_mode
    ,p_grade_spine_id             =>  p_grade_spine_id
    ,p_object_version_number      =>  l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE_SCALE'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);

  --
  -- Process Logic
  --
  -- Fix for bug 3472194 starts here.
  -- Delete the child grade steps before deleting the grade scale.
  --
  IF p_datetrack_mode in (hr_api.g_delete, hr_api.g_zap) THEN
    hr_utility.set_location(l_proc, 25);
    delete_child_grade_steps
      (p_validate                  => p_validate
      ,p_effective_date            => l_effective_date
      ,p_datetrack_mode            => p_datetrack_mode
      ,p_grade_spine_id            => p_grade_spine_id
      );
  END IF;
  --
  -- Fix for bug 3472194 ends here.
  --
  per_pgs_del.del
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    );

  hr_utility.set_location(l_proc, 30);

  --
  -- Call After Process User Hook
  --
 begin
  hr_grade_scale_bk3.delete_grade_scale_a
    (p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_grade_spine_id                => p_grade_spine_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE_SCALE'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 40);

  p_object_version_number := l_object_version_number;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments (returned by some dt modes only)
  --
  p_object_version_number  := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 50);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_grade_scale;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    p_object_version_number := null;
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 60);
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_grade_scale;
     --
    -- set in out parameters and set out parameters
    --
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    p_object_version_number := lv_object_version_number;
    --
    raise;
--
end delete_grade_scale;
--
end hr_grade_scale_api;

/
