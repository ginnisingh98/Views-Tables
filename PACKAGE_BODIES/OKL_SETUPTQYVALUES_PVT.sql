--------------------------------------------------------
--  DDL for Package Body OKL_SETUPTQYVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPTQYVALUES_PVT" AS
/* $Header: OKLRSEVB.pls 115.17 2003/07/23 18:32:17 sgorantl noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PTQ_VALUES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_ptvv_rec                     IN ptvv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_ptvv_rec					   OUT NOCOPY ptvv_rec_type
  ) IS
    CURSOR okl_ptvv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PTQ_ID,
            VALUE,
            DESCRIPTION,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ptq_Values_V
     WHERE okl_ptq_values_v.id  = p_id;
    l_okl_ptvv_pk                  okl_ptvv_pk_csr%ROWTYPE;
    l_ptvv_rec                     ptvv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ptvv_pk_csr (p_ptvv_rec.id);
    FETCH okl_ptvv_pk_csr INTO
              l_ptvv_rec.ID,
              l_ptvv_rec.OBJECT_VERSION_NUMBER,
              l_ptvv_rec.PTQ_ID,
              l_ptvv_rec.VALUE,
              l_ptvv_rec.DESCRIPTION,
              l_ptvv_rec.FROM_DATE,
              l_ptvv_rec.TO_DATE,
              l_ptvv_rec.CREATED_BY,
              l_ptvv_rec.CREATION_DATE,
              l_ptvv_rec.LAST_UPDATED_BY,
              l_ptvv_rec.LAST_UPDATE_DATE,
              l_ptvv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ptvv_pk_csr%NOTFOUND;
    CLOSE okl_ptvv_pk_csr;
    x_ptvv_rec := l_ptvv_rec;
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

      IF (okl_ptvv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ptvv_pk_csr;
      END IF;

  END get_rec;


 ---------------------------------------------------------------------------
  -- PROCEDURE default_parent_dates for: OKL_PTQ_VALUES_V
 ---------------------------------------------------------------------------

 PROCEDURE default_parent_dates(
    p_ptvv_rec		  IN ptvv_rec_type,
    x_no_data_found   OUT NOCOPY BOOLEAN,
	x_return_status	  OUT NOCOPY VARCHAR2,
	x_ptqv_rec		  OUT NOCOPY ptqv_rec_type
  ) IS
    CURSOR okl_ptqv_pk_csr (p_ptq_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_ptl_qualitys_V ptq
     WHERE ptq.id = p_ptq_id;
    l_okl_ptqv_pk                  okl_ptqv_pk_csr%ROWTYPE;
    l_ptqv_rec                     ptqv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
	-- Get current database values
    OPEN okl_ptqv_pk_csr (p_ptvv_rec.ptq_id);
    FETCH okl_ptqv_pk_csr INTO
              l_ptqv_rec.FROM_DATE,
              l_ptqv_rec.TO_DATE;
    x_no_data_found := okl_ptqv_pk_csr%NOTFOUND;
    CLOSE okl_ptqv_pk_csr;
    x_ptqv_rec := l_ptqv_rec;
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

      IF (okl_ptqv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ptqv_pk_csr;
      END IF;

 END default_parent_dates;

 ---------------------------------------------------------------------------
  -- PROCEDURE validate_Pkeys for: OKL_PTQ_VALUES_V
  -- To verify whether the dates are valid for PRODUCT TEMPLATE QUALITY
 ---------------------------------------------------------------------------

PROCEDURE Check_Constraints (
 p_ptvv_rec		  IN OUT  NOCOPY ptvv_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_valid          OUT NOCOPY BOOLEAN
  ) IS

   CURSOR okl_chk_ptq_csr(p_ptq_id      NUMBER,
                         p_from_date  DATE,
			             p_to_date	 DATE
	) IS
    SELECT '1'
    FROM   okl_ptl_qualitys_v ptqv
    WHERE  ptqv.ID = p_ptq_id
	AND   ((ptqv.FROM_DATE > p_from_date OR
	       p_from_date > NVL(ptqv.TO_DATE,p_from_date) OR
	 	    NVL(ptqv.TO_DATE, p_to_date) < p_to_date));

    CURSOR okl_chk_pmv_csr(p_ptv_id    NUMBER,
                          p_from_date  DATE,
	 	                  p_to_date	   DATE
	) IS
    SELECT '1'
    FROM OKL_ptl_ptq_vals_v pmvv
    WHERE  pmvv.ptv_id = p_ptv_id
		AND   (pmvv.FROM_DATE < p_from_date OR
	 	    NVL(pmvv.TO_DATE, pmvv.FROM_DATE) > p_to_date);

    CURSOR c1(p_value okl_ptq_values_v.value%TYPE,
     		  p_ptq_id okl_ptq_values_v.ptq_id%TYPE
    ) IS
    SELECT '1'
    FROM okl_ptq_values_v
    WHERE  value = p_value
    AND    ptq_id = p_ptq_id;
--    AND id <> NVL(p_ptvv_rec.id,-9999);

    l_token_1        VARCHAR2(1999);
    l_token_2        VARCHAR2(1999);
    l_token_3        VARCHAR2(1999);
    l_check		   	 VARCHAR2(1) := '?';
    l_row_not_found  BOOLEAN     := FALSE;
    l_unq_tbl               Okc_Util.unq_tbl_type;
    l_ptv_status            VARCHAR2(1);
    l_row_found             BOOLEAN := FALSE;

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_TMPVALS_CRUPD',
                                                      p_attribute_code => 'OKL_TEMPLATE_QUALITY_VALUES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_TMPQLTY_CRUPD',
                                                      p_attribute_code => 'OKL_TEMPLATE_QUALITIES');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_TMPL_QLTY_SUMRY',
                                                      p_attribute_code => 'OKL_PDT_QLTY_SUMRY_TITLE');


    IF p_ptvv_rec.id = Okl_Api.G_MISS_NUM THEN
       p_ptvv_rec.value := Okl_Accounting_Util.okl_upper(p_ptvv_rec.value);
       OPEN c1(p_ptvv_rec.value,
	      p_ptvv_rec.ptq_id);
    FETCH c1 INTO l_ptv_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
  	   Okl_Api.set_message(G_APP_NAME,Okl_Ptv_Pvt.G_UNQS,Okl_Ptv_Pvt.G_TABLE_TOKEN, l_token_1); ---CHG001
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
     END IF;
   END IF;

   IF p_ptvv_rec.id <> Okl_Api.G_MISS_NUM THEN
    -- Check for Child dates
    OPEN okl_chk_pmv_csr(p_ptvv_rec.id,
              		 	p_ptvv_rec.from_date,
		                p_ptvv_rec.TO_DATE);

    FETCH okl_chk_pmv_csr INTO l_check;
    l_row_not_found := okl_chk_pmv_csr%NOTFOUND;
    CLOSE okl_chk_pmv_csr;

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
   END IF;

    -- Check for Parent dates
    OPEN okl_chk_ptq_csr(p_ptvv_rec.ptq_id,
		 	  			p_ptvv_rec.from_date,
		         		p_ptvv_rec.TO_DATE);

    FETCH okl_chk_ptq_csr INTO l_check;
    l_row_not_found := okl_chk_ptq_csr%NOTFOUND;
    CLOSE okl_chk_ptq_csr;

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

       IF (okl_chk_pmv_csr%ISOPEN) THEN
	   	  CLOSE okl_chk_pmv_csr;
       END IF;

	   IF (okl_chk_ptq_csr%ISOPEN) THEN
	   	  CLOSE okl_chk_ptq_csr;
       END IF;

	   IF (c1%ISOPEN) THEN
	   	  CLOSE c1;
       END IF;

 END Check_Constraints;

 PROCEDURE Validate_From_Date(p_ptvv_rec      IN      ptvv_rec_type
						  ,x_return_status OUT  NOCOPY VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1        VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_TMPVALS_CRUPD','OKL_EFFECTIVE_FROM');

    -- check for data before processing
    IF (p_ptvv_rec.from_date IS NULL) OR
       (p_ptvv_rec.from_date = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Ptv_Pvt.g_app_name
                          ,p_msg_name       => Okl_Ptv_Pvt.g_required_value
                          ,p_token1         => Okl_Ptv_Pvt.g_col_name_token
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
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Ptv_Pvt.g_app_name,
                          p_msg_name     => Okl_Ptv_Pvt.g_unexpected_error,
                          p_token1       => Okl_Ptv_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Ptv_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Value(p_ptvv_rec      IN OUT NOCOPY ptvv_rec_type
						  ,x_return_status OUT  NOCOPY VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1        VARCHAR2(1999);
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_TMPVALS_CRUPD','OKL_NAME');

    -- check for data before processing
    IF (p_ptvv_rec.value IS NULL) OR
       (p_ptvv_rec.value = Okl_Api.G_MISS_CHAR) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Ptv_Pvt.g_app_name
                          ,p_msg_name       => Okl_Ptv_Pvt.g_required_value
                          ,p_token1         => Okl_Ptv_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	p_ptvv_rec.value := Okl_Accounting_Util.okl_upper(p_ptvv_rec.value);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Ptv_Pvt.g_app_name,
                          p_msg_name     => Okl_Ptv_Pvt.g_unexpected_error,
                          p_token1       => Okl_Ptv_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Ptv_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Value;

 FUNCTION Validate_Attributes (
    p_ptvv_rec IN OUT  NOCOPY ptvv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Value
    Validate_Value(p_ptvv_rec,x_return_status);
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

    -- Validate_From_Date
    Validate_From_Date(p_ptvv_rec,x_return_status);
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
       Okl_Api.SET_MESSAGE(p_app_name         => Okl_Ptv_Pvt.g_app_name,
                           p_msg_name         => Okl_Ptv_Pvt.g_unexpected_error,
                           p_token1           => Okl_Ptv_Pvt.g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => Okl_Ptv_Pvt.g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

 ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
 ---------------------------------------------------------------------------

  FUNCTION defaults_to_actuals (
    p_upd_ptvv_rec                 IN ptvv_rec_type,
	p_db_ptvv_rec				   IN ptvv_rec_type
  ) RETURN ptvv_rec_type IS
  l_ptvv_rec	ptvv_rec_type;
  BEGIN

     /* create a temporary record with all relevant details from db and upd records */
	   l_ptvv_rec := p_db_ptvv_rec;

	   IF p_upd_ptvv_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_ptvv_rec.description := p_upd_ptvv_rec.description;
	   END IF;

   	   IF p_upd_ptvv_rec.value <> Okl_Api.G_MISS_CHAR THEN
	  	  l_ptvv_rec.value := p_upd_ptvv_rec.value;
	   END IF;

	   IF p_upd_ptvv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_ptvv_rec.from_date := p_upd_ptvv_rec.from_date;
	   END IF;

	   IF p_upd_ptvv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_ptvv_rec.TO_DATE := p_upd_ptvv_rec.TO_DATE;
	   END IF;

	   RETURN l_ptvv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_ptvv_rec                 IN OUT NOCOPY ptvv_rec_type,
	p_db_ptvv_rec				   IN ptvv_rec_type
  ) IS
  l_upd_ptvv_rec	ptvv_rec_type;
  l_db_ptvv_rec     ptvv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_ptvv_rec := p_upd_ptvv_rec;
       l_db_ptvv_rec  := p_db_ptvv_rec;

	   IF l_upd_ptvv_rec.description = l_db_ptvv_rec.description THEN
	  	  l_upd_ptvv_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_ptvv_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_ptvv_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

       IF l_upd_ptvv_rec.value = l_db_ptvv_rec.value THEN
	  	  l_upd_ptvv_rec.value := Okl_Api.G_MISS_CHAR;
	   END IF;

       p_upd_ptvv_rec := l_upd_ptvv_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
 PROCEDURE check_updates (
    p_upd_ptvv_rec                 IN ptvv_rec_type,
	p_db_ptvv_rec				   IN ptvv_rec_type,
	p_ptvv_rec					   IN ptvv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_ptvv_rec	  ptvv_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_valid	  BOOLEAN;
  BEGIN

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
   l_ptvv_rec := p_ptvv_rec;


	/* check for start date greater than sysdate */
	/*IF to_date(to_char(p_upd_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_upd_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;*/


    /* check for the records with from and to dates less than sysdate */
   /* IF to_date(to_char(p_upd_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END IF;
	*/
    /* if the start date is in the past, the start date cannot be
       modified */
	/*IF to_date(to_char(p_upd_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_db_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_NOT_ALLOWED,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
	*/

    IF l_ptvv_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   	  l_ptvv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN

        Check_Constraints(p_ptvv_rec 	 	 => l_ptvv_rec,
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
    p_upd_ptvv_rec                 IN ptvv_rec_type,
    p_db_ptvv_rec				   IN ptvv_rec_type,
    p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
 BEGIN
  /* Scenario 1: Only description and/or descriptive flexfield changes */
  IF p_upd_ptvv_rec.from_date = Okl_Api.G_MISS_DATE AND
	 p_upd_ptvv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
	 l_action := '1';
	/* Scenario 2: Changing the dates */
  ELSE
	 l_action := '2';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_PQYVALUES for: okl_pdt_pqy_vals
  ---------------------------------------------------------------------------
  PROCEDURE insert_tqyvalues(p_api_version     IN  NUMBER,
                             p_init_msg_list   IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                        	 x_return_status   OUT NOCOPY VARCHAR2,
                        	 x_msg_count       OUT NOCOPY NUMBER,
                        	 x_msg_data        OUT NOCOPY VARCHAR2,
 					         p_ptqv_rec        IN  ptqv_rec_type,
                        	 p_ptvv_rec        IN  ptvv_rec_type,
                        	 x_ptvv_rec        OUT NOCOPY ptvv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_tqyvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_valid			  BOOLEAN;
    l_ptvv_rec		  ptvv_rec_type;
	l_ptqv_rec		  ptqv_rec_type;
	l_row_notfound    BOOLEAN := TRUE;
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

	l_ptvv_rec := p_ptvv_rec;

	/* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(l_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;*/

	--- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ptvv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


	default_parent_dates( p_ptvv_rec 	    => l_ptvv_rec,
                          x_no_data_found   => l_row_notfound,
	                      x_return_status   => l_return_status,
	                      x_ptqv_rec  	    => l_ptqv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--Default Child End Date With Its Parents End Date If It Is Not Entered.
    IF to_date(to_char(l_ptqv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
        (to_date(to_char(l_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') OR
	    to_date(to_char(l_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') IS NULL) THEN
   	   l_ptvv_rec.TO_DATE   := l_ptqv_rec.TO_DATE;
    END IF;

	/* call check_constraints to check the validity of this relationship */
	Check_Constraints(p_ptvv_rec 		=> l_ptvv_rec,
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

    /* public api to insert PQYVALUES */
    Okl_Ptl_Qualitys_Pub.create_ptl_qlty_values(p_api_version   => p_api_version,
                        		                 p_init_msg_list => p_init_msg_list,
                            		             x_return_status => l_return_status,
                          		                 x_msg_count     => x_msg_count,
                              		             x_msg_data      => x_msg_data,
                             		             p_ptvv_rec      => l_ptvv_rec,
                              		             x_ptvv_rec      => x_ptvv_rec);

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

  END insert_tqyvalues;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_PQYVALUES for: OKL_PTQ_VALUES_V
  ---------------------------------------------------------------------------
  PROCEDURE update_tqyvalues(p_api_version     IN  NUMBER,
                             p_init_msg_list   IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                             x_return_status   OUT NOCOPY VARCHAR2,
                        	 x_msg_count       OUT NOCOPY NUMBER,
                        	 x_msg_data        OUT NOCOPY VARCHAR2,
 					         p_ptqv_rec        IN  ptqv_rec_type,
							 p_ptvv_rec		   IN  ptvv_rec_type,
                        	 x_ptvv_rec        OUT NOCOPY ptvv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_tqyvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_valid			  BOOLEAN;
    l_db_ptvv_rec     ptvv_rec_type; /* database copy */
	l_upd_ptvv_rec	  ptvv_rec_type; /* input copy */
	l_ptvv_rec	  	  ptvv_rec_type; /* latest with the retained changes */
    l_ptqv_rec	  	  ptqv_rec_type; /* Parent Record */
	l_tmp_ptvv_rec	  ptvv_rec_type; /* for any other purposes */
    l_no_data_found   BOOLEAN := TRUE;
	l_action		  VARCHAR2(1);
	l_row_notfound    BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_upd_ptvv_rec := p_ptvv_rec;

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
    get_rec(p_ptvv_rec 	 	=> l_upd_ptvv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_ptvv_rec		=> l_db_ptvv_rec);

	IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	default_parent_dates( p_ptvv_rec 	    => l_db_ptvv_rec,
                          x_no_data_found   => l_row_notfound,
	                      x_return_status   => l_return_status,
	                      x_ptqv_rec  	    => l_ptqv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--Default Child End Date With Its Parents End Date If It Is Not Entered.
    IF to_date(to_char(l_ptqv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
       (to_date(to_char(l_upd_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') OR
	    to_date(to_char(l_upd_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') IS NULL) THEN
   	   l_upd_ptvv_rec.TO_DATE   := l_ptqv_rec.TO_DATE;
    END IF;

    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_ptvv_rec     => l_upd_ptvv_rec,
                      p_db_ptvv_rec      => l_db_ptvv_rec);

    /* check for past records */
    /*IF to_date(to_char(l_db_ptvv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
       to_date(to_char(l_db_ptvv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;*/


    IF (l_upd_ptvv_rec.TO_DATE = Okl_Api.G_MISS_DATE) then
            l_upd_ptvv_rec.TO_DATE := p_ptvv_rec.to_date;
     end if;

     IF (l_upd_ptvv_rec.from_DATE = Okl_Api.G_MISS_DATE) then
         l_upd_ptvv_rec.from_DATE := p_ptvv_rec.from_date;
     end if;

    /* check for end date greater than start date */
	IF (l_upd_ptvv_rec.TO_DATE IS NOT NULL) AND (l_upd_ptvv_rec.TO_DATE < l_upd_ptvv_rec.from_date) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => Okl_Ptv_Pvt.g_to_date_error
                          ,p_token1         => Okl_Ptv_Pvt.g_col_name_token
                          ,p_token1_value   => 'TO_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

 	/* determine how the processing to be done */
	l_action := determine_action(p_upd_ptvv_rec	 => l_upd_ptvv_rec,
			 					 p_db_ptvv_rec	 => l_db_ptvv_rec,
								 p_date			 => l_sysdate);

	/* Scenario 1: only changing description and descriptive flexfields */
	IF l_action = '1' THEN
	/* public api to update tqualities */
		/* public api to update PTYVALUES */
    Okl_Ptl_Qualitys_Pub.update_ptl_qlty_values(p_api_version   => p_api_version,
                              		 	        p_init_msg_list => p_init_msg_list,
                              		 	        x_return_status => l_return_status,
                              		 	        x_msg_count     => x_msg_count,
                              		 	        x_msg_data      => x_msg_data,
                              		 	        p_ptvv_rec      => l_upd_ptvv_rec,
                              		 	        x_ptvv_rec      => x_ptvv_rec);
     IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
    /* Scenario 2: changing the dates */
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
    l_ptvv_rec := defaults_to_actuals(p_upd_ptvv_rec => l_upd_ptvv_rec,
					  				 p_db_ptvv_rec  => l_db_ptvv_rec);

       check_updates(p_upd_ptvv_rec	 => l_upd_ptvv_rec,
	   			     p_db_ptvv_rec	 => l_db_ptvv_rec,
					 p_ptvv_rec		 => l_ptvv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);

      IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_ERROR;
      ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

	/* public api to update PTYVALUES */
    Okl_Ptl_Qualitys_Pub.update_ptl_qlty_values(p_api_version   => p_api_version,
                              		 	        p_init_msg_list => p_init_msg_list,
                              		 	        x_return_status => l_return_status,
                              		 	        x_msg_count     => x_msg_count,
                              		 	        x_msg_data      => x_msg_data,
                              		 	        p_ptvv_rec      => l_upd_ptvv_rec,
                              		 	        x_ptvv_rec      => x_ptvv_rec);
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

  END update_tqyvalues;


END Okl_Setuptqyvalues_Pvt;

/
