--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPTRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPTRULES_PVT" AS
/* $Header: OKLRSORB.pls 115.8 2003/07/23 18:33:03 sgorantl noship $ */
G_COLUMN_TOKEN			  CONSTANT VARCHAR2(100) := 'COLUMN';

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OPT_RULES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_orlv_rec                     IN orlv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_orlv_rec					   OUT NOCOPY orlv_rec_type
  ) IS
    CURSOR okl_orlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			OPT_ID,
            NVL(LRG_LSE_ID, Okl_Api.G_MISS_NUM) LRG_LSE_ID,
            NVL(LRG_SRD_ID, Okl_Api.G_MISS_NUM) LRG_SRD_ID,
			NVL(SRD_ID_FOR, Okl_Api.G_MISS_NUM) SRD_ID_FOR,
            RGR_RGD_CODE,
            RGR_RDF_CODE,
			NVL(OVERALL_INSTRUCTIONS,Okl_Api.G_MISS_CHAR) OVERALL_INSTRUCTIONS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Opt_Rules_V
     WHERE okl_Opt_Rules_V.id    = p_id;
    l_okl_orlv_pk                  okl_orlv_pk_csr%ROWTYPE;
    l_orlv_rec                     orlv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_orlv_pk_csr (p_orlv_rec.id);
    FETCH okl_orlv_pk_csr INTO
              l_orlv_rec.ID,
              l_orlv_rec.OBJECT_VERSION_NUMBER,
			  l_orlv_rec.OPT_ID,
              l_orlv_rec.LRG_LSE_ID,
              l_orlv_rec.LRG_SRD_ID,
              l_orlv_rec.SRD_ID_FOR,
              l_orlv_rec.RGR_RGD_CODE,
              l_orlv_rec.RGR_RDF_CODE,
              l_orlv_rec.OVERALL_INSTRUCTIONS,
              l_orlv_rec.CREATED_BY,
              l_orlv_rec.CREATION_DATE,
              l_orlv_rec.LAST_UPDATED_BY,
              l_orlv_rec.LAST_UPDATE_DATE,
              l_orlv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_orlv_pk_csr%NOTFOUND;
    CLOSE okl_orlv_pk_csr;
    x_orlv_rec := l_orlv_rec;
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

      IF (okl_orlv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_orlv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_OPT_RULES_V
  -- To verify whether the dates are valid with respect to options and
  -- to check whether any of these selected rules are attached to option
  -- values
  ---------------------------------------------------------------------------
  PROCEDURE Check_Constraints (
	p_orlv_rec		IN orlv_rec_type,
	x_return_status	OUT NOCOPY VARCHAR2,
    x_valid         OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_orl_pon_fk_csr (p_opt_id    IN Okl_Options_V.ID%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pdt_Opts_V pon
    WHERE pon.OPT_ID    = p_opt_id;

    CURSOR okl_orl_ovd_fk_csr (p_orl_id     IN Okl_Opt_Rules_V.ID%TYPE
	) IS
    SELECT '1'
    FROM Okl_Opv_Rules_V ovd
    WHERE ovd.ORL_ID    = p_orl_id;

    CURSOR okl_orl_opt_fk_csr (p_opt_id    IN Okl_Options_V.ID%TYPE,
                               p_date      IN Okl_Options_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Options_V opt
    WHERE opt.ID    = p_opt_id
    AND   NVL(opt.TO_DATE, p_date) < p_date;

    CURSOR okl_orl_lsr_fk_csr (p_opt_id       IN Okl_Opt_Rules_V.opt_id%TYPE,
                               p_lrg_lse_id   IN Okl_Opt_Rules_V.lrg_lse_id%TYPE,
                               p_lrg_srd_id   IN Okl_Opt_Rules_V.lrg_srd_id%TYPE,
                               p_srd_id_for   IN Okl_Opt_Rules_V.srd_id_for%TYPE,
                               p_rgr_rgd_code IN Okl_Opt_Rules_V.rgr_rgd_code%TYPE,
                               p_rgr_rdf_code IN Okl_Opt_Rules_V.rgr_rdf_code%TYPE
	) IS
	SELECT '1'
    FROM Okl_Lse_Scs_Rules_V lsr,
         Okl_Options_V       opt
    WHERE opt.ID = p_opt_id
    AND  ((p_lrg_lse_id <> Okl_Api.G_MISS_NUM
         AND lsr.LSE_ID = p_lrg_lse_id
         AND lsr.SRD_ID = p_lrg_srd_id)
         OR
         (p_lrg_lse_id = Okl_Api.G_MISS_NUM
         AND lsr.LSE_ID IS NULL
         AND lsr.SRD_ID = p_srd_id_for))
    AND lsr.RULE_GROUP = p_rgr_rgd_code
    AND lsr.RULE = p_rgr_rdf_code
    AND (lsr.START_DATE > opt.FROM_DATE OR
	     NVL(lsr.END_DATE, NVL(opt.TO_DATE, Okl_Api.G_MISS_DATE)) < NVL(opt.TO_DATE, Okl_Api.G_MISS_DATE));

 CURSOR c1(p_opt_id okl_opt_rules_v.opt_id%TYPE,
		p_rgr_rgd_code okl_opt_rules_v.rgr_rgd_code%TYPE,
            p_rgr_rdf_code okl_opt_rules_v.rgr_rdf_code%TYPE,
		p_srd_id_for okl_opt_rules_v.srd_id_for%TYPE) IS
  SELECT '1'
  FROM okl_opt_rules_v
  WHERE  opt_id = p_opt_id
  AND    rgr_rgd_code = p_rgr_rgd_code
  AND	   rgr_rdf_code = rgr_rdf_code
  AND    srd_id_for = p_srd_id_for
  AND id <> NVL(p_orlv_rec.id,-9999);

  CURSOR c2(p_opt_id okl_opt_rules_v.opt_id%TYPE,
		p_rgr_rgd_code okl_opt_rules_v.rgr_rgd_code%TYPE,
            p_rgr_rdf_code okl_opt_rules_v.rgr_rdf_code%TYPE,
            p_lrg_lse_id okl_opt_rules_v.lrg_lse_id%TYPE,
		p_lrg_srd_id okl_opt_rules_v.lrg_srd_id%TYPE) IS
  SELECT '1'
  FROM okl_opt_rules_v
  WHERE  opt_id = p_opt_id
  AND    rgr_rgd_code = p_rgr_rgd_code
  AND	   rgr_rdf_code = rgr_rdf_code
  AND    lrg_lse_id = p_lrg_lse_id
  AND    lrg_srd_id = p_lrg_srd_id
  AND id <> NVL(p_orlv_rec.id,-9999);

    l_orlv_rec      orlv_rec_type;
	l_check		   	VARCHAR2(1) := '?';
    l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_row_not_found	BOOLEAN := FALSE;
	l_unq_tbl       Okc_Util.unq_tbl_type;
    l_orl_status    VARCHAR2(1);
    l_row_found     BOOLEAN := FALSE;
    l_token_1       VARCHAR2(1999);
    l_token_2       VARCHAR2(1999);
    l_token_3       VARCHAR2(1999);
    l_token_4       VARCHAR2(1999);
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_RULE_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_RULES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_OPTIONS');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPT_VAL_RULE_SUMRY',
                                                           p_attribute_code => 'OKL_OPTION_VALUE_RULES');


    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPT_VAL_RULE_SUMRY',
                                                           p_attribute_code => 'OKL_RULE');

	-- Check for related products being used by contracts
    OPEN okl_orl_pon_fk_csr (p_orlv_rec.opt_id);
    FETCH okl_orl_pon_fk_csr INTO l_check;
    l_row_not_found := okl_orl_pon_fk_csr%NOTFOUND;
    CLOSE okl_orl_pon_fk_csr;

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

	-- Check if the option to which the rules are added is not
    -- in the past
    /*OPEN okl_orl_opt_fk_csr (p_orlv_rec.opt_id,
                             l_sysdate);
    FETCH okl_orl_opt_fk_csr INTO l_check;
    l_row_not_found := okl_orl_opt_fk_csr%NOTFOUND;
    CLOSE okl_orl_opt_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_PAST_RECORDS);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;*/

	-- Check for option value rules
    IF p_orlv_rec.id <> Okl_Api.G_MISS_NUM THEN
       OPEN okl_orl_ovd_fk_csr (p_orlv_rec.id);
       FETCH okl_orl_ovd_fk_csr INTO l_check;
       l_row_not_found := okl_orl_ovd_fk_csr%NOTFOUND;
       CLOSE okl_orl_ovd_fk_csr;

       IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name   => G_APP_NAME,
						   p_msg_name	   => G_IN_USE,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_1,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_3);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
  	      RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
    END IF;
  IF p_orlv_rec.id = Okl_Api.G_MISS_NUM THEN
    -- check for unique record
    IF (p_orlv_rec.srd_id_for IS NOT NULL) THEN
    	OPEN c1(p_orlv_rec.opt_id,
	      p_orlv_rec.rgr_rgd_code,
 		p_orlv_rec.rgr_rdf_code,
		p_orlv_rec.srd_id_for);
    	FETCH c1 INTO l_orl_status;
    	l_row_found := c1%FOUND;
    	CLOSE c1;
    	IF l_row_found THEN
                 Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
				     p_msg_name	    => 'OKL_COLUMN_NOT_UNIQUE',
				     p_token1	    => G_TABLE_TOKEN,
				     p_token1_value => l_token_1,
				     p_token2	    => G_COLUMN_TOKEN,
				     p_token2_value => l_token_4);

