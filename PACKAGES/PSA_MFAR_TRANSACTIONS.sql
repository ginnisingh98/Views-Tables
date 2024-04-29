--------------------------------------------------------
--  DDL for Package PSA_MFAR_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MFAR_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: PSAMFTXS.pls 120.4 2006/09/13 13:58:52 agovil ship $ */

FUNCTION create_distributions
		(errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  VARCHAR2,
                 p_cust_trx_id		IN NUMBER,
		 p_set_of_books_id	IN NUMBER,
		 p_run_id		IN NUMBER,
		 p_error_message       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN;


END PSA_MFAR_TRANSACTIONS;

 

/
