--------------------------------------------------------
--  DDL for Package ARP_BR_REMIT_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BR_REMIT_FUNCTION" AUTHID CURRENT_USER AS
/* $Header: ARBRRMFS.pls 120.2 2005/08/01 10:53:14 naneja ship $*/

FUNCTION GET_AMOUNT (p_trh_id IN ar_transaction_history.transaction_history_id%TYPE,
		     p_status IN ar_transaction_history.status%TYPE,
		     p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) RETURN NUMBER;

FUNCTION GET_ACCTD_AMOUNT (p_trh_id IN ar_transaction_history.transaction_history_id%TYPE,
		           p_status IN ar_transaction_history.status%TYPE,
		           p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) RETURN NUMBER;


FUNCTION revision RETURN VARCHAR2;

END  ARP_BR_REMIT_FUNCTION;
--

 

/
