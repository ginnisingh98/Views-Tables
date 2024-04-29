--------------------------------------------------------
--  DDL for Package ARP_RECEIVABLES_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RECEIVABLES_TRX_PKG" AUTHID CURRENT_USER AS
/*$Header: ARSIRTS.pls 120.4 2005/10/30 03:57:11 appldev ship $*/

--
-- Public procedures/functions
--
PROCEDURE fetch_p(
	p_receivables_trx_id IN ar_receivables_trx.receivables_trx_id%TYPE,
        p_rt_rec OUT NOCOPY ar_receivables_trx%ROWTYPE );

END ARP_RECEIVABLES_TRX_PKG;

 

/
