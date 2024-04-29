--------------------------------------------------------
--  DDL for Package Body OKL_SETUPDQUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPDQUALITYS_PVT" AS
/* $Header: OKLRSDQB.pls 120.5 2007/09/12 12:18:38 rajnisku ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.PRODUCTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
G_ITEM_NOT_FOUND_ERROR   EXCEPTION;
G_COLUMN_TOKEN			 CONSTANT VARCHAR2(100) := 'COLUMN';
G_TABLE_TOKEN            CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001
G_TAXOWN_SEC_MISMATCH    CONSTANT VARCHAR2(200) := 'OKL_TAXOWN_SEC_MISMATCH'; --- CHG001
G_LEASE_SEC_MISMATCH     CONSTANT VARCHAR2(200) := 'OKL_LEASE_SEC_MISMATCH'; --- CHG001
 ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PDT_PQYS_V
 ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_pdqv_rec                     IN pdqv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_pdqv_rec					   OUT NOCOPY pdqv_rec_type
  ) IS
    CURSOR okl_pdqv_pk_csr (p_id  IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PTL_ID,
            PQY_ID,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Pqys_V
     WHERE okl_pdt_pqys_v.id    = p_id;
    l_okl_pdqv_pk                  okl_pdqv_pk_csr%ROWTYPE;
    l_pdqv_rec                     pdqv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pdqv_pk_csr (p_pdqv_rec.id);
    FETCH okl_pdqv_pk_csr INTO
              l_pdqv_rec.ID,

              l_pdqv_rec.OBJECT_VERSION_NUMBER,
              l_pdqv_rec.PTL_ID,
              l_pdqv_rec.PQY_ID,
              l_pdqv_rec.FROM_DATE,
              l_pdqv_rec.TO_DATE,
              l_pdqv_rec.CREATED_BY,
              l_pdqv_rec.CREATION_DATE,
              l_pdqv_rec.LAST_UPDATED_BY,
              l_pdqv_rec.LAST_UPDATE_DATE,
              l_pdqv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pdqv_pk_csr%NOTFOUND;
    CLOSE okl_pdqv_pk_csr;
    x_pdqv_rec := l_pdqv_rec;
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

      IF (okl_pdqv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pdqv_pk_csr;
      END IF;

 END get_rec;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_parent_dates for: OKL_PDT_PQYS_V
 ---------------------------------------------------------------------------

 PROCEDURE get_parent_dates(
    p_pdqv_rec                     IN pdqv_rec_type,
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
    OPEN okl_ptl_pk_csr (p_pdqv_rec.ptl_id);
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
  -- PROCEDURE check_constraints for: Okl_Pdt_pqys_V
 -----------------------------------------------------------------------------

 PROCEDURE Check_Constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	p_pdqv_rec		 IN  pdqv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_pdqv_chk(p_ptl_id  NUMBER
	) IS
    SELECT '1' FROM okl_pdt_templates_v ptlv,
					okl_products pdtv,
					okl_k_headers_v khdr
    WHERE ptlv.id = p_ptl_id    AND

	      ptlv.id = pdtv.ptl_id AND
		  pdtv.id = khdr.pdt_id;

    CURSOR okl_pdq_ptl_fk_csr (p_ptl_id    IN Okl_Products_V.ID%TYPE,
                               p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_pdt_templates_V ptl
    WHERE ptl.ID    = p_ptl_id
    AND   NVL(ptl.TO_DATE, p_date) < p_date;

	CURSOR okl_pdq_constraints_csr (p_pqy_id     IN Okl_Pdt_Qualitys_V.ID%TYPE,
		   					        p_from_date  IN Okl_Pdt_Qualitys_V.FROM_DATE%TYPE,
							        p_to_date 	 IN Okl_Pdt_Qualitys_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pdt_Qualitys_V pqy
     WHERE pqy.ID        = p_pqy_id
	 AND   ((pqy.FROM_DATE > p_from_date OR
            p_from_date > NVL(pqy.TO_DATE,p_from_date)) OR
	 	    NVL(pqy.TO_DATE, p_to_date) < p_to_date);

  CURSOR c1(p_ptl_id okl_pdt_pqys_v.ptl_id%TYPE,
		p_pqy_id okl_pdt_pqys_v.pqy_id%TYPE) IS
  SELECT '1'
  FROM okl_pdt_pqys_v
  WHERE  ptl_id = p_ptl_id
  AND    pqy_id = p_pqy_id
  AND    id <> NVL(p_pdqv_rec.id,-9999);

  CURSOR choose_qlty_csr(cp_pqy_id okl_pdt_pqys_v.pqy_id%TYPE
  ) IS
  SELECT NAME
  FROM   okl_pdt_qualitys_v
  WHERE  id = cp_pqy_id
  AND    name IN ('LEASE','INVESTOR','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS');

  l_unq_tbl               Okc_Util.unq_tbl_type;
  l_pdq_status            VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  l_check		   	      VARCHAR2(1) := '?';
  l_row_not_found  	      BOOLEAN     := FALSE;
  l_invalid_selection_1   NUMBER(4):=0;
  l_invalid_selection_2   NUMBER(4):=0;
  l_chosen_quality        VARCHAR2(256):=NULL;
  l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_token_1        VARCHAR2(1999);
  l_token_2        VARCHAR2(1999);
  l_token_3        VARCHAR2(1999);
  l_token_4        VARCHAR2(1999);
  l_token_5        VARCHAR2(1999);
  l_token_6        VARCHAR2(1999);

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;


   l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_PDT_QLTY_SUMRY',
                                                      p_attribute_code => 'OKL_PDT_TMPL_PDT_Q_SUMRY_TITLE');

   l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
                                                           p_attribute_code => 'OKL_KDTLS_CONTRACT');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_TEMPLATE_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_TEMPLATES');

    l_token_4 := l_token_1 ||','||l_token_3;

    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRDQLTY_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITIES');

    l_token_6 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_PDT_QLTY_CREAT',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY');

    -- Check for pmvv valid dates
    OPEN okl_pdqv_chk(p_pdqv_rec.ptl_id);

    FETCH okl_pdqv_chk INTO l_check;
    l_row_not_found := okl_pdqv_chk%NOTFOUND;
    CLOSE okl_pdqv_chk;

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


    OPEN c1(p_pdqv_rec.ptl_id,
	      p_pdqv_rec.pqy_id);
    FETCH c1 INTO l_pdq_status;
    l_row_found := c1%FOUND;

    CLOSE c1;
    IF l_row_found THEN
		---Okl_Api.set_message(Okl_Pdq_Pvt.G_APP_NAME,Okl_Pdq_Pvt.G_UNQS,Okl_Pdq_Pvt.G_TABLE_TOKEN, l_token_1); ---CHG001
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


  -- Check if the product template to which the qualities are added is not
  -- in the past

    BEGIN
	OPEN choose_qlty_csr(p_pdqv_rec.pqy_id);
     FETCH choose_qlty_csr INTO l_chosen_quality;
     l_row_found := choose_qlty_csr%FOUND;
    CLOSE choose_qlty_csr;


    IF l_chosen_quality = 'LEASE'
      OR l_chosen_quality = 'TAXOWNER'
      OR l_chosen_quality = 'REVENUE_RECOGNITION_METHOD'
      OR l_chosen_quality = 'INTEREST_CALCULATION_BASIS' THEN

      SELECT COUNT(pqy.id)
		INTO l_invalid_selection_1
        FROM   OKL_PDT_PQYS_V pdq,
		       OKL_PDT_QUALITYS_V pqy
        WHERE  pdq.PTL_ID = p_pdqv_rec.ptl_id
        AND    pdq.PQY_ID = pqy.ID
        AND    pqy.name = 'INVESTOR';

    ELSIF l_chosen_quality = 'INVESTOR' THEN

      SELECT COUNT(pqy.id)
		INTO l_invalid_selection_1
        FROM   OKL_PDT_PQYS_V pdq,
		       OKL_PDT_QUALITYS_V pqy
        WHERE  pdq.PTL_ID = p_pdqv_rec.ptl_id
        AND    pdq.PQY_ID = pqy.ID
        AND    pqy.name IN ('LEASE','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS');

    END IF;


/*
    IF l_chosen_quality = 'LEASE' THEN
        SELECT COUNT(pqy.id)
		INTO l_invalid_selection_1
        FROM   OKL_PDT_PQYS_V pdq,
		       OKL_PDT_QUALITYS_V pqy
        WHERE  pdq.PTL_ID = p_pdqv_rec.ptl_id
        AND    pdq.PQY_ID = pqy.ID
        AND    pqy.name = 'INVESTOR';
    ELSIF l_chosen_quality = 'INVESTOR' THEN
        SELECT COUNT(pqy.id)
		INTO l_invalid_selection_1
        FROM   OKL_PDT_PQYS_V pdq,
	      	   OKL_PDT_QUALITYS_V pqy
        WHERE  pdq.PTL_ID = p_pdqv_rec.ptl_id
        AND    pdq.PQY_ID = pqy.ID
        AND    pqy.name = 'LEASE';
    ELSIF l_chosen_quality = 'TAXOWNER' THEN
        SELECT COUNT(pqy.id)
		INTO l_invalid_selection_2
        FROM   OKL_PDT_PQYS_V pdq,
		       OKL_PDT_QUALITYS_V pqy
        WHERE  pdq.PTL_ID = p_pdqv_rec.ptl_id
        AND    pdq.PQY_ID = pqy.ID
        AND    pqy.name = 'INVESTOR';
    ELSIF l_chosen_quality = 'INVESTOR' THEN
        SELECT COUNT(pqy.id)
		INTO l_invalid_selection_2
        FROM   OKL_PDT_PQYS_V pdq,
		       OKL_PDT_QUALITYS_V pqy
        WHERE  pdq.PTL_ID = p_pdqv_rec.ptl_id
        AND    pdq.PQY_ID = pqy.ID
        AND    pqy.name = 'TAXOWNER';
    END IF;

*/

    IF  l_invalid_selection_1 > 0 THEN
        Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_LEASE_SEC_MISMATCH);

	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

