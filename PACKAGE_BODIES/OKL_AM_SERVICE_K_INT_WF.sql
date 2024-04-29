--------------------------------------------------------
--  DDL for Package Body OKL_AM_SERVICE_K_INT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SERVICE_K_INT_WF" AS
/* $Header: OKLRKWFB.pls 120.2.12010000.3 2009/10/01 21:56:14 rmunjulu ship $ */

  -- Rec Type to get and set notification body details
  TYPE noti_rec_type IS RECORD (
    success_main_body          FND_NEW_MESSAGES.message_text%TYPE,
    error_main_body            FND_NEW_MESSAGES.message_text%TYPE,
    termination_main_body      FND_NEW_MESSAGES.message_text%TYPE,
    return_main_body           FND_NEW_MESSAGES.message_text%TYPE,
    dispose_main_body          FND_NEW_MESSAGES.message_text%TYPE,
    scrap_main_body            FND_NEW_MESSAGES.message_text%TYPE,
    contract_dtls              FND_NEW_MESSAGES.message_text%TYPE,
    lease_contract             FND_NEW_MESSAGES.message_text%TYPE,
    service_contract           FND_NEW_MESSAGES.message_text%TYPE,
    termination_date           FND_NEW_MESSAGES.message_text%TYPE,
    asset_ret_date             FND_NEW_MESSAGES.message_text%TYPE,
    asset_disp_date            FND_NEW_MESSAGES.message_text%TYPE,
    schedule_assets            FND_NEW_MESSAGES.message_text%TYPE,
    asset_num                  FND_NEW_MESSAGES.message_text%TYPE,
    item                       FND_NEW_MESSAGES.message_text%TYPE,
    item_description           FND_NEW_MESSAGES.message_text%TYPE,
    reference_num              FND_NEW_MESSAGES.message_text%TYPE,
    serial_num                 FND_NEW_MESSAGES.message_text%TYPE,
    quantity                   FND_NEW_MESSAGES.message_text%TYPE,
    body_end                   FND_NEW_MESSAGES.message_text%TYPE);


  -- Start of comments
  --
  -- Procedure Name	: set_message
  -- Desciption     : Sets the message with tokens
  --                  Does NOT put the message on the message stack
  --                  This set_message is used instead of the standard OKL_API.set_message
  --                  because the OKL_API.set_message puts the message on message stack after
  --                  which it cannot be retrieved using FND_MESSAGE.get
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE set_message (
	p_app_name		IN VARCHAR2 DEFAULT G_APP_NAME,
	p_msg_name		IN VARCHAR2,
	p_token1		IN VARCHAR2 DEFAULT NULL,
	p_token1_value	IN VARCHAR2 DEFAULT NULL,
	p_token2		IN VARCHAR2 DEFAULT NULL,
	p_token2_value	IN VARCHAR2 DEFAULT NULL,
	p_token3		IN VARCHAR2 DEFAULT NULL,
	p_token3_value	IN VARCHAR2 DEFAULT NULL,
	p_token4		IN VARCHAR2 DEFAULT NULL,
	p_token4_value	IN VARCHAR2 DEFAULT NULL,
	p_token5		IN VARCHAR2 DEFAULT NULL,
	p_token5_value	IN VARCHAR2 DEFAULT NULL,
	p_token6		IN VARCHAR2 DEFAULT NULL,
	p_token6_value	IN VARCHAR2 DEFAULT NULL,
	p_token7		IN VARCHAR2 DEFAULT NULL,
	p_token7_value	IN VARCHAR2 DEFAULT NULL,
	p_token8		IN VARCHAR2 DEFAULT NULL,
	p_token8_value	IN VARCHAR2 DEFAULT NULL,
	p_token9		IN VARCHAR2 DEFAULT NULL,
	p_token9_value	IN VARCHAR2 DEFAULT NULL,
	p_token10		IN VARCHAR2 DEFAULT NULL,
	p_token10_value	IN VARCHAR2 DEFAULT NULL ) IS

  BEGIN

	FND_MESSAGE.set_name( P_APP_NAME, P_MSG_NAME);

	IF (p_token1 IS NOT NULL) AND (p_token1_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token1,
					            VALUE		=> p_token1_value);
	END IF;

	IF (p_token2 IS NOT NULL) AND (p_token2_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token2,
					            VALUE		=> p_token2_value);
	END IF;

	IF (p_token3 IS NOT NULL) AND (p_token3_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token3,
					            VALUE		=> p_token3_value);
	END IF;

	IF (p_token4 IS NOT NULL) AND (p_token4_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token4,
					            VALUE		=> p_token4_value);
	END IF;

	IF (p_token5 IS NOT NULL) AND (p_token5_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token5,
					            VALUE		=> p_token5_value);
	END IF;

	IF (p_token6 IS NOT NULL) AND (p_token6_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token6,
					            VALUE		=> p_token6_value);
	END IF;
	IF (p_token7 IS NOT NULL) AND (p_token7_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token7,
					            VALUE		=> p_token7_value);
	END IF;

	IF (p_token8 IS NOT NULL) AND (p_token8_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token8,
					            VALUE		=> p_token8_value);
	END IF;
	IF (p_token9 IS NOT NULL) AND (p_token9_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token9,
					            VALUE		=> p_token9_value);
	END IF;

	IF (p_token10 IS NOT NULL) AND (p_token10_value IS NOT NULL) THEN
		FND_MESSAGE.set_token(	TOKEN		=> p_token10,
					            VALUE		=> p_token10_value);
	END IF;

	--FND_MSG_PUB.add;

  END set_message;


  -- Start of comments
  --
  -- Procedure Name	: check_asset_scrapped
  -- Desciption     : Checks if there is a RETURN with type SCRAPPED
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  FUNCTION check_asset_scrapped (p_asset_id IN NUMBER) RETURN VARCHAR2 IS

      -- Get Asset Return Status Code for kle_id
      CURSOR get_return_dtls_csr(p_kle_id IN NUMBER) IS
      SELECT ART.ARS_CODE
      FROM   OKL_ASSET_RETURNS_B ART
      WHERE  ART.kle_id = p_kle_id
      AND    ART.ARS_CODE <> 'CANCELLED';

      l_scrapped_yn VARCHAR2(1) := 'N';

  BEGIN

      FOR get_return_dtls_rec IN get_return_dtls_csr(p_asset_id) LOOP

          IF get_return_dtls_rec.ars_code = 'SCRAPPED' THEN

              l_scrapped_yn := 'Y';

          END IF;

      END LOOP;

      RETURN l_scrapped_yn;

  EXCEPTION
       WHEN OTHERS THEN
          RETURN NULL;
  END check_asset_scrapped;


  -- Start of comments
  --
  -- Procedure Name	: get_set_noti_dtls
  -- Desciption     : Gets the notification attributes and Sets the notification
  --                  messages. Need this procedure to make the message translatable
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE get_set_noti_dtls (
                     p_itemtype	IN  VARCHAR2,
                     p_itemkey  IN  VARCHAR2,
                     x_noti_rec OUT NOCOPY noti_rec_type) IS


      l_okl_contract_number     OKC_K_HEADERS_B.contract_number%TYPE;
      l_oks_contract_number     OKC_K_HEADERS_B.contract_number%TYPE;
      l_dispose_date            DATE;
      l_return_date             DATE;
      l_term_date               DATE;

      l_noti_rec                noti_rec_type;

  BEGIN

      -- ********
      -- Get the Attribute values
      -- ********

      l_okl_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => p_itemtype,
                                     itemkey  => p_itemkey,
                                     aname    => 'OKL_CONTRACT_NUMBER');

      l_oks_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => p_itemtype,
                                     itemkey  => p_itemkey,
                                     aname    => 'OKS_CONTRACT_NUMBER');

      l_dispose_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => p_itemtype,
                                     itemkey  => p_itemkey,
                                     aname    => 'DISPOSAL_DATE');

      l_return_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => p_itemtype,
                                     itemkey  => p_itemkey,
                                     aname    => 'RETURN_DATE');


      l_term_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => p_itemtype,
                                     itemkey  => p_itemkey,
                                     aname    => 'TERMINATION_DATE');

      -- ********
      -- Set the Notification body texts
      -- ********

      -- Success Notifications main body
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SUCCESS_MAIN_BODY',
                   p_token1       => 'LEASE_CONTRACT',
                   p_token1_value => l_okl_contract_number,
                   p_token2       => 'TERMINATION_DATE',
                   p_token2_value => l_term_date,
                   p_token3       => 'SERVICE_CONTRACT',
                   p_token3_value => l_oks_contract_number);

      l_noti_rec.success_main_body := FND_MESSAGE.get;

      -- Error Notifications main body
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ERROR_MAIN_BODY',
                   p_token1       => 'LEASE_CONTRACT',
                   p_token1_value => l_okl_contract_number,
                   p_token2       => 'TERMINATION_DATE',
                   p_token2_value => l_term_date,
                   p_token3       => 'SERVICE_CONTRACT',
                   p_token3_value => l_oks_contract_number);

      l_noti_rec.error_main_body := FND_MESSAGE.get;

      -- Termination Notifications main body
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_TERM_MAIN_BODY',
                   p_token1       => 'LEASE_CONTRACT',
                   p_token1_value => l_okl_contract_number,
                   p_token2       => 'TERMINATION_DATE',
                   p_token2_value => l_term_date,
                   p_token3       => 'SERVICE_CONTRACT',
                   p_token3_value => l_oks_contract_number);

      l_noti_rec.termination_main_body := FND_MESSAGE.get;

      -- Return Notifications main body
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_RETURN_MAIN_BODY',
                   p_token1       => 'SERVICE_CONTRACT',
                   p_token1_value => l_oks_contract_number,
                   p_token2       => 'RETURN_DATE',
                   p_token2_value => l_return_date);

      l_noti_rec.return_main_body := FND_MESSAGE.get;

      -- Dispose Notifications main body
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_DISPOSE_MAIN_BODY',
                   p_token1       => 'SERVICE_CONTRACT',
                   p_token1_value => l_oks_contract_number,
                   p_token2       => 'DISPOSE_DATE',
                   p_token2_value => l_dispose_date);

      l_noti_rec.dispose_main_body := FND_MESSAGE.get;

      -- Dispose Notifications main body   -- If Scrapped
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SCRAP_MAIN_BODY',
                   p_token1       => 'SERVICE_CONTRACT',
                   p_token1_value => l_oks_contract_number,
                   p_token2       => 'DISPOSE_DATE',
                   p_token2_value => l_dispose_date);

      l_noti_rec.scrap_main_body := FND_MESSAGE.get;

      -- Contract Details
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_CONTRACT_DTLS');

      l_noti_rec.contract_dtls := FND_MESSAGE.get;

      -- Lease Contract
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_LEASE_CONTRACT');

      l_noti_rec.lease_contract := FND_MESSAGE.get;

      -- Service Contract
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SERVICE_CONTRACT');

      l_noti_rec.service_contract := FND_MESSAGE.get;

      -- Termination Date
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_TERMINATION_DATE');

      l_noti_rec.termination_date := FND_MESSAGE.get;

      -- Asset Return Date
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ASSET_RET_DATE');

      l_noti_rec.asset_ret_date := FND_MESSAGE.get;

      -- Asset Sale Date
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ASSET_DISP_DATE');

      l_noti_rec.asset_disp_date := FND_MESSAGE.get;

      -- Schedule of Assets
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SCHEDULE_ASSETS');

      l_noti_rec.schedule_assets := FND_MESSAGE.get;

      -- Asset Number
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ASSET_NUM');

      l_noti_rec.asset_num := FND_MESSAGE.get;

      -- Item
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ITEM');

      l_noti_rec.item := FND_MESSAGE.get;

      -- Description
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ITEM_DESCRIPTION');

      l_noti_rec.item_description := FND_MESSAGE.get;

      -- Reference Number
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_REFERENCE_NUM');

      l_noti_rec.reference_num := FND_MESSAGE.get;

      -- Serial Number
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SERIAL_NUM');

      l_noti_rec.serial_num := FND_MESSAGE.get;

      -- Quantity
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_QUANTITY');

      l_noti_rec.quantity := FND_MESSAGE.get;

      -- Body End
      set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_BODY_END');

      l_noti_rec.body_end := FND_MESSAGE.get;

      -- ********
      -- Set the out parameter
      -- ********

      x_noti_rec := l_noti_rec;

  EXCEPTION
       WHEN OTHERS THEN
          NULL;
  END get_set_noti_dtls;


  -- Start of comments
  --
  -- Procedure Name	: get_assets_schedule
  -- Desciption     : Get the Asset Details when financial kle_id is supplied,
  --                  can return multiple records if serialized asset
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE get_assets_schedule (
                     p_kle_id              IN NUMBER,
                     x_asset_schedule_tbl  OUT NOCOPY kle_tbl_type) IS


      -- Get the asset details, if serialized asset then will have multiple
      -- rows returned for all serial numbers
      -- p_kle_id : is serviced financial asset line  with service contract link
      CURSOR get_asset_dtls_csr (p_kle_id IN NUMBER) IS
      SELECT CLET_FIN.name               asset_number,
             MTL.description             item_number,
             CLET_FIN.item_description   item_description ,
             CSI.instance_number         install_base_number,
             CSI.serial_number           serial_number,
             CSI.quantity                asset_quantity
      FROM   CSI_ITEM_INSTANCES CSI,
             OKC_K_ITEMS        CIM_IB,
             OKC_LINE_STYLES_B  LSE_IB,
             OKC_K_LINES_B      CLE_IB,
             OKC_LINE_STYLES_B  LSE_INST,
             OKC_K_LINES_B      CLE_INST,
             OKC_LINE_STYLES_B  LSE_MODEL,
             OKC_K_LINES_B      CLE_MODEL,
             OKC_K_ITEMS        CIM_MODEL,
             MTL_SYSTEM_ITEMS   MTL,
             OKC_LINE_STYLES_B  LSE_FIN,
             OKC_K_LINES_TL     CLET_FIN,
             OKC_K_LINES_B      CLE_FIN
      WHERE  CLE_FIN.id               = CLET_FIN.id
      AND    CLET_FIN.LANGUAGE        = USERENV('LANG')
      AND    LSE_FIN.id               = CLE_FIN.lse_id
      AND    LSE_FIN.lty_code         = 'FREE_FORM1'
      AND    CLE_INST.cle_id          = CLE_FIN.id
      AND    CLE_INST.dnz_chr_id      = CLE_FIN.dnz_chr_id
      AND    CLE_INST.lse_id          = LSE_INST.id
      AND    LSE_INST.lty_code        = 'FREE_FORM2'
      AND    CLE_IB.cle_id            = CLE_INST.id
      AND    CLE_IB.dnz_chr_id        = CLE_FIN.dnz_chr_id
      AND    CLE_IB.lse_id            = LSE_IB.id
      AND    LSE_IB.lty_code          = 'INST_ITEM'
      AND    CIM_IB.cle_id            = CLE_IB.id
      AND    CIM_IB.dnz_chr_id        = CLE_IB.dnz_chr_id
      AND    CIM_IB.object1_id1       = CSI.instance_id (+)
