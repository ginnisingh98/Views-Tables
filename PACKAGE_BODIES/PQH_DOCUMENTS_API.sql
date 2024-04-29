--------------------------------------------------------
--  DDL for Package Body PQH_DOCUMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOCUMENTS_API" as
/* $Header: pqdocapi.pkb 120.1 2005/09/15 14:14:51 rthiagar noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_DOCUMENTS_API.';

-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_ELIMINATED_REC>--------------------------|-- ----------------------------------------------------------------------------
--
procedure create_dummy_rec(
  p_document_id number,
  p_object_version_number in out nocopy number,
  p_effective_date date) is
--
l_proc                     varchar2(72) ;
l_effective_start_date date;
l_effective_end_date date ;
l_date_effective date;
l_short_name varchar2(30);
l_document_name varchar2(100);
l_file_id number;
l_formula_id number;
l_enable_flag varchar2(15) := 'N';
l_object_version_number number(9);
l_document_category varchar2(30);
/* Added for XDO changes */
l_lob_code  varchar2(80);
l_language  varchar2(6);
l_territory  varchar2(6);
--
cursor c1 is
select effective_start_date,effective_end_date,short_name,document_name,
file_id,formula_id,object_version_number,document_category,lob_code,language,territory
from pqh_documents_f
where document_id = p_document_id
and p_effective_date between effective_start_date and effective_end_date;
--
begin
  l_proc  := g_package||'create_dummy_rec';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  open c1;
  fetch c1 into l_effective_start_date,l_effective_end_date,
  l_short_name,l_document_name,l_file_id,l_formula_id,l_object_version_number,l_document_category,l_lob_code,l_language,l_territory;
  close c1;
  --

  if (p_document_id is not null
   and p_object_version_number is not null
   and p_effective_date is not null) then
    --
    pqh_documents_api.update_document
    (p_validate             => false
    ,p_effective_date       => p_effective_date+1
    ,p_datetrack_mode       => hr_api.g_update
    ,p_short_name           => l_short_name
    ,p_document_name        => l_document_name
    ,p_file_id              => l_file_id
    ,p_formula_id           => l_formula_id
    ,p_enable_flag          => l_enable_flag
    ,p_document_id          =>  p_document_id
    ,p_document_category    =>  l_document_category
    ,p_object_version_number => p_object_version_number
    ,p_effective_start_date  => l_effective_start_date
    ,p_effective_end_date    => l_effective_end_date
    /* Added for XDO */
    ,p_lob_code              => l_lob_code
    ,p_language              => l_language
    ,p_territory             => l_territory
     );
  end if;

end;


--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_PRINT_DOCUMENT>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_print_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_short_name                     in     varchar2
  ,p_document_name                  in 	   varchar2
  ,p_file_id                        in     number
  ,p_formula_id                     in     number
  ,p_enable_flag                    in     varchar2
  ,p_document_category              in     varchar2
  ,p_document_id                    out NOCOPY     number
  ,p_object_version_number          out NOCOPY     number
  ,p_effective_start_date           out NOCOPY     date
  ,p_effective_end_date     	    out NOCOPY	   date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
   l_proc                   varchar2(72) := g_package||'CREATE_PRINT_DOCUMENT';

   l_document_id            pqh_documents_f.document_id%TYPE;
   l_object_version_number  pqh_documents_f.object_version_number%TYPE;
   l_effective_start_date   pqh_documents_f.effective_start_date%TYPE;
   l_effective_end_date     pqh_documents_f.effective_end_date%TYPE;
    --
  begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
    -- Issue a savepoint
    --
    savepoint CREATE_PRINT_DOCUMENT;
    --
    -- Truncate the time portion from all IN date parameters
    --

    --
    -- Call Before Process User Hook
  begin
       PQH_DOCUMENTS_BK1.create_print_document_b
        (p_effective_date                => p_effective_date
           ,p_short_name                 => p_short_name
           ,p_document_name              => p_document_name
           ,p_file_id                    => p_file_id
           ,p_formula_id                 => p_formula_id
           ,p_enable_flag                => p_enable_flag
           ,p_document_category          => p_document_category
           /* Added for XDO changes */
           ,p_lob_code                   => p_lob_code
           ,p_language                   => p_language
           ,p_territory                  => p_territory
 	);
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_PRINT_DOCUMENT'
          ,p_hook_type   => 'BP'
          );
   end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  	pqh_doc_ins.ins
    	 (p_effective_date            => p_effective_date
	  ,p_short_name               => p_short_name
	  ,p_document_name            => p_document_name
	  ,p_file_id                  => p_file_id
	  ,p_enable_flag              => p_enable_flag
	  ,p_formula_id               => p_formula_id
	  ,p_document_category        => p_document_category
	  ,p_document_id              => l_document_id
	  ,p_object_version_number    => l_object_version_number
 	  ,p_effective_start_date     => l_effective_start_date
  	  ,p_effective_end_date       => l_effective_end_date
          /* Added for XDO */
          ,p_lob_code              => p_lob_code
          ,p_language              => p_language
          ,p_territory             => p_territory
         );
  --
  -- Call After Process User Hook
  --
  begin
       PQH_DOCUMENTS_BK1.create_print_document_a
       (p_effective_date            =>   p_effective_date
       ,p_short_name                =>   p_short_name
       ,p_document_name             =>   p_document_name
       ,p_file_id                   =>   p_file_id
       ,p_formula_id                =>   p_formula_id
       ,p_enable_flag               =>   p_enable_flag
       ,p_document_category         =>   p_document_category
       ,p_document_id               =>   l_document_id
       ,p_object_version_number     =>   l_object_version_number
       ,p_effective_start_date      =>   l_effective_start_date
       ,p_effective_end_date        =>   l_effective_end_date
       /* Added for XDO */
       ,p_lob_code                  =>   p_lob_code
       ,p_language                  =>   p_language
       ,p_territory                 =>   p_territory
	);
   exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'CREATE_PRINT_DOCUMENT'
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
  p_document_id       	   := l_document_id;
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
    rollback to CREATE_PRINT_DOCUMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_document_id            := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
