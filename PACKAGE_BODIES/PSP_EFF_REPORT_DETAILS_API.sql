--------------------------------------------------------
--  DDL for Package Body PSP_EFF_REPORT_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFF_REPORT_DETAILS_API" as
/* $Header: PSPEDAIB.pls 120.4 2006/01/30 22:33:34 dpaudel noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PSP_EFF_REPORT_DETAILS_API.';
MAX_percent_validation_flag Exception;
Range_percent_validation_flag Exception;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_EFF_REPORT_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_EFF_REPORT_DETAILS
  (p_validate                                      in boolean  default false
  ,p_Request_id                                    in number
  ,p_start_person                                  in number
  ,p_end_person                                   in number
  ,p_warning                          out nocopy   boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'UPDATE_EFF_REPORT_DETAILS';
  l_count_eff_detail_id            Number := 0;
L_OBJECT_VERSION_NUMBER Number;
l_Request_id Number;
 l_person_id Number;
 l_sum_PROPOSED_EFFORT_PERCENT Number;
 l_range_PROPOSED_EFFORT_PER Number;
 l_full_name Varchar2(240);
 l_message varchar2(240);
 l_return_status varchar2(30);
 l_start_date date;  --- uva fix
 l_end_date date;  --- uva fix

 l_approver_person_id psp_eff_report_details_api.assignment_id;
 l_investigator_name psp_eff_report_details_api.full_name_type;
 l_investigator_org_name psp_eff_report_details_api.full_name_type;
 l_inv_primary_org_id psp_eff_report_details_api.assignment_id;


-- uva fix.
cursor get_er_dates is
select parameter_value_2, parameter_value_3
  from psp_report_templates_h
 where request_id = p_request_id;


/* Cursor to Find the EFFORT_REPORT_DETAIL_ID from REQUEST_ID */
   cursor c_EFFORT_REPORT_DETAIL_ID is
select perd.effort_report_detail_id , perd.OBJECT_VERSION_NUMBER, Assignment_id,Project_id  ,expenditure_organization_id,expenditure_type ,task_id,award_id,
GL_SEGMENT1,GL_SEGMENT2 ,GL_SEGMENT3 ,GL_SEGMENT4 ,GL_SEGMENT5 ,GL_SEGMENT6 ,GL_SEGMENT7 ,GL_SEGMENT8 ,GL_SEGMENT9 ,GL_SEGMENT10,
GL_SEGMENT11,GL_SEGMENT12,GL_SEGMENT13,GL_SEGMENT14,GL_SEGMENT15,GL_SEGMENT16,GL_SEGMENT17,GL_SEGMENT18,GL_SEGMENT19,GL_SEGMENT20,
GL_SEGMENT21,GL_SEGMENT22,GL_SEGMENT23,GL_SEGMENT24,GL_SEGMENT25,GL_SEGMENT26,GL_SEGMENT27,GL_SEGMENT28,GL_SEGMENT29,GL_SEGMENT30, per.full_name, investigator_person_id,
 INVESTIGATOR_NAME      ,
 INVESTIGATOR_ORG_NAME  ,
 INVESTIGATOR_PRIMARY_ORG_ID
from psp_eff_report_details perd,
psp_eff_reports per
where REQUEST_ID = p_Request_id
and perd.EFFORT_REPORT_ID = per.EFFORT_REPORT_ID
and person_id between p_start_person and p_end_person;
/* Added Person Id check for Bug fix 4089645 */

/*
CURSOR c_MAX_PROPOSED_EFFORT_PERCENT IS
select per.PERSON_ID,max(Full_name), sum(perd.PROPOSED_EFFORT_PERCENT)
from psp_eff_report_details perd,
psp_eff_reports per
where perd.EFFORT_REPORT_ID = per.EFFORT_REPORT_ID
group by per.PERSON_ID
having sum(PROPOSED_EFFORT_PERCENT) > 100;
CURSOR c_RAnge_PROPOSED_EFFORT_PER IS
select per.PERSON_ID,max(Full_name), sum(perd.PROPOSED_EFFORT_PERCENT)
from psp_eff_report_details perd,
psp_eff_reports per
where perd.EFFORT_REPORT_ID = per.EFFORT_REPORT_ID
--AND (PROPOSED_EFFORT_PERCENT <0
--or PROPOSED_EFFORT_PERCENT >100)
AND PROPOSED_EFFORT_PERCENT >100
group by per.PERSON_ID;
*/
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

