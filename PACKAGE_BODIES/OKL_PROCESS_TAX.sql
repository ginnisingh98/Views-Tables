--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_TAX" AS
/* $Header: OKLRTAXB.pls 120.12 2006/08/11 10:44:39 gboomina noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

 -- SUBTYPE tax_rec_type         IS OKL_TAX_PVT.okl_tax_lines_v_rec_type;


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

/*========================================================================
 | PRIVATE FUNCTION Check_Tax_Exempt
 |
 | DESCRIPTION
 |    This function checks whether the asset line is exempt from tax
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     Create_Tax_Schedule
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_kle_id                 IN       Contract Line Id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-MAY-2004          RKUTTIYA           Created
 |
 *=======================================================================*/
 /*
 FUNCTION Tax_Exempt(p_kle_id IN NUMBER)
 RETURN BOOLEAN IS */
/* ------------------------------------------*/
--  Cursor Declarations
/*--------------------------------------------*/
/* CURSOR c_exempt_status(p_kle_id IN NUMBER) IS
 SELECT rul.rule_information1
 FROM   okc_rule_groups_b rgp,
        okc_rules_b rul
 WHERE  rgp.rgd_code = 'LAASTX'
 AND    RGP.ID = RUL.rgp_id
 AND    RUL.RULE_INFORMATION_CATEGORY = 'LAASTX'
 AND    RGP.CLE_ID = p_kle_id; */
/*---------------------------------------------*/
-- Local Variable Declarations
/*---------------------------------------------*/
/* l_tax_status   VARCHAR2(1);
 BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PROCESS_TAX.Tax_Exempt','Begin(+)');
   END IF;
 --Print Input Variables
   print_to_log('p_kle_id :'||p_kle_id);

   OPEN c_exempt_status(p_kle_id);
   FETCH c_exempt_status INTO l_tax_status;
   CLOSE c_exempt_status;

   print_to_log('Tax Status :'||l_tax_status);
--If Tax Exempt return TRUE  Else If not Tax Exempt return FALSE
   IF (l_tax_status = 'E') or (l_tax_status = 'Y') THEN
     RETURN TRUE;
   ELSE
     RETURN FALSE;
   END IF;
 EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Tax_Exempt',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
       END IF;
       IF c_exempt_status%ISOPEN THEN
          CLOSE c_exempt_status;
       END IF;
     RAISE;
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Tax_Exempt ',
                  'EXCEPTION :'||sqlerrm);
      END IF;
      RAISE;
 END Tax_Exempt; */
/*========================================================================
 | PRIVATE PROCEDURE Get_Asset_Details
 |
 | DESCRIPTION
 |    This function returns the asset details like Asset Id, Asset Number
 |    ship_to_site_use_id,ship_to_location when passed the financial Asset line id
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     Create_Tax_Schedule
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_kle_id                 IN       Contract Line Id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-MAY-2004          RKUTTIYA           Created
 | 17-JAN-2005          RKUTTIYA           Bug: 3977770
 |                                         Made changes in the procedure Get_Asset_details
 |                                         in cursor c_get_shiptositeid
 |                                         removed reference to cust_acct_site_id
 |                                         changed it to site_use_id
 | 20-JAN-2005          RKUTTIYA           Added FND debug messages
 *=======================================================================*/
 /*
 PROCEDURE Get_Asset_Details(p_api_version        IN  NUMBER,
                             p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY NUMBER,
                             x_msg_data           OUT NOCOPY VARCHAR2,
                             p_flag               IN  VARCHAR2,
                             p_cust_acct_id       IN  NUMBER,
                             p_kle_id             IN  NUMBER,
                             px_asset_id          OUT NOCOPY NUMBER,
                             px_asset_number      OUT NOCOPY VARCHAR2,
                             px_ship_to_siteuseid OUT NOCOPY NUMBER,
                             px_ship_to_locid     OUT NOCOPY NUMBER,
                             px_postal_code       OUT NOCOPY VARCHAR2)
 AS */
/* ------------------------------------------*/
--  Cursor Declarations
/*--------------------------------------------*/
--Cursor to get the Asset Id and Asset Number
/*
  CURSOR c_asset_number(p_kle_id IN NUMBER) IS
  SELECT CTL.NAME,
         CIM.object1_id1
  FROM   OKC_K_LINES_B CLE1,
         OKC_K_LINEs_B CLE2,
         OKC_LINE_STYLES_B CLS1,
         OKC_LINE_STYLES_B CLS2,
         OKC_K_LINES_TL CTL,
         OKC_K_ITEMS    CIM
  WHERE CLE1.LSE_ID = CLS1.ID
  AND   CLS1.LTY_CODE = 'FREE_FORM1'
  AND   CLE1.id = CLE2.cle_id
  AND   CLE2.lse_id = CLS2.id
  AND   CLS2.lty_code = 'FIXED_ASSET'
  AND   CLE1.id = CTL.id
  AND  CTL.LANGUAGE(+) = USERENV('LANG')
  AND  CIM.CLE_ID = CLE2.id
  AND  CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
  AND  CLE1.ID = p_kle_id;
--Cursor to get the  install_location_id of the asset
  CURSOR c_get_instlocid(p_kle_id IN NUMBER) IS
  SELECT  csi.install_location_id,
         -- csi.location_id
          csi.install_location_type_code
  FROM    csi_item_instances csi,
       	  okc_k_items cim,
       	  okc_k_lines_b   inst,
       	  okc_k_lines_b   ib,
       	  okc_line_styles_b lse
  WHERE  csi.instance_id = TO_NUMBER(cim.object1_id1)
  AND    cim.cle_id = ib.id
  AND    ib.cle_id = inst.id
  AND    inst.lse_id = lse.id
  AND    lse.lty_code = 'FREE_FORM2'
  AND    inst.cle_id = p_kle_id ;

 --Cursor to get the corresponding hz_location id for the install location id
  CURSOR c_get_location_id(p_party_site_id  IN NUMBER) IS
  SELECT hzp.location_id
  FROM  HZ_PARTY_SITES HZP
  WHERE HZP.PARTY_SITE_ID = p_party_site_id;

  --Cursor to get the corresponding party_site_id FOR  a location id
  CURSOR c_get_party_site_id(p_location_id IN NUMBER) IS
  SELECT HZP.PARTY_SITE_ID
  FROM HZ_PARTY_SITES HZP,
       HZ_PARTY_SITE_USES HZU
  WHERE HZP.LOCATION_ID = p_location_id
  AND   HZP.party_site_id  = HZU.PARTY_SITE_ID
  AND   HZU.SITE_USE_TYPE = 'INSTALL_AT'   ;


 */
