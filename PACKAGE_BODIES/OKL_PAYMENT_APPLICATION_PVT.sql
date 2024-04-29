--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_APPLICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_APPLICATION_PVT" AS
/* $Header: OKLRPYAB.pls 120.13.12010000.2 2009/06/02 10:46:27 racheruv ship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_APPLICATION_PVT';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';

  -- Bug# 7661717 - Added Record type and table type
  TYPE line_csr_rec IS RECORD (id NUMBER, capital_amount NUMBER);
  TYPE line_csr_tbl IS TABLE OF line_csr_rec
                       INDEX BY BINARY_INTEGER;

   subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
   subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
   subtype rgpv_tbl_type IS OKL_RULE_PUB.rgpv_tbl_type;
   subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;


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
-- PROCEDURE check_line_rule
--
--  This procedure checks the presence of SLH and SLL at line level. Payment
--  application should not proceed if SLH and SLL are there at Line level already.
--  It returns the total such rule count, depending on which rest of the process
--  works.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE check_line_rule (
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                              p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                              x_rule_present  OUT NOCOPY VARCHAR2) IS
   l_proc_name VARCHAR2(35) := 'CHECK_LINE_RULE';

   CURSOR lrule_csr (p_chr_id  OKC_K_HEADERS_V.ID%TYPE,
                     p_strm_id OKC_RULES_V.OBJECT1_ID1%TYPE) IS
   SELECT 'Y'
   FROM   okc_rules_v rule,
          okc_rule_groups_v rg,
          okc_k_lines_b cle,
          okc_line_styles_b lsb
   WHERE  rule.dnz_chr_id           = p_chr_id
   AND    rule_information_category IN ('LASLH','LASLL')
   AND    rule.object1_id1          = p_strm_id
   AND    rg.cle_id                 IS NOT NULL
   AND    rule.rgp_id               = rg.id
   -- next few lines bug fix along with property tax payment changes
  AND    cle.lse_id     = lsb.id
  AND    lsb.lty_code   = 'FREE_FORM1'
  AND    cle.id         = rg.cle_id
   -- added to handle abandon line
   AND    NOT EXISTS (
                      SELECT 'Y'
              FROM   okc_statuses_v okcsts,
                 okc_k_lines_b line
              WHERE  line.id = rg.cle_id
              AND    line.sts_code = okcsts.code
              AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));


   lrule_failed EXCEPTION;
   l_flag VARCHAR2(1);

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     OPEN lrule_csr(p_chr_id,
                    p_stream_id);
     FETCH lrule_csr INTO l_flag;
     IF lrule_csr%NOTFOUND THEN
        x_rule_present := 'N';
     ELSE
        x_rule_present := 'Y';
     END IF;
     CLOSE lrule_csr;

     RETURN;
   EXCEPTION
     WHEN OTHERS THEN
        IF lrule_csr%ISOPEN THEN
           CLOSE lrule_csr;
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END check_line_rule;


------------------------------------------------------------------------------
-- PROCEDURE check_ro_subline_rule
--
--  This procedure checks the presence of SLH and SLL at sub-line line level.
--  for the given Rollover top line. Payment application should not proceed if
--  SLH and SLL are there at Sub-Line level already.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE check_ro_subline_rule (
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2,
                              p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                              p_cle_id        IN  OKL_K_LINES.ID%TYPE,
                              p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                              x_rule_present  OUT NOCOPY VARCHAR2) IS
   l_proc_name VARCHAR2(35) := 'CHECK_RO_SUBLINE_RULE';

   CURSOR l_ro_sl_rule_csr (p_chr_id  OKC_K_HEADERS_V.ID%TYPE,
                            p_cle_id  OKL_K_LINES.ID%TYPE,
                            p_strm_id OKC_RULES_V.OBJECT1_ID1%TYPE) IS

  SELECT 'Y'
   FROM   okc_rules_v rule,
          okc_rule_groups_v rg,
          okc_k_lines_b cleb, -- Top Line
          okc_k_lines_b cle,  -- Sub Line
          okc_line_styles_b lsb
   WHERE  rule.dnz_chr_id           = p_chr_id
   AND    rule_information_category IN ('LASLH','LASLL')
   AND    rule.object1_id1          = p_strm_id
   AND    cleb.id = p_cle_id    -- Top Line
   AND    cleb.id = cle.cle_id  -- Top line equals subline cle_id
   AND    rg.cle_id = cle.id    -- Equate with sub-line
   AND    rule.rgp_id               = rg.id
   AND    cle.lse_id     = lsb.id
   AND    lsb.lty_code   = 'LINK_FEE_ASSET'
   -- added to handle abandon line
   AND    NOT EXISTS (
                      SELECT 'Y'
              FROM   okc_statuses_v okcsts,
                 okc_k_lines_b line
              WHERE  line.id = rg.cle_id
              AND    line.sts_code = okcsts.code
              AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

   lrule_failed EXCEPTION;
   l_flag VARCHAR2(1);

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     OPEN l_ro_sl_rule_csr(p_chr_id, p_cle_id,
                    p_stream_id);
     FETCH l_ro_sl_rule_csr INTO l_flag;
     IF l_ro_sl_rule_csr%NOTFOUND THEN
        x_rule_present := 'N';
     ELSE
       IF (l_flag IS NOT NULL ) THEN
         x_rule_present := l_flag;
       ELSE
        x_rule_present := 'N';
       END IF;
     END IF;
     CLOSE l_ro_sl_rule_csr;

     RETURN;
   EXCEPTION
     WHEN OTHERS THEN
        IF l_ro_sl_rule_csr%ISOPEN THEN
           CLOSE l_ro_sl_rule_csr;
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        okl_api.set_message(
                            G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            'OKL_SQLCODE',
                            SQLCODE,
                            'OKL_SQLERRM',
                            SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                           );
   END check_ro_subline_rule;


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
   AND    stream.capitalize_yn    = 'Y'
   AND    okl1.id                 = item1.cle_id
   AND    okl2.id                 = okl1.cle_id
   AND    okl2.id                 = item2.cle_id
   AND    item2.object1_id1       = stream.id1;

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

PROCEDURE get_contract_rule_group(
                                  p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2,
                                  p_chr_id         IN  NUMBER,
                                  p_cle_id         IN  NUMBER,
                                  p_stream_id      IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                                  p_rgd_code       IN  VARCHAR2,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  x_rgpv_tbl       OUT NOCOPY rgpv_tbl_type,
                                  x_rg_count       OUT NOCOPY NUMBER) IS
l_No_RG_Found  BOOLEAN DEFAULT TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GET_CONTRACT_RULE_GROUP';
    l_api_version                  CONSTANT NUMBER  := 1.0;
---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_GROUPS_V
---------------------------------------------------------------------------
FUNCTION get_rgpv_tab (
    p_chr_id                     IN    NUMBER,
    p_cle_id                     IN    NUMBER,
    p_rgd_code                   IN    VARCHAR2,
    p_stream_id                  IN    NUMBER,
    x_rg_count                   OUT NOCOPY NUMBER
  ) RETURN rgpv_tbl_type IS
    CURSOR okc_rgpv_csr (p_chr_id     IN NUMBER,
                         p_cle_id     IN NUMBER,
                         p_dnz_chr_id IN NUMBER,
                         p_strm_id    IN OKC_RULES_V.OBJECT1_ID1%TYPE,
                         p_rgd_code   IN VARCHAR2) IS
    SELECT
            rg.ID,
            rg.OBJECT_VERSION_NUMBER,
            rg.SFWT_FLAG,
            rg.RGD_CODE,
            rg.SAT_CODE,
            rg.RGP_TYPE,
            rg.CLE_ID,
            rg.CHR_ID,
            rg.DNZ_CHR_ID,
            rg.PARENT_RGP_ID,
            rg.COMMENTS,
            rg.ATTRIBUTE_CATEGORY,
            rg.ATTRIBUTE1,
            rg.ATTRIBUTE2,
            rg.ATTRIBUTE3,
            rg.ATTRIBUTE4,
            rg.ATTRIBUTE5,
            rg.ATTRIBUTE6,
            rg.ATTRIBUTE7,
            rg.ATTRIBUTE8,
            rg.ATTRIBUTE9,
            rg.ATTRIBUTE10,
            rg.ATTRIBUTE11,
            rg.ATTRIBUTE12,
            rg.ATTRIBUTE13,
            rg.ATTRIBUTE14,
            rg.ATTRIBUTE15,
            rg.CREATED_BY,
            rg.CREATION_DATE,
            rg.LAST_UPDATED_BY,
            rg.LAST_UPDATE_DATE,
            rg.LAST_UPDATE_LOGIN
     FROM   Okc_Rule_Groups_V rg,
            Okc_Rules_V rule
     WHERE  NVL(rg.chr_id,-9999)     = p_chr_id
     --AND    NVL(rg.cle_id,-9999)     = p_cle_id
     --AND    rg.dnz_chr_id            = DECODE(p_chr_id,-9999,rg.dnz_chr_id,p_dnz_chr_id)
     AND    rg.dnz_chr_id            = p_chr_id
     AND    rule.object1_id1         = p_strm_id
     AND    rgd_code = DECODE(p_rgd_code,NULL,rgd_code,p_rgd_code)
     AND    rule.rgp_id = rg.id;


    l_rgpv_rec                 rgpv_rec_type;
    l_rgpv_tab                 rgpv_tbl_type;
    i                          NUMBER DEFAULT 0;
    l_chr_id     NUMBER;
    l_cle_id     NUMBER;
    l_dnz_chr_id NUMBER;

  BEGIN
    IF p_chr_id IS NULL AND p_cle_id IS NOT NULL THEN
       l_chr_id     := -9999;
       l_cle_id     := p_cle_id;
       l_dnz_chr_id := -9999;
    ELSIF p_chr_id IS NULL AND p_cle_id IS NULL THEN
       l_chr_id     := -9999;
       l_cle_id     := -9999;
       l_dnz_chr_id := -9999;
    ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NULL THEN
       l_chr_id := p_chr_id;
       l_cle_id := -9999;
       l_dnz_chr_id := p_chr_id;
    ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NOT NULL THEN
       l_chr_id     := -9999;
       l_cle_id     := p_cle_id;
       l_dnz_chr_id := p_chr_id;
    END IF;

    -- Get current database values
    OPEN okc_rgpv_csr (l_chr_id,
                       l_cle_id,
                       l_dnz_chr_id,
                       p_stream_id,
                       p_rgd_code);
    LOOP
       FETCH okc_rgpv_csr INTO
              l_rgpv_rec.ID,
              l_rgpv_rec.OBJECT_VERSION_NUMBER,
              l_rgpv_rec.SFWT_FLAG,
              l_rgpv_rec.RGD_CODE,
              l_rgpv_rec.SAT_CODE,
              l_rgpv_rec.RGP_TYPE,
              l_rgpv_rec.CLE_ID,
              l_rgpv_rec.CHR_ID,
              l_rgpv_rec.DNZ_CHR_ID,
              l_rgpv_rec.PARENT_RGP_ID,
              l_rgpv_rec.COMMENTS,
              l_rgpv_rec.ATTRIBUTE_CATEGORY,
              l_rgpv_rec.ATTRIBUTE1,
              l_rgpv_rec.ATTRIBUTE2,
              l_rgpv_rec.ATTRIBUTE3,
              l_rgpv_rec.ATTRIBUTE4,
              l_rgpv_rec.ATTRIBUTE5,
              l_rgpv_rec.ATTRIBUTE6,
              l_rgpv_rec.ATTRIBUTE7,
              l_rgpv_rec.ATTRIBUTE8,
              l_rgpv_rec.ATTRIBUTE9,
              l_rgpv_rec.ATTRIBUTE10,
              l_rgpv_rec.ATTRIBUTE11,
              l_rgpv_rec.ATTRIBUTE12,
              l_rgpv_rec.ATTRIBUTE13,
              l_rgpv_rec.ATTRIBUTE14,
              l_rgpv_rec.ATTRIBUTE15,
              l_rgpv_rec.CREATED_BY,
              l_rgpv_rec.CREATION_DATE,
              l_rgpv_rec.LAST_UPDATED_BY,
              l_rgpv_rec.LAST_UPDATE_DATE,
              l_rgpv_rec.LAST_UPDATE_LOGIN;
    EXIT WHEN okc_rgpv_csr%NOTFOUND;
        i := okc_rgpv_csr%RowCount;
        l_rgpv_tab(i) := l_rgpv_rec;
    END LOOP;
    CLOSE okc_rgpv_csr;
    x_rg_count      := i;
    RETURN(l_rgpv_tab);
END get_rgpv_tab;

BEGIN

    x_rgpv_tbl := get_rgpv_tab(p_chr_id         => p_chr_id,
                               p_cle_id         => p_cle_id,
                               p_rgd_code       => p_rgd_code,
                               p_stream_id      => p_stream_id,
                               x_rg_count       => x_rg_count);
    EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

END get_contract_rule_group;

PROCEDURE get_ro_fee_topln_rg(
                                  p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2,
                                  p_chr_id         IN  NUMBER,
                                  p_cle_id         IN  NUMBER,
                                  p_stream_id      IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                                  p_rgd_code       IN  VARCHAR2,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  x_rgpv_tbl       OUT NOCOPY rgpv_tbl_type,
                                  x_rg_count       OUT NOCOPY NUMBER) IS
l_No_RG_Found  BOOLEAN DEFAULT TRUE;
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GET_RO_FEE_TOPLN_RG';
    l_api_version                  CONSTANT NUMBER  := 1.0;
---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_GROUPS_V
---------------------------------------------------------------------------
FUNCTION get_rgpv_tab (
    p_chr_id                     IN    NUMBER,
    p_cle_id                     IN    NUMBER,
    p_rgd_code                   IN    VARCHAR2,
    p_stream_id                  IN    NUMBER,
    x_rg_count                   OUT NOCOPY NUMBER
  ) RETURN rgpv_tbl_type IS
    CURSOR okc_rgpv_csr (p_chr_id     IN NUMBER,
                         p_cle_id     IN NUMBER,
                         p_strm_id    IN OKC_RULES_V.OBJECT1_ID1%TYPE,
                         p_rgd_code   IN VARCHAR2) IS
    SELECT
            rg.ID,
            rg.OBJECT_VERSION_NUMBER,
            rg.SFWT_FLAG,
            rg.RGD_CODE,
            rg.SAT_CODE,
            rg.RGP_TYPE,
            rg.CLE_ID,
            rg.CHR_ID,
            rg.DNZ_CHR_ID,
            rg.PARENT_RGP_ID,
            rg.COMMENTS,
            rg.ATTRIBUTE_CATEGORY,
            rg.ATTRIBUTE1,
            rg.ATTRIBUTE2,
            rg.ATTRIBUTE3,
            rg.ATTRIBUTE4,
            rg.ATTRIBUTE5,
            rg.ATTRIBUTE6,
            rg.ATTRIBUTE7,
            rg.ATTRIBUTE8,
            rg.ATTRIBUTE9,
            rg.ATTRIBUTE10,
            rg.ATTRIBUTE11,
            rg.ATTRIBUTE12,
            rg.ATTRIBUTE13,
            rg.ATTRIBUTE14,
            rg.ATTRIBUTE15,
            rg.CREATED_BY,
            rg.CREATION_DATE,
            rg.LAST_UPDATED_BY,
            rg.LAST_UPDATE_DATE,
            rg.LAST_UPDATE_LOGIN
     FROM   Okc_Rule_Groups_V rg,
            Okc_Rules_V rule
     WHERE  rg.dnz_chr_id     = p_chr_id
     AND   rg.cle_id          = p_cle_id
     AND    rule.object1_id1  = to_char(p_strm_id)
     AND    rg.rgd_code       = DECODE(p_rgd_code,NULL,rgd_code,p_rgd_code)
     AND    rule.rgp_id       = rg.id;


    l_rgpv_rec                 rgpv_rec_type;
    l_rgpv_tab                 rgpv_tbl_type;
    i                          NUMBER DEFAULT 0;
    l_chr_id     NUMBER;
    l_cle_id     NUMBER;
    l_dnz_chr_id NUMBER;

  BEGIN
    IF p_chr_id IS NULL AND p_cle_id IS NOT NULL THEN
       l_chr_id     := -9999;
       l_cle_id     := p_cle_id;
       l_dnz_chr_id := -9999;
    ELSIF p_chr_id IS NULL AND p_cle_id IS NULL THEN
       l_chr_id     := -9999;
       l_cle_id     := -9999;
       l_dnz_chr_id := -9999;
    ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NULL THEN
       l_chr_id := p_chr_id;
       l_cle_id := -9999;
       l_dnz_chr_id := p_chr_id;
    ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NOT NULL THEN
       l_chr_id     := -9999;
       l_cle_id     := p_cle_id;
       l_dnz_chr_id := p_chr_id;
    END IF;

    -- Get current database values
    OPEN okc_rgpv_csr (l_dnz_chr_id,
                       l_cle_id,
                       p_stream_id,
                       p_rgd_code);
    LOOP
       FETCH okc_rgpv_csr INTO
              l_rgpv_rec.ID,
              l_rgpv_rec.OBJECT_VERSION_NUMBER,
              l_rgpv_rec.SFWT_FLAG,
              l_rgpv_rec.RGD_CODE,
              l_rgpv_rec.SAT_CODE,
              l_rgpv_rec.RGP_TYPE,
              l_rgpv_rec.CLE_ID,
              l_rgpv_rec.CHR_ID,
              l_rgpv_rec.DNZ_CHR_ID,
              l_rgpv_rec.PARENT_RGP_ID,
              l_rgpv_rec.COMMENTS,
              l_rgpv_rec.ATTRIBUTE_CATEGORY,
              l_rgpv_rec.ATTRIBUTE1,
              l_rgpv_rec.ATTRIBUTE2,
              l_rgpv_rec.ATTRIBUTE3,
              l_rgpv_rec.ATTRIBUTE4,
              l_rgpv_rec.ATTRIBUTE5,
              l_rgpv_rec.ATTRIBUTE6,
              l_rgpv_rec.ATTRIBUTE7,
              l_rgpv_rec.ATTRIBUTE8,
              l_rgpv_rec.ATTRIBUTE9,
              l_rgpv_rec.ATTRIBUTE10,
              l_rgpv_rec.ATTRIBUTE11,
              l_rgpv_rec.ATTRIBUTE12,
              l_rgpv_rec.ATTRIBUTE13,
              l_rgpv_rec.ATTRIBUTE14,
              l_rgpv_rec.ATTRIBUTE15,
              l_rgpv_rec.CREATED_BY,
              l_rgpv_rec.CREATION_DATE,
              l_rgpv_rec.LAST_UPDATED_BY,
              l_rgpv_rec.LAST_UPDATE_DATE,
              l_rgpv_rec.LAST_UPDATE_LOGIN;
    EXIT WHEN okc_rgpv_csr%NOTFOUND;
        i := okc_rgpv_csr%RowCount;
        l_rgpv_tab(i) := l_rgpv_rec;
    END LOOP;
    CLOSE okc_rgpv_csr;
    x_rg_count      := i;
    RETURN(l_rgpv_tab);
END get_rgpv_tab;

BEGIN

    x_rgpv_tbl := get_rgpv_tab(p_chr_id         => p_chr_id,
                               p_cle_id         => p_cle_id,
                               p_rgd_code       => p_rgd_code,
                               p_stream_id      => p_stream_id,
                               x_rg_count       => x_rg_count);
    EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

END get_ro_fee_topln_rg;


PROCEDURE get_slh_rules(
                        p_rgpv_rec       IN  rgpv_rec_type,
                        p_rdf_code       IN  VARCHAR2,
                        p_stream_id      IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        x_rulv_tbl       OUT NOCOPY rulv_tbl_type,
                        x_rule_count     OUT NOCOPY NUMBER ) IS


  l_return_status                  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_api_name                       CONSTANT VARCHAR2(30) := 'GET_SLH_RULES';
  l_api_version                    CONSTANT NUMBER  := 1.0;
---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULES_V
---------------------------------------------------------------------------
  FUNCTION get_rulv_tab (
    p_rgpv_rec                     IN  rgpv_rec_type,
    p_rdf_code                     IN  VARCHAR2,
    p_stream_id                    IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
    x_Rule_Count                   OUT NOCOPY NUMBER
  ) RETURN rulv_tbl_type IS
    CURSOR okc_rulv_csr (p_rgp_id IN NUMBER,
                         p_strm_id OKC_RULES_V.OBJECT1_ID1%TYPE,
                         p_rdf_code IN VARCHAR2) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            OBJECT1_ID1,
            OBJECT2_ID1,
            OBJECT3_ID1,
            OBJECT1_ID2,
            OBJECT2_ID2,
            OBJECT3_ID2,
            JTOT_OBJECT1_CODE,
            JTOT_OBJECT2_CODE,
            JTOT_OBJECT3_CODE,
            DNZ_CHR_ID,
            RGP_ID,
            PRIORITY,
            STD_TEMPLATE_YN,
            COMMENTS,
            WARN_YN,
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
            --TEXT,
            RULE_INFORMATION_CATEGORY,
            RULE_INFORMATION1,
            RULE_INFORMATION2,
            RULE_INFORMATION3,
            RULE_INFORMATION4,
            RULE_INFORMATION5,
            RULE_INFORMATION6,
            RULE_INFORMATION7,
            RULE_INFORMATION8,
            RULE_INFORMATION9,
            RULE_INFORMATION10,
            RULE_INFORMATION11,
            RULE_INFORMATION12,
            RULE_INFORMATION13,
            RULE_INFORMATION14,
            RULE_INFORMATION15,
            TEMPLATE_YN,
            ans_set_jtot_object_code,
            ans_set_jtot_object_id1,
            ans_set_jtot_object_id2,
            DISPLAY_SEQUENCE
     FROM Okc_Rules_V
     WHERE okc_rules_v.rgp_id    = p_rgp_id
     AND   object1_id1           = p_strm_id
     AND   RULE_INFORMATION_CATEGORY = DECODE(p_rdf_code,NULL,RULE_INFORMATION_CATEGORY,p_rdf_code);
     l_rulv_rec                  rulv_rec_type;
     l_rulv_tab                  rulv_tbl_type;
     i                           NUMBER DEFAULT 0;
  BEGIN

    -- Get current database values
    OPEN okc_rulv_csr (p_rgpv_rec.id,
                       p_stream_id,
                       p_rdf_code);
    LOOP
    FETCH okc_rulv_csr INTO
                l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              --l_rulv_rec.TEXT,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ans_set_jtot_object_code,
              l_rulv_rec.ans_set_jtot_object_id1,
              l_rulv_rec.ans_set_jtot_object_id2,
              l_rulv_rec.DISPLAY_SEQUENCE ;
    EXIT WHEN okc_rulv_csr%NOTFOUND;
      i := okc_rulv_csr%RowCount;
      l_rulv_tab(i) := l_rulv_rec;
    END LOOP;
    CLOSE okc_rulv_csr;
    x_rule_count := i;
    RETURN(l_rulv_tab);
  END get_rulv_tab;
BEGIN

   x_rulv_tbl := get_rulv_tab(p_rgpv_rec     => p_rgpv_rec,
                              p_rdf_code     => p_rdf_code,
                              p_stream_id    => p_stream_id,
                              x_Rule_Count   => x_rule_Count);
    EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => g_pkg_name,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => g_api_type);

END get_slh_rules;

------------------------------------------------------------------------------
-- PROCEDURE get_sll_rules
--
--  This procedure retrieves all SLL related to given SLH rule under LALEVL Category
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_sll_rules(
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           p_rgpv_rec       IN  rgpv_rec_type,
                           p_rdf_code       IN  VARCHAR2,
                           p_slh_id         IN  NUMBER,
                           x_rulv_tbl       OUT NOCOPY rulv_tbl_type,
                           x_rule_count     OUT NOCOPY NUMBER
                          ) IS
    CURSOR okc_rulv_csr (p_rgp_id IN NUMBER,
                         p_rdf_code IN VARCHAR2,
                         p_slh_id   IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            OBJECT1_ID1,
            OBJECT2_ID1,
            OBJECT3_ID1,
            OBJECT1_ID2,
            OBJECT2_ID2,
            OBJECT3_ID2,
            JTOT_OBJECT1_CODE,
            JTOT_OBJECT2_CODE,
            JTOT_OBJECT3_CODE,
            DNZ_CHR_ID,
            RGP_ID,
            PRIORITY,
            STD_TEMPLATE_YN,
            COMMENTS,
            WARN_YN,
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
            --TEXT,
            RULE_INFORMATION_CATEGORY,
            RULE_INFORMATION1,
            RULE_INFORMATION2,
            RULE_INFORMATION3,
            RULE_INFORMATION4,
            RULE_INFORMATION5,
            RULE_INFORMATION6,
            RULE_INFORMATION7,
            RULE_INFORMATION8,
            RULE_INFORMATION9,
            RULE_INFORMATION10,
            RULE_INFORMATION11,
            RULE_INFORMATION12,
            RULE_INFORMATION13,
            RULE_INFORMATION14,
            RULE_INFORMATION15,
            TEMPLATE_YN,
            ans_set_jtot_object_code,
            ans_set_jtot_object_id1,
            ans_set_jtot_object_id2,
            DISPLAY_SEQUENCE
     FROM Okc_Rules_V
     WHERE okc_rules_v.rgp_id      = p_rgp_id
     AND   okc_rules_v.object2_id1 = p_slh_id
     AND   RULE_INFORMATION_CATEGORY = decode(p_rdf_code,null,RULE_INFORMATION_CATEGORY,p_rdf_code);

     l_rulv_rec                  rulv_rec_type;
     i                           NUMBER default 0;
     l_proc_name                 VARCHAR2(35) := 'GET_SLL_RULES';
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    -- Get current database values
    OPEN okc_rulv_csr (p_rgpv_rec.id,
                       p_rdf_code,
                       p_slh_id);
    LOOP
    FETCH okc_rulv_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              --l_rulv_rec.TEXT,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ans_set_jtot_object_code,
              l_rulv_rec.ans_set_jtot_object_id1,
              l_rulv_rec.ans_set_jtot_object_id2,
              l_rulv_rec.DISPLAY_SEQUENCE ;
    EXIT When okc_rulv_csr%NOTFOUND;
      i := okc_rulv_csr%RowCount;
      x_rulv_tbl(i) := l_rulv_rec;
    END LOOP;
    CLOSE okc_rulv_csr;
    x_rule_count := i;

    RETURN;

   END get_sll_rules;

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
-- PROCEDURE create_line_rule
--
--  This procedure creates line rule (SLH, SLL) after applying the payment
--  amount. Calculation = (Rule Payment Amount * Line Capital Amount) /
--                         Total Capital Amount
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE create_line_rule(
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2,
                               p_chr_id                  IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_cle_id                  IN  NUMBER,
                               p_stream_id               IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                               p_fin_line_capital_amount IN  NUMBER,
                               p_tot_capital_amount      IN  NUMBER,
                               p_precision               IN  FND_CURRENCIES.PRECISION%TYPE,
                               p_rgpv_tbl                IN  rgpv_tbl_type,
                               p_rg_count                IN  NUMBER,
                               x_slh_rulv_tbl_out        OUT NOCOPY rulv_tbl_type,
                               x_slh_count               OUT NOCOPY NUMBER,
                               x_sll_rulv_tbl_out        OUT NOCOPY rulv_tbl_type,
                               x_sll_count               OUT NOCOPY NUMBER
                              ) IS
   l_proc_name VARCHAR2(35) := 'CREATE_LINE_RULE';

   CURSOR rg_csr (p_chr_id NUMBER,
                  p_cle_id NUMBER) IS
   SELECT ID
   FROM   okc_rule_groups_v
   WHERE  dnz_chr_id = p_chr_id
   AND    cle_id     = p_cle_id
   AND    rgd_code   = 'LALEVL';

   CURSOR fee_type_csr (p_chr_id NUMBER,
                  p_cle_id NUMBER) IS
   SELECT FEE_TYPE
   FROM okc_k_lines_b CLEB, okl_k_lines KLE
   WHERE CLEB.dnz_chr_id = p_chr_id
   AND KLE.ID = p_cle_id
   AND KLE.ID = CLEB.ID;

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
   l_fee_type          OKL_K_LINES.FEE_TYPE%TYPE;
   rule_failed         EXCEPTION;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- Check to see presence of LELEVL Rule Group at line
      l_rgp_id := NULL;
      OPEN rg_csr(p_chr_id,
                  p_cle_id);
      FETCH rg_csr INTO l_rgp_id;
      CLOSE rg_csr;

      -- Get the fee type for the given contract and line
      l_fee_type := NULL;
      OPEN fee_type_csr(p_chr_id,
                  p_cle_id);
      FETCH fee_type_csr INTO l_fee_type;
      CLOSE fee_type_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'RGP at Line: '||l_rgp_id);
      END IF;

      IF (l_rgp_id IS NULL) THEN
         -- Create Rule Group for LALEVL
         l_rgpv_rec            := p_rgpv_tbl(1);
         l_rgpv_rec.chr_id     := NULL;
         l_rgpv_rec.cle_id     := p_cle_id;
         l_rgpv_rec.dnz_chr_id := p_chr_id;

         OKL_RULE_PUB.create_rule_group(
                                        p_api_version     => 1.0,
                                        p_init_msg_list   => OKC_API.G_FALSE,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_rgpv_rec        => l_rgpv_rec,
                                        x_rgpv_rec        => x_new_rgpv_rec
                                       );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             x_return_status := OKC_API.G_RET_STS_ERROR;
             raise rule_failed;
         END IF;
      ELSE
         x_new_rgpv_rec.id := l_rgp_id;
      END IF;

      -- Get SLH Rule from Header
      get_slh_rules(
                    p_rgpv_rec       => p_rgpv_tbl(1),
                    p_rdf_code       => 'LASLH',
                    p_stream_id      => p_stream_id,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    x_rulv_tbl       => x_slh_rulv_tbl,
                    x_rule_count     => x_slh_rule_count
                   );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE rule_failed;
      END IF;

      IF (x_slh_rule_count = 0) THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_NO_HEADER_PAYMENT
                            );
         RAISE rule_failed;
      END IF;

      x_slh_rulv_tbl_out := x_slh_rulv_tbl;
      x_slh_count        := x_slh_rule_count;

      FOR i IN 1..x_slh_rule_count
      LOOP
         l_slh_rulv_rec        := x_slh_rulv_tbl(i);
         l_slh_rulv_rec.rgp_id := x_new_rgpv_rec.id;
         OKL_RULE_PUB.create_rule(
                                  p_api_version     => 1.0,
                                  p_init_msg_list   => OKC_API.G_FALSE,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count,
                                  x_msg_data        => x_msg_data,
                                  p_rulv_rec        => l_slh_rulv_rec,
                                  x_rulv_rec        => x_new_slh_rulv_rec
                                 );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             x_return_status := OKC_API.G_RET_STS_ERROR;
             raise rule_failed;
         END IF;

         --okl_rule_apis_pvt.Get_Contract_Rules(
         -- Get SLL Rules from Header for a SLH
         get_sll_rules(
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_rgpv_rec       => p_rgpv_tbl(1),
                       p_rdf_code       => 'LASLL',
                       p_slh_id         => x_slh_rulv_tbl(i).id,
                       x_rulv_tbl       => x_sll_rulv_tbl,
                       x_rule_count     => x_sll_rule_count
                      );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE rule_failed;
         END IF;

         IF (x_sll_rule_count = 0) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_NO_HEADER_PAYMENT
                               );
            RAISE rule_failed;
         END IF;

         x_sll_rulv_tbl_out := x_sll_rulv_tbl;
         x_sll_count        := x_sll_rule_count;

         -- Create a SLL rule under SLH created above
         FOR i IN 1..x_sll_rule_count
         LOOP

            --
            -- Line Capital Amount :=
            --        Capital amount of this Line +
            --        Capital amount of corresponding LINK_ASSET_LINE (under FEE LINE)
            --
            --  Manu 9-Sep-2004 Calcualte Cap Amount if it is not Rollover fee.
            IF (l_fee_type <> 'ROLLOVER') THEN
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
            END IF;

            l_line_capital_amount := NVL(p_fin_line_capital_amount,0) +
                                     NVL(l_fee_line_capital_amount,0);

            l_sll_rulv_rec        := x_sll_rulv_tbl(i);
            l_sll_rulv_rec.rgp_id := x_new_rgpv_rec.id;

            --
            -- Payment Stub logic
            --
            IF (l_sll_rulv_rec.rule_information6 IS NOT NULL) THEN
               l_sll_rulv_rec.rule_information6 :=
                              ROUND(((l_sll_rulv_rec.rule_information6 * l_line_capital_amount) /
                               p_tot_capital_amount),p_precision);
            END IF;

            IF (l_sll_rulv_rec.rule_information8 IS NOT NULL) THEN
               l_sll_rulv_rec.rule_information8 :=
                              ROUND(((l_sll_rulv_rec.rule_information8 * l_line_capital_amount) /
                               p_tot_capital_amount),p_precision);
            END IF;
            l_sll_rulv_rec.object2_id1 := x_new_slh_rulv_rec.id;

            OKL_RULE_PUB.create_rule(
                                     p_api_version     => 1.0,
                                     p_init_msg_list   => OKC_API.G_FALSE,
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_rulv_rec        => l_sll_rulv_rec,
                                     x_rulv_rec        => x_rulv_rec
                                    );
               IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                   x_return_status := OKC_API.G_RET_STS_ERROR;
                   raise rule_failed;
               END IF;
         END LOOP; -- SLL

      END LOOP; -- SLH

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
   END create_line_rule;


------------------------------------------------------------------------------
-- PROCEDURE check_header_rule
--
--  This procedure retreives Header level rule groups and associated rule
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE check_header_rule(
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               p_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_stream_id      IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                               x_rgpv_tbl       OUT NOCOPY rgpv_tbl_type,
                               x_rg_count       OUT NOCOPY NUMBER
                              ) IS
   l_proc_name VARCHAR2(35) := 'CHECK_HEADER_RULE';
   check_header_failed EXCEPTION;
   l_rgpv_rec          OKL_RULE_PUB.rgpv_rec_type;
   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      get_contract_rule_group(
                              p_api_version    => 1.0,
                              p_init_msg_list  => OKL_API.G_FALSE,
                              p_chr_id         => p_chr_id,
                              p_cle_id         => NULL,
                              p_stream_id      => p_stream_id,
                              p_rgd_code       => 'LALEVL',
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              x_rgpv_tbl       => x_rgpv_tbl,
                              x_rg_count       => x_rg_count
                             );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE check_header_failed;
      END IF;

      RETURN;

   EXCEPTION
      WHEN check_header_failed THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_UNEXPECTED_ERROR,
                             'OKL_SQLCODE',
                             SQLCODE,
                             'OKL_SQLERRM',
                             SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                            );
         x_return_status := OKC_API.G_RET_STS_ERROR;
   END check_header_rule;

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


   /* Cursor fee_cap_csr is Not required, Bug: 4598703
    * Capital amt at Asset is updated
    * with Capitalized Fee line amoutn change
   -- Total Capital amount from FEE Top Line
   */

   l_fin_amount   NUMBER;
   -- l_fee_amount   NUMBER;
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

      x_tot_capital_amount := NVL(l_fin_amount,0);

      IF (x_tot_capital_amount = 0) THEN
         RAISE cap_failed;
      END IF;

      RETURN;

   EXCEPTION
      WHEN cap_failed THEN
         IF fin_cap_csr%ISOPEN THEN
            CLOSE fin_cap_csr;
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


     -- Bug# 7661717 - Added - Start
