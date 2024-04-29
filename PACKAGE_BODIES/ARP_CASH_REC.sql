--------------------------------------------------------
--  DDL for Package Body ARP_CASH_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CASH_REC" AS
/* $Header: ARPLCRXB.pls 120.2 2005/10/30 04:24:29 appldev ship $ */

PROCEDURE upd_cash_receipts (p_exchange_date      DATE,
                             p_exchange_rate      NUMBER,
                             p_exchange_rate_type VARCHAR2,
                             p_cash_receipt_id    NUMBER,
			     p_last_updated_by	  NUMBER,
			     p_last_update_date	  DATE,
			     p_last_update_login  NUMBER) IS
BEGIN

    UPDATE AR_CASH_RECEIPTS
    SET EXCHANGE_DATE = p_exchange_date,
        EXCHANGE_RATE = p_exchange_rate,
        EXCHANGE_RATE_TYPE = p_exchange_rate_type,
	LAST_UPDATED_BY = p_last_updated_by,
	LAST_UPDATE_DATE = p_last_update_date,
	LAST_UPDATE_LOGIN = p_last_update_login
    WHERE
          CASH_RECEIPT_ID = p_cash_receipt_id;

    /*-----------------------------------+
     | Calling Central MRC library for   |
     | MRC integration.                  |
     +-----------------------------------*/

     ar_mrc_engine.maintain_mrc_data(
                     p_event_mode    => 'UPDATE',
                     p_table_name    => 'AR_CASH_RECEIPTS',
                     p_mode          => 'SINGLE',
                     p_key_value     => p_cash_receipt_id);

END upd_cash_receipts;


END arp_cash_rec;

/
