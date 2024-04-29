--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPDTTEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPDTTEMPLATES_PVT" AS
/* $Header: OKLRSPTB.pls 115.17 2003/07/23 18:37:03 sgorantl noship $ */
  TYPE GenericCurTyp IS REF CURSOR;
  G_UNQS	            CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';
  ---------------------------------------------------------------------------
  -- PROCEDURE get_version to calculate the new version number for the
  -- product or product template to be created
  ---------------------------------------------------------------------------
  PROCEDURE get_version(p_name				IN VARCHAR2,
  						p_cur_version		IN VARCHAR2,
						p_from_date		    IN DATE,
						p_to_date			IN DATE,
						p_table				IN VARCHAR2,
  						x_return_status		OUT NOCOPY VARCHAR2,
						x_new_version		OUT NOCOPY VARCHAR2) IS

	okl_all_laterversionsexist_csr	GenericCurTyp;
	l_sql_stmt		VARCHAR2(250);
	l_check			VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
null;
/*
  	   IF p_cur_version = Okl_Api.G_MISS_CHAR THEN
	   	  x_new_version := G_INIT_VERSION;
	   ELSE
          -- Check for future versions of the same formula
		  l_sql_stmt := 'SELECT ''1'' ' ||
		  	  		 	'FROM ' || p_table ||
			  			' WHERE NAME = ' || '''' || p_name || '''' ||
			  			' AND NVL(TO_DATE, ' ||
						'''' || Okl_Api.G_MISS_DATE || '''' || ') > ' ||
						'''' || p_to_date || '''';
		  OPEN okl_all_laterversionsexist_csr
		  FOR l_sql_stmt;
    	  FETCH okl_all_laterversionsexist_csr INTO l_check;
    	  l_row_not_found := okl_all_laterversionsexist_csr%NOTFOUND;
    	  CLOSE okl_all_laterversionsexist_csr;

    	  IF l_row_not_found = TRUE THEN
  	   	   	 x_new_version := TO_CHAR(TO_NUMBER(p_cur_version, G_VERSION_FORMAT)
			                  + G_VERSION_MAJOR_INCREMENT, G_VERSION_FORMAT);
		  ELSE
		  	 x_new_version := TO_CHAR(TO_NUMBER(p_cur_version, G_VERSION_FORMAT)
			 			   	  + G_VERSION_MINOR_INCREMENT, G_VERSION_FORMAT);
    	  END IF;
	   END IF;

	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
*/
  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF (okl_all_laterversionsexist_csr%ISOPEN) THEN
	   	  CLOSE okl_all_laterversionsexist_csr;
       END IF;

  END get_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PDT_TEMPLATES_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_ptlv_rec                     IN ptlv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_ptlv_rec					   OUT NOCOPY ptlv_rec_type
  ) IS
    CURSOR okl_ptlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            VERSION,
            NVL(DESCRIPTION,Okl_Api.G_MISS_CHAR) DESCRIPTION,
            FROM_DATE,
            NVL(TO_DATE,Okl_Api.G_MISS_DATE) TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Templates_V
     WHERE okl_pdt_templates_v.id    = p_id;
    l_okl_ptlv_pk                  okl_ptlv_pk_csr%ROWTYPE;
    l_ptlv_rec                     ptlv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_ptlv_pk_csr (p_ptlv_rec.id);
    FETCH okl_ptlv_pk_csr INTO
              l_ptlv_rec.ID,
              l_ptlv_rec.OBJECT_VERSION_NUMBER,
              l_ptlv_rec.NAME,
              l_ptlv_rec.VERSION,
              l_ptlv_rec.DESCRIPTION,
              l_ptlv_rec.FROM_DATE,
              l_ptlv_rec.TO_DATE,
              l_ptlv_rec.CREATED_BY,
              l_ptlv_rec.CREATION_DATE,
              l_ptlv_rec.LAST_UPDATED_BY,
              l_ptlv_rec.LAST_UPDATE_DATE,
              l_ptlv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ptlv_pk_csr%NOTFOUND;
    CLOSE okl_ptlv_pk_csr;
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

      IF (okl_ptlv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_ptlv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_overlaps for either product or product template
  -- To avoid overlapping of dates with other versions of the same product or
  -- product template
  ---------------------------------------------------------------------------
  PROCEDURE check_overlaps (p_id			  IN NUMBER,
  						   	p_name			  IN VARCHAR2,
  						    p_from_date   	  IN DATE,
							p_to_date	   	  IN DATE,
							p_table			  IN VARCHAR2,
							x_return_status	  OUT NOCOPY VARCHAR2,
							x_valid			  OUT NOCOPY BOOLEAN
  ) IS

	okl_all_overlaps_csr	GenericCurTyp;
	l_sql_stmt		        VARCHAR2(500);
	l_check                 VARCHAR2(1) := '?';
	l_row_not_found	        BOOLEAN := FALSE;
  BEGIN
/*
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Check for product template overlaps
	l_sql_stmt := 'SELECT ''1'' ' ||
				  'FROM ' || p_table ||
				  ' WHERE NAME = ' || '''' || p_name || '''' ||
				  ' AND ID <> ' || p_id ||
				  ' AND ( ' || '''' || p_from_date || '''' ||
				  ' BETWEEN FROM_DATE AND ' ||
				  ' NVL(TO_DATE, ' || '''' || Okl_Api.G_MISS_DATE || '''' || ') OR ' ||
				  '''' || p_to_date || '''' ||
				  ' BETWEEN FROM_DATE AND ' ||
				  ' NVL(TO_DATE, ' || '''' || Okl_Api.G_MISS_DATE || '''' || ')) ' ||
				  'UNION ALL ' ||
			   	  'SELECT ''2'' ' ||
				  'FROM ' || p_table ||
				  ' WHERE NAME = ' || '''' || p_name || '''' ||
				  ' AND ID <> ' || p_id ||
				  ' AND ' || '''' || p_from_date || '''' ||
				  ' <= FROM_DATE ' ||
				  'AND ' || '''' || p_to_date || '''' ||
				  ' >= NVL(TO_DATE, ' || '''' || Okl_Api.G_MISS_DATE || '''' || ') ';
    OPEN okl_all_overlaps_csr
	FOR l_sql_stmt;
    FETCH okl_all_overlaps_csr INTO l_check;
    l_row_not_found := okl_all_overlaps_csr%NOTFOUND;
    CLOSE okl_all_overlaps_csr;
    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_VERSION_OVERLAPS,
						   p_token1			=> G_TABLE_TOKEN,
						   p_token1_value	=> p_table,
						   p_token2			=> G_COL_NAME_TOKEN,
						   p_token2_value	=> 'NAME');
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
*/
null;
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

       IF (okl_all_overlaps_csr%ISOPEN) THEN
	   	  CLOSE okl_all_overlaps_csr;
       END IF;


  END check_overlaps;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_PDT_TEMPLATES_V
  -- To verify whether the dates are valid in the following entities
  -- 1. Product
  -- 2. Contract
  -- 3. Product Template Quality
  -- 4. Product Template Quality Value
  -- 5. Product Quality
  ---------------------------------------------------------------------------
  PROCEDURE Check_Constraints (
    p_upd_ptlv_rec     IN ptlv_rec_type,
    p_ptlv_rec         IN ptlv_rec_type,
	x_return_status	   OUT NOCOPY VARCHAR2,
    x_valid            OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_products_csr (p_ptl_id     IN Okl_Pdt_Templates_V.ID%TYPE,
		   					 p_from_date  IN Okl_Pdt_Templates_V.FROM_DATE%TYPE,
							 p_to_date 	  IN Okl_Pdt_Templates_V.TO_DATE%TYPE
	) IS

    SELECT '1'
    FROM Okl_Products_V pdt
     WHERE pdt.PTL_ID    = p_ptl_id
	 AND   (pdt.FROM_DATE < p_from_date OR
	 	    NVL(pdt.TO_DATE, pdt.FROM_DATE) > p_to_date);


    CURSOR okl_ptl_constraints_csr (p_ptl_id     IN Okl_Pdt_Templates_V.ID%TYPE,
		   					        p_from_date  IN Okl_Pdt_Templates_V.FROM_DATE%TYPE,
							        p_to_date 	 IN Okl_Pdt_Templates_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Ptq_Values_V ptv,
         Okl_Ptl_Ptq_Vals_V pmv
     WHERE pmv.PTL_ID    = p_ptl_id
     AND   ptv.ID        = pmv.PTV_ID
	 AND   ((ptv.FROM_DATE > p_from_date OR
            p_from_date > NVL(ptv.TO_DATE,p_from_date)) OR
	 	    NVL(ptv.TO_DATE, p_to_date) < p_to_date)
     UNION ALL
    SELECT '2'
    FROM Okl_Pdt_Pqys_V pdq,
         Okl_Pdt_Qualitys_V pqy
     WHERE pdq.PTL_ID    = p_ptl_id
     AND   pqy.ID        = pdq.PQY_ID
	 AND   ((pqy.FROM_DATE > p_from_date OR
            p_from_date > NVL(pqy.TO_DATE,p_from_date)) OR
	 	    NVL(pqy.TO_DATE, p_to_date) < p_to_date);

  l_token_1        VARCHAR2(1999);
  l_token_2        VARCHAR2(1999);
  l_check		VARCHAR2(1) := '?';
  l_token_3        VARCHAR2(1999);
  l_token_4        VARCHAR2(1999);
  l_token_5        VARCHAR2(1999);

  l_row_not_found	BOOLEAN := FALSE;
  l_to_date         okl_pdt_templates_v.TO_DATE%TYPE;

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_TEMPLATE_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_TEMPLATES');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCTS');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_TMPVALS_CRUPD',
                                                      p_attribute_code => 'OKL_TEMPLATE_QUALITY_VALUES');

    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRDQLTY_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITIES');

    l_token_5 := l_token_3 ||','||l_token_4;

    -- Check for product dates

    IF p_ptlv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
          l_to_date := NULL;
    ELSE
          l_to_date := p_ptlv_rec.TO_DATE;
    END IF;

    IF p_ptlv_rec.id <> Okl_Api.G_MISS_NUM THEN

        OPEN okl_products_csr (p_upd_ptlv_rec.id,
		 				      p_ptlv_rec.from_date,
                                                      l_to_date
                                                      );
       FETCH okl_products_csr INTO l_check;
       l_row_not_found := okl_products_csr%NOTFOUND;
       CLOSE okl_products_csr;


       IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_DATES_MISMATCH,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_2);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
    END IF;

    -- Check for constraints dates
    OPEN okl_ptl_constraints_csr (p_upd_ptlv_rec.id,
		 					  	  p_ptlv_rec.from_date,
							  	  l_to_date);
    FETCH okl_ptl_constraints_csr INTO l_check;
    l_row_not_found := okl_ptl_constraints_csr%NOTFOUND;
    CLOSE okl_ptl_constraints_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_5,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_1);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name	    =>	G_UNEXPECTED_ERROR,
							p_token1	    =>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	    =>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_valid := FALSE;
	   x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF (okl_products_csr%ISOPEN) THEN
	   	  CLOSE okl_products_csr;
       END IF;

       IF (okl_ptl_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_ptl_constraints_csr;
       END IF;

 END Check_Constraints;


  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_ptlv_rec                 IN OUT NOCOPY ptlv_rec_type,
	p_db_ptlv_rec				   IN ptlv_rec_type
  ) IS
  l_upd_ptlv_rec	ptlv_rec_type;
  l_db_ptlv_rec     ptlv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_ptlv_rec := p_upd_ptlv_rec;
       l_db_ptlv_rec := p_db_ptlv_rec;

	   IF l_upd_ptlv_rec.description = l_db_ptlv_rec.description THEN
	  	  l_upd_ptlv_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_ptlv_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_ptlv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_ptlv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_ptlv_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

       p_upd_ptlv_rec := l_upd_ptlv_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_ptlv_rec                 IN ptlv_rec_type,
	p_db_ptlv_rec				   IN ptlv_rec_type
  ) RETURN ptlv_rec_type IS
  l_ptlv_rec	ptlv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_ptlv_rec := p_db_ptlv_rec;

	   IF p_upd_ptlv_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_ptlv_rec.description := p_upd_ptlv_rec.description;
	   END IF;

	   IF p_upd_ptlv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_ptlv_rec.from_date := p_upd_ptlv_rec.from_date;
	   END IF;

	   IF p_upd_ptlv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_ptlv_rec.TO_DATE := p_upd_ptlv_rec.TO_DATE;
	   END IF;

	   RETURN l_ptlv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_upd_ptlv_rec                 IN ptlv_rec_type,
	p_db_ptlv_rec				   IN ptlv_rec_type,
	p_ptlv_rec					   IN ptlv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_upd_ptlv_rec  ptlv_rec_type;
  l_ptlv_rec	  ptlv_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	   l_ptlv_rec := p_ptlv_rec;
       l_upd_ptlv_rec := p_upd_ptlv_rec;

	   /* check for start date greater than sysdate */
	/*IF to_date(to_char(p_upd_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_upd_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
       x_return_status    := OKL_API.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;	*/


    /* check for the records with from and to dates less than sysdate */
