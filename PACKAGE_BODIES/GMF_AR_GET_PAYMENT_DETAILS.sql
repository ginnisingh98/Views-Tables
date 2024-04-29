--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_PAYMENT_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_PAYMENT_DETAILS" AS
/* $Header: gmfinrpb.pls 115.1 99/07/16 04:19:17 porting shi $ */
	CURSOR cur_get_payment_details(
		invoice_id NUMBER,
		start_date DATE,
		end_date DATE) IS
SELECT
	arc.CASH_RECEIPT_ID,
	arc.LAST_UPDATED_BY,
	arc.LAST_UPDATE_DATE,
	arc.CREATED_BY,
	arc.CREATION_DATE,
	arc.AMOUNT,
	arc.SET_OF_BOOKS_ID,
	arc.CURRENCY_CODE,
	arc.RECEIVABLES_TRX_ID,
	arc.PAY_FROM_CUSTOMER,
	arc.STATUS,
	arc.TYPE,
	arc.RECEIPT_NUMBER,
	arc.RECEIPT_DATE,
	arc.MISC_PAYMENT_SOURCE,
	arc.COMMENTS,
	arc.DISTRIBUTION_SET_ID,
	arc.REVERSAL_DATE,
	arc.REVERSAL_CATEGORY,
	arc.REVERSAL_REASON_CODE,
	arc.REVERSAL_COMMENTS,
	arc.EXCHANGE_RATE_TYPE,
	arc.EXCHANGE_RATE,
	arc.EXCHANGE_DATE,
	arc.REMITTANCE_BANK_ACCOUNT_ID,
	arc.CONFIRMED_FLAG,
	arc.CUSTOMER_BANK_ACCOUNT_ID,
	arc.CUSTOMER_SITE_USE_ID,
	arc.DEPOSIT_DATE,
	arc.PROGRAM_APPLICATION_ID,
	arc.PROGRAM_ID,
	arc.PROGRAM_UPDATE_DATE,
	arc.RECEIPT_METHOD_ID,
	arc.REQUEST_ID,
	arc.SELECTED_FOR_FACTORING_FLAG,
	arc.SELECTED_REMITTANCE_BATCH_ID,
	arc.FACTOR_DISCOUNT_AMOUNT,
	arc.VAT_TAX_ID,
	arr.RECEIVABLE_APPLICATION_ID,
	arr.LAST_UPDATED_BY,
	arr.LAST_UPDATE_DATE,
	arr.CREATED_BY,
	arr.CREATION_DATE,
	arr.AMOUNT_APPLIED,
	arr.GL_DATE,
	arr.CODE_COMBINATION_ID,
	arr.SET_OF_BOOKS_ID,
	arr.DISPLAY,
	arr.APPLY_DATE,
	arr.APPLICATION_TYPE,
	arr.STATUS,
	arr.PAYMENT_SCHEDULE_ID,
	arr.LAST_UPDATE_LOGIN,
	arr.CASH_RECEIPT_ID,
	arr.APPLIED_CUSTOMER_TRX_ID,
	arr.APPLIED_CUSTOMER_TRX_LINE_ID,
	arr.APPLIED_PAYMENT_SCHEDULE_ID,
	arr.CUSTOMER_TRX_ID,
	arr.LINE_APPLIED,
	arr.TAX_APPLIED,
	arr.FREIGHT_APPLIED,
	arr.RECEIVABLES_CHARGES_APPLIED,
	arr.ON_ACCOUNT_CUSTOMER,
	arr.RECEIVABLES_TRX_ID,
	arr.EARNED_DISCOUNT_TAKEN,
	arr.UNEARNED_DISCOUNT_TAKEN,
	arr.DAYS_LATE,
	arr.APPLICATION_RULE,
	arr.GL_POSTED_DATE,
	arr.COMMENTS,
	arr.POSTABLE,
	arr.POSTING_CONTROL_ID,
	arr.ACCTD_AMOUNT_APPLIED_FROM,
	arr.ACCTD_AMOUNT_APPLIED_TO,
	arr.ACCTD_EARNED_DISCOUNT_TAKEN,
	arr.CONFIRMED_FLAG,
	arr.PROGRAM_APPLICATION_ID,
	arr.PROGRAM_ID,
	arr.PROGRAM_UPDATE_DATE,
	arr.REQUEST_ID,
	arr.EARNED_DISCOUNT_CCID,
	arr.UNEARNED_DISCOUNT_CCID,
	arr.ACCTD_UNEARNED_DISCOUNT_TAKEN,
	arr.REVERSAL_GL_DATE,
	' ',
	arr.CASH_RECEIPT_HISTORY_ID