--
when others then
    --
    -- A validation or unexpected error has occured
    --
    p_document_id       := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    rollback to CREATE_PRINT_DOCUMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_print_document;

--
--
--

procedure create_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_short_name                     in     varchar2
  ,p_document_name                  in 	   varchar2
  ,p_file_id                        in     number
  ,p_formula_id                     in     number
  ,p_enable_flag                    in     varchar2
  ,p_document_category              in     varchar2
  ,p_document_id                    out NOCOPY     number
  ,p_object_version_number          out NOCOPY     number
  ,p_effective_start_date           out NOCOPY     date
  ,p_effective_end_date     	    out NOCOPY	   date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  ) is
begin
--
-- Wrapper for UI
--
create_print_document
  (p_validate                       => p_validate
  ,p_effective_date                 => p_effective_date
  ,p_short_name                     => p_short_name
  ,p_document_name                  => p_document_name
  ,p_file_id                        => p_file_iD
  ,p_formula_id                     => p_formula_id
  ,p_enable_flag                    => p_enable_flag
  ,p_document_id                    => p_document_id
  ,p_document_category              => p_document_category
  ,p_object_version_number          => p_object_version_number
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date     	    => p_effective_end_date
  /* Added for XDO changes */
  ,p_lob_code                       => p_lob_code
  ,p_language                       => p_language
  ,p_territory                      => p_territory
  );

end create_document;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_print_document>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_print_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_short_name                     in     varchar2 default hr_api.g_varchar2
  ,p_document_name                  in 	   varchar2 default hr_api.g_varchar2
  ,p_file_id                        in     number   default hr_api.g_number
  ,p_formula_id                     in     number   default hr_api.g_number
  ,p_enable_flag                    in     varchar2 default hr_api.g_varchar2
  ,p_document_category              in     varchar2 default hr_api.g_varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  ) is
 --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'UPDATE_PRINT_DOCUMENT';

  l_effective_start_date   pqh_documents_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_documents_f.effective_end_date%TYPE;
  l_object_version_number number := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_PRINT_DOCUMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
 begin
    PQH_DOCUMENTS_BK2.update_print_document_b
    (p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_short_name                 => p_short_name
    ,p_document_name              => p_document_name
    ,p_file_id                    => p_file_id
    ,p_formula_id                 => p_formula_id
    ,p_enable_flag                => p_enable_flag
    ,p_document_id                => p_document_id
    ,p_document_category          => p_document_category
    ,p_object_version_number      => p_object_version_number
    /* Added for XDO changes */
    ,p_lob_code                   => p_lob_code
    ,p_language                   => p_language
    ,p_territory                  => p_territory
    );
 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRINT_DOCUMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  pqh_doc_upd.upd
    (p_effective_date              => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_document_id                => p_document_id
    ,p_object_version_number      => p_object_version_number
    ,p_short_name                 => p_short_name
    ,p_document_name              => p_document_name
    ,p_file_id                    => p_file_id
    ,p_enable_flag                => p_enable_flag
    ,p_formula_id                 => p_formula_id
    ,p_document_category          => p_document_category
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    /* Added for XDO changes */
    ,p_lob_code                   => p_lob_code
    ,p_language                   => p_language
    ,p_territory                  => p_territory
    );

 --
 -- Call After Process User Hook
 --
 begin
    PQH_DOCUMENTS_BK2.update_print_document_a
    (p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_short_name                 => p_short_name
    ,p_document_name              => p_document_name
    ,p_file_id                    => p_file_id
    ,p_formula_id                 => p_formula_id
    ,p_enable_flag                => p_enable_flag
    ,p_document_id                => p_document_id
    ,p_document_category          => p_document_category
    ,p_object_version_number      => p_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    /* Added for XDO changes */
    ,p_lob_code                   => p_lob_code
    ,p_language                   => p_language
    ,p_territory                  => p_territory
    );
 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRINT_DOCUMENT'
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
    rollback to UPDATE_PRINT_DOCUMENT;
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

    rollback to UPDATE_PRINT_DOCUMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_print_document;
