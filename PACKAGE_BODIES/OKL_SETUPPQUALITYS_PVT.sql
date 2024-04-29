--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPQUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPQUALITYS_PVT" AS
/* $Header: OKLRSPQB.pls 115.18 2004/04/02 01:22:19 sgorantl noship $ */

  SUBTYPE qvev_rec_type IS Okl_Pdt_Qualitys_Pub.qvev_rec_type;
  SUBTYPE qvev_tbl_type IS Okl_Pdt_Qualitys_Pub.qvev_tbl_type;
  G_UNQS	                CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE'; --- CHG001
  G_TABLE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001

---------------------------------------------------------------------------
 -- PROCEDURE get_rec for: OKL_PDT_QUALITYS_V
---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_pqyv_rec                     IN pqyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_pqyv_rec					   OUT NOCOPY pqyv_rec_type
  ) IS
    CURSOR okl_pqyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            DESCRIPTION,
            LOCATION_YN,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Qualitys_V
     WHERE okl_pdt_qualitys_v.id = p_id;
    l_okl_pqyv_pk                  okl_pqyv_pk_csr%ROWTYPE;
    l_pqyv_rec                     pqyv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pqyv_pk_csr (p_pqyv_rec.id);
    FETCH okl_pqyv_pk_csr INTO
              l_pqyv_rec.ID,
              l_pqyv_rec.OBJECT_VERSION_NUMBER,
              l_pqyv_rec.NAME,
              l_pqyv_rec.DESCRIPTION,
              l_pqyv_rec.LOCATION_YN,
              l_pqyv_rec.FROM_DATE,
              l_pqyv_rec.TO_DATE,
              l_pqyv_rec.CREATED_BY,
              l_pqyv_rec.CREATION_DATE,
              l_pqyv_rec.LAST_UPDATED_BY,
              l_pqyv_rec.LAST_UPDATE_DATE,
              l_pqyv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pqyv_pk_csr%NOTFOUND;
    CLOSE okl_pqyv_pk_csr;
	x_pqyv_rec := l_pqyv_rec;
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

      IF (okl_pqyv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pqyv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_pqy_values for: OKL_PDT_QUALITYS
  -- To fetch the valid values for the Product Quality.
  ---------------------------------------------------------------------------
  PROCEDURE get_pqy_values (p_upd_pqyv_rec   IN pqyv_rec_type,
						    x_return_status  OUT NOCOPY VARCHAR2,
						    x_count		     OUT NOCOPY NUMBER,
						    x_qvev_tbl	     OUT NOCOPY qvev_tbl_type
  ) IS
    CURSOR okl_qvev_fk_csr (p_qve_id IN Okl_pqy_values_V.id%TYPE) IS
    SELECT qve.ID ID,
           qve.FROM_DATE FROM_DATE,
           qve.TO_DATE TO_DATE
    FROM Okl_Pqy_Values_V qve
    WHERE qve.pqy_id = p_qve_id
    AND   qve.TO_DATE IS NULL;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_qvev_tbl	    qvev_tbl_type;
    i               NUMBER := 0;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_qve_rec IN okl_qvev_fk_csr(p_upd_pqyv_rec.id)
	LOOP
       l_qvev_tbl(l_count).ID := okl_qve_rec.ID;
	   l_qvev_tbl(l_count).TO_DATE := p_upd_pqyv_rec.TO_DATE;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_qvev_tbl := l_qvev_tbl;

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

      IF (okl_qvev_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_qvev_fk_csr;
      END IF;

  END get_pqy_values;

 ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_PDT_QUALITYS_V
  -- To verify whether the dates are valid for both PRODUCT TEMPLATE VALUE and
  --   PRODUCT TEMPLATE QUALITY VALUE  -- attached to it
 ---------------------------------------------------------------------------

  PROCEDURE Check_Constraints (
   p_pqyv_rec		IN  pqyv_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_valid          OUT NOCOPY BOOLEAN
  ) IS
   CURSOR okl_pqy_constraints_csr (p_pqy_id     IN Okl_Pdt_Qualitys_V.ID%TYPE,
		   			  	           p_from_date  IN Okl_Pdt_Qualitys_V.FROM_DATE%TYPE,
							       p_to_date 	IN Okl_Pdt_Qualitys_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pqy_Values_V qve
    WHERE qve.pqy_id  = p_pqy_id
	AND   (qve.FROM_DATE < p_from_date OR
	 	    NVL(qve.TO_DATE, qve.FROM_DATE) > p_to_date)
    UNION ALL
    SELECT '2'
    FROM OKL_pdt_pqys_V pdq
    WHERE pdq.pqy_id  = p_pqy_id
	AND   (pdq.FROM_DATE < p_from_date OR
	 	    NVL(pdq.TO_DATE, pdq.FROM_DATE) > p_to_date);

    l_token_1               VARCHAR2(999);
    l_token_2               VARCHAR2(999);
    l_token_3               VARCHAR2(999);
    l_token_4               VARCHAR2(999);
    l_token_5               VARCHAR2(999);
   l_check		   	    VARCHAR2(1) := '?';
   l_row_not_found     	BOOLEAN     := FALSE;

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRDQLTY_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITIES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PQVALS_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY_VALUES');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_PQV_VAL_SUMRY',
                                                      p_attribute_code => 'OKL_PDT_QUALITY_VALUES');
    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_PDT_QLTY_SUMRY',
                                                      p_attribute_code => 'OKL_PDT_TMPL_PDT_Q_SUMRY_TITLE');


    l_token_4 := l_token_5 ||','||l_token_2;


    -- Check for constraints dates in the case of update only
    OPEN okl_pqy_constraints_csr(p_pqyv_rec.id,
		 				         p_pqyv_rec.from_date,
                                 p_pqyv_rec.TO_DATE);

    FETCH okl_pqy_constraints_csr INTO l_check;
    l_row_not_found := okl_pqy_constraints_csr%NOTFOUND;
    CLOSE okl_pqy_constraints_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_1,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_4);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
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

       IF (okl_pqy_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pqy_constraints_csr;
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
    p_pqyv_rec IN OUT NOCOPY pqyv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1     VARCHAR2(999);
  BEGIN

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PRDQLTY_CRUPD','OKL_NAME');
    IF p_pqyv_rec.name = Okl_Api.G_MISS_CHAR OR p_pqyv_rec.name IS NULL
    THEN
      Okl_Api.set_message(Okl_Pqy_Pvt.G_APP_NAME, Okl_Pqy_Pvt.G_REQUIRED_VALUE,Okl_Pqy_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    p_pqyv_rec.name := Okl_Accounting_Util.okl_upper(p_pqyv_rec.name);
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name       =>Okl_Pqy_Pvt.G_APP_NAME,
                               p_msg_name       =>Okl_Pqy_Pvt.G_UNEXPECTED_ERROR,
                               p_token1         =>Okl_Pqy_Pvt.G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>Okl_Pqy_Pvt.G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;
 ------end of Validate_Name-----------------------------------

 --------------------------------------------------------------------------
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
    p_pqyv_rec IN  pqyv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
   l_token_1     VARCHAR2(999);
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PRDQLTY_CRUPD','OKL_EFFECTIVE_FROM');
    IF p_pqyv_rec.from_date = Okl_Api.G_MISS_DATE OR p_pqyv_rec.from_date IS NULL
    THEN
      Okl_Api.set_message(Okl_Pqy_Pvt.G_APP_NAME, Okl_Pqy_Pvt.G_REQUIRED_VALUE,Okl_Pqy_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name       =>Okl_Pqy_Pvt.G_APP_NAME,
                               p_msg_name       =>Okl_Pqy_Pvt.G_UNEXPECTED_ERROR,
                               p_token1         =>Okl_Pqy_Pvt.G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>Okl_Pqy_Pvt.G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;
------end of Validate_From_Date-----------------------------------


---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

FUNCTION Validate_Attributes(
    p_pqyv_rec IN OUT NOCOPY  pqyv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;


  BEGIN
    --------CHECK FOR NAME------------------
    Validate_Name (p_pqyv_rec,x_return_status);
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
    Validate_From_Date (p_pqyv_rec,x_return_status);
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
           Okl_Api.set_message(p_app_name  =>Okl_Pqy_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Pqy_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Pqy_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Pqy_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

-----END OF VALIDATE ATTRIBUTES-------------------------


 ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_pqyv_rec                 IN pqyv_rec_type,
	p_db_pqyv_rec				   IN pqyv_rec_type
  ) RETURN pqyv_rec_type IS
  l_pqyv_rec	pqyv_rec_type;
  BEGIN

	   /* create a temporary record with all relevant details from db and upd records */
	   l_pqyv_rec := p_db_pqyv_rec;

	   IF p_upd_pqyv_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_pqyv_rec.description := p_upd_pqyv_rec.description;
	   END IF;

   	   IF p_upd_pqyv_rec.location_yn <> Okl_Api.G_MISS_CHAR THEN
	  	  l_pqyv_rec.location_yn := p_upd_pqyv_rec.location_yn;
	   END IF;

	   IF p_upd_pqyv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_pqyv_rec.from_date := p_upd_pqyv_rec.from_date;
	   END IF;

	   IF p_upd_pqyv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_pqyv_rec.TO_DATE := p_upd_pqyv_rec.TO_DATE;
	   END IF;

	   RETURN l_pqyv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_pqyv_rec                 IN OUT NOCOPY pqyv_rec_type,
	p_db_pqyv_rec				   IN pqyv_rec_type
  ) IS
  l_upd_pqyv_rec	pqyv_rec_type;
  l_db_pqyv_rec     pqyv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_pqyv_rec := p_upd_pqyv_rec;
       l_db_pqyv_rec := p_db_pqyv_rec;

	   IF l_upd_pqyv_rec.description = l_db_pqyv_rec.description THEN
	  	  l_upd_pqyv_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_pqyv_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_pqyv_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

       IF l_upd_pqyv_rec.location_yn = l_db_pqyv_rec.location_yn THEN
	  	  l_upd_pqyv_rec.location_yn := Okl_Api.G_MISS_CHAR;
	   END IF;

       p_upd_pqyv_rec := l_upd_pqyv_rec;

  END reorganize_inputs;

 -----------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
 -----------------------------------------------------------------------------

   PROCEDURE check_updates (
    p_upd_pqyv_rec                 IN pqyv_rec_type,
	p_db_pqyv_rec				   IN pqyv_rec_type,
	p_pqyv_rec					   IN pqyv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_pqyv_rec	  pqyv_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_valid	  BOOLEAN;
  BEGIN
   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
   l_pqyv_rec := p_pqyv_rec;

    /* check for start date greater than sysdate */
	/*IF to_date(to_char(p_upd_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_upd_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    */

    /* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(p_upd_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END IF;
	*/
    /* if the start date is in the past, the start date cannot be
       modified */
	/*IF to_date(to_char(p_upd_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_db_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_NOT_ALLOWED,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    */

    IF l_pqyv_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   	  l_pqyv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN

          /* call check_constraints */
	      Check_Constraints(p_pqyv_rec 	 	 => l_pqyv_rec,
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
	  x_msg_data := 'Unexpected DATABASE Error';
      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_updates;

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: Okl_pdt_Qualitys_v
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record.
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_pqyv_rec                 IN pqyv_rec_type,
	p_db_pqyv_rec				   IN pqyv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
BEGIN
  /* Scenario 1: Only description and/or descriptive flexfield changes */
  IF p_upd_pqyv_rec.from_date = Okl_Api.G_MISS_DATE AND
	 p_upd_pqyv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
	 l_action := '1';
	/* Scenario 2: Changing the dates */
  ELSE
	 l_action := '2';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE copy_update_constraints for: OKL_PQY_QUALITYS_V
  ---------------------------------------------------------------------------
  PROCEDURE copy_update_constraints (p_api_version    IN  NUMBER,
                                     p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                                     p_upd_pqyv_rec   IN  pqyv_rec_type,
									 x_return_status  OUT NOCOPY VARCHAR2,
                      		 		 x_msg_count      OUT NOCOPY NUMBER,
                              		 x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
	l_upd_pqyv_rec	 	  	pqyv_rec_type; /* input copy */
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_ptv_count				NUMBER := 0;
	l_qvev_tbl				qvev_tbl_type;
	l_out_qvev_tbl			qvev_tbl_type;

 BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_upd_pqyv_rec  := p_upd_pqyv_rec;

	/* Get Product Quality Values */
	get_pqy_values(p_upd_pqyv_rec	  => l_upd_pqyv_rec,
				   x_return_status    => l_return_status,
				   x_count		      => l_ptv_count,
				   x_qvev_tbl		  => l_qvev_tbl);

    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_ptv_count > 0 THEN
	      Okl_Pdt_Qualitys_Pub.update_pdt_quality_vals(p_api_version   => p_api_version,
                           		 		       p_init_msg_list => p_init_msg_list,
                              		 		   x_return_status => l_return_status,
                              		 		   x_msg_count     => x_msg_count,
                              		 		   x_msg_data      => x_msg_data,
                              		 		   p_qvev_tbl      => l_qvev_tbl,
                              		 		   x_qvev_tbl      => l_out_qvev_tbl);
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

 -----------------------------------------------------------------------------
  -- PROCEDURE insert_pqualities for: Okl_pdt_Qualitys_v
 -----------------------------------------------------------------------------

  PROCEDURE insert_pqualitys(p_api_version      IN  NUMBER,
                              p_init_msg_list   IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	  x_return_status   OUT NOCOPY VARCHAR2,
                        	  x_msg_count       OUT NOCOPY NUMBER,
                        	  x_msg_data        OUT NOCOPY VARCHAR2,
                        	  p_pqyv_rec        IN  pqyv_rec_type,
                        	  x_pqyv_rec        OUT NOCOPY pqyv_rec_type
                        ) IS
    CURSOR okl_pdt_quality_unique (p_unique  OKL_PDT_QUALITYS_v.NAME%TYPE) IS
      SELECT '1'
      FROM OKL_PDT_QUALITYS_v
      WHERE NAME =  p_unique;

    l_unique_key      OKL_PDT_QUALITYS_v.NAME%TYPE;
	l_row_found       BOOLEAN := FALSE;
    l_token_1         VARCHAR2(1999);
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_tqualities';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate	      DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_valid			  BOOLEAN;
    l_pqyv_rec		  pqyv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_pqyv_rec := p_pqyv_rec;
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

    l_return_status := Validate_Attributes(l_pqyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRDQLTY_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITIES');

    OPEN okl_pdt_quality_unique (Okl_Accounting_Util.okl_upper(p_pqyv_rec.name));
    FETCH okl_pdt_quality_unique INTO l_unique_key;
	l_row_found := okl_pdt_quality_unique%FOUND;
    CLOSE okl_pdt_quality_unique;

    IF l_row_found THEN
		Okl_Api.set_message('OKL',G_UNQS,G_TABLE_TOKEN, l_token_1); ---CHG001
		RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    IF (l_pqyv_rec.TO_DATE IS NOT NULL) AND (l_pqyv_rec.TO_DATE < l_pqyv_rec.from_date) THEN
          Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => Okl_Pqy_Pvt.g_to_date_error
                          ,p_token1         => Okl_Pqy_Pvt.g_col_name_token
                          ,p_token1_value   => 'to_date');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* check for the records with start and end dates less than sysdate */
    /*IF to_date(to_char(l_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
       to_date(to_char(l_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
       Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    */
     /* public api to insert tqualities */

     Okl_Pdt_Qualitys_Pub.create_pdt_qualitys(p_api_version   => p_api_version,
                        		              p_init_msg_list => p_init_msg_list,
                            		          x_return_status => l_return_status,
                          		              x_msg_count     => x_msg_count,
                              		          x_msg_data      => x_msg_data,
                             		          p_pqyv_rec      => l_pqyv_rec,
                              		          x_pqyv_rec      => x_pqyv_rec);

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

      IF (okl_pdt_quality_unique%ISOPEN) THEN
	   	  CLOSE okl_pdt_quality_unique;
       END IF;

  END insert_pqualitys;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_pqualities for: Okl_pdt_Qualitys_v
  ---------------------------------------------------------------------------
  PROCEDURE update_pqualitys(p_api_version   IN  NUMBER,
                      		p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status  OUT NOCOPY VARCHAR2,
                        	x_msg_count      OUT NOCOPY NUMBER,
                        	x_msg_data       OUT NOCOPY VARCHAR2,
							p_pqyv_rec		 IN  pqyv_rec_type,
                        	x_pqyv_rec       OUT NOCOPY pqyv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_tqualities';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_valid			  BOOLEAN;
    l_db_pqyv_rec     pqyv_rec_type; /* database copy */
	l_upd_pqyv_rec	  pqyv_rec_type; /* input copy */
	l_pqyv_rec	  	  pqyv_rec_type; /* latest with the retained changes */
	l_tmp_pqyv_rec	  pqyv_rec_type; /* for any other purposes */
    l_no_data_found   BOOLEAN := TRUE;
	l_action		  VARCHAR2(1);
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_upd_pqyv_rec := p_pqyv_rec;

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
    get_rec(p_pqyv_rec 	 	=> l_upd_pqyv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_pqyv_rec		=> l_db_pqyv_rec);

	IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	IF l_upd_pqyv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
    /* update constraints */
	copy_update_constraints(p_api_version     => p_api_version,
                            p_init_msg_list   => p_init_msg_list,
							p_upd_pqyv_rec	  => l_upd_pqyv_rec,
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
    reorganize_inputs(p_upd_pqyv_rec     => l_upd_pqyv_rec,
                      p_db_pqyv_rec      => l_db_pqyv_rec);

    /* check for past records */
    /*IF to_date(to_char(l_db_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
       to_date(to_char(l_db_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
	*/

     IF (l_upd_pqyv_rec.TO_DATE = Okl_Api.G_MISS_DATE) then
            l_upd_pqyv_rec.TO_DATE := p_pqyv_rec.to_date;
     end if;

     IF (l_upd_pqyv_rec.from_DATE = Okl_Api.G_MISS_DATE) then
         l_upd_pqyv_rec.from_DATE := p_pqyv_rec.from_date;
     end if;


     IF (l_upd_pqyv_rec.TO_DATE IS NOT NULL) AND (l_upd_pqyv_rec.TO_DATE < l_upd_pqyv_rec.from_date) THEN
          Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => Okl_Pqy_Pvt.g_to_date_error
                          ,p_token1         => Okl_Pqy_Pvt.g_col_name_token
                          ,p_token1_value   => 'to_date');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* check for start date greater than sysdate */
	/*IF to_date(to_char(l_upd_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_pqyv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    */
	/* determine how the processing to be done */
	l_action := determine_action(p_upd_pqyv_rec	 => l_upd_pqyv_rec,
			 					 p_db_pqyv_rec	 => l_db_pqyv_rec,
								 p_date			 => l_sysdate);

	/* Scenario 1: only changing description and descriptive flexfields */
	IF l_action = '1' THEN
	/* public api to update tqualities */
    Okl_Pdt_Qualitys_Pub.update_pdt_qualitys(p_api_version => p_api_version,
                              		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_pqyv_rec      => l_upd_pqyv_rec,
                              		 	   x_pqyv_rec      => x_pqyv_rec);

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
	/* Scenario 2: changing the dates */
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
    l_pqyv_rec := defaults_to_actuals(p_upd_pqyv_rec => l_upd_pqyv_rec,
					  				 p_db_pqyv_rec  => l_db_pqyv_rec);

       check_updates(p_upd_pqyv_rec	 => l_upd_pqyv_rec,
	   			     p_db_pqyv_rec	 => l_db_pqyv_rec,
					 p_pqyv_rec		 => l_pqyv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);

       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

 	/* public api to update tqualities */
    Okl_Pdt_Qualitys_Pub.update_pdt_qualitys(p_api_version   => p_api_version,
                              		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_pqyv_rec      => l_upd_pqyv_rec,
                              		 	   x_pqyv_rec      => x_pqyv_rec);

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

  END update_pqualitys;
END Okl_Setuppqualitys_Pvt;

/
