--------------------------------------------------------
--  DDL for Package Body AR_TRX_BULK_PROCESS_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_BULK_PROCESS_DIST" AS
/* $Header: ARINBLDB.pls 120.6 2006/07/10 21:13:18 apandit noship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE val_tax_from_revenue (
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2 ) IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('val_tax_from_revenue (+)');
    END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF pg_debug = 'Y'
   THEN
     ar_invoice_utils.debug ('val_tax_from_revenue (-)');
   END IF;

END val_tax_from_revenue;

PROCEDURE INSERT_ROW (
        p_trx_dist_id         IN      NUMBER,
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2 ) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('INSERT_ROW (+)');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ra_cust_trx_line_gl_dist (
            CUST_TRX_LINE_GL_DIST_ID        ,
            customer_trx_line_id            ,
            ACCOUNT_CLASS	                ,
            AMOUNT	                        ,
            acctd_amount                    ,
            PERCENT	                        ,
            REQUEST_ID                      ,
            CODE_COMBINATION_ID	            ,
            CREATED_BY	                    ,
            CREATION_DATE	                ,
            LAST_UPDATED_BY	                ,
            LAST_UPDATE_DATE	            ,
            LAST_UPDATE_LOGIN	            ,
            set_of_books_id                 ,
            gl_date                         ,
            gl_posted_date                  ,
            customer_trx_id                 ,
            CUST_TRX_LINE_SALESREP_ID	    ,
            account_set_flag                ,
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
            COMMENTS                        ,
	    org_id	                    ,
            ussgl_transaction_code          )
            SELECT RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL,
                   d.customer_trx_line_id            ,
                   d.ACCOUNT_CLASS	                ,
                   d.AMOUNT	                        ,
                   d.acctd_amount,
                   d.PERCENT	                        ,
                   d.REQUEST_ID	                    ,
                   d.CODE_COMBINATION_ID	            ,
                   d.CREATED_BY	                    ,
                   d.CREATION_DATE	                ,
                   d.LAST_UPDATED_BY	                ,
                   d.LAST_UPDATE_DATE	            ,
                   d.LAST_UPDATE_LOGIN	            ,
                   d.set_of_books_id                 ,
                   trunc(d.gl_date)                         ,
                   d.gl_posted_date                  ,
                   d.customer_trx_id                 ,
                   d.CUST_TRX_LINE_SALESREP_ID	    ,
                   d.account_set_flag                 ,
                   d.ATTRIBUTE_CATEGORY	            ,
                   d.ATTRIBUTE1	                    ,
                   d.ATTRIBUTE2	                    ,
                   d.ATTRIBUTE3	                    ,
                   d.ATTRIBUTE4	                    ,
                   d.ATTRIBUTE5	                    ,
                   d.ATTRIBUTE6	                    ,
                   d.ATTRIBUTE7	                    ,
                   d.ATTRIBUTE8	                    ,
                   d.ATTRIBUTE9	                    ,
                   d.ATTRIBUTE10	                    ,
                   d.ATTRIBUTE11	                    ,
                   d.ATTRIBUTE12	                    ,
                   d.ATTRIBUTE13	                    ,
                   d.ATTRIBUTE14	                    ,
                   d.ATTRIBUTE15	                    ,
                   d.COMMENTS,
		   arp_standard.sysparm.org_id,
                   decode(nvl(d.trx_line_id,-999), -999,  h.default_ussgl_transaction_code,
                                decode(l.default_ussgl_transaction_code, null,
                                h.default_ussgl_transaction_code,
                                l.default_ussgl_transaction_code )
                          )
          FROM ar_trx_dist_gt d,
               ar_trx_header_gt h,
               ar_trx_lines_gt l
          WHERE  d.trx_line_id = l.trx_line_id(+)
           and   d.trx_header_id = h.trx_header_id
           AND   d.trx_header_ID NOT IN ( SELECT trx_header_id from
                                      ar_trx_errors_gt )
           AND   d.trx_dist_id = nvl(p_trx_dist_id, trx_dist_id)
	       AND   d.process_flag = 'N';

          UPDATE ar_trx_dist_gt
          SET    process_flag = 'Y'
          WHERE  trx_dist_id = nvl(p_trx_dist_id, trx_dist_id)
          AND    process_flag = 'N'
          AND    trx_header_ID NOT IN
                 ( SELECT trx_header_id
                   FROM ar_trx_errors_gt );

          IF pg_debug = 'Y' THEN
            ar_invoice_utils.debug('Rows Updated: ' || SQL%ROWCOUNT);
          END IF;

       /*----------------------------------------------------+
        |  Validate tax from revenue account.                |
        +----------------------------------------------------*/
      val_tax_from_revenue (
        x_errmsg            =>  x_errmsg,
        x_return_status     =>  x_return_status );
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        return;
      END IF;
      IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('INSERT_ROW (-)');
    END IF;

    EXCEPTION
       WHEN OTHERS THEN
                x_errmsg := 'Error in AR_TRX_BULK_PROCESS_DIST.INSER_ROW '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
END INSERT_ROW;

END AR_TRX_BULK_PROCESS_DIST;

/
