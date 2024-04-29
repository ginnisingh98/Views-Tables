--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_ENTRY_API" AS
/* $Header: pyeleapi.pkb 120.5.12010000.5 2010/03/30 10:31:41 priupadh ship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := 'pay_element_entry_api.';
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
  ,p_creator_type                  in     varchar2 default 'F'
  ,p_cost_allocation_keyflex_id    in     number   default null
  ,p_updating_action_id            in     number   default null
  ,p_updating_action_type          in     varchar2 default null
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
  ,p_entry_information_category    in     varchar2 default null
  ,p_entry_information1            in     varchar2 default null
  ,p_entry_information2            in     varchar2 default null
  ,p_entry_information3            in     varchar2 default null
  ,p_entry_information4            in     varchar2 default null
  ,p_entry_information5            in     varchar2 default null
  ,p_entry_information6            in     varchar2 default null
  ,p_entry_information7            in     varchar2 default null
  ,p_entry_information8            in     varchar2 default null
  ,p_entry_information9            in     varchar2 default null
  ,p_entry_information10           in     varchar2 default null
  ,p_entry_information11           in     varchar2 default null
  ,p_entry_information12           in     varchar2 default null
  ,p_entry_information13           in     varchar2 default null
  ,p_entry_information14           in     varchar2 default null
  ,p_entry_information15           in     varchar2 default null
  ,p_entry_information16           in     varchar2 default null
  ,p_entry_information17           in     varchar2 default null
  ,p_entry_information18           in     varchar2 default null
  ,p_entry_information19           in     varchar2 default null
  ,p_entry_information20           in     varchar2 default null
  ,p_entry_information21           in     varchar2 default null
  ,p_entry_information22           in     varchar2 default null
  ,p_entry_information23           in     varchar2 default null
  ,p_entry_information24           in     varchar2 default null
  ,p_entry_information25           in     varchar2 default null
  ,p_entry_information26           in     varchar2 default null
  ,p_entry_information27           in     varchar2 default null
  ,p_entry_information28           in     varchar2 default null
  ,p_entry_information29           in     varchar2 default null
  ,p_entry_information30           in     varchar2 default null
  ,p_override_user_ent_chk         in     varchar2 default 'N'
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_element_entry_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_create_warning                   out nocopy boolean
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
  l_adjustment_only_flag  pay_element_types_f.adjustment_only_flag%TYPE;   -- Bug 5872519
  l_period_status         per_time_periods.status%TYPE;
  --
  -- Enhancement 2793978
  -- size of entry_value variables increased to deal with
  -- screen format of entry values that use value sets
  --
  l_entry_value1          varchar2(240);
  l_entry_value2          varchar2(240);
  l_entry_value3          varchar2(240);
  l_entry_value4          varchar2(240);
  l_entry_value5          varchar2(240);
  l_entry_value6          varchar2(240);
  l_entry_value7          varchar2(240);
  l_entry_value8          varchar2(240);
  l_entry_value9          varchar2(240);
  l_entry_value10         varchar2(240);
  l_entry_value11         varchar2(240);
  l_entry_value12         varchar2(240);
  l_entry_value13         varchar2(240);
  l_entry_value14         varchar2(240);
  l_entry_value15         varchar2(240);
  --
  l_date_on_which_time_served_ok date;
  l_date_on_which_old_enough date;
  l_dummy                 varchar2(1);
  l_create_warning        boolean;
  l_proc                  varchar2(72) := g_package||'create_element_entry';
  l_element_name          pay_element_types_f.element_name%TYPE;
  l_legislation_code      pay_element_types_f.legislation_code%TYPE;
  -- bug 659393, added variables for storing all dates pased in and truncate them
  l_effective_date        date;
  l_date_earned           pay_element_entries_f.date_earned%TYPE;
  --
  -- Bugfix 2646060
  -- l_costable_type needed to hold the costable_type of the element link
  --
  l_costable_type         pay_element_links_f.costable_type%TYPE;
  --
  -- Bugfix 3079267
  -- l_indirect_only_flag required to hold indirect_only_flag value of the
  -- element link
  --
  l_indirect_only_flag    pay_element_types_f.indirect_only_flag%TYPE;
  --
  CURSOR c_output_variables IS
     SELECT ee.object_version_number
     FROM   pay_element_entries_f ee
     WHERE  l_element_entry_id = ee.element_entry_id
  -- bug 675794, added date condition to select correct row
         and l_effective_date between ee.effective_start_date
                                  and ee.effective_end_date;
  CURSOR c_assignment_details IS
       SELECT ptp.status
       FROM   per_time_periods  ptp,
              per_assignments_f pas
       WHERE  pas.assignment_id = p_assignment_id
       AND    pas.payroll_id = ptp.payroll_id
       AND    l_effective_date BETWEEN ptp.start_date
                               AND     ptp.end_date
       AND    l_effective_date BETWEEN pas.effective_start_date
                               AND     pas.effective_end_date;
  CURSOR c_entry_exists IS
       SELECT /*+ LEADING(ee)
                  INDEX(ee pay_element_entries_f_n51) */
              'X'
       FROM   pay_element_entries_f  ee,
              pay_element_types_f    et,
              pay_element_links_f    el
       WHERE  el.element_link_id = ee.element_link_id
       AND    el.element_link_id = p_element_link_id
       AND    el.element_type_id = et.element_type_id
       AND    ee.assignment_id = p_assignment_id
       AND    l_effective_date BETWEEN ee.effective_start_date
                               AND     ee.effective_end_date
       AND    l_effective_date BETWEEN el.effective_start_date
                               AND     el.effective_end_date
       AND    l_effective_date BETWEEN et.effective_start_date
                               AND     et.effective_end_date
       AND    et.multiple_entries_allowed_flag = 'N'
       AND    ee.entry_type = 'E';

  CURSOR c_element_info IS
       SELECT et.closed_for_entry_flag,
              et.adjustment_only_flag,       -- Bug 5872519
              et.process_in_run_flag,
              et.element_name,
              et.legislation_code,
       --
       --  Bugfix 2646060
       --  Retrieve the element_link costable_type
       --
              el.costable_type,
       --
       -- Bugfix 3079267
       -- Retreive the indirect_only_flag
       --
              et.indirect_only_flag
       FROM   pay_element_types_f et,
              pay_element_links_f el
       WHERE  el.element_link_id = p_element_link_id
       /* Bug # 8628917. Validating element and link against BG ID*/
       AND    el.business_group_id = p_business_group_id
       AND    el.business_group_id = nvl(et.business_group_id, el.business_group_id)
       AND    el.element_type_id = et.element_type_id
       AND    l_effective_date BETWEEN el.effective_start_date
                               AND     el.effective_end_date
       AND    l_effective_date BETWEEN et.effective_start_date
                               AND     et.effective_end_date;
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 50);
  end if;
  -- bug 659393, added variables for storing all dates pased in and truncate them
  l_effective_date := trunc(p_effective_date);
  l_effective_start_date := l_effective_date;
  l_date_earned := trunc(p_date_earned);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT create_element_entry;
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
	-- Call Before Process User Hook
	--
	begin
	  pay_element_entry_bk1.create_element_entry_b
    (p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_original_entry_id              => p_original_entry_id
    ,p_assignment_id                  => p_assignment_id
    ,p_element_link_id                => p_element_link_id
    ,p_entry_type                     => p_entry_type
    ,p_creator_type                   => p_creator_type
    ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
    ,p_updating_action_id             => p_updating_action_id
    ,p_updating_action_type           => p_updating_action_type
    ,p_comment_id                     => p_comment_id
    ,p_reason                         => p_reason
    ,p_target_entry_id                => p_target_entry_id
    ,p_subpriority                    => p_subpriority
    ,p_date_earned                    => l_date_earned
    ,p_personal_payment_method_id     => p_personal_payment_method_id
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_input_value_id1                => p_input_value_id1
    ,p_input_value_id2                => p_input_value_id2
    ,p_input_value_id3                => p_input_value_id3
    ,p_input_value_id4                => p_input_value_id4
    ,p_input_value_id5                => p_input_value_id5
    ,p_input_value_id6                => p_input_value_id6
    ,p_input_value_id7                => p_input_value_id7
    ,p_input_value_id8                => p_input_value_id8
    ,p_input_value_id9                => p_input_value_id9
    ,p_input_value_id10               => p_input_value_id10
    ,p_input_value_id11               => p_input_value_id11
    ,p_input_value_id12               => p_input_value_id12
    ,p_input_value_id13               => p_input_value_id13
    ,p_input_value_id14               => p_input_value_id14
    ,p_input_value_id15               => p_input_value_id15
    ,p_entry_value1                   => p_entry_value1
    ,p_entry_value2                   => p_entry_value2
    ,p_entry_value3                   => p_entry_value3
    ,p_entry_value4                   => p_entry_value4
    ,p_entry_value5                   => p_entry_value5
    ,p_entry_value6                   => p_entry_value6
    ,p_entry_value7                   => p_entry_value7
    ,p_entry_value8                   => p_entry_value8
    ,p_entry_value9                   => p_entry_value9
    ,p_entry_value10                  => p_entry_value10
    ,p_entry_value11                  => p_entry_value11
    ,p_entry_value12                  => p_entry_value12
    ,p_entry_value13                  => p_entry_value13
    ,p_entry_value14                  => p_entry_value14
    ,p_entry_value15                  => p_entry_value15
    ,p_entry_information_category     => p_entry_information_category
    ,p_entry_information1             => p_entry_information1
    ,p_entry_information2             => p_entry_information2
    ,p_entry_information3             => p_entry_information3
    ,p_entry_information4             => p_entry_information4
    ,p_entry_information5             => p_entry_information5
    ,p_entry_information6             => p_entry_information6
    ,p_entry_information7             => p_entry_information7
    ,p_entry_information8             => p_entry_information8
    ,p_entry_information9             => p_entry_information9
    ,p_entry_information10            => p_entry_information10
    ,p_entry_information11            => p_entry_information11
    ,p_entry_information12            => p_entry_information12
    ,p_entry_information13            => p_entry_information13
    ,p_entry_information14            => p_entry_information14
    ,p_entry_information15            => p_entry_information15
    ,p_entry_information16            => p_entry_information16
    ,p_entry_information17            => p_entry_information17
    ,p_entry_information18            => p_entry_information18
    ,p_entry_information19            => p_entry_information19
    ,p_entry_information20            => p_entry_information20
    ,p_entry_information21            => p_entry_information21
    ,p_entry_information22            => p_entry_information22
    ,p_entry_information23            => p_entry_information23
    ,p_entry_information24            => p_entry_information24
    ,p_entry_information25            => p_entry_information25
    ,p_entry_information26            => p_entry_information26
    ,p_entry_information27            => p_entry_information27
    ,p_entry_information28            => p_entry_information28
    ,p_entry_information29            => p_entry_information29
    ,p_entry_information30            => p_entry_information30
    ,p_override_user_ent_chk          => p_override_user_ent_chk
    );
	exception
	  when hr_api.cannot_find_prog_unit then
	    hr_api.cannot_find_prog_unit_error
	      (p_module_name => 'CREATE_ELEMENT_ENTRY'
	      ,p_hook_type   => 'BP'
	      );
	end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Create all elements as type 'F' with a NULL creator
  l_creator_type := p_creator_type;
  l_creator_id   := NULL;
  --
  -- Process Logic
  -- For lookups: The API is passed the lookup_code but this form of call to
  -- the insert_element_entry requires the meaning - convert
  -- Call existing element entry code
  --
  IF p_entry_type = 'E' THEN
    if g_debug then
       hr_utility.set_location(l_proc, 70);
    end if;
    OPEN c_entry_exists;
    FETCH c_entry_exists
    INTO l_dummy;
    IF c_entry_exists%FOUND THEN
      CLOSE c_entry_exists;
       hr_utility.set_message(801,'HR_7455_PLK_ELE_ENTRY_EXISTS');
     hr_utility.raise_error;
    END IF;
    CLOSE c_entry_exists;
  END IF;
