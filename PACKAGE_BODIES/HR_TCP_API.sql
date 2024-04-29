--------------------------------------------------------
--  DDL for Package Body HR_TCP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TCP_API" as
/* $Header: hrtcpapi.pkb 115.2 2002/12/05 09:12:55 raranjan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_tcp_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_tcp >---------------|
-- ----------------------------------------------------------------------------
--
procedure create_tcp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_template_item_context_id      in     number
  ,p_template_tab_page_id          in     number
  ,p_template_item_context_page_i     out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_template_tab_page_id          number ;
  l_template_item_context_page_i number ;
  l_object_version_number number;
  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
    ,hr_template_windows_b htw
    ,hr_template_canvases_b htb
    ,hr_template_tab_pages_b htt
  WHERE htt.template_tab_page_id = p_template_tab_page_id
  AND htt.template_canvas_id = htb.template_canvas_id
  AND htb.template_window_id = htw.template_window_id
  AND htw.form_template_id = hsf.form_template_id_to;

  l_proc                varchar2(72) := g_package||'create_tcp';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_tcp;
  --
  -- Truncate the time portion from all IN date parameters
  --
    -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_tcp_api_bk1.create_tcp_b
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_template_item_context_id     => p_template_item_context_id
       ,p_template_tab_page_id         => p_template_tab_page_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_tcp'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 10);

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
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_tcp_ins.ins(
     p_template_item_context_id      => p_template_item_context_id
     ,p_template_tab_page_id          => p_template_tab_page_id
     ,p_template_item_context_page_i => l_template_item_context_page_i
     ,p_object_version_number         => l_object_version_number);

  --
  -- Call After Process User Hook
  --
  begin
    hr_tcp_api_bk1.create_tcp_a
      (p_effective_date                 => TRUNC(p_effective_date)
       ,p_template_item_context_id      => p_template_item_context_id
       ,p_template_tab_page_id          => p_template_tab_page_id
       ,p_template_item_context_page_i => l_template_item_context_page_i
       ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_tcp'
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
    p_template_item_context_page_i := l_template_item_context_page_i;
    p_object_version_number         := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_tcp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_item_context_page_i := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_item_context_page_i := null;
    p_object_version_number  := null;

    rollback to create_tcp;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_tcp;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_tcp >---------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tcp
  (p_validate                      in     boolean  default false
  ,p_template_item_context_page_i  in number
  ,p_object_version_number            in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
    ,hr_template_windows_b htw
    ,hr_template_canvases_b htb
    ,hr_template_tab_pages_b htt
    ,hr_template_item_context_pages tcp
  WHERE htt.template_tab_page_id = tcp.template_tab_page_id
  AND htt.template_canvas_id = htb.template_canvas_id
  AND htb.template_window_id = htw.template_window_id
  AND htw.form_template_id = hsf.form_template_id_to
  AND tcp.template_item_context_page_id = p_template_item_context_page_i;

  l_proc                varchar2(72) := g_package||'delete_tcp';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_tcp;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_tcp_api_bk2.delete_tcp_b
      ( p_template_item_context_page_i => p_template_item_context_page_i
       ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_tcp'
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

  hr_utility.set_location('At:'|| l_proc, 20);

  --
  -- Process Logic
  --
  hr_tcp_del.del(
      p_template_item_context_page_i => p_template_item_context_page_i
     ,p_object_version_number        => p_object_version_number);

  --
  -- Call After Process User Hook
  --
  begin
    hr_tcp_api_bk2.delete_tcp_a
      ( p_template_item_context_page_i => p_template_item_context_page_i
       ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_tcp'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_tcp;
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
    rollback to delete_tcp;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_tcp;
--
end hr_tcp_api;

/