--      AND    CIM_IB.object1_id2       = '#'
      AND    CIM_IB.jtot_object1_code = 'OKX_IB_ITEM'
      AND    CLE_FIN.id               = CLE_MODEL.cle_id
      AND    CLE_MODEL.lse_id         = LSE_MODEL.id
      AND    LSE_MODEL.lty_code       = 'ITEM'
      AND    CLE_MODEL.id             = CIM_MODEL.cle_id
      AND    CIM_MODEL.object1_id1    = MTL.inventory_item_id
      AND    CIM_MODEL.object1_id2    = TO_NUMBER(MTL.organization_id)
      AND    CLE_FIN.id               = p_kle_id;

      l_asset_schedule_tbl kle_tbl_type;
      i NUMBER := 1;

  BEGIN

     -- Get the asset details for the financial line passed and set kle_tbl
     FOR get_asset_dtls_rec IN get_asset_dtls_csr(p_kle_id) LOOP

         l_asset_schedule_tbl(i).asset_number := get_asset_dtls_rec.asset_number;
         l_asset_schedule_tbl(i).item_number  := get_asset_dtls_rec.item_number;
         l_asset_schedule_tbl(i).item_description := get_asset_dtls_rec.item_description;
         l_asset_schedule_tbl(i).install_base_number := get_asset_dtls_rec.install_base_number;
         l_asset_schedule_tbl(i).serial_number := get_asset_dtls_rec.serial_number;
         l_asset_schedule_tbl(i).asset_quantity := get_asset_dtls_rec.asset_quantity;

         i := i + 1;
     END LOOP;

     -- Set the out tbl
     x_asset_schedule_tbl := l_asset_schedule_tbl;

  EXCEPTION
       WHEN OTHERS THEN
          NULL;
  END get_assets_schedule;

  -- Start of comments
  --
  -- Procedure Name	: get_assets_schedule
  -- Desciption     : Get the Serviced Assets with Details when okl contract id is supplied,
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --                : RMUNJULU 05-JAN-04 SERVICE K UPDATES, changed cursors
  --                  get_k_serviced_assets_csr and get_q_serviced_assets_csr -- added DISTINCT
  --                  since same asset can exist as multiple covered products in OKS if it is
  --                  serialized and then in that case duplicate records are shown which we want
  --                  to avoid
  --
  -- End of comments
  PROCEDURE get_assets_schedule (
                     p_khr_id               IN NUMBER,
                     p_quote_id             IN NUMBER,
                     x_asset_schedule_tbl   OUT NOCOPY kle_tbl_type) IS

      -- Get all serviced assets for the contract
      CURSOR get_k_serviced_assets_csr (p_khr_id IN NUMBER) IS
      SELECT DISTINCT LNK_SRV_CIM.object1_id1   asset_id
      FROM   OKC_K_HEADERS_B   OKS_CHRB,
             OKC_LINE_STYLES_B OKS_COV_PD_LSE,
             OKC_K_LINES_B     OKS_COV_PD_CLEB,
             OKC_K_REL_OBJS    KREL,
             OKC_LINE_STYLES_B LNK_SRV_LSE,
             OKC_STATUSES_B    LNK_SRV_STS,
             OKC_K_LINES_B     LNK_SRV_CLEB,
             OKC_K_ITEMS       LNK_SRV_CIM,
             OKC_K_LINES_B     FIN_LINE
      WHERE  OKS_CHRB.scs_code             = 'SERVICE'
      AND    OKS_CHRB.id                   = OKS_COV_PD_CLEB.dnz_chr_id
      AND    OKS_COV_PD_CLEB.lse_id        = OKS_COV_PD_LSE.id
      AND    OKS_COV_PD_LSE.lty_code       = 'COVER_PROD'
      AND    '#'                           = KREL.object1_id2
      AND    OKS_COV_PD_CLEB.id            = KREL.object1_id1
      AND    KREL.rty_code                 = 'OKLSRV'
      AND    KREL.cle_id                   = LNK_SRV_CLEB.id
      AND    LNK_SRV_CLEB.lse_id           = LNK_SRV_LSE.id
      AND    LNK_SRV_LSE.lty_code          = 'LINK_SERV_ASSET'
      AND    LNK_SRV_CLEB.sts_code         = LNK_SRV_STS.code
      AND    LNK_SRV_CLEB.id               = LNK_SRV_CIM.cle_id
      AND    LNK_SRV_CIM.jtot_object1_code = 'OKX_COVASST'
      AND    LNK_SRV_CIM.object1_id2       = '#'
      AND    LNK_SRV_CIM.object1_id1       = FIN_LINE.id
      AND    FIN_LINE.dnz_chr_id           = p_khr_id;


      -- Get all serviced assets for the quote
      CURSOR get_q_serviced_assets_csr (p_qte_id IN NUMBER) IS
      SELECT DISTINCT LNK_SRV_CIM.object1_id1   asset_id
      FROM   OKC_K_HEADERS_B       OKS_CHRB,
             OKC_LINE_STYLES_B     OKS_COV_PD_LSE,
             OKC_K_LINES_B         OKS_COV_PD_CLEB,
             OKC_K_REL_OBJS        KREL,
             OKC_LINE_STYLES_B     LNK_SRV_LSE,
             OKC_STATUSES_B        LNK_SRV_STS,
             OKC_K_LINES_B         LNK_SRV_CLEB,
             OKC_K_ITEMS           LNK_SRV_CIM,
             OKC_K_LINES_B         FIN_LINE,
             OKL_TXL_QUOTE_LINES_B TQL
      WHERE  OKS_CHRB.scs_code             = 'SERVICE'
      AND    OKS_CHRB.id                   = OKS_COV_PD_CLEB.dnz_chr_id
      AND    OKS_COV_PD_CLEB.lse_id        = OKS_COV_PD_LSE.id
      AND    OKS_COV_PD_LSE.lty_code       = 'COVER_PROD'
      AND    '#'                           = KREL.object1_id2
      AND    OKS_COV_PD_CLEB.id            = KREL.object1_id1
      AND    KREL.rty_code                 = 'OKLSRV'
      AND    KREL.cle_id                   = LNK_SRV_CLEB.id
      AND    LNK_SRV_CLEB.lse_id           = LNK_SRV_LSE.id
      AND    LNK_SRV_LSE.lty_code          = 'LINK_SERV_ASSET'
      AND    LNK_SRV_CLEB.sts_code         = LNK_SRV_STS.code
      AND    LNK_SRV_CLEB.id               = LNK_SRV_CIM.cle_id
      AND    LNK_SRV_CIM.jtot_object1_code = 'OKX_COVASST'
      AND    LNK_SRV_CIM.object1_id2       = '#'
      AND    LNK_SRV_CIM.object1_id1       = FIN_LINE.id
      AND    FIN_LINE.id                   = TQL.kle_id
      AND    TQL.qlt_code                  = 'AMCFIA'
      AND    TQL.qte_id                    = p_qte_id;


      l_asset_id NUMBER;
      l_temp_kle_tbl kle_tbl_type;
      l_asset_schedule_tbl kle_tbl_type;
      j NUMBER := 1;
      k NUMBER := 1;

  BEGIN

     -- IF no Quote ID passed then Full Termination
     IF p_quote_id IS NULL
     OR p_quote_id = OKL_API.G_MISS_NUM THEN

          -- Get the serviced assets for the contract
          FOR get_k_serviced_assets_rec IN get_k_serviced_assets_csr(p_khr_id) LOOP

              l_asset_id := get_k_serviced_assets_rec.asset_id;

              -- Get the assets schedule for financial asset id
              get_assets_schedule (
                     p_kle_id              => l_asset_id,
                     x_asset_schedule_tbl  => l_temp_kle_tbl);

              IF l_temp_kle_tbl.COUNT > 0 THEN

                  -- loop thru asset details
                  FOR j IN l_temp_kle_tbl.FIRST..l_temp_kle_tbl.LAST LOOP

                      -- fill up the asset schedule table
                      l_asset_schedule_tbl(k).asset_number := l_temp_kle_tbl(j).asset_number;
                      l_asset_schedule_tbl(k).item_number := l_temp_kle_tbl(j).item_number;
                      l_asset_schedule_tbl(k).item_description := l_temp_kle_tbl(j).item_description;
                      l_asset_schedule_tbl(k).install_base_number := l_temp_kle_tbl(j).install_base_number;
                      l_asset_schedule_tbl(k).serial_number := l_temp_kle_tbl(j).serial_number;
                      l_asset_schedule_tbl(k).asset_quantity := l_temp_kle_tbl(j).asset_quantity;

                      k := k + 1;
                  END LOOP;
              END IF;
          END LOOP;
     ELSE -- Quote Id passed - Get the Serviced Assets for the Quote Assets

          -- Get the serviced assets for the contract
          FOR get_q_serviced_assets_rec IN get_q_serviced_assets_csr(p_quote_id) LOOP

              l_asset_id := get_q_serviced_assets_rec.asset_id;

              -- Get the assets schedule for financial asset id
              get_assets_schedule (
                     p_kle_id              => l_asset_id,
                     x_asset_schedule_tbl  => l_temp_kle_tbl);

              IF l_temp_kle_tbl.COUNT > 0 THEN

                  -- loop thru asset details
                  FOR j IN l_temp_kle_tbl.FIRST..l_temp_kle_tbl.LAST LOOP

                      -- fill up the asset schedule table
                      l_asset_schedule_tbl(k).asset_number := l_temp_kle_tbl(j).asset_number;
                      l_asset_schedule_tbl(k).item_number := l_temp_kle_tbl(j).item_number;
                      l_asset_schedule_tbl(k).item_description := l_temp_kle_tbl(j).item_description;
                      l_asset_schedule_tbl(k).install_base_number := l_temp_kle_tbl(j).install_base_number;
                      l_asset_schedule_tbl(k).serial_number := l_temp_kle_tbl(j).serial_number;
                      l_asset_schedule_tbl(k).asset_quantity := l_temp_kle_tbl(j).asset_quantity;

                      k := k + 1;
                  END LOOP;
              END IF;
          END LOOP;
     END IF;

     -- set the out asset_schedule_tbl
     x_asset_schedule_tbl := l_asset_schedule_tbl;

  EXCEPTION
       WHEN OTHERS THEN
          NULL;
  END  get_assets_schedule;

  -- Start of comments
  --
  -- Procedure Name	: raise_service_k_int_event
  -- Desciption     : Raise the Service K Integration WF Process Event
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --                : RMUNJULU 23-DEC-03 SERVICE K UPDATES
  --
  -- End of comments
  PROCEDURE raise_service_k_int_event (
                     p_transaction_id   IN VARCHAR2,
                     p_source           IN VARCHAR2,
                     p_quote_id         IN VARCHAR2 DEFAULT NULL,
                     p_oks_contract     IN VARCHAR2 DEFAULT NULL, --RMUNJULU 23-DEC-03 SERVICE K UPDATES
                     p_transaction_date IN DATE)  IS


    l_parameter_list        WF_PARAMETER_LIST_T;
    l_key                   WF_ITEMS.item_key%TYPE;
    l_event_name            WF_EVENTS.NAME%TYPE := 'oracle.apps.okl.am.servicekintegration';
    l_seq                   NUMBER;

    -- Cursor to get the value of the sequence
  	CURSOR okl_key_csr IS
  	SELECT okl_wf_item_s.nextval
  	FROM   DUAL;

  BEGIN

    SAVEPOINT raise_service_k_int_event;

  	OPEN  okl_key_csr;
  	FETCH okl_key_csr INTO l_seq;
  	CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq ;

    -- *******
    -- Set the parameter list
    -- *******

    WF_EVENT.AddParameterToList('TRANSACTION_ID',
                                p_transaction_id,
                                l_parameter_list);

    WF_EVENT.AddParameterToList('SOURCE',
                                p_source,
                                l_parameter_list);

    IF p_quote_id IS NOT NULL THEN

        WF_EVENT.AddParameterToList('QUOTE_ID',
                                    p_quote_id,
                                    l_parameter_list);

    END IF;

    --RMUNJULU 23-DEC-03 SERVICE K UPDATES Added code to set OKS contract ID
    IF p_oks_contract IS NOT NULL THEN

        WF_EVENT.AddParameterToList('OKS_CONTRACT_ID',
                                    p_oks_contract,
                                    l_parameter_list);

    END IF;

    WF_EVENT.AddParameterToList('TRANSACTION_DATE',
                                p_transaction_date,
                                l_parameter_list);
    --added by akrangan
    wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

    -- Raise Business Event
    WF_EVENT.raise(
                 p_event_name  => l_event_name,
                 p_event_key   => l_key,
                 p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;
      ROLLBACK TO raise_service_k_int_event;

  END  raise_service_k_int_event;

  -- Start of comments
  --
  -- Procedure Name	: populate_attributes
  -- Desciption     : Populates the attributes for this WF
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --                : RMUNJULU 3061751 Got the right OKL and OKS managers
  --                : RMUNJULU 3061751 Set OKC APPROVER AS OKL and OKS managers
  --                : RMUNJULU 3061751 Changed Date Format Mask
  --                : RMUNJULU 23-DEC-03 SERVICE K UPDATES
  --
  -- End of comments
  PROCEDURE populate_attributes(
                     itemtype	IN  VARCHAR2,
                     itemkey  	IN  VARCHAR2,
                     actid		IN  NUMBER,
                     funcmode	IN  VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2) IS


    -- Get the OKL contract details
    CURSOR okl_k_dtls_csr ( p_okl_khr_id IN NUMBER) IS
    SELECT CHR.contract_number
    FROM   OKC_K_HEADERS_B CHR
    WHERE  CHR.id = p_okl_khr_id;

    -- Get the OKS contract details
    CURSOR oks_k_dtls_csr ( p_oks_khr_id IN NUMBER) IS
    SELECT CHR.contract_number
    FROM   OKC_K_HEADERS_B CHR
    WHERE  CHR.id = p_oks_khr_id;

    -- Get the asset details
    CURSOR asset_dtls_csr ( p_id IN NUMBER) IS
    SELECT CLE.dnz_chr_id
    FROM   OKC_K_LINES_B CLE
    WHERE  CLE.id = p_id;

    l_source   VARCHAR2(100);
    l_transaction_id VARCHAR2(100);
    l_quote_id VARCHAR2(100);
    l_message VARCHAR2(2000);
    l_okl_chr_id NUMBER;
    l_oks_chr_id NUMBER;
    l_okl_contract_number VARCHAR2(300);
    l_oks_contract_number VARCHAR2(300);
    l_asset_id NUMBER;
    l_return_status VARCHAR2(3);
    l_asset_return_date DATE;
    l_asset_disposal_date DATE;
    l_api_version CONSTANT NUMBER := G_API_VERSION;
    l_msg_count NUMBER := G_MISS_NUM;
    l_msg_data VARCHAR2(2000);
    l_oks_agent VARCHAR2(200);
    l_okl_agent VARCHAR2(200);
    l_termination_date DATE;
    l_transaction_date VARCHAR2(200);
    l_message_subject VARCHAR2(300);
    l_scrapped_yn VARCHAR2(1) := 'N';

  BEGIN

    --
    -- THE DIFFERENT SOURCES AND CORRESPONDING NOTIFICATION DETAILS
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- SOURCE      NOTIFICATION NAME                                                     TO                 TRANSACTION_ID
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- SUCCESS     Service Contract de-linked from Lease Contract                        OKS Manager        KHR_ID
    -- ERROR       Service Contract could not be de-linked from Lease Contract           OKS + OKL Manager  KHR_ID
    -- TERMINATION Lease Contract terminated but Service Contract has not been de-linked OKS Manager        KHR_ID
    -- RETURN      Serviced asset(s) returned by lessee                                  OKS Manager        ASSET_ID
    -- DISPOSE     Serviced asset(s) sold                                                OKS Manager        ASSET_ID
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- Get/Set the proper date format from contract/fnd profile

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

        -- ********
        -- Get the attribute values which are set
        -- ********

        l_source := WF_ENGINE.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'SOURCE');


        l_transaction_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'TRANSACTION_ID');

        l_quote_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'QUOTE_ID');

        l_transaction_date := WF_ENGINE.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'TRANSACTION_DATE');

        -- RMUNJULU 23-DEC-03 SERVICE K UPDATES
        l_oks_chr_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'OKS_CONTRACT_ID');

        -- *********
        -- Get/Set the OKS AND OKL performing agents :
        -- *********

        -- RMUNJULU 3061751 Set OKC APPROVER AS OKL and OKS managers
        l_oks_agent := FND_PROFILE.value('OKC_K_APPROVER'); -- OKS: Notify Contract Approver

        IF l_oks_agent IS NULL THEN
           l_oks_agent  := 'SYSADMIN';
        END IF;

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'OKS_PERFORMING_AGENT',
                                   avalue   => l_oks_agent);


        l_okl_agent := FND_PROFILE.value('OKC_K_APPROVER'); -- OKL: Notify Contract Approver

        IF l_okl_agent IS NULL THEN
           l_okl_agent  := 'SYSADMIN';
        END IF;

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'OKL_PERFORMING_AGENT',
                                   avalue   => l_okl_agent);

        -- ********
        -- Set the variables
        -- ********

        IF l_source IN ('SUCCESS',
                        'ERROR',
                        'TERMINATION') THEN

           -- Trn ID is LEASE KHR_ID
           l_okl_chr_id := TO_NUMBER(l_transaction_id);

           -- Trn_Date passed is Termination_Date
           l_termination_date := TO_DATE(l_transaction_date,'DD/MM/RRRR');

           IF  l_source = 'SUCCESS' THEN

               -- Success Message Subject
               set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SUCCESS_MSG_SUB');

               l_message_subject := FND_MESSAGE.get;

           ELSIF l_source = 'ERROR' THEN

               -- Error Message Subject
               set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_ERROR_MSG_SUB');

               l_message_subject := FND_MESSAGE.get;

           ELSIF l_source = 'TERMINATION' THEN

               -- Termination Message Subject
               set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_TERM_MSG_SUB');

               l_message_subject := FND_MESSAGE.get;

           END IF;

        ELSIF l_source = 'DISPOSE' THEN

           -- Trn_Id is Asset_Id
           l_asset_id := TO_NUMBER(l_transaction_id);

           -- Trn_Date passed is Disposal_Date
           l_asset_disposal_date := TO_DATE(l_transaction_date,'DD/MM/RRRR');

           -- Get the Asset Details
           OPEN asset_dtls_csr(l_asset_id);
           FETCH asset_dtls_csr INTO l_okl_chr_id;
           CLOSE asset_dtls_csr;

           l_scrapped_yn := check_asset_scrapped(l_asset_id);

           IF l_scrapped_yn = 'Y' THEN

               -- Scrap Message Subject
               set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_SCRAP_MSG_SUB');

               l_message_subject := FND_MESSAGE.get;

           ELSE

               -- Dispose Message Subject
               set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_DISPOSE_MSG_SUB');

               l_message_subject := FND_MESSAGE.get;
           END IF;
        ELSIF l_source = 'RETURN' THEN

           -- Trn_Id is Asset_Id
           l_asset_id := TO_NUMBER(l_transaction_id);

           -- Trn_Date passed is Return_Date
           l_asset_return_date := TO_DATE(l_transaction_date,'DD/MM/RRRR');

           -- Get the Return Details
           OPEN asset_dtls_csr(l_asset_id);
           FETCH asset_dtls_csr INTO l_okl_chr_id;
           CLOSE asset_dtls_csr;

           -- Return Message Subject
           set_message(
                   p_app_name     => G_APP_NAME,
                   p_msg_name     => 'OKL_AM_SRV_RETURN_MSG_SUB');

           l_message_subject := FND_MESSAGE.get;

        END IF;

        -- get okl contract dtls
        OPEN okl_k_dtls_csr(l_okl_chr_id);
        FETCH okl_k_dtls_csr INTO l_okl_contract_number;
        CLOSE okl_k_dtls_csr;

        -- RMUNJULU 23-DEC-03 SERVICE K UPDATES  Added condition
        -- If No OKS Contract ID was set to the WF then get it now
        IF l_oks_chr_id IS NULL
        OR l_oks_chr_id = OKL_API.G_MISS_NUM THEN

           -- Get the linked lease details
           OKL_SERVICE_INTEGRATION_PVT.check_service_link (
                                p_api_version           => l_api_version,
                                p_init_msg_list         => G_FALSE,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                p_lease_contract_id     => l_okl_chr_id ,
                                x_service_contract_id   => l_oks_chr_id);

        END IF;

        -- get oks contract dtls
        OPEN oks_k_dtls_csr(l_oks_chr_id);
        FETCH oks_k_dtls_csr INTO l_oks_contract_number;
        CLOSE oks_k_dtls_csr;

        -- *********
        -- Set Attributes needed
        -- *********

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'OKL_CONTRACT_ID',
                                   avalue   => l_okl_chr_id);

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'OKL_CONTRACT_NUMBER',
                                   avalue   => l_okl_contract_number);

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'OKS_CONTRACT_ID',
                                   avalue   => l_oks_chr_id);

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'OKS_CONTRACT_NUMBER',
                                   avalue   => l_oks_contract_number);

        WF_ENGINE.SetItemAttrDate( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'TERMINATION_DATE',
                                   avalue   => TO_DATE(l_termination_date,'DD/MM/RRRR'));

        WF_ENGINE.SetItemAttrDate( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NOTIFICATION_DATE',
                                   avalue   => TO_DATE(SYSDATE,'DD/MM/RRRR'));

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ASSET_ID',
                                   avalue   => l_asset_id);

        WF_ENGINE.SetItemAttrDate( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RETURN_DATE',
                                   avalue   => TO_DATE(l_asset_return_date,'DD/MM/RRRR'));

        WF_ENGINE.SetItemAttrDate( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DISPOSAL_DATE',
                                   avalue   => TO_DATE(l_asset_disposal_date,'DD/MM/RRRR'));

        WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'MESSAGE_SUBJECT',
                                   avalue   => l_message_subject);

        resultout := 'COMPLETE:Y';
        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

  EXCEPTION

     WHEN OTHERS THEN
        WF_CORE.context('OKL_AM_SERVICE_K_INT_WF' , 'populate_attributes',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END  populate_attributes;

  -- Start of comments
  --
  -- Procedure Name	: pop_dispose_noti_dtls
  -- Desciption     : Populates the Linked Lease Asset Dispose Notification details
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE pop_dispose_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2) IS

     l_item_type              WF_ITEMS.item_type%TYPE;
     l_item_key               WF_ITEMS.item_key%TYPE;
     l_colon                  NUMBER;
     l_msgbody                VARCHAR2(32000);
     l_okl_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_oks_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_asset_schedule_tbl     kle_tbl_type;
     l_noti_rec               noti_rec_type;
     i                        NUMBER := 1;

     l_dispose_date           DATE;
     l_dispose_asset_id       NUMBER;

     l_scrapped_yn            VARCHAR2(1) := 'N';
     l_msg_body               FND_NEW_MESSAGES.message_text%TYPE;

    l_dispose_date_text VARCHAR2(60); -- added for bug 7538658

    l_user_id NUMBER; -- added for bug 7538658

     -- added for bug 7538658
     CURSOR get_user_id_csr IS
     SELECT user_id
     FROM   FND_USER
     WHERE  User_Name = FND_GLOBAL.user_name;

	 disptype VARCHAR2(30); -- Bug 8974552

  BEGIN

     -- ********
     -- Get the Item_Type and Item_Key
     -- ********

     l_colon      := INSTR(document_id, ':');
     l_item_type  := SUBSTR(document_id, 1, l_colon - 1);
     l_item_key   := SUBSTR(document_id, l_colon + 1, LENGTH(document_id) - l_colon);

     -- ********
     -- Get the Attribute values
     -- ********

     l_okl_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_NUMBER');

     l_oks_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKS_CONTRACT_NUMBER');

     l_dispose_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'DISPOSAL_DATE');

     l_dispose_asset_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'ASSET_ID');

     -- ********
     -- Get Assets Details
     -- ********

     get_assets_schedule (
                   p_kle_id               => l_dispose_asset_id,
                   x_asset_schedule_tbl   => l_asset_schedule_tbl);



     -- ********
     -- Get Notification Body texts
     -- ********

     get_set_noti_dtls (
                     p_itemtype	=> l_item_type,
                     p_itemkey  => l_item_key,
                     x_noti_rec => l_noti_rec);

     -- ********
     -- Check if SCRAPPED
     -- ********

     l_scrapped_yn := check_asset_scrapped(l_dispose_asset_id);

     IF  l_scrapped_yn = 'Y' THEN

         l_msg_body := l_noti_rec.scrap_main_body;

     ELSE

         l_msg_body := l_noti_rec.dispose_main_body;

     END IF;