-- for uva
open get_er_dates;
fetch get_er_dates into l_start_date, l_end_date;
close get_er_dates;
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_EFF_REPORT_DETAILS;
   --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
open c_EFFORT_REPORT_DETAIL_ID;
    fetch c_EFFORT_REPORT_DETAIL_ID BULK COLLECT INTO g_er_EFFORT_REPORT_DETAIL_ID,g_er_OBJECT_VERSION_NUMBER, g_er_Assignment_id ,g_er_Project_id  ,g_er_expenditure_org_id,g_er_expenditure_type ,g_er_task_id, g_er_award_id,
 g_er_GL_SEGMENT1, G_ER_GL_SEGMENT2 , G_ER_GL_SEGMENT3 , G_ER_GL_SEGMENT4 , G_ER_GL_SEGMENT5 , G_ER_GL_SEGMENT6 , G_ER_GL_SEGMENT7 , G_ER_GL_SEGMENT8 , G_ER_GL_SEGMENT9 , G_ER_GL_SEGMENT10,
 G_ER_GL_SEGMENT11, G_ER_GL_SEGMENT12, G_ER_GL_SEGMENT13, G_ER_GL_SEGMENT14, G_ER_GL_SEGMENT15, G_ER_GL_SEGMENT16, G_ER_GL_SEGMENT17, G_ER_GL_SEGMENT18, G_ER_GL_SEGMENT19, G_ER_GL_SEGMENT20,
 G_ER_GL_SEGMENT21, G_ER_GL_SEGMENT22, G_ER_GL_SEGMENT23, G_ER_GL_SEGMENT24, G_ER_GL_SEGMENT25, G_ER_GL_SEGMENT26, G_ER_GL_SEGMENT27, G_ER_GL_SEGMENT28, G_ER_GL_SEGMENT29, G_ER_GL_SEGMENT30, g_er_full_name, g_er_approver_person_id,
g_er_investigator_name, g_er_investigator_org_name, g_er_inv_primary_org_id;
Close c_EFFORT_REPORT_DETAIL_ID;
l_count_eff_detail_id :=g_er_EFFORT_REPORT_DETAIL_ID.count;
/* for Bug fix 4081279 START*/
Begin
    for i in 1..l_count_eff_detail_id  Loop


			g_er_proposed_salary_amt(i)     := hr_api.g_number;
			g_er_proposed_effort_percent(i) := hr_api.g_number;
			g_er_committed_cost_share(i)    := hr_api.g_number;
			g_er_value1(i)                  := hr_api.g_number;
			g_er_value2(i)                  := hr_api.g_number;
			g_er_value3(i)                  := hr_api.g_number;
			g_er_value4(i)                  := hr_api.g_number;
			g_er_value5(i)                  := hr_api.g_number;
			g_er_value6(i)                  := hr_api.g_number;
			g_er_value7(i)                  := hr_api.g_number;
			g_er_value8(i)                  := hr_api.g_number;
			g_er_value9(i)                  := hr_api.g_number;
			g_er_value10(i)                 := hr_api.g_number;
			g_er_attribute1(i)              := hr_api.g_varchar2;
			g_er_attribute2(i)              := hr_api.g_varchar2;
			g_er_attribute3(i)              := hr_api.g_varchar2;
			g_er_attribute4(i)              := hr_api.g_varchar2;
			g_er_attribute5(i)              := hr_api.g_varchar2;
			g_er_attribute6(i)              := hr_api.g_varchar2;
			g_er_attribute7(i)              := hr_api.g_varchar2;
			g_er_attribute8(i)              := hr_api.g_varchar2;
			g_er_attribute9(i)              := hr_api.g_varchar2;
			g_er_attribute10(i)             := hr_api.g_varchar2;
			g_er_grouping_category(i)       := hr_api.g_varchar2;     -- Add for Hospital Effort Report

			l_approver_person_id(i)         := g_er_approver_person_id(i);
			l_investigator_name(i) 	        := g_er_investigator_name(i);
			l_inv_primary_org_id(i) 	:= g_er_inv_primary_org_id(i);
			l_investigator_org_name(i) 	:= g_er_investigator_org_name(i);

    End loop;
