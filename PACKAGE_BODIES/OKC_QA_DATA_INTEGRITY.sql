--------------------------------------------------------
--  DDL for Package Body OKC_QA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_DATA_INTEGRITY" AS
/* $Header: OKCRQADB.pls 120.3 2006/08/09 22:31:42 abkumar noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--  G_DESCRIPTIVE_FLEXFIELD_NAME CONSTANT VARCHAR2(200) := 'OKC Rule Developer DF';    -- /striping/
  G_DF_COUNT                   CONSTANT NUMBER(2)     := 15;
  --
  G_PACKAGE  Varchar2(33) := '  OKC_QA_DATA_INTEGRITY.';
  G_MSG_NAME Varchar2(30);
  G_LINE     Varchar2(4) := 'LINE';
  G_TOKEN    Varchar2(30);
  G_BULK_FETCH_LIMIT           CONSTANT NUMBER := 1000;
  --
-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

  PROCEDURE Set_QA_Message(p_chr_id IN OKC_K_LINES_V.chr_id%TYPE,
                           p_cle_id IN OKC_K_LINES_V.id%TYPE,
                           p_msg_name IN VARCHAR2,
                           p_token1 IN VARCHAR2 DEFAULT NULL,
                           p_token1_value IN VARCHAR2 DEFAULT NULL,
                           p_token2 IN VARCHAR2 DEFAULT NULL,
                           p_token2_value IN VARCHAR2 DEFAULT NULL,
                           p_token3 IN VARCHAR2 DEFAULT NULL,
                           p_token3_value IN VARCHAR2 DEFAULT NULL,
                           p_token4 IN VARCHAR2 DEFAULT NULL,
                           p_token4_value IN VARCHAR2 DEFAULT NULL) IS
    l_line Varchar2(200);
    l_token1_value Varchar2(200) := p_token1_value;
    l_token2_value Varchar2(200) := p_token2_value;
    l_token3_value Varchar2(200) := p_token3_value;
    l_token4_value Varchar2(200) := p_token4_value;
    l_return_status Varchar2(3);
  BEGIN
    If p_cle_id Is Not Null Then
      l_line := okc_contract_pub.get_concat_line_no(p_cle_id,
                                                    l_return_status);
      If p_token1 = g_line Then
        l_token1_value := l_line;
      Elsif p_token2 = g_line Then
        l_token2_value := l_line;
      Elsif p_token3 = g_line Then
        l_token3_value := l_line;
      Elsif p_token4 = g_line Then
        l_token4_value := l_line;
      End If;
    End If;

    OKC_API.set_message(
                 p_app_name     => G_APP_NAME,
                 p_msg_name     => p_msg_name,
                 p_token1       => p_token1,
                 p_token1_value => l_token1_value,
                 p_token2       => p_token2,
                 p_token2_value => l_token2_value,
                 p_token3       => p_token3,
                 p_token3_value => l_token3_value,
                 p_token4       => p_token4,
                 p_token4_value => l_token4_value);
  END;
  --
  -- Start of comments
  --
  -- Procedure Name  : check_art_compatible
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_art_compatible(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  cursor c1 is
  select ID,SAV_SAE_ID,NAME
  from okc_k_articles_v
  where dnz_chr_id = p_chr_id
  and chr_id = p_chr_id
  and cat_type='STA';

  r1 c1%ROWTYPE;

  l_id number;
  p_sae_id number;
  l_name varchar2(150);

  Cursor l_catv_csr Is
  SELECT 'E'
  FROM okc_k_articles_b
  WHERE SAV_SAE_ID in (
	SELECT SAE_ID from OKC_STD_ART_INCMPTS_V
	WHERE SAE_ID_FOR = p_sae_id
	UNION
	SELECT SAE_ID_FOR from OKC_STD_ART_INCMPTS_V
	WHERE SAE_ID = p_sae_id
	)
	AND DNZ_CHR_ID = p_chr_id
	AND CHR_ID = p_chr_id
	AND ID <> l_id;
l_return_status varchar2(1):='S';
   --
   l_proc varchar2(72) := g_package||'check_art_compatible';
   --
BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  x_return_status := 'S';
  FOR r1 IN c1 LOOP
    l_id := r1.ID;
    p_sae_id := r1.SAV_SAE_ID;
    l_name := r1.NAME;
--
    Open l_catv_csr;
    Fetch l_catv_csr Into l_return_status;
    Close l_catv_csr;
    if (l_return_status<>'S') then
      x_return_status := l_return_status;
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_INCOMP_ARTICLE_EXISTS',
        p_token1       => 'VALUE1',
        p_token1_value => l_name);
    end if;
  END LOOP;
  IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
exception
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    if c1%ISOPEN then
      close c1;
    end if;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end check_art_compatible;

  -- Start of comments
  --
  -- Procedure Name  : check_required_values
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_required_values(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    CURSOR l_clev_csr IS
    SELECT RTRIM(RTRIM(line_number) || ', ' || RTRIM(lsev.name) || ' ' ||
           RTRIM(clev.name)) "LINE_NAME", currency_code,
           clev.lse_id, --bug 2398639
           clev.cle_id --bug 2398639
      FROM OKC_LINE_STYLES_V lsev,
           OKC_K_LINES_V clev
     WHERE lsev.id = clev.lse_id
       AND clev.dnz_chr_id = p_chr_id
	   AND clev.date_cancelled is NULL;  --changes [llc]--


    --l_clev_rec l_clev_csr%ROWTYPE;

    TYPE chr15_tbl_type IS TABLE OF okc_k_lines_v.currency_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE chr450_tbl_type IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_line_name_tbl      chr450_tbl_type;
    l_currency_code_tbl  chr15_tbl_type;
    l_lse_id_tbl         num_tbl_type;
    l_cle_id_tbl         num_tbl_type;


    CURSOR l_ctc_csr (p_cpl_id NUMBER) IS
      SELECT ctc.JTOT_OBJECT1_CODE, ctc.OBJECT1_ID1, ctc.OBJECT1_ID2,
             fnd.MEANING
        FROM FND_LOOKUPS fnd,
             OKC_CONTACTS ctc
       WHERE fnd.LOOKUP_CODE = ctc.cro_code
         AND fnd.LOOKUP_TYPE = 'OKC_CONTACT_ROLE'
         AND ctc.cpl_id = p_cpl_id;
    l_ctc_rec l_ctc_csr%ROWTYPE;

    CURSOR l_cpl1_csr IS
      SELECT cpl.ID, cpl.JTOT_OBJECT1_CODE, cpl.OBJECT1_ID1, cpl.OBJECT1_ID2,
             fnd.MEANING, cpl.rle_code, cpl.chr_id, cpl.cle_id
        FROM FND_LOOKUPS fnd,
             OKC_K_PARTY_ROLES_B cpl
       WHERE fnd.LOOKUP_CODE = cpl.rle_code
         AND fnd.LOOKUP_TYPE = 'OKC_ROLE'
         AND cpl.dnz_chr_id  = p_chr_id;
    l_cpl1_rec l_cpl1_csr%ROWTYPE;

    -- Do not use chr_id in the where clause, this column is not indexed.
    CURSOR l_cpl_csr IS
      SELECT count(distinct RLE_CODE)
        FROM OKC_K_PARTY_ROLES_B cpl
       WHERE cpl.dnz_chr_id = p_chr_id
       	 AND cpl.cle_id is NULL;


    CURSOR l_chrv_csr IS
      SELECT chrv.*, sub.cls_code
        FROM OKC_K_HEADERS_B chrv,
             OKC_SUBCLASSES_B sub
       WHERE chrv.id = p_chr_id
	 AND sub.code = chrv.scs_code;
    l_chrv_rec l_chrv_csr%ROWTYPE;

    CURSOR l_cle_csr(p_id okc_k_lines_b.id%TYPE) IS
      SELECT cle.chr_id
        FROM OKC_K_LINES_B cle
       WHERE cle.id = p_id;
    l_cle_rec l_cle_csr%ROWTYPE;

    CURSOR l_chr_csr IS
      SELECT 'x'
        FROM OKC_K_PARTY_ROLES_B
       WHERE dnz_chr_id  = p_chr_id
         AND chr_id  = p_chr_id
         AND rle_code = l_cpl1_rec.rle_code
         AND jtot_object1_code = l_cpl1_rec.jtot_object1_code
         AND object1_id1 = l_cpl1_rec.object1_id1
         AND object1_id2 = l_cpl1_rec.object1_id2;
 --bug 2398639
     CURSOR l_ph_can_rule(b_chr_id number) IS
     SELECT 'Y'
     FROM okc_rule_groups_b    rgp
         ,okc_rules_b          rul
     WHERE rgp.dnz_chr_id   = b_chr_id
     AND rgp.cle_id IS NULL
     AND rul.rgp_id         = rgp.id
     AND rul.rule_information_category = 'CAN';
--end bug 2398639
   --
   l_proc varchar2(72) := g_package||'check_required_values';
   l_line Varchar2(200);
   l_can_found varchar2(1) :='N'; -- bug 2398639
   --/rules migration/
   l_func_curr_code  VARCHAR2(30);
   --
  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- fetch the contract header information
    OPEN  l_chrv_csr;
    FETCH l_chrv_csr INTO l_chrv_rec;
    CLOSE l_chrv_csr;

    -- check required data for contract header
    IF (l_chrv_rec.BUY_OR_SELL IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_QA_INTENT_REQUIRED');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF (l_chrv_rec.CURRENCY_CODE IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_QA_CURRENCY_REQUIRED');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF (l_chrv_rec.ISSUE_OR_RECEIVE IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_QA_PERSPECTIVE_REQUIRED');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- Check that at least 2 different parties have been attached
    -- to the contract header.
    -- get party count
    OPEN  l_cpl_csr;
    FETCH l_cpl_csr INTO l_count;
    CLOSE l_cpl_csr;

    -- There must be 2 distinct party roles defined at the header level
    IF (l_count < 2) THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => 'OKC_QA_PARTY_COUNT');
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF (l_chrv_rec.TEMPLATE_YN = 'N') THEN
      -- Check all of the parties attached to the contract and contract
      -- lines to make sure that all integration information is supplied
      OPEN  l_cpl1_csr;
      LOOP
        FETCH l_cpl1_csr INTO l_cpl1_rec;
        EXIT WHEN l_cpl1_csr%NOTFOUND;
        IF (l_cpl1_rec.JTOT_OBJECT1_CODE IS NULL OR
            l_cpl1_rec.OBJECT1_ID1 IS NULL OR
            l_cpl1_rec.OBJECT1_ID2 IS NULL) THEN

          If l_cpl1_rec.chr_id Is Not Null Then
            g_msg_name := 'OKC_QA_K_CPL_MISSING';
            g_token := Null;
          Else
            g_msg_name := 'OKC_QA_KL_CPL_MISSING';
            g_token := g_line;
          End If;
          Set_QA_Message(p_chr_id => l_cpl1_rec.chr_id,
                         p_cle_id => l_cpl1_rec.cle_id,
                         p_msg_name => g_msg_name,
                         p_token1 => 'PARTY',
                         p_token1_value => l_cpl1_rec.meaning,
                         p_token2 => g_token);

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        OPEN  l_ctc_csr (l_cpl1_rec.id);
        LOOP
          FETCH l_ctc_csr INTO l_ctc_rec;
          EXIT WHEN l_ctc_csr%NOTFOUND;
          IF (l_ctc_rec.JTOT_OBJECT1_CODE IS NULL OR
              l_ctc_rec.OBJECT1_ID1 IS NULL OR
              l_ctc_rec.OBJECT1_ID2 IS NULL) THEN
            If l_cpl1_rec.chr_id Is Not Null Then
              g_msg_name := 'OKC_QA_K_CTC_MISSING';
              g_token := Null;
            Else
              g_msg_name := 'OKC_QA_KL_CTC_MISSING';
              g_token := g_line;
            End If;
            Set_QA_Message(p_chr_id => l_cpl1_rec.chr_id,
                           p_cle_id => l_cpl1_rec.cle_id,
                           p_msg_name => g_msg_name,
                           p_token1 => 'CONTACT',
                           p_token1_value => l_ctc_rec.meaning,
                           p_token2 => 'PARTY',
                           p_token2_value => l_cpl1_rec.meaning,
                           p_token3 => g_token);

            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
        END LOOP;
        CLOSE l_ctc_csr;
      END LOOP;
      CLOSE l_cpl1_csr;
    END IF; -- template_yn = 'N'

    -- Check that the currency on the Contract Line
    -- is the same as the contract header.
    /*******
    OPEN  l_clev_csr;
    LOOP
      FETCH l_clev_csr INTO l_clev_rec;
      EXIT WHEN l_clev_csr%NOTFOUND;
      IF (l_clev_rec.CURRENCY_CODE IS NULL) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKC_REQUIRED_LINE_CURRENCY',
          p_token1       => 'LINE_NAME',
          p_token1_value => l_clev_rec.line_name);

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      ELSIF l_clev_rec.currency_code <> l_chrv_rec.currency_code THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_LINE_CURRENCY,
          p_token1       => 'LINE_NAME',
          p_token1_value => l_clev_rec.line_name);
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      --bug 2398639     Check if Its price hold top-line then Contract header must have a CAN rule.
      IF l_clev_rec.lse_id=61 and l_clev_rec.cle_id is null and  l_chrv_rec.BUY_OR_SELL='S' THEN

          OPEN l_ph_can_rule(p_chr_id);
          FETCH l_ph_can_rule into l_can_found;
          IF l_ph_can_rule%NOTFOUND THEN
             OKC_API.set_message(p_app_name   => g_app_name, --OKC
                                 p_msg_name   => 'OKC_NO_PRICE_HOLD_CAN');
              x_return_status := OKC_API.G_RET_STS_ERROR;

          END IF;
          CLOSE l_ph_can_rule;
      END IF;
     -- bug 2398639
    END LOOP;
    CLOSE l_clev_csr;
    *******/

    --bug 5442886
    OPEN  l_clev_csr;
    LOOP
      FETCH l_clev_csr BULK COLLECT INTO l_line_name_tbl, l_currency_code_tbl,
                                         l_lse_id_tbl, l_cle_id_tbl LIMIT G_BULK_FETCH_LIMIT;

      EXIT WHEN l_line_name_tbl.COUNT = 0;

      FOR i IN l_line_name_tbl.FIRST..l_line_name_tbl.LAST LOOP

         IF (l_currency_code_tbl(i) IS NULL) THEN
           OKC_API.set_message(
             p_app_name     => G_APP_NAME,
             p_msg_name     => 'OKC_REQUIRED_LINE_CURRENCY',
             p_token1       => 'LINE_NAME',
             p_token1_value => l_line_name_tbl(i));

           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
         ELSIF l_currency_code_tbl(i) <> l_chrv_rec.currency_code THEN
           OKC_API.set_message(
             p_app_name     => G_APP_NAME,
             p_msg_name     => G_INVALID_LINE_CURRENCY,
             p_token1       => 'LINE_NAME',
             p_token1_value => l_line_name_tbl(i));
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
         END IF;
         --bug 2398639     Check if Its price hold top-line then Contract header must have a CAN rule.
         IF l_lse_id_tbl(i)=61 and l_cle_id_tbl(i) is null and  l_chrv_rec.BUY_OR_SELL='S' THEN

             OPEN l_ph_can_rule(p_chr_id);
             FETCH l_ph_can_rule into l_can_found;
             IF l_ph_can_rule%NOTFOUND THEN
                OKC_API.set_message(p_app_name   => g_app_name, --OKC
                                    p_msg_name   => 'OKC_NO_PRICE_HOLD_CAN');
                 x_return_status := OKC_API.G_RET_STS_ERROR;

             END IF;
             CLOSE l_ph_can_rule;
         END IF;
        -- bug 2398639
      END LOOP;

    END LOOP;
    CLOSE l_clev_csr;


