--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPOPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPOPTIONS_PVT" AS
/* $Header: OKLRSPOB.pls 115.14 2003/07/23 18:36:47 sgorantl noship $ */

G_TABLE_TOKEN                 CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001
G_UNQS	                      CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE'; --- CHG001
G_COLUMN_TOKEN			  CONSTANT VARCHAR2(100) := 'COLUMN';
G_ITEM_NOT_FOUND_ERROR        EXCEPTION;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PDT_OPTS_V
 ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_ponv_rec                     IN  ponv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_ponv_rec					   OUT NOCOPY ponv_rec_type
  ) IS
    CURSOR okl_ponv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OPT_ID,
            PDT_ID,
            FROM_DATE,
            TO_DATE,
            OPTIONAL_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Opts_V
     WHERE okl_pdt_opts_v.id = p_id;
    l_okl_ponv_pk                  okl_ponv_pk_csr%ROWTYPE;
    l_ponv_rec                     ponv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ponv_pk_csr (p_ponv_rec.id);
    FETCH okl_ponv_pk_csr INTO
              l_ponv_rec.ID,
              l_ponv_rec.OBJECT_VERSION_NUMBER,
              l_ponv_rec.OPT_ID,
              l_ponv_rec.PDT_ID,
              l_ponv_rec.FROM_DATE,
              l_ponv_rec.TO_DATE,
              l_ponv_rec.OPTIONAL_YN,
              l_ponv_rec.CREATED_BY,
              l_ponv_rec.CREATION_DATE,
              l_ponv_rec.LAST_UPDATED_BY,
              l_ponv_rec.LAST_UPDATE_DATE,
              l_ponv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ponv_pk_csr%NOTFOUND;
    CLOSE okl_ponv_pk_csr;
	x_ponv_rec := l_ponv_rec;
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

      IF (okl_ponv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ponv_pk_csr;
      END IF;

  END get_rec;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_parent_dates for: OKL_PDT_OPTS_V
 ---------------------------------------------------------------------------

 PROCEDURE get_parent_dates(
    p_ponv_rec                     IN  ponv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_pdtv_rec					   OUT NOCOPY pdtv_rec_type
  ) IS
    CURSOR okl_pdt_pk_csr (p_pdt_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_products_V pdtv
     WHERE pdtv.id = p_pdt_id;
    l_okl_pdtv_pk                  okl_pdt_pk_csr%ROWTYPE;
    l_pdtv_rec                     pdtv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pdt_pk_csr (p_ponv_rec.pdt_id);
    FETCH okl_pdt_pk_csr INTO
              l_pdtv_rec.FROM_DATE,
              l_pdtv_rec.TO_DATE;
    x_no_data_found := okl_pdt_pk_csr%NOTFOUND;
    CLOSE okl_pdt_pk_csr;
    x_pdtv_rec := l_pdtv_rec;
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

      IF (okl_pdt_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pdt_pk_csr;
      END IF;

 END get_parent_dates;

 -----------------------------------------------------------------------------
 -- PROCEDURE check_constraints for: OKL_PDT_OPTS_V
 -----------------------------------------------------------------------------

 PROCEDURE Check_Constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	p_ponv_rec		 IN ponv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS
   CURSOR okl_ponv_chk_upd(p_pdt_id  NUMBER
   ) IS
   SELECT '1' FROM okl_k_headers_v khdr
   WHERE khdr.pdt_id = p_pdt_id;

   CURSOR okl_pon_pdt_fk_csr (p_pdt_id    IN Okl_Products_V.ID%TYPE,
                              p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_products_V pdt
    WHERE pdt.ID    = p_pdt_id
    AND   NVL(pdt.TO_DATE, p_date) < p_date;

	CURSOR okl_pon_constraints_csr(p_opt_id     IN Okl_Options_V.ID%TYPE,
		   					        p_from_date  IN Okl_Options_V.FROM_DATE%TYPE,
							        p_to_date 	 IN Okl_Options_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_options_V opt
     WHERE opt.ID    = p_opt_id
	 AND   ((opt.FROM_DATE > p_from_date OR
            p_from_date > NVL(opt.TO_DATE,p_from_date)) OR
	 	    NVL(opt.TO_DATE, p_to_date) < p_to_date);

	CURSOR get_opt_ruls(p_opt_id  NUMBER
	) IS
    SELECT opt_id,rgr_rdf_code,
           lrg_lse_id,rgr_rgd_code,
		   srd_id_for,lrg_srd_id
    FROM okl_opt_rules
    WHERE opt_id = p_opt_id;

    CURSOR get_pdt_ruls(p_pdt_id  NUMBER
	) IS
    SELECT pon.pdt_id,pon.opt_id,
           orl.rgr_rdf_code,orl.lrg_lse_id,
		   orl.rgr_rgd_code,orl.srd_id_for,
		   orl.lrg_srd_id
    FROM okl_pdt_opts pon,
       okl_opt_rules orl
    WHERE pon.opt_id = orl.opt_id
    AND   pon.pdt_id = p_pdt_id;

   CURSOR okl_pdt_opts_unique (p_unique1  OKL_PDT_OPTS.OPT_ID%TYPE, p_unique2  OKL_PDT_OPTS.PDT_ID%TYPE) IS
    SELECT '1'
       FROM OKL_PDT_OPTS_V
      WHERE OKL_PDT_OPTS_V.OPT_ID =  p_unique1 AND
            OKL_PDT_OPTS_V.PDT_ID =  p_unique2 AND
            OKL_PDT_OPTS_V.ID <> NVL(p_ponv_rec.id,-9999);

  l_unique_key    OKL_PDT_OPTS_V.OPT_ID%TYPE;
  l_check		  VARCHAR2(1) := '?';
  l_row_not_found BOOLEAN     := FALSE;
  l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/RRRR'), 'DD/MM/RRRR');
  l_token_1       VARCHAR2(9999);
  l_token_2       VARCHAR2(9999);
  l_token_3      VARCHAR2(9999);
  l_token_4       VARCHAR2(9999);
  l_token_5       VARCHAR2(9999);
  l_token_6       VARCHAR2(9999);

 BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_OPTIONS');


    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCTS');

    l_token_3 := l_token_1 ||','||l_token_2;


    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_OPTIONS');


    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
                                                      p_attribute_code => 'OKL_KDTLS_CONTRACT');

    l_token_6 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_CRUPD',
                                                      p_attribute_code => 'OKL_OPTION');


    -- Check for pqvv valid dates
    OPEN okl_ponv_chk_upd(p_ponv_rec.pdt_id);

    FETCH okl_ponv_chk_upd INTO l_check;
    l_row_not_found := okl_ponv_chk_upd%NOTFOUND;
    CLOSE okl_ponv_chk_upd;


    IF l_row_not_found = FALSE THEN
	   	 Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
				      p_msg_name	   => G_IN_USE,
				      p_token1		   => G_PARENT_TABLE_TOKEN,
				      p_token1_value  => l_token_1,
				      p_token2		   => G_CHILD_TABLE_TOKEN,
				      p_token2_value  => l_token_5);
     	      x_valid := FALSE;
              x_return_status := Okl_Api.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    -- Check if the product to which the option are added is not
    -- in the past
    /*OPEN okl_pon_pdt_fk_csr (p_ponv_rec.pdt_id,
                             l_sysdate);
    FETCH okl_pon_pdt_fk_csr INTO l_check;
    l_row_not_found := okl_pon_pdt_fk_csr%NOTFOUND;
    CLOSE okl_pon_pdt_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_PAST_RECORDS);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;*/

	--CHECK FOR UNIQUENESS
  IF p_ponv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pdt_opts_unique (p_ponv_rec.opt_id, p_ponv_rec.pdt_id);
    FETCH okl_pdt_opts_unique INTO l_unique_key;
    IF okl_pdt_opts_unique%FOUND THEN
 	   --Okl_Api.set_message(G_APP_NAME,G_UNQS, G_TABLE_TOKEN,l_token_6);
	   Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
				     p_msg_name	    => 'OKL_COLUMN_NOT_UNIQUE',
				     p_token1	    => G_TABLE_TOKEN,
				     p_token1_value => l_token_1,
				     p_token2	    => G_COLUMN_TOKEN,
				     p_token2_value => l_token_6);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
      ELSE
          x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opts_unique;
  END IF;

	-- Check for constraints dates
   IF p_ponv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pon_constraints_csr(p_ponv_rec.opt_id,
		 					  	  p_ponv_rec.from_date,
							  	  p_ponv_rec.TO_DATE);
    FETCH okl_pon_constraints_csr INTO l_check;
    l_row_not_found := okl_pon_constraints_csr%NOTFOUND;
    CLOSE okl_pon_constraints_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_4,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_3);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   END IF;

  -- Check for rule Overlap
  IF p_ponv_rec.id = Okl_Api.G_MISS_NUM THEN
	FOR i IN get_opt_ruls(p_ponv_rec.opt_id)
    LOOP
      FOR j IN get_pdt_ruls(p_ponv_rec.pdt_id)
      LOOP
      IF i.lrg_lse_id IS NULL THEN
          IF j.lrg_lse_id IS NULL THEN
             IF (i.srd_id_for = j.srd_id_for AND
                 i.rgr_rgd_code = j.rgr_rgd_code AND
                 i.rgr_rdf_code   = j.rgr_rdf_code) AND
				 i.opt_id   <> j.opt_id THEN
    		      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	                      	          p_msg_name	   => G_OPTION_DUPLICATE_RULE);
                 x_valid := FALSE;
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
	             RAISE G_EXCEPTION_HALT_PROCESSING;
             END IF;
           END IF;
        END IF;

        IF i.lrg_lse_id IS NOT NULL THEN
           IF j.lrg_lse_id IS NOT NULL THEN
             IF (i.lrg_lse_id = j.lrg_lse_id  AND
                 i.lrg_srd_id = j.lrg_srd_id AND
                 i.rgr_rgd_code = j.rgr_rgd_code AND
                 i.rgr_rdf_code   = j.rgr_rdf_code) AND
 				 i.opt_id   <> j.opt_id THEN
                 Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
					    	         p_msg_name	   => G_OPTION_DUPLICATE_RULE);
                 x_valid := FALSE;
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
	             RAISE G_EXCEPTION_HALT_PROCESSING;
             END IF;
            END IF;
  		 END IF;
        END LOOP;
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

       IF (okl_ponv_chk_upd%ISOPEN) THEN
	   	  CLOSE okl_ponv_chk_upd;
       END IF;

       IF (okl_pon_pdt_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pon_pdt_fk_csr;
       END IF;

	    IF (okl_pon_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pon_constraints_csr;
       END IF;

 	   IF (okl_pdt_opts_unique%ISOPEN) THEN
	   	  CLOSE okl_pdt_opts_unique;
       END IF;

 END Check_Constraints;

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Opt_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Opt_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Opt_Id (
    p_ponv_rec IN  ponv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    CURSOR okl_pdt_opts_foreign1 (p_foreign  OKL_PDT_OPTS.OPT_ID%TYPE) IS
    SELECT ID
       FROM OKL_OPTIONS_V
      WHERE OKL_OPTIONS_V.ID =  p_foreign;

    l_foreign_key           OKL_PDT_OPTS_V.OPT_ID%TYPE;
    l_token_1               VARCHAR2(999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_CRUPD',
                                                      p_attribute_code => 'OKL_OPTION');

    IF p_ponv_rec.opt_id = Okl_Api.G_MISS_NUM OR
       p_ponv_rec.opt_id IS NULL
    THEN
      Okl_Api.set_message(Okl_Pon_Pvt.G_APP_NAME, Okl_Pon_Pvt.G_REQUIRED_VALUE,Okl_Pon_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE G_ITEM_NOT_FOUND_ERROR;
    END IF;

    IF p_ponv_rec.opt_id IS NOT NULL THEN
    OPEN okl_pdt_opts_foreign1 (p_ponv_rec.opt_id);
    FETCH okl_pdt_opts_foreign1 INTO l_foreign_key;
    IF okl_pdt_opts_foreign1%NOTFOUND THEN
         Okl_Api.set_message(Okl_Pon_Pvt.G_APP_NAME, Okl_Pon_Pvt.G_INVALID_VALUE,Okl_Pon_Pvt.G_COL_NAME_TOKEN,l_token_1);
         x_return_status := Okl_Api.G_RET_STS_ERROR;
         RAISE G_ITEM_NOT_FOUND_ERROR;
    ELSE
          x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opts_foreign1;
	END IF;

  EXCEPTION
     WHEN G_ITEM_NOT_FOUND_ERROR THEN
	     NULL;
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name  =>Okl_Pon_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Pon_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Pon_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Pon_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Opt_Id;
------end of Validate_Opt_Id-----------------------------------

 ---------------------------------------------------------------------------
  -- FUNCTION Validate _Attribute
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Attribute
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION Validate_Attributes(
    p_ponv_rec IN  ponv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;


  BEGIN
    -----CHECK FOR OPT_ID----------------------------
    Validate_Opt_Id (p_ponv_rec,x_return_status);
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
           Okl_Api.set_message(p_app_name  =>Okl_Pon_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Pon_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Pon_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Pon_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;



 ---------------------------------------------------------------------------
 -- PROCEDURE insert_poptions for: OKL_PDT_OPTS_V
 ---------------------------------------------------------------------------

 PROCEDURE insert_poptions(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                    	   x_return_status   OUT NOCOPY VARCHAR2,
                     	   x_msg_count       OUT NOCOPY NUMBER,
                      	   x_msg_data        OUT NOCOPY VARCHAR2,
					       p_pdtv_rec        IN  pdtv_rec_type,
                       	   p_ponv_rec        IN  ponv_rec_type,
                       	   x_ponv_rec        OUT NOCOPY ponv_rec_type
                       ) IS

    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_poptions';
    l_return_status   VARCHAR2(1)            := Okl_Api.G_RET_STS_SUCCESS;
    l_valid	          BOOLEAN;
    l_ponv_rec	      ponv_rec_type;
    l_pdtv_rec	      pdtv_rec_type;
    l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/RRRR'), 'DD/MM/RRRR');
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_ponv_rec := p_ponv_rec;

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
    l_return_status := Validate_Attributes(l_ponv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	get_parent_dates(p_ponv_rec	     => l_ponv_rec,
                    x_no_data_found  => l_row_notfound,
	                x_return_status  => l_return_status,
	                x_pdtv_rec	     => l_pdtv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--assign parent dates.

	l_ponv_rec.from_date := l_pdtv_rec.from_date;
	l_ponv_rec.TO_DATE   := l_pdtv_rec.TO_DATE;

    /* check if the products is already used by contracts if yes halt the process*/

      Check_Constraints(p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        p_ponv_rec 		=> l_ponv_rec,
				   	    x_return_status	=> l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
						x_valid			=> l_valid);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* public api to insert poptions */
    Okl_Product_Options_Pub.insert_product_options(p_api_version   => p_api_version,
                        	                	    p_init_msg_list => p_init_msg_list,
                       		 	                    x_return_status => l_return_status,
                       		 	                    x_msg_count     => x_msg_count,
                       		 	                    x_msg_data      => x_msg_data,
                       		 	                    p_ponv_rec      => l_ponv_rec,
                       		 	                    x_ponv_rec      => x_ponv_rec);

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

  END insert_poptions;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_pdt_pqys for: OKL_PDT_OPTS_V
  -- Private procedure called from delete_poptions.
  ---------------------------------------------------------------------------

  PROCEDURE delete_pdt_opt_vals(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pdtv_rec              IN  pdtv_rec_type
    ,p_ponv_rec              IN  ponv_rec_type) IS

    i                        PLS_INTEGER :=0;
    l_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_del_povv_tbl           Okl_Pdt_Opt_Vals_Pub.povv_tbl_type;

    CURSOR pov_csr IS
      SELECT povv.id
        FROM okl_pdt_opt_vals_v povv
       WHERE povv.pon_id = p_ponv_rec.id;

  BEGIN

    FOR pov_rec IN pov_csr
    LOOP
      i := i + 1;
      l_del_povv_tbl(i).id := pov_rec.id;
    END LOOP;
    IF l_del_povv_tbl.COUNT > 0 THEN
     /* public api to delete product option values */
    Okl_Pdt_Opt_Vals_Pub.delete_pdt_opt_vals(p_api_version   => p_api_version,
                             	     	    p_init_msg_list  => p_init_msg_list,
                              		        x_return_status  => l_return_status,
                              		        x_msg_count      => x_msg_count,
                              		        x_msg_data       => x_msg_data,
                              		        p_povv_tbl       => l_del_povv_tbl);

      IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_PROCESSING;
      ELSE
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
        END IF;
      END IF;
    END IF;
    --Delete the Master
    Okl_Product_Options_Pub.delete_product_options(p_api_version   => p_api_version,
                              		               p_init_msg_list => p_init_msg_list,
                              		               x_return_status => l_return_status,
                              		               x_msg_count     => x_msg_count,
                              		               x_msg_data      => x_msg_data,
                              		               p_ponv_rec      => p_ponv_rec);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_PROCESSING;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      NULL;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);

      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END delete_pdt_opt_vals;


  ----------------------------------------------------------------------------
  -- PROCEDURE delete_poptions for: OKL_PDT_OPTS_V
  -- This allows the user to delete table of records
  ----------------------------------------------------------------------------

  PROCEDURE delete_poptions(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
					    ,p_pdtv_rec                     IN  pdtv_rec_type
                        ,p_ponv_tbl                     IN  ponv_tbl_type
                        ) IS

	l_del_povv_tbl    Okl_Pdt_Opt_Vals_Pub.povv_tbl_type;
	l_loop_ctr        NUMBER := 1;
    l_api_version     CONSTANT NUMBER := 1;
    l_overall_status  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS; --TCHGS
    i                 PLS_INTEGER :=0;
    l_ponv_tbl        ponv_tbl_type;
    l_pdtv_rec        pdtv_rec_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_poptions';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_valid	          BOOLEAN;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_ponv_tbl := p_ponv_tbl;
    l_pdtv_rec := p_pdtv_rec;

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

	 IF (l_ponv_tbl.COUNT > 0) THEN
      i := p_ponv_tbl.FIRST;
      LOOP
        /* check if the product asked to delete is used by contracts if yes halt the process*/

 		 Check_Constraints(p_api_version    => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            p_ponv_rec 		=> l_ponv_tbl(i),
				   	        x_return_status	=> l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
				   	        x_valid			=> l_valid);

          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		      (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		       l_valid <> TRUE) THEN
              x_return_status    := Okl_Api.G_RET_STS_ERROR;
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

        delete_pdt_opt_vals(p_api_version   => p_api_version
                          ,p_init_msg_list  => p_init_msg_list
                          ,x_return_status  => x_return_status
                          ,x_msg_count      => x_msg_count
                          ,x_msg_data       => x_msg_data
					      ,p_pdtv_rec       => l_pdtv_rec
                          ,p_ponv_rec       => l_ponv_tbl(i)
                          );
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
      EXIT WHEN (i = p_ponv_tbl.LAST);
      i := p_ponv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;

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

  END delete_poptions;

END Okl_Setuppoptions_Pvt;

/
