--------------------------------------------------------
--  DDL for Package Body PQH_DOCUMENT_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOCUMENT_ATTRIBUTES_API" as
/* $Header: pqdoaapi.pkb 115.1 2003/03/06 20:55:24 nsanghal noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_DOCUMENT_ATTRIBUTES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_DOCUMENT_ATTRIBUTE>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_document_attribute
     (p_validate                       in     boolean  default false
     ,p_effective_date                 in     date
     ,p_document_id                    in     number
     ,p_attribute_id                   in     number
     ,p_tag_name                       in     varchar2
     ,p_document_attribute_id             out NOCOPY 	number
     ,p_object_version_number             out NOCOPY	number
     ,p_effective_start_date              out NOCOPY	date
     ,p_effective_end_date                out NOCOPY	date
     ) is
  --
  -- Declare cursors and local variables
  --
   l_proc                   varchar2(72) := g_package||'CREATE_DOCUMENT_ATTRIBUTE';

   l_document_attribute_id            pqh_document_attributes_f.document_attribute_id%TYPE;
   l_object_version_number  pqh_document_attributes_f.object_version_number%TYPE;
   l_effective_start_date   pqh_document_attributes_f.effective_start_date%TYPE;
   l_effective_end_date     pqh_document_attributes_f.effective_end_date%TYPE;
    --
  begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
    -- Issue a savepoint
    --
    savepoint CREATE_DOCUMENT_ATTRIBUTE;
    --
    -- Truncate the time portion from all IN date parameters
    --

    --
    -- Call Before Process User Hook
  begin
       PQH_DOCUMENT_ATTRIBUTES_BK1.create_document_attribute_b
 	   (  p_effective_date            => p_effective_date
	      ,p_document_id              => p_document_id
	      ,p_attribute_id             => p_attribute_id
	      ,p_tag_name                 => p_tag_name
    	   );
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_DOCUMENT_ATTRIBUTE'
          ,p_hook_type   => 'BP'
          );
   end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  	pqh_doA_ins.ins
		  (p_effective_date                 => p_effective_date
		  ,p_document_id                    => p_document_id
		  ,p_attribute_id                   => p_attribute_id
		  ,p_tag_name                       => p_tag_name
		  ,p_document_attribute_id          => l_document_attribute_id
		  ,p_object_version_number          => l_object_version_number
		  ,p_effective_start_date           => l_effective_start_date
		  ,p_effective_end_date             => l_effective_end_date
		  );

  --
  -- Call After Process User Hook
  --
  begin
       PQH_DOCUMENT_ATTRIBUTES_BK1.create_document_attribute_a
    		(  p_effective_date                 => p_effective_date
    		  ,p_document_id                    => p_document_id
    		  ,p_attribute_id                   => p_attribute_id
    		  ,p_tag_name                       => p_tag_name
    		  ,p_document_attribute_id          => l_document_attribute_id
    		  ,p_object_version_number          => l_object_version_number
    		  ,p_effective_start_date           => l_effective_start_date
    		  ,p_effective_end_date             => l_effective_end_date
    		);

   exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'CREATE_DOCUMENT_ATTRIBUTE'
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
  p_document_attribute_id  := l_document_attribute_id;
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
    rollback to CREATE_DOCUMENT_ATTRIBUTE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_document_attribute_id  := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
--
when others then
    --
    -- A validation or unexpected error has occured
    --
    p_document_attribute_id  := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    rollback to CREATE_DOCUMENT_ATTRIBUTE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_document_attribute;

--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_document_attribute>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_document_attribute
 (p_validate                     in     boolean  default false
    ,p_effective_date               in     date
    ,p_datetrack_mode               in     varchar2
    ,p_document_attribute_id        in     number
    ,p_object_version_number        in out NOCOPY number
    ,p_document_id                  in     number    default hr_api.g_number
    ,p_attribute_id                 in     number    default hr_api.g_number
    ,p_tag_name                     in     varchar2  default hr_api.g_varchar2
    ,p_effective_start_date            out NOCOPY date
    ,p_effective_end_date              out NOCOPY date
    ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'UPDATE_DOCUMENT_ATTRIBUTE';

  l_effective_start_date   pqh_DOCUMENT_ATTRIBUTES_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_DOCUMENT_ATTRIBUTES_f.effective_end_date%TYPE;
  l_object_version_number number := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_DOCUMENT_ATTRIBUTE;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
 begin
    PQH_DOCUMENT_ATTRIBUTES_BK2.update_document_attribute_b
	(p_effective_date           => p_effective_date
        ,p_datetrack_mode           => p_datetrack_mode
        ,p_document_attribute_id    => p_document_attribute_id
        ,p_object_version_number    => p_object_version_number
        ,p_document_id              => p_document_id
        ,p_attribute_id             => p_attribute_id
        ,p_tag_name                 => p_tag_name
        );

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DOCUMENT_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  pqh_doa_upd.upd
	  (p_effective_date               => p_effective_date
	  ,p_datetrack_mode               => p_datetrack_mode
	  ,p_document_attribute_id        => p_document_attribute_id
	  ,p_object_version_number        => p_object_version_number
	  ,p_document_id                  => p_document_id
	  ,p_attribute_id                 => p_attribute_id
	  ,p_tag_name                     => p_tag_name
	  ,p_effective_start_date         => l_effective_start_date
	  ,p_effective_end_date           => l_effective_end_date
	  );
--

 --
 -- Call After Process User Hook
 --
 begin
    PQH_DOCUMENT_ATTRIBUTES_BK2.update_document_attribute_a
	(p_effective_date           => p_effective_date
        ,p_datetrack_mode           => p_datetrack_mode
        ,p_document_attribute_id    => p_document_attribute_id
        ,p_object_version_number    => p_object_version_number
        ,p_document_id              => p_document_id
        ,p_attribute_id             => p_attribute_id
        ,p_tag_name                 => p_tag_name
	,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
	);


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DOCUMENT_ATTRIBUTE'
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
    rollback to UPDATE_DOCUMENT_ATTRIBUTE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   -- p_document_id            := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
--
when others then
    --
    -- A validation or unexpected error has occured
    --
 --   p_document_id       := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    rollback to UPDATE_DOCUMENT_ATTRIBUTE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_document_attribute;


-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_DOCUMENT_ATTRIBUTE>--------------------------|
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
procedure delete_document_attribute
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_attribute_id          in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  )
  is
    --
    -- Declare cursors and local variables
    --

    l_proc      varchar2(72) := g_package||'DELETE_DOCUMENT_ATTRIBUTE';
    l_effective_start_date   pqh_DOCUMENT_ATTRIBUTES_f.effective_start_date%TYPE;
    l_effective_end_date     pqh_DOCUMENT_ATTRIBUTES_f.effective_end_date%TYPE;
  l_object_version_number number :=       p_object_version_number;
    --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint DELETE_DOCUMENT_ATTRIBUTE;
    --
    -- Truncate the time portion from all IN date parameters
    --

    --
    -- Call Before Process User Hook
    --
  begin
   PQH_DOCUMENT_ATTRIBUTES_BK3.delete_document_attribute_b
    (p_effective_date            => p_effective_date
    ,p_datetrack_mode            => p_datetrack_mode
    ,p_document_attribute_id     => p_document_attribute_id
    ,p_object_version_number     => p_object_version_number
    );
    exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
           (p_module_name => 'DELETE_DOCUMENT_ATTRIBUTE'
           ,p_hook_type   => 'BP'
           );
  end;
 --
 -- Validation in addition to Row Handlers
 --
 -- Process Logic
 --
 pqh_doa_del.del
  (p_effective_date                  => p_effective_date
   ,p_datetrack_mode                  => p_datetrack_mode
   ,p_document_attribute_id           => p_document_attribute_id
   ,p_object_version_number           => p_object_version_number
   ,p_effective_start_date            => l_effective_start_date
   ,p_effective_end_date              => l_effective_end_date
   );

 --
  -- Call After Process User Hook
  --
  begin
   PQH_DOCUMENT_ATTRIBUTES_BK3.delete_document_attribute_a
       (p_effective_date            => p_effective_date
       ,p_datetrack_mode            => p_datetrack_mode
       ,p_document_attribute_id     => p_document_attribute_id
       ,p_object_version_number     => p_object_version_number
       ,p_effective_start_date      => l_effective_start_date
       ,p_effective_end_date        => l_effective_end_date
    );
     exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_DOCUMENT_ATTRIBUTE'
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
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := l_effective_start_date;
    p_effective_end_date     := l_effective_end_date;
    --
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to DELETE_DOCUMENT_ATTRIBUTE;
      --
      -- Only set output warning arguments
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_effective_start_date   := null;
      p_effective_end_date     := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      p_object_version_number  := l_object_version_number;
      p_effective_start_date   := null;
      p_effective_end_date     := null;

      rollback to DELETE_DOCUMENT_ATTRIBUTE;
      hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
 --
 end delete_document_attribute;
--
end pqh_DOCUMENT_ATTRIBUTES_api;

/
