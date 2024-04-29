--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_CHARGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_CHARGES_PVT" as
/* $Header: OKLRKACB.pls 120.0.12010000.2 2008/12/03 10:33:08 rpillay ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
-------------------------------------------------------------------------------------------------
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_MISSING_CONTRACT            CONSTANT  Varchar2(200) := 'OKL_LLA_CONTRACT_NOT_FOUND';
  G_CONTRACT_ID_TOKEN           CONSTANT  Varchar2(30)  := 'CONTRACT_ID';
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
-------------------------------------------------------------------------------------------------

  TYPE asset_rec_type IS RECORD (fin_asset_id       OKC_K_LINES_B.id%TYPE,
                                 amount             OKL_K_LINES.amount%TYPE,
                                 asset_number       OKC_K_LINES_TL.name%TYPE,
                                 description        OKC_K_LINES_TL.item_description%TYPE,
                                 oec                OKL_K_LINES.oec%TYPE,
                                 cleb_cov_asset_id  OKC_K_LINES_B.id%TYPE,
                                 cim_cov_asset_id   OKC_K_ITEMS.id%TYPE);

  TYPE asset_tbl_type IS TABLE OF asset_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE delete_fee_service(
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_id                    IN  NUMBER) IS
  BEGIN
      null;
  END delete_fee_service;

  PROCEDURE delete_usage(
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_id                    IN  NUMBER) IS
  BEGIN
      null;
  END delete_usage;

  PROCEDURE delete_insurance(
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_id                    IN  NUMBER) IS
  BEGIN
      null;
  END delete_insurance;

  PROCEDURE allocate_amount_charges (
            p_api_version    	       IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER DEFAULT NULL,
            p_amount                 IN  NUMBER,
            p_mode                   IN  VARCHAR2,
            x_cov_asset_tbl          OUT NOCOPY cov_asset_tbl_type) IS


    l_api_name    CONSTANT VARCHAR2(30) := 'allocate_amount_charges';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR c_assets IS
    SELECT cleb_fin.id fin_asset_id,
           clet_fin.name asset_number,
           clet_fin.item_description description,
           NVL(kle_fin.oec,0) oec
    FROM   okc_k_lines_b cleb_fin,
           okc_k_lines_tl clet_fin,
           okl_k_lines kle_fin,
           okc_line_styles_b lse_fin,
           okc_statuses_b sts
    WHERE cleb_fin.dnz_chr_id = p_chr_id
    AND   cleb_fin.chr_id = p_chr_id
    AND   clet_fin.id = cleb_fin.id
    AND   clet_fin.language = USERENV('LANG')
    AND   cleb_fin.id = kle_fin.id
    AND   lse_fin.id = cleb_fin.lse_id
    AND   lse_fin.lty_code = 'FREE_FORM1'
    AND   cleb_fin.sts_code = sts.code
    AND   sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED');

    CURSOR c_term_cov_asset_lines(p_chr_id IN NUMBER,
                                  p_cle_id IN NUMBER) is
    SELECT SUM(NVL(kle_cov_asset.capital_amount,kle_cov_asset.amount)) amount
    FROM   okc_k_lines_b cleb_cov_asset,
           okl_k_lines kle_cov_asset
    WHERE  cleb_cov_asset.dnz_chr_id = p_chr_id
    AND    cleb_cov_asset.cle_id = p_cle_id
    AND    cleb_cov_asset.sts_code = 'TERMINATED'
    AND    kle_cov_asset.id = cleb_cov_asset.id;

    CURSOR c_cov_asset_line(p_chr_id     IN NUMBER,
                            p_cle_id     IN NUMBER,
                            p_fin_ast_id IN NUMBER) IS
    SELECT cov_ast_cle.id cov_ast_cle_id,
           cov_ast_cim.id cov_ast_cim_id
    FROM   okc_k_lines_b cov_ast_cle,
           okc_k_items cov_ast_cim
    WHERE  cov_ast_cle.dnz_chr_id = p_chr_id
    AND    cov_ast_cle.cle_id = p_cle_id
    AND    cov_ast_cim.cle_id = cov_ast_cle.id
    AND    cov_ast_cim.object1_id1 = TO_CHAR(p_fin_ast_id)
    AND    cov_ast_cim.object1_id2 = '#'
    and    cov_ast_cim.jtot_object1_code = 'OKX_COVASST';

    l_term_lines_cov_asset_amt NUMBER;
    i                          NUMBER := 0;
    l_chr_id                   OKC_K_HEADERS_B.id%TYPE;
    l_cle_id                   OKC_K_LINES_B.id%TYPE;
    l_amount                   NUMBER := 0;
    l_oec_total                NUMBER := 0;
    l_assoc_amount             NUMBER;
    l_assoc_total              NUMBER := 0;
    l_diff                     NUMBER;
    l_currency_code            OKC_K_HEADERS_B.currency_code%TYPE;
    l_asset_tbl                asset_tbl_type;
    l_cov_asset_tbl            cov_asset_tbl_type;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_chr_id := p_chr_id;
    l_cle_id := p_cle_id;
    If okl_context.get_okc_org_id  is null then
     	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;

    l_amount := p_amount;

    i := 0;

    FOR l_asset IN c_assets LOOP
      i := i + 1;

      l_asset_tbl(i).fin_asset_id := l_asset.fin_asset_id;
      l_asset_tbl(i).asset_number := l_asset.asset_number;
      l_asset_tbl(i).description  := l_asset.description;
      l_asset_tbl(i).oec := l_asset.oec;

      l_asset_tbl(i).cleb_cov_asset_id := NULL;
      l_asset_tbl(i).cim_cov_asset_id  := NULL;

      IF p_mode = 'UPDATE' THEN

        OPEN c_cov_asset_line(p_chr_id => l_chr_id,
                              p_cle_id => l_cle_id,
                              p_fin_ast_id => l_asset.fin_asset_id);
        FETCH c_cov_asset_line INTO l_asset_tbl(i).cleb_cov_asset_id,
                                    l_asset_tbl(i).cim_cov_asset_id;
        CLOSE c_cov_asset_line;

      END IF;
    END LOOP;

    IF p_mode = 'UPDATE' THEN
      -- Exclude Terminated line covered asset amounts from
      -- total amount available for allocation
      l_term_lines_cov_asset_amt := 0;
      OPEN c_term_cov_asset_lines(p_chr_id => l_chr_id,
                                  p_cle_id => l_cle_id);
      FETCH c_term_cov_asset_lines INTO l_term_lines_cov_asset_amt;
      CLOSE c_term_cov_asset_lines;

      l_amount := l_amount - NVL(l_term_lines_cov_asset_amt,0);

      IF l_amount < 0 THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name
                           ,p_msg_name     => 'OKL_LA_NEGATIVE_COV_AST_AMT'
                           ,p_token1       => 'AMOUNT'
                           ,p_token1_value => TO_CHAR(NVL(l_term_lines_cov_asset_amt,0)));
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF (l_asset_tbl.COUNT > 0) THEN

      ------------------------------------------------------------------
      -- 1. Loop through to get OEC total of all assets being associated
      ------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN
          l_oec_total := l_oec_total + l_asset_tbl(i).oec;
        END IF;

      END LOOP;

      SELECT currency_code
      INTO   l_currency_code
      FROM   okc_k_headers_b
      WHERE  id = l_chr_id;

      ----------------------------------------------------------------------------
      -- 2. Loop through to determine associated amounts and round off the amounts
      ----------------------------------------------------------------------------
      FOR i IN l_asset_tbl.FIRST .. l_asset_tbl.LAST LOOP

        IF l_asset_tbl.EXISTS(i) THEN

            IF l_asset_tbl.COUNT = 1 THEN

              l_assoc_amount := l_amount;

            ELSE

              l_assoc_amount := l_amount * l_asset_tbl(i).oec / l_oec_total;

            END IF;

          l_assoc_amount := okl_accounting_util.round_amount(p_amount        => l_assoc_amount,
                                                             p_currency_code => l_currency_code);

          l_assoc_total := l_assoc_total + l_assoc_amount;


          l_cov_asset_tbl(i).cleb_cov_asset_id     := l_asset_tbl(i).cleb_cov_asset_id;
          l_cov_asset_tbl(i).cleb_cov_asset_cle_id := l_cle_id;
          l_cov_asset_tbl(i).dnz_chr_id            := l_chr_id;
          l_cov_asset_tbl(i).asset_number          := l_asset_tbl(i).asset_number;
          l_cov_asset_tbl(i).description           := l_asset_tbl(i).description;
          l_cov_asset_tbl(i).capital_amount        := l_assoc_amount;
          l_cov_asset_tbl(i).cim_cov_asset_id      := l_asset_tbl(i).cim_cov_asset_id;
          l_cov_asset_tbl(i).object1_id1           := l_asset_tbl(i).fin_asset_id;
          l_cov_asset_tbl(i).object1_id2           := '#';
          l_cov_asset_tbl(i).jtot_object1_code     := 'OKX_COVASST';

        END IF;

      END LOOP;

      ----------------------------------------------------------------------------------------------------
      -- 3. Adjust associated amount if associated total does not tally up with line amount after rounding
      ----------------------------------------------------------------------------------------------------
      IF l_assoc_total <> l_amount THEN

        l_diff := l_amount - l_assoc_total;

        l_cov_asset_tbl(l_cov_asset_tbl.FIRST).capital_amount :=  l_cov_asset_tbl(l_cov_asset_tbl.FIRST).capital_amount + l_diff;

      END IF;

    END IF;

    x_cov_asset_tbl := l_cov_asset_tbl;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

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

  END allocate_amount_charges;

  PROCEDURE create_fee (
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_fee_rec        IN  fee_rec_type,
            x_fee_rec        OUT NOCOPY fee_rec_type) IS


    l_api_name    CONSTANT VARCHAR2(30) := 'create_fee';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    x_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

    i                NUMBER;
    l_rgr_tbl        OKL_RGRP_RULES_PROCESS_PVT.rgr_tbl_type;
    -- Bug# 7611623
    l_check_exception BOOLEAN := false;
    G_REQUIRED_VALUE CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_fee_types_rec.dnz_chr_id            := p_fee_rec.dnz_chr_id;
    l_fee_types_rec.fee_type              := p_fee_rec.fee_type;
    l_fee_types_rec.item_name             := p_fee_rec.cim_fee_sty_name;
    l_fee_types_rec.item_id1              := p_fee_rec.cim_fee_object1_id1;
    l_fee_types_rec.item_id2              := p_fee_rec.cim_fee_object1_id2;
    l_fee_types_rec.party_name            := p_fee_rec.cplb_fee_vendor_name;
    l_fee_types_rec.party_id1             := p_fee_rec.cplb_fee_object1_id1;
    l_fee_types_rec.party_id2             := p_fee_rec.cplb_fee_object1_id2;
    l_fee_types_rec.effective_from        := p_fee_rec.start_date;
    l_fee_types_rec.effective_to          := p_fee_rec.end_date;
    l_fee_types_rec.amount                := p_fee_rec.amount;
    l_fee_types_rec.initial_direct_cost   := p_fee_rec.initial_direct_cost;
    l_fee_types_rec.roll_qt               := p_fee_rec.rollover_term_quote_number;
    l_fee_types_rec.qte_id                := p_fee_rec.qte_id;
    l_fee_types_rec.funding_date          := p_fee_rec.funding_date;
    l_fee_types_rec.fee_purpose_code      := p_fee_rec.fee_purpose_code;
    l_fee_types_rec.attribute_category    := p_fee_rec.attribute_category;
    l_fee_types_rec.attribute1            := p_fee_rec.attribute1;
    l_fee_types_rec.attribute2            := p_fee_rec.attribute2;
    l_fee_types_rec.attribute3            := p_fee_rec.attribute3;
    l_fee_types_rec.attribute4            := p_fee_rec.attribute4;
    l_fee_types_rec.attribute5            := p_fee_rec.attribute5;
    l_fee_types_rec.attribute6            := p_fee_rec.attribute6;
    l_fee_types_rec.attribute7            := p_fee_rec.attribute7;
    l_fee_types_rec.attribute8            := p_fee_rec.attribute8;
    l_fee_types_rec.attribute9            := p_fee_rec.attribute9;
    l_fee_types_rec.attribute10           := p_fee_rec.attribute10;
    l_fee_types_rec.attribute11           := p_fee_rec.attribute11;
    l_fee_types_rec.attribute12           := p_fee_rec.attribute12;
    l_fee_types_rec.attribute13           := p_fee_rec.attribute13;
    l_fee_types_rec.attribute14           := p_fee_rec.attribute14;
    l_fee_types_rec.attribute15           := p_fee_rec.attribute15;
    l_fee_types_rec.validate_dff_yn       := p_fee_rec.validate_dff_yn;

    OKL_MAINTAIN_FEE_PVT.create_fee_type(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_fee_types_rec => l_fee_types_rec,
      x_fee_types_rec => x_fee_types_rec);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_fee_rec := p_fee_rec;
    x_fee_rec.cleb_fee_id :=  x_fee_types_rec.line_id;
    x_fee_rec.cim_fee_id  :=  x_fee_types_rec.item_id;
    x_fee_rec.cplb_fee_id :=  x_fee_types_rec.party_id;

    -- Bug# 7611623
    -- Number of periods, Amount Per Period and Frequency are mandatory for
    -- Expense, Financed and Miscellaneoud fees
    l_check_exception := false;
    IF (p_fee_rec.fee_type IN ('EXPENSE', 'MISCELLANEOUS', 'FINANCED')) THEN

        IF (p_fee_rec.rul_lafexp_rule_information1 IS NULL OR p_fee_rec.rul_lafexp_rule_information1 = OKL_API.G_MISS_CHAR) THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Number Of Periods');
          l_check_exception := true;
        END IF;
        IF (p_fee_rec.rul_lafexp_rule_information2 IS NULL OR p_fee_rec.rul_lafexp_rule_information2 = OKL_API.G_MISS_CHAR) THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Amount Per Period');
          l_check_exception := true;
        END IF;

        IF (p_fee_rec.rul_lafreq_object1_id1 IS NULL OR p_fee_rec.rul_lafreq_object1_id1 = OKL_API.G_MISS_CHAR) THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Frequency');
          l_check_exception := true;
        END IF;

    END IF;

    IF (l_check_exception) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    IF  (x_fee_rec.rul_lafreq_object1_id1 IS NOT NULL AND x_fee_rec.rul_lafreq_object1_id1 <> OKL_API.G_MISS_CHAR)
     OR (x_fee_rec.rul_lafexp_rule_information1 IS NOT NULL AND x_fee_rec.rul_lafexp_rule_information1 <> OKL_API.G_MISS_CHAR)
     OR (x_fee_rec.rul_lafexp_rule_information2 IS NOT NULL AND x_fee_rec.rul_lafexp_rule_information2 <> OKL_API.G_MISS_CHAR)
    THEN

      i := 1;

      l_rgr_tbl(i).rgd_code                  := 'LAFEXP';
      l_rgr_tbl(i).dnz_chr_id                := x_fee_rec.dnz_chr_id;
      l_rgr_tbl(i).sfwt_flag                 := OKL_API.G_FALSE;
      l_rgr_tbl(i).std_template_yn           := 'N';
      l_rgr_tbl(i).warn_yn                   := 'N';
      l_rgr_tbl(i).template_yn               := 'N';
      l_rgr_tbl(i).rule_information_category := 'LAFREQ';
      l_rgr_tbl(i).object1_id1               := x_fee_rec.rul_lafreq_object1_id1;
      l_rgr_tbl(i).object1_id2               := x_fee_rec.rul_lafreq_object1_id2;
      l_rgr_tbl(i).jtot_object1_code         := x_fee_rec.rul_lafreq_object1_code;

      i := i + 1;

      l_rgr_tbl(i).rgd_code                  := 'LAFEXP';
      l_rgr_tbl(i).dnz_chr_id                := x_fee_rec.dnz_chr_id;
      l_rgr_tbl(i).sfwt_flag                 := OKL_API.G_FALSE;
      l_rgr_tbl(i).std_template_yn           := 'N';
      l_rgr_tbl(i).warn_yn                   := 'N';
      l_rgr_tbl(i).template_yn               := 'N';
      l_rgr_tbl(i).rule_information_category := 'LAFEXP';
      l_rgr_tbl(i).rule_information1         := x_fee_rec.rul_lafexp_rule_information1;
      l_rgr_tbl(i).rule_information2         := x_fee_rec.rul_lafexp_rule_information2;

      OKL_RGRP_RULES_PROCESS_PVT.process_rule_group_rules(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_chr_id          => x_fee_rec.dnz_chr_id,
        p_line_id         => x_fee_rec.cleb_fee_id,
        p_cpl_id          => NULL,
        p_rrd_id          => NULL,
        p_rgr_tbl         => l_rgr_tbl);

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      OKL_CONTRACT_TOP_LINE_PVT.validate_fee_expense_rule(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_chr_id            => x_fee_rec.dnz_chr_id,
        p_line_id           => x_fee_rec.cleb_fee_id,
        p_no_of_period      => x_fee_rec.rul_lafexp_rule_information1,
        p_frequency         => x_fee_rec.frequency_name,
        p_amount_per_period => x_fee_rec.rul_lafexp_rule_information2);

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);

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

  END create_fee;

  PROCEDURE update_fee (
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_fee_rec        IN  fee_rec_type,
            x_fee_rec        OUT NOCOPY fee_rec_type) IS


    l_api_name    CONSTANT VARCHAR2(30) := 'update_fee';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    x_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

    i                NUMBER;
    l_rgr_tbl        OKL_RGRP_RULES_PROCESS_PVT.rgr_tbl_type;
    -- Bug# 7611623
    l_check_exception BOOLEAN := false;
    G_REQUIRED_VALUE CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_fee_types_rec.line_id               := p_fee_rec.cleb_fee_id;
    l_fee_types_rec.dnz_chr_id            := p_fee_rec.dnz_chr_id;
    l_fee_types_rec.fee_type              := p_fee_rec.fee_type;
    l_fee_types_rec.item_id               := p_fee_rec.cim_fee_id;
    l_fee_types_rec.item_name             := p_fee_rec.cim_fee_sty_name;
    l_fee_types_rec.item_id1              := p_fee_rec.cim_fee_object1_id1;
    l_fee_types_rec.item_id2              := p_fee_rec.cim_fee_object1_id2;
    l_fee_types_rec.party_id              := p_fee_rec.cplb_fee_id;
    l_fee_types_rec.party_name            := p_fee_rec.cplb_fee_vendor_name;
    l_fee_types_rec.party_id1             := p_fee_rec.cplb_fee_object1_id1;
    l_fee_types_rec.party_id2             := p_fee_rec.cplb_fee_object1_id2;
    l_fee_types_rec.effective_from        := p_fee_rec.start_date;
    l_fee_types_rec.effective_to          := p_fee_rec.end_date;
    l_fee_types_rec.amount                := p_fee_rec.amount;
    l_fee_types_rec.initial_direct_cost   := p_fee_rec.initial_direct_cost;
    l_fee_types_rec.roll_qt               := p_fee_rec.rollover_term_quote_number;
    l_fee_types_rec.qte_id                := p_fee_rec.qte_id;
    l_fee_types_rec.funding_date          := p_fee_rec.funding_date;
    l_fee_types_rec.fee_purpose_code      := p_fee_rec.fee_purpose_code;
    l_fee_types_rec.attribute_category    := p_fee_rec.attribute_category;
    l_fee_types_rec.attribute1            := p_fee_rec.attribute1;
    l_fee_types_rec.attribute2            := p_fee_rec.attribute2;
    l_fee_types_rec.attribute3            := p_fee_rec.attribute3;
    l_fee_types_rec.attribute4            := p_fee_rec.attribute4;
    l_fee_types_rec.attribute5            := p_fee_rec.attribute5;
    l_fee_types_rec.attribute6            := p_fee_rec.attribute6;
    l_fee_types_rec.attribute7            := p_fee_rec.attribute7;
    l_fee_types_rec.attribute8            := p_fee_rec.attribute8;
    l_fee_types_rec.attribute9            := p_fee_rec.attribute9;
    l_fee_types_rec.attribute10           := p_fee_rec.attribute10;
    l_fee_types_rec.attribute11           := p_fee_rec.attribute11;
    l_fee_types_rec.attribute12           := p_fee_rec.attribute12;
    l_fee_types_rec.attribute13           := p_fee_rec.attribute13;
    l_fee_types_rec.attribute14           := p_fee_rec.attribute14;
    l_fee_types_rec.attribute15           := p_fee_rec.attribute15;
    l_fee_types_rec.validate_dff_yn       := p_fee_rec.validate_dff_yn;

    OKL_MAINTAIN_FEE_PVT.update_fee_type(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_fee_types_rec => l_fee_types_rec,
      x_fee_types_rec => x_fee_types_rec);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_fee_rec := p_fee_rec;
    x_fee_rec.cleb_fee_id :=  x_fee_types_rec.line_id;
    x_fee_rec.cim_fee_id  :=  x_fee_types_rec.item_id;
    x_fee_rec.cplb_fee_id :=  x_fee_types_rec.party_id;

    -- Bug# 7611623
    -- Number of periods, Amount Per Period and Frequency are mandatory for
    -- Expense, Financed and Miscellaneoud fees
    l_check_exception := false;
    IF (p_fee_rec.fee_type IN ('EXPENSE', 'MISCELLANEOUS', 'FINANCED')) THEN

        IF (p_fee_rec.rul_lafexp_rule_information1 IS NULL OR p_fee_rec.rul_lafexp_rule_information1 = OKL_API.G_MISS_CHAR) THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Number Of Periods');
          l_check_exception := true;
        END IF;
        IF (p_fee_rec.rul_lafexp_rule_information2 IS NULL OR p_fee_rec.rul_lafexp_rule_information2 = OKL_API.G_MISS_CHAR) THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Amount Per Period');
          l_check_exception := true;
        END IF;

        IF (p_fee_rec.rul_lafreq_object1_id1 IS NULL OR p_fee_rec.rul_lafreq_object1_id1 = OKL_API.G_MISS_CHAR) THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_REQUIRED_VALUE,
                              p_token1 => G_COL_NAME_TOKEN,
                              p_token1_value => 'Frequency');
          l_check_exception := true;
        END IF;

    END IF;

    IF (l_check_exception) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    IF  (x_fee_rec.rul_lafreq_object1_id1 IS NOT NULL AND x_fee_rec.rul_lafreq_object1_id1 <> OKL_API.G_MISS_CHAR)
     OR (x_fee_rec.rul_lafexp_rule_information1 IS NOT NULL AND x_fee_rec.rul_lafexp_rule_information1 <> OKL_API.G_MISS_CHAR)
     OR (x_fee_rec.rul_lafexp_rule_information2 IS NOT NULL AND x_fee_rec.rul_lafexp_rule_information2 <> OKL_API.G_MISS_CHAR)
    THEN

      i := 1;

      l_rgr_tbl(i).rgd_code                  := 'LAFEXP';
      l_rgr_tbl(i).dnz_chr_id                := x_fee_rec.dnz_chr_id;
      l_rgr_tbl(i).sfwt_flag                 := OKL_API.G_FALSE;
      l_rgr_tbl(i).std_template_yn           := 'N';
      l_rgr_tbl(i).warn_yn                   := 'N';
      l_rgr_tbl(i).template_yn               := 'N';
      l_rgr_tbl(i).rule_information_category := 'LAFREQ';
      l_rgr_tbl(i).object1_id1               := x_fee_rec.rul_lafreq_object1_id1;
      l_rgr_tbl(i).object1_id2               := x_fee_rec.rul_lafreq_object1_id2;
      l_rgr_tbl(i).jtot_object1_code         := x_fee_rec.rul_lafreq_object1_code;

      i := i + 1;

      l_rgr_tbl(i).rgd_code                  := 'LAFEXP';
      l_rgr_tbl(i).dnz_chr_id                := x_fee_rec.dnz_chr_id;
      l_rgr_tbl(i).sfwt_flag                 := OKL_API.G_FALSE;
      l_rgr_tbl(i).std_template_yn           := 'N';
      l_rgr_tbl(i).warn_yn                   := 'N';
      l_rgr_tbl(i).template_yn               := 'N';
      l_rgr_tbl(i).rule_information_category := 'LAFEXP';
      l_rgr_tbl(i).rule_information1         := x_fee_rec.rul_lafexp_rule_information1;
      l_rgr_tbl(i).rule_information2         := x_fee_rec.rul_lafexp_rule_information2;

      OKL_RGRP_RULES_PROCESS_PVT.process_rule_group_rules(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_chr_id          => x_fee_rec.dnz_chr_id,
        p_line_id         => x_fee_rec.cleb_fee_id,
        p_cpl_id          => NULL,
        p_rrd_id          => NULL,
        p_rgr_tbl         => l_rgr_tbl);

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      OKL_CONTRACT_TOP_LINE_PVT.validate_fee_expense_rule(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_chr_id            => x_fee_rec.dnz_chr_id,
        p_line_id           => x_fee_rec.cleb_fee_id,
        p_no_of_period      => x_fee_rec.rul_lafexp_rule_information1,
        p_frequency         => x_fee_rec.frequency_name,
        p_amount_per_period => x_fee_rec.rul_lafexp_rule_information2);

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	=> x_msg_data);


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

  END update_fee;

End OKL_DEAL_CHARGES_PVT;

/
