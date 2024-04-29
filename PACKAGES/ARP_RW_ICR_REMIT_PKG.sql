--------------------------------------------------------
--  DDL for Package ARP_RW_ICR_REMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RW_ICR_REMIT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARICRRLS.pls 120.0.12010000.2 2009/02/25 16:57:55 mpsingh noship $ */
--
PROCEDURE insert_row(
	  P_REMIT_REFERENCE_ID      IN     ar_cash_remit_refs_all.REMIT_REFERENCE_ID%TYPE,
	  P_AUTOMATCH_SET_ID        IN     ar_cash_remit_refs_all.AUTOMATCH_SET_ID%TYPE,
	  P_CASH_RECEIPT_ID         IN     ar_cash_remit_refs_all.CASH_RECEIPT_ID%TYPE,
	  P_LINE_NUMBER             IN     ar_cash_remit_refs_all.LINE_NUMBER%TYPE,
	  P_REFERENCE_SOURCE        IN     ar_cash_remit_refs_all.REFERENCE_SOURCE%TYPE,
	  P_CUSTOMER_ID             IN     ar_cash_remit_refs_all.CUSTOMER_ID%TYPE,
	  P_CUSTOMER_NUMBER         IN     ar_cash_remit_refs_all.CUSTOMER_NUMBER%TYPE,
	  P_BANK_ACCOUNT_NUMBER     IN     ar_cash_remit_refs_all.BANK_ACCOUNT_NUMBER%TYPE,
	  P_TRANSIT_ROUTING_NUMBER  IN     ar_cash_remit_refs_all.TRANSIT_ROUTING_NUMBER%TYPE,
	  P_INVOICE_REFERENCE       IN     ar_cash_remit_refs_all.INVOICE_REFERENCE%TYPE,
	  P_MATCHING_REFERENCE_DATE     IN ar_cash_remit_refs_all.MATCHING_REFERENCE_DATE%TYPE,
	  P_RESOLVED_MATCHING_NUMBER    IN ar_cash_remit_refs_all.RESOLVED_MATCHING_NUMBER%TYPE,
	 -- P_RESOLVED_MATCHING_INSTALLMENT IN ar_cash_remit_refs_all.RESOLVED_MATCHING_INSTALLMENT%TYPE,
	  P_RESOLVED_MATCHING_DATE        IN ar_cash_remit_refs_all.RESOLVED_MATCHING_DATE%TYPE,
	  P_INVOICE_CURRENCY_CODE         IN ar_cash_remit_refs_all.INVOICE_CURRENCY_CODE%TYPE,
	  P_AMOUNT_APPLIED                IN ar_cash_remit_refs_all.AMOUNT_APPLIED%TYPE,
	  P_AMOUNT_APPLIED_FROM           IN ar_cash_remit_refs_all.AMOUNT_APPLIED_FROM%TYPE,
	  P_TRANS_TO_RECEIPT_RATE         IN ar_cash_remit_refs_all.TRANS_TO_RECEIPT_RATE%TYPE,
	  P_INVOICE_STATUS                IN ar_cash_remit_refs_all.INVOICE_STATUS%TYPE,
	  P_MATCH_RESOLVED_USING          IN ar_cash_remit_refs_all.MATCH_RESOLVED_USING%TYPE,
	  P_CUSTOMER_TRX_ID               IN ar_cash_remit_refs_all.CUSTOMER_TRX_ID%TYPE,
	  P_PAYMENT_SCHEDULE_ID           IN ar_cash_remit_refs_all.PAYMENT_SCHEDULE_ID%TYPE,
	  P_CUSTOMER_REFERENCE            IN ar_cash_remit_refs_all.CUSTOMER_REFERENCE%TYPE,
	  P_AUTO_APPLIED                  IN ar_cash_remit_refs_all.AUTO_APPLIED%TYPE,
	  P_MANUALLY_APPLIED              IN ar_cash_remit_refs_all.MANUALLY_APPLIED%TYPE,
	  P_INSTALLMENT_NUMBER            IN ar_cash_remit_refs_all.INSTALLMENT_NUMBER%TYPE,
	  P_PROGRAM_APPLICATION_ID        IN ar_cash_remit_refs_all.PROGRAM_APPLICATION_ID%TYPE,
	  P_PROGRAM_ID                    IN ar_cash_remit_refs_all.PROGRAM_ID%TYPE,
	  P_PROGRAM_UPDATE_DATE           IN ar_cash_remit_refs_all.PROGRAM_UPDATE_DATE%TYPE,
	  P_REQUEST_ID                    IN ar_cash_remit_refs_all.REQUEST_ID%TYPE,
	  P_BATCH_ID			  IN NUMBER DEFAULT NULL
         );
