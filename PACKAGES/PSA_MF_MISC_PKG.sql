--------------------------------------------------------
--  DDL for Package PSA_MF_MISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_MISC_PKG" AUTHID CURRENT_USER AS
/* $Header: PSAMFMXS.pls 120.4 2006/09/13 13:37:21 agovil ship $ */

   FUNCTION generate_distributions (
                                     errbuf             OUT NOCOPY VARCHAR2,
                                     retcode            OUT NOCOPY VARCHAR2,
                                     p_cash_receipt_id   IN        NUMBER,
                                     p_set_of_books_id   IN        NUMBER,
                                     p_run_id            IN        NUMBER,
                                     p_error_message    OUT NOCOPY VARCHAR2,
                                     p_report_only       IN        VARCHAR2 DEFAULT 'N') RETURN BOOLEAN;


END psa_mf_misc_pkg;

 

/
