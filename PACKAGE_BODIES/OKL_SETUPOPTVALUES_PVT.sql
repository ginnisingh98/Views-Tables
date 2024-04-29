--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPTVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPTVALUES_PVT" AS
/* $Header: OKLRSOVB.pls 115.15 2003/10/15 23:26:21 sgorantl noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OPT_VALUES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_ovev_rec                     IN ovev_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ovev_rec					   OUT NOCOPY ovev_rec_type
  ) IS
    CURSOR okl_ovev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OPT_ID,
            VALUE,
            NVL(DESCRIPTION,Okl_Api.G_MISS_CHAR) DESCRIPTION,
            FROM_DATE,
            NVL(TO_DATE,Okl_Api.G_MISS_DATE) TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM  Okl_Opt_Values_V
     WHERE okl_opt_values_v.id    = p_id;
    l_okl_ovev_pk                  okl_ovev_pk_csr%ROWTYPE;
    l_ovev_rec                     ovev_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_ovev_pk_csr (p_ovev_rec.id);
    FETCH okl_ovev_pk_csr INTO
              l_ovev_rec.ID,
              l_ovev_rec.OBJECT_VERSION_NUMBER,
              l_ovev_rec.OPT_ID,
              l_ovev_rec.VALUE,
              l_ovev_rec.DESCRIPTION,
              l_ovev_rec.FROM_DATE,
              l_ovev_rec.TO_DATE,
              l_ovev_rec.CREATED_BY,
              l_ovev_rec.CREATION_DATE,
              l_ovev_rec.LAST_UPDATED_BY,
              l_ovev_rec.LAST_UPDATE_DATE,
              l_ovev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ovev_pk_csr%NOTFOUND;
    CLOSE okl_ovev_pk_csr;
    x_ovev_rec := l_ovev_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name		=>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_ovev_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovev_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rul_rec for: OKC_RuleS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rul_rec (
    p_rulv_rec                     IN rulv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_rulv_rec					   OUT NOCOPY rulv_rec_type
  ) IS
    CURSOR okl_rulv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RGP_ID,
            NVL(OBJECT1_ID1, Okl_Api.G_MISS_CHAR) OBJECT1_ID1,
            NVL(OBJECT2_ID1, Okl_Api.G_MISS_CHAR) OBJECT2_ID1,
            NVL(OBJECT3_ID1, Okl_Api.G_MISS_CHAR) OBJECT3_ID1,
            NVL(OBJECT1_ID2, Okl_Api.G_MISS_CHAR) OBJECT1_ID2,
            NVL(OBJECT2_ID2, Okl_Api.G_MISS_CHAR) OBJECT2_ID2,
            NVL(OBJECT3_ID2, Okl_Api.G_MISS_CHAR) OBJECT3_ID2,
            NVL(JTOT_OBJECT1_CODE, Okl_Api.G_MISS_CHAR) JTOT_OBJECT1_CODE,
            NVL(JTOT_OBJECT2_CODE, Okl_Api.G_MISS_CHAR) JTOT_OBJECT2_CODE,
            NVL(JTOT_OBJECT3_CODE, Okl_Api.G_MISS_CHAR) JTOT_OBJECT3_CODE,
            NVL(DNZ_CHR_ID, Okl_Api.G_MISS_NUM) DNZ_CHR_ID,
            STD_TEMPLATE_YN,
            --TEMPLATE_YN,
-- removing dependincies from okc_rules_tl
            --COMMENTS,
            WARN_YN,
            NVL(PRIORITY, Okl_Api.G_MISS_NUM) PRIORITY,
            OBJECT_VERSION_NUMBER,
            NVL(ATTRIBUTE_CATEGORY, Okl_Api.G_MISS_CHAR) ATTRIBUTE_CATEGORY,
            NVL(ATTRIBUTE1, Okl_Api.G_MISS_CHAR) ATTRIBUTE1,
            NVL(ATTRIBUTE2, Okl_Api.G_MISS_CHAR) ATTRIBUTE2,
            NVL(ATTRIBUTE3, Okl_Api.G_MISS_CHAR) ATTRIBUTE3,
            NVL(ATTRIBUTE4, Okl_Api.G_MISS_CHAR) ATTRIBUTE4,
            NVL(ATTRIBUTE5, Okl_Api.G_MISS_CHAR) ATTRIBUTE5,
            NVL(ATTRIBUTE6, Okl_Api.G_MISS_CHAR) ATTRIBUTE6,
            NVL(ATTRIBUTE7, Okl_Api.G_MISS_CHAR) ATTRIBUTE7,
            NVL(ATTRIBUTE8, Okl_Api.G_MISS_CHAR) ATTRIBUTE8,
            NVL(ATTRIBUTE9, Okl_Api.G_MISS_CHAR) ATTRIBUTE9,
            NVL(ATTRIBUTE10, Okl_Api.G_MISS_CHAR) ATTRIBUTE10,
            NVL(ATTRIBUTE11, Okl_Api.G_MISS_CHAR) ATTRIBUTE11,
            NVL(ATTRIBUTE12, Okl_Api.G_MISS_CHAR) ATTRIBUTE12,
            NVL(ATTRIBUTE13, Okl_Api.G_MISS_CHAR) ATTRIBUTE13,
            NVL(ATTRIBUTE14, Okl_Api.G_MISS_CHAR) ATTRIBUTE14,
            NVL(ATTRIBUTE15, Okl_Api.G_MISS_CHAR) ATTRIBUTE15,
            RULE_INFORMATION_CATEGORY,
            NVL(RULE_INFORMATION1, Okl_Api.G_MISS_CHAR) RULE_INFORMATION1,
            NVL(RULE_INFORMATION2, Okl_Api.G_MISS_CHAR) RULE_INFORMATION2,
            NVL(RULE_INFORMATION3, Okl_Api.G_MISS_CHAR) RULE_INFORMATION3,
            NVL(RULE_INFORMATION4, Okl_Api.G_MISS_CHAR) RULE_INFORMATION4,
            NVL(RULE_INFORMATION5, Okl_Api.G_MISS_CHAR) RULE_INFORMATION5,
            NVL(RULE_INFORMATION6, Okl_Api.G_MISS_CHAR) RULE_INFORMATION6,
            NVL(RULE_INFORMATION7, Okl_Api.G_MISS_CHAR) RULE_INFORMATION7,
            NVL(RULE_INFORMATION8, Okl_Api.G_MISS_CHAR) RULE_INFORMATION8,
            NVL(RULE_INFORMATION9, Okl_Api.G_MISS_CHAR) RULE_INFORMATION9,
            NVL(RULE_INFORMATION10, Okl_Api.G_MISS_CHAR) RULE_INFORMATION10,
            NVL(RULE_INFORMATION11, Okl_Api.G_MISS_CHAR) RULE_INFORMATION11,
            NVL(RULE_INFORMATION12, Okl_Api.G_MISS_CHAR) RULE_INFORMATION12,
            NVL(RULE_INFORMATION13, Okl_Api.G_MISS_CHAR) RULE_INFORMATION13,
            NVL(RULE_INFORMATION14, Okl_Api.G_MISS_CHAR) RULE_INFORMATION14,
            NVL(RULE_INFORMATION15, Okl_Api.G_MISS_CHAR) RULE_INFORMATION15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
-- removed references to okc_rules_tl
     FROM  Okc_Rules_b
     WHERE okc_rules_b.id    = p_id;
    l_okl_rulv_pk                  okl_rulv_pk_csr%ROWTYPE;
    l_rulv_rec                     rulv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_rulv_pk_csr (p_rulv_rec.id);
    FETCH okl_rulv_pk_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.RGP_ID,
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
              l_rulv_rec.STD_TEMPLATE_YN,
              --l_rulv_rec.TEMPLATE_YN,
-- removing dependincies from okc_rules_tl
              --l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
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
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_rulv_pk_csr%NOTFOUND;
    CLOSE okl_rulv_pk_csr;
    x_rulv_rec := l_rulv_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name		=>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_rulv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_rulv_pk_csr;
      END IF;

  END get_rul_rec;


  ---------------------------------------------------------------------------
  -- PROCEDURE default_parent_dates for: OKL_OPT_VALUES_V
 ---------------------------------------------------------------------------

 PROCEDURE default_parent_dates(
    p_ovev_rec		  IN ovev_rec_type,
    x_no_data_found   OUT NOCOPY BOOLEAN,
	x_return_status	  OUT NOCOPY VARCHAR2,
	x_optv_rec		  OUT NOCOPY optv_rec_type
  ) IS
    CURSOR okl_optv_pk_csr (p_opt_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_Options_V opt
     WHERE opt.id = p_opt_id;
    l_okl_optv_pk                  okl_optv_pk_csr%ROWTYPE;
    l_optv_rec                     optv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
	-- Get current database values
    OPEN okl_optv_pk_csr (p_ovev_rec.opt_id);
    FETCH okl_optv_pk_csr INTO
              l_optv_rec.FROM_DATE,
              l_optv_rec.TO_DATE;
    x_no_data_found := okl_optv_pk_csr%NOTFOUND;
    CLOSE okl_optv_pk_csr;
    x_optv_rec := l_optv_rec;
 EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,

							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_optv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_optv_pk_csr;
      END IF;

 END default_parent_dates;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_OPT_VALUES_V
  -- To verify whether the dates modification is valid in relation with
  -- the attached Option Value Rules, Options and Product
  ---------------------------------------------------------------------------
  PROCEDURE Check_Constraints (
    p_ovev_rec                     IN OUT NOCOPY ovev_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_valid                		   OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_ove_opt_fk_csr (p_opt_id     IN Okl_Options_V.id%TYPE,
		   				       p_from_date  IN Okl_Opt_Values_V.from_date%TYPE,
						       p_to_date    IN Okl_Opt_Values_V.TO_DATE%TYPE
	) IS
	SELECT '1'
    FROM Okl_Options_V opt
     WHERE opt.ID    = p_opt_id
	 AND   ((opt.FROM_DATE > p_from_date OR
	 		p_from_date > NVL(opt.TO_DATE,p_from_date)) OR
	 	    NVL(opt.TO_DATE, p_to_date) < p_to_date);

    CURSOR okl_ove_ovd_fk_csr (p_ove_id     IN Okl_Opt_Values_V.id%TYPE,
		   				       p_from_date  IN Okl_Opt_Values_V.from_date%TYPE,
						       p_to_date    IN Okl_Opt_Values_V.TO_DATE%TYPE
	) IS
	SELECT '1'
    FROM Okl_Opv_Rules_V ovd,
         Okl_Opt_Rules_V orl,
         Okl_Lse_Scs_Rules_V lsr
    WHERE ovd.OVE_ID = p_ove_id
    AND   orl.ID     = ovd.ORL_ID
    AND ((orl.LRG_LSE_ID IS NOT NULL
         AND lsr.LSE_ID = orl.LRG_LSE_ID
         AND lsr.SRD_ID = orl.LRG_SRD_ID)
         OR
         (orl.LRG_LSE_ID IS NULL
         AND lsr.LSE_ID IS NULL
         AND lsr.SRD_ID = orl.SRD_ID_FOR))
    AND lsr.RULE_GROUP = orl.RGR_RGD_CODE
    AND lsr.RULE = orl.RGR_RDF_CODE
    AND ((lsr.START_DATE > p_from_date OR
         P_from_date > NVL(lsr.END_DATE,p_from_date)) OR
	     NVL(lsr.END_DATE, p_to_date) < p_to_date);

    CURSOR okl_ove_pov_fk_csr (p_ove_id    IN Okl_Opt_Values_V.ID%TYPE,
		   				       p_from_date  IN Okl_Opt_Values_V.from_date%TYPE,
						       p_to_date    IN Okl_Opt_Values_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pdt_Opt_Vals_V pov
    WHERE pov.OVE_ID    = p_ove_id
    AND (pov.FROM_DATE < p_from_date OR
	     NVL(pov.TO_DATE, pov.FROM_DATE) > p_to_date);

    CURSOR okl_ove_values_unique (p_unique1  OKL_OPT_VALUES.OPT_ID%TYPE,
	                              p_unique2  OKL_OPT_VALUES.VALUE%TYPE
    ) IS
    SELECT '1'
       FROM OKL_OPT_VALUES_V
      WHERE OKL_OPT_VALUES_V.OPT_ID =  p_unique1 AND
            OKL_OPT_VALUES_V.VALUE =  p_unique2;

    l_unique_key                   OKL_OPT_VALUES_V.OPT_ID%TYPE;
    l_ovev_rec      ovev_rec_type;
    l_token_1       VARCHAR2(1999);
    l_token_2       VARCHAR2(1999);
    l_token_3      VARCHAR2(1999);
    l_token_4       VARCHAR2(1999);
	l_check		   	VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  l_to_date       okl_opt_values_v.TO_DATE%TYPE;
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_VALUES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_OPTIONS');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_RULE_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_RULES');

    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_OPT_VAL_SUMRY',
                                                      p_attribute_code => 'OKL_PRODUCT_OPTION_VALUES');


    -- Fix for g_miss_date
    IF p_ovev_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
          l_to_date := NULL;
    ELSE
          l_to_date := p_ovev_rec.TO_DATE;
    END IF;

    IF p_ovev_rec.id = Okl_Api.G_MISS_NUM THEN
       p_ovev_rec.value := Okl_Accounting_Util.okl_upper(p_ovev_rec.value);
    OPEN okl_ove_values_unique (p_ovev_rec.opt_id, p_ovev_rec.value);
    FETCH okl_ove_values_unique INTO l_unique_key;
    IF okl_ove_values_unique%FOUND THEN
       Okl_Api.set_message(G_APP_NAME,'OKL_NOT_UNIQUE', 'OKL_TABLE_NAME',l_token_1);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    CLOSE okl_ove_values_unique;
	END IF;


    -- Check for option values dates
    OPEN okl_ove_opt_fk_csr (p_ovev_rec.opt_id,
		 					 p_ovev_rec.from_date,
							 l_to_date);
    FETCH okl_ove_opt_fk_csr INTO l_check;
    l_row_not_found := okl_ove_opt_fk_csr%NOTFOUND;
    CLOSE okl_ove_opt_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_2,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_1);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF p_ovev_rec.id <> Okl_Api.G_MISS_NUM THEN
       -- Check for option rules dates
       OPEN okl_ove_ovd_fk_csr (p_ovev_rec.id,
		 					    p_ovev_rec.from_date,
							    l_to_date);
       FETCH okl_ove_ovd_fk_csr INTO l_check;
       l_row_not_found := okl_ove_ovd_fk_csr%NOTFOUND;
       CLOSE okl_ove_ovd_fk_csr;

       IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_DATES_MISMATCH,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_3);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;

       -- Check for product dates
       OPEN okl_ove_pov_fk_csr (p_ovev_rec.id,
		 					    p_ovev_rec.from_date,
							    l_to_date);
       FETCH okl_ove_pov_fk_csr INTO l_check;
       l_row_not_found := okl_ove_pov_fk_csr%NOTFOUND;
       CLOSE okl_ove_pov_fk_csr;

       IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_DATES_MISMATCH,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_4);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
    END IF;

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

       IF (okl_ove_ovd_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ove_ovd_fk_csr;
       END IF;

       IF (okl_ove_opt_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ove_opt_fk_csr;
       END IF;

       IF (okl_ove_pov_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ove_pov_fk_csr;
       END IF;

       IF (okl_ove_values_unique%ISOPEN) THEN
	   	  CLOSE okl_ove_values_unique;
       END IF;
  END Check_Constraints;

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate _Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Value (
    p_ovev_rec IN OUT NOCOPY ovev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_token_1       VARCHAR2(1999);
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTVAL_CRUPD','OKL_NAME');
    IF p_ovev_rec.value = Okc_Api.G_MISS_CHAR OR
       p_ovev_rec.value IS NULL
    THEN
      Okc_Api.set_message(Okl_Ove_Pvt.G_APP_NAME, Okl_Ove_Pvt.G_REQUIRED_VALUE,Okl_Ove_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    p_ovev_rec.value := Okl_Accounting_Util.okl_upper(p_ovev_rec.value);
  EXCEPTION
     WHEN OTHERS THEN
           Okc_Api.set_message(p_app_name  =>Okl_Ove_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Ove_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Ove_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Ove_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Value;
------end of Validate_Value-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate _From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_From_Date(
    p_ovev_rec IN  ovev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_token_1       VARCHAR2(999);
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTVAL_CRUPD','OKL_EFFECTIVE_FROM');
    IF p_ovev_rec.from_date IS NULL OR p_ovev_rec.from_date = Okl_Api.G_MISS_DATE
    THEN
      Okl_Api.set_message(Okl_Ove_Pvt.G_APP_NAME, Okl_Ove_Pvt.G_REQUIRED_VALUE,Okl_Ove_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name  =>Okl_Ove_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Ove_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Ove_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Ove_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;
------end of Validate_From_Date-----------------------------------


---------------------------------------------------------------------------
  -- FUNCTION Validate _Attribute
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate _Attribute
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 FUNCTION Validate_Attributes(
    p_ovev_rec IN OUT NOCOPY ovev_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;


  BEGIN

    -----CHECK FOR VALUE----------------------------
    Validate_Value (p_ovev_rec,x_return_status);
    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
    ELSE
       l_return_status := x_return_status;
     END IF;

    END IF;

   -----CHECK FOR FROM_DATE----------------------------
    Validate_From_Date (p_ovev_rec,x_return_status);
    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
    ELSE
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
           Okl_Api.set_message(p_app_name  =>Okl_Ove_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Ove_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Ove_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Ove_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

-----END OF VALIDATE ATTRIBUTES-------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE check_rule_templates for: OKL_OPT_VALUES_V
  -- To verify whether the dates modification is valid in relation with
  -- the attached Option Value Rule Templates
  ---------------------------------------------------------------------------
  PROCEDURE check_rule_templates (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    p_ovev_rec       IN  ovev_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_ove_ovt_fk_csr (p_ove_id     IN Okl_Opt_Values_V.id%TYPE
	) IS
	SELECT ovt.RUL_ID RUL_ID,
           ovd.CONTEXT_INTENT CONTEXT_INTENT,
           orl.RGR_RGD_CODE RGR_RGD_CODE,
           orl.RGR_RDF_CODE RGR_RDF_CODE,
           ovt.SEQUENCE_NUMBER SEQUENCE_NUMBER
    FROM Okl_Opt_Rules_V  orl,
         Okl_Opv_Rules_V ovd,
         Okl_Ovd_Rul_Tmls_V ovt
    WHERE ovd.OVE_ID = p_ove_id
    AND   orl.ID     = ovd.ORL_ID
    AND   ovt.OVD_ID = ovd.ID;

    CURSOR okl_ove_rds_fk_csr (p_rgd_code         IN OKC_Rule_Def_Sources_V.rgr_rgd_code%TYPE,
                               p_rdf_code         IN OKC_Rule_Def_Sources_V.rgr_rdf_code%TYPE,
                               p_buy_or_sell      IN OKC_Rule_Def_Sources_V.buy_or_sell%TYPE,
                               p_jtot_object_code IN OKC_Rule_Def_Sources_V.jtot_object_code%TYPE,
                               p_object_id_number IN OKC_Rule_Def_Sources_V.object_id_number%TYPE,
                               p_from_date        IN Okl_Opt_Values_V.from_date%TYPE,
                               p_to_date          IN Okl_Opt_Values_V.TO_DATE%TYPE
	) IS
	SELECT '1'
    FROM OKC_Rule_Def_Sources_V  rds
    WHERE rds.RGR_RGD_CODE = p_rgd_code
    AND   rds.RGR_RDF_CODE = p_rdf_code
    AND   rds.OBJECT_ID_NUMBER = p_object_id_number
    AND   rds.JTOT_OBJECT_CODE = p_jtot_object_code
    AND   rds.BUY_OR_SELL = p_buy_or_sell
    AND (rds.START_DATE > p_from_date OR
         NVL(rds.END_DATE, p_to_date) < p_to_date);

    l_rulv_disp_rec    rulv_disp_rec_type;
	l_no_data_found	   BOOLEAN := TRUE;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_count            NUMBER := 0;
    l_jtot_object_code VARCHAR2(30);
    l_okx_start_date   DATE;
    l_okx_end_date     DATE;
    l_rulv_rec         rulv_rec_type;
	l_check		   	   VARCHAR2(1) := '?';
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_ove_ovt_rec IN okl_ove_ovt_fk_csr(p_ovev_rec.id)
	LOOP
        l_rulv_rec.id := okl_ove_ovt_rec.rul_id;
        get_rul_rec (p_rulv_rec      => l_rulv_rec,
                     x_return_status => l_return_status,
                     x_no_data_found => l_no_data_found,
                     x_rulv_rec      => l_rulv_rec);
	    IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	       l_no_data_found = TRUE THEN
	       x_valid := FALSE;
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	       RAISE G_EXCEPTION_HALT_PROCESSING;
	    END IF;
        Okl_Rule_Apis_Pvt.get_rule_disp_value(p_api_version   => p_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              p_rulv_rec      => l_rulv_rec,
                                              x_return_status => l_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              x_rulv_disp_rec => l_rulv_disp_rec);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	       x_valid := FALSE;
           x_return_status := Okl_Api.G_RET_STS_ERROR;
	       RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	       x_valid := FALSE;
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	       RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;

       FOR l_object_id_number IN 1..3
       LOOP
           IF l_object_id_number = 1 THEN
              l_jtot_object_code := l_rulv_rec.jtot_object1_code;
              l_okx_start_date := l_rulv_disp_rec.obj1_start_date;
              l_okx_end_date := l_rulv_disp_rec.obj1_end_date;
           ELSIF l_object_id_number = 2 THEN
              l_jtot_object_code := l_rulv_rec.jtot_object2_code;
              l_okx_start_date := l_rulv_disp_rec.obj2_start_date;
              l_okx_end_date := l_rulv_disp_rec.obj2_end_date;
           ELSE
              l_jtot_object_code := l_rulv_rec.jtot_object3_code;
              l_okx_start_date := l_rulv_disp_rec.obj3_start_date;
              l_okx_end_date := l_rulv_disp_rec.obj3_end_date;
           END IF;

           IF l_jtot_object_code <> Okl_Api.G_MISS_CHAR AND
              (l_okx_start_date > p_ovev_rec.from_date OR
               NVL(l_okx_end_date, p_ovev_rec.TO_DATE) < p_ovev_rec.TO_DATE OR
               p_ovev_rec.from_date > p_ovev_rec.TO_DATE) THEN
              Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
				                  p_msg_name	   => G_DATES_MISMATCH,
						          p_token1		   => G_PARENT_TABLE_TOKEN,
						          p_token1_value  => 'Okl_Opt_Values_V',
						          p_token2		   => G_CHILD_TABLE_TOKEN,
						          p_token2_value  => 'OKC_Rules_V');
	          x_valid := FALSE;
              x_return_status := Okl_Api.G_RET_STS_ERROR;
	          RAISE G_EXCEPTION_HALT_PROCESSING;
           END IF;

           IF l_jtot_object_code <> Okl_Api.G_MISS_CHAR THEN
               -- Check for dates in source, okx and option value
               OPEN okl_ove_rds_fk_csr (p_rgd_code         => okl_ove_ovt_rec.rgr_rgd_code,
                                        p_rdf_code         => okl_ove_ovt_rec.rgr_rdf_code,
                                        p_buy_or_sell      => okl_ove_ovt_rec.context_intent,
                                        p_jtot_object_code => l_jtot_object_code,
                                        p_object_id_number => l_object_id_number,
                                        p_from_date        => p_ovev_rec.from_date,
                                        p_to_date          => p_ovev_rec.TO_DATE);
               FETCH okl_ove_rds_fk_csr INTO l_check;
               l_no_data_found := okl_ove_rds_fk_csr%NOTFOUND;
               CLOSE okl_ove_rds_fk_csr;

               IF l_no_data_found = FALSE THEN
	              Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						              p_msg_name	   => G_DATES_MISMATCH,
						              p_token1		   => G_PARENT_TABLE_TOKEN,
						              p_token1_value   => 'Okl_Opt_Values_V',
						              p_token2		   => G_CHILD_TABLE_TOKEN,
						              p_token2_value   => 'OKC_Rule_Def_Sources_V');
	              x_valid := FALSE;
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
	              RAISE G_EXCEPTION_HALT_PROCESSING;
               END IF;
           END IF;
       END LOOP;

	END LOOP;

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

       IF (okl_ove_ovt_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ove_ovt_fk_csr;
       END IF;

       IF (okl_ove_rds_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ove_rds_fk_csr;
       END IF;

  END check_rule_templates;

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_ovev_rec                 IN OUT NOCOPY ovev_rec_type,
	p_db_ovev_rec				   IN ovev_rec_type
  ) IS
  l_upd_ovev_rec	ovev_rec_type;
  l_db_ovev_rec     ovev_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_ovev_rec := p_upd_ovev_rec;
       l_db_ovev_rec := p_db_ovev_rec;

	   IF l_upd_ovev_rec.description = l_db_ovev_rec.description THEN
	  	  l_upd_ovev_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_ovev_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_ovev_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

       p_upd_ovev_rec := l_upd_ovev_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_ovev_rec                 IN ovev_rec_type,
	p_db_ovev_rec				   IN ovev_rec_type
  ) RETURN ovev_rec_type IS
  l_ovev_rec	ovev_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_ovev_rec := p_db_ovev_rec;

	   IF p_upd_ovev_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_ovev_rec.description := p_upd_ovev_rec.description;
	   END IF;

	   IF p_upd_ovev_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_ovev_rec.from_date := p_upd_ovev_rec.from_date;
	   END IF;

	   IF p_upd_ovev_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_ovev_rec.TO_DATE := p_upd_ovev_rec.TO_DATE;
	   END IF;

	   RETURN l_ovev_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    p_upd_ovev_rec                 IN ovev_rec_type,
	p_db_ovev_rec				   IN ovev_rec_type,
	p_ovev_rec					   IN ovev_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_ovev_rec	  ovev_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_ovev_rec := p_ovev_rec;

	/* check for start date greater than sysdate */
	/*IF to_date(to_char(p_upd_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_upd_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   */
    /* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(p_upd_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END IF;
	*/
    /* if the start date is in the past, the start date cannot be
       modified */
	/*IF to_date(to_char(p_upd_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_db_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_NOT_ALLOWED,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
	*/

    IF p_upd_ovev_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   p_upd_ovev_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
         Check_Constraints(p_ovev_rec 	 	 => l_ovev_rec,
					       x_return_status	 => l_return_status,
					       x_valid			 => l_valid);
       	 IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       		x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
      	  	RAISE G_EXCEPTION_HALT_PROCESSING;
       	 ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		  	    (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	   	 l_valid <> TRUE) THEN
       		x_return_status    := Okl_Api.G_RET_STS_ERROR;
      	  	RAISE G_EXCEPTION_HALT_PROCESSING;
       	 END IF;

         check_rule_templates(p_api_version      => p_api_version,
                              p_init_msg_list    => p_init_msg_list,
                              p_ovev_rec         => l_ovev_rec,
                              x_return_status    => l_return_status,
                              x_msg_count        => x_msg_count,
                              x_msg_data         => x_msg_data,
                              x_valid            => l_valid);
       	 IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       		x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
      	  	RAISE G_EXCEPTION_HALT_PROCESSING;
       	 ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		  	    (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	   	 l_valid <> TRUE) THEN
       		x_return_status    := Okl_Api.G_RET_STS_ERROR;
      	  	RAISE G_EXCEPTION_HALT_PROCESSING;
       	 END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_updates;

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_OPT_VALUES_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_ovev_rec                 IN ovev_rec_type,
	p_db_ovev_rec				   IN ovev_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
