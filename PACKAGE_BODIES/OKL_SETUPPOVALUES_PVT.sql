--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPOVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPOVALUES_PVT" AS
/* $Header: OKLRSDVB.pls 115.12 2003/07/23 18:32:08 sgorantl noship $ */
G_TABLE_TOKEN                 CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001
G_UNQS	                      CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE'; --- CHG001
G_COLUMN_TOKEN			  CONSTANT VARCHAR2(100) := 'COLUMN';
G_ITEM_NOT_FOUND_ERROR        EXCEPTION;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PDT_OPT_VALS_V
 ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_povv_rec                     IN povv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
   	x_return_status				   OUT NOCOPY VARCHAR2,
	x_povv_rec					   OUT NOCOPY povv_rec_type
  ) IS
    CURSOR okl_povv_pk_csr (p_id  IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OVE_ID,
            PON_ID,
            FROM_DATE,
            CREATED_BY,
            TO_DATE,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Opt_Vals_V
     WHERE okl_pdt_opt_vals_v.id = p_id;
    l_okl_povv_pk                  okl_povv_pk_csr%ROWTYPE;
    l_povv_rec                     povv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_povv_pk_csr (p_povv_rec.id);
    FETCH okl_povv_pk_csr INTO
              l_povv_rec.ID,
              l_povv_rec.OBJECT_VERSION_NUMBER,
              l_povv_rec.OVE_ID,
              l_povv_rec.PON_ID,
              l_povv_rec.FROM_DATE,
              l_povv_rec.CREATED_BY,
              l_povv_rec.TO_DATE,
              l_povv_rec.CREATION_DATE,
              l_povv_rec.LAST_UPDATED_BY,
              l_povv_rec.LAST_UPDATE_DATE,
              l_povv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_povv_pk_csr%NOTFOUND;

    CLOSE okl_povv_pk_csr;
	x_povv_rec := l_povv_rec;
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

      IF (okl_povv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_povv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_parent_dates for: OKL_PDT_OPTS_V
 ---------------------------------------------------------------------------

 PROCEDURE get_parent_dates(
    p_povv_rec		  IN povv_rec_type,
    x_no_data_found   OUT NOCOPY BOOLEAN,
	x_return_status	  OUT NOCOPY VARCHAR2,
	x_ponv_rec		  OUT NOCOPY ponv_rec_type
  ) IS
    CURSOR okl_ponv_pk_csr (p_pon_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_pdt_opts_V ponv
     WHERE ponv.id = p_pon_id;
    l_okl_ponv_pk                  okl_ponv_pk_csr%ROWTYPE;
    l_ponv_rec                     ponv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
	-- Get current database values
    OPEN okl_ponv_pk_csr (p_povv_rec.pon_id);
    FETCH okl_ponv_pk_csr INTO
              l_ponv_rec.FROM_DATE,
              l_ponv_rec.TO_DATE;
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

 END get_parent_dates;

 -----------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_PDT_OPT_VALS_V
 -----------------------------------------------------------------------------

 PROCEDURE Check_Constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    p_povv_rec		 IN  povv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS

    CURSOR okl_povv_chk(p_pon_id  NUMBER
	) IS
    SELECT '1' FROM okl_pdt_opts_v     ponv,
					okl_k_headers_v    khdr
    WHERE ponv.id = p_pon_id AND
	      khdr.pdt_id = ponv.pdt_id;

    CURSOR okl_pov_pdt_fk_csr(p_pon_id    IN Okl_Products_V.ID%TYPE,
                              p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_products_V pdt,
     	 Okl_pdt_opts_V pon
    WHERE pdt.id = pon.pdt_id
	AND pon.ID    = p_pon_id
    AND   NVL(pdt.TO_DATE, p_date) < p_date;

    CURSOR okl_pov_constraints_csr(p_ove_id     IN Okl_Pdt_Qualitys_V.ID%TYPE,
		   					        p_from_date  IN Okl_Pdt_Qualitys_V.FROM_DATE%TYPE,
							        p_to_date 	 IN Okl_Pdt_Qualitys_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Opt_Values_V ove
     WHERE ove.ID        = p_ove_id
	 AND   ((ove.FROM_DATE > p_from_date OR
            p_from_date > NVL(ove.TO_DATE,p_from_date)) OR
	 	    NVL(ove.TO_DATE, p_to_date) < p_to_date);

  CURSOR okl_pdt_opt_vals_unique (p_unique1  OKL_PDT_OPT_VALS_V.OVE_ID%TYPE, p_unique2  OKL_PDT_OPT_VALS_V.PON_ID%TYPE) IS
    SELECT '1'
       FROM OKL_PDT_OPT_VALS_V
      WHERE OKL_PDT_OPT_VALS_V.OVE_ID =  p_unique1 AND
            OKL_PDT_OPT_VALS_V.PON_ID =  p_unique2 AND
            OKL_PDT_OPT_VALS_V.ID <> NVL(p_povv_rec.id,-9999);

  l_unique_key                   VARCHAR2(1);
  l_check		   	        VARCHAR2(1) := '?';
  l_row_not_found     	    BOOLEAN     := FALSE;
  l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_token_1       VARCHAR2(1999);
  l_token_2       VARCHAR2(1999);
  l_token_3      VARCHAR2(1999);
  l_token_4       VARCHAR2(1999);
  l_token_5       VARCHAR2(1999);
  l_token_6       VARCHAR2(1999);

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_OPT_VAL_SUMRY',
                                                      p_attribute_code => 'OKL_PRODUCT_OPTION_VALUES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCTS');
    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
                                                      p_attribute_code => 'OKL_KDTLS_CONTRACT');
    l_token_4 := l_token_1 ||','||l_token_2;


    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_VALUES');

    l_token_6 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_CRUPD',
                                                      p_attribute_code => 'OKL_OPTION_VALUE');


    -- Check for povv inserts and deletes
    OPEN okl_povv_chk(p_povv_rec.pon_id);

    FETCH okl_povv_chk INTO l_check;
    l_row_not_found := okl_povv_chk%NOTFOUND;
    CLOSE okl_povv_chk;

    IF l_row_not_found = FALSE THEN
	  	 Okl_Api.SET_MESSAGE(p_app_name	 => G_APP_NAME,
		 		      p_msg_name	     => G_IN_USE,
				      p_token1		     => G_PARENT_TABLE_TOKEN,
				      p_token1_value     => l_token_1,
				      p_token2		     => G_CHILD_TABLE_TOKEN,
				      p_token2_value     => l_token_3);
       x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  --CHECK FOR UNIQUENESS
  IF p_povv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pdt_opt_vals_unique (p_povv_rec.ove_id, p_povv_rec.pon_id);
    FETCH okl_pdt_opt_vals_unique INTO l_unique_key;
    IF okl_pdt_opt_vals_unique%FOUND THEN
       --Okl_Api.set_message(G_APP_NAME,G_UNQS, G_TABLE_TOKEN,l_token_1);
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
    CLOSE okl_pdt_opt_vals_unique;
   END IF;

	-- Check if the product to which the option values are added is not
    -- in the past
   /* OPEN okl_pov_pdt_fk_csr (p_povv_rec.pon_id,
                             l_sysdate);
    FETCH okl_pov_pdt_fk_csr INTO l_check;
    l_row_not_found := okl_pov_pdt_fk_csr%NOTFOUND;
    CLOSE okl_pov_pdt_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_PAST_RECORDS);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
	*/

   -- Check for constraints dates
   IF p_povv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pov_constraints_csr (p_povv_rec.ove_id,
		 					  	  p_povv_rec.from_date,
							  	  p_povv_rec.TO_DATE);
    FETCH okl_pov_constraints_csr INTO l_check;
    l_row_not_found := okl_pov_constraints_csr%NOTFOUND;
    CLOSE okl_pov_constraints_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_5,
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

       IF (okl_povv_chk%ISOPEN) THEN
	   	  CLOSE okl_povv_chk;
       END IF;

       IF (okl_pov_pdt_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pov_pdt_fk_csr;
       END IF;

       IF (okl_pov_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pov_constraints_csr;
       END IF;

       IF (okl_pdt_opt_vals_unique%ISOPEN) THEN
	   	  CLOSE okl_pdt_opt_vals_unique;
       END IF;

 END Check_Constraints;

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Ove_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Ove_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Ove_Id (
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    CURSOR okl_pdt_opt_vals_foreign1 (p_foreign  OKL_PDT_OPT_VALS.OVE_ID%TYPE) IS
    SELECT ID
       FROM OKL_OPT_VALUES_V
      WHERE OKL_OPT_VALUES_V.ID =  p_foreign;

    l_foreign_key                   OKL_PDT_OPT_VALS_V.OVE_ID%TYPE;
	l_token_1                       VARCHAR2(1999);


  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_CRUPD',
                                                      p_attribute_code => 'OKL_OPTION_VALUE');


    IF p_povv_rec.ove_id = Okl_Api.G_MISS_NUM OR
       p_povv_rec.ove_id IS NULL
    THEN
      Okc_Api.set_message(Okl_Pov_Pvt.G_APP_NAME, Okl_Pov_Pvt.G_REQUIRED_VALUE,Okl_Pov_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
	  RAISE G_ITEM_NOT_FOUND_ERROR;
    END IF;

	IF p_povv_rec.ove_id IS NOT NULL THEN
    OPEN okl_pdt_opt_vals_foreign1 (p_povv_rec.ove_id);
    FETCH okl_pdt_opt_vals_foreign1 INTO l_foreign_key;
    IF okl_pdt_opt_vals_foreign1%NOTFOUND THEN
         Okc_Api.set_message(Okl_Pov_Pvt.G_APP_NAME, Okl_Pov_Pvt.G_INVALID_KEY,Okl_Pov_Pvt.G_COL_NAME_TOKEN,l_token_1);
         x_return_status := Okl_Api.G_RET_STS_ERROR;
		 RAISE G_ITEM_NOT_FOUND_ERROR;
        ELSE
          x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opt_vals_foreign1;
	END IF;
  EXCEPTION
     WHEN G_ITEM_NOT_FOUND_ERROR THEN
	      NULL;
     WHEN OTHERS THEN
	       Okl_Api.set_message(p_app_name  =>Okl_Pov_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Pov_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Pov_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Pov_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Ove_Id;
------end of Validate_Ove_Id-----------------------------------

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
    p_povv_rec IN  povv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -----CHECK FOR OVE_ID----------------------------
    Validate_Ove_Id (p_povv_rec,x_return_status);
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
           Okl_Api.set_message(p_app_name  =>Okl_Pov_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Pov_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Pov_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Pov_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

  -----END OF VALIDATE ATTRIBUTES-------------------------


 ---------------------------------------------------------------------------
 -- PROCEDURE insert_povalues for: Okl_Pdt_opt_vals_V
 ---------------------------------------------------------------------------

 PROCEDURE insert_povalues(p_api_version       IN  NUMBER,
 		   			       p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_pdtv_rec          IN  pdtv_rec_type,
						   p_optv_rec          IN  optv_rec_type,
                           p_povv_rec          IN  povv_rec_type,
                           x_povv_rec          OUT NOCOPY povv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_povalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_valid	          BOOLEAN;
    l_povv_rec	      povv_rec_type;
    l_ponv_rec	      ponv_rec_type;
    l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_povv_rec := p_povv_rec;

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
    l_return_status := Validate_Attributes(l_povv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


    get_parent_dates( p_povv_rec 	   => l_povv_rec,
                     x_no_data_found   => l_row_notfound,
	                 x_return_status   => l_return_status,
	                 x_ponv_rec		   => l_ponv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--l_ptlv_rec := x_ptlv_rec;
	--assign parent dates.

	l_povv_rec.from_date := l_ponv_rec.from_date;
	l_povv_rec.TO_DATE   := l_ponv_rec.TO_DATE;

	/* call check_constraints to check the validity of this relationship */
	Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_povv_rec 		=> l_povv_rec,
				   	  x_return_status	=> l_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
				   	  x_valid			=> l_valid);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* public api to insert povalues */

    Okl_Pdt_Opt_Vals_Pub.insert_pdt_opt_vals(p_api_version   => p_api_version,
                                		     p_init_msg_list => p_init_msg_list,
                       		                 x_return_status => l_return_status,
                       		 	             x_msg_count     => x_msg_count,
                       		 	             x_msg_data      => x_msg_data,
                       		 	             p_povv_rec      => l_povv_rec,
                       		 	             x_povv_rec      => x_povv_rec);

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

  END insert_povalues;

   ---------------------------------------------------------------------------
  -- PROCEDURE delete_povalues for: Okl_Pdt_opt_vals_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_povalues(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
						,p_pdtv_rec                     IN  pdtv_rec_type
                        ,p_optv_rec                     IN  optv_rec_type
						,p_povv_tbl                     IN  povv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_povv_tbl        povv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_povalues';
    l_povv_rec	      povv_rec_type;
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_overall_status  VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    i                 NUMBER;
    l_valid			  BOOLEAN;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_povv_tbl := p_povv_tbl;

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

    /* check if the product asked to delete is used by contracts if yes halt the process*/

	IF (l_povv_tbl.COUNT > 0) THEN
      i := l_povv_tbl.FIRST;
      LOOP
       /* call check_constraints to check the validity of this relationship */
	       Check_Constraints(p_api_version     => p_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             p_povv_rec 	   => l_povv_tbl(i),
				   	         x_return_status   => l_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
				   	         x_valid		   => l_valid);

		  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		      (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		       l_valid <> TRUE) THEN
              x_return_status    := Okl_Api.G_RET_STS_ERROR;
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = l_povv_tbl.LAST);

          i := l_povv_tbl.NEXT(i);

       END LOOP;
     END IF;

    /* delete product option values */
    Okl_Pdt_Opt_Vals_Pub.delete_pdt_opt_vals(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		         x_return_status => l_return_status,
                              		         x_msg_count     => x_msg_count,
                              		         x_msg_data      => x_msg_data,
                              		         p_povv_tbl      => l_povv_tbl);

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

  END delete_povalues;

END Okl_Setuppovalues_Pvt;

/
