--------------------------------------------------------
--  DDL for Package Body HR_RATING_SCALES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATING_SCALES_API" as
/* $Header: perscapi.pkb 120.0 2005/05/31 19:41:40 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_rating_scales_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_rating_scale> >--------------------------|
-- ---------------------------------------------------------------------------
-- ngundura made changes as per pa requirements
-- {made p_business_group_id made optional }
-- Validate the language parameter. l_language_code should be passed
-- instead of p_language_code from now on, to allow an IN OUT parameter to
-- be passed through.
--

procedure create_rating_scale
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in     boolean         default false,
  p_effective_date               in     date,
  p_name                         in     varchar2,
  p_type                         in     varchar2,
  p_default_flag                 in     varchar2         default 'N',
  p_business_group_id            in     number           default null,
  p_description                  in     varchar2         default null,
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_rating_scale_id              out  NOCOPY   number,
  p_object_version_number        out  NOCOPY   number
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                varchar2(72) := g_package||'create_rating_scale';
  l_rating_scale_id		per_rating_scales.rating_scale_id%TYPE;
  l_object_version_number	per_rating_scales.object_version_number%TYPE;
  l_language_code               per_rating_scales_tl.language%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_rating_scale;
  hr_utility.set_location(l_proc, 6);
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- ngundura global rating scales cannot be created if Cross business
  -- group profile is set to N
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP')='N' and p_business_group_id is null then
     fnd_message.set_name('PER','HR_52692_NO_GLOB_RAT_SCAL');
     fnd_message.raise_error;
  end if;

  -- Call Before Process User Hook
  --
  begin
	hr_rating_scales_bk1.create_rating_scale_b	(
	 p_language_code               =>     l_language_code,
         p_effective_date               =>     p_effective_date,
         p_name                         =>     p_name,
         p_type                         =>     p_type,
         p_business_group_id            =>     p_business_group_id,
         p_description                  =>     p_description,
         p_default_flag                 =>     p_default_flag,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_rating_scale',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_rsc_ins.ins
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_name                         =>     p_name,
  p_type                         =>     p_type,
  p_business_group_id            =>     p_business_group_id,
  p_description                  =>     p_description,
  p_default_flag                 =>     p_default_flag,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_rating_scale_id              =>	l_rating_scale_id,
  p_object_version_number        =>	l_object_version_number
  );
  --



  per_rsl_ins.ins_tl
  (p_language_code               =>     l_language_code
  ,p_rating_scale_id             =>     l_rating_scale_id
  ,p_name                        =>     p_name
  ,p_description                 =>     p_description
  );
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_rating_scales_bk1.create_rating_scale_a	(
	 p_language_code               =>     l_language_code,
         p_rating_scale_id              =>     l_rating_scale_id,
         p_object_version_number        =>     l_object_version_number,
         p_effective_date               =>     p_effective_date,
         p_name                         =>     p_name,
         p_type                         =>     p_type,
         p_business_group_id            =>     p_business_group_id,
         p_description                  =>     p_description,
         p_default_flag                 =>     p_default_flag,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_rating_scale',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After process user hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_rating_scale_id        := l_rating_scale_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_rating_scale;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rating_scale_id        := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_rating_scale_id        := null;
    p_object_version_number  := null;
    ROLLBACK TO create_rating_scale;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_rating_scale;
--
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_rating_scale> >--------------------------|
-- ---------------------------------------------------------------------------
-- Validate the language parameter. l_language_code should be passed
-- instead of p_language_code from now on, to allow an IN OUT parameter to
-- be passed through.
--
procedure update_rating_scale
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_rating_scale_id              in number,
  p_object_version_number        in out NOCOPY number,
  p_name                         in varchar2    default hr_api.g_varchar2,
  p_description                  in varchar2    default hr_api.g_varchar2,
  p_default_flag                 in varchar2    default hr_api.g_varchar2,
  p_attribute_category           in varchar2    default hr_api.g_varchar2,
  p_attribute1                   in varchar2    default hr_api.g_varchar2,
  p_attribute2                   in varchar2    default hr_api.g_varchar2,
  p_attribute3                   in varchar2    default hr_api.g_varchar2,
  p_attribute4                   in varchar2    default hr_api.g_varchar2,
  p_attribute5                   in varchar2    default hr_api.g_varchar2,
  p_attribute6                   in varchar2    default hr_api.g_varchar2,
  p_attribute7                   in varchar2    default hr_api.g_varchar2,
  p_attribute8                   in varchar2    default hr_api.g_varchar2,
  p_attribute9                   in varchar2    default hr_api.g_varchar2,
  p_attribute10                  in varchar2    default hr_api.g_varchar2,
  p_attribute11                  in varchar2    default hr_api.g_varchar2,
  p_attribute12                  in varchar2    default hr_api.g_varchar2,
  p_attribute13                  in varchar2    default hr_api.g_varchar2,
  p_attribute14                  in varchar2    default hr_api.g_varchar2,
  p_attribute15                  in varchar2    default hr_api.g_varchar2,
  p_attribute16                  in varchar2    default hr_api.g_varchar2,
  p_attribute17                  in varchar2    default hr_api.g_varchar2,
  p_attribute18                  in varchar2    default hr_api.g_varchar2,
  p_attribute19                  in varchar2    default hr_api.g_varchar2,
  p_attribute20                  in varchar2    default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                	varchar2(72) := g_package||'update_rating_scale';
  l_object_version_number	per_rating_scales.object_version_number%TYPE;
  l_language_code               per_rating_scales_tl.language%TYPE;
  l_temp_ovn                    number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_rating_scale;
   l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_rating_scales_bk2.update_rating_scale_b	(
	 p_language_code               =>     l_language_code,
         p_effective_date               =>     p_effective_date,
         p_rating_scale_id              =>     p_rating_scale_id,
         p_object_version_number        =>     p_object_version_number,
         p_name                         =>     p_name,
         p_description                  =>     p_description,
         p_default_flag                 =>     p_default_flag,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_rating_scale',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  l_object_version_number := p_object_version_number;
  per_rsc_upd.upd
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_rating_scale_id              =>     p_rating_scale_id,
  p_object_version_number        =>     l_object_version_number,
  p_name                         =>     p_name,
  p_description                  =>     p_description,
  p_default_flag                 =>     p_default_flag,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20
  );
  --


  per_rsl_upd.upd_tl
  (p_language_code               =>     l_language_code
  ,p_rating_scale_id             =>     p_rating_scale_id
  ,p_name                        =>     p_name
  ,p_description                 =>     p_description
  );
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_rating_scales_bk2.update_rating_scale_a	(
	 p_language_code                =>     l_language_code,
         p_effective_date               =>     p_effective_date,
         p_rating_scale_id              =>     p_rating_scale_id,
         p_object_version_number        =>     l_object_version_number,
         p_name                         =>     p_name,
         p_description                  =>     p_description,
         p_default_flag                 =>     p_default_flag,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_rating_scale',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments. l_object_version_number now has the new
  -- object version number as the update was successful
  --
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_rating_scale;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_object_version_number  := l_temp_ovn;
    ROLLBACK TO update_rating_scale;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_rating_scale;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_rating_scale> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_rating_scale
(p_validate                           in boolean default false,
 p_rating_scale_id                    in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  cursor csr_get_rat_levels(c_rating_scale_id  per_rating_scales.rating_scale_id%TYPE)
   is
   select	rating_level_id,
		object_version_number
   from		per_rating_levels
   where	rating_scale_id	= c_rating_scale_id;
  --
  --
  l_proc                varchar2(72) := g_package||'delete_rating_scale';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_rating_scale;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_rating_scales_bk3.delete_rating_scale_b
		(
		p_rating_scale_id       =>   p_rating_scale_id,
		p_object_version_number =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_rating_scale',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- check if rating scale has any rating levels
  -- if yes, delete these rows.
  --
  for c_rat_rec in csr_get_rat_levels(p_rating_scale_id) loop
     per_rtl_del.del
     (p_validate			=> FALSE
     ,p_rating_level_id  	=> c_rat_rec.rating_level_id
     ,p_object_version_number => c_rat_rec.object_version_number
     );
  end loop;
  --
  -- now delete the rating scale itself
  --
      per_rsl_del.del_tl
     (p_rating_scale_id           => p_rating_scale_id
      );

     per_rsc_del.del
     (p_validate                  => FALSE
     ,p_rating_scale_id           => p_rating_scale_id
     ,p_object_version_number     => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_rating_scales_bk3.delete_rating_scale_a	(
		p_rating_scale_id        =>   p_rating_scale_id,
		p_object_version_number  =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_rating_scale',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_rating_scale;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_rating_scale;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_rating_scale;
--
-- ----------------------------------------------------------------------------
-- |-------------------< <create_or_update_rating_scale> >---------------------|
-- ----------------------------------------------------------------------------
procedure create_or_update_rating_scale
 (p_language_code                in varchar2    default hr_api.userenv_lang
 ,p_validate                     in boolean     default false
 ,p_effective_date               in date        default trunc(sysdate)
 ,p_name                         in varchar2    default null
 ,p_type                         in varchar2    default null
 ,p_description                  in varchar2    default null
 ,p_default_flag                 in varchar2    default null
 ,p_translated_language          in varchar2    default null
 ,p_source_rating_scale_name     in varchar2    default null
) is

 --
 -- Declare cursor and local variables
 --
 l_proc              varchar2(72) := g_package||'create_or_update_rating_scale';
 l_rating_scale_id   per_rating_scales.rating_scale_id%TYPE;
 l_source_rating_scale_id per_rating_scales.rating_scale_id%TYPE;
 l_ovn               per_rating_scales.object_version_number%TYPE;
 l_source_ovn        per_rating_scales.object_version_number%TYPE;
 l_type              per_rating_scales.type%TYPE;
 l_default_flag      per_rating_scales.default_flag%TYPE;
 l_effective_date    date;
 l_language_code     varchar2(20);
 l_translated_language varchar2(20);

 cursor csr_rs(p_rating_scale_name in varchar2) is
  select rating_scale_id , object_version_number
  from per_rating_scales_v
  where business_group_id is null
  and name = p_rating_scale_name;

 --
 -- Declare local modules
 --
  function return_lookup_code
         (p_meaning        in    fnd_lookup_values.meaning%TYPE default null
         ,p_lookup_type    in    fnd_lookup_values.lookup_code%TYPE
         ,p_language_code  in    fnd_lookup_values.language%TYPE
         )
         Return fnd_lookup_values.lookup_code%TYPE Is
  --
  l_lookup_code  fnd_lookup_values.lookup_code%TYPE := null;
  --
  Cursor Sel_Id Is
         select  flv.lookup_code
         from    fnd_lookup_values flv
         where   flv.lookup_type     = p_lookup_type
         and     flv.meaning         = p_meaning
         and     flv.language        = p_language_code
         and     flv.enabled_flag = 'Y';
  --
  begin
    open Sel_Id;
    fetch Sel_Id Into l_lookup_code;
    if Sel_Id%notfound then
       close Sel_Id;
       hr_utility.set_message(800, 'HR_449156_LOOK_MEANING_INVALID');
       fnd_message.set_token('MEANING',p_meaning);
       hr_utility.raise_error;
     end if;
     close Sel_Id;
    --
    return (l_lookup_code);
  end;
begin

  hr_utility.set_location('Entering... ' || l_proc,10);
  --
  -- Issue a savepoint.
  --
  savepoint create_or_update_rating_scale;

  hr_rating_scales_api.g_ignore_df := 'Y';

  if (p_language_code is NULL) then
    l_language_code :=  hr_api.userenv_lang;
  else
    l_language_code := p_language_code;
    -- BUG3668368
    hr_api.validate_language_code(p_language_code => l_language_code);
  end if;

  if (p_effective_date is NULL) then
      l_effective_date := trunc(sysdate);
  else
      l_effective_date := trunc(p_effective_date);
  end if;
  hr_utility.trace('p_effective_date : ' || p_effective_date);

  IF ( p_translated_language IS NULL AND p_source_rating_scale_name  IS NULL )
  THEN
    hr_utility.set_location(l_proc,20);

    open csr_rs(p_name);
    fetch csr_rs into l_rating_scale_id,l_ovn;
    if csr_rs%NOTFOUND then
       close csr_rs;
       hr_utility.set_location(l_proc,30);
       l_rating_scale_id := NULL;
       l_ovn := NULL;
    else
       close csr_rs;
    end if;
    hr_utility.trace('l_reating_scale_id : ' || l_rating_scale_id);
    hr_utility.trace('l_ovn              : ' || l_ovn);

    --
    if (p_type is not null) then
      l_type := return_lookup_code
                (p_meaning              => p_type
                ,p_lookup_type          => 'RATING_SCALE_TYPE'
                ,p_language_code        => l_language_code
                );
    else
      l_type := 'PROFICIENCY';
    end if;
    hr_utility.trace('l_type         : ' || l_type);
    --
    if (p_default_flag is not null) then
      l_default_flag := return_lookup_code
                (p_meaning              => p_default_flag
                ,p_lookup_type          => 'YES_NO'
                ,p_language_code        => l_language_code
                );
    else
      l_default_flag := 'N';
    end if;
    hr_utility.trace('l_default_flag : ' || l_default_flag);

    --
    if (l_rating_scale_id is null and l_ovn is null) then
      hr_utility.set_location(l_proc,40);

      create_rating_scale
      (p_language_code              => l_language_code
      ,p_validate                   => p_validate
      ,p_effective_date             => l_effective_date
      ,p_name                       => p_name
      ,p_type                       => l_type
      ,p_default_flag               => l_default_flag
      ,p_description                => p_description
      ,p_rating_scale_id            => l_rating_scale_id
      ,p_object_version_number      => l_ovn
      );
      hr_utility.trace('l_rating_scale_id : ' || l_rating_scale_id);
    else
      hr_utility.set_location(l_proc,50);

      update_rating_scale
      (p_language_code              => l_language_code
      ,p_validate                   => p_validate
      ,p_effective_date             => l_effective_date
      ,p_rating_scale_id            => l_rating_scale_id
      ,p_object_version_number      => l_ovn
      ,p_name                       => p_name
      ,p_default_flag               => l_default_flag
      ,p_description                => p_description
      );
    end if;
  ELSE

    hr_utility.set_location(l_proc,60);
    open csr_rs(p_source_rating_scale_name);
        fetch csr_rs into l_source_rating_scale_id,l_source_ovn;
    if csr_rs%NOTFOUND then
       close csr_rs;
       hr_utility.set_location(l_proc,70);
       hr_utility.set_message(800, 'HR_449190_SOURCE_RSC_INVALID');
       hr_utility.raise_error;
    else
       close csr_rs;
    end if;
    hr_utility.trace('l_source_reating_scale_id : ' || l_source_rating_scale_id);
    hr_utility.trace('l_source_ovn              : ' || l_source_ovn);

    l_translated_language := p_translated_language;
    hr_api.validate_language_code(p_language_code => l_translated_language);

    --
    -- MLS update
    --
    hr_utility.set_location(l_proc,80);
    per_rsl_upd.upd_tl
    (p_language_code               =>     l_translated_language
    ,p_rating_scale_id             =>     l_source_rating_scale_id
    ,p_name                        =>     p_name
    ,p_description                 =>     p_description
    );
    hr_utility.set_location(l_proc, 90);
    --
    -- Call After Process User Hook
    --
    begin
	hr_rating_scales_bk2.update_rating_scale_a	(
 	   p_language_code                =>     l_translated_language,
           p_effective_date               =>     l_effective_date,
           p_rating_scale_id              =>     l_source_rating_scale_id,
           p_object_version_number        =>     l_source_ovn,
           p_name                         =>     p_source_rating_scale_name,
           p_description                  =>     p_description,
           p_default_flag                 =>     p_default_flag,
           p_attribute_category           =>     NULL,
           p_attribute1                   =>     NULL,
           p_attribute2                   =>     NULL,
           p_attribute3                   =>     NULL,
           p_attribute4                   =>     NULL,
           p_attribute5                   =>     NULL,
           p_attribute6                   =>     NULL,
           p_attribute7                   =>     NULL,
           p_attribute8                   =>     NULL,
           p_attribute9                   =>     NULL,
           p_attribute10                  =>     NULL,
           p_attribute11                  =>     NULL,
           p_attribute12                  =>     NULL,
           p_attribute13                  =>     NULL,
           p_attribute14                  =>     NULL,
           p_attribute15                  =>     NULL,
           p_attribute16                  =>     NULL,
           p_attribute17                  =>     NULL,
           p_attribute18                  =>     NULL,
           p_attribute19                  =>     NULL,
           p_attribute20                  =>     NULL
	);
        exception
	   when hr_api.cannot_find_prog_unit then
                  hr_rating_scales_api.g_ignore_df := 'N';
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_rating_scale',
				 p_hook_type	=> 'AP'
				);
    end;
    --
    -- End After Process User Hook
    --
    hr_utility.set_location(l_proc,100);
  END IF;

  hr_rating_scales_api.g_ignore_df := 'N';
  hr_utility.set_location('Leaving ... ' || l_proc,110);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_or_update_rating_scale;
    hr_rating_scales_api.g_ignore_df := 'N';
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO create_or_update_rating_scale;
    hr_rating_scales_api.g_ignore_df := 'N';
    raise;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 120);
--
end create_or_update_rating_scale;
--
end hr_rating_scales_api;

/
