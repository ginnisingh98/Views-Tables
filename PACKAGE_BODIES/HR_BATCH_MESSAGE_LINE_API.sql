--------------------------------------------------------
--  DDL for Package Body HR_BATCH_MESSAGE_LINE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BATCH_MESSAGE_LINE_API" as
/* $Header: hrabmapi.pkb 120.0 2006/04/11 00:14:36 vkaduban noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_batch_message_line_api.';
g_debug    boolean; -- debug flag
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_message_line >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_message_line
  (p_validate                      in     boolean  default false
  ,p_batch_run_number              in     number
  ,p_api_name                      in     varchar2
  ,p_status                        in     varchar2
  ,p_error_number                  in     number   default null
  ,p_error_message                 in     varchar2 default null
  ,p_extended_error_message        in     varchar2 default null
  ,p_source_row_information        in     varchar2 default null
  ,p_line_id                          out nocopy number) is
  --
  l_proc      varchar2(72) := g_package||'create_message_line';
  l_line_id   hr_api_batch_message_lines.line_id%type;
  --
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering:'|| l_proc, 5);
  END IF;
  --
  -- Issue a savepoint
  --
  savepoint create_message_line;
  --
  IF g_debug THEN
    hr_utility.set_location(l_proc, 7);
  END IF;
  --
  -- Process Logic
  --
  hr_abm_ins.ins
    (p_line_id                => l_line_id
    ,p_batch_run_number       => p_batch_run_number
    ,p_api_name               => p_api_name
    ,p_status                 => p_status
    ,p_error_number           => p_error_number
    ,p_error_message          => p_error_message
    ,p_extended_error_message => p_extended_error_message
    ,p_source_row_information => p_source_row_information
    ,p_validate               => false);
  --
  IF g_debug THEN
    hr_utility.set_location(l_proc, 8);
  END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_line_id := l_line_id;
  --
  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 11);
  END IF;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_message_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_line_id := null;
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO create_message_line;
  -- set the p_line_id to NULL for NOCOPY
  p_line_id := NULL;
  --
  raise;
  --
end create_message_line;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_message_line >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_message_line
  (p_validate                      in     boolean  default false
  ,p_line_id                       in     number) is
  --
  l_proc                varchar2(72) := g_package||'delete_message_line';
  --
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering:'|| l_proc, 5);
  END IF;
  --
  -- Issue a savepoint
  --
  savepoint delete_message_line;
  --
  IF g_debug THEN
    hr_utility.set_location(l_proc, 7);
  END IF;
  --
  -- Process Logic
  --
  hr_abm_del.del
    (p_line_id  => p_line_id
    ,p_validate => false);
  --
  IF g_debug THEN
    hr_utility.set_location(l_proc, 8);
  END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 11);
  END IF;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_message_line;
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_message_line;
  --
  raise;
  --
end delete_message_line;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_batch_lines >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_lines
  (p_validate                      in     boolean  default false
  ,p_batch_run_number              in     number) is
  --
  l_proc                varchar2(72) := g_package||'delete_batch_lines';
  --
  -- select all the lines to be deleted for the specified batch run number
  --
  cursor csr_get_line_id is
    select abm.line_id
    from   hr_api_batch_message_lines abm
    where  abm.batch_run_number = p_batch_run_number
    order by 1;
  --
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering:'|| l_proc, 5);
  END IF;
  --
  -- Issue a savepoint
  --
  savepoint delete_batch_lines;
  --
  IF g_debug THEN
    hr_utility.set_location(l_proc, 6);
  END IF;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'batch_run_number',
     p_argument_value => p_batch_run_number);
  --
  for csr_sel in csr_get_line_id loop
    --
    -- delete the batch line selected
    --
    delete_message_line
      (p_validate => false
      ,p_line_id  => csr_sel.line_id);
    --
  end loop;
  --
  IF g_debug THEN
    hr_utility.set_location(l_proc, 7);
  END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 11);
  END IF;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_batch_lines;
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_batch_lines;
  --
  raise;
  --
end delete_batch_lines;
--
end hr_batch_message_line_api;

/