--/Rules Migration/
--For non-okc,oko contracts check conversion data here
    If l_chrv_rec.application_id not in (510,871) Then
      l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_chrv_rec.authoring_org_id);
   ---
      IF l_chrv_rec.currency_code <> l_func_curr_code Then
        If (l_chrv_rec.conversion_type is null or
          l_chrv_rec.conversion_rate is null or
          l_chrv_rec.conversion_rate_date is null)
        Then
          OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKC_QA_CONVERSION_DATA');

         --raise error message
          x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
      End If;
    End If;
---/Rules Migration/

    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_chrv_csr%ISOPEN THEN
      CLOSE l_chrv_csr;
    END IF;
    IF l_cpl_csr%ISOPEN THEN
      CLOSE l_cpl_csr;
    END IF;
    IF l_cpl1_csr%ISOPEN THEN
      CLOSE l_cpl1_csr;
    END IF;
    IF l_ctc_csr%ISOPEN THEN
      CLOSE l_ctc_csr;
    END IF;
    IF l_clev_csr%ISOPEN THEN
      CLOSE l_clev_csr;
    END IF;
  END check_required_values;
--
  -- Start of comments
  --
  -- Procedure Name  : check_rule_values
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_rule_values(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_rul_rec                  IN  OKC_RULES_B%ROWTYPE,
    p_rgd_code                 IN  OKC_RULE_GROUPS_B.rgd_code%TYPE,
    p_rgp_id                   IN  OKC_RULE_GROUPS_B.id%TYPE,
    p_chr_id                   IN  OKC_RULE_GROUPS_B.chr_id%TYPE,
    p_cle_id                   IN  OKC_RULE_GROUPS_B.cle_id%TYPE,
    p_cls_code                 IN  OKC_SUBCLASSES_B.CLS_CODE%TYPE
  ) IS

    CURSOR l_cti_csr IS
      SELECT 'x'
        FROM OKC_COVER_TIMES cti
       WHERE cti.rul_id = p_rul_rec.id;

    CURSOR l_ril_csr IS
      SELECT 'x'
        FROM OKC_REACT_INTERVALS ril
       WHERE ril.rul_id = p_rul_rec.id;

    CURSOR l_rgr_csr IS
      -- SELECT NVL(rgr.optional_yn, 'N')
      SELECT decode(sign(nvl(rgr.min_cardinality, 0)), 1, 'N', 'Y')
        FROM OKC_RG_DEF_RULES rgr
       WHERE rgr.rdf_code = p_rul_rec.rule_information_category
         AND rgr.rgd_code = p_rgd_code;