--Cursor to get the ship_to_site_use_id corresponding to the install_location_id of the asset
/*
  CURSOR c_get_shiptositeid(p_cust_acct_id IN NUMBER, p_inst_loc_id IN NUMBER,p_loc_id IN NUMBER) IS
  SELECT
 --rkuttiya modified to site use id for bug:3977770
         b.site_use_id
  FROM   hz_cust_acct_sites_all a,
         hz_cust_site_uses_all  b,
         hz_party_sites      c
  WHERE  a.CUST_ACCT_SITE_ID = b.CUST_ACCT_SITE_ID
  AND    b.site_use_code     = 'SHIP_TO'
  AND    a.party_site_id     = c.party_site_id
  AND    a.cust_account_id   = p_cust_acct_id
  AND    a.org_id            = NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99)
  AND    c.party_site_id     = p_inst_loc_id
  AND    c.location_id       = p_loc_id;

--Cursor to get the ship_to_location_id (loc ccid)
  CURSOR c_get_shiptolocid(p_location_id IN NUMBER) IS
  SELECT  HZA.loc_id,
          HZ.postal_code
  FROM HZ_LOC_ASSIGNMENTS HZA,
       HZ_LOCATIONS HZ
  WHERE HZ.location_id = p_location_id
  AND   HZ.LOCATION_ID = HZA.LOCATION_ID
  AND ORG_ID = NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99);
  */
 /*---------------------------------------------*/
-- Local Variable Declarations
/*---------------------------------------------*/

/*
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_asset_id              NUMBER;
   l_asset_number          VARCHAR2(150);
   l_inst_loc_id           NUMBER;
   l_inst_loc_type_code    VARCHAR2(30);
   l_loc_id                NUMBER;
   l_ship_to_id            NUMBER;
   l_ship_to_locid         NUMBER;
 BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PROCESS_TAX.Get_Asset_Details','Begin(+)');
   END IF;
 --Print Input Variables
   print_to_log('Input variables to Get_Asset_details');
   print_to_log('p_api_version :'||p_api_version);
   print_to_log('p_init_msg_list :'||p_init_msg_list);
   print_to_log('p_flag :'||p_flag);
   print_to_log('p_cust_acct_id :'||p_cust_acct_id);
   print_to_log('p_kle_id :'||p_kle_id);
   print_to_log('px_asset_id :'||px_asset_id);
   print_to_log('px_asset_number :'||px_asset_number);
   print_to_log('px_ship_to_siteuseid :'||px_ship_to_siteuseid);
   print_to_log('px_postal_code :'||px_postal_code);


  --Get the Asset Id and the Asset Number
   OPEN c_asset_number(p_kle_id);
   FETCH c_asset_number INTO px_asset_number,px_asset_id;
   CLOSE c_asset_number;

   IF p_flag = 'Y' THEN
       --get the install location id of the asset
       OPEN c_get_instlocid(p_kle_id);
       FETCH c_get_instlocid INTO l_inst_loc_id,l_inst_loc_type_code;
       CLOSE c_get_instlocid;

       print_to_log('l_inst_loc_id :'||l_inst_loc_id);
       print_to_log('l_inst_loc_type_code :'||l_inst_loc_type_code);

       IF l_inst_loc_id IS NULL  THEN
     -- Install Location id is required
           OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => G_REQUIRED_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'LOCATION_ID');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

        --Check the source of the install location id
        IF l_inst_loc_type_code = 'HZ_PARTY_SITES' THEN
          OPEN c_get_location_id(l_inst_loc_id);
          FETCH c_get_location_id INTO l_loc_id;
          CLOSE c_get_location_id;
        ELSIF l_inst_loc_type_code = 'HZ_LOCATIONS' THEN
          l_loc_id := l_inst_loc_id;
          OPEN c_get_party_site_id(l_loc_id);
          FETCH c_get_party_site_id INTO l_inst_loc_id;
          CLOSE c_get_party_site_id;
        END IF;

       --get the ship to site use id of the asset
         OPEN c_get_shiptositeid(p_cust_acct_id,l_inst_loc_id,l_loc_id);
         FETCH c_get_shiptositeid INTO px_ship_to_siteuseid;
         CLOSE c_get_shiptositeid;
         print_to_log('px_ship_to_siteuseid :'||px_ship_to_siteuseid);

         IF px_ship_to_siteuseid IS NULL THEN
     -- Install Location id is required
           OKL_API.set_message( p_app_name      => 'OKL',
                                p_msg_name      => G_REQUIRED_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'SHIP_TO');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       --get the ship to location id
         OPEN c_get_shiptolocid(l_loc_id);
         FETCH c_get_shiptolocid INTO px_ship_to_locid,px_postal_code;
         CLOSE c_get_shiptolocid;

         print_to_log('px_ship_to_locid :'||px_ship_to_locid);
         print_to_log('px_postal_code :'||px_postal_code);
       ELSE
         px_ship_to_siteuseid := NULL;
         px_ship_to_locid   := NULL;
         px_postal_code     := NULL;
       END IF;
         x_return_status := l_return_status;
 EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Get_Asset_Details',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
       END IF;
       IF c_asset_number%ISOPEN THEN
          CLOSE c_asset_number;
       END IF;
       IF c_get_instlocid%ISOPEN THEN
          CLOSE c_get_instlocid;
       END IF;
       IF c_get_shiptositeid%ISOPEN THEN
          CLOSE c_get_shiptositeid;
       END IF;
       IF c_get_shiptolocid%ISOPEN THEN
         CLOSE c_get_shiptolocid;
       END IF;
     RAISE;
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Get_Asset_Details ',
                  'EXCEPTION :'||sqlerrm);
      END IF;
      IF c_asset_number%ISOPEN THEN
          CLOSE c_asset_number;
       END IF;
       IF c_get_instlocid%ISOPEN THEN
          CLOSE c_get_instlocid;
       END IF;
       IF c_get_shiptositeid%ISOPEN THEN
          CLOSE c_get_shiptositeid;
       END IF;
       IF c_get_shiptolocid%ISOPEN THEN
         CLOSE c_get_shiptolocid;
       END IF;
      RAISE;
 END Get_Asset_Details;

 */
