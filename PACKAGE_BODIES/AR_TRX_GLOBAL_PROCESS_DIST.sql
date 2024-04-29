--------------------------------------------------------
--  DDL for Package Body AR_TRX_GLOBAL_PROCESS_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_GLOBAL_PROCESS_DIST" AS
/* $Header: ARINGTDB.pls 120.3 2005/06/14 19:04:14 vcrisost noship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE INSERT_ROW (
        p_trx_dist_tbl         IN      AR_INVOICE_API_PUB.trx_dist_tbl_type,
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2
    ) IS

        RecExist            NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_GLOBAL_PROCESS_DIST.INSERT_ROW (+)');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Now populate the lines global Temp. Table
    -- First check whether there are any records in the pl/sql table

    RecExist := p_trx_dist_tbl.FIRST;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Record Count ' || RecExist);
    END IF;
    IF RecExist >= 1
    THEN
    FOR i IN  p_trx_dist_tbl.FIRST .. p_trx_dist_tbl.LAST
    LOOP
        INSERT INTO ar_trx_dist_gt (
            trx_dist_ID	                    ,
	    trx_header_id		    ,
            trx_LINE_ID	                    ,
            ACCOUNT_CLASS	                ,
            AMOUNT	                        ,
            acctd_amount                    ,
            PERCENT	                        ,
            CODE_COMBINATION_ID	            ,
            CREATED_BY	                    ,
            CREATION_DATE	                ,
            LAST_UPDATED_BY	                ,
            LAST_UPDATE_DATE	            ,
            LAST_UPDATE_LOGIN	            ,
            CUST_TRX_LINE_SALESREP_ID	    ,
	    process_flag		    ,
            ATTRIBUTE_CATEGORY	            ,
            ATTRIBUTE1	                    ,
            ATTRIBUTE2	                    ,
            ATTRIBUTE3	                    ,
            ATTRIBUTE4	                    ,
            ATTRIBUTE5	                    ,
            ATTRIBUTE6	                    ,
            ATTRIBUTE7	                    ,
            ATTRIBUTE8	                    ,
            ATTRIBUTE9	                    ,
            ATTRIBUTE10	                    ,
            ATTRIBUTE11	                    ,
            ATTRIBUTE12	                    ,
            ATTRIBUTE13	                    ,
            ATTRIBUTE14	                    ,
            ATTRIBUTE15	                    ,
            COMMENTS	                    ,
            ORG_ID)
             VALUES
            ( p_trx_dist_tbl(i).trx_dist_ID,
             p_trx_dist_tbl(i).trx_header_ID,
            p_trx_dist_tbl(i).trx_LINE_ID,
            p_trx_dist_tbl(i).ACCOUNT_CLASS,
            p_trx_dist_tbl(i).AMOUNT	                        ,
            p_trx_dist_tbl(i).acctd_amount                    ,
            p_trx_dist_tbl(i).PERCENT	                        ,
            p_trx_dist_tbl(i).CODE_COMBINATION_ID	            ,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.login_id,
            null, -- p_trx_dist_tbl(i).CUST_TRX_LINE_SALESREP_ID    ,
	    'N',  -- process_flag
            p_trx_dist_tbl(i).ATTRIBUTE_CATEGORY	            ,
            p_trx_dist_tbl(i).ATTRIBUTE1	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE2	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE3	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE4	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE5	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE6	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE7	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE8	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE9	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE10	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE11	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE12	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE13	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE14	                    ,
            p_trx_dist_tbl(i).ATTRIBUTE15	                    ,
            p_trx_dist_tbl(i).COMMENTS	                            ,
            arp_standard.sysparm.org_id);
        END LOOP;
    END IF;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_GLOBAL_PROCESS_DIST.INSERT_ROW (-)');
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_TRX_GLOBAL_PROCESS_DIST.INSERT_ROW '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
END INSERT_ROW;

END AR_TRX_GLOBAL_PROCESS_DIST;

/