-- added for Bug 7538658 start
            IF (FND_RELEASE.MAJOR_VERSION = 12 AND FND_RELEASE.minor_version >= 1 AND FND_RELEASE.POINT_VERSION >= 1 )
                 OR (FND_RELEASE.MAJOR_VERSION > 12) THEN

              OPEN get_user_id_csr;
              FETCH get_user_id_csr INTO l_user_id;
              CLOSE get_user_id_csr;

              IF l_user_id IS NULL THEN
                 l_user_id := to_number(null);
              END IF;

              if (disptype=wf_notification.doc_html) then -- bug 8974552
                -- For html notification in Hijrah calendar, the MMM date format would be displayed correctly only when <BDO> tag is used.
                -- Use NVL for NLS_CALENDAR
                l_dispose_date_text := '<BDO DIR="LTR">' ||
                                 to_char(l_dispose_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''')
                                 || '</BDO>';

              else
                -- Use NVL for NLS_CALENDAR
                l_dispose_date_text := to_char(l_dispose_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''');

              end if;

            ELSE

              l_dispose_date_text := to_char(l_dispose_date);

            END IF;
-- added for Bug 7538658 End

     -- ********
     -- Set the message body
     -- ********

     l_msgbody :=
     '<html>
        <style> .tableHeaderCell { font-family: Arial; font-size: 10pt; font-weight: bold;}
                .tableDataCell { font-family: Arial; font-size: 9pt;  }
        </style>
        <body>
          <p></p>
          <p class="tableDataCell"> ' || l_msg_body || ' </p>
          <p class="tableHeaderCell"> ' || l_noti_rec.contract_dtls || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.lease_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.service_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.asset_disp_date || ' </td>
            </tr>
            <tr>
            <td class="tableDataCell"> ' || l_okl_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_oks_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_dispose_date_text || ' </td>
            </tr>
          </table>
          <p class="tableHeaderCell"> ' || l_noti_rec.schedule_assets || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.asset_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item_description || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.reference_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.serial_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.quantity || ' </td>
            </tr>';
            IF l_asset_schedule_tbl.COUNT > 0 THEN
               FOR i IN l_asset_schedule_tbl.FIRST..l_asset_schedule_tbl.LAST LOOP

               l_msgbody := l_msgbody ||
               '<tr>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_description||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).install_base_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).serial_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_quantity||'</td>
               </tr>';
               END LOOP;
            END IF;

          l_msgbody := l_msgbody ||
          '</table>
          <p class="tableDataCell"> ' || l_noti_rec.body_end || ' </p>
          </body>
          </html>';

     -- ********
     -- Set OUT variables
     -- ********

     document := l_msgbody;
     document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
       NULL;

  END  pop_dispose_noti_dtls;

  -- Start of comments
  --
  -- Procedure Name	: pop_return_noti_dtls
  -- Desciption     : Populates the Linked Lease Asset Return Notification details
  --                  When Source is 'RETURN'
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE pop_return_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2) IS

     l_item_type              WF_ITEMS.item_type%TYPE;
     l_item_key               WF_ITEMS.item_key%TYPE;
     l_colon                  NUMBER;
     l_msgbody                VARCHAR2(32000);
     l_okl_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_oks_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_asset_schedule_tbl     kle_tbl_type;
     l_noti_rec               noti_rec_type;
     i                        NUMBER := 1;

     l_return_date            DATE;
     l_return_asset_id        NUMBER;

     l_return_date_text VARCHAR2(60); -- added for bug 7538658

     l_user_id NUMBER; -- added for bug 7538658

     -- added for bug 7538658
     CURSOR get_user_id_csr IS
     SELECT user_id
     FROM   FND_USER
     WHERE  User_Name = FND_GLOBAL.user_name;

	 disptype VARCHAR2(30); -- Bug 8974552

  BEGIN

     -- ********
     -- Get the Item_Type and Item_Key
     -- ********

     l_colon      := INSTR(document_id, ':');
     l_item_type  := SUBSTR(document_id, 1, l_colon - 1);
     l_item_key   := SUBSTR(document_id, l_colon + 1, LENGTH(document_id) - l_colon);

     -- ********
     -- Get the Attribute values
     -- ********

     l_okl_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_NUMBER');

     l_oks_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKS_CONTRACT_NUMBER');

     l_return_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'RETURN_DATE');

     l_return_asset_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'ASSET_ID');

     -- ********
     -- Get Assets Details
     -- ********

     get_assets_schedule (
                   p_kle_id               => l_return_asset_id,
                   x_asset_schedule_tbl   => l_asset_schedule_tbl);

     -- ********
     -- Get Notification Body texts
     -- ********

     get_set_noti_dtls (
                     p_itemtype	=> l_item_type,
                     p_itemkey  => l_item_key,
                     x_noti_rec => l_noti_rec);


