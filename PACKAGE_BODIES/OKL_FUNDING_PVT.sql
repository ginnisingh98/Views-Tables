--------------------------------------------------------
--  DDL for Package Body OKL_FUNDING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FUNDING_PVT" AS
/* $Header: OKLCFUNB.pls 120.67.12010000.4 2010/02/18 01:51:07 rpillay ship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
-- see FND_NEW_MESSAGES for full message text
G_NOT_FOUND                  CONSTANT VARCHAR2(30) := 'OKC_NOT_FOUND';  -- message_name
G_NOT_FOUND_V1               CONSTANT VARCHAR2(30) := 'VALUE1';         -- token 1
G_NOT_FOUND_V2               CONSTANT VARCHAR2(30) := 'VALUE2';         -- token 2

G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

G_NO_INIT_MSG                CONSTANT VARCHAR2(1)  := OKL_API.G_FALSE;
G_VIEW                       CONSTANT VARCHAR2(30) := 'OKL_TRX_AP_INVOICES_V';

G_FND_APP                    CONSTANT VARCHAR2(30) := OKL_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(30) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(30) := OKL_API.G_FORM_RECORD_DELETED;
G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(30) := OKL_API.G_FORM_RECORD_CHANGED;
G_RECORD_LOGICALLY_DELETED	 CONSTANT VARCHAR2(30) := OKL_API.G_RECORD_LOGICALLY_DELETED;
G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(30) := OKL_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(30) := OKL_API.G_CHILD_TABLE_TOKEN;
G_NO_PARENT_RECORD           CONSTANT VARCHAR2(30) :='OKL_NO_PARENT_RECORD';
G_NOT_SAME                   CONSTANT VARCHAR2(30) :='OKL_CANNOT_BE_SAME';

G_PREFUNDING_TYPE            CONSTANT VARCHAR2(30) :='PREFUNDING';
G_ASSET_TYPE                 CONSTANT VARCHAR2(30) :='ASSET';
G_INVOICE_TYPE               CONSTANT VARCHAR2(30) :='INVOICE';
G_FUNDING_TRX_TYPE           CONSTANT VARCHAR2(30) :='FUNDING';

 G_CREDIT_CHKLST_TPL CONSTANT VARCHAR2(30) := 'LACCLH';
 G_CREDIT_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LACCLT';
 G_CREDIT_CHKLST_TPL_RULE2 CONSTANT VARCHAR2(30) := 'LACCLD';
 G_CREDIT_CHKLST_TPL_RULE3 CONSTANT VARCHAR2(30) := 'LACLFD';

 G_FUNDING_CHKLST_TPL CONSTANT VARCHAR2(30) := 'LAFCLH';
-- G_FUNDING_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LAFCLT';
 G_FUNDING_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LAFCLD';
 G_RGP_TYPE CONSTANT VARCHAR2(30) := 'KRG';

--cklee added user defined stream type modification
 G_STY_PURPOSE_CODE_PREFUNDING        CONSTANT VARCHAR2(30) := 'PREFUNDING';
 G_STY_PURPOSE_CODE_FUNDING           CONSTANT VARCHAR2(30) := 'FUNDING';
 G_STY_PURPOSE_CODE_P_BALANCE         CONSTANT VARCHAR2(30) := 'PRINCIPAL_BALANCE';
--cklee added user defined stream type modification
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
 G_OKL_LEASE_APP        CONSTANT VARCHAR2(30) := 'OKL_LEASE_APP';
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

/*
-- vthiruva, 08/31/2004
-- Added Constants to enable Business Event
*/
G_WF_EVT_FUN_REQ_CREATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.funding_request.created';
G_WF_EVT_FUN_REQ_UPDATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.funding_request.updated';
G_WF_EVT_FUN_REQ_CANCELLED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.funding_request.cancelled';
G_WF_EVT_FUN_REQ_SUBMITTED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.funding_request.submitted';
G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30) := 'CONTRACT_ID';
G_WF_ITM_FUN_REQ_ID CONSTANT VARCHAR2(30) := 'FUNDING_REQUEST_ID';
/*
-- cklee, 12/21/2005
-- Added Constants to enable Business Event bug#4901292
*/
--START: 04-Jan-2006  cklee -- Fixed bug#4925269                                    |
G_WF_EVT_FUN_LIST_VALIDATED CONSTANT VARCHAR2(250) := 'oracle.apps.okl.sales.leaseapplication.validated_funding_request';
--END: 04-Jan-2006  cklee -- Fixed bug#4925269                                    |

----------------------------------------------------------------------------
-- Data Structures
----------------------------------------------------------------------------

  subtype rgpv_rec_type is okl_okc_migration_pvt.rgpv_rec_type;
  subtype rgpv_tbl_type is okl_okc_migration_pvt.rgpv_tbl_type;
  subtype rulv_rec_type is okl_rule_pub.rulv_rec_type;
  subtype rulv_tbl_type is okl_rule_pub.rulv_tbl_type;

----------------------------------------------------------------------------
-- Private Procedures and Functions
----------------------------------------------------------------------------
  -- Debug messages:
  PROCEDURE msg (text VARCHAR2)
  IS
  BEGIN
    OKL_API.Set_Message(G_APP_NAME,'FND_GENERIC_MESSAGE','MESSAGE', text);
  END;

----------------------------------------------------------------------------
/*
-- vthiruva, 08/31/2004
-- START, Added PROCEDURE to enable Business Event
*/
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : local_procedure, raises business event by making a call to
--                   okl_wf_pvt.raise_event
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--
PROCEDURE raise_business_event(
                p_api_version       IN NUMBER,
                p_init_msg_list     IN VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_khr_id            IN okc_k_headers_b.id%TYPE,
                p_id                IN OKL_TRX_AP_INVOICES_B.id%TYPE,
                p_event_name        IN wf_events.name%TYPE) IS

l_parameter_list        wf_parameter_list_t;
BEGIN
    wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_khr_id,l_parameter_list);
    wf_event.AddParameterToList(G_WF_ITM_FUN_REQ_ID,p_id,l_parameter_list);


    OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
			    p_init_msg_list  => p_init_msg_list,
			    x_return_status  => x_return_status,
			    x_msg_count      => x_msg_count,
			    x_msg_data       => x_msg_data,
			    p_event_name     => p_event_name,
			    p_parameters     => l_parameter_list);

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END raise_business_event;

/*
-- vthiruva, 08/31/2004
-- END, PROCEDURE to enable Business Event
*/

----------------------------------------------------------------------------------

  PROCEDURE create_fund_asset_subsidies
                             (p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_status         IN  OKL_TRX_AP_INVOICES_B.trx_status_code%TYPE,
                              p_fund_id        IN  OKL_TRX_AP_INVOICES_B.ID%TYPE)
  IS

  l_api_name         CONSTANT VARCHAR2(30) := 'create_fund_asset_subsidies';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  j                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_row_found        boolean := false;

  l_tapv_rec        tapv_rec_type;
  x_tapv_rec        tapv_rec_type;
  l_tplv_rec        tplv_rec_type;
  x_tplv_rec        tplv_rec_type;

  -- smadhava - Bug#5200033 - Added - Start
  l_subsidy_line_count NUMBER DEFAULT 0;
  l_tplv_tbl  tplv_tbl_type;
  -- smadhava - Bug#5200033 - Added - End

-- required to create funding request for subsidy
  -- sjalasut, modified the below cursor to have khr_id referred to okl_txl_ap_inv_lns_all_b
  -- instead of okl_trx_ap_invoices_b. changes made as part of OKLR12B disbursements
  -- project
  CURSOR c_khr (p_contract_id  NUMBER)
  IS
  select khr.ID KHR_ID,
         khr.AUTHORING_ORG_ID ORG_ID,
         khr.CURRENCY_CODE,
         tap.ID TAP_ID,
         tap.VENDOR_INVOICE_NUMBER,
         tap.IPVS_ID,
         tap.PAYMENT_METHOD_CODE,
         -SUM(NVL(OKL_FUNDING_PVT.get_partial_subsidy_amount(tpl.KLE_ID, tpl.AMOUNT),0)) SUBSIDY_TOT_AMT
  from   okc_k_headers_b khr,
         okl_trx_ap_invoices_b tap,
         okl_txl_ap_inv_lns_all_b  tpl
  where  khr.id = tpl.khr_id
  and    tap.id = tpl.tap_id
  and    tap.id = p_fund_id
  and    tap.funding_type_code = 'ASSET'
  and    OKL_FUNDING_PVT.get_partial_subsidy_amount(tpl.kle_id, tpl.amount) > 0
  group by khr.ID,
           khr.AUTHORING_ORG_ID,
           khr.CURRENCY_CODE,
           tap.VENDOR_INVOICE_NUMBER,
           tap.ID,
           tap.IPVS_ID,
           tap.PAYMENT_METHOD_CODE
  ;

-- assets request
cursor c_fund_asset(p_fund_id OKL_TRX_AP_INVOICES_B.ID%TYPE) is
  select ast.KLE_ID,
         ast.AMOUNT
from OKL_TXL_AP_INV_LNS_B ast
where ast.TAP_ID = p_fund_id;


    r_khr c_khr%ROWTYPE;
    x_asbv_tbl OKL_SUBSIDY_PROCESS_PVT.asbv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT create_fund_asset_subsidies;

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


--*** Begin API body ****************************************************
-------------------------------------------------------------------------
-- 1. create funding asset subsidy internal AP header
-------------------------------------------------------------------------
  -- Get the internal invoice Details
  OPEN  c_khr(p_fund_id);
  FETCH c_khr INTO r_khr;
  l_row_found := c_khr%FOUND;
  CLOSE c_khr;

  -- if subsidy found
  IF (l_row_found) THEN

    -- sjalasut, not commenting the khr_id reference in l_tapv_rec here as this
    -- record variable is used as a parameter for validate_header_attributes,
    -- validate_funding_request etc. since per the disbursements FDD, tapv_rec
    -- .khr_id would continue to exist, not making this change would not cause
    -- compilation issues.
    -- the actual change of populating the khr_id at tplv_rec level is taken
    -- care in the procedure create_funding_header and create_fund_asset_subsidies
    l_tapv_rec.KHR_ID := r_khr.khr_id;
    l_tapv_rec.AMOUNT := r_khr.subsidy_tot_amt;
    l_tapv_rec.FUNDING_TYPE_CODE := G_ASSET_SUBSIDY;
    l_tapv_rec.IPVS_ID := r_khr.ipvs_id;
    l_tapv_rec.ORG_ID := r_khr.org_id;

    l_tapv_rec.TRX_STATUS_CODE := G_APPROVED;
    l_tapv_rec.DATE_FUNDING_APPROVED := SYSDATE;
