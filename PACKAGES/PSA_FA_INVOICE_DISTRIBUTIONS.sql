--------------------------------------------------------
--  DDL for Package PSA_FA_INVOICE_DISTRIBUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_FA_INVOICE_DISTRIBUTIONS" AUTHID CURRENT_USER AS
/* $Header: PSAFATAS.pls 120.3.12010000.2 2009/04/17 05:32:10 gnrajago ship $ */

PROCEDURE update_assets_tracking_flag
		(err_buf		OUT NOCOPY VARCHAR2,
		 ret_code		OUT NOCOPY VARCHAR2,
                 p_ledger_id            IN NUMBER,
		 p_chart_of_accounts	IN  NUMBER,
		 p_from_gl_date		IN  VARCHAR2,
		 p_to_gl_date		IN  VARCHAR2,
		 p_from_account		IN  VARCHAR2,
		 p_to_account		IN  VARCHAR2);

PROCEDURE print_header_info
		(p_from_gl_date IN DATE,
		 p_to_gl_date	IN DATE,
		 p_from_account IN VARCHAR2,
		 p_to_account	IN VARCHAR2);

PROCEDURE print_invoice_details (p_invoice_id IN NUMBER);

END PSA_FA_INVOICE_DISTRIBUTIONS;

/
