--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_PVT" AS
/* $Header: OKLCKHRB.pls 120.45.12010000.8 2009/12/17 13:36:40 smadhava ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
  -- GLOBAL VARIABLES
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
--avsingh added for k line deletion checks
  G_OKL_BOOKED_STS_CODE      CONSTANT VARCHAR2(30) := 'BOOKED';
  G_OKL_CANCELLED_STS_CODE   CONSTANT VARCHAR2(30) := 'ABANDONED';



  G_PARENT_TABLE_TOKEN  CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN        CONSTANT        VARCHAR2(200)  := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT        VARCHAR2(200)  := 'SQLcode';
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
--------------------------------------------------------------------------------
--GLOBAL Message constants added for okl line delete checks
--------------------------------------------------------------------------------
  G_BOOKED_KLE_DELETE         CONSTANT VARCHAR2(200) := 'OKL_LLA_BOOKED_KLE_DELETE';
  G_PAST_BOOKED_KLE_DELETE    CONSTANT VARCHAR2(200) := 'OKL_LLA_P_BOOKED_KLE_DELETE';
  G_FUNDED_KLE_DELETE         CONSTANT VARCHAR2(200) := 'OKL_LLA_FUNDED_KLE_DELETE';
--------------------------------------------------------------------------------
--Global Message Constants for Term Reduction
--------------------------------------------------------------------------------
G_TERM_REDUCTION_NOT_ALLOWED  CONSTANT VARCHAR2(200) := 'OKL_LLA_TERM_REDUCTION';
G_PRODUCT_EFFECTIVITY         CONSTANT VARCHAR2(200) := 'OKL_LLA_PDT_EFFECTIVITY';
--Bug # 2691056
G_RBK_NEW_START_DATE          CONSTANT VARCHAR2(200) := 'OKL_LLA_RBK_START_DATE';
G_RBK_DATE_LESS               CONSTANT VARCHAR2(200) := 'OKL_LLA_REBOOK_DATE_LESS';
G_EFFECTIVE_FROM_TOKEN        CONSTANT VARCHAR2(200) := 'EFFECTIVE_FROM';
G_REBOOK_DATE_TOKEN           CONSTANT VARCHAR2(200) := 'REBOOK_DATE';
--------------------------------------------------------------------------------
--Global Message Constant for Template creation not allowed
--------------------------------------------------------------------------------
G_TEMPLATE_CREATE_NOT_ALLOWED CONSTANT VARCHAR2(200) := 'OKL_LLA_TEMPLATE_CREATE';
--------------------------------------------------------------------------------
--Global Message constants for 11.5.9 - Multi currency Validation
--------------------------------------------------------------------------------
G_CONV_RATE_NOT_FOUND     CONSTANT VARCHAR2(200)  := 'OKL_LLA_CONV_RATE_NOT_FOUND';
G_FROM_CURRENCY_TOKEN     CONSTANT VARCHAR2(200)  := 'FROM_CURRENCY';
G_TO_CURRENCY_TOKEN       CONSTANT VARCHAR2(200)  := 'TO_CURRENCY';
G_CONV_TYPE_TOKEN         CONSTANT VARCHAR2(200)  := 'CONVERSION_TYPE';
G_CONV_DATE_TOKEN         CONSTANT VARCHAR2(200)  := 'CONVERSION_DATE';
G_REBOOK_CURRENCY_MODFN   CONSTANT VARCHAR2(200)  := 'OKL_LLA_REBOOK_CURR_MODFN';
G_REBOOK_PRODUCT_MODFN    CONSTANT VARCHAR2(200)  := 'OKL_LLA_REBOOK_PROD_MODFN';
--------------------------------------------------------------------------------
--Global Message constants for 11.5.9 - Product Validation
--------------------------------------------------------------------------------
G_PROD_PARAMS_NOT_FOUND   CONSTANT VARCHAR2(200)  := 'OKL_LLA_PDT_PARAM_NOT_FOUND';
G_PROD_MISSING_PARAM      CONSTANT VARCHAR2(200)  := 'OKL_LLA_MISSING_PDT_PARAM';
G_PROD_NAME_TOKEN         CONSTANT VARCHAR2(200)  := 'PRODUCT_NAME';
G_PROD_PARAM_TOKEN        CONSTANT VARCHAR2(200)  := 'PARAMETER_NAME';
G_PROD_SUBCALSS_MISMATCH  CONSTANT VARCHAR2(200)  := 'OKL_LLA_PDT_SUBCLASS_MISMATCH';
G_PROD_SUBCALSS_TOKEN     CONSTANT VARCHAR2(200)  := 'PRODUCT_SUBCLASS';
G_CONTRACT_SUBCLASS_TOKEN CONSTANT VARCHAR2(200)  := 'CONTRACT_SUBCLASS';

  G_DELETE_CONT_ERROR CONSTANT VARCHAR2(30) := 'OKL_LLA_DELETE_CONT_ERROR';
  G_DELETE_CONT_RBK_ERROR CONSTANT VARCHAR2(30) := 'OKL_LLA_DELETE_CONT_RBK_ERROR';
  G_DELETE_CONT_FUND_ERROR CONSTANT VARCHAR2(30) := 'OKL_LLA_DELETE_CONT_FUND_ERROR';
  G_DELETE_CONT_RCPT_ERROR CONSTANT VARCHAR2(30) := 'OKL_LLA_DELETE_CONT_RCPT_ERROR';

  G_EXCEPTION_HALT_VALIDATION exception;

  NO_CONTRACT_FOUND exception;

  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKL_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;

  G_API_TYPE            CONSTANT VARCHAR2(4) := '_PVT';

/*
-- vthiruva, 08/19/2004
-- Added Constants to enable Business Event
*/
G_WF_EVT_CR_LMT_CREATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.credit_limit.created';
G_WF_EVT_CR_LMT_UPDATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.credit_limit.updated';
G_WF_EVT_CR_LMT_REMOVED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.credit_limit.remove';
G_WF_EVT_ASSET_CREATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.asset_created';
G_WF_EVT_ASSET_UPDATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.asset_updated';
G_WF_EVT_ASSET_REMOVED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.remove_asset';
G_WF_EVT_SERVICE_CREATED CONSTANT VARCHAR2(60) := 'oracle.apps.okl.la.lease_contract.service_fee_created';
G_WF_EVT_SERVICE_UPDATED CONSTANT VARCHAR2(60) := 'oracle.apps.okl.la.lease_contract.service_fee_updated';
G_WF_ITM_CR_LINE_ID CONSTANT VARCHAR2(30) := 'CREDIT_LINE_ID';
G_WF_ITM_CR_LMT_ID CONSTANT VARCHAR2(30) := 'CREDIT_LIMIT_ID';
G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(30) := 'CONTRACT_ID';
G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(30) := 'ASSET_ID';
G_WF_ITM_SRV_LINE_ID CONSTANT VARCHAR2(30) := 'SERVICE_LINE_ID';
G_WF_ITM_SERVICE_KHR_ID CONSTANT VARCHAR2(30) := 'SERVICE_CONTRACT_ID';
G_WF_ITM_SERVICE_CLE_ID CONSTANT VARCHAR2(30) := 'SERVICE_CONTRACT_LINE_ID';
G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)   := 'CONTRACT_PROCESS';
--create_fee and update_fee events are raised from here rather than okl_maintain_fee_pvt
--as contract import process and split contract do not call okl_maintain_fee_pvt,
--but directly call okl_contract_pvt
G_WF_EVT_FEE_CREATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.fee_created';
G_WF_EVT_FEE_UPDATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.fee_updated';
G_WF_ITM_FEE_LINE_ID CONSTANT VARCHAR2(30) := 'FEE_LINE_ID';

/*
-- vthiruva, 08/19/2004
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
                p_event_name        IN wf_events.name%TYPE,
                p_parameter_list    IN wf_parameter_list_t) IS

l_chr_id              okc_k_headers_b.id%TYPE;
l_contract_process    VARCHAR2(30);
l_parameter_list      WF_PARAMETER_LIST_T := p_parameter_list;

BEGIN
  -- check to see if the the contract_id is not null, this is required since
  -- credit limit events do not necessarily pass a contract
  l_chr_id := wf_event.GetValueForParameter(G_WF_ITM_CONTRACT_ID,p_parameter_list);
  IF(l_chr_id IS NOT NULL)THEN
    -- if there exists a contract in context, then derive the contract process status
    l_contract_process := okl_lla_util_pvt.get_contract_process(l_chr_id);
    IF(l_contract_process IS NOT NULL)THEN
       -- add the contract process status to the parameter list only the value is not null
       wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_contract_process,l_parameter_list);
    END IF;
  END IF;
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
-- vthiruva, 08/19/2004
-- END, PROCEDURE to enable Business Event
*/

--Bug#2937980
-- Start of comments
--
-- Procedure Name  : Inactivate_streams
-- Description     : local_procedures inactivates line level streams for logically
--                   deleted lines
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
-- Start of comments
--
Procedure Inactivate_Streams
          ( p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_cle_id          IN NUMBER) is

--Cursor to fetch active streams against line
Cursor strms_csr (cleId IN Number) is
Select str.id strm_id,
       str.kle_id,
       str.sty_id,
       str.sgn_code
from   OKL_STREAMS str
where  str.say_code = 'CURR'
and    str.kle_id   = cleId;

l_strms_rec     strms_csr%ROWTYPE;
l_return_status VARCHAR2(1);
i               NUMBER;
l_stmv_tbl      okl_streams_pub.stmv_tbl_type;
x_stmv_tbl      okl_streams_pub.stmv_tbl_type;
l_stream_update_err EXCEPTION;

Begin
-----
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    i := 0;
    Open strms_csr(cleId => p_cle_id);
    Loop
        Fetch strms_csr into l_strms_rec;
        Exit when strms_csr%NOTFOUND;
        i := i+1;
        l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
        l_stmv_tbl(i).say_code := 'HIST';
        l_stmv_tbl(i).active_yn := 'N';
        l_stmv_tbl(i).date_history := sysdate;
    End Loop;
    Close strms_csr;
    If (l_stmv_tbl.COUNT > 0) then
        Okl_Streams_pub.update_streams(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_stmv_tbl      => l_stmv_tbl,
                         x_stmv_tbl      => x_stmv_tbl);
         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
             raise l_stream_update_err;
         END IF;
         l_stmv_tbl.delete;
     End If;
     EXCEPTION
     When l_stream_update_err then
         If (l_stmv_tbl.COUNT > 0) then
             l_stmv_tbl.delete;
         End If;
     When OTHERS then
         If (l_stmv_tbl.COUNT > 0) then
             l_stmv_tbl.delete;
         End If;
         If strms_csr%ISOPEN then
             close strms_csr;
         End If;
End Inactivate_Streams;
--Bug#2937980 end

-- Procedure Name  : kle_delete_allowed
-- Description     : local procvalidates if it is OK to delete the okl contract line
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE kle_delete_allowed(p_cle_id          IN NUMBER,
                             x_deletion_type   OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2) IS


    --Cursor to check if the contract is booked
    Cursor Chr_sts_crs(p_cle_id IN Number) IS
    SELECT chr.sts_code
    FROM   okc_k_headers_b chr,
           okc_k_lines_b   cle
    WHERE  chr.ID = cle.dnz_chr_id
    AND    cle.ID = p_cle_id;

    l_sts_code    OKC_K_HEADERS_B.STS_CODE%TYPE;

    --Cursor to check if the contract was ever booked
    Cursor Ever_Booked_crs(p_cle_id IN Number) is
    SELECT 'Y'
    FROM   okc_k_headers_bh chrh,
           okc_k_headers_b chr,
           okc_k_lines_b cle
    WHERE  chrh.contract_number = chr.contract_number
    AND    chr.ID = cle.dnz_chr_id
    AND    chrh.sts_code = G_OKL_BOOKED_STS_CODE
    AND    cle.ID = p_cle_id
    AND    rownum < 2;

    l_chr_ever_booked Varchar2(1) default 'N';

    --Cursor to check whether funding exists
    Cursor Funding_Exists_crs(p_cle_id IN NUMBER) is
    SELECT 'Y'
    FROM   OKL_TXL_AP_INV_LNS_B fln
    WHERE  fln.kle_id = p_cle_id
    And rownum < 2;

    l_funding_exists Varchar2(1) default 'N';

    --Cursor to check whether streams exist
    Cursor streams_exist_crs(p_cle_id IN NUMBER) is
    SELECT 'Y'
    FROM   OKL_STREAMS str
    WHERE  str.kle_id = p_cle_id
    And rownum < 2;

    l_streams_exists Varchar2(1) default 'N';
    l_deletion_type Varchar2(1) default 'P'; --P : physical delete
                                             --L : logical delete
                                             --N : Not allowed

    --------------
    --Bug# 4091789
    --------------
    --cursor to check that line is financila asset line and
    --contract is a rebook copy contract
    Cursor l_rbk_asst_csr(p_cle_id IN NUMBER) is
    Select 'Y' rbk_asst_flag,
           clet.NAME
    from   okc_k_lines_tl clet,
           okc_k_lines_b  cleb,
           okc_line_styles_b lseb,
           okc_k_headers_b chrb
    where  chrb.id                      =   cleb.dnz_chr_id
    and    chrb.scs_code                =   'LEASE'
    and    chrb.orig_system_source_code =   'OKL_REBOOK'
    and    clet.id                      =   cleb.id
    and    clet.language                =   userenv('LANG')
    and    lseb.id                      =   cleb.lse_id
    and    lseb.lty_code                =   'FREE_FORM1'
    and    cleb.id                      =   p_cle_id
    and    cleb.orig_system_id1 is not NULL
    and    exists (select '1'
                   from    okc_k_headers_b orig_chrb,
                           okc_k_lines_b   orig_cleb
                   where   orig_chrb.id          = chrb.orig_system_id1
                   and     orig_cleb.id          = cleb.orig_system_id1
                   --Bug# 4375800 :
                   and     orig_cleb.sts_code    <> 'ABANDONED'
                   and     orig_cleb.dnz_chr_id  = orig_chrb.id);

    l_rbk_asst_rec l_rbk_asst_csr%ROWTYPE;
    -------------
    --Bug# 4091789 End
    -------------

Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     --check if contract is booked
     Open  Chr_sts_crs(p_cle_id => p_cle_id);
         Fetch Chr_sts_crs into l_sts_code;
     Close Chr_sts_crs;
     If l_sts_code = G_OKL_BOOKED_STS_CODE Then
         OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                             p_msg_name => G_BOOKED_KLE_DELETE);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         l_deletion_type := 'N';
         Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

     --check if contract was ever booked
     l_chr_ever_booked := 'N';
     Open  Ever_Booked_crs(p_cle_id => p_cle_id);
         Fetch Ever_Booked_crs into l_chr_ever_booked;
         If Ever_Booked_crs%NOTFOUND Then
             Null;
         End If;
     Close Ever_Booked_crs;

     If l_chr_ever_booked = 'Y' Then
         OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => G_PAST_BOOKED_KLE_DELETE);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         l_deletion_type := 'N';
         Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

     --check whether funding exists
     l_funding_exists := 'N';
     Open  Funding_Exists_crs(p_cle_id => p_cle_id);
         Fetch Funding_Exists_crs into l_funding_exists;
              If Funding_Exists_crs%NOTFOUND Then
             Null;
         End If;
     Close Funding_Exists_crs;

     If l_funding_exists = 'Y' Then
         OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                             p_msg_name => G_FUNDED_KLE_DELETE);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         l_deletion_type := 'N';
         Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

     -------------
     --Bug# 4091789
     -------------
     --check if user is trying to delete a financial asset line on a lease rebook copy
     l_rbk_asst_rec := Null;
     for l_rbk_asst_rec in l_rbk_asst_csr(p_cle_id => p_cle_id)
     loop
         If NVL(l_rbk_asst_rec.rbk_asst_flag,'N') = 'Y' then
             OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKL_LA_REBOOK_LINE_DELETE',
                                 p_token1        => 'ASSET_NUMBER',
                                 p_token1_value  => l_rbk_asst_rec.name);
             x_return_status := OKL_API.G_RET_STS_ERROR;
             l_deletion_type := 'N';
             Raise G_EXCEPTION_HALT_VALIDATION;
          End If;
      End Loop;
      -------------
      --Bug# 4091789 End
      -------------


     --check if streams exist for the line
     l_streams_exists := 'N';
     Open  streams_exist_crs(p_cle_id => p_cle_id);
         Fetch streams_exist_crs into l_streams_exists;
              If streams_exist_crs%NOTFOUND Then
             Null;
         End If;
     Close streams_exist_crs;

     If l_streams_exists = 'Y' Then
         l_deletion_type := 'L';
     End If;
     x_deletion_type := l_deletion_type;

     Exception

         when G_EXCEPTION_HALT_VALIDATION then
         -- no processing necessary; validation can continue with the next column
         x_deletion_type := l_deletion_type;
         when OTHERS then
         -- store SQL error message on message stack for caller
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                    p_msg_name => G_UNEXPECTED_ERROR,
                                    p_token1   => g_sqlcode_token,
                                    p_token1_value => sqlcode,
                                    p_token2         => g_sqlerrm_token,
                                    p_token2_value => sqlerrm);

          -- notify caller of an error
      If Chr_sts_crs%ISOPEN Then
         Close Chr_sts_crs;
      End If;
      If Ever_Booked_crs%ISOPEN Then
         Close Ever_Booked_crs;
      End If;
      If Funding_Exists_crs%ISOPEN Then
         Close Funding_Exists_crs;
      End If;
      If streams_exist_crs%ISOPEN Then
         Close streams_exist_crs;
      End If;
      x_deletion_type := 'N';
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END kle_delete_allowed;

-- Start of comments
--
-- Procedure Name  : term_modfn
-- Description     : local proc checks if term modfn allowed on a lease chr hdr
--                   and cascades term modification to lines
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

Procedure term_modfn( p_api_version    IN NUMBER,
                      p_init_msg_list  IN VARCHAR2,
                      x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_count      OUT NOCOPY NUMBER,
                      x_msg_data       OUT NOCOPY VARCHAR2,
                      p_chr_id          IN   NUMBER,
                      p_new_start_date  IN   Date,
                      p_new_end_date    IN   Date,
                      p_new_term        IN   Number,
                      p_new_pdt_id          IN   NUMBER, -- Bug#9115610 - pass new product id if product has changed in UI and not yet stored in DB
                      x_modfn_mode     OUT NOCOPY VARCHAR2) IS

--Cursor to check if it is lease contract chr
   Cursor  chk_lease_csr(p_chr_id IN NUMBER) is
   SELECT  chr.sts_code,
           chr.scs_code,
           khr.term_duration,
           chr.start_date,
           chr.end_date
   From    okl_k_headers khr,
           okc_k_headers_b chr
   Where   khr.id = chr.id
   And     chr.id = p_chr_id;

   l_sts_code      okc_k_headers_b.sts_code%TYPE;
   l_scs_code      okc_k_headers_b.scs_code%TYPE;
   l_term_duration okl_k_headers.term_duration%TYPE;
   l_start_date    okc_k_headers_b.start_date%TYPE;
   l_end_date      okc_k_headers_b.end_date%TYPE;


--Cursor to check if the contract was ever booked
    Cursor Ever_Booked_csr(p_chr_id IN Number) is
    SELECT 'Y'
    FROM   okc_k_headers_bh chrh,
           okc_k_headers_b chr
    WHERE  chrh.contract_number = chr.contract_number
    AND    chr.ID = p_chr_id
    AND    chrh.sts_code = G_OKL_BOOKED_STS_CODE
    AND    rownum < 2;

    l_ever_booked Varchar2(1) default 'N';

--Cursor to check if the contract is a rebook copy
   Cursor Rbk_Cpy_Csr(p_chr_id IN Number) is
   Select 'Y'
   From   okc_k_headers_b chr
   where  chr.orig_system_source_code = 'OKL_REBOOK'
   and    chr.id = p_chr_id;

   l_rbk_cpy  Varchar2(1) default 'N';

   l_modfn_mode Varchar2(1); --'R' restrict reduction in term
                             --'N' Normal
                             --'L' Copy start and end dates on to lines
                             --'P' Violates product effictivity dates

   l_clev_rec   okl_okc_migration_pvt.clev_rec_type;
   lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;

--Cursor to find out the product from_date and to_date
  Cursor pdt_dts_csr(p_chr_id IN NUMBER) IS
  Select pdt.from_date,
         pdt.to_date
  From   okl_products  pdt,
         okl_k_headers khr
  where  pdt.id = khr.pdt_id
  and    khr.id = p_chr_id;

  -- Bug# 9115610 - Added cursor to get product effective dates
  CURSOR c_pdt_dts_csr(p_pdt_id IN NUMBER) IS
    SELECT pdt.from_date,
         pdt.to_date
    From   okl_products  pdt
    WHERE pdt.id = p_pdt_id;

  l_pdt_to_date      okl_products.to_date%TYPE;
  l_pdt_from_date    okl_products.from_date%TYPE;

  l_new_start_date   date;
  l_new_end_date     date;

--Bug# 2691029 : Cursor to find out Rebook date
  Cursor rbk_date_csr (rbk_chr_id IN NUMBER) is
  SELECT DATE_TRANSACTION_OCCURRED
  FROM   okl_trx_contracts ktrx
  WHERE  ktrx.KHR_ID_NEW = rbk_chr_id
  AND    ktrx.tsu_code   = 'ENTERED'
  --AND    ktrx.rbr_code IS NOT NULL
  AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP Project
  AND    ktrx.representation_type = 'PRIMARY';
--

  l_rbk_date okl_trx_contracts.DATE_TRANSACTION_OCCURRED%TYPE;

--Bug# 2691029: Cursor to find out the original start date of contract being rebooked
  Cursor orig_date_csr(rbk_chr_id IN NUMBER) is
  Select orig.start_date,
         orig.end_date,
         orig_k.term_duration
  from   okl_k_headers orig_k,
         okc_k_headers_b orig,
         okc_k_headers_b rbk
  where  orig_k.id = orig.id
  and    orig.id   = rbk.orig_system_id1
  and    rbk.id    = rbk_chr_id;

  l_orig_start_date    okc_k_headers_b.start_date%TYPE;
  l_orig_end_date      okc_k_headers_b.end_date%TYPE;
  l_orig_term_duration okl_k_headers.term_duration%TYPE;


Begin

  x_return_status  := OKL_API.G_RET_STS_SUCCESS;
  l_modfn_mode     := 'N';
  l_new_start_date := p_new_start_date;
  l_new_end_date   := p_new_end_date;

  Open  chk_lease_csr(p_chr_id => p_chr_id);
  Fetch chk_lease_csr Into l_sts_code,
                           l_scs_code,
                           l_term_duration,
                           l_start_date,
                           l_end_date;
  If chk_lease_csr%NOTFOUND Then
     Raise G_EXCEPTION_HALT_VALIDATION;
  End If;
  Close chk_lease_csr;

  If l_new_start_date is null or l_new_start_date = OKL_API.G_MISS_DATE Then
     l_new_start_date := l_start_date;
  End If;

  If l_new_end_date is null or l_new_end_date = OKL_API.G_MISS_DATE Then
     l_new_end_date := l_end_date;
  End If;


  If l_scs_code = 'LEASE' Then
      --Bug#2691029 if there is no change in dates then there is no term modification
      If l_new_start_date = l_start_date and
         l_new_end_date   = l_end_date Then
         l_modfn_mode := 'N';
      Else
          l_modfn_mode := 'L';
          --if contract booked do not allow term changes--(this will be taken care of by the UI as
          -- user get to see view only pages only)

          --if contract is a Rebook Copy OR Contract is ever booked
          --do not allow reduction in term (allow change in start date only)

          l_ever_booked := 'N';
          Open Ever_Booked_csr(p_chr_id => p_chr_id);
              Fetch Ever_Booked_csr into l_ever_booked;
              If Ever_Booked_csr%NOTFOUND Then
                  Null;
              End If;
          Close Ever_Booked_csr;

          If l_ever_booked = 'Y' Then
              l_modfn_mode := 'R';
          End If;

          l_rbk_cpy := 'N';
          --if lines exist for contract change start_end dates on lines
          Open Rbk_Cpy_Csr(p_chr_id => p_chr_id);
              Fetch Rbk_Cpy_Csr into l_rbk_cpy;
              If Rbk_Cpy_Csr%NOTFOUND Then
                  Null;
              End If;
          Close Rbk_Cpy_Csr;

          If l_rbk_cpy = 'Y' Then
              l_modfn_mode := 'R';
          End If;

          --if not restricted then check if the change will satisfy pdt start end dates
          If l_modfn_mode <> 'R' Then

            IF (p_new_pdt_id = OKL_API.G_MISS_NUM OR p_new_pdt_id IS NULL) THEN -- Bug# 9115610 - Added new condition
              Open pdt_dts_csr(p_chr_id => p_chr_id);
                  Fetch pdt_dts_csr into l_pdt_from_date,
                                         l_pdt_to_date;
                  If pdt_dts_csr%NOTFOUND Then
                      Null;
                  End If;
              Close pdt_dts_csr;
			ELSE -- Bug# 9115610 - Start
              Open c_pdt_dts_csr(p_new_pdt_id);
                  Fetch c_pdt_dts_csr into l_pdt_from_date,
                                         l_pdt_to_date;
                  If c_pdt_dts_csr%NOTFOUND Then
                      Null;
                  End If;
              Close c_pdt_dts_csr;
			END IF; -- Bug# 9115610 - End
              If trunc(l_new_start_date) not between trunc(nvl(l_pdt_from_date,l_new_start_date))
                                             and trunc(nvl(l_pdt_to_date,l_new_start_date)) Then
                  l_modfn_mode := 'P';
              End If;
          End If;
      End If;
  Elsif l_scs_code = 'QUOTE' then

     l_modfn_mode := 'L';
     Open pdt_dts_csr(p_chr_id => p_chr_id);
         Fetch pdt_dts_csr into l_pdt_from_date,
                                l_pdt_to_date;
         If pdt_dts_csr%NOTFOUND Then
             Null;
         End If;
     Close pdt_dts_csr;
     If trunc(l_new_start_date) not between trunc(nvl(l_pdt_from_date,l_new_start_date))
               and trunc(nvl(l_pdt_to_date,l_new_start_date)) Then
         l_modfn_mode := 'P';
     End If;

  Else
     --do nothing
     l_modfn_mode := 'N';
  End If;


  If (l_modfn_mode = 'R') Then
     --bug# 2821383: For rebook copy contracts end data should be from original contract
     If l_rbk_cpy <> 'Y' then
         If trunc(l_new_end_date) < trunc(l_end_date)
             or (p_new_term  < l_term_duration) Then
              OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                  p_msg_name      => G_TERM_REDUCTION_NOT_ALLOWED
                                              );
             x_return_status := OKL_API.G_RET_STS_ERROR;
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
     End If; --bug # 2821383

     --Bug # 2691029
     If l_rbk_cpy = 'Y' Then
         --start date compare should be with the start_date of the original contract
         Open orig_date_csr(rbk_chr_id => p_chr_id);
         Fetch orig_date_csr into l_orig_start_date,
                                  l_orig_end_date,
                                  l_orig_term_duration;
         If orig_date_csr%NOTFOUND then
             null; --should never hit this
         end if;
         Close orig_date_csr;

         If trunc(l_new_start_date) < trunc(l_orig_start_date) Then
             OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                 p_msg_name      => G_RBK_NEW_START_DATE,
                                 p_token1        => g_effective_from_token,
                                 p_token1_value  => to_char(l_orig_start_date,'DD-MON-YYYY')
                                                 );
             x_return_status := OKL_API.G_RET_STS_ERROR;
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
         --Bug#2821383 :check on term reduction for rbook copy contract should be with original end date
         If trunc(l_new_end_date) < trunc(l_orig_end_date)
             or (p_new_term  < l_orig_term_duration) Then
              OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                  p_msg_name      => G_TERM_REDUCTION_NOT_ALLOWED
                                              );
             x_return_status := OKL_API.G_RET_STS_ERROR;
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If; --Bug# 2821383  End
     End If;

     --Bug # 2691029
     If l_rbk_cpy = 'Y' Then
         Open  rbk_date_csr(p_chr_id);
         Fetch rbk_date_csr into l_rbk_date;
         If  rbk_date_csr%NOTFOUND Then
             null;
             --rebook date will always e there though
         end if;
         Close rbk_date_csr;

         If l_rbk_date < l_new_start_date then
             OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                                 p_msg_name      => G_RBK_DATE_LESS, --new message needed
                                 p_token1        => g_rebook_date_token,
                                 p_token1_value  => to_char(l_rbk_date,'DD-MON-YYYY')
                                                 );
             x_return_status := OKL_API.G_RET_STS_ERROR;
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If;
    End If;

  ElsIF (l_modfn_mode = 'P') Then
      OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name      => G_PRODUCT_EFFECTIVITY
                                          );
      x_return_status := OKL_API.G_RET_STS_ERROR;
      Raise G_EXCEPTION_HALT_VALIDATION;
  End If;

  x_modfn_mode := l_modfn_mode;

  Exception
    when G_EXCEPTION_HALT_VALIDATION then
         -- no processing necessary; validation can continue with the next column
         x_modfn_mode := l_modfn_mode;

         when OTHERS then
         -- store SQL error message on message stack for caller
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                    p_msg_name => G_UNEXPECTED_ERROR,
                                    p_token1   => g_sqlcode_token,
                                    p_token1_value => sqlcode,
                                    p_token2         => g_sqlerrm_token,
                                    p_token2_value => sqlerrm);

          -- notify caller of an error

      If Ever_Booked_csr%ISOPEN Then
         Close Ever_Booked_csr;
      End If;

      If Rbk_Cpy_Csr%ISOPEN Then
         Close Rbk_Cpy_Csr;
      End If;

      IF pdt_dts_csr%ISOPEN Then
          Close pdt_dts_csr;
      End If;

          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_modfn_mode    := 'N';
END term_modfn;

-- Start of comments
--
-- Procedure Name  : template_create_allowed
-- Description     : local proc validates if it is OK to create contract as template
-- Business Rules  : If profile option OKL_ALLOW_K_TEMPLATE_CREATE is 'Y' then
--                   the user is allowed to create contract templates else if it
--                   is 'N' the user is not allowed to create contract templates
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE template_create_allowed(p_chr_id          IN  NUMBER,
                                  p_template_yn     IN  VARCHAR2,
                                  x_return_status   OUT NOCOPY VARCHAR2) IS

   Cursor chk_template_csr (p_chr_id IN NUMBER) is
   Select nvl(template_yn,'N')
   From   okc_k_headers_b
   Where  id = p_chr_id;

   l_template_yn okc_k_headers_b.template_yn%TYPE;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --check if contract template creation is allowed
    IF p_chr_id is not null Then --it is an update
       --get old value of template y/N flag
       Open chk_template_csr(p_chr_id => p_chr_id);
       Fetch chk_template_csr into l_template_yn;
       If chk_template_csr%NOTFOUND Then
          l_template_yn := 'N';
       End If;
       Close chk_template_csr;
   Elsif p_chr_id is null Then
       l_template_yn := 'N';
   End If;

  --If p_template_yn is null OR p_template_yn = OKL_API.G_MISS_CHAR Then
  --   l_template_yn := p_template_yn;
  --End If;

  IF p_template_yn is Null OR p_template_yn = OKL_API.G_MISS_CHAR Then
      Null;
  Else
      IF p_template_yn  <> l_template_yn then
          IF FND_PROFILE.VALUE('OKL_ALLOW_K_TEMPLATE_CREATE') = 'Y' Then
             Null;
          ElsIf FND_PROFILE.VALUE('OKL_ALLOW_K_TEMPLATE_CREATE') = 'N' Then
             x_return_status := OKL_API.G_RET_STS_ERROR;
          End If;
      End If;
  END IF;

  EXCEPTION
    when OTHERS then
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END template_create_allowed;

