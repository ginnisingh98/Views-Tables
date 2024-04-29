--------------------------------------------------------
--  DDL for Package Body OKL_MAINTAIN_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MAINTAIN_CONTRACT_PVT" AS
/* $Header: OKLRKHRB.pls 120.6.12010000.3 2009/06/02 10:42:22 racheruv ship $ */

--------------------------------------------------------------------------------
--GLOBAL Message constants added for okl contract cancellation checks
--------------------------------------------------------------------------------
  G_CANC_CNTR_INV_STATUS         CONSTANT VARCHAR2(200) := 'OKL_LLA_CANC_CNTR_INV_STATUS';
  G_CONTRACT_NUMBER_TOKEN        CONSTANT VARCHAR2(200) := 'CONTRACT_NUMBER';
  G_STATUS_CODE_TOKEN            CONSTANT VARCHAR2(200) := 'STATUS';
  G_CANC_CNTR_PYMT_EXIST         CONSTANT VARCHAR2(200) := 'OKL_LLA_CANC_CNTR_PYMT_EXIST';
  G_TXN_TYPE                     CONSTANT VARCHAR2(200) := 'TXN_TYPE';
  G_CANC_CNTR_RCPT_EXIST         CONSTANT VARCHAR2(200) := 'OKL_LLA_CANC_CNTR_RCPT_EXIST';

   subtype tapv_rec_type is okl_tap_pvt.tapv_rec_type;

