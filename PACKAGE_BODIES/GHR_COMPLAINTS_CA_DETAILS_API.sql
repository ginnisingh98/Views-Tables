--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINTS_CA_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINTS_CA_DETAILS_API" as
/* $Header: ghcdtapi.pkb 115.4 2003/01/30 16:31:44 asubrahm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaints_ca_details_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_ca_detail >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_detail
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_compl_ca_header_id             in     number
  --,p_action                         in     varchar2
  ,p_amount                         in     number
  ,p_order_date                     in	   date
  ,p_due_date                       in	   date
  ,p_request_date                   in	   date
  ,p_complete_date                  in	   date
  ,p_category                       in     varchar2
  --,p_type                           in	 varchar2
  ,p_phase                          in	 varchar2
  ,p_action_type                    in     varchar2
  ,p_payment_type                   in     varchar2
  ,p_description                    in	 varchar2
  ,p_compl_ca_detail_id             out nocopy    number
  ,p_object_version_number          out nocopy    number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_ca_detail';
  l_compl_ca_detail_id    number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ca_detail;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaints_ca_details_bk_1.create_ca_detail_b
      (p_effective_date                 => p_effective_date
      ,p_compl_ca_header_id             => p_compl_ca_header_id
      --,p_action                         => p_action
      ,p_amount                         => p_amount
      ,p_order_date                     => p_order_date
      ,p_due_date                       => p_due_date
      ,p_request_date                   => p_request_date
      ,p_complete_date                  => p_complete_date
      ,p_category                       => p_category
      --,p_type                           => p_type
      ,p_phase                          => p_phase
      ,p_action_type                    => p_action_type
      ,p_payment_type                   => p_payment_type
      ,p_description                    => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ca_detail'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  ghr_cdt_ins.ins
  (
   p_effective_date                 => p_effective_date
  ,p_compl_ca_header_id             => p_compl_ca_header_id
  --,p_action                         => p_action
  ,p_amount                         => p_amount
  ,p_order_date                     => p_order_date
  ,p_due_date                       => p_due_date
  ,p_request_date                   => p_request_date
  ,p_complete_date                  => p_complete_date
  ,p_category                       => p_category
  --,p_type                           => p_type
  ,p_phase                          => p_phase
  ,p_action_type                    => p_action_type
  ,p_payment_type                   => p_payment_type
  ,p_description                    => p_description
  ,p_compl_ca_detail_id             => l_compl_ca_detail_id
  ,p_object_version_number          => l_object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaints_ca_details_bk_1.create_ca_detail_a
      (p_effective_date                 => p_effective_date
      ,p_compl_ca_header_id             => p_compl_ca_header_id
      --,p_action                         => p_action
      ,p_amount                         => p_amount
      ,p_order_date                     => p_order_date
      ,p_due_date                       => p_due_date
      ,p_request_date                   => p_request_date
      ,p_complete_date                  => p_complete_date
      ,p_category                       => p_category
      --,p_type                           => p_type
      ,p_phase                          => p_phase
      ,p_action_type                    => p_action_type
      ,p_payment_type                   => p_payment_type
      ,p_description                    => p_description
      ,p_compl_ca_detail_id             => l_compl_ca_detail_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ca_detail'
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
  p_compl_ca_detail_id     := l_compl_ca_detail_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ca_detail;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_ca_detail_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ca_detail;
    --RESET In/Out Params and SET Out Params
    p_compl_ca_detail_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ca_detail;
--


procedure update_ca_detail
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_compl_ca_detail_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_compl_ca_header_id           in     number
  --,p_action                       in     varchar2
  ,p_amount                       in     number
  ,p_order_date                   in     date
  ,p_due_date                     in     date
  ,p_request_date                 in     date
  ,p_complete_date                in     date
  ,p_category                     in     varchar2
  --,p_type                         in     varchar2
  ,p_phase                        in     varchar2
  ,p_action_type                  in     varchar2
  ,p_payment_type                 in     varchar2
  ,p_description                  in     varchar2
 )

is
  l_proc                varchar2(72) := g_package||'update_ca_detail';
  l_object_version_number number;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_ca_detail;
  --
     l_object_version_number := p_object_version_number;
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaints_ca_details_bk_2.update_ca_detail_b
      (p_effective_date                 => p_effective_date
      ,p_compl_ca_detail_id             => p_compl_ca_detail_id
      ,p_compl_ca_header_id             => p_compl_ca_header_id
      --,p_action                         => p_action
      ,p_amount                         => p_amount
      ,p_order_date                     => p_order_date
      ,p_due_date                       => p_due_date
      ,p_request_date                   => p_request_date
      ,p_complete_date                  => p_complete_date
      ,p_category                       => p_category
      --,p_type                           => p_type
      ,p_phase                          => p_phase
      ,p_action_type                    => p_action_type
      ,p_payment_type                   => p_payment_type
      ,p_description                    => p_description
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ca_detail'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
  l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 6);

  ghr_cdt_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_compl_ca_detail_id             => p_compl_ca_detail_id
  ,p_compl_ca_header_id             => p_compl_ca_header_id
  --,p_action                         => p_action
  ,p_amount                         => p_amount
  ,p_order_date                     => p_order_date
  ,p_due_date                       => p_due_date
  ,p_request_date                   => p_request_date
  ,p_complete_date                  => p_complete_date
  ,p_category                       => p_category
  --,p_type                           => p_type
  ,p_phase                          => p_phase
  ,p_action_type                    => p_action_type
  ,p_payment_type                   => p_payment_type
  ,p_description                    => p_description
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaints_ca_details_bk_2.update_ca_detail_a
      (p_effective_date                 => p_effective_date
      ,p_compl_ca_detail_id             => p_compl_ca_detail_id
      ,p_compl_ca_header_id             => p_compl_ca_header_id
      --,p_action                         => p_action
      ,p_amount                         => p_amount
      ,p_order_date                     => p_order_date
      ,p_due_date                       => p_due_date
      ,p_request_date                   => p_request_date
      ,p_complete_date                  => p_complete_date
      ,p_category                       => p_category
      --,p_type                           => p_type
      ,p_phase                          => p_phase
      ,p_action_type                    => p_action_type
      ,p_payment_type                   => p_payment_type
      ,p_description                    => p_description
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ca_detail'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ca_detail;
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
    rollback to update_ca_detail;
    -- RESET In/Out Params and SET Out Params
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_ca_detail;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ca_detail >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_detail
  (p_validate                      in     boolean
  ,p_compl_ca_detail_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_ca_detail';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_ca_detail;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaints_ca_details_bk_3.delete_ca_detail_b
      (p_compl_ca_detail_id            => p_compl_ca_detail_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ca_detail'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
 -- Process Logic
   ghr_cdt_del.del
    (p_compl_ca_detail_id            => p_compl_ca_detail_id
    ,p_object_version_number         => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaints_ca_details_bk_3.delete_ca_detail_a
      (p_compl_ca_detail_id            => p_compl_ca_detail_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ca_detail'
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ca_detail;
    --
  When Others then
    ROLLBACK TO delete_ca_detail;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_ca_detail;
end ghr_complaints_ca_details_api;


/
