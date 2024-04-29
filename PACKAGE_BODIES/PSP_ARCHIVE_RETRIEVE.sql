--------------------------------------------------------
--  DDL for Package Body PSP_ARCHIVE_RETRIEVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ARCHIVE_RETRIEVE" as
/* $Header: PSPARRTB.pls 120.6 2006/07/27 23:05:07 vdharmap noship $  */

/****************************************************************************************
	Created By	: Ddubey/Lveerubh

	Date Created By : 23-FEB-2001

	Purpose		: This procedure is to archive labor cost distribution history
		 	  for a given payroll name ,begin period and end period.

	Know limitations, enhancements or remarks :

	Change History	:

****************************************************************************************/
PROCEDURE archive_distribution (errbuf                  OUT NOCOPY 	VARCHAR2,
				retcode             	OUT NOCOPY 	VARCHAR2,
	                  	p_payroll_id         	IN  	NUMBER,
                         	p_begin_period     	IN 	NUMBER,
                         	p_end_period            IN 	NUMBER,
                         	p_business_group_id     IN 	NUMBER,
                         	p_set_of_books_id       IN 	NUMBER) IS

--Cursor to check if the begin and end period for the selected payroll name are valid
CURSOR error_check_cur IS
	SELECT	distinct PPC.source_type,
		PPC.time_period_id,
		PTP.period_name
	FROM 	PSP_PAYROLL_CONTROLS PPC,
		PER_TIME_PERIODS     PTP
	WHERE 	PPC.time_period_id 	=	PTP.time_period_id
          and 	PPC.payroll_id 	  	=   	p_payroll_id
          and 	PPC.time_period_id	>=  	p_begin_period
          and 	PPC.time_period_id	<=  	p_end_period
          and	PPC.business_group_id	=   	p_business_group_id
          and	PPC.set_of_books_id     =   	p_set_of_books_id
          and 	PPC.archive_flag	is 	NULL
--For bug fix 1767315
	  and	PPC.status_code	        <>	'P'
	  --and 	PPC.time_period_id in ( SELECT PPC2.time_period_id
	  		--		FROM 	psp_payroll_controls PPC2
			--		WHERE	PPC2.time_period_id	= PPC.time_period_id
			--			and PPC2.status_code	<> 'P'
			--		)
--End of Bug fix
	ORDER BY   PPC.time_period_id;

-- the following cursor has been redefined to include time periodwise error message
--For bug fix 1769523:Archiving : EFFT RPT Pending for certification,Payroll Period Archived
--Cursor to check if there are any pending effort reports for the selected begin and end periods
-- and for the selected payroll
--CURSOR effort_pending_cur IS
--SELECT	  1
--FROM	 DUAL
--WHERE 	EXISTS
--	(
--	SELECT DISTINCT PER.effort_report_id,
--			PER.version_num
--	 FROM		PSP_EFFORT_REPORTS PER,
--		        PSP_EFFORT_REPORT_DETAILS PERD,
--			PER_ASSIGNMENTS_F PAF,
--	    		PER_TIME_PERIODS PTP1,
--   			PER_TIME_PERIODS PTP2,
--  			PSP_EFFORT_REPORT_PERIODS PERP,
-- 			PSP_EFFORT_REPORT_TEMPLATES PERT
--	 WHERE 		PER.status_Code		<>	'C'
--	 and 		PER.effort_Report_id	= 	PERD.effort_report_id
--	 and		PER.version_num		= 	PERD.version_num
--	 and		PAF.assignment_id	= 	PERD.assignment_id
--	 and		PAF.payroll_id		= 	p_payroll_id
--	 and		PER.template_id		= 	PERT.template_id
--	 and		PERT.effort_report_period_name	=	PERP.effort_report_period_name
--	 and		PTP1.time_period_id	=	p_begin_period
--	 and		PTP2.TIME_PERIOD_ID 	=	p_end_period
--	 and		(
--		      PERP.start_date_active  	between       PTP1.start_date   and   PTP2.end_date
--	      or      PERP.end_date_active      between       PTP1.start_date   and   PTP2.end_date
--	      or      PTP1.start_date           between       PERP.start_date_active  and   PERP.end_date_active
--	      or      PTP2.end_date             between       PERP.start_date_active  and   PERP.end_date_active
--       	        )
--	and		PER.business_group_id	=	p_business_group_id
--	and		PER.set_of_books_id	=	p_set_of_books_id
--	);

CURSOR	effort_pending_cur IS
SELECT	period_name
FROM	per_time_periods PTP
WHERE	PTP.payroll_id = p_payroll_id
AND	PTP.time_period_id	>=	p_begin_period
AND	PTP.time_period_id	<=	p_end_period
AND	EXISTS	(SELECT	1
		FROM	PSP_EFFORT_REPORTS PER,
			PSP_EFFORT_REPORT_DETAILS PERD,
			PER_ASSIGNMENTS_F PAF,
			PSP_EFFORT_REPORT_PERIODS PERP,
			PSP_EFFORT_REPORT_TEMPLATES PERT
		WHERE 	PER.status_code			<>	'C'
		and 	PER.effort_Report_id		= 	PERD.effort_report_id
		and	PER.version_num			= 	PERD.version_num
 		and	PAF.assignment_id		= 	PERD.assignment_id
		and	PAF.payroll_id			= 	PTP.payroll_id
		and	PER.template_id			= 	PERT.template_id
		and	PERT.effort_report_period_name	=	PERP.effort_report_period_name
		and	(	PERP.start_date_active	BETWEEN	PTP.start_date   and   PTP.end_date
			OR	PERP.end_date_active	BETWEEN	PTP.start_date   and   PTP.end_date
			OR	PTP.start_date		BETWEEN	PERP.start_date_active  and   PERP.end_date_active
			OR	PTP.end_date		BETWEEN	PERP.start_date_active  and   PERP.end_date_active)
	and		PER.business_group_id	=	p_business_group_id
	and		PER.set_of_books_id	=	p_set_of_books_id);

-- Cursor to select valid periods that can be archived
-- Included 'distinct' in the select for bug fix 1759548
CURSOR valid_period_cur IS
	SELECT	distinct PPC.time_period_id,
		PTP.period_name
	FROM	PSP_PAYROLL_CONTROLS PPC,
		PER_TIME_PERIODS PTP
	WHERE	PPC.payroll_id		=	p_payroll_id
         and	PPC.time_period_id	>=	p_begin_period
         and	PPC.time_period_id	<=	p_end_period
         and	PPC.archive_flag	is	NULL
         and	PPC.business_group_id 	=	p_business_group_id
         and	PPC. set_of_books_id  	= 	p_set_of_books_id
         and	PPC.time_period_id	=	PTP.time_period_id
        ORDER BY   PPC.time_period_id;

-- Cursors to get payroll name, begin period name, end period name for displaying in the messages
CURSOR payroll_name_cur IS
	SELECT 	distinct PPF.payroll_name
	FROM    PAY_PAYROLLS_F PPF
        WHERE 	PPF.payroll_id 		=	p_payroll_id
        and   	PPF.business_group_id 	=	p_business_group_id
        and 	PPF.gl_set_of_books_id	=	p_set_of_books_id;

CURSOR begin_period_name_cur IS
	SELECT	distinct PTP.period_name
	FROM	PER_TIME_PERIODS PTP
	WHERE	PTP.time_period_id	=	p_begin_period;

CURSOR end_period_name_cur IS
	SELECT	distinct PTP.period_name
	FROM	PER_TIME_PERIODS PTP
	WHERE	PTP.time_period_id	=	p_end_period;

         l_error_api_name              	VARCHAR2(2000);
         l_status                      	VARCHAR2(15);
         l_error_period_count          	NUMBER;
         l_time_period	               	NUMBER(15);
         l_period_name                 	VARCHAR2(70);
         l_begin_period_name           	VARCHAR2(70);
         l_end_period_name             	VARCHAR2(70);
         l_process_type                	VARCHAR2(15) := 'Archive';
         l_lines_type                  	VARCHAR2(30) := 'Distribution Lines';
	 l_payroll_name                	VARCHAR2(80);
	 l_effort_count			NUMBER(5);
	 payroll_name_rec		payroll_name_cur%ROWTYPE;
	 begin_period_name_rec		begin_period_name_cur%ROWTYPE;
	 end_period_name_rec		end_period_name_cur%ROWTYPE;
	 error_check_rec		error_check_cur%ROWTYPE;
	 valid_period_rec		valid_period_cur%ROWTYPE;
	 effort_pending_rec		effort_pending_cur%ROWTYPE;

BEGIN
	fnd_msg_pub.initialize;
	OPEN payroll_name_cur;
	FETCH payroll_name_cur INTO payroll_name_rec;
	l_payroll_name	:=	payroll_name_rec.payroll_name;
	CLOSE payroll_name_cur;

	OPEN begin_period_name_cur;
	FETCH begin_period_name_cur INTO begin_period_name_rec;
	l_begin_period_name	:=	begin_period_name_rec.period_name;
	CLOSE begin_period_name_cur;

	OPEN end_period_name_cur;
	FETCH end_period_name_cur INTO end_period_name_rec;
	l_end_period_name	:=	end_period_name_rec.period_name;
	CLOSE end_period_name_cur;

--For bug fixing 1769523
--Checking if any Effort Reports are pending for Certification ,in which Archiving cannot be done
	 OPEN effort_pending_cur;
         FETCH  effort_pending_cur INTO effort_pending_rec;
         l_effort_count := effort_pending_cur%ROWCOUNT;
         CLOSE effort_pending_cur;
--End of Bug Fix
	FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_START');
	FND_MESSAGE.SET_TOKEN('PROCESS_TYPE', l_process_type);
	FND_MESSAGE.SET_TOKEN('LINES_TYPE', l_lines_type);
	FND_MESSAGE.SET_TOKEN('BEGIN_PERIOD', l_begin_period_name);
	FND_MESSAGE.SET_TOKEN('END_PERIOD', l_end_period_name);
	FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
	fnd_msg_pub.add;

