--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_ITEM_TAB_PAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_ITEM_TAB_PAGES_API" as
/* $Header: hrtfpapi.pkb 115.4 2002/12/18 06:15:25 raranjan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_template_item_tab_pages_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_template_item_tab_page >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_item_tab_page
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_template_item_id              in     number
  ,p_template_tab_page_id          in     number
  ,p_upd_template_item_contexts    in     boolean  default false
  ,p_template_item_tab_page_id        out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = p_template_item_id;

  CURSOR csr_template_item_contexts
    (p_template_item_id            IN NUMBER
    ,p_template_tab_page_id        IN NUMBER
    )
  IS
    SELECT tic.template_item_context_id
      FROM hr_template_item_contexts_b tic
     WHERE NOT EXISTS (SELECT 0
                         FROM hr_template_item_context_pages tcp
                        WHERE tcp.template_tab_page_id = p_template_tab_page_id
                          AND tcp.template_item_context_id = tic.template_item_context_id)
       AND tic.template_item_id = p_template_item_id;
  l_template_item_context        csr_template_item_contexts%ROWTYPE;

  l_template_item_context_page_i NUMBER;
  l_tcp_object_version_number    NUMBER;

  l_object_version_number number;
  l_template_item_Tab_page_id number;
  l_proc                varchar2(72) := g_package||'create_template_item_tab_page';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_item_tab_page;
  --
  -- Truncate the time portion from all IN date parameters
  --
    -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_item_tab_pages_bk1.create_tip_b
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_template_item_id             => p_template_item_id
       ,p_template_tab_page_id         => p_template_tab_page_id
      ,p_upd_template_item_contexts    => p_upd_template_item_contexts
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_item_tab_page'
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
  -- Process Logic
  --

  if (p_upd_template_item_contexts) then
    for l_template_item_context in csr_template_item_contexts
      (p_template_item_id     => p_template_item_id
      ,p_template_tab_page_id => p_template_tab_page_id
      )
    loop
      hr_tcp_api.create_tcp
        (p_effective_date               => p_effective_date
        ,p_template_item_context_id     => l_template_item_context.template_item_context_id
        ,p_template_tab_page_id         => p_template_tab_page_id
        ,p_template_item_context_page_i => l_template_item_context_page_i
        ,p_object_version_number        => l_tcp_object_version_number
        );
    end loop;
  end if;

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_tip_ins.ins( p_template_item_id        => p_template_item_id
                  ,p_template_tab_page_id         => p_template_tab_page_id
                  ,p_template_item_tab_page_id    => l_template_item_tab_page_id
                  ,p_object_version_number        => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 25);

  begin
    hr_template_item_tab_pages_bk1.create_tip_a
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_template_item_id             => p_template_item_id
       ,p_template_tab_page_id         => p_template_tab_page_id
       ,p_upd_template_item_contexts   => p_upd_template_item_contexts
       ,p_template_item_tab_page_id    => l_template_item_tab_page_id
       ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_item_tab_page'
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
    p_template_item_tab_page_id    := l_template_item_tab_page_id;
    p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template_item_tab_page;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_item_tab_page_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
       p_template_item_tab_page_id    := null;
    p_object_version_number  := null;

    rollback to create_template_item_tab_page;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_item_tab_page;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_item_tab_page >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item_tab_page
  (p_validate                      in     boolean  default false
  ,p_template_item_tab_page_id     in      number
  ,p_object_version_number         in      number
  ,p_upd_template_item_contexts    in     boolean  default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
       ,hr_template_item_tab_pages htit
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = htit.template_item_id
  AND htit.template_item_tab_page_id = p_template_item_tab_page_id;

  CURSOR csr_template_item_context_page
    (p_template_item_tab_page_id   IN NUMBER
    )
  IS
    SELECT tcp.template_item_context_page_id
          ,tcp.object_version_number
      FROM hr_template_item_context_pages tcp
          ,hr_template_item_contexts_b tic
          ,hr_template_item_tab_pages tip
     WHERE tcp.template_tab_page_id = tip.template_tab_page_id
       AND tcp.template_item_context_id = tic.template_item_context_id
       AND tic.template_item_id = tip.template_item_id
       AND tip.template_item_tab_page_id = p_template_item_tab_page_id;
  l_template_item_context_page csr_template_item_context_page%ROWTYPE;

  l_proc                varchar2(72) := g_package||'delete_template_item_tab_page';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_item_tab_page;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_item_tab_pages_bk2.delete_tip_b
      (p_template_item_tab_page_id     => p_template_item_tab_page_id
       ,p_object_version_number        => p_object_version_number
       ,p_upd_template_item_contexts   => p_upd_template_item_contexts
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_item_tab_page'
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

  if (p_upd_template_item_contexts) then
    for l_template_item_context_page in csr_template_item_context_page
      (p_template_item_tab_page_id => p_template_item_tab_page_id
      )
    loop
      hr_tcp_api.delete_tcp
        (p_template_item_context_page_i => l_template_item_context_page.template_item_context_page_id
        ,p_object_version_number        => l_template_item_context_page.object_version_number
        );
    end loop;
  end if;

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_tip_del.del( p_template_item_tab_page_id    => p_template_item_tab_page_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 30);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_item_tab_pages_bk2.delete_tip_a
      (p_template_item_tab_page_id     => p_template_item_tab_page_id
       ,p_object_version_number        => p_object_version_number
       ,p_upd_template_item_contexts   => p_upd_template_item_contexts
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_item_tab_page'
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
    rollback to delete_template_item_tab_page;
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
    rollback to delete_template_item_tab_page;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_item_tab_page;
--
end hr_template_item_tab_pages_api;

/