--Bug# 7030390
--------------------------------------------------------------------------------
--start of comments
-- Description    : This api takes the contract id as input and rename all
--                  the assets of the contract with CANCEL_XX so that the
--                  original asset number can be reused.
-- IN Parameters  : p_contract_id - contract id
--End of comments
--------------------------------------------------------------------------------
Procedure cancel_assets
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_contract_id          IN  NUMBER
                   )    IS


    G_TOP_LINE_STYLE               CONSTANT VARCHAR2(30) := 'TLS';
    l_api_name      CONSTANT VARCHAR2(30) := 'CANCEL_ASSETS';

    --get the top line
    CURSOR c_get_k_top_line(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id top_line
    FROM okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.cle_id IS NULL
    AND cle.chr_id = cle.dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lse_parent_id IS NULL
    AND lse.lse_type = G_TOP_LINE_STYLE
    and lse.lty_code = 'FREE_FORM1';

    --cursor for asset_number
    CURSOR asset_num_csr (p_fin_ast_id IN NUMBER) IS
    SELECT name
    FROM   okc_k_lines_tl
    WHERE  id = p_fin_ast_id;

  --cursor to get new asset number
    Cursor c_asset_no IS
    select 'CANCEL_'||TO_CHAR(OKL_FAN_SEQ.NEXTVAL)
    FROM dual;

  --Cursors to find if asset number exists
    CURSOR c_chk_asset_number(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_V
                  WHERE asset_number = p_asset_number)
    OR EXISTS (SELECT '1'
                  FROM OKL_TXD_ASSETS_V
                  WHERE asset_number = p_asset_number)
    OR EXISTS (SELECT '1'
                  FROM OKX_ASSETS_V
                  WHERE asset_number = p_asset_number);

    CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (select '1'
                  from   okc_k_lines_v kle,
                         okc_line_styles_b  lse
                  where  kle.name = p_asset_number
                  and    kle.lse_id = lse.id
                  and    lse.lty_code = 'FREE_FORM1');

    l_asset_number OKC_K_LINES_TL.NAME%TYPE;
    l_asset_new_number OKC_K_LINES_TL.NAME%TYPE;
    l_asset_exists Varchar2(1) default 'N';
    l_cle_id Number;

    l_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lx_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_clev_rec_temp  OKL_OKC_MIGRATION_PVT.clev_rec_type;
    lx_clev_rec_temp  OKL_OKC_MIGRATION_PVT.clev_rec_type;

    --Cursor to check asset number on txl
    CURSOR l_txlv_csr (p_finasst_id IN NUMBER, p_asstno IN VARCHAR2) is
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

    l_tlpv_temp_rec        OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    lx_tlpv_temp_rec       OKL_TXL_ASSETS_PUB.tlpv_rec_type;

    l_adpv_rec             OKL_TXD_ASSETS_PUB.adpv_rec_type;
    lx_adpv_rec            OKL_TXD_ASSETS_PUB.adpv_rec_type;

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

   FOR r_get_k_top_line IN c_get_k_top_line(p_dnz_chr_id => p_contract_id) LOOP
       --initialize variables
        l_asset_number := NULL;
        l_asset_new_number := null;
        l_asset_exists := 'N';

        l_cle_id :=r_get_k_top_line.top_line;

        --dbms_output.put_line('processing l_cle_id '||l_cle_id);

        OPEN asset_num_csr(p_fin_ast_id => l_cle_id);
        FETCH asset_num_csr INTO l_asset_number;
        IF asset_num_csr%NOTFOUND THEN
            NULL;
        END IF;
        CLOSE asset_num_csr;

       -- dbms_output.put_line('l_asset_number '||l_asset_number);

        OPEN c_asset_no;
          Loop
            Fetch c_asset_no into l_asset_new_number;
            --chk if asset already exists
            l_asset_exists := 'N';
            open c_chk_asset_number(l_asset_new_number);
            Fetch c_chk_asset_number into l_asset_exists;
            If c_chk_asset_number%NOTFOUND Then
                open  c_okx_asset_lines_v(l_asset_new_number);
                Fetch c_okx_asset_lines_v into l_asset_exists;
                Close c_okx_asset_lines_v;
             End If;
             Close c_chk_asset_number;
             If l_asset_exists = 'N' Then
                 Exit;
             End If;
         End Loop;
        close c_asset_no;
       --dbms_output.put_line('l_asset_new_number '||l_asset_new_number);

        --update asset number on top line
         l_clev_rec :=l_clev_rec_temp;
         lx_clev_rec:=lx_clev_rec_temp;
         l_clev_rec.id   := l_cle_id;
         l_clev_rec.name := l_asset_new_number;
         okl_okc_migration_pvt.update_contract_line(
             p_api_version       => p_api_version,
             p_init_msg_list     => p_init_msg_list,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_restricted_update => OKC_API.G_FALSE,
             p_clev_rec          => l_clev_rec,
             x_clev_rec          => lx_clev_rec);

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

        l_txl_id:=null;
        l_txl_asset_number:=null;
        l_tlpv_rec :=l_tlpv_temp_rec;
        lx_tlpv_rec :=lx_tlpv_temp_rec;

        --update asset number on txl
        OPEN l_txlv_csr(l_cle_id, l_asset_number);
        Loop
            Fetch l_txlv_csr into l_txl_id, l_txl_asset_number;
            Exit When l_txlv_csr%NOTFOUND;
            IF l_txl_asset_number is not null then
                 l_tlpv_rec :=l_tlpv_temp_rec;
                 lx_tlpv_rec :=lx_tlpv_temp_rec;
                 l_tlpv_rec.id := l_txl_id;
                 l_tlpv_rec.asset_number := l_asset_new_number; --15 character
                  okl_txl_assets_pub.update_txl_asset_Def(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_tlpv_rec      => l_tlpv_rec,
                                         x_tlpv_rec      => lx_tlpv_rec);
                 --dbms_output.put_line('after updating txl assets for asset number'||x_return_status);
                 IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_ERROR;
                 END IF;

             End IF;
        End Loop;
        CLOSE l_txlv_csr;

        l_txd_id:=NULL;
        l_txd_asset_number:=NULL;
        --update asset number on txd
        OPEN l_txdv_csr(l_cle_id,l_asset_number);
        LOOP
           l_txd_id:=NULL;
           l_txd_asset_number:=NULL;
           Fetch l_txdv_csr into l_txd_id, l_txd_asset_number;
           Exit When l_txdv_csr%NOTFOUND;
            IF l_txd_asset_number is not null then
                 l_adpv_rec.id := l_txd_id;
                 l_adpv_rec.asset_number := l_asset_new_number;
                 okl_txd_assets_pub.update_txd_asset_Def(
                                         p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_adpv_rec      => l_adpv_rec,
                                         x_adpv_rec      => lx_adpv_rec);
               -- dbms_output.put_line('After Updating TXD-->update_txd_asset_Def'||x_return_status);

                IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okl_Api.G_EXCEPTION_ERROR;
                 END IF;

             End IF;
        End Loop;
        CLOSE l_txdv_csr;
    END LOOP;

    OKL_API.END_ACTIVITY (x_msg_count, x_msg_data );
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
END cancel_assets;
--Bug# 7030390 End

--------------------------------------------------------------------------------
--start of comments
-- Description    : This api takes the contract id as input and
--                  returns the Validation status
-- IN Parameters  : p_contract_id - contract id
--End of comments
--------------------------------------------------------------------------------
Procedure Validate_Cancel_Contract
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_contract_id          IN  NUMBER) is

