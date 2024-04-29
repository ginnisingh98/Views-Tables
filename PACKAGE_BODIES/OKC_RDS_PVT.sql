--------------------------------------------------------
--  DDL for Package Body OKC_RDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RDS_PVT" AS
/* $Header: OKCSRDSB.pls 120.0 2005/05/25 22:44:36 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HARD-CODED  **************************/
-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

--  G_DESCRIPTIVE_FLEXFIELD_NAME CONSTANT VARCHAR2(200) := 'OKC Rule Developer DF';    -- /striping/

  FUNCTION Validate_Attributes
    (p_rdsv_rec IN  rdsv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200)  := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200)  := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_END_DATE    CONSTANT VARCHAR2(200) := 'OKC_INVALID_END_DATE';
  G_TOO_MANY_SOURCES		CONSTANT VARCHAR2(200) := 'OKC_TOO_MANY_SOURCES';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_INVALID_RULE_SOURCE         CONSTANT VARCHAR2(200) := 'OKC_INVALID_RULE_SOURCE';
  G_VIEW                        CONSTANT VARCHAR2(200) := 'OKC_RULE_DEF_SOURCES_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  g_row_id ROWID;

  -- Start of comments
  --
  -- Procedure Name  : validate_rgr_codes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rgr_codes(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rgdv_csr IS
      SELECT 'x'
        FROM OKC_RG_DEF_RULES rgrv
       WHERE rgrv.rgd_code = p_rdsv_rec.rgr_rgd_code
         AND rgrv.rdf_code = p_rdsv_rec.rgr_rdf_code;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rdsv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR OR
        p_rdsv_rec.rgr_rdf_code IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgr_rgd_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- data is required
    IF (p_rdsv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR OR
        p_rdsv_rec.rgr_rdf_code IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgr_rdf_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_rgdv_csr;
    FETCH l_rgdv_csr INTO l_dummy_var;
    CLOSE l_rgdv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
       --set error message in message stack
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rgr_rgd_code/rgr_rdf_code');

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
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rgdv_csr%ISOPEN THEN
      CLOSE l_rgdv_csr;
    END IF;
  END validate_rgr_codes;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_buy_or_sell
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_buy_or_sell(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rdsv_rec.buy_or_sell = OKC_API.G_MISS_CHAR OR
        p_rdsv_rec.buy_or_sell IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'buy_or_sell');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check allowed values
    IF (UPPER(p_rdsv_rec.buy_or_sell) NOT IN ('B','S')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'buy_or_sell');
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
  END validate_buy_or_sell;
--
--
  -- Start of comments
  --
  -- Procedure Name  : validate_access_level
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_access_level(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS

    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rgdv_csr IS
      SELECT 'x'
        FROM FND_LOOKUP_VALUES rgdv
       WHERE rgdv.LOOKUP_CODE = p_rdsv_rec.access_level
         AND rgdv.lookup_type = 'OKC_SEED_ACCESS_LEVEL_SU';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data
    IF (p_rdsv_rec.access_level <> OKC_API.G_MISS_CHAR OR
        p_rdsv_rec.access_level IS NOT NULL) THEN

    -- enforce foreign key
    OPEN  l_rgdv_csr;
    FETCH l_rgdv_csr INTO l_dummy_var;
    CLOSE l_rgdv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
       --set error message in message stack
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_VALUE,
          p_token1       => G_COL_NAME_TOKEN,
          p_token1_value => 'access_level');

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
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
  END validate_access_level;
--

  -- Start of comments
  --
  -- Procedure Name  : validate_start_date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_start_date(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rdsv_rec.start_date = OKC_API.G_MISS_DATE OR
        p_rdsv_rec.start_date IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'start_date');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
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
  END validate_start_date;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_end_date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_end_date(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_rdsv_rec.end_date <> OKC_API.G_MISS_DATE OR
        p_rdsv_rec.end_date IS NOT NULL) THEN
      IF (p_rdsv_rec.end_date < p_rdsv_rec.start_date) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_END_DATE);

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
  END validate_end_date;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_jtot_object_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_jtot_object_code(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_jtot_csr IS
      SELECT 'x'
        FROM 	jtf_objects_vl J, jtf_object_usages U
where
	J.OBJECT_CODE = p_rdsv_rec.JTOT_OBJECT_CODE
	and sysdate between NVL(J.START_DATE_ACTIVE,sysdate)
		and NVL(J.END_DATE_ACTIVE,sysdate)
	and U.OBJECT_code = p_rdsv_rec.JTOT_OBJECT_CODE
	and U.object_user_code='OKX_RULES';
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rdsv_rec.jtot_object_code = OKC_API.G_MISS_CHAR OR
        p_rdsv_rec.jtot_object_code IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'jtot_object_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_jtot_csr;
    FETCH l_jtot_csr INTO l_dummy_var;
    CLOSE l_jtot_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
       --set error message in message stack
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'jtot_object_code');

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
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_jtot_csr%ISOPEN THEN
      CLOSE l_jtot_csr;
    END IF;
  END validate_jtot_object_code;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_object_id_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_object_id_number(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
/* /striping/
    CURSOR l_rul_csr IS
      SELECT fnd.MEANING
        FROM FND_LOOKUPS fnd
       WHERE fnd.LOOKUP_CODE = p_rdsv_rec.rgr_rdf_code
         AND fnd.LOOKUP_TYPE = 'OKC_RULE_DEF';
*/
    CURSOR l_rul_csr IS
      SELECT MEANING
        FROM okc_rule_defs_v
       WHERE RULE_CODE = p_rdsv_rec.rgr_rdf_code;

    l_rule_name okc_rule_defs_v.MEANING%TYPE;

--    CURSOR l_dfcu_csr IS       -- /striping/
    CURSOR l_dfcu_csr(appl_id number, dff_name varchar2) IS
      SELECT 'x'
        FROM FND_DESCR_FLEX_COL_USAGE_VL dfcu
--       WHERE dfcu.application_id = 510 			-- Application id for OKC     -- /striping/
       WHERE dfcu.application_id = appl_id 			-- Application id for OKC
	    AND dfcu.descriptive_flexfield_name = dff_name
--             G_DESCRIPTIVE_FLEXFIELD_NAME  -- /striping/
         AND dfcu.descriptive_flex_context_code = p_rdsv_rec.rgr_rdf_code
         AND dfcu.application_column_name       =
             'JTOT_OBJECT'||LTRIM(p_rdsv_rec.object_id_number)||'_CODE' ;
    l_dummy VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_rdsv_rec.object_id_number = OKC_API.G_MISS_NUM OR
        p_rdsv_rec.object_id_number IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'object_id_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check allowed values
    IF (UPPER(p_rdsv_rec.object_id_number) NOT IN (1, 2, 3)) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'object_id_number');
       -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rdsv_rec.rgr_rdf_code);
