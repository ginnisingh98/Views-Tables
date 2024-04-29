--------------------------------------------------------
--  DDL for Package PSA_MFAR_RECEIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MFAR_RECEIPTS" AUTHID CURRENT_USER AS
/* $Header: PSAMFRTS.pls 120.5 2006/09/13 13:44:02 agovil ship $ */

FUNCTION create_distributions
		(errbuf                OUT NOCOPY VARCHAR2,
		 retcode               OUT NOCOPY VARCHAR2,
		 p_receivable_app_id 	IN NUMBER,
		 p_set_of_books_id 	IN NUMBER,
		 p_run_id		IN NUMBER,
		 p_error_message       OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


--
-- FUNCTIONS USED INSIDE SQL STATEMENTS SHOULD BE DECLARED IN THE PKG SPEC.
--

FUNCTION include_manual_line ( 	p_discount_basis	   IN VARCHAR2,
				p_link_to_cust_trx_line_id IN NUMBER,
				p_line_type		   IN VARCHAR2 ) RETURN VARCHAR2;


FUNCTION include_imported_line ( p_discount_basis		IN VARCHAR2,
		  		 p_link_to_cust_trx_line_id	IN NUMBER,
		  		 p_line_type			IN NUMBER,
		  		 p_inventory_item_id		IN NUMBER ) RETURN VARCHAR2;

PROCEDURE purge_orphan_distributions;


END PSA_MFAR_RECEIPTS;

 

/
