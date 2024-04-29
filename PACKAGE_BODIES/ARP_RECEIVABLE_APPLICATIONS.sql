--------------------------------------------------------
--  DDL for Package Body ARP_RECEIVABLE_APPLICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RECEIVABLE_APPLICATIONS" AS
/* $Header: ARPLAPPB.pls 115.4 2002/11/18 21:47:18 anukumar ship $    */

--
    PROCEDURE PopulateCashReceiptHistoryId( p_CashReceiptId IN NUMBER,
                                            p_CashReceiptHistoryId IN OUT NOCOPY NUMBER ) IS
    BEGIN
        IF p_CashReceiptId IS NOT NULL  AND  p_CashReceiptHistoryId IS NULL
        THEN
            p_CashReceiptHistoryId := arp_cash_receipt_history.GetCurrentId( p_CashReceiptId );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            arp_standard.debug( 'Exception:arp_receivable_applications.PopulateCashReceiptHistoryId');
            RAISE;
    END;
--
END ARP_RECEIVABLE_APPLICATIONS;

/