/*========================================================================
 | PUBLIC PROCEDURE Create_Tax_Schedule
 |
 | DESCRIPTION
 |      This procedure will query all streams for a contract, pass the stream amounts to
 |      the Global Tax Engine for calculating tax for each of the amounts and create tax schedules in
 |      OKL_TAX_LINES
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and cuntions which
 |      this package calls.
 |
 | PARAMETERS
 |      p_contract_id    IN      Contract Identifier
 |      p_trx_date   IN      Schedule Request Date
 |      p_date_from      IN      Date From
 |      p_date_to        IN      Date To
 |      x_return_status  OUT     Return Status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-MAY-2004           RKUTTIYA             Created
 |
 *=======================================================================*/

PROCEDURE Create_Tax_Schedule(  p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_tax_in_rec     IN  okl_tax_rec_type) IS

 /*-----------------------------------------------------------------------+
 | Cursor Declarations                                                    |
 +-----------------------------------------------------------------------*/
--Cursor to get the customer_account_id for the customer
  /*

  CURSOR c_get_custacctid(p_khr_id IN NUMBER) IS
  SELECT cust_acct_id
  FROM  OKC_K_HEADERS_B
  WHERE ID = p_khr_id;

--Cursor to get all the stream associated with the contract
   CURSOR c_contract_streams(p_contract_id IN NUMBER,
                             p_date_from   IN DATE,
                             p_date_to     IN DATE) IS
   SELECT typ.code Stream_Type,
          typ.billable_yn Billable,
          strm.id stream_id,
          strm.transaction_number,
          strm.sty_id type_id,
          strm.kle_id line_id,
          strm.khr_id contract_id,
          selm.id stream_element_id,
          selm.amount,
          selm.stream_element_date
    FROM  okl_strm_type_b typ,
          okl_streams_v strm,
          okl_strm_elements_v selm
    WHERE  strm.sty_id = typ.id
    AND    strm.id = selm.stm_id
    AND    typ.billable_yn = 'Y'
    AND    typ.taxable_default_yn = 'Y'
    AND    strm.say_code ='CURR'
    and    strm.active_yn = 'Y'
    and    strm.purpose_code is null
    and    strm.khr_id = p_contract_id
    and    selm.stream_element_date between p_date_from and p_date_to
    AND  NOT EXISTS
          (SELECT NULL
          FROM  okl_cnsld_ar_strms_b CNSLD
          WHERE cnsld.sel_id = selm.id
          and  cnsld.receivables_invoice_id IS NOT NULL);

--Cursor to obtain streams that have been invoiced to AR

  CURSOR c_invoiced_streams( p_contract_id IN NUMBER,
                             p_date_from   IN DATE,
                             p_date_to     IN DATE) IS
  SELECT  typ.code Stream_Type,
          typ.billable_yn Billable,
          selm.id stream_element_id,
          strm.transaction_number,
          strm.sty_id type_id,
          strm.kle_id line_id,
          strm.khr_id contract_id,
          selm.amount,
          selm.stream_element_date,
          rtrh.invoice_currency_code,
          rtrl.extended_amount,
          rtrl.tax_rate,
          rtrl.taxable_amount,
          ATX.tax_code,
          RTRL.SALES_TAX_ID,
          rtrl.customer_trx_id,
          RTRL.tax_exemption_id,
          RTRL.item_exception_rate_id
  FROM    okl_strm_type_b typ,
          okl_streams_v strm,
          okl_strm_elements_v selm,
          OKL_CNSLD_AR_STRMS_B CNSLD,
          RA_CUSTOMER_TRX_ALL RTRH,
          RA_CUSTOMER_TRX_LINES_ALL RTRL,
          AR_VAT_TAX_ALL ATX
  WHERE  strm.khr_id = p_contract_id
  AND    strm.sty_id = typ.id
  AND    strm.id = selm.stm_id
  AND    typ.billable_yn = 'Y'
  AND    typ.taxable_default_yn = 'Y'
  AND    strm.say_code ='CURR'
  AND    strm.active_yn = 'Y'
  AND    strm.purpose_code is null
  AND    selm.id = cnsld.sel_id
  AND    selm.stream_element_date between p_date_from and p_date_to
  AND    cnsld.receivables_invoice_id = rtrh.customer_trx_id
  AND    rtrh.customer_trx_id = rtrl.customer_trx_id
  AND    RTRL.ORG_ID = NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99)
  AND    RTRL.VAT_TAX_ID = ATX.VAT_TAX_ID
  AND    rtrl.line_type = 'TAX' ;


  CURSOR  c_get_billto_location ( p_bill_to_site_use_id IN NUMBER, p_cust_acct_id IN NUMBER) IS
  SELECT  loc_assign.loc_id  location_id
  FROM    HZ_PARTY_SITES            party_site,
          HZ_LOC_ASSIGNMENTS        loc_assign,
          HZ_LOCATIONS              loc,
          HZ_CUST_ACCT_SITES_ALL    acct_site,
          HZ_PARTIES                party,
          HZ_CUST_ACCOUNTS          cust_acct,
          HZ_CUST_SITE_USES         cust_site_uses
  WHERE   acct_site.party_site_id     = party_site.party_site_id
  AND     loc.location_id             = party_site.location_id
  AND     loc.location_id             = loc_assign.location_id
  AND     acct_site.cust_acct_site_id = cust_site_uses.cust_acct_site_id
  AND     party.party_id              = cust_acct.party_id
  AND     cust_site_uses.site_use_id  = p_bill_to_site_use_id
  AND     cust_acct.cust_account_id   = p_cust_acct_id
  AND     loc_assign.org_id= NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99);

-- Cursor to get the line id for the linked asset
  CURSOR c_linked_asset_line(p_kle_id IN NUMBER) IS
  SELECT fa.id
  FROM okc_k_lines_b fa,
       okc_line_styles_b stl,
       okc_k_lines_b top_cle,
       okc_line_styles_b top_stl,
       okc_k_lines_b sub_cle,
       okc_line_styles_b sub_stl,
       okc_k_items   cim
  WHERE top_cle.lse_id = top_stl.id
  AND top_stl.lty_code in ('SOLD_SERVICE','FEE')
  AND top_cle.id = sub_cle.cle_id
  AND sub_cle.lse_id = sub_stl.id
  AND sub_stl.lty_code in ('LINK_SERV_ASSET','LINK FEE ASSET')
  AND cim.cle_id = sub_cle.id
  AND CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'
  AND CIM.OBJECT1_ID1  = FA.ID
  AND FA.LSE_ID = STL.ID
  AND STL.LTY_CODE = 'FREE_FORM1'
  AND sub_cle.id =  p_kle_id;

-- Cursor to get the lty_code for the give line
  CURSOR c_lty_code(p_kle_id IN NUMBER) IS
  SELECT B.LTY_CODE
  FROM OKC_K_LINES_B A,
       OKC_LINE_STYLES_B B
  WHERE A.LSE_ID = B.ID
  AND A.ID = p_kle_id;
*/
l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Tax_Schedule';
l_api_version           CONSTANT NUMBER := 1;
 /*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
  /* l_exist                 VARCHAR2(1);
   lx_asset_id             NUMBER;
   lx_asset_number         VARCHAR2(150);
   l_lty_code              VARCHAR2(150);
   l_inst_loc_id           NUMBER;
   l_loc_id                NUMBER;
   l_ship_to_id            NUMBER;
   l_cust_acct_id          NUMBER(15,0);
   l_org_id                NUMBER;
   l_sob_id		   NUMBER        :=NULL;
   l_currency		   VARCHAR2(15)	 := NULL;
   l_precision		   NUMBER(1,0)	 := NULL;
   l_min_acc_unit	   NUMBER	 := NULL;
   l_cust_site_use_id	   NUMBER(15,0)	 := NULL;
   l_cust_account_id	   NUMBER        := NULL;
   lx_ship_to_siteuseid    NUMBER(15,0);
   lx_ship_to_locid        NUMBER;
   lx_postal_code          VARCHAR2(60);
   l_bill_to_postal_code   VARCHAR2(60);
   l_bill_to_locid         NUMBER;
   l_line_id               NUMBER;
   l_count                 NUMBER;
   l_tax_amt               NUMBER;
   l_object_name	   VARCHAR2(200);
   l_tax_tbl		   ARP_TAX.om_tax_out_tab_type;
   l_bill_to_rec	   okx_cust_site_uses_v%ROWTYPE;
   l_gte_tax_rec           ARP_TAX.tax_info_rec_type;
   l_okl_tax_rec           tax_rec_type;
   lx_tax_rec              tax_rec_type;
   l_newrec_count          NUMBER :=0;
   l_call_tax_api          VARCHAR2(1) := 'Y';
   l_tax_rate              NUMBER;
   l_tax_code              VARCHAR2(60);
   */
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PROCESS_TAX.Create_Tax_Schedule','Begin(+)');
  END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Input variables in Create_Tax_Schedule');
   END IF;