--
  OPEN c_element_info;
  FETCH c_element_info
  INTO  l_closed_for_entry_flag,
        l_adjustment_only_flag,        -- Bug 5872519
        l_process_in_run_flag,
        l_element_name,
        l_legislation_code,
  --
  -- Bugfix 2646060
  -- Fetch the element_link costable_type
  --
        l_costable_type,
  --
  -- Bugfix 3079267
  -- Fetch the indirect_only_flag
  --
        l_indirect_only_flag;
  IF c_element_info%NOTFOUND THEN
     CLOSE c_element_info;
     hr_utility.set_message(801,'HR_6132_ELE_ENTRY_LINK_MISSING');
     hr_utility.raise_error;
  END IF;
  CLOSE c_element_info;
--
  if g_debug then
     hr_utility.set_location(l_proc, 100);
  end if;
  OPEN c_assignment_details;
  FETCH c_assignment_details
  INTO  l_period_status;
  --
  -- bug 685930, commented this out as it is done by the api, and for non-recurring entries only.
  --
  /*
  IF c_assignment_details%NOTFOUND THEN
     CLOSE c_assignment_details;
     hr_utility.set_message(801,'HR_6047_ELE_ENTRY_NO_PAYROLL');
     hr_utility.raise_error;
  END IF;
  */
  CLOSE c_assignment_details;

-- Bug 5872519
-- Added check for adjustment only elements.
-- Modified for 6599070, 6603455

  IF ( l_adjustment_only_flag = 'Y' AND
      ( p_entry_type not in ('A','R','B') OR
        ( p_entry_type in ('A','R') and p_target_entry_id is null )
      )
     ) THEN

     hr_utility.set_message(801,'HR_34810_ELE_ENTRY_ADJ_ONLY');
     hr_utility.raise_error;

  END IF;

  IF l_closed_for_entry_flag = 'Y' THEN

     hr_utility.set_message(801,'HR_6064_ELE_ENTRY_CLOSED_ELE');
     hr_utility.raise_error;