END;
/* fro Bug fix 4081279 END*/

begin
for i in 1..l_count_eff_detail_id  Loop
       PSP_EFF_REPORT_DETAILS_BK1.UPDATE_EFF_REPORT_DETAILS_b
	    (p_effort_report_detail_id               =>     g_er_effort_report_detail_id (i)
		,p_Assignment_id              =>                g_er_Assignment_id(i)
		,p_GL_SEGMENT1              =>                  g_er_GL_SEGMENT1(i)
		,p_GL_SEGMENT2              =>                  g_er_GL_SEGMENT2(i)
		,p_GL_SEGMENT3              =>                  g_er_GL_SEGMENT3(i)
		,p_GL_SEGMENT4              =>                  g_er_GL_SEGMENT4(i)
		,p_GL_SEGMENT5              =>                  g_er_GL_SEGMENT5(i)
		,p_GL_SEGMENT6              =>                  g_er_GL_SEGMENT6(i)
		,p_GL_SEGMENT7              =>                  g_er_GL_SEGMENT7(i)
		,p_GL_SEGMENT8              =>                  g_er_GL_SEGMENT8(i)
		,p_GL_SEGMENT9              =>                  g_er_GL_SEGMENT9(i)
		,p_GL_SEGMENT10              =>                 g_er_GL_SEGMENT10(i)
		,p_GL_SEGMENT11              =>                 g_er_GL_SEGMENT11(i)
		,p_GL_SEGMENT12              =>                 g_er_GL_SEGMENT12(i)
		,p_GL_SEGMENT13              =>                 g_er_GL_SEGMENT13(i)
		,p_GL_SEGMENT14              =>                 g_er_GL_SEGMENT14(i)
		,p_GL_SEGMENT15              =>                 g_er_GL_SEGMENT15(i)
		,p_GL_SEGMENT16              =>                 g_er_GL_SEGMENT16(i)
		,p_GL_SEGMENT17              =>                 g_er_GL_SEGMENT17(i)
		,p_GL_SEGMENT18              =>                 g_er_GL_SEGMENT18(i)
		,p_GL_SEGMENT19              =>                 g_er_GL_SEGMENT19(i)
		,p_GL_SEGMENT20              =>                 g_er_GL_SEGMENT20(i)
		,p_GL_SEGMENT21              =>                 g_er_GL_SEGMENT21(i)
		,p_GL_SEGMENT22              =>                 g_er_GL_SEGMENT22(i)
		,p_GL_SEGMENT23              =>                 g_er_GL_SEGMENT23(i)
		,p_GL_SEGMENT24              =>                 g_er_GL_SEGMENT24(i)
		,p_GL_SEGMENT25              =>                 g_er_GL_SEGMENT25(i)
		,p_GL_SEGMENT26              =>                 g_er_GL_SEGMENT26(i)
		,p_GL_SEGMENT27              =>                 g_er_GL_SEGMENT27(i)
		,p_GL_SEGMENT28              =>                 g_er_GL_SEGMENT28(i)
		,p_GL_SEGMENT29              =>                 g_er_GL_SEGMENT29(i)
		,p_GL_SEGMENT30              =>                 g_er_GL_SEGMENT30(i)
		,p_Project_id              =>                   g_er_Project_id(i)
		,p_expenditure_org_id              =>           g_er_expenditure_org_id(i)
		,p_expenditure_type              =>             g_er_expenditure_type(i)
		,p_task_id              =>                      g_er_task_id(i)
		,p_award_id              =>		       g_er_Award_id(i)
		,p_count_eff_detail_id	=>			i
                ,p_effort_start_date           => l_start_date                     -- added 5 params for UVA
                ,p_effort_end_date             => l_end_date
                ,p_investigator_person_id          => g_er_approver_person_id(i)
                ,p_INVESTIGATOR_NAME              => g_er_investigator_name(i)
                ,p_INVESTIGATOR_ORG_NAME          => g_er_investigator_org_name(i)
                ,p_INVESTIGATOR_PRIMARY_ORG_ID   => g_er_inv_primary_org_id(i)
	    );

