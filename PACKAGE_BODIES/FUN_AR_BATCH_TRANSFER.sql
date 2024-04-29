--------------------------------------------------------
--  DDL for Package Body FUN_AR_BATCH_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_AR_BATCH_TRANSFER" AS
/* $Header: funartrb.pls 120.15.12010000.12 2010/04/23 12:37:59 srsampat ship $ */

  FUNCTION has_valid_conversion_rate (
    p_from_currency IN varchar2,
    p_to_currency   IN varchar2,
    p_exchange_type IN varchar2,
    p_exchange_date IN date) RETURN number
  IS
    l_has_rate  number;
  BEGIN
    IF (p_from_currency = p_to_currency) THEN
        RETURN 1;
    END IF;

    SELECT COUNT(conversion_rate) INTO l_has_rate
    FROM gl_daily_rates
    WHERE from_currency = p_from_currency AND
          to_currency = p_to_currency AND
          conversion_type = p_exchange_type AND
          conversion_date = p_exchange_date;

    IF (l_has_rate = 0) THEN
        RETURN 0;
    END IF;
    RETURN 1;
  END has_valid_conversion_rate;

  Procedure ar_batch_transfer  (errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
                                p_org_id    IN VARCHAR2 DEFAULT NULL,
                                p_le_id     IN VARCHAR2 DEFAULT NULL,
                                p_date_low  IN VARCHAR2 DEFAULT NULL,
                                p_date_high IN VARCHAR2 DEFAULT NULL,
                                p_run_autoinvoice_import IN VARCHAR2 DEFAULT 'N'
                                ) is


  -- AR Batch Transfer Program

     l_date_low         date;
     l_date_high        date;
     l_initiator_id     number;
     l_le_id            number;
     l_ledger_id        number;
     l_recipient_id     number;
     l_ap_le_id         number;
     l_trx_type_id      number;
     l_ou_id            number;
     l_ap_ou_id         number;
     l_error            number;
     l_memo_line_name   varchar2(2000);
     l_ar_trx_type_name varchar2(2000);
     l_memo_line_id     number;
     l_ar_trx_type_id   number;
     l_default_term_id  number;
     l_term_id  number;
     l_ar_period_count  number;
     l_batch_id         number;
     l_trx_id           number;
     l_count            number := 0;
     l_line             AR_INTERFACE_LINE;
     l_dist_line        AR_INTERFACE_DIST_LINE;
     l_success          boolean;
     l_customer_id      number;
     l_address_id       number;
     l_site_use_id      number;
     x_msg_data         varchar2(1000);
     l_return_status    varchar2(1);
     l_message_count    number;
     l_message_data     varchar2(1000);
     l_counter          number;
     l_org_name         varchar2(240);
     l_le_name          varchar2(240);
     l_batch_num        varchar2(20);
     l_trx_num          varchar2(15);
     l_ledger_currency_code varchar2(15);
     l_request_id    	number;
     Request_Submission_Failure   EXCEPTION;
     TYPE  ORG_ID_TAB_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     org_id_table ORG_ID_TAB_TYPE;
     l_src_name varchar2(50);
     l_previous_org_id   number;
     l_run_autoinvoice_import varchar2(3);


  -- Cursor to retrieve the line information
  CURSOR c_line  (p_batch_id IN NUMBER,
                  p_trx_id   IN NUMBER) IS
     SELECT
                 decode(ftl.init_amount_cr,0, ftl.init_amount_dr,
                                           NULL, ftl.init_amount_dr,
                                           (ftl.init_amount_cr * (-1))),
                 ftl.line_id
     FROM        FUN_TRX_LINES ftl
     WHERE       p_trx_id   = ftl.trx_id;

      -- cursor to retrieve the initiator and recipient party / LE ID

     cursor c_info IS
     SELECT      ftb.batch_id,
		 ftb.batch_number,
                 fth.trx_id,
		 fth.trx_number,
                 ftb.initiator_id,
                 ftb.from_le_id,
                 ftb.from_ledger_id,
                 fth.recipient_id,
                 fth.to_le_id,
                 ftb.trx_type_id,
                 ftb.exchange_rate_type,
                 ftb.currency_code,
                 ledgers.currency_code,
                 ftb.description,
                 ftb.gl_date,
                 ftb.batch_id,
                 fth.trx_id,
                 ftb.from_ledger_id,
                 ftb.batch_date

     FROM        FUN_TRX_BATCHES ftb,
                 FUN_TRX_HEADERS fth,
                 GL_LEDGERS ledgers

     WHERE       fth.batch_id= ftb.batch_id
     AND         fth.status='APPROVED'
     AND         ledgers.ledger_id = ftb.from_ledger_id
     AND         trunc(ftb.gl_date) between trunc(nvl(l_date_low,ftb.gl_date-1))
                             and trunc(nvl(l_date_high, ftb.gl_date+1))
     AND         nvl(p_org_id,1) = nvl2(p_org_id,fun_tca_pkg.get_ou_id(ftb.initiator_id),1)
     AND         ftb.from_le_id = nvl(p_le_id,ftb.from_le_id)
     AND         fth.invoice_flag = 'Y'
     ORDER BY    ftb.initiator_id;

      -- cursor to retrieve the distribution information

     CURSOR c_dist (p_trx_id IN NUMBER) IS
     SELECT
                 DECODE(FDL.dist_type_flag, 'L',
                                            decode(fdl.amount_cr,
                                                    0, fdl.amount_dr * (-1),
                                                    NULL, fdl.amount_dr * (-1),
                                                    fdl.amount_cr),
                                       'R', NULL,
                                            NULL),
                 DECODE(FDL.dist_type_flag, 'L', NULL,
                                       'R', 100,
                                            NULL),
                 DECODE(FDL.dist_type_flag, 'R', 'REC',
                                            'L', 'REV',
                                            NULL),
                 fdl.ccid,
                 fth.batch_id,
                 fth.trx_id,
                 ftl.line_id
     FROM        FUN_TRX_HEADERS fth,
                 FUN_TRX_LINES ftl,
                 FUN_DIST_LINES fdl
     WHERE       ftl.trx_id=fth.trx_id
     AND         fth.trx_id = p_trx_id
     AND         ftl.line_id=fdl.line_id
     AND         fdl.party_type_flag='I';

    CURSOR period_open_csr (p_trx_date   DATE,
                            p_ledger_id  NUMBER) IS
        SELECT COUNT(*)
        FROM   gl_period_statuses glps
        WHERE  TRUNC(p_trx_date) BETWEEN glps.start_date AND glps.end_date
        AND    glps.application_id = 222
        AND    glps.set_of_books_id = p_ledger_id
        AND    glps.adjustment_period_flag <> 'Y'
        AND    glps.closing_status IN ('O','F');