-- Error will not be raised for VERTEX, Workers Compensation element with
-- Legislation code as US. Bug No 506819

  ELSIF (l_period_status = 'C' AND l_process_in_run_flag = 'Y'
         AND l_element_name not in ('US_TAX_VERTEX','VERTEX','Workers Compensation')
         AND l_legislation_code <> 'US') THEN

     hr_utility.set_message(801,'HR_6074_ELE_ENTRY_CLOSE_PERIOD');
     hr_utility.raise_error;

  --
  -- Bugfix 2646060
  -- Ensure that element_link is costable if cost_allocation_keyflex_id
  -- is not null
  --
  ELSIF l_costable_type = 'N' and p_cost_allocation_keyflex_id IS NOT NULL THEN
    --
    hr_utility.set_message(801,'HR_7453_PLK_NON_COSTABLE_ELE');
    hr_utility.set_warning;
    --
  --
  -- Bugfix 3079267
  -- Ensure we are not creating an entry for an element marked as
  -- 'Indirect Only'
  ELSIF l_indirect_only_flag = 'Y' THEN
    --
    -- Cannot directly create an entry for this element type
    -- Create a warning
    --
    hr_utility.set_message(801,'HR_33297_EE_API_IND_ONLY_ELE');
    hr_utility.set_warning;
    --
  END IF;

  hr_entry.return_qualifying_conditions (p_assignment_id,
                                         p_element_link_id,
                                         l_effective_date,
                                         l_date_on_which_time_served_ok,
                                         l_date_on_which_old_enough     );

  IF l_effective_date < l_date_on_which_time_served_ok THEN
     hr_utility.set_message(801, 'HR_ELE_ENTRY_QUAL_LOS');
     hr_utility.set_warning;
  ELSIF l_effective_date < l_date_on_which_old_enough THEN
     hr_utility.set_message(801, 'HR_ELE_ENTRY_QUAL_AGE');
     hr_utility.set_warning;
  END IF;

  IF p_input_value_id1 IS NOT NULL AND
     p_entry_value1 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 200);
     end if;
     l_entry_value1 := pay_ele_shd.convert_lookups(p_input_value_id1, p_entry_value1, p_effective_date);
  END IF;
  IF p_input_value_id2 IS NOT NULL AND
     p_entry_value2 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 210);
     end if;
     l_entry_value2 := pay_ele_shd.convert_lookups(p_input_value_id2, p_entry_value2, p_effective_date);
  END IF;
  IF p_input_value_id3 IS NOT NULL AND
     p_entry_value3 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 220);
     end if;
     l_entry_value3 := pay_ele_shd.convert_lookups(p_input_value_id3, p_entry_value3, p_effective_date);
  END IF;
  IF p_input_value_id4 IS NOT NULL AND
     p_entry_value4 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 230);
     end if;
     l_entry_value4 := pay_ele_shd.convert_lookups(p_input_value_id4, p_entry_value4, p_effective_date);
  END IF;
  IF p_input_value_id5 IS NOT NULL AND
     p_entry_value5 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 240);
     end if;
     l_entry_value5 := pay_ele_shd.convert_lookups(p_input_value_id5, p_entry_value5, p_effective_date);
  END IF;
  IF p_input_value_id6 IS NOT NULL AND
     p_entry_value6 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 250);
     end if;
     l_entry_value6 := pay_ele_shd.convert_lookups(p_input_value_id6, p_entry_value6, p_effective_date);
  END IF;
  IF p_input_value_id7 IS NOT NULL AND
     p_entry_value7 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 260);
     end if;
     l_entry_value7 := pay_ele_shd.convert_lookups(p_input_value_id7, p_entry_value7, p_effective_date);
  END IF;
  IF p_input_value_id8 IS NOT NULL AND
     p_entry_value8 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 270);
     end if;
     l_entry_value8 := pay_ele_shd.convert_lookups(p_input_value_id8, p_entry_value8, p_effective_date);
  END IF;
  IF p_input_value_id9 IS NOT NULL AND
     p_entry_value9 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 280);
     end if;
     l_entry_value9 := pay_ele_shd.convert_lookups(p_input_value_id9, p_entry_value9, p_effective_date);
  END IF;
  IF p_input_value_id10 IS NOT NULL AND
     p_entry_value10 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 290);
     end if;
     l_entry_value10 := pay_ele_shd.convert_lookups(p_input_value_id10, p_entry_value10, p_effective_date);
  END IF;
  IF p_input_value_id11 IS NOT NULL AND
     p_entry_value11 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 300);
     end if;
     l_entry_value11 := pay_ele_shd.convert_lookups(p_input_value_id11, p_entry_value11, p_effective_date);
  END IF;
  IF p_input_value_id12 IS NOT NULL AND
     p_entry_value12 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 310);
     end if;
     l_entry_value12 := pay_ele_shd.convert_lookups(p_input_value_id12, p_entry_value12, p_effective_date);
  END IF;
  IF p_input_value_id13 IS NOT NULL AND
     p_entry_value13 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 320);
     end if;
     l_entry_value13 := pay_ele_shd.convert_lookups(p_input_value_id13, p_entry_value13, p_effective_date);
  END IF;
  IF p_input_value_id14 IS NOT NULL AND
     p_entry_value14 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 330);
     end if;
     l_entry_value14 := pay_ele_shd.convert_lookups(p_input_value_id14, p_entry_value14, p_effective_date);
  END IF;
  IF p_input_value_id15 IS NOT NULL AND
     p_entry_value15 IS NOT NULL THEN
     if g_debug then
        hr_utility.set_location(l_proc, 340);
     end if;
     l_entry_value15 := pay_ele_shd.convert_lookups(p_input_value_id15, p_entry_value15, p_effective_date);
  END IF;
  --
     hr_entry_api.insert_element_entry
     (
      p_effective_start_date => l_effective_start_date,
      p_effective_end_date   => l_effective_end_date,
      p_element_entry_id     => l_element_entry_id,
      p_original_entry_id    => p_original_entry_id,
      p_assignment_id        => p_assignment_id,
      p_element_link_id      => p_element_link_id,
      p_creator_type         => l_creator_type,
      p_entry_type           => p_entry_type,
      p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
      p_updating_action_id   => p_updating_action_id,
      p_updating_action_type => p_updating_action_type,
      p_comment_id           => p_comment_id,
      p_creator_id           => l_creator_id,
      p_reason               => p_reason,
      p_target_entry_id      => p_target_entry_id,
      p_subpriority          => p_subpriority,
      p_date_earned          => l_date_earned,
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
      p_entry_value1         => l_entry_value1,
      p_entry_value2         => l_entry_value2,
      p_entry_value3         => l_entry_value3,
      p_entry_value4         => l_entry_value4,
      p_entry_value5         => l_entry_value5,
      p_entry_value6         => l_entry_value6,
      p_entry_value7         => l_entry_value7,
      p_entry_value8         => l_entry_value8,
      p_entry_value9         => l_entry_value9,
      p_entry_value10        => l_entry_value10,
      p_entry_value11        => l_entry_value11,
      p_entry_value12        => l_entry_value12,
      p_entry_value13        => l_entry_value13,
      p_entry_value14        => l_entry_value14,
      p_entry_value15        => l_entry_value15,
      p_entry_information_category => p_entry_information_category,
      p_entry_information1   => p_entry_information1,
      p_entry_information2   => p_entry_information2,
      p_entry_information3   => p_entry_information3,
      p_entry_information4   => p_entry_information4,
      p_entry_information5   => p_entry_information5,
      p_entry_information6   => p_entry_information6,
      p_entry_information7   => p_entry_information7,
      p_entry_information8   => p_entry_information8,
      p_entry_information9   => p_entry_information9,
      p_entry_information10  => p_entry_information10,
      p_entry_information11  => p_entry_information11,
      p_entry_information12  => p_entry_information12,
      p_entry_information13  => p_entry_information13,
      p_entry_information14  => p_entry_information14,
      p_entry_information15  => p_entry_information15,
      p_entry_information16  => p_entry_information16,
      p_entry_information17  => p_entry_information17,
      p_entry_information18  => p_entry_information18,
      p_entry_information19  => p_entry_information19,
      p_entry_information20  => p_entry_information20,
      p_entry_information21  => p_entry_information21,
      p_entry_information22  => p_entry_information22,
      p_entry_information23  => p_entry_information23,
      p_entry_information24  => p_entry_information24,
      p_entry_information25  => p_entry_information25,
      p_entry_information26  => p_entry_information26,
      p_entry_information27  => p_entry_information27,
      p_entry_information28  => p_entry_information28,
      p_entry_information29  => p_entry_information29,
      p_entry_information30  => p_entry_information30,
      p_override_user_ent_chk => p_override_user_ent_chk
     );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 800);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF hr_utility.check_warning THEN
    l_create_warning       := TRUE;
    hr_utility.clear_warning;
  END IF;
  --
  -- Get all output arguments
  --
  OPEN  c_output_variables;
  FETCH c_output_variables
  INTO  l_object_version_number;
  CLOSE c_output_variables;
  --
	-- Call After Process User Hook
	--
	begin
	  pay_element_entry_bk1.create_element_entry_a
    (p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_original_entry_id              => p_original_entry_id
    ,p_assignment_id                  => p_assignment_id
    ,p_element_link_id                => p_element_link_id
    ,p_entry_type                     => p_entry_type
    ,p_creator_type                   => p_creator_type
    ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
    ,p_updating_action_id             => p_updating_action_id
    ,p_updating_action_type           => p_updating_action_type
    ,p_comment_id                     => p_comment_id
    ,p_reason                         => p_reason
    ,p_target_entry_id                => p_target_entry_id
    ,p_subpriority                    => p_subpriority
    ,p_date_earned                    => l_date_earned
    ,p_personal_payment_method_id     => p_personal_payment_method_id
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_input_value_id1                => p_input_value_id1
    ,p_input_value_id2                => p_input_value_id2
    ,p_input_value_id3                => p_input_value_id3
    ,p_input_value_id4                => p_input_value_id4
    ,p_input_value_id5                => p_input_value_id5
    ,p_input_value_id6                => p_input_value_id6
    ,p_input_value_id7                => p_input_value_id7
    ,p_input_value_id8                => p_input_value_id8
    ,p_input_value_id9                => p_input_value_id9
    ,p_input_value_id10               => p_input_value_id10
    ,p_input_value_id11               => p_input_value_id11
    ,p_input_value_id12               => p_input_value_id12
    ,p_input_value_id13               => p_input_value_id13
    ,p_input_value_id14               => p_input_value_id14
    ,p_input_value_id15               => p_input_value_id15
    ,p_entry_value1                   => p_entry_value1
    ,p_entry_value2                   => p_entry_value2
    ,p_entry_value3                   => p_entry_value3
    ,p_entry_value4                   => p_entry_value4
    ,p_entry_value5                   => p_entry_value5
    ,p_entry_value6                   => p_entry_value6
    ,p_entry_value7                   => p_entry_value7
    ,p_entry_value8                   => p_entry_value8
    ,p_entry_value9                   => p_entry_value9
    ,p_entry_value10                  => p_entry_value10
    ,p_entry_value11                  => p_entry_value11
    ,p_entry_value12                  => p_entry_value12
    ,p_entry_value13                  => p_entry_value13
    ,p_entry_value14                  => p_entry_value14
    ,p_entry_value15                  => p_entry_value15
    ,p_entry_information_category     => p_entry_information_category
    ,p_entry_information1             => p_entry_information1
    ,p_entry_information2             => p_entry_information2
    ,p_entry_information3             => p_entry_information3
    ,p_entry_information4             => p_entry_information4
    ,p_entry_information5             => p_entry_information5
    ,p_entry_information6             => p_entry_information6
    ,p_entry_information7             => p_entry_information7
    ,p_entry_information8             => p_entry_information8
    ,p_entry_information9             => p_entry_information9
    ,p_entry_information10            => p_entry_information10
    ,p_entry_information11            => p_entry_information11
    ,p_entry_information12            => p_entry_information12
    ,p_entry_information13            => p_entry_information13
    ,p_entry_information14            => p_entry_information14
    ,p_entry_information15            => p_entry_information15
    ,p_entry_information16            => p_entry_information16
    ,p_entry_information17            => p_entry_information17
    ,p_entry_information18            => p_entry_information18
    ,p_entry_information19            => p_entry_information19
    ,p_entry_information20            => p_entry_information20
    ,p_entry_information21            => p_entry_information21
    ,p_entry_information22            => p_entry_information22
    ,p_entry_information23            => p_entry_information23
    ,p_entry_information24            => p_entry_information24
    ,p_entry_information25            => p_entry_information25
    ,p_entry_information26            => p_entry_information26
    ,p_entry_information27            => p_entry_information27
    ,p_entry_information28            => p_entry_information28
    ,p_entry_information29            => p_entry_information29
    ,p_entry_information30            => p_entry_information30
    ,p_override_user_ent_chk          => p_override_user_ent_chk
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
    ,p_element_entry_id               => l_element_entry_id
    ,p_object_version_number          => l_object_version_number
    ,p_create_warning                 => l_create_warning
    );
	exception
	  when hr_api.cannot_find_prog_unit then
	    hr_api.cannot_find_prog_unit_error
	      (p_module_name => 'CREATE_ELEMENT_ENTRY'
	      ,p_hook_type   => 'AP'
	      );
	end;
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_element_entry_id       := l_element_entry_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_create_warning         := l_create_warning;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
  --
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_element_entry;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_element_entry_id       := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_create_warning         := l_create_warning;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_element_entry;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_element_entry_id       := null;
    p_object_version_number  := null;
    p_create_warning         := null;
    raise;
    --
    -- End of fix.
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 900);
    end if;
