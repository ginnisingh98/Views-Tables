--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPMVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPMVALUES_PVT" AS
/* $Header: OKLRSMVB.pls 120.2 2007/03/04 09:53:56 dcshanmu ship $ */

G_ITEM_NOT_FOUND_ERROR  EXCEPTION;
G_COLUMN_TOKEN			  CONSTANT VARCHAR2(100) := 'COLUMN';
G_TABLE_TOKEN                 CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001
 ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PTL_PTQ_VALS_V
 ---------------------------------------------------------------------------

PROCEDURE get_rec (
    p_pmvv_rec                     IN pmvv_rec_type,
    x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_pmvv_rec					   OUT NOCOPY pmvv_rec_type
  ) IS
    CURSOR okl_pmvv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PTV_ID,
            PTL_ID,
            PTQ_ID,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
     FROM Okl_Ptl_Ptq_Vals_V
     WHERE okl_ptl_ptq_vals_v.id = p_id;
    l_okl_pmvv_pk                  okl_pmvv_pk_csr%ROWTYPE;
    l_pmvv_rec                     pmvv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pmvv_pk_csr (p_pmvv_rec.id);
    FETCH okl_pmvv_pk_csr INTO
              l_pmvv_rec.ID,
              l_pmvv_rec.OBJECT_VERSION_NUMBER,
              l_pmvv_rec.PTV_ID,
              l_pmvv_rec.PTL_ID,
              l_pmvv_rec.PTQ_ID,
              l_pmvv_rec.FROM_DATE,
              l_pmvv_rec.TO_DATE,
              l_pmvv_rec.CREATED_BY,
              l_pmvv_rec.CREATION_DATE,
              l_pmvv_rec.LAST_UPDATED_BY,
              l_pmvv_rec.LAST_UPDATE_DATE,
              l_pmvv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pmvv_pk_csr%NOTFOUND;
    CLOSE okl_pmvv_pk_csr;
    x_pmvv_rec := l_pmvv_rec;
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

      IF (okl_pmvv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pmvv_pk_csr;
      END IF;

END get_rec;

---------------------------------------------------------------------------
 -- PROCEDURE get_parent_dates for: OKL_PDT_TEMPLATES_V
---------------------------------------------------------------------------

 PROCEDURE get_parent_dates(
    p_pmvv_rec                     IN pmvv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_ptlv_rec					   OUT NOCOPY ptlv_rec_type
  ) IS
    CURSOR okl_ptl_pk_csr (p_ptl_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_pdt_templates_V ptlv
     WHERE ptlv.id = p_ptl_id;
    l_okl_ptlv_pk                  okl_ptl_pk_csr%ROWTYPE;
    l_ptlv_rec                     ptlv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ptl_pk_csr (p_pmvv_rec.ptl_id);
    FETCH okl_ptl_pk_csr INTO
              l_ptlv_rec.FROM_DATE,
              l_ptlv_rec.TO_DATE;
    x_no_data_found := okl_ptl_pk_csr%NOTFOUND;
    CLOSE okl_ptl_pk_csr;
    x_ptlv_rec := l_ptlv_rec;
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

      IF (okl_ptl_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ptl_pk_csr;

      END IF;

 END get_parent_dates;

 -----------------------------------------------------------------------------
  -- PROCEDURE check_in_use for: Okl_Ptl_Ptq_Vals_V
 -----------------------------------------------------------------------------

 PROCEDURE Check_Constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	p_pmvv_rec		 IN  pmvv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS

    CURSOR okl_pmvv_chk_csr(p_ptl_id  NUMBER
	) IS
    SELECT '1' FROM okl_pdt_templates_v ptvv,
		   	   		okl_products pdtv,
					okl_k_headers_v khdr
    WHERE ptvv.id  = p_ptl_id
	AND   ptvv.id = pdtv.ptl_id
	AND	  pdtv.id  = khdr.pdt_id;

    CURSOR okl_pmv_ptl_fk_csr (p_ptl_id    IN Okl_Products_V.ID%TYPE,
                              p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_pdt_templates_V ptl
    WHERE ptl.ID    = p_ptl_id
    AND   NVL(ptl.TO_DATE, p_date) < p_date;

	 CURSOR okl_pmv_constraints_csr (p_ptv_id     IN Okl_Ptq_Values_V.ID%TYPE,
		   					        p_from_date  IN Okl_Ptq_Values_V.FROM_DATE%TYPE,
							        p_to_date 	 IN Okl_Ptq_Values_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Ptq_Values_V ptv
     WHERE ptv.ID        = p_ptv_id
	 AND   ((ptv.FROM_DATE > p_from_date OR
            p_from_date > NVL(ptv.TO_DATE,p_from_date)) OR
	 	    NVL(ptv.TO_DATE, p_to_date) < p_to_date);

  CURSOR c1(p_ptl_id okl_ptl_ptq_vals_v.ptl_id%TYPE,
		p_ptq_id okl_ptl_ptq_vals_v.ptq_id%TYPE) IS
  SELECT '1'
  FROM okl_ptl_ptq_vals_v
  WHERE  ptl_id = p_ptl_id
  AND    ptq_id = p_ptq_id
  AND    id <> NVL(p_pmvv_rec.id,-9999);

  l_unq_tbl               Okc_Util.unq_tbl_type;
  l_pmv_status            VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  l_check		   	        VARCHAR2(1) := '?';
  l_row_not_found     	    BOOLEAN     := FALSE;
  l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_token_1       VARCHAR2(1999);
  l_token_2       VARCHAR2(1999);
  l_token_3       VARCHAR2(1999);
  l_token_4       VARCHAR2(1999);
  l_token_5       VARCHAR2(1999);
  l_token_6       VARCHAR2(1999);

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_QLTY_CREATE',
                                                           p_attribute_code => 'OKL_PDT_TMPL_QLTY_CREATE_TITLE');

	l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
                                                           p_attribute_code => 'OKL_KDTLS_CONTRACT');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_TEMPLATE_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_TEMPLATES');

    l_token_4 := l_token_1 ||','||l_token_3;

    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_TMPVALS_CRUPD',
                                                      p_attribute_code => 'OKL_TEMPLATE_QUALITY_VALUES');

    l_token_6 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_QLTY_CREATE',
                                                      p_attribute_code => 'OKL_TEMPLATE_QUALITY');



    OPEN okl_pmvv_chk_csr(p_pmvv_rec.ptl_id);

    FETCH okl_pmvv_chk_csr INTO l_check;
    l_row_not_found := okl_pmvv_chk_csr%NOTFOUND;
    CLOSE okl_pmvv_chk_csr;

   IF l_row_not_found = FALSE THEN
        Okl_Api.SET_MESSAGE(p_app_name	=> G_APP_NAME,
 				      p_msg_name	    => G_IN_USE,
				      p_token1		    => G_PARENT_TABLE_TOKEN,
	 				  p_token1_value    => l_token_1,
					  p_token2		    => G_CHILD_TABLE_TOKEN,
					  p_token2_value    => l_token_2);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;



   IF p_pmvv_rec.id = Okl_Api.G_MISS_NUM THEN
	OPEN c1(p_pmvv_rec.ptl_id,
	      p_pmvv_rec.ptq_id);
    FETCH c1 INTO l_pmv_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
       --Okl_Api.set_message(Okl_Pmv_Pvt.G_APP_NAME,Okl_Pmv_Pvt.G_UNQS,Okl_Pmv_Pvt.G_TABLE_TOKEN, l_token_1); ---CHG001
	    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
				     p_msg_name	    => 'OKL_COLUMN_NOT_UNIQUE',
				     p_token1	    => G_TABLE_TOKEN,
				     p_token1_value => l_token_1,
				     p_token2	    => G_COLUMN_TOKEN,
				     p_token2_value => l_token_6);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   END IF;

    -- Check if the product template to which the template qualities are added is not
    -- in the past
    /*OPEN okl_pmv_ptl_fk_csr (p_pmvv_rec.ptl_id,
                             l_sysdate);
    FETCH okl_pmv_ptl_fk_csr INTO l_check;
    l_row_not_found := okl_pmv_ptl_fk_csr%NOTFOUND;
    CLOSE okl_pmv_ptl_fk_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_PAST_RECORDS);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
	*/

    -- Check for constraints dates
   IF p_pmvv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pmv_constraints_csr (p_pmvv_rec.ptv_id,
		 					  	  p_pmvv_rec.from_date,
							  	  p_pmvv_rec.TO_DATE);
    FETCH okl_pmv_constraints_csr INTO l_check;
    l_row_not_found := okl_pmv_constraints_csr%NOTFOUND;
    CLOSE okl_pmv_constraints_csr;

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

       IF (okl_pmvv_chk_csr%ISOPEN) THEN
	   	  CLOSE okl_pmvv_chk_csr;
       END IF;

       IF (okl_pmv_ptl_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pmv_ptl_fk_csr;
       END IF;

	   IF (okl_pmv_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pmv_constraints_csr;
       END IF;

   	   IF (c1%ISOPEN) THEN
	   	  CLOSE c1;
       END IF;

 END Check_Constraints;

   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ptq_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ptq_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Ptq_Id(p_pmvv_rec      IN   pmvv_rec_type
			     ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

      CURSOR okl_ptqv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_ptl_qualitys_v
       WHERE okl_ptl_qualitys_v.id = p_id;

      l_ptq_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
	  l_token_1                      VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_QLTY_CREATE',
                                                      p_attribute_code => 'OKL_TEMPLATE_QUALITY');

    -- check for data before processing
    IF (p_pmvv_rec.ptq_id IS NULL) OR
       (p_pmvv_rec.ptq_id = Okl_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pmv_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pmv_Pvt.g_required_value
                          ,p_token1         => Okl_Pmv_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF (p_pmvv_rec.ptq_ID IS NOT NULL)
      THEN
        OPEN okl_ptqv_pk_csr(p_pmvv_rec.PTQ_ID);
        FETCH okl_ptqv_pk_csr INTO l_ptq_status;
        l_row_notfound := okl_ptqv_pk_csr%NOTFOUND;
        CLOSE okl_ptqv_pk_csr;
        IF (l_row_notfound) THEN
          Okl_Api.set_message(Okl_Pmv_Pvt.G_APP_NAME, Okl_Pmv_Pvt.G_INVALID_VALUE,Okl_Pmv_Pvt.G_COL_NAME_TOKEN,l_token_1);
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
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pmv_Pvt.g_app_name,
                          p_msg_name     => Okl_Pmv_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pmv_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pmv_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Ptq_Id;

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
    p_pmvv_rec IN  pmvv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Ptq_Id
    Validate_Ptq_Id(p_pmvv_rec, x_return_status);
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
       Okl_Api.SET_MESSAGE(p_app_name         => Okl_Pmv_Pvt.g_app_name,
                           p_msg_name         => Okl_Pmv_Pvt.g_unexpected_error,
                           p_token1           => Okl_Pmv_Pvt.g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => Okl_Pmv_Pvt.g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

 ---------------------------------------------------------------------------
 -- PROCEDURE insert_pmvalues for: OKL_PTL_PTQ_VALS_V
 ---------------------------------------------------------------------------

 PROCEDURE insert_pmvalues(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                    	   x_return_status   OUT NOCOPY VARCHAR2,
                     	   x_msg_count       OUT NOCOPY NUMBER,
                      	   x_msg_data        OUT NOCOPY VARCHAR2,
					       p_ptlv_rec        IN  ptlv_rec_type,
                       	   p_pmvv_rec        IN  pmvv_rec_type,
                       	   x_pmvv_rec        OUT NOCOPY pmvv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_pmvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_valid	          BOOLEAN;
    l_pmvv_rec	      pmvv_rec_type;
    l_ptlv_rec	      ptlv_rec_type;
    l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_row_notfound    BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_pmvv_rec := p_pmvv_rec;

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

    l_return_status := Validate_Attributes(l_pmvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	get_parent_dates(p_pmvv_rec      => l_pmvv_rec,
                    x_no_data_found  => l_row_notfound,
	                x_return_status  => l_return_status,
	                x_ptlv_rec		 => l_ptlv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	l_pmvv_rec.from_date := l_ptlv_rec.from_date;
	l_pmvv_rec.TO_DATE   := l_ptlv_rec.TO_DATE;

    /* call check_constraints to check the validity of this relationship */

	Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_pmvv_rec 		=> l_pmvv_rec,
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

    /* public api to insert pmvalues */

    Okl_Ptq_Values_Pub.insert_ptq_values(p_api_version   => p_api_version,
                            		     p_init_msg_list => p_init_msg_list,
                       		             x_return_status => l_return_status,
                       		 	         x_msg_count     => x_msg_count,
                       		 	         x_msg_data      => x_msg_data,
                       		 	         p_pmvv_rec      => l_pmvv_rec,
                       		 	         x_pmvv_rec      => x_pmvv_rec);

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

  END insert_pmvalues;

   PROCEDURE insert_pmvalues(p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                    	   x_return_status   OUT NOCOPY VARCHAR2,
                     	   x_msg_count       OUT NOCOPY NUMBER,
                      	   x_msg_data        OUT NOCOPY VARCHAR2,
					       p_ptlv_rec        IN  ptlv_rec_type,
                       	   p_pmvv_tbl        IN  pmvv_tbl_type,
                       	   x_pmvv_tbl        OUT NOCOPY pmvv_tbl_type
                        ) IS
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;

  BEGIN

	-- Make sure PL/SQL table has records in it before passing
	IF (p_pmvv_tbl.COUNT > 0) THEN
		i := p_pmvv_tbl.FIRST;
		LOOP
			insert_pmvalues(
			  p_api_version                  => p_api_version,
			  p_init_msg_list                => OKL_API.G_FALSE,
			  x_return_status                => x_return_status,
			  x_msg_count                    => x_msg_count,
			  x_msg_data                     => x_msg_data,
			  p_ptlv_rec				=> p_ptlv_rec,
			  p_pmvv_rec                     => p_pmvv_tbl(i),
			  x_pmvv_rec                     => x_pmvv_tbl(i));

			IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
			   IF (l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			       l_overall_status := x_return_status;
			   END IF;
			END IF;

			EXIT WHEN (i = p_pmvv_tbl.LAST);
			i := p_pmvv_tbl.NEXT(i);
		END LOOP;
	END IF;

	x_return_status := l_overall_status;
  END insert_pmvalues;

   ---------------------------------------------------------------------------
  -- PROCEDURE delete_pmvalues for: okl_ptl_ptq_vals_v
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_pmvalues(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
					    ,p_ptlv_rec                     IN  ptlv_rec_type
				        ,p_pmvv_tbl                     IN  pmvv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_pmvv_tbl        pmvv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_pmvalues';
    l_pmvv_rec	      pmvv_rec_type;
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_overall_status  VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    i                 NUMBER;
    l_valid	          BOOLEAN;


  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_pmvv_tbl := p_pmvv_tbl;

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


	IF (l_pmvv_tbl.COUNT > 0) THEN
      i := l_pmvv_tbl.FIRST;
      LOOP

           /* check if the product template value asked to delete is used by contracts if yes halt the process*/
	       Check_Constraints(p_api_version  => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            p_pmvv_rec 		=> l_pmvv_tbl(i),
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

          EXIT WHEN (i = l_pmvv_tbl.LAST);

          i := l_pmvv_tbl.NEXT(i);

       END LOOP;
     END IF;

    /* delete pmvalues */
    Okl_Ptq_Values_Pub.delete_ptq_values(p_api_version   => p_api_version,
                              	     	 p_init_msg_list => p_init_msg_list,
                              		     x_return_status => l_return_status,
                              		     x_msg_count     => x_msg_count,
                              		     x_msg_data      => x_msg_data,
                              		     p_pmvv_tbl      => l_pmvv_tbl);

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

  END delete_pmvalues;

END Okl_Setuppmvalues_Pvt;

/