--  l_tapv_rec.VENDOR_INVOICE_NUMBER := TRIM(SUBSTR(r_khr.vendor_invoice_number,1,20)) || '''' || 'subsidies';

    l_tapv_rec.CURRENCY_CODE := r_khr.currency_code;

    l_tapv_rec.PAYMENT_METHOD_CODE := r_khr.PAYMENT_METHOD_CODE;

    l_tapv_rec.DATE_ENTERED := sysdate;
    l_tapv_rec.DATE_INVOICED := sysdate;
    l_tapv_rec.DATE_GL := sysdate;
    l_tapv_rec.ASSET_TAP_ID := r_khr.tap_id;
--      l_tapv_rec.VENDOR_ID := r_khr.vendor_id;

    -- sjalasut, modified invoice_type from G_STANDARD to G_CREDIT
    -- changes made as part of OKLR12B disbursements project
    l_tapv_rec.INVOICE_TYPE := G_CREDIT;

    create_funding_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-----------------------------------------------------------------------
-- 2. get assets by funding request id
-----------------------------------------------------------------------
    FOR r_ast IN c_fund_asset(p_fund_id) LOOP

      j := 1;
      -------------------------------------------------------------------
      -- get subsidies by asset and request amount
      -------------------------------------------------------------------
      OKL_SUBSIDY_PROCESS_PVT.get_partial_subsidy_amount(
        p_api_version     => l_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_asset_cle_id    => r_ast.kle_id,
        p_req_fund_amount => r_ast.amount,
        x_asbv_tbl        => x_asbv_tbl
      );

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -------------------------------------------------------------------
      -- if subsidies found
      -------------------------------------------------------------------
      IF (x_asbv_tbl.COUNT > 0) THEN
        i := x_asbv_tbl.FIRST;

        LOOP

          -------------------------------------------------------------------
          -- create internal AP line for each subsidy
          -------------------------------------------------------------------
          l_tplv_rec.inv_distr_line_code := 'ITEM';
          l_tplv_rec.tap_id := x_tapv_rec.id;

          -- sjalasut, added khr_id to the line. changes made as part of
          -- OKLR12B disbursements project
          l_tplv_rec.khr_id := r_khr.khr_id;

          l_tplv_rec.kle_id := r_ast.kle_id; -- asset_id, not subsidy_id

          -- smadhava - Bug#5200033 - Added - Start
          -- Round the amount to the System Options setup
          l_tplv_rec.amount := OKL_ACCOUNTING_UTIL.round_amount(p_amount        => x_asbv_tbl(i).amount
                                                              , p_currency_code => l_tapv_rec.CURRENCY_CODE);
          l_tplv_rec.amount := -l_tplv_rec.amount;
--          l_tplv_rec.amount := -x_asbv_tbl(i).amount;
          -- smadhava - Bug#5200033 - Added - End

          l_tplv_rec.org_id := r_khr.org_id;
          l_tplv_rec.line_number := j;
          l_tplv_rec.DISBURSEMENT_BASIS_CODE := 'BILL_DATE';

          l_tplv_rec.sty_id := x_asbv_tbl(i).stream_type_id;

          OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_tplv_rec      => l_tplv_rec,
            x_tplv_rec      => x_tplv_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- smadhava - Bug#5200033 - Added - Start
          -- Create a table of records of the AP subsidy lines to synchronize the header amount
          l_tplv_tbl(l_subsidy_line_count) := x_tplv_rec;
          l_subsidy_line_count := l_subsidy_line_count + 1;
          -- smadhava - Bug#5200033 - Added - End

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
/*
          -------------------------------------------------------------------
          -- create internal Accounting entry for each subsidy
          -------------------------------------------------------------------
          OKL_FUNDING_PVT.CREATE_ACCOUNTING_DIST(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_status        => l_tapv_rec.trx_status_code,
            p_fund_id       => x_tapv_rec.id,
            p_fund_line_id  => x_tplv_rec.id,
            p_subsidy_amt   => l_tplv_rec.amount,
            p_sty_id        => l_tplv_rec.sty_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
*/
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

          EXIT WHEN (i = x_asbv_tbl.LAST);
          i := x_asbv_tbl.NEXT(i);

        END LOOP; -- for each subsidy
      END IF;
      j := j+1;

    END LOOP; -- for each asset

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
    -------------------------------------------------------------------
    -- create internal Accounting for a funding header
    -------------------------------------------------------------------
    OKL_FUNDING_PVT.CREATE_ACCOUNTING_DIST(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_status        => l_tapv_rec.trx_status_code,
            p_fund_id       => x_tapv_rec.id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

    -- smadhava - Bug#5200033 - Added - Start
    -- Synchronize the header record amount as the line record amounts have been
    -- rounded to precision of the currency
    SYNC_HEADER_AMOUNT(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    -- smadhava - Bug#5200033 - Added - End


  END IF; -- if subsidy found

--*** End API body ******************************************************

  -- Get message count and if count is 1, get message info

	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

  END create_fund_asset_subsidies;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_funding_chklst_tpl
-- Description     : wrapper api for create funding checklist FK associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_funding_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
   ,p_fund_req_id                  IN  okl_trx_ap_invoices_b.id%type
   ,p_creditline_id                IN  okc_k_headers_b.id%type DEFAULT NULL
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_funding_chklst_tpl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_rgpv_rec        rgpv_rec_type;
  lp_rulv_rec        rulv_rec_type;
  lx_rgpv_rec        rgpv_rec_type;
  lx_rulv_rec       rulv_rec_type;
  l_crd_row_not_found   boolean;
  l_grp_row_not_found   boolean;
  l_expired_row_found   boolean;

  l_dummy number;
  l_rgpv_id okc_rule_groups_b.id%type;
  l_todo_item_code   okl_crd_fund_checklists_tpl_uv.TODO_ITEM_CODE%type;
  l_mandatory_flag   okl_crd_fund_checklists_tpl_uv.mandatory_flag%type;
  l_note             okl_crd_fund_checklists_tpl_uv.note%type;
  l_status           okl_crd_fund_checklists_tpl_uv.status%type;
  l_fund_cls_tpl_exp_found   boolean;
  l_chklist_sts_row_found   boolean;


  l_template_row_not_found  boolean;

  l_credit_id okc_k_headers_b.id%TYPE;

    l_funding_checklist_tpl okc_rules_b.rule_information2%TYPE;
    l_checklists_row_found boolean;
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
  l_function_id           okl_crd_fund_checklists_tpl_uv.function_id%type;
  l_checklist_type        okl_crd_fund_checklists_tpl_uv.checklist_type%type;
  l_lease_app_id number;
  l_lease_app_found boolean;
  l_lease_app_list_found boolean;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
--------------------------------------------------------------------------------------------
-- Checklists link check
--------------------------------------------------------------------------------------------
CURSOR c_checklists (p_credit_id  NUMBER)
  IS
  select rule.rule_information2
  from okc_rules_b rule
  where rule.dnz_chr_id = p_credit_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;

---------------------------------------------------------------------------------------------------
-- Funded contract group
---------------------------------------------------------------------------------------------------
cursor c_grp (p_chr_id number) is
  select rgp.id
from okc_rule_groups_b rgp
where rgp.dnz_chr_id = p_chr_id
and rgp.RGD_CODE = G_FUNDING_CHKLST_TPL
;

---------------------------------------------------------------------------------------------------
-- funding request checklist template at credit line level
---------------------------------------------------------------------------------------------------
cursor c_chk_tpl2 (p_credit_id number) is
select
  tpl.TODO_ITEM_CODE,
  nvl(tpl.MANDATORY_FLAG, 'N'),
  tpl.NOTE,
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
-- commented out tpl.STATUS
  tpl.FUNCTION_ID,
  tpl.CHECKLIST_TYPE
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
from okl_crd_fund_checklists_tpl_uv tpl
where tpl.khr_id = p_credit_id
;

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
---------------------------------------------------------------------------------------------------------
-- check if the contract was created from a lease application
---------------------------------------------------------------------------------------------------------
CURSOR c_lease_app (p_chr_id okc_k_headers_b.id%type)
IS
  select chr.ORIG_SYSTEM_ID1
from  okc_k_headers_b chr
where ORIG_SYSTEM_SOURCE_CODE = G_OKL_LEASE_APP
and   chr.id = p_chr_id
;

---------------------------------------------------------------------------------------------------
-- funding request checklist refer from a Lease application
---------------------------------------------------------------------------------------------------
cursor c_chk_lease_app (p_lease_app_id number) is
select
  chk.TODO_ITEM_CODE,
  NVL(chk.MANDATORY_FLAG, 'N') MANDATORY_FLAG,
  chk.USER_NOTE,
  chk.FUNCTION_ID,
  chk.INST_CHECKLIST_TYPE
from OKL_CHECKLIST_DETAILS chk
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
     ,okl_checklists hdr
where chk.ckl_id = hdr.id
and hdr.CHECKLIST_OBJ_ID = p_lease_app_id
--where chk.DNZ_CHECKLIST_OBJ_ID = p_lease_app_id
--END:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
and chk.INST_CHECKLIST_TYPE = 'FUNDING'
;

cursor c_lease_app_list_exists (p_lease_app_id number) is
select 1
from OKL_CHECKLIST_DETAILS chk
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
     ,okl_checklists hdr
where chk.ckl_id = hdr.id
and hdr.CHECKLIST_OBJ_ID = p_lease_app_id
--where chk.DNZ_CHECKLIST_OBJ_ID = p_lease_app_id
--END:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
and chk.INST_CHECKLIST_TYPE = 'FUNDING'
;

-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

begin
  -- Set API savepoint
  SAVEPOINT create_funding_chklst_tpl;

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

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
  OPEN c_lease_app(p_chr_id);
  FETCH c_lease_app INTO l_lease_app_id;
  l_lease_app_found := c_lease_app%FOUND;
  CLOSE c_lease_app;


  IF l_lease_app_id IS NOT NULL THEN

    OPEN c_lease_app_list_exists(l_lease_app_id);
    FETCH c_lease_app_list_exists INTO l_dummy;
    l_lease_app_list_found := c_lease_app_list_exists%FOUND;
    CLOSE c_lease_app_list_exists;

  END IF;

  IF NOT l_lease_app_found THEN
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

-- get credit line id
-- fixed bug if contract credit line has been changed, but funding requests
-- still have not been apporved. We need to re-generate list from the
-- new credit line
    IF (p_creditline_id IS NOT NULL) THEN
      l_credit_id := p_creditline_id;
    ELSE
      l_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_chr_id);
    END IF;

-- get source checklist template ID

    OPEN c_checklists(l_credit_id);
    FETCH c_checklists INTO l_funding_checklist_tpl;
    l_checklists_row_found := c_checklists%FOUND;
    CLOSE c_checklists;

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
  END IF;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

/*
---------------------------------------------------------------------------------------------------
1. create rule group
2. create rule1 : get the source of the checklist template lists
3. create rules based on #2. cursor
---------------------------------------------------------------------------------------------------
*/
---------------------------------------------------------------------------------------------------
--1. create rule group
---------------------------------------------------------------------------------------------------
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
--  IF (l_funding_checklist_tpl IS NOT NULL) THEN
  IF ( (NOT l_lease_app_found  AND l_funding_checklist_tpl IS NOT NULL) or
       (l_lease_app_found  AND l_lease_app_list_found)
     ) THEN
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |


    open c_grp(p_chr_id);
    fetch c_grp into l_rgpv_id;

    l_grp_row_not_found := c_grp%NOTFOUND;
    close c_grp;

    IF (l_grp_row_not_found) THEN

      lp_rgpv_rec.DNZ_CHR_ID := p_chr_id;
      lp_rgpv_rec.CHR_ID := p_chr_id;
  --    lp_rgpv_rec.CLE_ID := p_fund_req_id;
      lp_rgpv_rec.RGD_CODE := G_FUNDING_CHKLST_TPL;
      lp_rgpv_rec.RGP_TYPE := G_RGP_TYPE;

      okl_rule_pub.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_rgpv_rec,
        x_rgpv_rec       => lx_rgpv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

      l_rgpv_id := lx_rgpv_rec.id;
    END IF;
---------------------------------------------------------------------------------------------------
--2. create rule1 : get the source of the checklist template lists
--3. create rules based on #2. cursor
---------------------------------------------------------------------------------------------------
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
    IF NOT l_lease_app_found  AND l_funding_checklist_tpl IS NOT NULL THEN
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |


      OPEN c_chk_tpl2(l_credit_id);
      LOOP

        FETCH c_chk_tpl2 INTO l_todo_item_code,
                              l_mandatory_flag,
                              l_note,
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
--                              l_status;
                              l_function_id,
                              l_checklist_type;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

        EXIT WHEN c_chk_tpl2%NOTFOUND;

        lp_rulv_rec.OBJECT1_ID1 := p_fund_req_id;
        lp_rulv_rec.OBJECT1_ID2 := '#';
        lp_rulv_rec.RGP_ID := l_rgpv_id;
        lp_rulv_rec.DNZ_CHR_ID := p_chr_id;
        lp_rulv_rec.RULE_INFORMATION_CATEGORY := G_FUNDING_CHKLST_TPL_RULE1;
        lp_rulv_rec.STD_TEMPLATE_YN := 'N';
        lp_rulv_rec.WARN_YN := 'N';
        lp_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
        lp_rulv_rec.RULE_INFORMATION2 := l_mandatory_flag;
        lp_rulv_rec.RULE_INFORMATION3 := 'N';
        lp_rulv_rec.RULE_INFORMATION4 := l_note;
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
        lp_rulv_rec.RULE_INFORMATION5 := 'NEW'; -- set default checklist status
        lp_rulv_rec.RULE_INFORMATION9 := l_function_id;
        lp_rulv_rec.RULE_INFORMATION10 := l_checklist_type;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

        okl_rule_pub.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      END LOOP;
      CLOSE c_chk_tpl2;
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
    ELSIF l_lease_app_found  AND l_lease_app_list_found THEN

      FOR r_this_row IN c_chk_lease_app(l_lease_app_id) LOOP

        lp_rulv_rec.OBJECT1_ID1 := p_fund_req_id;
        lp_rulv_rec.OBJECT1_ID2 := '#';
        lp_rulv_rec.RGP_ID := l_rgpv_id;
        lp_rulv_rec.DNZ_CHR_ID := p_chr_id;
        lp_rulv_rec.RULE_INFORMATION_CATEGORY := G_FUNDING_CHKLST_TPL_RULE1;
        lp_rulv_rec.STD_TEMPLATE_YN := 'N';
        lp_rulv_rec.WARN_YN := 'N';
        lp_rulv_rec.RULE_INFORMATION1 := r_this_row.todo_item_code;
        lp_rulv_rec.RULE_INFORMATION2 := r_this_row.mandatory_flag;
        lp_rulv_rec.RULE_INFORMATION3 := 'N';
        lp_rulv_rec.RULE_INFORMATION4 := r_this_row.user_note;
-- automatically activate this checklist if the checklist was copy from a lease application's checklist
        lp_rulv_rec.RULE_INFORMATION5 := 'ACTIVE';

        lp_rulv_rec.RULE_INFORMATION9 := r_this_row.function_id;
        lp_rulv_rec.RULE_INFORMATION10 := r_this_row.inst_checklist_type;

        okl_rule_pub.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      END LOOP;
    END IF;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

  END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

end create_funding_chklst_tpl;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : refresh_fund_chklst
-- Description     : Refresh funding checklist if user have changed credit line
--                   for associated contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE refresh_fund_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
   ,p_MLA_id                       IN  okc_k_headers_b.id%type
   ,p_creditline_id            IN  okc_k_headers_b.id%type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'refresh_fund_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_old_credit_id    okc_k_headers_b.id%TYPE;
  l_funded_amout     NUMBER := 0;
  l_fund_req_id      okl_trx_ap_invoices_b.id%type;

  l_refresh_flag     boolean := false;
  l_rule_id          okc_rules_b.id%type;
  ldel_rulv_rec      rulv_rec_type;
  l_final_creditline_id okc_k_headers_b.id%type;
  l_MLA_creditline_id okc_k_headers_b.id%type;
--START: CKLEE 01/04/06
--  l_MLA_creditline_not_found boolean := false;
  l_MLA_creditline_found boolean := false;
--END: CKLEE 01/04/06

  l_dummy              number;
  l_approved_req_not_found boolean := false;

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
  l_lease_app_found boolean;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

CURSOR c_MLA_credit (p_MLA_id NUMBER)
  IS
select a.ID
from   OKC_K_HEADERS_B a,
       okc_Governances_v g
where  a.id = g.chr_id_referred
and    a.sts_code = 'ACTIVE'
and    a.scs_code = 'CREDITLINE_CONTRACT'
and    g.dnz_chr_id = p_MLA_id
;

--4. Check if associated funding requests exist
-- sjalasut, modified the cursor to have khr_id referred from okl_txl_ap_inv_lns_all_b
-- instead of okl_trx_ap_invoices_b. changes made as part of OKLR12B disburesments
-- project.
cursor c_fund_req(p_chr_id NUMBER) is
select fr.id
from OKL_TRX_AP_INVOICES_B fr
    ,okl_txl_ap_inv_lns_all_b b
where fr.id = b.tap_id
and   b.khr_id = p_chr_id
and   fr.trx_status_code = 'ENTERED'
;

--5. Delete all associated list by chr_id if any
cursor c_fund_req_list(p_chr_id NUMBER) is
--start modified abhsaxen for performance SQLID 20562295
SELECT rult.ID
FROM okc_rules_b rult
WHERE rult.rule_information_category = 'LAFCLD'
and rult.dnz_chr_id = p_chr_id
;
--end modified abhsaxen for performance SQLID 20562295


--6. Check if associated approved funding requests exist
-- sjalasut, modified the cursor to have khr_id referred from okl_txl_ap_inv_lns_all_b
-- instead of okl_trx_ap_invoices_b. changes made as part of OKLR12B disburesments
-- project.
cursor c_approved_req(p_chr_id NUMBER) is
select 1
from OKL_TRX_AP_INVOICES_B fr
    ,okl_txl_ap_inv_lns_all_b b
where fr.id = b.tap_id
  and b.khr_id = p_chr_id
  and fr.trx_status_code in ('APPROVED','PROCESSED')
;

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
---------------------------------------------------------------------------------------------------------
-- 5. check if the contract was created from a lease application
---------------------------------------------------------------------------------------------------------
CURSOR c_lease_app (p_chr_id okc_k_headers_b.id%type)
IS
--start modified abhsaxen for Performance SQLID 20562299
select 1
from  okc_k_headers_b chr
where ORIG_SYSTEM_SOURCE_CODE = G_OKL_LEASE_APP
and chr.id = p_chr_id
;
--end modified abhsaxen for Performance SQLID 20562299
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

BEGIN
  -- Set API savepoint
  SAVEPOINT refresh_fund_chklst;

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

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
  OPEN c_lease_app(p_chr_id);
  FETCH c_lease_app INTO l_dummy;
  l_lease_app_found := c_lease_app%FOUND;
  CLOSE c_lease_app;

  IF NOT l_lease_app_found THEN
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

/*
------------------------------------------------------------------------
0.1) find out if credit line has been changed
..
1. Passed in p_chr_id and p_creditline_id can not be NULL
2. Check if creditline is changed
3. Check if associated funding requests have not been approved

4. Check if associated funding requests exists
5. Delete all associated list by chr_id
6. Loop for funding requests
     call create_funding_chklst_tpl(p_chr_id, p_fund_req_id,p_creditline_id);
   end loop;
------------------------------------------------------------------------
*/

    IF (p_chr_id IS NOT NULL AND p_chr_id <> OKL_API.G_MISS_NUM) THEN

      -----------------------------------------------------------------
      -- get credit line id
      -----------------------------------------------------------------
      -- get old credit line id if exists
      l_old_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_chr_id);

      -- 1st to get new credit line id if there is any
      -- 1. old list <> new list
      -- 2. No old list, create a new list
      IF ((p_creditline_id IS NOT NULL AND
           p_creditline_id <> OKL_API.G_MISS_NUM AND
           l_old_credit_id IS NOT NULL AND
           l_old_credit_id <> p_creditline_id)
          OR
          (l_old_credit_id IS NULL AND
           p_creditline_id IS NOT NULL AND
           p_creditline_id <> OKL_API.G_MISS_NUM)
         ) THEN

        l_refresh_flag := true;
        l_final_creditline_id := p_creditline_id;

      END IF;

      IF ( p_creditline_id IS NULL OR
           p_creditline_id = OKL_API.G_MISS_NUM) THEN

        --------------------------------------------------------------------------------
        -- 1. p_MLA_id could be NULL
        -- 2. MLA doesn't have credit line attached
        -- 3. MLA has credit line attached, but no list associated with that credit line
        ---------------------------------------------------------------------------------
        OPEN c_MLA_credit(p_MLA_id);
        FETCH c_MLA_credit INTO l_MLA_creditline_id;
--START: CKLEE 01/04/06
--        l_MLA_creditline_not_found := c_MLA_credit%NOTFOUND;
        l_MLA_creditline_found := c_MLA_credit%FOUND;
--END: CKLEE 01/04/06
        close c_MLA_credit;

--START: CKLEE 01/04/06
--        IF (l_MLA_creditline_not_found OR
        IF (l_MLA_creditline_found OR
--END: CKLEE 01/04/06
           (l_old_credit_id IS NULL AND
            l_MLA_creditline_id IS NOT NULL) OR
           (l_old_credit_id IS NOT NULL AND
            l_MLA_creditline_id IS NOT NULL AND
            l_old_credit_id <> l_MLA_creditline_id)
           ) THEN

          l_refresh_flag := true;
          l_final_creditline_id := l_MLA_creditline_id;

        END IF;

      END IF;

      IF (l_refresh_flag = true) THEN

        -----------------------------------------------------------------
        -- Delete associated checklists by chr_id if ANY
        -----------------------------------------------------------------
        -- no approved requests exists
        --3. Check if associated funding requests have not been approved
        OPEN c_approved_req(p_chr_id);
        FETCH c_approved_req INTO l_dummy;
        l_approved_req_not_found := c_approved_req%NOTFOUND;
        close c_approved_req;

        IF ( l_approved_req_not_found ) THEN

          open c_fund_req_list(p_chr_id);
          LOOP

            fetch c_fund_req_list into l_rule_id;
            EXIT WHEN c_fund_req_list%NOTFOUND;

            ldel_rulv_rec.ID := l_rule_id;

            okl_rule_pub.delete_rule(
              p_api_version    => p_api_version,
              p_init_msg_list  => p_init_msg_list,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_rulv_rec       => ldel_rulv_rec);

            If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
              raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
              raise OKC_API.G_EXCEPTION_ERROR;

            End If;

          END LOOP;
          close c_fund_req_list;

        END IF;

        -----------------------------------------------------------------
        -- Create associated checklists by chr_id, fund_req_id if ANY
        -----------------------------------------------------------------
        IF (l_final_creditline_id IS NOT NULL) THEN

          OPEN c_fund_req(p_chr_id);
          -- Funding requests
          LOOP

            FETCH c_fund_req INTO l_fund_req_id;
            EXIT WHEN c_fund_req%NOTFOUND;

            create_funding_chklst_tpl(
              p_api_version       => p_api_version,
              p_init_msg_list     => p_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_chr_id            => p_chr_id,
              p_fund_req_id       => l_fund_req_id,
              p_creditline_id     => l_final_creditline_id);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END LOOP;-- Funding requests
        CLOSE c_fund_req;

        END IF; -- IF (l_final_creditline_id IS NOT NULL) THEN

      END IF; -- IF (l_refresh_flag = true) THEN

    END IF; -- p_chr_id check

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
  END IF; -- IF NOT l_lease_app_found THEN
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PVT;
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

END refresh_fund_chklst;

--------------------------------------------------------------------------------
----------------------------------CREATE_ACCOUNTING_DIST------------------------
--------------------------------------------------------------------------------
  PROCEDURE CREATE_ACCOUNTING_DIST(p_api_version      IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_status         IN  OKL_TRX_AP_INVOICES_B.trx_status_code%TYPE,
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
                              p_fund_id        IN  OKL_TRX_AP_INVOICES_B.ID%TYPE ) IS --,
/*
-- cklee 11.5.10 subsidy
                              p_fund_line_id   IN  OKL_TXL_AP_INV_LNS_B.ID%TYPE,
                              p_subsidy_amt    IN  NUMBER,
                              p_sty_id         IN  NUMBER) IS
*/
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

    l_api_name   CONSTANT VARCHAR2(30) := 'CREATE_ACCOUNTING_DIST';
    l_tapv_rec            tapv_rec_type;
    x_tapv_rec            tapv_rec_type;
    l_chr_id              NUMBER;
    l_funding_type_code   VARCHAR2(30);
    l_product_id          NUMBER;
    l_trans_id            NUMBER;
    l_stream_id           NUMBER;
    l_name                VARCHAR2(30);
    l_trx_name            VARCHAR2(30);
    l_amount              NUMBER;
    l_cust_trx_type_id    NUMBER;
    l_sales_id            NUMBER;
    l_site_uses_id        NUMBER;

    --Bug# 4622198
    l_scs_code            OKC_K_HEADERS_B.SCS_CODE%TYPE;
    l_fact_synd_code      FND_LOOKUPS.Lookup_code%TYPE;
    l_inv_acct_code       OKC_RULES_B.Rule_Information1%TYPE;
    --Bug# 4622198

    l_cust_acct_site_id   NUMBER;

    l_ipvs_id             NUMBER;

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--    l_tmpl_identify_rec  OKL_ACCOUNT_DIST_PVT.TMPL_IDENTIFY_REC_TYPE;
--    l_dist_info_rec      OKL_ACCOUNT_DIST_PVT.dist_info_REC_TYPE;
--    l_template_tbl       OKL_ACCOUNT_DIST_PVT.AVLV_TBL_TYPE;
--    l_amount_tbl         OKL_ACCOUNT_DIST_PVT.AMOUNT_TBL_TYPE;

--    l_ctxt_val_tbl       OKL_ACCOUNT_DIST_PVT.CTXT_VAL_TBL_TYPE;
--    l_acc_gen_primary_key_tbl OKL_ACCOUNT_DIST_PVT.acc_gen_primary_key;
    l_has_trans          VARCHAR2(1);
    l_org_id             NUMBER;
    l_fund_line_id       NUMBER;

    l_tmpl_identify_tbl     Okl_Account_Dist_Pvt.TMPL_IDENTIFY_TBL_TYPE;
    l_dist_info_tbl         Okl_Account_Dist_Pvt.dist_info_TBL_TYPE;
    l_pdt_id               Okl_k_headers.pdt_id%type;
    l_ctxt_val_tbl          Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_primary_key_tbl  Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
    l_template_tbl             Okl_Account_Dist_Pvt.AVLV_OUT_TBL_TYPE;
    l_amount_tbl               Okl_Account_Dist_Pvt.AMOUNT_OUT_TBL_TYPE;
--    l_fact_synd_code           fnd_lookups.lookup_code%TYPE;
--    l_inv_acct_code            okc_rules_b.RULE_INFORMATION1%TYPE;

--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

    -- sjalasut, modified the below cursor to have khr_id being selected
    -- from okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b
    -- changes made as part of OKLR12B disbursements project
    CURSOR c (p_fund_id  NUMBER)
    IS
    select b.khr_id,
           a.funding_type_code,
           a.ipvs_id,
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
           a.amount,
           a.date_invoiced,
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
           a.org_id
    from okl_trx_ap_invoices_b a
        ,okl_txl_ap_inv_lns_all_b b
    where a.id = b.tap_id
        and a.id = p_fund_id;

    CURSOR pdt_c (p_chr_id  NUMBER)
    IS
    SELECT pdt_id,
           --Bug# 4622198
           scs_code
    FROM  okl_k_headers_full_v chr
    where chr.id = p_chr_id
    ;

    CURSOR trans_csr(p_trx_name VARCHAR2)
    IS
    SELECT id
    FROM  okl_trx_types_tl
    WHERE  name = p_trx_name
    AND language = 'US'
    ;

    CURSOR stream_c(p_name VARCHAR2)
    IS
    SELECT id
    FROM  OKL_STRM_TYPE_V
    where name = p_name
    ;

--
--FINANCIAL_SYSTEM_PARAMETERS



--select mo_global.get_current_org_id() into l_fnd_profile
--    from dual;


--JTF_RS_SALESREPS_MO_V

    Cursor salesP_csr( p_chr_id NUMBER) IS
    select ct.object1_id1
    from   okc_contacts        ct,
           okc_contact_sources csrc,
           okc_k_party_roles_b pty,
           okc_k_headers_b     chr
    where  ct.cpl_id               = pty.id
          and    ct.cro_code             = csrc.cro_code
          and    ct.jtot_object1_code    = csrc.jtot_object_code
          and    ct.dnz_chr_id           =  chr.id
          and    pty.rle_code            = csrc.rle_code
          and    csrc.cro_code           = 'SALESPERSON'
          and    csrc.rle_code           = 'LESSOR'
          and    csrc.buy_or_sell        = chr.buy_or_sell
          and    pty.dnz_chr_id          = chr.id
          and    pty.chr_id              = chr.id
          and    chr.id                  = p_chr_id;


--RA_CUST_TRX_TYPES

    Cursor ra_cust_trx_types_csr( p_chr_id NUMBER) IS
    select cust_trx_type_id
    from ra_cust_trx_types
    where name = 'Invoice-OKL';


--AR_SITE_USES_V
/*
    Cursor ar_site_uses_csr( p_chr_id NUMBER) IS
 select object1_id1 cust_acct_site_id
    from okc_rules_b rul
    where  rul.rule_information_category = 'BTO'
         and exists (select '1'
                     from okc_rule_groups_b rgp
                     where rgp.id = rul.rgp_id
                          and   rgp.rgd_code = 'LABILL'
                          and   rgp.chr_id   = rul.dnz_chr_id
                          and   rgp.chr_id = p_chr_id );
*/
-- OKC/OKS rule migration project 11.5.10
    Cursor ar_site_uses_csr( p_chr_id NUMBER) IS
 select bill_to_site_use_id cust_acct_site_id
    from okc_k_headers_b chr
    where chr.id = p_chr_id;

    -- get sty_id for manual_disb
    -- cklee 05/04/2004
    Cursor manu_disb( p_fund_id NUMBER) IS
 select id, sty_id
    from okl_txl_ap_inv_lns_b txl
    where txl.tap_id = p_fund_id;

     -- Multi Currency Compliance
    CURSOR l_curr_conv_csr( p_khr_id  NUMBER ) IS
        SELECT  khr.currency_code
               ,chr.currency_conversion_type
               ,chr.currency_conversion_rate
               ,chr.currency_conversion_date
        FROM    okl_k_headers chr,
                okc_k_headers_b khr
        WHERE   chr.id = khr.id
        AND     khr.id = p_khr_id;

    r_curr_conv l_curr_conv_csr%ROWTYPE;
--

    --- vpanwar 21/02/2007 Added
    --- get the funding line amount based on funding_line_id
      CURSOR c_amount(p_fund_line_id  NUMBER)  IS
         SELECT nvl(tl.amount,0)
         FROM   okl_txl_ap_inv_lns_b tl
         WHERE tl.id = p_fund_line_id;
    ---- vpanwar 21/02/2007 End

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
      CURSOR c_fund_lines (p_fund_id NUMBER) IS
         SELECT tpl.id,
                tpl.sty_id,
                tpl.amount
         FROM okl_txl_ap_inv_lns_all_b tpl
         WHERE tpl.tap_id = p_fund_id;

      l_date_invoiced okl_trx_ap_invs_all_b.date_invoiced%type;
      l_tap_amount okl_trx_ap_invs_all_b.amount%type;
--      l_fund_line_id okl_txl_ap_inv_lns_all_b.id%type;
      l_sty_id okl_txl_ap_inv_lns_all_b.sty_id%type;
--      l_amount okl_txl_ap_inv_lns_all_b.amount%type;
      cnt NUMBER;

--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name,
                               p_init_msg_list,
                               '_PVT',
                               x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    IF (p_status = 'APPROVED') THEN
      OPEN c(p_fund_id);
      FETCH c INTO l_chr_id,
                   l_funding_type_code,
                   l_ipvs_id,
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
                   l_tap_amount,
                   l_date_invoiced,
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
                   l_org_id;
      CLOSE c;

      OPEN pdt_c(l_chr_id);
      FETCH pdt_c INTO l_product_id,
                       --Bug# 4662198
                       l_scs_code;
      CLOSE pdt_c;

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
-- cklee 11.5.10 subsidy
/*
      IF (l_funding_type_code = G_ASSET_SUBSIDY) THEN
        l_amount := p_subsidy_amt;
      ELSE

      --- vpanwar 21/02/2007 changed
--        /**
        l_amount := nvl(OKL_FUNDING_PVT.get_contract_line_funded_amt(p_fund_id, l_funding_type_code),0);
--        **
        OPEN c_amount(p_fund_line_id);
        FETCH c_amount INTO l_amount;
        CLOSE c_amount;
       --- vpanwar 21/02/2007 end
      END IF;
*/
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |


      IF ( (l_funding_type_code = G_SUPPLIER_RETENTION_TYPE_CODE)
           OR
--           (l_funding_type_code = G_PREFUNDING_TYPE_CODE AND l_amount < 0)
           (l_funding_type_code = G_PREFUNDING_TYPE_CODE AND l_tap_amount < 0)
           OR
-- cklee 11.5.10 subsidy
           (l_funding_type_code = G_ASSET_SUBSIDY)
         )
      THEN
        l_trx_name := G_TRANSACTION_DEBIT_MEMO;

      -- cklee 05/04/2004
      Elsif (l_funding_type_code = G_MANUAL_DISB) THEN
        l_trx_name := G_TRANSACTION_DISBURSEMENT;
      ELSE
        l_trx_name := G_TRANSACTION_FUNDING;
      END IF;

      OPEN trans_csr(l_trx_name);
      FETCH trans_csr INTO l_trans_id;
      CLOSE trans_csr;

      IF (l_funding_type_code = G_PREFUNDING_TYPE_CODE) THEN
        l_name := G_STY_PURPOSE_CODE_PREFUNDING;
      ELSIF (l_funding_type_code = G_BORROWER_PAYMENT_TYPE_CODE) THEN
        l_name := G_STY_PURPOSE_CODE_P_BALANCE;
--10-22-2004
      ELSIF (l_funding_type_code = G_ASSET_TYPE) THEN
-- start: comment out by cklee: 10/07/2004
--      ELSE
        l_name := G_STY_PURPOSE_CODE_FUNDING;
-- end: comment out by cklee: 10/07/2004
      END IF;

/* cklee: comment out 09/15/2004
      OPEN  stream_c(l_name);
      FETCH  stream_c INTO l_stream_id;
      CLOSE  stream_c;
*/

-- cklee: user defined stream changes
      IF (l_funding_type_code = G_BORROWER_PAYMENT_TYPE_CODE) THEN

        Okl_Streams_Util.GET_DEPENDENT_STREAM_TYPE(
               p_khr_id                => l_chr_id,
               p_primary_sty_purpose   => 'RENT',
               p_dependent_sty_purpose => l_name,
               x_return_status         => x_return_status,
               x_dependent_sty_id      => l_stream_id );

--      ELSE
--10-22-2004
      ELSIF (l_funding_type_code in (G_PREFUNDING_TYPE_CODE, G_ASSET_TYPE)) THEN

        Okl_Streams_Util.GET_PRIMARY_STREAM_TYPE(
               p_khr_id              => l_chr_id,
               p_primary_sty_purpose => l_name,
               x_return_status       => x_return_status,
               x_primary_sty_id      => l_stream_id );

      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
-- cklee: user defined stream changes


--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
/*
-- cklee 11.5.10 subsidy
      IF (l_funding_type_code = G_ASSET_SUBSIDY) THEN
        l_stream_id := p_sty_id;

      -- cklee 05/04/2004
-- cklee: 10/07/2004
-- added Expense and Supplier rentation funding type
      ELSIF (l_funding_type_code in (G_MANUAL_DISB, G_SUPPLIER_RETENTION_TYPE_CODE, G_EXPENSE)) THEN

        OPEN manu_disb(p_fund_id);
        FETCH manu_disb INTO l_fund_line_id, l_stream_id;
        CLOSE manu_disb;

      END IF;
*/
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
-- Major changes:
-- 1. Change the logic to fit in the new spec of accounting API
-- 2. Call OKL_SECURITIZATION_PVT.Check_Khr_ia_associated only once for a funding header
-- 3. Call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST only once for a funding header
--
      -- We need to call once per khr_id
      Okl_Securitization_Pvt.check_khr_ia_associated(p_api_version => p_api_version
                                                ,p_init_msg_list => p_init_msg_list
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => x_msg_count
                                                ,x_msg_data => x_msg_data
                                                ,p_khr_id =>  l_chr_id
                                                ,p_scs_code => NULL
                                                ,p_trx_date => l_date_invoiced
                                                ,x_fact_synd_code => l_fact_synd_code
                                                ,x_inv_acct_code => l_inv_acct_code);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      cnt := 0;
      FOR r_this IN c_fund_lines (p_fund_id) LOOP

        IF (l_funding_type_code in (G_ASSET_SUBSIDY,
	                            G_MANUAL_DISB,
	                            G_SUPPLIER_RETENTION_TYPE_CODE,
								G_EXPENSE)) THEN
          l_stream_id := r_this.sty_id;
        END IF;

        l_tmpl_identify_tbl(cnt).PRODUCT_ID := l_product_id;
        l_tmpl_identify_tbl(cnt).TRANSACTION_TYPE_ID := l_trans_id;
        l_tmpl_identify_tbl(cnt).STREAM_TYPE_ID := l_stream_id;

        l_tmpl_identify_tbl(cnt).MEMO_YN := 'N';
        l_tmpl_identify_tbl(cnt).PRIOR_YEAR_YN := 'N';
        l_tmpl_identify_tbl(cnt).factoring_synd_flag := l_fact_synd_code;
        l_tmpl_identify_tbl(cnt).investor_code       := l_inv_acct_code;

--    l_dist_info_rec.SOURCE_ID := p_fund_id;
-- cklee 11.5.10 subsidy

--- vpanwar 21/02/2007 Changed
    /**
    IF (l_funding_type_code = G_ASSET_SUBSIDY) THEN

      l_dist_info_rec.SOURCE_ID := p_fund_line_id;
      l_dist_info_rec.SOURCE_TABLE := G_OKL_SUBSIDY_SOURCE_TABLE;
    ELSIF (l_funding_type_code = G_MANUAL_DISB) THEN

      l_dist_info_rec.SOURCE_ID := l_fund_line_id;
      l_dist_info_rec.SOURCE_TABLE := G_OKL_MANUAL_DISB_SOURCE_TABLE;
    ELSE
      l_dist_info_rec.SOURCE_ID := p_fund_id;
      l_dist_info_rec.SOURCE_TABLE := G_OKL_FUNDING_SOURCE_TABLE;
    END IF;
    **/

        l_dist_info_tbl(cnt).SOURCE_ID := r_this.id;
        l_dist_info_tbl(cnt).SOURCE_TABLE := G_OKL_FUNDING_SOURCE_TABLE;

--- vpanwar 21/02/2007 End

        l_dist_info_tbl(cnt).ACCOUNTING_DATE := l_date_invoiced;--sysdate;

        l_dist_info_tbl(cnt).GL_REVERSAL_FLAG := 'N';
        l_dist_info_tbl(cnt).POST_TO_GL := 'N';

      -- changed to positive if it's negative
      -- sjalasut, commented the following code as part of OKLR12B Disbursements Project
      -- IF (l_amount < 0) THEN
        -- l_amount := -(l_amount);
      -- END IF;
      --
        l_dist_info_tbl(cnt).AMOUNT := r_this.amount;

-- multi-currency info
-- cklee 05/04/2004
        open l_curr_conv_csr(l_chr_id);
        fetch l_curr_conv_csr into r_curr_conv;
        close l_curr_conv_csr;

        l_dist_info_tbl(cnt).currency_code		:= r_curr_conv.currency_code;
        l_dist_info_tbl(cnt).contract_id		:= l_chr_id;

        -- Fill the Multi Currency parameters
        l_dist_info_tbl(cnt).currency_conversion_type
                            := r_curr_conv.CURRENCY_CONVERSION_TYPE;
        l_dist_info_tbl(cnt).currency_conversion_rate
                            := r_curr_conv.CURRENCY_CONVERSION_RATE;
        l_dist_info_tbl(cnt).currency_conversion_date
                            := r_curr_conv.CURRENCY_CONVERSION_DATE;

--

        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(0).source_table := 'AP_VENDOR_SITES_V';
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(0).primary_key_column := l_ipvs_id;

        OPEN ar_site_uses_csr (l_chr_id);
        FETCH ar_site_uses_csr INTO l_site_uses_id;
        CLOSE ar_site_uses_csr;
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(1).source_table := 'AR_SITE_USES_V';
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(1).primary_key_column := l_site_uses_id;

        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(2).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(2).primary_key_column := l_org_id;--mo_global.get_current_org_id();


        OPEN salesP_csr (l_chr_id);
        FETCH salesP_csr INTO l_sales_id;
        CLOSE salesP_csr;
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(3).source_table := 'JTF_RS_SALESREPS_MO_V';
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(3).primary_key_column := l_sales_id;

        OPEN ra_cust_trx_types_csr (l_chr_id);
        FETCH ra_cust_trx_types_csr INTO l_cust_trx_type_id;
        CLOSE ra_cust_trx_types_csr;
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(4).source_table := 'RA_CUST_TRX_TYPES';
        l_acc_gen_primary_key_tbl(cnt).acc_gen_key_tbl(4).primary_key_column := l_cust_trx_type_id;

--start:| 05-Jul-2007 cklee Fixed Accounting call issue: assigned the following:     |
--|      l_acc_gen_primary_key_tbl(cnt).source_id := r_this.id;      |
        l_acc_gen_primary_key_tbl(cnt).source_id := r_this.id;

--end:| 05-Jul-2007 cklee Fixed Accounting call issue: assigned the following:     |
--|      l_acc_gen_primary_key_tbl(cnt).source_id := lx_tplv_tbl(cnt).id;      |
      --Bug# 4622198

      cnt := cnt + 1;
      END LOOP;

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
                                  ,p_trx_header_id           => p_fund_id
                                  ,p_trx_header_table        => 'OKL_TRX_AP_INVOICES_B');

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
  END CREATE_ACCOUNTING_DIST;

----------------------------------------------------------------------------
 FUNCTION get_creditRem_by_chrid(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS

    --l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_value             NUMBER := 0;
    l_credit_id NUMBER := 0;
    l_row_found boolean := false;
begin
    l_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_contract_id);
    IF (l_credit_id IS NOT NULL) THEN
      x_value := OKL_SEEDED_FUNCTIONS_PVT.creditline_total_remaining(l_credit_id);
    ELSE
      x_value := 0;
    END IF;

  RETURN x_value;


  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;
END;


-- Check to see if contract is legal to fund
----------------------------------------------------------------------------
 FUNCTION is_chr_fundable_status(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS
  l_row_notfound boolean := false;
  l_yn number := 0;
  l_sts_code OKC_K_HEADERS_B.sts_code%TYPE;
  l_deal_type OKL_K_HEADERS.deal_type%TYPE;

  CURSOR c_deal_type(p_contract_id  NUMBER)
  IS
  select chr.sts_code,
         khr.deal_type
  from  OKL_K_HEADERS khr,
        OKC_K_HEADERS_B chr
  where khr.id = chr.id
  and   khr.id = p_contract_id
  ;


  CURSOR c (p_contract_id  NUMBER)
  IS
select 1
from   okc_statuses_b ste,
       okc_k_headers_b chr
where  ste.code = chr.sts_code
and    ste.ste_code in ('ENTERED', 'ACTIVE','SIGNED')
and    chr.id = p_contract_id
  ;

BEGIN

--
-- assume this is a valid contract id
--
  OPEN c_deal_type (p_contract_id);
  FETCH c_deal_type INTO l_sts_code,
                         l_deal_type;
  CLOSE c_deal_type;

  IF (l_deal_type = 'LOAN-REVOLVING') THEN

    IF (l_sts_code = 'BOOKED') THEN
      l_yn := 1;
    ELSE
      l_yn := 0;
    END IF;

  ELSE -- for any other type of contract

    OPEN c (p_contract_id);


    FETCH c INTO l_yn;
    l_row_notfound := c%NOTFOUND;
    CLOSE c;

    IF (l_row_notfound) THEN
      l_yn := 0;
    ELSE
      l_yn := 1;
    END IF;

  END IF;

  RETURN l_yn;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;
END;
----------------------------------------------------------------------------
-- Total contract funded adjustments
 FUNCTION get_chr_funded_adjs(
  p_contract_id                  IN NUMBER                 -- contract hdr
 ,p_vendor_site_id               IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the below cursor to make khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project
  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.funding_type_code = 'PREFUNDING'
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.amount < 0 -- adjustments
  and b.khr_id = p_contract_id;

  -- sjalasut, modified the below cursor to make khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project
  CURSOR c2 (p_contract_id  NUMBER, p_vendor_site_id NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.funding_type_code = 'PREFUNDING'
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.amount < 0 -- adjustments
  and b.khr_id = p_contract_id
  and a.ipvs_id = p_vendor_site_id;

BEGIN

  IF (p_vendor_site_id IS NULL OR p_vendor_site_id = OKL_API.G_MISS_NUM) THEN

    OPEN c (p_contract_id);
    FETCH c INTO l_amount;
    CLOSE c;
  ELSE
    OPEN c2 (p_contract_id, p_vendor_site_id);
    FETCH c2 INTO l_amount;
    CLOSE c2;
  END IF;

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;
END;
----------------------------------------------------------------------------

-- Total contract allowable funded remaining
 FUNCTION get_chr_canbe_funded_rem(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_amount_buffer NUMBER := 0;
  l_amount_hasbeen_funded NUMBER := 0;
  l_amount_canbe_funded NUMBER := 0;

  l_loan_rev NUMBER;
  l_loan_rev_notfound boolean := false;

--START:bug#4882537
  l_amt_hasbeen_funded_sub number;
--END:bug#4882537

  CURSOR c_loan_revolving (p_contract_id  NUMBER)
  IS
  select 1 from OKL_K_HEADERS khr
  where khr.id = p_contract_id
  and khr.deal_type = 'LOAN-REVOLVING';

  BEGIN

    OPEN c_loan_revolving(p_contract_id);
    FETCH c_loan_revolving INTO l_loan_rev;
    l_loan_rev_notfound := c_loan_revolving%NOTFOUND;
    CLOSE c_loan_revolving;


    -- is not loan revolving contract
    IF (l_loan_rev_notfound) THEN

      l_amount_hasbeen_funded := get_total_funded(p_contract_id);
      l_amount_canbe_funded := get_chr_canbe_funded(p_contract_id);
      l_amount := l_amount_canbe_funded - l_amount_hasbeen_funded;
--START:bug#4882537
-- Subsidy is a negative amount. So we just add back to the remaining balance
-- of the contract for the funding
      l_amt_hasbeen_funded_sub := get_amount_subsidy(p_contract_id);
      l_amount := l_amount_canbe_funded - l_amount_hasbeen_funded + l_amt_hasbeen_funded_sub;
--      l_amount := l_amount_canbe_funded - l_amount_hasbeen_funded;
--END:bug#4882537

    ELSE
      -- get amount for the remaining of the attach credit line
      l_amount := get_creditRem_by_chrid(p_contract_id);

    END IF;

  RETURN l_amount;
  EXCEPTION


    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;

----------------------------------------------------------------------------

-- Total contract allowable funded
 FUNCTION get_chr_canbe_funded(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_amount_oec NUMBER := 0;
  l_amount_expense NUMBER := 0;
  l_loan_rev NUMBER := 0;
  l_loan_rev_notfound boolean := false;
  l_credit_id NUMBER;

  CURSOR c_loan_revolving (p_contract_id  NUMBER)
  IS
  select 1 from OKL_K_HEADERS khr
  where khr.id = p_contract_id
  and khr.deal_type = 'LOAN-REVOLVING';

  BEGIN

    OPEN c_loan_revolving(p_contract_id);

    FETCH c_loan_revolving INTO l_loan_rev;
    l_loan_rev_notfound := c_loan_revolving%NOTFOUND;
    CLOSE c_loan_revolving;

    -- is not loan revolving contract
    IF (l_loan_rev_notfound) THEN
      l_amount_oec := get_chr_oec_canbe_funded(p_contract_id);
      l_amount_expense := get_chr_exp_canbe_funded_amt(p_contract_id);
      l_amount := l_amount_oec + l_amount_expense;
    ELSE
      -- get amount for the remaining of the attach credit line
      l_amount := get_creditRem_by_chrid(p_contract_id);

    END IF;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;

----------------------------------------------------------------------------

-- Total contract allowable oec funded remaining
 FUNCTION get_chr_oec_canbe_funded_rem(
  p_contract_id                      IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_total_canbe_OEC_amount NUMBER := 0;
  l_oec_hasbeen_funded_amount NUMBER := 0;

  BEGIN

    l_total_canbe_OEC_amount:= get_chr_oec_canbe_funded(p_contract_id);
    l_oec_hasbeen_funded_amount := get_chr_oec_hasbeen_funded_amt(p_contract_id);
    l_amount := l_total_canbe_OEC_amount - l_oec_hasbeen_funded_amount;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;

----------------------------------------------------------------------------

-- Total contract allowable oec funded
 FUNCTION get_chr_oec_canbe_funded(
  p_contract_id                      IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;


  BEGIN

    IF (okl_funding_pvt.is_chr_fundable_status(p_contract_id) = 1) THEN

      l_amount := OKL_FUNDING_PVT.get_contract_line_amt(p_contract_id);
    END IF;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;

----------------------------------------------------------------------------

-- Total contract has been funded oec amount
 FUNCTION get_chr_oec_hasbeen_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ,p_vendor_site_id               IN NUMBER

 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- get approved amount for Asset
  -- sjalasut, made changes to the below cursor to have khr_id be referred
  -- from okl_txl_inv_lns_all_b instead of okl_trx_ap_invoices_b.
  -- also changed the from clause to okl_txl_ap_inv_lns_all_b
  CURSOR c_tot_asset_fund (p_contract_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code ='ASSET'
  and b.amount > 0 --?
  and b.khr_id = p_contract_id
  ;

  -- sjalasut, made changes to the below cursor to have khr_id be referred
  -- from okl_txl_inv_lns_all_b instead of okl_trx_ap_invoices_b.
  -- also changed the from clause to okl_txl_ap_inv_lns_all_b
  CURSOR c_tot_asset_fund_ven (p_contract_id  NUMBER, p_vendor_site_id NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code ='ASSET'
  and b.amount > 0 --?
  and b.khr_id = p_contract_id
  and a.ipvs_id = p_vendor_site_id
  ;

  BEGIN
    IF (p_vendor_site_id IS NULL OR p_vendor_site_id = OKL_API.G_MISS_NUM)
    THEN

      OPEN c_tot_asset_fund(p_contract_id);
      FETCH c_tot_asset_fund INTO l_amount;
      CLOSE c_tot_asset_fund;
    ELSE
      OPEN c_tot_asset_fund_ven(p_contract_id,p_vendor_site_id);
      FETCH c_tot_asset_fund_ven INTO l_amount;
      CLOSE c_tot_asset_fund_ven;

    END IF;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;

----------------------------------------------------------------------------


-- Total contract allowable expnese funded remaining
 FUNCTION get_chr_exp_canbe_funded_rem(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_vendor_site_id               IN NUMBER                 -- vendor_site_id
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_total_canbe_expense_amount NUMBER := 0;
  l_expense_hasbeen_funded_amt NUMBER := 0;

  BEGIN
    l_expense_hasbeen_funded_amt:= get_chr_exp_hasbeen_funded_amt(p_contract_id,p_vendor_site_id);

    l_total_canbe_expense_amount := get_chr_exp_canbe_funded_amt(p_contract_id,p_vendor_site_id);
    l_amount := l_total_canbe_expense_amount - l_expense_hasbeen_funded_amt;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;
END;
----------------------------------------------------------------------------

-- Total contract has been funded expense
 FUNCTION get_chr_exp_hasbeen_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_vendor_site_id               IN NUMBER                 -- vendor_site_id
 ) RETURN NUMBER

IS
  l_amount NUMBER := 0;

  -- get approved amount for Expense by specific vendor
  -- sjalasut, modified the below cursor to have khr_id be referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c_tot_expense_fund (p_contract_id  NUMBER, p_vendor_site_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code ='EXPENSE'
  and b.amount > 0 --?
  and b.khr_id = p_contract_id
  and exists (select null
              from   okx_vendor_sites_v vs
              where  vs.id1 = a.ipvs_id
              and    vs.id1 = p_vendor_site_id)
  ;

  BEGIN
    OPEN c_tot_expense_fund(p_contract_id, p_vendor_site_id);
    FETCH c_tot_expense_fund INTO l_amount;
    CLOSE c_tot_expense_fund;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;
END;
----------------------------------------------------------------------------

-- Total contract has been funded expense
 FUNCTION get_chr_exp_hasbeen_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

-- get approved amount for Expense
  -- sjalasut, made changes to the below cursor to have khr_id referred to
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. change made
  -- as part of OKLR12B disbursements project.
  CURSOR c_tot_expense_fund (p_contract_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code ='EXPENSE'
  and b.amount > 0 --?
  and b.khr_id = p_contract_id;

  BEGIN

    OPEN c_tot_expense_fund(p_contract_id);
    FETCH c_tot_expense_fund INTO l_amount;
    CLOSE c_tot_expense_fund;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);

      RETURN 0;
END;
----------------------------------------------------------------------------
 FUNCTION get_chr_exp_canbe_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_vendor_site_id               IN NUMBER                 -- vendor_site_id
 ,p_due_date                     IN date  default sysdate   --cklee added) RETURN NUMBER
) RETURN NUMBER IS
  l_amount NUMBER := 0;
  l_cle_amount NUMBER := 0;
  l_amount_per NUMBER := 0;

  l_vendor_id NUMBER := 0;
  l_cle_id NUMBER := 0;

  l_cle_start_date DATE;
  l_period NUMBER := 0;
  l_period_org NUMBER := 0;

  l_row_notfound   BOOLEAN;


  CURSOR cv1 (p_vendor_site_id NUMBER)
  IS
    select vendor_id from okx_vendor_sites_v
    where id1 = to_char(p_vendor_site_id)
  ;

  CURSOR c (p_contract_id  NUMBER, p_vendor_id NUMBER, p_rle_code VARCHAR2)
  IS
select nvl(cle.AMOUNT,0),
       cle.id,
       nvl(cle.start_date,k.start_date)
from   OKL_K_LINES_FULL_V cle,
       okc_k_party_roles_b cpl,
       okc_line_styles_b ls,
       okc_k_headers_b k
where  k.id = cle.dnz_chr_id
and    cle.dnz_chr_id = p_contract_id
and    cle.lse_id = ls.id
and    ls.lty_code = p_rle_code
and    cle.id = cpl.cle_id
and    cpl.dnz_chr_id  = p_contract_id
and    cpl.chr_id     is null
and    cpl.rle_code = 'OKL_VENDOR'
and    cpl.object1_id1 = to_char(p_vendor_id)
and    cpl.object1_id2 = '#'
-- Pass through check
/* and not exists (select null
                from   okc_rule_groups_v crg,
                       okc_rules_v cr
                where  crg.dnz_chr_id = p_contract_id
                and    crg.cle_id = cle.id -- line id for rle_code
                and    crg.id = cr.rgp_id
                and    crg.rgd_code = 'LAPSTH') */
and not exists (select null
                from   okl_party_payment_hdr phr
                where  phr.dnz_chr_id = p_contract_id
                and    phr.cle_id = cle.id)
;


--
-- get Number of Period
--
-- 1) take contract start date if line start date is null
-- 2) truncate pay period if less than 0
--
  CURSOR c_period (p_contract_id  NUMBER, p_cle_id NUMBER)
  IS
   --cklee start 10/3/2007 bug: 6128765
/*select ceil(decode(cr.object1_id1, 'A', months_between(sysdate, nvl(cle.start_date, k.start_date))/12
                            , 'M', months_between(sysdate, nvl(cle.start_date, k.start_date))
                            , 'Q', months_between(sysdate, nvl(cle.start_date, k.start_date))/3
                            , 'S', months_between(sysdate, nvl(cle.start_date, k.start_date))/6
                            , months_between(sysdate, nvl(cle.start_date, k.start_date))))*/
 select ceil(decode(cr.object1_id1, 'A', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))/12
                              , 'M', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))
                               , 'Q', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))/3
                               , 'S', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))/6
                               , months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))))
   --cklee end 10/3/2007 bug: 6128765

from   okc_rule_groups_v crg,
       okc_rules_v cr,
       OKL_K_LINES_FULL_V cle,
       okc_k_headers_b k
where  crg.dnz_chr_id = p_contract_id
and    cle.dnz_chr_id = k.id
and    crg.id = cr.rgp_id
and    crg.rgd_code = 'LAFEXP'

and    crg.cle_id = cle.id
and    cr.RULE_INFORMATION_CATEGORY = 'LAFREQ'
and    cle.id = p_cle_id
;

--
-- get amount per period
--
--
  CURSOR c_amount_per (p_contract_id  NUMBER, p_cle_id NUMBER)
  IS
select to_number(nvl(cr.RULE_INFORMATION1,'0'))
       ,to_number(nvl(cr.RULE_INFORMATION2,'0'))
from   okc_rule_groups_v crg,
       okc_rules_v cr
where  crg.dnz_chr_id = p_contract_id
and    crg.id = cr.rgp_id

and    crg.rgd_code = 'LAFEXP'
and    cr.RULE_INFORMATION_CATEGORY = 'LAFEXP'
and    crg.cle_id = p_cle_id

;


BEGIN
  IF (p_contract_id IS NULL OR p_contract_id = OKL_API.G_MISS_NUM)
  THEN
    RETURN 0;  -- error
  ELSE
    OPEN cv1 (p_vendor_site_id);
    FETCH cv1 INTO l_vendor_id;
    CLOSE cv1;

    ----------------------------------------------------
    -- FEE line
    ----------------------------------------------------
    OPEN c (p_contract_id, l_vendor_id, 'FEE');
    LOOP


      FETCH c into l_cle_amount,
                   l_cle_id,
                   l_cle_start_date;

      EXIT WHEN c%NOTFOUND;

      OPEN c_amount_per (p_contract_id, l_cle_id);
      FETCH c_amount_per INTO l_period_org,
                              l_amount_per;

      l_row_notfound := c_amount_per%NOTFOUND;
      CLOSE c_amount_per;

      -- if recurring records doesn't exists
      IF (l_row_notfound) THEN

        -- either fee effective date or contract effective date <= current date
        IF ( l_cle_start_date <= trunc(p_due_date) ) THEN -- cklee start 10/3/2007 bug: 6128765
          l_amount := l_amount + l_cle_amount;
        END IF;

      ELSE

        OPEN c_period (p_contract_id, l_cle_id);
        FETCH c_period INTO l_period;
        CLOSE c_period;

        IF l_period = 0 AND trunc(p_due_date) = TRUNC(l_cle_start_date) THEN -- cklee start 10/3/2007 bug: 6128765
          l_period := 1;
        END IF;

        -- calculate only if period is positive
        IF (l_period > 0) THEN

          IF (l_period > l_period_org) THEN
            l_period := l_period_org;
          END IF;
          l_amount := l_amount + (l_amount_per * l_period);
        END IF;

      END IF;

    END LOOP;
    CLOSE c;

    -- SOLD_SERVICE line
    OPEN c (p_contract_id, l_vendor_id, 'SOLD_SERVICE');
    LOOP


      FETCH c into l_cle_amount,
                   l_cle_id,
                   l_cle_start_date;

      EXIT WHEN c%NOTFOUND;

      OPEN c_amount_per (p_contract_id, l_cle_id);

      FETCH c_amount_per INTO l_period_org,
                              l_amount_per;
      l_row_notfound := c_amount_per%NOTFOUND;
      CLOSE c_amount_per;


      -- if recurring records doesn't exists
      IF (l_row_notfound) THEN

        -- either fee effective date or contract effective date <= current date
        IF ( l_cle_start_date <= trunc(p_due_date) ) THEN -- cklee start 10/3/2007 bug: 6128765
          l_amount := l_amount + l_cle_amount;
        END IF;

      ELSE

        OPEN c_period (p_contract_id, l_cle_id);
        FETCH c_period INTO l_period;
        CLOSE c_period;

        IF l_period = 0 AND trunc(p_due_date) = TRUNC(l_cle_start_date) THEN -- cklee start 10/3/2007 bug: 6128765
          l_period := 1;
        END IF;

        -- calculate only if period is positive
        IF (l_period > 0) THEN

          IF (l_period > l_period_org) THEN
            l_period := l_period_org;
          END IF;
          l_amount := l_amount + (l_amount_per * l_period);
        END IF;

      END IF;

    END LOOP;
    CLOSE c;

  END IF;
--
  IF (l_amount IS NULL) THEN
    l_amount := 0;
  END IF;

  IF (okl_funding_pvt.is_chr_fundable_status(p_contract_id) = 0) THEN
    l_amount := 0;
  END IF;

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;
----------------------------------------------------------------------------
-- used for pre-funding only
 FUNCTION get_chr_exp_canbe_funded_amt(
  p_contract_id                       IN NUMBER                 -- contract hdr
  ,p_due_date                         IN date  default sysdate  --shagarg added
  ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_cle_amount NUMBER := 0;
  l_amount_per NUMBER := 0;

  l_cle_id NUMBER := 0;
  l_cle_start_date DATE;
  l_period NUMBER := 0;
  l_period_org NUMBER := 0;
  l_row_notfound   BOOLEAN;

  CURSOR c (p_contract_id  NUMBER, p_rle_code VARCHAR2)
  IS
select nvl(cle.AMOUNT,0),
       cle.id,
       nvl(cle.start_date,k.start_date)
from   OKL_K_LINES_FULL_V cle,
       okc_k_party_roles_b cpl,
       okc_line_styles_b ls,
       okc_k_headers_b k
where  k.id = cle.dnz_chr_id
and    cle.dnz_chr_id = p_contract_id
and    cle.lse_id = ls.id
and    ls.lty_code = p_rle_code
and    cle.id = cpl.cle_id
and    cpl.dnz_chr_id  = p_contract_id
and    cpl.chr_id     is null
and    cpl.rle_code = 'OKL_VENDOR'
--and    cpl.object1_id1 = to_char(p_vendor_id)
--and    cpl.object1_id2 = '#'
-- Pass through check
/*
and not exists (select null
                from   okc_rule_groups_v crg,
                       okc_rules_v cr
                where  crg.dnz_chr_id = p_contract_id
                and    crg.cle_id = cle.id -- line id for rle_code
                and    crg.id = cr.rgp_id
                and    crg.rgd_code = 'LAPSTH') */
and not exists (select null
                from   okl_party_payment_hdr phr
                where  phr.dnz_chr_id = p_contract_id
                and    phr.cle_id = cle.id)
;


--
-- get Number of Period
--
-- 1) take contract start date if cle start date is null
-- 2) truncate pay period if less than 0
--
  CURSOR c_period (p_contract_id  NUMBER, p_cle_id NUMBER)
  IS
   --cklee start 10/3/2007 bug: 6128765
/*select ceil(decode(cr.object1_id1, 'A', months_between(sysdate, nvl(cle.start_date, k.start_date))/12
                            , 'M', months_between(sysdate, nvl(cle.start_date, k.start_date))
                            , 'Q', months_between(sysdate, nvl(cle.start_date, k.start_date))/3
                            , 'S', months_between(sysdate, nvl(cle.start_date, k.start_date))/6
                            , months_between(sysdate, nvl(cle.start_date, k.start_date))))*/
 select ceil(decode(cr.object1_id1, 'A', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))/12
                              , 'M', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))
                               , 'Q', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))/3
                               , 'S', months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))/6
                               , months_between(trunc(p_due_date), nvl(cle.start_date, k.start_date))))
   --cklee end 10/3/2007 bug: 6128765
from   okc_rule_groups_v crg,
       okc_rules_v cr,
       OKL_K_LINES_FULL_V cle,
       okc_k_headers_b k
where  crg.dnz_chr_id = p_contract_id
and    cle.dnz_chr_id = k.id
and    crg.id = cr.rgp_id
and    crg.rgd_code = 'LAFEXP'

and    crg.cle_id = cle.id
and    cr.RULE_INFORMATION_CATEGORY = 'LAFREQ'
and    cle.id = p_cle_id
;

--
-- get amount per period
--
--
  CURSOR c_amount_per (p_contract_id  NUMBER, p_cle_id NUMBER)
  IS
select to_number(nvl(cr.RULE_INFORMATION1,'0'))
       ,to_number(nvl(cr.RULE_INFORMATION2,'0'))
from   okc_rule_groups_v crg,
       okc_rules_v cr
where  crg.dnz_chr_id = p_contract_id
and    crg.id = cr.rgp_id
and    crg.rgd_code = 'LAFEXP'
and    cr.RULE_INFORMATION_CATEGORY = 'LAFEXP'
and    crg.cle_id = p_cle_id
;


BEGIN
  IF (p_contract_id IS NULL OR p_contract_id = OKL_API.G_MISS_NUM)
  THEN
    RETURN 0;  -- error
  ELSE

    ----------------------------------------------------
    -- FEE line

    ----------------------------------------------------
    OPEN c (p_contract_id, 'FEE');
    LOOP

      FETCH c into l_cle_amount,
                   l_cle_id,
                   l_cle_start_date;

      EXIT WHEN c%NOTFOUND;


      OPEN c_amount_per (p_contract_id, l_cle_id);
      FETCH c_amount_per INTO l_period_org,
                              l_amount_per;

      l_row_notfound := c_amount_per%NOTFOUND;
      CLOSE c_amount_per;

      -- if recurring records doesn't exists
      IF (l_row_notfound) THEN

        -- either fee effective date or contract effective date <= current date
        IF ( l_cle_start_date <= trunc(p_due_date) ) THEN   --cklee end 10/3/2007 bug: 6128765
          l_amount := l_amount + l_cle_amount;

        END IF;

      ELSE

        OPEN c_period (p_contract_id, l_cle_id);
        FETCH c_period INTO l_period;
        CLOSE c_period;

        IF l_period = 0 AND trunc(p_due_date) = TRUNC(l_cle_start_date) THEN   --cklee end 10/3/2007 bug: 6128765
          l_period := 1;
        END IF;

        -- calculate only if period is positive
        IF (l_period > 0) THEN

          IF (l_period > l_period_org) THEN
            l_period := l_period_org;
          END IF;
          l_amount := l_amount + (l_amount_per * l_period);
        END IF;


      END IF;

    END LOOP;

    CLOSE c;

    -- SOLD_SERVICE line

    OPEN c (p_contract_id, 'SOLD_SERVICE');
    LOOP

      FETCH c into l_cle_amount,
                   l_cle_id,
                   l_cle_start_date;

      EXIT WHEN c%NOTFOUND;

      OPEN c_amount_per (p_contract_id, l_cle_id);

      FETCH c_amount_per INTO l_period_org,
                              l_amount_per;

      l_row_notfound := c_amount_per%NOTFOUND;
      CLOSE c_amount_per;

      -- if recurring records doesn't exists
      IF (l_row_notfound) THEN


        -- either fee effective date or contract effective date <= current date
        IF ( l_cle_start_date <= trunc(p_due_date) ) THEN   --cklee end 10/3/2007 bug: 6128765
          l_amount := l_amount + l_cle_amount;

        END IF;

      ELSE

        OPEN c_period (p_contract_id, l_cle_id);
        FETCH c_period INTO l_period;
        CLOSE c_period;

        IF l_period = 0 AND trunc(p_due_date) = TRUNC(l_cle_start_date) THEN   --cklee end 10/3/2007 bug: 6128765
          l_period := 1;
        END IF;

        -- calculate only if period is positive
        IF (l_period > 0) THEN

          IF (l_period > l_period_org) THEN
            l_period := l_period_org;

          END IF;
          l_amount := l_amount + (l_amount_per * l_period);
        END IF;
      END IF;

    END LOOP;
    CLOSE c;

  END IF;

  IF (l_amount IS NULL) THEN
    l_amount := 0;
  END IF;


  IF (okl_funding_pvt.is_chr_fundable_status(p_contract_id) = 0) THEN
    l_amount := 0;
  END IF;

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;


END;

  --------------------------------------------------------------------------
  --------------------------------------------------------------------------
     ----- Validate Re-lease contract for Manual Disbursement
     --------------------------------------------------------------------------
     FUNCTION validate_release_contract(
       p_tapv_rec                  IN tapv_rec_type
     ) RETURN VARCHAR2
     IS


     CURSOR c_release_k_flag(p_contract_id  NUMBER)
     IS
      SELECT nvl(rul.rule_information1, 'N') FROM
       okc_rules_b rul, okc_rule_groups_b rgp
       WHERE rul.rule_information_category='LARLES'
       AND rgp.id = rul.rgp_id
       AND rgp.rgd_code = 'LARLES'
       AND rgp.dnz_chr_id= p_contract_id;

       l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
       l_release_flag   okc_rules_b.rule_information1%type;


     BEGIN

       OPEN c_release_k_flag(p_tapv_rec.khr_id);
       FETCH c_release_k_flag INTO l_release_flag;
       CLOSE c_release_k_flag;

       IF (l_release_flag = 'Y') THEN
         -- re-leased contract
            IF (p_tapv_rec.funding_type_code <> 'MANUAL_DISB' ) THEN

               OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_LLA_RELK_FUNDTYPE_CHK',
                             p_token1       => 'COL_NAME',
                             p_token1_value => p_tapv_rec.funding_type_code);

               RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
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
   --------------------------------------------------------------

  -- Validate Funding request Checklist
  --------------------------------------------------------------------------
  FUNCTION validate_funding_checklist(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_req_row_found       boolean;
    l_list_row_not_found   boolean;
    l_template_row_not_found   boolean;

    l_dummy           number;
    l_chklist_sts_row_found   boolean;
    l_status okl_crd_fund_checklists_tpl_uv.STATUS%TYPE;
    l_fund_cls_tpl_exp_found boolean := false;

    l_credit_id okc_k_headers_b.id%TYPE;
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
    l_lease_app_found boolean := false;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
---------------------------------------------------------------------------------------------------------
-- 1. check credit line funding checklist template, used for existing requests w credit line that doesn't
--    have checklist template setup
---------------------------------------------------------------------------------------------------------
cursor c_chk_tpl (p_credit_id number) is
  select tpl.status
from okl_crd_fund_checklists_tpl_uv tpl
where tpl.khr_id = p_credit_id
  ;

---------------------------------------------------------------------------------------------------
-- 2.
-- validate if credit line contract's funding checklist template expired

-- Note: assumption

-- 1. Credit line exists : valiadte_creditline()
-- 2. pass # 1 cursor check
---------------------------------------------------------------------------------------------------
CURSOR c_fund_chklst_tpl (p_credit_id number)
IS
  select 1
from  okl_crd_fund_chklst_tpl_hdr_uv chk
where TRUNC(chk.effective_to) < TRUNC(sysdate)
and   chk.khr_id = p_credit_id
;


---------------------------------------------------------------------------------------------------------
-- 3. check funding checklist if funding checklist has not been setup
---------------------------------------------------------------------------------------------------------
CURSOR c_chklst_chk(p_req_id okl_trx_ap_invoices_b.id%type)
IS
  select 1
from okl_funding_checklists_uv chk
where fund_req_id = TO_CHAR(p_req_id) -- cklee: 11/04/2004
;

---------------------------------------------------------------------------------------------------------
-- 4. check checklist required items
---------------------------------------------------------------------------------------------------------

CURSOR c_chklst (p_chr_id okc_k_headers_b.id%type, p_fund_req_id okl_trx_ap_invoices_b.id%type)
IS
  select 1
from  okc_rules_b rult
where rult.rule_information_category = G_FUNDING_CHKLST_TPL_RULE1--'LAFCLD'
and   rult.dnz_chr_id = p_chr_id
and   rult.object1_id1 = p_fund_req_id
and   rult.object1_id2 = '#'
and   rult.RULE_INFORMATION2 = 'Y'
and   (rult.RULE_INFORMATION3 <> 'Y' or rult.RULE_INFORMATION3 is null)
;

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
---------------------------------------------------------------------------------------------------------
-- 5. check if the contract was created from a lease application
---------------------------------------------------------------------------------------------------------
CURSOR c_lease_app (p_chr_id okc_k_headers_b.id%type)
IS
--start modified abhsaxen for performance SQLID 20562365
  select 1
from  okc_k_headers_b chr
where ORIG_SYSTEM_SOURCE_CODE = G_OKL_LEASE_APP
and chr.id = p_chr_id
;
--end modified abhsaxen for performance SQLID 20562365

  BEGIN
      -- sjalasut, tapv_rec.khr_id would work here as the calling procedure
      -- continue to populate this value.
      OPEN c_lease_app(p_tapv_rec.khr_id);
      FETCH c_lease_app INTO l_dummy;
      l_lease_app_found := c_lease_app%FOUND;
      CLOSE c_lease_app;

      IF NOT l_lease_app_found THEN
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

        l_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_tapv_rec.khr_id);

      ---------------------------------------------------------------------------------------------------------
      -- 1.1 check credit line funding checklist template, used for existing requests w credit line that doesn't
      --    have checklist template setup
      -- existing check
      ---------------------------------------------------------------------------------------------------------
/* no need
      OPEN c_chk_tpl(l_credit_id);
      FETCH c_chk_tpl INTO l_status;

      l_template_row_not_found := c_chk_tpl%NOTFOUND;

      CLOSE c_chk_tpl;


      -- credit line checklist tempate doesn't exists
      IF (l_template_row_not_found) THEN
        -- Funding request checklist template not found. Please setup checklist template for associated credit line.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
*/

      ---------------------------------------------------------------------------------------------------------
      -- 1.2 check credit line funding checklist template, used for existing requests w credit line that doesn't
      --    have checklist template setup
      -- status check
      ---------------------------------------------------------------------------------------------------------
/*no need: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

      IF (l_status IS NOT NULL and l_status <> 'ACTIVE') THEN
        -- Funding request checklist template status is new. Please activate Funding request checklist template
        -- for associated credit line.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK7');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
*/
        ---------------------------------------------------------------------------------------------------------
        -- 2. check credit line funding checklist template expiration
        -- 2nd place to check when user submit a request for approval
        ---------------------------------------------------------------------------------------------------------
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
        IF l_credit_id IS NOT NULL THEN
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

          OPEN c_fund_chklst_tpl(l_credit_id);
          FETCH c_fund_chklst_tpl INTO l_dummy;
          l_fund_cls_tpl_exp_found := c_fund_chklst_tpl%FOUND;
          CLOSE c_fund_chklst_tpl;

          -- funding checklist template expired.
          IF (l_fund_cls_tpl_exp_found) THEN
            -- Funding request checklist template expired. Please modify effective date of Funding request checklist template.
            OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK6');

            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
        END IF;
      END IF;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

-- Fixed trx_status_code to include , 'SUBMITTED' for WF case 12-05-2003 cklee
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
-- commented out for okl.h     IF (p_tapv_rec.trx_status_code in ('APPROVED', 'SUBMITTED')) THEN

        ---------------------------------------------------------------------------------------------------------
        -- 3. check funding checklist if funding checklist has not been setup
        -- Note: This is used for existing request which doesn't have checklist setup
        ---------------------------------------------------------------------------------------------------------
/* no need
        OPEN c_chklst_chk(p_tapv_rec.id);
        FETCH c_chklst_chk INTO l_dummy;
        l_list_row_not_found := c_chklst_chk%NOTFOUND;
        CLOSE c_chklst_chk;

        -- checklist doesn't exists
        IF (l_list_row_not_found) THEN
          -- Funding checklist not found. Please update request and setup checklist before submit request.
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK2');

          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
*/


        ---------------------------------------------------------------------------------------------------------
        -- 4. check checklist required items
        ---------------------------------------------------------------------------------------------------------
/*no need for okl.h 23-May-2005  cklee okl.h Lease App IA Authoring                            |
        OPEN c_chklst(p_tapv_rec.khr_id, p_tapv_rec.id);
        FETCH c_chklst INTO l_dummy;
        l_req_row_found := c_chklst%FOUND;
        CLOSE c_chklst;

        -- all required items have not met requirement
        IF (l_req_row_found) THEN
          -- Funding request has not met all checklist items. Please check off all mandatory checklist items.
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_FUND_CHKLST');

          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
*/
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


  --------------------------------------------------------------------------
  ----- Validate amount if request status = 'SUBMITTED'
  --------------------------------------------------------------------------
  FUNCTION validate_trx_status_code(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_amount          NUMBER := 0;
  BEGIN

    -- trx_status_code is required:
    IF (p_tapv_rec.trx_status_code IS NULL) OR
       (p_tapv_rec.trx_status_code = OKL_API.G_MISS_CHAR)

    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Request Status');
      RAISE G_EXCEPTION_HALT_VALIDATION;
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

  --------------------------------------------------------------------------
  ----- Validate payment due date
  --------------------------------------------------------------------------
  FUNCTION validate_payment_due_date(

    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2

  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN


    -- payment_due_date is required:
    IF (p_tapv_rec.date_invoiced IS NULL) OR
       (p_tapv_rec.date_invoiced = OKL_API.G_MISS_DATE)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Payment due date');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*** comment out this check
    -- date range check : date_entered will be default to sysdate @ UI
    IF (trunc(p_tapv_rec.date_invoiced) < trunc(p_tapv_rec.date_entered))
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_RANGE_CHECK',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Payment due date',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Date entered');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
***/
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

  --------------------------------------------------------------------------
  ----- Validate Funding Amount... when SUBMITTED, APPROVED
  --------------------------------------------------------------------------
  FUNCTION validate_header_amount(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_value             NUMBER := 0;
--    l_chr_id            NUMBER;
--    l_funding_type_code VARCHAR2(30);
    l_cur_total_amount  NUMBER := 0;
    l_cur_amount  NUMBER := 0;
    l_total_hasbeen_funded_amt_ven NUMBER := 0;
    l_total_hasbeen_funded_amount NUMBER := 0;
    l_total_canbe_funded_amount NUMBER := 0;
    l_total_canbe_OEC_amount NUMBER := 0;
    l_total_canbe_expense_amount NUMBER := 0;
    l_total_canbe_expense_amount_g NUMBER := 0;
    l_total_credit_amount NUMBER := 0;
    l_message_name      VARCHAR2(30);
    l_resuts_amount     NUMBER := 0;
    l_credit_id         NUMBER := 0;
    l_booked_count      NUMBER := 0;
    l_total_fund_amount NUMBER := 0;
    l_total_check_amount NUMBER := 0;

    l_invalid_fund         VARCHAR2(150) := 'X';
    l_prefund_amount       NUMBER := 0;
    l_pf_amount       NUMBER := 0;
    l_sr_amount       NUMBER := 0;
    l_amount_buffer       NUMBER := 0;

    l_loan_rev        NUMBER := 0;
    l_loan_row_found  boolean := false;
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
    l_chk_credit_id   number;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |

    l_line_amt        NUMBER := 0; --bug#5600694

-- check FA line
-- OKL_FUNDING_PVT.get_contract_line_funded_amt(a.CHR_ID, a.CLE_ID)
-- will return 0 if user has not been funded FA line yet
-- sjalasut, modified the below cursor to have khr_id be referred from
-- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
-- as part of OKLR12B disbursements project
  CURSOR c_invalid_fund (p_fund_id  NUMBER)
  IS
SELECT
	   nvl(a.ASSET_NUMBER,'X') ASSET_NUMBER, a.CHR_ID, a.CLE_ID, b.ipvs_id
 	   FROM okl_assets_lov_uv a,
 	      okl_trx_ap_invoices_b b
 	   WHERE a.chr_id = b.khr_id
 	   and   b.id = p_fund_id;
 	 /*bug#5600694 veramach 29-Jun-2007
 	 commented and changed the cursor as above to improve the performance
 	 SELECT
  nvl(a.ASSET_NUMBER,'X')
FROM okl_assets_lov_uv a,
--START:| 13-Apr-2006  cklee -- Fixed bug#5160342                                    |
     okl_trx_ap_invoices_b b,
     OKL_TXL_AP_INV_LNS_V c
WHERE a.chr_id = c.khr_id
and   b.id = c.TAP_ID
and   a.cle_id = c.kle_id
--END:| 13-Apr-2006  cklee -- Fixed bug#5160342                                    |
and   b.id = p_fund_id
and   OKL_FUNDING_PVT.get_contract_line_amt(a.CHR_ID, a.CLE_ID, b.ipvs_id) > 0
and   OKL_FUNDING_PVT.get_contract_line_funded_amt(a.CHR_ID, a.CLE_ID) >
  OKL_FUNDING_PVT.get_contract_line_amt(a.CHR_ID, a.CLE_ID, b.ipvs_id); */


-- get current amount for Asset, Expense, or Supplier Retention

  CURSOR c_curr (p_fund_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_b b
  where a.id = b.tap_id
  and b.tap_id = p_fund_id
  and a.trx_status_code IN ('ENTERED','SUBMITTED')
  ;

-- get approved amount for Asset
  -- sjalasut, made changes to the below cursor to have khr_id be referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. change made
  -- as part of OKLR12B disbursements project.
  CURSOR c_tot_asset_fund (p_contract_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code ='ASSET'
  and b.amount > 0 --?
  and b.khr_id = p_contract_id;

-- get approved amount for Expense by specific vendor
  -- sjalasut, made changes to the below cursor to have khr_id be referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. change made
  -- as part of OKLR12B disbursements project.
  CURSOR c_tot_expense_fund (p_contract_id  NUMBER, p_vendor_site_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code ='EXPENSE'
  and b.amount > 0 --?
  and b.khr_id = p_contract_id
  and exists (select null
              from   okx_vendor_sites_v vs
              where  vs.id1 = a.ipvs_id
              and    vs.id1 = p_vendor_site_id)
  ;

  CURSOR c_booked (p_contract_id  NUMBER)
  IS
  select count(1)
  from OKC_K_HEADERS_B a
  where id = p_contract_id
  and sts_code = 'BOOKED'
  ;

-- bug 2604862
  CURSOR c_loan_revolving (p_contract_id  NUMBER)
  IS
  select 1 from OKL_K_HEADERS khr
  where khr.id = p_contract_id
  and khr.deal_type = 'LOAN-REVOLVING';

  BEGIN

    -- header Amount is required
    IF ((p_tapv_rec.funding_type_code in ('PREFUNDING','BORROWER_PAYMENT')) AND
        (p_tapv_rec.amount IS NULL OR
         p_tapv_rec.amount = OKL_API.G_MISS_NUM))
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Amount');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- 1) get contract OEC amount w/o re-lease

    -- 1) get contract OEC
    l_total_canbe_OEC_amount := get_chr_oec_canbe_funded(p_tapv_rec.khr_id);

   --cklee start: bug 6128765
/*    l_total_canbe_expense_amount := nvl(get_chr_exp_canbe_funded_amt(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id),0);

    l_total_canbe_expense_amount_g := nvl(get_chr_exp_canbe_funded_amt(p_tapv_rec.khr_id),0); -- for global check*/
     l_total_canbe_expense_amount := nvl(get_chr_exp_canbe_funded_amt(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id,p_tapv_rec.date_invoiced),0);
     l_total_canbe_expense_amount_g := nvl(get_chr_exp_canbe_funded_amt(p_tapv_rec.khr_id,p_tapv_rec.date_invoiced),0); -- for global check
   --cklee end: bug 6128765

    l_total_canbe_funded_amount := l_total_canbe_OEC_amount + l_total_canbe_expense_amount_g;

-- bug 2604862
    OPEN c_loan_revolving(p_tapv_rec.khr_id);
    FETCH c_loan_revolving INTO l_loan_rev;
    l_loan_row_found := c_loan_revolving%FOUND;
    CLOSE c_loan_revolving;

    -- is loan revolving contract
    IF (l_loan_row_found) THEN
      -- get amount for the remaining of the attach credit line
      l_total_canbe_funded_amount := get_creditRem_by_chrid(p_tapv_rec.khr_id);
    END IF;
-- bug 2604862

    -- get total has been funded
    l_total_hasbeen_funded_amount := get_total_funded(p_tapv_rec.khr_id);

/*
-- cklee 05/19/2004: exclude supplier retention and manual disbursement
    l_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_tapv_rec.khr_id);

    IF ( l_credit_id IS NULL AND
         p_tapv_rec.funding_type_code NOT IN ('SUPPLIER_RETENTION', 'MANUAL_DISB')) THEN
      -- Your request cannot be submitted. Credit line for this contract doesn't exists.
      l_message_name := 'OKL_LLA_FUND_CREDIT_AMT_CHK2';
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
    l_total_credit_amount := get_creditRem_by_chrid(p_tapv_rec.khr_id);

    -- check booked
    OPEN c_booked(p_tapv_rec.khr_id);
    FETCH c_booked INTO l_booked_count;
    CLOSE c_booked;

    -- need to get amount from different AP table
    -- pre-funding current amount
    IF (p_tapv_rec.funding_type_code in ('PREFUNDING','BORROWER_PAYMENT')) THEN

      l_cur_amount := p_tapv_rec.amount; -- stores amount at header, user could changes the amount when submit
    ELSE
      -- get current amount: NOT used for pre-funding
      OPEN c_curr (p_tapv_rec.id);
      FETCH c_curr INTO l_cur_amount;
      CLOSE c_curr;
    END IF;

    -- check amount
    IF (l_cur_amount = 0 ) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_AMOUNT_CHECK');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_resuts_amount := l_total_hasbeen_funded_amount + l_cur_amount;

    -- always check vs credit line total limit except adjustment request (pre-funding with negative amount)
    -- cklee 10/31/03 exclude supplier retention also
    -- cklee 05/14/04 exclude manual disb also
    IF ( p_tapv_rec.funding_type_code NOT IN ('PREFUNDING', 'SUPPLIER_RETENTION', 'MANUAL_DISB') OR
         (p_tapv_rec.funding_type_code = 'PREFUNDING' AND l_cur_amount > 0)
       ) THEN
      --Your request cannot be submitted. The total amount of this request exceeds the value of the contract credit limit.
      l_message_name := 'OKL_LLA_FUND_CREDIT_AMT_CHK';
--      IF (l_resuts_amount > l_total_credit_amount) THEN
-- fixed bug#3220634
      IF (l_total_credit_amount - l_cur_amount < 0) THEN

-- start: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
        l_chk_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_tapv_rec.khr_id);
        IF l_loan_row_found OR (NOT l_loan_row_found and l_chk_credit_id is not null) THEN
          OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring                            |
      END IF;

    -- adjustment check
    ELSIF (p_tapv_rec.funding_type_code = 'PREFUNDING' AND l_cur_amount < 0) THEN

      -- if it's revolving line of credit loan contract's adjustment
      IF (l_loan_row_found) THEN
        l_resuts_amount := l_total_hasbeen_funded_amount + l_cur_amount;
         --Your request cannot be submitted. The total funded amount cannot be less than 0.
        IF (l_resuts_amount < 0) THEN
          l_message_name := 'OKL_LLA_ADJUSTMENTS_AMT_CHK';
            OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

      ELSE
        --
        -- NOTE: adjustment is based on vendor specific. we need to calculate total has been funded amount
        --       by vendor
        --
        l_total_hasbeen_funded_amt_ven := get_chr_exp_hasbeen_funded_amt(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id)+
                                           get_chr_oec_hasbeen_funded_amt(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id)+
                                           get_amount_prefunded(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id)+
                                           -- 12-09-2003 cklee added adjustment
                                           get_chr_funded_adjs(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id);

        l_resuts_amount := l_total_hasbeen_funded_amt_ven + l_cur_amount;
         --Your request cannot be submitted. The total funded amount cannot be less than 0.
        IF (l_resuts_amount < 0) THEN
          l_message_name := 'OKL_LLA_ADJUSTMENTS_AMT_CHK';

            OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;
      END IF;

    END IF;

    IF (p_tapv_rec.funding_type_code ='PREFUNDING') THEN

      -- check if it is NOT a loan revolving contract
      IF NOT l_loan_row_found THEN
        -- booked: check contract
        IF (l_booked_count > 0 AND l_cur_amount > 0 ) THEN
           --Your request cannot be submitted. Pre-funding requests are not allowed for contracts in Booked status.
            l_message_name := 'OKL_LLA_PREFUNDED_AMT_CHK2';
            OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      END IF;

    ELSIF (p_tapv_rec.funding_type_code ='ASSET') THEN

      -- 1. check FA can be funded
      -- invalid fund amount for each FA line
      -- we need to show at most ONE asset number at a time
      /* Bug#5600694 to improve performance
      OPEN c_invalid_fund(p_tapv_rec.id);

      FETCH c_invalid_fund INTO l_invalid_fund;
      CLOSE c_invalid_fund;
      */
 	    FOR i IN  c_invalid_fund(p_tapv_rec.id)
 	    LOOP

 	       l_line_amt := OKL_FUNDING_PVT.get_contract_line_amt(i.CHR_ID, i.CLE_ID, i.ipvs_id);

 	        IF l_line_amt > 0
 	             AND OKL_FUNDING_PVT.get_contract_line_funded_amt(i.CHR_ID, i.CLE_ID) >
 	                  l_line_amt
 	        THEN
 	          l_invalid_fund := i.ASSET_NUMBER;
 	          EXIT;
 	        END IF;

 	    END LOOP;

 	       --End Bug#5600694

      IF (l_invalid_fund <> 'X') THEN

        l_message_name := 'OKL_LLA_FUND_ASSET_AMT_CHK';
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name,
                          p_token1        => 'ASSET_NUMBER',
                          p_token1_value  => l_invalid_fund);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- 2. check asset : will never happen if catch by previous check
      -- get current total HAS BEEN approved amount for ASSET

      OPEN c_tot_asset_fund (p_tapv_rec.khr_id);
      FETCH c_tot_asset_fund INTO l_cur_total_amount;
      CLOSE c_tot_asset_fund;

      l_resuts_amount := l_cur_total_amount + l_cur_amount;
      IF (l_resuts_amount > l_total_canbe_OEC_amount) THEN
        --Your request cannot be submitted. The total amount of this request exceeds
        -- the value of the contract total asset amount.
        l_message_name := 'OKL_LLA_FUND_TOT_ASSET_AMT_CHK';
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    ELSIF (p_tapv_rec.funding_type_code ='EXPENSE') THEN

      -- 1. check expense
      -- get current total HAS BEEN approved amount for EXPENSE
      OPEN c_tot_expense_fund(p_tapv_rec.khr_id, p_tapv_rec.ipvs_id);
      FETCH c_tot_expense_fund INTO l_cur_total_amount;
      CLOSE c_tot_expense_fund;

      l_resuts_amount := l_cur_total_amount + l_cur_amount;
      IF (l_resuts_amount > l_total_canbe_expense_amount) THEN

        l_message_name := 'OKL_LLA_EXPENSE_AMT_CHK';
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    -- check for any kind of requests
    -- check total can be funded
    l_resuts_amount := l_total_hasbeen_funded_amount + l_cur_amount;

    -- exclude prefunding and supplier retention
    -- exclude manual disb
    IF (p_tapv_rec.funding_type_code NOT IN ('PREFUNDING', 'SUPPLIER_RETENTION', 'MANUAL_DISB')) THEN

      IF (l_resuts_amount > l_total_canbe_funded_amount) THEN

        l_message_name := 'OKL_LLA_FUNDED_AMT_CHK';
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => l_message_name);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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

  --------------------------------------------------------------------------
-- Revolving line of credit contract allows adjustment funding request.
-- Funding module implement adjustment request by Pre-funding type with
-- negative request amount

  --------------------------------------------------------------------------

  FUNCTION validate_header_amount_for_RL(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_loan_rev        NUMBER := 0;
    l_loan_row_found  boolean := false;

-- bug 2604862
  CURSOR c_loan_revolving (p_contract_id  NUMBER)

  IS
  select 1 from OKL_K_HEADERS khr
  where khr.id = p_contract_id
  and khr.deal_type = 'LOAN-REVOLVING';

  BEGIN

-- bug 2604862
    OPEN c_loan_revolving(p_tapv_rec.khr_id);
    FETCH c_loan_revolving INTO l_loan_rev;
    l_loan_row_found := c_loan_revolving%FOUND;
    CLOSE c_loan_revolving;

    -- is loan revolving contract
    IF (l_loan_row_found) THEN
      IF (p_tapv_rec.funding_type_code = 'PREFUNDING' AND nvl(p_tapv_rec.amount,0) >= 0 ) THEN
        --Please enter negative amount for your adjustment. Revolving line of credit loan contract are not allowed for pre-funding request with positive amount.
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_LLA_REVLOAN_ADJ_AMT_CHK');
        RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      IF (p_tapv_rec.funding_type_code = 'BORROWER_PAYMENT' AND nvl(p_tapv_rec.amount,0) < 0 ) THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_POSITIVE_AMOUNT_ONLY',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Amount');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;
-- bug 2604862


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

  --------------------------------------------------------------------------
  ----- Populate additional attributes for BPD
  --------------------------------------------------------------------------
  FUNCTION populate_more_attrs(
    p_tapv_rec                  IN OUT NOCOPY tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--    l_set_of_books_id NUMBER;
    l_terms_id NUMBER;
    l_application_id NUMBER;
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

    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';--'OKL Lease Receipt Invoices';
    l_okl_application_id number(3) := 540;

    lX_dbseqnm           VARCHAR2(2000):= '';
    lX_dbseqid           NUMBER(38):= NULL;

  BEGIN

/*
-- 1. SET_OF_BOOKS_ID
    OPEN c_set_of_books(p_tapv_rec.org_id);
    FETCH c_set_of_books INTO l_set_of_books_id;
    CLOSE c_set_of_books;
*/

  p_tapv_rec.SET_OF_BOOKS_ID := OKL_ACCOUNTING_UTIL.get_set_of_books_id;--l_set_of_books_id;
-- 2. IPPT_ID
  -- cklee 05/04/2004
    IF (p_tapv_rec.IPPT_ID IS NULL or
        p_tapv_rec.IPPT_ID = OKL_API.G_MISS_NUM) THEN

      OPEN c_vendor_sites(p_tapv_rec.ipvs_id);
      FETCH c_vendor_sites INTO l_terms_id, l_pay_group_lookup_code;
      CLOSE c_vendor_sites;

      p_tapv_rec.IPPT_ID := l_terms_id;

    END IF;

-- 3. INVOICE_NUMBER

    OPEN c_app;

    FETCH c_app INTO l_application_id;
    CLOSE c_app;

    l_okl_application_id := nvl(l_application_id,540);
--
-- display specific application error if 'OKL Lease Pay Invoices' has not been setup or setup incorrectly
--
    BEGIN
      p_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
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
      p_tapv_rec.vendor_invoice_number := p_tapv_rec.invoice_number;
    END IF;

-- 4. NETTABLE_YN
  p_tapv_rec.NETTABLE_YN := 'N';

-- 5. PAY_GROUP_LOOKUP_CODE
  -- cklee 05/04/2004
    IF (p_tapv_rec.PAY_GROUP_LOOKUP_CODE IS NULL or
        p_tapv_rec.PAY_GROUP_LOOKUP_CODE = OKL_API.G_MISS_CHAR) THEN

-- fixed PAY_GROUP_LOOKUP_CODE default data missing issues
      OPEN c_vendor_sites(p_tapv_rec.ipvs_id);
      FETCH c_vendor_sites INTO l_terms_id, l_pay_group_lookup_code;
      CLOSE c_vendor_sites;

      p_tapv_rec.PAY_GROUP_LOOKUP_CODE := l_pay_group_lookup_code;

    END IF;

-- 6. vednor id
    OPEN c_vendor(p_tapv_rec.ipvs_id);
    FETCH c_vendor INTO l_vendor_id;
    CLOSE c_vendor;

  p_tapv_rec.VENDOR_ID := l_vendor_id;

-- 7. invoice_type
-- cklee 05/04/2004

   IF (p_tapv_rec.INVOICE_TYPE is null or
       p_tapv_rec.INVOICE_TYPE = OKL_API.G_MISS_CHAR) THEN

     p_tapv_rec.INVOICE_TYPE := G_STANDARD;

   END IF;
--start:| 06-Aug-08  cklee Fixed bug: 6860777                                        |
/* system shall not convert wrong data to correct data, instead, display error and request user
to fix before proceed.
    -- 8. If invoice type is G_STANDARD then invoice amount is positive
    --    If invoice type is G_CREDIT then the invoice amount is negative.
    --    sjalasut, made changes to incorporate the business rule as part
    --    of OKLR12B Disbursements Project
    IF((p_tapv_rec.INVOICE_TYPE = G_STANDARD AND p_tapv_rec.AMOUNT < 0)
       OR(p_tapv_rec.INVOICE_TYPE = G_CREDIT AND p_tapv_rec.AMOUNT > 0))THEN
      p_tapv_rec.AMOUNT := ((p_tapv_rec.AMOUNT) * (-1));
    END IF;
*/
--end:| 06-Aug-08  cklee Fixed bug: 6860777                                        |

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

  --------------------------------------------------------------------------
  ----- Validate vendor site ID
  --------------------------------------------------------------------------
  FUNCTION validate_chr_status(
    p_chr_id                  IN NUMBER
  ) RETURN VARCHAR2

  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_status          OKC_STATUSES_V.meaning%TYPE;

  CURSOR c_sts (p_contract_id  NUMBER)
  IS
select ste.meaning
from   OKC_STATUSES_V ste,
       okc_k_headers_b chr
where  ste.code = chr.sts_code
and    chr.id = p_chr_id
;

  BEGIN

    IF (okl_funding_pvt.is_chr_fundable_status(p_chr_id) = 0) THEN

      OPEN c_sts(p_chr_id);
      FETCH c_sts INTO l_status;
      CLOSE c_sts;

      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_INVALID_FUNDED_REQUEST',
                          p_token1       => 'CHR_STATUS',
                          p_token1_value => l_status);
      RAISE G_EXCEPTION_HALT_VALIDATION;
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

  --------------------------------------------------------------------------
  ----- Validate line of credit attach to funded contract
  --------------------------------------------------------------------------
  FUNCTION validate_creditline(
    p_tapv_rec                  IN tapv_rec_type
 ) RETURN VARCHAR2


IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_REVOLVING_CREDIT_YN  OKL_K_HEADERS.REVOLVING_CREDIT_YN%TYPE;
    l_END_DATE  OKC_K_HEADERS_B.END_DATE%TYPE;

    l_DEAL_TYPE  OKL_K_HEADERS.DEAL_TYPE%TYPE;
    l_creditline_row_found  boolean := false;
    l_credit_id okc_k_headers_b.id%TYPE;

  CURSOR c_contract (p_contract_id  NUMBER)
  IS
  select a.DEAL_TYPE
  from   OKL_K_HEADERS a
  where  a.id = p_contract_id
  ;

  CURSOR c_credit (p_credit_id  NUMBER)
  IS
  select khr.REVOLVING_CREDIT_YN,
         NVL(chr.END_DATE, SYSDATE)
  from   okl_k_headers khr,
         okc_k_headers_b chr
  where  khr.id = chr.id
  and    chr.id = p_credit_id
  ;


begin

    -- 1) get deal type
    OPEN c_contract(p_tapv_rec.khr_id);
    FETCH c_contract INTO l_DEAL_TYPE;
    CLOSE c_contract;

    -- 2) get revolving flag
    l_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_tapv_rec.khr_id);

    OPEN c_credit(l_credit_id);
    FETCH c_credit INTO l_REVOLVING_CREDIT_YN,
                          l_END_DATE;
    l_creditline_row_found := c_credit%FOUND;
    CLOSE c_credit;

    IF (l_creditline_row_found) THEN

      IF ((l_DEAL_TYPE = 'LOAN-REVOLVING' AND l_REVOLVING_CREDIT_YN <> 'Y')
          OR

          (l_DEAL_TYPE <> 'LOAN-REVOLVING' AND l_REVOLVING_CREDIT_YN = 'Y')) THEN

           --Either Revolving line of credit attach to a normal contract (book classification is not LOAN-REVOLVING)
           -- or non-revolving line of credit attach to LOAN-REVOLVING contract.
           -- Invalid credit line attach to funding request contract.
            OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDITLINE_CHECK');

            RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

      IF (trunc(l_END_DATE) < trunc(SYSDATE)) THEN
            OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDITLINE_EXPIRED');

            RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    ELSE -- creditline not found

--      IF (p_tapv_rec.funding_type_code NOT IN (G_SUPPLIER_RETENTION_TYPE_CODE,G_MANUAL_DISB)) THEN
--        -- There is no credit line for funding request contract.
-- start: 23-May-2005  cklee okl.h Lease App IA Authoring
-- Credit Line is not required after okl.h except loan-revolving contract
--
      IF l_DEAL_TYPE = 'LOAN-REVOLVING' THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDITLINE_NOTFOUND');

        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
-- end: 23-May-2005  cklee okl.h Lease App IA Authoring

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

  --------------------------------------------------------------------------
  ----- Validate Funding (Invoice) Number...
  --------------------------------------------------------------------------
  FUNCTION validate_vendor_invoice_number(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
  BEGIN
    -- Invoice Number is required:
    --   TO DO: When in 'C'reate mode - allow user to omit invoice
    --          (funding request) number and generate one automatically,
    --          assuring that the invoice number and vendor id
    --          combination is unique in OKL_TRX_AP_INVOICES_V (OKL) and
    --          in the AP_INVOICES_ALL (AP).

    IF (p_tapv_rec.vendor_invoice_number IS NULL) OR
       (p_tapv_rec.vendor_invoice_number = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Request Number');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- due to the external interface table limit to 30 chars
    IF (length(p_tapv_rec.vendor_invoice_number) > 30)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_EXCEED_MAXIMUM_LENGTH',
                          p_token1       => 'MAX_CHARS',
                          p_token1_value => 'thirty',
                          p_token2       => 'COL_NAME',
                          p_token2_value => 'Request Number');

      RAISE G_EXCEPTION_HALT_VALIDATION;
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

  --------------------------------------------------------------------------
  ----- Validate vendor site ID
  --------------------------------------------------------------------------
  FUNCTION validate_ipvs_id(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_dum number;
    l_rl_found boolean;
    l_lv_found boolean;

cursor c_rl(p_khr_id number) is
  select 1
from OKL_K_HEADERS khr
where khr.id = p_khr_id
and   khr.deal_type = 'LOAN-REVOLVING';

cursor c_lv(p_khr_id number) is
  select 1
from okl_fund_vendor_sites_uv vs
where vs.dnz_chr_id = p_khr_id;


  BEGIN
    IF (p_tapv_rec.ipvs_id IS NULL) OR
       (p_tapv_rec.ipvs_id = OKL_API.G_MISS_NUM)
    THEN

-- 10-10-2003 cklee fixed bug# 3159723
      open c_rl(p_tapv_rec.khr_id);
      fetch c_rl into l_dum;
      l_rl_found := c_rl%FOUND;
      close c_rl;

      IF (l_rl_found) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_LESSEE_AS_VENDOR_CHK');
      ELSE

        open c_lv(p_tapv_rec.khr_id);
        fetch c_lv into l_dum;
        l_lv_found := c_lv%FOUND;
        close c_lv;

        IF (l_lv_found) THEN

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Vendor Site');
        ELSE

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_FUNDING_VENDOR_CHK');

        END IF;
      END IF;


      RAISE G_EXCEPTION_HALT_VALIDATION;
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

  --------------------------------------------------------------------------
  ----- Validate Funding Type...
  --------------------------------------------------------------------------
  FUNCTION validate_funding_type(
    p_tapv_rec                  IN tapv_rec_type
   ,p_mode                            IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_loan_rev NUMBER := 0;
    l_loan_row_found  boolean := false;
    l_prefunding_eligible_yn okl_k_headers.PREFUNDING_ELIGIBLE_YN%type;
    l_trx_status_code okl_trx_ap_invoices_b.trx_status_code%type;
    l_reverse_row_notfound  boolean := false;
    l_dummy number;

  CURSOR c_prefund (p_contract_id  NUMBER)
  IS
  select nvl(khr.PREFUNDING_ELIGIBLE_YN, 'N')
  from   OKL_K_HEADERS khr
  where  khr.id = p_contract_id
;

  CURSOR c_curr_trx_sts (p_req_id  NUMBER)
  IS
  select trx_status_code
  from   OKL_TRX_AP_INVOICES_B
  where  id = p_req_id
;


-- bug 2604862
  CURSOR c_loan_revolving (p_contract_id  NUMBER)
  IS
  select 1 from OKL_K_HEADERS khr
  where khr.id = p_contract_id
  and khr.deal_type = 'LOAN-REVOLVING';

-- cklee 09-24-03
  -- sjalasut, modified the below cursor to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b.
  -- also not using okl_cnsld_ap_invoices_all as this cursor only checks
  -- for a pre-funding request.
  Cursor c_reverse_chk(p_contract_id number)
  is
  select 1
  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.vendor_invoice_number = a.invoice_number
  and b.khr_id = p_contract_id;

  BEGIN

-- bug 2604862
    OPEN c_loan_revolving(p_tapv_rec.khr_id);
    FETCH c_loan_revolving INTO l_loan_rev;
    l_loan_row_found := c_loan_revolving%FOUND;
    CLOSE c_loan_revolving;

    -- is loan revolving contract
    IF (l_loan_row_found) THEN
      IF (p_tapv_rec.funding_type_code NOT IN ('PREFUNDING','BORROWER_PAYMENT', 'MANUAL_DISB') ) THEN

        --Revolving line of credit loan contract are not allowed for TOKEN funding type.
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_LLA_REVLOAN_FUNDTYPE_CHK',
                          p_token1       => 'COL_NAME',
                          p_token1_value => p_tapv_rec.funding_type_code);

        RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;


    ELSE -- is not revolvong line of credit loan contract
      IF (p_tapv_rec.funding_type_code IN ('BORROWER_PAYMENT') ) THEN

        --Borrower payment funding type is allow for revolving line of credit loan contract only.
        OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_LLA_FUNDING_TYPE_CHK');
        RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    END IF;
-- bug 2604862

    -- funding_type_code is required
    IF (p_tapv_rec.funding_type_code IS NULL) OR
       (p_tapv_rec.funding_type_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Funding Type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    IF (p_mode = 'U') THEN

      -- get current req status
      OPEN c_curr_trx_sts(p_tapv_rec.id);
      FETCH c_curr_trx_sts INTO l_trx_status_code;
      CLOSE c_curr_trx_sts;


      -- check when submit for approval
      IF (l_trx_status_code = 'ENTERED' AND
          p_tapv_rec.trx_status_code in ('SUBMITTED','APPROVED')) THEN

        -- prefunding eligible flag check
        OPEN c_prefund(p_tapv_rec.khr_id);
        FETCH c_prefund INTO l_prefunding_eligible_yn;
        CLOSE c_prefund;

        -- cklee 09-25-2003 added p_tapv_rec.amount > 0
        IF ( p_tapv_rec.funding_type_code = 'PREFUNDING' AND p_tapv_rec.amount > 0 AND
             l_prefunding_eligible_yn <> 'Y') THEN

          OPEN c_reverse_chk(p_tapv_rec.khr_id);
          FETCH c_reverse_chk INTO l_dummy;
          l_reverse_row_notfound := c_reverse_chk%NOTFOUND;
          CLOSE c_reverse_chk;

          -- CKLEE 02-24-2003 :internal request will have the same value for these 2 columns
          IF (l_reverse_row_notfound) THEN
            -- You are not allowed to submit pre-funding request if Eligible For Pre-Funding
            -- has not been set for this contract.
            OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKL_LLA_PREFUND_ELIGIBLE_CHK');
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

        END IF;
      END IF;
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

  --------------------------------------------------------------------------
  ----- Validate Payment Method...
  --------------------------------------------------------------------------
  FUNCTION validate_payment_method(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- payment_method_code is required
    IF (p_tapv_rec.payment_method_code IS NULL) OR
       (p_tapv_rec.payment_method_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Payment Method');
      RAISE G_EXCEPTION_HALT_VALIDATION;
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

  -- cklee 05/04/2004
  --------------------------------------------------------------------------
  ----- Validate invoice type..
  --------------------------------------------------------------------------
  FUNCTION validate_invoice_type(
    p_tapv_rec                  IN tapv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_funding_type varchar2(80);

  cursor c_funding_type (p_funding_type_code varchar2)
    is
  select lok.meaning
  from fnd_lookups lok
  where lok.lookup_type = 'OKL_FUNDING_TYPE'
  and lok.lookup_code = p_funding_type_code
  ;

  BEGIN

    -- check if value exists
    IF (p_tapv_rec.invoice_type IS NOT NULL) AND
       (p_tapv_rec.invoice_type <> OKL_API.G_MISS_CHAR)
    THEN

--start: cklee 3/01/07 added invoice type and amount sign check at line level
/*
      IF (p_tapv_rec.funding_type_code = G_SUPPLIER_RETENTION_TYPE_CODE and
          p_tapv_rec.invoice_type <> G_CREDIT) OR
         (p_tapv_rec.funding_type_code NOT IN (G_SUPPLIER_RETENTION_TYPE_CODE, G_MANUAL_DISB) and
          p_tapv_rec.invoice_type = G_CREDIT) THEN
*/
      IF (p_tapv_rec.funding_type_code in (G_SUPPLIER_RETENTION_TYPE_CODE, G_ASSET_SUBSIDY) and
          p_tapv_rec.invoice_type <> G_CREDIT) OR
         (p_tapv_rec.funding_type_code in (G_EXPENSE, G_ASSET_TYPE_CODE, G_BORROWER_PAYMENT_TYPE_CODE) and
          p_tapv_rec.invoice_type <> G_STANDARD) THEN
--start: cklee 3/01/07 added invoice type and amount sign check at line level

        open c_funding_type(p_tapv_rec.funding_type_code);
        fetch c_funding_type into l_funding_type;
        close c_funding_type;

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUNDING_INVOICE_TYPE',
                            p_token1       => 'INVOICE_TYPE',
                            p_token1_value => p_tapv_rec.invoice_type,
                            p_token2       => 'FUNDING_TYPE',
                            p_token2_value => l_funding_type);

        RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

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

  -------------------------------------------------------------------------
  -- validate_invoice_type_and_sign
  -- sjalasut, added this function to implement new business validation
  -- that when the invoice_type is STANDARD, the invoice amount should be
  -- positive and when the invoice_type is CREDIT, invoice amount should be
  -- negative.
  -------------------------------------------------------------------------
  FUNCTION validate_invoice_type_and_sign(p_tapv_rec IN tapv_rec_type
                                         ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- If invoice type is G_STANDARD then invoice amount is positive
    -- If invoice type is G_CREDIT then the invoice amount is negative.
    -- sjalasut, made changes to incorporate the business rule as part
    -- of OKLR12B Disbursements Project

--start: cklee 03/01/07 added the following condition, somehow UI has passed
-- wrong data.
  IF p_tapv_rec.trx_status_code = 'ENTERED' THEN
--end: cklee 03/01/07 added the following condition, somehow UI has passed
-- wrong data.
    IF((p_tapv_rec.INVOICE_TYPE = G_STANDARD AND p_tapv_rec.AMOUNT < 0)
       OR(p_tapv_rec.INVOICE_TYPE = G_CREDIT AND p_tapv_rec.AMOUNT > 0))THEN
      OKL_API.set_message(
                          p_app_name => G_APP_NAME
                         ,p_msg_name => 'OKL_LLA_INV_TYPE_AND_SIGN'
                         );
      RAISE G_EXCEPTION_HALT_VALIDATION;
--start: cklee 03/01/07 added the following condition, somehow UI has passed
-- wrong data.
    END IF;
--end: cklee 03/01/07 added the following condition, somehow UI has passed
-- wrong data.
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
  END validate_invoice_type_and_sign;

  --------------------------------------------------------------------------
  ----- Validate kle_id (contract line id)... Real version by chenkuang.lee
  ----- 1) if funding_type_code = 'ASSET'
  ----- 2) check required only, OKLSTPLB.pls will check FK for kle_id
  --------------------------------------------------------------------------

  FUNCTION validate_kle_id(
    p_tplv_rec                 IN tplv_rec_type
    ,p_mode                    IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy       VARCHAR2(1) := '?';
    l_result VARCHAR2(1) := OKL_API.G_TRUE;

    CURSOR c (p_tap_id NUMBER)
    IS
      SELECT 'X'
        FROM OKL_TRX_AP_INVOICES_B
       WHERE id = p_tap_id
       AND funding_type_code = 'ASSET'
    ;
  BEGIN

    OPEN c (p_tplv_rec.tap_id);
    FETCH c INTO l_dummy;
    CLOSE c;


    IF (l_dummy = 'X') THEN

      -- kle_id is required:
      IF (p_tplv_rec.kle_id IS NULL) OR
         (p_tplv_rec.kle_id = OKL_API.G_MISS_NUM)
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
--START:| 30-May-2006  cklee -- Fixed bug#5241187                                    |
--                          p_token1_value => 'Contract Top Line'); -- kle_id (contract_line_id) assoc asset number
                          p_token1_value => 'Asset Number'); -- kle_id (contract_line_id) assoc asset number
--END:| 30-May-2006  cklee -- Fixed bug#5241187                                    |
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check uniqueness
      l_result := is_contract_line_unique(
                          p_kle_id   => p_tplv_rec.kle_id
                          ,p_fund_id => p_tplv_rec.tap_id

                          ,p_fund_line_id => p_tplv_rec.id
                          ,p_mode    => p_mode);
      IF (l_result = OKL_API.G_FALSE) THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NOT_UNIQUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Asset Number');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

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
  --------------------------------------------------------------------------
  ----- Validate kle_id (contract line id)
  ----- 1) if funding_type_code = 'ASSET'
  ----- 2) check required only, OKLSTPLB.pls will check FK for kle_id
  ----- 3) check pl/sql table before check DB, something wrong with the DB
  -----    transaction control or some problem with the code logic
  --------------------------------------------------------------------------

 FUNCTION validate_table_kle_id(
    p_tplv_tbl                 IN tplv_tbl_type

 ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_dummy       VARCHAR2(1) := '?';
    l_result VARCHAR2(1) := OKL_API.G_TRUE;

    CURSOR c (p_tap_id NUMBER)

    IS
      SELECT 'X'

        FROM OKL_TRX_AP_INVOICES_B
       WHERE id = p_tap_id
       AND funding_type_code = 'ASSET'
    ;
  BEGIN

    OPEN c (p_tplv_tbl(p_tplv_tbl.FIRST).tap_id);
    FETCH c INTO l_dummy;
    CLOSE c;

    IF (l_dummy = 'X') THEN

      -- check uniqueness
      l_result := is_kle_id_unique(p_tplv_tbl=>p_tplv_tbl);

      IF (l_result = OKL_API.G_FALSE) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NOT_UNIQUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Asset Number');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

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
  --------------------------------------------------------------------------
  ----- Validate Stream Type ID... Real version by chenkuang.lee
  ----- 1) if funding_type_code = 'SUPPLIER_RETENTION'
  ----- 2) check required only, OKLSTPLB.pls will check FK for sty_id
  --------------------------------------------------------------------------

  FUNCTION validate_stream_id(
    p_tplv_rec                 IN tplv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy       VARCHAR2(1) := '?';

    CURSOR c (p_tap_id NUMBER)
    IS
      SELECT 'X'
        FROM OKL_TRX_AP_INVOICES_B
       WHERE id = p_tap_id
       AND funding_type_code in ('SUPPLIER_RETENTION', 'EXPENSE')
    ;
  BEGIN

    OPEN c (p_tplv_rec.tap_id);
    FETCH c INTO l_dummy;
    CLOSE c;

    IF (l_dummy = 'X') THEN
      -- Stream Type ID is required:
      IF (p_tplv_rec.sty_id IS NULL) OR
         (p_tplv_rec.sty_id = OKL_API.G_MISS_NUM)
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Stream Type'); -- sty_id
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  --------------------------------------------------------------------------
  ----- Validate Funding Line Amount...
  --------------------------------------------------------------------------

  FUNCTION validate_line_amount(
    p_tplv_rec                  IN tplv_rec_type
    ,p_mode                     IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_api_version           NUMBER := 1.0;
    l_init_msg_list         VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    x_value                 NUMBER := 0;
    l_chr_id                NUMBER;
    l_funding_type_code     VARCHAR2(30);
    l_cur_total_amount      NUMBER := 0;
    l_cur_amount            NUMBER := 0;
    l_results_amount        NUMBER := 0;
    l_message_name          VARCHAR2(30);
--start: cklee 3/01/07 added invoice type and amount sign check at line level

  l_invoice_type okl_trx_ap_invoices_b.invoice_type%type;
  cursor c_invoice_type (p_tap_id number)is
    select invoice_type
    from okl_trx_ap_invoices_b
    where id = p_tap_id;

--end: cklee 3/01/07 added invoice type and amount sign check at line level

  BEGIN
    -- line Amount is required: default to 0 @ UI
    IF (p_tplv_rec.amount IS NULL) OR
       (p_tplv_rec.amount = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Amount');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--start: cklee 3/01/07 added invoice type and amount sign check at line level
    -- If invoice type is G_STANDARD then invoice amount is positive
    -- If invoice type is G_CREDIT then the invoice amount is negative.
    -- cklee, made changes to incorporate the business rule as part
    -- of OKLR12B Disbursements Project
    open c_invoice_type(p_tplv_rec.tap_id);
    fetch c_invoice_type into l_invoice_type;
    close c_invoice_type;

    IF((l_invoice_type = G_STANDARD AND p_tplv_rec.AMOUNT < 0)
       OR(l_invoice_type = G_CREDIT AND p_tplv_rec.AMOUNT > 0))THEN
      OKL_API.set_message(
                          p_app_name => G_APP_NAME
                         ,p_msg_name => 'OKL_LLA_INV_TYPE_AND_SIGN'
                         );
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--end: cklee 3/01/07 added invoice type and amount sign check at line level

    -- sjalasut, commented the following code as part of OKLR12B disbursements
    -- project.
    /*
    IF (p_tplv_rec.amount < 0 ) THEN

      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_POSITIVE_AMOUNT_ONLY',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Amount');


      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */
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

  --------------------------------------------------------------------------
  FUNCTION validate_header_attributes(
    p_tapv_rec                        IN tapv_rec_type
   ,p_mode                            IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete

  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_vendor_id PO_VENDOR_SITES_ALL.vendor_id%TYPE;
    l_org_id okc_k_headers_b.AUTHORING_ORG_ID%TYPE;


cursor c_vs (p_vendor_site_id number)
is
select vs.vendor_id
from PO_VENDOR_SITES_ALL VS
where vs.vendor_site_id = p_vendor_site_id;

cursor c_org (p_khr_id number)
is
select chr.AUTHORING_ORG_ID
from okc_k_headers_b chr
where chr.id = p_khr_id;


  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_trx_status_code(p_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Do formal attribute validation:
    l_return_status := validate_payment_due_date(p_tapv_rec);

    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- funding checklist enhancement for 11.5.9
-- to be able to copy funding checklist from associated credit line contract, user has to
-- select valid credit line before create a funding request

--
    l_return_status := validate_creditline(p_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- funding checklist enhancement for 11.5.9

-- cklee 01/30/03 check at approved until integrated with WF
-- cklee 06/24/03 WF enable, change check to 'SUBMITTED'
    IF (upper(p_mode) = 'U' AND p_tapv_rec.trx_status_code in ('SUBMITTED','APPROVED')) THEN

      l_return_status := validate_chr_status(p_tapv_rec.khr_id);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_return_status := validate_header_amount(p_tapv_rec);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    l_return_status := validate_funding_checklist(p_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- bug 2604862
    l_return_status := validate_header_amount_for_RL(p_tapv_rec);

    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
-- bug 2604862

    IF (p_tapv_rec.FUNDING_TYPE_CODE <> G_ASSET_SUBSIDY) THEN -- cklee 09/17/03
      l_return_status := validate_vendor_invoice_number(p_tapv_rec);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    l_return_status := validate_ipvs_id(p_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_funding_type(p_tapv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- Added for bug 5704212 -- start
       l_return_status := validate_release_contract(p_tapv_rec);
       --- Store the highest degree of error
       IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
         END IF;
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       -- Added for bug 5704212 - End

    l_return_status := validate_payment_method(p_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- 05/04/2004 cklee
    l_return_status := validate_invoice_type(p_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- sjalasut, added the function validate_invoice_type_and_sign
    -- as part of OKLR12B disbursements project
    l_return_status := validate_invoice_type_and_sign(p_tapv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- don't allow to change Request number (invoice number) at update mode
    IF (p_mode = 'C') THEN
-- fixed uniqueness check for funding vendor_invoice_number. pass vendor_site_id, org_id
      open c_vs(p_tapv_rec.ipvs_id);
      fetch c_vs into l_vendor_id;
      close c_vs;

      open c_org(p_tapv_rec.khr_id);
      fetch c_org into l_org_id;
      close c_org;

      l_return_status := is_funding_unique(
                          p_vendor_id    => l_vendor_id
                          ,p_org_id      => l_org_id
                          ,p_fund_number => p_tapv_rec.vendor_invoice_number);

      IF (l_return_status = OKL_API.G_FALSE) THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NOT_UNIQUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Request Number');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN


      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

      RETURN l_return_status;
  END validate_header_attributes;

  --------------------------------------------------------------------------
  FUNCTION validate_line_attributes(
    p_tplv_rec                      IN tplv_rec_type
   ,p_mode                          IN VARCHAR2 -- 'C'reate,'U'pdate,'D'elete
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- Do formal attribute validation:
    -- check sty_id
    l_return_status := validate_stream_id(p_tplv_rec);

    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN

        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION; -- 09/2001: one error at a time until Okx/Java can accept more
    END IF;

    -- check kle_id
    l_return_status := validate_kle_id(p_tplv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION; -- 09/2001: one error at a time until Okx/Java can accept more
    END IF;

    l_return_status := validate_line_amount(p_tplv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_line_attributes;

  --------------------------------------------------------------------------
  ----- Populate additional attributes (sty_id) for line
  --------------------------------------------------------------------------
  FUNCTION populate_sty_id(
    p_tplv_rec                  IN OUT NOCOPY tplv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_stream_id           NUMBER;
    l_chr_id              NUMBER;
    l_name                VARCHAR2(30);
    l_funding_type_code okl_trx_ap_invoices_b.funding_type_code%TYPE;

    CURSOR stream_c(p_name VARCHAR2)
    IS
    SELECT id
    FROM  OKL_STRM_TYPE_V
    where name = p_name
    ;

    -- sjalasut, modified the cursor below to have khr_id referred from
    -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b.
    -- changes made as part of OKLR12B disbursements project.
    --vpanwar added 28/02/2007 for provide khr_id from p_tplv_rec.khr_id  ..start
    /*CURSOR c_funding_type (p_tap_id NUMBER)
    IS
    select tap.funding_type_code , tpl.khr_id
    from okl_trx_ap_invoices_b tap
        ,okl_txl_ap_inv_lns_all_b tpl
    where tap.id = p_tap_id
      and tap.id = tpl.tap_id;*/

    CURSOR c_funding_type (p_tap_id NUMBER)
    IS
    select tap.funding_type_code /*, tpl.khr_id*/
    from okl_trx_ap_invoices_b tap
        /*,okl_txl_ap_inv_lns_all_b tpl*/
    where tap.id = p_tap_id
      /*and tap.id = tpl.tap_id*/;
    --vpanwar added 28/02/2007 end

  BEGIN


      OPEN  c_funding_type(p_tplv_rec.tap_id);
      FETCH  c_funding_type INTO l_funding_type_code/*, l_chr_id*/;
      CLOSE  c_funding_type;

    --vpanwar added 28/02/2007 start
      l_chr_id := p_tplv_rec.khr_id;
    --vpanwar added 28/02/2007 end

      IF (l_funding_type_code = G_PREFUNDING_TYPE_CODE) THEN
        l_name := G_STY_PURPOSE_CODE_PREFUNDING;
      ELSIF (l_funding_type_code = G_BORROWER_PAYMENT_TYPE_CODE) THEN
        l_name := G_STY_PURPOSE_CODE_P_BALANCE;
      ELSE
        l_name := G_STY_PURPOSE_CODE_FUNDING;
      END IF;

/*
      OPEN  stream_c(l_name);
      FETCH  stream_c INTO l_stream_id;
      CLOSE  stream_c;
*/

-- cklee: user defined stream changes
      IF (l_funding_type_code = G_BORROWER_PAYMENT_TYPE_CODE) THEN

        Okl_Streams_Util.GET_DEPENDENT_STREAM_TYPE(
               p_khr_id                => l_chr_id,
               p_primary_sty_purpose   => 'RENT',
               p_dependent_sty_purpose => l_name,
               x_return_status         => l_return_status,
               x_dependent_sty_id      => l_stream_id );

      ELSE

        Okl_Streams_Util.GET_PRIMARY_STREAM_TYPE(
               p_khr_id              => l_chr_id,
               p_primary_sty_purpose => l_name,
               x_return_status       => l_return_status,
               x_primary_sty_id      => l_stream_id );

      END IF;
--cklee user defined stream type modification

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- only fill if sty_id not exists
      IF (l_funding_type_code in (G_PREFUNDING_TYPE_CODE,
                                  G_ASSET_TYPE_CODE,
                                  G_BORROWER_PAYMENT_TYPE_CODE)) THEN
        p_tplv_rec.sty_id := l_stream_id;
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
  END populate_sty_id;
----------------------------------------------------------------------------

 PROCEDURE SYNC_HEADER_AMOUNT(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tplv_tbl                     IN tplv_tbl_type
)

IS
  l_api_name        CONSTANT VARCHAR2(30) := 'SYNC_HEADER_AMOUNT';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tapv_rec        tapv_rec_type;
  x_tapv_rec        tapv_rec_type;
  j                 BINARY_INTEGER;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_id                     OKL_TRX_AP_INVOICES_B.ID%TYPE;
  l_funding_type_code      OKL_TRX_AP_INVOICES_B.funding_type_code%TYPE;
  l_VENDOR_INVOICE_NUMBER  OKL_TRX_AP_INVOICES_B.VENDOR_INVOICE_NUMBER%TYPE;
  l_PAY_GROUP_LOOKUP_CODE  OKL_TRX_AP_INVOICES_B.PAY_GROUP_LOOKUP_CODE%TYPE;
  l_NETTABLE_YN            OKL_TRX_AP_INVOICES_B.NETTABLE_YN%TYPE;
  l_amount                 OKL_TRX_AP_INVOICES_B.AMOUNT%TYPE := 0;
  l_INVOICE_TYPE           OKL_TRX_AP_INVOICES_B.INVOICE_TYPE%TYPE;

    CURSOR c (p_id NUMBER)
    IS
      SELECT h.id,
             h.funding_type_code,
             h.VENDOR_INVOICE_NUMBER,
             h.PAY_GROUP_LOOKUP_CODE,
             h.NETTABLE_YN,
             h.INVOICE_TYPE
        FROM OKL_TRX_AP_INVOICES_B h
       WHERE h.id = p_id
    ;

BEGIN

    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name,
                               p_init_msg_list,
                               '_PVT',
                               x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--

--*** Begin API body ****************************************************

    OPEN c (p_tplv_tbl(p_tplv_tbl.FIRST).tap_id);
    FETCH c INTO l_id,
                 l_funding_type_code,
                 l_VENDOR_INVOICE_NUMBER,
                 l_PAY_GROUP_LOOKUP_CODE,
                 l_NETTABLE_YN,
                 l_INVOICE_TYPE;
    CLOSE c;

    -- set default
    l_amount := OKL_FUNDING_PVT.get_contract_line_funded_amt(l_id, l_funding_type_code);
    -- fill in all necessary attributes
    l_tapv_rec.id := l_id;
    l_tapv_rec.amount:= nvl(l_amount,0);
    l_tapv_rec.VENDOR_INVOICE_NUMBER := l_VENDOR_INVOICE_NUMBER;
    l_tapv_rec.PAY_GROUP_LOOKUP_CODE := l_PAY_GROUP_LOOKUP_CODE;
    l_tapv_rec.NETTABLE_YN := l_NETTABLE_YN;
    l_tapv_rec.INVOICE_TYPE := l_INVOICE_TYPE;

    OKL_TRX_AP_INVOICES_PUB.UPDATE_TRX_AP_INVOICES(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

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
  END;

----------------------------------------------------------------------------
-- Public Procedures and Functions
----------------------------------------------------------------------------

PROCEDURE create_funding_header(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tapv_rec                     IN tapv_rec_type
 ,x_tapv_rec                     OUT NOCOPY tapv_rec_type

)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_HEADER';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tapv_rec                 tapv_rec_type := p_tapv_rec;
  i                          NUMBER;
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := OKL_API.G_TRUE;
    l_try_id NUMBER;
    l_org_id NUMBER;
   l_try_name OKL_TRX_TYPES_TL.NAME%TYPE;

--
--
  l_tplv_rec        tplv_rec_type;
  x_tplv_rec        tplv_rec_type;
--
--

    CURSOR l_tryv_csr(p_try_name varchar2) IS
select TRYB.ID
FROM
  OKL_TRX_TYPES_B TRYB,
  OKL_TRX_TYPES_TL TRYT
WHERE
  TRYB.ID = TRYT.ID and
  TRYT.LANGUAGE = 'US' and
  TRYT.NAME = p_try_name; -- cklee 05/04/2004


    CURSOR l_org_id_csr(p_chr_id number) IS
      SELECT chr.authoring_org_id
      FROM okc_k_headers_b chr
      WHERE chr.id = p_chr_id;




  --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM okc_k_headers_b
  WHERE id = p_ctr_id1;

  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

BEGIN
  -- Set API savepoint

  SAVEPOINT CREATE_FUNDING_HEADER_PVT;

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

    IF (p_tapv_rec.funding_type_code = G_MANUAL_DISB) THEN
      l_try_name := G_TRANSACTION_DISBURSEMENT;
    ELSE
      l_try_name := G_TRANSACTION_FUNDING;
    END IF;

    open  l_tryv_csr(l_try_name);
    fetch l_tryv_csr into l_try_id;
    close l_tryv_csr;

-- force to get try_id
    l_tapv_rec.try_id := l_try_id;

-- 10-10-2003 cklee fixed bug# 3159723
    open  l_org_id_csr(l_tapv_rec.khr_id);
    fetch l_org_id_csr into l_org_id;
    close l_org_id_csr;

    IF (l_tapv_rec.org_id IS NULL) THEN
      l_tapv_rec.org_id := l_org_id;
    END IF;

    -- populates more attributes for BPD
    l_return_status := populate_more_attrs(l_tapv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_return_status := validate_header_attributes(l_tapv_rec, 'C');
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_tapv_rec.khr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tapv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_tapv_rec.khr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- smadhava - Bug#5200033 - Added - Start
    -- Round the amount to the System Options setup
    l_tapv_rec.AMOUNT := OKL_ACCOUNTING_UTIL.round_amount(p_amount        => l_tapv_rec.AMOUNT
                                                        , p_currency_code => l_tapv_rec.CURRENCY_CODE);
    -- smadhava - Bug#5200033 - Added - End

--    OKL_TAP_PVT.insert_row(
      OKL_TRX_AP_INVOICES_PUB.INSERT_TRX_AP_INVOICES(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--
-- create dummy funding line for pre-funding, AP required
--

    IF (l_tapv_rec.funding_type_code in ('PREFUNDING','BORROWER_PAYMENT')) THEN

      l_tplv_rec.inv_distr_line_code := 'ITEM';
      l_tplv_rec.tap_id := x_tapv_rec.id;
      l_tplv_rec.amount := l_tapv_rec.amount;
      l_tplv_rec.org_id := l_tapv_rec.org_id;
      l_tplv_rec.line_number := 1;
      l_tplv_rec.DISBURSEMENT_BASIS_CODE := 'BILL_DATE';
      -- sjalasut, added code to populate khr_id at line level. the khr_id
      -- is assumed to be retained at p_tapv_rec level from which the value
      -- is derived in this procedure. changes made as part of OKLR12B
      -- disbursements project. START code changes
      l_tplv_rec.khr_id := l_tapv_rec.khr_id;
      -- sjalsut, END code changes

      -- fixed bug#3338910
      l_return_status := populate_sty_id(l_tplv_rec);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


      OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_tplv_rec      => l_tplv_rec,
        x_tplv_rec      => x_tplv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

--
-- end of create dummy funding line for pre-funding

--
-- Removed code which creates checklists for funding request, as part of Funding OA Migration.
-- by nikshah

   /*
   -- vthiruva, 08/31/2004
   -- START, Code change to enable Business Event
   */

    --raise the business event for create funding request if
    --transaction status code is ENTERED
    IF(p_tapv_rec.trx_status_code = 'ENTERED')THEN
    	raise_business_event(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
			     x_return_status  => x_return_status,
		  	     x_msg_count      => x_msg_count,
			     x_msg_data       => x_msg_data,
			     p_khr_id         => p_tapv_rec.khr_id,
			     p_id             => x_tapv_rec.id,
			     p_event_name     => G_WF_EVT_FUN_REQ_CREATED);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    End If;

   /*
   -- vthiruva, 08/31/2004
   -- END, Code change to enable Business Event
   */

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_HEADER_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_HEADER_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_HEADER_PVT;
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

  END create_funding_header;


--------------------------------------------------------------------------

PROCEDURE update_funding_header(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tapv_rec                     IN tapv_rec_type
 ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_FUNDING_HEADER';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tapv_rec                 tapv_rec_type := p_tapv_rec;
  i                          NUMBER;

  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_row_not_found   boolean := false;
  l_dummy           number;
  funding_line_id   number;
  l_approval_option varchar2(10);

  -- vthiruva, 08/31/2004
  -- variables to raise business events
  l_event_name            wf_events.name%TYPE := null;
  l_raise_business_event  VARCHAR2(1) := OKL_API.G_FALSE;

cursor c_chklst_exists(p_fund_id varchar2) is
--start modified abhsaxen for performance SQLID 20562448
SELECT 1
FROM OKC_RULES_B RULT
WHERE rult.rule_information_category = 'LAFCLD'
and rult.OBJECT1_ID1 = p_fund_id ;
--end modified abhsaxen for performance SQLID 20562448

--- vpanwar 21/02/2007 Added
  --- to get all the funding lines for the funding header
    CURSOR funding_line_csr(p_fund_id number) IS
        Select id funding_line_id
        from OKL_TXL_AP_INV_LNS_B
        Where tap_id = p_fund_id;
  --- vpanwar 21/02/2007 End

BEGIN
  -- Set API savepoint
  SAVEPOINT UPDATE_FUNDING_HEADER_PVT;

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
    l_return_status := validate_header_attributes(l_tapv_rec, 'U');
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    ------------------------------------------------------------------
    -- added for approval process
    ------------------------------------------------------------------
    l_approval_option := fnd_profile.value('OKL_LEASE_FUNDING_APPROVAL_PROCESS');
    IF (l_tapv_rec.trx_status_code = 'SUBMITTED' AND
        l_approval_option not in ('WF', 'AME')) THEN

      /*
      -- cklee, 12/21/2004
      -- START, Code change to enable Business Event bug#4901292
      */

      --raise the business event for Validated the Funding Request for checklist items
      raise_business_event(p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
          			     x_return_status  => x_return_status,
           		  	     x_msg_count      => x_msg_count,
           			     x_msg_data       => x_msg_data,
           			     p_khr_id         => l_tapv_rec.khr_id,
		                 p_id             => l_tapv_rec.id,
           			     p_event_name     => G_WF_EVT_FUN_LIST_VALIDATED);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /*
      -- cklee, 12/21/2004
      -- END, Code change to enable Business Event
      */

      -- update item function validation results
      update_checklist_function(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_fund_req_id    => l_tapv_rec.id);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

      l_tapv_rec.trx_status_code := 'APPROVED';
      l_tapv_rec.DATE_FUNDING_APPROVED := sysdate;

    END IF;

    --Bug# 5690875: Update contract status to 'Incomplete'
    --              when Pre-funding request is Approved
    IF (l_tapv_rec.funding_type_code = G_PREFUNDING_TYPE_CODE
        AND l_tapv_rec.trx_status_code = 'APPROVED') THEN

      OKL_CONTRACT_STATUS_PUB.cascade_lease_status_edit
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => l_tapv_rec.khr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    -- smadhava - Bug#5200033 - Added - Start
    -- Round the amount to the System Options setup
    l_tapv_rec.AMOUNT := OKL_ACCOUNTING_UTIL.round_amount(p_amount        => l_tapv_rec.AMOUNT
                                                        , p_currency_code => l_tapv_rec.CURRENCY_CODE);
    -- smadhava - Bug#5200033 - Added - End

--    OKL_TAP_PVT.update_row(
      OKL_TRX_AP_INVOICES_PUB.UPDATE_TRX_AP_INVOICES(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------------------------
    -- trigger WF event if l_tapv_rec.trx_status_code = 'SUBMITTED' and
    -- profile option is WF or AME
    -----------------------------------------------------------
    IF (l_tapv_rec.trx_status_code = 'SUBMITTED' AND
        l_approval_option in ('WF', 'AME')) THEN

      /*
      -- cklee, 12/21/2004
      -- START, Code change to enable Business Event bug#4901292
      */

      --raise the business event for Validated the Funding Request for checklist items
      raise_business_event(p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
          			     x_return_status  => x_return_status,
           		  	     x_msg_count      => x_msg_count,
           			     x_msg_data       => x_msg_data,
           			     p_khr_id         => l_tapv_rec.khr_id,
		                 p_id             => l_tapv_rec.id,
           			     p_event_name     => G_WF_EVT_FUN_LIST_VALIDATED);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /*
      -- cklee, 12/21/2004
      -- END, Code change to enable Business Event
      */

       -- update item function validation results
      update_checklist_function(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_fund_req_id    => l_tapv_rec.id);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

     OKL_FUNDING_WF.raise_approval_event(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_funding_id    => l_tapv_rec.id);

    -----------------------------------------------------------
    -- trigger post activities if l_tapv_rec.trx_status_code = 'APPROVED' and
    -- profile option is NOT WF or AME
    -----------------------------------------------------------
    ELSIF (l_tapv_rec.trx_status_code = 'APPROVED' AND
        l_approval_option not in ('WF', 'AME')) THEN

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
/*    --- vpanwar 21/02/2007 Added
    OPEN funding_line_csr(l_tapv_rec.id);
    LOOP
    FETCH funding_line_csr into funding_line_id;

    EXIT WHEN funding_line_csr%NOTFOUND;
*/
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

      CREATE_ACCOUNTING_DIST(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_status        => l_tapv_rec.trx_status_code,
                           p_fund_id       => l_tapv_rec.id);--,
--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--                           p_fund_line_id  => funding_line_id);
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--    END LOOP;
--    CLOSE funding_line_csr;
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
    --- vpanwar 21/02/2007 End

    -------------------------------------------------------------
      -- create subsidy entries for 11.5.10
      -------------------------------------------------------------
      IF (l_tapv_rec.FUNDING_TYPE_CODE = OKL_FUNDING_PVT.G_ASSET_TYPE_CODE) THEN

        create_fund_asset_subsidies(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_status        => l_tapv_rec.trx_status_code,
                           p_fund_id       => l_tapv_rec.id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;

-- funding request checklist enhancement for 11.5.9
  IF (l_tapv_rec.funding_type_code <> G_ASSET_SUBSIDY AND
      l_tapv_rec.trx_status_code = 'ENTERED') THEN
--start modified abhsaxen changing l_tapv_rec.id in VARCHAR2 for Performance
    open c_chklst_exists(TO_CHAR(l_tapv_rec.id));
    fetch c_chklst_exists into l_dummy;
    l_row_not_found := c_chklst_exists%NOTFOUND;
    close c_chklst_exists;

    IF (l_row_not_found) THEN

      create_funding_chklst_tpl(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_chr_id        => l_tapv_rec.khr_id,
        p_fund_req_id   => l_tapv_rec.id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

  END IF;

-- funding request checklist enhancement for 11.5.9

   /*
   -- vthiruva, 08/31/2004
   -- START, Code change to enable Business Event
   */
    IF(p_tapv_rec.trx_status_code = 'ENTERED')THEN
    --raise the business event for update funding request
    --if transaction status code is ENTERED
        l_event_name  := G_WF_EVT_FUN_REQ_UPDATED;
        l_raise_business_event := OKL_API.G_TRUE;

    ELSIF(p_tapv_rec.trx_status_code = 'CANCELED')THEN
    --raise the business event for cancel funding request
    --if transaction status code is CANCELED
    --In DO the value of trx_status_code is being set to CANCELED
    --in place of CANCELLED. Hence changed the spelling in the above check.
        l_event_name  := G_WF_EVT_FUN_REQ_CANCELLED;
        l_raise_business_event := OKL_API.G_TRUE;

    ELSIF(p_tapv_rec.trx_status_code = 'SUBMITTED')THEN
    --raise the business event for submit funding request
    --if transaction status code is SUBMITTED
        l_event_name  := G_WF_EVT_FUN_REQ_SUBMITTED;
        l_raise_business_event := OKL_API.G_TRUE;
    END If;

    IF(l_raise_business_event = OKL_API.G_TRUE AND l_event_name IS NOT NULL) THEN
        --call to raise the appropriate business event
    	raise_business_event(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
			     x_return_status  => x_return_status,
			     x_msg_count      => x_msg_count,
			     x_msg_data       => x_msg_data,
			     p_khr_id         => p_tapv_rec.khr_id,
			     p_id             => p_tapv_rec.id,
			     p_event_name     => l_event_name);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;

   /*
   -- vthiruva, 08/31/2004
   -- END, Code change to enable Business Event
   */

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_HEADER_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_HEADER_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO UPDATE_FUNDING_HEADER_PVT;
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

  END update_funding_header;

----------------------------------------------------------------------------

PROCEDURE create_funding_lines(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tplv_tbl                     IN tplv_tbl_type
 ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_LINES';

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tplv_tbl                 tplv_tbl_type := p_tplv_tbl;
  i                          NUMBER;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  -- smadhava - Bug#5200033 - Added - Start
  l_currency_code OKL_TRX_AP_INVOICES_B.CURRENCY_CODE%TYPE;

   --- vpanwar added 28/02/2007 start
  l_khr_id  OKL_TRX_AP_INVOICES_B.KHR_ID%TYPE;
  --- vpanwar added 28/02/2007 end

  -- Cursor to get the currency code from the header record
  CURSOR c_get_currency_code(cp_tap_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
    SELECT CURRENCY_CODE
      FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = cp_tap_id;
  -- smadhava - Bug#5200033 - Added - End

  -- vpanwar Added --28/02/2007 -start
    CURSOR c_get_khr_id(p_tap_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
    SELECT KHR_ID
      FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = p_tap_id;
  -- vpanwar Added --28/02/2007 -end

  -- dcshanmu added - 23-Nov-2007 - bug # 6639928 - start
  CURSOR c_get_max_line_number(p_tap_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
    SELECT MAX(LINE_NUMBER)
	    FROM OKL_TXL_AP_INV_LNS_B
	    WHERE TAP_ID = P_TAP_ID;

  l_max_line_number NUMBER := 0;
  -- dcshanmu added - 23-Nov-2007 - bug # 6639928 - start

BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_LINES_PVT;

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


    -- OKL_TPL_PVT is not belongs to our dev team, so we have to write valid code here
    -- validate kle_id for passed in pl/sql table before insert into DB
    l_return_status := validate_table_kle_id(p_tplv_tbl);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- check kle_id and sty_id if applicable
    IF (p_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;

    -- smadhava - Bug#5200033 - Added - Start
    -- get the currency code from the header record
    OPEN c_get_currency_code(p_tplv_tbl(i).TAP_ID);
      FETCH c_get_currency_code INTO l_currency_code;
    CLOSE c_get_currency_code;
    -- smadhava - Bug#5200033 - Added - End

  --- vpanwar added 28/02/2007 start
    OPEN c_get_khr_id(p_tplv_tbl(i).TAP_ID);
      FETCH  c_get_khr_id INTO l_khr_id;
    CLOSE c_get_khr_id;
  --- vpanwar added 28/02/2007 end

  -- dcshanmu added - 23-Nov-2007 - bug # 6639928 - start
    OPEN c_get_max_line_number(p_tplv_tbl(i).TAP_ID);
	FETCH c_get_max_line_number INTO l_max_line_number;
    CLOSE c_get_max_line_number;

    IF (l_max_line_number IS NULL) THEN
	l_max_line_number := 0;
    END IF;

  -- dcshanmu added - 23-Nov-2007 - bug # 6639928 - end


      LOOP

     --- vpanwar added 28/02/2007 start
        l_tplv_tbl(i).KHR_ID := l_khr_id;
     --- vpanwar added 28/02/2007 start


--
-- default DISBURSEMENT_BASIS_CODE = 'BILL_DATE';
--
        l_tplv_tbl(i).DISBURSEMENT_BASIS_CODE := 'BILL_DATE';
--
--
--
  -- dcshanmu added - 23-Nov-2007 - bug # 6639928 - start
	IF (l_tplv_tbl(i).line_number = OKL_API.G_MISS_NUM OR l_tplv_tbl(i).line_number IS NULL) THEN
		l_max_line_number	:=	l_max_line_number + 1;
		l_tplv_tbl(i).line_number	:=	l_max_line_number;
	END IF;
  -- dcshanmu added - 23-Nov-2007 - bug # 6639928 - end

        -- fixed bug#3338910
        l_return_status := populate_sty_id(l_tplv_tbl(i));

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;


        l_return_status := validate_line_attributes(p_tplv_tbl(i), 'C');

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    -- smadhava - Bug#5200033 - Added - Start
    -- Round the amount to the System Options setup
    l_tplv_tbl(i).AMOUNT := OKL_ACCOUNTING_UTIL.round_amount(p_amount        => p_tplv_tbl(i).AMOUNT
                                                           , p_currency_code => l_currency_code);
    -- smadhava - Bug#5200033 - Added - End


        EXIT WHEN (i = p_tplv_tbl.LAST);
        i := p_tplv_tbl.NEXT(i);

      END LOOP;
    END IF;

--    OKL_TPL_PVT.insert_row(
      OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl,
      x_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


-- sync funding header amount
    SYNC_HEADER_AMOUNT(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN

    ROLLBACK TO CREATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_LINES_PVT;
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

  END create_funding_lines;

----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- dcshanmu - Added - Qucik Fund performance fix - start
----------------------------------------------------------------------------
PROCEDURE create_funding_lines(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_hdr_id				IN NUMBER
 ,p_khr_id				IN NUMBER
 ,p_vendor_site_id		IN NUMBER
 ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_LINES';

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_khr_id  OKL_TRX_AP_INVOICES_B.KHR_ID%TYPE;
  l_vendor_site_id OKL_TRX_AP_INVOICES_B.IPVS_ID%TYPE;
  l_vendor_id OKL_TRX_AP_INVOICES_B.VENDOR_ID%TYPE;

  -- cursor to fetch assets, which has supplier invoice for a given khr_id and vendor_site_id
  CURSOR c_get_assets(p_vendor_site_id OKL_TRX_AP_INVOICES_B.IPVS_ID%TYPE,
	p_khr_id OKL_TRX_AP_INVOICES_B.KHR_ID%TYPE) IS
    SELECT a.cle_id cle_id,
           a.chr_id chr_id,
           a.asset_number kle_num,
           a.description kle_name,
           okl_funding_pvt.get_contract_line_amt(
             a.chr_id,
             a.cle_id,
             p_vendor_site_id
           ) kle_amt
      FROM okl_assets_lov_uv a,
           okc_k_party_roles_b cpl,
           okc_k_lines_b LN,
           okx_vendor_sites_v sites
     WHERE a.chr_id = p_khr_id
       AND cpl.rle_code = 'OKL_VENDOR'
       AND cpl.chr_id IS NULL
       AND cpl.dnz_chr_id = a.chr_id
       AND cpl.object1_id1 = TO_CHAR(sites.vendor_id)
       AND sites.id1 = p_vendor_site_id
       AND cpl.object1_id2 = '#'
       AND cpl.cle_id = LN.ID
       AND LN.cle_id = a.cle_id;

  -- cursor to fetch org_id from khr_id
  CURSOR c_get_org_id(p_khr_id OKL_TRX_AP_INVOICES_B.KHR_ID%TYPE) IS
	SELECT AUTHORING_ORG_ID
	FROM OKC_K_HEADERS_ALL_B
	WHERE ID = p_khr_id;

assets_rec c_get_assets%ROWTYPE;
TYPE assets_tbl IS TABLE OF assets_rec%TYPE INDEX BY BINARY_INTEGER;

  l_assets_tbl assets_tbl;
  l_sty_id	NUMBER := 0;
  l_tplv_tbl                 tplv_tbl_type;
  cnt	NUMBER := 0;
  l_org_id	NUMBER := 0;

 BEGIN
	SAVEPOINT CREATE_FUNDING_LINES_PVT;

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	OPEN c_get_assets(p_vendor_site_id, p_khr_id);
		FETCH c_get_assets BULK COLLECT INTO l_assets_tbl;
	CLOSE c_get_assets;

	OPEN c_get_org_id(p_khr_id);
		FETCH c_get_org_id INTO l_org_id;
	CLOSE c_get_org_id;

	IF l_assets_tbl.COUNT > 0 THEN
		-- populate l_tplv_tbl
		FOR i in l_assets_tbl.FIRST..l_assets_tbl.LAST LOOP
			-- increment count and assign to line numbers
			l_tplv_tbl(i).tap_id			:=	p_hdr_id;
			cnt := cnt + 1;
			l_tplv_tbl(i).line_number		:=	cnt;
			l_tplv_tbl(i).kle_id			:=	l_assets_tbl(i).cle_id;
			l_tplv_tbl(i).inv_distr_line_code	:=	'ITEM';
			l_tplv_tbl(i).amount			:=	l_assets_tbl(i).kle_amt;
			l_tplv_tbl(i).org_id			:=	l_org_id;
			l_tplv_tbl(i).description			:=	l_assets_tbl(i).kle_name;
		END LOOP;

		-- call create_funding_lines proc with table
		create_funding_lines(
			  p_api_version
			 ,p_init_msg_list
			 ,x_return_status
			 ,x_msg_count
			 ,x_msg_data
			 ,l_tplv_tbl
			 ,x_tplv_tbl);
	END IF;


	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

  -- Get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN

    ROLLBACK TO CREATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_LINES_PVT;
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


  END create_funding_lines;
----------------------------------------------------------------------------
-- dcshanmu - Added - Qucik Fund performance fix - end
----------------------------------------------------------------------------

PROCEDURE update_funding_lines(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tplv_tbl                     IN tplv_tbl_type
 ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_FUNDING_LINES';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tplv_tbl                 tplv_tbl_type := p_tplv_tbl;
  i                          NUMBER;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_sty_id number;

  --- vpanwar added 28/02/2007 start
  l_khr_id  OKL_TRX_AP_INVOICES_B.KHR_ID%TYPE;
  --- vpanwar added 28/02/2007 end

cursor c_sty_id(p_tpl_id number) is
select sty_id
from okl_txl_ap_inv_lns_b
where id = p_tpl_id
;

  -- smadhava - Bug#5200033 - Added - Start
  l_currency_code OKL_TRX_AP_INVOICES_B.CURRENCY_CODE%TYPE;

  -- Cursor to get the currency code from the header record
  CURSOR c_get_currency_code(cp_tap_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
    SELECT CURRENCY_CODE
      FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = cp_tap_id;
  -- smadhava - Bug#5200033 - Added - End

 -- vpanwar Added --28/02/2007 -start
    CURSOR c_get_khr_id(p_tap_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
    SELECT KHR_ID
      FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = p_tap_id;
  -- vpanwar Added --28/02/2007 -end

BEGIN
  -- Set API savepoint
  SAVEPOINT UPDATE_FUNDING_LINES_PVT;

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

    -- check kle_id and sty_id if applicable
    -- OKL_TPL_PVT is not belongs to our dev team, so we have to write validate code here
    IF (l_tplv_tbl.COUNT > 0) THEN
      i := p_tplv_tbl.FIRST;

    -- smadhava - Bug#5200033 - Added - Start
    -- get the currency code from the header record
    OPEN c_get_currency_code(p_tplv_tbl(i).TAP_ID);
      FETCH c_get_currency_code INTO l_currency_code;
    CLOSE c_get_currency_code;
    -- smadhava - Bug#5200033 - Added - End

       --- vpanwar added 28/02/2007 start
    OPEN c_get_khr_id(p_tplv_tbl(i).TAP_ID);
      FETCH  c_get_khr_id INTO l_khr_id;
    CLOSE c_get_khr_id;
    --- vpanwar added 28/02/2007 end


      LOOP

   --- vpanwar added 28/02/2007 start
        l_tplv_tbl(i).KHR_ID := l_khr_id;
      --- vpanwar added 28/02/2007 start

-- cklee: 09/16/2004
        IF (l_tplv_tbl(i).sty_id IS NULL or l_tplv_tbl(i).sty_id = OKL_API.G_MISS_NUM) THEN

          open c_sty_id(l_tplv_tbl(i).id);
          fetch c_sty_id into l_sty_id;
          IF c_sty_id%found THEN
            l_tplv_tbl(i).sty_id := l_sty_id;
          END IF;
          close c_sty_id;
        END IF;

        l_return_status := validate_line_attributes(l_tplv_tbl(i), 'U');
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    -- smadhava - Bug#5200033 - Added - Start
    -- Round the amount to the System Options setup
    l_tplv_tbl(i).AMOUNT := OKL_ACCOUNTING_UTIL.round_amount(p_amount        => p_tplv_tbl(i).AMOUNT
                                                           , p_currency_code => l_currency_code);
    -- smadhava - Bug#5200033 - Added - End

        EXIT WHEN (i = l_tplv_tbl.LAST);
        i := l_tplv_tbl.NEXT(i);

      END LOOP;
    END IF;

--    OKL_TPL_PVT.update_row(
      OKL_TXL_AP_INV_LNS_PUB.UPDATE_TXL_AP_INV_LNS(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl,
      x_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- sync funding header amount
    SYNC_HEADER_AMOUNT(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PVT;
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

END update_funding_lines;
----------------------------------------------------------------------------
PROCEDURE create_funding_assets(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_id                      IN NUMBER
 )
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_ASSETS';

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tplv_tbl        tplv_tbl_type;
  x_tplv_tbl        tplv_tbl_type;
  i                 NUMBER;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  --l_khr_id          NUMBER;
  l_org_id          NUMBER;
  l_kle_id          NUMBER;
  l_asset_cost      NUMBER;
  l_asset_number    VARCHAR2(150);


  -- smadhava - Bug#5200033 - Modified - Start
  l_currency_code OKL_TRX_AP_INVOICES_B.CURRENCY_CODE%TYPE;

  --- vpanwar added 28/02/2007 start
  l_khr_id  OKL_TRX_AP_INVOICES_B.KHR_ID%TYPE;
  --- vpanwar added 28/02/2007 end


  -- Modifed cursor to get the currency code
  CURSOR c (p_fund_id  NUMBER)
  IS
  select a.org_id
       , a.currency_code
  from   okl_trx_ap_invoices_b a
  where  a.id = p_fund_id
  and    a.funding_type_code = 'ASSET'
  ;
  -- smadhava - Bug#5200033 - Modified - End


  --veramach 5600694  start modified cursor c2
  /*CURSOR c2 (p_fund_id NUMBER)
  IS
  select a.cle_id
         ,a.KLE_AMT
  from   okl_fund_assets_lov_uv a
  where  a.FUND_ID = p_fund_id
  and    a.KLE_AMT > 0
  and    NOT EXISTS
          (select 1
           from okl_txl_ap_inv_lns_b b
           where a.FUND_ID = b.tap_id
           and   a.cle_id = b.kle_id)
  ;*/
 	CURSOR c2 (p_fund_id NUMBER)
 	IS
 	/*veramach 29-Jun-2007 bug#5600694 commented to improve the performance */
 	 --SELECT cle_id, KLE_AMT
 	 --FROM
 	 --(
 	   select a.cle_id,
 	       (select OKL_FUNDING_PVT.get_contract_line_amt(a.CHR_ID, a.CLE_ID, b.ipvs_id)  from dual) KLE_AMT
 	   from   OKL_ASSETS_LOV_UV A,
 	   OKL_TRX_AP_INVOICES_B b
 	   WHERE  a.chr_id = b.khr_id
 	   AND b.ID = p_fund_id
 	   and    NOT EXISTS
 	          (select 1
 	           from okl_txl_ap_inv_lns_b c
 	           where b.ID = c.tap_id
 	           and   a.cle_id = c.kle_id)
	  -- )
 	   --WHERE    KLE_AMT > 0
 	   ;
 	   --veramach 5600694  end

   -- vpanwar Added --28/02/2007 -start
    CURSOR c_get_khr_id(p_tap_id OKL_TRX_AP_INVOICES_B.ID%TYPE) IS
    SELECT KHR_ID
      FROM OKL_TRX_AP_INVOICES_B
     WHERE ID = p_tap_id;
  -- vpanwar Added --28/02/2007 -end


BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_ASSETS_PVT;

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

  -- smadhava - Bug#5200033 - Modified - Start
  -- get org_id and Currency code

  OPEN c(p_fund_id);
  FETCH c INTO l_org_id, l_currency_code;
  CLOSE c;
  -- smadhava - Bug#5200033 - Modified - End

-- fill in l_tplv_tbl
  OPEN c2(p_fund_id);
  i := 0;
  LOOP

       FETCH c2 into
                l_kle_id,
                l_asset_cost;
       EXIT WHEN c2%NOTFOUND;
	     IF l_asset_cost > 0 THEN  --for bug#5600694

       l_tplv_tbl(i).inv_distr_line_code := 'ITEM';
       l_tplv_tbl(i).tap_id := p_fund_id;

       --- vpanwar added 28/02/2007 start
       OPEN c_get_khr_id(l_tplv_tbl(i).TAP_ID);
	FETCH  c_get_khr_id INTO l_khr_id;
       CLOSE c_get_khr_id;

        l_tplv_tbl(i).KHR_ID := l_khr_id;

       --- vpanwar added 28/02/2007 start


       l_tplv_tbl(i).kle_id := l_kle_id;
       -- smadhava - Bug#5200033 - Modified - Start
       -- Round the asset cost to the system options rounding setup
       l_tplv_tbl(i).amount := OKL_ACCOUNTING_UTIL.round_amount(p_amount        => l_asset_cost
                                                              , p_currency_code => l_currency_code);
--       l_tplv_tbl(i).amount := l_asset_cost;
       -- smadhava - Bug#5200033 - Modified - End

       l_tplv_tbl(i).org_id := l_org_id;
       l_tplv_tbl(i).line_number := i+1;
       l_tplv_tbl(i).DISBURSEMENT_BASIS_CODE := 'BILL_DATE';

        -- fixed bug#3338910
        l_return_status := populate_sty_id(l_tplv_tbl(i));

        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;


       i := i + 1;

    END IF;
  END LOOP;

  CLOSE c2;

  IF (l_tplv_tbl.COUNT > 0) THEN

--    OKL_TPL_PVT.insert_row(
    OKL_TXL_AP_INV_LNS_PUB.INSERT_TXL_AP_INV_LNS(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl,
      x_tplv_tbl      => x_tplv_tbl);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- sync funding header amount
    OKL_FUNDING_PVT.SYNC_HEADER_AMOUNT(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_ASSETS_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_ASSETS_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_ASSETS_PVT;
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

  END create_funding_assets;
----------------------------------------------------------------------------

 PROCEDURE reverse_funding_requests(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN NUMBER
 )
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'reverse_funding_requests';
  l_api_version     CONSTANT NUMBER       := 1.0;

  l_tapv_rec        tapv_rec_type;
  x_tapv_rec        tapv_rec_type;

  funding_line_id   number;


  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_currency_code   okc_k_headers_b.CURRENCY_CODE%TYPE;
  l_org_id          okc_k_headers_b.AUTHORING_ORG_ID%TYPE;
  l_contract_number okc_k_headers_b.CONTRACT_NUMBER%TYPE;

  l_amount           okl_trx_ap_invoices_b.AMOUNT%TYPE;

  l_ipvs_id          okl_trx_ap_invoices_b.IPVS_ID%TYPE;
  l_vendor_site_code OKX_VENDOR_SITES_V.NAME%TYPE;

  l_PAY_GROUP_LOOKUP_CODE  OKL_TRX_AP_INVOICES_B.PAY_GROUP_LOOKUP_CODE%TYPE;
  l_NETTABLE_YN            OKL_TRX_AP_INVOICES_B.NETTABLE_YN%TYPE;


    CURSOR cu (p_id NUMBER)
    IS
      SELECT h.PAY_GROUP_LOOKUP_CODE,
             h.NETTABLE_YN
        FROM OKL_TRX_AP_INVOICES_B h
       WHERE h.id = p_id
    ;

  --
  CURSOR c (p_contract_id  NUMBER)
  IS
  select a.AUTHORING_ORG_ID,
         a.CURRENCY_CODE,
         a.CONTRACT_NUMBER
  from   okc_k_headers_b a
  where  a.id = p_contract_id
  ;

  -- sjalasut, modified the below cursor to have p_contract_id joined with
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project
  CURSOR c2 (p_contract_id  NUMBER)
  IS
  select a.ipvs_id,
         nvl(sum(OKL_FUNDING_PVT.get_contract_line_funded_amt(a.id,a.funding_type_code)),0)
  from  okl_trx_ap_invoices_b a
       ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and  b.khr_id = p_contract_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and    a.funding_type_code IS NOT NULL -- cklee 09-24-03
  and    a.funding_type_code <> 'SUPPLIER_RETENTION'
  group by a.ipvs_id
  ;

  CURSOR c_vendor_site (p_ipvs_id  NUMBER)
  IS
  select a.name
  from OKX_VENDOR_SITES_V a
  where a.id1 = p_ipvs_id
  ;

  --- vpanwar 21/02/2007 Added
  --- to get all the funding lines for the funding header
    CURSOR fund_line_csr(p_fund_id number) IS
        Select id funding_line_id
        from OKL_TXL_AP_INV_LNS_B
        Where tap_id = p_fund_id;
  --- vpanwar 21/02/2007 End

BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_ASSETS_PVT;

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
  -- get org_id
  OPEN c(p_contract_id);
  FETCH c INTO l_org_id,
               l_currency_code,
               l_contract_number;
  CLOSE c;


  OPEN c2(p_contract_id);
  LOOP

    FETCH c2 into l_ipvs_id,
                  l_amount;

    OPEN c_vendor_site(l_ipvs_id);
    FETCH c_vendor_site into l_vendor_site_code;
    CLOSE c_vendor_site;

    EXIT WHEN c2%NOTFOUND;

    IF (l_amount <> 0 ) THEN
      l_amount := -l_amount;

      -- sjalasut, not commenting the khr_id reference in l_tapv_rec here as this
      -- record variable is used as a parameter for validate_header_attributes,
      -- validate_funding_request etc. since per the disbursements FDD, tapv_rec
      -- .khr_id would continue to exist, not making this change would not cause
      -- compilation issues.
      l_tapv_rec.KHR_ID := p_contract_id;
      l_tapv_rec.AMOUNT := l_amount;
      l_tapv_rec.FUNDING_TYPE_CODE := 'PREFUNDING';
      l_tapv_rec.IPVS_ID := l_ipvs_id;
      l_tapv_rec.ORG_ID := l_org_id;


      l_tapv_rec.TRX_STATUS_CODE := 'ENTERED'; -- create record 1st
      l_tapv_rec.DESCRIPTION
        := 'Account Payable debit for Reverse Contract, ' || l_contract_number || ', vendor site '|| l_vendor_site_code;
      l_tapv_rec.CURRENCY_CODE := l_currency_code;
      l_tapv_rec.PAYMENT_METHOD_CODE := 'CHECK';
      l_tapv_rec.DATE_ENTERED := sysdate;

      -- sjalasut, modified the invoice_type from G_STANDARD to G_CREDIT
      -- changes made as part of OKLR12B Disbursements Project
      l_tapv_rec.INVOICE_TYPE := G_CREDIT;

      -- sjalasut, added code to make sure that the invoice amount on the credit memo
      -- invoice is negative. changes made as part of OKLR12B Disbursements project
      IF(l_tapv_rec.AMOUNT > 0)THEN
        l_tapv_rec.AMOUNT := ((l_tapv_rec.AMOUNT)*(-1));
      END IF;

      l_tapv_rec.DATE_INVOICED := sysdate;
      l_tapv_rec.DATE_GL := sysdate;

      create_funding_header(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_tapv_rec      => l_tapv_rec,
        x_tapv_rec      => x_tapv_rec);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN cu (x_tapv_rec.id);
      FETCH cu INTO l_PAY_GROUP_LOOKUP_CODE,
                  l_NETTABLE_YN;
      CLOSE cu;

      l_tapv_rec.ID := x_tapv_rec.id;
      l_tapv_rec.PAY_GROUP_LOOKUP_CODE := l_PAY_GROUP_LOOKUP_CODE;
      l_tapv_rec.NETTABLE_YN := l_NETTABLE_YN;
      l_tapv_rec.TRX_STATUS_CODE := 'APPROVED';
-- cklee 09-24-03
-- due to the external interface table limit to 30 chars
      l_tapv_rec.VENDOR_INVOICE_NUMBER := x_tapv_rec.INVOICE_NUMBER;

      update_funding_header(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_tapv_rec      => l_tapv_rec,
        x_tapv_rec      => x_tapv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- WF enable, add accounting entry 06/24/03 cklee

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
/*
      --- vpanwar 21/02/2007 Added
    OPEN fund_line_csr(l_tapv_rec.id);
    LOOP
    FETCH fund_line_csr into funding_line_id;

    EXIT WHEN fund_line_csr%NOTFOUND;
*/
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

      OKL_FUNDING_PVT.CREATE_ACCOUNTING_DIST
                          (p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_status        => l_tapv_rec.trx_status_code,
                           p_fund_id       => l_tapv_rec.id);--,--:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--                           p_fund_line_id  => funding_line_id);--:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

--start:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |
--    END LOOP;
--    CLOSE fund_line_csr;
    --- vpanwar 21/02/2007 End
--end:| 21-May-2007 cklee    OKLR12B Accounting CR                                 |

    END IF;

  END LOOP;
  CLOSE c2;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_ASSETS_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_ASSETS_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_ASSETS_PVT;
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


  END reverse_funding_requests;

----------------------------------------------------------------------------
/*
 	   veramach 29-Jun-2007 Bug#5600694 Modified the function get_contract_line_amt
 	   to improve the performance of funding screens. Merged the cursor cv_addon in
 	   cv_model.
 	   The cv_model cursor considers the item for which the vendor is passed and
 	   add on items for that item for which a vendor is attached.
 	   The add on items should have a vendor and not necessary that
 	   the vendor should match the vendor of the item.
 	   Example 1:
 	      Item     - >    Addon1     and Addon2
 	     (Vendor1)       (Vendor2)     (Vendor2)

 	         cv_model will consider Item, Addon1 and Addon2.

 	   Example 2:
 	      Item     - >    Addon1     and Addon2
 	     (Vendor1)       (Vendor1)     (No vendor)

 	     cv_model will consider Item and Addon1.

 	 */


FUNCTION get_contract_line_amt(
  p_khr_id           IN   NUMBER,  -- contract hdr
  p_kle_id           IN   NUMBER,  -- contract line
  p_vendor_site_id   IN   NUMBER
)
  RETURN NUMBER IS
  l_amount            NUMBER                                        := 0;
  l_amount_buffer     NUMBER                                        := 0;
  l_vendor_id         NUMBER                                        := 0;
-- start: okl.h: cklee
  x_return_status     VARCHAR2(3)                                   := okl_api.g_ret_sts_success;
  l_api_version       NUMBER                                        := 1.0;
  x_msg_count         NUMBER;
  x_msg_data          VARCHAR2(4000);
  l_init_msg_list     VARCHAR2(10)                                  := okl_api.g_false;
  x_value             NUMBER;

-- start: okl.h: cklee
  CURSOR cv1(
    p_vendor_site_id   NUMBER
  ) IS
    SELECT vendor_id
      FROM okx_vendor_sites_v
     WHERE id1 = TO_CHAR(p_vendor_site_id);

--
--
-- FA line with vendor attach
--
  CURSOR cv_model(
    p_khr_id      NUMBER,
    p_kle_id      NUMBER,
    p_vendor_id   NUMBER
  ) IS
    SELECT NVL(SUM(NVL(cle.price_unit, 0) * NVL(cim.number_of_items, 0)), 0)
      FROM okc_k_items cim,
           okc_k_party_roles_b cpl,
           okc_k_lines_b cle
     WHERE
--for model lines of vendor
           (
                cim.cle_id = cle.ID
            AND cim.dnz_chr_id = p_khr_id
            AND cpl.cle_id = cle.ID
            AND cpl.dnz_chr_id = p_khr_id
            AND cpl.chr_id IS NULL
            AND cpl.rle_code = 'OKL_VENDOR'
            AND cpl.object1_id1 = TO_CHAR(p_vendor_id)
            AND cpl.object1_id2 = '#'
            AND EXISTS(SELECT NULL
                         FROM okc_line_styles_b model_lse
                        WHERE model_lse.ID = cle.lse_id AND model_lse.lty_code = 'ITEM' AND cle.cle_id = p_kle_id)
           )   -- end of model lines
-- re lease flag check
       AND EXISTS(SELECT NULL
                    FROM okl_k_lines lkl
                   WHERE lkl.ID = cle.ID AND lkl.re_lease_yn IS NULL);

--
--
-- add on line with vendor attach, but don't care which vendor attach
--
  CURSOR cv_addon(
    p_khr_id      NUMBER,
    p_kle_id      NUMBER,
-- start: okl.h: cklee -- add vendor_id as a parameter
    p_vendor_id   NUMBER
  )
-- end: okl.h: cklee -- add vendor_id as a parameter
  IS
    SELECT NVL(SUM(NVL(cle.price_unit, 0) * NVL(cim.number_of_items, 0)), 0)
      FROM okc_k_items cim,
           okc_k_party_roles_b cpl,
           okc_k_lines_b cle
     WHERE
--for add on lines: don't care the vendor association, but care if it has vendor association!
           (
                cim.cle_id = cle.ID
            AND cim.dnz_chr_id = p_khr_id
            AND cpl.cle_id = cle.ID
            AND cpl.dnz_chr_id = p_khr_id
            AND cpl.chr_id IS NULL
            AND cpl.rle_code = 'OKL_VENDOR'
-- start: okl.h: cklee
            AND cpl.object1_id1 = TO_CHAR(p_vendor_id)
            AND cpl.object1_id2 = '#'
-- end: okl.h: cklee
            AND EXISTS(SELECT NULL
                         FROM okc_line_styles_b adon_lse
                        WHERE adon_lse.ID = cle.lse_id AND adon_lse.lty_code = 'ADD_ITEM'
                                                                                         -- ADD_ITEM has one parent ITEM only
                              AND EXISTS(SELECT NULL
                                           FROM okc_k_lines_b mdl_parent
                                          WHERE mdl_parent.ID = cle.cle_id AND mdl_parent.cle_id = p_kle_id))
           )   -- end of add on lines
-- re lease flag check
       AND EXISTS(SELECT NULL
                    FROM okl_k_lines lkl
                   WHERE lkl.ID = cle.ID AND lkl.re_lease_yn IS NULL);

--
--
-- if NO vendor_id
--
  CURSOR cv_no_vendor(
    p_khr_id   NUMBER,
    p_kle_id   NUMBER
  ) IS
    SELECT NVL(SUM(NVL(cle.price_unit, 0) * NVL(cim.number_of_items, 0)), 0)
      FROM okc_k_items cim,
           okc_k_party_roles_b cpl,
           okc_k_lines_b cle
     WHERE
--for model lines of vendor
           (
                cim.cle_id = cle.ID
            AND cim.dnz_chr_id = p_khr_id
            AND cpl.cle_id = cle.ID
            AND cpl.dnz_chr_id = p_khr_id
            AND cpl.chr_id IS NULL
            AND cpl.rle_code = 'OKL_VENDOR'
--and    cpl.object1_id1 = to_char(p_vendor_id)
--and    cpl.object1_id2 = '#'
            AND EXISTS(SELECT NULL
                         FROM okc_line_styles_b model_lse
                        WHERE model_lse.ID = cle.lse_id AND model_lse.lty_code = 'ITEM' AND cle.cle_id = p_kle_id)
           )   -- end of model lines
        OR
--for add on lines: don't care the vendor association, but care if it has vendor association!
               (
                    cim.cle_id = cle.ID
                AND cim.dnz_chr_id = p_khr_id
                AND cpl.cle_id = cle.ID
                AND cpl.dnz_chr_id = p_khr_id
                AND cpl.chr_id IS NULL
                AND cpl.rle_code = 'OKL_VENDOR'
--and    cpl.object1_id1 = to_char(p_vendor_id)
--and    cpl.object1_id2 = '#'
                AND EXISTS(SELECT NULL
                             FROM okc_line_styles_b adon_lse
                            WHERE adon_lse.ID = cle.lse_id AND adon_lse.lty_code = 'ADD_ITEM'
                                                                                             -- ADD_ITEM has one parent ITEM only
                                  AND EXISTS(SELECT NULL
                                               FROM okc_k_lines_b mdl_parent
                                              WHERE mdl_parent.ID = cle.cle_id AND mdl_parent.cle_id = p_kle_id))
               )   -- end of add on lines
-- re lease flag check
           AND EXISTS(SELECT NULL
                        FROM okl_k_lines lkl
                       WHERE lkl.ID = cle.ID AND lkl.re_lease_yn IS NULL);

--
--
-- if NO line and vendor_id
--
  CURSOR c_no_line_and_vendor(
    p_khr_id   NUMBER
  ) IS
    SELECT NVL(SUM(NVL(cle.price_unit, 0) * NVL(cim.number_of_items, 0)), 0)
      FROM okc_k_items cim,
           okc_k_party_roles_b cpl,
           okc_k_lines_b cle
     WHERE (
                cim.cle_id = cle.ID
            AND cim.dnz_chr_id = p_khr_id
            AND cpl.cle_id = cle.ID
            AND cpl.dnz_chr_id = p_khr_id
            AND cpl.chr_id IS NULL
            AND cpl.rle_code = 'OKL_VENDOR'
            AND EXISTS(SELECT NULL
                         FROM okc_line_styles_b model_lse
                        WHERE model_lse.ID = cle.lse_id
                          AND model_lse.lty_code = 'ITEM')
           )
        OR     (
                    cim.cle_id = cle.ID
                AND cim.dnz_chr_id = p_khr_id
                AND cpl.cle_id = cle.ID
                AND cpl.dnz_chr_id = p_khr_id
                AND cpl.chr_id IS NULL
                AND cpl.rle_code = 'OKL_VENDOR'
                AND EXISTS(SELECT NULL
                             FROM okc_line_styles_b adon_lse
                            WHERE adon_lse.ID = cle.lse_id
                              AND adon_lse.lty_code = 'ADD_ITEM'
                              AND EXISTS(SELECT NULL
                                          FROM okc_k_lines_b mdl_parent
                                         WHERE mdl_parent.ID = cle.cle_id))
               )
           AND EXISTS(SELECT NULL
                        FROM okl_k_lines lkl
                       WHERE lkl.ID = cle.ID
                         AND lkl.re_lease_yn IS NULL);

--
-- bug 5384359 -- start
  CURSOR downpymnt_recvr_csr(
    p_kle_id   NUMBER
  ) IS
    SELECT down_payment_receiver_code
      FROM okl_k_lines
     WHERE ID = p_kle_id;

  l_downpymnt_recvr   okl_k_lines.down_payment_receiver_code%TYPE;
-- bug 5384359 -- end
--

--start:| 08-Feb-08  cklee Fixed bug: 6783566                                        |
/*
  CURSOR c_kle_id(
                  p_khr_id okc_k_headers_b.id%TYPE
                 ) IS
    SELECT kle.cle_id kle_id,
           kle_k.down_payment_receiver_code downpymnt_recvr
      FROM okl_assets_lov_uv kle,
           okl_k_lines kle_k
     WHERE kle.cle_id = kle_k.ID
       AND kle.chr_id = p_khr_id;
*/
  CURSOR c_kle_id(
                  p_khr_id okc_k_headers_b.id%TYPE
                 ) IS
    SELECT kle_k.id kle_id,
           kle_k.down_payment_receiver_code downpymnt_recvr
      FROM okl_k_lines kle_k,
           okc_k_lines_b kle
     where kle_k.id = kle.id
     and kle.dnz_chr_id = p_khr_id
     and kle_k.re_lease_yn IS NULL  -- re lease flag check
     -- only asset lines associated with Lease Vendor (Supplier Invoice)
     and exists (
      SELECT 1
      FROM okc_k_party_roles_b cpl,
           okc_k_lines_b cle,
           okc_line_styles_b model_lse
     WHERE cpl.rle_code = 'OKL_VENDOR'
       AND cpl.chr_id IS NULL
       and model_lse.ID = cle.lse_id
       and model_lse.lty_code = 'ITEM'
       and cle.cle_id = kle_k.id -- link to FREE_FORM1 (top line)
       AND cpl.object1_id2 = '#'
       AND cpl.cle_id = cle.ID); -- link to ITEM

--end:| 08-Feb-08  cklee Fixed bug: 6783566                                        |

BEGIN
  IF (p_khr_id IS NULL) OR (p_khr_id = okl_api.g_miss_num) THEN
    RETURN 0;   -- error
  ELSIF ((p_kle_id IS NULL) OR (p_kle_id = okl_api.g_miss_num) AND (p_vendor_site_id IS NULL OR p_vendor_site_id = okl_api.g_miss_num)) THEN

    OPEN c_no_line_and_vendor(p_khr_id);
    FETCH c_no_line_and_vendor INTO l_amount;
    CLOSE c_no_line_and_vendor;

    --------------------------------------------------
    -- Contract Trade In AND Contract Capitalized Reduction -- Downpayment
    --------------------------------------------------
    FOR l_kle_id IN c_kle_id(p_khr_id) LOOP
      BEGIN
        l_amount_buffer := okl_seeded_functions_pvt.line_tradein(p_chr_id => p_khr_id, p_line_id => l_kle_id.kle_id);

        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
          l_amount_buffer := 0;
        ELSIF(x_return_status = okl_api.g_ret_sts_error) THEN
          l_amount_buffer := 0;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          l_amount_buffer := 0;
      END;

      l_amount := l_amount - l_amount_buffer;

      BEGIN
        IF ((l_kle_id.downpymnt_recvr IS NULL) OR (l_kle_id.downpymnt_recvr = 'VENDOR')) THEN
          l_amount_buffer := okl_seeded_functions_pvt.line_capital_reduction(p_chr_id => p_khr_id, p_line_id => l_kle_id.kle_id);

          IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            l_amount_buffer := 0;
          ELSIF(x_return_status = okl_api.g_ret_sts_error) THEN
            l_amount_buffer := 0;
          END IF;
        ELSIF(l_kle_id.downpymnt_recvr = 'LESSOR') THEN
          l_amount_buffer := 0;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          l_amount_buffer := 0;
      END;

      l_amount := l_amount - l_amount_buffer;
    END LOOP;

  ELSIF (p_vendor_site_id IS NULL OR p_vendor_site_id = okl_api.g_miss_num) THEN

    OPEN cv_no_vendor(p_khr_id, p_kle_id);
    FETCH cv_no_vendor INTO l_amount;
    CLOSE cv_no_vendor;

    -- start: skgautam Bug#5260198
    --------------------------------------------------
    -- Contract Trade In
    --------------------------------------------------
    BEGIN
      l_amount_buffer := okl_seeded_functions_pvt.line_tradein(p_chr_id => p_khr_id, p_line_id => p_kle_id);

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        l_amount_buffer := 0;
      ELSIF(x_return_status = okl_api.g_ret_sts_error) THEN
        l_amount_buffer := 0;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_amount_buffer := 0;
    END;

    l_amount := l_amount - l_amount_buffer;

    --------------------------------------------------
    -- Contract Capitalized Reduction -- Downpayment
    --------------------------------------------------
    BEGIN
      -- bug 5384359 -- start
      OPEN downpymnt_recvr_csr(p_kle_id);
      FETCH downpymnt_recvr_csr INTO l_downpymnt_recvr;
      CLOSE downpymnt_recvr_csr;

      IF ((l_downpymnt_recvr IS NULL) OR (l_downpymnt_recvr = 'VENDOR')) THEN
        -- bug 5384359 -- end
        l_amount_buffer := okl_seeded_functions_pvt.line_capital_reduction(p_chr_id => p_khr_id, p_line_id => p_kle_id);

        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
          l_amount_buffer := 0;
        ELSIF(x_return_status = okl_api.g_ret_sts_error) THEN
          l_amount_buffer := 0;
        END IF;
        --bug 5473370 --start
      ELSIF(l_downpymnt_recvr = 'LESSOR') THEN
        l_amount_buffer := 0;
        --bug 5473370 -- end
        -- bug 5384359 -- start
      END IF;
        -- bug 5384359 -- END
    EXCEPTION
      WHEN OTHERS THEN
        l_amount_buffer := 0;
    END;

    l_amount := l_amount - l_amount_buffer;
    -- end: skgautam Bug#5260198
  ELSE
    OPEN cv1(p_vendor_site_id);
    FETCH cv1 INTO l_vendor_id;
    CLOSE cv1;

    -- get model line attach to vendor
    OPEN cv_model(p_khr_id,p_kle_id,l_vendor_id);
    FETCH cv_model INTO l_amount_buffer;
    CLOSE cv_model;

    -- start: okl.h: cklee
    /* commented out
        IF (l_amount_buffer <= 0) THEN
          return 0;
        ELSE
    */
    -- start: okl.h: cklee
    l_amount := l_amount_buffer;

    -- get add on attach to vendor, but don't care which vendor attach
    -- start: okl.h: cklee -- add vendor_id as a parameter
    OPEN cv_addon(p_khr_id,p_kle_id,l_vendor_id);
    -- end: okl.h: cklee
    FETCH cv_addon INTO l_amount_buffer;
    CLOSE cv_addon;

    l_amount := l_amount + l_amount_buffer;

    --    END IF;
    -- start: okl.h: cklee
    --------------------------------------------------
    -- Contract Capitalized Reduction -- Downpayment
    --------------------------------------------------
    BEGIN
      --START:| 27-Feb-2006  cklee -- Fixed bug#5003962                                    |
      /*
            OKL_EXECUTE_FORMULA_PUB.execute(
              p_api_version   => l_api_version,
              p_init_msg_list => l_init_msg_list,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_formula_name  => 'CONTRACT_TRADEIN',
              p_contract_id   => p_khr_id,
              p_line_id       => p_kle_id,
              x_value         => l_amount_buffer);
      */
      --skgautam Bug#5260198
      -- bug 5402377 -- start
      OPEN downpymnt_recvr_csr(p_kle_id);
      FETCH downpymnt_recvr_csr INTO l_downpymnt_recvr;
      CLOSE downpymnt_recvr_csr;

      IF ((l_downpymnt_recvr IS NULL) OR (l_downpymnt_recvr = 'VENDOR')) THEN
        -- bug 5402377 -- end
        l_amount_buffer := okl_seeded_functions_pvt.line_capital_reduction(p_chr_id => p_khr_id, p_line_id => p_kle_id);

        --END:| 27-Feb-2006  cklee -- Fixed bug#5003962                                    |
        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
          l_amount_buffer := 0;
        ELSIF(x_return_status = okl_api.g_ret_sts_error) THEN
          l_amount_buffer := 0;
        END IF;
        --bug 5500032 --start
      ELSIF(l_downpymnt_recvr = 'LESSOR') THEN
        l_amount_buffer := 0;
        --bug 5500032 -- end
        -- bug 5402377 -- start
      END IF;
      -- bug 5402377 -- END
    EXCEPTION
      WHEN OTHERS THEN
        l_amount_buffer := 0;
    END;

    l_amount := l_amount - l_amount_buffer;

    --------------------------------------------------
    -- Contract Trade In
    --------------------------------------------------
    BEGIN
      --START:| 27-Feb-2006  cklee -- Fixed bug#5003962                                    |
      /*
            OKL_EXECUTE_FORMULA_PUB.execute(
              p_api_version   => l_api_version,
              p_init_msg_list => l_init_msg_list,
              x_return_status => x_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_formula_name  => 'CONTRACT_CAPREDUCTION',
              p_contract_id   => p_khr_id,
              p_line_id       => p_kle_id,
              x_value         => l_amount_buffer);
      */
      --skgautam Bug#5260198
      l_amount_buffer := okl_seeded_functions_pvt.line_tradein(p_chr_id => p_khr_id, p_line_id => p_kle_id);

      --END:| 27-Feb-2006  cklee -- Fixed bug#5003962                                    |
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        l_amount_buffer := 0;
      ELSIF(x_return_status = okl_api.g_ret_sts_error) THEN
        l_amount_buffer := 0;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_amount_buffer := 0;
    END;

    l_amount := l_amount - l_amount_buffer;
    -- end: okl.h: cklee
  END IF;

  IF (l_amount IS NULL) THEN
    l_amount := 0;
  END IF;

  RETURN l_amount;
END get_contract_line_amt;



----------------------------------------------------------------------------
FUNCTION get_contract_line_funded_amt(
  p_khr_id                       IN NUMBER                 -- contract hdr
 ,p_kle_id                       IN NUMBER                 -- contract line
 ,p_ref_type_code                IN VARCHAR2
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_khr_id  NUMBER,
            p_kle_id  NUMBER)
  IS

    SELECT SUM(tl.amount)
      FROM okl_trx_ap_invoices_b th,
           okl_txl_ap_inv_lns_all_b tl
     WHERE th.id = tl.tap_id
       AND tl.khr_id = p_khr_id
       AND tl.kle_id = p_kle_id
-- fixed bug 3007875
       AND th.TRX_STATUS_CODE NOT IN ('CANCELED', 'ERROR', 'REJECTED');

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR ct (p_khr_id            NUMBER,
             p_kle_id            NUMBER,
             p_funding_type_code VARCHAR2)
  IS
    SELECT SUM(tl.amount)
      FROM okl_trx_ap_invoices_b th,
           okl_txl_ap_inv_lns_all_b tl
     WHERE th.id = tl.tap_id
       AND tl.khr_id = p_khr_id
       AND tl.kle_id = p_kle_id
       AND th.funding_type_code = p_funding_type_code
-- fixed bug 3007875
       AND th.TRX_STATUS_CODE NOT IN ('CANCELED', 'ERROR', 'REJECTED');
BEGIN
  IF (p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM) OR
     (p_kle_id IS NULL OR p_kle_id = OKL_API.G_MISS_NUM)
  THEN
    RETURN OKL_API.G_MISS_NUM;  -- error
  ELSIF (p_ref_type_code IS NULL OR p_ref_type_code = OKL_API.G_MISS_CHAR) THEN
    OPEN c (p_khr_id, p_kle_id);
    FETCH c INTO l_amount;
    CLOSE c;
  ELSE
    OPEN ct (p_khr_id, p_kle_id, p_ref_type_code);
    FETCH ct INTO l_amount;
    CLOSE ct;
  END IF;
  IF (l_amount IS NULL) THEN l_amount := 0; END IF;
  RETURN l_amount;
END;
----------------------------------------------------------------------------

-- get contract fund amount for asset lines
FUNCTION get_contract_line_funded_amt(
  p_fund_id                       IN NUMBER                 -- fund hdr
  ,p_fund_type                    IN VARCHAR2               -- fund type code
) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  CURSOR c (p_fund_id  NUMBER)
  IS
    SELECT nvl(SUM(tl.amount),0)
      FROM okl_trx_ap_invoices_b th,
           okl_txl_ap_inv_lns_b tl
     WHERE tl.tap_id = th.id
       AND th.id = p_fund_id
-- no need for this function. this is used for display at UI site only
--       AND th.TRX_STATUS_CODE NOT IN ('CANCELED', 'ERROR', 'REJECTED')
  ;
  CURSOR c2 (p_fund_id  NUMBER)
  IS
    SELECT nvl(th.amount,0)
      FROM okl_trx_ap_invoices_b th
       WHERE th.id = p_fund_id
-- no need for this function. this is used for display at UI site only
--       AND th.TRX_STATUS_CODE NOT IN ('CANCELED', 'ERROR', 'REJECTED')
  ;

BEGIN
    IF (p_fund_type in (G_ASSET_TYPE_CODE,
                        G_SUPPLIER_RETENTION_TYPE_CODE,
--START:| 08-Jun-2006   cklee   Bug#5291817 get_contract_line_funded_amt() for
--                              sync_header_amount()              |
                        G_ASSET_SUBSIDY,
--END:| 08-Jun-2006   cklee   Bug#5291817 get_contract_line_funded_amt() for
--                              sync_header_amount()              |
                        G_EXPENSE,
                        G_MANUAL_DISB)) THEN -- cklee 05/04/2004
      OPEN c (p_fund_id);

      FETCH c INTO l_amount;
      CLOSE c;
    ELSE
      OPEN c2(p_fund_id);
      FETCH c2 INTO l_amount;
      CLOSE c2;
    END IF;
/*
    IF (p_fund_type = 'SUPPLIER_RETENTION') THEN
      l_amount := -(l_amount);
    END IF;
*/

  RETURN l_amount;

END;
----------------------------------------------------------------------------

FUNCTION is_funding_unique(
  p_vendor_id                    IN NUMBER
 ,p_fund_number                  IN VARCHAR2
 ,p_org_id                       IN NUMBER
) RETURN VARCHAR2
IS
 l_result VARCHAR2(1) := OKL_API.G_TRUE;
 l_dummy  VARCHAR2(1) := '?';

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_fund_number VARCHAR2,
            p_org_id number,
            p_vendor_id number)
  IS
    SELECT 'X'
      FROM okl_trx_ap_invoices_b th,
           okl_txl_ap_inv_lns_all_b tl,
           okc_k_headers_b chr,
           PO_VENDOR_SITES_ALL VS
     WHERE th.id = tl.tap_id
     AND tl.khr_id = chr.id
     AND th.ipvs_id = vs.vendor_site_id
     AND th.vendor_invoice_number = p_fund_number
     AND chr.AUTHORING_ORG_ID = p_org_id
     AND VS.vendor_id = p_vendor_id;

BEGIN
  IF (p_vendor_id IS NULL OR p_vendor_id = OKL_API.G_MISS_NUM) OR
     (p_fund_number IS NULL OR p_fund_number = OKL_API.G_MISS_CHAR)
  THEN
    RETURN OKL_API.G_MISS_CHAR;
  END IF;

--  OPEN c(p_vendor_id, p_fund_number);
  OPEN c(p_fund_number, p_org_id, p_vendor_id);

  FETCH c INTO l_dummy;
  CLOSE c;
  IF (l_dummy = 'X') THEN
    l_result := OKL_API.G_FALSE;
  END IF;
  RETURN l_result;
END is_funding_unique;
----------------------------------------------------------------------------

FUNCTION is_contract_line_unique(
  p_kle_id                       IN NUMBER -- contract_line_id
 ,p_fund_id                      IN NUMBER
 ,p_fund_line_id                 IN NUMBER
 ,p_mode                         IN VARCHAR2
 ,p_org_id                       IN NUMBER
) RETURN VARCHAR2
IS
 l_result VARCHAR2(1) := OKL_API.G_TRUE;
 l_dummy  VARCHAR2(1) := '?';
 l_count  NUMBER(1) := 0;

  CURSOR c (p_fund_id NUMBER, p_kle_id NUMBER)
  IS
    SELECT 'X'
      FROM okl_txl_ap_inv_lns_b t
     WHERE t.tap_id = p_fund_id
     AND   t.kle_id = p_kle_id
  ;

  CURSOR c2 (p_fund_id NUMBER, p_kle_id NUMBER, p_fund_line_id NUMBER)
  IS


    SELECT 'X'
      FROM okl_txl_ap_inv_lns_b t
     WHERE t.tap_id = p_fund_id
     AND   t.kle_id = p_kle_id

     AND   t.id <> p_fund_line_id -- except itself
  ;

BEGIN

  IF (p_kle_id IS NULL OR p_kle_id = OKL_API.G_MISS_NUM) OR
     (p_fund_id IS NULL OR p_fund_id = OKL_API.G_MISS_NUM)
  THEN
    RETURN OKL_API.G_MISS_NUM;
  END IF;

  IF (p_mode = 'C') THEN

    OPEN c(p_fund_id, p_kle_id);
    FETCH c INTO l_dummy;
    CLOSE c;

  ELSIF (p_mode = 'U') THEN
    OPEN c2(p_fund_id, p_kle_id, p_fund_line_id);

    FETCH c2 INTO l_dummy;
    CLOSE c2;

  END IF;

  IF (l_dummy = 'X') THEN
    l_result := OKL_API.G_FALSE;
  END IF;


  RETURN l_result;

END is_contract_line_unique;

--
-- search duplicated kle_id in this table by specific okl_trx_ap_inv_lns_b.tap_id
--
FUNCTION is_kle_id_unique(
    p_tplv_tbl                 IN tplv_tbl_type
) RETURN VARCHAR2
IS
  l_result   VARCHAR2(1) := OKL_API.G_TRUE;
  l_tplv_tbl tplv_tbl_type := p_tplv_tbl;
  i        NUMBER;
  j        NUMBER;
  l_count  NUMBER;


BEGIN

  -- check duplicated kle_id in this table
  IF (p_tplv_tbl.COUNT > 0) THEN
    i := p_tplv_tbl.FIRST;
    LOOP

      -- inner being search loop
      l_count := 0;
      j := l_tplv_tbl.FIRST;
      LOOP


        IF (p_tplv_tbl(i).kle_id = l_tplv_tbl(j).kle_id) THEN
          l_count := l_count+1;
          IF (l_count > 1) THEN
            l_result := OKL_API.G_FALSE;
            EXIT;

          END IF;
        END IF;

        EXIT WHEN (j = l_tplv_tbl.LAST);
--        j := l_tplv_tbl.NEXT(i);
        j := l_tplv_tbl.NEXT(j); --  cklee 10/3/2007 bug: 6318418
      END LOOP;

      -- exit if duplicated rows found
      IF (l_count > 0) THEN
        EXIT;
      END IF;

      EXIT WHEN (i = p_tplv_tbl.LAST);
      i := p_tplv_tbl.NEXT(i);
    END LOOP;
  END IF;
  RETURN l_result;

END is_kle_id_unique;

-------------------------------------------------------------------------------

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_amount_prefunded                                            |
|  DESC   : Sum of all approved requests for specfiic contract where type    |
|          = prefunding                                                      |
|  IN     : p_contract_id                                                    |
|  OUT NOCOPY    : amount                                                    |
|  HISTORY: 13-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION get_amount_prefunded(
 p_contract_id                   IN NUMBER
 ,p_vendor_site_id               IN NUMBER

) RETURN NUMBER

IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.funding_type_code = 'PREFUNDING'
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and b.khr_id = p_contract_id
-- positive only
  and a.amount > 0
  ;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c2 (p_contract_id  NUMBER, p_vendor_site_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)

  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
   and a.funding_type_code = 'PREFUNDING'
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and b.khr_id = p_contract_id
  and a.ipvs_id = p_vendor_site_id
-- positive only
  and a.amount > 0
  ;

BEGIN

  IF (p_vendor_site_id IS NULL OR p_vendor_site_id = OKL_API.G_MISS_NUM) THEN

    OPEN c (p_contract_id);
    FETCH c INTO l_amount;
    CLOSE c;
  ELSE
    OPEN c2 (p_contract_id, p_vendor_site_id);
    FETCH c2 INTO l_amount;
    CLOSE c2;
  END IF;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_total_funded                                                |
|  DESC   : Sum of all approved requests for specific contract               |
|  IN     : p_contract_id                                                    |
|  OUT NOCOPY    : amount                                                    |
|  HISTORY: 13-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION get_total_funded(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER

IS
  l_amount NUMBER := 0;
  x_amount NUMBER := 0;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code IN ('ASSET','EXPENSE', G_ASSET_SUBSIDY) -- cklee 11.5.10 subsidy
  and b.khr_id = p_contract_id
UNION
  select nvl(sum(a.amount),0)
  from okl_trx_ap_invoices_b a
       ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
   and a.funding_type_code in ('PREFUNDING', 'BORROWER_PAYMENT') -- fixed bug# 2604862
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and b.khr_id = p_contract_id
  ;

BEGIN

  OPEN c (p_contract_id);
  LOOP
    FETCH c INTO l_amount;
    EXIT WHEN c%NOTFOUND;
    x_amount := x_amount + l_amount;
  END LOOP;
  CLOSE c;

  RETURN x_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_total_retention                                             |
|  DESC   : Sum of all approved requests for specific contract               |
|           where funding type = 'SUPPLIER_RETENTION'                        |
|  IN     : p_contract_id                                                    |
|  OUT NOCOPY    : amount                                                    |
|  HISTORY: 13-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */

FUNCTION get_total_retention(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(b.amount),0)
  from okl_trx_ap_invoices_b a,
       okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and b.khr_id = p_contract_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code = 'SUPPLIER_RETENTION';

BEGIN

  OPEN c (p_contract_id);
  FETCH c INTO l_amount;
  CLOSE c;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_amount_borrowerPay                                          |
|  DESC   : Sum of all approved requests for specific contract               |
|           where funding type = 'BORROWER_PAYMENT'                          |
|  IN     : p_contract_id                                                    |
|  OUT NOCOPY    : amount                                                    |
|  HISTORY: 02-OCT-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION get_amount_borrowerPay(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and b.khr_id = p_contract_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code = 'BORROWER_PAYMENT';

BEGIN

  OPEN c (p_contract_id);
  FETCH c INTO l_amount;
  CLOSE c;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;


END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_amount_subsidy                                              |
|  DESC   : Sum of all approved requests for specific contract               |
|           where funding type = 'ASSET_SUBSIDY'                             |
|  IN     : p_contract_id                                                    |
|  OUT NOCOPY    : amount                                                    |
|  HISTORY: 02-OCT-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION get_amount_subsidy(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from okl_trx_ap_invoices_b a
      ,okl_txl_ap_inv_lns_all_b b
  where a.id = b.tap_id
  and a.khr_id = p_contract_id
  and a.trx_status_code in ('APPROVED', 'PROCESSED')
  and a.funding_type_code = G_ASSET_SUBSIDY;

  -- sjalasut, modified the cursor below to have khr_id referred from
  -- okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b. changes made
  -- as part of OKLR12B disbursements project.
  CURSOR c_sub (p_contract_id  NUMBER, p_contract_line_id NUMBER)
  IS
  select nvl(sum(subln.amount),0)
  from okl_trx_ap_invoices_b sub,
       okl_txl_ap_inv_lns_all_b subln
  where sub.id = subln.tap_id
  and subln.khr_id = p_contract_id
  and subln.kle_id = p_contract_line_id -- fixed asset ID
  and sub.trx_status_code in ('APPROVED', 'PROCESSED')
  and sub.funding_type_code = G_ASSET_SUBSIDY;


BEGIN

  IF (p_contract_line_id IS NULL OR p_contract_line_id = OKL_API.G_MISS_NUM) THEN

    OPEN c (p_contract_id);
    FETCH c INTO l_amount;
    CLOSE c;

  ELSE

    OPEN c_sub (p_contract_id, p_contract_line_id);
    FETCH c_sub INTO l_amount;
    CLOSE c_sub;

  END IF;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;


END get_amount_subsidy;

-------------------------------------------------------------------------
 FUNCTION get_funding_subsidy_amount(
    p_chr_id                       IN  NUMBER,
    p_asset_cle_id                 IN  NUMBER,
    p_vendor_site_id               IN  NUMBER
) RETURN NUMBER
IS
--    l_amount            NUMBER := 0;
    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_subsidy_amount    NUMBER := 0;
    l_vendor_id         NUMBER := NULL;


  CURSOR cv1 (p_vendor_site_id NUMBER)
  IS
    select vendor_id from okx_vendor_sites_v
    where id1 = to_char(p_vendor_site_id)
  ;

BEGIN

    IF (p_vendor_site_id IS NOT NULL) THEN

      OPEN cv1 (p_vendor_site_id);
      FETCH cv1 INTO l_vendor_id;
      CLOSE cv1;
    END IF;

    OKL_SUBSIDY_PROCESS_PVT.get_funding_subsidy_amount(
        p_api_version    => l_api_version,
        p_init_msg_list  => l_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_chr_id         => p_chr_id,
        p_asset_cle_id   => p_asset_cle_id,
        p_vendor_id      => l_vendor_id,
        x_subsidy_amount => x_subsidy_amount

    );


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    RETURN x_subsidy_amount;

  EXCEPTION
    WHEN OTHERS THEN

      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_funding_subsidy_amount;


-------------------------------------------------------------------------
 FUNCTION get_partial_subsidy_amount(
    p_asset_cle_id                 IN  NUMBER,
    p_req_fund_amount              IN  NUMBER
) RETURN NUMBER
IS
    l_amount            NUMBER := 0;
    i                   NUMBER;
    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_partial_subsidy_amount    NUMBER := 0;
    x_asbv_tbl OKL_SUBSIDY_PROCESS_PVT.asbv_tbl_type;

BEGIN


    OKL_SUBSIDY_PROCESS_PVT.get_partial_subsidy_amount(
        p_api_version     => l_api_version,
        p_init_msg_list   => l_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_asset_cle_id    => p_asset_cle_id,
        p_req_fund_amount => p_req_fund_amount,
        x_asbv_tbl        => x_asbv_tbl
    );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (x_asbv_tbl.COUNT > 0) THEN
      i := x_asbv_tbl.FIRST;

      LOOP

        l_amount := l_amount + x_asbv_tbl(i).amount;
        EXIT WHEN (i = x_asbv_tbl.LAST);
        i := x_asbv_tbl.NEXT(i);
      END LOOP;
    END IF;

    RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;

      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_partial_subsidy_amount;


-- cklee 04-May-2004
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_amount_manu_disb                                            |
|  DESC   : Sum of all approved requests for specific contract               |
|           where funding type = 'MANUAL_DISB'                               |
|  IN     : p_contract_id                                                    |
|  OUT NOCOPY    : amount                                                    |
|  HISTORY: 04-MAY-04 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION get_amount_manu_disb(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR c_manu_disb (p_contract_id  NUMBER)
  IS
  -- select nvl(sum(decode(sub.invoice_type, 'CREDIT', -subln.amount, subln.amount)),0)
  -- sjalasut, commented the above select as part of OKLR12B disbursements project
  select nvl(sum(subln.amount),0)
  from okl_trx_ap_invoices_b sub,
       okl_txl_ap_inv_lns_b subln
  where sub.id = subln.tap_id
  and sub.trx_status_code in ('APPROVED', 'PROCESSED')
  and sub.funding_type_code = G_MANUAL_DISB
  and subln.khr_id = p_contract_id;
  -- sjalasut, commented the reference of khr_id. p_contract_id now joins with
  -- subln instead of sub. changes made as part of OKLR12B disbursements project
  -- and sub.khr_id = p_contract_id

BEGIN

  OPEN c_manu_disb (p_contract_id);
  FETCH c_manu_disb INTO l_amount;
  CLOSE c_manu_disb;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;


END get_amount_manu_disb;

-- strat: T and A 11/04/2004
-- Total contract can be funded fee amount
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Total contract can be funded fee amount
-- Description     : Total contract can be funded fee amount for a fee line
--                   by an given date
--                   IN: p_contract_id is the lease contract ID
--                   IN: p_fee_line_id is the lease contract fee line ID
--                   IN: p_effective_date is the effective date of the total fee amount
--                   OUT: x_value is the fee amount
-- Business Rules  : x_value will be 0 if fee line has not meet the following requirements
--                 : 1. Effective date greater than line start date
--                      (or contract start date if line start date is null)
--                   2. contract okc_k_headers_b.ste_code
--                      in ('ENTERED', 'ACTIVE','SIGNED')
--                   3. fee line is not passthrough
--                   4. fee line is associated with vendor
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE contract_fee_canbe_funded(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_contract_id                  IN NUMBER
   ,p_fee_line_id                  IN NUMBER
   ,p_effective_date               IN DATE
 )
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'contract_fee_canbe_funded';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN
  -- Set API savepoint

  SAVEPOINT contract_fee_canbe_funded_PVT;

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
  x_value := get_chr_fee_canbe_funded_amt(
              p_contract_id    => p_contract_id
             ,p_fee_line_id    => p_fee_line_id
             ,p_effective_date => p_effective_date);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO contract_fee_canbe_funded;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO contract_fee_canbe_funded;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO contract_fee_canbe_funded;
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


END contract_fee_canbe_funded;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_chr_fee_canbe_funded_amt
-- Description     : Total contract can be funded fee amount for a fee line
--                   by an given date
--                   IN: p_contract_id is the lease contract ID
--                   IN: p_fee_line_id is the lease contract fee line ID
--                   IN: p_effective_date is the effective date of the total fee amount
-- Business Rules  : x_value will be 0 if fee line has not meet the following requirements
--                 : 1. Effective date greater than line start date
--                      (or contract start date if line start date is null)
--                   2. contract okc_k_headers_b.ste_code
--                      in ('ENTERED', 'ACTIVE','SIGNED')
--                   3. fee line is not passthrough
--                   4. fee line is associated with vendor
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_chr_fee_canbe_funded_amt(
  p_contract_id                IN NUMBER                 -- contract hdr
  ,p_fee_line_id               IN NUMBER
  ,p_effective_date            IN DATE
) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_cle_amount NUMBER := 0;
  l_amount_per NUMBER := 0;

  l_cle_id NUMBER := 0;
  l_cle_start_date DATE;
  l_period NUMBER := 0;
  l_period_org NUMBER := 0;
  l_row_notfound   BOOLEAN;

  CURSOR c (p_contract_id  NUMBER,
            p_rle_code     VARCHAR2,
            p_fee_line_id  NUMBER)
  IS
select nvl(cle.AMOUNT,0),
       cle.id,
       nvl(cle.start_date,k.start_date)
from   OKL_K_LINES_FULL_V cle,
       okc_k_party_roles_b cpl,
       okc_line_styles_b ls,
       okc_k_headers_b k
where  k.id           = cle.dnz_chr_id
and    cle.dnz_chr_id = p_contract_id
and    cle.lse_id     = ls.id
and    ls.lty_code    = p_rle_code
and    cle.id         = cpl.cle_id
and    cpl.dnz_chr_id = p_contract_id
and    cpl.chr_id     is null
and    cpl.rle_code   = 'OKL_VENDOR'
and    cle.id         = p_fee_line_id
--and    cpl.object1_id1 = to_char(p_vendor_id)
--and    cpl.object1_id2 = '#'
-- Pass through check
/*
and not exists (select null
                from   okc_rule_groups_v crg,
                       okc_rules_v cr
                where  crg.dnz_chr_id = p_contract_id
                and    crg.cle_id     = cle.id -- line id for rle_code
                and    crg.id         = cr.rgp_id
                and    crg.rgd_code   = 'LAPSTH') */
and not exists (select null
                from   okl_party_payment_hdr phr
                where  phr.dnz_chr_id = p_contract_id
                and    phr.cle_id = cle.id)
;


--
-- get Number of Period
--
-- 1) take contract start date if cle start date is null
-- 2) truncate pay period if less than 0
--
  CURSOR c_period (p_contract_id    NUMBER,
                   p_cle_id         NUMBER,
                   p_effective_date DATE)
  IS
select ceil(decode(cr.object1_id1, 'A', months_between(p_effective_date, nvl(cle.start_date, k.start_date))/12
                            , 'M', months_between(p_effective_date, nvl(cle.start_date, k.start_date))
                            , 'Q', months_between(p_effective_date, nvl(cle.start_date, k.start_date))/3
                            , 'S', months_between(p_effective_date, nvl(cle.start_date, k.start_date))/6
                            , months_between(p_effective_date, nvl(cle.start_date, k.start_date))))
from   okc_rule_groups_v crg,
       okc_rules_v cr,
       OKL_K_LINES_FULL_V cle,
       okc_k_headers_b k
where  crg.dnz_chr_id = p_contract_id
and    cle.dnz_chr_id = k.id
and    crg.id         = cr.rgp_id
and    crg.rgd_code   = 'LAFEXP'
and    crg.cle_id     = cle.id
and    cr.RULE_INFORMATION_CATEGORY = 'LAFREQ'
and    cle.id         = p_cle_id
;

--
-- get amount per period
--
--
  CURSOR c_amount_per (p_contract_id NUMBER,
                       p_cle_id NUMBER)
  IS
select to_number(nvl(cr.RULE_INFORMATION1,'0'))
       ,to_number(nvl(cr.RULE_INFORMATION2,'0'))
from   okc_rule_groups_v crg,
       okc_rules_v cr
where  crg.dnz_chr_id = p_contract_id
and    crg.id         = cr.rgp_id
and    crg.rgd_code   = 'LAFEXP'
and    cr.RULE_INFORMATION_CATEGORY = 'LAFEXP'
and    crg.cle_id     = p_cle_id
;


BEGIN
  IF ((p_contract_id IS NULL OR p_contract_id = OKL_API.G_MISS_NUM) or
      (p_fee_line_id IS NULL OR p_fee_line_id = OKL_API.G_MISS_NUM) or
      (p_effective_date IS NULL OR p_effective_date = OKL_API.G_MISS_DATE))
  THEN
    RETURN 0;  -- error
  ELSE

    ----------------------------------------------------
    -- FEE line

    ----------------------------------------------------
    OPEN c (p_contract_id, 'FEE', p_fee_line_id);
    LOOP

      FETCH c into l_cle_amount,
                   l_cle_id,
                   l_cle_start_date;

      EXIT WHEN c%NOTFOUND;


      OPEN c_amount_per (p_contract_id, l_cle_id);
      FETCH c_amount_per INTO l_period_org,
                              l_amount_per;

      l_row_notfound := c_amount_per%NOTFOUND;
      CLOSE c_amount_per;

      -- if recurring records doesn't exists
      IF (l_row_notfound) THEN

        -- either fee effective date or contract effective date <= p_effective_date
        IF ( l_cle_start_date <= p_effective_date ) THEN
          l_amount := l_amount + l_cle_amount;

        END IF;

      ELSE

        OPEN c_period (p_contract_id, l_cle_id, p_effective_date);
        FETCH c_period INTO l_period;
        CLOSE c_period;

        -- calculate only if period is positive
        IF (l_period > 0) THEN

          IF (l_period > l_period_org) THEN
            l_period := l_period_org;
          END IF;
          l_amount := l_amount + (l_amount_per * l_period);
        END IF;


      END IF;

    END LOOP;

    CLOSE c;

  END IF; -- end if p_contract_id check

  IF (l_amount IS NULL) THEN
    l_amount := 0;
  END IF;

  IF (okl_funding_pvt.is_chr_fundable_status(p_contract_id) = 0) THEN
    l_amount := 0;
  END IF;

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;


END;

-- end: T and A 11/04/2004

-- strat: T and A bug#4151222
 FUNCTION is_contract_fully_funded(
  p_contract_id                IN NUMBER
 ) RETURN boolean
IS
  l_flag               boolean := false;
  l_chr_canbe_funded   number;
  l_amount_oec         number;
  l_amount_expense     number;
  l_amount_hasbeen_oec number;
  l_amount_hasbeen_exp number;


BEGIN

  l_amount_oec := get_chr_oec_canbe_funded(p_contract_id);
  l_amount_expense := get_chr_exp_canbe_funded_amt(p_contract_id);
  l_amount_hasbeen_oec := get_chr_oec_hasbeen_funded_amt(p_contract_id);
  l_amount_hasbeen_exp := get_chr_exp_hasbeen_funded_amt(p_contract_id);

  --
  -- has been funded may over totoal fundable amount due to asset termination
  --
  if ( l_amount_hasbeen_oec + l_amount_hasbeen_exp >=
       l_amount_oec + l_amount_expense) then
    l_flag := true;
  else
    l_flag := false;
  end if;

  RETURN l_flag;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN false;

END is_contract_fully_funded;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : Is contract fully funded
-- Description     : Is contract fully funded
--                   IN: p_contract_id is the lease contract ID
--                   OUT: x_value is the flag to indicate if contract is fully funded
-- Business Rules  : x_value will be false if error occurred
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE is_contract_fully_funded(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY BOOLEAN
   ,p_contract_id                  IN NUMBER
 )
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'is_contract_fully_funded';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN
  -- Set API savepoint

  SAVEPOINT is_contract_fully_funded_pvt;

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
  x_value := is_contract_fully_funded(
              p_contract_id    => p_contract_id);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO is_contract_fully_funded;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO is_contract_fully_funded;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO is_contract_fully_funded;
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


END is_contract_fully_funded;


-- end: T and A bug#4151222

--Added procedure get_checklist_source as part of bug 5912358, Funding OA Migration Issues
 ----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_checklist_source
-- Description     : Returns checklist source details whether contract was originated from lease app, whether checklist exists or not and get source checklist template.
--                   IN: p_chr_id is the contract ID
--                   OUT: x_lease_app_found returns where contract was originated from leaseapp or not
--                   OUT: x_lease_app_list_found returns whether lease checklist exists or not
--                   OUT: x_funding_checklist_tpl returns source checklist template ID
--                   OUT: x_lease_app_id returns lease application id
--                   OUT: x_credit_id returns credit template id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_checklist_source(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                        IN okc_k_headers_b.id%type
   ,x_lease_app_found       OUT NOCOPY VARCHAR2
   ,x_lease_app_list_found OUT NOCOPY VARCHAR2
   ,x_funding_checklist_tpl OUT NOCOPY okc_rules_b.rule_information2%TYPE
   ,x_lease_app_id          OUT NOCOPY NUMBER
   ,x_credit_id                OUT NOCOPY NUMBER
 ) IS

  l_lease_app_id number := OKC_API.G_MISS_NUM;
  l_lease_app_found boolean := FALSE;
  l_dummy number;
  l_lease_app_list_found boolean := FALSE;
  l_credit_id okc_k_headers_b.id%TYPE;
  l_funding_checklist_tpl okc_rules_b.rule_information2%TYPE := OKC_API.G_MISS_CHAR;

 --------------------------------------------------------------------------------------------
-- Checklists link check
--------------------------------------------------------------------------------------------
CURSOR c_checklists (p_credit_id  NUMBER)
  IS
  select rule.rule_information2
  from okc_rules_b rule
  where rule.dnz_chr_id = p_credit_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;

---------------------------------------------------------------------------------------------------------
-- check if the contract was created from a lease application
---------------------------------------------------------------------------------------------------------
CURSOR c_lease_app (p_chr_id okc_k_headers_b.id%type)
IS
  select chr.ORIG_SYSTEM_ID1
from  okc_k_headers_b chr
where ORIG_SYSTEM_SOURCE_CODE = G_OKL_LEASE_APP
and   chr.id = p_chr_id
;

cursor c_lease_app_list_exists (p_lease_app_id number) is
select 1
from OKL_CHECKLIST_DETAILS chk
     ,okl_checklists hdr
where chk.ckl_id = hdr.id
and hdr.CHECKLIST_OBJ_ID = p_lease_app_id
and chk.INST_CHECKLIST_TYPE = 'FUNDING'
;

 BEGIN

  OPEN c_lease_app(p_chr_id);
  FETCH c_lease_app INTO l_lease_app_id;
  l_lease_app_found := c_lease_app%FOUND;
  CLOSE c_lease_app;


  IF l_lease_app_id IS NOT NULL THEN
    OPEN c_lease_app_list_exists(l_lease_app_id);
    FETCH c_lease_app_list_exists INTO l_dummy;
    l_lease_app_list_found := c_lease_app_list_exists%FOUND;
    CLOSE c_lease_app_list_exists;
  END IF;

  IF NOT l_lease_app_found THEN
-- get credit line id
-- If contract credit line has been changed, but funding requests
-- still have not been apporved. We need to re-generate list from the
-- new credit line
    l_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_chr_id);

-- get source checklist template ID
    OPEN c_checklists(l_credit_id);
    FETCH c_checklists INTO l_funding_checklist_tpl;
    CLOSE c_checklists;
  END IF;
  IF (l_lease_app_found) THEN
	x_lease_app_found := 'TRUE';
  ELSE
	x_lease_app_found := 'FALSE';
  END IF;
  IF (l_lease_app_list_found) THEN
	x_lease_app_list_found := 'TRUE';
  ELSE
	x_lease_app_list_found := 'FALSE';
  END IF;
  x_funding_checklist_tpl := l_funding_checklist_tpl;
  x_lease_app_id := l_lease_app_id;
  x_credit_id := l_credit_id;
  x_return_status := 'S';
 EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

 END get_checklist_source;

-- start: 24-May-2005  cklee okl.h Lease App IA Authoring
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_function
-- Description     : This API will execute function for each item and
--                   update the execution results for the function.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_function(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_req_id                  IN  NUMBER
 ) is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_function';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_dummy  number;

  l_row_not_found boolean := false;

  lp_rulv_tbl        okl_funding_checklist_pvt.rulv_tbl_type;
  lx_rulv_tbl        okl_funding_checklist_pvt.rulv_tbl_type;
  plsql_block        VARCHAR2(500);

  lp_return_status   okl_funding_checklists_uv.FUNCTION_VALIDATE_RSTS%type;
  lp_fund_rst        okl_funding_checklists_uv.FUNCTION_VALIDATE_RSTS%type;
  lp_msg_data        okl_funding_checklists_uv.FUNCTION_VALIDATE_MSG%type;
  l_contract_id      okl_funding_checklists_uv.KHR_ID%type;

-- get checklist template attributes
cursor c_clist_funs (p_fund_req_id varchar2) is
--start modified abhsaxen for performance SQLID 20562504
SELECT rult.ID,  rult.DNZ_CHR_ID khr_id,
fun.source function_source
FROM OKC_RULES_B RULT,
OKL_DATA_SRC_FNCTNS_B FUN
WHERE rult.rule_information_category = 'LAFCLD'
and rult.object1_id1 = p_fund_req_id
and rult.RULE_INFORMATION9 = fun.Id   ;
--end modified abhsaxen for performance SQLID 20562504

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_function;

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
    ------------------------------------------------------------------------
    -- execute function for each to do item and save the return to each row
    ------------------------------------------------------------------------
    i := 0;
    --modified abhsaxen pass p_fund_req_id in varchar2 format for performannce SQLID 20562504
    FOR r_this_row IN c_clist_funs (TO_CHAR(p_fund_req_id)) LOOP

      BEGIN

        l_contract_id := r_this_row.khr_id;
--START:| 02-Mar-2006  cklee -- Fixed bug#5068910                                    |
--        plsql_block := 'BEGIN :l_rtn := '|| r_this_row.FUNCTION_SOURCE ||'(:l_contract_id); END;';
--        EXECUTE IMMEDIATE plsql_block USING OUT lp_return_status, l_contract_id;
        plsql_block := 'BEGIN :l_rtn := '|| r_this_row.FUNCTION_SOURCE ||'(:l_contract_id, :l_fund_req_id); END;';
        EXECUTE IMMEDIATE plsql_block USING OUT lp_return_status, l_contract_id, p_fund_req_id;
--END:| 02-Mar-2006  cklee -- Fixed bug#5068910                                    |

        IF lp_return_status = 'P' THEN
          lp_fund_rst := 'PASSED';
          lp_msg_data := 'Passed';
        ELSIF lp_return_status = 'F' THEN
          lp_fund_rst := 'FAILED';
          lp_msg_data := 'Failed';
        ELSE
          lp_fund_rst := 'ERROR';
          lp_msg_data := r_this_row.FUNCTION_SOURCE || ' returns: ' || lp_return_status;
        END IF;

      EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          lp_fund_rst := 'ERROR';
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);
          lp_msg_data := substr('Application error: ' || x_msg_data, 240);

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          lp_fund_rst := 'ERROR';
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);
          lp_msg_data := substr('Unexpected application error: ' || x_msg_data, 240);

        WHEN OTHERS THEN
          lp_fund_rst := 'ERROR';
          lp_msg_data := substr('Unexpected system error: ' || SQLERRM, 240);

      END;

      lp_rulv_tbl(i).ID := r_this_row.ID;
      lp_rulv_tbl(i).RULE_INFORMATION7 := lp_fund_rst;
      lp_rulv_tbl(i).RULE_INFORMATION8 := lp_msg_data;
      i := i + 1;

    END LOOP;

    IF lp_rulv_tbl.count > 0 THEN

      okl_funding_checklist_pvt.update_funding_chklst(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_function;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_function;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN

	ROLLBACK TO update_checklist_function;
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

end update_checklist_function;
-- end: 24-May-2005  cklee okl.h Lease App IA Authoring

----------------------------------------------------------------------------
/*
-- zrehman, 10/13/2006
-- START, Added PROCEDURE to get Funding Summary
*/
-- Start of comments
--
-- Procedure Name  : get_fund_summary
-- Description     : public_procedure, gets fund summary by making calls to
--                   functions in OKL_FUND_SMRY_PVT
-- Business Rules  :
-- Parameters      : contract ID
-- Version         : 1.0
-- End of comments
--

PROCEDURE get_fund_summary(
                p_api_version       IN NUMBER,
                p_init_msg_list     IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_contract_id       IN NUMBER,
		x_fnd_rec           OUT NOCOPY fnd_rec_type
                ) IS

BEGIN
   x_fnd_rec.TOTAL_FUNDABLE_AMOUNT := OKL_FUNDING_PVT.get_chr_canbe_funded(p_contract_id);
   x_fnd_rec.TOTAL_PRE_FUNDED := OKL_FUNDING_PVT.get_amount_prefunded(p_contract_id);
   x_fnd_rec.TOTAL_ASSETS_FUNDED := OKL_FUNDING_PVT.get_chr_oec_hasbeen_funded_amt(p_contract_id);
   x_fnd_rec.TOTAL_EXPENSES_FUNDED := OKL_FUNDING_PVT.get_chr_exp_hasbeen_funded_amt(p_contract_id);
   x_fnd_rec.TOTAL_ADJUSTMENTS := OKL_FUNDING_PVT.get_chr_funded_adjs(p_contract_id);
   x_fnd_rec.TOTAL_REMAINING_TO_FUND := OKL_FUNDING_PVT.get_chr_canbe_funded_rem(p_contract_id);
   x_fnd_rec.TOTAL_SUPPLIER_RETENTION := OKL_FUNDING_PVT.get_total_retention(p_contract_id);
   x_fnd_rec.TOTAL_BORROWER_PAYMENTS := OKL_FUNDING_PVT.get_amount_borrowerPay(p_contract_id);
   x_fnd_rec.TOTAL_SUBSIDIES_FUNDED := OKL_FUNDING_PVT.get_amount_subsidy(p_contract_id);
   x_fnd_rec.TOTAL_MANUAL_DISBURSEMENT := OKL_FUNDING_PVT.get_amount_manu_disb(p_contract_id);



    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END get_fund_summary;

/*
-- zrehman, 10/13/2006
-- END, PROCEDURE to get Funding Summary
*/


END OKL_FUNDING_PVT;

/
