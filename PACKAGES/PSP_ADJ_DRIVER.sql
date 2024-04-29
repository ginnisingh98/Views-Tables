--------------------------------------------------------
--  DDL for Package PSP_ADJ_DRIVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ADJ_DRIVER" AUTHID CURRENT_USER AS
/*$Header: PSPLDTRS.pls 120.2 2006/10/19 06:30:03 dpaudel noship $*/

PROCEDURE load_table(errbuf  		OUT NOCOPY VARCHAR2,
                     retcode 		OUT NOCOPY VARCHAR2,
                     p_person_id 	IN NUMBER,
                     p_assignment_id 	IN NUMBER,
              ---    p_element_type_id 	IN NUMBER,  commented for DA-ENH
                     p_begin_date 	IN DATE,
                     p_end_date 	IN DATE,
                     p_adjust_by        IN VARCHAR2,
                     p_currency_code    IN VARCHAR2,	-- Introduced for bug fix 2916848
		     p_run_id 		IN NUMBER,
		     p_business_group_id IN NUMBER,
		     p_set_of_books_id	IN NUMBER);

PROCEDURE generate_lines(errbuf  			OUT NOCOPY VARCHAR2,
			 retcode 			OUT NOCOPY VARCHAR2,
			 p_person_id       		IN NUMBER,
			 p_assignment_id   		IN NUMBER,
			 ---p_element_type_id 		IN NUMBER, commented for DA-ENH
			 p_batch_name      		IN VARCHAR2,
			 p_batch_comments  		IN VARCHAR2,
                         p_run_id          		IN NUMBER,
			 p_gl_posting_override_date 	IN DATE DEFAULT NULL,
			 p_distribution_start_date 	IN date,
			 p_distribution_end_date   	IN date,
			 p_business_group_id	   	IN number,
			 p_set_of_books_id	   	IN number,
			 p_employee_full_name           IN VARCHAR2,
                         p_assignment_number            IN VARCHAR2,
                         ---p_earnings_element             IN VARCHAR2,  commented for DA-ENH
                         p_time_out                     IN NUMBER,
                         p_adjust_by                    IN VARCHAR2,  -- added for DA-ENH
                         p_currency_code                IN VARCHAR2,	-- Introduced for bug fix 2916848
			 p_defer_autopop_param		IN VARCHAR2,  --Introduced for Bug 3548388
			 p_begin_date			IN DATE, --Introduced for Bug 3548388
			 p_adjustment_line_id	      	OUT NOCOPY NUMBER,  --Introduced for Bug 3548388
			 p_element_status			OUT NOCOPY VARCHAR2); --Introduced for Bug 3548388

PROCEDURE load_approval_table(errbuf 			OUT NOCOPY VARCHAR2,
			      retcode 			OUT NOCOPY VARCHAR2,
			      p_batch_name 		IN VARCHAR2,
			      p_run_id 			IN NUMBER,
			      p_business_group_id	IN NUMBER,
			      p_set_of_books_id		IN NUMBER);

PROCEDURE get_approval_header(errbuf  			OUT NOCOPY VARCHAR2,
                              retcode 			OUT NOCOPY VARCHAR2,
			      p_batch_name 		IN VARCHAR2,
			      p_business_group_id	IN NUMBER,
			      p_set_of_books_id		IN NUMBER,
			      l_full_name 		OUT NOCOPY VARCHAR2,
			      l_employee_number 	OUT NOCOPY VARCHAR2,
			      l_assignment_number 	OUT NOCOPY VARCHAR2,
                              l_assignment_organization OUT NOCOPY VARCHAR2,
			      l_begin_date 		OUT NOCOPY DATE,
			      l_end_date 		OUT NOCOPY DATE,
			      l_currency_code		OUT NOCOPY VARCHAR2,
		        	l_batch_comments 	OUT NOCOPY VARCHAR2);

PROCEDURE update_adjustment_ctrl_comment(errbuf  	OUT NOCOPY VARCHAR2,
                                         retcode 	OUT NOCOPY VARCHAR2,
			                 p_batch_name 	IN VARCHAR2,
                                         p_comments 	IN VARCHAR2);

PROCEDURE INSERT_PSP_CLEARING_ACCOUNT(errbuf 		out NOCOPY VARCHAR2,
		     		      retcode 		out NOCOPY VARCHAR2,
	             		      p_reversing_gl_ccid IN NUMBER,
                     		      p_comments 	IN VARCHAR2,
				      p_business_group_id IN Number,
				      p_set_of_books_id   IN Number,
				      p_payroll_id        IN Number,
				      p_rowid             OUT NOCOPY VARCHAR2 );

PROCEDURE UPDATE_PSP_CLEARING_ACCOUNT(errbuf 		out NOCOPY VARCHAR2,
		     			retcode 	out NOCOPY VARCHAR2,
	             			p_reversing_gl_ccid IN NUMBER,
                     			p_comments 	IN VARCHAR2,
				      p_business_group_id IN Number,
				      p_set_of_books_id   IN Number,
				      p_payroll_id        IN Number,
				      p_rowid             IN VARCHAR2 );

PROCEDURE DELETE_PSP_CLEARING_ACCOUNT(errbuf out NOCOPY VARCHAR2,
		     retcode out NOCOPY VARCHAR2,
	             p_reversing_gl_ccid IN NUMBER,
				      p_business_group_id IN Number,
				      p_set_of_books_id   IN Number,
				      p_rowid             IN VARCHAR2);

PROCEDURE LOCK_ROW_PSP_CLEARING_ACCOUNT (
				      p_business_group_id  IN NUMBER,
				      p_set_of_books_id    IN NUMBER,
				      p_reversing_gl_ccid  IN NUMBER,
				      p_comments           IN VARCHAR2,
				      p_payroll_id         IN NUMBER);

/* commented for DA-ENH
PROCEDURE mark_adj_begin(errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2,
                         p_person_id       IN NUMBER,
                         p_assignment_id   IN NUMBER,
                         p_element_type_id IN NUMBER,
                         p_begin_date      IN DATE,
                         p_end_date        IN DATE,
		         p_run_id          IN NUMBER,
			 p_business_group_id in number,
			 p_set_of_books_id   in number);

PROCEDURE mark_adj_end(p_run_id IN VARCHAR2);

PROCEDURE mark_batch_in_use(p_batch_name IN VARCHAR2);

PROCEDURE unmark_batch_in_use(p_batch_name IN VARCHAR2);
 */

PROCEDURE undo_adjustment(p_batch_name 		IN  VARCHAR2,
			  p_business_group_id	IN  NUMBER,
			  p_set_of_books_id	IN  NUMBER,
			  p_comments		IN  VARCHAR2,
                          errbuf       		OUT NOCOPY VARCHAR2,
                          return_code  		OUT NOCOPY NUMBER);
-- added following procedure for DA-ENH
PROCEDURE validate_proj_before_transfer
    (p_run_id  IN NUMBER,
    p_acct_group_id IN NUMBER,
    p_person_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id  IN NUMBER,
    p_award_id  IN NUMBER  DEFAULT NULL,
    p_expenditure_type IN VARCHAR2,
    p_expenditure_org_id IN NUMBER,
    p_error_flag OUT NOCOPY VARCHAR2,
    p_error_status OUT NOCOPY VARCHAR2,
    p_effective_date OUT NOCOPY DATE);
END;

/
