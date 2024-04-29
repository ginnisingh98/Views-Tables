--------------------------------------------------------
--  DDL for Package PSP_SUM_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SUM_TRANS" AUTHID CURRENT_USER as
/* $Header: PSPTRSTS.pls 120.1.12010000.2 2008/08/05 10:15:00 ubhat ship $ */
 g_run_id		NUMBER(10);
-- Extending the length of this variable from 500 to 2000 as part of bug fix 1776606
 g_error_api_path	VARCHAR2(2000) := '';

 PROCEDURE sum_and_transfer(errbuf	         OUT NOCOPY VARCHAR2,
                            retcode	         OUT NOCOPY VARCHAR2,
                            p_source_type     IN VARCHAR2,
                            p_source_code     IN VARCHAR2,
			    p_payroll_id      IN NUMBER,
                            p_time_period_id  IN NUMBER,
                            p_batch_name      IN VARCHAR2,
			    p_business_group_id IN NUMBER,
			    p_set_of_books_id   IN NUMBER);

 PROCEDURE mark_batch_begin(p_source_type     IN VARCHAR2,
                            p_source_code     IN VARCHAR2,
                            p_payroll_id      IN NUMBER,
                            p_time_period_id  IN NUMBER,
                            p_batch_name      IN VARCHAR2,
			    p_business_group_id IN NUMBER,
			    p_set_of_books_id   IN NUMBER,
                            p_return_status  OUT NOCOPY VARCHAR2);


 PROCEDURE mark_batch_end(p_source_type     IN VARCHAR2,
                          p_source_code     IN VARCHAR2,
                          p_time_period_id  IN NUMBER,
                          p_batch_name      IN VARCHAR2,
			  p_business_group_id IN NUMBER,
			  p_set_of_books_id   IN NUMBER,
                          p_return_status  OUT NOCOPY VARCHAR2);


 PROCEDURE create_gl_sum_lines(p_source_type     IN VARCHAR2,
                               p_source_code     IN VARCHAR2,
                               p_time_period_id  IN NUMBER,
                               p_batch_name      IN VARCHAR2,
			       p_business_group_id IN NUMBER,
			       p_set_of_books_id   IN NUMBER,
                               p_return_status  OUT NOCOPY VARCHAR2);


 PROCEDURE insert_into_summary_lines(
		P_SUMMARY_LINE_ID		OUT NOCOPY	NUMBER,
		P_PERSON_ID			IN	NUMBER,
		P_ASSIGNMENT_ID			IN	NUMBER,
		P_TIME_PERIOD_ID		IN	NUMBER,
 		P_EFFECTIVE_DATE		IN	DATE,
                P_ACCOUNTING_DATE               IN      DATE,
                P_EXCHANGE_RATE_TYPE            IN      VARCHAR2,
            	P_SOURCE_TYPE			IN	VARCHAR2,
 		P_SOURCE_CODE			IN	VARCHAR2,
		P_SET_OF_BOOKS_ID		IN	NUMBER,
 		P_GL_CODE_COMBINATION_ID	IN	NUMBER,
 		P_PROJECT_ID			IN	NUMBER,
 		P_EXPENDITURE_ORGANIZATION_ID	IN	NUMBER,
 		P_EXPENDITURE_TYPE		IN	VARCHAR2,
 		P_TASK_ID			IN	NUMBER,
 		P_AWARD_ID			IN	NUMBER,
 		P_SUMMARY_AMOUNT		IN	NUMBER,
 		P_DR_CR_FLAG			IN	VARCHAR2,
 		P_STATUS_CODE			IN	VARCHAR2,
            	P_INTERFACE_BATCH_NAME		IN	VARCHAR2,
		P_PAYROLL_CONTROL_ID		IN	NUMBER,
	    	p_business_group_id 		IN NUMBER,
		p_attribute_category		IN	VARCHAR2,		-- Introduced DFF columns for bug fix 2908859
		p_attribute1			IN	VARCHAR2,
		p_attribute2			IN	VARCHAR2,
		p_attribute3			IN	VARCHAR2,
		p_attribute4			IN	VARCHAR2,
		p_attribute5			IN	VARCHAR2,
		p_attribute6			IN	VARCHAR2,
		p_attribute7			IN	VARCHAR2,
		p_attribute8			IN	VARCHAR2,
		p_attribute9			IN	VARCHAR2,
		p_attribute10			IN	VARCHAR2,
            	P_RETURN_STATUS			OUT NOCOPY   VARCHAR2,
		p_org_id			IN  NUMBER DEFAULT NULL     -- R12 MOAC Uptake
);


 PROCEDURE transfer_to_gl_interface(p_source_type     IN VARCHAR2,
                                    p_source_code     IN VARCHAR2,
                                    p_time_period_id  IN NUMBER,
                                    p_batch_name      IN VARCHAR2,
			    	    p_business_group_id IN NUMBER,
			    	    p_set_of_books_id   IN NUMBER,
                                    p_return_status  OUT NOCOPY VARCHAR2);


 PROCEDURE get_gl_je_sources(P_USER_JE_SOURCE_NAME  OUT NOCOPY  VARCHAR2,
                             P_RETURN_STATUS        OUT NOCOPY  VARCHAR2);


 PROCEDURE get_gl_je_categories(P_USER_JE_CATEGORY_NAME  OUT NOCOPY  VARCHAR2,
                                P_RETURN_STATUS          OUT NOCOPY  VARCHAR2);

 PROCEDURE get_encum_type_id(P_ENCUMBRANCE_TYPE_ID  OUT NOCOPY  VARCHAR2,
                             P_RETURN_STATUS        OUT NOCOPY  VARCHAR2);


 PROCEDURE gl_tie_back(p_payroll_control_id IN	NUMBER,
                       p_source_type        IN  VARCHAR2,
                       p_period_end_date    IN  DATE,
                       p_group_id           IN	NUMBER,
		       p_business_group_id  IN NUMBER,
		       p_set_of_books_id    IN NUMBER,
		       p_mode		    IN	VARCHAR2,
                       p_return_status	 OUT NOCOPY	VARCHAR2);


 PROCEDURE gl_balance_transaction(
			P_SOURCE_TYPE 		IN	VARCHAR2,
			P_PAYROLL_CONTROL_ID	IN	NUMBER,
		        p_business_group_id IN NUMBER,
			p_set_of_books_id   IN NUMBER,
			P_PRECISION	IN	NUMBER,
                  	P_RETURN_STATUS        OUT NOCOPY    VARCHAR2);

 PROCEDURE insert_into_gl_interface(
			P_SET_OF_BOOKS_ID 		IN	NUMBER,
			P_ACCOUNTING_DATE			IN	DATE,
			P_CURRENCY_CODE			IN	VARCHAR2,
			P_USER_JE_CATEGORY_NAME		IN	VARCHAR2,
			P_USER_JE_SOURCE_NAME		IN	VARCHAR2,
			P_ENCUMBRANCE_TYPE_ID		IN	NUMBER,
			P_CODE_COMBINATION_ID		IN	NUMBER,
			P_ENTERED_DR			IN	NUMBER,
			P_ENTERED_CR			IN	NUMBER,
			P_GROUP_ID			IN	NUMBER,
			P_REFERENCE1			IN	VARCHAR2,
			P_REFERENCE2			IN	VARCHAR2,
			P_REFERENCE4			IN	VARCHAR2,
			P_REFERENCE6			IN	VARCHAR2,
			P_REFERENCE10			IN	VARCHAR2,
			P_ATTRIBUTE1			IN	VARCHAR2,
			P_ATTRIBUTE2			IN	VARCHAR2,
			P_ATTRIBUTE3			IN	VARCHAR2,
			P_ATTRIBUTE4			IN	VARCHAR2,
			P_ATTRIBUTE5			IN	VARCHAR2,
			P_ATTRIBUTE6			IN	VARCHAR2,
			P_ATTRIBUTE7			IN	VARCHAR2,
			P_ATTRIBUTE8			IN	VARCHAR2,
			P_ATTRIBUTE9			IN	VARCHAR2,
			P_ATTRIBUTE10			IN	VARCHAR2,
			P_ATTRIBUTE11			IN	VARCHAR2,
			P_ATTRIBUTE12			IN	VARCHAR2,
			P_ATTRIBUTE13			IN	VARCHAR2,
			P_ATTRIBUTE14			IN	VARCHAR2,
			P_ATTRIBUTE15			IN	VARCHAR2,
			P_ATTRIBUTE16			IN	VARCHAR2,
			P_ATTRIBUTE17			IN	VARCHAR2,
			P_ATTRIBUTE18			IN	VARCHAR2,
			P_ATTRIBUTE19			IN	VARCHAR2,
			P_ATTRIBUTE20			IN	VARCHAR2,
			P_ATTRIBUTE21			IN	VARCHAR2,
			P_ATTRIBUTE22			IN	VARCHAR2,
			P_ATTRIBUTE23			IN	VARCHAR2,
			P_ATTRIBUTE24			IN	VARCHAR2,
			P_ATTRIBUTE25			IN	VARCHAR2,
			P_ATTRIBUTE26			IN	VARCHAR2,
			P_ATTRIBUTE27			IN	VARCHAR2,
			P_ATTRIBUTE28			IN	VARCHAR2,
			P_ATTRIBUTE29			IN	VARCHAR2,
			P_ATTRIBUTE30			IN	VARCHAR2,
			P_CURRENCY_CONVERSION_TYPE	IN	VARCHAR2,-- Introduced for Bug 2916848
			P_CURRENCY_CONVERSION_DATE	IN	DATE,-- Introduced for Bug 2916848
			P_RETURN_STATUS			OUT NOCOPY	VARCHAR2);


 PROCEDURE create_gms_sum_lines(p_source_type     IN VARCHAR2,
                                p_source_code     IN VARCHAR2,
                                p_time_period_id  IN NUMBER,
                                p_batch_name      IN VARCHAR2,
			        p_business_group_id IN NUMBER,
			        p_set_of_books_id   IN NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2);

 PROCEDURE transfer_to_gms_interface(p_source_type     IN VARCHAR2,
                                     p_source_code     IN VARCHAR2,
                                     p_time_period_id  IN NUMBER,
                                     p_batch_name      IN VARCHAR2,
			             p_business_group_id IN NUMBER,
			             p_set_of_books_id   IN NUMBER,
                                     p_return_status  OUT NOCOPY VARCHAR2);

 PROCEDURE gms_tie_back(p_payroll_control_id  IN  NUMBER,
                        p_source_type         IN  VARCHAR2,
                        p_period_end_date     IN  DATE,
                        p_gms_batch_name      IN  VARCHAR2,
		        p_business_group_id   IN  NUMBER,
		        p_set_of_books_id     IN  NUMBER,
			p_txn_source          IN  VARCHAR2,
			p_mode		      IN  VARCHAR2,
                        p_return_status	   OUT NOCOPY  VARCHAR2);

 PROCEDURE insert_into_pa_interface(
	P_TRANSACTION_INTERFACE_ID	IN	NUMBER,
	P_TRANSACTION_SOURCE		IN	VARCHAR2,
	P_BATCH_NAME			IN	VARCHAR2,
	P_EXPENDITURE_ENDING_DATE	IN	DATE,
	P_EMPLOYEE_NUMBER		IN	VARCHAR2,
	P_ORGANIZATION_NAME		IN	VARCHAR2,
	P_EXPENDITURE_ITEM_DATE		IN	DATE,
	P_PROJECT_NUMBER		IN	VARCHAR2,
	P_TASK_NUMBER			IN	VARCHAR2,
	P_EXPENDITURE_TYPE		IN	VARCHAR2,
	P_QUANTITY			IN	NUMBER,
	P_RAW_COST			IN	NUMBER,
	P_EXPENDITURE_COMMENT		IN	VARCHAR2,
	P_TRANSACTION_STATUS_CODE	IN	VARCHAR2,
	P_ORIG_TRANSACTION_REFERENCE	IN	VARCHAR2,
	P_ORG_ID			IN	NUMBER,
	P_DENOM_CURRENCY_CODE		IN	VARCHAR2,
	P_DENOM_RAW_COST		IN	NUMBER,
	P_ATTRIBUTE1			IN	VARCHAR2,
	P_ATTRIBUTE2			IN	VARCHAR2,
	P_ATTRIBUTE3			IN	VARCHAR2,
	P_ATTRIBUTE4			IN	VARCHAR2,
	P_ATTRIBUTE5			IN	VARCHAR2,
	P_ATTRIBUTE6			IN	VARCHAR2,
	P_ATTRIBUTE7			IN	VARCHAR2,
	P_ATTRIBUTE8			IN	VARCHAR2,
	P_ATTRIBUTE9			IN	VARCHAR2,
	P_ATTRIBUTE10			IN	VARCHAR2,
	P_ACCT_RATE_TYPE		IN	VARCHAR2,-- Introduced for Bug 2916848
	P_ACCT_RATE_DATE		IN	DATE,-- Introduced for Bug 2916848
	P_PERSON_BUSINESS_GROUP_ID		IN	NUMBER,-- Introduced for Bug 2935850
	P_RETURN_STATUS			OUT NOCOPY	VARCHAR2);

 PROCEDURE SUPERCEDE_ER(p_run_id        in  integer,
                        errbuf          in out nocopy varchar2,
                        retcode         in out nocopy varchar2,
                        p_source_type   in varchar2,
                        p_source_code   in varchar2,
                        p_time_period_id in integer,
                        p_batch_name     in varchar2,
                        p_return_status out nocopy varchar2);

 END  PSP_SUM_TRANS;

/
