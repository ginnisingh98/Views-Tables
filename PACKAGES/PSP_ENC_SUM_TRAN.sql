--------------------------------------------------------
--  DDL for Package PSP_ENC_SUM_TRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_SUM_TRAN" AUTHID CURRENT_USER AS
/* $Header: PSPENSTS.pls 120.3 2006/07/13 07:40:41 spchakra noship $ */

g_run_id		NUMBER(10);
--g_error_api_path	VARCHAR2(500) := '';
g_error_api_path	VARCHAR2(2000) := ''; --Added for bug 1776606
g_business_group_id	NUMBER;
g_set_of_books_id	NUMBER;

PROCEDURE enc_sum_trans(
				errbuf	OUT NOCOPY VARCHAR2,
				retcode	OUT NOCOPY VARCHAR2,
				p_payroll_action_id IN NUMBER,
				p_business_group_id IN NUMBER,
				p_set_of_books_id IN NUMBER
				);

PROCEDURE enc_batch_begin(	p_payroll_action_id IN NUMBER,
				p_return_status	OUT NOCOPY VARCHAR2
				);

PROCEDURE enc_batch_end(	p_payroll_action_id IN NUMBER,
				p_return_status	OUT NOCOPY VARCHAR2
				);

--PROCEDURE create_gl_enc_sum_lines(p_payroll_id IN NUMBER,
--				p_return_status	OUT NOCOPY VARCHAR2
--				);

PROCEDURE insert_into_enc_sum_lines(
				p_enc_summary_line_id	OUT NOCOPY NUMBER,
				p_business_group_id	IN  NUMBER,
				p_enc_control_id	IN  NUMBER,
				p_time_period_id	IN  NUMBER,
				p_person_id		IN  NUMBER,
				p_assignment_id		IN  NUMBER,
				p_effective_date	IN  DATE,
				p_set_of_books_id	IN  NUMBER,
				p_gl_code_combination_id IN  NUMBER,
				p_project_id		IN  NUMBER,
				p_expenditure_organization_id IN  NUMBER,
				p_expenditure_type	IN  VARCHAR2,
				p_task_id		IN  NUMBER,
				p_award_id		IN  NUMBER,
				p_summary_amount	IN  NUMBER,
				p_dr_cr_flag		IN  VARCHAR2,
				p_status_code		IN  VARCHAR2,
				p_payroll_id		IN  NUMBER,
				p_gl_period_id		IN  NUMBER,
				p_gl_project_flag	IN  VARCHAR2,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

PROCEDURE tr_to_gl_int(		p_payroll_action_id IN NUMBER,
				p_return_status	OUT NOCOPY  VARCHAR2
				);


PROCEDURE gl_je_source(
				p_user_je_source_name	OUT NOCOPY  VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

PROCEDURE gl_je_cat(
				p_user_je_category_name	OUT NOCOPY  VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

PROCEDURE enc_type(
				p_encumbrance_type_id	OUT NOCOPY  VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

PROCEDURE gl_enc_tie_back(
--				p_enc_control_id	IN  NUMBER,
--				p_period_end_date	IN  DATE,
				p_payroll_action_id	IN  NUMBER,
				p_group_id		IN  NUMBER,
                		p_business_group_id 	IN  NUMBER,
                		p_set_of_books_id   	IN  NUMBER,
                                p_mode                  IN  VARCHAR2,--Added for bug 1776606.
				p_return_status		OUT NOCOPY VARCHAR2
				);

PROCEDURE insert_into_gl_int  (
				p_set_of_books_id	IN  NUMBER,
				p_accounting_date	IN  DATE,
				p_currency_code		IN  VARCHAR2,
				p_user_je_category_name	IN  VARCHAR2,
				p_user_je_source_name	IN  VARCHAR2,
				p_encumbrance_type_id	IN  NUMBER,
				p_code_combination_id	IN  NUMBER,
				p_entered_dr		IN  NUMBER,
				p_entered_cr		IN  NUMBER,
				p_group_id		IN  NUMBER,
				p_reference1		IN  VARCHAR2,
				p_reference2		IN  VARCHAR2,
				p_reference4		IN  VARCHAR2,
				p_reference6		IN  VARCHAR2,
				p_reference10		IN  VARCHAR2,
				p_attribute1		IN  VARCHAR2,
				p_attribute2		IN  VARCHAR2,
				p_attribute3		IN  VARCHAR2,
				p_attribute4		IN  VARCHAR2,
				p_attribute5		IN  VARCHAR2,
				p_attribute6		IN  VARCHAR2,
				p_attribute7		IN  VARCHAR2,
				p_attribute8		IN  VARCHAR2,
				p_attribute9		IN  VARCHAR2,
				p_attribute10		IN  VARCHAR2,
				p_attribute11		IN  VARCHAR2,
				p_attribute12		IN  VARCHAR2,
				p_attribute13		IN  VARCHAR2,
				p_attribute14		IN  VARCHAR2,
				p_attribute15		IN  VARCHAR2,
				p_attribute16		IN  VARCHAR2,
				p_attribute17		IN  VARCHAR2,
				p_attribute18		IN  VARCHAR2,
				p_attribute19		IN  VARCHAR2,
				p_attribute20		IN  VARCHAR2,
				p_attribute21		IN  VARCHAR2,
				p_attribute22		IN  VARCHAR2,
				p_attribute23		IN  VARCHAR2,
				p_attribute24		IN  VARCHAR2,
				p_attribute25		IN  VARCHAR2,
				p_attribute26		IN  VARCHAR2,
				p_attribute27		IN  VARCHAR2,
				p_attribute28		IN  VARCHAR2,
				p_attribute29		IN  VARCHAR2,
				p_attribute30		IN  VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

--PROCEDURE create_gms_enc_sum_lines(p_payroll_id IN NUMBER,
--				p_return_status		OUT NOCOPY  VARCHAR2
--				);

PROCEDURE tr_to_gms_int(	p_payroll_action_id IN NUMBER,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

/*PROCEDURE gms_enc_tie_back(
				p_enc_control_id	IN  NUMBER,
				p_period_end_date	IN  DATE,
				p_gms_batch_name	IN  VARCHAR2,
				p_business_group_id	IN  NUMBER,
				p_set_of_books_id	IN  NUMBER,
        		p_mode                  IN  VARCHAR2, --Added for bug 1776606
				p_return_status		OUT NOCOPY  VARCHAR2
				);*/
PROCEDURE gms_enc_tie_back(	p_payroll_action_id	IN		NUMBER,
				p_gms_batch_name	IN		VARCHAR2,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2);

END psp_enc_sum_tran;

 

/
