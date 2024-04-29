--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_DISB_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_DISB_TRANS_PVT" AS
/* $Header: OKLRCDTB.pls 120.13 2007/12/11 20:08:56 cklee noship $ */

-- Start of wraper code generated automatically by Debug code generator
  G_MODULE                 VARCHAR2(40) := 'LEASE.DISBURSEMENTS';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_LEVEL_PROCEDURE        NUMBER;
  G_IS_DEBUG_PROCEDURE_ON  BOOLEAN;
  G_IS_DEBUG_STATEMENT_ON  BOOLEAN;

--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
  G_STANDARD                         CONSTANT VARCHAR2(200) := 'STANDARD';
  G_CREDIT                           CONSTANT VARCHAR2(200) := 'CREDIT';
 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |

-- End of wraper code generated automatically by Debug code generator

--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |

----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : populate_more_attrs
-- Description     : Populate additional attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--
----------------------------------------------------------------------------
  FUNCTION populate_more_attrs(
    p_tapv_rec                  IN  tapv_rec_type
    ,x_tapv_rec                 OUT NOCOPY tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--    l_set_of_books_id NUMBER;
    l_terms_id NUMBER;
--    l_application_id NUMBER;
    l_pay_group_lookup_code PO_VENDOR_SITES_ALL.PAY_GROUP_LOOKUP_CODE%TYPE;
    l_vendor_id NUMBER;

  CURSOR c_vendor(p_vendor_site_id NUMBER)
  IS
  --start modified abhsaxen for performance SQLID 20562381
  select vs.vendor_id
  from   ap_supplier_sites vs
  where vs.vendor_site_id = p_vendor_site_id
  ;
  --end modified abhsaxen for performance SQLID 20562381

  CURSOR c_app
  IS
  select a.application_id
  from FND_APPLICATION a
  where APPLICATION_SHORT_NAME = 'OKL'
  ;

/*
  CURSOR c_set_of_books(p_org_id  NUMBER)
  IS
  select to_number(a.set_of_books_id)
  from HR_OPERATING_UNITS a
  where ORGANIZATION_ID = p_org_id
  ;
*/

  CURSOR c_vendor_sites(p_vendor_site_id  NUMBER)
  IS
  select a.TERMS_ID, a.PAY_GROUP_LOOKUP_CODE
  from PO_VENDOR_SITES_ALL a
  where vendor_site_id = p_vendor_site_id
  ;

    -- select apps.FND_DOC_SEQ_885_S.nextval from dual;
/*
    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';--'OKL Lease Receipt Invoices';
    l_okl_application_id number(3) := 540;

    lX_dbseqnm           VARCHAR2(2000):= '';
    lX_dbseqid           NUMBER(38):= NULL;
*/
  BEGIN

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs begin');
    END IF;

    -- assgin to OUT always
    x_tapv_rec := p_tapv_rec;
    IF (p_tapv_rec.payment_method_code is null or
        p_tapv_rec.payment_method_code = OKL_API.G_MISS_CHAR) THEN
      x_tapv_rec.payment_method_code := 'CHECK'; -- set default value
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.payment_method_code:' || x_tapv_rec.payment_method_code);
    END IF;

/*
-- 1. SET_OF_BOOKS_ID
    OPEN c_set_of_books(p_tapv_rec.org_id);
    FETCH c_set_of_books INTO l_set_of_books_id;
    CLOSE c_set_of_books;
*/

    IF (p_tapv_rec.SET_OF_BOOKS_ID is null or
        p_tapv_rec.SET_OF_BOOKS_ID = OKL_API.G_MISS_NUM) THEN
      x_tapv_rec.SET_OF_BOOKS_ID := OKL_ACCOUNTING_UTIL.get_set_of_books_id;--l_set_of_books_id;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.SET_OF_BOOKS_ID:' || x_tapv_rec.SET_OF_BOOKS_ID);
    END IF;
-- 2. IPPT_ID
  -- cklee 05/04/2004
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: p_tapv_rec.IPPT_ID:' || p_tapv_rec.IPPT_ID);
    END IF;
    IF (p_tapv_rec.IPPT_ID IS NULL or
        p_tapv_rec.IPPT_ID = OKL_API.G_MISS_NUM) THEN

      OPEN c_vendor_sites(p_tapv_rec.ipvs_id);
      FETCH c_vendor_sites INTO l_terms_id, l_pay_group_lookup_code;
      CLOSE c_vendor_sites;

      x_tapv_rec.IPPT_ID := l_terms_id;

    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.IPPT_ID:' || x_tapv_rec.IPPT_ID);
    END IF;

-- 3. INVOICE_NUMBER
/*
    OPEN c_app;
    FETCH c_app INTO l_application_id;
    CLOSE c_app;

    l_okl_application_id := nvl(l_application_id,540);
--
-- display specific application error if 'OKL Lease Pay Invoices' has not been setup or setup incorrectly
--
    BEGIN
      x_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
                         (appid      =>  l_okl_application_id,
                         cat_code    =>  l_document_category,
                         sobid       =>  OKL_ACCOUNTING_UTIL.get_set_of_books_id,--l_set_of_books_id,
                         met_code    =>  'A',
                         trx_date    =>  SYSDATE,
                         dbseqnm     =>  lx_dbseqnm,
                         dbseqid     =>  lx_dbseqid);
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = 100 THEN
          OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKL_PAY_INV_SEQ_CHECK');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END;

-- cklee set vendor_invoice_numner if it's NULL
    IF (p_tapv_rec.vendor_invoice_number IS NULL ) THEN
      x_tapv_rec.vendor_invoice_number := p_tapv_rec.invoice_number;
    END IF;
*/
-- 4. NETTABLE_YN
    IF (p_tapv_rec.NETTABLE_YN is null or
        p_tapv_rec.NETTABLE_YN = OKL_API.G_MISS_CHAR) THEN
      x_tapv_rec.NETTABLE_YN := 'N';
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.NETTABLE_YN:' || x_tapv_rec.NETTABLE_YN);
    END IF;

-- 5. PAY_GROUP_LOOKUP_CODE
  -- cklee 05/04/2004
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: p_tapv_rec.PAY_GROUP_LOOKUP_CODE:' || p_tapv_rec.PAY_GROUP_LOOKUP_CODE);
    END IF;

    IF (p_tapv_rec.PAY_GROUP_LOOKUP_CODE IS NULL or
        p_tapv_rec.PAY_GROUP_LOOKUP_CODE = OKL_API.G_MISS_CHAR) THEN

-- fixed PAY_GROUP_LOOKUP_CODE default data missing issues
      OPEN c_vendor_sites(p_tapv_rec.ipvs_id);
      FETCH c_vendor_sites INTO l_terms_id, l_pay_group_lookup_code;
      CLOSE c_vendor_sites;

      x_tapv_rec.PAY_GROUP_LOOKUP_CODE := l_pay_group_lookup_code;

    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.PAY_GROUP_LOOKUP_CODE:' || x_tapv_rec.PAY_GROUP_LOOKUP_CODE);
    END IF;

-- 6. vednor id
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: p_tapv_rec.VENDOR_ID:' || p_tapv_rec.VENDOR_ID);
    END IF;
    IF (p_tapv_rec.VENDOR_ID is null or
        p_tapv_rec.VENDOR_ID = OKL_API.G_MISS_NUM) THEN

      OPEN c_vendor(p_tapv_rec.ipvs_id);
      FETCH c_vendor INTO l_vendor_id;
      CLOSE c_vendor;

      x_tapv_rec.VENDOR_ID := l_vendor_id;

    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.VENDOR_ID:' || x_tapv_rec.VENDOR_ID);
    END IF;

-- 7. invoice_type
-- cklee 05/04/2004

    IF (p_tapv_rec.INVOICE_TYPE is null or
       p_tapv_rec.INVOICE_TYPE = OKL_API.G_MISS_CHAR) THEN

      x_tapv_rec.INVOICE_TYPE := G_STANDARD;

    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.INVOICE_TYPE:' || x_tapv_rec.INVOICE_TYPE);
    END IF;

    -- 8. If invoice type is G_STANDARD then invoice amount is positive
    --    If invoice type is G_CREDIT then the invoice amount is negative.
    --    sjalasut, made changes to incorporate the business rule as part
    --    of OKLR12B Disbursements Project
    IF((x_tapv_rec.INVOICE_TYPE = G_STANDARD AND x_tapv_rec.AMOUNT < 0)
       OR(x_tapv_rec.INVOICE_TYPE = G_CREDIT AND x_tapv_rec.AMOUNT > 0))THEN
      x_tapv_rec.AMOUNT := ((x_tapv_rec.AMOUNT) * (-1));
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.AMOUNT:' || x_tapv_rec.AMOUNT);
    END IF;

--START:|             11-Dec-07    cklee   -- Fixed bug: 6682348 -- stamped request_id when insert      |
    x_tapv_rec.REQUEST_ID := Fnd_Global.CONC_REQUEST_ID;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs: x_tapv_rec.REQUEST_ID:' || x_tapv_rec.REQUEST_ID);
    END IF;
--END:|             11-Dec-07    cklee   -- Fixed bug: 6682348 -- stamped request_id when insert      |



    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.populate_more_attrs end');
    END IF;

    RETURN l_return_status;
  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      l_return_status := OKL_API.G_RET_STS_ERROR;


      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_disb_trx
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--
----------------------------------------------------------------------------
  PROCEDURE create_disb_trx(p_api_version	IN  NUMBER
                       	    ,p_init_msg_list	IN  VARCHAR2	DEFAULT OKL_API.G_FALSE
  	                    ,x_return_status	OUT NOCOPY VARCHAR2
  	                    ,x_msg_count        OUT NOCOPY NUMBER
  	                    ,x_msg_data	        OUT NOCOPY VARCHAR2
                            ,p_tapv_rec         IN tapv_rec_type
                            ,p_tplv_tbl         IN tplv_tbl_type
                            ,x_tapv_rec         OUT NOCOPY tapv_rec_type
                            ,x_tplv_tbl         OUT NOCOPY tplv_tbl_type)
 IS

 -----------------------------------------------------------------
    -- Declare Process Variable
 --------------------------------------------------------------------
    l_api_name	    CONSTANT VARCHAR2(30)   := 'CREATE_DISB_TRX';
    l_okl_application_id NUMBER(3) := FND_GLOBAL.PROG_APPL_ID;
    l_application_id NUMBER(3);
    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
    lX_dbseqnm          VARCHAR2(2000):= '';
    lX_dbseqid          NUMBER(38):= NULL;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    cnt                 NUMBER;
    l_total_amount      NUMBER;
    l_khr_id            NUMBER;
    l_legal_entity_id   NUMBER;
    l_currency_code            okc_k_headers_b.currency_code%type;
    l_currency_conversion_type okl_k_headers.currency_conversion_type%type;
    l_currency_conversion_rate okl_k_headers.currency_conversion_rate%type;
    l_currency_conversion_date okl_k_headers.currency_conversion_date%type;



 ---------------------------------------------------------------
    -- Declare records: Payable Invoice Headers, Lines and Distributions
 ----------------------------------------------------------------
    l_tapv_rec              tapv_rec_type;
    lx_tapv_rec             tapv_rec_type;
    l_tplv_tbl              tplv_tbl_type;
    lx_tplv_tbl             tplv_tbl_type;
--start:|             17-May-07    cklee   -- Accounting API CR                                         |
    l_tmpl_identify_tbl     Okl_Account_Dist_Pvt.TMPL_IDENTIFY_TBL_TYPE;
    l_dist_info_tbl         Okl_Account_Dist_Pvt.dist_info_TBL_TYPE;
    l_pdt_id               Okl_k_headers.pdt_id%type;
--    l_tmpl_identify_rec     Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
--    l_dist_info_rec         Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
    l_ctxt_val_tbl          Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_primary_key_tbl  Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
--    l_ctxt_val_tbl          okl_execute_formula_pvt.ctxt_val_tbl_type;
--    l_acc_gen_primary_key_tbl  Okl_Account_Generator_Pvt.primary_key_tbl;
--    l_template_tbl             Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
--    l_amount_tbl               Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;
    l_template_tbl             Okl_Account_Dist_Pvt.AVLV_OUT_TBL_TYPE;
    l_amount_tbl               Okl_Account_Dist_Pvt.AMOUNT_OUT_TBL_TYPE;
    l_fact_synd_code           fnd_lookups.lookup_code%TYPE;
    l_inv_acct_code            okc_rules_b.RULE_INFORMATION1%TYPE;
--end:|             17-May-07    cklee   -- Accounting API CR                                         |

    CURSOR pdt_id_csr (p_khr_id  IN NUMBER) IS
    SELECT  khr.pdt_id
    FROM    okl_k_headers khr
    WHERE   khr.id =  p_khr_id;

    --Get currency conversion attributes for a contract
    CURSOR l_curr_conv_csr(p_khr_id IN NUMBER) IS
    SELECT khr.currency_code
           ,chr.currency_conversion_type
           ,chr.currency_conversion_rate
           ,chr.currency_conversion_date
           ,chr.legal_entity_id
    FROM   okc_k_headers_b khr,
            okl_k_headers chr
    WHERE khr.id = chr.id
    AND     khr.id = p_khr_id;

  CURSOR c_app
    IS
  select a.application_id
  from FND_APPLICATION a
  where APPLICATION_SHORT_NAME = 'OKL'
  ;

 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT); -- cklee 01-oct-2007
   END IF;

   IF (G_IS_DEBUG_PROCEDURE_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE,'Begin Debug OKLRCDTB.pls  ');
   END IF;

    --Print Input Variables
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Header Parameters');
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
--      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract Id  :'||p_tapv_rec.khr_id);
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Trx Status Code  :'||p_tapv_rec.trx_status_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Vendor Id  :'||p_tapv_rec.vendor_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Currency Code  :'||p_tapv_rec.currency_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Payment Method Code  :'||p_tapv_rec.payment_method_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Pay Group Lookup Code  :'||p_tapv_rec.pay_group_lookup_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoice Type  :'||p_tapv_rec.invoice_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Set Of Books Id  :'||p_tapv_rec.set_of_books_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Try Id  :'||p_tapv_rec.try_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Ipvs Id  :'||p_tapv_rec.ipvs_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Ippt Id  :'||p_tapv_rec.ippt_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Date Entered  :'||p_tapv_rec.date_entered);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Date Invoiced  :'||p_tapv_rec.date_invoiced);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount  :'||p_tapv_rec.amount);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Org Id  :'||p_tapv_rec.org_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Legal Entity Id  :'||p_tapv_rec.legal_entity_id);

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Line Parameters');
      IF p_tplv_tbl.COUNT > 0 THEN
        cnt := p_tplv_tbl.FIRST;
      LOOP
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract Id  :'||p_tplv_tbl(cnt).khr_id);
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inv Distr Line Code :'||cnt||' -'||p_tplv_tbl(cnt).inv_distr_line_code);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disbursement Basis Code :'||cnt||' -'||p_tplv_tbl(cnt).disbursement_basis_code);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Line Number :'||cnt||' -'||p_tplv_tbl(cnt).line_number);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Object Version Number :'||cnt||' -'||p_tplv_tbl(cnt).object_version_number);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount :'||cnt||' -'||p_tplv_tbl(cnt).amount);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Sty Id :'||cnt||' -'||p_tplv_tbl(cnt).sty_id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Org Id :'||cnt||' -'||p_tplv_tbl(cnt).org_id);

        EXIT WHEN cnt = p_tplv_tbl.LAST;
        cnt := p_tplv_tbl.NEXT(cnt);
      END LOOP;
    END IF;
  END IF;

   l_return_status := okl_api.start_activity(
                                       	p_api_name	=> l_api_name,
    	                                p_init_msg_list	=> p_init_msg_list,
    	                                p_api_type	=> '_PVT',
    	                                x_return_status	=> l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    		  RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   ------------------------------------------------------------
   -- Initialization of Parameters
   ------------------------------------------------------------
   l_tapv_rec := p_tapv_rec;
   l_tplv_tbl := p_tplv_tbl;

   ------------------------------------------------------------

--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
   -- populates more attributes
   l_return_status := populate_more_attrs(p_tapv_rec, l_tapv_rec);
   --- Store the highest degree of error
   IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
     IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       x_return_status := l_return_status;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: populate_more_attrs raise exception');
     END IF;
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   END IF;
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |

  -- Generating Invoice Number from Document Sequence if no invoice number is passed from source transaction
  BEGIN

    OPEN c_app;
    FETCH c_app INTO l_application_id;
    CLOSE c_app;

    l_okl_application_id := nvl(l_application_id,540);

    IF (NVL(l_tapv_rec.invoice_number,okl_api.g_miss_char) = okl_api.g_miss_char) THEN
       l_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
                (appid      =>  l_okl_application_id,
                cat_code    =>  l_document_category,
                sobid       =>  l_tapv_rec.set_of_books_id, -- |             28-Sep-07    cklee   -- Fixed bug:6457524 set_of_book_id is missing issue         |
                met_code    =>  'A',
                trx_date    =>  SYSDATE,
                dbseqnm     =>  lx_dbseqnm,
                dbseqid     =>  lx_dbseqid);
       IF (NVL(l_tapv_rec.vendor_invoice_number,okl_api.g_miss_char) = okl_api.g_miss_char) THEN
             l_tapv_rec.vendor_invoice_number := l_tapv_rec.invoice_number;
       END IF;
    ELSE
      IF (NVL(l_tapv_rec.vendor_invoice_number,okl_api.g_miss_char) = okl_api.g_miss_char) THEN
         l_tapv_rec.vendor_invoice_number := fnd_seqnum.get_next_sequence
                (appid      =>  l_okl_application_id,
                cat_code    =>  l_document_category,
                sobid       =>  l_tapv_rec.set_of_books_id,
                met_code    =>  'A',
                trx_date    =>  SYSDATE,
                dbseqnm     =>  lx_dbseqnm,
                dbseqid     =>  lx_dbseqid);
      END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN

    OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_PAY_INV_SEQ_CHECK');
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: fnd_seqnum.get_next_sequence raise exception');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: fnd_seqnum.get_next_sequence: l_okl_application_id' || l_okl_application_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: fnd_seqnum.get_next_sequence: l_document_category' || l_document_category);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: fnd_seqnum.get_next_sequence: l_tapv_rec.set_of_books_id' || l_tapv_rec.set_of_books_id);
    END IF;
    RAISE OKL_API.G_EXCEPTION_ERROR ;

  END;

