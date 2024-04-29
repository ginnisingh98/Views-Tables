--------------------------------------------------------
--  DDL for Package Body PSP_EFF_REPORT_APPROVALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFF_REPORT_APPROVALS_API" as
/* $Header: PSPEAAIB.pls 120.3 2006/03/26 01:09:40 dpaudel noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := '    psp_eff_report_approvals_api.';
  p_legislation_code  varchar(50):=hr_api.userenv_lang;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_eff_report_approvals >--------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_eff_report_approvals
(p_validate                       in            boolean  default false
,p_effort_report_detail_id        in            number
,p_wf_role_name                   in            varchar2
,p_wf_orig_system_id              in            number
,p_wf_orig_system                 in            varchar2
,p_approver_order_num             in            number
,p_approval_status                in            varchar2
,p_response_date                  in            date
,p_actual_cost_share              in            number
,p_overwritten_effort_percent     in            number
,p_wf_item_key                    in            varchar2
,p_comments                       in            varchar2
,p_pera_information_category      in            varchar2
,p_pera_information1              in            varchar2
,p_pera_information2              in            varchar2
,p_pera_information3              in            varchar2
,p_pera_information4              in            varchar2
,p_pera_information5              in            varchar2
,p_pera_information6              in            varchar2
,p_pera_information7              in            varchar2
,p_pera_information8              in            varchar2
,p_pera_information9              in            varchar2
,p_pera_information10             in            varchar2
,p_pera_information11             in            varchar2
,p_pera_information12             in            varchar2
,p_pera_information13             in            varchar2
,p_pera_information14             in            varchar2
,p_pera_information15             in            varchar2
,p_pera_information16             in            varchar2
,p_pera_information17             in            varchar2
,p_pera_information18             in            varchar2
,p_pera_information19             in            varchar2
,p_pera_information20             in            varchar2
,p_wf_role_display_name           in            varchar2
,p_eff_information_category       in            varchar2
,p_eff_information1               in            varchar2
,p_eff_information2               in            varchar2
,p_eff_information3               in            varchar2
,p_eff_information4               in            varchar2
,p_eff_information5               in            varchar2
,p_eff_information6               in            varchar2
,p_eff_information7               in            varchar2
,p_eff_information8               in            varchar2
,p_eff_information9               in            varchar2
,p_eff_information10              in            varchar2
,p_eff_information11              in            varchar2
,p_eff_information12              in            varchar2
,p_eff_information13              in            varchar2
,p_eff_information14              in            varchar2
,p_eff_information15              in            varchar2
,p_effort_report_approval_id         out nocopy number
,p_object_version_number             out nocopy number
,p_return_status                     out nocopy boolean
)
IS
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'insert_eff_report_approvals';
  l_object_version_number     number(9);
  l_response_date             date;
  l_effort_report_approval_id number;
  l_return_status             boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint insert_eff_report_approvals;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_response_date := trunc(p_response_date);
  --
  -- Call Before Process User Hook
  --
  begin
    psp_eff_report_approvals_bk1.insert_eff_report_approvals_b
		(p_effort_report_detail_id         =>  p_effort_report_detail_id
		,p_wf_role_name                    =>  p_wf_role_name
		,p_wf_orig_system_id               =>  p_wf_orig_system_id
		,p_wf_orig_system                  =>  p_wf_orig_system
		,p_approver_order_num              =>  p_approver_order_num
		,p_approval_status                 =>  p_approval_status
		,p_response_date                   =>  l_response_date
		,p_actual_cost_share               =>  p_actual_cost_share
		,p_overwritten_effort_percent      =>  p_overwritten_effort_percent
		,p_wf_item_key                     =>  p_wf_item_key
		,p_comments                        =>  p_comments
		,p_pera_information_category       =>  p_pera_information_category
		,p_pera_information1               =>  p_pera_information1
		,p_pera_information2               =>  p_pera_information2
		,p_pera_information3               =>  p_pera_information3
		,p_pera_information4               =>  p_pera_information4
		,p_pera_information5               =>  p_pera_information5
		,p_pera_information6               =>  p_pera_information6
		,p_pera_information7               =>  p_pera_information7
		,p_pera_information8               =>  p_pera_information8
		,p_pera_information9               =>  p_pera_information9
		,p_pera_information10              =>  p_pera_information10
		,p_pera_information11              =>  p_pera_information11
		,p_pera_information12              =>  p_pera_information12
		,p_pera_information13              =>  p_pera_information13
		,p_pera_information14              =>  p_pera_information14
		,p_pera_information15              =>  p_pera_information15
		,p_pera_information16              =>  p_pera_information16
		,p_pera_information17              =>  p_pera_information17
		,p_pera_information18              =>  p_pera_information18
		,p_pera_information19              =>  p_pera_information19
		,p_pera_information20              =>  p_pera_information20
		,p_wf_role_display_name            =>  p_wf_role_display_name
		,p_eff_information_category        =>  p_eff_information_category
		,p_eff_information1                =>  p_eff_information1
		,p_eff_information2                =>  p_eff_information2
		,p_eff_information3                =>  p_eff_information3
		,p_eff_information4                =>  p_eff_information4
		,p_eff_information5                =>  p_eff_information5
		,p_eff_information6                =>  p_eff_information6
		,p_eff_information7                =>  p_eff_information7
		,p_eff_information8                =>  p_eff_information8
		,p_eff_information9                =>  p_eff_information9
		,p_eff_information10               =>  p_eff_information10
		,p_eff_information11               =>  p_eff_information11
		,p_eff_information12               =>  p_eff_information12
		,p_eff_information13               =>  p_eff_information13
		,p_eff_information14               =>  p_eff_information14
		,p_eff_information15               =>  p_eff_information15
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_eff_report_approvals'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	psp_era_ins.ins
		(p_effort_report_detail_id         =>  p_effort_report_detail_id
		,p_wf_role_name                	   =>  p_wf_role_name
		,p_wf_orig_system_id           	   =>  p_wf_orig_system_id
		,p_wf_orig_system              	   =>  p_wf_orig_system
		,p_approver_order_num          	   =>  p_approver_order_num
		,p_approval_status             	   =>  p_approval_status
		,p_response_date               	   =>  l_response_date
		,p_actual_cost_share           	   =>  p_actual_cost_share
		,p_overwritten_effort_percent  	   =>  p_overwritten_effort_percent
		,p_wf_item_key                 	   =>  p_wf_item_key
		,p_comments                    	   =>  p_comments
		,p_pera_information_category   	   =>  p_pera_information_category
		,p_pera_information1           	   =>  p_pera_information1
		,p_pera_information2           	   =>  p_pera_information2
		,p_pera_information3           	   =>  p_pera_information3
		,p_pera_information4           	   =>  p_pera_information4
		,p_pera_information5           	   =>  p_pera_information5
		,p_pera_information6           	   =>  p_pera_information6
		,p_pera_information7           	   =>  p_pera_information7
		,p_pera_information8           	   =>  p_pera_information8
		,p_pera_information9           	   =>  p_pera_information9
		,p_pera_information10          	   =>  p_pera_information10
		,p_pera_information11          	   =>  p_pera_information11
		,p_pera_information12          	   =>  p_pera_information12
		,p_pera_information13          	   =>  p_pera_information13
		,p_pera_information14          	   =>  p_pera_information14
		,p_pera_information15          	   =>  p_pera_information15
		,p_pera_information16          	   =>  p_pera_information16
		,p_pera_information17          	   =>  p_pera_information17
		,p_pera_information18          	   =>  p_pera_information18
		,p_pera_information19          	   =>  p_pera_information19
		,p_pera_information20          	   =>  p_pera_information20
		,p_wf_role_display_name        	   =>  p_wf_role_display_name
		,p_effort_report_approval_id   	   =>  l_effort_report_approval_id
		,p_object_version_number       	   =>  l_object_version_number
		,p_eff_information_category        =>  p_eff_information_category
		,p_eff_information1                =>  p_eff_information1
		,p_eff_information2                =>  p_eff_information2
		,p_eff_information3                =>  p_eff_information3
		,p_eff_information4                =>  p_eff_information4
		,p_eff_information5                =>  p_eff_information5
		,p_eff_information6                =>  p_eff_information6
		,p_eff_information7                =>  p_eff_information7
		,p_eff_information8                =>  p_eff_information8
		,p_eff_information9                =>  p_eff_information9
		,p_eff_information10               =>  p_eff_information10
		,p_eff_information11               =>  p_eff_information11
		,p_eff_information12               =>  p_eff_information12
		,p_eff_information13               =>  p_eff_information13
		,p_eff_information14               =>  p_eff_information14
		,p_eff_information15               =>  p_eff_information15
);

  --
  -- Call After Process User Hook
  --
  begin
     psp_eff_report_approvals_bk1.insert_eff_report_approvals_a
		(p_effort_report_approval_id       =>  l_effort_report_approval_id
		,p_effort_report_detail_id         =>  p_effort_report_detail_id
		,p_wf_role_name                    =>  p_wf_role_name
		,p_wf_orig_system_id               =>  p_wf_orig_system_id
		,p_wf_orig_system                  =>  p_wf_orig_system
		,p_approver_order_num              =>  p_approver_order_num
		,p_approval_status                 =>  p_approval_status
		,p_response_date                   =>  l_response_date
		,p_actual_cost_share               =>  p_actual_cost_share
		,p_overwritten_effort_percent      =>  p_overwritten_effort_percent
		,p_wf_item_key                     =>  p_wf_item_key
		,p_comments                        =>  p_comments
		,p_pera_information_category       =>  p_pera_information_category
		,p_pera_information1               =>  p_pera_information1
		,p_pera_information2               =>  p_pera_information2
		,p_pera_information3               =>  p_pera_information3
		,p_pera_information4               =>  p_pera_information4
		,p_pera_information5               =>  p_pera_information5
		,p_pera_information6               =>  p_pera_information6
		,p_pera_information7               =>  p_pera_information7
		,p_pera_information8               =>  p_pera_information8
		,p_pera_information9               =>  p_pera_information9
		,p_pera_information10              =>  p_pera_information10
		,p_pera_information11              =>  p_pera_information11
		,p_pera_information12              =>  p_pera_information12
		,p_pera_information13              =>  p_pera_information13
		,p_pera_information14              =>  p_pera_information14
		,p_pera_information15              =>  p_pera_information15
		,p_pera_information16              =>  p_pera_information16
		,p_pera_information17              =>  p_pera_information17
		,p_pera_information18              =>  p_pera_information18
		,p_pera_information19              =>  p_pera_information19
		,p_pera_information20              =>  p_pera_information20
		,p_wf_role_display_name            =>  p_wf_role_display_name
		,p_object_version_number           =>  l_object_version_number
		,p_eff_information_category        =>  p_eff_information_category
		,p_eff_information1                =>  p_eff_information1
		,p_eff_information2                =>  p_eff_information2
		,p_eff_information3                =>  p_eff_information3
		,p_eff_information4                =>  p_eff_information4
		,p_eff_information5                =>  p_eff_information5
		,p_eff_information6                =>  p_eff_information6
		,p_eff_information7                =>  p_eff_information7
		,p_eff_information8                =>  p_eff_information8
		,p_eff_information9                =>  p_eff_information9
		,p_eff_information10               =>  p_eff_information10
		,p_eff_information11               =>  p_eff_information11
		,p_eff_information12               =>  p_eff_information12
		,p_eff_information13               =>  p_eff_information13
		,p_eff_information14               =>  p_eff_information14
		,p_eff_information15               =>  p_eff_information15
		,p_return_status                   =>  l_return_status
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_eff_report_approvals'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number     := l_object_version_number;
  p_effort_report_approval_id := l_effort_report_approval_id;
  p_return_status             := l_return_status;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to insert_eff_report_approvals;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_effort_report_approval_id      := null;
    p_return_status         := l_return_status;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to insert_eff_report_approvals;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := null;
    p_effort_report_approval_id      := null;
    p_return_status         := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end insert_eff_report_approvals;








--
-- ----------------------------------------------------------------------------
-- |----------------------< update_eff_report_approvals >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_eff_report_approvals
(p_validate                       in            boolean  default false
,p_effort_report_approval_id      in            number
,p_effort_report_detail_id        in            number   default hr_api.g_number
,p_wf_role_name                   in            varchar2 default hr_api.g_varchar2
,p_wf_orig_system_id              in            number   default hr_api.g_number
,p_wf_orig_system                 in            varchar2 default hr_api.g_varchar2
,p_approver_order_num             in            number   default hr_api.g_number
,p_approval_status                in            varchar2 default hr_api.g_varchar2
,p_response_date                  in            date     default hr_api.g_date
,p_actual_cost_share              in            number   default hr_api.g_number
,p_overwritten_effort_percent     in            number   default hr_api.g_number
,p_wf_item_key                    in            varchar2 default hr_api.g_varchar2
,p_comments                       in            varchar2 default hr_api.g_varchar2
,p_pera_information_category      in            varchar2 default hr_api.g_varchar2
,p_pera_information1              in            varchar2 default hr_api.g_varchar2
,p_pera_information2              in            varchar2 default hr_api.g_varchar2
,p_pera_information3              in            varchar2 default hr_api.g_varchar2
,p_pera_information4              in            varchar2 default hr_api.g_varchar2
,p_pera_information5              in            varchar2 default hr_api.g_varchar2
,p_pera_information6              in            varchar2 default hr_api.g_varchar2
,p_pera_information7              in            varchar2 default hr_api.g_varchar2
,p_pera_information8              in            varchar2 default hr_api.g_varchar2
,p_pera_information9              in            varchar2 default hr_api.g_varchar2
,p_pera_information10             in            varchar2 default hr_api.g_varchar2
,p_pera_information11             in            varchar2 default hr_api.g_varchar2
,p_pera_information12             in            varchar2 default hr_api.g_varchar2
,p_pera_information13             in            varchar2 default hr_api.g_varchar2
,p_pera_information14             in            varchar2 default hr_api.g_varchar2
,p_pera_information15             in            varchar2 default hr_api.g_varchar2
,p_pera_information16             in            varchar2 default hr_api.g_varchar2
,p_pera_information17             in            varchar2 default hr_api.g_varchar2
,p_pera_information18             in            varchar2 default hr_api.g_varchar2
,p_pera_information19             in            varchar2 default hr_api.g_varchar2
,p_pera_information20             in            varchar2 default hr_api.g_varchar2
,p_wf_role_display_name           in            varchar2 default hr_api.g_varchar2
,p_eff_information_category       in            varchar2 default hr_api.g_varchar2
,p_eff_information1               in            varchar2 default hr_api.g_varchar2
,p_eff_information2               in            varchar2 default hr_api.g_varchar2
,p_eff_information3               in            varchar2 default hr_api.g_varchar2
,p_eff_information4               in            varchar2 default hr_api.g_varchar2
,p_eff_information5               in            varchar2 default hr_api.g_varchar2
,p_eff_information6               in            varchar2 default hr_api.g_varchar2
,p_eff_information7               in            varchar2 default hr_api.g_varchar2
,p_eff_information8               in            varchar2 default hr_api.g_varchar2
,p_eff_information9               in            varchar2 default hr_api.g_varchar2
,p_eff_information10              in            varchar2 default hr_api.g_varchar2
,p_eff_information11              in            varchar2 default hr_api.g_varchar2
,p_eff_information12              in            varchar2 default hr_api.g_varchar2
,p_eff_information13              in            varchar2 default hr_api.g_varchar2
,p_eff_information14              in            varchar2 default hr_api.g_varchar2
,p_eff_information15              in            varchar2 default hr_api.g_varchar2
,p_object_version_number          in out nocopy number
,p_return_status                     out nocopy boolean
) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_eff_report_approvals';
  l_response_date         date;
  l_object_version_number number(9);
  l_return_status         boolean;

  l_pera_information1 varchar2(150);
  l_pera_information2 varchar2(150);
  l_pera_information3 varchar2(150);
  l_pera_information4 varchar2(150);
  l_pera_information5 varchar2(150);
  l_pera_information6 varchar2(150);
  l_pera_information7 varchar2(150);
  l_pera_information8 varchar2(150);
  l_pera_information9 varchar2(150);
  l_pera_information10 varchar2(150);
  l_pera_information11 varchar2(150);
  l_pera_information12 varchar2(150);
  l_pera_information13 varchar2(150);
  l_pera_information14 varchar2(150);
  l_pera_information15 varchar2(150);
  l_pera_information16 varchar2(150);
  l_pera_information17 varchar2(150);
  l_pera_information18 varchar2(150);
  l_pera_information19 varchar2(150);
  l_pera_information20 varchar2(150);

  l_eff_information1 varchar2(150);
  l_eff_information2 varchar2(150);
  l_eff_information3 varchar2(150);
  l_eff_information4 varchar2(150);
  l_eff_information5 varchar2(150);
  l_eff_information6 varchar2(150);
  l_eff_information7 varchar2(150);
  l_eff_information8 varchar2(150);
  l_eff_information9 varchar2(150);
  l_eff_information10 varchar2(150);
  l_eff_information11 varchar2(150);
  l_eff_information12 varchar2(150);
  l_eff_information13 varchar2(150);
  l_eff_information14 varchar2(150);
  l_eff_information15 varchar2(150);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_eff_report_approvals;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_response_date := trunc(p_response_date);

  -- Remember all user hook dependent values
  l_pera_information1  := p_pera_information1;
  l_pera_information2  := p_pera_information2;
  l_pera_information3  := p_pera_information3;
  l_pera_information4  := p_pera_information4;
  l_pera_information5  := p_pera_information5;
  l_pera_information6  := p_pera_information6;
  l_pera_information7  := p_pera_information7;
  l_pera_information8  := p_pera_information8;
  l_pera_information9  := p_pera_information9;
  l_pera_information10 := p_pera_information10;
  l_pera_information11 := p_pera_information11;
  l_pera_information12 := p_pera_information12;
  l_pera_information13 := p_pera_information13;
  l_pera_information14 := p_pera_information14;
  l_pera_information15 := p_pera_information15;
  l_pera_information16 := p_pera_information16;
  l_pera_information17 := p_pera_information17;
  l_pera_information18 := p_pera_information18;
  l_pera_information19 := p_pera_information19;
  l_pera_information20 := p_pera_information20;

  l_eff_information1  := p_eff_information1;
  l_eff_information2  := p_eff_information2;
  l_eff_information3  := p_eff_information3;
  l_eff_information4  := p_eff_information4;
  l_eff_information5  := p_eff_information5;
  l_eff_information6  := p_eff_information6;
  l_eff_information7  := p_eff_information7;
  l_eff_information8  := p_eff_information8;
  l_eff_information9  := p_eff_information9;
  l_eff_information10 := p_eff_information10;
  l_eff_information11 := p_eff_information11;
  l_eff_information12 := p_eff_information12;
  l_eff_information13 := p_eff_information13;
  l_eff_information14 := p_eff_information14;
  l_eff_information15 := p_eff_information15;

  --
  -- Clear Global variables
  --
  g_pera_information1  := hr_api.g_varchar2;
  g_pera_information2  := hr_api.g_varchar2;
  g_pera_information3  := hr_api.g_varchar2;
  g_pera_information4  := hr_api.g_varchar2;
  g_pera_information5  := hr_api.g_varchar2;
  g_pera_information6  := hr_api.g_varchar2;
  g_pera_information7  := hr_api.g_varchar2;
  g_pera_information8  := hr_api.g_varchar2;
  g_pera_information9  := hr_api.g_varchar2;
  g_pera_information10 := hr_api.g_varchar2;
  g_pera_information11 := hr_api.g_varchar2;
  g_pera_information12 := hr_api.g_varchar2;
  g_pera_information13 := hr_api.g_varchar2;
  g_pera_information14 := hr_api.g_varchar2;
  g_pera_information15 := hr_api.g_varchar2;
  g_pera_information16 := hr_api.g_varchar2;
  g_pera_information17 := hr_api.g_varchar2;
  g_pera_information18 := hr_api.g_varchar2;
  g_pera_information19 := hr_api.g_varchar2;
  g_pera_information20 := hr_api.g_varchar2;

  g_eff_information1  := hr_api.g_varchar2;
  g_eff_information2  := hr_api.g_varchar2;
  g_eff_information3  := hr_api.g_varchar2;
  g_eff_information4  := hr_api.g_varchar2;
  g_eff_information5  := hr_api.g_varchar2;
  g_eff_information6  := hr_api.g_varchar2;
  g_eff_information7  := hr_api.g_varchar2;
  g_eff_information8  := hr_api.g_varchar2;
  g_eff_information9  := hr_api.g_varchar2;
  g_eff_information10 := hr_api.g_varchar2;
  g_eff_information11 := hr_api.g_varchar2;
  g_eff_information12 := hr_api.g_varchar2;
  g_eff_information13 := hr_api.g_varchar2;
  g_eff_information14 := hr_api.g_varchar2;
  g_eff_information15 := hr_api.g_varchar2;

  --
  -- Call Before Process User Hook
  --
  begin
    psp_eff_report_approvals_bk2.update_eff_report_approvals_b
		(p_effort_report_approval_id       =>  p_effort_report_approval_id
		,p_effort_report_detail_id         =>  p_effort_report_detail_id
		,p_wf_role_name                    =>  p_wf_role_name
		,p_wf_orig_system_id               =>  p_wf_orig_system_id
		,p_wf_orig_system                  =>  p_wf_orig_system
		,p_approver_order_num              =>  p_approver_order_num
		,p_approval_status                 =>  p_approval_status
		,p_response_date                   =>  l_response_date
		,p_actual_cost_share               =>  p_actual_cost_share
		,p_overwritten_effort_percent      =>  p_overwritten_effort_percent
		,p_wf_item_key                     =>  p_wf_item_key
		,p_comments                        =>  p_comments
		,p_pera_information_category       =>  p_pera_information_category
		,p_pera_information1               =>  l_pera_information1
		,p_pera_information2               =>  l_pera_information2
		,p_pera_information3               =>  l_pera_information3
		,p_pera_information4               =>  l_pera_information4
		,p_pera_information5               =>  l_pera_information5
		,p_pera_information6               =>  l_pera_information6
		,p_pera_information7               =>  l_pera_information7
		,p_pera_information8               =>  l_pera_information8
		,p_pera_information9               =>  l_pera_information9
		,p_pera_information10              =>  l_pera_information10
		,p_pera_information11              =>  l_pera_information11
		,p_pera_information12              =>  l_pera_information12
		,p_pera_information13              =>  l_pera_information13
		,p_pera_information14              =>  l_pera_information14
		,p_pera_information15              =>  l_pera_information15
		,p_pera_information16              =>  l_pera_information16
		,p_pera_information17              =>  l_pera_information17
		,p_pera_information18              =>  l_pera_information18
		,p_pera_information19              =>  l_pera_information19
		,p_pera_information20              =>  l_pera_information20
		,p_wf_role_display_name            =>  p_wf_role_display_name
		,p_object_version_number           =>  l_object_version_number
		,p_eff_information_category        =>  p_eff_information_category
		,p_eff_information1                =>  l_eff_information1
		,p_eff_information2                =>  l_eff_information2
		,p_eff_information3                =>  l_eff_information3
		,p_eff_information4                =>  l_eff_information4
		,p_eff_information5                =>  l_eff_information5
		,p_eff_information6                =>  l_eff_information6
		,p_eff_information7                =>  l_eff_information7
		,p_eff_information8                =>  l_eff_information8
		,p_eff_information9                =>  l_eff_information9
		,p_eff_information10               =>  l_eff_information10
		,p_eff_information11               =>  l_eff_information11
		,p_eff_information12               =>  l_eff_information12
		,p_eff_information13               =>  l_eff_information13
		,p_eff_information14               =>  l_eff_information14
		,p_eff_information15               =>  l_eff_information15
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_eff_report_approvals'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- If user has updated global pera_informations from before hook
  IF (g_pera_information1 <> hr_api.g_varchar2) THEN
    l_pera_information1 := g_pera_information1;
  END IF;
  IF (g_pera_information2 <> hr_api.g_varchar2) THEN
    l_pera_information2 := g_pera_information2;
  END IF;
  IF (g_pera_information3 <> hr_api.g_varchar2) THEN
    l_pera_information3 := g_pera_information3;
  END IF;
  IF (g_pera_information4 <> hr_api.g_varchar2) THEN
    l_pera_information4 := g_pera_information4;
  END IF;
  IF (g_pera_information5 <> hr_api.g_varchar2) THEN
    l_pera_information5 := g_pera_information5;
  END IF;
  IF (g_pera_information6 <> hr_api.g_varchar2) THEN
    l_pera_information6 := g_pera_information6;
  END IF;
  IF (g_pera_information7 <> hr_api.g_varchar2) THEN
    l_pera_information7 := g_pera_information7;
  END IF;
  IF (g_pera_information8 <> hr_api.g_varchar2) THEN
    l_pera_information8 := g_pera_information8;
  END IF;
  IF (g_pera_information9 <> hr_api.g_varchar2) THEN
    l_pera_information9 := g_pera_information9;
  END IF;
  IF (g_pera_information10 <> hr_api.g_varchar2) THEN
    l_pera_information10 := g_pera_information10;
  END IF;
  IF (g_pera_information11 <> hr_api.g_varchar2) THEN
    l_pera_information11 := g_pera_information11;
  END IF;
  IF (g_pera_information12 <> hr_api.g_varchar2) THEN
    l_pera_information12 := g_pera_information12;
  END IF;
  IF (g_pera_information13 <> hr_api.g_varchar2) THEN
    l_pera_information13 := g_pera_information13;
  END IF;
  IF (g_pera_information14 <> hr_api.g_varchar2) THEN
    l_pera_information14 := g_pera_information14;
  END IF;
  IF (g_pera_information15 <> hr_api.g_varchar2) THEN
    l_pera_information15 := g_pera_information15;
  END IF;
  IF (g_pera_information16 <> hr_api.g_varchar2) THEN
    l_pera_information16 := g_pera_information16;
  END IF;
  IF (g_pera_information17 <> hr_api.g_varchar2) THEN
    l_pera_information17 := g_pera_information17;
  END IF;
  IF (g_pera_information18 <> hr_api.g_varchar2) THEN
    l_pera_information18 := g_pera_information18;
  END IF;
  IF (g_pera_information19 <> hr_api.g_varchar2) THEN
    l_pera_information19 := g_pera_information19;
  END IF;
  IF (g_pera_information20 <> hr_api.g_varchar2) THEN
    l_pera_information20 := g_pera_information20;
  END IF;


  IF (g_eff_information1 <> hr_api.g_varchar2) THEN
    l_eff_information1 := g_eff_information1;
  END IF;
  IF (g_eff_information2 <> hr_api.g_varchar2) THEN
    l_eff_information2 := g_eff_information2;
  END IF;
  IF (g_eff_information3 <> hr_api.g_varchar2) THEN
    l_eff_information3 := g_eff_information3;
  END IF;
  IF (g_eff_information4 <> hr_api.g_varchar2) THEN
    l_eff_information4 := g_eff_information4;
  END IF;
  IF (g_eff_information5 <> hr_api.g_varchar2) THEN
    l_eff_information5 := g_eff_information5;
  END IF;
  IF (g_eff_information6 <> hr_api.g_varchar2) THEN
    l_eff_information6 := g_eff_information6;
  END IF;
  IF (g_eff_information7 <> hr_api.g_varchar2) THEN
    l_eff_information7 := g_eff_information7;
  END IF;
  IF (g_eff_information8 <> hr_api.g_varchar2) THEN
    l_eff_information8 := g_eff_information8;
  END IF;
  IF (g_eff_information9 <> hr_api.g_varchar2) THEN
    l_eff_information9 := g_eff_information9;
  END IF;
  IF (g_eff_information10 <> hr_api.g_varchar2) THEN
    l_eff_information10 := g_eff_information10;
  END IF;
  IF (g_eff_information11 <> hr_api.g_varchar2) THEN
    l_eff_information11 := g_eff_information11;
  END IF;
  IF (g_eff_information12 <> hr_api.g_varchar2) THEN
    l_eff_information12 := g_eff_information12;
  END IF;
  IF (g_eff_information13 <> hr_api.g_varchar2) THEN
    l_eff_information13 := g_eff_information13;
  END IF;
  IF (g_eff_information14 <> hr_api.g_varchar2) THEN
    l_eff_information14 := g_eff_information14;
  END IF;
  IF (g_eff_information15 <> hr_api.g_varchar2) THEN
    l_eff_information15 := g_eff_information15;
  END IF;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   psp_era_upd.upd
		(p_effort_report_approval_id       =>  p_effort_report_approval_id
		,p_object_version_number      	   =>  l_object_version_number
		,p_effort_report_detail_id    	   =>  p_effort_report_detail_id
		,p_wf_role_name               	   =>  p_wf_role_name
		,p_wf_orig_system_id          	   =>  p_wf_orig_system_id
		,p_wf_orig_system             	   =>  p_wf_orig_system
		,p_approver_order_num         	   =>  p_approver_order_num
		,p_approval_status            	   =>  p_approval_status
		,p_response_date              	   =>  l_response_date
		,p_actual_cost_share          	   =>  p_actual_cost_share
		,p_overwritten_effort_percent 	   =>  p_overwritten_effort_percent
		,p_wf_item_key                	   =>  p_wf_item_key
		,p_comments                   	   =>  p_comments
		,p_pera_information_category  	   =>  p_pera_information_category
		,p_pera_information1          	   =>  l_pera_information1
		,p_pera_information2          	   =>  l_pera_information2
		,p_pera_information3          	   =>  l_pera_information3
		,p_pera_information4          	   =>  l_pera_information4
		,p_pera_information5          	   =>  l_pera_information5
		,p_pera_information6          	   =>  l_pera_information6
		,p_pera_information7          	   =>  l_pera_information7
		,p_pera_information8          	   =>  l_pera_information8
		,p_pera_information9          	   =>  l_pera_information9
		,p_pera_information10         	   =>  l_pera_information10
		,p_pera_information11         	   =>  l_pera_information11
		,p_pera_information12         	   =>  l_pera_information12
		,p_pera_information13         	   =>  l_pera_information13
		,p_pera_information14         	   =>  l_pera_information14
		,p_pera_information15         	   =>  l_pera_information15
		,p_pera_information16         	   =>  l_pera_information16
		,p_pera_information17         	   =>  l_pera_information17
		,p_pera_information18         	   =>  l_pera_information18
		,p_pera_information19         	   =>  l_pera_information19
		,p_pera_information20         	   =>  l_pera_information20
		,p_wf_role_display_name       	   =>  p_wf_role_display_name
		,p_eff_information_category        =>  p_eff_information_category
		,p_eff_information1                =>  l_eff_information1
		,p_eff_information2                =>  l_eff_information2
		,p_eff_information3                =>  l_eff_information3
		,p_eff_information4                =>  l_eff_information4
		,p_eff_information5                =>  l_eff_information5
		,p_eff_information6                =>  l_eff_information6
		,p_eff_information7                =>  l_eff_information7
		,p_eff_information8                =>  l_eff_information8
		,p_eff_information9                =>  l_eff_information9
		,p_eff_information10               =>  l_eff_information10
		,p_eff_information11               =>  l_eff_information11
		,p_eff_information12               =>  l_eff_information12
		,p_eff_information13               =>  l_eff_information13
		,p_eff_information14               =>  l_eff_information14
		,p_eff_information15               =>  l_eff_information15
		);



  --
  -- Call After Process User Hook
  --
  begin
    psp_eff_report_approvals_bk2.update_eff_report_approvals_a
		(p_effort_report_approval_id       =>  p_effort_report_approval_id
		,p_effort_report_detail_id         =>  p_effort_report_detail_id
		,p_wf_role_name                    =>  p_wf_role_name
		,p_wf_orig_system_id               =>  p_wf_orig_system_id
		,p_wf_orig_system                  =>  p_wf_orig_system
		,p_approver_order_num              =>  p_approver_order_num
		,p_approval_status                 =>  p_approval_status
		,p_response_date                   =>  l_response_date
		,p_actual_cost_share               =>  p_actual_cost_share
		,p_overwritten_effort_percent      =>  p_overwritten_effort_percent
		,p_wf_item_key                     =>  p_wf_item_key
		,p_comments                        =>  p_comments
		,p_pera_information_category       =>  p_pera_information_category
		,p_pera_information1               =>  l_pera_information1
		,p_pera_information2               =>  l_pera_information2
		,p_pera_information3               =>  l_pera_information3
		,p_pera_information4               =>  l_pera_information4
		,p_pera_information5               =>  l_pera_information5
		,p_pera_information6               =>  l_pera_information6
		,p_pera_information7               =>  l_pera_information7
		,p_pera_information8               =>  l_pera_information8
		,p_pera_information9               =>  l_pera_information9
		,p_pera_information10              =>  l_pera_information10
		,p_pera_information11              =>  l_pera_information11
		,p_pera_information12              =>  l_pera_information12
		,p_pera_information13              =>  l_pera_information13
		,p_pera_information14              =>  l_pera_information14
		,p_pera_information15              =>  l_pera_information15
		,p_pera_information16              =>  l_pera_information16
		,p_pera_information17              =>  l_pera_information17
		,p_pera_information18              =>  l_pera_information18
		,p_pera_information19              =>  l_pera_information19
		,p_pera_information20              =>  l_pera_information20
		,p_wf_role_display_name            =>  p_wf_role_display_name
		,p_object_version_number           =>  l_object_version_number
		,p_eff_information_category        =>  p_eff_information_category
		,p_eff_information1                =>  l_eff_information1
		,p_eff_information2                =>  l_eff_information2
		,p_eff_information3                =>  l_eff_information3
		,p_eff_information4                =>  l_eff_information4
		,p_eff_information5                =>  l_eff_information5
		,p_eff_information6                =>  l_eff_information6
		,p_eff_information7                =>  l_eff_information7
		,p_eff_information8                =>  l_eff_information8
		,p_eff_information9                =>  l_eff_information9
		,p_eff_information10               =>  l_eff_information10
		,p_eff_information11               =>  l_eff_information11
		,p_eff_information12               =>  l_eff_information12
		,p_eff_information13               =>  l_eff_information13
		,p_eff_information14               =>  l_eff_information14
		,p_eff_information15               =>  l_eff_information15
		,p_return_status                   =>  l_return_status
		);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_eff_report_approvals'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  p_return_status          := l_return_status;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_eff_report_approvals;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_return_status          := l_return_status;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_eff_report_approvals;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_return_status          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_eff_report_approvals;




--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_eff_report_approvals >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eff_report_approvals
( p_validate                     in             boolean  default false
, p_effort_report_approval_id    in             number
, p_object_version_number        in out nocopy  number
, p_return_status                   out	nocopy  boolean
)
IS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_eff_report_approvals_line';
  l_object_version_number  number(9);
  l_return_status          boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eff_report_approvals;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
    psp_eff_report_approvals_bk3.delete_eff_report_approvals_b
	( p_effort_report_approval_id      =>   p_effort_report_approval_id
	, p_object_version_number          =>   l_object_version_number
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_cap'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  psp_era_del.del
	( p_effort_report_approval_id      =>   p_effort_report_approval_id
	, p_object_version_number          =>   l_object_version_number
	);


  --
  -- Call After Process User Hook
  --
  begin
     psp_eff_report_approvals_bk3.delete_eff_report_approvals_a
	( p_effort_report_approval_id      =>   p_effort_report_approval_id
	, p_object_version_number          =>   l_object_version_number
	, p_return_status                  =>   l_return_status
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_cap'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  p_return_status          := l_return_status;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_eff_report_approvals;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_return_status          := l_return_status;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_eff_report_approvals;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_return_status          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_eff_report_approvals;


end psp_eff_report_approvals_api;

/
