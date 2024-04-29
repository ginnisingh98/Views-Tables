--------------------------------------------------------
--  DDL for Package Body OKC_RUL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RUL_PVT" AS
/* $Header: OKCSRULB.pls 120.0 2005/05/26 09:43:31 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- skekkar
--  Global variables
--TYPE num_tbl_type is table of number index by binary_integer;
--TYPE varchar_tbl_type is table of varchar2(30) index by binary_integer;

/* added by marat -- begin */
--TYPE varchar_tbl_type1 is table of fnd_descr_flex_col_usage_vl.descriptive_flex_context_code%type index by binary_integer;
--TYPE varchar_tbl_type2 is table of fnd_descr_flex_col_usage_vl.end_user_column_name%type index by binary_integer;
--TYPE varchar_tbl_type3 is table of fnd_descr_flex_col_usage_vl.required_flag%type index by binary_integer;
--TYPE varchar_tbl_type4 is table of fnd_descr_flex_col_usage_vl.application_column_name%type index by binary_integer;
--TYPE varchar_tbl_type5 is table of fnd_descr_flex_col_usage_vl.form_left_prompt%type index by binary_integer;
/* added by marat -- end */

/* modified by marat -- begin */
--g_ddf_context_code_tbl          varchar_tbl_type1; -- holds descriptive_flex_context_code
--g_end_user_col_name_tbl         varchar_tbl_type2; -- holds END_USER_COLUMN_NAME
--g_flex_value_set_id_tbl         num_tbl_type;     -- holds FLEX_VALUE_SET_ID
--g_required_flag_tbl             varchar_tbl_type3; -- holds REQUIRED_FLAG
--g_app_col_name_tbl              varchar_tbl_type4; -- holds APPLICATION_COLUMN_NAME
--g_col_seq_no_tbl                varchar_tbl_type; -- holds column seqence no
--g_form_left_prompt_tbl          varchar_tbl_type5; -- holds form_left_prompt
/* modified by marat -- end */

-- changed by msengupt regarding bug#2195697 tbl_type to tbl_type1 and tbl_type5

--g_obj_ddf_context_code_tbl      varchar_tbl_type1; -- holds descriptive_flex_context_code
--g_obj_x_tbl                     varchar_tbl_type; -- holds x
--g_obj_col_seq_no_tbl            varchar_tbl_type; -- holds column seqence no
--g_obj_form_left_prompt_tbl      varchar_tbl_type5; -- holds form_left_prompt

-- Cursors -- added 19-MAR-2002 by rgalipo -- performance bug

CURSOR c_flex_col_usage (p_context_code varchar2) IS
SELECT descriptive_flex_context_code
      ,end_user_column_name
      ,flex_value_set_id
      ,required_flag
      ,application_column_name
      ,seq_no
      ,form_left_prompt
FROM   okc_ddf_contextcode_tmp
WHERE  descriptive_flex_context_code = p_context_code
ORDER BY seq_no;

CURSOR c_descr_flex_col (p_context_code varchar2) IS
SELECT descriptive_flex_context_code
      ,dummy_col
      ,seq_no
      ,form_left_prompt
FROM   okc_obj_ddf_ctxcode_tmp
WHERE descriptive_flex_context_code = p_context_code
ORDER BY seq_no;


PROCEDURE populate_global_tab
(
   p_rulv_rec                      IN    rulv_rec_type,
   x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE populate_obj_global_tab
(
   p_rulv_rec                      IN    rulv_rec_type,
   x_return_status                OUT NOCOPY VARCHAR2
);

p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

-- skekkar
--


/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_rulv_rec IN  rulv_rec_type) RETURN VARCHAR2;
--  G_DESCRIPTIVE_FLEXFIELD_NAME CONSTANT VARCHAR2(200) := 'OKC Rule Developer DF'; -- don't use the constant /striping/
  G_NO_PARENT_RECORD           CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_LEN_CHK                    CONSTANT VARCHAR2(200) := 'OKC_LENGTH_EXCEEDS';
  G_COL_LEN                    CONSTANT VARCHAR2(30)  := 'COL_LEN';
  G_NO_DEVELOPER_FLEX_DEFINED  CONSTANT VARCHAR2(200) := 'OKC_NO_DEVELOPER_FLEX_DEFINED';
  G_NO_VALUE_SET_DEFINED       CONSTANT VARCHAR2(200) := 'OKC_NO_VALUE_SET_DEFINED';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN	       CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_VIEW                       CONSTANT VARCHAR2(200) := 'OKC_RULES_V';
  G_DF_COUNT                   CONSTANT NUMBER(2)     := 15;
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  g_return_status	       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  g_clob_used                  VARCHAR2(1) := 'N';
  g_package                    varchar2(33) := '  OKC_RUL_PVT.';

  -- Start of comments
  --
  -- Procedure Name  : validate_rgp_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rgp_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rgpv_csr IS
      SELECT 'x'
        FROM OKC_RULE_GROUPS_B rgpv
       WHERE rgpv.ID = p_rulv_rec.RGP_ID;
   --
   l_proc varchar2(72) := g_package||'validate_rgp_id';
   --
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