--
PROCEDURE update_row(
          P_REMIT_REFERENCE_ID      IN     ar_cash_remit_refs_all.REMIT_REFERENCE_ID%TYPE,
	  P_AUTOMATCH_SET_ID        IN     ar_cash_remit_refs_all.AUTOMATCH_SET_ID%TYPE,
	  P_CASH_RECEIPT_ID         IN     ar_cash_remit_refs_all.CASH_RECEIPT_ID%TYPE,
	  P_LINE_NUMBER             IN     ar_cash_remit_refs_all.LINE_NUMBER%TYPE,
	  P_REFERENCE_SOURCE        IN     ar_cash_remit_refs_all.REFERENCE_SOURCE%TYPE,
	  P_CUSTOMER_ID             IN     ar_cash_remit_refs_all.CUSTOMER_ID%TYPE,
	  P_CUSTOMER_NUMBER         IN     ar_cash_remit_refs_all.CUSTOMER_NUMBER%TYPE,
	  P_BANK_ACCOUNT_NUMBER     IN     ar_cash_remit_refs_all.BANK_ACCOUNT_NUMBER%TYPE,
	  P_TRANSIT_ROUTING_NUMBER  IN     ar_cash_remit_refs_all.TRANSIT_ROUTING_NUMBER%TYPE,
	  P_INVOICE_REFERENCE       IN     ar_cash_remit_refs_all.INVOICE_REFERENCE%TYPE,
	  P_MATCHING_REFERENCE_DATE     IN ar_cash_remit_refs_all.MATCHING_REFERENCE_DATE%TYPE,
	  P_RESOLVED_MATCHING_NUMBER    IN ar_cash_remit_refs_all.RESOLVED_MATCHING_NUMBER%TYPE,
	 -- P_RESOLVED_MATCHING_INSTALLMENT IN ar_cash_remit_refs_all.RESOLVED_MATCHING_INSTALLMENT%TYPE,
	  P_RESOLVED_MATCHING_DATE        IN ar_cash_remit_refs_all.RESOLVED_MATCHING_DATE%TYPE,
	  P_INVOICE_CURRENCY_CODE         IN ar_cash_remit_refs_all.INVOICE_CURRENCY_CODE%TYPE,
	  P_AMOUNT_APPLIED                IN ar_cash_remit_refs_all.AMOUNT_APPLIED%TYPE,
	  P_AMOUNT_APPLIED_FROM           IN ar_cash_remit_refs_all.AMOUNT_APPLIED_FROM%TYPE,
	  P_TRANS_TO_RECEIPT_RATE         IN ar_cash_remit_refs_all.TRANS_TO_RECEIPT_RATE%TYPE,
	  P_INVOICE_STATUS                IN ar_cash_remit_refs_all.INVOICE_STATUS%TYPE,
	  P_MATCH_RESOLVED_USING          IN ar_cash_remit_refs_all.MATCH_RESOLVED_USING%TYPE,
	  P_CUSTOMER_TRX_ID               IN ar_cash_remit_refs_all.CUSTOMER_TRX_ID%TYPE,
	  P_PAYMENT_SCHEDULE_ID           IN ar_cash_remit_refs_all.PAYMENT_SCHEDULE_ID%TYPE,
	  P_CUSTOMER_REFERENCE            IN ar_cash_remit_refs_all.CUSTOMER_REFERENCE%TYPE,
	  P_AUTO_APPLIED                  IN ar_cash_remit_refs_all.AUTO_APPLIED%TYPE,
	  P_MANUALLY_APPLIED              IN ar_cash_remit_refs_all.MANUALLY_APPLIED%TYPE,
	  P_INSTALLMENT_NUMBER            IN ar_cash_remit_refs_all.INSTALLMENT_NUMBER%TYPE,
	  P_PROGRAM_APPLICATION_ID        IN ar_cash_remit_refs_all.PROGRAM_APPLICATION_ID%TYPE,
	  P_PROGRAM_ID                    IN ar_cash_remit_refs_all.PROGRAM_ID%TYPE,
	  P_PROGRAM_UPDATE_DATE           IN ar_cash_remit_refs_all.PROGRAM_UPDATE_DATE%TYPE,
	  P_REQUEST_ID                    IN ar_cash_remit_refs_all.REQUEST_ID%TYPE  );
