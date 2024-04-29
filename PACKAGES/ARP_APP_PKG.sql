--------------------------------------------------------
--  DDL for Package ARP_APP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_APP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCIAPPS.pls 120.6 2006/12/14 17:23:23 mraymond ship $*/

FUNCTION revision RETURN VARCHAR2;

PROCEDURE insert_p(
    p_ra_rec IN ar_receivable_applications%ROWTYPE,
    p_ra_id  IN OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE);
--
PROCEDURE update_p( p_ra_rec    IN ar_receivable_applications%ROWTYPE );
--
PROCEDURE delete_p(
	p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE );
--
-- bugfix 2217253
PROCEDURE delete_f_ct_id(
	p_customer_trx_id IN ar_receivable_applications.customer_trx_id%TYPE );
--
PROCEDURE lock_p(
	p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE );

PROCEDURE nowaitlock_p(
        p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE );

PROCEDURE fetch_p(
        p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
        p_ra_rec OUT NOCOPY ar_receivable_applications%ROWTYPE );
--
END  ARP_APP_PKG;

 

/
