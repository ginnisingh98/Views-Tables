--------------------------------------------------------
--  DDL for Package Body ARP_RM_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RM_ACCOUNTS_PKG" AS
/*$Header: ARSIRMAB.pls 120.6 2004/02/27 19:00:24 mraymond ship $*/
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE fetch_p(
	p_receipt_method_id IN ar_receipt_method_accounts.receipt_method_id%TYPE,
        p_bank_account_id IN ar_receipt_method_accounts.remit_bank_acct_use_id%type,
        p_rma_rec OUT NOCOPY ar_receipt_method_accounts%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '>>ar_rm_accounts_pkg.fetch_p' );
    END IF;
    --
    SELECT *
    INTO   p_rma_rec
    FROM   ar_receipt_method_accounts
    WHERE  receipt_method_id = p_receipt_method_id
    AND    remit_bank_acct_use_id = p_bank_account_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( '<<ar_rm_accounts_pkg.fetch_p' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: ar_rm_accounts_pkg.fetch_p' );
              END IF;
              RAISE;
END fetch_p;
--
END ARP_RM_ACCOUNTS_PKG;

/
