--------------------------------------------------------
--  DDL for Package Body PSP_TEMPLATE_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_TEMPLATE_DETAILS_API" as
/* $Header: PSPRDAIB.pls 120.0 2005/06/02 15:55:43 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' PSP_TEMPLATE_DETAILS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <BUS_PROCESS_NAME> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_TEMPLATE_DETAILS
  (   P_VALIDATE                      in     boolean  default false
	, P_TEMPLATE_ID                     in        NUMBER
	, P_CRITERIA_LOOKUP_TYPE            in        VARCHAR2
	, P_CRITERIA_LOOKUP_CODE            in        VARCHAR2
	, P_INCLUDE_EXCLUDE_FLAG            in        VARCHAR2
	, P_CRITERIA_VALUE1                 in        VARCHAR2
	, P_CRITERIA_VALUE2                 in        VARCHAR2
	, P_CRITERIA_VALUE3                 in        VARCHAR2
    , P_TEMPLATE_DETAIL_ID		    in      NUMBER
    , P_OBJECT_VERSION_NUMBER       out nocopy      NUMBER
    , P_WARNING                     out nocopy      boolean
    , P_RETURN_STATUS               out nocopy      boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'Create_TEMPLATE_DETAILS';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Create_TEMPLATE_DETAILS;
  --
  -- Remember IN OUT parameter IN values
  --
--  l_in_out_parameter := p_in_out_parameter;

  --
  -- Truncate the time portion from all IN date parameters
  --
--  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    PSP_TEMPLATE_DETAILS_BK1.Create_TEMPLATE_DETAILS_b
      (	  P_TEMPLATE_ID          		=>	P_TEMPLATE_ID
		, P_CRITERIA_LOOKUP_TYPE 		=>	P_CRITERIA_LOOKUP_TYPE
		, P_CRITERIA_LOOKUP_CODE 		=>	P_CRITERIA_LOOKUP_CODE
		, P_INCLUDE_EXCLUDE_FLAG 		=>	P_INCLUDE_EXCLUDE_FLAG
		, P_CRITERIA_VALUE1      		=>	P_CRITERIA_VALUE1
		, P_CRITERIA_VALUE2      		=>	P_CRITERIA_VALUE2
		, P_CRITERIA_VALUE3     		=>	P_CRITERIA_VALUE3
		 , P_TEMPLATE_DETAIL_ID		    =>	P_TEMPLATE_DETAIL_ID
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_TEMPLATE_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  psp_rtd_ins.ins
	   ( p_template_id           		=>	p_template_id
		,p_include_exclude_flag  		=>	p_include_exclude_flag
		,p_criteria_lookup_type  		=>	p_criteria_lookup_type
		,p_criteria_lookup_code  		=>	p_criteria_lookup_code
		,p_criteria_value1       		=>	p_criteria_value1
		,p_criteria_value2       		=>	p_criteria_value2
		,p_criteria_value3       		=>	p_criteria_value3
		,p_template_detail_id    		=>	p_template_detail_id
		,p_object_version_number 		=>	p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    PSP_TEMPLATE_DETAILS_BK1.Create_TEMPLATE_DETAILS_a
      (	 P_TEMPLATE_ID              	=>	P_TEMPLATE_ID
		, P_CRITERIA_LOOKUP_TYPE    	=>	P_CRITERIA_LOOKUP_TYPE
		, P_CRITERIA_LOOKUP_CODE    	=>	P_CRITERIA_LOOKUP_CODE
		, P_INCLUDE_EXCLUDE_FLAG    	=>	P_INCLUDE_EXCLUDE_FLAG
		, P_CRITERIA_VALUE1         	=>	P_CRITERIA_VALUE1
		, P_CRITERIA_VALUE2         	=>	P_CRITERIA_VALUE2
		, P_CRITERIA_VALUE3        	    =>	P_CRITERIA_VALUE3
		, P_TEMPLATE_DETAIL_ID      	=>	P_TEMPLATE_DETAIL_ID
		, P_OBJECT_VERSION_NUMBER 	=>	P_OBJECT_VERSION_NUMBER
		, P_WARNING               	=>	P_WARNING
		, P_RETURN_STATUS         	=>	P_RETURN_STATUS

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_TEMPLATE_DETAILS'
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
  --  p_id                     := <local_var_set_in_process_logic>;
  --  p_in_out_parameter       := <local_var_set_in_process_logic>;
  --  p_object_version_number  := <local_var_set_in_process_logic>;
  --  p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Create_TEMPLATE_DETAILS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Create_TEMPLATE_DETAILS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Create_TEMPLATE_DETAILS;







--
-- ----------------------------------------------------------------------------
-- |--------------------------< <BUS_PROCESS_NAME> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_TEMPLATE_DETAILS
  (   P_VALIDATE                      in     boolean  default false
	, P_TEMPLATE_ID                     in        NUMBER
	, P_CRITERIA_LOOKUP_TYPE            in        VARCHAR2
	, P_CRITERIA_LOOKUP_CODE            in        VARCHAR2
	, P_INCLUDE_EXCLUDE_FLAG            in        VARCHAR2
	, P_CRITERIA_VALUE1                 in        VARCHAR2
	, P_CRITERIA_VALUE2                 in        VARCHAR2
	, P_CRITERIA_VALUE3                 in        VARCHAR2
    , P_TEMPLATE_DETAIL_ID            in out nocopy      NUMBER
   , P_OBJECT_VERSION_NUMBER       in out nocopy      NUMBER
   , P_WARNING                     out nocopy      boolean
   , P_RETURN_STATUS               out nocopy      boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'Update_TEMPLATE_DETAILS';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_TEMPLATE_DETAILS;
  --
  -- Remember IN OUT parameter IN values
  --
--  l_in_out_parameter := p_in_out_parameter;

  --
  -- Truncate the time portion from all IN date parameters
  --
--  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    PSP_TEMPLATE_DETAILS_BK2.Update_TEMPLATE_DETAILS_b
      (	  P_TEMPLATE_ID           	=>	P_TEMPLATE_ID
		, P_CRITERIA_LOOKUP_TYPE		=>	P_CRITERIA_LOOKUP_TYPE
		, P_CRITERIA_LOOKUP_CODE		=>	P_CRITERIA_LOOKUP_CODE
		, P_INCLUDE_EXCLUDE_FLAG		=>	P_INCLUDE_EXCLUDE_FLAG
		, P_CRITERIA_VALUE1     		=>	P_CRITERIA_VALUE1
		, P_CRITERIA_VALUE2     		=>	P_CRITERIA_VALUE2
		, P_CRITERIA_VALUE3     		=>	P_CRITERIA_VALUE3
		 , P_TEMPLATE_DETAIL_ID		    =>	P_TEMPLATE_DETAIL_ID
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_TEMPLATE_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    psp_rtd_upd.upd
	   ( p_template_detail_id     		=>	p_template_detail_id
		,p_object_version_number   		=>	p_object_version_number
		,p_template_id             		=>	p_template_id
		,p_include_exclude_flag    		=>	p_include_exclude_flag
		,p_criteria_lookup_type    		=>	p_criteria_lookup_type
		,p_criteria_lookup_code    		=>	p_criteria_lookup_code
		,p_criteria_value1         		=>	p_criteria_value1
		,p_criteria_value2         		=>	p_criteria_value2
		,p_criteria_value3         		=>	p_criteria_value3
        );



  --
  -- Call After Process User Hook
  --
  begin
    PSP_TEMPLATE_DETAILS_BK2.Update_TEMPLATE_DETAILS_a
      (	  P_TEMPLATE_ID            		=>	P_TEMPLATE_ID
		, P_CRITERIA_LOOKUP_TYPE   		=>	P_CRITERIA_LOOKUP_TYPE
		, P_CRITERIA_LOOKUP_CODE   		=>	P_CRITERIA_LOOKUP_CODE
		, P_INCLUDE_EXCLUDE_FLAG   		=>	P_INCLUDE_EXCLUDE_FLAG
		, P_CRITERIA_VALUE1        		=>	P_CRITERIA_VALUE1
		, P_CRITERIA_VALUE2        		=>	P_CRITERIA_VALUE2
		, P_CRITERIA_VALUE3        		=>	P_CRITERIA_VALUE3
		, P_TEMPLATE_DETAIL_ID     		=>	P_TEMPLATE_DETAIL_ID
		, P_OBJECT_VERSION_NUMBER		=>	P_OBJECT_VERSION_NUMBER
		, P_WARNING              		=>	P_WARNING
		, P_RETURN_STATUS        		=>	P_RETURN_STATUS
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_TEMPLATE_DETAILS'
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
--  p_id                     := <local_var_set_in_process_logic>;
--  p_in_out_parameter       := <local_var_set_in_process_logic>;
--  p_object_version_number  := <local_var_set_in_process_logic>;
--  p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Update_TEMPLATE_DETAILS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_TEMPLATE_DETAILS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_TEMPLATE_DETAILS;













--
-- ----------------------------------------------------------------------------
-- |--------------------------< <BUS_PROCESS_NAME> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Delete_TEMPLATE_DETAILS
  ( P_VALIDATE                       in     BOOLEAN default false
  , P_TEMPLATE_DETAIL_ID            in    NUMBER
  ,P_OBJECT_VERSION_NUMBER          in out nocopy number
  ,P_WARNING                       out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'Delete_TEMPLATE_DETAILS';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Delete_TEMPLATE_DETAILS;
  --
  -- Remember IN OUT parameter IN values
  --
--  l_in_out_parameter := p_in_out_parameter;

  --
  -- Truncate the time portion from all IN date parameters
  --
--  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    PSP_TEMPLATE_DETAILS_BK3.Delete_TEMPLATE_DETAILS_b
      (	P_TEMPLATE_DETAIL_ID   => P_TEMPLATE_DETAIL_ID
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_TEMPLATE_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    psp_rtd_del.del
   	   ( p_template_detail_id         	=>	p_template_detail_id
		,p_object_version_number      	=>	p_object_version_number
        );



  --
  -- Call After Process User Hook
  --
  begin
    PSP_TEMPLATE_DETAILS_BK3.Delete_TEMPLATE_DETAILS_a
      (			P_TEMPLATE_DETAIL_ID       		=>	P_TEMPLATE_DETAIL_ID
		,P_OBJECT_VERSION_NUMBER 		=>	P_OBJECT_VERSION_NUMBER
		,P_WARNING               		=>	P_WARNING

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_TEMPLATE_DETAILS'
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
--  p_id                     := <local_var_set_in_process_logic>;
--  p_in_out_parameter       := <local_var_set_in_process_logic>;
--  p_object_version_number  := <local_var_set_in_process_logic>;
--  p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Delete_TEMPLATE_DETAILS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Delete_TEMPLATE_DETAILS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Delete_TEMPLATE_DETAILS;

--
end PSP_TEMPLATE_DETAILS_API;

/
