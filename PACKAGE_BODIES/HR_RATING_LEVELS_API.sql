--------------------------------------------------------
--  DDL for Package Body HR_RATING_LEVELS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATING_LEVELS_API" as
/* $Header: pertlapi.pkb 120.0 2005/05/31 19:55:21 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_rating_levels_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_rating_level> >--------------------------|
-- ---------------------------------------------------------------------------
-- Validate the language parameter. l_language_code should be passed
-- instead of p_language_code from now on, to allow an IN OUT parameter to
-- be passed through.
--
--
-- ngundura changes done as per pa requirements { business_group_id made optional parameter}
procedure create_rating_level
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_name                         in 	varchar2,
  p_business_group_id            in 	number          default null,
  p_step_value                   in     number,
  p_behavioural_indicator        in 	varchar2         default null,
  p_rating_scale_id              in       number		 default null,
  p_competence_id	               in     number		 default null,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_rating_level_id              out nocopy    number,
  p_object_version_number        out nocopy 	number,
  p_obj_ver_number_cpn_or_rsc    out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get min amd max levels from the
  -- competence entity
  --
  Cursor get_cpn_levels is
  select min_level,
         max_level,
         object_version_number
  from	 per_competences
  where	 competence_id = p_competence_id;
  --
  -- Cursor to get min amd max levels from the
  -- rating scale entity
  --
  Cursor get_rsc_levels is
  select min_scale_step,
         max_scale_step,
         object_version_number
  from	 per_rating_scales
  where	 rating_scale_id = p_rating_scale_id;
  --
  l_proc                	varchar2(72) := g_package||'create_rating_level';
  l_rating_level_id		per_rating_levels.rating_level_id%TYPE;
  l_object_version_number	per_rating_levels.object_version_number%TYPE;
  l_obj_ver_number_cpn_or_rsc   number;
  --
  l_min_level		 per_competences.min_level%TYPE;
  l_max_level		 per_competences.max_level%TYPE;
  l_min_scale_step	 per_rating_scales.min_scale_step%TYPE;
  l_max_scale_step	 per_rating_scales.max_scale_step%TYPE;
  l_language_code        per_rating_levels_tl.language%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_rating_level;
  hr_utility.set_location(l_proc, 6);

  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- ngundura global rating levels should not be allowed if
  -- Cross business group profile is set to N
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' and p_business_group_id is null then
     fnd_message.set_name('PER', 'HR_52693_NO_GLOB_RAT_LEVL');
     fnd_message.raise_error;
  end if;
  -- Call Before Process User Hook
  --
  begin
	hr_rating_levels_bk1.create_rating_level_b	(
	 p_language_code                     =>     l_language_code,
         p_effective_date                    =>     p_effective_date,
         p_name                              =>     p_name,
         p_business_group_id                 =>     p_business_group_id,
         p_step_value                        =>     p_step_value,
         p_behavioural_indicator             =>     p_behavioural_indicator,
         p_rating_scale_id                   =>     p_rating_scale_id,
         p_competence_id                     =>     p_competence_id,
         p_attribute_category                =>     p_attribute_category,
         p_attribute1                        =>     p_attribute1,
         p_attribute2                        =>     p_attribute2,
         p_attribute3                        =>     p_attribute3,
         p_attribute4                        =>     p_attribute4,
         p_attribute5                        =>     p_attribute5,
         p_attribute6                        =>     p_attribute6,
         p_attribute7                        =>     p_attribute7,
         p_attribute8                        =>     p_attribute8,
         p_attribute9                        =>     p_attribute9,
         p_attribute10                       =>     p_attribute10,
         p_attribute11                       =>     p_attribute11,
         p_attribute12                       =>     p_attribute12,
         p_attribute13                       =>     p_attribute13,
         p_attribute14                       =>     p_attribute14,
         p_attribute15                       =>     p_attribute15,
         p_attribute16                       =>     p_attribute16,
         p_attribute17                       =>     p_attribute17,
         p_attribute18                       =>     p_attribute18,
         p_attribute19                       =>     p_attribute19,
         p_attribute20                       =>     p_attribute20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_rating_level',
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
  -- 1) Get min, max and object version number of competence/rating scale
  -- 2) place lock on competence/rating scale
  -- 3) insert row in rating levels
  -- 4) update competence/rating scale
  --
     -- Only one of them has to be set and not both.
     -- Both cannot be null.
     --
     if (   ( p_rating_scale_id is not null and p_competence_id is not null )
         or ( p_rating_scale_id is null and p_competence_id is null )
        ) then
        hr_utility.set_message(801,'HR_51482_RTL_RSC_OR_CPN');
        hr_utility.raise_error;
     end if;
     --
     if p_competence_id is not null then
       -- if a rating level for a competence is being created then
       -- get the min and max levels from competence table. Also get the
       -- object version number
       open get_cpn_levels;
       fetch get_cpn_levels into l_min_level, l_max_level, l_obj_ver_number_cpn_or_rsc;
       close get_cpn_levels;
        --
        -- lock the competence row
        --
           per_cpn_shd.lck(p_competence_id  		=> p_competence_id
		      	  ,p_object_version_number  	=> l_obj_ver_number_cpn_or_rsc);
        --
        -- call rating level api to insert the level for the competence
        -- in the rating level table
        --
        per_rtl_ins.ins
 	(p_validate                         =>     FALSE,
  	p_effective_date                    =>     p_effective_date,
  	p_name                         	=>     p_name,
  	p_business_group_id            	=>     p_business_group_id,
  	p_step_value                        =>     p_step_value,
  	p_behavioural_indicator             =>     p_behavioural_indicator,
  	p_rating_scale_id	                  =>     null,
  	p_competence_id                     =>     p_competence_id,
  	p_attribute_category           	=>     p_attribute_category,
  	p_attribute1                   	=>     p_attribute1,
  	p_attribute2                   	=>     p_attribute2,
  	p_attribute3                   	=>     p_attribute3,
  	p_attribute4                   	=>     p_attribute4,
  	p_attribute5                   	=>     p_attribute5,
  	p_attribute6                   	=>     p_attribute6,
  	p_attribute7                   	=>     p_attribute7,
  	p_attribute8                   	=>     p_attribute8,
  	p_attribute9                   	=>     p_attribute9,
  	p_attribute10                  	=>     p_attribute10,
  	p_attribute11                  	=>     p_attribute11,
  	p_attribute12                  	=>     p_attribute12,
  	p_attribute13                  	=>     p_attribute13,
  	p_attribute14                  	=>     p_attribute14,
  	p_attribute15                  	=>     p_attribute15,
  	p_attribute16                  	=>     p_attribute16,
  	p_attribute17                  	=>     p_attribute17,
  	p_attribute18                  	=>     p_attribute18,
  	p_attribute19                  	=>     p_attribute19,
  	p_attribute20                  	=>     p_attribute20,
  	p_rating_level_id               =>     l_rating_level_id,
  	p_object_version_number        	=>     l_object_version_number
  	);

  	-- call the translation table handler

  	 per_rtx_ins.ins_tl
 	(p_rating_level_id              =>   l_rating_level_id,
  	 p_language_code                =>   l_language_code,
  	 p_name                        	=>   p_name,
  	 p_behavioural_indicator        =>   p_behavioural_indicator);


  	--
        -- check if the step value passed in is less than the one held in the
        -- competence table
        --
	if (p_step_value < nvl(l_min_level,0)) then
         --
  	 -- call the competence row handler api to update the min level
  	 -- column in the competence table
  	 --
	 per_cpn_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date             	=>      p_effective_date
  	 ,p_competence_id              	=>	p_competence_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_min_level		 	=>	p_step_value
  	 );
         --
         -- check if the step value passed in is greater than the one held in the
         -- competence table
         --
       elsif (p_step_value > nvl(l_max_level,0)) then
         --
	 -- call the competence row handler api to update the max level
  	 -- column in the competence table
  	 --
	 per_cpn_upd.upd
         (p_validate                  =>	FALSE
  	 ,p_effective_date              =>  p_effective_date
  	 ,p_competence_id               =>	p_competence_id
  	 ,p_object_version_number       =>	l_obj_ver_number_cpn_or_rsc
  	 ,p_max_level                   =>	p_step_value
  	 );
	 --
       end if;
       --
       -- The user must be inserting rating level for rating scale.
       --
     else
       -- if a rating level for a rating scale is being created then
       -- get the min and max levels from competence table. Also get the
       -- object version number
       --
       open get_rsc_levels;
       fetch get_rsc_levels into l_min_scale_step, l_max_scale_step, l_obj_ver_number_cpn_or_rsc;
       close get_rsc_levels;
       --
       -- lock the row in the rating scale table
       --
       per_rsc_shd.lck(p_rating_scale_id 	=> p_rating_scale_id
		      ,p_object_version_number  => l_obj_ver_number_cpn_or_rsc);
       --
       -- call rating level api to insert the level for the rating scale
       -- in the rating level table
       --
        per_rtl_ins.ins
 	(p_validate                         =>     FALSE,
  	p_effective_date                    =>     p_effective_date,
  	p_name                              =>     p_name,
  	p_business_group_id                 =>     p_business_group_id,
  	p_step_value                        =>     p_step_value,
  	p_behavioural_indicator             =>     p_behavioural_indicator,
  	p_rating_scale_id                   =>     p_rating_scale_id,
  	p_competence_id                     =>     null,
  	p_attribute_category           	=>     p_attribute_category,
  	p_attribute1                   	=>     p_attribute1,
  	p_attribute2                   	=>     p_attribute2,
  	p_attribute3                       	=>     p_attribute3,
  	p_attribute4                   	=>     p_attribute4,
  	p_attribute5                   	=>     p_attribute5,
  	p_attribute6                   	=>     p_attribute6,
  	p_attribute7                   	=>     p_attribute7,
  	p_attribute8                   	=>     p_attribute8,
  	p_attribute9                   	=>     p_attribute9,
  	p_attribute10                  	=>     p_attribute10,
  	p_attribute11                  	=>     p_attribute11,
  	p_attribute12                  	=>     p_attribute12,
  	p_attribute13                  	=>     p_attribute13,
  	p_attribute14                  	=>     p_attribute14,
  	p_attribute15                  	=>     p_attribute15,
  	p_attribute16                  	=>     p_attribute16,
  	p_attribute17                  	=>     p_attribute17,
  	p_attribute18                  	=>     p_attribute18,
  	p_attribute19                  	=>     p_attribute19,
  	p_attribute20                  	=>     p_attribute20,
  	p_rating_level_id              	=>     l_rating_level_id,
  	p_object_version_number        	=>     l_object_version_number
  	);
  	--
  	-- call the translation table handler

  	 per_rtx_ins.ins_tl
 	(p_rating_level_id              =>   l_rating_level_id,
  	 p_language_code                =>   l_language_code,
  	 p_name                        	=>   p_name,
  	 p_behavioural_indicator        =>   p_behavioural_indicator);

        -- check if the step value passed in is less than the one held in the
        -- rating scale table
  	--
        if (p_step_value < nvl(l_min_scale_step,0)) then
         --
         -- call the rating scale row handler api to update the min step level
  	 -- column in the rating scale table
   	 --
 	 per_rsc_upd.upd
         (p_validate                    =>	FALSE
  	 ,p_effective_date              =>      p_effective_date
  	 ,p_rating_scale_id             =>	p_rating_scale_id
  	 ,p_object_version_number       =>	l_obj_ver_number_cpn_or_rsc
  	 ,p_min_scale_step	 	=>	p_step_value
  	 );
	 --
         -- check if the step value passed in is greater than the one held in the
         -- rating scale table
         --
        elsif (p_step_value > nvl(l_max_scale_step,0)) then
         --
         -- call the rating scale row handler api to update the max step level
  	 -- column in the rating scale table
   	 --
         per_rsc_upd.upd
         (p_validate                    =>	FALSE
  	 ,p_effective_date             	=>      p_effective_date
  	 ,p_rating_scale_id             =>	p_rating_scale_id
  	 ,p_object_version_number      	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_max_scale_step	 	=>	p_step_value
  	 );
        end if;
     end if;
     --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_rating_levels_bk1.create_rating_level_a	(
	 p_language_code                     =>     l_language_code,
         p_effective_date                    =>     p_effective_date,
         p_name                              =>     p_name,
         p_business_group_id                 =>     p_business_group_id,
         p_step_value                        =>     p_step_value,
         p_behavioural_indicator             =>     p_behavioural_indicator,
         p_rating_scale_id                   =>     p_rating_scale_id,
         p_competence_id                     =>     p_competence_id,
         p_attribute_category                =>     p_attribute_category,
         p_attribute1                        =>     p_attribute1,
         p_attribute2                        =>     p_attribute2,
         p_attribute3                        =>     p_attribute3,
         p_attribute4                        =>     p_attribute4,
         p_attribute5                        =>     p_attribute5,
         p_attribute6                        =>     p_attribute6,
         p_attribute7                        =>     p_attribute7,
         p_attribute8                        =>     p_attribute8,
         p_attribute9                        =>     p_attribute9,
         p_attribute10                       =>     p_attribute10,
         p_attribute11                       =>     p_attribute11,
         p_attribute12                       =>     p_attribute12,
         p_attribute13                       =>     p_attribute13,
         p_attribute14                       =>     p_attribute14,
         p_attribute15                       =>     p_attribute15,
         p_attribute16                       =>     p_attribute16,
         p_attribute17                       =>     p_attribute17,
         p_attribute18                       =>     p_attribute18,
         p_attribute19                       =>     p_attribute19,
         p_attribute20                       =>     p_attribute20,
         p_rating_level_id                   =>     l_rating_level_id,
         p_object_version_number             =>     l_object_version_number,
         p_obj_ver_number_cpn_or_rsc         =>     l_obj_ver_number_cpn_or_rsc
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_rating_level',
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
  p_rating_level_id		:= l_rating_level_id;
  p_object_version_number	:= l_object_version_number;
  p_obj_ver_number_cpn_or_rsc	:= l_obj_ver_number_cpn_or_rsc;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_rating_level;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rating_level_id          	:= null;
    p_object_version_number  	:= null;
    p_obj_ver_number_cpn_or_rsc	:= null;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_rating_level_id           := null;
    p_object_version_number     := null;
    p_obj_ver_number_cpn_or_rsc := null;
    ROLLBACK TO create_rating_level;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_rating_level;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_rating_level> >--------------------------|
-- ---------------------------------------------------------------------------
--
-- Validate the language parameter. l_language_code should be passed
-- instead of p_language_code from now on, to allow an IN OUT parameter to
-- be passed through.
--
procedure update_rating_level
 (p_language_code                in varchar2 default hr_api.userenv_lang,
  p_validate                     in boolean         default false,
  p_effective_date               in date,
  p_rating_level_id              in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_behavioural_indicator        in varchar2         default hr_api.g_varchar2,
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
  p_attribute20                  in varchar2         default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                	varchar2(72) := g_package||'update_rating_level';
  l_object_version_number	per_rating_levels.object_version_number%TYPE;
  l_language_code               per_rating_levels_tl.language%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_rating_level;
  l_language_code := p_language_code;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_rating_levels_bk2.update_rating_level_b	(
	   p_language_code               =>     l_language_code,
           p_effective_date               =>     p_effective_date,
           p_rating_level_id              =>     p_rating_level_id,
           p_object_version_number        =>     p_object_version_number,
           p_name                         =>     p_name,
           p_behavioural_indicator        =>     p_behavioural_indicator,
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
				(p_module_name	=> 'update_rating_level',
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
  l_object_version_number := p_object_version_number;
  --
 per_rtl_upd.upd
 (p_validate                     =>	FALSE,
  p_effective_date               =>     p_effective_date,
  p_rating_level_id              =>     p_rating_level_id,
  p_object_version_number        =>     l_object_version_number,
  p_name                         =>     p_name,
  p_behavioural_indicator        =>     p_behavioural_indicator,
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
  --call the translation table
  --
  per_rtx_upd.upd_tl
  (p_language_code               =>     l_language_code
  ,p_rating_level_id             =>     p_rating_level_id
  ,p_name                        =>     p_name
  ,p_behavioural_indicator       =>     p_behavioural_indicator
  );
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_rating_levels_bk2.update_rating_level_a	(
	   p_language_code                =>     l_language_code,
           p_effective_date               =>     p_effective_date,
           p_rating_level_id              =>     p_rating_level_id,
           p_object_version_number        =>     l_object_version_number,
           p_name                         =>     p_name,
           p_behavioural_indicator        =>     p_behavioural_indicator,
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
				(p_module_name	=> 'update_rating_level',
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_rating_level;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_object_version_number  := l_object_version_number;
    ROLLBACK TO update_rating_level;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_rating_level;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_rating_level> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_rating_level
(p_validate                           in  boolean default false,
 p_rating_level_id                    in  number,
 p_object_version_number              in  number,
 p_obj_ver_number_cpn_or_rsc	      out nocopy number
) is
  --
  l_competence_id		per_competences.competence_id%TYPE;
  l_rating_scale_id		per_rating_scales.rating_scale_id%TYPE;
  --
  -- Declare cursors and local variables
  --
  --
  -- Get values from competence table
  --
  Cursor get_competence_values is
  select cpn.competence_id,cpn.object_version_number
	,cpn.min_level, cpn.max_level
  from   per_competences cpn
	,per_rating_levels rtl
  where  rtl.competence_id   = cpn.competence_id
  and    rtl.rating_level_id = p_rating_level_id;
  --
  -- Get values from rating scale table
  --
  Cursor get_rating_scale_values is
  select rsc.rating_scale_id,rsc.object_version_number
	,rsc.min_scale_step, rsc.max_scale_step
  from   per_rating_scales rsc
	,per_rating_levels rtl
  where  rtl.rating_scale_id  = rsc.rating_scale_id
  and    rtl.rating_level_id = p_rating_level_id;
  --
  -- Cursor to get min and max rating levels for
  -- competence from the rating level table.
  --
 Cursor get_cpn_levels is
 select min(step_value),  max(step_value)
 from 	per_rating_levels
 where	competence_id    = l_competence_id;
 --
 --
 -- Cursor to get min and max levels for
 -- rating scale from the rating level table.
 --
 Cursor get_rsc_levels is
 select min(step_value), max(step_value)
 from 	per_rating_levels
 where	rating_scale_id  = l_rating_scale_id;
  --
  --
  l_proc                	varchar2(72) := g_package||'delete_rating_level';
  l_obj_ver_number_cpn_or_rsc	number;
  --
  l_min_step			per_rating_levels.step_value%TYPE;
  l_max_step			per_rating_levels.step_value%TYPE;
  l_min_level			per_competences.min_level%TYPE;
  l_max_level			per_competences.max_level%TYPE;
  l_min_scale_step		per_rating_scales.min_scale_step%TYPE;
  l_max_scale_step		per_rating_scales.max_scale_step%TYPE;
  l_effective_date		date := to_date('01/01/1900','DD/MM/YYYY');
  -- the l_effective_date parameter is set as it is a mandatory parameter on the
  -- competence and the rating scale api's. The actual date value itself has no
  -- particular use at all and is not used for any sort of validation in the
  -- api.
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_rating_level;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_rating_levels_bk3.delete_rating_level_b
		(
		p_rating_level_id        =>  p_rating_level_id,
		p_object_version_number  =>  p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_rating_level',
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
  -- 1) Get min and max step value from rating levels.
  --    if inserting a rating level of competence then:
  --      - get min_level, max_level,competence id and object version number
  --        of competence from per_competences
  --    if inserting a rating level of rating scale
  --      - get min_level, max_level,rating scale id and object version number
  --        of rating scale from per_rating_scales
  -- 2) place lock on competence or rating scale
  -- 3) delete row in rating levels
  -- 4) update competence or rating scale
  --
    --
    -- At this point we dont know to which parent the rating level belongs
    -- It could be a child of competence or rating scale.
    --
    -- opening cursor to check againts competence first.
    --
    open  get_competence_values;
    fetch get_competence_values into l_competence_id, l_obj_ver_number_cpn_or_rsc
				    ,l_min_level,  l_max_level;
    close get_competence_values;
    --
    -- if the rating level was for a competence deal with competence
    --
    if l_competence_id is not null then
      --
      -- As We have found the right parent, lock the competence row
      --
         per_cpn_shd.lck(p_competence_id  		=> l_competence_id
    	                ,p_object_version_number  	=> l_obj_ver_number_cpn_or_rsc);

      -- delete the translation table first
      --
      per_rtx_del.del_tl
     (p_rating_level_id          => p_rating_level_id
      );
      --
      -- delete the rating level from the rating level table
      --
         per_rtl_del.del
         (p_validate			=> FALSE
         ,p_rating_level_id  		=> p_rating_level_id
         ,p_object_version_number 	=> p_object_version_number
         );
      --
      --
      -- if the rating level was for a competence then get the min and max
      -- levels from the rating level table.
      --
      open  get_cpn_levels;
      fetch get_cpn_levels into l_min_step, l_max_step;
      close get_cpn_levels;

      --
      -- call competence api to update the level for the competence
      --
      --
      if (l_min_step < nvl(l_min_level,0)) then
         --
  	 -- call the competence row handler api to update the min level
  	 -- column in the competence table
  	 --
	 per_cpn_upd.upd
         (p_validate                   	=>	FALSE,
  	 p_effective_date              	=>      l_effective_date,
  	 p_competence_id               	=>	l_competence_id,
  	 p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc,
  	 p_min_level		 	=>	l_min_level
  	 );
         --
         -- check if the step value passed in is greater than the one held in the
         -- competence table
         --
      elsif (l_max_step > nvl(l_max_level,0)) then
         --
	 -- call the competence row handler api to update the max level
  	 -- column in the competence table
  	 --
	 per_cpn_upd.upd
         (p_validate                   	=>	FALSE,
  	 p_effective_date              	=>      l_effective_date,
  	 p_competence_id               	=>	l_competence_id,
  	 p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc,
  	 p_max_level		 	=>	l_max_level
  	 );
	 --
         --
         -- if there is only one step left then we want to make sure that
         -- whatever the value in the min_level column in per_competences
         -- table as long as the last value is not greater than 0, we need to
         -- update the table with the new min value.
	 -- ** As a general rule the min_level column in per_competences
	 -- should not be greater than 0.
	 --
       elsif (    (l_min_step = l_max_step)
	      and (l_min_step > l_min_level)
	      and (l_min_step <= 0 )
             ) then
         --
	 per_cpn_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date              =>      l_effective_date
  	 ,p_competence_id               =>	l_competence_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_min_level			=>	l_min_level
  	 );
	 --
         -- Same as above but, this time for max_level column.
         -- We want to make sure that the last value is not less than 0.
	 -- ** As a general rule, the max_level column in per_competences
	 -- should not be less than 0.
	 --
       elsif (    (l_min_step = l_max_step)
	      and (l_max_step < l_max_level)
	      and (l_max_step >= 0 )
             ) then
         --
	 per_cpn_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date              =>      l_effective_date
  	 ,p_competence_id               =>	l_competence_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_max_level			=>	l_max_level
  	 );
         --
      end if;
         --
    else
      -- The rating level must belong to the rating scale.
      --
	 open  get_rating_scale_values;
	 fetch get_rating_scale_values into l_rating_scale_id, l_obj_ver_number_cpn_or_rsc
					   ,l_min_scale_step, l_max_scale_step;
	 close get_rating_scale_values;
      --
      --
      -- lock the rating scale row
      --
          per_rsc_shd.lck(p_rating_scale_id  		=> l_rating_scale_id
                         ,p_object_version_number  	=> l_obj_ver_number_cpn_or_rsc);

      -- delete the translation table first
      --
      per_rtx_del.del_tl
     (p_rating_level_id          => p_rating_level_id
      );
      --
      --
      -- delete the rating level from the rating level table
      --
         per_rtl_del.del
         (p_validate			=> FALSE
         ,p_rating_level_id  		=> p_rating_level_id
         ,p_object_version_number 	=> p_object_version_number
         );
      --
      --
      -- get the min and max levels for the rating scale from the
      -- rating scale table
      --
         open  get_rsc_levels;
         fetch get_rsc_levels into l_min_step, l_max_step;
	 close get_rsc_levels;
      --
      -- call rating scale api to update the level for the rating scale
      --
      --
      if (l_min_step < nvl(l_min_scale_step,0)) then
         --
  	 -- call the rating scale row handler api to update the min scale step
  	 -- column in the competence table
  	 --
	 per_rsc_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date              =>      l_effective_date
  	 ,p_rating_scale_id             =>	l_rating_scale_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_min_scale_step		=>	l_min_scale_step
  	 );
         --
         -- check if the step value passed in is greater than the one held in the
         -- rating scale table
         --
      elsif (l_max_step > nvl(l_max_scale_step,0)) then
         --
	 -- call the rating scale row handler api to update the max scale step
  	 -- column in the rating scale table
  	 --
	 per_rsc_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date              =>      l_effective_date
  	 ,p_rating_scale_id             =>	l_rating_scale_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_max_scale_step		=>	l_max_scale_step
  	 );
	 --
         -- if there is only one step left then we want to make sure that
         -- whatever the value in the min_scale_step column in per_rating_scales
         -- table as long as the last value is not greater than 0, we need to
         -- update the table with the new min value.
	 -- ** As a general rule the min_scale_step column in per_rating_scales
	 -- should not be greater than 0.
	 --
         --
       elsif (    (l_min_step = l_max_step)
	      and (l_min_step > l_min_scale_step)
	      and (l_min_step <= 0 )
             ) then
         --
	 per_rsc_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date              =>      l_effective_date
  	 ,p_rating_scale_id             =>	l_rating_scale_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_min_scale_step		=>	l_min_step
  	 );
	 --
         -- Same as above but, this time for max_scale_step column.
         -- We want to make sure that the last value is not less than 0.
	 -- ** As a general rule, the max_scale_step column in per_rating_scales
	 -- should not be less than 0.
	 --
       elsif (    (l_min_step = l_max_step)
	      and (l_max_step < l_max_scale_step)
	      and (l_max_step >= 0 )
             ) then
         --
	 per_rsc_upd.upd
         (p_validate                   	=>	FALSE
  	 ,p_effective_date              =>      l_effective_date
  	 ,p_rating_scale_id             =>	l_rating_scale_id
  	 ,p_object_version_number    	=>	l_obj_ver_number_cpn_or_rsc
  	 ,p_max_scale_step		=>	l_max_step
  	 );
         --
       end if;
         --
    end if;
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
	hr_rating_levels_bk3.delete_rating_level_a	(
		p_rating_level_id        =>   p_rating_level_id,
		p_object_version_number  =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_rating_level',
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
  -- Set all output parameters
  --
  p_obj_ver_number_cpn_or_rsc	:= l_obj_ver_number_cpn_or_rsc;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_rating_level;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_obj_ver_number_cpn_or_rsc	:= null;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_obj_ver_number_cpn_or_rsc := null;
    ROLLBACK TO delete_rating_level;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_rating_level;
--
--
-- ---------------------------------------------------------------------------
-- |----------------< <create_or_update_rating_level> >-----------------------|
-- ---------------------------------------------------------------------------
--
procedure create_or_update_rating_level
 (
  p_language_code                in varchar2        default hr_api.userenv_lang
 ,p_validate                     in boolean         default false
 ,p_effective_date               in date            default trunc(sysdate)
 ,p_name                         in varchar2        default null
 ,p_step_value                   in number          default 1
 ,p_rating_scale_name            in varchar2        default null
 ,p_behavioural_indicator        in varchar2        default null
 ,p_competence_name              in varchar2        default null
 ,p_translated_language          in varchar2        default null
 ,p_source_rating_level_name     in varchar2        default null
  ) is

 --
 -- Declare cursor and local variables
 --
 l_proc              varchar2(72) := g_package||'create_or_update_rating_level';
 l_rating_level_id       per_rating_levels.rating_level_id%TYPE;
 l_source_rating_level_id per_rating_levels.rating_level_id%TYPE;
 l_rating_scale_id       per_rating_levels.rating_scale_id%TYPE;
 l_step_value            per_rating_levels.step_value%TYPE;
 l_competence_id         per_rating_levels.competence_id%TYPE;
 l_ovn                   per_rating_levels.object_version_number%TYPE;
 l_source_ovn            per_rating_levels.object_version_number%TYPE;
 l_obj_ver_number_cpn_or_rsc   number;
 l_effective_date        date;
 l_language_code         varchar2(10);
 l_translated_language   varchar2(20);

 cursor csr_rtl(p_rating_level_name in varchar2
               ,p_rating_scale_id in number) is
  select rating_level_id , object_version_number , step_value
  from per_rating_levels
  where business_group_id is null
  and name = p_rating_level_name
  and step_value = p_step_value
  and rating_scale_id = p_rating_scale_id;

 cursor csr_rsc is
  select rating_scale_id
  from per_rating_scales
  where business_group_id is null
  and name = p_rating_scale_name;

 cursor csr_comp is
  select competence_id
  from per_competences
  where business_group_id is null
  and name = p_competence_name;

begin

  hr_utility.set_location('Entering... ' || l_proc,10);
  --
  -- Issue a savepoint.
  --
  savepoint create_or_update_rating_level;

  hr_rating_levels_api.g_ignore_df := 'Y';

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
  hr_utility.trace('l_effective_date : ' || l_effective_date);

  if (p_rating_scale_name is not NULL) then
    hr_utility.set_location(l_proc,40);
    open csr_rsc;
    fetch csr_rsc into l_rating_scale_id;
    if csr_rsc%NOTFOUND then
       close csr_rsc;
       fnd_message.set_name('PER','HR_51928_APT_RSC_NOT_EXIST');
       fnd_message.raise_error;
    end if;
    close csr_rsc;
    hr_utility.trace('l_rating_scale_id : ' || l_rating_scale_id);
  end if;

  IF (p_translated_language IS NULL AND p_source_rating_level_name IS NULL)
  THEN
    hr_utility.set_location(l_proc,20);

    open csr_rtl(p_name,l_rating_scale_id);
    fetch csr_rtl into l_rating_level_id,l_ovn,l_step_value;
    if csr_rtl%NOTFOUND then
       close csr_rtl;
       l_rating_level_id := NULL;
       l_ovn := NULL;
    else
       close csr_rtl;
       hr_utility.set_location(l_proc,30);
    end if;

    hr_utility.trace('l_rating_level_id : ' || l_rating_level_id);
    hr_utility.trace('l_ovn             : ' || l_ovn);
    hr_utility.trace('l_step_value      : ' || l_step_value);

    hr_utility.set_location(l_proc,50);

    if (p_competence_name is not NULL) then
      hr_utility.trace('p_competence_name : ' || p_competence_name);
      open csr_comp;
      fetch csr_comp into l_competence_id;
      if csr_comp%NOTFOUND then
        close csr_comp;
        fnd_message.set_name('PER','HR_52251_CEL_COMP_ID_INVL');
        fnd_message.raise_error;
      end if;
      close csr_comp;
      hr_utility.trace('l_competence_id : ' || l_competence_id);
    end if;


    if (l_rating_level_id is null and l_ovn is null) then
      hr_utility.set_location(l_proc,60);
      if (p_step_value is NULL) then
        l_step_value := 1;
      else
        l_step_value := p_step_value;
      end if;
     --
     create_rating_level
       (p_language_code                => l_language_code
       ,p_validate                     => p_validate
       ,p_effective_date               => l_effective_date
       ,p_name                         => p_name
       ,p_step_value                   => l_step_value
       ,p_behavioural_indicator        => p_behavioural_indicator
       ,p_rating_scale_id              => l_rating_scale_id
       ,p_competence_id                => l_competence_id
       ,p_rating_level_id              => l_rating_level_id
       ,p_object_version_number        => l_ovn
       ,p_obj_ver_number_cpn_or_rsc    => l_obj_ver_number_cpn_or_rsc
     );
   else
     hr_utility.set_location(l_proc,70);

     if (p_step_value is not NULL and p_step_value <> l_step_value) then
       fnd_message.set_name('PER','HR_449168_NO_UPDATE_STEP_VALUE');
       fnd_message.raise_error;
     else
       update_rating_level
         (p_language_code                => l_language_code
         ,p_validate                     => p_validate
         ,p_effective_date               => l_effective_date
         ,p_name                         => p_name
         ,p_behavioural_indicator        => p_behavioural_indicator
         ,p_rating_level_id              => l_rating_level_id
         ,p_object_version_number        => l_ovn
       );
     end if;
   end if;
   --
 ELSE
  --
  -- p_translated_language is not NULL
  --
  hr_utility.set_location(l_proc,80);

  open csr_rtl(p_source_rating_level_name,l_rating_scale_id);
  fetch csr_rtl into l_source_rating_level_id,l_source_ovn,l_step_value;
  if csr_rtl%NOTFOUND then
     close csr_rtl;
     hr_utility.set_message(800,'HR_449191_SOURCE_RTL_INVALID');
     hr_utility.raise_error;
  else
     close csr_rtl;
     hr_utility.set_location(l_proc,90);
  end if;
  hr_utility.trace('l_source_rating_level_id : ' || l_source_rating_level_id);
  hr_utility.trace('l_source_ovn             : ' || l_ovn);

  l_translated_language := p_translated_language;
  hr_api.validate_language_code(p_language_code => l_translated_language);

  --
  --  MLS Processing
  --
  per_rtx_upd.upd_tl
  (p_language_code               =>     l_translated_language
  ,p_rating_level_id             =>     l_source_rating_level_id
  ,p_name			 =>     p_name
  ,p_behavioural_indicator       =>     p_behavioural_indicator
  );
  hr_utility.set_location(l_proc, 100);
  --
  -- Call After Process User Hook
  --
  begin
    hr_rating_levels_bk2.update_rating_level_a	(
   	p_language_code                =>     l_translated_language,
        p_effective_date               =>     l_effective_date,
        p_rating_level_id              =>     l_source_rating_level_id,
        p_object_version_number        =>     l_source_ovn,
        p_name                         =>     p_source_rating_level_name,
        p_behavioural_indicator        =>     p_behavioural_indicator,
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
                  hr_rating_levels_api.g_ignore_df	:= 'N';
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_rating_level',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
  --
 END IF;
 hr_rating_levels_api.g_ignore_df	:= 'N';
 hr_utility.set_location('Leaving... ' || l_proc,110);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_or_update_rating_level;
    --
    hr_rating_levels_api.g_ignore_df	:= 'N';
    --
    hr_utility.set_location('Leaving... ' || l_proc,120);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_or_update_rating_level;
    --
    hr_rating_levels_api.g_ignore_df	:= 'N';
    raise;
    --
--
end create_or_update_rating_level;
--
end hr_rating_levels_api;

/
