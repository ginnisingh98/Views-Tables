--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPTIONS_PVT" AS
/* $Header: OKLRSOTB.pls 115.13 2003/07/23 18:33:51 sgorantl noship $ */

  SUBTYPE ovev_rec_type IS Okl_Options_Pub.ovev_rec_type;
  SUBTYPE ovev_tbl_type IS Okl_Options_Pub.ovev_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OPTIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_optv_rec                     IN optv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_optv_rec					   OUT NOCOPY optv_rec_type
  ) IS
    CURSOR okl_optv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            NVL(DESCRIPTION,Okl_Api.G_MISS_CHAR) DESCRIPTION,
            FROM_DATE,
            NVL(TO_DATE,Okl_Api.G_MISS_DATE) TO_DATE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM Okl_Options_V
     WHERE okl_options_v.id    = p_id;
    l_okl_optv_pk                  okl_optv_pk_csr%ROWTYPE;
    l_optv_rec                     optv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_optv_pk_csr (p_optv_rec.id);
    FETCH okl_optv_pk_csr INTO
              l_optv_rec.ID,
              l_optv_rec.OBJECT_VERSION_NUMBER,
              l_optv_rec.NAME,
              l_optv_rec.DESCRIPTION,
              l_optv_rec.FROM_DATE,
              l_optv_rec.TO_DATE,
              l_optv_rec.ATTRIBUTE_CATEGORY,
              l_optv_rec.ATTRIBUTE1,
              l_optv_rec.ATTRIBUTE2,
              l_optv_rec.ATTRIBUTE3,
              l_optv_rec.ATTRIBUTE4,
              l_optv_rec.ATTRIBUTE5,
              l_optv_rec.ATTRIBUTE6,
              l_optv_rec.ATTRIBUTE7,
              l_optv_rec.ATTRIBUTE8,
              l_optv_rec.ATTRIBUTE9,
              l_optv_rec.ATTRIBUTE10,
              l_optv_rec.ATTRIBUTE11,
              l_optv_rec.ATTRIBUTE12,
              l_optv_rec.ATTRIBUTE13,
              l_optv_rec.ATTRIBUTE14,
              l_optv_rec.ATTRIBUTE15,
              l_optv_rec.CREATED_BY,
              l_optv_rec.CREATION_DATE,
              l_optv_rec.LAST_UPDATED_BY,
              l_optv_rec.LAST_UPDATE_DATE,
              l_optv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_optv_pk_csr%NOTFOUND;
    CLOSE okl_optv_pk_csr;
    x_optv_rec := l_optv_rec;
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

      IF (okl_optv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_optv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_opt_values for: OKL_OPTIONS_V
  -- To fetch the valid values for the OPTIONS.
  ---------------------------------------------------------------------------
  PROCEDURE get_opt_values (p_upd_optv_rec   IN optv_rec_type,
						    x_return_status  OUT NOCOPY VARCHAR2,
						    x_count		     OUT NOCOPY NUMBER,
						    x_ovev_tbl	     OUT NOCOPY ovev_tbl_type
  ) IS
    CURSOR okl_ovev_fk_csr (p_opt_id IN Okl_opt_values_V.id%TYPE) IS
    SELECT ove.ID ID,
           ove.FROM_DATE FROM_DATE,
           ove.TO_DATE TO_DATE
    FROM Okl_opt_Values_V ove
    WHERE ove.opt_id = p_opt_id
    AND   ove.TO_DATE IS NULL;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_ovev_tbl	    ovev_tbl_type;
    i               NUMBER := 0;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_ove_rec IN okl_ovev_fk_csr(p_upd_optv_rec.id)
	LOOP
       l_ovev_tbl(l_count).ID := okl_ove_rec.ID;
	   l_ovev_tbl(l_count).TO_DATE := p_upd_optv_rec.TO_DATE;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_ovev_tbl := l_ovev_tbl;

EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_ovev_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovev_fk_csr;
      END IF;

  END get_opt_values;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_OPTIONS_V
  -- To verify whether the dates modification is valid in relation with
  -- the attached Option Rules, Option Values and Product
  ---------------------------------------------------------------------------
  PROCEDURE Check_Constraints (
    p_optv_rec                     IN optv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_valid                		   OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_opt_orl_fk_csr (p_opt_id     IN Okl_Options_V.id%TYPE,
		   				       p_from_date  IN Okl_Options_V.from_date%TYPE,
						       p_to_date    IN Okl_Options_V.TO_DATE%TYPE

	) IS
	SELECT '1'
    FROM Okl_Opt_Rules_V orl,
         Okl_Lse_Scs_Rules_V lsr
    WHERE orl.OPT_ID = p_opt_id
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

    CURSOR okl_opt_ove_fk_csr (p_opt_id     IN Okl_Options_V.id%TYPE,
		   				       p_from_date  IN Okl_Options_V.from_date%TYPE,
						       p_to_date    IN Okl_Options_V.TO_DATE%TYPE

	) IS
	SELECT '1'
    FROM Okl_Opt_Values_V ove
     WHERE ove.OPT_ID    = p_opt_id
	 AND   (ove.FROM_DATE < p_from_date OR
	 	    NVL(ove.TO_DATE, ove.FROM_DATE) > p_to_date);

    CURSOR okl_opt_pon_fk_csr (p_opt_id    IN Okl_Options_V.ID%TYPE,
		   				       p_from_date  IN Okl_Options_V.from_date%TYPE,
						       p_to_date    IN Okl_Options_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pdt_Opts_V pon
    WHERE pon.OPT_ID    = p_opt_id
    AND (pon.FROM_DATE < p_from_date OR
	     NVL(pon.TO_DATE, pon.FROM_DATE) > p_to_date);

    l_token_1       VARCHAR2(1999);
    l_token_2       VARCHAR2(1999);
    l_token_3      VARCHAR2(1999);
    l_token_4       VARCHAR2(1999);
    l_optv_rec      optv_rec_type;
	l_check		   	VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
    l_to_date       okl_options_v.TO_DATE%TYPE;
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_OPTIONS');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_RULE_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_RULES');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_VALUES');

    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_OPTIONS');


    -- Fix for g_miss_date
    IF p_optv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
          l_to_date := NULL;
    ELSE
          l_to_date := p_optv_rec.TO_DATE;
    END IF;


    -- Check for option rules dates
    OPEN okl_opt_orl_fk_csr (p_optv_rec.id,
		 					p_optv_rec.from_date,
							l_to_date);
    FETCH okl_opt_orl_fk_csr INTO l_check;
    l_row_not_found := okl_opt_orl_fk_csr%NOTFOUND;
    CLOSE okl_opt_orl_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_1,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_2);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    -- Check for option values dates
    OPEN okl_opt_ove_fk_csr (p_optv_rec.id,
		 					 p_optv_rec.from_date,
							 l_to_date);
    FETCH okl_opt_ove_fk_csr INTO l_check;
    l_row_not_found := okl_opt_ove_fk_csr%NOTFOUND;
    CLOSE okl_opt_ove_fk_csr;

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
    OPEN okl_opt_pon_fk_csr (p_optv_rec.id,
		 					 p_optv_rec.from_date,
							 l_to_date);
    FETCH okl_opt_pon_fk_csr INTO l_check;
    l_row_not_found := okl_opt_pon_fk_csr%NOTFOUND;
    CLOSE okl_opt_pon_fk_csr;

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

       IF (okl_opt_orl_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opt_orl_fk_csr;
       END IF;

       IF (okl_opt_ove_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opt_ove_fk_csr;
       END IF;

       IF (okl_opt_pon_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opt_pon_fk_csr;
       END IF;

  END Check_Constraints;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate _Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Name(
    p_optv_rec IN OUT NOCOPY optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1       VARCHAR2(999);
  BEGIN

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTION_CRUPD','OKL_NAME');
    IF p_optv_rec.name = Okl_Api.G_MISS_CHAR OR
       p_optv_rec.name IS NULL
    THEN
      Okl_Api.set_message(Okl_Opt_Pvt.G_APP_NAME, Okl_Opt_Pvt.G_REQUIRED_VALUE,Okl_Opt_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    p_optv_rec.name := Okl_Accounting_Util.okl_upper(p_optv_rec.name);
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name       =>Okl_Opt_Pvt.G_APP_NAME,
                               p_msg_name       =>Okl_Opt_Pvt.G_UNEXPECTED_ERROR,
                               p_token1         =>Okl_Opt_Pvt.G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>Okl_Opt_Pvt.G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;
------end of Validate_Name-----------------------------------

 ---------------------------------------------------------------------------
 -- PROCEDURE Validate _From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE Validate_From_Date(
    p_optv_rec IN  optv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1       VARCHAR2(999);
  BEGIN
     l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_OPTION_CRUPD','OKL_EFFECTIVE_FROM');
    IF p_optv_rec.from_date IS NULL OR p_optv_rec.from_date = Okl_Api.G_MISS_DATE
    THEN
      Okl_Api.set_message(Okl_Opt_Pvt.G_APP_NAME, Okl_Opt_Pvt.G_REQUIRED_VALUE,Okl_Opt_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name       =>Okl_Opt_Pvt.G_APP_NAME,
                               p_msg_name       =>Okl_Opt_Pvt.G_UNEXPECTED_ERROR,
                               p_token1         =>Okl_Opt_Pvt.G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>Okl_Opt_Pvt.G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;
------end of Validate_From_Date-----------------------------------


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

FUNCTION Validate_Attributes(
    p_optv_rec IN OUT NOCOPY optv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;


  BEGIN
    -------CHECK FOR NAME------------------
    Validate_Name (p_optv_rec, x_return_status);
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
    Validate_From_Date (p_optv_rec, x_return_status);
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
           Okl_Api.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name  =>Okl_Opt_Pvt.G_UNEXPECTED_ERROR,
                          p_token1    =>Okl_Opt_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value  =>SQLCODE,
                          p_token2    =>Okl_Opt_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value  =>SQLERRM);
           l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

-----END OF VALIDATE ATTRIBUTES-------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_optv_rec                 IN OUT NOCOPY optv_rec_type,
	p_db_optv_rec				   IN optv_rec_type
  ) IS
  l_upd_optv_rec	optv_rec_type;
  l_db_optv_rec     optv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_optv_rec := p_upd_optv_rec;
       l_db_optv_rec := p_db_optv_rec;

	   IF l_upd_optv_rec.description = l_db_optv_rec.description THEN
	  	  l_upd_optv_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_optv_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_optv_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF l_upd_optv_rec.attribute_category = l_db_optv_rec.attribute_category THEN
	   	  l_upd_optv_rec.attribute_category := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute1 = l_db_optv_rec.attribute1 THEN
	   	  l_upd_optv_rec.attribute1 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute2 = l_db_optv_rec.attribute2 THEN
	   	  l_upd_optv_rec.attribute2 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute3 = l_db_optv_rec.attribute3 THEN
	   	  l_upd_optv_rec.attribute3 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute4 = l_db_optv_rec.attribute4 THEN
	   	  l_upd_optv_rec.attribute4 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute5 = l_db_optv_rec.attribute5 THEN
	   	  l_upd_optv_rec.attribute5 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute6 = l_db_optv_rec.attribute6 THEN
	   	  l_upd_optv_rec.attribute6 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute7 = l_db_optv_rec.attribute7 THEN
	   	  l_upd_optv_rec.attribute7 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute8 = l_db_optv_rec.attribute8 THEN
	   	  l_upd_optv_rec.attribute8 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute9 = l_db_optv_rec.attribute9 THEN
	   	  l_upd_optv_rec.attribute9 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute10 = l_db_optv_rec.attribute10 THEN
	   	  l_upd_optv_rec.attribute10 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute11 = l_db_optv_rec.attribute11 THEN
	   	  l_upd_optv_rec.attribute11 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute12 = l_db_optv_rec.attribute12 THEN
	   	  l_upd_optv_rec.attribute12 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute13 = l_db_optv_rec.attribute13 THEN
	   	  l_upd_optv_rec.attribute13 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute14 = l_db_optv_rec.attribute14 THEN
	   	  l_upd_optv_rec.attribute14 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_optv_rec.attribute15 = l_db_optv_rec.attribute15 THEN
	   	  l_upd_optv_rec.attribute15 := Okl_Api.G_MISS_CHAR;
	   END IF;

       p_upd_optv_rec := l_upd_optv_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_optv_rec                 IN optv_rec_type,
	p_db_optv_rec				   IN optv_rec_type
  ) RETURN optv_rec_type IS
  l_optv_rec	optv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_optv_rec := p_db_optv_rec;

	   IF p_upd_optv_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_optv_rec.description := p_upd_optv_rec.description;
	   END IF;

	   IF p_upd_optv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_optv_rec.from_date := p_upd_optv_rec.from_date;
	   END IF;

	   IF p_upd_optv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_optv_rec.TO_DATE := p_upd_optv_rec.TO_DATE;
	   END IF;

	   IF p_upd_optv_rec.attribute_category <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute_category := p_upd_optv_rec.attribute_category;
	   END IF;

	   IF p_upd_optv_rec.attribute1 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute1 := p_upd_optv_rec.attribute1;
	   END IF;

	   IF p_upd_optv_rec.attribute2 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute2 := p_upd_optv_rec.attribute2;
	   END IF;

	   IF p_upd_optv_rec.attribute3 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute3 := p_upd_optv_rec.attribute3;
	   END IF;

	   IF p_upd_optv_rec.attribute4 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute4 := p_upd_optv_rec.attribute4;
	   END IF;

	   IF p_upd_optv_rec.attribute5 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute5 := p_upd_optv_rec.attribute5;
	   END IF;

	   IF p_upd_optv_rec.attribute6 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute6 := p_upd_optv_rec.attribute6;
	   END IF;

	   IF p_upd_optv_rec.attribute7 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute7 := p_upd_optv_rec.attribute7;
	   END IF;

	   IF p_upd_optv_rec.attribute8 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute8 := p_upd_optv_rec.attribute8;
	   END IF;

	   IF p_upd_optv_rec.attribute9 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute9 := p_upd_optv_rec.attribute9;
	   END IF;

	   IF p_upd_optv_rec.attribute10 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute10 := p_upd_optv_rec.attribute10;
	   END IF;

	   IF p_upd_optv_rec.attribute11 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute11 := p_upd_optv_rec.attribute11;
	   END IF;

	   IF p_upd_optv_rec.attribute12 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute12 := p_upd_optv_rec.attribute12;
	   END IF;

	   IF p_upd_optv_rec.attribute13 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute13 := p_upd_optv_rec.attribute13;
	   END IF;

	   IF p_upd_optv_rec.attribute14 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute14 := p_upd_optv_rec.attribute14;
	   END IF;

	   IF p_upd_optv_rec.attribute15 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_optv_rec.attribute15 := p_upd_optv_rec.attribute15;
	   END IF;

	   RETURN l_optv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_upd_optv_rec                 IN optv_rec_type,
	p_db_optv_rec				   IN optv_rec_type,
	p_optv_rec					   IN optv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_optv_rec	  optv_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_optv_rec := p_optv_rec;

	/* check for start date greater than sysdate */
	/*IF to_date(to_char(p_upd_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_upd_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   */
    /* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(p_upd_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END IF;
	*/
    /* if the start date is in the past, the start date cannot be
       modified */
	/*IF to_date(to_char(p_upd_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_db_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_NOT_ALLOWED,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
	*/
    IF p_upd_optv_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   p_upd_optv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
         Check_Constraints(p_optv_rec 	 	 => l_optv_rec,
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
  -- PROCEDURE determine_action for: OKL_OPTIONS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_optv_rec                 IN optv_rec_type,
	p_db_optv_rec				   IN optv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
BEGIN
  /* Scenario 1: Only description and/or descriptive flexfield changes */
  IF p_upd_optv_rec.from_date = Okl_Api.G_MISS_DATE AND
	 p_upd_optv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
	 l_action := '1';
	/* Scenario 2: Changing the dates */
  ELSE
	 l_action := '2';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE copy_update_constraints for: OKL_OPTIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE copy_update_constraints (p_api_version    IN  NUMBER,
                                     p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                                     p_upd_optv_rec   IN  optv_rec_type,
									 x_return_status  OUT NOCOPY VARCHAR2,
                      		 		 x_msg_count      OUT NOCOPY NUMBER,
                              		 x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
	l_upd_optv_rec	 	  	optv_rec_type; /* input copy */
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_ove_count				NUMBER := 0;
	l_ovev_tbl				ovev_tbl_type;
	l_out_ovev_tbl			ovev_tbl_type;

 BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_upd_optv_rec  := p_upd_optv_rec;

	/* Get Option Values */
	get_opt_values(p_upd_optv_rec	  => l_upd_optv_rec,
				   x_return_status    => l_return_status,
				   x_count		      => l_ove_count,
				   x_ovev_tbl		  => l_ovev_tbl);

    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_ove_count > 0 THEN
	      Okl_Options_Pub.update_option_values(p_api_version   => p_api_version,
                           		 		       p_init_msg_list => p_init_msg_list,
                              		 		   x_return_status => l_return_status,
                              		 		   x_msg_count     => x_msg_count,
                              		 		   x_msg_data      => x_msg_data,
                              		 		   p_ovev_tbl      => l_ovev_tbl,
                              		 		   x_ovev_tbl      => l_out_ovev_tbl);
    END IF;

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END copy_update_constraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_options for: OKL_OPTIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_options(p_api_version       IN  NUMBER,
                           p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_optv_rec          IN  optv_rec_type,
                           x_optv_rec          OUT NOCOPY optv_rec_type
                        ) IS
    CURSOR okl_options_unique (p_unique  OKL_OPTIONS_V.NAME%TYPE) IS
    SELECT '1'
       FROM OKL_OPTIONS_V
      WHERE OKL_OPTIONS_V.NAME =  p_unique;

    l_unique_key    OKL_OPTIONS_V.NAME%TYPE;
	l_token_1       VARCHAR2(1999);
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_options';
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_optv_rec		  optv_rec_type;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_optv_rec := p_optv_rec;

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
    l_return_status := Validate_Attributes(l_optv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_OPTIONS');

    --moved from simle api to fix error messages
    OPEN okl_options_unique (Okl_Accounting_Util.okl_upper(p_optv_rec.name));
    FETCH okl_options_unique INTO l_unique_key;
    IF okl_options_unique%FOUND THEN
		  Okl_Api.set_message('OKL','OKL_NOT_UNIQUE', 'OKL_TABLE_NAME',l_token_1);
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      ELSE
          x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_options_unique;

	/* check for the records with start or end dates less than sysdate */
    /*IF to_date(to_char(l_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
    */
	/* public api to create options */
    Okl_Options_Pub.create_options(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => l_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_optv_rec      => l_optv_rec,
                                   x_optv_rec      => x_optv_rec);

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
       IF (okl_options_unique%ISOPEN) THEN
	   	  CLOSE okl_options_unique;
       END IF;

  END insert_options;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_options for: OKL_OPTIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_options(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_optv_rec                     IN  optv_rec_type,
                        	x_optv_rec                     OUT NOCOPY optv_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_options';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
    l_db_optv_rec    	  	optv_rec_type; /* database copy */
	l_upd_optv_rec	 	  	optv_rec_type; /* input copy */
	l_optv_rec	  	 	  	optv_rec_type; /* latest with the retained changes */
	l_tmp_optv_rec			optv_rec_type; /* for any other purposes */
	l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_upd_optv_rec := p_optv_rec;

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

	/* fetch old details from the database */
    get_rec(p_optv_rec 	 	=> l_upd_optv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_optv_rec		=> l_db_optv_rec);
	IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	IF l_upd_optv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
    /* update constraints */
	copy_update_constraints(p_api_version     => p_api_version,
                            p_init_msg_list   => p_init_msg_list,
							p_upd_optv_rec	  => l_upd_optv_rec,
                            x_return_status   => l_return_status,
                    		x_msg_count       => x_msg_count,
                            x_msg_data        => x_msg_data);

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    END IF;

    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_optv_rec     => l_upd_optv_rec,
                      p_db_optv_rec      => l_db_optv_rec);

    /* check for past records */
    /*IF to_date(to_char(l_db_optv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
       to_date(to_char(l_db_optv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
	*/



    IF (l_upd_optv_rec.TO_DATE = Okl_Api.G_MISS_DATE) then
            l_upd_optv_rec.TO_DATE := p_optv_rec.to_date;
     end if;

     IF (l_upd_optv_rec.from_DATE = Okl_Api.G_MISS_DATE) then
         l_upd_optv_rec.from_DATE := p_optv_rec.from_date;
     end if;

	/* To Check end date is > from_date */
	IF (l_upd_optv_rec.TO_DATE IS NOT NULL) AND (l_upd_optv_rec.TO_DATE < l_upd_optv_rec.from_date) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => Okl_Opt_Pvt.g_to_date_error
                          ,p_token1         => Okl_Opt_Pvt.g_col_name_token
                          ,p_token1_value   => 'to_date');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* determine how the processing to be done */
	l_action := determine_action(p_upd_optv_rec	 => l_upd_optv_rec,
			 					 p_db_optv_rec	 => l_db_optv_rec,
								 p_date			 => l_sysdate);

	/* Scenario 1: only changing description and descriptive flexfields */
	IF l_action = '1' THEN
	   /* public api to update options */
       Okl_Options_Pub.update_options(p_api_version   => p_api_version,
                           		 	  p_init_msg_list => p_init_msg_list,
                              		  x_return_status => l_return_status,
                              		  x_msg_count     => x_msg_count,
                              		  x_msg_data      => x_msg_data,
                              		  p_optv_rec      => l_upd_optv_rec,
                              		  x_optv_rec      => x_optv_rec);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 2: changing the dates */
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_optv_rec := defaults_to_actuals(p_upd_optv_rec => l_upd_optv_rec,
	   					  				 p_db_optv_rec  => l_db_optv_rec);

	   check_updates(p_upd_optv_rec	 => l_upd_optv_rec,
	   			     p_db_optv_rec	 => l_db_optv_rec,
					 p_optv_rec		 => l_optv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* public api to update options */
       Okl_Options_Pub.update_options(p_api_version   => p_api_version,
                            		  p_init_msg_list => p_init_msg_list,
                              		  x_return_status => l_return_status,
                              		  x_msg_count     => x_msg_count,
                              		  x_msg_data      => x_msg_data,
                              		  p_optv_rec      => l_upd_optv_rec,
                              		  x_optv_rec      => x_optv_rec);
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

  END update_options;

END Okl_Setupoptions_Pvt;

/