-- Start of comments
--  Bug # 2522268
-- Procedure Name  : Asset_Logical_Delete
-- Description     : Generates Asset Number for logically deleted asset ('ABANDONED')
--                   and updates the original number with deleted asset number
--                   so that the original asset number could be re-used
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE Asset_Logical_Delete( p_api_version     IN NUMBER,
                                p_init_msg_list   IN VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2,
                                x_msg_count       OUT NOCOPY NUMBER,
                                x_msg_data        OUT NOCOPY VARCHAR2,
                                p_cle_id          IN NUMBER,
                                p_asset_number    IN VARCHAR2) IS

    --cursor to get new asset number
    Cursor c_asset_no IS
    select 'DUMMY'||TO_CHAR(OKL_FAN_SEQ.NEXTVAL)
    FROM dual;

    l_asset_no OKX_ASSETS_V.ASSET_NUMBER%TYPE;

    --Cursors to find if asset number exists
    CURSOR c_txl_asset_number(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_V
                  WHERE asset_number = p_asset_number);

    CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    --start modified abhsaxen for performance SQLID 20562304
      select 'Y'
      from   okc_k_lines_b kleb,
             okc_k_lines_tl kle,
             okc_line_styles_b  lse
      where  kle.name = p_asset_number
      and    kle.id = kleb.id
      and    kle.language = USERENV('LANG')
      and    kleb.lse_id = lse.id
      and    lse.lty_code = 'FREE_FORM1';
    --start modified abhsaxen for performance SQLID 20562304

    CURSOR c_okx_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSETS_V
                  WHERE asset_number = p_asset_number);

    CURSOR c_txd_assets_v (p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXD_ASSETS_V
                  WHERE asset_number = p_asset_number);


    l_asset_exists Varchar2(1) default 'N';

    --cursor to check if line is financial asset top line
    CURSOR l_is_finasst (p_line_id OKC_K_LINES_B.ID%TYPE) IS
    Select 'Y'
    From   Dual
    Where exists (select '1'
                  from   okc_k_lines_b cle,
                         okc_line_styles_b  lse
                  where  cle.lse_id = lse.id
                  and    lse.lty_code = 'FREE_FORM1'
                  and    cle.id       = p_line_id);

    l_fin_asst Varchar2(1) default 'N';
    l_cle_id Number;

    l_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lx_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;

    --Cursor to check asset number on txl
    CURSOR l_txlv_csr (p_finasst_id IN NUMBER, P_Asstno IN VARCHAR2) is
    Select txlv.id,
           txlv.asset_number
    From   OKL_TXL_ASSETS_V  txlv,
           OKC_K_LINES_B     cle,
           OKC_LINE_STYLES_B lse
    Where  txlv.kle_id    = cle.id
    And    cle.lse_id     = lse.id
    And    lse.lty_code   = 'FIXED_ASSET'
    And    cle.cle_id     = p_finasst_id
    And    txlv.asset_number = p_asstNo;

    l_txl_id              OKL_TXL_ASSETS_V.ID%TYPE;
    l_txl_asset_number    OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE;

    --Cursor to check asset number on txd
    CURSOR l_txdv_csr (p_finasst_id IN NUMBER, p_asstno IN VARCHAR2) is
    Select txdv.id,
           txdv.asset_number
    From   OKL_TXD_ASSETS_V  txdv,
           OKL_TXL_ASSETS_V  txlv,
           OKC_K_LINES_B     cle,
           OKC_LINE_STYLES_B lse
    Where  txdv.tal_id    = txlv.id
    And    txlv.kle_id    = cle.id
    And    cle.lse_id     = lse.id
    And    lse.lty_code   = 'FIXED_ASSET'
    And    cle.cle_id     = p_finasst_id
    And    txdv.asset_number = p_asstno;

    l_txd_id              OKL_TXD_ASSETS_V.ID%TYPE;
    l_txd_asset_number    OKL_TXD_ASSETS_V.ASSET_NUMBER%TYPE;

    l_tlpv_rec             OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    lx_tlpv_rec            OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    l_adpv_rec             OKL_TXD_ASSETS_PUB.adpv_rec_type;
    lx_adpv_rec            OKL_TXD_ASSETS_PUB.adpv_rec_type;


Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cle_id := p_cle_id;
    --dbms_output.put_line('outside Asset_Logical_Delete:'||to_char(l_cle_id));
    l_fin_asst := 'N';
    --find out if p_cle_id is financial asset line
    Open l_is_finasst(l_cle_id);
    Fetch l_is_finasst into l_fin_asst;
    If l_is_finasst%NOTFOUND Then
       Null;
    End If;
    Close l_is_finasst;

    If l_fin_asst = 'Y' Then
        --dbms_output.put_line('inside Asset_Logical_Delete:'||to_char(l_cle_id));
        --get deleted asset number
        l_asset_no := null;
        Open c_asset_no;
        Loop
            Fetch c_asset_no into l_asset_no;
            --chk if asset already exists
            l_asset_exists := 'N';
            open c_txl_asset_number(l_asset_no);
            Fetch c_txl_asset_number into l_asset_exists;
            If c_txl_asset_number%NOTFOUND Then
                open  c_okx_asset_lines_v(l_asset_no);
                Fetch c_okx_asset_lines_v into l_asset_exists;
                If c_okx_asset_lines_v%NOTFOUND Then
                    open c_okx_assets_v(l_asset_no);
                    Fetch c_okx_assets_v into l_asset_exists;
                    If c_okx_assets_v%NOTFOUND Then
                        open c_txd_assets_v(l_asset_no);
                        Fetch c_txd_assets_v into l_Asset_exists;
                        If c_txd_assets_v%NOTFOUND Then
                           null;
                        End If;
                        Close c_txd_assets_v;
                    End If;
                    Close c_okx_assets_v;
                End If;
                Close c_okx_asset_lines_v;
             End If;
             Close c_txl_asset_number;
             If l_asset_exists = 'N' Then
                 Exit;
             End If;
         End Loop;

         --dbms_output.put_line(l_asset_no);
         --update asset number on top line
         l_clev_rec.id   := l_cle_id;
         l_clev_rec.name := l_asset_no;
         okl_okc_migration_pvt.update_contract_line(
             p_api_version       => p_api_version,
             p_init_msg_list     => p_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_restricted_update => OKC_API.G_FALSE,
             p_clev_rec          => l_clev_rec,
             x_clev_rec          => lx_clev_rec);

        If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
            RAISE G_EXCEPTION_HALT_PROCESS;
        End If;

        --update asset number on txl
        OPEN l_txlv_csr(l_cle_id, p_asset_number);
        Loop
            Fetch l_txlv_csr into l_txl_id, l_txl_asset_number;
            Exit When l_txlv_csr%NOTFOUND;
            IF l_txl_asset_number is not null then
                 l_tlpv_rec.id := l_txl_id;
                 l_tlpv_rec.asset_number := l_asset_no;
                 okl_txl_assets_pub.update_txl_asset_Def(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_tlpv_rec      => l_tlpv_rec,
                                         x_tlpv_rec      => lx_tlpv_rec);
                 --dbms_output.put_line('after updating txl assets for asset number');
                 If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                     RAISE G_EXCEPTION_HALT_PROCESS;
                 End If;
             End IF;
        End Loop;
        CLOSE l_txlv_csr;

        --update asset number on txd
        OPEN l_txdv_csr(l_cle_id,p_asset_number);
        LOOP
            Fetch l_txdv_csr into l_txd_id, l_txd_asset_number;
            Exit When l_txdv_csr%NOTFOUND;
            IF l_txd_asset_number is not null then
                 l_adpv_rec.id := l_txd_id;
                 l_adpv_rec.asset_number := l_asset_no;

                 okl_txd_assets_pub.update_txd_asset_Def(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_adpv_rec      => l_adpv_rec,
                                         x_adpv_rec      => lx_adpv_rec);

                 If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                     RAISE G_EXCEPTION_HALT_PROCESS;
                 End If;

             End IF;
        End Loop;
        CLOSE l_txlv_csr;
    END IF;
    EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESS Then
         --just return back the return status with message stack;
         Null;
         If l_txdv_csr%ISOPEN Then
             CLOSE l_txdv_csr;
         End If;
         If l_txlv_csr%ISOPEN Then
             CLOSE l_txlv_csr;
         End If;
         If l_is_finasst%ISOPEN Then
             CLOSE l_is_finasst;
         End If;
         If c_txd_assets_v%ISOPEN Then
             CLOSE c_txd_assets_v;
         End If;
         If c_okx_assets_v%ISOPEN Then
             CLOSE c_okx_assets_v;
         End If;
         If c_okx_asset_lines_v%ISOPEN Then
             CLOSE c_okx_asset_lines_v;
         End If;
         If c_txl_asset_number%ISOPEN Then
             CLOSE c_txl_asset_number;
         End If;
         If c_asset_no%ISOPEN Then
             CLOSE c_asset_no;
         End If;
    WHEN OTHERS Then
         If l_txdv_csr%ISOPEN Then
             CLOSE l_txdv_csr;
         End If;
         If l_txlv_csr%ISOPEN Then
             CLOSE l_txlv_csr;
         End If;
         If l_is_finasst%ISOPEN Then
             CLOSE l_is_finasst;
         End If;
         If c_txd_assets_v%ISOPEN Then
             CLOSE c_txd_assets_v;
         End If;
         If c_okx_assets_v%ISOPEN Then
             CLOSE c_okx_assets_v;
         End If;
         If c_okx_asset_lines_v%ISOPEN Then
             CLOSE c_okx_asset_lines_v;
         End If;
         If c_txl_asset_number%ISOPEN Then
             CLOSE c_txl_asset_number;
         End If;
         If c_asset_no%ISOPEN Then
             CLOSE c_asset_no;
         End If;
         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END Asset_logical_Delete;
 --Bug # 2522268 End

-- Start of comments
-- Bug # 2522268 End
-- Procedure Name  : Linked_Asset_Delete
-- Description     : Local Procedure to delete linked_assets
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
Procedure Linked_Asset_Delete( p_api_version     IN NUMBER,
                               p_init_msg_list   IN VARCHAR2,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2,
                               p_cle_id          IN NUMBER,
                               p_deletion_type  IN VARCHAR2) IS

    --cursor to check if line is financial asset top line
    CURSOR l_is_finasst (p_line_id OKC_K_LINES_B.ID%TYPE) IS
    Select 'Y'
    From   Dual
    Where exists (select '1'
                  from   okc_k_lines_b cle,
                         okc_line_styles_b  lse
                  where  cle.lse_id = lse.id
                  and    lse.lty_code = 'FREE_FORM1'
                  and    cle.id       = p_line_id);

    l_fin_asst Varchar2(1) default 'N';
    l_cle_id Number;

    --cursor to check if financial asset appears as linked asset
    CURSOR l_lnk_ast_csr (p_line_id  OKC_K_LINES_B.ID%TYPE) IS
    Select lnk.id
    From   okc_k_lines_b lnk,
           okc_line_styles_b lnk_lse,
           okc_statuses_b sts,
           okc_k_items    cim
    Where  lnk.id = cim.cle_id
    and    lnk.dnz_chr_id = cim.dnz_chr_id
    and    lnk.lse_id = lnk_lse.id
    and    lnk_lse.lty_code in ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
    and    sts.code = lnk.sts_code
    and    sts.ste_code not in ('EXPIRED','TERMINATED','CANCELLED')
    and    cim.jtot_object1_code = 'OKX_COVASST'
    and    cim.object1_id1 = to_char(p_line_id)
    and    cim.object1_id2 = '#';

    l_lnk_cle_id         OKC_K_LINES_B.ID%TYPE;
    l_clev_rec           OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_clev_rec_out       OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_deletion_type      Varchar2(1);

Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cle_id := p_cle_id;
    l_deletion_type := p_deletion_type;
    --dbms_output.put_line('outside Link_asset_Delete:'||to_char(l_cle_id));
    l_fin_asst := 'N';
    --find out if p_cle_id is financial asset line
    Open l_is_finasst(l_cle_id);
    Fetch l_is_finasst into l_fin_asst;
    If l_is_finasst%NOTFOUND Then
       Null;
    End If;
    Close l_is_finasst;

    If l_fin_asst = 'Y' Then
        --dbms_output.put_line('deletion type '||l_deletion_type);
        OPEN l_lnk_ast_csr(p_line_id => l_cle_id);
        LOOP
            FETCH l_lnk_ast_csr into l_lnk_cle_id;
            EXIT When l_lnk_ast_csr%NOTFOUND;
            If l_deletion_type = 'L' Then
                --do logical deletion of linked asset line
                l_clev_rec.id := l_lnk_cle_id;
                l_clev_rec.sts_code := G_OKL_CANCELLED_STS_CODE;

                okl_okc_migration_pvt.update_contract_line
                     (p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_clev_rec       => l_clev_rec,
                      x_clev_rec       => l_clev_rec_out
                     );
                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   RAISE G_EXCEPTION_HALT_PROCESS;
                End If;

            ElsIf l_deletion_type = 'P' Then
                --do physical deletions
                --dbms_output.put_line('Inside Link_asset_Delete:'||to_char(l_lnk_cle_id));
                OKL_CONTRACT_PVT.delete_contract_line
                     (p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_line_id        => l_lnk_cle_id
                      );

                 If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   RAISE G_EXCEPTION_HALT_PROCESS;
                 End If;
             End If;
        END LOOP;
        CLOSE l_lnk_ast_csr;
    END If;

        EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESS Then
         --just return back the return status with message stack;
         Null;
         If l_is_finasst%ISOPEN Then
             CLOSE l_is_finasst;
         End If;
         If l_lnk_ast_csr%ISOPEN Then
             CLOSE l_lnk_ast_csr;
         End If;
    WHEN OTHERS Then
         If l_is_finasst%ISOPEN Then
             CLOSE l_is_finasst;
         End If;
         If l_lnk_ast_csr%ISOPEN Then
             CLOSE l_lnk_ast_csr;
         End If;
         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END Linked_Asset_Delete;
--------------------------------------------------------------------------------
--Start of comments
-- Bug#2727161   : 11.5.9 Enhancment
-- Procedure     : Is_Rebook_Copy (Local)
-- Description   : Return 'Y' if contract is a rebook copy contract, 'N' if it
--                 is not
--Notes         :
--Prameters     : IN
--                p_chr_id          - contract id
--                Return            - 'Y' if rebook copy
--                                    'N' if not rebook copy
--end of comments
--------------------------------------------------------------------------------
FUNCTION Is_Rebook_Copy (p_chr_id IN NUMBER) return varchar2 IS
   --Cursor to check if the contract is a rebook copy
   Cursor Rbk_Cpy_Csr(p_chr_id IN Number) is
   Select 'Y'
   From   okc_k_headers_b chr
   where  chr.orig_system_source_code = 'OKL_REBOOK'
   and    chr.id = p_chr_id;

   l_rbk_cpy  Varchar2(1) default 'N';
Begin
   l_rbk_cpy := 'N';
   Open Rbk_Cpy_Csr(p_chr_id => p_chr_id);
   Fetch Rbk_Cpy_Csr into l_rbk_cpy;
   If Rbk_Cpy_Csr%NOTFOUND Then
       Null;
   End If;
   Close Rbk_Cpy_Csr;
   Return (l_rbk_cpy);
End Is_Rebook_Copy;
--Bug# : 3143522 - Subsidies . Extra enhancement if line start/end dates are not
--passed they should be initialized
--------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_line_dates
-- Description     : defaults line dates for fee and service line and
--                   sub-lines on a lease contract if no dates are
--                   passed.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--------------------------------------------------------------------------------
Procedure get_line_dates(p_clev_rec      IN okl_okc_migration_pvt.clev_rec_type,
                         x_return_status OUT NOCOPY Varchar2,
                         x_clev_rec      OUT NOCOPY okl_okc_migration_pvt.clev_rec_type) is

    l_return_status      Varchar2(1) default OKL_API.G_RET_STS_SUCCESS;
    --cursor to get contract header dates
    cursor l_chr_csr (p_chr_id in number) is
    select chrb.start_date,
           chrb.end_date,
           chrb.scs_code,
           chrb.currency_code,
           chrb.sts_code
    from   okc_k_headers_b chrb
    where  chrb.id = p_chr_id;

    l_chr_start_date date;
    l_chr_end_date   date;
    l_scs_code       okc_k_headers_b.scs_code%TYPE;
    l_chr_curr_code  okc_k_headers_b.currency_code%TYPE;
    l_chr_sts_code   okc_k_headers_b.sts_code%TYPE;

    --cursor to get parent line dates
    cursor l_cle_csr (p_cle_id in number) is
    select cleb.start_date,
           cleb.end_date,
           cleb.currency_code,
           cleb.sts_code
    from   okc_k_lines_b cleb
    where  cleb.id = p_cle_id;
   l_cle_start_date date;
   l_cle_end_date   date;
   l_cle_curr_code  okc_k_lines_b.currency_code%TYPE;
   l_cle_sts_code   okc_k_lines_b.sts_code%TYPE;

    --cursor to get line style
    cursor l_lse_csr (p_lse_id in number ) is
    select lseb.lty_code,
           lseb.lse_type
    from   okc_line_styles_b lseb
    where  lseb.id = p_lse_id;

    l_lty_code okc_line_styles_b.lty_code%TYPE;
    l_lse_type okc_line_styles_b.lse_type%TYPE;

    l_clev_rec       okl_okc_migration_pvt.clev_rec_type;

    l_rbk_cpy varchar2(1) default 'N';

    --Cursor to find out Rebook date
    Cursor rbk_date_csr (rbk_chr_id IN NUMBER) is
    SELECT DATE_TRANSACTION_OCCURRED
    FROM   okl_trx_contracts ktrx
    WHERE  ktrx.KHR_ID_NEW = rbk_chr_id
    AND    ktrx.tsu_code   = 'ENTERED'
    AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP
    AND    ktrx.representation_type = 'PRIMARY';
--

    l_rbk_date okl_trx_contracts.DATE_TRANSACTION_OCCURRED%TYPE default Null;