CURSOR contract_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
SELECT contract_number
FROM   okc_k_headers_v
WHERE  id = p_chr_id;

Cursor bankrupt_csr(p_contract_id NUMBER) IS
    SELECT DECODE(disposition_code, 'NEGOTIATION', 'Y', 'GRANTED', 'Y', NULL, 'Y', 'N') bankruptcy_status
    FROM iex_bankruptcies ban
    WHERE EXISTS (SELECT 1 FROM okc_k_party_roles_b rle
                  WHERE rle.dnz_chr_id = p_contract_id
                  AND rle.rle_code = 'LESSEE'
                  AND TO_NUMBER(rle.object1_id1) = ban.party_id);

Cursor contract_status_csr(p_contract_id NUMBER) IS
    SELECT sts_code
    FROM   okc_k_headers_b chrb
    WHERE  chrb.id = p_contract_id
    AND    chrb.scs_code  = 'LEASE'
    AND    chrb.sts_code in ('BOOKED', 'EVERGREEN', 'EXPIRED', 'TERMINATED', 'REVERSED', 'ABANDONED');

Cursor funding_disb_txn_csr(p_contract_id NUMBER) IS
    SELECT funding_type_code
    FROM   okl_trx_ap_invoices_b
    WHERE  khr_id = p_contract_id
