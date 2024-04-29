--------------------------------------------------------
--  DDL for Package ARP_CORRECT_CC_ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CORRECT_CC_ERRORS" AUTHID CURRENT_USER AS
/*$Header: ARCCCORS.pls 120.1.12010000.2 2009/01/28 02:55:26 vpusulur ship $ */

PROCEDURE cc_auto_correct(
       errbuf                   IN OUT NOCOPY VARCHAR2,
       retcode                  IN OUT NOCOPY VARCHAR2,
       p_request_id             IN NUMBER,
       p_mode                   IN VARCHAR2);

PROCEDURE cc_auto_correct_cover(p_request_id  IN NUMBER,
                                p_mode        IN VARCHAR2);

PROCEDURE obtain_alternate_payment(p_cc_trx_id IN NUMBER,
                                  p_cc_trx_category IN VARCHAR2,
			          p_error_notes    IN VARCHAR2);

PROCEDURE reauthorize(p_cc_trx_id IN NUMBER,
                    p_cc_trx_category IN VARCHAR2,
		    p_payment_trxn_extension_id IN NUMBER,
	            p_error_notes IN VARCHAR2);

PROCEDURE retry(p_cc_trx_id IN NUMBER,
                p_cc_trx_category IN VARCHAR2,
		p_payment_trxn_extension_id IN NUMBER,
	        p_error_notes IN VARCHAR2);
PROCEDURE lock_table_nowait(p_key IN NUMBER,
                 p_object_version_number IN NUMBER DEFAULT NULL,
		 p_table_name IN VARCHAR2,
		 p_trx_number IN VARCHAR2);

PROCEDURE correct_funds_error(p_cc_trx_id IN NUMBER,
                p_cc_trx_category IN VARCHAR2,
                p_corrective_action In VARCHAR2,
                p_instrument_number IN VARCHAR2,
                p_expiration_date   IN VARCHAR2,
                p_error_notes IN VARCHAR2);

FUNCTION get_collector_name (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER)
RETURN VARCHAR2;
FUNCTION cc_mapping_exist (
        p_cc_error_code IN ar_cc_error_mappings.cc_error_code%TYPE,
        p_cc_trx_category IN ar_cc_error_mappings.cc_trx_category%TYPE,
	p_receipt_method_id IN ar_cc_error_mappings.receipt_method_id%TYPE)
RETURN VARCHAR2;
END ARP_CORRECT_CC_ERRORS;

/