-- added for Bug 7538658 start
            IF (FND_RELEASE.MAJOR_VERSION = 12 AND FND_RELEASE.minor_version >= 1 AND FND_RELEASE.POINT_VERSION >= 1 )
                 OR (FND_RELEASE.MAJOR_VERSION > 12) THEN

              OPEN get_user_id_csr ;
              FETCH get_user_id_csr  INTO l_user_id;
              CLOSE get_user_id_csr ;

              IF l_user_id IS NULL THEN
                 l_user_id := to_number(null);
              END IF;


              if (disptype=wf_notification.doc_html) then -- bug 8974552
                -- For html notification in Hijrah calendar, the MMM date format would be displayed correctly only when <BDO> tag is used.
                -- Use NVL for NLS_CALENDAR
                l_return_date_text := '<BDO DIR="LTR">' ||
                                 to_char(l_return_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''')
                                 || '</BDO>';

              else
                -- Use NVL for NLS_CALENDAR
                l_return_date_text := to_char(l_return_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''');

              end if;

            ELSE

              l_return_date_text := to_char(l_return_date);

            END IF;
-- added for Bug 7538658 End

     -- ********
     -- Set the message body
     -- ********

     l_msgbody :=
     '<html>
        <style> .tableHeaderCell { font-family: Arial; font-size: 10pt; font-weight: bold;}
                .tableDataCell { font-family: Arial; font-size: 9pt;  }
        </style>
        <body>
          <p></p>
          <p class="tableDataCell"> ' || l_noti_rec.return_main_body || ' </p>
          <p class="tableHeaderCell"> ' || l_noti_rec.contract_dtls || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.lease_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.service_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.asset_ret_date || ' </td>
            </tr>
            <tr>
            <td class="tableDataCell"> ' || l_okl_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_oks_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_return_date_text || ' </td>
            </tr>
          </table>
          <p class="tableHeaderCell"> ' || l_noti_rec.schedule_assets || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.asset_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item_description || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.reference_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.serial_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.quantity || ' </td>
            </tr>';
            IF l_asset_schedule_tbl.COUNT > 0 THEN
               FOR i IN l_asset_schedule_tbl.FIRST..l_asset_schedule_tbl.LAST LOOP

               l_msgbody := l_msgbody ||
               '<tr>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_description||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).install_base_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).serial_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_quantity||'</td>
               </tr>';
               END LOOP;
            END IF;

          l_msgbody := l_msgbody ||
          '</table>
          <p class="tableDataCell"> ' || l_noti_rec.body_end || ' </p>
          </body>
          </html>';

     -- ********
     -- Set OUT variables
     -- ********

     document := l_msgbody;
     document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
       NULL;

  END  pop_return_noti_dtls;

  -- Start of comments
  --
  -- Procedure Name	: pop_delink_err_noti_dtls
  -- Desciption     : Populates the Linked Lease De-link Error and Termination Notification details
  --                  When Source is 'ERROR'
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE pop_delink_err_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2) IS

     l_item_type              WF_ITEMS.item_type%TYPE;
     l_item_key               WF_ITEMS.item_key%TYPE;
     l_colon                  NUMBER;
     l_msgbody                VARCHAR2(32000);
     l_okl_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_oks_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_quote_id               VARCHAR2(200);
     l_asset_schedule_tbl     kle_tbl_type;
     l_noti_rec               noti_rec_type;
     i                        NUMBER := 1;

     l_termination_date       DATE;
     l_okl_chr_id             NUMBER;


     l_termination_date_text VARCHAR2(60); -- added for bug 7538658
     l_user_id NUMBER; -- added for bug 7538658

     -- added for bug 7538658
     CURSOR get_user_id_csr IS
     SELECT user_id
     FROM   FND_USER
     WHERE  User_Name = FND_GLOBAL.user_name;

	 disptype VARCHAR2(30); -- Bug 8974552

  BEGIN

     -- LIMITATIONS:
     -- For now Partial quotes are not allowed if linked service contract exists.
     -- So its always full termination. So get all linked assets
     -- for the lease contract, no need to check if all exists in quote,
     -- since all will exist.


     -- ********
     -- Get the Item_Type and Item_Key
     -- ********

     l_colon      := INSTR(document_id, ':');
     l_item_type  := SUBSTR(document_id, 1, l_colon - 1);
     l_item_key   := SUBSTR(document_id, l_colon + 1, LENGTH(document_id) - l_colon);

     -- ********
     -- Get the Attribute values
     -- ********

     l_okl_chr_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_ID');

     l_okl_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_NUMBER');

     l_oks_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKS_CONTRACT_NUMBER');

     l_termination_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'TERMINATION_DATE');

     l_quote_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'QUOTE_ID');

     -- ********
     -- Get Assets Details
     -- ********

     get_assets_schedule (
                   p_khr_id               => l_okl_chr_id,
                   p_quote_id             => TO_NUMBER(l_quote_id),
                   x_asset_schedule_tbl   => l_asset_schedule_tbl);

     -- ********
     -- Get Notification Body texts
     -- ********

     get_set_noti_dtls (
                     p_itemtype	=> l_item_type,
                     p_itemkey  => l_item_key,
                     x_noti_rec => l_noti_rec);