CURSOR ou_valid_csr (p_ou_id    NUMBER,
                     p_trx_date DATE) IS
      SELECT count(*)
      FROM hr_operating_units ou
      WHERE organization_id = p_ou_id
      AND date_from <= p_trx_date
      AND NVL(date_to, p_trx_date) >= p_trx_date;

--Bug: 9052792. Cursor to get the term_id from site level.

CURSOR c_site_term(p_site_use_id NUMBER) IS
	select PAYMENT_TERM_ID
	from HZ_CUST_SITE_USES_ALL
	where site_use_code = 'BILL_TO'
	and site_use_id = p_site_use_id;

--Bug: 9052792. Cursor to get the term_id from customer account level.

CURSOR c_account_term(p_cust_acct_id NUMBER) IS
	select STANDARD_TERMS
	from HZ_CUSTOMER_PROFILES
	where cust_account_id = p_cust_acct_id;
BEGIN

     l_error := 1;
     l_counter := 0;
     l_date_low := TRUNC(fnd_date.canonical_to_date(p_date_low));
     l_date_high:= TRUNC(fnd_date.canonical_to_date(p_date_high));
     l_previous_org_id := 0;
     l_ou_id := 0;

     IF (p_run_autoinvoice_import = 'Y') THEN
        l_run_autoinvoice_import := 'Yes';
     ELSE
        l_run_autoinvoice_import := 'No';
     END IF;

     IF (p_org_id is not null) THEN
        select hr.name into l_org_name from hr_operating_units hr
        where hr.organization_id = p_org_id;
     END IF;

     IF (p_le_id is not null) THEN
        select xle.name into l_le_name from xle_entity_profiles xle
        where xle.legal_entity_id = p_le_id;
     END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '                   Transfer Intercompany Transactions to Receivables Report        Date: '||to_char(sysdate,'DD-MON-YYYY HH:MM'));
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        Operating Unit: ' || l_org_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'          Legal Entity: ' || l_le_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'          GL Date From: ' || to_char(l_date_low, 'DD-MON-YYYY'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'            GL Date To: ' || to_char(l_date_high,'DD-MON-YYYY'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Submit AR Auto Invoice: ' || l_run_autoinvoice_import);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Batch Number        Transaction Number  Transfer Status' );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'------------        ------------------  ----------------');


     open c_info;

     Loop

     fetch c_info into
      l_batch_id,
      l_batch_num,
      l_trx_id,
      l_trx_num,
      l_initiator_id,
      l_le_id,
      l_ledger_id,
      l_recipient_id,
      l_ap_le_id,
      l_trx_type_id,
      l_line.conversion_type,
      l_line.currency_code,
      l_ledger_currency_code,
      l_line.description,
      l_line.gl_date,
      l_line.interface_line_attribute1,
      l_line.interface_line_attribute2,
      l_line.set_of_books_id,
      l_line.trx_date;

     exit when c_info%NOTFOUND;
     l_counter := l_counter + 1;

     -- check AR Setup for records

     -- retrieve l_ou_id and l_ap_ou_id
     l_ou_id := FUN_TCA_PKG.get_ou_id (l_initiator_id);
     l_ap_ou_id := FUN_TCA_PKG.get_ou_id(l_recipient_id);

     IF (l_ou_id is null)  then
                l_error := 2;
                fnd_message.set_name('FUN','FUN_XFER_AR_IOU_NULL');
     END IF;

     IF  (l_ap_ou_id is null) then
                l_error := 2;
                fnd_message.set_name('FUN','FUN_XFER_AR_ROU_NULL');
     END IF;

     -- Validate AR OU Id.
     OPEN ou_valid_csr( l_ou_id, l_line.trx_date);
     FETCH ou_valid_csr INTO l_count;
     CLOSE ou_valid_csr;
     IF l_count < 1
     THEN
         l_error := 2;
         fnd_message.set_name('FUN','FUN_XFER_AR_IOU_NULL');
     END IF;
     -- ER:8288979. Passing l_trx_id.
     -- Retrieve memo line, ar trx type
       fun_trx_types_pub.Get_Trx_Type_Map(l_ou_id, l_trx_type_id,
                                       l_line.trx_date, l_trx_id,
                                       l_memo_line_id, l_memo_line_name,
                                       l_ar_trx_type_id, l_ar_trx_type_name,
                                       l_default_term_id);

     IF (l_memo_line_name IS NULL) OR (l_ar_trx_type_name IS NULL)  THEN
                l_error := 2;
                fnd_message.set_name('FUN','FUN_XFER_AR_MEMO_NULL');
     END IF;


     -- Check if AR period open

     l_ar_period_count := 0;

     OPEN period_open_csr(l_line.trx_date,
                          l_ledger_id);

     FETCH period_open_csr INTO l_ar_period_count;

     IF l_ar_period_count < 1 THEN
       l_error := 2;
       fnd_message.set_name('FUN','FUN_XFER_AR_PERIOD');
     END IF;

     CLOSE period_open_csr;

    -- Obtain the customer_id and address_id


   -- For customer association, transacting LE is actually the
   -- recipient LE.
   l_success :=
        FUN_TRADING_RELATION.get_customer(
            p_source       => 'INTERCOMPANY',
            p_trans_le_id  => l_ap_le_id,
            p_tp_le_id     => l_le_id,
            p_trans_org_id => l_ap_ou_id,
            p_tp_org_id    => l_ou_id,
            p_trans_organization_id => l_recipient_id,
            p_tp_organization_id => l_initiator_id,
            x_msg_data     => x_msg_data,
            x_cust_acct_id => l_customer_id,
            x_cust_acct_site_id  => l_address_id,
            x_site_use_id  => l_site_use_id);

   IF (l_success<>true) OR (l_customer_id is NULL) THEN
           l_error := 2;
           fnd_message.set_name('FUN','FUN_XFER_AR_CST_ID_NULL');
   END IF;
   IF  (l_address_id is NULL) THEN
           l_error := 2;
           fnd_message.set_name('FUN','FUN_XFER_AR_ADD_ID_NULL');
   END IF;

   IF (has_valid_conversion_rate(l_line.currency_code,l_ledger_currency_code,l_line.conversion_type,l_line.gl_date)=0) THEN
           l_error := 2;
           fnd_message.set_name('FUN', 'FUN_CONV_RATE_NOT_FOUND');
   END IF;
	--Bug: 9052792.
	    l_term_id := NULL;

	    OPEN c_site_term (l_site_use_id);
            FETCH c_site_term INTO l_term_id;
            IF c_site_term%NOTFOUND THEN
                NULL;
            END IF;
            CLOSE c_site_term;

	    IF l_term_id IS NULL THEN
		    OPEN c_account_term (l_customer_id);
		    FETCH c_account_term INTO l_term_id;
		    IF c_account_term%NOTFOUND THEN
			NULL;
		    END IF;
		    CLOSE c_account_term;
	    END IF;
		--Bug: 9126518
	    IF (l_term_id IS NOT NULL AND l_default_term_id IS NOT NULL) THEN
		l_default_term_id := l_term_id;
	    END IF;

      -- transfer to RA_INTERFACE_LINES


  IF l_error = 1 THEN

     open c_line(l_batch_id, l_trx_id);

     LOOP

     -- Amounts Transferred to AR should be
     -- Init Trx Amount: 1000 Cr,  AR Amount: -1000
     -- Init Trx Amount: -1000 Cr, AR Amount: 1000
     -- Init Trx Amount: 1000 Dr,  AR Amount: 1000
     -- Init Trx Amount: -1000 Dr, AR Amount: -1000

     FETCH c_line INTO

      l_line.amount,
      l_line.interface_line_attribute3;

     EXIT WHEN c_line%NOTFOUND;

      l_line.org_id:=  l_ou_id;