/* The following part has been changed to check for DFF in case of rule templates */

    -- data is required only if template_yn <> 'Y'
    IF (p_rulv_rec.rgp_id = OKC_API.G_MISS_NUM OR
        p_rulv_rec.rgp_id IS NULL) THEN
      IF NVL(p_rulv_rec.template_yn,'N') <> 'Y' THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'rgp_id');

      -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        RETURN;
      END IF;
    END IF;

    -- enforce foreign key
    OPEN  l_rgpv_csr;
    FETCH l_rgpv_csr INTO l_dummy_var;
    CLOSE l_rgpv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'rgp_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_RULE_GROUPS_V');
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN


    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN


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
    IF l_rgpv_csr%ISOPEN THEN
      CLOSE l_rgpv_csr;
    END IF;
  END validate_rgp_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_std_template_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_std_template_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'validate_std_template_yn';
   --
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rulv_rec.std_template_yn = OKC_API.G_MISS_CHAR OR
        p_rulv_rec.std_template_yn IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'std_template_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check allowed values
    IF (UPPER(p_rulv_rec.std_template_yn) NOT IN ('Y','N')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'std_template_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;




  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN


    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN


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
  END validate_std_template_yn;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_template_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_template_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'validate_template_yn';
   --
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check allowed values
    IF (UPPER(NVL(p_rulv_rec.template_yn,'N')) NOT IN ('Y','N')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'template_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;




  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN


    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN


    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
  END validate_template_yn;


  -- Start of comments
  --
  -- Procedure Name  : validate_dnz_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_dnz_chr_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_chrv_csr IS
      SELECT 'x'
        FROM OKC_K_HEADERS_B chrv
       WHERE chrv.ID = p_rulv_rec.DNZ_CHR_ID;
   --
   l_proc varchar2(72) := g_package||'validate_dnz_chr_id';
   --
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required if std template is no
    /*  Commented as per Bug 2734573/2754239
    IF p_rulv_rec.std_template_yn = 'N' or
       nvl(p_rulv_rec.template_yn,'N') <> 'Y' THEN */
     --  Modified as per Bug 2734573/2754239 - No validation is required for dnz_chr_id if it is Template
	IF p_rulv_rec.std_template_yn = 'Y' or
	   nvl(p_rulv_rec.template_yn,'N') = 'Y' THEN
        NULL;
     ELSE
      -- data required
      IF (p_rulv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_rulv_rec.dnz_chr_id IS NULL) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'dnz_chr_id');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

     -- check for data before processing
    IF (p_rulv_rec.dnz_chr_id <> OKC_API.G_MISS_NUM OR
        p_rulv_rec.dnz_chr_id IS NOT NULL) THEN

      -- enforce foreign key
      OPEN  l_chrv_csr;
      FETCH l_chrv_csr INTO l_dummy_var;
      CLOSE l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_NO_PARENT_RECORD,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'dnz_chr_id',
          p_token2        => G_CHILD_TABLE_TOKEN,
          p_token2_value  => G_VIEW,
          p_token3        => G_PARENT_TABLE_TOKEN,
          p_token3_value  => 'OKC_K_HEADERS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;




  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN


    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN


    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_chrv_csr%ISOPEN THEN
      CLOSE l_chrv_csr;
    END IF;
  END validate_dnz_chr_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_warn_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_warn_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'validate_warn_yn';
   --
  BEGIN




    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rulv_rec.warn_yn = OKC_API.G_MISS_CHAR OR
        p_rulv_rec.warn_yn IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'warn_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check allowed values
    IF (UPPER(p_rulv_rec.warn_yn) NOT IN ('Y','N')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'warn_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;




  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN


    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN


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
  END validate_warn_yn;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_rule_info_catagory
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

/* The following procedure has been changed to check for DFF in case of rule templates */

  PROCEDURE validate_rule_info_category(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS

    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_dfc_csr (appl_id number, dff_name varchar2) IS
      SELECT 'x'
        FROM FND_DESCR_FLEX_CONTEXTS_VL dfc
--       WHERE dfc.application_id = 510 -- Application id for Contracts    -- /striping/
       WHERE dfc.application_id = appl_id -- Application id for Contracts
--	    AND dfc.descriptive_flexfield_name    = G_DESCRIPTIVE_FLEXFIELD_NAME   -- /striping/
	    AND dfc.descriptive_flexfield_name    = dff_name
         AND dfc.descriptive_flex_context_code = p_rulv_rec.rule_information_category;

    CURSOR l_rgrv_csr IS
      SELECT 'x'
        FROM OKC_RULE_GROUPS_B rgpv,
             OKC_RG_DEF_RULES  rgrv
       WHERE rgrv.RGD_CODE = rgpv.RGD_CODE
         AND rgpv.ID       = p_rulv_rec.rgp_id
         AND rgrv.RDF_CODE = p_rulv_rec.rule_information_category;
   --
   l_proc varchar2(72) := g_package||'validate_rule_info_category';
   --
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rulv_rec.rule_information_category = OKC_API.G_MISS_CHAR OR
        p_rulv_rec.rule_information_category IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rule_information_category');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rulv_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(p_rulv_rec.rule_information_category);

/* The following part has been changed to check for DFF in case of rule templates */
    -- check for descriptive flex, it must be defined
    IF (p_rulv_rec.rgp_id IS NULL OR
        p_rulv_rec.rgp_id = OKC_API.G_MISS_NUM) Then
--      OPEN  l_dfc_csr;                     -- /striping/
      OPEN  l_dfc_csr(p_appl_id,p_dff_name);
      FETCH l_dfc_csr INTO l_dummy_var;
      CLOSE l_dfc_csr;

    -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_INVALID_VALUE,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'rule_information_category');
      -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    ELSE
      OPEN  l_rgrv_csr;
      FETCH l_rgrv_csr INTO l_dummy_var;
      CLOSE l_rgrv_csr;

    -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_INVALID_VALUE,
          p_token1        => G_COL_NAME_TOKEN,
          p_token1_value  => 'rule_information_category');
      -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN

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
    IF l_rgrv_csr%ISOPEN THEN
      CLOSE l_rgrv_csr;
    END IF;
  END validate_rule_info_category;
--
  -- Start of comments
  --
  -- Procedure Name  : checknumlen
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE  checknumlen(
    p_col_name       IN VARCHAR2,
    p_col_value      IN NUMBER,
    p_length         IN OUT NOCOPY NUMBER,
    p_scale          IN NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2
  ) IS
    i         NUMBER := 1;
    l_pre     NUMBER := 0;
    l_scale   NUMBER := 0;
    l_str_pos VARCHAR2(40) := '';
    l_pos     NUMBER := 0;
    l_neg     NUMBER := 0;
    l_value   NUMBER := 0;
    l_format varchar2(10);
   --
   l_proc varchar2(72) := g_package||'checknumlen';
   --
  BEGIN

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    -- There is a bug in the flex field form that will not allow you
    -- to set the maximum size of a number to more than 38. But 39 is the max.
    IF p_length = 38 THEN
      p_length := 39;
    END IF;

    l_value := NVL(p_col_value,0);
    l_pre := p_length - ABS(p_scale);
    for j in 1..l_pre loop
      l_str_pos := l_str_pos||'9';
    end loop;
    l_scale := p_scale;
    IF (l_scale>0) THEN
      l_str_pos:=l_str_pos||'.';
      FOR j in 1..l_scale LOOP
        l_str_pos := l_str_pos||'9';
      END LOOP;
    ELSIF (l_scale < 0) THEN
      FOR j in 1..ABS(l_scale) LOOP
        l_str_pos := l_str_pos||'0';
      END LOOP;
    END IF;
    l_pos:=to_number(l_str_pos);
    l_neg:=(-1)*l_pos;
    IF l_value<=l_pos and l_value>=l_neg THEN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := OKC_API.G_RET_STS_ERROR;
      if (p_scale is not NULL) then
        l_format := '('||to_char(p_length)||'.'||to_char(p_scale)||')';
      else
        l_format := to_char(p_length);
      end if;
      OKC_API.SET_MESSAGE
        (p_app_name      =>  G_APP_NAME,
         p_msg_name      =>  G_LEN_CHK,
         p_token1        =>  G_COL_NAME_TOKEN,
         p_token1_value  =>  'Column '||UPPER(p_col_name)|| ' in view ' || G_VIEW,
	   p_token2		=> G_COL_LEN,
	   p_token2_value  =>  l_format);
    END IF;




  EXCEPTION
  WHEN OTHERS THEN


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
  END checknumlen;
--
  -- Start of comments
  --
  -- Procedure Name  : checkcharlen
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE  checkcharlen(
    p_col_name       IN VARCHAR2,
    p_col_value      IN VARCHAR2,
    p_length         IN NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2
  ) IS
    col_len number:=0;
   --
   l_proc varchar2(72) := g_package||'checkcharlen';
   --
  BEGIN




    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    col_len := nvl(length(p_col_value),0);
    IF col_len <= TRUNC((p_length)/3) THEN
      x_return_status:=OKC_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.SET_MESSAGE
        (p_app_name      =>  G_APP_NAME,
         p_msg_name      =>  G_LEN_CHK,
         p_token1        =>  G_COL_NAME_TOKEN,
         p_token1_value  =>  'Column '||UPPER(p_col_name)|| ' in view ' || G_VIEW,
	   p_token2		=> G_COL_LEN,
	   p_token2_value  =>  to_char(TRUNC((p_length)/3)));

    END IF;




  EXCEPTION
  WHEN OTHERS THEN


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
  END checkcharlen;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_rule_information
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rule_information(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    TYPE l_info_type IS REF CURSOR;
    l_info_csr             l_info_type;
    sql_stmt               VARCHAR2(4000);
    l_end_user_column_name FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE;
    l_rule_information     OKC_RULES_V.RULE_INFORMATION1%TYPE;
    l_flex_value_set_id    FND_DESCR_FLEX_COL_USAGE_VL.FLEX_VALUE_SET_ID%TYPE;
    l_required_flag        FND_DESCR_FLEX_COL_USAGE_VL.REQUIRED_FLAG%TYPE;
    l_row_notfound         Boolean;

    CURSOR l_fvs_csr IS
      SELECT VALIDATION_TYPE, FORMAT_TYPE, MAXIMUM_SIZE,
             UPPERCASE_ONLY_FLAG, NUMERIC_MODE_ENABLED_FLAG,
             NUMBER_PRECISION
        FROM FND_FLEX_VALUE_SETS fvs
       WHERE fvs.FLEX_VALUE_SET_ID = l_flex_value_set_id;
    l_fvs_rec l_fvs_csr%ROWTYPE;

    CURSOR l_fvt_csr IS
      SELECT application_table_name, id_column_name, id_column_type,
             ADDITIONAL_WHERE_CLAUSE
        FROM FND_FLEX_VALIDATION_TABLES fvt
       WHERE fvt.flex_value_set_id = l_flex_value_set_id;
    l_fvt_rec l_fvt_csr%ROWTYPE;
    l_where_clause VARCHAR2(4000);

    CURSOR l_fvl_csr IS
    SELECT /*+ first_rows */ 'x'
      FROM FND_FLEX_VALUES fvl
     WHERE fvl.flex_value_set_id = l_flex_value_set_id
       AND rownum < 2 ;

    CURSOR l_fvl1_csr IS
    SELECT /*+ first_rows */ 'x'
      FROM FND_FLEX_VALUES fvl
     WHERE fvl.flex_value_set_id = l_flex_value_set_id
       AND fvl.flex_value        = l_rule_information
       AND rownum < 2 ;

-- actually nobody uses the cusor /striping/
/*
    cursor l_flex_csr(p_rule_cat varchar2, p_attribute varchar2) is
      SELECT END_USER_COLUMN_NAME, FLEX_VALUE_SET_ID, REQUIRED_FLAG
        FROM FND_DESCR_FLEX_COLUMN_USAGES dfcu
        WHERE dfcu.descriptive_flexfield_name = 'OKC Rule Developer DF'
        AND dfcu.descriptive_flex_context_code = p_rule_cat
        AND dfcu.application_column_name       =  p_attribute
	AND dfcu.application_id =510;
*/

    l_dummy_var   VARCHAR2(1) := '?';
    TYPE l_fvt_rc_type IS REF CURSOR;
    l_fvt_rc  l_fvt_rc_type;

--ricagraw
i number;
--ricagraw


   --
   l_proc varchar2(72) := g_package||'validate_rule_information';
   --
  BEGIN

-- skekkar

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

     populate_global_tab( p_rulv_rec => p_rulv_rec, x_return_status => l_return_status );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


-- added 19-MAR-2002 by rgalipo -- performance bug
-- added call to cursor on temporary table
-- removed dependency on pl/sql tables

/* FOR r IN NVL(g_ddf_context_code_tbl.first,0)..NVL(g_ddf_context_code_tbl.last,-1) LOOP */

FOR r_flex_col_usage IN c_flex_col_usage (p_rulv_rec.rule_information_category) LOOP

/*  IF g_ddf_context_code_tbl(r) = p_rulv_rec.rule_information_category THEN */
--    IF r_flex_col_usage.descriptive_flex_context_code = p_rulv_rec.rule_information_category THEN

      -- SQL statement to retrieve the developer descriptive flex field information
      l_end_user_column_name := NULL;
      l_flex_value_set_id    := NULL;
      l_rule_information     := NULL;


      --i := i + 1; -- g_col_seq_no_tbl(r);
--ricagraw
i := TO_NUMBER(r_flex_col_usage.seq_no);
--ricagraw

      IF i = 1 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION1;
      ELSIF i = 2 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION2;
      ELSIF i = 3 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION3;
      ELSIF i = 4 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION4;
      ELSIF i = 5 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION5;
      ELSIF i = 6 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION6;
      ELSIF i = 7 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION7;
      ELSIF i = 8 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION8;
      ELSIF i = 9 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION9;
      ELSIF i = 10 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION10;
      ELSIF i = 11 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION11;
      ELSIF i = 12 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION12;
      ELSIF i = 13 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION13;
      ELSIF i = 14 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION14;
      ELSIF i = 15 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION15;
      END IF;


      l_end_user_column_name := r_flex_col_usage.end_user_column_name;  -- g_end_user_col_name_tbl(r);
      l_flex_value_set_id    := r_flex_col_usage.flex_value_set_id;     -- g_flex_value_set_id_tbl(r);
      l_required_flag        := r_flex_col_usage.required_flag;         -- g_required_flag_tbl(r);

-- skekkar
     --
      -- if no column has been defined then the rule information
      -- must be null
      IF l_end_user_column_name IS NULL AND
         l_rule_information IS NOT NULL THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_NO_DEVELOPER_FLEX_DEFINED,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'rule_information'||LTRIM(TO_CHAR(i)));

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      IF l_end_user_column_name = 'CLOB_USED' THEN
        l_end_user_column_name := '';
        g_clob_used := 'Y';
      END IF;

      -- Check that the passed in value is correct for the
      -- defined attribute.
      IF l_end_user_column_name IS NOT NULL THEN

        -- a value set must be defined.
        IF l_flex_value_set_id IS NULL THEN
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_NO_VALUE_SET_DEFINED,
            p_token1       => G_COL_NAME_TOKEN,
            p_token1_value => 'rule_information'||LTRIM(TO_CHAR(i)));

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- check if data is required
        -- The following has been commented out so
        -- that rules can be built and saved without
        -- all of the required data present. The required
        -- data will be checked during the QA processes
        --IF l_required_flag = 'Y' THEN
        --  -- data is required
        --  IF (l_rule_information = OKC_API.G_MISS_CHAR OR
        --      l_rule_information IS NULL) THEN
        --    OKC_API.set_message(
        --      p_app_name     => G_APP_NAME,
        --      p_msg_name     => G_REQUIRED_VALUE,
        --      p_token1       => G_COL_NAME_TOKEN,
        --      p_token1_value => l_end_user_column_name);
        --    -- notify caller of an error
        --    x_return_status := OKC_API.G_RET_STS_ERROR;
        --    -- halt validation
        --    RAISE G_EXCEPTION_HALT_VALIDATION;
        --  END IF;
        --END IF;

        -- Check for value
        IF (l_rule_information <> OKC_API.G_MISS_CHAR OR
            l_rule_information IS NOT NULL) THEN

          -- get value set information for the descriptive flex
          OPEN  l_fvs_csr;
          FETCH l_fvs_csr INTO l_fvs_rec;
          CLOSE l_fvs_csr;

          -- Check type
          DECLARE
            l_date DATE;
            l_number NUMBER;
            l_char   VARCHAR2(4000);
          BEGIN
            -- Modified for Bug 2292300
            IF l_fvs_rec.format_type IN ('D','X') THEN
               l_date := fnd_date.canonical_to_date(l_rule_information);
            --IF l_fvs_rec.format_type = 'D' THEN
              -- l_date := to_date(l_rule_information, 'YYYY/MM/DD HH24:MI:SS');
            -- do we want any checks for character?
            --ELSIF l_fvs_rec.format_type = 'C' THEN
            --  l_char := l_rule_information;
            ELSIF l_fvs_rec.format_type = 'N' THEN
              l_number := to_number(l_rule_information);
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            OKC_API.set_message(
              p_app_name      => G_APP_NAME,
              p_msg_name      => G_INVALID_VALUE,
              p_token1        => G_COL_NAME_TOKEN,
              p_token1_value  => l_end_user_column_name);
             -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
             -- halt validation
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END;

          -- Check foriegn key validation
          IF l_fvs_rec.VALIDATION_TYPE = 'F' THEN
            OPEN  l_fvt_csr;
            FETCH l_fvt_csr INTO l_fvt_rec;
            CLOSE l_fvt_csr;

            l_where_clause := l_fvt_rec.additional_where_clause;
            IF l_where_clause IS NOT NULL AND
               UPPER(SUBSTR(l_where_clause, 1, 5)) <> 'ORDER' THEN
              IF UPPER(SUBSTR(l_where_clause, 1, 5)) = 'WHERE' THEN
                l_where_clause := SUBSTR(l_where_clause, 6, LENGTH(l_where_clause));
              END IF;
              l_where_clause := 'AND ' ||l_where_clause;
            END IF;

            -- validate forien key
            sql_stmt := 'SELECT ''x'' ' ||
                        '  FROM ' || l_fvt_rec.application_table_name ||
                        ' WHERE ' || l_fvt_rec.id_column_name ||  ' = :col_val ' ||
                        ' AND rownum < 2 ' ||
                        l_where_clause;
            --dbms_output.put_line(' l sql stmt '||sql_stmt);
            IF l_fvt_rec.id_column_type = 'N' THEN
               OPEN l_fvt_rc FOR sql_stmt USING to_number(l_rule_information);
            ELSE
               OPEN l_fvt_rc FOR sql_stmt USING l_rule_information;
            END IF;
            FETCH l_fvt_rc INTO l_dummy_var;
            l_row_notfound := l_fvt_rc%NotFound;
            CLOSE l_fvt_rc;
            -- if l_dummy_var still set to default, data was not found
            IF l_row_notfound THEN
              OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_NO_PARENT_RECORD,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => l_end_user_column_name,
                p_token2        => G_CHILD_TABLE_TOKEN,
                p_token2_value  => G_VIEW,
                p_token3        => G_PARENT_TABLE_TOKEN,
                p_token3_value  => l_fvt_rec.application_table_name);
               -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
          END IF;
           -- Check independent value
          IF l_fvs_rec.VALIDATION_TYPE = 'I' THEN
            l_dummy_var := '?';
            OPEN  l_fvl_csr;
            FETCH l_fvl_csr INTO l_dummy_var;
            CLOSE l_fvl_csr;

            --IF l_dummy_var = 'X' THEN
            IF l_dummy_var = 'x' THEN
              -- validate forien key
              l_dummy_var := '?';
              OPEN  l_fvl1_csr;
              FETCH l_fvl1_csr INTO l_dummy_var;
              CLOSE l_fvl1_csr;

              -- if l_dummy_var still set to default, data was not found
              IF (l_dummy_var = '?') THEN
                OKC_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => G_INVALID_VALUE,
                  p_token1       => G_COL_NAME_TOKEN,
                  p_token1_value => l_end_user_column_name);

                -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
              END IF;
            END IF;
          END IF; -- validate independent value set
        END IF;   -- value is not null
      END IF;     -- l_end_user_column_name IS NOT NULL

-- skekkar

--  END IF; -- for a Rule
 END LOOP; -- c_flex_col_usage

-- skekkar

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
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
    IF l_info_csr%ISOPEN THEN
      CLOSE l_info_csr;
    END IF;
    IF l_fvs_csr%ISOPEN THEN
      CLOSE l_fvs_csr;
    END IF;
    IF l_fvt_csr%ISOPEN THEN
      CLOSE l_fvt_csr;
    END IF;
    IF l_fvt_rc%ISOPEN THEN
      CLOSE l_fvt_rc;
    END IF;
    IF l_info_csr%ISOPEN THEN
      CLOSE l_info_csr;
    END IF;
    IF l_fvl_csr%ISOPEN THEN
      CLOSE l_fvl_csr;
    END IF;
    IF l_fvl1_csr%ISOPEN THEN
      CLOSE l_fvl1_csr;
    END IF;
  END validate_rule_information;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_text
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
/*--Bug 3055393
  PROCEDURE validate_text(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    sql_stmt               VARCHAR2(4000);
    TYPE l_info_type IS REF CURSOR;
    l_info_csr             l_info_type;
    l_dummy_var   VARCHAR2(1) := '?';

   --
   l_proc varchar2(72) := g_package||'validate_text';
   --
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_rulv_rec.text IS NOT NULL) THEN

      -- Make sure that the object has been defined in the developer
      -- descriptive flex field

      -- bug 1857663
      -- FROM clause missing in the sql_stmt constructed below

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rulv_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(p_rulv_rec.rule_information_category);

      sql_stmt := 'SELECT ''x'' ' ||
                  ' FROM FND_DESCR_FLEX_COLUMN_USAGES dfcu ' ||
--                  ' WHERE dfcu.descriptive_flexfield_name = ' ||   -- /striping/
                  ' WHERE dfcu.descriptive_flexfield_name = :dff_name ' ||
--                  ''''||G_DESCRIPTIVE_FLEXFIELD_NAME||'''' ||     -- /striping/
                  '   AND dfcu.descriptive_flex_context_code = :rule_cat ' ||
                  '   AND dfcu.end_user_column_name       =  :attribute' ||
--			'   AND dfcu.APPLICATION_ID=510';   -- /striping/
			'   AND dfcu.APPLICATION_ID = :appl_id';

--                  '   AND dfcu.application_column_name       =  :attribute' ;

       OPEN l_info_csr
        FOR sql_stmt
--      USING p_rulv_rec.rule_information_category, 'TEXT';       -- /striping/
      USING p_dff_name, p_rulv_rec.rule_information_category, 'TEXT', p_appl_id;
      FETCH l_info_csr INTO l_dummy_var;
      CLOSE l_info_csr;

      -- if no column has been defined then the object information
      -- must be null
      -- if l_dummy_var still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_NO_DEVELOPER_FLEX_DEFINED,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'text');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

      END IF;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN

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
    IF l_info_csr%ISOPEN THEN
      CLOSE l_info_csr;
    END IF;
  END validate_text;
*/
--
  -- Start of comments
  --
  -- Procedure Name  : validate_object
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_object(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rulv_rec      IN    rulv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    TYPE l_int_type IS REF CURSOR;
    l_int_csr              l_int_type;
    sql_stmt               VARCHAR2(4000);
    l_object_id1           OKC_RULES_V.OBJECT1_ID1%TYPE;
    l_object_id2           OKC_RULES_V.OBJECT1_ID2%TYPE;
    jtot_object_code       OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE;
    l_from_table           JTF_OBJECTS_VL.FROM_TABLE%TYPE;
    l_where_clause         varchar2(4000);
    l_flex_value_set_id    FND_DESCR_FLEX_COL_USAGE_VL.FLEX_VALUE_SET_ID%TYPE;
    TYPE l_info_type IS REF CURSOR;
    l_info_csr             l_info_type;

    CURSOR l_jtot_csr IS
      SELECT decode(where_clause,'','','and '||where_clause) where_clause,
             from_table
        FROM JTF_OBJECTS_B jtot
       WHERE jtot.object_code = jtot_object_code;

    l_dummy_var   VARCHAR2(1) := '?';

-- skekkar
i number := 0;
-- skekkar

   --
   l_proc varchar2(72) := g_package||'validate_object';
   --
  BEGIN


-- skekkar

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

     populate_obj_global_tab( p_rulv_rec => p_rulv_rec, x_return_status => l_return_status );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- added 19-MAR-2002 by rgalipo -- performance bug
-- added call to cursor on temporary table
-- removed dependency on pl/sql tables
/* FOR r IN NVL(g_obj_ddf_context_code_tbl.first,0)..NVL(g_obj_ddf_context_code_tbl.last,-1) LOOP */

FOR r_descr_flex_col IN c_descr_flex_col (p_rulv_rec.rule_information_category) LOOP

/*  IF g_obj_ddf_context_code_tbl(r) = p_rulv_rec.rule_information_category THEN */
--  IF r_descr_flex_col.descriptive_flex_context_code = p_rulv_rec.rule_information_category THEN

      -- SQL statement to retrieve the developer descriptive flex field information
      l_object_id1     := NULL;
      l_object_id2     := NULL;
      jtot_object_code := NULL;

      i := i + 1;  -- := g_obj_col_seq_no_tbl(r);

      IF i = 1 THEN
        l_object_id1     := p_rulv_rec.OBJECT1_ID1;
        l_object_id2     := p_rulv_rec.OBJECT1_ID2;
        jtot_object_code := p_rulv_rec.JTOT_OBJECT1_CODE;
      ELSIF i = 2 THEN
        l_object_id1     := p_rulv_rec.OBJECT2_ID1;
        l_object_id2     := p_rulv_rec.OBJECT2_ID2;
        jtot_object_code := p_rulv_rec.JTOT_OBJECT2_CODE;
      ELSIF i = 3 THEN
        l_object_id1     := p_rulv_rec.OBJECT3_ID1;
        l_object_id2     := p_rulv_rec.OBJECT3_ID2;
        jtot_object_code := p_rulv_rec.JTOT_OBJECT3_CODE;
      END IF;

     l_dummy_var := r_descr_flex_col.dummy_col;  -- g_obj_x_tbl(r);

-- skekkar

      -- if no column has been defined then the object id
      -- must be null
      IF l_object_id1 IS NOT NULL AND
         jtot_object_code IS NULL THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'jtot_object_'||LTRIM(TO_CHAR(i))||'_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSIF l_object_id1 IS NULL AND
            jtot_object_code IS NOT NULL THEN

        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_REQUIRED_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'object'||LTRIM(TO_CHAR(i))||'_id1');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

        -- halt validation
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSIF l_object_id1 IS NOT NULL AND
            jtot_object_code IS NOT NULL THEN

        -- if l_dummy_var still set to default, data was not found
        IF (l_dummy_var = '?') THEN
          OKC_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => G_NO_DEVELOPER_FLEX_DEFINED,
            p_token1       => G_COL_NAME_TOKEN,
            p_token1_value => 'object'||LTRIM(TO_CHAR(i)));

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- check jtot_object_code must be defined
        OPEN  l_jtot_csr;
        FETCH l_jtot_csr INTO l_where_clause, l_from_table;
        CLOSE l_jtot_csr;

        -- if l_dummy_var still set to default, data was not found
        IF (l_dummy_var = '?') THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => G_INVALID_VALUE,
            p_token1        => G_COL_NAME_TOKEN,
            p_token1_value  => 'jtot_object'||LTRIM(TO_CHAR(i))||'code');
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        -- Do integration foriegn key validation

        sql_stmt := 'SELECT ''x'' ' ||
                    '  FROM ' || l_from_table ||
                    ' WHERE ID1 = :col_val ' ||
                    '   AND ID2 = :col_val2 '||
                    '   AND rownum < 2 '|| l_where_clause;

         OPEN l_int_csr FOR sql_stmt USING l_object_id1, nvl(l_object_id2, '#');
        FETCH l_int_csr INTO l_dummy_var;
        CLOSE l_int_csr;

        -- if l_dummy_var still set to default, data was not found
        IF (l_dummy_var = '?') THEN
          OKC_API.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => G_NO_PARENT_RECORD,
            p_token1        => G_COL_NAME_TOKEN,
            p_token1_value  => 'object_id1, object2',
            p_token2        => G_CHILD_TABLE_TOKEN,
            p_token2_value  => G_VIEW,
            p_token3        => G_PARENT_TABLE_TOKEN,
            p_token3_value  => l_from_table);

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
      END IF;

