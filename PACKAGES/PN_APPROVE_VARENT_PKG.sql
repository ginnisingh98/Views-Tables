--------------------------------------------------------
--  DDL for Package PN_APPROVE_VARENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_APPROVE_VARENT_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRAPPS.pls 120.1 2006/12/20 09:20:34 pseeram noship $

PROCEDURE approve_payment_term_batch (
	errbuf                OUT NOCOPY  VARCHAR2,
	retcode               OUT NOCOPY  VARCHAR2,
	p_lease_num_from      IN  VARCHAR2,
	p_lease_num_to        IN  VARCHAR2,
	p_location_code_from  IN  VARCHAR2,
	p_location_code_to    IN  VARCHAR2,
	p_vrent_num_from      IN  VARCHAR2,
	p_vrent_num_to        IN  VARCHAR2,
	p_period_num_from     IN  NUMBER,
	p_period_num_to       IN  NUMBER,
	p_responsible_user    IN  NUMBER,
	p_var_rent_inv_id     IN  NUMBER,
    p_var_rent_type       IN  VARCHAR2,
	p_var_rent_id         IN  NUMBER,
    p_org_id              IN  NUMBER DEFAULT NULL,
    p_period_date         IN  VARCHAR2 DEFAULT NULL);

PROCEDURE  set_transferred_code (
        p_var_rent_inv_id NUMBER,
        p_rent_type VARCHAR2,
        p_term_status VARCHAR2,
        p_rent_amt NUMBER,
        p_period_id NUMBER,
        p_var_rent_id NUMBER,
        p_invoice_date DATE,
        p_counter IN OUT NOCOPY NUMBER);

END pn_approve_varent_pkg;


/