END create_element_entry;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_element_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_element_entry
  (p_validate                      in            boolean  default false
  ,p_datetrack_delete_mode         in            varchar2
  ,p_effective_date                in            date
  ,p_element_entry_id              in            number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_element_entry';
  l_object_version_number pay_element_entries_f.object_version_number%TYPE;
  l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
  l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
  -- bug 659393, added variables for storing dates passed in and truncate them
  l_effective_date date;
  -- divicker Added for new lck signature
  l_validation_start_date date;
  l_validation_end_date   date;
  --
  CURSOR C_Output_Variables IS
    SELECT effective_start_date,
           effective_end_date,
           object_version_number
    FROM   pay_element_entries_f
    WHERE  p_element_entry_id = element_entry_id
           -- bug 675794, added date condition to select correct row
           and l_effective_date between effective_start_date
                                    and effective_end_date;
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  -- bug 659393, added variables for storing dates passed in and truncate them
  l_effective_date := trunc(p_effective_date);
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  IF p_validate THEN
    SAVEPOINT delete_element_entry;
  END IF;
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
	-- Call Before Process User Hook
	--
	begin
    pay_element_entry_bk3.delete_element_entry_b
    (p_datetrack_delete_mode => p_datetrack_delete_mode
    ,p_effective_date        => l_effective_date
    ,p_element_entry_id      => p_element_entry_id
    ,p_object_version_number => p_object_version_number
    );
	exception
	  when hr_api.cannot_find_prog_unit then
	    hr_api.cannot_find_prog_unit_error
	      (p_module_name => 'DELETE_ELEMENT_ENTRY'
	      ,p_hook_type   => 'BP'
	      );
	end;
  --
  -- Validation in addition to Row Handlers
  -- 1.  Ensure datetrack mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_delete_mode);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Process Logic
  -- 1.  Lock the required row
  -- 2.  Call delete element entry
  --
  pay_ele_shd.lck(p_effective_date        => l_effective_date
                 ,p_element_entry_id      => p_element_entry_id
                 ,p_object_version_number => l_object_version_number
                 ,p_datetrack_mode        => p_datetrack_delete_mode
                 ,p_validation_start_date => l_validation_start_date
                 ,p_validation_end_date   => l_validation_end_date);
  --
  hr_entry_api.delete_element_entry
    (
     p_datetrack_delete_mode,
     l_effective_date,
     p_element_entry_id
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 8);
  end if;
  --
  -- Get all output arguments
  --
  OPEN  C_Output_Variables;
  FETCH C_Output_Variables
  INTO  l_effective_start_date,
        l_effective_end_date,
        l_object_version_number;
  CLOSE C_Output_Variables;
  --
	-- Call After Process User Hook
	--
	begin
    pay_element_entry_bk3.delete_element_entry_a
    (p_datetrack_delete_mode => p_datetrack_delete_mode
    ,p_effective_date        => l_effective_date
    ,p_element_entry_id      => p_element_entry_id
    ,p_object_version_number => l_object_version_number
    ,p_effective_start_date  => l_effective_start_date
    ,p_effective_end_date    => l_effective_end_date
    ,p_delete_warning        => p_delete_warning
    );
	exception
	  when hr_api.cannot_find_prog_unit then
	    hr_api.cannot_find_prog_unit_error
	      (p_module_name => 'DELETE_ELEMENT_ENTRY'
	      ,p_hook_type   => 'AP'
	      );
	end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
--  p_delete_warning         := <local_var_set_in_process_logic>;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_element_entry;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
--    p_delete_warning         := <local_var_set_in_process_logic>;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 12);
    end if;
