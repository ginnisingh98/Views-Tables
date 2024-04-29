--------------------------------------------------------
--  DDL for Package Body HR_CAGR_GRADES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_GRADES_API" as
/* $Header: pegraapi.pkb 115.9 2004/04/20 03:11:15 adudekul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_cagr_grades_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_concat_segs >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_concat_segs
  (p_cagr_grade_def_id     IN per_cagr_grades_def.cagr_grade_def_id%TYPE
  ,p_concatenated_segments IN per_cagr_grades_def.concatenated_segments%TYPE) is
--
  l_proc VARCHAR2(72) := g_package||'update_concat_segs';
  l_concat_segments per_cagr_grades_def.concatenated_segments%TYPE;
  l_cagr_found varchar2(1) := 'N';
--
  CURSOR  get_concat_segs IS
    SELECT  concatenated_segments
    FROM    per_cagr_grades_def
    WHERE   cagr_grade_def_id = p_cagr_grade_def_id;
--
  procedure update_concat_segs_auto
    (p_cagr_grade_def_id in number) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_cagr_lock is
      SELECT null
        FROM per_cagr_grades_def
        where cagr_grade_def_id = p_cagr_grade_def_id
        for update nowait;
    --
    l_exists  varchar2(30);
    l_proc    varchar2(72) := g_package||'update_concat_segs_auto';
    --
  begin
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    open csr_cagr_lock;
    fetch csr_cagr_lock into l_exists;
    if csr_cagr_lock%found then
      close csr_cagr_lock;
      --
      hr_utility.set_location(l_proc, 20);
      --
      UPDATE  per_cagr_grades_def
      SET     concatenated_segments  = p_concatenated_segments
      WHERE   cagr_grade_def_id      = p_cagr_grade_def_id;
      --
      commit;
    else
      close csr_cagr_lock;
      rollback; -- Added for bug 3578845.
    end if;
    --
    hr_utility.set_location('Leaving:'|| l_proc, 30);
    --
  Exception
    When HR_Api.Object_Locked then
      rollback; -- Added for bug 3578845.
      hr_utility.set_location('Leaving:'|| l_proc, 40);
  end update_concat_segs_auto;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN  get_concat_segs;
  FETCH get_concat_segs INTO l_concat_segments;
  if get_concat_segs%found then
    l_cagr_found := 'Y';
  else
    l_cagr_found := 'N';
  end if;
  CLOSE get_concat_segs;
  --
  hr_utility.set_location(l_proc,20);
  --
  IF (l_concat_segments <> p_concatenated_segments) OR
     (l_concat_segments IS NULL AND p_concatenated_segments IS NOT NULL) THEN
    --
     hr_utility.set_location(l_proc, 30);
    --
     if l_cagr_found = 'Y' then
       update_concat_segs_auto(p_cagr_grade_def_id);
     end if;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 999);
  --
end update_concat_segs;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cagr_grades >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_grades
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_id                  out nocopy number
  ,p_cagr_grade_structure_id        in  number    default null
  ,p_segment1            in  varchar2  default null
  ,p_segment2            in  varchar2  default null
  ,p_segment3            in  varchar2  default null
  ,p_segment4            in  varchar2  default null
  ,p_segment5            in  varchar2  default null
  ,p_segment6            in  varchar2  default null
  ,p_segment7            in  varchar2  default null
  ,p_segment8            in  varchar2  default null
  ,p_segment9            in  varchar2  default null
  ,p_segment10           in  varchar2  default null
  ,p_segment11           in  varchar2  default null
  ,p_segment12           in  varchar2  default null
  ,p_segment13           in  varchar2  default null
  ,p_segment14           in  varchar2  default null
  ,p_segment15           in  varchar2  default null
  ,p_segment16           in  varchar2  default null
  ,p_segment17           in  varchar2  default null
  ,p_segment18           in  varchar2  default null
  ,p_segment19           in  varchar2  default null
  ,p_segment20           in  varchar2  default null
  ,p_concat_segments        in  varchar2  default null
  ,p_sequence                       in  number    default null
  ,p_cagr_grade_def_id              in out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_name                  out nocopy varchar2
  ,p_effective_date         in date) is
  --
  -- Declare cursors and local variables
  --
  l_cagr_grade_id per_cagr_grades.cagr_grade_id%TYPE;
  l_temp_grade_def_id per_cagr_grades.cagr_grade_def_id%TYPE  := p_cagr_grade_def_id;
  l_proc varchar2(72) := g_package||'create_cagr_grades';
  l_object_version_number per_cagr_grades.object_version_number%TYPE;
  l_id_flex_num  per_cagr_grade_structures.id_flex_num%TYPE;
  l_cagr_grade_def_id per_cagr_grades.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;
  l_name varchar2(240) := p_concat_segments;
  --
  -- bug 2284889 set up and initialize local segment values for use when
  -- definition id is known, also create new variable to indicate
  -- whether key flex id parameter enters the program with a value.
  --
  l_segment1                 varchar2(60) := p_segment1;
  l_segment2                 varchar2(60) := p_segment2;
  l_segment3                 varchar2(60) := p_segment3;
  l_segment4                 varchar2(60) := p_segment4;
  l_segment5                 varchar2(60) := p_segment5;
  l_segment6                 varchar2(60) := p_segment6;
  l_segment7                 varchar2(60) := p_segment7;
  l_segment8                 varchar2(60) := p_segment8;
  l_segment9                 varchar2(60) := p_segment9;
  l_segment10                varchar2(60) := p_segment10;
  l_segment11                varchar2(60) := p_segment11;
  l_segment12                varchar2(60) := p_segment12;
  l_segment13                varchar2(60) := p_segment13;
  l_segment14                varchar2(60) := p_segment14;
  l_segment15                varchar2(60) := p_segment15;
  l_segment16                varchar2(60) := p_segment16;
  l_segment17                varchar2(60) := p_segment17;
  l_segment18                varchar2(60) := p_segment18;
  l_segment19                varchar2(60) := p_segment19;
  l_segment20                varchar2(60) := p_segment20;
  l_null_ind                 number(1)    := 0;
  --
  cursor csr_id_flex_num is
    select pcg.id_flex_num
      from per_cagr_grade_structures pcg
     where pcg.cagr_grade_structure_id = p_cagr_grade_structure_id;
  --
  -- bug 2284889 get per_competence_definition segment values where
  -- competence_definition_id is known
  --
  cursor c_segments is
    select segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20
      from per_cagr_grades_def
     where cagr_grade_def_id = l_cagr_grade_def_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_cagr_grades;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if l_cagr_grade_def_id is not null
  --
  then
  --
     hr_utility.set_location(l_proc, 15);
     --
     -- set indicator to show p_cagr_grade_def_id did not enter pgm null
     --
     l_null_ind := 1;
     --
     open c_segments;
        fetch c_segments into
                      l_segment1,
                      l_segment2,
                      l_segment3,
                      l_segment4,
                      l_segment5,
                      l_segment6,
                      l_segment7,
                      l_segment8,
                      l_segment9,
                      l_segment10,
                      l_segment11,
                      l_segment12,
                      l_segment13,
                      l_segment14,
                      l_segment15,
                      l_segment16,
                      l_segment17,
                      l_segment18,
                      l_segment19,
                      l_segment20;
     if c_segments%NOTFOUND OR c_segments%NOTFOUND IS NULL
     then
        l_cagr_grade_def_id := NULL;
        l_null_ind := 0;
        hr_utility.set_location(l_proc, 27);
     end if;
     close c_segments;
  end if;
  --
  -- Process Logic
  --
  begin
  --
    -- Start of API User Hook for the before hook of create_cagr_grades
    --
    hr_cagr_grades_bk1.create_cagr_grades_b
      (
       p_cagr_grade_structure_id        =>  p_cagr_grade_structure_id
      ,p_sequence                       =>  p_sequence
      ,p_segment1            =>  l_segment1
      ,p_segment2            =>  l_segment2
      ,p_segment3            =>  l_segment3
      ,p_segment4            =>  l_segment4
      ,p_segment5            =>  l_segment5
      ,p_segment6            =>  l_segment6
      ,p_segment7            =>  l_segment7
      ,p_segment8            =>  l_segment8
      ,p_segment9            =>  l_segment9
      ,p_segment10              =>  l_segment10
      ,p_segment11              =>  l_segment11
      ,p_segment12              =>  l_segment12
      ,p_segment13              =>  l_segment13
      ,p_segment14              =>  l_segment14
      ,p_segment15              =>  l_segment15
      ,p_segment16              =>  l_segment16
      ,p_segment17              =>  l_segment17
      ,p_segment18              =>  l_segment18
      ,p_segment19              =>  l_segment19
      ,p_segment20              =>  l_segment20
      ,p_concat_segments      =>  p_concat_segments
      ,p_effective_date       =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CAGR_GRADES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_cagr_grades
    --
  end;
  --
  -- Populate l_id_flex_num.
  --
  open csr_id_flex_num;
  fetch csr_id_flex_num
  into l_id_flex_num;
    if csr_id_flex_num%NOTFOUND then
       close csr_id_flex_num;
          hr_utility.set_message(800,'PER_52810_INVALID_STRUCTURE');
          hr_utility.raise_error;
     end if;
  close csr_id_flex_num;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if l_cagr_grade_def_id is null then
     l_null_ind := 0;
     --
     hr_utility.set_location(l_proc, 37);
     --
     --
     -- Determine the Grade defintion by calling ins_or_sel
     --
     hr_kflex_utility.ins_or_sel_keyflex_comb
     (p_appl_short_name       => 'PER'
     ,p_flex_code             => 'CAGR'
     ,p_flex_num              => l_id_flex_num
     ,p_segment1              => l_segment1
     ,p_segment2              => l_segment2
     ,p_segment3              => l_segment3
     ,p_segment4              => l_segment4
     ,p_segment5              => l_segment5
     ,p_segment6              => l_segment6
     ,p_segment7              => l_segment7
     ,p_segment8              => l_segment8
     ,p_segment9              => l_segment9
     ,p_segment10             => l_segment10
     ,p_segment11             => l_segment11
     ,p_segment12             => l_segment12
     ,p_segment13             => l_segment13
     ,p_segment14             => l_segment14
     ,p_segment15             => l_segment15
     ,p_segment16             => l_segment16
     ,p_segment17             => l_segment17
     ,p_segment18             => l_segment18
     ,p_segment19             => l_segment19
     ,p_segment20             => l_segment20
     ,p_concat_segments_in    => p_concat_segments
     ,p_ccid                  => l_cagr_grade_def_id
     ,p_concat_segments_out   => l_name
     );
     --
     hr_utility.set_location(l_proc, 40);
     --
     -- Added as part of fix for bug 2126247
     --
     -- Updates the concatenated segments for the new
     -- record on the per_cagr_grades_def table.
     --
     update_concat_segs
       (p_cagr_grade_def_id     => l_cagr_grade_def_id
       ,p_concatenated_segments => l_name);
     --
     hr_utility.set_location(l_proc, 50);
     --
  end if;
  --
  per_gra_ins.ins
  (
   p_cagr_grade_id                 => l_cagr_grade_id
  ,p_cagr_grade_structure_id       => p_cagr_grade_structure_id
  ,p_cagr_grade_def_id             => l_cagr_grade_def_id
  ,p_sequence                      => p_sequence
  ,p_object_version_number         => l_object_version_number
  ,p_effective_date          => trunc(p_effective_date)
  );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_cagr_grades
    --
    hr_cagr_grades_bk1.create_cagr_grades_a
      (p_cagr_grade_structure_id =>  p_cagr_grade_structure_id
      ,p_cagr_grade_id         =>  l_cagr_grade_id
      ,p_cagr_grade_def_id  =>  l_cagr_grade_def_id
      ,p_sequence           =>  p_sequence
      ,p_segment1             =>  l_segment1
      ,p_segment2             =>  l_segment2
      ,p_segment3             =>  l_segment3
      ,p_segment4             =>  l_segment4
      ,p_segment5             =>  l_segment5
      ,p_segment6             =>  l_segment6
      ,p_segment7             =>  l_segment7
      ,p_segment8             =>  l_segment8
      ,p_segment9             =>  l_segment9
      ,p_segment10              =>  l_segment10
      ,p_segment11              =>  l_segment11
      ,p_segment12              =>  l_segment12
      ,p_segment13              =>  l_segment13
      ,p_segment14              =>  l_segment14
      ,p_segment15              =>  l_segment15
      ,p_segment16              =>  l_segment16
      ,p_segment17              =>  l_segment17
      ,p_segment18              =>  l_segment18
      ,p_segment19              =>  l_segment19
      ,p_segment20              =>  l_segment20
      ,p_concat_segments        =>  p_concat_segments
      ,p_name                    =>  l_name
      ,p_object_version_number =>  l_object_version_number
      ,p_effective_date       =>  trunc(p_effective_date));
    --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CAGR_GRADES'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- End of API User Hook for the after hook of create_cagr_grades
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_cagr_grade_id         := l_cagr_grade_id;
  p_cagr_grade_def_id     := l_cagr_grade_def_id;
  p_object_version_number := l_object_version_number;
  p_name                  := l_name;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_cagr_grades;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cagr_grade_id := null;
    if l_null_ind = 0
    then
       p_cagr_grade_def_id := null;
    end if;
    p_object_version_number  := null;
    p_name := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cagr_grades;
    --
    -- set in out parameters and set out parameters
    --
    p_cagr_grade_def_id := null;
    p_object_version_number  := null;
    p_name := null;
     p_cagr_grade_def_id := l_temp_grade_def_id;
    raise;
    --
end create_cagr_grades;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_cagr_grades >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_grades
  (p_validate       in  boolean   default false
  ,p_cagr_grade_id  in  number
  ,p_sequence       in  number    default hr_api.g_number
  ,p_segment1            in  varchar2  default hr_api.g_varchar2
  ,p_segment2            in  varchar2  default hr_api.g_varchar2
  ,p_segment3            in  varchar2  default hr_api.g_varchar2
  ,p_segment4            in  varchar2  default hr_api.g_varchar2
  ,p_segment5            in  varchar2  default hr_api.g_varchar2
  ,p_segment6            in  varchar2  default hr_api.g_varchar2
  ,p_segment7            in  varchar2  default hr_api.g_varchar2
  ,p_segment8            in  varchar2  default hr_api.g_varchar2
  ,p_segment9            in  varchar2  default hr_api.g_varchar2
  ,p_segment10           in  varchar2  default hr_api.g_varchar2
  ,p_segment11           in  varchar2  default hr_api.g_varchar2
  ,p_segment12           in  varchar2  default hr_api.g_varchar2
  ,p_segment13           in  varchar2  default hr_api.g_varchar2
  ,p_segment14           in  varchar2  default hr_api.g_varchar2
  ,p_segment15           in  varchar2  default hr_api.g_varchar2
  ,p_segment16           in  varchar2  default hr_api.g_varchar2
  ,p_segment17           in  varchar2  default hr_api.g_varchar2
  ,p_segment18           in  varchar2  default hr_api.g_varchar2
  ,p_segment19           in  varchar2  default hr_api.g_varchar2
  ,p_segment20           in  varchar2  default hr_api.g_varchar2
  ,p_concat_segments         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number in out nocopy number
  ,p_effective_date           in     date
  ,p_name                           out nocopy varchar2
  ,p_cagr_grade_def_id      in out nocopy number) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cagr_grades';
  l_segments_changed  BOOLEAN;
  l_object_version_number   per_cagr_grades.object_version_number%TYPE;
  l_ovn per_cagr_grades.object_version_number%TYPE := p_object_version_number;
  l_id_flex_num             per_cagr_grade_structures.id_flex_num%TYPE;
  l_name                    varchar2(240);
  l_cagr_grade_def_id
    per_cagr_grades.cagr_grade_def_id%TYPE := p_cagr_grade_def_id;
  l_temp_grade_def_id per_cagr_grades.cagr_grade_def_id%TYPE := p_cagr_grade_def_id;
  --
  -- bug 2284889 initialize l_cagr_grade_def_id and segment variables with
  -- values where these are passed into program.
  --
  l_segment1                   varchar2(60) := p_segment1;
  l_segment2                   varchar2(60) := p_segment2;
  l_segment3                   varchar2(60) := p_segment3;
  l_segment4                   varchar2(60) := p_segment4;
  l_segment5                   varchar2(60) := p_segment5;
  l_segment6                   varchar2(60) := p_segment6;
  l_segment7                   varchar2(60) := p_segment7;
  l_segment8                   varchar2(60) := p_segment8;
  l_segment9                   varchar2(60) := p_segment9;
  l_segment10                  varchar2(60) := p_segment10;
  l_segment11                  varchar2(60) := p_segment11;
  l_segment12                  varchar2(60) := p_segment12;
  l_segment13                  varchar2(60) := p_segment13;
  l_segment14                  varchar2(60) := p_segment14;
  l_segment15                  varchar2(60) := p_segment15;
  l_segment16                  varchar2(60) := p_segment16;
  l_segment17                  varchar2(60) := p_segment17;
  l_segment18                  varchar2(60) := p_segment18;
  l_segment19                  varchar2(60) := p_segment19;
  l_segment20                  varchar2(60) := p_segment20;
  l_null_ind                   number(1)    := 0;
  --
  cursor csr_id_flex_num is
    select pcs.id_flex_num
    from per_cagr_grade_structures pcs
    where pcs.cagr_grade_structure_id in
          (select pcg.cagr_grade_structure_id
           from   per_cagr_grades pcg
           where  pcg.cagr_grade_id = p_cagr_grade_id);
  --
  -- bug 2284889 get per_cagr_grades_def segment values where
  -- cagr_grade_def_id is known
  --
  cursor c_segments is
    select segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20
      from per_cagr_grades_def
     where cagr_grade_def_id = l_cagr_grade_def_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cagr_grades;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- 2284889
  -- get segment values if p_cagr_grade_def_id entered with a value
  -- set indicator to show p_cagr_grade_def_id did not enter pgm null
  --
  if l_cagr_grade_def_id is not null then
     --
     hr_utility.set_location(l_proc, 30);
     --
     -- set indicator to show p_competence_definition_id did not enter pgm null
     --
     l_null_ind := 1;
     --
     open c_segments;
     fetch c_segments into
                      l_segment1,
                      l_segment2,
                      l_segment3,
                      l_segment4,
                      l_segment5,
                      l_segment6,
                      l_segment7,
                      l_segment8,
                      l_segment9,
                      l_segment10,
                      l_segment11,
                      l_segment12,
                      l_segment13,
                      l_segment14,
                      l_segment15,
                      l_segment16,
                      l_segment17,
                      l_segment18,
                      l_segment19,
                      l_segment20;
     --
     if c_segments%NOTFOUND OR c_segments%NOTFOUND IS NULL then
       --
       l_cagr_grade_def_id := NULL;
       l_null_ind := 0;
       --
       hr_utility.set_location(l_proc, 40);
       --
     end if;
     --
     close c_segments;
     --
  end if;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_cagr_grades
    --
    hr_cagr_grades_bk2.update_cagr_grades_b
      (p_cagr_grade_id      =>  p_cagr_grade_id
      ,p_sequence           =>  p_sequence
      ,p_segment1             =>  l_segment1
      ,p_segment2             =>  l_segment2
      ,p_segment3             =>  l_segment3
      ,p_segment4             =>  l_segment4
      ,p_segment5             =>  l_segment5
      ,p_segment6             =>  l_segment6
      ,p_segment7             =>  l_segment7
      ,p_segment8             =>  l_segment8
      ,p_segment9             =>  l_segment9
      ,p_segment10              =>  l_segment10
      ,p_segment11              =>  l_segment11
      ,p_segment12              =>  l_segment12
      ,p_segment13              =>  l_segment13
      ,p_segment14              =>  l_segment14
      ,p_segment15              =>  l_segment15
      ,p_segment16              =>  l_segment16
      ,p_segment17              =>  l_segment17
      ,p_segment18              =>  l_segment18
      ,p_segment19              =>  l_segment19
      ,p_segment20              =>  l_segment20
      ,p_concat_segments        =>  p_concat_segments
      ,p_object_version_number  =>  p_object_version_number
      ,p_effective_date         =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CAGR_GRADES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_cagr_grades
    --
  end;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Populate l_id_flex_num.
  --
  open csr_id_flex_num;
  fetch csr_id_flex_num into l_id_flex_num;
  --
  if csr_id_flex_num%NOTFOUND then
    --
    close csr_id_flex_num;
    --
    hr_utility.set_message(800, 'PER_52617_INVALID_GRADE');
    hr_utility.raise_error;
    --
  end if;
  --
  close csr_id_flex_num;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- 2284889
  -- update cagr grades definitions in per_cagr_grades_def if
  -- p_cagr_grade_def_id had no value when passed into program
  --
  if l_null_ind = 0 OR l_segments_changed = TRUE then
     --
     hr_utility.set_location(l_proc, 70);
     --
     -- Maintain the collective agreement key flexfields.
     --
     hr_kflex_utility.upd_or_sel_keyflex_comb
       (p_appl_short_name        => 'PER'
       ,p_flex_code              => 'CAGR'
       ,p_flex_num               => l_id_flex_num
       ,p_segment1               => l_segment1
       ,p_segment2               => l_segment2
       ,p_segment3               => l_segment3
       ,p_segment4               => l_segment4
       ,p_segment5               => l_segment5
       ,p_segment6               => l_segment6
       ,p_segment7               => l_segment7
       ,p_segment8               => l_segment8
       ,p_segment9               => l_segment9
       ,p_segment10              => l_segment10
       ,p_segment11              => l_segment11
       ,p_segment12              => l_segment12
       ,p_segment13              => l_segment13
       ,p_segment14              => l_segment14
       ,p_segment15              => l_segment15
       ,p_segment16              => l_segment16
       ,p_segment17              => l_segment17
       ,p_segment18              => l_segment18
       ,p_segment19              => l_segment19
       ,p_segment20              => l_segment20
       ,p_concat_segments_in     => p_concat_segments
       ,p_ccid                   => l_cagr_grade_def_id
       ,p_concat_segments_out    => l_name);
     --
     hr_utility.set_location(l_proc, 80);
     --
  end if;
  --
  -- Added as part of fix for bug 2126247
  --
  -- Updates the concatenated segments for the record
  -- on the per_cagr_grades_def table.
  --
  update_concat_segs
       (p_cagr_grade_def_id     => l_cagr_grade_def_id
       ,p_concatenated_segments => l_name);
  --
  hr_utility.set_location(l_proc, 90);
  --
  per_gra_upd.upd
    (p_cagr_grade_id         => p_cagr_grade_id
    ,p_cagr_grade_def_id     => l_cagr_grade_def_id
    ,p_sequence              => p_sequence
    ,p_object_version_number => l_object_version_number
    ,p_effective_date            => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_cagr_grades
    --
    hr_cagr_grades_bk2.update_cagr_grades_a
      (p_cagr_grade_id     =>  p_cagr_grade_id
      ,p_sequence          =>  p_sequence
      ,p_segment1            =>  l_segment1
      ,p_segment2            =>  l_segment2
      ,p_segment3            =>  l_segment3
      ,p_segment4            =>  l_segment4
      ,p_segment5            =>  l_segment5
      ,p_segment6            =>  l_segment6
      ,p_segment7            =>  l_segment7
      ,p_segment8            =>  l_segment8
      ,p_segment9            =>  l_segment9
      ,p_segment10              =>  l_segment10
      ,p_segment11              =>  l_segment11
      ,p_segment12              =>  l_segment12
      ,p_segment13              =>  l_segment13
      ,p_segment14              =>  l_segment14
      ,p_segment15              =>  l_segment15
      ,p_segment16              =>  l_segment16
      ,p_segment17              =>  l_segment17
      ,p_segment18              =>  l_segment18
      ,p_segment19              =>  l_segment19
      ,p_segment20              =>  l_segment20
      ,p_concat_segments      =>  p_concat_segments
      ,p_effective_date       =>  trunc(p_effective_date)
      ,p_name                    =>  l_name
      ,p_cagr_grade_def_id  =>  l_cagr_grade_def_id
      ,p_object_version_number =>  l_object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CAGR_GRADES'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_cagr_grades
    --
  end;
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_name := l_name;
  p_cagr_grade_def_id := l_cagr_grade_def_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_cagr_grades;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_name := null;
    if l_null_ind = 0
    then
       p_cagr_grade_def_id := l_cagr_grade_def_id;
    end if;
    --
  when others then
    --
    hr_utility.set_location(' Leaving:'||l_proc, 999);
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_cagr_grades;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    p_name         := null;
    p_cagr_grade_def_id     := l_temp_grade_def_id;
    raise;
    --
end update_cagr_grades;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_cagr_grades >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_grades
  (p_validate                       in  boolean  default false
  ,p_cagr_grade_id                  in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date         in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cagr_grades';
  l_object_version_number per_cagr_grades.object_version_number%TYPE;
  l_ovn per_cagr_grades.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cagr_grades;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_cagr_grades
    --
    hr_cagr_grades_bk3.delete_cagr_grades_b
      (
       p_cagr_grade_id                  =>  p_cagr_grade_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date       =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CAGR_GRADES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_cagr_grades
    --
  end;
  --
  per_gra_del.del
    (
     p_cagr_grade_id               => p_cagr_grade_id,
     p_object_version_number       => l_object_version_number,
     p_effective_date         => trunc(p_effective_date)
     );
  begin
    --
    -- Start of API User Hook for the after hook of delete_cagr_grades
    --
    hr_cagr_grades_bk3.delete_cagr_grades_a
      (
       p_cagr_grade_id                  =>  p_cagr_grade_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date       =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CAGR_GRADES'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cagr_grades
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_cagr_grades;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_cagr_grades;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
end delete_cagr_grades;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cagr_grade_id                   in     number
  ,p_object_version_number           in     number
  ,p_effective_date          in     date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
    per_gra_shd.lck
    (
      p_cagr_grade_id                 => p_cagr_grade_id
     ,p_object_version_number         => p_object_version_number
     ,p_effective_date           => trunc(p_effective_date)
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end hr_cagr_grades_api;

/
