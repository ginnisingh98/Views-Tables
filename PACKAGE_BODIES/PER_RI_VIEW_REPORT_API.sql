--------------------------------------------------------
--  DDL for Package Body PER_RI_VIEW_REPORT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_VIEW_REPORT_API" AS
/* $Header: pervrapi.pkb 120.1 2006/06/12 23:58:23 ndorai noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'per_ri_view_report_api.';
--
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- |-----------------------------< create_view_report >--------------------------|
-- ----------------------------------------------------------------------------------
--
Procedure create_view_report
  (   p_validate                       In  Boolean   Default False
     ,p_workbench_view_report_code     In Varchar2
     ,p_workbench_view_report_name     In Varchar2
     ,p_wb_view_report_description     In Varchar2
     ,p_workbench_item_code            In Varchar2
     ,p_workbench_view_report_type     In Varchar2
     ,p_workbench_view_report_action   In Varchar2
     ,p_workbench_view_country         In Varchar2
     ,p_wb_view_report_instruction     In Varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          Out Nocopy Number
     ,p_primary_industry	       In Varchar2
     ,p_enabled_flag               In Varchar2 Default 'Y'
  ) Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  Varchar2(72) := g_package||'create_view_report';
  l_object_version_number per_ri_view_reports.object_version_number%TYPE;
  l_language_code         per_ri_view_reports_tl.language%TYPE;
  l_effective_date        Date;
  l_workbench_item_creation_date Date;
  l_workbench_item_code per_ri_view_reports.workbench_item_code%TYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint create_view_report;
  --
  hr_utility.set_location(l_proc, 15);
  per_rvr_ins.set_base_key_value (p_workbench_view_report_code  => p_workbench_view_report_code );
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_effective_date := trunc (p_effective_date);

  --
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);

  -- Process Logic
  --
  -- Insert non-translatable rows into PER_RI_VIEW_REPORTS first
   per_rvr_ins.ins
    (p_workbench_view_report_code       => p_workbench_view_report_code
    ,p_workbench_item_code              => p_workbench_item_code
    ,p_workbench_view_report_type       => p_workbench_view_report_type
    ,p_workbench_view_report_action   	 => p_workbench_view_report_action
    ,p_workbench_view_country         	 => p_workbench_view_country
    ,p_wb_view_report_instruction     	 => p_wb_view_report_instruction
    ,p_object_version_number          	 => p_object_version_number
    ,p_primary_industry			        => p_primary_industry
    ,p_enabled_flag                     => p_enabled_flag
    );


  --
  --  Now insert translatable rows in PER_RI_VIEW_REPORTS_TL table
  per_rvt_ins.ins_tl
      (p_workbench_view_report_code   =>p_workbench_view_report_code
	   ,p_workbench_view_report_name   =>p_workbench_view_report_name
	   ,p_wb_view_report_description   =>p_wb_view_report_description
	   ,p_language_code                =>p_language_code
      ) ;

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  If p_validate Then
    Raise hr_api.validate_enabled;
  End If;
  --
  -- Set all output arguments
  --
    p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
Exception
  --
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To create_view_report;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To create_view_report;
    -- Set OUT parameters.
    p_object_version_number  := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
   --
End create_view_report;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_view_report >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_view_report
  (   p_validate                       In  Boolean   Default False
     ,p_workbench_view_report_code     In Varchar2
     ,p_workbench_view_report_name     In Varchar2   Default hr_api.g_varchar2
     ,p_wb_view_report_description     In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_item_code            In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_view_report_type     In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_view_report_action   In Varchar2   Default hr_api.g_varchar2
     ,p_workbench_view_country         In Varchar2   Default hr_api.g_varchar2
     ,p_wb_view_report_instruction     In Varchar2   Default hr_api.g_varchar2
     ,p_language_code                  In  Varchar2  Default hr_api.userenv_lang
     ,p_effective_date                 In  Date
     ,p_object_version_number          In Out Nocopy Number
     ,p_primary_industry	       In Varchar2  Default hr_api.g_varchar2
     ,p_enabled_flag               In Varchar2 Default 'Y'
  )  Is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_view_report';
  l_object_version_number per_ri_view_reports.object_version_number%TYPE;
  l_language_code         per_ri_view_reports_tl.language%TYPE;
  l_workbench_item_creation_date Date;
  l_effective_date        DATE;

  l_temp_ovn   number := p_object_version_number;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_view_report;
  --
  --
  --  All date input parameters must be truncated to remove time elements
  --
  l_effective_date := trunc (p_effective_date);

  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to be
  -- passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Insert non-translatable rows in PER_RI_VIEW_REPORTS Table
  --
   per_rvr_upd.upd
    (p_workbench_view_report_code        => p_workbench_view_report_code
    ,p_workbench_item_code               => p_workbench_item_code
    ,p_workbench_view_report_type        => p_workbench_view_report_type
    ,p_workbench_view_report_action   	 => p_workbench_view_report_action
    ,p_workbench_view_country         	 => p_workbench_view_country
    ,p_wb_view_report_instruction     	 => p_wb_view_report_instruction
    ,p_object_version_number          	 => l_object_version_number
    ,p_primary_industry                  => p_primary_industry
    ,p_enabled_flag                      => p_enabled_flag
    );
  --
  --  Now insert translatable rows in PER_RI_VIEW_REPORTS_TL table

  per_rvt_upd.upd_tl
      (p_workbench_view_report_code        => p_workbench_view_report_code
	   ,p_workbench_view_report_name   => p_workbench_view_report_name
	   ,p_wb_view_report_description   => p_wb_view_report_description
	   ,p_language_code                => p_language_code
      ) ;

  --

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  If p_validate Then
    Raise hr_api.validate_enabled;
  End If;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
Exception
  --
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To update_view_report;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To update_view_report;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
    --
End update_view_report;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_view_report >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_view_report
   (  p_validate                     In Boolean Default False
     ,p_workbench_view_report_code   In Varchar2
     ,p_object_version_number        IN Number )

Is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc Varchar2(72) := g_package||'delete_view_report';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  Savepoint delete_view_report;

 --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  per_rvr_shd.lck ( p_workbench_view_report_code    => p_workbench_view_report_code,
                    p_object_version_number         => p_object_version_number );
  --
  --  Remove all matching translation rows
  --
  hr_utility.set_location( l_proc, 35);

  per_rvt_del.del_tl( p_workbench_view_report_code => p_workbench_view_report_code );
  --
  --  Remove non-translated data row
  --
  hr_utility.set_location( l_proc, 40);

  per_rvr_del.del(p_workbench_view_report_code   => p_workbench_view_report_code,
                  p_object_version_number        => p_object_version_number );
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  If p_validate Then
     Raise hr_api.validate_enabled;
  End If;
  --
  --
Exception
  --
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To delete_view_report;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occurred
    Rollback To delete_view_report;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
    --
End delete_view_report;

--

End per_ri_view_report_api;

/
