--------------------------------------------------------
--  DDL for Package PSP_ERD_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ERD_EXT" AUTHID CURRENT_USER as
/* $Header: PSPERCXS.pls 120.2 2005/08/28 20:04 vdharmap noship $ */
PSP_ER_PERCENT_VALIDATION_FLAG Exception;
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
         );
END PSP_ERD_EXT;

 

/
