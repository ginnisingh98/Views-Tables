--------------------------------------------------------
--  DDL for Package Body AR_TRX_BULK_PROCESS_SALESCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_BULK_PROCESS_SALESCR" AS
/* $Header: ARINBLSB.pls 120.3 2004/02/28 00:02:36 anukumar noship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE INSERT_ROW (
        p_trx_salescredit_id         IN      NUMBER,
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2 ) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_BULK_PROCESS_SALESCR.INSERT_ROW (+)');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    INSERT INTO RA_CUST_TRX_LINE_SALESREPS (
            CUST_TRX_LINE_SALESREP_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            SALESREP_ID,
            CUSTOMER_TRX_ID,
            CUSTOMER_TRX_LINE_ID,
            REVENUE_AMOUNT_SPLIT,
            REVENUE_PERCENT_SPLIT,
            NON_REVENUE_AMOUNT_SPLIT,
            NON_REVENUE_PERCENT_SPLIT,
            request_id,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,org_id)
            SELECT
            RA_CUST_TRX_LINE_SALESREPS_S.NEXTVAL,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            SALESREP_ID,
            CUSTOMER_TRX_ID,
            CUSTOMER_TRX_LINE_ID,
            REVENUE_AMOUNT_SPLIT,
            REVENUE_PERCENT_SPLIT,
            NON_REVENUE_AMOUNT_SPLIT,
            NON_REVENUE_PERCENT_SPLIT,
            request_id,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,arp_standard.sysparm.org_id
            FROM ar_trx_salescredits_gt
            WHERE trx_header_id NOT IN (
                                SELECT trx_header_id
                                from   ar_trx_errors_gt );


            -- run_auto_accounting;

            -- need to code the similar to distributiosn. valdate_rev
        IF pg_debug = 'Y'
        THEN
            ar_invoice_utils.debug ('AR_TRX_BULK_PROCESS_SALESCR.INSERT_ROW (-)');
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_TRX_BULK_PROCESS_SALESCR.INSERT_ROW'||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;

END INSERT_ROW;

END AR_TRX_BULK_PROCESS_SALESCR;

/