BEGIN
  /* Scenario 1: Only description changes */
  IF p_upd_ovev_rec.from_date = Okl_Api.G_MISS_DATE AND
	 p_upd_ovev_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
	 l_action := '1';
	/* Scenario 2: Changing the dates */
  ELSE
	 l_action := '2';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_optvalues for: OKL_OPT_VALUES_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_optvalues(p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             p_optv_rec          IN  optv_rec_type,
                             p_ovev_rec          IN  ovev_rec_type,
                             x_ovev_rec          OUT NOCOPY ovev_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_optvalues';
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_optv_rec		  optv_rec_type;
    l_ovev_rec        ovev_rec_type;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_optv_rec := p_optv_rec;
    l_ovev_rec := p_ovev_rec;

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

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ovev_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* check for the records with start or end dates less than sysdate */
    /*IF to_date(to_char(l_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
	*/
	default_parent_dates( p_ovev_rec 	    => l_ovev_rec,
                          x_no_data_found   => l_row_notfound,
	                      x_return_status   => l_return_status,
	                      x_optv_rec  	    => l_optv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--Default Child End Date With Its Parents End Date If It Is Not Entered.
    IF to_date(to_char(l_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
       to_date(to_char(l_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
   	   l_ovev_rec.TO_DATE   := l_optv_rec.TO_DATE;
    END IF;

	/* call check_constraints to check the validity of this relationship */
	Check_Constraints(p_ovev_rec 		=> l_ovev_rec,
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

	/* public api to create option values */
    Okl_Options_Pub.create_option_values(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => l_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_ovev_rec      => l_ovev_rec,
                                         x_ovev_rec      => x_ovev_rec);

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

  END insert_optvalues;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_optvalues for: OKL_OPT_VALUES_V
  ---------------------------------------------------------------------------
  PROCEDURE update_optvalues(p_api_version     IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_optv_rec         IN  optv_rec_type,
                            p_ovev_rec         IN  ovev_rec_type,
                        	x_ovev_rec         OUT NOCOPY ovev_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_optvalues';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
    l_optv_rec              optv_rec_type; /* for master record */
    l_db_ovev_rec    	  	ovev_rec_type; /* database copy */
	l_upd_ovev_rec	 	  	ovev_rec_type; /* input copy */
	l_ovev_rec	  	 	  	ovev_rec_type; /* latest with the retained changes */
	l_tmp_ovev_rec			ovev_rec_type; /* for any other purposes */
	l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_row_notfound          BOOLEAN := TRUE;
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

    l_upd_ovev_rec := p_ovev_rec;

	/* fetch old details from the database */
    get_rec(p_ovev_rec 	 	=> l_upd_ovev_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_ovev_rec		=> l_db_ovev_rec);
	IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	default_parent_dates( p_ovev_rec 	    => l_db_ovev_rec,
                          x_no_data_found   => l_row_notfound,
	                      x_return_status   => l_return_status,
	                      x_optv_rec  	    => l_optv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--Default Child End Date With Its Parents End Date If It Is Not Entered.
    IF to_date(to_char(l_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
       (to_date(to_char(l_upd_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') OR
	    to_date(to_char(l_upd_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') IS NULL) THEN
   	   l_upd_ovev_rec.TO_DATE   := l_optv_rec.TO_DATE;
    END IF;

    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_ovev_rec     => l_upd_ovev_rec,
                      p_db_ovev_rec      => l_db_ovev_rec);

	/* check for past records */
    /*IF to_date(to_char(l_db_ovev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
       to_date(to_char(l_db_ovev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
	*/

	    IF (l_upd_ovev_rec.TO_DATE = Okl_Api.G_MISS_DATE) then
            l_upd_ovev_rec.TO_DATE := p_ovev_rec.to_date;
     end if;

     IF (l_upd_ovev_rec.from_DATE = Okl_Api.G_MISS_DATE) then
         l_upd_ovev_rec.from_DATE := p_ovev_rec.from_date;
     end if;


	/* To Check end date is > start date*/
	IF (l_upd_ovev_rec.TO_DATE IS NOT NULL) AND (l_upd_ovev_rec.TO_DATE < l_upd_ovev_rec.from_date) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => Okl_Ove_Pvt.g_to_date_error
                          ,p_token1         => Okl_Ove_Pvt.g_col_name_token
                          ,p_token1_value   => 'TO_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* determine how the processing to be done */
	l_action := determine_action(p_upd_ovev_rec	 => l_upd_ovev_rec,
			 					 p_db_ovev_rec	 => l_db_ovev_rec,
								 p_date			 => l_sysdate);

	/* Scenario 1: only changing description and descriptive flexfields */
	IF l_action = '1' THEN
	   /* public api to update options */
       Okl_Options_Pub.update_option_values(p_api_version   => p_api_version,
                           		 	        p_init_msg_list => p_init_msg_list,
                              		        x_return_status => l_return_status,
                              		        x_msg_count     => x_msg_count,
                              		        x_msg_data      => x_msg_data,
                              		        p_ovev_rec      => l_upd_ovev_rec,
                              		        x_ovev_rec      => x_ovev_rec);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 2: changing the dates */
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_ovev_rec := defaults_to_actuals(p_upd_ovev_rec => l_upd_ovev_rec,
	   					  				 p_db_ovev_rec  => l_db_ovev_rec);

	   check_updates(p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     p_upd_ovev_rec	 => l_upd_ovev_rec,
	   			     p_db_ovev_rec	 => l_db_ovev_rec,
					 p_ovev_rec		 => l_ovev_rec,
					 x_return_status => l_return_status,
                     x_msg_count     => x_msg_count,
					 x_msg_data		 => x_msg_data);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* public api to update options */
       Okl_Options_Pub.update_option_values(p_api_version   => p_api_version,
                            		        p_init_msg_list => p_init_msg_list,
                              		        x_return_status => l_return_status,
                              		        x_msg_count     => x_msg_count,
                              		        x_msg_data      => x_msg_data,
                              		        p_ovev_rec      => l_upd_ovev_rec,
                              		        x_ovev_rec      => x_ovev_rec);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

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

  END update_optvalues;

END Okl_Setupoptvalues_Pvt;

/