-- Checking for periods which have unprocessed lines
	OPEN error_check_cur;
	  FETCH  error_check_cur INTO error_check_rec;
         l_error_period_count := error_check_cur%ROWCOUNT;
	CLOSE error_check_cur;

	IF  (l_error_period_count > 0) THEN
	OPEN error_check_cur;
          LOOP
           FETCH  error_check_cur INTO error_check_rec;
           EXIT WHEN error_check_cur%NOTFOUND ;
		l_time_period	:=	error_check_rec.time_period_id;
		l_period_name	:= 	error_check_rec.period_name;
		IF (error_check_rec.source_type = 'O') THEN
		  FND_MESSAGE.SET_NAME('PSP','PSP_ARC_LDO_CANNOT_ARCHIVE');
		  FND_MESSAGE.SET_TOKEN('PAYROLL_NAME',l_payroll_name);
                  FND_MESSAGE.SET_TOKEN('TIME_PERIOD',l_period_name);
		  fnd_msg_pub.add;

  		ELSIF (error_check_rec.source_type = 'N') THEN
		  FND_MESSAGE.SET_NAME('PSP','PSP_ARC_LDN_CANNOT_ARCHIVE');
		  FND_MESSAGE.SET_TOKEN('PAYROLL_NAME',l_payroll_name);
                  FND_MESSAGE.SET_TOKEN('TIME_PERIOD',l_period_name);
		  fnd_msg_pub.add;

		ELSIF (error_check_rec.source_type = 'P') THEN
		  FND_MESSAGE.SET_NAME('PSP','PSP_ARC_LDP_CANNOT_ARCHIVE');
		  FND_MESSAGE.SET_TOKEN('PAYROLL_NAME',l_payroll_name);
                  FND_MESSAGE.SET_TOKEN('TIME_PERIOD',l_period_name);
		  fnd_msg_pub.add;

		ELSIF (error_check_rec.source_type = 'A') THEN
		  FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_LDA_CANNOT_ARCHIVE');
		  FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
                  FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
		  fnd_msg_pub.add;
		END IF;
	  END LOOP;
	CLOSE error_check_cur;

--For bug fixing 1769523
--Checking if any Effort Reports are pending for Certification ,in which Archiving cannot be done
        IF  (l_effort_count > 0) THEN
--		Included the following cursor for bug fix 1818874
		OPEN effort_pending_cur;
		LOOP
			FETCH effort_pending_cur INTO effort_pending_rec;
			EXIT WHEN effort_pending_cur%NOTFOUND ;

			l_period_name := effort_pending_rec.period_name;
			FND_MESSAGE.SET_NAME('PSP', 'PSP_EFFORT_ARCH_PENDING');
			FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
			FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
			fnd_msg_pub.add;
		END LOOP;
		CLOSE effort_pending_cur;
        END IF;
--End of Bug Fix

                l_status        :=      'unsuccessful';

		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
		FND_MESSAGE.SET_TOKEN('PROCESS_TYPE', l_process_type);
		FND_MESSAGE.SET_TOKEN('LINES_TYPE', l_lines_type);
		FND_MESSAGE.SET_TOKEN('STATUS', l_status);
		fnd_msg_pub.add;
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

--For bug fixing 1769523
--Checking if any Effort Reports are pending for Certification ,in which Archiving cannot be done
        IF  (l_effort_count > 0) THEN
--	Included the following cursor for bug fix 1818874
		l_status        :=      'unsuccessful';
		OPEN effort_pending_cur;
		LOOP
			FETCH effort_pending_cur INTO effort_pending_rec;
			EXIT WHEN effort_pending_cur%NOTFOUND ;

			l_period_name := effort_pending_rec.period_name;
			FND_MESSAGE.SET_NAME('PSP', 'PSP_EFFORT_ARCH_PENDING');
			FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
			FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
			fnd_msg_pub.add;
		END LOOP;
		CLOSE effort_pending_cur;

		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
                FND_MESSAGE.SET_TOKEN('PROCESS_TYPE', l_process_type);
                FND_MESSAGE.SET_TOKEN('LINES_TYPE', l_lines_type);
                FND_MESSAGE.SET_TOKEN('STATUS', l_status);
                fnd_msg_pub.add;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
--End of Bug Fix

-- Archiving data into the new archival tables and purging the data from the history tables
-- Standard WHO columns and Concurrent WHO columns


 	OPEN valid_period_cur;
	LOOP
	FETCH valid_period_cur  INTO valid_period_rec;
	EXIT WHEN valid_period_cur%NOTFOUND ;
	l_period_name	:=	valid_period_rec.period_name;

-- Insert data into archive table PSP_DISTRIBUTION_LINES_ARCH from PSP_DISTRIBUTION_LINES_HISTORY for the valid_period
	INSERT  INTO    PSP_DISTRIBUTION_LINES_ARCH
	(
	distribution_line_id,				distribution_date,
	effective_date,					distribution_amount,
	status_code,					default_reason_code,
	suspense_reason_code,				include_in_er_flag,
	effort_report_id,				version_num,
	schedule_line_id,				summary_line_id,
	default_org_account_id,				suspense_org_account_id,
	element_account_id,				org_schedule_id,
	gl_project_flag,				reversal_entry_flag,
	user_defined_field,				adjustment_batch_name,
	set_of_books_id,				payroll_sub_line_id,
	auto_expenditure_type,				auto_gl_code_combination_id,
	business_group_id,				attribute_category,		-- Introduced DFF columns for bug fix 2908859
	attribute1,					attribute2,   --- 4304623:nih salary cap
	attribute3,					attribute4,
	attribute5,					attribute6,
	attribute7,					attribute8,
	attribute9,					attribute10,
        cap_excess_glccid,                              cap_excess_award_id,
        cap_excess_task_id,                             cap_excess_project_id,
        cap_excess_exp_type,                            cap_excess_exp_org_id,
        funding_source_code,                            annual_salary_cap,
        cap_excess_dist_line_id,                        suspense_auto_glccid,
        suspense_auto_exp_type,                         adj_account_flag)  -- added for 5080403
	SELECT
	PDLH.distribution_line_id,			PDLH.distribution_date,
	PDLH.effective_date,				PDLH.distribution_amount,
	PDLH.status_code,				PDLH.default_reason_code,
	PDLH.suspense_reason_code,			PDLH.include_in_er_flag,
	PDLH.effort_report_id,				PDLH.version_num,
	PDLH.schedule_line_id,				PDLH.summary_line_id,
	PDLH.default_org_account_id,			PDLH.suspense_org_account_id,
	PDLH.element_account_id,			PDLH.org_schedule_id,
	PDLH.gl_project_flag,				PDLH.reversal_entry_flag,
	PDLH.user_defined_field,			PDLH.adjustment_batch_name,
	PDLH.set_of_books_id,				PDLH.payroll_sub_line_id,
	PDLH.auto_expenditure_type,			PDLH.auto_gl_code_combination_id,
	PDLH.business_group_id,				pdlh.attribute_category,	-- Introduced DFF columns for bug fix 2908859
	pdlh.attribute1,				pdlh.attribute2,
	pdlh.attribute3,				pdlh.attribute4,
	pdlh.attribute5,				pdlh.attribute6,
	pdlh.attribute7,				pdlh.attribute8,
	pdlh.attribute9,				pdlh.attribute10,
        pdlh.cap_excess_glccid,                         pdlh.cap_excess_award_id,
        pdlh.cap_excess_task_id,                        pdlh.cap_excess_project_id,
        pdlh.cap_excess_exp_type,                       pdlh.cap_excess_exp_org_id,
        pdlh.funding_source_code,                       pdlh.annual_salary_cap,
        pdlh.cap_excess_dist_line_id,                   pdlh.suspense_auto_glccid,
        pdlh.suspense_auto_exp_type,                    pdlh.adj_account_flag  -- added for 5080403
	FROM	PSP_DISTRIBUTION_LINES_HISTORY PDLH,
		PSP_SUMMARY_LINES  PSL
	WHERE	PDLH.summary_line_id	=	PSL.summary_line_id
	and	PSL.time_period_id	=	valid_period_rec.time_period_id ;

-- Insert data into archive table PSP_ADJUSTMENT_LINES_ARCH from PSP_ADJUSTMENT_LINES_HISTORY for the valid_period
	INSERT INTO PSP_ADJUSTMENT_LINES_ARCH
	(
	adjustment_line_id,			person_id,
	assignment_id,				element_type_id,
	distribution_date,			effective_date,
	distribution_amount,			dr_cr_flag,
	payroll_control_id,			source_code,
	time_period_id,				batch_name,
	status_code,				set_of_books_id,
	gl_code_combination_id,			project_id,
	expenditure_organization_id,		expenditure_type,
	task_id,				award_id,
	suspense_org_account_id,		suspense_reason_code,
	include_in_er_flag,			effort_report_id,
	version_num,				summary_line_id,
	reversal_entry_flag,			original_line_flag,
	user_defined_field,			adjustment_batch_name,
	percent,				orig_source_type,
	orig_line_id,				attribute_category,
	attribute1,				attribute2,
	attribute3,				attribute4,
	attribute5,				attribute6,
	attribute7,				attribute8,
	attribute9,				attribute10,
	attribute11,				attribute12,
	attribute13,				attribute14,
	attribute15,				last_update_date,
	last_updated_by,			last_update_login,
	created_by,				creation_date,
	source_type,				business_group_id,
        adj_set_number,                         line_number)
	SELECT
	PALH.adjustment_line_id,		PALH.person_id,
	PALH.assignment_id,			PALH.element_type_id,
	PALH.distribution_date,			PALH.effective_date,
	PALH.distribution_amount,		PALH.dr_cr_flag,
	PALH.payroll_control_id,		PALH.source_code,
	PALH.time_period_id,			PALH.batch_name,
	PALH.status_code,			PALH.set_of_books_id,
	PALH.gl_code_combination_id,		PALH.project_id,
	PALH.expenditure_organization_id,	PALH.expenditure_type,
	PALH.task_id,				PALH.award_id,
	PALH.suspense_org_account_id,		PALH.suspense_reason_code,
	PALH.include_in_er_flag,		PALH.effort_report_id,
	PALH.version_num,			PALH.summary_line_id,
	PALH.reversal_entry_flag,		PALH.original_line_flag,
	PALH.user_defined_field,		PALH.adjustment_batch_name,
	PALH.percent,				PALH.orig_source_type,
	PALH.orig_line_id,			PALH.attribute_category,
	PALH.attribute1,			PALH.attribute2,
	PALH.attribute3,			PALH.attribute4,
	PALH.attribute5,			PALH.attribute6,
	PALH.attribute7,			PALH.attribute8,
	PALH.attribute9,			PALH.attribute10,
	PALH.attribute11,			PALH.attribute12,
	PALH.attribute13,			PALH.attribute14,
	PALH.attribute15,			PALH.last_update_date,
	PALH.last_updated_by,			PALH.last_update_login,
	PALH.created_by,			PALH.creation_date,
	PALH.source_type,			PALH.business_group_id,
        PALH.adj_set_number,                    PALH.line_number
	FROM	PSP_ADJUSTMENT_LINES_HISTORY PALH
	WHERE	PALH.time_period_id	=	 valid_period_rec.time_period_id ;