/* -- /striping/
    CURSOR l_rul_csr IS
      SELECT fnd.MEANING
        FROM FND_LOOKUPS fnd
       WHERE fnd.LOOKUP_CODE = p_rul_rec.RULE_INFORMATION_CATEGORY
         AND fnd.LOOKUP_TYPE = 'OKC_RULE_DEF';
*/
-- /striping/
    CURSOR l_rul_csr IS
      SELECT MEANING
        FROM okc_rule_defs_v
       WHERE RULE_CODE = p_rul_rec.RULE_INFORMATION_CATEGORY;

--    l_rule_def FND_LOOKUPS.MEANING%TYPE;   -- /striping/
    l_rule_def okc_rule_defs_v.MEANING%TYPE;


    l_dummy VARCHAR2(1);
    l_optional_yn OKC_RG_DEF_RULES.OPTIONAL_YN%TYPE;

    l_token VARCHAR2(2000);
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    TYPE l_info_type IS REF CURSOR;
    l_info_csr             l_info_type;
    sql_stmt               VARCHAR2(2000);
    l_end_user_column_name FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE;
    l_rule_information     OKC_RULES_V.RULE_INFORMATION1%TYPE;
    l_flex_value_set_id    FND_DESCR_FLEX_COL_USAGE_VL.FLEX_VALUE_SET_ID%TYPE;
    l_required_flag        FND_DESCR_FLEX_COL_USAGE_VL.REQUIRED_FLAG%TYPE;

    l_missing_values VARCHAR2(1) := 'N';
    l_all_must_be_present BOOLEAN := False;

    l_adv_pricing_profile  VARCHAR2(10) := 'N';
    l_adv_pricing_warn     VARCHAR2(10) := 'N';

-- skekkar # 1586976
--    cursor l_flex_csr(p_rule_cat varchar2, p_attribute varchar2) is      -- /striping/
    cursor l_flex_csr(p_rule_cat varchar2, p_attribute varchar2, appl_id number, dff_name varchar2) is
      SELECT END_USER_COLUMN_NAME, FLEX_VALUE_SET_ID, REQUIRED_FLAG
        FROM FND_DESCR_FLEX_COLUMN_USAGES dfcu
--        WHERE dfcu.descriptive_flexfield_name = 'OKC Rule Developer DF'     -- /striping/
        WHERE dfcu.descriptive_flexfield_name = dff_name
        AND dfcu.descriptive_flex_context_code = p_rule_cat
        AND dfcu.application_column_name       =  p_attribute
--        AND dfcu.application_id =510;      -- /striping/
        AND dfcu.application_id = appl_id;
-- skekkar

   --
   l_proc varchar2(72) := g_package||'check_rule_values';
   --
  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check if the rule is a required rule
    OPEN  l_rgr_csr;
    FETCH l_rgr_csr INTO l_optional_yn;
    CLOSE l_rgr_csr;

   -- bug 1965956
   -- Added By skekkar
   -- If the Rule Group is 'PRICING' and if the Advanced Pricing Profile is enabled then we will
   -- ignore all Rules under 'PRICING' rule group and issue a warning to the user
       IF NVL(p_rgd_code,'XYZ') = 'PRICING' THEN
          IF (l_debug = 'Y') THEN
             okc_debug.Log('20: Pricing Rule Group  '||p_rgd_code,2);
          END IF;
         -- check the Advanced Pricing Profile value
            l_adv_pricing_profile := nvl(fnd_profile.value('OKC_ADVANCED_PRICING'), 'N');
            IF (l_debug = 'Y') THEN
               okc_debug.Log('30: Advance Pricing Profile : '||l_adv_pricing_profile,2);
            END IF;
             IF l_adv_pricing_profile = 'Y' THEN
               -- ignore this Rule and make it optional
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('40: Setting l_optional_yn to Y ',2);
                END IF;
                l_optional_yn := 'Y' ;
               -- warn the user , done at Rule Group Level
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('50: Issuing Warning To User ',2);
                END IF;
                l_adv_pricing_warn := 'Y';
             END IF; -- AP is 'Y'
       END IF; -- Rule Group is PRICING


    -- Loop through the rule definitions,
    -- the +3 is for the integration objects.
    FOR i IN 1..G_DF_COUNT+3 LOOP
      IF i = 1 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION1;
      ELSIF i = 2 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION2;
      ELSIF i = 3 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION3;
      ELSIF i = 4 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION4;
      ELSIF i = 5 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION5;
      ELSIF i = 6 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION6;
      ELSIF i = 7 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION7;
      ELSIF i = 8 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION8;
      ELSIF i = 9 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION9;
      ELSIF i = 10 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION10;
      ELSIF i = 11 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION11;
      ELSIF i = 12 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION12;
      ELSIF i = 13 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION13;
      ELSIF i = 14 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION14;
      ELSIF i = 15 THEN
        l_rule_information := p_rul_rec.RULE_INFORMATION15;
      ELSIF i = G_DF_COUNT+1 THEN
        l_rule_information := p_rul_rec.JTOT_OBJECT1_CODE;
      ELSIF i = G_DF_COUNT+2 THEN
        l_rule_information := p_rul_rec.JTOT_OBJECT2_CODE;
      ELSIF i = G_DF_COUNT+3 THEN
        l_rule_information := p_rul_rec.JTOT_OBJECT3_CODE;
      END IF;

/*
      -- SQL statement to retrieve the developer descriptive flex field information
      sql_stmt := 'SELECT END_USER_COLUMN_NAME, FLEX_VALUE_SET_ID, REQUIRED_FLAG ' ||
                  ' FROM FND_DESCR_FLEX_COL_USAGE_VL dfcu ' ||
                  ' WHERE dfcu.application_id=510 and dfcu.descriptive_flexfield_name = ' ||
                  ''''||G_DESCRIPTIVE_FLEXFIELD_NAME||'''' ||
                  '   AND dfcu.descriptive_flex_context_code = :rule_cat ' ||
                  '   AND dfcu.application_column_name       = :attribute' ;
*/
-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rul_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(p_rul_rec.rule_information_category);

      IF i <= G_DF_COUNT THEN
      -- skekkar # 1586976
      OPEN l_flex_csr(p_rul_rec.rule_information_category,
--                        'RULE_INFORMATION'||LTRIM(TO_CHAR(i)) );      -- /striping/
                        'RULE_INFORMATION'||LTRIM(TO_CHAR(i)), p_appl_id, p_dff_name );
      FETCH l_flex_csr INTO l_end_user_column_name, l_flex_value_set_id,
            l_required_flag;
      -- skekkar