------------------------------------------------------------------------------
-- PROCEDURE split_payments
--
--  This procedure creates line rule (SLH, SLL) after applying the payment
--  amount. Calculation = (Rule Payment Amount * Line Capital Amount) /
--                         Total Capital Amount
--
------------------------------------------------------------------------------
   PROCEDURE split_payments(
                               p_api_version   IN  NUMBER,
                               p_init_msg_list IN  VARCHAR2,
                               p_chr_id                  IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_line_csr_tbl            IN  line_csr_tbl,
                               p_stream_id               IN  OKC_RULES_V.OBJECT1_ID1%TYPE,
                               p_tot_capital_amount      IN  NUMBER,
                               p_precision               IN  FND_CURRENCIES.PRECISION%TYPE,
                               p_rgpv_tbl                IN  rgpv_tbl_type,
                               x_slh_rulv_tbl_out        OUT NOCOPY rulv_tbl_type,
                               x_slh_count               OUT NOCOPY NUMBER,
                               x_sll_rulv_tbl_out        OUT NOCOPY rulv_tbl_type,
                               x_sll_count               OUT NOCOPY NUMBER,
                               x_return_status           OUT NOCOPY VARCHAR2,
                               x_msg_count               OUT NOCOPY NUMBER,
                               x_msg_data                OUT NOCOPY VARCHAR2
                              ) IS
   l_api_name VARCHAR2(35) := 'split_payments';

   CURSOR rg_csr (p_chr_id NUMBER,
                  p_cle_id NUMBER) IS
   SELECT ID
   FROM   okc_rule_groups_v
   WHERE  dnz_chr_id = p_chr_id
   AND    cle_id     = p_cle_id
   AND    rgd_code   = 'LALEVL';

   CURSOR fee_type_csr (p_chr_id NUMBER,
                  p_cle_id NUMBER) IS
   SELECT FEE_TYPE
   FROM okc_k_lines_b CLEB, okl_k_lines KLE
   WHERE CLEB.dnz_chr_id = p_chr_id
   AND KLE.ID = p_cle_id
   AND KLE.ID = CLEB.ID;

  TYPE kle_map_tbl IS TABLE OF NUMBER
                       INDEX BY BINARY_INTEGER;

  l_rgpv_rec          rgpv_rec_type;
  l_slh_rulv_rec      rulv_rec_type;
  x_slh_rulv_tbl      OKL_RULE_PUB.rulv_tbl_type;
  l_sll_rulv_rec      rulv_rec_type;
  l_sll_rulv_tbl      OKL_RULE_PUB.rulv_tbl_type;
  x_sll_rulv_tbl      rulv_tbl_type;
  x_sll_rulv_new_tbl  rulv_tbl_type;
  l_kle_rgp_cache_tbl kle_map_tbl;
  l_kle_slh_cache_tbl kle_map_tbl;

  x_new_rgpv_rec      rgpv_rec_type;
  x_new_slh_rulv_rec  rulv_rec_type;
  l_line_csr_tbl      line_csr_tbl DEFAULT p_line_csr_tbl;

  l_return_status VARCHAR2(1);
  x_slh_rule_count    NUMBER;
  x_sll_rule_count    NUMBER;
  l_rgp_id            NUMBER;
  l_adj_index NUMBER;
  sll_indx    NUMBER DEFAULT 0;
  l_adjustment NUMBER DEFAULT 0;
  l_slh_created BOOLEAN DEFAULT FALSE;
  l_khr_payment NUMBER;
  l_line_capital_amount     NUMBER;
  l_asset_pymnt_total NUMBER;
  rule_failed         EXCEPTION;

