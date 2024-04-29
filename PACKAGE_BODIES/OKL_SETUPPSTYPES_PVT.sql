--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPSTYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPSTYPES_PVT" AS
/* $Header: OKLRSPSB.pls 115.7 2003/07/23 18:36:58 sgorantl noship $ */
G_ITEM_NOT_FOUND_ERROR  EXCEPTION;
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: Okl_Prod_Strm_Types_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_psyv_rec                     IN psyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_psyv_rec					   OUT NOCOPY psyv_rec_type
  ) IS
    CURSOR okl_psyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            STY_ID,
            PDT_ID,
            ACCRUAL_YN,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
     FROM Okl_Prod_Strm_Types_V
     WHERE Okl_Prod_Strm_Types_V.id = p_id;
    l_okl_psyv_pk                  okl_psyv_pk_csr%ROWTYPE;
    l_psyv_rec                     psyv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_psyv_pk_csr (p_psyv_rec.id);
    FETCH okl_psyv_pk_csr INTO
              l_psyv_rec.ID,
              l_psyv_rec.OBJECT_VERSION_NUMBER,
              l_psyv_rec.STY_ID,
              l_psyv_rec.PDT_ID,
              l_psyv_rec.ACCRUAL_YN,
              l_psyv_rec.FROM_DATE,
              l_psyv_rec.TO_DATE,
              l_psyv_rec.CREATED_BY,
              l_psyv_rec.CREATION_DATE,
              l_psyv_rec.LAST_UPDATED_BY,
              l_psyv_rec.LAST_UPDATE_DATE,
              l_psyv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_psyv_pk_csr%NOTFOUND;
    CLOSE okl_psyv_pk_csr;
	x_psyv_rec 	:= l_psyv_rec;
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

      IF (okl_psyv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_psyv_pk_csr;
      END IF;

  END get_rec;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_parent_dates for: Okl_Prod_Strm_Types_V
 ---------------------------------------------------------------------------

 PROCEDURE get_parent_dates(
    p_psyv_rec                     IN psyv_rec_type,
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
    OPEN okl_pdt_pk_csr (p_psyv_rec.pdt_id);
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
  -- PROCEDURE check_constraints for: Okl_Prod_Strm_Types_V
 -----------------------------------------------------------------------------

 PROCEDURE Check_Constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	p_psyv_rec		 IN  psyv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS
   CURSOR okl_psyv_chk_upd(p_pdt_id  NUMBER
	) IS
    SELECT '1' FROM okl_k_headers_v khdr
    WHERE khdr.pdt_id = p_pdt_id;

   CURSOR okl_psy_pdt_fk_csr (p_pdt_id    IN Okl_Products_V.ID%TYPE,
                              p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_products_V pdt
    WHERE pdt.ID    = p_pdt_id
    AND   NVL(pdt.TO_DATE, p_date) < p_date;

   CURSOR okl_psy_constraints_csr(p_sty_id     IN Okl_Prod_Strm_Types_V.STY_ID%TYPE,
		   					      p_from_date  IN Okl_Prod_Strm_Types_V.FROM_DATE%TYPE,
							      p_to_date 	 IN Okl_Prod_Strm_Types_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Strm_Type_V sty
     WHERE sty.ID  = p_sty_id
	 AND   ((sty.START_DATE > p_from_date OR
            p_from_date > NVL(sty.END_DATE,p_from_date)) OR
	 	    NVL(sty.END_DATE, p_to_date) < p_to_date);

  CURSOR c1(p_pdt_id okl_prod_strm_types_v.pdt_id%TYPE,
		p_sty_id okl_prod_strm_types_v.sty_id%TYPE) IS
  SELECT '1'
  FROM okl_prod_strm_types_v
  WHERE  pdt_id = p_pdt_id
  AND    sty_id = p_sty_id
  AND id <> NVL(p_psyv_rec.id,-9999);

  l_check		   	        VARCHAR2(1) := '?';
  l_row_not_found      	    BOOLEAN     := FALSE;
  l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_unq_tbl               Okc_Util.unq_tbl_type;
  l_psy_status            VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  l_token_1        VARCHAR2(1999);

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDTPSY_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_STREAM_TYPES');

   -- check for uniquness
   IF p_psyv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN c1(p_psyv_rec.pdt_id,
	      p_psyv_rec.sty_id);
    FETCH c1 INTO l_psy_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
		Okl_Api.set_message('OKL',Okl_Psy_Pvt.G_UNQS,Okl_Psy_Pvt.G_TABLE_TOKEN, l_token_1); ---CHG001
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   END IF;

    -- Check for psyv valid dates
 /*   OPEN okl_psyv_chk_upd(p_psyv_rec.pdt_id);

    FETCH okl_psyv_chk_upd INTO l_check;
    l_row_not_found := okl_psyv_chk_upd%NOTFOUND;
    CLOSE okl_psyv_chk_upd;

    IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_IN_USE,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => 'Okl_Prod_Strm_Types_V',
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => 'okl_k_headers_v');
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    */
    -- Check if the product to which the product stream types are attached is not
    -- in the past
    /*OPEN okl_psy_pdt_fk_csr (p_psyv_rec.pdt_id,
                             l_sysdate);
    FETCH okl_psy_pdt_fk_csr INTO l_check;
    l_row_not_found := okl_psy_pdt_fk_csr%NOTFOUND;
    CLOSE okl_psy_pdt_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_PAST_RECORDS);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;*/

    /*-- Check for constraints dates
    OPEN okl_psy_constraints_csr(p_psyv_rec.sty_id,
		 					  	 p_psyv_rec.from_date,
							  	 p_psyv_rec.TO_DATE);
    FETCH okl_psy_constraints_csr INTO l_check;
    l_row_not_found := okl_psy_constraints_csr%NOTFOUND;
    CLOSE okl_psy_constraints_csr;

    IF l_row_not_found = FALSE THEN
	   OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Okl_Strm_Type_V',
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Okl_Prod_Strm_Types_V,Okl_Products_V');
	   x_valid := FALSE;
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;*/

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

       IF (okl_psyv_chk_upd%ISOPEN) THEN
	   	  CLOSE okl_psyv_chk_upd;
       END IF;

       IF (okl_psy_pdt_fk_csr%ISOPEN) THEN
 	   	  CLOSE okl_psy_pdt_fk_csr;
       END IF;

	   IF (okl_psy_constraints_csr%ISOPEN) THEN
 	     CLOSE okl_psy_constraints_csr;
	   END IF;

  	   IF (C1%ISOPEN) THEN
 	     CLOSE C1;
	   END IF;

  END Check_Constraints;

  -------------------------------------
  -- Validate_Attributes for: STY_ID --
  -------------------------------------
  PROCEDURE validate_sty_id(x_return_status                OUT NOCOPY VARCHAR2,
                            p_sty_id                       IN NUMBER)
  IS
      CURSOR okl_styv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
      FROM okl_strm_type_v
      WHERE okl_strm_type_v.id = p_id;

      l_sty_status                   VARCHAR2(1);
	  l_row_notfound                 BOOLEAN := TRUE;
	  l_token_1        VARCHAR2(1999);

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDTPSY_CRUPD',
                                                      p_attribute_code => 'OKL_NAME');

    IF (p_sty_id = Okl_Api.G_MISS_NUM OR
        p_sty_id IS NULL)
    THEN
      Okl_Api.set_message(Okl_Psy_Pvt.G_APP_NAME, Okl_Psy_Pvt.G_REQUIRED_VALUE, Okl_Psy_Pvt.G_COL_NAME_TOKEN, l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF (p_sty_id IS NOT NULL)
      THEN
        OPEN okl_styv_pk_csr(p_sty_id);
        FETCH okl_styv_pk_csr INTO l_sty_status;
        l_row_notfound := okl_styv_pk_csr%NOTFOUND;
        CLOSE okl_styv_pk_csr;
        IF (l_row_notfound) THEN
          Okl_Api.set_message(Okl_Psy_Pvt.G_APP_NAME, Okl_Psy_Pvt.G_INVALID_VALUE,Okl_Psy_Pvt.G_COL_NAME_TOKEN,l_token_1);
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => Okl_Psy_Pvt.G_APP_NAME
                          ,p_msg_name     => Okl_Psy_Pvt.G_UNEXPECTED_ERROR
                          ,p_token1       => Okl_Psy_Pvt.G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => Okl_Psy_Pvt.G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END validate_sty_id;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_PROD_STRM_TYPES_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_psyv_rec                     IN psyv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- sty_id
    -- ***
    validate_sty_id(x_return_status, p_psyv_rec.sty_id);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => Okl_Psy_Pvt.G_APP_NAME
                          ,p_msg_name     => Okl_Psy_Pvt.G_UNEXPECTED_ERROR
                          ,p_token1       => Okl_Psy_Pvt.G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => Okl_Psy_Pvt.G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_pstypes for: Okl_Prod_Strm_Types_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_pstypes(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_psyv_rec                     IN  psyv_rec_type,
    x_psyv_rec                     OUT NOCOPY psyv_rec_type
    ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_pstypes';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_valid			  BOOLEAN;
	l_psyv_rec		  psyv_rec_type;
    l_pdtv_rec		  pdtv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_psyv_rec := p_psyv_rec;

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

    l_return_status := Validate_Attributes(l_psyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    get_parent_dates(p_psyv_rec 	  => l_psyv_rec,
                    x_no_data_found   => l_row_notfound,
                    x_return_status   => l_return_status,
	                x_pdtv_rec	      => l_pdtv_rec);


	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--assign parent dates.

	l_psyv_rec.from_date := l_pdtv_rec.from_date;
	l_psyv_rec.TO_DATE   := l_pdtv_rec.TO_DATE;

    /* call check_constraints to check the validity of this relationship */

    Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_psyv_rec 		=> l_psyv_rec,
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

	/* public api to insert pstypes */

    Okl_Pdt_Stys_Pub.insert_pdt_stys(p_api_version   => p_api_version,
                            	     p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_psyv_rec      => l_psyv_rec,
                              		 x_psyv_rec      => x_psyv_rec);

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

  END insert_pstypes;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_pstypes for: Okl_Prod_Strm_Types_V
  ---------------------------------------------------------------------------
  PROCEDURE update_pstypes(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_psyv_rec                     IN  psyv_rec_type,
    x_psyv_rec                     OUT NOCOPY psyv_rec_type
    ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_pstypes';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_valid			  BOOLEAN;
	l_psyv_rec		  psyv_rec_type;
    l_pdtv_rec		  pdtv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_psyv_rec := p_psyv_rec;

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

	get_parent_dates(p_psyv_rec 	  => l_psyv_rec,
                     x_no_data_found  => l_row_notfound,
	                 x_return_status  => l_return_status,
	                 x_pdtv_rec		  => l_pdtv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--assign parent dates.

	l_psyv_rec.from_date := l_pdtv_rec.from_date;
	l_psyv_rec.TO_DATE   := l_pdtv_rec.TO_DATE;


    /* call check_constraints to check the validity of this relationship */

	Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_psyv_rec 		=> l_psyv_rec,
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

	/* public api to update pstypes */

    Okl_Pdt_Stys_Pub.update_pdt_stys(p_api_version   => p_api_version,
                            		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_psyv_rec      => l_psyv_rec,
                              		 	   x_psyv_rec      => x_psyv_rec);

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

  END update_pstypes;

END Okl_Setuppstypes_Pvt;

/
