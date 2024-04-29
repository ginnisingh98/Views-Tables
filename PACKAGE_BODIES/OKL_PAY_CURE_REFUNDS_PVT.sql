--------------------------------------------------------
--  DDL for Package Body OKL_PAY_CURE_REFUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_CURE_REFUNDS_PVT" as
/* $Header: OKLRPCRB.pls 120.16 2007/09/20 16:41:19 cklee noship $ */

    G_MODULE VARCHAR2(255) := 'okl.cure.refund.OKL_PAY_CURE_REFUNDS_PVT';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;


--private procedure
/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
        fnd_message.set_token('API_NAME', p_api_name);
        fnd_message.set_token('MISSING_PARAM', p_param_name);
        fnd_msg_pub.add;

END AddMissingArgMsg;

/**Name   AddFailMsg
  **Appends to a message  the name of the object and
  ** the operation (insert, update ,delete)
*/

PROCEDURE AddfailMsg
  ( p_object	    IN	VARCHAR2,
    p_operation 	IN	VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('OKL', 'OKL_FAILED_OPERATION');
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('OPERATION', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;


PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_message       OUT NOCOPY VARCHAR2) IS


  l_msg_list        VARCHAR2(32627) := '';
  l_temp_msg        VARCHAR2(32627);
  l_appl_short_name  VARCHAR2(50) ;
  l_message_name    VARCHAR2(50) ;
  l_id              NUMBER;
  l_message_num     NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(32627);

  Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
         SELECT  application_id
         FROM    fnd_application_vl
         WHERE   application_short_name = x_short_name;

  Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
         SELECT  msg.message_number
         FROM    fnd_new_messages msg, fnd_languages_vl lng
         WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;

BEGIN
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_message := l_msg_list;


END Get_Messages;



PROCEDURE create_refund(
                p_pay_cure_refunds_rec  IN pay_cure_refunds_rec_type
               ,x_cure_refund_id        OUT NOCOPY  NUMBER
               ,x_return_status         OUT NOCOPY VARCHAR2
               ,x_msg_count             OUT NOCOPY NUMBER
               ,x_msg_data              OUT NOCOPY VARCHAR2
               )IS

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_message  VARCHAR2(32627);


l_cure_refund_id okl_cure_refunds.cure_refund_id%type;
l_cure_refund_number okl_cure_refunds.refund_number%type;
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_REFUND';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

l_okl_application_id NUMBER(3) := 540;
l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
lX_dbseqnm          VARCHAR2(2000):= '';
lX_dbseqid          NUMBER(38):= NULL;

-----------------------------------------------------------
-- Declare records: Payable Invoice Headers, Lines and Distributions
------------------------------------------------------------
lp_tapv_rec         okl_tap_pvt.tapv_rec_type;
lx_tapv_rec     	okl_tap_pvt.tapv_rec_type;
lp_tplv_rec     	okl_tpl_pvt.tplv_rec_type;
lx_tplv_rec     	okl_tpl_pvt.tplv_rec_type;

/* ankushar 22-JAN-2007
   added table definitions
   start changes
*/
lp_tplv_tbl     	      okl_tpl_pvt.tplv_tbl_type;
lx_tplv_tbl     	      okl_tpl_pvt.tplv_tbl_type;
/* ankushar end changes*/

l_tmpl_identify_rec Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
l_dist_info_rec     Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
l_ctxt_val_tbl      okl_execute_formula_pvt.ctxt_val_tbl_type;
l_acc_gen_primary_key_tbl  Okl_Account_Generator_Pvt.primary_key_tbl;
l_template_tbl      OKL_TMPT_SET_PUB.avlv_tbl_type;
l_amount_tbl        Okl_Account_Dist_Pvt.AMOUNT_TBL_TYPE;

lp_crfv_rec         okl_crf_pvt.crfv_rec_type;
lx_crfv_rec     	okl_crf_pvt.crfv_rec_type;



CURSOR org_id_csr ( p_khr_id NUMBER ) IS
    	   SELECT chr.authoring_org_id
    	   FROM okc_k_headers_b chr
    	   WHERE id =  p_khr_id;

CURSOR sob_csr ( p_org_id  NUMBER ) IS
    	   SELECT hru.set_of_books_id
    	   FROM HR_OPERATING_UNITS HRU
    	   WHERE ORGANIZATION_ID = p_org_id;

CURSOR try_id_csr IS
     	   SELECT id
    	   FROM okl_trx_types_tl
    	   WHERE name = 'Disbursement'
           AND LANGUAGE = USERENV('LANG');

/* --User Defined Stream fix
 CURSOR stream_type_csr IS
      SELECT id
      FROM   okl_strm_type_tl
      WHERE  name = 'CURE'
      AND    LANGUAGE = USERENV('LANG');
*/
x_primary_sty_id number;
l_khr_id number;

 cursor chk_refund_number(p_refund_number IN VARCHAR2) IS
        select refund_number
        from okl_cure_refunds
        where refund_number =p_refund_number;

  CURSOR c_app
  IS
  select a.application_id
  from FND_APPLICATION a
  where APPLICATION_SHORT_NAME = 'OKL';


BEGIN

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : START ');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

      SAVEPOINT CREATE_REFUND;
      -- Initialize message list if p_init_msg_list is set to TRUE.

          FND_MSG_PUB.initialize;


       /*** Logic for refunds ********
       ** 1) Invoke the common disbursement API for ap header and line creation
       ** 2) create accounting record
       ** 3) create cure refund record
       **/

    -- STEP 1
    --populate the ap invoice header table (okl_trx_ap_invoices_b)
      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before creating TAP record ');
         END IF;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

  	  lp_tapv_rec.org_id := NULL;
  	  OPEN 	org_id_csr ( p_pay_cure_refunds_rec.chr_id) ;
	  FETCH	org_id_csr INTO lp_tapv_rec.org_id;
	  CLOSE	org_id_csr;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tapv_rec.org_id : '||lp_tapv_rec.org_id);

      IF (lp_tapv_rec.org_id IS NULL)  THEN
          AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'org_id' );
                    RAISE FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.org_id '||
                                       lp_tapv_rec.org_id);
               END IF;
           END IF;
 	 END IF;

 	 OPEN	sob_csr ( lp_tapv_rec.org_id );
	 FETCH	sob_csr INTO lp_tapv_rec.set_of_books_id;
	 CLOSE	sob_csr;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tapv_rec.set_of_books_id : '||lp_tapv_rec.set_of_books_id);

     IF (lp_tapv_rec.set_of_books_id IS NULL)  THEN
         AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'set_of_books_id' );
                    RAISE FND_API.G_EXC_ERROR;
    ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.set_of_books_id'||
                                      lp_tapv_rec.set_of_books_id);
             END IF;
          END IF;
 	 END IF;


      lp_tapv_rec.try_id := NULL;
      OPEN  try_id_csr;
	  FETCH try_id_csr INTO lp_tapv_rec.try_id;
	  CLOSE try_id_csr;
      IF (lp_tapv_rec.try_id IS NULL)  THEN
         AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'try_id' );
                    RAISE FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.try_id'||
                                     lp_tapv_rec.try_id);
             END IF;
          END IF;
 	 END IF;
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tapv_rec.try_id : '||lp_tapv_rec.try_id);
  	  lp_tapv_rec.invoice_number := NULL;

--
-- display specific application error if 'OKL Lease Pay Invoices'
-- has not been setup or setup incorrectly
--

    OPEN c_app;
    FETCH c_app INTO l_okl_application_id;
    CLOSE c_app;
    l_okl_application_id := nvl(l_okl_application_id,540);

  BEGIN
      lp_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
			(appid      =>  l_okl_application_id,
	 		 cat_code    =>  l_document_category,
			 sobid       =>  lp_tapv_rec.set_of_books_id,
			 met_code    =>  'A',
			 trx_date    =>  SYSDATE,
			 dbseqnm     =>  lx_dbseqnm,
			 dbseqid     =>  lx_dbseqid);

   EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = 100 THEN
          fnd_message.set_name('OKL', 'OKL_PAY_INV_SEQ_CHECK');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tapv_rec.invoice_number : '||lp_tapv_rec.invoice_number);

      IF (lp_tapv_rec.invoice_number IS NULL)  THEN
         AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'invoice_number' );
                    RAISE FND_API.G_EXC_ERROR;
     ELSE
         IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.invoice_number'||
                                    lp_tapv_rec.invoice_number);
            END IF;
         END IF;

  	 END IF;


     lp_tapv_rec.vendor_invoice_number     := lp_tapv_rec.invoice_number;
     -- sjalasut, commented the assignment of khr_id below. khr_id would henceforth referred
     -- in l_tplv_rec (internal disbursements lines table). changes made as part of OKLR12B
     -- disbursements project.
      lp_tapv_rec.khr_id                    := p_pay_cure_refunds_rec.chr_id; -- cklee 09/20/2007
--     lp_tapv_rec.khr_id                    := NULL;

     lp_tapv_rec.ipvs_id                   := p_pay_cure_refunds_rec.vendor_site_id;
     lp_tapv_rec.ippt_id                   := p_pay_cure_refunds_rec.pay_terms;
     lp_tapv_rec.payment_method_code       := p_pay_cure_refunds_rec.payment_method_code;
     lp_tapv_rec.currency_code             := p_pay_cure_refunds_rec.currency;
     lp_tapv_rec.date_entered              := sysdate;
     lp_tapv_rec.date_invoiced             := p_pay_cure_refunds_rec.invoice_date;
     lp_tapv_rec.amount                    := p_pay_cure_refunds_rec.refund_amount;
     lp_tapv_rec.trx_status_code           := 'PENDINGI';
     lp_tapv_rec.object_version_number     := 1;
					--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
    lp_tapv_rec.legal_entity_id            := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_pay_cure_refunds_rec.chr_id);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tapv_rec.amount : '||lp_tapv_rec.amount);
    -- not sure of these 4 variable
    /* invoice_type,
       invoice_category_code,
       pay_group_lookup_code,
       nettable_yn,
       if invoice_type is credit then amount is -ve
     */

    -- STEP 2
    --populate the line table (okl_txl_ap_inv_lns_b)
    -- sjalasut, added code to have khr_id populated from the cursor p_pay_cure_refunds_rec
    -- changes made as part of OKLR12B disbursements project
      lp_tplv_rec.khr_id := p_pay_cure_refunds_rec.chr_id;

      lp_tplv_rec.amount		      :=  lp_tapv_rec.amount;
      lp_tplv_rec.inv_distr_line_code     :=  'MANUAL';
      lp_tplv_rec.line_number	      :=  1;
      lp_tplv_rec.org_id		      :=  lp_tapv_rec.org_id;
      lp_tplv_rec.disbursement_basis_code :=  'BILL_DATE';
   	  lp_tplv_rec.object_version_number   := 1;


      /* what about other columns
        sty_id,
       * is disbursement_basis_code= 'bill_date'
       */

/*
        FOR stream_rec IN stream_type_csr
        LOOP
            lp_tplv_rec.sty_id := stream_rec.id;
            IF PG_DEBUG < 11  THEN
              okl_debug_pub.logmessage ('sty_id ' ||stream_rec.id);
            END IF;
        END LOOP;
*/
    -- sjalasut, modified the below assignment to have khr_id populated from the lp_tplv_rec
    -- changes made as part of OKLR12B disbursements project
    -- l_khr_id := lp_tapv_rec.khr_id;
    l_khr_id := lp_tplv_rec.khr_id;

    OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id => l_khr_id,
    			p_primary_sty_purpose => 'CURE',
    			x_return_status => l_return_status,
    			x_primary_sty_id => x_primary_sty_id
    			);

    lp_tplv_rec.sty_id  := x_primary_sty_id;

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS or x_primary_sty_id is null)  THEN
       Get_Messages (l_msg_count,l_message);
       IF PG_DEBUG < 11  THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
        END IF;
       END IF;
       raise FND_API.G_EXC_ERROR;

    ELSE

       IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'sty_id ' ||x_primary_sty_id);
            END IF;
       END IF;

    END IF;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tplv_rec.sty_id : '||lp_tplv_rec.sty_id);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : lp_tplv_rec.amount : '||lp_tplv_rec.amount);
  --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TXL_AP_INV_LNS_B ',
                  p_operation =>  'CREATE' );

/* ankushar 23-JAN-2007
   Call to the common Disbursement API
   start changes
*/

   -- Add tpl_rec to table
-- start:
--cklee 06/04/2007 Reverse the original code back due to the duplicated
-- accounting entries will be created
/*
         lp_tplv_tbl(1) := lp_tplv_rec;

   --Call the commong disbursement API to create transactions
        Okl_Create_Disb_Trans_Pvt.create_disb_trx(
             p_api_version      =>   1.0
            ,p_init_msg_list    =>   'F'
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tapv_rec         =>   lp_tapv_rec
            ,p_tplv_tbl         =>   lp_tplv_tbl
            ,x_tapv_rec         =>   lx_tapv_rec
            ,x_tplv_tbl         =>   lx_tplv_tbl);
*/
    OKL_TRX_AP_INVOICES_PUB.INSERT_TRX_AP_INVOICES(
      p_api_version   => 1.0,
      p_init_msg_list => 'F',
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => lp_tapv_rec,
      x_tapv_rec      => lx_tapv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : OKL_TRX_AP_INVOICES_PUB.INSERT_TRX_AP_INVOICES : '||x_return_status);
     IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
       IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
         END IF;
       END IF;
       raise FND_API.G_EXC_ERROR;
     ELSE
       IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tapv_rec.id'
                                     ||lx_tapv_rec.id);
         END IF;
       END IF;
       FND_MSG_PUB.initialize;
    END IF;

      lp_tplv_rec.tap_id := lx_tapv_rec.id;

      OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS(
        p_api_version   => 1.0,
        p_init_msg_list => 'F',
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_tplv_rec      => lp_tplv_rec,
        x_tplv_rec      => lx_tplv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS : '||x_return_status);

     IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
       IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
         END IF;
       END IF;
       raise FND_API.G_EXC_ERROR;
     ELSE
       IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tplv_rec.id'
                                     ||lx_tplv_rec.id);
         END IF;
       END IF;
       FND_MSG_PUB.initialize;
    END IF;
-- end:
--cklee 06/04/2007 Reverse the original code back due to the duplicated
-- accounting entries will be created
/* ankushar end changes */

   --Step 4
   --create cure refund record
     lp_crfv_rec.refund_number         := p_pay_cure_refunds_rec.refund_number;
     lp_crfv_rec.chr_id                := p_pay_cure_refunds_rec.chr_id;
     lp_crfv_rec.vendor_site_id        := p_pay_cure_refunds_rec.vendor_site_id;
     lp_crfv_rec.disbursement_amount   := p_pay_cure_refunds_rec.refund_amount;
     lp_crfv_rec.total_refund_due      := p_pay_cure_refunds_rec.refund_amount_due;
     lp_crfv_rec.refund_date           := p_pay_cure_refunds_rec.invoice_date;
     lp_crfv_rec.object_version_number := 1;
     lp_crfv_rec.tap_id                := lx_tapv_rec.id;
     lp_crfv_rec.cure_refund_header_id :=p_pay_cure_refunds_rec.refund_header_id;

    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUNDS ',
                  p_operation =>  'CREATE' );

      OKL_cure_refunds_pub.insert_cure_refunds(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crfv_rec        => lp_crfv_rec
                          ,x_crfv_rec        => lx_crfv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : OKL_cure_refunds_pub.insert_cure_refunds : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_crfv_rec.cure_refund_id'
                                     ||lx_crfv_rec.cure_refund_id);
           END IF;
          x_cure_refund_id :=lx_crfv_rec.cure_refund_id;
    END IF;

    IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'* End of Procedure'||
                                 '=>OKL_PAY_CURE_REFUNDS_PVT.'||
                                  'create_refund *');

     END IF;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund : START ');

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_REFUND;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_REFUND;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_REFUND;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','CREATE_REFUND');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END create_refund;

PROCEDURE check_contract(p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
                        ,x_return_status        OUT NOCOPY VARCHAR2
                        ,x_contract_number      OUT NOCOPY VARCHAR2) IS

l_id1                  VARCHAR2(40);
l_id2                  VARCHAR2(200);
l_rule_value           VARCHAR2(2000);
l_days_allowed         NUMBER   :=0;
l_program_id okl_k_headers.khr_id%TYPE;
l_return_status VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;

cursor c_program_id (p_contract_id IN NUMBER ) IS
       select khr_id from okl_k_headers
       where id= p_contract_id;



-- ASHIM CHANGE - START


/*CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                         p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
          ,ar_payment_schedules_all aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class IN ('INV','CM')
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0;*/

CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                         p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
          ,ar_payment_schedules_all aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class IN ('INV','CM')
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0;


-- ASHIM CHANGE - END



TYPE c_getcontractsCurTyp IS REF CURSOR;
  c_getcontracts c_getcontractsCurTyp;  -- declare cursor variable

l_contract_id       okl_cure_refunds_dtls_uv.contract_id%TYPE;
l_contract_number   okl_cure_refunds_dtls_uv.contract_number%TYPE;
l_idx INTEGER;
l_amount_past_due NUMBER;
BEGIN

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : START ');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Start of check_contract' );

       END IF;
       IF p_pay_cure_refunds_rec.chr_id is not null THEN
          -- then check for this contract only
