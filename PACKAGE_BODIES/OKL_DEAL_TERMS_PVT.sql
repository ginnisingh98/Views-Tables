--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_TERMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_TERMS_PVT" as
/* $Header: OKLRDTRB.pls 120.2.12010000.5 2010/03/30 12:59:48 nikshah ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_INVALID_CRITERIA            CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_INVALID_VALUE               CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
-------------------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
-------------------------------------------------------------------------------------------------
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_LLA_AST_SERIAL              CONSTANT  VARCHAR2(200) := 'OKL_LLA_AST_SERIAL';
  G_MISSING_CONTRACT            CONSTANT Varchar2(200)  := 'OKL_LLA_CONTRACT_NOT_FOUND';
  G_CONTRACT_ID_TOKEN           CONSTANT Varchar2(30) := 'CONTRACT_ID';
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_DEAL_TERMS_PVT';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
-------------------------------------------------------------------------------------------------

   PROCEDURE delete_terms(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            p_chr_id              IN  NUMBER,
            p_rgp_id              IN  NUMBER,
            p_page_name           IN  VARCHAR2) IS
  BEGIN
      null;
  END delete_terms;


  PROCEDURE process_billing_setup(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  billing_setup_rec_type,
    x_rgpv_rec                     OUT NOCOPY billing_setup_rec_type) IS

  l_api_name         VARCHAR2(30) := 'process_billing_setup';
  l_api_version      CONSTANT NUMBER    := 1.0;

  lp_labill_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
  lx_labill_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

  lp_lapmth_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lapmth_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_labacc_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_labacc_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_lainvd_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lainvd_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_lainpr_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_lainpr_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

  lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
  lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
  l_msg_data VARCHAR2(4000);
  l_msg_index_out number;

  --sechawla 2-Jun-09 6826580
  cursor l_inv_frmt_csr(cp_inv_frmt_code in varchar2) IS
  select id
  from   okl_invoice_formats_v
  where  name = cp_inv_frmt_code;
  l_inv_frmt_id number;

  BEGIN

     x_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   IF (p_rgpv_rec.rgp_id IS NULL) THEN

    -- Create LABILL rule group
    lp_labill_rgpv_rec.id := NULL;
    lp_labill_rgpv_rec.rgd_code := 'LABILL';
    lp_labill_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
    lp_labill_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
    lp_labill_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_labill_rgpv_rec,
        x_rgpv_rec       => lx_labill_rgpv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rgp_id               := lx_labill_rgpv_rec.id;
      x_rgpv_rec.rgp_labill_lapmth_id := lx_labill_rgpv_rec.id;
      x_rgpv_rec.rgp_labill_labacc_id := lx_labill_rgpv_rec.id;
      x_rgpv_rec.rgp_labill_lainvd_id := lx_labill_rgpv_rec.id;
      x_rgpv_rec.rgp_labill_lainpr_id := lx_labill_rgpv_rec.id;

   ElSE
    -- Update LABILL rule group
    lp_labill_rgpv_rec.id := p_rgpv_rec.rgp_id;
    lp_labill_rgpv_rec.rgd_code := 'LABILL';
    lp_labill_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
    lp_labill_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
    lp_labill_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.update_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_labill_rgpv_rec,
        x_rgpv_rec       => lx_labill_rgpv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
      x_rgpv_rec.rgp_id := p_rgpv_rec.rgp_id;

   END IF;

   lp_chrv_rec.id := p_rgpv_rec.chr_id;
   lp_khrv_rec.id := p_rgpv_rec.chr_id;
   lp_chrv_rec.bill_to_site_use_id := p_rgpv_rec.bill_to_site_use_id;

   OKL_CONTRACT_PUB.update_contract_header(
           p_api_version    	=> p_api_version,
           p_init_msg_list  	=> p_init_msg_list,
           x_return_status  	=> x_return_status,
           x_msg_count      	=> x_msg_count,
           x_msg_data       	=> x_msg_data,
           p_restricted_update     => 'F',
           p_chrv_rec       	=> lp_chrv_rec,
           p_khrv_rec       	=> lp_khrv_rec,
           x_chrv_rec       	=> lx_chrv_rec,
           x_khrv_rec       	=> lx_khrv_rec);

   IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;


   IF (p_rgpv_rec.rul_lapmth_id IS NULL) THEN
      -- Create LAPMTH rule
      lp_lapmth_rulv_rec.id := NULL;
      lp_lapmth_rulv_rec.rgp_id := x_rgpv_rec.rgp_id;
      lp_lapmth_rulv_rec.rule_information_category := 'LAPMTH';
      lp_lapmth_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lapmth_rulv_rec.WARN_YN := 'N';
      lp_lapmth_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lapmth_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_lapmth_object1_id2 IS NOT NULL)) THEN
          lp_lapmth_rulv_rec.object1_id1 := p_rgpv_rec.rul_lapmth_object1_id1;
          lp_lapmth_rulv_rec.object1_id2 := p_rgpv_rec.rul_lapmth_object1_id2;
          lp_lapmth_rulv_rec.jtot_object1_code := 'OKX_RCPTMTH';
      END IF;

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lapmth_rulv_rec,
        x_rulv_rec       => lx_lapmth_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lapmth_id := lx_lapmth_rulv_rec.id;

    ELSE
      -- update LAPMTH rule
      lp_lapmth_rulv_rec.id := p_rgpv_rec.rul_lapmth_id;
      lp_lapmth_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_lapmth_rulv_rec.rule_information_category := 'LAPMTH';
      lp_lapmth_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_lapmth_rulv_rec.WARN_YN := 'N';
      lp_lapmth_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lapmth_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_lapmth_object1_id2 IS NOT NULL)) THEN
          lp_lapmth_rulv_rec.object1_id1 := p_rgpv_rec.rul_lapmth_object1_id1;
          lp_lapmth_rulv_rec.object1_id2 := p_rgpv_rec.rul_lapmth_object1_id2;
          lp_lapmth_rulv_rec.jtot_object1_code := 'OKX_RCPTMTH';
      --Bug# 7702487
      ELSIF ((p_rgpv_rec.rul_lapmth_object1_id1 IS NULL) AND (p_rgpv_rec.rul_lapmth_object1_id2 IS NULL)) THEN
          lp_lapmth_rulv_rec.object1_id1 := NULL;
          lp_lapmth_rulv_rec.object1_id2 := NULL;
          lp_lapmth_rulv_rec.jtot_object1_code := NULL;
      END IF;

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lapmth_rulv_rec,
        x_rulv_rec       => lx_lapmth_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;


    IF (p_rgpv_rec.rul_labacc_id IS NULL) THEN
      -- Create LABACC rule
      lp_labacc_rulv_rec.id := NULL;
      lp_labacc_rulv_rec.rgp_id := x_rgpv_rec.rgp_id;
      lp_labacc_rulv_rec.rule_information_category := 'LABACC';
      lp_labacc_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_labacc_rulv_rec.WARN_YN := 'N';
      lp_labacc_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_labacc_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_labacc_object1_id2 IS NOT NULL)) THEN
          lp_labacc_rulv_rec.object1_id1 := p_rgpv_rec.rul_labacc_object1_id1;
          lp_labacc_rulv_rec.object1_id2 := p_rgpv_rec.rul_labacc_object1_id2;
          lp_labacc_rulv_rec.jtot_object1_code := 'OKX_CUSTBKAC';
      END IF;

      OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_labacc_rulv_rec,
        x_rulv_rec       => lx_labacc_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_labacc_id := lx_labacc_rulv_rec.id;

    ELSE
      -- update LABACC rule
      lp_labacc_rulv_rec.id := p_rgpv_rec.rul_labacc_id;
      lp_labacc_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_labacc_rulv_rec.rule_information_category := 'LABACC';
      lp_labacc_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_labacc_rulv_rec.WARN_YN := 'N';
      lp_labacc_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_labacc_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_labacc_object1_id2 IS NOT NULL)) THEN
          lp_labacc_rulv_rec.object1_id1 := p_rgpv_rec.rul_labacc_object1_id1;
          lp_labacc_rulv_rec.object1_id2 := p_rgpv_rec.rul_labacc_object1_id2;
          lp_labacc_rulv_rec.jtot_object1_code := 'OKX_CUSTBKAC';
      --Bug# 7702487
      ELSIF ((p_rgpv_rec.rul_labacc_object1_id1 IS NULL) AND (p_rgpv_rec.rul_labacc_object1_id2 IS NULL)) THEN
          lp_labacc_rulv_rec.object1_id1 := NULL;
          lp_labacc_rulv_rec.object1_id2 := NULL;
          lp_labacc_rulv_rec.jtot_object1_code := NULL;
      END IF;

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_labacc_rulv_rec,
        x_rulv_rec       => lx_labacc_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;


   IF (p_rgpv_rec.rul_lainvd_id IS NULL) THEN
      -- Create LAINVD rule
      lp_lainvd_rulv_rec.id := NULL;
      lp_lainvd_rulv_rec.rgp_id := x_rgpv_rec.rgp_id;
      lp_lainvd_rulv_rec.rule_information_category := 'LAINVD';
      lp_lainvd_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;

      --sechawla 2-jun-09 6826580 : begin
      open   l_inv_frmt_csr(p_rgpv_rec.lainvd_rule_information1);
      fetch  l_inv_frmt_csr into l_inv_frmt_id;
      close  l_inv_frmt_csr;
      -- lp_lainvd_rulv_rec.rule_information1 := p_rgpv_rec.lainvd_rule_information1;
      lp_lainvd_rulv_rec.rule_information1 := to_char(l_inv_frmt_id);
      --sechawla 2-jun-09 6826580 : end

      lp_lainvd_rulv_rec.rule_information3 := p_rgpv_rec.lainvd_rule_information3;
      lp_lainvd_rulv_rec.rule_information4 := p_rgpv_rec.lainvd_rule_information4;
      lp_lainvd_rulv_rec.WARN_YN := 'N';
      lp_lainvd_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lainvd_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_lainvd_object1_id2 IS NOT NULL)) THEN
          lp_lainvd_rulv_rec.object1_id1 := p_rgpv_rec.rul_lainvd_object1_id1;
          lp_lainvd_rulv_rec.object1_id2 := p_rgpv_rec.rul_lainvd_object1_id2;
          lp_lainvd_rulv_rec.jtot_object1_code := 'OKL_CASHAPPL';
      END IF;

      OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lainvd_rulv_rec,
        x_rulv_rec       => lx_lainvd_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_lainvd_id := lx_lainvd_rulv_rec.id;

     ELSE
      -- Update LAINVD rule
      lp_lainvd_rulv_rec.id := p_rgpv_rec.rul_lainvd_id;
      lp_lainvd_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_lainvd_rulv_rec.rule_information_category := 'LAINVD';
      lp_lainvd_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;

      --sechawla 2-jun-09 6826580 : begin
      open   l_inv_frmt_csr(p_rgpv_rec.lainvd_rule_information1);
      fetch  l_inv_frmt_csr into l_inv_frmt_id;
      close  l_inv_frmt_csr;
      -- lp_lainvd_rulv_rec.rule_information1 := p_rgpv_rec.lainvd_rule_information1;
      lp_lainvd_rulv_rec.rule_information1 := to_char(l_inv_frmt_id);
      --sechawla 2-jun-09 6826580 : end

      lp_lainvd_rulv_rec.rule_information3 := p_rgpv_rec.lainvd_rule_information3;
      lp_lainvd_rulv_rec.rule_information4 := p_rgpv_rec.lainvd_rule_information4;
      lp_lainvd_rulv_rec.WARN_YN := 'N';
      lp_lainvd_rulv_rec.STD_TEMPLATE_YN := 'N';
      IF ((p_rgpv_rec.rul_lainvd_object1_id1 IS NOT NULL) AND (p_rgpv_rec.rul_lainvd_object1_id2 IS NOT NULL)) THEN
          lp_lainvd_rulv_rec.object1_id1 := p_rgpv_rec.rul_lainvd_object1_id1;
          lp_lainvd_rulv_rec.object1_id2 := p_rgpv_rec.rul_lainvd_object1_id2;
          lp_lainvd_rulv_rec.jtot_object1_code := 'OKL_CASHAPPL';
      --Bug# 7702487
      ELSIF ((p_rgpv_rec.rul_lainvd_object1_id1 IS NULL) AND (p_rgpv_rec.rul_lainvd_object1_id2 IS NULL)) THEN
          lp_lainvd_rulv_rec.object1_id1 := NULL;
          lp_lainvd_rulv_rec.object1_id2 := NULL;
          lp_lainvd_rulv_rec.jtot_object1_code := NULL;
      END IF;

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_lainvd_rulv_rec,
        x_rulv_rec       => lx_lainvd_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

     END IF;

     IF (p_rgpv_rec.rul_lainpr_id IS NULL) THEN
        -- Create LAINPR rule
        lp_lainpr_rulv_rec.id := NULL;
        lp_lainpr_rulv_rec.rgp_id := x_rgpv_rec.rgp_id;
        lp_lainpr_rulv_rec.rule_information_category := 'LAINPR';
        lp_lainpr_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
        lp_lainpr_rulv_rec.rule_information1 := p_rgpv_rec.lainpr_rule_information1;
        lp_lainpr_rulv_rec.rule_information2 := p_rgpv_rec.lainpr_rule_information2;
        lp_lainpr_rulv_rec.WARN_YN := 'N';
        lp_lainpr_rulv_rec.STD_TEMPLATE_YN := 'N';

        OKL_RULE_PUB.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_lainpr_rulv_rec,
          x_rulv_rec       => lx_lainpr_rulv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        x_rgpv_rec.rul_lainpr_id := lx_lainpr_rulv_rec.id;

      ELSE
        -- Update LAINPR rule
        lp_lainpr_rulv_rec.id := p_rgpv_rec.rul_lainpr_id;
        lp_lainpr_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
        lp_lainpr_rulv_rec.rule_information_category := 'LAINPR';
        lp_lainpr_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
        lp_lainpr_rulv_rec.rule_information1 := p_rgpv_rec.lainpr_rule_information1;
        lp_lainpr_rulv_rec.rule_information2 := p_rgpv_rec.lainpr_rule_information2;
        lp_lainpr_rulv_rec.WARN_YN := 'N';
        lp_lainpr_rulv_rec.STD_TEMPLATE_YN := 'N';

        OKL_RULE_PUB.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_lainpr_rulv_rec,
          x_rulv_rec       => lx_lainpr_rulv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

      OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);
  END process_billing_setup;

  PROCEDURE process_rvi(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_rgpv_rec          IN  rvi_rec_type,
    x_rgpv_rec          OUT NOCOPY rvi_rec_type) IS

  l_api_name         VARCHAR2(30) := 'process_rvi';
  l_api_version      CONSTANT NUMBER    := 1.0;

  lp_larvin_rgpv_rec  OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
  lx_larvin_rgpv_rec  OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

  lp_larvau_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_larvau_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_larvam_rulv_rec  Okl_Rule_Pub.rulv_rec_type;
  lx_larvam_rulv_rec  Okl_Rule_Pub.rulv_rec_type;

  lp_fee_types_rec   OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
  lx_fee_types_rec   OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

  l_msg_data VARCHAR2(4000);
  l_msg_index_out number;

  BEGIN
     x_return_status := OKL_API.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => g_api_type,
                        x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   IF (p_rgpv_rec.rgp_id IS NULL) THEN

    -- Create LARVIN rule group
    lp_larvin_rgpv_rec.id := NULL;
    lp_larvin_rgpv_rec.rgd_code := 'LARVIN';
    lp_larvin_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
    lp_larvin_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
    lp_larvin_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larvin_rgpv_rec,
        x_rgpv_rec       => lx_larvin_rgpv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rgp_id := lx_larvin_rgpv_rec.id;

   ElSE

    -- Update LARVIN rule group
    lp_larvin_rgpv_rec.id := p_rgpv_rec.rgp_id;
    lp_larvin_rgpv_rec.rgd_code := 'LARVIN';
    lp_larvin_rgpv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
    lp_larvin_rgpv_rec.chr_id := p_rgpv_rec.chr_id;
    lp_larvin_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.update_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larvin_rgpv_rec,
        x_rgpv_rec       => lx_larvin_rgpv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

   IF (p_rgpv_rec.rul_larvau_id IS NULL) THEN
      -- Create LARVAU rule
      lp_larvau_rulv_rec.id := NULL;
      lp_larvau_rulv_rec.rgp_id := lx_larvin_rgpv_rec.id;
      lp_larvau_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_larvau_rulv_rec.rule_information_category := 'LARVAU';
      lp_larvau_rulv_rec.rule_information1 := p_rgpv_rec.larvau_rule_information1;
      lp_larvau_rulv_rec.WARN_YN := 'N';
      lp_larvau_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larvau_rulv_rec,
        x_rulv_rec       => lx_larvau_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_larvau_id := lx_larvau_rulv_rec.id;

    ELSE

      -- Update LARVAU rule
      lp_larvau_rulv_rec.id := p_rgpv_rec.rul_larvau_id;
      lp_larvau_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_larvau_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_larvau_rulv_rec.rule_information_category := 'LARVAU';
      lp_larvau_rulv_rec.rule_information1 := p_rgpv_rec.larvau_rule_information1;
      lp_larvau_rulv_rec.WARN_YN := 'N';
      lp_larvau_rulv_rec.STD_TEMPLATE_YN := 'N';

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larvau_rulv_rec,
        x_rulv_rec       => lx_larvau_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_larvau_id := lx_larvau_rulv_rec.id;
   END IF;

   IF (p_rgpv_rec.rul_larvam_id IS NULL) THEN
      -- Create LARVAM rule
      lp_larvam_rulv_rec.id := NULL;
      lp_larvam_rulv_rec.rgp_id := lx_larvin_rgpv_rec.id;
      lp_larvam_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_larvam_rulv_rec.rule_information_category := 'LARVAM';
      lp_larvam_rulv_rec.rule_information4 := p_rgpv_rec.larvam_rule_information4;
      lp_larvam_rulv_rec.WARN_YN := 'N';
      lp_larvam_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larvam_rulv_rec,
        x_rulv_rec       => lx_larvam_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_larvam_id := lx_larvam_rulv_rec.id;

    ELSE

      -- Update LARVAM rule
      lp_larvam_rulv_rec.id := p_rgpv_rec.rul_larvam_id;
      lp_larvam_rulv_rec.rgp_id := p_rgpv_rec.rgp_id;
      lp_larvam_rulv_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_larvam_rulv_rec.rule_information_category := 'LARVAM';
      lp_larvam_rulv_rec.rule_information4 := p_rgpv_rec.larvam_rule_information4;
      lp_larvam_rulv_rec.WARN_YN := 'N';
      lp_larvam_rulv_rec.STD_TEMPLATE_YN := 'N';

      OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larvam_rulv_rec,
        x_rulv_rec       => lx_larvam_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rgpv_rec.rul_larvam_id := lx_larvam_rulv_rec.id;
    END IF;

      lp_fee_types_rec.dnz_chr_id := p_rgpv_rec.chr_id;
      lp_fee_types_rec.line_id := p_rgpv_rec.line_id;
      lp_fee_types_rec.item_id1 := p_rgpv_rec.item_id1;
      lp_fee_types_rec.item_name := p_rgpv_rec.item_name;
      lp_fee_types_rec.fee_type := 'ABSORBED';
      lp_fee_types_rec.fee_purpose_code := 'RVI';

      OKL_MAINTAIN_FEE_PVT.process_rvi_stream(
            p_api_version       => p_api_version,
            p_init_msg_list     => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_check_box_value   => p_rgpv_rec.larvau_rule_information1,
            p_fee_types_rec     => lp_fee_types_rec,
            x_fee_types_rec     => lx_fee_types_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END process_rvi;

  PROCEDURE load_billing_setup(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_billing_setup_rec          OUT NOCOPY billing_setup_rec_type) IS

  l_return_status        VARCHAR2(1) default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'load_billing_setup';
  l_api_version          CONSTANT NUMBER := 1.0;

  CURSOR c_bill_to(p_chr_id NUMBER) IS
  SELECT chr.bill_to_site_use_id,
         csu.location bill_to_site_name
  FROM okc_k_headers_b chr,
       hz_cust_site_uses_all csu
  WHERE chr.id = p_chr_id
  AND   csu.site_use_id = chr.bill_to_site_use_id;

  CURSOR c_rule(p_chr_id NUMBER, p_rgd_code VARCHAR2, p_rule_info_cat VARCHAR2) IS
  SELECT rul.rgp_id,rgp.rgd_code,rul.ID,rul.object1_id1,rul.object1_id2,rul.rule_information1,rul.rule_information2,
         rul.rule_information3, rul.rule_information4
  FROM  okc_rules_b rul,
        okc_rule_groups_b rgp
  WHERE rgp.chr_id = p_chr_id
  AND   rgp.dnz_chr_id = p_chr_id
  AND   rgp.rgd_code = p_rgd_code
  AND   rgp.id = rul.rgp_id
  AND   rgp.dnz_chr_id = rul.dnz_chr_id
  AND   rul.rule_information_category = p_rule_info_cat;

  l_rule c_rule%ROWTYPE;

  CURSOR c_payment_method(p_object1_id1 NUMBER) IS
  SELECT name
  FROM okx_receipt_methods_v
  WHERE id1 = p_object1_id1;

  CURSOR c_bank_info(p_object1_id1 NUMBER) IS
  SELECT description name,bank bank_name
  FROM okx_rcpt_method_accounts_v
  WHERE id1 = p_object1_id1;

  CURSOR c_cash_app(p_object1_id1 NUMBER) IS
  SELECT name
  FROM okl_bpd_active_csh_rls_v
  WHERE id1 = p_object1_id1;

  --sechawla 26-may-09 6826580 :begin
  CURSOR c_invoice_formats(p_inv_fmt_id IN NUMBER) IS
  SELECT name
  FROM   okl_invoice_formats_v
  WHERE  ID = p_inv_fmt_id;
  l_format_name   VARCHAR2(150);
  --sechawla 26-may-09 6826580 :end

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

    x_billing_setup_rec.chr_id := p_chr_id;
    OPEN c_bill_to(p_chr_id);
    FETCH c_bill_to INTO x_billing_setup_rec.bill_to_site_use_id, x_billing_setup_rec.bill_to_site_name;
    CLOSE c_bill_to;

    OPEN c_rule(p_chr_id , 'LABILL', 'LAPMTH');
    FETCH c_rule INTO l_rule;
    x_billing_setup_rec.rgp_id                 := l_rule.rgp_id;
    x_billing_setup_rec.rgp_labill_lapmth_id   := l_rule.rgp_id;
    x_billing_setup_rec.rgp_labill_labacc_id   := l_rule.rgp_id;
    x_billing_setup_rec.rgp_labill_lainvd_id   := l_rule.rgp_id;
    x_billing_setup_rec.rgp_labill_lainpr_id   := l_rule.rgp_id;
    x_billing_setup_rec.rul_lapmth_id          := l_rule.id;
    x_billing_setup_rec.rul_lapmth_object1_id1 := l_rule.object1_id1;
    x_billing_setup_rec.rul_lapmth_object1_id2 := l_rule.object1_id2;
    CLOSE c_rule;

    IF (x_billing_setup_rec.rul_lapmth_object1_id1 IS NOT NULL) THEN
       OPEN c_payment_method(x_billing_setup_rec.rul_lapmth_object1_id1);
       FETCH c_payment_method INTO x_billing_setup_rec.rul_lapmth_name;
       CLOSE c_payment_method;
    END IF;

    OPEN c_rule(p_chr_id , 'LABILL', 'LABACC');
    FETCH c_rule INTO l_rule;
    x_billing_setup_rec.rul_labacc_id          := l_rule.id;
    x_billing_setup_rec.rul_labacc_object1_id1 := l_rule.object1_id1;
    x_billing_setup_rec.rul_labacc_object1_id2 := l_rule.object1_id2;
    CLOSE c_rule;

    IF (x_billing_setup_rec.rul_labacc_object1_id1 IS NOT NULL) THEN
       OPEN c_bank_info(x_billing_setup_rec.rul_labacc_object1_id1);
       FETCH c_bank_info INTO x_billing_setup_rec.rul_labacc_name,x_billing_setup_rec.rul_labacc_bank_name;
       CLOSE c_bank_info;
    END IF;

    OPEN c_rule(p_chr_id , 'LABILL', 'LAINVD');
    FETCH c_rule INTO l_rule;
    x_billing_setup_rec.rul_lainvd_id                 := l_rule.id;

	--x_billing_setup_rec.lainvd_rule_information1      := l_rule.rule_information1;

       --sechawla 26-may-09 6826580 : get the format name : begin
       OPEN   c_invoice_formats(to_number(l_rule.rule_information1));
       FETCH  c_invoice_formats INTO l_format_name;
       CLOSE  c_invoice_formats;

       x_billing_setup_rec.lainvd_rule_information1      := l_format_name;
       --sechawla 26-may-09 6826580 : get the format name : end

    x_billing_setup_rec.lainvd_invoice_format_meaning := l_format_name; --l_rule.rule_information1; --sechawla 26-may-09 6826580
    x_billing_setup_rec.lainvd_rule_information3      := l_rule.rule_information3;
    x_billing_setup_rec.lainvd_rule_information4      := l_rule.rule_information4;
    x_billing_setup_rec.rul_lainvd_object1_id1        := l_rule.object1_id1;
    x_billing_setup_rec.rul_lainvd_object1_id2        := l_rule.object1_id2;
    CLOSE c_rule;

    IF (x_billing_setup_rec.rul_lainvd_object1_id1 IS NOT NULL) THEN
       OPEN c_cash_app(x_billing_setup_rec.rul_lainvd_object1_id1);
       FETCH c_cash_app INTO x_billing_setup_rec.rul_lainvd_name;
       CLOSE c_cash_app;
    END IF;

    OPEN c_rule(p_chr_id , 'LABILL', 'LAINPR');
    FETCH c_rule INTO l_rule;
    x_billing_setup_rec.rul_lainpr_id                 := l_rule.id;
    x_billing_setup_rec.lainpr_rule_information1      := l_rule.rule_information1;
    x_billing_setup_rec.lainpr_rule_information2      := l_rule.rule_information2;
    CLOSE c_rule;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

    --sechawla 26-may-09 6826580
    IF c_invoice_formats%ISOPEN THEN
       CLOSE c_invoice_formats;
    END IF;

    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

    --sechawla 26-may-09 6826580
    IF c_invoice_formats%ISOPEN THEN
       CLOSE c_invoice_formats;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN

    --sechawla 26-may-09 6826580
    IF c_invoice_formats%ISOPEN THEN
       CLOSE c_invoice_formats;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END load_billing_setup;

  PROCEDURE load_rvi(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_rvi_rec                    OUT NOCOPY rvi_rec_type) IS

  l_return_status        VARCHAR2(1) default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'load_rvi';
  l_api_version          CONSTANT NUMBER := 1.0;

  CURSOR c_rule(p_chr_id NUMBER) IS
  SELECT rgp.dnz_chr_id,
         rgp.id rgp_id,
         rgp.rgd_code,
         rgp.id rgp_larvin_larvau_id,
         rgp.id rgp_larvin_larvam_id,
         rul_larvau.id rul_larvau_id,
	 rul_larvau.rule_information_category larvau_rule_info_cat,
	 rul_larvam.id rul_larvam_id,
	 rul_larvam.rule_information_category larvam_rule_info_cat,
         rul_larvau.rule_information1 larvau_rule_information1,
	 rul_larvam.rule_information4 larvam_rule_information4
  FROM  okc_rules_b rul_larvau,
        okc_rules_b rul_larvam,
        okc_rule_groups_b rgp
  WHERE rgp.chr_id = p_chr_id
  AND   rgp.dnz_chr_id = p_chr_id
  AND   rgp.rgd_code = 'LARVIN'
  AND   rul_larvau.rgp_id = rgp.id
  AND   rul_larvau.dnz_chr_id = rgp.dnz_chr_id
  AND   rul_larvau.rule_information_category = 'LARVAU'
  AND   rul_larvam.rgp_id = rgp.id
  AND   rul_larvam.rule_information_category = 'LARVAM'
  AND   rul_larvam.dnz_chr_id = rgp.dnz_chr_id;

  CURSOR c_stream_name(p_chr_id NUMBER) IS
  SELECT cle.id,ossv.id1,name,fee_type
  from okc_k_lines_b cle,
       okl_k_lines kle,
       okc_k_items itm,
       okl_strmtyp_source_v ossv,
       okc_line_styles_b olsb
  where cle.id = kle.id
  and cle.id = itm.cle_id
  and itm.object1_id1 = ossv.id1
  and kle.fee_type = 'ABSORBED'
  and kle.fee_purpose_code = 'RVI'
  and cle.lse_id = olsb.ID
  and olsb.LTY_CODE = 'FEE'
  and cle.dnz_chr_id = p_chr_id;

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

    OPEN c_rule(p_chr_id);
    FETCH c_rule INTO x_rvi_rec.chr_id,x_rvi_rec.rgp_id,x_rvi_rec.rgd_code,x_rvi_rec.rgp_larvin_larvau_id,x_rvi_rec.rgp_larvin_larvam_id,
                      x_rvi_rec.rul_larvau_id,x_rvi_rec.larvau_rule_info_cat,x_rvi_rec.rul_larvam_id,x_rvi_rec.larvam_rule_info_cat,
                      x_rvi_rec.larvau_rule_information1, x_rvi_rec.larvam_rule_information4;
    CLOSE c_rule;

    OPEN c_stream_name(p_chr_id);
    FETCH c_stream_name INTO  x_rvi_rec.line_id,x_rvi_rec.item_id1,x_rvi_rec.item_name,x_rvi_rec.fee_type;
    CLOSE c_stream_name;

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
  END load_rvi;

 PROCEDURE delete_tnc_group(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_tnc_id                     IN  NUMBER
      ) is


  l_return_status        VARCHAR2(1) default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'delete_tnc_group';
  l_api_version          CONSTANT NUMBER := 1.0;


  Cursor l_rgp_csr (p_rgp_id in number) IS
  SELECT 'Y'
  from   okc_rule_groups_b
  where  id = p_rgp_id;

  l_rgp_found VARCHAR2(1) := 'N';

  Cursor l_ppyh_csr  (p_ppyh_id in number) is
  SELECT 'Y'
  from   OKL_PARTY_PAYMENT_HDR
  where  id = p_ppyh_id;

  l_ppyh_found VARCHAR2(1) := 'N';

  Cursor l_ppyl_csr (p_ppyh_id in number) is
  SELECT id, cpl_id
  from   OKL_PARTY_PAYMENT_DTLS
  where  payment_hdr_id = p_ppyh_id;

  l_ppyl_id OKL_PARTY_PAYMENT_DTLS.ID%TYPE := NULL;
  l_cpl_id  OKL_PARTY_PAYMENT_DTLS.CPL_ID%TYPE := NULL;

  l_rgpv_rec    okc_rule_pub.rgpv_rec_type;
  l_ppydv_rec   okl_party_payments_pvt.ppydv_rec_type;
  l_pphv_rec    okl_party_payments_pvt.pphv_rec_type;



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

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           'OKL_DEAL_CREAT_PVT.delete_tnc_group.',
                           'p_tnc_id :'||p_tnc_id);
    END IF;

    --1.Check if tnc exists in rule groups
    open l_rgp_csr (p_rgp_id => p_tnc_id);
    Fetch l_rgp_csr into l_rgp_found;
    If l_rgp_csr%NOTFOUND then
        NULL;
    End If;
    Close l_rgp_csr;

    If l_rgp_found = 'Y' then
        --delete the rule group
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'Before call to delete_rule_group = '||x_return_status);
        END IF;
        l_rgpv_rec.id := p_tnc_id;
        okc_rule_pub.delete_rule_group(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_rgpv_rec      => l_rgpv_rec);
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'After call to delete_rule_group = '||x_return_status);
        END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    ElsIf l_rgp_found = 'N' then
        --2. Check if record exists in OKL_PARTY_PAYMENT_HDR for
        -- evergreen passthrough
        Open l_ppyh_csr (p_ppyh_id => p_tnc_id);
        Fetch l_ppyh_csr into l_ppyh_found;
        If l_ppyh_csr%NOTFOUND then
            --raise error as this means that the id
            --passed is invalid
            okl_api.set_message(
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKL_CONTRACTS_INVALID_VALUE',
                             p_token1   => 'COL_NAME',
                             p_token1_value => 'Terms and Condition group'
                            );
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;

        End If;
        Close l_ppyh_csr;
        If l_ppyh_found = 'Y' Then
            --delete party payment records
            --Fetch party payment details records
            Open l_ppyl_csr (p_ppyh_id => p_tnc_id);
            Loop
                Fetch l_ppyl_csr into l_ppyl_id, l_cpl_id;
                Exit when l_ppyl_csr%NOTFOUND;
                If l_ppyl_id is Not Null Then
                   --delete the party payment detail
                   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'Before call to delete_party_payment_dtls = '||x_return_status);
                   END IF;
                   l_ppydv_rec.id := l_ppyl_id;
                   OKL_PARTY_PAYMENTS_PVT.delete_party_payment_dtls(
                     p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_ppydv_rec     => l_ppydv_rec
                     );
                   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'After call to delete_party_payment_dtls = '||x_return_status);
                   END IF;
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
               End If;
          End Loop;
          Close l_ppyl_csr;
          --Delete the party payment header record
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'Before call to delete_party_payment_hdr = '||x_return_status);
          END IF;
          l_pphv_rec.id := p_tnc_id;
          OKL_PARTY_PAYMENTS_PVT.delete_party_payment_hdr(
                     p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_pphv_rec     => l_pphv_rec
                     );
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'After  call to delete_party_payment_hdr = '||x_return_status);
          END IF;
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
     End If;
  End If;
  OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'End(-)');
     END IF;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF l_rgp_csr%ISOPEN THEN
            CLOSE l_rgp_csr;
         END IF;
         IF l_ppyh_csr%ISOPEN THEN
            CLOSE l_ppyh_csr;
         END IF;
         IF l_ppyl_csr%ISOPEN THEN
            CLOSE l_ppyl_csr;
         END IF;
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                    l_api_name,
                                    G_PKG_NAME,
                                    'OKL_API.G_RET_STS_ERROR',
                                    x_msg_count,
                                    x_msg_data,
                                    '_PVT');
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'EXP - ERROR');
         END IF;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF l_rgp_csr%ISOPEN THEN
            CLOSE l_rgp_csr;
         END IF;
         IF l_ppyh_csr%ISOPEN THEN
            CLOSE l_ppyh_csr;
         END IF;
         IF l_ppyl_csr%ISOPEN THEN
            CLOSE l_ppyl_csr;
         END IF;
         x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                   l_api_name,
                                   G_PKG_NAME,
                                   'OKL_API.G_RET_STS_UNEXP_ERROR',
                                   x_msg_count,
                                   x_msg_data,
                                   '_PVT');
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'EXP - UNEXCP ERROR');
         END IF;
    WHEN OTHERS THEN
         IF l_rgp_csr%ISOPEN THEN
            CLOSE l_rgp_csr;
         END IF;
         IF l_ppyh_csr%ISOPEN THEN
            CLOSE l_ppyh_csr;
         END IF;
         IF l_ppyl_csr%ISOPEN THEN
            CLOSE l_ppyl_csr;
         END IF;
         x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                   l_api_name,
                                   G_PKG_NAME,
                                   'OTHERS',
                                   x_msg_count,
                                   x_msg_data,
                                   '_PVT');
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'OKL_DEAL_CREAT_PVT.delete_tnc_group.', 'EXP - OTHERS');
         END IF;
  END delete_tnc_group;

End OKL_DEAL_TERMS_PVT;

/
