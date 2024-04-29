--------------------------------------------------------
--  DDL for Package Body IRC_TEMPLATE_ASSOCIATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_TEMPLATE_ASSOCIATION_API" as
/* $Header: iritaapi.pkb 120.0 2005/09/27 08:11:22 sayyampe noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  irc_template_association_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_template_association >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_association
  (p_validate                         in  boolean    default false
  ,p_template_id                      in  number
  ,p_effective_date                   in  date       default null
  ,p_default_association              in  varchar2   default null
  ,p_job_id                           in  number     default null
  ,p_position_id                      in  number     default null
  ,p_organization_id                  in  number     default null
  ,p_start_date                       in  date       default null
  ,p_end_date                         in  date       default null
  ,p_object_version_number            out nocopy number
  ,p_template_association_id          out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_template_association';
  l_object_version_number  number;
  l_effective_date         date;
  l_start_date             date      := trunc(p_start_date);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_association;

  if p_effective_date is null then
    l_effective_date:=l_start_date;
  else
    l_effective_date:=trunc(p_effective_date);
  end if;

  --
  -- Call Before Process User Hook
  --
  begin
    irc_template_association_bk1.create_template_association_b
    (p_template_id                      =>  p_template_id
    ,p_effective_date                   =>  l_effective_date
    ,p_default_association              =>  p_default_association
    ,p_job_id                           =>  p_job_id
    ,p_position_id                      =>  p_position_id
    ,p_organization_id                  =>  p_organization_id
    ,p_start_date                       =>  p_start_date
    ,p_end_date                         =>  p_end_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_association'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  irc_ita_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_template_id                    => p_template_id
  ,p_default_association            => p_default_association
  ,p_job_id                         => p_job_id
  ,p_position_id                    => p_position_id
  ,p_organization_id                => p_organization_id
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_template_association_id        => p_template_association_id
  ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    irc_template_association_bk1.create_template_association_a
     (p_template_association_id          =>  p_template_association_id
     ,p_template_id                      =>  p_template_id
     ,p_effective_date                   =>  l_effective_date
     ,p_default_association              =>  p_default_association
     ,p_job_id                           =>  p_job_id
     ,p_position_id                      =>  p_position_id
     ,p_organization_id                  =>  p_organization_id
     ,p_start_date                       =>  p_start_date
     ,p_end_date                         =>  p_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_association'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template_association;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    p_template_association_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_template_association;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_association;

--
-- ----------------------------------------------------------------------------
-- |--------------------< update_template_association >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_association
( p_validate                         in      boolean    default false
 ,p_effective_date                   in      date       default null
 ,p_template_association_id          in      number
 ,p_template_id                      in      number
 ,p_default_association              in      varchar2   default null
 ,p_job_id                           in      number     default null
 ,p_position_id                      in      number     default null
 ,p_organization_id                  in      number     default null
 ,p_start_date                       in      date       default null
 ,p_end_date                         in      date       default null
 ,p_object_version_number            in out  nocopy number

) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_template_association';
  l_object_version_number  number;
  l_effective_date         date;
  l_start_date             date            := trunc(p_start_date);

begin
  hr_utility.set_location('Entering:'|| l_proc||p_object_version_number, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_association;
  --
  -- Truncate the time portion from all IN date parameters
  --
  if p_effective_date is null then
    l_effective_date:= l_start_date;
  else
    l_effective_date:=trunc(p_effective_date);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_template_association_bk2.update_template_association_b
    (p_template_association_id          =>      p_template_association_id
    ,p_template_id                      =>      p_template_id
    ,p_effective_date                   =>      l_effective_date
    ,p_default_association              =>      p_default_association
    ,p_job_id                           =>      p_job_id
    ,p_position_id                      =>      p_position_id
    ,p_organization_id                  =>      p_organization_id
    ,p_start_date                       =>      p_start_date
    ,p_end_date                         =>      p_end_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_association'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  l_object_version_number  := p_object_version_number;

  irc_ita_upd.upd
  (p_effective_date               =>     l_effective_date
  ,p_template_association_id      =>     p_template_association_id
  ,p_object_version_number        =>     l_object_version_number
  ,p_template_id                  =>     p_template_id
  ,p_default_association          =>     p_default_association
  ,p_job_id                       =>     p_job_id
  ,p_position_id                  =>     p_position_id
  ,p_organization_id              =>     p_organization_id
  ,p_start_date                   =>     p_start_date
  ,p_end_date                     =>     p_end_date
  );

  --
  -- Call After Process User Hook
  --
  begin
     irc_template_association_bk2.update_template_association_a
     (p_template_association_id          =>  p_template_association_id
     ,p_template_id                      =>  p_template_id
     ,p_effective_date                   =>  l_effective_date
     ,p_default_association              =>  p_default_association
     ,p_job_id                           =>  p_job_id
     ,p_position_id                      =>  p_position_id
     ,p_organization_id                  =>  p_organization_id
     ,p_start_date                       =>  p_start_date
     ,p_end_date                         =>  p_end_date
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_association'
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
    p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc||p_object_version_number, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_template_association;
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
    rollback to update_template_association;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_template_association;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_association >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_association
  (p_validate                       in       boolean  default false
  ,p_template_association_id        in       number
  ,p_object_version_number          in       number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'delete_template_association';
  l_object_version_number  number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_association;

  --
  -- Call Before Process User Hook
  --
  begin
    irc_template_association_bk3.delete_template_association_b
      (p_template_association_id          =>      p_template_association_id
      ,p_object_version_number            =>      p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_association'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Validation in addition to Row Handlers
  --

  -- NONE

  --
  -- Process Logic
  --
    irc_ita_del.del
    (p_template_association_id      => p_template_association_id
    ,p_object_version_number        => p_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    irc_template_association_bk3.delete_template_association_a
     (p_template_association_id          =>      p_template_association_id
     ,p_object_version_number            =>      p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_association'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_template_association;
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
    rollback to delete_template_association;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_association;



--
end irc_template_association_api;

/