-- Insert data into archive table PSP_PRE_GEN_DIST_LINES_ARCH from PSP_PRE_GEN_LINES_HISTORY for the valid_period.
	INSERT INTO PSP_PRE_GEN_DIST_LINES_ARCH
	(
	pre_gen_dist_line_id,		distribution_interface_id,
	person_id,			assignment_id,
	element_type_id,		distribution_date,
	effective_date,			distribution_amount,
	dr_cr_flag,			payroll_control_id,
	source_type,			source_code,
	time_period_id,			batch_name,
	status_code,			set_of_books_id,
	gl_code_combination_id,		project_id,
	expenditure_organization_id,	expenditure_type,
	task_id,			award_id,
	suspense_org_account_id,	suspense_reason_code,
	include_in_er_flag,		effort_report_id,
	version_num,			summary_line_id,
	reversal_entry_flag,		user_defined_field,
	adjustment_batch_name,		business_group_id,
	attribute_category,						-- Introduced DFF columns for bug fix 2908859
	attribute1,			attribute2,
	attribute3,			attribute4,
	attribute5,			attribute6,
	attribute7,			attribute8,
	attribute9,			attribute10,
        suspense_auto_glccid,           suspense_auto_exp_type)
	SELECT
	PGDLH.pre_gen_dist_line_id,		PGDLH.distribution_interface_id,
	PGDLH.person_id,			PGDLH.assignment_id,
	PGDLH.element_type_id,			PGDLH.distribution_date,
	PGDLH.effective_date,			PGDLH.distribution_amount,
	PGDLH.dr_cr_flag,			PGDLH.payroll_control_id,
	PGDLH.source_type,			PGDLH.source_code,
	PGDLH.time_period_id,			PGDLH.batch_name,
	PGDLH.status_code,			PGDLH.set_of_books_id,
	PGDLH.gl_code_combination_id,		PGDLH.project_id,
	PGDLH.expenditure_organization_id,	PGDLH.expenditure_type,
	PGDLH.task_id,				PGDLH.award_id,
	PGDLH.suspense_org_account_id,		PGDLH.suspense_reason_code,
	PGDLH.include_in_er_flag,		PGDLH.effort_report_id,
	PGDLH.version_num,			PGDLH.summary_line_id,
	PGDLH.reversal_entry_flag,		PGDLH.user_defined_field,
	PGDLH.adjustment_batch_name,		PGDLH.business_group_id,
	pgdlh.attribute_category,					-- Introduced DFF columns for bug fix 2908859
	pgdlh.attribute1,			pgdlh.attribute2,
	pgdlh.attribute3,			pgdlh.attribute4,
	pgdlh.attribute5,			pgdlh.attribute6,
	pgdlh.attribute7,			pgdlh.attribute8,
	pgdlh.attribute9,			pgdlh.attribute10,
        pgdlh.suspense_auto_glccid,             pgdlh.suspense_auto_exp_type
	FROM	PSP_PRE_GEN_DIST_LINES_HISTORY PGDLH
	WHERE	PGDLH.time_period_id	=	valid_period_rec.time_period_id ;

-- Insert data into archive table PSP_SUMMARY_LINES_ARCH from PSP_SUMMARY_LINES for the valid_period
	INSERT INTO PSP_SUMMARY_LINES_ARCH
	(
	summary_line_id,		source_type,
	source_code,			time_period_id,
	interface_batch_name,		person_id,
	assignment_id,			effective_date,
        accounting_date,                exchange_rate_type,
	payroll_control_id,		gl_code_combination_id,
	project_id,			expenditure_organization_id,
	expenditure_type,		task_id,
	award_id,			summary_amount,
	dr_cr_flag,			group_id,
	interface_status,		attribute_category,
	attribute1,			attribute2,
	attribute3,			attribute4,
	attribute5,			attribute6,
	attribute7,			attribute8,
	attribute9,			attribute10,
	attribute11,			attribute12,
	attribute13,			attribute14,
	attribute15,			attribute16,
	attribute17,			attribute18,
	attribute19,			attribute20,
	attribute21,			attribute22,
	attribute23,			attribute24,
	attribute25,			attribute26,
	attribute27,			attribute28,
 	attribute29,			attribute30,
 	last_update_date,		last_updated_by,
 	last_update_login,		created_by,
 	creation_date,			set_of_books_id,
 	business_group_id,		status_code,
 	gms_batch_name,                 gms_posting_effective_date,/* added posting eff dt. for Zero work Days */
        expenditure_id,                 expenditure_item_id,  -- added five exp columns for 2445196
        expenditure_ending_date,        interface_id,
        txn_interface_id,		actual_summary_amount -- For Bug 2496661 : Added new column actual_summary_amount
	)
	SELECT
	PSL.summary_line_id,		PSL.source_type,
	PSL.source_code,		PSL.time_period_id,
	PSL.interface_batch_name,	PSL.person_id,
	PSL.assignment_id,		PSL.effective_date,
        PSL.accounting_date,            PSL.exchange_rate_type,
	PSL.payroll_control_id,		PSL.gl_code_combination_id,
	PSL.project_id,			PSL.expenditure_organization_id,
	PSL.expenditure_type,		PSL.task_id,
	PSL.award_id,			PSL.summary_amount,
	PSL.dr_cr_flag,			PSL.group_id,
	PSL.interface_status,		PSL.attribute_category,
	PSL.attribute1,			PSL.attribute2,
	PSL.attribute3,			PSL.attribute4,
	PSL.attribute5,			PSL.attribute6,
	PSL.attribute7,			PSL.attribute8,
	PSL.attribute9,			PSL.attribute10,
	PSL.attribute11,		PSL.attribute12,
	PSL.attribute13,		PSL.attribute14,
	PSL.attribute15,		PSL.attribute16,
	PSL.attribute17,		PSL.attribute18,
	PSL.attribute19,		PSL.attribute20,
	PSL.attribute21,		PSL.attribute22,
	PSL.attribute23,		PSL.attribute24,
	PSL.attribute25,		PSL.attribute26,
	PSL.attribute27,		PSL.attribute28,
 	PSL.attribute29,		PSL.attribute30,
 	PSL.last_update_date,		PSL.last_updated_by,
 	PSL.last_update_login,		PSL.created_by,
 	PSL.creation_date,		PSL.set_of_books_id,
 	PSL.business_group_id,		PSL.status_code,
 	PSL.gms_batch_name,             PSL.gms_posting_effective_date,/*posting eff dt added for zero work days */
        PSL.expenditure_id,             PSL.expenditure_item_id,  -- added five exp columns for 2445196
        PSL.expenditure_ending_date,    PSL.interface_id,
        PSL.txn_interface_id,		PSL.actual_summary_amount --For bug 2496661 : Added a new column actual_summary_amount
	FROM	PSP_SUMMARY_LINES PSL
	WHERE	PSL.time_period_id	= 	valid_period_rec.time_period_id;

-- Delete from the actual table PSP_DISTRIBUTION_LINES_HISTORY for the valid_period
	DELETE	PSP_DISTRIBUTION_LINES_HISTORY	PDLH
	WHERE	PDLH.summary_line_id	in
		(
		SELECT	PSL.summary_line_id
		FROM	PSP_SUMMARY_LINES PSL
		WHERE	PSL.summary_line_id	=	PDLH.summary_line_id
		and	PSL.time_period_id	=	valid_period_rec.time_period_id
		);

-- Delete from the actual table PSP_ADJUSTMENT_LINES_HISTORY for the valid_period
	DELETE	PSP_ADJUSTMENT_LINES_HISTORY	PALH
	WHERE	PALH.time_period_id	=	valid_period_rec.time_period_id;

-- Delete from the actual table PSP_PRE_GEN_DIST_LINES_HISTORYfor the curr_period
	DELETE	PSP_PRE_GEN_DIST_LINES_HISTORY	PPGDH
	WHERE	PPGDH. time_period_id	=	valid_period_rec.time_period_id;

-- Delete from the actual table PSP_SUMMARY_LINES for the valid_period
	DELETE	PSP_SUMMARY_LINES	PSL
	WHERE	PSL.time_period_id	=	valid_period_rec.time_period_id;

-- Update the status of archive_flag in PSP_PAYROLL_CONTROLS to 'Y'
	UPDATE	PSP_PAYROLL_CONTROLS	PPC
	SET	PPC.archive_flag	=	'Y'
	WHERE	PPC.time_period_id	=	valid_period_rec.time_period_id;

	Commit;
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_LD_ARCHIVE_PERIOD');
		FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
		FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
		fnd_msg_pub.add;
	END LOOP;
	CLOSE valid_period_cur;

		l_status:='successful';
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
		FND_MESSAGE.SET_TOKEN('PROCESS_TYPE', l_process_type);
		FND_MESSAGE.SET_TOKEN('LINES_TYPE', l_lines_type);
		FND_MESSAGE.SET_TOKEN('STATUS', l_status);
             	fnd_msg_pub.add;
             	--psp_message_s.print_success;
		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_FALSE);
		retcode := 0;
