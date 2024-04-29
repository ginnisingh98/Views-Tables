--------------------------------------------------------
--  DDL for Package Body AR_INVOICE_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INVOICE_API_PUB" AS
/* $Header: ARXPINVB.pls 120.26.12010000.3 2010/02/25 10:38:10 npanchak ship $ */

pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

g_one_time_init_org   number;
g_single_invoice boolean := FALSE;

PROCEDURE populate_header  (
    p_trx_header_tbl            IN          trx_header_tbl_type,
    p_trx_system_param_rec      IN          AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    p_trx_profile_rec           IN          AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
    p_batch_source_rec          IN          batch_source_rec_type,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_header(+)' );
    ar_invoice_utils.debug ('All Default Values ' );
    ar_invoice_utils.debug ('Set of Books Id '||
      p_trx_system_param_rec.set_of_books_id);
    ar_invoice_utils.debug ('Trx Currency '||
      p_trx_system_param_rec.base_currency_code);
    ar_invoice_utils.debug ('Batch Source '||
      p_trx_profile_rec.ar_ra_batch_source);
    ar_invoice_utils.debug ('GL Date '|| p_batch_source_rec.default_date);
    ar_invoice_utils.debug ('Exchange Rate Type '
       || p_trx_profile_rec.default_exchange_rate_type);
  END IF;

  -- First populate the global header table with the user parameter.
  ar_trx_global_process_header.insert_row(
    p_trx_header_tbl   => p_trx_header_tbl,
    p_batch_source_rec => p_batch_source_rec,
    x_errmsg           => x_errmsg,
    x_return_status    => x_return_status);

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RETURN;
  END IF;

   /* 5921925 - Removed defaulting UPDATE statement and integrated it
       into ar_trx_global_process_header.insert_row */

   IF pg_debug = 'Y' THEN
     ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_header(-)' );
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_API_PUB.populate_header '||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END;

PROCEDURE populate_lines  (
  p_trx_lines_tbl        trx_line_tbl_type,
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2) IS

  l_customer_trx_line_id          NUMBER;

  CURSOR clink IS
    SELECT customer_trx_line_id, link_to_trx_line_id, trx_line_id,
	   link_to_cust_trx_line_id
    FROM   ar_trx_lines_gt
    WHERE  link_to_trx_line_id IS NOT NULL
    AND    line_type in ( 'TAX', 'FREIGHT');

  CURSOR line (p_link_line_id NUMBER) IS
    SELECT customer_trx_line_id
    FROM   ar_trx_lines_gt
    WHERE  trx_line_id = p_link_line_id;

BEGIN

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_lines(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    AR_TRX_GLOBAL_PROCESS_LINES.INSERT_ROW(
            p_trx_lines_tbl     => p_trx_lines_tbl,
            x_errmsg            => x_errmsg,
            x_return_status    => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        return;
    END IF;

    -- check if there are any freight and tax lines and whether it is linked
    -- to any of the lines or not.
    -- need to do bulk enable

    /* 5921925 - considered rewriting this, but I don't see an easy way
       to do anything since both trx_id and trx_line_id are dynamically assigned
       in the GT inserts. */

    FOR clinkRec IN clink
    LOOP
        OPEN line(clinkRec.link_to_trx_line_id);
        FETCH line INTO l_customer_trx_line_id;
        CLOSE line;

        IF pg_debug = 'Y' THEN
          ar_invoice_utils.debug ('Cust Trx Line Id in Link Loop ' ||
            l_customer_trx_line_id);
          ar_invoice_utils.debug ('Link to  Line Id in Link Loop ' ||
            clinkRec.link_to_trx_line_id );
          ar_invoice_utils.debug ('Trx Line Id in Link Loop ' ||
            clinkRec.trx_line_id );
        END IF;

        UPDATE ar_trx_lines_gt gt
            set link_to_cust_trx_line_id = l_customer_trx_line_id
        WHERE  customer_trx_line_id = clinkRec.customer_trx_line_id;

    END LOOP;

    UPDATE ar_trx_lines_gt lgt
    SET (customer_trx_id, trx_date, org_id, set_of_books_id,currency_code) =
      ( SELECT hgt.customer_trx_id, hgt.trx_date, hgt.org_id,
               hgt.set_of_books_id, trx_currency
        FROM ar_trx_header_gt hgt
        WHERE lgt.trx_header_id = trx_header_id),
        request_id   =  AR_INVOICE_TABLE_HANDLER.g_request_id;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_lines(-)' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_errmsg := 'Error in AR_INVOICE_API_PUB.populate_lines '||sqlerrm;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            return;
END;


PROCEDURE populate_distributions  (
    p_trx_dist_tbl         IN trx_dist_tbl_type,
    p_batch_source_rec     IN batch_source_rec_type,
    p_trx_system_param_rec IN
      ar_invoice_default_pvt.trx_system_parameters_rec_type,
    x_errmsg               OUT NOCOPY  VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2 ) IS

  -- To work around an issue in 8i.
  -- ORASHID
  -- 16-OCT-2003

  null_column NUMBER := NULL;

BEGIN

  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_distributions(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --populate global dist. table
  ar_trx_global_process_dist.insert_row(
    p_trx_dist_tbl      =>  p_trx_dist_tbl,
    x_errmsg            =>  x_errmsg,
    x_return_status     =>  x_return_status);

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
    return;
  END IF;

  /* 5921925 - Should remove this but it would require us to rewrite
     the internals of ar_trx_global_process_dist.insert_row */
  UPDATE ar_trx_dist_gt dist
  SET set_of_books_id = nvl(set_of_books_id,
        p_trx_system_param_rec.set_of_books_id),
        request_id   =  AR_INVOICE_TABLE_HANDLER.g_request_id,
        /* gl_date = nvl(gl_date, nvl(p_batch_source_rec.default_date,
        sysdate)),
        Bug 3361235*/
     (customer_trx_id, customer_trx_line_id, trx_header_id, gl_date) =
     (
       SELECT line.customer_trx_id,
              line.customer_trx_line_id,
              line.trx_header_id,
              h.gl_date
       FROM   ar_trx_lines_gt line,
              ar_trx_header_gt h
       WHERE  line.trx_line_id = dist.trx_line_id
       AND    line.trx_header_id = h.trx_header_id
       UNION
       SELECT h.customer_trx_id, null_column, h.trx_header_id, h.gl_date
       FROM   ar_trx_header_gt h
       WHERE  h.trx_header_id = dist.trx_header_id
       AND    dist.account_class = 'REC');


  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_distributions(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'Error in AR_INVOICE_API_PUB.populate distributions'
        || sqlerrm;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

END populate_distributions;


PROCEDURE populate_salescredits  (
    p_trx_salescredits_tbl              IN   trx_salescredits_tbl_type,
    p_trx_system_param_rec              IN   AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    x_errmsg                            OUT NOCOPY  VARCHAR2,
    x_return_status                     OUT NOCOPY  VARCHAR2 ) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_salescredits(+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --populate global dist. table
    AR_TRX_GLOBAL_PROCESS_SALESCR.INSERT_ROW(
            p_trx_salescredits_tbl      =>  p_trx_salescredits_tbl,
            x_errmsg                    =>  x_errmsg,
            x_return_status             =>  x_return_status
            );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
     return;
    END IF;

    /* 5921925 - Should remove this.  Have to rewrite
        ar_trx_global_process_salescr.insert_row */
    UPDATE ar_trx_salescredits_gt sc
        SET org_id = nvl(org_id, p_trx_system_param_rec.org_id),
            request_id   =  AR_INVOICE_TABLE_HANDLER.g_request_id,
            (customer_trx_id, customer_trx_line_id, trx_header_id) =  (
                    SELECT line.customer_trx_id, line.customer_trx_line_id,
                           trx_header_id
                    FROM  ar_trx_lines_gt line
                    WHERE line.trx_line_id = sc.trx_line_id
                    AND rownum = 1);


    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_salescredits(-)' );
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_API_PUB.populate sales credits '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;

END populate_salescredits;

-- new subroutine introduced for "Payment Based Revenue Managment" project
-- ORASHID 20-September-2004

PROCEDURE populate_contingencies  (
 p_trx_contingencies_tbl trx_contingencies_tbl_type,
 p_trx_system_param_rec  ar_invoice_default_pvt.trx_system_parameters_rec_type,
 x_errmsg        OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2 ) IS

BEGIN

  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.populate_contingencies(+)' );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- populate global contingencies table

  ar_trx_global_process_cont.insert_row
  (
    p_trx_contingencies_tbl =>  p_trx_contingencies_tbl,
    x_errmsg               =>  x_errmsg,
    x_return_status        =>  x_return_status
  );

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RETURN;
  END IF;

  /* 5921925 - Should remove this.. Have to rewrite
     ar_trx_global_process_cont.insert_row */
  UPDATE ar_trx_contingencies_gt tcg
  SET    org_id       = nvl(org_id, p_trx_system_param_rec.org_id),
         request_id   = ar_invoice_table_handler.g_request_id,
         trx_header_id = (SELECT trx_header_id
                          FROM  ar_trx_lines_gt tlg
                          WHERE tlg.trx_line_id = tcg.trx_line_id
                          AND   rownum = 1);

  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('ar_invoice_api_pub.populate_contingencies(-)' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_errmsg := 'error ar_invoice_api_pub.populate_contingencies: '||sqlerrm;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;

END populate_contingencies;

PROCEDURE clean_gt IS

BEGIN
	delete from ar_trx_header_gt;
	delete from ar_trx_lines_gt;
	delete from ar_trx_dist_gt;
	delete from ar_trx_salescredits_gt;
	--delete from ar_trx_errors_gt;
	DELETE FROM ZX_TRX_HEADERS_GT;
	DELETE FROM ZX_TRANSACTION_LINES_GT;
	DELETE FROM ZX_IMPORT_TAX_LINES_GT;
END;

PROCEDURE clean_tmp_gt IS

BEGIN
	delete from ar_trx_header_tmp_gt;
	delete from ar_trx_lines_tmp_gt;
	delete from ar_trx_dist_tmp_gt;
	delete from ar_trx_salescredits_tmp_gt;
	--delete from ar_trx_errors_gt;
END;

PROCEDURE CREATE_INVOICE(
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    p_trx_contingencies_tbl IN          trx_contingencies_tbl_type,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2) IS

    l_api_name       CONSTANT  VARCHAR2(30) := 'CREATE_INVOICE';
    l_api_version    CONSTANT NUMBER       := 1.0;

    l_trx_system_parameters_rec   AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type;
    l_trx_profile_rec             AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type;
    l_trx_date                    ra_customer_trx.trx_date%type;
    x_errmsg                      VARCHAR2(2000);
    l_batch_id                    NUMBER;
--anuj
  cursor org_cur is
     select org_id
     from ar_trx_header_tmp_gt
     group by org_id;
    l_trx_header_tbl      trx_header_tbl_type;
    l_trx_lines_tbl       trx_line_tbl_type;
    l_trx_dist_tbl          trx_dist_tbl_type;
    l_trx_salescredits_tbl trx_salescredits_tbl_type;
    l_org_return_status VARCHAR2(1);
    l_org_id                           NUMBER;
--anuj

BEGIN

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_INVOICE(2)(+)' );
    END IF;

    SAVEPOINT Create_Invoice;
    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(
                      l_api_version,
                      p_api_version,
                      l_api_name,
                      G_PKG_NAME
                                )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

--anuj
clean_tmp_gt;
AR_TRX_GLOBAL_PROCESS_TMP.INSERT_ROWS (
    p_trx_header_tbl    =>p_trx_header_tbl,
    p_trx_lines_tbl     =>p_trx_lines_tbl,
    p_trx_dist_tbl      =>p_trx_dist_tbl,
    p_trx_salescredits_tbl  =>p_trx_salescredits_tbl,
    x_errmsg     =>x_errmsg,
    x_return_status  =>x_return_status);


    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('Before looping thru invoice headers....' );
         ar_invoice_utils.debug ('x_return_status = '|| x_return_status);
         ar_invoice_utils.debug ('x_errmsg = '|| x_errmsg);
    END IF;

 FOR org_rec in org_cur LOOP
   AR_TRX_GLOBAL_PROCESS_TMP.GET_ROWS (
    p_org_id    => org_rec.org_id,
    p_trx_header_tbl       =>  l_trx_header_tbl,
    p_trx_lines_tbl        => l_trx_lines_tbl,
    p_trx_dist_tbl         =>  l_trx_dist_tbl,
    p_trx_salescredits_tbl => l_trx_salescredits_tbl,
    x_errmsg     => x_errmsg,
    x_return_status => x_return_status);

         ar_invoice_utils.debug ('Looping thru invoice headers....' );
         ar_invoice_utils.debug ('x_return_status = '|| x_return_status);
         ar_invoice_utils.debug ('x_errmsg = '|| x_errmsg);

    l_org_id            := org_rec.org_id;
    l_org_return_status := FND_API.G_RET_STS_SUCCESS;
    ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                             p_return_status =>l_org_return_status);
    ar_invoice_utils.debug ('l_org_id = '|| l_org_id);
    ar_invoice_utils.debug ('l_org_return_status = '|| l_org_return_status);

    /* 6006015 - this logic differs from 11.5 because
       the transactions are processed by org.  So we
       have to init each time the org changes */
    IF g_one_time_init_org <> l_org_id
    THEN
       ar_invoice_default_pvt.get_system_parameters(
            p_trx_system_parameters_rec => l_trx_system_parameters_rec,
            x_errmsg                    =>  x_errmsg,
            x_return_status             =>  x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;

       -- Get the default values from profile options;
       ar_invoice_default_pvt.Get_profile_values(
           p_trx_profile_rec       =>   l_trx_profile_rec,
           x_errmsg                =>  x_errmsg,
           x_return_status         =>  x_return_status)   ;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;
    END IF;

 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE

    -- first clean all global temporary tables to start with
    clean_gt;

    IF (l_trx_header_tbl.COUNT = 0) OR (l_trx_lines_tbl.COUNT = 0) THEN
      ROLLBACK to Create_Invoice;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data := arp_standard.fnd_message('AR_INAPI_TABLES_EMPTY');
      RETURN;
    END IF;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('Calling Default Rtn from ar_invoice_pub(-)' );
         ar_invoice_utils.debug ('Create Batch(+)' );
    END IF;

    /* 5921925 - only create a batch if they are not calling in single invoice
        mode */
    IF NOT g_single_invoice
    THEN
       -- Create a batch
       AR_INVOICE_TABLE_HANDLER.create_batch(
            p_trx_system_parameters_rec     => l_trx_system_parameters_rec,
            p_trx_profile_rec               => l_trx_profile_rec,
            p_batch_source_rec              => p_batch_source_rec,
            p_batch_id                      => l_batch_id,
            x_errmsg                        => x_errmsg,
            x_return_status                 => x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
          ROLLBACK to Create_Invoice;
          x_msg_data := x_errmsg;
          return;
       END IF;
    ELSE
       /* 5921925 - insure that we have a viable request_id for this batch
           even if its only one transaction */
       SELECT ra_batches_s.nextval * -1
       INTO   ar_invoice_table_handler.g_request_id
       FROM   dual;
    END IF;

    --first popolate the global temp. table based on user passed variables and
    -- default system parameters and profile values.
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('Create Batch(-)' );
         ar_invoice_utils.debug ('populate header(+)' );
    END IF;
    populate_header( p_trx_header_tbl        => l_trx_header_tbl,
                     p_trx_system_param_rec  => l_trx_system_parameters_rec,
                     p_trx_profile_rec       => l_trx_profile_rec,
                     p_batch_source_rec      => p_batch_source_rec,
                     x_errmsg                =>  x_errmsg,
                     x_return_status         =>  x_return_status);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        ROLLBACK to Create_Invoice;
        x_msg_data := x_errmsg;
        return;
    END IF;
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('populate header (-)' );
         ar_invoice_utils.debug ('populate lines (+)' );
    END IF;

    populate_lines ( p_trx_lines_tbl => l_trx_lines_tbl,
                     p_trx_system_param_rec => l_trx_system_parameters_rec,
                     x_errmsg                =>  x_errmsg,
                     x_return_status         =>  x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      ROLLBACK to Create_Invoice;
      x_msg_data := x_errmsg;
      RETURN;
    END IF;

    -- Check for validations that spans across header and lines.

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug ('validate_master_detail' );
    END IF;

    ar_invoice_utils.validate_master_detail
      ( x_errmsg        =>  x_errmsg,
        x_return_status =>  x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      ROLLBACK to Create_Invoice;
      x_msg_data := x_errmsg;
      RETURN;
    END IF;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('populate lines (-)' );
         ar_invoice_utils.debug ('populate distributions (+)' );
    END IF;

    /* 5921925 - only execute if there are rows */
    IF p_trx_dist_tbl.count > 0
    THEN
       g_dist_exist := TRUE;
       populate_distributions (p_trx_dist_tbl         => p_trx_dist_tbl,
                            p_batch_source_rec     => p_batch_source_rec,
                            p_trx_system_param_rec => l_trx_system_parameters_rec,
                            x_errmsg                =>  x_errmsg,
                            x_return_status         =>  x_return_status );

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;
    ELSE
       g_dist_exist := FALSE;
    END IF;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('populate distributions (-)' );
         ar_invoice_utils.debug ('populate sales credits (+)' );
    END IF;

    /* 5921925 - only execute if rows exist */
    IF p_trx_salescredits_tbl.count > 0
    THEN
       g_sc_exist := TRUE;
       populate_salescredits  (p_trx_salescredits_tbl => p_trx_salescredits_tbl,
                            p_trx_system_param_rec => l_trx_system_parameters_rec,
                            x_errmsg                =>  x_errmsg,
                            x_return_status         =>  x_return_status );

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;
    ELSE
       g_sc_exist := FALSE;
    END IF;

    IF pg_debug = 'Y' THEN
      ar_invoice_utils.debug('populate sales credits(-)' );
      ar_invoice_utils.debug('populate contingencies(+)' );
    END IF;

    /* 5921925 - only populate if rows exist */
    IF p_trx_contingencies_tbl.count > 0
    THEN
       g_cont_exist := TRUE;
       populate_contingencies(
          p_trx_contingencies_tbl => p_trx_contingencies_tbl,
          p_trx_system_param_rec  => l_trx_system_parameters_rec,
          x_errmsg                => x_errmsg,
          x_return_status         => x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;
    ELSE
       g_cont_exist := FALSE;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      ROLLBACK TO Create_Invoice;
      x_msg_data := x_errmsg;
      RETURN;
    END IF;

    -- ORASHID 20-Sep-2004
    -- END

    IF pg_debug = 'Y'  THEN
         ar_invoice_utils.debug ('populate contingencies(-)' );
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      ROLLBACK to Create_Invoice;
      x_msg_data := x_errmsg;
      RETURN;
    END IF;

   -- Validate all inter-dependent parameters
    IF pg_debug = 'Y'
    THEN
      ar_invoice_utils.debug ('validate_dependend_parameter' );
    END IF;
    ar_invoice_utils.validate_dependent_parameters
            ( p_trx_system_param_rec => l_trx_system_parameters_rec,
              x_errmsg               =>  x_errmsg,
              x_return_status        =>  x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        ROLLBACK to Create_Invoice;
        x_msg_data := x_errmsg;
        return;
    END IF;

    -- Now validate all the values which user has passed and populate
    -- any dependent fields.
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('validate_header from ar_invoice_pub (+)' );
    END IF;

    ar_invoice_utils.validate_header
            ( p_trx_system_param_rec   => l_trx_system_parameters_rec,
              p_trx_profile_rec        => l_trx_profile_rec,
              x_errmsg                 =>  x_errmsg,
              x_return_status          =>  x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        ROLLBACK to Create_Invoice;
        x_msg_data := x_errmsg;
        return;
    END IF;


    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('validate_header from ar_invoice_pub (-)' );
         ar_invoice_utils.debug ('validate_lines from ar_invoice_pub (+)' );
    END IF;

    ar_invoice_utils.validate_lines
        ( x_errmsg            =>  x_errmsg,
          x_return_status     =>  x_return_status);

        /* Bug9356903 When creating Credit Memo, Quantity_Credited
        should be populated. Quantity_Invocied must be made NULL. */
        UPDATE ar_trx_lines_gt
        SET quantity_credited = quantity_invoiced,
            quantity_invoiced = null
        WHERE trx_line_id in
        (SELECT gt.trx_line_id
         FROM ar_trx_lines_gt gt ,
    	  ar_trx_header_gt gt2
         WHERE gt.trx_header_id = gt2.trx_header_id
         AND   gt2.trx_class = 'CM'
     	 AND   gt.line_type = 'LINE');

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        ROLLBACK to Create_Invoice;
        x_msg_data := x_errmsg;
        return;
    END IF;
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('validate_lines from ar_invoice_pub (-)' );
         ar_invoice_utils.debug ('validate_distributions from ar_invoice_pub (+)' );
    END IF;

    /* 5921925 - prevent this call if no distributions passed */
    IF g_dist_exist
    THEN
       ar_invoice_utils.validate_distributions
        ( p_trx_system_parameters_rec => l_trx_system_parameters_rec,
          x_errmsg            =>  x_errmsg,
          x_return_status     =>  x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;
    END IF;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('validate_distributions from ar_invoice_pub (-)' );
         ar_invoice_utils.debug ('validate_salescredits from ar_invoice_pub (+)' );
    END IF;

    IF g_sc_exist
    THEN
       ar_invoice_utils.validate_salescredits(
         p_trx_system_param_rec => l_trx_system_parameters_rec,
         x_errmsg              => x_errmsg,
         x_return_status       => x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           ROLLBACK to Create_Invoice;
           x_msg_data := x_errmsg;
           return;
       END IF;
    END IF;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('validate_salescredits from ar_invoice_pub (-)' );
         ar_invoice_utils.debug ('vaidate_gdf (+) ');
    END IF;

    ar_invoice_utils.validate_gdf(
      p_request_id          => AR_INVOICE_TABLE_HANDLER.g_request_id,
      x_errmsg              => x_errmsg,
      x_return_status       => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        ROLLBACK to Create_Invoice;
        x_msg_data := x_errmsg;
        return;
    END IF;
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('validate_gdf (-)' );
         ar_invoice_utils.debug ('Calling Table Handler ar_invoice_table_handler.insert_row (+) ');
    END IF;

    AR_INVOICE_TABLE_HANDLER.insert_row(
            p_trx_system_parameters_rec =>  l_trx_system_parameters_rec,
            p_trx_profile_rec           =>  l_trx_profile_rec,
            p_batch_source_rec          =>  p_batch_source_rec,
            x_errmsg                    =>  x_errmsg,
            x_return_status             =>  x_return_status)  ;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        ROLLBACK to Create_Invoice;
        x_msg_data := x_errmsg;
        return;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT;
    END IF;
 END IF;

 END LOOP; --anuj


--{Call creation of the events should outside the loop as not org striped
--
 ar_invoice_utils.debug ('Call creation of XLA events in bulk mode +' );
 ar_invoice_utils.debug ('  Using the request_id :'||AR_INVOICE_TABLE_HANDLER.g_request_id);

 arp_xla_events.Create_Events_Req(p_request_id =>  AR_INVOICE_TABLE_HANDLER.g_request_id,
                                     p_doc_table  => 'CT',
                                     p_mode       => 'B',
                                     p_call       => 'B');
 ar_invoice_utils.debug ('Call creation of XLA events in bulk mode -' );
--}


    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('Calling Table Handler ar_invoice_table_handler.insert_row (-) ');
         ar_invoice_utils.debug ('ar_invoice_api_pub.create_invoice(-)' );
    END IF;


END CREATE_INVOICE;

PROCEDURE CREATE_SINGLE_INVOICE(
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    p_trx_contingencies_tbl IN          trx_contingencies_tbl_type,
    x_customer_trx_id       OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2) IS

    l_api_name       CONSTANT  VARCHAR2(30) := 'CREATE_INVOICE';
    l_api_version    CONSTANT  NUMBER       := 1.0;
    l_no_of_records            NUMBER := 0;


BEGIN
    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE(2)(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_no_of_records := p_trx_header_tbl.COUNT;

    /* 5921925 - global variable to track single invoice call */
    g_single_invoice := TRUE;

    IF ( nvl(l_no_of_records,0) > 1 )
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := arp_standard.fnd_message('AR_INAPI_MULTIPLE_HEADERS');
        return;
    END IF;


    CREATE_INVOICE (
        p_api_version           =>  p_api_version,
        p_init_msg_list         =>  p_init_msg_list,
        p_commit                =>  p_commit,
        p_batch_source_rec      =>  p_batch_source_rec,
        p_trx_header_tbl        =>  p_trx_header_tbl,
        p_trx_lines_tbl         =>  p_trx_lines_tbl,
        p_trx_dist_tbl          =>  p_trx_dist_tbl,
        p_trx_salescredits_tbl  =>  p_trx_salescredits_tbl,
        p_trx_contingencies_tbl =>  p_trx_contingencies_tbl,
        x_return_status         =>  x_return_status,
        x_msg_count             =>  x_msg_count,
        x_msg_data              =>  x_msg_data);


    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        -- get the value of cust_trx_id
        x_customer_trx_id := AR_INVOICE_API_PUB.g_customer_trx_id;
    END IF;

    IF pg_debug = 'Y'
    THEN
         ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE(-)' );
    END IF;

END CREATE_SINGLE_INVOICE;


-- added the overloaded procedures to make the api backward compatible
-- ORASHID
-- 11-OCT-2004

PROCEDURE create_invoice(
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2) IS

    l_trx_contingencies_tbl trx_contingencies_tbl_type;

BEGIN

  IF pg_debug = 'Y'  THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE(+)' );
  END IF;

  -- call the api with a null trx_contingencies_tbl

  create_invoice (
    p_api_version           =>  p_api_version,
    p_init_msg_list         =>  p_init_msg_list,
    p_commit                =>  p_commit,
    p_batch_source_rec      =>  p_batch_source_rec,
    p_trx_header_tbl        =>  p_trx_header_tbl,
    p_trx_lines_tbl         =>  p_trx_lines_tbl,
    p_trx_dist_tbl          =>  p_trx_dist_tbl,
    p_trx_salescredits_tbl  =>  p_trx_salescredits_tbl,
    p_trx_contingencies_tbl =>  l_trx_contingencies_tbl,
    x_return_status         =>  x_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data);

  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE(-)' );
  END IF;

END create_invoice;


PROCEDURE create_single_invoice (
    p_api_version           IN      	NUMBER,
    p_init_msg_list         IN      	VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN      	VARCHAR2 := FND_API.G_FALSE,
    p_batch_source_rec      IN      	batch_source_rec_type DEFAULT NULL,
    p_trx_header_tbl        IN      	trx_header_tbl_type,
    p_trx_lines_tbl         IN      	trx_line_tbl_type,
    p_trx_dist_tbl          IN          trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN          trx_salescredits_tbl_type,
    x_customer_trx_id       OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2) IS

    l_trx_contingencies_tbl trx_contingencies_tbl_type;

BEGIN

  IF pg_debug = 'Y'  THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE(+)' );
  END IF;

  -- call the api with a null trx_contingencies_tbl

  create_single_invoice (
    p_api_version           =>  p_api_version,
    p_init_msg_list         =>  p_init_msg_list,
    p_commit                =>  p_commit,
    p_batch_source_rec      =>  p_batch_source_rec,
    p_trx_header_tbl        =>  p_trx_header_tbl,
    p_trx_lines_tbl         =>  p_trx_lines_tbl,
    p_trx_dist_tbl          =>  p_trx_dist_tbl,
    p_trx_salescredits_tbl  =>  p_trx_salescredits_tbl,
    p_trx_contingencies_tbl =>  l_trx_contingencies_tbl,
    x_customer_trx_id       =>  x_customer_trx_id,
    x_return_status         =>  x_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data);

  IF pg_debug = 'Y' THEN
    ar_invoice_utils.debug ('AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE(-)' );
  END IF;

END create_single_invoice;

-- Bug 7194381 Start

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Cache_Transaction_Type                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Caches each transaction type when it is first used so that   |
 |              type values can easily be accessed later and so that the     |
 |              type record does not have to be fetched from the database    |
 |              for future transactions.                                     |
 |              The whole table is not cached at startup because it might be |
 |              very large on some sites, and because it is likely that a    |
 |              few types will be used many times.                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_context_rec					     |
 |                    p_cust_trx_type_id                                     |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    mpsingh   20-JUN-08  Created                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Transaction_Type(
                                  p_context_rec       IN  Context_Rec_Type,
                                  p_cust_trx_type_id  IN
                                    ra_cust_trx_types.cust_trx_type_id%type
                                ) IS

       l_temp        BINARY_INTEGER;
       l_dummy_type  ra_cust_trx_types%rowtype;

BEGIN

        ar_invoice_utils.debug('Cache_Transaction_Type()+');

       IF ( p_cust_trx_type_id IS NOT NULL )
       THEN

            /*------------------------------------------------------+
             |  Add the current transaction type to the type cache  |
             |  if it does not already exist in the cache.          |
             +------------------------------------------------------*/

             IF ( NOT Type_Cache_Tbl.EXISTS( p_cust_trx_type_id ) )
             THEN

                  BEGIN
                          SELECT *
                          INTO   Type_Cache_Tbl( p_cust_trx_type_id )
                          FROM   ra_cust_trx_types
                          WHERE  cust_trx_type_id =  p_cust_trx_type_id;

                           ar_invoice_utils.debug('Transaction Type: ' ||
                                Type_Cache_Tbl( p_cust_trx_type_id ).name ||
                                ' found.');

                  EXCEPTION
                    WHEN NO_DATA_FOUND
                         THEN
                            /*---------------------------------------------+
                             |  If the type does not exist, assign a       |
                             |  null type record to its place in the cache |
                             |  to avoid NO_DATA_FOUND errors later on.    |
                             |                                             |
                             |  The invalid data will be caught later in   |
                             |  the validation routines.                   |
                             +---------------------------------------------*/

                             Type_Cache_Tbl( p_cust_trx_type_id ) :=
                                   l_dummy_type;
                              ar_invoice_utils.debug('Transaction Type not found');

                    WHEN OTHERS THEN
                         RAISE;
                  END;

             END IF;

       END IF;

        ar_invoice_utils.debug('Cache_Transaction_type()-');

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;

    WHEN OTHERS THEN
      ar_invoice_utils.debug('EXCEPTION: Cache_Transaction_Type() ');
      ar_invoice_utils.debug('p_cust_trx_type_id  =  ' ||
                    TO_CHAR(p_cust_trx_type_id));
     RAISE;

END Cache_Transaction_Type;

/*===========================================================================+
 | PROCEDURE     Get_Flags                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Gets information about the transaction that is used in determining if   |
 |   it can be updated.                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_context_rec                                           |
 |              OUT:                                                         |
 |                   p_dm_reversal 					     |
 |                   p_cb 						     |
 |          IN/ OUT:                                                         |
 |                   p_trx_rec 						     |
 |                   p_type_rec 					     |
 |                   p_posted_flag 					     |
 |                   p_activity_flag 					     |
 |                   p_printed_flag 					     |
 |                   p_rev_recog_run_flag 				     |
 |                                                                           |
 | RETURNS    : None			                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  mpsingh   20-jun-2008 Created
 |                                                                           |
 +===========================================================================*/

PROCEDURE Get_Flags(
                             p_context_rec   IN  Context_Rec_Type,
                             p_trx_rec       IN OUT NOCOPY  ra_customer_trx%rowtype,
                             p_type_rec      IN OUT NOCOPY  ra_cust_trx_types%rowtype,
                             p_posted_flag   IN OUT NOCOPY  VARCHAR2,
                             p_activity_flag IN OUT NOCOPY  VARCHAR2,
                             p_printed_flag  IN OUT NOCOPY  VARCHAR2,
                             p_rev_recog_run_flag  IN OUT NOCOPY VARCHAR2,
                             p_dm_reversal      OUT NOCOPY VARCHAR2,
                             p_cb               OUT NOCOPY VARCHAR2
                              ) IS

        l_index  BINARY_INTEGER;

BEGIN

        ar_invoice_utils.debug('Get_Flags()+');

        p_posted_flag         := 'N';
        p_activity_flag       := 'N';
        p_dm_reversal         := 'N';
        p_cb                  := 'N';
        p_printed_flag        := 'N';
        p_rev_recog_run_flag  := 'N';

        p_posted_flag := arpt_sql_func_util.get_posted_flag(
                                       p_trx_rec.customer_trx_id,
                                       p_type_rec.post_to_gl,
                                       p_trx_rec.complete_flag );

        p_activity_flag := arpt_sql_func_util.get_activity_flag(
                                 p_trx_rec.customer_trx_id,
                                 p_type_rec.accounting_affect_flag,
                                 p_trx_rec.complete_flag,
                                 p_type_rec.type,
                                 p_trx_rec.initial_customer_trx_id,
                                 p_trx_rec.previous_customer_trx_id
                                 );

        IF ( NVL(p_trx_rec.printing_count, 0) > 0 )
        THEN p_printed_flag := 'Y';
        END IF;

       /*--------------------------------------------------------------------+
        | Determine if Revenue Recognition has been run for any of the lines |
	+--------------------------------------------------------------------*/

        FOR l_index IN 1..G_lines_tbl.count LOOP

            IF ( G_lines_tbl(l_index).autorule_duration_processed > 0 )
            THEN p_rev_recog_run_flag := 'Y';
            END IF;

        END LOOP;

        ar_invoice_utils.debug('.  posted_flag           = ' ||
                                 p_posted_flag);

        ar_invoice_utils.debug('.  activity_flag         = ' ||
                                 p_activity_flag);

        ar_invoice_utils.debug('.  printed_flag          = ' ||
                                 p_printed_flag);

        ar_invoice_utils.debug('.  p_rev_recog_run_flag  = ' ||
                                 p_rev_recog_run_flag);

        ar_invoice_utils.debug('.  Class                 = ' ||
                                 p_type_rec.type);

        ar_invoice_utils.debug('.  created_from          = ' ||
                                 p_trx_rec.created_from);

        IF ( p_trx_rec.created_from  IN ('ARXREV', 'REL9_ARXREV') )
        THEN
             p_dm_reversal := 'Y';
        END IF;

        IF ( p_type_rec.type = 'CB' )
        THEN
             p_cb := 'Y';
        END IF;

        ar_invoice_utils.debug('Get_Flags()-');

EXCEPTION
   WHEN OTHERS THEN

        ar_invoice_utils.debug('EXCEPTION: Get_Flags()');
        RAISE;

END Get_Flags;

/*===========================================================================+
 | PROCEDURE     Validate_Delete_Transaction                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |		 Validates that the information provided for a transaction   |
 |		 deletion does not violate any of the validation rules.      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_customer_trx_id                                       |
 |                   p_trx_rec                                               |
 |                   p_type_rec                                              |
 |              OUT:                                                         |
 |		     p_return_status					     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    mpsingh   20-Jun-08  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Delete_Transaction(
               p_customer_trx_id  IN      ra_customer_trx.customer_trx_id%type,
               p_trx_rec          IN OUT NOCOPY  ra_customer_trx%rowtype,
               p_type_rec         IN OUT NOCOPY  ra_cust_trx_types%rowtype,
               p_return_status    OUT NOCOPY     VARCHAR2
                                     ) IS

  l_context_rec          Context_Rec_Type;
  l_dummy                BINARY_INTEGER;
  l_posted_flag          VARCHAR2(1);
  l_activity_flag        VARCHAR2(1);
  l_printed_flag         VARCHAR2(1);
  l_rev_recog_run_flag   VARCHAR2(1);
  l_dm_reversal_flag     VARCHAR2(1);
  l_cb_flag              VARCHAR2(1);

BEGIN

        ar_invoice_utils.debug('Validate_Delete_Transaction()+');

        p_return_status := FND_API.G_RET_STS_SUCCESS;

       /*------------------------------------------------------------+
        |  Get the header record for the transaction to be deleted.  |
	+------------------------------------------------------------*/

        BEGIN
                arp_ct_pkg.fetch_p(
                                      p_trx_rec,
                                      p_customer_trx_id
                                   );

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
              p_return_status := FND_API.G_RET_STS_ERROR;

              arp_trx_validate.Add_To_Error_List(
                          p_mode              => 'PL/SQL',
                          P_error_count       => l_dummy,
                          p_customer_trx_id   => p_customer_trx_id,
                          p_trx_number        => null,
                          p_line_number       => null,
                          p_other_line_number => null,
                          p_message_name      => 'AR_TAPI_TRANS_NOT_EXIST',
                          p_token_name_1      => 'CUSTOMER_TRX_ID',
                          p_token_1           => p_customer_trx_id );

               RAISE;

          WHEN OTHERS THEN RAISE;
        END;

       /*--------------------------------------------------------------------+
        | The invoice_deletion_flag must be Y for transactions to be deleted |
	+--------------------------------------------------------------------*/

        ar_invoice_utils.debug('.  invoice_deletion_flag = ' ||
                                 arp_global.sysparam.invoice_deletion_flag);

        IF ( arp_global.sysparam.invoice_deletion_flag <> 'Y' )
        THEN

              p_return_status := FND_API.G_RET_STS_ERROR;

              arp_trx_validate.Add_To_Error_List(
                          p_mode              => 'PL/SQL',
                          P_error_count       => l_dummy,
                          p_customer_trx_id   => p_trx_rec.customer_trx_id,
                          p_trx_number        => p_trx_rec.trx_number,
                          p_line_number       => null,
                          p_other_line_number => null,
                          p_message_name      => 'AR_CANT_DELETE_IF_COMPLETE');

        ELSE

				Cache_Transaction_Type(
                                                   l_context_rec,
                                                   p_trx_rec.cust_trx_type_id
                                                       );

              p_type_rec := Type_Cache_Tbl(
                              p_trx_rec.cust_trx_type_id
                                          );

             /*--------------------------------------------------------------+
              |  If the transaction is complete, it must be made incomplete  |
              |  before it can be deleted.                                   |
              |                                                              |
              |  A transaction can only be made incomplete if:               |
              |    o It is not a chargeback           and                    |
              |    o It is not a debit memo reversal  and                    |
              |    o It has not been posted to GL     and                    |
              |    o There is no activity against it.                        |
              +--------------------------------------------------------------*/

              ar_invoice_utils.debug('.  complete_flag         = ' ||
                                       p_trx_rec.complete_flag);

              IF ( p_trx_rec.complete_flag = 'Y' )
              THEN

                    Get_Flags(
                               l_context_rec,
                               p_trx_rec,
                               p_type_rec,
                               l_posted_flag,
                               l_activity_flag,
                               l_printed_flag,
                               l_rev_recog_run_flag,
                               l_dm_reversal_flag,
                               l_cb_flag
                             );

                    IF   ( l_dm_reversal_flag = 'Y' )
                    THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;

                         arp_trx_validate.Add_To_Error_List(
                              p_mode              => 'PL/SQL',
                              p_error_count       => l_dummy,
                              p_customer_trx_id   => p_trx_rec.customer_trx_id,
                              p_trx_number        => p_trx_rec.trx_number,
                              p_line_number       => null,
                              p_other_line_number => null,
                              p_message_name      =>
                                                 'AR_TAPI_CANT_DELETE_DM_REV');

                    END IF;

                    IF ( l_cb_flag = 'Y' )
                    THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;

                         arp_trx_validate.Add_To_Error_List(
                              p_mode              => 'PL/SQL',
                              p_error_count       => l_dummy,
                              p_customer_trx_id   => p_trx_rec.customer_trx_id,
                              p_trx_number        => p_trx_rec.trx_number,
                              p_line_number       => null,
                              p_other_line_number => null,
                              p_message_name      => 'AR_TAPI_CANT_DELETE_CB');

                    END IF;

                    IF ( l_posted_flag  = 'Y' )
                    THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;

                         arp_trx_validate.Add_To_Error_List(
                              p_mode              => 'PL/SQL',
                              p_error_count       => l_dummy,
                              p_customer_trx_id   => p_trx_rec.customer_trx_id,
                              p_trx_number        => p_trx_rec.trx_number,
                              p_line_number       => null,
                              p_other_line_number => null,
                              p_message_name      =>
                                                 'AR_ALL_CANT_DELETE_IF_POSTED');

                    END IF;

                    IF ( l_activity_flag = 'Y' )
                    THEN
                         p_return_status := FND_API.G_RET_STS_ERROR;

                         arp_trx_validate.Add_To_Error_List(
                              p_mode              => 'PL/SQL',
                              p_error_count       => l_dummy,
                              p_customer_trx_id   => p_trx_rec.customer_trx_id,
                              p_trx_number        => p_trx_rec.trx_number,
                              p_line_number       => null,
                              p_other_line_number => null,
                              p_message_name      =>
                                               'AR_TAPI_CANT_DELETE_ACTIVITY');

                    END IF;


              END IF;  -- complete case

       END IF;

       ar_invoice_utils.debug('Validate_Delete_Transaction()-');

EXCEPTION
   WHEN OTHERS THEN
        ar_invoice_utils.debug('EXCEPTION:  Validate_Delete_Transaction()');
        ar_invoice_utils.debug('p_customer_trx_id = ' ||
                                 p_customer_trx_id);

        RAISE;

END Validate_Delete_Transaction;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Delete_Trxn_Extn_Details                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine that deletes the                    |
 |              PAYMENT_TRXN_EXTENSION details of transactions.              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |     IBY_FNDCPT_TRXN_PUB.delete_transaction_extension                      |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_rec                                               |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    mpsingh   20-jun-2008  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Delete_Trxn_Extn_Details(p_trx_rec IN ra_customer_trx%rowtype,
                                   p_return_status    OUT NOCOPY     VARCHAR2
) IS

    l_payer_rec            IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_trxn_attribs_rec     IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
    l_payment_channel      ar_receipt_methods.payment_channel_code%type;
    x_msg_count		   NUMBER;
    x_msg_data		   VARCHAR2(240);
    x_return_status	   VARCHAR2(240);
    l_payment_trxn_extn_id ra_customer_trx.PAYMENT_TRXN_EXTENSION_ID%TYPE;
    l_fnd_api_constants_rec     ar_bills_main.fnd_api_constants_type     := ar_bills_main.get_fnd_api_constants_rec;
    Begin
        ar_invoice_utils.debug('AR_INVOICE_API_PUB.Delete_Trxn_Extn_Details()+ ');

	p_return_status := FND_API.G_RET_STS_SUCCESS;


        x_msg_count          := NULL;
        x_msg_data           := NULL;
        x_return_status      := l_fnd_api_constants_rec.G_RET_STS_SUCCESS;
        l_payer_rec.party_id :=  arp_trx_defaults_3.get_party_Id(p_trx_rec.BILL_TO_CUSTOMER_ID);
        l_payer_rec.payment_function                  := 'CUSTOMER_PAYMENT';
        l_payer_rec.org_type                          := 'OPERATING_UNIT';
        l_payer_rec.cust_account_id                   := p_trx_rec.BILL_TO_CUSTOMER_ID;
        l_payer_rec.org_id                            := p_trx_rec.ORG_ID;
        l_payer_rec.account_site_id                   := p_trx_rec.BILL_TO_SITE_USE_ID;
        l_payment_trxn_extn_id 			      := p_trx_rec.PAYMENT_TRXN_EXTENSION_ID;

           /*-------------------------+
            |   Call the IBY API      |
            +-------------------------*/
            ar_invoice_utils.debug('Call TO IBY API ()+ ');


            IBY_FNDCPT_TRXN_PUB.delete_transaction_extension(
               p_api_version           => 1.0,
               p_init_msg_list         => AR_BILLS_MAIN.GTRUE,
               p_commit                => AR_BILLS_MAIN.GFALSE,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_payer                 => l_payer_rec,
               p_payer_equivalency     => 'UPWARD',
               p_entity_id             => l_payment_trxn_extn_id,
               x_response              => l_response);



    IF x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
       ar_invoice_utils.debug('Payment_Trxn_Extension_Id : ' || l_payment_trxn_extn_id);
    Else
      ar_invoice_utils.debug('Errors Reported by IBY API:Delete Transaction Extension ');
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
EXCEPTION
     WHEN OTHERS THEN
       ar_invoice_utils.debug('exception in AR_INVOICE_API_PUB.Delete_Trxn_Extn_Detail ');
       p_return_status := FND_API.G_RET_STS_ERROR;
END Delete_Trxn_Extn_Details;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Delete_Transaction                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine that deletes the transactions.      |
 |              It is called once for each transaction to be deleted.        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |     ar_transaction_val2_pub.Validate_Delete_Transaction                   |
 |     arp_process_header.update_header                                      |
 |     arp_process_header_post_commit.post_commit                            |
 |     arp_trx_validate.Add_To_Error_List                                    |
 |     arp_process_header.delete_header                                      |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.compatible_api_call                                           |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |     fnd_msg_pub.check_msg_level                                           |
 |     fnd_msg_pub.count_and_get                                             |
 |     fnd_msg_pub.initialize                                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit                                                |
 |                   p_validation_level                                      |
 |                   p_customer_trx_id                                       |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                   p_msg_count                                             |
 |                   p_msg_data                                              |
 |                   p_errors                                                |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    mpsingh   20-jun-2008  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Delete_Transaction(
     p_api_name                  IN  varchar2,
     p_api_version               IN  number,
     p_init_msg_list             IN  varchar2 := FND_API.G_FALSE,
     p_commit                    IN  varchar2 := FND_API.G_FALSE,
     p_validation_level          IN  varchar2 := FND_API.G_VALID_LEVEL_FULL,
     p_customer_trx_id           IN  ra_customer_trx.customer_trx_id%type,
     p_return_status            OUT NOCOPY  varchar2,
     p_msg_count             IN OUT NOCOPY  NUMBER,
     p_msg_data              IN OUT NOCOPY  varchar2,
     p_errors                IN OUT NOCOPY  arp_trx_validate.Message_Tbl_Type
                  ) IS

  l_api_name             CONSTANT VARCHAR2(20) := 'Delete_Transaction';
  l_api_version          CONSTANT NUMBER       := 1.0;
  l_message              VARCHAR2(1000);
  l_return_status        VARCHAR2(10);
  l_trx_rec              ra_customer_trx%rowtype;
  l_type_rec             ra_cust_trx_types%rowtype;
  l_commitment_rec       arp_process_commitment.commitment_rec_type;
  l_gl_date              ra_cust_trx_line_gl_dist.gl_date%type;
  l_amount               ra_cust_trx_line_gl_dist.amount%type;
  l_dummy                BINARY_INTEGER;
  l_update_status        VARCHAR2(50)  := 'OK';
  l_delete_status        VARCHAR2(50)  := 'OK';
  l_validation_status    VARCHAR2(10);
  l_delete_pmt_ext_status VARCHAR2(10);

  PROCEDURE Display_Parameters IS
  BEGIN
        ar_invoice_utils.debug('p_api_name              = ' || p_api_name);
        ar_invoice_utils.debug('p_api_version           = ' || p_api_version);
        ar_invoice_utils.debug('p_init_msg_list         = ' || p_init_msg_list);
        ar_invoice_utils.debug('p_commit                = ' || p_commit);
        ar_invoice_utils.debug('p_validation_level      = ' || p_validation_level);
        ar_invoice_utils.debug('p_customer_trx_id       = ' || p_customer_trx_id);
  END;

BEGIN


       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT Delete_Transaction_Pub;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
              FND_MSG_PUB.initialize;
              arp_trx_validate.pg_message_tbl.DELETE;
        END IF;

        /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        l_return_status := FND_API.G_RET_STS_SUCCESS;

       /*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/

       	 ar_invoice_utils.debug('AR_INVOICE_API_PUB.Delete_Transaction(+)' );


                               Validate_Delete_Transaction(
                                                            p_customer_trx_id,
                                                            l_trx_rec,
                                                            l_type_rec,
                                                            l_validation_status
                                                           );

        IF ( l_validation_status = FND_API.G_RET_STS_SUCCESS )
        THEN
              IF ( l_trx_rec.complete_flag = 'Y' )
              THEN

		IF pg_debug = 'Y'
		THEN
		 ar_invoice_utils.debug('Making the transaction incomplete ' );
		END IF;

                        /*-------------------------------------------+
                         |  Try to make the transaction incomplete.  |
                         +-------------------------------------------*/

                         SELECT trunc(gl_date),
                                amount
                         INTO   l_gl_date,
                                l_amount
                         FROM   ra_cust_trx_line_gl_dist
                         WHERE  customer_trx_id = p_customer_trx_id
                         AND    account_class   = 'REC'
                         AND    latest_rec_flag = 'Y';

                         	IF pg_debug = 'Y'
				THEN
				 ar_invoice_utils.debug ('.  gl_date	= ' ||  TO_CHAR(l_gl_date, 'DD-MON-YYYY'));
				END IF;

                        	IF pg_debug = 'Y'
				THEN
				 ar_invoice_utils.debug ('.  amount                = ' ||TO_CHAR(l_amount));
				END IF;

                         l_trx_rec.complete_flag := 'N';

                         arp_process_header.update_header(
                               p_api_name,
                               p_api_version,
                               l_trx_rec,
                               p_customer_trx_id,
                               l_amount,
                               l_type_rec.type,
                               l_gl_date,
                               l_trx_rec.initial_customer_trx_id,
                               l_commitment_rec,
                               l_type_rec.accounting_affect_flag,
                               'Y',
                               FALSE,
                               FALSE,
                               NULL,
                               NULL,
                               l_update_status);


                        /*-----------------------+
                         |  Do postcommit logic  |
                         +-----------------------*/

			 IF pg_debug = 'Y'
			 THEN
			  ar_invoice_utils.debug('post_commit()+ ');
			 END IF;

                         arp_process_header_post_commit.post_commit(
                                      'ARTPTRXB',
                                      p_api_version,
                                      p_customer_trx_id,
                                      l_trx_rec.previous_customer_trx_id,
                                      'N',
                                      l_type_rec.accounting_affect_flag,
                                      NULL,
                                      l_type_rec.creation_sign,
                                      l_type_rec.allow_overapplication_flag,
                                      l_type_rec.natural_application_only_flag,
                                      NULL,
                                      'PL/SQL'
                                      );


                         IF pg_debug = 'Y'
			 THEN
			  ar_invoice_utils.debug('post_commit()- ');
			 END IF;

              END IF;   -- end complete_flag = 'Y' case

             /*-----------------------------------------------------+
              |  Delete the transaction if no errors have occurred  |
              |  in the previous steps.                             |
              +-----------------------------------------------------*/

              IF pg_debug = 'Y'
	      THEN
		ar_invoice_utils.debug ('.  update_status         = ' || l_update_status);
	      END IF;

              IF   (
                        l_return_status = FND_API.G_RET_STS_SUCCESS
                    AND l_update_status = 'OK'
                   )
              THEN
			IF pg_debug = 'Y'
			THEN
				ar_invoice_utils.debug('Deleting the transaction');
			END IF;


                        IF l_trx_rec.payment_trxn_extension_id IS NOT NULL THEN
				Delete_Trxn_Extn_Details(l_trx_rec,
						       l_delete_pmt_ext_status);
                        ELSE
			   l_delete_pmt_ext_status := FND_API.G_RET_STS_SUCCESS;
			END IF;

			IF  l_delete_pmt_ext_status = FND_API.G_RET_STS_SUCCESS THEN

			      arp_process_header.delete_header(
								p_api_name,
								p_api_version,
								p_customer_trx_id,
								l_type_rec.type,
								l_delete_status);
                        END IF;

              END IF;

        END IF;  -- validation was successfull case

       /*-------------------------------------------------------------------+
        |  Get any messages that have been put on the regular message stack |
        |  and add them to the error list.                                  |
        +-------------------------------------------------------------------*/

        l_message := fnd_message.get;

        WHILE l_message IS NOT NULL LOOP

              arp_trx_validate.Add_To_Error_List(
                              p_mode              => 'PL/SQL',
                              P_error_count       => l_dummy,
                              p_customer_trx_id   => null,
                              p_trx_number        => null,
                              p_line_number       => null,
                              p_other_line_number => null,
                              p_message_name      => 'GENERIC_MESSAGE',
                              p_token_name_1      => 'GENERIC_TEXT',
                              p_token_1           => l_message );

              l_message := fnd_message.get;

        END LOOP;


       /*-------------------------------------------+
        |   ========== End of API Body ==========   |
        +-------------------------------------------*/

        p_return_status := l_return_status;

       /*---------------------------------------------------+
        |  Get message count and if 1, return message data  |
        +---------------------------------------------------*/

        FND_MSG_PUB.Count_And_Get(
                                   p_count => p_msg_count,
                                   p_data  => p_msg_data
                                 );


       /*------------------------------------------------------------+
        |  If any errors - including validation failures - occurred, |
        |  rollback any changes and return an error status.          |
        +------------------------------------------------------------*/

        IF   (
                  NVL( arp_trx_validate.pg_message_tbl.COUNT, 0)  > 0
               OR l_update_status <> 'OK'
               OR l_delete_status <> 'OK'
	       OR l_delete_pmt_ext_status <> FND_API.G_RET_STS_SUCCESS
               OR l_return_status <> FND_API.G_RET_STS_SUCCESS
             )
        THEN

             p_errors := arp_trx_validate.pg_message_tbl;

             ROLLBACK TO Delete_Transaction_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             	   IF pg_debug = 'Y'
		   THEN
		     ar_invoice_utils.debug ('Error(s) occurred. Rolling back and setting status to ERROR');
  		     ar_invoice_utils.debug ('Number Of Messages:  ' ||  TO_CHAR( arp_trx_validate.pg_message_tbl.COUNT) );
		   END IF;



        END IF;

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN  ar_invoice_utils.debug('committing');
              Commit;
        END IF;

        	 ar_invoice_utils.debug('AR_INVOICE_API_PUB.Delete_Transaction(-)' );


EXCEPTION
       WHEN NO_DATA_FOUND THEN

                ROLLBACK TO Delete_Transaction_PUB;
                p_return_status := FND_API.G_RET_STS_ERROR;
                Display_Parameters;

                FND_MSG_PUB.Count_And_Get( p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

       WHEN FND_API.G_EXC_ERROR THEN
		 ar_invoice_utils.debug(SQLCODE);
		 ar_invoice_utils.debug(SQLERRM);


                ROLLBACK TO Delete_Transaction_PUB;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                Display_Parameters;

                FND_MSG_PUB.Count_And_Get( p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		 ar_invoice_utils.debug(SQLCODE);
		 ar_invoice_utils.debug(SQLERRM);
                ROLLBACK TO Delete_Transaction_PUB;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                Display_Parameters;

                FND_MSG_PUB.Count_And_Get( p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN OTHERS THEN
		 ar_invoice_utils.debug(SQLCODE);
		 ar_invoice_utils.debug(SQLERRM);
               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                      p_errors := arp_trx_validate.pg_message_tbl;

                      ROLLBACK TO Delete_Transaction_PUB;

                      p_return_status := FND_API.G_RET_STS_ERROR ;

			 ar_invoice_utils.debug('Completion validation error(s) occurred. ' ||
                            'Rolling back and setting status to ERROR');

                      RETURN;

                ELSE NULL;
                END IF;

                ROLLBACK TO Delete_Transaction_PUB;

                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                Display_Parameters;

                IF      FND_MSG_PUB.Check_Msg_Level
                THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                        l_api_name
                                       );
                END IF;

                FND_MSG_PUB.Count_And_Get( p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );


END Delete_Transaction;


-- Bug 7194381 End

BEGIN
   g_one_time_init_org := -98;
END AR_INVOICE_API_PUB;

/
