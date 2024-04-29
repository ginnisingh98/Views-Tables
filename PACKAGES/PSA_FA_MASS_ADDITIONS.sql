--------------------------------------------------------
--  DDL for Package PSA_FA_MASS_ADDITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_FA_MASS_ADDITIONS" AUTHID CURRENT_USER AS
/* $Header: PSAFAUCS.pls 120.3 2006/03/16 15:31:23 tpradhan noship $ */

PROCEDURE update_asset_type
		(err_buf		OUT NOCOPY VARCHAR2,
		 ret_code		OUT NOCOPY VARCHAR2,
                 p_ledger_id            IN  NUMBER,
		 p_chart_of_accounts	IN  NUMBER,
		 p_asset_book		IN  VARCHAR2,
		 p_capital_acct_from	IN  VARCHAR2,
		 p_capital_acct_to	IN  VARCHAR2,
		 p_cip_acct_from	IN  VARCHAR2,
		 p_cip_acct_to		IN  VARCHAR2);

PROCEDURE PRINT_HEADER_INFO (p_asset_book 	 IN VARCHAR2,
			     p_capital_acct_from IN VARCHAR2,
			     p_capital_acct_to	 IN VARCHAR2,
			     p_cip_acct_from	 IN VARCHAR2,
			     p_cip_acct_to	 IN VARCHAR2);


PROCEDURE PRINT_MASS_ADDITION_DETAILS (p_mass_addition_id IN NUMBER);

PROCEDURE PRINT_REPORT_HEADER;

END PSA_FA_MASS_ADDITIONS;

 

/