EXCEPTION

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	/* Following added for bug 2482603 */
	g_error_api_path := SUBSTR('ARCHIVE_DISTRIBUTION '||g_error_api_path,1,230);
	fnd_msg_pub.add_exc_msg('PSP_ARCHIVE_RETRIEVE',g_error_api_path);
	psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
					p_print_header	=>	FND_API.G_TRUE);
	retcode := 2;

	WHEN OTHERS THEN
	/* Following added for bug 2482603 */
	g_error_api_path := SUBSTR('ARCHIVE_DISTRIBUTION '||g_error_api_path,1,230);
	fnd_msg_pub.add_exc_msg('PSP_ARCHIVE_RETRIEVE',g_error_api_path);
	psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
					p_print_header	=>	FND_API.G_TRUE);
	retcode := 2;
END archive_distribution;

/****************************************************************************************
	Created By	: Lveerubh

	Date Created By : 03-MAR-2001

	Purpose		: This procedure is to retrieve labor cost distribution history
		 	  for a given payroll name ,begin period and end period.

	Know limitations, enhancements or remarks :

	Change History	:

****************************************************************************************/
PROCEDURE retrieve_distribution(errbuf            	 OUT NOCOPY VARCHAR2,
                         	retcode                  OUT NOCOPY VARCHAR2,
                         	p_payroll_id             IN  NUMBER,
                         	p_begin_period           IN NUMBER,
                         	p_end_period             IN NUMBER,
                        	p_business_group_id      IN NUMBER,
                         	p_set_of_books_id        IN NUMBER)
IS
-- Cursor to select valid periods that can be retrieved
-- For bug fix 1777003, 1778727, retained the following select stmt. as the functionality had changed.
CURSOR valid_period_cur IS
	SELECT	distinct PPC.time_period_id,
		PTP.period_name
	FROM	PSP_PAYROLL_CONTROLS PPC,
		PER_TIME_PERIODS PTP
	WHERE	PPC.payroll_id		=	p_payroll_id
         and	PPC.time_period_id	>=	p_begin_period
         and	PPC.time_period_id	<=	p_end_period
         and	PPC.archive_flag	=	'Y'
         and	PPC.business_group_id 	=	p_business_group_id
         and	PPC. set_of_books_id  	= 	p_set_of_books_id
         and	PPC.time_period_id	=	PTP.time_period_id
        ORDER BY   PPC.time_period_id;

-- Cursors to get payroll name, begin period name, end period name for displaying in the messages
CURSOR payroll_name_cur IS
	SELECT 	distinct PPF.payroll_name
	FROM    PAY_PAYROLLS_F PPF
        WHERE 	PPF.payroll_id 		=	p_payroll_id
        and   	PPF.business_group_id 	=	p_business_group_id
        and 	PPF.gl_set_of_books_id	=	p_set_of_books_id;

CURSOR begin_period_name_cur IS
	SELECT	distinct PTP.period_name
	FROM	PER_TIME_PERIODS PTP
	WHERE	PTP.time_period_id	=	p_begin_period;

CURSOR end_period_name_cur IS
	SELECT	distinct PTP.period_name
	FROM	PER_TIME_PERIODS PTP
	WHERE	PTP.time_period_id	=	p_end_period;

         l_error_api_name              	VARCHAR2(2000);
         l_status                      	VARCHAR2(15);
         l_error_period_count          	NUMBER;
         l_time_period	               	NUMBER(15);
         l_period_name                 	VARCHAR2(70);
         l_begin_period_name           	VARCHAR2(70);
         l_end_period_name             	VARCHAR2(70);
         l_process_type                	VARCHAR2(15) := 'Retrieve';
         l_lines_type                  	VARCHAR2(30) := 'Distribution Lines';
	 l_payroll_name                	VARCHAR2(80);
	 payroll_name_rec		payroll_name_cur%ROWTYPE;
	 begin_period_name_rec		begin_period_name_cur%ROWTYPE;
	 end_period_name_rec		end_period_name_cur%ROWTYPE;
	 valid_period_rec		valid_period_cur%ROWTYPE;

BEGIN
	fnd_msg_pub.initialize;
	OPEN payroll_name_cur;
	FETCH payroll_name_cur INTO payroll_name_rec;
	l_payroll_name	:=	payroll_name_rec.payroll_name;
	CLOSE payroll_name_cur;

	OPEN begin_period_name_cur;
	FETCH begin_period_name_cur INTO begin_period_name_rec;
	l_begin_period_name	:=	begin_period_name_rec.period_name;
	CLOSE begin_period_name_cur;

	OPEN end_period_name_cur;
	FETCH end_period_name_cur INTO end_period_name_rec;
	l_end_period_name	:=	end_period_name_rec.period_name;
	CLOSE end_period_name_cur;

	FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_START');
	FND_MESSAGE.SET_TOKEN('PROCESS_TYPE', l_process_type);
	FND_MESSAGE.SET_TOKEN('LINES_TYPE', l_lines_type);
	FND_MESSAGE.SET_TOKEN('BEGIN_PERIOD', l_begin_period_name);
	FND_MESSAGE.SET_TOKEN('END_PERIOD', l_end_period_name);
	FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
	fnd_msg_pub.add;

	OPEN valid_period_cur;
	LOOP
	FETCH valid_period_cur  INTO valid_period_rec;
	EXIT WHEN valid_period_cur%NOTFOUND ;
	l_period_name	:=	valid_period_rec.period_name;


-- Insert data from archive table PSP_DISTRIBUTION_LINES_ARCH into PSP_DISTRIBUTION_LINES_HISTORY for the valid_period

	INSERT  INTO    PSP_DISTRIBUTION_LINES_HISTORY
	(
	distribution_line_id,				distribution_date,
	effective_date,					distribution_amount,
	status_code,					default_reason_code,
	suspense_reason_code,				include_in_er_flag,
	effort_report_id,				version_num,
	schedule_line_id,				summary_line_id,
	default_org_account_id,				suspense_org_account_id,
	element_account_id,				org_schedule_id,
	gl_project_flag,				reversal_entry_flag,
	user_defined_field,				adjustment_batch_name,
	set_of_books_id,				payroll_sub_line_id,
	auto_expenditure_type,				auto_gl_code_combination_id,
	business_group_id,				attribute_category,		-- Introduced DFF columns for bug fix 2908859
	attribute1,					attribute2,
	attribute3,					attribute4,
	attribute5,					attribute6,
	attribute7,					attribute8,
	attribute9,					attribute10,
        cap_excess_glccid,                              cap_excess_award_id,
        cap_excess_task_id,                             cap_excess_project_id,
        cap_excess_exp_type,                            cap_excess_exp_org_id,
        funding_source_code,                            annual_salary_cap,
        cap_excess_dist_line_id,                        suspense_auto_glccid,
        suspense_auto_exp_type,                          adj_account_flag)
	SELECT
	PDLA.distribution_line_id,			PDLA.distribution_date,
	PDLA.effective_date,				PDLA.distribution_amount,
	PDLA.status_code,				PDLA.default_reason_code,
	PDLA.suspense_reason_code,			PDLA.include_in_er_flag,
	PDLA.effort_report_id,				PDLA.version_num,
	PDLA.schedule_line_id,				PDLA.summary_line_id,
	PDLA.default_org_account_id,			PDLA.suspense_org_account_id,
	PDLA.element_account_id,			PDLA.org_schedule_id,
	PDLA.gl_project_flag,				PDLA.reversal_entry_flag,
	PDLA.user_defined_field,			PDLA.adjustment_batch_name,
	PDLA.set_of_books_id,				PDLA.payroll_sub_line_id,
	PDLA.auto_expenditure_type,			PDLA.auto_gl_code_combination_id,
	pdla.business_group_id,				pdla.attribute_category,		-- Introduced DFF columns for bug fix 2908859
	pdla.attribute1,				pdla.attribute2,
	pdla.attribute3,				pdla.attribute4,
	pdla.attribute5,				pdla.attribute6,
	pdla.attribute7,				pdla.attribute8,
	pdla.attribute9,				pdla.attribute10,
        pdla.cap_excess_glccid,                         pdla.cap_excess_award_id,  --4304623: nih salary cap
        pdla.cap_excess_task_id,                        pdla.cap_excess_project_id,
        pdla.cap_excess_exp_type,                       pdla.cap_excess_exp_org_id,
        pdla.funding_source_code,                       pdla.annual_salary_cap,
        pdla.cap_excess_dist_line_id,                   pdla.suspense_auto_glccid,
        pdla.suspense_auto_exp_type,                    pdla.adj_account_flag
	FROM	PSP_DISTRIBUTION_LINES_ARCH PDLA,
		PSP_SUMMARY_LINES_ARCH  PSLA
	WHERE	PDLA.summary_line_id	=	PSLA.summary_line_id
	and	PSLA.time_period_id	=	valid_period_rec.time_period_id ;