--    AND    ((funding_type_code = 'MANUAL_DISB') OR
-- Added for bug #5944260/5981076(Forward R12 cklee)
    AND  (trx_status_code in ('SUBMITTED', 'APPROVED', 'PROCESSED'));



Cursor funding_disb_txn_type_csr(p_code VARCHAR2) IS
    SELECT meaning
    FROM   fnd_lookups
    WHERE  lookup_type = 'OKL_FUNDING_TYPE'
    AND    lookup_code = p_code;

Cursor Billing_invoice_status_csr(p_contract_id NUMBER) IS
    SELECT '!'
    FROM   okl_trx_ar_invoices_b
    WHERE  khr_id = p_contract_id
    AND    trx_status_code <> 'ERROR';

Cursor Advance_receipt_csr(p_contract_id NUMBER) IS
    SELECT '!'
    FROM   okl_trx_csh_receipt_v otcr, okl_txl_rcpt_apps_v otra
    WHERE  otcr.id = otra.rct_id_details
    AND    otcr.receipt_type = 'ADV'
    AND    otra.khr_id = p_contract_id;

l_return_status          VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name               CONSTANT varchar2(30) := 'VALIDATE_CANCEL_CONTRACTS';
l_api_version            CONSTANT NUMBER := 1.0;
l_contract_number        OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
l_sts_code               OKC_K_HEADERS_V.sts_code%TYPE := NULL;
l_funding_type_code      OKL_TRX_AP_INVOICES_B.funding_type_code%TYPE := NULL;
l_txn_type               FND_LOOKUPS.meaning%TYPE;
l_bankruptcy_status      VARCHAR2(1);
l_status_code            OKC_K_HEADERS_B.sts_code%TYPE;
l_billing_invoice_status VARCHAR2(1) := '?';
l_advance_receipt_status VARCHAR2(1) := '?';

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

    -- Get Contract Number from Original Contract
    OPEN  contract_csr(p_contract_id);
    FETCH contract_csr INTO l_contract_number;

    IF contract_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => G_LLA_CHR_ID);
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    CLOSE contract_csr;

    OPEN bankrupt_csr(p_contract_id);
    FETCH bankrupt_csr INTO l_bankruptcy_status;
    CLOSE bankrupt_csr;

    IF (nvl(l_bankruptcy_status,'N') = 'Y') THEN
         l_sts_code := 'BANKRUPTCY_HOLD';
         OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CANC_CNTR_INV_STATUS,
                           p_token1       => G_CONTRACT_NUMBER_TOKEN,
                           p_token1_value => l_contract_number,
                           p_token2       => G_STATUS_CODE_TOKEN,
                           p_token2_value => l_sts_code);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN contract_status_csr(p_contract_id);
    FETCH contract_status_csr INTO l_sts_code;
    IF (contract_status_csr%NOTFOUND) THEN
       null;
    END IF;

    CLOSE contract_status_csr;

    IF (l_sts_code IS NOT NULL) THEN
       OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CANC_CNTR_INV_STATUS,
                           p_token1       => G_CONTRACT_NUMBER_TOKEN,
                           p_token1_value => l_contract_number,
                           p_token2       => G_STATUS_CODE_TOKEN,
                           p_token2_value => l_sts_code);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN funding_disb_txn_csr(p_contract_id);
    FETCH funding_disb_txn_csr INTO l_funding_type_code;
    IF (funding_disb_txn_csr%NOTFOUND) THEN
       null;
    END IF;
    CLOSE funding_disb_txn_csr;

    IF (l_funding_type_code is NOT NULL) THEN
       OPEN  funding_disb_txn_type_csr(l_funding_type_code);
       FETCH funding_disb_txn_type_csr INTO l_txn_type;
       CLOSE funding_disb_txn_type_csr;

       OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CANC_CNTR_PYMT_EXIST,
                           p_token1       => G_TXN_TYPE,
                           p_token1_value => l_txn_type,
                           p_token2       => G_CONTRACT_NUMBER_TOKEN,
                           p_token2_value => l_contract_number);

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN Billing_invoice_status_csr(p_contract_id);
    FETCH Billing_invoice_status_csr INTO l_Billing_invoice_status;
    IF (Billing_invoice_status_csr%NOTFOUND) THEN
       null;
    END IF;
    CLOSE Billing_invoice_status_csr;

    IF (l_Billing_invoice_status = '!') THEN
       OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CANC_CNTR_RCPT_EXIST,
                           p_token1       => G_CONTRACT_NUMBER_TOKEN,
                           p_token1_value => l_contract_number);

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN Advance_receipt_csr(p_contract_id);
    FETCH Advance_receipt_csr INTO l_advance_receipt_status;
    IF (Advance_receipt_csr%NOTFOUND) THEN
       null;
    END IF;
    CLOSE Advance_receipt_csr;

    IF (l_advance_receipt_status = '!') THEN
       OKC_API.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CANC_CNTR_RCPT_EXIST,
                           p_token1       => G_CONTRACT_NUMBER_TOKEN,
                           p_token1_value => l_contract_number);

       x_return_status := OKC_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
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
end validate_cancel_contract;

-- Added for bug #5944260/5981076(Forward R12 cklee) -- start
 PROCEDURE cancel_funding_request(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_funding_id        IN  OKL_TRX_AP_INVOICES_B.ID%TYPE) IS

    l_tapv_rec            tapv_rec_type;
    x_tapv_rec            tapv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CANCEL_FUNDING_REQUEST';

-- Fix BPD Bug. these columns will be overridden by tapi
    CURSOR c_tap (p_funding_id OKL_TRX_AP_INVOICES_B.ID%TYPE)
    IS
      SELECT h.VENDOR_INVOICE_NUMBER,
             h.PAY_GROUP_LOOKUP_CODE,
             h.NETTABLE_YN,
             h.FUNDING_TYPE_CODE,
             h.INVOICE_TYPE
        FROM OKL_TRX_AP_INVOICES_B h
       WHERE h.id = p_funding_id;

    r_tap c_tap%ROWTYPE;

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

    -- Get the internal invoice Details
    OPEN  c_tap(p_funding_id);
    FETCH c_tap INTO r_tap;
    CLOSE c_tap;

    l_tapv_rec.id := p_funding_id;
    l_tapv_rec.trx_status_code := 'CANCELED';
    l_tapv_rec.vendor_invoice_number := r_tap.vendor_invoice_number;
    l_tapv_rec.pay_group_lookup_code := r_tap.pay_group_lookup_code;
    l_tapv_rec.nettable_yn := r_tap.nettable_yn;
    l_tapv_rec.invoice_type := r_tap.invoice_type;

    -- update funding status
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
    ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
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
  END cancel_funding_request;

  -- Added for bug #5944260/5981076(Forward R12 cklee) -- End