End Loop;
Exception
   when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_EFF_REPORT_DETAILS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
--    p_Request_id                      := null;
      p_warning				:= true;
      l_message := sqlerrm;
      PSP_GENERAL.add_report_error(
   				 p_request_id		 =>	p_Request_id
		    		,p_message_level	 =>	'E'
			    	,p_source_id		 =>	NULL
   				,p_error_message	 =>	l_message
		                ,p_return_status         =>     l_return_status
                );

      hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
end;
  --
  -- Call Before Process User Hook
  --
  --
  -- Validation in addition to Row Handlers
  --
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler upd procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for i in 1..l_count_eff_detail_id Loop
	BEGIN
		if (g_er_approver_person_id(i) <> l_approver_person_id(i) ) THEN
			l_approver_person_id(i) := g_er_approver_person_id(i);
		END IF;
		if (g_er_investigator_name(i) <> l_investigator_name(i) ) THEN
			l_investigator_name(i) := g_er_investigator_name(i);
		END IF;
		if (g_er_inv_primary_org_id(i) <> l_inv_primary_org_id(i) ) THEN
			l_inv_primary_org_id(i) := g_er_inv_primary_org_id(i);
		END IF;
		if (g_er_investigator_org_name(i) <> l_investigator_org_name(i) ) THEN
			l_investigator_org_name(i) := g_er_investigator_org_name(i);
		END IF;


	/* Added check to provent unnecessary update  */
	    if 		g_er_proposed_salary_amt(i) <> hr_api.g_number OR  g_er_proposed_effort_percent(i) <> hr_api.g_number
                                OR g_er_committed_cost_share(i) <> hr_api.g_number OR g_er_value1(i) <> hr_api.g_number
				OR g_er_value2(i) <> hr_api.g_number OR g_er_value3(i) <> hr_api.g_number OR g_er_value4(i) <> hr_api.g_number
				OR g_er_value5(i) <> hr_api.g_number OR g_er_value6(i) <> hr_api.g_number OR g_er_value7(i) <> hr_api.g_number
				OR g_er_value8(i) <> hr_api.g_number OR g_er_value9(i) <> hr_api.g_number OR g_er_value10(i) <> hr_api.g_number
				OR g_er_attribute1(i) <> hr_api.g_varchar2 OR g_er_attribute2(i) <> hr_api.g_varchar2
				OR g_er_attribute3(i) <> hr_api.g_varchar2 OR g_er_attribute4(i) <> hr_api.g_varchar2
				OR g_er_attribute5(i) <> hr_api.g_varchar2 OR g_er_attribute6(i) <> hr_api.g_varchar2
				OR g_er_attribute7(i) <> hr_api.g_varchar2 OR g_er_attribute8(i) <> hr_api.g_varchar2
				OR g_er_attribute9(i) <> hr_api.g_varchar2 OR g_er_attribute10(i)  <> hr_api.g_varchar2
                                OR g_er_approver_person_id(i) <> l_approver_person_id(i)
                                OR g_er_investigator_name(i)  <> l_investigator_name(i)
                                OR g_er_investigator_org_name(i) <> l_investigator_org_name(i)
                                OR g_er_inv_primary_org_id(i) <> l_inv_primary_org_id(i)
                                OR g_er_grouping_category(i) <> hr_api.g_varchar2
	    THEN
	       psp_erd_upd.upd (
				   p_effort_report_detail_id			=>	g_er_EFFORT_REPORT_DETAIL_ID(i)
				  ,p_object_version_number        		=>	g_er_OBJECT_VERSION_NUMBER(i)
				  ,p_proposed_salary_amt          		=>	g_er_proposed_salary_amt(i)
				  ,p_proposed_effort_percent      		=>	g_er_proposed_effort_percent(i)
				  ,p_committed_cost_share         		=>	g_er_committed_cost_share(i)
				  ,p_value1                       		=>	g_er_value1(i)
				  ,p_value2                       		=>	g_er_value2(i)
				  ,p_value3                       		=>	g_er_value3(i)
				  ,p_value4                       		=>	g_er_value4(i)
				  ,p_value5                       		=>	g_er_value5(i)
				  ,p_value6                       		=>	g_er_value6(i)
				  ,p_value7                       		=>	g_er_value7(i)
				  ,p_value8                       		=>	g_er_value8(i)
				  ,p_value9                       		=>	g_er_value9(i)
				  ,p_value10                      		=>	g_er_value10(i)
				  ,p_attribute1                   		=>	g_er_attribute1(i)
				  ,p_attribute2                   		=>	g_er_attribute2(i)
				  ,p_attribute3                   		=>	g_er_attribute3(i)
				  ,p_attribute4                   		=>	g_er_attribute4(i)
				  ,p_attribute5                   		=>	g_er_attribute5(i)
				  ,p_attribute6                   		=>	g_er_attribute6(i)
				  ,p_attribute7                   		=>	g_er_attribute7(i)
				  ,p_attribute8                   		=>	g_er_attribute8(i)
				  ,p_attribute9                   		=>	g_er_attribute9(i)
				  ,p_attribute10                  		=>	g_er_attribute10(i)
                                  ,p_investigator_person_id                     =>      l_approver_person_id(i)
                ,p_INVESTIGATOR_NAME              => l_investigator_name(i)
                ,p_INVESTIGATOR_ORG_NAME          => l_investigator_org_name(i)
                ,p_INVESTIGATOR_PRIMARY_ORG_ID   => l_inv_primary_org_id(i)
		,p_grouping_category          => g_er_grouping_category(i)    -- Add for Hospital Effort Report
				 );
	    End if;
	Exception
	   when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to UPDATE_EFF_REPORT_DETAILS;
	    --
	    -- Reset IN OUT parameters and set all
	    -- OUT parameters, including warnings, to null
	    --
	--    p_Request_id                      := null;
	      p_warning				:= true;
	      l_message := sqlerrm;
	      PSP_GENERAL.add_report_error(
					 p_request_id		 =>	p_Request_id
					,p_message_level	 =>	'E'
					,p_source_id		 =>	g_er_full_name(i)
					,p_error_message	 =>	l_message
					,p_return_status         =>     l_return_status
			);

	      hr_utility.set_location(' Leaving:'||l_proc, 90);
	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END;