-- Insert data from archive table PSP_ADJUSTMENT_LINES_ARCH into PSP_ADJUSTMENT_LINES_HISTORY for the valid_period
	INSERT INTO PSP_ADJUSTMENT_LINES_HISTORY
	(
	adjustment_line_id,			person_id,
	assignment_id,				element_type_id,
	distribution_date,			effective_date,
	distribution_amount,			dr_cr_flag,
	payroll_control_id,			source_code,
	time_period_id,				batch_name,
	status_code,				set_of_books_id,
	gl_code_combination_id,			project_id,
	expenditure_organization_id,		expenditure_type,
	task_id,				award_id,
	suspense_org_account_id,		suspense_reason_code,
	include_in_er_flag,			effort_report_id,
	version_num,				summary_line_id,
	reversal_entry_flag,			original_line_flag,
	user_defined_field,			adjustment_batch_name,
	percent,				orig_source_type,
	orig_line_id,				attribute_category,
	attribute1,				attribute2,
	attribute3,				attribute4,
	attribute5,				attribute6,
	attribute7,				attribute8,
	attribute9,				attribute10,
	attribute11,				attribute12,
	attribute13,				attribute14,
	attribute15,				last_update_date,
	last_updated_by,			last_update_login,
	created_by,				creation_date,
	source_type,				business_group_id,
        adj_set_number,                         line_number
	)
	SELECT
	PALA.adjustment_line_id,		PALA.person_id,
	PALA.assignment_id,			PALA.element_type_id,
	PALA.distribution_date,			PALA.effective_date,
	PALA.distribution_amount,		PALA.dr_cr_flag,
	PALA.payroll_control_id,		PALA.source_code,
	PALA.time_period_id,			PALA.batch_name,
	PALA.status_code,			PALA.set_of_books_id,
	PALA.gl_code_combination_id,		PALA.project_id,
	PALA.expenditure_organization_id,	PALA.expenditure_type,
	PALA.task_id,				PALA.award_id,
	PALA.suspense_org_account_id,		PALA.suspense_reason_code,
	PALA.include_in_er_flag,		PALA.effort_report_id,
	PALA.version_num,			PALA.summary_line_id,
	PALA.reversal_entry_flag,		PALA.original_line_flag,
	PALA.user_defined_field,		PALA.adjustment_batch_name,
	PALA.percent,				PALA.orig_source_type,
	PALA.orig_line_id,			PALA.attribute_category,
	PALA.attribute1,			PALA.attribute2,
	PALA.attribute3,			PALA.attribute4,
	PALA.attribute5,			PALA.attribute6,
	PALA.attribute7,			PALA.attribute8,
	PALA.attribute9,			PALA.attribute10,
	PALA.attribute11,			PALA.attribute12,
	PALA.attribute13,			PALA.attribute14,
	PALA.attribute15,			PALA.last_update_date,
	PALA.last_updated_by,			PALA.last_update_login,
	PALA.created_by,			PALA.creation_date,
	PALA.source_type,			PALA.business_group_id,
        PALA.adj_set_number,                    PALA.line_number
	FROM	PSP_ADJUSTMENT_LINES_ARCH PALA
	WHERE	PALA.time_period_id	=	  valid_period_rec.time_period_id ;

-- Insert data from archive table PSP_PRE_GEN_DIST_LINES_ARCH into PSP_PRE_GEN_LINES_HISTORY for the valid_period.
	INSERT INTO PSP_PRE_GEN_DIST_LINES_HISTORY
	(
	pre_gen_dist_line_id,		distribution_interface_id,
	person_id,			assignment_id,
	element_type_id,		distribution_date,
	effective_date,			distribution_amount,
	dr_cr_flag,			payroll_control_id,
	source_type,			source_code,
	time_period_id,			batch_name,
	status_code,			set_of_books_id,
	gl_code_combination_id,		project_id,
	expenditure_organization_id,	expenditure_type,
	task_id,			award_id,
	suspense_org_account_id,	suspense_reason_code,
	include_in_er_flag,		effort_report_id,
	version_num,			summary_line_id,
	reversal_entry_flag,		user_defined_field,
	adjustment_batch_name,		business_group_id,
	attribute_category,						-- Introduced DFF columns for bug fix 2908859
	attribute1,			attribute2,
	attribute3,			attribute4,
	attribute5,			attribute6,
	attribute7,			attribute8,
	attribute9,			attribute10,
        suspense_auto_glccid,           suspense_auto_exp_type
	)
	SELECT
	PGDLA.pre_gen_dist_line_id,		PGDLA.distribution_interface_id,
	PGDLA.person_id,			PGDLA.assignment_id,
	PGDLA.element_type_id,			PGDLA.distribution_date,
	PGDLA.effective_date,			PGDLA.distribution_amount,
	PGDLA.dr_cr_flag,			PGDLA.payroll_control_id,
	PGDLA.source_type,			PGDLA.source_code,
	PGDLA.time_period_id,			PGDLA.batch_name,
	PGDLA.status_code,			PGDLA.set_of_books_id,
	PGDLA.gl_code_combination_id,		PGDLA.project_id,
	PGDLA.expenditure_organization_id,	PGDLA.expenditure_type,
	PGDLA.task_id,				PGDLA.award_id,
	PGDLA.suspense_org_account_id,		PGDLA.suspense_reason_code,
	PGDLA.include_in_er_flag,		PGDLA.effort_report_id,
	PGDLA.version_num,			PGDLA.summary_line_id,
	PGDLA.reversal_entry_flag,		PGDLA.user_defined_field,
	PGDLA.adjustment_batch_name,		PGDLA.business_group_id,
	pgdla.attribute_category,					-- Introduced DFF columns for bug fix 2908859
	pgdla.attribute1,			pgdla.attribute2,
	pgdla.attribute3,			pgdla.attribute4,
	pgdla.attribute5,			pgdla.attribute6,
	pgdla.attribute7,			pgdla.attribute8,
	pgdla.attribute9,			pgdla.attribute10,
        pgdla.suspense_auto_glccid,             pgdla.suspense_auto_exp_type
	FROM	PSP_PRE_GEN_DIST_LINES_ARCH PGDLA
	WHERE	PGDLA.time_period_id	=	valid_period_rec.time_period_id ;

-- Insert data from archive table PSP_SUMMARY_LINES_ARCH into PSP_SUMMARY_LINES for the valid_period
	INSERT INTO PSP_SUMMARY_LINES
	(
	summary_line_id,		source_type,
	source_code,			time_period_id,
	interface_batch_name,		person_id,
	assignment_id,			effective_date,
        accounting_date,                exchange_rate_type,
	payroll_control_id,		gl_code_combination_id,
	project_id,			expenditure_organization_id,
	expenditure_type,		task_id,
	award_id,			summary_amount,
	dr_cr_flag,			group_id,
	interface_status,		attribute_category,
	attribute1,			attribute2,
	attribute3,			attribute4,
	attribute5,			attribute6,
	attribute7,			attribute8,
	attribute9,			attribute10,
	attribute11,			attribute12,
	attribute13,			attribute14,
	attribute15,			attribute16,
	attribute17,			attribute18,
	attribute19,			attribute20,
	attribute21,			attribute22,
	attribute23,			attribute24,
	attribute25,			attribute26,
	attribute27,			attribute28,
 	attribute29,			attribute30,
 	last_update_date,		last_updated_by,
 	last_update_login,		created_by,
 	creation_date,			set_of_books_id,
 	business_group_id,		status_code,
 	gms_batch_name,                 gms_posting_effective_date, /*posting eff-dt added for  zero work days */
        expenditure_id,                 expenditure_item_id,  -- added five exp columns for 2445196
        expenditure_ending_date,        interface_id,
        txn_interface_id,		actual_summary_amount --For Bug 2496661 : Added a new column
 	)
	SELECT
	PSLA.summary_line_id,		PSLA.source_type,
	PSLA.source_code,		PSLA.time_period_id,
	PSLA.interface_batch_name,	PSLA.person_id,
	PSLA.assignment_id,		PSLA.effective_date,
        PSLA.accounting_date,           PSLA.exchange_rate_type,
	PSLA.payroll_control_id,	PSLA.gl_code_combination_id,
	PSLA.project_id,		PSLA.expenditure_organization_id,
	PSLA.expenditure_type,		PSLA.task_id,
	PSLA.award_id,			PSLA.summary_amount,
	PSLA.dr_cr_flag,		PSLA.group_id,
	PSLA.interface_status,		PSLA.attribute_category,
	PSLA.attribute1,		PSLA.attribute2,
	PSLA.attribute3,		PSLA.attribute4,
	PSLA.attribute5,		PSLA.attribute6,
	PSLA.attribute7,		PSLA.attribute8,
	PSLA.attribute9,		PSLA.attribute10,
	PSLA.attribute11,		PSLA.attribute12,
	PSLA.attribute13,		PSLA.attribute14,
	PSLA.attribute15,		PSLA.attribute16,
	PSLA.attribute17,		PSLA.attribute18,
	PSLA.attribute19,		PSLA.attribute20,
	PSLA.attribute21,		PSLA.attribute22,
	PSLA.attribute23,		PSLA.attribute24,
	PSLA.attribute25,		PSLA.attribute26,
	PSLA.attribute27,		PSLA.attribute28,
 	PSLA.attribute29,		PSLA.attribute30,
 	PSLA.last_update_date,		PSLA.last_updated_by,
 	PSLA.last_update_login,		PSLA.created_by,
 	PSLA.creation_date,		PSLA.set_of_books_id,
 	PSLA.business_group_id,		PSLA.status_code,
 	PSLA.gms_batch_name,            PSLA.gms_posting_effective_date, /* column been added for zero work days */
        PSLA.expenditure_id,            PSLA.expenditure_item_id,  -- added five columns for 2445196
        PSLA.expenditure_ending_date,   PSLA.interface_id,
        PSLA.txn_interface_id,		PSLA.actual_summary_amount  --For Bug 2496661: Added new column
 	FROM	PSP_SUMMARY_LINES_ARCH PSLA
	WHERE	PSLA.time_period_id	= 	valid_period_rec.time_period_id;

-- Delete from the archive table PSP_DISTRIBUTION_LINES_ARCH for the valid_period
	DELETE	PSP_DISTRIBUTION_LINES_ARCH	PDLA
	WHERE	PDLA.summary_line_id	in
		(
		SELECT	PSLA.summary_line_id
		FROM	PSP_SUMMARY_LINES PSLA
		WHERE	PSLA.summary_line_id	=	PDLA.summary_line_id
		and	PSLA.time_period_id	=	valid_period_rec.time_period_id
		);

-- Delete from the archive table PSP_ADJUSTMENT_LINES_ARCH for the valid_period
	DELETE	PSP_ADJUSTMENT_LINES_ARCH PALA
	WHERE	PALA.time_period_id	=	valid_period_rec.time_period_id;

-- Delete from the archive table PSP_PRE_GEN_DIST_LINES_ARCH for the curr_period
	DELETE	PSP_PRE_GEN_DIST_LINES_ARCH	PPGDA
	WHERE	PPGDA.time_period_id	=	valid_period_rec.time_period_id;