END delete_element_entry;


--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure is used to validate the update statement.  Certain fields are
-- allowed for update and those fields are checked here
procedure update_validate(
  p_element_entry_id               in     number
  ,p_effective_date                in     date
  ,p_creator_type                  in     varchar2  default hr_api.g_varchar2
  ,p_creator_id                    in     number    default hr_api.g_number
  ,p_personal_payment_method_id    in     number    default hr_api.g_number
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
    )
is

cursor csr_creator_type (c_element_entry_id in number,
                          c_effective_date in date) is
select   creator_type, count(element_entry_id) total_records
  from   pay_element_entries_f
 where   element_entry_id = c_element_entry_id
   and   c_effective_date between effective_start_date and effective_end_date
group by creator_type;

cursor csr_creator_type_validate (c_element_entry_id in number,
                          c_effective_date in date,
			  c_creator_type in varchar2,
			  c_creator_id in number,
			  c_personal_payment_method_id in number) is
select count(creator_type)
  from pay_element_entries_f
 where element_entry_id = c_element_entry_id
   and c_effective_date between effective_start_date and effective_end_date
   and (   (c_creator_type <> hr_api.g_varchar2
           and creator_type <> c_creator_type)
       or  (c_creator_id <> hr_api.g_number
           and ( nvl(creator_id, -1) <> nvl(c_creator_id, -1)
               )
            )
      or   (c_personal_payment_method_id <> hr_api.g_number
           and (nvl(personal_payment_method_id, -1) <> nvl(c_personal_payment_method_id, -1)
               )
           )
      );

cursor csr_entry_values_check (c_element_entry_id in number,
                          c_effective_date in date) is
select input_value_id,
       screen_entry_value
  from pay_element_entry_values_f
 where element_entry_id = c_element_entry_id
   and c_effective_date between effective_start_date and effective_end_date;

l_total_elt_entry_records    number;
l_proc                       varchar2(300);
l_creator_type               pay_element_entries_f.creator_type%type;

-- Creating types for storing input value id and entry values
type input_value_id_tbl  is table of number index by binary_integer;
type entry_value_tbl     is table of varchar2(80) index by binary_integer;

l_input_value_id_tbl input_value_id_tbl;
l_entry_value_tbl    entry_value_tbl;

l_input_id           number;
l_screen_entry_value varchar2(80);
l_count              number;

procedure conv_entry_into_table (p_input_value_id in number,
                                 p_entry_value in varchar2)
is
l_proc_name varchar2(300);
l_count     number;
begin
l_proc_name := 'conv_entry_into_table';
hr_utility.set_location('Entering '||l_proc_name, 10);

if p_input_value_id is not null then

   if l_input_value_id_tbl.last is not null then
      l_count := l_input_value_id_tbl.last;
   else
      l_count := 1;
   end if;
   hr_utility.set_location('l_count '||l_count, 15);
   l_input_value_id_tbl(l_count) := p_input_value_id;
   l_entry_value_tbl(l_count)    := p_entry_value;
end if; --
   hr_utility.set_location('Leaving '||l_proc_name, 20);
exception
when others then
   hr_utility.set_location('Error '||l_proc_name, 30);
   hr_utility.set_location(sqlerrm, 30);
end conv_entry_into_table;

begin

l_proc := 'update_validate';
hr_utility.set_location('Entering '||l_proc, 5);

hr_utility.set_location('obtain creator type ', 10);

open csr_creator_type (p_element_entry_id, p_effective_date);
fetch csr_creator_type into l_creator_type, l_total_elt_entry_records;
close csr_creator_type;

/*  Overlapping of records will be validated later
   -- Check for overlapping of element entry record
   if l_total_elt_entry_records > 1 then
      hr_utility.set_message('PAY', 'OVERLAPPING OF RECORDS IS NOT ALLOWED');
      hr_utility.raise_error;
   end if;
*/

hr_utility.set_location('After element entry unique key check  '||l_proc, 15);

if l_creator_type in ('EE', 'NR', 'R', 'RR', 'PR', 'D', 'DF', 'AD', 'AE', 'P', 'B') then

   -- Check for creator type, creator id and personal_payment_method_id
   open csr_creator_type_validate (p_element_entry_id, p_effective_date, p_creator_type, p_creator_id, p_personal_payment_method_id);
   fetch csr_creator_type_validate into l_total_elt_entry_records;
   if l_total_elt_entry_records > 0 then
      hr_utility.set_message(801, 'PAY_33292_CHANGE_PROTECTED');
      hr_utility.set_message_token('CREATOR_TYPE', hr_general.decode_lookup('CREATOR_TYPE', l_creator_type));
      hr_utility.raise_error;
   end if;
   close csr_creator_type_validate;

   hr_utility.set_location('After creator type, creator id and personal_payment_method_id check '||l_proc, 20);

   hr_utility.set_location('Adding input value and entry values in to pl/sql tables ' || l_proc, 30);

   conv_entry_into_table (p_input_value_id1, p_entry_value1);
   conv_entry_into_table (p_input_value_id2, p_entry_value2);
   conv_entry_into_table (p_input_value_id3, p_entry_value3);
   conv_entry_into_table (p_input_value_id4, p_entry_value4);
   conv_entry_into_table (p_input_value_id5, p_entry_value5);
   conv_entry_into_table (p_input_value_id6, p_entry_value6);
   conv_entry_into_table (p_input_value_id7, p_entry_value7);
   conv_entry_into_table (p_input_value_id8, p_entry_value8);
   conv_entry_into_table (p_input_value_id9, p_entry_value9);
   conv_entry_into_table (p_input_value_id10, p_entry_value10);
   conv_entry_into_table (p_input_value_id11, p_entry_value11);
   conv_entry_into_table (p_input_value_id12, p_entry_value12);
   conv_entry_into_table (p_input_value_id13, p_entry_value13);
   conv_entry_into_table (p_input_value_id14, p_entry_value14);
   conv_entry_into_table (p_input_value_id15, p_entry_value15);

   hr_utility.set_location('Element Entry check '||l_proc, 35);

   open csr_entry_values_check (p_element_entry_id , p_effective_date );
   loop
      fetch csr_entry_values_check into l_input_id, l_screen_entry_value;
      exit when csr_entry_values_check%notfound;

      l_count := 1;

      while l_count <= l_input_value_id_tbl.last
      loop
         if l_input_value_id_tbl(l_count) = l_input_id then
 	        if l_entry_value_tbl(l_count) <> l_screen_entry_value then
               hr_utility.set_location('Raise Error '||l_proc, 40);

               hr_utility.set_message(801, 'PAY_33292_CHANGE_PROTECTED');
               hr_utility.set_message_token('CREATOR_TYPE', hr_general.decode_lookup('CREATOR_TYPE', l_creator_type));
               hr_utility.raise_error;

            end if; -- screen entry value is not equal
	     end if; -- input value is equal
	  l_count := l_count + 1;
      end loop; -- input value loop
   end loop; --element entry value cursor

end if; --Creator type check
hr_utility.set_location('Leaving '||l_proc, 45);

exception
when others then
   hr_utility.set_location('Error '||l_proc, 50);
   hr_utility.set_location(sqlerrm, 50);
   raise;
