--------------------------------------------------------
--  DDL for Package Body PQP_SHP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SHP_API" as
/* $Header: pqshpapi.pkb 115.4 2003/01/22 00:56:53 tmehra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_shp_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_service_history_period >--------------------|
-- ----------------------------------------------------------------------------
--
-- Default all null columns for FF
--
procedure create_service_history_period
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_employer_name                 in     varchar2 default null
  ,p_employer_address              in     varchar2 default null
  ,p_employer_type                 in     varchar2 default null
  ,p_employer_subtype              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_continuous_service            in     varchar2 default null
  ,p_all_assignments               in     varchar2 default null
  ,p_period_years                  in     number   default null
  ,p_period_days                   in     number   default null
  ,p_shp_attribute_category        in     varchar2 default null
  ,p_shp_attribute1                in     varchar2 default null
  ,p_shp_attribute2                in     varchar2 default null
  ,p_shp_attribute3                in     varchar2 default null
  ,p_shp_attribute4                in     varchar2 default null
  ,p_shp_attribute5                in     varchar2 default null
  ,p_shp_attribute6                in     varchar2 default null
  ,p_shp_attribute7                in     varchar2 default null
  ,p_shp_attribute8                in     varchar2 default null
  ,p_shp_attribute9                in     varchar2 default null
  ,p_shp_attribute10               in     varchar2 default null
  ,p_shp_attribute11               in     varchar2 default null
  ,p_shp_attribute12               in     varchar2 default null
  ,p_shp_attribute13               in     varchar2 default null
  ,p_shp_attribute14               in     varchar2 default null
  ,p_shp_attribute15               in     varchar2 default null
  ,p_shp_attribute16               in     varchar2 default null
  ,p_shp_attribute17               in     varchar2 default null
  ,p_shp_attribute18               in     varchar2 default null
  ,p_shp_attribute19               in     varchar2 default null
  ,p_shp_attribute20               in     varchar2 default null
  ,p_shp_information_category      in     varchar2 default null
  ,p_shp_information1              in     varchar2 default null
  ,p_shp_information2              in     varchar2 default null
  ,p_shp_information3              in     varchar2 default null
  ,p_shp_information4              in     varchar2 default null
  ,p_shp_information5              in     varchar2 default null
  ,p_shp_information6              in     varchar2 default null
  ,p_shp_information7              in     varchar2 default null
  ,p_shp_information8              in     varchar2 default null
  ,p_shp_information9              in     varchar2 default null
  ,p_shp_information10             in     varchar2 default null
  ,p_shp_information11             in     varchar2 default null
  ,p_shp_information12             in     varchar2 default null
  ,p_shp_information13             in     varchar2 default null
  ,p_shp_information14             in     varchar2 default null
  ,p_shp_information15             in     varchar2 default null
  ,p_shp_information16             in     varchar2 default null
  ,p_shp_information17             in     varchar2 default null
  ,p_shp_information18             in     varchar2 default null
  ,p_shp_information19             in     varchar2 default null
  ,p_shp_information20             in     varchar2 default null
  ,p_service_history_period_id        out nocopy number
  ,p_object_version_number            out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                       varchar2(72) := g_package||'create_service_history_period';
  l_service_history_period_id  number;
  l_object_version_number      number;
  l_start_date                 date;
  l_end_date                   date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_service_history_period;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pqp_service_history_period_bk1.create_pqp_service_hist_pd_b
      (p_business_group_id   => p_business_group_id
      ,p_assignment_id       => p_assignment_id
      ,p_start_date          => l_start_date
      ,p_end_date            => l_end_date
      ,p_employer_name       => p_employer_name
      ,p_employer_address    => p_employer_address
      ,p_employer_type       => p_employer_type
      ,p_employer_subtype    => p_employer_subtype
      ,p_description         => p_description
      ,p_continuous_service  => p_continuous_service
      ,p_all_assignments     => p_all_assignments
      ,p_period_years        => p_period_years
      ,p_period_days         => p_period_days
      ,p_shp_attribute_category => p_shp_attribute_category
      ,p_shp_attribute1      => p_shp_attribute1
      ,p_shp_attribute2      => p_shp_attribute2
      ,p_shp_attribute3      => p_shp_attribute3
      ,p_shp_attribute4      => p_shp_attribute4
      ,p_shp_attribute5      => p_shp_attribute5
      ,p_shp_attribute6      => p_shp_attribute6
      ,p_shp_attribute7      => p_shp_attribute7
      ,p_shp_attribute8      => p_shp_attribute8
      ,p_shp_attribute9      => p_shp_attribute9
      ,p_shp_attribute10     => p_shp_attribute10
      ,p_shp_attribute11     => p_shp_attribute11
      ,p_shp_attribute12     => p_shp_attribute12
      ,p_shp_attribute13     => p_shp_attribute13
      ,p_shp_attribute14     => p_shp_attribute14
      ,p_shp_attribute15     => p_shp_attribute15
      ,p_shp_attribute16     => p_shp_attribute16
      ,p_shp_attribute17     => p_shp_attribute17
      ,p_shp_attribute18     => p_shp_attribute18
      ,p_shp_attribute19     => p_shp_attribute19
      ,p_shp_attribute20     => p_shp_attribute20
      ,p_shp_information_category => p_shp_information_category
      ,p_shp_information1    => p_shp_information1
      ,p_shp_information2    => p_shp_information2
      ,p_shp_information3    => p_shp_information3
      ,p_shp_information4    => p_shp_information4
      ,p_shp_information5    => p_shp_information5
      ,p_shp_information6    => p_shp_information6
      ,p_shp_information7    => p_shp_information7
      ,p_shp_information8    => p_shp_information8
      ,p_shp_information9    => p_shp_information9
      ,p_shp_information10   => p_shp_information10
      ,p_shp_information11   => p_shp_information11
      ,p_shp_information12   => p_shp_information12
      ,p_shp_information13   => p_shp_information13
      ,p_shp_information14   => p_shp_information14
      ,p_shp_information15   => p_shp_information15
      ,p_shp_information16   => p_shp_information16
      ,p_shp_information17   => p_shp_information17
      ,p_shp_information18   => p_shp_information18
      ,p_shp_information19   => p_shp_information19
      ,p_shp_information20   => p_shp_information20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_service_history_period'
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


  pqp_shp_ins.ins (
       p_business_group_id            => p_business_group_id
      ,p_assignment_id                => p_assignment_id
      ,p_start_date                   => l_start_date
      ,p_end_date                     => l_end_date
      ,p_employer_name                => p_employer_name
      ,p_employer_address             => p_employer_address
      ,p_employer_type                => p_employer_type
      ,p_employer_subtype             => p_employer_subtype
      ,p_description                  => p_description
      ,p_continuous_service           => p_continuous_service
      ,p_all_assignments              => p_all_assignments
      ,p_period_years                 => p_period_years
      ,p_period_days                  => p_period_days
      ,p_service_history_period_id    => l_service_history_period_id
      ,p_object_version_number        => l_object_version_number
      ,p_shp_attribute_category => p_shp_attribute_category
      ,p_shp_attribute1      => p_shp_attribute1
      ,p_shp_attribute2      => p_shp_attribute2
      ,p_shp_attribute3      => p_shp_attribute3
      ,p_shp_attribute4      => p_shp_attribute4
      ,p_shp_attribute5      => p_shp_attribute5
      ,p_shp_attribute6      => p_shp_attribute6
      ,p_shp_attribute7      => p_shp_attribute7
      ,p_shp_attribute8      => p_shp_attribute8
      ,p_shp_attribute9      => p_shp_attribute9
      ,p_shp_attribute10     => p_shp_attribute10
      ,p_shp_attribute11     => p_shp_attribute11
      ,p_shp_attribute12     => p_shp_attribute12
      ,p_shp_attribute13     => p_shp_attribute13
      ,p_shp_attribute14     => p_shp_attribute14
      ,p_shp_attribute15     => p_shp_attribute15
      ,p_shp_attribute16     => p_shp_attribute16
      ,p_shp_attribute17     => p_shp_attribute17
      ,p_shp_attribute18     => p_shp_attribute18
      ,p_shp_attribute19     => p_shp_attribute19
      ,p_shp_attribute20     => p_shp_attribute20
      ,p_shp_information_category => p_shp_information_category
      ,p_shp_information1    => p_shp_information1
      ,p_shp_information2    => p_shp_information2
      ,p_shp_information3    => p_shp_information3
      ,p_shp_information4    => p_shp_information4
      ,p_shp_information5    => p_shp_information5
      ,p_shp_information6    => p_shp_information6
      ,p_shp_information7    => p_shp_information7
      ,p_shp_information8    => p_shp_information8
      ,p_shp_information9    => p_shp_information9
      ,p_shp_information10   => p_shp_information10
      ,p_shp_information11   => p_shp_information11
      ,p_shp_information12   => p_shp_information12
      ,p_shp_information13   => p_shp_information13
      ,p_shp_information14   => p_shp_information14
      ,p_shp_information15   => p_shp_information15
      ,p_shp_information16   => p_shp_information16
      ,p_shp_information17   => p_shp_information17
      ,p_shp_information18   => p_shp_information18
      ,p_shp_information19   => p_shp_information19
      ,p_shp_information20   => p_shp_information20
      );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_service_history_period_bk1.create_pqp_service_hist_pd_a
      (p_business_group_id           => p_business_group_id
      ,p_assignment_id               => p_assignment_id
      ,p_start_date                  => l_start_date
      ,p_end_date                    => l_end_date
      ,p_employer_name               => p_employer_name
      ,p_employer_address            => p_employer_address
      ,p_employer_type               => p_employer_type
      ,p_employer_subtype            => p_employer_subtype
      ,p_description                 => p_description
      ,p_continuous_service          => p_continuous_service
      ,p_all_assignments             => p_all_assignments
      ,p_period_years                => p_period_years
      ,p_period_days                 => p_period_days
      ,p_service_history_period_id   => l_service_history_period_id
      ,p_object_version_number       => l_object_version_number
      ,p_shp_attribute_category => p_shp_attribute_category
      ,p_shp_attribute1      => p_shp_attribute1
      ,p_shp_attribute2      => p_shp_attribute2
      ,p_shp_attribute3      => p_shp_attribute3
      ,p_shp_attribute4      => p_shp_attribute4
      ,p_shp_attribute5      => p_shp_attribute5
      ,p_shp_attribute6      => p_shp_attribute6
      ,p_shp_attribute7      => p_shp_attribute7
      ,p_shp_attribute8      => p_shp_attribute8
      ,p_shp_attribute9      => p_shp_attribute9
      ,p_shp_attribute10     => p_shp_attribute10
      ,p_shp_attribute11     => p_shp_attribute11
      ,p_shp_attribute12     => p_shp_attribute12
      ,p_shp_attribute13     => p_shp_attribute13
      ,p_shp_attribute14     => p_shp_attribute14
      ,p_shp_attribute15     => p_shp_attribute15
      ,p_shp_attribute16     => p_shp_attribute16
      ,p_shp_attribute17     => p_shp_attribute17
      ,p_shp_attribute18     => p_shp_attribute18
      ,p_shp_attribute19     => p_shp_attribute19
      ,p_shp_attribute20     => p_shp_attribute20
      ,p_shp_information_category => p_shp_information_category
      ,p_shp_information1    => p_shp_information1
      ,p_shp_information2    => p_shp_information2
      ,p_shp_information3    => p_shp_information3
      ,p_shp_information4    => p_shp_information4
      ,p_shp_information5    => p_shp_information5
      ,p_shp_information6    => p_shp_information6
      ,p_shp_information7    => p_shp_information7
      ,p_shp_information8    => p_shp_information8
      ,p_shp_information9    => p_shp_information9
      ,p_shp_information10   => p_shp_information10
      ,p_shp_information11   => p_shp_information11
      ,p_shp_information12   => p_shp_information12
      ,p_shp_information13   => p_shp_information13
      ,p_shp_information14   => p_shp_information14
      ,p_shp_information15   => p_shp_information15
      ,p_shp_information16   => p_shp_information16
      ,p_shp_information17   => p_shp_information17
      ,p_shp_information18   => p_shp_information18
      ,p_shp_information19   => p_shp_information19
      ,p_shp_information20   => p_shp_information20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_service_history_period'
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
  p_service_history_period_id  := l_service_history_period_id;
  p_object_version_number      := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_service_history_period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_service_history_period_id  := null;
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_service_history_period;
    p_service_history_period_id  := null;
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_service_history_period;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_service_history_period >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_service_history_period
  (p_validate                      in     boolean  default false
  ,p_service_history_period_id     in     number
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_employer_name                 in     varchar2 default hr_api.g_varchar2
  ,p_employer_address              in     varchar2 default hr_api.g_varchar2
  ,p_employer_type                 in     varchar2 default hr_api.g_varchar2
  ,p_employer_subtype              in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_continuous_service            in     varchar2 default hr_api.g_varchar2
  ,p_all_assignments               in     varchar2 default hr_api.g_varchar2
  ,p_period_years                  in     number   default hr_api.g_number
  ,p_period_days                   in     number   default hr_api.g_number
  ,p_shp_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_shp_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_shp_information1              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information2              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information3              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information4              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information5              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information6              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information7              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information8              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information9              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information10             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information11             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information12             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information13             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information14             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information15             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information16             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information17             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information18             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information19             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information20             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_service_history_period';
  l_object_version_number      number;
  l_start_date                 date;
  l_end_date                   date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_service_history_period;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pqp_service_history_period_bk2.update_pqp_service_hist_pd_b
      (p_service_history_period_id  => p_service_history_period_id
      ,p_assignment_id              => p_assignment_id
      ,p_start_date                 => l_start_date
      ,p_end_date                   => l_end_date
      ,p_employer_name              => p_employer_name
      ,p_employer_address           => p_employer_address
      ,p_employer_type              => p_employer_type
      ,p_employer_subtype           => p_employer_subtype
      ,p_description                => p_description
      ,p_continuous_service         => p_continuous_service
      ,p_all_assignments            => p_all_assignments
      ,p_period_years               => p_period_years
      ,p_period_days                => p_period_days
      ,p_object_version_number      => p_object_version_number
      ,p_shp_attribute_category => p_shp_attribute_category
      ,p_shp_attribute1      => p_shp_attribute1
      ,p_shp_attribute2      => p_shp_attribute2
      ,p_shp_attribute3      => p_shp_attribute3
      ,p_shp_attribute4      => p_shp_attribute4
      ,p_shp_attribute5      => p_shp_attribute5
      ,p_shp_attribute6      => p_shp_attribute6
      ,p_shp_attribute7      => p_shp_attribute7
      ,p_shp_attribute8      => p_shp_attribute8
      ,p_shp_attribute9      => p_shp_attribute9
      ,p_shp_attribute10     => p_shp_attribute10
      ,p_shp_attribute11     => p_shp_attribute11
      ,p_shp_attribute12     => p_shp_attribute12
      ,p_shp_attribute13     => p_shp_attribute13
      ,p_shp_attribute14     => p_shp_attribute14
      ,p_shp_attribute15     => p_shp_attribute15
      ,p_shp_attribute16     => p_shp_attribute16
      ,p_shp_attribute17     => p_shp_attribute17
      ,p_shp_attribute18     => p_shp_attribute18
      ,p_shp_attribute19     => p_shp_attribute19
      ,p_shp_attribute20     => p_shp_attribute20
      ,p_shp_information_category => p_shp_information_category
      ,p_shp_information1    => p_shp_information1
      ,p_shp_information2    => p_shp_information2
      ,p_shp_information3    => p_shp_information3
      ,p_shp_information4    => p_shp_information4
      ,p_shp_information5    => p_shp_information5
      ,p_shp_information6    => p_shp_information6
      ,p_shp_information7    => p_shp_information7
      ,p_shp_information8    => p_shp_information8
      ,p_shp_information9    => p_shp_information9
      ,p_shp_information10   => p_shp_information10
      ,p_shp_information11   => p_shp_information11
      ,p_shp_information12   => p_shp_information12
      ,p_shp_information13   => p_shp_information13
      ,p_shp_information14   => p_shp_information14
      ,p_shp_information15   => p_shp_information15
      ,p_shp_information16   => p_shp_information16
      ,p_shp_information17   => p_shp_information17
      ,p_shp_information18   => p_shp_information18
      ,p_shp_information19   => p_shp_information19
      ,p_shp_information20   => p_shp_information20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_service_history_period'
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
  l_object_version_number  := p_object_version_number;


  pqp_shp_upd.upd (
       p_service_history_period_id    => p_service_history_period_id
      ,p_object_version_number        => l_object_version_number
      ,p_assignment_id                => p_assignment_id
      ,p_start_date                   => l_start_date
      ,p_end_date                     => l_end_date
      ,p_employer_name                => p_employer_name
      ,p_employer_address             => p_employer_address
      ,p_employer_type                => p_employer_type
      ,p_employer_subtype             => p_employer_subtype
      ,p_description                  => p_description
      ,p_continuous_service           => p_continuous_service
      ,p_all_assignments              => p_all_assignments
      ,p_period_years                 => p_period_years
      ,p_period_days                  => p_period_days
      ,p_shp_attribute_category => p_shp_attribute_category
      ,p_shp_attribute1      => p_shp_attribute1
      ,p_shp_attribute2      => p_shp_attribute2
      ,p_shp_attribute3      => p_shp_attribute3
      ,p_shp_attribute4      => p_shp_attribute4
      ,p_shp_attribute5      => p_shp_attribute5
      ,p_shp_attribute6      => p_shp_attribute6
      ,p_shp_attribute7      => p_shp_attribute7
      ,p_shp_attribute8      => p_shp_attribute8
      ,p_shp_attribute9      => p_shp_attribute9
      ,p_shp_attribute10     => p_shp_attribute10
      ,p_shp_attribute11     => p_shp_attribute11
      ,p_shp_attribute12     => p_shp_attribute12
      ,p_shp_attribute13     => p_shp_attribute13
      ,p_shp_attribute14     => p_shp_attribute14
      ,p_shp_attribute15     => p_shp_attribute15
      ,p_shp_attribute16     => p_shp_attribute16
      ,p_shp_attribute17     => p_shp_attribute17
      ,p_shp_attribute18     => p_shp_attribute18
      ,p_shp_attribute19     => p_shp_attribute19
      ,p_shp_attribute20     => p_shp_attribute20
      ,p_shp_information_category => p_shp_information_category
      ,p_shp_information1    => p_shp_information1
      ,p_shp_information2    => p_shp_information2
      ,p_shp_information3    => p_shp_information3
      ,p_shp_information4    => p_shp_information4
      ,p_shp_information5    => p_shp_information5
      ,p_shp_information6    => p_shp_information6
      ,p_shp_information7    => p_shp_information7
      ,p_shp_information8    => p_shp_information8
      ,p_shp_information9    => p_shp_information9
      ,p_shp_information10   => p_shp_information10
      ,p_shp_information11   => p_shp_information11
      ,p_shp_information12   => p_shp_information12
      ,p_shp_information13   => p_shp_information13
      ,p_shp_information14   => p_shp_information14
      ,p_shp_information15   => p_shp_information15
      ,p_shp_information16   => p_shp_information16
      ,p_shp_information17   => p_shp_information17
      ,p_shp_information18   => p_shp_information18
      ,p_shp_information19   => p_shp_information19
      ,p_shp_information20   => p_shp_information20
      );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_service_history_period_bk2.update_pqp_service_hist_pd_a
      (p_service_history_period_id   => p_service_history_period_id
      ,p_object_version_number       => l_object_version_number
      ,p_assignment_id               => p_assignment_id
      ,p_start_date                  => l_start_date
      ,p_end_date                    => l_end_date
      ,p_employer_name               => p_employer_name
      ,p_employer_address            => p_employer_address
      ,p_employer_type               => p_employer_type
      ,p_employer_subtype            => p_employer_subtype
      ,p_description                 => p_description
      ,p_continuous_service          => p_continuous_service
      ,p_all_assignments             => p_all_assignments
      ,p_period_years                => p_period_years
      ,p_period_days                 => p_period_days
      ,p_shp_attribute_category => p_shp_attribute_category
      ,p_shp_attribute1      => p_shp_attribute1
      ,p_shp_attribute2      => p_shp_attribute2
      ,p_shp_attribute3      => p_shp_attribute3
      ,p_shp_attribute4      => p_shp_attribute4
      ,p_shp_attribute5      => p_shp_attribute5
      ,p_shp_attribute6      => p_shp_attribute6
      ,p_shp_attribute7      => p_shp_attribute7
      ,p_shp_attribute8      => p_shp_attribute8
      ,p_shp_attribute9      => p_shp_attribute9
      ,p_shp_attribute10     => p_shp_attribute10
      ,p_shp_attribute11     => p_shp_attribute11
      ,p_shp_attribute12     => p_shp_attribute12
      ,p_shp_attribute13     => p_shp_attribute13
      ,p_shp_attribute14     => p_shp_attribute14
      ,p_shp_attribute15     => p_shp_attribute15
      ,p_shp_attribute16     => p_shp_attribute16
      ,p_shp_attribute17     => p_shp_attribute17
      ,p_shp_attribute18     => p_shp_attribute18
      ,p_shp_attribute19     => p_shp_attribute19
      ,p_shp_attribute20     => p_shp_attribute20
      ,p_shp_information_category => p_shp_information_category
      ,p_shp_information1    => p_shp_information1
      ,p_shp_information2    => p_shp_information2
      ,p_shp_information3    => p_shp_information3
      ,p_shp_information4    => p_shp_information4
      ,p_shp_information5    => p_shp_information5
      ,p_shp_information6    => p_shp_information6
      ,p_shp_information7    => p_shp_information7
      ,p_shp_information8    => p_shp_information8
      ,p_shp_information9    => p_shp_information9
      ,p_shp_information10   => p_shp_information10
      ,p_shp_information11   => p_shp_information11
      ,p_shp_information12   => p_shp_information12
      ,p_shp_information13   => p_shp_information13
      ,p_shp_information14   => p_shp_information14
      ,p_shp_information15   => p_shp_information15
      ,p_shp_information16   => p_shp_information16
      ,p_shp_information17   => p_shp_information17
      ,p_shp_information18   => p_shp_information18
      ,p_shp_information19   => p_shp_information19
      ,p_shp_information20   => p_shp_information20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_service_history_period'
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
  p_object_version_number      := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_service_history_period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_service_history_period;
    p_object_version_number      := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_service_history_period;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_service_history_period >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_service_history_period
  (p_validate                      in     boolean  default false
  ,p_service_history_period_id     in     number
  ,p_object_version_number         in     number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_service_history_period';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_service_history_period;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pqp_service_history_period_bk3.delete_pqp_service_hist_pd_b
      (p_service_history_period_id  => p_service_history_period_id
      ,p_object_version_number      => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_service_history_period'
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


  pqp_shp_del.del (
       p_service_history_period_id    => p_service_history_period_id
      ,p_object_version_number        => p_object_version_number
      );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pqp_service_history_period_bk3.delete_pqp_service_hist_pd_a
      (p_service_history_period_id   => p_service_history_period_id
      ,p_object_version_number       => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_service_history_period'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_service_history_period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_service_history_period;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_service_history_period;
--
end pqp_shp_api;

/
