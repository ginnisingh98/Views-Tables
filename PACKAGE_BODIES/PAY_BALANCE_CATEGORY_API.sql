--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_CATEGORY_API" as
/* $Header: pypbcapi.pkb 120.0 2005/05/29 07:18:50 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_balance_category_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_balance_category >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_category_name                 in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_save_run_balance_enabled      in     varchar2 default null
  ,p_user_category_name            in     varchar2 default null
  ,p_pbc_information_category      in     varchar2 default null
  ,p_pbc_information1              in     varchar2 default null
  ,p_pbc_information2              in     varchar2 default null
  ,p_pbc_information3              in     varchar2 default null
  ,p_pbc_information4              in     varchar2 default null
  ,p_pbc_information5              in     varchar2 default null
  ,p_pbc_information6              in     varchar2 default null
  ,p_pbc_information7              in     varchar2 default null
  ,p_pbc_information8              in     varchar2 default null
  ,p_pbc_information9              in     varchar2 default null
  ,p_pbc_information10             in     varchar2 default null
  ,p_pbc_information11             in     varchar2 default null
  ,p_pbc_information12             in     varchar2 default null
  ,p_pbc_information13             in     varchar2 default null
  ,p_pbc_information14             in     varchar2 default null
  ,p_pbc_information15             in     varchar2 default null
  ,p_pbc_information16             in     varchar2 default null
  ,p_pbc_information17             in     varchar2 default null
  ,p_pbc_information18             in     varchar2 default null
  ,p_pbc_information19             in     varchar2 default null
  ,p_pbc_information20             in     varchar2 default null
  ,p_pbc_information21             in     varchar2 default null
  ,p_pbc_information22             in     varchar2 default null
  ,p_pbc_information23             in     varchar2 default null
  ,p_pbc_information24             in     varchar2 default null
  ,p_pbc_information25             in     varchar2 default null
  ,p_pbc_information26             in     varchar2 default null
  ,p_pbc_information27             in     varchar2 default null
  ,p_pbc_information28             in     varchar2 default null
  ,p_pbc_information29             in     varchar2 default null
  ,p_pbc_information30             in     varchar2 default null
  ,p_balance_category_id              out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_balance_category';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_balance_category_id    pay_balance_categories_f.balance_category_id%TYPE;
  l_object_version_number  pay_balance_categories_f.object_version_number%TYPE;
  l_effective_start_date   pay_balance_categories_f.effective_start_date%TYPE;
  l_effective_end_date     pay_balance_categories_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_balance_category;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_balance_category_bk1.create_balance_category_b
      (p_effective_date           => l_effective_date
      ,p_category_name            => p_category_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_save_run_balance_enabled => p_save_run_balance_enabled
      ,p_user_category_name       => p_user_category_name
      ,p_pbc_information_category => p_pbc_information_category
      ,p_pbc_information1         => p_pbc_information1
      ,p_pbc_information2         => p_pbc_information2
      ,p_pbc_information3         => p_pbc_information3
      ,p_pbc_information4         => p_pbc_information4
      ,p_pbc_information5         => p_pbc_information5
      ,p_pbc_information6         => p_pbc_information6
      ,p_pbc_information7         => p_pbc_information7
      ,p_pbc_information8         => p_pbc_information8
      ,p_pbc_information9         => p_pbc_information9
      ,p_pbc_information10        => p_pbc_information10
      ,p_pbc_information11        => p_pbc_information11
      ,p_pbc_information12        => p_pbc_information12
      ,p_pbc_information13        => p_pbc_information13
      ,p_pbc_information14        => p_pbc_information14
      ,p_pbc_information15        => p_pbc_information15
      ,p_pbc_information16        => p_pbc_information16
      ,p_pbc_information17        => p_pbc_information17
      ,p_pbc_information18        => p_pbc_information18
      ,p_pbc_information19        => p_pbc_information19
      ,p_pbc_information20        => p_pbc_information20
      ,p_pbc_information21        => p_pbc_information21
      ,p_pbc_information22        => p_pbc_information22
      ,p_pbc_information23        => p_pbc_information23
      ,p_pbc_information24        => p_pbc_information24
      ,p_pbc_information25        => p_pbc_information25
      ,p_pbc_information26        => p_pbc_information26
      ,p_pbc_information27        => p_pbc_information27
      ,p_pbc_information28        => p_pbc_information28
      ,p_pbc_information29        => p_pbc_information29
      ,p_pbc_information30        => p_pbc_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_category'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  pay_pbc_ins.ins
     (p_effective_date           => l_effective_date
     ,p_category_name            => p_category_name
     ,p_business_group_id        => p_business_group_id
     ,p_legislation_code         => p_legislation_code
     ,p_save_run_balance_enabled => p_save_run_balance_enabled
     ,p_user_category_name       => p_user_category_name
     ,p_pbc_information_category => p_pbc_information_category
     ,p_pbc_information1         => p_pbc_information1
     ,p_pbc_information2         => p_pbc_information2
     ,p_pbc_information3         => p_pbc_information3
     ,p_pbc_information4         => p_pbc_information4
     ,p_pbc_information5         => p_pbc_information5
     ,p_pbc_information6         => p_pbc_information6
     ,p_pbc_information7         => p_pbc_information7
     ,p_pbc_information8         => p_pbc_information8
     ,p_pbc_information9         => p_pbc_information9
     ,p_pbc_information10        => p_pbc_information10
     ,p_pbc_information11        => p_pbc_information11
     ,p_pbc_information12        => p_pbc_information12
     ,p_pbc_information13        => p_pbc_information13
     ,p_pbc_information14        => p_pbc_information14
     ,p_pbc_information15        => p_pbc_information15
     ,p_pbc_information16        => p_pbc_information16
     ,p_pbc_information17        => p_pbc_information17
     ,p_pbc_information18        => p_pbc_information18
     ,p_pbc_information19        => p_pbc_information19
     ,p_pbc_information20        => p_pbc_information20
     ,p_pbc_information21        => p_pbc_information21
     ,p_pbc_information22        => p_pbc_information22
     ,p_pbc_information23        => p_pbc_information23
     ,p_pbc_information24        => p_pbc_information24
     ,p_pbc_information25        => p_pbc_information25
     ,p_pbc_information26        => p_pbc_information26
     ,p_pbc_information27        => p_pbc_information27
     ,p_pbc_information28        => p_pbc_information28
     ,p_pbc_information29        => p_pbc_information29
     ,p_pbc_information30        => p_pbc_information30
     ,p_balance_category_id      => l_balance_category_id
     ,p_object_version_number    => l_object_version_number
     ,p_effective_start_date     => l_effective_start_date
     ,p_effective_end_date       => l_effective_end_date
     );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_balance_category_bk1.create_balance_category_a
      (p_effective_date           => l_effective_date
      ,p_category_name            => p_category_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_save_run_balance_enabled => p_save_run_balance_enabled
      ,p_user_category_name       => p_user_category_name
      ,p_pbc_information_category => p_pbc_information_category
      ,p_pbc_information1         => p_pbc_information1
      ,p_pbc_information2         => p_pbc_information2
      ,p_pbc_information3         => p_pbc_information3
      ,p_pbc_information4         => p_pbc_information4
      ,p_pbc_information5         => p_pbc_information5
      ,p_pbc_information6         => p_pbc_information6
      ,p_pbc_information7         => p_pbc_information7
      ,p_pbc_information8         => p_pbc_information8
      ,p_pbc_information9         => p_pbc_information9
      ,p_pbc_information10        => p_pbc_information10
      ,p_pbc_information11        => p_pbc_information11
      ,p_pbc_information12        => p_pbc_information12
      ,p_pbc_information13        => p_pbc_information13
      ,p_pbc_information14        => p_pbc_information14
      ,p_pbc_information15        => p_pbc_information15
      ,p_pbc_information16        => p_pbc_information16
      ,p_pbc_information17        => p_pbc_information17
      ,p_pbc_information18        => p_pbc_information18
      ,p_pbc_information19        => p_pbc_information19
      ,p_pbc_information20        => p_pbc_information20
      ,p_pbc_information21        => p_pbc_information21
      ,p_pbc_information22        => p_pbc_information22
      ,p_pbc_information23        => p_pbc_information23
      ,p_pbc_information24        => p_pbc_information24
      ,p_pbc_information25        => p_pbc_information25
      ,p_pbc_information26        => p_pbc_information26
      ,p_pbc_information27        => p_pbc_information27
      ,p_pbc_information28        => p_pbc_information28
      ,p_pbc_information29        => p_pbc_information29
      ,p_pbc_information30        => p_pbc_information30
      ,p_balance_category_id      => l_balance_category_id
      ,p_effective_start_date     => l_effective_start_date
      ,p_effective_end_date       => l_effective_end_date
      ,p_object_version_number    => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_category_a'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_balance_category_id    := l_balance_category_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --
g_dml_status := TRUE;
--For MLS-----------------------------------------------------------------------
pay_tbc_ins.ins_tl(userenv('lang'),p_balance_category_id,p_user_category_name);
--------------------------------------------------------------------------------
g_dml_status := FALSE;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_balance_category;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_category_id    := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_balance_category;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    g_dml_status := FALSE;
    raise;
end create_balance_category;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_balance_category >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_balance_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_save_run_balance_enabled      in     varchar2 default hr_api.g_varchar2
  ,p_user_category_name            in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pbc_information30             in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_balance_category';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date     pay_run_types_f.effective_start_date%TYPE;
  l_effective_end_date       pay_run_types_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variable
  --
  l_object_version_number    pay_run_types_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  l_object_version_number := p_object_version_number;
  savepoint update_balance_category;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_balance_category_bk2.update_balance_category_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_balance_category_id           => p_balance_category_id
      ,p_object_version_number         => p_object_version_number
      ,p_save_run_balance_enabled      => p_save_run_balance_enabled
      ,p_user_category_name            => p_user_category_name
      ,p_pbc_information_category      => p_pbc_information_category
      ,p_pbc_information1              => p_pbc_information1
      ,p_pbc_information2              => p_pbc_information2
      ,p_pbc_information3              => p_pbc_information3
      ,p_pbc_information4              => p_pbc_information4
      ,p_pbc_information5              => p_pbc_information5
      ,p_pbc_information6              => p_pbc_information6
      ,p_pbc_information7              => p_pbc_information7
      ,p_pbc_information8              => p_pbc_information8
      ,p_pbc_information9              => p_pbc_information9
      ,p_pbc_information10             => p_pbc_information10
      ,p_pbc_information11             => p_pbc_information11
      ,p_pbc_information12             => p_pbc_information12
      ,p_pbc_information13             => p_pbc_information13
      ,p_pbc_information14             => p_pbc_information14
      ,p_pbc_information15             => p_pbc_information15
      ,p_pbc_information16             => p_pbc_information16
      ,p_pbc_information17             => p_pbc_information17
      ,p_pbc_information18             => p_pbc_information18
      ,p_pbc_information19             => p_pbc_information19
      ,p_pbc_information20             => p_pbc_information20
      ,p_pbc_information21             => p_pbc_information21
      ,p_pbc_information22             => p_pbc_information22
      ,p_pbc_information23             => p_pbc_information23
      ,p_pbc_information24             => p_pbc_information24
      ,p_pbc_information25             => p_pbc_information25
      ,p_pbc_information26             => p_pbc_information26
      ,p_pbc_information27             => p_pbc_information27
      ,p_pbc_information28             => p_pbc_information28
      ,p_pbc_information29             => p_pbc_information29
      ,p_pbc_information30             => p_pbc_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_balance_category'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
    pay_pbc_upd.upd
      (p_effective_date                => l_effective_date
      ,p_datetrack_mode                => p_datetrack_update_mode
      ,p_balance_category_id           => p_balance_category_id
      ,p_object_version_number         => p_object_version_number
      ,p_save_run_balance_enabled      => p_save_run_balance_enabled
      ,p_user_category_name            => p_user_category_name
      ,p_pbc_information_category      => p_pbc_information_category
      ,p_pbc_information1              => p_pbc_information1
      ,p_pbc_information2              => p_pbc_information2
      ,p_pbc_information3              => p_pbc_information3
      ,p_pbc_information4              => p_pbc_information4
      ,p_pbc_information5              => p_pbc_information5
      ,p_pbc_information6              => p_pbc_information6
      ,p_pbc_information7              => p_pbc_information7
      ,p_pbc_information8              => p_pbc_information8
      ,p_pbc_information9              => p_pbc_information9
      ,p_pbc_information10             => p_pbc_information10
      ,p_pbc_information11             => p_pbc_information11
      ,p_pbc_information12             => p_pbc_information12
      ,p_pbc_information13             => p_pbc_information13
      ,p_pbc_information14             => p_pbc_information14
      ,p_pbc_information15             => p_pbc_information15
      ,p_pbc_information16             => p_pbc_information16
      ,p_pbc_information17             => p_pbc_information17
      ,p_pbc_information18             => p_pbc_information18
      ,p_pbc_information19             => p_pbc_information19
      ,p_pbc_information20             => p_pbc_information20
      ,p_pbc_information21             => p_pbc_information21
      ,p_pbc_information22             => p_pbc_information22
      ,p_pbc_information23             => p_pbc_information23
      ,p_pbc_information24             => p_pbc_information24
      ,p_pbc_information25             => p_pbc_information25
      ,p_pbc_information26             => p_pbc_information26
      ,p_pbc_information27             => p_pbc_information27
      ,p_pbc_information28             => p_pbc_information28
      ,p_pbc_information29             => p_pbc_information29
      ,p_pbc_information30             => p_pbc_information30
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_balance_category_bk2.update_balance_category_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_balance_category_id           => p_balance_category_id
      ,p_object_version_number         => p_object_version_number
      ,p_save_run_balance_enabled      => p_save_run_balance_enabled
      ,p_user_category_name            => p_user_category_name
      ,p_pbc_information_category      => p_pbc_information_category
      ,p_pbc_information1              => p_pbc_information1
      ,p_pbc_information2              => p_pbc_information2
      ,p_pbc_information3              => p_pbc_information3
      ,p_pbc_information4              => p_pbc_information4
      ,p_pbc_information5              => p_pbc_information5
      ,p_pbc_information6              => p_pbc_information6
      ,p_pbc_information7              => p_pbc_information7
      ,p_pbc_information8              => p_pbc_information8
      ,p_pbc_information9              => p_pbc_information9
      ,p_pbc_information10             => p_pbc_information10
      ,p_pbc_information11             => p_pbc_information11
      ,p_pbc_information12             => p_pbc_information12
      ,p_pbc_information13             => p_pbc_information13
      ,p_pbc_information14             => p_pbc_information14
      ,p_pbc_information15             => p_pbc_information15
      ,p_pbc_information16             => p_pbc_information16
      ,p_pbc_information17             => p_pbc_information17
      ,p_pbc_information18             => p_pbc_information18
      ,p_pbc_information19             => p_pbc_information19
      ,p_pbc_information20             => p_pbc_information20
      ,p_pbc_information21             => p_pbc_information21
      ,p_pbc_information22             => p_pbc_information22
      ,p_pbc_information23             => p_pbc_information23
      ,p_pbc_information24             => p_pbc_information24
      ,p_pbc_information25             => p_pbc_information25
      ,p_pbc_information26             => p_pbc_information26
      ,p_pbc_information27             => p_pbc_information27
      ,p_pbc_information28             => p_pbc_information28
      ,p_pbc_information29             => p_pbc_information29
      ,p_pbc_information30             => p_pbc_information30
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_balance_category'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := p_object_version_number;
  --
  g_dml_status := TRUE;
--For MLS-----------------------------------------------------------------------
pay_tbc_upd.upd_tl(userenv('lang'),p_balance_category_id,p_user_category_name);
--------------------------------------------------------------------------------
g_dml_status := FALSE;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to pay_balance_category;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_balance_category;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    g_dml_status := FALSE;
    raise;
end update_balance_category;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_balance_category >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_category
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := g_package||'delete_balance_category';
  l_effective_date     date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date  pay_balance_categories_f.effective_start_date%type;
  l_effective_end_date    pay_balance_categories_f.effective_end_date%type;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_version_number pay_balance_categories_f.object_version_number%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint and assign in-out parameters to local variable
  --
  savepoint delete_balance_category;
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 10);
  --
    l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_balance_category_bk3.delete_balance_category_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_balance_category_id           => p_balance_category_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_balance_category'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
    hr_utility.set_location(l_proc, 30);
  --
begin
  g_dml_status := TRUE;
--For MLS-----------------------------------------------------------------------
pay_tbc_del.del_tl(p_balance_category_id);
--------------------------------------------------------------------------------
g_dml_status := FALSE;
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
end;

  -- Call the row handler to delete the balance category
  --
    pay_pbc_del.del
       (p_effective_date        => l_effective_date
       ,p_datetrack_mode        => p_datetrack_delete_mode
       ,p_balance_category_id   => p_balance_category_id
       ,p_object_version_number => p_object_version_number
       ,p_effective_start_date  => l_effective_start_date
       ,p_effective_end_date    => l_effective_end_date
       );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Call After Process User Hook
  --
  begin
   pay_balance_category_bk3.delete_balance_category_a
      (p_effective_date        => l_effective_date
      ,p_datetrack_delete_mode => p_datetrack_delete_mode
      ,p_balance_category_id   => p_balance_category_id
      ,p_object_version_number => p_object_version_number
      ,p_business_group_id     => p_business_group_id
      ,p_legislation_code      => p_legislation_code
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_balance_category'
        ,p_hook_type   => 'AP'
        );
  end;
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
    p_object_version_number := p_object_version_number;
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
    rollback to delete_balance_category;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_balance_category;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_balance_category;
--
function return_dml_status
return boolean
IS
begin
return g_dml_status;
end return_dml_status;
--

end PAY_BALANCE_CATEGORY_API;

/
