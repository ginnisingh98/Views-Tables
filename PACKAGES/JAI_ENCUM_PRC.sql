--------------------------------------------------------
--  DDL for Package JAI_ENCUM_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_ENCUM_PRC" AUTHID CURRENT_USER AS
/* $Header: jai_encum_prc.pls 120.1.12000000.1 2007/10/24 18:20:19 rallamse noship $ */

  PROCEDURE fetch_nr_tax( p_dist_type_tbl IN po_tbl_varchar30,
                          p_dist_id_tbl   IN po_tbl_number,
                          p_action        IN VARCHAR2,
                          p_doc_type      IN VARCHAR2,
                          p_nr_tax_tbl    OUT NOCOPY po_tbl_number,
                          p_return_status OUT NOCOPY VARCHAR2
                         );

  PROCEDURE fetch_encum_rev_amt( p_acct_txn_id	    IN 	NUMBER,
																 p_source_doc_type  IN  VARCHAR2,
																 p_source_doc_id    IN  NUMBER,
																 p_acct_source      IN  VARCHAR2,
                                 p_nr_tax_amount    OUT NOCOPY NUMBER,
                                 p_rec_tax_amount   OUT NOCOPY NUMBER,
                                 p_err_num	        OUT NOCOPY NUMBER,
																 p_err_code	        OUT NOCOPY VARCHAR2,
																 p_err_msg	        OUT NOCOPY VARCHAR2
                                );

END jai_encum_prc;
 

/
