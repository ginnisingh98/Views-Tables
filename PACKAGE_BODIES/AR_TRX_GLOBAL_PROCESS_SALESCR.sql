--------------------------------------------------------
--  DDL for Package Body AR_TRX_GLOBAL_PROCESS_SALESCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_GLOBAL_PROCESS_SALESCR" AS
/* $Header: ARINGTSB.pls 120.3 2005/06/14 19:05:06 vcrisost noship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE INSERT_ROW (
        p_trx_salescredits_tbl         IN      AR_INVOICE_API_PUB.trx_salescredits_tbl_type,
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2
 ) IS

        RecExist            NUMBER;
BEGIN

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_GLOBAL_PROCESS_SALESCR.INSERT_ROW (+)');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Now populate the lines global Temp. Table
    -- Now populate the lines global Temp. Table
    -- First check whether there are any records in the pl/sql table
    RecExist := p_trx_salescredits_tbl.FIRST;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Record Count ' || RecExist);
    END IF;
    IF RecExist >= 1
    THEN
    FOR i IN  p_trx_salescredits_tbl.FIRST .. p_trx_salescredits_tbl.LAST
    LOOP
        INSERT INTO ar_trx_salescredits_gt (
            trx_salescredit_id,
            trx_line_id,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            SALESREP_ID,
            SALESREP_NUM,
            SALES_CREDIT_TYPE_NAME,
            SALES_CREDIT_TYPE_ID,
            REVENUE_AMOUNT_SPLIT,
            REVENUE_PERCENT_SPLIT,
            NON_REVENUE_AMOUNT_SPLIT,
            NON_REVENUE_PERCENT_SPLIT,
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
            ATTRIBUTE15,
            ORG_ID)
             VALUES (
            p_trx_salescredits_tbl(i).trx_salescredit_id,
            p_trx_salescredits_tbl(i).trx_line_id,
            sysdate, -- LAST_UPDATE_DATE,
            fnd_global.user_id, -- last_updated_by
            sysdate, --CREATION_DATE,
            fnd_global.user_id,-- CREATED_BY,
            fnd_global.login_id, --LAST_UPDATE_LOGIN,
            p_trx_salescredits_tbl(i).SALESREP_ID,
            p_trx_salescredits_tbl(i).SALESREP_NUMBER,
            p_trx_salescredits_tbl(i).SALES_CREDIT_TYPE_NAME,
            p_trx_salescredits_tbl(i).SALES_CREDIT_TYPE_ID,
            -- revenue
            DECODE(p_trx_salescredits_tbl(i).sales_credit_type_id, 1,
              p_trx_salescredits_tbl(i).salescredit_amount_split, NULL),
            DECODE(p_trx_salescredits_tbl(i).sales_credit_type_id, 1,
              p_trx_salescredits_tbl(i).salescredit_percent_split, NULL),
            -- non revenue
            DECODE(p_trx_salescredits_tbl(i).sales_credit_type_id, 2,
              p_trx_salescredits_tbl(i).salescredit_amount_split, NULL),
            DECODE(p_trx_salescredits_tbl(i).sales_credit_type_id, 2,
              p_trx_salescredits_tbl(i).salescredit_percent_split, NULL),
            p_trx_salescredits_tbl(i).ATTRIBUTE_CATEGORY,
            p_trx_salescredits_tbl(i).ATTRIBUTE1,
            p_trx_salescredits_tbl(i).ATTRIBUTE2,
            p_trx_salescredits_tbl(i).ATTRIBUTE3,
            p_trx_salescredits_tbl(i).ATTRIBUTE4,
            p_trx_salescredits_tbl(i).ATTRIBUTE5,
            p_trx_salescredits_tbl(i).ATTRIBUTE6,
            p_trx_salescredits_tbl(i).ATTRIBUTE7,
            p_trx_salescredits_tbl(i).ATTRIBUTE8,
            p_trx_salescredits_tbl(i).ATTRIBUTE9,
            p_trx_salescredits_tbl(i).ATTRIBUTE10,
            p_trx_salescredits_tbl(i).ATTRIBUTE11,
            p_trx_salescredits_tbl(i).ATTRIBUTE12,
            p_trx_salescredits_tbl(i).ATTRIBUTE13,
            p_trx_salescredits_tbl(i).ATTRIBUTE14,
            p_trx_salescredits_tbl(i).ATTRIBUTE15,
            arp_standard.sysparm.org_id);


    END LOOP;
    END IF;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_GLOBAL_PROCESS_SALESCR.INSERT_ROW (-)');
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_TRX_GLOBAL_PROCESS_SALESCR.INSERT_ROW '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
END INSERT_ROW;

END AR_TRX_GLOBAL_PROCESS_SALESCR;

/
