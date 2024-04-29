--------------------------------------------------------
--  DDL for Package ARP_PROCESS_BR_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_BR_HEADER" AUTHID CURRENT_USER AS
/* $Header: ARTEBRHS.pls 115.3 2002/11/15 03:37:09 anukumar ship $ */

PROCEDURE insert_header(p_trx_rec               IN OUT NOCOPY ra_customer_trx%rowtype,
                        p_gl_date               IN     DATE,
                        p_trx_number            OUT NOCOPY    ra_customer_trx.trx_number%type,
                        p_customer_trx_id       OUT NOCOPY    ra_customer_trx.customer_trx_id%type);

PROCEDURE update_header(p_trx_rec               IN OUT NOCOPY ra_customer_trx%rowtype,
                        p_customer_trx_id       IN     ra_customer_trx.customer_trx_id%TYPE);

PROCEDURE delete_header(p_customer_trx_id       IN ra_customer_trx.customer_trx_id%TYPE);

PROCEDURE lock_transaction(p_customer_trx_id   IN ra_customer_trx.customer_trx_id%TYPE);

PROCEDURE move_deferred_tax(p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE,
                            p_required         OUT NOCOPY BOOLEAN);

END ARP_PROCESS_BR_HEADER;

 

/
