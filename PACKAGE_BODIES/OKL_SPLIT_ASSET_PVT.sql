--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_ASSET_PVT" AS
/* $Header: OKLRSPAB.pls 120.61.12010000.10 2010/04/07 06:21:22 bkatraga ship $ */
--------------------------------------------------------------------------------
--GLOBAL VARIBLES
--------------------------------------------------------------------------------
G_FIN_AST_LTY_CODE           CONSTANT VARCHAR2(30) := 'FREE_FORM1';
--------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
--------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN           CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  -- Bug# 4542290 - smadhava - Added - Start
  G_METHOD  CONSTANT VARCHAR2(200) := 'METHOD';
  -- Bug# 4542290 - smadhava - Added - End
--------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
--------------------------------------------------------------------------------
G_INVALID_TOP_LINE             CONSTANT VARCHAR2(200) := 'OKL_LLA_LINE_STYLE';
G_TOP_LINE_STYLE               CONSTANT VARCHAR2(30)  := 'TLS';
G_SPLIT_ASSET_NOT_FOUND        CONSTANT VARCHAR2(200) := 'OKL_LLA_SPLIT_ASSET_NOT_FOUND';
G_SPLIT_AST_TRX_NOT_FOUND      CONSTANT VARCHAR2(200) := 'OKL_LLA_SPLIT_AST_TRX';
G_SPLIT_PARENT_NUMBER_CHANGE   CONSTANT VARCHAR2(200) := 'OKL_LLA_SPLIT_PARENT_NUMBER';
G_LTY_CODE_NOT_FOUND           CONSTANT VARCHAR2(200) := 'OKL_LLA_SPLIT_PARENT_NUMBER';
G_NO_DATA_FOUND                CONSTANT VARCHAR2(200) := 'OKL_NO_DATA_FOUND';
G_INACTIVE_ASSET               CONSTANT VARCHAR2(200) := 'OKL_LLA_INACTIVE_ASSET';
G_SPLIT_ASSET_TRX              CONSTANT VARCHAR2(200) := 'OKL_LLA_PEND_SPLT_AST_TRX';
G_SPLIT_AST_COMP_TRX           CONSTANT VARCHAR2(200) := 'OKL_LLA_PEND_SPLT_COMP_TRX';
G_ASSET_REQUIRED               CONSTANT VARCHAR2(200) := 'OKL_LLA_ASSET_REQUIRED';
G_DUPLICATE_ASSET              CONSTANT VARCHAR2(200) := 'OKL_LLA_ASSET_NUMBER';
G_ASSET_LENGTH                 CONSTANT VARCHAR2(200) := 'OKL_LLA_AST_LEN';
G_NOT_UNIQUE                   CONSTANT VARCHAR2(30)  := 'OKL_LLA_NOT_UNIQUE';
G_SINGLE_UNIT_ASSET            CONSTANT VARCHAR2(200) := 'OKL_LLA_SINGLE_UNIT_SPLIT';

--Added by bkatraga for bug 9548880
G_SPLIT_UNIT_NOT_ALLWD         CONSTANT VARCHAR2(200) := 'OKL_LLA_SPLIT_UNIT_NOT_ALLWD';
--end bkatraga

-- Bug# 4542290 - smadhava - Added - Start
G_RRB_SPLIT_ASSET_NOT_ALLWD    CONSTANT VARCHAR2(200) := 'OKL_LLA_RRB_SPLIT_NOT_ALLWD';
-- Bug# 4542290 - smadhava - Added - End
--------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
--------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

 -- GLOBAL VARIABLES
--------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_SPLIT_ASSET_PVT';
  G_TRY_NAME                              OKL_TRX_TYPES_V.NAME%TYPE       := 'Split Asset';
  G_TRY_TYPE                              OKL_TRX_TYPES_V.TRY_TYPE%TYPE   := 'TIE';
--------------------------------------------------------------------------------
--Globals for csi item instance
--------------------------------------------------------------------------------
G_IB_TXN_TYPE_NOT_FOUND     CONSTANT VARCHAR2(200) := 'OKL_LLA_IB_TXN_TYPE_NOT_FOUND';
G_TXN_TYPE_TOKEN            CONSTANT VARCHAR2(30)  := 'TXN_TYPE';
G_ITM_INST_PARTY            CONSTANT VARCHAR2(30)  := 'LESSEE';
G_CONTRACT_INTENT           CONSTANT VARCHAR2(1)   := 'S';
G_PARTY_SRC_TABLE           CONSTANT VARCHAR2(30)  := 'HZ_PARTIES';
G_PARTY_RELATIONSHIP        CONSTANT VARCHAR2(30)  := 'OWNER';
G_PARTY_NOT_FOUND           CONSTANT VARCHAR2(200) := 'OKL_LLA_PARTY_NOT_FOUND';
G_ROLE_CODE_TOKEN           CONSTANT VARCHAR2(30)  := 'RLE_CODE';
G_CUST_ACCT_RULE            CONSTANT VARCHAR2(30)  := 'CAN';
G_CUST_ACCT_RULE_GROUP      CONSTANT VARCHAR2(30)  := 'LACAN';
G_CONTRACT_ID_TOKEN         CONSTANT VARCHAR2(200) := 'CONTRACT_ID';
G_IB_SPLIT_TXN_TYPE         CONSTANT VARCHAR2(30)  := 'OKL_SPLITA';
G_CUST_ACCOUNT_FOUND        CONSTANT VARCHAR2(200) := 'OKL_LLA_CUST_ACCT_NOT_FOUND';
--------------------------------------------------------------------------------
--Bug#2723498 : 11.5.9 Enhancement Split asset by serial numbers message constants
--------------------------------------------------------------------------------
G_IB_INSTANCE_MISMATCH        CONSTANT VARCHAR2(200) := 'OKL_LLA_SPA_INSTANCE_MISMATCH';
G_IB_LINE_TOKEN               CONSTANT VARCHAR2(200) := 'IB_LINE_ID';
G_ASSET_NUMBER_TOKEN          CONSTANT VARCHAR2(200) := 'ASSET_NUMBER';
G_SPLIT_SERIAL_NOT_FOUND      CONSTANT VARCHAR2(200) := 'OKL_LLA_SPA_SERIAL_NOT_FOUND';
G_SPLIT_UNITS_TOKEN           CONSTANT VARCHAR2(200) := 'SPLIT_UNITS';
G_SRL_NUM_DUPLICATE           CONSTANT VARCHAR2(200) := 'OKL_LLA_SERIAL_NUM_DUP';
G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
G_ASSET_NOT_SERIALIZED        CONSTANT VARCHAR2(200) := 'OKL_LLA_SPA_NOT_SERIALIZED';
--Bug Fix # 2881114
G_ASSET_LINKED_TO_SERVICE     CONSTANT VARCHAR2(200) := 'OKL_LLA_SPA_SERVICE_LINKED';
--Bug# : 11.5.10
G_FORMULA_OEC                           OKL_FORMULAE_V.NAME%TYPE := 'LINE_OEC';
G_FORMULA_CAP                           OKL_FORMULAE_V.NAME%TYPE := 'LINE_CAP_AMNT';
G_FORMULA_RES                           OKL_FORMULAE_V.NAME%TYPE := 'LINE_RESIDUAL_VALUE';
--Bug# 3222804 : serial number control by leasing inv org setups
G_SERIALIZED_IN_IB            CONSTANT VARCHAR2(200) := 'OKL_SERIAL_CONTROL_MISMATCH';
G_NOT_SERIALIZED_IN_IB        CONSTANT VARCHAR2(200) := 'OKL_SERIAL_CONTROL_MISMATCH_2';
G_SERIAL_NUMBER_MISMATCH      CONSTANT VARCHAR2(200) := 'OKL_SERIAL_NUMBER_MISMATCH';

--Bug# 3156924 :
 G_LLA_MISSING_TRX_DATE     CONSTANT VARCHAR2(200) := 'OKL_LLA_MISSING_TRX_DATE';
 G_LLA_WRONG_TRX_DATE       CONSTANT VARCHAR2(200) := 'OKL_LLA_WRONG_TRX_DATE';
 G_LLA_REV_ONLY_BOOKED      CONSTANT VARCHAR2(200) := 'OKL_LLA_REV_ONLY_BOOKED';
 G_LLA_INVALID_DATE_FORMAT  CONSTANT VARCHAR2(200) := 'OKL_LLA_INVALID_DATE_FORMAT';

--BUG# 3569441
  G_INVALID_INSTALL_LOC_TYPE CONSTANT VARCHAR2(200) := 'OKL_INVALID_INSTALL_LOC_TYPE';
  G_LOCATION_TYPE_TOKEN      CONSTANT VARCHAR2(30)  := 'LOCATION_TYPE';
  G_LOC_TYPE1_TOKEN          CONSTANT VARCHAR2(30)  := 'LOCATION_TYPE1';
  G_LOC_TYPE2_TOKEN          CONSTANT VARCHAR2(30)  := 'LOCATION_TYPE2';

  G_MISSING_USAGE            CONSTANT VARCHAR2(200) := 'OKL_INSTALL_LOC_MISSING_USAGE';
  G_USAGE_TYPE_TOKEN         CONSTANT VARCHAR2(30)  := 'USAGE_TYPE';
  G_ADDRESS_TOKEN            CONSTANT VARCHAR2(30)  := 'ADDRESS';
  G_INSTANCE_NUMBER_TOKEN    CONSTANT VARCHAR2(30)  := 'INSTANCE_NUMBER';
--END BUG# 3569441

   /*
   -- mvasudev, 08/23/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_SPLIT_ASSET_REQ  CONSTANT VARCHAR2(64) := 'oracle.apps.okl.la.lease_contract.split_asset_by_units_requested';
   G_WF_EVT_KHR_SPLIT_ASSET_COMP CONSTANT VARCHAR2(64) := 'oracle.apps.okl.la.lease_contract.split_asset_by_units_completed';

   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(20)  := 'CONTRACT_ID';
   G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(10)  := 'ASSET_ID';
   G_WF_ITM_TRANS_DATE CONSTANT VARCHAR2(20)    := 'TRANSACTION_DATE';
   -- Bug# 4542290 - smadhava - Added - Start
   G_RRB_ESTIMATED CONSTANT OKL_PQY_VALUES_V.VALUE%TYPE := 'ESTIMATED_AND_BILLED';
   G_RRB_ACTUAL     CONSTANT OKL_PQY_VALUES_V.VALUE%TYPE := 'ACTUAL';
  -- Bug# 4542290 - smadhava - Added - End

--Bug# 6612475 Start
------------------------------------------------------------------------------
--Bug # 6612475
--API Name    : Validate_Split_Request
--Description : This will validate the split asset request parameters
--              and will be called from Create_Split_Transaction
-- History    :
--              07-May-2008   avsingh   Creation
--
-- End of Comments
-----------------------------------------------------------------------------
  Procedure Validate_Split_Request
     (p_api_version    IN  NUMBER
     ,p_init_msg_list  IN  VARCHAR2
     ,x_return_status  OUT NOCOPY VARCHAR2
     ,x_msg_count      OUT NOCOPY NUMBER
     ,x_msg_data       OUT NOCOPY VARCHAR2
     ,p_cle_id         IN  NUMBER
     ,p_split_into_individuals_yn IN VARCHAR2
     ,p_split_into_units IN NUMBER
     ,p_revision_date    IN DATE
     ) IS

  l_api_name             CONSTANT VARCHAR2(30) := 'VALIDATE_SPLIT_REQUEST';
  l_valid_asset_flag     VARCHAR2(1);

  cursor l_cle_csr (p_cle_id in number) is
  select 'Y'
  from   okc_k_lines_b cleb
  where  id = p_cle_id
  and    lse_id = 33;

  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  Begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
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
      --1. Validate Revision Date
      IF p_revision_date is NULL or p_revision_date = OKL_API.G_MISS_DATE Then
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => 'OKL_LP_REQUIRED_VALUE',
                              p_token1   => 'COLUMN_PROMPT',
                              p_token1_value => 'Revision Date'
                             );
          l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
      --2. Validate the Asset Id
      If nvl(p_cle_id, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM then
          --Asset Number to split is andatory
          OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => 'OKL_LP_REQUIRED_VALUE',
                              p_token1   => 'COLUMN_PROMPT',
                              p_token1_value => 'Asset'
                             );
           l_return_status := OKL_API.G_RET_STS_ERROR;
      ElsIf nvl(p_cle_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
          --find out whether the asset number provided is valid
          l_valid_asset_flag := 'N';
          Open l_cle_csr(p_cle_id => p_cle_id);
          Fetch l_cle_csr into l_valid_asset_flag;
          Close l_cle_csr;
          If l_valid_asset_flag = 'N' Then
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_LLA_NO_DATA_FOUND',
                              p_token1       => 'COL_NAME',
                              p_token1_value => 'Asset'
                             );
               l_return_status := OKL_API.G_RET_STS_ERROR;
          End If;
      End If;
      --3. validate units to split
      If (
           (nvl(p_split_into_individuals_yn, OKL_API.G_MISS_CHAR) =
            OKL_API.G_MISS_CHAR
           ) OR (p_split_into_individuals_yn = 'N')
         )  AND
        nvl(p_split_into_units, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM Then
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_LLA_INVALID_SPLIT_OPTION',
                              p_token1       => 'COL_NAME1',
                              p_token1_value => 'Split Into Single Units',
                              p_token2       => 'COL_NAME2',
                              p_token2_value => 'Number of Units'
                             );
           l_return_status := OKL_API.G_RET_STS_ERROR;
      ElsIf nvl(p_split_into_units, OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM
      Then
          If nvl(p_split_into_units, OKL_API.G_MISS_NUM) <= 0 Then
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AM_REQ_FIELD_POS_ERR',
                                  p_token1       => 'PROMPT',
                                  p_token1_value => 'Number of Units'
                                 );
              l_return_status := OKL_API.G_RET_STS_ERROR;
           End If;
      End IF;

      x_return_status := l_return_status;

      --Call end Activity
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_UNEXP_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OTHERS',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
  End  Validate_Split_Request;
--Bug# 6612475 End;


--Bug# 6344223
------------------------------------------------------------------------------
--Bug# 6344223
--API Name    : get_split_round_amount
--Description : API to adjust the amounts which are not evenly divisible such
--		that the remainder is allocated to either the child asset
--		holding the same asset number as the parent asset or the asset
--		with the largest percentage of cost (when splitting into
--		components).
--History     :
--              09-Aug-2007    rirawat  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE get_split_round_amount(
     p_api_version    IN  NUMBER
    ,p_init_msg_list  IN  VARCHAR2
    ,x_return_status  OUT NOCOPY VARCHAR2
    ,x_msg_count      OUT NOCOPY NUMBER
    ,x_msg_data       OUT NOCOPY VARCHAR2
    ,p_txl_id             IN NUMBER
    ,p_split_factor       IN NUMBER
    ,p_klev_rec           IN  klev_rec_type
    ,p_clev_rec           IN clev_rec_type
    ,x_klev_rec           OUT NOCOPY klev_rec_type
    ,x_clev_rec           OUT NOCOPY clev_rec_type
) IS

   l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
   l_api_name             CONSTANT VARCHAR2(30) := 'get_split_round_amount';
   l_api_version          CONSTANT NUMBER := 1.0;

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


CURSOR l_txd_csr(p_trxline_id IN NUMBER) IS
      SELECT txd.id,
           txd.split_percent,
           txl.kle_id,
           txd.target_kle_id,
           txd.quantity,
           txl.current_units
    FROM   okl_txd_assets_b  txd,
           okl_txl_Assets_b  txl
    WHERE  txl.tal_type  = 'ALI'
    AND    txd.tal_id    = txl.id
    AND    txl.id        = p_trxline_id
    --Bug# 6898798 start
    ORDER BY nvl(txd.split_percent,-1);
    --Bug# 6898798 end


l_child_split_factor NUMBER :=0;

l_klev_rec_sum        klev_rec_type;
l_klev_rec_out     klev_rec_type;
l_clev_rec_sum         clev_rec_type;
l_clev_rec_out     clev_rec_type;

l_klev_rec        klev_rec_type;
l_clev_rec         clev_rec_type;
l_split_by_unit varchar2(1):='N' ;

FUNCTION round_amount(
   p_currency_code      IN VARCHAR2
  ,p_amount             IN NUMBER
) RETURN NUMBER
IS
l_round_amount NUMBER;
BEGIN
   l_round_amount:=p_amount;

   IF (p_amount IS NOT NULL
         AND
         p_amount <> OKL_API.G_MISS_NUM) THEN

         l_round_amount := NULL;

         l_round_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_amount,
                                          p_currency_code => p_currency_code
                                         );
    END IF;
 RETURN l_round_amount;

EXCEPTION
    WHEN OTHERS THEN
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);

     RETURN NULL;
END;


BEGIN
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
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_klev_rec_out:=p_klev_rec;
    l_clev_rec_out:=p_clev_rec;

    --Initialize
    l_klev_rec_sum.ESTIMATED_OEC :=0;
    l_klev_rec_sum.LAO_AMOUNT :=0;
    l_klev_rec_sum.CAPITAL_REDUCTION :=0;
    l_klev_rec_sum.FEE_CHARGE    :=0;
    l_klev_rec_sum.INITIAL_DIRECT_COST :=0;
    l_klev_rec_sum.AMOUNT_STAKE :=0;
    l_klev_rec_sum.LRV_AMOUNT :=0;
    l_klev_rec_sum.COVERAGE :=0;
    l_klev_rec_sum.VENDOR_ADVANCE_PAID :=0;
    l_klev_rec_sum.TRADEIN_AMOUNT :=0;
    l_klev_rec_sum.BOND_EQUIVALENT_YIELD :=0;
    l_klev_rec_sum.TERMINATION_PURCHASE_AMOUNT :=0;
    l_klev_rec_sum.REFINANCE_AMOUNT :=0;
    l_klev_rec_sum.REMARKETED_AMOUNT :=0;
    l_klev_rec_sum.REMARKET_MARGIN :=0;
    l_klev_rec_sum.REPURCHASED_AMOUNT :=0;
    l_klev_rec_sum.RESIDUAL_VALUE :=0;
    l_klev_rec_sum.APPRAISAL_VALUE :=0;
    l_klev_rec_sum.GAIN_LOSS :=0;
    l_klev_rec_sum.FLOOR_AMOUNT :=0;
    l_klev_rec_sum.TRACKED_RESIDUAL :=0;
    l_klev_rec_sum.AMOUNT :=0;
    l_klev_rec_sum.OEC :=0;
    l_klev_rec_sum.CAPITAL_AMOUNT :=0;
    l_klev_rec_sum.RESIDUAL_GRNTY_AMOUNT :=0;
    l_klev_rec_sum.RVI_PREMIUM :=0;
    l_klev_rec_sum.CAPITALIZED_INTEREST :=0;
    l_klev_rec_sum.SUBSIDY_OVERRIDE_AMOUNT :=0;
    l_klev_rec_sum.Expected_Asset_Cost :=0;

    l_clev_rec_sum.price_unit:=0;
    l_clev_rec_sum.price_negotiated:=0;
    l_clev_rec_sum.price_negotiated_renewed:=0;


  for l_txd_rec in l_txd_csr(p_txl_id)
   loop
    if nvl(l_txd_rec.split_percent,0) in (0,okl_api.g_miss_num) then
      l_child_split_factor := l_txd_rec.quantity/l_txd_rec.current_units;
      l_split_by_unit:='Y';
    else
      l_child_split_factor := l_txd_rec.split_percent/100;
       l_split_by_unit:='N';
    end if;

    l_klev_rec_sum.ESTIMATED_OEC := l_klev_rec_sum.ESTIMATED_OEC +
                                round_amount(l_currency_code,l_child_split_factor * p_klev_rec.ESTIMATED_OEC);
    l_klev_rec_sum.LAO_AMOUNT    := l_klev_rec_sum.LAO_AMOUNT+
                                  round_amount(l_currency_code,l_child_split_factor * p_klev_rec.LAO_AMOUNT);
    l_klev_rec_sum.CAPITAL_REDUCTION := l_klev_rec_sum.CAPITAL_REDUCTION
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.CAPITAL_REDUCTION);
    l_klev_rec_sum.FEE_CHARGE    := l_klev_rec_sum.FEE_CHARGE
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.FEE_CHARGE);
    l_klev_rec_sum.INITIAL_DIRECT_COST := l_klev_rec_sum.INITIAL_DIRECT_COST
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.INITIAL_DIRECT_COST);
    l_klev_rec_sum.AMOUNT_STAKE := l_klev_rec_sum.AMOUNT_STAKE
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.AMOUNT_STAKE);
    l_klev_rec_sum.LRV_AMOUNT := l_klev_rec_sum.LRV_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.LRV_AMOUNT);
    l_klev_rec_sum.COVERAGE := l_klev_rec_sum.COVERAGE
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.COVERAGE);
    l_klev_rec_sum.VENDOR_ADVANCE_PAID := l_klev_rec_sum.VENDOR_ADVANCE_PAID
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.VENDOR_ADVANCE_PAID);
    l_klev_rec_sum.TRADEIN_AMOUNT := l_klev_rec_sum.TRADEIN_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.TRADEIN_AMOUNT);
    l_klev_rec_sum.BOND_EQUIVALENT_YIELD := l_klev_rec_sum.BOND_EQUIVALENT_YIELD
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.BOND_EQUIVALENT_YIELD);
    l_klev_rec_sum.TERMINATION_PURCHASE_AMOUNT := l_klev_rec_sum.TERMINATION_PURCHASE_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.TERMINATION_PURCHASE_AMOUNT);
    l_klev_rec_sum.REFINANCE_AMOUNT := l_klev_rec_sum.REFINANCE_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.REFINANCE_AMOUNT);
    l_klev_rec_sum.REMARKETED_AMOUNT := l_klev_rec_sum.REMARKETED_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.REMARKETED_AMOUNT);
    l_klev_rec_sum.REMARKET_MARGIN := l_klev_rec_sum.REMARKET_MARGIN
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.REMARKET_MARGIN);
    l_klev_rec_sum.REPURCHASED_AMOUNT := l_klev_rec_sum.REPURCHASED_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.REPURCHASED_AMOUNT);
    l_klev_rec_sum.RESIDUAL_VALUE := l_klev_rec_sum.RESIDUAL_VALUE
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.RESIDUAL_VALUE);
    l_klev_rec_sum.APPRAISAL_VALUE := l_klev_rec_sum.APPRAISAL_VALUE
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.APPRAISAL_VALUE);
    l_klev_rec_sum.GAIN_LOSS := l_klev_rec_sum.GAIN_LOSS
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.GAIN_LOSS);
    l_klev_rec_sum.FLOOR_AMOUNT := l_klev_rec_sum.FLOOR_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.FLOOR_AMOUNT);
    l_klev_rec_sum.TRACKED_RESIDUAL := l_klev_rec_sum.TRACKED_RESIDUAL
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.TRACKED_RESIDUAL);
    l_klev_rec_sum.AMOUNT := l_klev_rec_sum.AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.AMOUNT);
    l_klev_rec_sum.OEC := l_klev_rec_sum.OEC
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.OEC);
    l_klev_rec_sum.CAPITAL_AMOUNT := l_klev_rec_sum.CAPITAL_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.CAPITAL_AMOUNT);
    l_klev_rec_sum.RESIDUAL_GRNTY_AMOUNT := l_klev_rec_sum.RESIDUAL_GRNTY_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.RESIDUAL_GRNTY_AMOUNT);
    l_klev_rec_sum.RVI_PREMIUM := l_klev_rec_sum.RVI_PREMIUM
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.RVI_PREMIUM);
    l_klev_rec_sum.CAPITALIZED_INTEREST := l_klev_rec_sum.CAPITALIZED_INTEREST
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.CAPITALIZED_INTEREST);
    l_klev_rec_sum.SUBSIDY_OVERRIDE_AMOUNT := l_klev_rec_sum.SUBSIDY_OVERRIDE_AMOUNT
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.SUBSIDY_OVERRIDE_AMOUNT);
    l_klev_rec_sum.Expected_Asset_Cost := l_klev_rec_sum.Expected_Asset_Cost
                                    + round_amount(l_currency_code,l_child_split_factor * p_klev_rec.Expected_Asset_Cost);
    l_clev_rec_sum.price_unit      := l_clev_rec_sum.price_unit
                                     + round_amount(l_currency_code,l_child_split_factor * p_clev_rec.price_unit);
    l_clev_rec_sum.price_negotiated := l_clev_rec_sum.price_negotiated
                            + round_amount(l_currency_code,l_child_split_factor * p_clev_rec.price_negotiated);
    l_clev_rec_sum.price_negotiated_renewed := l_clev_rec_sum.price_negotiated_renewed
                            + round_amount(l_currency_code,l_child_split_factor * p_clev_rec.price_negotiated_renewed);

   end loop;

    --Bug# 6788253: Replaced l_child_split_factor with p_split_factor in below code that calculates split values
    --              for the asset line to which rounding differences are applied.

    IF l_split_by_unit ='N' THEN
      --unit price to be changed in split by component only
       l_clev_rec_out.price_unit := round_amount(l_currency_code,p_split_factor * p_clev_rec.price_unit )
                                       + (p_clev_rec.price_unit - l_clev_rec_sum.price_unit);
       l_clev_rec_out.price_negotiated := round_amount(l_currency_code,p_split_factor * p_clev_rec.price_negotiated )
                                       + (p_clev_rec.price_negotiated - l_clev_rec_sum.price_negotiated);
       l_clev_rec_out.price_negotiated_renewed :=
                                    round_amount(l_currency_code,p_split_factor * p_clev_rec.price_negotiated_renewed )
                                     + (p_clev_rec.price_negotiated_renewed - l_clev_rec_sum.price_negotiated_renewed);
    END IF;


   l_klev_rec_out.LAO_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.LAO_AMOUNT )
				  +  p_klev_rec.LAO_AMOUNT - l_klev_rec_sum.LAO_AMOUNT;
   l_klev_rec_out.ESTIMATED_OEC := round_amount(l_currency_code,p_split_factor * p_klev_rec.ESTIMATED_OEC )
				  +  p_klev_rec.ESTIMATED_OEC - l_klev_rec_sum.ESTIMATED_OEC;
   l_klev_rec_out.CAPITAL_REDUCTION := round_amount(l_currency_code,p_split_factor * p_klev_rec.CAPITAL_REDUCTION )
				  +  p_klev_rec.CAPITAL_REDUCTION - l_klev_rec_sum.CAPITAL_REDUCTION;
   l_klev_rec_out.FEE_CHARGE := round_amount(l_currency_code,p_split_factor * p_klev_rec.FEE_CHARGE )
				  +  p_klev_rec.FEE_CHARGE - l_klev_rec_sum.FEE_CHARGE;
   l_klev_rec_out.INITIAL_DIRECT_COST := round_amount(l_currency_code,p_split_factor * p_klev_rec.INITIAL_DIRECT_COST )
				  +  p_klev_rec.INITIAL_DIRECT_COST - l_klev_rec_sum.INITIAL_DIRECT_COST;
   l_klev_rec_out.AMOUNT_STAKE := round_amount(l_currency_code,p_split_factor * p_klev_rec.AMOUNT_STAKE )
				  +  p_klev_rec.AMOUNT_STAKE - l_klev_rec_sum.AMOUNT_STAKE;
   l_klev_rec_out.LRV_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.LRV_AMOUNT )
				  +  p_klev_rec.LRV_AMOUNT - l_klev_rec_sum.LRV_AMOUNT;
   l_klev_rec_out.COVERAGE := round_amount(l_currency_code,p_split_factor * p_klev_rec.COVERAGE )
				  +  p_klev_rec.COVERAGE - l_klev_rec_sum.COVERAGE;
   l_klev_rec_out.VENDOR_ADVANCE_PAID := round_amount(l_currency_code,p_split_factor * p_klev_rec.VENDOR_ADVANCE_PAID )
				  +  p_klev_rec.VENDOR_ADVANCE_PAID - l_klev_rec_sum.VENDOR_ADVANCE_PAID;
   l_klev_rec_out.TRADEIN_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.TRADEIN_AMOUNT )
				  +  p_klev_rec.TRADEIN_AMOUNT - l_klev_rec_sum.TRADEIN_AMOUNT;
   l_klev_rec_out.BOND_EQUIVALENT_YIELD := round_amount(l_currency_code,p_split_factor * p_klev_rec.BOND_EQUIVALENT_YIELD )
				  +  p_klev_rec.BOND_EQUIVALENT_YIELD - l_klev_rec_sum.BOND_EQUIVALENT_YIELD;
   l_klev_rec_out.TERMINATION_PURCHASE_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.TERMINATION_PURCHASE_AMOUNT )
				  +  p_klev_rec.TERMINATION_PURCHASE_AMOUNT - l_klev_rec_sum.TERMINATION_PURCHASE_AMOUNT;
   l_klev_rec_out.REFINANCE_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.REFINANCE_AMOUNT )
				  +  p_klev_rec.REFINANCE_AMOUNT - l_klev_rec_sum.REFINANCE_AMOUNT;
   l_klev_rec_out.REMARKETED_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.REMARKETED_AMOUNT )
				  +  p_klev_rec.REMARKETED_AMOUNT - l_klev_rec_sum.REMARKETED_AMOUNT;
   l_klev_rec_out.REMARKET_MARGIN := round_amount(l_currency_code,p_split_factor * p_klev_rec.REMARKET_MARGIN )
				  +  p_klev_rec.REMARKET_MARGIN - l_klev_rec_sum.REMARKET_MARGIN;
   l_klev_rec_out.REPURCHASED_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.REPURCHASED_AMOUNT )
				  +  p_klev_rec.REPURCHASED_AMOUNT - l_klev_rec_sum.REPURCHASED_AMOUNT;
   l_klev_rec_out.RESIDUAL_VALUE := round_amount(l_currency_code,p_split_factor * p_klev_rec.RESIDUAL_VALUE )
				  +  p_klev_rec.RESIDUAL_VALUE - l_klev_rec_sum.RESIDUAL_VALUE;
   l_klev_rec_out.APPRAISAL_VALUE := round_amount(l_currency_code,p_split_factor * p_klev_rec.APPRAISAL_VALUE )
				  +  p_klev_rec.APPRAISAL_VALUE - l_klev_rec_sum.APPRAISAL_VALUE;
   l_klev_rec_out.GAIN_LOSS := round_amount(l_currency_code,p_split_factor * p_klev_rec.GAIN_LOSS )
				  +  p_klev_rec.GAIN_LOSS - l_klev_rec_sum.GAIN_LOSS;
   l_klev_rec_out.FLOOR_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.FLOOR_AMOUNT )
				  +  p_klev_rec.FLOOR_AMOUNT - l_klev_rec_sum.FLOOR_AMOUNT;
   l_klev_rec_out.TRACKED_RESIDUAL := round_amount(l_currency_code,p_split_factor * p_klev_rec.TRACKED_RESIDUAL )
				  +  p_klev_rec.TRACKED_RESIDUAL - l_klev_rec_sum.TRACKED_RESIDUAL;
   l_klev_rec_out.AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.AMOUNT )
				  +  p_klev_rec.AMOUNT - l_klev_rec_sum.AMOUNT;
   l_klev_rec_out.OEC := round_amount(l_currency_code,p_split_factor * p_klev_rec.OEC )
				  +  p_klev_rec.OEC - l_klev_rec_sum.OEC;
   l_klev_rec_out.CAPITAL_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.CAPITAL_AMOUNT )
				  +  p_klev_rec.CAPITAL_AMOUNT - l_klev_rec_sum.CAPITAL_AMOUNT;
   l_klev_rec_out.RESIDUAL_GRNTY_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.RESIDUAL_GRNTY_AMOUNT )
				  +  p_klev_rec.RESIDUAL_GRNTY_AMOUNT - l_klev_rec_sum.RESIDUAL_GRNTY_AMOUNT;
   l_klev_rec_out.RVI_PREMIUM := round_amount(l_currency_code,p_split_factor * p_klev_rec.RVI_PREMIUM )
				  +  p_klev_rec.RVI_PREMIUM - l_klev_rec_sum.RVI_PREMIUM;
   l_klev_rec_out.CAPITALIZED_INTEREST := round_amount(l_currency_code,p_split_factor * p_klev_rec.CAPITALIZED_INTEREST )
				  +  p_klev_rec.CAPITALIZED_INTEREST - l_klev_rec_sum.CAPITALIZED_INTEREST;
   l_klev_rec_out.SUBSIDY_OVERRIDE_AMOUNT := round_amount(l_currency_code,p_split_factor * p_klev_rec.SUBSIDY_OVERRIDE_AMOUNT )
				  +  p_klev_rec.SUBSIDY_OVERRIDE_AMOUNT - l_klev_rec_sum.SUBSIDY_OVERRIDE_AMOUNT;
   l_klev_rec_out.Expected_Asset_Cost := round_amount(l_currency_code,p_split_factor * p_klev_rec.Expected_Asset_Cost )
				  +  p_klev_rec.Expected_Asset_Cost - l_klev_rec_sum.Expected_Asset_Cost;

   x_klev_rec:=l_klev_rec_out;
   x_clev_rec:=l_clev_rec_out;

   OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
     WHEN OTHERS THEN
      l_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

END get_split_round_amount;

--Bug# 6344223
------------------------------------------------------------------------------
--Bug# 6344223
--API Name    : adjust_unit_cost
--Description : API to adjust the unit price when payment type is
--              PRINCIPAL PAYMENT.
--History     :
--              25-Jul-2007    rirawat  Creation
--End of Comments
------------------------------------------------------------------------------

procedure adjust_unit_cost( p_api_version    IN  NUMBER,
                            p_init_msg_list  IN  VARCHAR2,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            p_cle_id NUMBER,
                            p_txdv_rec       IN  txdv_rec_type,
                            p_txlv_rec       IN  txlv_rec_type
) IS


    l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT VARCHAR2(30) := 'adjust_unit_cost';
    l_api_version          CONSTANT NUMBER := 1.0;

    l_fa_line_id NUMBER;
    l_chr_id NUMBER;
    l_tot_principal_payment NUMBER;
    l_principal_payment_found varchar2(1) := 'N';
    l_rule_id  number;
    l_curr_cle_id NUMBER;


   rec_count   NUMBER;
   subtype klev_tbl_type is OKL_CONTRACT_PUB.klev_tbl_type;
   subtype clev_tbl_type is OKL_OKC_MIGRATION_PVT.clev_tbl_type;

   l_clev_price_tbl   clev_tbl_type;
   lx_clev_price_tbl  clev_tbl_type;
   l_klev_price_tbl   klev_tbl_type;
   lx_klev_price_tbl  klev_tbl_type;

   CURSOR k_line_curs(p_fa_line_id IN NUMBER) IS
    SELECT cle.cle_id , sts.ste_code
    FROM   okc_k_lines_b cle , OKC_STATUSES_B sts
    WHERE  id = p_fa_line_id
    and cle.sts_code = sts.code;

  l_ste_code OKC_STATUSES_B.STE_CODE%TYPE;

  --cursor to get model and fixed asset lines
  cursor l_cleb_csr (p_cle_id in number,
                     p_chr_id in number,
                     p_lty_code in varchar2) is
  select cleb.id,
         cleb.price_unit
  from   okc_k_lines_b cleb,
         okc_line_styles_b lseb
  where  cleb.cle_id      = p_cle_id
  and    cleb.dnz_chr_id  = p_chr_id
  and    cleb.lse_id      = lseb.id
  and    lseb.lty_code    = p_lty_code;

    l_cleb_rec  l_cleb_csr%ROWTYPE;
    CURSOR l_pmnt_strm_check(p_chrId NUMBER,
                             p_cle_id NUMBER
                             ) IS
    SELECT crl.id
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = crl.object1_id1
           AND stty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
           AND crl.rgp_id = crg.id
           AND crg.RGD_CODE = 'LALEVL'
           AND crl.RULE_INFORMATION_CATEGORY = 'LASLH'
           AND crg.dnz_chr_id = p_chrId
           and cle_id = p_cle_id;

  CURSOR l_pmnt_strm_check2(
                   rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                   rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                   pmnt_strm_purpose OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE,
                   chrId NUMBER) IS
    SELECT crg.cle_id,
           crl.id,
           crl.object1_id1,
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION4,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = crl.object1_id1
           AND stty.stream_type_purpose = pmnt_strm_purpose
           AND crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

  l_pmnt_strm_check_rec2 l_pmnt_strm_check2%ROWTYPE;

    CURSOR l_pmnt_lns_in_hdr(p_id OKC_RULES_B.ID%TYPE,
                             chrId NUMBER) IS
    SELECT
    crl2.object1_id1,
    crl2.object1_id2,
    crl2.rule_information2,
    NVL(crl2.rule_information3,0) rule_information3,
    crl2.rule_information4,
    crl2.rule_information5,
    crl2.rule_information6,
    crl2.rule_information7,
    crl2.rule_information8,
    crl2.rule_information10
    FROM   OKC_RULES_B crl1, OKC_RULES_B crl2
    WHERE crl1.id = crl2.object2_id1
    AND crl1.id = p_id
    AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
    AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
    AND crl1.dnz_chr_id = chrId
    AND crl2.dnz_chr_id = chrId
    ORDER BY crl2.rule_information2 ASC;


 CURSOR l_pmnt_lns_in_hdr2(p_id OKC_RULES_B.ID%TYPE, chrId NUMBER) IS
    SELECT
    crl2.object1_id1,
    crl2.object1_id2,
    crl2.rule_information2,
    NVL(crl2.rule_information3,0) rule_information3,
    crl2.rule_information4,
    crl2.rule_information5,
    crl2.rule_information6,
    crl2.rule_information7,
    crl2.rule_information8,
    crl2.rule_information10
    FROM   OKC_RULES_B crl1, OKC_RULES_B crl2
    WHERE crl1.id = crl2.object2_id1
    AND crl1.id = p_id
    AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
    AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
    AND crl1.dnz_chr_id = chrId
    AND crl2.dnz_chr_id = chrId
    ORDER BY crl2.rule_information2 ASC;

    l_pmnt_lns_in_hdr_rec2 l_pmnt_lns_in_hdr2%ROWTYPE;

    cursor l_kleb_csr (p_cle_id in number) IS
    select CAPITALIZE_DOWN_PAYMENT_YN ,
           CAPITAL_REDUCTION
    from  okl_k_lines
    where id=p_cle_id ;

    l_kleb_rec  l_kleb_csr%ROWTYPE;

  l_capitalize_downpayment_yn VARCHAR2(1):='N';
  l_capital_reduction NUMBER;

  l_pmnt_strm_check_rec l_pmnt_strm_check%ROWTYPE;
  l_pmnt_lns_in_hdr_rec l_pmnt_lns_in_hdr%ROWTYPE;


  l_child_unit_cost       NUMBER;
  l_child_quantity   NUMBER;
  l_amort_subsidy_amount NUMBER;
  l_total_amount NUMBER;
  l_tot_unsched_prin_payment NUMBER;

    FUNCTION tot_unsched_prin_payment(
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      p_chr_id IN NUMBER,
                                      p_kle_id IN NUMBER) RETURN NUMBER IS
    l_tot_amount NUMBER := 0;
    BEGIN
     x_return_status := Okl_Api.G_RET_STS_SUCCESS;
     FOR l_pmnt_strm_check_rec2 IN l_pmnt_strm_check2('LALEVL','LASLH','UNSCHEDULED_PRINCIPAL_PAYMENT', p_chr_id)
     LOOP
       IF (l_pmnt_strm_check_rec2.cle_id = p_kle_id) THEN
         FOR l_pmnt_lns_in_hdr_rec2 IN l_pmnt_lns_in_hdr2(l_pmnt_strm_check_rec2.id ,p_chr_id)
         LOOP
           l_tot_amount := l_tot_amount + NVL(l_pmnt_lns_in_hdr_rec2.rule_information8,0);
         END LOOP;
       END IF;
     END LOOP;

     RETURN(l_tot_amount);

     EXCEPTION WHEN OTHERS THEN
       --print('Exception In tot_unsched_prin_payment...sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm);
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RETURN(0);
    END; -- tot_unsched_prin_payment


 begin

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

    l_fa_line_id:= p_cle_id;
    l_chr_id:= p_txlv_rec.dnz_khr_id;

    OPEN k_line_curs(l_fa_line_id);
    FETCH k_line_curs INTO l_curr_cle_id,l_ste_code;
    IF k_line_curs%NOTFOUND THEN
       NULL;
    END IF;
    CLOSE k_line_curs;

    IF l_ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED') THEN

    l_tot_principal_payment:=0;

    --check whether principal payment exists

    l_principal_payment_found:='Y';

    OPEN l_pmnt_strm_check(l_chr_id,l_curr_cle_id);
    FETCH l_pmnt_strm_check into l_rule_id;
    IF l_pmnt_strm_check%NOTFOUND THEN
        l_principal_payment_found:='N';
    ELSE
        l_principal_payment_found:='Y';
    END IF;
    close l_pmnt_strm_check;


    IF l_principal_payment_found='Y' THEN
         --get the total principal payment amount
        FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_rule_id ,l_chr_id)
        LOOP
          l_tot_principal_payment := l_tot_principal_payment +
          NVL(l_pmnt_lns_in_hdr_rec.rule_information3,0) * NVL(l_pmnt_lns_in_hdr_rec.rule_information6, 0) +
          NVL(l_pmnt_lns_in_hdr_rec.rule_information8, 0);
        END LOOP;

       ---------get subsidy amount if any--
        l_amort_subsidy_amount :=0;
        Okl_Subsidy_Process_Pvt.get_asset_subsidy_amount(
            p_api_version                  => 1.0,
            p_init_msg_list                => Okl_Api.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_asset_cle_id                 => l_curr_cle_id,
            p_accounting_method            => 'AMORTIZE',
            x_subsidy_amount               => l_amort_subsidy_amount);

       l_amort_subsidy_amount:=NVL(l_amort_subsidy_amount,0);


     -- get capitalized downpayment amount --------

      l_capital_reduction :=0;

      open l_kleb_csr(p_cle_id   => l_curr_cle_id);
      fetch l_kleb_csr into l_kleb_rec;
      If l_kleb_csr%NOTFOUND THEN
          l_capital_reduction :=0;
      Else
        IF NVL(l_kleb_rec.CAPITALIZE_DOWN_PAYMENT_YN,'X')='Y' THEN
            l_capital_reduction :=  NVL(l_kleb_rec.CAPITAL_REDUCTION,0);
        END IF;
      End if;
     -----------------------------------
       --Total Unscheduled Principal Payment
      l_tot_unsched_prin_payment :=
                   tot_unsched_prin_payment(l_return_status,
                                     l_chr_id, l_curr_cle_id);

      --total amount
      l_total_amount := l_amort_subsidy_amount + l_tot_principal_payment
                        +l_capital_reduction + l_tot_unsched_prin_payment ;


      IF NVL(p_txlv_rec.SPLIT_INTO_SINGLES_FLAG,'X')='Y' THEN
         l_child_quantity:=1;
      ELSE
         l_child_quantity  := p_txdv_rec.quantity;
      END IF;

      --evaluate the unit cost
      l_child_unit_cost := l_total_amount/l_child_quantity ;


      --Update the contract line with the unit cost

      rec_count:=0;
      rec_count                              := rec_count+1;
      l_clev_price_tbl(rec_count).id         := l_fa_line_id;
      l_klev_price_tbl(rec_count).id         := l_fa_line_id;
      l_clev_price_tbl(rec_count).price_unit := l_child_unit_cost;

      open l_cleb_csr(p_cle_id   => l_curr_cle_id,
                      p_chr_id   => l_chr_id,
                      p_lty_code => 'ITEM');
      fetch l_cleb_csr into l_cleb_rec;
      If l_cleb_csr%NOTFOUND then
          Null;
      Else
          rec_count                              := rec_count+1;
          l_clev_price_tbl(rec_count).id         := l_cleb_rec.id;
          l_klev_price_tbl(rec_count).id         := l_cleb_rec.id;
          l_clev_price_tbl(rec_count).price_unit := l_child_unit_cost;

      End If;
      close l_cleb_csr;

      --Call api to update line
     OKL_CONTRACT_PUB.update_contract_line(
                  p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_clev_tbl       => l_clev_price_tbl,
                  p_klev_tbl       => l_klev_price_tbl,
                  x_clev_tbl       => lx_clev_price_tbl,
                  x_klev_tbl       => lx_klev_price_tbl);

        --dbms_output.put_line('After updating contract line :'||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- l_principal_payment_found
  END IF; --l_ste_code

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
end adjust_unit_cost;


--Bug# 6344223
------------------------------------------------------------------------------
--Bug# 6344223
--API Name    : SYNC_STREAMS
--Description : API to perform stream generation processing for Split asset.
--History     :
--              25-Jul-2007    rirawat  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE sync_streams(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_chr_id         IN  NUMBER ) IS


    l_api_name               CONSTANT VARCHAR2(30) := 'sync_streams';
    l_api_version            CONSTANT NUMBER := 1.0;

    l_trx_number           NUMBER;
    l_trx_status           VARCHAR2(100);
BEGIN
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

     okl_contract_status_pub.update_contract_status(
            p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_khr_status       => 'PASSED',
            p_chr_id           => p_chr_id);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      --cascade status to lines
      okl_contract_status_pub.cascade_lease_status(
           p_api_version      => l_api_version,
           p_init_msg_list    => p_init_msg_list,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_chr_id           => p_chr_id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

     OKL_LA_STREAM_PUB.GEN_INTR_EXTR_STREAM (
                                      p_api_version         => l_api_version,
                                      p_init_msg_list       => p_init_msg_list,
                                      x_return_status       => x_return_status,
                                      x_msg_count           => x_msg_count,
                                      x_msg_data            => x_msg_data,
                                      p_khr_id              => p_chr_id,
                                      p_generation_ctx_code => 'AUTH',
                                      x_trx_number          => l_trx_number,
                                      x_trx_status          => l_trx_status);

    -- check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data);
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
   x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name,
                             G_PKG_NAME,
                             'OKL_API.G_RET_STS_UNEXP_ERROR',
                             x_msg_count,
                             x_msg_data,
                             '_PVT');
   WHEN OTHERS THEN
   x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name,
                             G_PKG_NAME,
                             'OTHERS',
                             x_msg_count,
                             x_msg_data,
                             '_PVT');

END sync_streams;



--Bug# 6344223
------------------------------------------------------------------------------
--Bug# 6344223
--API Name    : SPLIT_ASSET_AFTER_YIELD
--Description : API to perform post stream generation processing for Split asset.
--History     :
--              25-Jul-2007    bkatraga  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE SPLIT_ASSET_AFTER_YIELD (p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status OUT NOCOPY   VARCHAR2,
                                   x_msg_count     OUT NOCOPY   NUMBER,
                                   x_msg_data      OUT NOCOPY   VARCHAR2,
                                   p_chr_id        IN  NUMBER) IS

l_return_status          VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name               CONSTANT VARCHAR2(30) := 'SPLIT_ASSET_AFTER_YIELD';
l_api_version            CONSTANT NUMBER := 1.0;
l_split_trx_flag         VARCHAR2(1);
l_accrual_rec            OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
l_stream_tbl             OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
l_chr_secure             VARCHAR2(3) := OKL_API.G_FALSE;
l_inv_agmt_chr_id_tbl    OKL_SECURITIZATION_PVT.inv_agmt_chr_id_tbl_type;
l_inv_accrual_rec        OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
l_inv_stream_tbl         OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
l_trxv_rec               trxv_rec_type;
lx_trxv_rec              trxv_rec_type;
l_split_trans_id         OKL_TRX_ASSETS.ID%TYPE;
l_trx_number             OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE := null; -- MGAAP
l_trx_reason_asset_split VARCHAR2(20) := OKL_SECURITIZATION_PVT.G_TRX_REASON_ASSET_SPLIT;

--Cursor to check whether split asset transaction is in progress for the contract
CURSOR check_split_trx_csr IS
 SELECT tas.id
   FROM OKL_TXL_ASSETS_B txl, OKL_TRX_ASSETS tas
  WHERE txl.tal_type= 'ALI'
    AND txl.dnz_khr_id = p_chr_id
    AND txl.tas_id = tas.id
    AND tas.tas_type = 'ALI'
    AND tas.tsu_code = 'ENTERED';

-- MGAAP start 7263041
CURSOR check_csr(p_chr_id NUMBER) IS
SELECT A.MULTI_GAAP_YN,
       B.REPORTING_PDT_ID
FROM   OKL_K_HEADERS A,
       OKL_PRODUCTS B
WHERE  A.ID = p_chr_id
AND    A.PDT_ID = B.ID;

l_multi_gaap_yn OKL_K_HEADERS.MULTI_GAAP_YN%TYPE;
l_reporting_pdt_id OKL_PRODUCTS.REPORTING_PDT_ID%TYPE;
-- MGAAP start 7263041

--Bug# 9191475
lx_trxnum_tbl     OKL_GENERATE_ACCRUALS_PVT.trxnum_tbl_type;
l_trxnum_init_tbl OKL_GENERATE_ACCRUALS_PVT.trxnum_tbl_type;

BEGIN
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

   -- MGAAP start 7263041
   OPEN check_csr(p_chr_id);
   FETCH check_csr
   INTO  l_multi_gaap_yn, l_reporting_pdt_id;
   CLOSE check_csr;
   -- MGAAP end 7263041

   OPEN check_split_trx_csr;
   FETCH check_split_trx_csr INTO l_split_trans_id;
   CLOSE check_split_trx_csr;

   --Split asset transaction exists for the contract
   IF(l_split_trans_id IS NOT NULL) THEN
      okl_contract_status_pub.update_contract_status(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_khr_status       => 'BOOKED',
            p_chr_id           => p_chr_id);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      --cascade status to lines
      okl_contract_status_pub.cascade_lease_status(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_chr_id           => p_chr_id);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 6336455
      -- R12B Authoring OA Migration
      -- Update the status of the Submit Contract task to Complete
      OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_khr_id             => p_chr_id ,
        p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_SUBMIT_CONTRACT,
        p_progress_status    => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        Raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_CONTRACT_REBOOK_PVT.create_billing_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chr_id,
           p_orig_khr_id     => p_chr_id,
           p_trx_id          => l_split_trans_id,
           p_trx_date        => sysdate);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041
      OKL_CONTRACT_REBOOK_PVT.calc_accrual_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chr_id,
           p_orig_khr_id     => p_chr_id,
           p_trx_id          => l_split_trans_id,
           p_trx_date        => sysdate,
           x_accrual_rec     => l_accrual_rec,
           x_stream_tbl      => l_stream_tbl,
           p_trx_tbl_code    => 'TAS',
           p_trx_type        => 'ALI');
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      IF (l_stream_tbl.COUNT > 0) THEN
         OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data ,
             --Bug# 9191475
             --x_trx_number     => l_trx_number,
             x_trx_tbl        => lx_trxnum_tbl,
             p_accrual_rec    => l_accrual_rec,
             p_stream_tbl     => l_stream_tbl);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      -- MGAAP start 7263041
      OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS; -- MGAAP 7263041
      OKL_CONTRACT_REBOOK_PVT.calc_accrual_adjustment(
           p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_chr_id,
           p_orig_khr_id     => p_chr_id,
           p_trx_id          => l_split_trans_id,
           p_trx_date        => sysdate,
           x_accrual_rec     => l_accrual_rec,
           x_stream_tbl      => l_stream_tbl,
           p_trx_tbl_code    => 'TAS',
           p_trx_type        => 'ALI');

      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      IF (l_stream_tbl.COUNT > 0) THEN
         --Bug# 9191475
         --l_accrual_rec.trx_number := l_trx_number;
         OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data ,
             --Bug# 9191475
             --x_trx_number     => l_trx_number,
             x_trx_tbl        => lx_trxnum_tbl,
             p_accrual_rec    => l_accrual_rec,
             p_stream_tbl     => l_stream_tbl,
             p_representation_type     => 'SECONDARY');
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
      END IF;
      -- MGAAP end 7263041

      okl_securitization_pvt.check_khr_securitized(
            p_api_version              => p_api_version,
            p_init_msg_list            => p_init_msg_list,
            x_return_status            => x_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data,
            p_khr_id                   => p_chr_id,
            p_effective_date           => sysdate,
            x_value                    => l_chr_secure,
            x_inv_agmt_chr_id_tbl      => l_inv_agmt_chr_id_tbl);
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 6788253
      IF l_chr_secure = OKL_API.G_TRUE THEN
         OKL_SECURITIZATION_PVT.modify_pool_contents(
               p_api_version         => p_api_version,
               p_init_msg_list       => p_init_msg_list,
               p_transaction_reason  => l_trx_reason_asset_split,
               p_khr_id              => p_chr_id,
               p_transaction_date    => SYSDATE,
               p_effective_date      => SYSDATE,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         OKL_STREAM_GENERATOR_PVT.create_disb_streams(
              p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_contract_id      => p_chr_id);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         OKL_STREAM_GENERATOR_PVT.create_pv_streams(
              p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_contract_id      => p_chr_id);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS(
              p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_khr_id           => p_chr_id);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         OKL_CONTRACT_REBOOK_PVT.create_inv_disb_adjustment(
              p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_orig_khr_id      => p_chr_id);
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         l_trx_number := null; -- MGAAP 7263041
         --Bug# 9191475
         lx_trxnum_tbl := l_trxnum_init_tbl;
         OKL_CONTRACT_REBOOK_PVT.calc_inv_acc_adjustment(
              p_api_version     => p_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              p_orig_khr_id     => p_chr_id,
              p_trx_id          => l_split_trans_id,
              p_trx_date        => sysdate,
              x_inv_accrual_rec => l_inv_accrual_rec,
              x_inv_stream_tbl  => l_inv_stream_tbl,
              p_trx_tbl_code    => 'TAS',
              p_trx_type        => 'ALI');
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         IF (l_inv_stream_tbl.COUNT > 0) THEN
            OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
                p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data ,
                --Bug# 9191475
                --x_trx_number     => l_trx_number,
                x_trx_tbl        => lx_trxnum_tbl,
                p_accrual_rec    => l_inv_accrual_rec,
                p_stream_tbl     => l_inv_stream_tbl);
            IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
               RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
               RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
         END IF;

         -- MGAAP start 7263041
         IF (l_multi_gaap_yn = 'Y') THEN
           OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
           OKL_CONTRACT_REBOOK_PVT.calc_inv_acc_adjustment(
                p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_orig_khr_id     => p_chr_id,
                p_trx_id          => l_split_trans_id,
                p_trx_date        => sysdate,
                x_inv_accrual_rec => l_inv_accrual_rec,
                x_inv_stream_tbl  => l_inv_stream_tbl,
                p_trx_tbl_code    => 'TAS',
                p_trx_type        => 'ALI',
                p_product_id       => l_reporting_pdt_id); -- MGAAP 7263041

           OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
           IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;

           IF (l_inv_stream_tbl.COUNT > 0) THEN
              --Bug# 9191475
              --l_inv_accrual_rec.trx_number := l_trx_number;
              OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
                  p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  --Bug# 9191475
                  x_trx_tbl        => lx_trxnum_tbl,
                  --x_trx_number     => l_trx_number,
                  p_accrual_rec    => l_inv_accrual_rec,
                  p_stream_tbl     => l_inv_stream_tbl,
                  p_representation_type     => 'SECONDARY');
              IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                 RAISE Okl_Api.G_EXCEPTION_ERROR;
              END IF;
           END IF;
         END IF;
         -- MGAAP end 7263041
      END IF;

      ------------------------------------------------------------------------
      --Bug# : R12.B eBTax impact Start
      ------------------------------------------------------------------------
      okl_process_sales_tax_pvt.calculate_sales_tax(
         p_api_version             => p_api_version,
         p_init_msg_list           => p_init_msg_list,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data,
         p_source_trx_id           => l_split_trans_id, --<okl_trx_assets.id>,
         p_source_trx_name         => 'Split Asset',
         p_source_table            => 'OKL_TRX_ASSETS');

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      ------------------------------------------------------------------------
      --Bug# : R12.B eBTax impact End
      ------------------------------------------------------------------------

	 l_trxv_rec.id := l_split_trans_id;
	 l_trxv_rec.tsu_code := 'PROCESSED';
	 OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
	      p_api_version   => p_api_version,
	      p_init_msg_list => p_init_msg_list,
	      x_return_status => x_return_status,
	      x_msg_count     => x_msg_count,
	      x_msg_data      => x_msg_data,
	      p_thpv_rec      => l_trxv_rec,
	      x_thpv_rec      => lx_trxv_rec);
	 IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	 ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	    RAISE Okl_Api.G_EXCEPTION_ERROR;
	 END IF;

   -- racheruv: added update of okl_stream_trx_data.last_trx_state
     okl_streams_util.update_trx_state(p_chr_id, 'BOTH');
   -- end update of okl_stream_trx_data.last_trx_state

   END IF;

   OKL_API.END_ACTIVITY (x_msg_count,
                         x_msg_data);
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
   x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name,
                             G_PKG_NAME,
                             'OKL_API.G_RET_STS_UNEXP_ERROR',
                             x_msg_count,
                             x_msg_data,
                             '_PVT');
   WHEN OTHERS THEN
   x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                             l_api_name,
                             G_PKG_NAME,
                             'OTHERS',
                             x_msg_count,
                             x_msg_data,
                             '_PVT');
END SPLIT_ASSET_AFTER_YIELD;
--Bug# 6344223

------------------------------------------------------------------------------
--Bug# 6326479
--API Name    : process_split_accounting
--Description : Private API to create accounting entries for transaction type
--              'Split Asset' for the new Asset created after split.
--History     :
--              18-Jun-2007    rirawat  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE process_split_accounting(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN  NUMBER
   ,p_kle_id                      IN  NUMBER
   ,p_transaction_date             IN  DATE)

IS
    l_api_name         CONSTANT VARCHAR2(30) := 'process_split_accounting';
    l_api_version      CONSTANT NUMBER       := 1.0;

    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

     -- Define PL/SQL Records and Tables
    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_in_rec        Okl_Trx_Contracts_Pvt.tclv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_out_rec       Okl_Trx_Contracts_Pvt.tclv_rec_type;

    -- Define variables
    l_post_to_gl_yn   VARCHAR2(1);

    l_amount          NUMBER;
    l_init_msg_list   VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_currency_code   okl_txl_cntrct_lns.currency_code%TYPE;


    CURSOR Product_csr (p_contract_id IN okl_products_v.id%TYPE) IS
    SELECT pdt.id                       product_id
          ,pdt.name                     product_name
          ,khr.sts_code                 contract_status
          ,khr.start_date               start_date
          ,khr.currency_code            currency_code
          ,khr.authoring_org_id         authoring_org_id
          ,khr.currency_conversion_rate currency_conversion_rate
          ,khr.currency_conversion_type currency_conversion_type
          ,khr.currency_conversion_date currency_conversion_date
          ,khr.scs_code
    FROM   okl_products_v        pdt
          ,okl_k_headers_full_v  khr
    WHERE  khr.id = p_contract_id
    AND    khr.pdt_id = pdt.id;

       -- Get the product type
   CURSOR l_product_type_csr ( p_pdt_id IN NUMBER) IS
      SELECT  description
      FROM    OKL_PRODUCTS_V
      WHERE   id = p_pdt_id;

    l_func_curr_code               OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    l_chr_curr_code                OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
    x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
    x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;
    l_functional_currency_code VARCHAR2(15);
    l_contract_currency_code VARCHAR2(15);
    l_converted_amount NUMBER;
    l_Product_rec      Product_csr%ROWTYPE;
    l_transaction_date DATE;
    l_ctxt_val_tbl                  OKL_ACCOUNT_DIST_PUB.ctxt_val_tbl_type;
    l_acc_gen_primary_key_tbl       OKL_ACCOUNT_DIST_PUB.acc_gen_primary_key;
    l_tmpl_identify_rec  OKL_ACCOUNT_DIST_PVT.TMPL_IDENTIFY_REC_TYPE;
    lp_tmpl_identify_rec OKL_ACCOUNT_DIST_PUB.tmpl_identify_rec_type;
    l_dist_info_rec      OKL_ACCOUNT_DIST_PVT.dist_info_REC_TYPE;
    l_template_tbl       OKL_ACCOUNT_DIST_PVT.AVLV_TBL_TYPE;
    l_amount_tbl         OKL_ACCOUNT_DIST_PVT.AMOUNT_TBL_TYPE;
    lx_template_tbl                  OKL_ACCOUNT_DIST_PUB.avlv_tbl_type;
    l_trx_desc           VARCHAR2(2000);
    l_fact_synd_code      FND_LOOKUPS.Lookup_code%TYPE;
    l_inv_acct_code       OKC_RULES_B.Rule_Information1%TYPE;
    l_try_name              VARCHAR2(30);
    l_trans_code            VARCHAR2(30);
    l_tcn_type              VARCHAR2(3);
    l_trans_meaning         VARCHAR2(200);
    l_try_id                NUMBER;
    G_NO               CONSTANT VARCHAR2(1)   := 'N';
    l_valid_gl_date DATE;
    l_product_type                   VARCHAR2(2000);
    lp_tclv_rec                      OKL_TRX_CONTRACTS_PUB.tclv_rec_type;
    lx_tclv_rec                      OKL_TRX_CONTRACTS_PUB.tclv_rec_type;
    li_tclv_rec                      OKL_TRX_CONTRACTS_PUB.tclv_rec_type;
    i                                NUMBER;
    l_total_amount                   NUMBER := 0;
    l_line_number                    NUMBER := 1;
    l_hard_coded_amount NUMBER := 100;

    l_tclv_tbl              Okl_trx_contracts_pvt.tclv_tbl_type;
    x_tclv_tbl              Okl_trx_contracts_pvt.tclv_tbl_type;
    l_tcnv_rec              Okl_trx_contracts_pvt.tcnv_rec_type;
    x_tcnv_rec              Okl_trx_contracts_pvt.tcnv_rec_type;

    l_tmpl_identify_tbl     Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
    l_dist_info_tbl         Okl_Account_Dist_Pvt.dist_info_tbl_type;
    l_ctxt_tbl              Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_template_out_tbl      Okl_Account_Dist_Pvt.avlv_out_tbl_type;
    l_amount_out_tbl        Okl_Account_Dist_Pvt.amount_out_tbl_type;
    l_acc_gen_tbl           Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;

    CURSOR fnd_lookups_csr( lkp_type VARCHAR2, mng VARCHAR2 ) IS
    select description,
           lookup_code
    from   fnd_lookup_values
    where language = 'US'
    and lookup_type = lkp_type
    and meaning = mng;

    l_fnd_rec               fnd_lookups_csr%ROWTYPE;

BEGIN
  -- Set API savepoint
  SAVEPOINT process_split_accounting_PVT;

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
   --------------------------------------------------------------------------
   -- Initialize API variables
   --------------------------------------------------------------------------

   i                := 0;

   l_transaction_date  := p_transaction_date;

   l_trx_desc := 'OKL Accounting Transaction for Split Asset';

   l_post_to_gl_yn := 'Y';

   l_try_name := 'Split Asset';
   l_trans_code := 'SPLIT_ASSET';
   l_tcn_type := 'SPA';

   l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
		       p_lookup_type  => 'OKL_ACCOUNTING_EVENT_TYPE',
		       p_lookup_code	=>  l_trans_code,
		       p_validate_yn  => 'Y');


   OKL_AM_UTIL_PVT.get_transaction_id (
  	    p_try_name      => l_try_name,
          p_language      => 'US',
          x_return_status => l_return_status,
  	    x_try_id        => l_try_id);


    -- Get product_id
    OPEN  Product_csr(p_contract_id);
    FETCH Product_csr INTO l_Product_rec;
    IF Product_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME,
                           'OKL_REQUIRED_VALUE',
                           OKL_API.G_COL_NAME_TOKEN,
                           'Product');
      CLOSE Product_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE Product_csr;

    l_currency_code  := l_Product_rec.currency_code;

    --------------------------------------------------------------------------
    -- multi-currency setup
    --------------------------------------------------------------------------

    l_chr_curr_code  := l_Product_rec.CURRENCY_CODE;

    l_func_curr_code := okl_accounting_util.get_func_curr_code;

    x_currency_conversion_rate := NULL;
    x_currency_conversion_type := NULL;
    x_currency_conversion_date := NULL;

    IF ( ( l_func_curr_code IS NOT NULL) AND
         ( l_chr_curr_code <> l_func_curr_code ) ) THEN

        x_currency_conversion_type := l_Product_rec.currency_conversion_type;
        x_currency_conversion_date :=l_transaction_date;

        IF ( l_Product_rec.currency_conversion_type = 'User') THEN
            x_currency_conversion_rate := l_Product_rec.currency_conversion_rate;
            x_currency_conversion_date := l_Product_rec.currency_conversion_date;
        ELSE
            x_currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
	                 p_from_curr_code => l_chr_curr_code,
	                 p_to_curr_code   => l_func_curr_code,
                       p_con_date  => l_transaction_date,
 		           p_con_type => l_Product_rec.currency_conversion_type);

        END IF;

    END IF;

    --------------------------------------------------------------------------
    -- Assign passed in record values for transaction header and line
    -------------------------------------------------------------------------

    l_trxH_in_rec.khr_id         := p_contract_id;
    l_trxH_in_rec.pdt_id         := l_Product_rec.product_id;
    l_trxH_in_rec.tcn_type       := l_tcn_type;  --'SPA'
    l_trxH_in_rec.currency_code  := l_currency_code;
    l_trxH_in_rec.try_id         := l_try_id;
    l_trxH_in_rec.description    := l_trx_desc;
    l_trxH_in_rec.currency_conversion_rate := x_currency_conversion_rate;
    l_trxH_in_rec.currency_conversion_type := x_currency_conversion_type;
    l_trxH_in_rec.currency_conversion_date := x_currency_conversion_date;
    l_trxH_in_rec.tsu_code                    := 'PROCESSED';
    l_trxH_in_rec.date_transaction_occurred  := l_transaction_date;
    l_trxH_in_rec.set_of_books_id    := okl_accounting_util.get_set_of_books_id;
    l_trxH_in_rec.org_id            := l_Product_rec.authoring_org_id;
    --------------------------------------------------------------------------
    -- Create transaction Header and line
    --------------------------------------------------------------------------
    Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => l_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

      IF ((l_trxH_out_rec.id = OKL_API.G_MISS_NUM) OR
            (l_trxH_out_rec.id IS NULL) ) THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_REQUIRED_VALUE',
                                 OKL_API.G_COL_NAME_TOKEN,
                                'TRANSACTION_ID');
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    --------------------------------------------------------------------------
    -- accounting template record
    --------------------------------------------------------------------------

    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := l_try_id;
    l_tmpl_identify_rec.PRODUCT_ID := l_Product_rec.product_id;
    l_tmpl_identify_rec.memo_yn               :=  G_NO;
    l_tmpl_identify_rec.prior_year_yn         :=  G_NO;

     -- get the product type
    OPEN  l_product_type_csr ( l_Product_rec.product_id);
    FETCH l_product_type_csr INTO l_product_type;
    CLOSE l_product_type_csr;


     -- set the additional parameters with contract_id, line_id and transaction_date
     -- to be passed to formula engine

    l_valid_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date( p_gl_date => l_transaction_date);

    --For special accounting treatment : Review whether it is required or not
    OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
                                  p_api_version             => p_api_version,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_khr_id                  => p_contract_id,
                                  p_scs_code            => l_product_rec.scs_code,
                                  p_trx_date                => l_transaction_date,
                                  x_fact_synd_code          => l_fact_synd_code,
                                  x_inv_acct_code           => l_inv_acct_code
                                  );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_tmpl_identify_rec.factoring_synd_flag := l_fact_synd_code;
    l_tmpl_identify_rec.investor_code       := l_inv_acct_code;

    OKL_ACCOUNT_DIST_PUB.get_template_info(
                p_api_version     	            => p_api_version,
                p_init_msg_list   	            => OKL_API.G_FALSE,
                x_return_status   	            => l_return_status,
                x_msg_count       	            => x_msg_count,
                x_msg_data        	            => x_msg_data,
                p_tmpl_identify_rec             => l_tmpl_identify_rec,
                x_template_tbl                  => l_template_tbl,
                p_validity_date                 => l_valid_gl_date);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        -- No accounting templates found matching the transaction type TRX_TYPE
        -- and product  PRODUCT.
        OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name   => 'OKL_AM_NO_ACC_TEMPLATES',
                             p_token1        => 'TRX_TYPE',
                             p_token1_value  => l_trans_meaning,
                             p_token2        => 'PRODUCT',
                             p_token2_value  => l_product_type);

      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- If no templates present
      IF l_template_tbl.COUNT = 0 THEN
        -- No accounting templates found matching the transaction type TRX_TYPE
        -- and product  PRODUCT.
        OKL_API.set_message(
                             p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_NO_ACC_TEMPLATES',
                             p_token1        => 'TRX_TYPE',
                             p_token1_value  => l_trans_meaning,
                             p_token2        => 'PRODUCT',
                             p_token2_value  => l_product_type);


        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

     --Build the transaction line table of records
     FOR i IN l_template_tbl.FIRST..l_template_tbl.LAST
     LOOP
             l_tclv_tbl(i).line_number := i;
             l_tclv_tbl(i).khr_id := p_contract_id;
             l_tclv_tbl(i).kle_id := p_kle_id;
             l_tclv_tbl(i).sty_id := l_template_tbl(i).sty_id;
             l_tclv_tbl(i).tcl_type := l_tcn_type;  --'SPA';
             l_tclv_tbl(i).description := l_trx_desc;
             l_tclv_tbl(i).tcn_id := l_trxh_out_rec.id;
             l_tclv_tbl(i).currency_code := l_currency_code;
             l_tclv_tbl(i).org_id := l_Product_rec.authoring_org_id;
      END LOOP;

      --Call to create transaction lines

      Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
        p_api_version      => l_api_version
       ,p_init_msg_list    => l_init_msg_list
       ,x_return_status    => x_return_status
       ,x_msg_count        => l_msg_count
       ,x_msg_data         => l_msg_data
       ,p_tclv_tbl         => l_tclv_tbl
       ,x_tclv_tbl         => x_tclv_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /* Populating the tmpl_identify_tbl  from the template_tbl returned by get_template_info*/

      FOR i in l_template_tbl.FIRST.. l_template_tbl.LAST
      LOOP
        l_tmpl_identify_tbl(i).product_id          := l_Product_rec.product_id;
        l_tmpl_identify_tbl(i).transaction_type_id := l_try_id;
        l_tmpl_identify_tbl(i).stream_type_id      := l_template_tbl(i).sty_id;
        l_tmpl_identify_tbl(i).advance_arrears     := l_template_tbl(i).advance_arrears;
        l_tmpl_identify_tbl(i).prior_year_yn       := l_template_tbl(i).prior_year_yn;
        l_tmpl_identify_tbl(i).memo_yn             := l_template_tbl(i).memo_yn;
        l_tmpl_identify_tbl(i).factoring_synd_flag := l_template_tbl(i).factoring_synd_flag;
        l_tmpl_identify_tbl(i).investor_code       := l_template_tbl(i).inv_code;
        l_tmpl_identify_tbl(i).SYNDICATION_CODE    := l_template_tbl(i).syt_code;
        l_tmpl_identify_tbl(i).FACTORING_CODE      := l_template_tbl(i).fac_code;
      END LOOP;

      -- for account generator
      OKL_ACC_CALL_PVT.okl_populate_acc_gen (
        p_contract_id       => p_contract_id,
        p_contract_line_id  => p_kle_id,
        x_acc_gen_tbl       => l_acc_gen_primary_key_tbl,
        x_return_status     => l_return_status);

      -- Raise exception to rollback to savepoint for this block
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      /* Populating the dist_info_Tbl */
      FOR i in x_tclv_tbl.FIRST..x_tclv_tbl.LAST
      LOOP
      --Assigning the account generator table
        l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
        l_acc_gen_tbl(i).source_id :=  x_tclv_tbl(i).id;

        --Bug# 6189396
        l_ctxt_val_tbl := okl_execute_formula_pub.g_additional_parameters;

        l_dist_info_tbl(i).SOURCE_ID := x_tclv_tbl(i).id;
        l_dist_info_tbl(i).SOURCE_TABLE := 'OKL_TXL_CNTRCT_LNS';
        l_dist_info_tbl(i).GL_REVERSAL_FLAG := 'N';
        l_dist_info_tbl(i).POST_TO_GL := l_post_to_gl_yn;
        l_dist_info_tbl(i).CONTRACT_ID := p_contract_id;
        l_dist_info_tbl(i).contract_line_id := p_kle_id;

        l_dist_info_tbl(i).currency_conversion_rate := x_currency_conversion_rate;
        l_dist_info_tbl(i).currency_conversion_type := x_currency_conversion_type;
        l_dist_info_tbl(i).currency_conversion_date := x_currency_conversion_date;
        l_dist_info_tbl(i).currency_code  := l_currency_code;
        l_dist_info_tbl(i).ACCOUNTING_DATE := l_trxh_out_rec.date_transaction_occurred;
      END LOOP;

      /* Making the new single accounting engine call*/
      Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
        p_api_version        => l_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
        p_dist_info_tbl      => l_dist_info_tbl,
        p_ctxt_val_tbl       => l_ctxt_tbl,
        p_acc_gen_primary_key_tbl  => l_acc_gen_tbl,
        x_template_tbl       => l_template_out_tbl,
        x_amount_tbl         => l_amount_out_tbl,
	  p_trx_header_id      => l_trxH_out_rec.id);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Processed');
      FETCH fnd_lookups_csr INTO l_fnd_rec;
      IF fnd_lookups_csr%NOTFOUND THEN
        Okl_Api.SET_MESSAGE(G_APP_NAME, OKL_API.G_INVALID_VALUE,OKL_API.G_COL_NAME_TOKEN,l_try_name);
        CLOSE fnd_lookups_csr;
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      CLOSE fnd_lookups_csr;

       --From the l_amount_out_tbl returned , the transaction line amount and header amount need to be updated back on the contract
       l_tclv_tbl := x_tclv_tbl;
       l_tcnv_rec := l_trxH_out_rec;

       If l_tclv_tbl.COUNT > 0 then
         FOR i in l_tclv_tbl.FIRST..l_tclv_tbl.LAST LOOP
           l_amount_tbl.delete;
           If l_amount_out_tbl.COUNT > 0 then
              For k in l_amount_out_tbl.FIRST..l_amount_out_tbl.LAST LOOP
                  IF l_tclv_tbl(i).id = l_amount_out_tbl(k).source_id THEN
                      l_amount_tbl := l_amount_out_tbl(k).amount_tbl;
                      l_tclv_tbl(i).currency_code := l_currency_code;
                      IF l_amount_tbl.COUNT > 0 THEN
                          FOR j in l_amount_tbl.FIRST..l_amount_tbl.LAST LOOP
                              l_tclv_tbl(i).amount := nvl(l_tclv_tbl(i).amount,0)  + l_amount_tbl(j);
                          END LOOP; -- for j in
                      END IF;-- If l_amount_tbl.COUNT
                  END IF; ---- IF l_tclv_tbl(i).id
              END LOOP; -- For k in
           END IF; -- If l_amount_out_tbl.COUNT
           l_tcnv_rec.amount := nvl(l_tcnv_rec.amount,0) + l_tclv_tbl(i).amount;
           l_tcnv_rec.currency_code := l_currency_code;
           l_tcnv_rec.tsu_code      := l_fnd_rec.lookup_code;
         END LOOP; -- For i in
       End If; -- If l_tclv_tbl.COUNT

      --Making the call to update the amounts on transaction header and line
      Okl_Trx_Contracts_Pub.update_trx_contracts
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,p_tcnv_rec => l_tcnv_rec
                           ,p_tclv_tbl => l_tclv_tbl
                           ,x_tcnv_rec => x_tcnv_rec
                           ,x_tclv_tbl => x_tclv_tbl );

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => x_tcnv_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;


  -- Get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO process_split_accounting_PVT;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_split_accounting_PVT;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO process_split_accounting_PVT;
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

END process_split_accounting;

------------------------------------------------------------------------------
  --Bug# 5946411
  --Start of comments
  --
  --Procedure Name        : get_deprn_reserve
  --Purpose               : Get Depreciation Reserve- used internally
  --Modification History  :
  --02-May-2007    avsingh   Created
  --                         To get accumulated depreciation of an asset
  --                         As per Bug# 6027547 raised on FA, the suggestion
  --                         from FA is to back out depreciation reserve
  --                         if cost is being adjusted in the period of
  --                         of addition.
  ------------------------------------------------------------------------------
  PROCEDURE get_deprn_reserve
                   (p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    p_asset_id        IN  NUMBER,
                    p_book_type_code  IN  VARCHAR2,
                    x_asset_deprn_rec   OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'GET_DEPRN_RESERVE';
    l_api_version	CONSTANT NUMBER	:= 1.0;

    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

    l_deprn_reserve            NUMBER;

  BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_asset_hdr_rec.asset_id          := p_asset_id;
     l_asset_hdr_rec.book_type_code    := p_book_type_code;

     if NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Depreciation Reserve
     if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => 'P'
                 ) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     x_asset_deprn_rec := l_asset_deprn_rec;

     --Call end Activity
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OKL_API.G_RET_STS_UNEXP_ERROR',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
      l_api_name,
      G_PKG_NAME,
      'OTHERS',
      x_msg_count,
      x_msg_data,
      '_PVT'
      );
  END get_deprn_reserve;
--Bug# 5946411 End
-----------------------------------------------------------------
--Bug# 5946411: ER
--added procedure to create split asset return
-----------------------------------------------------------------
 PROCEDURE create_split_asset_return(  p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_kle_id        IN  NUMBER,
                              p_cle_tbl       IN  cle_tbl_type,
                              p_txlv_rec      IN  txlv_rec_type
                              ) IS
  l_api_name             CONSTANT VARCHAR2(30) := 'create_split_asset_return';
  l_api_version          CONSTANT NUMBER := 1.0;
  lp_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;
  lp_upd_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;
  lx_artv_rec             OKL_AM_ASSET_RETURN_PUB.artv_rec_type;
    -- Get asset return for asset with status Scheduled
   CURSOR l_asset_return_csr ( p_kle_id IN NUMBER) IS
    SELECT  id,
            RMR_ID,
            ART1_CODE,
            RELOCATE_ASSET_YN,
            VOLUNTARY_YN,
            COMMMERCIALLY_REAS_SALE_YN,
            ORG_ID,
            FLOOR_PRICE,
            NEW_ITEM_PRICE,
            NEW_ITEM_NUMBER,
            ASSET_RELOCATED_YN,
            REPURCHASE_AGMT_YN,
            CURRENCY_CODE,
            CURRENCY_CONVERSION_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            --Bug# 6336455
            LEGAL_ENTITY_ID
    FROM   OKL_ASSET_RETURNS_b
    WHERE  kle_id = p_kle_id
    AND    ars_code = 'SCHEDULED';
   -- Get the non-cancelled asset return for asset
    CURSOR l_check_asset_return_csr ( p_kle_id IN NUMBER) IS
    select 'N' from dual
    where exists (
    SELECT 1
    FROM   OKL_ASSET_RETURNS_V
    WHERE  kle_id = p_kle_id
    AND    ars_code <> 'CANCELLED'
    );
    cursor l_term_date_csr ( p_kle_id IN NUMBER)
    IS
    select date_terminated
    from okc_k_lines_b
    where id=p_kle_id;
    CURSOR l_trmnt_line_csr(p_cle_id IN OKC_K_LINES_B.ID%TYPE)
    IS
    SELECT cle.id id
    FROM okc_k_lines_b cle
    CONNECT BY PRIOR cle.id = cle.cle_id
    START WITH cle.id = p_cle_id;
    l_return_needed         VARCHAR2(1) := 'Y';
    l_asset_return_rec l_asset_return_csr%ROWTYPE;
    l_source_cle_id NUMBER;
    i                       NUMBER := 1;
    l_parent_unit NUMBER;
    l_child_unit NUMBER;
    l_split_factor NUMBER;
    l_term_date DATE;
    l_clev_rec               OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_klev_rec               OKL_CONTRACT_PUB.klev_rec_type;
    lx_clev_rec              OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lx_klev_rec              OKL_CONTRACT_PUB.klev_rec_type;
    l_chld_total_flr_price NUMBER:=0.0;
  begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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
   l_source_cle_id :=p_kle_id;
   --dbms_output.put_line(' l_source_cle_id'||l_source_cle_id);
 FOR  l_asset_return_rec in l_asset_return_csr(l_source_cle_id)
   LOOP
    --dbms_output.put_line('CSAR--> found');
   IF p_cle_tbl.COUNT > 0 THEN
    --get the split factor
    if NVL(p_txlv_rec.SPLIT_INTO_SINGLES_FLAG,'X')='Y' THEN
        l_parent_unit :=1;
        l_child_unit:=1;
     else
       l_parent_unit:= p_txlv_rec.CURRENT_UNITS - NVL(p_txlv_rec.SPLIT_INTO_UNITS,0);
       l_child_unit:=p_txlv_rec.SPLIT_INTO_UNITS;
    end if;
  -- dbms_output.put_line('l_parent_unit-->'||l_parent_unit);
  -- dbms_output.put_line('l_child_unit-->'||l_child_unit);
    --get the termination date
    OPEN l_term_date_csr(l_source_cle_id);
    FETCH l_term_date_csr INTO l_term_date;
    CLOSE l_term_date_csr;
   FOR i IN p_cle_tbl.FIRST..p_cle_tbl.LAST
    LOOP
    --dbms_output.put_line('procssing --> '|| p_cle_tbl(i).cle_id);
     if l_source_cle_id <> p_cle_tbl(i).cle_id then
        l_split_factor:=l_child_unit/p_txlv_rec.current_units;
       -- dbms_output.put_line('CSAR-->child l_split_factor>'||l_split_factor);
        -- Check if return created
        l_return_needed:='Y';
        OPEN  l_check_asset_return_csr (p_cle_tbl(i).cle_id);
        FETCH l_check_asset_return_csr INTO l_return_needed;
        CLOSE l_check_asset_return_csr;
        IF l_return_needed='Y' THEN
        --dbms_output.put_line('Creating asset return for >'||p_cle_tbl(i).cle_id);
		lp_artv_rec.KLE_ID	:=  p_cle_tbl(i).cle_id;
		lp_artv_rec.RMR_ID	:= l_asset_return_rec.RMR_ID;
		lp_artv_rec.ARS_CODE := 'SCHEDULED';--l_asset_return_rec.ARS_CODE;
	--	lp_artv_rec.IMR_ID	:= l_asset_return_rec.IMR_ID;
		lp_artv_rec.ART1_CODE	:= l_asset_return_rec.ART1_CODE;
		lp_artv_rec.RELOCATE_ASSET_YN	:= l_asset_return_rec.RELOCATE_ASSET_YN;
		lp_artv_rec.VOLUNTARY_YN	:= l_asset_return_rec.VOLUNTARY_YN;
 		lp_artv_rec.COMMMERCIALLY_REAS_SALE_YN	:= l_asset_return_rec.COMMMERCIALLY_REAS_SALE_YN;
		lp_artv_rec.ORG_ID	:= l_asset_return_rec.ORG_ID;
    	lp_artv_rec.FLOOR_PRICE	:=  l_split_factor * NVL(l_asset_return_rec.FLOOR_PRICE,0.0);
    	l_chld_total_flr_price := l_chld_total_flr_price+NVL(lp_artv_rec.FLOOR_PRICE,0.0);
    --	lp_artv_rec.NEW_ITEM_PRICE	:= l_split_factor * NVL(l_asset_return_rec.NEW_ITEM_PRICE,0.0);
    --	lp_artv_rec.NEW_ITEM_NUMBER	:= l_asset_return_rec.NEW_ITEM_NUMBER;
		lp_artv_rec.ASSET_RELOCATED_YN	:= l_asset_return_rec.ASSET_RELOCATED_YN;
		lp_artv_rec.REPURCHASE_AGMT_YN	:= l_asset_return_rec.REPURCHASE_AGMT_YN;
		lp_artv_rec.CURRENCY_CODE	:= l_asset_return_rec.CURRENCY_CODE;
		lp_artv_rec.CURRENCY_CONVERSION_CODE	:= l_asset_return_rec.CURRENCY_CONVERSION_CODE;
		lp_artv_rec.CURRENCY_CONVERSION_TYPE	:= l_asset_return_rec.CURRENCY_CONVERSION_TYPE;
		lp_artv_rec.CURRENCY_CONVERSION_RATE	:= l_asset_return_rec.CURRENCY_CONVERSION_RATE;
		lp_artv_rec.CURRENCY_CONVERSION_DATE	:= l_asset_return_rec.CURRENCY_CONVERSION_DATE;

            --Bug# 6336455
            lp_artv_rec.LEGAL_ENTITY_ID := l_asset_return_rec.LEGAL_ENTITY_ID;

        -- call insert of tapi
       OKL_ASSET_RETURNS_PUB.insert_asset_returns(
	    p_api_version              => p_api_version,
        p_init_msg_list            => OKL_API.G_FALSE,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        p_artv_rec                 => lp_artv_rec,
        x_artv_rec                 => lx_artv_rec);
      -- dbms_output.put_line('Calling OKL_ASSET_RETURNS_PUB.insert_asset_returns  status >'||x_return_status);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --upade the termination date on the lines and subliines
       FOR r_trmnt_line_csr IN
          l_trmnt_line_csr(p_cle_id => p_cle_tbl(i).cle_id) LOOP
          l_clev_rec.id              := r_trmnt_line_csr.id;
          l_klev_rec.id              := r_trmnt_line_csr.id;
          l_clev_rec.date_terminated := l_term_date;
          OKL_CONTRACT_PUB.update_contract_line(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_clev_rec       => l_clev_rec,
                           p_klev_rec       => l_klev_rec,
                           x_clev_rec       => lx_clev_rec,
                           x_klev_rec       => lx_klev_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END LOOP; --inner loop
      END IF; --return needed
      END IF; --soucer id<> pkle_id
    END LOOP; -- p_cle_tbl loop end
    -- this is parent asset so adjust the floor price
     lp_upd_artv_rec.id:=l_asset_return_rec.id;
     lp_upd_artv_rec.FLOOR_PRICE := NVL(l_asset_return_rec.FLOOR_PRICE,0.0)-l_chld_total_flr_price;
     -- call update of tapi
     OKL_ASSET_RETURNS_PUB.update_asset_returns(
      p_api_version        => p_api_version,
      p_init_msg_list      =>  OKL_API.G_FALSE,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_artv_rec           => lp_upd_artv_rec,
      x_artv_rec           => lx_artv_rec);
    -- dbms_output.put_line('Calling OKL_ASSET_RETURNS_PUB.update_asset_returns  status >'||x_return_status);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
   END IF; --p_cle_tbl >0
  END LOOP; --aset rturn record
   OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
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
   end create_split_asset_return;

-----------------------------------------------
-- Bug# 5946411: ER
-- added procedure to check pending transaction
-----------------------------------------------
  PROCEDURE Check_Offlease_Trans(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_cle_id         IN  NUMBER
                              ) is
  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'CHECK_OFFLEASE_TRANS';
  l_api_version          CONSTANT NUMBER := 1.0;

   --cursor to fetch the corporate and tax book for the given asset
   CURSOR l_okxassetlines_csr(p_kle_id IN NUMBER) IS
   SELECT o.asset_id, o.asset_number, o.corporate_book, a.cost, o.depreciation_category, a.original_cost, o.current_units,
          o.dnz_chr_id ,a.book_type_code, b.book_class, a.prorate_convention_code
   FROM   okx_asset_lines_v o, fa_books a, fa_book_controls b
   WHERE  o.parent_line_id = p_kle_id
   AND    o.asset_id = a.asset_id
   AND    a.book_type_code = b.book_type_code
   AND    a.date_ineffective IS NULL
   AND    a.transaction_header_id_out IS NULL
   ORDER BY book_class;

   CURSOR l_offlseassettrx_csr(cp_trx_date IN DATE, cp_asset_number IN VARCHAR2) IS
   SELECT h.tsu_code, h.tas_type,  h.date_trans_occurred, l.dnz_asset_id,
          l.asset_number, l.kle_id ,l.DNZ_KHR_ID
   FROM   OKL_TRX_ASSETS h, OKL_TXL_ASSETS_B l
   WHERE  h.id = l.tas_id
   AND    h.date_trans_occurred <= cp_trx_date
   AND    h.tas_type in ('AMT','AUD','AUS')
   AND    l.asset_number = cp_asset_number;

 l_okxassetlines_rec         l_okxassetlines_csr%ROWTYPE;
 l_name               OKL_TXL_ASSETS_B.asset_number%TYPE;
 l_trx_status         VARCHAR2(30);


  BEGIN
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

    FOR l_okxassetlines_rec IN l_okxassetlines_csr(p_cle_id) LOOP
        l_name:=l_okxassetlines_rec.asset_number;
        l_trx_status := NULL;
        FOR  l_offlseassettrx_rec IN l_offlseassettrx_csr(sysdate,l_name) LOOP
			      l_trx_status := l_offlseassettrx_rec.tsu_code;
			      IF l_trx_status IN ('ENTERED','ERROR') THEN
			         EXIT;
			      END IF;
		 END LOOP;
        IF l_trx_status IN ('ENTERED','ERROR') THEN -- if any trx has this status
           --dbms_output.put_line('Pending transactions');
                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_PENDING_OFFLEASE',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
        end if ;
   end loop;
   OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
 EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF l_offlseassettrx_csr%ISOPEN THEN
          CLOSE l_offlseassettrx_csr;
      END IF;
     IF l_okxassetlines_csr%ISOPEN THEN
          CLOSE l_okxassetlines_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF l_offlseassettrx_csr%ISOPEN THEN
          CLOSE l_offlseassettrx_csr;
      END IF;
      IF l_okxassetlines_csr%ISOPEN THEN
          CLOSE l_okxassetlines_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
     WHEN OTHERS THEN
     IF l_offlseassettrx_csr%ISOPEN THEN
          CLOSE l_offlseassettrx_csr;
      END IF;
     IF l_okxassetlines_csr%ISOPEN THEN
          CLOSE l_okxassetlines_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Check_Offlease_Trans;

--------------
--Bug# 3156924
--------------
--date validation routine
--should be called from UI(revision page only ):

  PROCEDURE validate_trx_date(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_chr_id         IN  NUMBER,
                              p_trx_date       IN  VARCHAR2) IS

  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_DATE';
  l_api_version          CONSTANT NUMBER := 1.0;


  l_date_valid VARCHAR2(1) DEFAULT 'N';
  l_trx_date   DATE ;

  --cursor to check the date validity wrt contract dates
  CURSOR l_chrb_csr(ptrxdate IN DATE, pchrid IN NUMBER, pdateformat IN VARCHAR2) IS
  SELECT 'Y'                                  date_valid,
         TO_CHAR(chrb.start_date,pdateformat) con_start_date,
         TO_CHAR(chrb.end_date,pdateformat)   con_end_date,
         chrb.sts_code                        sts_code
  FROM   okc_k_headers_b chrb
  WHERE  ptrxdate BETWEEN TRUNC(chrb.start_date) AND TRUNC(chrb.end_date)
  AND    chrb.id = pchrid;

  l_chrb_rec         l_chrb_csr%ROWTYPE;
  l_icx_date_format  VARCHAR2(240);


  BEGIN
      x_return_status := l_return_status;

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

      --0. verify date format
      BEGIN
          l_icx_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');
          l_trx_date := TO_DATE(p_trx_date, l_icx_date_format);
          EXCEPTION
          WHEN OTHERS THEN
              okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_INVALID_DATE_FORMAT,
                             'DATE_FORMAT',
                             l_icx_date_format,
                             'COL_NAME',
                             'Revision Date'
                            );
              x_return_status := OKL_API.G_RET_STS_ERROR;
      END;

      IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


      --1. Transaction date is required
      IF NVL(p_trx_date,okl_api.g_miss_char) = okl_api.g_miss_char THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_MISSING_TRX_DATE
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --2. Transaction date is between contract start and end date
      l_date_valid := 'N';
      OPEN l_chrb_csr(ptrxdate => l_trx_date, pchrid => p_chr_id, pdateformat => l_icx_date_format);
      FETCH l_chrb_csr INTO l_chrb_rec;
      IF l_chrb_csr%NOTFOUND THEN
          NULL;
      ELSE
          l_date_valid := l_chrb_rec.date_valid;
      END IF;
      CLOSE l_chrb_csr;


      IF (l_date_valid = 'N') THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_WRONG_TRX_DATE,
                             'START_DATE',
                             l_chrb_rec.con_start_date,
                             'END_DATE',
                             l_chrb_rec.con_end_date
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --3. contracts which are not active can not be split asset
      IF (NVL(l_chrb_rec.sts_code,OKL_API.G_MISS_CHAR) <> 'BOOKED') THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_REV_ONLY_BOOKED
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF l_chrb_csr%ISOPEN THEN
          CLOSE l_chrb_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF l_chrb_csr%ISOPEN THEN
          CLOSE l_chrb_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
      WHEN OTHERS THEN
      IF l_chrb_csr%ISOPEN THEN
          CLOSE l_chrb_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END validate_trx_date;

-----------------------------------------------------------------
--01-Mar-2004: Bug# 3156924
--overloaded will be called locally from create_split_transaction
-----------------------------------------------------------------
  PROCEDURE validate_trx_date(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_cle_id         IN  NUMBER,
                              p_trx_date       IN  DATE) IS

  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'VALIDATE_TRX_DATE';
  l_api_version          CONSTANT NUMBER := 1.0;


  l_date_valid VARCHAR2(1) DEFAULT 'N';

  --cursor to check the date validity wrt contract dates
  --Bug# 5946411: ER
  /*
  CURSOR l_cleb_csr(ptrxdate IN DATE, pcleid IN NUMBER, pdateformat IN VARCHAR2) IS
  SELECT 'Y'                                  date_valid,
         TO_CHAR(cleb.start_date,pdateformat) line_start_date,
         TO_CHAR(cleb.end_date,pdateformat)   line_end_date,
         cleb.sts_code                        sts_code
  FROM   okc_k_lines_b cleb
  WHERE  ptrxdate BETWEEN TRUNC(cleb.start_date) AND TRUNC(cleb.end_date)
  AND    cleb.id = pcleid;
  */
  CURSOR l_cleb_csr(pcleid IN NUMBER, pdateformat IN VARCHAR2) IS
  SELECT TO_CHAR(cleb.start_date,pdateformat) line_start_date,
         TO_CHAR(cleb.end_date,pdateformat)   line_end_date,
         cleb.sts_code                        sts_code,
         trunc(cleb.start_date)  cle_start_date,
         TRUNC(cleb.end_date)    cle_end_date
  FROM   okc_k_lines_b cleb
  WHERE  cleb.id = pcleid;
  --Bug# 5946411: ER end

  /*  --Added by HARIVEN - cursor to fetch the Start and  End Date
  CURSOR l_strdate_csr(pcleid IN NUMBER, pdateformat IN VARCHAR2) IS
  SELECT 'Y'                                  date_valid,
         TO_CHAR(cleb.start_date,pdateformat) line_start_date,
         TO_CHAR(cleb.end_date,pdateformat)   line_end_date,
         cleb.sts_code                        sts_code
  FROM   okc_k_lines_b cleb
  WHERE  cleb.id = pcleid;*/

  l_cleb_rec         l_cleb_csr%ROWTYPE;
  l_icx_date_format  VARCHAR2(240);


  BEGIN
      x_return_status := l_return_status;

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

      --1. Transaction date is required
      IF NVL(p_trx_date,okl_api.g_miss_date) = okl_api.g_miss_date THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_MISSING_TRX_DATE
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_icx_date_format := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-YYYY');
      --2. Transaction date is between contract start and end date
      --Bug# 5946411: ER
      /*
      l_date_valid := 'N';
      OPEN l_cleb_csr(ptrxdate => p_trx_date, pcleid => p_cle_id, pdateformat => l_icx_date_format);
      FETCH l_cleb_csr INTO l_cleb_rec;
      IF l_cleb_csr%NOTFOUND THEN
          NULL;
      ELSE
          l_date_valid := l_cleb_rec.date_valid;
      END IF;
      CLOSE l_cleb_csr;
      */
      l_date_valid := 'Y';
      OPEN l_cleb_csr( pcleid => p_cle_id, pdateformat => l_icx_date_format);
      FETCH l_cleb_csr INTO l_cleb_rec;
      IF l_cleb_csr%NOTFOUND THEN
          NULL;
      ELSE
          if (l_cleb_rec.sts_code  = 'BOOKED')
             AND NOT (p_trx_date BETWEEN l_cleb_rec.cle_start_date AND l_cleb_rec.cle_end_date) THEN
            l_date_valid := 'N';
          end if;
      END IF;
      CLOSE l_cleb_csr;

      --Bug# 5946411: ER End


      IF (l_date_valid = 'N') THEN
      /*OPEN l_strdate_csr(pcleid => p_cle_id, pdateformat => l_icx_date_format);
      FETCH l_strdate_csr INTO l_cleb_rec;
      IF l_strdate_csr%NOTFOUND THEN
          NULL;
      ELSE
          l_date_valid := l_cleb_rec.date_valid;
      END IF;
      CLOSE l_strdate_csr;*/
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_WRONG_TRX_DATE,
                             'START_DATE',
                             l_cleb_rec.line_start_date,
                             'END_DATE',
                             l_cleb_rec.line_end_date
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF l_cleb_csr%ISOPEN THEN
          CLOSE l_cleb_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF l_cleb_csr%ISOPEN THEN
          CLOSE l_cleb_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
      WHEN OTHERS THEN
      IF l_cleb_csr%ISOPEN THEN
          CLOSE l_cleb_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END validate_trx_date;
---------------
--Bug# 3156924
--------------
-------------------------------------------------------------------------------
--Function to get Asset Line Record
------------------------------------------------------------------------------
FUNCTION get_ast_line(p_cle_id IN NUMBER,
                      x_no_data_found OUT NOCOPY BOOLEAN)
RETURN ast_line_rec_type IS
CURSOR ast_line_curs(p_cle_id IN NUMBER) IS
SELECT
        ID1,
        ID2,
        NAME,
        DESCRIPTION,
        ITEM_DESCRIPTION,
        COMMENTS,
        CHR_ID,
        DNZ_CHR_ID,
        LTY_CODE,
        LSE_TYPE,
        LSE_PARENT_ID,
        PARENT_LINE_ID,
        LINE_NUMBER,
        DATE_TERMINATED,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
        STATUS,
        ASSET_ID,
        QUANTITY,
        UNIT_OF_MEASURE_CODE,
        ASSET_NUMBER,
        CORPORATE_BOOK,
        LIFE_IN_MONTHS,
        ORIGINAL_COST,
        COST,
        ADJUSTED_COST,
        TAG_NUMBER,
        CURRENT_UNITS,
        SERIAL_NUMBER,
        REVAL_CEILING,
        NEW_USED,
        IN_SERVICE_DATE,
        MANUFACTURER_NAME,
        MODEL_NUMBER,
        ASSET_TYPE,
        SALVAGE_VALUE,
        PERCENT_SALVAGE_VALUE,
        DEPRECIATION_CATEGORY,
        DEPRN_START_DATE,
        DEPRN_METHOD_CODE,
        RATE_ADJUSTMENT_FACTOR,
        BASIC_RATE,
        ADJUSTED_RATE,
        RECOVERABLE_COST,
        ORG_ID,
        SET_OF_BOOKS_ID,
    PROPERTY_TYPE_CODE,
    PROPERTY_1245_1250_CODE,
    IN_USE_FLAG,
    OWNED_LEASED,
    INVENTORIAL,
    LINE_STATUS
FROM    OKX_ASSET_LINES_V
WHERE   parent_line_id = p_cle_id;
l_ast_line_rec ast_line_rec_type;
BEGIN
    x_no_data_found := TRUE;
    OPEN  ast_line_curs(p_cle_id);
    FETCH ast_line_curs INTO
        l_ast_line_rec.ID1,
        l_ast_line_rec.ID2,
        l_ast_line_rec.NAME,
        l_ast_line_rec.DESCRIPTION,
        l_ast_line_rec.ITEM_DESCRIPTION,
        l_ast_line_rec.COMMENTS,
        l_ast_line_rec.CHR_ID,
        l_ast_line_rec.DNZ_CHR_ID,
        l_ast_line_rec.LTY_CODE,
        l_ast_line_rec.LSE_TYPE,
        l_ast_line_rec.LSE_PARENT_ID,
        l_ast_line_rec.PARENT_LINE_ID,
        l_ast_line_rec.LINE_NUMBER,
        l_ast_line_rec.DATE_TERMINATED,
        l_ast_line_rec.START_DATE_ACTIVE,
        l_ast_line_rec.END_DATE_ACTIVE,
        l_ast_line_rec.STATUS,
        l_ast_line_rec.ASSET_ID,
        l_ast_line_rec.QUANTITY,
        l_ast_line_rec.UNIT_OF_MEASURE_CODE,
        l_ast_line_rec.ASSET_NUMBER,
        l_ast_line_rec.CORPORATE_BOOK,
        l_ast_line_rec.LIFE_IN_MONTHS,
        l_ast_line_rec.ORIGINAL_COST,
        l_ast_line_rec.COST,
        l_ast_line_rec.ADJUSTED_COST,
        l_ast_line_rec.TAG_NUMBER,
        l_ast_line_rec.CURRENT_UNITS,
        l_ast_line_rec.SERIAL_NUMBER,
        l_ast_line_rec.REVAL_CEILING,
        l_ast_line_rec.NEW_USED,
        l_ast_line_rec.IN_SERVICE_DATE,
        l_ast_line_rec.MANUFACTURER_NAME,
        l_ast_line_rec.MODEL_NUMBER,
        l_ast_line_rec.ASSET_TYPE,
        l_ast_line_rec.SALVAGE_VALUE,
        l_ast_line_rec.PERCENT_SALVAGE_VALUE,
        l_ast_line_rec.DEPRECIATION_CATEGORY,
        l_ast_line_rec.DEPRN_START_DATE,
        l_ast_line_rec.DEPRN_METHOD_CODE,
        l_ast_line_rec.RATE_ADJUSTMENT_FACTOR,
        l_ast_line_rec.BASIC_RATE,
        l_ast_line_rec.ADJUSTED_RATE,
        l_ast_line_rec.RECOVERABLE_COST,
        l_ast_line_rec.ORG_ID,
        l_ast_line_rec.SET_OF_BOOKS_ID,
    l_ast_line_rec.PROPERTY_TYPE_CODE,
    l_ast_line_rec.PROPERTY_1245_1250_CODE,
    l_ast_line_rec.IN_USE_FLAG,
    l_ast_line_rec.OWNED_LEASED,
    l_ast_line_rec.INVENTORIAL,
    l_ast_line_rec.LINE_STATUS;

        x_no_data_found := ast_line_curs%NOTFOUND;
        CLOSE  ast_line_curs;
        RETURN (l_ast_line_rec);
    END get_ast_line;
    FUNCTION get_ast_line (p_cle_id IN NUMBER) RETURN  ast_line_rec_type IS
       l_row_not_found    BOOLEAN := TRUE;
    BEGIN
        RETURN (get_ast_line(p_cle_id,l_row_not_found));
    END get_ast_line;
--------------------------------------------------------------------------------
--Function to get txl details for a given tal_id
--------------------------------------------------------------------------------
FUNCTION get_txlv_rec (
    p_kle_id         IN  NUMBER,
    x_no_data_found  OUT NOCOPY BOOLEAN
  ) RETURN txlv_rec_type IS
    CURSOR txlv_csr (p_kle_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           TAS_ID,
           ILO_ID,
           ILO_ID_OLD,
           IAY_ID,
           IAY_ID_NEW,
           KLE_ID,
           DNZ_KHR_ID,
           LINE_NUMBER,
           ORG_ID,
           TAL_TYPE,
           ASSET_NUMBER,
           DESCRIPTION,
           FA_LOCATION_ID,
           ORIGINAL_COST,
           CURRENT_UNITS,
           MANUFACTURER_NAME,
           YEAR_MANUFACTURED,
           SUPPLIER_ID,
           USED_ASSET_YN,
           TAG_NUMBER,
           MODEL_NUMBER,
           CORPORATE_BOOK,
           DATE_PURCHASED,
           DATE_DELIVERY,
           IN_SERVICE_DATE,
           LIFE_IN_MONTHS,
           DEPRECIATION_ID,
           DEPRECIATION_COST,
           DEPRN_METHOD,
           DEPRN_RATE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
--Bug# 2981308
           ASSET_KEY_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           DEPRECIATE_YN,
           HOLD_PERIOD_DAYS,
           OLD_SALVAGE_VALUE,
           NEW_RESIDUAL_VALUE,
           OLD_RESIDUAL_VALUE,
           UNITS_RETIRED,
           COST_RETIRED,
           SALE_PROCEEDS,
           REMOVAL_COST,
           DNZ_ASSET_ID,
           DATE_DUE,
           REP_ASSET_ID,
           LKE_ASSET_ID,
           MATCH_AMOUNT,
           SPLIT_INTO_SINGLES_FLAG,
           SPLIT_INTO_UNITS,
--Bug #2723498 : 11.5.9 - Multi currency compliance
           CURRENCY_CODE,
           CURRENCY_CONVERSION_TYPE,
           CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_DATE
-- Multi-Currency Change
     FROM  Okl_Txl_Assets_V
     WHERE okl_txl_assets_v.kle_id  = p_kle_id
     AND   EXISTS (SELECT NULL
                   FROM   okl_trx_Assets   trx,
                          okl_trx_types_tl ttyp
                   WHERE  trx.id = okl_txl_assets_v.tas_id
                   AND    trx.tsu_code  = 'ENTERED'
                   AND    trx.try_id    = ttyp.id
                   AND    ttyp.name     = 'Split Asset'
                   AND    ttyp.LANGUAGE = 'US');

    l_txlv_rec                     txlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN txlv_csr (p_kle_id => p_kle_id);
    FETCH txlv_csr INTO
              l_txlv_rec.ID,
              l_txlv_rec.OBJECT_VERSION_NUMBER,
              l_txlv_rec.SFWT_FLAG,
              l_txlv_rec.TAS_ID,
              l_txlv_rec.ILO_ID,
              l_txlv_rec.ILO_ID_OLD,
              l_txlv_rec.IAY_ID,
              l_txlv_rec.IAY_ID_NEW,
              l_txlv_rec.KLE_ID,
              l_txlv_rec.DNZ_KHR_ID,
              l_txlv_rec.LINE_NUMBER,
              l_txlv_rec.ORG_ID,
              l_txlv_rec.TAL_TYPE,
              l_txlv_rec.ASSET_NUMBER,
              l_txlv_rec.DESCRIPTION,
              l_txlv_rec.FA_LOCATION_ID,
              l_txlv_rec.ORIGINAL_COST,
              l_txlv_rec.CURRENT_UNITS,
              l_txlv_rec.MANUFACTURER_NAME,
              l_txlv_rec.YEAR_MANUFACTURED,
              l_txlv_rec.SUPPLIER_ID,
              l_txlv_rec.USED_ASSET_YN,
              l_txlv_rec.TAG_NUMBER,
              l_txlv_rec.MODEL_NUMBER,
              l_txlv_rec.CORPORATE_BOOK,
              l_txlv_rec.DATE_PURCHASED,
              l_txlv_rec.DATE_DELIVERY,
              l_txlv_rec.IN_SERVICE_DATE,
              l_txlv_rec.LIFE_IN_MONTHS,
              l_txlv_rec.DEPRECIATION_ID,
              l_txlv_rec.DEPRECIATION_COST,
              l_txlv_rec.DEPRN_METHOD,
              l_txlv_rec.DEPRN_RATE,
              l_txlv_rec.SALVAGE_VALUE,
              l_txlv_rec.PERCENT_SALVAGE_VALUE,
--Bug# 2981308 :
              l_txlv_rec.ASSET_KEY_ID,
              l_txlv_rec.ATTRIBUTE_CATEGORY,
              l_txlv_rec.ATTRIBUTE1,
              l_txlv_rec.ATTRIBUTE2,
              l_txlv_rec.ATTRIBUTE3,
              l_txlv_rec.ATTRIBUTE4,
              l_txlv_rec.ATTRIBUTE5,
              l_txlv_rec.ATTRIBUTE6,
              l_txlv_rec.ATTRIBUTE7,
              l_txlv_rec.ATTRIBUTE8,
              l_txlv_rec.ATTRIBUTE9,
              l_txlv_rec.ATTRIBUTE10,
              l_txlv_rec.ATTRIBUTE11,
              l_txlv_rec.ATTRIBUTE12,
              l_txlv_rec.ATTRIBUTE13,
              l_txlv_rec.ATTRIBUTE14,
              l_txlv_rec.ATTRIBUTE15,
              l_txlv_rec.CREATED_BY,
              l_txlv_rec.CREATION_DATE,
              l_txlv_rec.LAST_UPDATED_BY,
              l_txlv_rec.LAST_UPDATE_DATE,
              l_txlv_rec.LAST_UPDATE_LOGIN,
              l_txlv_rec.DEPRECIATE_YN,
              l_txlv_rec.HOLD_PERIOD_DAYS,
              l_txlv_rec.OLD_SALVAGE_VALUE,
              l_txlv_rec.NEW_RESIDUAL_VALUE,
              l_txlv_rec.OLD_RESIDUAL_VALUE,
              l_txlv_rec.UNITS_RETIRED,
              l_txlv_rec.COST_RETIRED,
              l_txlv_rec.SALE_PROCEEDS,
              l_txlv_rec.REMOVAL_COST,
              l_txlv_rec.DNZ_ASSET_ID,
              l_txlv_rec.DATE_DUE,
              l_txlv_rec.REP_ASSET_ID,
              l_txlv_rec.LKE_ASSET_ID,
              l_txlv_rec.MATCH_AMOUNT,
              l_txlv_rec.SPLIT_INTO_SINGLES_FLAG,
              l_txlv_rec.SPLIT_INTO_UNITS,
-- Multi-Currency Change
              l_txlv_rec.CURRENCY_CODE,
              l_txlv_rec.CURRENCY_CONVERSION_TYPE,
              l_txlv_rec.CURRENCY_CONVERSION_RATE,
              l_txlv_rec.CURRENCY_CONVERSION_DATE
              ;
-- Multi-Currency Change
    x_no_data_found := txlv_csr%NOTFOUND;
    CLOSE txlv_csr;
    RETURN(l_txlv_rec);
END get_txlv_rec;
--------------------------------------------------------------------------------
--Function to get trx details for a given tal_id
--------------------------------------------------------------------------------
FUNCTION get_trx_details (
    p_tal_id                       IN  NUMBER,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN txdv_tbl_type IS
    CURSOR txdv_csr(p_tal_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TAL_ID,
            TARGET_KLE_ID,
            LINE_DETAIL_NUMBER,
            ASSET_NUMBER,
            DESCRIPTION,
            QUANTITY,
            COST,
            TAX_BOOK,
            LIFE_IN_MONTHS_TAX,
            DEPRN_METHOD_TAX,
            DEPRN_RATE_TAX,
            SALVAGE_VALUE,
            SPLIT_PERCENT,
            INVENTORY_ITEM_ID,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
--Bug #2723498 : 11.5.9 - Multi currency compliance
            CURRENCY_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
     FROM  Okl_Txd_Assets_v txdv
     WHERE  txdv.tal_id = p_tal_id
     ORDER  BY NVL(target_kle_id,-1)
     --Bug# 3502142
             , NVL(split_percent,-1);

    l_txdv_rec                      txdv_rec_type;
    l_txdv_tbl                      txdv_tbl_type;
    r_count                         NUMBER DEFAULT 0;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN txdv_csr (p_tal_id);
    LOOP
    FETCH txdv_csr INTO
              l_txdv_rec.ID,
              l_txdv_rec.OBJECT_VERSION_NUMBER,
              l_txdv_rec.TAL_ID,
              l_txdv_rec.TARGET_KLE_ID,
              l_txdv_rec.LINE_DETAIL_NUMBER,
              l_txdv_rec.ASSET_NUMBER,
              l_txdv_rec.description,
              l_txdv_rec.QUANTITY,
              l_txdv_rec.COST,
              l_txdv_rec.TAX_BOOK,
              l_txdv_rec.LIFE_IN_MONTHS_TAX,
              l_txdv_rec.DEPRN_METHOD_TAX,
              l_txdv_rec.DEPRN_RATE_TAX,
              l_txdv_rec.SALVAGE_VALUE,
              l_txdv_rec.SPLIT_PERCENT,
              l_txdv_rec.INVENTORY_ITEM_ID,
              l_txdv_rec.ATTRIBUTE_CATEGORY,
              l_txdv_rec.ATTRIBUTE1,
              l_txdv_rec.ATTRIBUTE2,
              l_txdv_rec.ATTRIBUTE3,
              l_txdv_rec.ATTRIBUTE4,
              l_txdv_rec.ATTRIBUTE5,
              l_txdv_rec.ATTRIBUTE6,
              l_txdv_rec.ATTRIBUTE7,
              l_txdv_rec.ATTRIBUTE8,
              l_txdv_rec.ATTRIBUTE9,
              l_txdv_rec.ATTRIBUTE10,
              l_txdv_rec.ATTRIBUTE11,
              l_txdv_rec.ATTRIBUTE12,
              l_txdv_rec.ATTRIBUTE13,
              l_txdv_rec.ATTRIBUTE14,
              l_txdv_rec.ATTRIBUTE15,
              l_txdv_rec.CREATED_BY,
              l_txdv_rec.CREATION_DATE,
              l_txdv_rec.LAST_UPDATED_BY,
              l_txdv_rec.LAST_UPDATE_DATE,
              l_txdv_rec.LAST_UPDATE_LOGIN,
-- Multi-Currency Change
              l_txdv_rec.CURRENCY_CODE,
              l_txdv_rec.CURRENCY_CONVERSION_TYPE,
              l_txdv_rec.CURRENCY_CONVERSION_RATE,
              l_txdv_rec.CURRENCY_CONVERSION_DATE;
-- Multi-Currency Change
              EXIT WHEN txdv_csr%NOTFOUND;
              r_count := txdv_csr%rowcount;
              l_txdv_tbl(r_count) := l_txdv_rec;
    END LOOP;
    CLOSE txdv_csr;
    IF r_count <> 0 THEN
       x_no_data_found := FALSE;
    ELSIF r_count = 0 THEN
       x_no_data_found := TRUE;
    END IF;
    RETURN(l_txdv_tbl);
END get_trx_details;
--------------------------------------------------------------------------------
--Function to verify whether the generated split asset number exists in FA
--------------------------------------------------------------------------------
FUNCTION Asset_Number_Exists(p_asset_number IN VARCHAR2,
                             x_asset_exists OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    l_asset_exists VARCHAR2(1) DEFAULT 'N';
    l_return_status VARCHAR2(1) DEFAULT OKL_API.G_RET_STS_SUCCESS;

    --chk for asset in FA
    CURSOR asset_chk_curs1 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okx_assets_v okx
    WHERE  okx.asset_number = p_asset_number;

    --chk for asset on asset line
    CURSOR asset_chk_curs2 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okl_k_lines_full_v kle,
           okc_line_styles_b  lse
    WHERE  kle.name = p_asset_number
    AND    kle.lse_id = lse.id
    --and    lse.lty_code = 'FIXED_ASSET';
    --Bug# 3222804
    AND    lse.lty_code = 'FREE_FORM1';

    --check for asset on an split asset transaction
    CURSOR asset_chk_curs3 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okl_txd_assets_b txd
    WHERE  NVL(txd.asset_number,'-999999999999999') = p_asset_number
    AND    EXISTS (SELECT NULL
                   FROM   okl_trx_Assets   trx,
                          okl_trx_types_tl ttyp,
                          okl_txl_assets_b txl
                   WHERE  trx.id        = txl.tas_id
                   AND    trx.try_id    = ttyp.id
                   AND    ttyp.name     = 'Split Asset'
                   AND    ttyp.LANGUAGE = 'US'
                   AND    txl.id        = txd.tal_id);


BEGIN
   l_return_status := OKL_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('Asset Number'||p_asset_number);
   l_asset_exists := 'N';
   OPEN asset_chk_curs1(p_asset_number);
       FETCH asset_chk_curs1 INTO l_asset_exists;
       IF asset_chk_curs1%NOTFOUND THEN
          OPEN asset_chk_curs2(p_asset_number);
              FETCH asset_chk_curs2 INTO l_asset_exists;
              IF asset_chk_curs2%NOTFOUND THEN
                  OPEN asset_chk_curs3(p_asset_number);
                      FETCH asset_chk_curs3 INTO l_asset_exists;
                      IF asset_chk_curs3%NOTFOUND THEN
                          NULL;
                      END IF;
                  CLOSE asset_chk_curs3;
              END IF;
           CLOSE asset_chk_curs2;
       END IF;
   CLOSE asset_chk_curs1;
   x_asset_exists := l_asset_exists;
   --return status to caller
   RETURN(l_return_status);
   EXCEPTION
   WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
       --close the cursor
       IF asset_chk_curs1%ISOPEN THEN
          CLOSE asset_chk_curs1;
       END IF;
       IF asset_chk_curs2%ISOPEN THEN
          CLOSE asset_chk_curs2;
       END IF;
       IF asset_chk_curs3%ISOPEN THEN
          CLOSE asset_chk_curs3;
       END IF;
       --send back status to caller
       l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
END Asset_Number_Exists;
--------------------------------------------------------------------------------
--Function to validate okl_txd_Assets_v attributes
--------------------------------------------------------------------------------
FUNCTION Validate_Attributes (p_txdv_rec IN txdv_rec_type)
  RETURN VARCHAR2 IS

   l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    --chk for asset in FA
    CURSOR asset_chk_curs1 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okx_assets_v okx
    WHERE  okx.asset_number = p_asset_number;

    --chk for asset on asset line
    CURSOR asset_chk_curs2 (p_asset_number IN VARCHAR2) IS
    SELECT 'Y'
    FROM   okl_k_lines_full_v kle,
           okc_line_styles_b  lse
    WHERE  kle.name = p_asset_number
    AND    kle.lse_id = lse.id
    AND    lse.lty_code = 'FIXED_ASSET';


    --check for asset on an split asset transaction
    CURSOR asset_chk_curs3 (p_asset_number IN VARCHAR2, p_txdv_id IN NUMBER) IS
    SELECT 'Y'
    FROM   okl_txd_assets_b txd,
           okl_txl_assets_b txl,
           okl_trx_types_tl ttyp,
           okl_trx_assets   trx
    WHERE  NVL(txd.asset_number,'-999999999999999') = p_asset_number
    AND    txd.tal_id    = txl.id
    AND    txl.tas_id    = trx.id
    AND    trx.try_id    = ttyp.id
    AND    ttyp.name     = 'Split Asset'
    AND    ttyp.LANGUAGE = 'US'
    AND    NVL(txd.target_kle_id,-99) <> txl.kle_id
    AND    trx.tsu_code = 'ENTERED'
    AND    txd.id <> p_txdv_id;

   --check for asset on create asset or rebook transaction
   CURSOR asset_chk_curs4 (p_asset_number IN VARCHAR2) IS
   SELECT 'Y'
   FROM   okl_txl_assets_b txl
   WHERE  txl.asset_number = p_asset_number
   AND    txl.tal_type IN ('ALI','CRB'); --only transactions apart from split which create a new line


   l_txdv_rec      txdv_rec_type;
   l_asset_exists  VARCHAR2(1) DEFAULT 'N';

BEGIN
    l_txdv_rec := p_txdv_rec;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    --1.Validate existence of asset number
    IF (l_txdv_rec.asset_number IS NULL) OR (l_txdv_rec.asset_number = OKL_API.G_MISS_CHAR) THEN
     -- store SQL error message on message stack
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_ASSET_REQUIRED);
       l_return_status := OKL_API.G_RET_STS_ERROR;
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF LENGTH(l_txdv_rec.asset_number) > 15 THEN
           -- store SQL error message on message stack
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_ASSET_LENGTH);
           l_return_status := OKL_API.G_RET_STS_ERROR;
           -- halt validation as it is a required field
           RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
           l_asset_exists := 'N';
           OPEN asset_chk_curs1(l_txdv_rec.asset_number);
           FETCH asset_chk_curs1 INTO l_asset_exists;
           IF asset_chk_curs1%NOTFOUND THEN
               OPEN asset_chk_curs2(l_txdv_rec.asset_number);
               FETCH asset_chk_curs2 INTO l_asset_exists;
               IF asset_chk_curs2%NOTFOUND THEN
                  OPEN asset_chk_curs3(l_txdv_rec.asset_number,l_txdv_rec.id);
                      FETCH asset_chk_curs3 INTO l_asset_exists;
                      IF asset_chk_curs3%NOTFOUND THEN
                          OPEN asset_chk_curs4 (l_txdv_rec.asset_number);
                          FETCH asset_chk_curs4 INTO l_asset_exists;
                          IF asset_chk_curs4%NOTFOUND THEN
                              NULL;
                          END IF;
                      END IF;
                  CLOSE asset_chk_curs3;
              END IF;
              CLOSE asset_chk_curs2;
           END IF;
           CLOSE asset_chk_curs1;
           IF l_asset_exists = 'Y' THEN
              -- store SQL error message on message stack
              OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_NOT_UNIQUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Asset Number '|| l_txdv_rec.asset_number);
              l_return_status := OKL_API.G_RET_STS_ERROR;
              -- halt validation as it is a required field
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
      END IF;
   END IF;
   RETURN(l_return_status);

   EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
        RETURN(l_return_status);
   WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
       --close the cursor
       IF asset_chk_curs1%ISOPEN THEN
          CLOSE asset_chk_curs1;
       END IF;
       IF asset_chk_curs2%ISOPEN THEN
          CLOSE asset_chk_curs2;
       END IF;
       IF asset_chk_curs3%ISOPEN THEN
          CLOSE asset_chk_curs3;
       END IF;
       IF asset_chk_curs4%ISOPEN THEN
          CLOSE asset_chk_curs4;
       END IF;
       --send back status to caller
       l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
END Validate_Attributes;
-------------------------------------------------------------------------------
--Function to verify TRY_ID for the transaction try_id
-------------------------------------------------------------------------------
FUNCTION get_try_id(p_try_name  IN  OKL_TRX_TYPES_V.NAME%TYPE,
                    x_try_id    OUT NOCOPY OKC_LINE_STYLES_V.ID%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_get_try_id(p_try_name  OKL_TRX_TYPES_V.NAME%TYPE) IS
    SELECT id
    FROM   OKL_TRX_TYPES_TL
    WHERE UPPER(name) = UPPER(p_try_name)
    AND   LANGUAGE = 'US';
BEGIN
   IF (p_try_name = OKL_API.G_MISS_CHAR) OR
       (p_try_name IS NULL) THEN
       -- store SQL error message on message stack
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_DATA_FOUND,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => p_try_name);
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN c_get_try_id(p_try_name);
    FETCH c_get_try_id INTO x_try_id;
    IF c_get_try_id%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_DATA_FOUND,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => p_try_name);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_try_id;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
     IF c_get_try_id%ISOPEN THEN
        CLOSE c_get_try_id;
     END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_try_id%ISOPEN THEN
        CLOSE c_get_try_id;
     END IF;
     RETURN(x_return_status);
 END get_try_id;
--------------------------------------------------------------------------------
--Function to verify whether the line id is correct or not
--------------------------------------------------------------------------------
FUNCTION verify_cle_id(p_cle_id IN NUMBER) RETURN VARCHAR2 IS
        CURSOR Chk_Top_Line(p_cle_id IN NUMBER) IS
        SELECT 'Y'
        FROM   OKC_K_LINES_B cle
        WHERE  cle.id = p_cle_id
        AND        EXISTS (SELECT '1'
                   FROM   OKC_LINE_STYLES_B lse
                       WHERE  lse.id = cle.lse_id
                   AND    lse.lty_code = G_FIN_AST_LTY_CODE
                   AND    lse.lse_type = G_TOP_LINE_STYLE)
        AND        EXISTS (SELECT '1'
                           FROM OKC_SUBCLASS_TOP_LINE stl,
                                OKC_K_HEADERS_B CHR
                           WHERE stl.lse_id = cle.lse_id
                           AND   stl.scs_code = CHR.scs_code
                           AND   CHR.id = cle.chr_id);
    l_chk_top_line VARCHAR2(1) DEFAULT 'N';
    l_return_status VARCHAR2(1) DEFAULT OKL_API.G_RET_STS_SUCCESS;
BEGIN
    OPEN Chk_Top_Line(p_cle_id);
    FETCH Chk_Top_Line INTO l_chk_top_line;
        IF chk_top_line%NOTFOUND THEN
           ----dbms_output.put_line('Not a correct top line id');
           NULL;
        END IF;
    CLOSE Chk_Top_Line;
    IF l_chk_top_line <> 'Y' THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => G_INVALID_TOP_LINE);
        l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
    EXCEPTION
    WHEN OTHERS THEN
    l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    OKL_API.set_message(
            G_APP_NAME,
            G_UNEXPECTED_ERROR,
            G_SQLCODE_TOKEN,
            SQLCODE,
            G_SQLERRM_TOKEN,
            SQLERRM);
    IF Chk_top_line%ISOPEN THEN
        CLOSE Chk_top_line;
    END IF;
    RETURN(l_return_status);
END verify_cle_id;
-------------------------------------------------------------------------------
--Function to get FA location id. An asset after being sent to FA may have been
-- assigned to different FA locations. Since OKL takes only only one FA location
--right now , we will pick up only one location.
------------------------------------------------------------------------------
FUNCTION get_fa_location (p_asset_id IN VARCHAR2,
                             p_book_type_code IN VARCHAR2,
                             x_location_id OUT NOCOPY NUMBER)
RETURN VARCHAR2 IS
    CURSOR fa_location_curs(p_asset_id       IN VARCHAR2,
                            p_book_type_code IN VARCHAR2) IS
    SELECT location_id
    FROM   okx_ast_dst_hst_v
    WHERE  asset_id = p_asset_id
    AND    book_type_code = p_book_type_code
    AND    status = 'A'
    AND    NVL(start_date_active,SYSDATE) <= SYSDATE
    AND    NVL(end_date_active,SYSDATE+1) > SYSDATE
    AND    transaction_header_id_out IS NULL
    AND    retirement_id IS NULL
    AND    ROWNUM < 2;
--This is strange way to get one location
--since asset can be assigned to multiple
--fa locations. But till we know what we have to do
--this is it.
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_location_id   NUMBER DEFAULT NULL;
BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN fa_location_curs(p_asset_id,
                          p_book_type_code);
       FETCH fa_location_curs
       INTO  l_location_id;
       IF fa_location_curs%NOTFOUND THEN
          NULL; --location not found that is not a problem
                --as it is not a mandatory field
       END IF;
    CLOSE fa_location_curs;
    RETURN(l_return_status);
    EXCEPTION
    WHEN OTHERS THEN
         -- notify caller of an UNEXPECTED error
         l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         OKL_API.set_message(
            G_APP_NAME,
            G_UNEXPECTED_ERROR,
            G_SQLCODE_TOKEN,
            SQLCODE,
            G_SQLERRM_TOKEN,
            SQLERRM);
         -- if the cursor is open
         IF fa_location_curs%ISOPEN THEN
            CLOSE fa_location_curs;
          END IF;
     RETURN(l_return_status);
END Get_fa_Location;
--------------------------------------------------------------------------------
--Procedure to create transaction header (OKL_TRX_ASSETS_V)
--------------------------------------------------------------------------------
PROCEDURE Create_trx_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TRX_HEADER';
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
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => p_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);

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
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKC_API.G_RET_STS_UNEXP_ERROR',
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
  END Create_trx_header;
--------------------------------------------------------------------------------
--PROCEDURE to update transaction_header (OKL_TRX_ASSETS_V)
--------------------------------------------------------------------------------
PROCEDURE Update_trx_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TRX_HEADER';
  BEGIN
    x_return_status        := OKL_API.G_RET_STS_SUCCESS;
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
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => p_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKC_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKC_API.G_RET_STS_UNEXP_ERROR',
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
END Update_trx_header;
--------------------------------------------------------------------------------
--Procedure to create split transaction details (okl_txd_assets_b)
--Bug# 2798006 : Modifications for Loan contract - instead of reading values from
--p_ast_line_rec will read from p_txlv_rec
--------------------------------------------------------------------------------
PROCEDURE Create_trx_details(p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             p_ast_line_rec   IN  ast_line_rec_type,
                             p_txlv_rec       IN  txlv_rec_type,
                             x_txdv_tbl       OUT NOCOPY txdv_tbl_type) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_TRX_DETAILS';
l_api_version          CONSTANT NUMBER := 1.0;

l_split_into_individuals_yn VARCHAR2(1);
l_split_into_units          NUMBER;
l_units_on_child_line       NUMBER;
l_total_salvage_value       NUMBER;
l_total_cost                NUMBER;
l_total_quantity            NUMBER;
l_txdv_rec                  txdv_rec_type;
l_txdv_rec_out              txdv_rec_type;

l_asset_exists         VARCHAR2(1) DEFAULT 'N';
j                      NUMBER      DEFAULT 0; --counter for generating split asset numbers
i                      NUMBER      DEFAULT 0;
l_split_unit_count     NUMBER      DEFAULT 0;

BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_split_into_individuals_yn := NVL(p_txlv_rec.SPLIT_INTO_SINGLES_FLAG,'N');
    --dbms_output.put_line('Split into individuals'||l_split_into_individuals_yn);
    --dbms_output.put_line('ast rec current units'||to_char(p_ast_line_rec.current_units));
    --dbms_output.put_line('txlv rec units retired'||to_char(p_txlv_rec.split_into_units));
    --prepared record for OKL_TXD_ASSETS_V
    IF  l_split_into_individuals_yn = 'Y' THEN
        --l_split_into_units := p_ast_line_rec.current_units;
        l_split_into_units := p_txlv_rec.current_units;
        l_units_on_child_line := 1;
    ELSIF NVL(l_split_into_individuals_yn,'N') = 'N' THEN
        l_split_into_units := 2;
        -- l_units_on_child_line := p_split_into_units;
        l_units_on_child_line := p_txlv_rec.SPLIT_INTO_UNITS;
    END IF;
        l_total_salvage_value := 0;
        l_total_cost := 0;
        l_total_quantity := 0;
        --dbms_output.put_line('Split into units'||to_char(l_split_into_units));
        --dbms_output.put_line('units on child line'||to_char(l_units_on_child_line));
        FOR i IN 1..(l_split_into_units - 1)
        LOOP
            --dbms_output.put_line('Into split loop');
            l_txdv_rec.tal_id := p_txlv_rec.id;
            l_txdv_rec.line_detail_number := i + 1;
            --l_txdv_rec.description := p_ast_line_rec.description;
            l_txdv_rec.description := p_txlv_rec.description;
            --dbms_output.put_line('Description from FA'|| p_ast_line_rec.description);

            --generate an asset number which does not exist in FA
            j := j+1;
            LOOP
                --dbms_output.put_line('Into asset number gen loop');
                --dbms_output.put_line('Asset Number'||p_ast_line_rec.asset_number||'.'||to_char(j));
                SELECT 'OKL'||TO_CHAR(okl_fan_seq.NEXTVAL)
                INTO l_txdv_rec.asset_number FROM dual;
                --dbms_output.put_line('Asset Number'||l_txdv_rec.asset_number);
                x_return_status := Asset_Number_Exists(l_txdv_rec.asset_number,l_asset_exists);
                --dbms_output.put_line('after asset number validate'||x_return_status);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                IF l_asset_exists = 'Y' THEN
                   j:= j+1;
                ELSIF l_asset_exists = 'N' THEN
                    EXIT;
                END IF;
            END LOOP;
            --dbms_output.put_line('Out of generation of asset number');
            l_txdv_rec.quantity := l_units_on_child_line;
            --l_txdv_rec.cost     := (p_ast_line_rec.cost/p_ast_line_rec.current_units)*l_units_on_child_line;
            l_txdv_rec.cost     := (p_txlv_rec.depreciation_cost/p_txlv_rec.current_units)*l_units_on_child_line;
            --l_txdv_rec.salvage_value := (p_ast_line_rec.salvage_value/p_ast_line_rec.current_units)*l_units_on_child_line;
            l_txdv_rec.salvage_value := (p_txlv_rec.salvage_value/p_txlv_rec.current_units)*l_units_on_child_line;
            l_total_cost := l_total_cost + l_txdv_rec.cost;
            l_total_salvage_value := l_total_salvage_value + l_txdv_rec.salvage_value;
            l_total_quantity := l_total_quantity + l_units_on_child_line;

            ---Bug#2723498 : 11.5.9 Currency conversion
            l_txdv_rec.currency_code            := p_txlv_rec.currency_code;
            --bug fix# 2770114
            --l_txdv_rec.currency_conversion_type := p_txlv_rec.currency_code;
            l_txdv_rec.currency_conversion_type := p_txlv_rec.currency_conversion_type;
            l_txdv_rec.currency_conversion_rate := p_txlv_rec.currency_conversion_rate;
            l_txdv_rec.currency_conversion_date := p_txlv_rec.currency_conversion_date;
            ---Bug#2723498 : 11.5.9 Currency conversion

            --dbms_output.put_line('Creating trx detail for child asset');
            --dbms_output.put_line('Before Creating trx detail for child asset'||l_txdv_rec.description);
            OKL_TXD_ASSETS_PUB.create_txd_asset_def(p_api_version   =>  p_api_version,
                                                    p_init_msg_list =>  p_init_msg_list,
                                                    x_return_status =>  x_return_status,
                                                    x_msg_count     =>  x_msg_count,
                                                    x_msg_data      =>  x_msg_data,
                                                    p_adpv_rec      =>  l_txdv_rec,
                                                    x_adpv_rec      =>  l_txdv_rec_out);
            --dbms_output.put_line('After Creating trx detail for child asset'||x_return_status);
            --dbms_output.put_line('After Creating trx detail for child asset'||l_txdv_rec_out.description);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_split_unit_count := i;
            x_txdv_tbl(l_split_unit_count) := l_txdv_rec_out;
        END LOOP;
        --split record for the parent asset
        l_txdv_rec.tal_id := p_txlv_rec.id;
        --l_txdv_rec.target_kle_id := p_ast_line_rec.id1;
        l_txdv_rec.target_kle_id := p_txlv_rec.kle_id;
        l_txdv_rec.line_detail_number := 1;
        --l_txdv_rec.description := p_ast_line_rec.description;
        l_txdv_rec.description := p_txlv_rec.description;
        --l_txdv_rec.asset_number := p_ast_line_rec.asset_number;
        l_txdv_rec.asset_number := p_txlv_rec.asset_number;
        --l_txdv_rec.quantity := (p_ast_line_rec.current_units - l_total_quantity);
        l_txdv_rec.quantity := (p_txlv_rec.current_units - l_total_quantity);

        ------------------------------------------------------------------------
        --quantity less that 1 is possible in FA
        --If l_txdv_rec.quantity < 1 Then
            --l_txdv_rec.quantity := 1;
        --End If;
        --quantity less than 1 is possible in FA
        ------------------------------------------------------------------------
        --l_txdv_rec.cost     := (p_ast_line_rec.cost - l_total_cost);
        l_txdv_rec.cost     := (p_txlv_rec.depreciation_cost - l_total_cost);
        --l_txdv_rec.salvage_value := (p_ast_line_rec.salvage_value - l_total_salvage_value);
        l_txdv_rec.salvage_value := (p_txlv_rec.salvage_value - l_total_salvage_value);

        ---Bug#2723498 : 11.5.9 Currency conversion
        l_txdv_rec.currency_code := p_txlv_rec.currency_code;
        --Bug# 2770114
        --l_txdv_rec.currency_conversion_type := p_txlv_rec.currency_code;
        l_txdv_rec.currency_conversion_type := p_txlv_rec.currency_conversion_type;
        l_txdv_rec.currency_conversion_rate := p_txlv_rec.currency_conversion_rate;
        l_txdv_rec.currency_conversion_date := p_txlv_rec.currency_conversion_date;
        ---Bug#2723498 : 11.5.9 Currency conversion

        --dbms_output.put_line('before Creating trx detail for parent asset'||x_return_status);
        OKL_TXD_ASSETS_PUB.create_txd_asset_def(p_api_version   =>  p_api_version,
                                                p_init_msg_list =>  p_init_msg_list,
                                                x_return_status =>  x_return_status,
                                                x_msg_count     =>  x_msg_count,
                                                x_msg_data      =>  x_msg_data,
                                                p_adpv_rec      =>  l_txdv_rec,
                                                x_adpv_rec      =>  l_txdv_rec_out);
                --dbms_output.put_line('after Creating trx detail for parent asset'||x_return_status);
        --dbms_output.put_line('After Creating trx detail for child asset'||x_return_status);
        --dbms_output.put_line('After Creating trx detail for child asset'||l_txdv_rec_out.description);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        x_txdv_tbl(l_split_unit_count + 1) := l_txdv_rec_out;
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

END Create_Trx_details;
--------------------------------------------------------------------------------
--Start of Comments
--Bug #2723498 : 11.5.9 enhancement for splitting assets by serial number
--API Name    : is_serialized
--Description : Function to find if asset is serialized
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--End of comments
--------------------------------------------------------------------------------
FUNCTION is_serialized(p_cle_id IN NUMBER) RETURN VARCHAR2 IS
--Bug Fix # 2887948
--Cursor to check whether inventory item is serialized
CURSOR chk_srl_csr (fin_ast_id IN NUMBER) IS
SELECT mtl.serial_number_control_code,
       mtl.inventory_item_id,
       mtl.organization_id
FROM   mtl_system_items  mtl,
       okc_k_items       model_cim,
       okc_k_lines_b     model_cle,
       okc_line_styles_b model_lse
WHERE  model_cim.object1_id2       = TO_CHAR(mtl.organization_id)
AND    model_cim.object1_id1       = mtl.inventory_item_id
AND    model_cim.jtot_object1_code = 'OKX_SYSITEM'
AND    model_cim.cle_id            = model_cle.id
AND    model_cim.dnz_chr_id        = model_cle.dnz_chr_id
AND    model_cle.cle_id            = fin_ast_id
AND    model_cle.lse_id            = model_lse.id
AND    model_lse.lty_code          = 'ITEM';

chk_srl_rec  chk_srl_csr%ROWTYPE;

l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

BEGIN
    l_serialized := OKL_API.G_FALSE;
    --user needs to select serial numbers to split out
    OPEN chk_srl_csr (fin_ast_id => p_cle_id);
    FETCH chk_srl_csr INTO chk_srl_rec;
    IF chk_srl_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE chk_srl_csr;

    IF chk_srl_rec.serial_number_control_code IN (2,5,6) THEN
    -- asset inventory item is serial number controlled
        l_serialized := OKL_API.G_TRUE;
    END IF;

    RETURN (l_serialized);
END is_serialized;
--------------------------------------------------------------------------------
--Start of Comments
--Bug # 2726870 : 11.5.9 enhancement for splitting assets by serial number
--API Name    : Is_Inv_Item_Serialized
--Description : API will determine whether inv item is serialized or not
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Is_Inv_Item_Serialized(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 p_inv_item_id      IN  NUMBER,
                                 p_chr_id           IN  NUMBER,
                                 p_cle_id           IN  NUMBER,
                                 x_serialized       OUT NOCOPY VARCHAR2) IS
l_api_version CONSTANT NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'IS_INV_ITEM_SERIALIZED';

l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

--cursor to find serialized
CURSOR srl_ctrl_csr (p_inv_item_id IN NUMBER,
                     p_chr_id IN NUMBER) IS
SELECT mtl.serial_number_control_code
FROM   mtl_system_items  mtl,
       okc_k_headers_b chrb
WHERE  mtl.inventory_item_id = p_inv_item_id
AND    mtl.organization_id   = chrb.inv_organization_id
--BUG# 3489089
AND    chrb.id               = p_chr_id;

--cursor2  to find serialized
CURSOR srl_ctrl_csr2 (p_inv_item_id IN NUMBER,
                      p_cle_id IN NUMBER) IS
SELECT mtl.serial_number_control_code
FROM   mtl_system_items     mtl,
       okc_k_headers_b      chrb,
       okc_k_lines_b        cleb
WHERE  mtl.inventory_item_id = p_inv_item_id
AND    mtl.organization_id   = chrb.inv_organization_id
AND    chrb.id               = cleb.dnz_chr_id
AND    cleb.id               = p_cle_id;

l_srl_control_code   mtl_system_items.serial_number_control_code%TYPE;

l_exception_halt     EXCEPTION;

BEGIN
   x_serialized := OKL_API.G_FALSE;
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

    l_serialized := OKL_API.G_FALSE;
    IF p_chr_id IS NOT NULL OR p_chr_id <> OKL_API.G_MISS_NUM THEN
        OPEN srl_ctrl_csr (p_inv_item_id => p_inv_item_id,
                           p_chr_id      => p_chr_id);
        FETCH srl_ctrl_csr INTO
          l_srl_control_code;
        CLOSE srl_ctrl_csr;
    ELSIF p_cle_id IS NOT NULL OR p_cle_id <> OKL_API.G_MISS_NUM THEN
        OPEN srl_ctrl_csr2 (p_inv_item_id => p_inv_item_id,
                            p_cle_id      => p_cle_id);
        FETCH srl_ctrl_csr2 INTO
          l_srl_control_code;
        CLOSE srl_ctrl_csr2;
    ELSE
         RAISE l_exception_halt;
    END IF;

    IF NVL(l_srl_control_code,0) IN (2,5,6) THEN
        l_serialized := OKL_API.G_TRUE;
    END IF;
   x_serialized := l_serialized;
   OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN l_exception_halt THEN
        NULL;
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
END Is_Inv_Item_Serialized;
--------------------------------------------------------------------------------
--Start of Comments
--Bug # 2726870 : 11.5.9 enhancement for Splitting Asets by serial number
--API Name    : Is_Asset_Serialized
--Description : API will find if asset is serialized
--------------------------------------------------------------------------------
PROCEDURE Is_Asset_Serialized(p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2) IS

l_api_version CONSTANT NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'IS_ASSET_SERIALIZED';

l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
BEGIN
   x_serialized     := OKL_API.G_FALSE;
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

   l_serialized := OKL_API.G_FALSE;
   l_serialized := Is_serialized(p_cle_id => p_cle_id);
   x_serialized := l_serialized;
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
END Is_Asset_Serialized;
--------------------------------------------------------------------------------
--Start of Comments
--Bug # 2726870 : 11.5.9 enhancement for splitting assets by serial number
--API Name    : Asset_Not_Srlz_Halt
--              (Stop_if_Asset_Not_Serialized)
--Description : API to be clled from UI - will raise Error if Asset not serialized
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Asset_Not_Srlz_Halt(p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2) IS
l_api_version CONSTANT NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'ASSET_NOT_SRLZ_HALT';

l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
BEGIN
-----
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

   l_serialized := OKL_API.G_FALSE;
   x_serialized := l_serialized;
   Is_Asset_Serialized(p_api_version     => p_api_version,
                       p_init_msg_list   => p_init_msg_list,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_cle_id          => p_cle_id,
                       x_serialized      => l_serialized);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   x_serialized := l_serialized;
   IF l_serialized = OKL_API.G_FALSE THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_ASSET_NOT_SERIALIZED);
        x_return_status := OKL_API.G_RET_STS_ERROR;
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
END Asset_Not_Srlz_Halt;
--------------------------------------------------------------------------------
--Start of Comments
--Bug # 2726870 : 11.5.9 enhancement for splitting assets by serial number
--API Name    : Item_Not_Srlz_Halt
--              (Stop_if_Asset_Not_Serialized)
--Description : API to be clled from UI - will raise Error if Asset not serialized
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Item_Not_Srlz_Halt(p_api_version       IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_inv_item_id      IN  NUMBER,
                              p_chr_id           IN  NUMBER,
                              p_cle_id           IN  NUMBER,
                              x_serialized       OUT NOCOPY VARCHAR2) IS
l_api_version CONSTANT NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'ITEM_NOT_SRLZ_HALT';

l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
BEGIN
-----
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

   l_serialized := OKL_API.G_FALSE;
   x_serialized := l_serialized;
   Is_Inv_Item_Serialized(p_api_version     => p_api_version,
                          p_init_msg_list   => p_init_msg_list,
                          x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data,
                          p_inv_item_id     => p_inv_item_id,
                          p_chr_id          => p_chr_id,
                          p_cle_id          => p_cle_id,
                          x_serialized      => l_serialized);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   x_serialized := l_serialized;
   IF l_serialized = OKL_API.G_FALSE THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_ASSET_NOT_SERIALIZED);
        x_return_status := OKL_API.G_RET_STS_ERROR;
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
END Item_Not_Srlz_Halt;
--------------------------------------------------------------------------------
--Start of Comments
--Bug # 2726870 : 11.5.9 enhancement for splitting assets by serial number
--API Name    : Validate_Serial_Number
--Description : LOCAL API will validate serial number
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Validate_Serial_Number(x_return_status OUT nocopy VARCHAR2,
                                 p_serial_number IN VARCHAR2) IS
     l_serial_number okl_txl_itm_insts.serial_number%TYPE;

     --Cursor to find existence
     CURSOR srl_num_csr (Srl_Number IN VARCHAR2) IS
     SELECT serial_number
     FROM   csi_item_instances
     WHERE  serial_number = Srl_Number;

     l_csi_srl_number csi_item_instances.serial_number%TYPE DEFAULT NULL;

BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     l_serial_number := p_serial_number;
     IF l_serial_number IS NULL OR l_serial_number = OKL_API.G_MISS_CHAR THEN
         -- store SQL error message on message stack
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'serial_number');
        x_return_status := OKL_API.G_RET_STS_ERROR;
     ELSE
        l_csi_srl_number := NULL;
        OPEN srl_num_csr (Srl_Number => l_serial_number);
        FETCH srl_num_csr INTO l_csi_srl_number;
        IF srl_num_csr%NOTFOUND THEN
           NULL;
        END IF;
        CLOSE srl_num_csr;

        IF l_csi_srl_number IS NOT NULL
           AND l_csi_srl_number = l_serial_number THEN
           OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_SRL_NUM_DUPLICATE,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => l_serial_number);
           x_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END Validate_Serial_Number;
---------------------------------------------------------------------------------------------------------------
  FUNCTION generate_instance_number_ib(x_instance_number_ib  OUT NOCOPY OKL_TXL_ITM_INSTS_V.INSTANCE_NUMBER_IB%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    -- cursor to get sequence number for asset number
    CURSOR c_instance_no_ib IS
    SELECT TO_CHAR(OKL_IBN_SEQ.NEXTVAL)
    FROM dual;
  BEGIN
    OPEN  c_instance_no_ib;
    FETCH c_instance_no_ib INTO x_instance_number_ib;
    IF (c_instance_no_ib%NOTFOUND) THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
    END IF;
    CLOSE c_instance_no_ib;
    RETURN x_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_instance_no_ib%ISOPEN THEN
        CLOSE c_instance_no_ib;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
    RETURN x_return_status;
  END generate_instance_number_ib;
--------------------------------------------------------------------------------
--Start of Comments
--Bug # 2726870: 11.5.9 enhancement for splitting assets by serial number
--API Name    : create_split_comp_srl_num
--Description : API will create serial_number records in OKL_TXL_ITM_INSTS_V
--              If financial asset inventory item is serialized for a split asset
--              component
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--                                     Bug# 7047938
--              17-May-2008   avsingh  After OA migration tal_id is not being
--                                     passed from the UI as part of the input
--                                     record. Added l_tal_csr to fetch it based
--                                     on asd id
--End of comments
--------------------------------------------------------------------------------
PROCEDURE create_split_comp_srl_num(p_api_version      IN  NUMBER,
                                    p_init_msg_list    IN  VARCHAR2,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2,
                                    p_itiv_tbl         IN  itiv_tbl_type,
                                    x_itiv_tbl         OUT NOCOPY itiv_tbl_type) IS

l_api_name   VARCHAR2(30) := 'CREATE_SPLIT_COMP_SRL_NUM';
l_api_version CONSTANT NUMBER := 1.0;

--Cursor to get inventory organization ids
CURSOR inv_org_csr (p_tal_id IN NUMBER, p_asd_id IN NUMBER) IS
SELECT mp.master_organization_id,
       chrb.inv_organization_id,
       txdb.inventory_item_id
FROM   mtl_parameters mp,
       okc_k_headers_b chrb,
       okc_k_lines_b  cleb,
       okl_txl_Assets_b txlb,
       okl_txd_assets_b txdb
WHERE  mp.organization_id = chrb.inv_organization_id
AND    chrb.id            = cleb.dnz_chr_id
AND    cleb.id            = txlb.kle_id
AND    txlb.id            = p_tal_id
AND    txdb.id            = p_asd_id;

l_mast_org_id mtl_parameters.master_organization_id%TYPE;
l_inv_org_id  okc_k_headers_b.inv_organization_id%TYPE;
l_inv_item_id okl_txd_assets_b.inventory_item_id%TYPE;

--Cursor to get location of parent instance from IB
CURSOR ib_loc_csr (p_tal_id IN NUMBER) IS
SELECT txlb.kle_id  fa_cle_id,
       ib_cle.id ib_cle_id,
       txlb.tas_id,
       csi.location_id,  --hz_locations
       csi.install_location_id,
       --Bug# 3569441
       csi.install_location_type_code,  --hz_party_sites, hz_locations
       csi.instance_number
FROM   csi_item_instances  csi,
       csi_instance_statuses csi_inst_sts,
       okc_k_items         ib_cim,
       okc_k_lines_b       ib_cle,
       okc_line_styles_b   ib_lse,
       okc_k_lines_b       inst_cle,
       okc_line_styles_b   inst_lse,
       okc_statuses_b      inst_sts,
       okc_k_lines_b       fa_cle,
       okc_line_styles_b   fa_lse,
       okl_txl_assets_b    txlb
WHERE  csi.instance_id    = TO_NUMBER(ib_cim.object1_id1)
AND    csi_inst_sts.instance_status_id = csi.instance_status_id
AND    NVL(csi_inst_sts.terminated_flag,'N') = 'N'
AND    ib_cim.cle_id      = ib_cle.id
AND    ib_cim.dnz_chr_id  = ib_cle.dnz_chr_id
AND    ib_cle.cle_id      = inst_cle.id
AND    ib_cle.dnz_chr_id  = inst_cle.dnz_chr_id
AND    ib_cle.lse_id      = ib_lse.id
AND    ib_lse.lty_code    = 'INST_ITEM'
AND    inst_cle.cle_id    = fa_cle.cle_id
AND    inst_cle.dnz_chr_id = fa_cle.dnz_chr_id
AND    inst_cle.lse_id    = inst_lse.id
AND    inst_lse.lty_code  = 'FREE_FORM2'
AND    inst_sts.code      = inst_cle.sts_code
AND    INST_STS.STE_CODE NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
AND    fa_cle.id          = txlb.kle_id
AND    fa_cle.lse_id      = fa_lse.id
AND    fa_lse.lty_code    = 'FIXED_ASSET'
AND    txlb.id            = p_tal_id;

l_fa_cle_id           okc_k_lines_b.id%TYPE;
l_ib_cle_id           okc_k_lines_b.id%TYPE;
l_tas_id              okl_txl_assets_b.tas_id%TYPE;
l_location_id         csi_item_instances.location_id%TYPE;
l_install_location_id csi_item_instances.install_location_id%TYPE;
--BUG# 3569441
l_location_type_code  csi_item_instances.install_location_type_code%TYPE;
l_instance_number_csi csi_item_instances.instance_number%TYPE;

--Cursor to get install site use id
CURSOR inst_site_csr (pty_site_id IN NUMBER) IS
SELECT TO_CHAR(Party_site_use_id) party_site_use_id
FROM   hz_party_site_uses
WHERE  party_site_id = pty_site_id
AND    site_use_type = 'INSTALL_AT';


  --BUG# 3569441
  CURSOR inst_loc_csr (loc_id IN NUMBER) IS
  SELECT TO_CHAR(psu.party_site_use_id) party_site_use_id
  FROM   hz_party_site_uses psu,
         hz_party_sites     ps
  WHERE  psu.party_site_id    = ps.party_site_id
  AND    psu.site_use_type    = 'INSTALL_AT'
  AND    ps.location_id       = loc_id;

  --Cursor to get address for error
  CURSOR l_address_csr (pty_site_id IN NUMBER ) IS
  SELECT SUBSTR(arp_addr_label_pkg.format_address(NULL,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,NULL,hl.country,NULL, NULL,NULL,NULL,NULL,NULL,NULL,'n','n',80,1,1),1,80)
  FROM hz_locations hl,
       hz_party_sites ps
  WHERE hl.location_id = ps.location_id
  AND   ps.party_site_id = pty_site_id;

  CURSOR l_address_csr2 (loc_id IN NUMBER) IS
  SELECT SUBSTR(arp_addr_label_pkg.format_address(NULL,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,NULL,hl.country,NULL, NULL,NULL,NULL,NULL,NULL,NULL,'n','n',80,1,1),1,80)
  FROM hz_locations hl
  WHERE hl.location_id = loc_id;

  l_address VARCHAR2(80);
  --END BUG# 3569441

l_party_site_use_id   okl_txl_itm_insts.object_id1_new%TYPE;
l_itiv_tbl            itiv_tbl_type;
l_itiv_rec            itiv_rec_type;
lx_itiv_rec           itiv_rec_type;
i                     NUMBER;
j                     NUMBER;
l_instance_number     OKL_TXL_ITM_INSTS.instance_number_ib%TYPE;

--Bug # 7047938
cursor l_tal_csr (p_asd_id in number) is
select tal_id
from   okl_txd_assets_b
where  id = p_asd_id;

l_tal_id okl_txd_assets_b.tal_id%TYPE;
--Bug 7047938 End
BEGIN
----
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

    l_itiv_tbl := p_itiv_tbl;
    IF l_itiv_tbl.COUNT > 0 THEN
        --Bug # 7047938
        If l_itiv_tbl(1).tal_id is NULL OR l_itiv_tbl(1).tal_id = OKL_API.G_MISS_NUM
        then
            open l_tal_csr (p_asd_id => l_itiv_tbl(1).asd_id);
            Fetch l_tal_csr into l_tal_id;
            close l_tal_csr;
            for j in l_itiv_tbl.FIRST..l_itiv_tbl.LAST
            LOOP
                l_itiv_tbl(j).tal_id := l_tal_id;
            END LOOP;
        End If;
        --Bug # 7047938 End
      --get inv org id
      OPEN inv_org_csr (p_tal_id => l_itiv_tbl(1).tal_id,
                        p_asd_id => l_itiv_tbl(1).asd_id);
      FETCH inv_org_csr INTO
                        l_mast_org_id,
                        l_inv_org_id,
                        l_inv_item_id;
      IF inv_org_csr%NOTFOUND THEN
         NULL; --this is not feasible
      END IF;
      CLOSE inv_org_csr;

      --get locations
      OPEN ib_loc_csr (p_tal_id => l_itiv_tbl(1).tal_id);
      FETCH ib_loc_csr INTO
                      l_fa_cle_id,
                      l_ib_cle_id,
                      l_tas_id,
                      l_location_id,
                      l_install_location_id,
                      --Bug# 3569441
                      l_location_type_code,
                      l_instance_number_csi;
      IF ib_loc_csr%NOTFOUND THEN
          NULL; -- should not happen
      END IF;
      CLOSE ib_loc_csr;

      --BUG# 3569441
      IF NVL(l_location_type_code,OKL_API.G_MISS_CHAR)  NOT IN ('HZ_LOCATIONS','HZ_PARTY_SITES') THEN
          --RAISE ERROR
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_INSTALL_LOC_TYPE,
                              p_token1       => G_LOCATION_TYPE_TOKEN,
                              p_token1_value => l_location_type_code,
                              p_token2       => G_LOC_TYPE1_TOKEN,
                              p_token2_value => 'HZ_PARTY_SITES',
                              p_token3       => G_LOC_TYPE2_TOKEN,
                              p_token3_value => 'HZ_LOCATIONS');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;

      ELSIF NVL(l_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_PARTY_SITES' THEN

          --get site use id
          OPEN inst_site_csr(pty_site_id => l_install_location_id);
          FETCH inst_site_csr INTO l_party_site_use_id;
          IF inst_site_csr%NOTFOUND THEN
             OPEN l_address_csr(pty_site_id => l_install_location_id);
             FETCH l_address_csr INTO l_address;
             CLOSE l_address_csr;
             --Raise Error : not defined as install_at
             OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => l_instance_number_csi);
              x_return_status := OKL_API.G_RET_STS_ERROR;
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          CLOSE inst_site_csr;

      ELSIF NVL(l_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_LOCATIONS' THEN

         --get site use id
          OPEN inst_loc_csr(loc_id => l_install_location_id);
          FETCH inst_loc_csr INTO l_party_site_use_id;
          IF inst_loc_csr%NOTFOUND THEN
             OPEN l_address_csr2(loc_id => l_install_location_id);
             FETCH l_address_csr2 INTO l_address;
             CLOSE l_address_csr2;
             --Raise Error : not defined as install_at
             OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => l_instance_number_csi);
              x_return_status := OKL_API.G_RET_STS_ERROR;
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          CLOSE inst_loc_csr;
      END IF;
      --End BUG# 3569441

      j := 1;
      FOR i IN 1..l_itiv_tbl.LAST LOOP
          IF l_itiv_tbl(i).id IS NULL OR l_itiv_tbl(i).id = OKL_API.G_MISS_NUM THEN

             l_itiv_rec := l_itiv_tbl(i);
             --l_itiv_rec.kle_id := l_ib_cle_id;
             l_itiv_rec.kle_id := l_fa_cle_id;
             l_itiv_rec.tal_type := 'ALI';
             l_itiv_rec.tas_id   := l_tas_id;
             l_itiv_rec.line_number := i;
             l_itiv_rec.object_id1_new := l_party_site_use_id;
             l_itiv_rec.object_id2_new := '#';
             l_itiv_rec.jtot_object_code_new := 'OKX_PARTSITE';
             l_itiv_rec.object_id1_old := l_party_site_use_id;
             l_itiv_rec.object_id2_old := '#';
             l_itiv_rec.jtot_object_code_old := 'OKX_PARTSITE';
             l_itiv_rec.inventory_org_id := l_inv_org_id;
             l_itiv_rec.mfg_serial_number_yn := 'N';
             l_itiv_rec.inventory_item_id    := l_inv_item_id;
             l_itiv_rec.inv_master_org_id := l_mast_org_id;
             l_itiv_rec.selected_for_split_flag := 'Y';


             Validate_Serial_Number(x_return_status => x_return_status,
                                    p_serial_number => l_itiv_rec.serial_number);
             IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             x_return_status := generate_instance_number_ib(x_instance_number_ib => l_instance_number);
             IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             l_itiv_rec.instance_number_ib := l_instance_number;
             --create record
             okl_txl_itm_insts_pub.create_txl_itm_insts
                                    (p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_iipv_rec      => l_itiv_rec,
                                     x_iipv_rec      => lx_itiv_rec);
             IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             j:= j+1;
             x_itiv_tbl(j) := lx_itiv_rec;
          END IF;
     END LOOP;
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
END create_split_comp_srl_num;
--Bug#3222804 - serial number control based on setup in leasing inv org
--------------------------------------------------------------------------------
--Start of Comments
--API Name    : validate_srl_num_control
--Description : Local API to validate whether serial # control code is in sync with
--              existing serial numbers in Install Base.
--History     : 20-Nov-2003   avsingh  Creation
--End of comments
--------------------------------------------------------------------------------
PROCEDURE validate_srl_num_control(p_api_version               IN  NUMBER,
                                   p_init_msg_list             IN  VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2,
                                   x_msg_count                 OUT NOCOPY NUMBER,
                                   x_msg_data                  OUT NOCOPY VARCHAR2,
                                   p_cle_id                    IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units          IN NUMBER,
                                   p_tal_id                    IN NUMBER) IS

  l_api_name   VARCHAR2(30) := 'VALIDATE_SRL_NUM_CONTROL';
  l_api_version CONSTANT NUMBER := 1.0;

l_serialized        VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

--cursor for asset_number
CURSOR asset_num_csr (P_fin_ast_id IN NUMBER) IS
SELECT name
FROM   okc_k_lines_tl
WHERE  id = p_fin_ast_id;

l_asset_number OKC_K_LINES_TL.NAME%TYPE;

--Bug# 3222804 : serial # control based on leasing inv org setup
--cursor to find serialized item instances in installed base
CURSOR l_srl_no_count_csr(fin_ast_id IN NUMBER) IS
SELECT
       COUNT(1)
FROM   csi_item_instances  csi,
       okc_k_items         ib_cim,
       okc_k_lines_b       ib_cle,
       okc_line_styles_b   ib_lse,
       okc_k_lines_b       inst_cle,
       okc_line_styles_b   inst_lse,
       okc_statuses_b      inst_sts
WHERE  csi.instance_id    = TO_NUMBER(ib_cim.object1_id1)
AND    ib_cim.cle_id      = ib_cle.id
AND    ib_cim.dnz_chr_id  = ib_cle.dnz_chr_id
AND    ib_cle.cle_id      = inst_cle.id
AND    ib_cle.dnz_chr_id  = inst_cle.dnz_chr_id
AND    ib_cle.lse_id      = ib_lse.id
AND    ib_lse.lty_code    = 'INST_ITEM'
AND    inst_cle.cle_id    = fin_ast_id
AND    inst_cle.lse_id    = inst_lse.id
AND    inst_lse.lty_code  = 'FREE_FORM2'
AND    inst_sts.code      = inst_cle.sts_code
--Bug# 5946411: ER
--AND    INST_STS.STE_CODE NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED');
AND    INST_STS.STE_CODE NOT IN ('HOLD', 'CANCELLED');
--Bug# 5946411: ER end

l_srl_no_count NUMBER DEFAULT 0;

--cursor to get txl quantity
CURSOR l_txlqty_csr (p_tal_id IN NUMBER) IS
SELECT txl.current_units
FROM   okl_txl_assets_b txl
WHERE  id   = p_tal_id;

l_txlqty NUMBER DEFAULT NULL;

BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

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

    IF (NVL(p_split_into_individuals_yn,'N') = 'Y')
       OR
       (NVL(p_split_into_individuals_yn,'N') = 'N' AND NVL(p_split_into_units,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM) THEN
       --check if serialization has been done properly
       l_txlqty := NULL;
       OPEN l_txlqty_csr(p_tal_id => p_tal_id);
       FETCH l_txlqty_csr INTO l_txlqty;
       IF l_txlqty_csr%NOTFOUND THEN
           NULL;
       END IF;
       CLOSE l_txlqty_csr;
       IF NVL(l_txlqty,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN

        l_serialized := Is_Serialized(p_cle_id => p_cle_id);
        IF (l_serialized = OKL_API.G_TRUE) THEN
            --fetch total instances to find if qantity matches

            l_srl_no_count := 0;
            OPEN l_srl_no_count_csr( fin_ast_id => p_cle_id);
            FETCH l_srl_no_count_csr INTO l_srl_no_count;
            IF l_srl_no_count_csr%NOTFOUND THEN
                NULL;
            END IF;
            CLOSE l_srl_no_count_csr;

            IF l_srl_no_count = 1 AND l_txlqty  <> 1 THEN

                l_asset_number := NULL;
                OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                FETCH asset_num_csr INTO l_asset_number;
                IF asset_num_csr%NOTFOUND THEN
                    NULL;
                END IF;
                CLOSE asset_num_csr;

                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_NOT_SERIALIZED_IN_IB,
                                    p_token1       => G_ASSET_NUMBER_TOKEN,
                                    p_token1_value => l_Asset_number
                                    );
                --raise error
                RAISE OKL_API.G_EXCEPTION_ERROR;

            ELSIF l_srl_no_count <> l_txlqty THEN

                l_asset_number := NULL;
                OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                FETCH asset_num_csr INTO l_asset_number;
                IF asset_num_csr%NOTFOUND THEN
                    NULL;
                END IF;
                CLOSE asset_num_csr;


                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_SERIAL_NUMBER_MISMATCH,
                                    p_token1       => G_ASSET_NUMBER_TOKEN,
                                    p_token1_value => l_Asset_number
                                    );
                --raise error
                RAISE OKL_API.G_EXCEPTION_ERROR;

            ELSIF l_srl_no_count =  l_txlqty THEN
                --data in installed base is correct
                NULL;
            END IF;

        ELSIF l_serialized = OKL_API.G_FALSE THEN
            --fetch total instances to find if qantity matches

            l_srl_no_count := 0;
            OPEN l_srl_no_count_csr( fin_ast_id => p_cle_id);
            FETCH l_srl_no_count_csr INTO l_srl_no_count;
            IF l_srl_no_count_csr%NOTFOUND THEN
                NULL;
            END IF;
            CLOSE l_srl_no_count_csr;

            IF l_srl_no_count <> 1 AND l_srl_no_count = l_txlqty THEN
                --error asset is serilized in Installed Base
                l_asset_number := NULL;
                OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                FETCH asset_num_csr INTO l_asset_number;
                IF asset_num_csr%NOTFOUND THEN
                    NULL;
                END IF;
                CLOSE asset_num_csr;

                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_SERIALIZED_IN_IB,
                                    p_token1       => G_ASSET_NUMBER_TOKEN,
                                    p_token1_value => l_Asset_number
                                    );
                --raise error
                RAISE OKL_API.G_EXCEPTION_ERROR;

            ELSIF l_srl_no_count <> 1 AND l_srl_no_count <> l_txlqty THEN
                --error in installed base data
                l_asset_number := NULL;
                OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                FETCH asset_num_csr INTO l_asset_number;
                IF asset_num_csr%NOTFOUND THEN
                    NULL;
                END IF;

               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_SERIAL_NUMBER_MISMATCH,
                                    p_token1       => G_ASSET_NUMBER_TOKEN,
                                    p_token1_value => l_Asset_number
                                    );
                --raise error
                RAISE OKL_API.G_EXCEPTION_ERROR;

            ELSIF l_srl_no_count = 1 THEN
                --data in installed base is correct
                NULL;
            END IF;
        END IF;
    END IF;

    ELSIF NVL(p_split_into_individuals_yn,'N') = 'X' THEN
       NULL; -- user will have to create new serail numbers
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
END  validate_srl_num_control;
--End Bug# 3222804 : serial number control setup in Leasing Inv Org
--------------------------------------------------------------------------------
--Start of Comments
--Bug #2723498 : 11.5.9 enhancement for splitting assets by serial number
--API Name    : create_srl_num_trx
--Description : Local API will create serial_number records in OKL_TXL_ITM_INSTS_V
--              If financial asset inventory item is serialized
--History     : 03-Nov-2002   avsingh  Creation (for asset split by serial numbers)
--End of comments
--------------------------------------------------------------------------------
PROCEDURE create_srl_num_trx(p_api_version               IN  NUMBER,
                             p_init_msg_list             IN  VARCHAR2,
                             x_return_status             OUT NOCOPY VARCHAR2,
                             x_msg_count                 OUT NOCOPY NUMBER,
                             x_msg_data                  OUT NOCOPY VARCHAR2,
                             p_cle_id                    IN  NUMBER,
                             p_split_into_individuals_yn IN VARCHAR2,
                             p_split_into_units          IN NUMBER,
                             p_ib_tbl                    IN ib_tbl_type,
                             p_tas_id                    IN NUMBER,
                             p_tal_id                    IN NUMBER,
                             p_asd_id                    IN NUMBER) IS

l_api_name   VARCHAR2(30) := 'CREATE_SRL_NUM_TRX';
l_api_version CONSTANT NUMBER := 1.0;


--Cursor to get all the serial numbers
CURSOR srl_num_csr(fin_ast_id IN NUMBER) IS
SELECT ib_cle.id  ib_cle_id,
       csi.instance_id,
       csi.serial_number,
       csi.instance_number,
       csi.inv_organization_id,
       csi.inventory_item_id,
       csi.inv_master_organization_id,
       csi.unit_of_measure,
       csi.quantity,
       csi.instance_status_id,
       csi.location_id,  --hz_locations
       csi.install_location_id,
       --BUG# 3569441
       csi.install_location_type_code   --hz_party_sites OR hz_loactions
FROM   csi_item_instances  csi,
       okc_k_items         ib_cim,
       okc_k_lines_b       ib_cle,
       okc_line_styles_b   ib_lse,
       okc_k_lines_b       inst_cle,
       okc_line_styles_b   inst_lse,
       okc_statuses_b      inst_sts
WHERE  csi.instance_id    = TO_NUMBER(ib_cim.object1_id1)
AND    ib_cim.cle_id      = ib_cle.id
AND    ib_cim.dnz_chr_id  = ib_cle.dnz_chr_id
AND    ib_cle.cle_id      = inst_cle.id
AND    ib_cle.dnz_chr_id  = inst_cle.dnz_chr_id
AND    ib_cle.lse_id      = ib_lse.id
AND    ib_lse.lty_code    = 'INST_ITEM'
AND    inst_cle.cle_id    = fin_ast_id
AND    inst_cle.lse_id    = inst_lse.id
AND    inst_lse.lty_code  = 'FREE_FORM2'
AND    inst_sts.code      = inst_cle.sts_code
--Bug# 5946411: ER
--AND    INST_STS.STE_CODE NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED');
AND    INST_STS.STE_CODE NOT IN ('HOLD', 'CANCELLED');
--Bug# 5946411: ER--end


srl_num_rec  srl_num_csr%ROWTYPE;

-- Cursor to get all the serial numbers if ib line id table is passed as input
-- This will be done by asset managment during asset level termination
CURSOR srl_num_csr2(fin_ast_id IN NUMBER, p_ib_cle_id IN VARCHAR2) IS
SELECT ib_cle.id  ib_cle_id,
       csi.instance_id,
       csi.serial_number,
       csi.instance_number,
       csi.inv_organization_id,
       csi.inventory_item_id,
       csi.inv_master_organization_id,
       csi.unit_of_measure,
       csi.quantity,
       csi.instance_status_id,
       csi.location_id,  --hz_locations
       csi.install_location_id,
       --BUG# 3569441
       csi.install_location_type_code   --hz_party_sites OR hz_locations
FROM   csi_item_instances  csi,
       okc_k_items         ib_cim,
       okc_k_lines_b       ib_cle,
       okc_line_styles_b   ib_lse,
       okc_k_lines_b       inst_cle,
       okc_line_styles_b   inst_lse,
       okc_statuses_b      inst_sts
WHERE  csi.instance_id    = TO_NUMBER(ib_cim.object1_id1)
AND    ib_cim.cle_id      = ib_cle.id
AND    ib_cim.dnz_chr_id  = ib_cle.dnz_chr_id
AND    ib_cle.cle_id      = inst_cle.id
AND    ib_cle.dnz_chr_id  = inst_cle.dnz_chr_id
AND    ib_cle.lse_id      = ib_lse.id
AND    ib_cle.id          = p_ib_cle_id
AND    ib_lse.lty_code    = 'INST_ITEM'
AND    inst_cle.cle_id    = fin_ast_id
AND    inst_cle.lse_id    = inst_lse.id
AND    inst_lse.lty_code  = 'FREE_FORM2'
AND    inst_sts.code      = inst_cle.sts_code
--Bug# 5946411: ER
--AND    INST_STS.STE_CODE NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED');
AND    INST_STS.STE_CODE NOT IN ('HOLD', 'CANCELLED');
--Bug# 5946411: ER -- End

srl_num_rec2  srl_num_csr2%ROWTYPE;

l_iipv_tbl   okl_txl_itm_insts_pub.iipv_tbl_type;
i            NUMBER DEFAULT 0;
lx_iipv_tbl  okl_txl_itm_insts_pub.iipv_tbl_type;

--Cursor to get install site use id
CURSOR inst_site_csr (pty_site_id IN NUMBER) IS
SELECT TO_CHAR(Party_site_use_id) party_site_use_id
FROM   hz_party_site_uses
WHERE  party_site_id = pty_site_id
AND    site_use_type = 'INSTALL_AT';

  --BUG# 3569441
  CURSOR inst_loc_csr (loc_id IN NUMBER) IS
  SELECT TO_CHAR(psu.party_site_use_id) party_site_use_id
  FROM  hz_party_site_uses psu,
        hz_party_sites     ps
  WHERE psu.party_site_id   = ps.party_site_id
  AND   psu.site_use_type   = 'INSTALL_AT'
  AND   ps.location_id      = loc_id;

  CURSOR l_address_csr (pty_site_id IN NUMBER ) IS
  SELECT SUBSTR(arp_addr_label_pkg.format_address(NULL,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,NULL,hl.country,NULL, NULL,NULL,NULL,NULL,NULL,NULL,'n','n',80,1,1),1,80)
  FROM hz_locations hl,
       hz_party_sites ps
  WHERE hl.location_id = ps.location_id
  AND   ps.party_site_id = pty_site_id;

  CURSOR l_address_csr2 (loc_id IN NUMBER) IS
  SELECT SUBSTR(arp_addr_label_pkg.format_address(NULL,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,NULL,hl.country,NULL, NULL,NULL,NULL,NULL,NULL,NULL,'n','n',80,1,1),1,80)
  FROM hz_locations hl
  WHERE hl.location_id = loc_id;

  l_address VARCHAR2(80);
  --END BUG# 3569441

l_pty_site_use_id   okl_txl_itm_insts.object_id1_new%TYPE;
l_error_condition   EXCEPTION;

l_ib_tbl            ib_tbl_type;
l_serialized        VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

--cursor for asset_number
CURSOR asset_num_csr (P_fin_ast_id IN NUMBER) IS
SELECT name
FROM   okc_k_lines_tl
WHERE  id = p_fin_ast_id;

l_asset_number OKC_K_LINES_TL.NAME%TYPE;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

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

    --Bug# 3222804 : Serial number control to be based on leasing inv org setup
    validate_srl_num_control(
                   p_api_version               => p_api_version,
                   p_init_msg_list             => p_init_msg_list,
                   x_return_status             => x_return_status,
                   x_msg_count                 => x_msg_count,
                   x_msg_data                  => x_msg_data,
                   p_cle_id                    => p_cle_id,
                   p_split_into_individuals_yn => p_split_into_individuals_yn,
                   p_split_into_units          => p_split_into_units,
                   p_tal_id                    => p_tal_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 3222804 : Serial number control to be based on leasing inv org setup

    l_ib_tbl       := p_ib_tbl;
    IF NVL(p_split_into_individuals_yn,'N') = 'Y' THEN
       NULL; --no need to create srl num transactions
    ELSIF NVL(p_split_into_individuals_yn,'N') = 'X' THEN
       NULL; -- user will have to create new serail numbers
    ELSIF NVL(p_split_into_individuals_yn,'N') = 'N' AND NVL(p_split_into_units,0) > 0  THEN
       --user needs to select serial numbers to split
       l_serialized := is_serialized(p_cle_id => p_cle_id);
       IF (l_serialized = OKL_API.G_TRUE) THEN
          -- asset inventory item is serial number controlled
          IF l_ib_tbl.COUNT <> 0 THEN
             FOR i IN 1..l_ib_tbl.LAST
             LOOP
                 OPEN srl_num_csr2(fin_Ast_id => p_cle_id, p_ib_cle_id => l_ib_tbl(i).id);
                 FETCH srl_num_csr2 INTO srl_num_rec2;
                 IF srl_num_csr2%NOTFOUND THEN
                    --Serial number does not belong to asset. Please select correct serial number to split.
                    l_asset_number := NULL;
                    OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                    FETCH asset_num_csr INTO l_asset_number;
                    IF asset_num_csr%NOTFOUND THEN
                        NULL;
                    END IF;
                    CLOSE asset_num_csr;

                    OKL_API.set_message(p_app_name     => G_APP_NAME,
                                        p_msg_name     => G_IB_INSTANCE_MISMATCH,
                                        p_token1       => G_ASSET_NUMBER_TOKEN,
                                        p_token1_value => l_Asset_number,
                                        p_token2       => G_IB_LINE_TOKEN,
                                        p_token2_value => TO_CHAR(l_ib_tbl(i).id));
                    --raise error
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
                 l_iipv_tbl(i).tas_id             := p_tas_id;
                 l_iipv_tbl(i).tal_id             := p_tal_id;
                 l_iipv_tbl(i).kle_id             := srl_num_rec2.ib_cle_id;
                 l_iipv_tbl(i).tal_type           := 'ALI'; -- hardcoded for split asset
                 l_iipv_tbl(i).line_number        := i;
                 l_iipv_tbl(i).instance_number_ib := srl_num_rec2.instance_number;

                 --fetch party site use id
                 l_pty_site_use_id := NULL;
                 --BUG# 3569441 :
                 IF NVL(srl_num_rec2.install_location_type_code,OKL_API.G_MISS_CHAR) NOT IN ('HZ_LOCATIONS','HZ_PARTY_SITES') THEN

                     --Raise Error
                     OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_INSTALL_LOC_TYPE,
                                  p_token1       => G_LOCATION_TYPE_TOKEN,
                                  p_token1_value => srl_num_rec2.install_location_type_code,
                                  p_token2       => G_LOC_TYPE1_TOKEN,
                                  p_token2_value => 'HZ_PARTY_SITES',
                                  p_token3       => G_LOC_TYPE2_TOKEN,
                                  p_token3_value => 'HZ_LOCATIONS');
                      x_return_status := OKL_API.G_RET_STS_ERROR;
                      RAISE OKL_API.G_EXCEPTION_ERROR;

                 ELSIF NVL(srl_num_rec2.install_location_type_code,OKL_API.G_MISS_CHAR)  = 'HZ_PARTY_SITES' THEN

                     OPEN inst_site_csr(srl_num_rec2.install_location_id);
                     FETCH inst_site_csr INTO l_pty_site_use_id;
                     IF inst_site_csr%NOTFOUND THEN
                         OPEN l_address_csr(pty_site_id => srl_num_rec2.install_location_id);
                         FETCH l_address_csr INTO l_address;
                         CLOSE l_address_csr;
                         --Raise Error : not defined as install_at
                         OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => srl_num_rec2.instance_number);
                          x_return_status := OKL_API.G_RET_STS_ERROR;
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                         --l_pty_site_use_id := '-1';
                     END IF;
                     CLOSE inst_site_csr;

                 ELSIF NVL(srl_num_rec2.install_location_type_code, OKL_API.G_MISS_CHAR) = 'HZ_LOCATIONS' THEN

                     OPEN inst_loc_csr(srl_num_rec2.install_location_id);
                     FETCH inst_loc_csr INTO l_pty_site_use_id;
                     IF inst_loc_csr%NOTFOUND THEN
                         --l_pty_site_use_id := '-1';
                         OPEN l_address_csr2(loc_id => srl_num_rec2.install_location_id);
                         FETCH l_address_csr2 INTO l_address;
                         CLOSE l_address_csr2;
                         --Raise Error : not defined as install_at
                         OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                                  p_msg_name     => G_MISSING_USAGE,
                                  p_token1       => G_USAGE_TYPE_TOKEN,
                                  p_token1_value => 'INSTALL_AT',
                                  p_token2       => G_ADDRESS_TOKEN,
                                  p_token2_value => l_address,
                                  p_token3       => G_INSTANCE_NUMBER_TOKEN,
                                  p_token3_value => srl_num_rec2.instance_number);
                         x_return_status := OKL_API.G_RET_STS_ERROR;
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;
                     CLOSE inst_loc_csr;

                 END IF;
                 --End Bug # 3569441

                 l_iipv_tbl(i).object_id1_new         := l_pty_site_use_id;
                 l_iipv_tbl(i).object_id2_new         := '#';
                 l_iipv_tbl(i).jtot_object_code_new    := 'OKX_PARTSITE';
                 l_iipv_tbl(i).object_id1_old         := l_pty_site_use_id;
                 l_iipv_tbl(i).object_id2_old         := '#';
                 l_iipv_tbl(i).jtot_object_code_old    := 'OKX_PARTSITE';
                 l_iipv_tbl(i).inventory_org_id        := srl_num_rec2.inv_organization_id;
                 l_iipv_tbl(i).serial_number           := srl_num_rec2.serial_number;
                 l_iipv_tbl(i).mfg_serial_number_yn    := 'N';
                 l_iipv_tbl(i).inventory_item_id       := srl_num_rec2.inventory_item_id;
                 l_iipv_tbl(i).INV_MASTER_ORG_ID       := srl_num_rec2.inv_master_organization_id;
                 l_iipv_tbl(i).dnz_cle_id              := p_cle_id;
                 l_iipv_tbl(i).instance_id             := srl_num_rec2.instance_id;
                 l_iipv_tbl(i).selected_for_split_flag := 'Y';
                 l_iipv_tbl(i).asd_id                  := p_asd_id;
                --Bug fix # 2753141
                CLOSE srl_num_csr2;
              END LOOP;
          ELSE --srl_tbl count is zero
              --get all the serial numbers
              i := 0;
              OPEN srl_num_csr (fin_Ast_id => p_cle_id);
              LOOP
                  FETCH srl_num_csr INTO srl_num_rec;
                  EXIT WHEN  srl_num_csr%NOTFOUND;
                  i := i + 1;
                  l_iipv_tbl(i).tas_id             := p_tas_id;
                  l_iipv_tbl(i).tal_id             := p_tal_id;
                  l_iipv_tbl(i).kle_id             := srl_num_rec.ib_cle_id;
                  l_iipv_tbl(i).tal_type           := 'ALI'; -- hardcoded for split asset
                  l_iipv_tbl(i).line_number        := i;
                  l_iipv_tbl(i).instance_number_ib := srl_num_rec.instance_number;

                  --fetch party site use id
                  l_pty_site_use_id := NULL;
                  --BUG# 3569441
                  IF NVL(srl_num_rec.install_location_type_code,OKL_API.G_MISS_CHAR) NOT IN ('HZ_LOCATIONS','HZ_PARTY_SITES') THEN

                      --Raise Error
                      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_INSTALL_LOC_TYPE,
                                  p_token1       => G_LOCATION_TYPE_TOKEN,
                                  p_token1_value => srl_num_rec.install_location_type_code,
                                  p_token2       => G_LOC_TYPE1_TOKEN,
                                  p_token2_value => 'HZ_PARTY_SITES',
                                  p_token3       => G_LOC_TYPE2_TOKEN,
                                  p_token3_value => 'HZ_LOCATIONS');
                      x_return_status := OKL_API.G_RET_STS_ERROR;
                      RAISE OKL_API.G_EXCEPTION_ERROR;

                  ELSIF NVL(srl_num_rec.install_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_PARTY_SITES' THEN

                      OPEN inst_site_csr(srl_num_rec.install_location_id);
                      FETCH inst_site_csr INTO l_pty_site_use_id;
                      IF inst_site_csr%NOTFOUND THEN
                          OPEN l_address_csr(pty_site_id => srl_num_rec2.install_location_id);
                          FETCH l_address_csr INTO l_address;
                          CLOSE l_address_csr;
                          --Raise Error : not defined as install_at
                          OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => srl_num_rec.instance_number);
                          x_return_status := OKL_API.G_RET_STS_ERROR;
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      CLOSE inst_site_csr;
                  ELSIF NVL(srl_num_rec.install_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_LOCATIONS' THEN

                      OPEN inst_loc_csr(srl_num_rec.install_location_id);
                      FETCH inst_loc_csr INTO l_pty_site_use_id;
                      IF inst_loc_csr%NOTFOUND THEN
                          OPEN l_address_csr2(loc_id => srl_num_rec2.install_location_id);
                          FETCH l_address_csr2 INTO l_address;
                          CLOSE l_address_csr2;
                          --Raise Error : not defined as install_at
                          OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => srl_num_rec.instance_number);
                          x_return_status := OKL_API.G_RET_STS_ERROR;
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                      CLOSE inst_loc_csr;

                  END IF;
                  --BUG# 3569441


                  l_iipv_tbl(i).object_id1_new         := l_pty_site_use_id;
                  l_iipv_tbl(i).object_id2_new         := '#';
                  l_iipv_tbl(i).jtot_object_code_new    := 'OKX_PARTSITE';
                  l_iipv_tbl(i).object_id1_old         := l_pty_site_use_id;
                  l_iipv_tbl(i).object_id2_old         := '#';
                  l_iipv_tbl(i).jtot_object_code_old    := 'OKX_PARTSITE';
                  l_iipv_tbl(i).inventory_org_id        := srl_num_rec.inv_organization_id;
                  l_iipv_tbl(i).serial_number           := srl_num_rec.serial_number;
                  l_iipv_tbl(i).mfg_serial_number_yn    := 'N';
                  l_iipv_tbl(i).inventory_item_id       := srl_num_rec.inventory_item_id;
                  l_iipv_tbl(i).INV_MASTER_ORG_ID       := srl_num_rec.inv_master_organization_id;
                  l_iipv_tbl(i).dnz_cle_id              := p_cle_id;
                  l_iipv_tbl(i).instance_id             := srl_num_rec.instance_id;
                  l_iipv_tbl(i).selected_for_split_flag := 'N';
                  l_iipv_tbl(i).asd_id                  := p_asd_id;

              END LOOP;
              CLOSE srl_num_csr;
          END IF; --srl_tbl count is = 0
          IF l_iipv_tbl.COUNT  > 0 THEN
              --call api to create records for srl num trx
              okl_txl_itm_insts_pub.create_txl_itm_insts(
                   p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_iipv_tbl       => l_iipv_tbl,
                   x_iipv_tbl       => lx_iipv_tbl);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

          END IF;
       --Bug# 3222804 : serial # control based on leasing inv org setup
       ELSIF l_serialized = OKL_API.G_FALSE THEN
           NULL;
       END IF; -- if srl number controlled
   END IF;
   l_iipv_tbl.DELETE;
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
END  create_srl_num_trx;
--Bug #2723498 : 11.5.9 Split by serial numbers enhancement
FUNCTION Check_If_Loan(p_cle_id IN NUMBER,
                       x_return_status OUT nocopy VARCHAR2) RETURN VARCHAR2 IS
--cursor to get deal type
CURSOR l_dealtyp_csr(PCleId IN NUMBER) IS
SELECT khr.deal_type
FROM   okl_k_headers khr,
       okc_k_headers_b chrb,
       okc_k_lines_b   cleb
WHERE  khr.id = chrb.id
AND    chrb.id = cleb.dnz_chr_id
AND    cleb.id = PCleId;

l_deal_type okl_k_headers.deal_type%TYPE;
l_loan_yn   VARCHAR2(1) DEFAULT 'N';

BEGIN
----
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN l_dealtyp_csr (PCleId => p_cle_id);
    FETCH l_dealtyp_csr INTO l_deal_type;
    IF l_dealtyp_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE l_dealtyp_csr;

    IF NVL(l_deal_type,'X') IN ('LOAN','LOAN-REVOLVING') THEN
        l_loan_yn := 'Y';
    ELSE
        l_loan_yn := 'N';
    END IF;

    RETURN(l_loan_yn);
    EXCEPTION
    WHEN OTHERS THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
----
END Check_If_Loan;

--------------------------------------------------------------------------------
--Start of Comments
--API Name    : Create_Split_Transaction
--Description : Process API to create Split Aseet Transaction Records in
--              OKL_TXL_ASSETS_V and OKL_TXD_ASSETS_V
--              1. Take the line details to be split
--              2. Set the status of the contract as inactive
--              3. Create and save source record into okl_trx_assets_v
--              4. Create and save target record into okl_txd_assets_v
--History     :
--              10-OCT-2001    avsingh  Creation
--              12-Dec-2002    avsingh  Overloaded the procedure to take p_srl_tbl
--                                      as IN parameter. This will be directly called
--                                      by Asset management line level termination
--                                      Process. The old call is kept for backward
--                                      compatability. It will be still used from
--                                      the split asset UI.
--              30-Jan-2004    avsingh  Bug# 3156924
--                                      Overloaded the procedure to accept
--                                      trx_date
--              16-Aug-2005    smadhava Bug# 4542290 Variable Rate Enhancement
--End of Comments
------------------------------------------------------------------------------
PROCEDURE Create_Split_Transaction(p_api_version               IN  NUMBER,
                                   p_init_msg_list             IN  VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2,
                                   x_msg_count                 OUT NOCOPY NUMBER,
                                   x_msg_data                  OUT NOCOPY VARCHAR2,
                                   p_cle_id                    IN  NUMBER,
                                   p_split_into_individuals_yn IN  VARCHAR2,
                                   p_split_into_units          IN  NUMBER,
                                   p_ib_tbl                    IN  ib_tbl_type,
                                   --Bug# 3156924
                                   p_trx_date                  IN  DATE,
                                   --bug# 3156924
                                   x_txdv_tbl                  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec                  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec                  OUT NOCOPY trxv_rec_type) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_SPLIT_TRANSACTION';
l_api_version          CONSTANT NUMBER := 1.0;

--cursor to check presence of an already active transaction
CURSOR chk_split_trx(p_cle_id IN NUMBER) IS
SELECT txl.id,             --tal_id
       txl.SPLIT_INTO_SINGLES_FLAG,  --p_split_into_individuals_yn
       txl.SPLIT_INTO_UNITS,  --p_split_into_units
       --Bug# 3156924
       tas.DATE_TRANS_OCCURRED,
       tas.ID
FROM   OKL_TXL_ASSETS_B txl,
       OKL_TRX_ASSETS   tas
WHERE  txl.kle_id = p_cle_id
AND    txl.tas_id = tas.id
AND    txl.tal_type = 'ALI'
AND    tas.tas_type = 'ALI'
AND    tas.tsu_code = 'ENTERED'
AND    EXISTS (SELECT NULL
                   FROM
                          okl_trx_types_tl ttyp
                   WHERE  tas.try_id    = ttyp.id
                   AND    ttyp.name     = 'Split Asset'
                   AND    ttyp.LANGUAGE = 'US');

--for split asset components
--cursor to check whether split asset comonent

l_split_into_ind_yn    VARCHAR2(1) DEFAULT 'Z';
l_split_units          NUMBER DEFAULT 0;
l_tal_id               NUMBER;
--Bug# 3156924
l_trx_date             okl_trx_assets.DATE_TRANS_OCCURRED%TYPE;
l_tas_id               okl_trx_assets.ID%TYPE;


l_trxv_rec             trxv_rec_type;
l_txlv_rec             txlv_rec_type;
l_txdv_rec             txdv_rec_type;
l_txdv_rec_out         txdv_rec_type;
l_txdv_tbl             txdv_tbl_type;
l_ast_line_rec         ast_line_rec_type;
l_fa_location_id       NUMBER;
l_row_not_found        BOOLEAN := TRUE;
l_total_cost           NUMBER;
l_total_salvage_value  NUMBER;
l_units_on_child_line  NUMBER;
l_total_quantity       NUMBER;
l_split_into_units     NUMBER;
l_asset_exists         VARCHAR2(1) DEFAULT 'N';
j                      NUMBER      DEFAULT 0; --counter for generating split asset numbers
l_no_txd_data_found    BOOLEAN DEFAULT TRUE;

--Bug #2723498 11.5.9 enhancement - Splitting assets by serial numbers
--check if serial number data exists
--cursor to check whether srl number data exists
CURSOR srl_exist_chk (p_tal_id IN NUMBER) IS
SELECT '!'
FROM   dual
WHERE  EXISTS
(SELECT 1
FROM   okl_txl_itm_insts
WHERE  tal_id = p_tal_id
AND    tal_type = 'ALI');

l_srl_exists VARCHAR2(1) DEFAULT '?';

--Bug #2723498 11.5.9 enhancement - Splitting assets by serial numbers
--cursor to fetch all the serail numbers
CURSOR get_srl_csr (p_tal_id IN NUMBER) IS
SELECT id
FROM   okl_txl_itm_insts
WHERE  tal_id = p_tal_id
AND    tal_type = 'ALI';

l_iipv_tbl   okl_txl_itm_insts_pub.iipv_tbl_type;
l_iipv_count NUMBER;
l_iipv_id    NUMBER;

l_ib_tbl    ib_tbl_type;

--Bug #2723498 11.5.9 - Multi Currency
CURSOR curr_conv_csr (PCleId IN NUMBER) IS
SELECT khrv.currency_code,
       khrv.currency_conversion_type,
       khrv.currency_conversion_rate,
       khrv.currency_conversion_date,
       khrv.start_date
FROM   okl_k_headers_full_v khrv,
       okc_k_lines_b        cle
WHERE  khrv.id         = cle.dnz_chr_id
AND    cle.id  = PCleId;

curr_conv_rec curr_conv_csr%ROWTYPE;


--Bug# 2798006 : split asset for loan contracts
CURSOR loan_ast_csr (PCleId IN NUMBER) IS
SELECT
        cle_fa.id               kle_id,
        clet.name               NAME,
        clet.item_description   DESCRIPTION,
        cle.chr_id              CHR_ID,
        cle.dnz_chr_id          DNZ_CHR_ID,
        cle.id                  PARENT_LINE_ID,
        cle.start_date          START_DATE_ACTIVE,
        cle.end_date            END_DATE_ACTIVE,
        cim_fa.number_of_items  CURRENT_UNITS,
        clet.name               ASSET_NUMBER,
        kle.OEC                 ORIGINAL_COST,
        kle.OEC                 COST,
        cle.sts_code            LINE_STATUS
FROM    okc_k_items           cim_fa,
        okc_k_lines_b         cle_fa,
        okc_line_styles_b     lse_fa,
        okl_k_lines           kle,
        okc_k_lines_tl        clet,
        okc_k_lines_b         cle
WHERE   cim_fa.cle_id     = cle_fa.id
AND     cle_fa.cle_id     = cle.id
AND     cle_fa.dnz_chr_id = cle.dnz_chr_id
AND     cle_fa.lse_id     = lse_fa.id
AND     lse_fa.lty_code   = 'FIXED_ASSET'
AND     kle.id            = cle.id
AND     clet.id           = cle.id
AND     clet.LANGUAGE     = USERENV('LANG')
AND     cle.id            = PCleId;

l_loan_ast_rec loan_ast_csr%ROWTYPE;
l_loan_yn      VARCHAR2(1) DEFAULT 'N';
l_fa_exists    VARCHAR2(1) DEFAULT 'N';

--Bug Fix # 2881114
--Cursor to check whether asset is linked to service contract
CURSOR lnk_to_srv_csr(p_cle_id IN NUMBER) IS
SELECT '!'
FROM   dual
WHERE  EXISTS
       (
        SELECT '1'
        FROM
               okc_k_headers_b   oks_chrb,
               okc_line_styles_b oks_cov_pd_lse,
               okc_k_lines_b     oks_cov_pd_cleb,
               okc_k_rel_objs    krel,
               okc_line_styles_b lnk_srv_lse,
               okc_statuses_b    lnk_srv_sts,
               okc_k_lines_b     lnk_srv_cleb,
               okc_k_items       lnk_srv_cim
        WHERE  oks_chrb.scs_code            = 'SERVICE'
        AND    oks_chrb.id                  = oks_cov_pd_cleb.dnz_chr_id
        AND    oks_cov_pd_cleb.lse_id       = oks_cov_pd_lse.id
        AND    oks_cov_pd_lse.lty_code      = 'COVER_PROD'
        AND    '#'                          = krel.object1_id2
        AND    oks_cov_pd_cleb.id           = krel.object1_id1
        AND    krel.rty_code                = 'OKLSRV'
        AND    krel.chr_id                  = lnk_srv_cleb.dnz_chr_id
        AND    krel.cle_id                  = lnk_srv_cleb.id
        AND    lnk_srv_cleb.lse_id          = lnk_srv_lse.id
        AND    lnk_srv_lse.lty_code         = 'LINK_SERV_ASSET'
        AND    lnk_srv_cleb.sts_code        = lnk_srv_sts.code
        AND    lnk_srv_sts.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
        AND    lnk_srv_cleb.dnz_chr_id       = lnk_srv_cim.dnz_chr_id
        AND    lnk_srv_cleb.id               = lnk_srv_cim.cle_id
        AND    lnk_srv_cim.jtot_object1_code = 'OKX_COVASST'
        AND    lnk_srv_cim.object1_id2       = '#'
        AND    lnk_srv_cim.object1_id1       = TO_CHAR(p_cle_id)
       );

l_lnk_to_srv  VARCHAR2(1) DEFAULT '?';

  --Bug# 2981308 : cursor to fetch asset key ccid
  CURSOR l_fab_csr(p_asset_id IN NUMBER) IS
  SELECT fab.asset_key_ccid
  FROM   fa_additions_b fab
  WHERE  fab.asset_id = p_asset_id;

  l_asset_key_id   fa_additions_b.asset_key_ccid%TYPE;
  --Bug# 2981308

  --Bug# 3783518
  CURSOR l_chr_csr(p_cle_id IN NUMBER) IS
  SELECT dnz_chr_id
  FROM okc_k_lines_b
  WHERE id = p_cle_id;

  l_chr_id okc_k_headers_b.id%TYPE;

  --cursor to check if contract has re-lease assets
  -- Bug# 4631549
  -- Disable split asset process for
  -- Re-lease contract and Re-lease asset flows
  CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
  SELECT '!'
  FROM   OKC_RULES_B rul
  WHERE  rul.dnz_chr_id = p_chr_id
  AND    rul.rule_information_category = 'LARLES'
  AND    NVL(rule_information1,'N') = 'Y';

 l_rel_ast VARCHAR2(1);
 -- Bug# 4542290 - smadhava - Added - Start
 l_pdt_params_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
 l_rev_recog_meaning     OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_MEANING%TYPE;

    CURSOR get_prod_param_values(cp_name OKL_PDT_QUALITYS.NAME%TYPE
                               , cp_value OKL_PQY_VALUES.VALUE%TYPE) IS
    SELECT
         QVE.DESCRIPTION
      FROM
         OKL_PDT_QUALITYS PQY
       , OKL_PQY_VALUES QVE
     WHERE
          QVE.PQY_ID = PQY.ID
      AND PQY.NAME   = cp_name
      AND QVE.VALUE  = cp_value;

 -- Bug# 4542290 - smadhava - Added - End

 --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

BEGIN
    --dbms_output.put_line('before start activity');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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
    l_ib_tbl := p_ib_tbl;
    --Bug# 6612475
    --1. Validate Split Request
    Validate_Split_Request
     (p_api_version               => p_api_version
     ,p_init_msg_list             => p_init_msg_list
     ,x_return_status             => x_return_status
     ,x_msg_count                 => x_msg_count
     ,x_msg_data                  => x_msg_data
     ,p_cle_id                    => p_cle_id
     ,p_split_into_individuals_yn => p_split_into_individuals_yn
     ,p_split_into_units          => p_split_into_units
     ,p_revision_date             => p_trx_date
     );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Commenting this validation as it is redundant now
    --because of newly added Validate_Split_Request
    --1.Verify p_cle_id
    --x_return_status := verify_cle_id(p_cle_id => p_cle_id);
    --IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    --ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        --RAISE OKL_API.G_EXCEPTION_ERROR;
    --END IF;
    --Bug# 6612475 End

    --Bug# 3783518: start
    -- Do not allow split asset for contracts with release assets
    OPEN l_chr_csr(p_cle_id => p_cle_id);
    FETCH l_chr_csr INTO l_chr_id;
    CLOSE l_chr_csr;

    -- Bug# 4542290 - smadhava - Added - Start
    -- Obtain the product parameter - Revenue Recognition method
    OKL_K_RATE_PARAMS_PVT.get_product(
            p_api_version       => p_api_version,
            p_init_msg_list     => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_khr_id            => l_chr_id,
            x_pdt_parameter_rec => l_pdt_params_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Raise an error if the Revenue Recognition Method is 'Actual' or 'Estimated and Actual'
    IF ( l_pdt_params_rec.Revenue_Recognition_Method = G_RRB_ESTIMATED OR
         l_pdt_params_rec.Revenue_Recognition_Method = G_RRB_ACTUAL) THEN
      OPEN get_prod_param_values('REVENUE_RECOGNITION_METHOD',
                                 l_pdt_params_rec.Revenue_Recognition_Method);
        FETCH get_prod_param_values INTO l_rev_recog_meaning;
      CLOSE get_prod_param_values;

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_RRB_SPLIT_ASSET_NOT_ALLWD,
                          p_token1       => G_METHOD,
                          p_token1_value => l_rev_recog_meaning);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Bug# 4542290 - smadhava - Added - End

    l_rel_ast := '?';
    --check for release assets in a contract
    OPEN l_chk_rel_ast_csr (p_chr_id => l_chr_id);
    FETCH l_chk_rel_ast_csr INTO l_rel_ast;
    CLOSE l_chk_rel_ast_csr;

    IF l_rel_ast = '!' THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_REL_ASSET_SPLIT_NOT_ALLWD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 3783518: end

    --Bug Fix # 2881114
    --check whether asset is linked to service contract
    l_lnk_to_srv := '?';
    OPEN lnk_to_srv_csr (p_cle_id => p_cle_id);
        FETCH lnk_to_srv_csr INTO l_lnk_to_srv;
        IF lnk_to_srv_csr%NOTFOUND THEN
            NULL;
        END IF;
    CLOSE lnk_to_srv_csr;

    IF l_lnk_to_srv = '!' THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ASSET_LINKED_TO_SERVICE);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug Fix # 2881114 End

    --2.Set the status of the Contract Line on HOLD
    --study the contract status concurrent program
    --possibly call it from here.
    --3.create and save split asset transaction
    l_trxv_rec.tas_type   := 'ALI';
    l_trxv_rec.tsu_code   := 'ENTERED';
    ----------------------------------
    --Bug# 3156924
    --validate trx_date :
    validate_trx_date(p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_cle_id         => p_cle_id,

                      p_trx_date       => p_trx_date);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --Bug# 5946411 :ER Added offlease pending transaction message
    Check_Offlease_Trans(p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_cle_id         => p_cle_id
                      );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   --Bug# 5946411 :ER end
    --l_trxv_rec.date_trans_occurred := sysdate;
    l_trxv_rec.date_trans_occurred := p_trx_date;

    --Added by dpsingh for LE Uptake

    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(l_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -------------------------------------
    --++++++++++++++++++++testing ty id only++++++++++++++++++++++
    x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_trxv_rec.try_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --++++++++++++++++++++testing ty id only++++++++++++++++++++++
    --Check if a 'ENTRED' unprocessed split transaction alreadt exists for this line
    --dbms_output.put_line('Before chk_split_trx cursor fetch');
    l_ast_line_rec := get_ast_line(p_cle_id,l_row_not_found);
    --dbms_output.put_line('After fetching asset line '||l_ast_line_rec.description);
    l_fa_exists := 'N';
    IF (l_row_not_found) THEN
       --Bug #2798006 : call create split transaction for Loans
       l_loan_yn := 'N';
       l_loan_yn := Check_If_Loan(P_Cle_Id        => p_cle_id,
                                  x_return_status => x_return_status);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF l_loan_yn = 'N' THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_SPLIT_ASSET_NOT_FOUND);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_loan_yn = 'Y' THEN
           --open cursor to get asset information from OKL tables
           OPEN loan_ast_csr(PCleId => p_cle_id);
           FETCH loan_ast_csr INTO l_loan_ast_rec;
           IF loan_ast_csr%NOTFOUND THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_SPLIT_ASSET_NOT_FOUND);
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSE
               l_fa_exists := 'N';
           END IF;
        END IF;
        --Bug# 2798006 end.
    ELSE
        l_fa_exists := 'Y';
    END IF;
    -- avsingh : added on 10-Aug-2002 : To Prevent Single unit assets to split into
    -- individuals
    IF (l_ast_line_rec.current_units = 1 AND l_loan_yn = 'N') OR
       (l_loan_ast_rec.current_units = 1 AND l_loan_yn = 'Y') THEN
       IF NVL(p_split_into_individuals_yn,'N') = 'Y' OR NVL(p_split_into_units,0) > 0 THEN

         --Bug# 6336455: Display appropriate error message when
         -- splitting an off-lease asset
         IF (l_ast_line_rec.line_status IN ('TERMINATED','EXPIRED')) OR
            (l_loan_ast_rec.line_status IN ('TERMINATED','EXPIRED')) THEN

                  OKL_API.set_message(p_app_name     => G_APP_NAME,
                                      p_msg_name     => 'OKL_AM_SINGLE_UNIT_SPLIT');
                  RAISE OKL_API.G_EXCEPTION_ERROR;

         ELSE
	          --Changed message name by bkatraga for bug 9548880
                  OKL_API.set_message(p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_SPLIT_UNIT_NOT_ALLWD);
                  RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;
         --Bug# 6336455: end
       END IF;
    END IF;


    OPEN chk_split_trx(p_cle_id => l_ast_line_rec.id1);
        FETCH chk_split_trx INTO
                            l_tal_id,
                            l_split_into_ind_yn,
                            l_split_units,
                            --Bug# 3156924
                            l_trx_date,
                            l_tas_id;
        --dbms_output.put_line('After chk_split_trx cursor fetch');
        IF chk_split_trx%NOTFOUND THEN
            --create new transaction (header, line and detail)
            -- Now creating the new header record
            --dbms_output.put_line('After chk_split_trx cursor fetch - trx not found.');
            Create_trx_header(p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_trxv_rec       => l_trxv_rec,
                              x_trxv_rec       => x_trxv_rec);
            --dbms_output.put_line('After creating trx header'||x_return_status);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        --Prepare txl record for insert into OKL_TXL_ASSETS_V

        IF l_fa_exists = 'Y' THEN
            l_txlv_rec.tas_id       := x_trxv_rec.id;
            l_txlv_rec.kle_id       := l_ast_line_rec.id1;
            l_txlv_rec.dnz_khr_id   := l_ast_line_rec.dnz_chr_id;
            l_txlv_rec.asset_number := l_ast_line_rec.name;
            l_txlv_rec.description  := l_ast_line_rec.description;
            x_return_status := Get_Fa_Location(l_ast_line_rec.asset_id,
                                               l_ast_line_rec.corporate_book,
                                               l_fa_location_id);
            --dbms_output.put_line('After fetching fa location id'||x_return_status);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_txlv_rec.fa_location_id := l_fa_location_id;
            l_txlv_rec.original_cost := l_ast_line_rec.original_cost;
            l_txlv_rec.current_units := l_ast_line_rec.current_units;
            IF l_ast_line_rec.new_used = 'NEW' THEN
                l_txlv_rec.used_asset_yn := 'Y';
            ELSIF l_ast_line_rec.new_used = 'USED' THEN
                l_txlv_rec.used_asset_yn := 'N';
            END IF;

            l_txlv_rec.tag_number            := l_ast_line_rec.tag_number;
            l_txlv_rec.model_number          := l_ast_line_rec.model_number;
            l_txlv_rec.corporate_book        := l_ast_line_rec.corporate_book;
            l_txlv_rec.in_service_date       := l_ast_line_rec.in_service_date;
            l_txlv_rec.org_id                := l_ast_line_rec.org_id;
            l_txlv_rec.depreciation_id       := l_ast_line_rec.depreciation_category;
            l_txlv_rec.life_in_months        := l_ast_line_rec.life_in_months;
            l_txlv_rec.depreciation_cost     := l_ast_line_rec.cost;
            l_txlv_rec.deprn_method          := l_ast_line_rec.deprn_method_code;
            l_txlv_rec.deprn_rate            := l_ast_line_rec.basic_rate;
            l_txlv_rec.salvage_value         := l_ast_line_rec.salvage_value;
            l_txlv_rec.percent_salvage_value := l_ast_line_rec.percent_salvage_value;

            --------------------------------------
            --Bug# 2981308 : fetch asset key ccid
            --------------------------------------
            OPEN l_fab_csr(p_asset_id => l_ast_line_rec.asset_id);
            FETCH l_fab_csr INTO l_asset_key_id;
            IF l_fab_csr%NOTFOUND THEN
                NULL;
            END IF;
            CLOSE l_fab_csr;

            l_txlv_rec.asset_key_id         := l_asset_key_id;
            -------------------------------------
            --bug# 2981308 : fetch asset key ccid
            ------------------------------------

        ELSIF l_fa_exists = 'N' THEN
            l_txlv_rec.tas_id        := x_trxv_rec.id;
            l_txlv_rec.kle_id        := l_loan_ast_rec.kle_id;
            l_txlv_rec.dnz_khr_id    := l_loan_ast_rec.dnz_chr_id;
            l_txlv_rec.asset_number  := l_loan_ast_rec.asset_number;
            l_txlv_rec.description   := l_loan_ast_rec.description;
            l_txlv_rec.original_cost := l_loan_ast_rec.original_cost;
            l_txlv_rec.current_units := l_loan_ast_rec.current_units;
            l_txlv_rec.used_asset_yn := 'Y';
            l_txlv_rec.depreciation_cost  := l_loan_ast_rec.cost;
        END IF;
        l_txlv_rec.SPLIT_INTO_SINGLES_FLAG := p_split_into_individuals_yn;
        l_txlv_rec.SPLIT_INTO_UNITS        := p_split_into_units;


        IF (l_txlv_rec.tal_type = OKC_API.G_MISS_CHAR OR
            l_txlv_rec.tal_type IS NULL) THEN
            l_txlv_rec.tal_type       := 'ALI';
        END IF;
        IF (l_txlv_rec.line_number = OKC_API.G_MISS_NUM OR
            l_txlv_rec.line_number IS NULL) THEN
            l_txlv_rec.line_number       := 1;
        ELSE
            l_txlv_rec.line_number       := l_txlv_rec.line_number + 1;
        END IF;

        --Bug# : Multi Currency
        OPEN curr_conv_csr (PCleId => p_cle_id);
        FETCH  curr_conv_csr INTO curr_conv_rec;
        IF curr_conv_csr%NOTFOUND THEN
            NULL;
        END IF;
        CLOSE curr_conv_csr;

        l_txlv_rec.currency_code            := curr_conv_rec.currency_code;
        l_txlv_rec.currency_conversion_type := curr_conv_rec.currency_conversion_type;
        l_txlv_rec.currency_conversion_rate := curr_conv_rec.currency_conversion_rate;
        l_txlv_rec.currency_conversion_date := curr_conv_rec.currency_conversion_date;

        --create asset line transaction
        OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_tlpv_rec       => l_txlv_rec,
                           x_tlpv_rec       => x_txlv_rec);
                --dbms_output.put_line('After creating transaction line'||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --call to create record for OKL_TXD_ASSETS_V
        --dbms_output.put_line('when fresh trx '||l_ast_line_rec.description);
        IF NVL(p_split_into_individuals_yn,'N') = 'X' THEN
           --split asset component transaction details will not be created
            NULL;
        ELSE
            Create_trx_details(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_ast_line_rec   => l_ast_line_rec,
                               p_txlv_rec       => x_txlv_rec,
                               x_txdv_tbl       => x_txdv_tbl);

            --dbms_output.put_line('After creating trx details'||x_return_status);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;

        --Bug #2723498 : 11.5.9 enahncement split asset by serial numbers
        --call to create serial number transaction
        create_srl_num_trx(p_api_version               => p_api_version,
                           p_init_msg_list             => p_init_msg_list,
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_cle_id                    => p_cle_id,
                           p_split_into_individuals_yn => p_split_into_individuals_yn,
                           p_split_into_units          => p_split_into_units,
                           p_ib_tbl                    => l_ib_tbl,
                           p_tas_id                    => x_txlv_rec.tas_id,
                           p_tal_id                    => x_txlv_rec.id,
                           p_asd_id                    => NULL);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --Bug #2723498 : 11.5.9 enahncement split asset by serial numbers end

    ELSE --chk_split_trx%FOUND
       -- If yes then chk if split parameters are same
       --dbms_output.put_line('transaction found');
       IF NVL(p_split_into_individuals_yn,'N') <> 'X' AND  NVL(l_split_into_ind_yn,'N') = 'X' THEN

          --split asset component transactions exist
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_SPLIT_AST_COMP_TRX);
          RAISE OKL_API.G_EXCEPTION_ERROR;

       ELSIF NVL(p_split_into_individuals_yn,'N') = 'X' AND  NVL(l_split_into_ind_yn,'N') <> 'X' THEN

           --split asset transactions exist
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_SPLIT_ASSET_TRX);
          RAISE OKL_API.G_EXCEPTION_ERROR;

       ELSIF (NVL(p_split_into_individuals_yn,'N') = NVL(l_split_into_ind_yn,'N') AND NVL(p_split_into_units,0) = NVL(l_split_units,0)
              --Bug# 3156924 :
              AND TRUNC(p_trx_date) = TRUNC(l_trx_date)) THEN
           -- If yes then do nothing
           NULL;
           --dbms_output.put_line('no change transaction found - doing nothing');
       ELSIF (NVL(p_split_into_individuals_yn,'N') <> 'X') AND
             (NVL(p_split_into_individuals_yn,'N') <> NVL(l_split_into_ind_yn,'N') OR NVL(p_split_into_units,0) <> NVL(l_split_units,0)
              --Bug# 3156924 :
              OR TRUNC(p_trx_date) <> TRUNC(l_trx_date)) THEN
       -- else
           -------------------------------------------------
           --Bug# 3156924
           ------------------------------------------------
           --update transaction header for transaction date
           l_trxv_rec.id := l_tas_id;
           l_trxv_rec.date_trans_occurred := p_trx_date;
           OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                          p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_thpv_rec      => l_trxv_rec,
                          x_thpv_rec      => x_trxv_rec);

           --dbms_output.put_line('after updating contract trx status to processed '||x_return_status);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           -------------------------------------------------
           --Bug# 3156924
           ------------------------------------------------

           --update transaction lines for split assets
           l_txlv_rec.id := l_tal_id;
           --l_txlv_rec.depreciate_yn := p_split_into_individuals_yn;
           --l_txlv_rec.units_retired := p_split_into_units;
           l_txlv_rec.SPLIT_INTO_SINGLES_FLAG := p_split_into_individuals_yn;
           l_txlv_rec.SPLIT_INTO_UNITS        := p_split_into_units;
           OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_tlpv_rec       => l_txlv_rec,
                           x_tlpv_rec       => x_txlv_rec);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --fetch transaction details
           l_txdv_tbl := get_trx_details(p_tal_id         => x_txlv_rec.id,
                                         x_no_data_found  => l_no_txd_data_found);
           IF l_no_txd_data_found THEN
               NULL;
               --dbms_output.put_line('No Transaction Details Found');
                       --call to create record for OKL_TXD_ASSETS_V
               --dbms_output.put_line('when txd assets not found '||l_ast_line_rec.description);
               Create_trx_details(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_ast_line_rec   => l_ast_line_rec,
                           p_txlv_rec       => x_txlv_rec,
                           x_txdv_tbl       => x_txdv_tbl);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

           ELSE
               -- delete transaction details and approprately create new transaction details
               OKL_TXD_ASSETS_PUB.delete_txd_asset_def(p_api_version   => p_api_version,
                                                       p_init_msg_list  => p_init_msg_list,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data,
                                                       p_adpv_tbl       => l_txdv_tbl);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
--Bug fix# 2744213 : positioning of end if
--            End If;

            -- create new transaction details
            --call to create record for OKL_TXD_ASSETS_V
            --dbms_output.put_line('after deleting txd assets '||l_ast_line_rec.description);
            Create_trx_details(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_ast_line_rec   => l_ast_line_rec,
                               p_txlv_rec       => x_txlv_rec,
                               x_txdv_tbl       => x_txdv_tbl);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;

        --Bug #2723498 11.5.9 enhancement - Splitting assets by serial numbers
        --check if serial number data exists

        l_srl_exists := '?';
        OPEN srl_exist_chk(x_txlv_rec.id);
        FETCH srl_exist_chk INTO l_srl_exists;
        IF srl_exist_chk%NOTFOUND THEN
            NULL;
        END IF;
        CLOSE srl_exist_chk;

        IF l_srl_exists = '!' THEN

            l_iipv_count := 0;
            OPEN get_srl_csr(x_txlv_rec.id);
            LOOP
                FETCH  get_srl_csr INTO l_iipv_id;
                EXIT WHEN get_srl_csr%NOTFOUND;
                l_iipv_count := l_iipv_count + 1;
                l_iipv_tbl(l_iipv_count).id := l_iipv_id;
            END LOOP;
            CLOSE get_srl_csr;

            IF l_iipv_tbl.COUNT > 0 THEN
                --delete the old records
                okl_txl_itm_insts_pub.delete_txl_itm_insts(
                   p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_iipv_tbl      => l_iipv_tbl);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
            END IF;

            --create new srl numbers if required
            create_srl_num_trx(p_api_version           => p_api_version,
                           p_init_msg_list             => p_init_msg_list,
                           x_return_status             => x_return_status,
                           x_msg_count                 => x_msg_count,
                           x_msg_data                  => x_msg_data,
                           p_cle_id                    => p_cle_id,
                           p_split_into_individuals_yn => p_split_into_individuals_yn,
                           p_split_into_units          => p_split_into_units,
                           p_ib_tbl                    => l_ib_tbl,
                           p_tas_id                    => x_txlv_rec.tas_id,
                           p_tal_id                    => x_txlv_rec.id,
                           p_asd_id                    => NULL);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        ELSIF l_srl_exists = '?' THEN
             --create new srl numbers if required
            create_srl_num_trx(p_api_version               => p_api_version,
                               p_init_msg_list             => p_init_msg_list,
                               x_return_status             => x_return_status,
                               x_msg_count                 => x_msg_count,
                               x_msg_data                  => x_msg_data,
                               p_cle_id                    => p_cle_id,
                               p_split_into_individuals_yn => p_split_into_individuals_yn,
                               p_split_into_units          => p_split_into_units,
                               p_ib_tbl                    => l_ib_tbl,
                               p_tas_id                    => x_txlv_rec.tas_id,
                               p_tal_id                    => x_txlv_rec.id,
                               p_asd_id                    => NULL);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF; -- srl number exists
        --Bug #2723498 11.5.9 enhancement - Splitting assets by serial numbers
     --Bug fix# 2744213 : positioning of end if
     END IF; -- chenges in transaction
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

END Create_Split_Transaction;
------------------------------------------------------------------------------
--Bug# 3156924
--API Name    : Create_Split_Transaction
--Description : Process API to create Split Aseet Transaction Records in
--              OKL_TXL_ASSETS_V and OKL_TXD_ASSETS_V
--Note        : Original split asset trx creation callo has been overloaded
--              to include p_trx_date(trx_date) as parameter. This old
--              signature preserved for backward compatability. It will
--              create split asset transaction on SYSDATE
--History     :
--              30-Jan-2004    avsingh  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE Create_Split_Transaction(p_api_version               IN  NUMBER,
                                   p_init_msg_list             IN  VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2,
                                   x_msg_count                 OUT NOCOPY NUMBER,
                                   x_msg_data                  OUT NOCOPY VARCHAR2,
                                   p_cle_id                    IN  NUMBER,
                                   p_split_into_individuals_yn IN  VARCHAR2,
                                   p_split_into_units          IN  NUMBER,
                                   p_ib_tbl                    IN  ib_tbl_type,
                                   x_txdv_tbl                  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec                  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec                  OUT NOCOPY trxv_rec_type) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_SPLIT_TRANSACTION';
l_api_version          CONSTANT NUMBER := 1.0;

l_trx_date             DATE := SYSDATE;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --call the overloded procedure :
    Create_Split_Transaction(p_api_version               => p_api_version,
                             p_init_msg_list             => p_init_msg_list,
                             x_return_status             => x_return_status,
                             x_msg_count                 => x_msg_count,
                             x_msg_data                  => x_msg_data,
                             p_cle_id                    => p_cle_id,
                             p_split_into_individuals_yn => p_split_into_individuals_yn,
                             p_split_into_units          => p_split_into_units,
                             p_ib_tbl                    => p_ib_tbl,
                             --Bug# 3156924
                             p_trx_date                  => l_trx_date,
                             x_txdv_tbl                  => x_txdv_tbl,
                             x_txlv_rec                  => x_txlv_rec,
                             x_trxv_rec                  => x_trxv_rec);

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

END Create_Split_Transaction;
-------------------------------------------------------------------------------------
--Bug# 3156924
--API Name    : Create_Split_Transaction
--Description : Process API to create Split Aseet Transaction Records in
--              OKL_TXL_ASSETS_V and OKL_TXD_ASSETS_V
--Note        : New signature added to accomodate p_trx_date being passed. This is
--              the one called from the UI. This will create transactions in OKL
--              _TXL_ITM_INSTS if the asset is serialized ad being split by units
--             UI will mark the selected records as selected_for_split_flag = 'Y'
--             for all the assets being split out
--History     :
--              30-Jan-2004    avsingh  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   p_trx_date  IN  DATE,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_SPLIT_TRANSACTION';
l_api_version          CONSTANT NUMBER := 1.0;
l_ib_tbl               ib_tbl_type;

    /*
    -- mvasudev, 08/23/2004
    -- Added PROCEDURE to enable Business Event
    */
        PROCEDURE raise_business_event(
           x_return_status OUT NOCOPY VARCHAR2
    )
        IS
       CURSOR l_okl_cle_chr_csr IS
       SELECT dnz_chr_id
       FROM   okc_k_lines_b
       WHERE  id = p_cle_id;

      l_parameter_list           wf_parameter_list_t;
        BEGIN

       FOR l_okl_cle_chr_rec IN l_okl_cle_chr_csr
           LOOP

                 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_okl_cle_chr_rec.dnz_chr_id,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,p_cle_id,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_TRANS_DATE,fnd_date.date_to_canonical(p_trx_date),l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                                                 x_return_status  => x_return_status,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data,
                                                                 p_event_name     => G_WF_EVT_KHR_SPLIT_ASSET_REQ,
                                                                 p_parameters     => l_parameter_list);

          END LOOP;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;

    /*
    -- mvasudev, 08/23/2004
    -- END, PROCEDURE to enable Business Event
    */

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --call the overloded procedure :
    Create_Split_Transaction(p_api_version               => p_api_version,
                             p_init_msg_list             => p_init_msg_list,
                             x_return_status             => x_return_status,
                             x_msg_count                 => x_msg_count,
                             x_msg_data                  => x_msg_data,
                             p_cle_id                    => p_cle_id,
                             p_split_into_individuals_yn => p_split_into_individuals_yn,
                             p_split_into_units          => p_split_into_units,
                             p_ib_tbl                    => l_ib_tbl,
                             p_trx_date                  => p_trx_date,
                             x_txdv_tbl                  => x_txdv_tbl,
                             x_txlv_rec                  => x_txlv_rec,
                             x_trxv_rec                  => x_trxv_rec);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

       /*
       -- mvasudev, 08/23/2004
       -- Code change to enable Business Event
       */
        raise_business_event(x_return_status => x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

       /*
       -- mvasudev, 08/23/2004
       -- END, Code change to enable Business Event
   */

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

END Create_Split_Transaction;
---------------
--Bug# 3156924
---------------
--Bug #2723498 : 11.5.9 Split by serial numbers enhancement
--------------------------------------------------------------------------------
--Start of Comments
--API Name    : Create_Split_Transaction
--Description : Process API to create Split Aseet Transaction Records in
--              OKL_TXL_ASSETS_V and OKL_TXD_ASSETS_V
--              1. Take the line details to be split
--              2. Set the status of the contract as inactive
--              3. Create and save source record into okl_trx_assets_v
--              4. Create and save target record into okl_txd_assets_v
--Note        : old signature kept for backward compatability. This will be the
--              the one called from the UI. This will create transactions in OKL
--              _TXL_ITM_INSTS if the asset is serialized ad being split by units
--             UI will mark the selected records as selected_for_split_flag = 'Y'
--             for all the assets being split out
--History     :
--              10-OCT-2001    avsingh  Creation
--End of Comments
------------------------------------------------------------------------------
PROCEDURE Create_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_split_into_individuals_yn IN VARCHAR2,
                                   p_split_into_units IN NUMBER,
                                   x_txdv_tbl  OUT NOCOPY txdv_tbl_type,
                                   x_txlv_rec  OUT NOCOPY txlv_rec_type,
                                   x_trxv_rec  OUT NOCOPY trxv_rec_type) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_SPLIT_TRANSACTION';
l_api_version          CONSTANT NUMBER := 1.0;
l_ib_tbl               ib_tbl_type;
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --call the overloded procedure :
    Create_Split_Transaction(p_api_version               => p_api_version,
                             p_init_msg_list             => p_init_msg_list,
                             x_return_status             => x_return_status,
                             x_msg_count                 => x_msg_count,
                             x_msg_data                  => x_msg_data,
                             p_cle_id                    => p_cle_id,
                             p_split_into_individuals_yn => p_split_into_individuals_yn,
                             p_split_into_units          => p_split_into_units,
                             p_ib_tbl                    => l_ib_tbl,
                             x_txdv_tbl                  => x_txdv_tbl,
                             x_txlv_rec                  => x_txlv_rec,
                             x_trxv_rec                  => x_trxv_rec);

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

END Create_Split_Transaction;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name  :  Update Split transaction
--Description     :  Updates the split asset number and description
--                   on transaction details table
--History         :
--                   08-Apr-2001  ashish.singh Created
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE Update_Split_Transaction(p_api_version   IN  NUMBER,
                                   p_init_msg_list IN  VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_cle_id        IN  NUMBER,
                                   p_txdv_tbl      IN  txdv_tbl_type,
                                   x_txdv_tbl      OUT NOCOPY txdv_tbl_type) IS

 l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT VARCHAR2(30) := 'UPDATE_SPLIT_TRX';
 l_api_version          CONSTANT NUMBER := 1.0;

  CURSOR fa_line_csr(p_cle_id IN NUMBER) IS
  SELECT cle.id
  FROM   OKC_K_LINES_B cle,
         OKC_LINE_STYLES_B lse
  WHERE  cle.cle_id = p_cle_id
  AND    cle.lse_id = lse.id
  AND    lse.lty_code = 'FIXED_ASSET'
   --Bug# 2761799 : Do not check for active status on sysdate
  --AND    trunc(nvl(start_date,sysdate)) <= trunc(sysdate)
  --AND    trunc(nvl(end_date,sysdate+1)) > trunc(sysdate)
  --Bug# 5946411: ER :commented following
 -- AND    cle.sts_code = 'BOOKED';
 ;
  --Bug# 5946411: ER End
  l_txlv_rec  txlv_rec_type;
  l_txdv_tbl  txdv_tbl_type;
  l_txdv_rec  txdv_rec_type;
  lx_txdv_rec txdv_rec_type;
  lx_txdv_tbl txdv_tbl_type;

  l_no_data_found BOOLEAN DEFAULT TRUE;
  l_fa_line_id    NUMBER;

  j NUMBER;

BEGIN

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

  --Verify cle_id
  x_return_status := verify_cle_id(p_cle_id => p_cle_id);
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --get fixed asset line
  OPEN   fa_line_csr(p_cle_id => p_cle_id) ;
  FETCH  fa_line_csr INTO l_fa_line_id;
  IF fa_line_csr%NOTFOUND THEN
      NULL; --not exactly
  ELSE
      l_txlv_rec := get_txlv_rec(l_fa_line_id, l_no_data_found);
      IF l_no_data_found THEN
          NULL;
          --dbms_output.put_line('No pending Split Asset Transactions for this Asset');
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_SPLIT_AST_TRX_NOT_FOUND
                              );
      ELSE
            l_txdv_tbl := p_txdv_tbl;
            --1. update txd assets
            IF l_txdv_tbl.LAST IS NOT NULL THEN
            j := 0;
            LOOP
                IF l_txdv_tbl.LAST = j THEN
                    EXIT;
            ELSE
                j := j+1;
                --dbms_output.put_line('J ='||to_char(j));
                l_txdv_rec.id := l_txdv_tbl(j).id;
                --Bug# 4994713: convert asset number to upper case
                l_txdv_rec.asset_number := UPPER(l_txdv_tbl(j).asset_number);
                l_txdv_rec.description := l_txdv_tbl(j).description;
                --dbms_output.put_line('l_txdv_rec.id'||to_char(l_txdv_rec.id));
                IF (l_txdv_rec.id IS NULL) OR (l_txdv_rec.id = OKL_API.G_MISS_NUM) THEN
                    EXIT;
                ELSE

                    OKL_TXD_ASSETS_PUB.update_txd_asset_def(
                              p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_adpv_rec       => l_txdv_rec,
                              x_adpv_rec       => lx_txdv_rec);
                    --dbms_output.put_line('after updating the transaction details for asset number '||l_txdv_rec.asset_number||':'||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                    ---

                    IF lx_txdv_rec.target_kle_id IS NULL THEN
                        x_return_status := validate_attributes(p_txdv_rec => lx_txdv_rec);

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                   END IF;

                    --validate if original asset number has been modified
                    IF l_txlv_rec.kle_id = lx_txdv_rec.target_kle_id THEN
                       IF (lx_txdv_rec.asset_number <> l_txlv_rec.asset_number)
                         OR (lx_txdv_rec.description <> l_txlv_rec.description) THEN
                           OKL_API.Set_message(p_app_name  => G_APP_NAME,
                                               p_msg_name  => G_SPLIT_PARENT_NUMBER_CHANGE);
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                       END IF;
                    END IF;

                    lx_txdv_tbl(j) := lx_txdv_rec;
                 END IF;
            END IF;
            END LOOP;
         END IF;
      -----
      END IF;
   END IF;
   x_txdv_tbl := lx_txdv_tbl;
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
END Update_Split_Transaction;
---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ITEMS_V
---------------------------------------------------------------------------
  FUNCTION get_cimv_rec (
    p_cle_id                       IN  NUMBER,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cimv_rec_type IS
    CURSOR okc_cimv_csr (p_cle_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CLE_ID,
            CHR_ID,
            CLE_ID_FOR,
            DNZ_CHR_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            UOM_CODE,
            EXCEPTION_YN,
            NUMBER_OF_ITEMS,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            PRICED_ITEM_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Items_V
     WHERE okc_k_items_v.cle_id     = p_cle_id;
    l_cimv_rec                     cimv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cimv_csr (p_cle_id);
    FETCH okc_cimv_csr INTO
              l_cimv_rec.ID,
              l_cimv_rec.OBJECT_VERSION_NUMBER,
              l_cimv_rec.CLE_ID,
              l_cimv_rec.CHR_ID,
              l_cimv_rec.CLE_ID_FOR,
              l_cimv_rec.DNZ_CHR_ID,
              l_cimv_rec.OBJECT1_ID1,
              l_cimv_rec.OBJECT1_ID2,
              l_cimv_rec.JTOT_OBJECT1_CODE,
              l_cimv_rec.UOM_CODE,
              l_cimv_rec.EXCEPTION_YN,
              l_cimv_rec.NUMBER_OF_ITEMS,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_cimv_rec.PRICED_ITEM_YN,
              l_cimv_rec.CREATED_BY,
              l_cimv_rec.CREATION_DATE,
              l_cimv_rec.LAST_UPDATED_BY,
              l_cimv_rec.LAST_UPDATE_DATE,
              l_cimv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cimv_csr%NOTFOUND;
    CLOSE okc_cimv_csr;
    RETURN(l_cimv_rec);
  END get_cimv_rec;

  FUNCTION get_cimv_rec (
    p_cle_id                     IN NUMBER
  ) RETURN cimv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_cimv_rec(p_cle_id, l_row_notfound));
  END get_cimv_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_K_LINES_V
---------------------------------------------------------------------------
FUNCTION get_klev_rec (
    p_cle_id                       IN  NUMBER,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN klev_rec_type IS
    CURSOR okl_k_lines_v_csr (p_id                 IN NUMBER) IS
      SELECT
        ID,
        OBJECT_VERSION_NUMBER,
        KLE_ID,
        STY_ID,
        PRC_CODE,
        FCG_CODE,
        NTY_CODE,
        ESTIMATED_OEC,
        LAO_AMOUNT,
        TITLE_DATE,
        FEE_CHARGE,
        LRS_PERCENT,
        INITIAL_DIRECT_COST,
        PERCENT_STAKE,
        PERCENT,
        EVERGREEN_PERCENT,
        AMOUNT_STAKE,
        OCCUPANCY,
        COVERAGE,
        RESIDUAL_PERCENTAGE,
        DATE_LAST_INSPECTION,
        DATE_SOLD,
        LRV_AMOUNT,
        CAPITAL_REDUCTION,
        DATE_NEXT_INSPECTION_DUE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        VENDOR_ADVANCE_PAID,
        WEIGHTED_AVERAGE_LIFE,
        TRADEIN_AMOUNT,
        BOND_EQUIVALENT_YIELD,
        TERMINATION_PURCHASE_AMOUNT,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        DELIVERED_DATE,
        CREDIT_TENANT_YN,
        DATE_LAST_CLEANUP,
        YEAR_OF_MANUFACTURE,
        COVERAGE_RATIO,
        REMARKETED_AMOUNT,
        GROSS_SQUARE_FOOTAGE,
        PRESCRIBED_ASSET_YN,
        DATE_REMARKETED,
        NET_RENTABLE,
        REMARKET_MARGIN,
        DATE_LETTER_ACCEPTANCE,
        REPURCHASED_AMOUNT,
        DATE_COMMITMENT_EXPIRATION,
        DATE_REPURCHASED,
        DATE_APPRAISAL,
        RESIDUAL_VALUE,
        APPRAISAL_VALUE,
        SECURED_DEAL_YN,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        RE_LEASE_YN,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        AMOUNT,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        STY_ID_FOR,
        CLG_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
        --Bug# 2998115
        FEE_TYPE,
--Bug# 3143522 : Subsidies
       SUBSIDY_ID,
       --SUBSIDIZED_OEC,
       --SUBSIDIZED_CAP_AMOUNT,
       PRE_TAX_YIELD,
       AFTER_TAX_YIELD,
       IMPLICIT_INTEREST_RATE,
       IMPLICIT_NON_IDC_INTEREST_RATE,
       PRE_TAX_IRR,
       AFTER_TAX_IRR,
       SUBSIDY_OVERRIDE_AMOUNT,
--quote
       SUB_PRE_TAX_YIELD,
       SUB_AFTER_TAX_YIELD,
       SUB_IMPL_INTEREST_RATE,
       SUB_IMPL_NON_IDC_INT_RATE,
       SUB_PRE_TAX_IRR,
       SUB_AFTER_TAX_IRR,
--Bug# 2994971
       ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 : 11.5.10+ schema changes
       QTE_ID,
       FUNDING_DATE,
       STREAM_TYPE_SUBCLASS
       -- Bug#4508050 - smadhava - Added - Start
       , FEE_PURPOSE_CODE
       , DATE_FUNDING_EXPECTED
       , DATE_DELIVERY_EXPECTED
       , MANUFACTURER_NAME
       , MODEL_NUMBER
       , DOWN_PAYMENT_RECEIVER_CODE
       , CAPITALIZE_DOWN_PAYMENT_YN
       -- Bug#4508050 - smadhava - Added - End
       --Bug# 4631549
       ,Expected_asset_cost

      FROM OKL_K_LINES_V
      WHERE OKL_K_LINES_V.id     = p_id;
      l_klev_rec                   klev_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_lines_v_csr (p_cle_id);
    FETCH okl_k_lines_v_csr INTO
       l_klev_rec.ID,
        l_klev_rec.OBJECT_VERSION_NUMBER,
        l_klev_rec.KLE_ID,
        l_klev_rec.STY_ID,
        l_klev_rec.PRC_CODE,
        l_klev_rec.FCG_CODE,
        l_klev_rec.NTY_CODE,
        l_klev_rec.ESTIMATED_OEC,
        l_klev_rec.LAO_AMOUNT,
        l_klev_rec.TITLE_DATE,
        l_klev_rec.FEE_CHARGE,
        l_klev_rec.LRS_PERCENT,
        l_klev_rec.INITIAL_DIRECT_COST,
        l_klev_rec.PERCENT_STAKE,
        l_klev_rec.PERCENT,
        l_klev_rec.EVERGREEN_PERCENT,
        l_klev_rec.AMOUNT_STAKE,
        l_klev_rec.OCCUPANCY,
        l_klev_rec.COVERAGE,
        l_klev_rec.RESIDUAL_PERCENTAGE,
        l_klev_rec.DATE_LAST_INSPECTION,
        l_klev_rec.DATE_SOLD,
        l_klev_rec.LRV_AMOUNT,
        l_klev_rec.CAPITAL_REDUCTION,
        l_klev_rec.DATE_NEXT_INSPECTION_DUE,
        l_klev_rec.DATE_RESIDUAL_LAST_REVIEW,
        l_klev_rec.DATE_LAST_REAMORTISATION,
        l_klev_rec.VENDOR_ADVANCE_PAID,
        l_klev_rec.WEIGHTED_AVERAGE_LIFE,
        l_klev_rec.TRADEIN_AMOUNT,
        l_klev_rec.BOND_EQUIVALENT_YIELD,
        l_klev_rec.TERMINATION_PURCHASE_AMOUNT,
        l_klev_rec.REFINANCE_AMOUNT,
        l_klev_rec.YEAR_BUILT,
        l_klev_rec.DELIVERED_DATE,
        l_klev_rec.CREDIT_TENANT_YN,
        l_klev_rec.DATE_LAST_CLEANUP,
        l_klev_rec.YEAR_OF_MANUFACTURE,
        l_klev_rec.COVERAGE_RATIO,
        l_klev_rec.REMARKETED_AMOUNT,
        l_klev_rec.GROSS_SQUARE_FOOTAGE,
        l_klev_rec.PRESCRIBED_ASSET_YN,
        l_klev_rec.DATE_REMARKETED,
        l_klev_rec.NET_RENTABLE,
        l_klev_rec.REMARKET_MARGIN,
        l_klev_rec.DATE_LETTER_ACCEPTANCE,
        l_klev_rec.REPURCHASED_AMOUNT,
        l_klev_rec.DATE_COMMITMENT_EXPIRATION,
        l_klev_rec.DATE_REPURCHASED,
        l_klev_rec.DATE_APPRAISAL,
        l_klev_rec.RESIDUAL_VALUE,
        l_klev_rec.APPRAISAL_VALUE,
        l_klev_rec.SECURED_DEAL_YN,
        l_klev_rec.GAIN_LOSS,
        l_klev_rec.FLOOR_AMOUNT,
        l_klev_rec.RE_LEASE_YN,
        l_klev_rec.PREVIOUS_CONTRACT,
        l_klev_rec.TRACKED_RESIDUAL,
        l_klev_rec.DATE_TITLE_RECEIVED,
        l_klev_rec.AMOUNT,
        l_klev_rec.ATTRIBUTE_CATEGORY,
        l_klev_rec.ATTRIBUTE1,
        l_klev_rec.ATTRIBUTE2,
        l_klev_rec.ATTRIBUTE3,
        l_klev_rec.ATTRIBUTE4,
        l_klev_rec.ATTRIBUTE5,
        l_klev_rec.ATTRIBUTE6,
        l_klev_rec.ATTRIBUTE7,
        l_klev_rec.ATTRIBUTE8,
        l_klev_rec.ATTRIBUTE9,
        l_klev_rec.ATTRIBUTE10,
        l_klev_rec.ATTRIBUTE11,
        l_klev_rec.ATTRIBUTE12,
        l_klev_rec.ATTRIBUTE13,
        l_klev_rec.ATTRIBUTE14,
        l_klev_rec.ATTRIBUTE15,
        l_klev_rec.STY_ID_FOR,
        l_klev_rec.CLG_ID,
        l_klev_rec.CREATED_BY,
        l_klev_rec.CREATION_DATE,
        l_klev_rec.LAST_UPDATED_BY,
        l_klev_rec.LAST_UPDATE_DATE,
        l_klev_rec.LAST_UPDATE_LOGIN,
        l_klev_rec.DATE_FUNDING,
        l_klev_rec.DATE_FUNDING_REQUIRED,
        l_klev_rec.DATE_ACCEPTED,
        l_klev_rec.DATE_DELIVERY_EXPECTED,
        l_klev_rec.OEC,
        l_klev_rec.CAPITAL_AMOUNT,
        l_klev_rec.RESIDUAL_GRNTY_AMOUNT,
        l_klev_rec.RESIDUAL_CODE,
        l_klev_rec.RVI_PREMIUM,
        l_klev_rec.CREDIT_NATURE,
        l_klev_rec.CAPITALIZED_INTEREST,
        l_klev_rec.CAPITAL_REDUCTION_PERCENT,
        l_klev_rec.DATE_PAY_INVESTOR_START,
        l_klev_rec.PAY_INVESTOR_FREQUENCY,
        l_klev_rec.PAY_INVESTOR_EVENT,
        l_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS,
        --Bug# 2998115:
        l_klev_rec.FEE_TYPE,
--Bug#3143522 : Subsidies
       l_klev_rec.SUBSIDY_ID,
       --l_klev_rec.SUBSIDIZED_OEC,
       --l_klev_rec.SUBSIDIZED_CAP_AMOUNT,
       l_klev_rec.PRE_TAX_YIELD,
       l_klev_rec.AFTER_TAX_YIELD,
       l_klev_rec.IMPLICIT_INTEREST_RATE,
       l_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
       l_klev_rec.PRE_TAX_IRR,
       l_klev_rec.AFTER_TAX_IRR,
       l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT,
--quote
       l_klev_rec.SUB_PRE_TAX_YIELD,
       l_klev_rec.SUB_AFTER_TAX_YIELD,
       l_klev_rec.SUB_IMPL_INTEREST_RATE,
       l_klev_rec.SUB_IMPL_NON_IDC_INT_RATE,
       l_klev_rec.SUB_PRE_TAX_IRR,
       l_klev_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971 :
       l_klev_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 : 11.5.10+ schema changes
       l_klev_rec.QTE_ID,
       l_klev_rec.FUNDING_DATE,
       l_klev_rec.STREAM_TYPE_SUBCLASS
       -- Bug#4508050 - smadhava - Added - Start
       , l_klev_rec.FEE_PURPOSE_CODE
       , l_klev_rec.DATE_FUNDING_EXPECTED
       , l_klev_rec.DATE_DELIVERY_EXPECTED
       , l_klev_rec.MANUFACTURER_NAME
       , l_klev_rec.MODEL_NUMBER
       , l_klev_rec.DOWN_PAYMENT_RECEIVER_CODE
       , l_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN
       -- Bug#4508050 - smadhava - Added - End
       --Bug# 4631549
       ,l_klev_rec.Expected_Asset_Cost
;
    x_no_data_found := okl_k_lines_v_csr%NOTFOUND;
    CLOSE okl_k_lines_v_csr;
    RETURN(l_klev_rec);
  END get_klev_rec;

FUNCTION get_klev_rec (
    p_cle_id                    IN NUMBER
  ) RETURN klev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_klev_rec(p_cle_id, l_row_notfound));
END get_klev_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKC_K_LINES_V
---------------------------------------------------------------------------
FUNCTION get_clev_rec (
    p_cle_id                     IN NUMBER,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clev_rec_type IS
    CURSOR okc_clev_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CHR_ID,
            CLE_ID,
            LSE_ID,
            LINE_NUMBER,
            STS_CODE,
            DISPLAY_SEQUENCE,
            TRN_CODE,
            DNZ_CHR_ID,
            COMMENTS,
            ITEM_DESCRIPTION,
                  OKE_BOE_DESCRIPTION,
            HIDDEN_IND,
                  PRICE_UNIT,
                  PRICE_UNIT_PERCENT,
            PRICE_NEGOTIATED,
               PRICE_NEGOTIATED_RENEWED,
            PRICE_LEVEL_IND,
            INVOICE_LINE_LEVEL_IND,
            DPAS_RATING,
            BLOCK23TEXT,
            EXCEPTION_YN,
            TEMPLATE_USED,
            DATE_TERMINATED,
            NAME,
            START_DATE,
            END_DATE,
                  DATE_RENEWED,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
             ORIG_SYSTEM_SOURCE_CODE,
             ORIG_SYSTEM_ID1,
             ORIG_SYSTEM_REFERENCE1,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PRICE_TYPE,
            CURRENCY_CODE,
                CURRENCY_CODE_RENEWED,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Lines_V
     WHERE okc_k_lines_v.id     = p_id;
    l_clev_rec                     clev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_clev_csr (p_cle_id);
    FETCH okc_clev_csr INTO
              l_clev_rec.ID,
              l_clev_rec.OBJECT_VERSION_NUMBER,
              l_clev_rec.SFWT_FLAG,
              l_clev_rec.CHR_ID,
              l_clev_rec.CLE_ID,
              l_clev_rec.LSE_ID,
              l_clev_rec.LINE_NUMBER,
              l_clev_rec.STS_CODE,
              l_clev_rec.DISPLAY_SEQUENCE,
              l_clev_rec.TRN_CODE,
              l_clev_rec.DNZ_CHR_ID,
              l_clev_rec.COMMENTS,
              l_clev_rec.ITEM_DESCRIPTION,
                    l_clev_rec.OKE_BOE_DESCRIPTION,
              l_clev_rec.HIDDEN_IND,
                    l_clev_rec.PRICE_UNIT,
                    l_clev_rec.PRICE_UNIT_PERCENT,
              l_clev_rec.PRICE_NEGOTIATED,
                    l_clev_rec.PRICE_NEGOTIATED_RENEWED,
              l_clev_rec.PRICE_LEVEL_IND,
              l_clev_rec.INVOICE_LINE_LEVEL_IND,
              l_clev_rec.DPAS_RATING,
              l_clev_rec.BLOCK23TEXT,
              l_clev_rec.EXCEPTION_YN,
              l_clev_rec.TEMPLATE_USED,
              l_clev_rec.DATE_TERMINATED,
              l_clev_rec.NAME,
              l_clev_rec.START_DATE,
              l_clev_rec.END_DATE,
                    l_clev_rec.DATE_RENEWED,
              l_clev_rec.UPG_ORIG_SYSTEM_REF,
              l_clev_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_clev_rec.ORIG_SYSTEM_SOURCE_CODE,
              l_clev_rec.ORIG_SYSTEM_ID1,
              l_clev_rec.ORIG_SYSTEM_REFERENCE1,
              l_clev_rec.ATTRIBUTE_CATEGORY,
              l_clev_rec.ATTRIBUTE1,
              l_clev_rec.ATTRIBUTE2,
              l_clev_rec.ATTRIBUTE3,
              l_clev_rec.ATTRIBUTE4,
              l_clev_rec.ATTRIBUTE5,
              l_clev_rec.ATTRIBUTE6,
              l_clev_rec.ATTRIBUTE7,
              l_clev_rec.ATTRIBUTE8,
              l_clev_rec.ATTRIBUTE9,
              l_clev_rec.ATTRIBUTE10,
              l_clev_rec.ATTRIBUTE11,
              l_clev_rec.ATTRIBUTE12,
              l_clev_rec.ATTRIBUTE13,
              l_clev_rec.ATTRIBUTE14,
              l_clev_rec.ATTRIBUTE15,
              l_clev_rec.CREATED_BY,
              l_clev_rec.CREATION_DATE,
              l_clev_rec.LAST_UPDATED_BY,
              l_clev_rec.LAST_UPDATE_DATE,
              l_clev_rec.PRICE_TYPE,
              l_clev_rec.CURRENCY_CODE,
                  l_clev_rec.CURRENCY_CODE_RENEWED,
              l_clev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_clev_csr%NOTFOUND;
    CLOSE okc_clev_csr;
    RETURN(l_clev_rec);
END get_clev_rec;

FUNCTION get_clev_rec (
    p_cle_id                     IN NUMBER
  ) RETURN clev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
BEGIN
    RETURN(get_clev_rec(p_cle_id, l_row_notfound));
END get_clev_rec;
--Bug #2648280 Begin
--------------------------------------------------------------------------------
-- Procedure to split streams : will be called after split asset processing
-- Bug #2648280  - During the split asset process streams were not getting split
-- for the financial asset lines getting split. Splitting of streams being done
-- in this procedure
-- Bug # 2723498 : 11.5.9 Enhancement Multi-GAAP support . Split reporting streams
--------------------------------------------------------------------------------
PROCEDURE split_streams(p_api_version      IN  NUMBER,
                        p_init_msg_list    IN  VARCHAR2,
                        x_return_status    OUT NOCOPY   VARCHAR2,
                        x_msg_count        OUT NOCOPY   NUMBER,
                        x_msg_data         OUT NOCOPY   VARCHAR2,
                        p_txl_id           IN  NUMBER)  AS

    l_api_name          CONSTANT VARCHAR2(256) := 'SPLIT_STREAMS';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;


    l_stmv_rec Okl_Streams_pub.stmv_rec_type;
    l_selv_tbl Okl_Streams_pub.selv_tbl_type;
    x_stmv_rec Okl_Streams_pub.stmv_rec_type;
    x_selv_tbl Okl_Streams_pub.selv_tbl_type;

    --Cursor to fetch split child records (for split asset as well as split asset into components)
    CURSOR l_split_trx_csr1(p_trxline_id IN NUMBER) IS
    SELECT txd.split_percent,
           txl.kle_id,
           txd.target_kle_id,
           cle.cle_id  cle_id,
           target_cle.cle_id target_cle_id,
           txd.quantity,
           txl.current_units
    FROM   okl_txd_assets_b  txd,
           okl_txl_Assets_b  txl,
           okc_k_lines_b     cle,
           okc_k_lines_b     target_cle
    WHERE  txl.tal_type  = 'ALI'
    AND    txd.tal_id    = txl.id
    AND    txl.id        = p_trxline_id
    AND    txl.kle_id    <> txd.target_kle_id
    AND    cle.id        = txl.kle_id
    AND    target_cle.id = txd.target_kle_id
    --Bug# 3502142
    ORDER BY NVL(txd.split_percent,-1);

    --Bug# 3502142
    subtype l_split_trx_rec is l_split_trx_csr1%ROWTYPE;
    type l_split_trx_tbl is table of l_split_trx_rec INDEX BY BINARY_INTEGER;
    l_split_trx_tbl1 l_split_trx_tbl;

    --Cursor to fetch split parent record for Split Asset (Not split Asset into components)
    CURSOR l_split_trx_csr2(p_trxline_id IN NUMBER) IS
    SELECT txd.split_percent,
           txl.kle_id,
           txd.target_kle_id,
           cle.cle_id  cle_id,
           target_cle.cle_id target_cle_id,
           txd.quantity,
           txl.current_units
    FROM   okl_txd_assets_b  txd,
           okl_txl_Assets_b  txl,
           okc_k_lines_b     cle,
           okc_k_lines_b     target_cle
    WHERE  txl.tal_type  = 'ALI'
    AND    txd.tal_id    = txl.id
    AND    txl.id        = p_trxline_id
    AND    txl.kle_id    = txd.target_kle_id
    AND    cle.id        = txl.kle_id
    AND    target_cle.id = txd.target_kle_id;



    l_split_trx_rec1  l_split_trx_csr1%ROWTYPE;
    l_split_trx_rec2  l_split_trx_csr2%ROWTYPE;

        l_kle_id          NUMBER;
    l_split_factor    NUMBER;

    --Bug# 3066375:
    --Cursor to find any linked asset lines
    CURSOR l_lnk_asst_csr1 (p_cle_id IN NUMBER, p_target_cle_id IN NUMBER) IS
    SELECT lnk_cle.id,
           lnk_target_cle.id,
           --Bug 3502142
           lnk_target_cle.cle_id
    FROM   okc_k_lines_b     lnk_cle,
           okc_k_items       lnk_cim,
           okc_line_styles_b lnk_lse,
           okc_k_lines_b     lnk_target_cle,
           okc_k_items       lnk_target_cim,
           okc_line_styles_b lnk_target_lse
    WHERE  lnk_cim.object1_id1              = TO_CHAR(p_cle_id)
    AND    lnk_cim.object1_id2              = '#'
    AND    lnk_cim.jtot_object1_code        = 'OKX_COVASST'
    AND    lnk_cle.id                       = lnk_cim.cle_id
    AND    lnk_cle.dnz_chr_id               = lnk_cim.dnz_chr_id
    AND    lnk_cle.lse_id                   = lnk_lse.id
    AND    lnk_lse.lty_code                 IN ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
    AND    lnk_target_cim.object1_id1       = TO_CHAR(p_target_cle_id)
    AND    lnk_target_cim.object1_id2       = '#'
    AND    lnk_target_cim.jtot_object1_code = 'OKX_COVASST'
    AND    lnk_target_cle.id                = lnk_target_cim.cle_id
    AND    lnk_target_cle.dnz_chr_id        = lnk_target_cim.dnz_chr_id
    AND    lnk_target_cle.lse_id            = lnk_target_lse.id
    AND    lnk_target_lse.lty_code          IN ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
    AND    lnk_cle.cle_id                   = lnk_target_cle.cle_id
    AND    lnk_cle.id                      <> lnk_target_cle.id
    AND    lnk_cle.dnz_chr_id               = lnk_target_cle.dnz_chr_id;

    CURSOR l_lnk_asst_csr2 (p_cle_id IN NUMBER, p_target_cle_id IN NUMBER) IS
    SELECT lnk_cle.id,
           lnk_target_cle.id,
           --Bug 3502142
           lnk_target_cle.cle_id
    FROM   okc_k_lines_b     lnk_cle,
           okc_k_items       lnk_cim,
           okc_line_styles_b lnk_lse,
           okc_k_lines_b     lnk_target_cle,
           okc_k_items       lnk_target_cim,
           okc_line_styles_b lnk_target_lse
    WHERE  lnk_cim.object1_id1              = TO_CHAR(p_cle_id)
    AND    lnk_cim.object1_id2              = '#'
    AND    lnk_cim.jtot_object1_code        = 'OKX_COVASST'
    AND    lnk_cle.id                       = lnk_cim.cle_id
    AND    lnk_cle.dnz_chr_id               = lnk_cim.dnz_chr_id
    AND    lnk_cle.lse_id                   = lnk_lse.id
    AND    lnk_lse.lty_code                 IN ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
    AND    lnk_target_cim.object1_id1       = TO_CHAR(p_target_cle_id)
    AND    lnk_target_cim.object1_id2       = '#'
    AND    lnk_target_cim.jtot_object1_code = 'OKX_COVASST'
    AND    lnk_target_cle.id                = lnk_target_cim.cle_id
    AND    lnk_target_cle.dnz_chr_id        = lnk_target_cim.dnz_chr_id
    AND    lnk_target_cle.lse_id            = lnk_target_lse.id
    AND    lnk_target_lse.lty_code          IN ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
    AND    lnk_cle.cle_id                   = lnk_target_cle.cle_id
    AND    lnk_cle.id                       = lnk_target_cle.id
    AND    lnk_cle.dnz_chr_id               = lnk_target_cle.dnz_chr_id;


    l_lnk_cle_id         okc_k_lines_b.id%TYPE;
    l_lnk_target_cle_id  okc_k_lines_b.id%TYPE;

    -- Bug# 3502142
    l_lnk_top_cle_id     okc_k_lines_b.id%TYPE;
    --Bug# 6344223
    l_highest_split_comp_amt VARCHAR2(30);
    l_count NUMBER;

--------------------------------------------------------------------------------
-- Local procedure to do split streams processing
-- IN parameters - p_kle_id (child top line)
--               - p_parent_kle_id (parent top line)
--               - p_split_factor (split factor)
--------------------------------------------------------------------------------
    PROCEDURE Process_Split_Streams(p_api_version      IN  NUMBER,
                          p_init_msg_list    IN  VARCHAR2,
                          x_return_status    OUT NOCOPY   VARCHAR2,
                          x_msg_count        OUT NOCOPY   NUMBER,
                          x_msg_data         OUT NOCOPY   VARCHAR2,
                          p_kle_id           IN  NUMBER,
                          p_split_factor     IN  NUMBER,
                          p_parent_kle_id    IN  NUMBER,
                          p_txl_id           IN  NUMBER,
                          --Bug# 6344223
                          p_highest_split_comp_amt IN VARCHAR2 DEFAULT 'N') IS

    l_stmv_rec      Okl_Streams_pub.stmv_rec_type;
    l_selv_tbl      Okl_Streams_pub.selv_tbl_type;
    l_stmv_rec_hist Okl_Streams_pub.stmv_rec_type;
    l_selv_tbl_hist Okl_Streams_pub.selv_tbl_type;
    x_stmv_rec      Okl_Streams_pub.stmv_rec_type;
    x_selv_tbl      Okl_Streams_pub.selv_tbl_type;


    CURSOR l_strm_csr ( kleId NUMBER, status VARCHAR2) IS
    SELECT str.Id,
           str.transaction_number,
           str.sgn_code SGN_CODE,
           str.khr_id,
           str.sty_id,
           str.say_code,
           str.active_yn,
           str.kle_id,
           --Bug# 3502142
           str.purpose_code,
           str.comments,
           str.date_current,
           -- Bug# 4775555
           sty.stream_type_purpose,
           --Bug# 6344223
           str.link_hist_stream_id
    FROM okl_streams str,
         okl_strm_type_b sty
    WHERE
    str.kle_id = kleId
    AND str.say_code = status
    AND str.sty_id = sty.id;

    --Bug# 3502142
    CURSOR l_strmele_csr( kleId NUMBER, styId NUMBER, strId NUMBER,
                          purposeCode VARCHAR2, activeYn VARCHAR2) IS
    SELECT ele.id,
           ele.DATE_BILLED,
           ele.STREAM_ELEMENT_DATE,
           ele.AMOUNT,
           ele.ACCRUED_YN,
           ele.comments,
           str.transaction_number,
           str.sgn_code SGN_CODE,
           ele.stm_id STM_ID,
           ele.se_line_number SE_LINE_NUMBER
    FROM  okl_strm_elements ele,
          okl_streams str
    WHERE ele.stm_id = str.id
    AND str.id     = strId
    AND str.kle_id = kleId
    AND str.sty_id = styId
    AND UPPER(str.say_code) = 'CURR'
    AND UPPER(str.active_yn) = activeYn
    AND NVL(str.purpose_code,'ORIG') = purposeCode
    ORDER BY 3;

    l_strms_rec       l_strm_csr%ROWTYPE;
    l_strmele_rec     l_strmele_csr%ROWTYPE;
    i                 NUMBER;
    l_kle_id          NUMBER;

    --cursor to fetch transaction number
    CURSOR l_sifseq_csr IS
    SELECT okl_sif_seq.NEXTVAL
    FROM   dual;

    -- Bug# 3502142: start
    CURSOR curr_code_csr(p_kle_id IN NUMBER) IS
    SELECT currency_code
    FROM okc_k_lines_b
    WHERE id = p_kle_id;

    l_currency_code OKC_K_LINES_B.currency_code%type;

    l_active_yn          OKL_STREAMS.ACTIVE_YN%TYPE;

    --Bug# 4775555
    l_stmv_rec_temp Okl_Streams_pub.stmv_rec_type;

   --Bug# 6344223
   CURSOR l_txd_csr(p_trxline_id IN NUMBER) IS
    SELECT txd.id,
           txd.split_percent,
           txl.kle_id,
           txd.target_kle_id,
           cle.cle_id  cle_id,
           target_cle.cle_id target_cle_id,
           txd.quantity,
           txl.current_units
    FROM   okl_txd_assets_b  txd,
           okl_txl_Assets_b  txl,
           okc_k_lines_b     cle,
           okc_k_lines_b     target_cle
    WHERE  txl.tal_type  = 'ALI'
    AND    txd.tal_id    = txl.id
    AND    txl.id        = p_trxline_id
    AND    txl.kle_id    <> txd.target_kle_id
    AND    cle.id        = txl.kle_id
    AND    target_cle.id = txd.target_kle_id;


  l_split_pymt NUMBER;
  l_split_pymt_sum NUMBER;
  l_child_split_factor NUMBER;
  l_rounded_amount NUMBER;
  l_child_amount NUMBER;

  BEGIN
        x_return_status :=  OKL_API.G_RET_STS_SUCCESS;

        IF ( p_parent_kle_id = p_kle_id ) THEN
                    l_kle_id := p_kle_id;
                ELSE
                    l_kle_id := p_parent_kle_id;
        END IF;

        -- Bug# 3502142
        open curr_code_csr(p_kle_id => p_kle_id);
        fetch curr_code_csr into l_currency_code;
        close curr_code_csr;

        FOR l_strms_rec IN l_strm_csr( l_kle_id, 'CURR' )
        LOOP

          -- Bug# 4775555
          -- Disbursement Basis streams should only be Historized here
          -- They will be recreated later by the call to
          -- okl_stream_generator_pvt.create_disb_streams
          IF (l_strms_rec.stream_type_purpose
               IN ('INVESTOR_RENT_DISB_BASIS',
                   'INVESTOR_RESIDUAL_DISB_BASIS','INVESTOR_PRINCIPAL_DISB_BASIS','INVESTOR_INTEREST_DISB_BASIS')) THEN

            IF (p_parent_kle_id = p_kle_id) THEN

              l_stmv_rec_hist              := l_stmv_rec_temp;
              l_stmv_rec_hist.id           := l_strms_rec.id;
              l_stmv_rec_hist.kle_id       := l_kle_id;
              l_stmv_rec_hist.say_code     := 'HIST';
              l_stmv_rec_hist.active_yn    := 'N';
              l_stmv_rec_hist.date_history := SYSDATE;
              --Bug# 6344223
		  l_stmv_rec_hist.link_hist_stream_id := l_strms_rec.link_hist_stream_id;
              Okl_Streams_Pub.update_streams(
                p_api_version   => l_api_version
               ,p_init_msg_list => p_init_msg_list
               ,x_return_status => x_return_status
               ,x_msg_count     => x_msg_count
               ,x_msg_data      => x_msg_data
               ,p_stmv_rec      => l_stmv_rec_hist
               ,x_stmv_rec      => x_stmv_rec);

               IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;

            END IF;

          ELSE

            l_stmv_rec.sty_id := l_strms_rec.sty_id;
            --l_stmv_rec.khr_id := p_chr_id;
            l_stmv_rec.khr_id := l_strms_rec.khr_id;

            IF ((p_parent_kle_id = p_kle_id ) AND (p_split_factor = 0)) THEN
                l_stmv_rec.say_code := 'HIST';
                l_stmv_rec.active_yn := 'N';
                l_stmv_rec.date_history := SYSDATE;
                --Bug# 6344223
                l_stmv_rec.link_hist_stream_id := l_strms_rec.link_hist_stream_id;
            ELSE
                l_stmv_rec.say_code := 'CURR';
                --Bug# 6344223
                l_stmv_rec.link_hist_stream_id := l_strms_rec.id;
                --Bug# 3502142
                --l_stmv_rec.active_yn := 'Y';
                --l_stmv_rec.date_current := SYSDATE;
            END IF;
            --Bug# 3502142
            --l_stmv_rec.active_yn := 'Y';
            --l_stmv_rec.date_current := SYSDATE;
            l_stmv_rec.transaction_number := l_strms_rec.transaction_number;
            l_stmv_rec.sgn_code := l_strms_rec.sgn_code;
            --Bug# 3502142
            l_stmv_rec.purpose_code := l_strms_rec.purpose_code;
            l_stmv_rec.active_yn := l_strms_rec.active_yn;
            l_stmv_rec.comments := l_strms_rec.comments;
            l_stmv_rec.date_current := l_strms_rec.date_current;

            i := 0;
            -- Bug# 3502142

            if NVL(l_strms_rec.purpose_code,'ORIG') = 'ORIG' then
              l_active_yn := 'Y';
            elsif l_strms_rec.purpose_code = 'REPORT' then
              l_active_yn := 'N';
            end if;

            FOR l_strmele_rec IN l_strmele_csr(l_kle_id, l_strms_rec.sty_id, l_strms_rec.id,
                                               NVL(l_strms_rec.purpose_code,'ORIG'), l_active_yn)
              LOOP
                i := i + 1;
                l_selv_tbl(i).accrued_yn          := l_strmele_rec.accrued_yn;
                l_selv_tbl(i).stream_element_date := l_strmele_rec.stream_element_date;
                l_selv_tbl(i).date_billed         := l_strmele_rec.date_billed;
                l_selv_tbl(i).se_line_number      := l_strmele_rec.SE_LINE_NUMBER;
                l_selv_tbl(i).comments            := l_strmele_rec.comments;

                IF p_split_factor <> 0 THEN
                   --for parent line adjust the stream element amount
                   l_split_pymt_sum := 0;

                     --get the sum of stream element amount for child asset if
                     -- calculating cost for the parent line or for the
                     -- child line with highest split percent
                    IF (p_parent_kle_id = p_kle_id ) OR (p_highest_split_comp_amt='Y') THEN

                           FOR l_txd_rec in l_txd_csr(p_txl_id)
                           LOOP
                            IF NVL(l_txd_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN
                              l_child_split_factor := l_txd_rec.quantity/l_txd_rec.current_units;
                           ELSE
                              l_child_split_factor := l_txd_rec.split_percent/100;
                           END IF;
                            l_split_pymt := l_strmele_rec.amount * l_child_split_factor;
                            okl_accounting_util.round_amount(
                                                         p_api_version    => p_api_version,
                                                         p_init_msg_list  => p_init_msg_list,
                                                         x_return_status  => x_return_status,
                                                         x_msg_count      => x_msg_count,
                                                         x_msg_data       => x_msg_data,
                                                         p_amount         => l_split_pymt,
                                                         p_currency_code  => l_currency_code,
                                                         p_round_option   => 'STM',
                                                         x_rounded_amount => l_rounded_amount
                                                         );
                            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;
                            l_split_pymt_sum := l_split_pymt_sum + l_rounded_amount;
                          END LOOP;
                      END IF;

                     IF (p_parent_kle_id = p_kle_id ) THEN
                           --for split by unit--
                          l_selv_tbl(i).amount :=l_strmele_rec.amount - l_split_pymt_sum;

                     ELSE
                           --claculate the amount for child line
                           l_child_amount :=l_strmele_rec.amount * p_split_factor;
                           okl_accounting_util.round_amount(
                                                       p_api_version    => p_api_version,
                                                         p_init_msg_list  => p_init_msg_list,
                                                         x_return_status  => x_return_status,
                                                         x_msg_count      => x_msg_count,
                                                         x_msg_data       => x_msg_data,
                                                         p_amount         => l_child_amount,
                                                         p_currency_code  => l_currency_code,
                                                         p_round_option   => 'STM',
                                                         x_rounded_amount => l_rounded_amount
                                                         );
                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                           l_child_amount :=l_rounded_amount;
                           --adjust the amount for highest asset percent if split by component
                           if p_highest_split_comp_amt='Y' THEN
                               l_selv_tbl(i).amount :=l_child_amount+ l_strmele_rec.amount - l_split_pymt_sum;
                            else
                               -- no adjustment required
                               l_selv_tbl(i).amount :=l_child_amount;
                           END IF;

                        END IF; --end if for parent line check
                       --dbms_output.put_line('l_selv_tbl(i).amount  '||l_selv_tbl(i).amount );
                END IF; --p_split_factor
                -----------------------------------------------------------------
                --If (p_parent_kle_id = p_kle_id ) then
                    --l_selv_tbl(i).stm_id := l_strms_rec.id;
                    --l_selv_tbl(i).id     := l_strmele_rec.id;
                --End If;
                -----------------------------------------------------------------
                l_selv_tbl_hist(i)        := l_selv_tbl(i);
                l_selv_tbl_hist(i).amount := l_strmele_rec.amount;
                l_selv_tbl_hist(i).stm_id := l_strms_rec.id;
                l_selv_tbl_hist(i).id     := l_strmele_rec.id;

            END LOOP;

            IF (i <> 0) THEN
            IF (p_parent_kle_id = p_kle_id ) THEN
                ------------------------------------------------------------------------
                --Bug# : historize old streams and recreate with new values for old asset
                ------------------------------------------------------------------------
                l_stmv_rec_hist          := l_stmv_rec;
                l_stmv_rec_hist.id       := l_strms_rec.id;
                l_stmv_rec_hist.kle_id   := l_kle_id;
                l_stmv_rec_hist.say_code := 'HIST';
                l_stmv_rec_hist.active_yn := 'N';
                l_stmv_rec_hist.date_history := SYSDATE;
                --Bug# 6344223
                l_stmv_rec_hist.link_hist_stream_id := l_strms_rec.link_hist_stream_id;
                Okl_Streams_Pub.update_streams(
                               p_api_version   => l_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_stmv_rec      => l_stmv_rec_hist
                              ,p_selv_tbl      => l_selv_tbl_hist
                              ,x_stmv_rec      => x_stmv_rec
                              ,x_selv_tbl      => x_selv_tbl);

               IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;

               IF (p_split_factor <> 0 ) THEN
                   l_stmv_rec.kle_id := l_kle_id;
                   l_stmv_rec.sgn_code := 'MANL';
                   l_stmv_rec.comments := 'Generated manually during split asset from parent transaction number '||TO_CHAR(l_stmv_rec.transaction_number);
                   OPEN l_sifseq_csr;
                   FETCH l_sifseq_csr INTO l_stmv_rec.transaction_number;
                   CLOSE l_sifseq_csr;
                   --Bug# 3502142
                   l_stmv_rec.date_current := SYSDATE;

                   Okl_Streams_Pub.create_streams(
                               p_api_version   => l_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_stmv_rec      => l_stmv_rec
                              ,p_selv_tbl      => l_selv_tbl
                              ,x_stmv_rec      => x_stmv_rec
                              ,x_selv_tbl      => x_selv_tbl);

                   IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                   END IF;
                END IF;

            ELSE

                l_stmv_rec.kle_id := p_kle_id;
                l_stmv_rec.sgn_code := 'MANL';
                --Bug# 3502142
                l_stmv_rec.comments := 'Generated manually during split asset from parent transaction number '||TO_CHAR(l_stmv_rec.transaction_number);
                OPEN l_sifseq_csr;
                FETCH l_sifseq_csr INTO l_stmv_rec.transaction_number;
                CLOSE l_sifseq_csr;
                --Bug# 3502142
                l_stmv_rec.date_current := SYSDATE;

                Okl_Streams_Pub.create_streams(
                               p_api_version   => l_api_version
                              ,p_init_msg_list => p_init_msg_list
                              ,x_return_status => x_return_status
                              ,x_msg_count     => x_msg_count
                              ,x_msg_data      => x_msg_data
                              ,p_stmv_rec      => l_stmv_rec
                              ,p_selv_tbl      => l_selv_tbl
                              ,x_stmv_rec      => x_stmv_rec
                              ,x_selv_tbl      => x_selv_tbl);

               IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;


            END IF;
            ELSE
               NULL;
            END IF;

            l_selv_tbl.DELETE(1, l_selv_tbl.LAST);
            l_selv_tbl_hist.DELETE(1, l_selv_tbl.LAST);

          END IF;
        END LOOP;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF l_strm_csr%ISOPEN THEN
          CLOSE l_strm_csr;
      END IF;
      IF l_strmele_csr%ISOPEN THEN
          CLOSE l_strmele_csr;
      END IF;
      NULL;
  WHEN OTHERS THEN
      IF l_strm_csr%ISOPEN THEN
          CLOSE l_strm_csr;
      END IF;
      IF l_strmele_csr%ISOPEN THEN
          CLOSE l_strmele_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

END process_split_streams;
/*begin main body*/
BEGIN

    x_return_status := l_return_status;

    --open cursor only for parent records as should not
    --update the parent streams till all child lines are fixed.
    --Bug# 3502142
    l_count := 0;
    --Bug# 6344223
    l_highest_split_comp_amt := 'N';

    FOR  l_split_trx_rec1 IN l_split_trx_csr1 (p_trxLine_id => p_txl_id) LOOP
      l_count := l_count + 1;
      l_split_trx_tbl1(l_count) := l_split_trx_rec1;
    END LOOP;

    IF (l_count > 0) THEN
      FOR i IN l_split_trx_tbl1.FIRST .. l_split_trx_tbl1.LAST
      LOOP

        l_split_trx_rec1 :=  l_split_trx_tbl1(i);

        IF NVL(l_split_trx_rec1.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN
           l_split_factor := (l_split_trx_rec1.split_percent/100);

           --Bug# 3502142
           --Bug# 6344223
           IF i = l_split_trx_tbl1.LAST THEN
             l_highest_split_comp_amt := 'Y';
           ELSE
             l_highest_split_comp_amt := 'N';
           END IF;
        ELSE
            --1. By comparing the cost and quantities on txlv record and txdv record find the split factor
            l_split_factor    := l_split_trx_rec1.quantity/l_split_trx_rec1.current_units;
        END IF;
        --split streams for split child lines
        Process_split_streams(p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_kle_id         => l_split_trx_rec1.target_cle_id,
                              p_split_factor   => l_split_factor,
                              p_parent_kle_id  => l_split_trx_rec1.cle_id,
                              --Bug# 3502142
                              p_txl_id         => p_txl_id,
                              --Bug# 6344223
                              p_highest_split_comp_amt => l_highest_split_comp_amt);


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 3066375:: split streams attached to linked asset lines
        OPEN l_lnk_asst_csr1(p_cle_id => l_split_trx_rec1.cle_id, p_target_cle_id => l_split_trx_rec1.target_cle_id);
        LOOP
            --Bug# 3502142
            FETCH l_lnk_asst_csr1 INTO l_lnk_cle_id, l_lnk_target_cle_id,l_lnk_top_cle_id;
            EXIT WHEN l_lnk_asst_csr1%NOTFOUND;
            Process_split_streams(p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_kle_id         => l_lnk_target_cle_id,
                                  p_split_factor   => l_split_factor,
                                  p_parent_kle_id  => l_lnk_cle_id,
                                  --Bug# 3502142
                                  p_txl_id         => p_txl_id,
                                  --Bug# 6344223
                                  p_highest_split_comp_amt => l_highest_split_comp_amt);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END LOOP;
        CLOSE l_lnk_asst_csr1;

      END LOOP;
    END IF;

     IF NVL(l_split_trx_rec1.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN
     --split asset component : Process_split_streams to historize for parent line
         Process_split_streams(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_kle_id         => l_split_trx_rec1.cle_id,
                               p_split_factor   => 0,
                               p_parent_kle_id  => l_split_trx_rec1.cle_id,
                               --Bug# 3502142
                               p_txl_id         => p_txl_id,
                               --Bug# 6344223
                               p_highest_split_comp_amt => 'N');

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --Bug# 3066375: split streams attached to linked asset lines
         OPEN l_lnk_asst_csr1(p_cle_id => l_split_trx_rec1.cle_id, p_target_cle_id => l_split_trx_rec1.target_cle_id);
         LOOP
             --Bug# 3502142
             FETCH l_lnk_asst_csr1 INTO l_lnk_cle_id, l_lnk_target_cle_id, l_lnk_top_cle_id;
             EXIT WHEN l_lnk_asst_csr1%NOTFOUND;
             Process_split_streams(p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_kle_id         => l_lnk_cle_id,
                                   p_split_factor   => 0,
                                   p_parent_kle_id  => l_lnk_cle_id,
                                   --Bug# 3502142
                                   p_txl_id         => p_txl_id,
                                   --Bug# 6344223
                                   p_highest_split_comp_amt => 'N');


             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END LOOP;
         CLOSE l_lnk_asst_csr1;

     ELSE

         --split asset case : get percent for parent split
         --
         OPEN l_split_trx_csr2 (p_trxLine_id => p_txl_id);
         FETCH l_split_trx_csr2 INTO l_split_trx_rec2;
         IF l_split_trx_csr2%NOTFOUND THEN
             NULL;
         ELSE
             --split streams for split parent
             l_split_factor    := (l_split_trx_rec2.quantity/l_split_trx_rec2.current_units);

             Process_split_streams(p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_kle_id         => l_split_trx_rec2.target_cle_id,
                                   p_split_factor   => l_split_factor,
                                   p_parent_kle_id  => l_split_trx_rec2.cle_id,
                                   --Bug# 3502142
                                   p_txl_id         => p_txl_id,
                                   --Bug# 6344223
                                   p_highest_split_comp_amt => 'N');


             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --Bug# 3066375: split streams attached to linked asset lines
             OPEN l_lnk_asst_csr2(p_cle_id => l_split_trx_rec2.cle_id, p_target_cle_id => l_split_trx_rec2.target_cle_id);
             LOOP
                 --Bug# 3502142
                 FETCH l_lnk_asst_csr2 INTO l_lnk_cle_id, l_lnk_target_cle_id,l_lnk_top_cle_id;
                 EXIT WHEN l_lnk_asst_csr2%NOTFOUND;
                 Process_split_streams(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_kle_id         => l_lnk_target_cle_id,
                                       p_split_factor   => l_split_factor,
                                       p_parent_kle_id  => l_lnk_cle_id,
                                       --Bug# 3502142
                                       p_txl_id         => p_txl_id,
                                       --Bug# 6344223
                                       p_highest_split_comp_amt => 'N');

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             END LOOP;
             CLOSE l_lnk_asst_csr2;

         END IF;
         CLOSE l_split_trx_csr2;

         NULL;
    END IF;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

    IF l_split_trx_csr1%ISOPEN THEN
        CLOSE l_split_trx_csr1;
    END IF;

    IF l_split_trx_csr2%ISOPEN THEN
        CLOSE l_split_trx_csr2;
    END IF;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

    IF l_split_trx_csr1%ISOPEN THEN
        CLOSE l_split_trx_csr1;
    END IF;

    IF l_split_trx_csr2%ISOPEN THEN
        CLOSE l_split_trx_csr2;
    END IF;

    IF l_lnk_asst_csr1%ISOPEN THEN
        CLOSE l_lnk_asst_csr1;
    END IF;

    IF l_lnk_asst_csr2%ISOPEN THEN
        CLOSE l_lnk_asst_csr2;
    END IF;

    WHEN OTHERS THEN

    IF l_split_trx_csr1%ISOPEN THEN
        CLOSE l_split_trx_csr1;
    END IF;

    IF l_split_trx_csr2%ISOPEN THEN
        CLOSE l_split_trx_csr2;
    END IF;

    IF l_lnk_asst_csr1%ISOPEN THEN
        CLOSE l_lnk_asst_csr1;
    END IF;

    IF l_lnk_asst_csr2%ISOPEN THEN
        CLOSE l_lnk_asst_csr2;
    END IF;

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END Split_Streams;
--Bug #2648280 End

---------------
--Bug# 2994971
---------------
  PROCEDURE populate_insurance_category(p_api_version   IN NUMBER,
                                        p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_msg_count     OUT NOCOPY NUMBER,
                                        x_msg_data      OUT NOCOPY VARCHAR2,
                                        p_cle_id        IN  NUMBER,
                                        p_inv_item_id   IN  NUMBER,
                                        p_inv_org_id    IN  NUMBER) IS

  l_api_name   CONSTANT VARCHAR2(30) := 'POPULATE_INS_CATEGORY';

  --cursor to get asset category
  CURSOR l_msi_csr(p_inv_item_id IN NUMBER,
                   p_inv_org_id  IN NUMBER) IS
  SELECT msi.asset_category_id
  FROM   mtl_system_items msi
  WHERE  msi.organization_id   = p_inv_org_id
  AND    msi.inventory_item_id = p_inv_item_id;

  l_asset_category_id mtl_system_items.asset_category_id%TYPE DEFAULT NULL;
  l_clev_rec  okl_okc_migration_pvt.clev_rec_type;
  l_klev_rec  okl_contract_pub.klev_rec_type;
  lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;
  lx_klev_rec  okl_contract_pub.klev_rec_type;


  BEGIN

    x_return_status          := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --fetch asset category
    l_asset_category_id := NULL;
    OPEN l_msi_csr (p_inv_item_id => p_inv_item_id,
                    p_inv_org_id  => p_inv_org_id);
    FETCH l_msi_csr INTO l_asset_category_id;
    IF l_msi_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE l_msi_csr;


    l_clev_rec.id := p_cle_id;
    l_klev_rec.id := p_cle_id;
    l_klev_rec.item_insurance_category := l_asset_category_id;

    okl_contract_pub.update_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_clev_rec      => l_clev_rec,
                         p_klev_rec      => l_klev_rec,
                         x_clev_rec      => lx_clev_rec,
                         x_klev_rec      => lx_klev_rec
                         );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF l_msi_csr%ISOPEN THEN
       CLOSE l_msi_csr;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF l_msi_csr%ISOPEN THEN
       CLOSE l_msi_csr;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    IF l_msi_csr%ISOPEN THEN
       CLOSE l_msi_csr;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END POPULATE_INSURANCE_CATEGORY;
-------------------
--Bug# 2994971
------------------
--------------------------------------------------------------------------------
--Procedure to adjust the quantities on copied split lines
--modified for Bug# 2648280 - null amounts to remain null on copied lines
--------------------------------------------------------------------------------
PROCEDURE Adjust_Split_Lines(
             p_api_version    IN  NUMBER,
             p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER,
             x_msg_data       OUT NOCOPY VARCHAR2,
             p_cle_id         IN  NUMBER, --id of the new top line after copy or parent top line
             p_parent_line_id IN  NUMBER, --parent top line id which is split
             p_txdv_rec       IN  txdv_rec_type,
             p_txlv_rec       IN  txlv_rec_type,
             --Bug# 3502142
             p_round_split_comp_amt IN VARCHAR2 DEFAULT 'N') IS

l_return_status    VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name         CONSTANT VARCHAR2(30) := 'ADJUST_SPLIT_LINES';
l_api_version      CONSTANT NUMBER := 1.0;

l_parent_cost      NUMBER;
l_parent_quantity  NUMBER;
l_child_cost       NUMBER;
l_child_quantity   NUMBER;
l_split_factor     NUMBER;
l_no_data_found    BOOLEAN;
l_cimv_rec         cimv_rec_type;
l_cimv_rec_out     cimv_rec_type;
lupd_cimv_rec      cimv_rec_type;
l_klev_rec         klev_rec_type;
l_klev_rec_out     klev_rec_type;
l_clev_rec         clev_rec_type;
l_clev_rec_out     clev_rec_type;


l_lnk_klev_rec klev_rec_type;
l_lnk_clev_rec clev_rec_type;
l_lnk_klev_old_rec klev_rec_type;
l_lnk_clev_old_rec clev_rec_type;

lx_lnk_klev_rec klev_rec_type;
lx_lnk_clev_rec clev_rec_type;
lx_lnk_klev_old_rec klev_rec_type;
lx_lnk_clev_old_rec clev_rec_type;

l_lnk_cimv_rec  cimv_rec_type;
lx_lnk_cimv_rec cimv_rec_type;
l_lnk_cimv_old_rec  cimv_rec_type;
lx_lnk_cimv_old_rec cimv_rec_type;


CURSOR c_lines(p_cle_id IN NUMBER) IS
    SELECT LEVEL,
        id,
                chr_id,
                cle_id,
                dnz_chr_id,
        lse_id
    FROM         okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_cle_id;

CURSOR c_lty_code(p_lse_id IN NUMBER) IS
    SELECT lty_code
    FROM   okc_line_styles_b
    WHERE  id = p_lse_id;

--Bug# 3897490 : modified cursor to join to SLH row
--Bug# 3066375 : modified cursor
CURSOR l_sll_cur (p_cle_id IN NUMBER) IS
SELECT rul.id                         sll_id,
       rul.jtot_object1_code,
       rul.object1_id1,
       rul.object1_id2,
       rul.jtot_object2_code,
       rul.object2_id2,
       --nvl(rul.Rule_information6,'0') amount_sll,
       rul.Rule_information6           amount_sll,
       rul.object2_id1                slh_id,
       rul.rule_information1,
       rul.rule_information2,
       rul.rule_information3,
       rul.rule_information4,
       rul.rule_information5,
       rul.rule_information7,
       rul.rule_information8 amount_stub,
       rul.rule_information9,
       rul.rule_information10,
       rul.rule_information11,
       rul.rule_information12,
       rul.rule_information13,
       rul.rule_information14,
       rul.rule_information15,
       rul_slh.jtot_object1_code strm_type_source,
       rul_slh.object1_id1       strm_type_id1,
       rul_slh.object1_id2       strm_type_id2,
       cleb.currency_code
FROM   okc_rules_b rul,
       okc_rule_groups_b rgp,
       okc_rules_b rul_slh,
       okc_k_lines_b cleb
--Bug# : 3124577 - 11.5.10 : Rule Migration
WHERE  rul.rule_information_category = 'LASLL'
--where  rul.rule_information_category = 'SLL'
AND    rul.rgp_id   = rgp.id
AND    rgp.rgd_code = 'LALEVL'
and    rgp.cle_id   = cleb.id
and    cleb.id      = p_cle_id
AND    rul_slh.id = rul.object2_id1
AND    rul_slh.rgp_id   = rgp.id
AND    rul_slh.rule_information_category = 'LASLH'
ORDER BY rul_slh.object1_id1;

l_sll_rec l_sll_cur%ROWTYPE;

--Bug# 3897490: SLH details are now fetched by cursor l_sll_cur
/*--Bug : 3066375
CURSOR l_slh_cur (p_rul_id IN NUMBER) IS
SELECT rul.id                slh_id,
       rul.jtot_object1_code strm_type_source,
       rul.object1_id1       strm_type_id1,
       rul.object1_id2       strm_type_id2
FROM   okc_rules_b rul
WHERE  rul.id = p_rul_id
--Bug# - 3124577: 11.5.10 :---Rule Migration
AND    rul.rule_information_category = 'LASLH';
--And    rul.rule_information_category = 'SLH';
*/

l_slh_rul_id               okc_rules_b.id%TYPE;
l_strm_type_source         okc_rules_b.jtot_object1_code%TYPE;
l_strm_type_id1            okc_rules_b.object1_id1%TYPE;
l_strm_type_id2            okc_rules_b.object1_id2%TYPE;




--Bug# 2881114 - modified cursor
CURSOR l_lnk_asst_cur (p_cle_id IN NUMBER) IS
SELECT cle.cle_id          srv_fee_line_id,
       cle.id              lnk_line_id
FROM   OKC_K_LINES_B       cle,
       OKC_LINE_STYLES_B   lse,
       OKC_STATUSES_B      sts,
       OKC_K_ITEMS         cim,
       OKC_K_LINES_B       fin_asst_line
WHERE  cle.lse_id                 = lse.id
AND    lse.lty_code               IN ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
AND    cle.dnz_chr_id             = fin_asst_line.dnz_chr_id
AND    sts.code = cle.sts_code
AND    sts.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
AND    cim.cle_id      = cle.id
AND    cim.dnz_chr_id  = cle.dnz_chr_id
AND    cim.object1_id1 = TO_CHAR(p_cle_id)
AND    cim.object1_id2 = '#'
AND    cim.jtot_object1_code = 'OKX_COVASST'
AND    cim.dnz_chr_id = fin_asst_line.dnz_chr_id
AND    fin_asst_line.id = p_cle_id;

l_srv_fee_line_id OKC_K_LINES_B.cle_id%TYPE;
l_lnk_line_id     OKC_K_LINES_B.id%TYPE;


l_level         NUMBER;
l_cle_id        NUMBER;
l_chr_id        NUMBER;
l_parent_cle_id NUMBER;
l_dnz_chr_id    NUMBER;
l_lse_id        NUMBER;
l_lty_code      VARCHAR2(30);
l_txdv_rec      txdv_rec_type;
l_txdv_rec_out  txdv_rec_type;

l_sll_id              OKC_RULES_B.ID%TYPE;
l_amount_sll          OKC_RULES_B.Rule_Information6%TYPE;
l_slh_id              OKC_RULES_B.OBJECT2_ID1%TYPE;
L_UPDATED_SLL_AMOUNT  NUMBER;
--Bug# 2757289 : For Payment stubs
l_updated_stub_amount NUMBER;

l_rulv_rec      OKL_RULE_PUB.rulv_rec_type;
l_rulv_rec_out  OKL_RULE_PUB.rulv_rec_type;

--Bug# 3066375:
l_rgpv_rec     OKL_RULE_PUB.rgpv_rec_type;
lx_rgpv_rec    OKL_RULE_PUB.rgpv_rec_type;

l_sll_rulv_rec   OKL_RULE_PUB.rulv_rec_type;
lx_sll_rulv_rec  OKL_RULE_PUB.rulv_rec_type;
l_slh_rulv_rec   OKL_RULE_PUB.rulv_rec_type;
lx_slh_rulv_rec  OKL_RULE_PUB.rulv_rec_type;

--Bug#3143522 : Subsidies enhancement
--cursor to fetch associated subsidy details
  CURSOR l_sub_csr (p_asset_cle_id IN NUMBER) IS
  SELECT
       kle_sub.subsidy_id                subsidy_id
       ,cleb_sub.id                      subsidy_cle_id
       ,clet_sub.name                    name
       ,clet_sub.item_description        description
       ,kle_sub.amount                   amount
       ,kle_sub.subsidy_override_amount  subsidy_override_amount
       ,cleb_sub.dnz_chr_id              dnz_chr_id
       ,cleb_asst.id                     asset_cle_id
       ,cplb.id                          cpl_id
       ,pov.vendor_id                    vendor_id
       ,pov.vendor_name                  vendor_name
       ,clet_asst.name                   asset_number
       ,cleb_sub.orig_system_id1         parent_sub_cle_id
  FROM
      po_vendors          pov,
      okc_k_party_roles_b cplb,
      okl_k_lines         kle_sub,
      okc_k_lines_tl      clet_sub,
      okc_k_lines_b       cleb_sub,
      okc_line_styles_b   lseb_sub,
      okc_k_lines_tl      clet_asst,
      okc_k_lines_b       cleb_asst
  WHERE
      pov.vendor_id              = cplb.object1_id1
  AND cplb.object1_id2           = '#'
  AND cplb.jtot_object1_code     = 'OKX_VENDOR'
  AND cplb.dnz_chr_id            = cleb_sub.dnz_chr_id
  AND cplb.cle_id                = cleb_sub.id
  AND cplb.chr_id                IS NULL
  AND cplb.rle_code              = 'OKL_VENDOR'
  AND kle_sub.id                 = cleb_sub.id
  AND clet_sub.id                = cleb_sub.id
  AND clet_sub.LANGUAGE          = USERENV('LANG')
  AND cleb_sub.cle_id            = cleb_asst.id
  AND cleb_sub.dnz_chr_id        = cleb_asst.dnz_chr_id
  AND cleb_sub.sts_code         <> 'ABANDONED'
  AND lseb_sub.id                = cleb_sub.lse_id
  AND lseb_sub.lty_code          = 'SUBSIDY'
  AND clet_asst.id               = cleb_asst.id
  AND clet_asst.LANGUAGE         =USERENV('LANG')
  AND cleb_asst.id               = p_asset_cle_id;

  l_sub_rec l_sub_csr%ROWTYPE;

  l_asb_rec okl_asset_subsidy_pvt.asb_rec_type;


  --cursor to select supplier invoice details to copy
  CURSOR l_sid_csr (p_cle_id IN NUMBER) IS
  SELECT
        sid.ID
        ,sid.OBJECT_VERSION_NUMBER
        ,sid.CLE_ID
        ,sid.FA_CLE_ID
        ,sid.INVOICE_NUMBER
        ,sid.DATE_INVOICED
        ,sid.DATE_DUE
        ,sid.SHIPPING_ADDRESS_ID1
        ,sid.SHIPPING_ADDRESS_ID2
        ,sid.SHIPPING_ADDRESS_CODE
        ,sid.ATTRIBUTE_CATEGORY
        ,sid.ATTRIBUTE1
        ,sid.ATTRIBUTE2
        ,sid.ATTRIBUTE3
        ,sid.ATTRIBUTE4
        ,sid.ATTRIBUTE5
        ,sid.ATTRIBUTE6
        ,sid.ATTRIBUTE7
        ,sid.ATTRIBUTE8
        ,sid.ATTRIBUTE9
        ,sid.ATTRIBUTE10
        ,sid.ATTRIBUTE11
        ,sid.ATTRIBUTE12
        ,sid.ATTRIBUTE13
        ,sid.ATTRIBUTE14
        ,sid.ATTRIBUTE15
        ,sid.CREATED_BY
        ,sid.CREATION_DATE
        ,sid.LAST_UPDATED_BY
        ,sid.LAST_UPDATE_DATE
        ,sid.LAST_UPDATE_LOGIN
        ,cleb_fa.id  fixed_asset_cle_id
  FROM  okl_supp_invoice_dtls sid,
        okc_k_lines_b         cleb_fa,
        okc_line_styles_b     lseb_fa,
        okc_k_lines_b         cleb
  WHERE sid.cle_id         = cleb.orig_system_id1
  AND   cleb_fa.cle_id     = cleb.cle_id
  AND   cleb_fa.dnz_chr_id = cleb.dnz_chr_id
  AND   lseb_fa.id         = cleb_fa.lse_id
  AND   lseb_fa.lty_code   = 'FIXED_ASSET'
  AND   cleb.id            = p_cle_id;

  l_sid_rec l_sid_csr%ROWTYPE;
  l_sidv_rec okl_supp_invoice_dtls_pub.sidv_rec_type;
  lx_sidv_rec okl_supp_invoice_dtls_pub.sidv_rec_type;
  ----------------
  --Bug# 2994971
  ---------------
  l_inv_item_id   NUMBER;
  l_inv_org_id    NUMBER;

  --Bug# 3897490
  l_strm_type_id   OKC_RULES_B.OBJECT1_ID1%TYPE;

  --Bug# 3502142
  l_rounded_amount NUMBER;

  CURSOR l_txd_csr(p_tal_id IN NUMBER,
                   p_cle_id IN NUMBER) IS
  SELECT id,
         quantity,
         split_percent
  FROM okl_txd_assets_b txd
  WHERE txd.tal_id = p_tal_id
  AND NVL(txd.target_kle_id,-1) <> p_cle_id;

  l_sll_amount  NUMBER;
  l_stub_amount NUMBER;
  l_sll_split_factor NUMBER;
  l_split_pymt NUMBER;
  l_split_pymt_sum NUMBER;

  CURSOR l_new_lnk_assts_cur (p_chr_id IN NUMBER,
                              p_cle_id IN NUMBER) IS
  SELECT cle.id
  FROM   OKC_K_LINES_B       cle
  WHERE  cle.dnz_chr_id      = p_chr_id
  AND    cle.orig_system_id1 = p_cle_id;

  l_target_kle_id NUMBER;

  CURSOR l_fa_line_csr(p_chr_id IN NUMBER,
                       p_cle_id IN NUMBER) IS
  SELECT cle.id
  FROM okc_k_lines_b cle,
       okc_line_styles_b lse
  WHERE cle.cle_id = p_cle_id
  AND   cle.dnz_chr_id = p_chr_id
  AND   cle.lse_id = lse.id
  AND   lse.lty_code = 'FIXED_ASSET';

 -- Bug# 5946411: ER
  --cursor to check the status of asset
  CURSOR l_cleb_sts_csr(pcleid IN NUMBER) IS
  SELECT cleb.sts_code sts_code
  FROM   okc_k_lines_b cleb
  WHERE  cleb.id = pcleid;
  l_cle_status okc_k_lines_b.sts_code%TYPE;
  -- Bug# 5946411: ER End

  --Bug# 6344223 : Start
   l_fa_line_id NUMBER;
  l_klev_round_out     klev_rec_type;
  l_clev_round_out     clev_rec_type;
  --Bug# 6344223 : end
BEGIN
   x_return_status := OKL_API.G_RET_STS_SUCCESS;
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
    IF NVL(p_txdv_rec.split_percent,0)  NOT IN (0,OKL_API.G_MISS_NUM) THEN
        l_split_factor := (p_txdv_rec.split_percent/100);
    ELSE
        --1. By comparing the cost and quantities on txlv record and txdv record find the split factor
        l_parent_cost     := p_txlv_rec.depreciation_cost;
        l_parent_quantity := p_txlv_rec.current_units;
        l_child_cost      := p_txdv_rec.cost;
        l_child_quantity  := p_txdv_rec.quantity;
        l_split_factor    := p_txdv_rec.quantity/p_txlv_rec.current_units;
   END IF;
  -- Bug# 5946411: ER
   -- get the status of the parent line id
    OPEN l_cleb_sts_csr(  p_txlv_rec.kle_id);
    FETCH l_cleb_sts_csr INTO l_cle_status;
    close l_cleb_sts_csr;
    --dbms_output.put_line('Adjust_split_lines--p_txlv_rec.kle_id'||p_txlv_rec.kle_id);
    --dbms_output.put_line('Status set as l_cle_status'||l_cle_status);
  -- Bug# 5946411: ER End
--2. Select split lines using connect by prior starting with top line (p_clev_id)
    OPEN c_lines(p_cle_id);
    ---For each line selected in 2
    ---2.1 depending on the line style  recalculate the amount and unit fields
    ---2.2 Call Update Line API to update the line with recalculated amounts and units
    LOOP
        FETCH c_lines INTO l_level,
                           l_cle_id,
                           l_chr_id,
                           l_parent_cle_id,
                           l_dnz_chr_id,
                           l_lse_id;
        EXIT WHEN c_lines%NOTFOUND;
        OPEN c_lty_code(l_lse_id);
        FETCH c_lty_code INTO l_lty_code;
        IF c_lty_code%NOTFOUND THEN
            --dbms_output.put_line('lty_code not found for lse_id "'||to_char(l_lse_id));
            --handle error appropriately
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                p_msg_name     => G_LTY_CODE_NOT_FOUND
                                               );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE c_lty_code;

        --Bug# 6344223 : start
        IF l_lty_code ='FIXED_ASSET' THEN
            l_fa_line_id := l_cle_id;
        END IF;
        --Bug# 6344223 : End

        --dbms_output.put_line(l_lty_code);
        --update transaction details and item links on lines
        IF l_lty_code IN ('ITEM','ADD_ITEM','FIXED_ASSET','INST_ITEM','LINK_SERV_ASSET',
                          'LINK_FEE_ASSET','LINK_USAGE_ASSET') THEN
            l_cimv_rec := get_cimv_rec(p_cle_id => l_cle_id);
            IF l_lty_code <> 'INST_ITEM' THEN
                IF NVL(p_txdv_rec.split_percent,0)  NOT IN (0,OKL_API.G_MISS_NUM) THEN
                    --number of items will remain same in case of split asset components
                    l_cimv_rec.number_of_items := l_cimv_rec.number_of_items;
                ELSE
                    l_cimv_rec.number_of_items := (l_split_factor*l_cimv_rec.number_of_items);
                END IF;
            END IF;
            IF (l_lty_code = 'FIXED_ASSET') AND (NVL(p_txdv_rec.target_kle_id,-99) <> p_txlv_rec.kle_id) THEN
                l_txdv_rec := p_txdv_rec;
                l_txdv_rec.target_kle_id := l_cle_id;
                --update txd record to indicate correct target_kle_id
                --dbms_output.put_line('before updating txd target kle_id :'||to_char(l_cle_id));
                OKL_TXD_ASSETS_PUB.update_txd_asset_def(p_api_version    => p_api_version,
                                                        p_init_msg_list  => p_init_msg_list,
                                                        x_return_status  => x_return_status,
                                                        x_msg_count      => x_msg_count,
                                                        x_msg_data       => x_msg_data,
                                                        p_adpv_rec       => l_txdv_rec,
                                                        x_adpv_rec       => l_txdv_rec_out);
                --dbms_output.put_line('target kle_id :'||l_txdv_rec_out.target_kle_id);
                --dbms_output.put_line('After updating trx details:'||x_return_status);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;

            --update the number of items on model and fa lines
            --Bug#5559502 --Modification Start
            --Update number of items for ADDON record in OKC_K_ITEMS table
            IF l_lty_code IN ('ADD_ITEM','ITEM','FIXED_ASSET') THEN
            --Bug#5559502 --Modification End
                IF (l_cimv_rec.id IS NOT NULL) OR (l_cimv_rec.id <> OKL_API.G_MISS_NUM) THEN
                        --dbms_output.put_line('cimv rec id'|| to_char(l_cimv_rec.id));
                        lupd_cimv_rec.id              := l_cimv_rec.id;
                        --dbms_output.put_line('Split Factor '|| to_char(l_split_factor));
                        --dbms_output.put_line('Split Factor '|| to_char(p_txlv_rec.current_units));
                        IF NVL(p_txdv_rec.split_percent,0)  NOT IN (0,OKL_API.G_MISS_NUM) THEN
                            --number of items will remain same in case of split asset components
                            lupd_cimv_rec.number_of_items := p_txlv_rec.current_units;
                            --if it is split asset component update the inventory item on model line
                            IF l_lty_code = ('ITEM') THEN
                                lupd_cimv_rec.object1_id1       := TO_CHAR(p_txdv_rec.inventory_item_id);
                                --dbms_output.put_line('object1_id1 '||lupd_cimv_rec.object1_id1);
                                lupd_cimv_rec.object1_id2       := l_cimv_rec.object1_id2;
                                --dbms_output.put_line('object1_id2 '||lupd_cimv_rec.object1_id2);
                                lupd_cimv_rec.jtot_object1_code := l_cimv_rec.jtot_object1_code;
                                --dbms_output.put_line('object_code '||lupd_cimv_rec.jtot_object1_code);
                                --dbms_output.put_line('ITEM_ID '||to_char(lupd_cimv_rec.id));

                                ---------------
                                --Bug# 2994971
                                ---------------
                                IF NVL(lupd_cimv_rec.object1_id1,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR AND
                                   NVL(lupd_cimv_rec.object1_id2,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR THEN

                                    --Bug# 3438811 :
                                    l_inv_item_id  := TO_NUMBER(lupd_cimv_rec.object1_id1);
                                    l_inv_org_id   := TO_NUMBER(lupd_cimv_rec.object1_id2);
                                    --l_inv_item_id  := to_char(lupd_cimv_rec.object1_id1);
                                    --l_inv_org_id   := to_char(lupd_cimv_rec.object1_id2);

                                    populate_insurance_category(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_cle_id        => l_parent_cle_id,
                                       p_inv_item_id   => l_inv_item_id,
                                       p_inv_org_id    => l_inv_org_id);
                                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                       RAISE OKL_API.G_EXCEPTION_ERROR;
                                   END IF;
                               END IF;
                               ---------------
                               --Bug# 2994971
                               ---------------

                            ELSE
                                lupd_cimv_rec.object1_id1       := l_cimv_rec.object1_id1;
                                --dbms_output.put_line('object1_id1 '||lupd_cimv_rec.object1_id1);
                                lupd_cimv_rec.object1_id2       := l_cimv_rec.object1_id2;
                                --dbms_output.put_line('object1_id2 '||lupd_cimv_rec.object1_id2);
                                lupd_cimv_rec.jtot_object1_code := l_cimv_rec.jtot_object1_code;
                                --dbms_output.put_line('object_code '||lupd_cimv_rec.jtot_object1_code);
                                --dbms_output.put_line('ITEM_ID '||to_char(lupd_cimv_rec.id));
                            END IF;
                        ELSE
                            --lupd_cimv_rec.number_of_items := (l_split_factor*nvl(p_txlv_rec.current_units,0));
                            --Bug#2761799 - did a round as whole number of units may not be found as split factor
                            --is being calculated earlier - so rounding issues
                            --lupd_cimv_rec.number_of_items := (l_split_factor*p_txlv_rec.current_units);
                            lupd_cimv_rec.number_of_items := ROUND((l_split_factor*p_txlv_rec.current_units));
                        END IF;

                            --dbms_output.put_line('Number of items'|| to_char(lupd_cimv_rec.number_of_items));
                            --update the item record
                        OKL_OKC_MIGRATION_PVT.update_contract_item( p_api_version       => p_api_version,
                                                                    p_init_msg_list     => p_init_msg_list,
                                                                    x_return_status     => x_return_status,
                                                                    x_msg_count     => x_msg_count,
                                                                    x_msg_data      => x_msg_data,
                                                                    p_cimv_rec      => lupd_cimv_rec,
                                                                    x_cimv_rec      => l_cimv_rec_out);
                        --dbms_output.put_line('After updating contract item to nulls :'||x_return_status);
                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                     --End If;
                END IF;

         END IF;


        END IF;

        l_klev_rec := get_klev_rec(p_cle_id => l_cle_id);
        l_clev_rec := get_clev_rec(p_cle_id => l_cle_id);

   --Bug# 6344223 : Start
     IF (NVL(p_txdv_rec.target_kle_id,-99) = p_txlv_rec.kle_id)
        OR p_round_split_comp_amt = 'Y' THEN
        --get the rounding logic
         get_split_round_amount(
                              p_api_version   =>p_api_version
                             ,p_init_msg_list =>p_init_msg_list
                             ,x_return_status =>x_return_status
                             ,x_msg_count     =>x_msg_count
                             ,x_msg_data      =>x_msg_data
                             ,p_txl_id        =>p_txlv_rec.id
                             ,p_split_factor  =>l_split_factor
                             ,p_klev_rec      =>l_klev_rec
                             ,p_clev_rec      =>l_clev_rec
                             ,x_klev_rec      =>l_klev_round_out
                             ,x_clev_rec      =>l_clev_round_out
                             );
          --dbms_output.put_line('After get_split_round_amount :'||x_return_status);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_klev_rec :=l_klev_round_out;
          l_clev_rec :=l_clev_round_out;

     ELSE
    --Bug# 6344223 : End
        --
        l_klev_rec.ESTIMATED_OEC := (l_split_factor * l_klev_rec.ESTIMATED_OEC);
        l_klev_rec.LAO_AMOUNT    := (l_split_factor * l_klev_rec.LAO_AMOUNT);
        l_klev_rec.FEE_CHARGE    := (l_split_factor * l_klev_rec.FEE_CHARGE);
        l_klev_rec.INITIAL_DIRECT_COST := (l_split_factor * l_klev_rec.INITIAL_DIRECT_COST);
        l_klev_rec.AMOUNT_STAKE := (l_split_factor * l_klev_rec.AMOUNT_STAKE);
        l_klev_rec.LRV_AMOUNT := (l_split_factor * l_klev_rec.LRV_AMOUNT);
        l_klev_rec.COVERAGE := (l_split_factor * l_klev_rec.COVERAGE);
        l_klev_rec.CAPITAL_REDUCTION := (l_split_factor * l_klev_rec.CAPITAL_REDUCTION);
        l_klev_rec.VENDOR_ADVANCE_PAID := (l_split_factor * l_klev_rec.VENDOR_ADVANCE_PAID);
        l_klev_rec.TRADEIN_AMOUNT := (l_split_factor * l_klev_rec.TRADEIN_AMOUNT);
        l_klev_rec.BOND_EQUIVALENT_YIELD :=  (l_split_factor * l_klev_rec.BOND_EQUIVALENT_YIELD);
        l_klev_rec.TERMINATION_PURCHASE_AMOUNT :=(l_split_factor * l_klev_rec.TERMINATION_PURCHASE_AMOUNT);
        l_klev_rec.REFINANCE_AMOUNT := (l_split_factor * l_klev_rec.REFINANCE_AMOUNT);
        l_klev_rec.REMARKETED_AMOUNT := (l_split_factor * l_klev_rec.REMARKETED_AMOUNT);
        l_klev_rec.REMARKET_MARGIN :=  (l_split_factor * l_klev_rec.REMARKET_MARGIN);
        l_klev_rec.REPURCHASED_AMOUNT := (l_split_factor * l_klev_rec.REPURCHASED_AMOUNT);
        l_klev_rec.RESIDUAL_VALUE := (l_split_factor * l_klev_rec.RESIDUAL_VALUE);
        l_klev_rec.APPRAISAL_VALUE := (l_split_factor * l_klev_rec.APPRAISAL_VALUE);
        l_klev_rec.GAIN_LOSS := (l_split_factor * l_klev_rec.GAIN_LOSS);
        l_klev_rec.FLOOR_AMOUNT := (l_split_factor * l_klev_rec.FLOOR_AMOUNT);
        l_klev_rec.TRACKED_RESIDUAL := (l_split_factor * l_klev_rec.TRACKED_RESIDUAL);
        l_klev_rec.AMOUNT := (l_split_factor * l_klev_rec.AMOUNT);
        l_klev_rec.OEC := (l_split_factor * l_klev_rec.OEC);
        l_klev_rec.CAPITAL_AMOUNT := (l_split_factor * l_klev_rec.CAPITAL_AMOUNT);
        l_klev_rec.RESIDUAL_GRNTY_AMOUNT := (l_split_factor * l_klev_rec.RESIDUAL_GRNTY_AMOUNT);
        l_klev_rec.RVI_PREMIUM := (l_split_factor * l_klev_rec.RVI_PREMIUM);
        l_klev_rec.CAPITALIZED_INTEREST := (l_split_factor * l_klev_rec.CAPITALIZED_INTEREST);
        --
        --Bug#3143522 : Subsidies additional columns
        l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT := (l_split_factor * l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT);
        --Bug#3143522 : Subsidy additional columns

        --Bug#4631549 :
        l_klev_rec.Expected_Asset_Cost := (l_split_factor * l_klev_rec.Expected_Asset_Cost);
        --Bug# 4631549

        IF (NVL(p_txdv_rec.target_kle_id,-99) <> p_txlv_rec.kle_id) THEN
            l_clev_rec.ORIG_SYSTEM_SOURCE_CODE := 'OKL_SPLIT';
        END IF;
        --Bug# 5946411: ER
        --set the status same as that of the parent line
        --l_clev_rec.STS_CODE                := 'BOOKED';
        l_clev_rec.STS_CODE:=l_cle_status;
         --Bug# 5946411: ER End

        --price unit to be split only for split into components
        IF NVL(p_txdv_rec.split_percent,0)  IN (0,OKL_API.G_MISS_NUM)
        THEN
            NULL;
        ELSIF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN
            --
            l_clev_rec.price_unit              := (l_split_factor * l_clev_rec.price_unit);
            l_clev_rec.price_negotiated        := (l_split_factor * l_clev_rec.price_negotiated);
            l_clev_rec.price_negotiated_renewed        := (l_split_factor * l_clev_rec.price_negotiated_renewed);

        END IF;
     --Bug# 6344223
     END IF;
        --update asset number on top line
        IF l_lty_code IN ('FREE_FORM1','FIXED_ASSET') THEN
            l_clev_rec.name             := p_txdv_rec.asset_number;
            l_clev_rec.item_description := p_txdv_rec.description;
        END IF;

        --Call api to update line
        OKL_CONTRACT_PUB.update_contract_line(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_clev_rec       => l_clev_rec,
                         p_klev_rec       => l_klev_rec,
                         x_clev_rec       => l_clev_rec_out,
                         x_klev_rec       => l_klev_rec_out);
        --dbms_output.put_line('After updating contract line :'||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -------------------------------------------------------
        --Bug# 3143522: subsidies - Validate all associated subsidies
        ------------------------------------------------------
        IF l_lty_code = 'FREE_FORM1' THEN
            --check if any subsidies exist and are valid
            OPEN l_sub_csr (p_asset_cle_id => l_cle_id);
            LOOP
                FETCH l_sub_csr INTO l_sub_rec;
                EXIT WHEN l_sub_csr%NOTFOUND;
                --check whether subsidy is valid for the asset :
                l_asb_rec.SUBSIDY_ID              :=  l_sub_rec.SUBSIDY_ID;
                l_asb_rec.SUBSIDY_CLE_ID          :=  l_sub_rec.SUBSIDY_CLE_ID;
                l_asb_rec.NAME                    :=  l_sub_rec.NAME;
                l_asb_rec.DESCRIPTION             :=  l_sub_rec.DESCRIPTION;
                l_asb_rec.AMOUNT                  :=  l_sub_rec.AMOUNT;
                l_asb_rec.SUBSIDY_OVERRIDE_AMOUNT :=  l_sub_rec.SUBSIDY_OVERRIDE_AMOUNT;
                l_asb_rec.DNZ_CHR_ID              :=  l_sub_rec.DNZ_CHR_ID;
                l_asb_rec.ASSET_CLE_ID            :=  l_sub_rec.ASSET_CLE_ID;
                l_asb_rec.CPL_ID                  :=  l_sub_rec.CPL_ID;
                l_asb_rec.VENDOR_ID               :=  l_sub_rec.VENDOR_ID;
                l_asb_rec.VENDOR_NAME             :=  l_sub_rec.VENDOR_NAME;

                --call api to validate asset subsidy
                okl_asset_subsidy_pvt.validate_asset_subsidy(
                                      p_api_version    => p_api_version,
                                      p_init_msg_list  => p_init_msg_list,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_asb_rec        => l_asb_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

               /*------------------Commented as this will be done as part of copy lines now
                ------------------------------------------
                --create party payment details from parent
                ------------------------------------------
                 ---------------------------------Commented as this being done in copy lines base proc*/
             END LOOP;
             CLOSE l_sub_csr;
         END IF;
         ------------------------------------------------------
         --Bug# 3143522 : End Subsidies
         ------------------------------------------------------
         ------------------------------------------------------
         --to_copy supplier invoice details linked to model line
         ------------------------------------------------------
         IF l_lty_code = 'ITEM' THEN
             IF (NVL(p_txdv_rec.target_kle_id,-99) <> p_txlv_rec.kle_id) THEN --is new line
                 OPEN l_sid_csr(p_cle_id => l_cle_id);
                 FETCH l_sid_csr INTO l_sid_rec;
                 IF l_sid_csr%NOTFOUND THEN
                    NULL;
                 ELSE
                     l_sidv_rec.CLE_ID                :=  l_cle_id;
                     l_sidv_rec.FA_CLE_ID             :=  l_sid_rec.fixed_asset_cle_id;
                     l_sidv_rec.INVOICE_NUMBER        :=  l_sid_rec.invoice_number;
                     l_sidv_rec.DATE_INVOICED         :=  l_sid_rec.date_invoiced;
                     l_sidv_rec.DATE_DUE              :=  l_sid_rec.date_due;
                     l_sidv_rec.SHIPPING_ADDRESS_ID1  :=  l_sid_rec.shipping_address_id1;
                     l_sidv_rec.SHIPPING_ADDRESS_ID2  :=  l_sid_rec.shipping_address_id2;
                     l_sidv_rec.SHIPPING_ADDRESS_CODE :=  l_sid_rec.shipping_address_code;
                     l_sidv_rec.ATTRIBUTE_CATEGORY    :=  l_sid_rec.attribute_category;
                     l_sidv_rec.ATTRIBUTE1            :=  l_sid_rec.attribute1;
                     l_sidv_rec.ATTRIBUTE2            :=  l_sid_rec.attribute2;
                     l_sidv_rec.ATTRIBUTE3            :=  l_sid_rec.attribute3;
                     l_sidv_rec.ATTRIBUTE4            :=  l_sid_rec.attribute4;
                     l_sidv_rec.ATTRIBUTE5            :=  l_sid_rec.attribute5;
                     l_sidv_rec.ATTRIBUTE6            :=  l_sid_rec.attribute6;
                     l_sidv_rec.ATTRIBUTE7            :=  l_sid_rec.attribute7;
                     l_sidv_rec.ATTRIBUTE8            :=  l_sid_rec.attribute8;
                     l_sidv_rec.ATTRIBUTE9            :=  l_sid_rec.attribute9;
                     l_sidv_rec.ATTRIBUTE10           :=  l_sid_rec.attribute10;
                     l_sidv_rec.ATTRIBUTE11           :=  l_sid_rec.attribute11;
                     l_sidv_rec.ATTRIBUTE12           :=  l_sid_rec.attribute12;
                     l_sidv_rec.ATTRIBUTE13           :=  l_sid_rec.attribute13;
                     l_sidv_rec.ATTRIBUTE14           :=  l_sid_rec.attribute14;
                     l_sidv_rec.ATTRIBUTE15           :=  l_sid_rec.attribute15;

                     --------------------------------------------
                     --call api to create supplier invoice dtls
                     -------------------------------------------
                     OKL_SUPP_INVOICE_DTLS_PUB.Create_sup_inv_dtls
                                    (p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_sidv_rec      => l_sidv_rec,
                                     x_sidv_rec      => lx_sidv_rec);

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                 END IF;
             END IF;
         END IF;

    END LOOP;
    CLOSE c_lines;

    --after completing adjustment on lines
    --adjust rule amounts SLL/SLH

    --Bug# 3502142
    IF (NVL(p_txdv_rec.target_kle_id,-1) <> p_txlv_rec.kle_id) AND
       (p_round_split_comp_amt = 'N') THEN -- child line

      OPEN l_sll_cur(p_cle_id => p_cle_id);
      LOOP
        l_updated_sll_amount := NULL;
        l_updated_stub_amount := NULL;
        FETCH l_sll_cur INTO l_sll_rec;
        EXIT WHEN l_sll_cur%NOTFOUND;

        l_updated_sll_amount := TO_NUMBER(l_sll_rec.amount_sll)*l_split_factor;
        --Bug# 4028371
        --Bug# 3502142: Use Streams Rounding Option
        okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_updated_sll_amount,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_updated_sll_amount := l_rounded_amount;

        --Bug# 2757289 :enhancement for stub payments
        l_updated_stub_amount := TO_NUMBER(l_sll_rec.amount_stub)*l_split_factor;
        --Bug# 4028371
        --Bug# 3502142: Use Streams Rounding Option
        okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_updated_stub_amount,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_updated_stub_amount := l_rounded_amount;

        --update the rule record
        l_rulv_rec.id                 := l_sll_rec.sll_id;
        IF NVL(l_updated_sll_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information6  := l_updated_sll_amount;
        ELSIF NVL(l_updated_sll_amount,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information6 := NULL;
        END IF;
        --Bug# 2757289 :enhancement for stub payments
        IF NVL(l_updated_stub_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information8  := l_updated_stub_amount;
        ELSIF NVL(l_updated_stub_amount,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information8 := NULL;
        END IF;

        OKL_RULE_PUB.update_rule(
                      p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_rulv_rec       => l_rulv_rec,
                      x_rulv_rec       => l_rulv_rec_out);
        --dbms_output.put_line('After updating payments :'||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
      CLOSE l_sll_cur;

    ELSE -- parent line

      -- Apply Rounding Difference to
      -- Parent Line for Split assets into Units
      -- Largest asset cost for Split assets into Components

        OPEN l_sll_cur(p_cle_id => p_cle_id);
        LOOP
          FETCH l_sll_cur INTO l_sll_rec;
          EXIT WHEN l_sll_cur%NOTFOUND;

          l_sll_amount := TO_NUMBER(l_sll_rec.amount_sll);
          l_stub_amount := TO_NUMBER(l_sll_rec.amount_stub);

          l_split_pymt_sum := 0;

          -- Split into units
          IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN
            l_target_kle_id := p_txlv_rec.kle_id;

          -- Split into components
          ELSE
            open l_fa_line_csr(p_chr_id => p_txlv_rec.dnz_khr_id
                              ,p_cle_id => p_cle_id);
            fetch l_fa_line_csr into l_target_kle_id;
            close l_fa_line_csr;
          END IF;

          FOR l_txd_rec in l_txd_csr(p_tal_id  => p_txlv_rec.id
                                    ,p_cle_id  => l_target_kle_id)
          LOOP

            IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN
              l_sll_split_factor := l_txd_rec.quantity/p_txlv_rec.current_units;
            ELSE
              l_sll_split_factor := l_txd_rec.split_percent/100;
            END IF;

            IF NVL(l_sll_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
              l_split_pymt := l_sll_amount * l_sll_split_factor;
            ELSIF NVL(l_stub_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
              l_split_pymt := l_stub_amount * l_sll_split_factor;
            END IF;

            okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_split_pymt,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_split_pymt_sum := l_split_pymt_sum + l_rounded_amount;

          END LOOP;

          --update the rule record
          l_rulv_rec.id                 := l_sll_rec.sll_id;
          IF NVL(l_sll_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information6  := TO_CHAR(l_sll_amount - l_split_pymt_sum);
          ELSIF NVL(l_sll_amount,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information6 := NULL;
          END IF;
          --Bug# 2757289 :enhancement for stub payments
          IF NVL(l_stub_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information8  := TO_CHAR(l_stub_amount - l_split_pymt_sum);
          ELSIF NVL(l_stub_amount,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
            l_rulv_rec.rule_information8 := NULL;
          END IF;

          OKL_RULE_PUB.update_rule(
                      p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_rulv_rec       => l_rulv_rec,
                      x_rulv_rec       => l_rulv_rec_out);
          --dbms_output.put_line('After updating payments :'||x_return_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END LOOP;
        CLOSE l_sll_cur;
    END IF;

    --Bug Fix# 2881114 :
    --find out if the parent top line is linked to an asset/fee line
    -- Bug# 3502142
    IF (NVL(p_txdv_rec.target_kle_id,-1) <> p_txlv_rec.kle_id) AND
       (p_round_split_comp_amt = 'N') THEN -- it is a child line

        --get if top line is linked to an asset
        OPEN l_lnk_asst_cur (p_cle_id => p_parent_line_id);
        LOOP
            FETCH l_lnk_asst_cur INTO
                  l_srv_fee_line_id,
                  l_lnk_line_id;
            EXIT WHEN l_lnk_asst_cur%NOTFOUND;
            --create new linked line and update old line
            l_lnk_klev_rec := get_klev_rec(p_cle_id        => l_lnk_line_id,
                                           x_no_data_found => l_no_data_found);
            IF l_no_data_found THEN
                NULL;
                --raise appropriate error
            ELSE
            --End If;
                l_lnk_klev_old_rec := l_lnk_klev_rec;

                l_lnk_clev_rec := get_clev_rec(p_cle_id        => l_lnk_line_id,
                                               x_no_data_found => l_no_data_found);
                IF l_no_data_found THEN
                    NULL;
                    --raise appropriate error
                ELSE
                --End If;
                    l_lnk_clev_old_rec := l_lnk_clev_rec;
                    --adjusted entries
                    --
                    l_lnk_klev_rec.ESTIMATED_OEC := (l_split_factor * l_lnk_klev_rec.ESTIMATED_OEC);
                    l_lnk_klev_rec.LAO_AMOUNT    := (l_split_factor * l_lnk_klev_rec.LAO_AMOUNT);
                    l_lnk_klev_rec.FEE_CHARGE    := (l_split_factor * l_lnk_klev_rec.FEE_CHARGE);
                    l_lnk_klev_rec.INITIAL_DIRECT_COST := (l_split_factor * l_lnk_klev_rec.INITIAL_DIRECT_COST);
                    l_lnk_klev_rec.AMOUNT_STAKE := (l_split_factor * l_lnk_klev_rec.AMOUNT_STAKE);
                    l_lnk_klev_rec.LRV_AMOUNT := (l_split_factor * l_lnk_klev_rec.LRV_AMOUNT);
                    l_lnk_klev_rec.COVERAGE := (l_split_factor * l_lnk_klev_rec.COVERAGE);
                    l_lnk_klev_rec.CAPITAL_REDUCTION := (l_split_factor * l_lnk_klev_rec.CAPITAL_REDUCTION);
                    l_lnk_klev_rec.VENDOR_ADVANCE_PAID := (l_split_factor * l_lnk_klev_rec.VENDOR_ADVANCE_PAID);
                    l_lnk_klev_rec.TRADEIN_AMOUNT := (l_split_factor * l_lnk_klev_rec.TRADEIN_AMOUNT);
                    l_lnk_klev_rec.BOND_EQUIVALENT_YIELD :=  (l_split_factor * l_lnk_klev_rec.BOND_EQUIVALENT_YIELD);
                    l_lnk_klev_rec.TERMINATION_PURCHASE_AMOUNT :=(l_split_factor * l_lnk_klev_rec.TERMINATION_PURCHASE_AMOUNT);
                    l_lnk_klev_rec.REFINANCE_AMOUNT := (l_split_factor * l_lnk_klev_rec.REFINANCE_AMOUNT);
                    l_lnk_klev_rec.REMARKETED_AMOUNT := (l_split_factor * l_lnk_klev_rec.REMARKETED_AMOUNT);
                    l_lnk_klev_rec.REMARKET_MARGIN :=  (l_split_factor * l_lnk_klev_rec.REMARKET_MARGIN);
                    l_lnk_klev_rec.REPURCHASED_AMOUNT := (l_split_factor * l_lnk_klev_rec.REPURCHASED_AMOUNT);
                    l_lnk_klev_rec.RESIDUAL_VALUE := (l_split_factor * l_lnk_klev_rec.RESIDUAL_VALUE);
                    l_lnk_klev_rec.APPRAISAL_VALUE := (l_split_factor * l_lnk_klev_rec.APPRAISAL_VALUE);
                    l_lnk_klev_rec.GAIN_LOSS := (l_split_factor * l_lnk_klev_rec.GAIN_LOSS);
                    l_lnk_klev_rec.FLOOR_AMOUNT := (l_split_factor * l_lnk_klev_rec.FLOOR_AMOUNT);
                    l_lnk_klev_rec.TRACKED_RESIDUAL := (l_split_factor * l_lnk_klev_rec.TRACKED_RESIDUAL);
                    l_lnk_klev_rec.AMOUNT := (l_split_factor * l_lnk_klev_rec.AMOUNT);
                    l_lnk_klev_rec.OEC := (l_split_factor * l_lnk_klev_rec.OEC);
                    l_lnk_klev_rec.CAPITAL_AMOUNT := (l_split_factor * l_lnk_klev_rec.CAPITAL_AMOUNT);
                    l_lnk_klev_rec.RESIDUAL_GRNTY_AMOUNT := (l_split_factor * l_lnk_klev_rec.RESIDUAL_GRNTY_AMOUNT);
                    l_lnk_klev_rec.RVI_PREMIUM := (l_split_factor * l_lnk_klev_rec.RVI_PREMIUM);
                    --
                    --Bug# 3143522 : Subsidy New Columns
                    ---
                    l_lnk_klev_rec.SUBSIDY_OVERRIDE_AMOUNT := (l_split_factor * l_lnk_klev_rec.SUBSIDY_OVERRIDE_AMOUNT);
                    --
                    --price unit to be split only for split into components
                    --old record to be adjusted only for normal split asset
                    IF NVL(p_txdv_rec.split_percent,0)  IN (0,OKL_API.G_MISS_NUM)
                    THEN
                        NULL;
                    ELSIF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN
                        --
                        l_lnk_clev_rec.price_unit := (l_split_factor * l_lnk_clev_rec.price_unit);
                        l_lnk_clev_rec.price_negotiated := (l_split_factor * l_lnk_clev_rec.price_negotiated);
                        l_lnk_clev_rec.price_negotiated_renewed := (l_split_factor * l_lnk_clev_rec.price_negotiated_renewed);
                        --make the old line as 'ABANDONED'
                        --l_lnk_clev_old_rec.sts_code := 'ABANDONED';
                    END IF;
                    l_lnk_clev_rec.ORIG_SYSTEM_ID1       := l_lnk_clev_rec.ID;
                    l_lnk_clev_rec.ID                    := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.OBJECT_VERSION_NUMBER := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.SFWT_FLAG             := OKL_API.G_MISS_CHAR;
                    l_lnk_clev_rec.LINE_NUMBER           := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.DISPLAY_SEQUENCE      := l_clev_rec.DISPLAY_SEQUENCE + 1;
                    --l_lnk_clev_rec.START_DATE            :=  sysdate;
                    --l_clev_rec.END_DATE         :=
                    l_lnk_clev_rec.ORIG_SYSTEM_SOURCE_CODE := 'OKL_SPLIT';
                    l_lnk_clev_rec.CREATED_BY        := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.CREATION_DATE     := OKL_API.G_MISS_DATE;
                    l_lnk_clev_rec.LAST_UPDATED_BY   := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.LAST_UPDATE_DATE  := OKL_API.G_MISS_DATE;
                    l_lnk_clev_rec.LAST_UPDATE_LOGIN := OKL_API.G_MISS_NUM;
                     --Bug# 5946411: ER
                    --set the status same as that of the parent line
                    --make new line as BOOKED
                    --l_lnk_clev_rec.STS_CODE          := 'BOOKED';
                    l_lnk_clev_rec.STS_CODE :=l_cle_status;
                    --dbms_output.put_line('Status set as l_lnk_clev_rec'||l_lnk_clev_rec.STS_CODE);
                     --Bug# 5946411: ER End
                    --bug# 3066375
                    l_lnk_clev_rec.name              := l_txdv_rec.asset_number;
                    l_lnk_clev_rec.item_description  := l_txdv_rec.description;
                    ----
                    l_lnk_klev_rec.ID := OKL_API.G_MISS_NUM;
                    l_lnk_klev_rec.OBJECT_VERSION_NUMBER := OKL_API.G_MISS_NUM;
                    l_lnk_klev_rec.CREATED_BY := OKL_API.G_MISS_NUM;
                    l_lnk_klev_rec.CREATION_DATE := OKL_API.G_MISS_DATE;
                    l_klev_rec.LAST_UPDATED_BY := OKL_API.G_MISS_NUM;
                    l_klev_rec.LAST_UPDATE_DATE := OKL_API.G_MISS_DATE;
                    l_klev_rec.LAST_UPDATE_LOGIN := OKL_API.G_MISS_NUM;


                    OKL_CONTRACT_PUB.create_contract_line(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_clev_rec       => l_lnk_clev_rec,
                         p_klev_rec       => l_lnk_klev_rec,
                         x_clev_rec       => lx_lnk_clev_rec,
                         x_klev_rec       => lx_lnk_klev_rec);
                    --dbms_output.put_line('After creating service fee link line :'||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_lnk_cimv_rec := get_cimv_rec(p_cle_id => l_lnk_line_id, x_no_data_found => l_no_data_found);

                    IF l_no_data_found THEN
                        NULL;
                    --raise appropriate error
                    ELSE
                    --End If;
                        l_lnk_cimv_old_rec := l_lnk_cimv_rec;
                        l_lnk_cimv_rec.ID                         := OKL_API.G_MISS_NUM;
                        l_lnk_cimv_rec.OBJECT_VERSION_NUMBER      := OKL_API.G_MISS_NUM;
                        l_lnk_cimv_rec.OBJECT1_ID1                := TO_CHAR(p_cle_id);
                        l_lnk_cimv_rec.CLE_ID                     := lx_lnk_clev_rec.id;

                        IF NVL(p_txdv_rec.split_percent,0)  NOT IN (0,OKL_API.G_MISS_NUM) THEN
                            --number of items will remain same in case of split asset components
                            l_lnk_cimv_rec.NUMBER_OF_ITEMS        := l_lnk_cimv_rec.NUMBER_OF_ITEMS;
                        ELSE
                             --number of items will be split in case of normal split asset
                            l_lnk_cimv_rec.NUMBER_OF_ITEMS        := l_lnk_cimv_rec.NUMBER_OF_ITEMS * l_split_factor;
                        END IF;

                        l_lnk_cimv_rec.CREATED_BY                 := OKL_API.G_MISS_NUM;
                        l_lnk_cimv_rec.CREATION_DATE              := OKL_API.G_MISS_DATE;
                        l_lnk_cimv_rec.LAST_UPDATED_BY            := OKL_API.G_MISS_NUM;
                        l_lnk_cimv_rec.LAST_UPDATE_DATE           := OKL_API.G_MISS_DATE;
                        l_lnk_cimv_rec.LAST_UPDATE_LOGIN          := OKL_API.G_MISS_NUM;

                        OKL_OKC_MIGRATION_PVT.create_contract_item( p_api_version       => p_api_version,
                                                       p_init_msg_list  => p_init_msg_list,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count          => x_msg_count,
                                                       x_msg_data           => x_msg_data,
                                                       p_cimv_rec           => l_lnk_cimv_rec,
                                                       x_cimv_rec           => lx_lnk_cimv_rec);

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                   END IF;
               END IF;
          END IF;

          --Bug#3066375 : Split the payments attached to the covered asset line
          --adjust rule amounts SLL/SLH
          --Bug# 3897490 : Fix creation of SLH and SLL lines when more than one
          --payment types are defined at service subline level
          l_strm_type_id := NULL;
          OPEN l_sll_cur(p_cle_id =>  l_lnk_line_id);
          LOOP
              l_updated_sll_amount := NULL;
              --Bug# 275289 : For stub payments
              l_updated_stub_amount := NULL;
              FETCH l_sll_cur INTO l_sll_rec;
              EXIT WHEN l_sll_cur%NOTFOUND;

              -------------------------------------------------------------
              --create LALEVL,SLH and SLL against new linked asset line :
              --30-oct-03: 3143522 - LALEVL to be created only once
              IF l_sll_cur%RowCount = 1 THEN
                  l_rgpv_rec.rgd_code      :=  'LALEVL';
                  l_rgpv_rec.cle_id        :=  lx_lnk_clev_rec.id;
                  l_rgpv_rec.dnz_chr_id    :=  lx_lnk_clev_rec.dnz_chr_id;
                  l_rgpv_rec.rgp_type      :=  'KRG';

                  OKL_RULE_PUB.create_rule_group(
                   p_api_version                =>  p_api_version,
                   p_init_msg_list              =>  p_init_msg_list,
                   x_return_status              =>  x_return_status,
                   x_msg_count                  =>  x_msg_count,
                   x_msg_data                   =>  x_msg_data,
                   p_rgpv_rec                   =>  l_rgpv_rec,
                   x_rgpv_rec                   =>  lx_rgpv_rec);

                   --dbms_output.put_line('After updating payments :'||x_return_status);
                   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
               END IF;

                  --Bug# 3897490
                  IF (l_strm_type_id IS NULL OR l_strm_type_id <> l_sll_rec.strm_type_id1) THEN
                  --30-oct-03  : 3143522 - SLH should be created only once

                      --create slh
                      l_slh_rulv_rec.rgp_id                    := lx_rgpv_rec.id;
                      l_slh_rulv_rec.rule_information_category := 'LASLH';
                      l_slh_rulv_rec.jtot_object1_code         := l_sll_rec.strm_type_source;
                      l_slh_rulv_rec.object1_id1               := l_sll_rec.strm_type_id1;
                      l_slh_rulv_rec.object1_id2               := l_sll_rec.strm_type_id2;
                      l_slh_rulv_rec.dnz_chr_id                := lx_rgpv_rec.dnz_chr_id;
                      l_slh_rulv_rec.std_template_yn           := 'N';
                      l_slh_rulv_rec.warn_yn                   := 'N';
                      l_slh_rulv_rec.template_yn               := 'N';

                      OKL_RULE_PUB.create_rule(
                          p_api_version         => p_api_version,
                          p_init_msg_list       => p_init_msg_list,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_rulv_rec            => l_slh_rulv_rec,
                          x_rulv_rec            => lx_slh_rulv_rec);

                      --dbms_output.put_line('After updating payments :'||x_return_status);
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      --Bug# 3897490
                      l_strm_type_id := l_sll_rec.strm_type_id1;
                  END IF;

                  --create sll
                  l_sll_rulv_rec.dnz_chr_id                := lx_rgpv_rec.dnz_chr_id;
                  l_sll_rulv_rec.rgp_id                    := lx_rgpv_rec.id;
                  l_sll_rulv_rec.std_template_yn           := lx_slh_rulv_rec.std_template_yn;
                  l_sll_rulv_rec.warn_yn                   := lx_slh_rulv_rec.warn_yn;
                  l_sll_rulv_rec.template_yn               := lx_slh_rulv_rec.template_yn;
                  l_sll_rulv_rec.rule_information_category := 'LASLL';
                  l_sll_rulv_rec.jtot_object1_code         := l_sll_rec.jtot_object1_code;
                  l_sll_rulv_rec.object1_id1               := l_sll_rec.object1_id1;
                  l_sll_rulv_rec.object1_id2               := l_sll_Rec.object1_id2;
                  l_sll_rulv_rec.jtot_object2_code         := l_sll_rec.jtot_object2_code;
                  l_sll_rulv_rec.object2_id1               := lx_slh_rulv_rec.id;
    -- ansethur 28-feb-08 bug # 6697542
                  l_sll_rulv_rec.object2_id2               :=  '#' ; -- l_sll_rec.object2_id2;
    -- ansethur 28-feb-08 bug # 6697542
                  l_sll_rulv_rec.rule_information1         := l_sll_rec.rule_information1;
                  l_sll_rulv_rec.rule_information2         := l_sll_rec.rule_information2;
                  l_sll_rulv_rec.rule_information3         := l_sll_rec.rule_information3;
                  l_sll_rulv_rec.rule_information4         := l_sll_rec.rule_information4;
                  l_sll_rulv_rec.rule_information5         := l_sll_rec.rule_information5;
                  IF NVL(TO_NUMBER(l_sll_rec.amount_sll)*l_split_factor,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN

                      --Bug# 4028371
                      --Bug# 3502142: Use Streams Rounding Option
                      l_updated_sll_amount := TO_NUMBER(l_sll_rec.amount_sll)*l_split_factor;
                      okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_updated_sll_amount,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      l_updated_sll_amount := l_rounded_amount;
                      l_sll_rulv_rec.rule_information6         := l_updated_sll_amount;

                  ELSIF NVL(TO_NUMBER(l_sll_rec.amount_sll)*l_split_factor,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
                      l_sll_rulv_rec.rule_information6 := NULL;
                  END IF;
                  l_sll_rulv_rec.rule_information7         := l_sll_rec.rule_information7;
                  --Bug# 2757289 : For stup payments
                  IF NVL(TO_NUMBER(l_sll_rec.amount_stub)*l_split_factor,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN

                      --Bug# 4028371
                      --Bug# 3502142: Use Streams Rounding Option
                      l_updated_stub_amount := TO_NUMBER(l_sll_rec.amount_stub)*l_split_factor;
                      okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_updated_stub_amount,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      l_updated_stub_amount := l_rounded_amount;
                      l_sll_rulv_rec.rule_information8         := l_updated_stub_amount;

                  ELSIF NVL(TO_NUMBER(l_sll_rec.amount_stub)*l_split_factor,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
                      l_sll_rulv_rec.rule_information8 := NULL;
                  END IF;
                  --l_sll_rulv_rec.rule_information8         := l_sll_rec.rule_information8;
                  l_sll_rulv_rec.rule_information9         := l_sll_rec.rule_information9;
                  l_sll_rulv_rec.rule_information10        := l_sll_rec.rule_information10;
                  l_sll_rulv_rec.rule_information11        := l_sll_rec.rule_information11;
                  l_sll_rulv_rec.rule_information12        := l_sll_rec.rule_information12;
                  l_sll_rulv_rec.rule_information13        := l_sll_rec.rule_information13;
                  l_sll_rulv_rec.rule_information14        := l_sll_rec.rule_information14;
                  l_sll_rulv_rec.rule_information15        := l_sll_rec.rule_information15;

                  OKL_RULE_PUB.create_rule(
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      x_return_status       => x_return_status,
                      x_msg_count           => x_msg_count,
                      x_msg_data            => x_msg_data,
                      p_rulv_rec            => l_sll_rulv_rec,
                      x_rulv_rec            => lx_sll_rulv_rec);

                  --dbms_output.put_line('After updating payments :'||x_return_status);
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

              ------------------------------------------------------------------------

          END LOOP;
          CLOSE l_sll_cur;
          --End Bug# 3066375

    END LOOP;
    CLOSE l_lnk_asst_cur;

    --Bug# 3502142
    ELSE -- Parent line

      -- For Split Asset into Units, Update Parent linked asset
      --  line after all child linked lines have been created

      -- For Split Asset into Components, create linked asset
      -- line for largest asset cost after all other child linked lines
      -- have been created

        OPEN l_lnk_asst_cur (p_cle_id => p_parent_line_id);
        LOOP
            FETCH l_lnk_asst_cur INTO
                  l_srv_fee_line_id,
                  l_lnk_line_id;
            EXIT WHEN l_lnk_asst_cur%NOTFOUND;

            l_lnk_klev_rec := get_klev_rec(p_cle_id        => l_lnk_line_id,
                                           x_no_data_found => l_no_data_found);
            IF l_no_data_found THEN
                NULL;
                --raise appropriate error
            ELSE
                l_lnk_klev_old_rec := l_lnk_klev_rec;

                l_lnk_clev_rec := get_clev_rec(p_cle_id        => l_lnk_line_id,
                                               x_no_data_found => l_no_data_found);
                IF l_no_data_found THEN
                  NULL;
                  --raise appropriate error
                ELSE
                  l_lnk_clev_old_rec := l_lnk_clev_rec;

                  FOR l_new_lnk_assts_rec in l_new_lnk_assts_cur
                                             (p_chr_id => l_lnk_clev_old_rec.dnz_chr_id,
                                              p_cle_id => l_lnk_line_id) LOOP

                      l_lnk_klev_rec := get_klev_rec(p_cle_id        => l_new_lnk_assts_rec.id,
                                                     x_no_data_found => l_no_data_found);
                      IF l_no_data_found THEN
                          NULL;
                          --raise appropriate error
                      ELSE
                        l_lnk_klev_old_rec.ESTIMATED_OEC := l_lnk_klev_old_rec.ESTIMATED_OEC - l_lnk_klev_rec.ESTIMATED_OEC;
                        l_lnk_klev_old_rec.LAO_AMOUNT    := l_lnk_klev_old_rec.LAO_AMOUNT - l_lnk_klev_rec.LAO_AMOUNT;
                        l_lnk_klev_old_rec.FEE_CHARGE    :=  l_lnk_klev_old_rec.FEE_CHARGE - l_lnk_klev_rec.FEE_CHARGE;
                        l_lnk_klev_old_rec.INITIAL_DIRECT_COST := l_lnk_klev_old_rec.INITIAL_DIRECT_COST - l_lnk_klev_rec.INITIAL_DIRECT_COST;
                        l_lnk_klev_old_rec.AMOUNT_STAKE :=  l_lnk_klev_old_rec.AMOUNT_STAKE - l_lnk_klev_rec.AMOUNT_STAKE;
                        l_lnk_klev_old_rec.LRV_AMOUNT := l_lnk_klev_old_rec.LRV_AMOUNT - l_lnk_klev_rec.LRV_AMOUNT;
                        l_lnk_klev_old_rec.COVERAGE := l_lnk_klev_old_rec.COVERAGE - l_lnk_klev_rec.COVERAGE;
                        l_lnk_klev_old_rec.CAPITAL_REDUCTION := l_lnk_klev_old_rec.CAPITAL_REDUCTION - l_lnk_klev_rec.CAPITAL_REDUCTION;
                        l_lnk_klev_old_rec.VENDOR_ADVANCE_PAID := l_lnk_klev_old_rec.VENDOR_ADVANCE_PAID - l_lnk_klev_rec.VENDOR_ADVANCE_PAID;
                        l_lnk_klev_old_rec.TRADEIN_AMOUNT := l_lnk_klev_old_rec.TRADEIN_AMOUNT - l_lnk_klev_rec.TRADEIN_AMOUNT;
                        l_lnk_klev_old_rec.BOND_EQUIVALENT_YIELD :=  l_lnk_klev_old_rec.BOND_EQUIVALENT_YIELD - l_lnk_klev_rec.BOND_EQUIVALENT_YIELD;
                        l_lnk_klev_old_rec.TERMINATION_PURCHASE_AMOUNT :=l_lnk_klev_old_rec.TERMINATION_PURCHASE_AMOUNT - l_lnk_klev_rec.TERMINATION_PURCHASE_AMOUNT;
                        l_lnk_klev_old_rec.REFINANCE_AMOUNT := l_lnk_klev_old_rec.REFINANCE_AMOUNT - l_lnk_klev_rec.REFINANCE_AMOUNT;
                        l_lnk_klev_old_rec.REMARKETED_AMOUNT := l_lnk_klev_old_rec.REMARKETED_AMOUNT - l_lnk_klev_rec.REMARKETED_AMOUNT;
                        l_lnk_klev_old_rec.REMARKET_MARGIN :=  l_lnk_klev_old_rec.REMARKET_MARGIN - l_lnk_klev_rec.REMARKET_MARGIN;
                        l_lnk_klev_old_rec.REPURCHASED_AMOUNT := l_lnk_klev_old_rec.REPURCHASED_AMOUNT - l_lnk_klev_rec.REPURCHASED_AMOUNT;
                        l_lnk_klev_old_rec.RESIDUAL_VALUE := l_lnk_klev_old_rec.RESIDUAL_VALUE - l_lnk_klev_rec.RESIDUAL_VALUE;
                        l_lnk_klev_old_rec.APPRAISAL_VALUE := l_lnk_klev_old_rec.APPRAISAL_VALUE - l_lnk_klev_rec.APPRAISAL_VALUE;
                        l_lnk_klev_old_rec.GAIN_LOSS := l_lnk_klev_old_rec.GAIN_LOSS - l_lnk_klev_rec.GAIN_LOSS;
                        l_lnk_klev_old_rec.FLOOR_AMOUNT := l_lnk_klev_old_rec.FLOOR_AMOUNT -l_lnk_klev_rec.FLOOR_AMOUNT;
                        l_lnk_klev_old_rec.TRACKED_RESIDUAL := l_lnk_klev_old_rec.TRACKED_RESIDUAL - l_lnk_klev_rec.TRACKED_RESIDUAL;
                        l_lnk_klev_old_rec.AMOUNT := l_lnk_klev_old_rec.AMOUNT - l_lnk_klev_rec.AMOUNT;
                        l_lnk_klev_old_rec.OEC := l_lnk_klev_old_rec.OEC - l_lnk_klev_rec.OEC;
                        l_lnk_klev_old_rec.CAPITAL_AMOUNT := l_lnk_klev_old_rec.CAPITAL_AMOUNT - l_lnk_klev_rec.CAPITAL_AMOUNT;
                        l_lnk_klev_old_rec.RESIDUAL_GRNTY_AMOUNT := l_lnk_klev_old_rec.RESIDUAL_GRNTY_AMOUNT - l_lnk_klev_rec.RESIDUAL_GRNTY_AMOUNT;
                        l_lnk_klev_old_rec.RVI_PREMIUM := l_lnk_klev_old_rec.RVI_PREMIUM - l_lnk_klev_rec.RVI_PREMIUM;
                        l_lnk_klev_old_rec.SUBSIDY_OVERRIDE_AMOUNT := l_lnk_klev_old_rec.SUBSIDY_OVERRIDE_AMOUNT - l_lnk_klev_rec.SUBSIDY_OVERRIDE_AMOUNT;
                      END IF;
                  END LOOP;

                  -- Split into units
                  IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN

                    --update contract line
                    OKL_CONTRACT_PUB.update_contract_line(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_clev_rec       => l_lnk_clev_old_rec,
                         p_klev_rec       => l_lnk_klev_old_rec,
                         x_clev_rec       => lx_lnk_clev_old_rec,
                         x_klev_rec       => lx_lnk_klev_old_rec);
                    --dbms_output.put_line('After updating service fee link line :'||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                  -- Split into components
                  ELSIF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN

                    l_lnk_klev_rec := l_lnk_klev_old_rec;
                    --
                    l_lnk_clev_rec.price_unit := (l_split_factor * l_lnk_clev_rec.price_unit);
                    l_lnk_clev_rec.price_negotiated := (l_split_factor * l_lnk_clev_rec.price_negotiated);
                    l_lnk_clev_rec.price_negotiated_renewed := (l_split_factor * l_lnk_clev_rec.price_negotiated_renewed);

                    l_lnk_clev_rec.ORIG_SYSTEM_ID1       := l_lnk_clev_rec.ID;
                    l_lnk_clev_rec.ID                    := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.OBJECT_VERSION_NUMBER := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.SFWT_FLAG             := OKL_API.G_MISS_CHAR;
                    l_lnk_clev_rec.LINE_NUMBER           := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.DISPLAY_SEQUENCE      := l_clev_rec.DISPLAY_SEQUENCE + 1;

                      l_lnk_clev_rec.ORIG_SYSTEM_SOURCE_CODE := 'OKL_SPLIT';
                    l_lnk_clev_rec.CREATED_BY        := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.CREATION_DATE     := OKL_API.G_MISS_DATE;
                    l_lnk_clev_rec.LAST_UPDATED_BY   := OKL_API.G_MISS_NUM;
                    l_lnk_clev_rec.LAST_UPDATE_DATE  := OKL_API.G_MISS_DATE;
                    l_lnk_clev_rec.LAST_UPDATE_LOGIN := OKL_API.G_MISS_NUM;
                    --make new line as BOOKED
                    l_lnk_clev_rec.STS_CODE          := 'BOOKED';
                    --bug# 3066375
                    l_lnk_clev_rec.name              := l_txdv_rec.asset_number;
                    l_lnk_clev_rec.item_description  := l_txdv_rec.description;
                    ----
                    l_lnk_klev_rec.ID := OKL_API.G_MISS_NUM;
                    l_lnk_klev_rec.OBJECT_VERSION_NUMBER := OKL_API.G_MISS_NUM;
                    l_lnk_klev_rec.CREATED_BY := OKL_API.G_MISS_NUM;
                    l_lnk_klev_rec.CREATION_DATE := OKL_API.G_MISS_DATE;
                    l_klev_rec.LAST_UPDATED_BY := OKL_API.G_MISS_NUM;
                    l_klev_rec.LAST_UPDATE_DATE := OKL_API.G_MISS_DATE;
                    l_klev_rec.LAST_UPDATE_LOGIN := OKL_API.G_MISS_NUM;

                    OKL_CONTRACT_PUB.create_contract_line(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_clev_rec       => l_lnk_clev_rec,
                         p_klev_rec       => l_lnk_klev_rec,
                         x_clev_rec       => lx_lnk_clev_rec,
                         x_klev_rec       => lx_lnk_klev_rec);
                    --dbms_output.put_line('After creating service fee link line :'||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                  END IF;

                  l_lnk_cimv_rec := get_cimv_rec(p_cle_id => l_lnk_line_id, x_no_data_found => l_no_data_found);

                  IF l_no_data_found THEN
                      NULL;
                  --raise appropriate error
                  ELSE
                    l_lnk_cimv_old_rec := l_lnk_cimv_rec;

                    -- Split into units
                    IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN

                      FOR l_new_lnk_assts_rec in l_new_lnk_assts_cur
                                             (p_chr_id => l_lnk_clev_old_rec.dnz_chr_id,
                                              p_cle_id => l_lnk_line_id) LOOP

                        l_lnk_cimv_rec := get_cimv_rec(p_cle_id => l_new_lnk_assts_rec.id,
                                                       x_no_data_found => l_no_data_found);
                        IF l_no_data_found THEN
                          NULL;
                          --raise appropriate error
                        ELSE
                          --number of items will be split in case of normal split asset
                          l_lnk_cimv_old_rec.NUMBER_OF_ITEMS  := l_lnk_cimv_old_rec.NUMBER_OF_ITEMS - l_lnk_cimv_rec.NUMBER_OF_ITEMS;
                        END IF;
                      END LOOP;

                      --update original item record
                      OKL_OKC_MIGRATION_PVT.update_contract_item( p_api_version => p_api_version,
                                                       p_init_msg_list  => p_init_msg_list,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data             => x_msg_data,
                                                       p_cimv_rec             => l_lnk_cimv_old_rec,
                                                       x_cimv_rec             => lx_lnk_cimv_old_rec);

                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                    -- Split into components
                    ELSIF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN

                       l_lnk_cimv_rec.ID                         := OKL_API.G_MISS_NUM;
                       l_lnk_cimv_rec.OBJECT_VERSION_NUMBER      := OKL_API.G_MISS_NUM;
                       l_lnk_cimv_rec.OBJECT1_ID1                := TO_CHAR(p_cle_id);
                       l_lnk_cimv_rec.CLE_ID                     := lx_lnk_clev_rec.id;

                       l_lnk_cimv_rec.CREATED_BY                 := OKL_API.G_MISS_NUM;
                       l_lnk_cimv_rec.CREATION_DATE              := OKL_API.G_MISS_DATE;
                       l_lnk_cimv_rec.LAST_UPDATED_BY            := OKL_API.G_MISS_NUM;
                       l_lnk_cimv_rec.LAST_UPDATE_DATE           := OKL_API.G_MISS_DATE;
                       l_lnk_cimv_rec.LAST_UPDATE_LOGIN          := OKL_API.G_MISS_NUM;

                       OKL_OKC_MIGRATION_PVT.create_contract_item( p_api_version        => p_api_version,
                                                       p_init_msg_list  => p_init_msg_list,
                                                       x_return_status  => x_return_status,
                                                       x_msg_count          => x_msg_count,
                                                       x_msg_data           => x_msg_data,
                                                       p_cimv_rec           => l_lnk_cimv_rec,
                                                       x_cimv_rec           => lx_lnk_cimv_rec);

                       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                       END IF;
                    END IF;

                  END IF; -- cimv rec found
                END IF; -- clev rec found
            END IF; --klev rec found

            l_strm_type_id := NULL;
            OPEN l_sll_cur(p_cle_id =>  l_lnk_line_id);
            LOOP
              FETCH l_sll_cur INTO l_sll_rec;
              EXIT WHEN l_sll_cur%NOTFOUND;

                l_sll_amount := TO_NUMBER(l_sll_rec.amount_sll);
                l_stub_amount := TO_NUMBER(l_sll_rec.amount_stub);

                l_split_pymt_sum := 0;

                -- Split into units
                IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN
                  l_target_kle_id := p_txlv_rec.kle_id;

                -- Split into components
                ELSE
                  open l_fa_line_csr(p_chr_id => p_txlv_rec.dnz_khr_id
                                    ,p_cle_id => p_cle_id);
                  fetch l_fa_line_csr into l_target_kle_id;
                  close l_fa_line_csr;
                END IF;

                FOR l_txd_rec in l_txd_csr(p_tal_id  => p_txlv_rec.id
                                          ,p_cle_id  => l_target_kle_id)
                LOOP

                  IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN
                    l_sll_split_factor := l_txd_rec.quantity/p_txlv_rec.current_units;
                  ELSE
                    l_sll_split_factor := l_txd_rec.split_percent/100;
                  END IF;

                  IF NVL(l_sll_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
                    l_split_pymt := l_sll_amount * l_sll_split_factor;
                  ELSIF NVL(l_stub_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
                    l_split_pymt := l_stub_amount * l_sll_split_factor;
                  END IF;

                  okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_split_pymt,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  l_split_pymt_sum := l_split_pymt_sum + l_rounded_amount;

                END LOOP;

                -- Split into units
                IF NVL(p_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN

                  --update the rule record
                  l_rulv_rec.id                 := l_sll_rec.sll_id;
                  IF NVL(l_sll_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
                    l_rulv_rec.rule_information6  := TO_CHAR(l_sll_amount - l_split_pymt_sum);
                  ELSIF NVL(l_sll_amount,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
                    l_rulv_rec.rule_information6 := NULL;
                  END IF;

                  IF NVL(l_stub_amount,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
                    l_rulv_rec.rule_information8  := TO_CHAR(l_stub_amount - l_split_pymt_sum);
                  ELSIF NVL(l_stub_amount,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
                    l_rulv_rec.rule_information8 := NULL;
                  END IF;

                  OKL_RULE_PUB.update_rule(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_rulv_rec       => l_rulv_rec,
                            x_rulv_rec       => l_rulv_rec_out);

                  --dbms_output.put_line('After updating payments :'||x_return_status);
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                -- Split into components
                ELSIF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN

                  IF l_sll_cur%RowCount = 1 THEN
                    l_rgpv_rec.rgd_code      :=  'LALEVL';
                    l_rgpv_rec.cle_id        :=  lx_lnk_clev_rec.id;
                    l_rgpv_rec.dnz_chr_id    :=  lx_lnk_clev_rec.dnz_chr_id;
                    l_rgpv_rec.rgp_type      :=  'KRG';

                    OKL_RULE_PUB.create_rule_group(
                     p_api_version                =>  p_api_version,
                     p_init_msg_list              =>  p_init_msg_list,
                     x_return_status              =>  x_return_status,
                     x_msg_count                  =>  x_msg_count,
                     x_msg_data                   =>  x_msg_data,
                     p_rgpv_rec                   =>  l_rgpv_rec,
                     x_rgpv_rec                   =>  lx_rgpv_rec);

                    --dbms_output.put_line('After updating payments :'||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;

                  --Bug# 3897490
                  IF (l_strm_type_id IS NULL OR l_strm_type_id <> l_sll_rec.strm_type_id1) THEN
                  --30-oct-03  : 3143522 - SLH should be created only once
                      --create slh
                      l_slh_rulv_rec.rgp_id                    := lx_rgpv_rec.id;
                      l_slh_rulv_rec.rule_information_category := 'LASLH';
                      l_slh_rulv_rec.jtot_object1_code         := l_sll_rec.strm_type_source;
                      l_slh_rulv_rec.object1_id1               := l_sll_rec.strm_type_id1;
                      l_slh_rulv_rec.object1_id2               := l_sll_rec.strm_type_id2;
                      l_slh_rulv_rec.dnz_chr_id                := lx_rgpv_rec.dnz_chr_id;
                      l_slh_rulv_rec.std_template_yn           := 'N';
                      l_slh_rulv_rec.warn_yn                   := 'N';
                      l_slh_rulv_rec.template_yn               := 'N';

                      OKL_RULE_PUB.create_rule(
                          p_api_version         => p_api_version,
                          p_init_msg_list       => p_init_msg_list,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data,
                          p_rulv_rec            => l_slh_rulv_rec,
                          x_rulv_rec            => lx_slh_rulv_rec);

                      --dbms_output.put_line('After updating payments :'||x_return_status);
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      --Bug# 3897490
                      l_strm_type_id := l_sll_rec.strm_type_id1;
                  END IF;

                  --create sll
                  l_sll_rulv_rec.dnz_chr_id                := lx_rgpv_rec.dnz_chr_id;
                  l_sll_rulv_rec.rgp_id                    := lx_rgpv_rec.id;
                  l_sll_rulv_rec.std_template_yn           := lx_slh_rulv_rec.std_template_yn;
                  l_sll_rulv_rec.warn_yn                   := lx_slh_rulv_rec.warn_yn;
                  l_sll_rulv_rec.template_yn               := lx_slh_rulv_rec.template_yn;
                  l_sll_rulv_rec.rule_information_category := 'LASLL';
                  l_sll_rulv_rec.jtot_object1_code         := l_sll_rec.jtot_object1_code;
                  l_sll_rulv_rec.object1_id1               := l_sll_rec.object1_id1;
                  l_sll_rulv_rec.object1_id2               := l_sll_Rec.object1_id2;
                  l_sll_rulv_rec.jtot_object2_code         := l_sll_rec.jtot_object2_code;
                  l_sll_rulv_rec.object2_id1               := lx_slh_rulv_rec.id;
    -- ansethur 28-feb-08 bug # 6697542
                  l_sll_rulv_rec.object2_id2               :=  '#' ; -- l_sll_rec.object2_id2;
    -- ansethur 28-feb-08 bug # 6697542
                  l_sll_rulv_rec.rule_information1         := l_sll_rec.rule_information1;
                  l_sll_rulv_rec.rule_information2         := l_sll_rec.rule_information2;
                  l_sll_rulv_rec.rule_information3         := l_sll_rec.rule_information3;
                  l_sll_rulv_rec.rule_information4         := l_sll_rec.rule_information4;
                  l_sll_rulv_rec.rule_information5         := l_sll_rec.rule_information5;

                  IF NVL(TO_NUMBER(l_sll_rec.amount_sll),OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN

                      --Bug# 4028371
                      --Bug# 3502142: Use Streams Rounding Option
                      l_updated_sll_amount := TO_NUMBER(l_sll_rec.amount_sll) - l_split_pymt_sum;
                      okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_updated_sll_amount,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      l_updated_sll_amount := l_rounded_amount;
                      l_sll_rulv_rec.rule_information6         := l_updated_sll_amount;

                  ELSIF NVL(TO_NUMBER(l_sll_rec.amount_sll),OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
                      l_sll_rulv_rec.rule_information6 := NULL;
                  END IF;
                  l_sll_rulv_rec.rule_information7         := l_sll_rec.rule_information7;
                  --Bug# 2757289 : For stup payments
                  IF NVL(TO_NUMBER(l_sll_rec.amount_stub),OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN

                      --Bug# 4028371
                      --Bug# 3502142: Use Streams Rounding Option
                      l_updated_stub_amount := TO_NUMBER(l_sll_rec.amount_stub) - l_split_pymt_sum;
                      okl_accounting_util.round_amount(
                                         p_api_version    => p_api_version,
                                         p_init_msg_list  => p_init_msg_list,
                                         x_return_status  => x_return_status,
                                         x_msg_count      => x_msg_count,
                                         x_msg_data       => x_msg_data,
                                         p_amount         => l_updated_stub_amount,
                                         p_currency_code  => l_sll_rec.currency_code,
                                         p_round_option   => 'STM',
                                         x_rounded_amount => l_rounded_amount
                                         );
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      l_updated_stub_amount := l_rounded_amount;
                      l_sll_rulv_rec.rule_information8         := l_updated_stub_amount;

                  ELSIF NVL(TO_NUMBER(l_sll_rec.amount_stub),OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM THEN
                      l_sll_rulv_rec.rule_information8 := NULL;
                  END IF;
                  --l_sll_rulv_rec.rule_information8         := l_sll_rec.rule_information8;
                  l_sll_rulv_rec.rule_information9         := l_sll_rec.rule_information9;
                  l_sll_rulv_rec.rule_information10        := l_sll_rec.rule_information10;
                  l_sll_rulv_rec.rule_information11        := l_sll_rec.rule_information11;
                  l_sll_rulv_rec.rule_information12        := l_sll_rec.rule_information12;
                  l_sll_rulv_rec.rule_information13        := l_sll_rec.rule_information13;
                  l_sll_rulv_rec.rule_information14        := l_sll_rec.rule_information14;
                  l_sll_rulv_rec.rule_information15        := l_sll_rec.rule_information15;

                  OKL_RULE_PUB.create_rule(
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      x_return_status       => x_return_status,
                      x_msg_count           => x_msg_count,
                      x_msg_data            => x_msg_data,
                      p_rulv_rec            => l_sll_rulv_rec,
                      x_rulv_rec            => lx_sll_rulv_rec);

                  --dbms_output.put_line('After updating payments :'||x_return_status);
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                END IF;

            END LOOP;
            CLOSE l_sll_cur;
        END LOOP;
        CLOSE l_lnk_asst_cur;
    END IF;
    --will also have to think about UBB

    --Bug# 6344223
    --update unit cost
   adjust_unit_cost(p_api_version   => p_api_version,
                    p_init_msg_list =>p_init_msg_list,
                    x_return_status =>x_return_status,
                    x_msg_count     =>x_msg_count,
                    x_msg_data      =>x_msg_data,
                    p_cle_id        =>l_fa_line_id ,
                    p_txdv_rec      =>p_txdv_rec,
                    p_txlv_rec      =>p_txlv_rec
                    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- Bug# 6344223

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
END Adjust_Split_Lines;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : ABANDON_PARENT_ASSET
--Description    : Abandons Parent Asset for Split Asset Component Parent
--History        :
--                 24-Jul-2002  ashish.singh Created
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE ABANDON_PARENT_ASSET(
                p_api_version    IN  NUMBER,
                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                x_return_status  OUT NOCOPY VARCHAR2,
                x_msg_count      OUT NOCOPY NUMBER,
                x_msg_data       OUT NOCOPY VARCHAR2,
                p_cle_id         IN  NUMBER) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'ABANDON_PARENT_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;

CURSOR c_lines_cur(p_cle_id IN NUMBER) IS
    SELECT LEVEL,
           id,
                   chr_id,
                   cle_id,
                   dnz_chr_id,
           lse_id
    FROM   okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_cle_id;

    c_lines_rec c_lines_cur%ROWTYPE;
    l_clev_rec  okl_okc_migration_pvt.clev_rec_type;
    lx_clev_rec okl_okc_migration_pvt.clev_rec_type;

--Bug#3066375 :
--Cursor to fetch linked asset lines for parent asset being abandoned
CURSOR l_lnk_asst_csr (p_cle_id IN NUMBER) IS
SELECT lnk_cleb.id lnk_cle_id
FROM   okc_k_lines_b       lnk_cleb,
       okc_line_styles_b   lnk_lseb,
       okc_statuses_b      lnk_stsb,
       okc_k_items         lnk_cim
WHERE  lnk_cleb.id         = lnk_cim.cle_id
AND    lnk_cleb.dnz_chr_id = lnk_cim.dnz_chr_id
AND    lnk_cleb.lse_id     = lnk_lseb.id
AND    lnk_lseb.lty_code IN
       ('LINK_FEE_ASSET','LINK_SERV_ASSET','LINK_USAGE_ASSET')
AND    lnk_cleb.sts_code   =  lnk_stsb.code
AND    lnk_stsb.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
AND    lnk_cim.object1_id1 = TO_CHAR(p_cle_id)
AND    lnk_cim.object1_id2 = '#'
AND    lnk_cim.jtot_object1_code = 'OKX_COVASST';

l_lnk_cle_id okc_k_lines_b.id%TYPE;
l_lnk_clev_rec  okl_okc_migration_pvt.clev_rec_type;
lx_lnk_clev_rec okl_okc_migration_pvt.clev_rec_type;

BEGIN
-----
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

   OPEN c_lines_cur(p_cle_id => p_cle_id);
   LOOP
       FETCH c_lines_cur INTO c_lines_rec;
       EXIT WHEN c_lines_cur%NOTFOUND;
       l_clev_rec.id := c_lines_rec.id;
       l_clev_rec.sts_code := 'ABANDONED';

       okl_okc_migration_pvt.update_contract_line(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_clev_rec           => l_clev_rec,
            x_clev_rec           => lx_clev_rec);

        --Bug# 3066375 : abandon linked asset lines
        OPEN l_lnk_asst_csr(p_cle_id => p_cle_id);
        LOOP
            FETCH l_lnk_asst_csr INTO l_lnk_cle_id;
            EXIT WHEN l_lnk_asst_csr%NOTFOUND;
            l_lnk_clev_rec.id := l_lnk_cle_id;
            l_lnk_clev_rec.sts_code := 'ABANDONED';

            okl_okc_migration_pvt.update_contract_line(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_clev_rec           => l_lnk_clev_rec,
            x_clev_rec           => lx_lnk_clev_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

         END LOOP;
         CLOSE l_lnk_asst_csr;
         --Bug# 3066375 end.

    END LOOP;
    CLOSE c_lines_cur;
    --will also have to think about UBB
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
END ABANDON_PARENT_ASSET;

--Bug# 6061103
PROCEDURE is_evergreen_df_lease
                   (p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    p_cle_id          IN  NUMBER,
                    p_book_type_code  IN VARCHAR2,
                    p_asset_status    IN VARCHAR2,
                    p_pdt_id          IN NUMBER,
                    p_start_date      IN DATE,
                    x_amortization_date OUT NOCOPY DATE,
                    x_special_treatment_required OUT NOCOPY VARCHAR2
                   )     IS
 l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT varchar2(30) := 'is_evergreen_df_lease';
 l_api_version          CONSTANT NUMBER := 1.0;
--cursor to find book class
   CURSOR l_book_class_cur(p_book_type_code IN VARCHAR2) IS
   SELECT book_class
   FROM   okx_asst_bk_controls_v
   WHERE  book_type_code = p_book_type_code;
   l_book_class okx_asst_bk_controls_v.book_class%TYPE;
 l_contract_number       OKC_K_HEADERS_B.contract_number%TYPE;
 l_scs_code          Varchar2(30);
 l_sts_code          Varchar2(30);
 l_deal_type         Varchar2(30);
 l_pdt_id            Number;
 l_start_date        Date;
 l_asset_status okc_k_lines_b.sts_code%TYPE;
 l_chr_id NUMBER;
 l_amortization_date DATE;
 l_special_treatment_required VARCHAR2(1);
 l_pdt_date                DATE;
 l_pdtv_rec                okl_setupproducts_pub.pdtv_rec_type;
 l_pdt_parameter_rec       okl_setupproducts_pub.pdt_parameters_rec_type;
 l_rep_pdt_parameter_rec   okl_setupproducts_pub.pdt_parameters_rec_type;
 l_reporting_product       OKL_PRODUCTS_V.NAME%TYPE;
 l_no_data_found           BOOLEAN;
 l_rep_pdt_id NUMBER;
 l_rep_deal_type           okl_product_parameters_v.deal_type%TYPE;
 l_tax_owner         Varchar2(150);
 l_rep_tax_owner         Varchar2(150);
 l_Multi_GAAP_YN     Varchar2(1);
 l_mg_rep_book             fa_book_controls.book_type_code%TYPE;
  l_amortization_start_date DATE:=NULL;
  -- CURSOR TO GET MAX OFF LEASE TRX DATESELECT
   Cursor tax_off_trx_amt(p_asset_id in number, p_tax_book in varchar2) is
    select  tas.date_trans_occurred
    FROM   OKL_TRX_ASSETS tas,
          OKL_TXL_ASSETS_B tal,
          OKL_TXD_ASSETS_B txl
   WHERE tas.id = tal.tas_id
   AND   tal.id = txl.tal_id
   AND   txl.tax_book  = p_tax_book
   AND    tas.tsu_code  = 'PROCESSED'
   AND    tas.tas_type in ('AMT')
   And tal.kle_id = p_asset_id;
   Cursor corp_off_trx_amt(p_asset_id in number, p_corp_book in varchar2) is
   SELECT
          tas.date_trans_occurred
   FROM   OKL_TRX_ASSETS tas,
          OKL_TXL_ASSETS_B tal,
          OKL_TXD_ASSETS_B txd
   WHERE tas.id = tal.tas_id
   AND   tal.corporate_book  = P_corp_book
   AND    tas.tsu_code = 'PROCESSED'
   AND   tas.tas_type in ('AMT')
   And   tal.kle_id = p_asset_id
   AND   tal.id = txd.tal_id(+)
   AND   TAX_BOOK IS NULL ;
    Cursor tax_off_trx_aus(p_asset_id in number, p_tax_book in varchar2) is
    select  tas.date_trans_occurred
    FROM   OKL_TRX_ASSETS tas,
          OKL_TXL_ASSETS_B tal,
          OKL_TXD_ASSETS_B txl
   WHERE tas.id = tal.tas_id
   AND   tal.id = txl.tal_id
   AND   txl.tax_book  = p_tax_book
   AND    tas.tsu_code  = 'PROCESSED'
   AND    tas.tas_type in ('AUS')
   And tal.kle_id = p_asset_id;
   Cursor corp_off_trx_aus(p_asset_id in number, p_corp_book in varchar2) is
   SELECT
          tas.date_trans_occurred
   FROM   OKL_TRX_ASSETS tas,
          OKL_TXL_ASSETS_B tal,
          OKL_TXD_ASSETS_B txd
   WHERE tas.id = tal.tas_id
   AND   tal.corporate_book  = P_corp_book
   AND    tas.tsu_code = 'PROCESSED'
   AND    tas.tas_type in ('AUS')
   And tal.kle_id = p_asset_id
   AND   tal.id = txd.tal_id(+)
   AND   TAX_BOOK IS NULL ;
   l_trans_date_aus DATE;
   l_trans_date_amt DATE;
BEGIN
     --call start activity to set savepoint
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   l_pdtv_rec.id    := p_pdt_id;
   l_no_data_found  := TRUE;
   l_pdt_date :=p_start_date;
   okl_setupproducts_pub.Getpdt_parameters(p_api_version      => p_api_version,
                                             p_init_msg_list     => p_init_msg_list,
                      			             x_return_status     => l_return_status,
            			                     x_no_data_found     => l_no_data_found,
                              		         x_msg_count         => x_msg_count,
                              		         x_msg_data          => x_msg_data,
					                         p_pdtv_rec          => l_pdtv_rec,
					                         p_product_date      => l_pdt_date,
					                         p_pdt_parameter_rec => l_pdt_parameter_rec);
     IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- Error getting financial product parameters for contract CONTRACT_NUMBER.
        OKC_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FIN_PROD_PARAM_ERR',
                           p_token1        =>  'CONTRACT_NUMBER',
                           p_token1_value  =>  l_contract_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --dbms_output.put_line('l_pdt_parameter_rec.reporting_pdt_id '||l_pdt_parameter_rec.reporting_pdt_id );
     l_mg_rep_book :=NULL;
      if l_pdt_parameter_rec.reporting_pdt_id IS NULL Then
         l_rep_pdt_id    := Null;
         l_tax_owner     := l_pdt_parameter_rec.tax_owner;
         l_deal_type     :=  l_pdt_parameter_rec.deal_type;
         l_rep_deal_type := Null;
         l_rep_tax_owner :=NULL;
      Else
         l_rep_pdt_id    := l_pdt_parameter_rec.reporting_pdt_id;
         l_tax_owner     := l_pdt_parameter_rec.tax_owner;
         l_deal_type     :=  l_pdt_parameter_rec.deal_type;
         --get reporting product param values
         l_no_data_found := TRUE;
         l_pdtv_rec.id := l_rep_pdt_id;
         IF l_rep_pdt_id IS NOT NULL AND l_rep_pdt_id <> OKC_API.G_MISS_NUM THEN
          okl_setupproducts_pub.Getpdt_parameters(p_api_version      => p_api_version,
                                                 p_init_msg_list     => p_init_msg_list,
                                                 x_return_status     => l_return_status,
                                                 x_no_data_found     => l_no_data_found,
                                 		         x_msg_count         => x_msg_count,
                                 		         x_msg_data          => x_msg_data,
    					                         p_pdtv_rec          => l_pdtv_rec,
    					                         p_product_date      => l_pdt_date,
    					                         p_pdt_parameter_rec => l_rep_pdt_parameter_rec);
          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
                -- Error getting reporting product parameters for contract CONTRACT_NUMBER.
                OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_REP_PROD_PARAM_ERR',
                                  p_token1        => 'CONTRACT_NUMBER',
                                  p_token1_value  => l_contract_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
          Else
             l_rep_deal_type :=  l_rep_pdt_parameter_rec.deal_type;
             l_rep_tax_owner := l_rep_pdt_parameter_rec.tax_owner;
             IF l_rep_deal_type IS NULL OR l_rep_deal_type = OKC_API.G_MISS_CHAR THEN
                    --Deal Type not defined for Reporting product REP_PROD.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_NO_MG_DEAL_TYPE',
                                 p_token1        => 'REP_PROD',
                                 p_token1_value  => l_reporting_product);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
             End If;
             l_Multi_GAAP_YN := 'Y';
         End If;
         -- get the MG reporting book
         -- Bug#6695409
           l_mg_rep_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);

           IF l_mg_rep_book IS NULL THEN
                    --Multi GAAP Reporting Book is not defined.
                   OKL_API.set_message(  p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_NO_MG_REP_BOOK');
                   RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF; --mg book
         END IF; --l_rep_pdt_id IS not null
       END IF;  --reporting_pdt_id IS NULL
     l_book_class := NULL;
     OPEN l_book_class_cur(p_book_type_code => p_book_type_code);
         FETCH l_book_class_cur INTO l_book_class;
         IF l_book_class_cur%NOTFOUND THEN
             NULL;
         END IF;
     CLOSE l_book_class_cur;
     l_special_treatment_required :='N';
     IF p_asset_status IN ('TERMINATED','EXPIRED','EVERGREEN') THEN
         IF (l_book_class = 'CORPORATE') AND (l_deal_type in ('LEASEDF','LEASEST')) then
             --rirawat
             open corp_off_trx_aus(p_cle_id , p_book_type_code);
             FETCH corp_off_trx_aus INTO l_amortization_date;
             close  corp_off_trx_aus ;
             IF l_amortization_date IS NULL THEN
                 open corp_off_trx_amt(p_cle_id , p_book_type_code);
                 FETCH corp_off_trx_amt INTO l_amortization_date;
                 close  corp_off_trx_amt ;
             END IF ;
             --l_amortization_date := sysdate;
             l_special_treatment_required := 'Y';
         elsif ((l_book_class = 'TAX') and (l_Multi_GAAP_YN = 'Y') and (l_rep_deal_type  in ('LEASEDF','LEASEST')) and (p_book_type_code = l_mg_rep_book)) then
             --rirawat
             open  tax_off_trx_aus(p_cle_id , p_book_type_code);
             FETCH tax_off_trx_aus INTO l_amortization_date;
             close tax_off_trx_aus ;
             IF l_amortization_date IS NULL THEN
              open tax_off_trx_amt(p_cle_id , p_book_type_code);
              FETCH tax_off_trx_amt INTO l_amortization_date;
              close tax_off_trx_amt ;
             END IF;
             --l_amortization_date := sysdate;
             l_special_treatment_required := 'Y';
         elsif ((l_book_class = 'TAX') and (l_tax_owner ='LESSEE')) THEN
             open  tax_off_trx_aus(p_cle_id , p_book_type_code);
             FETCH tax_off_trx_aus INTO l_amortization_date;
             close tax_off_trx_aus ;
             IF l_amortization_date IS NULL THEN
              open tax_off_trx_amt(p_cle_id , p_book_type_code);
              FETCH tax_off_trx_amt INTO l_amortization_date;
              close tax_off_trx_amt ;
             END IF;
             --l_amortization_date := sysdate;
             l_special_treatment_required := 'Y';
         END IF;
     END IF;
     x_amortization_date := l_amortization_date;
     x_special_treatment_required := l_special_treatment_required;
     --Call end Activity
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
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
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_ADD
--Description    : Calls FA additions api to create new assets for
--                 and split children
--History        :
--                 28-Nov-2001  ashish.singh Created
--               Bug# 6373605 (OKL.R12.B SLA CRs
--               p_sla_source_header_id    IN Number,
--                  ID of source OKL_TRX_ASSETS record
--               p_sla_source_header_table IN Varchar2,
--                  'OKL_TRX_ASSETS'
--               p_sla_source_try_id       IN Number,
--                   OKL_TRX_ASSETS.try_id (transaction type id)
--               p_sla_source_line_id      IN Number,
--                   ID of line table (OKL_TXL_ASSETS_B or
--                                     OKL_TXD_ASSETS_B
--               p_sla_source_line_table   IN Varchar2,
--                    OKL_TXL_ASSETS_B or OKL_TXD_ASSETS_B
--               p_sla_source_chr_id       IN Number,
--                    Contract id of the contract on which
--                    source transaction happened
--               p_sla_source_kle_id       IN Number,
--                    Financial asset line id (lse_id = 33)
--               p_sla_asset_chr_id        IN Number,
--                    Contract on which asset is present
--                    at the time of transaction (in case of
--                    online rebook transaction is against the rebook
--                    copy contract whereas the asset is on
--                    original contract
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_ADD   (p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_ast_line_rec  IN  ast_line_rec_type,
                             p_txlv_rec      IN  txlv_rec_type,
                             p_txdv_rec      IN  txdv_rec_type,
                             --3156924
                             p_trx_date      IN  DATE,
                             p_trx_number    IN  NUMBER,
                             --Bug# 6373605--SLA populate source
                             p_sla_source_header_id    IN Number,
                             p_sla_source_header_table IN Varchar2,
                             p_sla_source_try_id       IN Number,
                             p_sla_source_line_id      IN Number,
                             p_sla_source_line_table   IN Varchar2,
                             p_sla_source_chr_id       IN Number,
                             p_sla_source_kle_id       IN Number,
                             p_sla_asset_chr_id        IN Number,
                             --Bug# 6373605--SLA populate source
                             --Bug# 4028371
                             x_fa_trx_date   OUT NOCOPY date,
                             x_asset_hdr_rec OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'FIXED_ASSET_ADD';
l_api_version          CONSTANT NUMBER := 1.0;

l_trans_rec                FA_API_TYPES.trans_rec_type;
l_dist_trans_rec           FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
--l_asset_fin_glob_dff_rec   FA_API_TYPES.asset_fin_glob_dff_rec_type;
l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
l_asset_hierarchy_rec      fa_api_types.asset_hierarchy_rec_type;

l_split_factor             NUMBER;

--cursor to get asset key ccid
   CURSOR asset_k_ccid_cur(p_asset_id IN NUMBER) IS
   SELECT asset_key_ccid
   FROM   fa_additions
   WHERE  asset_id = p_asset_id;

--cursor to get depreciation info
  CURSOR  deprn_cur (p_asset_id        IN NUMBER,
                     p_book_type_code  IN VARCHAR2,
                     p_split_factor IN NUMBER) IS
  SELECT  ytd_deprn           - (ytd_deprn -(ytd_deprn*p_split_factor)),
          deprn_reserve       - (deprn_reserve -(deprn_reserve*p_split_factor)),
          prior_fy_expense    - (prior_fy_expense-(prior_fy_expense*p_split_factor)),
          bonus_ytd_deprn     - (bonus_ytd_deprn-(bonus_ytd_deprn*p_split_factor)),
          bonus_deprn_reserve - (bonus_deprn_reserve-(bonus_deprn_reserve*p_split_factor))
   FROM   okx_ast_dprtns_v
   WHERE  asset_id       = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    deprn_run_date = (SELECT MAX(deprn_run_date)
                            FROM   okx_ast_dprtns_v
                            WHERE  asset_id       = p_asset_id
                            AND    book_type_code = p_book_type_code);

--cursor to get asset distribution rec
   CURSOR     ast_dist_cur (p_asset_id        IN NUMBER,
                            p_book_type_code  IN VARCHAR2,
                            p_units           IN NUMBER) IS
   SELECT --p_txdv_rec.quantity,
          --p_ast_line_rec.current_units,
          p_units,
          assigned_to,
          code_combination_id,
          location_id,
          p_units
          --p_txdv_rec.quantity
          --p_ast_line_rec.current_units
   FROM   okx_ast_dst_hst_v
   WHERE  asset_id       = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    transaction_header_id_out IS NULL
   AND    retirement_id IS NULL;

   -- Bug# 5946411 -- start
   CURSOR ast_dep_limit_csr (p_asset_id        IN NUMBER,
                             p_book_type_code  IN VARCHAR2
                            ) IS
   SELECT ALLOWED_DEPRN_LIMIT,
          ALLOWED_DEPRN_LIMIT_AMOUNT
          ,DEPRN_LIMIT_TYPE
          ,DEPRECIATE_FLAG
          --Bug# 6152614
          ,PRORATE_CONVENTION_CODE
          ,PRORATE_DATE
   FROM   FA_books
   WHERE  asset_id       = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    transaction_header_id_out IS NULL;

   l_allowed_deprn_limit  FA_books.ALLOWED_DEPRN_LIMIT%TYPE;
   l_allowed_deprn_limit_amount FA_books.allowed_deprn_limit_amount%type;
   l_deprn_limit_type  FA_books.DEPRN_LIMIT_TYPE%TYPE;
   l_depreciate_flag   FA_books.DEPRECIATE_FLAG%TYPE;
   -- Bug# 5946411 -- end
   -- Bug# 6152614
   l_prorate_convention_code   FA_books.PRORATE_CONVENTION_CODE%TYPE;
   l_prorate_date   FA_books.PRORATE_DATE%TYPE;

--cursor to fetch already created asset id if book_class is TAX ie. corp book is already created
   CURSOR  get_ast_id_cur (p_asset_number    IN VARCHAR2,
                           p_book_type_code  IN VARCHAR2) IS
   SELECT DECODE(bkc.book_class,'CORPORATE',NULL,'TAX',ast.asset_id)
   FROM   okx_assets_v ast,
          okx_asst_bk_controls_v bkc
   WHERE  ast.asset_number             = p_asset_number
   AND    ast.corporate_book           = bkc.mass_copy_source_book
   AND    bkc.book_type_code           = p_book_type_code;

  --3156924:
  l_calling_interface Varchar2(30) := 'OKLRSPAB:Split Asset';

  --Bug# 5946411
  l_asset_hdr_orig_rec            FA_API_TYPES.asset_hdr_rec_type;

 -- bug 6061103 -- start
  CURSOR l_cleb_sts_csr(pcleid IN NUMBER) IS
 SELECT cleb.sts_code sts_code,
        cleb.dnz_chr_id chr_id,
        khr.PDT_ID,
        chr.START_DATE
 FROM   okc_k_lines_b cleb,
        okl_k_headers khr,
        OKC_K_HEADERS_B chr
 WHERE  cleb.id = pcleid
         and khr.id = cleb.dnz_chr_id
         and chr.id = khr.id;
   l_cle_status okc_k_lines_b.sts_code%TYPE;
 --cursor to find book class
   CURSOR l_book_class_cur(p_book_type_code IN VARCHAR2) IS
   SELECT book_class
   FROM   okx_asst_bk_controls_v
   WHERE  book_type_code = p_book_type_code;
   l_book_class okx_asst_bk_controls_v.book_class%TYPE;
   l_pdt_id            Number;
 l_start_date        Date;
 l_chr_id        number;
  l_temp_cost    number;
   l_temp_original_cost      number;
   l_temp_salvage_value  number;
   l_temp_ytd_deprn  number;
l_temp_deprn_reserve number;
l_temp_prior_fy_expense number;
l_temp_bonus_ytd_deprn number;
l_temp_bonus_deprn_reserve number;
  l_amortization_date DATE;
 l_special_treatment_required VARCHAR2(1);
 l_adj_trans_rec               FA_API_TYPES.trans_rec_type;
l_adj_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
l_adj_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
l_adj_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
--l_asset_fin_glob_dff_rec  FA_API_TYPES.asset_fin_glob_dff_rec_type;
l_adj_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;
l_adj_inv_tbl                 FA_API_TYPES.inv_tbl_type;
l_adj_inv_rate_tbl            FA_API_TYPES.inv_rate_tbl_type;
l_adj_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
l_adj_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
l_adj_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
l_adj_inv_rec                 FA_API_TYPES.inv_rec_type;
l_adj_asset_deprn_rec         FA_API_TYPES.asset_deprn_rec_type;
l_adj_group_recalss_option_rec FA_API_TYPES.group_reclass_options_rec_type;
-- bug 6061103 -- end

  --Bug# 6373605 begin
  l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
  l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;
  --Bug# 6373605 end

--Bug# 6955027
x_log_level_rec              FA_API_TYPES.log_level_rec_type;

BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

   --dbms_output.enable(1000000);

   --FA_SRVR_MSG.Init_Server_Message;
   --FA_DEBUG_PKG.Initialize;

   --Bug# 6955027
   IF NOT FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => p_ast_line_rec.corporate_book,
           X_asset_id          => p_ast_line_rec.asset_id,
           X_trx_type          => 'ADJUSTMENT',
           X_trx_date          => NULL,
           X_init_message_flag => 'NO',
           p_log_level_rec     => x_log_level_rec) then
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   --Bug# 6955027

   -----------------
   --trans_rec_info
   -----------------
   l_trans_rec.transaction_type_code         := 'ADDITION'; --optional
   --Bug# 3156924 :
   --l_trans_rec.transaction_date_entered      := p_ast_line_rec.in_service_date; --optional.defaults to dpis
   --l_trans_rec.transaction_date_entered      := p_trx_date; --optional.defaults to dpis
   l_trans_rec.who_info.last_updated_by      := FND_GLOBAL.USER_ID;
   --l_trans_rec.calling_interface             := 'OKL SPLIT ASSET';
   --Bug# 3156924 :
   l_trans_rec.calling_interface             := l_calling_interface; --optional
   l_trans_rec.transaction_name              := SUBSTR(TO_CHAR(p_trx_number),1,20); --optional


   ---------------
   --hdr_rec info
   --------------
   l_asset_hdr_rec.book_type_code    := p_ast_line_rec.corporate_book;
   l_asset_hdr_rec.set_of_books_id   := p_ast_line_rec.set_of_books_id;
   l_asset_hdr_rec.asset_id          := NULL;

   --for tax books fetch the asset id
   OPEN  get_ast_id_cur (p_asset_number    => p_txdv_rec.asset_number,
                         p_book_type_code  => p_ast_line_rec.corporate_book);
       FETCH get_ast_id_cur INTO l_asset_hdr_rec.asset_id;
       IF get_ast_id_cur%NOTFOUND THEN
           NULL;
       END IF;
   CLOSE get_ast_id_cur;

   ---------------
   -- desc info
   ---------------
   l_asset_desc_rec.asset_number       := p_txdv_rec.asset_number;
   l_asset_desc_rec.description        := p_txdv_rec.description;
   l_asset_desc_rec.manufacturer_name  := p_ast_line_rec.manufacturer_name;
   l_asset_desc_rec.in_use_flag        := p_ast_line_rec.in_use_flag;
   l_asset_desc_rec.inventorial        := p_ast_line_rec.inventorial;
   l_asset_desc_rec.property_type_code := p_ast_line_rec.property_type_code;
   l_asset_desc_rec.property_1245_1250_code     := p_ast_line_rec.property_1245_1250_code;
   l_asset_desc_rec.owned_leased       := p_ast_line_rec.owned_leased;
   l_asset_desc_rec.new_used           := p_ast_line_rec.new_used;
   --Bug# 2761799: model number not being copied
   l_asset_desc_rec.model_number       := p_ast_line_rec.model_number;


   OPEN asset_k_ccid_cur(p_asset_id => p_ast_line_rec.asset_id);
       FETCH asset_k_ccid_cur INTO l_asset_desc_rec.asset_key_ccid;
       IF asset_k_ccid_cur%NOTFOUND THEN
           NULL;
       END IF;
   CLOSE asset_k_ccid_cur;

   IF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN
        l_split_factor := (p_txdv_rec.split_percent/100);
        l_asset_desc_rec.current_units := p_ast_line_rec.current_units;
   ELSE
        l_split_factor := (p_txdv_rec.quantity/p_txlv_rec.current_units);
         --l_asset_desc_rec.current_units                := p_txdv_rec.quantity;
        l_asset_desc_rec.current_units                := p_ast_line_rec.current_units -
                                                    (p_ast_line_rec.current_units -
                                                     (p_ast_line_rec.current_units*l_split_factor)
                                                      );
   END IF;


   --original_units - (original_units - (original_units*split_factor))
   --this should actually be on the current quantity and not on the qty when trx was saved
   --modify it later

   ----------------------
   --asset_type_rec info
   ---------------------
   l_asset_type_rec.asset_type := p_ast_line_rec.asset_type;

   ----------------------
   --asset_cat_rec_info
   ---------------------
   l_asset_cat_rec.category_id  := p_ast_line_rec.depreciation_category;

   --asset_fin_rec
   l_asset_fin_rec.set_of_books_id         := p_ast_line_rec.set_of_books_id;
   --3156924
   l_asset_fin_rec.date_placed_in_service  := p_ast_line_rec.in_service_date;
   --l_asset_fin_rec.date_placed_in_service  := p_trx_date;
   l_asset_fin_rec.deprn_method_code       := p_ast_line_rec.deprn_method_code;
   l_asset_fin_rec.life_in_months          := p_ast_line_rec.life_in_months;
   l_asset_fin_rec.cost                    := p_ast_line_rec.cost          -(p_ast_line_rec.cost- (p_ast_line_rec.cost*l_split_factor));
   l_asset_fin_rec.original_cost           := p_ast_line_rec.original_cost -(p_ast_line_rec.original_cost - (p_ast_line_rec.original_cost*l_split_factor));
   l_asset_fin_rec.salvage_value           := p_ast_line_rec.salvage_value -(p_ast_line_rec.salvage_value -(p_ast_line_rec.salvage_value*l_split_factor));
   l_asset_fin_rec.basic_rate              := p_ast_line_rec.basic_rate;
   l_asset_fin_rec.adjusted_rate           := p_ast_line_rec.adjusted_rate;
   l_asset_fin_rec.percent_salvage_value   := p_ast_line_rec.percent_salvage_value;
   l_asset_fin_rec.rate_adjustment_factor  := 1;

   -- Bug# 5946411 -- start
   OPEN  ast_dep_limit_csr (p_asset_id       => p_ast_line_rec.asset_id,
                            p_book_type_code => p_ast_line_rec.corporate_book);

   FETCH ast_dep_limit_csr INTO l_allowed_deprn_limit,
                            l_allowed_deprn_limit_amount,
                            l_deprn_limit_type,
                            l_depreciate_flag
                            --Bug# 6152614
                            ,l_prorate_convention_code
                            ,l_prorate_date;

   IF ast_dep_limit_csr%NOTFOUND THEN
        NULL;
   END IF;
   CLOSE ast_dep_limit_csr;
   l_asset_fin_rec.allowed_deprn_limit := l_allowed_deprn_limit;
   l_asset_fin_rec.allowed_deprn_limit_amount := l_allowed_deprn_limit_amount;
   -- Bug# 6152614
   l_asset_fin_rec.prorate_convention_code := l_prorate_convention_code;
   l_asset_fin_rec.prorate_date :=  l_prorate_date;
   -- Bug# 5946411 -- end

   --Bug# 6373605 start
   l_asset_fin_rec.contract_id            := p_sla_asset_chr_id;
   --Bug# 6373605 end

   -----------------
   --Bug# 3156924
   ----------------
   --l_asset_fin_rec.depreciate_flag         := 'YES';

   l_asset_deprn_rec.set_of_books_id := p_ast_line_rec.set_of_books_id;

   /* Bug# 5946411
    --commented following and added FA_UTIL to retrive asset deprn_rec

   OPEN  deprn_cur (p_asset_id       => p_ast_line_rec.asset_id,
                    p_book_type_code => p_ast_line_rec.corporate_book,
                    p_split_factor   => l_split_factor);

       FETCH deprn_cur INTO l_asset_deprn_rec.ytd_deprn,
                            l_asset_deprn_rec.deprn_reserve,
                            l_asset_deprn_rec.prior_fy_expense,
                            l_asset_deprn_rec.bonus_ytd_deprn,
                            l_asset_deprn_rec.bonus_deprn_reserve;
       IF deprn_cur%NOTFOUND THEN
           NULL;
       END IF;
   CLOSE deprn_cur;

   */
   l_asset_fin_rec.depreciate_flag := l_depreciate_flag;
   l_asset_fin_rec.deprn_limit_type :=l_deprn_limit_type;
   if NOT fa_cache_pkg.fazcbc(x_book => p_ast_line_rec.corporate_book) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
   end if;
   l_asset_hdr_orig_rec.asset_id:=p_ast_line_rec.asset_id;
   l_asset_hdr_orig_rec.book_type_code    := p_ast_line_rec.corporate_book;
   -- To fetch Depreciation Reserve
   if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_orig_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => 'P'
                 ) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
   end if;
   l_asset_deprn_rec.ytd_deprn:= l_asset_deprn_rec.ytd_deprn - (l_asset_deprn_rec.ytd_deprn -(l_asset_deprn_rec.ytd_deprn*l_split_factor));
   l_asset_deprn_rec.deprn_reserve:= l_asset_deprn_rec.deprn_reserve       - (l_asset_deprn_rec.deprn_reserve -(l_asset_deprn_rec.deprn_reserve*l_split_factor));
   l_asset_deprn_rec.prior_fy_expense:=l_asset_deprn_rec.prior_fy_expense    - (l_asset_deprn_rec.prior_fy_expense-(l_asset_deprn_rec.prior_fy_expense*l_split_factor));
   l_asset_deprn_rec.bonus_ytd_deprn:=l_asset_deprn_rec.bonus_ytd_deprn     - (l_asset_deprn_rec.bonus_ytd_deprn-(l_asset_deprn_rec.bonus_ytd_deprn*l_split_factor));
   l_asset_deprn_rec.bonus_deprn_reserve:=l_asset_deprn_rec.bonus_deprn_reserve - (l_asset_deprn_rec.bonus_deprn_reserve-(l_asset_deprn_rec.bonus_deprn_reserve*l_split_factor));

   -- Bug# 6189396 -- start
   okl_execute_formula_pub.g_additional_parameters(1).name := 'SPLIT_ASSET_DEPRN_RESRVE';
   okl_execute_formula_pub.g_additional_parameters(1).value := to_char(l_asset_deprn_rec.deprn_reserve);
   -- Bug# 6189396 -- end

   ---------------------------------------------------------------------------------------
   --Bug# 3156924 : Due to partial retirement ytd_deprn may get greater than deprn_reserve
   ---------------------------------------------------------------------------------------
   IF l_asset_deprn_rec.ytd_deprn > l_asset_deprn_rec.deprn_reserve THEN
      l_asset_deprn_rec.ytd_deprn := l_asset_deprn_rec.deprn_reserve;
   END IF;

   --asset_dist_rec
   OPEN     ast_dist_cur (p_asset_id        => p_ast_line_rec.asset_id,
                          p_book_type_code  => p_ast_line_rec.corporate_book,
                          p_units           => l_asset_desc_rec.current_units);

       FETCH     ast_dist_cur INTO l_asset_dist_rec.units_assigned,
                                   l_asset_dist_rec.assigned_to,
                                   l_asset_dist_rec.expense_ccid,
                                   l_asset_dist_rec.location_ccid,
                                   l_asset_dist_rec.transaction_units;

       IF  ast_dist_cur%NOTFOUND THEN
           NULL;
       END IF;

   CLOSE ast_dist_cur;

      -- bug 6061103 start
    OPEN l_cleb_sts_csr(  p_txlv_rec.kle_id);
    FETCH l_cleb_sts_csr INTO l_cle_status, l_chr_id, l_pdt_id, l_start_date ;
    close l_cleb_sts_csr;
     is_evergreen_df_lease
                   (p_api_version     =>  p_api_version,
                    p_init_msg_list   =>  p_init_msg_list,
                    x_return_status   =>  x_return_status,
                    x_msg_count       =>  x_msg_count,
                    x_msg_data        =>  x_msg_data,
                    p_cle_id          =>  p_ast_line_rec.PARENT_LINE_ID ,--p_ast_line_rec.asset_id, rirawat
                    p_book_type_code   =>  p_ast_line_rec.corporate_book,
                    p_asset_status    => l_cle_status,
                    p_pdt_id          => l_pdt_id,
                    p_start_date      => l_start_date,
                    x_amortization_date => l_amortization_date,
                    x_special_treatment_required => l_special_treatment_required);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
    if (l_special_treatment_required = 'Y') then
         l_temp_cost := l_asset_fin_rec.cost;
         l_temp_original_cost := l_asset_fin_rec.original_cost;
         l_temp_salvage_value := l_asset_fin_rec.salvage_value;
         l_temp_ytd_deprn := l_asset_deprn_rec.ytd_deprn;
         l_temp_deprn_reserve := l_asset_deprn_rec.deprn_reserve;
         l_temp_prior_fy_expense := l_asset_deprn_rec.prior_fy_expense;
         l_temp_bonus_ytd_deprn := l_asset_deprn_rec.bonus_ytd_deprn ;
         l_temp_bonus_deprn_reserve := l_asset_deprn_rec.bonus_deprn_reserve;
         l_asset_fin_rec.cost              := 0;
         l_asset_fin_rec.original_cost           := 0;
         l_asset_fin_rec.salvage_value           := 0 ;
         l_asset_deprn_rec.ytd_deprn:= 0;
         l_asset_deprn_rec.deprn_reserve:= 0;
         l_asset_deprn_rec.prior_fy_expense:= 0;
         l_asset_deprn_rec.bonus_ytd_deprn:= 0;
         l_asset_deprn_rec.bonus_deprn_reserve:= 0;
   end if;
     -- bug 6061103 end
   l_asset_dist_tbl(1) := l_asset_dist_rec;

   --dbms_output.put_line('Add '||l_asset_desc_rec.asset_number || ' Deprn reserve '||to_char(l_asset_deprn_rec.deprn_reserve));
   -- call the api
   fa_addition_pub.do_addition
      (p_api_version             => p_api_version,
       p_init_msg_list           => OKL_API.G_FALSE,
       p_commit                  => OKL_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       --Bug# 3156924
       p_calling_fn              => l_calling_interface,
       px_trans_rec              => l_trans_rec,
       px_dist_trans_rec         => l_dist_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       px_asset_desc_rec         => l_asset_desc_rec,
       px_asset_type_rec         => l_asset_type_rec,
       px_asset_cat_rec          => l_asset_cat_rec,
       px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
       px_asset_fin_rec          => l_asset_fin_rec,
       px_asset_deprn_rec        => l_asset_deprn_rec,
       px_asset_dist_tbl         => l_asset_dist_tbl,
       px_inv_tbl                => l_inv_tbl
      );

     --dbms_output.put_line(x_return_status);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

      --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --bug# 6373605 -- call populate SLA sources

     --Bug# 6061103
     if (l_special_treatment_required = 'Y') and (l_temp_cost <> 0) then
         l_adj_trans_rec.transaction_subtype     := 'AMORTIZED';
         --Bug# 6331465
         --l_adj_trans_rec.amortization_start_date := l_amortization_date;
         l_adj_trans_rec.transaction_name  := SUBSTR(TO_CHAR(p_trx_number),1,20); --optional
         l_adj_trans_rec.calling_interface := l_calling_interface; --optional
         l_adj_asset_fin_rec_adj.cost              := l_temp_cost;
         l_adj_asset_fin_rec_adj.original_cost           := l_temp_original_cost;
         l_adj_asset_fin_rec_adj.salvage_value           := l_temp_salvage_value ;
         l_adj_asset_deprn_rec_adj.ytd_deprn:= l_temp_ytd_deprn;
         l_adj_asset_deprn_rec_adj.deprn_reserve:= l_temp_deprn_reserve;
         l_adj_asset_deprn_rec_adj.prior_fy_expense:= l_temp_prior_fy_expense;
         l_adj_asset_deprn_rec_adj.bonus_ytd_deprn:= l_temp_bonus_ytd_deprn;
         l_adj_asset_deprn_rec_adj.bonus_deprn_reserve:= l_temp_bonus_deprn_reserve;

         FA_ADJUSTMENT_PUB.do_adjustment
          (p_api_version             => p_api_version,
           p_init_msg_list           => p_init_msg_list,
           p_commit                  => OKL_API.G_FALSE,
           p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
           x_return_status           => x_return_status,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           --Bug# 3156924
           --p_calling_fn              => null,
           p_calling_fn              => l_calling_interface,
           px_trans_rec              => l_adj_trans_rec,
           px_asset_hdr_rec          => l_asset_hdr_rec,
           p_asset_fin_rec_adj       => l_adj_asset_fin_rec_adj,
           x_asset_fin_rec_new       => l_adj_asset_fin_rec_new,
           x_asset_fin_mrc_tbl_new   => l_adj_asset_fin_mrc_tbl_new,
           px_inv_trans_rec          => l_adj_inv_trans_rec,
           px_inv_tbl                => l_adj_inv_tbl,
           p_asset_deprn_rec_adj     => l_adj_asset_deprn_rec_adj,
           x_asset_deprn_rec_new     => l_adj_asset_deprn_rec_new,
           x_asset_deprn_mrc_tbl_new => l_adj_asset_deprn_mrc_tbl_new,
           p_group_reclass_options_rec => l_adj_group_recalss_option_rec
          );
          --dbms_output.put_line('After calling FA adjustment Api '||x_return_status);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --bug# 6373605 -- call populate sla sources
         l_fxhv_rec.source_id := p_sla_source_header_id;
         l_fxhv_rec.source_table := p_sla_source_header_table;
         l_fxhv_rec.khr_id := p_sla_source_chr_id;
         l_fxhv_rec.try_id := p_sla_source_try_id;

         l_fxlv_rec.source_id := p_sla_source_line_id;
         l_fxlv_rec.source_table := p_sla_source_line_table;
         l_fxlv_rec.kle_id := p_sla_source_kle_id;

         l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
         l_fxlv_rec.fa_transaction_id := l_adj_trans_rec.transaction_header_id;
         l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

         OKL_SLA_ACC_SOURCES_PVT.populate_sources(
           p_api_version  => p_api_version
           ,p_init_msg_list => p_init_msg_list
           ,p_fxhv_rec => l_fxhv_rec
           ,p_fxlv_rec => l_fxlv_rec
           ,x_return_status => x_return_status
           ,x_msg_count    => x_msg_count
           ,x_msg_data    => x_msg_data
          );
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         --bug# 6373605 -- call populate SLA sources

     end if;
     x_asset_hdr_rec := l_asset_hdr_rec;
     --Bug# 4028371
     x_fa_trx_date   := l_adj_trans_rec.transaction_date_entered;  -- for 6061103 chaged to adj

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
END FIXED_ASSET_ADD;
--Bug# 3156924
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_UNIT_ADJUST
--Description    : Does unit adjustment on parent asset (source asset to split) in FA
--History        :
--                 26-Feb-2004  ashish.singh Created
--End of Comments
--------------------------------------------------------------------------------
  PROCEDURE FIXED_ASSET_unit_adjust
                             (p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_ast_line_rec  IN  ast_line_rec_type,
                              p_txlv_rec      IN  txlv_rec_type,
                              p_txdv_rec      IN  txdv_rec_type,
                              --Bug# 3156924
                              p_trx_date      IN  DATE,
                              p_trx_number  IN  NUMBER,
                              --Bug# 4028371
                              x_fa_trx_date OUT NOCOPY DATE) IS

  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'FIXED_ASSET_UNIT_ADJ';
  l_api_version          CONSTANT NUMBER := 1.0;


  l_trans_rec          fa_api_types.trans_rec_type;
  l_asset_hdr_rec      fa_api_types.asset_hdr_rec_type;
  l_asset_dist_tbl     fa_api_types.asset_dist_tbl_type;

  l_calling_interface  VARCHAR2(30) := 'OKL:Split Asset';
  l_units_to_adjust    NUMBER;
  i                    NUMBER;
  l_split_factor       NUMBER;


   --cursor to get the distributions
   CURSOR    l_dist_curs(p_asset_id       IN NUMBER,
                        p_corporate_book IN VARCHAR2) IS
   SELECT  units_assigned,
           distribution_id
   FROM    OKX_AST_DST_HST_V
   WHERE   asset_id = p_ast_line_rec.asset_id
   AND     book_type_code = p_ast_line_rec.corporate_book
   AND     transaction_header_id_out IS NULL
   AND     retirement_id IS NULL;

   l_units_assigned   NUMBER;
   l_distribution_id  NUMBER;

  BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

      l_split_factor           := (p_txdv_rec.quantity/p_txlv_rec.current_units);
      l_asset_hdr_rec.asset_id := p_ast_line_rec.asset_id;
      l_asset_hdr_rec.book_type_code := p_ast_line_rec.corporate_book;

      -- transaction date must be filled in if performing
      -- prior period transfer
      l_trans_rec.transaction_date_entered := NULL;
      l_trans_rec.transaction_name          := SUBSTR(TO_CHAR(p_trx_number),1,20);
      l_trans_rec.calling_interface         := l_calling_interface;
      l_trans_rec.who_info.last_updated_by := FND_GLOBAL.USER_ID;
      l_trans_rec.who_info.last_update_login := FND_GLOBAL.LOGIN_ID;


      l_asset_dist_tbl.DELETE;

      l_units_to_adjust := p_ast_line_rec.current_units - (p_ast_line_rec.current_units*l_split_factor);

       --dbms_output.put_line('Units to adjust outside loop'||l_units_to_adjust );
       i := 1;
       OPEN l_dist_curs(p_ast_line_rec.asset_id, p_ast_line_rec.corporate_book);
       LOOP
           FETCH l_dist_curs INTO l_units_assigned, l_distribution_id;
           EXIT WHEN l_dist_curs%NOTFOUND;
           IF l_units_to_adjust = 0 THEN
              EXIT;
           ELSIF l_units_to_adjust >= l_units_assigned THEN
              l_asset_dist_tbl(i).distribution_id := l_distribution_id;
              l_asset_dist_tbl(i).transaction_units := (-1)*l_units_assigned;
              --dbms_output.put_line('Units to adjust '||to_char(l_asset_dist_tbl(i).transaction_units));
              l_asset_dist_tbl(i).units_assigned := NULL;
              l_asset_dist_tbl(i).assigned_to := NULL;
              l_asset_dist_tbl(i).expense_ccid := NULL;
              l_asset_dist_tbl(i).location_ccid := NULL;
              l_units_to_adjust := l_units_to_adjust - l_units_assigned;
              i := i + 1;
           ELSIF l_units_to_adjust < l_units_assigned THEN
              l_asset_dist_tbl(i).distribution_id := l_distribution_id;
              l_asset_dist_tbl(i).transaction_units := (-1)*l_units_to_adjust;
              --dbms_output.put_line('Units to adjust '||to_char(l_asset_dist_tbl(i).transaction_units));
              l_asset_dist_tbl(i).units_assigned := NULL;
              l_asset_dist_tbl(i).assigned_to := NULL;
              l_asset_dist_tbl(i).expense_ccid := NULL;
              l_asset_dist_tbl(i).location_ccid := NULL;
              l_units_to_adjust := l_units_to_adjust - l_units_to_adjust;
              i := i + 1;
           END IF;
       END LOOP;
       CLOSE l_dist_curs;

      FA_UNIT_ADJ_PUB.do_unit_adjustment(
           p_api_version       => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           p_commit            => FND_API.G_FALSE,
           p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
           --bug# 3156924 :
           p_calling_fn        => l_calling_interface,
           --p_calling_fn        => NULL,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           px_trans_rec        => l_trans_rec,
           px_asset_hdr_rec    => l_asset_hdr_rec,
           px_asset_dist_tbl   => l_asset_dist_tbl);

         --dbms_output.put_line('After calling FA unit adjust Api '||x_return_status);
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
END FIXED_ASSET_unit_ADJUST;
--Bug# 3156924
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : FIXED_ASSET_RETIRE
--Description    : Retires the Parent fixed Asset (source asset to split) in FA
--History        :
--                 20-Dec-2001  ashish.singh Created
--                 24-Jul-2002  ashish.singh Modified to take care of Full
--                              retirement for split asset compoents
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_RETIRE (p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_ast_line_rec  IN  ast_line_rec_type,
                              p_txlv_rec      IN  txlv_rec_type,
                              p_txdv_rec      IN  txdv_rec_type,
                              --Bug# 3156924
                              p_trx_date      IN  DATE,
                              p_trx_number  IN  NUMBER,
                              --Bug# 4028371
                              x_fa_trx_date OUT NOCOPY date) IS

   l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
   l_api_name             CONSTANT VARCHAR2(30) := 'FIXED_ASSET_RETIRE';
   l_api_version          CONSTANT NUMBER := 1.0;

   l_user_id                 NUMBER := 1001; -- USER_ID must properly be set to run calc gain/loss
   l_request_id              NUMBER;
   l_split_factor            NUMBER;
   l_units_to_retire         NUMBER;

   /* define local record types */
   l_trans_rec              FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec       FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl         FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl            FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl                FA_API_TYPES.inv_tbl_type;
   l_dist_trans_rec         FA_API_TYPES.trans_rec_type;


   l_commit                VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level      NUMBER := FND_API.G_VALID_LEVEL_FULL;
   l_calling_fn            VARCHAR2(80) := 'OKL_SPLIT_ASSET_PVT';

   i                       NUMBER := 0;

   --cursor to get the distributions
   CURSOR    l_dist_curs(p_asset_id       IN NUMBER,
                         p_corporate_book IN VARCHAR2) IS
   SELECT  units_assigned,
           distribution_id
   FROM    OKX_AST_DST_HST_V
   WHERE   asset_id = p_ast_line_rec.asset_id
   AND     book_type_code = p_ast_line_rec.corporate_book
   AND     transaction_header_id_out IS NULL
   AND     retirement_id IS NULL;

   l_units_assigned   NUMBER;
   l_distribution_id  NUMBER;

--cursor to find book class
   CURSOR l_book_class_cur(p_book_type_code IN VARCHAR2) IS
   SELECT book_class
   FROM   okx_asst_bk_controls_v
   WHERE  book_type_code = p_book_type_code;

   l_book_class okx_asst_bk_controls_v.book_class%TYPE;

--debug variables
  api_error EXCEPTION;
  mesg_count NUMBER;
  temp_str   VARCHAR2(2000);

  --Bug# 3156924 : cursor to get retirement prorate convention from defaults
  CURSOR l_fcbd_csr (p_book_type_code IN VARCHAR2,
                     p_category_id IN NUMBER,
                     p_dpis        IN DATE) IS
  SELECT retirement_prorate_convention
  FROM   fa_category_book_defaults
  WHERE  book_type_code = p_book_type_code
  AND    category_id    = p_category_id
  AND    p_dpis BETWEEN start_dpis AND NVL(end_dpis,p_dpis);

  l_retire_prorate_convention fa_category_book_defaults.retirement_prorate_convention%TYPE;

    --Bug# 3156924 :
   l_calling_interface     CONSTANT VARCHAR2(30) := 'OKLRSPAB:Split Asset';
   --Bug# 4028371
   l_fa_unit_adj_date      date;


BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
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


   --dbms_output.disable;
   --dbms_output.enable(1000000);
   --dbms_output.put_line('begin');
   --fa_srvr_msg.init_server_message;
   --fa_debug_pkg.set_debug_flag(debug_flag => 'YES');

   -- Get standard who info
   l_request_id := fnd_global.conc_request_id;
   fnd_profile.get('LOGIN_ID', l_trans_rec.who_info.last_update_login);
   fnd_profile.get('USER_ID', l_trans_rec.who_info.last_updated_by);
   IF (l_trans_rec.who_info.last_updated_by IS NULL) THEN
      l_trans_rec.who_info.last_updated_by := -1;
   END IF;
   IF (l_trans_rec.who_info.last_update_login IS NULL) THEN
      l_trans_rec.who_info.last_update_login := -1;
   END IF;

   l_trans_rec.who_info.last_update_date := SYSDATE;
   l_trans_rec.who_info.creation_date    :=  l_trans_rec.who_info.last_update_date;
   l_trans_rec.who_info.created_by       :=  l_trans_rec.who_info.last_updated_by;

   l_trans_rec.transaction_type_code    := NULL; -- this will be determined inside API
   l_trans_rec.transaction_date_entered := NULL; --defaults to dpis
   --Bug# 3156924 :
   l_trans_rec.calling_interface        := l_calling_interface;
   l_trans_rec.transaction_name         := SUBSTR(TO_CHAR(p_trx_number),1,20);

   l_asset_hdr_rec.asset_id           := p_ast_line_rec.asset_id;
   l_asset_hdr_rec.book_type_code     := p_ast_line_rec.corporate_book;
   l_asset_hdr_rec.period_of_addition := NULL;

   l_split_factor := (p_txdv_rec.quantity/p_txlv_rec.current_units);

   --Bug# 3156924 :
   OPEN l_fcbd_csr(p_book_type_code   => l_asset_hdr_rec.book_type_code,
                   p_category_id      => p_ast_line_rec.depreciation_category,
                   p_dpis             => p_ast_line_rec.in_service_date);

   FETCH l_fcbd_csr INTO l_retire_prorate_convention;
   IF l_fcbd_csr%NOTFOUND THEN
       NULL;
   END IF;
   CLOSE l_fcbd_csr;

   --l_asset_retire_rec.retirement_prorate_convention := 'MID-MONTH';
   l_asset_retire_rec.retirement_prorate_convention := l_retire_prorate_convention;
    -- what should retirement prorate convntion be
   --l_asset_retire_rec.date_retired := NULL; -- will be current period by default
   --3156924 :
   --l_asset_retire_rec.date_retired := p_trx_date; -- will be current period by default

   IF NVL(p_txdv_rec.split_percent,0) <> 0 OR p_txdv_rec.split_percent <> OKL_API.G_MISS_NUM THEN
       --fully retire for split asset compoents
       l_asset_retire_rec.units_retired := NULL;
       l_asset_retire_rec.cost_retired := p_ast_line_rec.cost;
   ELSE
      --partially retire for normal split asset
      --Bug# 3156924 : either units or cost should be retired
      --l_asset_retire_rec.units_retired := p_ast_line_rec.current_units -(p_ast_line_rec.current_units*l_split_factor);
      --l_asset_retire_rec.cost_retired := 30000;
      l_asset_retire_rec.cost_retired := p_ast_line_rec.cost - (p_ast_line_rec.cost*l_split_factor);
   END IF;

   l_asset_retire_rec.proceeds_of_sale := 0;
   l_asset_retire_rec.cost_of_removal := 0;
   l_asset_retire_rec.retirement_type_code := FND_PROFILE.VALUE('OKL_SPLIT_ASSET_RETIRE_TYPE');
   --l_asset_retire_rec.retirement_type_code := 'SPLIT';
   l_asset_retire_rec.trade_in_asset_id := NULL;
   --l_asset_retire_rec.calculate_gain_loss := FND_API.G_FALSE;
   l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;
   --assign this to FND_API.G_TRUE if it is required to calculate the gain loss

   fnd_profile.put('USER_ID',l_user_id);

   IF NVL(p_txdv_rec.split_percent,0) <> 0 OR p_txdv_rec.split_percent <> OKL_API.G_MISS_NUM THEN
      --no need to do distribution level retirements as full retirment being done
      -- for split asset components
      NULL;
   ELSE

      --do distribution level unit adjustments
      l_book_class := NULL;

      OPEN l_book_class_cur(p_book_type_code => p_ast_line_rec.corporate_book);
          FETCH l_book_class_cur INTO l_book_class;
          IF l_book_class_cur%NOTFOUND THEN
             NULL;
          END IF;
      CLOSE l_book_class_cur;


      IF l_book_class = 'CORPORATE' THEN
          --Bug# 3156924 : either do cost retire or units retire
          FIXED_ASSET_unit_adjust
                             (p_api_version   => p_api_version ,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_ast_line_rec  => p_ast_line_rec,
                              p_txlv_rec      => p_txlv_rec,
                              p_txdv_rec      => p_txdv_rec,
                              --Bug# 3156924
                              p_trx_date      => p_trx_date,
                              p_trx_number    => p_trx_number,
                              --Bug# 4028371
                              x_fa_trx_date   => l_fa_unit_adj_date);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --Bug# 3156924
         /*---------------commented; either retire cost or units---------------------------------------
         --l_asset_dist_tbl.delete;
         --how to find which distribution to retire from ??
        --l_units_to_retire := p_ast_line_rec.current_units -(p_ast_line_rec.current_units*l_split_factor);
        --i := 1;
        --open l_dist_curs(p_ast_line_rec.asset_id, p_ast_line_rec.corporate_book);
        --Loop
            --Fetch l_dist_curs into l_units_assigned, l_distribution_id;
            --Exit When l_dist_curs%NOTFOUND;
            --If l_units_to_retire = 0 Then
               --Exit;
            --Elsif l_units_to_retire >= l_units_assigned Then
               --l_asset_dist_tbl(i).distribution_id := l_distribution_id;
               --l_asset_dist_tbl(i).transaction_units := (-1)*l_units_assigned;
               --l_asset_dist_tbl(i).units_assigned := null;
               --l_asset_dist_tbl(i).assigned_to := null;
               --l_asset_dist_tbl(i).expense_ccid := null;
               --l_asset_dist_tbl(i).location_ccid := null;
               --l_units_to_retire := l_units_to_retire - l_units_assigned;
               --i := i + 1;
            --Elsif l_units_to_retire < l_units_assigned Then
               --l_asset_dist_tbl(i).distribution_id := l_distribution_id;
               --l_asset_dist_tbl(i).transaction_units := (-1)*l_units_to_retire;
               --l_asset_dist_tbl(i).units_assigned := null;
               --l_asset_dist_tbl(i).assigned_to := null;
               --l_asset_dist_tbl(i).expense_ccid := null;
               --l_asset_dist_tbl(i).location_ccid := null;
               --l_units_to_retire := l_units_to_retire - l_units_to_retire;
               --i := i + 1;
            --End If;
         --End Loop;
         --close l_dist_curs;
         -------------------------------------------------------------------------------------------------*/
         --end of commented code : 3156924
     END IF;
   --bug# 3156924
   END IF;

--   l_asset_dist_tbl(2).distribution_id := 1338;
--   l_asset_dist_tbl(2).transaction_units := -1;
--   l_asset_dist_tbl(2).units_assigned := null;
--   l_asset_dist_tbl(2).assigned_to := null;
--   l_asset_dist_tbl(2).expense_ccid := null;
--   l_asset_dist_tbl(2).location_ccid := null;


   FA_RETIREMENT_PUB.do_retirement
   (p_api_version               => p_api_version
   ,p_init_msg_list             => p_init_msg_list
   ,p_commit                    => l_commit
   ,p_validation_level          => l_validation_level
   --Bug# 3156924:
   --,p_calling_fn                => l_calling_fn
   ,p_calling_fn                => l_calling_interface
   ,x_return_status             => x_return_status
   ,x_msg_count                 => x_msg_count
   ,x_msg_data                  => x_msg_data
   ,px_trans_rec                => l_trans_rec
   ,px_dist_trans_rec           => l_dist_trans_rec
   ,px_asset_hdr_rec            => l_asset_hdr_rec
   ,px_asset_retire_rec         => l_asset_retire_rec
   ,p_asset_dist_tbl            => l_asset_dist_tbl
   ,p_subcomp_tbl               => l_subcomp_tbl
   ,p_inv_tbl                   => l_inv_tbl
   );

/*--------------------FA Debugging Code Commented ------------------------------
    if x_return_status = FND_API.G_FALSE then
      raise api_error;
   end if;

   -- Dump Debug messages when run in debug mode to log file
   if (fa_debug_pkg.print_debug) then
      fa_debug_pkg.Write_Debug_Log;
   end if;

   fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => 'FA_SHARED_END_SUCCESS',
         token1     => 'PROGRAM',
         value1     => 'RETIREMENT_API');

   mesg_count := fnd_msg_pub.count_msg;

   if (mesg_count > 0) then
        temp_str := fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE);
        --dbms_output.put_line('dump: ' || temp_str);

        for I in 1..(mesg_count -1) loop
            temp_str := fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE);
            --dbms_output.put_line('dump: ' || temp_str);
        end loop;
    else
        --dbms_output.put_line('dump: NO MESSAGE !');
    end if;
--------------------FA Debugging Code Commented END------------------------------*/
     --dbms_output.put_line('After do retirement :'||x_return_status);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --Bug# 3156924
     --End If;
     --x_asset_hdr_rec := l_asset_hdr_rec;
     --Bug# 4028371
     x_fa_trx_date    := l_trans_rec.transaction_date_entered;
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
/*--------------------FA Debugging Code Commented -------------------------------
       when api_error then
       ROLLBACK WORK;

       fa_srvr_msg.add_message(
         calling_fn => l_calling_fn,
         name       => 'FA_SHARED_PROGRAM_FAILED',
         token1     => 'PROGRAM',
         value1     => l_calling_fn);

       mesg_count := fnd_msg_pub.count_msg;
       if (mesg_count > 0) then
          temp_str := fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE);
          --dbms_output.put_line('dump: ' || temp_str);

          for I in 1..(mesg_count -1) loop
              temp_str := fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE);
              --dbms_output.put_line('dump: ' || temp_str);
          end loop;
       else
          --dbms_output.put_line('dump: NO MESSAGE !');
       end if;
--------------------FA Debugging Code Commented END -----------------------------*/
        WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');


END FIXED_ASSET_RETIRE;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : Fixed_Asset_Adjust
--Description    : Adjusts the Parent fixed Asset (source asset to split) in FA
--History        :
--                 29-Nov-2001  ashish.singh Created
--                 25-JUL-2002  ashish.singh Enhancement for Fixed Asset componet
--                                           split
--               Bug# 6373605 -R12.B SAL CRs
--               New IN parameters as descriped earlier in
--               FIXED_ASSET_ADD
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE FIXED_ASSET_ADJUST(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_ast_line_rec  IN  ast_line_rec_type,
                             p_txlv_rec      IN  txlv_rec_type,
                             p_txdv_rec      IN  txdv_rec_type,
                             --Bug# 3156924
                             p_trx_date      IN  DATE,
                             p_trx_number  IN  NUMBER,
                             --Bug# 6373605--SLA populate source
                             p_sla_source_header_id    IN Number,
                             p_sla_source_header_table IN Varchar2,
                             p_sla_source_try_id       IN Number,
                             p_sla_source_line_id      IN Number,
                             p_sla_source_line_table   IN Varchar2,
                             p_sla_source_chr_id       IN Number,
                             p_sla_source_kle_id       IN Number,
                             --Bug# 6373605--SLA populate source
                             --Bug# 4028371
                             x_fa_trx_date  OUT NOCOPY DATE) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'FIXED_ASSET_ADJUST';
l_api_version          CONSTANT NUMBER := 1.0;

l_trans_rec               FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
l_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
--l_asset_fin_glob_dff_rec  FA_API_TYPES.asset_fin_glob_dff_rec_type;
l_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;
l_inv_tbl                 FA_API_TYPES.inv_tbl_type;
l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
l_inv_rec                 FA_API_TYPES.inv_rec_type;
l_asset_deprn_rec         FA_API_TYPES.asset_deprn_rec_type;
l_group_recalss_option_rec FA_API_TYPES.group_reclass_options_rec_type;

--parameters for unit adjustment
l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;
l_trans_rec_ua               FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec_ua           FA_API_TYPES.asset_hdr_rec_type;


l_split_factor            NUMBER;
l_units_to_adjust         NUMBER;
i                         NUMBER;

 --cursor to get the distributions
   CURSOR    l_dist_curs(p_asset_id       IN NUMBER,
                        p_corporate_book IN VARCHAR2) IS
   SELECT  units_assigned,
           distribution_id
   FROM    OKX_AST_DST_HST_V
   WHERE   asset_id = p_ast_line_rec.asset_id
   AND     book_type_code = p_ast_line_rec.corporate_book
   AND     transaction_header_id_out IS NULL
   AND     retirement_id IS NULL;

   l_units_assigned   NUMBER;
   l_distribution_id  NUMBER;

--cursor to find book class
   CURSOR l_book_class_cur(p_book_type_code IN VARCHAR2) IS
   SELECT book_class
   FROM   okx_asst_bk_controls_v
   WHERE  book_type_code = p_book_type_code;

   l_book_class okx_asst_bk_controls_v.book_class%TYPE;

--cursor to get depreciation info

  CURSOR  deprn_cur (p_asset_id        IN NUMBER,
                     p_book_type_code  IN VARCHAR2,
                     p_split_factor    IN NUMBER) IS
            -- gk removed below 2 params for bug 5946411
  SELECT  -- -1 * (ytd_deprn -(ytd_deprn*p_split_factor)),
          -- -1 * (deprn_reserve -(deprn_reserve*p_split_factor)),
          -1 * (prior_fy_expense-(prior_fy_expense*p_split_factor)),
          -1 * (bonus_ytd_deprn-(bonus_ytd_deprn*p_split_factor)),
          -1 * (bonus_deprn_reserve-(bonus_deprn_reserve*p_split_factor))
   FROM   okx_ast_dprtns_v
   WHERE  asset_id       = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    deprn_run_date = (SELECT MAX(deprn_run_date)
                            FROM   okx_ast_dprtns_v
                            WHERE  asset_id       = p_asset_id
                            AND    book_type_code = p_book_type_code);



  CURSOR  deprn_cur2 (p_asset_id        IN NUMBER,
                      p_book_type_code  IN VARCHAR2) IS
            -- gk removed below 2 params for bug 5946411
  SELECT   -- -1 * ytd_deprn,
           -- -1 * deprn_reserve,
           -1 * prior_fy_expense,
           -1 * bonus_ytd_deprn,
           -1 * bonus_deprn_reserve
   FROM   okx_ast_dprtns_v
   WHERE  asset_id       = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    deprn_run_date = (SELECT MAX(deprn_run_date)
                            FROM   okx_ast_dprtns_v
                            WHERE  asset_id       = p_asset_id
                            AND    book_type_code = p_book_type_code);

   --Bug# 4028371 :
   l_calling_interface     CONSTANT VARCHAR2(30) := 'OKLRSPAB:Split Asset';

   --Bug# 6373605 begin
   l_fxhv_rec okl_sla_acc_sources_pvt.fxhv_rec_type;
   l_fxlv_rec okl_sla_acc_sources_pvt.fxlv_rec_type;
   --Bug# 6373605 end

-- Bug# 5946411: ER
  --cursor to check the status of asset
 /* CURSOR l_cleb_sts_csr(pcleid IN NUMBER) IS
  SELECT cleb.sts_code sts_code,cleb.dnz_chr_id chr_id
  FROM   okc_k_lines_b cleb
  WHERE  cleb.id = pcleid;
  l_cle_status okc_k_lines_b.sts_code%TYPE;  */
 -- Bug# 6061103
 CURSOR l_cleb_sts_csr(pcleid IN NUMBER) IS
 SELECT cleb.sts_code sts_code,
        cleb.dnz_chr_id chr_id,
        khr.PDT_ID,
        chr.START_DATE
 FROM   okc_k_lines_b cleb,
        okl_k_headers khr,
        OKC_K_HEADERS_B chr
 WHERE  cleb.id = pcleid
         and khr.id = cleb.dnz_chr_id
         and chr.id = khr.id;
  l_cle_status okc_k_lines_b.sts_code%TYPE;

  --cursor to get the amortization date
  cursor l_max_amortize_date_csr (p_asset_id IN NUMBER,p_book_type_code IN VARCHAR2) is
  select max(th.amortization_start_date) amortization_start_date
  from   fa_transaction_headers th,
          fa_books inbk,
          fa_books outbk
  where  inbk.asset_id = p_asset_id
  and    inbk.book_type_code = p_book_type_code
  and    outbk.asset_id(+) = p_asset_id
  and    outbk.book_type_code(+) = p_book_type_code
  and    inbk.transaction_header_id_in = th.transaction_header_id
  and    outbk.transaction_header_id_out(+) = th.transaction_header_id
  and    th.asset_id = p_asset_id
  and    th.book_type_code = p_book_type_code
  and    th.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                            'TRANSFER', 'TRANSFER IN/VOID',
                                            'RECLASS', 'UNIT ADJUSTMENT',
                                            'REINSTATEMENT');
  l_amortization_start_date DATE:=NULL;
-- Bug# 5946411: ER End

 -- Bug# 6061103
 l_amortization_date DATE;
 l_special_treatment_required VARCHAR2(1);
 l_pdt_id            Number;
 l_start_date        Date;
 l_chr_id        number;
 -- Bug# 6061103 end

--Bug# 5946411: avsingh - parameters for getting depreciation reserve
  l_fa_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
  l_fa_asset_deprn_rec FA_API_TYPES.asset_deprn_rec_type;
BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
   --call start activity to set savepoint
     x_return_status := OKL_API.START_ACTIVITY( SUBSTR(l_api_name,1,26),
                                                       p_init_msg_list,
                                                   '_PVT',
                                                       x_return_status);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

   --------------------
   -- asset header info
   -------------------
   l_asset_hdr_rec.asset_id       := p_ast_line_rec.asset_id;
   l_asset_hdr_rec.book_type_code := p_ast_line_rec.corporate_book;

   ----------------
   -- trans struct
   ----------------
   -- from the dld :
   -- You must populate the transaction type code as. This applies to any asset
   -- type. The transaction subtype will default to 'EXPENSED' so u should popul
   -- ate the transaction subtype with 'AMORTIZED' if you wish to instead
   -- amortize the adjustment. If transaction subtype is AMORTIZED, you must also
   -- provide the amortization start date

   --Bug# 3156924 :
   --l_trans_rec.transaction_type_code   := 'ADJUSTMENT'; --will be derived as per DOC
   --l_trans_rec.transaction_subtype     := 'AMORTIZED';
   --by default will be 'EXPENSED'
   --l_trans_rec.amortization_start_date := to_date('01-JAN-1995','DD-MON-YYYY');

   --Bug# 3156924 :
   --l_trans_rec.amortization_start_date    := p_trx_date; --required only if amortize
   --l_trans_rec.transaction_date_entered := p_trx_date; --will be derived as per DOC
   --l_trans_rec.amortization_start_date := p_ast_line_rec.in_service_date;


   --Bug# 3783518: Cost adjustment on Split to be Amortized
   l_trans_rec.transaction_subtype     := 'AMORTIZED';

    --Bug# 5946411: ER
    -- l_trans_rec.amortization_start_date := p_ast_line_rec.in_service_date;
    --dbms_output.put_line('l_trans_rec.amortization_start_date '||l_trans_rec.amortization_start_date);
    l_amortization_start_date:=NULL;
    -- get the status of the parent line id
    OPEN l_cleb_sts_csr(  p_txlv_rec.kle_id);
    FETCH l_cleb_sts_csr INTO l_cle_status, l_chr_id, l_pdt_id, l_start_date ;
    close l_cleb_sts_csr;
    -- Bug# 6061103 start
     is_evergreen_df_lease
                   (p_api_version     =>  p_api_version,
                    p_init_msg_list   =>  p_init_msg_list,
                    x_return_status   =>  x_return_status,
                    x_msg_count       =>  x_msg_count,
                    x_msg_data        =>  x_msg_data,
                    p_cle_id          =>p_ast_line_rec.PARENT_LINE_ID, -- p_ast_line_rec.asset_id,
                    p_book_type_code   =>  p_ast_line_rec.corporate_book,
                    p_asset_status    => l_cle_status,
                    p_pdt_id          => l_pdt_id,
                    p_start_date      => l_start_date,
                    x_amortization_date => l_amortization_date,
                    x_special_treatment_required => l_special_treatment_required);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
    if l_special_treatment_required = 'Y' then
        l_trans_rec.amortization_start_date := l_amortization_date;
        --rirawat : Handle scenario for asset with no off lease transaction
        IF l_amortization_date IS NULL THEN
         OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                        p_msg_name     =>  'OKL_LA_SPLIT_NOT_ALLOWED'
                                        );
         RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    else
     -- Bug# 6061103 end
   --dbms_output.put_line('Status set as l_cle_status'||l_cle_status);
 /*   IF l_cle_status IN ('TERMINATED','EXPIRED') THEN
     --To prevent following FA error FA_INVALID_AMOUNT_ADJUSTMENT:
     -- 'The amounts you entered cause the results of the adjustment to be
     -- invalid for the amortization date you entered.'
     -- do the adjustement on the last amortization date
     open l_max_amortize_date_csr(p_ast_line_rec.asset_id,p_ast_line_rec.corporate_book);
     fetch l_max_amortize_date_csr into l_amortization_start_date;
     close l_max_amortize_date_csr;
    ELSE
     l_trans_rec.amortization_start_date := p_ast_line_rec.in_service_date;
   END IF;
   if l_amortization_start_date IS NOT NULL THEN
     l_trans_rec.amortization_start_date := l_amortization_start_date;
   ELSE */
     l_trans_rec.amortization_start_date := p_ast_line_rec.in_service_date;
 --  END IF;
   end if; -- 6061103 end if;
    --Bug# 5946411: ER End

   --Bug# 3156924 :
   l_trans_rec.transaction_name  := SUBSTR(TO_CHAR(p_trx_number),1,20); --optional
   l_trans_rec.calling_interface := l_calling_interface; --optional

   IF NVL(p_txdv_rec.split_percent,0) <> 0 OR p_txdv_rec.split_percent <> OKL_API.G_MISS_NUM THEN
       l_split_factor := (p_txdv_rec.split_percent/100);
   ELSE
       l_split_factor := (p_txdv_rec.quantity/p_txlv_rec.current_units);
   END IF;

   -----------
   -- fin info
   -----------
   l_asset_fin_rec_adj.set_of_books_id := p_ast_line_rec.set_of_books_id;
   --should take the true snapshot at this point in time and not from split trx
   --this is just for testing
   --l_asset_fin_rec_adj.cost := p_txdv_rec.cost;
   --l_asset_fin_rec_adj.salvage_value := p_ast_line_rec.salvage_value*l_split_factor;
   --
   --------------------
   --Bug #2723498 11.5.9 enhancement fix :
   --                For Direct Finance Lease Asset cost for original asset will be zero
   --                Calling adjustment API for already zero cost gives error msg. this if clause
   --                to avoid that
   --This is fixed in branch by bug#2598894
   --------------------
   IF p_ast_line_rec.cost = 0 THEN
       --do not call adjustments for DFL contracts
       NULL;
   ELSE
       IF NVL(p_txdv_rec.split_percent,0) <> 0 OR p_txdv_rec.split_percent <> OKL_API.G_MISS_NUM THEN
           l_asset_fin_rec_adj.cost :=  - p_ast_line_rec.cost;
           --Bug# 3950089
           If (p_ast_line_rec.percent_salvage_value is not null) Then
             l_asset_fin_rec_adj.percent_salvage_value :=  - p_ast_line_rec.percent_salvage_value;
           Else
             l_asset_fin_rec_adj.salvage_value :=  - p_ast_line_rec.salvage_value;
           End If;
       ELSE
           l_asset_fin_rec_adj.cost := (p_ast_line_rec.cost*l_split_factor) - p_ast_line_rec.cost;
           --Bug# 3950089
           If (p_ast_line_rec.percent_salvage_value is not null) Then
             l_asset_fin_rec_adj.percent_salvage_value := 0;
           Else
             l_asset_fin_rec_adj.salvage_value := (p_ast_line_rec.salvage_value*l_split_factor) - p_ast_line_rec.salvage_value;
           End If;
       END IF;
       --

       --asset_deprn_rec
       l_asset_deprn_rec_adj.set_of_books_id := p_ast_line_rec.set_of_books_id;

       ---------------------------------------------------------------------------------------------
       --Bug# 5946411 : avsingh
       -- If adjustment being done in period of addition depreciation reserve needs to be backed out
       ---------------------------------------------------------------------------------------------
       --1. Check if adjustment is being made in the period of addition of the asset
       ---------------------------------------------------------------------------------------------
       l_fa_asset_hdr_rec.asset_id       := p_ast_line_rec.asset_id;
       l_fa_asset_hdr_rec.book_type_code := p_ast_line_rec.corporate_book;

       If NOT fa_cache_pkg.fazcbc(x_book => l_fa_asset_hdr_rec.book_type_code) then
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                              );
           Raise OKL_API.G_EXCEPTION_ERROR;
       end if;

       --Bug# 6804043: In R12 codeline, do not back out depreciation reserve
       --              when cost adjustment is done in period of addition
       /*
       If not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_fa_asset_hdr_rec.asset_id,
              p_book                => l_fa_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_fa_asset_hdr_rec.period_of_addition
             ) then
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_LLA_FA_POA_ERROR'
                              );
           Raise OKL_API.G_EXCEPTION_ERROR;
       end if;


       If nvl(l_fa_asset_hdr_rec.period_of_addition,'N') = 'Y' Then
           --------------------------------------
           --2. Get the depreciation reserve
           --------------------------------------
           get_deprn_reserve
                   (p_api_version      =>  p_api_version,
                    p_init_msg_list    =>  p_init_msg_list,
                    x_return_status    =>  x_return_status,
                    x_msg_count        =>  x_msg_count,
                    x_msg_data         =>  x_msg_data,
                    p_asset_id         =>  p_ast_line_rec.asset_id,
                    p_book_type_code   =>  p_ast_line_rec.corporate_book,
                    x_asset_deprn_rec  =>  l_fa_asset_deprn_rec);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

          If l_fa_asset_deprn_rec.deprn_reserve > 0 then
               l_asset_deprn_rec_adj.deprn_reserve := (-1) * l_fa_asset_deprn_rec.deprn_reserve;
           End If;
           If l_fa_asset_deprn_rec.ytd_deprn > 0 then
               l_asset_deprn_rec_adj.ytd_deprn     := (-1) * l_fa_asset_deprn_rec.ytd_deprn;
           End If;
           If l_fa_asset_deprn_rec.prior_fy_expense > 0 then
               l_asset_deprn_rec_adj.prior_fy_expense := (-1) * l_fa_asset_deprn_rec.prior_fy_expense;
           End If;
           If l_fa_asset_deprn_rec.bonus_ytd_deprn > 0 then
               l_asset_deprn_rec_adj.bonus_ytd_deprn  := (-1) * l_fa_asset_deprn_rec.bonus_ytd_deprn;
           End If;
           If l_fa_asset_deprn_rec.bonus_deprn_reserve > 0 then
               l_asset_deprn_rec_adj.bonus_deprn_reserve := (-1) * l_fa_asset_deprn_rec.bonus_deprn_reserve;
           End If;

       End If;
       --End Bug# 5946411
       */
       --End Bug# 6804043

       /***** Commented as part of Bug # 5946411****************************************************/
       /*--avsingh : commented - As per FA no depreciation should be passed during Adjustments if it
         -- adjustment is not period of addition
       IF (p_ast_line_rec.cost + l_asset_fin_rec_adj.cost) = 0 THEN
          --dbms_output.put_line('opening deprn_cur2');
           OPEN  deprn_cur2 (p_asset_id       => p_ast_line_rec.asset_id,
                             p_book_type_code => p_ast_line_rec.corporate_book);
-- gk removed below 2 params for bug 5946411
               FETCH deprn_cur2 INTO --l_asset_deprn_rec_adj.ytd_deprn,
                                     --l_asset_deprn_rec_adj.deprn_reserve,
                                     l_asset_deprn_rec_adj.prior_fy_expense,
                                     l_asset_deprn_rec_adj.bonus_ytd_deprn,
                                     l_asset_deprn_rec_adj.bonus_deprn_reserve;
               IF deprn_cur2%NOTFOUND THEN
                   NULL;
               END IF;
           CLOSE deprn_cur2;
       ELSE
          --dbms_output.put_line('opening deprn_cur');
           OPEN  deprn_cur (p_asset_id       => p_ast_line_rec.asset_id,
                            p_book_type_code => p_ast_line_rec.corporate_book,
                            p_split_factor   => l_split_factor);
-- gk removed below 2 params for bug 5946411
               FETCH deprn_cur INTO --l_asset_deprn_rec_adj.ytd_deprn,
                                    --l_asset_deprn_rec_adj.deprn_reserve,
                                    l_asset_deprn_rec_adj.prior_fy_expense,
                                    l_asset_deprn_rec_adj.bonus_ytd_deprn,
                                    l_asset_deprn_rec_adj.bonus_deprn_reserve;
               IF deprn_cur%NOTFOUND THEN
                   NULL;
               END IF;
           CLOSE deprn_cur;
       END IF;
       ---------------End of Commented Code for Bug# 5946411-----------------------------------------------------*/

       --dbms_output.put_line('Deprn reserve '||to_char(l_asset_deprn_rec_adj.deprn_reserve));
       FA_ADJUSTMENT_PUB.do_adjustment
          (p_api_version             => p_api_version,
           p_init_msg_list           => p_init_msg_list,
           p_commit                  => OKL_API.G_FALSE,
           p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
           x_return_status           => x_return_status,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           --Bug# 3156924
           --p_calling_fn              => null,
           p_calling_fn              => l_calling_interface,
           px_trans_rec              => l_trans_rec,
           px_asset_hdr_rec          => l_asset_hdr_rec,
           p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
           x_asset_fin_rec_new       => l_asset_fin_rec_new,
           x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
           px_inv_trans_rec          => l_inv_trans_rec,
           px_inv_tbl                => l_inv_tbl,
           p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
           x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
           x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
           p_group_reclass_options_rec => l_group_recalss_option_rec
          );
          --dbms_output.put_line('After calling FA adjustment Api '||x_return_status);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

        --Bug# 4028371 :
       x_fa_trx_date := l_trans_rec.transaction_date_entered;

   --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec.book_type_code;

      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --bug# 6373605 -- call populate SLA sources

     END IF;

     l_book_class := NULL;
     OPEN l_book_class_cur(p_book_type_code => p_ast_line_rec.corporate_book);
         FETCH l_book_class_cur INTO l_book_class;
         IF l_book_class_cur%NOTFOUND THEN
             NULL;
         END IF;
     CLOSE l_book_class_cur;

     IF l_book_class = 'CORPORATE' THEN
         --dbms_output.put_line('In adjust split units book type code '|| p_ast_line_rec.corporate_book);
         --now do the unit adjustments
         l_asset_hdr_rec_ua.asset_id             := p_ast_line_rec.asset_id;
         l_asset_hdr_rec_ua.book_type_code       := p_ast_line_rec.corporate_book;

        --l_trans_rec_ua.transaction_type_code    := NULL;
        --l_trans_rec_ua.transaction_subtype      := NULL;
        --l_trans_rec_ua.amortization_start_date := to_date('01-JAN-1995','DD-MON-YYYY');
        --l_trans_rec_ua.amortization_start_date   := NULL;
        --l_trans_rec_ua.transaction_date_entered  := p_ast_line_rec.in_service_date;
        --Bug# 3156924 :
        --l_trans_rec_ua.transaction_date_entered  := null;
        --l_trans_rec_ua.transaction_date_entered  := p_trx_date;
        -- Bug# 6061103 -- start
        l_trans_rec_ua.amortization_start_date   := p_ast_line_rec.in_service_date;
        -- Bug# 6061103 -- end
        l_trans_rec_ua.transaction_name          := SUBSTR(TO_CHAR(p_trx_number),1,20);
        l_trans_rec_ua.calling_interface         := l_calling_interface;

        l_trans_rec_ua.who_info.last_updated_by := FND_GLOBAL.USER_ID;
        l_trans_rec_ua.who_info.last_update_login := FND_GLOBAL.LOGIN_ID;


       --how to find which distribution to adjust from ??
       l_asset_dist_tbl.DELETE;
       --dbms_output.put_line('split factor '||to_char(l_split_factor));
       --dbms_output.put_line('current units '||to_char(p_ast_line_rec.current_units));

       IF NVL(p_txdv_rec.split_percent,0) <> 0 OR p_txdv_rec.split_percent <> OKL_API.G_MISS_NUM THEN
           --l_units_to_adjust := p_ast_line_rec.current_units;
           NULL;
       ELSE
           l_units_to_adjust := p_ast_line_rec.current_units - (p_ast_line_rec.current_units*l_split_factor);
       --End If;

       --dbms_output.put_line('Units to adjust outside loop'||l_units_to_adjust );
       i := 1;
       OPEN l_dist_curs(p_ast_line_rec.asset_id, p_ast_line_rec.corporate_book);
       LOOP
           FETCH l_dist_curs INTO l_units_assigned, l_distribution_id;
           EXIT WHEN l_dist_curs%NOTFOUND;
           IF l_units_to_adjust = 0 THEN
              EXIT;
           ELSIF l_units_to_adjust >= l_units_assigned THEN
              l_asset_dist_tbl(i).distribution_id := l_distribution_id;
              l_asset_dist_tbl(i).transaction_units := (-1)*l_units_assigned;
              --dbms_output.put_line('Units to adjust '||to_char(l_asset_dist_tbl(i).transaction_units));
              l_asset_dist_tbl(i).units_assigned := NULL;
              l_asset_dist_tbl(i).assigned_to := NULL;
              l_asset_dist_tbl(i).expense_ccid := NULL;
              l_asset_dist_tbl(i).location_ccid := NULL;
              l_units_to_adjust := l_units_to_adjust - l_units_assigned;
              i := i + 1;
           ELSIF l_units_to_adjust < l_units_assigned THEN
              l_asset_dist_tbl(i).distribution_id := l_distribution_id;
              l_asset_dist_tbl(i).transaction_units := (-1)*l_units_to_adjust;
              --dbms_output.put_line('Units to adjust '||to_char(l_asset_dist_tbl(i).transaction_units));
              l_asset_dist_tbl(i).units_assigned := NULL;
              l_asset_dist_tbl(i).assigned_to := NULL;
              l_asset_dist_tbl(i).expense_ccid := NULL;
              l_asset_dist_tbl(i).location_ccid := NULL;
              l_units_to_adjust := l_units_to_adjust - l_units_to_adjust;
              i := i + 1;
           END IF;
       END LOOP;
       CLOSE l_dist_curs;

      FA_UNIT_ADJ_PUB.do_unit_adjustment(
           p_api_version       => p_api_version,
           p_init_msg_list      => FND_API.G_FALSE,
           p_commit            => FND_API.G_FALSE,
           p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
           --bug# 3156924 :
           p_calling_fn        => l_calling_interface,
           --p_calling_fn        => NULL,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           px_trans_rec        => l_trans_rec_ua,
           px_asset_hdr_rec    => l_asset_hdr_rec_ua,
           px_asset_dist_tbl   => l_asset_dist_tbl);

         --dbms_output.put_line('After calling FA unit adjust Api '||x_return_status);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

      --bug# 6373605 -- call populate sla sources
      l_fxhv_rec.source_id := p_sla_source_header_id;
      l_fxhv_rec.source_table := p_sla_source_header_table;
      l_fxhv_rec.khr_id := p_sla_source_chr_id;
      l_fxhv_rec.try_id := p_sla_source_try_id;

      l_fxlv_rec.source_id := p_sla_source_line_id;
      l_fxlv_rec.source_table := p_sla_source_line_table;
      l_fxlv_rec.kle_id := p_sla_source_kle_id;

      l_fxlv_rec.asset_id := l_asset_hdr_rec_ua.asset_id;
      l_fxlv_rec.fa_transaction_id := l_trans_rec_ua.transaction_header_id;
      l_fxlv_rec.asset_book_type_name := l_asset_hdr_rec_ua.book_type_code;

      OKL_SLA_ACC_SOURCES_PVT.populate_sources(
      p_api_version  => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,p_fxhv_rec => l_fxhv_rec
     ,p_fxlv_rec => l_fxlv_rec
     ,x_return_status => x_return_status
     ,x_msg_count    => x_msg_count
     ,x_msg_data    => x_msg_data
      );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --bug# 6373605 -- call populate SLA sources

    END IF;
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
END FIXED_ASSET_ADJUST;
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_trx_rec
  --Purpose               : Gets source transaction record for IB interface
  --Modification History  :
  --15-Jun-2001    ashish.singh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_trx_rec
    (p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
     p_cle_id                       IN  NUMBER,
     p_transaction_type             IN  VARCHAR2,
     x_trx_rec                      OUT NOCOPY CSI_DATASTRUCTURES_PUB.transaction_rec) IS

     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_TRX_REC';
     l_api_version           CONSTANT NUMBER    := 1.0;

--Following cursor assumes that a transaction type called
--'OKL_BOOK'  will be seeded in IB
     CURSOR okl_trx_type_csr(p_transaction_type IN VARCHAR2)IS
            SELECT transaction_type_id
            FROM   CSI_TXN_TYPES
            WHERE  source_transaction_type = p_transaction_type;
     l_trx_type_id NUMBER;
 BEGIN
     OPEN okl_trx_type_csr(p_transaction_type);
        FETCH okl_trx_type_csr
        INTO  l_trx_type_id;
        IF okl_trx_type_csr%NOTFOUND THEN
           --OKL LINE ACTIVATION not seeded as a source transaction in IB
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                               p_msg_name     => G_IB_TXN_TYPE_NOT_FOUND,
                                               p_token1       => G_TXN_TYPE_TOKEN,
                                               p_token1_value => p_transaction_type
                                            );
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     CLOSE okl_trx_type_csr;
     --Assign transaction Type id to seeded value in cs_lookups
     x_trx_rec.transaction_type_id := l_trx_type_id;
     --Assign Source Line Ref id to contract line id of IB instance line
     x_trx_rec.source_line_ref_id := p_cle_id;
     x_trx_rec.transaction_date := SYSDATE;
     --confirm whether this has to be sysdate or creation date on line
     x_trx_rec.source_transaction_date := SYSDATE;
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_trx_rec;
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_party_rec
  --Purpose               : Gets Party records for IB interface
  --Modification History  :
  --15-Jun-2001    avsingh   Created
  --Notes : Takes chr_id as input and tries to get the party role
  --        for that contract for party role = 'LESSEE'
  --        Assuming that LESSEE will be the owner of the IB instance
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_party_rec
        (p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chrv_id                      IN  NUMBER,
     x_party_tbl                    OUT NOCOPY CSI_DATASTRUCTURES_PUB.party_tbl) IS

     l_party_tab         OKL_JTOT_EXTRACT.party_tab_type;
     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_PARTY_REC';
     l_api_version           CONSTANT NUMBER    := 1.0;

     l_index         NUMBER;

BEGIN
    --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( SUBSTR(l_api_name,1,26),
                                                       p_init_msg_list,
                                                   '_PVT',
                                                       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    --get Party
    OKL_JTOT_EXTRACT.Get_Party(p_api_version     =>  p_api_version,
                               p_init_msg_list   =>  p_init_msg_list,
                               x_return_status   =>  x_return_status,
                               x_msg_count       =>  x_msg_count,
                               x_msg_data        =>  x_msg_data,
                               p_chr_id          =>  p_chrv_id,
                               p_cle_id          =>  NULL,
                               p_role_code       =>  G_ITM_INST_PARTY,
                               p_intent          =>  G_CONTRACT_INTENT,
                               x_party_tab       =>  l_party_tab);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR l_index IN 1..l_party_tab.LAST
    LOOP
        x_party_tbl(l_index).party_id := l_party_tab(l_index).id1;
        x_party_tbl(l_index).party_source_table := G_PARTY_SRC_TABLE;
        x_party_tbl(l_index).relationship_type_code := G_PARTY_RELATIONSHIP;
        x_party_tbl(l_index).contact_flag := 'N';
        --dbms_output.put_line('party_id' || to_char(l_index)||'-'||to_char(x_party_tbl(l_index).party_id));
    END LOOP;

    IF (l_index = 0) THEN
        --no owner party record found
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                            p_msg_name     => G_PARTY_NOT_FOUND,
                                            p_token1       => G_ROLE_CODE_TOKEN,
                                            p_token1_value => G_ITM_INST_PARTY
                                         );
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_party_rec;
--------------------------------------------------------------------------------
--Start of comments
--Procedure Name : delete_instance_lines(Local)
--Description    : deletes split our instance lines in case of serialized split asset
--Created for Bug# 2726870 : Split assets by serial numbers
--End of comments
--------------------------------------------------------------------------------
PROCEDURE delete_instance_lines(p_api_version   IN  NUMBER,
                                p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                p_inst_cle_id   IN  NUMBER,
                                p_ib_cle_id     IN  NUMBER) IS

  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'DELETE_INSTANCE_LINES';
  l_api_version          CONSTANT NUMBER := 1.0;

  l_inst_cle_id           OKC_K_LINES_B.ID%TYPE;
  l_ib_cle_id             OKC_K_LINES_B.ID%TYPE;

  l_inst_clev_rec         okc_contract_pub.clev_rec_type;
  l_ib_clev_rec           okc_contract_pub.clev_rec_type;
  lx_inst_clev_rec        okc_contract_pub.clev_rec_type;
  lx_ib_clev_rec          okc_contract_pub.clev_rec_type;

  l_inst_klev_rec         okl_kle_pvt.klev_rec_type;
  l_ib_klev_rec           okl_kle_pvt.klev_rec_type;


BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

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

    l_inst_cle_id      := p_inst_cle_id;
    l_ib_cle_id        := p_ib_cle_id;
    l_inst_klev_rec.id :=  l_inst_cle_id;
    l_ib_klev_rec.id   :=  l_ib_cle_id;
    l_inst_clev_rec.id :=  l_inst_cle_id;
    l_ib_clev_rec.id   :=  l_ib_cle_id;

    l_inst_clev_rec.sts_code :=  'ABANDONED';
    l_ib_clev_rec.sts_code   :=  'ABANDONED';

    ---update status of the line
    OKC_CONTRACT_PUB.update_contract_line(
                     p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_clev_rec       => l_ib_clev_rec,
                     x_clev_rec       => lx_ib_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Call line deletion API.
    OKC_CONTRACT_PUB.delete_contract_line(
                     p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_line_id        => l_ib_cle_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- delete shadows explicitly
    OKL_KLE_PVT.delete_row(
              p_api_version             => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data,
              p_klev_rec                => l_ib_klev_rec);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---update status of the line
    OKC_CONTRACT_PUB.update_contract_line(
                     p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_clev_rec       => l_inst_clev_rec,
                     x_clev_rec       => lx_inst_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Call line deletion API
    OKC_CONTRACT_PUB.delete_contract_line(
                     p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     p_line_id        => l_inst_cle_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- delete shadows explicitly
    OKL_KLE_PVT.delete_row(
              p_api_version             => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data,
              p_klev_rec                => l_ib_klev_rec);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 7033247: Deleted the wrongly pasted
    --duplicate lines of code from below:

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
END delete_instance_lines;
--------------------------------------------------------------------------------
--Start of comments
--Procedure Name : Create_ib_instance
--Description    : procedure creates split child ib instance
--Modified for Bug# 2648280 : to take care of IB fix on expire instance API
--end of comments
--------------------------------------------------------------------------------
PROCEDURE create_ib_instance(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_csi_id1       IN  VARCHAR2,
                             p_csi_id2       IN  VARCHAR2,
                             p_ib_cle_id     IN  NUMBER,
                             p_chr_id        IN  NUMBER,
                             p_split_qty     IN  NUMBER,
                             p_txdv_rec      IN  txdv_rec_type,
                             x_instance_id   OUT NOCOPY NUMBER) IS

  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_IB_INSTANCE';
  l_api_version          CONSTANT NUMBER := 1.0;

  --instance query recs
  l_instance_query_rec           CSI_DATASTRUCTURES_PUB.instance_query_rec;
  l_party_query_rec              CSI_DATASTRUCTURES_PUB.party_query_rec;
  l_account_query_rec            CSI_DATASTRUCTURES_PUB.party_account_query_rec;
  l_instance_header_tbl          CSI_DATASTRUCTURES_PUB.instance_header_tbl;

  --instance recs for creation
  l_instance_rec                 CSI_DATASTRUCTURES_PUB.instance_rec;
  l_ext_attrib_values_tbl        CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
  l_party_tbl                    CSI_DATASTRUCTURES_PUB.party_tbl;
  l_party_tbl_in                 CSI_DATASTRUCTURES_PUB.party_tbl;
  l_account_tbl                  CSI_DATASTRUCTURES_PUB.party_account_tbl;
  l_pricing_attrib_tbl           CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
  l_org_assignments_tbl          CSI_DATASTRUCTURES_PUB.organization_units_tbl;
  l_asset_assignment_tbl         CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
  l_txn_rec                      CSI_DATASTRUCTURES_PUB.transaction_rec;

  --original instance updation parameters
  l_upd_instance_rec                 CSI_DATASTRUCTURES_PUB.instance_rec;
  l_upd_ext_attrib_values_tbl        CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
  l_upd_party_tbl                    CSI_DATASTRUCTURES_PUB.party_tbl;
  l_upd_party_tbl_in                 CSI_DATASTRUCTURES_PUB.party_tbl;
  l_upd_account_tbl                  CSI_DATASTRUCTURES_PUB.party_account_tbl;
  l_upd_pricing_attrib_tbl           CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
  l_upd_org_assignments_tbl          CSI_DATASTRUCTURES_PUB.organization_units_tbl;
  l_upd_asset_assignment_tbl         CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
  l_upd_txn_rec                      CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_upd_instance_id_lst              CSI_DATASTRUCTURES_PUB.id_tbl;

  l_exp_txn_rec                      CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_exp_instance_id_lst              CSI_DATASTRUCTURES_PUB.id_tbl;


  l_no_data_found                BOOLEAN;

  --cursor to fetch customer account
  /*--Bug# 3124577: 11.5.10 : Rule Migration--------------------------------------
  CURSOR party_account_csr(p_chrv_id IN NUMBER) is
  SELECT  to_number(rulv.object1_id1)
  FROM    OKC_RULES_V rulv
  WHERE   rulv.rule_information_category = G_CUST_ACCT_RULE
  AND     rulv.dnz_chr_id = p_chrv_id
  AND     exists (select '1'
                  from    OKC_RULE_GROUPS_V rgpv
                  where   rgpv.chr_id = p_chrv_id
                  and     rgpv.rgd_code = G_CUST_ACCT_RULE_GROUP
                  and     rgpv.id       = rulv.rgp_id);
  --------------------------------------Bug# 3124577 : 11.5.10 Rule Migration----*/

  CURSOR party_account_csr(p_chrv_id IN NUMBER) IS
  SELECT chrb.cust_acct_id
  FROM   OKC_K_HEADERS_B chrb
  WHERE  chrb.id = p_chrv_id;

  l_party_account              NUMBER;

  --bug# 2648280
  --modified to get all the terminated statuses
  CURSOR inst_sts_csr(p_status_name IN VARCHAR2) IS
  SELECT instance_status_id
  FROM   CSI_INSTANCE_STATUSES
  WHERE  NVL(TERMINATED_FLAG,'N') = 'Y'
  AND    name = p_status_name;

  l_expired_status_id csi_instance_statuses.instance_status_id%TYPE DEFAULT NULL;

  l_active_instances_only VARCHAR2(1);

  --Bug # 2726870 11.5.9 enhancements - split asset into components
  --cursor to check if instance is to be split out in case of split asset by serial numbers
  CURSOR chk_instance_csr (PInstanceId IN NUMBER,PTalId IN NUMBER ) IS
  SELECT '!'
  FROM   OKL_TXL_ITM_INSTS iti
  WHERE  iti.instance_id                      = PInstanceId
  AND    iti.tal_id                           = PTalId
  AND    NVL(iti.selected_for_split_flag,'N') = 'Y'
  AND    iti.tal_type                         = 'ALI';

  l_instance_for_split   VARCHAR2(1) DEFAULT '?';

  --cursor to get the instance line id for parent asset line for delete
  CURSOR get_instance_cle_csr (PInstanceId IN NUMBER, PTalId IN NUMBER, PChrId IN NUMBER) IS
  SELECT inst_cle.id      inst_cle_id,
         ib_cle.id        ib_cle_id
  FROM
         okc_k_items       ib_cim,
         okc_k_lines_b     ib_cle,
         okc_line_styles_b ib_lse,
         okc_k_lines_b     inst_cle,
         okc_line_styles_b inst_lse,
         okc_k_lines_b     fa_cle,
         okc_line_styles_b fa_lse,
         okl_txl_Assets_b  tal
  WHERE  ib_cim.object1_id1       = TO_CHAR(PInstanceId)
  AND    ib_cim.object1_id2       = '#'
  AND    ib_cim.jtot_object1_code = 'OKX_IB_ITEM'
  AND    ib_cim.cle_id            = ib_cle.id
  AND    ib_cim.dnz_chr_id        = ib_cle.dnz_chr_id
  AND    ib_cle.cle_id            = inst_cle.id
  AND    ib_cle.dnz_chr_id        = inst_cle.dnz_chr_id
  AND    ib_cle.lse_id            = ib_lse.id
  AND    ib_lse.lty_code          = 'INST_ITEM'
  AND    inst_cle.cle_id          = fa_cle.cle_id
  AND    inst_cle.dnz_chr_id      = fa_cle.dnz_chr_id
  AND    inst_cle.lse_id          = inst_lse.id
  AND    inst_lse.lty_code        = 'FREE_FORM2'
  AND    fa_cle.id                = tal.kle_id
  AND    fa_cle.dnz_chr_id        = PChrId
  AND    fa_cle.lse_id            = fa_lse.id
  AND    fa_lse.lty_code          = 'FIXED_ASSET'
  AND    tal.id                   = PTalId;

  l_inst_cle_id    OKC_K_LINES_B.ID%TYPE;
  l_ib_cle_id      OKC_K_LINES_B.ID%TYPE;

--Cursors for Split asset components which are serialized
  CURSOR get_instance_cle_csr2 (PTarget_kle_id IN NUMBER, PChrId IN NUMBER) IS
  SELECT inst_cle.id  inst_cle_id,
         ib_cim.id    ib_cim_id
  FROM
         okc_k_items       ib_cim,
         okc_k_lines_b     ib_cle,
         okc_line_styles_b ib_lse,
         okc_k_lines_b     inst_cle,
         okc_line_styles_b inst_lse,
         okc_k_lines_b     fa_cle,
         okc_line_styles_b fa_lse
  WHERE
         ib_cim.cle_id            = ib_cle.id
  AND    ib_cim.dnz_chr_id        = ib_cle.dnz_chr_id
  AND    ib_cle.cle_id            = inst_cle.id
  AND    ib_cle.dnz_chr_id        = inst_cle.dnz_chr_id
  AND    ib_cle.lse_id            = ib_lse.id
  AND    ib_lse.lty_code          = 'INST_ITEM'
  AND    inst_cle.cle_id          = fa_cle.cle_id
  AND    inst_cle.dnz_chr_id      = fa_cle.dnz_chr_id
  AND    inst_cle.lse_id          = inst_lse.id
  AND    inst_lse.lty_code        = 'FREE_FORM1'
  AND    fa_cle.id                = PTarget_kle_id
  AND    fa_cle.dnz_chr_id        = PChrId
  AND    fa_cle.lse_id            = fa_lse.id
  AND    fa_lse.lty_code          = 'FIXED_ASSET';


  l_ib_cim_id      OKC_K_ITEMS.ID%TYPE;
  l_serialized     VARCHAR2(1) DEFAULT okl_api.g_false;

  --cursor to get the serial numbers for serialized split asset components
  CURSOR comp_srl_csr (p_asd_id IN NUMBER) IS
  SELECT serial_number,
         id
  FROM   okl_txl_itm_insts
  WHERE  asd_id = p_asd_id
  AND    NVL(selected_for_split_flag,'N') = 'Y';

  l_itiv_id  OKL_TXL_ITM_INSTS.ID%TYPE;

  l_iipv_rec  OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
  lx_iipv_rec OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;


BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --get item instance record
    --l_instance_rec := get_csi_rec(p_csi_id1 => p_csi_id1,
    --                              p_csi_id2 => p_csi_id2,
    --                              x_no_data_found => l_no_data_found);

    l_instance_query_rec.instance_id := p_csi_id1;

    --split asset into components modfn.
    IF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN
       l_active_instances_only := FND_API.G_FALSE;
    ELSE
       l_active_instances_only := FND_API.G_TRUE;
    END IF;

    csi_item_instance_pub.get_item_instances (
         p_api_version           => p_api_version,
         p_commit                => FND_API.G_FALSE,
         p_init_msg_list         => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_instance_query_rec    => l_instance_query_rec,
         p_party_query_rec       => l_party_query_rec,
         p_account_query_rec     => l_account_query_rec,
         p_transaction_id        => NULL,
         p_resolve_id_columns    => FND_API.G_FALSE,
         p_active_instance_only  => l_active_instances_only,
         --modfn for split asset component
         --p_active_instance_only  => FND_API.TRUE,
         x_instance_header_tbl   => l_instance_header_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);

     --dbms_output.put_line('After calling IB API for query status '||x_return_status);
     --dbms_output.put_line('After calling IB API for query instance_id '||to_char(l_instance_header_tbl(1).instance_id));
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF (NVL (l_instance_header_tbl.COUNT, 0) <> 1) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

     --bug# 2982927 : resetting okc inv org again from k header :
     okl_context.set_okc_org_context(p_chr_id => p_chr_id);
     --bug# 2982927

     --BUG#  3489089 :
     l_instance_rec.vld_organization_id         := okl_context.get_okc_organization_id;
     --BUG# 3489089

     l_instance_rec.instance_id                 := l_instance_header_tbl(1).instance_id;
     l_instance_rec.instance_number             := l_instance_header_tbl(1).instance_number;
     l_instance_rec.external_reference          := l_instance_header_tbl(1).external_reference;
     l_instance_rec.INVENTORY_ITEM_ID           := l_instance_header_tbl(1).INVENTORY_ITEM_ID;
     l_instance_rec.INVENTORY_REVISION          := l_instance_header_tbl(1).INVENTORY_REVISION;
     l_instance_rec.INV_MASTER_ORGANIZATION_ID  := l_instance_header_tbl(1).INV_MASTER_ORGANIZATION_ID;
     l_instance_rec.SERIAL_NUMBER               := l_instance_header_tbl(1).SERIAL_NUMBER;
     l_instance_rec.MFG_SERIAL_NUMBER_FLAG      := l_instance_header_tbl(1).MFG_SERIAL_NUMBER_FLAG;
     l_instance_rec.LOT_NUMBER                  := l_instance_header_tbl(1).LOT_NUMBER;
     l_instance_rec.QUANTITY                    := l_instance_header_tbl(1).QUANTITY;
     l_instance_rec.UNIT_OF_MEASURE             := l_instance_header_tbl(1).UNIT_OF_MEASURE;
     l_instance_rec.ACCOUNTING_CLASS_CODE       := l_instance_header_tbl(1).ACCOUNTING_CLASS_CODE;
     l_instance_rec.INSTANCE_CONDITION_ID       := l_instance_header_tbl(1).INSTANCE_CONDITION_ID;
     l_instance_rec.INSTANCE_STATUS_ID          := l_instance_header_tbl(1).INSTANCE_STATUS_ID;
     l_instance_rec.CUSTOMER_VIEW_FLAG          := l_instance_header_tbl(1).CUSTOMER_VIEW_FLAG;
     l_instance_rec.MERCHANT_VIEW_FLAG          := l_instance_header_tbl(1).MERCHANT_VIEW_FLAG;
     l_instance_rec.SELLABLE_FLAG               := l_instance_header_tbl(1).SELLABLE_FLAG;
     l_instance_rec.SYSTEM_ID                   := l_instance_header_tbl(1).SYSTEM_ID;
     l_instance_rec.INSTANCE_TYPE_CODE          := l_instance_header_tbl(1).INSTANCE_TYPE_CODE;
     l_instance_rec.LOCATION_TYPE_CODE          := l_instance_header_tbl(1).LOCATION_TYPE_CODE;
     l_instance_rec.LOCATION_ID                 := l_instance_header_tbl(1).LOCATION_ID;
     l_instance_rec.INV_ORGANIZATION_ID         := l_instance_header_tbl(1).INV_ORGANIZATION_ID;
     l_instance_rec.INV_SUBINVENTORY_NAME       := l_instance_header_tbl(1).INV_SUBINVENTORY_NAME;
     l_instance_rec.INV_LOCATOR_ID              := l_instance_header_tbl(1).INV_LOCATOR_ID;
     l_instance_rec.PA_PROJECT_ID               := l_instance_header_tbl(1).PA_PROJECT_ID;
     l_instance_rec.PA_PROJECT_TASK_ID          := l_instance_header_tbl(1).PA_PROJECT_TASK_ID;
     l_instance_rec.IN_TRANSIT_ORDER_LINE_ID    := l_instance_header_tbl(1).IN_TRANSIT_ORDER_LINE_ID;
     l_instance_rec.WIP_JOB_ID                  := l_instance_header_tbl(1).WIP_JOB_ID;
     l_instance_rec.PO_ORDER_LINE_ID            := l_instance_header_tbl(1).PO_ORDER_LINE_ID;
     l_instance_rec.LAST_OE_ORDER_LINE_ID       := l_instance_header_tbl(1).LAST_OE_ORDER_LINE_ID;
     l_instance_rec.LAST_OE_RMA_LINE_ID         := l_instance_header_tbl(1).LAST_OE_RMA_LINE_ID;
     l_instance_rec.LAST_PO_PO_LINE_ID          := l_instance_header_tbl(1).LAST_PO_PO_LINE_ID;
     l_instance_rec.LAST_OE_PO_NUMBER           := l_instance_header_tbl(1).LAST_OE_PO_NUMBER;
     l_instance_rec.LAST_WIP_JOB_ID             := l_instance_header_tbl(1).LAST_WIP_JOB_ID;
     l_instance_rec.LAST_PA_PROJECT_ID          := l_instance_header_tbl(1).LAST_PA_PROJECT_ID;
     l_instance_rec.LAST_PA_TASK_ID             := l_instance_header_tbl(1).LAST_PA_TASK_ID;
     l_instance_rec.LAST_OE_AGREEMENT_ID        := l_instance_header_tbl(1).LAST_OE_AGREEMENT_ID;
     l_instance_rec.INSTALL_DATE                := l_instance_header_tbl(1).INSTALL_DATE;
     l_instance_rec.MANUALLY_CREATED_FLAG       := l_instance_header_tbl(1).MANUALLY_CREATED_FLAG;
     l_instance_rec.RETURN_BY_DATE              := l_instance_header_tbl(1).RETURN_BY_DATE;
     l_instance_rec.ACTUAL_RETURN_DATE          := l_instance_header_tbl(1).ACTUAL_RETURN_DATE;
     l_instance_rec.CREATION_COMPLETE_FLAG      := l_instance_header_tbl(1).CREATION_COMPLETE_FLAG;
     l_instance_rec.COMPLETENESS_FLAG           := l_instance_header_tbl(1).COMPLETENESS_FLAG;
     l_instance_rec.LAST_TXN_LINE_DETAIL_ID     := l_instance_header_tbl(1).LAST_TXN_LINE_DETAIL_ID;
     l_instance_rec.INSTALL_LOCATION_TYPE_CODE  := l_instance_header_tbl(1).INSTALL_LOCATION_TYPE_CODE;
     l_instance_rec.INSTALL_LOCATION_ID         := l_instance_header_tbl(1).INSTALL_LOCATION_ID;
     l_instance_rec.INSTANCE_USAGE_CODE         := l_instance_header_tbl(1).INSTANCE_USAGE_CODE;
     l_instance_rec.OBJECT_VERSION_NUMBER       := l_instance_header_tbl(1).OBJECT_VERSION_NUMBER;

     IF NVL(p_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN --splitting into components
         --expire original item instances
         l_expired_status_id := NULL;
         OPEN inst_sts_csr(p_status_name => l_instance_rec.instance_status_id);
         FETCH inst_sts_csr INTO l_expired_status_id;
         IF inst_sts_csr%NOTFOUND THEN
             --get trx record
             get_trx_rec(p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_cle_id           => p_ib_cle_id,
                         p_transaction_type => G_IB_SPLIT_TXN_TYPE,
                         x_trx_rec          => l_exp_txn_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_instance_rec.INSTANCE_STATUS_ID := NULL;
            csi_item_instance_pub.expire_item_instance
                  (p_api_version         => p_api_version
                  ,p_commit              => fnd_api.g_false
                  ,p_init_msg_list       => p_init_msg_list
                  ,p_validation_level    => fnd_api.g_valid_level_full
                  ,p_instance_rec        => l_instance_rec
                  ,p_expire_children     => fnd_api.g_false
                  ,p_txn_rec             => l_exp_txn_rec
                  ,x_instance_id_lst     => l_exp_instance_id_lst
                  ,x_return_status       => x_return_status
                  ,x_msg_count           => x_msg_count
                  ,x_msg_data            => x_msg_data);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --bug# 2982927 : resetting okc inv org again from k header :
            okl_context.set_okc_org_context(p_chr_id => p_chr_id);
            --bug# 2982927

        ELSE

            NULL;

        END IF;

        --Bug # 2726870 :11.5.9 enhancement Split asset by serial numbers for Split Asset by components
        l_serialized := OKL_API.G_FALSE;
        Is_Inv_Item_Serialized(p_api_version      => p_api_version,
                               p_init_msg_list    => p_init_msg_list,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count,
                               x_msg_data         => x_msg_data,
                               p_inv_item_id      => p_txdv_rec.inventory_item_id,
                               p_chr_id           => p_chr_id,
                               p_cle_id           => NULL,
                               x_serialized       => l_serialized);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         --If l_serialized = OKL_API.G_FALSE Then
             --if not serialized create new instances normally
             IF l_serialized = OKL_API.G_FALSE THEN
                 l_instance_rec.serial_number  := NULL;
                 l_instance_rec.quantity       := p_split_qty;
             ELSIF l_serialized = OKL_API.G_TRUE THEN
                 --set serial number
                 OPEN comp_srl_csr (p_asd_id => p_txdv_rec.id);
                 FETCH comp_srl_csr INTO l_instance_rec.serial_number,
                                         l_itiv_id;
                 IF comp_srl_csr%NOTFOUND THEN
                     l_instance_rec.serial_number  := NULL;
                 END IF;
                 CLOSE comp_srl_csr;
                 IF l_itiv_id IS NOT NULL OR l_itiv_id <> OKL_API.G_MISS_NUM THEN
                     --update the serail number record as processed
                     l_iipv_rec.id := l_itiv_id;
                     l_iipv_rec.selected_for_split_flag := 'P';
                     --dbms_output.put_line('before update of txl itm insts sts'||x_return_status);
                     --dbms_output.put_line('before update of txl itm insts sts'||to_char(l_iipv_rec.id));
                     --dbms_output.put_line('before update of txl itm insts sts'||to_char(l_iipv_rec.kle_id));
                     okl_txl_itm_insts_pub.update_txl_itm_insts
                                         (p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_iipv_rec      => l_iipv_rec,
                                          x_iipv_rec      => lx_iipv_rec);
                     --dbms_output.put_line('after update of txl itm insts sts'||x_return_status);
                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;
                 END IF;
                 l_instance_rec.quantity   := 1;
             END IF;

             l_instance_rec.INSTANCE_STATUS_ID := NULL;

             -- now process for new ib instance creation.
             --get trx record
             l_instance_rec.instance_id            := NULL;
             l_instance_rec.instance_number        := NULL;
             --l_instance_rec.serial_number          := Null;
             l_instance_rec.creation_complete_flag := NULL;
             --l_instance_rec.quantity               := p_split_qty;
             l_instance_rec.object_version_number  := NULL;
             l_instance_rec.inventory_item_id      := p_txdv_rec.inventory_item_id;
             --Bug# 3066375:
             l_instance_rec.call_contracts         := okl_api.g_false;


             get_trx_rec(p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_cle_id           => p_ib_cle_id,
                         p_transaction_type => G_IB_SPLIT_TXN_TYPE,
                         x_trx_rec          => l_txn_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --get party tbl
            get_party_rec(p_api_version      => p_api_version,
                          p_init_msg_list    => p_init_msg_list,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data,
                          p_chrv_id          => p_chr_id,
                          x_party_tbl        => l_party_tbl);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --get party accoutnt id
            l_party_account := NULL;
            OPEN party_account_csr(p_chrv_id => p_chr_id);
                FETCH party_account_csr INTO
                                           l_party_account;
                IF party_account_csr%NOTFOUND THEN
                    --raise error for unable to find inv mstr org
                    OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                        p_msg_name     =>  G_CUST_ACCOUNT_FOUND,
                                        p_token1       =>  G_CONTRACT_ID_TOKEN,
                                        p_token1_value =>  TO_CHAR(p_chr_id)
                                        );
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                ELSE
                     NULL;
                END IF;
           CLOSE party_account_csr;

           l_account_tbl(1).instance_party_id := l_party_tbl(1).party_id;
           l_account_tbl(1).party_account_id  := l_party_account;
           l_account_tbl(1).relationship_type_code := G_PARTY_RELATIONSHIP;
           --l_account_tbl(1).active_start_date := sysdate;
           l_account_tbl(1).parent_tbl_index := 1;

           --dbms_output.put_line('before calling ib API');

           csi_item_instance_pub.create_item_instance(p_api_version           =>  p_api_version,
                                                      p_commit                =>  fnd_api.g_false,
                                                      p_init_msg_list         =>  p_init_msg_list,
                                                      p_instance_rec          =>  l_instance_rec,
                                                      p_validation_level      =>  fnd_api.g_valid_level_full,
                                                      p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                      p_party_tbl             =>  l_party_tbl,
                                                      p_account_tbl           =>  l_account_tbl,
                                                      p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                      p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                      p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                      p_txn_rec               =>  l_txn_rec,
                                                      x_return_status         =>  x_return_status,
                                                      x_msg_count             =>  x_msg_count,
                                                      x_msg_data              =>  x_msg_data);

             --dbms_output.put_line('After calling IB API status '||x_return_status);
             --dbms_output.put_line('After calling IB API instance_id '||to_char(l_instance_rec.instance_id));

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --bug# 2982927 : resetting okc inv org again from k header :
            okl_context.set_okc_org_context(p_chr_id => p_chr_id);
            --bug# 2982927

            x_instance_id := l_instance_rec.instance_id;

        --Elsif l_serialized = OKL_API.G_TRUE Then

             --1. read from the split transaction to create new serial numbers
             --2. For each record create instance in IB
             --3. Loop through all the created instances
             --4.    fetch existing ib line
             --        If line found  update id1,id2
             --        else create new ib line and plug in id1,id2
             --Null;
        --End If; --serialized

     ELSE --for normal split assets

         --Bug # 2726870 :11.5.9 enhancement Split asset by serial numbers for Split Asset by components
         l_serialized := OKL_API.G_FALSE;
         Is_Inv_Item_Serialized(p_api_version      => p_api_version,
                                 p_init_msg_list    => p_init_msg_list,
                                 x_return_status    => x_return_status,
                                 x_msg_count        => x_msg_count,
                                 x_msg_data         => x_msg_data,
                                 p_inv_item_id      => l_instance_rec.inventory_item_id,
                                 p_chr_id           => p_chr_id,
                                 p_cle_id           => NULL,
                                 x_serialized       => l_serialized);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         IF (l_instance_rec.quantity = 1) OR
             (l_instance_rec.quantity - p_split_qty) <= 0 THEN -- this will never be the case
             NULL; -- no need to update quantity - item instance may be serailized

             --Bug # 2726870 11.5.9 enhancements - split asset into components
             IF l_serialized = OKL_API.G_TRUE THEN
                 l_instance_for_split := '?';
                 OPEN chk_instance_csr(PInstanceId => l_instance_rec.instance_id,
                                       PTalId      => P_txdv_rec.tal_id);
                 FETCH chk_instance_csr INTO l_instance_for_split;
                 IF chk_instance_csr%NOTFOUND THEN
                     NULL;
                 END IF;
                 CLOSE chk_instance_csr;

                 IF l_instance_for_split = '!' THEN
                    --delete instance line from parent asset
                    --dbms_output.put_line('instance for split');
                    OPEN get_instance_cle_csr (PInstanceId => l_instance_rec.instance_id,
                                               PTalId      => P_txdv_rec.tal_id,
                                               PChrId      => p_chr_id);
                    FETCH  get_instance_cle_csr INTO l_inst_cle_id, l_ib_cle_id;
                    IF get_instance_cle_csr%NOTFOUND THEN
                        NULL;
                    ELSE
                        --Call line deletion API
                        delete_instance_lines(
                                               p_api_version    => p_api_version,
                                               p_init_msg_list  => p_init_msg_list,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data,
                                               p_inst_cle_id    => l_inst_cle_id,
                                               p_ib_cle_id      => l_ib_cle_id);
                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                    END IF;
                    x_instance_id := l_instance_rec.instance_id;
                 END IF; -- If item instance is selected for serial split
             END IF;--if serialized

         ELSE

             --do csi adjustment
             l_upd_instance_rec.instance_id           := l_instance_rec.instance_id;
             l_upd_instance_rec.quantity              := (l_instance_rec.quantity - p_split_qty);
             l_upd_instance_rec.object_version_number := l_instance_rec.object_version_number;

             --get trx record
             get_trx_rec(p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_cle_id           => p_ib_cle_id,
                         p_transaction_type => G_IB_SPLIT_TXN_TYPE,
                         x_trx_rec          => l_upd_txn_rec);

             l_upd_txn_rec.transaction_quantity := (-1)* p_split_qty;

             csi_item_instance_pub.update_item_instance
                   (
                    p_api_version           => p_api_version
                   ,p_commit                => fnd_api.g_false
                   ,p_init_msg_list         => p_init_msg_list
                   ,p_validation_level      => fnd_api.g_valid_level_full
                   ,p_instance_rec          => l_upd_instance_rec
                   ,p_ext_attrib_values_tbl => l_upd_ext_attrib_values_tbl
                   ,p_party_tbl             => l_upd_party_tbl
                   ,p_account_tbl           => l_upd_account_tbl
                   ,p_pricing_attrib_tbl    => l_upd_pricing_attrib_tbl
                   ,p_org_assignments_tbl   => l_upd_org_assignments_tbl
                   ,p_asset_assignment_tbl  => l_upd_asset_assignment_tbl
                   ,p_txn_rec               => l_upd_txn_rec
                   ,x_instance_id_lst       => l_upd_instance_id_lst
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data
                   );

              --dbms_output.put_line('After calling IB API for update status '||x_return_status);
              --dbms_output.put_line('After calling IB API update instance_id '||to_char(l_instance_rec.instance_id));
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              --bug# 2982927 : resetting okc inv org again from k header :
              okl_context.set_okc_org_context(p_chr_id => p_chr_id);
              --bug# 2982927

           END IF;


           IF  (l_serialized = OKL_API.G_TRUE) THEN
               NULL;
               --dbms_output.put_line('Serialized');
               x_instance_id := l_instance_rec.instance_id;
           ELSE
               --dbms_output.put_line('Not Serialized');
               -- now process for new ib instance creation.
               --get trx record
               l_instance_rec.instance_id            := NULL;
               l_instance_rec.instance_number        := NULL;
               l_instance_rec.serial_number          := NULL;
               l_instance_rec.creation_complete_flag := NULL;
               l_instance_rec.quantity               := p_split_qty;
               l_instance_rec.object_version_number  := NULL;
               --Bug# 3066375:
               l_instance_rec.call_contracts         := okl_api.g_false;


               get_trx_rec(p_api_version      => p_api_version,
                           p_init_msg_list    => p_init_msg_list,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data,
                           p_cle_id           => p_ib_cle_id,
                           p_transaction_type => G_IB_SPLIT_TXN_TYPE,
                           x_trx_rec          => l_txn_rec);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               --get party tbl
               get_party_rec(p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data,
                         p_chrv_id          => p_chr_id,
                         x_party_tbl        => l_party_tbl);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               --get party accoutnt id
               l_party_account := NULL;
               OPEN party_account_csr(p_chrv_id => p_chr_id);
                  FETCH party_account_csr INTO
                                           l_party_account;
                   IF party_account_csr%NOTFOUND THEN
                       --raise error for unable to find inv mstr org
                       OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                           p_msg_name     =>  G_CUST_ACCOUNT_FOUND,
                                           p_token1       =>  G_CONTRACT_ID_TOKEN,
                                           p_token1_value =>  TO_CHAR(p_chr_id)
                                           );
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   ELSE
                       NULL;
                   END IF;
               CLOSE party_account_csr;

               l_account_tbl(1).instance_party_id := l_party_tbl(1).party_id;
               l_account_tbl(1).party_account_id  := l_party_account;
               l_account_tbl(1).relationship_type_code := G_PARTY_RELATIONSHIP;
               --l_account_tbl(1).active_start_date := sysdate;
               l_account_tbl(1).parent_tbl_index := 1;

               --dbms_output.put_line('before calling ib API');

               csi_item_instance_pub.create_item_instance(p_api_version           =>  p_api_version,
                                                          p_commit                =>  fnd_api.g_false,
                                                          p_init_msg_list         =>  p_init_msg_list,
                                                          p_instance_rec          =>  l_instance_rec,
                                                          p_validation_level      =>  fnd_api.g_valid_level_full,
                                                          p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                          p_party_tbl             =>  l_party_tbl,
                                                          p_account_tbl           =>  l_account_tbl,
                                                          p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                          p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                          p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                          p_txn_rec               =>  l_txn_rec,
                                                          x_return_status         =>  x_return_status,
                                                          x_msg_count             =>  x_msg_count,
                                                          x_msg_data              =>  x_msg_data);

               --dbms_output.put_line('After calling IB API status '||x_return_status);
               --dbms_output.put_line('After calling IB API instance_id '||to_char(l_instance_rec.instance_id));

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               --bug# 2982927 : resetting okc inv org again from k header :
               okl_context.set_okc_org_context(p_chr_id => p_chr_id);
               --bug# 2982927

           END IF; --If serail number split
           x_instance_id := l_instance_rec.instance_id;
    END IF; --type of split

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
END create_ib_instance;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : consolidate_ib_lines (local)
--Description    : Will consoldate the ib lines for split asset into
--                 components when either source or target asset is serialized
--History        :
--                 30-Jan-2003  ashish.singh Created
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE consolidate_ib_lines(p_api_version   IN  NUMBER,
                               p_init_msg_list IN  VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_txdv_rec      IN  txdv_rec_type,
                               p_txlv_rec      IN  txlv_rec_type
                               ) IS
l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'CONSOLIDATE_IB_LINES';
l_api_version          CONSTANT NUMBER := 1.0;

--Cursor to get model line inventory item on parent line
CURSOR inv_itm_csr(p_fa_line_id IN NUMBER) IS
SELECT cim_model.object1_id1,
       cim_model.object1_id2,
       cle_fa.dnz_chr_id,
       cle_fa.cle_id
FROM   okc_k_items        cim_model,
       okc_k_lines_b      cle_model,
       okc_line_styles_b  lse_model,
       okc_k_lines_b      cle_fa
WHERE  cim_model.dnz_chr_id = cle_model.dnz_chr_id
AND    cim_model.cle_id     = cle_model.id
AND    cle_model.lse_id     = lse_model.id
AND    lse_model.lty_code   = 'ITEM'
AND    cle_model.cle_id     = cle_fa.cle_id
AND    cle_model.dnz_chr_id = cle_fa.dnz_chr_id
AND    cle_fa.id            = p_fa_line_id;

l_object1_id1        OKC_K_ITEMS.object1_id1%TYPE;
l_object1_id2        OKC_K_ITEMS.object1_id2%TYPE;
l_chr_id             NUMBER;
l_cle_id             NUMBER; --top line id

l_parent_serialized  VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
l_child_serialized   VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

--Cursor to fetch ib instances
CURSOR ib_inst_csr(p_fin_ast_id IN NUMBER) IS
SELECT cle_ib.id,
       cle_inst.id
FROM   okc_k_lines_b     cle_ib,
       okc_line_styles_b lse_ib,
       okc_k_lines_b     cle_inst,
       okc_line_styles_b lse_inst
WHERE  cle_ib.lse_id      = lse_ib.id
AND    lse_ib.lty_code    = 'INST_ITEM'
AND    cle_ib.dnz_chr_id  = cle_inst.dnz_chr_id
AND    cle_ib.cle_id      = cle_inst.id
AND    cle_inst.lse_id    = lse_inst.id
AND    lse_inst.lty_code  = 'FREE_FORM2'
AND    cle_inst.cle_id    = p_fin_ast_id;

l_ib_cle_id      OKC_K_LINES_B.ID%TYPE;
l_inst_cle_id    OKC_K_LINES_B.ID%TYPE;

--Cursor to fetch new ib instance lines
--Cursor ib_inst_csr(p_fin_ast_id IN NUMBER) is
CURSOR new_ib_inst_csr(p_txd_id IN NUMBER) IS
SELECT cle_ib.id,
       cle_inst.id
FROM   okc_k_lines_b     cle_ib,
       okc_line_styles_b lse_ib,
       okc_k_lines_b     cle_inst,
       okc_line_styles_b lse_inst,
       okc_k_lines_b     cle_fa,
       okl_txd_assets_b  txdb
WHERE  cle_ib.lse_id      = lse_ib.id
AND    lse_ib.lty_code    = 'INST_ITEM'
AND    cle_ib.dnz_chr_id  = cle_inst.dnz_chr_id
AND    cle_ib.cle_id      = cle_inst.id
AND    cle_inst.lse_id    = lse_inst.id
AND    lse_inst.lty_code  = 'FREE_FORM2'
AND    cle_inst.cle_id    =  cle_fa.cle_id
AND    cle_fa.id          = txdb.target_kle_id
AND    txdb.id            = p_txd_id;

l_tgt_ib_cle_id       OKC_K_LINES_B.ID%TYPE;
l_tgt_inst_cle_id     OKC_K_LINES_B.ID%TYPE;


--cursor to fetch child asset top line is
CURSOR child_cle_csr(p_txd_id IN NUMBER) IS
SELECT cle_fa.cle_id
FROM   okc_k_lines_b  cle_fa,
       okl_txd_assets_b txdb
WHERE  cle_fa.id = txdb.target_kle_id
AND    txdb.id    = p_txd_id;

l_target_cle_id   OKC_K_LINES_B.ID%TYPE;
l_new_inst_cle_id OKC_K_LINES_B.ID%TYPE;

--cursor to fetch the newly created ib line
CURSOR new_ib_csr(p_new_inst_id IN NUMBER) IS
SELECT id
FROM   okc_k_lines_b cle_new_ib
WHERE  cle_new_ib.cle_id = p_new_inst_id;

l_new_ib_cle_id OKC_K_LINES_B.ID%TYPE;

--table of line records for updating statuses of the new lines
l_clev_tbl      OKL_OKC_MIGRATION_PVT.clev_tbl_type;
lx_clev_tbl      OKL_OKC_MIGRATION_PVT.clev_tbl_type;
j               NUMBER DEFAULT 0;

 -- Bug# 5946411: ER
  --cursor to check the status of asset
  CURSOR l_cleb_sts_csr(pcleid IN NUMBER) IS
  SELECT cleb.sts_code sts_code
  FROM   okc_k_lines_b cleb
  WHERE  cleb.id = pcleid;
  l_cle_status okc_k_lines_b.sts_code%TYPE;
  -- Bug# 5946411: ER End
BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
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
  -- Bug# 5946411: ER
   -- get the status of the parent line id
    OPEN l_cleb_sts_csr(  p_txlv_rec.kle_id);
    FETCH l_cleb_sts_csr INTO l_cle_status;
    close l_cleb_sts_csr;
    --dbms_output.put_line('consolidate_ib_line--p_txlv_rec.kle_id'||p_txlv_rec.kle_id);
    --dbms_output.put_line('Status set as l_cle_status'||l_cle_status);
  -- Bug# 5946411: ER End

    OPEN inv_itm_csr(p_fa_line_id => p_txlv_rec.kle_id);
    FETCH inv_itm_csr INTO l_object1_id1,
                           l_object1_id2,
                           l_chr_id,
                           l_cle_id;
    CLOSE inv_itm_csr;

    --evaluate if parent asset is serialized
    l_parent_serialized := OKL_API.G_FALSE;
    Is_Inv_Item_Serialized(p_api_version      => p_api_version,
                           p_init_msg_list    => p_init_msg_list,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data,
                           p_inv_item_id      => TO_NUMBER(l_object1_id1),
                           p_chr_id           => l_chr_id,
                           p_cle_id           => NULL,
                           x_serialized       => l_parent_serialized);
    --dbms_output.put_line('After parent serialized '||x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --evaluate if child asset is serialized
    l_child_serialized := OKL_API.G_FALSE;
    Is_Inv_Item_Serialized(p_api_version      => p_api_version,
                           p_init_msg_list    => p_init_msg_list,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data,
                           p_inv_item_id      => p_txdv_rec.inventory_item_id,
                           p_chr_id           => l_chr_id,
                           p_cle_id           => NULL,
                           x_serialized       => l_child_serialized);
    --dbms_output.put_line('After child serialized '||x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_parent_serialized = OKL_API.G_FALSE AND l_child_serialized = OKL_API.G_FALSE THEN
        --dbms_output.put_line('Both not serialized '||x_return_status);
        NULL;
    ELSIF l_parent_serialized = OKL_API.G_TRUE AND l_child_serialized = OKL_API.G_TRUE THEN
        --dbms_output.put_line('Both serialized '||x_return_status);
        NULL;
    ELSIF l_parent_serialized = OKL_API.G_TRUE AND l_child_serialized = OKL_API.G_FALSE THEN
        --dbms_output.put_line('Parent serialized,Child not'||x_return_status);
        --trim extra ib instance lines from child
        FOR i IN 1..(p_txlv_rec.current_units -1)
        LOOP
            --Open ib_inst_csr(p_fin_ast_id => l_cle_id);
            OPEN new_ib_inst_csr(p_txd_id => p_txdv_rec.id);
            FETCH new_ib_inst_csr INTO l_tgt_ib_cle_id,
                                       l_tgt_inst_cle_id;
            CLOSE new_ib_inst_csr;
            delete_instance_lines(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_inst_cle_id   => l_tgt_inst_cle_id,
                                  p_ib_cle_id     => l_tgt_ib_cle_id);
        END LOOP;

    ELSIF l_parent_serialized = OKL_API.G_FALSE AND l_child_serialized = OKL_API.G_TRUE THEN
        --dbms_output.put_line('Add extra ib instance line to child '||x_return_status);
        --Add extra ib instance line to child
        OPEN ib_inst_csr(p_fin_ast_id => l_cle_id);
            FETCH ib_inst_csr INTO l_ib_cle_id,
                                   l_inst_cle_id;
        CLOSE ib_inst_csr;

        OPEN child_cle_csr(p_txd_id => p_txdv_rec.id);
            FETCH child_cle_csr INTO l_target_cle_id;
        CLOSE child_cle_csr;

        j := 0;
        FOR i IN 1..(p_txlv_rec.current_units-1)
        LOOP
            --dbms_output.put_line('before Copying lines '||to_char(i)||x_return_status);
            --dbms_output.put_line('source cle '||to_char(l_inst_cle_id)||x_return_status);
            --dbms_output.put_line('target cle '||to_char(l_target_cle_id)||x_return_status);

            OKL_COPY_CONTRACT_PUB.COPY_CONTRACT_LINES(
                p_api_version       => p_api_version,
                p_init_msg_list     => p_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_from_cle_id       => l_inst_cle_id,
                p_to_cle_id         => l_target_cle_id,
                p_to_chr_id         => NULL,
                p_to_template_yn        => 'N',
                p_copy_reference        =>  'COPY',
                p_copy_line_party_yn => 'Y',
                p_renew_ref_yn       => 'N',
                x_cle_id                     => l_new_inst_cle_id);

            --dbms_output.put_line('After Copying lines '||to_char(i)||x_return_status);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            --making the line table for update of status
            j := j+1;
            l_clev_tbl(j).id       :=   l_new_inst_cle_id;
            --Bug# 5946411: ER
            --l_clev_tbl(j).sts_code :=   'BOOKED';
            l_clev_tbl(j).sts_code:=l_cle_status;
            --dbms_output.put_line('consolidate_ib_lines l_clev_tbl(j).sts_code-->'||l_clev_tbl(j).sts_code);
            --Bug# 5946411: ER End
            OPEN new_ib_csr(p_new_inst_id=> l_new_inst_cle_id);
              FETCH  new_ib_csr INTO  l_new_ib_cle_id;
            CLOSE new_ib_csr;
            j := j+1;
            l_clev_tbl(j).id := l_new_ib_cle_id;
            --Bug# 5946411: ER
            --l_clev_tbl(j).sts_code :=   'BOOKED';
            l_clev_tbl(j).sts_code :=  l_cle_status;
            --dbms_output.put_line('consolidate_ib_lines * l_clev_tbl(j).sts_code-->'||l_clev_tbl(j).sts_code);
            --Bug# 5946411: ER End
            --
         END LOOP;
         --change status of newly created lines to BOOKED
         IF l_clev_tbl.COUNT > 0 THEN
             OKL_OKC_MIGRATION_PVT.update_contract_line(
                p_api_version       => p_api_version,
                p_init_msg_list     => p_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_restricted_update     => OKC_API.G_FALSE,
                p_clev_tbl          => l_clev_tbl,
                x_clev_tbl          => lx_clev_tbl);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
         END IF;
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
END consolidate_ib_lines;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : Relink_Ib_Lines
--Description    : Local procedure will be called if invnetory item is serial
--                 Number Controlled and split criteria is split into individu
--                 -als
--History        :
--                 20-Nov-2003 avsingh  Bug#3222804
--                                      Fixed as part of this bug
--End of Comments
--------------------------------------------------------------------------------
  PROCEDURE Relink_Ib_Lines(  p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_txlv_rec      IN  txlv_rec_type) IS

  l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'RELINK_IB_LINES';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to fetch top line id for a fixed asset line
  CURSOR l_cleb_csr (p_cle_id IN NUMBER) IS
  SELECT cleb.cle_id
  FROM   okc_k_lines_b cleb
  WHERE  cleb.id = p_cle_id;

  l_parent_fina_cle_id  NUMBER DEFAULT NULL;
  l_child_fina_cle_id   NUMBER DEFAULT NULL;


  --cursor to fetch child instance lines
  CURSOR l_target_kle_csr(p_tal_id IN NUMBER) IS
  SELECT txdb.target_kle_id
  FROM   okl_txd_assets_b txdb
  WHERE  txdb.tal_id = p_tal_id;

  l_target_kle_id  NUMBER DEFAULT 0;

  --cursor to fetch Inastance line id
  CURSOR l_instcle_csr(p_cle_id IN NUMBER) IS
  SELECT cleb.id
  FROM   okc_k_lines_b     cleb,
         okc_line_styles_b lseb
  WHERE  lseb.id          = cleb.lse_id
  AND    lseb.lty_code    = 'FREE_FORM2'
  AND    cleb.sts_code    <> 'ABANDONED'
  AND    cleb.cle_id       = p_cle_id;

  l_instcle_id  NUMBER DEFAULT NULL;

  l_clev_rec    okl_okc_migration_pvt.clev_rec_type;
  lx_clev_rec   okl_okc_migration_pvt.clev_rec_type;

  l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    --get the top line id for parent fixed asset line

    OPEN l_cleb_csr(p_cle_id => p_txlv_rec.kle_id);
    FETCH l_cleb_csr INTO l_parent_fina_cle_id;
    IF l_cleb_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE l_cleb_csr;

    IF NVL(l_parent_fina_cle_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN

        l_serialized := is_serialized(p_cle_id => l_parent_fina_cle_id);
        IF l_serialized = OKL_API.G_TRUE THEN
            l_target_kle_id := NULL;
            OPEN l_target_kle_csr(p_tal_id => p_txlv_rec.id);
            LOOP
                FETCH l_target_kle_csr INTO l_target_kle_id;
                EXIT WHEN l_target_kle_csr%NOTFOUND;
                IF l_target_kle_id = p_txlv_rec.kle_id THEN
                    NULL;
                ELSE
                    l_child_fina_cle_id := NULL;
                    OPEN l_cleb_csr(p_cle_id => l_target_kle_id);
                    FETCH l_cleb_csr INTO l_child_fina_cle_id;
                    IF l_cleb_csr%NOTFOUND THEN
                        NULL;
                    END IF;
                    CLOSE l_cleb_csr;

                    IF NVL(l_child_fina_cle_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM  THEN
                        l_instcle_id := NULL;
                        OPEN l_instcle_csr(p_cle_id => l_parent_fina_cle_id);
                        FETCH l_instcle_csr INTO l_instcle_id;
                        IF l_instcle_csr%NOTFOUND THEN
                            NULL;
                        END IF;
                        CLOSE l_instcle_csr;
                        IF NVL(l_instcle_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM THEN
                            l_clev_rec.id     := l_instcle_id;
                            l_clev_rec.cle_id := l_child_fina_cle_id;
                            OKL_OKC_MIGRATION_PVT.update_contract_line(p_api_version         => p_api_version,
                                                                      p_init_msg_list   => p_init_msg_list,
                                                                      x_return_status   => x_return_status,
                                                                      x_msg_count           => x_msg_count,
                                                                      x_msg_data            => x_msg_data,
                                                                      p_clev_rec            => l_clev_rec,
                                                                      x_clev_rec            => lx_clev_rec);
                            --dbms_output.put_line('after updating contract item for Asset link '||x_return_status);
                            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)  THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            CLOSE l_target_kle_csr;
        ELSIF l_serialized = OKL_API.G_FALSE THEN

            --this processing will be done in the create instance routine
            --as new IB instances need to be created
            NULL;

        END IF;
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
END Relink_Ib_Lines;
--------------------------------------------------------------------------------
--Bug#       : 11.5.10
--Name       : recalculate_costs
--Creation   : 23-Sep-2003
--Purpose    : Local procedure to recalculate and update costs on split lines
--------------------------------------------------------------------------------
PROCEDURE recalculate_costs(
          p_api_version     IN NUMBER,
          p_init_msg_list   IN VARCHAR2,
          x_return_status   OUT NOCOPY VARCHAR2,
          x_msg_count       OUT NOCOPY NUMBER,
          x_msg_data        OUT NOCOPY VARCHAR2,
          p_chr_id          IN  NUMBER,
          p_cle_tbl         IN  cle_tbl_type
          ) IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'RECALCULATE_COSTS';
l_api_version          CONSTANT NUMBER := 1.0;

l_oec               NUMBER;
l_cap_amount        NUMBER;
l_residual_value    NUMBER;


l_clev_rec             okl_okc_migration_pvt.clev_rec_type;
l_klev_rec             okl_contract_pub.klev_rec_type;
lx_clev_rec            okl_okc_migration_pvt.clev_rec_type;
lx_klev_rec            okl_contract_pub.klev_rec_type;

i                  NUMBER;

BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    IF p_cle_tbl.COUNT > 0 THEN
    FOR i IN p_cle_tbl.FIRST..p_cle_tbl.LAST
    LOOP
        --calculate and update subsidised OEC ,  Capital Amount, Residual Value
        OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => G_FORMULA_OEC,
                                        p_contract_id   => p_chr_id,
                                        p_line_id       => p_cle_tbl(i).cle_id,
                                        x_value         => l_oec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => G_FORMULA_CAP,
                                        p_contract_id   => p_chr_id,
                                        p_line_id       => p_cle_tbl(i).cle_id,
                                        x_value         => l_cap_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => G_FORMULA_RES,
                                        p_contract_id   => p_chr_id,
                                        p_line_id       => p_cle_tbl(i).cle_id,
                                        x_value         => l_residual_value);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        ----------------------------------------------------------------------
        --call api to update costs on asset line
        ----------------------------------------------------------------------
        l_clev_rec.id                    := p_cle_tbl(i).cle_id;
        l_klev_rec.id                    := p_cle_tbl(i).cle_id;
        l_klev_rec.oec                   := l_oec;
        l_klev_rec.capital_amount        := l_cap_amount;
        l_klev_rec.residual_value        := l_residual_value;


        okl_contract_pub.update_contract_line
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_clev_rec      => l_clev_rec,
         p_klev_rec      => l_klev_rec,
         x_clev_rec      => lx_clev_rec,
         x_klev_rec      => lx_klev_rec
         );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END LOOP;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
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
END recalculate_costs;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : Split_Asset
--Description    : Selects the split Asset transaction against the line
--                 and splits the Asset in OKL and FA
--History        :
--                 03-Nov-2001  ashish.singh Created
--                 12-Aug-2005  smadhava Fix for Bug# 4508050
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_txdv_tbl      IN  txdv_tbl_type,
                            p_txlv_rec      IN  txlv_rec_type,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            --Bug# 6344223
                            p_source_call   IN VARCHAR2 DEFAULT 'UI') IS

l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(30) := 'SPLIT_FIXED_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;

CURSOR k_line_curs(p_fa_line_id IN NUMBER) IS
SELECT cle_id,
       dnz_chr_id,
       --Bug# 6373605 start
       sts_code
       --Bug# 6373605 end
FROM   okc_k_lines_b
WHERE  id = p_fa_line_id;

l_source_cle_id NUMBER;
l_chr_id        NUMBER;
i               NUMBER;
--Bug# 6373605 start
l_sts_code      okc_k_lines_b.STS_CODE%TYPE;
--Bug# 6373605 end

l_txdv_rec      txdv_rec_type;
l_txlv_rec      txlv_rec_type;

l_split_cle_id  NUMBER;
l_split_cle_id_orig  NUMBER; -- 7626121
l_cle_tbl       cle_tbl_type;
l_ast_line_rec  ast_line_rec_type;

CURSOR c_cim(p_id IN NUMBER) IS
SELECT id,
       cle_id
FROM   okc_k_items cim
WHERE  EXISTS
(SELECT '1'
FROM    okl_txd_assets_b txd
WHERE   txd.target_kle_id = cim.cle_id
AND     txd.id = p_id
);

l_asset_hdr_rec FA_API_TYPES.asset_hdr_rec_type;
l_cim_id        NUMBER;
l_cimv_rec      cimv_rec_type;
l_cimv_rec_out  cimv_rec_type;
l_cim_cle_id    NUMBER;

CURSOR ib_item_cur (p_fa_line_id IN NUMBER) IS
SELECT cim.object1_id1,
       cim.object1_id2,
       cim.id,
       cim.cle_id,
       cim.dnz_chr_id
FROM   OKC_K_ITEMS         cim,
       OKC_K_LINES_B       inst_item,
       OKC_LINE_STYLES_B   inst_item_lse,
       OKC_K_LINES_B       f_frm2,
       OKC_LINE_STYLES_B   f_frm2_lse,
       OKC_K_LINES_B       fa
WHERE cim.cle_id = inst_item.id
AND   cim.dnz_chr_id = inst_item.dnz_chr_id
AND   inst_item.cle_id = f_frm2.id
AND   inst_item.lse_id = inst_item_lse.id
AND   inst_item_lse.lty_code = 'INST_ITEM'
AND   f_frm2.cle_id = fa.cle_id
AND   f_frm2.lse_id = f_frm2_lse.id
AND   f_frm2_lse.lty_code = 'FREE_FORM2'
AND   fa.id = p_fa_line_id;

l_csi_id1               okc_k_items.object1_id1%TYPE;
l_csi_id2               okc_k_items.object1_id2%TYPE;
l_csi_cim_id            okc_k_items.id%TYPE;
l_csi_cle_id            okc_k_items.cle_id%TYPE;
l_csi_chr_id            okc_k_items.dnz_chr_id%TYPE;
l_csi_number_of_items   okc_k_items.number_of_items%TYPE;

l_csi_instance_id NUMBER;

l_trxv_rec        trxv_rec_type;
lx_trxv_rec       trxv_rec_type;

l_txdv_tbl        txdv_tbl_type;

--cursor to find if asset added in current period
CURSOR check_period_of_addition(p_asset_id       IN NUMBER,
                                p_book_type_code IN VARCHAR2) IS
SELECT 'Y' -- 'Y' if the current period of the asset is period of addition.
FROM dual
WHERE NOT EXISTS
     (SELECT 'x'
      FROM   fa_deprn_summary
      WHERE  asset_id = p_asset_id
      AND    book_type_code = p_book_type_code
      AND    deprn_amount <> 0
      AND    deprn_source_code = 'DEPRN'
     );
l_check_period_of_addition    VARCHAR2(1) DEFAULT NULL;

--cursor to get all books  for parent asset
CURSOR all_books_curs(p_asset_id IN NUMBER) IS
SELECT
    id1,
    id2,
    name,
    description,
    book_type_code,
    book_class,
    asset_id,
    asset_number,
    serial_number,
    salvage_value,
    percent_salvage_value,
    life_in_months,
    acquisition_date,
    original_cost,
    cost,
    adjusted_cost,
    tag_number,
    current_units,
    reval_ceiling,
    new_used,
    manufacturer_name,
    model_number,
    asset_type,
    depreciation_category,
    deprn_start_date,
    deprn_method_code,
    rate_adjustment_factor,
    basic_rate,
    adjusted_rate,
    start_date_active,
    end_date_active,
    status,
    primary_uom_code,
    recoverable_cost,
    org_id,
    set_of_books_id
FROM  OKX_AST_BKS_V
WHERE TRUNC(NVL(start_date_active,SYSDATE)) <= TRUNC(SYSDATE)
AND   TRUNC(NVL(end_date_active,SYSDATE+1)) >TRUNC(SYSDATE)
AND   book_class IN ('CORPORATE','TAX')
AND   asset_id = p_asset_id
ORDER BY book_class,asset_id;

l_all_books_rec  all_books_curs%ROWTYPE;

--Bug #2723498 :11.5.9 split asset by serial numbers
CURSOR get_dup_inst_csr (p_asd_id IN NUMBER) IS
SELECT f_frm2.id           instance_id,
       inst_item.id        ib_line_id
FROM   OKC_K_ITEMS         cim,
       OKC_K_LINES_B       inst_item,
       OKC_LINE_STYLES_B   inst_item_lse,
       OKC_K_LINES_B       f_frm2,
       OKC_LINE_STYLES_B   f_frm2_lse,
       OKC_K_LINES_B       fa,
       OKL_TXD_ASSETS_B    asd
WHERE  cim.cle_id             = inst_item.id
AND    cim.dnz_chr_id         = inst_item.dnz_chr_id
AND    inst_item.cle_id       = f_frm2.id
AND    inst_item.lse_id       = inst_item_lse.id
AND    inst_item_lse.lty_code = 'INST_ITEM'
AND    f_frm2.cle_id          = fa.cle_id
AND    f_frm2.lse_id          = f_frm2_lse.id
AND    f_frm2_lse.lty_code    = 'FREE_FORM2'
AND    fa.id                  = asd.target_kle_id
AND    asd.id                 = p_asd_id
AND    EXISTS (SELECT   NULL
               FROM     OKC_K_ITEMS         cim_p,
                        OKC_K_LINES_B       inst_item_p,
                        OKC_LINE_STYLES_B   inst_item_lse_p,
                        OKC_K_LINES_B       f_frm2_p,
                        OKC_LINE_STYLES_B   f_frm2_lse_p,
                        OKC_K_LINES_B       fa_p,
                        OKL_TXL_ASSETS_B    tal
                 WHERE  cim_p.object1_id1         = cim.object1_id1
                 AND    cim_p.object1_id2         = cim.object1_id2
                 AND    cim_p.jtot_object1_code   = cim.jtot_object1_code
                 AND    cim_p.dnz_chr_id          = cim.dnz_chr_id
                 AND    cim_p.cle_id              = inst_item_p.id
                 AND    cim_p.dnz_chr_id          = inst_item_p.dnz_chr_id
                 AND    inst_item_p.cle_id        = f_frm2_p.id
                 AND    inst_item_p.lse_id        = inst_item_lse_p.id
                 AND    inst_item_lse_p.lty_code  = 'INST_ITEM'
                 AND    f_frm2_p.cle_id           = fa_p.cle_id
                 AND    f_frm2_p.lse_id           = f_frm2_lse_p.id
                 AND    f_frm2_lse_p.lty_code     = 'FREE_FORM2'
                 AND    fa_p.id                     = tal.kle_id
                 AND    tal.id                    = asd.tal_id
                 );

l_dup_inst_cle_id   OKC_K_LINES_B.ID%TYPE;
l_dup_ib_cle_id   OKC_K_LINES_B.ID%TYPE;

--Bug# : cursor to check if split is called by asset level termination process
CURSOR asset_trmn_csr(pcleid IN NUMBER) IS
SELECT '!'
FROM   DUAL
WHERE  EXISTS
  (SELECT 1
  FROM    okl_trx_quotes_b h,
          okl_txl_quote_lines_b l,
          okl_trx_contracts t,
          okl_k_headers k
  WHERE   h.id = l.qte_id
  AND     h.id = t.qte_id
  AND     h.khr_id = k.id
  AND     ((  k.deal_type LIKE 'LEASE%' AND h.qtp_code IN
           ('TER_PURCHASE','TER_RECOURSE','TER_ROLL_PURCHASE','TER_MAN_PURCHASE'))
           OR
           (k.deal_type LIKE 'LOAN%' )
          )
  AND     l.qlt_code = 'AMCFIA'
  AND     l.quote_quantity < l.asset_quantity
  AND     l.kle_id = pcleid
  AND     t.tcn_type = 'ALT'
  --rkuttiya added for 12.1.1 Multi GAAP
  AND     t.representation_type = 'PRIMARY'
  --
  --Bug# 6043327  : R12B SLA impact
  --AND     t.tsu_code = 'WORKING'
  AND     t.tmt_status_code = 'WORKING'
  );

l_asset_trmn_exists VARCHAR2(1) DEFAULT '?';

l_loan_yn     VARCHAR2(1) DEFAULT 'N';
l_fa_exists   VARCHAR2(1) DEFAULT 'N';
l_row_not_found BOOLEAN DEFAULT FALSE;

--------------------------------------
--Bug# : 11.5.10 : Securitization impact
-------------------------------------
l_is_asset_securitized VARCHAR2(1);
l_inv_agmt_chr_id_tbl okl_securitization_pvt.inv_agmt_chr_id_tbl_type;
l_trx_reason_asset_split VARCHAR2(20) := okl_securitization_pvt.g_trx_reason_Asset_split;
--------------------------------------
--Bug# : 11.5.10 : Securitization impact
-------------------------------------

  --Bug# 3156924 : cursor to get transaction date and transaction number from transaction
  CURSOR l_trx_csr (ptrxid IN NUMBER) IS
  SELECT DATE_TRANS_OCCURRED,
         TRANS_NUMBER,
         --Bug# 6373605 start
         TRY_ID
         --Bug# 6373605 end
  FROM   OKL_TRX_ASSETS
  WHERE  id = ptrxid;

  l_trx_rec l_trx_csr%ROWTYPE;

  --Bg# 4028371
  l_fa_retire_date  date;
  l_fa_adj_date     date;
  l_fa_add_date     date;

  l_talv_date_rec            okl_tal_pvt.talv_rec_type;
  lx_talv_date_rec           okl_tal_pvt.talv_rec_type;
  --Bug# 4028371

  --Bug# 3502142
  l_round_split_comp_amt varchar2(30);

  --Bug# 4631549
  --cursor to fetch re-lease contract flag
  cursor l_chrb_csr (p_chr_id in number) is
  select chrb.orig_system_source_code
  from   okc_k_headers_b chrb
  where  chrb.id = p_chr_id;

  l_chrb_rec l_chrb_csr%ROWTYPE;

  --cursor to fetch expected asset cost
  cursor l_exp_cost_csr(p_cle_id in number) is
  select kle.expected_asset_cost
  from   okl_k_lines kle
  where  kle.id = p_cle_id;

  l_exp_cost_rec l_exp_cost_csr%ROWTYPE;

  l_clev_exp_cost_rec  okl_okc_migration_pvt.clev_rec_type;
  lx_clev_exp_cost_rec okl_okc_migration_pvt.clev_rec_type;
  l_klev_exp_cost_rec  okl_contract_pub.klev_rec_type;
  lx_klev_exp_cost_rec  okl_contract_pub.klev_rec_type;

  --Bug# 6373605 start
  l_sla_asset_chr_id NUMBER;
  --Bug# 6373605 end

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

    l_txdv_tbl := p_txdv_tbl;

    --Bug# 3156924 : Get the transaction details
    OPEN l_trx_csr(ptrxid => p_txlv_rec.tas_id);
    FETCH l_trx_csr INTO l_trx_rec;
    IF l_trx_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE l_trx_csr;
    --Bug# 3156924 end

    --2. get financial asset line id and chr_id
    OPEN k_line_curs(p_fa_line_id => p_txlv_rec.kle_id);
    FETCH k_line_curs INTO l_source_cle_id, l_chr_id,
                           --Bug# 6373605 start
                           l_sts_code;
                           --Bug# 6373605 end
    IF k_line_curs%NOTFOUND THEN
       --dbms_output.put_line('unable to find financial asset line for fixed asset line!!!');
       --handle error appropraitely
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_DATA_FOUND,
                           p_token1       => 'COL_NAME',
                           p_token1_value => 'Financial Asset Line');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE k_line_curs;

    --Bug# 2982927 : Resetting okc inv organization id from k header
    okl_context.set_okc_org_context(p_chr_id => l_chr_id);
    --Bug# 2982927

    --Bug# 3222804 : Serial number control to be based on leasing inv org setup
    validate_srl_num_control(
                   p_api_version               => p_api_version,
                   p_init_msg_list             => p_init_msg_list,
                   x_return_status             => x_return_status,
                   x_msg_count                 => x_msg_count,
                   x_msg_data                  => x_msg_data,
                   p_cle_id                    => l_source_cle_id,
                   p_split_into_individuals_yn => p_txlv_rec.split_into_singles_flag,
                   p_split_into_units          => p_txlv_rec.split_into_units,
                   p_tal_id                    => p_txlv_rec.id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 3222804 : Serial number control to be based on leasing inv org setup

    --1. get values for the parent asset
    l_fa_exists := 'N';
    l_ast_line_rec := get_ast_line(l_source_cle_id,l_row_not_found);
    --dbms_output.put_line('After fetching asset line '||l_ast_line_rec.description);
    IF (l_row_not_found) THEN
       --Bug #2798006 : call create split transaction for Loans
       l_loan_yn := 'N';
       l_loan_yn := Check_If_Loan(P_Cle_Id        => l_source_cle_id,
                                  x_return_status => x_return_status);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF l_loan_yn = 'N' THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_SPLIT_ASSET_NOT_FOUND);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_loan_yn = 'Y' THEN
           l_fa_exists := 'N';
       END IF;
    ELSE
       l_fa_exists := 'Y';
    END IF;
    --Bug# 2798006 end.
--------------------------------------------------------------------------------
        i := 1;
        LOOP
        ------------------------------------------------------------------------
        -- Normal split asset parent adjustments
        IF (l_txdv_tbl(i).target_kle_id IS NOT NULL AND l_txdv_tbl(i).target_kle_id = p_txlv_rec.kle_id) THEN
           --this record needs asset adjustment only
           --no line creation is required
           --1.Call local procedure to adjust quantities and amounts
           l_txdv_rec := l_txdv_tbl(i);
           l_txlv_rec := p_txlv_rec;
           --dbms_output.put_line('before adjusting split lines');
           Adjust_Split_Lines(
                p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_cle_id         => l_source_cle_id,
                p_parent_line_id => l_source_cle_id,
                p_txdv_rec       => l_txdv_rec,
                p_txlv_rec       => l_txlv_rec);
            --dbms_output.put_line('after adjusting split lines'||x_return_status);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

           --2. Call Asset Retire Api -
           -- to confirm with Mukul whether retirement or
           -- adjustment will

          IF l_fa_exists = 'Y' THEN
               --to get all books for this asset
              OPEN all_books_curs(p_asset_id => l_ast_line_rec.asset_id);
              LOOP
                  FETCH all_books_curs INTO l_all_books_rec;
                  EXIT WHEN all_books_curs%NOTFOUND;
                  --reinitialize l_Ast_line_rec
                  l_ast_line_rec.START_DATE_ACTIVE         := l_all_books_rec.start_date_active;
                  l_ast_line_rec.END_DATE_ACTIVE           := l_all_books_rec.end_date_active;
                  l_ast_line_rec.ASSET_ID                  := l_all_books_rec.asset_id;
                  l_ast_line_rec.QUANTITY                  := l_all_books_rec.current_units;
                  l_ast_line_rec.ASSET_NUMBER              := l_all_books_rec.asset_number;
                  l_ast_line_rec.CORPORATE_BOOK            := l_all_books_rec.book_type_code; --this will be tax book in case of tax books inspite of var name
                  l_ast_line_rec.LIFE_IN_MONTHS            := l_all_books_rec.life_in_months;
                  l_ast_line_rec.ORIGINAL_COST             := l_all_books_rec.original_cost;
                  l_ast_line_rec.COST                      := l_all_books_rec.cost;
                  l_ast_line_rec.ADJUSTED_COST             := l_all_books_rec.adjusted_cost;
                  l_ast_line_rec.TAG_NUMBER                := l_all_books_rec.tag_number;
                  l_ast_line_rec.CURRENT_UNITS             := l_all_books_rec.current_units ;
                  l_ast_line_rec.SERIAL_NUMBER             := l_all_books_rec.serial_number;
                  l_ast_line_rec.REVAL_CEILING             := l_all_books_rec.reval_ceiling;
                  l_ast_line_rec.NEW_USED                  := l_all_books_rec.new_used;
                  l_ast_line_rec.IN_SERVICE_DATE           := l_all_books_rec.acquisition_date;
                  l_ast_line_rec.MANUFACTURER_NAME         := l_all_books_rec.manufacturer_name;
                  l_ast_line_rec.MODEL_NUMBER              := l_all_books_rec.model_number;
                  l_ast_line_rec.ASSET_TYPE                := l_all_books_rec.asset_type;
                  l_ast_line_rec.SALVAGE_VALUE             := l_all_books_rec.salvage_value;
                  l_ast_line_rec.PERCENT_SALVAGE_VALUE     := l_all_books_rec.percent_salvage_value;
                  l_ast_line_rec.DEPRECIATION_CATEGORY     := l_all_books_rec.depreciation_category;
                  l_ast_line_rec.DEPRN_START_DATE          := l_all_books_rec.deprn_start_date;
                  l_ast_line_rec.DEPRN_METHOD_CODE         := l_all_books_rec.deprn_method_code;
                  l_ast_line_rec.RATE_ADJUSTMENT_FACTOR    := l_all_books_rec.rate_adjustment_factor;
                  l_ast_line_rec.BASIC_RATE                := l_all_books_rec.basic_rate;
                  l_ast_line_rec.ADJUSTED_RATE             := l_all_books_rec.adjusted_rate;
                  l_ast_line_rec.RECOVERABLE_COST          := l_all_books_rec.recoverable_cost;
                  l_ast_line_rec.ORG_ID                    := l_all_books_rec.org_id;
                  l_ast_line_rec.SET_OF_BOOKS_ID           := l_all_books_rec.set_of_books_id;

                   --check period of addition
                  l_check_period_of_Addition := 'N';
                  OPEN check_period_of_addition(p_asset_id       => l_ast_line_rec.asset_id,
                                                p_book_type_code => l_ast_line_rec.corporate_book);
                      FETCH check_period_of_addition INTO l_check_period_of_Addition;
                      IF check_period_of_addition%NOTFOUND THEN
                          NULL;
                      END IF;
                  CLOSE check_period_of_addition;

                  /* Bug#4508050 - smadhava - Modified - Start*/
                  -- Commented code to avoid retiring of original asset after splitting
                  /*
                   IF NVL(l_check_period_of_addition,'N') = 'N' THEN
                   --dbms_output.put_line('before retiring fA'||x_return_status);
                   --check if call is being made from asset level termination process
                       l_asset_trmn_exists := '?';
                       OPEN asset_trmn_csr(pcleid => l_source_cle_id);
                       FETCH asset_trmn_csr INTO l_asset_trmn_exists;
                       IF asset_trmn_csr%NOTFOUND THEN
                           NULL;
                       END IF;
                       CLOSE asset_trmn_csr;

                       IF l_asset_trmn_exists = '!' THEN --exists
                          --call special procedure for asset level termination : suspen retirement
                          NULL;
                       ELSIF l_asset_trmn_exists = '?' THEN --does not exist
                           --Bug# : 3156924 : cost retirement for all books
                           --If (l_all_books_rec.book_class = 'CORPORATE') Then
                               FIXED_ASSET_RETIRE(p_api_version    =>  p_api_version,
                                                  p_init_msg_list =>  p_init_msg_list,
                                                  x_return_status =>  x_return_status,
                                                  x_msg_count     =>  x_msg_count,
                                                  x_msg_data      =>  x_msg_data,
                                                  p_ast_line_rec  =>  l_ast_line_rec,
                                                  p_txlv_rec      =>  l_txlv_rec,
                                                  p_txdv_rec      =>  l_txdv_rec,
                                                  --Bug# 3156924
                                                  p_trx_date       => l_trx_rec.date_trans_occurred,
                                                  p_trx_number   => l_trx_rec.trans_number,
                                                  --Bug# 4028371
                                                  x_fa_trx_date  => l_fa_retire_date);

                               --dbms_output.put_line('after retiring fA'||x_return_status);
                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;
                        */
                       /* Bug#4508050 - smadhava - Modified - End*/
                            --Bug# 3156924
                           /*
                           ElsIf (l_all_books_rec.book_class = 'TAX') Then
                               -- since FA does not allow unit retirements on tax books
                               -- we have to restore to doing adjustments here for tax books
                               FIXED_ASSET_ADJUST(p_api_version   => p_api_version,
                                                  p_init_msg_list  => p_init_msg_list,
                                                  x_return_status  => x_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data       => x_msg_data,
                                                  p_ast_line_rec   => l_ast_line_rec,
                                                  p_txlv_rec       => l_txlv_rec,
                                                  p_txdv_rec       => l_txdv_rec,
                                                  --3156924
                                                  p_trx_date       => l_trx_rec.date_trans_occurred,
                                                  p_trx_number   => l_trx_rec.trans_number,
                                                  --Bug# 4028371
                                                  x_fa_trx_date    => l_fa_adj_date);

                               --dbms_output.put_line('after adjusting fA'||x_return_status);
                               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                               END IF;
                           End If;
                           */
                  /* Bug#4508050 - smadhava - Modified - Start*/
                  /*
                       END IF; --asset_trmn_exists
                   ELSIF NVL(l_check_period_of_addition,'N') = 'Y' THEN
                  */
                  /* Bug#4508050 - smadhava - Modified - End*/
                       --dbms_output.put_line('before adjusting fA'||x_return_status);
                       --dbms_output.put_line('before adjusting fA units'||to_char(l_ast_line_rec.current_units));
                       FIXED_ASSET_ADJUST(p_api_version   => p_api_version,
                                          p_init_msg_list  => p_init_msg_list,
                                          x_return_status  => x_return_status,
                                          x_msg_count      => x_msg_count,
                                          x_msg_data       => x_msg_data,
                                          p_ast_line_rec   => l_ast_line_rec,
                                          p_txlv_rec       => l_txlv_rec,
                                          p_txdv_rec       => l_txdv_rec,
                                          --3156924
                                          p_trx_date       => l_trx_rec.date_trans_occurred,
                                          p_trx_number   => l_trx_rec.trans_number,
                    --Bug# 6373605--SLA populate source
                    p_sla_source_header_id    => l_txlv_rec.tas_id,
                    p_sla_source_header_table => 'OKL_TRX_ASSETS',
                    p_sla_source_try_id       => l_trx_rec.try_id,
                    p_sla_source_line_id      => l_txlv_rec.id,
                    p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
                    p_sla_source_chr_id       => l_chr_id,
                    p_sla_source_kle_id       => l_source_cle_id,
                    --Bug# 6373605--SLA populate sources
                                          --Bug# 4028371
                                          x_fa_trx_date    => l_fa_adj_date);

                       --dbms_output.put_line('after adjusting fA'||x_return_status);
                       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                       END IF;
                   /* Bug#4508050 - smadhava - Modified - Start*/
                   /*
                   END IF;
                   */
                   /* Bug#4508050 - smadhava - Modified - End*/
               END LOOP;
               CLOSE all_books_curs;
               --adjustments done for all the books
           END IF; --l_fa_exists
           --3. Put record onto the lines table
           l_cle_tbl(i).cle_id := l_source_cle_id;

       ELSIF l_txdv_tbl(i).target_kle_id IS NULL THEN

           --1.Call to Copy Lines api to create split line
           OKL_COPY_CONTRACT_PUB.COPY_CONTRACT_LINES(
                p_api_version       => p_api_version,
                p_init_msg_list     => p_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_from_cle_id       => l_source_cle_id,
                p_to_cle_id         => NULL,
                p_to_chr_id         => l_chr_id,
                p_to_template_yn        => 'N',
                p_copy_reference        =>  'COPY',
                p_copy_line_party_yn => 'Y',
                p_renew_ref_yn       => 'N',
                x_cle_id                     => l_split_cle_id);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --Bug# 4631549 : If release contract copy expected_asset_cost from source line to target line
            Open l_chrb_csr (p_chr_id => l_chr_id);
            fetch l_chrb_csr into l_chrb_rec;
            close l_chrb_csr;

            If nvl(l_chrb_rec.orig_system_source_code,OKL_API.G_MISS_CHAR) = 'OKL_RELEASE' then
                open l_exp_cost_csr(p_cle_id => l_source_cle_id);
                fetch l_exp_cost_csr into l_exp_cost_rec;
                close l_exp_cost_csr;

                l_clev_exp_cost_rec.id := l_split_cle_id;
                l_klev_exp_cost_rec.id := l_split_cle_id;
                l_klev_exp_cost_rec.expected_asset_cost := l_exp_cost_rec.expected_asset_cost;

                OKL_CONTRACT_PUB.update_contract_line(
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_clev_rec            => l_clev_exp_cost_rec,
                  p_klev_rec            => l_klev_exp_cost_rec,
                  x_clev_rec            => lx_clev_exp_cost_rec,
                  x_klev_rec            => lx_klev_exp_cost_rec
                  );

                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
             End If;

           --2. Call local procedure to adjust quantities and amounts
           --3. Call local procedure to null out line source references on copied lines
           l_txdv_rec := l_txdv_tbl(i);
           l_txlv_rec := p_txlv_rec;

           --Bug# 3502142
           l_round_split_comp_amt := 'N';
           IF (i = l_txdv_tbl.LAST) AND
              (NVL(l_txdv_tbl(i).split_percent,0) > 0 OR l_txdv_tbl(i).split_percent <> OKL_API.G_MISS_NUM) THEN
             l_round_split_comp_amt := 'Y';
           END IF;

           Adjust_Split_Lines(
                p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_cle_id         => l_split_cle_id,
                p_parent_line_id => l_source_cle_id,
                p_txdv_rec       => l_txdv_rec,
                p_txlv_rec       => l_txlv_rec,
                p_round_split_comp_amt => l_round_split_comp_amt);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            IF l_fa_exists = 'Y' THEN
                --to get all books for this asset
                OPEN all_books_curs(p_asset_id => l_ast_line_rec.asset_id);
                LOOP
                    FETCH all_books_curs INTO l_all_books_rec;
                    EXIT WHEN all_books_curs%NOTFOUND;
                    --reinitialize l_Ast_line_rec
                    l_ast_line_rec.START_DATE_ACTIVE         := l_all_books_rec.start_date_active;
                    l_ast_line_rec.END_DATE_ACTIVE           := l_all_books_rec.end_date_active;
                    l_ast_line_rec.ASSET_ID                  := l_all_books_rec.asset_id;
                    l_ast_line_rec.QUANTITY                  := l_all_books_rec.current_units;
                    l_ast_line_rec.ASSET_NUMBER              := l_all_books_rec.asset_number;
                    l_ast_line_rec.CORPORATE_BOOK            := l_all_books_rec.book_type_code; --this will be tax book in case of tax books inspite of var name
                    l_ast_line_rec.LIFE_IN_MONTHS            := l_all_books_rec.life_in_months;
                    l_ast_line_rec.ORIGINAL_COST             := l_all_books_rec.original_cost;
                    l_ast_line_rec.COST                      := l_all_books_rec.cost;
                    l_ast_line_rec.ADJUSTED_COST             := l_all_books_rec.adjusted_cost;
                    l_ast_line_rec.TAG_NUMBER                := l_all_books_rec.tag_number;
                    l_ast_line_rec.CURRENT_UNITS             := l_all_books_rec.current_units ;
                    l_ast_line_rec.SERIAL_NUMBER             := l_all_books_rec.serial_number;
                    l_ast_line_rec.REVAL_CEILING             := l_all_books_rec.reval_ceiling;
                    l_ast_line_rec.NEW_USED                  := l_all_books_rec.new_used;
                    l_ast_line_rec.IN_SERVICE_DATE           := l_all_books_rec.acquisition_date;
                    l_ast_line_rec.MANUFACTURER_NAME         := l_all_books_rec.manufacturer_name;
                    l_ast_line_rec.MODEL_NUMBER              := l_all_books_rec.model_number;
                    l_ast_line_rec.ASSET_TYPE                := l_all_books_rec.asset_type;
                    l_ast_line_rec.SALVAGE_VALUE             := l_all_books_rec.salvage_value;
                    l_ast_line_rec.PERCENT_SALVAGE_VALUE     := l_all_books_rec.percent_salvage_value;
                    l_ast_line_rec.DEPRECIATION_CATEGORY     := l_all_books_rec.depreciation_category;
                    l_ast_line_rec.DEPRN_START_DATE          := l_all_books_rec.deprn_start_date;
                    l_ast_line_rec.DEPRN_METHOD_CODE         := l_all_books_rec.deprn_method_code;
                    l_ast_line_rec.RATE_ADJUSTMENT_FACTOR    := l_all_books_rec.rate_adjustment_factor;
                    l_ast_line_rec.BASIC_RATE                := l_all_books_rec.basic_rate;
                    l_ast_line_rec.ADJUSTED_RATE             := l_all_books_rec.adjusted_rate;
                    l_ast_line_rec.RECOVERABLE_COST          := l_all_books_rec.recoverable_cost;
                    l_ast_line_rec.ORG_ID                    := l_all_books_rec.org_id;
                    l_ast_line_rec.SET_OF_BOOKS_ID           := l_all_books_rec.set_of_books_id;

                    --Bug# 6373605 start
                    If nvl(l_sts_code,OKL_API.G_MISS_CHAR) in
('TERMINATED','EXPIRED') Then
                        l_sla_asset_chr_id := NULL;
                    Else
                        l_sla_asset_chr_id := l_chr_id;
                    End If;
                    --Bug# 6373605

                    --4. Call Local procedure to add asset
                    FIXED_ASSET_ADD(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_ast_line_rec  => l_ast_line_rec,
                                    p_txlv_rec      => l_txlv_rec,
                                    p_txdv_rec      => l_txdv_rec,
                                    --3156924
                                    p_trx_date       => l_trx_rec.date_trans_occurred,
                                    p_trx_number   => l_trx_rec.trans_number,
          --Bug# 6373605--SLA populate source
          p_sla_source_header_id    => l_txlv_rec.tas_id,
          p_sla_source_header_table => 'OKL_TRX_ASSETS',
          p_sla_source_try_id       => l_trx_rec.try_id,
          p_sla_source_line_id      => l_txdv_rec.id,
          p_sla_source_line_table   => 'OKL_TXD_ASSETS_B',
          p_sla_source_chr_id       => l_chr_id,
          p_sla_source_kle_id       => l_split_cle_id,
          p_sla_asset_chr_id        => l_sla_asset_chr_id,
          --Bug# 6373605--SLA populate sources
                                    --Bug# 4028371
                                    x_fa_trx_date   => l_fa_add_date,
                                    x_asset_hdr_rec => l_asset_hdr_rec);
                    --dbms_output.put_line('after adding fixed asset '||x_return_status);
                    --dbms_output.put_line('after adding fixed asset '||to_char(l_asset_hdr_rec.asset_id));
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    --Bug# 4028371
                    --update the fa trx date on transaction line
                    If l_all_books_rec.book_class = 'CORPORATE' then
                        l_talv_date_rec.id          := l_txlv_rec.id;
                        l_talv_date_rec.fa_trx_date := l_fa_add_date;
                        l_split_cle_id_orig := l_split_cle_id;

                        okl_tal_pvt.update_row
                                        (p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_talv_rec      => l_talv_date_rec,
                                         x_talv_rec      => lx_talv_date_rec);
                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                        --Bug# 6326479
                          /* 7626121 commented out from here and moved outside
                              process_split_accounting(
                            p_api_version   => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_contract_id   => l_chr_id
                           ,p_kle_id        => l_split_cle_id
                           ,p_transaction_date=>l_trx_rec.date_trans_occurred
                           );

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF; */

                        -- Bug# 6189396 -- start
                       okl_execute_formula_pub.g_additional_parameters(1).name := '';
                       okl_execute_formula_pub.g_additional_parameters(1).value := null;
                        -- Bug# 6189396 -- end

                     End If;
                     --End Bug# 4028371
                END LOOP;
                CLOSE all_books_curs;

                           -- Bug 7626121
                              process_split_accounting(
                            p_api_version   => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count     => x_msg_count
                           ,x_msg_data      => x_msg_data
                           ,p_contract_id   => l_chr_id
                           ,p_kle_id        => l_split_cle_id_orig
                           ,p_transaction_date=>l_trx_rec.date_trans_occurred
                           );

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                       okl_execute_formula_pub.g_additional_parameters(1).name := '';
                       okl_execute_formula_pub.g_additional_parameters(1).value := null;
           END IF; --l_fa_exists
           --5. Tie back new asset records to OKL
           --dbms_output.put_line('before fetching the cim_id for FA link');
           OPEN c_cim(l_txdv_rec.id);
           LOOP
               FETCH c_cim INTO l_cim_id,l_cim_cle_id;
               --dbms_output.put_line('in fetching the cim_id for FA link'||to_char(l_cim_id));
               EXIT WHEN c_cim%NOTFOUND;
               IF l_fa_exists = 'Y' THEN
                   l_cimv_rec.id := l_cim_id;
                   l_cimv_rec.object1_id1 := l_asset_hdr_rec.asset_id;
                   l_cimv_rec.object1_id2 := '#';
                   l_cimv_rec.jtot_object1_code := 'OKX_ASSET';
                   l_cimv_rec.number_of_items := l_txdv_rec.quantity;
                   --dbms_output.put_line('Asset Id :'||to_char(l_asset_hdr_rec.asset_id));

                   OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version         => p_api_version,
                                                              p_init_msg_list   => p_init_msg_list,
                                                              x_return_status   => x_return_status,
                                                              x_msg_count           => x_msg_count,
                                                              x_msg_data            => x_msg_data,
                                                              p_cimv_rec            => l_cimv_rec,
                                                              x_cimv_rec            => l_cimv_rec_out);
                    --dbms_output.put_line('after updating contract item for Asset link '||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)  THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                END IF; --l_fa_exits
                -- take care of the ib instances for this FA line
                 --dbms_output.put_line('before splitting IB instances fa_line_id'||to_char(l_cimv_rec_out.cle_id));
                 --bug# : serial number processing for split asset by serial numbers - consolidate ib lines

                 IF NVL(l_txdv_rec.split_percent,0) NOT IN (0,OKL_API.G_MISS_NUM) THEN -- Is serialized
                    --consolidate the ib lines
                    consolidate_ib_lines(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_txdv_rec      => l_txdv_rec,
                                         p_txlv_rec      => l_txlv_rec
                                        );
                    --dbms_output.put_line('After consolidating ib lines'||x_return_status);
                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                 END IF;

                 --bug# : serial number processing for split asset by serial numbers - consolidate ib lines
                 --OPEN   ib_item_cur(p_fa_line_id => l_cimv_rec_out.cle_id);
                 OPEN   ib_item_cur(p_fa_line_id => l_cim_cle_id);
                 LOOP
                     FETCH  ib_item_cur INTO l_csi_id1,
                                             l_csi_id2,
                                             l_csi_cim_id,
                                             l_csi_cle_id,
                                             l_csi_chr_id;

                     EXIT WHEN ib_item_cur%NOTFOUND;
                     --create split ib instance
                     --dbms_output.put_line('Before Create ib instance csi id1:'|| x_return_status);
                     create_ib_instance(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_csi_id1       => l_csi_id1,
                                        p_csi_id2       => l_csi_id2,
                                        p_ib_cle_id     => l_csi_cle_id,
                                        p_chr_id        => l_csi_chr_id,
                                        p_split_qty     => l_txdv_rec.quantity,
                                        --new parameter added for split asset into components feature
                                        p_txdv_rec      => l_txdv_rec,
                                        x_instance_id   => l_csi_instance_id);

                      --dbms_output.put_line('After Create ib instance '||x_return_status||':'||to_char(l_csi_instance_id));
                      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

                      --update the coressponding okc_k_item record
                      l_cimv_rec.id := l_csi_cim_id;
                      l_cimv_rec.object1_id1 := TO_CHAR(l_csi_instance_id);
                      l_cimv_rec.object1_id2 := '#';
                      l_cimv_rec.jtot_object1_code := 'OKX_IB_ITEM';

                      OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version      => p_api_version,
                                                                 p_init_msg_list        => p_init_msg_list,
                                                                 x_return_status        => x_return_status,
                                                                 x_msg_count        => x_msg_count,
                                                                 x_msg_data             => x_msg_data,
                                                                 p_cimv_rec             => l_cimv_rec,
                                                                 x_cimv_rec             => l_cimv_rec_out);

                       --dbms_output.put_line('after updating contract item for IB link '||x_return_status);
                       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                           RAISE OKL_API.G_EXCEPTION_ERROR;
                       END IF;
                    END LOOP;
                 CLOSE ib_item_cur;

                 --Bug# 115.9 - Split by serial numbers
                 --consolidate if serialized and delete duplicate instance lines on child
                 --do it only for normal split assets as logic for split asset into compoets to be worked out
                 IF NVL(l_txdv_rec.split_percent,0) IN (0,OKL_API.G_MISS_NUM) THEN
                 ----
                 OPEN get_dup_inst_csr (p_asd_id        => l_txdv_rec.id);
                 LOOP
                     FETCH get_dup_inst_csr INTO l_dup_inst_cle_id, l_dup_ib_cle_id;
                     EXIT WHEN get_dup_inst_csr%NOTFOUND;
                     --Call line deletion API
                     delete_instance_lines(
                                               p_api_version    => p_api_version,
                                               p_init_msg_list  => p_init_msg_list,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data,
                                               p_inst_cle_id    => l_dup_inst_cle_id,
                                               p_ib_cle_id      => l_dup_ib_cle_id);
                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;
                 END LOOP;
                 CLOSE get_dup_inst_csr;
                 ----
                 END IF;
                 --Bug# 115.9 - Split by serial numbers


            END LOOP;
            CLOSE c_cim;
           --6. Update the lines table
           l_cle_tbl(i).cle_id := l_split_cle_id;
       END IF;
       IF (i=l_txdv_tbl.LAST) THEN


            IF (i = l_txdv_tbl.LAST) AND
               (NVL(l_txdv_tbl(i).split_percent,0) > 0 OR l_txdv_tbl(i).split_percent <> OKL_API.G_MISS_NUM) THEN
               --special processing for split asset components the original asset has to be retired completely
                --1.Abandon the old asset line as we have created assets
                Abandon_Parent_Asset(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_cle_id         => l_source_cle_id);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               IF l_fa_exists = 'Y' THEN
                   --2.Fully retire the Asset
                   OPEN all_books_curs(p_asset_id => l_ast_line_rec.asset_id);
                   LOOP
                       FETCH all_books_curs INTO l_all_books_rec;
                       EXIT WHEN all_books_curs%NOTFOUND;
                       --reinitialize l_Ast_line_rec
                       l_ast_line_rec.START_DATE_ACTIVE         := l_all_books_rec.start_date_active;
                       l_ast_line_rec.END_DATE_ACTIVE           := l_all_books_rec.end_date_active;
                       l_ast_line_rec.ASSET_ID                  := l_all_books_rec.asset_id;
                       l_ast_line_rec.QUANTITY                  := l_all_books_rec.current_units;
                       l_ast_line_rec.ASSET_NUMBER              := l_all_books_rec.asset_number;
                       l_ast_line_rec.CORPORATE_BOOK            := l_all_books_rec.book_type_code; --this will be tax book in case of tax books inspite of var name
                       l_ast_line_rec.LIFE_IN_MONTHS            := l_all_books_rec.life_in_months;
                       l_ast_line_rec.ORIGINAL_COST             := l_all_books_rec.original_cost;
                       l_ast_line_rec.COST                      := l_all_books_rec.cost;
                       l_ast_line_rec.ADJUSTED_COST             := l_all_books_rec.adjusted_cost;
                       l_ast_line_rec.TAG_NUMBER                := l_all_books_rec.tag_number;
                       l_ast_line_rec.CURRENT_UNITS             := l_all_books_rec.current_units ;
                       l_ast_line_rec.SERIAL_NUMBER             := l_all_books_rec.serial_number;
                       l_ast_line_rec.REVAL_CEILING             := l_all_books_rec.reval_ceiling;
                       l_ast_line_rec.NEW_USED                  := l_all_books_rec.new_used;
                       l_ast_line_rec.IN_SERVICE_DATE           := l_all_books_rec.acquisition_date;
                       l_ast_line_rec.MANUFACTURER_NAME         := l_all_books_rec.manufacturer_name;
                       l_ast_line_rec.MODEL_NUMBER              := l_all_books_rec.model_number;
                       l_ast_line_rec.ASSET_TYPE                := l_all_books_rec.asset_type;
                       l_ast_line_rec.SALVAGE_VALUE             := l_all_books_rec.salvage_value;
                       l_ast_line_rec.PERCENT_SALVAGE_VALUE     := l_all_books_rec.percent_salvage_value;
                       l_ast_line_rec.DEPRECIATION_CATEGORY     := l_all_books_rec.depreciation_category;
                       l_ast_line_rec.DEPRN_START_DATE          := l_all_books_rec.deprn_start_date;
                       l_ast_line_rec.DEPRN_METHOD_CODE         := l_all_books_rec.deprn_method_code;
                       l_ast_line_rec.RATE_ADJUSTMENT_FACTOR    := l_all_books_rec.rate_adjustment_factor;
                       l_ast_line_rec.BASIC_RATE                := l_all_books_rec.basic_rate;
                       l_ast_line_rec.ADJUSTED_RATE             := l_all_books_rec.adjusted_rate;
                       l_ast_line_rec.RECOVERABLE_COST          := l_all_books_rec.recoverable_cost;
                       l_ast_line_rec.ORG_ID                    := l_all_books_rec.org_id;
                       l_ast_line_rec.SET_OF_BOOKS_ID           := l_all_books_rec.set_of_books_id;

                       --check period of addition
                       l_check_period_of_Addition := 'N';
                       OPEN check_period_of_addition(p_asset_id       => l_ast_line_rec.asset_id,
                                                     p_book_type_code => l_ast_line_rec.corporate_book);
                           FETCH check_period_of_addition INTO l_check_period_of_Addition;
                           IF check_period_of_addition%NOTFOUND THEN
                               NULL;
                           END IF;
                       CLOSE check_period_of_addition;

                       /* Bug#4508050 - smadhava - Modified - Start*/
                       /*
                       IF NVL(l_check_period_of_addition,'N') = 'N' THEN
                       --dbms_output.put_line('before retiring fA'||x_return_status);

                           FIXED_ASSET_RETIRE(p_api_version    =>  p_api_version,
                                              p_init_msg_list =>  p_init_msg_list,
                                              x_return_status =>  x_return_status,
                                              x_msg_count     =>  x_msg_count,
                                              x_msg_data      =>  x_msg_data,
                                              p_ast_line_rec  =>  l_ast_line_rec,
                                              p_txlv_rec      =>  l_txlv_rec,
                                              p_txdv_rec      =>  l_txdv_rec,
                                              --Bug# 3156924
                                              p_trx_date       => l_trx_rec.date_trans_occurred,
                                              p_trx_number   => l_trx_rec.trans_number,
                                              x_fa_trx_date  => l_fa_retire_date);
                           --dbms_output.put_line('after retiring fA'||x_return_status);
                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                       ELSIF NVL(l_check_period_of_addition,'N') = 'Y' THEN
                        */
                       /* Bug#4508050 - smadhava - Modified - End*/

                       --ElsIf nvl(l_check_period_of_addition,'N') in ('Y','N') Then
                       --dbms_output.put_line('before adjusting fA'||x_return_status);
                       --dbms_output.put_line('before adjusting fA units'||to_char(l_ast_line_rec.current_units));
                           FIXED_ASSET_ADJUST(p_api_version   => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                              p_ast_line_rec   => l_ast_line_rec,
                                              p_txlv_rec       => l_txlv_rec,
                                              p_txdv_rec       => l_txdv_rec,
                                              --3156924
                                              p_trx_date       => l_trx_rec.date_trans_occurred,
                                              p_trx_number   => l_trx_rec.trans_number,
                    --Bug# 6373605--SLA populate source
                    p_sla_source_header_id    => l_txlv_rec.tas_id,
                    p_sla_source_header_table => 'OKL_TRX_ASSETS',
                    p_sla_source_try_id       => l_trx_rec.try_id,
                    p_sla_source_line_id      => l_txlv_rec.id,
                    p_sla_source_line_table   => 'OKL_TXL_ASSETS_B',
                    p_sla_source_chr_id       => l_chr_id,
                    p_sla_source_kle_id       => l_source_cle_id,
                    --Bug# 6373605--SLA populate sources
                                              x_fa_trx_date    => l_fa_adj_date);

                           --dbms_output.put_line('after adjusting fA'||x_return_status);
                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;
                       /* Bug#4508050 - smadhava - Modified - Start*/
                       /*
                       END IF;
                       */
                       /* Bug#4508050 - smadhava - Modified - End*/
                    END LOOP;
                    CLOSE all_books_curs;
                    --adjustments done for all the books
                END IF; --l_fa_exists
            -- end of full retirement for split asset into components parent asset
            END IF;
            --now exit out of the loop
            EXIT;
       ELSE
            i := i + 1;
            --dbms_output.put_line('number of split records processed'||to_char(i));
       END IF;
    END LOOP;
    --End If;--unable to track unchanged

    --Bug# 3222804 : relink ib lines in case split into individual units
    --and serialized
    IF NVL(l_txlv_rec.split_into_singles_flag,'N')  = 'Y' THEN
        Relink_Ib_Lines(p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_txlv_rec       => l_txlv_rec);

        --dbms_output.put_line('after calling process streams '|| x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    --Bug# 3257326 End : relink ib lines in case split into individual units

    x_cle_tbl := l_cle_tbl;
    --Bug#2648280 Begin
    --dbms_output.put_line('Before calling process streams'|| x_return_status);
    --rounding streams could be an issue:
    split_streams(p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_txl_id         => l_txlv_rec.id);
    --dbms_output.put_line('after calling process streams '|| x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug#2648280 End

    ------------------------------------------------------------------------
    --Bug# : 11.5.10 Recalculate costs on impacted lines and update
    ------------------------------------------------------------------------
  --Bug# 5946411: ER
  --recalculate only if split asset have status : BOOKED/EVERGREEN
  --dbms_output.put_line('before calling recalculate  l_sts_code'||l_sts_code);
  IF (l_sts_code IN ('BOOKED','EVERGREEN')) THEN

    recalculate_costs(
                        p_api_version         => p_api_version,
                        p_init_msg_list       => p_init_msg_list,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data,
                        p_chr_id              => l_chr_id,
                        p_cle_tbl             => x_cle_tbl);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
    END IF;

    --Bug# 6788253
    --call API check if asset is securitized
    OKL_SECURITIZATION_PVT.check_kle_securitized(
                            p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data,
                            p_kle_id              => l_source_cle_id,
                            p_effective_date      => SYSDATE,
                            x_value               => l_is_asset_securitized,
                            x_inv_agmt_chr_id_tbl => l_inv_agmt_chr_id_tbl);
    --dbms_output.put_line('SFA-0 : calling check_kle_securitized--status >'||x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_is_asset_securitized = OKL_API.G_TRUE THEN
     --call API to modify pool contents

      OKL_SECURITIZATION_PVT.modify_pool_contents(
                            p_api_version         => p_api_version,
                            p_init_msg_list       => p_init_msg_list,
                            x_return_status       => x_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data,
                            p_transaction_reason  => l_trx_reason_asset_split,
                            p_khr_id              => l_chr_id,
                            p_kle_id              => l_source_cle_id,
                            p_split_kle_ids       => x_cle_tbl,
                            p_transaction_date    => SYSDATE,
                            p_effective_date      => SYSDATE);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    --Bug# 6344223
    IF (l_sts_code = 'BOOKED') AND (p_source_call = 'UI') THEN
        sync_streams( p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_chr_id          => l_chr_id );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    ELSE
        -------------------------------------------------------------------------
        --Bug# : 11.5.10 Securitization impact
        -------------------------------------------------------------------------
         IF l_is_asset_securitized = OKL_API.G_TRUE THEN

             -- Bug# 4775555
             -- Historize and Re-create Disbursement Basis Streams
             OKL_STREAM_GENERATOR_PVT.create_disb_streams(
                 p_api_version         => p_api_version,
                 p_init_msg_list       => p_init_msg_list,
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data,
                 p_contract_id         => l_chr_id
              );

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

            --Bug# 6344223
             okl_stream_generator_pvt.create_pv_streams(
                   p_api_version         => 1.0,
                   p_init_msg_list       => OKC_API.G_FALSE,
                   x_return_status       => x_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_contract_id         => l_chr_id
                   );

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             okl_contract_rebook_pvt.create_inv_disb_adjustment(
                   p_api_version         => 1.0,
                   p_init_msg_list       => OKC_API.G_FALSE,
                   x_return_status       => x_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data,
                   p_orig_khr_id         => l_chr_id
                   );


             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
            --Bug# 6344223 : End
        END IF;


        -------------------------------------------------------------------------
        --Bug# : 11.5.10 Securitization impact End
        -------------------------------------------------------------------------
      -- Bug# 5946411: ER
      IF (l_sts_code IN ('TERMINATED','EXPIRED')) THEN
        create_split_asset_return (
                       p_api_version         =>  p_api_version,
                        p_init_msg_list       => p_init_msg_list,
                        x_return_status       => x_return_status,
                        x_msg_count           => x_msg_count,
                        x_msg_data            => x_msg_data,
                        p_kle_id             => l_source_cle_id,
                        p_cle_tbl             => x_cle_tbl,
                        p_txlv_rec            => l_txlv_rec
                        );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      --Bug# 5946411: ER end

      ------------------------------------------------------------------------
      --Bug# : R12.B eBTax impact Start
      ------------------------------------------------------------------------
      okl_process_sales_tax_pvt.calculate_sales_tax(
         p_api_version             => p_api_version,
         p_init_msg_list           => p_init_msg_list,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data,
         p_source_trx_id           =>  p_txlv_rec.tas_id, --<okl_trx_assets.id>,
         p_source_trx_name         => 'Split Asset',
         p_source_table            => 'OKL_TRX_ASSETS');

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      ------------------------------------------------------------------------
      --Bug# : R12.B eBTax impact End
      ------------------------------------------------------------------------

    --update the transaction record to processed.
    l_trxv_rec.id := p_txlv_rec.tas_id;
    l_trxv_rec.tsu_code := 'PROCESSED';
    OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_thpv_rec      => l_trxv_rec,
                        x_thpv_rec      => lx_trxv_rec);

     --dbms_output.put_line('after updating contract trx status to processed '||x_return_status);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

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
END Split_Fixed_Asset;
------------------------------------------------------------------------------
-- PROCEDURE version_contract
--
--  This procedure versions contract, i.e. making a contract Version History
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE version_contract(
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE
                            ) IS

  l_proc_name VARCHAR2(35) := 'VERSION_CONTRACT';
  l_cvmv_rec  okl_okc_migration_pvt.cvmv_rec_type;
  x_cvmv_rec  okl_okc_migration_pvt.cvmv_rec_type;

  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_cvmv_rec.chr_id := p_chr_id;
    okl_version_pub.version_contract(
                                     p_api_version => 1.0,
                                     p_init_msg_list => OKC_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_cvmv_rec      => l_cvmv_rec,
                                     x_cvmv_rec      => x_cvmv_rec --,
                                     --p_commit        => OKC_API.G_FALSE
                                    );
    RETURN;

  END version_contract;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : Split_Asset
--Description    : Selects the split Asset transaction against the line
--                 and splits the Asset in OKL and FA
--History        :
--                 08-Apr-2001  ashish.singh Created
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE Split_Fixed_Asset(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_cle_id        IN  NUMBER,
                            x_cle_tbl       OUT NOCOPY cle_tbl_type,
                            --Bug# 6344223
                            p_source_call   IN VARCHAR2 DEFAULT 'UI') IS

 l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT VARCHAR2(30) := 'SPLIT_FIXED_ASSET';
 l_api_version          CONSTANT NUMBER := 1.0;

  CURSOR fa_line_csr(p_cle_id IN NUMBER) IS
  SELECT cle.id,
         cle.dnz_chr_id
  FROM   OKC_K_LINES_B cle,
         OKC_LINE_STYLES_B lse
  WHERE  cle.cle_id = p_cle_id
  AND    cle.lse_id = lse.id
  AND    lse.lty_code = 'FIXED_ASSET'
--Bug Fix# 2744213 - 2761799
--  should not check for effectivity on sysdate
--  AND    trunc(nvl(start_date,sysdate)) <= trunc(sysdate)
--  AND    trunc(nvl(end_date,sysdate+1)) > trunc(sysdate)
 --Bug# 5946411: ER
 --commented the status as it should consider all kind of contract
 -- AND    cle.sts_code = 'BOOKED';
 ;
  --Bug# 5946411: ER end

  l_txlv_rec  txlv_rec_type;
  l_txdv_tbl  txdv_tbl_type;

  l_no_data_found BOOLEAN DEFAULT TRUE;
  l_fa_line_id    NUMBER;
  l_chr_id        OKC_K_LINES_B.dnz_chr_id%TYPE;

i NUMBER;

--Bug #2723498: 11.5.9 Split Asset by serial Number enhancement
CURSOR srl_num_csr1 (PTalid IN NUMBER) IS
SELECT COUNT(iti.serial_number)
FROM   okl_txl_itm_insts iti
WHERE  iti.tal_id = PTalid
AND    tal_type   = 'ALI'
AND    NVL(selected_for_split_flag,'N') = 'Y';


CURSOR srl_num_csr2 (PTalId IN NUMBER,
                     PTxdId IN NUMBER) IS
SELECT COUNT(iti.serial_number)
FROM   okl_txl_itm_insts iti
WHERE  iti.tal_id = PTalId
AND    iti.asd_id = PTxdId
AND    tal_type   = 'ALI'
AND    NVL(selected_for_split_flag,'N') = 'Y';

l_serial_count NUMBER;

--cursor for asset_number
CURSOR asset_num_csr (P_fin_ast_id IN NUMBER) IS
SELECT name
FROM   okc_k_lines_tl
WHERE  id = p_fin_ast_id;

l_asset_number OKC_K_LINES_TL.NAME%TYPE;

--cursor to fetch serial number control code
CURSOR srl_ctrl_csr (PInvItmId       IN NUMBER,
                     P_fin_ast_id    IN NUMBER) IS
SELECT mtl.serial_number_control_code
FROM   mtl_system_items     mtl,
       okc_k_headers_b      CHR,
       okc_k_lines_b        cle
WHERE  mtl.inventory_item_id = PInvItmId
AND    mtl.organization_id   = CHR.INV_ORGANIZATION_ID
AND    CHR.id                = cle.chr_id
AND    cle.id                = P_fin_ast_id;


l_srl_control_code    mtl_system_items.serial_number_control_code%TYPE;

l_serialized          VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

  --Bug# 5946411: ER
    CURSOR c_get_sts_code(p_chr_id NUMBER)
    IS
    SELECT st.ste_code
    FROM OKC_K_HEADERS_V chr,
         okc_statuses_b st
    WHERE chr.id = p_chr_id
    and st.code = chr.sts_code;
   lv_sts_code               OKC_K_HEADERS_V.STS_CODE%TYPE;
    --Bug# 5946411: ER end
    /*
    -- mvasudev, 08/23/2004
    -- Added PROCEDURE to enable Business Event
    */
           CURSOR l_cle_tas_csr
           IS
           SELECT cleb.dnz_chr_id,
                  tasb.date_trans_occurred
           FROM   okl_trx_assets tasb
                 ,okl_txl_assets_b txlb
                 ,okc_k_lines_b cleb
                         ,okc_line_styles_b lseb
           WHERE txlb.tas_id = tasb.id
           AND cleb.id = txlb.kle_id
           AND cleb.cle_id = p_cle_id
           AND cleb.lse_id = lseb.id
           AND lseb.lty_Code = 'FIXED_ASSET'
           AND tasb.tsu_code = 'ENTERED';

           l_dnz_chr_id NUMBER;
           l_trx_date DATE;

        PROCEDURE raise_business_event
        (p_dnz_chr_id IN NUMBER,
         p_trx_date IN DATE,
         x_return_status OUT NOCOPY VARCHAR2
        )
        IS


      l_parameter_list           wf_parameter_list_t;
        BEGIN
          x_return_status := OKL_API.G_RET_STS_SUCCESS;

                 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,l_dnz_chr_id,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_ASSET_ID,p_cle_id,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_TRANS_DATE,fnd_date.date_to_canonical(l_trx_date),l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                                                 x_return_status  => x_return_status,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data,
                                                                 p_event_name     => G_WF_EVT_KHR_SPLIT_ASSET_COMP,
                                                                 p_parameters     => l_parameter_list);


     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;

    /*
    -- mvasudev, 08/23/2004
    -- END, PROCEDURE to enable Business Event
    */

BEGIN

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

  --Verify cle_id
  x_return_status := verify_cle_id(p_cle_id => p_cle_id);
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --get fixed asset line
  OPEN   fa_line_csr(p_cle_id => p_cle_id) ;
  FETCH  fa_line_csr INTO l_fa_line_id, l_chr_id;
  IF fa_line_csr%NOTFOUND THEN
       NULL; --not exactly
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_INACTIVE_ASSET
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
      /*
      -- mvasudev, 10/28/2004
      -- Fetch parameters for Business Event enabling
      */
         FOR l_cle_tas_rec IN l_cle_tas_csr
         LOOP
          l_dnz_chr_id := l_cle_tas_rec.dnz_chr_id;
          l_trx_date := l_cle_tas_rec.date_trans_occurred;
         END LOOP;
      /*
      -- mvasudev, 10/28/2004
      -- END, Fetch parameters for Business Event enabling
      */

      l_txlv_rec := get_txlv_rec(l_fa_line_id, l_no_data_found);
      IF l_no_data_found THEN
          NULL;
          --dbms_output.put_line('No pending Split Asset Transactions FOR this Asset');
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_SPLIT_AST_TRX_NOT_FOUND
                              );
          RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
          --dbms_output.put_line('txlv id FOR FETCH OF txd '|| to_char(l_txlv_rec.id));
          l_txdv_tbl := get_trx_details (
                                         p_tal_id  => l_txlv_rec.id,
                                         x_no_data_found => l_no_data_found
                                         );
          IF l_no_data_found THEN
              NULL;
              --dbms_output.put_line('NO_DATA_FOUND FOR trx detail');
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_SPLIT_AST_TRX_NOT_FOUND
                                 );
              RAISE OKL_API.G_EXCEPTION_ERROR;

          ELSE

            --Bug #2723498 : 11.5.9 Split by serial numbers validation
            --1. validate for split into units

            IF NVL(l_txlv_rec.SPLIT_INTO_SINGLES_FLAG,'N') = 'N' AND
               NVL(l_txlv_rec.split_into_units,0) <> 0 THEN
               l_serialized := OKL_API.G_FALSE;
               l_serialized := Is_Serialized(p_cle_id => p_cle_id);
               IF (l_serialized = OKL_API.G_TRUE) THEN
                   OPEN  srl_num_csr1 (PTalid => l_txlv_rec.id);
                   FETCH srl_num_csr1 INTO l_serial_count;
                   IF srl_num_csr1%NOTFOUND THEN
                       NULL; --it is count cursor so should not happen
                   END IF;
                   CLOSE srl_num_csr1;

                   IF (l_serial_Count <> NVL(l_txlv_rec.split_into_units,0)) THEN
                       --Inventory item for asset is serialized. Please select split_into_units
                       --serial nubers to split.
                        l_asset_number := NULL;
                        OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                        FETCH asset_num_csr INTO l_asset_number;
                        IF asset_num_csr%NOTFOUND THEN
                            NULL;
                        END IF;
                        CLOSE asset_num_csr;

                       OKL_API.set_message(p_app_name     => G_APP_NAME,
                                           p_msg_name     => G_SPLIT_SERIAL_NOT_FOUND,
                                           p_token1       => G_ASSET_NUMBER_TOKEN,
                                           p_token1_value => l_asset_number,
                                           p_token2       => G_SPLIT_UNITS_TOKEN,
                                           p_token2_value => TO_CHAR(l_txlv_rec.split_into_units)
                                          );
                       --raise exception
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
               END IF;
            END IF;

            --2. validate for split asset into components
            IF NVL(l_txlv_rec.SPLIT_INTO_SINGLES_FLAG,'N') = 'X' THEN
                IF l_txdv_tbl.COUNT > 0 THEN
                    FOR i IN 1..l_txdv_tbl.COUNT
                    LOOP
                        l_serial_count := 0;
                        OPEN srl_ctrl_csr (PInvItmId       => l_txdv_tbl(i).inventory_item_id,
                                           P_fin_ast_id    => p_cle_id);
                        FETCH  srl_ctrl_csr
                        INTO   l_srl_control_code;
                        IF srl_ctrl_csr%NOTFOUND THEN
                           NULL; -- will not happen
                        END IF;
                        CLOSE srl_ctrl_csr;


                        IF NVL(l_srl_control_code,0) IN (2,5,6) THEN
                            --is serialized
                            --Bug fix #2744213 : invalid cursor
                            --slr_num_csr1 was being checked after opening srl_num_csr2
                            OPEN srl_num_csr2(PTalId => l_txlv_rec.id,
                                              PTxdId => l_txdv_tbl(i).id);
                            FETCH srl_num_csr2 INTO l_serial_count;
                            IF srl_num_csr2%NOTFOUND THEN
                                NULL; --it is count cursor so should not happen
                            END IF;
                            CLOSE srl_num_csr2;

                            IF  (l_serial_count <> l_txdv_tbl(i).quantity) THEN
                                --Inventory item for asset is serialized. Please select split_into_units
                                --serial nubers to split.

                                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                                    p_msg_name     => G_SPLIT_SERIAL_NOT_FOUND,
                                                    p_token1       => G_ASSET_NUMBER_TOKEN,
                                                    p_token1_value => l_txdv_tbl(i).Asset_Number,
                                                    p_token2       => G_SPLIT_UNITS_TOKEN,
                                                    p_token2_value => TO_CHAR(l_txdv_tbl(i).quantity)
                                                   );
                                --raise exception
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;
                        END IF;
                    END LOOP; -- txdv_tbl
                 END IF;-- txdv_tb.count > 0
             END IF;
            --Bug #2723498 : 11.5.9 Split by serial numbers validation End

            --Bug# 5946411: ER
            -- Get the sts code since we can version only active contract
            -- Required to perform split for the Expired contract
            OPEN  c_get_sts_code(l_chr_id);
            FETCH c_get_sts_code INTO lv_sts_code;
            CLOSE c_get_sts_code;
            --Bug# 5946411: ER End
            IF NVL(lv_sts_code,'X') = 'ACTIVE' THEN
            --version contract
            version_contract(
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_chr_id        => l_chr_id
                             );
            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            END IF; --Bug# 5946411: ER

            --Call split asset for transactions to be processed
            Split_Fixed_Asset(p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_txdv_tbl      => l_txdv_tbl,
                                p_txlv_rec      => l_txlv_rec,
                                x_cle_tbl       => x_cle_tbl,
                                --Bug# 6344223
                                p_source_call   => p_source_call);

              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
      END IF;
  END IF;

     /*
   -- mvasudev, 08/23/2004
   -- Code change to enable Business Event
   */
        raise_business_event(p_dnz_chr_id => l_dnz_chr_id,
                             p_trx_date => l_trx_date,
                             x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/23/2004
   -- END, Code change to enable Business Event
   */

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

END Split_Fixed_Asset;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name  : Cancel_Split_Asset_Trs
--Description     : Marks the split asset transaction as cancelled
--History        :
--                 03-Sep-2002  ashish.singh Created
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE Cancel_Split_Asset_Trs
                           (p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY   VARCHAR2,
                            x_msg_count     OUT NOCOPY   NUMBER,
                            x_msg_data      OUT NOCOPY   VARCHAR2,
                            p_cle_id        IN  NUMBER) IS

 l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT VARCHAR2(30) := 'CANCEL_SPLIT_ASSET_TRS';
 l_api_version          CONSTANT NUMBER := 1.0;

  --Cursor to get the fixed Asset Line Id
  CURSOR l_fixedasst_csr (p_finasst_line IN NUMBER) IS
  SELECT cle.id        fixedasst_line
  FROM   OKC_K_LINES_B cle,
         OKC_LINE_STYLES_B lse
  WHERE  cle.cle_id   = p_finasst_line
  AND    cle.lse_id   = lse.id
  AND    lse.lty_code = 'FIXED_ASSET';

  l_fixedasst_line  OKC_K_LINES_B.ID%TYPE;

  --Cursor to find kle_id split transaction lines to be cancelled..
  CURSOR l_tal_csr(p_fixedasst_line IN NUMBER) IS
  SELECT tal.id       tal_id,
         tas.id       tas_id
  FROM   OKL_TRX_ASSETS   TAS,
         OKL_TXL_ASSETS_B TAL
  WHERE  tas.id  = tal.tas_id
  AND    tas.tsu_code = 'ENTERED'
  AND    tas.tas_type = 'ALI'
  AND    tal.tal_type = 'ALI'
  AND    tal.kle_id   = p_fixedasst_line;

  l_tas_id    OKL_TRX_ASSETS.ID%TYPE;
  l_tal_id    OKL_TXL_ASSETS_B.ID%TYPE;
  l_cle_id    OKC_K_LINES_B.ID%TYPE;

  l_tasv_rec   okl_trx_assets_pub.thpv_rec_type;
  lx_tasv_rec  okl_trx_assets_pub.thpv_rec_type;

BEGIN
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

    l_cle_id := p_cle_id;
    --1.Verify p_cle_id
    x_return_status := verify_cle_id(p_cle_id => l_cle_id);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get fixedasset line id
    OPEN l_fixedasst_csr(p_finasst_line => l_cle_id);
    FETCH l_fixedasst_csr INTO l_fixedasst_line;
    IF l_fixedasst_csr%NOTFOUND THEN
        NULL;
    ELSE
        OPEN l_tal_csr(p_fixedasst_line => l_fixedasst_line);
        FETCH l_tal_csr INTO l_tal_id, l_tas_id;
        IF l_tal_csr%NOTFOUND THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_SPLIT_AST_TRX_NOT_FOUND
                              );
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            --update the transaction status to cancelled
            l_tasv_rec.id       := l_tas_id;
            l_tasv_rec.tsu_code := 'CANCELED';
            --update split transaction header
            OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
             p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_thpv_rec        => l_tasv_rec,
             x_thpv_rec        => lx_tasv_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;
        CLOSE l_tal_csr;
    END IF; --l_fixedasst_csr%NOTFOUND
    CLOSE l_fixedasst_csr;
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
END Cancel_Split_Asset_Trs;
Procedure check_ser_num_checked(x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_cle_id        IN  NUMBER) is

 l_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT VARCHAR2(30) := 'CHECK_SER_NUM_CHECKED';
 l_api_version          CONSTANT NUMBER := 1.0;

  CURSOR fa_line_csr(p_cle_id IN NUMBER) IS
  SELECT cle.id,
         cle.dnz_chr_id
  FROM   OKC_K_LINES_B cle,
         OKC_LINE_STYLES_B lse
  WHERE  cle.cle_id = p_cle_id
  AND    cle.lse_id = lse.id
  AND    lse.lty_code = 'FIXED_ASSET';

  l_txlv_rec  txlv_rec_type;
  l_txdv_tbl  txdv_tbl_type;

  l_no_data_found BOOLEAN DEFAULT TRUE;
  l_fa_line_id    NUMBER;
  l_chr_id        OKC_K_LINES_B.dnz_chr_id%TYPE;

i NUMBER;

CURSOR srl_num_csr1 (PTalid IN NUMBER) IS
SELECT COUNT(iti.serial_number)
FROM   okl_txl_itm_insts iti
WHERE  iti.tal_id = PTalid
AND    tal_type   = 'ALI'
AND    NVL(selected_for_split_flag,'N') = 'Y';

l_serial_count NUMBER;

--cursor for asset_number
CURSOR asset_num_csr (P_fin_ast_id IN NUMBER) IS
SELECT name
FROM   okc_k_lines_tl
WHERE  id = p_fin_ast_id;

l_asset_number OKC_K_LINES_TL.NAME%TYPE;

BEGIN

--  dbms_output.put_line('start');
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,OKL_API.G_FALSE
                               ,'_PVT'
                               ,x_return_status);
   -- Check if activity started successfully
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--  dbms_output.put_line('ebd activity');
  --Verify cle_id
  x_return_status := verify_cle_id(p_cle_id => p_cle_id);
--  dbms_output.put_line('x_return_status after verify : ' || x_return_status);
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

--  dbms_output.put_line('b4 fa_line_csr');
  --get fixed asset line
  OPEN   fa_line_csr(p_cle_id => p_cle_id) ;
  FETCH  fa_line_csr INTO l_fa_line_id, l_chr_id;
  IF fa_line_csr%NOTFOUND THEN
       NULL; --not exactly
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_INACTIVE_ASSET
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
      l_txlv_rec := get_txlv_rec(l_fa_line_id, l_no_data_found);
      IF l_no_data_found THEN
          NULL;
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_SPLIT_AST_TRX_NOT_FOUND
                              );
          RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
          l_txdv_tbl := get_trx_details (
                                         p_tal_id  => l_txlv_rec.id,
                                         x_no_data_found => l_no_data_found
                                         );
          IF l_no_data_found THEN
              NULL;
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_SPLIT_AST_TRX_NOT_FOUND
                                 );
              RAISE OKL_API.G_EXCEPTION_ERROR;

          ELSE
            IF NVL(l_txlv_rec.SPLIT_INTO_SINGLES_FLAG,'N') = 'N' AND
               NVL(l_txlv_rec.split_into_units,0) <> 0 THEN
--                   dbms_output.put_line('b4 srl_num_csr1:' || l_serial_count);
                   OPEN  srl_num_csr1 (PTalid => l_txlv_rec.id);
                   FETCH srl_num_csr1 INTO l_serial_count;
                   IF srl_num_csr1%NOTFOUND THEN
                       NULL; --it is count cursor so should not happen
                   END IF;
                   CLOSE srl_num_csr1;
                   IF (l_serial_Count <> NVL(l_txlv_rec.split_into_units,0))
THEN
                   --Inventory item for asset is serialized. Please select
                       --serial nubers to split.
                        l_asset_number := NULL;
--                        dbms_output.put_line('b4 asset_num_csr:');
                        OPEN asset_num_csr(p_fin_ast_id => p_cle_id);
                        FETCH asset_num_csr INTO l_asset_number;
                        IF asset_num_csr%NOTFOUND THEN
                            NULL;
                        END IF;
                        CLOSE asset_num_csr;
--                        dbms_output.put_line('after asset_num_csr:');
                       OKL_API.set_message(p_app_name     => G_APP_NAME,
                                           p_msg_name     =>
G_SPLIT_SERIAL_NOT_FOUND,
                                           p_token1       =>
G_ASSET_NUMBER_TOKEN,
                                           p_token1_value => l_asset_number,
                                           p_token2       =>
G_SPLIT_UNITS_TOKEN,
                                           p_token2_value =>
TO_CHAR(l_txlv_rec.split_into_units)
                                          );
                       --raise exception
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                   END IF;
            END IF;
        END IF;
      END IF;
    END IF;
    exception
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
end check_ser_num_checked;
END Okl_Split_Asset_Pvt;

/
