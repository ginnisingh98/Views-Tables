--------------------------------------------------------
--  DDL for Package Body PSP_REPORT_TEMPLATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_REPORT_TEMPLATE_API" as
/* $Header: PSPRTAIB.pls 120.1.12010000.3 2008/08/05 10:14:48 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '    PSP_Report_Template_API.';
  p_legislation_code  varchar(50):=hr_api.userenv_lang;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_Report_Template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_Report_Template
  (P_VALIDATE                      in     boolean  default false
   , P_TEMPLATE_ID                 in     NUMBER
   , P_TEMPLATE_NAME               in   VARCHAR2
   , P_BUSINESS_GROUP_ID           in   NUMBER
   , P_SET_OF_BOOKS_ID             in    NUMBER
   , P_REPORT_TYPE                 in    VARCHAR2
   , P_PERIOD_FREQUENCY_ID         in    NUMBER
   , P_REPORT_TEMPLATE_CODE        in    VARCHAR2
   , P_DISPLAY_ALL_EMP_DISTRIB_FLAG in              VARCHAR2
   , P_MANUAL_ENTRY_OVERRIDE_FLAG  in              VARCHAR2
   , P_APPROVAL_TYPE               in              VARCHAR2
   , P_SUP_LEVELS                  in              NUMBER
   , P_PREVIEW_EFFORT_REPORT_FLAG  in    VARCHAR2
   , P_NOTIFICATION_REMINDER in             NUMBER
   , P_SPRCD_TOLERANCE_AMT           in            NUMBER
   , P_SPRCD_TOLERANCE_PERCENT       in            NUMBER
   , P_DESCRIPTION                   in            VARCHAR2
   , P_EGISLATION_CODE               in           VARCHAR2
   , P_OBJECT_VERSION_NUMBER       out nocopy      NUMBER
   , P_WARNING                     out nocopy      boolean
   , P_RETURN_STATUS               out nocopy      boolean
   , P_CUSTOM_APPROVAL_CODE	     in		VARCHAR2
   , P_HUNDRED_PCENT_EFF_AT_PER_ASG  in		VARCHAR2
   , P_SELECTION_MATCH_LEVEL         in		VARCHAR2
  ) is
  --
  -- Declare cursors and local variables
  --
--  l_in_out_parameter    number;
--  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'Create_Report_Template';

  l_template_name         Psp_Report_Templates.TEMPLATE_NAME%TYPE;

--
-- cursor to check Duplicate  TEMPLATE NAME
--

cursor c_template_name
is
select distinct Template_Name
from   Psp_Report_Templates
where  Template_Name =  P_TEMPLATE_NAME
and    report_type = p_report_type ;

--
-- end of cursor
--




begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Create_Report_Template;
  --
  -- Remember IN OUT parameter IN values
  --
--  l_in_out_parameter := p_in_out_parameter;

  --
  -- Truncate the time portion from all IN date parameters
  --
--  l_effective_date := trunc(p_effective_date);


  open    c_template_name;
  fetch   c_template_name into   l_template_name;
  close   c_template_name;

  if (l_template_name is not NULL ) then
-- Show the appropriate Message

     fnd_message.set_name('PSP', 'PSP_ER_DUP_TEMPLATE_NAME');
     fnd_message.set_token('TEMPLATE_NAME', p_template_name);
     fnd_message.raise_error;

  end if;



  --
  -- Call Before Process User Hook
  --
  begin
    PSP_Report_Template_BK1.Create_Report_Template_b
    ( 	  P_TEMPLATE_NAME			        =>	P_TEMPLATE_NAME
		, P_TEMPLATE_ID				=>	P_TEMPLATE_ID
		, P_BUSINESS_GROUP_ID			=>	P_BUSINESS_GROUP_ID
		, P_SET_OF_BOOKS_ID  	   	        =>	P_SET_OF_BOOKS_ID
		, P_REPORT_TYPE                		=>	P_REPORT_TYPE
		, P_PERIOD_FREQUENCY_ID  	   	=>	P_PERIOD_FREQUENCY_ID
		, P_REPORT_TEMPLATE_CODE      		=>	P_REPORT_TEMPLATE_CODE
		, P_DISPLAY_ALL_EMP_DISTRIB_FLAG	=>	P_DISPLAY_ALL_EMP_DISTRIB_FLAG
		, P_MANUAL_ENTRY_OVERRIDE_FLAG  	=>	P_MANUAL_ENTRY_OVERRIDE_FLAG
		, P_APPROVAL_TYPE               	=>	P_APPROVAL_TYPE
		, P_SUP_LEVELS                  	=>	P_SUP_LEVELS
		, P_PREVIEW_EFFORT_REPORT_FLAG  	=>	P_PREVIEW_EFFORT_REPORT_FLAG
		, P_NOTIFICATION_REMINDER    		=>	P_NOTIFICATION_REMINDER
		, P_SPRCD_TOLERANCE_AMT         	=>	P_SPRCD_TOLERANCE_AMT
		, P_SPRCD_TOLERANCE_PERCENT     	=>	P_SPRCD_TOLERANCE_PERCENT
		, P_DESCRIPTION                 	=>	P_DESCRIPTION
		, P_EGISLATION_CODE 		    	=>	P_EGISLATION_CODE
		,P_CUSTOM_APPROVAL_CODE			=>	P_CUSTOM_APPROVAL_CODE
		,P_HUNDRED_PCENT_EFF_AT_PER_ASG 	=>	P_HUNDRED_PCENT_EFF_AT_PER_ASG
		,P_SELECTION_MATCH_LEVEL 		=>	P_SELECTION_MATCH_LEVEL
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_Report_Template'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

         psp_prt_ins.ins (
		 p_template_name               			=>	p_template_name
		,p_business_group_id           			=>	p_business_group_id
		,p_set_of_books_id             			=>	p_set_of_books_id
		,p_report_type                 			=>	p_report_type
		,p_period_frequency_id         			=>	p_period_frequency_id
		,p_report_template_code        			=>	p_report_template_code
		,p_preview_effort_report_flag  			=>	p_preview_effort_report_flag
		,p_display_all_emp_distrib_flag			=>	p_display_all_emp_distrib_flag
		,p_manual_entry_override_flag  			=>	p_manual_entry_override_flag
		,p_approval_type               			=>	p_approval_type
		,p_sup_levels                  			=>	p_sup_levels
		,p_notification_reminder_in_day			=>	p_notification_reminder
		,p_sprcd_tolerance_amt         			=>	p_sprcd_tolerance_amt
		,p_sprcd_tolerance_percent     			=>	p_sprcd_tolerance_percent
		,p_description                 			=>	p_description
		,p_legislation_code            			=>	p_legislation_code
		,P_TEMPLATE_ID                 			=>	P_TEMPLATE_ID
		,p_object_version_number       			=>	p_object_version_number
		,P_CUSTOM_APPROVAL_CODE				=>	P_CUSTOM_APPROVAL_CODE
		,P_HUNDRED_PCENT_EFF_AT_PER_ASG		 	=>	P_HUNDRED_PCENT_EFF_AT_PER_ASG
		,P_SELECTION_MATCH_LEVEL 			=>	P_SELECTION_MATCH_LEVEL
     );

  --
  -- Call After Process User Hook
  --
  begin
     PSP_Report_Template_BK1.Create_Report_Template_a
      (	  P_TEMPLATE_ID                 		=>	P_TEMPLATE_ID
		, P_TEMPLATE_NAME               		=>	P_TEMPLATE_NAME
		, P_BUSINESS_GROUP_ID           		=>	P_BUSINESS_GROUP_ID
		, P_SET_OF_BOOKS_ID             		=>	P_SET_OF_BOOKS_ID
		, P_REPORT_TYPE                 		=>	P_REPORT_TYPE
		, P_PERIOD_FREQUENCY_ID         		=>	P_PERIOD_FREQUENCY_ID
		, P_REPORT_TEMPLATE_CODE        		=>	P_REPORT_TEMPLATE_CODE
		, P_DISPLAY_ALL_EMP_DISTRIB_FLAG		=>	P_DISPLAY_ALL_EMP_DISTRIB_FLAG
		, P_MANUAL_ENTRY_OVERRIDE_FLAG  		=>	P_MANUAL_ENTRY_OVERRIDE_FLAG
		, P_APPROVAL_TYPE               		=>	P_APPROVAL_TYPE
		, P_SUP_LEVELS                  		=>	P_SUP_LEVELS
		, P_PREVIEW_EFFORT_REPORT_FLAG  		=>	P_PREVIEW_EFFORT_REPORT_FLAG
		, P_NOTIFICATION_REMINDER			    =>	P_NOTIFICATION_REMINDER
		, P_SPRCD_TOLERANCE_AMT         		=>	P_SPRCD_TOLERANCE_AMT
		, P_SPRCD_TOLERANCE_PERCENT     		=>	P_SPRCD_TOLERANCE_PERCENT
		, P_DESCRIPTION                 		=>	P_DESCRIPTION
		, P_EGISLATION_CODE             		=>	P_EGISLATION_CODE
		, P_OBJECT_VERSION_NUMBER       		=>	P_OBJECT_VERSION_NUMBER
		, P_WARNING                     		=>	P_WARNING
		, P_RETURN_STATUS               		=>	P_RETURN_STATUS
		,P_CUSTOM_APPROVAL_CODE				=>	P_CUSTOM_APPROVAL_CODE
		,P_HUNDRED_PCENT_EFF_AT_PER_ASG 		=>	P_HUNDRED_PCENT_EFF_AT_PER_ASG
		,P_SELECTION_MATCH_LEVEL 			=>	P_SELECTION_MATCH_LEVEL
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_Report_Template'
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
  p_object_version_number  := p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Create_Report_Template;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Create_Report_Template;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Create_Report_Template;












--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Report_Template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Report_Template
  (P_VALIDATE                      in     boolean  default false
   , P_TEMPLATE_ID                 in     NUMBER
   , P_TEMPLATE_NAME               in      VARCHAR2
   , P_BUSINESS_GROUP_ID           in    NUMBER
   , P_SET_OF_BOOKS_ID             in    NUMBER
   , P_REPORT_TYPE                 in    VARCHAR2
   , P_PERIOD_FREQUENCY_ID         in    NUMBER
   , P_REPORT_TEMPLATE_CODE        in    VARCHAR2
   , P_DISPLAY_ALL_EMP_DISTRIB_FLAG in              VARCHAR2
   , P_MANUAL_ENTRY_OVERRIDE_FLAG  in              VARCHAR2
   , P_APPROVAL_TYPE               in              VARCHAR2
   , P_SUP_LEVELS                  in              NUMBER
   , P_PREVIEW_EFFORT_REPORT_FLAG  in    VARCHAR2
   , P_NOTIFICATION_REMINDER in             NUMBER
   , P_SPRCD_TOLERANCE_AMT           in            NUMBER
   , P_SPRCD_TOLERANCE_PERCENT       in            NUMBER
   , P_DESCRIPTION                   in            VARCHAR2
   , P_EGISLATION_CODE               in           VARCHAR2
   , P_OBJECT_VERSION_NUMBER       in out nocopy      NUMBER
   , P_WARNING                     out nocopy      boolean
   , P_RETURN_STATUS               out nocopy      boolean
    ,P_CUSTOM_APPROVAL_CODE	     in		VARCHAR2
   , P_HUNDRED_PCENT_EFF_AT_PER_ASG  in		VARCHAR2
   , P_SELECTION_MATCH_LEVEL         in		VARCHAR2
) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'<BUS_PROCESS_NAME>';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Report_Template;
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
    PSP_Report_Template_BK2.Update_Report_Template_b

    (  	 	  P_TEMPLATE_ID                 		=>	P_TEMPLATE_ID
		, P_TEMPLATE_NAME               		=>	P_TEMPLATE_NAME
		, P_BUSINESS_GROUP_ID           		=>	P_BUSINESS_GROUP_ID
		, P_SET_OF_BOOKS_ID             		=>	P_SET_OF_BOOKS_ID
		, P_REPORT_TYPE                 		=>	P_REPORT_TYPE
		, P_PERIOD_FREQUENCY_ID         		=>	P_PERIOD_FREQUENCY_ID
		, P_REPORT_TEMPLATE_CODE        		=>	P_REPORT_TEMPLATE_CODE
		, P_DISPLAY_ALL_EMP_DISTRIB_FLAG		=>	P_DISPLAY_ALL_EMP_DISTRIB_FLAG
		, P_MANUAL_ENTRY_OVERRIDE_FLAG  		=>	P_MANUAL_ENTRY_OVERRIDE_FLAG
		, P_APPROVAL_TYPE               		=>	P_APPROVAL_TYPE
		, P_SUP_LEVELS                  		=>	P_SUP_LEVELS
		, P_PREVIEW_EFFORT_REPORT_FLAG  		=>	P_PREVIEW_EFFORT_REPORT_FLAG
		, P_NOTIFICATION_REMINDER			=>	P_NOTIFICATION_REMINDER
		, P_SPRCD_TOLERANCE_AMT         		=>	P_SPRCD_TOLERANCE_AMT
		, P_SPRCD_TOLERANCE_PERCENT     		=>	P_SPRCD_TOLERANCE_PERCENT
		, P_DESCRIPTION                 		=>	P_DESCRIPTION
		, P_EGISLATION_CODE             		=>	P_EGISLATION_CODE
		,P_CUSTOM_APPROVAL_CODE				=>	P_CUSTOM_APPROVAL_CODE
		,P_HUNDRED_PCENT_EFF_AT_PER_ASG 		=>	P_HUNDRED_PCENT_EFF_AT_PER_ASG
		,P_SELECTION_MATCH_LEVEL 			=>	P_SELECTION_MATCH_LEVEL
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Report_Template'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         psp_prt_upd.upd(
		 p_template_id                 			=>	p_template_id
		,p_object_version_number       			=>	p_object_version_number
		,p_template_name               			=>	p_template_name
		,p_business_group_id           			=>	p_business_group_id
		,p_set_of_books_id             			=>	p_set_of_books_id
		,p_report_type                 			=>	p_report_type
		,p_period_frequency_id         			=>	p_period_frequency_id
		,p_report_template_code        			=>	p_report_template_code
		,p_preview_effort_report_flag  			=>	p_preview_effort_report_flag
		,p_display_all_emp_distrib_flag			=>	p_display_all_emp_distrib_flag
		,p_manual_entry_override_flag  			=>	p_manual_entry_override_flag
		,p_approval_type               			=>	p_approval_type
		,p_sup_levels                  			=>	p_sup_levels
		,p_notification_reminder_in_day			=>	p_notification_reminder
		,p_sprcd_tolerance_amt         			=>	p_sprcd_tolerance_amt
		,p_sprcd_tolerance_percent     			=>	p_sprcd_tolerance_percent
		,p_description                 			=>	p_description
		,p_legislation_code            			=>	p_legislation_code
		,P_CUSTOM_APPROVAL_CODE				=>	P_CUSTOM_APPROVAL_CODE
		,P_HUNDRED_PCENT_EFF_AT_PER_ASG 		=>	P_HUNDRED_PCENT_EFF_AT_PER_ASG
		,P_SELECTION_MATCH_LEVEL 			=>	P_SELECTION_MATCH_LEVEL
        );


  --
  -- Call After Process User Hook
  --
  begin
     PSP_Report_Template_BK2.Update_Report_Template_a
      (		  P_TEMPLATE_ID                 		=>	P_TEMPLATE_ID
		, P_TEMPLATE_NAME               		=>	P_TEMPLATE_NAME
		, P_BUSINESS_GROUP_ID           		=>	P_BUSINESS_GROUP_ID
		, P_SET_OF_BOOKS_ID             		=>	P_SET_OF_BOOKS_ID
		, P_REPORT_TYPE                 		=>	P_REPORT_TYPE
		, P_PERIOD_FREQUENCY_ID         		=>	P_PERIOD_FREQUENCY_ID
		, P_REPORT_TEMPLATE_CODE        		=>	P_REPORT_TEMPLATE_CODE
		, P_DISPLAY_ALL_EMP_DISTRIB_FLAG		=>	P_DISPLAY_ALL_EMP_DISTRIB_FLAG
		, P_MANUAL_ENTRY_OVERRIDE_FLAG  		=>	P_MANUAL_ENTRY_OVERRIDE_FLAG
		, P_APPROVAL_TYPE               		=>	P_APPROVAL_TYPE
		, P_SUP_LEVELS                  		=>	P_SUP_LEVELS
		, P_PREVIEW_EFFORT_REPORT_FLAG  		=>	P_PREVIEW_EFFORT_REPORT_FLAG
		, P_NOTIFICATION_REMINDER   			=>	P_NOTIFICATION_REMINDER
		, P_SPRCD_TOLERANCE_AMT         		=>	P_SPRCD_TOLERANCE_AMT
		, P_SPRCD_TOLERANCE_PERCENT     		=>	P_SPRCD_TOLERANCE_PERCENT
		, P_DESCRIPTION                 		=>	P_DESCRIPTION
		, P_EGISLATION_CODE             		=>	P_EGISLATION_CODE
		, P_OBJECT_VERSION_NUMBER       		=>	P_OBJECT_VERSION_NUMBER
		, P_WARNING                     		=>	P_WARNING
		, P_RETURN_STATUS               		=>	P_RETURN_STATUS
 		,P_CUSTOM_APPROVAL_CODE				=>	P_CUSTOM_APPROVAL_CODE
		,P_HUNDRED_PCENT_EFF_AT_PER_ASG 		=>	P_HUNDRED_PCENT_EFF_AT_PER_ASG
		,P_SELECTION_MATCH_LEVEL 			=>	P_SELECTION_MATCH_LEVEL
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Report_Template'
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
--  p_id                     := p_id  ;
--  p_in_out_parameter       :=  p_in_out_parameter ;
  p_object_version_number  := p_object_version_number;
--  p_some_warning           :=  p_some_warning ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Update_Report_Template;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := p_some_warning ;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_Report_Template;
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
end Update_Report_Template;



--
-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_Report_Template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Delete_Report_Template
  (  P_VALIDATE                       in     BOOLEAN default false
  ,P_TEMPLATE_ID                      in     number
  ,P_OBJECT_VERSION_NUMBER          in out nocopy number
  ,P_WARNING                       out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'<BUS_PROCESS_NAME>';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Delete_Report_template;
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
    PSP_Report_Template_BK3.Delete_Report_template_b
    (  	 P_TEMPLATE_ID      	=>	P_TEMPLATE_ID
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Report_template'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    psp_prt_del.del(
    p_template_id             =>  p_template_id
    ,p_object_version_number   =>  p_object_version_number
    );


  --
  -- Call After Process User Hook
  --
  begin
     PSP_Report_Template_BK3.Delete_Report_template_a
      (	 P_TEMPLATE_ID                 		=>	 P_TEMPLATE_ID
		,P_OBJECT_VERSION_NUMBER     		=>	P_OBJECT_VERSION_NUMBER
		,P_WARNING                   		=>	P_WARNING

     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Report_template'
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
--  p_id                     := p_id  ;
--  p_in_out_parameter       :=  p_in_out_parameter ;
  p_object_version_number  := p_object_version_number;
--  p_some_warning           :=  p_some_warning ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Delete_Report_template;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_in_out_parameter       := l_in_out_parameter;
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := p_some_warning ;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to Delete_Report_template;
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
end Delete_Report_template;
--
end PSP_Report_Template_API;

/
