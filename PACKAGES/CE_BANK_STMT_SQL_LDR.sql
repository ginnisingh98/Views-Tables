--------------------------------------------------------
--  DDL for Package CE_BANK_STMT_SQL_LDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_STMT_SQL_LDR" AUTHID CURRENT_USER AS
/*$Header: cesqldrs.pls 120.3 2004/09/02 18:07:37 lkwan ship $ 	*/

/* 2421690
Start of Code Fix */

  G_spec_revision	VARCHAR2(1000) := '$Revision: 120.3 $';

FUNCTION spec_revision RETURN VARCHAR2;

FUNCTION body_revision RETURN VARCHAR2;

/* End of Code Fix */

PROCEDURE Print_Report(X_MAP_ID		NUMBER,
		       X_DATA_FILE	VARCHAR2);

PROCEDURE Call_Sql_Loader(errbuf		OUT NOCOPY 	VARCHAR2,
			  retcode		OUT NOCOPY 	NUMBER,
	                  X_process_option      IN	VARCHAR2,
  		 	  X_loading_id		IN	NUMBER,
			  X_input_file		IN	VARCHAR2,
			  X_directory_path	IN	VARCHAR2,
			  X_bank_branch_id	IN	VARCHAR2,
			  X_bank_account_id	IN	VARCHAR2,
  			  X_gl_date             IN      VARCHAR2,
  			  X_org_id              IN      VARCHAR2,
			  X_receivables_trx_id	IN     	NUMBER,
			  X_payment_method_id	IN     	NUMBER,
			  X_nsf_handling        IN     	VARCHAR2,
                          X_display_debug	IN	VARCHAR2,
			  X_debug_path		IN     	VARCHAR2,
			  X_debug_file		IN     	VARCHAR2,
			  X_gl_date_source	IN	VARCHAR2 DEFAULT NULL,
                          X_intra_day_flag      IN      VARCHAR2 DEFAULT 'N');

END CE_BANK_STMT_SQL_LDR;

 

/