/*
         OPEN l_info_csr
          FOR sql_stmt
        USING p_rul_rec.rule_information_category,
              'RULE_INFORMATION'||LTRIM(TO_CHAR(i));
        FETCH l_info_csr INTO l_end_user_column_name, l_flex_value_set_id,
              l_required_flag;
*/
      ELSE
      -- skekkar # 1586976
      OPEN l_flex_csr(p_rul_rec.rule_information_category,
--                        'JTOT_OBJECT'||LTRIM(TO_CHAR(i - G_DF_COUNT))||'_CODE');  -- /striping/
                        'JTOT_OBJECT'||LTRIM(TO_CHAR(i - G_DF_COUNT))||'_CODE', p_appl_id, p_dff_name);
      FETCH l_flex_csr INTO l_end_user_column_name, l_flex_value_set_id,
            l_required_flag;
      -- skekkar
/*
         OPEN l_info_csr
          FOR sql_stmt
        USING p_rul_rec.rule_information_category,
              'JTOT_OBJECT'||LTRIM(TO_CHAR(i - G_DF_COUNT))||'_CODE';
        FETCH l_info_csr INTO l_end_user_column_name, l_flex_value_set_id,
              l_required_flag;
*/
      END IF;

      IF l_flex_csr%NOTFOUND THEN
        l_end_user_column_name := NULL;
        l_flex_value_set_id    := NULL;
      END IF;
      CLOSE l_flex_csr;

/*
      IF l_info_csr%NOTFOUND THEN
        l_end_user_column_name := NULL;
        l_flex_value_set_id    := NULL;
      END IF;
      CLOSE l_info_csr;
*/

   -- bug 1965956
   -- Added By skekkar
   -- If the Rule Group is 'PRICING' and if the Advanced Pricing Profile is enabled then we will
   -- ignore all Rules under 'PRICING' rule group and issue a warning to the user
   -- If the Rule Segments have Required values , we set it to Not Required

       IF NVL(p_rgd_code,'XYZ') = 'PRICING' THEN
          IF (l_debug = 'Y') THEN
             okc_debug.Log('100: Pricing Rule Group  '||p_rgd_code,2);
          END IF;
         -- check the Advanced Pricing Profile value
            l_adv_pricing_profile := nvl(fnd_profile.value('OKC_ADVANCED_PRICING'), 'N');
            IF (l_debug = 'Y') THEN
               okc_debug.Log('110: Advance Pricing Profile : '||l_adv_pricing_profile,2);
            END IF;
             IF l_adv_pricing_profile = 'Y' THEN
               -- ignore this Rule and make it optional
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('120: Setting l_required_flag to N ',2);
                END IF;
                l_required_flag := 'N' ;
             END IF; -- AP is 'Y'
       END IF; -- Rule Group is PRICING


      -- if the attribute has been defined
      IF l_end_user_column_name IS NOT NULL THEN
	   IF l_optional_yn = 'Y' AND
           l_rule_information IS NOT NULL THEN
          l_all_must_be_present := True;
        END IF;
        -- check if data is required
        IF l_required_flag = 'Y' THEN
          -- data is required
          IF (l_rule_information = OKC_API.G_MISS_CHAR OR
              l_rule_information IS NULL) THEN
            l_missing_values := 'Y';
          END IF;
        END IF;
      END IF;
    END LOOP;

    -- get the rule meaning for the error messages
    OPEN  l_rul_csr;
    FETCH l_rul_csr INTO l_rule_def;
    CLOSE l_rul_csr;

    -- check if required data is missing for a required rule
    -- or a rule that has some information entered.
    IF l_missing_values = 'Y' THEN
      IF ((l_optional_yn = 'N') OR
          (l_optional_yn = 'Y' AND l_all_must_be_present)) THEN
        If p_chr_id Is Not Null Then
          g_msg_name := 'OKC_QA_K_RULE_VAL_MISSING';
          g_token := Null;
        Else
          g_msg_name := 'OKC_QA_KL_RULE_VAL_MISSING';
          g_token := g_line;
        End If;
        Set_QA_Message(p_chr_id => p_chr_id,
                       p_cle_id => p_cle_id,
                       p_msg_name => g_msg_name,
                       p_token1 => 'RULE',
                       p_token1_value => l_rule_def,
                       p_token2 => g_token);
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

/*
   Warning given at Rule Group Level
   -- skekkar, Bug 1965956
   -- issue warning if Pricing Rule used and Advanced Pricing Profile is set to Y
   --
     IF l_adv_pricing_warn = 'Y' THEN
       OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_PRICING_RULE_WARN');
     END IF;

*/

    -- There must be at least on child record in OKC_COVER_TIMES for a CVR rule
    IF (p_rul_rec.rule_information_category = 'CVR') THEN
      l_dummy := '?';
      -- check for record in cover times
      OPEN  l_cti_csr;
      FETCH l_cti_csr INTO l_dummy;
      CLOSE l_cti_csr;

      IF (l_dummy = '?') THEN
        If p_chr_id Is Not Null Then
          g_msg_name := 'OKC_QA_K_CVR_VALUE_MISSING';
          g_token := Null;
        Else
          g_msg_name := 'OKC_QA_KL_CVR_VALUE_MISSING';
          g_token := g_line;
        End If;
        Set_QA_Message(p_chr_id => p_chr_id,
                       p_cle_id => p_cle_id,
                       p_msg_name => g_msg_name,
                       p_token1 => 'RULE',
                       p_token1_value => l_rule_def,
                       p_token2 => g_token);
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    -- There must be at least on child record in OKC_REACT_INTERVALS for a rule
    IF (p_rul_rec.rule_information_category = 'RCN') THEN
      l_dummy := '?';
      -- check for record in cover times
      OPEN  l_ril_csr;
      FETCH l_ril_csr INTO l_dummy;
      CLOSE l_ril_csr;

      IF (l_dummy = '?') THEN
        If p_chr_id Is Not Null Then
          g_msg_name := 'OKC_QA_K_RCN_VALUE_MISSING';
          g_token := Null;
        Else
          g_msg_name := 'OKC_QA_KL_RCN_VALUE_MISSING';
          g_token := g_line;
        End If;
        Set_QA_Message(p_chr_id => p_chr_id,
                       p_cle_id => p_cle_id,
                       p_msg_name => g_msg_name,
                       p_token1 => 'RULE',
                       p_token1_value => l_rule_def,
                       p_token2 => g_token);
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    -- Bug 1496111. For Non-Service Contracts, check that for the renewal type of
    -- Notify Sales Rep 'NSR', the Contact information has been entered.
    -- Bug 1630898. Contacts must be defined for EVN/SFA also.
    If p_cls_code <> 'SERVICE' Then
      IF (p_rul_rec.rule_information_category = 'REN') And
	    (p_rul_rec.rule_information1 IN ('NSR', 'SFA', 'EVN')) And
	    ((p_rul_rec.rule_information2 Is Null) Or
	     (p_rul_rec.rule_information2 = OKC_API.G_MISS_CHAR)) Then

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKC_NO_CONTACT_FOR_NSR');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rgr_csr%ISOPEN THEN
      CLOSE l_rgr_csr;
    END IF;
    IF l_flex_csr%ISOPEN THEN
      CLOSE l_flex_csr;
    END IF;
    IF l_info_csr%ISOPEN THEN
      CLOSE l_info_csr;
    END IF;
    IF l_cti_csr%ISOPEN THEN
      CLOSE l_cti_csr;
    END IF;
    IF l_rul_csr%ISOPEN THEN
      CLOSE l_rul_csr;
    END IF;
  END check_rule_values;
