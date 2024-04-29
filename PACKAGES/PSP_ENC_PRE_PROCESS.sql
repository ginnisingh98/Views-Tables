--------------------------------------------------------
--  DDL for Package PSP_ENC_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_PRE_PROCESS" AUTHID CURRENT_USER AS
/* $Header: PSPENPPS.pls 120.2 2006/03/05 07:32:04 spchakra noship $ */
--	The POETA Pre Process procedure that identifies the POETA related changes
	PROCEDURE poeta_pre_process	(p_pre_process_mode	IN	VARCHAR2,
					p_payroll_id		IN	NUMBER,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER,
					p_return_status		OUT NOCOPY	VARCHAR2);

--	This procedure will identify all those assignments impacted by the Setup form changes
	PROCEDURE labor_schedule_pre_process	(p_enc_line_type	IN	VARCHAR2,
						p_payroll_id		IN	NUMBER,
						p_return_status		OUT NOCOPY	VARCHAR2);

	PROCEDURE validate_poeta	(p_project_id			IN	NUMBER,
				p_task_id			IN	NUMBER,
				p_award_id			IN	NUMBER,
				p_expenditure_type		IN	VARCHAR2,
				p_expenditure_organization_id	IN	NUMBER,
				p_payroll_id			IN	NUMBER,
				p_start_date			OUT NOCOPY	DATE,
				p_end_date			OUT NOCOPY	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2);

END psp_enc_pre_process;

 

/
