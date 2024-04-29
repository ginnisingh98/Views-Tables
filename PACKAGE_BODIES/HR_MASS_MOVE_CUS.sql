--------------------------------------------------------
--  DDL for Package Body HR_MASS_MOVE_CUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MASS_MOVE_CUS" as
/* $Header: pemmvcus.pkb 115.1 99/07/18 14:02:46 porting ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_mass_move_cus.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< pre_move_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure pre_move_emp_asg
  (p_effective_date        in  		date
  ,p_assignment_id	   in  		number
  ,p_object_version_number in    	number
  ,p_mass_move_id	   in  		number   default hr_api.g_number
  ,p_position_id           in  		number   default hr_api.g_number
  ,p_organization_id	   in  		number   default hr_api.g_number
  ,p_location_id	   in  		number   default hr_api.g_number
  ,p_frequency	           in  		varchar2 default hr_api.g_varchar2
  ,p_normal_hours	   in  		number   default hr_api.g_number
  ,p_time_normal_finish    in  		varchar2 default hr_api.g_varchar2
  ,p_time_normal_start     in  		varchar2 default hr_api.g_varchar2
  ,p_segment1              in  		varchar2 default hr_api.g_varchar2
  ,p_segment2              in  		varchar2 default hr_api.g_varchar2
  ,p_segment3              in  		varchar2 default hr_api.g_varchar2
  ,p_segment4              in  		varchar2 default hr_api.g_varchar2
  ,p_segment5              in  		varchar2 default hr_api.g_varchar2
  ,p_segment6              in  		varchar2 default hr_api.g_varchar2
  ,p_segment7              in  		varchar2 default hr_api.g_varchar2
  ,p_segment8              in  		varchar2 default hr_api.g_varchar2
  ,p_segment9              in  		varchar2 default hr_api.g_varchar2
  ,p_segment10             in  		varchar2 default hr_api.g_varchar2
  ,p_segment11             in  		varchar2 default hr_api.g_varchar2
  ,p_segment12             in  		varchar2 default hr_api.g_varchar2
  ,p_segment13             in  		varchar2 default hr_api.g_varchar2
  ,p_segment14             in  		varchar2 default hr_api.g_varchar2
  ,p_segment15             in  		varchar2 default hr_api.g_varchar2
  ,p_segment16             in  		varchar2 default hr_api.g_varchar2
  ,p_segment17             in  		varchar2 default hr_api.g_varchar2
  ,p_segment18             in  		varchar2 default hr_api.g_varchar2
  ,p_segment19             in  		varchar2 default hr_api.g_varchar2
  ,p_segment20             in  		varchar2 default hr_api.g_varchar2
  ,p_segment21             in  		varchar2 default hr_api.g_varchar2
  ,p_segment22             in  		varchar2 default hr_api.g_varchar2
  ,p_segment23             in  		varchar2 default hr_api.g_varchar2
  ,p_segment24             in  		varchar2 default hr_api.g_varchar2
  ,p_segment25             in  		varchar2 default hr_api.g_varchar2
  ,p_segment26             in  		varchar2 default hr_api.g_varchar2
  ,p_segment27             in  		varchar2 default hr_api.g_varchar2
  ,p_segment28             in  		varchar2 default hr_api.g_varchar2
  ,p_segment29             in  		varchar2 default hr_api.g_varchar2
  ,p_segment30             in  		varchar2 default hr_api.g_varchar2
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'pre_move_emp_asg';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Customers should enter their own custom code here!
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --
end pre_move_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< post_move_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure post_move_emp_asg
  (p_validate		   	in	boolean  default false
  ,p_old_asg_eff_start_date 	in out  date
  ,p_new_asg_eff_start_date 	in out  date
  ,p_assignment_id	   	in  	number
  ,p_old_asg_object_version_num in out  number
  ,p_new_asg_object_version_num in out  number
  ,p_mass_move_id	   	in   	number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'post_move_emp_asg';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Customers should enter their own custom code here!
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --

end post_move_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< pre_move_position >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure pre_move_position
  (p_position_id	   in  		number
  ,p_object_version_number in    	number
  ,p_date_effective        in  		date
  ,p_business_group_id	   in		number
  ,p_organization_id	   in  		number
  ,p_segment1              in  		varchar2 default hr_api.g_varchar2
  ,p_segment2              in  		varchar2 default hr_api.g_varchar2
  ,p_segment3              in  		varchar2 default hr_api.g_varchar2
  ,p_segment4              in  		varchar2 default hr_api.g_varchar2
  ,p_segment5              in  		varchar2 default hr_api.g_varchar2
  ,p_segment6              in  		varchar2 default hr_api.g_varchar2
  ,p_segment7              in  		varchar2 default hr_api.g_varchar2
  ,p_segment8              in  		varchar2 default hr_api.g_varchar2
  ,p_segment9              in  		varchar2 default hr_api.g_varchar2
  ,p_segment10             in  		varchar2 default hr_api.g_varchar2
  ,p_segment11             in  		varchar2 default hr_api.g_varchar2
  ,p_segment12             in  		varchar2 default hr_api.g_varchar2
  ,p_segment13             in  		varchar2 default hr_api.g_varchar2
  ,p_segment14             in  		varchar2 default hr_api.g_varchar2
  ,p_segment15             in  		varchar2 default hr_api.g_varchar2
  ,p_segment16             in  		varchar2 default hr_api.g_varchar2
  ,p_segment17             in  		varchar2 default hr_api.g_varchar2
  ,p_segment18             in  		varchar2 default hr_api.g_varchar2
  ,p_segment19             in  		varchar2 default hr_api.g_varchar2
  ,p_segment20             in  		varchar2 default hr_api.g_varchar2
  ,p_segment21             in  		varchar2 default hr_api.g_varchar2
  ,p_segment22             in  		varchar2 default hr_api.g_varchar2
  ,p_segment23             in  		varchar2 default hr_api.g_varchar2
  ,p_segment24             in  		varchar2 default hr_api.g_varchar2
  ,p_segment25             in  		varchar2 default hr_api.g_varchar2
  ,p_segment26             in  		varchar2 default hr_api.g_varchar2
  ,p_segment27             in  		varchar2 default hr_api.g_varchar2
  ,p_segment28             in  		varchar2 default hr_api.g_varchar2
  ,p_segment29             in  		varchar2 default hr_api.g_varchar2
  ,p_segment30             in  		varchar2 default hr_api.g_varchar2
  ,p_deactivate_old_position in		boolean  default false
  ,p_mass_move_id	   in  		number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                	varchar2(72) := g_package||'pre_move_position';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Customers should enter their own custom code here!
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --

end pre_move_position;
--
-- ----------------------------------------------------------------------------
-- |------------------------< post_move_position >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure post_move_position
  (p_validate		   	in	boolean  default false
  ,p_position_id		in	number
  ,p_object_version_number	in out	number
  ,p_date_effective		in	date
  ,p_business_group_id		in	number
  ,p_organization_id		in	number
  ,p_deactivate_old_position	in	boolean  default false
  ,p_new_position_id		in	number
  ,p_new_object_version_number	in out	number
  ,p_mass_move_id	   	in   	number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'post_move_position';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Customers should enter their own custom code here!
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --

end post_move_position;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< pre_mass_move >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure pre_mass_move
  (p_mass_move_id	   in  		number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'pre_mass_move';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Customers should enter their own custom code here!
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --
end pre_mass_move;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< post_mass_move >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure post_mass_move
  (p_mass_move_id	   	in   	number   default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'post_mass_move';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Customers should enter their own custom code here!
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --
end post_mass_move;
--
end hr_mass_move_cus;

/
