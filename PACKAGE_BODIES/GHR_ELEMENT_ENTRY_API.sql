--------------------------------------------------------
--  DDL for Package Body GHR_ELEMENT_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_ELEMENT_ENTRY_API" AS
/* $Header: gheleapi.pkb 120.0.12010000.2 2009/05/26 10:35:58 utokachi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_element_entry_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_element_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_element_entry
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_original_entry_id             in     number   default null
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_cost_allocation_keyflex_id    in     number   default null
  ,p_updating_action_id            in     number   default null
  ,p_comment_id                    in     number   default null
  ,p_reason                        in     varchar2 default null
  ,p_target_entry_id               in     number   default null
  ,p_subpriority                   in     number   default null
  ,p_date_earned                   in     date     default null
  ,p_personal_payment_method_id    in     number   default null
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
  ,p_input_value_id1               in     number   default null
  ,p_input_value_id2               in     number   default null
  ,p_input_value_id3               in     number   default null
  ,p_input_value_id4               in     number   default null
  ,p_input_value_id5               in     number   default null
  ,p_input_value_id6               in     number   default null
  ,p_input_value_id7               in     number   default null
  ,p_input_value_id8               in     number   default null
  ,p_input_value_id9               in     number   default null
  ,p_input_value_id10              in     number   default null
  ,p_input_value_id11              in     number   default null
  ,p_input_value_id12              in     number   default null
  ,p_input_value_id13              in     number   default null
  ,p_input_value_id14              in     number   default null
  ,p_input_value_id15              in     number   default null
  ,p_entry_value1                  in     varchar2 default null
  ,p_entry_value2                  in     varchar2 default null
  ,p_entry_value3                  in     varchar2 default null
  ,p_entry_value4                  in     varchar2 default null
  ,p_entry_value5                  in     varchar2 default null
  ,p_entry_value6                  in     varchar2 default null
  ,p_entry_value7                  in     varchar2 default null
  ,p_entry_value8                  in     varchar2 default null
  ,p_entry_value9                  in     varchar2 default null
  ,p_entry_value10                 in     varchar2 default null
  ,p_entry_value11                 in     varchar2 default null
  ,p_entry_value12                 in     varchar2 default null
  ,p_entry_value13                 in     varchar2 default null
  ,p_entry_value14                 in     varchar2 default null
  ,p_entry_value15                 in     varchar2 default null
  ,p_effective_start_date             out NOCOPY date
  ,p_effective_end_date               out NOCOPY date
  ,p_element_entry_id                 out NOCOPY number
  ,p_object_version_number            out NOCOPY number
  ,p_create_warning                   out NOCOPY boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_creator_type          pay_element_entries_f.creator_type%TYPE;
  l_creator_id            pay_element_entries_f.creator_id%TYPE;
  l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
  l_object_version_number pay_element_entries_f.object_version_number%TYPE;
  l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
  l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
  l_process_in_run_flag   pay_element_types_f.process_in_run_flag%TYPE;
  l_closed_for_entry_flag pay_element_types_f.closed_for_entry_flag%TYPE;
  l_period_status         per_time_periods.status%TYPE;
  l_date_on_which_time_served_ok date;
  l_date_on_which_old_enough date;
  l_dummy                 varchar2(1);
  l_create_warning        boolean;
  l_proc                  varchar2(72) := g_package||'create_element_entry';
  --
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    SAVEPOINT ghr_create_element_entry;
  hr_utility.set_location(l_proc, 60);
  --
  ghr_session.set_session_var_for_core
  (p_effective_date  => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 350);
     py_element_entry_api.create_element_entry
     (
      --p_validate             => p_validate,
      p_effective_date       => p_effective_date,
      p_business_group_id    => p_business_group_id,
      p_original_entry_id    => p_original_entry_id,
      p_assignment_id        => p_assignment_id,
      p_element_link_id      => p_element_link_id,
      p_entry_type           => p_entry_type,
      p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
      p_updating_action_id   => p_updating_action_id,
      p_comment_id           => p_comment_id,
      p_reason               => p_reason,
      p_target_entry_id      => p_target_entry_id,
      p_subpriority          => p_subpriority,
      p_date_earned          => p_date_earned,
      p_personal_payment_method_id => p_personal_payment_method_id,
      p_attribute_category   => p_attribute_category,
      p_attribute1           => p_attribute1,
      p_attribute2           => p_attribute2,
      p_attribute3           => p_attribute3,
      p_attribute4           => p_attribute4,
      p_attribute5           => p_attribute5,
      p_attribute6           => p_attribute6,
      p_attribute7           => p_attribute7,
      p_attribute8           => p_attribute8,
      p_attribute9           => p_attribute9,
      p_attribute10          => p_attribute10,
      p_attribute11          => p_attribute11,
      p_attribute12          => p_attribute12,
      p_attribute13          => p_attribute13,
      p_attribute14          => p_attribute14,
      p_attribute15          => p_attribute15,
      p_attribute16          => p_attribute16,
      p_attribute17          => p_attribute17,
      p_attribute18          => p_attribute18,
      p_attribute19          => p_attribute19,
      p_attribute20          => p_attribute20,
      p_input_value_id1      => p_input_value_id1,
      p_input_value_id2      => p_input_value_id2,
      p_input_value_id3      => p_input_value_id3,
      p_input_value_id4      => p_input_value_id4,
      p_input_value_id5      => p_input_value_id5,
      p_input_value_id6      => p_input_value_id6,
      p_input_value_id7      => p_input_value_id7,
      p_input_value_id8      => p_input_value_id8,
      p_input_value_id9      => p_input_value_id9,
      p_input_value_id10     => p_input_value_id10,
      p_input_value_id11     => p_input_value_id11,
      p_input_value_id12     => p_input_value_id12,
      p_input_value_id13     => p_input_value_id13,
      p_input_value_id14     => p_input_value_id14,
      p_input_value_id15     => p_input_value_id15,
      p_entry_value1         => p_entry_value1,
      p_entry_value2         => p_entry_value2,
      p_entry_value3         => p_entry_value3,
      p_entry_value4         => p_entry_value4,
      p_entry_value5         => p_entry_value5,
      p_entry_value6         => p_entry_value6,
      p_entry_value7         => p_entry_value7,
      p_entry_value8         => p_entry_value8,
      p_entry_value9         => p_entry_value9,
      p_entry_value10        => p_entry_value10,
      p_entry_value11        => p_entry_value11,
      p_entry_value12        => p_entry_value12,
      p_entry_value13        => p_entry_value13,
      p_entry_value14        => p_entry_value14,
      p_entry_value15        => p_entry_value15,
      p_effective_start_date => p_effective_start_date,
      p_effective_end_date   => p_effective_end_date,
      p_element_entry_id     => p_element_entry_id,
      p_object_version_number => p_object_version_number,
      p_create_warning        => p_create_warning
     );
  --
  hr_utility.set_location(l_proc, 800);
  --
  ghr_history_api.post_update_process;

  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --

  hr_utility.set_location(' Leaving:'||l_proc, 11);
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_element_entry;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_element_entry_id       := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 900);

  When others then
    ROLLBACK TO ghr_create_element_entry;
    raise;
END create_element_entry;
--
--

-- ----------------------------------------------------------------------------
-- |-------------------------< update_element_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_element_entry
  (p_validate                      in     boolean   default false
  ,p_datetrack_update_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_cost_allocation_keyflex_id    in     number    default hr_api.g_number
  ,p_updating_action_id            in     number    default hr_api.g_number
  ,p_original_entry_id             in     number    default hr_api.g_number
  ,p_creator_type                  in     varchar2  default hr_api.g_varchar2
  ,p_comment_id                    in     number    default hr_api.g_number
  ,p_creator_id                    in     number    default hr_api.g_number
  ,p_reason                        in     varchar2  default hr_api.g_varchar2
  ,p_subpriority                   in     number    default hr_api.g_number
  ,p_date_earned                   in     date      default hr_api.g_date
  ,p_personal_payment_method_id    in     number    default hr_api.g_number
  ,p_attribute_category            in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id1               in     number    default null
  ,p_input_value_id2               in     number    default null
  ,p_input_value_id3               in     number    default null
  ,p_input_value_id4               in     number    default null
  ,p_input_value_id5               in     number    default null
  ,p_input_value_id6               in     number    default null
  ,p_input_value_id7               in     number    default null
  ,p_input_value_id8               in     number    default null
  ,p_input_value_id9               in     number    default null
  ,p_input_value_id10              in     number    default null
  ,p_input_value_id11              in     number    default null
  ,p_input_value_id12              in     number    default null
  ,p_input_value_id13              in     number    default null
  ,p_input_value_id14              in     number    default null
  ,p_input_value_id15              in     number    default null
  ,p_entry_value1                  in     varchar2  default null
  ,p_entry_value2                  in     varchar2  default null
  ,p_entry_value3                  in     varchar2  default null
  ,p_entry_value4                  in     varchar2  default null
  ,p_entry_value5                  in     varchar2  default null
  ,p_entry_value6                  in     varchar2  default null
  ,p_entry_value7                  in     varchar2  default null
  ,p_entry_value8                  in     varchar2  default null
  ,p_entry_value9                  in     varchar2  default null
  ,p_entry_value10                 in     varchar2  default null
  ,p_entry_value11                 in     varchar2  default null
  ,p_entry_value12                 in     varchar2  default null
  ,p_entry_value13                 in     varchar2  default null
  ,p_entry_value14                 in     varchar2  default null
  ,p_entry_value15                 in     varchar2  default null
  ,p_effective_start_date             out NOCOPY date
  ,p_effective_end_date               out NOCOPY date
  ,p_update_warning                   out NOCOPY boolean
  ) IS
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'update_element_entry';
  l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
  l_object_version_number pay_element_entries_f.object_version_number%TYPE;
  l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
  l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
  l_creator_type          pay_element_entries_f.creator_type%TYPE;
  l_creator_id            pay_element_entries_f.creator_id%TYPE;
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    SAVEPOINT ghr_update_element_entry;
  hr_utility.set_location(l_proc, 6);
  --
  --

  ghr_session.set_session_var_for_core
  (p_effective_date   => p_effective_date
  );

  py_element_entry_api.update_element_entry
  (
  p_datetrack_update_mode      => p_datetrack_update_mode,
  p_effective_date             => p_effective_date,
  p_business_group_id          => p_business_group_id,
  p_element_entry_id        	 => p_element_entry_id,
  p_object_version_number    	 => p_object_version_number,
  p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
  p_updating_action_id   	 => p_updating_action_id,
  p_original_entry_id    	 => p_original_entry_id,
  p_creator_type 			 => p_creator_type,
  p_comment_id   			 => p_comment_id,
  p_creator_id  			 => p_creator_id,
  p_reason 			   	 => p_reason,
  p_subpriority			 => p_subpriority,
  p_date_earned                => p_date_earned,
  p_personal_payment_method_id => p_personal_payment_method_id,
  p_attribute_category 		 => p_attribute_category,
  p_attribute1      		 => p_attribute1,
  p_attribute2       		 => p_attribute2,
  p_attribute3       	  	 => p_attribute3,
  p_attribute4       => p_attribute4,
  p_attribute5       => p_attribute5,
  p_attribute6       => p_attribute6,
  p_attribute7       => p_attribute7,
  p_attribute8       => p_attribute8,
  p_attribute9       => p_attribute9,
  p_attribute10      => p_attribute10,
  p_attribute11      => p_attribute11,
  p_attribute12      => p_attribute12,
  p_attribute13      => p_attribute13,
  p_attribute14      => p_attribute14,
  p_attribute15      => p_attribute15,
  p_attribute16      => p_attribute16,
  p_attribute17      => p_attribute17,
  p_attribute18      => p_attribute18,
  p_attribute19      => p_attribute19,
  p_attribute20      => p_attribute20,
  p_input_value_id1  => p_input_value_id1,
  p_input_value_id2  => p_input_value_id2,
  p_input_value_id3  => p_input_value_id3,
  p_input_value_id4  => p_input_value_id4,
  p_input_value_id5  => p_input_value_id5,
  p_input_value_id6  => p_input_value_id6,
  p_input_value_id7  => p_input_value_id7,
  p_input_value_id8  => p_input_value_id8,
  p_input_value_id9  => p_input_value_id9,
  p_input_value_id10 => p_input_value_id10,
  p_input_value_id11 => p_input_value_id11,
  p_input_value_id12 => p_input_value_id12,
  p_input_value_id13 => p_input_value_id13,
  p_input_value_id14 => p_input_value_id14,
  p_input_value_id15 => p_input_value_id15,
  p_entry_value1     => p_entry_value1,
  p_entry_value2     => p_entry_value2,
  p_entry_value3     => p_entry_value3,
  p_entry_value4     => p_entry_value4,
  p_entry_value5     => p_entry_value5,
  p_entry_value6     => p_entry_value6,
  p_entry_value7     => p_entry_value7,
  p_entry_value8     => p_entry_value8,
  p_entry_value9     => p_entry_value9,
  p_entry_value10    => p_entry_value10,
  p_entry_value11    => p_entry_value11,
  p_entry_value12    => p_entry_value12,
  p_entry_value13    => p_entry_value13,
  p_entry_value14    => p_entry_value14,
  p_entry_value15    => p_entry_value15,
  p_effective_start_Date => p_effective_start_date,
  p_effective_end_date   => p_effective_end_date,
  p_update_warning       => p_update_warning
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  ghr_history_api.post_update_process;

  -- When in validation only mode raise the Validate_Enabled exception
  --

  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_update_element_entry;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
 -- revisit this to check the correct assignment of values to the
   --  variables
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := NULL;
    p_effective_end_date     := NULL;

    hr_utility.set_location(' Leaving:'||l_proc, 12);
  When others then
    ROLLBACK TO ghr_update_element_entry;
    raise;
END update_element_entry;

--
END ghr_element_entry_api;

/