from    AR_CASH_RECEIPTS_ALL arc,
	AR_RECEIVABLE_APPLICATIONS_ALL arr
where   (arr.APPLIED_CUSTOMER_TRX_ID = invoice_id)
	AND (arr.last_update_date between nvl(start_date, arr.last_update_date)
	AND nvl(end_date, arr.last_update_date))
	AND (arc.CASH_RECEIPT_ID = arr.CASH_RECEIPT_ID);

PROCEDURE get_payment_details
	(invoice_id                     IN      OUT     NUMBER,
	start_date                      IN      OUT     DATE,
	end_date                        IN      OUT     DATE,
	arc_CASH_RECEIPT_ID                     OUT     NUMBER,
	arc_LAST_UPDATED_BY                     OUT     NUMBER,
	arc_LAST_UPDATE_DATE                    OUT     DATE,
	arc_CREATED_BY                          OUT     NUMBER,
	arc_CREATION_DATE                       OUT     DATE,
	arc_AMOUNT                              OUT     NUMBER,
	arc_SET_OF_BOOKS_ID                     OUT     NUMBER,
	arc_CURRENCY_CODE                       OUT     VARCHAR2,
	arc_RECEIVABLES_TRX_ID                  OUT     NUMBER,
	arc_PAY_FROM_CUSTOMER                   OUT     NUMBER,
	arc_STATUS                              OUT     VARCHAR2,
	arc_TYPE                                OUT     VARCHAR2,
	arc_RECEIPT_NUMBER                      OUT     VARCHAR2,
	arc_RECEIPT_DATE                        OUT     DATE,
	arc_MISC_PAYMENT_SOURCE                 OUT     VARCHAR2,
	arc_COMMENTS                            OUT     VARCHAR2,
	arc_DISTRIBUTION_SET_ID                 OUT     NUMBER,
	arc_REVERSAL_DATE                       OUT     DATE,
	arc_REVERSAL_CATEGORY                   OUT     VARCHAR2,
	arc_REVERSAL_REASON_CODE                OUT     VARCHAR2,
	arc_REVERSAL_COMMENTS                   OUT     VARCHAR2,
	arc_EXCHANGE_RATE_TYPE                  OUT     VARCHAR2,
	arc_EXCHANGE_RATE                       OUT     NUMBER,
	arc_EXCHANGE_DATE                       OUT     DATE,
	arc_REMITTANCE_BANK_ACC_ID          	OUT     NUMBER,
	arc_CONFIRMED_FLAG                      OUT     VARCHAR2,
	arc_CUSTOMER_BANK_ACC_ID            	OUT     NUMBER,
	arc_CUSTOMER_SITE_USE_ID                OUT     NUMBER,
	arc_DEPOSIT_DATE                        OUT     DATE,
	arc_PROGRAM_APPLICATION_ID              OUT     NUMBER,
	arc_PROGRAM_ID                          OUT     NUMBER,
	arc_PROGRAM_UPDATE_DATE                 OUT     DATE,
	arc_RECEIPT_METHOD_ID                   OUT     NUMBER,
	arc_REQUEST_ID                          OUT     NUMBER,
	arc_SELECTED_FOR_FACT_FLAG         	OUT     VARCHAR2,
	arc_SELECTED_REMIT_BATCH_ID        	OUT     NUMBER,
	arc_FACTOR_DISCOUNT_AMOUNT              OUT     NUMBER,
	arc_VAT_TAX_ID                          OUT     NUMBER,
	arr_RECEIVABLE_APPLICATION_ID           OUT     NUMBER,
	arr_LAST_UPDATED_BY                     OUT     NUMBER,
	arr_LAST_UPDATE_DATE                    OUT     DATE,
	arr_CREATED_BY                          OUT     NUMBER,
	arr_CREATION_DATE                       OUT     DATE,
	arr_AMOUNT_APPLIED                      OUT     NUMBER,
	arr_GL_DATE                             OUT     DATE,
	arr_CODE_COMBINATION_ID                 OUT     NUMBER,
	arr_SET_OF_BOOKS_ID                     OUT     NUMBER,
	arr_DISPLAY                             OUT     VARCHAR2,
	arr_APPLY_DATE                          OUT     DATE,
	arr_APPLICATION_TYPE                    OUT     VARCHAR2,
	arr_STATUS                              OUT     VARCHAR2,
	arr_PAYMENT_SCHEDULE_ID                 OUT     NUMBER,
	arr_LAST_UPDATE_LOGIN                   OUT     NUMBER,
	arr_CASH_RECEIPT_ID                     OUT     NUMBER,
	arr_APPLIED_CUSTOMER_TRX_ID             OUT     NUMBER,
	arr_APPLIED_CUST_TRX_LINE_ID    	OUT     NUMBER,
	arr_APPLIED_PAYMENT_SCH_ID         	OUT     NUMBER,
	arr_CUSTOMER_TRX_ID                     OUT     NUMBER,
	arr_LINE_APPLIED                        OUT     NUMBER,
	arr_TAX_APPLIED                         OUT     NUMBER,
	arr_FREIGHT_APPLIED                     OUT     NUMBER,
	arr_RECEIVABLES_CHARGES_APPD         	OUT     NUMBER,
	arr_ON_ACCOUNT_CUSTOMER                 OUT     NUMBER,
	arr_RECEIVABLES_TRX_ID                  OUT     NUMBER,
	arr_EARNED_DISCOUNT_TAKEN               OUT     NUMBER,
	arr_UNEARNED_DISCOUNT_TAKEN             OUT     NUMBER,
	arr_DAYS_LATE                           OUT     NUMBER,
	arr_APPLICATION_RULE                    OUT     VARCHAR2,
	arr_GL_POSTED_DATE                      OUT     DATE,
	arr_COMMENTS                            OUT     VARCHAR2,
	arr_POSTABLE                            OUT     VARCHAR2,
	arr_POSTING_CONTROL_ID                  OUT     NUMBER,
	arr_ACCTD_AMOUNT_APPLIED_FROM           OUT     NUMBER,
	arr_ACCTD_AMOUNT_APPLIED_TO             OUT     NUMBER,
	arr_ACCTD_EARNED_DISC_TAKEN         	OUT     NUMBER,
	arr_CONFIRMED_FLAG                      OUT     VARCHAR2,
	arr_PROGRAM_APPLICATION_ID              OUT     NUMBER,
	arr_PROGRAM_ID                          OUT     NUMBER,
	arr_PROGRAM_UPDATE_DATE                 OUT     DATE,
	arr_REQUEST_ID                          OUT     NUMBER,
	arr_EARNED_DISCOUNT_CCID                OUT     NUMBER,
	arr_UNEARNED_DISCOUNT_CCID              OUT     NUMBER,
	arr_ACCTD_UNEARNED_DISC_TAKEN       	OUT     NUMBER,
	arr_REVERSAL_GL_DATE                    OUT     DATE,
	arr_REVERSAL_GL_DATE_CONTEXT            OUT     VARCHAR2,
	arr_CASH_RECEIPT_HISTORY_ID             OUT     NUMBER,
	row_to_fetch                    IN      OUT     NUMBER,
	error_status                            OUT     NUMBER ) IS