/*		--Okl_Api.set_message('OKL','OKL_COLUMN_NOT_UNIQUE',             'OKL_TABLE_NAME',l_token_1,Okl_Ovd_Pvt.G_COL_NAME_TOKEN,l_token_3);

		--Okl_Api.set_message(G_APP_NAME,'OKL_COLUMN_NOT_UNIQUE',G_TABLE_TOKEN, l_token_1,Okl_Ovd_Pvt.G_COL_NAME_TOKEN,l_token_4); ---CHG001
*/
        x_valid := FALSE;
        x_return_status := Okl_Api.G_RET_STS_ERROR;
  	    RAISE G_EXCEPTION_HALT_PROCESSING;
     	END IF;
    ELSE
    	OPEN c2(p_orlv_rec.opt_id,
	      p_orlv_rec.rgr_rgd_code,
 		p_orlv_rec.rgr_rdf_code,
		p_orlv_rec.lrg_lse_id,
		p_orlv_rec.lrg_srd_id);
    	FETCH c2 INTO l_orl_status;
    	l_row_found := c2%FOUND;
    	CLOSE c2;
    	IF l_row_found THEN
		 Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
				     p_msg_name	    => 'OKL_COLUMN_NOT_UNIQUE',
				     p_token1	    => G_TABLE_TOKEN,
				     p_token1_value => l_token_1,
				     p_token2	    => G_COLUMN_TOKEN,
				     p_token2_value => l_token_4);
  	    x_valid := FALSE;
        x_return_status := Okl_Api.G_RET_STS_ERROR;
  	    RAISE G_EXCEPTION_HALT_PROCESSING;
     	END IF;
    END IF;
   END IF;
    -- Check for rules dates
    IF p_orlv_rec.id = Okl_Api.G_MISS_NUM THEN
       OPEN okl_orl_lsr_fk_csr (p_orlv_rec.opt_id,
                                p_orlv_rec.lrg_lse_id,
                                p_orlv_rec.lrg_srd_id,
                                p_orlv_rec.srd_id_for,
                                p_orlv_rec.rgr_rgd_code,
                                p_orlv_rec.rgr_rdf_code);
       FETCH okl_orl_lsr_fk_csr INTO l_check;
       l_row_not_found := okl_orl_lsr_fk_csr%NOTFOUND;
       CLOSE okl_orl_lsr_fk_csr;

       IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name      => G_APP_NAME,
						      p_msg_name	  => G_DATES_MISMATCH,
						      p_token1		  => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		  => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_3);
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

       IF (okl_orl_pon_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_orl_pon_fk_csr;
       END IF;

       IF (okl_orl_opt_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_orl_opt_fk_csr;
       END IF;

       IF (okl_orl_ovd_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_orl_ovd_fk_csr;
       END IF;

       IF (okl_orl_lsr_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_orl_lsr_fk_csr;
       END IF;

	    IF (C1%ISOPEN) THEN
	   	  CLOSE C1;
       END IF;

	    IF (C1%ISOPEN) THEN
	   	  CLOSE C2;
       END IF;

  END Check_Constraints;

 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rgr_Rdf_Code
  ---------------------------------------------------------------------------
  -- Procedure Name  : Validate_Rgr_Rdf_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
 ---------------------------------------------------------------------------
  PROCEDURE Validate_Rgr_Rdf_Code(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_token_1       VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPT_VAL_RULE_SUMRY',
                                                       p_attribute_code => 'OKL_RULE');

    -- check for data before processing
    IF (p_orlv_rec.rgr_rdf_code IS NULL) OR
       (p_orlv_rec.rgr_rdf_code = Okl_Api.G_MISS_CHAR) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Orl_Pvt.g_app_name
                          ,p_msg_name       => Okl_Orl_Pvt.g_required_value
                          ,p_token1         => Okl_Orl_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
    RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Orl_Pvt.g_app_name,
                          p_msg_name     => Okl_Orl_Pvt.g_unexpected_error,
                          p_token1       => Okl_Orl_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Orl_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Rgr_Rdf_Code;

 ---------------------------------------------------------------------------
  -- FUNCTION Validate_Foreign_Keys
  ---------------------------------------------------------------------------
  -- Function Name   : Validate_Foreign_Keys
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
 ---------------------------------------------------------------------------
   FUNCTION Validate_Attributes (
    p_orlv_rec IN  orlv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Rgr_Rdf_Code
    Validate_Rgr_Rdf_Code(p_orlv_rec, x_return_status);

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
       Okl_Api.SET_MESSAGE(p_app_name         => Okl_Orl_Pvt.g_app_name,
                           p_msg_name         => Okl_Orl_Pvt.g_unexpected_error,
                           p_token1           => Okl_Orl_Pvt.g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => Okl_Orl_Pvt.g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_optrules for: OKL_OPT_RULES_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_optrules(p_api_version    IN  NUMBER,
                        	p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status  OUT NOCOPY VARCHAR2,
                        	x_msg_count      OUT NOCOPY NUMBER,
                        	x_msg_data       OUT NOCOPY VARCHAR2,
                            p_optv_rec       IN  optv_rec_type,
                        	p_orlv_rec       IN  orlv_rec_type,
                        	x_orlv_rec       OUT NOCOPY orlv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_optrules';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_orlv_rec		  orlv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_orlv_rec := p_orlv_rec;
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

    l_return_status := Validate_Attributes(l_orlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* call check_constraints to check the validity of this relationship */
	Check_Constraints(p_orlv_rec 		=> l_orlv_rec,
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

	/* public api to insert option rules */
    Okl_Option_Rules_Pub.create_option_rules(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 	   	 x_return_status => l_return_status,
                              		 	   	 x_msg_count     => x_msg_count,
                              		 	   	 x_msg_data      => x_msg_data,
                              		 	   	 p_orlv_rec      => l_orlv_rec,
                              		 	   	 x_orlv_rec      => x_orlv_rec);

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

  END insert_optrules;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_optrules for: OKL_OPT_RULES_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_optrules(p_api_version          IN  NUMBER,
                            p_init_msg_list        IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status        OUT NOCOPY VARCHAR2,
                        	x_msg_count            OUT NOCOPY NUMBER,
                        	x_msg_data             OUT NOCOPY VARCHAR2,
                            p_optv_rec             IN  optv_rec_type,
                        	p_orlv_tbl             IN  orlv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_orlv_tbl        orlv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_optrules';
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

	l_orlv_tbl := p_orlv_tbl;
    IF (l_orlv_tbl.COUNT > 0) THEN
      i := l_orlv_tbl.FIRST;
      LOOP
	  	  Check_Constraints(p_orlv_rec 		=> l_orlv_tbl(i),
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

          EXIT WHEN (i = l_orlv_tbl.LAST);

          i := l_orlv_tbl.NEXT(i);

       END LOOP;
	 END IF;

	/* delete option rules */
    Okl_Option_Rules_Pub.delete_option_rules(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 		 x_return_status => l_return_status,
                              		 		 x_msg_count     => x_msg_count,
                              		 		 x_msg_data      => x_msg_data,
                              		 		 p_orlv_tbl      => l_orlv_tbl);

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

  END delete_optrules;

END Okl_Setupoptrules_Pvt;

/
