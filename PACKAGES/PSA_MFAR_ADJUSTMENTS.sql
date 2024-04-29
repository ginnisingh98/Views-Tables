--------------------------------------------------------
--  DDL for Package PSA_MFAR_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MFAR_ADJUSTMENTS" AUTHID CURRENT_USER AS
/* $Header: PSAMFADS.pls 120.5 2006/09/13 12:12:34 agovil ship $ */

FUNCTION create_distributions
		(errbuf                OUT NOCOPY VARCHAR2,
		 retcode               OUT NOCOPY VARCHAR2,
		 p_adjustment_id	IN NUMBER,
		 p_set_of_books_id	IN NUMBER,
		 p_run_id		IN NUMBER,
		 p_error_message       OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION FIND_TAX_FREIGHT_LINES (p_adjustment_type VARCHAR2,
				 p_line_type	   VARCHAR2 ) RETURN VARCHAR2;


FUNCTION is_reverse_entry( l_index IN NUMBER) RETURN BOOLEAN;

TYPE hold_ccid_info_rec_type IS RECORD
         (cust_trx_line_id            ra_customer_trx_lines.customer_trx_line_id%type,
          line_type                   ra_customer_trx_lines.line_type%type,
          cust_trx_line_gl_dist_id    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type  ,
          mf_rec_ccid                 psa_mf_trx_dist_all.mf_receivables_ccid%type,
          code_combination_id         ra_cust_trx_line_gl_dist.code_combination_id%type ,
          amount_due                  psa_mf_balances_view.amount_due_original%type,
          percent                     ra_cust_trx_line_gl_dist.percent%type
         );



TYPE hold_cursor_info_tab_type IS TABLE OF hold_ccid_info_rec_type
INDEX BY BINARY_INTEGER;

ccid_info               hold_cursor_info_tab_type;



END PSA_MFAR_ADJUSTMENTS;

 

/
