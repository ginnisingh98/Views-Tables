--------------------------------------------------------
--  DDL for Package Body PSP_ERD_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERD_EXT" as
/* $Header: PSPERCXB.pls 120.5 2006/01/30 22:33 dpaudel noship $ */
-- WARNING:
--          Please note that any PL/SQL statements that cause Commit/Rollback
--          are not allowed in the user extension code. Commit/Rollback's
--          will interfere with the Commit cycle of the main
--          process and Restart/Recover process will not work properly.
--
--         ------------------------------------------------------
Procedure UPDATE_EFF_REPORT_DETAILS_EXT( p_effort_report_detail_id	in  Number
		,p_Assignment_id                in VARCHAR2
		,p_GL_SEGMENT1                in VARCHAR2
		,p_GL_SEGMENT2                in VARCHAR2
		,p_GL_SEGMENT3                in VARCHAR2
		,p_GL_SEGMENT4                in VARCHAR2
		,p_GL_SEGMENT5                in VARCHAR2
		,p_GL_SEGMENT6                in VARCHAR2
		,p_GL_SEGMENT7                in VARCHAR2
		,p_GL_SEGMENT8                in VARCHAR2
		,p_GL_SEGMENT9                in VARCHAR2
		,p_GL_SEGMENT10               in VARCHAR2
		,p_GL_SEGMENT11               in VARCHAR2
		,p_GL_SEGMENT12               in VARCHAR2
		,p_GL_SEGMENT13               in VARCHAR2
		,p_GL_SEGMENT14               in VARCHAR2
		,p_GL_SEGMENT15               in VARCHAR2
		,p_GL_SEGMENT16               in VARCHAR2
		,p_GL_SEGMENT17               in VARCHAR2
		,p_GL_SEGMENT18               in VARCHAR2
		,p_GL_SEGMENT19               in VARCHAR2
		,p_GL_SEGMENT20               in VARCHAR2
		,p_GL_SEGMENT21               in VARCHAR2
		,p_GL_SEGMENT22               in VARCHAR2
		,p_GL_SEGMENT23               in VARCHAR2
		,p_GL_SEGMENT24               in VARCHAR2
		,p_GL_SEGMENT25               in VARCHAR2
		,p_GL_SEGMENT26               in VARCHAR2
		,p_GL_SEGMENT27               in VARCHAR2
		,p_GL_SEGMENT28               in VARCHAR2
		,p_GL_SEGMENT29               in VARCHAR2
		,p_GL_SEGMENT30               in VARCHAR2
		,p_Project_id		      in Number
		,p_expenditure_org_id	      in Number
		,p_expenditure_type           in VARCHAR2
		,p_task_id		      in Number
		,p_award_id			in Number
		,p_count_eff_detail_id		in Number
                ,p_effort_start_date            in date
                ,p_effort_end_date              in date
                ,p_investigator_person_id           in number
                ,p_INVESTIGATOR_NAME           in varchar2
                ,p_INVESTIGATOR_ORG_NAME  in varchar2
                ,p_INVESTIGATOR_PRIMARY_ORG_ID  in number
         ) as
BEGIN
	PSP_EFF_REPORT_DETAILS_API.g_er_proposed_salary_amt(p_count_eff_detail_id)     := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_proposed_effort_percent(p_count_eff_detail_id) := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_committed_cost_share(p_count_eff_detail_id)    := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value1(p_count_eff_detail_id)                  := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value2(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value3(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value4(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value5(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value6(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value7(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value8(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value9(p_count_eff_detail_id)  		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_value10(p_count_eff_detail_id) 		       := hr_api.g_number;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute1(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute2(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute3(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute4(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute5(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute6(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute7(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute8(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute9(p_count_eff_detail_id) 	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_attribute10(p_count_eff_detail_id)	       := hr_api.g_varchar2;
	PSP_EFF_REPORT_DETAILS_API.g_er_grouping_category(p_count_eff_detail_id)       := hr_api.g_varchar2;    -- Add for Hospital Effort Report

	-- EDIT:Add your code here
	--p_EFFORT_REPORT_DETAIL_ID is the Effort Report Detail id

/*        --- Sample code to stick Grant Project PI to non-Grant Project
            if p_investigator_person_id is null then
               select INVESTIGATOR_PERSON_ID,
                              INVESTIGATOR_NAME,
                              INVESTIGATOR_ORG_NAME,
                              INVESTIGATOR_PRIMARY_ORG_ID
               into psp_eff_report_details_api.g_er_approver_person_id(p_count_eff_detail_id),
                              psp_eff_report_details_api.g_er_investigator_name(p_count_eff_detail_id),
                              psp_eff_report_details_api.g_er_investigator_org_name(p_count_eff_detail_id),
                              psp_eff_report_details_api.g_er_inv_primary_org_id(p_count_eff_detail_id)
                 from psp_eff_report_details
                 where effort_report_id in
                      (select effort_report_id
                        from psp_eff_report_details
                         where effort_report_detail_id = p_effort_report_detail_id)
                    and investigator_person_id is not null
                    and rownum = 1
                    order by payroll_percent desc;
             end if;

           --- if you are setting PI (overriding the approver), donot forget
               to set PI org id , PI org name, PI name .. otherwise these info could be
               missing in the PDF report
*/
	exception
	   when others then
	   fnd_msg_pub.add_exc_msg('PSP_ERD_EXT','UPDATE_EFF_REPORT_DETAILS_EXT');
	   raise FND_API.G_EXC_UNEXPECTED_ERROR;
end;
END PSP_ERD_EXT;

/