-- added for Bug 7538658 start
            IF (FND_RELEASE.MAJOR_VERSION = 12 AND FND_RELEASE.minor_version >= 1 AND FND_RELEASE.POINT_VERSION >= 1 )
                 OR (FND_RELEASE.MAJOR_VERSION > 12) THEN

              OPEN get_user_id_csr;
              FETCH get_user_id_csr INTO l_user_id;
              CLOSE get_user_id_csr;

              IF l_user_id IS NULL THEN
                 l_user_id := to_number(null);
              END IF;

              if (disptype=wf_notification.doc_html) then -- bug 8974552
                -- For html notification in Hijrah calendar, the MMM date format would be displayed correctly only when <BDO> tag is used.
                -- Use NVL for NLS_CALENDAR
                l_termination_date_text := '<BDO DIR="LTR">' ||
                                 to_char(l_termination_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''')
                                 || '</BDO>';

              else
                -- Use NVL for NLS_CALENDAR
                l_termination_date_text := to_char(l_termination_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''');

              end if;

            ELSE

              l_termination_date_text := to_char(l_termination_date);

            END IF;
-- added for Bug 7538658 End

     -- ********
     -- Set the message body
     -- ********

     l_msgbody :=
     '<html>
        <style> .tableHeaderCell { font-family: Arial; font-size: 10pt; font-weight: bold;}
                .tableDataCell { font-family: Arial; font-size: 9pt;  }
        </style>
        <body>
          <p></p>
          <p class="tableDataCell"> ' || l_noti_rec.error_main_body || ' </p>
          <p class="tableHeaderCell"> ' || l_noti_rec.contract_dtls || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.lease_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.service_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.termination_date || ' </td>
            </tr>
            <tr>
            <td class="tableDataCell"> ' || l_okl_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_oks_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_termination_date_text || ' </td>
            </tr>
          </table>
          <p class="tableHeaderCell"> ' || l_noti_rec.schedule_assets || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.asset_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item_description || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.reference_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.serial_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.quantity || ' </td>
            </tr>';
            IF l_asset_schedule_tbl.COUNT > 0 THEN
               FOR i IN l_asset_schedule_tbl.FIRST..l_asset_schedule_tbl.LAST LOOP

               l_msgbody := l_msgbody ||
               '<tr>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_description||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).install_base_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).serial_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_quantity||'</td>
               </tr>';
               END LOOP;
            END IF;

          l_msgbody := l_msgbody ||
          '</table>
          <p class="tableDataCell"> ' || l_noti_rec.body_end || ' </p>
          </body>
          </html>';

     -- ********
     -- Set OUT variables
     -- ********

     document := l_msgbody;
     document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
       NULL;

  END  pop_delink_err_noti_dtls;

  -- Start of comments
  --
  -- Procedure Name	: pop_delink_noti_dtls
  -- Desciption     : Populates the Linked Lease De-link and Termination Notification details
  --                  When Source is 'SUCCESS'
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --                : RMUNJULU 23-DEC-03 SERVICE K UPDATES
  --
  -- End of comments
  PROCEDURE pop_delink_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2) IS

     l_item_type              WF_ITEMS.item_type%TYPE;
     l_item_key               WF_ITEMS.item_key%TYPE;
     l_colon                  NUMBER;
     l_msgbody                VARCHAR2(32000);
     l_okl_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_oks_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_quote_id               VARCHAR2(200);
     l_asset_schedule_tbl     kle_tbl_type;
     l_noti_rec               noti_rec_type;
     i                        NUMBER := 1;

     l_termination_date       DATE;
     l_okl_chr_id             NUMBER;

     l_termination_date_text VARCHAR2(60); -- added for bug 7538658

     l_user_id NUMBER; -- added for bug 7538658

     -- added for bug 7538658
     CURSOR get_user_id_csr IS
     SELECT user_id
     FROM   FND_USER
     WHERE  User_Name = FND_GLOBAL.user_name;

	 disptype VARCHAR2(30); -- Bug 8974552


  BEGIN

     -- LIMITATIONS:
     -- For now Partial quotes are not allowed if linked service contract exists.
     -- So its always full termination. So get all linked assets
     -- for the lease contract, no need to check if all exists in quote,
     -- since all will exist.

     -- ********
     -- Get the Item_Type and Item_Key
     -- ********

     l_colon      := INSTR(document_id, ':');
     l_item_type  := SUBSTR(document_id, 1, l_colon - 1);
     l_item_key   := SUBSTR(document_id, l_colon + 1, LENGTH(document_id) - l_colon);

     -- ********
     -- Get the Attribute values
     -- ********

     l_okl_chr_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_ID');

     l_okl_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_NUMBER');

     l_oks_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKS_CONTRACT_NUMBER');

     l_termination_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'TERMINATION_DATE');

     l_quote_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'QUOTE_ID');

     -- ********
     -- Get Assets Details
     -- ********

     get_assets_schedule (
                   p_khr_id               => l_okl_chr_id,
                   p_quote_id             => TO_NUMBER(l_quote_id),
                   x_asset_schedule_tbl   => l_asset_schedule_tbl);

     -- ********
     -- Get Notification Body texts
     -- ********

     get_set_noti_dtls (
                     p_itemtype	=> l_item_type,
                     p_itemkey  => l_item_key,
                     x_noti_rec => l_noti_rec);


