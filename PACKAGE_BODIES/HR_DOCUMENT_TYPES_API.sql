--------------------------------------------------------
--  DDL for Package Body HR_DOCUMENT_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOCUMENT_TYPES_API" as
/* $Header: hrdtyapi.pkb 120.0 2005/05/30 23:53:41 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_document_types_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_document_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_document_type(
   p_validate                       in     boolean  default false
  ,p_language_code                  IN     VARCHAR2  DEFAULT hr_api.userenv_lang
  ,p_description                    in     varchar2  default null
  ,p_document_type                  in     varchar2
  ,p_effective_date                 in     date       default sysdate
  ,p_category_code                  in     varchar2
  ,p_active_inactive_flag           in     varchar2
  ,p_multiple_occurences_flag       in     varchar2
  ,p_authorization_required         in     varchar2
  ,p_sub_category_code              in     varchar2 default null
  ,p_legislation_code               in     varchar2 default null
  ,p_warning_period                 in     number   default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default sysdate
  ,p_document_type_id               out nocopy number
  ,p_object_version_number          out nocopy number
  ) IS
  -- Declare cursors and local variables
  --
    l_proc			varchar2(72) := g_package||'create_document_type';
    l_object_version_number	hr_document_types.object_version_number%type;
    l_document_type_id 	        hr_document_types.document_type_id%type;
    l_language_code         hr_all_organization_units_tl.language%TYPE;
    l_document_type varchar2(40);
BEGIN

  --
  -- Issue a savepoint
  --

  savepoint create_document_type;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_types_bk1.create_document_type_b(
       p_effective_date                => p_effective_date
      ,p_document_type                 => p_document_type
      ,p_language_code                 => p_language_code
      ,p_description                   => p_description
      ,p_category_code                 => p_category_code
      ,p_active_inactive_flag          => p_active_inactive_flag
      ,p_multiple_occurences_flag      => p_multiple_occurences_flag
      ,p_authorization_required        => p_authorization_required
      ,p_sub_category_code             => p_sub_category_code
      ,p_legislation_code              => p_legislation_code
      ,p_warning_period                => p_warning_period
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
  );
            exception
              when hr_api.cannot_find_prog_unit then
              hr_api.cannot_find_prog_unit_error
               (p_module_name => 'CREATE_DOCUMENT_TYPE'
               ,p_hook_type   => 'BP'
               );
      end;
    --

    -- End of Before Process User Hook call
    --
  hr_utility.set_location(l_proc, 7);
  --
  --
  -- Validate the language parameter. l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  --hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);

  --
  -- Process Logic
  --
  hr_dty_ins.ins(
       p_effective_date                => p_effective_date
      ,p_system_document_type          => p_document_type
      ,p_category_code                 => p_category_code
      ,p_active_inactive_flag          => p_active_inactive_flag
      ,p_multiple_occurences_flag      => p_multiple_occurences_flag
      ,p_authorization_required        => p_authorization_required
      ,p_sub_category_code             => p_sub_category_code
      ,p_legislation_code              => p_legislation_code
      ,p_warning_period                => p_warning_period
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_document_type_id              => l_document_type_id
      ,p_object_version_number         => l_object_version_number
  );

  --
  --  Now insert translatable rows in HR_DOCUMENT_TYPES_TL table
  --

  hr_dtt_ins.ins_tl
    ( p_language_code                 => l_language_code,
      p_document_type_id              => l_document_type_id,
      p_document_type                 => p_document_type,
      p_description                   => p_description
    );

  --

    p_object_version_number	    := l_object_version_number;
    p_document_type_id	        := l_document_type_id;
    --
    hr_utility.set_location(l_proc, 8);
    --
    -- Call After Process User Hook
    --

    begin
      hr_document_types_bk1.create_document_type_a(
       p_document_type_id              => l_document_type_id
      ,p_effective_date                => p_effective_date
      ,p_document_type                 => p_document_type
      ,p_language_code                 => p_language_code
      ,p_description                   => p_description
      ,p_category_code                 => p_category_code
      ,p_active_inactive_flag          => p_active_inactive_flag
      ,p_multiple_occurences_flag      => p_multiple_occurences_flag
      ,p_authorization_required        => p_authorization_required
      ,p_sub_category_code             => p_sub_category_code
      ,p_legislation_code              => p_legislation_code
      ,p_warning_period                => p_warning_period
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_object_version_number         => l_document_type_id
);
exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_DOCUMENT_TYPE',
           p_hook_type   => 'BP'
          );
end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_document_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_document_type_id       := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO create_document_type;
    --
    -- set in out parameters and set out parameters
    --
    p_document_type_id   := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_document_type;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_document_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_document_type(
  p_validate                     in     boolean  default false
 ,p_effective_date               in     date     default sysdate
 ,p_language_code                IN     VARCHAR2  DEFAULT hr_api.userenv_lang
 ,p_description                  in     varchar2
 ,p_document_type                in     varchar2
 ,p_document_type_id             in     number
 ,p_object_version_number        in out nocopy number
 ,p_category_code                in     varchar2
 ,p_active_inactive_flag         in     varchar2
 ,p_multiple_occurences_flag     in     varchar2
 ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
 ,p_authorization_required       in     varchar2
 ,p_sub_category_code            in     varchar2  default hr_api.g_varchar2
 ,p_warning_period               in     number    default hr_api.g_number
 ,p_request_id                   in     number    default hr_api.g_number
 ,p_program_application_id       in     number    default hr_api.g_number
 ,p_program_id                   in     number    default hr_api.g_number
 ,p_program_update_date          in     date      default hr_api.g_date
) IS
--
--
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_document_type';
  l_object_version_number hr_document_types.object_version_number%TYPE;
  l_ovn 		  hr_document_types.object_version_number%TYPE := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_document_type;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_types_bk2.update_document_type_b(
          p_effective_date                => p_effective_date
         ,p_category_code                 => p_category_code
         ,p_document_type                 => p_document_type
         ,p_language_code                 => p_language_code
         ,p_description                   => p_description
         ,p_active_inactive_flag          => p_active_inactive_flag
         ,p_multiple_occurences_flag      => p_multiple_occurences_flag
         ,p_authorization_required        => p_authorization_required
         ,p_sub_category_code             => p_sub_category_code
         ,p_legislation_code              => p_legislation_code
         ,p_warning_period                => p_warning_period
         ,p_request_id                    => p_request_id
         ,p_program_application_id        => p_program_application_id
         ,p_program_id                    => p_program_id
         ,p_program_update_date           => p_program_update_date
         ,p_document_type_id              => p_document_type_id
         ,p_object_version_number         => p_object_version_number
);
  exception
   when hr_api.cannot_find_prog_unit then
   hr_api.cannot_find_prog_unit_error
      (p_module_name => 'UPDATE_DOCUMENT_TYPE',
       p_hook_type   => 'BP'
                    );
        end;
          --
   -- End of Before Process User Hook call
   --
   --
   hr_utility.set_location(l_proc, 7);
   --
   -- Store the original ovn in case we rollback when p_validate is true
   --
   l_object_version_number  := p_object_version_number;
   --
   -- Process Logic - UPDATE_DOCUMENT_TYPE
   --
   hr_dty_upd.upd(
          p_effective_date                => p_effective_date
         ,p_category_code                 => p_category_code
         ,p_active_inactive_flag          => p_active_inactive_flag
         ,p_multiple_occurences_flag      => p_multiple_occurences_flag
         ,p_authorization_required        => p_authorization_required
         ,p_sub_category_code             => p_sub_category_code
         ,p_legislation_code              => p_legislation_code
         ,p_warning_period                => p_warning_period
         ,p_request_id                    => p_request_id
         ,p_program_application_id        => p_program_application_id
         ,p_program_id                    => p_program_id
         ,p_program_update_date           => p_program_update_date
         ,p_document_type_id              => p_document_type_id
         ,p_object_version_number         => p_object_version_number
         );
      --

  hr_dtt_upd.upd_tl
   (
    p_language_code => p_language_code,
    p_document_type_id => p_document_type_id,
    p_description => p_description,
    p_document_type =>p_document_type
    );
        hr_utility.set_location(l_proc, 8);
        --
        -- Call After Process User Hook
        --
        begin
    hr_document_types_bk2.update_document_type_a(
           p_effective_date                => p_effective_date
          ,p_category_code                 => p_category_code
          ,p_document_type                 => p_document_type
          ,p_language_code                 => p_language_code
          ,p_description                   => p_description
          ,p_active_inactive_flag          => p_active_inactive_flag
          ,p_multiple_occurences_flag      => p_multiple_occurences_flag
          ,p_authorization_required        => p_authorization_required
          ,p_sub_category_code             => p_sub_category_code
          ,p_legislation_code              => p_legislation_code
          ,p_warning_period                => p_warning_period
          ,p_request_id                    => p_request_id
          ,p_program_application_id        => p_program_application_id
          ,p_program_id                    => p_program_id
          ,p_program_update_date           => p_program_update_date
          ,p_document_type_id              => p_document_type_id
          ,p_object_version_number         => p_object_version_number
    );
     exception
            when hr_api.cannot_find_prog_unit then
              hr_api.cannot_find_prog_unit_error
          	    (p_module_name => 'UPDATE_DOCUMENT_TYPE',
                     p_hook_type   => 'AP'
                    );
    end;
      --
      -- End of After Process User Hook call
      --
      -- When in validation only mode raise the Validate_Enabled exception
      --
      if p_validate then
        raise hr_api.validate_enabled;
      end if;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 11);
    exception
      when hr_api.validate_enabled then
        --
        -- As the Validate_Enabled exception has been raised
        -- we must rollback to the savepoint
        --
        ROLLBACK TO update_document_type;
        --
        -- Only set output warning arguments
        -- (Any key or derived arguments must be set to null
        -- when validation only mode is being used.)
        --
        p_object_version_number  := l_object_version_number;
        --
        hr_utility.set_location(' Leaving:'||l_proc, 12);
        --
      when others then
        --
        -- A validation or unexpected error has occurred
        --
        ROLLBACK TO update_document_type;
        --
        -- set in out parameters and set out parameters
        --
            p_object_version_number  := l_ovn;
        --
        raise;
        --
    end update_document_type;
    --
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_document_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_document_type
  (p_validate                      in     boolean  default false
  ,p_document_type_id              in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_document_type';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_document_type;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_types_bk3.delete_document_type_b
      (p_document_type_id           => p_document_type_id,
       p_object_version_number      => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_DOCUMENT_TYPE',
             p_hook_type   => 'BP'
            );
end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete Person Extra Info details
  --
  hr_dty_del.del
  (p_document_type_id              => p_document_type_id
  ,p_object_version_number         => p_object_version_number
  );
  --
 hr_dtt_del.del_tl
 (
 p_document_type_id              => p_document_type_id
 );
  hr_utility.set_location(l_proc, 8);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_types_bk3.delete_document_type_a
      (p_document_type_id          => p_document_type_id,
       p_object_version_number     => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_DOCUMENT_TYPE',
             p_hook_type   => 'AP'
            );
end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_person_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO delete_document_type;
    --
    raise;
    --
end delete_document_type;
--
end hr_document_types_api;

/