--
  -- Start of comments
  --
  -- Procedure Name  : check_rule_groups
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_rule_groups(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    CURSOR l_chr_csr IS
      SELECT chr.*, sub.cls_code
        FROM OKC_K_HEADERS_B chr,
             OKC_SUBCLASSES_B sub
       WHERE chr.id = p_chr_id
         AND sub.code = chr.scs_code;
    l_chr_rec l_chr_csr%ROWTYPE;

-- use only for getting info about OKC_RULE_GROUP_DEF, don't use OKC_RULE_DEF -- /striping/
    CURSOR l_rgpm_csr IS
      SELECT fnd.MEANING
        FROM FND_LOOKUPS fnd
       WHERE fnd.LOOKUP_CODE = 'CURRENCY'
         AND fnd.LOOKUP_TYPE = 'OKC_RULE_GROUP_DEF';
      -- WHERE fnd.LOOKUP_CODE = 'CVN'
      --   AND fnd.LOOKUP_TYPE = 'OKC_RULE_DEF';
    l_rgpm_meaning FND_LOOKUPS.MEANING%TYPE;

    --
    -- modified as part of bug 2155930 (jkodiyan - 26/12/2001)
    -- Cursor to check Conversion rule at the header level with
    -- all required values
    -- p_rgd_code = 'SVC_K' for service contracts and
    --            = 'CURRENCY' for core contracts
    --
    CURSOR l_cvn_csr(p_rgd_code VARCHAR2) IS
       SELECT 'x'
       FROM OKC_RULE_GROUPS_B rgp, OKC_RULES_B rul
       WHERE rgp.rgd_code   = p_rgd_code
         AND rgp.dnz_chr_id = p_chr_id
	    AND rul.dnz_chr_id = rgp.dnz_chr_id
	    AND rgp.cle_id is null
	    AND rul.rgp_id = rgp.id
	    AND rul.rule_information_category = 'CVN'
	    AND rul.rule_information1 is not null
	    AND rul.rule_information2 is not null
	    AND rul.object1_id1 is not null;
/* -- /striping/
    CURSOR l_rgp_csr IS
      SELECT rgp.id, rgp.rgd_code, fnd.meaning rule_group_name,
             rgp.chr_id, rgp.cle_id,
             rgr.rdf_code, rgr.min_cardinality, rgr.max_cardinality,
             fnd1.meaning rule_name
        FROM FND_LOOKUPS fnd,
             FND_LOOKUPS fnd1,
             OKC_RG_DEF_RULES rgr,
             OKC_RULE_GROUPS_B rgp
       WHERE rgp.dnz_chr_id = p_chr_id
         AND fnd.lookup_code = rgp.rgd_code
         AND fnd.lookup_type = 'OKC_RULE_GROUP_DEF'
         AND rgr.rgd_code = rgp.rgd_code
         AND rgr.rdf_code = fnd1.lookup_code
         AND fnd1.lookup_type = 'OKC_RULE_DEF'
       ORDER BY rgp.id;
*/
-- /striping/
    CURSOR l_rgp_csr IS
      SELECT rgp.id, rgp.rgd_code, fnd.meaning rule_group_name,
             rgp.chr_id, rgp.cle_id,
             rgr.rdf_code, rgr.min_cardinality, rgr.max_cardinality,
             fnd1.meaning rule_name
        FROM FND_LOOKUPS fnd,
             okc_rule_defs_v fnd1,
             OKC_RG_DEF_RULES rgr,
             OKC_RULE_GROUPS_B rgp
       WHERE rgp.dnz_chr_id = p_chr_id
         AND fnd.lookup_code = rgp.rgd_code
         AND fnd.lookup_type = 'OKC_RULE_GROUP_DEF'
         AND rgr.rgd_code = rgp.rgd_code
         AND rgr.rdf_code = fnd1.rule_code
       ORDER BY rgp.id;

    l_rgp_rec l_rgp_csr%ROWTYPE;

    /* CURSOR l_rgr_csr(p_rgd_code IN okc_rg_def_rules.rgd_code%TYPE) IS
      SELECT rgr.rdf_code, rgr.min_cardinality, rgr.max_cardinality,
             fnd.meaning
        FROM OKC_RG_DEF_RULES rgr,
             FND_LOOKUPS fnd
       WHERE rgr.rgd_code = p_rgd_code
         AND rgr.rdf_code = fnd.lookup_code
         AND fnd.lookup_type = 'OKC_RULE_DEF';
    l_rgr_rec l_rgr_csr%ROWTYPE; */

    CURSOR l_rul_cnt_csr(p_rgp_id IN okc_rules_b.rgp_id%TYPE,
                         p_rdf_code IN okc_rules_b.rule_information_category%TYPE) IS
      SELECT count(*)
        FROM OKC_RULES_B rul
       WHERE rul.rule_information_category = p_rdf_code
         AND rul.rgp_id = p_rgp_id;
    l_rule_count Number;

    CURSOR l_rul_csr IS
      SELECT rul.*
        FROM OKC_RULES_B rul
       WHERE rgp_id = l_rgp_rec.id;

    l_rul_rec OKC_RULES_B%ROWTYPE;

    CURSOR l_cle_csr(p_id okc_k_lines_b.id%TYPE) IS
      SELECT cle.chr_id
        FROM OKC_K_LINES_B cle
       WHERE cle.id = p_id;
    l_cle_rec l_cle_csr%ROWTYPE;

    l_prev_rgp_rec_id Number := -1;
    l_token VARCHAR2(2000);
    l_dummy VARCHAR2(1);
    l_optional_yn OKC_RG_DEF_RULES.OPTIONAL_YN%TYPE;
    l_func_curr_code OKC_K_HEADERS_B.CURRENCY_CODE%TYPE;
    l_return_status VARCHAR2(1);

    l_adv_pricing_profile  VARCHAR2(10) := 'N';
    l_adv_pricing_warn     VARCHAR2(10) := 'N';

   --
   l_proc varchar2(72) := g_package||'check_rule_groups';
   --
  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- Get Contract Header info
    OPEN l_chr_csr;
    FETCH l_chr_csr INTO l_chr_rec;
    CLOSE l_chr_csr;

--/Rules migration/
--Rule group check should not be performed for other contract catregories
--apart from OKC/OKO/OKL

    If l_chr_rec.application_id not in (510,871,540) Then
	RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;
--/Rules migration/

    -- get the rules attached to the contract
    OPEN l_rgp_csr;
    LOOP
      FETCH l_rgp_csr INTO l_rgp_rec;
      EXIT WHEN l_rgp_csr%NOTFOUND;
      --
      -- Check that all required rules for the rule group
      -- have been associated.
      -- l_dummy := '?';
      /* For l_rgr_rec in l_rgr_csr(l_rgp_rec.rgd_code) Loop */
        Open l_rul_cnt_csr(l_rgp_rec.id, l_rgp_rec.rdf_code);
        Fetch l_rul_cnt_csr Into l_rule_count;
        Close l_rul_cnt_csr;

   -- bug 1965956
   -- Added By skekkar
   -- If the Rule Group is 'PRICING' and if the Advanced Pricing Profile is enabled then we will
   -- ignore all Rules under 'PRICING' rule group and issue a warning to the user
   -- set the l_rule_count to min_cardinality

       IF NVL(l_rgp_rec.rgd_code,'XYZ') = 'PRICING' THEN
          IF (l_debug = 'Y') THEN
             okc_debug.Log('200: Pricing Rule Group  '||l_rgp_rec.rgd_code,2);
          END IF;
         -- check the Advanced Pricing Profile value
            l_adv_pricing_profile := nvl(fnd_profile.value('OKC_ADVANCED_PRICING'), 'N');
             IF (l_debug = 'Y') THEN
                okc_debug.Log('210: Advance Pricing Profile : '||l_adv_pricing_profile,2);
             END IF;
             IF l_adv_pricing_profile = 'Y' THEN
               -- ignore this Rule and make it optional
                IF (l_debug = 'Y') THEN
                   okc_debug.Log('220: Setting l_rule_count to min_cardinality ',2);
                END IF;
                l_rule_count := nvl(l_rgp_rec.min_cardinality, 0);
                -- issue Warning to the user
                l_adv_pricing_warn := 'Y';
             END IF; -- AP is 'Y'
       END IF; -- Rule Group is PRICING

        IF l_rule_count < l_rgp_rec.min_cardinality Then
          If l_rgp_rec.chr_id Is Not Null Then
            g_msg_name := 'OKC_QA_K_RULE_MIN';
            g_token := Null;
          Else
            g_msg_name := 'OKC_QA_KL_RULE_MIN';
            g_token := g_line;
          End If;
          Set_QA_Message(p_chr_id => l_rgp_rec.chr_id,
                         p_cle_id => l_rgp_rec.cle_id,
                         p_msg_name => g_msg_name,
                         p_token1 => 'NUM_OF_RULE',
                         p_token1_value => l_rgp_rec.min_cardinality,
                         p_token2 => 'RULE',
                         p_token2_value => l_rgp_rec.rule_name,
                         p_token3 => g_token);
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
        --
        IF l_rule_count > l_rgp_rec.max_cardinality Then
          If l_rgp_rec.chr_id Is Not Null Then
            g_msg_name := 'OKC_QA_K_RULE_MAX';
            g_token := Null;
          Else
            g_msg_name := 'OKC_QA_KL_RULE_MAX';
            g_token := g_line;
          End If;
          Set_QA_Message(p_chr_id => l_rgp_rec.chr_id,
                         p_cle_id => l_rgp_rec.cle_id,
                         p_msg_name => g_msg_name,
                         p_token1 => 'NUM_OF_RULE',
                         p_token1_value => l_rgp_rec.max_cardinality,
                         p_token2 => 'RULE',
                         p_token2_value => l_rgp_rec.rule_name,
                         p_token3 => g_token);
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
      -- End Loop; -- l_rgr_csr

      If l_rgp_rec.id <> l_prev_rgp_rec_id Then
        OPEN l_rul_csr;
        LOOP
          FETCH l_rul_csr INTO l_rul_rec;
          EXIT WHEN l_rul_csr%NOTFOUND;
          check_rule_values(l_return_status, l_rul_rec,
                            l_rgp_rec.rgd_code, l_rgp_rec.id,
                            l_rgp_rec.chr_id, l_rgp_rec.cle_id,
                            l_chr_rec.cls_code);
          IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
        END LOOP; -- l_rul_csr;
        CLOSE l_rul_csr;
        l_prev_rgp_rec_id := l_rgp_rec.id;
      End If;
    END LOOP; -- l_rgp_csr
    CLOSE l_rgp_csr;

-- Bug 2357950
    --l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY();
    l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_chr_rec.authoring_org_id);