--start changed by abhsaxen for Bug#6174484
          OPEN c_getcontracts
          FOR
	SELECT st.khr_id contract_id,
	     cn.contract_number
	   FROM okl_xtl_sell_invs_v xls,
	     okl_txl_ar_inv_lns_v til,
	     okl_trx_ar_invoices_v tai,
	     okc_k_headers_b cn,
	     ar_payment_schedules_all ps,
	     ar_receivable_applications_all arapp,
	     okl_cnsld_ar_strms_b st
	   WHERE st.id = xls.lsm_id
	   AND st.receivables_invoice_id = ps.customer_trx_id
	   AND ps.class IN('INV',    'CM')
	   AND arapp.applied_payment_schedule_id = ps.payment_schedule_id
	   AND cn.id = st.khr_id(+)
	   AND tai.id = til.tai_id
	   AND til.id = xls.til_id
	   AND tai.cpy_id IS NOT NULL
	   and st.khr_id = p_pay_cure_refunds_rec.chr_id;
--end changed by abhsaxen for Bug#6174484
       ELSE
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'in else part of ref cursor for check contract' );
            END IF;
           --check for other 2 types;
            if p_pay_cure_refunds_rec.REFUND_TYPE ='VENDOR_SITE' THEN
              OPEN c_getcontracts
              FOR
--start changed by abhsaxen for Bug#6174484
 		SELECT st.khr_id contract_id,
		  cn.contract_number
		FROM okl_xtl_sell_invs_v xls,
		  okl_txl_ar_inv_lns_b til,
		  okl_trx_ar_invoices_b tai,
		  okc_k_headers_all_b cn,
		  ar_payment_schedules_all ps,
		  ar_receivable_applications_all arapp,
		  okl_cnsld_ar_strms_b st,
		  okc_k_party_roles_b pty,
		  okc_rules_b rul,
		  okc_k_headers_b CHR,
		  po_vendors pvn,
		  po_vendor_sites_all pvs
		WHERE st.id = xls.lsm_id
		 AND st.receivables_invoice_id = ps.customer_trx_id
		 AND ps.class IN('INV',   'CM')
		 AND arapp.applied_payment_schedule_id = ps.payment_schedule_id
		 AND cn.id = st.khr_id(+)
		 AND tai.id = til.tai_id
		 AND til.id = xls.til_id
		 AND tai.cpy_id IS NOT NULL
		 AND rul.dnz_chr_id = CHR.id
		 AND rul.rule_information_category = 'COVNAG'
		 AND CHR.id = pty.chr_id
		 AND rle_code = 'OKL_VENDOR'
		 AND pty.object1_id1 = pvn.vendor_id
		 AND pvn.vendor_id = pvs.vendor_id
		 AND pvs.vendor_site_id = rul.rule_information1
		 AND CHR.id = cn.id
		 AND CHR.scs_code = 'PROGRAM'
		 AND pvs.vendor_site_id = p_pay_cure_refunds_rec.vendor_site_id
		 AND cn.currency_code = p_pay_cure_refunds_rec.currency;
--end changed by abhsaxen for Bug#6174484
            elsif p_pay_cure_refunds_rec.REFUND_TYPE ='ACROSS_SITES' THEN
             OPEN c_getcontracts
             FOR
--start changed by abhsaxen for Bug#6174484
 		SELECT st.khr_id contract_id,
		  cn.contract_number
		FROM okl_xtl_sell_invs_v xls,
		  okl_txl_ar_inv_lns_b til,
		  okl_trx_ar_invoices_b tai,
		  okc_k_headers_b cn,
		  ar_payment_schedules_all ps,
		  ar_receivable_applications_all arapp,
		  okl_cnsld_ar_strms_b st,
		  okc_k_party_roles_b pty,
		  okc_rules_b rul,
		  okc_k_headers_all_b CHR,
		  po_vendors pvn
		WHERE st.id = xls.lsm_id
		 AND st.receivables_invoice_id = ps.customer_trx_id
		 AND ps.class IN('INV',   'CM')
		 AND arapp.applied_payment_schedule_id = ps.payment_schedule_id
		 AND cn.id = st.khr_id(+)
		 AND tai.id = til.tai_id
		 AND til.id = xls.til_id
		 AND tai.cpy_id IS NOT NULL
		 AND rul.dnz_chr_id = CHR.id
		 AND rul.rule_information_category = 'COVNAG'
		 AND CHR.id = pty.chr_id
		 AND rle_code = 'OKL_VENDOR'
		 AND pty.object1_id1 = pvn.vendor_id
		 AND CHR.id = cn.id
		 AND CHR.scs_code = 'PROGRAM'
		 AND pvn.vendor_id = p_pay_cure_refunds_rec.vendor_id
		 AND cn.currency_code = p_pay_cure_refunds_rec.currency;
--end changed by abhsaxen for Bug#6174484
           end if;
      END IF;

      LOOP
          l_amount_past_due :=0;
           FETCH c_getcontracts INTO l_contract_id,l_contract_number;

           IF c_getcontracts%NOTFOUND THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'coming out from the cursor');
              END IF;
              x_return_status  := FND_API.G_RET_STS_SUCCESS;
              x_contract_number:=l_contract_number;
              EXIT;
           END IF;
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : l_contract_id : '||l_contract_id);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : l_contract_number : '||l_contract_number);

          -- Get Contract allowed value for days past due from rules
          OPEN  c_program_id(l_contract_id);
          FETCH c_program_id INTO l_program_id;
          CLOSE c_program_id;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : l_program_id : '||l_program_id);

         l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => l_program_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code		=> 'COCURE'
                             ,p_segment_number	=> 3
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : okl_contract_info.get_rule_value : '||l_return_status);

        IF l_return_status =FND_Api.G_RET_STS_SUCCESS THEN
           l_days_allowed :=nvl(l_rule_value,0);
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,
                   'l_days allowed for days past due ' || l_days_allowed);
           END IF;
        END IF;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : l_days_allowed : '||l_days_allowed);

         -- Get Past Due Amount
         OPEN  c_amount_past_due (l_contract_id,l_days_allowed);
         FETCH c_amount_past_due INTO l_amount_past_due;
         CLOSE c_amount_past_due;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : l_amount_past_due : '||l_amount_past_due);

         IF l_amount_past_due > 0 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Contract' ||l_contract_number ||
                                              ' is delinquent');
            END IF;
          x_return_status  := FND_API.G_RET_STS_ERROR;
          x_contract_number:=l_contract_number;
          EXIT;
         END IF;

     END LOOP;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Result of check Contract is '||
                                  x_return_status);
     END IF;
     CLOSE c_getcontracts;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: check_contract : END ');

END check_contract;

PROCEDURE populate_chr_tbl(p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
                           ,x_pay_tbl  OUT NOCOPY pay_cure_refunds_tbl_type) IS


total_rfnd_amt NUMBER :=0;
con_rfnd_amt   NUMBER :=0;
old_rfnd_amt   NUMBER :=0;

l_idx INTEGER;

TYPE c_getcontractsCurTyp IS REF CURSOR;
  c_getcontracts c_getcontractsCurTyp;  -- declare cursor variable

l_contract_id       okl_cure_refunds_dtls_uv.contract_id%TYPE;
l_refund_amount_due okl_cure_refunds_dtls_uv.refund_amount_due%TYPE;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Start of populate_chr_tbl' );

        END IF;
        total_rfnd_amt := p_pay_cure_refunds_rec.refund_amount;

        IF p_pay_cure_refunds_rec.REFUND_TYPE ='VENDOR_SITE' THEN
           OPEN c_getcontracts
           FOR
	          select contract_id,refund_amount_due
              from okl_cure_refunds_dtls_uv
              where vendor_site_id     =p_pay_cure_refunds_rec.vendor_site_id and
              contract_currency_code   =p_pay_cure_refunds_rec.currency;

       elsif p_pay_cure_refunds_rec.REFUND_TYPE ='ACROSS_SITES' THEN
          OPEN c_getcontracts
          FOR
             select contract_id,refund_amount_due
             from okl_cure_refunds_dtls_uv
             where vendor_id        =p_pay_cure_refunds_rec.vendor_id and
             contract_currency_code =p_pay_cure_refunds_rec.currency;


       END IF;
       LOOP
           FETCH c_getcontracts INTO l_contract_id,l_refund_amount_due;
           IF c_getcontracts%NOTFOUND THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'coming out from the cursor');
              END IF;
              EXIT;
           END IF;
           con_rfnd_amt := 0;
               --Distribute refund amount among the contracts
                IF total_rfnd_amt > 0 THEN
                   --store the old value
                   old_rfnd_amt   := total_rfnd_amt;
                   total_rfnd_amt := total_rfnd_amt - l_refund_amount_due;

                   if  total_rfnd_amt < 0 THEN
                       con_rfnd_amt :=old_rfnd_amt;
                   else
                       con_rfnd_amt :=l_refund_amount_due;
                   end if;

                   l_idx := nvl(x_pay_tbl.LAST,0) + 1;
                   x_pay_tbl(l_idx).chr_id :=l_contract_id;
                   x_pay_tbl(l_idx).refund_amount_due :=l_refund_amount_due;
                   x_pay_tbl(l_idx).refund_amount :=con_rfnd_amt;

                   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'contract id '||x_pay_tbl(l_idx).chr_id ||
                                      ' refund_amount_due '||
                                       x_pay_tbl(l_idx).refund_amount_due ||
                                       ' refund_amount '||
                                       x_pay_tbl(l_idx).refund_amount);
                   END IF;
              ELSE
                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'amount exhausted');
                     END IF;
                     EXIT;
              END IF;

          END LOOP;
          CLOSE c_getcontracts;


END  populate_chr_tbl;


PROCEDURE create_refund_hdr
             (  p_api_version            IN NUMBER
               ,p_init_msg_list          IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_cure_refund_header_id  OUT NOCOPY  NUMBER
               ,x_return_status          OUT NOCOPY VARCHAR2
               ,x_msg_count              OUT NOCOPY NUMBER
               ,x_msg_data               OUT NOCOPY VARCHAR2
               )IS

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_message  VARCHAR2(32627);
l_cure_refund_id okl_cure_refunds.cure_refund_id%type;
l_cure_refund_header_id okl_cure_refund_headers_b.cure_refund_header_id%type;
l_cure_refund_header_number okl_cure_refund_headers_b.refund_header_number%type;
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;

x_pay_tbl           pay_cure_refunds_tbl_type;

l_pay_cure_refunds_rec pay_cure_refunds_rec_type;
cursor chk_refund_number(p_refund_header_number IN VARCHAR2) IS
        select refund_header_number
        from okl_cure_refund_headers_b
        where refund_header_number =p_refund_header_number;

x_contract_number okc_k_headers_b.contract_number%TYPE;

BEGIN

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_hdr : START ');

      SAVEPOINT CREATE_REFUND_HDR;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

         --duplicate refund_number check
      OPEN 	chk_refund_number(p_pay_cure_refunds_rec.refund_number);
	  FETCH	chk_refund_number INTO l_cure_refund_header_number;
      CLOSE	chk_refund_number;
      if l_cure_refund_header_number IS NOT NULL THEN

         IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'duplicate refund number' );
             END IF;
         END IF;
          fnd_message.set_name('OKL', 'OKL_DUPLICATE_REFUND_NUMBER');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_hdr : l_cure_refund_header_number : '||l_cure_refund_header_number);

      --check if refund amount is less than total_refund_due
      IF nvl(p_pay_cure_refunds_rec.refund_amount,0)
               > nvl(p_pay_cure_refunds_rec.refund_amount_due,0) THEN
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Refund amount exceeds  total refund due' );
             END IF;
          END IF;
          fnd_message.set_name('OKL', 'OKL_CURE_REFUND_EXCEEDS');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling create refund');
         END IF;
      END IF;


      --02/27/03
      --Check if any of the contracts are in delinquency
      --We are going to check if the contract has any delinquent
      --invoices.(due_date + gracedays(from rule) < SYSDATE )
      --If it is delinquent , show error message
      --Alternate way was to check if the case with the contract
      --is in was in Delinquency or not. ( this would not consider the grace days)

       CHECK_CONTRACT(p_pay_cure_refunds_rec,
                      l_return_status,
                      x_contract_number);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_hdr : CHECK_CONTRACT : '||l_return_status);

       If l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract ' ||x_contract_number);
          END IF;
          fnd_message.set_name('OKL', 'OKL_CO_CONTRACT_DELINQUENT');
          fnd_message.set_token('CONTRACT_NUMBER', x_contract_number);
          fnd_msg_pub.add;
          raise FND_API.G_EXC_ERROR;
       END IF;


     --create hdr first
     --create cure refund hdr record
     lp_chdv_rec.refund_header_number  := p_pay_cure_refunds_rec.refund_number;
     lp_chdv_rec.refund_type           := p_pay_cure_refunds_rec.refund_type;
     lp_chdv_rec.vendor_site_id        := p_pay_cure_refunds_rec.vendor_site_id;
     lp_chdv_rec.disbursement_amount   := p_pay_cure_refunds_rec.refund_amount;
     lp_chdv_rec.total_refund_due      := p_pay_cure_refunds_rec.refund_amount_due;
     lp_chdv_rec.refund_due_date       := p_pay_cure_refunds_rec.invoice_date;
     lp_chdv_rec.object_version_number := 1;
     lp_chdv_rec.description           := p_pay_cure_refunds_rec.description;
     lp_chdv_rec.refund_status         :='PENDINGI';
     lp_chdv_rec.currency_code         :=p_pay_cure_refunds_rec.currency;
     lp_chdv_rec.payment_method        :=p_pay_cure_refunds_rec.payment_method_code;
     lp_chdv_rec.payment_term_id       :=p_pay_cure_refunds_rec.pay_terms;
     lp_chdv_rec.chr_id                :=p_pay_cure_refunds_rec.chr_id;
     lp_chdv_rec.vendor_site_cure_due  :=p_pay_cure_refunds_rec.vendor_site_cure_due;
     lp_chdv_rec.vendor_cure_due       :=p_pay_cure_refunds_rec.vendor_cure_due;

     l_pay_cure_refunds_rec :=p_pay_cure_refunds_rec;


       IF l_pay_cure_refunds_rec.chr_id is not null THEN
          lp_chdv_rec.refund_type            := 'CONTRACT' ;
          l_pay_cure_refunds_rec.refund_type := 'CONTRACT' ;

          x_pay_tbl(1).chr_id :=l_pay_cure_refunds_rec.chr_id;
          x_pay_tbl(1).refund_amount_due :=l_pay_cure_refunds_rec.refund_amount_due;
          x_pay_tbl(1).refund_amount :=l_pay_cure_refunds_rec.refund_amount;
       ELSE
           populate_chr_tbl(l_pay_cure_refunds_rec,x_pay_tbl);
       END IF;



       OKL_cure_rfnd_hdr_pub.insert_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'T'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_hdr : OKL_cure_rfnd_hdr_pub.insert_cure_rfnd_hdr : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_chdv_rec.cure_refund_header_id'
                                     ||lx_chdv_rec.cure_refund_header_id);
           END IF;
           l_pay_cure_refunds_rec.refund_header_id :=
                                   lx_chdv_rec.cure_refund_header_id;
           x_cure_refund_header_id :=
                                   lx_chdv_rec.cure_refund_header_id;
     END IF;

     --have loop and distibute amounts
     --for the corresponding contracts
     --distribute amounts
     --if contract id is passed then
     --create payable only for that contract
     --else get all contract for the vendor or vendor site


       IF x_pay_tbl.COUNT > 0 THEN
         FOR i in x_pay_tbl.FIRST..x_pay_tbl.LAST
         LOOP
             l_pay_cure_refunds_rec.refund_amount_due:=x_pay_tbl(i).refund_amount_due;
             l_pay_cure_refunds_rec.refund_amount:=x_pay_tbl(i).refund_amount;
             l_pay_cure_refunds_rec.chr_id :=x_pay_tbl(i).chr_id;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_pay_cure_refunds_rec.refund_TYPE'||
               l_pay_cure_refunds_rec.refund_TYPE);
          END IF;
              create_refund
                (p_pay_cure_refunds_rec   => l_pay_cure_refunds_rec
                ,x_cure_refund_id         =>l_cure_refund_id
                ,x_return_status          =>l_return_status
                ,x_msg_count              =>l_msg_count
                ,x_msg_data               =>l_msg_data
                );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_hdr : create_refund : '||l_return_status);

 	         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	            Get_Messages (l_msg_count,l_message);
                IF PG_DEBUG < 11  THEN
                   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
                   END IF;
                END IF;
                raise FND_API.G_EXC_ERROR;
             ELSE
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cure_refund_id'
                                       ||l_cure_refund_id);
                END IF;
           END IF;

        END LOOP;

      END IF; -- table count of cure refunds is >0


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_hdr : END ');

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','CREATE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END create_refund_hdr;

PROCEDURE update_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS

cursor c_get_tap_ids (p_cure_refund_header_id IN NUMBER ) is
select a.tap_id,
       a.cure_refund_id,
       a.object_version_number,
       b.invoice_number
from okl_cure_refunds a, okl_trx_ap_invoices_b b
where cure_refund_header_id =p_cure_refund_header_id
 and a.tap_id =b.id;

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;



l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_message  VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'UPDATE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_tapv_tbl         okl_tap_pvt.tapv_tbl_type;
lx_tapv_tbl     	okl_tap_pvt.tapv_tbl_type;
lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;
next_row integer;
lp_crfv_tbl         okl_crf_pvt.crfv_tbl_type;
lx_crfv_tbl     	okl_crf_pvt.crfv_tbl_type;

BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_hdr : START ');
      SAVEPOINT UPDATE_REFUND_HDR;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     --update tap and cure_refund_headers table
     FOR i in c_get_tap_ids (p_pay_cure_refunds_rec.refund_header_id)
     LOOP
         next_row := nvl(lp_tapv_tbl.LAST,0) +1;
         lp_tapv_tbl(next_row).id             :=i.tap_id;
         lp_tapv_tbl(next_row).date_invoiced  := p_pay_cure_refunds_rec.invoice_date;
         lp_tapv_tbl(next_row).ippt_id        := p_pay_cure_refunds_rec.pay_terms;
         lp_tapv_tbl(next_row).payment_method_code
                                      :=p_pay_cure_refunds_rec.payment_method_code;
         lp_tapv_tbl(next_row).vendor_invoice_number := i.invoice_number;
         lp_crfv_tbl(next_row).refund_date    := p_pay_cure_refunds_rec.invoice_date;
         lp_crfv_tbl(next_row).cure_refund_id :=i.cure_refund_id;
         lp_crfv_tbl(next_row).object_version_number :=i.object_version_number;
     END LOOP;

     IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'no of records to be updated in TAP'||
                                     lp_tapv_tbl.COUNT);
         END IF;
      END IF;

  	 okl_trx_ap_invoices_pub.update_trx_ap_invoices(
  		  p_api_version			=> 1.0
		  ,p_init_msg_list		=> 'T'
		  ,x_return_status		=> l_return_status
		  ,x_msg_count			=> l_msg_count
		  ,x_msg_data			=> l_msg_data
		  ,p_tapv_tbl 			=> lp_tapv_tbl
		  ,x_tapv_tbl			=> lx_tapv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_hdr : okl_trx_ap_invoices_pub.update_trx_ap_invoices : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated tap records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;



    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUNDS ',
                  p_operation =>  'UPDATE' );

      OKL_cure_refunds_pub.update_cure_refunds(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crfv_tbl        => lp_crfv_tbl
                          ,x_crfv_tbl        => lx_crfv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_hdr : OKL_cure_refunds_pub.update_cure_refunds : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated CRF records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;


    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_HEADERS ',
                  p_operation =>  'UPDATE' );

      lp_chdv_rec.cure_refund_header_id :=p_pay_cure_refunds_rec.refund_header_id;
      lp_chdv_rec.refund_due_date       :=p_pay_cure_refunds_rec.invoice_date;
      lp_chdv_rec.payment_method        :=p_pay_cure_refunds_rec.payment_method_code;
      lp_chdv_rec.payment_term_id       :=p_pay_cure_refunds_rec.pay_terms;

      OPEN c_getobj(p_pay_cure_refunds_rec.refund_header_id);
      FETCH c_getobj INTO lp_chdv_rec.object_version_number;
      CLOSE c_getobj;


      OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_hdr : OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Successfully updated Cure refund '||
                                      'header table');

          END IF;
     END IF;

    IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_hdr : END ');

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','UPDATE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END update_refund_hdr;

PROCEDURE delete_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS

cursor c_get_tap_ids (p_cure_refund_header_id IN NUMBER ) is
select crf.tap_id,
       crf.cure_refund_id,
       crf.object_version_number,
       til.id til_id
from okl_cure_refunds crf,
     okl_txl_ap_inv_lns_b til
where cure_refund_header_id =p_cure_refund_header_id
and til.tap_id =crf.tap_id;


cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;



l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_message  VARCHAR2(32627);

l_api_name                CONSTANT VARCHAR2(50) := 'DELETE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_tapv_tbl         okl_tap_pvt.tapv_tbl_type;
lp_tplv_tbl         okl_tpl_pvt.tplv_tbl_type;
lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lp_crfv_tbl         okl_crf_pvt.crfv_tbl_type;
next_row integer;


BEGIN

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: delete_refund_hdr : START ');

      SAVEPOINT DELETE_REFUND_HDR;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_refund_header_id IS NULL)  THEN
          AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'cure_refund_header_id' );
                    RAISE FND_API.G_EXC_ERROR;
 	 END IF;


     --update tap and cure_refund_headers table
     FOR i in c_get_tap_ids (p_refund_header_id)
     LOOP
         next_row := nvl(lp_tapv_tbl.LAST,0) +1;
         lp_tapv_tbl(next_row).id             :=i.tap_id;
         lp_tplv_tbl(next_row).id             :=i.til_id;
         lp_crfv_tbl(next_row).cure_refund_id :=i.cure_refund_id;
         lp_crfv_tbl(next_row).object_version_number :=i.object_version_number;
     END LOOP;

     IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'no of records to be updated in TAP'||
                                     lp_tapv_tbl.COUNT);
         END IF;
      END IF;

  	 okl_trx_ap_invoices_pub.delete_trx_ap_invoices(
  		  p_api_version			=> 1.0
		  ,p_init_msg_list		=> 'T'
		  ,x_return_status		=> l_return_status
		  ,x_msg_count			=> l_msg_count
		  ,x_msg_data			=> l_msg_data
		  ,p_tapv_tbl 			=> lp_tapv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: delete_refund_hdr : okl_trx_ap_invoices_pub.delete_trx_ap_invoices : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully deleted tap records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;

     --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TXL_AP_INV_LNS_B ',
                  p_operation =>  'DELETE' );

  	  okl_txl_ap_inv_lns_pub.delete_txl_ap_inv_lns (
			 p_api_version		=> 1.0
			,p_init_msg_list	=> 'F'
			,x_return_status	=> l_return_status
			,x_msg_count		=> l_msg_count
			,x_msg_data		    => l_msg_data
			,p_tplv_tbl		    => lp_tplv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: delete_refund_hdr : okl_txl_ap_inv_lns_pub.delete_txl_ap_inv_lns : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully deleted tap records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;

    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUNDS ',
                  p_operation =>  'DELETE' );

      OKL_cure_refunds_pub.delete_cure_refunds(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crfv_tbl        => lp_crfv_tbl);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: delete_refund_hdr : OKL_cure_refunds_pub.delete_cure_refunds : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully deleted CRF records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;


    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_HEADERS ',
                  p_operation =>  'DELETE' );

      lp_chdv_rec.cure_refund_header_id :=p_refund_header_id;

      OPEN c_getobj(p_refund_header_id);
      FETCH c_getobj INTO lp_chdv_rec.object_version_number;
      CLOSE c_getobj;


      OKL_cure_rfnd_hdr_pub.delete_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: delete_refund_hdr : OKL_cure_rfnd_hdr_pub.delete_cure_rfnd_hdr : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Successfully deleted Cure refund '||
                                      'header table');

          END IF;
     END IF;


    IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: delete_refund_hdr : END ');
EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO DELETE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','DELETE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END delete_refund_hdr;

PROCEDURE CREATE_TAI_ACCOUNTING
                 (p_cure_refund_header_id IN NUMBER,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_msg_count     OUT NOCOPY NUMBER,
                  x_msg_data      OUT NOCOPY VARCHAR2) IS

cursor c_get_contract_currency (l_khr_id IN NUMBER) IS
select currency_code from OKC_K_HEADERS_b
where id =l_khr_id;

CURSOR curr_csr (l_khr_id NUMBER) IS
SELECT 	currency_conversion_type,
        currency_conversion_rate,
	    currency_conversion_date
FROM 	okl_k_headers
WHERE 	id = l_khr_id;


l_functional_currency okl_trx_contracts.currency_code%TYPE;
l_currency_conversion_type	okl_k_headers.currency_conversion_type%TYPE;
l_currency_conversion_rate	okl_k_headers.currency_conversion_rate%TYPE;
l_currency_conversion_date	okl_k_headers.currency_conversion_date%TYPE;
l_contract_currency OKC_K_HEADERS_b.currency_code%TYPE;

next_row integer;


-- ASHIM CHANGE - START


/*cursor c_get_accounting(p_refund_header_id IN NUMBER) is
select  tai.try_id,
        til.sty_id,
        til.id,
        tai.khr_id,
        tai.date_invoiced,
        tai.amount,
        tai.currency_code
from
     okl_trx_ar_invoices_b tai,
     okl_txl_ar_inv_lns_b  til,
     okl_cure_refunds  crf
where  tai.id   =til.tai_id
and    tai.id    =crf.tai_id
and crf.cure_refund_header_id =p_refund_header_id;*/

cursor c_get_accounting(p_refund_header_id IN NUMBER) is
select  tai.id                tai_id,
        tai.try_id            try_id,
        txd.sty_id            sty_id,
        txd.id                txd_id,
        tai.khr_id            khr_id,
        tai.date_invoiced     date_invoiced,
        tai.amount            amount,
        tai.currency_code     currency_code
from    okl_trx_ar_invoices_b tai,
        okl_txl_ar_inv_lns_b  til,
        okl_txd_ar_ln_dtls_b  txd,
        okl_cure_refunds      crf
where   crf.cure_refund_header_id = p_refund_header_id
and     tai.id                    = crf.tai_id
and     tai.id                    = til.tai_id
and     til.id                    = txd.til_id_details ;



-- ASHIM CHANGE - END

l_tai_id          okl_trx_ar_invoices_b.id%TYPE;
l_sty_id          okl_txl_ar_inv_lns_b.sty_id%TYPE;
l_try_id          okl_trx_ar_invoices_b.try_id%TYPE;
l_line_id         okl_txl_ar_inv_lns_b.id%TYPE;
l_khr_id          okc_k_headers_b.id%TYPE;
l_date_invoiced   okl_trx_ar_invoices_b.date_invoiced%TYPE;
l_amount          okl_trx_ar_invoices_b.amount%TYPE;

 CURSOR product_csr (p_chr_id IN NUMBER) IS
         SELECT  khr.pdt_id,
                 chr.scs_code --Bug# 4622198
	     FROM    okl_k_headers khr,
                 okc_k_headers_b chr --Bug# 4622198
     	 WHERE   chr.id = khr.id --Bug# 4622198
         and     khr.id = p_chr_id;

/* -- OKL.H Code commented out
l_tmpl_identify_rec          Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
l_dist_info_rec              Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
l_ctxt_val_tbl               okl_execute_formula_pvt.ctxt_val_tbl_type;
l_acc_gen_primary_key_tbl    Okl_Account_Generator_Pvt.primary_key_tbl;
l_template_tbl         	     Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
l_amount_tbl         	     Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;
*/

-- R12 Change - START

l_tmpl_identify_tbl         okl_account_dist_pvt.tmpl_identify_tbl_type;
l_dist_info_tbl             okl_account_dist_pvt.dist_info_tbl_type;
l_template_tbl              okl_account_dist_pvt.avlv_out_tbl_type;
l_amount_tbl                okl_account_dist_pvt.amount_out_tbl_type;
l_ctxt_val_tbl              okl_account_dist_pvt.ctxt_tbl_type;
l_acc_gen_primary_key_tbl   okl_account_dist_pvt.acc_gen_tbl_type;

-- R12 Change - END

l_factoring_synd    VARCHAR2(30);
l_syndication_code  VARCHAR2(30) DEFAULT NULL;
l_factoring_code    VARCHAR2(30) DEFAULT NULL;

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'CREATE_TAI_ACCOUNTING';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;

--Bug# 4622198 :For special accounting treatment - START
l_fact_synd_code      FND_LOOKUPS.Lookup_code%TYPE;
l_inv_acct_code       OKC_RULES_B.Rule_Information1%TYPE;
l_scs_code            okc_k_headers_b.SCS_CODE%TYPE;
--Bug# 4622198 :For special accounting treatment - END


BEGIN

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_TAI_ACCOUNTING : START ');

      SAVEPOINT CREATE_TAI_ACCOUNTING;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start CREATE_TAI_ACCOUNTING');

      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;


       FOR j in c_get_accounting(p_cure_refund_header_id)
       LOOP

           FOR i IN product_csr (j.khr_id)
           LOOP
              l_tmpl_identify_tbl(1).product_id := i.pdt_id;
              l_scs_code := i.scs_code;
              IF l_tmpl_identify_tbl(1).product_id IS NULL THEN
                  OKL_API.SET_MESSAGE (p_app_name => 'OKL',
                                   p_msg_name => 'OKL_NO_PRODUCT_FOUND');
                 raise FND_API.G_EXC_ERROR;
              END IF;
              IF PG_DEBUG < 11  THEN
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'product_id '
                                     ||l_tmpl_identify_tbl(1).product_id);
                END IF;
             END IF;
           END LOOP;
          /*--- New Code Start Here ---*/
          -- Fetch the functional currency
         l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

        -- Fetch the currency conversion factors if functional currency is not equal
        -- to the transaction currency

       OPEN c_get_contract_currency (j.khr_id);
       FETCH  c_get_contract_currency INTO l_contract_currency;
       CLOSE c_get_contract_currency;
       l_dist_info_tbl(1).currency_code := l_contract_currency;

      IF l_functional_currency <> l_contract_currency THEN

        -- Fetch the currency conversion factors from Contracts
           FOR curr_rec IN curr_csr(j.khr_id) LOOP
               l_currency_conversion_type := curr_rec.currency_conversion_type;
               l_currency_conversion_rate := curr_rec.currency_conversion_rate;
               l_currency_conversion_date := curr_rec.currency_conversion_date;
          END LOOP;

        -- Fetch the currency conversion factors from GL_DAILY_RATES if the
        -- conversion type is not 'USER'.

     IF UPPER(l_currency_conversion_type) <> 'USER' THEN
	 l_currency_conversion_date := SYSDATE;
         l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate
         	(p_from_curr_code => l_contract_currency,
       		p_to_curr_code => l_functional_currency,
       		p_con_date => l_currency_conversion_date,
  		    p_con_type => l_currency_conversion_type);

     END IF; -- End IF for (UPPER(l_currency_conversion_type) <> 'USER')

   END IF;  -- End IF for (l_functional_currency <> l_contract_currency)

-- Populate the currency conversion factors

   l_dist_info_tbl(1).currency_conversion_type := l_currency_conversion_type;
   l_dist_info_tbl(1).currency_conversion_rate := l_currency_conversion_rate;
   l_dist_info_tbl(1).currency_conversion_date := l_currency_conversion_date;

-- Round the transaction amount
   l_dist_info_tbl(1).amount:= okl_accounting_util.cross_currency_round_amount
   			(p_amount   => j.amount,
			 p_currency_code => l_contract_currency);

    l_dist_info_tbl(1).contract_id		     := j.khr_id;
    l_dist_info_tbl(1).amount:=    l_dist_info_tbl(1).amount * -1;

/*--- New Code End Here ---*/


       l_tmpl_identify_tbl(1).transaction_type_id  := j.try_id;
       l_tmpl_identify_tbl(1).stream_type_id       := j.sty_id;
       l_tmpl_identify_tbl(1).advance_arrears      := null;
       l_tmpl_identify_tbl(1).factoring_synd_flag  := null;
       l_tmpl_identify_tbl(1).syndication_code     := null;
       l_tmpl_identify_tbl(1).factoring_code       := null;
       l_tmpl_identify_tbl(1).memo_yn              := 'N';
       l_tmpl_identify_tbl(1).prior_year_yn        := 'N';

       l_dist_info_tbl(1).source_id		         := j.txd_id;
--start: cklee 06/28/07
--       l_dist_info_tbl(1).source_table		   := 'OKL_TXL_AR_INV_LNS_B';
       l_dist_info_tbl(1).source_table		   := 'OKL_TXD_AR_LN_DTLS_B';
--end: cklee 06/28/07
       l_dist_info_tbl(1).accounting_date		   := j.date_invoiced;
       l_dist_info_tbl(1).gl_reversal_flag	   :='N';
       l_dist_info_tbl(1).post_to_gl		   :='N';
       l_dist_info_tbl(1).currency_code		   := l_contract_currency;
       l_dist_info_tbl(1).contract_id		   := j.khr_id;

       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       -- R12 CHANGE- START

          --Do no know what this segment does. Hence commented out,
          --will enable if required during test run
          -- enabled by cklee 06/29/07

         AddfailMsg(
                  p_object    =>  'Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen ',
                  p_operation =>  'CREATE' );

        Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
          p_contract_id	     => j.khr_id,
          p_contract_line_id  => NULL,
          x_acc_gen_tbl	     => l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl,
          x_return_status     => l_return_status);

       l_acc_gen_primary_key_tbl(1).source_id := j.txd_id; -- cklee 06/29/07

   	   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
            raise FND_API.G_EXC_ERROR;
       ELSE
           FND_MSG_PUB.initialize;
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_acc_gen_primary_key_tbl for TAI'
                                     ||l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl.count
                                     ||l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl(1).primary_key_column
                                     ||l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl(1).source_table );
              END IF;
          END IF;

       END IF;

       -- R12 CHANGE- END


       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       AddfailMsg(
                  p_object    =>  'OKL_SECURITIZATION_PVT.Check_Khr_ia_associated ',
                  p_operation =>  'CREATE' );

      --Bug# 4622198 :For special accounting treatment - START
      OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => OKL_API.G_FALSE,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_khr_id                  => j.khr_id,
                                  p_scs_code                => l_scs_code,
                                  p_trx_date                => j.date_invoiced,
                                  x_fact_synd_code          => l_fact_synd_code,
                                  x_inv_acct_code           => l_inv_acct_code
                                  );

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_tmpl_identify_tbl(1).factoring_synd_flag := l_fact_synd_code;
      l_tmpl_identify_tbl(1).investor_code       := l_inv_acct_code;
      --Bug# 4622198 :For special accounting treatment - END


       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       AddfailMsg(
                  p_object    =>  'Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ',
                  p_operation =>  'CREATE' );