-- added for Bug 7538658 start
            IF (FND_RELEASE.MAJOR_VERSION = 12 AND FND_RELEASE.minor_version >= 1 AND FND_RELEASE.POINT_VERSION >= 1 )
                 OR (FND_RELEASE.MAJOR_VERSION > 12) THEN

              OPEN get_user_id_csr;
              FETCH get_user_id_csr INTO l_user_id;
              CLOSE get_user_id_csr;

              IF l_user_id IS NULL THEN
                 l_user_id := to_number(null);
              END IF;

              if (disptype=wf_notification.doc_html) then -- bug 8974552
                -- For html notification in Hijrah calendar, the MMM date format would be displayed correctly only when <BDO> tag is used.
                -- Use NVL for NLS_CALENDAR
                l_termination_date_text := '<BDO DIR="LTR">' ||
                                 to_char(l_termination_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''')
                                 || '</BDO>';

              else
                -- Use NVL for NLS_CALENDAR
                l_termination_date_text := to_char(l_termination_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''');

              end if;

            ELSE

              l_termination_date_text := to_char(l_termination_date);

            END IF;
-- added for Bug 7538658 End

     -- ********
     -- Set the message body
     -- ********
     -- RMUNJULU 23-DEC-03 SERVICE K UPDATES
     -- Changed the message body removed the asset details
     l_msgbody :=
     '<html>
        <style> .tableHeaderCell { font-family: Arial; font-size: 10pt; font-weight: bold;}
                .tableDataCell { font-family: Arial; font-size: 9pt;  }
        </style>
        <body>
          <p></p>
          <p class="tableDataCell"> ' || l_noti_rec.success_main_body || ' </p>
          <p class="tableHeaderCell"> ' || l_noti_rec.contract_dtls || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.lease_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.service_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.termination_date || ' </td>
            </tr>

            <tr>
            <td class="tableDataCell"> ' || l_okl_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_oks_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_termination_date_text || ' </td>
            </tr>
          </table>
          <p class="tableDataCell"> ' || l_noti_rec.body_end || ' </p>
          </body>
          </html>';

     -- ********
     -- Set OUT variables
     -- ********

     document := l_msgbody;
     document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
       NULL;

  END  pop_delink_noti_dtls;

  -- Start of comments
  --
  -- Procedure Name	: pop_term_noti_dtls
  -- Desciption     : Populates the Linked Lease Termination Notification details
  --                  When Source is 'TERMINATION'
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE pop_term_noti_dtls(
                     document_id    IN VARCHAR2,
                     display_type   IN VARCHAR2,
                     document       IN OUT NOCOPY VARCHAR2,
                     document_type  IN OUT NOCOPY VARCHAR2) IS

     l_item_type              WF_ITEMS.item_type%TYPE;
     l_item_key               WF_ITEMS.item_key%TYPE;
     l_colon                  NUMBER;
     l_msgbody                VARCHAR2(32000);
     l_okl_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_oks_contract_number    OKC_K_HEADERS_B.contract_number%TYPE;
     l_quote_id               VARCHAR2(200);
     l_asset_schedule_tbl     kle_tbl_type;
     l_noti_rec               noti_rec_type;
     i                        NUMBER := 1;

     l_termination_date       DATE;
     l_okl_chr_id             NUMBER;

     l_termination_date_text VARCHAR2(60); -- added for bug 7538658
     l_user_id NUMBER; -- added for bug 7538658

     -- added for bug 7538658
     CURSOR get_user_id_csr IS
     SELECT user_id
     FROM   FND_USER
     WHERE  User_Name = FND_GLOBAL.user_name;

	 disptype VARCHAR2(30); -- Bug 8974552

  BEGIN

     -- LIMITATIONS:
     -- For now Partial quotes are not allowed if linked service contract exists.
     -- So its always full termination. So get all linked assets
     -- for the lease contract, no need to check if all exists in quote,
     -- since all will exist.

     -- ********
     -- Get the Item_Type and Item_Key
     -- ********

     l_colon      := INSTR(document_id, ':');
     l_item_type  := SUBSTR(document_id, 1, l_colon - 1);
     l_item_key   := SUBSTR(document_id, l_colon + 1, LENGTH(document_id) - l_colon);

     -- ********
     -- Get the Attribute values
     -- ********

     l_okl_chr_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_ID');

     l_okl_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKL_CONTRACT_NUMBER');

     l_oks_contract_number := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'OKS_CONTRACT_NUMBER');

     l_termination_date := WF_ENGINE.GetItemAttrDate(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'TERMINATION_DATE');

     l_quote_id := WF_ENGINE.GetItemAttrText(
                                     itemtype => l_item_type,
                                     itemkey  => l_item_key,
                                     aname    => 'QUOTE_ID');

     -- ********
     -- Get Assets Details
     -- ********

     get_assets_schedule (
                   p_khr_id               => l_okl_chr_id,
                   p_quote_id             => TO_NUMBER(l_quote_id),
                   x_asset_schedule_tbl   => l_asset_schedule_tbl);

     -- ********
     -- Get Notification Body texts
     -- ********

     get_set_noti_dtls (
                     p_itemtype	=> l_item_type,
                     p_itemkey  => l_item_key,
                     x_noti_rec => l_noti_rec);