p_dff_name := okc_rld_pvt.get_dff_name(p_rdsv_rec.rgr_rdf_code);

    -- Check that the rule supports an integration foreign key
    -- for the rule type and object number
    OPEN  l_dfcu_csr(p_appl_id, p_dff_name);
    FETCH l_dfcu_csr INTO l_dummy;
    CLOSE l_dfcu_csr;

    IF (l_dummy = '?') THEN
      -- get rule name
      OPEN  l_rul_csr;
      FETCH l_rul_csr INTO l_rule_name;
      CLOSE l_rul_csr;

      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_RULE_SOURCE,
        p_token1       => 'RULE',
        p_token1_value => l_rule_name,
        p_token2       => 'OBJECT_NUMBER',
        p_token2_value => p_rdsv_rec.object_id_number);

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
    IF l_dfcu_csr%ISOPEN THEN
      CLOSE l_dfcu_csr;
    END IF;
    IF l_rul_csr%ISOPEN THEN
      CLOSE l_rul_csr;
    END IF;
  END validate_object_id_number;
--
  -- Start of comments
  --
  -- Procedure Name  : check unique
  -- Description     : Check that a record is unique and not already active.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_unique(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy NUMBER;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


    SELECT COUNT(1)
      INTO l_dummy
      FROM OKC_RULE_DEF_SOURCES RDS
     WHERE BUY_OR_SELL      = p_rdsv_rec.buy_or_sell
       AND RGR_RGD_CODE     = p_rdsv_rec.rgr_rgd_code
       AND RGR_RDF_CODE     = p_rdsv_rec.rgr_rdf_code
       AND OBJECT_ID_NUMBER = p_rdsv_rec.object_id_number
       AND (
            (TRUNC(NVL(p_rdsv_rec.end_date, TRUNC(START_DATE))) >= TRUNC(START_DATE) AND
             TRUNC(p_rdsv_rec.start_date) < TRUNC(START_DATE))
            OR
             (TRUNC(p_rdsv_rec.start_date) >= TRUNC(START_DATE) AND
              TRUNC(p_rdsv_rec.start_date) <=
              TRUNC(NVL(END_DATE, TRUNC(p_rdsv_rec.start_date))))
           )
       AND ((p_rdsv_rec.row_id IS NULL) OR (ROWID <> p_rdsv_rec.row_id));

    IF (l_dummy >= 1) then
       --set error message in message stack
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     =>   G_TOO_MANY_SOURCES,
        p_token1       => 'SOURCE',
        p_token1_value => 'Rule Type Source',
        p_token2       => 'DATE',
        p_token2_value => p_rdsv_rec.start_date);

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END check_unique;
--


  -- Start of comments
  --
  -- Procedure Name  : validate_uniqueness
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