/* OKL.H code commented out
       Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
 	     p_api_version           => 1.0
        ,p_init_msg_list  	     => 'F'
        ,x_return_status  	     => l_return_status
        ,x_msg_count      	     => l_msg_count
        ,x_msg_data       	     => l_msg_data
        ,p_tmpl_identify_rec 	 => l_tmpl_identify_rec
        ,p_dist_info_rec         => l_dist_info_rec
        ,p_ctxt_val_tbl            => l_ctxt_val_tbl
        ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
        ,x_template_tbl            => l_template_tbl
        ,x_amount_tbl              => l_amount_tbl);
*/
          -- R12 CHANGE - START
          okl_account_dist_pvt.create_accounting_dist(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => OKL_API.G_FALSE,
                                  x_return_status           => l_return_status,
                                  x_msg_count               => l_msg_count,
                                  x_msg_data                => l_msg_data,
                                  p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                  p_dist_info_tbl           => l_dist_info_tbl,
                                  p_ctxt_val_tbl            => l_ctxt_val_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl,
                                  x_template_tbl            => l_template_tbl,
                                  x_amount_tbl              => l_amount_tbl,
                                  p_trx_header_id           => j.tai_id,--); 06/28/07 cklee
                                  p_trx_header_table        => 'OKL_TRX_AR_INVOICES_B'); -- 06/28/07 cklee

          -- R12 CHANGE - END

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_TAI_ACCOUNTING : okl_account_dist_pvt.create_accounting_dist : '||l_return_status);

   	   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
       ELSE
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'count of l_template_tbl'||l_template_tbl.count);
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'count of l_amount_tbl'||l_amount_tbl.count);
           END IF;
           FND_MSG_PUB.initialize;
       END IF;

   END LOOP; -- for c_get_accounting cursor


 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after accounting dist '||l_return_status);

 END IF;
 FND_MSG_PUB.Count_And_Get
        (  p_count          =>   x_msg_count,
           p_data           =>   x_msg_data
        );
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' End of Procedure'||
                                 '=>OKL_PAY_RECON_PVT.'||
                                  'CREATE_TAI_ACCOUNTING');
    END IF;

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_TAI_ACCOUNTING : END ');

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_TAI_ACCOUNTING;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_TAI_ACCOUNTING;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_TAI_ACCOUNTING;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','CREATE_TAI_ACCOUNTING');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END CREATE_TAI_ACCOUNTING;



PROCEDURE submit_cure_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);

l_api_name                CONSTANT VARCHAR2(50) := 'SUBMIT_CURE_REFUND_HDR';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;
lp_tapv_tbl         okl_tap_pvt.tapv_tbl_type;
lx_tapv_tbl     	okl_tap_pvt.tapv_tbl_type;
lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;
lp_crsv_tbl         okl_crs_pvt.crsv_tbl_type;
xp_crsv_tbl         okl_crs_pvt.crsv_tbl_type;
lp_taiv_tbl         okl_tai_pvt.taiv_tbl_type;
lx_taiv_tbl     	okl_tai_pvt.taiv_tbl_type;

/* -- OKL.H Code commented out
l_tmpl_identify_rec          Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
l_dist_info_rec              Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
l_ctxt_val_tbl               okl_execute_formula_pvt.ctxt_val_tbl_type;
l_acc_gen_primary_key_tbl    Okl_Account_Generator_Pvt.primary_key_tbl;
l_template_tbl         	     Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
l_amount_tbl         	     Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;
*/

-- R12 Change - START

l_tmpl_identify_tbl         okl_account_dist_pvt.tmpl_identify_tbl_type;
l_dist_info_tbl             okl_account_dist_pvt.dist_info_tbl_type;
l_template_tbl              okl_account_dist_pvt.avlv_out_tbl_type;
l_amount_tbl                okl_account_dist_pvt.amount_out_tbl_type;
l_ctxt_val_tbl              okl_account_dist_pvt.ctxt_tbl_type;
l_acc_gen_primary_key_tbl   okl_account_dist_pvt.acc_gen_tbl_type;
--start:REM                    28-June-2007 cklee
    l_fact_synd_code           fnd_lookups.lookup_code%TYPE;
    l_inv_acct_code            okc_rules_b.RULE_INFORMATION1%TYPE;
    l_tpl_id                   okl_txl_ap_inv_lns_all_b.id%type;
--end:REM                    28-June-2007 cklee
-- R12 Change - END

cursor c_get_tap_ids (p_cure_refund_header_id IN NUMBER ) is
select crf.tap_id,tap.invoice_number,
       crs.object_version_number
       ,crs.cure_refund_Stage_id
       ,crf.tai_id
from okl_cure_refunds crf,okl_trx_ap_invoices_b tap
     ,okl_cure_refund_stage crs
where crf.cure_refund_header_id =p_cure_refund_header_id
       and crf.tap_id =tap.id
       and crs.cure_refund_stage_id =crf.cure_refund_stage_id;

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;

next_row     integer;
tai_next_row integer;

-- sjalasut, modified the below cursor to have khr_id referred from
-- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
-- as part of OKLR12B disbursements project
cursor c_get_accounting(p_cure_refund_header_id IN NUMBER) is
select  tap.id                      tap_id,
        tap.try_id                  try_id,
        til.sty_id                  sty_id,
        til.id                      id,
        tap.date_invoiced           date_invoiced,
        tap.amount                  amount,
        tap.currency_code           currency_code,
        til.khr_id                  khr_id
from    okl_trx_ap_invoices_b       tap,
        okl_txl_ap_inv_lns_b        til,
        okl_cure_refunds            crf
where   crf.cure_refund_header_id = p_cure_refund_header_id
and     tap.id                    = til.tap_id
and     crf.tap_id                = tap.id;


 CURSOR product_csr (p_chr_id IN NUMBER) IS
         SELECT  khr.pdt_id
	     FROM    okl_k_headers khr
     	 WHERE   khr.id = p_chr_id;

/*---New Code start ---*/
CURSOR curr_csr (l_khr_id NUMBER) IS
SELECT 	currency_conversion_type,
        currency_conversion_rate,
	    currency_conversion_date
FROM 	okl_k_headers
WHERE 	id = l_khr_id;

cursor c_get_contract_currency (l_khr_id IN NUMBER) IS
select currency_code from OKC_K_HEADERS_b
where id =l_khr_id;

l_functional_currency okl_trx_contracts.currency_code%TYPE;
l_currency_conversion_type	okl_k_headers.currency_conversion_type%TYPE;
l_currency_conversion_rate	okl_k_headers.currency_conversion_rate%TYPE;
l_currency_conversion_date	okl_k_headers.currency_conversion_date%TYPE;
l_contract_currency OKC_K_HEADERS_b.currency_code%TYPE;
/*---New Code end ---*/

BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : START ');
      SAVEPOINT SUBMIT_CURE_REFUND_HDR;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_refund_header_id IS NULL)  THEN
          AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'cure_refund_header_id' );
                    RAISE FND_API.G_EXC_ERROR;
 	 END IF;


     FOR i in c_get_tap_ids (p_refund_header_id)
     LOOP
         next_row  := nvl(lp_tapv_tbl.LAST,0) +1;
         lp_tapv_tbl(next_row).id              :=i.tap_id;
         lp_tapv_tbl(next_row).trx_status_code :='ENTERED';
         lp_tapv_tbl(next_row).vendor_invoice_number := i.invoice_number;
         lp_crsv_tbl(next_row).cure_refund_stage_id :=i.cure_refund_stage_id;
         lp_crsv_tbl(next_row).status:='SUBMITTED';
         lp_crsv_tbl(next_row).object_version_number
                               :=i.object_version_number;

         IF i.tai_id is not null THEN
             tai_next_row := nvl(lp_taiv_tbl.LAST,0) +1;
             lp_taiv_tbl(tai_next_row).id          :=i.tai_id;
             lp_taiv_tbl(tai_next_row).trx_status_code :='SUBMITTED';
         END IF;

     END LOOP;


     IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'no of records to be updated in TAP'||
                                     lp_tapv_tbl.COUNT);
         END IF;
      END IF;

  	 okl_trx_ap_invoices_pub.update_trx_ap_invoices(
  		  p_api_version			=> 1.0
		  ,p_init_msg_list		=> 'T'
		  ,x_return_status		=> l_return_status
		  ,x_msg_count			=> l_msg_count
		  ,x_msg_data			=> l_msg_data
		  ,p_tapv_tbl 			=> lp_tapv_tbl
		  ,x_tapv_tbl			=> lx_tapv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : okl_trx_ap_invoices_pub.update_trx_ap_invoices : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated tap records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;


    IF lp_taiv_tbl.COUNT > 0 THEN
        --Update trx ar invoices
        --set error message,so this will be prefixed before the
        --actual message, so it makes more sense than displaying an
        -- OKL message.


-- ASHIM CHANGE - START


        AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES',
                  p_operation =>  'UPDATE' );

    	okl_trx_ar_invoices_pub.update_trx_ar_invoices(
   		   p_api_version		=> 1.0
		   ,p_init_msg_list		=> 'T'
		   ,x_return_status		=> l_return_status
		   ,x_msg_count			=> l_msg_count
		   ,x_msg_data			=> l_msg_data
		   ,p_taiv_tbl 			=> lp_taiv_tbl
		   ,x_taiv_tbl			=> lx_taiv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : okl_trx_ar_invoices_pub.update_trx_ar_invoices : '||l_return_status);
-- ASHIM CHANGE - END



 	    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	        Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
           END IF;
           raise FND_API.G_EXC_ERROR;
       ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated tai records');
              END IF;
           END IF;
          FND_MSG_PUB.initialize;
      END IF;
   END IF; -- if tai table count > 0


   --Update OKL_CURE_REFUND_STAGE
   --set error message,so this will be prefixed before the
   --actual message, so it makes more sense than displaying an
   -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_STAGE',
                  p_operation =>  'UPDATE' );

     OKL_cure_rfnd_stage_pub.update_cure_refunds(
      p_api_version         => 1.0
     ,p_init_msg_list       =>'F'
     ,x_return_status	    => l_return_status
     ,x_msg_count		    => l_msg_count
     ,x_msg_data	      	 => l_msg_data
     ,p_crsv_tbl             => lp_crsv_tbl
     ,x_crsv_tbl             => xp_crsv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : OKL_cure_rfnd_stage_pub.update_cure_refunds : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund stage' );
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
    END IF;

    --create accounting
    -- set accounting call required values


   -- following call gets the product id for the accounting call
    FOR j in c_get_accounting(p_refund_header_id)
    LOOP

        FOR i IN product_csr (j.khr_id)
        LOOP
         l_tmpl_identify_tbl(1).product_id := i.pdt_id;
         l_acc_gen_primary_key_tbl(1).source_id := j.id; -- cklee 06/29/07
          IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'product_id '
                                     ||l_tmpl_identify_tbl(1).product_id);
              END IF;
          END IF;
       END LOOP;

/*--- New Code Start Here ---*/
-- Fetch the functional currency
   l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

-- Fetch the currency conversion factors if functional currency is not equal
-- to the transaction currency

   OPEN c_get_contract_currency (j.khr_id);
   FETCH  c_get_contract_currency INTO l_contract_currency;
   CLOSE c_get_contract_currency;

   l_dist_info_tbl(1).currency_code := l_contract_currency;

   IF l_functional_currency <> l_contract_currency THEN

    -- Fetch the currency conversion factors from Contracts
     FOR curr_rec IN curr_csr(j.khr_id) LOOP
       l_currency_conversion_type := curr_rec.currency_conversion_type;
       l_currency_conversion_rate := curr_rec.currency_conversion_rate;
       l_currency_conversion_date := curr_rec.currency_conversion_date;
     END LOOP;

-- Fetch the currency conversion factors from GL_DAILY_RATES if the
-- conversion type is not 'USER'.

     IF UPPER(l_currency_conversion_type) <> 'USER' THEN
	 l_currency_conversion_date := SYSDATE;
         l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate
         	(p_from_curr_code => l_contract_currency,
       		p_to_curr_code => l_functional_currency,
       		p_con_date => l_currency_conversion_date,
  		    p_con_type => l_currency_conversion_type);

     END IF; -- End IF for (UPPER(l_currency_conversion_type) <> 'USER')

   END IF;  -- End IF for (l_functional_currency <> l_contract_currency)

-- Populate the currency conversion factors

   l_dist_info_tbl(1).currency_conversion_type := l_currency_conversion_type;
   l_dist_info_tbl(1).currency_conversion_rate := l_currency_conversion_rate;
   l_dist_info_tbl(1).currency_conversion_date := l_currency_conversion_date;

-- Round the transaction amount
   l_dist_info_tbl(1).amount:= okl_accounting_util.cross_currency_round_amount
   			(p_amount   => j.amount,
			 p_currency_code => l_contract_currency);

    l_dist_info_tbl(1).contract_id		     := j.khr_id;

/*--- New Code End Here ---*/
--start:REM                    28-June-2007 cklee
    -- We need to call once per khr_id
    Okl_Securitization_Pvt.check_khr_ia_associated(
	  p_api_version         => 1.0
     ,p_init_msg_list       =>'F'
     ,x_return_status	    => l_return_status
     ,x_msg_count		    => l_msg_count
     ,x_msg_data	      	=> l_msg_data
     ,p_khr_id              => j.khr_id
     ,p_scs_code            => NULL
     ,p_trx_date            => j.date_invoiced
     ,x_fact_synd_code      => l_fact_synd_code
     ,x_inv_acct_code       => l_inv_acct_code);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -Okl_Securitization_Pvt.check_khr_ia_associated' );
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
    END IF;
--end:REM                    28-June-2007 cklee


       l_tmpl_identify_tbl(1).transaction_type_id  := j.try_id;
       l_tmpl_identify_tbl(1).stream_type_id       := j.sty_id;
       l_tmpl_identify_tbl(1).advance_arrears      := null;
       l_tmpl_identify_tbl(1).factoring_synd_flag  := l_fact_synd_code;
       l_tmpl_identify_tbl(1).investor_code        := l_inv_acct_code; -- cklee 06/29/07
       l_tmpl_identify_tbl(1).syndication_code     := null;
       l_tmpl_identify_tbl(1).factoring_code       := null;
       l_tmpl_identify_tbl(1).memo_yn              := 'N';
       l_tmpl_identify_tbl(1).prior_year_yn        := 'N';

       l_dist_info_tbl(1).source_id		      := j.id;
       l_dist_info_tbl(1).source_table		      := 'OKL_TXL_AP_INV_LNS_B';
       l_dist_info_tbl(1).accounting_date		:= j.date_invoiced;
       l_dist_info_tbl(1).gl_reversal_flag	      :='N';
       l_dist_info_tbl(1).post_to_gl		      :='N';
--       l_dist_info_tbl(1).amount			      := ABS(j.amount);
       l_dist_info_tbl(1).amount			      := j.amount; --start: 06/04/07 cklee
       l_dist_info_tbl(1).currency_code		:= j.currency_code;
       l_dist_info_tbl(1).contract_id		      := j.khr_id;


       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       -- R12 CHANGE - START
       --Do not know what this segment does. Hence commented out,
       --will enable if required during test run
       -- enabled by cklee 06/29/07

         AddfailMsg(
                  p_object    =>  'Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen ',
                  p_operation =>  'CREATE' );


        Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
          p_contract_id	     => j.khr_id,
          p_contract_line_id  => NULL,
          x_acc_gen_tbl	     => l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl,
          x_return_status     => l_return_status);

   	   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
            raise FND_API.G_EXC_ERROR;
       ELSE
           FND_MSG_PUB.initialize;
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_acc_gen_primary_key_tbl'
                                     ||l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl.count
                                     ||l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl(1).primary_key_column
                                     ||l_acc_gen_primary_key_tbl(1).acc_gen_key_tbl(1).source_table );
              END IF;
          END IF;

       END IF;

       -- R12 CHANGE - END

       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       AddfailMsg(
                  p_object    =>  'Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ',
                  p_operation =>  'CREATE' );

/* OKL.H code commented out
       Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
 	     p_api_version           => 1.0
        ,p_init_msg_list  	     => 'F'
        ,x_return_status  	     => l_return_status
        ,x_msg_count      	     => l_msg_count
        ,x_msg_data       	     => l_msg_data
        ,p_tmpl_identify_rec 	 => l_tmpl_identify_rec
        ,p_dist_info_rec         => l_dist_info_rec
        ,p_ctxt_val_tbl            => l_ctxt_val_tbl
        ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
        ,x_template_tbl            => l_template_tbl
        ,x_amount_tbl              => l_amount_tbl);
*/

          -- R12 CHANGE - START
          okl_account_dist_pvt.create_accounting_dist(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => OKL_API.G_FALSE,
                                  x_return_status           => l_return_status,
                                  x_msg_count               => l_msg_count,
                                  x_msg_data                => l_msg_data,
                                  p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                  p_dist_info_tbl           => l_dist_info_tbl,
                                  p_ctxt_val_tbl            => l_ctxt_val_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl,
                                  x_template_tbl            => l_template_tbl,
                                  x_amount_tbl              => l_amount_tbl,
--start: 06/04/07 cklee
--                                  p_trx_header_id           => j.tap_id);
                                  p_trx_header_id           => j.tap_id,
                                  p_trx_header_table        => 'OKL_TRX_AP_INVOICES_B'); -- cklee 07/06/07
--end: 06/04/07 cklee
          -- R12 CHANGE - END
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : okl_account_dist_pvt.create_accounting_dist : '||l_return_status);

   	   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
       ELSE
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'count of l_template_tbl for tap '||l_template_tbl.count);
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'count of l_amount_tbl for tap '||l_amount_tbl.count);
           END IF;
           FND_MSG_PUB.initialize;
       END IF;


   END LOOP; -- for c_get_accounting cursor


-- ASHIM CHANGE - START



   --create accounting for tai lines
    CREATE_TAI_ACCOUNTING(p_cure_refund_header_id =>p_refund_header_id,
                          x_return_status =>l_return_status,
                          x_msg_count     =>l_msg_count,
                          x_msg_data      =>l_msg_data);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : CREATE_TAI_ACCOUNTING : '||l_return_status);


