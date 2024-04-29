--------------------------------------------------------
--  DDL for Package FV_IPAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_IPAC" AUTHID CURRENT_USER AS
-- $Header: FVIPPROS.pls 120.11 2006/08/07 08:38:57 kbhatt ship $

 PROCEDURE main (errbuf                 OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY VARCHAR2,
                profile_class_id        VARCHAR2,
                customer_category       VARCHAR2,
                customer_id             VARCHAR2,
                transaction_type        VARCHAR2,
                trx_date_low            VARCHAR2,
                trx_date_high           VARCHAR2,
		contact_ph_no		VARCHAR2
                );

 PROCEDURE create_bulk_file(errbuf            OUT NOCOPY VARCHAR2,
                            retcode           OUT NOCOPY VARCHAR2,
                            p_org_id          IN          NUMBER  ) ;

 PROCEDURE create_receipt_acct_main(errbuf            OUT NOCOPY VARCHAR2,
                            	    retcode           OUT NOCOPY VARCHAR2,
                            	    p_receipt_method_id IN NUMBER,
                                    p_receipt_date IN DATE ,
				    p_gl_date IN DATE );



END fv_ipac;

 

/