/*
    IF  l_invalid_selection_2 > 0 THEN
        Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_TAXOWN_SEC_MISMATCH);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
*/
  END;


   -- Check for constraints dates
   IF p_pdqv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pdq_constraints_csr (p_pdqv_rec.pqy_id,
		 					  	  p_pdqv_rec.from_date,
							  	  p_pdqv_rec.TO_DATE);
    FETCH okl_pdq_constraints_csr INTO l_check;
    l_row_not_found := okl_pdq_constraints_csr%NOTFOUND;
    CLOSE okl_pdq_constraints_csr;

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


       IF (okl_pdqv_chk%ISOPEN) THEN
	   	  CLOSE okl_pdqv_chk;
       END IF;

       IF (okl_pdq_ptl_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pdq_ptl_fk_csr;
       END IF;

	   IF (okl_pdq_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pdq_constraints_csr;
       END IF;

  	   IF (choose_qlty_csr%ISOPEN) THEN
	   	  CLOSE choose_qlty_csr;
       END IF;

 END Check_Constraints;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pqy_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pqy_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pqy_Id(p_pdqv_rec      IN   pdqv_rec_type
					   ,x_return_status OUT  NOCOPY VARCHAR2)
  IS

      CURSOR okl_pqyv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_pdt_qualitys_v
       WHERE okl_pdt_qualitys_v.id = p_id;

      l_pqy_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
	  l_token_1                      VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_PDT_QLTY_CREAT',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY');

    -- check for data before processing
    IF (p_pdqv_rec.pqy_id IS NULL) OR
       (p_pdqv_rec.pqy_id = Okl_Api.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDQB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pdq_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pdq_Pvt.g_required_value
                          ,p_token1         => Okl_Pdq_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDQB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

      IF (p_pdqv_rec.pqy_ID IS NOT NULL)
      THEN
        OPEN okl_pqyv_pk_csr(p_pdqv_rec.PQY_ID);

        FETCH okl_pqyv_pk_csr INTO l_pqy_status;
        l_row_notfound := okl_pqyv_pk_csr%NOTFOUND;
        CLOSE okl_pqyv_pk_csr;
        IF (l_row_notfound) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.set_message
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDQB.pls call Okl_Api.set_message ');
    END;
  END IF;
          Okl_Api.set_message(Okl_Pdq_Pvt.G_APP_NAME, Okl_Pdq_Pvt.G_INVALID_VALUE,Okl_Pdq_Pvt.G_COL_NAME_TOKEN,l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDQB.pls call Okl_Api.set_message ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.set_message
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdq_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdq_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdq_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdq_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Pqy_Id;

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
    p_pdqv_rec IN  pdqv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Pqy_Id
    Validate_Pqy_Id(p_pdqv_rec,x_return_status);
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
       Okl_Api.SET_MESSAGE(p_app_name         => Okl_Pdq_Pvt.g_app_name,
                           p_msg_name         => Okl_Pdq_Pvt.g_unexpected_error,
                           p_token1           => Okl_Pdq_Pvt.g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => Okl_Pdq_Pvt.g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE copy_dependent_qualitys for: OKL_PDT_PQYS_V
  ---------------------------------------------------------------------------

  PROCEDURE copy_dependent_qualitys (p_api_version    IN  NUMBER,
                                    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
  								   	p_pdqv_rec       IN  pdqv_rec_type,
                                    p_name           IN  okl_pdt_qualitys_v.name%TYPE,
						            x_return_status  OUT NOCOPY VARCHAR2,
                      		 		x_msg_count      OUT NOCOPY NUMBER,
                              		x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
   CURSOR get_pqy_csr(cp_name okl_pdt_qualitys_v.name%TYPE
    ) IS
    SELECT id
    FROM   okl_pdt_qualitys_v pqy
    WHERE  pqy.name = cp_name;

	l_pdqv_rec	  	 	  	pdqv_rec_type;
    l_out_pdqv_rec	  	 	pdqv_rec_type;
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_psy_count             NUMBER := 0;
	l_name                  okl_pdt_qualitys_v.name%TYPE;
    l_pqy_id                okl_pdt_qualitys_v.id%TYPE;

 BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_pdqv_rec := p_pdqv_rec;
    l_pdqv_rec := p_pdqv_rec;
	l_name  := p_name;

	OPEN get_pqy_csr(l_name);
    FETCH get_pqy_csr INTO l_pqy_id;
    IF get_pqy_csr%NOTFOUND THEN
      NULL;
    END IF;
    CLOSE get_pqy_csr;

	IF l_pqy_id <> Okl_Api.G_MISS_NUM AND l_pqy_id IS NOT NULL THEN

	--Default the dependent quality
	l_pdqv_rec.pqy_id := l_pqy_id;

-- Start of wraper code generated automatically by Debug code generator for okl_pdt_pqys_pub.insert_pdt_pqys
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDQB.pls call okl_pdt_pqys_pub.insert_pdt_pqys ');
    END;
  END IF;
	      okl_pdt_pqys_pub.insert_pdt_pqys(p_api_version   => p_api_version,
                           		 		     p_init_msg_list => p_init_msg_list,
                              		 		 x_return_status => l_return_status,
                              		 		 x_msg_count     => x_msg_count,
                              		 		 x_msg_data      => x_msg_data,
                              		 		 p_pdqv_rec      => l_pdqv_rec,
                           		 		     x_pdqv_rec      => l_out_pdqv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDQB.pls call okl_pdt_pqys_pub.insert_pdt_pqys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_pdt_pqys_pub.insert_pdt_pqys
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

  END copy_dependent_qualitys;

 ---------------------------------------------------------------------------
 -- PROCEDURE insert_dqualitys for: Okl_Pdt_pqys_V
 ---------------------------------------------------------------------------

 PROCEDURE insert_dqualitys(p_api_version     IN  NUMBER,
                            p_init_msg_list   IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                    		x_return_status   OUT NOCOPY VARCHAR2,
                     		x_msg_count       OUT NOCOPY NUMBER,

                      		x_msg_data        OUT NOCOPY VARCHAR2,
						    p_ptlv_rec        IN  ptlv_rec_type,
                       		p_pdqv_rec        IN  pdqv_rec_type,
                       		x_pdqv_rec        OUT NOCOPY pdqv_rec_type
                        ) IS

   CURSOR choose_qualitys_csr(cp_pqy_id okl_pdt_qualitys_v.id%TYPE
    ) IS
    SELECT name
    FROM   okl_pdt_qualitys_v pqy
    WHERE  pqy.ID = cp_pqy_id;


   CURSOR get_dependent_qualitys_csr(P_choosen_quality okl_pdt_qualitys_v.NAME%TYPE
    ) IS
    SELECT name
    FROM   okl_pdt_qualitys_v pqy
    WHERE  pqy.NAME <> P_choosen_quality
    AND pqy.NAME IN ('LEASE','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS');


    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_dqualitys';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_choosen_quality okl_pdt_qualitys_v.name%TYPE;
    l_dependent_quality okl_pdt_qualitys_v.name%TYPE;
    l_dependent_quality_cnt  NUMBER(4):= 0;
    l_valid	          BOOLEAN;
    l_pdqv_rec	      pdqv_rec_type;
    l_ptlv_rec	      ptlv_rec_type;
    l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_pdqv_rec := p_pdqv_rec;

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

	l_return_status := Validate_Attributes(l_pdqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	get_parent_dates(p_pdqv_rec       => l_pdqv_rec,
                     x_no_data_found  => l_row_notfound,
	                 x_return_status  => l_return_status,
	                 x_ptlv_rec		  => l_ptlv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--l_ptlv_rec := x_ptlv_rec;
	--assign parent dates.

	l_pdqv_rec.from_date := l_ptlv_rec.from_date;
	l_pdqv_rec.TO_DATE   := l_ptlv_rec.TO_DATE;

    /* call check_constraints to check the validity of this relationship */

	Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_pdqv_rec 		=> l_pdqv_rec,
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

    /* public api to insert dqualitys */
-- Start of wraper code generated automatically by Debug code generator for Okl_Pdt_Pqys_Pub.insert_pdt_pqys
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDQB.pls call Okl_Pdt_Pqys_Pub.insert_pdt_pqys ');
    END;
  END IF;
    Okl_Pdt_Pqys_Pub.insert_pdt_pqys(p_api_version   => p_api_version,
                          		     p_init_msg_list => p_init_msg_list,

                       		 	     x_return_status => l_return_status,
                       		 	     x_msg_count     => x_msg_count,
                       		 	     x_msg_data      => x_msg_data,
                       		 	     p_pdqv_rec      => l_pdqv_rec,
                       		 	     x_pdqv_rec      => x_pdqv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDQB.pls call Okl_Pdt_Pqys_Pub.insert_pdt_pqys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pdt_Pqys_Pub.insert_pdt_pqys

     IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

 /* BEGIN --- commented by rajnisku bug 6398092
   OPEN choose_qualitys_csr(l_pdqv_rec.pqy_id);
   FETCH choose_qualitys_csr INTO l_choosen_quality;
   IF choose_qualitys_csr%NOTFOUND THEN
      NULL;
   END IF;
   CLOSE choose_qualitys_csr;

   IF l_choosen_quality = 'LEASE'
      OR l_choosen_quality = 'TAXOWNER'
      OR l_choosen_quality = 'REVENUE_RECOGNITION_METHOD'
      OR l_choosen_quality = 'INTEREST_CALCULATION_BASIS' THEN
      FOR get_dependent_qualitys_rec in get_dependent_qualitys_csr(l_choosen_quality)
      loop
       copy_dependent_qualitys(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               p_pdqv_rec	 => l_pdqv_rec,
   	   		       p_name            => get_dependent_qualitys_rec.NAME,
                               x_return_status   => l_return_status,
           		       x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data);
       END LOOP;

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
    END IF;
  END;
  */

/*
   IF l_choosen_quality = 'LEASE' THEN
     SELECT COUNT(pqy.id)
	 INTO l_dependent_quality_cnt
     FROM   okl_pdt_pqys_v pdq,
	        okl_pdt_qualitys_v pqy
     WHERE  pdq.ptl_id = l_pdqv_rec.ptl_id
     AND    pdq.pqy_id = pqy.id
     AND    pqy.name = 'TAXOWNER';
   ELSIF l_choosen_quality = 'TAXOWNER' THEN
     SELECT COUNT(pqy.id)
	 INTO l_dependent_quality_cnt
     FROM   okl_pdt_pqys_v pdq,
	        okl_pdt_qualitys_v pqy
     WHERE  pdq.ptl_id = l_pdqv_rec.ptl_id
     AND    pdq.pqy_id = pqy.id
     AND    pqy.name = 'LEASE';
   ELSIF l_choosen_quality = 'REVENUE_RECOGNITION_METHOD' THEN
     SELECT COUNT(pqy.id)
	 INTO l_dependent_quality_cnt
     FROM   okl_pdt_pqys_v pdq,
	        okl_pdt_qualitys_v pqy
     WHERE  pdq.ptl_id = l_pdqv_rec.ptl_id
     AND    pdq.pqy_id = pqy.id
     AND    pqy.name = 'LEASE';
   ELSIF l_choosen_quality = 'TAXOWNER' THEN
     SELECT COUNT(pqy.id)
	 INTO l_dependent_quality_cnt
     FROM   okl_pdt_pqys_v pdq,
	        okl_pdt_qualitys_v pqy
     WHERE  pdq.ptl_id = l_pdqv_rec.ptl_id
     AND    pdq.pqy_id = pqy.id
     AND    pqy.name = 'LEASE';
   END IF;


   IF l_choosen_quality = 'LEASE' AND l_dependent_quality_cnt = 0 THEN
       copy_dependent_qualitys(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               p_pdqv_rec		 => l_pdqv_rec,
							   p_name            => 'TAXOWNER',
                               x_return_status   => l_return_status,
                    		   x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
   ELSIF l_choosen_quality = 'TAXOWNER' and l_dependent_quality_cnt = 0 THEN
     copy_dependent_qualitys(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               p_pdqv_rec		 => l_pdqv_rec,
							   p_name            => 'LEASE',
                               x_return_status   => l_return_status,
                    		   x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
   END IF;
*/
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

       IF (choose_qualitys_csr%ISOPEN) THEN
	   	  CLOSE choose_qualitys_csr;
       END IF;

  END insert_dqualitys;


   PROCEDURE insert_dqualitys(p_api_version     IN  NUMBER,
                            p_init_msg_list   IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                    		x_return_status   OUT NOCOPY VARCHAR2,
                     		x_msg_count       OUT NOCOPY NUMBER,

                      		x_msg_data        OUT NOCOPY VARCHAR2,
						    p_ptlv_rec        IN  ptlv_rec_type,
                       		p_pdqv_tbl        IN  pdqv_tbl_type,
                       		x_pdqv_tbl        OUT NOCOPY pdqv_tbl_type
                        ) IS
     l_api_name        CONSTANT VARCHAR2(30)  := 'insert_dqualitys';
	l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	i                       NUMBER := 0;
	do_copy    NUMBER := 0;
 CURSOR copy_allowed_csr  IS
		select 1  from okl_pdt_qualitys pdtq ,okl_pdt_pqys pdt
    where pdtq.id = pdt.pqy_id and pdt.ptl_id=p_pdqv_tbl(i).ptl_id
    and pdtq.name IN ('LEASE','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS');


		 CURSOR get_dependent_qualitys_csr--- added by rajnisku for bug 6398092 get the dependent qualitites not selected by the user
     IS
    SELECT name
    FROM   okl_pdt_qualitys_v pqy
    WHERE  pqy.NAME not in ( select pdtq.name from okl_pdt_qualitys pdtq ,okl_pdt_pqys pdt
    where pdtq.id = pdt.pqy_id and pdt.ptl_id=p_pdqv_tbl(i).ptl_id)
    AND pqy.NAME IN ('LEASE','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS');

	BEGIN
		-- Make sure PL/SQL table has records in it before passing
		IF (p_pdqv_tbl.COUNT > 0) THEN
			i := p_pdqv_tbl.FIRST;
			LOOP
				insert_dqualitys(
				  p_api_version                  => p_api_version,
				  p_init_msg_list                => OKL_API.G_FALSE,
				  x_return_status                => x_return_status,
				  x_msg_count                    => x_msg_count,
				  x_msg_data                     => x_msg_data,
				  p_ptlv_rec				=> p_ptlv_rec,
				  p_pdqv_rec                     => p_pdqv_tbl(i),
				  x_pdqv_rec                     => x_pdqv_tbl(i));
				  		IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	    EXIT WHEN (i = p_pdqv_tbl.LAST);
				i := p_pdqv_tbl.NEXT(i);
			END LOOP;
	BEGIN
	IF(do_copy=0) THEN
		OPEN copy_allowed_csr;
       FETCH copy_allowed_csr INTO do_copy;
       IF copy_allowed_csr%NOTFOUND THEN
        NULL;
       END IF;
       CLOSE copy_allowed_csr;
       END if;
  IF (do_copy=1) THEN
      FOR get_dependent_qualitys_rec in get_dependent_qualitys_csr
      loop
       copy_dependent_qualitys(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               p_pdqv_rec	 => p_pdqv_tbl(i),
   	   		                     p_name      => get_dependent_qualitys_rec.NAME,
                               x_return_status => l_overall_status,
           		               x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data);
       END LOOP;

	END IF;
END ;

		END IF;
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




   END insert_dqualitys;

  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE delete_pdt_pqys for: Okl_Pdt_pqys_V
  -- Private procedure called from delete_dqualitys.
  ---------------------------------------------------------------------------

  PROCEDURE delete_pdt_pqys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ptlv_rec              IN  ptlv_rec_type
    ,p_pdqv_rec              IN  pdqv_rec_type) IS

    i                        PLS_INTEGER :=0;
    l_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_del_pqvv_tbl           Okl_Pqy_Values_Pub.pqvv_tbl_type;

    CURSOR pqv_csr IS
      SELECT pqvv.id
        FROM okl_pdt_pqy_vals_v pqvv
       WHERE pqvv.pdq_id = p_pdqv_rec.id;

  BEGIN

    FOR pqv_rec IN pqv_csr
    LOOP
      i := i + 1;
      l_del_pqvv_tbl(i).id := pqv_rec.id;
    END LOOP;
    IF l_del_pqvv_tbl.COUNT > 0 THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.delete_pqy_values
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDQB.pls call Okl_Pqy_Values_Pub.delete_pqy_values ');
    END;
  END IF;
     Okl_Pqy_Values_Pub.delete_pqy_values(p_api_version  => p_api_version,
                               	     	 p_init_msg_list => p_init_msg_list,
                              		     x_return_status => l_return_status,
                              		     x_msg_count     => x_msg_count,
                              		     x_msg_data      => x_msg_data,
                              		     p_pqvv_tbl      => l_del_pqvv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDQB.pls call Okl_Pqy_Values_Pub.delete_pqy_values ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.delete_pqy_values

      IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_PROCESSING;
      ELSE
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN

          l_return_status := x_return_status;
        END IF;
      END IF;
    END IF;
    --Delete the Master
-- Start of wraper code generated automatically by Debug code generator for Okl_Pdt_Pqys_Pub.delete_pdt_pqys
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDQB.pls call Okl_Pdt_Pqys_Pub.delete_pdt_pqys ');
    END;
  END IF;
    Okl_Pdt_Pqys_Pub.delete_pdt_pqys(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_pdqv_rec      => p_pdqv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDQB.pls call Okl_Pdt_Pqys_Pub.delete_pdt_pqys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pdt_Pqys_Pub.delete_pdt_pqys

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
  END delete_pdt_pqys;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_dqualitys for: Okl_Pdt_pqys_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------

  PROCEDURE delete_dqualitys( p_api_version                  IN  NUMBER
                           ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                           ,x_return_status                OUT NOCOPY VARCHAR2
                           ,x_msg_count                    OUT NOCOPY NUMBER
                           ,x_msg_data                     OUT NOCOPY VARCHAR2
                           ,p_ptlv_rec                     IN  ptlv_rec_type
                           ,p_pdqv_tbl                     IN  pdqv_tbl_type ) IS

  l_api_version     CONSTANT NUMBER := 1;
  i                 PLS_INTEGER :=0;
  l_pdqv_tbl        pdqv_tbl_type;
  l_ptlv_rec        ptlv_rec_type;

  l_api_name        CONSTANT VARCHAR2(30)  := 'delete_dqualitys';
  l_pdqv_rec        pdqv_rec_type;
  l_valid           BOOLEAN;
  l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
  l_overall_status  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS; --TCHGS

  j                 PLS_INTEGER :=0;
  id_count          number(10):=0;
  other_id          number;
  l_other_id        number;

  CURSOR delete_dep_quality_csr(P_PDQ_ID NUMBER,P_PTL_ID NUMBER) IS
  Select pdq.Id
       From   okl_pdt_pqys pdq,
              okl_pdt_qualitys pqy
       Where  pdq.Id <> P_PDQ_ID
       and    pdq.pqy_id = pqy.id
       and    pqy.name in ('LEASE','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS')
       and    pdq.ptl_id = P_PTL_ID;


  Function id_exists(id in number) return boolean is
   k  PLS_INTEGER :=0;
   id_flag boolean := False;
  Begin
   k := l_pdqv_tbl.FIRST;
   LOOP
     IF l_pdqv_tbl(k).id = id then
       id_flag := TRUE;
       EXIT;
     END IF;
     EXIT WHEN k = l_pdqv_tbl.LAST;
     k := l_pdqv_tbl.NEXT(k);
   END LOOP;
   RETURN(id_flag);
  End;

  procedure insert_id(id in number,
  l_pdqv_tbl IN OUT NOCOPY pdqv_tbl_type) Is
   l PLS_INTEGER := 0;
   x PLS_INTEGER := 0;
  Begin
   l := l_pdqv_tbl.LAST;
   --l := l_pdqv_tbl.NEXT(l);
   x := l + 1;
   l_pdqv_tbl(x).Id := id;
  End;

BEGIN
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;
  l_pdqv_tbl := p_pdqv_tbl;
  l_ptlv_rec := p_ptlv_rec;

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


   IF (l_pdqv_tbl.COUNT > 0) THEN
    j := p_pdqv_tbl.FIRST;
    LOOP
     Select count(*) into id_count
     From   okl_pdt_pqys pdq,
            okl_pdt_qualitys pqy
     Where  pdq.Id = p_pdqv_tbl(j).Id
     and    pdq.pqy_id = pqy.id
     and    pqy.name in ('LEASE','TAXOWNER','REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS')
     and    pdq.ptl_id = p_pdqv_tbl(j).ptl_id;

     If id_count >= 1 then

     /*  Select pdq.Id into other_id
       From   okl_pdt_pqys pdq,
              okl_pdt_qualitys pqy
       Where  pdq.Id <> p_pdqv_tbl(j).Id
       and    pdq.pqy_id = pqy.id
       and    pqy.name in ('LEASE','TAXOWNER','REVENUE RECOGNITION METHOD','INTEREST_CALCULATION_BASIS')
       and    pdq.ptl_id = p_pdqv_tbl(j).ptl_id;*/

      FOR delete_dep_quality_rec in delete_dep_quality_csr(P_PDQ_ID => p_pdqv_tbl(j).Id,
	    						   P_PTL_ID => p_pdqv_tbl(j).ptl_id)
      LOOP

      l_other_id := delete_dep_quality_rec.id;

      If NOT(ID_EXISTS(l_other_id)) then
         insert_id(l_other_id,l_pdqv_tbl);
      End if;
      END LOOP;

     End if;

     EXIT WHEN (j = p_pdqv_tbl.LAST);
     j := p_pdqv_tbl.NEXT(j);
    END LOOP;
  END IF;

  IF (l_pdqv_tbl.COUNT > 0) THEN
      i := l_pdqv_tbl.FIRST;
      LOOP


  /* check if the product asked to delete is used by contracts if yes halt the process*/

 		 Check_Constraints(p_api_version    => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            p_pdqv_rec 		=> l_pdqv_tbl(i),
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


        delete_pdt_pqys(
                        p_api_version    => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                    ,p_ptlv_rec      => l_ptlv_rec
                        ,p_pdqv_rec      => l_pdqv_tbl(i)
                        );
           -- store the highest degree of error
     IF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
        (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
         l_valid <> TRUE) THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := l_return_status;
         END IF;
     END IF;

      EXIT WHEN (i = l_pdqv_tbl.LAST);

      i := l_pdqv_tbl.NEXT(i);
      END LOOP;
    --TCHGS: return overall status
   x_return_status := l_overall_status;
    END IF;

   Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
           x_msg_data   => x_msg_data);

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

  END delete_dqualitys;


END Okl_Setupdqualitys_Pvt;

/