--
PROCEDURE delete_row(
            p_rr_id IN ar_cash_remit_refs_all.remit_reference_id%TYPE
             );
--
PROCEDURE lock_row(
          P_REMIT_REFERENCE_ID      IN     ar_cash_remit_refs_all.REMIT_REFERENCE_ID%TYPE,
	  P_AUTOMATCH_SET_ID        IN     ar_cash_remit_refs_all.AUTOMATCH_SET_ID%TYPE,
	  P_CASH_RECEIPT_ID         IN     ar_cash_remit_refs_all.CASH_RECEIPT_ID%TYPE,
	  P_LINE_NUMBER             IN     ar_cash_remit_refs_all.LINE_NUMBER%TYPE,
	  P_REFERENCE_SOURCE        IN     ar_cash_remit_refs_all.REFERENCE_SOURCE%TYPE,
	  P_CUSTOMER_ID             IN     ar_cash_remit_refs_all.CUSTOMER_ID%TYPE,
	  P_CUSTOMER_NUMBER         IN     ar_cash_remit_refs_all.CUSTOMER_NUMBER%TYPE,
	  P_BANK_ACCOUNT_NUMBER     IN     ar_cash_remit_refs_all.BANK_ACCOUNT_NUMBER%TYPE,
	  P_TRANSIT_ROUTING_NUMBER  IN     ar_cash_remit_refs_all.TRANSIT_ROUTING_NUMBER%TYPE,
	  P_INVOICE_REFERENCE       IN     ar_cash_remit_refs_all.INVOICE_REFERENCE%TYPE,
	  P_MATCHING_REFERENCE_DATE     IN ar_cash_remit_refs_all.MATCHING_REFERENCE_DATE%TYPE,
	  P_RESOLVED_MATCHING_NUMBER    IN ar_cash_remit_refs_all.RESOLVED_MATCHING_NUMBER%TYPE,
	 -- P_RESOLVED_MATCHING_INSTALLMENT IN ar_cash_remit_refs_all.RESOLVED_MATCHING_INSTALLMENT%TYPE,
	  P_RESOLVED_MATCHING_DATE        IN ar_cash_remit_refs_all.RESOLVED_MATCHING_DATE%TYPE,
	  P_INVOICE_CURRENCY_CODE         IN ar_cash_remit_refs_all.INVOICE_CURRENCY_CODE%TYPE,
	  P_AMOUNT_APPLIED                IN ar_cash_remit_refs_all.AMOUNT_APPLIED%TYPE,
	  P_AMOUNT_APPLIED_FROM           IN ar_cash_remit_refs_all.AMOUNT_APPLIED_FROM%TYPE,
	  P_TRANS_TO_RECEIPT_RATE         IN ar_cash_remit_refs_all.TRANS_TO_RECEIPT_RATE%TYPE,
	  P_INVOICE_STATUS                IN ar_cash_remit_refs_all.INVOICE_STATUS%TYPE,
	  P_MATCH_RESOLVED_USING          IN ar_cash_remit_refs_all.MATCH_RESOLVED_USING%TYPE,
	  P_CUSTOMER_TRX_ID               IN ar_cash_remit_refs_all.CUSTOMER_TRX_ID%TYPE,
	  P_PAYMENT_SCHEDULE_ID           IN ar_cash_remit_refs_all.PAYMENT_SCHEDULE_ID%TYPE,
	  P_CUSTOMER_REFERENCE            IN ar_cash_remit_refs_all.CUSTOMER_REFERENCE%TYPE,
	  P_AUTO_APPLIED                  IN ar_cash_remit_refs_all.AUTO_APPLIED%TYPE,
	  P_MANUALLY_APPLIED              IN ar_cash_remit_refs_all.MANUALLY_APPLIED%TYPE,
	  P_INSTALLMENT_NUMBER            IN ar_cash_remit_refs_all.INSTALLMENT_NUMBER%TYPE,
	  P_PROGRAM_APPLICATION_ID        IN ar_cash_remit_refs_all.PROGRAM_APPLICATION_ID%TYPE,
	  P_PROGRAM_ID                    IN ar_cash_remit_refs_all.PROGRAM_ID%TYPE,
	  P_PROGRAM_UPDATE_DATE           IN ar_cash_remit_refs_all.PROGRAM_UPDATE_DATE%TYPE,
	  P_REQUEST_ID                    IN ar_cash_remit_refs_all.REQUEST_ID%TYPE );
END ARP_RW_ICR_REMIT_PKG;

/