-- Delete from the archive table PSP_SUMMARY_LINES_ARCH for the valid_period
-- Replaced PSP_SUMMARY_LINES table with PSP_SUMMARY_LINES_ARCH for bug fix 1761830
	DELETE	PSP_SUMMARY_LINES_ARCH	PSLA
	WHERE	PSLA.time_period_id	=	valid_period_rec.time_period_id;

-- Update the status of archive_flag in PSP_PAYROLL_CONTROLS to NULL
	UPDATE	PSP_PAYROLL_CONTROLS	PPC
	SET	PPC.archive_flag	= 	NULL
	WHERE	PPC.time_period_id	=	valid_period_rec.time_period_id;

	Commit;
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_LD_RETRIEVE_PERIOD');
		FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
		FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
		fnd_msg_pub.add;
	END LOOP;
	CLOSE valid_period_cur;

		l_status:='successful';
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
		FND_MESSAGE.SET_TOKEN('PROCESS_TYPE', l_process_type);
		FND_MESSAGE.SET_TOKEN('LINES_TYPE', l_lines_type);
		FND_MESSAGE.SET_TOKEN('STATUS', l_status);
             	fnd_msg_pub.add;
             	--psp_message_s.print_success;
		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_FALSE);
		retcode := 0;
EXCEPTION
	WHEN OTHERS THEN
		/* Following  Added for bug 2482603 */
		g_error_api_path := SUBSTR('RETRIEVE_DISTRIBUTION '||g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ARCHIVE_RETRIEVE',g_error_api_path);
		psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
						p_print_header	=>	FND_API.G_TRUE);
		retcode :=  2;
END retrieve_distribution;

/****************************************************************************************
	Created By	: spchakra

	Date Created By : 23-FEB-2001

	Purpose		: This procedure is to archive encumbrance history
		 	  for a given payroll name ,begin period and end period.s

	Know limitations, enhancements or remarks :

	Change History	:

****************************************************************************************/
PROCEDURE archive_encumbrance(  errbuf                 OUT NOCOPY	VARCHAR2,
                         	retcode                OUT NOCOPY	VARCHAR2,
                         	p_payroll_id           IN	NUMBER,
                         	p_begin_period         IN	NUMBER,
                         	p_end_period           IN	NUMBER,
                         	p_business_group_id    IN 	NUMBER,
                        	p_set_of_books_id      IN 	NUMBER)
IS
--	Cursor to select invalid time periods
	CURSOR	invalid_period_cur
	IS	Select	distinct period_name
		FROM	PSP_ENC_CONTROLS PEC,
			PER_TIME_PERIODS PTP
		WHERE	PEC.time_period_id	=	PTP.time_period_id
		AND	PEC.payroll_id		=	p_payroll_id
		AND	PEC.time_period_id	>=	p_begin_period
		AND	PEC.time_period_id	<=	p_end_period
		AND	PEC.archive_flag	is	NULL
		AND	PEC.time_period_id	in	(SELECT	time_period_id
							FROM	PSP_ENC_CONTROLS PEC2
							WHERE	PEC2.time_period_id	=	PEC.time_period_id
							AND	PEC2.action_code	<>	'L');

--	Cursor to select valid periods that can be archived
	CURSOR	valid_period_cur
	IS	SELECT	distinct PEC.time_period_id, PTP.period_name
		FROM	PSP_ENC_CONTROLS PEC,
			PER_TIME_PERIODS PTP
		WHERE	PTP.time_period_id	=	PEC.time_period_id
		AND	PEC.payroll_id		=	p_payroll_id
		AND	PEC.time_period_id	>=	p_begin_period
		AND	PEC.time_period_id	<=	p_end_period
		AND	PEC.archive_flag	is	NULL
		AND	PEC.business_group_id 	=	p_business_group_id
		AND	PEC. set_of_books_id 	=	p_set_of_books_id
		ORDER BY PEC.time_period_id;

--	Cursor to get payroll name, begin period name, end period name for displaying in the messages
	CURSOR	parameter_cur
	IS	SELECT 	distinct PPF.payroll_name, PTP1.period_name, PTP2.period_name
		FROM	PAY_PAYROLLS_F PPF,
			PER_TIME_PERIODS PTP1,
			PER_TIME_PERIODS PTP2
		WHERE 	PPF.payroll_id		=	p_payroll_id
		AND 	PTP1.payroll_id		=	p_payroll_id
		AND	PTP1.time_period_id	=	p_begin_period
		AND	PTP2.payroll_id		=	p_payroll_id
		AND	PTP2.time_period_id	=	p_end_period
		AND	PPF.business_group_id	=	p_business_group_id;

	l_status			VarChar2(80);
	l_payroll_name			VarChar2(80);
	l_begin_period			VarChar2(70);
	l_end_period			VarChar2(70);
	l_process_type			VarChar2(15)	:=	'Archive';
	l_lines_type			VarChar2(30)	:=	'Encumbrance Lines';
	l_period_name			VarChar2(70);

	l_time_period			Number(15);
	l_error_period_count		Number(15);

BEGIN

	fnd_msg_pub.initialize;

--	Retrieve the payroll name, begin , end period names for process initialization message
	Open parameter_cur;
	Fetch parameter_cur Into l_payroll_name, l_begin_period, l_end_period;
	Close parameter_cur;

--	Process Initialization Message
	FND_MESSAGE.SET_NAME('PSP','PSP_ARC_ARCHIVE_RETRIEVE_START');
	FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_process_type);
	FND_MESSAGE.SET_TOKEN('PAYROLL_NAME',l_payroll_name);
	FND_MESSAGE.SET_TOKEN('LINES_TYPE',l_lines_type);
	FND_MESSAGE.SET_TOKEN('BEGIN_PERIOD',l_begin_period);
	FND_MESSAGE.SET_TOKEN('END_PERIOD',l_end_period);
	fnd_msg_pub.add;

--	Check for Error time periods, If present log their corresponding messages
	Open invalid_period_cur;
	Fetch invalid_period_cur Into l_period_name;
	l_error_period_count	:=	invalid_period_cur%ROWCOUNT;

	If (l_error_period_count	>	0) Then
		Loop
--			Print the log message for the current period
			FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_EN_CANNOT_ARCHIVE');
			FND_MESSAGE.SET_TOKEN('PAYROLL_NAME',l_payroll_name);
			FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
			fnd_msg_pub.add;

			Fetch invalid_period_cur Into l_period_name;
			Exit When invalid_period_cur%NOTFOUND;
		End Loop;

		Close invalid_period_cur;

--		Set the status flag to 'Unsuccesful' for printing it on the log message
		l_status:='Unsuccessful';

--		Print the process end log message
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
		FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_process_type);
		FND_MESSAGE.SET_TOKEN('LINES_TYPE',l_lines_type);
		FND_MESSAGE.SET_TOKEN('STATUS',l_status);
		fnd_msg_pub.add;

--		Raise Unexpected Error exception to end the Procedure
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;

--	The valid period loop starts here
	Open valid_period_cur;
	Loop
		Fetch valid_period_cur Into l_time_period, l_period_name;
		Exit When valid_period_cur%NOTFOUND;

--		Insert data into ARCHIVE tables from HISTORY tables
--		Insert data Into PSP_ENC_LINES_ARCH from PSP_ENC_LINES_HISTORY for the current period
--		Added enc_start_date,enc_end_date for Enh. Bug# 2259310.
		INSERT	INTO PSP_ENC_LINES_ARCH
			(enc_line_id,			business_group_id,		enc_element_type_id,
			encumbrance_date,		enc_line_type,			schedule_line_id,
			org_schedule_id,		default_org_account_id,		suspense_org_account_id,
			element_account_id,		gl_project_flag,		enc_summary_line_id,
			person_id,			assignment_id,			award_id,
			task_id,			expenditure_type,		expenditure_organization_id,
			project_id,			gl_code_combination_id,		time_period_id,
			payroll_id,			set_of_books_id,		default_reason_code,
			suspense_reason_code,		status_code,			enc_control_id,
			dr_cr_flag,			last_update_date,		last_updated_by,
			last_update_login,		created_by,			creation_date,
			encumbrance_amount,		change_flag,			enc_start_date,
			enc_end_date,			attribute_category,		attribute1,
			attribute2,			attribute3,			attribute4,
			attribute5,			attribute6,			attribute7,
			attribute8,			attribute9,			attribute10,
			payroll_action_id,	orig_gl_code_combination_id,	orig_project_id,	orig_task_id,
			orig_award_id,		orig_expenditure_org_id,		orig_expenditure_type,	hierarchy_code,
			hierarchy_start_date,	hierarchy_end_date)
		SELECT	PELH.enc_line_id,		PELH.business_group_id,		PELH.enc_element_type_id,
			PELH.encumbrance_date,		PELH.enc_line_type,		PELH.schedule_line_id,
			PELH.org_schedule_id,		PELH.default_org_account_id,	PELH.suspense_org_account_id,
			PELH.element_account_id,	PELH.gl_project_flag,		PELH.enc_summary_line_id,
			PELH.person_id,			PELH.assignment_id,		PELH.award_id,
			PELH.task_id,			PELH.expenditure_type,		PELH.expenditure_organization_id,
			PELH.project_id,		PELH.gl_code_combination_id,	PELH.time_period_id,
			PELH.payroll_id,		PELH.set_of_books_id,		PELH.default_reason_code,
			PELH.suspense_reason_code,	PELH.status_code,		PELH.enc_control_id,
			PELH.dr_cr_flag,		PELH.last_update_date,		PELH.last_updated_by,
			PELH.last_update_login,		PELH.created_by,		PELH.creation_date,
			PELH.encumbrance_amount,	PELH.change_flag,		PELH.enc_start_date,
			PELH.enc_end_date,		pelh.attribute_category,	pelh.attribute1,
			pelh.attribute2,		pelh.attribute3,		pelh.attribute4,
			pelh.attribute5,		pelh.attribute6,		pelh.attribute7,
			pelh.attribute8,		pelh.attribute9,		pelh.attribute10,
			pelh.payroll_action_id,	pelh.orig_gl_code_combination_id,	pelh.orig_project_id,
			pelh.orig_task_id,	pelh.orig_award_id,	pelh.orig_expenditure_org_id,
			pelh.orig_expenditure_type,	pelh.hierarchy_code,
			pelh.hierarchy_start_date,	pelh.hierarchy_end_date
		FROM	PSP_ENC_LINES_HISTORY PELH
		WHERE	PELH.time_period_id	=	l_time_period;

