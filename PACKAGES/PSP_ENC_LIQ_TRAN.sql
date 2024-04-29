--------------------------------------------------------
--  DDL for Package PSP_ENC_LIQ_TRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_LIQ_TRAN" AUTHID CURRENT_USER AS
/* $Header: PSPENLQS.pls 120.2.12000000.1 2007/01/18 12:09:40 appldev noship $  */
g_run_id		NUMBER(10);
g_error_api_path	VARCHAR2(500) := '';

--PROCEDURE enc_liq_trans(	errbuf	OUT NOCOPY VARCHAR2,
--				retcode	OUT NOCOPY VARCHAR2,
PROCEDURE enc_liq_trans(	p_payroll_action_id IN NUMBER,
--				p_payroll_id IN NUMBER,
--				p_action_type IN VARCHAR2,
				p_business_group_id IN NUMBER,
				p_set_of_books_id IN NUMBER,
				p_return_status	OUT NOCOPY VARCHAR2
				);

PROCEDURE enc_batch_begin(p_payroll_action_id IN NUMBER,
--				p_payroll_id IN NUMBER,
--				p_action_type IN VARCHAR2,
				p_return_status	OUT NOCOPY VARCHAR2
				);

PROCEDURE enc_batch_end(	p_payroll_action_id IN NUMBER,
--                        		p_payroll_id IN NUMBER,
--                                p_action_type IN VARCHAR2,
--                                p_mode in varchar2,     ---Bug 2039196: three new params
                                p_business_group_id in number,
                                p_set_of_books_id in number,
				p_return_status	OUT NOCOPY VARCHAR2
				);

PROCEDURE create_gl_enc_liq_lines(p_payroll_id IN NUMBER,
                                  p_action_type IN VARCHAR2,
				p_return_status	OUT NOCOPY VARCHAR2
				);
/*****	Commented for bug fix 4625734
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
                                p_suspense_org_account_id IN NUMBER,
                                p_superceded_line_id        IN NUMBER,
                                p_gms_posting_override_date IN DATE,
                                p_gl_posting_override_date  IN DATE,
				p_attribute_category	IN	VARCHAR2,	-- Introduced DFF columns for bug fix 2908859
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
				p_expenditure_item_id	IN	NUMBER,		-- Introduced for bug fix 4068182
				p_return_status		OUT NOCOPY  VARCHAR2
				);
	End of comment for bug fix 4625734	*****/

PROCEDURE tr_to_gl_int(		p_payroll_action_id IN NUMBER,
--				p_payroll_id IN NUMBER,
--				p_action_type		IN  VARCHAR2, -- Added for Restart Update Enh.
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
				p_enc_control_id	IN  NUMBER,
				p_period_end_date	IN  DATE,
				p_group_id		IN  NUMBER,
				p_business_group_id	IN  NUMBER,
				p_set_of_books_id	IN  NUMBER,
                                p_mode                  in  varchar2,    ---Bug 2039196
                                p_action_type		IN  VARCHAR2,    -- Added for Restart Update Enh.
				p_return_status		OUT NOCOPY  VARCHAR2
				);
/*****	Commented for bug fix 4625734
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
	End of comment for bug fix 4625734	*****/

PROCEDURE create_gms_enc_liq_lines(p_payroll_id IN NUMBER,
                                 p_action_type IN VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				);

PROCEDURE tr_to_gms_int(	p_payroll_action_id IN NUMBER,
--				p_payroll_id IN NUMBER,
--				p_action_type		IN  VARCHAR2, -- Added for Restart Update Enh.
				p_return_status		OUT NOCOPY  VARCHAR2
				);

PROCEDURE gms_enc_tie_back(
				p_enc_control_id	IN  NUMBER,
				p_period_end_date	IN  DATE,
				p_gms_batch_name	IN  VARCHAR2,
				p_business_group_id	IN  NUMBER,
				p_set_of_books_id	IN  NUMBER,
                                p_mode                  in  varchar2,   ---Bug 2039196
                                p_action_type		IN  VARCHAR2, -- Added for Restart Update Enh.
				p_return_status		OUT NOCOPY  VARCHAR2
				);

/* Commented the below procedure as part of "zero work days" enhancement */

/* PROCEDURE get_effective_date(p_person_id in number,
                             p_effective_date in out NOCOPY date
                             ); */

/****	Commented for bug fix 4625734
PROCEDURE insert_into_pa_int(
				p_txn_interface_id		IN  NUMBER,
				p_transaction_source		IN  VARCHAR2,
				p_batch_name			IN  VARCHAR2,
				p_expenditure_ending_date	IN  DATE,
				p_employee_number		IN  VARCHAR2,
				p_organization_name		IN  VARCHAR2,
				p_expenditure_item_date		IN  DATE,
				p_project_number		IN  VARCHAR2,
				p_task_number			IN  VARCHAR2,
				p_expenditure_type		IN  VARCHAR2,
				p_quantity			IN  NUMBER,
				p_raw_cost			IN  NUMBER,
				p_expenditure_comment		IN  VARCHAR2,
				p_transaction_status_code	IN  VARCHAR2,
				p_orig_transaction_reference	IN  VARCHAR2,
				p_org_id			IN  NUMBER,
				p_denom_currency_code		IN  VARCHAR2,
				p_denom_raw_cost		IN  NUMBER,
				p_attribute1			IN  VARCHAR2,
				p_attribute2			IN  VARCHAR2,
				p_attribute3			IN  VARCHAR2,
				p_attribute6			IN  VARCHAR2,
				p_attribute7			IN  VARCHAR2,
				p_attribute8			IN  VARCHAR2,
				p_attribute9			IN  VARCHAR2,
				p_attribute10			IN  VARCHAR2,
				p_person_business_group_id	IN  NUMBER,
				p_return_status		OUT NOCOPY  VARCHAR2
				);
	End of comment for bug fix 4625734	*****/

/*
PROCEDURE insert_into_psp_stout(
        P_MSG                   IN      VARCHAR2);
*/

--	Introduced move_qkupd_rec_to_hist for Quick Update Enc. enh. 2143723
/* Commented for Restart Update/Quick Update Encumbrance Lines Enh.
PROCEDURE	move_qkupd_rec_to_hist
			(p_payroll_id		IN      NUMBER,
			p_action_type		IN      VARCHAR2,
			p_business_group_id	IN      NUMBER,
			p_set_of_books_id	IN      NUMBER,
			p_return_status		OUT NOCOPY     VARCHAR2);
*/
/*****	Commented for Create and Update multi thread enh.
--- introduced for 3413373
PROCEDURE LIQUIDATE_EMP_TERM(errbuf  OUT NOCOPY VARCHAR2,
                             retcode OUT NOCOPY VARCHAR2,
                             p_business_group_id in number,
                             p_set_of_books_id   in number,
                             p_person_id         in number,
                             p_actual_term_date  in date);
	End of comment for Create and Update multi thread enh.	*****/


END psp_enc_liq_tran;

 

/