--|             06-Dec-07    cklee   -- Fixed bug: 6663203                                        |
--|                                      raise proper error message if request amount = 0         |
  --Raise message if amount  = 0
  IF l_tapv_rec.amount = 0 THEN
     OKL_API.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => 'OKL_AMT_CANNOT_BE_ZERO'
                ) ;
     RAISE OKL_API.G_EXCEPTION_ERROR ;
  END IF;

  --Raise message if Currency code is not passed
  IF l_tapv_rec.currency_code IS NULL THEN
     OKL_API.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'currency_code'
                ) ;
     RAISE OKL_API.G_EXCEPTION_ERROR ;
  END IF;

  --get contract currency parameters
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
--  l_khr_id := l_tapv_rec.khr_id;
  cnt := l_tplv_tbl.FIRST;
  l_khr_id := l_tplv_tbl(cnt).khr_id;
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_khr_id' || l_khr_id);
  END IF;

  FOR cur IN l_curr_conv_csr(l_khr_id) LOOP
    l_currency_code := cur.currency_code;
    l_currency_conversion_type := cur.currency_conversion_type;
    l_currency_conversion_rate := cur.currency_conversion_rate;
    l_currency_conversion_date := cur.currency_conversion_date;
    l_legal_entity_id          := cur.legal_entity_id;
  END LOOP;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_currency_code' || l_currency_code);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_currency_type' || l_currency_conversion_type);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_currency_rate' || l_currency_conversion_rate);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_currency_date' || l_currency_conversion_date);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_legal_entity_id' || l_legal_entity_id);
  END IF;