-- skekkar

--  END IF; -- for a Rule

END LOOP;  -- c_descr_flex_col

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
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
    IF l_info_csr%ISOPEN THEN
      CLOSE l_info_csr;
    END IF;
    IF l_jtot_csr%ISOPEN THEN
      CLOSE l_jtot_csr;
    END IF;
    IF l_jtot_csr%ISOPEN THEN
      CLOSE l_jtot_csr;
    END IF;
  END validate_object;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  FUNCTION Validate_Attributes (
    p_rulv_rec IN  rulv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'Validate_Attributes';
   --
  BEGIN

    -- call each column-level validation for the rule super type columns

    validate_rgp_id(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status := l_return_status;
       END IF;
     END IF;
--
    validate_std_template_yn(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    validate_template_yn(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);


    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_dnz_chr_id(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_warn_yn(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_rule_info_category(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    g_clob_used := 'N';
    validate_rule_information(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
/*--Bug 3055393
    validate_text(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
*/
--
    validate_object(
      x_return_status => l_return_status,
      p_rulv_rec      => p_rulv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--

    -- return status to caller
    RETURN(x_return_status);

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE
      (p_app_name     => G_APP_NAME,
       p_msg_name     => G_UNEXPECTED_ERROR,
       p_token1       => G_SQLCODE_TOKEN,
       p_token1_value => SQLCODE,
       p_token2       => G_SQLERRM_TOKEN,
       p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    -- return status to caller
    RETURN x_return_status;

  END Validate_Attributes;

/***********************  create comments   **************************/
--+
function set_fk_comments(p_rulv_rec rulv_rec_type) return varchar2 as
    TYPE l_info_type IS REF CURSOR;
    l_info_csr             l_info_type;
    sql_stmt               VARCHAR2(4000);
    l_object_id1           OKC_RULES_V.OBJECT1_ID1%TYPE;
    l_object_id2           OKC_RULES_V.OBJECT1_ID2%TYPE;
    l_jtot_object_code       OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE;
    l_from_table           JTF_OBJECTS_VL.FROM_TABLE%TYPE;
    l_where_clause         varchar2(4000);
    l_flex_value_set_id    FND_DESCR_FLEX_COL_USAGE_VL.FLEX_VALUE_SET_ID%TYPE;
    CURSOR l_jtot_csr IS
      SELECT decode(where_clause,'','','and '||where_clause) where_clause,
             from_table
        FROM JTF_OBJECTS_B jtot
       WHERE jtot.object_code = l_jtot_object_code;
    l_get varchar2(2000);
    l_assemble   VARCHAR2(32000);
    i number ;
   --
   l_proc varchar2(72) := g_package||'set_fk_comments';
   --
begin
i:=0;
-- skekkar

-- added 19-MAR-2002 by rgalipo -- performance bug
-- added call to cursor on temporary table
-- removed dependency on pl/sql tables
/* FOR r IN NVL(g_obj_ddf_context_code_tbl.first,0)..NVL(g_obj_ddf_context_code_tbl.last,-1) LOOP */

FOR r_descr_flex_col IN c_descr_flex_col (p_rulv_rec.rule_information_category) LOOP

/*  IF g_obj_ddf_context_code_tbl(r) = p_rulv_rec.rule_information_category THEN */
--  IF r_descr_flex_col.descriptive_flex_context_code = p_rulv_rec.rule_information_category THEN

    l_object_id1       := NULL;
    l_object_id2       := NULL;
    l_jtot_object_code := NULL;
    l_get              := NULL;

    i := i + 1;  -- g_obj_col_seq_no_tbl(r);

      IF i = 1 THEN
        l_object_id1     := p_rulv_rec.OBJECT1_ID1;
        l_object_id2     := p_rulv_rec.OBJECT1_ID2;
        l_jtot_object_code := p_rulv_rec.JTOT_OBJECT1_CODE;
      ELSIF i = 2 THEN
        l_object_id1     := p_rulv_rec.OBJECT2_ID1;
        l_object_id2     := p_rulv_rec.OBJECT2_ID2;
        l_jtot_object_code := p_rulv_rec.JTOT_OBJECT2_CODE;
      ELSIF i = 3 THEN
        l_object_id1     := p_rulv_rec.OBJECT3_ID1;
        l_object_id2     := p_rulv_rec.OBJECT3_ID2;
        l_jtot_object_code := p_rulv_rec.JTOT_OBJECT3_CODE;
      END IF;

      l_get := r_descr_flex_col.form_left_prompt;  -- g_obj_form_left_prompt_tbl(r);

-- skekkar

     IF ((l_jtot_object_code IS NOT NULL) AND (l_object_id1 IS NOT NULL)) THEN
     BEGIN
        l_assemble:=l_assemble||l_get||'=';
        OPEN  l_jtot_csr;
        FETCH l_jtot_csr INTO l_where_clause, l_from_table;
        CLOSE l_jtot_csr;
        sql_stmt := 'SELECT name ' ||
                    '  FROM ' || l_from_table ||
                    ' WHERE ID1 = :col_val ' ||
                    '   AND ID2 = :col_val2 ' || l_where_clause;
         OPEN l_info_csr FOR sql_stmt USING l_object_id1, nvl(l_object_id2, '#');
        l_get:=NULL;
        FETCH l_info_csr INTO l_get;
        CLOSE l_info_csr;
        l_assemble := l_assemble||l_get||', ';
     EXCEPTION
       WHEN OTHERS THEN
            if (l_info_csr%ISOPEN) then close l_info_csr; end if;
            if (l_jtot_csr%ISOPEN) then close l_jtot_csr; end if;
     END;
   END IF; -- l_jtot_object_code IS NOT NULL
-- END IF; -- r_descr_flex_col.descriptive_flex_context_code = p_rulv_rec.rule_information_category
END LOOP; -- c_descr_flex_col


          IF (l_debug = 'Y') THEN
             okc_util.print_trace(5, ' RUL set_fk_comments:' || l_assemble);
          END IF;


return l_assemble;
end;

--+
function set_bt_comments(p_rulv_rec rulv_rec_type) return varchar2 as
    l_get varchar2(100);
    l_assemble   VARCHAR2(4000);
    i number ;
--
    TYPE l_info_type IS REF CURSOR;
    l_info_csr             l_info_type;
    sql_stmt               VARCHAR2(4000);
    l_end_user_column_name FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE;
    l_rule_information     OKC_RULES_V.RULE_INFORMATION1%TYPE;
    l_flex_value_set_id    FND_DESCR_FLEX_COL_USAGE_VL.FLEX_VALUE_SET_ID%TYPE;
    l_required_flag        FND_DESCR_FLEX_COL_USAGE_VL.REQUIRED_FLAG%TYPE;

    CURSOR l_fvs_csr IS
      SELECT VALIDATION_TYPE, FORMAT_TYPE, MAXIMUM_SIZE,
             UPPERCASE_ONLY_FLAG, NUMERIC_MODE_ENABLED_FLAG,
             NUMBER_PRECISION
        FROM FND_FLEX_VALUE_SETS fvs
       WHERE fvs.FLEX_VALUE_SET_ID = l_flex_value_set_id;
    l_fvs_rec l_fvs_csr%ROWTYPE;

    CURSOR l_fvt_csr IS
      SELECT application_table_name, id_column_name, id_column_type,
             ADDITIONAL_WHERE_CLAUSE, value_column_name
        FROM FND_FLEX_VALIDATION_TABLES fvt
       WHERE fvt.flex_value_set_id = l_flex_value_set_id;
    l_fvt_rec l_fvt_csr%ROWTYPE;
    l_where_clause VARCHAR2(4000);

    TYPE l_fvt_rc_type IS REF CURSOR;
    l_fvt_rc  l_fvt_rc_type;
   --
   l_proc varchar2(72) := g_package||'set_bt_comments';
   --
begin
i:=0;
-- skekkar

-- added 19-MAR-2002 by rgalipo -- performance bug
-- added call to cursor on temporary table
-- removed dependency on pl/sql tables

FOR r_flex_col_usage IN c_flex_col_usage (p_rulv_rec.rule_information_category) LOOP

/* FOR r IN NVL(g_ddf_context_code_tbl.first,0)..NVL(g_ddf_context_code_tbl.last,-1) LOOP */
/* IF g_ddf_context_code_tbl(r) = p_rulv_rec.rule_information_category THEN */
--  IF r_flex_col_usage.descriptive_flex_context_code = p_rulv_rec.rule_information_category THEN

      -- SQL statement to retrieve the developer descriptive flex field information
      l_end_user_column_name := NULL;
      l_flex_value_set_id    := NULL;
      l_rule_information     := NULL;

      i := i + 1;  -- g_col_seq_no_tbl(r);


      IF i = 1 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION1;
      ELSIF i = 2 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION2;
      ELSIF i = 3 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION3;
      ELSIF i = 4 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION4;
      ELSIF i = 5 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION5;
      ELSIF i = 6 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION6;
      ELSIF i = 7 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION7;
      ELSIF i = 8 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION8;
      ELSIF i = 9 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION9;
      ELSIF i = 10 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION10;
      ELSIF i = 11 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION11;
      ELSIF i = 12 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION12;
      ELSIF i = 13 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION13;
      ELSIF i = 14 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION14;
      ELSIF i = 15 THEN
        l_rule_information := p_rulv_rec.RULE_INFORMATION15;
      END IF;

      l_end_user_column_name := r_flex_col_usage.end_user_column_name;  -- g_end_user_col_name_tbl(r);
      l_flex_value_set_id    := r_flex_col_usage.flex_value_set_id;     -- g_flex_value_set_id_tbl(r);
      l_required_flag        := r_flex_col_usage.required_flag;         -- g_required_flag_tbl(r);
      l_get                  := r_flex_col_usage.form_left_prompt;      -- g_form_left_prompt_tbl(r);

-- skekkar
if  (l_rule_information is not NULL) then
begin
--
     l_assemble:=l_assemble||l_get||'=';
          OPEN  l_fvs_csr;
          FETCH l_fvs_csr INTO l_fvs_rec;
          CLOSE l_fvs_csr;
--
IF l_fvs_rec.VALIDATION_TYPE <>'F' THEN
l_assemble:=l_assemble||l_rule_information||', ';
else
            OPEN  l_fvt_csr;
            FETCH l_fvt_csr INTO l_fvt_rec;
            CLOSE l_fvt_csr;
--
            l_where_clause := l_fvt_rec.additional_where_clause;
            IF l_where_clause IS NOT NULL AND
               UPPER(SUBSTR(l_where_clause, 1, 5)) <> 'ORDER' THEN
              IF UPPER(SUBSTR(l_where_clause, 1, 5)) = 'WHERE' THEN
                l_where_clause := SUBSTR(l_where_clause, 6, LENGTH(l_where_clause));
              END IF;
              l_where_clause := 'AND ' ||l_where_clause;
            END IF;
            if (UPPER(l_fvt_rec.application_table_name)='OKC_TIMEVALUES_V') then
              l_fvt_rec.value_column_name := 'COMMENTS';
            end if;
            sql_stmt := 'SELECT ' ||l_fvt_rec.value_column_name||
                        '  FROM ' || l_fvt_rec.application_table_name ||
                        ' WHERE ' || l_fvt_rec.id_column_name ||  ' = :col_val ' ||
                        l_where_clause;
            IF l_fvt_rec.id_column_type = 'N' THEN
               OPEN l_fvt_rc FOR sql_stmt USING to_number(l_rule_information);
            ELSE
               OPEN l_fvt_rc FOR sql_stmt USING l_rule_information;
            END IF;
            l_get := NULL;
            FETCH l_fvt_rc INTO l_get;
            CLOSE l_fvt_rc;
            l_assemble:=l_assemble||l_get||', ';
end if; -- l_fvs_rec.VALIDATION_TYPE <>'F'
exception when others then
  if (l_info_csr%ISOPEN) then close l_info_csr; end if;
  if (l_fvs_csr%ISOPEN) then close l_fvs_csr; end if;
  if (l_fvt_csr%ISOPEN) then close l_fvt_csr; end if;
  if (l_fvt_rc%ISOPEN) then close l_fvt_rc; end if;
end; -- begin
end if; -- l_rule_information is not NULL
  -- end if; -- r_flex_col_usage.descriptive_flex_context_code = p_rulv_rec.rule_information_category
END LOOP;  -- c_flex_col_usage


          IF (l_debug = 'Y') THEN
             okc_util.print_trace(5, ' RUL set_bt_comments:' || l_assemble);
          END IF;


return l_assemble;
end;

function set_comments(p_rulv_rec rulv_rec_type) return varchar2 as
S varchar2(32000);
L number;
   --
   l_proc varchar2(72) := g_package||'set_comments';
   --
begin

   S:=set_fk_comments(p_rulv_rec)||set_bt_comments(p_rulv_rec);
   L:=length(S);
  if (L>0) then L:=L-2; end if;

  return substr(s,1,least(1995,L));

exception when others then
   return '';
end;

/***********************  END HAND-CODED  **************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
   --
   l_proc varchar2(72) := g_package||'get_seq_id';
   --
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
   --
   l_proc varchar2(72) := g_package||'qc';
   --
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
   --
   l_proc varchar2(72) := g_package||'change_version';
   --
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
   --
   l_proc varchar2(72) := g_package||'api_copy';
   --
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
   --
   l_proc varchar2(72) := g_package||'add_language';
   --
  BEGIN
null;

/*Bug 3055393 This function is obsolete as okc_rules_tl is removed

    DELETE FROM OKC_RULES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_RULES_B B
         WHERE B.ID = T.ID
        );


-- Commented Update Statement for Bug 2801195
    UPDATE OKC_RULES_TL T SET (
        COMMENTS,
        TEXT) = (SELECT
                                  B.COMMENTS,
                                  B.TEXT
                                FROM OKC_RULES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_RULES_TL SUBB, OKC_RULES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR ((SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NOT NULL) AND
                          (DBMS_LOB.COMPARE(SUBB.TEXT,SUBT.TEXT) <> 0))
              ));


    INSERT INTO OKC_RULES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        TEXT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.COMMENTS,
            B.TEXT,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_RULES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_RULES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
    DELETE FROM OKC_RULES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_RULES_BH B
         WHERE B.ID = T.ID
         AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_RULES_TLH T SET (
        COMMENTS,
        TEXT) = (SELECT
                                  B.COMMENTS,
                                  B.TEXT
                                FROM OKC_RULES_TLH B
                               WHERE B.ID = T.ID
                                 AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKC_RULES_TLH SUBB, OKC_RULES_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR ((SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NOT NULL) AND
                          (DBMS_LOB.COMPARE(SUBB.TEXT,SUBT.TEXT) <> 0))
              ));

    INSERT INTO OKC_RULES_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        TEXT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.COMMENTS,
            B.TEXT,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_RULES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_RULES_TLH T
                     WHERE T.ID = B.ID
                       AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

*/
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rul_rec                      IN rul_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rul_rec_type IS
    CURSOR rul_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RGP_ID,
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
            STD_TEMPLATE_YN,
            WARN_YN,
            PRIORITY,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
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
            DISPLAY_SEQUENCE,
--Bug 3055393
            comments
      FROM Okc_Rules_B
     WHERE okc_rules_b.id       = p_id;
    l_rul_pk                       rul_pk_csr%ROWTYPE;
    l_rul_rec                      rul_rec_type;
   --
   l_proc varchar2(72) := g_package||'get_rec';
   --
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rul_pk_csr (p_rul_rec.id);
    FETCH rul_pk_csr INTO
              l_rul_rec.ID,
              l_rul_rec.RGP_ID,
              l_rul_rec.OBJECT1_ID1,
              l_rul_rec.OBJECT2_ID1,
              l_rul_rec.OBJECT3_ID1,
              l_rul_rec.OBJECT1_ID2,
              l_rul_rec.OBJECT2_ID2,
              l_rul_rec.OBJECT3_ID2,
              l_rul_rec.JTOT_OBJECT1_CODE,
              l_rul_rec.JTOT_OBJECT2_CODE,
              l_rul_rec.JTOT_OBJECT3_CODE,
              l_rul_rec.DNZ_CHR_ID,
              l_rul_rec.STD_TEMPLATE_YN,
              l_rul_rec.WARN_YN,
              l_rul_rec.PRIORITY,
              l_rul_rec.OBJECT_VERSION_NUMBER,
              l_rul_rec.CREATED_BY,
              l_rul_rec.CREATION_DATE,
              l_rul_rec.LAST_UPDATED_BY,
              l_rul_rec.LAST_UPDATE_DATE,
              l_rul_rec.LAST_UPDATE_LOGIN,
              l_rul_rec.ATTRIBUTE_CATEGORY,
              l_rul_rec.ATTRIBUTE1,
              l_rul_rec.ATTRIBUTE2,
              l_rul_rec.ATTRIBUTE3,
              l_rul_rec.ATTRIBUTE4,
              l_rul_rec.ATTRIBUTE5,
              l_rul_rec.ATTRIBUTE6,
              l_rul_rec.ATTRIBUTE7,
              l_rul_rec.ATTRIBUTE8,
              l_rul_rec.ATTRIBUTE9,
              l_rul_rec.ATTRIBUTE10,
              l_rul_rec.ATTRIBUTE11,
              l_rul_rec.ATTRIBUTE12,
              l_rul_rec.ATTRIBUTE13,
              l_rul_rec.ATTRIBUTE14,
              l_rul_rec.ATTRIBUTE15,
              l_rul_rec.RULE_INFORMATION_CATEGORY,
              l_rul_rec.RULE_INFORMATION1,
              l_rul_rec.RULE_INFORMATION2,
              l_rul_rec.RULE_INFORMATION3,
              l_rul_rec.RULE_INFORMATION4,
              l_rul_rec.RULE_INFORMATION5,
              l_rul_rec.RULE_INFORMATION6,
              l_rul_rec.RULE_INFORMATION7,
              l_rul_rec.RULE_INFORMATION8,
              l_rul_rec.RULE_INFORMATION9,
              l_rul_rec.RULE_INFORMATION10,
              l_rul_rec.RULE_INFORMATION11,
              l_rul_rec.RULE_INFORMATION12,
              l_rul_rec.RULE_INFORMATION13,
              l_rul_rec.RULE_INFORMATION14,
              l_rul_rec.RULE_INFORMATION15,
              l_rul_rec.TEMPLATE_YN,
              l_rul_rec.ans_set_jtot_object_code,
              l_rul_rec.ans_set_jtot_object_id1,
              l_rul_rec.ans_set_jtot_object_id2,
              l_rul_rec.DISPLAY_SEQUENCE,
--Bug 3055393
              l_rul_rec.comments ;
    x_no_data_found := rul_pk_csr%NOTFOUND;
    CLOSE rul_pk_csr;
    RETURN(l_rul_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rul_rec                      IN rul_rec_type
  ) RETURN rul_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'get_rec';
   --
  BEGIN
    RETURN(get_rec(p_rul_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULES_TL
  ---------------------------------------------------------------------------
/*--Bug 3055393
  FUNCTION get_rec (
    p_okc_rules_tl_rec             IN okc_rules_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_rules_tl_rec_type IS
    CURSOR rul_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rules_Tl
     WHERE okc_rules_tl.id      = p_id
       AND okc_rules_tl.language = p_language;
    l_rul_pktl                     rul_pktl_csr%ROWTYPE;
    l_okc_rules_tl_rec             okc_rules_tl_rec_type;
   --
   l_proc varchar2(72) := g_package||'get_rec';
   --
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rul_pktl_csr (p_okc_rules_tl_rec.id,
                       p_okc_rules_tl_rec.language);
    FETCH rul_pktl_csr INTO
              l_okc_rules_tl_rec.ID,
              l_okc_rules_tl_rec.LANGUAGE,
              l_okc_rules_tl_rec.SOURCE_LANG,
              l_okc_rules_tl_rec.SFWT_FLAG,
              l_okc_rules_tl_rec.COMMENTS,
              l_okc_rules_tl_rec.TEXT,
              l_okc_rules_tl_rec.CREATED_BY,
              l_okc_rules_tl_rec.CREATION_DATE,
              l_okc_rules_tl_rec.LAST_UPDATED_BY,
              l_okc_rules_tl_rec.LAST_UPDATE_DATE,
              l_okc_rules_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := rul_pktl_csr%NOTFOUND;
    CLOSE rul_pktl_csr;

    RETURN(l_okc_rules_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_rules_tl_rec             IN okc_rules_tl_rec_type
  ) RETURN okc_rules_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'get_rec';
   --
  BEGIN
    RETURN(get_rec(p_okc_rules_tl_rec, l_row_notfound));
  END get_rec;
*/
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rulv_rec                     IN rulv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rulv_rec_type IS
    CURSOR okc_rulv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
--Bug 3055393            SFWT_FLAG,
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
--Bug 3055393            TEXT,
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
     WHERE okc_rules_v.id       = p_id;
    l_okc_rulv_pk                  okc_rulv_pk_csr%ROWTYPE;
    l_rulv_rec                     rulv_rec_type;
   --
   l_proc varchar2(72) := g_package||'get_rec';
   --
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rulv_pk_csr (p_rulv_rec.id);
    FETCH okc_rulv_pk_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
--Bug 3055393              l_rulv_rec.SFWT_FLAG,
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
--Bug 3055393              l_rulv_rec.TEXT,
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
    x_no_data_found := okc_rulv_pk_csr%NOTFOUND;
    CLOSE okc_rulv_pk_csr;
    RETURN(l_rulv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rulv_rec                     IN rulv_rec_type
  ) RETURN rulv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'get_rec';
   --
  BEGIN
    RETURN(get_rec(p_rulv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RULES_V --
  -------------------------------------------------
  FUNCTION null_out_defaults (
    p_rulv_rec	IN rulv_rec_type
  ) RETURN rulv_rec_type IS
    l_rulv_rec	rulv_rec_type := p_rulv_rec;
   --
   l_proc varchar2(72) := g_package||'null_out_defaults';
   --
  BEGIN
    IF (l_rulv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.object_version_number := NULL;
    END IF;
/*--Bug 3055393
    IF (l_rulv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.sfwt_flag := NULL;
    END IF;
*/
    IF (l_rulv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.object1_id1 := NULL;
    END IF;
    IF (l_rulv_rec.object2_id1 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.object2_id1 := NULL;
    END IF;
    IF (l_rulv_rec.object3_id1 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.object3_id1 := NULL;
    END IF;
    IF (l_rulv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.object1_id2 := NULL;
    END IF;
    IF (l_rulv_rec.object2_id2 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.object2_id2 := NULL;
    END IF;
    IF (l_rulv_rec.object3_id2 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.object3_id2 := NULL;
    END IF;
    IF (l_rulv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_rulv_rec.jtot_object2_code = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.jtot_object2_code := NULL;
    END IF;
    IF (l_rulv_rec.jtot_object3_code = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.jtot_object3_code := NULL;
    END IF;
    IF (l_rulv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_rulv_rec.rgp_id = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.rgp_id := NULL;
    END IF;
    IF (l_rulv_rec.priority = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.priority := NULL;
    END IF;
    IF (l_rulv_rec.std_template_yn = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.std_template_yn := NULL;
    END IF;
    IF (l_rulv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.comments := NULL;
    END IF;
    IF (l_rulv_rec.warn_yn = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.warn_yn := NULL;
    END IF;
    IF (l_rulv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute_category := NULL;
    END IF;
    IF (l_rulv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute1 := NULL;
    END IF;
    IF (l_rulv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute2 := NULL;
    END IF;
    IF (l_rulv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute3 := NULL;
    END IF;
    IF (l_rulv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute4 := NULL;
    END IF;
    IF (l_rulv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute5 := NULL;
    END IF;
    IF (l_rulv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute6 := NULL;
    END IF;
    IF (l_rulv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute7 := NULL;
    END IF;
    IF (l_rulv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute8 := NULL;
    END IF;
    IF (l_rulv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute9 := NULL;
    END IF;
    IF (l_rulv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute10 := NULL;
    END IF;
    IF (l_rulv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute11 := NULL;
    END IF;
    IF (l_rulv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute12 := NULL;
    END IF;
    IF (l_rulv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute13 := NULL;
    END IF;
    IF (l_rulv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute14 := NULL;
    END IF;
    IF (l_rulv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.attribute15 := NULL;
    END IF;
    IF (l_rulv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.created_by := NULL;
    END IF;
    IF (l_rulv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rulv_rec.creation_date := NULL;
    END IF;
    IF (l_rulv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rulv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rulv_rec.last_update_date := NULL;
    END IF;
    IF (l_rulv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.last_update_login := NULL;
    END IF;
    --IF (DBMS_LOB.COMPARE(l_rulv_rec.text,G_MISS_CLOB)=0) THEN
    --  l_rulv_rec.text := NULL;
    --END IF;
    IF (l_rulv_rec.rule_information_category = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information_category := NULL;
    END IF;
    IF (l_rulv_rec.rule_information1 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information1 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information2 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information2 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information3 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information3 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information4 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information4 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information5 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information5 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information6 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information6 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information7 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information7 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information8 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information8 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information9 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information9 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information10 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information10 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information11 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information11 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information12 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information12 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information13 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information13 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information14 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information14 := NULL;
    END IF;
    IF (l_rulv_rec.rule_information15 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.rule_information15 := NULL;
    END IF;
    IF (l_rulv_rec.template_yn = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.template_yn := 'N';
    END IF;
    IF (l_rulv_rec.ans_set_jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.ans_set_jtot_object_code := NULL;
    END IF;
    IF (l_rulv_rec.ans_set_jtot_object_id1 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.ans_set_jtot_object_id1 := NULL;
    END IF;
    IF (l_rulv_rec.ans_set_jtot_object_id2 = OKC_API.G_MISS_CHAR) THEN
      l_rulv_rec.ans_set_jtot_object_id2 := NULL;
    END IF;
    IF (l_rulv_rec.display_sequence = OKC_API.G_MISS_NUM) THEN
      l_rulv_rec.display_sequence := NULL;
    END IF;

    RETURN(l_rulv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate_Attributes for:OKC_RULES_V --
  -----------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_rulv_rec IN  rulv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'Validate_Attributes';
   --
  BEGIN




    IF p_rulv_rec.id = OKC_API.G_MISS_NUM OR
       p_rulv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rulv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_rulv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rulv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_rulv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rulv_rec.std_template_yn = OKC_API.G_MISS_CHAR OR
          p_rulv_rec.std_template_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'std_template_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rulv_rec.warn_yn = OKC_API.G_MISS_CHAR OR
          p_rulv_rec.warn_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'warn_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rulv_rec.rule_information_category = OKC_API.G_MISS_CHAR OR
          p_rulv_rec.rule_information_category IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rule_information_category');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;




    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Validate_Record for:OKC_RULES_V --
  -------------------------------------
  FUNCTION Validate_Record (
    p_rulv_rec IN rulv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'Validate_Record';
   --
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rulv_rec_type,
    p_to	IN OUT NOCOPY rul_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'migrate';
   --
  BEGIN
    p_to.id := p_from.id;
    p_to.rgp_id := p_from.rgp_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object2_id1 := p_from.object2_id1;
    p_to.object3_id1 := p_from.object3_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.object2_id2 := p_from.object2_id2;
    p_to.object3_id2 := p_from.object3_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.jtot_object2_code := p_from.jtot_object2_code;
    p_to.jtot_object3_code := p_from.jtot_object3_code;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.std_template_yn := p_from.std_template_yn;
    p_to.warn_yn := p_from.warn_yn;
    p_to.priority := p_from.priority;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute11 := p_from.rule_information11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.rule_information_category := p_from.rule_information_category;
    p_to.rule_information1 := p_from.rule_information1;
    p_to.rule_information2 := p_from.rule_information2;
    p_to.rule_information3 := p_from.rule_information3;
    p_to.rule_information4 := p_from.rule_information4;
    p_to.rule_information5 := p_from.rule_information5;
    p_to.rule_information6 := p_from.rule_information6;
    p_to.rule_information7 := p_from.rule_information7;
    p_to.rule_information8 := p_from.rule_information8;
    p_to.rule_information9 := p_from.rule_information9;
    p_to.rule_information10 := p_from.rule_information10;
    p_to.rule_information11 := p_from.rule_information11;
    p_to.rule_information12 := p_from.rule_information12;
    p_to.rule_information13 := p_from.rule_information13;
    p_to.rule_information14 := p_from.rule_information14;
    p_to.rule_information15 := p_from.rule_information15;
    p_to.template_yn := p_from.template_yn;
    p_to.ans_set_jtot_object_code := p_from.ans_set_jtot_object_code;
    p_to.ans_set_jtot_object_id1 := p_from.ans_set_jtot_object_id1;
    p_to.ans_set_jtot_object_id2 := p_from.ans_set_jtot_object_id2;
    p_to.display_sequence := p_from.display_sequence;
--Bug 3055393
    p_to.comments := p_from.comments;


  END migrate;

  PROCEDURE migrate (
    p_from	IN rul_rec_type,
    p_to	IN OUT NOCOPY rulv_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'migrate';
   --
  BEGIN




    p_to.id := p_from.id;
    p_to.rgp_id := p_from.rgp_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object2_id1 := p_from.object2_id1;
    p_to.object3_id1 := p_from.object3_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.object2_id2 := p_from.object2_id2;
    p_to.object3_id2 := p_from.object3_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.jtot_object2_code := p_from.jtot_object2_code;
    p_to.jtot_object3_code := p_from.jtot_object3_code;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.std_template_yn := p_from.std_template_yn;
    p_to.warn_yn := p_from.warn_yn;
    p_to.priority := p_from.priority;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute11 := p_from.rule_information11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.rule_information_category := p_from.rule_information_category;
    p_to.rule_information1 := p_from.rule_information1;
    p_to.rule_information2 := p_from.rule_information2;
    p_to.rule_information3 := p_from.rule_information3;
    p_to.rule_information4 := p_from.rule_information4;
    p_to.rule_information5 := p_from.rule_information5;
    p_to.rule_information6 := p_from.rule_information6;
    p_to.rule_information7 := p_from.rule_information7;
    p_to.rule_information8 := p_from.rule_information8;
    p_to.rule_information9 := p_from.rule_information9;
    p_to.rule_information10 := p_from.rule_information10;
    p_to.rule_information11 := p_from.rule_information11;
    p_to.rule_information12 := p_from.rule_information12;
    p_to.rule_information13 := p_from.rule_information13;
    p_to.rule_information14 := p_from.rule_information14;
    p_to.rule_information15 := p_from.rule_information15;
    p_to.template_yn := p_from.template_yn;
    p_to.ans_set_jtot_object_code := p_from.ans_set_jtot_object_code;
    p_to.ans_set_jtot_object_id1 := p_from.ans_set_jtot_object_id1;
    p_to.ans_set_jtot_object_id2 := p_from.ans_set_jtot_object_id2;
    p_to.display_sequence := p_from.display_sequence;
--Bug 3055393
    p_to.comments := p_from.comments;

  END migrate;
/*--Bug 3055393
  PROCEDURE migrate (
    p_from	IN rulv_rec_type,
    p_to	IN OUT NOCOPY okc_rules_tl_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'migrate';
   --
  BEGIN




    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.text := p_from.text;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;




  END migrate;
*/
/*--Bug 3055393
  PROCEDURE migrate (
    p_from	IN okc_rules_tl_rec_type,
    p_to	IN OUT NOCOPY rulv_rec_type
  ) IS
   --
   l_proc varchar2(72) := g_package||'migrate';
   --
  BEGIN




    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.text := p_from.text;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;




  END migrate;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- validate_row for:OKC_RULES_V --
  ----------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rul_rec                      rul_rec_type;
--Bug 3055393    l_okc_rules_tl_rec             okc_rules_tl_rec_type;
   --
   l_proc varchar2(72) := g_package||'validate_row';
   --
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  IF  p_rulv_rec.VALIDATE_YN = 'Y' THEN
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_rulv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF; --end of VALIDATE_YN

    l_return_status := Validate_Record(l_rulv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:RULV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
   --
   l_proc varchar2(72) := g_package||'validate_row';
   --
  BEGIN




    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rulv_rec                     => p_rulv_tbl(i));
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  --------------------------------
  -- insert_row for:OKC_RULES_B --
  --------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rul_rec                      IN rul_rec_type,
    x_rul_rec                      OUT NOCOPY rul_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rul_rec                      rul_rec_type := p_rul_rec;
    l_def_rul_rec                  rul_rec_type;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
    ------------------------------------
    -- Set_Attributes for:OKC_RULES_B --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_rul_rec IN  rul_rec_type,
      x_rul_rec OUT NOCOPY rul_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rul_rec := p_rul_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rul_rec,                         -- IN
      l_rul_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RULES_B(
        id,
        rgp_id,
        object1_id1,
        object2_id1,
        object3_id1,
        object1_id2,
        object2_id2,
        object3_id2,
        jtot_object1_code,
        jtot_object2_code,
        jtot_object3_code,
        dnz_chr_id,
        std_template_yn,
        warn_yn,
        priority,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        rule_information_category,
        rule_information1,
        rule_information2,
        rule_information3,
        rule_information4,
        rule_information5,
        rule_information6,
        rule_information7,
        rule_information8,
        rule_information9,
        rule_information10,
        rule_information11,
        rule_information12,
        rule_information13,
        rule_information14,
        rule_information15,
        template_yn,
        ans_set_jtot_object_code,
        ans_set_jtot_object_id1,
        ans_set_jtot_object_id2,
        display_sequence,
--Bug 3055393
        comments)
      VALUES (
        l_rul_rec.id,
        l_rul_rec.rgp_id,
        l_rul_rec.object1_id1,
        l_rul_rec.object2_id1,
        l_rul_rec.object3_id1,
        l_rul_rec.object1_id2,
        l_rul_rec.object2_id2,
        l_rul_rec.object3_id2,
        l_rul_rec.jtot_object1_code,
        l_rul_rec.jtot_object2_code,
        l_rul_rec.jtot_object3_code,
        l_rul_rec.dnz_chr_id,
        l_rul_rec.std_template_yn,
        l_rul_rec.warn_yn,
        l_rul_rec.priority,
        l_rul_rec.object_version_number,
        l_rul_rec.created_by,
        l_rul_rec.creation_date,
        l_rul_rec.last_updated_by,
        l_rul_rec.last_update_date,
        l_rul_rec.last_update_login,
        l_rul_rec.attribute_category,
        l_rul_rec.attribute1,
        l_rul_rec.attribute2,
        l_rul_rec.attribute3,
        l_rul_rec.attribute4,
        l_rul_rec.attribute5,
        l_rul_rec.attribute6,
        l_rul_rec.attribute7,
        l_rul_rec.attribute8,
        l_rul_rec.attribute9,
        l_rul_rec.attribute10,
        l_rul_rec.attribute11,
        l_rul_rec.attribute12,
        l_rul_rec.attribute13,
        l_rul_rec.attribute14,
        l_rul_rec.attribute15,
        l_rul_rec.rule_information_category,
        l_rul_rec.rule_information1,
        l_rul_rec.rule_information2,
        l_rul_rec.rule_information3,
        l_rul_rec.rule_information4,
        l_rul_rec.rule_information5,
        l_rul_rec.rule_information6,
        l_rul_rec.rule_information7,
        l_rul_rec.rule_information8,
        l_rul_rec.rule_information9,
        l_rul_rec.rule_information10,
        l_rul_rec.rule_information11,
        l_rul_rec.rule_information12,
        l_rul_rec.rule_information13,
        l_rul_rec.rule_information14,
        l_rul_rec.rule_information15,
        l_rul_rec.template_yn,
        l_rul_rec.ans_set_jtot_object_code,
        l_rul_rec.ans_set_jtot_object_id1,
        l_rul_rec.ans_set_jtot_object_id2,
        l_rul_rec.display_sequence,
--Bug 3055393
        l_rul_rec.comments);
    -- Set OUT values
    x_rul_rec := l_rul_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------
  -- insert_row for:OKC_RULES_TL --
  ---------------------------------
/*--Bug 3055393
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rules_tl_rec             IN okc_rules_tl_rec_type,
    x_okc_rules_tl_rec             OUT NOCOPY okc_rules_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rules_tl_rec             okc_rules_tl_rec_type := p_okc_rules_tl_rec;
    l_def_okc_rules_tl_rec         okc_rules_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
    -------------------------------------
    -- Set_Attributes for:OKC_RULES_TL --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rules_tl_rec IN  okc_rules_tl_rec_type,
      x_okc_rules_tl_rec OUT NOCOPY okc_rules_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rules_tl_rec := p_okc_rules_tl_rec;
      x_okc_rules_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_rules_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okc_rules_tl_rec,                -- IN
      l_okc_rules_tl_rec);               -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_rules_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_RULES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          text,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_rules_tl_rec.id,
          l_okc_rules_tl_rec.language,
          l_okc_rules_tl_rec.source_lang,
          l_okc_rules_tl_rec.sfwt_flag,
          l_okc_rules_tl_rec.comments,
          l_okc_rules_tl_rec.text,
          l_okc_rules_tl_rec.created_by,
          l_okc_rules_tl_rec.creation_date,
          l_okc_rules_tl_rec.last_updated_by,
          l_okc_rules_tl_rec.last_update_date,
          l_okc_rules_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_rules_tl_rec := l_okc_rules_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
*/
  --------------------------------
  -- insert_row for:OKC_RULES_V --
  --------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec                     rulv_rec_type;
    l_def_rulv_rec                 rulv_rec_type;
    l_rul_rec                      rul_rec_type;
    lx_rul_rec                     rul_rec_type;
--Bug 3055393    l_okc_rules_tl_rec             okc_rules_tl_rec_type;
--Bug 3055393    lx_okc_rules_tl_rec            okc_rules_tl_rec_type;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rulv_rec	IN rulv_rec_type
    ) RETURN rulv_rec_type IS
      l_rulv_rec	rulv_rec_type := p_rulv_rec;
    BEGIN
      l_rulv_rec.CREATION_DATE := SYSDATE;
      l_rulv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rulv_rec.LAST_UPDATE_DATE := l_rulv_rec.creation_date;
      l_rulv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rulv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rulv_rec);
    END fill_who_columns;
    ------------------------------------
    -- Set_Attributes for:OKC_RULES_V --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_rulv_rec IN  rulv_rec_type,
      x_rulv_rec OUT NOCOPY rulv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rulv_rec := p_rulv_rec;
      x_rulv_rec.OBJECT_VERSION_NUMBER := 1;
--Bug 3055393      x_rulv_rec.SFWT_FLAG := 'N';
      /************************ HAND-CODED *********************************/
      x_rulv_rec.STD_TEMPLATE_YN                := UPPER(x_rulv_rec.STD_TEMPLATE_YN);
      x_rulv_rec.WARN_YN                        := UPPER(x_rulv_rec.WARN_YN);
      /*********************** END HAND-CODED ********************************/
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rulv_rec := null_out_defaults(p_rulv_rec);
    -- Set primary key value
    l_rulv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rulv_rec,                        -- IN
      l_def_rulv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rulv_rec := fill_who_columns(l_def_rulv_rec);

 IF p_rulv_rec.VALIDATE_YN = 'Y' THEN
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rulv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;  --end of VALIDATE_YN

    l_return_status := Validate_Record(l_def_rulv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
--+added override comments
	l_def_rulv_rec.comments := set_comments(l_def_rulv_rec);
--+
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rulv_rec, l_rul_rec);
--Bug 3055393    migrate(l_def_rulv_rec, l_okc_rules_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rul_rec,
      lx_rul_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rul_rec, l_def_rulv_rec);
/*--Bug 3055393
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rules_tl_rec,
      lx_okc_rules_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rules_tl_rec, l_def_rulv_rec);
*/
    -- Set OUT values
    x_rulv_rec := l_def_rulv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:RULV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
  BEGIN




    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rulv_rec                     => p_rulv_tbl(i),
          x_rulv_rec                     => x_rulv_tbl(i));
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ------------------------------
  -- lock_row for:OKC_RULES_B --
  ------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rul_rec                      IN rul_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rul_rec IN rul_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULES_B
     WHERE ID = p_rul_rec.id
       AND OBJECT_VERSION_NUMBER = p_rul_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rul_rec IN rul_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULES_B
    WHERE ID = p_rul_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_RULES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_RULES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_rul_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_rul_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rul_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rul_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------
  -- lock_row for:OKC_RULES_TL --
  -------------------------------
/*--Bug 3055393
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rules_tl_rec             IN okc_rules_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_rules_tl_rec IN okc_rules_tl_rec_type) IS
    SELECT *
      FROM OKC_RULES_TL
     WHERE ID = p_okc_rules_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okc_rules_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
*/
  ------------------------------
  -- lock_row for:OKC_RULES_V --
  ------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rul_rec                      rul_rec_type;
--Bug 3055393    l_okc_rules_tl_rec             okc_rules_tl_rec_type;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_rulv_rec, l_rul_rec);
--Bug 3055393    migrate(p_rulv_rec, l_okc_rules_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rul_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rules_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:RULV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
   --
   l_proc varchar2(72) := g_package||'insert_row';
   --
  BEGIN




    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rulv_rec                     => p_rulv_tbl(i));
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  --------------------------------
  -- update_row for:OKC_RULES_B --
  --------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rul_rec                      IN rul_rec_type,
    x_rul_rec                      OUT NOCOPY rul_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rul_rec                      rul_rec_type := p_rul_rec;
    l_def_rul_rec                  rul_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'update_row';
   --
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rul_rec	IN rul_rec_type,
      x_rul_rec	OUT NOCOPY rul_rec_type
    ) RETURN VARCHAR2 IS
      l_rul_rec                      rul_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'populate_new_record';
   --
    BEGIN




      x_rul_rec := p_rul_rec;
      -- Get current database values
      l_rul_rec := get_rec(p_rul_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rul_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.id := l_rul_rec.id;
      END IF;
      IF (x_rul_rec.rgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.rgp_id := l_rul_rec.rgp_id;
      END IF;
      IF (x_rul_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.object1_id1 := l_rul_rec.object1_id1;
      END IF;
      IF (x_rul_rec.object2_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.object2_id1 := l_rul_rec.object2_id1;
      END IF;
      IF (x_rul_rec.object3_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.object3_id1 := l_rul_rec.object3_id1;
      END IF;
      IF (x_rul_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.object1_id2 := l_rul_rec.object1_id2;
      END IF;
      IF (x_rul_rec.object2_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.object2_id2 := l_rul_rec.object2_id2;
      END IF;
      IF (x_rul_rec.object3_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.object3_id2 := l_rul_rec.object3_id2;
      END IF;
      IF (x_rul_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.jtot_object1_code := l_rul_rec.jtot_object1_code;
      END IF;
      IF (x_rul_rec.jtot_object2_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.jtot_object2_code := l_rul_rec.jtot_object2_code;
      END IF;
      IF (x_rul_rec.jtot_object3_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.jtot_object3_code := l_rul_rec.jtot_object3_code;
      END IF;
      IF (x_rul_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.dnz_chr_id := l_rul_rec.dnz_chr_id;
      END IF;
      IF (x_rul_rec.std_template_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.std_template_yn := l_rul_rec.std_template_yn;
      END IF;
      IF (x_rul_rec.warn_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.warn_yn := l_rul_rec.warn_yn;
      END IF;
      IF (x_rul_rec.priority = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.priority := l_rul_rec.priority;
      END IF;
      IF (x_rul_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.object_version_number := l_rul_rec.object_version_number;
      END IF;
      IF (x_rul_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.created_by := l_rul_rec.created_by;
      END IF;
      IF (x_rul_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rul_rec.creation_date := l_rul_rec.creation_date;
      END IF;
      IF (x_rul_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.last_updated_by := l_rul_rec.last_updated_by;
      END IF;
      IF (x_rul_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rul_rec.last_update_date := l_rul_rec.last_update_date;
      END IF;
      IF (x_rul_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.last_update_login := l_rul_rec.last_update_login;
      END IF;
      IF (x_rul_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute_category := l_rul_rec.attribute_category;
      END IF;
      IF (x_rul_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute1 := l_rul_rec.attribute1;
      END IF;
      IF (x_rul_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute2 := l_rul_rec.attribute2;
      END IF;
      IF (x_rul_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute3 := l_rul_rec.attribute3;
      END IF;
      IF (x_rul_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute4 := l_rul_rec.attribute4;
      END IF;
      IF (x_rul_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute5 := l_rul_rec.attribute5;
      END IF;
      IF (x_rul_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute6 := l_rul_rec.attribute6;
      END IF;
      IF (x_rul_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute7 := l_rul_rec.attribute7;
      END IF;
      IF (x_rul_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute8 := l_rul_rec.attribute8;
      END IF;
      IF (x_rul_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute9 := l_rul_rec.attribute9;
      END IF;
      IF (x_rul_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute10 := l_rul_rec.attribute10;
      END IF;
      IF (x_rul_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute11 := l_rul_rec.attribute11;
      END IF;
      IF (x_rul_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute12 := l_rul_rec.attribute12;
      END IF;
      IF (x_rul_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute13 := l_rul_rec.attribute13;
      END IF;
      IF (x_rul_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute14 := l_rul_rec.attribute14;
      END IF;
      IF (x_rul_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.attribute15 := l_rul_rec.attribute15;
      END IF;
      IF (x_rul_rec.rule_information_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information_category := l_rul_rec.rule_information_category;
      END IF;
      IF (x_rul_rec.rule_information1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information1 := l_rul_rec.rule_information1;
      END IF;
      IF (x_rul_rec.rule_information2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information2 := l_rul_rec.rule_information2;
      END IF;
      IF (x_rul_rec.rule_information3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information3 := l_rul_rec.rule_information3;
      END IF;
      IF (x_rul_rec.rule_information4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information4 := l_rul_rec.rule_information4;
      END IF;
      IF (x_rul_rec.rule_information5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information5 := l_rul_rec.rule_information5;
      END IF;
      IF (x_rul_rec.rule_information6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information6 := l_rul_rec.rule_information6;
      END IF;
      IF (x_rul_rec.rule_information7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information7 := l_rul_rec.rule_information7;
      END IF;
      IF (x_rul_rec.rule_information8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information8 := l_rul_rec.rule_information8;
      END IF;
      IF (x_rul_rec.rule_information9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information9 := l_rul_rec.rule_information9;
      END IF;
      IF (x_rul_rec.rule_information10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information10 := l_rul_rec.rule_information10;
      END IF;
      IF (x_rul_rec.rule_information11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information11 := l_rul_rec.rule_information11;
      END IF;
      IF (x_rul_rec.rule_information12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information12 := l_rul_rec.rule_information12;
      END IF;
      IF (x_rul_rec.rule_information13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information13 := l_rul_rec.rule_information13;
      END IF;
      IF (x_rul_rec.rule_information14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information14 := l_rul_rec.rule_information14;
      END IF;
      IF (x_rul_rec.rule_information15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.rule_information15 := l_rul_rec.rule_information15;
      END IF;
      IF (x_rul_rec.template_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.template_yn := l_rul_rec.template_yn;
      END IF;
      IF (x_rul_rec.ans_set_jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.ans_set_jtot_object_code := l_rul_rec.ans_set_jtot_object_code;
      END IF;
      IF (x_rul_rec.ans_set_jtot_object_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.ans_set_jtot_object_id1 := l_rul_rec.ans_set_jtot_object_id1;
      END IF;
      IF (x_rul_rec.ans_set_jtot_object_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.ans_set_jtot_object_id2 := l_rul_rec.ans_set_jtot_object_id2;
      END IF;
      IF (x_rul_rec.display_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_rul_rec.display_sequence := l_rul_rec.display_sequence;
      END IF;
--Bug 3055393
      IF (x_rul_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_rul_rec.comments := l_rul_rec.comments;
      END IF;




      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKC_RULES_B --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_rul_rec IN  rul_rec_type,
      x_rul_rec OUT NOCOPY rul_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rul_rec := p_rul_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rul_rec,                         -- IN
      l_rul_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rul_rec, l_def_rul_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKC_RULES_B
    SET RGP_ID = l_def_rul_rec.rgp_id,
        OBJECT1_ID1 = l_def_rul_rec.object1_id1,
        OBJECT2_ID1 = l_def_rul_rec.object2_id1,
        OBJECT3_ID1 = l_def_rul_rec.object3_id1,
        OBJECT1_ID2 = l_def_rul_rec.object1_id2,
        OBJECT2_ID2 = l_def_rul_rec.object2_id2,
        OBJECT3_ID2 = l_def_rul_rec.object3_id2,
        JTOT_OBJECT1_CODE = l_def_rul_rec.jtot_object1_code,
        JTOT_OBJECT2_CODE = l_def_rul_rec.jtot_object2_code,
        JTOT_OBJECT3_CODE = l_def_rul_rec.jtot_object3_code,
        DNZ_CHR_ID = l_def_rul_rec.dnz_chr_id,
        STD_TEMPLATE_YN = l_def_rul_rec.std_template_yn,
        WARN_YN = l_def_rul_rec.warn_yn,
        PRIORITY = l_def_rul_rec.priority,
        OBJECT_VERSION_NUMBER = l_def_rul_rec.object_version_number,
        CREATED_BY = l_def_rul_rec.created_by,
        CREATION_DATE = l_def_rul_rec.creation_date,
        LAST_UPDATED_BY = l_def_rul_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rul_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rul_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_rul_rec.attribute_category,
        ATTRIBUTE1 = l_def_rul_rec.attribute1,
        ATTRIBUTE2 = l_def_rul_rec.attribute2,
        ATTRIBUTE3 = l_def_rul_rec.attribute3,
        ATTRIBUTE4 = l_def_rul_rec.attribute4,
        ATTRIBUTE5 = l_def_rul_rec.attribute5,
        ATTRIBUTE6 = l_def_rul_rec.attribute6,
        ATTRIBUTE7 = l_def_rul_rec.attribute7,
        ATTRIBUTE8 = l_def_rul_rec.attribute8,
        ATTRIBUTE9 = l_def_rul_rec.attribute9,
        ATTRIBUTE10 = l_def_rul_rec.attribute10,
        ATTRIBUTE11 = l_def_rul_rec.attribute11,
        ATTRIBUTE12 = l_def_rul_rec.attribute12,
        ATTRIBUTE13 = l_def_rul_rec.attribute13,
        ATTRIBUTE14 = l_def_rul_rec.attribute14,
        ATTRIBUTE15 = l_def_rul_rec.attribute15,
        RULE_INFORMATION_CATEGORY = l_def_rul_rec.rule_information_category,
        RULE_INFORMATION1 = l_def_rul_rec.rule_information1,
        RULE_INFORMATION2 = l_def_rul_rec.rule_information2,
        RULE_INFORMATION3 = l_def_rul_rec.rule_information3,
        RULE_INFORMATION4 = l_def_rul_rec.rule_information4,
        RULE_INFORMATION5 = l_def_rul_rec.rule_information5,
        RULE_INFORMATION6 = l_def_rul_rec.rule_information6,
        RULE_INFORMATION7 = l_def_rul_rec.rule_information7,
        RULE_INFORMATION8 = l_def_rul_rec.rule_information8,
        RULE_INFORMATION9 = l_def_rul_rec.rule_information9,
        RULE_INFORMATION10 = l_def_rul_rec.rule_information10,
        RULE_INFORMATION11 = l_def_rul_rec.rule_information11,
        RULE_INFORMATION12 = l_def_rul_rec.rule_information12,
        RULE_INFORMATION13 = l_def_rul_rec.rule_information13,
        RULE_INFORMATION14 = l_def_rul_rec.rule_information14,
        RULE_INFORMATION15 = l_def_rul_rec.rule_information15,
        TEMPLATE_YN = l_def_rul_rec.template_yn,
        ans_set_jtot_object_code = l_def_rul_rec.ans_set_jtot_object_code,
        ans_set_jtot_object_id1 = l_def_rul_rec.ans_set_jtot_object_id1,
        ans_set_jtot_object_id2 = l_def_rul_rec.ans_set_jtot_object_id2,
        DISPLAY_SEQUENCE = l_def_rul_rec.display_sequence,
--Bug 3055393
        comments = l_def_rul_rec.comments
    WHERE ID = l_def_rul_rec.id;

    x_rul_rec := l_def_rul_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ---------------------------------
  -- update_row for:OKC_RULES_TL --
  ---------------------------------
/*--Bug 3055393
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rules_tl_rec             IN okc_rules_tl_rec_type,
    x_okc_rules_tl_rec             OUT NOCOPY okc_rules_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rules_tl_rec             okc_rules_tl_rec_type := p_okc_rules_tl_rec;
    l_def_okc_rules_tl_rec         okc_rules_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'update_row';
   --
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_rules_tl_rec	IN okc_rules_tl_rec_type,
      x_okc_rules_tl_rec	OUT NOCOPY okc_rules_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_rules_tl_rec             okc_rules_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rules_tl_rec := p_okc_rules_tl_rec;
      -- Get current database values
      l_okc_rules_tl_rec := get_rec(p_okc_rules_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_rules_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rules_tl_rec.id := l_okc_rules_tl_rec.id;
      END IF;
      IF (x_okc_rules_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rules_tl_rec.language := l_okc_rules_tl_rec.language;
      END IF;
      IF (x_okc_rules_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rules_tl_rec.source_lang := l_okc_rules_tl_rec.source_lang;
      END IF;
      IF (x_okc_rules_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rules_tl_rec.sfwt_flag := l_okc_rules_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_rules_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_rules_tl_rec.comments := l_okc_rules_tl_rec.comments;
      END IF;
      IF (x_okc_rules_tl_rec.text IS NULL)
      THEN
        x_okc_rules_tl_rec.text := l_okc_rules_tl_rec.text;
      END IF;
      IF (x_okc_rules_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rules_tl_rec.created_by := l_okc_rules_tl_rec.created_by;
      END IF;
      IF (x_okc_rules_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_rules_tl_rec.creation_date := l_okc_rules_tl_rec.creation_date;
      END IF;
      IF (x_okc_rules_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rules_tl_rec.last_updated_by := l_okc_rules_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_rules_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_rules_tl_rec.last_update_date := l_okc_rules_tl_rec.last_update_date;
      END IF;
      IF (x_okc_rules_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_rules_tl_rec.last_update_login := l_okc_rules_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKC_RULES_TL --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rules_tl_rec IN  okc_rules_tl_rec_type,
      x_okc_rules_tl_rec OUT NOCOPY okc_rules_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rules_tl_rec := p_okc_rules_tl_rec;
      x_okc_rules_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_rules_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okc_rules_tl_rec,                -- IN
      l_okc_rules_tl_rec);               -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_rules_tl_rec, l_def_okc_rules_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RULES_TL
    SET COMMENTS = l_def_okc_rules_tl_rec.comments,
        TEXT = l_def_okc_rules_tl_rec.text,
        CREATED_BY = l_def_okc_rules_tl_rec.created_by,
        CREATION_DATE = l_def_okc_rules_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_rules_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_rules_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_rules_tl_rec.last_update_login
    WHERE ID = l_def_okc_rules_tl_rec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_RULES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_rules_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_rules_tl_rec := l_def_okc_rules_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
*/
  --------------------------------
  -- update_row for:OKC_RULES_V --
  --------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_def_rulv_rec                 rulv_rec_type;
--Bug 3055393    l_okc_rules_tl_rec             okc_rules_tl_rec_type;
--Bug 3055393    lx_okc_rules_tl_rec            okc_rules_tl_rec_type;
    l_rul_rec                      rul_rec_type;
    lx_rul_rec                     rul_rec_type;
   --
   l_proc varchar2(72) := g_package||'update_row';
   --
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rulv_rec	IN rulv_rec_type
    ) RETURN rulv_rec_type IS
      l_rulv_rec	rulv_rec_type := p_rulv_rec;
    BEGIN
      l_rulv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rulv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rulv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rulv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rulv_rec	IN rulv_rec_type,
      x_rulv_rec	OUT NOCOPY rulv_rec_type
    ) RETURN VARCHAR2 IS
      l_rulv_rec                     rulv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rulv_rec := p_rulv_rec;
      -- Get current database values
      l_rulv_rec := get_rec(p_rulv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rulv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.id := l_rulv_rec.id;
      END IF;
      IF (x_rulv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.object_version_number := l_rulv_rec.object_version_number;
      END IF;
/*--Bug 3055393
      IF (x_rulv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.sfwt_flag := l_rulv_rec.sfwt_flag;
      END IF;
*/
      IF (x_rulv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.object1_id1 := l_rulv_rec.object1_id1;
      END IF;
      IF (x_rulv_rec.object2_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.object2_id1 := l_rulv_rec.object2_id1;
      END IF;
      IF (x_rulv_rec.object3_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.object3_id1 := l_rulv_rec.object3_id1;
      END IF;
      IF (x_rulv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.object1_id2 := l_rulv_rec.object1_id2;
      END IF;
      IF (x_rulv_rec.object2_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.object2_id2 := l_rulv_rec.object2_id2;
      END IF;
      IF (x_rulv_rec.object3_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.object3_id2 := l_rulv_rec.object3_id2;
      END IF;
      IF (x_rulv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.jtot_object1_code := l_rulv_rec.jtot_object1_code;
      END IF;
      IF (x_rulv_rec.jtot_object2_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.jtot_object2_code := l_rulv_rec.jtot_object2_code;
      END IF;
      IF (x_rulv_rec.jtot_object3_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.jtot_object3_code := l_rulv_rec.jtot_object3_code;
      END IF;
      IF (x_rulv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.dnz_chr_id := l_rulv_rec.dnz_chr_id;
      END IF;
      IF (x_rulv_rec.rgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.rgp_id := l_rulv_rec.rgp_id;
      END IF;
      IF (x_rulv_rec.priority = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.priority := l_rulv_rec.priority;
      END IF;
      IF (x_rulv_rec.std_template_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.std_template_yn := l_rulv_rec.std_template_yn;
      END IF;
      IF (x_rulv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.comments := l_rulv_rec.comments;
      END IF;
      IF (x_rulv_rec.warn_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.warn_yn := l_rulv_rec.warn_yn;
      END IF;
      IF (x_rulv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute_category := l_rulv_rec.attribute_category;
      END IF;
      IF (x_rulv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute1 := l_rulv_rec.attribute1;
      END IF;
      IF (x_rulv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute2 := l_rulv_rec.attribute2;
      END IF;
      IF (x_rulv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute3 := l_rulv_rec.attribute3;
      END IF;
      IF (x_rulv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute4 := l_rulv_rec.attribute4;
      END IF;
      IF (x_rulv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute5 := l_rulv_rec.attribute5;
      END IF;
      IF (x_rulv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute6 := l_rulv_rec.attribute6;
      END IF;
      IF (x_rulv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute7 := l_rulv_rec.attribute7;
      END IF;
      IF (x_rulv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute8 := l_rulv_rec.attribute8;
      END IF;
      IF (x_rulv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute9 := l_rulv_rec.attribute9;
      END IF;
      IF (x_rulv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute10 := l_rulv_rec.attribute10;
      END IF;
      IF (x_rulv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute11 := l_rulv_rec.attribute11;
      END IF;
      IF (x_rulv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute12 := l_rulv_rec.attribute12;
      END IF;
      IF (x_rulv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute13 := l_rulv_rec.attribute13;
      END IF;
      IF (x_rulv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute14 := l_rulv_rec.attribute14;
      END IF;
      IF (x_rulv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.attribute15 := l_rulv_rec.attribute15;
      END IF;
      IF (x_rulv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.created_by := l_rulv_rec.created_by;
      END IF;
      IF (x_rulv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rulv_rec.creation_date := l_rulv_rec.creation_date;
      END IF;
      IF (x_rulv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.last_updated_by := l_rulv_rec.last_updated_by;
      END IF;
      IF (x_rulv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rulv_rec.last_update_date := l_rulv_rec.last_update_date;
      END IF;
      IF (x_rulv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.last_update_login := l_rulv_rec.last_update_login;
      END IF;
/*--Bug 3055393
      IF (x_rulv_rec.text IS NULL)
      THEN
        x_rulv_rec.text := l_rulv_rec.text;
      END IF;
*/
      IF (x_rulv_rec.rule_information_category = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information_category := l_rulv_rec.rule_information_category;
      END IF;
      IF (x_rulv_rec.rule_information1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information1 := l_rulv_rec.rule_information1;
      END IF;
      IF (x_rulv_rec.rule_information2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information2 := l_rulv_rec.rule_information2;
      END IF;
      IF (x_rulv_rec.rule_information3 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information3 := l_rulv_rec.rule_information3;
      END IF;
      IF (x_rulv_rec.rule_information4 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information4 := l_rulv_rec.rule_information4;
      END IF;
      IF (x_rulv_rec.rule_information5 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information5 := l_rulv_rec.rule_information5;
      END IF;
      IF (x_rulv_rec.rule_information6 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information6 := l_rulv_rec.rule_information6;
      END IF;
      IF (x_rulv_rec.rule_information7 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information7 := l_rulv_rec.rule_information7;
      END IF;
      IF (x_rulv_rec.rule_information8 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information8 := l_rulv_rec.rule_information8;
      END IF;
      IF (x_rulv_rec.rule_information9 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information9 := l_rulv_rec.rule_information9;
      END IF;
      IF (x_rulv_rec.rule_information10 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information10 := l_rulv_rec.rule_information10;
      END IF;
      IF (x_rulv_rec.rule_information11 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information11 := l_rulv_rec.rule_information11;
      END IF;
      IF (x_rulv_rec.rule_information12 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information12 := l_rulv_rec.rule_information12;
      END IF;
      IF (x_rulv_rec.rule_information13 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information13 := l_rulv_rec.rule_information13;
      END IF;
      IF (x_rulv_rec.rule_information14 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information14 := l_rulv_rec.rule_information14;
      END IF;
      IF (x_rulv_rec.rule_information15 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.rule_information15 := l_rulv_rec.rule_information15;
      END IF;
      IF (x_rulv_rec.template_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.template_yn := l_rulv_rec.template_yn;
      END IF;
      IF (x_rulv_rec.ans_set_jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.ans_set_jtot_object_code := l_rulv_rec.ans_set_jtot_object_code;
      END IF;
      IF (x_rulv_rec.ans_set_jtot_object_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.ans_set_jtot_object_id1 := l_rulv_rec.ans_set_jtot_object_id1;
      END IF;
      IF (x_rulv_rec.ans_set_jtot_object_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_rulv_rec.ans_set_jtot_object_id2 := l_rulv_rec.ans_set_jtot_object_id2;
      END IF;
      IF (x_rulv_rec.display_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_rulv_rec.display_sequence := l_rulv_rec.display_sequence;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKC_RULES_V --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_rulv_rec IN  rulv_rec_type,
      x_rulv_rec OUT NOCOPY rulv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rulv_rec := p_rulv_rec;
      x_rulv_rec.OBJECT_VERSION_NUMBER := NVL(x_rulv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rulv_rec,                        -- IN
      l_rulv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rulv_rec, l_def_rulv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rulv_rec := fill_who_columns(l_def_rulv_rec);

 IF  p_rulv_rec.VALIDATE_YN = 'Y' THEN
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rulv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
 END IF; -- end of VALIDATE_YN

    l_return_status := Validate_Record(l_def_rulv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

--+added override comments
	l_def_rulv_rec.comments := set_comments(l_def_rulv_rec);
--+

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
--Bug 3055393    migrate(l_def_rulv_rec, l_okc_rules_tl_rec);
    migrate(l_def_rulv_rec, l_rul_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
/*--Bug 3055393
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rules_tl_rec,
      lx_okc_rules_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rules_tl_rec, l_def_rulv_rec);
*/
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rul_rec,
      lx_rul_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rul_rec, l_def_rulv_rec);
    x_rulv_rec := l_def_rulv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:RULV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
   --
   l_proc varchar2(72) := g_package||'update_row';
   --
  BEGIN




    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rulv_rec                     => p_rulv_tbl(i),
          x_rulv_rec                     => x_rulv_tbl(i));
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  --------------------------------
  -- delete_row for:OKC_RULES_B --
  --------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rul_rec                      IN rul_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rul_rec                      rul_rec_type:= p_rul_rec;
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'delete_row';
   --
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_RULES_B
     WHERE ID = l_rul_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ---------------------------------
  -- delete_row for:OKC_RULES_TL --
  ---------------------------------
/*--Bug 3055393
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rules_tl_rec             IN okc_rules_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rules_tl_rec             okc_rules_tl_rec_type:= p_okc_rules_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
   --
   l_proc varchar2(72) := g_package||'delete_row';
   --
    -------------------------------------
    -- Set_Attributes for:OKC_RULES_TL --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rules_tl_rec IN  okc_rules_tl_rec_type,
      x_okc_rules_tl_rec OUT NOCOPY okc_rules_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rules_tl_rec := p_okc_rules_tl_rec;
      x_okc_rules_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okc_rules_tl_rec,                -- IN
      l_okc_rules_tl_rec);               -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_RULES_TL
     WHERE ID = l_okc_rules_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
*/
  --------------------------------
  -- delete_row for:OKC_RULES_V --
  --------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
--Bug 3055393    l_okc_rules_tl_rec             okc_rules_tl_rec_type;
    l_rul_rec                      rul_rec_type;
   --
   l_proc varchar2(72) := g_package||'delete_row';
   --
  BEGIN




    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
--Bug 3055393    migrate(l_rulv_rec, l_okc_rules_tl_rec);
    migrate(l_rulv_rec, l_rul_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
/*--Bug 3055393
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rules_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rul_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:RULV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
   --
   l_proc varchar2(72) := g_package||'delete_row';
   --
  BEGIN




    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rulv_rec                     => p_rulv_tbl(i));
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

---------------------------------------------------------------
-- Procedure for mass insert in OKC_RULES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_rulv_tbl rulv_tbl_type) IS
  l_tabsize NUMBER := p_rulv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
--Bug 3055393  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_object1_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object2_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object3_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object1_id2                   OKC_DATATYPES.Var200TabTyp;
  in_object2_id2                   OKC_DATATYPES.Var200TabTyp;
  in_object3_id2                   OKC_DATATYPES.Var200TabTyp;
  in_jtot_object1_code             OKC_DATATYPES.Var30TabTyp;
  in_jtot_object2_code             OKC_DATATYPES.Var30TabTyp;
  in_jtot_object3_code             OKC_DATATYPES.Var30TabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_rgp_id                        OKC_DATATYPES.NumberTabTyp;
  in_priority                      OKC_DATATYPES.NumberTabTyp;
  in_std_template_yn               OKC_DATATYPES.Var3TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_warn_yn                       OKC_DATATYPES.Var3TabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
--Bug 3055393  in_text                          OKC_DATATYPES.clobTabTyp;
  in_rule_information_category     OKC_DATATYPES.Var90TabTyp;
  in_rule_information1             OKC_DATATYPES.Var450TabTyp;
  in_rule_information2             OKC_DATATYPES.Var450TabTyp;
  in_rule_information3             OKC_DATATYPES.Var450TabTyp;
  in_rule_information4             OKC_DATATYPES.Var450TabTyp;
  in_rule_information5             OKC_DATATYPES.Var450TabTyp;
  in_rule_information6             OKC_DATATYPES.Var450TabTyp;
  in_rule_information7             OKC_DATATYPES.Var450TabTyp;
  in_rule_information8             OKC_DATATYPES.Var450TabTyp;
  in_rule_information9             OKC_DATATYPES.Var450TabTyp;
  in_rule_information10            OKC_DATATYPES.Var450TabTyp;
  in_rule_information11            OKC_DATATYPES.Var450TabTyp;
  in_rule_information12            OKC_DATATYPES.Var450TabTyp;
  in_rule_information13            OKC_DATATYPES.Var450TabTyp;
  in_rule_information14            OKC_DATATYPES.Var450TabTyp;
  in_rule_information15            OKC_DATATYPES.Var450TabTyp;
  in_template_yn                   OKC_DATATYPES.Var3TabTyp;
  in_ans_set_jtot_object_code      OKC_DATATYPES.Var90TabTyp;
  in_ans_set_jtot_object_id1           OKC_DATATYPES.Var90TabTyp;
  in_ans_set_jtot_object_id2           OKC_DATATYPES.Var90TabTyp;
  in_display_sequence              OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
   --
   l_proc varchar2(72) := g_package||'INSERT_ROW_UPG';
   --
BEGIN
  -- Initialize return status
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  i := p_rulv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_rulv_tbl(i).id;
    in_object_version_number    (j) := p_rulv_tbl(i).object_version_number;
--Bug 3055393    in_sfwt_flag                (j) := p_rulv_tbl(i).sfwt_flag;
    in_object1_id1              (j) := p_rulv_tbl(i).object1_id1;
    in_object2_id1              (j) := p_rulv_tbl(i).object2_id1;
    in_object3_id1              (j) := p_rulv_tbl(i).object3_id1;
    in_object1_id2              (j) := p_rulv_tbl(i).object1_id2;
    in_object2_id2              (j) := p_rulv_tbl(i).object2_id2;
    in_object3_id2              (j) := p_rulv_tbl(i).object3_id2;
    in_jtot_object1_code        (j) := p_rulv_tbl(i).jtot_object1_code;
    in_jtot_object2_code        (j) := p_rulv_tbl(i).jtot_object2_code;
    in_jtot_object3_code        (j) := p_rulv_tbl(i).jtot_object3_code;
    in_dnz_chr_id               (j) := p_rulv_tbl(i).dnz_chr_id;
    in_rgp_id                   (j) := p_rulv_tbl(i).rgp_id;
    in_priority                 (j) := p_rulv_tbl(i).priority;
    in_std_template_yn          (j) := p_rulv_tbl(i).std_template_yn;
    in_comments                 (j) := p_rulv_tbl(i).comments;
    in_warn_yn                  (j) := p_rulv_tbl(i).warn_yn;
    in_attribute_category       (j) := p_rulv_tbl(i).attribute_category;
    in_attribute1               (j) := p_rulv_tbl(i).attribute1;
    in_attribute2               (j) := p_rulv_tbl(i).attribute2;
    in_attribute3               (j) := p_rulv_tbl(i).attribute3;
    in_attribute4               (j) := p_rulv_tbl(i).attribute4;
    in_attribute5               (j) := p_rulv_tbl(i).attribute5;
    in_attribute6               (j) := p_rulv_tbl(i).attribute6;
    in_attribute7               (j) := p_rulv_tbl(i).attribute7;
    in_attribute8               (j) := p_rulv_tbl(i).attribute8;
    in_attribute9               (j) := p_rulv_tbl(i).attribute9;
    in_attribute10              (j) := p_rulv_tbl(i).attribute10;
    in_attribute11              (j) := p_rulv_tbl(i).attribute11;
    in_attribute12              (j) := p_rulv_tbl(i).attribute12;
    in_attribute13              (j) := p_rulv_tbl(i).attribute13;
    in_attribute14              (j) := p_rulv_tbl(i).attribute14;
    in_attribute15              (j) := p_rulv_tbl(i).attribute15;
    in_created_by               (j) := p_rulv_tbl(i).created_by;
    in_creation_date            (j) := p_rulv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_rulv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_rulv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_rulv_tbl(i).last_update_login;
--Bug 3055393    in_text                     (j) := p_rulv_tbl(i).text;
    in_rule_information_category(j) := p_rulv_tbl(i).rule_information_category;
    in_rule_information1        (j) := p_rulv_tbl(i).rule_information1;
    in_rule_information2        (j) := p_rulv_tbl(i).rule_information2;
    in_rule_information3        (j) := p_rulv_tbl(i).rule_information3;
    in_rule_information4        (j) := p_rulv_tbl(i).rule_information4;
    in_rule_information5        (j) := p_rulv_tbl(i).rule_information5;
    in_rule_information6        (j) := p_rulv_tbl(i).rule_information6;
    in_rule_information7        (j) := p_rulv_tbl(i).rule_information7;
    in_rule_information8        (j) := p_rulv_tbl(i).rule_information8;
    in_rule_information9        (j) := p_rulv_tbl(i).rule_information9;
    in_rule_information10       (j) := p_rulv_tbl(i).rule_information10;
    in_rule_information11       (j) := p_rulv_tbl(i).rule_information11;
    in_rule_information12       (j) := p_rulv_tbl(i).rule_information12;
    in_rule_information13       (j) := p_rulv_tbl(i).rule_information13;
    in_rule_information14       (j) := p_rulv_tbl(i).rule_information14;
    in_rule_information15       (j) := p_rulv_tbl(i).rule_information15;
    in_template_yn              (j) := p_rulv_tbl(i).template_yn;
    in_ans_set_jtot_object_code        (j) := p_rulv_tbl(i).ans_set_jtot_object_code;
    in_ans_set_jtot_object_id1            (j) := p_rulv_tbl(i).ans_set_jtot_object_id1;
    in_ans_set_jtot_object_id2            (j) := p_rulv_tbl(i).ans_set_jtot_object_id2;
    in_display_sequence         (j) := p_rulv_tbl(i).display_sequence;
    i:=p_rulv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_RULES_B
      (
        id,
        rgp_id,
        object1_id1,
        object2_id1,
        object3_id1,
        object1_id2,
        object2_id2,
        object3_id2,
        jtot_object1_code,
        jtot_object2_code,
        jtot_object3_code,
        dnz_chr_id,
        std_template_yn,
        warn_yn,
        priority,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        rule_information_category,
        rule_information1,
        rule_information2,
        rule_information3,
        rule_information4,
        rule_information5,
        rule_information6,
        rule_information7,
        rule_information8,
        rule_information9,
        rule_information10,
        rule_information11,
        rule_information12,
        rule_information13,
        rule_information14,
        rule_information15,
        template_yn,
        ans_set_jtot_object_code,
        ans_set_jtot_object_id1,
        ans_set_jtot_object_id2,
        display_sequence,
--Bug 3055393
        comments
     )
     VALUES (
        in_id(i),
        in_rgp_id(i),
        in_object1_id1(i),
        in_object2_id1(i),
        in_object3_id1(i),
        in_object1_id2(i),
        in_object2_id2(i),
        in_object3_id2(i),
        in_jtot_object1_code(i),
        in_jtot_object2_code(i),
        in_jtot_object3_code(i),
        in_dnz_chr_id(i),
        in_std_template_yn(i),
        in_warn_yn(i),
        in_priority(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
        in_attribute_category(i),
        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i),
        in_rule_information_category(i),
        in_rule_information1(i),
        in_rule_information2(i),
        in_rule_information3(i),
        in_rule_information4(i),
        in_rule_information5(i),
        in_rule_information6(i),
        in_rule_information7(i),
        in_rule_information8(i),
        in_rule_information9(i),
        in_rule_information10(i),
        in_rule_information11(i),
        in_rule_information12(i),
        in_rule_information13(i),
        in_rule_information14(i),
        in_rule_information15(i),
        in_template_yn(i),
        in_ans_set_jtot_object_code(i),
        in_ans_set_jtot_object_id1(i),
        in_ans_set_jtot_object_id2(i),
        in_display_sequence(i),
--Bug 3055393
        in_comments(i)
     );
/*--Bug 3055393
  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKC_RULES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        comments,
        --text,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        in_sfwt_flag(i),
        in_comments(i),
        --in_text(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
      );
      END LOOP;
*/
EXCEPTION
  WHEN OTHERS THEN

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
    --RAISE;
END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

   --
   l_proc varchar2(72) := g_package||'create_version';
   --
BEGIN




INSERT INTO okc_rules_bh
  (
      major_version,
      id,
      rgp_id,
      object1_id1,
      object2_id1,
      object3_id1,
      object1_id2,
      object2_id2,
      object3_id2,
      jtot_object1_code,
      jtot_object2_code,
      jtot_object3_code,
      dnz_chr_id,
      std_template_yn,
      warn_yn,
      priority,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      rule_information_category,
      rule_information1,
      rule_information2,
      rule_information3,
      rule_information4,
      rule_information5,
      rule_information6,
      rule_information7,
      rule_information8,
      rule_information9,
      rule_information10,
      rule_information11,
      rule_information12,
      rule_information13,
      rule_information14,
      rule_information15,
      template_yn,
      ans_set_jtot_object_code,
      ans_set_jtot_object_id1,
      ans_set_jtot_object_id2,
      display_sequence,
--Bug 3055393
      comments
)
  SELECT
      p_major_version,
      id,
      rgp_id,
      object1_id1,
      object2_id1,
      object3_id1,
      object1_id2,
      object2_id2,
      object3_id2,
      jtot_object1_code,
      jtot_object2_code,
      jtot_object3_code,
      dnz_chr_id,
      std_template_yn,
      warn_yn,
      priority,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      rule_information_category,
      rule_information1,
      rule_information2,
      rule_information3,
      rule_information4,
      rule_information5,
      rule_information6,
      rule_information7,
      rule_information8,
      rule_information9,
      rule_information10,
      rule_information11,
      rule_information12,
      rule_information13,
      rule_information14,
      rule_information15,
      template_yn,
      ans_set_jtot_object_code,
      ans_set_jtot_object_id1,
      ans_set_jtot_object_id2,
      display_sequence,
--Bug 3055393
      comments
  FROM okc_rules_b
 WHERE dnz_chr_id = p_chr_id;

--------------------------------
-- Versioning TL Table
--------------------------------
/*--Bug 3055393
INSERT INTO okc_rules_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_rules_tl
 WHERE id  in (select id
			  from okc_rules_b
			 where dnz_chr_id = p_chr_id);

*/

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN


       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

   --
   l_proc varchar2(72) := g_package||'restore_version';
   --
BEGIN


/*--Bug 3055393

INSERT INTO okc_rules_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      comments,
      text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_rules_tlh
WHERE id in (SELECT id
			FROM okc_rules_bh
		    WHERE dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;
*/
-----------------------------------------
-- Restoring Base Table
-----------------------------------------

INSERT INTO okc_rules_b
(
      id,
      rgp_id,
      object1_id1,
      object2_id1,
      object3_id1,
      object1_id2,
      object2_id2,
      object3_id2,
      jtot_object1_code,
      jtot_object2_code,
      jtot_object3_code,
      dnz_chr_id,
      std_template_yn,
      warn_yn,
      priority,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      rule_information_category,
      rule_information1,
      rule_information2,
      rule_information3,
      rule_information4,
      rule_information5,
      rule_information6,
      rule_information7,
      rule_information8,
      rule_information9,
      rule_information10,
      rule_information11,
      rule_information12,
      rule_information13,
      rule_information14,
      rule_information15,
      template_yn,
      ans_set_jtot_object_code,
      ans_set_jtot_object_id1,
      ans_set_jtot_object_id2,
      display_sequence,
      comments
)
  SELECT
      id,
      rgp_id,
      object1_id1,
      object2_id1,
      object3_id1,
      object1_id2,
      object2_id2,
      object3_id2,
      jtot_object1_code,
      jtot_object2_code,
      jtot_object3_code,
      dnz_chr_id,
      std_template_yn,
      warn_yn,
      priority,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      rule_information_category,
      rule_information1,
      rule_information2,
      rule_information3,
      rule_information4,
      rule_information5,
      rule_information6,
      rule_information7,
      rule_information8,
      rule_information9,
      rule_information10,
      rule_information11,
      rule_information12,
      rule_information13,
      rule_information14,
      rule_information15,
      template_yn,
      ans_set_jtot_object_code,
      ans_set_jtot_object_id1,
      ans_set_jtot_object_id2,
      display_sequence,
--Bug 3055393
      comments
  FROM okc_rules_bh
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;





RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN


       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END restore_version;


PROCEDURE populate_global_tab
(
    p_rulv_rec                     IN    rulv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
)
IS

CURSOR csr_tmp (p_context_code IN VARCHAR2) is
SELECT 'Y'
FROM   okc_ddf_contextcode_tmp
WHERE  descriptive_flex_context_code = p_context_code;

l_found       VARCHAR2(10) := 'N';
l_app_col_name VARCHAR2(30) := 'RULE_INFORMATION%';
-- l_desc_ff_name VARCHAR2(30) := 'OKC Rule Developer DF';        -- /striping/

BEGIN

    -- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
OPEN  csr_tmp(p_rulv_rec.rule_information_category);
FETCH csr_tmp into l_found;
CLOSE csr_tmp;
IF l_found = 'Y' THEN
   RETURN;
END IF;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rulv_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(p_rulv_rec.rule_information_category);

   INSERT INTO okc_ddf_contextcode_tmp
   (descriptive_flex_context_code, end_user_column_name, flex_value_set_id,
   required_flag, application_column_name, seq_no, form_left_prompt)
   SELECT
      descriptive_flex_context_code,
      end_user_column_name,
      flex_value_set_id,
      required_flag,
      application_column_name,
      SUBSTR(application_column_name,17,2) seq_no,
      form_left_prompt
   FROM fnd_descr_flex_col_usage_vl dfcu
--   WHERE dfcu.descriptive_flexfield_name = l_desc_ff_name    -- /striping/
   WHERE dfcu.descriptive_flexfield_name = p_dff_name
      AND application_column_name like l_app_col_name
--      AND dfcu.application_id =510                           -- /striping/
      AND dfcu.application_id = p_appl_id
      AND dfcu.descriptive_flex_context_code IN
        (
           SELECT /*+ NO_UNNEST */ rdf_code
             FROM OKC_K_HEADERS_B K ,
                  okc_subclass_rg_defs  B,
			   okc_rg_def_rules  A
            WHERE A.rgd_code = B.rgd_code
              AND B.scs_code = K.scs_code
              AND k.id = p_rulv_rec.dnz_chr_id
        )
      AND NOT EXISTS
	      (SELECT 1 FROM okc_ddf_contextcode_tmp
		   WHERE descriptive_flex_context_code =
				   dfcu.descriptive_flex_context_code
          AND  application_column_name       =
               dfcu.application_column_name);

EXCEPTION
 WHEN OTHERS THEN
    -- store SQL error message on message stack
       OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                           p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                           p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);
    -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END populate_global_tab;


PROCEDURE populate_obj_global_tab
(
    p_rulv_rec                     IN    rulv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
)
IS

CURSOR csr_tmp (p_context_code IN VARCHAR2) is
SELECT 'Y'
FROM   okc_obj_ddf_ctxcode_tmp
WHERE  descriptive_flex_context_code = p_context_code;

l_found       VARCHAR2(10) := 'N';

--
-- Bug 2197451: following variables are defined and used
--              to resolve performance issue - jkodiyan
--
l_app_col_name VARCHAR2(30) := 'JTOT_OBJECT%_CODE';
-- l_desc_ff_name VARCHAR2(30) := 'OKC Rule Developer DF';     -- /striping/

BEGIN

    -- initialize return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

OPEN  csr_tmp(p_rulv_rec.rule_information_category);
FETCH csr_tmp into l_found;
CLOSE csr_tmp;
IF l_found = 'Y' THEN
   RETURN;
END IF;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rulv_rec.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(p_rulv_rec.rule_information_category);

   INSERT INTO okc_obj_ddf_ctxcode_tmp
      (descriptive_flex_context_code, dummy_col, seq_no, form_left_prompt)
   SELECT
      descriptive_flex_context_code ,
      'x',
      SUBSTR(application_column_name,12,1) seq_no ,
      form_left_prompt
   FROM fnd_descr_flex_col_usage_vl dfcu
--   WHERE dfcu.descriptive_flexfield_name = l_desc_ff_name    -- /striping/
   WHERE dfcu.descriptive_flexfield_name = p_dff_name
     AND application_column_name like l_app_col_name
--     AND dfcu.application_id =510                            -- /striping/
     AND dfcu.application_id = p_appl_id
     AND dfcu.descriptive_flex_context_code IN
       (
           SELECT /*+ NO_UNNEST */ rdf_code
             FROM OKC_K_HEADERS_B K ,
                  okc_subclass_rg_defs  B,
			   okc_rg_def_rules  A
            WHERE A.rgd_code = B.rgd_code
              AND B.scs_code = K.scs_code
              AND k.id = p_rulv_rec.dnz_chr_id
        )
      AND NOT EXISTS
	      (SELECT 1 FROM okc_obj_ddf_ctxcode_tmp
		   WHERE descriptive_flex_context_code =
				   dfcu.descriptive_flex_context_code
           AND seq_no = SUBSTR(application_column_name,12,1));

EXCEPTION
 WHEN OTHERS THEN
    -- store SQL error message on message stack
       OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                           p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                           p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);
    -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END populate_obj_global_tab;

END OKC_RUL_PVT;

/