-- Bug 9634573 fetched src name from the table

	SELECT name into l_line.BATCH_SOURCE_NAME FROM
	RA_BATCH_SOURCES_ALL WHERE  BATCH_SOURCE_ID =  22 AND org_id = l_ou_id;


      l_line.INTERFACE_LINE_CONTEXT:='INTERNAL_ALLOCATIONS';
      l_line.LINE_TYPE:='LINE';
     -- l_line.UOM_NAME :='Each';    -- Bug No: 8291939
      l_count:=l_count+1;


  l_line.orig_system_bill_customer_id:= l_customer_id;
  l_line.orig_system_bill_address_id := l_address_id;



  -- Bug: 6788142 Added PRIMARY_SALESREP_ID field in the insert query.
  -- insert into AR Interface table
  -- Bug: 7271703 Populating the INTERFACE_LINE_ATTRIBUTE4 with the
  -- batch number.
  INSERT INTO RA_INTERFACE_LINES_ALL
   (
     AMOUNT,
     BATCH_SOURCE_NAME,
     CONVERSION_TYPE,
     CURRENCY_CODE,
     CUST_TRX_TYPE_ID,
     CUST_TRX_TYPE_NAME,
     DESCRIPTION,
     GL_DATE,
     INTERFACE_LINE_ATTRIBUTE1,
     INTERFACE_LINE_ATTRIBUTE2,
     INTERFACE_LINE_ATTRIBUTE3,
     INTERFACE_LINE_ATTRIBUTE4,
     INTERFACE_LINE_CONTEXT,
     LINE_TYPE,
     MEMO_LINE_ID,
     MEMO_LINE_NAME,
     ORG_ID,
     ORIG_SYSTEM_BILL_ADDRESS_ID,
     ORIG_SYSTEM_BILL_CUSTOMER_ID,
     SET_OF_BOOKS_ID,
     TRX_DATE,
     TAXABLE_FLAG,
     TERM_ID,
     LEGAL_ENTITY_ID,
     SOURCE_EVENT_CLASS_CODE,
     PRIMARY_SALESREP_ID
      )
   VALUES
   (
     l_line.AMOUNT,
     l_line.BATCH_SOURCE_NAME,
     l_line.CONVERSION_TYPE,
     l_line.CURRENCY_CODE,
     l_ar_trx_type_id,
     l_ar_trx_type_name,
     NVL(l_line.DESCRIPTION,
         'Transactions from Global Intercompany'),
     l_line.GL_DATE,
     l_line.INTERFACE_LINE_ATTRIBUTE1,
     l_line.INTERFACE_LINE_ATTRIBUTE2,
     l_line.INTERFACE_LINE_ATTRIBUTE3,
     l_batch_num,
     l_line.INTERFACE_LINE_CONTEXT,
     l_line.LINE_TYPE,
     l_memo_line_id,
     l_memo_line_name,
     l_line.ORG_ID,
     l_line.ORIG_SYSTEM_BILL_ADDRESS_ID,
     l_line.ORIG_SYSTEM_BILL_CUSTOMER_ID,
     l_line.SET_OF_BOOKS_ID,
     l_line.TRX_DATE,
	 --Bug 9285035: Changed the value From 'S' to 'Y'
     --'S'  ,
	 'Y'  ,
     l_default_term_id,
     l_le_id,
     'INTERCOMPANY_TRX',
     '-3'
    );

  -- Bug No. 6788142. Inserting into RA_INTERFACE_SALESCREDITS_ALL table

  INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
   (
     INTERFACE_LINE_CONTEXT ,
     INTERFACE_LINE_ATTRIBUTE1 ,
     INTERFACE_LINE_ATTRIBUTE2 ,
     INTERFACE_LINE_ATTRIBUTE3 ,
     INTERFACE_LINE_ATTRIBUTE4 ,
     INTERFACE_LINE_ATTRIBUTE5 ,
     INTERFACE_LINE_ATTRIBUTE6 ,
     INTERFACE_LINE_ATTRIBUTE7 ,
     INTERFACE_LINE_ATTRIBUTE8 ,
     INTERFACE_LINE_ATTRIBUTE9 ,
     INTERFACE_LINE_ATTRIBUTE10 ,
     INTERFACE_LINE_ATTRIBUTE11 ,
     INTERFACE_LINE_ATTRIBUTE12 ,
     INTERFACE_LINE_ATTRIBUTE13 ,
     INTERFACE_LINE_ATTRIBUTE14 ,
     INTERFACE_LINE_ATTRIBUTE15,
     SALES_CREDIT_PERCENT_SPLIT,
     SALES_CREDIT_TYPE_ID,
     SALESREP_ID,
     ORG_ID
   )
   VALUES
   (
     l_line.INTERFACE_LINE_CONTEXT,
     l_line.INTERFACE_LINE_ATTRIBUTE1,
     l_line.INTERFACE_LINE_ATTRIBUTE2,
     l_line.INTERFACE_LINE_ATTRIBUTE3,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     '100',
     '1',
     '-3',
     l_line.ORG_ID
   );

      IF  l_previous_org_id <> l_ou_id THEN
          ORG_ID_TABLE(org_id_table.count+1) := l_ou_id;
          l_previous_org_id := l_ou_id;
      END IF;

      End Loop; --c_line
      Close C_Line;


