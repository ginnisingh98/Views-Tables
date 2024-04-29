--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_DATA_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_DATA_GROUPS_API" as
/* $Header: hrtdgapi.pkb 115.4 2004/06/21 09:20:50 njaladi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_template_data_groups_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template_data_group >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_template_data_group_id_from   in     number
  ,p_form_template_id              in     number
  ,p_template_data_group_id_to        out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_data_group
  IS
  SELECT tdg.form_data_group_id
  FROM hr_template_data_groups tdg
  WHERE tdg.template_data_group_id = p_template_data_group_id_from;

  -- Bug # 3648566. Modified the cursor text to use base table hr_template_items_b
  -- instead of view hr_template_items.
  CURSOR cur_tmplt_item
  IS
  SELECT tit1.template_item_id
  FROM hr_template_items_b tit2
  ,hr_template_items_b tit1
  ,hr_template_data_groups tdg
  WHERE tit2.template_item_id IS NULL
  AND tit2.form_template_id (+) = p_form_template_id
  AND tit2.form_item_id (+) = tit1.form_item_id
  AND tit1.form_template_id = tdg.form_template_id
  AND tdg.template_data_group_id = p_template_data_group_id_from;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
  WHERE hsf.form_template_id_to = p_form_template_id;

  l_form_data_group_id number;
-- the next 2 local vars are used only for storing the unused values
  l_template_item_id_to number;
  l_ovn_item number;

  l_proc                varchar2(72) := g_package||'copy_template_data_group';
  l_object_version_number number;
  l_template_data_group_id_to number;
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_template_data_group;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_data_groups_bk1.copy_template_data_group_b
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_language_code                => l_language_code
       ,p_template_data_group_id_from  => p_template_data_group_id_from
       ,p_form_template_id             => p_form_template_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_data_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_data_group;
  FETCH cur_data_group INTO l_form_data_group_id;
  CLOSE cur_data_group;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_tdg_ins.ins(p_form_template_id             => p_form_template_id
             ,p_form_data_group_id           => l_form_data_group_id
             ,p_template_data_group_id       => l_template_data_group_id_to
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 30);

  FOR cur_rec in cur_tmplt_item LOOP
    hr_template_items_api.copy_template_item(
                p_effective_date                => TRUNC(p_effective_date)
                ,p_language_code                => l_language_code
                ,p_template_item_id_from        => cur_rec.template_item_id
                ,p_form_template_id             => p_form_template_id
                ,p_template_item_id_to          => l_template_item_id_to
                ,p_object_version_number        => l_ovn_item);

  END LOOP;
  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 35);

  begin
    hr_template_data_groups_bk1.copy_template_data_group_a
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_language_code                => l_language_code
       ,p_template_data_group_id_from  => p_template_data_group_id_from
       ,p_form_template_id             => p_form_template_id
       ,p_template_data_group_id_to    => l_template_data_group_id_to
       ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_data_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_template_data_group_id_to    := l_template_data_group_id_to;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_template_data_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_data_group_id_to   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_data_group_id_to   := null;
    p_object_version_number  := null;

    rollback to copy_template_data_group;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_template_data_group;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_data_group >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_template_id              in     number
  ,p_form_data_group_id            in     number
  ,p_template_data_group_id           out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_form_item
  IS
  SELECT fit.form_item_id
  FROM hr_template_items tit
  ,hr_form_items fit
  ,hr_form_data_group_items fgi
  WHERE tit.template_item_id IS NULL
  AND tit.form_template_id (+) = p_form_template_id
  AND tit.form_item_id (+) = fit.form_item_id
  AND fit.form_item_id = fgi.form_item_id
  AND fgi.form_data_group_id = p_form_data_group_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
  WHERE hsf.form_template_id_to = p_form_template_id;

  l_proc                varchar2(72) := g_package||'create_template_data_group';
  l_template_data_group_id number;
  l_object_version_number number;
  l_template_item_id number;
  l_ovn number;
  l_override_value_warning boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_data_group;
  --
  -- Truncate the time portion from all IN date parameters
  --
    -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_data_groups_bk2.create_template_data_group_b
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_form_data_group_id           => p_form_data_group_id
       ,p_form_template_id             => p_form_template_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_data_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location('At:'|| l_proc, 15);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  hr_tdg_ins.ins(p_form_template_id             => p_form_template_id
             ,p_form_data_group_id           => p_form_data_group_id
             ,p_template_data_group_id       => l_template_data_group_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  FOR cur_rec in cur_form_item LOOP
    hr_template_items_api.create_template_item(
                p_effective_date           => TRUNC(p_effective_date)
                ,p_form_template_id        => p_form_template_id
                ,p_form_item_id            => cur_rec.form_item_id
                ,p_template_item_id        => l_template_item_id
                ,p_object_version_number   => l_ovn
                ,p_override_value_warning  => l_override_value_warning);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 30);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_data_groups_bk2.create_template_data_group_a
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_form_data_group_id           => p_form_data_group_id
       ,p_form_template_id             => p_form_template_id
       ,p_template_data_group_id       => l_template_data_group_id
       ,p_object_version_number        => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_data_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 35);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_template_data_group_id       := l_template_data_group_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template_data_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_data_group_id       := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_data_group_id       := null;
    p_object_version_number  := null;

    rollback to create_template_data_group;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_data_group;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_data_group >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_data_group
  (p_validate                      in     boolean  default false
  ,p_template_data_group_id        in number
  ,p_object_version_number         in number
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_tmplt_item
  IS
  SELECT tit.template_item_id
  ,tit.object_version_number
  FROM hr_template_items tit
  ,hr_form_data_group_items fgi
  ,hr_template_data_groups tdg
  WHERE tit.form_template_id = tdg.form_template_id
  AND tit.form_item_id = fgi.form_item_id
  AND fgi.form_data_group_id = tdg.form_data_group_id
  AND tdg.template_data_group_id = p_template_data_group_id
  MINUS
  SELECT tit.template_item_id
  ,tit.object_version_number
  FROM hr_template_items tit
  ,hr_form_data_group_items fgi
  ,hr_template_data_groups tdg2
  ,hr_template_data_groups tdg1
  WHERE tit.form_template_id = tdg2.form_template_id
  AND tit.form_item_id = fgi.form_item_id
  AND fgi.form_data_group_id = tdg2.form_data_group_id
  AND tdg2.template_data_group_id <> tdg1.template_data_group_id
  AND tdg2.form_template_id = tdg1.form_template_id
  AND tdg1.template_data_group_id = p_template_data_group_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_data_groups tdg
  WHERE hsf.form_template_id_to = tdg.form_template_id
  AND tdg.template_data_group_id = p_template_data_group_id;

  l_proc                varchar2(72) := g_package||'delete_template_data_group';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_data_group;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_data_groups_bk3.delete_template_data_group_b
      (p_template_data_group_id       => p_template_data_group_id
       ,p_object_version_number        => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_data_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  hr_tdg_shd.lck( p_template_data_group_id       => p_template_data_group_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  FOR cur_rec in cur_tmplt_item LOOP
    hr_template_items_api.delete_template_item(
               p_template_item_id             => cur_rec.template_item_id
              ,p_object_version_number        => cur_rec.object_version_number);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tdg_del.del( p_template_data_group_id       => p_template_data_group_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_data_groups_bk3.delete_template_data_group_a
      (p_template_data_group_id       => p_template_data_group_id
       ,p_object_version_number        => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_data_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_template_data_group;
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
    rollback to delete_template_data_group;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_data_group;
--
end hr_template_data_groups_api;

/
