--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOVDTEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOVDTEMPLATES_PVT" AS
/* $Header: OKLRSVTB.pls 115.8 2003/10/15 23:26:30 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OVD_RUL_TMLS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_ovtv_rec                     IN ovtv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ovtv_rec					   OUT NOCOPY ovtv_rec_type
  ) IS
    CURSOR okl_ovtv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			OVD_ID,
            RUL_ID,
            SEQUENCE_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Ovd_Rul_Tmls_V
     WHERE Okl_Ovd_Rul_Tmls_V.id    = p_id;
    l_okl_ovtv_pk                  okl_ovtv_pk_csr%ROWTYPE;
    l_ovtv_rec                     ovtv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_ovtv_pk_csr (p_ovtv_rec.id);
    FETCH okl_ovtv_pk_csr INTO
              l_ovtv_rec.ID,
              l_ovtv_rec.OBJECT_VERSION_NUMBER,
			  l_ovtv_rec.OVD_ID,
              l_ovtv_rec.RUL_ID,
              l_ovtv_rec.SEQUENCE_NUMBER,
              l_ovtv_rec.CREATED_BY,
              l_ovtv_rec.CREATION_DATE,
              l_ovtv_rec.LAST_UPDATED_BY,
              l_ovtv_rec.LAST_UPDATE_DATE,
              l_ovtv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ovtv_pk_csr%NOTFOUND;
    CLOSE okl_ovtv_pk_csr;
    x_ovtv_rec := l_ovtv_rec;
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

      IF (okl_ovtv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovtv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE verify_context for: OKL_OVD_RUL_TMLS_V
  ---------------------------------------------------------------------------
  FUNCTION verify_context (
    p_org_id                       IN NUMBER,
    p_inv_org_id                   IN NUMBER,
    p_book_type_code               IN VARCHAR2,
    p_context_org                  IN NUMBER,
    p_context_inv_org              IN NUMBER,
    p_context_asset_book           IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status           VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    IF p_context_org <> Okl_Api.G_MISS_NUM AND
       p_org_id <> p_context_org THEN
	   Okl_Api.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_CONTEXT_MISMATCH,
						   p_token1		  => G_CONTEXT_TOKEN,
						   p_token1_value  => 'Context_Org_Id');
       l_return_status := Okl_Api.G_RET_STS_ERROR;
       RETURN(l_return_status);
    END IF;
    IF p_context_inv_org <> Okl_Api.G_MISS_NUM AND
       p_inv_org_id <> p_context_inv_org THEN
	   Okl_Api.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_CONTEXT_MISMATCH,
						   p_token1		  => G_CONTEXT_TOKEN,
						   p_token1_value  => 'Context_Inv_Org_Id');
       l_return_status := Okl_Api.G_RET_STS_ERROR;
       RETURN(l_return_status);
    END IF;
    IF p_context_asset_book <> Okl_Api.G_MISS_CHAR AND
       p_book_type_code <> p_context_asset_book THEN
	   Okl_Api.SET_MESSAGE(p_app_name	  => G_APP_NAME,
				           p_msg_name	  => G_CONTEXT_MISMATCH,
						   p_token1		  => G_CONTEXT_TOKEN,
						   p_token1_value  => 'Context_Book_Type_Code');
       l_return_status := Okl_Api.G_RET_STS_ERROR;
       RETURN(l_return_status);
    END IF;
    RETURN(l_return_status);
  END verify_context;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_OVD_RUL_TMLS_V
  -- To verify whether an addition of new option value rule template
  -- is ok with rest of the product - contract relationships
  ---------------------------------------------------------------------------
  PROCEDURE check_constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,	p_ovtv_rec		IN ovtv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_ovt_csp_fk_csr (p_ovd_id    IN Okl_Opv_Rules_V.ID%TYPE
	) IS
    SELECT '1'
    FROM Okl_Opv_Rules_V ovd,
         Okl_Pdt_Opt_Vals_V pov,
         Okl_Slctd_Optns_V csp
    WHERE ovd.ID        = p_ovd_id
    AND   pov.OVE_ID    = ovd.OVE_ID
    AND   csp.POV_ID    = pov.ID;

    CURSOR okl_ovt_lsr_fk_csr (p_ovd_id   IN Okl_Opv_Rules_V.ID%TYPE
	) IS
	SELECT orl.RGR_RGD_CODE RGR_RGD_CODE,
           orl.RGR_RDF_CODE RGR_RDF_CODE,
           NVL(ovd.CONTEXT_INTENT, Okl_Api.G_MISS_CHAR) CONTEXT_INTENT,
           NVL(ovd.CONTEXT_ORG, Okl_Api.G_MISS_NUM) CONTEXT_ORG,
           NVL(ovd.CONTEXT_INV_ORG, Okl_Api.G_MISS_NUM) CONTEXT_INV_ORG,
           NVL(ovd.CONTEXT_ASSET_BOOK, Okl_Api.G_MISS_CHAR) CONTEXT_ASSET_BOOK,
           ove.FROM_DATE FROM_DATE,
           NVL(ove.TO_DATE, Okl_Api.G_MISS_DATE) TO_DATE
    FROM Okl_Opv_Rules_V ovd,
         Okl_Opt_Rules_V orl,
         Okl_Opt_Values_V ove
    WHERE ovd.ID     = p_ovd_id
    AND   orl.ID     = ovd.ORL_ID
    AND   ove.ID     = ovd.OVE_ID;

    CURSOR okl_ovt_rds_fk_csr (p_rgd_code         IN Okc_Rule_Def_Sources_V.rgr_rgd_code%TYPE,
                               p_rdf_code         IN Okc_Rule_Def_Sources_V.rgr_rdf_code%TYPE,
                               p_buy_or_sell      IN Okc_Rule_Def_Sources_V.buy_or_sell%TYPE,
                               p_jtot_object_code IN Okc_Rule_Def_Sources_V.jtot_object_code%TYPE,
                               p_object_id_number IN Okc_Rule_Def_Sources_V.object_id_number%TYPE,
                               p_from_date        IN Okl_Opt_Values_V.from_date%TYPE,
                               p_to_date          IN Okl_Opt_Values_V.TO_DATE%TYPE
	) IS
	SELECT '1'
    FROM Okc_Rule_Def_Sources_V  rds
    WHERE rds.RGR_RGD_CODE = p_rgd_code
    AND   rds.RGR_RDF_CODE = p_rdf_code
    AND   rds.OBJECT_ID_NUMBER = p_object_id_number
    AND   rds.JTOT_OBJECT_CODE = p_jtot_object_code
    AND   rds.BUY_OR_SELL = p_buy_or_sell
    AND (rds.START_DATE > p_from_date OR
         NVL(rds.END_DATE, Okl_Api.G_MISS_DATE) < p_to_date);

	l_check		   	          VARCHAR2(1) := '?';
    l_sysdate                 DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY') , 'DD/MM/YYYY');
	l_row_not_found	          BOOLEAN := FALSE;
    l_rulv_rec                rulv_rec_type;
    l_return_status           VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
    l_no_data_found           BOOLEAN := FALSE;
    l_object_id_number        NUMBER := 0;
    l_rule                    VARCHAR2(30);
    l_rulegroup               VARCHAR2(30);
    l_context_org             NUMBER := 0;
    l_context_inv_org         NUMBER := 0;
    l_context_asset_book      VARCHAR2(10);
    l_context_intent          VARCHAR2(30);
    l_from_date               DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_to_date                 DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_jtot_object_code        VARCHAR2(30);
    l_okx_start_date          DATE;
    l_okx_end_date            DATE;
    l_rulv_disp_rec           rulv_disp_rec_type;
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Check if the option value is already in use with a contract
    OPEN okl_ovt_csp_fk_csr (p_ovtv_rec.ovd_id);
    FETCH okl_ovt_csp_fk_csr INTO l_check;
    l_row_not_found := okl_ovt_csp_fk_csr%NOTFOUND;
    CLOSE okl_ovt_csp_fk_csr;

    IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_IN_USE,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => 'Okl_Ovd_Rul_Tmls_V',
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => 'Okl_Slctd_Optns_V');
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF p_ovtv_rec.id = Okl_Api.G_MISS_NUM THEN
       l_rulv_rec.id := p_ovtv_rec.rul_id;
       Okl_Setupoptvalues_Pvt.get_rul_rec (p_rulv_rec      => l_rulv_rec,
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

       -- Fetch all the details for the option value rule for which this
       -- template is being attached
       OPEN okl_ovt_lsr_fk_csr (p_ovtv_rec.ovd_id);
       FETCH okl_ovt_lsr_fk_csr
       INTO l_rulegroup,
            l_rule,
            l_context_intent,
            l_context_org,
            l_context_inv_org,
            l_context_asset_book,
            l_from_date,
            l_to_date;
       l_row_not_found := okl_ovt_lsr_fk_csr%NOTFOUND;
       CLOSE okl_ovt_lsr_fk_csr;

       IF l_row_not_found = TRUE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_MISS_DATA);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
	      RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;

      --IF l_rulv_rec.rule_information_category <> l_rule OR
        --l_rulv_rec.template_yn <> 'Y' THEN

       IF l_rulv_rec.rule_information_category <> l_rule THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_RULE_MISMATCH);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
	    RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;

	   --END IF;

       FOR l_object_id_number IN 1..3
       LOOP
           l_jtot_object_code := Okl_Api.G_MISS_CHAR;
           l_okx_start_date := Okl_Api.G_MISS_DATE;
           l_okx_end_date := Okl_Api.G_MISS_DATE;
           IF l_object_id_number = 1 AND l_rulv_rec.jtot_object1_code <> Okl_Api.G_MISS_CHAR THEN
              l_jtot_object_code := l_rulv_rec.jtot_object1_code;
              l_okx_start_date := l_rulv_disp_rec.obj1_start_date;
              l_okx_end_date := l_rulv_disp_rec.obj1_end_date;
              l_return_status := verify_context(p_org_id              => l_rulv_disp_rec.obj1_org_id,
                                                p_inv_org_id          => l_rulv_disp_rec.obj1_inv_org_id,
                                                p_book_type_code      => l_rulv_disp_rec.obj1_book_type_code,
                                                p_context_org         => l_context_org,
                                                p_context_inv_org     => l_context_inv_org,
                                                p_context_asset_book  => l_context_asset_book);
              IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	             x_valid := FALSE;
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
	             RAISE G_EXCEPTION_HALT_PROCESSING;
              END IF;
           ELSIF l_object_id_number = 2 AND l_rulv_rec.jtot_object2_code <> Okl_Api.G_MISS_CHAR THEN
              l_jtot_object_code := l_rulv_rec.jtot_object2_code;
              l_okx_start_date := l_rulv_disp_rec.obj2_start_date;
              l_okx_end_date := l_rulv_disp_rec.obj2_end_date;
              l_return_status := verify_context(p_org_id              => l_rulv_disp_rec.obj2_org_id,
                                                p_inv_org_id          => l_rulv_disp_rec.obj2_inv_org_id,
                                                p_book_type_code      => l_rulv_disp_rec.obj2_book_type_code,
                                                p_context_org         => l_context_org,
                                                p_context_inv_org     => l_context_inv_org,
                                                p_context_asset_book  => l_context_asset_book);
              IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	             x_valid := FALSE;
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
	             RAISE G_EXCEPTION_HALT_PROCESSING;
              END IF;
           ELSIF l_object_id_number = 3 AND l_rulv_rec.jtot_object3_code <> Okl_Api.G_MISS_CHAR THEN
              l_jtot_object_code := l_rulv_rec.jtot_object3_code;
              l_okx_start_date := l_rulv_disp_rec.obj3_start_date;
              l_okx_end_date := l_rulv_disp_rec.obj3_end_date;
              l_return_status := verify_context(p_org_id              => l_rulv_disp_rec.obj3_org_id,
                                                p_inv_org_id          => l_rulv_disp_rec.obj3_inv_org_id,
                                                p_book_type_code      => l_rulv_disp_rec.obj3_book_type_code,
                                                p_context_org         => l_context_org,
                                                p_context_inv_org     => l_context_inv_org,
                                                p_context_asset_book  => l_context_asset_book);
              IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	             x_valid := FALSE;
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
	             RAISE G_EXCEPTION_HALT_PROCESSING;
              END IF;
           END IF;

           IF l_jtot_object_code <> Okl_Api.G_MISS_CHAR AND
              (l_okx_start_date > l_from_date OR
              NVL(l_okx_end_date, Okl_Api.G_MISS_DATE) < l_to_date OR
              l_from_date > l_to_date) THEN
              Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
				                  p_msg_name	   => G_DATES_MISMATCH,
						          p_token1		   => G_PARENT_TABLE_TOKEN,
						          p_token1_value  => 'Okl_Opt_Values_V',
						          p_token2		   => G_CHILD_TABLE_TOKEN,
						          p_token2_value  => 'Okc_Rules_b');
	          x_valid := FALSE;
              x_return_status := Okl_Api.G_RET_STS_ERROR;
	          RAISE G_EXCEPTION_HALT_PROCESSING;
           END IF;

           IF l_jtot_object_code <> Okl_Api.G_MISS_CHAR THEN
              -- Check for dates in source, okx and option value
              OPEN okl_ovt_rds_fk_csr (p_rgd_code         => l_rulegroup,
                                       p_rdf_code         => l_rule,
                                       p_buy_or_sell      => l_context_intent,
                                       p_jtot_object_code => l_jtot_object_code,
                                       p_object_id_number => l_object_id_number,
                                       p_from_date        => l_from_date,
                                       p_to_date          => l_to_date);
              FETCH okl_ovt_rds_fk_csr INTO l_check;
              l_no_data_found := okl_ovt_rds_fk_csr%NOTFOUND;
              CLOSE okl_ovt_rds_fk_csr;

              IF l_no_data_found = FALSE THEN
	             Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
				                     p_msg_name	   => G_DATES_MISMATCH,
						             p_token1		   => G_PARENT_TABLE_TOKEN,
						             p_token1_value  => 'Okl_Ovd_Rul_Tmls_V',
						             p_token2		   => G_CHILD_TABLE_TOKEN,
						             p_token2_value  => 'Okc_Rule_Def_Sources_V');
	             x_valid := FALSE;
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
	             RAISE G_EXCEPTION_HALT_PROCESSING;
              END IF;
           END IF;

       END LOOP;

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

       IF (okl_ovt_csp_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovt_csp_fk_csr;
       END IF;

       IF (okl_ovt_lsr_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovt_lsr_fk_csr;
       END IF;

       IF (okl_ovt_rds_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ovt_rds_fk_csr;
       END IF;

  END check_constraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_ovdtemplates for: OKL_OVD_RUL_TMLS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_ovdtemplates(p_api_version    IN  NUMBER,
                        	        p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	        x_return_status  OUT NOCOPY VARCHAR2,
                        	        x_msg_count      OUT NOCOPY NUMBER,
                        	        x_msg_data       OUT NOCOPY VARCHAR2,
                                    p_optv_rec       IN  optv_rec_type,
                        	        p_ovev_rec       IN  ovev_rec_type,
                                    p_ovdv_rec       IN  ovdv_rec_type,
                                    p_ovtv_rec       IN  ovtv_rec_type,
                        	        x_ovtv_rec       OUT NOCOPY ovtv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_ovdtemplates';
    l_return_status   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_ovtv_rec		  ovtv_rec_type;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status := Okc_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

	l_ovtv_rec := p_ovtv_rec;

	/* call check_constraints to check the validity of this relationship */
	check_constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_ovtv_rec 		=> l_ovtv_rec,
				   	  x_return_status	=> l_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
				   	  x_valid			=> l_valid);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

	/* public api to insert option value rule templates */
    Okl_Ovd_Rul_Tmls_Pub.insert_ovd_rul_tmls(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 	   	 x_return_status => l_return_status,
                              		 	   	 x_msg_count     => x_msg_count,
                              		 	   	 x_msg_data      => x_msg_data,
                              		 	   	 p_ovtv_rec      => l_ovtv_rec,
                              		 	   	 x_ovtv_rec      => x_ovtv_rec);

     IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    Okc_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END insert_ovdtemplates;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_ovdtemplates for: OKL_OVD_RUL_TMLS_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_ovdtemplates(p_api_version          IN  NUMBER,
                                    p_init_msg_list        IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	        x_return_status        OUT NOCOPY VARCHAR2,
                        	        x_msg_count            OUT NOCOPY NUMBER,
                        	        x_msg_data             OUT NOCOPY VARCHAR2,
                                    p_optv_rec             IN  optv_rec_type,
                                    p_ovev_rec             IN  ovev_rec_type,
                        	        p_ovdv_rec             IN  ovdv_rec_type,
                                    p_ovtv_tbl             IN  ovtv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_ovtv_tbl        ovtv_tbl_type;
    l_db_ovtv_rec     ovtv_rec_type;
    l_rulv_tbl        Okl_Rule_Pub.rulv_tbl_type;
    l_no_data_found   BOOLEAN := TRUE;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_ovdtemplates';
    l_return_status   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status  VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
    l_valid	      BOOLEAN;
    i                 NUMBER;


  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status := Okc_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

	l_ovtv_tbl := p_ovtv_tbl;
    IF (l_ovtv_tbl.COUNT > 0) THEN
      i := l_ovtv_tbl.FIRST;
      LOOP
	      check_constraints(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            p_ovtv_rec 		=> l_ovtv_tbl(i),
				   	        x_return_status	=> l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
				   	        x_valid			=> l_valid);
		  -- store the highest degree of error
		  IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := l_return_status;
			 END IF;
		  END IF;


             /* fetch old details from the database */
             get_rec(p_ovtv_rec 	  => l_ovtv_tbl(i),
		             x_return_status => l_return_status,
			         x_no_data_found => l_no_data_found,
    		         x_ovtv_rec	  => l_db_ovtv_rec);

	          IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
 	             l_no_data_found = TRUE THEN
	             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	          END IF;

                 l_rulv_tbl(i).id := l_db_ovtv_rec.rul_id;

                 Okl_Rule_Pub.delete_rule(p_api_version   => p_api_version
                                        ,p_init_msg_list  => p_init_msg_list
                                        ,x_return_status  => x_return_status
                                        ,x_msg_count      => x_msg_count
                                        ,x_msg_data       => x_msg_data
                                        ,p_rulv_rec       => l_rulv_tbl(i)
                                        );

		-- TCHGS: Store the highest degree of error
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;

          EXIT WHEN (i = l_ovtv_tbl.LAST);

          i := l_ovtv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

	/* public api to delete option value rules */
    Okl_Ovd_Rul_Tmls_Pub.delete_ovd_rul_tmls(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 		 x_return_status => l_return_status,
                              		 		 x_msg_count     => x_msg_count,
                              		 		 x_msg_data      => x_msg_data,
                              		 		 p_ovtv_tbl      => l_ovtv_tbl);

     IF l_return_status = Okc_Api.G_RET_STS_ERROR THEN
        RAISE Okc_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    Okc_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END delete_ovdtemplates;

END Okl_Setupovdtemplates_Pvt;

/