-- Insert into the AR distribution table

      -- Amounts Transferred to AR should be
      -- Ini Dst Amount: 1000 Dr,  AR Amount: -1000
      -- Ini Dst Amount: -1000 Dr, AR Amount: 1000
      -- Ini Dst Amount: 1000 Cr,  AR Amount: 1000
      -- Ini Dst Amount: -1000 Cr, AR Amount: -1000

      open c_dist(l_trx_id);
      LOOP

      FETCH c_dist INTO
     l_dist_line.AMOUNT,
     l_dist_line.percent,
     l_dist_line.account_class,
     l_dist_line.CODE_COMBINATION_ID,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE1,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE2,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE3;

     exit when c_dist%NOTFOUND;

     l_dist_line.ORG_ID :=l_ou_id;
     l_dist_line.INTERFACE_LINE_CONTEXT:='INTERNAL_ALLOCATIONS';

   -- Insert the value into the distribution table

    INSERT INTO RA_INTERFACE_DISTRIBUTIONS_ALL
    (
     ACCOUNT_CLASS,
     AMOUNT,
     percent,
     CODE_COMBINATION_ID,
     INTERFACE_LINE_ATTRIBUTE1,
     INTERFACE_LINE_ATTRIBUTE2,
     INTERFACE_LINE_ATTRIBUTE3,
	 INTERFACE_LINE_ATTRIBUTE4,
     INTERFACE_LINE_CONTEXT,
     ORG_ID
     )
     VALUES
     (
     l_dist_line.ACCOUNT_CLASS,
     l_dist_line.AMOUNT,
     l_dist_line.percent,
     l_dist_line.CODE_COMBINATION_ID,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE1,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE2,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE3,
	 l_batch_num,
     l_dist_line.INTERFACE_LINE_CONTEXT,
     l_dist_line.ORG_ID
     );

      END LOOP; --c_dist
      CLOSE c_dist;

      fnd_message.set_name('FUN','FUN_XFER_SUCCESS');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(l_batch_num,1,20),20)||rpad(substr(l_trx_num,1,15),20)||fnd_message.get);

        -- update transaction status

        FUN_TRX_PVT.update_trx_status(p_api_version   =>1.0,
                                  x_return_status =>l_return_status,
                                  x_msg_count     => l_message_count,
                                  x_msg_data      => l_message_data,
                                  p_trx_id        => l_trx_id,
                                  p_update_status_to => 'XFER_AR');

        -- Handle the API call return

        IF l_return_status = FND_API.G_RET_STS_ERROR   THEN

            raise FND_API.G_EXC_ERROR;
        END IF;


        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN

            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  ELSIF l_error=2 THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(substr(l_batch_num,1,20),20)||rpad(substr(l_trx_num,1,15),20)||fnd_message.get);
  END IF; -- l_error
  l_error := 1;

 End Loop; -- c_info

 close c_info;
  FND_FILE.NEW_LINE(FND_FILE.OUTPUT,2 );
  IF (l_counter = 0) THEN
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   *****No Data Found*****');
  ELSE
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                   *****End Of Report*****');
  END IF;

 COMMIT;


 IF p_run_autoinvoice_import='Y' and org_id_table.count>0 THEN
   FOR I in  org_id_table.First .. org_id_table.last
   LOOP
-- Bug 9634573 fetched src name from the table

	SELECT name into l_src_name FROM
	RA_BATCH_SOURCES_ALL WHERE  BATCH_SOURCE_ID =  22 AND org_id = org_id_table(I);

      FND_REQUEST.set_org_id(org_id_table(I));
      l_request_id := FND_REQUEST.SUBMIT_REQUEST('AR', 'RAXMTR','','', FALSE,
                 '1',org_id_table(I),22,l_src_name, trunc(sysdate),
                  '','','','','','','','','','','',
                  '','','','','','','','','', 'YES','');

      IF l_request_id <> 0 THEN
        fnd_file.put_line(fnd_file.log,'AR Auto Invoice Program submitted for Org ID: ' || org_id_table(I)||' with Request id: ' || l_request_id);
        commit;
      ELSE
        RAISE Request_Submission_Failure;
      END IF;
   END LOOP;
  END IF;


 EXCEPTION
 WHEN Request_Submission_Failure THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in submitting AutoInovice Import Process');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error:' || sqlcode || sqlerrm);
 WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'No Data Found');
 WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error:' || sqlcode || sqlerrm);
    retcode := 2;
    end;

 END FUN_AR_BATCH_TRANSFER;



/
