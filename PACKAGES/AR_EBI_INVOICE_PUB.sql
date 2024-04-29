--------------------------------------------------------
--  DDL for Package AR_EBI_INVOICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_EBI_INVOICE_PUB" AUTHID CURRENT_USER AS
/* $Header: AREIINVS.pls 120.1.12010000.1 2008/11/17 14:10:18 rsamanta noship $ */


PROCEDURE ar_invoice_submission
  (
    p_lines_all     	  IN AR_EBI_RA_INT_LINES_ALL_LIST,
    p_distributions 	  IN AR_EBI_RA_INT_DIST_LIST,
    p_salescredits	  IN AR_EBI_RA_INT_SALESCREDIT_LIST,
    p_run_autoinvoice_cp  IN VARCHAR2 := FND_API.g_true,
    p_commit     	  IN VARCHAR2 := FND_API.g_false,
    x_conc_req_ids   	  OUT NOCOPY FND_TABLE_OF_NUMBER,
    x_err_msg       	  OUT NOCOPY VARCHAR2,
    x_return_status 	  OUT NOCOPY VARCHAR2 );

END AR_EBI_INVOICE_PUB;


/