-- added for Bug 7538658 start
            IF (FND_RELEASE.MAJOR_VERSION = 12 AND FND_RELEASE.minor_version >= 1 AND FND_RELEASE.POINT_VERSION >= 1 )
                 OR (FND_RELEASE.MAJOR_VERSION > 12) THEN

              OPEN get_user_id_csr;
              FETCH get_user_id_csr INTO l_user_id;
              CLOSE get_user_id_csr;

              IF l_user_id IS NULL THEN
                 l_user_id := to_number(null);
              END IF;

              if (disptype=wf_notification.doc_html) then -- bug 8974552
                -- For html notification in Hijrah calendar, the MMM date format would be displayed correctly only when <BDO> tag is used.
                -- Use NVL for NLS_CALENDAR
                l_termination_date_text := '<BDO DIR="LTR">' ||
                                 to_char(l_termination_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''')
                                 || '</BDO>';

              else
                -- Use NVL for NLS_CALENDAR
                l_termination_date_text := to_char(l_termination_date,
                                 FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),
                                 'NLS_CALENDAR = ''' || NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id), 'GREGORIAN') || '''');

              end if;

            ELSE

              l_termination_date_text := to_char(l_termination_date);

            END IF;
-- added for Bug 7538658 End

     -- ********
     -- Set the message body
     -- ********

     l_msgbody :=
     '<html>
        <style> .tableHeaderCell { font-family: Arial; font-size: 10pt; font-weight: bold;}
                .tableDataCell { font-family: Arial; font-size: 9pt;  }
        </style>
        <body>
          <p></p>
          <p class="tableDataCell"> ' || l_noti_rec.termination_main_body || ' </p>
          <p class="tableHeaderCell"> ' || l_noti_rec.contract_dtls || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.lease_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.service_contract || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.termination_date || ' </td>
            </tr>
            <tr>
            <td class="tableDataCell"> ' || l_okl_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_oks_contract_number || ' </td>
            <td class="tableDataCell"> ' || l_termination_date_text || ' </td>
            </tr>
          </table>
          <p class="tableHeaderCell"> ' || l_noti_rec.schedule_assets || ' </p>
          <table border="1">
            <tr>
            <td class="tableHeaderCell"> ' || l_noti_rec.asset_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.item_description || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.reference_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.serial_num || ' </td>
            <td class="tableHeaderCell"> ' || l_noti_rec.quantity || ' </td>
            </tr>';
            IF l_asset_schedule_tbl.COUNT > 0 THEN
               FOR i IN l_asset_schedule_tbl.FIRST..l_asset_schedule_tbl.LAST LOOP

               l_msgbody := l_msgbody ||
               '<tr>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).item_description||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).install_base_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).serial_number||'</td>
               <td class="tableDataCell">'||l_asset_schedule_tbl(i).asset_quantity||'</td>
               </tr>';
               END LOOP;
            END IF;

          l_msgbody := l_msgbody ||
          '</table>
          <p class="tableDataCell"> ' || l_noti_rec.body_end || ' </p>
          </body>
          </html>';

     -- ********
     -- Set OUT variables
     -- ********

     document := l_msgbody;
     document_type := display_type;

  EXCEPTION
     WHEN OTHERS THEN
       NULL;

  END  pop_term_noti_dtls;

  -- Start of comments
  --
  -- Procedure Name	: check_source
  -- Desciption     : Checks the source of the WF call, this will decide which
  --                  path to take, which will send a noti
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE check_source(
                     itemtype	IN  VARCHAR2,
                     itemkey  	IN  VARCHAR2,
                     actid		IN  NUMBER,
                     funcmode	IN  VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2) IS


    l_source   VARCHAR2(100);


  BEGIN

    --
    -- RUN mode
    --
    IF (funcmode = 'RUN') THEN

        -- ********
        -- Get the values
        -- ********

        l_source := WF_ENGINE.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'SOURCE');

        -- ********
        -- Set the Notification Body and Output of this function based on source
        -- ********

        IF    l_source = 'SUCCESS' THEN -- From termination, de-link was successful

             WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MESSAGE_DOC',
                                  avalue   =>
                       'PLSQL:OKL_AM_SERVICE_K_INT_WF.pop_delink_noti_dtls /'||itemtype||':'||itemkey);

             resultout := 'COMPLETE:SOURCE_SUCCESS';

        ELSIF l_source = 'ERROR' THEN -- From termination, de-link failed

             WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MESSAGE_DOC',
                                  avalue   =>
                       'PLSQL:OKL_AM_SERVICE_K_INT_WF.pop_delink_err_noti_dtls /'||itemtype||':'||itemkey);

             resultout := 'COMPLETE:SOURCE_ERROR';

        ELSIF l_source = 'TERMINATION' THEN -- From termination, de-link not needed

             WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MESSAGE_DOC',
                                  avalue   =>
                       'PLSQL:OKL_AM_SERVICE_K_INT_WF.pop_term_noti_dtls /'||itemtype||':'||itemkey);

             resultout := 'COMPLETE:SOURCE_TERMINATION';

        ELSIF l_source = 'DISPOSE' THEN -- From Asset Dispose

             WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MESSAGE_DOC',
                                  avalue   =>
                       'PLSQL:OKL_AM_SERVICE_K_INT_WF.pop_dispose_noti_dtls /'||itemtype||':'||itemkey);

             resultout := 'COMPLETE:SOURCE_DISPOSE';

        ELSIF l_source = 'RETURN' THEN -- From Asset Return

             WF_ENGINE.SetItemAttrText(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MESSAGE_DOC',
                                  avalue   =>
                       'PLSQL:OKL_AM_SERVICE_K_INT_WF.pop_return_noti_dtls /'||itemtype||':'||itemkey);

             resultout := 'COMPLETE:SOURCE_RETURN';

        END IF;

      RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN

      resultout := 'COMPLETE:';
      RETURN;

    END IF;


  EXCEPTION

     WHEN OTHERS THEN
        WF_CORE.context('OKL_AM_SERVICE_K_INT_WF' , 'check_source',
                        itemtype, itemkey, actid, funcmode);
        RAISE;

  END  check_source;


END OKL_AM_SERVICE_K_INT_WF;

/