End Loop;


/*
OPEN c_RAnge_PROPOSED_EFFORT_PER;
	fetch c_RAnge_PROPOSED_EFFORT_PER into l_person_id,l_full_name, l_Range_PROPOSED_EFFORT_PER;
close c_RAnge_PROPOSED_EFFORT_PER;
if l_person_id is not null then
	raise Range_percent_validation_flag;
end if;
OPEN c_MAX_PROPOSED_EFFORT_PERCENT;
	fetch c_MAX_PROPOSED_EFFORT_PERCENT into l_person_id, l_full_name, l_sum_PROPOSED_EFFORT_PERCENT;
close c_MAX_PROPOSED_EFFORT_PERCENT;
if l_sum_PROPOSED_EFFORT_PERCENT is not null  then
	raise MAX_percent_validation_flag;
end if;
*/
  --
  -- Call After Process User Hook
  --
 begin
for i in 1..l_count_eff_detail_id  Loop
   PSP_EFF_REPORT_DETAILS_BK1.UPDATE_EFF_REPORT_DETAILS_a
    (p_effort_report_detail_id               =>     g_er_effort_report_detail_id (i)
		,p_Assignment_id              =>                g_er_Assignment_id(i)
		,p_GL_SEGMENT1              =>                  g_er_GL_SEGMENT1(i)
		,p_GL_SEGMENT2              =>                  g_er_GL_SEGMENT2(i)
		,p_GL_SEGMENT3              =>                  g_er_GL_SEGMENT3(i)
		,p_GL_SEGMENT4              =>                  g_er_GL_SEGMENT4(i)
		,p_GL_SEGMENT5              =>                  g_er_GL_SEGMENT5(i)
		,p_GL_SEGMENT6              =>                  g_er_GL_SEGMENT6(i)
		,p_GL_SEGMENT7              =>                  g_er_GL_SEGMENT7(i)
		,p_GL_SEGMENT8              =>                  g_er_GL_SEGMENT8(i)
		,p_GL_SEGMENT9              =>                  g_er_GL_SEGMENT9(i)
		,p_GL_SEGMENT10              =>                 g_er_GL_SEGMENT10(i)
		,p_GL_SEGMENT11              =>                 g_er_GL_SEGMENT11(i)
		,p_GL_SEGMENT12              =>                 g_er_GL_SEGMENT12(i)
		,p_GL_SEGMENT13              =>                 g_er_GL_SEGMENT13(i)
		,p_GL_SEGMENT14              =>                 g_er_GL_SEGMENT14(i)
		,p_GL_SEGMENT15              =>                 g_er_GL_SEGMENT15(i)
		,p_GL_SEGMENT16              =>                 g_er_GL_SEGMENT16(i)
		,p_GL_SEGMENT17              =>                 g_er_GL_SEGMENT17(i)
		,p_GL_SEGMENT18              =>                 g_er_GL_SEGMENT18(i)
		,p_GL_SEGMENT19              =>                 g_er_GL_SEGMENT19(i)
		,p_GL_SEGMENT20              =>                 g_er_GL_SEGMENT20(i)
		,p_GL_SEGMENT21              =>                 g_er_GL_SEGMENT21(i)
		,p_GL_SEGMENT22              =>                 g_er_GL_SEGMENT22(i)
		,p_GL_SEGMENT23              =>                 g_er_GL_SEGMENT23(i)
		,p_GL_SEGMENT24              =>                 g_er_GL_SEGMENT24(i)
		,p_GL_SEGMENT25              =>                 g_er_GL_SEGMENT25(i)
		,p_GL_SEGMENT26              =>                 g_er_GL_SEGMENT26(i)
		,p_GL_SEGMENT27              =>                 g_er_GL_SEGMENT27(i)
		,p_GL_SEGMENT28              =>                 g_er_GL_SEGMENT28(i)
		,p_GL_SEGMENT29              =>                 g_er_GL_SEGMENT29(i)
		,p_GL_SEGMENT30              =>                 g_er_GL_SEGMENT30(i)
		,p_Project_id              =>                   g_er_Project_id(i)
		,p_expenditure_org_id              =>           g_er_expenditure_org_id(i)
		,p_expenditure_type              =>             g_er_expenditure_type(i)
		,p_task_id              =>                      g_er_task_id(i)
		,p_award_id              =>		       g_er_Award_id(i)
		,p_count_eff_detail_id	=>			i
                ,p_effort_start_date           => l_start_date                     -- added 3 params for UVA
                ,p_effort_end_date             => l_end_date
                ,p_investigator_person_id          => g_er_approver_person_id(i)
                ,p_INVESTIGATOR_NAME              => g_er_investigator_name(i)
                ,p_INVESTIGATOR_ORG_NAME          => g_er_investigator_org_name(i)
                ,p_INVESTIGATOR_PRIMARY_ORG_ID   => g_er_inv_primary_org_id(i)
      );