--
--
procedure update_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_short_name                     in     varchar2 default hr_api.g_varchar2
  ,p_document_name                  in 	   varchar2 default hr_api.g_varchar2
  ,p_file_id                        in     number   default hr_api.g_number
  ,p_formula_id                     in     number   default hr_api.g_number
  ,p_enable_flag                    in     varchar2 default hr_api.g_varchar2
  ,p_document_category              in     varchar2 default hr_api.g_varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  /* Added for XDO changes */
  ,p_lob_code                       in     varchar2
  ,p_language                       in     varchar2
  ,p_territory                      in     varchar2
  ) is

begin
update_print_document
  (p_validate                       => p_validate
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  ,p_short_name                     => p_short_name
  ,p_document_name                  => p_document_name
  ,p_file_id                        => p_file_iD
  ,p_formula_id                     => p_formula_id
  ,p_enable_flag                    => p_enable_flag
  ,p_document_id                    => p_document_id
  ,p_document_category              => p_document_category
  ,p_object_version_number          => p_object_version_number
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  /* Added for XDO changes */
  ,p_lob_code                       => p_lob_code
  ,p_language                       => p_language
  ,p_territory                      => p_territory
  );

end update_document;
--
-- Wrapper for UI
--
-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_PRINT_DOCUMENT>--------------------------|
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
procedure delete_print_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  )
  is
    --
    -- Declare cursors and local variables
    --

    l_proc      varchar2(72) := g_package||'DELETE_PRINT_DOCUMENT';
    l_effective_start_date   pqh_documents_f.effective_start_date%TYPE;
    l_effective_end_date     pqh_documents_f.effective_end_date%TYPE;
  l_object_version_number number :=       p_object_version_number;
    --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint DELETE_PRINT_DOCUMENT;
    --
    -- Truncate the time portion from all IN date parameters
    --

    --
    -- Call Before Process User Hook
    --
  begin
   PQH_DOCUMENTS_BK3.delete_print_document_b
    (p_effective_date            => p_effective_date
    ,p_datetrack_mode            => p_datetrack_mode
    ,p_document_id               => p_document_id
    ,p_object_version_number     => p_object_version_number
    );
    exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
           (p_module_name => 'DELETE_PRINT_DOCUMENT'
           ,p_hook_type   => 'BP'
           );
  end;
 --
 -- Validation in addition to Row Handlers
 --
 -- Process Logic
 --
 pqh_doc_del.del
  (p_effective_date                  => p_effective_date
   ,p_datetrack_mode                  => p_datetrack_mode
   ,p_document_id                     => p_document_id
   ,p_object_version_number           => p_object_version_number
   ,p_effective_start_date            => l_effective_start_date
   ,p_effective_end_date              => l_effective_end_date
   );

 --
  -- Call After Process User Hook
  --
  begin
   PQH_DOCUMENTS_BK3.delete_print_document_a
       (p_effective_date            => p_effective_date
       ,p_datetrack_mode            => p_datetrack_mode
       ,p_document_id               => p_document_id
       ,p_object_version_number     => p_object_version_number
       ,p_effective_start_date      => l_effective_start_date
       ,p_effective_end_date        => l_effective_end_date
    );
     exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_PRINT_DOCUMENT'
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
      rollback to DELETE_PRINT_DOCUMENT;
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

      rollback to DELETE_PRINT_DOCUMENT;
      hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
 --
 end delete_print_document;
--
--
procedure delete_document
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_document_id                    in     number
  ,p_object_version_number          in OUT NOCOPY     number
  ,p_effective_start_date           OUT    NOCOPY     date
  ,p_effective_end_date     	    OUT    NOCOPY     date
  ) is

begin

 if ( p_datetrack_mode = hr_api.g_delete) then
    create_dummy_rec(
       p_document_id => p_document_id,
       p_object_version_number => p_object_version_number,
       p_effective_date        => p_effective_date);
 else
    delete_print_document
      (p_validate                       => p_validate
      ,p_effective_date                 => p_effective_date
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_document_id                    => p_document_id
      ,p_object_version_number          => p_object_version_number
      ,p_effective_start_date           => p_effective_start_date
      ,p_effective_end_date             => p_effective_end_date
     );
end if;

end delete_document;
--
--
end pqh_documents_api;

/