--Print Input Variables
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_contract_id :'||p_tax_in_rec.contract_id);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_trx_id :'||p_tax_in_rec.trx_id);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_trx_date :'||p_tax_in_rec.trx_date);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_line_type :'||p_tax_in_rec.line_type);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_date_from :'||p_tax_in_rec.date_from);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_date_to :'||p_tax_in_rec.date_to);
   END IF;

  l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);
/*
--Get the Customer Account Id for the contract
  OPEN c_get_custacctid(p_tax_in_rec.contract_id);
  FETCH c_get_custacctid INTO l_cust_acct_id;
  CLOSE c_get_custacctid;

  print_to_log('Customer Acount id'|| l_cust_acct_id);

--Get the org id , currency, precision, minimum accounting unit
  l_org_id   := okl_am_util_pvt.get_chr_org_id (p_tax_in_rec.contract_id);
  l_sob_id   := okc_currency_api.get_ou_sob (l_org_id);
  l_currency := okc_currency_api.get_sob_currency (l_sob_id);

  okl_am_util_pvt.get_currency_info
			(l_currency, l_precision, l_min_acc_unit);


--Query all streams for the contract which satisfy
    --date range, Billable, Taxable, Active, Current, Purpose Code
  FOR contract_streams_rec IN c_contract_streams(p_tax_in_rec.contract_id,p_tax_in_rec.date_from,p_tax_in_rec.date_to)  LOOP
    -- Initialising all the loop variable to null for every row.
    l_cust_site_use_id    := NULL;
    l_cust_account_id     := NULL;
    lx_asset_id           := NULL;
    lx_asset_number       := NULL;
    lx_ship_to_siteuseid  := NULL;
    lx_ship_to_locid      := NULL;
    l_bill_to_locid       := NULL;
    lx_postal_code        := NULL;
    l_bill_to_postal_code := NULL;

    IF contract_streams_rec.line_id IS NULL THEN
      l_lty_code := NULL;
    ELSE
      OPEN c_lty_code(contract_streams_rec.line_id);
      FETCH c_lty_code INTO l_lty_code;
      IF c_lty_code%NOTFOUND THEN
      -- The case of a bad data need to be handled (Bad line id in the streams record)
         OKL_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => 'OKL_INVALID_DATA');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE c_lty_code;
    END IF;
   print_to_log('lty_code :'||l_lty_code);
    IF (l_lty_code = 'FREE_FORM1') OR
       (l_lty_code = 'LINK_SERV_ASSET')OR
       (l_lty_code = 'LINK_FEE_ASSET') THEN
      IF l_lty_code = 'FREE_FORM1' THEN -- Financial Asset line
        l_line_id := contract_streams_rec.line_id;
      ELSE -- Linked Asset Line - Service or Fee
       --get the line id of the asset linked to the service or fee
        OPEN c_linked_asset_line(contract_streams_rec.line_id);
        FETCH c_linked_asset_line INTO l_line_id;
        CLOSE c_linked_asset_line;
      END IF;
      --set the variable to call the tax api, after checking whether the line is tax exempt or not.
      IF Tax_Exempt(l_line_id) THEN
        l_call_tax_api := 'N';
      ELSE
        l_call_tax_api := 'Y';
      END IF;
    print_to_log('call tax api :'||l_call_tax_api);

     --If the line is tax exempt , there is no need to get asset details
      IF NOT Tax_Exempt(l_line_id) THEN
       -- Get the Asset Details
          Get_Asset_Details(p_api_version        => p_api_version,
                            p_init_msg_list      => p_init_msg_list,
                            x_return_status      => l_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_flag               => 'Y',
                            p_cust_acct_id       => l_cust_acct_id,
                            p_kle_id             => l_line_id,
                            px_asset_id          => lx_asset_id,
                            px_asset_number      => lx_asset_number,
                            px_ship_to_siteuseid => lx_ship_to_siteuseid,
                            px_ship_to_locid     => lx_ship_to_locid,
                            px_postal_code       => lx_postal_code);
          print_to_log('return status from Get_Asset_Details :'|| l_return_status);
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


       END IF; -- Tax Exempt
    ELSIF (l_lty_code = 'SOLD_SERVICE') OR -- Line with no assets
       (l_lty_code = 'FEE') OR -- Line with no assets
       (l_lty_code = 'INSURANCE') OR -- Insurance line
       (contract_streams_rec.line_id IS NULL) THEN -- Contract level payment

      -- get the contract bill to site useid, bill to location
      l_bill_to_rec := NULL;
      okl_am_util_pvt.get_bill_to_address (
			p_contract_id		    => p_tax_in_rec.contract_id,
			p_message_yn		    => FALSE,
			x_bill_to_address_rec	    => l_bill_to_rec,
			x_return_status		    => l_return_status);
      print_to_log('return status from get_bill_to_address :'|| l_return_status);

      IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
    	 l_cust_site_use_id := l_bill_to_rec.id1;
	     l_cust_account_id  := l_bill_to_rec.cust_account_id;
         l_bill_to_postal_code := l_bill_to_rec.postal_code;
         OPEN c_get_billto_location(l_cust_site_use_id,l_cust_account_id);
         FETCH c_get_billto_location INTO l_bill_to_locid;
         CLOSE c_get_billto_location;
      END IF;
      print_to_log('customer bill to site_use_id :'|| l_cust_site_use_id);
      print_to_log('customer bill to location_id :'|| l_bill_to_locid);
      print_to_log('customer bill to postal_code :'|| l_bill_to_postal_code);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS)
      OR (l_cust_site_use_id IS NULL)
      OR (l_cust_account_id  IS NULL) THEN
      --  l_overall_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE (p_app_name	     => OKL_API.G_APP_NAME,
        	       	     p_msg_name	     => 'OKL_AM_TAX_NO_BILL_TO',
                             p_token1	     => 'OBJECT',
		             p_token1_value  => l_object_name);
      END IF;

    END IF; --lty code check

    IF l_call_tax_api = 'Y' THEN

    --Reset the GLOBAL tax_info_rec rec type with empty rec type
     ARP_TAX.tax_info_rec         := l_gte_tax_rec;

     -- prepare the input tax record structure
     ARP_TAX.tax_info_rec.trx_date		       := p_tax_in_rec.trx_date;
     ARP_TAX.tax_info_rec.extended_amount	       := contract_streams_rec.amount;
     ARP_TAX.tax_info_rec.trx_currency_code	       := l_currency;
     ARP_TAX.tax_info_rec.PRECISION		       := l_precision;
     ARP_TAX.tax_info_rec.minimum_accountable_unit     := l_min_acc_unit;
     ARP_TAX.tax_info_rec.ship_to_cust_id              := l_cust_acct_id;
     ARP_TAX.tax_info_rec.bill_to_cust_id              := l_cust_acct_id;
     ARP_TAX.tax_info_rec.ship_to_site_use_id          := lx_ship_to_siteuseid;
     ARP_TAX.tax_info_rec.ship_to_location_id          := lx_ship_to_locid;
     ARP_TAX.tax_info_rec.ship_to_postal_code          := lx_postal_code;
     ARP_TAX.tax_info_rec.bill_to_site_use_id          := l_cust_site_use_id;
     ARP_TAX.tax_info_rec.bill_to_location_id          := l_bill_to_locid;
     ARP_TAX.tax_info_rec.bill_to_postal_code          := l_bill_to_postal_code;


    -- make call to tax engine
    BEGIN
       ARP_TAX_CRM_INTEGRATION_PKG.summary
			(p_set_of_books_id 	=>	l_sob_id
			,x_crm_tax_out_tbl	=>	l_tax_tbl
			,p_new_tax_amount	=>	l_tax_amt);

    EXCEPTION


--Tax API logs the messages in a debug file in case of exceptions raised. hence coding in this manner.
       WHEN OTHERS THEN
       -- exceptions raised by Tax engine
          OKL_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => 'OKL_CS_TAX_FAILED');

          RAISE OKL_API.G_EXCEPTION_ERROR;
    END;--call to tax api.


    -- get the out put tax record structure;
     l_count := l_tax_tbl.COUNT;
     print_to_log('count in table :'|| l_tax_tbl.COUNT);

    IF l_count > 0 THEN
       FOR i IN 1..l_count LOOP
         l_okl_tax_rec.khr_id                 := p_tax_in_rec.contract_id;
         l_okl_tax_rec.kle_id                 := contract_streams_rec.line_id;
         l_okl_tax_rec.asset_id               := lx_asset_id;
         l_okl_tax_rec.asset_number           := lx_asset_number;
         l_okl_tax_rec.tax_line_type          := p_tax_in_rec.line_type;
         l_okl_tax_rec.sel_id                 := contract_streams_rec.stream_element_id;
         l_okl_tax_rec.tax_due_date           := contract_streams_rec.stream_element_date;
         l_okl_tax_rec.tax_type               := l_tax_tbl(i).tax_type;
         l_okl_tax_rec.tax_rate_code          := l_tax_tbl(i).tax_code;
         l_okl_tax_rec.taxable_amount         := contract_streams_rec.amount;
         l_okl_tax_rec.tax_exemption_id       := l_tax_tbl(i).tax_exemption_id;
         l_okl_tax_rec.tax_rate               := l_tax_tbl(i).tax_rate;
         l_okl_tax_rec.tax_amount             := l_tax_tbl(i).tax_amount;
         l_okl_tax_rec.sales_tax_id           := l_tax_tbl(i).sales_tax_id;
         l_okl_tax_rec.trq_id                 := p_tax_in_rec.trx_id;
         l_okl_tax_rec.actual_yn              := 'E'; --Estimated Tax
         l_okl_tax_rec.org_id                 := l_org_id;
         l_okl_tax_rec.history_yn             := 'N';

         print_to_log(i||'tax rate'||l_okl_tax_rec.tax_rate);
         print_to_log(i||'tax code'||l_okl_tax_rec.tax_rate_code);
         print_to_log(i||'taxable amount'||l_okl_tax_rec.taxable_amount);
         print_to_log(i||'tax amount'||l_okl_tax_rec.tax_amount);

         l_newrec_count := l_newrec_count+1;

         -- if a new record is inserted to okl_tax_lines then historize the rest active schedules
         IF l_newrec_count = 1 THEN
           update okl_tax_lines
           set history_yn = 'Y'
           where history_yn = 'N'
           and  khr_id = p_tax_in_rec.contract_id;
         END IF;

         -- call to simple apis to insert the tax lines into OKL_TAX_LINES
         OKL_TAX_PVT.insert_row(p_api_version             => l_api_version,
                                p_init_msg_list           => 'F',
                                x_return_status           => l_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data,
                                p_okl_tax_lines_v_rec     => l_okl_tax_rec,
                                x_okl_tax_lines_v_rec     => lx_tax_rec);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

        END LOOP; -- end processing output tax table

     END IF;-- If count > 0
  END IF;  -- If call_tax_api = 'y'
 END LOOP;  -- end processing of contract streams


  print_to_log('Processing Invoiced Streams');
   --Start processing invoiced streams with tax records
  FOR c_invoice_rec IN c_invoiced_streams(p_tax_in_rec.contract_id,p_tax_in_rec.date_from,p_tax_in_rec.date_to) LOOP

-- Initialising all the loop variable to null for every row.
    lx_asset_id           := NULL;
    lx_asset_number       := NULL;

    IF c_invoice_rec.line_id IS NULL THEN
      l_lty_code := NULL;
    ELSE
      OPEN c_lty_code(c_invoice_rec.line_id);
      FETCH c_lty_code INTO l_lty_code;
      IF c_lty_code%NOTFOUND THEN
        -- The case of a bad data need to be handled (Bad line id in the streams record)
         OKL_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => 'OKL_INVALID_DATA');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE c_lty_code;
      print_to_log('lty_code'||l_lty_code);
    END IF;

    IF (l_lty_code = 'FREE_FORM1') OR
       (l_lty_code = 'LINK_SERV_ASSET')OR
       (l_lty_code = 'LINK_FEE_ASSET') THEN
      IF l_lty_code = 'FREE_FORM1' THEN -- Financial Asset line
        l_line_id := c_invoice_rec.line_id;
      ELSE -- Linked Asset Line - Service or Fee
       --get the line id of the asset linked to the service or fee
        OPEN c_linked_asset_line(c_invoice_rec.line_id);
        FETCH c_linked_asset_line INTO l_line_id;
        CLOSE c_linked_asset_line;
      END IF;

      Get_Asset_Details(p_api_version        => p_api_version,
                            p_init_msg_list      => p_init_msg_list,
                            x_return_status      => l_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_flag               => 'N',
                            p_cust_acct_id       => l_cust_acct_id,
                            p_kle_id             => l_line_id,
                            px_asset_id          => lx_asset_id,
                            px_asset_number      => lx_asset_number,
                            px_ship_to_siteuseid => lx_ship_to_siteuseid,
                            px_ship_to_locid     => lx_ship_to_locid,
                            px_postal_code       => lx_postal_code);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    ELSIF (l_lty_code = 'SOLD_SERVICE') OR -- Line with no assets
       (l_lty_code = 'FEE') OR -- Line with no assets
       (c_invoice_rec.line_id IS NULL) THEN
       lx_asset_id := NULL;
       lx_asset_number := NULL;
    END IF;

--prepare the input record for inserting into the OKL Tax Entity
    l_okl_tax_rec.khr_id                 := p_tax_in_rec.contract_id;
    l_okl_tax_rec.kle_id                 := c_invoice_rec.line_id;
    l_okl_tax_rec.asset_id               := lx_asset_id;
    l_okl_tax_rec.asset_number           := lx_asset_number;
    l_okl_tax_rec.tax_line_type          := p_tax_in_rec.line_type;
    l_okl_tax_rec.sel_id                 := c_invoice_rec.stream_element_id;
    l_okl_tax_rec.tax_due_date           := c_invoice_rec.stream_element_date;
    l_okl_tax_rec.tax_rate_code          := c_invoice_rec.tax_code;
    l_okl_tax_rec.taxable_amount         := c_invoice_rec.taxable_amount;
    l_okl_tax_rec.tax_exemption_id       := c_invoice_rec.tax_exemption_id;
    l_okl_tax_rec.tax_rate               := c_invoice_rec.tax_rate;
    l_okl_tax_rec.tax_amount             := c_invoice_rec.extended_amount;
    l_okl_tax_rec.sales_tax_id           := c_invoice_rec.sales_tax_id;
    l_okl_tax_rec.actual_yn              := 'A'; --Actual Tax
    l_okl_tax_rec.trq_id                 := p_tax_in_rec.trx_id;
    l_okl_tax_rec.org_id                 := l_org_id;
    l_okl_tax_rec.history_yn             := 'N';


    l_newrec_count := l_newrec_count+1;
  -- if a new record is inserted to okl_tax_lines then historize the rest active schedules
     IF l_newrec_count = 1 THEN
        update okl_tax_lines
        set history_yn = 'Y'
        where history_yn = 'N'
        and khr_id = p_tax_in_rec.contract_id;
     END IF;

     -- call to simple apis to insert the actual tax lines from AR into OKL_TAX_LINES
         OKL_TAX_PVT.insert_row(p_api_version             => l_api_version,
                                p_init_msg_list           => 'F',
                                x_return_status           => l_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data,
                                p_okl_tax_lines_v_rec     => l_okl_tax_rec,
                                x_okl_tax_lines_v_rec     => lx_tax_rec);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

   END LOOP; --End Processing AR Tax records.

  print_to_log('return status from simple entity'||l_return_status);
  */

   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PROCESS_TAX.Create_Tax_Schedule ','End(-)');
  END IF;
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Create_Tax_Schedule ',
                  'EXCEPTION :'|| 'OKL_API.G_EXCEPTION_ERROR');
   END IF;
 /*  IF c_get_custacctid%ISOPEN THEN
    CLOSE c_get_custacctid;
   END IF;
   IF c_contract_streams%ISOPEN THEN
     CLOSE c_contract_streams;
   END IF;
   IF c_get_billto_location%ISOPEN THEN
     CLOSE c_get_billto_location;
   END IF;
   IF c_linked_asset_line%ISOPEN THEN
     CLOSE c_linked_asset_line;
   END IF;
   IF c_invoiced_streams%ISOPEN THEN
     CLOSE c_invoiced_streams;
   END IF;
   */
   x_return_status := OKL_API.G_RET_STS_ERROR;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Create_Tax_Schedule ',
                  'EXCEPTION :'|| 'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
   END IF;
   /*IF c_get_custacctid%ISOPEN THEN
    CLOSE c_get_custacctid;
   END IF;
   IF c_contract_streams%ISOPEN THEN
     CLOSE c_contract_streams;
   END IF;
   IF c_get_billto_location%ISOPEN THEN
     CLOSE c_get_billto_location;
   END IF;
   IF c_linked_asset_line%ISOPEN THEN
     CLOSE c_linked_asset_line;
   END IF;
   IF c_invoiced_streams%ISOPEN THEN
     CLOSE c_invoiced_streams;
   END IF;
   */
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Create_Tax_Schedule ',
                  'EXCEPTION :'||sqlerrm);
   END IF;
   /*IF c_get_custacctid%ISOPEN THEN
    CLOSE c_get_custacctid;
   END IF;
   IF c_contract_streams%ISOPEN THEN
     CLOSE c_contract_streams;
   END IF;
   IF c_get_billto_location%ISOPEN THEN
     CLOSE c_get_billto_location;
   END IF;
   IF c_linked_asset_line%ISOPEN THEN
     CLOSE c_linked_asset_line;
   END IF;
   IF c_invoiced_streams%ISOPEN THEN
     CLOSE c_invoiced_streams;
   END IF;
   */
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- unexpecetd error
   OKL_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