End Loop;
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EFF_REPORT_DETAILS'
        ,p_hook_type   => 'AP'
        );
      l_message := sqlerrm;
      PSP_GENERAL.add_report_error(
   				 p_request_id		 =>	p_Request_id
		    		,p_message_level	 =>	'E'
			    	,p_source_id		 =>	NULL
   				,p_error_message	 =>	l_message
		                ,p_return_status         =>     l_return_status
		                );

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

   when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_EFF_REPORT_DETAILS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
--    p_Request_id                      := null;
      p_warning				:= true;
      l_message := sqlerrm;
      PSP_GENERAL.add_report_error(
   				 p_request_id		 =>	p_Request_id
		    		,p_message_level	 =>	'E'
			    	,p_source_id		 =>	NULL
   				,p_error_message	 =>	l_message
		                ,p_return_status         =>     l_return_status
                );

      hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
--  p_Request_id             := l_Request_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
/*
    when Range_percent_validation_flag then
        p_warning				:= true;
        OPEN c_RAnge_PROPOSED_EFFORT_PER;
    	Loop
            fetch c_RAnge_PROPOSED_EFFORT_PER into l_person_id, l_full_name, l_range_PROPOSED_EFFORT_PER;
            exit when c_RAnge_PROPOSED_EFFORT_PER%NOTFOUND;
--            fnd_msg_pub.add_exc_msg('PSP_ERD_EXT','UPDATE_EFF_REPORT_DETAILS_EXT');
            fnd_message.set_name('PSP', 'PSP_RANGE_PERCENT_VALIDAION');
            fnd_message.SET_TOKEN('EMPLOYEENAME',l_full_name);
            l_message := fnd_message.get;
            PSP_GENERAL.add_report_error(
   	    			p_request_id		    =>	p_Request_id
		    		,p_message_level		=>	'E'
			    	,p_source_id		    =>	l_person_id
   				    ,p_error_message		=>	l_message
                    ,p_return_status        =>  l_return_status
                );
        if l_return_status = 'E' then
            raise;
        end if;
        End Loop;
        close c_RAnge_PROPOSED_EFFORT_PER;
   when MAX_percent_validation_flag then
    p_warning				:= true;
    OPEN c_MAX_PROPOSED_EFFORT_PERCENT;
   	Loop
    	fetch c_MAX_PROPOSED_EFFORT_PERCENT into l_person_id, l_full_name, l_sum_PROPOSED_EFFORT_PERCENT;
            exit when c_MAX_PROPOSED_EFFORT_PERCENT%NOTFOUND;
            fnd_message.set_name('PSP', 'PSP_MAX_PERCENT_VALIDAION');
            fnd_message.SET_TOKEN('EMPLOYEENAME',l_full_name);
            l_message := fnd_message.get;
            PSP_GENERAL.add_report_error(
   	    			p_request_id		    =>	p_Request_id
		    		,p_message_level		=>	'E'
			    	,p_source_id		    =>	l_person_id
   				    ,p_error_message		=>	l_message
                    ,p_return_status        =>  l_return_status
                );
        if l_return_status = 'E' then
            raise;
        end if;
        End Loop;
        close c_MAX_PROPOSED_EFFORT_PERCENT;
  */
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_EFF_REPORT_DETAILS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_Request_id                     := null;
    p_warning				:= true;
    l_message := sqlerrm;
                PSP_GENERAL.add_report_error(
   	    			p_request_id		    =>	p_Request_id
		    		,p_message_level		=>	'E'
			    	,p_source_id		    =>	NULL
   				    ,p_error_message		=>	l_message
                    ,p_return_status        =>  l_return_status
                );
        if l_return_status = 'E' then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_EFF_REPORT_DETAILS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
--    p_Request_id                      := null;
    p_warning				:= true;
    l_message := sqlerrm;
                   PSP_GENERAL.add_report_error(
   	    			p_request_id		    =>	p_Request_id
		    		,p_message_level		=>	'E'
			    	,p_source_id		    =>	NULL
   				    ,p_error_message		=>	l_message
                    ,p_return_status        =>  l_return_status
                );
        if l_return_status = 'E' then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
end UPDATE_EFF_REPORT_DETAILS;
--
end PSP_EFF_REPORT_DETAILS_API;

/
