--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOVERULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOVERULES_PVT" AS
/* $Header: OKLRSODB.pls 115.9 2003/07/23 18:32:50 sgorantl noship $ */
G_ITEM_NOT_FOUND_ERROR EXCEPTION;
G_COLUMN_TOKEN			  CONSTANT VARCHAR2(100) := 'COLUMN';
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OPV_RULES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_ovdv_rec                     IN ovdv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ovdv_rec					   OUT NOCOPY ovdv_rec_type
  ) IS
    CURSOR okl_ovdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			ORL_ID,
            OVE_ID,
            COPY_OR_ENTER_FLAG,
            CONTEXT_INTENT,
            CONTEXT_ORG,
            CONTEXT_INV_ORG,
            CONTEXT_ASSET_BOOK,
			NVL(INDIVIDUAL_INSTRUCTIONS,Okl_Api.G_MISS_CHAR) INDIVIDUAL_INSTRUCTIONS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Opv_Rules_V
     WHERE Okl_Opv_Rules_V.id    = p_id;
    l_okl_ovdv_pk                  okl_ovdv_pk_csr%ROWTYPE;
    l_ovdv_rec                     ovdv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_ovdv_pk_csr (p_ovdv_rec.id);
    FETCH okl_ovdv_pk_csr INTO
              l_ovdv_rec.ID,
              l_ovdv_rec.OBJECT_VERSION_NUMBER,
			  l_ovdv_rec.ORL_ID,
              l_ovdv_rec.OVE_ID,
              l_ovdv_rec.COPY_OR_ENTER_FLAG,
              l_ovdv_rec.CONTEXT_INTENT,
              l_ovdv_rec.CONTEXT_ORG,
              l_ovdv_rec.CONTEXT_INV_ORG,
              l_ovdv_rec.CONTEXT_ASSET_BOOK,
              l_ovdv_rec.INDIVIDUAL_INSTRUCTIONS,
              l_ovdv_rec.CREATED_BY,
              l_ovdv_rec.CREATION_DATE,
              l_ovdv_rec.LAST_UPDATED_BY,
              l_ovdv_rec.LAST_UPDATE_DATE,
              l_ovdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ovdv_pk_csr%NOTFOUND;
    CLOSE okl_ovdv_pk_csr;
    x_ovdv_rec := l_ovdv_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_ovdv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovdv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_OPV_RULES_V
  -- To verify whether an addition of new option value rule is ok with rest
  -- of the product - contract relationships
  ---------------------------------------------------------------------------
  PROCEDURE Check_Constraints (
	p_ovdv_rec		IN ovdv_rec_type,
	x_return_status	OUT NOCOPY VARCHAR2,
    x_valid         OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_ovd_orl_fk_csr (p_ove_id   IN Okl_Opt_Values_V.ID%TYPE,
                               p_orl_id   IN Okl_Opt_Rules_V.id%TYPE
	) IS
	SELECT '1'
    FROM Okl_Opt_Values_V ove,
         Okl_Opt_Rules_V orl,
         Okl_Lse_Scs_Rules_V lsr
    WHERE orl.ID     = p_orl_id
    AND   ove.ID     = p_ove_id
    AND ((orl.LRG_LSE_ID IS NOT NULL
         AND lsr.LSE_ID = orl.LRG_LSE_ID
         AND lsr.SRD_ID = orl.LRG_SRD_ID)
         OR
         (orl.LRG_LSE_ID IS NULL
         AND lsr.LSE_ID IS NULL
         AND lsr.SRD_ID = orl.SRD_ID_FOR))
    AND lsr.RULE_GROUP = orl.RGR_RGD_CODE
    AND lsr.RULE = orl.RGR_RDF_CODE
    AND (lsr.START_DATE > ove.FROM_DATE OR
	     NVL(lsr.END_DATE, NVL(ove.TO_DATE, Okl_Api.G_MISS_DATE)) < NVL(ove.TO_DATE, Okl_Api.G_MISS_DATE));

    CURSOR okl_ovd_csp_fk_csr (p_ove_id    IN Okl_Opt_Values_V.ID%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pdt_Opt_Vals_V pov,
         Okl_Slctd_Optns_V csp
    WHERE pov.OVE_ID    = p_ove_id
    AND   csp.POV_ID    = pov.ID;

    CURSOR okl_ovd_ove_fk_csr (p_ove_id    IN Okl_Products_V.ID%TYPE,
                              p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_opt_values_V ove
    WHERE ove.ID    = p_ove_id
    AND   NVL(ove.TO_DATE, p_date) < p_date;


    CURSOR okl_ovd_ovt_fk_csr (p_ovd_id    IN Okl_Opv_Rules_V.ID%TYPE
	) IS
    SELECT '1'
    FROM Okl_Ovd_Rul_Tmls_V ovt
    WHERE ovt.OVD_ID    = p_ovd_id;

    CURSOR c1(p_orl_id okl_opv_rules_v.orl_id%TYPE,
		    p_ove_id okl_opv_rules_v.ove_id%TYPE,
            p_context_intent okl_opv_rules_v.context_intent%TYPE,
            p_context_org okl_opv_rules_v.context_org%TYPE,
            p_context_inv_org okl_opv_rules_v.context_inv_org%TYPE,
            p_context_asset_book okl_opv_rules_v.context_asset_book%TYPE) IS
    SELECT '1'
    FROM okl_opv_rules_v
    WHERE  orl_id = p_orl_id
    AND    ove_id = p_ove_id
    AND    context_intent = p_context_intent
    AND    (context_org IS NULL OR context_org = p_context_org)
    AND    (context_inv_org IS NULL OR context_inv_org = p_context_inv_org)
    AND    (context_asset_book IS NULL OR context_asset_book = p_context_asset_book);

    l_ovd_status            VARCHAR2(1);
    l_context_org           NUMBER;
    l_context_inv_org       NUMBER;
    l_context_asset_book    VARCHAR2(100) := NULL;
    l_row_found             BOOLEAN := FALSE;
    l_token_1               VARCHAR2(1999);
    l_token_2               VARCHAR2(1999);
    l_token_3               VARCHAR2(1999);
    l_token_4               VARCHAR2(1999);
    l_check		   	VARCHAR2(1) := '?';
    l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_row_not_found	BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

     l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPT_VAL_RULE_SUMRY',
                                                           p_attribute_code => 'OKL_OPTION_VALUE_RULES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTV_RUL_TML_SUMRY',
                                                           p_attribute_code => 'OKL_LP_OPT_VAL_RUL_TML');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPT_VAL_RULE_SUMRY',
                                                           p_attribute_code => 'OKL_RULE');

    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_RULE_CR_UPD',
                                                           p_attribute_code => 'OKL_RULE');


    -- Check if the option value is already in use with a contract
    OPEN okl_ovd_csp_fk_csr (p_ovdv_rec.ove_id);
    FETCH okl_ovd_csp_fk_csr INTO l_check;
    l_row_not_found := okl_ovd_csp_fk_csr%NOTFOUND;
    CLOSE okl_ovd_csp_fk_csr;

    IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_IN_USE,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => 'Okl_Slctd_Optns_V');
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    -- Check for related rule templates
    -- Only delete scenario
    IF p_ovdv_rec.id <> Okl_Api.G_MISS_NUM THEN
       OPEN okl_ovd_ovt_fk_csr (p_ovdv_rec.id);
       FETCH okl_ovd_ovt_fk_csr INTO l_check;
       l_row_not_found := okl_ovd_ovt_fk_csr%NOTFOUND;
       CLOSE okl_ovd_ovt_fk_csr;

       IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_IN_USE,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_2);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
    END IF;

  -- check uniqueness
  IF p_ovdv_rec.id = Okl_Api.G_MISS_NUM THEN
    IF p_ovdv_rec.context_org = Okl_Api.G_MISS_NUM THEN
       l_context_org  := NULL;
    ELSE
       l_context_org := p_ovdv_rec.context_org;
    END IF;
    IF p_ovdv_rec.context_inv_org = Okl_Api.G_MISS_NUM THEN
       l_context_inv_org  := NULL;
    ELSE
       l_context_inv_org := p_ovdv_rec.context_inv_org;
    END IF;
    IF p_ovdv_rec.context_asset_book = Okl_Api.G_MISS_CHAR THEN
       l_context_asset_book  := NULL;
    ELSE
       l_context_asset_book := p_ovdv_rec.context_asset_book;
    END IF;

  IF p_ovdv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN c1(p_ovdv_rec.orl_id,
	    p_ovdv_rec.ove_id,
            p_ovdv_rec.context_intent,
            l_context_org,
            l_context_inv_org,
            l_context_asset_book);
    FETCH c1 INTO l_ovd_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
	 ---Okl_Api.set_message('OKL','OKL_COLUMN_NOT_UNIQUE', 'OKL_TABLE_NAME',l_token_1,Okl_Ovd_Pvt.G_COL_NAME_TOKEN,l_token_3);
        Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
				     p_msg_name	    => 'OKL_COLUMN_NOT_UNIQUE',
				     p_token1	    => G_TABLE_TOKEN,
				     p_token1_value => l_token_1,
				     p_token2	    => G_COLUMN_TOKEN,
				     p_token2_value => l_token_3);

		x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
     END IF;
   END IF;
  END IF;
   /* -- Check if the option value to which the option rules are attached is not
    -- in the past
    OPEN okl_ovd_ove_fk_csr (p_ovdv_rec.ove_id,
                             l_sysdate);
    FETCH okl_ovd_ove_fk_csr INTO l_check;
    l_row_not_found := okl_ovd_ove_fk_csr%NOTFOUND;
    CLOSE okl_ovd_ove_fk_csr;

    IF l_row_not_found = FALSE THEN
	   OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_PAST_RECORDS);
	   x_valid := FALSE;
       x_return_status := OKL_API.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    -- Check for related rules and contracts
    -- Only Insert scenario
    IF p_ovdv_rec.id = OKL_API.G_MISS_NUM THEN
       OPEN okl_ovd_orl_fk_csr (p_ovdv_rec.ove_id,
                                p_ovdv_rec.orl_id);
       FETCH okl_ovd_orl_fk_csr INTO l_check;
       l_row_not_found := okl_ovd_orl_fk_csr%NOTFOUND;
       CLOSE okl_ovd_orl_fk_csr;

       IF l_row_not_found = FALSE THEN
	      OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_DATES_MISMATCH,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => 'Okl_Opv_Rules_V',
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => 'Okl_Lse_Scs_Rules_V');
	      x_valid := FALSE;
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
    END IF;
    */
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_valid := FALSE;
	   x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF (okl_ovd_ovt_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovd_ovt_fk_csr;
       END IF;

       /*IF (okl_ovd_orl_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovd_orl_fk_csr;
       END IF;*/

       IF (okl_ovd_csp_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovd_csp_fk_csr;
       END IF;

      /* IF (okl_ovd_ove_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovd_ove_fk_csr;
       END IF;*/

       IF (C1%ISOPEN) THEN
	   	  CLOSE C1;
       END IF;

  END Check_Constraints;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Orl_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Orl_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Orl_Id(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_orlv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_opt_rules_v
       WHERE okl_opt_rules_v.id = p_id;

      l_orl_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_token_1               VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTVAL_RULE_CR_UPD','OKL_RULE');

    -- check for data before processing
    IF (p_ovdv_rec.orl_id IS NULL) OR
       (p_ovdv_rec.orl_id = Okl_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Ovd_Pvt.g_app_name
                          ,p_msg_name       => Okl_Ovd_Pvt.g_required_value
                          ,p_token1         => Okl_Ovd_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF (p_ovdv_rec.ORL_ID IS NOT NULL)
      THEN
        OPEN okl_orlv_pk_csr(p_ovdv_rec.ORL_ID);
        FETCH okl_orlv_pk_csr INTO l_orl_status;
        l_row_notfound := okl_orlv_pk_csr%NOTFOUND;
        CLOSE okl_orlv_pk_csr;
        IF (l_row_notfound) THEN
          Okl_Api.set_message(Okl_Ovd_Pvt.G_APP_NAME, Okl_Ovd_Pvt.G_INVALID_VALUE,Okl_Ovd_Pvt.G_COL_NAME_TOKEN,l_token_1);
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Ovd_Pvt.g_app_name,
                          p_msg_name     => Okl_Ovd_Pvt.g_unexpected_error,
                          p_token1       => Okl_Ovd_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Ovd_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Orl_Id;

 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Copy_Or_Enter_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Copy_Or_Enter_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Copy_Or_Enter_Flag(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1               VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTVAL_RULE_CR_UPD','OKL_ACTION');
    -- check for data before processing
    l_return_status := Okl_Accounting_Util.validate_lookup_code(Okl_Ovd_Pvt.G_LOOKUP_TYPE,p_ovdv_rec.copy_or_enter_flag);

      IF l_return_status = Okl_Api.G_FALSE THEN
         l_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;



    IF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Ovd_Pvt.g_app_name
                          ,p_msg_name       => Okl_Ovd_Pvt.g_required_value
                          ,p_token1         => Okl_Ovd_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Ovd_Pvt.g_app_name,
                          p_msg_name     => Okl_Ovd_Pvt.g_unexpected_error,
                          p_token1       => Okl_Ovd_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Ovd_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Copy_Or_Enter_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Context_Intent
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Context_Intent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Context_Intent(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1               VARCHAR2(999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTVAL_RULE_CR_UPD','OKL_INTENT');
    -- check for data before processing
    l_return_status := Okl_Accounting_Util.validate_lookup_code(Okl_Ovd_Pvt.G_INTENT_TYPE,p_ovdv_rec.context_intent);
     IF l_return_status = Okl_Api.G_FALSE THEN
         l_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;


    IF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Ovd_Pvt.g_app_name
                          ,p_msg_name       => Okl_Ovd_Pvt.g_required_value
                          ,p_token1         => Okl_Ovd_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Ovd_Pvt.g_app_name,
                          p_msg_name     => Okl_Ovd_Pvt.g_unexpected_error,
                          p_token1       => Okl_Ovd_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Ovd_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Context_Intent;

 ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_ovdv_rec IN  ovdv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Orl_Id
    Validate_Orl_Id(p_ovdv_rec,x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Copy_Or_Enter_Flag
    Validate_Copy_Or_Enter_Flag(p_ovdv_rec,x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Context_Intent
    Validate_Context_Intent(p_ovdv_rec,x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

  RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okl_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE insert_overules for: OKL_OPV_RULES_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_overules(p_api_version    IN  NUMBER,
                        	p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status  OUT NOCOPY VARCHAR2,
                        	x_msg_count      OUT NOCOPY NUMBER,
                        	x_msg_data       OUT NOCOPY VARCHAR2,
                            p_optv_rec       IN  optv_rec_type,
                        	p_ovev_rec       IN  ovev_rec_type,
                            p_ovdv_rec       IN  ovdv_rec_type,
                        	x_ovdv_rec       OUT NOCOPY ovdv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_overules';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_ovdv_rec		  ovdv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_ovdv_rec := p_ovdv_rec;


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ovdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* call check_constraints to check the validity of this relationship */
	Check_Constraints(p_ovdv_rec 		=> l_ovdv_rec,
				   	  x_return_status	=> l_return_status,
				   	  x_valid			=> l_valid);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* public api to insert option value rules */
    Okl_Option_Rules_Pub.create_option_val_rules(p_api_version   => p_api_version,
                              		             p_init_msg_list => p_init_msg_list,
                              		 	   	     x_return_status => l_return_status,
                              		 	   	     x_msg_count     => x_msg_count,
                              		 	   	     x_msg_data      => x_msg_data,
                              		 	   	     p_ovdv_rec      => l_ovdv_rec,
                              		 	   	     x_ovdv_rec      => x_ovdv_rec);

     IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END insert_overules;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_overules for: OKL_OPV_RULES_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_overules(p_api_version          IN  NUMBER,
                            p_init_msg_list        IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status        OUT NOCOPY VARCHAR2,
                        	x_msg_count            OUT NOCOPY NUMBER,
                        	x_msg_data             OUT NOCOPY VARCHAR2,
                            p_optv_rec             IN  optv_rec_type,
                            p_ovev_rec             IN  ovev_rec_type,
                        	p_ovdv_tbl             IN  ovdv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_ovdv_tbl        ovdv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_overules';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status  VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
    i                 NUMBER;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	l_ovdv_tbl := p_ovdv_tbl;
    IF (l_ovdv_tbl.COUNT > 0) THEN
      i := l_ovdv_tbl.FIRST;
      LOOP
	  	  Check_Constraints(p_ovdv_rec 		=> l_ovdv_tbl(i),
				            x_return_status	=> l_return_status,
				   		   	x_valid			=> l_valid);

		 IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		      (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		       l_valid <> TRUE) THEN
              x_return_status    := Okl_Api.G_RET_STS_ERROR;
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = l_ovdv_tbl.LAST);

          i := l_ovdv_tbl.NEXT(i);

       END LOOP;
     END IF;

	/* public api to delete option value rules */
    Okl_Option_Rules_Pub.delete_option_val_rules(p_api_version   => p_api_version,
                              		             p_init_msg_list => p_init_msg_list,
                              		 		     x_return_status => l_return_status,
                              		 		     x_msg_count     => x_msg_count,
                              		 		     x_msg_data      => x_msg_data,
                              		 		     p_ovdv_tbl      => l_ovdv_tbl);

     IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END delete_overules;

END Okl_Setupoverules_Pvt;

/
