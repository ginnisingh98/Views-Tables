--------------------------------------------------------
--  DDL for Package Body PAY_CONTRIBUTION_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CONTRIBUTION_HISTORY_API" as
/* $Header: pyconapi.pkb 115.1 99/09/30 13:47:35 porting ship  $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_Contribution_History_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Contribution_History >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Contribution_History
  (p_validate                       in  boolean   default false
  ,p_contr_history_id               out number
  ,p_person_id                      in  number    default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_contr_type                     in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_amt_contr                      in  number    default null
  ,p_max_contr_allowed              in  number    default null
  ,p_includable_comp                in  number    default null
  ,p_tax_unit_id                    in  number    default null
  ,p_source_system                  in  varchar2  default null
  ,p_contr_information_category     in  varchar2  default null
  ,p_contr_information1             in  varchar2  default null
  ,p_contr_information2             in  varchar2  default null
  ,p_contr_information3             in  varchar2  default null
  ,p_contr_information4             in  varchar2  default null
  ,p_contr_information5             in  varchar2  default null
  ,p_contr_information6             in  varchar2  default null
  ,p_contr_information7             in  varchar2  default null
  ,p_contr_information8             in  varchar2  default null
  ,p_contr_information9             in  varchar2  default null
  ,p_contr_information10            in  varchar2  default null
  ,p_contr_information11            in  varchar2  default null
  ,p_contr_information12            in  varchar2  default null
  ,p_contr_information13            in  varchar2  default null
  ,p_contr_information14            in  varchar2  default null
  ,p_contr_information15            in  varchar2  default null
  ,p_contr_information16            in  varchar2  default null
  ,p_contr_information17            in  varchar2  default null
  ,p_contr_information18            in  varchar2  default null
  ,p_contr_information19            in  varchar2  default null
  ,p_contr_information20            in  varchar2  default null
  ,p_contr_information21            in  varchar2  default null
  ,p_contr_information22            in  varchar2  default null
  ,p_contr_information23            in  varchar2  default null
  ,p_contr_information24            in  varchar2  default null
  ,p_contr_information25            in  varchar2  default null
  ,p_contr_information26            in  varchar2  default null
  ,p_contr_information27            in  varchar2  default null
  ,p_contr_information28            in  varchar2  default null
  ,p_contr_information29            in  varchar2  default null
  ,p_contr_information30            in  varchar2  default null
  ,p_object_version_number          out number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_contr_history_id pay_us_contribution_history.contr_history_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Contribution_History';
  l_object_version_number pay_us_contribution_history.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Contribution_History;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Contribution_History
    --
    pay_Contribution_History_bk1.create_Contribution_History_b
      (
       p_person_id                      =>  p_person_id
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_contr_type                     =>  p_contr_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_amt_contr                      =>  p_amt_contr
      ,p_max_contr_allowed              =>  p_max_contr_allowed
      ,p_includable_comp                =>  p_includable_comp
      ,p_tax_unit_id                    =>  p_tax_unit_id
      ,p_source_system                  =>  p_source_system
      ,p_contr_information_category     =>  p_contr_information_category
      ,p_contr_information1             =>  p_contr_information1
      ,p_contr_information2             =>  p_contr_information2
      ,p_contr_information3             =>  p_contr_information3
      ,p_contr_information4             =>  p_contr_information4
      ,p_contr_information5             =>  p_contr_information5
      ,p_contr_information6             =>  p_contr_information6
      ,p_contr_information7             =>  p_contr_information7
      ,p_contr_information8             =>  p_contr_information8
      ,p_contr_information9             =>  p_contr_information9
      ,p_contr_information10            =>  p_contr_information10
      ,p_contr_information11            =>  p_contr_information11
      ,p_contr_information12            =>  p_contr_information12
      ,p_contr_information13            =>  p_contr_information13
      ,p_contr_information14            =>  p_contr_information14
      ,p_contr_information15            =>  p_contr_information15
      ,p_contr_information16            =>  p_contr_information16
      ,p_contr_information17            =>  p_contr_information17
      ,p_contr_information18            =>  p_contr_information18
      ,p_contr_information19            =>  p_contr_information19
      ,p_contr_information20            =>  p_contr_information20
      ,p_contr_information21            =>  p_contr_information21
      ,p_contr_information22            =>  p_contr_information22
      ,p_contr_information23            =>  p_contr_information23
      ,p_contr_information24            =>  p_contr_information24
      ,p_contr_information25            =>  p_contr_information25
      ,p_contr_information26            =>  p_contr_information26
      ,p_contr_information27            =>  p_contr_information27
      ,p_contr_information28            =>  p_contr_information28
      ,p_contr_information29            =>  p_contr_information29
      ,p_contr_information30            =>  p_contr_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Contribution_History'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Contribution_History
    --
  end;
  --
  pay_con_ins.ins
    (
     p_contr_history_id              => l_contr_history_id
    ,p_person_id                     => p_person_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_contr_type                    => p_contr_type
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_amt_contr                     => p_amt_contr
    ,p_max_contr_allowed             => p_max_contr_allowed
    ,p_includable_comp               => p_includable_comp
    ,p_tax_unit_id                   => p_tax_unit_id
    ,p_source_system                 => p_source_system
    ,p_contr_information_category    => p_contr_information_category
    ,p_contr_information1            => p_contr_information1
    ,p_contr_information2            => p_contr_information2
    ,p_contr_information3            => p_contr_information3
    ,p_contr_information4            => p_contr_information4
    ,p_contr_information5            => p_contr_information5
    ,p_contr_information6            => p_contr_information6
    ,p_contr_information7            => p_contr_information7
    ,p_contr_information8            => p_contr_information8
    ,p_contr_information9            => p_contr_information9
    ,p_contr_information10           => p_contr_information10
    ,p_contr_information11           => p_contr_information11
    ,p_contr_information12           => p_contr_information12
    ,p_contr_information13           => p_contr_information13
    ,p_contr_information14           => p_contr_information14
    ,p_contr_information15           => p_contr_information15
    ,p_contr_information16           => p_contr_information16
    ,p_contr_information17           => p_contr_information17
    ,p_contr_information18           => p_contr_information18
    ,p_contr_information19           => p_contr_information19
    ,p_contr_information20           => p_contr_information20
    ,p_contr_information21           => p_contr_information21
    ,p_contr_information22           => p_contr_information22
    ,p_contr_information23           => p_contr_information23
    ,p_contr_information24           => p_contr_information24
    ,p_contr_information25           => p_contr_information25
    ,p_contr_information26           => p_contr_information26
    ,p_contr_information27           => p_contr_information27
    ,p_contr_information28           => p_contr_information28
    ,p_contr_information29           => p_contr_information29
    ,p_contr_information30           => p_contr_information30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Contribution_History
    --
    pay_Contribution_History_bk1.create_Contribution_History_a
      (
       p_contr_history_id               =>  l_contr_history_id
      ,p_person_id                      =>  p_person_id
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_contr_type                     =>  p_contr_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_amt_contr                      =>  p_amt_contr
      ,p_max_contr_allowed              =>  p_max_contr_allowed
      ,p_includable_comp                =>  p_includable_comp
      ,p_tax_unit_id                    =>  p_tax_unit_id
      ,p_source_system                  =>  p_source_system
      ,p_contr_information_category     =>  p_contr_information_category
      ,p_contr_information1             =>  p_contr_information1
      ,p_contr_information2             =>  p_contr_information2
      ,p_contr_information3             =>  p_contr_information3
      ,p_contr_information4             =>  p_contr_information4
      ,p_contr_information5             =>  p_contr_information5
      ,p_contr_information6             =>  p_contr_information6
      ,p_contr_information7             =>  p_contr_information7
      ,p_contr_information8             =>  p_contr_information8
      ,p_contr_information9             =>  p_contr_information9
      ,p_contr_information10            =>  p_contr_information10
      ,p_contr_information11            =>  p_contr_information11
      ,p_contr_information12            =>  p_contr_information12
      ,p_contr_information13            =>  p_contr_information13
      ,p_contr_information14            =>  p_contr_information14
      ,p_contr_information15            =>  p_contr_information15
      ,p_contr_information16            =>  p_contr_information16
      ,p_contr_information17            =>  p_contr_information17
      ,p_contr_information18            =>  p_contr_information18
      ,p_contr_information19            =>  p_contr_information19
      ,p_contr_information20            =>  p_contr_information20
      ,p_contr_information21            =>  p_contr_information21
      ,p_contr_information22            =>  p_contr_information22
      ,p_contr_information23            =>  p_contr_information23
      ,p_contr_information24            =>  p_contr_information24
      ,p_contr_information25            =>  p_contr_information25
      ,p_contr_information26            =>  p_contr_information26
      ,p_contr_information27            =>  p_contr_information27
      ,p_contr_information28            =>  p_contr_information28
      ,p_contr_information29            =>  p_contr_information29
      ,p_contr_information30            =>  p_contr_information30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Contribution_History'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Contribution_History
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
  p_contr_history_id := l_contr_history_id;
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
    ROLLBACK TO create_Contribution_History;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_contr_history_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Contribution_History;
    raise;
    --
end create_Contribution_History;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Contribution_History >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Contribution_History
  (p_validate                       in  boolean   default false
  ,p_contr_history_id               in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_contr_type                     in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_amt_contr                      in  number    default hr_api.g_number
  ,p_max_contr_allowed              in  number    default hr_api.g_number
  ,p_includable_comp                in  number    default hr_api.g_number
  ,p_tax_unit_id                    in  number    default hr_api.g_number
  ,p_source_system                  in  varchar2  default hr_api.g_varchar2
  ,p_contr_information_category     in  varchar2  default hr_api.g_varchar2
  ,p_contr_information1             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information2             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information3             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information4             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information5             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information6             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information7             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information8             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information9             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information10            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information11            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information12            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information13            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information14            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information15            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information16            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information17            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information18            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information19            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information20            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information21            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information22            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information23            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information24            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information25            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information26            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information27            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information28            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information29            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information30            in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Contribution_History';
  l_object_version_number pay_us_contribution_history.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Contribution_History;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Contribution_History
    --
    pay_Contribution_History_bk2.update_Contribution_History_b
      (
       p_contr_history_id               =>  p_contr_history_id
      ,p_person_id                      =>  p_person_id
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_contr_type                     =>  p_contr_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_amt_contr                      =>  p_amt_contr
      ,p_max_contr_allowed              =>  p_max_contr_allowed
      ,p_includable_comp                =>  p_includable_comp
      ,p_tax_unit_id                    =>  p_tax_unit_id
      ,p_source_system                  =>  p_source_system
      ,p_contr_information_category     =>  p_contr_information_category
      ,p_contr_information1             =>  p_contr_information1
      ,p_contr_information2             =>  p_contr_information2
      ,p_contr_information3             =>  p_contr_information3
      ,p_contr_information4             =>  p_contr_information4
      ,p_contr_information5             =>  p_contr_information5
      ,p_contr_information6             =>  p_contr_information6
      ,p_contr_information7             =>  p_contr_information7
      ,p_contr_information8             =>  p_contr_information8
      ,p_contr_information9             =>  p_contr_information9
      ,p_contr_information10            =>  p_contr_information10
      ,p_contr_information11            =>  p_contr_information11
      ,p_contr_information12            =>  p_contr_information12
      ,p_contr_information13            =>  p_contr_information13
      ,p_contr_information14            =>  p_contr_information14
      ,p_contr_information15            =>  p_contr_information15
      ,p_contr_information16            =>  p_contr_information16
      ,p_contr_information17            =>  p_contr_information17
      ,p_contr_information18            =>  p_contr_information18
      ,p_contr_information19            =>  p_contr_information19
      ,p_contr_information20            =>  p_contr_information20
      ,p_contr_information21            =>  p_contr_information21
      ,p_contr_information22            =>  p_contr_information22
      ,p_contr_information23            =>  p_contr_information23
      ,p_contr_information24            =>  p_contr_information24
      ,p_contr_information25            =>  p_contr_information25
      ,p_contr_information26            =>  p_contr_information26
      ,p_contr_information27            =>  p_contr_information27
      ,p_contr_information28            =>  p_contr_information28
      ,p_contr_information29            =>  p_contr_information29
      ,p_contr_information30            =>  p_contr_information30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Contribution_History'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Contribution_History
    --
  end;
  --
  pay_con_upd.upd
    (
     p_contr_history_id              => p_contr_history_id
    ,p_person_id                     => p_person_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_contr_type                    => p_contr_type
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_amt_contr                     => p_amt_contr
    ,p_max_contr_allowed             => p_max_contr_allowed
    ,p_includable_comp               => p_includable_comp
    ,p_tax_unit_id                   => p_tax_unit_id
    ,p_source_system                 => p_source_system
    ,p_contr_information_category    => p_contr_information_category
    ,p_contr_information1            => p_contr_information1
    ,p_contr_information2            => p_contr_information2
    ,p_contr_information3            => p_contr_information3
    ,p_contr_information4            => p_contr_information4
    ,p_contr_information5            => p_contr_information5
    ,p_contr_information6            => p_contr_information6
    ,p_contr_information7            => p_contr_information7
    ,p_contr_information8            => p_contr_information8
    ,p_contr_information9            => p_contr_information9
    ,p_contr_information10           => p_contr_information10
    ,p_contr_information11           => p_contr_information11
    ,p_contr_information12           => p_contr_information12
    ,p_contr_information13           => p_contr_information13
    ,p_contr_information14           => p_contr_information14
    ,p_contr_information15           => p_contr_information15
    ,p_contr_information16           => p_contr_information16
    ,p_contr_information17           => p_contr_information17
    ,p_contr_information18           => p_contr_information18
    ,p_contr_information19           => p_contr_information19
    ,p_contr_information20           => p_contr_information20
    ,p_contr_information21           => p_contr_information21
    ,p_contr_information22           => p_contr_information22
    ,p_contr_information23           => p_contr_information23
    ,p_contr_information24           => p_contr_information24
    ,p_contr_information25           => p_contr_information25
    ,p_contr_information26           => p_contr_information26
    ,p_contr_information27           => p_contr_information27
    ,p_contr_information28           => p_contr_information28
    ,p_contr_information29           => p_contr_information29
    ,p_contr_information30           => p_contr_information30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Contribution_History
    --
    pay_Contribution_History_bk2.update_Contribution_History_a
      (
       p_contr_history_id               =>  p_contr_history_id
      ,p_person_id                      =>  p_person_id
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_contr_type                     =>  p_contr_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_amt_contr                      =>  p_amt_contr
      ,p_max_contr_allowed              =>  p_max_contr_allowed
      ,p_includable_comp                =>  p_includable_comp
      ,p_tax_unit_id                    =>  p_tax_unit_id
      ,p_source_system                  =>  p_source_system
      ,p_contr_information_category     =>  p_contr_information_category
      ,p_contr_information1             =>  p_contr_information1
      ,p_contr_information2             =>  p_contr_information2
      ,p_contr_information3             =>  p_contr_information3
      ,p_contr_information4             =>  p_contr_information4
      ,p_contr_information5             =>  p_contr_information5
      ,p_contr_information6             =>  p_contr_information6
      ,p_contr_information7             =>  p_contr_information7
      ,p_contr_information8             =>  p_contr_information8
      ,p_contr_information9             =>  p_contr_information9
      ,p_contr_information10            =>  p_contr_information10
      ,p_contr_information11            =>  p_contr_information11
      ,p_contr_information12            =>  p_contr_information12
      ,p_contr_information13            =>  p_contr_information13
      ,p_contr_information14            =>  p_contr_information14
      ,p_contr_information15            =>  p_contr_information15
      ,p_contr_information16            =>  p_contr_information16
      ,p_contr_information17            =>  p_contr_information17
      ,p_contr_information18            =>  p_contr_information18
      ,p_contr_information19            =>  p_contr_information19
      ,p_contr_information20            =>  p_contr_information20
      ,p_contr_information21            =>  p_contr_information21
      ,p_contr_information22            =>  p_contr_information22
      ,p_contr_information23            =>  p_contr_information23
      ,p_contr_information24            =>  p_contr_information24
      ,p_contr_information25            =>  p_contr_information25
      ,p_contr_information26            =>  p_contr_information26
      ,p_contr_information27            =>  p_contr_information27
      ,p_contr_information28            =>  p_contr_information28
      ,p_contr_information29            =>  p_contr_information29
      ,p_contr_information30            =>  p_contr_information30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Contribution_History'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Contribution_History
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
    ROLLBACK TO update_Contribution_History;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_Contribution_History;
    raise;
    --
end update_Contribution_History;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Contribution_History >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Contribution_History
  (p_validate                       in  boolean  default false
  ,p_contr_history_id               in  number
  ,p_object_version_number          in out number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Contribution_History';
  l_object_version_number pay_us_contribution_history.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Contribution_History;
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
    -- Start of API User Hook for the before hook of delete_Contribution_History
    --
    pay_Contribution_History_bk3.delete_Contribution_History_b
      (
       p_contr_history_id               =>  p_contr_history_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Contribution_History'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Contribution_History
    --
  end;
  --
  pay_con_del.del
    (
     p_contr_history_id              => p_contr_history_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Contribution_History
    --
    pay_Contribution_History_bk3.delete_Contribution_History_a
      (
       p_contr_history_id               =>  p_contr_history_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Contribution_History'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Contribution_History
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_Contribution_History;
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
    ROLLBACK TO delete_Contribution_History;
    raise;
    --
end delete_Contribution_History;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_contr_history_id                   in     number
  ,p_object_version_number          in     number
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
  pay_con_shd.lck
    (
      p_contr_history_id                 => p_contr_history_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pay_Contribution_History_api;

/