-- ASHIM CHANGE - END


 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -created accounting for tai records');
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
    END IF;

   IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before updating cure refund header table');
         END IF;
   END IF;

    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_HEADERS ',
                  p_operation =>  'UPDATE' );

      lp_chdv_rec.cure_refund_header_id :=p_refund_header_id;
      lp_chdv_rec.refund_status         :='APPROVED';

      OPEN c_getobj(p_refund_header_id);
      FETCH c_getobj INTO lp_chdv_rec.object_version_number;
      CLOSE c_getobj;

      OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Successfully updated Cure refund '||
                                      'header table');
             END IF;
          END IF;

     END IF;


    IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refund_hdr : END ');
EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SUBMIT_CURE_REFUND_HDR;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','SUBMIT_CURE_REFUND_HDR');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);



END submit_cure_refund_hdr;

    --07/01/03
    -- Send a notification to a vendor indicating about
    -- the offset contract/credit memo ( if there is any)
    -- Populate the Role for the notification
    -- Check in workflow if role is populated THEN
    -- send notification

 PROCEDURE  GET_ROLE(
                    p_refund_header_id IN NUMBER
                   ,x_role             OUT NOCOPY VARCHAR2
            	   ,x_return_status    OUT NOCOPY VARCHAR2
                   ,x_msg_count        OUT NOCOPY NUMBER
                   ,x_msg_data         OUT NOCOPY VARCHAR2 )

 IS

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);

l_api_name                CONSTANT VARCHAR2(50) := 'GET_ROLE';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'||l_api_name ;


 l_email po_vendor_sites.email_address%TYPE;
 l_role_prefix VARCHAR2(10) := 'OKLVENDOR_';
 l_role_name VARCHAR2(30);
 l_role_display_name po_vendor_sites.vendor_site_code%TYPE;
 l_role_exists NUMBER;


 /*
  l_notification_pref wf_local_users.notification_preference%TYPE;
  l_lang      wf_local_users.language%TYPE;
  l_territory wf_local_users.territory%TYPE;
 */


  Cursor c_vendor_info (p_refund_header_id IN NUMBER) Is
  select pos.vendor_site_id,
         pos.vendor_site_code,
         pos.email_address,
         crh.cure_refund_header_id
  from po_vendor_sites pos,
       okl_cure_refund_headers_b crh,
       okl_cure_refunds crl
  where crh.vendor_site_id =pos.vendor_site_id
    and crh.cure_refund_header_id=p_refund_header_id
    and rownum <2;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      SAVEPOINT GET_ROLE;

      FOR i in  c_vendor_info(p_refund_header_id)
       LOOP
          l_role_name         := l_role_prefix||i.vendor_site_id;
          l_role_display_name :=i.vendor_site_code;
          l_email             :=i.email_address;
     END LOOP;

    IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Email Address ' ||l_email ||
                                     ' Role '         ||l_role_name||
                                     ' Role Display ' ||l_role_display_name);
         END IF;
    END IF;

    --set error stack
    IF l_email is NULL THEN
        fnd_message.set_name('OKL', 'OKL_MISSING_EMAIL_ID');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- check if role exists, otherwise create a new role
   -- wf_local_roles using  WF_DIRECTORY.CreateAdHocRole

/*      WF_DIRECTORY.GetRoleInfo
          (Role =>l_role_name,
           Display_Name =>l_role_display_name,
           Email_Address =>l_email,
           Notification_Preference =>l_notification_pref,
           Language =>l_lang,
           Territory =>l_territory
           );
 */
    --- assumption is wf_local_roles is a public table
       select count(1)
       into l_role_exists
       from WF_LOCAL_ROLES
       where name = l_role_name;

       if l_role_exists = 0 then
          --create ad hoc role
         WF_DIRECTORY.CreateAdHocRole
         ( role_name =>l_role_name,
           role_display_name =>l_role_display_name,
           notification_preference =>'MAILHTML',
           email_address =>l_email,
           status =>'ACTIVE',
           expiration_date =>to_DATE(NULL));

       ELSE
           x_role:=l_role_name;
       end if;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

 EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK TO GET_ROLE;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

 WHEN OTHERS THEN
      ROLLBACK TO GET_ROLE;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','GET_ROLE');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

End  GET_ROLE;


PROCEDURE  invoke_refund_wf(
                    p_refund_header_id IN NUMBER
            	   ,x_return_status       OUT NOCOPY VARCHAR2
                   ,x_msg_count           OUT NOCOPY NUMBER
                   ,x_msg_data            OUT NOCOPY VARCHAR2 ) IS

l_parameter_list        wf_parameter_list_t;
l_key                   VARCHAR2(240);
l_seq                   NUMBER;
l_event_name            varchar2(240) := 'oracle.apps.okl.co.approverefund';

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);

l_api_name                CONSTANT VARCHAR2(50) := 'INVOKE_REFUND_WF';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;
-- Selects the nextval from sequence, used later for defining event key
CURSOR okl_key_csr IS
SELECT okl_wf_item_s.nextval
FROM   dual;

cursor c_get_ref_details (p_refund_header_id IN NUMBER)
is select  crh.refund_header_number
          ,crh.disbursement_amount
          ,pov.vendor_name
from okl_cure_refund_headers_b crh,
     po_vendors pov,
     po_vendor_sites_All povs
where crh.vendor_site_id =povs.vendor_site_id
and pov.vendor_id =povs.vendor_id
and crh.cure_refund_header_id =p_refund_header_id;

l_refund_amount okl_cure_refund_headers_b.disbursement_amount%TYPE;
l_refund_number okl_cure_refund_headers_b.refund_header_number%TYPE;

l_vendor_name   po_vendors.vendor_name%TYPE;
l_notification_agent varchar2(100) := 'SYSADMIN';

cursor c_get_agent(p_user_id IN NUMBER) is
select wfr.name
from   fnd_user fuser,wf_roles wfr
where   orig_system = 'PER'
and wfr.orig_system_id =fuser.employee_id
and fuser.user_id =p_user_id;


l_user_id   NUMBER := to_number(fnd_profile.value('OKL_REFUND_APPROVAL_USER'));

--vendor role
l_role_name VARCHAR2(30);
l_offset_count NUMBER;

BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: invoke_refund_wf : START ');
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
      -- OKL message.
       /*AddfailMsg(
                  p_object    =>  'BEFORE CALLING WORKFLOW ',
                  p_operation =>  'CREATE' );
       */
      SAVEPOINT INVOKE_REFUND_WF;
  	  OPEN okl_key_csr;
	  FETCH okl_key_csr INTO l_seq;
	  CLOSE okl_key_csr;
      l_key := l_event_name  ||'-'||l_seq;

      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Event Key ' ||l_key);
         END IF;
      END IF;

      OPEN c_get_ref_details (p_refund_header_id );

      FETCH c_get_ref_details INTO l_refund_number,
                                   l_refund_amount,
                                   l_vendor_name;

      CLOSE c_get_ref_details;

     OPEN c_get_agent (l_user_id);
     FETCH c_get_agent INTO l_notification_agent;
     CLOSE c_get_Agent;

     IF l_notification_agent IS NULL THEN
          l_notification_agent := 'SYSADMIN';
     END IF;


      wf_event.AddParameterToList('NOTIFY_AGENT',
                                      l_notification_agent,
                                      l_parameter_list);

      wf_event.AddParameterToList('CURE_REFUND_HEADER_ID',
                                      to_char(p_refund_header_id),
                                      l_parameter_list);

       wf_event.AddParameterToList('REFUND_AMOUNT',
                                      to_char(l_refund_amount),
                                      l_parameter_list);

      wf_event.AddParameterToList('VENDOR_NAME',
                                      l_vendor_name,
                                      l_parameter_list);

     wf_event.AddParameterToList('REFUND_NUMBER',
                                      l_refund_number,
                                      l_parameter_list);



    --07/01/03
    -- Send a notification to a vendor indicating about
    -- the offset contract/credit memo ( if there is any)
    -- Populate the Role for the notification
    -- Check in workflow if role is populated THEN
    -- send notification

    -- getrole if there are offset contracts
    --jsanju 10/31

     select count(*) into l_offset_count
     from okl_cure_refunds
     where offset_contract is not null
     and cure_refund_header_id =p_refund_header_id;

    IF l_offset_count >0 THEN

       GET_ROLE(p_refund_header_id      =>p_refund_header_id,
                x_role                  =>l_role_name
           	   ,x_return_status         =>l_return_status
               ,x_msg_count             =>l_msg_count
               ,x_msg_data              =>l_msg_data);


       	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
  	          Get_Messages (l_msg_count,l_message);
              IF PG_DEBUG < 11  THEN
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
                 END IF;
              END IF;
              raise FND_API.G_EXC_ERROR;
        END IF;
    END IF;

         --set Attribute
           wf_event.AddParameterToList('VENDOR_ROLE',
                                    l_role_name,
                                    l_parameter_list);

         --added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);


     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before launching workflow');

     END IF;
      wf_event.raise(p_event_name  => l_event_name
                     ,p_event_key  => l_key
                    ,p_parameters  => l_parameter_list);

      COMMIT ;
      l_parameter_list.DELETE;



      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Successfully launched Cure refund workflow');
         END IF;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: invoke_refund_wf : END ');
 EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
   okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: invoke_refund_wf : Fnd_Api.G_EXC_ERROR ');
       ROLLBACK TO INVOKE_REFUND_WF;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

 WHEN OTHERS THEN
   okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: invoke_refund_wf : OTHERS ');
      ROLLBACK TO INVOKE_REFUND_WF;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','INVOKE_REFUND_WF');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

End  invoke_refund_wf;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : additional_tld_attr
-- Description     : Internal procedure to add additional columns for
--                   OKL_TXD_AR_LN_DTLS_B
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE additional_tld_attr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tldv_rec                     IN okl_tld_pvt.tldv_rec_type
   ,x_tldv_rec                     OUT NOCOPY okl_tld_pvt.tldv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'additional_tld_attr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
/*
        l_recv_inv_id NUMBER;
        CURSOR reverse_csr1(p_tld_id NUMBER) IS
        SELECT receivables_invoice_id
        FROM okl_txd_ar_ln_dtls_v
        WHERE id = p_tld_id;

        CURSOR reverse_csr2(p_til_id NUMBER) IS
        SELECT receivables_invoice_id
        FROM okl_txl_ar_inv_lns_v
        WHERE id = p_til_id;


  -- Get currency attributes
  CURSOR l_curr_csr(cp_currency_code VARCHAR2) IS
  SELECT c.minimum_accountable_unit,
    c.PRECISION
  FROM fnd_currencies c
  WHERE c.currency_code = cp_currency_code;
*/
  -- Get currency attributes
  CURSOR l_curr_csr(p_khr_id number) IS
  SELECT c.minimum_accountable_unit,
    c.PRECISION
  FROM fnd_currencies c,
       okl_trx_ar_invoices_b b
  WHERE c.currency_code = b.currency_code
  AND   b.khr_id = p_khr_id;


  l_min_acct_unit fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision fnd_currencies.PRECISION %TYPE;

  l_rounded_amount OKL_TXD_AR_LN_DTLS_B.amount%TYPE;

  -- to get inventory_org_id  bug 4890024 begin
  CURSOR inv_org_id_csr(p_contract_id NUMBER) IS
  SELECT NVL(inv_organization_id,   -99)
  FROM okc_k_headers_b
  WHERE id = p_contract_id;

begin
  -- Set API savepoint
  SAVEPOINT additional_tld_attr;
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_tldv_rec.id :'||p_tldv_rec.id);
    END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
  -- assign all passed in attributes from IN to OUT record
  x_tldv_rec := p_tldv_rec;
/* For R12, okl_arfetch_pub is absolete, so the following logic won't work
since the receivable_invoice_id is null
      --For Credit Memo Processing
      IF p_tldv_rec.tld_id_reverses IS NOT NULL THEN
        -- Null out variables
        l_recv_inv_id := NULL;

        OPEN reverse_csr1(p_tldv_rec.tld_id_reverses);
        FETCH reverse_csr1
        INTO l_recv_inv_id;
        CLOSE reverse_csr1;
        x_tldv_rec.reference_line_id := l_recv_inv_id;
      ELSE
        x_tldv_rec.reference_line_id := NULL;
      END IF;

      x_tldv_rec.receivables_invoice_id := NULL;
      -- Populated later by fetch
*/

      IF(p_tldv_rec.inventory_org_id IS NULL) THEN

        OPEN inv_org_id_csr(p_tldv_rec.khr_id);
        FETCH inv_org_id_csr
        INTO x_tldv_rec.inventory_org_id;
        CLOSE inv_org_id_csr;
      ELSE
        x_tldv_rec.inventory_org_id := p_tldv_rec.inventory_org_id;
      END IF;

      -- Bug 4890024 end

      -------- Rounded Amount --------------
      l_rounded_amount := NULL;
      l_min_acct_unit := NULL;
      l_precision := NULL;

      OPEN l_curr_csr(p_tldv_rec.khr_id);
      FETCH l_curr_csr
      INTO l_min_acct_unit,
        l_precision;
      CLOSE l_curr_csr;

      IF(NVL(l_min_acct_unit,   0) <> 0) THEN
        -- Round the amount to the nearest Min Accountable Unit
        l_rounded_amount := ROUND(p_tldv_rec.amount / l_min_acct_unit) * l_min_acct_unit;

      ELSE
        -- Round the amount to the nearest precision
        l_rounded_amount := ROUND(p_tldv_rec.amount,   l_precision);
      END IF;
      -------- Rounded Amount --------------
      x_tldv_rec.amount := l_rounded_amount;
      --TIL
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO additional_tld_attr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO additional_tld_attr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO additional_tld_attr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end additional_tld_attr;





PROCEDURE  create_credit_memo
                  (p_contract_id      IN NUMBER
                   ,p_cure_refund_id  IN NUMBER
                   ,p_amount         IN NUMBER
               	   ,x_return_status  OUT NOCOPY VARCHAR2
                   ,x_msg_count      OUT NOCOPY NUMBER
                   ,x_msg_data       OUT NOCOPY VARCHAR2 ) IS

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_CREDIT_MEMO';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_taiv_rec          okl_tai_pvt.taiv_rec_type;
xp_taiv_rec          okl_tai_pvt.taiv_rec_type;
lp_tilv_rec          okl_til_pvt.tilv_rec_type;
xp_tilv_rec          okl_til_pvt.tilv_rec_type;
lp_tldv_rec          okl_tld_pvt.tldv_rec_type;
xp_tldv_rec          okl_tld_pvt.tldv_rec_type;


CURSOR get_trx_id IS
SELECT  id FROM okl_trx_types_tl
WHERE   name = 'Credit Memo'   AND LANGUAGE = USERENV('LANG');
--WHERE   name = 'Billing'    AND LANGUAGE = USERENV('LANG');



/*
CURSOR get_sty_id IS
SELECT  sty.id
FROM    okl_strm_type_tl styt, okl_strm_type_b sty
WHERE   styt.name = 'CURE'  AND styt.language = 'US'
AND   sty.id = styt.id      AND sty.start_date <= TRUNC(SYSDATE)
AND   NVL(sty.end_date, SYSDATE) >= TRUNC(SYSDATE);
*/

CURSOR	l_rcpt_mthd_csr (cp_cust_rct_mthd IN NUMBER) IS
		SELECT	c.receipt_method_id
		FROM	ra_cust_receipt_methods  c
		WHERE	c.cust_receipt_method_id = cp_cust_rct_mthd;

CURSOR	l_site_use_csr (
			cp_site_use_id		IN NUMBER,
			cp_site_use_code	IN VARCHAR2) IS
SELECT	a.cust_account_id	cust_account_id,
			a.cust_acct_site_id	cust_acct_site_id,
			a.payment_term_id	payment_term_id
FROM    okx_cust_site_uses_v	a,
		okx_customer_accounts_v	c
WHERE	a.id1			= cp_site_use_id
		AND	a.site_use_code		= cp_site_use_code
		AND	c.id1			= a.cust_account_id;

l_site_use_rec	 l_site_use_csr%ROWTYPE;

CURSOR	l_std_terms_csr (
		cp_cust_id		IN NUMBER,
		cp_site_use_id		IN NUMBER) IS
SELECT	c.standard_terms	standard_terms
FROM	hz_customer_profiles	c
WHERE	c.cust_account_id	= cp_cust_id
        AND	c.site_use_id		= cp_site_use_id
		UNION
		SELECT	c1.standard_terms	standard_terms
		FROM	hz_customer_profiles	c1
		WHERE	c1.cust_account_id	= cp_cust_id
		AND	c1.site_use_id		IS NULL
		AND	NOT EXISTS (
			SELECT	'1'
			FROM	hz_customer_profiles	c2
			WHERE	c2.cust_account_id	= cp_cust_id
			AND	c2.site_use_id		= cp_site_use_id);


cursor c_program_id (p_contract_id IN NUMBER ) IS
select khr_id from okl_k_headers where id= p_contract_id;


l_program_id okl_k_headers.khr_id%TYPE;

l_id1           VARCHAR2(40)  :=NULL;
l_id2           VARCHAR2(200) :=NULL;
l_rule_value    VARCHAR2(2000):=NULL;


l_btc_id        NUMBER;