--start:|             14-Sep-07    cklee   -- Restored khr_id back to okl_trx_ap_invs_all_b for the     |
  IF (NVL(l_tapv_rec.khr_id,okl_api.g_miss_num) = okl_api.g_miss_num) then -- 28-Sep-07    cklee   -- Fixed bug:6455033
    l_tapv_rec.khr_id := l_khr_id;
  END IF;
--end:|             14-Sep-07    cklee   -- Restored khr_id back to okl_trx_ap_invs_all_b for the     |

--Transaction Status defaulted to Entered
  IF (NVL(l_tapv_rec.trx_status_code,okl_api.g_miss_char) = okl_api.g_miss_char) then
    l_tapv_rec.trx_status_code := 'ENTERED';
  END IF;

  --Check for currency conversion type
  IF (NVL(l_tapv_rec.currency_conversion_type, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
    l_tapv_rec.currency_conversion_type := l_currency_conversion_type;
  END IF;

 --Check for currency conversion date
  IF (NVL(l_tapv_rec.currency_conversion_date, okl_api.g_miss_date) = okl_api.g_miss_date) THEN
    l_tapv_rec.currency_conversion_date := l_currency_conversion_date;
  END IF;

 --Handle Currency Conversion Rate
  IF l_tapv_rec.currency_conversion_type = 'User' THEN
    IF (l_tapv_rec.currency_code = okl_accounting_util.get_func_curr_code) THEN
      l_tapv_rec.currency_conversion_rate := 1;
    ELSE
      IF NVL(l_tapv_rec.currency_conversion_rate,okl_api.g_miss_num) = okl_api.g_miss_num THEN
        l_tapv_rec.currency_conversion_rate := l_currency_conversion_rate;
      END IF;
    END IF;
  END IF;

  --Raise message if Payment Method Code is not passed
   IF (NVL(l_tapv_rec.payment_method_code,okl_api.g_miss_char) = okl_api.g_miss_char) THEN
      --raise message
      OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'payment_method_code'
                ) ;
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  --Raise message if Pay Group Lookup Code is not passed
   IF (NVL(l_tapv_rec.pay_group_lookup_code,okl_api.g_miss_char) = okl_api.g_miss_char) THEN
     --raise message
      OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'pay_group_lookup_code'
                ) ;
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  --Raise message if Invoice Type is not passed
  IF (NVL(l_tapv_rec.invoice_type,okl_api.g_miss_char) = okl_api.g_miss_char) THEN
    --raise message
    OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'invoice_type'
                ) ;
      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

 --Negate the positive amount passed if invoice type is CREDIT
  IF l_tapv_rec.invoice_type = 'CREDIT' THEN
    IF SIGN(l_tapv_rec.amount) = 1 THEN
      l_tapv_rec.amount := -(l_tapv_rec.amount);
    END IF;
  END IF;

  -- Raise message if Set of Books Id is not passed
  IF NVL(l_tapv_rec.set_of_books_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --raise message
    OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'set_of_books_id'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;


  --Raise message if try id is not passed
  IF NVL(l_tapv_rec.try_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --raise message
     OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'try_id'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

 --Raise message if vendor site id is not passed
  IF NVL(l_tapv_rec.ipvs_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --raise message
     OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'ipvs_id'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --Raise message id payment terms id is not passed
  IF NVL(l_tapv_rec.ippt_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --raise message
     OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'ippt_id'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


  --Raise message if date entered is not passed
  IF NVL(l_tapv_rec.date_entered,okl_api.g_miss_date) = okl_api.g_miss_date THEN
    --raise message
     OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'date_entered'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --Raise message if date invoiced is not passed
  IF NVL(l_tapv_rec.date_invoiced,okl_api.g_miss_date) = okl_api.g_miss_date THEN
    --raise message
     OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'date_invoiced'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --Raise message if amount is not passed
  IF NVL(l_tapv_rec.amount,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --raise message
     OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'amount'
                ) ;
      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: before OKL_ACCOUNTING_UTIL.round_amount');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_tapv_rec.amount' || l_tapv_rec.amount);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_tapv_rec.currency_code' || l_tapv_rec.currency_code);
  END IF;
  --Rounding the amount
  l_tapv_rec.amount := OKL_ACCOUNTING_UTIL.round_amount(l_tapv_rec.amount, l_tapv_rec.currency_code);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: after OKL_ACCOUNTING_UTIL.round_amount');
  END IF;
--start: 5/18/2007 cklee added rounding logc for line's amount
  cnt := l_tplv_tbl.FIRST;
  LOOP
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: before OKL_ACCOUNTING_UTIL.round_amount');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_tplv_tbl(cnt)' || cnt);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_tplv_tbl(cnt).amount' || l_tplv_tbl(cnt).amount);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: l_tapv_rec.currency_code' || l_tapv_rec.currency_code);
    END IF;
    --Rounding the amount
    l_tplv_tbl(cnt).amount := OKL_ACCOUNTING_UTIL.round_amount(l_tplv_tbl(cnt).amount, l_tapv_rec.currency_code);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CREATE_DISB_TRANS_PVT.create_disb_trx: after OKL_ACCOUNTING_UTIL.round_amount');
    END IF;
    EXIT WHEN cnt = l_tplv_tbl.LAST;
    cnt := l_tplv_tbl.NEXT(cnt);
  END LOOP;
--end: 5/18/2007 cklee added rounding logc for line's amount

  -- Default gl date to date invoiced
  IF NVL(l_tapv_rec.date_gl,okl_api.g_miss_date) = okl_api.g_miss_date THEN
    l_tapv_rec.date_gl := l_tapv_rec.date_invoiced;
  END IF;

  --Raise message id org id is not passed
  IF NVL(l_tapv_rec.org_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --Raise message
    OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'org_id'
                ) ;
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

-- Default legal entity id from the contract legal entity
  IF NVL(l_tapv_rec.legal_entity_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
    --derive the legal entity id from the contract
    l_tapv_rec.legal_entity_id := l_legal_entity_id;
  END IF;


  --Create the header
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before create transaction invoice header');
   END IF;

   OKL_TRX_AP_INVOICES_PUB.Insert_trx_ap_invoices(p_api_version      =>  p_api_version
                                                 ,p_init_msg_list    =>   p_init_msg_list
                                                 ,x_return_status    =>   x_return_status
                                                 ,x_msg_count        =>   x_msg_count
                                                 ,x_msg_data         =>   x_msg_data
                                                 ,p_tapv_rec         =>   l_tapv_rec
                                                 ,x_tapv_rec         =>   lx_tapv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after create invoice header,invoice header id : ' || lx_tapv_rec.id);
      END IF;

     ------------------------------------------------------------
      -- Insert Invoice Line
      ------------------------------------------------------------

    l_total_amount := 0;
      cnt := l_tplv_tbl.FIRST;
      LOOP
        IF NVL(l_tplv_tbl(cnt).inv_distr_line_code,okl_api.g_miss_char) = okl_api.g_miss_char THEN
          l_tplv_tbl(cnt).inv_distr_line_code := 'ITEM';
        END IF;
        IF NVL(l_tplv_tbl(cnt).sty_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
      --Raise message
          OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'line'||cnt||' sty_id'
                ) ;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF NVL(l_tplv_tbl(cnt).line_number,okl_api.g_miss_num) = okl_api.g_miss_num THEN
          --Raise message
          OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'line'||cnt||' line_number'
                ) ;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF NVL(l_tplv_tbl(cnt).amount,okl_api.g_miss_num) = okl_api.g_miss_num THEN
         --Raise message
           OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'line'||cnt||' amount'
                ) ;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          IF l_tapv_rec.invoice_type = 'CREDIT' THEN
            IF SIGN(l_tplv_tbl(cnt).amount) = 1 THEN
               l_tplv_tbl(cnt).amount := -(l_tplv_tbl(cnt).amount);
            END IF;
          END IF;
        END IF;
        IF NVL(l_tplv_tbl(cnt).org_id,okl_api.g_miss_num) = okl_api.g_miss_num THEN
        --Raise message
          OKL_Api.SET_MESSAGE
                ( p_app_name     => g_app_name,
                  p_msg_name     => g_required_value,
                  p_token1       => g_col_name_token,
                  p_token1_value => 'line'||cnt||' org_id'
                ) ;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
--START:|             11-Dec-07    cklee   -- Fixed bug: 6682348 -- stamped request_id when insert      |
        l_tplv_tbl(cnt).REQUEST_ID := Fnd_Global.CONC_REQUEST_ID;
--END:|             11-Dec-07    cklee   -- Fixed bug: 6682348 -- stamped request_id when insert      |

        l_total_amount := l_total_amount + l_tplv_tbl(cnt).amount;
        l_tplv_tbl(cnt).tap_id := lx_tapv_rec.id;

        EXIT WHEN cnt = l_tplv_tbl.LAST;
        cnt := l_tplv_tbl.NEXT(cnt);
       END LOOP;

  --Error: Sign of total amount on lines do not match the sign of amount on the header transaction
   IF SIGN(l_total_amount) <> SIGN(l_tapv_rec.amount) THEN
     OKL_API.set_message( p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_BPD_SIGN_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF l_total_amount <> l_tapv_rec.amount THEN
     OKL_API.set_message( p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_BPD_AMOUNT_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before create transaction invoice line');
   END IF;

   OKL_TXL_AP_INV_LNS_PUB.insert_txl_ap_inv_lns(
            p_api_version       =>   p_api_version
            ,p_init_msg_list    =>  p_init_msg_list
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tplv_tbl         =>   l_tplv_tbl
            ,x_tplv_tbl         =>   lx_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKl_API.G_EXCEPTION_ERROR;
    END IF;

    cnt := lx_tplv_tbl.FIRST;
     LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after create ap invoice line, ap invoice line id : ' || lx_tplv_tbl(cnt).id);
      END IF;
      EXIT WHEN cnt = lx_tplv_tbl.LAST;
      cnt := lx_tplv_tbl.NEXT(cnt);
    END LOOP;

--start:|             17-May-07    cklee   -- Accounting API CR                                         |
/*
    --Create Distributions
    --------------------Accounting Engine Calls---------------------------

    l_tmpl_identify_rec.product_id := NULL;

    -- Get Product Id
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
--    OPEN  pdt_id_csr ( p_tapv_rec.khr_id );
    OPEN  pdt_id_csr ( l_khr_id );
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
	FETCH pdt_id_csr INTO l_tmpl_identify_rec.product_id;
	CLOSE pdt_id_csr;

     cnt := lx_tplv_tbl.FIRST;
     LOOP
	l_tmpl_identify_rec.transaction_type_id    := P_tapv_rec.try_id;
	l_tmpl_identify_rec.stream_type_id         := lx_tplv_tbl(cnt).sty_id;

	l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
	l_tmpl_identify_rec.FACTORING_SYND_FLAG    := NULL;
	l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
	--l_tmpl_identify_rec.FACTORING_CODE         := NULL;
	l_tmpl_identify_rec.MEMO_YN                := 'N';
	l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';

       Okl_Securitization_Pvt.check_khr_ia_associated(p_api_version => p_api_version
                                                ,p_init_msg_list => p_init_msg_list
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => x_msg_count
                                                ,x_msg_data => x_msg_data
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
--                                                ,p_khr_id =>  p_tapv_rec.khr_id
                                                ,p_khr_id =>  l_khr_id
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
                                                ,p_scs_code => NULL
                                                ,p_trx_date => p_tapv_rec.date_invoiced
                                                ,x_fact_synd_code => l_tmpl_identify_rec.FACTORING_SYND_FLAG
                                                ,x_inv_acct_code => l_tmpl_identify_rec.INVESTOR_CODE);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Securitization_pvt.check_khr_ia_associated called successfully'|| x_return_status);
       END IF;

        l_dist_info_rec.source_id		    	   := lx_tplv_tbl(cnt).id;
	l_dist_info_rec.source_table			   := 'OKL_TXL_AP_INV_LNS_B';
	l_dist_info_rec.accounting_date			   := l_tapv_rec.date_invoiced;
	l_dist_info_rec.gl_reversal_flag		   :='N';
	l_dist_info_rec.post_to_gl			   :='N';
	l_dist_info_rec.amount				   := ABS(lx_tplv_tbl(cnt).amount);
	l_dist_info_rec.currency_code			   := l_tapv_rec.currency_code;
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
--	l_dist_info_rec.contract_id			   := l_tapv_rec.khr_id;
	l_dist_info_rec.contract_id			   := l_khr_id;
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
	l_dist_info_rec.contract_line_id        	   := lx_tplv_tbl(cnt).kle_id;


    --Check for currency code
    l_dist_info_rec.currency_code := l_tapv_rec.currency_code;

    IF (NVL(l_dist_info_rec.currency_code, okl_api.g_miss_char) = okl_api.g_miss_char) IS NULL THEN
      l_dist_info_rec.currency_code := l_currency_code;
    END IF;

    --Check for currency conversion type
    l_dist_info_rec.currency_conversion_type := l_tapv_rec.currency_conversion_type;

    IF (NVL(l_dist_info_rec.currency_conversion_type, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
      l_dist_info_rec.currency_conversion_type := l_currency_conversion_type;
    END IF;

    --Check for currency conversion date
    l_dist_info_rec.currency_conversion_date := l_tapv_rec.currency_conversion_date;

    IF (NVL(l_dist_info_rec.currency_conversion_date, okl_api.g_miss_date) =  okl_api.g_miss_date) THEN
      l_dist_info_rec.currency_conversion_date := l_currency_conversion_date;
    END IF;


    IF (l_dist_info_rec.currency_conversion_type = 'User') THEN
      IF (l_dist_info_rec.currency_code = okl_accounting_util.get_func_curr_code) THEN
        l_dist_info_rec.currency_conversion_rate := 1;
      ELSE
        IF (NVL(l_tapv_rec.currency_conversion_rate, okl_api.g_miss_num) = okl_api.g_miss_num) THEN
          l_dist_info_rec.currency_conversion_rate := l_currency_conversion_rate;
        ELSE
          l_dist_info_rec.currency_conversion_rate := l_tapv_rec.currency_conversion_rate;
        END IF;
      END IF;
    ELSIF (l_dist_info_rec.currency_conversion_type = 'Spot' OR l_dist_info_rec.currency_conversion_type = 'Corporate') THEN
      l_dist_info_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                                (p_from_curr_code => l_dist_info_rec.currency_code,
	                                         p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                                         p_con_date => l_dist_info_rec.currency_conversion_date,
	                                         p_con_type => l_dist_info_rec.currency_conversion_type);
    END IF;

    l_dist_info_rec.currency_conversion_rate := NVL(l_dist_info_rec.currency_conversion_rate, 1);

  -- Call to populate account generator API

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Call to Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen ');
    END IF;

    Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
--start:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
--	p_contract_id	     => p_tapv_rec.khr_id,
	p_contract_id	     => l_khr_id,
--end:|             11-May-07    cklee   -- added defaulted attributes for the following:             |
	p_contract_line_id	 => lx_tplv_tbl(cnt).kle_id,
	x_acc_gen_tbl		 => l_acc_gen_primary_key_tbl,
	x_return_status		 => x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End call to Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen');
    END IF;


   -- Call to Distributons API

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Call to Okl_Account_Dist_Pub.Create_Accounting_Dist');
    END IF;
    Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
				   p_api_version             => p_api_version
                                  ,p_init_msg_list           => p_init_msg_list
                                  ,x_return_status  	     => x_return_status
                                  ,x_msg_count      	     => x_msg_count
                                  ,x_msg_data       	     => x_msg_data
                                  ,p_tmpl_identify_rec 	     => l_tmpl_identify_rec
                                  ,p_dist_info_rec           => l_dist_info_rec
                                  ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                  ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                  ,x_template_tbl            => l_template_tbl
                                  ,x_amount_tbl              => l_amount_tbl);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End Call to Okl_Account_Dist_Pub.Create_Accounting_Dist ');
     END IF;


     EXIT WHEN cnt = lx_tplv_tbl.LAST;
     cnt := lx_tplv_tbl.NEXT(cnt);
    END LOOP;
*/
--end:|             17-May-07    cklee   -- Accounting API CR                                         |
------------------End Accounting Engine Calls -----------------------
    x_tapv_rec := lx_tapv_rec;
    x_tplv_tbl := lx_tplv_tbl;

------------------------------------------------------------------------------
-- START: Move accounting call after creating the OKL AP internal invoice lines
------------------------------------------------------------------------------
--start:|             17-May-07    cklee   -- Accounting API CR                                         |
    --Create Distributions
    --------------------Accounting Engine Calls---------------------------
    l_pdt_id := NULL;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before pdt_id_csr');
    END IF;
    -- Get Product Id
    OPEN  pdt_id_csr ( l_khr_id );
	FETCH pdt_id_csr INTO l_pdt_id;
	CLOSE pdt_id_csr;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after pdt_id_csr');
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before pOkl_Securitization_Pvt.check_khr_ia_associated');
    END IF;
    -- We need to call once per khr_id
    Okl_Securitization_Pvt.check_khr_ia_associated(p_api_version => p_api_version
                                                ,p_init_msg_list => p_init_msg_list
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => x_msg_count
                                                ,x_msg_data => x_msg_data
                                                ,p_khr_id =>  l_khr_id
                                                ,p_scs_code => NULL
                                                ,p_trx_date => p_tapv_rec.date_invoiced
                                                ,x_fact_synd_code => l_fact_synd_code
                                                ,x_inv_acct_code => l_inv_acct_code);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Okl_Securitization_pvt.check_khr_ia_associated called successfully'|| x_return_status);
    END IF;

    cnt := lx_tplv_tbl.FIRST;
    LOOP
  	  l_tmpl_identify_tbl(cnt).transaction_type_id    := P_tapv_rec.try_id;
      l_tmpl_identify_tbl(cnt).stream_type_id         := lx_tplv_tbl(cnt).sty_id;
  	  l_tmpl_identify_tbl(cnt).product_id             := l_pdt_id;

      l_tmpl_identify_tbl(cnt).ADVANCE_ARREARS        := NULL;
      l_tmpl_identify_tbl(cnt).FACTORING_SYND_FLAG    := l_fact_synd_code;
      l_tmpl_identify_tbl(cnt).INVESTOR_CODE          := l_inv_acct_code;
      l_tmpl_identify_tbl(cnt).SYNDICATION_CODE       := NULL;
      --l_tmpl_identify_tbl(cnt).FACTORING_CODE         := NULL;
      l_tmpl_identify_tbl(cnt).MEMO_YN                := 'N';
      l_tmpl_identify_tbl(cnt).PRIOR_YEAR_YN          := 'N';

      l_dist_info_tbl(cnt).source_id	    	   := lx_tplv_tbl(cnt).id;
      l_dist_info_tbl(cnt).source_table			   := 'OKL_TXL_AP_INV_LNS_B';
      l_dist_info_tbl(cnt).accounting_date		   := l_tapv_rec.date_invoiced;
      l_dist_info_tbl(cnt).gl_reversal_flag		   :='N';
      l_dist_info_tbl(cnt).post_to_gl			   :='N';
--      l_dist_info_tbl(cnt).amount				   := ABS(lx_tplv_tbl(cnt).amount);
      l_dist_info_tbl(cnt).amount				   := lx_tplv_tbl(cnt).amount;
      l_dist_info_tbl(cnt).currency_code		   := l_tapv_rec.currency_code;
      l_dist_info_tbl(cnt).contract_id			   := l_khr_id;
      l_dist_info_tbl(cnt).contract_line_id    	   := lx_tplv_tbl(cnt).kle_id;


      --Check for currency code
      l_dist_info_tbl(cnt).currency_code := l_tapv_rec.currency_code;

      IF (NVL(l_dist_info_tbl(cnt).currency_code, okl_api.g_miss_char) = okl_api.g_miss_char) IS NULL THEN
        l_dist_info_tbl(cnt).currency_code := l_currency_code;
      END IF;

      --Check for currency conversion type
      l_dist_info_tbl(cnt).currency_conversion_type := l_tapv_rec.currency_conversion_type;

      IF (NVL(l_dist_info_tbl(cnt).currency_conversion_type, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
        l_dist_info_tbl(cnt).currency_conversion_type := l_currency_conversion_type;
      END IF;

      --Check for currency conversion date
      l_dist_info_tbl(cnt).currency_conversion_date := l_tapv_rec.currency_conversion_date;

      IF (NVL(l_dist_info_tbl(cnt).currency_conversion_date, okl_api.g_miss_date) =  okl_api.g_miss_date) THEN
        l_dist_info_tbl(cnt).currency_conversion_date := l_currency_conversion_date;
      END IF;

      IF (l_dist_info_tbl(cnt).currency_conversion_type = 'User') THEN
        IF (l_dist_info_tbl(cnt).currency_code = okl_accounting_util.get_func_curr_code) THEN
          l_dist_info_tbl(cnt).currency_conversion_rate := 1;
        ELSE
          IF (NVL(l_tapv_rec.currency_conversion_rate, okl_api.g_miss_num) = okl_api.g_miss_num) THEN
            l_dist_info_tbl(cnt).currency_conversion_rate := l_currency_conversion_rate;
          ELSE
            l_dist_info_tbl(cnt).currency_conversion_rate := l_tapv_rec.currency_conversion_rate;
          END IF;
        END IF;
      ELSIF (l_dist_info_tbl(cnt).currency_conversion_type = 'Spot' OR l_dist_info_tbl(cnt).currency_conversion_type = 'Corporate') THEN
        l_dist_info_tbl(cnt).currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                                (p_from_curr_code => l_dist_info_tbl(cnt).currency_code,
	                                             p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                                             p_con_date => l_dist_info_tbl(cnt).currency_conversion_date,
    	                                         p_con_type => l_dist_info_tbl(cnt).currency_conversion_type);
      END IF;

      l_dist_info_tbl(cnt).currency_conversion_rate := NVL(l_dist_info_tbl(cnt).currency_conversion_rate, 1);

      -- Call to populate account generator API

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Call to Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen ');
      END IF;

      Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
    	p_contract_id	     => l_khr_id,
    	p_contract_line_id	 => lx_tplv_tbl(cnt).kle_id,
    	x_acc_gen_tbl		 => l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl,
    	x_return_status		 => x_return_status);

      l_acc_gen_primary_key_tbl(cnt).source_id := lx_tplv_tbl(cnt).id;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End call to Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen');
      END IF;

      EXIT WHEN cnt = lx_tplv_tbl.LAST;
      cnt := lx_tplv_tbl.NEXT(cnt);
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Call to Okl_Account_Dist_Pub.Create_Accounting_Dist');
    END IF;
    Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
								   p_api_version             => p_api_version
                                  ,p_init_msg_list           => p_init_msg_list
                                  ,x_return_status  	     => x_return_status
                                  ,x_msg_count      	     => x_msg_count
                                  ,x_msg_data       	     => x_msg_data
                                  ,p_tmpl_identify_tbl 	     => l_tmpl_identify_tbl
                                  ,p_dist_info_tbl           => l_dist_info_tbl
                                  ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                  ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                  ,x_template_tbl            => l_template_tbl
                                  ,x_amount_tbl              => l_amount_tbl
                                  ,p_trx_header_id           => lx_tapv_rec.ID
                                  ,p_trx_header_table        => 'OKL_TRX_AP_INVOICES_B');

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End Call to Okl_Account_Dist_Pub.Create_Accounting_Dist ');
     END IF;

--end:|             17-May-07    cklee   -- Accounting API CR                                         |
------------------------------------------------------------------------------
-- END: Move accounting call after creating the OKL AP internal invoice lines
------------------------------------------------------------------------------


    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );

    IF (G_IS_DEBUG_PROCEDURE_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, G_MODULE,'End OKLRCDTB.pls Debug call ');
    END IF;
 EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END Create_Disb_Trx;


  -- Procedure for updating Transaction status
  PROCEDURE Update_Disb_Trx(p_api_version               IN  NUMBER
                           ,p_init_msg_list             IN  VARCHAR2    DEFAULT OKL_API.G_FALSE
                           ,x_return_status             OUT NOCOPY VARCHAR2
                           ,x_msg_count                 OUT NOCOPY NUMBER
                           ,x_msg_data                  OUT NOCOPY VARCHAR2
                           ,p_tapv_rec                  IN tapv_rec_type
                           ,x_tapv_rec                  OUT NOCOPY tapv_rec_type
                            )
  IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'UPDATE_DISB_TRX';
   l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_tapv_rec      tapv_rec_type;
   lx_tapv_rec     tapv_rec_type;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

   l_return_status := okl_api.start_activity(
                                        p_api_name      => l_api_name,
                                        p_init_msg_list => p_init_msg_list,
                                        p_api_type      => '_PVT',
                                        x_return_status => l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_tapv_rec := p_tapv_rec;

   OKL_TRX_AP_INVOICES_PUB.Update_trx_ap_invoices(p_api_version      =>  p_api_version
                                                 ,p_init_msg_list    =>   p_init_msg_list
                                                 ,x_return_status    =>   x_return_status
                                                 ,x_msg_count        =>   x_msg_count
                                                 ,x_msg_data         =>   x_msg_data
                                                 ,p_tapv_rec         =>   l_tapv_rec
                                                 ,x_tapv_rec         =>   lx_tapv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   x_tapv_rec := lx_tapv_rec;

   OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END Update_Disb_Trx;

  FUNCTION get_khr_line_amount(p_invoice_id IN NUMBER
                              ,p_khr_id IN NUMBER) RETURN NUMBER IS
    l_khr_line_amount NUMBER DEFAULT 0;
/*
		CURSOR l_khr_line_amt_csr(cp_invoice_id NUMBER, cp_khr_id NUMBER) IS
		SELECT sum(lin.amount) khr_line_amount
		FROM ap_invoice_lines_all lin
		    ,okl_txl_ap_inv_lns_all_b tpl
		    ,fnd_application app
		WHERE lin.application_id = app.application_id
		AND   app.application_short_name = 'OKL'
		AND   lin.product_table = 'OKL_TXL_AP_INV_LNS_ALL_B'
		AND   tpl.id = TO_NUMBER(lin.reference_key1)
		AND   lin.invoice_id = cp_invoice_id
		AND   tpl.khr_id = cp_khr_id;
*/
--start: cklee 08/31/07 fixed for the migration
		CURSOR l_khr_line_amt_csr(cp_invoice_id NUMBER, cp_khr_id NUMBER) IS
		SELECT sum(tpl.amount) khr_line_amount
		FROM ap_invoices_all ap
		    ,okl_txl_ap_inv_lns_all_b tpl
      	    ,okl_cnsld_ap_invs_all cin
		where ap.product_table = 'OKL_CNSLD_AP_INVS_ALL'
		AND   cin.cnsld_ap_inv_id = TO_NUMBER(ap.reference_key1)
		AND   tpl.cnsld_ap_inv_id = cin.cnsld_ap_inv_id
		AND   ap.invoice_id = cp_invoice_id
		AND   tpl.khr_id = cp_khr_id;
--end: cklee 08/31/07 fixed for the migration

  BEGIN
	  OPEN l_khr_line_amt_csr(p_invoice_id, p_khr_id);
	  FETCH l_khr_line_amt_csr INTO l_khr_line_amount;
	  CLOSE l_khr_line_amt_csr;

	  RETURN l_khr_line_amount;
  END get_khr_line_amount;

 END OKL_CREATE_DISB_TRANS_PVT;

/
