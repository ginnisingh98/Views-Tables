--------------------------------------------------------
--  DDL for Package Body AR_INVOICE_TABLE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INVOICE_TABLE_HANDLER" AS
/* $Header: ARXVINTB.pls 120.28.12010000.9 2010/07/06 12:27:36 npanchak ship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE generate_default_salescredit(
        p_cust_trx_id           IN          NUMBER,
        p_cust_trx_line_id      IN          NUMBER,
        p_trx_lines_rec         IN          ar_trx_lines_gt%rowtype,
        x_errmsg                OUT NOCOPY  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2 ) IS

        l_status1               VARCHAR2(2000);
        l_cnt                   NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('generate_default_salescredit (+)');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- check whether user has passed any sales credit for this line
    BEGIN
        SELECT COUNT(*)
        INTO   l_cnt
        FROM   ar_trx_salescredits_gt
        WHERE  trx_line_id = (
                SELECT trx_line_id
                FROM   ar_trx_lines_gt
                WHERE  customer_trx_line_id = p_cust_trx_line_id);

        IF l_cnt = 0  -- means user has not passed saleccredit
        THEN
            arp_process_salescredit.create_line_salescredits(
                                p_cust_trx_id,
                                p_cust_trx_line_id,
                                null, --p_memo_line_type,
                                'N', -- p_delete_scredits_first_flag
                                'N', -- p_run_autoaccounting_flag
                                l_status1 );
            IF l_status1 <> 'OK'
            THEN
                x_errmsg  := l_status1;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
            END IF;
        END IF;
    END;

    EXCEPTION
        WHEN OTHERS THEN
              x_errmsg := 'Error in AR_INVOICE_TABLE_HANDLER.generate_default_salescredit '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;


END;
PROCEDURE INSERT_TRX_HEADER (
    ar_trx_header_rec          IN           ar_trx_header_gt%rowtype,
    p_batch_id                 IN           NUMBER DEFAULT NULL,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2)
 IS
    l_ct_reference              ra_customer_trx.ct_reference%type;
    l_trx_number                ra_customer_trx.trx_number%type;
    l_org_id                    NUMBER;
    l_org_str                   VARCHAR2(30);
    l_trx_str                   VARCHAR2(2000);
    l_copy_doc_number_flag      varchar2(1):='N';
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_TRX_HEADER(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    /* 5921925 - removed trx_number sequence from here.  Moved it to
         ar_invoice_utils.populate_doc_sequence */

    -- call table handler to insert into ra_customer_trx
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Before calling AR_TRX_BULK_PROCESS_HEADER.insert_row (+)' );
    END IF;

    AR_TRX_BULK_PROCESS_HEADER.insert_row(
            p_trx_header_id  => ar_trx_header_rec.trx_header_id,
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        return;
    END IF;

    ar_invoice_api_pub.g_api_outputs.batch_id := p_batch_id;

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Before calling AR_TRX_BULK_PROCESS_HEADER.insert_row (-)' );
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_TRX_HEADER(-)' );
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_TABLE_HANDLER.INSERT_TRX_HEADER '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
END;

PROCEDURE INSERT_TRX_LINES (
        ar_trx_lines_rec                IN  ar_trx_lines_gt%rowtype,
        p_cust_trx_id                   IN  NUMBER,
        p_batch_id                      NUMBER DEFAULT NULL,
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_TRX_LINES(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call table handler to insert into ra_customer_trx
    AR_TRX_BULK_PROCESS_LINES.insert_row(
            p_trx_header_id => ar_trx_lines_rec.trx_header_id,
            p_trx_line_id   => ar_trx_lines_rec.trx_line_id,
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
         return;
    END IF;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_TRX_LINES(-)' );
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_TABLE_HANDLER.INSERT_TRX_LINES '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
END;


PROCEDURE INSERT_TRX_DIST (
    p_trx_dist_id           IN      NUMBER  DEFAULT NULL,
    p_batch_id              IN      NUMBER  DEFAULT NULL,
    x_errmsg                OUT NOCOPY  VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2)  IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_TRX_DIST(+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    AR_TRX_BULK_PROCESS_DIST.INSERT_ROW (
            p_trx_dist_id => p_trx_dist_id,
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
         return;
    END IF;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_TRX_DIST(-)' );
    END IF;

    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_TABLE_HANDLER.INSERT_TRX_DIST '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;

END INSERT_TRX_DIST;

PROCEDURE INSERT_TRX_SALESCR (
    p_trx_salescredit_id    IN      NUMBER  DEFAULT NULL,
    p_batch_id              IN      NUMBER  DEFAULT NULL,
    x_errmsg                OUT NOCOPY  VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2)  IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_SALESCR(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    UPDATE ar_trx_salescredits_gt
        SET request_id = -(p_batch_id);

    AR_TRX_BULK_PROCESS_SALESCR.INSERT_ROW (
            p_trx_salescredit_id => p_trx_salescredit_id,
            x_errmsg            =>  x_errmsg,
            x_return_status     =>  x_return_status );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
         return;
    END IF;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.INSERT_SALESCR(-)' );
    END IF;

    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_TABLE_HANDLER.INSERT_TRX_SALESCR '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;
END INSERT_TRX_SALESCR;


PROCEDURE create_batch(
    p_trx_system_parameters_rec     IN      AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    p_trx_profile_rec               IN      AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
    p_batch_source_rec              IN      AR_INVOICE_API_PUB.batch_source_rec_type,
    p_batch_id                      OUT NOCOPY NUMBER,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2 ) IS

    l_cnt           NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.create_batch(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO RA_BATCHES
    (
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            BATCH_ID,
            request_id,
            NAME,
            BATCH_DATE,
            GL_DATE,
            TYPE,
            BATCH_SOURCE_ID,
            SET_OF_BOOKS_ID
            ,org_id
        )
        values (
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.login_id,
            fnd_global.prog_appl_id,
            null,
            sysdate,
            RA_BATCHES_S.NEXTVAL,
            -(RA_BATCHES_S.currval),
            'AR_INVOICE_API'||'_'||RA_BATCHES_S.currval,
            sysdate,
            trunc(nvl(p_batch_source_rec.default_date,trunc(sysdate))),
            'INV',
            nvl(p_batch_source_rec.batch_source_id, p_trx_profile_rec.ar_ra_batch_source),
            p_trx_system_parameters_rec.set_of_books_id
            ,arp_standard.sysparm.org_id)
        returning batch_id INTO p_batch_id;

        g_batch_id := p_batch_id;
        g_request_id := -1 * p_batch_id;

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Batch Id :'|| p_batch_id );
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.create_batch(-)' );
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_TABLE_HANDLER.CREATE_BATCH '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;

END;

/* 4188835 - This routine is obsolete.  For tax purposes, the invoice API
   is now aligned with autoinvoice (bulk calls and batch processes) rather
   than the trx workbench (individual calls) for performance reasons. */

PROCEDURE GET_DEFAULT_TAX_CODE (
        ar_trx_header_rec               IN          ar_trx_header_gt%rowtype,
        ar_trx_lines_rec                IN          ar_trx_lines_gt%rowtype,
        p_vat_tax_id                    OUT NOCOPY  NUMBER,
        p_amt_incl_tax_flag             OUT NOCOPY  VARCHAR2,
        x_errmsg                        OUT NOCOPY  VARCHAR2,
        x_return_status                 OUT NOCOPY  VARCHAR2 ) AS

        l_tax_code                      ar_vat_tax.tax_code%type;
        l_amt_incl_tax_override         ar_vat_tax.amount_includes_tax_override%type;
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.GET_DEFAULT_TAX_CODE(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Ship to site use Id :' || ar_trx_header_rec.ship_to_site_use_id);
        ar_invoice_utils.debug ('Bill to site use Id :' || ar_trx_header_rec.bill_to_site_use_id);
        ar_invoice_utils.debug ('Inventory Item Id :' || ar_trx_lines_rec.inventory_item_id);
        ar_invoice_utils.debug ('Org Id :' || ar_trx_header_rec.org_id);
        ar_invoice_utils.debug ('SOB Id :' || ar_trx_header_rec.set_of_books_id);
        ar_invoice_utils.debug ('Ware House Id :' || ar_trx_lines_rec.warehouse_id);
        ar_invoice_utils.debug ('trx date :' || ar_trx_header_rec.trx_date);
        ar_invoice_utils.debug ('trx type id :' || ar_trx_header_rec.cust_trx_type_id);
        ar_invoice_utils.debug ('memo line id :' || ar_trx_lines_rec.memo_line_id);
    END IF;

    /* 4188835 - defaulting code removed */

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.GET_DEFAULT_TAX_CODE(-)' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
             x_errmsg := 'Error during default Tax Code';
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
             return;
END GET_DEFAULT_TAX_CODE;

PROCEDURE populate_error_stack (
        p_trx_header_id             NUMBER,
        p_trx_line_id               NUMBER      default NULL,
        p_trx_dist_id               NUMBER      default NULL,
        p_trx_salescredit_id        NUMBER      default NULL,
        p_error_message             VARCHAR2    default NULL,
        p_invalid_value             VARCHAR2    default NULL) AS
BEGIN

    INSERT INTO ar_trx_errors_gt (
                    trx_header_id,
                    trx_line_id,
                    trx_dist_id,
                    trx_salescredit_id,
                    error_message,
                    invalid_value)
     VALUES
                    ( p_trx_header_id,
                      p_trx_line_id,
                      p_trx_dist_id,
                      p_trx_salescredit_id,
                      p_error_message,
                      p_invalid_value);

END populate_error_stack;

PROCEDURE cleanup (
        p_customer_trx_id       IN      NUMBER ) AS

        l_ret_stat          NUMBER;
BEGIN

        arp_etax_invapi_util.cleanup_tax(p_customer_trx_id);

        delete from ra_customer_trx where customer_trx_id = p_customer_trx_id;
        delete from ra_customer_trx_lines where customer_trx_id = p_customer_trx_id;
        delete from ra_cust_trx_line_gl_dist where customer_trx_id = p_customer_trx_id;
        delete from ar_payment_schedules where customer_trx_id = p_customer_trx_id;
        delete from RA_CUST_TRX_LINE_SALESREPS where customer_trx_id = p_customer_trx_id;

END;

PROCEDURE cleanup_all AS
        l_ret_stat          NUMBER;

        CURSOR c_failed_trx IS
           SELECT ct.customer_trx_id
           FROM   ra_customer_trx      ct
           WHERE
               EXISTS (SELECT 'error'
                       FROM   ar_trx_errors_gt err,
                              ar_trx_header_gt head
                       WHERE  err.trx_header_id = head.trx_header_id
                       AND    head.customer_trx_id = ct.customer_trx_id);

BEGIN
     /* Get the tax audit tables */
     FOR c_bad IN c_failed_trx LOOP
         arp_etax_invapi_util.cleanup_tax(c_bad.customer_trx_id);
     END LOOP;

     /* Delete everything else */
        delete from ra_customer_trx
        where customer_trx_id in (
          select distinct th.customer_trx_id
          from   ar_trx_errors_gt err,
                 ar_trx_header_gt th
          where  err.trx_header_id = th.trx_header_id);

        delete from ra_customer_trx_lines
        where customer_trx_id in (
          select distinct th.customer_trx_id
          from   ar_trx_errors_gt err,
                 ar_trx_header_gt th
          where  err.trx_header_id = th.trx_header_id);

        delete from ra_cust_trx_line_gl_dist
        where customer_trx_id in (
          select distinct th.customer_trx_id
          from   ar_trx_errors_gt err,
                 ar_trx_header_gt th
          where  err.trx_header_id = th.trx_header_id);

        delete from ar_payment_schedules
        where customer_trx_id in (
          select distinct th.customer_trx_id
          from   ar_trx_errors_gt err,
                 ar_trx_header_gt th
          where  err.trx_header_id = th.trx_header_id);

        delete from RA_CUST_TRX_LINE_SALESREPS
        where customer_trx_id in (
          select distinct th.customer_trx_id
          from   ar_trx_errors_gt err,
                 ar_trx_header_gt th
          where  err.trx_header_id = th.trx_header_id);

END;


PROCEDURE INSERT_ROW(
        p_trx_system_parameters_rec     IN      AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
        p_trx_profile_rec               IN      AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
        p_batch_source_rec              IN      AR_INVOICE_API_PUB.batch_source_rec_type,
        x_errmsg                        OUT NOCOPY  VARCHAR2,
        x_return_status                 OUT NOCOPY  VARCHAR2)   AS

l_cust_trx_id       NUMBER;
l_cnt               NUMBER;
l_ccid              number;
l_concat_segments   varchar2(2000);
l_status2           varchar2(2000);
l_num_failed_dist_rows  number;
l_revenue_amount    number;
l_trx_header_id     number;
l_customer_trx_line_id number;
l_new_tax_amount       number;
l_link_to_cust_trx_line_id  number;
l_gross_extended_amount number;
l_gross_unit_selling_price number;
l_recalculate_tax_flag   boolean;
l_status1                varchar2(100);
l_status                 varchar2(100);
l_tax_line_rec           ra_customer_trx_lines%rowtype;
l_freight_line_rec       ra_customer_trx_lines%rowtype;
l_ct_reference          ra_customer_trx.ct_reference%type;
l_requery_tax_if_visible boolean;
l_batch_id             NUMBER;
lc_request_id           VARCHAR2(40);
l_rec_dist_exist        VARCHAR2(1) := 'N';
l_tax_error_flag        VARCHAR2(1) := 'N';
l_result                VARCHAR2(1);
l_ok_to_call_tax        VARCHAR2(1);
l_vat_tax_id            ar_vat_tax.vat_tax_id%type;
l_amt_incl_tax_flag     ar_vat_tax.amount_includes_tax_flag%type;
l_num_failed_rows       NUMBER;
l_etax_error_count           NUMBER := 0;

/* 5921925 */
l_scredit_count         NUMBER;
l_dist_count            NUMBER;
l_error_message         FND_NEW_MESSAGES.message_text%type;
l_error_count           NUMBER;
l_commitment_amt        NUMBER;
l_prev_cust_old_state AR_BUS_EVENT_COVER.prev_cust_old_state_tab;
/* end 5921925 */
/* BR Sped Project */
l_jgzz_product_code VARCHAR2(100);
lcursor  NUMBER;
lignore  NUMBER;
sqlstmt  VARCHAR2(254);
l_return_value_gdf NUMBER;
/* BR Sped Project */
/* Added for Bug 8731646  */
  l_amount number;
  l_creation_sign varchar2(10);
/* End  Bug 8731646  */


/*7829636*/
l_request_id NUMBER;

l_return_status         NUMBER;

l_called_from		varchar2(30);

AR_TAX_EXCEPTION        EXCEPTION;
TAX_NO_RATE             EXCEPTION;
TAX_NO_CODE             EXCEPTION;
TAX_NO_AMOUNT           EXCEPTION;
TAX_NO_PRECISION        EXCEPTION;
TAX_NO_DATA             EXCEPTION;
TAX_NEED_POSTAL         EXCEPTION;
TAX_CODE_INACTIVE       EXCEPTION;
TAX_BAD_DATA            EXCEPTION;
TAX_OERR                EXCEPTION;

CURSOR ar_trx_header_c IS
    SELECT * FROM ar_trx_header_gt gt
    WHERE NOT EXISTS ( SELECT 'X' FROM
                       ar_trx_errors_gt err
                       WHERE err.trx_header_id = gt.trx_header_id);

CURSOR ar_trx_lines_c IS
    SELECT * FROM ar_trx_lines_gt gt
    WHERE  trx_header_id = l_trx_header_id
    order by trx_header_id, trx_line_id, line_number;

CURSOR ar_trx_dist_c IS
    SELECT * FROM ar_trx_dist_gt
       where trx_header_id = l_trx_header_id
       AND   account_class = 'REC'
       AND   process_flag = 'N';

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_TABLE_HANDLER.insert_row(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_batch_id := g_batch_id;

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Batch Id '|| l_batch_id );
    END IF;
    -- This is for mrc call. which takes varchar2.
    lc_request_id := g_request_id;
    -- Also assign the global variable in auto_accounting package so that it does
    -- not call mrc engine from auto_accounting.
    l_called_from	:= ARP_AUTO_ACCOUNTING.g_called_from;
    ARP_AUTO_ACCOUNTING.g_called_from := 'AR_INVOICE_API';

    FOR ar_trx_header_rec IN ar_trx_header_c
    LOOP
        l_tax_error_flag := 'N';
        l_trx_header_id :=  ar_trx_header_rec.trx_header_id;
        l_cust_trx_id := ar_trx_header_rec.customer_trx_id;

        -- populate g_customer_trx_id. This is out parameter
        -- in case the API is called for a singel invoice. Otherwise
        -- the latest value will be stored in this global value.
        AR_INVOICE_API_PUB.g_customer_trx_id := ar_trx_header_rec.customer_trx_id;

        IF pg_debug = 'Y'
        THEN
            ar_invoice_utils.debug ('In Header Loop' );
            ar_invoice_utils.debug ('Trx Header Id ' || l_trx_header_id );
            ar_invoice_utils.debug ('Cust Trx Id ' || l_cust_trx_id );
            ar_invoice_utils.debug ('calling insert_trx_header (+)' );
        END IF;

        insert_trx_header ( ar_trx_header_rec   => ar_trx_header_rec,
                            p_batch_id          => l_batch_id,
                            x_errmsg            =>  x_errmsg,
                            x_return_status     =>  x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
             return;
        END IF;

        IF pg_debug = 'Y'
        THEN
            ar_invoice_utils.debug ('calling insert_trx_header (-)' );
            ar_invoice_utils.debug ('calling auto accounting (+)' );
        END IF;

        /* 5921925 - Do not call insert unless there were dists rows */
        IF ar_invoice_api_pub.g_dist_exist
        THEN
           BEGIN
               FOR ar_trx_dist_rec IN ar_trx_dist_c
               LOOP
                   INSERT_TRX_DIST(
                   p_trx_dist_id     =>  ar_trx_dist_rec.trx_dist_id,
                   p_batch_id        =>  l_batch_id,
                   x_errmsg          =>  x_errmsg,
                   x_return_status   =>  x_return_status);

               END LOOP;
           END;
        END IF;

    -- Now insert lines
    FOR ar_trx_lines_rec IN ar_trx_lines_c
    LOOP
        IF pg_debug = 'Y'
        THEN
            ar_invoice_utils.debug ('In Lines Loop (+)' );
        END IF;

        IF  ar_trx_lines_rec.line_type in ('LINE','FREIGHT')
        THEN
            l_customer_trx_line_id := ar_trx_lines_rec.customer_trx_line_id;

            IF pg_debug = 'Y'
            THEN
                ar_invoice_utils.debug ('Line Type = LINE ' );
                ar_invoice_utils.debug ('Cust. Trx Line Id  '|| l_customer_trx_line_id );
                ar_invoice_utils.debug ('Calling insert_trx_lines (+)' );
            END IF;

            /* 4188835 - removed tax code defaulting logic */

            insert_trx_lines(ar_trx_lines_rec   => ar_trx_lines_rec,
                             p_cust_trx_id      => l_cust_trx_id,
                             p_batch_id         => l_batch_id,
                             x_errmsg            =>  x_errmsg,
                             x_return_status     =>  x_return_status);

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                 return;
            END IF;
            IF pg_debug = 'Y'
            THEN
                ar_invoice_utils.debug ('Calling insert_trx_lines (-)' );
            END IF;

            -- derive the GL and trx date if trx_class is not CM
            IF ( ( ar_trx_header_rec.trx_class <> 'CM' )
                AND
                ( ar_trx_lines_rec.accounting_rule_id IS NOT NULL )
               )
            THEN

                /*Bug 5884520 reevaluate gl date if gl date is not provided by user*/

                arp_dates.derive_gl_trx_dates_from_rules(
                                   l_cust_trx_id,
                                   ar_trx_header_rec.gl_date,
                                   ar_trx_header_rec.trx_date,
                                   l_recalculate_tax_flag);

		 UPDATE ar_trx_header_gt
		 SET gl_date = ar_trx_header_rec.gl_date
		 WHERE trx_header_id=ar_trx_header_rec.trx_header_id;

            END IF;
            IF  ar_trx_lines_rec.line_type = 'LINE'
            THEN
                -- Create Sales Credit
                IF pg_debug = 'Y'
                THEN
                    ar_invoice_utils.debug ('Calling sales credit (+)' );
                END IF;
                -- before defaulting check whether user has passed
                -- sales credit or not. If user has passed sales credit
                -- then don't default the sales credit.

                IF NOT ar_invoice_api_pub.g_sc_exist
                THEN
                   generate_default_salescredit(
                       p_cust_trx_id   =>  l_cust_trx_id,
                       p_cust_trx_line_id  => l_customer_trx_line_id,
                       p_trx_lines_rec     =>  ar_trx_lines_rec,
                       x_errmsg            =>  x_errmsg,
                       x_return_status     =>  x_return_status);
                END IF;

                IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN
                    return;
                END IF;
                IF pg_debug = 'Y'
                THEN
                    ar_invoice_utils.debug ('Calling sales credit (-)' );
                END IF;
            END IF;

            /* 4188835 - removed line-level call to
                 arp_process_tax.after_insert_line   */

                  IF ar_trx_lines_rec.line_type = 'FREIGHT' THEN
                    BEGIN

						/* Changes for Bug 5398561 starts. */
						DECLARE
						lv_ship_via		ar_trx_header_gt.ship_via%type;
						lv_ship_dt_actual	ar_trx_header_gt.ship_date_actual%type;
						BEGIN

						  IF  ar_trx_lines_rec.ship_date_actual is null
							THEN
							 select ship_via, ship_date_actual
							 into   lv_ship_via, lv_ship_dt_actual
							 from   ar_trx_header_gt
							 where  customer_trx_id = l_cust_trx_id;

							ar_trx_lines_rec.ship_via := lv_ship_via;
							ar_trx_lines_rec.ship_date_actual := lv_ship_dt_actual;
						  ELSE
							 select ship_via
							 into   lv_ship_via
							 from   ar_trx_header_gt
							 where  customer_trx_id = l_cust_trx_id;

							ar_trx_lines_rec.ship_via := lv_ship_via;
						  END IF;

						  EXCEPTION
						 WHEN OTHERS THEN
							 IF pg_debug = 'Y'
							 THEN
								 ar_invoice_utils.debug ('Error fetching ship_vi, ship_actual_date : ' ||sqlerrm );
							END IF;
						   END;
						/* Changes for Bug 5398561 ends. */


                     arp_process_header.update_header_freight_cover(
                       'AR_INVOICE_API',
                       1,
                       l_cust_trx_id,
                       'INV',
                       null,
                       ar_trx_lines_rec.ship_via,
                       ar_trx_lines_rec.ship_date_actual,
                       ar_trx_lines_rec.waybill_number,
                       ar_trx_lines_rec.fob_point,
                       l_status);

                    EXCEPTION
                      WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_errmsg :=
                          'arp_process_header.update_header_freight_cover '
                             || 'raised unexpected error!';
                      RETURN;
                    END;

                  END IF;
                  IF pg_debug = 'Y'
                  THEN
                        ar_invoice_utils.debug ('CC id '|| l_ccid);
                        ar_invoice_utils.debug ('Con cat segments '|| l_concat_segments);
                        ar_invoice_utils.debug ('No. of rows failed '|| l_num_failed_dist_rows);
                        ar_invoice_utils.debug ('Calling auto accounting for line  (-)' );
                  END IF;

        ELSIF ar_trx_lines_rec.line_type = 'TAX'
        THEN
            IF pg_debug = 'Y'
            THEN
                ar_invoice_utils.debug ('Line Type = TAX (+)' );
            END IF;

            /* 4188835 - Removed entire manual tax block.  This behavior
               is now handled in arp_etax_invapi_util.calculate_tax */

        END IF; -- end of if line_type = 'LINE'
        IF pg_debug = 'Y'
        THEN
               ar_invoice_utils.debug ('Line Type = LINE (-)' );
        END IF;
    END LOOP;

    IF l_tax_error_flag = 'Y'
    THEN
        GOTO main_loop;
    END IF;

    -- call distributions
    IF ar_invoice_api_pub.g_dist_exist
    THEN
       INSERT_TRX_DIST( p_trx_dist_id => null,
                        p_batch_id => l_batch_id,
                        x_errmsg            =>  x_errmsg,
                        x_return_status     =>  x_return_status );
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
         cleanup(p_customer_trx_id   => l_cust_trx_id);
         return;
       END IF;
    END IF;

    IF ar_invoice_api_pub.g_sc_exist
    THEN
       INSERT_TRX_SALESCR ( p_trx_salescredit_id => null,
                            p_batch_id => l_batch_id,
                            x_errmsg            =>  x_errmsg,
                            x_return_status     =>  x_return_status );

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
            cleanup(p_customer_trx_id   => l_cust_trx_id);
            return;
       END IF;
    END IF;

   <<main_loop>>
       NULL;
   END LOOP; /* End of Primary Loop */

   /* call autoaccounting for REC first -- needed by etax call below */
   IF pg_debug = 'Y'
   THEN
      ar_invoice_utils.debug('calling autoaccounting for REC');
   END IF;

   arp_auto_accounting.do_autoaccounting(
                                     'I',
                                     'REC',
                                     null,
                                     null,
                                     null,
                                     g_request_id , --req_id,
                                     null, --_gl_date,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     l_ccid,
                                     l_concat_segments,
                                     l_num_failed_dist_rows);

   IF pg_debug = 'Y'
   THEN
      ar_invoice_utils.debug('calling etax for entire API batch');
   END IF;

   arp_etax_invapi_util.calculate_tax(g_request_id, l_etax_error_count,
                                      l_return_status);

   /* 6743811 - raise error if etax returns an error (E or U) status
        the returned values are 0=success, 1=Error, 2=Unexpected Error */
   IF l_return_status > 0
   THEN
      arp_util.debug('EXCEPTION:  error calling eBusiness Tax, status = ' ||
                       l_return_status);
      arp_util.debug('Please review the plsql debug log for additional details.');
      APP_EXCEPTION.raise_exception;
   END IF;

   IF (nvl(l_etax_error_count, 0) > 0)
   THEN
      ar_invoice_utils.debug('EXCEPTION: etax error count = ' || l_etax_error_count);
   END IF;

  FOR ar_trx_header_rec IN ar_trx_header_c
    LOOP
          l_creation_sign :=ar_trx_header_rec.CREATION_SIGN;
          select sum(extended_amount) into l_amount
          from ra_customer_trx_lines
          where customer_trx_id=ar_trx_header_rec.CUSTOMER_TRX_ID;
          ar_invoice_utils.debug('l_creation_sign:'||l_creation_sign);
          ar_invoice_utils.debug('l_amount:'||l_amount);
          ar_invoice_utils.debug('CUSTOMER_TRX_ID:'||ar_trx_header_rec.CUSTOMER_TRX_ID);

          IF ( l_creation_sign = 'A' ) THEN
                 NULL;
          ELSIF ( l_creation_sign  = 'P' ) THEN
                 IF  (NVL( l_amount, 0 ) < 0) THEN
                   INSERT INTO ar_trx_errors_gt
                      ( trx_header_id,
                        error_message)
                   VALUES
                      ( ar_trx_header_rec.trx_header_id,
                        arp_standard.fnd_message('AR_INAPI_AMT_SIGN_INVALID'));
                        cleanup(p_customer_trx_id=>ar_trx_header_rec.CUSTOMER_TRX_ID);
                 END IF;
          ELSIF ( l_creation_sign = 'N' ) THEN
                 IF (NVL( l_amount, 0 ) > 0)   THEN
                   INSERT INTO ar_trx_errors_gt
                      ( trx_header_id,
                        error_message)
                   VALUES
                      ( ar_trx_header_rec.trx_header_id,
                        arp_standard.fnd_message('AR_INAPI_AMT_SIGN_INVALID'));
                   cleanup(p_customer_trx_id=>ar_trx_header_rec.CUSTOMER_TRX_ID);
                 END IF;
           END IF;
   end loop;

   IF pg_debug = 'Y'
   THEN
       ar_invoice_utils.debug ('calling autoaccounting for ALL (except REC)' );
   END IF;

   arp_auto_accounting.do_autoaccounting(
                                     'I',
                                     'ALL',
                                     null,
                                     null,
                                     null,
                                     g_request_id , --req_id,
                                     null, --_gl_date,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     l_ccid,
                                     l_concat_segments,
                                     l_num_failed_dist_rows);

    IF pg_debug = 'Y'
    THEN
       ar_invoice_utils.debug ('No. of Rows failed  ' || l_num_failed_dist_rows);
       ar_invoice_utils.debug ('returning from arp_auto_accounting.do_autoaccounting(-)' );
    END IF;

    IF l_num_failed_dist_rows > 0
       OR l_etax_error_count > 0
    THEN
      /* Clean up any transactions that encountered problems
         in autoaccounting (before calling MRC) */
      cleanup_all;

    END IF;

    -- call mrc engine
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('Calling MRC Engine (+)' );
        ar_invoice_utils.debug ('Request Id '|| to_char(g_request_id) );
    END IF;
    /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +--------------------------------- */
       ar_mrc_engine.mrc_bulk_process (
            p_request_id    =>  g_request_id,
            p_table_name    =>  'RAXTRX');
     IF pg_debug = 'Y'
     THEN
        ar_invoice_utils.debug ('Calling MRC Engine (-)' );
        ar_invoice_utils.debug ('callling post commit process with complete flag = Y(+)' );
     END IF;

     /* Second loop to do final completion tasks */
     FOR ar_trx_header_rec IN ar_trx_header_c
     LOOP

        IF pg_debug = 'Y'
        THEN
               ar_invoice_utils.debug ('set Term in use (+)' );
               ar_invoice_utils.debug ('Term Id '|| ar_trx_header_rec.term_id );
        END IF;

    arp_trx_util.set_term_in_use_flag(
                    p_form_name         => 'AR_INVOICE_API',
                    p_form_version      => 1,
                    p_term_id           => ar_trx_header_rec.term_id,
                    p_term_in_use_flag  => null);
        IF pg_debug = 'Y'
        THEN
               ar_invoice_utils.debug ('set Term in use (-)' );
               ar_invoice_utils.debug ('arp_global.request_id BEFORE CHANGES'||arp_global.request_id );
        END IF;

        /* 5921925 - Streamlined completion logic */
        BEGIN
        arp_rounding.correct_scredit_rounding_errs(ar_trx_header_rec.customer_trx_id,
                                                   l_scredit_count);
         /*7829636*/
         l_request_id := arp_global.request_id;

          /*8290034*/
         /*IF((arp_global.request_id IS NULL) AND (g_request_id IS NOT NULL)) THEN*/
         IF(g_request_id IS NOT NULL) THEN
         arp_global.request_id := g_request_id;
         END IF;

         ar_invoice_utils.debug ('arp_global.request_id AFTER CHANGES'||arp_global.request_id );

        IF  (arp_rounding.correct_dist_rounding_errors
                  (null,                   -- request_id
                   ar_trx_header_rec.customer_trx_id,
                   null,                   -- customer_trx_line_id
                   l_dist_count,
                   l_error_message,
                   p_trx_system_parameters_rec.precision,
                   p_trx_system_parameters_rec.minimum_accountable_unit,
                   'ALL',
                   'N',
                   null,                   -- debug_mode
                   p_trx_system_parameters_rec.trx_header_level_rounding,
                   'N'                     -- activity flag
                 ) = 0) -- FALSE
        THEN
           arp_util.debug('EXCEPTION:  ar_invoice_table_handler.insert_row()');
           arp_util.debug(l_error_message);
             fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');

           APP_EXCEPTION.raise_exception;
        END IF;

         /*7829636-Resetting arp_global.request_id*/
         arp_global.request_id := l_request_id;

        arp_trx_complete_chk.do_completion_checking(
                                            ar_trx_header_rec.customer_trx_id,
                                            NULL,
                                            NULL,
                                            NULL,
                                            l_error_count,
                                            'B'
                                          );

        IF (l_error_count > 0)
        THEN
           app_exception.raise_exception;
        END IF;

        arp_balance_check.check_transaction_balance(
           ar_trx_header_rec.customer_trx_id,'Y');

        IF ar_trx_header_rec.accounting_affect_flag = 'Y'
        THEN
           arp_maintain_ps.maintain_payment_schedules(
                'I',
                ar_trx_header_rec.customer_trx_id,
                NULL,   -- ps_id
                NULL,   -- line_amount
                NULL,   -- tax_amount
                NULL,   -- frt_amount
                NULL,   -- charge_amount
                l_commitment_amt,  -- out parameter, junk
                NULL);

          AR_BUS_EVENT_COVER.Raise_Trx_Creation_Event
                                 (ar_trx_header_rec.trx_class, -- trx_type.type
                                  ar_trx_header_rec.customer_trx_id,
                                  l_prev_cust_old_state);      -- structure

        END IF;

        /* Call JL for copying GDF Attributes to JL Tables. */
	l_jgzz_product_code := AR_GDF_VALIDATION.is_jg_installed;

	IF l_jgzz_product_code IS NOT NULL THEN
		/* JL_BR_SPED_PKG package is installed, so OK to call the package. */

		BEGIN

			lcursor := dbms_sql.open_cursor;
			sqlstmt :=
				'BEGIN :l_return_value_gdf := JL_BR_SPED_PKG.COPY_GDF_ATTRIBUTES_API(:p_customer_trx_id);
				END;';

			dbms_sql.parse(lcursor, sqlstmt, dbms_sql.native);
			dbms_sql.bind_variable(lcursor, ':p_customer_trx_id', ar_trx_header_rec.customer_trx_id);
			dbms_sql.bind_variable(lcursor, ':l_return_value_gdf', l_return_value_gdf);

			IF PG_DEBUG in ('Y', 'C') THEN
			arp_standard.debug('copy_gdf_attributes: Executing Statement: '||sqlstmt);
			END IF;

			lignore := dbms_sql.execute(lcursor);
			dbms_sql.close_cursor(lcursor);

		EXCEPTION
			WHEN OTHERS THEN
				IF PG_DEBUG in ('Y', 'C') THEN
					arp_standard.debug('copy_gdf_attributes: Exception calling BEGIN JL_BR_SPED_PKG.copy_gdf_attr_for_api.');
					arp_standard.debug('copy_gdf_attributes: ' || SQLERRM);
				END IF;

				IF dbms_sql.is_open(lcursor)
				THEN
					dbms_sql.close_cursor(lcursor);
				END IF;
		END;
	END IF;

	ARP_AUTO_ACCOUNTING.g_called_from := l_called_from;

    EXCEPTION
        WHEN OTHERS
            THEN
                cleanup(p_customer_trx_id   => l_cust_trx_id);
                x_errmsg := sqlerrm;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                INSERT INTO ar_trx_errors_gt (
                    trx_header_id,
                    error_message)
                    VALUES
                    ( ar_trx_header_rec.trx_header_id,
                      x_errmsg);
                RETURN;
        END;

    END LOOP; /* End of completion loop */

    IF pg_debug = 'Y'
        THEN
               ar_invoice_utils.debug ('Insert_row(-)' );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            cleanup(p_customer_trx_id   => l_cust_trx_id);
            x_errmsg   := 'Fatal Error' || sqlerrm;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            return;

END INSERT_ROW;

END AR_INVOICE_TABLE_HANDLER;

/