cursor c_getobj_ver(p_cure_refund_id IN NUMBER ) is
select object_version_number from okl_cure_refunds
where cure_refund_id =p_cure_refund_id;
lp_crfv_rec         okl_crf_pvt.crfv_rec_type;
lx_crfv_rec     	okl_crf_pvt.crfv_rec_type;

  -- Code segment for Customer Account/bill to address
  -- as mentioned in OKC Rules Migration HLD
  -- Start

  CURSOR bill_to_csr (p_program_id IN NUMBER) IS
   select BILL_TO_SITE_USE_ID
   from okc_k_party_roles_b
   where dnz_chr_id = p_program_id
   and RLE_CODE ='OKL_VENDOR';

  -- Code segment for Customer Account/bill to address
  -- as mentioned in OKC Rules Migration HLD
  -- End

l_bill_to_address_id NUMBER;
x_primary_sty_id NUMBER;

BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : START ');
      SAVEPOINT CREATE_CREDIT_MEMO;
      -- Initialize message list if p_init_msg_list is set to TRUE.
       FND_MSG_PUB.initialize;


      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /**logic
        1) create tai * TIL
       **/

       --INSERT okl_trx_ar_invoices_b
       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES ',
                  p_operation =>  'INSERT' );

       lp_taiv_rec.khr_id := p_contract_id;

      OPEN get_trx_id;
      FETCH get_trx_id INTO lp_taiv_rec.try_id;
      CLOSE get_trx_id;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'trxid '||lp_taiv_rec.try_id);

      END IF;
      IF lp_taiv_rec.try_id IS NULL THEN
			OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> 'OKL_REQUIRED_VALUE',
				p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Transaction Type');
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*
    OPEN get_sty_id;
    FETCH get_sty_id INTO lp_tilv_rec.sty_id ;
    CLOSE get_sty_id;
    */
        OKL_STREAMS_UTIL.get_primary_stream_type(
            			p_khr_id => p_contract_id,
            			p_primary_sty_purpose => 'CURE',
            			x_return_status => l_return_status,
            			x_primary_sty_id => x_primary_sty_id
            			);

    lp_tilv_rec.sty_id := x_primary_sty_id;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'sty_id '||lp_tilv_rec.sty_id);

    END IF;
    IF lp_tilv_rec.sty_id IS NULL THEN
			OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> 'OKL_REQUIRED_VALUE',
				p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Transaction Type');
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : lp_tilv_rec.sty_id : '||lp_tilv_rec.sty_id);
     -- need to  populate 4 fields. so that cure invoice gets
     --generated for vendor and not for the customer
     -- ibt_id,ixx_id,irm_id,irt_id
     --get cust_account from rule vendor billing set up

     OPEN  c_program_id(lp_taiv_rec.khr_id);
     FETCH c_program_id INTO l_program_id;
     CLOSE c_program_id;
     IF l_program_id IS NULL THEN
			OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> 'OKL_REQUIRED_VALUE',
				p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Vendor Program');
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'program Id' ||l_program_id);


    END IF;

    -- New code for bill to address START
    OPEN bill_to_csr (l_program_id);
    FETCH bill_to_csr INTO l_bill_to_address_id;
    CLOSE bill_to_csr;

    IF trunc(l_bill_to_address_id) IS NULL THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Retrieval of Bill To Address Id failed');
        END IF;
  	    OKL_API.SET_MESSAGE (
			  	 p_app_name	=> 'OKL',
				 p_msg_name	=> 'OKL_REQUIRED_VALUE',
				 p_token1	=> 'COL_NAME',
				 p_token1_value	=> 'Bill To Address Id');
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_btc_id :=l_bill_to_address_id;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Bill to address id from rule is  ' || l_btc_id);

    END IF;
	-- *****************************************************
	-- Extract Customer, Bill To and Payment Term from rules
	-- *****************************************************

    OPEN	l_site_use_csr (l_btc_id, 'BILL_TO');
	FETCH	l_site_use_csr INTO l_site_use_rec;
	CLOSE	l_site_use_csr;

    lp_taiv_rec.ibt_id	:= l_site_use_rec.cust_acct_site_id;
	lp_taiv_rec.ixx_id	:= l_site_use_rec.cust_account_id;
	lp_taiv_rec.irt_id	:= l_site_use_rec.payment_term_id;

	IF lp_taiv_rec.irt_id IS NULL
		OR lp_taiv_rec.irt_id = FND_API.G_MISS_NUM THEN
		OPEN	l_std_terms_csr (
				l_site_use_rec.cust_account_id,
				l_btc_id);
		FETCH	l_std_terms_csr INTO lp_taiv_rec.irt_id;
		CLOSE	l_std_terms_csr;
	END IF;


	IF lp_taiv_rec.ixx_id IS NULL
		OR lp_taiv_rec.ixx_id = FND_API.G_MISS_NUM THEN
			OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> 'OKL_REQUIRED_VALUE',
				 p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Customer Account Id');
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF lp_taiv_rec.ibt_id IS NULL
		OR lp_taiv_rec.ibt_id = FND_API.G_MISS_NUM  THEN
			OKL_API.SET_MESSAGE (
				p_app_name	   => 'OKL',
				p_msg_name	   => 'OKL_REQUIRED_VALUE',
			    p_token1	   => 'COL_NAME',
				p_token1_value => 'Bill To Address Id');
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF lp_taiv_rec.irt_id IS NULL
 	   OR lp_taiv_rec.irt_id = FND_API.G_MISS_NUM THEN
    	  OKL_API.SET_MESSAGE (
				p_app_name	=> 'OKL',
				p_msg_name	=> 'OKL_REQUIRED_VALUE',
 			    p_token1	=> 'COL_NAME',
				p_token1_value	=> 'Payment Term Id');
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;


   l_rule_value := NULL;
   l_id1        := NULL;
   l_id2        := NULL;

   l_return_status := okl_contract_info.get_rule_value(
                            p_contract_id      => l_program_id
                            ,p_rule_group_code => 'LAVENB'
                            ,p_rule_code	   => 'LAPMTH'
                            ,p_segment_number  => 16
                            ,x_id1             => l_id1
                            ,x_id2             => l_id2
                            ,x_value           => l_rule_value);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : okl_contract_info.get_rule_value : '||l_return_status);
   if l_return_status =FND_Api.G_RET_STS_SUCCESS
             and l_id1 IS NOT NULL THEN
             lp_taiv_rec.irm_id :=l_id1;
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Payment method from rule is  ' || l_id1);
             END IF;
   else
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Retrieval of Payment Method Id failed');
             END IF;
			 OKL_API.SET_MESSAGE (
			  	 p_app_name	=> 'OKL',
				 p_msg_name	=> 'OKL_REQUIRED_VALUE',
				 p_token1	=> 'COL_NAME',
				 p_token1_value	=> 'Payment Method ');
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  end if;

  OPEN	l_rcpt_mthd_csr (l_id1);
  FETCH	l_rcpt_mthd_csr INTO lp_taiv_rec.irm_id;
  CLOSE	l_rcpt_mthd_csr;

  IF lp_taiv_rec.irm_id IS NULL
 		  OR lp_taiv_rec.irm_id = FND_API.G_MISS_NUM THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'receipt method id is not found');
            END IF;
			 OKL_API.SET_MESSAGE (
			  	 p_app_name	=> 'OKL',
				 p_msg_name	=> 'OKL_REQUIRED_VALUE',
				 p_token1	=> 'COL_NAME',
				 p_token1_value	=> 'receipt method id ');
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

      lp_taiv_rec.object_version_number :=1;
      lp_taiv_rec.date_entered    :=SYSDATE;
      lp_taiv_rec.date_invoiced   :=SYSDATE;
      lp_taiv_rec.amount          :=p_amount * - 1;
      lp_taiv_rec.description     := 'Cure Invoice';
      lp_taiv_rec.trx_status_code :='PENDINGI';
       -- this will establish a link for offset contracts with a refund line
      --lp_taiv_rec.cpy_id          :=p_cure_refund_id;
						--20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
    lp_taiv_rec.legal_entity_id            := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(lp_taiv_rec.khr_id);

      -- R12 Changes - START
      -- Following is new as per Ashim's instructions

      lp_taiv_rec.okl_source_billing_trx := 'CURE';

      -- R12 Changes - END


      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'taiv_rec.cpy_id' ||lp_taiv_rec.cpy_id ||
                                  ' taiv_rec.try_id' ||lp_taiv_rec.try_id||
                                  ' taiv_rec.khr_id' ||lp_taiv_rec.khr_id||
                                  ' taiv_rec.irm_id'||lp_taiv_rec.irm_id||
                                  ' taiv_rec.ibt_id'||lp_taiv_rec.ibt_id||
                                  ' taiv_rec.ixx_id '||lp_taiv_rec.ixx_id||
                                  ' taiv_rec.irt_id'||lp_taiv_rec.irt_id);

      END IF;


-- ASHIM CHANGE - START


      okl_trx_ar_invoices_pub.INSERT_trx_ar_invoices
                     (p_api_version     => 1.0,
                      p_init_msg_list   => 'F',
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_taiv_rec        => lp_taiv_rec,
                      x_taiv_rec        => xp_taiv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : okl_trx_ar_invoices_pub.INSERT_trx_ar_invoices : '||l_return_status);

     IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
          Get_Messages (l_msg_count,l_message);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error in updating okl_trx_ar_invoices_b '
                                      ||l_message);
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          FND_MSG_PUB.initialize;
         --INSERT okl_txl_ar_inv_lns
         --set error message,so this will be prefixed before the
         --actual message, so it makes more sense than displaying an
         -- OKL message.
         AddfailMsg(
                  p_object    =>  'RECORD IN  OKL_TXL_AR_INV_LNS ',
                  p_operation =>  'INSERT' );


         lp_tilv_rec.amount                :=p_amount * -1;
         lp_tilv_rec.object_version_number :=1;
         lp_tilv_rec.tai_id                :=xp_taiv_rec.id;
         lp_tilv_rec.description           :='Cure Invoice';
         lp_tilv_rec.inv_receiv_line_code  :='LINE';
         lp_tilv_rec.line_number           :=1;

         -- R12 Change - START
         -- Following is new as per Ashim's instructions

         lp_tilv_rec.txl_ar_line_number    :=1;

         -- R12 Change - END

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'tilv_rec.tai_id' ||lp_tilv_rec.tai_id||
                                     'tilv_rec.amount' ||lp_tilv_rec.amount||
                                     'tilv_rec.sty_id' ||lp_tilv_rec.sty_id);


         END IF;
         okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns
                     (p_api_version     => 1.0,
                      p_init_msg_list   => 'F',
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_tilv_rec        => lp_tilv_rec,
                      x_tilv_rec        => xp_tilv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns : '||l_return_status);
-- ASHIM CHANGE - END



         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
              Get_Messages (l_msg_count,l_message);
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error in updating okl_txl_ar_inv_lns '
                                          ||l_message);
              END IF;
              raise FND_API.G_EXC_ERROR;
        ELSE
             FND_MSG_PUB.initialize;

          -- R12 Change - START
          -- Ashim's instructions for TXD table
          -- populate sty_id, kle_id(NULL), khr_id, amount, til_id_details, txl_ar_line_number

          AddfailMsg(
                  p_object    =>  'RECORD IN  OKL_TXD_AR_LN_DTLS ',
                  p_operation =>  'INSERT' );

          lp_tldv_rec.TIL_ID_DETAILS     := xp_tilv_rec.id;
          lp_tldv_rec.STY_ID             := xp_tilv_rec.STY_ID;
          lp_tldv_rec.AMOUNT             := xp_tilv_rec.AMOUNT;
          lp_tldv_rec.ORG_ID             := xp_tilv_rec.ORG_ID;
          lp_tldv_rec.INVENTORY_ORG_ID   := xp_tilv_rec.INVENTORY_ORG_ID;
          lp_tldv_rec.INVENTORY_ITEM_ID  := xp_tilv_rec.INVENTORY_ITEM_ID;
          lp_tldv_rec.LINE_DETAIL_NUMBER := 1;
          lp_tldv_rec.KHR_ID             := lp_taiv_rec.KHR_ID;
          lp_tldv_rec.txl_ar_line_number :=1;


          okl_internal_billing_pvt.Get_Invoice_format(
             p_api_version                  => 1.0
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data
            ,p_inf_id                       => lp_taiv_rec.inf_id
            ,p_sty_id                       => lp_tldv_rec.STY_ID
            ,x_invoice_format_type          => lp_tldv_rec.invoice_format_type
            ,x_invoice_format_line_type     => lp_tldv_rec.invoice_format_line_type);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : okl_internal_billing_pvt.Get_Invoice_format : '||l_return_status);

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
          THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
          THEN
            RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

          additional_tld_attr(
            p_api_version         => 1.0,
            p_init_msg_list       => OKL_API.G_FALSE,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_tldv_rec            => lp_tldv_rec,
            x_tldv_rec            => xp_tldv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : additional_tld_attr : '||l_return_status);
          lp_tldv_rec := xp_tldv_rec;

          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
            END IF;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

          okl_tld_pvt.insert_row(
            p_api_version          =>  1.0,
            p_init_msg_list        =>  OKL_API.G_FALSE,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_rec,
            x_tldv_rec             =>  xp_tldv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : okl_tld_pvt.insert_row : '||l_return_status);

          IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
            END IF;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          ELSE
            FND_MSG_PUB.initialize;

          END IF; -- for okl_txd_ar_ln_dtls

          -- R12 Change - END


       END IF; -- for okl_txl_ar_inv_lns
     END IF; -- for okl_trx_ar_invoices

    --update tai_id in cure_refund_table
    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUNDS ',
                  p_operation =>  'UPDATE' );


      lp_crfv_rec.cure_refund_id := p_cure_refund_id;
      lp_crfv_rec.tai_id         := xp_taiv_rec.id;

      OPEN c_getobj_ver(p_cure_refund_id);
      FETCH c_getobj_ver INTO  lp_crfv_rec.object_version_number;
      CLOSE c_getobj_ver;


      OKL_cure_refunds_pub.update_cure_refunds(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crfv_rec        => lp_crfv_rec
                          ,x_crfv_rec        => lx_crfv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : OKL_cure_refunds_pub.update_cure_refunds : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated CRF records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;

 IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
 END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_credit_memo : END ');
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_CREDIT_MEMO;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_CREDIT_MEMO;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_CREDIT_MEMO;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','CREATE_CREDIT_MEMO');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END CREATE_CREDIT_MEMO;


PROCEDURE  CREATE_CUREREFUNDS
               (p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               )IS
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_CUREREFUNDS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;
lp_tapv_rec         okl_tap_pvt.tapv_rec_type;
lx_tapv_rec     	okl_tap_pvt.tapv_rec_type;
lp_tplv_rec     	okl_tpl_pvt.tplv_rec_type;
lx_tplv_rec     	okl_tpl_pvt.tplv_rec_type;

/* ankushar 22-JAN-2007
   added table definitions
   start changes
*/
 lp_tplv_tbl     	        okl_tpl_pvt.tplv_tbl_type;
 lx_tplv_tbl     	      okl_tpl_pvt.tplv_tbl_type;
/* ankushar end changes*/

lp_crfv_rec         okl_crf_pvt.crfv_rec_type;
lx_crfv_rec     	okl_crf_pvt.crfv_rec_type;



lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;

next_row integer;

cursor c_get_refunds(p_cure_refund_header_id IN NUMBER) is
select crf.chr_id,
       crf.disbursement_amount,
       crf.offset_contract,
       crf.offset_amount,
       crf.object_version_number,
       crf.cure_refund_id,
       crh.vendor_site_id,
       crh.payment_term_id,
       crh.payment_method,
       crh.currency_code,
       crh.refund_due_date

from okl_cure_refund_headers_b crh,
     okl_cure_refunds crf
where crh.cure_refund_header_id =p_cure_refund_header_id
      and crh.cure_refund_header_id =crf.cure_refund_header_id;

 CURSOR product_csr (p_chr_id IN NUMBER) IS
         SELECT  khr.pdt_id
	     FROM    okl_k_headers khr
     	 WHERE   khr.id = p_chr_id;


CURSOR org_id_csr ( p_khr_id NUMBER ) IS
    	   SELECT chr.authoring_org_id
    	   FROM okc_k_headers_b chr
    	   WHERE id =  p_khr_id;

CURSOR sob_csr ( p_org_id  NUMBER ) IS
    	   SELECT hru.set_of_books_id
    	   FROM HR_OPERATING_UNITS HRU
    	   WHERE ORGANIZATION_ID = p_org_id;

CURSOR try_id_csr IS
     	   SELECT id
    	   FROM okl_trx_types_tl
    	   WHERE name = 'Disbursement'
           AND LANGUAGE = USERENV('LANG');

/* -- user defined streams
 CURSOR stream_type_csr IS
      SELECT id
      FROM   okl_strm_type_tl
      WHERE  name = 'CURE'
      AND    LANGUAGE = USERENV('LANG');
*/

x_primary_sty_id number;
l_khr_id number;

  CURSOR c_app
  IS
  select a.application_id
  from FND_APPLICATION a
  where APPLICATION_SHORT_NAME = 'OKL';

l_okl_application_id NUMBER(3) := 540;
l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
lX_dbseqnm          VARCHAR2(2000):= '';
lX_dbseqid          NUMBER(38):= NULL;


BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_CUREREFUNDS : START ');
      SAVEPOINT CREATE_CUREREFUNDS;
      -- Initialize message list if p_init_msg_list is set to TRUE.
          FND_MSG_PUB.initialize;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_refund_header_id IS NULL)  THEN
          AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'p_refund_header_id');
                    RAISE FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.org_id '||
                                       lp_tapv_rec.org_id);
               END IF;
           END IF;
 	 END IF;


       /*** Logic for refunds ********
       ** 1) Invoke the common disbursement API for ap header and line creation
       **/
    -- STEP 1
    --populate the ap invoice header table (okl_trx_ap_invoices_b)
      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update cure refunds ');
         END IF;
      END IF;


    -- STEP 1
    --populate the ap invoice header table (okl_trx_ap_invoices_b)
      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before creating TAP record ');
         END IF;
      END IF;


      FOR i in c_get_refunds (p_refund_header_id)
      LOOP
  	      lp_tapv_rec.org_id := NULL;
     	  OPEN 	org_id_csr ( i.chr_id) ;
  	      FETCH	org_id_csr INTO lp_tapv_rec.org_id;
	      CLOSE	org_id_csr;

          IF (lp_tapv_rec.org_id IS NULL)  THEN
             AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'org_id' );
                    RAISE FND_API.G_EXC_ERROR;
          ELSE
             IF PG_DEBUG < 11  THEN
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.org_id '||
                                       lp_tapv_rec.org_id);
               END IF;
             END IF;
    	     END IF;

   	    OPEN	sob_csr ( lp_tapv_rec.org_id );
   	    FETCH	sob_csr INTO lp_tapv_rec.set_of_books_id;
	       CLOSE	sob_csr;

        IF (lp_tapv_rec.set_of_books_id IS NULL)  THEN
           AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'set_of_books_id' );
                    RAISE FND_API.G_EXC_ERROR;
        ELSE
             IF PG_DEBUG < 11  THEN
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.set_of_books_id'||
                                      lp_tapv_rec.set_of_books_id);
                END IF;
             END IF;
 	      END IF;

        lp_tapv_rec.try_id := NULL;
        OPEN  try_id_csr;
        FETCH try_id_csr INTO lp_tapv_rec.try_id;
        CLOSE try_id_csr;

        IF (lp_tapv_rec.try_id IS NULL)  THEN
           AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'try_id' );
                    RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.try_id'||
                                     lp_tapv_rec.try_id);
             END IF;
          END IF;
 	      END IF;
   	   lp_tapv_rec.invoice_number := NULL;

       --
       -- display specific application error if 'OKL Lease Pay Invoices'
       -- has not been setup or setup incorrectly
       --

       OPEN c_app;
       FETCH c_app INTO l_okl_application_id;
       CLOSE c_app;
       l_okl_application_id := nvl(l_okl_application_id,540);

       BEGIN
           lp_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
                                                    (appid      =>  l_okl_application_id,
                                                     cat_code    =>  l_document_category,
                                                     sobid       =>  lp_tapv_rec.set_of_books_id,
                                                     met_code    =>  'A',
                                                     trx_date    =>  SYSDATE,
                                                     dbseqnm     =>  lx_dbseqnm,
                                                     dbseqid     =>  lx_dbseqid);

      EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE = 100 THEN
          fnd_message.set_name('OKL', 'OKL_PAY_INV_SEQ_CHECK');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END;

      IF (lp_tapv_rec.invoice_number IS NULL)  THEN
         AddMissingArgMsg(
                    p_api_name    =>  l_api_name_full,
                    p_param_name  =>  'invoice_number' );
                    RAISE FND_API.G_EXC_ERROR;
     ELSE
         IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lp_tapv_rec.invoice_number'||
                                    lp_tapv_rec.invoice_number);
            END IF;
         END IF;

  	 END IF;


     -- sjalasut, commented the below khr_id assignment as khr_id would be henceforth referred in
     -- okl_txl_ap_inv_lns_all_b. changes made as part of OKLR12B disbursements project.
   	  lp_tapv_rec.khr_id                := i.chr_id; -- cklee 09/20/2007