---
    IF l_chr_rec.currency_code <> l_func_curr_code  AND
    --/rules migration/
    --Don't check conversion rule fro Non OKC/OKO contracts
       l_chr_rec.application_id in (510,871) THEN
      -- Check for conversion rule, which is required if
      -- currency code is different from the functional currency
      l_dummy := '?';

      -- modified for bug# 1413682 - tsaifee 09/21/00
      -- For service Ks use l_cvn_csr which uses SVC_K rule grp.
	 -- modified for bug# 2155930 - jkodiyan 26/12/01
	 --
      IF l_chr_rec.cls_code = 'SERVICE' then -- if SERVICE, then use
         OPEN  l_cvn_csr('SVC_K');
      ELSE
         OPEN  l_cvn_csr('CURRENCY');
      END IF;

      FETCH l_cvn_csr INTO l_dummy;
      CLOSE l_cvn_csr;

      IF (l_dummy <> 'x') THEN
        -- get the rule group meaning for the error message
        OPEN  l_rgpm_csr;
        FETCH l_rgpm_csr INTO l_rgpm_meaning;
        CLOSE l_rgpm_csr;

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_RULE_GROUP,
          p_token1       => 'RULE_GROUP',
          p_token1_value => l_rgpm_meaning);
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;


    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN

     -- since there were no errors , we will issue warning depending on l_adv_pricing_warn flag
        -- Bug 1965956
        -- skekkar
        -- issue warning if Pricing Rule Group used and Advanced Pricing Profile is set to Y
        --
           IF l_adv_pricing_warn = 'Y' THEN
              OKC_API.set_message(
                       p_app_name     => G_APP_NAME,
                       p_msg_name     => 'OKC_PRICING_RULE_WARN');
               -- notify caller of an warning
               x_return_status := OKC_API.G_RET_STS_WARNING;
           ELSE
              OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_QA_SUCCESS);
           END IF;  -- l_adv_pricing_warn = 'Y'

    END IF; -- x_return_status is SUCCESS


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    /* IF l_rgr_csr%ISOPEN THEN
      CLOSE l_rgr_csr;
    END IF; */
    IF l_rgp_csr%ISOPEN THEN
      CLOSE l_rgp_csr;
    END IF;
    IF l_rul_csr%ISOPEN THEN
      CLOSE l_rgp_csr;
    END IF;
    IF l_chr_csr%ISOPEN THEN
      CLOSE l_chr_csr;
    END IF;
    IF l_rgpm_csr%ISOPEN THEN
      CLOSE l_rgpm_csr;
    END IF;
  END check_rule_groups;