BEGIN

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,p_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
     ---------------------------------------
	 -- Get SLH - payment header information
     ---------------------------------------
     get_slh_rules(
                    p_rgpv_rec       => p_rgpv_tbl(1),
                    p_rdf_code       => 'LASLH',
                    p_stream_id      => p_stream_id,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    x_rulv_tbl       => x_slh_rulv_tbl,
                    x_rule_count     => x_slh_rule_count
                   );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE rule_failed;
      END IF;

      IF (x_slh_rule_count = 0) THEN
         OKL_API.set_message(
                             G_APP_NAME,
                             G_NO_HEADER_PAYMENT
                            );
         RAISE rule_failed;
      END IF;

      x_slh_rulv_tbl_out := x_slh_rulv_tbl;
      x_slh_count        := x_slh_rule_count;

     ---------------------------------------
      -- Loop through each SLH record
     ---------------------------------------
      FOR i IN 1..x_slh_rule_count
      LOOP
        x_sll_rulv_tbl.DELETE;
        ---------------------------------------
        -- Get SLL Rules from Header for a SLH
        ---------------------------------------
         get_sll_rules(
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_rgpv_rec       => p_rgpv_tbl(1),
                       p_rdf_code       => 'LASLL',
                       p_slh_id         => x_slh_rulv_tbl(i).id,
                       x_rulv_tbl       => x_sll_rulv_tbl,
                       x_rule_count     => x_sll_rule_count
                      );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE rule_failed;
         END IF;

         IF (x_sll_rule_count = 0) THEN
            OKL_API.set_message(
                                G_APP_NAME,
                                G_NO_HEADER_PAYMENT
                               );
            RAISE rule_failed;
         END IF;

         x_sll_rulv_tbl_out := x_sll_rulv_tbl;
         x_sll_count        := x_sll_rule_count;

         -- Delete the SLH cache before start of processing new SLLs
         l_kle_slh_cache_tbl.DELETE;

         ---------------------------------------
         -- Loop through each SLL record
         ---------------------------------------
         FOR j IN 1..x_sll_rule_count
         LOOP
           l_sll_rulv_rec := x_sll_rulv_tbl(j);

           ---------------------------------------
           -- Note down contract level payment (be it stub or be it periodic payment)
           ---------------------------------------
            IF (l_sll_rulv_rec.rule_information6 IS NOT NULL) THEN
               l_khr_payment := l_sll_rulv_rec.rule_information6;
            END IF;

            IF (l_sll_rulv_rec.rule_information8 IS NOT NULL) THEN
               l_khr_payment := l_sll_rulv_rec.rule_information8;
            END IF;

           -- Initialize total of asset level payments to 0
           l_asset_pymnt_total := 0;
           l_adjustment := 0;
           l_adj_index := 1;
           sll_indx := 0;
           l_sll_rulv_tbl.DELETE;
           ---------------------------------------
           -- Loop through each asset
           ---------------------------------------
           FOR k IN l_line_csr_tbl.FIRST .. l_line_csr_tbl.LAST
           LOOP
             ---------------------------------------
             -- Create Rule Group once per asset if not present already
             ---------------------------------------
             -- Check to see presence of LELEVL Rule Group at line
             IF k > l_kle_rgp_cache_tbl.COUNT THEN
               l_rgp_id := NULL;
               OPEN rg_csr(p_chr_id,
                           l_line_csr_tbl(k).id);
                 FETCH rg_csr INTO l_rgp_id;
               CLOSE rg_csr;

               IF (l_rgp_id IS NULL) THEN
                 -- Create Rule Group for LALEVL
                 l_rgpv_rec            := p_rgpv_tbl(1);
                 l_rgpv_rec.chr_id     := NULL;
                 l_rgpv_rec.cle_id     := l_line_csr_tbl(k).id;
                 l_rgpv_rec.dnz_chr_id := p_chr_id;

                 OKL_RULE_PUB.create_rule_group(
                                        p_api_version     => 1.0,
                                        p_init_msg_list   => OKC_API.G_FALSE,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_rgpv_rec        => l_rgpv_rec,
                                        x_rgpv_rec        => x_new_rgpv_rec
                                       );
                 IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                   x_return_status := OKC_API.G_RET_STS_ERROR;
                   raise rule_failed;
                 END IF;
               ELSE
                 x_new_rgpv_rec.id := l_rgp_id;
               END IF;
               -- Set the cache with this value
               l_kle_rgp_cache_tbl(k) := x_new_rgpv_rec.id;
             END IF;  -- end of check for k > l_kle_rgp_cache_tbl.COUNT
             ---------------------------------------
             -- Create SLH for asset per SLH at contract level
             ---------------------------------------
             IF k > l_kle_slh_cache_tbl.COUNT THEN
               l_slh_rulv_rec        := x_slh_rulv_tbl(i);
               l_slh_rulv_rec.rgp_id := l_kle_rgp_cache_tbl(k);
               OKL_RULE_PUB.create_rule(
                                  p_api_version     => 1.0,
                                  p_init_msg_list   => OKC_API.G_FALSE,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count,
                                  x_msg_data        => x_msg_data,
                                  p_rulv_rec        => l_slh_rulv_rec,
                                  x_rulv_rec        => x_new_slh_rulv_rec
                                 );
               IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 x_return_status := OKC_API.G_RET_STS_ERROR;
                 raise rule_failed;
               END IF;

               -- set the SLH cache
               l_kle_slh_cache_tbl(k) := x_new_slh_rulv_rec.id;
             END IF;

             l_sll_rulv_rec             := x_sll_rulv_tbl(j);
             l_sll_rulv_rec.rgp_id      := l_kle_rgp_cache_tbl(k);
             l_sll_rulv_rec.object2_id1 := l_kle_slh_cache_tbl(k);

            ---------------------------------------
			-- calculate line level payment (be it stub or be it periodic payment)
            ---------------------------------------
            l_line_capital_amount := l_line_csr_tbl(k).capital_amount;
            IF (l_sll_rulv_rec.rule_information6 IS NOT NULL) THEN
               l_sll_rulv_rec.rule_information6 :=
                              ROUND(((l_sll_rulv_rec.rule_information6 * l_line_capital_amount) /
                               p_tot_capital_amount),p_precision);
               l_asset_pymnt_total := l_asset_pymnt_total + l_sll_rulv_rec.rule_information6;
            END IF;

            IF (l_sll_rulv_rec.rule_information8 IS NOT NULL) THEN
               l_sll_rulv_rec.rule_information8 :=
                              ROUND(((l_sll_rulv_rec.rule_information8 * l_line_capital_amount) /
                               p_tot_capital_amount),p_precision);
               l_asset_pymnt_total := l_asset_pymnt_total + l_sll_rulv_rec.rule_information8;
            END IF;
            ---------------------------------------
            -- Identify asset with highest capital cost
            ---------------------------------------
            IF (l_line_capital_amount > l_line_csr_tbl(l_adj_index).capital_amount) THEN
              l_adj_index := k;
            END IF;
            -- Populate the table of SLLs
            sll_indx := sll_indx + 1;
            l_sll_rulv_tbl(sll_indx) := l_sll_rulv_rec;
	  END LOOP; -- end of loop over assets

          ---------------------------------------
          -- Calculate difference between contract level payment and temporary total
          ---------------------------------------
          l_adjustment := l_khr_payment - l_asset_pymnt_total;
          ---------------------------------------
          -- adjust this on the payment of the asset identified to be adjusted.
          ---------------------------------------
          IF l_adjustment <> 0 THEN
            IF (l_sll_rulv_tbl(l_adj_index).rule_information6 IS NOT NULL) THEN
              l_sll_rulv_tbl(l_adj_index).rule_information6 := l_sll_rulv_tbl(l_adj_index).rule_information6 + l_adjustment;
            ELSIF (l_sll_rulv_tbl(l_adj_index).rule_information8 IS NOT NULL) THEN
              l_sll_rulv_tbl(l_adj_index).rule_information8 := l_sll_rulv_tbl(l_adj_index).rule_information8 + l_adjustment;
            END IF;
		  END IF;

         ---------------------------------------
         -- Create all SLLs using the table of records of SLLs formed
         ---------------------------------------
         OKL_RULE_PUB.create_rule(
                                     p_api_version     => 1.0,
                                     p_init_msg_list   => OKC_API.G_FALSE,
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_rulv_tbl        => l_sll_rulv_tbl,
                                     x_rulv_tbl        => x_sll_rulv_new_tbl
                                    );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           x_return_status := OKC_API.G_RET_STS_ERROR;
           raise rule_failed;
         END IF;
        END LOOP; -- end of SLL loop
      END LOOP; -- end of SLH loop

   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
      WHEN OTHERS THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);
  END split_payments;
  -- Bug# 7661717 - Added - End