--		Insert data Into PSP_ENC_SUMMARY_LINES_ARCH from PSP_ENC_SUMMARY_LINES for the current period
		INSERT	INTO PSP_ENC_SUMMARY_LINES_ARCH
			(enc_summary_line_id,		business_group_id,			gms_batch_name,
			time_period_id,			person_id,				assignment_id,
			effective_date,			set_of_books_id,			gl_code_combination_id,
			project_id,			expenditure_organization_id,		expenditure_type,
			task_id,			award_id,				summary_amount,
			dr_cr_flag,			group_id,				interface_status,
			payroll_id,			gl_period_id,				gl_project_flag,
			attribute_category,		attribute1,				attribute2,
			attribute3,			attribute4,				attribute5,
			attribute6,			attribute7,				attribute8,
			attribute9,			attribute10,				attribute11,
			attribute12,			attribute13,				attribute14,
			attribute15,			attribute16,				attribute17,
			attribute18,			attribute19,				attribute20,
			attribute21,			attribute22,				attribute23,
			attribute24,			attribute25,				attribute26,
			attribute27,			attribute28,				attribute29,
			attribute30,			reject_reason_code,			enc_control_id,
			status_code,			last_update_date,			last_updated_by,
			last_update_login,		created_by,				creation_date,
			suspense_org_account_id,	superceded_line_id,		gms_posting_override_date,
			gl_posting_override_date,
                        expenditure_id,                 expenditure_item_id,  -- added five exp columns for 2445196
                        expenditure_ending_date,        interface_id,
                        txn_interface_id, payroll_action_id,	liquidate_request_id,	proposed_termination_date,	update_flag)
		SELECT	PESL.enc_summary_line_id,	PESL.business_group_id,			PESL.gms_batch_name,
			PESL.time_period_id,		PESL.person_id,				PESL.assignment_id,
			PESL.effective_date,		PESL.set_of_books_id,			PESL.gl_code_combination_id,
			PESL.project_id,		PESL.expenditure_organization_id,	PESL.expenditure_type,
			PESL.task_id,			PESL.award_id,				PESL.summary_amount,
			PESL.dr_cr_flag,		PESL.group_id,				PESL.interface_status,
			PESL.payroll_id,		PESL.gl_period_id,			PESL.gl_project_flag,
			PESL.attribute_category,	PESL.attribute1,			PESL.attribute2,
			PESL.attribute3,		PESL.attribute4,			PESL.attribute5,
			PESL.attribute6,		PESL.attribute7,			PESL.attribute8,
			PESL.attribute9,		PESL.attribute10,			PESL.attribute11,
			PESL.attribute12,		PESL.attribute13,			PESL.attribute14,
			PESL.attribute15,		PESL.attribute16,			PESL.attribute17,
			PESL.attribute18,		PESL.attribute19,			PESL.attribute20,
			PESL.attribute21,		PESL.attribute22,			PESL.attribute23,
			PESL.attribute24,		PESL.attribute25,			PESL.attribute26,
			PESL.attribute27,		PESL.attribute28,			PESL.attribute29,
			PESL.attribute30,		PESL.reject_reason_code,		PESL.enc_control_id,
			PESL.status_code,		PESL.last_update_date,			PESL.last_updated_by,
			PESL.last_update_login,		PESL.created_by,			PESL.creation_date,
			PESL.suspense_org_account_id,	PESL.superceded_line_id,		PESL.gms_posting_override_date,
			PESL.gl_posting_override_date,
                        PESL.expenditure_id,            PESL.expenditure_item_id,  -- added five exp columns for 2445196
                        PESL.expenditure_ending_date,   PESL.interface_id,
                        PESL.txn_interface_id, payroll_action_id,	liquidate_request_id,	proposed_termination_date,	update_flag
		FROM	PSP_ENC_SUMMARY_LINES PESL
		WHERE	PESL.time_period_id	=	l_time_period;

--		Purge the archived data
--		Delete from PSP_ENC_LINES_HISTORY for the current period
		DELETE	PSP_ENC_LINES_HISTORY
		WHERE	time_period_id	=	l_time_period;

--		Delete from PSP_ENC_SUMMARY_LINES for the current period
		DELETE	PSP_ENC_SUMMARY_LINES
		WHERE	time_period_id	=	l_time_period;

--		Update the status of archive_flag in PSP_ENC_CONTROLS to 'Y'
		Update	PSP_ENC_CONTROLS
		Set	archive_flag	=	'Y'
		WHERE	time_period_id	=	l_time_period;

--		Commit the changes made for thecurrent period
		COMMIT;

--		Update the log with with current periods message
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_EN_ARCHIVE_PERIOD');
		FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
		FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
		fnd_msg_pub.add;

--	Continue with the next period
	End Loop;

--	Set the status flag to 'Successfull' as all the periods have been successfully archived
	l_status:='Successful';

--	Print the end of process message to the log
	FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
	FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_process_type);
	FND_MESSAGE.SET_TOKEN('LINES_TYPE',l_lines_type);
	FND_MESSAGE.SET_TOKEN('STATUS',l_status);
	fnd_msg_pub.add;

--	Write all the accumulated messages into the log
	psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
					p_print_header	=>	FND_API.G_FALSE);
	retcode	:=	0;

--Exception handling starts here
Exception
--	The following Exception occurs as part of user call for invalid time periods
	When	FND_API.G_EXC_UNEXPECTED_ERROR Then
--		Update the log with the messages accumulated so far
		/* Following added for bug 2482603 */
		g_error_api_path := SUBSTR('ARCHIVE_ENCUMBRANCE '||g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ARCHIVE_RETRIEVE',g_error_api_path);
		psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
						p_print_header	=>	FND_API.G_TRUE);
		retcode	:=	2;

--		For any other exception, ROLLBACK
	When	OTHERS Then
		/* Following added for bug 2482603 */
		g_error_api_path := SUBSTR('ARCHIVE_ENCUMBRANCE '||g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ARCHIVE_RETRIEVE',g_error_api_path);
		psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
						p_print_header	=>	FND_API.G_TRUE);
		retcode	:=	2;
End archive_encumbrance;

/****************************************************************************************
	Created By	: spchakra

	Date Created By : 02-MAR-2001

	Purpose		: This procedure is to retrieves into encumbrance history
		 	  for a given payroll name ,begin period and end period.s

	Know limitations, enhancements or remarks :

	Change History	:

****************************************************************************************/


PROCEDURE  retrieve_encumbrance(errbuf                OUT NOCOPY VARCHAR2,
                         retcode                      OUT NOCOPY VARCHAR2,
                         p_payroll_id                 IN  NUMBER,
                         p_begin_period               IN NUMBER,
                         p_end_period                 IN NUMBER,
                         p_business_group_id          IN NUMBER,
                         p_set_of_books_id            IN NUMBER)
IS
--	Cursor for selecting valid time periods
-- For bug fix 17770033, 1778727, changed the begin period to end period check as the functionality had changed
	CURSOR	valid_period_cur
	IS	SELECT	distinct PEC.time_period_id, PTP.period_name
		FROM	PSP_ENC_CONTROLS PEC,
			PER_TIME_PERIODS PTP
		WHERE	PTP.time_period_id	=	PEC.time_period_id
		AND	PEC.payroll_id		=	p_payroll_id
		AND	PEC.time_period_id	>=	p_begin_period
		AND	PEC.time_period_id	<=	p_end_period
		AND	PEC.archive_flag	=	'Y'
		AND	PEC.business_group_id 	=	p_business_group_id
		AND	PEC. set_of_books_id 	=	p_set_of_books_id
		ORDER BY PEC.time_period_id;

--	Cursor to get payroll name, begin period name, end period name for displaying in the messages
	CURSOR	parameter_cur
	IS	SELECT 	distinct PPF.payroll_name, PTP1.period_name, PTP2.period_name
		FROM	PAY_PAYROLLS_F PPF,
			PER_TIME_PERIODS PTP1,
			PER_TIME_PERIODS PTP2
		WHERE 	PPF.payroll_id		=	p_payroll_id
		AND 	PTP1.payroll_id		=	p_payroll_id
		AND	PTP1.time_period_id	=	p_begin_period
		AND	PTP2.payroll_id		=	p_payroll_id
		AND	PTP2.time_period_id	=	p_end_period
		AND	PPF.business_group_id	=	p_business_group_id;

	l_status			VarChar2(80);
	l_payroll_name			VarChar2(80);
	l_begin_period			VarChar2(70);
	l_end_period			VarChar2(70);
	l_process_type			VarChar2(15)	:=	'Retrieve';
	l_lines_type			VarChar2(30)	:=	'Encumbrance Lines';
	l_period_name			VarChar2(70);

	l_time_period			Number(15);
	l_error_period_count		Number(15);

BEGIN
	fnd_msg_pub.initialize;

--	Retrieve the payroll name, begin , end period names for process initialization message
	Open parameter_cur;
	Fetch parameter_cur Into l_payroll_name, l_begin_period, l_end_period;
	Close parameter_cur;

--	Process Initialization Message
	FND_MESSAGE.SET_NAME('PSP','PSP_ARC_ARCHIVE_RETRIEVE_START');
	FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_process_type);
	FND_MESSAGE.SET_TOKEN('PAYROLL_NAME',l_payroll_name);
	FND_MESSAGE.SET_TOKEN('LINES_TYPE',l_lines_type);
	FND_MESSAGE.SET_TOKEN('BEGIN_PERIOD',l_begin_period);
	FND_MESSAGE.SET_TOKEN('END_PERIOD',l_end_period);
	fnd_msg_pub.add;

