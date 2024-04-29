--------------------------------------------------------
--  DDL for Package Body ARP_RECEIVABLES_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RECEIVABLES_TRX_PKG" AS
/*$Header: ARSIRTB.pls 115.5 2003/10/24 19:36:06 mraymond ship $*/
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE fetch_p(
	p_receivables_trx_id IN ar_receivables_trx.receivables_trx_id%TYPE,
        p_rt_rec OUT NOCOPY ar_receivables_trx%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_receivables_trx_pkg.fetch_p()+' );
    END IF;
    --
    SELECT *
    INTO   p_rt_rec
    FROM   ar_receivables_trx
    WHERE  receivables_trx_id = p_receivables_trx_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_receivables_trx_pkg.fetch_p()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: arp_receivables_trx_pkg.fetch_p' );
              END IF;
              RAISE;
END fetch_p;
--
END ARP_RECEIVABLES_TRX_PKG;

/
