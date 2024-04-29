--------------------------------------------------------
--  DDL for Package Body HR_SOURCE_FORM_TEMPLATES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SOURCE_FORM_TEMPLATES_BSI" as
/* $Header: hrsftbsi.pkb 115.2 2003/09/24 02:01:28 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_source_form_templates_bsi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_source_form_template >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_source_form_template
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_template_id_from         in     number
  ,p_form_template_id_to           in     number
  ,p_source_form_template_id       out nocopy    number
  ,p_object_version_number         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_source_form_template_id           number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'create_source_form_template';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_source_form_template;

  --
  -- Process Logic
  --
  hr_sft_ins.ins(p_form_template_id_to          => p_form_template_id_to
            ,p_form_template_id_from        => p_form_template_id_from
            ,p_source_form_template_id      => l_source_form_template_id
            ,p_object_version_number        => l_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_source_form_template_id      := l_source_form_template_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_source_form_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_source_form_template_id      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_source_form_template;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_source_form_template;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_source_form_template >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_source_form_template
  (p_validate                      in     boolean  default false
  ,p_source_form_template_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_source_form_template';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_source_form_template;
  --
  -- Process Logic
  --

  hr_sft_del.del( p_source_form_template_id      => p_source_form_template_id
                  ,p_object_version_number       => p_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
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
    rollback to delete_source_form_template;
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
    rollback to delete_source_form_template;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_source_form_template;
--
end hr_source_form_templates_bsi;

/