--	The valid period loop starts here
	Open valid_period_cur;
	Loop
		Fetch valid_period_cur Into l_time_period, l_period_name;
		Exit When valid_period_cur%NOTFOUND;

--		Insert data into ARCHIVE tables from HISTORY tables
--		Insert data Into PSP_ENC_LINES_HISTORY from PSP_ENC_LINES_ARCH for the current period
--		Added enc_start_date,enc_end_date for Enh. Enc Redesign - Prorata.Bug # 2259310.
		INSERT	INTO PSP_ENC_LINES_HISTORY
			(enc_line_id,			business_group_id,		enc_element_type_id,
			encumbrance_date,		enc_line_type,			schedule_line_id,
			org_schedule_id,		default_org_account_id,		suspense_org_account_id,
			element_account_id,		gl_project_flag,		enc_summary_line_id,
			person_id,			assignment_id,			award_id,
			task_id,			expenditure_type,		expenditure_organization_id,
			project_id,			gl_code_combination_id,		time_period_id,
			payroll_id,			set_of_books_id,		default_reason_code,
			suspense_reason_code,		status_code,			enc_control_id,
			last_update_date,		last_updated_by,		last_update_login,
			created_by,			creation_date,			dr_cr_flag,
			encumbrance_amount,		change_flag,			enc_start_date,
			enc_end_date,			attribute_category,		attribute1,
			attribute2,			attribute3,			attribute4,
			attribute5,			attribute6,			attribute7,
			attribute8,			attribute9,			attribute10,
			payroll_action_id,	orig_gl_code_combination_id,	orig_project_id,	orig_task_id,
			orig_award_id,		orig_expenditure_org_id,		orig_expenditure_type,	hierarchy_code,
			hierarchy_start_date,	hierarchy_end_date)
		SELECT	PELA.enc_line_id,		PELA.business_group_id,		PELA.enc_element_type_id,
			PELA.encumbrance_date,		PELA.enc_line_type,		PELA.schedule_line_id,
			PELA.org_schedule_id,		PELA.default_org_account_id,	PELA.suspense_org_account_id,
			PELA.element_account_id,	PELA.gl_project_flag,		PELA.enc_summary_line_id,
			PELA.person_id,			PELA.assignment_id,		PELA.award_id,
			PELA.task_id,			PELA.expenditure_type,		PELA.expenditure_organization_id,
			PELA.project_id,		PELA.gl_code_combination_id,	PELA.time_period_id,
			PELA.payroll_id,		PELA.set_of_books_id,		PELA.default_reason_code,
			PELA.suspense_reason_code,	PELA.status_code,		PELA.enc_control_id,
			PELA.last_update_date,		PELA.last_updated_by,		PELA.last_update_login,
			PELA.created_by,		PELA.creation_date,		PELA.dr_cr_flag,
			PELA.encumbrance_amount,	PELA.change_flag,		PELA.enc_start_date,
			PELA.enc_end_date,		pela.attribute_category,	pela.attribute1,
			pela.attribute2,		pela.attribute3,		pela.attribute4,
			pela.attribute5,		pela.attribute6,		pela.attribute7,
			pela.attribute8,		pela.attribute9,		pela.attribute10,
			pela.payroll_action_id,	pela.orig_gl_code_combination_id,	pela.orig_project_id,
			pela.orig_task_id,	pela.orig_award_id,	pela.orig_expenditure_org_id,
			pela.orig_expenditure_type,	pela.hierarchy_code,
			pela.hierarchy_start_date,	pela.hierarchy_end_date
		FROM	PSP_ENC_LINES_ARCH PELA
		WHERE	PELA.time_period_id	=	l_time_period;

--		Insert data Into PSP_ENC_SUMMARY_LINES from PSP_ENC_SUMMARY_LINES_ARCH for the current period
		INSERT	INTO PSP_ENC_SUMMARY_LINES
			(enc_summary_line_id,		business_group_id,			gms_batch_name,
			time_period_id,			person_id,				assignment_id,
			effective_date,			set_of_books_id,			gl_code_combination_id,
			project_id,			expenditure_organization_id,		expenditure_type,
			task_id,			award_id,				summary_amount,
			dr_cr_flag,			group_id,				interface_status,
			payroll_id,			gl_period_id,				gl_project_flag,
			attribute_category,		attribute1,				attribute2,
			attribute3,			attribute4,				attribute5,
			attribute6,			attribute7,				attribute8,
			attribute9,			attribute10,				attribute11,
			attribute12,			attribute13,				attribute14,
			attribute15,			attribute16,				attribute17,
			attribute18,			attribute19,				attribute20,
			attribute21,			attribute22,				attribute23,
			attribute24,			attribute25,				attribute26,
			attribute27,			attribute28,				attribute29,
			attribute30,			reject_reason_code,			enc_control_id,
			status_code,			last_update_date,			last_updated_by,
			last_update_login,		created_by,				creation_date,
			suspense_org_account_id,	superceded_line_id,			gms_posting_override_date,
			gl_posting_override_date,
                        expenditure_id,                 expenditure_item_id,  -- added five exp columns for 2445196
                        expenditure_ending_date,        interface_id,
                        txn_interface_id,
                        payroll_action_id,	liquidate_request_id,	proposed_termination_date,	update_flag)
		SELECT	PESLA.enc_summary_line_id,	PESLA.business_group_id,		PESLA.gms_batch_name,
			PESLA.time_period_id,		PESLA.person_id,			PESLA.assignment_id,
			PESLA.effective_date,		PESLA.set_of_books_id,		PESLA.gl_code_combination_id,
			PESLA.project_id,		PESLA.expenditure_organization_id,	PESLA.expenditure_type,
			PESLA.task_id,			PESLA.award_id,				PESLA.summary_amount,
			PESLA.dr_cr_flag,		PESLA.group_id,				PESLA.interface_status,
			PESLA.payroll_id,		PESLA.gl_period_id,			PESLA.gl_project_flag,
			PESLA.attribute_category,	PESLA.attribute1,			PESLA.attribute2,
			PESLA.attribute3,		PESLA.attribute4,			PESLA.attribute5,
			PESLA.attribute6,		PESLA.attribute7,			PESLA.attribute8,
			PESLA.attribute9,		PESLA.attribute10,			PESLA.attribute11,
			PESLA.attribute12,		PESLA.attribute13,			PESLA.attribute14,
			PESLA.attribute15,		PESLA.attribute16,			PESLA.attribute17,
			PESLA.attribute18,		PESLA.attribute19,			PESLA.attribute20,
			PESLA.attribute21,		PESLA.attribute22,			PESLA.attribute23,
			PESLA.attribute24,		PESLA.attribute25,			PESLA.attribute26,
			PESLA.attribute27,		PESLA.attribute28,			PESLA.attribute29,
			PESLA.attribute30,		PESLA.reject_reason_code,		PESLA.enc_control_id,
			PESLA.status_code,		PESLA.last_update_date,			PESLA.last_updated_by,
			PESLA.last_update_login,	PESLA.created_by,			PESLA.creation_date,
			PESLA.suspense_org_account_id,	PESLA.superceded_line_id,		PESLA.gms_posting_override_date,
			PESLA.gl_posting_override_date,
                        PESLA.expenditure_id,           PESLA.expenditure_item_id, --added five exp columns for 2445196
                        PESLA.expenditure_ending_date,  PESLA.interface_id,
                        PESLA.txn_interface_id, payroll_action_id,	liquidate_request_id,	proposed_termination_date,	update_flag

		FROM	PSP_ENC_SUMMARY_LINES_ARCH PESLA
		WHERE	PESLA.time_period_id	=	l_time_period;

--		Purge the archived data
--		Delete from PSP_ENC_LINES_ARCH for the current period
		DELETE	PSP_ENC_LINES_ARCH
		WHERE	time_period_id	=	l_time_period;

--		Delete from PSP_ENC_SUMMARY_LINES_ARCH for the current period
		DELETE	PSP_ENC_SUMMARY_LINES_ARCH
		WHERE	time_period_id	=	l_time_period;

--		Update the status of archive_flag in PSP_ENC_CONTROLS to NULL
		Update	PSP_ENC_CONTROLS
		Set	archive_flag	=	NULL
		WHERE	time_period_id	=	l_time_period;

--		Commit the changes made for thecurrent period
		COMMIT;

--		Update the log with with current periods message
--		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_EN_ARCHIVE_PERIOD');  --For Bug 2783253
		FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_EN_RETRIEVE_PERIOD');  --For Bug 2783253
		FND_MESSAGE.SET_TOKEN('PAYROLL_NAME', l_payroll_name);
		FND_MESSAGE.SET_TOKEN('TIME_PERIOD', l_period_name);
		fnd_msg_pub.add;

--	Continue with the next period
	End Loop;

--	Set the status flag to 'Successfull' as all the periods have been successfully archived
	l_status:='Successful';

--	Print the end of process message to the log
	FND_MESSAGE.SET_NAME('PSP', 'PSP_ARC_ARCHIVE_RETRIEVE_END');
	FND_MESSAGE.SET_TOKEN('PROCESS_TYPE',l_process_type);
	FND_MESSAGE.SET_TOKEN('LINES_TYPE',l_lines_type);
	FND_MESSAGE.SET_TOKEN('STATUS',l_status);
	fnd_msg_pub.add;

--	Write all messages into Log
	psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
					p_print_header	=>	FND_API.G_FALSE);
	retcode	:=	0;

--Exception handling starts here
Exception
--	For any other kind of Exception, ROLLBACK
	When OTHERS Then
		/* Folllowing is added for bug 2482603 */
		g_error_api_path := SUBSTR('RETRIEVE_ENCUMBRANCE '||g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ARCHIVE_RETRIEVE',g_error_api_path);
		psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
						p_print_header	=>	FND_API.G_TRUE);
		retcode	:=	2;
End retrieve_encumbrance;

END PSP_ARCHIVE_RETRIEVE;

/