--
  -- Start of comments
  --
  -- Procedure Name  : check_rule_group_parties
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_rule_group_parties(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    CURSOR l_chr_csr IS
      SELECT chr.template_yn,chr.application_id
        FROM OKC_K_HEADERS_B chr
       WHERE chr.id = p_chr_id;
    l_template_yn OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;

    CURSOR l_rrd_csr IS
      SELECT rgp.id "RGP_ID", rrd.id "RRD_ID", rgp.rgd_code , sre.rle_code,
             fndrgd.meaning "RGD_MEANING", fndrle.meaning "RLE_MEANING",
             rgp.chr_id, rgp.cle_id
        FROM FND_LOOKUPS fndrle,
             FND_LOOKUPS fndrgd,
             OKC_SUBCLASS_ROLES sre,
             OKC_RG_ROLE_DEFS rrd,
             OKC_SUBCLASS_RG_DEFS srd,
             OKC_RULE_GROUPS_B rgp,
             OKC_K_HEADERS_B chr
       WHERE fndrle.LOOKUP_CODE = sre.rle_code
         AND fndrle.LOOKUP_TYPE = 'OKC_ROLE'
         AND fndrgd.LOOKUP_CODE = srd.rgd_code
         AND fndrgd.LOOKUP_TYPE = 'OKC_RULE_GROUP_DEF'
         AND sre.id         = rrd.sre_id
         AND NVL(rrd.optional_yn, 'N') = 'N'
         AND rrd.srd_id     = srd.id
         AND srd.rgd_code   = rgp.rgd_code
         AND srd.scs_code   = chr.scs_code
         AND rgp.dnz_chr_id = chr.id
         AND chr.id         = p_chr_id;
    l_rrd_rec l_rrd_csr%ROWTYPE;

    CURSOR l_rpr_csr IS
      SELECT rpr.cpl_id
        FROM OKC_RG_PARTY_ROLES rpr
       WHERE rpr.rgp_id = l_rrd_rec.rgp_id
         AND rpr.rrd_id = l_rrd_rec.rrd_id;
       -- WHERE (rpr.cpl_id IS NOT NULL or l_template_yn = 'Y')

    l_cpl_id OKC_RG_PARTY_ROLES.CPL_ID%TYPE;

    CURSOR l_kpr_csr(p_id OKC_K_PARTY_ROLES_B.ID%TYPE) IS
	 SELECT kpr.rle_code, fl.meaning
	   FROM OKC_K_PARTY_ROLES_B kpr,
                FND_LOOKUPS fl
          WHERE kpr.id = p_id
	    AND fl.lookup_type = 'OKC_ROLE'
	    AND fl.lookup_code = kpr.rle_code;

    l_kpr_rec l_kpr_csr%ROWTYPE;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    l_adv_pricing_profile  VARCHAR2(10) := 'N';
    l_appl_id NUMBER;
   --
   l_proc varchar2(72) := g_package||'check_rule_group_parties';
   --

    PROCEDURE Set_Rule_Party_Message IS
      l_token VARCHAR2(2000);
       --
       l_proc varchar2(72) := g_package||'Set_Rule_Party_Message';
       --
    BEGIN

      IF (l_debug = 'Y') THEN
         okc_debug.Set_Indentation(l_proc);
         okc_debug.Log('10: Entering ',2);
      END IF;
      If l_rrd_rec.chr_id Is Not Null Then
        g_msg_name := 'OKC_QA_K_RGP_ROLE_MISSING';
        g_token := Null;
      Else
        g_msg_name := 'OKC_QA_KL_RGP_ROLE_MISSING';
        g_token := g_line;
      End If;
      Set_QA_Message(p_chr_id       => l_rrd_rec.chr_id,
                     p_cle_id       => l_rrd_rec.cle_id,
                     p_msg_name     => g_msg_name,
                     p_token1       => 'ROLE',
                     p_token1_value => l_rrd_rec.rle_meaning,
                     p_token2       => 'RULE_GROUP',
                     p_token2_value => l_rrd_rec.rgd_meaning,
                     p_token3       => g_token);

      IF (l_debug = 'Y') THEN
         okc_debug.Log('1000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
    END;

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- get template info from contract header
    OPEN l_chr_csr;
    FETCH l_chr_csr INTO l_template_yn,l_appl_id;
    CLOSE l_chr_csr;

--/Rules migration/
--Rule party check should not be performed for other contract catregories
--apart from OKC/OKO/OKL

    If l_appl_id not in (510,871,540) Then
     RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;
--/Rules migration/

    --
    -- For all of the rules attached to a contract
    -- check that all required rule party roles have
    -- been assigned.
    OPEN  l_rrd_csr;
    LOOP
      FETCH l_rrd_csr INTO l_rrd_rec;
      EXIT WHEN l_rrd_csr%NOTFOUND;
      --
      -- Check that all required party roles have been
      -- attached to a rule group.
      OPEN l_rpr_csr;
        LOOP
        FETCH l_rpr_csr INTO l_cpl_id;
        EXIT WHEN l_rpr_csr%NOTFOUND;
          IF l_template_yn = 'N' THEN
            IF l_cpl_id IS NULL THEN
              Set_Rule_Party_Message;
              x_return_status := OKC_API.G_RET_STS_ERROR;
            ELSE
              OPEN l_kpr_csr(l_cpl_id);
              FETCH l_kpr_csr INTO l_kpr_rec;
              l_row_notfound := l_kpr_csr%NOTFOUND;
              CLOSE l_kpr_csr;
              IF l_row_notfound THEN
                If l_rrd_rec.chr_id Is Not Null Then
                  g_msg_name := 'OKC_QA_K_RULE_ROLE_DELETED';
                  g_token := Null;
                Else
                  g_msg_name := 'OKC_QA_KL_RULE_ROLE_DELETED';
                  g_token := g_line;
                End If;
                Set_QA_Message(p_chr_id       => l_rrd_rec.chr_id,
                               p_cle_id       => l_rrd_rec.cle_id,
                               p_msg_name     => g_msg_name,
                               p_token1       => 'ROLE',
                               p_token1_value => l_rrd_rec.rle_meaning,
                               p_token2       => 'RULE_GROUP',
                               p_token2_value => l_rrd_rec.rgd_meaning,
                               p_token3       => g_token);
                x_return_status := OKC_API.G_RET_STS_ERROR;
              ELSIF l_kpr_rec.rle_code <> l_rrd_rec.rle_code THEN
                If l_rrd_rec.chr_id Is Not Null Then
                  g_msg_name := 'OKC_QA_K_RULE_ROLE_CHANGED';
                  g_token := Null;
                Else
                  g_msg_name := 'OKC_QA_KL_RULE_ROLE_CHANGED';
                  g_token := g_line;
                End If;
                Set_QA_Message(p_chr_id       => l_rrd_rec.chr_id,
                               p_cle_id       => l_rrd_rec.cle_id,
                               p_msg_name     => g_msg_name,
                               p_token1       => 'ROLE1',
                               p_token1_value => l_rrd_rec.rle_meaning,
                               p_token2       => 'RULE_GROUP',
                               p_token2_value => l_rrd_rec.rgd_meaning,
                               p_token3       => 'ROLE2',
                               p_token3_value => l_kpr_rec.meaning,
                               p_token4       => g_token);
                x_return_status := OKC_API.G_RET_STS_ERROR;
              END IF;
            END IF;
          END IF;
        END LOOP; --l_rpr_csr

      IF l_rpr_csr%ROWCOUNT <= 0 THEN
        -- Bug 1965956
        -- skekkar
        -- check if the Rule Group is Pricing
        IF (l_debug = 'Y') THEN
           okc_debug.Log('20:Rowcount is 0 , rgd_code is : '||l_rrd_rec.rgd_code,2);
        END IF;
        IF NVL(l_rrd_rec.rgd_code,'XYZ') = 'PRICING' THEN
          -- check the Advanced Pricing Profile value
          l_adv_pricing_profile := nvl(fnd_profile.value('OKC_ADVANCED_PRICING'), 'N');
          IF (l_debug = 'Y') THEN
             okc_debug.Log('40: Advance Pricing Profile : '||l_adv_pricing_profile,2);
          END IF;

          IF l_adv_pricing_profile = 'N' THEN
            -- Rule Group Party Role is missing.
            -- notify caller of an error
            IF (l_debug = 'Y') THEN
               okc_debug.Log('100: Rule Group Party Role is missing ',2);
            END IF;
            Set_Rule_Party_Message;
            x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF; -- l_adv_pricing_profile is N

        ELSE
          -- rule group is NOT Pricing, error
          IF (l_debug = 'Y') THEN
             okc_debug.Log('50: rule group is NOT Pricing , error ',2);
          END IF;
          -- Rule Group Party Role is missing.
          -- notify caller of an error
          IF (l_debug = 'Y') THEN
             okc_debug.Log('200: Rule Group Party Role is missing ',2);
          END IF;
          Set_Rule_Party_Message;
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF; -- rule group is Pricing

      END IF; -- rowcount is 0
      CLOSE l_rpr_csr;
    END LOOP; --l_rrd_csr
    CLOSE l_rrd_csr;

    -- notify caller of success
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_chr_csr%ISOPEN THEN
      CLOSE l_chr_csr;
    END IF;
    IF l_rrd_csr%ISOPEN THEN
      CLOSE l_rrd_csr;
    END IF;
    IF l_rpr_csr%ISOPEN THEN
      CLOSE l_rpr_csr;
    END IF;
  END check_rule_group_parties;
--
  -- Start of comments
  --
  -- Procedure Name  : check_effectivity_dates
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_effectivity_dates(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER) IS

    CURSOR l_chrv_csr IS
      SELECT start_date, end_date
        FROM OKC_K_HEADERS_B chrv
       WHERE chrv.id = p_chr_id;

    CURSOR l_cle_csr IS
	 /**
      SELECT level, start_date, end_date, line_number,
             id, chr_id, cle_id,lse_id
        FROM OKC_K_LINES_B
	WHERE date_cancelled is null	--changes [llc]-- bug #4727744 -- to ignore cancelled lines
       START WITH chr_id = p_chr_id
     CONNECT BY PRIOR id = cle_id
     AND date_cancelled is NULL;          --changes [llc]-- to ignore cancelled sublines
	**/
     --bug 5442886
     SELECT kla.start_date, kla.end_date,
            kla.id, kla.chr_id, kla.lse_id,
            --
            klb.start_date parent_start_date, klb.end_date parent_end_date
     FROM okc_k_lines_b kla,
          okc_k_lines_b klb
     WHERE kla.dnz_chr_id = p_chr_id
     AND   kla.cle_id = klb.id (+)
     AND   kla.date_cancelled is NULL
     AND   klb.date_cancelled is NULL;


    CURSOR l_clev_csr (p_cle_id NUMBER) IS
    SELECT Rtrim(Rtrim(cle.line_number) || ', ' || lse.name ||
                                           ' ' || cle.name) "LINE_NAME"
      FROM OKC_LINE_STYLES_TL lse,
           OKC_K_LINES_V cle
     WHERE cle.id = p_cle_id
       and lse.id = cle.lse_id
       and lse.language = userenv('LANG');

    l_chrv_rec l_chrv_csr%ROWTYPE;
    l_line_name Varchar2(2000);


    -- l_cle_rec l_cle_csr%ROWTYPE;
    --TYPE l_cle_tbl_type is table of l_cle_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    --l_cle_tbl l_cle_tbl_type;


    TYPE dte_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_start_date_tbl        dte_tbl_type;
    l_end_date_tbl          dte_tbl_type;
    l_id_tbl                num_tbl_type;
    l_chr_id_tbl            num_tbl_type;
    l_lse_id_tbl            num_tbl_type;
    l_parent_start_date_tbl dte_tbl_type;
    l_parent_end_date_tbl   dte_tbl_type;


    l_clev_rec l_clev_csr%ROWTYPE;
    l_index Number;
    l_prev_level Number := 0;
    l_parent_start_date DATE;
    l_parent_end_date DATE;
    l_parent_found Boolean;
    l_row_notfound Boolean;
    l_error_number Varchar2(4);
    l_return_status Varchar2(1);

   --
   l_proc varchar2(72) := g_package||'check_effectivity_dates';
   --
  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that start date is less than end date
    OPEN  l_chrv_csr;
    FETCH l_chrv_csr INTO l_chrv_rec;
    CLOSE l_chrv_csr;

    -- data is required
    IF (l_chrv_rec.start_date IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKC_QA_START_DATE_REQUIRED');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (l_chrv_rec.start_date > NVL(l_chrv_rec.end_date, l_chrv_rec.start_date)) THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_INVALID_END_DATE);
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Loop thru the contract sub lines

    /***********************************************
    FOR l_cle_rec IN l_cle_csr LOOP
      If l_cle_rec.chr_id Is Not Null Then
        l_parent_start_date := l_chrv_rec.start_date;
        l_parent_end_date   := l_chrv_rec.end_date;
        l_cle_tbl.delete;
        l_index := 1;
      Else
        If l_cle_rec.level <> l_prev_level Then
	     l_parent_found := False;
          If l_cle_tbl.COUNT > 0 Then
            FOR i IN l_cle_tbl.FIRST .. l_cle_tbl.LAST LOOP
              If l_cle_tbl(i).id = l_cle_rec.cle_id Then
                l_parent_start_date := l_cle_tbl(i).start_date;
                l_parent_end_date := l_cle_tbl(i).end_date;
                l_parent_found := True;
                Exit;
              End If;
            End Loop;
          End If;
          If Not l_parent_found Then
            -- Control should never reach here. It means something
            -- wrong with the data.
            l_parent_start_date := l_chrv_rec.start_date;
            l_parent_end_date   := l_chrv_rec.end_date;
	  End If;
        End If;
      End If;
      l_cle_tbl(l_index).id := l_cle_rec.id;
      l_cle_tbl(l_index).start_date := l_cle_rec.start_date;
      l_cle_tbl(l_index).end_date := l_cle_rec.end_date;
      l_index := l_index + 1;
      l_prev_level := l_cle_rec.level;
      l_error_number := '0000';

      -- data is required
      IF (l_cle_rec.start_date IS NULL) THEN
        l_error_number := '1000';
      END IF;

      IF (l_cle_rec.start_date > NVL(l_cle_rec.end_date, l_cle_rec.start_date)) THEN
        l_error_number := substr(l_error_number, 1, 1) || '100';
      END IF;

      IF (l_cle_rec.end_date IS NULL AND
          l_parent_end_date IS NOT NULL) THEN
        l_error_number := substr(l_error_number, 1, 2) || '10';
      END IF;

      IF ((l_cle_rec.start_date NOT BETWEEN l_parent_start_date AND
           NVL(l_parent_end_date, l_cle_rec.start_date)) OR
          (l_cle_rec.end_date IS NOT NULL AND l_cle_rec.end_date NOT BETWEEN
           l_parent_start_date AND NVL(l_parent_end_date, l_cle_rec.end_date))) THEN
          --below if condition added for bug#3339185
          if ((l_cle_rec.lse_id >=2 and l_cle_rec.lse_id <=6) or (l_cle_rec.lse_id=15)or (l_cle_rec.lse_id=16) or (l_cle_rec.lse_id=17)
             or (l_cle_rec.lse_id>=21 and l_cle_rec.lse_id <=24)) then
              l_error_number := substr(l_error_number, 1, 3) || '2';  --coverage lines
          else --non coverage lines
            l_error_number := substr(l_error_number, 1, 3) || '1';
          end if;
        --l_error_number := substr(l_error_number, 1, 3) || '1';
      END IF;
      --at below if statement,added second condition for bug#3339185
      If (Instr(l_error_number, '1') > 0 or Instr(l_error_number, '2') > 0) Then
        x_return_status := OKC_API.G_RET_STS_ERROR;
        l_line_name := okc_contract_pub.get_concat_line_no(l_cle_rec.id, l_return_status);
        IF l_return_status <> okc_api.g_ret_sts_success THEN
          l_line_name := 'Unknown';
        END IF;

        If Substr(l_error_number, 1, 1) = '1' Then
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKC_QA_LINE_SDATE_REQUIRED',
            p_token1       => 'LINE_NAME',
            p_token1_value => l_line_name);
        End If;

        If Substr(l_error_number, 2, 1) = '1' Then
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_INVALID_LINE_DATES,
            p_token1       => 'LINE_NAME',
            p_token1_value => l_line_name);
        End If;

        If Substr(l_error_number, 3, 1) = '1' Then
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKC_QA_LINE_EDATE_REQUIRED',
            p_token1       => 'LINE_NAME',
            p_token1_value => l_line_name);
        End If;

        If Substr(l_error_number, 4, 1) = '1' Then
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_INVALID_LINE_DATES,
            p_token1       => 'LINE_NAME',
            p_token1_value => l_line_name);
        End If;
        --below condition added for bug#3339185
        If Substr(l_error_number, 4, 1) = '2' Then
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_INVALID_COVERAGELINE_DATES,
            p_token1       => 'LINE_NAME',
            p_token1_value => l_line_name);
        End If;
      End If;

    END LOOP;   -- Lines attached to header
    ***********************************************/


    --added for bug 5442886
    OPEN l_cle_csr;
    LOOP

      FETCH l_cle_csr BULK COLLECT INTO l_start_date_tbl, l_end_date_tbl, l_id_tbl,
                                        l_chr_id_tbl, l_lse_id_tbl, l_parent_start_date_tbl,
                                        l_parent_end_date_tbl LIMIT G_BULK_FETCH_LIMIT;

      EXIT WHEN l_id_tbl.COUNT = 0;

      FOR i IN l_id_tbl.FIRST..l_id_tbl.LAST LOOP

          If l_chr_id_tbl(i) Is Not Null Then
             l_parent_start_date := l_chrv_rec.start_date;
             l_parent_end_date   := l_chrv_rec.end_date;
          Else
             l_parent_start_date := l_parent_start_date_tbl(i);
             l_parent_end_date   := l_parent_end_date_tbl(i);
	     End if;

          l_error_number := '0000';

          -- data is required
          IF (l_start_date_tbl(i) IS NULL) THEN
            l_error_number := '1000';
          END IF;

          IF (l_start_date_tbl(i) > NVL(l_end_date_tbl(i), l_start_date_tbl(i))) THEN
            l_error_number := substr(l_error_number, 1, 1) || '100';
          END IF;

          IF (l_end_date_tbl(i) IS NULL AND
              l_parent_end_date IS NOT NULL) THEN
            l_error_number := substr(l_error_number, 1, 2) || '10';
          END IF;

          IF ((l_start_date_tbl(i) NOT BETWEEN l_parent_start_date AND
               NVL(l_parent_end_date, l_start_date_tbl(i))) OR
              (l_end_date_tbl(i) IS NOT NULL AND l_end_date_tbl(i) NOT BETWEEN
               l_parent_start_date AND NVL(l_parent_end_date, l_end_date_tbl(i)))) THEN
              --below if condition added for bug#3339185
              if ((l_lse_id_tbl(i) >=2 and l_lse_id_tbl(i) <=6) or (l_lse_id_tbl(i)=15)or (l_lse_id_tbl(i)=16) or (l_lse_id_tbl(i)=17)
                 or (l_lse_id_tbl(i)>=21 and l_lse_id_tbl(i) <=24)) then
                  l_error_number := substr(l_error_number, 1, 3) || '2';  --coverage lines
              else --non coverage lines
                l_error_number := substr(l_error_number, 1, 3) || '1';
              end if;
            --l_error_number := substr(l_error_number, 1, 3) || '1';
          END IF;
          --at below if statement,added second condition for bug#3339185
          If (Instr(l_error_number, '1') > 0 or Instr(l_error_number, '2') > 0) Then
            x_return_status := OKC_API.G_RET_STS_ERROR;
            l_line_name := okc_contract_pub.get_concat_line_no(l_id_tbl(i), l_return_status);
            IF l_return_status <> okc_api.g_ret_sts_success THEN
              l_line_name := 'Unknown';
            END IF;

            If Substr(l_error_number, 1, 1) = '1' Then
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_QA_LINE_SDATE_REQUIRED',
                p_token1       => 'LINE_NAME',
                p_token1_value => l_line_name);
            End If;

            If Substr(l_error_number, 2, 1) = '1' Then
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => G_INVALID_LINE_DATES,
                p_token1       => 'LINE_NAME',
                p_token1_value => l_line_name);
            End If;

            If Substr(l_error_number, 3, 1) = '1' Then
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKC_QA_LINE_EDATE_REQUIRED',
                p_token1       => 'LINE_NAME',
                p_token1_value => l_line_name);
            End If;

            If Substr(l_error_number, 4, 1) = '1' Then
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => G_INVALID_LINE_DATES,
                p_token1       => 'LINE_NAME',
                p_token1_value => l_line_name);
            End If;
            --below condition added for bug#3339185
            If Substr(l_error_number, 4, 1) = '2' Then
              OKC_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => G_INVALID_COVERAGELINE_DATES,
                p_token1       => 'LINE_NAME',
                p_token1_value => l_line_name);
            End If;
          End If;


      END LOOP;

    END LOOP;   -- Lines attached to header




    -- notify caller of success
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_chrv_csr%ISOPEN THEN
      CLOSE l_chrv_csr;
    END IF;
    IF l_cle_csr%ISOPEN THEN
      CLOSE l_cle_csr;
    END IF;
    IF l_clev_csr%ISOPEN THEN
      CLOSE l_clev_csr;
    END IF;
  END check_effectivity_dates;
--

END OKC_QA_DATA_INTEGRITY;

/