BEGIN
	if NOT cur_get_payment_details%ISOPEN
	then
		OPEN cur_get_payment_details( invoice_id, start_date, end_date);
	end if;

	FETCH cur_get_payment_details INTO
	arc_CASH_RECEIPT_ID,
	arc_LAST_UPDATED_BY,
	arc_LAST_UPDATE_DATE,
	arc_CREATED_BY,
	arc_CREATION_DATE,
	arc_AMOUNT,
	arc_SET_OF_BOOKS_ID,
	arc_CURRENCY_CODE,
	arc_RECEIVABLES_TRX_ID,
	arc_PAY_FROM_CUSTOMER,
	arc_STATUS,
	arc_TYPE,
	arc_RECEIPT_NUMBER,
	arc_RECEIPT_DATE,
	arc_MISC_PAYMENT_SOURCE,
	arc_COMMENTS,
	arc_DISTRIBUTION_SET_ID,
	arc_REVERSAL_DATE,
	arc_REVERSAL_CATEGORY,
	arc_REVERSAL_REASON_CODE,
	arc_REVERSAL_COMMENTS,
	arc_EXCHANGE_RATE_TYPE,
	arc_EXCHANGE_RATE,
	arc_EXCHANGE_DATE,
	arc_REMITTANCE_BANK_ACC_ID,
	arc_CONFIRMED_FLAG,
	arc_CUSTOMER_BANK_ACC_ID,
	arc_CUSTOMER_SITE_USE_ID,
	arc_DEPOSIT_DATE,
	arc_PROGRAM_APPLICATION_ID,
	arc_PROGRAM_ID,
	arc_PROGRAM_UPDATE_DATE,
	arc_RECEIPT_METHOD_ID,
	arc_REQUEST_ID,
	arc_SELECTED_FOR_FACT_FLAG,
	arc_SELECTED_REMIT_BATCH_ID,
	arc_FACTOR_DISCOUNT_AMOUNT,
	arc_VAT_TAX_ID,
	arr_RECEIVABLE_APPLICATION_ID,
	arr_LAST_UPDATED_BY,
	arr_LAST_UPDATE_DATE,
	arr_CREATED_BY,
	arr_CREATION_DATE,
	arr_AMOUNT_APPLIED,
	arr_GL_DATE,
	arr_CODE_COMBINATION_ID,
	arr_SET_OF_BOOKS_ID,
	arr_DISPLAY,
	arr_APPLY_DATE,
	arr_APPLICATION_TYPE,
	arr_STATUS,
	arr_PAYMENT_SCHEDULE_ID,
	arr_LAST_UPDATE_LOGIN,
	arr_CASH_RECEIPT_ID,
	arr_APPLIED_CUSTOMER_TRX_ID,
	arr_APPLIED_CUST_TRX_LINE_ID,
	arr_APPLIED_PAYMENT_SCH_ID,
	arr_CUSTOMER_TRX_ID,
	arr_LINE_APPLIED,
	arr_TAX_APPLIED,
	arr_FREIGHT_APPLIED,
	arr_RECEIVABLES_CHARGES_APPD,
	arr_ON_ACCOUNT_CUSTOMER,
	arr_RECEIVABLES_TRX_ID,
	arr_EARNED_DISCOUNT_TAKEN,
	arr_UNEARNED_DISCOUNT_TAKEN,
	arr_DAYS_LATE,
	arr_APPLICATION_RULE,
	arr_GL_POSTED_DATE,
	arr_COMMENTS,
	arr_POSTABLE,
	arr_POSTING_CONTROL_ID,
	arr_ACCTD_AMOUNT_APPLIED_FROM,
	arr_ACCTD_AMOUNT_APPLIED_TO,
	arr_ACCTD_EARNED_DISC_TAKEN,
	arr_CONFIRMED_FLAG,
	arr_PROGRAM_APPLICATION_ID,
	arr_PROGRAM_ID,
	arr_PROGRAM_UPDATE_DATE,
	arr_REQUEST_ID,
	arr_EARNED_DISCOUNT_CCID,
	arr_UNEARNED_DISCOUNT_CCID,
	arr_ACCTD_UNEARNED_DISC_TAKEN,
	arr_REVERSAL_GL_DATE,
	arr_REVERSAL_GL_DATE_CONTEXT,
	arr_CASH_RECEIPT_HISTORY_ID;


	if cur_get_payment_details%NOTFOUND
	then
		error_status := 100;
		close cur_get_payment_details;
	end if;

	if row_to_fetch = 1 and cur_get_payment_details%ISOPEN
	then
		close cur_get_payment_details;
	end if;

	EXCEPTION

		when others then
		error_status := SQLCODE;
END get_payment_details;
END GMF_AR_GET_PAYMENT_DETAILS;

/