--   	 lp_tapv_rec.khr_id                := NULL;

     lp_tapv_rec.ipvs_id               := i.vendor_site_id;
     lp_tapv_rec.ippt_id               := i.payment_term_id;
     lp_tapv_rec.payment_method_code   := i.payment_method;
     lp_tapv_rec.currency_code         := i.currency_code;
     lp_tapv_rec.date_entered          := sysdate;
     lp_tapv_rec.date_invoiced         := i.refund_due_date;
     lp_tapv_rec.amount                := i.disbursement_amount;
     lp_tapv_rec.trx_status_code       := 'PENDINGI';
     lp_tapv_rec.object_version_number := 1;
    --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
    -- sjalasut, changed the parameter from lp_tapv_rec.khr_id to i.chr_id as part of OKLR12B
    -- disbursements project.
    lp_tapv_rec.legal_entity_id            := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(i.chr_id);

    -- not sure of these 4 variable
    /* invoice_type,
       invoice_category_code,
       pay_group_lookup_code,
       nettable_yn,
       if invoice_type is credit then amount is -ve
     */

    --populate the line table (okl_txl_ap_inv_lns_b)
    -- sjalasut, added the khr_id assignment as part of OKLR12B disbursements project
      lp_tplv_rec.khr_id        := i.chr_id;

      lp_tplv_rec.tap_id	    	  :=  lx_tapv_rec.id;
      lp_tplv_rec.amount		      :=  lp_tapv_rec.amount;
      lp_tplv_rec.inv_distr_line_code :=  'MANUAL';
      lp_tplv_rec.line_number		  :=  1;
      lp_tplv_rec.org_id		      :=  lp_tapv_rec.org_id;
      lp_tplv_rec.disbursement_basis_code :=  'BILL_DATE';
   	  lp_tplv_rec.object_version_number  := 1;

      /* what about other columns
        sty_id,
       * is disbursement_basis_code= 'bill_date'
       */


/* --User Defines Streams fix
        FOR stream_rec IN stream_type_csr
        LOOP
           lp_tplv_rec.sty_id := stream_rec.id;
            IF PG_DEBUG < 11  THEN
              okl_debug_pub.logmessage ('sty_id ' ||stream_rec.id);
            END IF;
        END LOOP;
*/

    l_khr_id := i.chr_id;

    OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id => l_khr_id,
    			p_primary_sty_purpose => 'CURE',
    			x_return_status => l_return_status,
    			x_primary_sty_id => x_primary_sty_id
    			);

    lp_tplv_rec.sty_id  := x_primary_sty_id;

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
       Get_Messages (l_msg_count,l_message);
       IF PG_DEBUG < 11  THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
        END IF;
       END IF;
       raise FND_API.G_EXC_ERROR;

    ELSE

       IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'sty_id ' ||x_primary_sty_id);
            END IF;
       END IF;

    END IF;

/* ankushar 23-JAN-2007
   Call to the common Disbursement API
   start changes */

-- Add tpl_rec to table
   lp_tplv_tbl(1) := lp_tplv_rec;

--Call the commong disbursement API to create transactions
-- start:
--cklee 06/04/2007 Reverse the original code back due to the duplicated
-- accounting entries will be created
/*
         lp_tplv_tbl(1) := lp_tplv_rec;

   --Call the commong disbursement API to create transactions
        Okl_Create_Disb_Trans_Pvt.create_disb_trx(
             p_api_version      =>   1.0
            ,p_init_msg_list    =>   'F'
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tapv_rec         =>   lp_tapv_rec
            ,p_tplv_tbl         =>   lp_tplv_tbl
            ,x_tapv_rec         =>   lx_tapv_rec
            ,x_tplv_tbl         =>   lx_tplv_tbl);
*/
    OKL_TRX_AP_INVOICES_PUB.INSERT_TRX_AP_INVOICES(
      p_api_version   => 1.0,
      p_init_msg_list => 'F',
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => lp_tapv_rec,
      x_tapv_rec      => lx_tapv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_CUREREFUNDS : OKL_TRX_AP_INVOICES_PUB.INSERT_TRX_AP_INVOICES : '||x_return_status);

     IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
       IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
         END IF;
       END IF;
       raise FND_API.G_EXC_ERROR;
     ELSE
       IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tapv_rec.id'
                                     ||lx_tapv_rec.id);
         END IF;
       END IF;
       FND_MSG_PUB.initialize;
    END IF;

      lp_tplv_rec.tap_id := lx_tapv_rec.id;

      OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS(
        p_api_version   => 1.0,
        p_init_msg_list => 'F',
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_tplv_rec      => lp_tplv_rec,
        x_tplv_rec      => lx_tplv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_CUREREFUNDS : OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS : '||x_return_status);
     IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
       IF PG_DEBUG <11 THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
         END IF;
       END IF;
       raise FND_API.G_EXC_ERROR;
     ELSE
       IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_tplv_rec.id'
                                     ||lx_tplv_rec.id);
         END IF;
       END IF;
       FND_MSG_PUB.initialize;
    END IF;
-- end:
--cklee 06/04/2007 Reverse the original code back due to the duplicated
-- accounting entries will be created
 /* ankushar end changes */

    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUNDS ',
                  p_operation =>  'UPDATE' );


      lp_crfv_rec.cure_refund_id := i.cure_refund_id;
      lp_crfv_rec.tap_id         :=  lx_tapv_rec.id;
      lp_crfv_rec.object_version_number :=i.object_version_number;

      OKL_cure_refunds_pub.update_cure_refunds(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_crfv_rec        => lp_crfv_rec
                          ,x_crfv_rec        => lx_crfv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_CUREREFUNDS : OKL_cure_refunds_pub.update_cure_refunds : '||x_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated CRF records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;

    IF i.offset_contract is not null THEN
          --Update Cure refunds table
          --set error message,so this will be prefixed before the
          --actual message, so it makes more sense than displaying an
          -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES_B ',
                  p_operation =>  'CREATE' );


-- ASHIM CHANGE - START



        create_credit_memo (p_contract_id     => i.offset_contract
                            ,p_cure_refund_id => i.cure_refund_id
                            ,p_amount         => i.offset_amount
               	            ,x_return_status  => l_return_status
        	            ,x_msg_count      => l_msg_count
		            ,x_msg_data       => l_msg_data );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_CUREREFUNDS : create_credit_memo : '||l_return_status);

-- ASHIM CHANGE - END


   	    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	        Get_Messages (l_msg_count,l_message);
            IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
            END IF;
            raise FND_API.G_EXC_ERROR;
       ELSE
            IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success ' );
              END IF;
            END IF;
            FND_MSG_PUB.initialize;
      END IF;
    END IF; --offset contract

 END LOOP;

 IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
 END IF;

 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )   THEN
         COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: CREATE_CUREREFUNDS : END ');
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_CUREREFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_CUREREFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_CUREREFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','CREATE_CUREREFUNDS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END  create_curerefunds;


PROCEDURE  approve_cure_refunds
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               )IS
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'APPROVE_CURE_REFUNDS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number,
       refund_header_number,
       refund_status
from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;
l_refund_header_number okl_cure_refund_headers_b.refund_header_number%TYPE;

l_refund_status okl_cure_refund_headers_b.refund_status%TYPE;

next_row integer;
c_check_dtls_ctr NUMBER :=0;

cursor c_check_dtls (p_refund_header_id IN NUMBER) is
select count(cure_refund_id) from okl_cure_refunds where
cure_refund_header_id =p_refund_header_id;


BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: approve_cure_refunds : START ');
      SAVEPOINT APPROVE_CURE_REFUNDS_PVT;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

       /*** Logic for refunds ********
       ** check if details exists before submitting
       ** check if refund_status ='ENTERED'
       ** 0 )create tap, tai (if offset contract is present)
       ** 1) Call Workflow for approving Refund
       ** 2) Update Cure Refund hdr - WAITING FOR APPROVAL '
       **/



       OPEN  c_check_dtls (p_refund_header_id);
       FETCH c_check_dtls into c_check_dtls_ctr;
       CLOSE c_check_dtls;

      OPEN c_getobj(p_refund_header_id);
      FETCH c_getobj INTO lp_chdv_rec.object_version_number,
                                      l_refund_header_number,
                                      l_refund_status;
      CLOSE c_getobj;

       IF c_check_dtls_ctr = 0 THEN
          -- no refund details
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'No refund details exists for '
                                           ||p_refund_header_id);
              END IF;
           END IF;
              fnd_message.set_name('OKL', 'OKL_CO_MISSING_REFUND_DETAILS');
              fnd_message.set_token('REFUND_NUMBER',l_refund_header_number);
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
      ELSE
          --check for refund header status
           IF l_refund_status <> 'IN_PROGRESS' THEN
              IF PG_DEBUG < 11  THEN
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Refund status is not in progress');
                  END IF;
             END IF;
             fnd_message.set_name('OKL', 'OKL_CO_REFUND_STATUS');
             fnd_message.set_token('REFUND_NUMBER',l_refund_header_number);
             fnd_msg_pub.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF; --refund_status check
     END IF; -- if details exists
    -- STEP 0
    --populate the ap invoice header table (okl_trx_ap_invoices_b)
      IF PG_DEBUG < 11  THEN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before creating TAP record ');
         END IF;
      END IF;

     create_curerefunds(
                      p_commit             =>'F'
                     ,p_refund_header_id  =>p_refund_header_id
    	             ,x_return_status	=> l_return_status
  			         ,x_msg_count		=> l_msg_count
			         ,x_msg_data	    => l_msg_data );
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: approve_cure_refunds : create_curerefunds : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after calling WF' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          FND_MSG_PUB.initialize;
    END IF;

     --call refund_workflow
      invoke_refund_wf(
                  p_refund_header_id=>p_refund_header_id
            	 ,x_return_status	=> l_return_status
			      ,x_msg_count		=> l_msg_count
			      ,x_msg_data	    => l_msg_data );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: approve_cure_refunds : invoke_refund_wf : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after calling WF' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          FND_MSG_PUB.initialize;
    END IF;

    --Update Cure refunds headers table
    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_HEADERS ',
                  p_operation =>  'UPDATE' );

      lp_chdv_rec.cure_refund_header_id :=p_refund_header_id;
      lp_chdv_rec.refund_status         :='PENDINGI';


     OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: approve_cure_refunds : OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error after updating Refund header'
                                           ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
    END IF;



   IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;

 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )THEN
         COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: approve_cure_refunds : END ');
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO APPROVE_CURE_REFUNDS_PVT;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO APPROVE_CURE_REFUNDS_PVT;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO APPROVE_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','APPROVE_CURE_REFUNDS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);



END   approve_cure_refunds;


PROCEDURE submit_cure_refunds
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_status            IN VARCHAR2
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS

l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'SUBMIT_CURE_REFUNDS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;
lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;


lp_tapv_tbl         okl_tap_pvt.tapv_tbl_type;
lx_tapv_tbl     	okl_tap_pvt.tapv_tbl_type;
lp_taiv_tbl         okl_tai_pvt.taiv_tbl_type;
lx_taiv_tbl     	okl_tai_pvt.taiv_tbl_type;
lp_crsv_tbl         okl_crs_pvt.crsv_tbl_type;
xp_crsv_tbl         okl_crs_pvt.crsv_tbl_type;

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;


cursor c_get_refunds (p_refund_header_id IN NUMBER)
is  select crf.cure_refund_stage_id,
           crf.tai_id, crf.tap_id,
           crs.object_version_number
    from okl_cure_refunds crf,
         okl_cure_refund_stage crs
    where crf.cure_refund_header_id =p_refund_header_id
          and crs.cure_refund_stage_id=crf.cure_refund_stage_id;

next_row     integer;
tai_next_row integer;
BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : START ');

    SAVEPOINT SUBMIT_CURE_REFUNDS;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

     IF p_status ='APPROVED' THEN

        submit_cure_refund_hdr
             (  p_api_version          =>p_api_version
               ,p_init_msg_list        =>p_init_msg_list
               ,p_commit               =>p_commit
               ,p_refund_header_id     =>p_refund_header_id
               ,x_return_status        => l_return_status
               ,x_msg_count            => l_msg_count
               ,x_msg_data             => l_msg_data);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : submit_cure_refund_hdr : '||l_return_status);

    	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
        ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated TAP ' );
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
       END IF;

  ELSE
       /** logic**
       1) update tai -status to 'REJECTED'--if offset contract is populated
       2) update tap -status to 'REJECTED'
       4)update cure_refund_stage -status back to 'ENTERED'
       5) update cure_refund_headers -status to 'REJECTED'
      **/

        IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' cure refund header id ' ||
                                        p_refund_header_id);
             END IF;
        END IF;

        FOR i in c_get_refunds (p_refund_header_id)
        LOOP
            IF i.tai_id is not null THEN
                tai_next_row := nvl(lp_taiv_tbl.LAST,0) +1;
                lp_taiv_tbl(tai_next_row).id          :=i.tai_id;
                lp_taiv_tbl(tai_next_row).trx_status_code :='REJECTED';
            END IF;
           next_row := nvl(lp_tapv_tbl.LAST,0) +1;
           lp_tapv_tbl(next_row).id              :=i.tap_id;
           lp_tapv_tbl(next_row).trx_status_code :='REJECTED';

           lp_crsv_tbl(next_row).cure_refund_stage_id
                               :=i.cure_refund_stage_id;
           lp_crsv_tbl(next_row).status
                               :='ENTERED';

           lp_crsv_tbl(next_row).object_version_number
                               :=i.object_version_number;

       END LOOP;

       --Update trx ar invoices
       --set error message,so this will be prefixed before the
       --actual message, so it makes more sense than displaying an
       -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES',
                  p_operation =>  'UPDATE' );

  	  okl_trx_ap_invoices_pub.update_trx_ap_invoices(
  		  p_api_version			=> 1.0
		  ,p_init_msg_list		=> 'T'
		  ,x_return_status		=> l_return_status
		  ,x_msg_count			=> l_msg_count
		  ,x_msg_data			=> l_msg_data
		  ,p_tapv_tbl 			=> lp_tapv_tbl
		  ,x_tapv_tbl			=> lx_tapv_tbl);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : okl_trx_ap_invoices_pub.update_trx_ap_invoices : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated tap records');
             END IF;
          END IF;
          FND_MSG_PUB.initialize;
    END IF;

    IF lp_taiv_tbl.COUNT > 0 THEN
        --Update trx ar invoices
        --set error message,so this will be prefixed before the
        --actual message, so it makes more sense than displaying an
        -- OKL message.
        AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES',
                  p_operation =>  'UPDATE' );


