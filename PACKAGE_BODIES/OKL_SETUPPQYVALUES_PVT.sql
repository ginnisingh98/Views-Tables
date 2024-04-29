--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPQYVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPQYVALUES_PVT" AS
/* $Header: OKLRSQVB.pls 115.22 2004/04/01 00:39:19 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: okl_pqy_values_v
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_qvev_rec                     IN qvev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_qvev_rec					   OUT NOCOPY qvev_rec_type
  ) IS
    CURSOR okl_qvev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PQY_ID,
            VALUE,
            DESCRIPTION,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pqy_Values_V
     WHERE okl_pqy_values_v.id  = p_id;
    l_okl_qvev_pk                  okl_qvev_pk_csr%ROWTYPE;
    l_qvev_rec                     qvev_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qvev_pk_csr (p_qvev_rec.id);
    FETCH okl_qvev_pk_csr INTO
              l_qvev_rec.ID,
              l_qvev_rec.OBJECT_VERSION_NUMBER,
              l_qvev_rec.PQY_ID,
              l_qvev_rec.VALUE,
              l_qvev_rec.DESCRIPTION,
              l_qvev_rec.FROM_DATE,
              l_qvev_rec.TO_DATE,
              l_qvev_rec.CREATED_BY,
              l_qvev_rec.CREATION_DATE,
              l_qvev_rec.LAST_UPDATED_BY,
              l_qvev_rec.LAST_UPDATE_DATE,
              l_qvev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_qvev_pk_csr%NOTFOUND;
    CLOSE okl_qvev_pk_csr;
	x_qvev_rec := l_qvev_rec;
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

      IF (okl_qvev_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_qvev_pk_csr;
      END IF;

  END get_rec;


  ---------------------------------------------------------------------------
  -- PROCEDURE default_parent_dates for: OKL_PDT_QUALITYS_V
 ---------------------------------------------------------------------------

 PROCEDURE default_parent_dates(
    p_qvev_rec		  IN qvev_rec_type,
    x_no_data_found   OUT NOCOPY BOOLEAN,
	x_return_status	  OUT NOCOPY VARCHAR2,
	x_pqyv_rec		  OUT NOCOPY pqyv_rec_type
  ) IS
    CURSOR okl_pqyv_pk_csr (p_pqy_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_pdt_qualitys_V pqy
     WHERE pqy.id = p_pqy_id;
    l_okl_pqyv_pk                  okl_pqyv_pk_csr%ROWTYPE;
    l_pqyv_rec                     pqyv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
	-- Get current database values
    OPEN okl_pqyv_pk_csr (p_qvev_rec.pqy_id);
    FETCH okl_pqyv_pk_csr INTO
              l_pqyv_rec.FROM_DATE,
              l_pqyv_rec.TO_DATE;
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

 END default_parent_dates;

 ---------------------------------------------------------------------------
  -- To verify whether the dates are valid in the following entities
  -- 1. Quality Value
  -- 2. Product quality value
 ---------------------------------------------------------------------------

PROCEDURE Check_Constraints (
 p_qvev_rec		  IN OUT NOCOPY qvev_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_valid          OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_chk_pqy_csr(p_pqy_id      NUMBER,
                            p_from_date  DATE,
			                p_to_date	 DATE
	) IS
    SELECT '1'
    FROM   okl_pdt_qualitys_v pqyv
    WHERE  pqyv.ID = p_pqy_id
	AND   ((pqyv.FROM_DATE > p_from_date OR
		    p_from_date > NVL(pqyv.TO_DATE,p_from_date))
		   OR
	 	    NVL(pqyv.TO_DATE, p_to_date) < p_to_date);

    CURSOR okl_chk_pqv_csr(p_qve_id          NUMBER,
                          p_from_date  DATE,
			              p_to_date	 DATE
	) IS
    SELECT '1'
    FROM okl_pdt_pqy_vals_v pqvv
    WHERE  pqvv.qve_id = p_qve_id
		AND   (pqvv.FROM_DATE < p_from_date OR
	 	    NVL(pqvv.TO_DATE, pqvv.FROM_DATE) > p_to_date);

    CURSOR okl_pqy_values_unique (p_unique1  OKL_PQY_VALUES.VALUE%TYPE,
	                              P_unique2  OKL_PQY_VALUES.PQY_ID%TYPE
    ) IS
    SELECT '1'
       FROM OKL_PQY_VALUES_V
      WHERE OKL_PQY_VALUES_V.VALUE =  p_unique1 AND
            OKL_PQY_VALUES_V.PQY_ID =  p_unique2;
			-- AND
            -- OKL_PQY_VALUES_V.ID  <> NVL(p_qvev_rec.id,-9999);

    l_token_1        VARCHAR2(1999);
    l_token_2        VARCHAR2(1999);
    l_token_3        VARCHAR2(1999);
    l_unique_key     OKL_PQY_VALUES_V.VALUE%TYPE;
    l_unique_key2    OKL_PQY_VALUES_V.PQY_ID%TYPE;
	l_check		     VARCHAR2(1) := '?';
    l_row_not_found  BOOLEAN     := FALSE;

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;


    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PQVALS_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY_VALUES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRDQLTY_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITIES');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_PQV_VAL_SUMRY',
                                                      p_attribute_code => 'OKL_PDT_QUALITY_VALUES');


    IF p_qvev_rec.id = Okl_Api.G_MISS_NUM THEN
       p_qvev_rec.value := Okl_Accounting_Util.okl_upper(p_qvev_rec.value);

    OPEN okl_pqy_values_unique (p_qvev_rec.value, p_qvev_rec.pqy_id);
    FETCH okl_pqy_values_unique INTO l_unique_key;
    IF okl_pqy_values_unique%FOUND THEN
       Okl_Api.set_message(G_APP_NAME,'OKL_NOT_UNIQUE','OKL_TABLE_NAME',l_token_1);
   	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
 	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    CLOSE okl_pqy_values_unique;
	END IF;

    -- Check for parent dates
    OPEN okl_chk_pqy_csr(p_qvev_rec.pqy_id,
		 	  			p_qvev_rec.from_date,
		         		p_qvev_rec.TO_DATE);

    FETCH okl_chk_pqy_csr INTO l_check;
    l_row_not_found := okl_chk_pqy_csr%NOTFOUND;
    CLOSE okl_chk_pqy_csr;

    IF l_row_not_found = FALSE THEN
		   Okl_Api.SET_MESSAGE(p_app_name  => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_2,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_1);
   	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
 	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

   IF p_qvev_rec.id <> Okl_Api.G_MISS_NUM THEN
    -- Check for Child dates
    OPEN okl_chk_pqv_csr(p_qvev_rec.id,
                        p_qvev_rec.from_date,
		                p_qvev_rec.TO_DATE);

    FETCH okl_chk_pqv_csr INTO l_check;
    l_row_not_found := okl_chk_pqv_csr%NOTFOUND;
    CLOSE okl_chk_pqv_csr;

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

       IF (okl_chk_pqy_csr%ISOPEN) THEN
	   	  CLOSE okl_chk_pqy_csr;
       END IF;

       IF (okl_chk_pqv_csr%ISOPEN) THEN
	   	  CLOSE okl_chk_pqv_csr;
       END IF;

       IF (okl_pqy_values_unique%ISOPEN) THEN
	   	  CLOSE okl_pqy_values_unique;
       END IF;
 END Check_Constraints;

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Value (
    p_qvev_rec IN OUT NOCOPY qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1           VARCHAR2(999);
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PQVALS_CRUPD','OKL_NAME');

    IF p_qvev_rec.value = Okl_Api.G_MISS_CHAR OR
       p_qvev_rec.value IS NULL
    THEN
      Okl_Api.set_message(Okl_Qve_Pvt.G_APP_NAME, Okl_Qve_Pvt.G_REQUIRED_VALUE,Okl_Qve_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
	p_qvev_rec.value := Okl_Accounting_Util.okl_upper(p_qvev_rec.value);
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name  =>Okl_Qve_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Qve_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Qve_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Qve_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Value;
------end of Validate_Value-----------------------------------

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
    p_qvev_rec  IN  qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1   VARCHAR2(999);
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PQVALS_CRUPD','OKL_EFFECTIVE_FROM');
    IF (p_qvev_rec.from_date IS NULL) OR
       (p_qvev_rec.from_date = Okl_Api.G_MISS_DATE) THEN
      Okl_Api.set_message(Okl_Qve_Pvt.G_APP_NAME, Okl_Qve_Pvt.G_REQUIRED_VALUE,Okl_Qve_Pvt.G_COL_NAME_TOKEN,l_token_1);
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           Okl_Api.set_message(p_app_name  =>Okl_Qve_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Qve_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Qve_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Qve_Pvt.G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;
------end of Validate_From_Date-----------------------------------

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
    p_qvev_rec IN OUT NOCOPY qvev_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;


  BEGIN

    -----CHECK FOR PQY_VALUE----------------------------
    Validate_Value (p_qvev_rec, x_return_status);
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
    Validate_From_Date (p_qvev_rec,x_return_status);
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
           Okl_Api.set_message(p_app_name  =>Okl_Qve_Pvt.G_APP_NAME,
                          p_msg_name       =>Okl_Qve_Pvt.G_UNEXPECTED_ERROR,
                          p_token1         =>Okl_Qve_Pvt.G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>Okl_Qve_Pvt.G_SQL_SQLERRM_TOKEN,
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
    p_upd_qvev_rec                 IN qvev_rec_type,
	p_db_qvev_rec				   IN qvev_rec_type
  ) RETURN qvev_rec_type IS
  l_qvev_rec	qvev_rec_type;
  BEGIN

	   /* create a temporary record with all relevant details from db and upd records */
	   l_qvev_rec := p_db_qvev_rec;

	   IF p_upd_qvev_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_qvev_rec.description := p_upd_qvev_rec.description;
	   END IF;

   	   IF p_upd_qvev_rec.value <> Okl_Api.G_MISS_CHAR THEN
	  	  l_qvev_rec.value := p_upd_qvev_rec.value;
	   END IF;

       IF p_upd_qvev_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_qvev_rec.from_date := p_upd_qvev_rec.from_date;
	   END IF;

	   IF p_upd_qvev_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_qvev_rec.TO_DATE := p_upd_qvev_rec.TO_DATE;
	   END IF;

	   RETURN l_qvev_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_qvev_rec                 IN OUT NOCOPY qvev_rec_type,
	p_db_qvev_rec				   IN qvev_rec_type
  ) IS
  l_upd_qvev_rec	qvev_rec_type;
  l_db_qvev_rec     qvev_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_qvev_rec := p_upd_qvev_rec;
       l_db_qvev_rec  := p_db_qvev_rec;

	   IF l_upd_qvev_rec.description = l_db_qvev_rec.description THEN
	  	  l_upd_qvev_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_qvev_rec.from_date , 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_qvev_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_qvev_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

       IF l_upd_qvev_rec.value = l_db_qvev_rec.value THEN
	  	  l_upd_qvev_rec.value := Okl_Api.G_MISS_CHAR;
	   END IF;

       p_upd_qvev_rec := l_upd_qvev_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_upd_qvev_rec                 IN qvev_rec_type,
	p_db_qvev_rec				   IN qvev_rec_type,
	p_qvev_rec					   IN qvev_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_qvev_rec	  qvev_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_sysdate       DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_valid	  BOOLEAN;
  BEGIN

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
   l_qvev_rec := p_qvev_rec;

	/* check for start date greater than sysdate */
	/*IF to_date(to_char(p_upd_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_upd_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    */

    /* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(p_upd_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END IF;
	*/
    /* if the start date is in the past, the start date cannot be
       modified */
	/*IF to_date(to_char(p_upd_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_db_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_NOT_ALLOWED,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    */
    IF l_qvev_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   	  l_qvev_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN

       --- check dates constraints
	    Check_Constraints(p_qvev_rec 	 	 => l_qvev_rec,
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
    p_upd_qvev_rec                 IN qvev_rec_type,
    p_db_qvev_rec				   IN qvev_rec_type,
    p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
 BEGIN
  /* Scenario 1: Only description and/or descriptive flexfield changes */
  IF p_upd_qvev_rec.from_date = Okl_Api.G_MISS_DATE AND
	 p_upd_qvev_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
	 l_action := '1';
	/* Scenario 2: Changing the dates */
  ELSE
	 l_action := '2';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_pqyvalues for: okl_pqy_values_v
  ---------------------------------------------------------------------------
  PROCEDURE insert_pqyvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqyv_rec                     IN  pqyv_rec_type,
    p_qvev_rec                     IN  qvev_rec_type,
    x_qvev_rec                     OUT NOCOPY qvev_rec_type
    ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_pqyvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_valid			  BOOLEAN;
    l_qvev_rec		  qvev_rec_type;
	l_pqyv_rec	      pqyv_rec_type;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_qvev_rec := p_qvev_rec;
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

    l_return_status := Validate_Attributes(l_qvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(l_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
    */
    default_parent_dates( p_qvev_rec 	    => l_qvev_rec,
                          x_no_data_found   => l_row_notfound,
	                      x_return_status   => l_return_status,
	                      x_pqyv_rec  	    => l_pqyv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--Default Child End Date With Its Parents End Date If It Is Not Entered.
    IF to_date(to_char(l_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
       (to_date(to_char(l_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') OR
	    to_date(to_char(l_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') IS NULL) THEN
   	   l_qvev_rec.TO_DATE   := l_pqyv_rec.TO_DATE;
    END IF;

	/* call check_constraints to check the validity of this relationship */
	Check_Constraints(p_qvev_rec 		=> l_qvev_rec,
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

     Okl_Pdt_Qualitys_Pub.create_pdt_quality_vals(p_api_version   => p_api_version,
                        		                  p_init_msg_list => p_init_msg_list,
                               		              x_return_status => l_return_status,
                          		                  x_msg_count     => x_msg_count,
                              		              x_msg_data      => x_msg_data,
                             		              p_qvev_rec      => l_qvev_rec,
                              		              x_qvev_rec      => x_qvev_rec);

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

  END insert_pqyvalues;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_pqyvalues for: okl_pdt_pqy_vals
  ---------------------------------------------------------------------------
  PROCEDURE update_pqyvalues(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type,
     p_qvev_rec                     IN  qvev_rec_type,
     x_qvev_rec                     OUT NOCOPY qvev_rec_type
    ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_pqyvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_valid			  BOOLEAN;
    l_db_qvev_rec     qvev_rec_type; /* database copy */
	l_upd_qvev_rec	  qvev_rec_type; /* input copy */
	l_qvev_rec	  	  qvev_rec_type; /* latest with the retained changes */
	l_pqyv_rec	  	  pqyv_rec_type; /* Parent Record */
	l_tmp_qvev_rec	  qvev_rec_type; /* for any other purposes */
    l_no_data_found   BOOLEAN := TRUE;
	l_action		  VARCHAR2(1);
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_upd_qvev_rec := p_qvev_rec;

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
    get_rec(p_qvev_rec 	 	=> l_upd_qvev_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_qvev_rec		=> l_db_qvev_rec);

	IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	default_parent_dates( p_qvev_rec 	     => l_db_qvev_rec,
                          x_no_data_found    => l_row_notfound,
	                      x_return_status    => l_return_status,
	                      x_pqyv_rec  	     => l_pqyv_rec);

	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

   IF l_pqyv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
       l_pqyv_rec.TO_DATE := NULL;
   END IF;

   IF l_upd_qvev_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
       l_upd_qvev_rec.TO_DATE := NULL;
   END IF;


	--Default Child End Date With Its Parents End Date If It Is Not Entered.
    IF to_date(to_char(l_pqyv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
       (to_date(to_char(l_upd_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(Okl_Api.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') OR
	     to_date(to_char(l_upd_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') IS NULL) THEN
   	   l_upd_qvev_rec.TO_DATE   := l_pqyv_rec.TO_DATE;
    END IF;

    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_qvev_rec     => l_upd_qvev_rec,
                      p_db_qvev_rec      => l_db_qvev_rec);

    /* check for past records */
    /*IF to_date(to_char(l_db_qvev_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
       to_date(to_char(l_db_qvev_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
	*/

      IF (l_upd_qvev_rec.TO_DATE = Okl_Api.G_MISS_DATE) then
            l_upd_qvev_rec.TO_DATE := p_qvev_rec.to_date;
     end if;

     IF (l_upd_qvev_rec.from_DATE = Okl_Api.G_MISS_DATE) then
         l_upd_qvev_rec.from_DATE := p_qvev_rec.from_date;
     end if;

	IF (l_upd_qvev_rec.TO_DATE IS NOT NULL) AND (l_upd_qvev_rec.TO_DATE < l_upd_qvev_rec.from_date) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => Okl_Qve_Pvt.g_to_date_error
                          ,p_token1         => Okl_Qve_Pvt.g_col_name_token
                          ,p_token1_value   => 'TO_DATE');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
	   RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


	/* determine how the processing to be done */
	l_action := determine_action(p_upd_qvev_rec	 => l_upd_qvev_rec,
			 					 p_db_qvev_rec	 => l_db_qvev_rec,
								 p_date			 => l_sysdate);

	/* Scenario 1: only changing description and descriptive flexfields */
	IF l_action = '1' THEN
    /* public api to update pqyvalues */
    Okl_Pdt_Qualitys_Pub.update_pdt_quality_vals(p_api_version => p_api_version,
                              		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_qvev_rec      => l_upd_qvev_rec,
                              		 	   x_qvev_rec      => x_qvev_rec);

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
	/* Scenario 2: changing the dates */
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
    l_qvev_rec := defaults_to_actuals(p_upd_qvev_rec => l_upd_qvev_rec,
					  				 p_db_qvev_rec  => l_db_qvev_rec);

    check_updates(p_upd_qvev_rec	 => l_upd_qvev_rec,
	   			     p_db_qvev_rec	 => l_db_qvev_rec,
					 p_qvev_rec		 => l_qvev_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

   /* public api to update pqyvalues */
    Okl_Pdt_Qualitys_Pub.update_pdt_quality_vals(p_api_version => p_api_version,
                              		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_qvev_rec      => l_upd_qvev_rec,
                              		 	   x_qvev_rec      => x_qvev_rec);

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

  END update_pqyvalues;


END Okl_Setuppqyvalues_Pvt;

/
