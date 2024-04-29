--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_SPLIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_SPLIT_PVT" AS
/* $Header: OKLRPMSB.pls 120.4.12010000.2 2008/11/25 09:26:53 nikshah ship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_SPLIT_PVT';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';


   subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
   subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
   subtype rgpv_tbl_type IS OKL_RULE_PUB.rgpv_tbl_type;
   subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;

------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );

    FOR i in 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

    END LOOP;
    return;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;

------------------------------------------------------------------------------
-- PROCEDURE get_fee_subline_cap_amount
--
--  This procedure returns Capital Amount from FEE Sub line corresponding
--  to Financial Asset Line, passed as parameter
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_fee_subline_cap_amount(
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_msg_count     OUT NOCOPY NUMBER,
                                        x_msg_data      OUT NOCOPY VARCHAR2,
                                        p_fin_line_id   IN  NUMBER,
                                        x_fee_cap_amt   OUT NOCOPY NUMBER
                                       ) IS

   l_proc_name  VARCHAR2(35) := 'GET_FEE_SUBLINE_CAP_AMOUNT';
   l_cap_amount NUMBER;

   CURSOR cap_csr (p_fin_line_id NUMBER) IS
   SELECT SUM(NVL(okl1.capital_amount,0))
   FROM   okl_k_lines_full_v okl1, -- fee sub line
          okl_k_lines_full_v okl2, -- fee top line
          okc_k_items_v item1,
          okc_k_items_v item2,
          okl_strmtyp_source_v stream
   WHERE  item1.object1_id1       = TO_CHAR(p_fin_line_id) -- Bug 3830454
   AND    item1.jtot_object1_code = 'OKX_COVASST'       -- Bug 3830454
   AND    stream.capitalize_yn = 'Y'
   AND    okl1.id              = item1.cle_id
   AND    okl2.id              = okl1.cle_id
   AND    okl2.id              = item2.cle_id
   AND    item2.object1_id1    = stream.id1;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      l_cap_amount := 0;
      OPEN cap_csr(p_fin_line_id);
      FETCH cap_csr INTO l_cap_amount;
      IF cap_csr%NOTFOUND THEN

         l_cap_amount := 0;
      END IF;

      CLOSE cap_csr;

      x_fee_cap_amt := l_cap_amount;

      RETURN;
   END get_fee_subline_cap_amount;

------------------------------------------------------------------------------
-- PROCEDURE get_currency_precision
--
--  This procedure returns Precision for a currency attached at header level
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_currency_precision (
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                     x_precision     OUT NOCOPY FND_CURRENCIES.PRECISION%TYPE
                                    ) IS
   CURSOR chr_csr (p_chr_id NUMBER) IS
   SELECT currency_code
   FROM   okc_k_headers_v
   WHERE  id = p_chr_id;

   CURSOR curr_csr (p_curr_code VARCHAR2) IS
   SELECT precision
   FROM   fnd_currencies
   WHERE  currency_code = p_curr_code;

   curr_failed     EXCEPTION;
   l_currency_code FND_CURRENCIES.CURRENCY_CODE%TYPE;
   l_precision     FND_CURRENCIES.PRECISION%TYPE;

   BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      OPEN chr_csr(p_chr_id);
      FETCH chr_csr INTO l_currency_code;
      IF chr_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_CHR_ID
                            );
         RAISE curr_failed;
      END IF;

      CLOSE chr_csr;

      OPEN curr_csr(l_currency_code);
      FETCH curr_csr INTO l_precision;
      IF curr_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_INVALID_VALUE,
                             'COL_NAME',
                             'CURRENCY CODE'
                            );
         RAISE curr_failed;
      END IF;
      CLOSE curr_csr;

      x_precision := l_precision;
      RETURN;

   EXCEPTION
      WHEN curr_failed THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
   END get_currency_precision;

------------------------------------------------------------------------------
-- PROCEDURE gen_line_rule
--
--  This procedure generates line rule (SLH, SLL) after applying the payment
--  amount. Calculation = (Rule Payment Amount * Line Capital Amount) /
--                         Total Capital Amount
--  It returns line level rule information in x_strm_tbl table
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE gen_line_rule(
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2,
                               p_chr_id                  IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_cle_id                  IN  NUMBER,
                               p_fin_line_capital_amount IN  NUMBER,
                               p_tot_capital_amount      IN  NUMBER,
                               p_precision               IN  FND_CURRENCIES.PRECISION%TYPE,
                               p_payment_type            IN  VARCHAR2,
                               p_amount                  IN  NUMBER,
                               p_period                  IN  NUMBER,
                               p_start_date              IN  DATE,
                               p_frequency               IN  VARCHAR2,
                               p_strm_count              IN  NUMBER,
                               x_strm_tbl                OUT NOCOPY okl_mass_rebook_pub.strm_lalevl_tbl_type
                              ) IS
   l_proc_name VARCHAR2(35) := 'GEN_LINE_RULE';

   CURSOR strm_csr (p_strm_code VARCHAR2) IS
   SELECT ID1
   FROM   okl_strmtyp_source_v
   WHERE  code = p_strm_code;

   -- _new indicates the rules that got created under Line as part of payment applications
   x_new_rgpv_rec      rgpv_rec_type;
   x_new_slh_rulv_rec  rulv_rec_type;

   x_slh_rulv_tbl      rulv_tbl_type;
   x_slh_rule_count    NUMBER;

   x_sll_rulv_tbl      rulv_tbl_type;
   x_sll_rule_count    NUMBER;

   x_rulv_rec          rulv_rec_type;

   l_rgpv_rec          rgpv_rec_type;
   l_slh_rulv_rec      rulv_rec_type;
   l_sll_rulv_rec      rulv_rec_type;
   l_fee_line_capital_amount NUMBER;
   l_line_capital_amount     NUMBER;
   l_rgp_id            NUMBER;

   l_strm_count        NUMBER := 0;
   l_strm_id           NUMBER;
   rule_failed         EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      l_strm_count := p_strm_count + 1;

      --debug_message('gen, srtm_count 1 :'||l_strm_count);

      l_strm_id := NULL;
      OPEN strm_csr (p_payment_type);
      FETCH strm_csr INTO l_strm_id;
      CLOSE strm_csr;

      IF (l_strm_id IS NULL) THEN
         RAISE rule_failed;
      END IF;

      -- Populate SLH for this line
      x_strm_tbl(l_strm_count).chr_id := p_chr_id;
      x_strm_tbl(l_strm_count).cle_id := p_cle_id;

      x_strm_tbl(l_strm_count).rule_information_category := 'LASLH';
      x_strm_tbl(l_strm_count).object1_id1 := l_strm_id;
      x_strm_tbl(l_strm_count).jtot_object1_code := 'OKL_STRMTYP';

      -- Now populate SLL for the same line
      l_strm_count := l_strm_count + 1;

      x_strm_tbl(l_strm_count).chr_id := p_chr_id;
      x_strm_tbl(l_strm_count).cle_id := p_cle_id;

      x_strm_tbl(l_strm_count).rule_information_category := 'LASLL';
      x_strm_tbl(l_strm_count).object1_id1 := p_frequency; --'M'; -- ???
      x_strm_tbl(l_strm_count).object1_id2 := '#';
      --nikshah 25-Nov-2008  bug # 6697542
      x_strm_tbl(l_strm_count).object2_id2 := '#';
      --nikshah 25-Nov-2008  bug # 6697542
      x_strm_tbl(l_strm_count).jtot_object1_code := 'OKL_TUOM';
      x_strm_tbl(l_strm_count).jtot_object2_code := 'OKL_STRMHDR';

      x_strm_tbl(l_strm_count).rule_information1 := 10;
      x_strm_tbl(l_strm_count).rule_information2 := fnd_date.date_to_canonical(p_start_date);
      x_strm_tbl(l_strm_count).rule_information3 := p_period;


      --
      -- Line Capital Amount :=
      --        Capital amount of this Line +
      --        Capital amount of corresponding LINK_ASSET_LINE (under FEE LINE)
      --
      get_fee_subline_cap_amount(
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_fin_line_id   => p_cle_id,
                                 x_fee_cap_amt   => l_fee_line_capital_amount
                                );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise rule_failed;
      END IF;

      l_line_capital_amount := NVL(p_fin_line_capital_amount,0) +
                               NVL(l_fee_line_capital_amount,0);

      x_strm_tbl(l_strm_count).rule_information6 :=
                        ROUND(((p_amount * l_line_capital_amount) /
                         p_tot_capital_amount),p_precision);


      --debug_message('Tot line: '||l_strm_count);
      --debug_message('gen, srtm_count 2 :'||l_strm_count);

      RETURN;

   EXCEPTION
      WHEN rule_failed THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_UNEXPECTED_ERROR,
                             'OKL_SQLCODE',
                             SQLCODE,
                             'OKL_SQLERRM',
                             SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                            );
         x_return_status := OKC_API.G_RET_STS_ERROR;
   END gen_line_rule;

------------------------------------------------------------------------------
-- PROCEDURE get_total_capital_amount
--
--  This procedure return total capital amount for Financial Asset
--  and Fee Top Line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_total_capital_amount(
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                      x_tot_capital_amount OUT NOCOPY NUMBER
                                     ) IS
   l_proc_name VARCHAR2(35) := 'GET_TOTAL_CAPITAL_AMOUNT';

   -- Total Capital amount from Financial Asset Top line
   CURSOR fin_cap_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT SUM(NVL(line.capital_amount,0))
   FROM   okl_k_lines_full_v line
   WHERE  line.dnz_chr_id = p_chr_id
   AND    EXISTS ( SELECT 'Y'
                   FROM   okc_line_styles_v style
                   WHERE  line.lse_id    = style.id
                   AND    style.lty_code = 'FREE_FORM1'
                  )
   -- added to handle abandon line
   AND    NOT EXISTS (
                      SELECT 'Y'
		      FROM   okc_statuses_v okcsts
		      WHERE  okcsts.code = line.sts_code
		      AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

   -- Total Capital amount from FEE Top Line
   CURSOR fee_cap_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
   SELECT SUM(NVL(line.capital_amount,0))
   FROM   okl_k_lines_full_v line,
          okc_line_styles_v  style,
          okc_k_items_v      item,
          okl_strmtyp_source_v stream
   WHERE  style.lty_code       = 'FEE'
   AND    line.dnz_chr_id      = p_chr_id
   AND    stream.capitalize_yn = 'Y'
   AND    line.lse_id          = style.id
   AND    line.id              = item.cle_id
   AND    item.object1_id1     = stream.id1
   -- added to handle abandon line
   AND    NOT EXISTS (
                      SELECT 'Y'
		      FROM   okc_statuses_v okcsts
		      WHERE  okcsts.code = line.sts_code
		      AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

   l_fin_amount   NUMBER;
   l_fee_amount   NUMBER;
   cap_failed     EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      OPEN fin_cap_csr(p_chr_id);
      FETCH fin_cap_csr INTO l_fin_amount;
      IF fin_cap_csr%NOTFOUND THEN
        RAISE cap_failed;
      END IF;
      CLOSE fin_cap_csr;

      OPEN fee_cap_csr(p_chr_id);
      FETCH fee_cap_csr INTO l_fee_amount;
      IF fee_cap_csr%NOTFOUND THEN
        l_fee_amount := 0;
      END IF;
      CLOSE fee_cap_csr;

      x_tot_capital_amount := NVL(l_fin_amount,0) + NVL(l_fee_amount,0);

      IF (x_tot_capital_amount = 0) THEN
         RAISE cap_failed;
      END IF;

      RETURN;

   EXCEPTION
      WHEN cap_failed THEN
         IF fin_cap_csr%ISOPEN THEN
            CLOSE fin_cap_csr;
         END IF;
         IF fee_cap_csr%ISOPEN THEN
            CLOSE fee_cap_csr;
         END IF;
         x_return_status := OKC_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_UNEXPECTED_ERROR,
                             'OKL_SQLCODE',
                             SQLCODE,
                             'OKL_SQLERRM',
                             SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                            );
        x_return_status := OKC_API.G_RET_STS_ERROR;
   END get_total_capital_amount;

------------------------------------------------------------------------------
-- PROCEDURE generate_line_payments
--
--  This procedure proportion-ed the payments accross Financial Asset Top Line
--  and Fee Top Line. It returns the information in a table. It does not
--  create any payment to the contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE generate_line_payments(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_payment_type  IN  VARCHAR2,
                          p_amount        IN  NUMBER,
                          p_start_date    IN  DATE,
                          p_period        IN  NUMBER,
                          p_frequency     IN  VARCHAR2,
                          x_strm_tbl      OUT NOCOPY okl_mass_rebook_pub.strm_lalevl_tbl_type
                         ) IS

  l_api_name           VARCHAR2(35)    := 'generate_line_payments';
  l_proc_name          VARCHAR2(35)    := 'generate_line_payments';
  l_api_version        CONSTANT NUMBER := 1;
  l_precision          FND_CURRENCIES.PRECISION%TYPE;

  CURSOR line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT okl.*
  FROM   okl_k_lines_full_v okl,
         okc_line_styles_b ols
  WHERE  okl.dnz_chr_id = p_chr_id
  AND    okl.lse_id     = ols.id
  AND    ols.lty_code   = 'FREE_FORM1'
  -- added to handle abandon line
  AND    NOT EXISTS (
                     SELECT 'Y'
	             FROM   okc_statuses_b okcsts
	             WHERE  okcsts.code = okl.sts_code
	             AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

  CURSOR payment_csr (p_strm_code VARCHAR2) IS
  SELECT 'Y'
  FROM   okl_strmtyp_source_v
  WHERE  code = p_strm_code;

  CURSOR freq_csr (p_freq_code VARCHAR2) IS
  SELECT 'Y'
  FROM   okl_time_units_v
  WHERE  id1 = p_freq_code;


  l_del_yn             VARCHAR2(1) := 'N';
  l_rgpv_tbl           OKL_RULE_PUB.rgpv_tbl_type;
  l_slh_rulv_tbl       OKL_RULE_PUB.rulv_tbl_type;
  l_sll_rulv_tbl       OKL_RULE_PUB.rulv_tbl_type;

  l_rg_count           NUMBER := 0;
  l_slh_rule_count     NUMBER := 0;
  l_sll_rule_count     NUMBER := 0;

  l_rgpv_del_rec       rgpv_rec_type;
  x_slh_rulv_tbl_out   rulv_tbl_type;
  x_sll_rulv_tbl_out   rulv_tbl_type;

  x_slh_count          NUMBER;
  x_sll_count          NUMBER;

  l_slh_rulv_del_tbl   rulv_tbl_type;
  l_sll_rulv_del_tbl   rulv_tbl_type;

  l_tot_capital_amount NUMBER := 0;
  l_rule_present       VARCHAR2(1);

  l_strm_count         NUMBER := 0;
  l_strm_tbl           okl_mass_rebook_pub.strm_lalevl_tbl_type;
  l_out_strm_tbl       okl_mass_rebook_pub.strm_lalevl_tbl_type;
  l_index              NUMBER := 0;

  l_exists             VARCHAR2(1) := 'N';

  BEGIN -- main process begins here
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --
      -- Validate input
      --
      IF (p_chr_id IS NULL) THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_INVALID_VALUE,
                    'COL_NAME',
                    'Contract Header ID'
                   );
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_exists := 'N';
      OPEN payment_csr(p_payment_type);
      FETCH payment_csr INTO l_exists;
      IF payment_csr%NOTFOUND THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_INVALID_VALUE,
                    'COL_NAME',
                    'Contract Header ID'
                   );
          CLOSE payment_csr;
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE payment_csr;

      l_exists := 'N';
      OPEN freq_csr(p_frequency);
      FETCH freq_csr INTO l_exists;
      IF freq_csr%NOTFOUND THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_INVALID_VALUE,
                    'COL_NAME',
                    'Payment frequency'
                   );
          CLOSE freq_csr;
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE freq_csr;

      IF (p_amount IS NULL) THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_INVALID_VALUE,
                    'COL_NAME',
                    'Payment amount'
                   );
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (p_start_date IS NULL) THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_INVALID_VALUE,
                    'COL_NAME',
                    'Payment start date'
                   );
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (p_period IS NULL) THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_INVALID_VALUE,
                    'COL_NAME',
                    'Payment period'
                   );
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      get_total_capital_amount(
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               p_chr_id             => p_chr_id,
                               x_tot_capital_amount => l_tot_capital_amount
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_CAPITAL_AMT_ERROR
                            );
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      get_currency_precision(
                             x_return_status => x_return_status,
                             p_chr_id        => p_chr_id,
                             x_precision     => l_precision
                            );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --debug_message('CAP :'||l_tot_capital_amount);
      FOR line_rec IN line_csr(p_chr_id)
      LOOP
         -- Apply Payment across Lines (Fin Asset and Fee Top Line)

         l_strm_count := x_strm_tbl.COUNT;

         gen_line_rule(
                          x_return_status           => x_return_status,
                          x_msg_count               => x_msg_count,
                          x_msg_data                => x_msg_data,
                          p_chr_id                  => p_chr_id,
                          p_cle_id                  => line_rec.id,
                          p_fin_line_capital_amount => line_rec.capital_amount,
                          p_tot_capital_amount      => l_tot_capital_amount,
                          p_precision               => l_precision,
                          p_payment_type            => p_payment_type,
                          p_amount                  => p_amount,
                          p_period                  => p_period,
                          p_start_date              => p_start_date,
                          p_frequency               => p_frequency,
                          p_strm_count              => l_strm_count,
                          x_strm_tbl                => l_strm_tbl
                         );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         -- Populate output steam table
         l_index := NVL(l_out_strm_tbl.LAST,0); -- get the last record

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_strm_count: '||l_index);
         END IF;

         FOR i IN 1..l_strm_tbl.COUNT
         LOOP
           l_index := l_index + 1;
           l_out_strm_tbl(l_index) := l_strm_tbl(i);
         END LOOP;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OK after assignment...');
         END IF;

      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_strm_count after : '||x_strm_tbl.COUNT);
      END IF;

      FOR i IN 1..l_out_strm_tbl.COUNT
      LOOP
        x_strm_tbl(i) := l_out_strm_tbl(i);
      END LOOP;

    --Call End Activity
     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);

EXCEPTION

      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END generate_line_payments;

END OKL_PAYMENT_SPLIT_PVT;

/
