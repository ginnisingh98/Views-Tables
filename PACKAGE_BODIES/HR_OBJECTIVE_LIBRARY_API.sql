--------------------------------------------------------
--  DDL for Package Body HR_OBJECTIVE_LIBRARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OBJECTIVE_LIBRARY_API" as
/* $Header: pepmlapi.pkb 120.2 2006/02/28 05:01:56 sturlapa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_objective_library_api.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Create_Library_Objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_library_objective
  (p_validate                      in   boolean   	default false
  ,p_effective_date                in   date
  ,p_objective_name	           in	varchar2
  ,p_valid_from		           in	date	    	default null
  ,p_valid_to	                   in	date	    	default null
  ,p_target_date	           in	date	    	default null
  ,p_next_review_date	           in	date	    	default null
  ,p_group_code	         	   in	varchar2  	default null
  ,p_priority_code		   in	varchar2  	default null
  ,p_appraise_flag	           in	varchar2  	default 'Y'
  ,p_weighting_percent	           in	number          default null
  ,p_measurement_style_code	   in	varchar2        default 'N_M'
  ,p_measure_name	           in	varchar2        default null
  ,p_target_value                  in   number          default null
  ,p_uom_code			   in	varchar2	default null
  ,p_measure_type_code		   in	varchar2	default null
  ,p_measure_comments		   in	varchar2	default null
  ,p_eligibility_type_code	   in	varchar2        default 'N_P'
  ,p_details			   in	varchar2	default null
  ,p_success_criteria		   in	varchar2	default null
  ,p_comments			   in	varchar2	default null
  ,p_attribute_category		   in	varchar2	default null
  ,p_attribute1			   in	varchar2	default null
  ,p_attribute2			   in	varchar2	default null
  ,p_attribute3			   in	varchar2	default null
  ,p_attribute4			   in	varchar2	default null
  ,p_attribute5			   in	varchar2	default null
  ,p_attribute6			   in	varchar2	default null
  ,p_attribute7			   in	varchar2	default null
  ,p_attribute8			   in	varchar2	default null
  ,p_attribute9			   in	varchar2	default null
  ,p_attribute10		   in	varchar2	default null
  ,p_attribute11		   in	varchar2	default null
  ,p_attribute12		   in	varchar2	default null
  ,p_attribute13		   in	varchar2	default null
  ,p_attribute14		   in	varchar2	default null
  ,p_attribute15		   in	varchar2	default null
  ,p_attribute16		   in	varchar2	default null
  ,p_attribute17		   in	varchar2	default null
  ,p_attribute18		   in	varchar2	default null
  ,p_attribute19	 	   in	varchar2	default null
  ,p_attribute20		   in	varchar2	default null
  ,p_attribute21		   in	varchar2	default null
  ,p_attribute22		   in	varchar2	default null
  ,p_attribute23		   in	varchar2	default null
  ,p_attribute24		   in	varchar2	default null
  ,p_attribute25		   in	varchar2	default null
  ,p_attribute26		   in	varchar2	default null
  ,p_attribute27		   in	varchar2	default null
  ,p_attribute28		   in	varchar2	default null
  ,p_attribute29		   in	varchar2	default null
  ,p_attribute30		   in	varchar2	default null
  ,p_objective_id		   out nocopy	number
  ,p_object_version_number	   out nocopy	number
  ,p_duplicate_name_warning	   out nocopy	boolean
  ,p_weighting_over_100_warning	   out nocopy	boolean
  ,p_weighting_appraisal_warning   out nocopy	boolean
  ) is
  --
  -- Declare cursors and local variables
  --
    l_proc                        varchar2(72) := g_package||'create_library_objective';
    l_effective_date              date;
    l_valid_from                  date;
    l_valid_to                    date;
    l_target_date                 date;
    l_next_review_date            date;
    l_object_version_number       number;
    l_objective_id                number;
    l_duplicate_name_warning      boolean := false;
    l_weighting_over_100_warning  boolean := false;
    l_weighting_appraisal_warning boolean := false;

  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace('  p_objective_name                 '||
                        p_objective_name);
    hr_utility.trace('  p_valid_from                     '||
                        to_char(p_valid_from));
    hr_utility.trace('  p_valid_to                       '||
                        to_char(p_valid_to));
    hr_utility.trace('  p_target_date                    '||
                        to_char(p_target_date));
    hr_utility.trace('  p_next_review_date               '||
                        to_char(p_next_review_date));
    hr_utility.trace('  p_group_code                     '||
                        p_group_code);
    hr_utility.trace('  p_priority_code                  '||
                        p_priority_code);
    hr_utility.trace('  p_appraise_flag                  '||
                        p_appraise_flag);
    hr_utility.trace('  p_weighting_percent              '||
                        to_char(p_weighting_percent));
    hr_utility.trace('  p_measurement_style_code         '||
                        p_measurement_style_code);
    hr_utility.trace('  p_measure_name                   '||
                        p_measure_name);
    hr_utility.trace('  p_target_value                   '||
                        to_char(p_target_value));
    hr_utility.trace('  p_uom_code                       '||
                        p_uom_code);
    hr_utility.trace('  p_measure_type_code              '||
                        p_measure_type_code);
    hr_utility.trace('  p_measure_comments               '||
                        p_measure_comments);
    hr_utility.trace('  p_eligibility_type_code          '||
                        p_eligibility_type_code);
    hr_utility.trace('  p_details                        '||
                        p_details);
    hr_utility.trace('  p_success_criteria               '||
                        p_success_criteria);
    hr_utility.trace('  p_comments                       '||
                        p_comments);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
     savepoint create_library_objective;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date     := trunc(p_effective_date);
  l_valid_from         := trunc(p_valid_from);
  l_valid_to           := trunc(p_valid_to);
  l_target_date        := trunc(p_target_date);
  l_next_review_date   := trunc(p_next_review_date);

  --
  -- Call Before Process User Hook
  --
 begin

   hr_objective_library_bk1.create_library_objective_b
     (p_effective_date                => l_effective_date
     ,p_objective_name                => p_objective_name
     ,p_valid_from                    => l_valid_from
     ,p_valid_to                      => l_valid_to
     ,p_target_date                   => l_target_date
     ,p_next_review_date              => l_next_review_date
     ,p_group_code		      => p_group_code
     ,p_priority_code      	      => p_priority_code
     ,p_appraise_flag                 => p_appraise_flag
     ,p_weighting_percent             => p_weighting_percent
     ,p_measurement_style_code        => p_measurement_style_code
     ,p_measure_name                  => p_measure_name
     ,p_target_value                  => p_target_value
     ,p_uom_code      		      => p_uom_code
     ,p_measure_type_code             => p_measure_type_code
     ,p_measure_comments              => p_measure_comments
     ,p_eligibility_type_code         => p_eligibility_type_code
     ,p_details                       => p_details
     ,p_success_criteria              => p_success_criteria
     ,p_comments                      => p_comments
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
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
    );

   exception
     when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'CREATE_LIBRARY_OBJECTIVE',
       p_hook_type   => 'BP'
      );
  end;
  --
  -- End of Before Process User Hook call
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

 --
 -- Call the row handler insert
 --
  per_pml_ins.ins
  (p_effective_date                => l_effective_date
  ,p_objective_name                => p_objective_name
  ,p_valid_from                    => l_valid_from
  ,p_valid_to                      => l_valid_to
  ,p_target_date                   => l_target_date
  ,p_next_review_date              => l_next_review_date
  ,p_group_code                    => p_group_code
  ,p_priority_code                 => p_priority_code
  ,p_appraise_flag                 => p_appraise_flag
  ,p_weighting_percent             => p_weighting_percent
  ,p_measurement_style_code        => p_measurement_style_code
  ,p_measure_name                  => p_measure_name
  ,p_target_value                  => p_target_value
  ,p_uom_code       		   => p_uom_code
  ,p_measure_type_code             => p_measure_type_code
  ,p_measure_comments              => p_measure_comments
  ,p_eligibility_type_code         => p_eligibility_type_code
  ,p_details                       => p_details
  ,p_success_criteria              => p_success_criteria
  ,p_comments                      => p_comments
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_objective_id                  => l_objective_id
  ,p_object_version_number         => l_object_version_number
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_weighting_over_100_warning    => l_weighting_over_100_warning
  ,p_weighting_appraisal_warning   => l_weighting_appraisal_warning
  );

  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

   --
   -- Call After Process User Hook
   --

   begin

  hr_objective_library_bk1.create_library_objective_a
  (p_effective_date                => l_effective_date
  ,p_objective_id                  => l_objective_id
  ,p_objective_name                => p_objective_name
  ,p_valid_from                    => l_valid_from
  ,p_valid_to                      => l_valid_to
  ,p_target_date                   => l_target_date
  ,p_next_review_date              => l_next_review_date
  ,p_group_code                    => p_group_code
  ,p_priority_code                 => p_priority_code
  ,p_appraise_flag                 => p_appraise_flag
  ,p_weighting_percent             => p_weighting_percent
  ,p_measurement_style_code        => p_measurement_style_code
  ,p_measure_name                  => p_measure_name
  ,p_target_value                  => p_target_value
  ,p_uom_code    		   => p_uom_code
  ,p_measure_type_code             => p_measure_type_code
  ,p_measure_comments              => p_measure_comments
  ,p_eligibility_type_code         => p_eligibility_type_code
  ,p_details                       => p_details
  ,p_success_criteria              => p_success_criteria
  ,p_comments                      => p_comments
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => l_object_version_number
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_weighting_over_100_warning    => l_weighting_over_100_warning
  ,p_weighting_appraisal_warning   => l_weighting_appraisal_warning
  );

  exception
   when hr_api.cannot_find_prog_unit then
   hr_api.cannot_find_prog_unit_error
    (p_module_name => 'CREATE_LIBRARY_OBJECTIVE',
     p_hook_type   => 'AP'
    );

  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;

  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_objective_id                := l_objective_id;
  p_object_version_number       := l_object_version_number;
  p_duplicate_name_warning      := l_duplicate_name_warning;
  p_weighting_over_100_warning  := l_weighting_over_100_warning;
  p_weighting_appraisal_warning := l_weighting_appraisal_warning;


  IF g_debug THEN

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_objective_id                 '||
                        to_char(p_objective_id));
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    IF p_duplicate_name_warning THEN
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'FALSE');
    END IF;
    IF p_weighting_over_100_warning THEN
      hr_utility.trace('  p_weighting_over_100_warning   '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_weighting_over_100_warning   '||
                          'FALSE');
    END IF;
    IF p_weighting_appraisal_warning THEN
      hr_utility.trace('  p_weighting_appraisal_warning   '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_weighting_appraisal_warning   '||
                          'FALSE');
    END IF;
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');
    hr_utility.set_location(' Leaving:'||l_proc, 970);

  END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_library_objective;
    --
    --  Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_objective_id           	  := null;
    p_object_version_number  	  := null;
    p_duplicate_name_warning 	  := l_duplicate_name_warning;
    p_weighting_over_100_warning  := l_weighting_over_100_warning;
    p_weighting_appraisal_warning := l_weighting_appraisal_warning;

    --
    hr_utility.set_location(' Leaving:'||l_proc, 980);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_library_objective;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_objective_id           	  := null;
    p_object_version_number  	  := null;
    p_duplicate_name_warning 	  := null;
    p_weighting_over_100_warning  := null;
    p_weighting_appraisal_warning := null;

    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

  end create_library_objective;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Update_Library_Objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_library_objective
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_objective_id                  in   number
  ,p_objective_name                in   varchar2   default hr_api.g_varchar2
  ,p_valid_from                    in   date       default hr_api.g_date
  ,p_valid_to                      in   date       default hr_api.g_date
  ,p_target_date                   in   date       default hr_api.g_date
  ,p_next_review_date              in   date       default hr_api.g_date
  ,p_group_code                    in   varchar2   default hr_api.g_varchar2
  ,p_priority_code                 in   varchar2   default hr_api.g_varchar2
  ,p_appraise_flag                 in   varchar2   default hr_api.g_varchar2
  ,p_weighting_percent             in   number     default hr_api.g_number
  ,p_measurement_style_code        in   varchar2   default hr_api.g_varchar2
  ,p_measure_name                  in   varchar2   default hr_api.g_varchar2
  ,p_target_value                  in   number     default hr_api.g_number
  ,p_uom_code                      in   varchar2   default hr_api.g_varchar2
  ,p_measure_type_code             in   varchar2   default hr_api.g_varchar2
  ,p_measure_comments              in   varchar2   default hr_api.g_varchar2
  ,p_eligibility_type_code         in   varchar2   default hr_api.g_varchar2
  ,p_details                       in   varchar2   default hr_api.g_varchar2
  ,p_success_criteria              in   varchar2   default hr_api.g_varchar2
  ,p_comments                      in   varchar2   default hr_api.g_varchar2
  ,p_attribute_category            in   varchar2   default hr_api.g_varchar2
  ,p_attribute1                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute2                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute3                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute4                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute5                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute6                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute7                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute8                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute9                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute10                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute11                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute12                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute13                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute14                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute15                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute16                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute17                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute18                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute19                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute20                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute21                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute22                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute23                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute24                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute25                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute26                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute27                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute28                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute29                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute30                   in   varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_weighting_over_100_warning       out nocopy   boolean
  ,p_weighting_appraisal_warning      out nocopy   boolean
  ) is

  --
  -- Declare cursors and local variables
  --
  --
  l_proc                        varchar2(72) := g_package||'update_library_objective';
  l_effective_date              date;
  l_valid_from                  date;
  l_valid_to                    date;
  l_target_date                 date;
  l_next_review_date            date;
  l_object_version_number       number;
  l_duplicate_name_warning      boolean := false;
  l_weighting_over_100_warning  boolean := false;
  l_weighting_appraisal_warning boolean := false;

  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace('  p_objective_id                   '||
                        to_char(p_objective_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_objective_name                 '||
                        p_objective_name);
    hr_utility.trace('  p_valid_from                     '||
                        to_char(p_valid_from));
    hr_utility.trace('  p_valid_to                       '||
                        to_char(p_valid_to));
    hr_utility.trace('  p_target_date                    '||
                        to_char(p_target_date));
    hr_utility.trace('  p_next_review_date               '||
                        to_char(p_next_review_date));
    hr_utility.trace('  p_group_code                     '||
                        p_group_code);
    hr_utility.trace('  p_priority_code                  '||
                        p_priority_code);
    hr_utility.trace('  p_appraise_flag                  '||
                        p_appraise_flag);
    hr_utility.trace('  p_weighting_percent              '||
                        to_char(p_weighting_percent));
    hr_utility.trace('  p_measurement_style_code         '||
                        p_measurement_style_code);
    hr_utility.trace('  p_measure_name                   '||
                        p_measure_name);
    hr_utility.trace('  p_target_value                   '||
                        to_char(p_target_value));
    hr_utility.trace('  p_uom_code                       '||
                        p_uom_code);
    hr_utility.trace('  p_measure_type_code              '||
                        p_measure_type_code);
    hr_utility.trace('  p_measure_comments               '||
                        p_measure_comments);
    hr_utility.trace('  p_eligibility_type_code          '||
                        p_eligibility_type_code);
    hr_utility.trace('  p_details                        '||
                        p_details);
    hr_utility.trace('  p_success_criteria               '||
                        p_success_criteria);
    hr_utility.trace('  p_comments                       '||
                        p_comments);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint update_library_objective;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date     := trunc(p_effective_date);
  l_valid_from         := trunc(p_valid_from);
  l_valid_to           := trunc(p_valid_to);
  l_target_date        := trunc(p_target_date);
  l_next_review_date   := trunc(p_next_review_date);

  --
  -- Call Before Process User Hook
  --
  begin

   hr_objective_library_bk2.update_library_objective_b
  (p_effective_date                => l_effective_date
  ,p_objective_id                  => p_objective_id
  ,p_objective_name                => p_objective_name
  ,p_valid_from                    => l_valid_from
  ,p_valid_to                      => l_valid_to
  ,p_target_date                   => l_target_date
  ,p_next_review_date              => l_next_review_date
  ,p_group_code                    => p_group_code
  ,p_priority_code                 => p_priority_code
  ,p_appraise_flag                 => p_appraise_flag
  ,p_weighting_percent             => p_weighting_percent
  ,p_measurement_style_code        => p_measurement_style_code
  ,p_measure_name                  => p_measure_name
  ,p_target_value                  => p_target_value
  ,p_uom_code      		   => p_uom_code
  ,p_measure_type_code             => p_measure_type_code
  ,p_measure_comments              => p_measure_comments
  ,p_eligibility_type_code         => p_eligibility_type_code
  ,p_details                       => p_details
  ,p_success_criteria              => p_success_criteria
  ,p_comments                      => p_comments
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => l_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
    hr_api.cannot_find_prog_unit_error
     (p_module_name => 'UPDATE_LIBRARY_OBJECTIVE',
      p_hook_type   => 'BP'
     );

  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  --
  -- Call the row handler update
  --
  per_pml_upd.upd
  (p_effective_date                => l_effective_date
  ,p_objective_id		   => p_objective_id
  ,p_object_version_number         => l_object_version_number
  ,p_objective_name                => p_objective_name
  ,p_valid_from                    => l_valid_from
  ,p_valid_to                      => l_valid_to
  ,p_target_date                   => l_target_date
  ,p_next_review_date              => l_next_review_date
  ,p_group_code                    => p_group_code
  ,p_priority_code          	   => p_priority_code
  ,p_appraise_flag                 => p_appraise_flag
  ,p_weighting_percent             => p_weighting_percent
  ,p_measurement_style_code        => p_measurement_style_code
  ,p_measure_name                  => p_measure_name
  ,p_target_value                  => p_target_value
  ,p_uom_code    		   => p_uom_code
  ,p_measure_type_code             => p_measure_type_code
  ,p_measure_comments              => p_measure_comments
  ,p_eligibility_type_code         => p_eligibility_type_code
  ,p_details                       => p_details
  ,p_success_criteria              => p_success_criteria
  ,p_comments                      => p_comments
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_weighting_over_100_warning    => l_weighting_over_100_warning
  ,p_weighting_appraisal_warning   => l_weighting_appraisal_warning
  );

  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  --
  -- Call After Process User Hook
  --
  begin
  hr_objective_library_bk2.update_library_objective_a
  (p_effective_date                => l_effective_date
  ,p_objective_id                  => p_objective_id
  ,p_objective_name                => p_objective_name
  ,p_valid_from                    => l_valid_from
  ,p_valid_to                      => l_valid_to
  ,p_target_date                   => l_target_date
  ,p_next_review_date              => l_next_review_date
  ,p_group_code                    => p_group_code
  ,p_priority_code                 => p_priority_code
  ,p_appraise_flag                 => p_appraise_flag
  ,p_weighting_percent             => p_weighting_percent
  ,p_measurement_style_code        => p_measurement_style_code
  ,p_measure_name                  => p_measure_name
  ,p_target_value                  => p_target_value
  ,p_uom_code   		   => p_uom_code
  ,p_measure_type_code             => p_measure_type_code
  ,p_measure_comments              => p_measure_comments
  ,p_eligibility_type_code         => p_eligibility_type_code
  ,p_details                       => p_details
  ,p_success_criteria              => p_success_criteria
  ,p_comments                      => p_comments
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
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => p_object_version_number
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_weighting_over_100_warning    => l_weighting_over_100_warning
  ,p_weighting_appraisal_warning   => l_weighting_appraisal_warning
  );
  exception
   when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'UPDATE_LIBRARY_OBJECTIVE',
       p_hook_type   => 'AP'
      );
  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;

  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number         := l_object_version_number;
  p_duplicate_name_warning        := l_duplicate_name_warning;
  p_weighting_over_100_warning    := l_weighting_over_100_warning;
  p_weighting_appraisal_warning   := l_weighting_appraisal_warning;

  IF g_debug THEN

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    IF p_duplicate_name_warning THEN
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'FALSE');
    END IF;
    IF p_weighting_over_100_warning THEN
      hr_utility.trace('  p_weighting_over_100_warning   '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_weighting_over_100_warning   '||
                          'FALSE');
    END IF;
    IF p_weighting_appraisal_warning THEN
      hr_utility.trace('  p_weighting_appraisal_warning   '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_weighting_appraisal_warning   '||
                          'FALSE');
    END IF;
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');
    hr_utility.set_location(' Leaving:'||l_proc, 970);

  END IF;

  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      ROLLBACK TO update_library_objective;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number         := null;
      p_duplicate_name_warning        := l_duplicate_name_warning;
      p_weighting_over_100_warning    := l_weighting_over_100_warning;
      p_weighting_appraisal_warning   := l_weighting_appraisal_warning;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_library_objective;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number       := null;
    p_duplicate_name_warning      := null;
    p_weighting_over_100_warning  := null;
    p_weighting_appraisal_warning := null;

    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

end update_library_objective;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Delete_Library_Objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_library_objective
  (p_validate                      in   boolean         default false
  ,p_objective_id                  in   number
  ,p_object_version_number         in   number
  ) is

  --
  -- Declare cursors and local variables
  --
     l_proc                  varchar2(72) := g_package||'delete_library_objective';
  --

  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_objective_id                   '||
                        to_char(p_objective_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
     savepoint delete_library_objective;
  --
  -- Call Before Process User Hook
  --
  begin

    hr_objective_library_bk3.delete_library_objective_b
    (p_objective_id           => p_objective_id
    ,p_object_version_number  => p_object_version_number
    );
  exception
   when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'DELETE_LIBRARY_OBJECTIVE',
       p_hook_type   => 'BP'
      );
  end;

  --
  -- End of Before Process User Hook call
  --
     hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete Objective
  --

   per_pml_del.del
    (p_objective_id           => p_objective_id
    ,p_object_version_number  => p_object_version_number
    );

  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
  hr_objective_library_bk3.delete_library_objective_a
    (p_objective_id           => p_objective_id
    ,p_object_version_number  => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'DELETE_LIBRARY_OBJECTIVE',
       p_hook_type   => 'AP'
      );
  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  IF g_debug THEN hr_utility.set_location(' Leaving:'||l_proc, 970); END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_library_objective;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 980);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_library_objective;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

 end delete_library_objective;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_eligy_profile >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_name                         Yes  varchar2
--   p_elig_pstn_flag               No   varchar2
--   p_elig_grd_flag                No   varchar2
--   p_elig_org_unit_flag           No   varchar2
--   p_elig_job_flag                No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_profile
  (p_validate             in    boolean   default false
  ,p_effective_date       in    date
  ,p_business_group_id    in    number
  ,p_name                 in    varchar2  default null
  ,p_bnft_cagr_prtn_cd    in    varchar2  default null
  ,p_stat_cd              in    varchar2  default null
  ,p_asmt_to_use_cd       in    varchar2  default null
  ,p_elig_grd_flag        in    varchar2  default 'N'
  ,p_elig_org_unit_flag   in    varchar2  default 'N'
  ,p_elig_job_flag        in    varchar2  default 'N'
  ,p_elig_pstn_flag       in    varchar2  default 'N'
  ,p_eligy_prfl_id          out nocopy number
  ,p_object_version_number  out nocopy number
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ) is

  l_object_version_number  ben_eligy_prfl_f.object_version_number%type;
  l_eligy_prfl_id          ben_eligy_prfl_f.eligy_prfl_id%type;
  l_effective_start_date   ben_eligy_prfl_f.effective_start_date%type;
  l_effective_end_date     ben_eligy_prfl_f.effective_end_date%type;
begin

  ben_eligy_profile_api.create_eligy_profile
  (p_validate		   =>  p_validate
  ,p_name                  =>  p_name
  ,p_bnft_cagr_prtn_cd     =>  p_bnft_cagr_prtn_cd
  ,p_stat_cd               =>  p_stat_cd
  ,p_asmt_to_use_cd        =>  p_asmt_to_use_cd
  ,p_eligy_prfl_id         =>  l_eligy_prfl_id
  ,p_elig_grd_flag         =>  p_elig_grd_flag
  ,p_elig_org_unit_flag    =>  p_elig_org_unit_flag
  ,p_elig_job_flag         =>  p_elig_job_flag
  ,p_elig_pstn_flag    	   =>  p_elig_pstn_flag
  ,p_object_version_number =>  l_object_version_number
  ,p_business_group_id     =>  p_business_group_id
  ,p_effective_date	   =>  p_effective_date
  ,p_effective_start_date  =>  l_effective_start_date
  ,p_effective_end_date    =>  l_effective_end_date
  );

  p_object_version_number := l_object_version_number;
  p_eligy_prfl_id         := l_eligy_prfl_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;

end create_eligy_profile;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_profile >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:

procedure update_eligy_profile
 ( p_validate             in    boolean   default false
  ,p_effective_date       in    date
  ,p_business_group_id    in    number
  ,p_name                 in    varchar2  default null
  ,p_bnft_cagr_prtn_cd     in    varchar2  default null
  ,p_stat_cd               in    varchar2  default null
  ,p_asmt_to_use_cd        in    varchar2  default null
  ,p_elig_grd_flag         in    varchar2  default 'N'
  ,p_elig_org_unit_flag    in    varchar2  default 'N'
  ,p_elig_job_flag         in    varchar2  default 'N'
  ,p_elig_pstn_flag        in    varchar2  default 'N'
  ,p_eligy_prfl_id         in   number
  ,p_object_version_number in out nocopy number
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_datetrack_mode   in varchar2
 ) is
  l_object_version_number  ben_eligy_prfl_f.object_version_number%type;
  l_effective_start_date   ben_eligy_prfl_f.effective_start_date%type;
  l_effective_end_date     ben_eligy_prfl_f.effective_end_date%type;
 begin

 l_object_version_number:=p_object_version_number;

  ben_eligy_profile_api.update_eligy_profile
    (
       p_validate              =>    p_validate
      ,p_eligy_prfl_id         =>    p_eligy_prfl_id
      ,p_name                  =>    p_name
      ,p_stat_cd               =>    p_stat_cd
      ,p_asmt_to_use_cd        =>    p_asmt_to_use_cd
      ,p_elig_grd_flag         =>    p_elig_grd_flag
      ,p_elig_org_unit_flag    =>	 p_elig_org_unit_flag
      ,p_elig_job_flag         =>	 p_elig_job_flag
      ,p_elig_pstn_flag        =>	 p_elig_pstn_flag
      ,p_object_version_number =>	 l_object_version_number
      ,p_effective_start_date  =>	 l_effective_start_date
      ,p_effective_end_date    =>	 l_effective_end_date
      ,p_datetrack_mode        =>    p_datetrack_mode
      ,p_business_group_id     =>    p_business_group_id
      ,p_effective_date        =>    p_effective_date
   );

  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;

end update_eligy_profile;

-- ----------------------------------------------------------------------------
-- |--------------------------< create_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_object
  (p_validate                       in boolean    default false
  ,p_elig_obj_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_table_name                     in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_value                   in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 ) is

   l_elig_obj_id           ben_elig_obj_f.elig_obj_id%type;
   l_effective_start_date  ben_elig_obj_f.effective_start_date%type;
   l_effective_end_date    ben_elig_obj_f.effective_end_date%type;
   l_object_version_number ben_elig_obj_f.object_version_number%type;

begin

   ben_elig_obj_api.create_ELIG_OBJ
   (p_validate                =>  p_validate
   ,p_elig_obj_id             =>  l_elig_obj_id
   ,p_effective_start_date    =>  l_effective_start_date
   ,p_effective_end_date      =>  l_effective_end_date
   ,p_business_group_id       =>  p_business_group_id
   ,p_table_name              =>  p_table_name
   ,p_column_name             =>  p_column_name
   ,p_column_value            =>  p_column_value
   ,p_object_version_number   =>  l_object_version_number
   ,p_effective_date          =>  p_effective_date
   );

   p_effective_start_date  := l_effective_start_date ;
   p_elig_obj_id           := l_elig_obj_id;
   p_effective_end_date    := l_effective_end_date;
   p_object_version_number := l_object_version_number;

end create_eligy_object;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_object
  (p_validate                       in boolean    default false
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_table_name                     in  varchar2  default hr_api.g_varchar2
  ,p_column_name                    in  varchar2  default hr_api.g_varchar2
  ,p_column_value                   in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
) is

    l_object_version_number ben_elig_obj_f.object_version_number%TYPE;
    l_effective_start_date ben_elig_obj_f.effective_start_date%TYPE;
    l_effective_end_date ben_elig_obj_f.effective_end_date%TYPE;

begin

    l_object_version_number := p_object_version_number;

    ben_elig_obj_api.update_ELIG_OBJ
     (p_validate 		=>  p_validate
     ,p_elig_obj_id		=>  p_elig_obj_id
     ,p_effective_start_date    =>  l_effective_start_date
     ,p_effective_end_date	=>  l_effective_end_date
     ,p_business_group_id 	=>  p_business_group_id
     ,p_table_name		=>  p_table_name
     ,p_column_name		=>  p_column_name
     ,p_column_value		=>  p_column_value
     ,p_object_version_number	=>  l_object_version_number
     ,p_effective_date 		=>  p_effective_date
     ,p_datetrack_mode		=>  p_datetrack_mode
     );

      p_object_version_number := l_object_version_number;
      p_effective_start_date := l_effective_start_date;
      p_effective_end_date := l_effective_end_date;

end update_eligy_object;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_object
  (p_validate                       in boolean        default false
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ) is

    l_object_version_number ben_elig_obj_f.object_version_number%TYPE;
    l_effective_start_date ben_elig_obj_f.effective_start_date%TYPE;
    l_effective_end_date ben_elig_obj_f.effective_end_date%TYPE;

begin

    l_object_version_number := p_object_version_number;

    ben_elig_obj_api.delete_ELIG_OBJ
     (p_validate                =>  p_validate
     ,p_elig_obj_id             =>  p_elig_obj_id
     ,p_effective_start_date    =>  l_effective_start_date
     ,p_effective_end_date      =>  l_effective_end_date
     ,p_object_version_number   =>  l_object_version_number
     ,p_effective_date          =>  p_effective_date
     ,p_datetrack_mode          =>  p_datetrack_mode
     );

      p_object_version_number := l_object_version_number;
      p_effective_start_date := l_effective_start_date;
      p_effective_end_date := l_effective_end_date;

end delete_eligy_object;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_elig_obj_elig_prfl
  (p_validate                   in    boolean    default false
  ,p_elig_obj_elig_prfl_id        out nocopy number
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_business_group_id          in    number    default null
  ,p_elig_obj_id                in    number    default null
  ,p_elig_prfl_id               in    number    default null
  ,p_object_version_number        out nocopy number
  ,p_effective_date             in    date
 ) is

   l_elig_obj_elig_prfl_id ben_elig_obj_elig_profl_f.elig_obj_elig_prfl_id%TYPE;
   l_effective_start_date ben_elig_obj_elig_profl_f.effective_start_date%TYPE;
   l_effective_end_date ben_elig_obj_elig_profl_f.effective_end_date%TYPE;
   l_object_version_number ben_elig_obj_elig_profl_f.object_version_number%TYPE;

begin

   ben_ELIG_OBJ_ELIG_PROFL_api.create_ELIG_OBJ_ELIG_PROFL
    (p_validate                 => p_validate
    ,p_elig_obj_elig_prfl_id    => l_elig_obj_elig_prfl_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_business_group_id        => p_business_group_id
    ,p_elig_obj_id              => p_elig_obj_id
    ,p_elig_prfl_id             => p_elig_prfl_id
    ,p_mndtry_flag              => 'Y'
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date          => p_effective_date
    );

    p_effective_start_date  :=  l_effective_start_date;
    p_effective_end_date    :=  l_effective_end_date;
    p_object_version_number :=  l_object_version_number;
    p_elig_obj_elig_prfl_id :=  l_elig_obj_elig_prfl_id;

end create_elig_obj_elig_prfl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_elig_obj_elig_prfl
  (p_validate                       in boolean    default false
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

   l_effective_start_date ben_elig_obj_elig_profl_f.effective_start_date%TYPE;
   l_effective_end_date ben_elig_obj_elig_profl_f.effective_end_date%TYPE;
   l_object_version_number ben_elig_obj_elig_profl_f.object_version_number%TYPE;

begin

    l_object_version_number := p_object_version_number;

    ben_ELIG_OBJ_ELIG_PROFL_api.update_ELIG_OBJ_ELIG_PROFL
    (p_validate                 => p_validate
    ,p_elig_obj_elig_prfl_id    => p_elig_obj_elig_prfl_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_elig_obj_id              => p_elig_obj_id
    ,p_elig_prfl_id             => p_elig_prfl_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date           => p_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
    );

    p_effective_start_date  :=  l_effective_start_date;
    p_effective_end_date    :=  l_effective_end_date;
    p_object_version_number :=  l_object_version_number;

end update_elig_obj_elig_prfl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_elig_obj_elig_prfl
  (p_validate                       in boolean    default false
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

   l_effective_start_date ben_elig_obj_elig_profl_f.effective_start_date%TYPE;
   l_effective_end_date ben_elig_obj_elig_profl_f.effective_end_date%TYPE;
   l_object_version_number ben_elig_obj_elig_profl_f.object_version_number%TYPE;

begin

    l_object_version_number := p_object_version_number;

    ben_ELIG_OBJ_ELIG_PROFL_api.delete_ELIG_OBJ_ELIG_PROFL
    (p_validate                 => p_validate
    ,p_elig_obj_elig_prfl_id    => p_elig_obj_elig_prfl_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date           => p_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
    );

    p_effective_start_date  :=  l_effective_start_date;
    p_effective_end_date    :=  l_effective_end_date;
    p_object_version_number :=  l_object_version_number;


end delete_elig_obj_elig_prfl;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_grade >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_grade
 (p_validate                     in    boolean   default false
 ,p_elig_grd_prte_id               out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_grade_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
) is

  l_elig_grd_prte_id ben_elig_grd_prte_f.elig_grd_prte_id%TYPE;
  l_effective_start_date ben_elig_grd_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_grd_prte_f.effective_end_date%TYPE;
  l_object_version_number ben_elig_grd_prte_f.object_version_number%TYPE;

begin

   ben_ELIG_GRD_PRTE_api.create_ELIG_GRD_PRTE
    (p_validate                => p_validate
    ,p_elig_grd_prte_id        => l_elig_grd_prte_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_grade_id                => p_grade_id
    ,p_ordr_num  	       => p_ordr_num
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date                                  ,p_excld_flag	       => 'N'
    );

    p_elig_grd_prte_id      := l_elig_grd_prte_id;
    p_effective_end_date    := l_effective_end_date;
    p_effective_start_date  := l_effective_start_date;
    p_object_version_number := l_object_version_number;

end create_eligy_grade;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_grade >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_grade
  (p_validate                       in boolean    default false
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

  l_object_version_number ben_elig_grd_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_grd_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_grd_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIG_GRD_PRTE_api.update_ELIG_GRD_PRTE
   (p_validate  		    => p_validate
   ,p_elig_grd_prte_id              => p_elig_grd_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_business_group_id             => p_business_group_id
   ,p_eligy_prfl_id                 => p_eligy_prfl_id
   ,p_grade_id                      => p_grade_id
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date   	 	    => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
   ,p_excld_flag                    => 'N'
   );

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;


end update_eligy_grade;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_grade >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_grade
  (p_validate                       in boolean    default false
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is


  l_object_version_number ben_elig_grd_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_grd_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_grd_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIG_GRD_PRTE_api.delete_ELIG_GRD_PRTE
   (p_validate                      => p_validate
   ,p_elig_grd_prte_id              => p_elig_grd_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
   );

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;

end delete_eligy_grade;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_org >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_org
 (p_validate                     in    boolean   default false
 ,p_elig_org_unit_prte_id          out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_organization_id              in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
) is

  l_elig_org_unit_prte_id ben_elig_grd_prte_f.elig_grd_prte_id%TYPE;
  l_effective_start_date ben_elig_grd_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_grd_prte_f.effective_end_date%TYPE;
  l_object_version_number ben_elig_grd_prte_f.object_version_number%TYPE;
begin

   ben_ELIG_ORG_UNIT_PRTE_api.create_ELIG_ORG_UNIT_PRTE
    (p_validate                => p_validate
    ,p_elig_org_unit_prte_id  => l_elig_org_unit_prte_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_organization_id         => p_organization_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_excld_flag              => 'N'
    );

    p_elig_org_unit_prte_id := l_elig_org_unit_prte_id;
    p_effective_end_date    := l_effective_end_date;
    p_effective_start_date  := l_effective_start_date;
    p_object_version_number := l_object_version_number;

end create_eligy_org;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_eligy_org >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_org
  (p_validate                       in boolean    default false
  ,p_elig_org_unit_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                   in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

  l_object_version_number ben_elig_org_unit_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_org_unit_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_org_unit_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIG_org_unit_PRTE_api.update_ELIG_org_unit_PRTE
   (p_validate                      => p_validate
   ,p_elig_org_unit_prte_id         => p_elig_org_unit_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_business_group_id             => p_business_group_id
   ,p_eligy_prfl_id                 => p_eligy_prfl_id
   ,p_organization_id               => p_organization_id
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
   ,p_excld_flag              	    => 'N'
   );

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;


end update_eligy_org;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_org >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_org
  (p_validate                       in boolean    default false
  ,p_elig_org_unit_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is


  l_object_version_number ben_elig_org_unit_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_org_unit_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_org_unit_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIG_org_unit_PRTE_api.delete_ELIG_org_unit_PRTE
   (p_validate                      => p_validate
   ,p_elig_org_unit_prte_id         => p_elig_org_unit_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
);

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;

end delete_eligy_org;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_job >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_job
 (p_validate                     in    boolean   default false
 ,p_elig_job_prte_id               out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_job_id                       in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date               in  date
) is

  l_elig_job_prte_id ben_elig_grd_prte_f.elig_grd_prte_id%TYPE;
  l_effective_start_date ben_elig_grd_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_grd_prte_f.effective_end_date%TYPE;
  l_object_version_number ben_elig_grd_prte_f.object_version_number%TYPE;
begin

   ben_ELIGY_JOB_PRTE_api.create_ELIGY_JOB_PRTE
    (p_validate                => p_validate
    ,p_elig_job_prte_id        => l_elig_job_prte_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_job_id 	               => p_job_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_excld_flag              => 'N'
    );

    p_elig_job_prte_id      := l_elig_job_prte_id;
    p_effective_end_date    := l_effective_end_date;
    p_effective_start_date  := l_effective_start_date;
    p_object_version_number := l_object_version_number;

end create_eligy_job;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_job >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_job
  (p_validate                       in boolean    default false
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
 ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_job_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

  l_object_version_number ben_elig_job_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_job_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_job_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIGY_JOB_PRTE_api.update_ELIGY_JOB_PRTE
   (p_validate                      => p_validate
   ,p_elig_job_prte_id              => p_elig_job_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_business_group_id             => p_business_group_id
   ,p_eligy_prfl_id                 => p_eligy_prfl_id
   ,p_job_id                        => p_job_id
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
   ,p_excld_flag                    => 'N'
   );

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;


end update_eligy_job;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_job >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_job
  (p_validate                       in boolean    default false
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is


  l_object_version_number ben_elig_job_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_job_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_job_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIGY_JOB_PRTE_api.delete_ELIGY_JOB_PRTE
   (p_validate                      => p_validate
   ,p_elig_job_prte_id              => p_elig_job_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
);

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;

end delete_eligy_job;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_position >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- positiont Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- positiont Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_position
 (p_validate                     in    boolean   default false
 ,p_elig_pstn_prte_id              out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_position_id                  in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date               in  date
) is

  l_elig_pstn_prte_id ben_elig_grd_prte_f.elig_grd_prte_id%TYPE;
  l_effective_start_date ben_elig_grd_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_grd_prte_f.effective_end_date%TYPE;
  l_object_version_number ben_elig_grd_prte_f.object_version_number%TYPE;
begin

    ben_ELIG_PSTN_PRTE_api.create_ELIG_PSTN_PRTE
    (p_validate                => p_validate
    ,p_elig_pstn_prte_id        => l_elig_pstn_prte_id
    ,p_effective_start_date    => l_effective_start_date
    ,p_effective_end_date      => l_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_position_id             => p_position_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_excld_flag              => 'N'
    );

    p_elig_pstn_prte_id      := l_elig_pstn_prte_id;
    p_effective_end_date    := l_effective_end_date;
    p_effective_start_date  := l_effective_start_date;
    p_object_version_number := l_object_version_number;

end create_eligy_position;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_position >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_position
  (p_validate                       in boolean    default false
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_position_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

  l_object_version_number ben_elig_pstn_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_pstn_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_pstn_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIG_PSTN_PRTE_api.update_ELIG_PSTN_PRTE
   (p_validate                      => p_validate
   ,p_elig_pstn_prte_id              => p_elig_pstn_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_business_group_id             => p_business_group_id
   ,p_eligy_prfl_id                 => p_eligy_prfl_id
   ,p_position_id                      => p_position_id
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
   ,p_excld_flag              	    => 'N'
   );

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;


end update_eligy_position;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_position >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_position
  (p_validate                       in boolean    default false
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is


  l_object_version_number ben_elig_pstn_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_pstn_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_pstn_prte_f.effective_end_date%TYPE;

begin

   l_object_version_number := p_object_version_number;

   ben_ELIG_PSTN_PRTE_api.delete_ELIG_PSTN_PRTE
   (p_validate                      => p_validate
   ,p_elig_pstn_prte_id              => p_elig_pstn_prte_id
   ,p_effective_start_date          => l_effective_start_date
   ,p_effective_end_date            => l_effective_end_date
   ,p_object_version_number         => l_object_version_number
   ,p_effective_date                => p_effective_date
   ,p_datetrack_mode                => p_datetrack_mode
);

   p_object_version_number := l_object_version_number;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;

end delete_eligy_position;
--

end HR_OBJECTIVE_LIBRARY_API;

/
