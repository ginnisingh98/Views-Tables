--------------------------------------------------------
--  DDL for Package Body OTA_TPC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPC_API" as
/* $Header: ottpcapi.pkb 115.4 2002/11/25 13:45:13 hwinsor noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_TPC_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_COST >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cost
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_type_id        in     number
  ,p_training_plan_id              in     number
  ,p_amount                        in     number
  ,p_booking_id                    in     number   default null
  ,p_event_id                      in     number   default null
  ,p_currency_code                 in     varchar2 default null
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_information_category          in     varchar2 default null
  ,p_tp_cost_information1          in     varchar2 default null
  ,p_tp_cost_information2          in     varchar2 default null
  ,p_tp_cost_information3          in     varchar2 default null
  ,p_tp_cost_information4          in     varchar2 default null
  ,p_tp_cost_information5          in     varchar2 default null
  ,p_tp_cost_information6          in     varchar2 default null
  ,p_tp_cost_information7          in     varchar2 default null
  ,p_tp_cost_information8          in     varchar2 default null
  ,p_tp_cost_information9          in     varchar2 default null
  ,p_tp_cost_information10         in     varchar2 default null
  ,p_tp_cost_information11         in     varchar2 default null
  ,p_tp_cost_information12         in     varchar2 default null
  ,p_tp_cost_information13         in     varchar2 default null
  ,p_tp_cost_information14         in     varchar2 default null
  ,p_tp_cost_information15         in     varchar2 default null
  ,p_tp_cost_information16         in     varchar2 default null
  ,p_tp_cost_information17         in     varchar2 default null
  ,p_tp_cost_information18         in     varchar2 default null
  ,p_tp_cost_information19         in     varchar2 default null
  ,p_tp_cost_information20         in     varchar2 default null
  ,p_tp_cost_information21         in     varchar2 default null
  ,p_tp_cost_information22         in     varchar2 default null
  ,p_tp_cost_information23         in     varchar2 default null
  ,p_tp_cost_information24         in     varchar2 default null
  ,p_tp_cost_information25         in     varchar2 default null
  ,p_tp_cost_information26         in     varchar2 default null
  ,p_tp_cost_information27         in     varchar2 default null
  ,p_tp_cost_information28         in     varchar2 default null
  ,p_tp_cost_information29         in     varchar2 default null
  ,p_tp_cost_information30         in     varchar2 default null
  ,p_training_plan_cost_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Cost';
  l_training_plan_cost_id   number;
  l_object_version_number   number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_cost;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tpc_api_bk1.create_cost_b(
   p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_tp_measurement_type_id      => p_tp_measurement_type_id
  ,p_training_plan_id            => p_training_plan_id
  ,p_amount                      => p_amount
  ,p_booking_id                  => p_booking_id
  ,p_event_id                    => p_event_id
  ,p_currency_code               => p_currency_code
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_information_category        => p_information_category
  ,p_tp_cost_information1        => p_tp_cost_information1
  ,p_tp_cost_information2        => p_tp_cost_information2
  ,p_tp_cost_information3        => p_tp_cost_information3
  ,p_tp_cost_information4        => p_tp_cost_information4
  ,p_tp_cost_information5        => p_tp_cost_information5
  ,p_tp_cost_information6        => p_tp_cost_information6
  ,p_tp_cost_information7        => p_tp_cost_information7
  ,p_tp_cost_information8        => p_tp_cost_information8
  ,p_tp_cost_information9        => p_tp_cost_information9
  ,p_tp_cost_information10       => p_tp_cost_information10
  ,p_tp_cost_information11       => p_tp_cost_information11
  ,p_tp_cost_information12       => p_tp_cost_information12
  ,p_tp_cost_information13       => p_tp_cost_information13
  ,p_tp_cost_information14       => p_tp_cost_information14
  ,p_tp_cost_information15       => p_tp_cost_information15
  ,p_tp_cost_information16       => p_tp_cost_information16
  ,p_tp_cost_information17       => p_tp_cost_information17
  ,p_tp_cost_information18       => p_tp_cost_information18
  ,p_tp_cost_information19       => p_tp_cost_information19
  ,p_tp_cost_information20       => p_tp_cost_information20
  ,p_tp_cost_information21       => p_tp_cost_information21
  ,p_tp_cost_information22       => p_tp_cost_information22
  ,p_tp_cost_information23       => p_tp_cost_information23
  ,p_tp_cost_information24       => p_tp_cost_information24
  ,p_tp_cost_information25       => p_tp_cost_information25
  ,p_tp_cost_information26       => p_tp_cost_information26
  ,p_tp_cost_information27       => p_tp_cost_information27
  ,p_tp_cost_information28       => p_tp_cost_information28
  ,p_tp_cost_information29       => p_tp_cost_information29
  ,p_tp_cost_information30       => p_tp_cost_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_cost'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tpc_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_tp_measurement_type_id         => p_tp_measurement_type_id
  ,p_training_plan_id               => p_training_plan_id
  ,p_amount                         => p_amount
  ,p_booking_id                     => p_booking_id
  ,p_event_id                       => p_event_id
  ,p_business_group_id              => p_business_group_id
  ,p_currency_code                  => p_currency_code
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
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_information_category           => p_information_category
  ,p_tp_cost_information1           => p_tp_cost_information1
  ,p_tp_cost_information2           => p_tp_cost_information2
  ,p_tp_cost_information3           => p_tp_cost_information3
  ,p_tp_cost_information4           => p_tp_cost_information4
  ,p_tp_cost_information5           => p_tp_cost_information5
  ,p_tp_cost_information6           => p_tp_cost_information6
  ,p_tp_cost_information7           => p_tp_cost_information7
  ,p_tp_cost_information8           => p_tp_cost_information8
  ,p_tp_cost_information9           => p_tp_cost_information9
  ,p_tp_cost_information10          => p_tp_cost_information10
  ,p_tp_cost_information11          => p_tp_cost_information11
  ,p_tp_cost_information12          => p_tp_cost_information12
  ,p_tp_cost_information13          => p_tp_cost_information13
  ,p_tp_cost_information14          => p_tp_cost_information14
  ,p_tp_cost_information15          => p_tp_cost_information15
  ,p_tp_cost_information16          => p_tp_cost_information16
  ,p_tp_cost_information17          => p_tp_cost_information17
  ,p_tp_cost_information18          => p_tp_cost_information18
  ,p_tp_cost_information19          => p_tp_cost_information19
  ,p_tp_cost_information20          => p_tp_cost_information20
  ,p_tp_cost_information21          => p_tp_cost_information21
  ,p_tp_cost_information22          => p_tp_cost_information22
  ,p_tp_cost_information23          => p_tp_cost_information23
  ,p_tp_cost_information24          => p_tp_cost_information24
  ,p_tp_cost_information25          => p_tp_cost_information25
  ,p_tp_cost_information26          => p_tp_cost_information26
  ,p_tp_cost_information27          => p_tp_cost_information27
  ,p_tp_cost_information28          => p_tp_cost_information28
  ,p_tp_cost_information29          => p_tp_cost_information29
  ,p_tp_cost_information30          => p_tp_cost_information30
  ,p_training_plan_cost_id          => l_training_plan_cost_id
  ,p_object_version_number          => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
  ota_tpc_api_bk1.create_cost_a
  (p_effective_date              => l_effective_date
  ,p_training_plan_cost_id       => l_training_plan_cost_id
  ,p_object_version_number       => l_object_version_number
  ,p_business_group_id           => p_business_group_id
  ,p_tp_measurement_type_id      => p_tp_measurement_type_id
  ,p_training_plan_id            => p_training_plan_id
  ,p_amount                      => p_amount
  ,p_booking_id                  => p_booking_id
  ,p_event_id                    => p_event_id
  ,p_currency_code               => p_currency_code
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_information_category        => p_information_category
  ,p_tp_cost_information1        => p_tp_cost_information1
  ,p_tp_cost_information2        => p_tp_cost_information2
  ,p_tp_cost_information3        => p_tp_cost_information3
  ,p_tp_cost_information4        => p_tp_cost_information4
  ,p_tp_cost_information5        => p_tp_cost_information5
  ,p_tp_cost_information6        => p_tp_cost_information6
  ,p_tp_cost_information7        => p_tp_cost_information7
  ,p_tp_cost_information8        => p_tp_cost_information8
  ,p_tp_cost_information9        => p_tp_cost_information9
  ,p_tp_cost_information10       => p_tp_cost_information10
  ,p_tp_cost_information11       => p_tp_cost_information11
  ,p_tp_cost_information12       => p_tp_cost_information12
  ,p_tp_cost_information13       => p_tp_cost_information13
  ,p_tp_cost_information14       => p_tp_cost_information14
  ,p_tp_cost_information15       => p_tp_cost_information15
  ,p_tp_cost_information16       => p_tp_cost_information16
  ,p_tp_cost_information17       => p_tp_cost_information17
  ,p_tp_cost_information18       => p_tp_cost_information18
  ,p_tp_cost_information19       => p_tp_cost_information19
  ,p_tp_cost_information20       => p_tp_cost_information20
  ,p_tp_cost_information21       => p_tp_cost_information21
  ,p_tp_cost_information22       => p_tp_cost_information22
  ,p_tp_cost_information23       => p_tp_cost_information23
  ,p_tp_cost_information24       => p_tp_cost_information24
  ,p_tp_cost_information25       => p_tp_cost_information25
  ,p_tp_cost_information26       => p_tp_cost_information26
  ,p_tp_cost_information27       => p_tp_cost_information27
  ,p_tp_cost_information28       => p_tp_cost_information28
  ,p_tp_cost_information29       => p_tp_cost_information29
  ,p_tp_cost_information30       => p_tp_cost_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cost'
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
  p_training_plan_cost_id  := l_training_plan_cost_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_cost;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_training_plan_cost_id  := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cost;
    p_training_plan_cost_id  := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cost;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_COST >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cost
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_training_plan_cost_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_amount                        in     number   default hr_api.g_number
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information1          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information2          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information3          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information4          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information5          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information6          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information7          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information8          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information9          in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information10         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information11         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information12         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information13         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information14         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information15         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information16         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information17         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information18         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information19         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information20         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information21         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information22         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information23         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information24         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information25         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information26         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information27         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information28         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information29         in     varchar2 default hr_api.g_varchar2
  ,p_tp_cost_information30         in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Cost';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_cost;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tpc_api_bk2.update_cost_b
  (p_effective_date              => l_effective_date
  ,p_training_plan_cost_id       => p_training_plan_cost_id
  ,p_object_version_number       => p_object_version_number
  ,p_amount                      => p_amount
  ,p_currency_code               => p_currency_code
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_information_category        => p_information_category
  ,p_tp_cost_information1        => p_tp_cost_information1
  ,p_tp_cost_information2        => p_tp_cost_information2
  ,p_tp_cost_information3        => p_tp_cost_information3
  ,p_tp_cost_information4        => p_tp_cost_information4
  ,p_tp_cost_information5        => p_tp_cost_information5
  ,p_tp_cost_information6        => p_tp_cost_information6
  ,p_tp_cost_information7        => p_tp_cost_information7
  ,p_tp_cost_information8        => p_tp_cost_information8
  ,p_tp_cost_information9        => p_tp_cost_information9
  ,p_tp_cost_information10       => p_tp_cost_information10
  ,p_tp_cost_information11       => p_tp_cost_information11
  ,p_tp_cost_information12       => p_tp_cost_information12
  ,p_tp_cost_information13       => p_tp_cost_information13
  ,p_tp_cost_information14       => p_tp_cost_information14
  ,p_tp_cost_information15       => p_tp_cost_information15
  ,p_tp_cost_information16       => p_tp_cost_information16
  ,p_tp_cost_information17       => p_tp_cost_information17
  ,p_tp_cost_information18       => p_tp_cost_information18
  ,p_tp_cost_information19       => p_tp_cost_information19
  ,p_tp_cost_information20       => p_tp_cost_information20
  ,p_tp_cost_information21       => p_tp_cost_information21
  ,p_tp_cost_information22       => p_tp_cost_information22
  ,p_tp_cost_information23       => p_tp_cost_information23
  ,p_tp_cost_information24       => p_tp_cost_information24
  ,p_tp_cost_information25       => p_tp_cost_information25
  ,p_tp_cost_information26       => p_tp_cost_information26
  ,p_tp_cost_information27       => p_tp_cost_information27
  ,p_tp_cost_information28       => p_tp_cost_information28
  ,p_tp_cost_information29       => p_tp_cost_information29
  ,p_tp_cost_information30       => p_tp_cost_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_cost'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tpc_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_training_plan_cost_id          => p_training_plan_cost_id
  ,p_object_version_number          => l_object_version_number
  ,p_amount                         => p_amount
  ,p_currency_code                  => p_currency_code
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
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_information_category           => p_information_category
  ,p_tp_cost_information1           => p_tp_cost_information1
  ,p_tp_cost_information2           => p_tp_cost_information2
  ,p_tp_cost_information3           => p_tp_cost_information3
  ,p_tp_cost_information4           => p_tp_cost_information4
  ,p_tp_cost_information5           => p_tp_cost_information5
  ,p_tp_cost_information6           => p_tp_cost_information6
  ,p_tp_cost_information7           => p_tp_cost_information7
  ,p_tp_cost_information8           => p_tp_cost_information8
  ,p_tp_cost_information9           => p_tp_cost_information9
  ,p_tp_cost_information10          => p_tp_cost_information10
  ,p_tp_cost_information11          => p_tp_cost_information11
  ,p_tp_cost_information12          => p_tp_cost_information12
  ,p_tp_cost_information13          => p_tp_cost_information13
  ,p_tp_cost_information14          => p_tp_cost_information14
  ,p_tp_cost_information15          => p_tp_cost_information15
  ,p_tp_cost_information16          => p_tp_cost_information16
  ,p_tp_cost_information17          => p_tp_cost_information17
  ,p_tp_cost_information18          => p_tp_cost_information18
  ,p_tp_cost_information19          => p_tp_cost_information19
  ,p_tp_cost_information20          => p_tp_cost_information20
  ,p_tp_cost_information21          => p_tp_cost_information21
  ,p_tp_cost_information22          => p_tp_cost_information22
  ,p_tp_cost_information23          => p_tp_cost_information23
  ,p_tp_cost_information24          => p_tp_cost_information24
  ,p_tp_cost_information25          => p_tp_cost_information25
  ,p_tp_cost_information26          => p_tp_cost_information26
  ,p_tp_cost_information27          => p_tp_cost_information27
  ,p_tp_cost_information28          => p_tp_cost_information28
  ,p_tp_cost_information29          => p_tp_cost_information29
  ,p_tp_cost_information30          => p_tp_cost_information30);
  --
  -- Call After Process User Hook
  --
  begin
  ota_tpc_api_bk2.update_cost_a
  (p_effective_date              => l_effective_date
  ,p_training_plan_cost_id       => p_training_plan_cost_id
  ,p_object_version_number       => l_object_version_number
  ,p_amount                      => p_amount
  ,p_currency_code               => p_currency_code
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_information_category        => p_information_category
  ,p_tp_cost_information1        => p_tp_cost_information1
  ,p_tp_cost_information2        => p_tp_cost_information2
  ,p_tp_cost_information3        => p_tp_cost_information3
  ,p_tp_cost_information4        => p_tp_cost_information4
  ,p_tp_cost_information5        => p_tp_cost_information5
  ,p_tp_cost_information6        => p_tp_cost_information6
  ,p_tp_cost_information7        => p_tp_cost_information7
  ,p_tp_cost_information8        => p_tp_cost_information8
  ,p_tp_cost_information9        => p_tp_cost_information9
  ,p_tp_cost_information10       => p_tp_cost_information10
  ,p_tp_cost_information11       => p_tp_cost_information11
  ,p_tp_cost_information12       => p_tp_cost_information12
  ,p_tp_cost_information13       => p_tp_cost_information13
  ,p_tp_cost_information14       => p_tp_cost_information14
  ,p_tp_cost_information15       => p_tp_cost_information15
  ,p_tp_cost_information16       => p_tp_cost_information16
  ,p_tp_cost_information17       => p_tp_cost_information17
  ,p_tp_cost_information18       => p_tp_cost_information18
  ,p_tp_cost_information19       => p_tp_cost_information19
  ,p_tp_cost_information20       => p_tp_cost_information20
  ,p_tp_cost_information21       => p_tp_cost_information21
  ,p_tp_cost_information22       => p_tp_cost_information22
  ,p_tp_cost_information23       => p_tp_cost_information23
  ,p_tp_cost_information24       => p_tp_cost_information24
  ,p_tp_cost_information25       => p_tp_cost_information25
  ,p_tp_cost_information26       => p_tp_cost_information26
  ,p_tp_cost_information27       => p_tp_cost_information27
  ,p_tp_cost_information28       => p_tp_cost_information28
  ,p_tp_cost_information29       => p_tp_cost_information29
  ,p_tp_cost_information30       => p_tp_cost_information30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cost'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_cost;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_cost;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cost;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_COST >-----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cost
  (p_validate                      in     boolean  default false
  ,p_training_plan_cost_id         in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Cost';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_cost;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
  ota_tpc_api_bk3.delete_cost_b
  (p_training_plan_cost_id       => p_training_plan_cost_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_cost'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tpc_del.del
  (p_training_plan_cost_id          => p_training_plan_cost_id
  ,p_object_version_number          => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_tpc_api_bk3.delete_cost_a
  (p_training_plan_cost_id       => p_training_plan_cost_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cost'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_cost;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_cost;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_cost;
--
end ota_tpc_api;

/