END Create_Tax_Schedule;


/*========================================================================
 | PUBLIC PROCEDURE Create_Tax_Schedule
 |
 | DESCRIPTION
 |      This procedure will query all streams for a contract, pass the stream amounts to
 |      the Global Tax Engine for calculating tax for each of the amounts and create tax schedules in
 |      OKL_TAX_LINES. This procedure takes parameters in the table structure.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and cuntions which
 |      this package calls.
 |
 | PARAMETERS
 |      p_contract_id    IN      Contract Identifier
 |      p_trx_date       IN      Schedule Request Date
 |      p_date_from      IN      Date From
 |      p_date_to        IN      Date To
 |      x_return_status  OUT     Return Status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-MAY-2004           RKUTTIYA             Created
 |
 *=======================================================================*/


PROCEDURE Create_Tax_Schedule(  p_api_version     IN  NUMBER,
                                p_init_msg_list   IN  VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2,
                                x_msg_count       OUT NOCOPY NUMBER,
                                x_msg_data        OUT NOCOPY VARCHAR2,
                                p_tax_in_tbl      IN  okl_tax_tbl_type)
IS
   l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_api_name              CONSTANT VARCHAR2(30) := 'Create_Tax_Schedule';
   l_api_version           CONSTANT NUMBER := 1;
   l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   i                       NUMBER;