/*    IF to_date(to_char(p_upd_ptlv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   x_return_status    := OKL_API.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END IF;
	*/

    /* if the start date is in the past, the start date cannot be
       modified */
/*	IF to_date(to_char(p_upd_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(p_db_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> 'OKL_NOT_ALLOWED',
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE');
       x_return_status    := OKL_API.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

*/	   IF p_upd_ptlv_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   	  p_upd_ptlv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN

		  /* call check_overlaps */
		  /*check_overlaps(p_id	   	 		=> l_upd_ptlv_rec.id,
		  				 p_name	        	=> l_ptlv_rec.name,
		  				 p_from_date 		=> l_ptlv_rec.from_date,
						 p_to_date			=> l_ptlv_rec.TO_DATE,
						 p_table			=> 'Okl_Pdt_Templates_V',
						 x_return_status	=> l_return_status,
						 x_valid			=> l_valid);
       	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		 x_return_status    := OKL_API.G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		  	    (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
       		 x_return_status    := OKL_API.G_RET_STS_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  END IF;*/

		  /* call check_constraints */
		  Check_Constraints(p_upd_ptlv_rec   => l_upd_ptlv_rec,
                            p_ptlv_rec 	 	 => l_ptlv_rec,
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
  -- PROCEDURE determine_action for: OKL_PDT_TEMPLATES_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_ptlv_rec                 IN ptlv_rec_type,
	p_db_ptlv_rec				   IN ptlv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
 BEGIN

    /* Scenario 1: Only description changes */
  IF p_upd_ptlv_rec.from_date = Okl_Api.G_MISS_DATE AND
	 p_upd_ptlv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
	 l_action := '1';
	/* Scenario 2: only changing description and end date for all records
       or modified start date is less than existing start date */
  /*ELSIF (p_upd_ptlv_rec.from_date = OKL_API.G_MISS_DATE AND
	     p_upd_ptlv_rec.TO_DATE <> OKL_API.G_MISS_DATE) OR
	    (p_upd_ptlv_rec.from_date <> OKL_API.G_MISS_DATE AND
	     p_db_ptlv_rec.from_date > p_date AND
		 p_upd_ptlv_rec.from_date < p_db_ptlv_rec.from_date) THEN*/
  ELSE
	 l_action := '2';
  END IF;
  RETURN(l_action);
 END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_ptl_ptq_vals for: OKL_PDT_TEMPLATES_V
  -- To fetch the template qualities/values that are attached to the existing
  -- version of the product template
  ---------------------------------------------------------------------------
  PROCEDURE get_ptl_ptq_vals (p_upd_ptlv_rec   IN ptlv_rec_type,
    					      p_ptlv_rec       IN ptlv_rec_type,
                              p_flag           IN VARCHAR2,
						      x_return_status  OUT NOCOPY VARCHAR2,
						      x_count		   OUT NOCOPY NUMBER,
						      x_pmvv_tbl	   OUT NOCOPY pmvv_tbl_type
  ) IS
    CURSOR okl_pmvv_fk_csr (p_ptl_id IN Okl_Ptl_Ptq_Vals_V.ptl_id%TYPE) IS
    SELECT ID,
           PTQ_ID,
		   PTV_ID,
           FROM_DATE,
           TO_DATE
    FROM Okl_Ptl_Ptq_Vals_V pmv
    WHERE pmv.PTL_ID    = p_ptl_id;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_pmvv_tbl	    pmvv_tbl_type;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_pmv_rec IN okl_pmvv_fk_csr(p_upd_ptlv_rec.id)
	LOOP
       IF p_flag = G_UPDATE THEN
          l_pmvv_tbl(l_count).ID := okl_pmv_rec.ID;
       END IF;
	   l_pmvv_tbl(l_count).PTL_ID := p_ptlv_rec.ID;
	   l_pmvv_tbl(l_count).PTQ_ID := okl_pmv_rec.PTQ_ID;
	   l_pmvv_tbl(l_count).PTV_ID := okl_pmv_rec.PTV_ID;
       IF p_upd_ptlv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
          l_pmvv_tbl(l_count).from_date := p_upd_ptlv_rec.from_date;
       ELSE
          l_pmvv_tbl(l_count).from_date := okl_pmv_rec.from_date;
       END IF;
       IF p_upd_ptlv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
          l_pmvv_tbl(l_count).TO_DATE := p_upd_ptlv_rec.TO_DATE;
       ELSE
          l_pmvv_tbl(l_count).TO_DATE := okl_pmv_rec.TO_DATE;
       END IF;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_pmvv_tbl := l_pmvv_tbl;

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

      IF (okl_pmvv_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pmvv_fk_csr;
      END IF;

  END get_ptl_ptq_vals;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_pdt_pqys for: OKL_PDT_TEMPLATES_V
  -- To fetch the product qualities that are attached to the existing
  -- version of the product template
  ---------------------------------------------------------------------------
  PROCEDURE get_pdt_pqys (p_upd_ptlv_rec   IN ptlv_rec_type,
    					  p_ptlv_rec       IN ptlv_rec_type,
                          p_flag           IN VARCHAR2,
						  x_return_status  OUT NOCOPY VARCHAR2,
						  x_count		   OUT NOCOPY NUMBER,
						  x_pdqv_tbl	   OUT NOCOPY pdqv_tbl_type
  ) IS
    CURSOR okl_pdqv_fk_csr (p_ptl_id IN Okl_Pdt_Pqys_V.ptl_id%TYPE) IS
    SELECT ID,
           PQY_ID,
           FROM_DATE,
           TO_DATE
    FROM Okl_Pdt_Pqys_V pdq
    WHERE pdq.PTL_ID    = p_ptl_id;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_pdqv_tbl	    pdqv_tbl_type;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_pdq_rec IN okl_pdqv_fk_csr(p_upd_ptlv_rec.id)
	LOOP
       IF p_flag = G_UPDATE THEN
          l_pdqv_tbl(l_count).ID := okl_pdq_rec.ID;
       END IF;
	   l_pdqv_tbl(l_count).PTL_ID := p_ptlv_rec.ID;
	   l_pdqv_tbl(l_count).PQY_ID := okl_pdq_rec.PQY_ID;
       IF p_upd_ptlv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
          l_pdqv_tbl(l_count).from_date := p_upd_ptlv_rec.from_date;
       ELSE
          l_pdqv_tbl(l_count).from_date := okl_pdq_rec.from_date;
       END IF;
       IF p_upd_ptlv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
          l_pdqv_tbl(l_count).TO_DATE := p_upd_ptlv_rec.TO_DATE;
       ELSE
          l_pdqv_tbl(l_count).TO_DATE := okl_pdq_rec.TO_DATE;
       END IF;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_pdqv_tbl := l_pdqv_tbl;

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

      IF (okl_pdqv_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pdqv_fk_csr;
      END IF;

  END get_pdt_pqys;

  ---------------------------------------------------------------------------
  -- PROCEDURE copy_update_constraints for: OKL_PDT_TEMPLATES_V
  -- To copy constraints data from one version to the other
  ---------------------------------------------------------------------------
  PROCEDURE copy_update_constraints (p_api_version    IN  NUMBER,
                                     p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                                     p_upd_ptlv_rec   IN  ptlv_rec_type,
                                     p_db_ptlv_rec    IN  ptlv_rec_type,
    					             p_ptlv_rec       IN  ptlv_rec_type,
                                     p_flag           IN  VARCHAR2,
						             x_return_status  OUT NOCOPY VARCHAR2,
                      		 		 x_msg_count      OUT NOCOPY NUMBER,
                              		 x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
	l_upd_ptlv_rec	 	  	ptlv_rec_type; /* input copy */
	l_ptlv_rec	  	 	  	ptlv_rec_type; /* latest with the retained changes */
	l_db_ptlv_rec			ptlv_rec_type; /* for db copy */
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_pmv_count				NUMBER := 0;
    l_pdq_count             NUMBER := 0;
	l_pmvv_tbl				pmvv_tbl_type;
	l_out_pmvv_tbl			pmvv_tbl_type;
	l_pdqv_tbl				pdqv_tbl_type;
	l_out_pdqv_tbl			pdqv_tbl_type;

 BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_upd_ptlv_rec := p_ptlv_rec;
    l_ptlv_rec := p_ptlv_rec;
    l_db_ptlv_rec := p_db_ptlv_rec;

	/* product template qualities/values carryover */
	get_ptl_ptq_vals(p_upd_ptlv_rec	  => l_upd_ptlv_rec,
	 				 p_ptlv_rec		  => l_ptlv_rec,
                     p_flag           => p_flag,
					 x_return_status  => l_return_status,
					 x_count		  => l_pmv_count,
					 x_pmvv_tbl		  => l_pmvv_tbl);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_pmv_count > 0 THEN
       IF p_flag = G_UPDATE THEN
	      Okl_Ptq_Values_Pub.update_ptq_values(p_api_version   => p_api_version,
                           		 		       p_init_msg_list => p_init_msg_list,
                              		 		   x_return_status => l_return_status,
                              		 		   x_msg_count     => x_msg_count,
                              		 		   x_msg_data      => x_msg_data,
                              		 		   p_pmvv_tbl      => l_pmvv_tbl,
                              		 		   x_pmvv_tbl      => l_out_pmvv_tbl);
       ELSE
	      Okl_Ptq_Values_Pub.insert_ptq_values(p_api_version   => p_api_version,
                           		 		       p_init_msg_list => p_init_msg_list,
                              		 		   x_return_status => l_return_status,
                              		 		   x_msg_count     => x_msg_count,
                              		 		   x_msg_data      => x_msg_data,
                              		 		   p_pmvv_tbl      => l_pmvv_tbl,
                              		 		   x_pmvv_tbl      => l_out_pmvv_tbl);
       END IF;
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
	END IF;

	/* product defining qualities carryover */
	get_pdt_pqys(p_upd_ptlv_rec	  => l_upd_ptlv_rec,
	   			 p_ptlv_rec		  => l_ptlv_rec,
                 p_flag           => p_flag,
				 x_return_status  => l_return_status,
				 x_count		  => l_pdq_count,
				 x_pdqv_tbl		  => l_pdqv_tbl);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_pdq_count > 0 THEN
       IF p_flag = G_UPDATE THEN
	      Okl_Pdt_Pqys_Pub.update_pdt_pqys(p_api_version   => p_api_version,
                            		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_pdqv_tbl      => l_pdqv_tbl,
                              		 	   x_pdqv_tbl      => l_out_pdqv_tbl);
       ELSE
	      Okl_Pdt_Pqys_Pub.insert_pdt_pqys(p_api_version   => p_api_version,
                            		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_pdqv_tbl      => l_pdqv_tbl,
                              		 	   x_pdqv_tbl      => l_out_pdqv_tbl);
       END IF;
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
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
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END copy_update_constraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_pdttemplates for: OKL_PDT_TEMPLATES_V
  ---------------------------------------------------------------------------
   PROCEDURE insert_pdttemplates(p_api_version      IN  NUMBER,
                                p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	    x_return_status    OUT NOCOPY VARCHAR2,
                        	    x_msg_count        OUT NOCOPY NUMBER,
                        	    x_msg_data         OUT NOCOPY VARCHAR2,
                        	    p_ptlv_rec         IN  ptlv_rec_type,
                        	    x_ptlv_rec         OUT NOCOPY ptlv_rec_type
                        ) IS

 CURSOR c1(p_name okl_pdt_templates_v.name%TYPE,
		p_version okl_pdt_templates_v.version%TYPE) IS
   SELECT '1'
   FROM okl_pdt_templates_v
   WHERE  name = p_name;

    l_name           okl_pdt_templates_v.name%TYPE;
    l_unq_tbl               Okc_Util.unq_tbl_type;
    l_token_1        VARCHAR2(1999);
    l_pdt_status            VARCHAR2(1);
    l_row_found             BOOLEAN := FALSE;
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_pdttemplates';
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_ptlv_rec		  ptlv_rec_type;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
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

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_TEMPLATE_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_TEMPLATES');

    l_name := Okl_Accounting_Util.okl_upper(p_ptlv_rec.name);
    OPEN c1(l_name,
	      p_ptlv_rec.version);
    FETCH c1 INTO l_pdt_status;
    l_row_found := c1%FOUND;
    CLOSE c1;

    IF l_row_found THEN
        Okl_Api.set_message('OKL',G_UNQS, G_TABLE_TOKEN, l_token_1);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    /* check for the records with from and to dates less than sysdate */
    /*IF to_date(to_char(l_ptlv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_ptlv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;*/

	/* public api to insert pdttemplates */
    Okl_Pdt_Templates_Pub.insert_pdt_templates(p_api_version   => p_api_version,
                              		           p_init_msg_list => p_init_msg_list,
                              		           x_return_status => l_return_status,
                              		           x_msg_count     => x_msg_count,
                              		           x_msg_data      => x_msg_data,
                              		           p_ptlv_rec      => l_ptlv_rec,
                              		           x_ptlv_rec      => x_ptlv_rec);

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

       IF (c1%ISOPEN) THEN
	  CLOSE c1;
       END IF;

  END insert_pdttemplates;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_pdttemplates for: OKL_PDT_TEMPLATES_V
  ---------------------------------------------------------------------------
  PROCEDURE update_pdttemplates(p_api_version       IN  NUMBER,
                                p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	    x_return_status     OUT NOCOPY VARCHAR2,
                        	    x_msg_count         OUT NOCOPY NUMBER,
                        	    x_msg_data          OUT NOCOPY VARCHAR2,
                        	    p_ptlv_rec          IN  ptlv_rec_type,
                        	    x_ptlv_rec          OUT NOCOPY ptlv_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_pdttemplates';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
	l_oldversion_enddate  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_db_ptlv_rec    	  	ptlv_rec_type; /* database copy */
	l_upd_ptlv_rec	 	  	ptlv_rec_type; /* input copy */
	l_ptlv_rec	  	 	  	ptlv_rec_type; /* latest with the retained changes */
	l_tmp_ptlv_rec			ptlv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_new_version			VARCHAR2(100);
	l_pmv_count				NUMBER := 0;
    l_pdq_count             NUMBER := 0;
	l_pmvv_tbl				pmvv_tbl_type;
	l_out_pmvv_tbl			pmvv_tbl_type;
	l_pdqv_tbl				pdqv_tbl_type;
	l_out_pdqv_tbl			pdqv_tbl_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_upd_ptlv_rec := p_ptlv_rec;

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
    get_rec(p_ptlv_rec 	 	=> l_upd_ptlv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_ptlv_rec		=> l_db_ptlv_rec);

	IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_ptlv_rec     => l_upd_ptlv_rec,
                      p_db_ptlv_rec      => l_db_ptlv_rec);


	/* determine how the processing to be done */
	l_action := determine_action(p_upd_ptlv_rec	 => l_upd_ptlv_rec,
				     p_db_ptlv_rec	 => l_db_ptlv_rec,
				     p_date			 => l_sysdate);

	/* Scenario 1: only changing description */
	IF l_action = '1' THEN
	   /* public api to update product templates */
       Okl_Pdt_Templates_Pub.update_pdt_templates(p_api_version   => p_api_version,
                        		 	  p_init_msg_list => p_init_msg_list,
                       		 	          x_return_status => l_return_status,
 	              		 	          x_msg_count     => x_msg_count,
                       		 	          x_msg_data      => x_msg_data,
                       		 	          p_ptlv_rec      => l_upd_ptlv_rec,
                       		 	          x_ptlv_rec      => x_ptlv_rec);

       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 2: only changing description and end date for all records
       or modified start date is less than existing start date for a future record */
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_ptlv_rec := defaults_to_actuals(p_upd_ptlv_rec => l_upd_ptlv_rec,
	   					  				 p_db_ptlv_rec  => l_db_ptlv_rec);

           l_ptlv_rec.TO_DATE := l_ptlv_rec.TO_DATE;

           /* check the changes */
	   check_updates(p_upd_ptlv_rec	 => l_upd_ptlv_rec,
	   			     p_db_ptlv_rec	 => l_db_ptlv_rec,
					 p_ptlv_rec		 => l_ptlv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* public api to update product templates */
       Okl_Pdt_Templates_Pub.update_pdt_templates(p_api_version   => p_api_version,
                            		 	          p_init_msg_list => p_init_msg_list,
                              		 	          x_return_status => l_return_status,
                              		 	          x_msg_count     => x_msg_count,
                              		 	          x_msg_data      => x_msg_data,
                              		 	          p_ptlv_rec      => l_upd_ptlv_rec,
                              		 	          x_ptlv_rec      => x_ptlv_rec);
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       /* update constraints */
	  /* copy_update_constraints(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               p_upd_ptlv_rec	 => l_upd_ptlv_rec,
	   			               p_db_ptlv_rec	 => l_db_ptlv_rec,
					           p_ptlv_rec		 => l_ptlv_rec,
                               p_flag            => G_UPDATE,
                               x_return_status   => l_return_status,
                    		   x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
	   	*/
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

  END update_pdttemplates;

END Okl_Setuppdttemplates_Pvt;

/