------------------------------------------------------------------------------
-- PROCEDURE apply_payment
--
--  This procedure proportion-ed the payments accross Financial Asset Top Line
--  and Fee Top Line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE apply_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         ) IS
  --Changed query for performance --dkagrawa
  CURSOR line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT okl.id, okl.capital_amount -- bug# 7661717
  FROM   okl_k_lines_full_v okl,
         okc_line_styles_b ols,
         okc_statuses_b okcsts
  WHERE  okl.dnz_chr_id = p_chr_id
  AND    okl.lse_id     = ols.id
  AND    ols.lty_code   = 'FREE_FORM1'
  AND    okcsts.code    = okl.sts_code
  AND    okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED')
  ORDER BY okl.NAME; -- Added Order by for bug# 7661717

  CURSOR rg_del_csr (p_chr_id NUMBER,
                     p_rgp_id NUMBER) IS
  SELECT 'Y'
  FROM   okc_rule_groups_v rg
  WHERE  NOT EXISTS (SELECT 'Y'
                     FROM   okc_rules_v rule
                     WHERE  rule.rgp_id = rg.id
                    )
  AND   rg.dnz_chr_id = p_chr_id
  AND   rg.rgd_code   = 'LALEVL'
  AND   rg.id         = p_rgp_id;

  l_api_name           VARCHAR2(35)    := 'apply_payment';
  l_proc_name          VARCHAR2(35)    := 'APPLY_PAYMENT';
  l_api_version        CONSTANT NUMBER := 1;
  l_precision          FND_CURRENCIES.PRECISION%TYPE;

  l_del_yn             VARCHAR2(1) := 'N';
  l_rgpv_tbl           OKL_RULE_PUB.rgpv_tbl_type;
  l_slh_rulv_tbl       OKL_RULE_PUB.rulv_tbl_type;
  l_sll_rulv_tbl       OKL_RULE_PUB.rulv_tbl_type;

  l_rg_count           NUMBER := 0;
  x_slh_rule_count     NUMBER;
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

  l_line_csr_tbl line_csr_tbl; -- Added Bug# 7661717
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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Check for Line Rule, if present don't proceed with Payment Application
      check_line_rule(
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_stream_id     => p_stream_id,
                      x_rule_present  => l_rule_present
                     );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_rule_present = 'Y') THEN -- Rule already present at Line level
         okl_api.set_message(
                             G_APP_NAME,
                             G_RULE_PRESENT_ERROR
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      check_header_rule(
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data,
                       p_chr_id            => p_chr_id,
                       p_stream_id         => p_stream_id,
                       x_rgpv_tbl          => l_rgpv_tbl,
                       x_rg_count          => l_rg_count
                      );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (l_rg_count = 0) THEN  -- No Rule Groups
         okl_api.set_message(
                             G_APP_NAME,
                             G_NO_HEADER_PAYMENT
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

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CAP :'||l_tot_capital_amount);
      END IF;
      -- Bug 7661717 : Start
/*
      FOR line_rec IN line_csr(p_chr_id)
      LOOP
         -- Apply Payment across Lines (Fin Asset and Fee Top Line)
         create_line_rule(
                          x_return_status           => x_return_status,
                          x_msg_count               => x_msg_count,
                          x_msg_data                => x_msg_data,
                          p_chr_id                  => p_chr_id,
                          p_cle_id                  => line_rec.id,
                          p_stream_id               => p_stream_id,
                          p_fin_line_capital_amount => line_rec.capital_amount,
                          p_tot_capital_amount      => l_tot_capital_amount,
                          p_precision               => l_precision,
                          p_rgpv_tbl                => l_rgpv_tbl,
                          p_rg_count                => l_rg_count,
                          x_slh_rulv_tbl_out        => x_slh_rulv_tbl_out,
                          x_slh_count               => x_slh_count,
                          x_sll_rulv_tbl_out        => x_sll_rulv_tbl_out,
                          x_sll_count               => x_sll_count
                         );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END LOOP;
*/    -- Bug 7661717 : Start
     -- Bug# 7661717 - Added - Start
     ---------------------------------------
     -- Get all of contract lines into a table of records
     ---------------------------------------
     OPEN line_csr(p_chr_id);
       FETCH line_csr BULK COLLECT INTO l_line_csr_tbl;
     CLOSE line_csr;

     -- Call split payments method to split the SLH and SLLs among assets
     split_payments(
        p_api_version          => p_api_version,
        p_init_msg_list        => p_init_msg_list,
        p_chr_id               => p_chr_id,
        p_line_csr_tbl         => l_line_csr_tbl,
        p_stream_id            => p_stream_id,
        p_tot_capital_amount   => l_tot_capital_amount,
        p_precision            => l_precision,
        p_rgpv_tbl             => l_rgpv_tbl,
        x_slh_rulv_tbl_out     => x_slh_rulv_tbl_out,
        x_slh_count            => x_slh_count,
        x_sll_rulv_tbl_out     => x_sll_rulv_tbl_out,
        x_sll_count            => x_sll_count,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data
			  );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
      -- Bug# 7661717 - Added - End

      FOR i IN 1..x_slh_count
      LOOP
         l_slh_rulv_del_tbl(i).id := x_slh_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH delete: '||x_slh_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLH
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_slh_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_sll_count
      LOOP
         l_sll_rulv_del_tbl(i).id := x_sll_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL delete: '||x_sll_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLL
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_sll_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      --
      -- Delete Header Payment Rule
      -- only if there is no other stream type present
      --
      FOR i IN 1..l_rg_count
      LOOP
         l_del_yn := 'N';
         OPEN rg_del_csr(p_chr_id, l_rgpv_tbl(i).id);
         FETCH rg_del_csr INTO l_del_yn;
         CLOSE rg_del_csr;
         IF (l_del_yn = 'Y') THEN
            l_rgpv_del_rec.id := l_rgpv_tbl(i).id;
            okl_rule_pub.delete_rule_group(
                                     p_api_version                  => 1.0,
                                     p_init_msg_list                => p_init_msg_list,
                                     x_return_status                => x_return_status,
                                     x_msg_count                    => x_msg_count,
                                     x_msg_data                     => x_msg_data,
                                     p_rgpv_rec                     => l_rgpv_del_rec
                                    );
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
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

  END apply_payment;


------------------------------------------------------------------------------
-- PROCEDURE apply_propery_tax_payment
--
--  This procedure proportion-ed the payments accross Financial Asset Top Line
--  for Property Tax Payment
--
-- Calls:
-- Called By: OKL_LA_PAYMENTS_PVT
------------------------------------------------------------------------------
  PROCEDURE apply_propery_tax_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         ) IS
  CURSOR line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT okl.id, okl.capital_amount
  FROM   okl_k_lines_full_v okl,
         okc_line_styles_v ols,
         okc_rule_groups_b rgp,
         okc_rules_b       rul
  WHERE  okl.dnz_chr_id = p_chr_id
  AND    okl.lse_id     = ols.id
  AND    ols.lty_code   = 'FREE_FORM1'
  --AND    rul.rule_information_category = 'LAASTK'
  AND    rul.rule_information_category = 'LAPRTX'  -- Bug 3987623
  AND    rul.dnz_chr_id = p_chr_id
  AND    rul.rgp_id     = rgp.id
  AND    rul.rule_information1 = 'Y'
  AND    NVL(rul.rule_information3,'XXX') IN ('ESTIMATED','ESTIMATED_AND_ACTUAL')
  AND    rgp.rgd_code   = 'LAASTX'
  AND    rgp.dnz_chr_id = p_chr_id
  AND    rgp.chr_id     IS NULL
  AND    rgp.cle_id     = okl.id
  -- added to handle abandon line
  AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = okl.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

  line_rec line_csr%ROWTYPE;

  CURSOR rg_del_csr (p_chr_id NUMBER,
                     p_rgp_id NUMBER) IS
  SELECT 'Y'
  FROM   okc_rule_groups_v rg
  WHERE  NOT EXISTS (SELECT 'Y'
                     FROM   okc_rules_v rule
                     WHERE  rule.rgp_id = rg.id
                    )
  AND   rg.dnz_chr_id = p_chr_id
  AND   rg.rgd_code   = 'LALEVL'
  AND   rg.id         = p_rgp_id;

  CURSOR line_cap_csr (p_chr_id NUMBER) IS
  SELECT SUM(NVL(line.oec,0)) tot_cap
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v style,
         okc_statuses_v okcsts,
         okc_rules_b rule,
         okc_rule_groups_b rgp
  WHERE  line.dnz_chr_id                = p_chr_id
  AND    line.lse_id                    = style.id
  AND    style.lty_code                 = 'FREE_FORM1'
  AND    okcsts.code                    = line.sts_code
  AND    okcsts.ste_code                NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED')
  AND    rule.rgp_id                    = rgp.id
  AND    rgp.dnz_chr_id                 = line.dnz_chr_id
  AND    rgp.rgd_code                   = 'LAASTX'
  AND    rule.rule_information_category = 'LAPRTX'
  AND    rule.rule_information1         = 'Y'
  AND    NVL(rule.rule_information3,'XXX') IN ('ESTIMATED','ESTIMATED_AND_ACTUAL')
  AND    rgp.cle_id                     = line.id
  AND    rgp.chr_id                     IS NULL;

  l_api_name           VARCHAR2(35)    := 'apply_propery_tax_payment';
  l_proc_name          VARCHAR2(35)    := 'apply_propery_tax_payment';
  l_api_version        CONSTANT NUMBER := 1;
  l_precision          FND_CURRENCIES.PRECISION%TYPE;

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
  rowCnt               NUMBER DEFAULT 0;
  l_line_count         NUMBER := 0;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Check for Line Rule, if present don't proceed with Payment Application
      check_line_rule(
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_stream_id     => p_stream_id,
                      x_rule_present  => l_rule_present
                     );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_rule_present = 'Y') THEN -- Rule already present at Line level
         okl_api.set_message(
                             G_APP_NAME,
                             G_RULE_PRESENT_ERROR
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      check_header_rule(
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data,
                       p_chr_id            => p_chr_id,
                       p_stream_id         => p_stream_id,
                       x_rgpv_tbl          => l_rgpv_tbl,
                       x_rg_count          => l_rg_count
                      );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (l_rg_count = 0) THEN  -- No Rule Groups
         okl_api.set_message(
                             G_APP_NAME,
                             G_NO_HEADER_PAYMENT
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_tot_capital_amount := 0;
      FOR line_cap_rec IN line_cap_csr (p_chr_id)
      LOOP
        l_tot_capital_amount := line_cap_rec.tot_cap;
      END LOOP;

      get_currency_precision(
                             x_return_status => x_return_status,
                             p_chr_id        => p_chr_id,
                             x_precision     => l_precision
                            );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CAP :'||l_tot_capital_amount);
      END IF;

      l_line_count := 0; -- number of lines eligible for Prop tax application
      FOR line_rec IN line_csr(p_chr_id)
      LOOP
         l_line_count := l_line_count + 1;
         -- Apply Payment across Lines (Fin Asset and Fee Top Line)
         create_line_rule(
                          x_return_status           => x_return_status,
                          x_msg_count               => x_msg_count,
                          x_msg_data                => x_msg_data,
                          p_chr_id                  => p_chr_id,
                          p_cle_id                  => line_rec.id,
                          p_stream_id               => p_stream_id,
                          p_fin_line_capital_amount => line_rec.capital_amount,
                          p_tot_capital_amount      => l_tot_capital_amount,
                          p_precision               => l_precision,
                          p_rgpv_tbl                => l_rgpv_tbl,
                          p_rg_count                => l_rg_count,
                          x_slh_rulv_tbl_out        => x_slh_rulv_tbl_out,
                          x_slh_count               => x_slh_count,
                          x_sll_rulv_tbl_out        => x_sll_rulv_tbl_out,
                          x_sll_count               => x_sll_count
                         );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

      END LOOP;

      IF ( l_line_count = 0 ) THEN
        okl_api.set_message(
                         G_APP_NAME,
                         'OKL_NO_PROP_TAX_AST'
                       );
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_slh_count
      LOOP
         l_slh_rulv_del_tbl(i).id := x_slh_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH delete: '||x_slh_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLH
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_slh_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_sll_count
      LOOP
         l_sll_rulv_del_tbl(i).id := x_sll_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL delete: '||x_sll_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLL
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_sll_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --
      -- Delete Header Payment Rule
      -- only if there is no other stream type present
      --
      FOR i IN 1..l_rg_count
      LOOP
         l_del_yn := 'N';
         OPEN rg_del_csr(p_chr_id, l_rgpv_tbl(i).id);
         FETCH rg_del_csr INTO l_del_yn;
         CLOSE rg_del_csr;
         IF (l_del_yn = 'Y') THEN
            l_rgpv_del_rec.id := l_rgpv_tbl(i).id;
            okl_rule_pub.delete_rule_group(
                                     p_api_version                  => 1.0,
                                     p_init_msg_list                => p_init_msg_list,
                                     x_return_status                => x_return_status,
                                     x_msg_count                    => x_msg_count,
                                     x_msg_data                     => x_msg_data,
                                     p_rgpv_rec                     => l_rgpv_del_rec
                                    );
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
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

  END apply_propery_tax_payment;


------------------------------------------------------------------------------
-- PROCEDURE apply_rollover_fee_payment
--
--  This procedure applies the payments proportionately accross Rollover
--  Fee Sub-Lines (Assets attachecd to the Fee top line)
--  for the Rollover Fee Top line.
--
-- Calls:
-- Created By:  Manu 09-Sep-2004
-- Called By: OKL_LA_PAYMENTS_PVT
------------------------------------------------------------------------------
  PROCEDURE apply_rollover_fee_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_kle_id        IN  OKC_K_LINES_B.ID%TYPE,-- Rollover Fee Top Line
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         ) IS
  CURSOR ro_fee_subline_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                             p_kle_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT kle.id, kle.amount
    FROM okc_k_lines_b cleb,
         okl_k_lines kle
    WHERE cleb.dnz_chr_id = p_chr_id
        AND kle.ID = cleb.ID
        AND cleb.CLE_ID = p_kle_id
        -- AND cleb.sts_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED');
        AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

   -- Total Fee amount for the rollover fee top line.

   CURSOR fee_amount_csr (p_kle_id OKL_K_LINES.ID%TYPE) IS
   SELECT NVL(kle.amount,0)
    FROM okl_k_lines kle
    WHERE kle.ID = p_kle_id;

   -- Cursor to get fee top line name.

   CURSOR fee_name_csr (p_kle_id OKL_K_LINES.ID%TYPE) IS
   SELECT kle.name
    FROM okc_k_lines_v kle
    WHERE kle.ID = p_kle_id;

  CURSOR rg_del_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                     p_rgp_id NUMBER) IS
  SELECT 'Y'
  FROM   okc_rule_groups_v rg
  WHERE  NOT EXISTS (SELECT 'Y'
                     FROM   okc_rules_v rule
                     WHERE  rule.rgp_id = rg.id
                    )
  AND   rg.dnz_chr_id = p_chr_id
  AND   rg.rgd_code   = 'LALEVL'
  AND   rg.id         = p_rgp_id;

  l_api_name           VARCHAR2(35)    := 'apply_rollover_fee_payment';
  l_proc_name          VARCHAR2(35)    := 'apply_rollover_fee_payment';
  l_api_version        CONSTANT NUMBER := 1;
  l_precision          FND_CURRENCIES.PRECISION%TYPE;

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

  l_tot_fee_amount     NUMBER := 0;
  l_rule_present       VARCHAR2(1);
   ro_fee_subline_rec   ro_fee_subline_csr%ROWTYPE;
  l_fee_name           OKC_K_LINES_V.NAME%TYPE;
   rowCnt               NUMBER DEFAULT 0;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Check if payments already exists for fee-sublines for the given rollover
      -- fee top line, if present don't proceed with Payment Application
      check_ro_subline_rule(
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_cle_id        => p_kle_id,
                      p_stream_id     => p_stream_id,
                      x_rule_present  => l_rule_present
                     );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_rule_present IS NOT NULL AND l_rule_present = 'Y') THEN -- Rule already present at Line level
         okl_api.set_message(
                             G_APP_NAME,
                             G_RULE_PRESENT_ERROR
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      get_ro_fee_topln_rg(
                          p_api_version    => 1.0,
                          p_init_msg_list  => OKL_API.G_FALSE,
                          p_chr_id         => p_chr_id,
                          p_cle_id         => p_kle_id,
                          p_stream_id      => p_stream_id,
                          p_rgd_code       => 'LALEVL',
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_rgpv_tbl       => l_rgpv_tbl,
                          x_rg_count       => l_rg_count);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


      IF (l_rg_count = 0) THEN  -- No Rule Groups
         okl_api.set_message(
                             G_APP_NAME,
                             G_NO_HEADER_PAYMENT
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_tot_fee_amount := 0;
      OPEN fee_amount_csr(p_kle_id => p_kle_id);
      FETCH fee_amount_csr INTO l_tot_fee_amount;
      CLOSE fee_amount_csr;


      get_currency_precision(
                             x_return_status => x_return_status,
                             p_chr_id        => p_chr_id,
                             x_precision     => l_precision
                            );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CAP :'||l_tot_fee_amount);
      END IF;

      OPEN fee_name_csr (p_kle_id);
      FETCH fee_name_csr INTO l_fee_name;
      CLOSE fee_name_csr;

      OPEN ro_fee_subline_csr(p_chr_id, p_kle_id);
      LOOP
        FETCH ro_fee_subline_csr INTO
              ro_fee_subline_rec.id,
              ro_fee_subline_rec.amount;
      EXIT WHEN ro_fee_subline_csr%NOTFOUND;
        rowCnt := ro_fee_subline_csr%ROWCOUNT;
        -- Apply Payment across Sub-Lines (Fee Asset Lines)
        create_line_rule(
                             x_return_status           => x_return_status,
                             x_msg_count               => x_msg_count,
                             x_msg_data                => x_msg_data,
                             p_chr_id                  => p_chr_id,
                             p_cle_id                  => ro_fee_subline_rec.id,
                             p_stream_id               => p_stream_id,
                             p_fin_line_capital_amount => ro_fee_subline_rec.amount, -- Sub-line fee Amount
                             p_tot_capital_amount      => l_tot_fee_amount, -- Total top Fee line Amount
                             p_precision               => l_precision,
                             p_rgpv_tbl                => l_rgpv_tbl,
                             p_rg_count                => l_rg_count,
                             x_slh_rulv_tbl_out        => x_slh_rulv_tbl_out,
                             x_slh_count               => x_slh_count,
                             x_sll_rulv_tbl_out        => x_sll_rulv_tbl_out,
                             x_sll_count               => x_sll_count
                            );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
      CLOSE ro_fee_subline_csr;

      -- NO sub-lines found, error out.
      IF ( rowCnt < 1 ) THEN
        okl_api.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_RO_NO_SUB_LNS',
	           	      p_token1       => 'FEE_LINE',
	                      p_token1_value => l_fee_name
                                   );
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_slh_count
      LOOP
         l_slh_rulv_del_tbl(i).id := x_slh_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH delete: '||x_slh_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLH
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_slh_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_sll_count
      LOOP
         l_sll_rulv_del_tbl(i).id := x_sll_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL delete: '||x_sll_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLL
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_sll_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      --
      -- Delete Header Payment Rule
      -- only if there is no other stream type present
      --
      FOR i IN 1..l_rg_count
      LOOP
         l_del_yn := 'N';
         OPEN rg_del_csr(p_chr_id, l_rgpv_tbl(i).id);
         FETCH rg_del_csr INTO l_del_yn;
         CLOSE rg_del_csr;
         IF (l_del_yn = 'Y') THEN
            l_rgpv_del_rec.id := l_rgpv_tbl(i).id;
            okl_rule_pub.delete_rule_group(
                                     p_api_version                  => 1.0,
                                     p_init_msg_list                => p_init_msg_list,
                                     x_return_status                => x_return_status,
                                     x_msg_count                    => x_msg_count,
                                     x_msg_data                     => x_msg_data,
                                     p_rgpv_rec                     => l_rgpv_del_rec
                                    );
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
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

  END apply_rollover_fee_payment;

-- start: cklee: okl.h
------------------------------------------------------------------------------
-- PROCEDURE apply_eligible_fee_payment
--
--  This procedure applies the payments proportionately accross
--  Fee Sub-Lines (Assets attachecd to the Fee top line)
--  for the Fee Top line.
--
-- Calls:
-- Created By:  cklee 22-Jun-2005
-- Called By: OKL_LA_PAYMENTS_PVT
------------------------------------------------------------------------------
  PROCEDURE apply_eligible_fee_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_kle_id        IN  OKC_K_LINES_B.ID%TYPE,-- Fee Top Line
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         ) IS
  CURSOR ro_fee_subline_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                             p_kle_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT kle.id, kle.amount
    FROM okc_k_lines_b cleb,
         okl_k_lines kle
    WHERE cleb.dnz_chr_id = p_chr_id
        AND kle.ID = cleb.ID
        AND cleb.CLE_ID = p_kle_id
        -- AND cleb.sts_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED');
        AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

   -- Total Fee amount for the rollover fee top line.

   CURSOR fee_amount_csr (p_kle_id OKL_K_LINES.ID%TYPE) IS
   SELECT NVL(kle.amount,0)
    FROM okl_k_lines kle
    WHERE kle.ID = p_kle_id;

   -- Cursor to get fee top line name.

   CURSOR fee_name_csr (p_kle_id OKL_K_LINES.ID%TYPE) IS
   SELECT kle.name
    FROM okc_k_lines_v kle
    WHERE kle.ID = p_kle_id;

  CURSOR rg_del_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                     p_rgp_id NUMBER) IS
  SELECT 'Y'
  FROM   okc_rule_groups_v rg
  WHERE  NOT EXISTS (SELECT 'Y'
                     FROM   okc_rules_v rule
                     WHERE  rule.rgp_id = rg.id
                    )
  AND   rg.dnz_chr_id = p_chr_id
  AND   rg.rgd_code   = 'LALEVL'
  AND   rg.id         = p_rgp_id;

  l_api_name           VARCHAR2(35)    := 'apply_eligible_fee_payment';
  l_proc_name          VARCHAR2(35)    := 'apply_eligible_fee_payment';
  l_api_version        CONSTANT NUMBER := 1;
  l_precision          FND_CURRENCIES.PRECISION%TYPE;

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

  l_tot_fee_amount     NUMBER := 0;
  l_rule_present       VARCHAR2(1);
   ro_fee_subline_rec   ro_fee_subline_csr%ROWTYPE;
  l_fee_name           OKC_K_LINES_V.NAME%TYPE;
   rowCnt               NUMBER DEFAULT 0;

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Check if payments already exists for fee-sublines for the given
      -- fee top line, if present don't proceed with Payment Application
      check_ro_subline_rule(
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_cle_id        => p_kle_id,
                      p_stream_id     => p_stream_id,
                      x_rule_present  => l_rule_present
                     );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_rule_present IS NOT NULL AND l_rule_present = 'Y') THEN -- Rule already present at Line level
         okl_api.set_message(
                             G_APP_NAME,
                             G_RULE_PRESENT_ERROR
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      get_ro_fee_topln_rg(
                          p_api_version    => 1.0,
                          p_init_msg_list  => OKL_API.G_FALSE,
                          p_chr_id         => p_chr_id,
                          p_cle_id         => p_kle_id,
                          p_stream_id      => p_stream_id,
                          p_rgd_code       => 'LALEVL',
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_rgpv_tbl       => l_rgpv_tbl,
                          x_rg_count       => l_rg_count);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


      IF (l_rg_count = 0) THEN  -- No Rule Groups
         okl_api.set_message(
                             G_APP_NAME,
                             G_NO_HEADER_PAYMENT
                            );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_tot_fee_amount := 0;
      OPEN fee_amount_csr(p_kle_id => p_kle_id);
      FETCH fee_amount_csr INTO l_tot_fee_amount;
      CLOSE fee_amount_csr;


      get_currency_precision(
                             x_return_status => x_return_status,
                             p_chr_id        => p_chr_id,
                             x_precision     => l_precision
                            );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CAP :'||l_tot_fee_amount);
      END IF;

      OPEN fee_name_csr (p_kle_id);
      FETCH fee_name_csr INTO l_fee_name;
      CLOSE fee_name_csr;

      OPEN ro_fee_subline_csr(p_chr_id, p_kle_id);
      LOOP
        FETCH ro_fee_subline_csr INTO
              ro_fee_subline_rec.id,
              ro_fee_subline_rec.amount;
      EXIT WHEN ro_fee_subline_csr%NOTFOUND;
        rowCnt := ro_fee_subline_csr%ROWCOUNT;
        -- Apply Payment across Sub-Lines (Fee Asset Lines)
        create_line_rule(
                             x_return_status           => x_return_status,
                             x_msg_count               => x_msg_count,
                             x_msg_data                => x_msg_data,
                             p_chr_id                  => p_chr_id,
                             p_cle_id                  => ro_fee_subline_rec.id,
                             p_stream_id               => p_stream_id,
                             p_fin_line_capital_amount => ro_fee_subline_rec.amount, -- Sub-line fee Amount
                             p_tot_capital_amount      => l_tot_fee_amount, -- Total top Fee line Amount
                             p_precision               => l_precision,
                             p_rgpv_tbl                => l_rgpv_tbl,
                             p_rg_count                => l_rg_count,
                             x_slh_rulv_tbl_out        => x_slh_rulv_tbl_out,
                             x_slh_count               => x_slh_count,
                             x_sll_rulv_tbl_out        => x_sll_rulv_tbl_out,
                             x_sll_count               => x_sll_count
                            );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
      CLOSE ro_fee_subline_csr;

      -- NO sub-lines found, error out.
      IF ( rowCnt < 1 ) THEN
        okl_api.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_RO_NO_SUB_LNS',
	           	      p_token1       => 'FEE_LINE',
	                      p_token1_value => l_fee_name
                                   );
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_slh_count
      LOOP
         l_slh_rulv_del_tbl(i).id := x_slh_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH delete: '||x_slh_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLH
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_slh_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      FOR i IN 1..x_sll_count
      LOOP
         l_sll_rulv_del_tbl(i).id := x_sll_rulv_tbl_out(i).id;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL delete: '||x_sll_rulv_tbl_out(i).id);
         END IF;
      END LOOP; -- SLL
      okl_rule_pub.delete_rule(
                               p_api_version                  => 1.0,
                               p_init_msg_list                => p_init_msg_list,
                               x_return_status                => x_return_status,
                               x_msg_count                    => x_msg_count,
                               x_msg_data                     => x_msg_data,
                               p_rulv_tbl                     => l_sll_rulv_del_tbl
                              );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      --
      -- Delete Header Payment Rule
      -- only if there is no other stream type present
      --
      FOR i IN 1..l_rg_count
      LOOP
         l_del_yn := 'N';
         OPEN rg_del_csr(p_chr_id, l_rgpv_tbl(i).id);
         FETCH rg_del_csr INTO l_del_yn;
         CLOSE rg_del_csr;
         IF (l_del_yn = 'Y') THEN
            l_rgpv_del_rec.id := l_rgpv_tbl(i).id;
            okl_rule_pub.delete_rule_group(
                                     p_api_version                  => 1.0,
                                     p_init_msg_list                => p_init_msg_list,
                                     x_return_status                => x_return_status,
                                     x_msg_count                    => x_msg_count,
                                     x_msg_data                     => x_msg_data,
                                     p_rgpv_rec                     => l_rgpv_del_rec
                                    );
            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
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

  END apply_eligible_fee_payment;
