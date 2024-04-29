--------------------------------------------------------
--  DDL for Package ARP_CASH_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CASH_REC" AUTHID CURRENT_USER AS
/* $Header: ARPLCRXS.pls 120.2 2005/10/30 04:24:30 appldev ship $ */

PROCEDURE upd_cash_receipts (p_exchange_date      DATE,
                             p_exchange_rate      NUMBER,
                             p_exchange_rate_type VARCHAR2,
                             p_cash_receipt_id    NUMBER,
			     p_last_updated_by	  NUMBER,
			     p_last_update_date	  DATE,
			     p_last_update_login  NUMBER);


END arp_cash_rec;

 

/
