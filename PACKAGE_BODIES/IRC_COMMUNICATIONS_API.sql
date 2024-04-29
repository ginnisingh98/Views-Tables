--------------------------------------------------------
--  DDL for Package Body IRC_COMMUNICATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_COMMUNICATIONS_API" as
/* $Header: ircomapi.pkb 120.6.12010000.5 2010/04/07 09:53:56 vmummidi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_COMMUNICATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DEFINE_COMM_PROPERTIES >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DEFINE_COMM_PROPERTIES
  (p_validate                      in   boolean  default false
  ,p_effective_date                in   date
  ,p_object_type                   in   varchar2
  ,p_object_id                     in   number
  ,p_default_comm_status           in   varchar2
  ,p_allow_attachment_flag         in   varchar2
  ,p_auto_notification_flag        in   varchar2
  ,p_allow_add_recipients          in   varchar2
  ,p_default_moderator             in   varchar2
  ,p_attribute_category            in   varchar2  default null
  ,p_attribute1                    in   varchar2  default null
  ,p_attribute2                    in   varchar2  default null
  ,p_attribute3                    in   varchar2  default null
  ,p_attribute4                    in   varchar2  default null
  ,p_attribute5                    in   varchar2  default null
  ,p_attribute6                    in   varchar2  default null
  ,p_attribute7                    in   varchar2  default null
  ,p_attribute8                    in   varchar2  default null
  ,p_attribute9                    in   varchar2  default null
  ,p_attribute10                   in   varchar2  default null
  ,p_information_category          in   varchar2  default null
  ,p_information1                  in   varchar2  default null
  ,p_information2                  in   varchar2  default null
  ,p_information3                  in   varchar2  default null
  ,p_information4                  in   varchar2  default null
  ,p_information5                  in   varchar2  default null
  ,p_information6                  in   varchar2  default null
  ,p_information7                  in   varchar2  default null
  ,p_information8                  in   varchar2  default null
  ,p_information9                  in   varchar2  default null
  ,p_information10                 in   varchar2  default null
  ,p_communication_property_id        out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DEFINE_COMM_PROPERTIES';
  l_communication_property_id number;
  l_object_version_number     number(9);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DEFINE_COMM_PROPERTIES;

  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk1.define_comm_properties_b
    (p_effective_date          =>  p_effective_date
    ,p_object_type             =>  p_object_type
    ,p_object_id               =>  p_object_id
    ,p_default_comm_status     =>  p_default_comm_status
    ,p_allow_attachment_flag   =>  p_allow_attachment_flag
    ,p_auto_notification_flag  =>  p_auto_notification_flag
    ,p_allow_add_recipients    =>  p_allow_add_recipients
    ,p_default_moderator       =>  p_default_moderator
    ,p_attribute_category      =>  p_attribute_category
    ,p_attribute1              =>  p_attribute1
    ,p_attribute2              =>  p_attribute2
    ,p_attribute3              =>  p_attribute3
    ,p_attribute4              =>  p_attribute4
    ,p_attribute5              =>  p_attribute5
    ,p_attribute6              =>  p_attribute6
    ,p_attribute7              =>  p_attribute7
    ,p_attribute8              =>  p_attribute8
    ,p_attribute9              =>  p_attribute9
    ,p_attribute10             =>  p_attribute10
    ,p_information_category    =>  p_information_category
    ,p_information1            =>  p_information1
    ,p_information2            =>  p_information2
    ,p_information3            =>  p_information3
    ,p_information4            =>  p_information4
    ,p_information5            =>  p_information5
    ,p_information6            =>  p_information6
    ,p_information7            =>  p_information7
    ,p_information8            =>  p_information8
    ,p_information9            =>  p_information9
    ,p_information10           =>  p_information10
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DEFINE_COMM_PROPERTIES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    irc_cmp_ins.ins
    (p_effective_date          =>  p_effective_date
    ,p_object_type             =>  p_object_type
    ,p_object_id               =>  p_object_id
    ,p_default_comm_status     =>  p_default_comm_status
    ,p_allow_attachment_flag   =>  p_allow_attachment_flag
    ,p_auto_notification_flag  =>  p_auto_notification_flag
    ,p_allow_add_recipients    =>  p_allow_add_recipients
    ,p_default_moderator       =>  p_default_moderator
    ,p_attribute_category      =>  p_attribute_category
    ,p_attribute1              =>  p_attribute1
    ,p_attribute2              =>  p_attribute2
    ,p_attribute3              =>  p_attribute3
    ,p_attribute4              =>  p_attribute4
    ,p_attribute5              =>  p_attribute5
    ,p_attribute6              =>  p_attribute6
    ,p_attribute7              =>  p_attribute7
    ,p_attribute8              =>  p_attribute8
    ,p_attribute9              =>  p_attribute9
    ,p_attribute10             =>  p_attribute10
    ,p_information_category    =>  p_information_category
    ,p_information1            =>  p_information1
    ,p_information2            =>  p_information2
    ,p_information3            =>  p_information3
    ,p_information4            =>  p_information4
    ,p_information5            =>  p_information5
    ,p_information6            =>  p_information6
    ,p_information7            =>  p_information7
    ,p_information8            =>  p_information8
    ,p_information9            =>  p_information9
    ,p_information10           =>  p_information10
    ,p_communication_property_id => l_communication_property_id
    ,p_object_version_number     => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk1.define_comm_properties_a
    (p_effective_date          =>  p_effective_date
    ,p_object_type             =>  p_object_type
    ,p_object_id               =>  p_object_id
    ,p_default_comm_status     =>  p_default_comm_status
    ,p_allow_attachment_flag   =>  p_allow_attachment_flag
    ,p_auto_notification_flag  =>  p_auto_notification_flag
    ,p_allow_add_recipients    =>  p_allow_add_recipients
    ,p_default_moderator       =>  p_default_moderator
    ,p_attribute_category      =>  p_attribute_category
    ,p_attribute1              =>  p_attribute1
    ,p_attribute2              =>  p_attribute2
    ,p_attribute3              =>  p_attribute3
    ,p_attribute4              =>  p_attribute4
    ,p_attribute5              =>  p_attribute5
    ,p_attribute6              =>  p_attribute6
    ,p_attribute7              =>  p_attribute7
    ,p_attribute8              =>  p_attribute8
    ,p_attribute9              =>  p_attribute9
    ,p_attribute10             =>  p_attribute10
    ,p_information_category    =>  p_information_category
    ,p_information1            =>  p_information1
    ,p_information2            =>  p_information2
    ,p_information3            =>  p_information3
    ,p_information4            =>  p_information4
    ,p_information5            =>  p_information5
    ,p_information6            =>  p_information6
    ,p_information7            =>  p_information7
    ,p_information8            =>  p_information8
    ,p_information9            =>  p_information9
    ,p_information10           =>  p_information10
    ,p_communication_property_id => l_communication_property_id
    ,p_object_version_number   => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DEFINE_COMM_PROPERTIES'
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
  p_communication_property_id := l_communication_property_id;
  p_object_version_number     := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DEFINE_COMM_PROPERTIES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_communication_property_id := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DEFINE_COMM_PROPERTIES;
    -- Reset IN OUT Parameters and set OUT parameters
    --
    p_communication_property_id := null;
    p_object_version_number     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DEFINE_COMM_PROPERTIES;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_COMM_PROPERTIES >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_COMM_PROPERTIES
(p_validate                      in   boolean  default false
  ,p_effective_date                in   date
  ,p_object_type                   in   varchar2
  ,p_object_id                     in   number
  ,p_default_comm_status           in   varchar2
  ,p_allow_attachment_flag         in   varchar2
  ,p_auto_notification_flag        in   varchar2
  ,p_allow_add_recipients          in   varchar2
  ,p_default_moderator             in   varchar2
  ,p_attribute_category            in   varchar2  default null
  ,p_attribute1                    in   varchar2  default null
  ,p_attribute2                    in   varchar2  default null
  ,p_attribute3                    in   varchar2  default null
  ,p_attribute4                    in   varchar2  default null
  ,p_attribute5                    in   varchar2  default null
  ,p_attribute6                    in   varchar2  default null
  ,p_attribute7                    in   varchar2  default null
  ,p_attribute8                    in   varchar2  default null
  ,p_attribute9                    in   varchar2  default null
  ,p_attribute10                   in   varchar2  default null
  ,p_information_category          in   varchar2  default null
  ,p_information1                  in   varchar2  default null
  ,p_information2                  in   varchar2  default null
  ,p_information3                  in   varchar2  default null
  ,p_information4                  in   varchar2  default null
  ,p_information5                  in   varchar2  default null
  ,p_information6                  in   varchar2  default null
  ,p_information7                  in   varchar2  default null
  ,p_information8                  in   varchar2  default null
  ,p_information9                  in   varchar2  default null
  ,p_information10                 in   varchar2  default null
  ,p_communication_property_id     in   number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_COMM_PROPERTIES';
  l_object_version_number number(9);
--
-- Define cursors
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_COMM_PROPERTIES;
  --

  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk2.update_comm_properties_b
    (p_effective_date          =>  p_effective_date
    ,p_object_type             =>  p_object_type
    ,p_object_id               =>  p_object_id
    ,p_default_comm_status     =>  p_default_comm_status
    ,p_allow_attachment_flag   =>  p_allow_attachment_flag
    ,p_auto_notification_flag  =>  p_auto_notification_flag
    ,p_allow_add_recipients    =>  p_allow_add_recipients
    ,p_default_moderator       =>  p_default_moderator
    ,p_attribute_category      =>  p_attribute_category
    ,p_attribute1              =>  p_attribute1
    ,p_attribute2              =>  p_attribute2
    ,p_attribute3              =>  p_attribute3
    ,p_attribute4              =>  p_attribute4
    ,p_attribute5              =>  p_attribute5
    ,p_attribute6              =>  p_attribute6
    ,p_attribute7              =>  p_attribute7
    ,p_attribute8              =>  p_attribute8
    ,p_attribute9              =>  p_attribute9
    ,p_attribute10             =>  p_attribute10
    ,p_information_category    =>  p_information_category
    ,p_information1            =>  p_information1
    ,p_information2            =>  p_information2
    ,p_information3            =>  p_information3
    ,p_information4            =>  p_information4
    ,p_information5            =>  p_information5
    ,p_information6            =>  p_information6
    ,p_information7            =>  p_information7
    ,p_information8            =>  p_information8
    ,p_information9            =>  p_information9
    ,p_information10           =>  p_information10
    ,p_communication_property_id => p_communication_property_id
    ,p_object_version_number     => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COMM_PROPERTIES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmp_upd.upd
    (p_effective_date          =>  p_effective_date
    ,p_object_type             =>  p_object_type
    ,p_object_id               =>  p_object_id
    ,p_default_comm_status     =>  p_default_comm_status
    ,p_allow_attachment_flag   =>  p_allow_attachment_flag
    ,p_auto_notification_flag  =>  p_auto_notification_flag
    ,p_allow_add_recipients    =>  p_allow_add_recipients
    ,p_default_moderator       =>  p_default_moderator
    ,p_attribute_category      =>  p_attribute_category
    ,p_attribute1              =>  p_attribute1
    ,p_attribute2              =>  p_attribute2
    ,p_attribute3              =>  p_attribute3
    ,p_attribute4              =>  p_attribute4
    ,p_attribute5              =>  p_attribute5
    ,p_attribute6              =>  p_attribute6
    ,p_attribute7              =>  p_attribute7
    ,p_attribute8              =>  p_attribute8
    ,p_attribute9              =>  p_attribute9
    ,p_attribute10             =>  p_attribute10
    ,p_information_category    =>  p_information_category
    ,p_information1            =>  p_information1
    ,p_information2            =>  p_information2
    ,p_information3            =>  p_information3
    ,p_information4            =>  p_information4
    ,p_information5            =>  p_information5
    ,p_information6            =>  p_information6
    ,p_information7            =>  p_information7
    ,p_information8            =>  p_information8
    ,p_information9            =>  p_information9
    ,p_information10           =>  p_information10
    ,p_communication_property_id => p_communication_property_id
    ,p_object_version_number     => l_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk2.update_comm_properties_a
    (p_effective_date          =>  p_effective_date
    ,p_object_type             =>  p_object_type
    ,p_object_id               =>  p_object_id
    ,p_default_comm_status     =>  p_default_comm_status
    ,p_allow_attachment_flag   =>  p_allow_attachment_flag
    ,p_auto_notification_flag  =>  p_auto_notification_flag
    ,p_allow_add_recipients    =>  p_allow_add_recipients
    ,p_default_moderator       =>  p_default_moderator
    ,p_attribute_category      =>  p_attribute_category
    ,p_attribute1              =>  p_attribute1
    ,p_attribute2              =>  p_attribute2
    ,p_attribute3              =>  p_attribute3
    ,p_attribute4              =>  p_attribute4
    ,p_attribute5              =>  p_attribute5
    ,p_attribute6              =>  p_attribute6
    ,p_attribute7              =>  p_attribute7
    ,p_attribute8              =>  p_attribute8
    ,p_attribute9              =>  p_attribute9
    ,p_attribute10             =>  p_attribute10
    ,p_information_category    =>  p_information_category
    ,p_information1            =>  p_information1
    ,p_information2            =>  p_information2
    ,p_information3            =>  p_information3
    ,p_information4            =>  p_information4
    ,p_information5            =>  p_information5
    ,p_information6            =>  p_information6
    ,p_information7            =>  p_information7
    ,p_information8            =>  p_information8
    ,p_information9            =>  p_information9
    ,p_information10           =>  p_information10
    ,p_communication_property_id => p_communication_property_id
    ,p_object_version_number     => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COMM_PROPERTIES'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_COMM_PROPERTIES;
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
    rollback to UPDATE_COMM_PROPERTIES;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_COMM_PROPERTIES;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_COMMUNICATION >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_status                        in     varchar2
  ,p_start_date                    in     date
  ,p_object_version_number  out nocopy number
  ,p_communication_id       out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_COMMUNICATION';
  l_object_version_number number;
  l_communication_id      number;
  l_start_date            date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_COMMUNICATION;
  --
  --if start_date is null then start_date is equal to effective_date
  l_start_date := nvl(p_start_date, p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk3.create_communication_b
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => p_status
    ,p_start_date                 => l_start_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_COMMUNICATION'
,p_hook_type   => 'BP'
);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmc_ins.ins
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => p_status
    ,p_start_date                 => l_start_date
    ,p_object_version_number      => l_object_version_number
    ,p_communication_id           => l_communication_id
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk3.create_communication_a
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => p_status
    ,p_start_date                 => l_start_date
    ,p_object_version_number      => l_object_version_number
    ,p_communication_id           => l_communication_id
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_COMMUNICATION'
,p_hook_type   => 'AP'
);
  end;
  --
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
  p_communication_id       := l_communication_id;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_COMMUNICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_communication_id       := l_communication_id;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_COMMUNICATION;
    --
    p_object_version_number  := l_object_version_number;
    p_communication_id       := l_communication_id;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end CREATE_COMMUNICATION;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< START_COMMUNICATION >---------------------|
-- ----------------------------------------------------------------------------
--
procedure start_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_start_date                    in     date
  ,p_object_version_number  out nocopy number
  ,p_communication_id       out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'START_COMMUNICATION';
  l_object_version_number number;
  l_communication_id      number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint START_COMMUNICATION;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    CREATE_COMMUNICATION
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => 'OPEN'
    ,p_start_date                 => p_start_date
    ,p_object_version_number      => l_object_version_number
    ,p_communication_id           => l_communication_id
    );
  --
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
  p_communication_id       := l_communication_id;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to START_COMMUNICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_communication_id       := l_communication_id;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to START_COMMUNICATION;
    --
    p_object_version_number  := l_object_version_number;
    p_communication_id       := l_communication_id;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end START_COMMUNICATION;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_COMMUNICATION >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_status                        in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_communication_id              in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_COMMUNICATION';
  l_object_version_number number;
  l_end_date            date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_COMMUNICATION;
  --
  --if start_date is null then start_date is equal to effective_date
  l_end_date := nvl(p_end_date, p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk4.update_communication_b
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_communication_id           => p_communication_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => p_status
    ,p_start_date                 => p_start_date
    ,p_end_date                   => l_end_date
    ,p_object_version_number      => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'UPDATE_COMMUNICATION'
,p_hook_type   => 'BP'
);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmc_upd.upd
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => p_status
    ,p_start_date                 => p_start_date
    ,p_end_date                   => l_end_date
    ,p_object_version_number      => l_object_version_number
    ,p_communication_id           => p_communication_id
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk4.update_communication_a
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => p_status
    ,p_start_date                 => p_start_date
    ,p_end_date                   => l_end_date
    ,p_object_version_number      => l_object_version_number
    ,p_communication_id           => p_communication_id
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'UPDATE_COMMUNICATION'
,p_hook_type   => 'AP'
);
  end;
  --
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_COMMUNICATION;
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
    rollback to UPDATE_COMMUNICATION;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end UPDATE_COMMUNICATION;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CLOSE_COMMUNICATION >---------------------|
-- ----------------------------------------------------------------------------
--
procedure close_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_communication_id              in     number
  ,p_object_version_number      in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CLOSE_COMMUNICATION';
  l_object_version_number number;
  l_end_date            date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CLOSE_COMMUNICATION;
  --
  --if start_date is null then start_date is equal to effective_date
  l_end_date := nvl(p_end_date, p_effective_date);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    update_communication
    (p_effective_date             => p_effective_date
    ,p_communication_property_id  => p_communication_property_id
    ,p_object_type                => p_object_type
    ,p_object_id                  => p_object_id
    ,p_status                     => 'CLOSED'
    ,p_start_date                 => p_start_date
    ,p_end_date                   => l_end_date
    ,p_object_version_number      => l_object_version_number
    ,p_communication_id           => p_communication_id
    );
  --
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CLOSE_COMMUNICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CLOSE_COMMUNICATION;
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end CLOSE_COMMUNICATION;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_comm_properties >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comm_properties
(
  p_validate                    in boolean    default false
, p_object_version_number       in number
, p_communication_property_id   in number
, p_effective_date              in date       default null
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'delete_comm_properties';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_COMM_PROPERTIES;
  --
  --
  -- Validation in addition to Row Handlers
  --
  irc_cmp_del.del
  (
    p_communication_property_id => p_communication_property_id
   ,p_object_version_number     => P_OBJECT_VERSION_NUMBER
  );
  --
  -- Process Logic
  --
  --if a communiucation exist with this property do not delete
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
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_comm_properties;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_comm_properties;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    raise;
end delete_comm_properties;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_COMM_TOPIC >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_comm_topic
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_id              in     number
  ,p_subject                       in     varchar2
  ,p_status                        in     varchar2
  ,p_communication_topic_id        out    nocopy number
  ,p_object_version_number         out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_COMM_TOPIC';
  l_object_version_number       number;
  l_communication_topic_id      number;
  l_start_date                  date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_COMM_TOPIC;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk5.create_comm_topic_b
    (p_effective_date             => p_effective_date
    ,p_communication_id           => p_communication_id
    ,p_subject                    => p_subject
    ,p_status                     => p_status
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_COMM_TOPIC'
,p_hook_type   => 'BP'
);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmt_ins.ins
    (p_effective_date             => p_effective_date
    ,p_communication_id           => p_communication_id
    ,p_subject                    => p_subject
    ,p_status                     => p_status
    ,p_communication_topic_id     => l_communication_topic_id
    ,p_object_version_number      => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk5.create_comm_topic_a
    (p_effective_date             => p_effective_date
    ,p_communication_id           => p_communication_id
    ,p_subject                    => p_subject
    ,p_status                     => p_status
    ,p_communication_topic_id     => l_communication_topic_id
    ,p_object_version_number      => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_COMM_TOPIC'
,p_hook_type   => 'AP'
);
  end;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number        := l_object_version_number;
  p_communication_topic_id       := l_communication_topic_id;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_COMM_TOPIC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number        := l_object_version_number;
    p_communication_topic_id       := l_communication_topic_id;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_COMM_TOPIC;
    --
    p_object_version_number  := l_object_version_number;
    p_communication_topic_id       := l_communication_topic_id;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_comm_topic;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_MESSAGE >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_message
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_communication_topic_id       in     number
  ,p_parent_id                    in     number
  ,p_message_subject              in     varchar2
  ,p_message_post_date            in     date
  ,p_sender_type                  in     varchar2
  ,p_sender_id                    in     number
  ,p_message_body                 in     varchar2
  ,p_document_type                in     varchar2
  ,p_document_id                  in     number
  ,p_deleted_flag                 in     varchar2
  ,p_communication_message_id     out nocopy number
  ,p_object_version_number        out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_MESSAGE';
  l_object_version_number         number;
  l_communication_message_id      number;
  l_message_post_date             date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_MESSAGE;
  --
  --if message_post_date is null then message_post_date is equal to effective_date
  l_message_post_date := nvl(p_message_post_date, p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk6.create_message_b
    (p_effective_date            => p_effective_date
    ,p_communication_topic_id    => p_communication_topic_id
    ,p_parent_id                 => p_parent_id
    ,p_message_subject           => p_message_subject
    ,p_message_post_date         => l_message_post_date
    ,p_sender_type               => p_sender_type
    ,p_sender_id                 => p_sender_id
    ,p_message_body              => p_message_body
    ,p_document_type             => p_document_type
    ,p_document_id               => p_document_id
    ,p_deleted_flag              => p_deleted_flag
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_MESSAGE'
,p_hook_type   => 'BP'
);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmm_ins.ins
    (p_effective_date            => p_effective_date
    ,p_communication_topic_id    => p_communication_topic_id
    ,p_parent_id                 => p_parent_id
    ,p_message_subject           => p_message_subject
    ,p_message_post_date         => l_message_post_date
    ,p_sender_type               => p_sender_type
    ,p_sender_id                 => p_sender_id
    ,p_message_body              => p_message_body
    ,p_document_type             => p_document_type
    ,p_document_id               => p_document_id
    ,p_deleted_flag              => p_deleted_flag
    ,p_communication_message_id  => l_communication_message_id
    ,p_object_version_number     => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk6.create_message_a
    (p_effective_date            => p_effective_date
    ,p_communication_topic_id    => p_communication_topic_id
    ,p_parent_id                 => p_parent_id
    ,p_message_subject           => p_message_subject
    ,p_message_post_date         => l_message_post_date
    ,p_sender_type               => p_sender_type
    ,p_sender_id                 => p_sender_id
    ,p_message_body              => p_message_body
    ,p_document_type             => p_document_type
    ,p_document_id               => p_document_id
    ,p_deleted_flag              => p_deleted_flag
    ,p_communication_message_id  => l_communication_message_id
    ,p_object_version_number     => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'CREATE_MESSAGE'
,p_hook_type   => 'AP'
);
  end;
  --
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
  p_communication_message_id       := l_communication_message_id;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_MESSAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_communication_message_id       := l_communication_message_id;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_MESSAGE;
    --
    p_object_version_number  := l_object_version_number;
    p_communication_message_id       := l_communication_message_id;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_message;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_MESSAGE >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_message
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deleted_flag                 in     varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc          varchar2(72) := g_package||'UPDATE_MESSAGE';
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_MESSAGE;
  --
  -- Call Before Process User Hook
  --
  begin
  irc_communications_bk7.update_message_b
  (p_effective_date               => p_effective_date
  ,p_deleted_flag                 => p_deleted_flag
  ,p_communication_message_id     => p_communication_message_id
  ,p_object_version_number        => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'UPDATE_MESSAGE'
,p_hook_type   => 'BP'
);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmm_upd.upd
    (p_effective_date             => p_effective_date
    ,p_deleted_flag               => p_deleted_flag
    ,p_communication_message_id   => p_communication_message_id
    ,p_object_version_number      => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk7.update_message_a
    (p_effective_date             => p_effective_date
    ,p_deleted_flag               => p_deleted_flag
    ,p_communication_message_id   => p_communication_message_id
    ,p_object_version_number      => l_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'UPDATE_MESSAGE'
,p_hook_type   => 'AP'
);
  end;
  --
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_MESSAGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_MESSAGE;
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_message;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ADD_RECIPIENT >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_recipient
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_object_type     in     varchar2
  ,p_communication_object_id       in     number
  ,p_recipient_type                in     varchar2
  ,p_recipient_id                  in     number
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date
  ,p_primary_flag                  in     varchar2
  ,p_communication_recipient_id    out nocopy number
  ,p_object_version_number         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'ADD_RECIPIENT';
  l_object_version_number       number;
  l_communication_recipient_id  number;
  l_start_date_active           date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint ADD_RECIPIENT;
  --
  --if start_date_active is null then start_date_active is equal to effective_date
  l_start_date_active := nvl(p_start_date_active, p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_communications_bk8.ADD_RECIPIENT_b
    (p_effective_date               => p_effective_date
    ,p_communication_object_type    => p_communication_object_type
    ,p_communication_object_id      => p_communication_object_id
    ,p_recipient_type               => p_recipient_type
    ,p_recipient_id                 => p_recipient_id
    ,p_start_date_active            => l_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_primary_flag                 => p_primary_flag
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'ADD_RECIPIENT'
,p_hook_type   => 'BP'
);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    irc_cmr_ins.ins
    (p_effective_date               => p_effective_date
    ,p_communication_object_type    => p_communication_object_type
    ,p_communication_object_id      => p_communication_object_id
    ,p_recipient_type               => p_recipient_type
    ,p_recipient_id                 => p_recipient_id
    ,p_start_date_active            => l_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_primary_flag                 => p_primary_flag
    ,p_communication_recipient_id   => l_communication_recipient_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_communications_bk8.add_recipient_a
    (p_effective_date               => p_effective_date
    ,p_communication_object_type    => p_communication_object_type
    ,p_communication_object_id      => p_communication_object_id
    ,p_recipient_type               => p_recipient_type
    ,p_recipient_id                 => p_recipient_id
    ,p_start_date_active            => l_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_primary_flag                 => p_primary_flag
    ,p_communication_recipient_id   => l_communication_recipient_id
    ,p_object_version_number        => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
(p_module_name => 'ADD_RECIPIENT'
,p_hook_type   => 'AP'
);
  end;
  --
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
  p_communication_recipient_id       := l_communication_recipient_id;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to ADD_RECIPIENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_communication_recipient_id       := l_communication_recipient_id;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to ADD_RECIPIENT;
    --
    p_object_version_number  := l_object_version_number;
    p_communication_recipient_id       := l_communication_recipient_id;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end add_recipient;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< GET_RECIPIENT_LIST >---------------------|
-- ----------------------------------------------------------------------------
--
function get_rcpt_list(p_object_id IN number,filter varchar2 ) return varchar2 is
--
  Cursor cur_vac_id(p_topic_id irc_comm_topics.communication_topic_id%TYPE) is
  --get vacancy_id from topic_id
   select icp.object_id
   from
   irc_comm_properties icp,
   irc_communications ic,
   irc_comm_topics ict
   where
       ict.communication_topic_id = p_topic_id
   and ic.communication_id = ict.communication_id
   and icp.communication_property_id = ic.communication_property_id
   and icp.object_type = 'VACANCY'  ;
--
  Cursor cur_rec_mgr(p_vacancy_id per_all_vacancies.vacancy_id%TYPE) is
  --get recruiter_id and hiring_manager_id for a given vacancy
   select pav.recruiter_id
          ,pav.manager_id
   from
   per_all_vacancies pav
   where
   pav.vacancy_id = p_vacancy_id;
--
  Cursor cur_team(p_vacancy_id per_all_vacancies.vacancy_id%TYPE) is
   --get recruiting team members for a given vacancy
   select team.person_id
   from
   irc_rec_team_members team
   where
   team.vacancy_id = p_vacancy_id;
--
  Cursor cur_apl(p_topic_id irc_comm_topics.communication_topic_id%TYPE) is
  --get applicant for application attached to the given topic
   select paf.person_id
   from
   per_all_assignments_f paf,
   irc_communications ic,
   irc_comm_topics ict
   where
       ict.communication_topic_id = p_topic_id
   and ic.communication_id = ict.communication_id
   and paf.assignment_id  = ic.object_id
   and ic.object_type = 'APPL';
--
  Cursor cur_tpc_frm_msg(p_message_id irc_comm_messages.communication_message_id%TYPE) is
  --get topic_id from message_id
   select msg.communication_topic_id
   from
   irc_comm_messages msg
   where
   msg.communication_message_id = p_message_id;
--
  Cursor cur_tpc_frm_rcpt(p_recipient_id irc_comm_recipients.recipient_id%TYPE) is
   --get topic_id from recipient_id
   select icr.communication_object_id
   from
   irc_comm_recipients icr
   where
       icr.communication_recipient_id = p_recipient_id
   and icr.communication_object_type = 'TOPIC';
--
  Cursor cur_ppf(p_person_id per_all_people_f.person_id%TYPE) is
  --get person full name
   select ppf.full_name
   from per_all_people_f ppf
   where
       ppf.person_id = p_person_id;
--
  --get agency name
  Cursor cur_agency(l_recipient_id po_vendors.vendor_id%TYPE) is
   select pov.vendor_name
   from
   po_vendors pov
   where
     pov.vendor_id = l_recipient_id;
--
 l_list varchar2(32767);
 l_vacancy_id number;
 l_recipient_id number;
 l_recipient_type irc_comm_messages.sender_type%TYPE;
 l_topic_id number;
 l_rec_id number;
 l_mgr_id number;
 l_apl_id number;
 l_team_id number;
 l_full_name per_all_people_f.full_name%TYPE;
 l_meaning_rec hr_lookups.meaning%TYPE;
 l_meaning_mgr hr_lookups.meaning%TYPE;
 l_meaning_apl hr_lookups.meaning%TYPE;
 l_meaning_tm hr_lookups.meaning%TYPE;
 l_meaning_agncy hr_lookups.meaning%TYPE;
 l_role varchar2(32767);
--
 TYPE cur_typ IS REF CURSOR;
 cur_rcpt cur_typ;
 rec_team cur_team%ROWTYPE;
 l_found boolean;
 query_str VARCHAR2(32767);
 --
begin
----------------

 --fetching lookup meaning
 l_meaning_rec  := get_lookup_meaning('REC','IRC_VAC_ROLE');
 l_meaning_mgr  := get_lookup_meaning('MGR','IRC_VAC_ROLE');
 l_meaning_apl  := get_lookup_meaning('APL','IRC_VAC_ROLE');
 l_meaning_tm := get_lookup_meaning('TM','IRC_VAC_ROLE');
 l_meaning_agncy := get_lookup_meaning('AGNCY','IRC_VAC_ROLE');

-----------------------Recipient query making start------------------------------

   --get recipients for a given topic_id
   query_str := ' select icr.recipient_id, icr.recipient_type' ||
                ' from' ||
                ' irc_comm_recipients icr'||
                ' where icr.communication_object_id = :1' ||
                ' and   icr.communication_object_type= ''TOPIC''';

----------Fetch only selected recipients of a topic
----------or message based on given filter-value----

   --get topic creator
   if filter = 'CREATOR' then
    query_str := query_str || ' and icr.primary_flag=''Y'' ' ||
                              ' and icr.communication_object_type = ''TOPIC''';
   end if;

   --get all recipients of topic
   if filter = 'TOPIC_ALL' then
    query_str := query_str || ' and icr.communication_object_type = ''TOPIC'''||
                              ' order by icr.communication_recipient_id';
   end if;

   --get message sender
   if filter = 'SENDER' then
     query_str := ' select icm.sender_id, icm.sender_type' ||
                  ' from' ||
                  ' irc_comm_messages icm'||
                  ' where icm.communication_message_id =:1' ;
   end if;

   --get all recipients of message
   if filter = 'MESSAGE_ALL' then

       query_str :=' select icr.recipient_id,icr.recipient_type' ||
                   ' from' ||
                   ' irc_comm_messages icm,' ||
                   ' irc_comm_recipients icr' ||
                   ' where' ||
                   '     icm.communication_message_id= :1' ||
                   ' and  icr.communication_object_id   = icm.communication_topic_id' ||
                   ' and icr.communication_object_type = ''TOPIC''' ||
                   ' and icr.recipient_id<>icm.sender_id' ||
                   ' and icm.message_post_date' ||
                           ' between ' ||
                           ' icr.start_date_active'||
                           ' and  nvl(icr.end_date_active,icm.message_post_date)'||
                   ' order by icr.communication_recipient_id';

    end if;

    if filter = 'ROLE' then
       query_str :=' select icr.recipient_id,icr.recipient_type' ||
                   ' from' ||
                   ' irc_comm_recipients icr' ||
                   ' where' ||
                   ' icr.communication_recipient_id =:1';
    end if;
-----------------------Recipient query making finish------------------------------

  --if filter is 'SENDER' or 'MESSAGE_ALL' then p_object_id is message_id.
  --if filter is 'CREATOR' or 'TOPIC_ALL' then p_object_id is topic_id.
  --if filter is 'ROLE' then p_object_id is recipient_id and just role
  --is returned for given recipient.

   --getting topic_id for given message_id
   if filter = 'SENDER' OR filter = 'MESSAGE_ALL' then
     OPEN cur_tpc_frm_msg(p_object_id);
     FETCH cur_tpc_frm_msg INTO l_topic_id;
     CLOSE cur_tpc_frm_msg;
    end if;

   --getting topic_id for given recipient_id
   if filter = 'ROLE' then
     OPEN cur_tpc_frm_rcpt(p_object_id);
     FETCH cur_tpc_frm_rcpt INTO l_topic_id;
     CLOSE cur_tpc_frm_rcpt;
    end if;


   if filter='CREATOR' or filter = 'TOPIC_ALL' then
    l_topic_id := p_object_id;
   end if;

   --fetch vacancy_id for a given topic
   OPEN cur_vac_id(l_topic_id);
   FETCH cur_vac_id INTO l_vacancy_id;
   CLOSE cur_vac_id;

   --fetch recruiter and hiring manager for a given vacancy
   OPEN cur_rec_mgr(l_vacancy_id);
   FETCH cur_rec_mgr INTO l_rec_id, l_mgr_id;
   CLOSE cur_rec_mgr;

   --fetch applicant for a given application with which topic is attached
   OPEN cur_apl(l_topic_id);
   FETCH cur_apl INTO l_apl_id;
   CLOSE cur_apl;

--Looping through all recipients and appending their full-name with
--their role in context of vacancy with which topic/message attached.

-----------START OF LOOP FOR PROCESSING RECIPIENTS--------------------------------------
 l_list := '';

 OPEN cur_rcpt FOR query_str USING p_object_id;
 LOOP
  FETCH cur_rcpt INTO l_recipient_id, l_recipient_type ;
  EXIT WHEN cur_rcpt%NOTFOUND;
  l_found := false;
  l_role  := '';
  l_full_name := '';

      --If person_type is 'PERSON' then following role-possibilities are checked
      --recruiter, hiring manager, applicant, recruiting team-member.
      --If none of the above match is successfull then just name returned for given
      --recipient_id(person_id)

      if l_recipient_type='PERSON' then

      --------Comparing with team-members
          FOR rec_team IN cur_team(l_vacancy_id)
          LOOP
             if rec_team.person_id = l_recipient_id then

             l_found := true;

             OPEN cur_ppf(l_recipient_id);
             FETCH cur_ppf INTO l_full_name;

                if cur_ppf%FOUND then
                  l_role := l_meaning_tm;
                end if;

             CLOSE cur_ppf;

             end if;
          END LOOP;

      --------Comparing with recruiter
        if l_rec_id = l_recipient_id then
             l_found := true;

             OPEN cur_ppf(l_recipient_id);
             FETCH cur_ppf INTO l_full_name;

             if cur_ppf%FOUND then
              l_role := l_meaning_rec;
             end if;

             CLOSE cur_ppf;

          end if;
      --------Comparing with manager
          if l_mgr_id = l_recipient_id then

             l_found := true;

             OPEN cur_ppf(l_recipient_id);
             FETCH cur_ppf INTO l_full_name;

             if cur_ppf%FOUND then
               l_role := l_meaning_mgr;
             end if;

             CLOSE cur_ppf;
          end if;

      --------Comparing with applicant
          if l_apl_id = l_recipient_id then
             l_found := true;
             OPEN cur_ppf(l_recipient_id);
             FETCH cur_ppf INTO l_full_name;

             if cur_ppf%FOUND then
               l_role := l_meaning_apl;
             end if;

             CLOSE cur_ppf;
          end if;

       -------If not matched with anyone then just fetch name
          if l_found = false then
             OPEN cur_ppf(l_recipient_id);
             FETCH cur_ppf INTO l_full_name;
             CLOSE cur_ppf;
          end if;


     end if; ----end for checking roles when person_type='PERSON'


     ---if person_type is agency
     if l_recipient_type = 'AGENCY' then
      OPEN cur_agency(l_recipient_id);
      FETCH cur_agency INTO l_full_name;
        if cur_agency%FOUND then
           l_role := l_meaning_agncy;
        end if;
      CLOSE cur_agency;
     end if;

    if filter <> 'ROLE' then
       l_list := l_list ||l_role ||':'|| l_full_name || '    ';
    end if;

    if filter='ROLE' then
      l_list := l_role;
    end if;

 -----------END OF LOOP FOR PROCESSING RECIPIENTS--------------------------------------

   END LOOP;

   close  cur_rcpt;

   if filter='MESSAGE_ALL' and length(l_list||'a')=1 then
   l_list := fnd_message.GET_STRING('PER','IRC_412532_SELF_MESSAGE');
   end if;

   RETURN l_list;

   EXCEPTION
    WHEN  others THEN
        RETURN '';

END;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< GET_LOOKUP_MEANING >------------------------|
-- ----------------------------------------------------------------------------
--

function get_lookup_meaning(
p_lookup_code hr_lookups.lookup_code%TYPE
,p_lookup_type hr_lookups.lookup_type%TYPE)
return  varchar2 is
--
 Cursor cur_lookup(p_lookup_code hr_lookups.lookup_code%TYPE,p_lookup_type hr_lookups.lookup_type%TYPE) is
  --get lookup-meaning from lookup-code,lookup-type
    select hr_lookups.meaning
      from hr_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and enabled_flag = 'Y'
       and  sysdate between
            nvl(start_date_active, sysdate)
            and nvl(end_date_active, sysdate);
--
 l_lookup_meaning hr_lookups.meaning%TYPE;
--
BEGIN
   --fetch vacancy_id for a given topic
   OPEN cur_lookup(p_lookup_code, p_lookup_type);
   FETCH cur_lookup INTO l_lookup_meaning;
   CLOSE cur_lookup;

   RETURN l_lookup_meaning;

   EXCEPTION
    WHEN  others THEN
        RETURN '';
   END;


--
-- ----------------------------------------------------------------------------
-- |----------------------------< TOKENIZER >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This is a private procedure and is meant to be called from getIdArray
-- procedure only
--
      procedure tokenizer
      (
       p_nStartIn IN NUMBER,
       p_sDelimeterIn in VARCHAR2,
       p_sDelimetedListIn in VARCHAR2,
       p_sTokenOut OUT nocopy VARCHAR2,
       p_nNextPosOut OUT nocopy NUMBER
      )
      AS
      l_nPos1 number;
      l_nPos2 number;

      BEGIN
      p_sTokenOut :='NULL' ;

      l_nPos1 := Instr (p_sDelimetedListIn ,p_sDelimeterIn ,p_nStartIn);

       IF l_nPos1 = 0 then
        p_sTokenOut :='NULL' ;
       ELSE
        l_nPos2 := Instr (p_sDelimetedListIn ,p_sDelimeterIn ,l_nPos1 + 1);
         IF l_nPos2 = 0 then
          p_sTokenOut := Rtrim(Ltrim(Substr(p_sDelimetedListIn,l_nPos1 + 1)));
          p_nNextPosOut := l_nPos2;
         else
          p_sTokenOut := Rtrim(Ltrim(Substr(p_sDelimetedListIn ,l_nPos1 + 1 , l_nPos2 - l_nPos1 - 1)));
          p_nNextPosOut := l_nPos2;
         END IF;

       END IF;

      END tokenizer ;


--
-- ----------------------------------------------------------------------------
-- |----------------------------< GETIDARRAY>----------------------------------|
-- ----------------------------------------------------------------------------
--
--This procedure returns an array of assignmentId/recipientId when
--a comma-separated assignIdList/recipientIdList is passed to it.
--The list is expected to be of format ",1" or ",1,24,34"

      procedure getIdArray
      (
       sbuf in varchar2,
       data out nocopy assoc_arr
      )
      as
       sepr varchar2(1);
       sres varchar2(200);
       pos number;
       istart number;
       num number;
       listLength number;
      begin
       num:=1;
       sepr := ',';
       istart := 1;
       tokenizer (istart ,sepr,sbuf,sres,pos);

       if sres<>'NULL' then
        data(1) := sres;
       end if;

       while (pos <> 0)
        loop
         num := num+1;
         istart := pos;
         tokenizer (istart ,sepr,sbuf,sres,pos );
         data(num) := sres;
        end loop;

      END getIdArray;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< COMMUNICATION_EXISTS>------------------------|
-- ----------------------------------------------------------------------------
--
function communication_exists
(
   p_assignmentIdIn           in number
  ,p_communicationIdOut       out nocopy number
  ,p_communicationStatusOut   out nocopy varchar2
  ,p_object_version_numberOut out nocopy number
  ,p_object_typeOut           out nocopy varchar2
  ,p_start_dateOut            out nocopy date
)  return boolean  is

cursor cur_get_communication is
  select communication_id, status, object_version_number, object_type, start_date from irc_communications
  where object_type ='APPL' and object_id = p_assignmentIdIn;

begin
    open cur_get_communication;
    fetch cur_get_communication into p_communicationIdOut,p_communicationStatusOut
                                     ,p_object_version_numberOut,p_object_typeOut
                                     ,p_start_dateOut  ;

    if cur_get_communication%notfound then
     close cur_get_communication;
     return false;
    else
     close cur_get_communication;
     return true;
    end if;
end;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< START_MASS_COMMUNICATION---------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure takes a comma-separated list of assignmentIds
-- eg.(,234,235) as input.
--
procedure start_mass_communication
(
  p_assignmentIdListIn in  varchar2
) is
PRAGMA AUTONOMOUS_TRANSACTION;
--
--Cursor to get the communication property. This is required in case
--communication status needs to be updated or a new communication
--needs to be created.
--
 cursor cur_get_comm_property(p_assignment_id number) is
  select communication_property_id from irc_comm_properties where
   object_id = (select distinct vacancy_id from per_all_assignments_f where
                   assignment_id =p_assignment_id )
   and object_type ='VACANCY'  ;

 cursor cur_get_default_comm_status(p_assignment_id number) is
  select default_comm_status from irc_comm_properties where
   object_id = (select distinct vacancy_id from per_all_assignments_f where
                   assignment_id =p_assignment_id )
   and object_type ='VACANCY'  ;


 l_assignmentIdArray  assoc_arr;
 l_listLength number;
 l_communication_id irc_communications.communication_id%type;
 l_communication_status irc_communications.status%type;
 l_assignmentId irc_communications.object_id%type;
 l_comm_property_id irc_comm_properties.communication_property_id%type;
 l_object_version_number number;
 l_object_type irc_communications.object_type%type;
 l_start_date date;
begin
--
--Get assignmentId array
--
 getIdArray(p_assignmentIdListIn,l_assignmentIdArray);
 l_listLength := l_assignmentIdArray.count;
--
--Loop through all assignments
--
 for tempIndex in 1 .. l_listLength
  loop
     l_assignmentId := l_assignmentIdArray(tempIndex);
     --Check if communication exists
     if(communication_exists(p_assignmentIdIn=>l_assignmentId
                             ,p_communicationIdOut=>l_communication_id
                             ,p_communicationStatusOut=>l_communication_status
                             ,p_object_version_numberOut=> l_object_version_number
                             ,p_object_typeOut=>l_object_type
                             ,p_start_dateOut=>l_start_date ))
     then
      --If communication exists and is 'CLOSED', then update the status to 'OPEN'
      if l_communication_status<>'OPEN' then

        open cur_get_comm_property(l_assignmentId);
        fetch cur_get_comm_property into l_comm_property_id ;
        close cur_get_comm_property;

        update_communication
        (
          p_effective_date             => trunc(sysdate)
         ,p_communication_property_id  => l_comm_property_id
         ,p_object_type                => l_object_type
         ,p_object_id                  => l_assignmentId
         ,p_status                     => 'OPEN'
         ,p_start_date                 => l_start_date
         ,p_end_date                   => null
         ,p_communication_id           => l_communication_id
         ,p_object_version_number      => l_object_version_number
        );

      end if;

     else
        --If communication does not exist then create a communication with status
        --as 'OPEN' only if default-communication-status is not already 'OPEN'
--
--
     open cur_get_default_comm_status(l_assignmentId);
     fetch cur_get_default_comm_status into l_communication_status ;
     close cur_get_default_comm_status;
--
--
     if l_communication_status<>'OPEN' then

        open cur_get_comm_property(l_assignmentId);
        fetch cur_get_comm_property into l_comm_property_id ;
        close cur_get_comm_property;

      create_communication
      (
       p_effective_date                => trunc(sysdate)
      ,p_communication_property_id     => l_comm_property_id
      ,p_object_type                   => 'APPL'
      ,p_object_id                     => l_assignmentId
      ,p_status                        => 'OPEN'
      ,p_start_date                    => trunc(sysdate)
      ,p_object_version_number         => l_object_version_number
      ,p_communication_id              => l_communication_id
      );

     end if;

   end if;

  end loop;

  commit;

end;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CLOSE_MASS_COMMUNICATION>--------------------|
-- ----------------------------------------------------------------------------
--
-- Called from stop_mass_communication_gui
--
procedure close_mass_communication
(
  p_assignmentIdListIn in  varchar2
) is
PRAGMA AUTONOMOUS_TRANSACTION;
--
--Cursor to get the communication property. This is required in case
--communication status needs to be updated or a new communication
--needs to be created.
--
 cursor cur_get_comm_property(p_assignment_id number) is
  select communication_property_id from irc_comm_properties where
   object_id = (select distinct vacancy_id from per_all_assignments_f where
                   assignment_id =p_assignment_id )
   and object_type ='VACANCY'  ;
--
--
 cursor cur_get_default_comm_status(p_assignment_id number) is
  select default_comm_status from irc_comm_properties where
   object_id = (select distinct vacancy_id from per_all_assignments_f where
                   assignment_id =p_assignment_id )
   and object_type ='VACANCY';
--
 l_assignmentIdArray  assoc_arr;
 l_listLength number;
 l_communication_id irc_communications.communication_id%type;
 l_communication_status irc_communications.status%type;
 l_assignmentId irc_communications.object_id%type;
 l_comm_property_id irc_comm_properties.communication_property_id%type;
 l_object_version_number number;
 l_object_type irc_communications.object_type%type;
 l_start_date date;
begin
--
--Get assignmentId array
--
 getIdArray(p_assignmentIdListIn,l_assignmentIdArray);
 l_listLength := l_assignmentIdArray.count;
--
--Loop through all assignments
--
 for tempIndex in 1 .. l_listLength
  loop
     l_assignmentId := l_assignmentIdArray(tempIndex);

     if(communication_exists(p_assignmentIdIn=>l_assignmentId
                             ,p_communicationIdOut=>l_communication_id
                             ,p_communicationStatusOut=>l_communication_status
                             ,p_object_version_numberOut=> l_object_version_number
                             ,p_object_typeOut=>l_object_type
                             ,p_start_dateOut=>l_start_date))
     then
      --If communication exists and is 'OPEN', then update the status to 'CLOSED'
      if l_communication_status<>'CLOSED' then

        open cur_get_comm_property(l_assignmentId);
        fetch cur_get_comm_property into l_comm_property_id ;
        close cur_get_comm_property;

        update_communication
        (
          p_effective_date             => trunc(sysdate)
         ,p_communication_property_id  => l_comm_property_id
         ,p_object_type                => l_object_type
         ,p_object_id                  => l_assignmentId
         ,p_status                     => 'CLOSED'
         ,p_start_date                 => l_start_date
         ,p_end_date                   => null
         ,p_communication_id           => l_communication_id
         ,p_object_version_number      => l_object_version_number
        );

      end if;

     else
--
--
     open cur_get_default_comm_status(l_assignmentId);
     fetch cur_get_default_comm_status into l_communication_status ;
     close cur_get_default_comm_status;
--
--
     if l_communication_status='OPEN' then

        open cur_get_comm_property(l_assignmentId);
        fetch cur_get_comm_property into l_comm_property_id ;
        close cur_get_comm_property;
        --If communication does not exist then create a communication with status
        --as 'CLOSED' only if default-communication-status is not already 'CLOSED'
      create_communication
      (
       p_effective_date                => trunc(sysdate)
      ,p_communication_property_id     => l_comm_property_id
      ,p_object_type                   => 'APPL'
      ,p_object_id                     => l_assignmentId
      ,p_status                        => 'CLOSED'
      ,p_start_date                    => trunc(sysdate)
      ,p_object_version_number         => l_object_version_number
      ,p_communication_id              => l_communication_id
      );

     end if;

   end if;

  end loop;

  commit;

end;
--
--
procedure handle_attachments_on_commit
(
 p_message_list in varchar2
 ,p_dummy_attachment_id number
) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handle_attachments_on_commit';
  l_messageIdArray  assoc_arr;
  l_listLength number;
  l_messageId number;
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);

--
--Get assignmentId array
--
 getIdArray(p_message_list,l_messageIdArray);
 l_listLength := l_messageIdArray.count;
--
--Loop through all assignments
--
 for tempIndex in 1 .. l_listLength
  loop
     l_messageId := l_messageIdArray(tempIndex);
     fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'commDummyMsgMap',X_from_pk1_value => p_dummy_attachment_id,X_to_entity_name=>'commMsgMap',X_to_pk1_value=>l_messageId);
  end loop;

     fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'commDummyMsgMap',X_pk1_value=>p_dummy_attachment_id,X_delete_document_flag=>'Y');
     hr_utility.set_location(' Exiting:' || l_proc,20);
  commit;
 end;
--
--
procedure copy_comm_to_apl_asg
(
  p_target_asg_id in number
 ,p_source_asg_id in number
 ) is

l_proc    varchar2(72) := g_package || 'copy_comm_to_apl_asg';
l_comm_rec irc_communications%rowtype;
l_comm_recp_rec irc_comm_recipients%rowtype;
l_comm_topics irc_comm_topics%rowtype;
irc_comm_msgs irc_comm_messages%rowtype;
l_src_asgn_id number:=p_source_asg_id;
l_eff_date date:=sysdate;
l_target_asgn_id number:=p_target_asg_id;
l_comm_id number;
l_comm_topic_id number;
l_comm_msg_id number;
l_comm_recp_id number;
l_obj_version_number number;
l_src_person_id number;
l_trg_person_id number;
l_dummy_person_id number;
cursor csrGetCommForAsg(src_asgn_id in Number) is
select * from irc_communications
where object_id = src_asgn_id;

Cursor csrGetCommRec(comm_topic_id in number) is
select * from irc_comm_recipients
where communication_object_id = comm_topic_id;

cursor csrGetCommTopics(comm_id in number) is
select * from irc_comm_topics
where communication_id = comm_id;

cursor csrGetCommMessage(topic_id in number) is
select * from irc_comm_messages
where communication_topic_id = topic_id;

begin
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  select person_id into l_src_person_id from per_all_assignments_f paf
  where assignment_id = l_src_asgn_id and l_eff_date between paf.effective_start_date and paf.effective_end_date;
  --
  select person_id into l_trg_person_id from per_all_assignments_f paf
  where assignment_id = l_target_asgn_id and l_eff_date between paf.effective_start_date and paf.effective_end_date;
  --
  open csrGetCommForAsg(l_src_asgn_id);
  fetch csrGetCommForAsg into l_comm_rec;
  --
  if(csrGetCommForAsg%notfound)
  then
    return;
  end if;
  --
  close csrGetCommForAsg;
  --
  hr_utility.set_location(' Create Communication: ' || l_proc,20);
  --
  irc_communications_api.create_communication
    (p_effective_date                =>   l_eff_date
    ,p_communication_property_id     =>   l_comm_rec.communication_property_id
    ,p_object_type                   =>   l_comm_rec.object_type
    ,p_object_id                     =>   l_target_asgn_id
    ,p_status                        =>   l_comm_rec.status
    ,p_start_date                    =>   l_comm_rec.start_date
    ,p_object_version_number         =>   l_obj_version_number
    ,p_communication_id              =>   l_comm_id
    );
  --
  FOR commTopicRec IN csrGetCommTopics(l_comm_rec.communication_id)
  LOOP
    --
    hr_utility.set_location(' Create topic : ' || l_proc,30);
    --
    irc_communications_api.create_comm_topic
         (p_effective_date                =>   l_eff_date
         ,p_communication_id              =>   l_comm_id
         ,p_subject                       =>   commTopicRec.subject
         ,p_status                        =>   commTopicRec.status
         ,p_communication_topic_id        =>   l_comm_topic_id
         ,p_object_version_number         =>   l_obj_version_number
         );
     --
     For commMessageRec in csrGetCommMessage(commTopicRec.communication_topic_id)
     Loop
       --
       hr_utility.set_location(' Create message : ' || l_proc,40);
       --
       irc_communications_api.create_message
              (p_effective_date               =>    l_eff_date
              ,p_communication_topic_id       =>    l_comm_topic_id
              ,p_parent_id                    =>    commMessageRec.parent_id
              ,p_message_subject              =>    commMessageRec.message_subject
              ,p_message_post_date            =>    commMessageRec.message_post_date
              ,p_sender_type                  =>    commMessageRec.sender_type
              ,p_sender_id                    =>    commMessageRec.sender_id
              ,p_message_body                 =>    commMessageRec.message_body
              ,p_document_type                =>    commMessageRec.document_type
              ,p_document_id                  =>    commMessageRec.document_id
              ,p_deleted_flag                 =>    commMessageRec.deleted_flag
              ,p_communication_message_id     =>    l_comm_msg_id
              ,p_object_version_number        =>    l_obj_version_number
              );
        --
     END LOOP;
     For commRecpRec in csrGetCommRec(commTopicRec.communication_topic_id)
     LOOP
       --
       l_dummy_person_id := commRecpRec.recipient_id;
       --
       if(commRecpRec.recipient_id = l_src_person_id)
       then
         l_dummy_person_id := l_trg_person_id;
       end if;
       --
       hr_utility.set_location(' Create recipient : ' || l_proc,30);
       --
       irc_communications_api.add_recipient
               (p_effective_date                =>  l_eff_date
               ,p_communication_object_type     =>  commRecpRec.communication_object_type
               ,p_communication_object_id       =>  l_comm_topic_id
               ,p_recipient_type                =>  commRecpRec.recipient_type
               ,p_recipient_id                  =>  l_dummy_person_id
               ,p_start_date_active             =>  commRecpRec.start_date_active
               ,p_end_date_active               =>  commRecpRec.end_date_active
               ,p_primary_flag                  =>  commRecpRec.primary_flag
               ,p_communication_recipient_id    =>  l_comm_recp_id
               ,p_object_version_number         =>  l_obj_version_number
               );
        --
     END LOOP;
     --
  END LOOP;
  --
exception
when others then
        hr_utility.set_location(' Error : '||sqlErrm || l_proc,30);
end copy_comm_to_apl_asg;
end IRC_COMMUNICATIONS_API;

/