/* -- -------------------------------------------------------
	 COMMENTED VALIDATE_UNIQUENESS AS THE ABOVE CHECK_UNIQUE
	 PROCEDURE DOES THE SIMILAR FUNCTION. -shyam, 05-MAR-01
   -- -------------------------------------------------------

      <------------ BEGIN COMMENTED SEGMENT  --------------->

  PROCEDURE validate_uniqueness(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_rdsv_rec      IN    rdsv_rec_type
  ) IS

   -- ------------------------------------------------------
   -- To check for any matching row, for unique combination.
   -- ------------------------------------------------------
	 CURSOR cur_rds IS
	 SELECT 'x'
	 FROM   okc_rule_def_sources
	 WHERE  rgr_rdf_code      = p_rdsv_rec.RGR_RDF_CODE
	 AND    rgr_rgd_code      = p_rdsv_rec.RGR_RGD_CODE
	 AND    buy_or_sell       = p_rdsv_rec.BUY_OR_SELL
	 AND    TRUNC(start_date) = TO_CHAR(TRUNC(p_rdsv_rec.start_date),'DD-MON-YYYY')
	 AND    object_id_number  = p_rdsv_rec.OBJECT_ID_NUMBER;

  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_row_found       BOOLEAN     := FALSE;
  l_dummy           VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call is replaced with
    -- the explicit cursors above, for identical function to check
    -- uniqueness for RGR_RDF_CODE + RGR_RGD_CODE + BUY_OR_SELL
    --                START_DATE   + OBJECT_ID_NUMBER
    --                in OKC_RULE_DEF_SOURCES_V
    -- ---------------------------------------------------------------------
    IF (        (p_rdsv_rec.RGR_RDF_CODE IS NOT NULL)
            AND (p_rdsv_rec.RGR_RDF_CODE <> OKC_API.G_MISS_CHAR)   )
	   AND
	     (     (p_rdsv_rec.RGR_RGD_CODE IS NOT NULL)
		  AND (p_rdsv_rec.RGR_RGD_CODE <> OKC_API.G_MISS_CHAR) )
	   AND
	     (     (p_rdsv_rec.BUY_OR_SELL IS NOT NULL)
		  AND (p_rdsv_rec.BUY_OR_SELL <> OKC_API.G_MISS_CHAR) )
	   AND
	     (     (p_rdsv_rec.START_DATE IS NOT NULL)
		  AND (p_rdsv_rec.START_DATE <> OKC_API.G_MISS_DATE) )
	   AND
	     (     (p_rdsv_rec.OBJECT_ID_NUMBER IS NOT NULL)
		  AND (p_rdsv_rec.OBJECT_ID_NUMBER <> OKC_API.G_MISS_NUM) )
    THEN
         OPEN  cur_rds;
	    FETCH cur_rds INTO l_dummy;
	    l_row_found := cur_rds%FOUND;
	    CLOSE cur_rds;

         IF (l_row_found)
	    THEN
		   -- Display the newly defined error message
		   OKC_API.set_message(G_APP_NAME,
		                       'OKC_DUP_RULE_DEF_SOURCE');

             -- If not unique, set error flag
             x_return_status := OKC_API.G_RET_STS_ERROR;
	    END IF;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
       -- store SQL error message on message stack
       OKC_API.SET_MESSAGE( p_app_name        => G_APP_NAME,
                            p_msg_name        => G_UNEXPECTED_ERROR,
                            p_token1	        => G_SQLCODE_TOKEN,
                            p_token1_value    => SQLCODE,
                            p_token2          => G_SQLERRM_TOKEN,
                            p_token2_value    => SQLERRM);

       -- notify caller of an error as UNEXPETED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_uniqueness;

      <------------ END COMMENTED SEGMENT  --------------->
*/

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
    p_rdsv_rec IN  rdsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_rgr_codes(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_buy_or_sell(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_access_level(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--

    validate_start_date(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_end_date(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_jtot_object_code(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_object_id_number(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    check_unique(
      x_return_status => l_return_status,
      p_rdsv_rec      => p_rdsv_rec);

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

/***********************  END HAND-CODED  **************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_DEF_SOURCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rds_rec                      IN rds_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rds_rec_type IS
    CURSOR rds_pk_csr (p_buy_or_sell        IN VARCHAR2,
                       p_rgr_rgd_code       IN VARCHAR2,
                       p_rgr_rdf_code       IN VARCHAR2,
                       p_start_date         IN DATE,
                       p_object_id_number   IN NUMBER) IS
    SELECT
            RGR_RGD_CODE,
            RGR_RDF_CODE,
            BUY_OR_SELL,
            ACCESS_LEVEL,
            START_DATE,
            END_DATE,
            JTOT_OBJECT_CODE,
            OBJECT_ID_NUMBER,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Def_Sources
     WHERE okc_rule_def_sources.buy_or_sell = p_buy_or_sell
       AND okc_rule_def_sources.rgr_rgd_code = p_rgr_rgd_code
       AND okc_rule_def_sources.rgr_rdf_code = p_rgr_rdf_code
       AND okc_rule_def_sources.start_date = p_start_date
       AND okc_rule_def_sources.object_id_number = p_object_id_number;
    l_rds_pk                       rds_pk_csr%ROWTYPE;
    l_rds_rec                      rds_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rds_pk_csr (p_rds_rec.buy_or_sell,
                     p_rds_rec.rgr_rgd_code,
                     p_rds_rec.rgr_rdf_code,
                     p_rds_rec.start_date,
                     p_rds_rec.object_id_number);
    FETCH rds_pk_csr INTO
              l_rds_rec.RGR_RGD_CODE,
              l_rds_rec.RGR_RDF_CODE,
              l_rds_rec.BUY_OR_SELL,
              l_rds_rec.ACCESS_LEVEL,
              l_rds_rec.START_DATE,
              l_rds_rec.END_DATE,
              l_rds_rec.JTOT_OBJECT_CODE,
              l_rds_rec.OBJECT_ID_NUMBER,
              l_rds_rec.OBJECT_VERSION_NUMBER,
              l_rds_rec.CREATED_BY,
              l_rds_rec.CREATION_DATE,
              l_rds_rec.LAST_UPDATED_BY,
              l_rds_rec.LAST_UPDATE_DATE,
              l_rds_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := rds_pk_csr%NOTFOUND;
    CLOSE rds_pk_csr;
    RETURN(l_rds_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rds_rec                      IN rds_rec_type
  ) RETURN rds_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rds_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_DEF_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rdsv_rec                     IN rdsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rdsv_rec_type IS
    CURSOR okc_rdsv_pk_csr (p_rgr_rgd_code       IN VARCHAR2,
                            p_rgr_rdf_code       IN VARCHAR2,
                            p_buy_or_sell        IN VARCHAR2,
                            p_start_date         IN DATE,
                            p_object_id_number   IN NUMBER) IS
    SELECT
            JTOT_OBJECT_CODE,
            RGR_RGD_CODE,
            RGR_RDF_CODE,
            BUY_OR_SELL,
            ACCESS_LEVEL,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
            OBJECT_ID_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Def_Sources_V
     WHERE okc_rule_def_sources_v.rgr_rgd_code = p_rgr_rgd_code
       AND okc_rule_def_sources_v.rgr_rdf_code = p_rgr_rdf_code
       AND okc_rule_def_sources_v.buy_or_sell = p_buy_or_sell
       AND okc_rule_def_sources_v.object_id_number = p_object_id_number
       AND trunc(okc_rule_def_sources_v.start_date) = trunc(p_start_date);
    l_okc_rdsv_pk                  okc_rdsv_pk_csr%ROWTYPE;
    l_rdsv_rec                     rdsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rdsv_pk_csr (p_rdsv_rec.rgr_rgd_code,
                          p_rdsv_rec.rgr_rdf_code,
                          p_rdsv_rec.buy_or_sell,
                          p_rdsv_rec.start_date,
                          p_rdsv_rec.object_id_number);
    FETCH okc_rdsv_pk_csr INTO
              l_rdsv_rec.JTOT_OBJECT_CODE,
              l_rdsv_rec.RGR_RGD_CODE,
              l_rdsv_rec.RGR_RDF_CODE,
              l_rdsv_rec.BUY_OR_SELL,
              l_rdsv_rec.ACCESS_LEVEL,
              l_rdsv_rec.START_DATE,
              l_rdsv_rec.END_DATE,
              l_rdsv_rec.OBJECT_VERSION_NUMBER,
              l_rdsv_rec.OBJECT_ID_NUMBER,
              l_rdsv_rec.CREATED_BY,
              l_rdsv_rec.CREATION_DATE,
              l_rdsv_rec.LAST_UPDATED_BY,
              l_rdsv_rec.LAST_UPDATE_DATE,
              l_rdsv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_rdsv_pk_csr%NOTFOUND;
    CLOSE okc_rdsv_pk_csr;
    RETURN(l_rdsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rdsv_rec                     IN rdsv_rec_type
  ) RETURN rdsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rdsv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RULE_DEF_SOURCES_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rdsv_rec	IN rdsv_rec_type
  ) RETURN rdsv_rec_type IS
    l_rdsv_rec	rdsv_rec_type := p_rdsv_rec;
  BEGIN
    IF (l_rdsv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_rdsv_rec.jtot_object_code := NULL;
    END IF;
    IF (l_rdsv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR) THEN
      l_rdsv_rec.rgr_rgd_code := NULL;
    END IF;
    IF (l_rdsv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR) THEN
      l_rdsv_rec.rgr_rdf_code := NULL;
    END IF;
    IF (l_rdsv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_rdsv_rec.end_date := NULL;
    END IF;
    IF (l_rdsv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.object_version_number := NULL;
    END IF;
    IF (l_rdsv_rec.object_id_number = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.object_id_number := NULL;
    END IF;
    IF (l_rdsv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.created_by := NULL;
    END IF;
    IF (l_rdsv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rdsv_rec.creation_date := NULL;
    END IF;
    IF (l_rdsv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rdsv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rdsv_rec.last_update_date := NULL;
    END IF;
    IF (l_rdsv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_rdsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_RULE_DEF_SOURCES_V --
  ----------------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_rdsv_rec IN  rdsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rdsv_rec.jtot_object_code = OKC_API.G_MISS_CHAR OR
       p_rdsv_rec.jtot_object_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'jtot_object_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rdsv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR OR
          p_rdsv_rec.rgr_rgd_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgr_rgd_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rdsv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR OR
          p_rdsv_rec.rgr_rdf_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgr_rdf_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rdsv_rec.buy_or_sell = OKC_API.G_MISS_CHAR OR
          p_rdsv_rec.buy_or_sell IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'buy_or_sell');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rdsv_rec.start_date = OKC_API.G_MISS_DATE OR
          p_rdsv_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rdsv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_rdsv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rdsv_rec.object_id_number = OKC_API.G_MISS_NUM OR
          p_rdsv_rec.object_id_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_id_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKC_RULE_DEF_SOURCES_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_rdsv_rec IN rdsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rdsv_rec_type,
    p_to	IN OUT NOCOPY rds_rec_type
  ) IS
  BEGIN
    p_to.rgr_rgd_code := p_from.rgr_rgd_code;
    p_to.rgr_rdf_code := p_from.rgr_rdf_code;
    p_to.buy_or_sell := p_from.buy_or_sell;
    p_to.access_level := p_from.access_level;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.object_id_number := p_from.object_id_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rds_rec_type,
    p_to	IN OUT NOCOPY rdsv_rec_type
  ) IS
  BEGIN
    p_to.rgr_rgd_code := p_from.rgr_rgd_code;
    p_to.rgr_rdf_code := p_from.rgr_rdf_code;
    p_to.buy_or_sell := p_from.buy_or_sell;
    p_to.access_level := p_from.access_level;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.object_id_number := p_from.object_id_number;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKC_RULE_DEF_SOURCES_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
    l_rds_rec                      rds_rec_type;
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
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_rdsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rdsv_rec);
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
  -- PL/SQL TBL validate_row for:RDSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec                     => p_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKC_RULE_DEF_SOURCES --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type,
    x_rds_rec                      OUT NOCOPY rds_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type := p_rds_rec;
    l_def_rds_rec                  rds_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_RULE_DEF_SOURCES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_rds_rec IN  rds_rec_type,
      x_rds_rec OUT NOCOPY rds_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rds_rec := p_rds_rec;
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
      p_rds_rec,                         -- IN
      l_rds_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RULE_DEF_SOURCES(
        rgr_rgd_code,
        rgr_rdf_code,
        buy_or_sell,
        access_level,
        start_date,
        end_date,
        jtot_object_code,
        object_id_number,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_rds_rec.rgr_rgd_code,
        l_rds_rec.rgr_rdf_code,
        l_rds_rec.buy_or_sell,
        l_rds_rec.access_level,
        l_rds_rec.start_date,
        l_rds_rec.end_date,
        l_rds_rec.jtot_object_code,
        l_rds_rec.object_id_number,
        l_rds_rec.object_version_number,
        l_rds_rec.created_by,
        l_rds_rec.creation_date,
        l_rds_rec.last_updated_by,
        l_rds_rec.last_update_date,
        l_rds_rec.last_update_login);
    -- Set OUT values
    x_rds_rec := l_rds_rec;
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
  -------------------------------------------
  -- insert_row for:OKC_RULE_DEF_SOURCES_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type,
    x_rdsv_rec                     OUT NOCOPY rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec                     rdsv_rec_type;
    l_def_rdsv_rec                 rdsv_rec_type;
    l_rds_rec                      rds_rec_type;
    lx_rds_rec                     rds_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rdsv_rec	IN rdsv_rec_type
    ) RETURN rdsv_rec_type IS
      l_rdsv_rec	rdsv_rec_type := p_rdsv_rec;
    BEGIN
      l_rdsv_rec.CREATION_DATE := SYSDATE;
      l_rdsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rdsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rdsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rdsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rdsv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_RULE_DEF_SOURCES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_rdsv_rec IN  rdsv_rec_type,
      x_rdsv_rec OUT NOCOPY rdsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rdsv_rec := p_rdsv_rec;
      x_rdsv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_rdsv_rec := null_out_defaults(p_rdsv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rdsv_rec,                        -- IN
      l_def_rdsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rdsv_rec := fill_who_columns(l_def_rdsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rdsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rdsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rdsv_rec, l_rds_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec,
      lx_rds_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rds_rec, l_def_rdsv_rec);
    -- Set OUT values
    x_rdsv_rec := l_def_rdsv_rec;
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
  -- PL/SQL TBL insert_row for:RDSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type,
    x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec                     => p_rdsv_tbl(i),
          x_rdsv_rec                     => x_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKC_RULE_DEF_SOURCES --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rds_rec IN rds_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULE_DEF_SOURCES
     WHERE BUY_OR_SELL = p_rds_rec.buy_or_sell
       AND RGR_RGD_CODE = p_rds_rec.rgr_rgd_code
       AND RGR_RDF_CODE = p_rds_rec.rgr_rdf_code
       AND START_DATE = p_rds_rec.start_date
       AND OBJECT_ID_NUMBER = p_rds_rec.object_id_number
       AND OBJECT_VERSION_NUMBER = p_rds_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rds_rec IN rds_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULE_DEF_SOURCES
    WHERE BUY_OR_SELL = p_rds_rec.buy_or_sell
       AND RGR_RGD_CODE = p_rds_rec.rgr_rgd_code
       AND RGR_RDF_CODE = p_rds_rec.rgr_rdf_code
       AND OBJECT_ID_NUMBER = p_rds_rec.object_id_number
       AND START_DATE = p_rds_rec.start_date;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_RULE_DEF_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_RULE_DEF_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_rds_rec);
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
      OPEN lchk_csr(p_rds_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rds_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rds_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKC_RULE_DEF_SOURCES_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type;
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
    migrate(p_rdsv_rec, l_rds_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec
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
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:RDSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec                     => p_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKC_RULE_DEF_SOURCES --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type,
    x_rds_rec                      OUT NOCOPY rds_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type := p_rds_rec;
    l_def_rds_rec                  rds_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rds_rec	IN rds_rec_type,
      x_rds_rec	OUT NOCOPY rds_rec_type
    ) RETURN VARCHAR2 IS
      l_rds_rec                      rds_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rds_rec := p_rds_rec;
      -- Get current database values
      l_rds_rec := get_rec(p_rds_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rds_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rds_rec.rgr_rgd_code := l_rds_rec.rgr_rgd_code;
      END IF;
      IF (x_rds_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rds_rec.rgr_rdf_code := l_rds_rec.rgr_rdf_code;
      END IF;
      IF (x_rds_rec.buy_or_sell = OKC_API.G_MISS_CHAR)
      THEN
        x_rds_rec.buy_or_sell := l_rds_rec.buy_or_sell;
      END IF;
      IF (x_rds_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rds_rec.access_level := l_rds_rec.access_level;
      END IF;
      IF (x_rds_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_rds_rec.start_date := l_rds_rec.start_date;
      END IF;
      IF (x_rds_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_rds_rec.end_date := l_rds_rec.end_date;
      END IF;
      IF (x_rds_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rds_rec.jtot_object_code := l_rds_rec.jtot_object_code;
      END IF;
      IF (x_rds_rec.object_id_number = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.object_id_number := l_rds_rec.object_id_number;
      END IF;
      IF (x_rds_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.object_version_number := l_rds_rec.object_version_number;
      END IF;
      IF (x_rds_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.created_by := l_rds_rec.created_by;
      END IF;
      IF (x_rds_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rds_rec.creation_date := l_rds_rec.creation_date;
      END IF;
      IF (x_rds_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.last_updated_by := l_rds_rec.last_updated_by;
      END IF;
      IF (x_rds_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rds_rec.last_update_date := l_rds_rec.last_update_date;
      END IF;
      IF (x_rds_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.last_update_login := l_rds_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_RULE_DEF_SOURCES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_rds_rec IN  rds_rec_type,
      x_rds_rec OUT NOCOPY rds_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rds_rec := p_rds_rec;
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
      p_rds_rec,                         -- IN
      l_rds_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rds_rec, l_def_rds_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_RULE_DEF_SOURCES
    SET END_DATE = l_def_rds_rec.end_date,
        JTOT_OBJECT_CODE = l_def_rds_rec.jtot_object_code,
        OBJECT_VERSION_NUMBER = l_def_rds_rec.object_version_number,
        CREATED_BY = l_def_rds_rec.created_by,
        CREATION_DATE = l_def_rds_rec.creation_date,
        LAST_UPDATED_BY = l_def_rds_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rds_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rds_rec.last_update_login
    WHERE BUY_OR_SELL = l_def_rds_rec.buy_or_sell
    AND RGR_RGD_CODE = l_def_rds_rec.rgr_rgd_code
    AND RGR_RDF_CODE = l_def_rds_rec.rgr_rdf_code
    AND TRUNC(START_DATE) = TRUNC(l_def_rds_rec.start_date)
    AND OBJECT_ID_NUMBER = l_def_rds_rec.object_id_number;
    x_rds_rec := l_def_rds_rec;
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
  -------------------------------------------
  -- update_row for:OKC_RULE_DEF_SOURCES_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type,
    x_rdsv_rec                     OUT NOCOPY rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
    l_def_rdsv_rec                 rdsv_rec_type;
    l_rds_rec                      rds_rec_type;
    lx_rds_rec                     rds_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rdsv_rec	IN rdsv_rec_type
    ) RETURN rdsv_rec_type IS
      l_rdsv_rec	rdsv_rec_type := p_rdsv_rec;
    BEGIN
      l_rdsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rdsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rdsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rdsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rdsv_rec	IN rdsv_rec_type,
      x_rdsv_rec	OUT NOCOPY rdsv_rec_type
    ) RETURN VARCHAR2 IS
      l_rdsv_rec                     rdsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rdsv_rec := p_rdsv_rec;
      -- Get current database values
      l_rdsv_rec := get_rec(p_rdsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rdsv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rdsv_rec.jtot_object_code := l_rdsv_rec.jtot_object_code;
      END IF;
      IF (x_rdsv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rdsv_rec.rgr_rgd_code := l_rdsv_rec.rgr_rgd_code;
      END IF;
      IF (x_rdsv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rdsv_rec.rgr_rdf_code := l_rdsv_rec.rgr_rdf_code;
      END IF;
      IF (x_rdsv_rec.buy_or_sell = OKC_API.G_MISS_CHAR)
      THEN
        x_rdsv_rec.buy_or_sell := l_rdsv_rec.buy_or_sell;
      END IF;
      IF (x_rdsv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rdsv_rec.access_level := l_rdsv_rec.access_level;
      END IF;
      IF (x_rdsv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_rdsv_rec.start_date := l_rdsv_rec.start_date;
      END IF;
      IF (x_rdsv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_rdsv_rec.end_date := l_rdsv_rec.end_date;
      END IF;
      IF (x_rdsv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.object_version_number := l_rdsv_rec.object_version_number;
      END IF;
      IF (x_rdsv_rec.object_id_number = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.object_id_number := l_rdsv_rec.object_id_number;
      END IF;
      IF (x_rdsv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.created_by := l_rdsv_rec.created_by;
      END IF;
      IF (x_rdsv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rdsv_rec.creation_date := l_rdsv_rec.creation_date;
      END IF;
      IF (x_rdsv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.last_updated_by := l_rdsv_rec.last_updated_by;
      END IF;
      IF (x_rdsv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rdsv_rec.last_update_date := l_rdsv_rec.last_update_date;
      END IF;
      IF (x_rdsv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.last_update_login := l_rdsv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_RULE_DEF_SOURCES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_rdsv_rec IN  rdsv_rec_type,
      x_rdsv_rec OUT NOCOPY rdsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rdsv_rec := p_rdsv_rec;
      x_rdsv_rec.OBJECT_VERSION_NUMBER := NVL(x_rdsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rdsv_rec,                        -- IN
      l_rdsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rdsv_rec, l_def_rdsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rdsv_rec := fill_who_columns(l_def_rdsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rdsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rdsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rdsv_rec, l_rds_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec,
      lx_rds_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rds_rec, l_def_rdsv_rec);
    x_rdsv_rec := l_def_rdsv_rec;
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
  -- PL/SQL TBL update_row for:RDSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type,
    x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec                     => p_rdsv_tbl(i),
          x_rdsv_rec                     => x_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKC_RULE_DEF_SOURCES --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type:= p_rds_rec;
    l_row_notfound                 BOOLEAN := TRUE;
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
    DELETE FROM OKC_RULE_DEF_SOURCES
     WHERE BUY_OR_SELL = l_rds_rec.buy_or_sell
       AND RGR_RGD_CODE = l_rds_rec.rgr_rgd_code
       AND RGR_RDF_CODE = l_rds_rec.rgr_rdf_code
       AND TRUNC(START_DATE) = TRUNC(l_rds_rec.start_date)
       AND OBJECT_ID_NUMBER = l_rds_rec.object_id_number;

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
  -------------------------------------------
  -- delete_row for:OKC_RULE_DEF_SOURCES_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec                     rdsv_rec_type := p_rdsv_rec;
    l_rds_rec                      rds_rec_type;
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
    migrate(l_rdsv_rec, l_rds_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec
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
  -- PL/SQL TBL delete_row for:RDSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec                     => p_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
END OKC_RDS_PVT;

/