-- end: cklee: okl.h

------------------------------------------------------------------------------
-- PROCEDURE delete_payment
--
--  This procedure deletes Payments including SLH, SLL and if requires
--  corresponding rule group too.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE delete_payment(
                           p_api_version   IN  NUMBER,
                           p_init_msg_list IN  VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2,
                           p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                           p_rgp_id        IN  OKC_RULE_GROUPS_V.ID%TYPE,
                           p_rule_id       IN  OKC_RULES_V.ID%TYPE
                          ) IS
  l_api_name           VARCHAR2(35)    := 'delete_payment';
  l_proc_name          VARCHAR2(35)    := 'DELETE_PAYMENT';
  l_api_version        CONSTANT NUMBER := 1;

  CURSOR sll_csr (p_chr_id  OKC_K_HEADERS_V.ID%TYPE,
                  p_rgp_id  OKC_RULE_GROUPS_V.ID%TYPE,
                  p_rule_id OKC_RULES_V.ID%TYPE) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  dnz_chr_id                = p_chr_id
  AND    rgp_id                    = p_rgp_id
  AND    object2_id1               = p_rule_id
  AND    rule_information_category = 'LASLL';

  CURSOR rgp_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                  p_rgp_id OKC_RULE_GROUPS_V.ID%TYPE) IS
  SELECT 'Y'
  FROM   okc_rules_v
  WHERE  dnz_chr_id = p_chr_id
  AND    rgp_id     = p_rgp_id;

  -- Fix Bug# 2819175
  CURSOR slh_csr (p_chr_id  OKC_K_HEADERS_V.ID%TYPE,
                  p_rule_id OKC_RULES_V.ID%TYPE) IS
  SELECT 'Y'
  FROM   okc_rules_v
  WHERE  id         = p_rule_id
  AND    dnz_chr_id = p_chr_id;

  l_rulv_tbl     rulv_tbl_type;
  l_rulv_rec     rulv_rec_type;
  l_rgpv_rec     rgpv_rec_type;
  i              NUMBER;
  l_rule_present VARCHAR2(1);
  l_slh          VARCHAR2(1);

  BEGIN
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

     --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

     i := 0;
     FOR sll_rec IN sll_csr(p_chr_id,
                            p_rgp_id,
                            p_rule_id)
     LOOP
        i := i + 1;
        l_rulv_tbl(i).id := sll_rec.id;
     END LOOP;

     IF (i > 0) THEN
        okl_rule_pub.delete_rule(
                         p_api_version    => 1.0,
                         p_init_msg_list  => OKC_API.G_FALSE,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_tbl       => l_rulv_tbl
                        );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

     l_slh := 'N';
     OPEN slh_csr(p_chr_id,
                  p_rule_id);
     FETCH slh_csr INTO l_slh;
     CLOSE slh_csr;

     IF (l_slh = 'Y') THEN

        l_rulv_rec.id := p_rule_id; -- SLH Rule ID
        okl_rule_pub.delete_rule(
                         p_api_version    => 1.0,
                         p_init_msg_list  => OKC_API.G_FALSE,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_rulv_rec       => l_rulv_rec
                        );
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

     l_rule_present := 'N';
     OPEN rgp_csr(p_chr_id,
                  p_rgp_id);
     FETCH rgp_csr INTO l_rule_present;
     CLOSE rgp_csr;

     IF (l_rule_present = 'N') THEN -- No more rules under this rule group

        l_rgpv_rec.id := p_rgp_id;
        okl_rule_pub.delete_rule_group(
                                       p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_rgpv_rec       => l_rgpv_rec
                                      );

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

     --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

  END delete_payment;

END OKL_PAYMENT_APPLICATION_PVT;

/