begin
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_clev_rec      := p_clev_rec;

    open l_chr_csr(p_chr_id => l_clev_rec.dnz_chr_id);
    fetch l_chr_csr into l_chr_start_date,
                         l_chr_end_date,
                         l_scs_code,
                         l_chr_curr_code,
                         l_chr_sts_code;
    close l_chr_csr;

    --get rebook date if it is a rebook copy contract
    l_rbk_cpy := 'N';
    If l_scs_code = 'LEASE' then
        l_rbk_cpy := Is_rebook_Copy(p_chr_id => l_clev_rec.dnz_chr_id);
    End If;

    If l_rbk_cpy = 'Y' Then
        Open  rbk_date_csr(l_clev_rec.dnz_chr_id);
        Fetch rbk_date_csr into l_rbk_date;
        If  rbk_date_csr%NOTFOUND Then
            null;
            --rebook date will always e there though
        end if;
        Close rbk_date_csr;
    End If;
    --end of get rebook date if it is a rebook copy contract

    If l_scs_code  in ('LEASE','QUOTE') then
        open l_lse_csr(p_lse_id => l_clev_rec.lse_id);
        fetch l_lse_csr into l_lty_code,
                             l_lse_type;
        close l_lse_csr;
        --If l_lty_code in ('SOLD_SERVICE','FEE','USAGE','LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET') then
           if l_lse_type = 'TLS' then

              If nvl(l_clev_rec.start_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
                  If nvl(l_rbk_cpy,'N') = 'Y' AND nvl(l_rbk_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE then
                      l_clev_rec.start_date := l_rbk_date;
                  Else
                      l_clev_rec.start_date := l_chr_start_date;
                  End If;
              End If;
              If nvl(l_clev_rec.end_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
                  l_clev_rec.end_date   := l_chr_end_date;
              End If;
              If nvl(l_clev_rec.currency_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
                  l_clev_rec.currency_code := l_chr_curr_code;
              End If;
              If nvl(l_clev_rec.sts_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
                  l_clev_rec.sts_code := l_chr_sts_code;
              End If;

           elsif l_lse_type = 'SLS' then
               open l_cle_csr (p_cle_id => l_clev_rec.cle_id);
               fetch l_cle_csr into l_cle_start_date,
                                    l_cle_end_date,
                                    l_cle_curr_code,
                                    l_cle_sts_code;
               close l_cle_csr;
               If nvl(l_clev_rec.start_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
                   l_clev_rec.start_date := l_cle_start_date;
               End If;
               If nvl(l_clev_rec.end_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
                   l_clev_rec.end_date   := l_cle_end_date;
               End If;
              If nvl(l_clev_rec.currency_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
                  l_clev_rec.currency_code := l_cle_curr_code;
              End If;
              If nvl(l_clev_rec.sts_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
                  l_clev_rec.sts_code := l_cle_sts_code;
              End If;

           end if;
        --end if;
    end if;
    x_clev_rec      := l_clev_rec;
    x_return_status := l_return_status;
exception
when others then
     if l_chr_csr%ISOPEN then
         close l_chr_csr;
     end if;
     if l_cle_csr%ISOPEN then
         close l_cle_csr;
     end if;
     if l_lse_csr%ISOPEN then
         close l_lse_csr;
     end if;
     if  rbk_date_csr%ISOPEN then
         close rbk_date_csr;
     end if;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
end get_line_dates;
--End Bug# 3143522 - Subsidies - extra enhancement to auto-populate line dates
--------------------------------------------------------------------------------
--Bug# 3124577 : Procedure Create_OKC_CURRENCY_RULE  is removed  for
--               OKC 11.5.10 Rule Migration
--               as there is no need to create the CVN rule . Currency columns
--               been promoted to OKC_K_HEADERS_B
/*--Bug# 3124577 : 11.5.10 Rule Migration -------------------------------------*/
--------------------------------------------------------------------------------
  --Bug # : Multi-Currency Enhancement
  --
  -- PROCEDURE validate_currency (local)
  -- Decription: This procedure validates currency_code during insert and update operation
  -- Logic:
  --       1. If transaction currency is NULL, take functional currency and
  --          make rate, date and type as NULL
  --       2. If transaction currency is NOT NULL and
  --             transaction currency <> functional currency and
  --             type <> 'User' then
  --            get conversion rate from GL and change rate column with new rate
  --       3. If transaction currency is NOT NULL and
  --             transaction currency <> functional currency and
  --             type = 'User' then
  --            take all values as it is
  --       4. If transaction currency = functional currency
  --            make rate, date and type as NULL
  --       5. If Contract currency <> Functional currency then ceate OKC
  --          currency conversion rule
  --
------------------------------------------------------------------------------
  PROCEDURE validate_currency(p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_chrv_rec      IN  okl_okc_migration_pvt.chrv_rec_type,
                              p_khrv_rec      IN  khrv_rec_type,
                              x_chrv_rec      OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
                              x_khrv_rec      OUT NOCOPY khrv_rec_type
                             ) IS

  l_chrv_rec                 okl_okc_migration_pvt.chrv_rec_type;
  l_khrv_rec                 khrv_rec_type;
  l_func_currency            GL_CURRENCIES.CURRENCY_CODE%TYPE;
  currency_validation_failed EXCEPTION;

  --Bug# : 11.5.9 Rebooks - currency can not be modified
  -- cursor to get currency of the original contract
  Cursor ger_orig_curr_csr(p_rbk_chr_id IN NUMBER) is
  Select khr.currency_code,
         khr.currency_conversion_type,
         khr.currency_conversion_date,
         khr.currency_conversion_rate
  from   okl_k_headers_full_v khr,
         okc_k_headers_b rbk_chr
  where  khr.id = rbk_chr.orig_system_id1
  and    rbk_chr.id = p_rbk_chr_id;

  l_orig_curr_code       okl_k_headers_full_v.currency_code%TYPE;
  l_orig_curr_conv_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
  l_orig_curr_conv_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
  l_orig_curr_conv_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
  --Bug# : 11.5.9 Rebooks - currency can not be modified


  l_rbk_cpy Varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_chrv_rec := p_chrv_rec;
    l_khrv_rec := p_khrv_rec;

    --Check if contract is rebook copy
    --if it is and currency code and conv type is being modified raise error
    l_rbk_cpy := Is_Rebook_Copy(p_chr_id => p_chrv_rec.id);
    If l_rbk_cpy = 'Y' Then
        Open ger_orig_curr_csr(p_rbk_chr_id => l_chrv_rec.id);
        Fetch ger_orig_curr_csr into  l_orig_curr_code,
                                      l_orig_curr_conv_type,
                                      l_orig_curr_conv_date,
                                      l_orig_curr_conv_rate;
        If ger_orig_curr_csr%NOTFOUND then
            null;
        Else
            If  l_chrv_rec.currency_code <> l_orig_curr_code OR
                l_khrv_rec.currency_conversion_type <> l_orig_curr_conv_type OR
                l_khrv_rec.currency_conversion_rate <> l_orig_curr_conv_rate Then
                OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                                    p_msg_name  => G_REBOOK_CURRENCY_MODFN);
                x_return_status := OKL_API.G_RET_STS_ERROR;
                raise currency_validation_failed;
            Else
                --do not allow change in currency conversion date
                l_khrv_rec.currency_conversion_date := l_orig_curr_conv_date;
            End If;
        End If;
    End If;

    l_func_currency := okl_accounting_util.get_func_curr_code();

    --dbms_output.put_line('Func Curr: '||l_func_currency);
    --dbms_output.put_line('Trans Curr Code: '|| p_chrv_rec.currency_code);
    --dbms_output.put_line('Trans Curr Rate: '|| p_khrv_rec.currency_conversion_rate);
    --dbms_output.put_line('Trans Curr Date: '|| p_khrv_rec.currency_conversion_date);
    --dbms_output.put_line('Trans Curr Type: '|| p_khrv_rec.currency_conversion_type);

    IF (l_chrv_rec.currency_code IS NULL
       OR
        l_chrv_rec.currency_code = OKL_API.G_MISS_CHAR) THEN -- take functional currency
        l_chrv_rec.currency_code := l_func_currency;
        l_khrv_rec.currency_conversion_type := NULL;
        l_khrv_rec.currency_conversion_rate := NULL;
        l_khrv_rec.currency_conversion_date := NULL;
    ELSE
       IF (l_chrv_rec.currency_code = l_func_currency) THEN -- both are same
           l_khrv_rec.currency_conversion_type := NULL;
           l_khrv_rec.currency_conversion_rate := NULL;
           l_khrv_rec.currency_conversion_date := NULL;
       ELSE -- transactional and functional currency are different

           -- Conversion type, date and rate mandetory
           IF (l_khrv_rec.currency_conversion_type IS NULL
               OR
               l_khrv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
              OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Currency Conversion Type');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;


           IF (l_khrv_rec.currency_conversion_date IS NULL
               OR
               l_khrv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
               If nvl(l_rbk_cpy,'N') <> 'Y' Then
                   l_khrv_rec.currency_conversion_date := p_chrv_rec.start_date;
               End if;
           End IF;

           --For Lease contract entry currency conversion date is always equal to
           --contract start date - PMs So

           If l_chrv_rec.scs_code = 'LEASE' and nvl(l_rbk_cpy,'N') <> 'Y' then
               l_khrv_rec.currency_conversion_date := p_chrv_rec.start_date;
           End If;


           IF (l_khrv_rec.currency_conversion_date IS NULL
               OR
               l_khrv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
              OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Currency Conversion Date');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;

           IF (upper(l_khrv_rec.currency_conversion_type) = 'USER') THEN

               IF (l_khrv_rec.currency_conversion_rate IS NULL
                   OR
                    l_khrv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
                  OKC_API.set_message(
                                      p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_REQUIRED_VALUE,
                                      p_token1       => G_COL_NAME_TOKEN,
                                      p_token1_value => 'Currency Conversion Rate');
                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  RAISE currency_validation_failed;
               END IF;


           ELSE -- conversion_type <> 'User'

              l_khrv_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
                                                          p_from_curr_code => l_chrv_rec.currency_code,
                                                          p_to_curr_code   => l_func_currency,
                                                          p_con_date       => l_khrv_rec.currency_conversion_date,
                                                          p_con_type       => l_khrv_rec.currency_conversion_type
                                                         );
              --since accounting util is returning -1 for all the rates not found
              --Bug# 2763523 : if rate not found api returnes -1 or -2 or any other negative value
              --If (l_khrv_rec.currency_conversion_rate = 0 ) OR (l_khrv_rec.currency_conversion_rate = -1)Then
              If (l_khrv_rec.currency_conversion_rate <= 0 ) Then
                  OKC_API.set_message(
                                      p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_CONV_RATE_NOT_FOUND,
                                      p_token1       => G_FROM_CURRENCY_TOKEN,
                                      p_token1_value => l_chrv_rec.currency_code,
                                      p_token2       => G_TO_CURRENCY_TOKEN,
                                      p_token2_value => l_func_currency,
                                      p_token3       => G_CONV_TYPE_TOKEN,
                                      p_token3_value => l_khrv_rec.currency_conversion_type,
                                      p_token4       => G_CONV_DATE_TOKEN,
                                      p_token4_value => to_char(l_khrv_rec.currency_conversion_date,'DD-MON-YYYY'));
                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  RAISE currency_validation_failed;
              End If;


           END IF; -- conversion_type

/*---Bug# 3124577 : 11.5.10 Rule Migration
----OKC currency rule will no longer be created.Removed call to create OKC Currency CVN rule---*/

       END IF; -- currency_code check
    END IF; -- currency_code NULL

    --Bug# 3124577 :11.5.10 Rule migration : OKC rule will not have to be created
    l_chrv_rec.conversion_type      := l_khrv_rec.currency_conversion_type;
    l_chrv_rec.conversion_rate      := l_khrv_rec.currency_conversion_rate;
    l_chrv_rec.conversion_rate_date := l_khrv_rec.currency_conversion_date;
    --Bug# 3124577 :11.5.10 Rule Migration : OKC rule will not have to be created

    x_chrv_rec := l_chrv_rec;
    x_khrv_rec := l_khrv_rec;

  EXCEPTION
    WHEN currency_validation_failed THEN
       RETURN;
    WHEN others THEN
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_currency;
--Bug# : 11.5.9 Enhancement  Multi-Currency Changes
---------------------------------------------------------------------------------
-- Start of comments
--  Bug # : 11.5.9  Enhancement Validate product and default Tax Owner
--                  and Book Classification from product
-- Procedure Name  : Validate_Product(Local)
-- Description     : 1. Will validate whether selected product belongs to the
--                      correct subclass
--                   2. Will default tax owner and book class from product
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------
Procedure Validate_Product(p_api_version   IN  NUMBER,
                           p_init_msg_list IN  VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           p_chrv_rec      IN  okl_okc_migration_pvt.chrv_rec_type,
                           p_pdt_id        IN  NUMBER,
                           x_deal_type     OUT NOCOPY VARCHAR2,
                           x_tax_owner     OUT NOCOPY VARCHAR2,
                           --bug# 3180583
                           x_multigaap_yn  OUT NOCOPY VARCHAR2) is

    l_pdt_id            Number;
    l_pdt_date          date;
    l_scs_code          okc_k_headers_b.scs_code%TYPE;
    l_pdtv_rec          okl_setupproducts_pub.pdtv_rec_type;
    l_pdt_parameter_rec okl_setupproducts_pub.pdt_parameters_rec_type;
    l_no_data_found     Boolean;
    l_error_condition   exception;

    --cursor to get tax owner rule group
    Cursor town_rgp_exists_csr (pchrid Number) is
    select id
    From   okc_rule_groups_b rgp
    Where  rgp.chr_id     = pchrid
    and    rgp.dnz_chr_id = pchrid
    and    rgp.rgd_code   = 'LATOWN';

    l_town_rgp_id Number  default Null;

    --cursor to get tax owner rule
    Cursor town_rul_csr (pchrid number, prgpid number) is
    Select rule_information1 tax_owner,
           id
    From   okc_rules_b rul
    where  rul.rgp_id     = prgpid
    and    rul.dnz_chr_id = pchrid
    and    rul.rule_information_category = 'LATOWN'
    and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

    l_town_rul      okc_rules_b.rule_information1%TYPE;
    l_town_rul_id   okc_rules_b.id%TYPE;

    l_latown_rgpv_rec   OKL_RULE_PUB.rgpv_rec_type;
    lx_latown_rgpv_rec  OKL_RULE_PUB.rgpv_rec_type;

    l_latown_rulv_rec   OKL_RULE_PUB.rulv_rec_type;
    lx_latown_rulv_rec  OKL_RULE_PUB.rulv_rec_type;

    --cursor to get product name for exception conditions
    Cursor get_pdtname_csr (pdtid in Number) is
    Select name
    From   OKL_PRODUCTS_V
    Where  id = pdtid;

    l_pdt_name OKL_PRODUCTS_V.NAME%TYPE default null;

    --Bug#2727161 : 11.5.9 Rebooks - product can not be modified
    -- cursor to get product of the original contract
    Cursor ger_orig_pdt_csr(p_rbk_chr_id IN NUMBER) is
    Select khr.pdt_id
    from   okl_k_headers khr,
           okc_k_headers_b rbk_chr
    where  khr.id = rbk_chr.orig_system_id1
    and    rbk_chr.id = p_rbk_chr_id;

    l_orig_pdt_id  okl_k_headers.pdt_id%TYPE;
    --Bug#2727161 : 11.5.9 product - currency can not be modified

    l_rbk_cpy   Varchar2(1) default 'N';


    --Bug# 3548044 : cursor to fetch the existing  pdt_id for this contract
    --Bug# 3631094 :
    Cursor l_curr_pdt_csr (p_chr_id in number) is
    select khr.pdt_id,
           chrb.scs_code,
           chrb.orig_system_source_code
    from   okl_k_headers      khr,
           okc_k_headers_b    chrb
    where  khr.id                        =   chrb.id
    and    chrb.id                       =   p_chr_id;

    l_curr_pdt_rec    l_curr_pdt_csr%ROWTYPE;

    --Bug# 3631094
    Cursor l_release_asset_yn_csr (p_chr_id in number) is
    select nvl(rulb.rule_information1,'N') release_Asset_yn
    from   okc_rules_b rulb,
           okc_rule_groups_b rgpb
    where  rulb.rule_information_category   = 'LARLES'
    and    rulb.rgp_id                      = rgpb.id
    and    rulb.dnz_chr_id                  = rgpb.dnz_chr_id
    and    rgpb.rgd_code                    = 'LARLES'
    and    rgpb.chr_id                      = p_chr_id
    and    rgpb.dnz_chr_id                  = p_chr_id;

    l_release_asset_yn                      okc_rules_b.rule_information1%TYPE;
    --Bug# 3631094

    --cursor to get multi-gaap reporting book transaction
    cursor l_txd_csr (p_book_type_code in varchar2,
                      p_chr_id         in number) is
    select txdb.id
    from   okl_txd_assets_b txdb,
           okl_txl_assets_b txlb,
           okc_k_lines_b    cleb,
           okc_line_styles_b lseb
    where  txdb.tax_book         =  p_book_type_code
    and    txdb.tal_id           =  txlb.id
    and    txlb.kle_id           =  cleb.id
    and    cleb.lse_id           = lseb.id
    and    lseb.lty_code         = 'FIXED_ASSET'
    and    cleb.dnz_chr_id       = p_chr_id;

    l_txd_rec   l_txd_csr%ROWTYPE;

    l_adpv_tbl  OKL_TXD_ASSETS_PUB.adpv_tbl_type;

    i                        number;
    l_curr_pdtv_rec          okl_setupproducts_pub.pdtv_rec_type;
    l_curr_pdt_parameter_rec okl_setupproducts_pub.pdt_parameters_rec_type;
    l_rep_book_type          okl_txd_assets_b.tax_book%TYPE;
    --Bug# 3621663
    l_Multi_GAAP_YN          varchar2(1);
    l_rep_pdtv_rec           okl_setupproducts_pub.pdtv_rec_type;
    l_rep_pdt_parameter_rec  okl_setupproducts_pub.pdt_parameters_rec_type;
    --Bug# 3548044

Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pdt_id        := p_pdt_id;
    l_pdt_date      := p_chrv_rec.start_date;
    l_scs_code      := p_chrv_rec.scs_code;
    l_pdtv_rec.id   := l_pdt_id;
    l_no_data_found := TRUE;

    --Check if contract is rebook copy
    --if it is and product is being modified raise error
    l_rbk_cpy := Is_Rebook_Copy(p_chr_id => p_chrv_rec.id);
    If l_rbk_cpy = 'Y' Then
        Open ger_orig_pdt_csr(p_rbk_chr_id => p_chrv_rec.id);
        Fetch ger_orig_pdt_csr into  l_orig_pdt_id;
        If ger_orig_pdt_csr%NOTFOUND then
            null;
        Else
            If l_orig_pdt_id <> l_pdt_id Then
                OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                                    p_msg_name  => G_REBOOK_PRODUCT_MODFN);
                x_return_status := OKL_API.G_RET_STS_ERROR;
                raise l_error_condition;
            End If;
        End If;
    End If;

    Okl_SetupProducts_Pub.GetPdt_Parameters (p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             x_no_data_found => l_no_data_found,
                                             p_pdtv_rec      => l_pdtv_rec,
                                             p_product_date  => l_pdt_date,
                                             p_pdt_parameter_rec => l_pdt_parameter_rec);

    --product param fetch returns errors
    If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
       Open get_pdtname_csr(p_pdt_id);
       Fetch get_pdtname_csr into l_pdt_name;
       If get_pdtname_csr%notfound then
           null;
       end if;
       close get_pdtname_csr;

       OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_PARAMS_NOT_FOUND,
                           p_token1       => G_PROD_NAME_TOKEN ,
                           p_token1_value => l_pdt_name);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       raise l_error_condition;
    End If;

    --product subcalss is null
    If l_pdt_parameter_rec.product_subclass is Null or
       l_pdt_parameter_rec.product_subclass = OKL_API.G_MISS_CHAR Then
       --message for missing product subclass
       Open get_pdtname_csr(p_pdt_id);
       Fetch get_pdtname_csr into l_pdt_name;
       If get_pdtname_csr%notfound then
           null;
       end if;

       OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_MISSING_PARAM,
                           p_token1       => G_PROD_PARAM_TOKEN,
                           p_token1_value => 'Product Subclass',
                           p_token2       => G_PROD_NAME_TOKEN,
                           p_token2_value => l_pdt_name);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE l_error_condition;
    End If;

    --product tax owner is null
    If l_pdt_parameter_rec.tax_owner is Null or
       l_pdt_parameter_rec.tax_owner = OKL_API.G_MISS_CHAR Then
       If l_scs_code in ('LEASE','QUOTE') then
           --message for missing product tax owner
           Open get_pdtname_csr(p_pdt_id);
           Fetch get_pdtname_csr into l_pdt_name;
           If get_pdtname_csr%notfound then
               null;
           end if;
           OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_MISSING_PARAM,
                           p_token1       => G_PROD_PARAM_TOKEN,
                           p_token1_value => 'Tax Owner',
                           p_token2       => G_PROD_NAME_TOKEN,
                           p_token2_value => l_pdt_name);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE l_error_condition;
           -- tax owner may not be a mandatory quality
       End If;
    End If;

    --product deal type is null
    If l_pdt_parameter_rec.deal_type is Null or
       l_pdt_parameter_rec.deal_type = OKL_API.G_MISS_CHAR Then
       If l_scs_code in ('LEASE','QUOTE') then
           --message for missing product tax owner
           Open get_pdtname_csr(p_pdt_id);
           Fetch get_pdtname_csr into l_pdt_name;
           If get_pdtname_csr%notfound then
               null;
           end if;
           OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_MISSING_PARAM,
                           p_token1       => G_PROD_PARAM_TOKEN,
                           p_token1_value => 'Book Classification',
                           p_token2       => G_PROD_NAME_TOKEN,
                           p_token2_value => l_pdt_name);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE l_error_condition;
           -- tax owner may not be a mandatory quality
       End If;
       null; -- deal type may not be a mandatory pdt quality
    End If;

    --check if product subclass matches contract subclass
    If l_scs_code in ('LEASE', 'PROGRAM', 'MASTER_LEASE','QUOTE','LOAN') and
       l_pdt_parameter_rec.product_subclass <> 'LEASE' then
       --Product and contract subclassess do not match
       Open get_pdtname_csr(p_pdt_id);
       Fetch get_pdtname_csr into l_pdt_name;
       If get_pdtname_csr%notfound then
           null;
       end if;
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_SUBCALSS_MISMATCH,
                           p_token1       => G_CONTRACT_SUBCLASS_TOKEN,
                           p_token1_value => l_scs_code,
                           p_token2       => G_PROD_SUBCALSS_TOKEN,
                           p_token2_value => l_pdt_parameter_rec.product_subclass);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE l_error_condition;
    ElsIf l_scs_code in ('INVESTOR') and
       l_pdt_parameter_rec.product_subclass <> 'INVESTOR' then
       --Product and contract subclassess do not match
       Open get_pdtname_csr(p_pdt_id);
       Fetch get_pdtname_csr into l_pdt_name;
       If get_pdtname_csr%notfound then
           null;
       end if;
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_SUBCALSS_MISMATCH,
                           p_token1       => G_CONTRACT_SUBCLASS_TOKEN,
                           p_token1_value => l_scs_code,
                           p_token2       => G_PROD_SUBCALSS_TOKEN,
                           p_token2_value => l_pdt_parameter_rec.product_subclass);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE l_error_condition;
    End If;

    If l_scs_code in ('LEASE','QUOTE') Then

        l_town_rgp_id := Null;

        Open town_rgp_exists_csr(pchrid => p_chrv_rec.id);
        Fetch town_rgp_exists_csr into l_town_rgp_id;
        If town_rgp_exists_csr%NOTFOUND Then
            null;
        end if;
        Close town_rgp_exists_csr;

        If l_town_rgp_id is null Then
            --tax owner record does not exist
            --create tax owner
            l_latown_rgpv_rec.rgd_code   := 'LATOWN';
            l_latown_rgpv_rec.dnz_chr_id := p_chrv_rec.id;
            l_latown_rgpv_rec.chr_id     := p_chrv_rec.id;
            l_latown_rgpv_rec.rgp_type   := 'KRG';

            OKL_RULE_PUB.create_rule_group(
               p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_rgpv_rec       => l_latown_rgpv_rec,
               x_rgpv_rec       => lx_latown_rgpv_rec);

           If (x_return_status <> OKL_API.G_RET_STS_SUCCESS) Then
                  raise l_error_condition;
           End If;

            l_town_rgp_id := lx_latown_rgpv_rec.id;
        End if;

        l_town_rul := null;
        l_town_rul_id := null;
        Open town_rul_csr (pchrid => p_chrv_rec.id, prgpid => l_town_rgp_id );
        Fetch town_rul_csr into l_town_rul,l_town_rul_id;
        If town_rul_csr%NOTFOUND Then
            Null;
        End If;
        Close town_rul_csr;

        If l_town_rul_id is null then
            -- create rule
            l_latown_rulv_rec.rgp_id                    := l_town_rgp_id;
            l_latown_rulv_rec.rule_information_category := 'LATOWN';
            l_latown_rulv_rec.dnz_chr_id                := p_chrv_rec.id;
            l_latown_rulv_rec.rule_information1         := l_pdt_parameter_rec.tax_owner;
            l_latown_rulv_rec.WARN_YN                   := 'N';
            l_latown_rulv_rec.STD_TEMPLATE_YN           := 'N';

            OKL_RULE_PUB.create_rule(
                p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_rulv_rec       => l_latown_rulv_rec,
                x_rulv_rec       => lx_latown_rulv_rec);

           If (x_return_status <> OKL_API.G_RET_STS_SUCCESS) Then
                  raise l_error_condition;
           End If;


       Elsif l_town_rul_id is not null then

           --update existing rule if values are different
           If l_town_rul <> l_pdt_parameter_rec.tax_owner Then
               l_latown_rulv_rec.id := l_town_rul_id;
               l_latown_rulv_rec.rule_information1 := l_pdt_parameter_rec.tax_owner;

               OKL_RULE_PUB.update_rule(
                   p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_rulv_rec       => l_latown_rulv_rec,
                   x_rulv_rec       => lx_latown_rulv_rec);

              If (x_return_status <> OKL_API.G_RET_STS_SUCCESS) Then
                  raise l_error_condition;
              End If;
           End If;

       End If;

    End If;

    ---------------------------------------------------------------------
    --Bug# 3631094 : Do not prompt for deletion of rporting asset books
    --               if rebook, release contract or release asset
    ---------------------------------------------------------------------
    --fetch currenct pdt_id
    open l_curr_pdt_csr (p_chr_id => p_chrv_rec.id);
    fetch l_curr_pdt_csr into l_curr_pdt_rec;
    If l_curr_pdt_csr%NOTFOUND then
         null;
    End If;
    close l_curr_pdt_csr;

    If nvl(l_curr_pdt_rec.pdt_id, okl_api.g_miss_num) <> okl_api.g_miss_num AND
    l_curr_pdt_rec.pdt_id <> l_pdt_id  AND
    l_curr_pdt_rec.scs_code = 'LEASE'  AND
    nvl(l_curr_pdt_rec.orig_system_source_code,okl_api.g_miss_char) not in ('OKL_REBOOK','OKL_RELEASE') then
        l_release_asset_yn := 'N';
        Open l_release_asset_yn_csr(p_chr_id  => p_chrv_rec.id);
        Fetch l_release_asset_yn_csr into l_release_Asset_yn;
        If l_release_asset_yn_csr%NOTFOUND then
            null;
        End If;
        Close l_release_asset_yn_csr;
        If l_release_asset_yn =  'N' then
            -----------------
            --Bug# 3548044 : If multi-gaap prod changed to no multi-gaap
                            --multi gaap reporting book trx needs to be deleted
            ----------------
            --Bug# 3621663 :
            l_Multi_GAAP_YN := 'N';
            If l_rbk_cpy = 'N' then
            --decide whether the reporting product needs multigaap asset book
                If nvl(l_pdt_parameter_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                    l_rep_pdtv_rec.id      := l_pdt_parameter_rec.reporting_pdt_id;
                 --okl_debug_pub.logmessage('AKP:0.l_rep_pdtv_rec.id = ' || l_rep_pdtv_rec.id);
                    l_pdt_date             := p_chrv_rec.start_date;
                 --okl_debug_pub.logmessage('AKP:0.l_pdt_date = ' || l_pdt_date);

                    Okl_SetupProducts_Pub.GetPdt_Parameters (p_api_version       => p_api_version,
                                                 p_init_msg_list     => p_init_msg_list,
                                                 x_return_status     => x_return_status,
                                                 x_msg_count         => x_msg_count,
                                                 x_msg_data          => x_msg_data,
                                                 x_no_data_found     => l_no_data_found,
                                                 p_pdtv_rec          => l_rep_pdtv_rec,
                                                 p_product_date      => l_pdt_date,
                                                 p_pdt_parameter_rec => l_rep_pdt_parameter_rec);

                     If x_return_status = OKL_API.G_RET_STS_SUCCESS then

                         -- 7610725
                         /*If nvl(l_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) = 'LEASEOP' and
                         nvl(l_rep_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) = 'LEASEOP' and
                         nvl(l_pdt_parameter_rec.tax_owner,OKL_API.G_MISS_CHAR) = 'LESSOR' Then
                             l_Multi_GAAP_YN := 'Y';
                         End If;

                         If nvl(l_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) in ('LEASEDF','LEASEST') and
                         nvl(l_rep_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) = 'LEASEOP' and
                         nvl(l_pdt_parameter_rec.tax_owner,OKL_API.G_MISS_CHAR) = 'LESSOR' Then
                             l_Multi_GAAP_YN := 'Y';
                         End If;

                         If nvl(l_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) in ('LEASEDF','LEASEST') and
                         nvl(l_rep_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) = 'LEASEOP' and
                         nvl(l_pdt_parameter_rec.tax_owner,OKL_API.G_MISS_CHAR) = 'LESSEE' Then
                            l_Multi_GAAP_YN := 'Y';
                         End If;

                         If nvl(l_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) = 'LOAN' and
                         nvl(l_rep_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR) = 'LEASEOP' and
                         nvl(l_pdt_parameter_rec.tax_owner,OKL_API.G_MISS_CHAR) = 'LESSEE' Then
                             l_Multi_GAAP_YN := 'Y';
                         End If; */

                         -- 7610725
         --okl_debug_pub.logmessage('AKP:1.l_rep_pdt_parameter_rec.id = ' || l_rep_pdt_parameter_rec.id);
         --okl_debug_pub.logmessage('AKP:2.l_rep_pdt_parameter_rec.deal_type = ' || l_rep_pdt_parameter_rec.deal_type);
                         If (nvl(l_rep_pdt_parameter_rec.deal_type,OKL_API.G_MISS_CHAR)
                                 <> OKL_API.G_MISS_CHAR )
                         Then
                             l_Multi_GAAP_YN := 'Y';
                         End If;


                     End If;
                End If;
            End If;
            --Bug# 3621663

         --okl_debug_pub.logmessage('AKP:3.l_pdt_parameter_rec.reporting_pdt_id =' || l_pdt_parameter_rec.reporting_pdt_id);
         --okl_debug_pub.logmessage('AKP:4.l_Multi_GAAP_YN= ' || l_Multi_GAAP_YN);
            If  (nvl(l_pdt_parameter_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM)
              OR
                 (nvl(l_pdt_parameter_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM
             and l_Multi_GAAP_YN = 'N') Then
                 If l_rbk_cpy = 'N' then
                     l_curr_pdtv_rec.id      := l_curr_pdt_rec.pdt_id;
                     l_pdt_date              := p_chrv_rec.start_date;
                     Okl_SetupProducts_Pub.GetPdt_Parameters (p_api_version       => p_api_version,
                                                      p_init_msg_list     => p_init_msg_list,
                                                      x_return_status     => x_return_status,
                                                      x_msg_count         => x_msg_count,
                                                      x_msg_data          => x_msg_data,
                                                      x_no_data_found     => l_no_data_found,
                                                      p_pdtv_rec          => l_curr_pdtv_rec,
                                                      p_product_date      => l_pdt_date,
                                                      p_pdt_parameter_rec => l_curr_pdt_parameter_rec);

                     If x_return_status = OKL_API.G_RET_STS_SUCCESS then
         --okl_debug_pub.logmessage('AKP:5.l_curr_pdt_parameter_rec.id = ' || l_curr_pdt_parameter_rec.id);
                         If nvl(l_curr_pdt_parameter_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                             l_rep_book_type := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
                             i := 0;
                             open l_txd_csr (p_book_type_code  => l_rep_book_type,
                                             p_chr_id          => p_chrv_rec.id);
                             Loop
                                 fetch l_txd_csr into l_txd_rec;
                                 exit when l_txd_csr%NOTFOUND;
                                 i := i+1;
                                 l_adpv_tbl(i).id := l_txd_rec.id;
                             end Loop;
                             close l_txd_csr;

                             If l_adpv_tbl.COUNT <> 0 then
                                 --Bug# 3631094
                                 OKL_API.set_message(p_app_name     => G_APP_NAME,
                                                       p_msg_name     => 'OKL_LA_MULTIGAAP_ASSET_BOOK');
                                 x_return_status :=  OKL_API.G_RET_STS_ERROR;
                                 raise l_error_condition;
                             End If;

                         End If; -- current reporting product is not null
                     End If; --product parameters fetch api returns success
                 End If; -- is not a rebook copy
            End If; -- new multi gaap product is null
        End If; -- not a contract with release assets
    End If; -- is 'LEASE', change in product is there, not rbook or contract release copy, current pdt not null
    ------------------
    --Bug# 3548044 : End
    ------------------


    x_deal_type  := l_pdt_parameter_rec.deal_type;
    x_tax_owner  := l_pdt_parameter_rec.tax_owner;

    -----------------
    --Bug# 3180583
    -----------------
    If nvl(l_pdt_parameter_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM then
        x_multigaap_yn := 'N';
    Elsif nvl(l_pdt_parameter_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
        x_multigaap_yn := 'Y';
    End If;
    -----------------
    --Bug# 3180583
    -----------------


    EXCEPTION
    When l_error_condition Then
        Return;

    When Others Then
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
End validate_product;
--------------------------------------------------------------------------------
-- Start of comments
--
-- Bug# : 11.5.9 Enhancement  Product change (Bug# 2730633)
-- Function Name   : Is_Orig_Pdt_Old
-- Scope           : Local
-- Description     : For Copied contracts if the original contract has old (11.5.8)
--                   product, product validations should not be done. If they are
--                   done copy from old contracts will not be possible.
--                   This function verifies if product against original contract
--                   is old(11.5.8) or not.
--                   This will be called at the time of insert(create_contract_header)
--                   If original/old contract product is old then 11.5.9 product validations
--                   will not be done.
-- Business Rules  :
-- Parameters      : IN - p_orig_chr_id - original contract id
--                      - p_pdt_id      - pdt_id on new contract being created
--                   Returns Varchar2 = 'Y' or 'N'
-- Version         : 1.0
-- End of comments
--------------------------------------------------------------------------------
Function Is_Orig_Pdt_Old(p_orig_chr_id IN NUMBER,
                         p_pdt_id      IN NUMBER
                         ) return Varchar2 is
--cursor to get pdt of original contract
Cursor get_pdt_csr(orig_chr_id in number) is
Select khr.pdt_id,
       khr.start_date
from   okl_k_headers_full_v khr
where  id = orig_chr_id;

l_pdt_id                 okl_k_headers_full_v.pdt_id%TYPE;
l_Start_date             date;
l_is_orig_pdt_old        Varchar2(1) default 'N';
l_no_data_found          Boolean;
l_pdtv_rec               Okl_SetupProducts_Pub.pdtv_rec_type;
l_pdt_parameter_rec      Okl_setupproducts_pub.pdt_parameters_rec_type;
l_exception_halt_process Exception;

l_return_status          Varchar2(1) default OKL_API.G_RET_STS_SUCCESS;
l_msg_count              Number;
l_msg_data               Varchar2(3000);

begin
    l_return_status    := OKL_API.G_RET_STS_SUCCESS;
    l_is_orig_pdt_old  := 'N';

    Open get_pdt_csr (orig_chr_id => p_orig_chr_id);
    Fetch get_pdt_csr into l_pdt_id, l_start_date;
    If get_pdt_csr%NOTFOUND Then
        Null;
    End If;
    Close get_pdt_csr;

    If (l_pdt_id = p_pdt_id) Then
        l_pdtv_rec.id   := l_pdt_id;
        l_no_data_found := TRUE;
        Okl_SetupProducts_Pub.GetPdt_Parameters (p_api_version       => 1.0,
                                                 p_init_msg_list     => OKL_API.G_FALSE,
                                                 x_return_status     => l_return_status,
                                                 x_msg_count         => l_msg_count,
                                                 x_msg_data          => l_msg_data,
                                                 x_no_data_found     => l_no_data_found,
                                                 p_pdtv_rec          => l_pdtv_rec,
                                                 p_product_date      => l_start_date,
                                                 p_pdt_parameter_rec => l_pdt_parameter_rec);

        --product param do not exist
        If l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
            l_is_orig_pdt_old := 'Y';
            Raise l_exception_halt_process;
        End If;

        --product subcalss is null
        If l_pdt_parameter_rec.product_subclass is Null or
           l_pdt_parameter_rec.product_subclass = OKL_API.G_MISS_CHAR Then
            l_is_orig_pdt_old := 'Y';
            Raise l_exception_halt_process;
        End If;

        --product tax owner is null
        If l_pdt_parameter_rec.tax_owner is Null or
           l_pdt_parameter_rec.tax_owner = OKL_API.G_MISS_CHAR Then
           l_is_orig_pdt_old := 'Y';
           Raise l_exception_halt_process;
        End If;

        --product deal type is null
        If l_pdt_parameter_rec.deal_type is Null or
           l_pdt_parameter_rec.deal_type = OKL_API.G_MISS_CHAR Then
           l_is_orig_pdt_old := 'Y';
           Raise l_exception_halt_process;
        End If;
    End If;
    Return(l_is_orig_pdt_old);
    Exception
    When l_exception_halt_process Then
        return (l_is_orig_pdt_old);
    When others then
        return (l_is_orig_pdt_old);

End Is_Orig_Pdt_Old;
--------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_contract_header
-- Description     : creates contract header for shadowed contract
-- Bug# : 11.5.9 Enhancement  Multi-Currency Changes
--                           Product Vaqlidations
--                           Rebook contract can not change currency code
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--------------------------------------------------------------------------------
  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    subtype rulv_tbl_type is OKL_RULE_PUB.rulv_tbl_type;

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    --Bug # : 11.5.9 Enhancement - Multi Currency changes

    l_curr_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_curr_khrv_rec khrv_rec_type;

    --Bug # : 11.5.9 Enhancement - Defaulting from product definition
    l_pdt_deal_type  varchar2(150);
    l_pdt_tax_owner  varchar2(150);

    l_bypass_pdt_validation varchar2(1) default 'N';
    --Bug# 3180583
    l_multigaap_yn varchar2(1) default NULL;

    --Bug# 3486065
    cursor profile_option_csr(p_profile_option_name in varchar2) is
    select user_profile_option_name
    from   fnd_profile_options_vl
    where  profile_option_name = p_profile_option_name;

    l_authoring_org_profile_name  fnd_profile_options_vl.user_profile_option_name%type;
    l_inventory_org_profile_name  fnd_profile_options_vl.user_profile_option_name%type;
    l_authoring_org_profile_value fnd_profile_option_values.profile_option_value%type;
    l_inventory_org_profile_value fnd_profile_option_values.profile_option_value%type;

  l_deal_type OKL_K_HEADERS.deal_type%TYPE;
  l_interest_calculation_basis VARCHAR2(30);
  l_revenue_recognition_method VARCHAR2(30);
  l_pdt_parameter_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
  x_rulv_tbl rulv_tbl_type;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list


    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

    --Bug# 3783278
    --Remove leading and trailing spaces in contract number
    If l_chrv_rec.contract_number is not null Then
      l_chrv_rec.contract_number := LTRIM(RTRIM(l_chrv_rec.contract_number));
    End If;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing
        --dbms_output.put_line('Set org context');

    --Bug# 3486065
    l_authoring_org_profile_value := mo_global.get_current_org_id();
    If NVL(l_authoring_org_profile_value,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR Then
      open profile_option_csr(p_profile_option_name => 'ORG_ID');
      fetch profile_option_csr into l_authoring_org_profile_name;
      close profile_option_csr;

      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_SYSTEM_PROFILE',
                          p_token1       => 'OKL_SYS_PROFILE_NAME',
                          p_token1_value => l_authoring_org_profile_name);
      raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_inventory_org_profile_value := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID);

    -- removed by dcshanmu to fix bug 5378114

    If NVL(l_inventory_org_profile_value,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR Then
         /*open profile_option_csr(p_profile_option_name => 'OKL_K_ITEMS_INVENTORY_ORG');
         fetch profile_option_csr into l_inventory_org_profile_name;
         close profile_option_csr;*/

      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_INVENTORY_ORG');
      raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);

        ----------------------------------------------------------------------------
    --call to check if template modification is allowed
    ----------------------------------------------------------------------------
    template_create_allowed(p_chr_id        => null,
                            p_template_yn   => l_chrv_rec.template_yn,
                            x_return_status => x_return_status);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                           p_msg_name => G_TEMPLATE_CREATE_NOT_ALLOWED);
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency
    ----------------------------------------------------------------------------
    validate_currency(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      x_return_status => x_return_status,
                      p_chrv_rec      => l_chrv_rec,
                      p_khrv_rec      => l_khrv_rec,
                      x_chrv_rec      => l_curr_chrv_rec,
                      x_khrv_rec      => l_curr_khrv_rec);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;
    l_chrv_rec := l_curr_chrv_rec;
    l_khrv_rec := l_curr_khrv_rec;
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency
    ----------------------------------------------------------------------------
      --Added by dpsingh
      IF (l_khrv_rec.legal_entity_id IS NOT NULL AND l_khrv_rec.legal_entity_id <> Okl_Api.G_MISS_NUM) THEN
          OKL_LA_VALIDATION_UTIL_PVT.VALIDATE_LEGAL_ENTITY(x_return_status => x_return_status,
                                                                                                       p_chrv_rec      => l_chrv_rec,
												       p_mode => 'CR');
       ELSE
           IF l_chrv_rec.scs_code IN ('LEASE','LOAN','INVESTOR', 'MASTER_LEASE','PROGRAM') THEN
	      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'legal_entity_id');
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	   END IF;
       END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Added by dpsingh end

    --dbms_output.put_line('Create contract header');
    --
    -- call procedure in complex API
    --
    --OKC_CONTRACT_PUB.create_contract_header(

    okl_okc_migration_pvt.create_contract_header(
         p_api_version            => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_chrv_rec                    => l_chrv_rec,
         x_chrv_rec                    => x_chrv_rec);


    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;


    /*Bug# 3124577 : Commented for 11.5.10 Rule Migration-------------------------------------------
    --Removed call to creation of OKC CVN Rule
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency, Create CURRENCY Rule
    ----------------------------------------------------------------------------
    -----------------------------------------------------------Bug# 3124577 11.5.10: Rule Migration*/
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Product validations
    ----------------------------------------------------------------------------
    If p_khrv_rec.pdt_id is null OR p_khrv_rec.pdt_id = OKL_API.G_MISS_NUM Then
        Null;
    Else

        --Begin (Bug# 2730633)
        --Fix for not to validate for copied contracts being copied from contracts
        --which have 11.5.8 products against them
        l_bypass_pdt_validation := 'N';
        If nvl(x_chrv_rec.orig_system_source_code,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR AND
           nvl(x_chrv_rec.orig_system_id1,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM Then
           l_bypass_pdt_validation := Is_Orig_Pdt_old(p_orig_chr_id => x_chrv_rec.orig_system_id1,
                                                      p_pdt_id      => p_khrv_rec.pdt_id);
        End If;
        --Fix for not to validate for copied contracts being copied from contracts
        --which have 11.5.8 products against them
        --End (Bug# 2730633)

        If  l_bypass_pdt_validation = 'N' Then
            Validate_Product(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_chrv_rec      => x_chrv_rec,
                             p_pdt_id        => p_khrv_rec.pdt_id,
                             x_deal_type     => l_pdt_deal_type,
                             x_tax_owner     => l_pdt_tax_owner,
                             --Bug# 3180583
                             x_multigaap_yn  => l_multigaap_yn);

            -- check return status
            If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                    raise OKL_API.G_EXCEPTION_ERROR;
            End If;

            If l_chrv_rec.scs_code in ('LEASE','QUOTE') Then
                --Bug#2809358
                --If l_khrv_rec.deal_type <> l_pdt_deal_type Then
                If nvl(l_khrv_rec.deal_type,'DEALTYPE') <> l_pdt_deal_type Then
                    --If l_pdt_deal_type is not null OR
                    If l_pdt_deal_type is not null AND
                       l_pdt_deal_type <> OKL_API.G_MISS_CHAR Then
                       l_khrv_rec.deal_type := l_pdt_deal_type;
                    End If;
                 End If;

                 --Bug# 3379294 : check if deal type is still Null then raise error for lease and quote
                 If nvl(l_khrv_rec.deal_type,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
                     OKL_API.Set_Message(p_app_name => G_APP_NAME,
                                         p_msg_name => 'OKL_NULL_DEAL_TYPE');
                     x_return_status := OKL_API.G_RET_STS_ERROR;
                     raise OKL_API.G_EXCEPTION_ERROR;
                 End If;
                 --Bug# 3379294: End

            End If;
        End If;
    End If;
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Product validations
    ----------------------------------------------------------------------------

    --Bug# 2819869: Generate accrual and assignable hould be 'Y' by default
    If x_chrv_rec.scs_code = 'LEASE' Then
        If l_khrv_rec.generate_accrual_yn is NULL OR
           l_khrv_rec.generate_accrual_yn = OKL_API.G_MISS_CHAR then
            l_khrv_rec.generate_accrual_yn := 'Y';
        End IF;
        If l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN is NULL OR
           l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN = OKL_API.G_MISS_CHAR then
            l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN := 'N';
        End IF;
        If l_khrv_rec.assignable_yn is NULL OR
           l_khrv_rec.assignable_yn = OKL_API.G_MISS_CHAR then
            l_khrv_rec.assignable_yn := 'Y';
        End IF;
    End If;
    --End Bug# 2819869 : Generate accrual and assignable should be 'Y' by default

    -- get id from OKC record
    l_khrv_rec.ID := x_chrv_rec.ID;

        --dbms_output.put_line('Create shadow');

    -- call procedure in complex API
        OKL_KHR_PVT.Insert_Row(
                p_api_version            => p_api_version,
                p_init_msg_list            => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khrv_rec              => l_khrv_rec,
            x_khrv_rec              => x_khrv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

        --dbms_output.put_line('I am through');

  -- 4542290. Create zero interest schedules for LOAN (FLOAT, CATCHUP/CLEANUP)
  --          And LOAN-REVOLVING (FLOAT).

  OKL_K_RATE_PARAMS_PVT.get_product(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => l_khrv_rec.ID,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

  l_interest_calculation_basis :=l_pdt_parameter_rec.interest_calculation_basis;
  l_revenue_recognition_method :=l_pdt_parameter_rec.revenue_recognition_method;
  l_deal_type := l_pdt_parameter_rec.deal_type;

  --Bug 4742650 (Not to be created for LOAN CATCHUP/CLEANUP)
  IF (l_deal_type = 'LOAN' AND
      --l_interest_calculation_basis IN ('FLOAT', 'CATCHUP/CLEANUP')) OR
      l_interest_calculation_basis = 'FLOAT') OR
    (l_deal_type = 'LOAN-REVOLVING' AND
     l_interest_calculation_basis = 'FLOAT') THEN
    OKL_LA_PAYMENTS_PVT.VARIABLE_INTEREST_SCHEDULE (
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_chr_id        => l_khrv_rec.ID,
          x_rulv_tbl      => x_rulv_tbl
    );

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

  END IF;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END create_contract_header;


-- Start of comments
--
-- Procedure Name  : create_contract_header
-- Description     : creates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okl_okc_migration_pvt.chrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status         VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                               NUMBER;
    l_khrv_tbl                  khrv_tbl_type := p_khrv_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
           i := p_chrv_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                create_contract_header(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_chrv_rec                => p_chrv_tbl(i),
                p_khrv_rec                => l_khrv_tbl(i),
                        x_chrv_rec                => x_chrv_tbl(i),
                x_khrv_rec                => x_khrv_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END create_contract_header;


--------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : update_contract_header
-- Description     : updates contract header for shadowed contract
--Bug# : 11.5.9 Enhancement  Multi-Currency Changes
--                           Product Vaqlidations
--                           Rebook contract can not change currency code
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------
  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS


    subtype rulv_tbl_type is OKL_RULE_PUB.rulv_tbl_type;
    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

    cursor l_khrv_csr(l_id IN NUMBER) is
        select 'x'
        from OKL_K_HEADERS_V
        where id = l_id;
    l_dummy_var VARCHAR2(1) := '?';

    l_modfn_mode  Varchar2(1);

   --Bug #2821383 : added order by as order of line dates being updated is important
   --Cursor to get top lines is lease chr has lines to change effectivity
   --bug 4412923: Removed the status 'CANCELLED' from the cursor
   Cursor top_cle_csr (p_chr_id IN NUMBER) is
   SELECT cle.id
   From   okc_k_lines_b cle,
          okc_statuses_b sts
   where  cle.dnz_chr_id = cle.chr_id
   and    cle.chr_id     = p_chr_id
   and    sts.code = cle.sts_code
   And    sts.ste_code not in ('HOLD','EXPIRED','TERMINATED');

   l_top_cle_id OKC_K_LINES_B.ID%TYPE;

   --Cursor to check if lease chr has lines to change effectivity
      --bug 4412923: Removed the status 'CANCELLED' from the cursor
   Cursor  cle_csr(p_cle_id IN NUMBER) is
   SELECT  cle.id,
           cle.start_date,
           cle.end_date,
           cle.orig_system_id1,
           --Bug#
           cle.lse_id
   From    okc_k_lines_b cle
   connect by prior cle.id = cle.cle_id
   start with cle.id = p_cle_id
   and exists (select 1
               from okc_statuses_b sts
               where sts.code = cle.sts_code
               and sts.ste_code not in ('HOLD','EXPIRED','TERMINATED'));

   l_cle_id           OKC_K_LINES_B.ID%TYPE;
   l_cle_start_date   OKC_K_LINES_B.START_DATE%TYPE;
   l_cle_end_date     OKC_K_LINES_B.END_DATE%TYPE;
   l_parent_cle_id    OKC_K_LINES_B.orig_system_id1%TYPE;
   --Bug#
   l_lse_id           OKC_K_LINES_B.lse_id%TYPE;


   l_clev_rec          OKL_OKC_MIGRATION_PVT.clev_rec_type;
   lx_clev_rec         OKL_OKC_MIGRATION_PVT.clev_rec_type;

   -------------------------------------------------------------------------
   --Bug# : 11.5.9 Multi-currency/product validation enhancements
   -------------------------------------------------------------------------
   --cursor to fetch current chr/khr columns from the database
   Cursor get_orig_chr_csr(chrid in number) is
   SELECT chr.currency_code,
          chr.start_date,
          chr.end_date,
          chr.scs_code,
          chr.orig_system_source_code,
          chr.orig_system_id1,
          chr.authoring_org_id  --MOAC
   FROM   okc_k_headers_b chr
   WHERE  chr.id = chrid;

   l_orig_chr_rec get_orig_chr_csr%ROWTYPE;

   --separate cursor fr khr as sometimes khr record may not exist
   -- for update
   Cursor get_orig_khr_csr(chrid in number) is
   SELECT khr.currency_conversion_type,
          khr.currency_conversion_rate,
          khr.currency_conversion_date,
          khr.term_duration,
          khr.pdt_id,
          --bug# 3180583
          khr.multi_gaap_yn
   FROM   okl_k_headers khr
   WHERE  khr.id = chrid;

   l_orig_khr_rec get_orig_khr_csr%ROWTYPE;

   -- Bug 7610725 start
   CURSOR curr_pdt_csr(p_pdt_id in number) IS
   SELECT DEAL_TYPE, REPORTING_PDT_ID
   FROM   OKL_PRODUCT_PARAMETERS_V
   WHERE  ID = p_pdt_id;

   l_curr_pdt_rec curr_pdt_csr%ROWTYPE;
   l_delete_flag VARCHAR(1) := 'N';

   l_rep_book_type          okl_txd_assets_b.tax_book%TYPE;
   cursor l_txd_csr (p_book_type_code in varchar2,
                      p_chr_id         in number) is
    select txdb.id
    from   okl_txd_assets_b txdb,
           okl_txl_assets_b txlb,
           okc_k_lines_b    cleb,
           okc_line_styles_b lseb
    where  txdb.tax_book         =  p_book_type_code
    and    txdb.tal_id           =  txlb.id
    and    txlb.kle_id           =  cleb.id
    and    cleb.lse_id           = lseb.id
    and    lseb.lty_code         = 'FIXED_ASSET'
    and    cleb.dnz_chr_id       = p_chr_id;

    l_txd_rec   l_txd_csr%ROWTYPE;
    l_adpv_tbl  OKL_TXD_ASSETS_PUB.adpv_tbl_type;
    i number;
   -- Bug 7610725 end


   l_curr_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
   l_curr_khrv_rec khrv_rec_type;

   l_pdt_deal_type       varchar2(150);
   l_pdt_tax_owner       varchar2(150);

   l_bypass_pdt_validation varchar2(1) default 'N';
   -------------------------------------------------------------------------
   --Bug# : 11.5.9 Multi-currency/product validation enhancements
   -------------------------------------------------------------------------
   --Bug# 2821383
   l_rbk_cpy    Varchar2(1) default 'N';

   --Cursor to get dates from orignal lines in case of a rebook contract
   Cursor  parent_cle_csr (p_cle_id IN Number) is
   SELECT
           cle.start_date,
           cle.end_date
   From    okc_k_lines_b cle
   Where   cle.id = p_cle_id;

   l_parent_cle_start_date OKC_K_HEADERS_B.start_date%TYPE;
   l_parent_cle_end_date   OKC_K_HEADERS_B.end_date%TYPE;

   --Bug# 3143522 : Subsidies
   --cursor to get lty code
   cursor l_ltycd_csr (p_lse_id in number) is
   select lseb.lty_code
   from   okc_line_styles_b lseb
   where  lseb.id = p_lse_id;

   l_lty_code okc_line_styles_b.lty_code%TYPE default null;

   --cursor to get maximum subsidy term
   cursor l_sub_csr (p_cle_id in number) is
   select subb.maximum_term
   from   okl_subsidies_b subb,
          okl_k_lines     kle
   where  subsidy_id = kle.subsidy_id
   and    kle.id     = p_cle_id;

   l_max_subsidy_term  okl_subsidies_b.maximum_term%TYPE;
   --Bug# 3143522 : subsidies

   --Bug# 3180583
   l_multigaap_yn varchar2(1) default Null;

  -- Bug 4722839
  l_deal_type OKL_K_HEADERS.deal_type%TYPE;
  l_interest_calculation_basis VARCHAR2(30);
  l_revenue_recognition_method VARCHAR2(30);
  l_pdt_parameter_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
  x_rulv_tbl rulv_tbl_type;

--Added by dpsingh for LE Uptake
 CURSOR get_con_line_ids_csr(p_chr_id1 NUMBER) IS
 SELECT DISTINCT TAS_ID
 FROM OKL_TXL_ASSETS_B
 WHERE KLE_ID IN
              (SELECT OKC.ID
	       FROM OKC_K_LINES_B OKC,
	       OKC_LINE_STYLES_B OKC_ST
	       WHERE OKC_ST.LTY_CODE ='FREE_FORM1'
	       AND OKC.LSE_ID=OKC_ST.ID
	       AND OKC.CHR_ID =OKC.DNZ_CHR_ID
	       AND OKC.CHR_ID =p_chr_id1);

l_tasv_rec  okl_tas_pvt.tasv_rec_type;
x_tasv_rec okl_tas_pvt.tasv_rec_type;
l_legal_entity_id NUMBER;
l_upd_trx_assets NUMBER(1);

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

    --Bug# 3783278
    --Remove leading and trailing spaces in contract number
    If l_chrv_rec.contract_number is not null Then
      l_chrv_rec.contract_number := LTRIM(RTRIM(l_chrv_rec.contract_number));
    End If;


        --term modfn

        OPEN  get_orig_chr_csr(l_chrv_rec.id);
        FETCH get_orig_chr_csr into l_orig_chr_rec;
        IF get_orig_chr_csr%NOTFOUND Then
            Null; --will not happen as we are updating the current record so it has to be there
        END IF;
        CLOSE get_orig_chr_csr;

        --dkagrawa moved down the following code and passed l_orig_chr_rec.authoring_org_id for MOAC

        -- set okc context before API call
        -- msamoyle: check whether we need to call this method here or in PUB or in processing
        OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_orig_chr_rec.authoring_org_id,l_chrv_rec.inv_organization_id);

        OPEN  get_orig_khr_csr(l_chrv_rec.id);
        FETCH get_orig_khr_csr into l_orig_khr_rec;
        IF get_orig_khr_csr%NOTFOUND Then
            Null; --will not happen as we are updating the current record so it has to be there
        END IF;
        CLOSE get_orig_khr_csr;

   -- Bug 7610725 start
    l_delete_flag := 'N';
    IF (l_khrv_rec.pdt_id IS NOT NULL AND
        l_khrv_rec.pdt_id <> OKL_API.G_MISS_NUM) THEN
      IF (NVL(l_orig_khr_rec.multi_gaap_yn,'N') = 'Y') THEN
        OPEN curr_pdt_csr(l_khrv_rec.pdt_id);
        FETCH curr_pdt_csr INTO l_curr_pdt_rec;
        CLOSE curr_pdt_csr;

        IF (l_curr_pdt_rec.REPORTING_PDT_ID IS NOT NULL) THEN
          IF l_curr_pdt_rec.DEAL_TYPE like 'LOAN%' THEN
            -- Delete reporting asset tax book
            l_delete_flag := 'Y';
          END IF;
        ELSE
          -- Delete rep[orting asset tax book
            l_delete_flag := 'Y';
            --l_khrv_rec.multi_gaap_yn := 'N';
        END IF;
      END IF;
    END IF;

    IF (l_delete_flag = 'Y') THEN
       -- Delete reporting asset tax book
       l_rep_book_type := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
           i := 0;
           If nvl(l_rep_book_type,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR then
               open l_txd_csr (p_book_type_code  => l_rep_book_type,
                               p_chr_id          => l_chrv_rec.id);
               Loop
                   fetch l_txd_csr into l_txd_rec;
                   exit when l_txd_csr%NOTFOUND;
                   i := i+1;
                   l_adpv_tbl(i).id := l_txd_rec.id;
               end Loop;
               close l_txd_csr;

               If l_adpv_tbl.COUNT <> 0 then
                   OKL_TXD_ASSETS_PUB.delete_txd_asset_Def(
                       p_api_version         => p_api_version,
                       p_init_msg_list       => p_init_msg_list,
                       x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data,
                       p_adpv_tbl            => l_adpv_tbl);
                   If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                       raise OKL_API.G_EXCEPTION_ERROR;
                   End If;
               End If;
          End If;

    END IF;
   -- Bug 7610725 end

    --
    If l_chrv_rec.start_date = OKL_API.G_MISS_DATE Then
       l_chrv_rec.start_date := l_orig_chr_rec.start_date;
    End If;
    --

    If l_khrv_rec.term_duration = OKL_API.G_MISS_NUM  and
       l_orig_khr_rec.term_duration is not null Then
       l_khrv_rec.term_duration := l_orig_khr_rec.term_duration;
    End If;
    --
    --Bug Fix# 2860122 start.
    --SandO fix for end date
    IF (l_chrv_rec.end_date = OKL_API.G_MISS_DATE) Then
       IF (l_chrv_rec.start_date is NOT NULL and
          l_chrv_rec.start_date <> OKL_API.G_MISS_DATE) and
          (l_khrv_rec.term_duration is not NULL and
          l_khrv_rec.term_duration <> OKL_API.G_MISS_NUM) Then
	   --Added for bug 6007644
           l_chrv_rec.end_date := OKL_LLA_UTIL_PVT.calculate_end_date(p_start_date => l_chrv_rec.start_date,
                                                                      p_months     => l_khrv_rec.term_duration);
         --end bug 6007644
       ELSE
           l_chrv_rec.end_date := l_orig_chr_rec.end_date;
       END IF;
    END IF;
    -- Bug Fix # 2860122 End.
    --
    If l_chrv_rec.currency_code = OKL_API.G_MISS_CHAR Then
       l_chrv_rec.currency_code := l_orig_chr_rec.currency_code;
    End If;

    --
    -- call to check if term modification is allowed and cascade it onto existing lines
    ---
    --Bug # 11.5.9 : modified to take care of currency modification during rebooks
    term_modfn( p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_chr_id         => l_chrv_rec.id,
                p_new_start_date => l_chrv_rec.start_date,
                p_new_end_date   => l_chrv_rec.end_date,
                p_new_term       => l_khrv_rec.term_duration,
				p_new_pdt_id     => l_khrv_rec.pdt_id, -- Bug# 9115610
                x_modfn_mode     => l_modfn_mode);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    ----------------------------------------------------------------------------
    --call to check if template modification is allowed
    ----------------------------------------------------------------------------
    template_create_allowed(p_chr_id        => l_chrv_rec.id,
                            p_template_yn   => l_chrv_rec.template_yn,
                            x_return_status => x_return_status);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                           p_msg_name => G_TEMPLATE_CREATE_NOT_ALLOWED);
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency
    ----------------------------------------------------------------------------
    If (l_chrv_rec.currency_code = OKL_API.G_MISS_CHAR) Then
       l_chrv_rec.currency_code := l_orig_chr_rec.currency_code;
    End If;

    If (l_khrv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR) and
       l_orig_khr_rec.currency_conversion_type is not null Then
       l_khrv_rec.currency_conversion_type := l_orig_khr_rec.currency_conversion_type;
    End If;

    If (l_khrv_rec.currency_conversion_rate = OKL_API.G_MISS_NUM) and
       l_orig_khr_rec.currency_conversion_rate is not null Then
       l_khrv_rec.currency_conversion_rate := l_orig_khr_rec.currency_conversion_rate;
    End If;

    If (l_khrv_rec.currency_conversion_date = OKL_API.G_MISS_DATE) and
       l_orig_khr_rec.currency_conversion_date is not null Then
       l_khrv_rec.currency_conversion_date := l_orig_khr_rec.currency_conversion_date;
    End If;

    If (l_chrv_rec.start_date = OKL_API.G_MISS_DATE) Then
       l_chrv_rec.start_date := l_orig_chr_rec.start_date;
    End If;

    If (l_chrv_rec.scs_code = OKL_API.G_MISS_CHAR) Then
       l_chrv_rec.scs_code := l_orig_chr_rec.scs_code;
    End If;

    --Bug# 3180583
    If (l_khrv_rec.multi_gaap_yn = OKL_API.G_MISS_CHAR) then
        l_khrv_rec.multi_gaap_yn := l_orig_khr_rec.multi_gaap_yn;
    End If;

    -- AKP:Check if start_date is changed default interest_start_date,
    --rate_change_start_date and catchup_start_date
    IF ((l_chrv_rec.start_date <> l_orig_chr_rec.start_date) AND
        (l_chrv_rec.scs_code = 'LEASE') ) THEN
      okl_k_rate_params_pvt.cascade_contract_start_date
              ( p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_chr_id         => l_chrv_rec.id,
                p_new_start_date => l_chrv_rec.start_date);
      -- check return status
      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
            raise OKL_API.G_EXCEPTION_ERROR;
      End If;
    END IF;

    -- now go in to validate currency
    validate_currency(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      x_return_status => x_return_status,
                      p_chrv_rec      => l_chrv_rec,
                      p_khrv_rec      => l_khrv_rec,
                      x_chrv_rec      => l_curr_chrv_rec,
                      x_khrv_rec      => l_curr_khrv_rec);
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_chrv_rec := l_curr_chrv_rec;
    l_khrv_rec := l_curr_khrv_rec;
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency End
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Product Validations
    ----------------------------------------------------------------------------
    --For older contracts do not check for product validation unless product has changed
    --therefore commenting this code below :
    --If l_khrv_rec.pdt_id = OKL_API.G_MISS_NUM Then
    --    l_khrv_rec.pdt_id := l_orig_chr_rec.pdt_id;
    --End If;

    If (l_chrv_rec.start_date = OKL_API.G_MISS_DATE) Then
       l_chrv_rec.start_date := l_orig_chr_rec.start_date;
    End If;


    --For older contracts do not check for product validation unless product has changed
    --therefore commenting adding the G_MISS clause in IF below :

    If (l_khrv_rec.pdt_id is  null) OR (l_khrv_rec.pdt_id = OKL_API.G_MISS_NUM ) OR
       (l_khrv_rec.pdt_id = l_orig_khr_rec.pdt_id)  then
        null;
    Else
        --Begin (Bug# 2730633)
        --Fix for not to validate for copied contracts being copied from contracts
        --which have 11.5.8 products against them
        l_bypass_pdt_validation := 'N';
        If nvl(l_orig_chr_rec.orig_system_source_code,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR AND
           nvl(l_orig_chr_rec.orig_system_id1,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM Then
           l_bypass_pdt_validation := Is_Orig_Pdt_old(p_orig_chr_id => l_orig_chr_rec.orig_system_id1,
                                                      p_pdt_id      => l_khrv_rec.pdt_id);
        End If;
        --Fix for not to validate for copied contracts being copied from contracts
        --which have 11.5.8 products against them
        --End (Bug# 2730633)
        If l_bypass_pdt_validation = 'N' Then
            Validate_Product(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_chrv_rec      => l_chrv_rec,
                             p_pdt_id        => l_khrv_rec.pdt_id,
                             x_deal_type     => l_pdt_deal_type,
                             x_tax_owner     => l_pdt_tax_owner,
                             --Bug# 3180583
                             x_multigaap_yn  => l_multigaap_yn);

            -- check return status
            If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                    raise OKL_API.G_EXCEPTION_ERROR;
            End If;

            --for lease contracts deal type has to come from product
            If l_chrv_rec.scs_code in ('LEASE','QUOTE') Then
                 --Bug# 2809358
                 --If l_khrv_rec.deal_type <> l_pdt_deal_type Then
                 If nvl(l_khrv_rec.deal_type,'DEALTYPE') <> l_pdt_deal_type Then
                     --If l_pdt_deal_type is not null OR
                     If l_pdt_deal_type is not null AND
                       l_pdt_deal_type <> OKL_API.G_MISS_CHAR Then
                          l_khrv_rec.deal_type := l_pdt_deal_type;
                     End If;
                 End If;

                 --------------
                 --Bug# 3180583
                 -------------
                 If nvl(l_multigaap_yn,OKL_API.G_MISS_CHAR)  = 'N' then
                     If nvl(l_khrv_rec.multi_gaap_yn,OKL_API.G_MISS_CHAR) = 'Y' then
                          l_khrv_rec.multi_gaap_yn := NULL;
                     End If;
                 ELSIf nvl(l_multigaap_yn,'N')  = 'Y' then  -- 7610725
                          l_khrv_rec.multi_gaap_yn := 'Y';
                 End If;
                 --------------
                 --Bug# 3180583
                 -------------

                --Bug# 3379294 : check if deal type is still Null then raise error for lease and quote
                 If nvl(l_khrv_rec.deal_type,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
                     OKL_API.Set_Message(p_app_name => G_APP_NAME,
                                         p_msg_name => 'OKL_NULL_DEAL_TYPE');
                     x_return_status := OKL_API.G_RET_STS_ERROR;
                     raise OKL_API.G_EXCEPTION_ERROR;
                 End If;
                 --Bug# 3379294 : End

            End If;
        End If;
    End If;
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Product validations
    ----------------------------------------------------------------------------
--Added by dpsingh
      l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_chrv_rec.id) ;

  --rkuttiya commented out for bug 6595451
  --validation on null legal entity id not required for update contract
     /*IF (l_khrv_rec.legal_entity_id IS NULL ) THEN
            IF l_chrv_rec.scs_code IN ('LEASE','LOAN','INVESTOR', 'MASTER_LEASE','PROGRAM') THEN
	      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'legal_entity_id');
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	    END IF;*/
     IF( (l_khrv_rec.legal_entity_id <> Okl_Api.G_MISS_NUM) AND  (l_legal_entity_id <> l_khrv_rec.legal_entity_id)) THEN
            OKL_LA_VALIDATION_UTIL_PVT.VALIDATE_LEGAL_ENTITY(x_return_status => x_return_status,
                                                                                                          p_chrv_rec      => l_chrv_rec,
													  p_mode => 'UPD');
             l_upd_trx_assets := 1;
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
      END IF ;
  --Added by dpsingh end

    --Should not go in and validate for previous records

    --
    -- call procedure in complex API
    --
--    OKC_CONTRACT_PUB.update_contract_header(

     okl_okc_migration_pvt.update_contract_header(
         p_api_version            => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_restricted_update    => p_restricted_update,
         p_chrv_rec                        => l_curr_chrv_rec,
         x_chrv_rec                        => x_chrv_rec);

    -- check return status
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
     --Added by dpsingh for LE Uptake
    ELSIF  x_return_status = OKL_API.G_RET_STS_SUCCESS AND l_upd_trx_assets = 1 THEN
         FOR get_con_line_ids_rec IN get_con_line_ids_csr(l_chrv_rec.id) LOOP
            l_tasv_rec.id :=  get_con_line_ids_rec.tas_id;
            l_tasv_rec.legal_entity_id := l_legal_entity_id;
	    OKL_TRX_ASSETS_PVT.UPDATE_TRX_ASS_H_DEF(p_api_version ,
                                                                                               p_init_msg_list ,
                                                                                               x_return_status ,
                                                                                               x_msg_count ,
                                                                                               x_msg_data  ,
                                                                                               l_tasv_rec ,
                                                                                               x_tasv_rec) ;

	       IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
	       END IF;
          END LOOP;
    END IF;
    /*Bug# 3124577: 11.5.10 Rule Migration:-----------------------------------------------------------
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency, Create CURRENCY Rule
    ----------------------------------------------------------------------------
    --Create OKC currency rule for contract currency different from functional currency
    --Removed as OKC CVN rule need not be created after 11.5.10 rules migration
    ----------------------------------------------------------------------------
    --Bug# : 11.5.9 Enhancement Multi Currency, Create CURRENCY Rule
    ----------------------------------------------------------------------------
    ---------------------------------------Bug# 3124577 -Rule Migration 11.5.10-----------*/

     --If does not satisfy above clause stamp header dates on to lines
  If l_modfn_mode in ('L','R') Then
      --Bug# 2821383
      Open top_cle_csr(p_chr_id => x_chrv_rec.id);
      Loop
          Fetch top_cle_csr into l_top_cle_id;
          Exit when top_cle_csr%NOTFOUND;

          Open cle_csr (p_cle_id => l_top_cle_id);
          --Open cle_csr (p_chr_id => x_chrv_rec.id);
          Loop
              Fetch Cle_Csr into l_cle_id,
                                 l_cle_start_date,
                                 l_cle_end_date,
                                 l_parent_cle_id,
                                 --Bug# : subsidy
                                 l_lse_id;

              Exit When Cle_Csr%NOTFOUND;

              l_clev_rec.id         := l_cle_id;
              l_clev_rec.start_date := l_cle_start_date;
              l_clev_rec.end_date   := l_cle_end_date;

              --Bug#: Subsidy
              l_lty_code := Null;
              open l_ltycd_csr (p_lse_id => l_lse_id);
              fetch l_ltycd_csr into l_lty_code;
              If l_ltycd_csr%NOTFOUND then
                  Null;
              End If;
              close l_ltycd_csr;


              -----------------------------------------------------------------------------------------------------
              --Bug# 3143522: Subsidy - segregated date stamping logic for fee,service and subsidy from rest of the lines
              --       because of different natures of these lines
              ---------------------------------------------------------------------------------------------------e
              If nvl(l_lty_code,'XXXX') not in('FEE','SOLD_SERVICE','LINK_FEE_ASSET','LINK_SERV_ASSET','SUBSIDY') then
                  --Bug # 2691029 : modify line start date only if line start date is
                  -- is less than or equal to new header start date
                  ----------------------------------------------------------------
                  --start date logic for lines other than FEE, SERVICE and SUBSIDY
                  ----------------------------------------------------------------
                  If l_modfn_mode = 'R' then
                      --bug# 2821383
                      l_rbk_cpy := 'N';
                      l_rbk_cpy := Is_rebook_Copy(p_chr_id => x_chrv_rec.id);
                      If l_rbk_cpy = 'Y' then
                          If l_parent_cle_id is not null then
                              If l_cle_start_date <= x_chrv_rec.start_date then
                                  l_clev_rec.start_date := x_chrv_rec.start_date;
                              elsif l_cle_start_date > x_chrv_rec.start_date then
                                  --get the dates from parent lines
                                  Open parent_cle_csr(p_cle_id => l_parent_cle_id);
                                  Fetch parent_cle_csr into
                                                       l_parent_cle_start_date,
                                                       l_parent_cle_end_date;
                                  If parent_cle_csr%NOTFOUND then
                                      null;
                                  Else
                                      If trunc(l_clev_rec.start_date) = trunc(l_parent_cle_start_date) then
                                          --do not change the line date (do not stamp header date on line)
                                          null;
                                      Else
                                          --change line start date
                                          If trunc(l_parent_cle_start_date) <= trunc(x_chrv_rec.start_date) then
                                              l_clev_rec.start_date := x_chrv_rec.start_date;
                                          Elsif trunc(l_parent_cle_start_date) > trunc(x_chrv_rec.start_date) then
                                              l_clev_rec.start_date := l_parent_cle_start_date;
                                          End If;
                                      End If;
                                  End If;
                                  Close parent_cle_csr;
                              End If; --cle_start date > header date

                          elsif l_parent_cle_id is null then
                              null;
                          end if;
                      Elsif l_rbk_cpy = 'N' then
                          If l_cle_start_date <= x_chrv_rec.start_date then
                              l_clev_rec.start_date := x_chrv_rec.start_date;
                          elsif l_cle_start_date > x_chrv_rec.start_date then
                              null;
                          end if;
                      End If;

                  elsif l_modfn_mode = 'L' then
                      l_clev_rec.start_date := x_chrv_rec.start_date;
                  end if;
                  ----------------------------------------------------------------
                  --end of start date logic for lines other than FEE, SERVICE and SUBSIDY
                  ----------------------------------------------------------------

                  ---------------------------------------------------------------
                  --End date logic for lines other than FEE, SERVICE and SUBSIDY
                  --------------------------------------------------------------
                  l_clev_rec.end_date   := x_chrv_rec.end_date;
                  ---------------------------------------------------------------
                  --end of End date logic for lines other than FEE, SERVICE and SUBSIDY
                  --------------------------------------------------------------

              ---------------------------------------------------------------------------------------------
              --Bug#3143522 :subsidy special logic for fee and service lines which may end and start on any dates
              --      between contract dates
              ---------------------------------------------------------------------------------------------
              ElsIf nvl(l_lty_code,'XXXX') in ('FEE','SOLD_SERVICE','LINK_FEE_ASSET','LINK_SERV_ASSET') then

                  --------------------------------------------------------
                  --New code added along with bug fix 3180583 to take care of
                  --fee and service lines during re-books :
                  /*--------new code-------------------------------------*/
                  If l_modfn_mode = 'R' then
                      --bug# 2821383
                      l_rbk_cpy := 'N';
                      l_rbk_cpy := Is_rebook_Copy(p_chr_id => x_chrv_rec.id);
                      If l_rbk_cpy = 'Y' then
                          If l_parent_cle_id is not null then
                              Open parent_cle_csr(p_cle_id => l_parent_cle_id);
                                  Fetch parent_cle_csr into
                                                       l_parent_cle_start_date,
                                                       l_parent_cle_end_date;
                                  If parent_cle_csr%NOTFOUND then
                                      null;
                                  End If;
                              Close parent_cle_csr;

                              If (l_cle_start_date <= x_chrv_rec.start_date) OR
                                  (l_cle_start_date > x_chrv_rec.end_date) then
                                  l_clev_rec.start_date := x_chrv_rec.start_date;
                              elsif (l_cle_start_date > x_chrv_rec.start_date) AND
                                     (l_cle_start_date <= x_chrv_rec.end_date) then
                                  --get the dates from parent lines
                                  If nvl(l_parent_cle_start_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
                                      null;
                                  Else
                                      If trunc(l_clev_rec.start_date) = trunc(l_parent_cle_start_date) then
                                          --do not change the line date (do not stamp header date on line)
                                          null;
                                      Else
                                          --change line start date
                                          If trunc(l_parent_cle_start_date) <= trunc(x_chrv_rec.start_date) then
                                              l_clev_rec.start_date := x_chrv_rec.start_date;
                                          Elsif trunc(l_parent_cle_start_date) > trunc(x_chrv_rec.start_date) then
                                              l_clev_rec.start_date := l_parent_cle_start_date;
                                          End If;
                                      End If;
                                  End If;
                              End If; --cle_start date > header date

                              If (l_cle_end_date >= x_chrv_rec.end_date) OR
                                 (l_cle_end_date < x_chrv_rec.start_date)  then
                                  l_clev_rec.end_date := x_chrv_rec.end_date;
                              ElsIf (l_cle_end_date < x_chrv_rec.end_date)
                                  and (l_cle_end_date >=  x_chrv_rec.start_date) then
                                  --get the dates from parent lines
                                  If nvl(l_parent_cle_end_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
                                      null;
                                  Else
                                      If trunc(l_clev_rec.end_date) = trunc(l_parent_cle_end_date) then
                                          --do not change the line date (do not stamp header date on line)
                                          null;
                                      Else
                                          --change line start date
                                          If trunc(l_parent_cle_end_date) > trunc(x_chrv_rec.end_date) then
                                              l_clev_rec.end_date := x_chrv_rec.end_date;
                                          Elsif trunc(l_parent_cle_end_date) <= trunc(x_chrv_rec.end_date) then
                                              l_clev_rec.end_date := l_parent_cle_end_date;
                                          End If;
                                      End If;
                                  End If;
                              End If; --cle_end date < header end date

                          elsif l_parent_cle_id is null then
                              null;
                          end if;

                      Elsif l_rbk_cpy = 'N' then
                          -------------------------------------------
                          --start date logic for fee and service lines
                          -------------------------------------------
                          If (l_cle_start_date < x_chrv_rec.start_date) OR (l_cle_start_date > x_chrv_rec.end_date) then
                              l_clev_rec.start_date := x_chrv_rec.start_date;
                          ElsIf (l_cle_start_date >= x_chrv_rec.start_date) And (l_cle_start_date <= x_chrv_rec.end_date) then
                               NULL;
                          End If;
                          --------------------------------------------
                          --end of start date logic for fee and service
                          -------------------------------------------
                          ---------------------------------------------
                          --end date logic for fee and service
                          ---------------------------------------------
                          If (l_cle_end_date > x_chrv_rec.end_date) OR (l_cle_end_date < x_chrv_rec.start_date)  then
                              l_clev_rec.end_date := x_chrv_rec.end_date;
                          ElsIf (l_cle_end_date <= x_chrv_rec.end_date) and (l_cle_end_date >=  x_chrv_rec.start_date) then
                              NULL;
                          End If;
                          --------------------------------------------
                          --end of end date logic for fee and service
                          -------------------------------------------

                      End If;

                  elsif l_modfn_mode = 'L' then
                      ---------------------------------------------
                      --start date logic for fee and service lines
                      ---------------------------------------------
                      If (l_cle_start_date < x_chrv_rec.start_date) OR (l_cle_start_date > x_chrv_rec.end_date) then
                          l_clev_rec.start_date := x_chrv_rec.start_date;
                      ElsIf (l_cle_start_date >= x_chrv_rec.start_date) And (l_cle_start_date <= x_chrv_rec.end_date) then
                          NULL;
                      End If;
                      --------------------------------------------
                      --end of start date logic for fee and service
                      -------------------------------------------
                      ---------------------------------------------
                      --end date logic for fee and service
                      ---------------------------------------------
                      If (l_cle_end_date > x_chrv_rec.end_date) OR (l_cle_end_date < x_chrv_rec.start_date)  then
                          l_clev_rec.end_date := x_chrv_rec.end_date;
                      ElsIf (l_cle_end_date <= x_chrv_rec.end_date) and (l_cle_end_date >=  x_chrv_rec.start_date) then
                          NULL;
                      End If;
                      --------------------------------------------
                      --end of end date logic for fee and service
                      -------------------------------------------
                  end if;
                  /*---------------------end of new code--------------------*/

              ----------------------------------------------------------------------------------------------
              --Bug#3143522 : Subsidy special logic for subsidy line which starts with the parent line but may end
              --       prior to contract/parent line end date based on maximum-term in subsidy setup
              ---------------------------------------------------------------------------------------------
              ElsIf nvl(l_lty_code,'XXX') = 'SUBSIDY' then
                  -- follow the same logic for normal asset lines for start date

                  -----------------------------------------------------------------------------------
                  -- start date logic for subsidy lines : exactly copied from above (for asset lines)
                  -----------------------------------------------------------------------------------
                  If l_modfn_mode = 'R' then
                      --bug# 2821383
                      l_rbk_cpy := 'N';
                      l_rbk_cpy := Is_rebook_Copy(p_chr_id => x_chrv_rec.id);
                      If l_rbk_cpy = 'Y' then
                          If l_parent_cle_id is not null then
                              If l_cle_start_date <= x_chrv_rec.start_date then
                                  l_clev_rec.start_date := x_chrv_rec.start_date;
                              elsif l_cle_start_date > x_chrv_rec.start_date then
                                  --get the dates from parent lines
                                  Open parent_cle_csr(p_cle_id => l_parent_cle_id);
                                  Fetch parent_cle_csr into
                                                       l_parent_cle_start_date,
                                                       l_parent_cle_end_date;
                                  If parent_cle_csr%NOTFOUND then
                                      null;
                                  Else
                                      If trunc(l_clev_rec.start_date) = trunc(l_parent_cle_start_date) then
                                          --do not change the line date (do not stamp header date on line)
                                          null;
                                      Else
                                          --change line start date
                                          If trunc(l_parent_cle_start_date) <= trunc(x_chrv_rec.start_date) then
                                              l_clev_rec.start_date := x_chrv_rec.start_date;
                                          Elsif trunc(l_parent_cle_start_date) > trunc(x_chrv_rec.start_date) then
                                              l_clev_rec.start_date := l_parent_cle_start_date;
                                          End If;
                                      End If;
                                  End If;
                                  Close parent_cle_csr;
                              End If; --cle_start date > header date

                          elsif l_parent_cle_id is null then
                              null;
                          end if;
                      Elsif l_rbk_cpy = 'N' then
                          If l_cle_start_date <= x_chrv_rec.start_date then
                              l_clev_rec.start_date := x_chrv_rec.start_date;
                          elsif l_cle_start_date > x_chrv_rec.start_date then
                              null;
                          end if;
                      End If;

                  elsif l_modfn_mode = 'L' then
                      l_clev_rec.start_date := x_chrv_rec.start_date;
                  end if;
                  ---------------------------------------------------
                  --end of start date logic for subsidy lines
                  ---------------------------------------------------

                  ---------------------------------------------------
                  --start of end date logic for subsidy lines
                  --------------------------------------------------
                  l_max_subsidy_term := null;
                  open l_sub_csr(p_cle_id => l_cle_id);
                      fetch l_sub_csr into l_max_subsidy_term;
                      If l_sub_csr%NOTFOUND then
                          null;
                      End If;
                  close l_sub_csr;
                  If nvl(l_max_subsidy_term,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM  then
                      l_clev_rec.end_date := x_chrv_rec.end_date;
                  Elsif l_max_subsidy_term  <= 0 then
                      l_clev_rec.end_date := l_clev_rec.start_date;
                  Elsif l_max_subsidy_term > 0 then
                      l_clev_rec.end_date := add_months(l_clev_rec.start_date,l_max_subsidy_term) - 1;
                      If l_clev_rec.end_date > x_chrv_rec.end_date then
                          l_clev_rec.end_date := x_chrv_rec.end_date;
                      End If;
                  End If;
                  ---------------------------------------------------
                  --end of end date logic for subsidy lines
                  ---------------------------------------------------

              End If; --lty code not service fee or subsidy


              okl_okc_migration_pvt.update_contract_line(
                   p_api_version        => p_api_version,
                   p_init_msg_list        => p_init_msg_list,
                   x_return_status         => x_return_status,
                   x_msg_count             => x_msg_count,
                   x_msg_data              => x_msg_data,
                   p_clev_rec                => l_clev_rec,
                   x_clev_rec                => lx_clev_rec);

               -- check return status
               If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                   raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                   raise OKL_API.G_EXCEPTION_ERROR;
               End If;
           End Loop;
           Close Cle_Csr;
        End Loop;
        Close top_cle_csr;
    Elsif l_modfn_mode = 'N' Then
        Null;
    End If;

    -- Bug# 6438785
    -- When the contract start date is changed, update the
    -- start dates for all payments based on the new contract or
    -- line start dates
    IF ((l_chrv_rec.start_date <> l_orig_chr_rec.start_date) AND
        (l_chrv_rec.scs_code = 'LEASE') ) THEN

      OKL_LA_PAYMENTS_PVT.update_pymt_start_date
        (p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_chr_id         => l_chrv_rec.id);

      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

    END IF;
    -- Bug# 6438785

    -- get id from OKC record
    l_khrv_rec.ID := x_chrv_rec.ID;

    -- check whether the shadow is present
    open l_khrv_csr(l_khrv_rec.id);
        fetch l_khrv_csr into l_dummy_var;
    close l_khrv_csr;

    -- call procedure in complex API
    -- if l_dummy_var is changed then the shadow is present
    -- and we need to update it, otherwise we need to create the shadow
    if (l_dummy_var = 'x') THEN
        OKL_KHR_PVT.Update_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khrv_rec          => l_khrv_rec,
            x_khrv_rec          => x_khrv_rec);
    else
        OKL_KHR_PVT.Insert_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khrv_rec          => l_khrv_rec,
            x_khrv_rec          => x_khrv_rec);
    end if;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If p_edit_mode = 'Y' Then
    --Added for updating header status if required and cascading to lines
    If (x_khrv_rec.id is not null) OR (x_khrv_rec.id <> OKL_API.G_MISS_NUM) Then
        okl_contract_status_pub.cascade_lease_status_edit
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => x_khrv_rec.id);

        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
        End If;
    End If;
    End If;

  -- 4722839. Create zero interest schedules for LOAN (FLOAT, CATCHUP/CLEANUP)
  --          And LOAN-REVOLVING (FLOAT).

  OKL_K_RATE_PARAMS_PVT.get_product(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_khr_id        => x_khrv_rec.ID,
          x_pdt_parameter_rec => l_pdt_parameter_rec);

  l_interest_calculation_basis :=l_pdt_parameter_rec.interest_calculation_basis;
  l_revenue_recognition_method :=l_pdt_parameter_rec.revenue_recognition_method;
  l_deal_type := l_pdt_parameter_rec.deal_type;

  --okl_debug_pub.logmessage('update_contract_header: l_deal_type=' || l_deal_type);
  --okl_debug_pub.logmessage('update_contract_header: l_interest_calculation_basis=' || l_interest_calculation_basis);
  IF (l_deal_type = 'LOAN' AND
      --l_interest_calculation_basis IN ('FLOAT', 'CATCHUP/CLEANUP')) OR
      l_interest_calculation_basis = 'FLOAT') OR
    (l_deal_type = 'LOAN-REVOLVING' AND
     l_interest_calculation_basis = 'FLOAT') THEN
    OKL_LA_PAYMENTS_PVT.VARIABLE_INTEREST_SCHEDULE (
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_chr_id        => l_khrv_rec.ID,
          x_rulv_tbl      => x_rulv_tbl
    );

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

  END IF;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      if l_khrv_csr%ISOPEN then
          close l_khrv_csr;
        end if;

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      if l_khrv_csr%ISOPEN then
          close l_khrv_csr;
        end if;

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      if l_khrv_csr%ISOPEN then
          close l_khrv_csr;
        end if;

  END update_contract_header;

-- Start of comments
--
-- Procedure Name  : update_contract_header
-- Description     : updates contract header for shadowed contract  will be called
--                   from updation of streams after stream generation
--                   This will not flip the contract status
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;


  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;


     update_contract_header(
             p_api_version        => p_api_version,
             p_init_msg_list        => p_init_msg_list,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
         p_restricted_update    => p_restricted_update,
             p_chrv_rec                => l_chrv_rec,
         p_khrv_rec     => l_khrv_rec,
         p_edit_mode    => 'Y',
             x_chrv_rec                => x_chrv_rec,
         x_khrv_rec     => x_khrv_rec
         );

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;


    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_contract_header;


-- Start of comments
--
-- Procedure Name  : update_contract_header
-- Description     : creates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okl_okc_migration_pvt.chrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_khrv_tbl                  khrv_tbl_type := p_khrv_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
           i := p_chrv_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                update_contract_header(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_restricted_update    => p_restricted_update,
                        p_chrv_rec                => p_chrv_tbl(i),
                        p_khrv_rec                => l_khrv_tbl(i),
                        x_chrv_rec                => x_chrv_tbl(i),
                        x_khrv_rec                => x_khrv_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_contract_header;


-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Procedure Name       : delete_contracte
-- Description          : delete of the contract
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE delete_contract(
          p_api_version      IN  NUMBER,
          p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER,
          x_msg_data         OUT NOCOPY VARCHAR2,
          p_contract_id      IN  okc_k_headers_b.id%TYPE) IS

    SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE;
    SUBTYPE khrv_rec_type IS OKL_CONTRACT_PUB.KHRV_REC_TYPE;
    G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
    G_APP_NAME                  CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
    G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
    G_PKG_NAME                  CONSTANT  VARCHAR2(200) := 'OKL_OPEN_INTERFACE_PVT';
    G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_CANNOT_DELETE VARCHAR2(200) := 'OKC_CANNOT_DELETE';
  G_TABLE_NAME_TOKEN VARCHAR2(200) := 'TABLE_NAME';
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN VARCHAR2(200) := 'SQLerrm';

    l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT';
    l_chrv_rec2              OKC_CONTRACT_PUB.chrv_rec_type;
    l_chrv_rec               chrv_rec_type;
    l_khrv_rec               khrv_rec_type;
    l_tcnv_rec               OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    lx_tcnv_rec              OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    l_stmv_rec               OKL_STREAMS_PUB.stmv_rec_type;
    r_tcnv_rec               OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
    l_sts_code               OKC_K_HEADERS_B.STS_CODE%TYPE;

    l_orig_system_source_code okc_k_headers_b.orig_system_source_code%type;
    l_contract_number okc_k_headers_b.contract_number%type;
    l_funding_count number := 0;
    l_chr_ever_booked varchar2(1);
    l_chr_invoices varchar2(1);
    l_receipts_csr number;
    l_authoring_org_id NUMBER; --CDUBEY l_authoring_org_id added for MOAC

    CURSOR check_receipts_csr(p_id number) IS
    SELECT 'Y'
    FROM   okl_trx_ar_invoices_b
    WHERE khr_id = p_id
    AND   trx_status_code <> 'ERROR'
    AND   rownum < 2;

    CURSOR Ever_Booked_crs(p_id number) IS
    SELECT 'Y'
    FROM   okc_k_headers_bh chrh,
           okc_k_headers_b chr
    WHERE  chrh.contract_number = chr.contract_number
    AND    chr.id = p_id
    AND    chrh.sts_code = G_OKL_BOOKED_STS_CODE
    AND    rownum < 2;

    CURSOR c_get_k_stream(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id stm_id
    FROM OKL_STREAMS
    WHERE khr_id = p_khr_id;

    CURSOR c_get_je_trans(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id trx_id
    FROM OKL_TRX_CONTRACTS
    WHERE khr_id = p_khr_id
    AND   representation_type = 'PRIMARY';

    CURSOR c_get_source_id(p_khr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE khr_id = p_khr_id;

    CURSOR c_get_k_top_line(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id top_line
    FROM okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.cle_id IS NULL
    AND cle.chr_id = cle.dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lse_parent_id IS NULL
    AND lse.lse_type = G_TLS_TYPE;

    -- To get the orig system id for p_chr_id
    CURSOR get_sts_code(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT sts_code, orig_system_source_code, contract_number,authoring_org_id --CDUBEY authoring_org_id added for MOAC
    FROM okc_k_headers_b
    WHERE id = p_chr_id;


FUNCTION DELETE_GOVERNANCES( p_chr_id number) Return varchar2 IS
  l_return_status varchar2(30);
  l_gvev_tbl_in okc_contract_pub.gvev_tbl_type;

  CURSOR l_gvev_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_GOVERNANCES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_gvev_csr(p_chr_id)
   LOOP

         l_gvev_tbl_in(1).ID := rec.id;

         okc_contract_pub.delete_governance (
                p_api_version                => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => l_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                => x_msg_data,
                p_gvev_tbl                => l_gvev_tbl_in
                );

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Governances',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_GOVERNANCES;

FUNCTION DELETE_RULE_GROUPS( p_chr_id number) Return varchar2 IS

  l_return_status varchar2(30);
  l_rgpv_tbl_in OKC_RULE_PUB.rgpv_tbl_type;

  CURSOR l_rgpv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_RULE_GROUPS_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_rgpv_csr(p_chr_id)
   LOOP
         l_rgpv_tbl_in(1).ID := rec.id;

         OKC_RULE_PUB.delete_rule_group (
                p_api_version                => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => l_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                => x_msg_data,
                p_rgpv_tbl                => l_rgpv_tbl_in
                );

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Rule Groups',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_RULE_GROUPS;

FUNCTION DELETE_K_PARTY_ROLES( p_chr_id number) Return varchar2 IS

  --Bug# 4558486
  l_cplv_tbl_in OKL_OKC_MIGRATION_PVT.cplv_tbl_type;
  l_return_status varchar2(30);

  CURSOR l_cplv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_K_PARTY_ROLES_V
     WHERE dnz_chr_id = p_id;

  --Bug# 4558486
  l_kplv_tbl_in  OKL_K_PARTY_ROLES_PVT.kplv_tbl_type;
Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_cplv_csr(p_chr_id)
   LOOP
         l_cplv_tbl_in(1).ID := rec.id;

         --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
       --              to delete records in tables
       --              okc_k_party_roles_b and okl_k_party_roles

        l_kplv_tbl_in(1).ID := l_cplv_tbl_in(1).ID;
        OKL_K_PARTY_ROLES_PVT.DELETE_K_PARTY_ROLE (
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_cplv_tbl            => l_cplv_tbl_in,
          p_kplv_tbl          => l_kplv_tbl_in
                );

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contract Party Roles',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_K_PARTY_ROLES;

FUNCTION DELETE_CONTACTS( p_chr_id number) Return varchar2 IS

  l_ctcv_tbl_in OKC_CONTRACT_PARTY_PUB.ctcv_tbl_type;
  l_return_status varchar2(30);

  CURSOR l_ctc_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_CONTACTS_V
     WHERE dnz_chr_id = p_id;

Begin
   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_ctc_csr(p_chr_id)
   LOOP

         l_ctcv_tbl_in(1).ID := rec.id;

         OKC_CONTRACT_PARTY_PUB.Delete_Contact(
                        p_api_version     => p_api_version,
                        p_init_msg_list   => p_init_msg_list,
                        x_return_status   => x_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        p_ctcv_tbl        => l_ctcv_tbl_in);

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Contacts',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_CONTACTS;

FUNCTION DELETE_RG_PARTY_ROLES( p_chr_id number) Return varchar2 IS

  l_rmpv_tbl_in OKC_RULE_PUB.rmpv_tbl_type;
  l_return_status varchar2(30);

  CURSOR l_rmpv_csr (p_id  IN NUMBER) IS
    SELECT ID
     FROM OKC_RG_PARTY_ROLES_V
     WHERE dnz_chr_id = p_id;

Begin

   l_return_status := OKC_API.G_RET_STS_SUCCESS;

   FOR rec IN l_rmpv_csr(p_chr_id)
   LOOP
         l_rmpv_tbl_in(1).ID := rec.id;

         OKC_RULE_PUB.delete_rg_mode_pty_role (
                p_api_version                => p_api_version,
                p_init_msg_list        => p_init_msg_list,
                x_return_status        => x_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                => x_msg_data,
                p_rmpv_tbl                => l_rmpv_tbl_in
                );

             If (l_return_status <> 'S') Then
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CANNOT_DELETE,
                                 p_token1       => G_TABLE_NAME_TOKEN,
                                 p_token1_value => 'Rule Group Party Roles',
                                 p_token2       => G_SQLCODE_TOKEN,
                                 p_token2_value => sqlcode,
                                 p_token3       => G_SQLERRM_TOKEN,
                                 p_token3_value => sqlerrm);
                   Exit;
                End If;
   END LOOP;
   return l_return_status;
  EXCEPTION
       -- other appropriate handlers
       When others then
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UNEXPECTED_ERROR,
                                 p_token1       => G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END DELETE_RG_PARTY_ROLES;


  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Get the Orig system id1
    OPEN  get_sts_code(p_chr_id => p_contract_id);
    FETCH get_sts_code INTO l_sts_code,
                            l_orig_system_source_code,
                            l_contract_number,
			    l_authoring_org_id; --CDUBEY l_authoring_org_id added for MOAC
    IF get_sts_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_chr_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_sts_code;

    -- Check rebook copy contract
    if (nvl(l_orig_system_source_code, 'N') = 'OKL_REBOOK') then
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_DELETE_CONT_RBK_ERROR,
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value =>  l_contract_number);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Check if funding txn exists
    l_funding_count := 0;
    -- sjalasut, added okl_txl_ap_inv_lns_all_b as part of OKLR12B disbursements project
    -- also changed the reference of okl_trx_ap_invoices_v to okl_trx_ap_invoices_b
    select count(1) into l_funding_count
    from   okl_trx_ap_invoices_b a
           ,okl_txl_ap_inv_lns_all_b b
    where a.id = b.tap_id
    and  b.khr_id = p_contract_id
    and a.funding_type_code is not null
    and rownum < 2;

    if (l_funding_count > 0) then
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_DELETE_CONT_FUND_ERROR,
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value =>  l_contract_number);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

     --check if contract was ever booked
     l_chr_ever_booked := 'N';
     Open  Ever_Booked_crs(p_id => p_contract_id);
         Fetch Ever_Booked_crs into l_chr_ever_booked;

     Close Ever_Booked_crs;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_chr_ever_booked=' || l_chr_ever_booked);
     END IF;
     If nvl(l_chr_ever_booked, 'N') = 'Y' Then
         OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => G_PAST_BOOKED_KLE_DELETE);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
     End If;

     --check if contract has receivables invoices
     l_chr_invoices := 'N';
     Open  check_receipts_csr(p_id => p_contract_id);
         Fetch check_receipts_csr into l_chr_invoices;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In okl_contract_pvt.delete_contract: ' || p_contract_id || ':' || l_chr_invoices);
         END IF;

     Close check_receipts_csr;

     If nvl(l_chr_invoices, 'N') = 'Y' Then
         OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => G_DELETE_CONT_RCPT_ERROR,
                             p_token1       => 'CONTRACT_NUMBER',
                             p_token1_value =>  l_contract_number);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
     End If;

    --debug_message('l_sts_code=' || l_sts_code);
    if l_sts_code not in ('NEW', 'INCOMPLETE', 'PASSED', 'COMPLETE', 'APPROVED', 'PENDING_APPROVAL') then
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_DELETE_CONT_ERROR,
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value =>  l_contract_number,
                          p_token2       => 'STATUS',
                          p_token2_value =>  l_sts_code);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    end if;

    -- Deleting the Draft journal Entries
    FOR r_get_source_id IN c_get_source_id(p_khr_id => p_contract_id) LOOP
      OKL_ACCOUNT_DIST_PUB.DELETE_ACCT_ENTRIES(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_source_id     => r_get_source_id.id,
                            p_source_table  => 'OKL_TXL_CNTRCT_LNS');
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Deleting the transctions of the journal Entries
    FOR r_get_je_trans IN c_get_je_trans(p_khr_id => p_contract_id) LOOP
      r_tcnv_rec.id := r_get_je_trans.trx_id;
      OKL_TRX_CONTRACTS_PUB.delete_trx_contracts(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_tcnv_rec      => r_tcnv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Delete the streams for the contract
    FOR r_get_k_stream IN c_get_k_stream(p_khr_id => p_contract_id) LOOP
      l_stmv_rec.id := r_get_k_stream.stm_id;
      OKL_STREAMS_PUB.delete_streams(
                              p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_stmv_rec      => l_stmv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Delete the contract lines
    FOR r_get_k_top_line IN c_get_k_top_line(p_dnz_chr_id => p_contract_id) LOOP
      OKL_CONTRACT_PUB.delete_contract_line(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_line_id            => r_get_k_top_line.top_line);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_K_HISTORY_PUB.delete_all_rows(
                     p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     p_chr_id             => p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := DELETE_GOVERNANCES(p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := DELETE_RULE_GROUPS(p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := DELETE_CONTACTS(p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := DELETE_K_PARTY_ROLES(p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := DELETE_RG_PARTY_ROLES(p_contract_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE OKL_K_RATE_PARAMS
    WHERE  KHR_ID = p_contract_id;

    -- Now the Delete the Header

    l_chrv_rec.id := p_contract_id;
    l_chrv_rec.authoring_org_id :=l_authoring_org_id; --CDUBEY added for MOAC
    l_khrv_rec.id := p_contract_id;



    OKL_CONTRACT_PUB.delete_contract_header(
                     p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     p_chrv_rec           => l_chrv_rec,
                     p_khrv_rec           => l_khrv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    -- since we need to do this beacuse we need to delete to the contract
    --COMMIT;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_get_k_top_line%ISOPEN THEN
      CLOSE c_get_k_top_line;
    END IF;
    IF get_sts_code%ISOPEN THEN
      CLOSE get_sts_code;
    END IF;

    IF c_get_k_stream%ISOPEN THEN
      CLOSE c_get_k_stream;
    END IF;
    IF c_get_je_trans%ISOPEN THEN
      CLOSE c_get_je_trans;
    END IF;
    IF c_get_source_id%ISOPEN THEN
      CLOSE c_get_source_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_get_k_top_line%ISOPEN THEN
      CLOSE c_get_k_top_line;
    END IF;
    IF get_sts_code%ISOPEN THEN
      CLOSE get_sts_code;
    END IF;

    IF c_get_k_stream%ISOPEN THEN
      CLOSE c_get_k_stream;
    END IF;
    IF c_get_je_trans%ISOPEN THEN
      CLOSE c_get_je_trans;
    END IF;
    IF c_get_source_id%ISOPEN THEN
      CLOSE c_get_source_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_get_k_top_line%ISOPEN THEN
      CLOSE c_get_k_top_line;
    END IF;
    IF get_sts_code%ISOPEN THEN
      CLOSE get_sts_code;
    END IF;

    IF c_get_k_stream%ISOPEN THEN
      CLOSE c_get_k_stream;
    END IF;
    IF c_get_je_trans%ISOPEN THEN
      CLOSE c_get_je_trans;
    END IF;
    IF c_get_source_id%ISOPEN THEN
      CLOSE c_get_source_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END delete_contract;

-- Start of comments
--
-- Procedure Name  : delete_contract_header
-- Description     : deletes contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);


    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.delete_contract_header(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_chrv_rec                => l_chrv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- call procedure in complex API
        OKL_KHR_PVT.Delete_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khrv_rec          => p_khrv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END delete_contract_header;


-- Start of comments
--
-- Procedure Name  : delete_contract_header
-- Description     : deletes contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_khrv_tbl                  khrv_tbl_type := p_khrv_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
           i := p_chrv_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                delete_contract_header(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_chrv_rec                => p_chrv_tbl(i),
                p_khrv_rec                => l_khrv_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_contract_header;

-- Start of comments
--
-- Procedure Name  : lock_contract_header
-- Description     : locks contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);


    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.lock_contract_header(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_chrv_rec                => l_chrv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- call procedure in complex API
        OKL_KHR_PVT.lock_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khrv_rec          => p_khrv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END lock_contract_header;


-- Start of comments
--
-- Procedure Name  : lock_contract_header
-- Description     : locks contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_khrv_tbl                  khrv_tbl_type := p_khrv_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
           i := p_chrv_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                lock_contract_header(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_chrv_rec                => p_chrv_tbl(i),
                p_khrv_rec                => l_khrv_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END lock_contract_header;

-- -----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_contract_header
-- Description     : validates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

        --dbms_output.put_line('Start validation');
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

        --dbms_output.put_line('Started activity');

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);
        --dbms_output.put_line('Set up context');

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.validate_contract_header(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_chrv_rec                => l_chrv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;
        --dbms_output.put_line('Got standard validation');

    -- pass OKC contract header id
        l_khrv_rec.id := l_chrv_rec.id;

    -- call procedure in complex API
        OKL_KHR_PVT.validate_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khrv_rec          => l_khrv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;
        --dbms_output.put_line('Got shadow validation');

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
        --dbms_output.put_line('Done');
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END validate_contract_header;


-- Start of comments
--
-- Procedure Name  : validate_contract_header
-- Description     : validates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'validate_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_khrv_tbl                  khrv_tbl_type := p_khrv_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_chrv_tbl.COUNT > 0) Then
           i := p_chrv_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                validate_contract_header(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_chrv_rec                => p_chrv_tbl(i),
                p_khrv_rec                => l_khrv_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
                i := p_chrv_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END validate_contract_header;

-- Start of comments
--
-- Procedure Name  : roundoff_line_amount
-- Description     : Round off NOT NULL line amounts columns
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

   PROCEDURE roundoff_line_amount(
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_clev_rec        IN  okl_okc_migration_pvt.clev_rec_type,
                         p_klev_rec        IN  klev_rec_type,
                         x_clev_rec        OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
                         x_klev_rec        OUT NOCOPY klev_rec_type
                        ) IS

   --Fix Bug# 2727161
   CURSOR curr_hdr_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT currency_code
   FROM   okc_k_headers_b
   WHERE  id = p_chr_id;

   CURSOR curr_ln_csr (p_line_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT h.currency_code
   FROM   okc_k_headers_b h,
          okc_k_lines_b l
   WHERE  h.id = l.dnz_chr_id
   AND    l.id = p_line_id;

   l_conv_amount   NUMBER;
   l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

   roundoff_error EXCEPTION;

   BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Take original record values
     x_clev_rec := p_clev_rec;
     x_klev_rec := p_klev_rec;

     --
     -- Get currency Code
     -- Using line dnz_chr_id
     --
     l_currency_code := '?';
     OPEN curr_hdr_csr (p_clev_rec.dnz_chr_id);
     FETCH curr_hdr_csr INTO l_currency_code;
     CLOSE curr_hdr_csr;

     IF (l_currency_code = '?') THEN
         --
         -- Get currency_code
         -- Using line_id
         --
        OPEN curr_ln_csr (p_clev_rec.id);
        FETCH curr_ln_csr INTO l_currency_code;
        CLOSE curr_ln_csr;
     END IF;

     IF (l_currency_code = '?') THEN -- Fatal error, Not a valid currency_code
        RAISE roundoff_error;
     END IF;

     --dbms_output.put_line('Round off start '||l_currency_code);
     -- Round off all OKL Line Amounts
     IF (p_klev_rec.amount IS NOT NULL
         AND
         p_klev_rec.amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.amount_stake IS NOT NULL
         AND
         p_klev_rec.amount_stake<> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.amount_stake,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.amount_stake := l_conv_amount;
     END IF;

     IF (p_klev_rec.appraisal_value IS NOT NULL
         AND
         p_klev_rec.appraisal_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.appraisal_value,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.appraisal_value := l_conv_amount;
     END IF;

     IF (p_klev_rec.capital_amount IS NOT NULL
         AND
         p_klev_rec.capital_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.capital_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.capital_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.capital_reduction IS NOT NULL
         AND
         p_klev_rec.capital_reduction <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.capital_reduction,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.capital_reduction := l_conv_amount;
     END IF;

     IF (p_klev_rec.capitalized_interest IS NOT NULL
         AND
         p_klev_rec.capitalized_interest <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.capitalized_interest,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.capitalized_interest := l_conv_amount;
     END IF;

     IF (p_klev_rec.coverage IS NOT NULL
         AND
         p_klev_rec.coverage <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.coverage,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.coverage := l_conv_amount;
     END IF;

     IF (p_klev_rec.estimated_oec IS NOT NULL
         AND
         p_klev_rec.estimated_oec <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.estimated_oec,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.estimated_oec := l_conv_amount;
     END IF;

     IF (p_klev_rec.fee_charge IS NOT NULL
         AND
         p_klev_rec.fee_charge <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.fee_charge,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.fee_charge := l_conv_amount;
     END IF;

     IF (p_klev_rec.floor_amount IS NOT NULL
         AND
         p_klev_rec.floor_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.floor_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.floor_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.initial_direct_cost IS NOT NULL
         AND
         p_klev_rec.initial_direct_cost <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.initial_direct_cost,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.initial_direct_cost := l_conv_amount;
     END IF;

     IF (p_klev_rec.lao_amount IS NOT NULL
         AND
         p_klev_rec.lao_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.lao_amount,
                                          p_currency_code => p_clev_rec.currency_code
                                         );

         x_klev_rec.lao_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.lrv_amount IS NOT NULL
         AND
         p_klev_rec.lrv_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.lrv_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.lrv_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.net_rentable IS NOT NULL
         AND
         p_klev_rec.net_rentable <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.net_rentable,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.net_rentable := l_conv_amount;
     END IF;

     IF (p_klev_rec.oec IS NOT NULL
         AND
         p_klev_rec.oec <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.oec,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.oec := l_conv_amount;

     END IF;

     IF (p_klev_rec.refinance_amount IS NOT NULL
         AND
         p_klev_rec.refinance_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.refinance_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.refinance_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.remarketed_amount IS NOT NULL
         AND
         p_klev_rec.remarketed_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.remarketed_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.remarketed_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.repurchased_amount IS NOT NULL
         AND
         p_klev_rec.repurchased_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.repurchased_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.repurchased_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.residual_grnty_amount IS NOT NULL
         AND
         p_klev_rec.residual_grnty_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.residual_grnty_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.residual_grnty_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.rvi_premium IS NOT NULL
         AND
         p_klev_rec.rvi_premium <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.rvi_premium,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.rvi_premium := l_conv_amount;
     END IF;

     IF (p_klev_rec.termination_purchase_amount IS NOT NULL
         AND
         p_klev_rec.termination_purchase_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.termination_purchase_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.termination_purchase_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.tracked_residual IS NOT NULL
         AND
         p_klev_rec.tracked_residual <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.tracked_residual,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.tracked_residual := l_conv_amount;
     END IF;

     IF (p_klev_rec.tradein_amount IS NOT NULL
         AND
         p_klev_rec.tradein_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.tradein_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.tradein_amount := l_conv_amount;
     END IF;

     IF (p_klev_rec.vendor_advance_paid IS NOT NULL
         AND
         p_klev_rec.vendor_advance_paid <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.vendor_advance_paid,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.vendor_advance_paid := l_conv_amount;
     END IF;

     IF (p_klev_rec.residual_value IS NOT NULL
         AND
         p_klev_rec.residual_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.residual_value,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.residual_value := l_conv_amount;
     END IF;

     --Bug# 3143522 : 11.5.10 Subsidies
     IF (p_klev_rec.subsidy_override_amount IS NOT NULL
         AND
         p_klev_rec.subsidy_override_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_klev_rec.subsidy_override_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_klev_rec.subsidy_override_amount := l_conv_amount;
     END IF;
     -- Round off OKC line amounts


     IF (p_clev_rec.price_negotiated IS NOT NULL
         AND
         p_clev_rec.price_negotiated <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_clev_rec.price_negotiated,
                                          p_currency_code => l_currency_code
                                         );

         x_clev_rec.price_negotiated := l_conv_amount;
     END IF;

     IF (p_clev_rec.price_negotiated_renewed IS NOT NULL
         AND
         p_clev_rec.price_negotiated_renewed <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_clev_rec.price_negotiated_renewed,
                                          p_currency_code => l_currency_code
                                         );

         x_clev_rec.price_negotiated_renewed := l_conv_amount;
     END IF;

     IF (p_clev_rec.price_unit IS NOT NULL
         AND
         p_clev_rec.price_unit <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_clev_rec.price_unit,
                                          p_currency_code => l_currency_code
                                         );

         x_clev_rec.price_unit := l_conv_amount;
     END IF;
     --dbms_output.put_line('Round off complete');

   EXCEPTION
     WHEN roundoff_error THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
   END roundoff_line_amount;


-- -----------------------------------------------------------------------------
-- Contract Line Related Procedure
-- -----------------------------------------------------------------------------

-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

   /*
   -- vthiruva, 08/19/2004
   -- START, Code change to enable Business Event
   */
   --cursor to fetch the line style code for line style id passed
    CURSOR lty_code_csr(p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT lse.lty_code
    FROM okc_line_styles_b lse,
         okc_k_lines_b line
    WHERE lse.id = line.lse_id
      AND line.id = p_line_id;

    l_lty_code              okc_line_styles_b.lty_code%TYPE;
    l_parameter_list        wf_parameter_list_t;
    l_event_name            wf_events.name%TYPE := null;
    l_raise_business_event  VARCHAR2(1) := OKL_API.G_FALSE;
   /*
   -- vthiruva, 08/19/2004
   -- END, Code change to enable Business Event
   */
    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    lx_clev_rec okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec klev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

    --Bug# 3143522
    l_dt_clev_rec       okl_okc_migration_pvt.clev_rec_type;
    lx_dt_clev_rec      okl_okc_migration_pvt.clev_rec_type;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    --
    -- Calling amount round-off process
    --
    roundoff_line_amount(
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_clev_rec        => l_clev_rec,
                         p_klev_rec        => l_klev_rec,
                         x_clev_rec        => lx_clev_rec,
                         x_klev_rec        => lx_klev_rec
                        );

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := lx_klev_rec;
    l_clev_rec := lx_clev_rec;

    --Bug# 3143522:
    --
    -- call procedure to get default line dates for Fee and service lines
    --
    If nvl(l_clev_rec.start_date,OKL_API.G_MISS_DATE)    = OKL_API.G_MISS_DATE or
       nvl(l_clev_rec.end_date,OKL_API.G_MISS_DATE)      = OKL_API.G_MISS_DATE or
       nvl(l_clev_rec.currency_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR or
       nvl(l_clev_rec.sts_code,OKL_API.G_MISS_CHAR)      = OKL_API.G_MISS_CHAR then

       l_dt_clev_rec := l_clev_rec;

       get_line_dates(p_clev_rec       => l_dt_clev_rec,
                      x_return_status  => x_return_status,
                      x_clev_rec       => lx_dt_clev_rec);

        -- check return status
        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
            raise OKL_API.G_EXCEPTION_ERROR;
        End If;

        If nvl(lx_dt_clev_rec.start_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE then
            l_clev_rec.start_date := lx_dt_clev_rec.start_date;
        End If;
        If nvl(lx_dt_clev_rec.end_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE then
            l_clev_rec.end_date  := lx_dt_clev_rec.end_date;
        End If;
        If nvl(lx_dt_clev_rec.currency_code,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR then
            l_clev_rec.currency_code  := lx_dt_clev_rec.currency_code;
        End If;
        If nvl(lx_dt_clev_rec.sts_code,OKL_API.G_MISS_CHAR)  <> OKL_API.G_MISS_CHAR then
            l_clev_rec.sts_code  := lx_dt_clev_rec.sts_code;
        End If;
    End If;
    --End Bug# 3143522

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.create_contract_line(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_clev_rec                => l_clev_rec,
         x_clev_rec                => x_clev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record
    l_klev_rec.ID := x_clev_rec.ID;

    -- call procedure in complex API
        OKL_KLE_PVT.Insert_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_klev_rec          => l_klev_rec,
            x_klev_rec          => x_klev_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (x_clev_rec.dnz_chr_id is not null) AND (l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then

         -- call to cascade lease contract statuses to INCOMPLETE
         okl_contract_status_pub.cascade_lease_status_edit
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 p_chr_id          => x_clev_rec.dnz_chr_id);

         If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                 raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                 raise OKL_API.G_EXCEPTION_ERROR;
         End If;

    End If;

   /*
   -- vthiruva, 08/19/2004
   -- START, Code change to enable Business Event
   */
    --fetch the line style code for the record
    OPEN lty_code_csr(x_clev_rec.ID);
    FETCH lty_code_csr into l_lty_code;
    CLOSE lty_code_csr;

    IF l_lty_code = 'FREE_FORM' THEN
        -- raise the business event for create credit limit, if line style code is FREE_FORM
        l_event_name  := G_WF_EVT_CR_LMT_CREATED;
        l_raise_business_event := OKL_API.G_TRUE;
        -- create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CR_LINE_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_CR_LMT_ID,x_clev_rec.id,l_parameter_list);
    ELSIF l_lty_code = 'FREE_FORM1' THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        -- raise the business event for create asset, if line style code is FREE_FORM1
        l_event_name  := G_WF_EVT_ASSET_CREATED;
        -- create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,x_clev_rec.id,l_parameter_list);
      END IF;
    ELSIF l_lty_code = 'SOLD_SERVICE' THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        -- raise the business event for create service, if line style code is SOLD_SERVICE
        l_event_name  := G_WF_EVT_SERVICE_CREATED;
        -- create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_SRV_LINE_ID,x_clev_rec.id,l_parameter_list);
      END IF;
    --create_fee event is raised from here rather than okl_maintain_fee_pvt
    --as contract import process does not call okl_maintain_fee_pvt, but directly calls
    --okl_contract_pvt
    ELSIF l_lty_code = 'FEE' THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        -- raise the business event for create fee, if line style code is FEE
        l_event_name  := G_WF_EVT_FEE_CREATED;
        -- create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID,x_clev_rec.id,l_parameter_list);
      END IF;
    END IF;

    -- raise business event only if the contract is a lease contract, the raise_event flag is on and business event
    -- name is specified. the event should also be raised if this is a credit limit, in which case is_lease_contract
    -- does not hold good
    IF(l_raise_business_event = OKL_API.G_TRUE AND l_event_name IS NOT NULL) THEN
         raise_business_event(p_api_version    => p_api_version,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_event_name     => l_event_name,
                          p_parameter_list => l_parameter_list);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   /*
   -- vthiruva, 08/19/2004
   -- END, Code change to enable Business Event
   */

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END create_contract_line;


-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_clev_tbl.COUNT > 0) Then
           i := p_clev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                create_contract_line(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_rec                => p_clev_tbl(i),
                p_klev_rec                => l_klev_tbl(i),
                        x_clev_rec                => x_clev_tbl(i),
                x_klev_rec                => x_klev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
                i := p_clev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END create_contract_line;
-- Start of comments
-- Bug 2525554      : added this overloaded form for bug 252554
-- Procedure Name   : update_contract_line
-- Description      : updates contract line for shadowed contract
-- Business Rules   : If p_edit_mode is sent as 'Y' contract status will be
--                    updated to 'INCOMPLETE' else it will not be updated to
--                    'INCOMPLETE'. Facilitates updater transactions which
--                    happen in the background while the contract is not 'BOOKED'
--                    for example - calculation and updation of okl_k_lines.
--                    capitalized_interest every time user navigates to booking
--                    page. It is not desired that khr status change to 'INCOMPLETE'
--                    every time capitalized interest is updated.
-- Parameters       :
-- Version          : 1.0
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;
    lx_clev_rec okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec klev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

    cursor l_klev_csr(l_id IN NUMBER) is
        select 'x'
        from OKL_K_LINES_V
        where id = l_id;
    l_dummy_var VARCHAR2(1) := '?';

     --Bug# 3143522,
     --
     -- cursor to get original line data for defaulting dates for fee and service lines
     --Bug# 3455874
     --
     -- populate missing currency_code and sts_code

     cursor l_orig_clev_csr(p_cle_id in number) is
     select cleb.dnz_chr_id,
            cleb.cle_id,
            cleb.lse_id,
            cleb.start_date,
            cleb.end_date,
            cleb.currency_code,
            cleb.sts_code
     from   okc_k_lines_b cleb
     where  id = p_cle_id;

     l_orig_chr_id        okc_k_lines_b.dnz_chr_id%TYPE;
     l_orig_cle_id        okc_k_lines_b.cle_id%TYPE;
     l_orig_lse_id        okc_k_lines_b.lse_id%TYPE;
     l_orig_start_date    okc_k_lines_b.start_date%TYPE;
     l_orig_end_date      okc_k_lines_b.end_date%TYPE;
     l_orig_currency_code okc_k_lines_b.currency_code%TYPE;
     l_orig_sts_code      okc_k_lines_b.sts_code%TYPE;

     l_dt_clev_rec        okl_okc_migration_pvt.clev_rec_type;
     lx_dt_clev_rec       okl_okc_migration_pvt.clev_rec_type;
     --Bug# 3143522

   /*
   -- vthiruva, 08/19/2004
   -- START, Code change to enable Business Event
   */
   --cursor to fetch the line style code for line style id passed
    CURSOR lty_code_csr(p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT lse.lty_code
    FROM okc_line_styles_b lse,
         okc_k_lines_b line
    WHERE lse.id = line.lse_id
      AND line.id = p_line_id;

    -- sjalasut. added cursors to get the service contract details
    CURSOR get_linked_serv_cle (p_okl_chr_id okc_k_headers_b.id%TYPE, p_okl_cle_id okc_k_lines_b.id%TYPE) IS
    select rlobj.object1_id1
     from okc_k_rel_objs_v rlobj
    where rlobj.chr_id = p_okl_chr_id
      and rlobj.cle_id = p_okl_cle_id
      and rlobj.rty_code = 'OKLSRV'
      and rlobj.jtot_object1_code = 'OKL_SERVICE_LINE';
    l_linked_serv_cle_id okc_k_lines_b.id%TYPE;

    CURSOR get_linked_serv_khr (p_oks_cle_id okc_k_headers_b.id%TYPE) IS
    select dnz_chr_id from okc_k_lines_b where id = p_oks_cle_id;
    l_linked_serv_chr_id okc_k_headers_b.id%TYPE;


    l_lty_code              okc_line_styles_b.lty_code%TYPE;
    l_parameter_list        wf_parameter_list_t;
    l_event_name            wf_events.name%TYPE := null;
    l_raise_business_event  VARCHAR2(1) := OKL_API.G_FALSE;
   /*
   -- vthiruva, 08/19/2004
   -- END, Code change to enable Business Event
   */
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    --
    -- Calling amount round-off process
    --
    roundoff_line_amount(
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_clev_rec        => l_clev_rec,
                         p_klev_rec        => l_klev_rec,
                         x_clev_rec        => lx_clev_rec,
                         x_klev_rec        => lx_klev_rec
                        );

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := lx_klev_rec;
    l_clev_rec := lx_clev_rec;

    --Bug# 3143522
    --
    -- call procedure to get default line dates for Fee and service lines
    --
    If nvl(l_clev_rec.start_date,OKL_API.G_MISS_DATE)    = OKL_API.G_MISS_DATE or
       nvl(l_clev_rec.end_date,OKL_API.G_MISS_DATE)      = OKL_API.G_MISS_DATE or
       nvl(l_clev_rec.currency_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR or
       nvl(l_clev_rec.sts_code,OKL_API.G_MISS_CHAR)      = OKL_API.G_MISS_CHAR then


       l_dt_clev_rec := l_clev_rec;

       open l_orig_clev_csr(p_cle_id => l_clev_rec.id);
           fetch l_orig_clev_csr into l_orig_chr_id,
                                      l_orig_cle_id,
                                      l_orig_lse_id,
                                      l_orig_start_date,
                                      l_orig_end_date,
                                      l_orig_currency_code,
                                      l_orig_sts_code;
       close l_orig_clev_csr;

       If nvl(l_dt_clev_rec.dnz_chr_id,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM then
          l_dt_clev_rec.dnz_chr_id := l_orig_chr_id;
       End If;
       If nvl(l_dt_clev_rec.cle_id,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM then
           l_dt_clev_rec.cle_id := l_orig_cle_id;
       End If;
       If nvl(l_dt_clev_rec.lse_id,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM then
           l_dt_clev_rec.lse_id := l_orig_lse_id;
       End If;
       If nvl(l_dt_clev_rec.start_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
           l_dt_clev_rec.start_date := l_orig_start_date;
       End If;
       If nvl(l_dt_clev_rec.end_date,OKL_API.G_MISS_DATE) = OKL_API.G_MISS_DATE then
           l_dt_clev_rec.end_date := l_orig_end_date;
       End If;
       If nvl(l_dt_clev_rec.currency_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
           l_dt_clev_rec.currency_code := l_orig_currency_code;
       End If;
       If nvl(l_dt_clev_rec.sts_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
           l_dt_clev_rec.sts_code := l_orig_sts_code;
       End If;

    If nvl(l_dt_clev_rec.start_date,OKL_API.G_MISS_DATE)    = OKL_API.G_MISS_DATE or
       nvl(l_dt_clev_rec.end_date,OKL_API.G_MISS_DATE)      = OKL_API.G_MISS_DATE or
       nvl(l_dt_clev_rec.currency_code,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR or
       nvl(l_dt_clev_rec.sts_code,OKL_API.G_MISS_CHAR)      = OKL_API.G_MISS_CHAR then

          get_line_dates(p_clev_rec       => l_dt_clev_rec,
                         x_return_status  => x_return_status,
                         x_clev_rec       => lx_dt_clev_rec);

           -- check return status
           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

            If nvl(lx_dt_clev_rec.start_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE then
                l_clev_rec.start_date := lx_dt_clev_rec.start_date;
            End If;
            If nvl(lx_dt_clev_rec.end_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE then
                l_clev_rec.end_date  := lx_dt_clev_rec.end_date;
            End If;
            If nvl(lx_dt_clev_rec.currency_code,OKL_API.G_MISS_CHAR) <> OKL_API.G_MISS_CHAR then
                l_clev_rec.currency_code  := lx_dt_clev_rec.currency_code;
            End If;
            If nvl(lx_dt_clev_rec.sts_code,OKL_API.G_MISS_CHAR)  <> OKL_API.G_MISS_CHAR then
                l_clev_rec.sts_code  := lx_dt_clev_rec.sts_code;
            End If;
        End If;
    End If;
    --Bug# 3143522

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.update_contract_line(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_clev_rec                => l_clev_rec,
         x_clev_rec                => x_clev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record
    l_klev_rec.ID := x_clev_rec.ID;

    -- check whether the shadow is present
    open l_klev_csr(l_klev_rec.id);
        fetch l_klev_csr into l_dummy_var;
    close l_klev_csr;

    -- call procedure in complex API
    -- if l_dummy_var is changed then the shadow is present
    -- and we need to update it, otherwise we need to create the shadow
    if (l_dummy_var = 'x') THEN
        OKL_KLE_PVT.Update_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_klev_rec          => l_klev_rec,
            x_klev_rec          => x_klev_rec);
    else
        OKL_KLE_PVT.Insert_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_klev_rec          => l_klev_rec,
            x_klev_rec          => x_klev_rec);
    end if;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If p_edit_mode = 'Y' Then
        If (x_clev_rec.dnz_chr_id is NOT NULL) AND (x_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
            --cascade edit status on to lines
            okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_chr_id          => x_clev_rec.dnz_chr_id);

             If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                 raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                 raise OKL_API.G_EXCEPTION_ERROR;
             End If;
         END IF;
    End If;

   /*
   -- vthiruva, 08/19/2004
   -- START, Code change to enable Business Event
   */
    --fetch the line style code for the record
    OPEN lty_code_csr(x_clev_rec.ID);
    FETCH lty_code_csr into l_lty_code;
    CLOSE lty_code_csr;

    IF l_lty_code = 'FREE_FORM' THEN
        -- raise the business event for update credit limit if line style code is FREE_FORM
        l_event_name  := G_WF_EVT_CR_LMT_UPDATED;
        l_raise_business_event := OKL_API.G_TRUE;
        --create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CR_LINE_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_CR_LMT_ID,l_clev_rec.id,l_parameter_list);
    ELSIF l_lty_code = 'FREE_FORM1' THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        -- raise the business event for create asset, if line style code is FREE_FORM1
        l_event_name  := G_WF_EVT_ASSET_UPDATED;
        --create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,x_clev_rec.id,l_parameter_list);
      END IF;
    ELSIF l_lty_code = 'SOLD_SERVICE' THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        --raise the business event for create service, if line style code is SOLD_SERVICE
        l_event_name  := G_WF_EVT_SERVICE_UPDATED;
        --create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_SRV_LINE_ID,x_clev_rec.id,l_parameter_list);
        -- check if this service line is linked with a service contract
        OPEN get_linked_serv_cle(l_clev_rec.dnz_chr_id,x_clev_rec.id);
        FETCH get_linked_serv_cle INTO l_linked_serv_cle_id;
        CLOSE get_linked_serv_cle;
        IF(l_linked_serv_cle_id IS NOT NULL)THEN
          -- we have a service line, derive the service contract and pass the service line and
          -- service contract to the event
          OPEN get_linked_serv_khr(l_linked_serv_cle_id);
          FETCH get_linked_serv_khr INTO l_linked_serv_chr_id;
          CLOSE get_linked_serv_khr;
          wf_event.AddParameterToList(G_WF_ITM_SERVICE_KHR_ID,l_linked_serv_chr_id,l_parameter_list);
          wf_event.AddParameterToList(G_WF_ITM_SERVICE_CLE_ID,l_linked_serv_cle_id,l_parameter_list);
        END IF;
      END IF;
    --update_fee event is raised from here rather than okl_maintain_fee_pvt
    --as split contract process does not call okl_maintain_fee_pvt, but directly calls
    --okl_contract_pvt
    ELSIF l_lty_code = 'FEE' THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        -- raise the business event for fee updated, if line style code is FEE
        l_event_name  := G_WF_EVT_FEE_UPDATED;
        --create the parameter list to pass to raise_event
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_clev_rec.dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID,x_clev_rec.id,l_parameter_list);
      END IF;
    END IF;

    -- raise business event only if the contract is a lease contract, the raise_event flag is on and business event
    -- name is specified. the event should also be raised if this is a credit limit, in which case is_lease_contract
    -- does not hold good
    IF(l_raise_business_event = OKL_API.G_TRUE AND l_event_name IS NOT NULL) THEN
         raise_business_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_event_name     => l_event_name,
                           p_parameter_list => l_parameter_list);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   /*
   -- vthiruva, 08/19/2004
   -- END, Code change to enable Business Event
   */

  OKL_API.END_ACTIVITY(x_msg_count      => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      if l_klev_csr%ISOPEN then
          close l_klev_csr;
        end if;

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      if l_klev_csr%ISOPEN then
          close l_klev_csr;
        end if;

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      if l_klev_csr%ISOPEN then
          close l_klev_csr;
        end if;
  END update_contract_line;

-- Start of comments
--
-- Procedure Name  : update_contract_line (default)
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- Bug # 2525554   : Now calls the p_edit_mode form of update_contract_line
--                   with p_edit_mode = 'Y' as default. This is the original
--                   default update contract line.
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    --
    -- call procedure in complex API
    --
    update_contract_line(
         p_api_version            => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_clev_rec                    => l_clev_rec,
     p_klev_rec         => l_klev_rec,
     p_edit_mode        => 'Y',
         x_clev_rec                    => x_clev_rec,
     x_klev_rec         => x_klev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

  OKL_API.END_ACTIVITY(x_msg_count      => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END update_contract_line;

-- Start of comments
-- Bug 2525554      : added this overloaded form for bug 252554
-- Procedure Name   : update_contract_line
-- Description      : updates contract line for shadowed contract
-- Business Rules   : If p_edit_mode is sent as 'Y' contract status will be
--                    updated to 'INCOMPLETE' else it will not be updated to
--                    'INCOMPLETE'. Facilitates updater transactions which
--                    happen in the background while the contract is not 'BOOKED'
--                    for example - calculation and updation of okl_k_lines.
--                    capitalized_interest every time user navigates to booking
--                    page. It is not desired that khr status change to 'INCOMPLETE'
--                    every time capitalized interest is updated.
-- Parameters       :
-- Version          : 1.0
-- End of comments

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_edit_mode                    IN  VARCHAR2,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version                CONSTANT NUMBER          := 1.0;
    l_return_status          VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                                NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_clev_tbl.COUNT > 0) Then
           i := p_clev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                update_contract_line(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_rec                    => p_clev_tbl(i),
                p_klev_rec                    => l_klev_tbl(i),
            p_edit_mode         => p_edit_mode,
                        x_clev_rec                    => x_clev_tbl(i),
                x_klev_rec                    => x_klev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
                i := p_clev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_contract_line;


-- Start of comments
--
-- Procedure Name  : update_contract_line
-- Description     : updates contract line for shadowed contract(default)
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- Bug # 2525554   : Now calls the p_edit_mode form of update_contract_line
--                   with p_edit_mode = 'Y' as default. This is the original
--                   default update contract line for table signature.
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version                CONSTANT NUMBER          := 1.0;
    l_return_status          VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                                NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_clev_tbl.COUNT > 0) Then

                update_contract_line(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_tbl                    => p_clev_tbl,
                p_klev_tbl                    => l_klev_tbl,
            p_edit_mode         => 'Y',
                        x_clev_tbl                    => x_clev_tbl,
                x_klev_tbl                    => x_klev_tbl);

        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                raise OKL_API.G_EXCEPTION_ERROR;
        End If;

    End If;


    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_contract_line;


-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : line can be deleted only when there is no sublines attached
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_clev_rec_out okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec_out klev_rec_type;

    l_deletion_type     Varchar2(1);

    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status         VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

     --cursor to find out chr id required to flip status at edit point
    CURSOR chr_id_crs (p_cle_id IN NUMBER) is
    SELECT DNZ_CHR_ID
    FROM   OKC_K_LINES_B
    WHERE  ID = P_CLE_ID;

    l_dnz_chr_id   OKC_K_LINES_B.dnz_chr_id%TYPE;

    --cursor to find out if any transactions hanging off the line to be deleted
    CURSOR l_get_txl_crs (p_kle_id IN NUMBER) is
    SELECT tas_id,
           id
    FROM   OKL_TXL_ASSETS_B
    WHERE  kle_id = p_kle_id;

    l_tas_id    OKL_TXL_ASSETS_B.TAS_ID%TYPE;
    l_txl_id    OKL_TXL_ASSETS_B.ID%TYPE;

    --cursor to get the transaction detail record if it exists
    CURSOR l_get_txd_crs (p_tal_id IN NUMBER) is
    SELECT ID
    FROM   OKL_TXD_ASSETS_B
    WHERE  tal_id = p_tal_id;

    l_txd_id      OKL_TXD_ASSETS_B.ID%TYPE;

    l_adpv_rec        OKL_TXD_ASSETS_PUB.adpv_rec_type;
    l_tlpv_rec        OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    l_thpv_rec        OKL_TRX_ASSETS_PUB.thpv_rec_type;

     --Bug # 2522268
    --cursor to get ib transaction line record
    CURSOR l_get_iti_csr (p_kle_id IN NUMBER) is
    SELECT tas_id,
           id
    FROM   OKL_TXL_ITM_INSTS
    WHERE  kle_id = p_kle_id;

    l_iti_tas_id   OKL_TXL_ITM_INSTS.TAS_ID%TYPE;
    l_iti_id       OKL_TXL_ITM_INSTS.ID%TYPE;

    l_iipv_rec     OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
    l_iti_thpv_rec OKL_TRX_ASSETS_PUB.thpv_rec_type;
     --Bug # 2522268

    --Bug# 3143522 : delete supplier invoice details is line is deleted
    --cursor to ger supplier invoice details
    CURSOR l_get_sid_csr (p_kle_id IN NUMBER) is
    Select id
    FROM   OKL_SUPP_INVOICE_DTLS
    where  cle_id = p_kle_id;

    l_sid_id     OKL_SUPP_INVOICE_DTLS.ID%TYPE;

    l_sidv_tbl   OKL_SUPP_INVOICE_DTLS_PUB.sidv_tbl_type;

    --cursor to get party payment header for line
    -- Passthru, Bug 4350255
    CURSOR l_get_pyh_csr (p_kle_id IN NUMBER) is
    Select pyh.id
    FROM   OKL_PARTY_PAYMENT_HDR  pyh
    WHERE  pyh.cle_id = p_kle_id;

    l_pyh_id    OKL_PARTY_PAYMENT_HDR.ID%TYPE;
    l_pphv_tbl  OKL_PARTY_PAYMENTS_PVT.pphv_tbl_type;

    --cursor to get party payment details for line
    CURSOR l_get_pyd_csr (p_kle_id IN NUMBER) is
    Select pyd.id
    FROM   OKL_PARTY_PAYMENT_DTLS pyd,
           OKC_K_PARTY_ROLES_B    cplb
    WHERE  pyd.cpl_id = cplb.id
    AND    nvl(cplb.cle_id,-9999) = p_kle_id;

    l_pyd_id    OKL_PARTY_PAYMENT_DTLS.ID%TYPE;

    l_ppydv_tbl OKL_PYD_PVT.ppydv_tbl_type;
    i   number  default 0;

    --Bug# 4558486
    CURSOR l_kpl_csr(p_kle_id IN NUMBER,
                     p_khr_id IN NUMBER) is
    SELECT kpl.id
    FROM   okl_k_party_roles kpl,
           okc_k_party_roles_b cpl
    WHERE  kpl.id = cpl.id
    AND    cpl.cle_id = p_kle_id
    AND    cpl.dnz_chr_id = p_khr_id;

    l_kplv_tbl OKL_KPL_PVT.kplv_tbl_type;

    --Bug# 3143522
    /*
    -- vthiruva, 08/19/2004
    -- START, Code change to enable Business Event
    */
    --cursor to fetch the line style code for line style id passed
    CURSOR lty_code_csr(p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT lse.lty_code
    FROM okc_line_styles_b lse,
         okc_k_lines_b lns
    WHERE lns.id = p_line_id
    AND lse.id = lns.lse_id;

    l_lty_code              okc_line_styles_b.lty_code%TYPE;
    l_parameter_list        wf_parameter_list_t;
    l_raise_business_event VARCHAR2(1) := OKL_API.G_FALSE;
    l_business_event_name WF_EVENTS.NAME%TYPE;
    /*
    -- vthiruva, 08/19/2004
    -- END, Code change to enable Business Event
    */

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    --check if okl contract line delete is allowed
    kle_delete_allowed(p_cle_id          => l_klev_rec.id,
                       x_deletion_type   => l_deletion_type,
                       x_return_status   => x_return_status);

    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OPEN  lty_code_csr(l_clev_rec.id);
    FETCH lty_code_csr into l_lty_code;
    CLOSE lty_code_csr;


    If l_deletion_type = 'L' Then --logical delete
       --update line status to 'Abandoned'
       l_clev_rec.sts_code := G_OKL_CANCELLED_STS_CODE;
       --l_clev_rec.end_date := sysdate;

       update_contract_line(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_clev_rec       => l_clev_rec,
           p_klev_rec       => l_klev_rec,
           x_clev_rec       => l_clev_rec_out,
           x_klev_rec       => l_klev_rec_out
           );

       If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
       End If;

       --Bug # 2522268 Begin
       --do logical deletion of asset number so
       -- old asset number is available for use
       Asset_Logical_Delete( p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_cle_id          => l_clev_rec_out.id,
                             p_asset_number    => l_clev_rec_out.name);

       If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
       End If;

       --do logical deletion of linked assets
       Linked_Asset_Delete(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_cle_id          => l_clev_rec_out.id,
                           p_deletion_type   => l_deletion_type);

       If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
       End If;
        --Bug # 2522268 End

       --Bug # 2937980
       Inactivate_Streams
          ( p_api_version     => p_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_cle_id          => l_clev_rec.id);

       If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
           raise OKL_API.G_EXCEPTION_ERROR;
       End If;
       --Bug # 2937980

       If (l_clev_rec_out.dnz_chr_id is not null) AND (l_clev_rec_out.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
            --call to cascade the status to Incomplete
            okl_contract_status_pub.cascade_lease_status_edit
                    (p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                    x_return_status   => x_return_status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => x_msg_data,
                    p_chr_id          => l_clev_rec_out.dnz_chr_id);

            If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                   raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                   raise OKL_API.G_EXCEPTION_ERROR;
            End If;

       End If;

    ElsIf l_deletion_type = 'N' Then --not allowed
        null; --delete is not allowed this will be normally an error
    ElsIf l_deletion_type = 'P' Then

          --call to cascade the status to Incomplete
          --this has to be done first as l_clev_rec.dnz_chr_id will be null
          -- once the line has been deleted.
          If (l_clev_rec.dnz_chr_id is NULL) or (l_clev_rec.dnz_chr_id = OKL_API.G_MISS_NUM) Then
              Open chr_id_crs(p_cle_id => l_clev_rec.cle_id);
                  Fetch chr_id_crs into l_dnz_chr_id;
                  If chr_id_crs%NOTFOUND Then
                     null;
                  End If;
              Close chr_id_crs;
          Else
             l_dnz_chr_id := l_clev_rec.dnz_chr_id;
          End If;

          If (l_dnz_chr_id is not null) AND (l_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 p_chr_id          => l_dnz_chr_id);

          If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                  raise OKL_API.G_EXCEPTION_ERROR;
          End If;

          End If;

        --Bug # 2522268
        --Physical delete of linked covered asset lines
        Linked_Asset_Delete(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_cle_id          => l_clev_rec.id,
                           p_deletion_type   => l_deletion_type);

        If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
        End If;
        --Bug # 2522268 End

        --Bug# 3143522
        --delete associated party payment details
        i := 0;
        open l_get_pyd_csr(p_kle_id => l_clev_rec.id);
        Loop
            Fetch l_get_pyd_csr into l_pyd_id;
            Exit when l_get_pyd_csr%NOTFOUND;
            i := i+1;
            l_ppydv_tbl(i).id := l_pyd_id;
        End Loop;
        close l_get_pyd_csr;

        If l_ppydv_tbl.COUNT > 0 then
            OKL_PYD_PVT.delete_row
             (p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_ppydv_tbl        => l_ppydv_tbl);

           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

           l_ppydv_tbl.DELETE;

       End If;
       --Bug# 3143522

       -- Passthru Bug 4350255
        i := 0;
        open l_get_pyh_csr(p_kle_id => l_clev_rec.id);
        Loop
            Fetch l_get_pyh_csr into l_pyh_id;
            Exit when l_get_pyh_csr%NOTFOUND;
            i := i+1;
            l_pphv_tbl(i).id := l_pyh_id;
        End Loop;
        close l_get_pyh_csr;

        If l_pphv_tbl.COUNT > 0 then
            OKL_PARTY_PAYMENTS_PVT.DELETE_PARTY_PAYMENT_HDR
             (p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_pphv_tbl         => l_pphv_tbl );

           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

           l_pphv_tbl.DELETE;

       End If;
       -- Passthru Bug 4350255

        --Bug# 4558486
        -- Delete records from okl_k_party_roles
        i := 0;
        For l_kpl_rec in l_kpl_csr(p_kle_id => l_clev_rec.id,
                                   p_khr_id => l_dnz_chr_id)
        Loop
          i := i + 1;
          l_kplv_tbl(i).id := l_kpl_rec.id;
        End Loop;

        If l_kplv_tbl.COUNT > 0 then
            OKL_KPL_PVT.Delete_Row
               (p_api_version      => p_api_version,
                p_init_msg_list    => p_init_msg_list,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data,
                p_kplv_tbl         => l_kplv_tbl);

           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

           l_kplv_tbl.DELETE;
        End If;
        --Bug# 4558486

        --
        -- call procedure in complex API
        --
        okl_okc_migration_pvt.delete_contract_line(
             p_api_version            => p_api_version,
             p_init_msg_list        => p_init_msg_list,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
         p_clev_rec                 => l_clev_rec);


      --12/10/01 ashish - changed this to call different okc api as we need to delete
      --okc_k_items automatically when okc_k_lines is deleted.
      --okc_contract_pub can be called directly here as there are no records involved

      --taken care of in another api with p_delete_cascade_yn flag

        -- check return status
        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
        End If;

        -- get id from OKC record
        l_klev_rec.ID := l_clev_rec.ID;

        -- check if any transactions are hanging on this line
        OPEN l_get_txl_crs (p_kle_id => l_klev_rec.ID);
             FETCH l_get_txl_crs into l_tas_id, l_txl_id;
             If l_get_txl_crs%NOTFOUND Then
                 Null;
             Else
                 --find if any transaction details attached to the txl line

                 OPEN l_get_txd_crs (p_tal_id => l_txl_id);
                 FETCH l_get_txd_crs INTO l_txd_id;
                 If l_get_txd_crs%NOTFOUND Then
                    Null;
                 Else
                     --delete txd record
                     l_adpv_rec.id := l_txd_id;
                     OKL_TXD_ASSETS_PUB.delete_txd_asset_Def(
                         p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_adpv_rec        => l_adpv_rec);
                      -- check return status
                      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                              raise OKL_API.G_EXCEPTION_ERROR;
                      End If;
                  End If;
                  Close l_get_txd_crs;
                  --delete txl record
                  l_tlpv_rec.id := l_txl_id;
                  OKL_TXL_ASSETS_PUB.delete_txl_asset_Def(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_tlpv_rec      => l_tlpv_rec);
                  -- check return status
                  If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                  End If;

                  --delete tas_record
                  l_thpv_rec.id := l_tas_id;
                  OKL_TRX_ASSETS_PUB.delete_trx_ass_h_Def(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_thpv_rec      => l_thpv_rec);
                  -- check return status
                  If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                  End If;
              End If;
        Close l_get_txl_crs;

        --Bug # 2522268
        -- check if any IB transactions are hanging on this line
        OPEN l_get_iti_csr (p_kle_id => l_klev_rec.ID);
             FETCH l_get_iti_csr into l_iti_tas_id, l_iti_id;
             If l_get_iti_csr%NOTFOUND Then
                 Null;
             Else
                  l_iipv_rec.id := l_iti_id;
                  OKL_TXL_ITM_INSTS_PUB.delete_txl_itm_insts(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_iipv_rec      => l_iipv_rec);
                  -- check return status
                  If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                  End If;

                  --delete tas_record
                  l_iti_thpv_rec.id := l_iti_tas_id;
                  OKL_TRX_ASSETS_PUB.delete_trx_ass_h_Def(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_thpv_rec      => l_iti_thpv_rec);
                  -- check return status
                  If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                  End If;
              End If;
        Close l_get_iti_csr;

        --Bug # 2522268 End

       --Bug# 3143522
        --delete associated supplier invoice details
        i := 0;
        open l_get_sid_csr(p_kle_id => l_clev_rec.id);
        Loop
            Fetch l_get_sid_csr into l_sid_id;
            Exit when l_get_sid_csr%NOTFOUND;
            i := i+1;
            l_sidv_tbl(i).id := l_sid_id;
        End Loop;
        close l_get_sid_csr;

        If l_sidv_tbl.COUNT > 0 then
            OKL_SUPP_INVOICE_DTLS_PUB.delete_sup_inv_dtls
             (p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_sidv_tbl         => l_sidv_tbl);

           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

           l_sidv_tbl.DELETE;

       End If;
       --Bug# 3143522 End


        -- call procedure in complex API
        OKL_KLE_PVT.Delete_Row(
                p_api_version        => p_api_version,
                p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_klev_rec          => l_klev_rec);

        If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
              raise OKL_API.G_EXCEPTION_ERROR;
        End If;
    End If;

    -- sjalasut, added code to handle business event when credit limit is deleted
    -- raise the business event for delete credit limit only if line style code is FREE_FORM.
    -- keep the following condition and the raise business event api separate for
    -- extensibility
    IF(l_lty_code = 'FREE_FORM')THEN
      l_raise_business_event := OKL_API.G_TRUE;
      --create the parameter list to pass to raise_event
      wf_event.AddParameterToList(G_WF_ITM_CR_LINE_ID,l_dnz_chr_id,l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_CR_LMT_ID,l_clev_rec.id,l_parameter_list);
      l_business_event_name := G_WF_EVT_CR_LMT_REMOVED;
    END IF;

    IF(l_raise_business_event = OKL_API.G_TRUE AND l_business_event_name IS NOT NULL)THEN
      raise_business_event(p_api_version    => p_api_version,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_event_name     => l_business_event_name,
                          p_parameter_list => l_parameter_list);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count,
                                     x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      If l_get_txl_crs%ISOPEN Then
          Close l_get_txl_crs;
      End If;
      If l_get_txd_crs%ISOPEN Then
          Close l_get_txd_crs;
      End If;
      If chr_id_crs%ISOPEN Then
          Close chr_id_crs;
      End If;
      If l_get_iti_csr%ISOPEN Then
          Close l_get_iti_csr;
      End If;
      If l_get_sid_csr%ISOPEN Then
          Close l_get_sid_csr;
      End If;
      If l_get_pyd_csr%ISOPEN Then
          Close l_get_pyd_csr;
      End If;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                                 p_api_name  => l_api_name,
                                                 p_pkg_name  => g_pkg_name,
                                                 p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                                 x_msg_count => x_msg_count,
                                                 x_msg_data  => x_msg_data,
                                                 p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      If l_get_txl_crs%ISOPEN Then
          Close l_get_txl_crs;
      End If;
      If l_get_txd_crs%ISOPEN Then
          Close l_get_txd_crs;
      End If;
      If chr_id_crs%ISOPEN Then
          Close chr_id_crs;
      End If;
      If l_get_iti_csr%ISOPEN Then
          Close l_get_iti_csr;
      End If;
      If l_get_sid_csr%ISOPEN Then
          Close l_get_sid_csr;
      End If;
      If l_get_pyd_csr%ISOPEN Then
          Close l_get_pyd_csr;
      End If;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                                 p_api_name  => l_api_name,
                                                 p_pkg_name  => g_pkg_name,
                                                 p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                                 x_msg_count => x_msg_count,
                                                 x_msg_data  => x_msg_data,
                                                 p_api_type  => g_api_type);

    when OTHERS then
      If l_get_txl_crs%ISOPEN Then
          Close l_get_txl_crs;
      End If;
      If l_get_txd_crs%ISOPEN Then
          Close l_get_txd_crs;
      End If;
      If chr_id_crs%ISOPEN Then
          Close chr_id_crs;
      End If;
      If l_get_iti_csr%ISOPEN Then
          Close l_get_iti_csr;
      End If;
      If l_get_sid_csr%ISOPEN Then
          Close l_get_sid_csr;
      End If;
      If l_get_pyd_csr%ISOPEN Then
          Close l_get_pyd_csr;
      End If;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                                 p_api_name  => l_api_name,
                                                 p_pkg_name  => g_pkg_name,
                                                 p_exc_name  => 'OTHERS',
                                                 x_msg_count => x_msg_count,
                                                 x_msg_data  => x_msg_data,
                                                 p_api_type  => g_api_type);
  END delete_contract_line;


-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : line can be deleted only if there is not sublines attached
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (p_clev_tbl.COUNT > 0) Then
           i := p_clev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                delete_contract_line(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_rec                => p_clev_tbl(i),
                p_klev_rec                => l_klev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
                i := p_clev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : delete contract line, all related objects and sublines
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN NUMBER) IS

    l_cle_Id     NUMBER;
    v_Index   Binary_Integer;

-- OKC code removes lines four levels deep
    CURSOR l_Child_Cur1_csr(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   OKC_K_Lines_b
    WHERE  cle_id=P_Parent_Id;

    CURSOR l_Child_Cur2_csr(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    CURSOR l_Child_Cur3_csr(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    CURSOR l_Child_Cur4_csr(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    CURSOR l_Child_Cur5_csr(P_Parent_Id IN NUMBER)
    IS SELECT ID
    FROM   Okc_K_Lines_b
    WHERE  cle_Id=P_Parent_Id;

    --cursor to find out chr id required to flip status at edit point
    CURSOR chr_id_crs (p_cle_id IN NUMBER) is
    SELECT DNZ_CHR_ID
    FROM   OKC_K_LINES_B
    WHERE  ID = P_CLE_ID;

    l_dnz_chr_id   OKC_K_LINES_B.dnz_chr_id%TYPE;


    n NUMBER:=0;
    l_klev_tbl_in     OKL_KLE_PVT.klev_tbl_type;
    l_klev_tbl_tmp    OKL_KLE_PVT.klev_tbl_type;

    l_api_version       CONSTANT        NUMBER      := 1.0;
    l_return_status     VARCHAR2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';

    l_clev NUMBER:=1;
    l_lse_Id NUMBER;

    --cursor to find out if any transactions hanging off the line to be deleted
    CURSOR l_get_txl_crs (p_kle_id IN NUMBER) is
    SELECT tas_id,
           id
    FROM   OKL_TXL_ASSETS_B
    WHERE  kle_id = p_kle_id;

    l_tas_id    OKL_TXL_ASSETS_B.TAS_ID%TYPE;
    l_txl_id    OKL_TXL_ASSETS_B.ID%TYPE;

    --cursor to get the transaction detail record if it exists
    CURSOR l_get_txd_crs (p_tal_id IN NUMBER) is
    SELECT ID
    FROM   OKL_TXD_ASSETS_B
    WHERE  tal_id = p_tal_id;

    l_txd_id      OKL_TXD_ASSETS_B.ID%TYPE;

    l_adpv_rec        OKL_TXD_ASSETS_PUB.adpv_rec_type;
    l_tlpv_rec        OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    l_thpv_rec        OKL_TRX_ASSETS_PUB.thpv_rec_type;

     --Bug # 2522268
    --cursor to get ib transaction line record
    CURSOR l_get_iti_csr (p_kle_id IN NUMBER) is
    SELECT tas_id,
           id
    FROM   OKL_TXL_ITM_INSTS
    WHERE  kle_id = p_kle_id;

    l_iti_tas_id   OKL_TXL_ITM_INSTS.TAS_ID%TYPE;
    l_iti_id       OKL_TXL_ITM_INSTS.ID%TYPE;

    l_iipv_rec     OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
    l_iti_thpv_rec OKL_TRX_ASSETS_PUB.thpv_rec_type;
     --Bug # 2522268


--variable added for checking if okl line deletion is allowed
    i Number;
    l_deletion_type Varchar2(1) default 'P';
    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_clev_rec_out okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec_out klev_rec_type;
--variable added for checking if okl line deletion is allowed
 --Bug# 3143522 : delete supplier invoice details is line is deleted
    --cursor to ger supplier invoice details
    CURSOR l_get_sid_csr (p_kle_id IN NUMBER) is
    Select id
    FROM   OKL_SUPP_INVOICE_DTLS
    where  cle_id = p_kle_id;

    l_sid_id     OKL_SUPP_INVOICE_DTLS.ID%TYPE;

    l_sidv_tbl   OKL_SUPP_INVOICE_DTLS_PUB.sidv_tbl_type;

    --cursor to get party payment details for line
    CURSOR l_get_pyd_csr (p_kle_id IN NUMBER) is
    Select pyd.id
    FROM   OKL_PARTY_PAYMENT_DTLS pyd,
           OKC_K_PARTY_ROLES_B    cplb
    WHERE  pyd.cpl_id = cplb.id
    AND    nvl(cplb.cle_id,-9999) = p_kle_id;

    l_pyd_id    OKL_PARTY_PAYMENT_DTLS.ID%TYPE;

    l_ppydv_tbl OKL_PYD_PVT.ppydv_tbl_type;
    k   number  default 0;
    --Bug# 3143522

    --cursor to get party payment header for line
    -- Passthru, Bug 4350255
    CURSOR l_get_pyh_csr (p_kle_id IN NUMBER) is
    Select pyh.id
    FROM   OKL_PARTY_PAYMENT_HDR  pyh
    WHERE  pyh.cle_id = p_kle_id;

    l_pyh_id    OKL_PARTY_PAYMENT_HDR.ID%TYPE;
    l_pphv_tbl  OKL_PARTY_PAYMENTS_PVT.pphv_tbl_type;

    --Bug# 4558486
    CURSOR l_kpl_csr(p_kle_id IN NUMBER,
                     p_khr_id IN NUMBER) is
    SELECT kpl.id
    FROM   okl_k_party_roles kpl,
           okc_k_party_roles_b cpl
    WHERE  kpl.id = cpl.id
    AND    cpl.cle_id = p_kle_id
    AND    cpl.dnz_chr_id = p_khr_id;

    l_kplv_tbl OKL_KPL_PVT.kplv_tbl_type;

    /*
    -- vthiruva, 08/19/2004
    -- START, Code change to enable Business Event
    */
    --cursor to fetch the line style code for line style id passed
    CURSOR lty_code_csr(p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT lse.lty_code
    FROM okc_line_styles_b lse,
         okc_k_lines_b lns
    WHERE lns.id = p_line_id
    AND lse.id = lns.lse_id;

    l_lty_code              okc_line_styles_b.lty_code%TYPE;
    l_parameter_list        wf_parameter_list_t;
    l_raise_business_event VARCHAR2(1) := OKL_API.G_FALSE;
    l_business_event_name WF_EVENTS.NAME%TYPE;
    /*
    -- vthiruva, 08/19/2004
    -- END, Code change to enable Business Event
    */

    -- validates line id
    PROCEDURE Validate_Line_id(
      p_line_id         IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2) IS
      l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_count   NUMBER;
      CURSOR l_cur_line_csr(p_line_id IN NUMBER) IS
      SELECT COUNT(id) FROM OKC_K_LINES_B
      WHERE id = p_line_id;
    BEGIN
      IF p_line_id = OKL_API.G_MISS_NUM OR p_line_id IS NULL
      THEN
        OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'p_line_id');

        l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;

      OPEN l_cur_line_csr(p_line_id);
      FETCH l_cur_line_csr INTO l_Count;
      CLOSE l_cur_line_csr;
      IF NOT l_Count = 1 THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_line_id');

        l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
      x_return_status := l_return_status;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller

        OKL_API.set_message(G_APP_NAME,
                         G_UNEXPECTED_ERROR,
                         G_SQLCODE_TOKEN,
                         SQLCODE,
                         G_SQLERRM_TOKEN,
                         SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Line_id;

  BEGIN
    x_return_status:=OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    Validate_Line_id(p_line_id,l_return_status);
    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;


-- now we need to store all numbers of sublines to the current line
-- we do it the same way as OKC are doing
-- what we need to make sure later, is that even when the master line is deleted
-- we still can delete the shadow
    l_klev_tbl_tmp(l_clev).ID:=p_line_id;
    l_clev:=l_clev+1;
    FOR l_child_rec1 IN l_child_cur1_csr(p_line_id)
    LOOP
      l_klev_tbl_tmp(l_clev).ID:=l_child_rec1.ID;
      l_clev:=l_clev+1;
      FOR l_child_rec2 IN l_child_cur2_csr(l_child_rec1.Id)
      LOOP
          l_klev_tbl_tmp(l_clev).ID:=l_child_rec2.Id;
        l_clev:=l_clev+1;
        FOR l_child_rec3 IN l_child_cur3_csr(l_child_rec2.Id)
        LOOP
            l_klev_tbl_tmp(l_clev).ID:=l_child_rec3.Id;
          l_clev:=l_clev+1;
            FOR l_child_rec4 IN l_child_cur4_csr(l_child_rec3.Id)
            LOOP
              l_klev_tbl_tmp(l_clev).ID:=l_child_rec4.Id;
            l_clev:=l_clev+1;
            FOR l_child_rec5 IN l_child_cur5_csr(l_child_rec4.Id)
              LOOP
                    l_klev_tbl_tmp(l_clev).ID:=l_child_rec5.Id;
              l_clev:=l_clev+1;
            END LOOP;
            END LOOP;
        END LOOP;
      END LOOP;
    END LOOP;
    l_clev:=1;
    FOR v_Index IN REVERSE l_klev_tbl_tmp.FIRST .. l_klev_tbl_tmp.LAST
    LOOP
      l_klev_tbl_in(l_clev).ID:= l_klev_tbl_tmp(v_Index).ID;
      l_clev:=l_clev+1;
    END LOOP;

    --check for deletion allowed on all lines
    for i in 1..l_klev_tbl_in.LAST
    LOOP
           --check if okl contract line delete is allowed
           --dbms_output.put_line('cle id '||to_char(l_klev_tbl_in(i).id));
           kle_delete_allowed(p_cle_id          => l_klev_tbl_in(i).id,
                              x_deletion_type   => l_deletion_type,
                              x_return_status   => x_return_status);

           If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;
           --dbms_output.put_line('l_deletion_type'||l_deletion_type);
           If (l_deletion_type in ('L','N')) Then --logical delete or not allowed
               Exit;
           End If;
     END LOOP;

     If l_deletion_type = 'L' Then
         for i in l_klev_tbl_in.FIRST..l_klev_tbl_in.LAST
         LOOP
             --update line status to 'Abandoned'
             l_clev_rec.id       := l_klev_tbl_in(i).ID;
             l_clev_rec.sts_code := G_OKL_CANCELLED_STS_CODE; --'ABANDONED';
             --l_clev_rec.end_date := sysdate;
             --l_klev_rec.ID       := l_klev_tbl_in(i).ID;
             --dbms_output.put_line('going in for logical delete');
             --dbms_output.put_line('line:'||to_char(l_clev_rec.id));

               okl_okc_migration_pvt.update_contract_line
                 (p_api_version    => p_api_version,
                 p_init_msg_list  => p_init_msg_list,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_clev_rec       => l_clev_rec,
                 x_clev_rec       => l_clev_rec_out
                 );
               --dbms_output.put_line('sts_code :'||l_clev_rec_out.sts_code);
               --dbms_output.put_line('line:'||to_char(l_clev_rec_out.id));

                If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                   raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
                   raise OKL_API.G_EXCEPTION_ERROR;
                End If;

                --Bug # 2522268 Begin
                --do logical deletion of asset number so
                -- old asset number is available for use
                --dbms_output.put_line('Asset_Logical_Delete:'||to_char(l_clev_rec_out.id));
                Asset_Logical_Delete( p_api_version     => p_api_version,
                                      p_init_msg_list   => p_init_msg_list,
                                      x_return_status   => x_return_status,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data,
                                      p_cle_id          => l_clev_rec_out.id,
                                      p_asset_number    => l_clev_rec_out.name);

                If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
                    raise OKL_API.G_EXCEPTION_ERROR;
                End If;

                --do logical deletion of linked assets
                Linked_Asset_Delete(p_api_version     => p_api_version,
                                    p_init_msg_list   => p_init_msg_list,
                                    x_return_status   => x_return_status,
                                    x_msg_count       => x_msg_count,
                                    x_msg_data        => x_msg_data,
                                    p_cle_id          => l_clev_rec_out.id,
                                    p_deletion_type   => l_deletion_type);

                If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
                    raise OKL_API.G_EXCEPTION_ERROR;
                End If;
                --Bug # 2522268 End

                --Bug # 2937980
                Inactivate_Streams
                   ( p_api_version     => p_api_version,
                     p_init_msg_list   => p_init_msg_list,
                     x_return_status   => x_return_status,
                     x_msg_count       => x_msg_count,
                     x_msg_data        => x_msg_data,
                     p_cle_id          => l_clev_rec.id);

                 If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
                    raise OKL_API.G_EXCEPTION_ERROR;
                 End If;
                 --Bug # 2937980

               If (l_clev_rec_out.dnz_chr_id is not null) AND (l_clev_rec_out.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
                    --call API to cascade 'INCOMPLETE' status for lease contracts
                    okl_contract_status_pub.cascade_lease_status_edit
                        (p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_chr_id          => l_clev_rec_out.dnz_chr_id);

                   If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                           raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                           raise OKL_API.G_EXCEPTION_ERROR;
                   End If;

               End If;
          END LOOP;

      ElsIf l_deletion_type = 'P' Then --physical delete
        -- sjalasut added code to raise business event. the cursor is processed here but the actual
        -- event is raised later. the cursor cannot be processed just before raising the event
        -- as the records would have been deleted by that time and no information about the line can
        -- be derived. fetch the line style code for the record

        OPEN  lty_code_csr(p_line_id);
        FETCH lty_code_csr into l_lty_code;
        CLOSE lty_code_csr;


          --get dnz_chr_id
          --call to cascade the status to Incomplete
          --this has to be done first as l_clev_rec.dnz_chr_id will be null
          -- once the line has been deleted.

           Open chr_id_crs(p_cle_id => p_line_id);
               Fetch chr_id_crs into l_dnz_chr_id;
                   If chr_id_crs%NOTFOUND Then
                     null;
                   End If;
           Close chr_id_crs;

          If (l_dnz_chr_id is not null) AND (l_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN

          okl_contract_status_pub.cascade_lease_status_edit
                (p_api_version     => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 p_chr_id          => l_dnz_chr_id);

          If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                  raise OKL_API.G_EXCEPTION_ERROR;
          End If;

          End If;

          --Bug # 2522268 begin
          --physical deletion of linked assets
          --dbms_output.put_line('going in for lnk asst delete '||to_char(p_line_id));
          Linked_Asset_Delete(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               x_return_status   => x_return_status,
                               x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data,
                               p_cle_id          => p_line_id,
                               p_deletion_type   => l_deletion_type);

          If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
          End If;
          --Bug # 2522268 end

          --Bug# 3143522
          --delete associated party payment details
          for i in l_klev_tbl_in.FIRST..l_klev_tbl_in.LAST
          LOOP

              --Bug# 3143522
              --delete associated party payment details
              k := 0;
              open l_get_pyd_csr(p_kle_id => l_klev_tbl_in(i).ID);
              Loop
                  Fetch l_get_pyd_csr into l_pyd_id;
                  Exit when l_get_pyd_csr%NOTFOUND;
                  k := k+1;
                  l_ppydv_tbl(k).id := l_pyd_id;
              End Loop;
              close l_get_pyd_csr;

              If l_ppydv_tbl.COUNT > 0 then
                  OKL_PYD_PVT.delete_row
                   (p_api_version      => p_api_version,
                    p_init_msg_list    => p_init_msg_list,
                    x_return_status    => x_return_status,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_ppydv_tbl        => l_ppydv_tbl);

                 If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                 End If;

                 l_ppydv_tbl.DELETE;

             End If;
         End Loop;
         --Bug# 3143522

       -- Passthru Bug 4350255
        i := 0;
        open l_get_pyh_csr(p_kle_id => p_line_id);
        Loop
            Fetch l_get_pyh_csr into l_pyh_id;
            Exit when l_get_pyh_csr%NOTFOUND;
            i := i+1;
            l_pphv_tbl(i).id := l_pyh_id;
        End Loop;
        close l_get_pyh_csr;

        If l_pphv_tbl.COUNT > 0 then
            OKL_PARTY_PAYMENTS_PVT.DELETE_PARTY_PAYMENT_HDR
             (p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_pphv_tbl         => l_pphv_tbl );

           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

           l_pphv_tbl.DELETE;

       End If;
       -- Passthru Bug 4350255

       --Bug# 4558486
       -- Delete records from okl_k_party_roles
       i := 0;
       For l_klev_count in l_klev_tbl_in.FIRST..l_klev_tbl_in.LAST
       Loop
         For l_kpl_rec in l_kpl_csr(p_kle_id => l_klev_tbl_in(l_klev_count).ID,
                                    p_khr_id => l_dnz_chr_id)
         Loop
           i := i + 1;
           l_kplv_tbl(i).id := l_kpl_rec.id;
         End Loop;
       End Loop;

       If l_kplv_tbl.COUNT > 0 then
           OKL_KPL_PVT.Delete_Row
               (p_api_version      => p_api_version,
                p_init_msg_list    => p_init_msg_list,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data,
                p_kplv_tbl         => l_kplv_tbl);

           If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
               raise OKL_API.G_EXCEPTION_ERROR;
           End If;

           l_kplv_tbl.DELETE;
       End If;
       --Bug# 4558486

        -- call OKC API first to delete contract line
            okc_contract_pub.delete_contract_line(
            p_api_version               => l_api_version,
            p_init_msg_list             => p_init_msg_list,
            x_return_status             => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_line_id           => p_line_id);

          If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                  raise OKL_API.G_EXCEPTION_ERROR;
          End If;

          -- delete transactions hanging fo the lines
          for i in l_klev_tbl_in.FIRST..l_klev_tbl_in.LAST
          LOOP
             l_tas_id := Null;
             l_txl_id := Null;
             OPEN l_get_txl_crs (p_kle_id => l_klev_tbl_in(i).ID);
             FETCH l_get_txl_crs into l_tas_id, l_txl_id;
             If l_get_txl_crs%NOTFOUND Then
                 Null;
             Else
                 --find if any transaction details attached to the txl line
                 l_txd_id := Null;
                 OPEN l_get_txd_crs (p_tal_id => l_txl_id);
                 FETCH l_get_txd_crs INTO l_txd_id;
                 If l_get_txd_crs%NOTFOUND Then
                    Null;
                 Else
                     --delete txd record
                     l_adpv_rec.id := l_txd_id;
                     OKL_TXD_ASSETS_PUB.delete_txd_asset_Def(
                         p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_adpv_rec        => l_adpv_rec);
                      -- check return status
                      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                              raise OKL_API.G_EXCEPTION_ERROR;
                      End If;
                  End If;
                  Close l_get_txd_crs;
                  --delete txl record
                  l_tlpv_rec.id := l_txl_id;
                  OKL_TXL_ASSETS_PUB.delete_txl_asset_Def(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_tlpv_rec      => l_tlpv_rec);
                  -- check return status
                  If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                  End If;

                  --delete tas_record
                  l_thpv_rec.id := l_tas_id;
                  OKL_TRX_ASSETS_PUB.delete_trx_ass_h_Def(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_thpv_rec      => l_thpv_rec);
                  -- check return status
                  If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                     raise OKL_API.G_EXCEPTION_ERROR;
                  End If;
              End If;
           Close l_get_txl_crs;

           --Bug # 2522268
           -- check if any IB transactions are hanging on this line
           l_iti_tas_id := Null;
           l_iti_id     := Null;
           OPEN l_get_iti_csr (p_kle_id => l_klev_tbl_in(i).ID);
           FETCH l_get_iti_csr into l_iti_tas_id, l_iti_id;
           If l_get_iti_csr%NOTFOUND Then
               Null;
           Else

               l_iipv_rec.id := l_iti_id;
               OKL_TXL_ITM_INSTS_PUB.delete_txl_itm_insts(
                               p_api_version   => p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               x_return_status => x_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_iipv_rec      => l_iipv_rec);
               -- check return status
               If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                   raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                   raise OKL_API.G_EXCEPTION_ERROR;
               End If;

               --delete tas_record
               l_iti_thpv_rec.id := l_iti_tas_id;
               OKL_TRX_ASSETS_PUB.delete_trx_ass_h_Def(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_thpv_rec      => l_iti_thpv_rec);
               -- check return status
               If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                   raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                   raise OKL_API.G_EXCEPTION_ERROR;
               End If;

           End If;
           Close l_get_iti_csr;

          --Bug # 2522268 End


          --Bug# 3143522
          --delete associated supplier invoice details
          k := 0;
          open l_get_sid_csr(p_kle_id => l_klev_tbl_in(i).id);
          Loop
              Fetch l_get_sid_csr into l_sid_id;
              Exit when l_get_sid_csr%NOTFOUND;
              k := k+1;
              l_sidv_tbl(k).id := l_sid_id;
          End Loop;
          close l_get_sid_csr;

          If l_sidv_tbl.COUNT > 0 then
              OKL_SUPP_INVOICE_DTLS_PUB.delete_sup_inv_dtls
               (p_api_version      => p_api_version,
                p_init_msg_list    => p_init_msg_list,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data,
                p_sidv_tbl         => l_sidv_tbl);

             If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                 raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                 raise OKL_API.G_EXCEPTION_ERROR;
             End If;

             l_sidv_tbl.DELETE;

         End If;
         --Bug# 3143522 End

           END LOOP;

          -- delete shadows
          OKL_KLE_PVT.delete_row(
              p_api_version                => l_api_version,
              p_init_msg_list        => p_init_msg_list,
              x_return_status        => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data,
              p_klev_tbl                => l_klev_tbl_in);

          If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                  raise OKL_API.G_EXCEPTION_ERROR;
          End If;

    Elsif l_deletion_type = 'N' Then-- not allowed will not come here as this situation will raise error
          Null;
    End If;

   /*
   -- vthiruva, 08/19/2004
   -- START, Code change to enable Business Event
   */
    -- raise business event for delete of asset line
    IF(l_lty_code = 'FREE_FORM1')THEN
      -- raise business event only if the context contract is a lease contract
      l_raise_business_event := OKL_LLA_UTIL_PVT.is_lease_contract(l_dnz_chr_id);
      IF(l_raise_business_event = OKL_API.G_TRUE)THEN
        -- raise the business event for create asset, if line style code is FREE_FORM1
        wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_dnz_chr_id,l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,p_line_id,l_parameter_list);
        l_business_event_name := G_WF_EVT_ASSET_REMOVED;
      END IF;
    END IF;

    IF(l_raise_business_event = OKL_API.G_TRUE AND l_business_event_name IS NOT NULL)THEN
      raise_business_event(p_api_version    => p_api_version,
                          p_init_msg_list  => p_init_msg_list,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_event_name     => l_business_event_name,
                          p_parameter_list => l_parameter_list);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
   /*
   -- vthiruva, 08/19/2004
   -- END, Code change to enable Business Event
   */

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);

  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : deletes sublines based on parameter p_delete_cascade_yn
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_delete_cascade_yn           IN  VARCHAR2) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_clev_rec_out okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec_out klev_rec_type;

    l_api_name                      CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version                       CONSTANT NUMBER          := 1.0;
    l_return_status                 VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    If p_delete_cascade_yn = 'Y' Then

         delete_contract_line(p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_line_id        => l_klev_rec.id);

         If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
             raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
             raise OKL_API.G_EXCEPTION_ERROR;
         End If;

    ElsIf p_delete_cascade_yn = 'N' Then
          delete_contract_line(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               x_return_status   => x_return_status,
                               x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data,
                               p_clev_rec        => l_clev_rec,
                               p_klev_rec        => p_klev_rec);

         If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
             raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
             raise OKL_API.G_EXCEPTION_ERROR;
         End If;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : deletes sublines based on parameter p_delete_cascade_yn
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_delete_cascade_yn           IN  varchar2) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (p_clev_tbl.COUNT > 0) Then
           i := p_clev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                delete_contract_line(
                        p_api_version                 => p_api_version,
                        p_init_msg_list                 => p_init_msg_list,
                        x_return_status          => x_return_status,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data,
                        p_clev_rec                     => p_clev_tbl(i),
                p_klev_rec                     => l_klev_tbl(i),
            p_delete_cascade_yn => p_delete_cascade_yn);

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
                i := p_clev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : lock_contract_line
-- Description     : locks contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.lock_contract_line(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_clev_rec                => l_clev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record
    l_klev_rec.ID := l_clev_rec.ID;

    -- call procedure in complex API
        OKL_KLE_PVT.Lock_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_klev_rec          => l_klev_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END lock_contract_line;


-- Start of comments
--
-- Procedure Name  : lock_contract_line
-- Description     : locks contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'lock_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (p_clev_tbl.COUNT > 0) Then
           i := p_clev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                lock_contract_line(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_rec                => p_clev_tbl(i),
                p_klev_rec                => l_klev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
                i := p_clev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END lock_contract_line;


-- Start of comments
--
-- Procedure Name  : validate_contract_line
-- Description     : validates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.validate_contract_line(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_clev_rec                => l_clev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record
    l_klev_rec.ID := l_clev_rec.ID;

    -- call procedure in complex API
        OKL_KLE_PVT.validate_Row(
              p_api_version        => p_api_version,
              p_init_msg_list        => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_klev_rec          => l_klev_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END validate_contract_line;


-- Start of comments
--
-- Procedure Name  : validate_contract_line
-- Description     : validates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'validate_CONTRACT_LINE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_klev_tbl                  klev_tbl_type := p_klev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (p_clev_tbl.COUNT > 0) Then
           i := p_clev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                validate_contract_line(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_rec                => p_clev_tbl(i),
                p_klev_rec                => l_klev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
                i := p_clev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END validate_contract_line;
--------------------------------------------------------------------------------
--governances related procedures
--------------------------------------------------------------------------------
 PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN  okl_okc_migration_pvt.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY okl_okc_migration_pvt.gvev_rec_type) IS

    l_gvev_rec okl_okc_migration_pvt.gvev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

        --dbms_output.put_line('Start it');

    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_gvev_rec := p_gvev_rec;
    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing
        --dbms_output.put_line('Set org context');


    --OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);

        --dbms_output.put_line('Create governance');
    --
    -- call procedure in complex API
    --
    --OKC_CONTRACT_PUB.create_contract_header(
    okl_okc_migration_pvt.create_governance(
         p_api_version            => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_gvev_rec                    => l_gvev_rec,
         x_gvev_rec                    => x_gvev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (x_gvev_rec.dnz_chr_id is not null) AND (x_gvev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then
          --call API to cascade 'INCOMPLETE' status for lease contracts
          okl_contract_status_pub.cascade_lease_status_edit
                 (p_api_version     => p_api_version,
                  p_init_msg_list   => p_init_msg_list,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_chr_id          => x_gvev_rec.dnz_chr_id);

          If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                  raise OKL_API.G_EXCEPTION_ERROR;
          End If;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END create_governance;


-- Start of comments
--
-- Procedure Name  : create_contract_header
-- Description     : creates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN  okl_okc_migration_pvt.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY okl_okc_migration_pvt.gvev_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status         VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                               NUMBER;
    l_gvev_tbl                  okl_okc_migration_pvt.gvev_tbl_type := p_gvev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_gvev_tbl.COUNT > 0) Then
           i := p_gvev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                create_governance(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_gvev_rec                    => p_gvev_tbl(i),
                x_gvev_rec                   =>  x_gvev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
                i := p_gvev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(       x_msg_count        => x_msg_count,
                                x_msg_data        => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END create_governance;

-- Start of comments
--
-- Procedure Name  : update_governance
-- Description     : updates governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN  okl_okc_migration_pvt.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY okl_okc_migration_pvt.gvev_rec_type) IS

    l_gvev_rec okl_okc_migration_pvt.gvev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_gvev_rec := p_gvev_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    --OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);

    --
    -- call procedure in complex API
    --
--    OKC_CONTRACT_PUB.update_contract_header(
     okl_okc_migration_pvt.update_governance(
         p_api_version            => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
     p_gvev_rec             => l_gvev_rec,
         x_gvev_rec                    => x_gvev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If (x_gvev_rec.dnz_chr_id is not null) AND (x_gvev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then
       --call API to cascade 'INCOMPLETE' status for lease contracts
          okl_contract_status_pub.cascade_lease_status_edit
                 (p_api_version     => p_api_version,
                  p_init_msg_list   => p_init_msg_list,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_chr_id          => x_gvev_rec.dnz_chr_id);

          If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
                  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
                  raise OKL_API.G_EXCEPTION_ERROR;
          End If;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);



    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);


  END update_governance;


-- Start of comments
--
-- Procedure Name  : update_governance
-- Description     : update governance for table type records
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN  okl_okc_migration_pvt.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY okl_okc_migration_pvt.gvev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_gvev_tbl                  okl_okc_migration_pvt.gvev_tbl_type := p_gvev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_gvev_tbl.COUNT > 0) Then
           i := p_gvev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                update_governance(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_gvev_rec                    => p_gvev_tbl(i),
                        x_gvev_rec                    => x_gvev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
                i := p_gvev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END update_governance;

-- Start of comments
--
-- Procedure Name  : delete_governance
-- Description     : deletes governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN  okl_okc_migration_pvt.gvev_rec_type) IS

    l_gvev_rec      okl_okc_migration_pvt.gvev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;

    --cursor to find out chr id required to flip status at edit point
    CURSOR chr_id_crs (p_gve_id IN NUMBER) is
    SELECT DNZ_CHR_ID
    FROM   OKC_GOVERNANCES
    WHERE  ID = P_GVE_ID;

    l_dnz_chr_id   OKC_GOVERNANCES.dnz_chr_id%TYPE;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_gvev_rec := p_gvev_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    --OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);
   If (l_gvev_rec.dnz_chr_id is null) OR (l_gvev_rec.dnz_chr_id = OKL_API.G_MISS_NUM) Then
      Open chr_id_crs(p_gve_id => l_gvev_rec.id);
          FETCH chr_id_crs into l_dnz_chr_id;
          If chr_id_crs%NOTFOUND THEN
              NULL;
          End If;
      Close chr_id_crs;
   Else
       l_dnz_chr_id := l_gvev_rec.dnz_chr_id;
   End If;

   If (l_dnz_chr_id is not null) And (l_dnz_chr_id <> OKL_API.G_MISS_NUM) Then
    --call API to cascade 'INCOMPLETE' status for lease contracts
    okl_contract_status_pub.cascade_lease_status_edit
                 (p_api_version     => p_api_version,
                  p_init_msg_list   => p_init_msg_list,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_chr_id          => l_dnz_chr_id);

     If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
              raise OKL_API.G_EXCEPTION_ERROR;
     End If;
    End If;
    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.delete_governance(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_gvev_rec                    => l_gvev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;


    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END delete_governance;


-- Start of comments
--
-- Procedure Name  : delete_governance
-- Description     : deletes governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN  okl_okc_migration_pvt.gvev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_gvev_tbl                  okl_okc_migration_pvt.gvev_tbl_type := p_gvev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_gvev_tbl.COUNT > 0) Then
           i := p_gvev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                delete_governance(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_gvev_rec                => p_gvev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
                i := p_gvev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END delete_governance;

-- Start of comments
--
-- Procedure Name  : lock_governance
-- Description     : locks governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type) IS

    l_gvev_rec okl_okc_migration_pvt.gvev_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_gvev_rec := p_gvev_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    --OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);


    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.lock_governance(
         p_api_version            => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_gvev_rec                    => l_gvev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END lock_governance;


-- Start of comments
--
-- Procedure Name  : lock_governance
-- Description     : locks governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
   PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'LOCK_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_gvev_tbl                  okl_okc_migration_pvt.gvev_tbl_type := p_gvev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_gvev_tbl.COUNT > 0) Then
           i := p_gvev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                lock_governance(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_gvev_rec                => p_gvev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
                i := p_gvev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END lock_governance;

-- -----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_governance
-- Description     : validates governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type) IS

    l_gvev_rec okl_okc_migration_pvt.gvev_rec_type;


    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_GOVERNANCE';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

        --dbms_output.put_line('Start validation');
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

        --dbms_output.put_line('Started activity');

    l_gvev_rec := p_gvev_rec;

    --
    -- set okc context before API call
    -- msamoyle: check whether we need to call this method here or in PUB or in processing

    --OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);
        --dbms_output.put_line('Set up context');

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.validate_governance(
         p_api_version        => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_gvev_rec                => l_gvev_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;
        --dbms_output.put_line('Got standard validation');

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
        --dbms_output.put_line('Done');
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END validate_governance;


-- Start of comments
--
-- Procedure Name  : validate_governance
-- Description     : validates governance for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN  okl_okc_migration_pvt.gvev_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'validate_CONTRACT_HEADER';
    l_api_version               CONSTANT NUMBER          := 1.0;
    l_return_status     VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)                  := OKL_API.G_RET_STS_SUCCESS;
    i                           NUMBER;
    l_gvev_tbl                  okl_okc_migration_pvt.gvev_tbl_type := p_gvev_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;

    End If;

    If (p_gvev_tbl.COUNT > 0) Then
           i := p_gvev_tbl.FIRST;
           LOOP
                -- call procedure in complex API for a record
                validate_governance(
                        p_api_version                => p_api_version,
                        p_init_msg_list                => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_gvev_rec                    => p_gvev_tbl(i));

                If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
                i := p_gvev_tbl.NEXT(i);
           END LOOP;

           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
          raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                                 x_msg_data                => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END validate_governance;
--------------------------------------------------------------------------------
--APi to get contract header information for OKL
--Bug 2471750 : If cust account is not found for subcalss quote  error will not
-- be raised
--bug# 2471750 : Even if cust account soes not exist for QUOTE - party name is
-- to be fetched for the header jsp. for this purpose get_private_label loacal
-- function made generic for all the parties and renamed GET_PARTY. Now is it
-- used to fetch 'LESSEE' name as well as 'PRIVATE_LABEL'
--------------------------------------------------------------------------------
  Procedure get_contract_header_info(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_chr_id_old                   IN  NUMBER,
    p_orgId                        IN  NUMBER,
    p_custId                       IN  NUMBER,
    p_invOrgId                     IN  NUMBER,
    p_oldOKL_STATUS                IN  VARCHAR2,
    p_oldOKC_STATUS                IN  VARCHAR2,
    x_hdr_tbl                      OUT NOCOPY hdr_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'GET_CONTRACT_HEADER_INFO';
    l_api_version       CONSTANT NUMBER       := 1;
    l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    Cursor status_csr( chrId NUMBER ) IS
    select a.ste_code,
           a.code,
           cst.meaning,
           b.scs_code,
           b.currency_code,
           --Bug# 2857899
           nvl(b.template_yn,'N') template_yn
    from okc_statuses_b a,
         okc_k_headers_b b,
         okl_k_headers c,
         OKC_STATUSES_TL cst
    where b.id = c.id
       and b.id = chrId
       and a.CODE = b.STS_CODE
       and cst.code = a.code
       and cst.LANGUAGE = userenv('LANG');


   status_rec       status_csr%ROWTYPE;
   l_scs_code       okc_k_headers_b.scs_code%TYPE;
   l_currency_code  okc_k_headers_b.currency_code%TYPE;
   --bug# 2857899
   l_template_yn    okc_k_headers_b.template_yn%TYPE;

   Cursor chr_csr ( chrId NUMBER ) IS
   select khr.SHORT_DESCRIPTION,
          khr.CONTRACT_NUMBER,
          khr.PROGRAM_NAME,
          khr.PRODUCT_NAME,
          khr.PDT_ID,
          khr.ID,
          khr.AUTHORING_ORG_ID,
          khr.PRODUCT_DESCRIPTION,
          khr.INV_ORG_ID,
          khr.START_DATE,
          khr.END_DATE,
          cst.MEANING,
	  --Added by dpsingh for LE Project
	  khr.LEGAL_ENTITY_ID
   from OKL_LA_HEADERS_UV khr,
        OKC_STATUSES_TL cst
   where khr.ID = chrId
       and cst.CODE = khr.STS_CODE
       and cst.LANGUAGE = userenv('LANG');

   chr_rec chr_csr%ROWTYPE;


   -------------------------------------------------------
   --Bug# 3124577 : 11.5.10 Rule Migration
   -- new cust csr will fetch customet account from OKC_K_HEADERS_B
   --------------------------------------------------------
   Cursor cust_csr ( chrId IN NUMBER) IS
   SELECT CHRB.CURRENCY_CODE,
          CHRB.AUTHORING_ORG_ID,
          CHRB.INV_ORGANIZATION_ID,
          CHRB.BUY_OR_SELL,
          CHRB.CUST_ACCT_ID,
          CUS.NAME,
          CUS.DESCRIPTION
   FROM   OKC_K_HEADERS_B         CHRB,
          OKX_CUSTOMER_ACCOUNTS_V CUS
   WHERE CUS.ID1    = CHRB.cust_acct_id
   AND   CHRB.ID    = chrId;


   cust_rec cust_csr%ROWTYPE;
   x_value           NUMBER;
   l_synd            VARCHAR2(256);
   l_priv            VARCHAR2(256);
   l_lessee          VARCHAR2(360);

   -------------------------------------------------------
   --Bug# 4748777 : 11.5.10 Change from Program short
   -- description to program number in the common header
   --------------------------------------------------------
   l_prog_num    OKC_K_HEADERS_B.CONTRACT_NUMBER%type := null;
   Cursor prog_num_csr ( p_chr_id IN NUMBER) IS
   select prog.contract_number
   from OKL_K_HEADERS KHR,
        OKC_K_HEADERS_B PROG
   where PROG.ID = KHR.KHR_ID
   and  khr.id = p_chr_id;

   -------------------------------------------------------
   --Bug# 3455354 : 11.5.10 CHANGE SYNDICATION FLAG ON CONTRACT HEADER
   -- get investor flag for common header
   --------------------------------------------------------
   l_investor_flag okl_k_headers.SECURITIZED_CODE%type := null;
   Cursor investor_csr ( p_chr_id IN NUMBER) IS
   select SECURITIZED_CODE
   from okl_k_headers khr
   where khr.id = p_chr_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_syndicate_flag
  ---------------------------------------------------------------------------
  FUNCTION get_syndicate_flag(
     p_contract_id      IN NUMBER,
     x_syndicate_flag   OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    -- A complex query to find out if a contract has syndication
    CURSOR syndicate_flag_csr(p_contract_id NUMBER) IS
      SELECT 'Y'  FROM okc_k_headers_b chr
      WHERE id = p_contract_id
      AND EXISTS
          (
           SELECT 'x' FROM okc_k_items cim
           WHERE  cim.object1_id1 = to_char(chr.id)
           AND    EXISTS
                  (
                   SELECT 'x' FROM okc_k_lines_b cle, okc_line_styles_b lse
                   WHERE  cle.lse_id = lse.id
                   AND    lse.lty_code = 'SHARED'
                   AND    cle.id = cim.cle_id
                  )
           AND    EXISTS
                  (
                   SELECT 'x' FROM okc_k_headers_b chr2
                   WHERE  chr2.id = cim.dnz_chr_id
                   AND    chr2.scs_code = 'SYNDICATION'
                   AND    chr2.sts_code not in ('TERMINATED','ABANDONED')
                  )
          )
      AND chr.scs_code in ('LEASE','LOAN');

    l_syndicate_flag    VARCHAR2(1) := 'N';
    l_api_version       NUMBER;
    l_return_status     VARCHAR2(1) := Okl_API.G_RET_STS_SUCCESS;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

  BEGIN

    OPEN  syndicate_flag_csr(p_contract_id);
    FETCH syndicate_flag_csr INTO l_syndicate_flag;
    CLOSE syndicate_flag_csr;

    x_syndicate_flag := l_syndicate_flag;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_syndicate_flag;

  ---------------------------------------------------------------------------
  -- FUNCTION get party
  ---------------------------------------------------------------------------
  FUNCTION get_party(
     p_contract_id              IN  NUMBER,
     p_rle_code         IN  VARCHAR2,
     x_party_name       OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_api_version           NUMBER := 1.0;
    l_init_msg_list         VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_party_tab             OKL_JTOT_EXTRACT.party_tab_type;
  BEGIN

    -- Procedure to call to get Private Label ID, nothing but
    -- a Role
    OKL_JTOT_EXTRACT.Get_Party (
          l_api_version,
          l_init_msg_list,
          l_return_status,
          l_msg_count,
          l_msg_data,
          p_contract_id,
          null,
          --'PRIVATE_LABEL',
          p_rle_code,
          'S',
          l_party_tab
          );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    IF l_party_tab.FIRST IS NOT NULL
    THEN --fetch from table only if some data is retrieved
      FOR i in 1..l_party_tab.LAST
      LOOP
        --x_private_label := l_party_tab(i).id1;
        --x_private_label := l_party_tab(i).name;
        x_party_name := l_party_tab(i).name;
      END LOOP;
    ELSE
      x_party_name := NULL;
    END IF;

    RETURN l_return_status;
    EXCEPTION
        when OKL_API.G_EXCEPTION_ERROR then
                l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

        when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
                l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

        when OTHERS then
        l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);


  END get_party;



  BEGIN

    OPEN  status_csr( p_chr_id );
    FETCH status_csr INTO status_rec;
    if (status_csr%NOTFOUND ) Then
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    End If;
    CLOSE status_csr;

    l_scs_code      := status_rec.scs_code;
    l_currency_code := status_rec.currency_code;
    --Bug Fix# 2857899
    l_template_yn   := status_rec.template_yn;

    If ( ( nvl(p_chr_id,0) <>  0 )
             AND ((nvl(p_chr_id_old,0) = 0)
                  OR  (nvl(p_orgId,0) =  0)
                  OR  (nvl(p_custId,0) = 0)
                  OR  (nvl(p_invOrgId,0) = 0)
                  OR  ( status_rec.ste_code <> p_oldOKC_STATUS)
                  OR  ( status_rec.code <> p_oldOKL_STATUS )
                  OR  ( p_chr_id <> p_chr_id_old) )) Then

        OPEN  chr_csr( p_chr_id );
        FETCH chr_csr INTO chr_rec;
        if (chr_csr%NOTFOUND ) Then
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
        CLOSE chr_csr;

        OPEN  prog_num_csr( p_chr_id );
        FETCH prog_num_csr INTO l_prog_num;
        CLOSE prog_num_csr;

        x_hdr_tbl(1) := chr_rec.short_description;

        x_hdr_tbl(2) := chr_rec.product_description;
        x_hdr_tbl(3) := chr_rec.start_date;
        x_hdr_tbl(4) := chr_rec.end_date;
        x_hdr_tbl(5) := chr_rec.meaning;
        x_hdr_tbl(6) := chr_rec.contract_number;
        x_hdr_tbl(7) := l_prog_num;
--        x_hdr_tbl(7) := chr_rec.program_name;
        x_hdr_tbl(8) := chr_rec.product_name;
        x_hdr_tbl(9) := chr_rec.inv_org_id;
        x_hdr_tbl(10) := chr_rec.pdt_id;
        x_hdr_tbl(11) := chr_rec.id;



        ---------------------------------------------
        --Bug# 3124577: 11.5.10 : Rule migration
        --------------------------------------------
        OPEN cust_csr(p_chr_id);
        FETCH cust_csr into cust_rec;
        if (cust_csr%NOTFOUND ) Then
            --for bug# 2471750 :special treatment for QUOTE
            If l_scs_code <> 'QUOTE' Then
                --Bug# 2857899
                If l_template_yn <> 'Y' Then
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                Elsif l_template_yn = 'Y' Then
                    x_hdr_tbl(12) := Null;
                    x_hdr_tbl(13) := Null;
                    x_hdr_tbl(14) := Null;

                    x_hdr_tbl(15) := l_currency_code;

                    l_return_status := get_party(p_chr_id,'LESSEE', l_lessee);
                    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) Then
                        x_hdr_tbl(16) := l_lessee;
                    ELSE
                        x_hdr_tbl(16) := '';
                    END IF;

                    x_hdr_tbl(17) := '';
                End If;
            Elsif l_scs_code = 'QUOTE' Then
               x_hdr_tbl(12) := Null;
               x_hdr_tbl(13) := Null;
               x_hdr_tbl(14) := Null;

               x_hdr_tbl(15) := l_currency_code;

               l_return_status := get_party(p_chr_id,'LESSEE', l_lessee);
               IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) Then
                   x_hdr_tbl(16) := l_lessee;
               ELSE
                   x_hdr_tbl(16) := '';
               END IF;

               x_hdr_tbl(17) := '';
            End If;
        Else
            x_hdr_tbl(12) := cust_rec.cust_acct_id;
            x_hdr_tbl(13) := 'OKX_CUSTACCT';
            x_hdr_tbl(14) := '#';


            x_hdr_tbl(15) := cust_rec.currency_code;
            x_hdr_tbl(16) := cust_rec.name;
            x_hdr_tbl(17) := cust_rec.description;

        End If;
        CLOSE cust_csr;
        --CLOSE rule_csr;

--commented for bug# 2471750
--        x_hdr_tbl(12) := rule_rec.object1_id1;
--        x_hdr_tbl(13) := rule_rec.jtot_object1_code;
--        x_hdr_tbl(14) := rule_rec.object2_id2;


--        OPEN  cust_csr( rule_rec.jtot_object1_code,
--                        p_chr_id,
--                        rule_rec.object1_id1 );
--        FETCH cust_csr INTO cust_rec;
--        if (cust_csr%NOTFOUND ) Then
--            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
--        End If;
--        CLOSE cust_csr;

--        x_hdr_tbl(15) := cust_rec.currency_code;
--        x_hdr_tbl(16) := cust_rec.name;
--        x_hdr_tbl(17) := cust_rec.description;
--commented for bug# 2471750

        If (( status_rec.ste_code = 'ENTERED' ) OR ( status_rec.ste_code= 'SIGNED' )) Then
            x_hdr_tbl(18) := 'Y';
        Else
            x_hdr_tbl(18) := 'N';
        End If;

        --l_return_status := okl_contract_info_pvt.get_syndicate_flag(p_chr_id, l_synd);

        -- Bug# 3455354
        l_investor_flag := null;
        OPEN  investor_csr( p_chr_id );
        FETCH investor_csr INTO l_investor_flag;
        CLOSE investor_csr;

        IF (l_investor_flag is not null and l_investor_flag = 'Y') Then
            x_hdr_tbl(19) := l_investor_flag;
        ELSE
            x_hdr_tbl(19) := 'N';
        END IF;

        --l_return_status := okl_contract_info_pvt.get_private_label(p_chr_id, l_priv);
        --l_return_status := get_private_label(p_chr_id, l_priv);
        l_return_status := get_party(p_chr_id,'PRIVATE_LABEL', l_priv);
        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) Then
            x_hdr_tbl(20) := l_priv;
        ELSE
            x_hdr_tbl(20) := '';
        END IF;

        x_hdr_tbl(21) := status_rec.ste_code;
        x_hdr_tbl(22) := status_rec.code;

        x_hdr_tbl(23) := chr_rec.authoring_org_id;
       --Added by dpsingh for LE Project
	x_hdr_tbl(24) := chr_rec.legal_entity_id;
    Else
       x_hdr_tbl(1) := 'GET_FROM_REQUEST';
    End if;

    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    Exception
        when OKL_API.G_EXCEPTION_ERROR then
                x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

        when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
                x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

        when OTHERS then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);


  END get_contract_header_info;
END OKL_CONTRACT_PVT;

/