--------------------------------------------------------------------------------
--start of comments
-- Description   : This api takes the contract id as input and returns the status of operation
-- IN Parameters : p_contract_id - ID of the Lease contract
--End of comments
--------------------------------------------------------------------------------
Procedure confirm_cancel_contract
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_contract_id          IN  NUMBER,
				   p_new_contract_number  IN  VARCHAR2) is

l_return_status           VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name                CONSTANT varchar2(30) := 'CONVERT_FA_AMOUNTS';
l_api_version             CONSTANT NUMBER := 1.0;
l_seq_no                  NUMBER;
l_orig_contract_number    OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
l_orig_system_source_code OKC_K_HEADERS_V.ORIG_SYSTEM_SOURCE_CODE%TYPE;
l_new_contract_number     OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
l_orig_system_id1         OKC_K_HEADERS_V.ORIG_SYSTEM_ID1%TYPE;
l_funding_id    OKL_TRX_AP_INVOICES_B.ID%TYPE;  -- Added for bug 5944260/5981076(Forward R12 cklee)

CURSOR orig_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
SELECT contract_number, orig_system_source_code,
       orig_system_id1
FROM   okc_k_headers_v
WHERE  id = p_chr_id;
-- Added for bug #5944260/5981076(Forward R12 cklee) -- start
Cursor funding_cancel_csr(p_contract_id NUMBER) IS
    SELECT id
    FROM   okl_trx_ap_invoices_b
    WHERE  khr_id = p_contract_id
    AND  trx_status_code not in ('CANCELED','SUBMITTED', 'APPROVED', 'PROCESSED');
-- Added for bug #5944260/5981076(Forward R12 cklee) -- End
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

    Validate_Cancel_Contract
                     (p_api_version      => 1.0,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_contract_id      => p_contract_id);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Get Contract Number from Original Contract
    OPEN  orig_csr(p_contract_id);
    FETCH orig_csr INTO l_orig_contract_number, l_orig_system_source_code, l_orig_system_id1;

    IF orig_csr%NOTFOUND THEN
       okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_CHR_ID
                            );
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

    END IF;

    CLOSE orig_csr;

    IF (l_orig_system_source_code = 'OKL_LEASE_APP') THEN

       OKL_LEASE_APP_PVT.revert_leaseapp
                 ( p_api_version   => 1.0,
                   p_init_msg_list => OKL_API.G_FALSE,
                   p_leaseapp_id   => l_orig_system_id1,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data );

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

    END IF;

    IF (p_new_contract_number IS NULL) THEN
      -- Get Sequence Number to generate Contract Number
      SELECT okl_rbk_seq.NEXTVAL
      INTO   l_seq_no
      FROM   DUAL;

      l_new_contract_number := l_orig_contract_number || '-CANCEL'|| l_seq_no;
    ELSE
      l_new_contract_number := p_new_contract_number;
    END IF;
  -- Added for bug #5944260/5981076(Forward R12 cklee) -- start
    FOR funding_cancel_rec IN funding_cancel_csr (p_contract_id)
    LOOP
       l_funding_id := funding_cancel_rec.id;

       cancel_funding_request
                     (p_api_version      => 1.0,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_funding_id      => l_funding_id);

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
    End loop;
	  -- Added for bug #5944260/5981076(Forward R12 cklee) -- End
    -- Update the status of the header
    -- Bug# 7631183: Set datetime_cancelled to SYSDATE
    UPDATE okc_k_headers_b
    SET    sts_code = 'ABANDONED',
           contract_number = l_new_contract_number,
           datetime_cancelled = SYSDATE
    WHERE  id = p_contract_id;

    --Bug# 7030390
    -- Rename assets with CANCEL_XX :
    cancel_assets(p_api_version  =>1.0,
                   p_init_msg_list =>OKL_API.G_FALSE,
                   x_return_status =>x_return_status,
                   x_msg_count =>x_msg_count,
                   x_msg_data =>x_msg_data,
                   p_contract_id =>p_contract_id
                    ) ;
    --Bug# 7030390 End

    -- Update the status of the lines
    UPDATE okc_k_lines_b
    SET    sts_code = 'ABANDONED'
    WHERE  dnz_chr_id = p_contract_id;

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

end  confirm_cancel_contract;
end okl_maintain_contract_pvt;


/