-- ASHIM CHANGE - START



    	okl_trx_ar_invoices_pub.update_trx_ar_invoices(
   		   p_api_version		=> 1.0
		   ,p_init_msg_list		=> 'T'
		   ,x_return_status		=> l_return_status
		   ,x_msg_count			=> l_msg_count
		   ,x_msg_data			=> l_msg_data
		   ,p_taiv_tbl 			=> lp_taiv_tbl
		   ,x_taiv_tbl			=> lx_taiv_tbl);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : okl_trx_ar_invoices_pub.update_trx_ar_invoices : '||l_return_status);
-- ASHIM CHANGE - END


 	    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	        Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG <11 THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
           END IF;
           raise FND_API.G_EXC_ERROR;
       ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Succesfully updated tai records');
              END IF;
           END IF;
          FND_MSG_PUB.initialize;
      END IF;
   END IF; -- if tai table count > 0

   --Update OKL_CURE_REFUND_STAGE
   --set error message,so this will be prefixed before the
   --actual message, so it makes more sense than displaying an
   -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_STAGE',
                  p_operation =>  'UPDATE' );

     OKL_cure_rfnd_stage_pub.update_cure_refunds(
      p_api_version         => 1.0
     ,p_init_msg_list       =>'F'
     ,x_return_status	    => l_return_status
     ,x_msg_count		    => l_msg_count
     ,x_msg_data	      	 => l_msg_data
     ,p_crsv_tbl             => lp_crsv_tbl
     ,x_crsv_tbl             => xp_crsv_tbl);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : OKL_cure_rfnd_stage_pub.update_cure_refunds : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
              END IF;
           END IF;
    END IF;

  END IF; --p_status

    --Update Cure refunds table
    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_HEADERS ',
                  p_operation =>  'UPDATE' );



      lp_chdv_rec.cure_refund_header_id :=p_refund_header_id;
      lp_chdv_rec.refund_status         :=p_status;

      OPEN c_getobj(p_refund_header_id);
      FETCH c_getobj INTO lp_chdv_rec.object_version_number;
      CLOSE c_getobj;

     OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr : '||l_return_status);

 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
              END IF;
           END IF;
           FND_MSG_PUB.initialize;
    END IF;


    IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;


 -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: submit_cure_refunds : END ');
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO SUBMIT_CURE_REFUNDS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','SUBMIT_CURE_REFUNDS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END  submit_cure_refunds;

/**
  called from the workflow to update cure refunds based on
  the approval
**/
  PROCEDURE set_approval_status (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2) IS
l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message      VARCHAR2(32627) :=NULL;

l_refund_header_id  VARCHAR2(32627);
--okl_cure_refund_headers_b.cure_refund_header_id%TYPE;
l_refund_status  okl_cure_refund_headers_b.refund_status%TYPE;
l_nid NUMBER;
l_role_name VARCHAR2(30);

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;

lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;




BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_approval_status : START ');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

        if funcmode <> 'RUN' then
          result := wf_engine.eng_null;
          return;
        end if;

       l_refund_header_id := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'CURE_REFUND_HEADER_ID');

       IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' cure refund header id ' ||
                                        l_refund_header_id);
            END IF;
       END IF;

 	         OKL_PAY_CURE_REFUNDS_PVT.SUBMIT_CURE_REFUNDS(
              p_api_version		     => 1.0
      	     ,p_init_msg_list	     => 'T'
             ,p_commit               => 'F'
             ,p_status               => 'APPROVED'
             ,p_refund_header_id     => to_number(l_refund_header_id)
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
             ,x_msg_data	      	 => l_msg_data
           );
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_approval_status : OKL_PAY_CURE_REFUNDS_PVT.SUBMIT_CURE_REFUNDS : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error---->' ||l_message);
              END IF;
              --set error message
             -- sent a notification to SYSADMIN with the error message
              -- Also update the refund_header to IN_PROGRESS
           END IF;

           wf_engine.SetItemAttrText(itemtype  => itemtype,
                                        itemkey   => itemkey,
                                        aname     => 'ERROR_MESSAGE',
                                        avalue    => l_message);

              --the message is sent to the SYSADMIN
              -- could be sent to any one , only need to populate the notify_error attribute

                 wf_engine.SetItemAttrText(itemtype  => itemtype,
                                        itemkey   => itemkey,
                                        aname     => 'NOTIFY_ERROR',
                                        avalue    => 'SYSADMIN');


              result := wf_engine.eng_completed ||':'||'E';

              lp_chdv_rec.cure_refund_header_id := l_refund_header_id;
              lp_chdv_rec.refund_status         := 'IN_PROGRESS';

              OPEN c_getobj(l_refund_header_id);
              FETCH c_getobj INTO lp_chdv_rec.object_version_number;
              CLOSE c_getobj;

              OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
                             p_api_version     => 1.0
                            ,p_init_msg_list   => 'F'
                            ,x_return_status   => l_return_status
                            ,x_msg_count       => l_msg_count
                            ,x_msg_data        => l_msg_data
                            ,p_chdv_rec        => lp_chdv_rec
                            ,x_chdv_rec        => lx_chdv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_approval_status : OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr : '||l_return_status);
   	         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
  	              Get_Messages (l_msg_count,l_message);
                   IF PG_DEBUG < 11  THEN
                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error in update of cure refund to PENDINGI' ||l_message);
                      END IF;
                   END IF;
                   raise FND_API.G_EXC_ERROR;
            ELSE
                 IF PG_DEBUG < 11  THEN
                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
                     END IF;
                 END IF;
            END IF;

     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
              END IF;
           END IF;

           --send notification to Vendor
           --get Vendor_role ( if null do not send notification,
           --that means there are no notifications)
           --
               l_role_name :=wf_engine.GetItemAttrText(
                                    itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'VENDOR_ROLE');
               IF PG_DEBUG < 11  THEN
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,
                              'Vendor Role Name is ' ||l_role_name );
                  END IF;
               END IF;

          -- Role name will be populated if there are offset contracts
          -- and notification will be sent if there are offset contract
           -- and result is 'Y to sent notifications
          if l_role_name is not null THEN
             result := wf_engine.eng_completed ||':'||'Y';
          else
             result := wf_engine.eng_completed ||':'||'N';
         End if;

    END IF;


  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_approval_status : END ');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_PAY_CURE_REFUNDS_PVT',
                       'set_approval_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

    when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_PAY_CURE_REFUNDS_PVT',
                       'set_approval_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

 END set_approval_status;
/**
  called from the workflow to update cure refunds based on
  the approval
**/
  PROCEDURE set_reject_status (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2) IS
l_api_version   NUMBER := 1;
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message      VARCHAR2(32627);

l_refund_header_id  VARCHAR2(32627);
l_refund_status  okl_cure_refund_headers_b.refund_status%TYPE;


BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_reject_status : START ');
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

        if funcmode <> 'RUN' then
          result := wf_engine.eng_null;
          return;
       end if;

       l_refund_header_id := wf_engine.GetItemAttrText(
                                           itemtype  => itemtype,
                                           itemkey   => itemkey,
                                           aname     => 'CURE_REFUND_HEADER_ID');


 	         OKL_PAY_CURE_REFUNDS_PVT.SUBMIT_CURE_REFUNDS(
              p_api_version		     => 1.0
      	     ,p_init_msg_list	     => 'T'
             ,p_commit               => 'F'
             ,p_status               => 'REJECTED'
             ,p_refund_header_id     => to_number(l_refund_header_id)
	         ,x_return_status	     => l_return_status
	         ,x_msg_count		     => l_msg_count
             ,x_msg_data	      	 => l_msg_data
           );
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_reject_status : OKL_PAY_CURE_REFUNDS_PVT.SUBMIT_CURE_REFUNDS : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
              END IF;
           END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF PG_DEBUG < 11  THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Success -updated cure refund header' );
              END IF;
           END IF;
    END IF;
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: set_reject_status : END ');
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_PAY_CURE_REFUNDS_PVT',
                       'set_reject_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

    when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_PAY_CURE_REFUNDS_PVT',
                       'set_reject_status',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
       raise;

 END set_reject_status;


PROCEDURE create_refund_headers
             (  p_api_version           IN NUMBER
               ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_cure_refund_header_id OUT NOCOPY  NUMBER
               ,x_return_status         OUT NOCOPY VARCHAR2
               ,x_msg_count             OUT NOCOPY NUMBER
               ,x_msg_data              OUT NOCOPY VARCHAR2
               ) IS
l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_message  VARCHAR2(32627);
l_cure_refund_id okl_cure_refunds.cure_refund_id%type;
l_cure_refund_header_id okl_cure_refund_headers_b.cure_refund_header_id%type;
l_cure_refund_header_number okl_cure_refund_headers_b.refund_header_number%type;
l_api_name                CONSTANT VARCHAR2(50) := 'CREATE_REFUND_HEADERS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;

x_pay_tbl           pay_cure_refunds_tbl_type;

l_pay_cure_refunds_rec pay_cure_refunds_rec_type;
cursor chk_refund_number(p_refund_header_number IN VARCHAR2) IS
        select refund_header_number
        from okl_cure_refund_headers_b
        where refund_header_number =p_refund_header_number;

x_contract_number okc_k_headers_b.contract_number%TYPE;

BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_headers : START ');
      SAVEPOINT CREATE_REFUND_HEADERS;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

         --duplicate refund_number check
      OPEN 	chk_refund_number(p_pay_cure_refunds_rec.refund_number);
	  FETCH	chk_refund_number INTO l_cure_refund_header_number;
      CLOSE	chk_refund_number;
      if l_cure_refund_header_number IS NOT NULL THEN

         IF PG_DEBUG < 11  THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'duplicate refund number' );
             END IF;
         END IF;
          fnd_message.set_name('OKL', 'OKL_DUPLICATE_REFUND_NUMBER');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


     --create HEADERS first
     --create cure refund HEADERS record
     lp_chdv_rec.refund_header_number  := p_pay_cure_refunds_rec.refund_number;
    lp_chdv_rec.refund_type           := 'ALL';
     lp_chdv_rec.vendor_site_id        := p_pay_cure_refunds_rec.vendor_site_id;
  --   lp_chdv_rec.disbursement_amount   := p_pay_cure_refunds_rec.refund_amount;
   --  lp_chdv_rec.total_refund_due      := p_pay_cure_refunds_rec.refund_amount_due;
     lp_chdv_rec.refund_due_date       := p_pay_cure_refunds_rec.invoice_date;
     lp_chdv_rec.object_version_number := 1;
     lp_chdv_rec.description           := p_pay_cure_refunds_rec.description;
     lp_chdv_rec.refund_status         :='IN_PROGRESS';
     lp_chdv_rec.currency_code         :=p_pay_cure_refunds_rec.currency;
     lp_chdv_rec.payment_method        :=p_pay_cure_refunds_rec.payment_method_code;
     lp_chdv_rec.payment_term_id       :=p_pay_cure_refunds_rec.pay_terms;
     --lp_chdv_rec.chr_id                :=p_pay_cure_refunds_rec.chr_id;
     --lp_chdv_rec.vendor_site_cure_due  :=p_pay_cure_refunds_rec.vendor_site_cure_due;
     --lp_chdv_rec.vendor_cure_due       :=p_pay_cure_refunds_rec.vendor_cure_due;

     l_pay_cure_refunds_rec :=p_pay_cure_refunds_rec;

       OKL_cure_rfnd_hdr_pub.insert_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'T'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_headers : OKL_cure_rfnd_hdr_pub.insert_cure_rfnd_hdr : '||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'lx_chdv_rec.cure_refund_header_id'
                                     ||lx_chdv_rec.cure_refund_header_id);
           END IF;
           l_pay_cure_refunds_rec.refund_header_id :=
                                   lx_chdv_rec.cure_refund_header_id;
           x_cure_refund_header_id :=
                                   lx_chdv_rec.cure_refund_header_id;
     END IF;



  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: create_refund_headers : END ');
EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','CREATE_REFUND_HEADERS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);



END  create_refund_headers;

PROCEDURE update_refund_headers
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               )IS
cursor c_get_tap_ids (p_cure_refund_header_id IN NUMBER ) is
select a.tap_id,
       a.cure_refund_id,
       a.object_version_number,
       b.invoice_number
from okl_cure_refunds a, okl_trx_ap_invoices_b b
where cure_refund_header_id =p_cure_refund_header_id
 and a.tap_id =b.id;

cursor c_getobj(p_cure_refund_header_id IN NUMBER ) is
select object_version_number from okl_cure_refund_headers_b
where cure_refund_header_id =p_cure_refund_header_id;



l_init_msg_list VARCHAR2(1);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER ;
l_msg_data VARCHAR2(32627);
l_message  VARCHAR2(32627);
l_api_name                CONSTANT VARCHAR2(50) := 'UPDATE_REFUND_HEADERS';
l_api_name_full	          CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                     || l_api_name;

lp_tapv_tbl         okl_tap_pvt.tapv_tbl_type;
lx_tapv_tbl     	okl_tap_pvt.tapv_tbl_type;
lp_chdv_rec         okl_chd_pvt.chdv_rec_type;
lx_chdv_rec     	okl_chd_pvt.chdv_rec_type;
next_row integer;
lp_crfv_tbl         okl_crf_pvt.crfv_tbl_type;
lx_crfv_tbl     	okl_crf_pvt.crfv_tbl_type;

BEGIN
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_headers : START');
      SAVEPOINT UPDATE_REFUND_HEADERS;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    --set error message,so this will be prefixed before the
    --actual message, so it makes more sense than displaying an
    -- OKL message.
       AddfailMsg(
                  p_object    =>  'RECORD IN OKL_CURE_REFUND_HEADERS ',
                  p_operation =>  'UPDATE' );

      lp_chdv_rec.cure_refund_header_id :=p_pay_cure_refunds_rec.refund_header_id;
      lp_chdv_rec.refund_due_date       :=p_pay_cure_refunds_rec.invoice_date;
      lp_chdv_rec.payment_method        :=p_pay_cure_refunds_rec.payment_method_code;
      lp_chdv_rec.payment_term_id       :=p_pay_cure_refunds_rec.pay_terms;
      lp_chdv_rec.description          :=p_pay_cure_refunds_rec.description;

      OPEN c_getobj(p_pay_cure_refunds_rec.refund_header_id);
      FETCH c_getobj INTO lp_chdv_rec.object_version_number;
      CLOSE c_getobj;


      OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
                           p_api_version     => 1.0
                          ,p_init_msg_list   => 'F'
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_chdv_rec        => lp_chdv_rec
                          ,x_chdv_rec        => lx_chdv_rec);
  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_headers : OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr :'||l_return_status);
 	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
	      Get_Messages (l_msg_count,l_message);
          IF PG_DEBUG < 11  THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
            END IF;
          END IF;
          raise FND_API.G_EXC_ERROR;
     ELSE
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Successfully updated Cure refund '||
                                      'header table');

          END IF;
     END IF;

    IF x_return_status =FND_API.G_RET_STS_SUCCESS THEN
        FND_MSG_PUB.initialize;
    END IF;


  -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  okl_debug_pub.logmessage ('OKL_PAY_CURE_REFUNDS_PVT: update_refund_headers : END');
EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_REFUND_HEADERS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_CURE_REFUNDS_PVT','UPDATE_REFUND_HEADERS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);



END  update_refund_headers;

PROCEDURE create_refund_details
             (  p_api_version           IN NUMBER
               ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status         OUT NOCOPY VARCHAR2
               ,x_msg_count             OUT NOCOPY NUMBER
               ,x_msg_data              OUT NOCOPY VARCHAR2
               )IS
BEGIN

      null;
END  create_refund_details  ;

PROCEDURE update_refund_details
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               )IS
BEGIN

      null;
END  update_refund_details ;

PROCEDURE delete_refund_details
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               ) IS
BEGIN

      null;

END  delete_refund_details;



PROCEDURE gen_doc (document_id IN VARCHAR2
                  ,display_type IN VARCHAR2
                  ,document IN OUT NOCOPY VARCHAR2
                  ,document_type IN OUT NOCOPY VARCHAR2)
IS


   l_cure_refund_header_id NUMBER := TO_NUMBER(document_id);
   l_table_row         VARCHAR2(1000);

   CURSOR c_emps (p_cure_refund_header_id IN NUMBER)
   IS
     select a.contract_number,
            b.offset_amount
     from okl_cure_refunds b, okc_k_headers_b a
     where a.id =b.offset_contract
     and b.cure_refund_header_id =p_cure_refund_header_id;

   c_emps_rec  c_emps%ROWTYPE;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

    IF PG_DEBUG < 11  THEN
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In gen Doc' ||document_id);
       END IF;
    END IF;

   document_type := document_type;
   document      := NULL;

   IF c_emps%ISOPEN THEN
      CLOSE c_emps;
   END IF;

   OPEN c_emps (l_cure_refund_header_id);
   LOOP

   FETCH c_emps INTO c_emps_rec;
   EXIT WHEN c_emps%NOTFOUND;

      l_table_row := '<tr><td>'||c_emps_rec.contract_number||'</td><td>'
       ||c_emps_rec.offset_amount  ||'</td></tr>';

      document := document||l_table_row;

   END LOOP;
   CLOSE c_emps;

   -- Close off the HTML table definition

   document := document||'</table>';

END gen_doc;
end OKL_PAY_CURE_REFUNDS_PVT;

/