BEGIN
  l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);
    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;
    -- Make sure PL/SQL table has records in it before passing
/*    IF (p_tax_in_tbl.COUNT > 0) THEN
      i := p_tax_in_tbl.FIRST;
      --Print Input Variables
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PROCESS_TAX.Create_Tax_Schedule',
            'P_contract_id :'||p_tax_in_tbl(i).contract_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PROCESS_TAX.Create_Tax_Schedule',
           'P_trx_id :'||p_tax_in_tbl(i).trx_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PROCESS_TAX.Create_Tax_Schedule',
           'p_trx_date :'||p_tax_in_tbl(i).trx_date);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PROCESS_TAX.Create_Tax_Schedule',
           'p_line_type :'||p_tax_in_tbl(i).line_type);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PROCESS_TAX.Create_Tax_Schedule',
           'p_date_from :'||p_tax_in_tbl(i).date_from);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PROCESS_TAX.Create_Tax_Schedule',
           'p_date_to :'||p_tax_in_tbl(i).date_to);
      END IF;
      LOOP
        Create_Tax_Schedule (
                  p_api_version                  => l_api_version,
                  p_init_msg_list                => OKL_API.G_FALSE,
                  x_return_status                => x_return_status,
                  x_msg_count                    => x_msg_count,
                  x_msg_data                     => x_msg_data,
                  p_tax_in_rec                   => p_tax_in_tbl(i));
        -- store the highest degree of error
		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_tax_in_tbl.LAST);
        i := p_tax_in_tbl.NEXT(i);
      END LOOP;
  	  -- return overall status
	  x_return_status := l_overall_status;
    END IF;
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
  	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
    */
    x_return_status := l_return_status;

   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PROCESS_TAX.Create_Tax_Schedule ','End(-)');
  END IF;
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Create_Tax_Schedule ',
                  'EXCEPTION :'|| 'OKL_API.G_EXCEPTION_ERROR');
   END IF;
   x_return_status := OKL_API.G_RET_STS_ERROR;
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Create_Tax_Schedule ',
                  'EXCEPTION :'|| 'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
   END IF;
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
   IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PROCESS_TAX.Create_Tax_Schedule ',
                  'EXCEPTION :'||sqlerrm);
   END IF;
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- unexpected error
   OKL_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
END Create_Tax_Schedule;

END OKL_PROCESS_TAX;



/
