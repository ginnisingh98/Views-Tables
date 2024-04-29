--------------------------------------------------------
--  DDL for Package Body PQP_AAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAT_API" as
/* $Header: pqaatapi.pkb 120.3.12010000.1 2008/07/28 11:06:57 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_aat_api.';

--
-- ---------------------------------------------------------------------------+
-- |---------------------< <create_assignment_attribute> >--------------------|
-- ---------------------------------------------------------------------------+
--
procedure create_assignment_attribute
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_assignment_id                 in     number
  ,p_contract_type                 in     varchar2	default null
  ,p_work_pattern                  in     varchar2	default null
  ,p_start_day                     in     varchar2	default null
  ,p_primary_company_car            in     number	default null
  ,p_primary_car_fuel_benefit       in     varchar2	default null
  ,p_primary_capital_contribution   in     number	default null
  ,p_primary_class_1a               in     varchar2	default null
  ,p_secondary_company_car          in     number	default null
  ,p_secondary_car_fuel_benefit     in     varchar2	default null
  ,p_secondary_capital_contributi   in     number	default null
  ,p_secondary_class_1a             in     varchar2	default null
  ,p_company_car_calc_method        in     varchar2	default null
  ,p_company_car_rates_table_id     in     number	default null
  ,p_company_car_secondary_table    in     number	default null
  ,p_private_car                    in     number	default null
  ,p_private_car_calc_method        in     varchar2	default null
  ,p_private_car_rates_table_id     in     number	default null
  ,p_private_car_essential_table    in     number	default null
  ,p_primary_private_contribution   in number		default null
  ,p_secondary_private_contributi   in number		default null
  ,p_tp_is_teacher                  in varchar2		default null
  --added for head Teacher seconded location for salary scale calculation
  ,p_tp_headteacher_grp_code        in number 		default null
  ,p_tp_safeguarded_grade           in varchar2		default null
  ,p_tp_safeguarded_grade_id        in number		default null
  ,p_tp_safeguarded_rate_type       in varchar2		default null
  ,p_tp_safeguarded_rate_id         in number		default null
  ,p_tp_spinal_point_id             in number		default null
  ,p_tp_elected_pension             in varchar2		default null
  ,p_tp_fast_track                  in varchar2		default null
  ,p_aat_attribute_category     in varchar2		default null
  ,p_aat_attribute1             in varchar2		default null
  ,p_aat_attribute2             in varchar2		default null
  ,p_aat_attribute3             in varchar2		default null
  ,p_aat_attribute4             in varchar2		default null
  ,p_aat_attribute5             in varchar2		default null
  ,p_aat_attribute6             in varchar2		default null
  ,p_aat_attribute7             in varchar2		default null
  ,p_aat_attribute8             in varchar2		default null
  ,p_aat_attribute9             in varchar2		default null
  ,p_aat_attribute10            in varchar2		default null
  ,p_aat_attribute11            in varchar2		default null
  ,p_aat_attribute12            in varchar2		default null
  ,p_aat_attribute13            in varchar2		default null
  ,p_aat_attribute14            in varchar2		default null
  ,p_aat_attribute15            in varchar2		default null
  ,p_aat_attribute16            in varchar2		default null
  ,p_aat_attribute17            in varchar2		default null
  ,p_aat_attribute18            in varchar2		default null
  ,p_aat_attribute19            in varchar2		default null
  ,p_aat_attribute20            in varchar2		default null
  ,p_aat_information_category   in varchar2		default null
  ,p_aat_information1           in varchar2		default null
  ,p_aat_information2           in varchar2		default null
  ,p_aat_information3           in varchar2		default null
  ,p_aat_information4           in varchar2		default null
  ,p_aat_information5           in varchar2		default null
  ,p_aat_information6           in varchar2		default null
  ,p_aat_information7           in varchar2		default null
  ,p_aat_information8           in varchar2		default null
  ,p_aat_information9           in varchar2		default null
  ,p_aat_information10          in varchar2		default null
  ,p_aat_information11          in varchar2		default null
  ,p_aat_information12          in varchar2		default null
  ,p_aat_information13          in varchar2		default null
  ,p_aat_information14          in varchar2		default null
  ,p_aat_information15          in varchar2		default null
  ,p_aat_information16          in varchar2		default null
  ,p_aat_information17          in varchar2		default null
  ,p_aat_information18          in varchar2		default null
  ,p_aat_information19          in varchar2		default null
  ,p_aat_information20          in varchar2		default null
  ,p_lgps_process_flag          in varchar2           default null
  ,p_lgps_exclusion_type        in varchar2           default null
  ,p_lgps_pensionable_pay       in varchar2           default null
  ,p_lgps_trans_arrang_flag     in varchar2           default null
  ,p_lgps_membership_number     in varchar2           default null
  ,p_assignment_attribute_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declaring cursors and local variables

  l_assignment_attribute_id     number;
  l_object_version_number       number;
  l_proc                varchar2(72) := g_package||'create_assignment_attribute';
  l_effective_date              date;
  l_effective_start_date        date;
  l_effective_end_date          date;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_assignment_attribute;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date           := trunc(p_effective_date);
     l_effective_start_date     := trunc(p_effective_start_date);
     l_effective_end_date       := trunc(p_effective_end_date);


  --
  -- Call Before Process User Hook
  --
  begin
    pqp_aat_api_bk1.create_assignment_attribute_b
      (p_effective_date             => l_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_assignment_id              => p_assignment_id
      ,p_contract_type              => p_contract_type
      ,p_work_pattern               => p_work_pattern
      ,p_start_day                  => p_start_day
      ,p_primary_company_car        => p_primary_company_car
      ,p_primary_car_fuel_benefit   => p_primary_car_fuel_benefit
      ,p_primary_capital_contribution => p_primary_capital_contribution
      ,p_primary_class_1a           => p_primary_class_1a
      ,p_secondary_company_car      => p_secondary_company_car
      ,p_secondary_car_fuel_benefit => p_secondary_car_fuel_benefit
      ,p_secondary_capital_contributi => p_secondary_capital_contributi
      ,p_secondary_class_1a         => p_secondary_class_1a
      ,p_company_car_calc_method    => p_company_car_calc_method
      ,p_company_car_rates_table_id  => p_company_car_rates_table_id
      ,p_company_car_secondary_table => p_company_car_secondary_table
      ,p_private_car                => p_private_car
      ,p_private_car_calc_method    => p_private_car_calc_method
      ,p_private_car_rates_table_id    => p_private_car_rates_table_id
      ,p_private_car_essential_table => p_private_car_essential_table
      ,p_primary_private_contribution   => p_primary_private_contribution
      ,p_secondary_private_contributi   => p_secondary_private_contributi
      ,p_tp_is_teacher                  => p_tp_is_teacher
       --added for head Teacher seconded location for salary scale calculation
      ,p_tp_headteacher_grp_code     => p_tp_headteacher_grp_code
      ,p_tp_safeguarded_grade           => p_tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type       => p_tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id         => p_tp_safeguarded_rate_id
      ,p_tp_spinal_point_id             => p_tp_spinal_point_id
      ,p_tp_elected_pension             => p_tp_elected_pension
      ,p_tp_fast_track                  => p_tp_fast_track
      ,p_aat_attribute_category         => p_aat_attribute_category
      ,p_aat_attribute1                 => p_aat_attribute1
      ,p_aat_attribute2                 => p_aat_attribute2
      ,p_aat_attribute3                 => p_aat_attribute3
      ,p_aat_attribute4                 => p_aat_attribute4
      ,p_aat_attribute5                 => p_aat_attribute5
      ,p_aat_attribute6                 => p_aat_attribute6
      ,p_aat_attribute7                 => p_aat_attribute7
      ,p_aat_attribute8                 => p_aat_attribute8
      ,p_aat_attribute9                 => p_aat_attribute9
      ,p_aat_attribute10                => p_aat_attribute10
      ,p_aat_attribute11                => p_aat_attribute11
      ,p_aat_attribute12                => p_aat_attribute12
      ,p_aat_attribute13                => p_aat_attribute13
      ,p_aat_attribute14                => p_aat_attribute14
      ,p_aat_attribute15                => p_aat_attribute15
      ,p_aat_attribute16                => p_aat_attribute16
      ,p_aat_attribute17                => p_aat_attribute17
      ,p_aat_attribute18                => p_aat_attribute18
      ,p_aat_attribute19                => p_aat_attribute19
      ,p_aat_attribute20                => p_aat_attribute20
      ,p_aat_information_category       => p_aat_information_category
      ,p_aat_information1               => p_aat_information1
      ,p_aat_information2               => p_aat_information2
      ,p_aat_information3               => p_aat_information3
      ,p_aat_information4               => p_aat_information4
      ,p_aat_information5               => p_aat_information5
      ,p_aat_information6               => p_aat_information6
      ,p_aat_information7               => p_aat_information7
      ,p_aat_information8               => p_aat_information8
      ,p_aat_information9               => p_aat_information9
      ,p_aat_information10              => p_aat_information10
      ,p_aat_information11              => p_aat_information11
      ,p_aat_information12              => p_aat_information12
      ,p_aat_information13              => p_aat_information13
      ,p_aat_information14              => p_aat_information14
      ,p_aat_information15              => p_aat_information15
      ,p_aat_information16              => p_aat_information16
      ,p_aat_information17              => p_aat_information17
      ,p_aat_information18              => p_aat_information18
      ,p_aat_information19              => p_aat_information19
      ,p_aat_information20              => p_aat_information20
      ,p_lgps_process_flag              => p_lgps_process_flag
      ,p_lgps_exclusion_type            => p_lgps_exclusion_type
      ,p_lgps_pensionable_pay           => p_lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag         => p_lgps_trans_arrang_flag
      ,p_lgps_membership_number         => p_lgps_membership_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_assignment_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic, calling Row Handler for insert

     pqp_aat_ins.ins
      (p_effective_date         => l_effective_date
      ,p_business_group_id      => p_business_group_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_assignment_id          => p_assignment_id
      ,p_contract_type          => p_contract_type
      ,p_work_pattern           => p_work_pattern
      ,p_start_day              => p_start_day
      ,p_primary_company_car        => p_primary_company_car
      ,p_primary_car_fuel_benefit   => p_primary_car_fuel_benefit
      ,p_primary_capital_contribution => p_primary_capital_contribution
      ,p_primary_class_1a           => p_primary_class_1a
      ,p_secondary_company_car      => p_secondary_company_car
      ,p_secondary_car_fuel_benefit => p_secondary_car_fuel_benefit
      ,p_secondary_capital_contributi => p_secondary_capital_contributi
      ,p_secondary_class_1a         => p_secondary_class_1a
      ,p_company_car_calc_method    => p_company_car_calc_method
      ,p_company_car_rates_table_id    => p_company_car_rates_table_id
      ,p_company_car_secondary_table => p_company_car_secondary_table
      ,p_private_car                => p_private_car
      ,p_private_car_calc_method    => p_private_car_calc_method
      ,p_private_car_rates_table_id    => p_private_car_rates_table_id
      ,p_private_car_essential_table => p_private_car_essential_table
      ,p_primary_private_contribution   => p_primary_private_contribution
      ,p_secondary_private_contributi   => p_secondary_private_contributi
      ,p_tp_is_teacher                  => p_tp_is_teacher
       --added for head Teacher seconded location for salary scale calculation
      ,p_tp_headteacher_grp_code        => p_tp_headteacher_grp_code
      ,p_tp_safeguarded_grade           => p_tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type       => p_tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id         => p_tp_safeguarded_rate_id
      ,p_tp_spinal_point_id             => p_tp_spinal_point_id
      ,p_tp_elected_pension             => p_tp_elected_pension
      ,p_tp_fast_track                  => p_tp_fast_track
      ,p_aat_attribute_category         => p_aat_attribute_category
      ,p_aat_attribute1                 => p_aat_attribute1
      ,p_aat_attribute2                 => p_aat_attribute2
      ,p_aat_attribute3                 => p_aat_attribute3
      ,p_aat_attribute4                 => p_aat_attribute4
      ,p_aat_attribute5                 => p_aat_attribute5
      ,p_aat_attribute6                 => p_aat_attribute6
      ,p_aat_attribute7                 => p_aat_attribute7
      ,p_aat_attribute8                 => p_aat_attribute8
      ,p_aat_attribute9                 => p_aat_attribute9
      ,p_aat_attribute10                => p_aat_attribute10
      ,p_aat_attribute11                => p_aat_attribute11
      ,p_aat_attribute12                => p_aat_attribute12
      ,p_aat_attribute13                => p_aat_attribute13
      ,p_aat_attribute14                => p_aat_attribute14
      ,p_aat_attribute15                => p_aat_attribute15
      ,p_aat_attribute16                => p_aat_attribute16
      ,p_aat_attribute17                => p_aat_attribute17
      ,p_aat_attribute18                => p_aat_attribute18
      ,p_aat_attribute19                => p_aat_attribute19
      ,p_aat_attribute20                => p_aat_attribute20
      ,p_aat_information_category       => p_aat_information_category
      ,p_aat_information1               => p_aat_information1
      ,p_aat_information2               => p_aat_information2
      ,p_aat_information3               => p_aat_information3
      ,p_aat_information4               => p_aat_information4
      ,p_aat_information5               => p_aat_information5
      ,p_aat_information6               => p_aat_information6
      ,p_aat_information7               => p_aat_information7
      ,p_aat_information8               => p_aat_information8
      ,p_aat_information9               => p_aat_information9
      ,p_aat_information10              => p_aat_information10
      ,p_aat_information11              => p_aat_information11
      ,p_aat_information12              => p_aat_information12
      ,p_aat_information13              => p_aat_information13
      ,p_aat_information14              => p_aat_information14
      ,p_aat_information15              => p_aat_information15
      ,p_aat_information16              => p_aat_information16
      ,p_aat_information17              => p_aat_information17
      ,p_aat_information18              => p_aat_information18
      ,p_aat_information19              => p_aat_information19
      ,p_aat_information20              => p_aat_information20
      ,p_lgps_process_flag              => p_lgps_process_flag
      ,p_lgps_exclusion_type            => p_lgps_exclusion_type
      ,p_lgps_pensionable_pay           => p_lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag         => p_lgps_trans_arrang_flag
      ,p_lgps_membership_number         => p_lgps_membership_number
      ,p_assignment_attribute_id    => l_assignment_attribute_id
      ,p_object_version_number      => l_object_version_number
      );
  --


  --
  -- Call After Process User Hook
  --
  begin
    pqp_aat_api_bk1.create_assignment_attribute_a
      (p_effective_date         => l_effective_date
      ,p_business_group_id      => p_business_group_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_assignment_id          => p_assignment_id
      ,p_contract_type          => p_contract_type
      ,p_work_pattern           => p_work_pattern
      ,p_start_day              => p_start_day
      ,p_primary_company_car        => p_primary_company_car
      ,p_primary_car_fuel_benefit   => p_primary_car_fuel_benefit
      ,p_primary_capital_contribution => p_primary_capital_contribution
      ,p_primary_class_1a           => p_primary_class_1a
      ,p_secondary_company_car      => p_secondary_company_car
      ,p_secondary_car_fuel_benefit => p_secondary_car_fuel_benefit
      ,p_secondary_capital_contributi => p_secondary_capital_contributi
      ,p_secondary_class_1a         => p_secondary_class_1a
      ,p_company_car_calc_method    => p_company_car_calc_method
      ,p_company_car_rates_table_id    => p_company_car_rates_table_id
      ,p_company_car_secondary_table => p_company_car_secondary_table
      ,p_private_car                => p_private_car
      ,p_private_car_calc_method    => p_private_car_calc_method
      ,p_private_car_rates_table_id    => p_private_car_rates_table_id
      ,p_private_car_essential_table => p_private_car_essential_table
      ,p_primary_private_contribution   => p_primary_private_contribution
      ,p_secondary_private_contributi   => p_secondary_private_contributi
      ,p_tp_is_teacher                  => p_tp_is_teacher
       --added for head Teacher seconded location for salary scale calculation
      ,p_tp_headteacher_grp_code        => p_tp_headteacher_grp_code
      ,p_tp_safeguarded_grade           => p_tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type       => p_tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id         => p_tp_safeguarded_rate_id
      ,p_tp_spinal_point_id             => p_tp_spinal_point_id
      ,p_tp_elected_pension             => p_tp_elected_pension
      ,p_tp_fast_track                  => p_tp_fast_track
      ,p_aat_attribute_category         => p_aat_attribute_category
      ,p_aat_attribute1                 => p_aat_attribute1
      ,p_aat_attribute2                 => p_aat_attribute2
      ,p_aat_attribute3                 => p_aat_attribute3
      ,p_aat_attribute4                 => p_aat_attribute4
      ,p_aat_attribute5                 => p_aat_attribute5
      ,p_aat_attribute6                 => p_aat_attribute6
      ,p_aat_attribute7                 => p_aat_attribute7
      ,p_aat_attribute8                 => p_aat_attribute8
      ,p_aat_attribute9                 => p_aat_attribute9
      ,p_aat_attribute10                => p_aat_attribute10
      ,p_aat_attribute11                => p_aat_attribute11
      ,p_aat_attribute12                => p_aat_attribute12
      ,p_aat_attribute13                => p_aat_attribute13
      ,p_aat_attribute14                => p_aat_attribute14
      ,p_aat_attribute15                => p_aat_attribute15
      ,p_aat_attribute16                => p_aat_attribute16
      ,p_aat_attribute17                => p_aat_attribute17
      ,p_aat_attribute18                => p_aat_attribute18
      ,p_aat_attribute19                => p_aat_attribute19
      ,p_aat_attribute20                => p_aat_attribute20
      ,p_aat_information_category       => p_aat_information_category
      ,p_aat_information1               => p_aat_information1
      ,p_aat_information2               => p_aat_information2
      ,p_aat_information3               => p_aat_information3
      ,p_aat_information4               => p_aat_information4
      ,p_aat_information5               => p_aat_information5
      ,p_aat_information6               => p_aat_information6
      ,p_aat_information7               => p_aat_information7
      ,p_aat_information8               => p_aat_information8
      ,p_aat_information9               => p_aat_information9
      ,p_aat_information10              => p_aat_information10
      ,p_aat_information11              => p_aat_information11
      ,p_aat_information12              => p_aat_information12
      ,p_aat_information13              => p_aat_information13
      ,p_aat_information14              => p_aat_information14
      ,p_aat_information15              => p_aat_information15
      ,p_aat_information16              => p_aat_information16
      ,p_aat_information17              => p_aat_information17
      ,p_aat_information18              => p_aat_information18
      ,p_aat_information19              => p_aat_information19
      ,p_aat_information20              => p_aat_information20
      ,p_lgps_process_flag              => p_lgps_process_flag
      ,p_lgps_exclusion_type            => p_lgps_exclusion_type
      ,p_lgps_pensionable_pay           => p_lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag         => p_lgps_trans_arrang_flag
      ,p_lgps_membership_number         => p_lgps_membership_number
      ,p_assignment_attribute_id =>l_assignment_attribute_id
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_assignment_attribute'
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
  p_assignment_attribute_id     := l_assignment_attribute_id;
  p_object_version_number       := l_object_version_number;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_assignment_attribute;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_attribute_id   := null;
    p_object_version_number     := null;
    p_effective_start_date      := null;
    p_effective_end_date        := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_assignment_attribute;
    p_assignment_attribute_id   := null;
    p_object_version_number     := null;
    p_effective_start_date      := null;
    p_effective_end_date        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_assignment_attribute;
--
--
-- ---------------------------------------------------------------------------+
-- |---------------------< <update_assignment_attribute> >--------------------|
-- ---------------------------------------------------------------------------+
--
procedure update_assignment_attribute
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_assignment_attribute_id       in     number
  ,p_business_group_id             in     number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_contract_type                 in     varchar2 default hr_api.g_varchar2
  ,p_work_pattern                  in     varchar2 default hr_api.g_varchar2
  ,p_start_day                     in     varchar2 default hr_api.g_varchar2
  ,p_primary_company_car           in     number   default hr_api.g_number
  ,p_primary_car_fuel_benefit      in     varchar2 default hr_api.g_varchar2
  ,p_primary_capital_contribution  in     number    default hr_api.g_number
  ,p_primary_class_1a              in     varchar2 default hr_api.g_varchar2
  ,p_secondary_company_car         in     number   default hr_api.g_number
  ,p_secondary_car_fuel_benefit    in     varchar2 default hr_api.g_varchar2
  ,p_secondary_capital_contributi  in     number    default hr_api.g_number
  ,p_secondary_class_1a            in     varchar2 default hr_api.g_varchar2
  ,p_company_car_calc_method       in     varchar2 default hr_api.g_varchar2
  ,p_company_car_rates_table_id    in     number default hr_api.g_number
  ,p_company_car_secondary_table   in     number default hr_api.g_number
  ,p_private_car                   in     number    default hr_api.g_number
  ,p_private_car_calc_method       in     varchar2 default hr_api.g_varchar2
  ,p_private_car_rates_table_id    in     number default hr_api.g_number
  ,p_private_car_essential_table   in     number default hr_api.g_number
  ,p_primary_private_contribution  in     number  default hr_api.g_number
  ,p_secondary_private_contributi  in     number  default hr_api.g_number
  ,p_tp_is_teacher                 in     varchar2  default hr_api.g_varchar2
  --added for head Teacher seconded location for salary scale calculation
  ,p_tp_headteacher_grp_code       in     number  default hr_api.g_number
  ,p_tp_safeguarded_grade          in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_grade_id       in     number    default hr_api.g_number
  ,p_tp_safeguarded_rate_type      in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_rate_id        in     number    default hr_api.g_number
  ,p_tp_spinal_point_id            in     number  default hr_api.g_number
  ,p_tp_elected_pension            in     varchar2  default hr_api.g_varchar2
  ,p_tp_fast_track                 in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute_category     in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute1             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute2             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute3             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute4             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute5             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute6             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute7             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute8             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute9             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute10            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute11            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute12            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute13            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute14            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute15            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute16            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute17            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute18            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute19            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute20            in varchar2  default hr_api.g_varchar2
  ,p_aat_information_category   in varchar2  default hr_api.g_varchar2
  ,p_aat_information1           in varchar2  default hr_api.g_varchar2
  ,p_aat_information2           in varchar2  default hr_api.g_varchar2
  ,p_aat_information3           in varchar2  default hr_api.g_varchar2
  ,p_aat_information4           in varchar2  default hr_api.g_varchar2
  ,p_aat_information5           in varchar2  default hr_api.g_varchar2
  ,p_aat_information6           in varchar2  default hr_api.g_varchar2
  ,p_aat_information7           in varchar2  default hr_api.g_varchar2
  ,p_aat_information8           in varchar2  default hr_api.g_varchar2
  ,p_aat_information9           in varchar2  default hr_api.g_varchar2
  ,p_aat_information10          in varchar2  default hr_api.g_varchar2
  ,p_aat_information11          in varchar2  default hr_api.g_varchar2
  ,p_aat_information12          in varchar2  default hr_api.g_varchar2
  ,p_aat_information13          in varchar2  default hr_api.g_varchar2
  ,p_aat_information14          in varchar2  default hr_api.g_varchar2
  ,p_aat_information15          in varchar2  default hr_api.g_varchar2
  ,p_aat_information16          in varchar2  default hr_api.g_varchar2
  ,p_aat_information17          in varchar2  default hr_api.g_varchar2
  ,p_aat_information18          in varchar2  default hr_api.g_varchar2
  ,p_aat_information19          in varchar2  default hr_api.g_varchar2
  ,p_aat_information20          in varchar2  default hr_api.g_varchar2
  ,p_lgps_process_flag          in varchar2  default hr_api.g_varchar2
  ,p_lgps_exclusion_type        in varchar2  default hr_api.g_varchar2
  ,p_lgps_pensionable_pay       in varchar2  default hr_api.g_varchar2
  ,p_lgps_trans_arrang_flag     in varchar2  default hr_api.g_varchar2
  ,p_lgps_membership_number     in varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declaring cursors and local variables
  --
  l_object_version_number       number;
  l_proc                        varchar2(72) := g_package||'update_assignment_attribute';
  l_effective_date              date;
  l_effective_start_date        date;
  l_effective_end_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_assignment_attribute;
  --
  -- Truncate the time portion from all IN date parameters
  --

     l_effective_date           := trunc(p_effective_date);
     l_effective_start_date     := trunc(p_effective_start_date);
     l_effective_end_date       := trunc(p_effective_end_date);


  --
  -- Call Before Process User Hook
  --
  begin
    pqp_aat_api_bk2.update_assignment_attribute_b
      (p_effective_date         => l_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_business_group_id      => p_business_group_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_assignment_id          => p_assignment_id
      ,p_contract_type          => p_contract_type
      ,p_work_pattern           => p_work_pattern
      ,p_start_day              => p_start_day
      ,p_primary_company_car        => p_primary_company_car
      ,p_primary_car_fuel_benefit   => p_primary_car_fuel_benefit
      ,p_primary_capital_contribution => p_primary_capital_contribution
      ,p_primary_class_1a           => p_primary_class_1a
      ,p_secondary_company_car      => p_secondary_company_car
      ,p_secondary_car_fuel_benefit => p_secondary_car_fuel_benefit
      ,p_secondary_capital_contributi => p_secondary_capital_contributi
      ,p_secondary_class_1a         => p_secondary_class_1a
      ,p_company_car_calc_method    => p_company_car_calc_method
      ,p_company_car_rates_table_id    => p_company_car_rates_table_id
      ,p_company_car_secondary_table => p_company_car_secondary_table
      ,p_private_car                => p_private_car
      ,p_private_car_calc_method    => p_private_car_calc_method
      ,p_private_car_rates_table_id    => p_private_car_rates_table_id
      ,p_private_car_essential_table => p_private_car_essential_table
      ,p_primary_private_contribution   => p_primary_private_contribution
      ,p_secondary_private_contributi   => p_secondary_private_contributi
      ,p_tp_is_teacher                  => p_tp_is_teacher
       --added for head Teacher seconded location for salary scale calculation
      ,p_tp_headteacher_grp_code        => p_tp_headteacher_grp_code
      ,p_tp_safeguarded_grade           => p_tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type       => p_tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id         => p_tp_safeguarded_rate_id
      ,p_tp_spinal_point_id             => p_tp_spinal_point_id
      ,p_tp_elected_pension             => p_tp_elected_pension
      ,p_tp_fast_track                  => p_tp_fast_track
      ,p_aat_attribute_category         => p_aat_attribute_category
      ,p_aat_attribute1                 => p_aat_attribute1
      ,p_aat_attribute2                 => p_aat_attribute2
      ,p_aat_attribute3                 => p_aat_attribute3
      ,p_aat_attribute4                 => p_aat_attribute4
      ,p_aat_attribute5                 => p_aat_attribute5
      ,p_aat_attribute6                 => p_aat_attribute6
      ,p_aat_attribute7                 => p_aat_attribute7
      ,p_aat_attribute8                 => p_aat_attribute8
      ,p_aat_attribute9                 => p_aat_attribute9
      ,p_aat_attribute10                => p_aat_attribute10
      ,p_aat_attribute11                => p_aat_attribute11
      ,p_aat_attribute12                => p_aat_attribute12
      ,p_aat_attribute13                => p_aat_attribute13
      ,p_aat_attribute14                => p_aat_attribute14
      ,p_aat_attribute15                => p_aat_attribute15
      ,p_aat_attribute16                => p_aat_attribute16
      ,p_aat_attribute17                => p_aat_attribute17
      ,p_aat_attribute18                => p_aat_attribute18
      ,p_aat_attribute19                => p_aat_attribute19
      ,p_aat_attribute20                => p_aat_attribute20
      ,p_aat_information_category       => p_aat_information_category
      ,p_aat_information1               => p_aat_information1
      ,p_aat_information2               => p_aat_information2
      ,p_aat_information3               => p_aat_information3
      ,p_aat_information4               => p_aat_information4
      ,p_aat_information5               => p_aat_information5
      ,p_aat_information6               => p_aat_information6
      ,p_aat_information7               => p_aat_information7
      ,p_aat_information8               => p_aat_information8
      ,p_aat_information9               => p_aat_information9
      ,p_aat_information10              => p_aat_information10
      ,p_aat_information11              => p_aat_information11
      ,p_aat_information12              => p_aat_information12
      ,p_aat_information13              => p_aat_information13
      ,p_aat_information14              => p_aat_information14
      ,p_aat_information15              => p_aat_information15
      ,p_aat_information16              => p_aat_information16
      ,p_aat_information17              => p_aat_information17
      ,p_aat_information18              => p_aat_information18
      ,p_aat_information19              => p_aat_information19
      ,p_aat_information20              => p_aat_information20
      ,p_lgps_process_flag              => p_lgps_process_flag
      ,p_lgps_exclusion_type            => p_lgps_exclusion_type
      ,p_lgps_pensionable_pay           => p_lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag         => p_lgps_trans_arrang_flag
      ,p_lgps_membership_number         => p_lgps_membership_number
      ,p_assignment_attribute_id =>p_assignment_attribute_id
      ,p_object_version_number  => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_assignment_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

     l_object_version_number := p_object_version_number;

  --
  -- Process Logic, calling Row Handler for update
    pqp_aat_upd.upd
      (p_effective_date         => l_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_business_group_id      => p_business_group_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_assignment_id          => p_assignment_id
      ,p_contract_type          => p_contract_type
      ,p_work_pattern           => p_work_pattern
      ,p_start_day              => p_start_day
      ,p_primary_company_car        => p_primary_company_car
      ,p_primary_car_fuel_benefit   => p_primary_car_fuel_benefit
      ,p_primary_capital_contribution => p_primary_capital_contribution
      ,p_primary_class_1a           => p_primary_class_1a
      ,p_secondary_company_car      => p_secondary_company_car
      ,p_secondary_car_fuel_benefit => p_secondary_car_fuel_benefit
      ,p_secondary_capital_contributi => p_secondary_capital_contributi
      ,p_secondary_class_1a         => p_secondary_class_1a
      ,p_company_car_calc_method    => p_company_car_calc_method
      ,p_company_car_rates_table_id    => p_company_car_rates_table_id
      ,p_company_car_secondary_table => p_company_car_secondary_table
      ,p_private_car                => p_private_car
      ,p_private_car_calc_method    => p_private_car_calc_method
      ,p_private_car_rates_table_id    => p_private_car_rates_table_id
      ,p_private_car_essential_table  => p_private_car_essential_table
      ,p_primary_private_contribution   => p_primary_private_contribution
      ,p_secondary_private_contributi   => p_secondary_private_contributi
      ,p_tp_is_teacher                  => p_tp_is_teacher
       --added for head Teacher seconded location for salary scale calculation
      ,p_tp_headteacher_grp_code        => p_tp_headteacher_grp_code
      ,p_tp_safeguarded_grade           => p_tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type       => p_tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id         => p_tp_safeguarded_rate_id
      ,p_tp_spinal_point_id             => p_tp_spinal_point_id
      ,p_tp_elected_pension             => p_tp_elected_pension
      ,p_tp_fast_track                  => p_tp_fast_track
      ,p_aat_attribute_category         => p_aat_attribute_category
      ,p_aat_attribute1                 => p_aat_attribute1
      ,p_aat_attribute2                 => p_aat_attribute2
      ,p_aat_attribute3                 => p_aat_attribute3
      ,p_aat_attribute4                 => p_aat_attribute4
      ,p_aat_attribute5                 => p_aat_attribute5
      ,p_aat_attribute6                 => p_aat_attribute6
      ,p_aat_attribute7                 => p_aat_attribute7
      ,p_aat_attribute8                 => p_aat_attribute8
      ,p_aat_attribute9                 => p_aat_attribute9
      ,p_aat_attribute10                => p_aat_attribute10
      ,p_aat_attribute11                => p_aat_attribute11
      ,p_aat_attribute12                => p_aat_attribute12
      ,p_aat_attribute13                => p_aat_attribute13
      ,p_aat_attribute14                => p_aat_attribute14
      ,p_aat_attribute15                => p_aat_attribute15
      ,p_aat_attribute16                => p_aat_attribute16
      ,p_aat_attribute17                => p_aat_attribute17
      ,p_aat_attribute18                => p_aat_attribute18
      ,p_aat_attribute19                => p_aat_attribute19
      ,p_aat_attribute20                => p_aat_attribute20
      ,p_aat_information_category       => p_aat_information_category
      ,p_aat_information1               => p_aat_information1
      ,p_aat_information2               => p_aat_information2
      ,p_aat_information3               => p_aat_information3
      ,p_aat_information4               => p_aat_information4
      ,p_aat_information5               => p_aat_information5
      ,p_aat_information6               => p_aat_information6
      ,p_aat_information7               => p_aat_information7
      ,p_aat_information8               => p_aat_information8
      ,p_aat_information9               => p_aat_information9
      ,p_aat_information10              => p_aat_information10
      ,p_aat_information11              => p_aat_information11
      ,p_aat_information12              => p_aat_information12
      ,p_aat_information13              => p_aat_information13
      ,p_aat_information14              => p_aat_information14
      ,p_aat_information15              => p_aat_information15
      ,p_aat_information16              => p_aat_information16
      ,p_aat_information17              => p_aat_information17
      ,p_aat_information18              => p_aat_information18
      ,p_aat_information19              => p_aat_information19
      ,p_aat_information20              => p_aat_information20
      ,p_lgps_process_flag              => p_lgps_process_flag
      ,p_lgps_exclusion_type            => p_lgps_exclusion_type
      ,p_lgps_pensionable_pay           => p_lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag         => p_lgps_trans_arrang_flag
      ,p_lgps_membership_number         => p_lgps_membership_number
      ,p_assignment_attribute_id =>p_assignment_attribute_id
      ,p_object_version_number  => l_object_version_number
    );
  --



  --
  -- Call After Process User Hook
  --
  begin
    pqp_aat_api_bk2.update_assignment_attribute_a
      (p_effective_date         => l_effective_date
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_business_group_id      => p_business_group_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_assignment_id          => p_assignment_id
      ,p_contract_type          => p_contract_type
      ,p_work_pattern           => p_work_pattern
      ,p_start_day              => p_start_day
      ,p_primary_company_car        => p_primary_company_car
      ,p_primary_car_fuel_benefit   => p_primary_car_fuel_benefit
      ,p_primary_capital_contribution => p_primary_capital_contribution
      ,p_primary_class_1a           => p_primary_class_1a
      ,p_secondary_company_car      => p_secondary_company_car
      ,p_secondary_car_fuel_benefit => p_secondary_car_fuel_benefit
      ,p_secondary_capital_contributi => p_secondary_capital_contributi
      ,p_secondary_class_1a         => p_secondary_class_1a
      ,p_company_car_calc_method    => p_company_car_calc_method
      ,p_company_car_rates_table_id    => p_company_car_rates_table_id
      ,p_company_car_secondary_table => p_company_car_secondary_table
      ,p_private_car                => p_private_car
      ,p_private_car_calc_method    => p_private_car_calc_method
      ,p_private_car_rates_table_id    => p_private_car_rates_table_id
      ,p_private_car_essential_table => p_private_car_essential_table
      ,p_primary_private_contribution   => p_primary_private_contribution
      ,p_secondary_private_contributi   => p_secondary_private_contributi
      ,p_tp_is_teacher                  => p_tp_is_teacher
       --added for head Teacher seconded location for salary scale calculation
      ,p_tp_headteacher_grp_code        => p_tp_headteacher_grp_code
      ,p_tp_safeguarded_grade           => p_tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_tp_safeguarded_grade_id
      ,p_tp_safeguarded_rate_type       => p_tp_safeguarded_rate_type
      ,p_tp_safeguarded_rate_id         => p_tp_safeguarded_rate_id
      ,p_tp_spinal_point_id             => p_tp_spinal_point_id
      ,p_tp_elected_pension             => p_tp_elected_pension
      ,p_tp_fast_track                  => p_tp_fast_track
      ,p_aat_attribute_category         => p_aat_attribute_category
      ,p_aat_attribute1                 => p_aat_attribute1
      ,p_aat_attribute2                 => p_aat_attribute2
      ,p_aat_attribute3                 => p_aat_attribute3
      ,p_aat_attribute4                 => p_aat_attribute4
      ,p_aat_attribute5                 => p_aat_attribute5
      ,p_aat_attribute6                 => p_aat_attribute6
      ,p_aat_attribute7                 => p_aat_attribute7
      ,p_aat_attribute8                 => p_aat_attribute8
      ,p_aat_attribute9                 => p_aat_attribute9
      ,p_aat_attribute10                => p_aat_attribute10
      ,p_aat_attribute11                => p_aat_attribute11
      ,p_aat_attribute12                => p_aat_attribute12
      ,p_aat_attribute13                => p_aat_attribute13
      ,p_aat_attribute14                => p_aat_attribute14
      ,p_aat_attribute15                => p_aat_attribute15
      ,p_aat_attribute16                => p_aat_attribute16
      ,p_aat_attribute17                => p_aat_attribute17
      ,p_aat_attribute18                => p_aat_attribute18
      ,p_aat_attribute19                => p_aat_attribute19
      ,p_aat_attribute20                => p_aat_attribute20
      ,p_aat_information_category       => p_aat_information_category
      ,p_aat_information1               => p_aat_information1
      ,p_aat_information2               => p_aat_information2
      ,p_aat_information3               => p_aat_information3
      ,p_aat_information4               => p_aat_information4
      ,p_aat_information5               => p_aat_information5
      ,p_aat_information6               => p_aat_information6
      ,p_aat_information7               => p_aat_information7
      ,p_aat_information8               => p_aat_information8
      ,p_aat_information9               => p_aat_information9
      ,p_aat_information10              => p_aat_information10
      ,p_aat_information11              => p_aat_information11
      ,p_aat_information12              => p_aat_information12
      ,p_aat_information13              => p_aat_information13
      ,p_aat_information14              => p_aat_information14
      ,p_aat_information15              => p_aat_information15
      ,p_aat_information16              => p_aat_information16
      ,p_aat_information17              => p_aat_information17
      ,p_aat_information18              => p_aat_information18
      ,p_aat_information19              => p_aat_information19
      ,p_aat_information20              => p_aat_information20
      ,p_lgps_process_flag              => p_lgps_process_flag
      ,p_lgps_exclusion_type            => p_lgps_exclusion_type
      ,p_lgps_pensionable_pay           => p_lgps_pensionable_pay
      ,p_lgps_trans_arrang_flag         => p_lgps_trans_arrang_flag
      ,p_lgps_membership_number         => p_lgps_membership_number
      ,p_assignment_attribute_id =>p_assignment_attribute_id
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_assignment_attribute'
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_assignment_attribute;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_assignment_attribute;
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_assignment_attribute;
--
--
-- ---------------------------------------------------------------------------+
-- |---------------------< <delete_assignment_attribute> >--------------------|
-- ---------------------------------------------------------------------------+
--
procedure delete_assignment_attribute
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_business_group_id             in     number
  ,p_assignment_attribute_id       in     number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_assignment_attribute';
  l_effective_date              date;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_object_version_number       number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_assignment_attribute;
  --
  -- Truncate the time portion from all IN date parameters
  --

     l_effective_date           := trunc(p_effective_date);
     l_effective_start_date     := trunc(p_effective_start_date);
     l_effective_end_date       := trunc(p_effective_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqp_aat_api_bk3.delete_assignment_attribute_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_assignment_attribute_id       => p_assignment_attribute_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_assignment_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

     l_object_version_number := p_object_version_number;


  --
  -- Process Logic
     pqp_aat_del.del
      (p_effective_date         => l_effective_date
      ,p_assignment_attribute_id =>p_assignment_attribute_id
      ,p_datetrack_mode         => p_datetrack_mode
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_object_version_number  => l_object_version_number
      );
  --



  --
  -- Call After Process User Hook
  --
  begin
    pqp_aat_api_bk3.delete_assignment_attribute_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_assignment_attribute_id       => p_assignment_attribute_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_assignment_attribute'
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
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_assignment_attribute;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
     p_object_version_number := null;
     p_effective_start_date  := null;
     p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_assignment_attribute;
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_assignment_attribute;

--
end pqp_aat_api;

/