end update_validate;



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
  ,p_object_version_number         in out nocopy number
  ,p_cost_allocation_keyflex_id    in     number    default hr_api.g_number
  ,p_updating_action_id            in     number    default hr_api.g_number
  ,p_updating_action_type          in     varchar2  default hr_api.g_varchar2
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
  ,p_entry_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_entry_information1            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information2            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information3            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information4            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information5            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information6            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information7            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information8            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information9            in     varchar2  default hr_api.g_varchar2
  ,p_entry_information10           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information11           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information12           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information13           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information14           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information15           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information16           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information17           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information18           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information19           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information20           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information21           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information22           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information23           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information24           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information25           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information26           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information27           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information28           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information29           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information30           in     varchar2  default hr_api.g_varchar2
  ,p_override_user_ent_chk         in     varchar2 default 'N'
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_update_warning                   out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_element_entry';
  l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
  l_object_version_number pay_element_entries_f.object_version_number%TYPE;
  l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
  l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
  --
  -- Enhancement 2793978
  -- size of entry_value variables increased to deal with
  -- screen format of entry values that use value sets
  --
  l_entry_value1          varchar2(240);
  l_entry_value2          varchar2(240);
  l_entry_value3          varchar2(240);
  l_entry_value4          varchar2(240);
  l_entry_value5          varchar2(240);
  l_entry_value6          varchar2(240);
  l_entry_value7          varchar2(240);
  l_entry_value8          varchar2(240);
  l_entry_value9          varchar2(240);
  l_entry_value10         varchar2(240);
  l_entry_value11         varchar2(240);
  l_entry_value12         varchar2(240);
  l_entry_value13         varchar2(240);
  l_entry_value14         varchar2(240);
  l_entry_value15         varchar2(240);
  --
  l_creator_type          pay_element_entries_f.creator_type%TYPE;
  l_creator_id            pay_element_entries_f.creator_id%TYPE;
  -- bug 659393, added variables for storing dates passed in and truncate them
  l_effective_date        date;
  l_date_earned           pay_element_entries_f.date_earned%TYPE;
  -- divicker Added for new lck signature
  l_validation_start_date date;
  l_validation_end_date   date;
  --
  -- Bugfix 2646060
  -- l_costable_type needed to hold the costable_type of the element link
  --
  l_costable_type         pay_element_links_f.costable_type%TYPE;
  --
  -- Bugfix 9456999
  l_check_for_update varchar2(1);

  CURSOR c_output_variables IS
     SELECT ee.effective_start_date,
            ee.effective_end_date,
            ee.object_version_number
     FROM   pay_element_entries_f ee
     WHERE  p_element_entry_id = ee.element_entry_id
  -- bug 675794, added date condition to select correct row
         and l_effective_date between ee.effective_start_date
                                  and ee.effective_end_date;
  CURSOR c_entry_details IS
     SELECT ee.creator_type
     FROM   pay_element_entries_f ee
     WHERE  p_element_entry_id = ee.element_entry_id;
  --
  -- Bugfix 2646060
  -- c_link_details required to retrieve the costable_type of the
  -- element_link for the element_entry being updated
  --
  CURSOR c_link_details ( p_element_entry_id NUMBER
                        , p_effective_date DATE ) IS
     SELECT el.costable_type
     FROM   pay_element_entries_f ee
          , pay_element_links_f el
     WHERE  ee.element_entry_id = p_element_entry_id
     AND    ee.element_link_id = el.element_link_id
     AND    p_effective_date BETWEEN ee.effective_start_date
                             AND ee.effective_end_date
     AND    p_effective_date BETWEEN el.effective_start_date
                             AND el.effective_end_date;
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  l_element_entry_id      := p_element_entry_id;
  -- bug 659393, added variables for storing dates passed in and truncate them
  l_effective_date := trunc(p_effective_date);
  l_date_earned := trunc(p_date_earned);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT update_element_entry;
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
	-- Call Before Process User Hook
	--
	begin
    pay_element_entry_bk2.update_element_entry_b
    (p_datetrack_update_mode          => p_datetrack_update_mode
    ,p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_element_entry_id               => p_element_entry_id
    ,p_object_version_number          => p_object_version_number
    ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
    ,p_updating_action_id             => p_updating_action_id
    ,p_updating_action_type           => p_updating_action_type
    ,p_original_entry_id              => p_original_entry_id
    ,p_creator_type                   => p_creator_type
    ,p_comment_id                     => p_comment_id
    ,p_creator_id                     => p_creator_id
    ,p_reason                         => p_reason
    ,p_subpriority                    => p_subpriority
    ,p_date_earned                    => l_date_earned
    ,p_personal_payment_method_id     => p_personal_payment_method_id
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_input_value_id1                => p_input_value_id1
    ,p_input_value_id2                => p_input_value_id2
    ,p_input_value_id3                => p_input_value_id3
    ,p_input_value_id4                => p_input_value_id4
    ,p_input_value_id5                => p_input_value_id5
    ,p_input_value_id6                => p_input_value_id6
    ,p_input_value_id7                => p_input_value_id7
    ,p_input_value_id8                => p_input_value_id8
    ,p_input_value_id9                => p_input_value_id9
    ,p_input_value_id10               => p_input_value_id10
    ,p_input_value_id11               => p_input_value_id11
    ,p_input_value_id12               => p_input_value_id12
    ,p_input_value_id13               => p_input_value_id13
    ,p_input_value_id14               => p_input_value_id14
    ,p_input_value_id15               => p_input_value_id15
    ,p_entry_value1                   => p_entry_value1
    ,p_entry_value2                   => p_entry_value2
    ,p_entry_value3                   => p_entry_value3
    ,p_entry_value4                   => p_entry_value4
    ,p_entry_value5                   => p_entry_value5
    ,p_entry_value6                   => p_entry_value6
    ,p_entry_value7                   => p_entry_value7
    ,p_entry_value8                   => p_entry_value8
    ,p_entry_value9                   => p_entry_value9
    ,p_entry_value10                  => p_entry_value10
    ,p_entry_value11                  => p_entry_value11
    ,p_entry_value12                  => p_entry_value12
    ,p_entry_value13                  => p_entry_value13
    ,p_entry_value14                  => p_entry_value14
    ,p_entry_value15                  => p_entry_value15
    ,p_entry_information_category     => p_entry_information_category
    ,p_entry_information1             => p_entry_information1
    ,p_entry_information2             => p_entry_information2
    ,p_entry_information3             => p_entry_information3
    ,p_entry_information4             => p_entry_information4
    ,p_entry_information5             => p_entry_information5
    ,p_entry_information6             => p_entry_information6
    ,p_entry_information7             => p_entry_information7
    ,p_entry_information8             => p_entry_information8
    ,p_entry_information9             => p_entry_information9
    ,p_entry_information10            => p_entry_information10
    ,p_entry_information11            => p_entry_information11
    ,p_entry_information12            => p_entry_information12
    ,p_entry_information13            => p_entry_information13
    ,p_entry_information14            => p_entry_information14
    ,p_entry_information15            => p_entry_information15
    ,p_entry_information16            => p_entry_information16
    ,p_entry_information17            => p_entry_information17
    ,p_entry_information18            => p_entry_information18
    ,p_entry_information19            => p_entry_information19
    ,p_entry_information20            => p_entry_information20
    ,p_entry_information21            => p_entry_information21
    ,p_entry_information22            => p_entry_information22
    ,p_entry_information23            => p_entry_information23
    ,p_entry_information24            => p_entry_information24
    ,p_entry_information25            => p_entry_information25
    ,p_entry_information26            => p_entry_information26
    ,p_entry_information27            => p_entry_information27
    ,p_entry_information28            => p_entry_information28
    ,p_entry_information29            => p_entry_information29
    ,p_entry_information30            => p_entry_information30
    ,p_override_user_ent_chk          => p_override_user_ent_chk
    );
	exception
	  when hr_api.cannot_find_prog_unit then
	    hr_api.cannot_find_prog_unit_error
	      (p_module_name => 'UPDATE_ELEMENT_ENTRY'
	      ,p_hook_type   => 'BP'
	      );
	end;
  --
  -- Validation in addition to Row Handlers
  -- 1. Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_update_mode);
  --
  -- Bugfix 2646060
  -- Fetch the element_link costable_type and ensure that the
  -- element_link is costable if cost_allocation_keyflex_id is not null
  --
  OPEN c_link_details(l_element_entry_id, l_effective_date);
  FETCH c_link_details INTO l_costable_type;
  CLOSE c_link_details;
  --
  IF l_costable_type = 'N'
    AND p_cost_allocation_keyflex_id IS NOT NULL
    AND p_cost_allocation_keyflex_id <> hr_api.g_number THEN
    --
    hr_utility.set_message(801,'HR_7453_PLK_NON_COSTABLE_ELE');
    hr_utility.set_warning;
    --
  END IF;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Process Logic
  -- 1.  If updating entries created by MIX - creator_type = 'H' - the creator
  --     id must be updated to NULL to stop MIX Rollbacks occurring.
  -- 1.  Lock the required row
  -- 2.  Call update element entry
  --
  OPEN  c_entry_details;
  FETCH c_entry_details
  INTO  l_creator_type;
  CLOSE c_entry_details;

  IF l_creator_type = 'H' THEN
     l_creator_type := 'F';
     IF p_creator_id = hr_api.g_number THEN
        l_creator_id := NULL;
     END IF;
  END IF;

  IF p_input_value_id1 IS NOT NULL AND
     p_entry_value1 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(p_input_value_id1, p_entry_value1, p_effective_date);
  END IF;
  IF p_input_value_id2 IS NOT NULL AND
     p_entry_value2 IS NOT NULL THEN
     l_entry_value2 := pay_ele_shd.convert_lookups(p_input_value_id2, p_entry_value2, p_effective_date);
  END IF;
  IF p_input_value_id3 IS NOT NULL AND
     p_entry_value3 IS NOT NULL THEN
     l_entry_value3 := pay_ele_shd.convert_lookups(p_input_value_id3, p_entry_value3, p_effective_date);
  END IF;
  IF p_input_value_id4 IS NOT NULL AND
     p_entry_value4 IS NOT NULL THEN
     l_entry_value4 := pay_ele_shd.convert_lookups(p_input_value_id4, p_entry_value4, p_effective_date);
  END IF;
  IF p_input_value_id5 IS NOT NULL AND
     p_entry_value5 IS NOT NULL THEN
     l_entry_value5 := pay_ele_shd.convert_lookups(p_input_value_id5, p_entry_value5, p_effective_date);
  END IF;
  IF p_input_value_id6 IS NOT NULL AND
     p_entry_value6 IS NOT NULL THEN
     l_entry_value6 := pay_ele_shd.convert_lookups(p_input_value_id6, p_entry_value6, p_effective_date);
  END IF;
  IF p_input_value_id7 IS NOT NULL AND
     p_entry_value7 IS NOT NULL THEN
     l_entry_value7 := pay_ele_shd.convert_lookups(p_input_value_id7, p_entry_value7, p_effective_date);
  END IF;
  IF p_input_value_id8 IS NOT NULL AND
     p_entry_value8 IS NOT NULL THEN
     l_entry_value8 := pay_ele_shd.convert_lookups(p_input_value_id8, p_entry_value8, p_effective_date);
  END IF;
  IF p_input_value_id9 IS NOT NULL AND
     p_entry_value9 IS NOT NULL THEN
     l_entry_value9 := pay_ele_shd.convert_lookups(p_input_value_id9, p_entry_value9, p_effective_date);
  END IF;
  IF p_input_value_id10 IS NOT NULL AND
     p_entry_value10 IS NOT NULL THEN
     l_entry_value10 := pay_ele_shd.convert_lookups(p_input_value_id10, p_entry_value10, p_effective_date);
  END IF;
  IF p_input_value_id11 IS NOT NULL AND
     p_entry_value11 IS NOT NULL THEN
     l_entry_value11 := pay_ele_shd.convert_lookups(p_input_value_id11, p_entry_value11, p_effective_date);
  END IF;
  IF p_input_value_id12 IS NOT NULL AND
     p_entry_value12 IS NOT NULL THEN
     l_entry_value12 := pay_ele_shd.convert_lookups(p_input_value_id12, p_entry_value12, p_effective_date);
  END IF;
  IF p_input_value_id13 IS NOT NULL AND
     p_entry_value13 IS NOT NULL THEN
     l_entry_value13 := pay_ele_shd.convert_lookups(p_input_value_id13, p_entry_value13, p_effective_date);
  END IF;
  IF p_input_value_id14 IS NOT NULL AND
     p_entry_value14 IS NOT NULL THEN
     l_entry_value14 := pay_ele_shd.convert_lookups(p_input_value_id14, p_entry_value14, p_effective_date);
  END IF;
  IF p_input_value_id15 IS NOT NULL AND
     p_entry_value15 IS NOT NULL THEN
     l_entry_value15 := pay_ele_shd.convert_lookups(p_input_value_id15, p_entry_value15, p_effective_date);
  END IF;
  --

  update_validate(p_element_entry_id    => p_element_entry_id
    ,p_effective_date                 => l_effective_date
    ,p_creator_type                   => p_creator_type
    ,p_creator_id                     => p_creator_id
    ,p_personal_payment_method_id     => p_personal_payment_method_id
    ,p_input_value_id1                => p_input_value_id1
    ,p_input_value_id2                => p_input_value_id2
    ,p_input_value_id3                => p_input_value_id3
    ,p_input_value_id4                => p_input_value_id4
    ,p_input_value_id5                => p_input_value_id5
    ,p_input_value_id6                => p_input_value_id6
    ,p_input_value_id7                => p_input_value_id7
    ,p_input_value_id8                => p_input_value_id8
    ,p_input_value_id9                => p_input_value_id9
    ,p_input_value_id10               => p_input_value_id10
    ,p_input_value_id11               => p_input_value_id11
    ,p_input_value_id12               => p_input_value_id12
    ,p_input_value_id13               => p_input_value_id13
    ,p_input_value_id14               => p_input_value_id14
    ,p_input_value_id15               => p_input_value_id15
    ,p_entry_value1                   => p_entry_value1
    ,p_entry_value2                   => p_entry_value2
    ,p_entry_value3                   => p_entry_value3
    ,p_entry_value4                   => p_entry_value4
    ,p_entry_value5                   => p_entry_value5
    ,p_entry_value6                   => p_entry_value6
    ,p_entry_value7                   => p_entry_value7
    ,p_entry_value8                   => p_entry_value8
    ,p_entry_value9                   => p_entry_value9
    ,p_entry_value10                  => p_entry_value10
    ,p_entry_value11                  => p_entry_value11
    ,p_entry_value12                  => p_entry_value12
    ,p_entry_value13                  => p_entry_value13
    ,p_entry_value14                  => p_entry_value14
    ,p_entry_value15                  => p_entry_value15
    );


  --
  pay_ele_shd.lck(p_effective_date        => l_effective_date
                 ,p_element_entry_id      => l_element_entry_id
                 ,p_object_version_number => l_object_version_number
                 ,p_datetrack_mode        => p_datetrack_update_mode
                 ,p_validation_start_date => l_validation_start_date
                 ,p_validation_end_date   => l_validation_end_date);
  --
  -- Bugfix 9456999
  l_check_for_update := fnd_profile.value('PAY_CHECK_UPD_ELE_ENTRY_API');
  if l_check_for_update is null then
     l_check_for_update := 'Y';
  end if;

  hr_entry_api.update_element_entry
  (
  p_dt_update_mode   => p_datetrack_update_mode,
  p_session_date     => l_effective_date,
  p_check_for_update => l_check_for_update,                   -- Bug 9456999
  p_element_entry_id => l_element_entry_id,
  p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
  p_updating_action_id => p_updating_action_id,
  p_updating_action_type => p_updating_action_type,
  p_original_entry_id  => p_original_entry_id,
  p_creator_type => p_creator_type,
  p_comment_id   => p_comment_id,
  p_creator_id   => p_creator_id,
  p_reason => p_reason,
  p_subpriority => p_subpriority,
  p_date_earned => l_date_earned,
  p_personal_payment_method_id => p_personal_payment_method_id,
  p_attribute_category => p_attribute_category,
  p_attribute1       => p_attribute1,
  p_attribute2       => p_attribute2,
  p_attribute3       => p_attribute3,
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
  p_entry_value1     => l_entry_value1,
  p_entry_value2     => l_entry_value2,
  p_entry_value3     => l_entry_value3,
  p_entry_value4     => l_entry_value4,
  p_entry_value5     => l_entry_value5,
  p_entry_value6     => l_entry_value6,
  p_entry_value7     => l_entry_value7,
  p_entry_value8     => l_entry_value8,
  p_entry_value9     => l_entry_value9,
  p_entry_value10    => l_entry_value10,
  p_entry_value11    => l_entry_value11,
  p_entry_value12    => l_entry_value12,
  p_entry_value13    => l_entry_value13,
  p_entry_value14    => l_entry_value14,
  p_entry_value15    => l_entry_value15,
  p_entry_information_category => p_entry_information_category,
  p_entry_information1 => p_entry_information1,
  p_entry_information2 => p_entry_information2,
  p_entry_information3 => p_entry_information3,
  p_entry_information4 => p_entry_information4,
  p_entry_information5 => p_entry_information5,
  p_entry_information6 => p_entry_information6,
  p_entry_information7 => p_entry_information7,
  p_entry_information8 => p_entry_information8,
  p_entry_information9 => p_entry_information9,
  p_entry_information10 => p_entry_information10,
  p_entry_information11 => p_entry_information11,
  p_entry_information12 => p_entry_information12,
  p_entry_information13 => p_entry_information13,
  p_entry_information14 => p_entry_information14,
  p_entry_information15 => p_entry_information15,
  p_entry_information16 => p_entry_information16,
  p_entry_information17 => p_entry_information17,
  p_entry_information18 => p_entry_information18,
  p_entry_information19 => p_entry_information19,
  p_entry_information20 => p_entry_information20,
  p_entry_information21 => p_entry_information21,
  p_entry_information22 => p_entry_information22,
  p_entry_information23 => p_entry_information23,
  p_entry_information24 => p_entry_information24,
  p_entry_information25 => p_entry_information25,
  p_entry_information26 => p_entry_information26,
  p_entry_information27 => p_entry_information27,
  p_entry_information28 => p_entry_information28,
  p_entry_information29 => p_entry_information29,
  p_entry_information30 => p_entry_information30,
  p_override_user_ent_chk => p_override_user_ent_chk
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 8);
  end if;
  --
  -- Get all output arguments
  --
  if g_debug then
     hr_utility.set_location(l_proc, 9);
  end if;
  --
  OPEN  C_Output_Variables;
  FETCH C_Output_Variables
  INTO  l_effective_start_date,
        l_effective_end_date,
        l_object_version_number;
  CLOSE C_Output_Variables;
  --
	-- Call After Process User Hook
	--
	begin
    pay_element_entry_bk2.update_element_entry_a
    (p_datetrack_update_mode          => p_datetrack_update_mode
    ,p_effective_date                 => l_effective_date
    ,p_business_group_id              => p_business_group_id
    ,p_element_entry_id               => p_element_entry_id
    ,p_object_version_number          => l_object_version_number
    ,p_cost_allocation_keyflex_id     => p_cost_allocation_keyflex_id
    ,p_updating_action_id             => p_updating_action_id
    ,p_updating_action_type           => p_updating_action_type
    ,p_original_entry_id              => p_original_entry_id
    ,p_creator_type                   => p_creator_type
    ,p_comment_id                     => p_comment_id
    ,p_creator_id                     => p_creator_id
    ,p_reason                         => p_reason
    ,p_subpriority                    => p_subpriority
    ,p_date_earned                    => l_date_earned
    ,p_personal_payment_method_id     => p_personal_payment_method_id
    ,p_attribute_category             => p_attribute_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_input_value_id1                => p_input_value_id1
    ,p_input_value_id2                => p_input_value_id2
    ,p_input_value_id3                => p_input_value_id3
    ,p_input_value_id4                => p_input_value_id4
    ,p_input_value_id5                => p_input_value_id5
    ,p_input_value_id6                => p_input_value_id6
    ,p_input_value_id7                => p_input_value_id7
    ,p_input_value_id8                => p_input_value_id8
    ,p_input_value_id9                => p_input_value_id9
    ,p_input_value_id10               => p_input_value_id10
    ,p_input_value_id11               => p_input_value_id11
    ,p_input_value_id12               => p_input_value_id12
    ,p_input_value_id13               => p_input_value_id13
    ,p_input_value_id14               => p_input_value_id14
    ,p_input_value_id15               => p_input_value_id15
    ,p_entry_value1                   => p_entry_value1
    ,p_entry_value2                   => p_entry_value2
    ,p_entry_value3                   => p_entry_value3
    ,p_entry_value4                   => p_entry_value4
    ,p_entry_value5                   => p_entry_value5
    ,p_entry_value6                   => p_entry_value6
    ,p_entry_value7                   => p_entry_value7
    ,p_entry_value8                   => p_entry_value8
    ,p_entry_value9                   => p_entry_value9
    ,p_entry_value10                  => p_entry_value10
    ,p_entry_value11                  => p_entry_value11
    ,p_entry_value12                  => p_entry_value12
    ,p_entry_value13                  => p_entry_value13
    ,p_entry_value14                  => p_entry_value14
    ,p_entry_value15                  => p_entry_value15
    ,p_entry_information_category     => p_entry_information_category
    ,p_entry_information1             => p_entry_information1
    ,p_entry_information2             => p_entry_information2
    ,p_entry_information3             => p_entry_information3
    ,p_entry_information4             => p_entry_information4
    ,p_entry_information5             => p_entry_information5
    ,p_entry_information6             => p_entry_information6
    ,p_entry_information7             => p_entry_information7
    ,p_entry_information8             => p_entry_information8
    ,p_entry_information9             => p_entry_information9
    ,p_entry_information10            => p_entry_information10
    ,p_entry_information11            => p_entry_information11
    ,p_entry_information12            => p_entry_information12
    ,p_entry_information13            => p_entry_information13
    ,p_entry_information14            => p_entry_information14
    ,p_entry_information15            => p_entry_information15
    ,p_entry_information16            => p_entry_information16
    ,p_entry_information17            => p_entry_information17
    ,p_entry_information18            => p_entry_information18
    ,p_entry_information19            => p_entry_information19
    ,p_entry_information20            => p_entry_information20
    ,p_entry_information21            => p_entry_information21
    ,p_entry_information22            => p_entry_information22
    ,p_entry_information23            => p_entry_information23
    ,p_entry_information24            => p_entry_information24
    ,p_entry_information25            => p_entry_information25
    ,p_entry_information26            => p_entry_information26
    ,p_entry_information27            => p_entry_information27
    ,p_entry_information28            => p_entry_information28
    ,p_entry_information29            => p_entry_information29
    ,p_entry_information30            => p_entry_information30
    ,p_override_user_ent_chk          => p_override_user_ent_chk
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
    ,p_update_warning                 => p_update_warning
    );
	exception
	  when hr_api.cannot_find_prog_unit then
	    hr_api.cannot_find_prog_unit_error
	      (p_module_name => 'UPDATE_ELEMENT_ENTRY'
	      ,p_hook_type   => 'AP'
	      );
	end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
--  p_element_entry_id       := l_element_entry_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
--  p_update_warning         := <local_var_set_in_process_logic>;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_element_entry;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_element_entry_id       := NULL;
    p_object_version_number  := l_object_version_number;
--    p_update_warning         := <local_var_set_in_process_logic>;
    p_effective_start_date   := NULL;
    p_effective_end_date     := NULL;
    --
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO update_element_entry;
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_update_warning         := null;
    raise;
    --
    -- End of fix.
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 12);
    end if;
END update_element_entry;
--
END pay_element_entry_api;

/
